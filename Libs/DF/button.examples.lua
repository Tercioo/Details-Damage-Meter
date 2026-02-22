---@type detailsframework
local DF = DetailsFramework

-- Parameters for CreateButton:
---@param self table the details framework object
---@param parent frame the parent frame of the button
---@param callback function the function to be called when the button is clicked
---@param width number the width of the button
---@param height number the height of the button
---@param text string the text to be displayed on the button, can be an empty string
---@param param1 any|nil the first parameter to be passed to the callback function when the button is clicked
---@param param2 any|nil the second parameter to be passed to the callback function when the button is clicked
---@param texture any|nil the texture to be used for the button, can be a number (texture ID) or a string (texture path)
---@param member string|nil the member name of the button in the parent, if provided parent[member] is equal to the button created
---@param name string|nil the name of the button
---@param shortMethod boolean|nil auto adjust the button size to fit the text, options: false: no nothing, nil: ajust the width of the button to fit the text, 1: shrink the text to fit the button
---@param buttonTemplate table|nil the template to be used for the button: "OPTIONS_BUTTON_TEMPLATE", "OPTIONS_CIRCLEBUTTON_TEMPLATE", "OPTIONS_BUTTON_GOLDENBORDER_TEMPLATE", "STANDARD_GRAY", "OPAQUE_DARK"
---@param textTemplate table|nil the template to be used for the button text "ORANGE_FONT_TEMPLATE", "OPTIONS_FONT_TEMPLATE", "SMALL_SILVER"

-- When a button is clicked, its callback function is called with the arguments:
---@param self button this is the button object from the game client.
---@param mouseButton string the mouse button that was clicked, can be "LeftButton", "RightButton", "MiddleButton", "Button4", "Button5"
---@param param1 any|nil the first parameter passed when creating the button or when calling button:SetParameters(param1, param2)
---@param param2 any|nil the second parameter passed when creating the button or when calling button:SetParameters(param1, param2)

--1º example: a simple button created with only one line:
local button = DF:CreateButton(UIParent, function() print("You clicked the button!") end, 20, 20, "Click-Me")

--2º example: a button with a texture and two parameters passed to the callback function:
local callback = function(self, mouseButton, param1, param2) print("You clicked the button with the mouse button: ", mouseButton, " Param1: ", param1, " Param2: ", param2) end
local button = DF:CreateButton(UIParent, callback, 20, 20, "Click-Me", "First", "Second")

--3º example: use the callback function to change a a table, change the button icon with the SetIcon method
local t = {orange = "orange", apple = "red", grape = "purple"}
local removeButton = DF:CreateButton(UIParent, function(self, mouseButton, fruit) t[fruit] = nil end, 20, 20, "Remove Apple", "apple")
removeButton:SetIcon("common-search-clearbutton", 12, 12, "OVERLAY")
removeButton.icon:SetAlpha(0.4) --when an icon is set, it can be accessed with button.icon

--4º example: a button with a template and auto adjust the width to fit the text
local clear_filter_func = function(self, mouseButton, param1, param2) print("Apply filter with param1: ", param1, " and param2: ", param2) end
local shortMethod = nil
local clearFilterButton =  DF:CreateButton(UIParent, clear_filter_func, 6, 20, "X", false, nil, nil, "button_clear_sync", nil, shortMethod, DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"), DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"))
local new_clear_filter_func = function(self, mouseButton, param1, param2) print("New function applied to the button with param1: ", param1, " and param2: ", param2) end

---text functions
clearFilterButton:SetText("CLEAR") --changing the text alone, the button width will be ajusted to fit the new text because shortMethod is nil
clearFilterButton:SetTextColor(1, 0, 0, 1) --changing the text color to red
clearFilterButton:SetFontSize(14)
clearFilterButton:SetFontFace([[Fonts\FRIZQT__.TTF]])
clearFilterButton:SetTexture([[Interface\Tooltips\UI-Tooltip-Background]], [[Interface\Tooltips\UI-Tooltip-Background]], [[Interface\Tooltips\UI-Tooltip-Background]], [[Interface\Tooltips\UI-Tooltip-Background]])

local iconTexture = clearFilterButton:GetIconTexture()
clearFilterButton:SetIconFilterMode("TRILINEAR")
---set a template to the button, this will change the button appearance and can also change the button size if the template has a fixed size, when using a template the button will use the template as base and then apply any other setting on top of it, so you can use this method to change the button appearance and still keep the text, icon, click function and parameters you set before
clearFilterButton:SetTemplate(DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))

---enable the button
clearFilterButton:Enable()
---disable the button
clearFilterButton:Disable()
---check if the button is enabled
local isEnabled = clearFilterButton:IsEnabled()
---set the button enabled or disabled
clearFilterButton:SetEnabled(true)

---simulate a click on the button, this will call the callback function with the parameters set
clearFilterButton:SetClickFunction(new_clear_filter_func, true, true) --parameters on this function is optional
clearFilterButton:SetParameters(false, false) --changing the parameters alone
clearFilterButton:Exec()
clearFilterButton:Click()
clearFilterButton:RightClick()

---debugging why the button isn't shown
local button = DF:CreateButton(UIParent, function() print("You clicked the button!") end, 20, 20, "Click-Me")
---First check if the button is created and exists
if not button then
    print("Button was not created!")
    return
end
---Second: check if the button has a width and height greater than 0
local width, height = button:GetSize()
if width <= 0 or height <= 0 then
    print("Button has invalid size: ", width, height)
    return
end
---Third: check if the button is shown
if not button:IsShown() then
    print("Button is not shown!")
    return
end
---Fourth: check if the button has alpha bigger than 0
local alpha = button:GetAlpha()
if alpha <= 0 then
    print("Button has invalid alpha: ", alpha)
    return
end
---Fifth: check if the button is visible, this checks if the button is shown and all its parents are shown and have alpha bigger than 0
if not button:IsVisible() then
    print("Button is not visible!")
    return
end
---Sixth: check if the button has an anchor point set
local point, relativeTo, relativePoint, xOfs, yOfs = button:GetPoint()
if not point then
    print("Button has no anchor point set!")
    return
end