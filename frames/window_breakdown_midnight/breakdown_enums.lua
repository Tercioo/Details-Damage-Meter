
local addonName, Details222 = ...

---@type detailsbreakdownmidnight
local breakdownMidnight = Details222.BreakdownWindowMidnight

---@class detailsbreakdownmidnight_sectionids
---@field Spells number
---@field Players number
---@field Segments number
---@field SpellDetails number
---@field Targets number
---@field Compare number

---@class detailsbreakdownmidnight_enums
---@field SectionIds detailsbreakdownmidnight_sectionids

breakdownMidnight.Enums = {
    SectionIds = {
        Spells = 1,
        Players = 2,
        Segments = 3,
        SpellDetails = 4,
        Targets = 5,
        Compare = 6,
    }
}
