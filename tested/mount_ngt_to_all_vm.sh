for i in $(ncli vm list | grep "Id" | grep -v Hypervisor | awk -F ":" '{print $4}');do \
ncli ngt mount vm-id=$i;done