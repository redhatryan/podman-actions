ssh-keygen -N "" -f /Users/retten/Homelab/podman-actions/ovirt.id_rsa

if [ "x$subscriptionOrg" == "x" ]
then
   read -p "What is your subscription org used to register RHEL? " subscriptionOrg
fi
if [ "x$subscriptionKey" == "x" ]
then
   read -p "What is your subscription key? " subscriptionKey
fi
echo "export subscriptionOrg=$subscriptionOrg
export subscriptionKey=$subscriptionKey" > /Users/retten/Homelab/podman-actions/subscription.txt