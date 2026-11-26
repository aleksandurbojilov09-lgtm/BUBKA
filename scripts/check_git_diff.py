import json, os, subprocess
from pathlib import Path
from ci_classify import event_range, git

event=json.loads(Path(os.environ['GITHUB_EVENT_PATH']).read_text())
base,head=event_range(event,os.environ['GITHUB_EVENT_NAME'],os.environ['GITHUB_SHA'])
if base:
    subprocess.run(['git','diff','--check',base,head,'--'],check=True)
    for c in git('rev-list',f'{base}..{head}').decode().split():
        subprocess.run(['git','show','--check','--format=oneline',c],check=True)
else:
    subprocess.run(['git','show','--check','--format=oneline',head],check=True)
