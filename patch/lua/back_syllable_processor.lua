local backSyllableProcessor = {}

local Logger = require("logger")
local log = Logger.new_dummy("C:\\Users\\etaoi\\Desktop\\rime.log", "back_syllable_processor", "INFO")

log:info("Loading back syllable processor...")

function backSyllableProcessor.init(env)
    local engine = env.engine
    local config = engine.schema.config

    env.back_syllable_processor = {}

    local editor_bindings = config:get_map("editor/bindings")
    local syllable_begin = config:get_string("speller/syllable_begin")
    local syllable_end = config:get_string("speller/syllable_end")

    env.back_syllable_processor.delimiters = syllable_begin .. ' ' .. syllable_end

    log:info("Delimiters: " .. env.back_syllable_processor.delimiters)

    env.back_syllable_processor.delimiter_map = {}
    for i = 1, #syllable_begin do
        env.back_syllable_processor.delimiter_map[syllable_begin:sub(i, i)] = 'begin'
    end
    for i = 1, #syllable_end do
        env.back_syllable_processor.delimiter_map[syllable_end:sub(i, i)] = 'end'
    end

    log:debug("Delimiter map: " .. Logger.serialize_list(env.back_syllable_processor.delimiter_map))

    -- List of keys that will trigger the back syllable processor
    local respond_keys = {}
    local respond_key_set = {}

    for _, key in ipairs(editor_bindings:keys()) do
        local value = editor_bindings:get_value(key):get_string()
        if value == "back_syllable_delimited" then
            table.insert(respond_keys, key)
            respond_key_set[key] = true
        end
    end

    log:info("Respond keys: " .. table.concat(respond_keys, ", "))
    env.back_syllable_processor.respond_keys = respond_keys
    env.back_syllable_processor.respond_key_set = respond_key_set
end

local function pop_input_remove_syllable(env, context)
    local input = context.input
    if #input == 0 then
        return false
    end

    local caret_pos = context.caret_pos

    log:debug("Caret position: " .. caret_pos)
    if caret_pos == 0 then
        return false
    end

    for i = caret_pos, 1, -1 do
        log:debug("Checking for delimiter: " .. input:sub(i, i))
        local delimiter_type = env.back_syllable_processor.delimiter_map[input:sub(i, i)]
        log:debug("Condition evaluates to: " .. tostring(delimiter_type))
        local num_removed = 0
        if delimiter_type == 'begin' then
            num_removed = caret_pos - i + 1
        elseif delimiter_type == 'end' then
            num_removed = caret_pos - i
        end
        log:debug("Number to remove: " .. num_removed)
        if num_removed > 0 then
            log:debug("Removing " .. num_removed .. " characters: " .. input:sub(caret_pos - num_removed + 1, caret_pos))
            context:pop_input(num_removed)
            return true
        end
    end

    context:pop_input(#input)
    return true
end

function backSyllableProcessor.func(key_event, env)
    local engine = env.engine
    local context = engine.context
    local back_syllable_processor = env.back_syllable_processor
    local respond_key_set = back_syllable_processor.respond_key_set

    if key_event:release() then
        return 2
    end

    if not context:is_composing() then
        return 2
    end

    local key_code = key_event:repr()
    log:debug("Got key code: " .. key_code .. ", input: " .. context.input)

    if respond_key_set[key_code] then
        log:debug("Responding to key code: " .. key_code)
        local result = context:reopen_previous_selection()
        log:debug("Reopen previous selection result: " .. tostring(result))
        if result then
            return 1
        end
        pop_input_remove_syllable(env, context)
        context:reopen_previous_segment()
        return 1
    end

    return 2
end

function backSyllableProcessor.fini(env)
    env.back_syllable_processor = nil
end

return backSyllableProcessor
