return function()
    local ctx = ngx.ctx
    assert(not ctx.a)
    ngx.ctx.a = 100
    assert(ctx.a == 100)
    ngx.say('ok')
end
