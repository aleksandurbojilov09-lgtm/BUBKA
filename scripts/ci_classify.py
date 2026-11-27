"""Classify the checked-out event tree, conservatively including intermediate commits."""
import json
import os
import re
import subprocess
from pathlib import Path

DOCS = {'README.md','AGENTS.md','ARCHITECTURE.md','PROJECT_STATE.json','ROADMAP.md','MODULES.md','DECISIONS.md','KNOWN_ISSUES.md','CHANGELOG.md'}
FULL = (True, True, True)
DOC = (False, False, False)
LITE = (True, False, False)
RISKY_DART = re.compile(rb'(?i)(MigrationStrategy|schemaVersion|@DriftDatabase|@DriftAccessor|extends\s+Table\b|CREATE\s+TABLE|ALTER\s+TABLE|DROP\s+TABLE|PRAGMA\s+user_version|MethodChannel|EventChannel|BasicMessageChannel|dart:ffi|DynamicLibrary\.|package:ffi/)')
VERSION = re.compile(rb'^version: [0-9]+\.[0-9]+\.[0-9]+\+[1-9][0-9]*$', re.M)


def is_doc(p):
    return p in DOCS or (p.startswith('docs/') and p.endswith(('.md','.json','.txt')))


def version_only(before, after):
    # Identical bytes except one simple, top-level version scalar. More complex
    # YAML edits, duplicate version keys, or ambiguity never qualify as lite.
    return (before != after and len(VERSION.findall(before)) == 1
            and len(VERSION.findall(after)) == 1
            and len(re.findall(rb'^version\s*:', before, re.M)) == 1
            and VERSION.sub(b'version: VERSION', before) == VERSION.sub(b'version: VERSION', after))


def risky_path(p):
    return any(x in p.lower() for x in ('asset','schema','migration','database','sqlite','drift','plugin','gradle','podfile','package.resolved','project.pbxproj','build.sh','security','signing','generated','.g.dart','.freezed.dart'))


def internal_dart(p):
    return re.fullmatch(r'lib/features/[^/]+/(?:presentation|domain|data)/.+\.dart', p) and not risky_path(p)


def public_export(p):
    # Only the conventionally named module entrypoint, not arbitrary root Dart.
    return re.fullmatch(r'lib/features/([a-z][a-z0-9_]*)/\1\.dart', p)



def classify(paths, event='pull_request', version_ok=False, destructive=(), verified_exports=()):
    paths = set(paths)
    if not paths:
        return FULL
    if all(is_doc(p) for p in paths):
        return DOC
    if event != 'pull_request':
        return FULL
    if any(not is_doc(p) for p in destructive):
        return FULL
    for p in paths:
        if is_doc(p):
            continue
        if p in ('pubspec.yaml','lib/app/version.dart') and version_ok:
            continue
        if risky_path(p):
            return FULL
        if internal_dart(p) or re.fullmatch(r'(?:test|integration_test)/.+\.dart', p):
            continue
        if public_export(p) and p in verified_exports:
            continue
        return FULL
    return LITE


def git(*args):
    return subprocess.check_output(['git', *args])


def regular_blob(ref, path):
    entry = git('ls-tree', ref, '--', path)
    if not entry.startswith(b'100644 blob '):
        return None
    return git('show', ref + ':' + path)


def export_only(ref, path):
    content = regular_blob(ref, path)
    if content is None:
        return False
    lines = [line.strip() for line in content.splitlines() if line.strip()]
    if not lines:
        return False
    for line in lines:
        match = re.fullmatch(rb"export '((?:presentation|domain|data)/(?:[a-zA-Z0-9_]+/)*[a-zA-Z0-9_]+\.dart)';", line)
        if not match:
            return False
        target = path.rsplit('/', 1)[0] + '/' + match[1].decode('ascii')
        if not internal_dart(target):
            return False
        blob = regular_blob(ref, target)
        if blob is None or RISKY_DART.search(blob):
            return False
    return True



