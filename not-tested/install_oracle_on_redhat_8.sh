#!/bin/bash

set -ex

# Change Host Name
HOST_NAME=@@{HOST_NAME}@@
IPADDR=@@{address}
sudo hostnamectl set-hostname ${HOST_NAME}

sudo echo ${HOST_NAME} | tee /etc/hostname
sudo sed -i -E 's/^127.0.1.1.*/127.0.1.1\t'"${HOST_NAME}"'/' /etc/hosts
sudo sed -i -E 's/^127.0.1.1.*/127.0.1.1\t'"${HOST_NAME}"'/' /etc/sysconfig/network
sudo echo -e ""${IPADDR}" \t "${HOST_NAME}"" >> /etc/hosts

# Download Pre-Reqs for Oracle 19c
sudo dnf install -y https://yum.oracle.com/repo/OracleLinux/OL8/baseos/latest/x86_64/getPackage/oracle-database-preinstall-19c-1.0-1.el8.x86_64.rpm

# Disable SELINUX
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

# Update Firewall Rules
# Allow Port 22 through firewall
sudo firewall-cmd --permanent --zone=public --add-port=22/tcp
sudo firewall-cmd --permanent --zone=public --add-port=1521/tcp
sudo firewall-cmd --reload

# Set Oracle user password
passwd oracle

# Disable Transparent Huge Pages


# Create Oracle Directories
mkdir -p /u01/app/oracle/product/19.0.0/dbhome_1
mkdir -p /u02/oradata
chown -R oracle:oinstall /u01 /u02
chmod -R 775 /u01 /u02

# Create setEnv.sh File
cat > /home/oracle/scripts/setEnv.sh <<EOF
# Oracle Settings
export TMP=/tmp
export TMPDIR=\$TMP

export ORACLE_HOSTNAME=ol8-19.localdomain
export ORACLE_UNQNAME=cdb1
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=\$ORACLE_BASE/product/19.0.0/dbhome_1
export ORA_INVENTORY=/u01/app/oraInventory
export ORACLE_SID=cdb1
export PDB_NAME=pdb1
export DATA_DIR=/u02/oradata

export PATH=/usr/sbin:/usr/local/bin:\$PATH
export PATH=\$ORACLE_HOME/bin:\$PATH

export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=\$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib
EOF

echo ". /home/oracle/scripts/setEnv.sh" >> /home/oracle/.bash_profile

# Create a start_all.sh and stop_all.sh script
cat > /home/oracle/scripts/start_all.sh <<EOF
#!/bin/bash
. /home/oracle/scripts/setEnv.sh

export ORAENV_ASK=NO
. oraenv
export ORAENV_ASK=YES

dbstart \$ORACLE_HOME
EOF


cat > /home/oracle/scripts/stop_all.sh <<EOF
#!/bin/bash
. /home/oracle/scripts/setEnv.sh

export ORAENV_ASK=NO
. oraenv
export ORAENV_ASK=YES

dbshut \$ORACLE_HOME
EOF

chown -R oracle:oinstall /home/oracle/scripts
chmod u+x /home/oracle/scripts/*.sh

# Create Scripts Directory
sudo mkdir -p /home/oracle/scripts

# Install Script for Oracle
# Unzip software.
cd $ORACLE_HOME
unzip -oq /path/to/software/LINUX.X64_193000_db_home.zip

# Fake Oracle Linux 7.
export CV_ASSUME_DISTID=OEL7.6

# Interactive mode.
./runInstaller

# Silent mode.
./runInstaller -ignorePrereq -waitforcompletion -silent                        \
-responseFile ${ORACLE_HOME}/install/response/db_install.rsp               \
oracle.install.option=INSTALL_DB_SWONLY                                    \
ORACLE_HOSTNAME=${ORACLE_HOSTNAME}                                         \
UNIX_GROUP_NAME=oinstall                                                   \
INVENTORY_LOCATION=${ORA_INVENTORY}                                        \
SELECTED_LANGUAGES=en,en_GB                                                \
ORACLE_HOME=${ORACLE_HOME}                                                 \
ORACLE_BASE=${ORACLE_BASE}                                                 \
oracle.install.db.InstallEdition=EE                                        \
oracle.install.db.OSDBA_GROUP=dba                                          \
oracle.install.db.OSBACKUPDBA_GROUP=dba                                    \
oracle.install.db.OSDGDBA_GROUP=dba                                        \
oracle.install.db.OSKMDBA_GROUP=dba                                        \
oracle.install.db.OSRACDBA_GROUP=dba                                       \
SECURITY_UPDATES_VIA_MYORACLESUPPORT=false                                 \
DECLINE_SECURITY_UPDATES=true

# Run Post-Install Scripts
sudo /u01/app/oraInventory/orainstRoot.sh
sudo /u01/app/oracle/product/19.0.0/dbhome_1/root.sh

# Create Database
# Start the listener.
lsnrctl start

# Interactive mode.
dbca

# Silent mode.
dbca -silent -createDatabase                                                   \
-templateName General_Purpose.dbc                                         \
-gdbname ${ORACLE_SID} -sid  ${ORACLE_SID} -responseFile NO_VALUE         \
-characterSet AL32UTF8                                                    \
-sysPassword SysPassword1                                                 \
-systemPassword SysPassword1                                              \
-createAsContainerDatabase true                                           \
-numberOfPDBs 1                                                           \
-pdbName ${PDB_NAME}                                                      \
-pdbAdminPassword PdbPassword1                                            \
-databaseType MULTIPURPOSE                                                \
-memoryMgmtType auto_sga                                                  \
-totalMemory 2000                                                         \
-storageType FS                                                           \
-datafileDestination "${DATA_DIR}"                                        \
-redoLogFileSize 50                                                       \
-emConfiguration NONE                                                     \
-ignorePreReqs
