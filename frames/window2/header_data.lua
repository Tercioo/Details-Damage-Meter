
local Details = Details
local addonName, Details222 = ...
---@type detailsframework
local detailsFramework = DetailsFramework
local _

---@type details_allinonewindow
local AllInOneWindow = Details222.AllInOneWindow

local columnOffset = 0

--{"damage_heal1", "dps_heal1", "hps_heal2", "death", "interrupt", "dispel"} --dps_heal1 seria se o jogador trocar a spec?
--"damage done", "dps", "healing done", "hps"
--"icon", "rank", "pname", "dmg", "dmgdps", "dmgdpspercent", "heal", "healhps", "healhpspercent", "death", "interrupt", "dispel"

---@class details_allinonewindow_headercolumndata : df_headercolumndata
---@field label string?
---@field enbaled boolean?
---@field attribute number
---@field subAttribute number
---@field shownOnOptions boolean?
---@field showText boolean? true to show the text in the header, false to hide it

local p = 0.125 --32/256

---default settings for the header of the spells container, label is a localized string, name is a string used to save the column settings, key is the key used to get the value from the spell table, width is the width of the column, align is the alignment of the text, enabled is if the column is enabled, canSort is if the column can be sorted, sortKey is the key used to sort the column, dataType is the type of data the column is sorting, order is the order of the sorting, offset is the offset of the column
---@type details_allinonewindow_headercolumndata[]
local columnData = {
	--the align seems to be bugged as the left is aligning in the center and center is on the left side
	{shownOnOptions = false, key = "icon", name = "icon", width = 22, text = "", align = "left", enabled = true, offset = columnOffset, attribute = 1, subAttribute = 1},
	{shownOnOptions = false, showText = true, key = "rank", name = "rank", text = "#", width = 16, align = "center", enabled = true, offset = 6, dataType = "number", attribute = 1, subAttribute = 1},
	{shownOnOptions = false, showText = true, key = "pname", name = "pname", text = "Name", width = 110, align = "left", enabled = true, offset = columnOffset, attribute = 1, subAttribute = 1},
	{shownOnOptions = true, showText = false, key = "dmg", name = "dmg", text = "Dmg", width = 50, align = "left", enabled = true, offset = columnOffset, attribute = 1, subAttribute = 1, canSort = true, selected = true, icon = Details.menuIcons[1], texcoord = {p*(1-1), p*(1), 0, 1}},
	{shownOnOptions = true, showText = false, key = "dps", name = "dps", text = "Dps", width = 50, align = "left", enabled = true, offset = columnOffset, attribute = 1, subAttribute = 1, canSort = true, selected = true, icon = Details.menuIcons[1], texcoord = {p*(2-1), p*(2), 0, 1}}, --dps
    {shownOnOptions = true, showText = true, key = "dmgdps", name = "dmgdps", text = "Dmg/Dps", width = 70, align = "left", enabled = true, offset = columnOffset, attribute = 1, subAttribute = 1, canSort = true, icon = Details.menuIcons[1], texcoord = {p*(1-1), p*(1), 0, 1}},
    {shownOnOptions = true, showText = true, key = "dmgdpspercent", name = "dmgdpspercent", text = "Dmg/Dps/%", width = 90, align = "left", enabled = true, offset = columnOffset, attribute = 1, subAttribute = 1, canSort = true, icon = Details.menuIcons[1], texcoord = {p*(1-1), p*(1), 0, 1}},
    {shownOnOptions = true, showText = false, key = "heal", name = "heal", text = "Heal", width = 50, align = "left", enabled = true, offset = columnOffset, attribute = 2, subAttribute = 1, canSort = true, icon = Details.menuIcons[2], texcoord = {p*(1-1), p*(1), 0, 1}},
    {shownOnOptions = true, showText = false, key = "hps", name = "hps", text = "Hps", width = 50, align = "left", enabled = true, offset = columnOffset, attribute = 2, subAttribute = 1, canSort = true, icon = Details.menuIcons[2], texcoord = {p*(2-1), p*(2), 0, 1}}, --hps
    {shownOnOptions = true, showText = false, key = "overheal", name = "overheal", text = "Overheal", width = 50, align = "left", enabled = true, offset = columnOffset, attribute = 2, subAttribute = 3, canSort = true, icon = Details.menuIcons[2], texcoord = {p*(3-1), p*(3), 0, 1}}, --overheal
    {shownOnOptions = true, showText = true, key = "healhps", name = "healhps", text = "Heal/Hps", width = 70, align = "left", enabled = true, offset = columnOffset, attribute = 2, subAttribute = 1, canSort = true, icon = Details.menuIcons[2], texcoord = {p*(1-1), p*(1), 0, 1}},
    {shownOnOptions = true, showText = true, key = "healhpspercent", name = "healhpspercent", text = "Heal/Hps/%", width = 90, align = "left", enabled = true, offset = columnOffset, attribute = 2, subAttribute = 1, canSort = true, icon = Details.menuIcons[2], texcoord = {p*(1-1), p*(1), 0, 1}},
    {shownOnOptions = true, showText = false, key = "death", name = "death", text = "Death", width = 60, align = "left", enabled = true, offset = columnOffset, attribute = 4, subAttribute = 5, canSort = true, icon = Details.menuIcons[4], texcoord = {p*(5-1), p*(5), 0, 1}}, --5 is the subattribute index
    {shownOnOptions = true, showText = false, key = "interrupt", name = "interrupt", text = "Interrupt", width = 60, align = "left", enabled = true, offset = columnOffset, attribute = 4, subAttribute = 3, canSort = true, icon = Details.menuIcons[4], texcoord = {p*(3-1), p*(3), 0, 1}}, --3 is the subattribute index
    {shownOnOptions = true, showText = false, key = "dispel", name = "dispel", text = "Dispel", width = 60, align = "left", enabled = true, offset = columnOffset, attribute = 4, subAttribute = 4, canSort = true, icon = Details.menuIcons[4], texcoord = {p*(4-1), p*(4), 0, 1}}, --4 is the subattribute index
}

--this table connect the column key with the column index, the table has as hash the column key and as value the index in the columnData table
AllInOneWindow.HeaderColumnDataKeyToIndex = {}
for i, column in ipairs(columnData) do
    AllInOneWindow.HeaderColumnDataKeyToIndex[column.key] = i
end

AllInOneWindow.HeaderColumnData = columnData

function AllInOneWindow:GetColumnData(key)
    local index = self.HeaderColumnDataKeyToIndex[key]
    return self.HeaderColumnData[index]
end