def commit(ref):
    if not isinstance(ref, str) or not re.fullmatch(r'[0-9a-f]{40}', ref):
        raise ValueError('Invalid commit SHA')
    return git('rev-parse','--verify',ref+'^{commit}').decode().strip()


def changes(base, head):
    raw = git('diff','--name-status','--no-renames','-z',base,head,'--').split(b'\0')
    if raw.pop() != b'' or len(raw) % 2:
        raise ValueError('Invalid diff')
    paths, destructive = set(), set()
    for status, path in zip(raw[::2],raw[1::2]):
        p = path.decode('utf-8',errors='strict')
        paths.add(p)
        if status not in (b'A',b'M'):
            destructive.add(p)
    return paths, destructive


def event_range(event, event_name, sha):
    head = commit(sha)
    if git('rev-parse','HEAD').decode().strip() != head:
        raise ValueError('Checkout does not match GITHUB_SHA')
    if event_name == 'pull_request':
        pr = event['pull_request']
        if pr['base']['ref'] != 'main':
            raise ValueError('Unexpected PR base')
        base, source = commit(pr['base']['sha']), commit(pr['head']['sha'])
        parents = git('show','-s','--format=%P',head).decode().split()
        if parents != [base, source]:
            raise ValueError('Not the expected synthetic merge commit')
        return base, head
    if event_name == 'push':
        if event.get('ref') != 'refs/heads/main' or event.get('after') != head:
            raise ValueError('Unexpected push')
        if any(event.get(k) for k in ('created','forced','deleted')) or event.get('before') == '0'*40:
            return None, head
        base = commit(event['before'])
        if subprocess.run(['git','merge-base','--is-ancestor',base,head]).returncode:
            return None, head
        return base, head
    if event_name == 'workflow_dispatch':
        if os.environ.get('GITHUB_REF') != 'refs/heads/main':
            raise ValueError('Manual full CI is main only')
        return None, head
    raise ValueError('Unexpected event')


def event_plan(event, event_name, sha):
    base, head = event_range(event,event_name,sha)
    if not base:
        return FULL
    return range_plan(base, head, event_name)


def range_plan(base, head, event_name):
    paths, destructive = changes(base,head)
    verified_exports = set()
    # Include all reachable new commits, including reverted risky edits.
    version_ok = True
    for c in git('rev-list',f'{base}..{head}').decode().split():
        parents = git('show','-s','--format=%P',c).decode().split()
        if not parents:
            return FULL
        # Compare first parent (merge result); side commits are visited too.
        p, d = changes(parents[0],c)
        paths.update(p); destructive.update(d)
        for path in p:
            if public_export(path):
                if not (export_only(parents[0], path) and export_only(c, path)):
                    return FULL
                verified_exports.add(path)
            if path.startswith(('lib/','test/','integration_test/')) and path.endswith('.dart'):
                patch = git('diff','--no-ext-diff','--no-renames','--unified=0',parents[0],c,'--',path)
                if any(RISKY_DART.search(line[1:]) for line in patch.splitlines() if line.startswith((b'+',b'-')) and not line.startswith((b'+++',b'---'))):
                    return FULL
        if 'pubspec.yaml' in p:
            version_ok &= version_only(git('show',parents[0]+':pubspec.yaml'),git('show',c+':pubspec.yaml'))
    version_ok &= ('pubspec.yaml' in paths and 'pubspec.lock' not in paths)
    if version_ok:
        version_ok = version_only(git('show',base+':pubspec.yaml'),git('show',head+':pubspec.yaml'))
    print('Changed paths:',json.dumps(sorted(paths)))
    return classify(paths,event_name,version_ok,destructive,verified_exports)


if __name__ == '__main__':
    event=json.loads(Path(os.environ['GITHUB_EVENT_PATH']).read_text())
    plan=event_plan(event,os.environ['GITHUB_EVENT_NAME'],os.environ['GITHUB_SHA'])
    with open(os.environ['GITHUB_OUTPUT'],'a') as f:
        for key,val in zip(('common','android','ios'),plan):
            print(f'{key}={str(val).lower()}',file=f)
    print('Plan:',plan)
