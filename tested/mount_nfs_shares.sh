# settings
target_ip=10.10.10.33
target_folder=/apps
mount_folder=/mnt/apps
mount_attempts=3
ping_attempts=5

#test if its already mounted
if [ -n "`mount | grep $mount_folder`" ]; then
  echo "Server already mounted."
  exit 0
fi

if [ ! -d "$mount_folder" ]; then
  echo "Mount point $mount_folder doesn't exist"
  exit 1
fi