import os
for key in ('CLASSIFY','DOCS'):
    if os.environ[key]!='success': raise SystemExit(f'{key}={os.environ[key]}')
for name in ('COMMON','ANDROID','IOS'):
    required=os.environ[name+'_REQUIRED']
    actual=os.environ[name+'_RESULT']
    if required not in ('true','false') or actual != ('success' if required=='true' else 'skipped'):
        raise SystemExit(f'{name}: required={required}, result={actual}')
common,android,ios=(os.environ[n+'_REQUIRED']=='true' for n in ('COMMON','ANDROID','IOS'))
if (android or ios) and not common:
    raise SystemExit('Platform build without common checks is invalid')
if os.environ['GITHUB_EVENT_NAME']=='workflow_dispatch' and not all((common,android,ios)):
    raise SystemExit('Manual full CI requires all jobs')
if os.environ['GITHUB_EVENT_NAME']=='push' and common and not (android and ios):
    raise SystemExit('Non-doc main CI requires both platform builds')
if os.environ['GITHUB_EVENT_NAME'] not in ('push','pull_request','workflow_dispatch'):
    raise SystemExit('Unexpected event')
print('CI gate passed')
