"""Trusted main CI artifact selection and verification; no builds or signing here."""
import argparse
import datetime as dt
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import zipfile

REPO='aleksandurbojilov09-lgtm/BUBKA'
CI_PATH='.github/workflows/ci.yml'
JOBS=('classify','docs','Common checks','Android unsigned release APK','iOS unsigned IPA','BUBKA CI gate')


def require(condition, message):
    if not condition:
        raise ValueError(message)


def api(path, paginated=False):
    args=['gh','api',path]
    if paginated: args += ['--paginate','--slurp']
    return json.loads(subprocess.check_output(args))


def items(path, key):
    pages=api(path+'?per_page=100',True)
    result=[item for page in pages for item in page[key]]
    require(bool(pages) and len(result)==pages[0]['total_count'],'Incomplete or changing API result')
    return result


def validate_run(run, sha, repo_id, workflow_id, run_id):
    expected={'id':run_id,'head_sha':sha,'head_branch':'main','path':CI_PATH,'workflow_id':workflow_id,'status':'completed','conclusion':'success'}
    require(all(run.get(k)==v for k,v in expected.items()),'Wrong CI identity, SHA or status')
    require(run.get('event') in ('push','workflow_dispatch'),'Not trusted main CI')
    require(all(run.get(k,{}).get('id')==repo_id for k in ('repository','head_repository')),'Wrong CI repository')
    attempt=run.get('run_attempt')
    require(type(attempt) is int and attempt>0,'Missing attempt')
    return attempt


def validate_jobs(jobs, run_id, attempt, sha):
    for name in JOBS:
        matches=[j for j in jobs if j.get('name')==name]
        require(len(matches)==1, f'Missing or ambiguous job: {name}')
        j=matches[0]
        require(j.get('run_id')==run_id and j.get('run_attempt',attempt)==attempt and j.get('head_sha',sha)==sha and j.get('status')=='completed' and j.get('conclusion')=='success',f'Not a successful job in selected attempt: {name}')


def select_artifacts(artifacts, run_id, attempt, sha, repo_id, version, build, now=None):
    now=now or dt.datetime.now(dt.timezone.utc)
    selected={}
    for platform in ('android','ios'):
        name=f'BUBKA-{version}-{build}-{platform}-unsigned-attempt-{attempt}'
        matches=[a for a in artifacts if a.get('name')==name]
        require(len(matches)==1,f'Missing or ambiguous artifact {name}')
        a=matches[0]; w=a.get('workflow_run',{})
        require(all(w.get(k)==v for k,v in {'id':run_id,'repository_id':repo_id,'head_repository_id':repo_id,'head_branch':'main','head_sha':sha}.items()),'Wrong artifact provenance')
        require(a.get('expired') is False and dt.datetime.fromisoformat(a['expires_at'].replace('Z','+00:00'))>now,'Expired artifact')
        require(type(a.get('id')) is int and a['id']>0 and re.fullmatch(r'sha256:[0-9a-f]{64}',a.get('digest') or ''),'Missing artifact ID or archive digest')
        selected[platform]={'id':a['id'],'digest':a['digest'],'name':name}
    require(selected['android']['id']!=selected['ios']['id'],'Duplicate artifact ID')
    return selected


def sha256(path):
    with open(path,'rb') as f: return hashlib.file_digest(f,'sha256').hexdigest()


def verify_archive(archive, digest, dest, platform, version, build, provenance):
    require('sha256:'+sha256(archive)==digest,'Archive digest mismatch')
    ext='apk' if platform=='android' else 'ipa'
    payload=f'BUBKA-{version}+{build}-unsigned.{ext}'
    expected={payload,'SHA256SUMS.txt','PROVENANCE.json'}
    if platform=='ios': expected.add('ENVIRONMENT.txt')
    with zipfile.ZipFile(archive) as z:
        names=z.namelist()
        require(len(names)==len(expected) and set(names)==expected,'Unexpected archive files')
        require(json.loads(z.read('PROVENANCE.json'))==provenance,'Internal attempt metadata mismatch')
        checksum=z.read('SHA256SUMS.txt').decode().strip()
        require(bool(re.fullmatch(r'[0-9a-f]{64}  '+re.escape(payload),checksum)),'Invalid internal checksum manifest')
        dest.mkdir(exist_ok=False)
        # Never extract arbitrary paths or symlinks from ZIP.
        for name in names:
            with z.open(name) as src, (dest/name).open('xb') as dst:
                import shutil
                shutil.copyfileobj(src,dst)
        require(sha256(dest/payload)==checksum.split()[0],'Payload checksum mismatch')


