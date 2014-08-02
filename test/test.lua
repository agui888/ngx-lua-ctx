local _ = require 'shim'
local context = require 'context'
local ctx = ngx.ctx

context(ctx)

ctx.var = 11111
_.ok(11111 == ctx.var)

local header = ctx.header
_.ok('table' == type(header))

_.ok('GET' == ctx.method)

_.ok({
    {a = '1', b = '2'}, -- curl
    ctx.query
})
_.ok({
    {'1.1.1.1', '2.2.2.2', '3.3.3.3'}, -- curl
    ctx.ips
})

_.ok('1.1.1.1' == ctx.ip)

local rawips = ctx.get('X-Forwarded-For')


_.ok({rawips, '1.1.1.1,2.2.2.2,  3.3.3.3'}) -- curl

ctx.set('field', 'value')

--ngx.say(_.dump(ngx.header.field))
--ngx.exit(200)

_.ok({'value', ngx.header.field})

ctx.type = 'text/html'
_.ok('text/html' == ngx.header['Content-Type'])

ctx.status = 201
_.ok(201 == ngx.status)

ctx.remove('field')
_.ok(not ngx.header.field)

_.ok('table' == type(ctx.event))

ngx.say('test ok')

