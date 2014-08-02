pkill -9 nginx
rm -f /usr/local/openresty/nginx/conf/nginx.conf
cp test/nginx.conf /usr/local/openresty/nginx/conf/


#wget --no-check-certificate https://raw.githubusercontent.com/chunpu/Shim/master/shim.lua
cp *.lua /tmp/

/usr/local/openresty/nginx/sbin/nginx



