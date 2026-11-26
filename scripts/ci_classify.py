"""Fail-safe classification. --no-renames includes both old and new paths."""
import json
import os
import re
import subprocess
from pathlib import Path

DOCS = {'README.md','AGENTS.md','ARCHITECTURE.md','PROJECT_STATE.json','ROADMAP.md','MODULES.md','DECISIONS.md','KNOWN_ISSUES.md','CHANGELOG.md'}
FULL = (True, True, True)

def classify(paths):
    if not paths:
        return FULL
    result = [False, False, False]
    for p in paths:
        if p in DOCS or (p.startswith('docs/') and p.endswith(('.md','.json','.txt'))):
            continue
        if p.startswith('android/'):
            result[0] = result[1] = True
        elif p.startswith('ios/'):
            result[0] = result[2] = True
        elif re.fullmatch(r'lib/features/[^/]+/presentation/.+\.dart', p) or (p.startswith('test/') and p.endswith('.dart')):
            result[0] = True
        else:
            return FULL
        # Assets, plugin/dependency files and build scripts always require full CI.
        if any(x in p.lower() for x in ('/assets/', '.xcassets/', 'pubspec', 'podfile', 'package.resolved', 'plugin', 'gradle', 'build.gradle', 'build.sh', 'project.pbxproj')):
            return FULL
    return tuple(result)

def git(*args):
    return subprocess.check_output(['git', *args])

def event_plan(event, event_name, sha):
    if event_name == 'workflow_dispatch' or event_name not in ('push','pull_request'):
        return FULL
    if event_name == 'push':
        base, head = event.get('before'), sha
        if str(event.get('ref','')).startswith('refs/tags/') or event.get('created') or event.get('forced') or event.get('deleted'):
            return FULL
    else:
        base, head = event['pull_request']['base']['sha'], event['pull_request']['head']['sha']
        base = git('merge-base',base,head).decode().strip()
    if not base or not head or set(base)=={'0'}:
        return FULL
    for ref in (base,head):
        git('cat-file','-e',ref+'^{commit}')
    raw = git('diff','--name-only','--no-renames','-z',base,head,'--')
    paths = [p.decode('utf-8',errors='strict') for p in raw.split(b'\0') if p]
    print('Changed paths:',json.dumps(paths))
    return classify(paths)

if __name__ == '__main__':
    try:
        event=json.loads(Path(os.environ['GITHUB_EVENT_PATH']).read_text())
        plan=event_plan(event,os.environ['GITHUB_EVENT_NAME'],os.environ['GITHUB_SHA'])
    except Exception as exc:
        print(f'Classification fallback (full): {exc}')
        plan=FULL
    with open(os.environ['GITHUB_OUTPUT'],'a') as f:
        for key,val in zip(('common','android','ios'),plan):
            print(f'{key}={str(val).lower()}',file=f)
    print('Plan:',plan)
