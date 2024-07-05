-- logger.lua
---@class Logger
---@field file file
---@field prefix string
local Logger = {}
Logger.__index = Logger

local log_levels = {
    DEBUG = 0,
    INFO = 1,
    WARN = 2,
    ERROR = 3,
    SILENT = 100
}

--- Constructor
---@param filename string
---@param prefix string
---@param log_level string
---@return Logger
function Logger.new(filename, prefix, log_level)
    local self = setmetatable({}, Logger)
    self.file = io.open(filename, "a") -- Open the file in append mode
    self.prefix = prefix or ""
    self.log_level = log_levels[log_level] or log_levels.INFO
    if not self.file then
        error("Could not open file " .. filename)
    end
    return self
end

--- Method to log a message with a specific log level
---@param level string
---@param message string
---@return nil
function Logger:log(level, message)
    if self.file then
        if self.log_level > log_levels[level] then
            return
        end
        local log_entry = os.date("%Y-%m-%d %H:%M:%S") .. " [" .. self.prefix .. " " .. level .. "] " .. message .. "\n"
        self.file:write(log_entry)
        self.file:flush() -- Ensure the message is written to the file immediately
    else
        error("Log file is not open.")
    end
end

--- Convenience methods for various log levels

---@param message string
function Logger:debug(message)
    self:log("DEBUG", message)
end

---@param message string
function Logger:info(message)
    self:log("INFO", message)
end

---@param message string
function Logger:warn(message)
    self:log("WARN", message)
end

---@param message string
function Logger:error(message)
    self:log("ERROR", message)
end

--- Close the file when done
---@return nil
function Logger:close()
    if self.file then
        self.file:close()
        self.file = nil
    end
end

--- Dummy logger that does not write to a file
---@class DummyLogger
local DummyLogger = {}
DummyLogger.__index = DummyLogger

--- Constructor for a dummy logger that does not write to a file
---@return DummyLogger
function DummyLogger.new()
    return setmetatable({}, DummyLogger)
end

---@return DummyLogger
Logger.new_dummy = DummyLogger.new

local function ignore()
end

--- Convenience methods for dummy logger
DummyLogger.log = ignore
DummyLogger.debug = ignore
DummyLogger.info = ignore
DummyLogger.warn = ignore
DummyLogger.error = ignore
DummyLogger.close = ignore

--- Serialize a table to a string
---@param tabl table
---@param indent string?
function Logger.serialize_list(tabl, indent)
    indent = indent and (indent .. "  ") or ""
    local str = ''
    str = str .. indent .. "{"
    for key, value in pairs(tabl) do
        local pr = (type(key) == "string") and ('["' .. key .. '"]=') or ""
        if type(value) == "table" then
            str = str .. "\n" .. pr .. serialize_list(value, indent) .. ','
        elseif type(value) == "string" then
            str = str .. "\n" .. indent .. pr .. '"' .. value .. '",'
        else
            str = str .. "\n" .. indent .. pr .. tostring(value) .. ','
        end
    end
    str = str:sub(1, #str - 1) -- remove last symbol
    str = str .. "\n" .. indent .. "}"
    return str
end

return Logger
