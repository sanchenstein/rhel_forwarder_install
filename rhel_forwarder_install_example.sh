 HOSTS_FILE="$HOME/test/hosts.txt"

 # This should be a WGET command that was *carefully* copied from splunk.com!!
 # Sign into splunk.com and go to the download page, then look for the wget
 # link near the top of the page (once you have selected your platform)
 # copy and paste your wget command between the ""
 WGET_CMD="wget -O splunkforwarder-7.1.2-...'"

 # Set the install file name to the name of the file that wget downloads
 # (the second argument to wget)
 INSTALL_FILE="splunkforwarder-7.1.2..."

 # After installation, the forwarder will become a deployment client of this
 # host.  Specify the host and management (not web) port of the deployment server
 # that will be managing these forwarder instances.
 DEPLOY_SERVER="<ds_server>:8089"
 # Set the new Splunk admin password
 PASSWORD="<password>"

 # ----------- End of user settings -----------

 # create script to run remotely. Watch out for line wraps, esp. in the "set deploy-poll" line below.
 # the remote script assumes that 'splunkuser' (the login account) has permissions to write to the
 # /opt directory (this is not generally the default in Linux)
 REMOTE_SCRIPT="
 cd /opt
 sudo $WGET_CMD
 sudo rpm -i splunkforwarder-7.1.2-a0c72a66db66-linux-2.6-x86_64.rpm
# /opt/splunkforwarder/bin/splunk enable boot-start -user splunkusername
 /opt/splunkforwarder/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd $PASSWORD
 /opt/splunkforwarder/bin/splunk set deploy-poll \"$DEPLOY_SERVER\" -auth admin:$PASSWORD
 /opt/splunkforwarder/bin/splunk restart
 "
 echo "In 5 seconds, will run the following script on each remote host:"
 echo
 echo "===================="
 echo "$REMOTE_SCRIPT"
 echo "===================="
 echo
 sleep 5
 echo "Reading host logins from $HOSTS_FILE"
 echo
 echo "Starting."

 for DST in `cat "$HOSTS_FILE"`; do
   if [ -z "$DST" ]; then
     continue;
   fi
   echo "---------------------------"
   echo "Installing to $DST"

   # run script on remote host - you will be prompted for the password
   ssh -i <public_key> "$DST" "$REMOTE_SCRIPT"

 done
 echo "---------------------------"
 echo "Done"