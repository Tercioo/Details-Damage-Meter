
local Details = Details
local addonName, Details222 = ...
---@type detailsframework
local detailsFramework = DetailsFramework
local _

---@type details_allinonewindow
local AllInOneWindow = Details222.AllInOneWindow

---@class details_allinonewindow_public
---@field OpenWindow fun(windowId: number) open a window by id
---@field CloseWindow fun(windowId: number) close a window by id

---@type details_allinonewindow_public
---@diagnostic disable-next-line: missing-fields
DetailsOne = {} --[[GLOBAL]]

--open a window by id
function DetailsOne.OpenWindow(windowId)
    AllInOneWindow:OpenWindow(windowId)
end

--close window by id
function DetailsOne.CloseWindow(windowId)
    AllInOneWindow:CloseWindow(windowId)
end