#cloud-config
hostname: ${vm_name}
fqdn: ${vm_name}
manage_etc_hosts: true

users:
  - name: ${oracle_user}
    gecos: Oracle Software Owner
    groups: [oinstall, dba]
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${ssh_pubkey}

  - name: root
    ssh_authorized_keys:
      - ${ssh_pubkey}

packages:
  - nfs-utils
  - net-tools
  - unzip
  - lsof
  - curl
  - wget

runcmd:
  - groupadd -g 54321 oinstall || true
  - groupadd -g 54322 dba     || true
  - usermod -u 54321 -g oinstall ${oracle_user} || true
  - mkdir -p /u01/oracle/{products,config,logs,media}
  - chown -R ${oracle_user}:oinstall /u01/oracle
  - chmod 0755 /u01/oracle
  - echo "vm.swappiness=10" >> /etc/sysctl.d/99-oracle-cloud-init.conf
  - sysctl -p /etc/sysctl.d/99-oracle-cloud-init.conf

final_message: "Oracle Linux VM ${vm_name} ready after $UPTIME seconds"
