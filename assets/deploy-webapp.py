# =============================
import os
import random
import string
import socket

# Functions
def randomName():
  return ''.join([random.choice(string.ascii_letters + string.digits) for n in xrange(16)])

def editMode():
  edit()
  startEdit()

def editActivate():
  save()
  activate(block="true")

# AdminServer details
username  = os.environ.get('ADMIN_USERNAME', 'weblogic')
password  = os.environ.get('ADMIN_PASSWORD')
adminhost = os.environ.get('ADMIN_HOST', 'wlsadmin')
adminport = os.environ.get('ADMIN_PORT', '7001')
cluster_name = os.environ.get("CLUSTER_NAME", "Cluster-Docker")
target_name = os.environ.get('TARGET_NAME', 'ManagedServer1')

# Application artifcact details
webapp_name = os.environ.get('WEBAPP_NAME', 'shoppingcart')
artifact_path = os.environ.get('ARTIFACT_PATH', '/u01/oracle')
artifact_name = os.environ.get('ARTIFACT_NAME', 'shoppingcart.war')

# Connect to the AdminServer
# ==========================
connect(username, password, 't3://' + adminhost + ':' + adminport)

print 'Deploying....'
deploy(webapp_name, artifact_path + '/' + artifact_name, targets=target_name)
print '....deployed. Starting....'
startApplication(webapp_name)
print '....started'

disconnect()
exit()
