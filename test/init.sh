pkill -9 nginx
rm -f /usr/local/openresty/nginx/conf/nginx.conf
cp test/nginx.conf /usr/local/openresty/nginx/conf/

rm -f shim.lua*
wget --no-check-certificate https://raw.githubusercontent.com/chunpu/Shim/master/shim.lua
cp *.lua /tmp/
cp test/test.lua /usr/local/openresty/nginx/test.lua

/usr/local/openresty/nginx/sbin/nginx

RET=`curl -s 'localhost/basic?a=1&b=2'  -H "Connection: keep-alive" -H "Cache-Control: no-cache" -H "X-Forwarded-For: 1.1.1.1,2.2.2.2,  3.3.3.3"`
echo $RET
[ "$RET" == "test ok" ]
