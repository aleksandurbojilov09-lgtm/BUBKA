from pathlib import Path
import re

for p in Path('lib').rglob('*.dart'):
    if p.name.endswith('.g.dart'): continue
    s=p.read_text(); rel=p.parts
    for target in re.findall(r"(?:import|export)\s+['\"]([^'\"]+)['\"]",s):
        assert target not in ('package:flutter/material.dart','package:flutter/cupertino.dart'),p
        if target.startswith('package:garage/'):
            q=Path('lib')/target.removeprefix('package:garage/')
        elif ':' not in target:
            q=(p.parent/target).resolve().relative_to(Path.cwd().resolve())
        else:
            if 'presentation' in rel:
                assert not target.startswith(('package:drift/','package:sqlite3/')), (p,target)
            continue
        if rel[1]=='core': assert q.parts[1] in ('core',), (p,q)
        if rel[1]=='features':
            assert q.parts[1]!='app', (p,q)
            if q.parts[1]=='features' and q.parts[2]!=rel[2]:
                assert len(q.parts)==4 and q.name==q.parts[2]+'.dart',(p,q)
            if 'presentation' in rel:
                assert 'database' not in q.parts and 'data' not in q.parts,(p,q)
print('Architecture import boundaries passed')
