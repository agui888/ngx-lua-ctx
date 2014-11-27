local context = require 'context'
local ctx = ngx.ctx

context(ctx)

ctx.add(1)
ctx.add('2')
ctx.add(nil)
ctx.add(4)

ctx.send(5)

ctx.add(6)
ctx.send()
