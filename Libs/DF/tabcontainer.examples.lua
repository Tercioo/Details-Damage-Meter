--[=[
    tabcontainer.examples.lua
    Demonstrates usage of CreateTabContainer.
    All examples assume DetailsFramework is loaded as DF.
--]=]

---@type detailsframework
local DF = _G["DetailsFramework"]

-------------------------------------------------
-- Example 1: Basic Tab Container
-------------------------------------------------
-- Creates a tab container with three tabs.
-- Each tab gets a label as placeholder content.

local function Example_BasicTabContainer(parent)
    local tabList = {
        {name = "GeneralSettings", text = "General"},
        {name = "DisplaySettings", text = "Display"},
        {name = "AboutTab", text = "About"},
    }

    local options = {
        width = 700,
        height = 400,
        button_width = 140,
        button_height = 20,
        button_text_size = 11,
    }

    local tabContainer = DF:CreateTabContainer(parent, "My AddOn Options", "MyAddOnTabContainer", tabList, options)
    tabContainer:SetPoint("center", UIParent, "center", 0, 0)

    -- Add content to each tab frame
    local generalFrame = tabContainer:GetTabFrameByIndex(1)
    local generalLabel = DF:CreateLabel(generalFrame, "General settings go here", 14, "white")
    generalLabel:SetPoint("topleft", generalFrame, "topleft", 20, -80)

    local displayFrame = tabContainer:GetTabFrameByName("DisplaySettings") -- lookup by name
    local displayLabel = DF:CreateLabel(displayFrame, "Display settings go here", 14, "white")
    displayLabel:SetPoint("topleft", displayFrame, "topleft", 20, -80)

    local aboutFrame = tabContainer:GetTabFrameByName("About") -- lookup by text
    local aboutLabel = DF:CreateLabel(aboutFrame, "About this addon", 14, "white")
    aboutLabel:SetPoint("topleft", aboutFrame, "topleft", 20, -80)

    tabContainer:Show()
    return tabContainer
end

-------------------------------------------------
-- Example 2: Tab Switching
-------------------------------------------------
-- Shows how to programmatically switch tabs
-- and how to use the OnSelectIndex hook.

local function Example_TabSwitching(parent)
    local tabList = {
        {name = "Tab1", text = "First Tab"},
        {name = "Tab2", text = "Second Tab"},
        {name = "Tab3", text = "Third Tab"},
    }

    -- Hook fires every time a tab is selected
    local hookList = {
        OnSelectIndex = function(tabContainer, tabButton)
            print("Tab switched to index:", tabContainer.CurrentIndex)
        end,
    }

    local tabContainer = DF:CreateTabContainer(parent, "Tab Switching Demo", "TabSwitchDemo", tabList, {}, hookList)
    tabContainer:SetPoint("center", UIParent, "center", 0, 0)

    -- Switch to the second tab by index
    tabContainer:SelectTabByIndex(2)

    -- Switch to the third tab by its text
    tabContainer:SelectTabByName("Third Tab")

    -- Switch to the first tab by its name
    tabContainer:SelectTabByName("Tab1")

    -- Set which tab will open next time the container is shown, without switching now
    tabContainer:SetIndex(2)
    -- Next time tabContainer:Show() is called, tab 2 will be selected

    -- Read the current tab index
    local currentTab = tabContainer.CurrentIndex

    tabContainer:Show()
    return tabContainer
end

-------------------------------------------------
-- Example 3: Lazy (On-Demand) Tabs
-------------------------------------------------
-- Uses createOnDemandFunc to defer expensive tab
-- creation until the user clicks that tab.

local function Example_LazyTabs(parent)
    local tabList = {
        {name = "MainTab", text = "Main"},

        -- This tab's content is only built when first shown
        {name = "HeavyTab", text = "Heavy Content", createOnDemandFunc = function(tabFrame, tabContainer, parentFrame)
            -- This function runs exactly once, the first time the tab is shown
            local label = DF:CreateLabel(tabFrame, "This content was loaded on demand!", 14, "white")
            label:SetPoint("center", tabFrame, "center", 0, 0)

            -- You can create scrollboxes, sliders, checkboxes, etc. here
            -- They will persist after the function finishes
        end},

        -- Another on-demand tab
        {name = "RareTab", text = "Rarely Used", createOnDemandFunc = function(tabFrame, tabContainer, parentFrame)
            local label = DF:CreateLabel(tabFrame, "Rarely visited tab", 14, "white")
            label:SetPoint("center", tabFrame, "center", 0, 0)
        end},
    }

    local tabContainer = DF:CreateTabContainer(parent, "Lazy Tabs Demo", "LazyTabsDemo", tabList)
    tabContainer:SetPoint("center", UIParent, "center", 0, 0)
    tabContainer:Show()
    return tabContainer
end

-------------------------------------------------
-- Example 4: Styled Tab Container
-------------------------------------------------
-- Customizes the backdrop of all tab frames
-- and uses button border colors to highlight the active tab.

local function Example_StyledTabs(parent)
    local tabList = {
        {name = "Alpha", text = "Alpha"},
        {name = "Beta", text = "Beta"},
    }

    local options = {
        width = 600,
        height = 350,
        button_width = 120,
        button_selected_border_color = {1, 0.8, 0, 1},   -- gold border on active
        button_border_color = {0.3, 0.3, 0.3, 1},         -- gray border on inactive
        hide_click_label = true,                           -- hide "right click to close" text
        can_move_parent = false,                           -- disable drag-to-move
    }

    local tabContainer = DF:CreateTabContainer(parent, "Styled Demo", "StyledTabsDemo", tabList, options)
    tabContainer:SetPoint("center", UIParent, "center", 0, 0)

    -- Apply a dark backdrop to all tab frames
    local backdrop = {
        edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1,
        bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true,
    }
    tabContainer:SetTabFramesBackdrop(backdrop, {0.1, 0.1, 0.1, 0.9}, {0, 0, 0, 1})

    -- Apply something to every tab frame
    tabContainer:CallOnEachTab(function(tabFrame)
        tabFrame:EnableMouse(true)
    end)

    tabContainer:Show()
    return tabContainer
end

-------------------------------------------------
-- Example 5: RefreshOptions on Tab Show
-------------------------------------------------
-- Demonstrates the RefreshOptions callback that
-- fires each time a tab is selected.

local function Example_RefreshOptions(parent)
    local tabList = {
        {name = "Settings", text = "Settings"},
        {name = "Preview", text = "Preview"},
    }

    local tabContainer = DF:CreateTabContainer(parent, "Refresh Demo", "RefreshDemo", tabList)
    tabContainer:SetPoint("center", UIParent, "center", 0, 0)

    -- Attach a RefreshOptions function to the Preview tab
    -- This runs every time the Preview tab is selected
    local previewFrame = tabContainer:GetTabFrameByName("Preview")
    previewFrame.RefreshOptions = function(self)
        print("Preview tab refreshed — update widgets here")
    end

    tabContainer:Show()
    return tabContainer
end
