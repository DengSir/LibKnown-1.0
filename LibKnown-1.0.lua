-- LibKnown.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/30/2024, 4:44:30 PM
--
local MAJOR, MINOR = 'LibKnown-1.0', 2

---@class LibKnown-1.0
local Lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not Lib then
    return
end

local GARRISON_ICONS = {[1001489] = true, [1001490] = true, [1001491] = true}
local ITEM_SPELL_KNOWN = ITEM_SPELL_KNOWN

local GetItemInfoInstant = GetItemInfoInstant or C_Item.GetItemInfoInstant
local GetToyInfo = C_ToyBox and C_ToyBox.GetToyInfo
local IsItemHeirloom = C_Heirloom and C_Heirloom.IsItemHeirloom
local PlayerHasHeirloom = C_Heirloom and C_Heirloom.PlayerHasHeirloom

local function HasHeirloom(id)
    return IsItemHeirloom(id) and PlayerHasHeirloom(id)
end

local IsKnown
if C_TooltipInfo then
    function IsKnown(id)
        local tipData = C_TooltipInfo.GetItemByID(id)

        for _, lineData in ipairs(tipData.lines) do
            local text = lineData.leftText
            if text and text == ITEM_SPELL_KNOWN then
                return true
            end
        end
    end
else
    local Tooltip
    function IsKnown(id)
        if not Tooltip then
            if not LibKnownTooltip then
                LibKnownTooltip = CreateFrame('GameTooltip', 'LibKnownTooltip', UIParent, 'GameTooltipTemplate')
                LibKnownTooltip.Left = setmetatable({}, {
                    __index = function(t, i)
                        local font = _G['LibKnownTooltipTextLeft' .. i]
                        t[i] = font
                        return font
                    end,
                })
            end
            Tooltip = LibKnownTooltip
        end

        Tooltip:SetOwner(UIParent, 'ANCHOR_NONE')
        Tooltip:SetItemByID(id)

        for i = 1, Tooltip:NumLines() do
            local text = Tooltip.Left[i]:GetText()
            if text and text == ITEM_SPELL_KNOWN then
                Tooltip:Hide()
                return true
            end
        end
        Tooltip:Hide()
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
    if IsItemHeirloom and IsItemHeirloom(id) then
        return true
    end
    if GetToyInfo and select(2, GetToyInfo(id)) then
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
