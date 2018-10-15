#!/bin/bash
set -e
name=hutao
group=cmp
FILE_PATH=./master_ca
openssl genrsa -out $name.key 2048
openssl req -new -key $name.key -out $name.csr -subj "/CN=$name/O=$group"    
openssl x509 -req -in $name.csr -CA $FILE_PATH/ca.crt -CAkey $FILE_PATH/ca.key -CAcreateserial -out $name.crt -days 3650
kubectl config set-credentials $name --client-certificate=./$name.crt  --client-key=./$name.key
kubectl config set-context --cluster=kubernetes  $name-context  --user=$name

#Step2：解码账户名秘钥:
#cat $name.crt | base64 
#cat $name.key | base64

rm -rf rolebinding-deployment-manager.yaml role-deployment-manager.yaml
cp rolebinding-deployment-manager.yaml-bak rolebinding-deployment-manager.yaml
cp role-deployment-manager.yaml-bak role-deployment-manager.yaml

sed -i ’‘ s/username/$name/g rolebinding-deployment-manager.yaml
sed -i ’‘ s/username/$name/g role-deployment-manager.yaml

#Step3：创建角色操作:
kubectl apply -f role-deployment-manager.yaml

#Step4：绑定:
kubectl apply -f rolebinding-deployment-manager.yaml
