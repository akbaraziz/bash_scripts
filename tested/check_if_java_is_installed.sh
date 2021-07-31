# Remove Existing Version of Java if installed
if rpm -qa | grep -q java*; then
    yum remove -y java*;
else
    echo Not Installed
fi