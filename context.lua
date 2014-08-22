local _ = require 'shim'

return function(ctx)
    
    ctx = ctx or ngx.ctx

    local req = {
        get_header = function()
            return ngx.req.get_headers()
        end,

        get_url = function()
            return ngx.var.request_uri
        end,

        set_url = function(...)
            ngx.req.set_uri(...) -- maybe wrong
        end,

        get_originalUrl = function()
            return ngx.var.request_uri
        end,

        get_method = function()
            return ngx.req.get_method()
        end,

        set_method = function(v)
            ngx.req.set_method(v)
        end,

        get_path = function()
            return ngx.var.uri
        end,

        get_querystring = function()
            return ngx.var.args
        end,

        get_host = function()
            return ngx.var.host .. ngx.var.server_port
        end,

        get_protocol = function()
            return ngx.var.server_protocol
        end,
        
        get_hostname = function()
            return ngx.var.host
        end,

        get_query = function()
            if not ctx._query then
                local qs = ngx.req.get_uri_args()
                for k, v in pairs(qs) do
                    if type(v) == 'table' then
                        qs[k] = v[#v]
                    elseif v == true then
                        qs[k] = ''
                    end
                end
                ctx._query = qs
            end
            return ctx._query
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
        local _v = rawget(ctx, k)
        if _v ~= nil then return _v end
        local fn = proto['get_' .. k]
        if type(fn) == 'function' then
            return fn()
        end
    end

    local setter = function(ctx, k, v)
        local _v = rawget(ctx, k)
        local fn = proto['set_' .. k]
        if _v == nil and type(fn) == 'function' then
            fn(v)
        end
        rawset(ctx, k, v)
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

    return ctx
end
