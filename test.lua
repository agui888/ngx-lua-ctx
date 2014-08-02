local context = require 'context'
local _ = require 'shim'

local ctx = {}

context(ctx)

ctx.type = 'xxx'

print(_.a)


print(ctx.method == ctx)
