export DOMAIN=<INSERT DOMAIN HERE>
export ADMIN_EMAIL=<insert admin email>
export ADMIN_PW=<insert admin password>

export CCNG_HOST=ccng.$DOMAIN
export UAA_HOST=uaa.$DOMAIN

export CC_SECRET=fOZF5DMNDZIfCb9A

uaac token get $ADMIN_EMAIL $ADMIN_PW
export AUTH_TOKEN="bearer $(uaac context | grep access_token | sed 's/ *access_token: //')"; echo $AUTH_TOKEN
