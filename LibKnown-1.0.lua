-- LibKnown.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/30/2024, 4:44:30 PM
--
local MAJOR, MINOR = 'LibKnown-1.0', 1

---@class LibKnown-1.0
local Lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not Lib then
    return
end

local C = LibStub('C_Everywhere')
local GARRISON_ICONS = {[1001489] = true, [1001490] = true, [1001491] = true}

local function HasHeirloom(id)
    return C.Heirloom and C.Heirloom.IsItemHeirloom(id) and C.Heirloom.PlayerHasHeirloom(id)
end

local function IsKnown(id)
    local tipData = C.TooltipInfo.GetItemByID(id)

    for i, lineData in ipairs(tipData.lines) do
        local text = lineData.leftText
        if text and text == ITEM_SPELL_KNOWN then
            return true
        end
    end
end

local known = setmetatable({}, {
    __index = function(t, id)
        if HasHeirloom(id) or IsKnown(id) then
            t[id] = true
            return true
        end
    end,
})

function Lib:IsKnownable(id)
    if not id then
        return false
    end
    if C.Heirloom and C.Heirloom.IsItemHeirloom(id) then
        return true
    end
    if C.ToyBox and select(2, C.ToyBox.GetToyInfo(id)) then
        return true
    end
    local _, _, _, _, icon, classId, subClassId = GetItemInfoInstant(id)
    if GARRISON_ICONS[icon] then
        return true
    end
    if classId == Enum.ItemClass.Recipe then
        return true
    end
    if classId == Enum.ItemClass.Miscellaneous then
        if subClassId == Enum.ItemMiscellaneousSubclass.Mount then
            return true
        end
    end
end

function Lib:IsKnown(id)
    if self:IsKnownable(id) then
        return known[id]
    end
end