def current_main(sha):
    require(api(f'repos/{REPO}/git/ref/heads/main')['object']['sha']==sha,'main moved; stop release')


def check_release_sequence(version, build):
    # A new release may not reuse any existing release version or build number.
    # Validate historical manifests rather than assuming version implies build.
    target=tuple(map(int,version.split('.')))
    for release in api(f'repos/{REPO}/releases?per_page=100',True):
        for r in release:
            tag=r.get('tag_name','')
            require(tag != 'v'+version,'Release version already exists')
            if r.get('draft'):
                raise ValueError('Existing draft release; manual review required')
            m=re.fullmatch(r'v([0-9]+)\.([0-9]+)\.([0-9]+)',tag)
            require(bool(m) and tuple(map(int,m.groups()))<target,'Non-monotonic release version')
            assets=[a for a in r.get('assets',[]) if a.get('name')=='update-manifest.json']
            require(len(assets)==1,'Missing historical update manifest')
            with tempfile.TemporaryDirectory() as t:
                subprocess.run(['gh','release','download',tag,'--repo',REPO,'--pattern','update-manifest.json','--dir',t],check=True)
                data=json.loads((Path(t)/'update-manifest.json').read_text())
                require(data.get('tag')==tag,'Historical manifest tag mismatch')
                entries=data.get('assets',[])
                require(len(entries)==2 and {a.get('platform') for a in entries}=={'android','ios'},'Invalid historical manifest')
                require(all(type(a.get('build_number')) is int and 0<a['build_number']<int(build) for a in entries),'Non-monotonic build number')


def version_info():
    return tuple(subprocess.check_output(['python3','scripts/version.py',part],text=True).strip() for part in ('version','build'))


def resolve(run_id,sha,version,build):
    current_main(sha)
    repo_id=api(f'repos/{REPO}')['id']
    wf=api(f'repos/{REPO}/actions/workflows/ci.yml')
    require(wf['path']==CI_PATH,'Wrong workflow path')
    base=f'repos/{REPO}/actions/runs/{run_id}'
    attempt=validate_run(api(base),sha,repo_id,wf['id'],run_id)
    validate_jobs(items(f'{base}/attempts/{attempt}/jobs','jobs'),run_id,attempt,sha)
    selected=select_artifacts(items(f'{base}/artifacts','artifacts'),run_id,attempt,sha,repo_id,version,build)
    require(validate_run(api(base),sha,repo_id,wf['id'],run_id)==attempt,'CI attempt changed during selection')
    return {'attempt':attempt,'artifacts':selected}


def metadata(platform,version,build,run_id,attempt,sha):
    return dict(repository=REPO,sha=sha,run_id=run_id,attempt=attempt,platform=platform,version=version,build=build)


def main():
    parser=argparse.ArgumentParser(); parser.add_argument('mode',choices=['stamp','resolve','download','prepublish']); parser.add_argument('--platform',choices=['android','ios']); parser.add_argument('--directory'); parser.add_argument('--run-id',type=int); parser.add_argument('--selection'); args=parser.parse_args()
    require(os.environ['GITHUB_REPOSITORY']==REPO,'Unexpected repository')
    sha=os.environ['GITHUB_SHA']; version,build=version_info()
    if args.mode=='stamp':
        data=metadata(args.platform,version,build,int(os.environ['GITHUB_RUN_ID']),int(os.environ['GITHUB_RUN_ATTEMPT']),sha)
        (Path(args.directory)/'PROVENANCE.json').write_text(json.dumps(data)+'\n')
        return
    if args.mode=='prepublish':
        require(os.environ['GITHUB_REF']=='refs/heads/main','Release only from main')
        current_main(sha); check_release_sequence(version,build); current_main(sha)
        return
    require(os.environ['GITHUB_REF']=='refs/heads/main' and args.run_id and args.run_id>0,'Release only from main')
    selected=resolve(args.run_id,sha,version,build)
    if args.mode=='resolve':
        check_release_sequence(version,build)
        print(json.dumps(selected,separators=(',',':')))
        return
    require(selected==json.loads(args.selection),'CI selection changed after validation')
    with tempfile.TemporaryDirectory() as temp:
        for platform,a in selected['artifacts'].items():
            archive=Path(temp)/(platform+'.zip')
            with archive.open('wb') as out:
                subprocess.run(['gh','api',f'repos/{REPO}/actions/artifacts/{a["id"]}/zip'],stdout=out,check=True)
            verify_archive(archive,a['digest'],Path(platform+'-input'),platform,version,build,metadata(platform,version,build,args.run_id,selected['attempt'],sha))
    require(resolve(args.run_id,sha,version,build)==selected,'CI selection changed during download')


if __name__=='__main__': main()
