"""
rotate-ds-password.py — Update a WLS JDBC Data Source password via WLST
Usage: wlst.sh rotate-ds-password.py <admin_url> <admin_user> <admin_password> <ds_name> <new_db_password>
Typically called from a startup script that retrieves new_db_password from BeyondTrust.
"""
import sys

admin_url      = sys.argv[1]  # t3://ccb-admin-vm-01:7001
admin_user     = sys.argv[2]
admin_password = sys.argv[3]
ds_name        = sys.argv[4]
new_password   = sys.argv[5]

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
