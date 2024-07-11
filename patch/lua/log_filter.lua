local Logger = require("logger")

local log_filter = {}

function log_filter.init(env)
    env.logger = Logger:new("log_filter_log.txt", "log_filter")
    env.logger:info("log_filter init")
end

function log_filter.func(input, env)
    local context = env.engine.context
    local inputCode = context.input
    local logger = env.logger
    logger:info("inputCode: " .. inputCode)

    for cand in input:iter() do
        yield(cand)
    end
end

function log_filter.fini(env)
    env.logger:info("log_filter fini")
    env.logger:close()
end

return log_filter
