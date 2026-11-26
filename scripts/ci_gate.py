import os
for key in ('CLASSIFY','DOCS'):
    if os.environ[key]!='success': raise SystemExit(f'{key}={os.environ[key]}')
for name in ('COMMON','ANDROID','IOS'):
    required=os.environ[name+'_REQUIRED']
    actual=os.environ[name+'_RESULT']
    if required not in ('true','false') or actual != ('success' if required=='true' else 'skipped'):
        raise SystemExit(f'{name}: required={required}, result={actual}')
print('CI gate passed')
