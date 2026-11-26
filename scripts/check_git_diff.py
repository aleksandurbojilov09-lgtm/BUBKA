import json, os, subprocess
from pathlib import Path

def git(*args):
    return subprocess.check_output(['git',*args],text=True).strip()
event=json.loads(Path(os.environ['GITHUB_EVENT_PATH']).read_text())
head=git('rev-parse','HEAD')
base=None
if os.environ['GITHUB_EVENT_NAME']=='pull_request':
    try: base=git('merge-base',event['pull_request']['base']['sha'],head)
    except subprocess.CalledProcessError: pass
elif os.environ['GITHUB_EVENT_NAME']=='push':
    candidate=event.get('before','')
    if candidate and set(candidate)!={'0'}:
        try: base=git('rev-parse','--verify',candidate+'^{commit}')
        except subprocess.CalledProcessError: pass
if base: subprocess.run(['git','diff','--check',base,head,'--'],check=True)
else: subprocess.run(['git','show','--check','--format=oneline',head],check=True)
