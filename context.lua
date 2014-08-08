local _ = require 'shim'

return function(ctx)
    local cache = {}

    local req = {
        get_header = function()
            return ngx.req.get_headers()
        end,

        get_url = function()
            return ngx.var.uri
        end,

        get_originalUrl = function()
            return ngx.var.request_uri
        end,

        get_method = function()
            return ngx.var.request_method
        end,

        get_path = function()
            return ngx.var.request_filename
        end,

        get_querystring = function()
            return ngx.var.args
        end,

        get_host = function()
            return ngx.var.host
        end,
        
        get_hostname = function()
            return ngx.var.hostname
        end,

        get_query = function()
            if not cache.query then
                local qs = ngx.req.get_uri_args()
                for k, v in pairs(qs) do
                    if type(v) == 'table' then
                        qs[k] = v[#v]
                    end
                end
                cache.query = qs
            end
            return cache.query
        end,
        
        get_ips = function()
            local val = ctx.get('X-Forwarded-For')
            if val then
                return _.split(val, ' *, *')
            end
            return {}
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
        --[[
        set_body = function(x)
            -- todo, most important and should flag it has sent   
        end,]]

        set_status = function(v)
            ngx.status = v
        end,

        get_status = function()
            return ngx.status
        end,
        
        redirect = function(...)
            ngx.redirect(...)
        end,

        set = function(k, v) -- need to know if has written
            ngx.header[k] = v -- response, don't confuse
        end,

        remove = function(k)
            ngx.header[k] = nil
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
                local event = ctx.event
                if not event[ev] then
                    event[ev] = {}
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
        local fn = proto['get_' .. k]
        if type(fn) == 'function' then
            return fn()
        end
        return cache[k]
    end

    local setter = function(ctx, k, v)
        local fn = proto['set_' .. k]
        if type(fn) == 'function' then
            fn(v)
        else
            cache[k] = v -- dirty
        end
    end

    for k, v in pairs(proto) do
        if _.indexOf(k, '_') ~= 4 then
            ctx[k] = v
        end
    end

    setmetatable(ctx, {
        __index = getter,
        __newindex = setter
    })
    ngx.say(_.dump(ngx.var))
    return ctx
end
