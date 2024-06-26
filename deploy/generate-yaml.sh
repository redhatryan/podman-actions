namespace=$1
touch namespace.last
lastNamespace=$(cat namespace.last)
lastNamespace=${lastNamespace:validated-pattern}
printf -v sshPubKey "%q" $(<../ovirt.id_rsa.pub tr -d '\n' | base64)
if [ "x$namespace" == "x" ]
then
   read -p "What namespace name [$lastNamespace]? " namespace
fi
if [ -z "$namespace" ]
then
   namespace="$lastNamespace"
fi
echo "$namespace" > namespace.last
source ../subscription.txt
cat namespace.yaml.template | perl -pe "s/\{\{ namespace \}\}/$namespace/g" > $namespace.yaml
baseDomain=$(oc get --namespace openshift-ingress-operator ingresscontrollers/default -o jsonpath='{.status.domain}')
if [ -n "$GUID" ]
then
  altDomain=$baseDomain
  baseDomain="apps.$GUID.etbit.io"
fi
echo "---" >> $namespace.yaml
oc create secret generic id-rsa --from-file ../ovirt.id_rsa -n $namespace --dry-run=client -o yaml >> $namespace.yaml
cat rhel8.install.yaml.template ubi8.yaml.template | \
  perl -pe "s/\{\{ namespace \}\}/$namespace/g" | \
  perl -pe "s/\{\{ baseDomain \}\}/$baseDomain/g" | \
  perl -pe "s/\{\{ subscriptionOrg \}\}/$subscriptionOrg/g" | \
  perl -pe "s/\{\{ subscriptionKey \}\}/$subscriptionKey/g" | \
  perl -MMIME::Base64 -pe "s/\{\{ sshPubKey \}\}/decode_base64('$sshPubKey')/ge" \
  >> $namespace.yaml
for name in lab; do
  cat rhel8.master.yaml.template | \
      perl -pe "s/\{\{ name \}\}/$name/g" | \
      perl -pe "s/\{\{ namespace \}\}/$namespace/g" | \
      perl -pe "s/\{\{ baseDomain \}\}/$baseDomain/g" | \
      perl -MMIME::Base64 -pe "s/\{\{ sshPubKey \}\}/decode_base64('$sshPubKey')/ge" \
  >> $namespace.yaml
done
cat namespace.yaml.template ../deploy/rhel8.yaml.template | perl -pe "s/\{\{ namespace \}\}/$namespace/g" > ../deploy/rhel8/vm.yaml
echo "# Apply yaml using:"
echo "oc apply -f ../rhel/vm.yaml"
echo "oc apply -f $namespace.yaml"