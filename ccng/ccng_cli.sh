#!/bin/sh

if [ -z "$AUTH_TOKEN" ]; then
  [ -z "$ADMIN_EMAIL" ] && echo "ADMIN_EMAIL not set! Aborting..." && exit 1;
  [ -z "$ADMIN_PW" ] && echo "ADMIN_PW not set! Aborting..." && exit 1;

  echo "Switching to UAA - admin context..."
  uaac token get $ADMIN_EMAIL $ADMIN_PW
  export AUTH_TOKEN="bearer $(uaac context | grep access_token | sed 's/ *access_token: //')"; echo $AUTH_TOKEN
fi

[ -z "$CCNG_HOST" ] && echo "CCNG_HOST not set! Aborting..." && exit 1

case $1 in
  custom) echo "Executing Get on endpoint: $2"
      curl -v -H "Authorization: $AUTH_TOKEN" http://$CCNG_HOST/$2
      ;;

  delete) echo "Executing Delete on endpoint: $2"
      curl -v -X DELETE -H "Authorization: $AUTH_TOKEN" http://$CCNG_HOST/$2
      ;;


  list-users) echo "Listing Users"
       curl -v -H "Authorization: $AUTH_TOKEN" http://$CCNG_HOST/v2/users
       ;;

  list-user) echo "List User: $2"
       curl -v -H "Authorization: $AUTH_TOKEN" http://$CCNG_HOST/v2/organizations?q=user_guid:$2
       ;;

  list-users-in-org) echo "Listing users in Org: $2"
       curl -v -H "Authorization: $AUTH_TOKEN" http://$CCNG_HOST/v2/organizations/$2/users
       ;;

  add-user-to-org) echo "Adding user: $2 to org $3"
       curl -v -X PUT -H "Content-Type: application/json" -H "Authorization: $AUTH_TOKEN" \
            -d '{"user_guids":[\"$2\"]}' http://$CCNG_HOST/v2/organizations/$3
       ;;

  create-org) echo "Creating org: $2"
       curl -v -X POST -H "Content-Type: application/json" -H "Authorization: $AUTH_TOKEN" \
            -d '{"name":\"$2\"}' http://$CCNG_HOST/v2/organizations
       ;;

  list-orgs) echo "Listing all organizations"
       curl -v -H "Authorization: $AUTH_TOKEN" http://$CCNG_HOST/v2/organizations
       ;;

  list-org) echo "Listing org: $2"
       curl -v -H "Authorization: $AUTH_TOKEN" http://$CCNG_HOST/v2/organizations/$2
       ;;

  create-user) echo "Creating user: $2"
       curl -v -X POST -H "Content-Type: application/json" -H "Authorization: $AUTH_TOKEN" \
            -d '{"guid":\"$2\"}' http://$CCNG_HOST/v2/users
       ;;

  create-space) echo "Creating space: $1 for org: $2"
       curl -v -X POST -H "Content-Type: application/json" -H "Authorization:$AUTH_TOKEN" \
            -d '{"name":\"$2\", "organization_guid":\"$3\"}' \
            http://$CCNG_HOST/v2/spaces
       ;;

  list-services) echo "Listing Services"
       curl -v -H "Authorization: $AUTH_TOKEN" http://$CCNG_HOST/v2/services
       ;;

  list-service-plans) echo "Listing Service plans for service: $2"
       curl -v -H "Authorization: $AUTH_TOKEN" http://$CCNG_HOST/v2/services/$2/service_plans
       ;;

  use-cc-token) echo "Switching to UAA - cloud_controller context..."
       [ -z "$CC_SECRET" ] && echo "CC_SECRET not set! Aborting..." && exit 1;
       uaac token client get cloud_controller -s $CC_SECRET
       ;;

  use-admin-token) echo "Switching to UAA - sre@vmware.com - admin context..."
       [ -z "$ADMIN_EMAIL"] && echo "ADMIN_EMAIL not set! Aborting..." && exit 1;
       [ -z "$ADMIN_PW"] && echo "ADMIN_PW not set! Aborting..." && exit 1;

       uaac token get $ADMIN_EMAIL $ADMIN_PW
       export AUTH_TOKEN="bearer $(uaac context | grep access_token | sed 's/ *access_token: //')"; echo $AUTH_TOKEN
       ;; 


  *)
        cat <<HELP_BLOCK
ccng_cli.sh <VERB> [options]

custom  <url>
delete <url>
list-users
list-user <user_guid>
list-users-in-org <org_guid>
add-user-to-org <user_guid> <org_guid>
create-org <org_name>
list-orgs
list-org <org_guid>
create-user <uaa_user_guid>
create-space <space_name> <org_guid>
list-services
list-service-plans <service_guid>
use-cc-token
use-admin-token

HELP_BLOCK

      echo "$help_text"
      ;;


esac 
