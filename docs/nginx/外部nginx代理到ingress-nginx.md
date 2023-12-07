

```config
upstream clusertaskcenter {
     server 192.168.241.66:80;
     server 192.168.241.67:80;
     server 192.168.241.68:80;
     server 192.168.241.69:80;
     server 192.168.241.70:80;
     server 192.168.241.71:80;

}

server
{
    listen 80;
    listen  443 ssl;
    server_name *;
        ssl_certificate "/etc/pki/nginx/tls.crt";
        ssl_certificate_key "/etc/pki/nginx/tls.key";
	
        ssl_session_timeout  10m;
        ssl_ciphers HIGH:!aNULL:!MD5:!RC4;
        ssl_prefer_server_ciphers on;

	# proxy_ssl_server_name on; 
	# proxy_ssl_protocols SSLv3;
	# proxy_redirect     off;        
	    proxy_set_header   X-Real-IP	$remote_addr;
	    proxy_set_header   X-Forwarded-For   $remote_addr;
	    proxy_set_header   X-Forwarded-Proto https;
        proxy_set_header   X-Forwarded-Port 443;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";

        proxy_set_header Connection "";
        proxy_set_header Host $host;
        
        # error_log /var/log/nginx/infoplus_error.log warn;
        # access_log  /var/log/nginx/infoplus-ssl-access.log  main;


    
    location  / {
        proxy_pass      http://clusertaskcenter:80;
    }
  
 }

```
