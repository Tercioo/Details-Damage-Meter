--[=[
    slider.examples.lua
    Demonstrates usage of CreateSlider, CreateSwitch, SetAsCheckBox, and CreateAdjustmentSlider.
    All examples assume DetailsFramework is loaded as DF.
--]=]

---@type detailsframework
local DF = _G["DetailsFramework"]

-------------------------------------------------
-- Example 1: Basic Slider
-------------------------------------------------
-- Creates a horizontal slider with range 1–100, step 1, default 50.
-- Prints the new value whenever the user drags or types a value.

local function Example_BasicSlider(parent)
    local slider = DF:CreateSlider(parent, 150, 20, 1, 100, 1, 50, false, nil, nil, "Volume:")
    slider:SetPoint("topleft", parent, "topleft", 10, -30)

    -- OnValueChanged receives (nativeSlider, fixedValue, newValue)
    slider.OnValueChanged = function(self, fixedValue, value)
        print("Slider value:", value)
    end

    -- FixedParameter is passed as the second argument to OnValueChanged
    slider:SetFixedParameter("volume_setting")

    return slider
end

-------------------------------------------------
-- Example 2: Decimal Slider
-------------------------------------------------
-- Creates a slider for opacity (0.0 to 1.0) with decimal precision.
-- Uses SetValueNoCallback to initialize without triggering the callback.

local function Example_DecimalSlider(parent)
    local slider = DF:CreateSlider(parent, 120, 14, 0.0, 1.0, 0.01, 0.8, true, nil, nil, "Opacity:")
    slider:SetPoint("topleft", parent, "topleft", 10, -70)

    slider.OnValueChanged = function(self, fixedValue, value)
        parent:SetAlpha(value)
    end

    -- Change value without triggering the callback
    slider:SetValueNoCallback(0.5)

    return slider
end

-------------------------------------------------
-- Example 3: Switch (Toggle Button)
-------------------------------------------------
-- Creates a toggle switch with ON/OFF states.
-- The callback fires when the user clicks to toggle.

local function Example_Switch(parent)
    local isEnabled = false

    local onSwitch = function(self, fixedValue, value)
        -- value is true (ON) or false (OFF)
        isEnabled = value
        print("Switch toggled:", value)
    end

    local switch = DF:CreateSwitch(parent, onSwitch, isEnabled, 60, 20, "OFF", "ON")
    switch:SetPoint("topleft", parent, "topleft", 10, -110)

    -- Read current state
    local currentValue = switch:GetValue()

    -- Programmatically set without triggering the callback
    switch:SetValue(true)

    -- Programmatically set AND trigger the callback
    switch:SetValue(false, "RUN_CALLBACK")

    return switch
end

-------------------------------------------------
-- Example 4: Switch as Checkbox
-------------------------------------------------
-- Creates a switch, converts it to a checkbox with SetAsCheckBox().
-- Uses a template for visual styling and attaches a label.

local function Example_Checkbox(parent)
    local savedSetting = true

    local onToggle = function(self, fixedValue, value)
        savedSetting = value
        print("Checkbox:", value)
    end

    -- Create the switch with a template and a label
    local checkbox, label = DF:CreateSwitch(
        parent,
        onToggle,
        savedSetting,         -- default value
        18,                   -- width
        18,                   -- height
        nil, nil,             -- leftText, rightText (not used for checkbox)
        nil,                  -- member
        nil,                  -- name
        nil,                  -- colorInverted
        nil,                  -- switchFunc
        nil,                  -- returnFunc
        "Enable Feature",     -- withLabel (creates a df_label)
        DF:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"),
        DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
    )

    -- Convert the switch into a checkbox
    checkbox:SetAsCheckBox()
    checkbox:SetPoint("topleft", parent, "topleft", 10, -150)

    -- SetChecked / GetChecked are aliases for SetValue / GetValue on checkboxes
    checkbox:SetChecked(true)
    local checked = checkbox:GetChecked()

    return checkbox
end

-------------------------------------------------
-- Example 5: Adjustment Slider
-------------------------------------------------
-- Creates a joystick-style adjustment control.
-- Left/right clicks adjust by ±1 (literal).
-- Center-button drag reports normalized mouse movement.

local function Example_AdjustmentSlider(parent)
    local currentScale = 1.0

    -- callback(self, valueX, valueY, isLiteral, ...)
    local onAdjust = function(self, valueX, valueY, isLiteral, targetFrame)
        if (isLiteral) then
            -- Discrete click: valueX is -1 or +1
            currentScale = currentScale + (valueX * 0.05)
        else
            -- Continuous drag: valueX is normalized [-1, 1]
            currentScale = currentScale + (valueX * 0.02)
        end

        currentScale = math.max(0.5, math.min(2.0, currentScale))
        targetFrame:SetScale(currentScale)
    end

    local adjSlider = DF:CreateAdjustmentSlider(parent, onAdjust, {
        width = 70,
        height = 20,
        scale_factor = 1,
    }, nil, parent) -- 'parent' is passed as payload, received as 'targetFrame' in the callback

    adjSlider:SetPoint("topleft", parent, "topleft", 10, -190)

    -- Change the scale factor (multiplied into all values)
    adjSlider:SetScaleFactor(2)

    -- Replace the callback
    adjSlider:SetCallback(onAdjust)

    -- Disable / Enable
    adjSlider:Disable()
    adjSlider:Enable()

    return adjSlider
end
