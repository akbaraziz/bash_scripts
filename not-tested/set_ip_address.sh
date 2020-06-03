#setting up variables
ips=$1
domain_name=".xyz.com"
mc_name=$2
export ips
#Modifying the ifcfg-eth0 file
awk -v ip=$ips '/ONBOOT=no/{
print
print "DEVICE=eth0"
print "BOOTPROTO=static"
print "IPADDR=" ip
print "NETMASK=255.255.255.0"
print "GATEWAY=123.123.123.1"
next
}1' /etc/sysconfig/network-scripts/ifcfg-eth0> /etc/sysconfig/network-scripts/temp1

sed -e's/no/yes/' /etc/sysconfig/network-scripts/temp1 > /etc/sysconfig/network-scripts/temp2

rm /etc/sysconfig/network-scripts/ifcfg-eth0
mv /etc/sysconfig/network-scripts/temp2 ifcfg-eth0
chmod 644 /etc/sysconfig/network-scripts/ifcfg-eth0
rm /etc/sysconfig/network-scripts/temp1
rm /etc/sysconfig/network-scripts/temp2

#Modifying /etc/hosts
echo $ips $mc_name$domain_name $mc_name > /etc/host2
sed -e's/127.0.0.1/#127.0.0.1/' /etc/hosts > /etc/host1
rm /etc/hosts
mv /etc/host1 /etc/hosts
hostname $mc_name
rm /etc/host1
rm /etc/host2

#Modifying access.conf

sed -e's/-:root/#-:root/' /etc/security/access.conf > /etc/security/access1.conf
rm /etc/security/access.conf
mv /etc/security/access1.conf /etc/security/access.conf
rm /etc/security/access1.conf
echo "Don't forget to reboot the system"