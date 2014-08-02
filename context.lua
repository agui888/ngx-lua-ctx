local _ = require 'shim'
local cache = {}

local ctx

local req = {
    get_header = function()
        return ngx.req.get_headers()
    end,

    get_url = function()
    end,

    get_method = function()
        return ngx.req.get_method()
    end,

    get_path = function()
    end,

    get_query = function()
        if not ctx._query then
            local qs = ngx.req.get_uri_args()
            for k, v in pairs(qs) do
                if type(v) == 'table' then
                    qs[k] = v[#v]
                end
            end
            ctx._query = qs
        end
        return ctx._query
    end,
    
    get_ips = function()
        local val = ctx.get('X-Forwarded-For') or ''
        return _.split(val, ' *, *')
    end,

    get_ip = function()
        return ctx.ips[1] or ngx.var.remote_addr
    end,

    get = function(k)
        return ctx.header[k]
    end,
}

local res = {
    set_type = function(v)
        ctx.set('Content-Type', v)
    end,

    get_type = function()
        return ngx.header['Content-Type']
    end,

    set_body = function(x)
        -- todo, most important and should flag it has sent   
    end,

    set_status = function(v)
        ngx.status = v
    end,

    get_status = function()
        return ngx.status
    end,
    
    redirect = function(...)
        ngx.redirect(...)
    end,

    set = function(k, v)
        ngx.header[k] = v -- response, don't confuse
    end,

    remove = function(k)
        ngx.req.clear_header(k)
    end
   
}

local proto = {
    res = res,
    req = req,
    event = {},

    throw = function(err)
        ctx.emit('error', err)
    end,

    emit = function(ev, msg)
        local arr = ctx.event[ev]
        if arr then
            _._each(arr, function(fn)
                fn(msg)
            end)
        end
    end,

    on = function(ev, fn)
        if type(ev) == 'string' and type(fn) == 'function' then
            if not ctx.event[ev] then
                ctx.event[ev] = []
            end
            local arr = event[ev]
            if not _.has(arr, fn) then
                _.push(arr, fn)
            end
        end
    end,
}

_.extend(proto, req, res)

local getter = function(ctx, k)
    k = 'get_' .. k
    if type(proto[k]) == 'function' then
        return proto[k]()
    end
end

local setter = function(ctx, k, v)
    k = 'set_' .. k
    if type(proto[k]) == 'function' then
        proto[k](v)
    end
end

return function(_ctx)
    ctx = _ctx
    setmetatable(_ctx, {
        __index = getter,
        __newindex = setter
    })
    for k, v in proto do
        if not _.has(k, '_') then
            ctx[k] = proto[v]
        end
    end
end
