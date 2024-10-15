logger = {}
logger.prefix = "[%s]"
logger.color = Color(247, 0, 255)
logger.enum_type = {
    [1] = "INFO",
    [2] = "WARN",
    [3] = "ERROR",
    [4] = "DEBUG",
}
logger.logDir = "logs"
logger.logFile = ".txt"
logger.logFileTo = ".log"

if not file.Exists(logger.logDir, "DATA") then
    file.CreateDir(logger.logDir)
end

-- Функция для записи логов в файл
function logger:Write(message)
    if !SERVER then return end

    local date = os.date("%Y-%m-%d", os.time())
    local logFilePath = self.logDir .. "/" .. date
    local fLogFileName = logFilePath .. self.logFile

    file.Append(fLogFileName,  message .. "\n")
end

local function getCallerInfo()
    local level = 3
    local info
    repeat
        info = debug.getinfo(level, "Sl")
        level = level + 1
    until not info or info.short_src ~= debug.getinfo(1, "S").short_src

    if info then
        return string.format("%s:%d", info.short_src or "unknown", info.currentline or 0)
    end
    return "unknown:0"
end

-- Логирование с проверкой аргументов
function logger:Log(color_or_message, message, logType, ...)
    -- Проверка типов аргументов и наличие нужных
    if not message then
        print("Usage: logger:Log(color_or_message, message, logType, ...)")
        return
    end
    
    if not logType or not self.enum_type[logType] then
        print(string.format("Invalid logType provided. Available types: 1 (%s), 2 (%s), 3 (%s), 4 (%s)", self.enum_type[1], self.enum_type[2], self.enum_type[3], self.enum_type[4]))
        return
    end
    
    local args = {...}
    local tMessage
    local logTypeStr = self.enum_type[logType] or "INFO"

    -- Проверяем, что первый аргумент — это цвет
    if (isvector(color_or_message) or istable(color_or_message)) then
        color = color_or_message
        message = message or ""
    else
        color = self.color
        message = color_or_message
    end

    -- Если есть аргументы для форматирования, применяем string.format
    if (#args > 0) then
        tMessage = string.format(message, unpack(args))
    else
        tMessage = message
    end

    -- Печать с цветом и префиксом
    local ms = math.floor(os.clock() * 1000) % 1000
    local  date = os.date("[ %H:%M:%S ]", os.time())
    local callerInfo = getCallerInfo()
    MsgC(color_white, date, color, string.format(self.prefix, logTypeStr), string.format(" [%s] ", callerInfo), color_white, tMessage, "\n")

    local message_write = {date, string.format(self.prefix, logTypeStr), string.format("[%s]", callerInfo), tMessage}
    local concated_string = table.concat(message_write, " ")
    self:Write(concated_string)

end

-- shortcut
if (log != nil) or (IsValid(log) and log != log) then -- overwriting
    log = function(...)
        logger:Log(...)
    end
end

-- Типы логов
function logger:LogError(message, ...) 
    if not message then
        print("Usage: logger:LogError(message, ...)")
        return
    end
    self:Log(Color(255, 0, 0), message, 3, ...)
end

function logger:LogWarn(message, ...) 
    if not message then
        print("Usage: logger:LogWarn(message, ...)")
        return
    end
    self:Log(Color(255, 196, 0), message, 2, ...)
end

function logger:LogDebug(message, ...) 
    if not message then
        print("Usage: logger:LogDebug(message, ...)")
        return
    end
    self:Log(Color(0, 195, 255), message, 4, ...)
end

function logger:LogInfo(message, ...) 
    if not message then
        print("Usage: logger:LogInfo(message, ...)")
        return
    end
    self:Log(Color(0, 255, 0), message, 1, ...)
end

-- Шорткаты для типов логов
lge = function(...) logger:LogError(...) end
lgw = function(...) logger:LogWarn(...) end
lgd = function(...) logger:LogDebug(...) end
lgi = function(...) logger:LogInfo(...) end


-- local typeee = math.random(1,4)
-- if (typeee == 1) then
--     lgi("Hello, world!")
-- elseif (typeee == 2) then
--     lgw("Hello, world!")
-- elseif (typeee == 3) then
--     lge("Hello, world!")
-- else
--     lgd("Hello, world!")
-- end