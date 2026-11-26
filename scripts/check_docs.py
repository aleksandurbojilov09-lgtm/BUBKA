import json
from pathlib import Path
import re
for p in [Path('PROJECT_STATE.json'), *Path('docs/handoffs').glob('*.json')]:
    data=json.loads(p.read_text())
    assert data['project']=='BUBKA', p
    assert isinstance(data['phase'], int), p
    if p.parent.name=='handoffs':
        assert data['task_id']==f"BUBKA-{data['phase']:03d}", p
        assert p.stem==f"PHASE-{data['phase']:02d}", p
for p in ['README.md','AGENTS.md','ARCHITECTURE.md','ROADMAP.md','MODULES.md','DECISIONS.md','KNOWN_ISSUES.md','CHANGELOG.md']:
    assert Path(p).read_text().strip(),p
state=json.loads(Path('PROJECT_STATE.json').read_text())
assert state['version']==re.search(r'^version: (.+)\+\d+$',Path('pubspec.yaml').read_text(),re.M)[1]
assert state['build_number']==int(re.search(r'^version: .+\+(\d+)$',Path('pubspec.yaml').read_text(),re.M)[1])
for p in Path('docs').rglob('*.json'):
    json.loads(p.read_text())
print('Documentation checks passed')
