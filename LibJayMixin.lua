local MAJOR = "LibJayMixin"
local MINOR = 1

assert(LibStub, format("%s requires LibStub.", MAJOR))

local lib = LibStub:NewLibrary(MAJOR, MINOR)

if not lib then return end

local safecall, xsafecall
do -- safecall, xsafecall
    local pcall = pcall
    ---@param func function
    ---@return boolean retOK
    safecall = function(func, ...) return pcall(func, ...) end

    local geterrorhandler = geterrorhandler
    ---@param err string
    ---@return function handler
    local function errorhandler(err) return geterrorhandler()(err) end

    local xpcall = xpcall
    ---@param func function
    ---@return boolean retOK
    xsafecall = function(func, ...) return xpcall(func, errorhandler, ...) end
end

local error = error
local format = format
local pairs = pairs
local select = select
local type = type
---@param object table
---@return table object
function lib:Mixin(object, ...)
    if type(object) ~= "table" then
        error(format(
                  "Usage: %s:Mixin(object[, ...]): 'object' - table expected got %s",
                  MAJOR, type(object)), 2)
    end
    for i = 1, select("#", ...) do
        local mixin = select(i, ...)
        for k, v in pairs(mixin) do object[k] = v end
        if mixin.OnLoad then mixin.OnLoad(object) end
    end
    return object
end
setmetatable(lib, {__call = lib.Mixin})

---@return table newObject
function lib:CreateFrom(...) return self:Mixin({}, ...) end

local CreateFrame = CreateFrame
---@param frameType string
---@param name string
---@param parent table
---@param template string
---@param id number
---@return table newFrame
function lib:CreateFrame(frameType, name, parent, template, id, ...)
    local success, result = xsafecall(CreateFrame, frameType, name, parent,
                                      template, id)
    if success then return self:Mixin(result, ...) end
end
