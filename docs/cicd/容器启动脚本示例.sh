#!/bin/bash -e
#------修改环境变量-------
CONTAINER_ALREADY_STARTED="CONTAINER_ALREADY_STARTED_PLACEHOLDER";
if [ ! -e $CONTAINER_ALREADY_STARTED ]; then
    touch $CONTAINER_ALREADY_STARTED;
    echo "-- First container startup --";
#    cat /usr/share/nginx/html/note/index.html;
    # YOUR_JUST_ONCE_LOGIC_HERE
    echo "-- BUS_URL= $BUS_URL --";
    sed -i   "s#BUS_URL#$BUS_URL#"  /usr/share/nginx/html/note/index.html;
    echo "-- OAUTH_AUTHORITY_URL= $OAUTH_AUTHORITY_URL --";
    sed -i   "s#OAUTH_AUTHORITY_URL#$OAUTH_AUTHORITY_URL#"  /usr/share/nginx/html/note/index.html;
    echo "-- OAUTH_CLIENT_ID= $OAUTH_CLIENT_ID --";
    sed -i   "s#OAUTH_CLIENT_ID#$OAUTH_CLIENT_ID#"  /usr/share/nginx/html/note/index.html;
    echo "-- SSO_LOGOUT_URL= $SSO_LOGOUT_URL --";
    sed -i   "s#SSO_LOGOUT_URL#$SSO_LOGOUT_URL#"  /usr/share/nginx/html/note/index.html;
    echo "-- contextPath= $contextPath --";
    sed -i   "s#contextPath#$contextPath#"  /usr/share/nginx/html/note/index.html;

#cat /usr/share/nginx/html/note/index.html;
else
    echo "-- Not first container startup --"
fi

#------docker-entrypoint.sh 默认--------
for hook in $(ls /startup-hooks); do
  echo -n "Found startup hook ${hook} ... ";
  if [ -x "/startup-hooks/${hook}" ]; then
    echo "executing.";
    /startup-hooks/${hook};
  else
    echo 'not executable. Skipping.';
  fi
done

_quit () {
  echo 'Caught sigquit, sending SIGQUIT to child';
  kill -s QUIT $child;
}

trap _quit SIGQUIT;

echo 'Starting child (nginx)';
nginx -g 'daemon off;' &
child=$!;

echo 'Waiting on child...';
wait $child;

