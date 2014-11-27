pkill -9 nginx
rm -f /usr/local/openresty/nginx/conf/nginx.conf
cp test/nginx.conf /usr/local/openresty/nginx/conf/

rm -f shim.lua*
wget --no-check-certificate https://raw.githubusercontent.com/chunpu/Shim/master/shim.lua
cp *.lua /tmp
cp test/lib/*.lua /tmp # lib for require
cp test/*.lua /usr/local/openresty/nginx/ # entrance
#cp test/*.lua /usr/local/openresty/nginx/

/usr/local/openresty/nginx/sbin/nginx

RET=`curl -s 'localhost/basic?a=1&b=2' -H "Connection: keep-alive" -H "Cache-Control: no-cache" -H "X-Forwarded-For: 1.1.1.1,2.2.2.2,  3.3.3.3"`
echo $RET
[ "$RET" == "test ok" ] && echo test round 1 ok

# ctx should be isolated
RET2=`curl -s 'localhost/basic?a=1&b=2' -H "Connection: keep-alive" -H "Cache-Control: no-cache" -H "X-Forwarded-For: 1.1.1.1,2.2.2.2,  3.3.3.3"`
echo $RET2
[ "$RET2" == "test ok" ] && echo test round 2 ok

# ctx should be isolated in module function
RET3=`curl -s 'localhost/module'`
echo $RET3
[ "$RET2" == "ok" ]

# ctx should be isolated in module function
RET4=`curl -s 'localhost/module'`
echo $RET4
[ "$RET4" == "ok" ]

# ctx should always send once
RET5=`curl -s 'localhost/send'`
echo $RET5
[ "$RET5" == "12nil45" ]
