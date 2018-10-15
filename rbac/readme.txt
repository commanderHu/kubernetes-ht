1. 初始化k8s环境
2. 创建serviceAccout：
    kubectl create clusterrolebinding --user system:serviceaccount:kube-system:default kube-system-cluster-admin --clusterrole cluster-admin
3. 查看token
    SECRET_NAME=`kubectl describe sa default | grep Tokens | awk '{print $2}'`
    TOKEN=`kubectl describe secret $SECRET_NAME | grep token: | awk '{print $2}'`
4. 修改pod数量
    APISERVER=`echo $(kubectl config view | grep server | cut -f 2- -d ":" | tr -d " ")`
    API_URL="$APISERVER/apis/extensions/v1beta1/namespaces/default/deployments/cmp-redis/scale"
    PAYLOAD='[{"op":"replace","path":"/spec/replicas","value":2}]'
    curl -X PATCH -d$PAYLOAD -H 'Content-Type: application/json-patch+json' $API_URL --header "Authorization: Bearer $TOKEN" --insecure








nohup java -jar aido-eureka/aido-eureka-1.0.0.jar --spring.profiles.active=eureka > aido-eureka/log 2>&1 &
sleep 15
nohup java -jar aido-config/aido-config-1.0.0.jar > aido-config/log 2>&1 &
sleep 35
nohup java -jar aido-gateway/aido-gateway-1.0.0.jar > aido-gateway/log 2>&1 &
sleep 15
nohup java -jar aido-schedule/aido-schedule-1.0.0.jar > aido-schedule/log 2>&1 &
sleep 5
nohup java -jar aido-user-impl/aido-user-impl-1.0.0.jar > aido-user-impl/log 2>&1 &
sleep 5
nohup java -jar aido-auth-server/aido-auth-server-1.0.0.jar > aido-auth-server/log 2>&1 &
sleep 5
nohup java -jar aido-oss/aido-oss-1.0.0.jar > aido-oss/log 2>&1 &
sleep 5
nohup java -jar aido-agile-impl/aido-agile-impl-1.0.0.jar > aido-agile-impl/log 2>&1 &
sleep 5
nohup java -jar aido-agile-admin/aido-agile-admin-1.0.0.jar > aido-agile-admin/log 2>&1 &


####################请自定义以下内容，包括工作目录，svn，编译处理等####################
#log_path请务必填写，作为编译的结果文件，需要做校验使用
#以下部分为编译必须
echo $SHELL
setenv ANT_HOME ${HOME}/ant
setenv JAVA_HOME ${HOME}/jdk1.6.0_45

setenv work_home $HOME/work/cmp-testenv-dk-rm

setenv log_path ${work_home}/bin/logs/create-crm.log
setenv jar_path ${work_home}/dest/crm

echo ${work_home}/bin ---------------------------------------
echo $JAVA_HOME --------------
echo $log_path  $jar_path $ANT_HOME ---------------------------------------

cd ${work_home}/bin
svn_log=`./update-crm.sh`
echo $svn_log ---------------------------------------
if  [ "X`echo "$svn_log" | awk '{print $1$2$3}'|grep Updatedtorevision`" !=  "X" ];then
    echo "测试分支存在代码更新，需要更新编译"
#./create-crm.sh

else
    echo "没有需要编译的代码清单"
endif

####################以下部分请勿动，自动生成的部分脚本，请勿操作####################
#处理编译结果，判断是否编译成功，该脚本暂只支持鉴别JAVA错误

#exit 1