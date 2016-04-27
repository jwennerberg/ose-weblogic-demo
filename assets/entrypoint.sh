#!/bin/bash

DOMAIN_HOME="/u01/oracle/weblogic/user_projects/domains/base_domain"

CONFIG_JVM_ARGS="${CONFIG_JVM_ARGS} -Dweblogic.security.SSL.ignoreHostnameVerification=true"
WLST="wlst.sh -skipWLSModuleScanning"

############################################################
# Preparations
############################################################

get_var_name() {
  echo $1 | tr '[a-z]' '[A-Z]' | tr '-' '_'
}

export ADMIN_HOST=127.0.0.1
export ADMIN_PORT=7001
export MS_NAME="ManagedServer1"

export DATABASE_HOST=$(eval echo "\$$(get_var_name $DATABASE_SERVICE_NAME)_SERVICE_HOST")
export DATABASE_PORT=$(eval echo "\$$(get_var_name $DATABASE_SERVICE_NAME)_SERVICE_PORT")
export MQ_HOST=$(eval echo "\$$(get_var_name $MQ_SERVICE_NAME)_SERVICE_HOST")
export MQ_PORT=$(eval echo "\$$(get_var_name $MQ_SERVICE_NAME)_SERVICE_PORT")

sed -i "s/^WLS_USER=.*/WLS_USER=weblogic/g" ${DOMAIN_HOME}/bin/startManagedWebLogic.sh
sed -i "s/^WLS_PW=.*/WLS_PW=$ADMIN_PASSWORD/g" ${DOMAIN_HOME}/bin/startManagedWebLogic.sh

############################################################
# Deployment
############################################################

ADMSRV_LOG=AdminServer_start.log
MGDSRV_LOG=ManagedServer_start.log

pushd $DOMAIN_HOME
echo "# Start AdminServer" > $ADMSRV_LOG
nohup ./startWebLogic.sh > $ADMSRV_LOG &
# Wait for AdminServer
tail -f $ADMSRV_LOG | grep -m 1 "Server started in RUNNING mode" | { cat; echo >> $ADMSRV_LOG ; }
popd

# Create ManagedServer1
$WLST /u01/oracle/create-managed-server.py

pushd $DOMAIN_HOME
echo "# Start ManagedServer" > $MGDSRV_LOG
nohup ./bin/startManagedWebLogic.sh $MS_NAME http://${ADMIN_HOST}:${ADMIN_PORT} > $MGDSRV_LOG &
tail -f $MGDSRV_LOG | grep -m 1 "Server started in RUNNING mode" | { cat; echo >> $MGDSRV_LOG ; }
popd

# Deploy webapp
$WLST /u01/oracle/deploy-webapp.py

# Print log
tail -f ${DOMAIN_HOME}/servers/${MS_NAME}/logs/${MS_NAME}.log
