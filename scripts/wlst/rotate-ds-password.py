"""
rotate-ds-password.py — Update a WLS JDBC Data Source password via WLST

Usage: wlst.sh rotate-ds-password.py <admin_url> <admin_user> <ds_name>

Positional arguments (not sensitive):
  admin_url   — WLS Admin Server T3 URL, e.g. t3://ccb-admin-vm-01:7001
  admin_user  — WLS admin username, e.g. weblogic
  ds_name     — JDBC data source name to update

Credentials (sensitive — must be passed via environment variables):
  WLS_ADMIN_PASSWORD — WLS admin password retrieved from BeyondTrust
  DS_NEW_PASSWORD    — New database password retrieved from BeyondTrust

Typically called from a startup/rotation script that retrieves credentials
from BeyondTrust PasswordSafe via scripts/beyondtrust/get-credential.sh.
"""
import os
import sys

if len(sys.argv) != 4:
    print('Usage: wlst.sh rotate-ds-password.py <admin_url> <admin_user> <ds_name>')
    sys.exit(1)

admin_url      = sys.argv[1]  # t3://ccb-admin-vm-01:7001
admin_user     = sys.argv[2]
ds_name        = sys.argv[3]

admin_password = os.environ.get('WLS_ADMIN_PASSWORD')
new_password   = os.environ.get('DS_NEW_PASSWORD')

if not admin_password:
    print('ERROR: WLS_ADMIN_PASSWORD environment variable is not set.')
    sys.exit(1)
if not new_password:
    print('ERROR: DS_NEW_PASSWORD environment variable is not set.')
    sys.exit(1)

connect(admin_user, admin_password, admin_url)
edit()
startEdit()

try:
    cd('/JDBCSystemResources/' + ds_name + '/JDBCResource/' + ds_name +
       '/JDBCDriverParams/' + ds_name)
    cmo.setPassword(new_password)
    save()
    activate()
    print("DS password updated for: " + ds_name)
except Exception as e:
    cancelEdit('y')
    raise e
finally:
    disconnect()
