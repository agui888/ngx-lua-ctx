ngx-lua-ctx
---
[![build status][travis-image]][travis-url]

simple request context sugar like [koa](https://github.com/koajs/koa)

Usage
---

```lua
local _ = require 'shim'
local context = require 'context'
local ctx = ngx.ctx
context(ctx)

local query = ctx.query
ngx.say(query.name)
```

Api
---

todo

License
---

MIT

Copyright (c) 2012-2014 [Chunpu](https://github.com/chunpu)

[travis-image]: https://img.shields.io/travis/chunpu/ngx-lua-ctx.svg?style=flat
[travis-url]: https://travis-ci.org/chunpu/ngx-lua-ctx
