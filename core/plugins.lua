
	local Loc = LibStub("AceLocale-3.0"):GetLocale( "Details" )
	local Details = _G.Details
	local PixelUtil = PixelUtil or DFPixelUtil
	local addonName, Details222 = ...
	local CreateFrame = CreateFrame

	---@type detailsframework
	local detailsFramework = DetailsFramework
	local UIParent = UIParent
	local UISpecialFrames = UISpecialFrames
	local breakdownWindowFrame = Details.BreakdownWindowFrame

	DETAILSPLUGIN_ALWAYSENABLED = 0x1 --[[GLOBAL]]

	local CONST_PLUGINWINDOW_MENU_WIDTH = 150
	local CONST_PLUGINWINDOW_MENU_HEIGHT = 22
	local CONST_PLUGINWINDOW_MENU_X = -5
	local CONST_PLUGINWINDOW_MENU_Y = -26
	local CONST_PLUGINWINDOW_WIDTH = 925
	local CONST_PLUGINWINDOW_HEIGHT = 600

	---default cooltip appearance for plugin tooltips
	function Details:SetCooltipForPlugins()
		local gameCooltip = GameCooltip
        gameCooltip:Preset(2)
		gameCooltip:SetOption("TextSize", Details.font_sizes.menus)
		gameCooltip:SetOption("TextFont", Details.font_faces.menus)
		gameCooltip:SetOption("LineHeightSizeOffset", 0)
		gameCooltip:SetOption("LineYOffset", 0)
		gameCooltip:SetOption("LinePadding", -1)
		gameCooltip:SetOption("FrameHeightSizeOffset", 0)
		gameCooltip:SetOption("FixedWidth", 280)
		gameCooltip:SetOption("StatusBarTexture", [[Interface\AddOns\Details\images\bar_serenity]])
		gameCooltip:SetOption("LeftTextWidth", 280 - 22 - 90)
		gameCooltip:SetOption("LeftTextHeight", 14)
		Details:SetTooltipMinWidth()
	end


	---comment
	---@param pluginAbsoluteName string
	---@return unknown
	function Details:GetPlugin(pluginAbsoluteName)
		return Details.SoloTables.NameTable[pluginAbsoluteName] or Details.RaidTables.NameTable[pluginAbsoluteName] or Details.ToolBar.NameTable[pluginAbsoluteName] or Details.StatusBar.NameTable[pluginAbsoluteName] or Details.PluginsLocalizedNames[pluginAbsoluteName] or Details.PluginsGlobalNames[pluginAbsoluteName]
	end

	---comment
	---@param pluginAbsoluteName string
	---@return unknown
	function Details:GetPluginSavedTable(pluginAbsoluteName)
		return Details.plugin_database[pluginAbsoluteName]
	end

	---comment
	function Details:UpdatePluginBarsConfig()
		---@type instance
		local instanceObject = self:GetPluginInstance()
		if (instanceObject) then
			self.row_info = self.row_info or {}
			Details.table.copy(self.row_info, instanceObject.row_info)
			self.bars_grow_direction = instanceObject.bars_grow_direction
			self.row_height = instanceObject.row_height
			self:SetBarGrowDirection()
		end
	end

	function Details:AttachToInstance()
		---@type instance
		local instanceObject = self:GetPluginInstance()
		if (instanceObject) then
			local width, height = instanceObject:GetSize()
			self.Frame:SetSize(width, height)
		end
	end

	---comment
	---@param pluginAbsoluteName string|nil
	---@return any
	function Details:GetPluginInstance(pluginAbsoluteName)
		local plugin = self
		if (pluginAbsoluteName) then
			plugin = Details:GetPlugin(pluginAbsoluteName)
		end

		local id = plugin.instance_id
		if (id) then
			return Details:GetInstance(id)
		end
	end

	function Details:IsPluginEnabled(pluginAbsoluteName)
		if (pluginAbsoluteName) then
			local plugin = Details.plugin_database[pluginAbsoluteName]
			if (plugin) then
				return plugin.enabled
			end
		else
			return self.__enabled
		end
	end

	---comment
	---@param desc string
	function Details:SetPluginDescription(desc)
		self.__description = desc
	end

	---get the description of a plugin
	---@return string
	function Details:GetPluginDescription()
		return self.__description or ""
	end

	---disable a plugin
	---@param pluginAbsoluteName string
	---@return boolean
	function Details:DisablePlugin(pluginAbsoluteName)
		local plugin = Details:GetPlugin(pluginAbsoluteName)

		if (plugin) then
			local savedTable = Details:GetPluginSavedTable(pluginAbsoluteName)
			savedTable.enabled = false
			plugin.__enabled = false

			Details:SendEvent("PLUGIN_DISABLED", plugin)
			Details:DelayOptionsRefresh()
			return true
		end

		return false
	end

	---check if the plugin saved table has all the default key and values
	---@param savedTable table
	---@param defaultSavedTable table
	function Details:CheckDefaultTable(savedTable, defaultSavedTable)
		for key, value in pairs(defaultSavedTable) do
			if (type(value) == "table") then
				if (type(savedTable[key]) ~= "table") then
					savedTable[key] = Details.CopyTable(value)
				else
					Details:CheckDefaultTable(savedTable[key], value)
				end
			else
				if (savedTable[key] == nil) then
					savedTable[key] = value
				end
			end
		end
	end

	function Details:InstallPlugin(pluginType, pluginName, pluginIcon, pluginObject, pluginAbsoluteName, minVersion, authorName, version, defaultSavedTable)
		if (minVersion and minVersion > Details.realversion) then
			print(pluginName, Loc["STRING_TOOOLD"])
			return Details:NewError("Details version is out of date.")
		end

		if (pluginType == "TANK") then
			pluginType = "RAID"
		end

		if (not pluginType) then
			return Details:NewError("InstallPlugin parameter 1 (plugin type) not especified")
		elseif (not pluginName) then
			return Details:NewError("InstallPlugin parameter 2 (plugin name) can't be nil")
		elseif (not pluginIcon) then
			return Details:NewError("InstallPlugin parameter 3 (plugin icon) can't be nil")
		elseif (not pluginObject) then
			return Details:NewError("InstallPlugin parameter 4 (plugin object) can't be nil")
		elseif (not pluginAbsoluteName) then
			return Details:NewError("InstallPlugin parameter 5 (plugin absolut name) can't be nil")
		end

		if (_G[pluginAbsoluteName]) then
			print(Loc["STRING_PLUGIN_NAMEALREADYTAKEN"] .. ": " .. pluginName .. " name: " .. pluginAbsoluteName)
			return
		else
			_G[pluginAbsoluteName] = pluginObject
			pluginObject.real_name = pluginAbsoluteName
		end

		pluginObject.__name = pluginName
		pluginObject.__author = authorName or "--------"
		pluginObject.__version = version or "v1.0.0"
		pluginObject.__icon = pluginIcon or[[Interface\ICONS\Trade_Engineering]]
		pluginObject.real_name = pluginAbsoluteName

		Details.PluginsGlobalNames[pluginAbsoluteName] = pluginObject
		Details.PluginsLocalizedNames[pluginName] = pluginObject

		local savedTable

		if (pluginType ~= "STATUSBAR") then
			savedTable = Details.plugin_database[pluginAbsoluteName]

			if (not savedTable) then
				savedTable = {enabled = true, author = authorName or "--------"}
				Details.plugin_database[pluginAbsoluteName] = savedTable
			end

			if (defaultSavedTable) then
				Details:CheckDefaultTable(savedTable, defaultSavedTable)
			end

			pluginObject.__enabled = savedTable.enabled
		end

		if (pluginType == "SOLO") then
			if (not pluginObject.Frame) then
				return Details:NewError("plugin doesn't have a Frame, please check case-sensitive member name: Frame")
			end

			Details.SoloTables.Plugins[#Details.SoloTables.Plugins+1] = pluginObject
			Details.SoloTables.Menu[#Details.SoloTables.Menu+1] = {pluginName, pluginIcon, pluginObject, pluginAbsoluteName}
			Details.SoloTables.NameTable[pluginAbsoluteName] = pluginObject
			Details:SendEvent("INSTALL_OKEY", pluginObject)
			Details.PluginCount.SOLO = Details.PluginCount.SOLO + 1

		elseif (pluginType == "RAID") then
			Details.RaidTables.Plugins[#Details.RaidTables.Plugins+1] = pluginObject
			Details.RaidTables.Menu[#Details.RaidTables.Menu+1] = {pluginName, pluginIcon, pluginObject, pluginAbsoluteName}
			Details.RaidTables.NameTable[pluginAbsoluteName] = pluginObject
			Details:SendEvent("INSTALL_OKEY", pluginObject)
			Details.PluginCount.RAID = Details.PluginCount.RAID + 1
			Details:InstanceCall("RaidPluginInstalled", pluginAbsoluteName)

		elseif (pluginType == "TOOLBAR") then
			Details.ToolBar.Plugins[#Details.ToolBar.Plugins+1] = pluginObject
			Details.ToolBar.Menu[#Details.ToolBar.Menu+1] = {pluginName, pluginIcon, pluginObject, pluginAbsoluteName}
			Details.ToolBar.NameTable[pluginAbsoluteName] = pluginObject
			Details:SendEvent("INSTALL_OKEY", pluginObject)
			Details.PluginCount.TOOLBAR = Details.PluginCount.TOOLBAR + 1

		elseif (pluginType == "STATUSBAR") then
			Details.StatusBar.Plugins[#Details.StatusBar.Plugins+1] = pluginObject
			Details.StatusBar.Menu[#Details.StatusBar.Menu+1] = {pluginName, pluginIcon}
			Details.StatusBar.NameTable[pluginAbsoluteName] = pluginObject
			Details:SendEvent("INSTALL_OKEY", pluginObject)
			Details.PluginCount.STATUSBAR = Details.PluginCount.STATUSBAR + 1
		end

		if (savedTable) then
			pluginObject.db = savedTable
		end

		if (pluginObject.__enabled) then
			return true, savedTable, true
		else
			return true, savedTable, false
		end
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--internal functions

	---@type table<plugintype, number>
	Details.PluginCount = {
		["SOLO"] = 0,
		["RAID"] = 0,
		["TOOLBAR"] = 0,
		["STATUSBAR"] = 0
	}

	local onEnableFunction = function(self)
		self.__parent.Enabled = true
		---@type instance
		local instanceObject = Details:GetInstance(self.__parent.instance_id)
		if (instanceObject) then
			self:SetParent(instanceObject.baseframe)
		end
		Details:SendEvent("SHOW", self.__parent)
	end

	local onDisableFunction = function(self)
		Details:SendEvent("HIDE", self.__parent)
		if (bit.band(self.__parent.__options, DETAILSPLUGIN_ALWAYSENABLED) == 0) then
			self.__parent.Enabled = false
		end
	end

	local buildDefaultStatusBarMembers = function(self)
		self.childs = {}
		self.__index = self
		function self:Setup()
			Details.StatusBar:OpenOptionsForChild(self)
		end
	end

	local temp_event_function = function()
		print("=====================")
		print("Hello There plugin developer!")
		print("Please make sure you are declaring")
		print("A member called 'OnDetailsEvent' on your plugin object")
		print("With a function to receive the events like bellow:")
		print("function PluginObject:OnDetailsEvent(event, ...) end")
		print("Thank You Sir!===================")
	end

	local registerEventFunc = function(self, event)
		self.Frame:RegisterEvent(event)
	end

	local unregisterEventFunc = function(self, event)
		self.Frame:UnregisterEvent(event)
	end

	---@param frameName string
	---@param pluginFlag number
	---@param pluginType plugintype
	function Details:NewPluginObject(frameName, pluginFlag, pluginType)
		pluginFlag = pluginFlag or 0x0
		local newPluginObject = {__options = pluginFlag, __enabled = true, RegisterEvent = registerEventFunc, UnregisterEvent = unregisterEventFunc}

		local pluginFrame = CreateFrame("Frame", frameName, UIParent, "BackdropTemplate")
		pluginFrame:RegisterEvent("PLAYER_LOGIN")
		pluginFrame:RegisterEvent("PLAYER_LOGOUT")
		pluginFrame:SetFrameStrata("HIGH")
		pluginFrame:SetFrameLevel(6)
		pluginFrame:Hide()
		pluginFrame:SetScript("OnShow", onEnableFunction)
		pluginFrame:SetScript("OnHide", onDisableFunction)
		pluginFrame.__parent = newPluginObject

		pluginFrame:SetScript("OnEvent", function(self, event, ...)
			if (newPluginObject.OnEvent) then
				if (event == "PLAYER_LOGIN") then
					newPluginObject:OnEvent(self, "ADDON_LOADED", newPluginObject.Frame:GetName())
					newPluginObject.Frame:Hide()
					return
				end
				return newPluginObject:OnEvent(self, event, ...)
			end
		end)

		if (bit.band(pluginFlag, DETAILSPLUGIN_ALWAYSENABLED) ~= 0) then
			newPluginObject.Enabled = true
		else
			newPluginObject.Enabled = false
		end

		--default members
		if (pluginType == "STATUSBAR") then
			buildDefaultStatusBarMembers(newPluginObject)
		end

		newPluginObject.Frame = pluginFrame
		newPluginObject.OnDetailsEvent = temp_event_function
		setmetatable(newPluginObject, Details)

		return newPluginObject
	end

	---create a window for plugin options
	---@param name string
	---@param title string
	---@param template number? @1 = standard backdrop, @2 = buttonframe, @3 = rounded corners
	---@param pluginIcon string?
	---@param pluginIconCoords table?
	function Details:CreatePluginOptionsFrame(name, title, template,  pluginIcon, pluginIconCoords)
		template = template or 3

		if (template == 3) then
			local optionsFrame = CreateFrame("frame", name, UIParent)
			table.insert(UISpecialFrames, name)
			optionsFrame:SetSize(500, 200)
			optionsFrame:SetMovable(true)
			optionsFrame:EnableMouse(true)
			optionsFrame:SetFrameStrata("DIALOG")
			optionsFrame:SetToplevel(true)
			optionsFrame:SetPoint("center", UIParent, "center")
			optionsFrame:Hide()

			detailsFramework:AddRoundedCornersToFrame(optionsFrame, Details.PlayerBreakdown.RoundedCornerPreset)
			Details:RegisterFrameToColor(optionsFrame)

			--create a an icon to display the pluginIcon
			local pluginIconTexture = detailsFramework:CreateTexture(optionsFrame, pluginIcon, 20, 20, "artwork", pluginIconCoords or {0, 1, 0, 1}, "pluginIconTexture", "$parentPluginIconTexture")
			pluginIconTexture:SetPoint("topleft", optionsFrame, "topleft", 5, -5)
			if (not pluginIcon) then
				pluginIconTexture:SetSize(1, 20)
			end

			--create a font string in the topleft corner for plugin name
			local pluginNameLabel = detailsFramework:CreateLabel(optionsFrame, title, 20, "yellow")
			pluginNameLabel:SetPoint("left", pluginIconTexture, "right", 2, 0)

			--create a close button at the right top corner
			local closeButton = detailsFramework:CreateCloseButton(optionsFrame)
			closeButton:SetPoint("topright", optionsFrame, "topright", -5, -5)

			local bigDogTexture = detailsFramework:CreateTexture(optionsFrame, [[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]], 110, 120, nil, {1, 0, 0, 1}, "backgroundBigDog", "$parentBackgroundBigDog")
			bigDogTexture:SetPoint("bottomright", optionsFrame, "bottomright", -3, 0)
			bigDogTexture:SetAlpha(.25)

			optionsFrame:SetScript("OnMouseDown", function(self, button)
				if (button == "RightButton") then
					if (self.moving) then
						self.moving = false
						self:StopMovingOrSizing()
					end
					return optionsFrame:Hide()
				elseif (button == "LeftButton" and not self.moving) then
					self.moving = true
					self:StartMoving()
				end
			end)

			optionsFrame:SetScript("OnMouseUp", function(self)
				if (self.moving) then
					self.moving = false
					self:StopMovingOrSizing()
				end
			end)

			return optionsFrame

		elseif (template == 2) then
			local optionsFrame = CreateFrame("frame", name, UIParent, "ButtonFrameTemplate, BackdropTemplate")
			table.insert(UISpecialFrames, name)
			optionsFrame:SetSize(500, 200)
			optionsFrame:SetMovable(true)
			optionsFrame:EnableMouse(true)
			optionsFrame:SetFrameStrata("DIALOG")
			optionsFrame:SetToplevel(true)
			optionsFrame:SetPoint("center", UIParent, "center")
			optionsFrame:Hide()

			optionsFrame:SetScript("OnMouseDown", function(self, button)
				if (button == "RightButton") then
					if (self.moving) then
						self.moving = false
						self:StopMovingOrSizing()
					end
					return optionsFrame:Hide()
				elseif (button == "LeftButton" and not self.moving) then
					self.moving = true
					self:StartMoving()
				end
			end)

			optionsFrame:SetScript("OnMouseUp", function(self)
				if (self.moving) then
					self.moving = false
					self:StopMovingOrSizing()
				end
			end)

			return optionsFrame

		elseif (template == 1) then
			local optionsFrame = CreateFrame("frame", name, UIParent, "BackdropTemplate")
			table.insert(UISpecialFrames, name)
			optionsFrame:SetSize(500, 200)
			optionsFrame:SetMovable(true)
			optionsFrame:EnableMouse(true)
			optionsFrame:SetFrameStrata("DIALOG")
			optionsFrame:SetToplevel(true)
			optionsFrame:SetPoint("center", UIParent, "center", 0, 0)
			optionsFrame:Hide()

			optionsFrame:SetScript("OnMouseDown", function(self, button)
				if (button == "RightButton") then
					if (self.moving) then
						self.moving = false
						self:StopMovingOrSizing()
					end
					return optionsFrame:Hide()
				elseif (button == "LeftButton" and not self.moving) then
					self.moving = true
					self:StartMoving()
				end
			end)

			optionsFrame:SetScript("OnMouseUp", function(self)
				if (self.moving) then
					self.moving = false
					self:StopMovingOrSizing()
				end
			end)

			optionsFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
			edgeFile = [[Interface\AddOns\Details\images\border_2]], edgeSize = 32,
			insets = {left = 1, right = 1, top = 1, bottom = 1}})
			optionsFrame:SetBackdropColor(0, 0, 0, .7)

			detailsFramework:ApplyStandardBackdrop(optionsFrame)
			detailsFramework:CreateTitleBar(optionsFrame, title)

			local bigDogTexture = detailsFramework:NewImage(optionsFrame, [[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]], 110, 120, nil, {1, 0, 0, 1}, "backgroundBigDog", "$parentBackgroundBigDog")
			bigDogTexture:SetPoint("bottomright", optionsFrame, "bottomright", -3, 0)
			bigDogTexture:SetAlpha(.25)

			return optionsFrame
		end
	end

	function Details:CreateRightClickToCloseLabel(parent)
		local mouseIcon = detailsFramework:CreateAtlasString(Details:GetTextureAtlas("right-mouse-click"), 12, 9)
		local rightClickToBackLabel = detailsFramework:CreateLabel(parent, mouseIcon .. " right click to close", "GameFontNormal")
		rightClickToBackLabel:SetAlpha(0.834)
		rightClickToBackLabel.textcolor = "gray"
		parent.RightClickLabel = rightClickToBackLabel
		return rightClickToBackLabel
	end

	function Details:CreatePluginWindowContainer()
		local pluginContainerFrame = CreateFrame("frame", "DetailsPluginContainerWindow", UIParent, "BackdropTemplate")
		pluginContainerFrame:EnableMouse(true)
		pluginContainerFrame:SetMovable(true)
		pluginContainerFrame:SetPoint("center", UIParent, "center", 0, 0)
		pluginContainerFrame:SetClampedToScreen(true)
		table.insert(UISpecialFrames, "DetailsPluginContainerWindow")

		pluginContainerFrame:Hide()

		--members
		pluginContainerFrame.MenuX = CONST_PLUGINWINDOW_MENU_X
		pluginContainerFrame.MenuY = CONST_PLUGINWINDOW_MENU_Y
		pluginContainerFrame.MenuButtonWidth = CONST_PLUGINWINDOW_MENU_WIDTH
		pluginContainerFrame.MenuButtonHeight = CONST_PLUGINWINDOW_MENU_HEIGHT
		pluginContainerFrame.FrameWidth = CONST_PLUGINWINDOW_WIDTH
		pluginContainerFrame.FrameHeight = CONST_PLUGINWINDOW_HEIGHT
		pluginContainerFrame.TitleHeight = 20

		--store button references for the left menu
		pluginContainerFrame.MenuButtons = {}
		--store all plugins embed
		pluginContainerFrame.EmbedPlugins = {}

		--lib window
		pluginContainerFrame:SetSize(pluginContainerFrame.FrameWidth, pluginContainerFrame.FrameHeight)
		local LibWindow = LibStub("LibWindow-1.1")
		LibWindow.RegisterConfig(pluginContainerFrame, Details.plugin_window_pos)
		LibWindow.RestorePosition(pluginContainerFrame)
		LibWindow.MakeDraggable(pluginContainerFrame)
		LibWindow.SavePosition(pluginContainerFrame)

		local scaleBar = DetailsFramework:CreateScaleBar(pluginContainerFrame, Details.options_window, true)
		scaleBar:SetFrameStrata("fullscreen")
		pluginContainerFrame:SetScale(Details.options_window.scale)
		pluginContainerFrame.scaleBar = scaleBar

		--left side bar menu
		local optionsLeftSideBarMenu = CreateFrame("frame", "$parentMenuFrame", pluginContainerFrame, "BackdropTemplate")
		detailsFramework:AddRoundedCornersToFrame(optionsLeftSideBarMenu, Details.PlayerBreakdown.RoundedCornerPreset)
		optionsLeftSideBarMenu:SetPoint("topright", pluginContainerFrame, "topleft", -2, 0)
		optionsLeftSideBarMenu:SetPoint("bottomright", pluginContainerFrame, "bottomleft", -2, 0)
		optionsLeftSideBarMenu:SetWidth(pluginContainerFrame.MenuButtonWidth + 6)
		pluginContainerFrame.optionsLeftSideBarMenu = optionsLeftSideBarMenu

		--statusbar
		local statusBar = CreateFrame("frame", nil, optionsLeftSideBarMenu, "BackdropTemplate")
		statusBar:SetPoint("bottomleft", pluginContainerFrame, "bottomleft", 7, 5)
		statusBar:SetPoint("bottomright", pluginContainerFrame, "bottomright", 0, 5)
		statusBar:SetHeight(16)
		statusBar:SetAlpha(1)

		DetailsFramework:BuildStatusbarAuthorInfo(statusBar)

		local rightClickToBackLabel = Details:CreateRightClickToCloseLabel(statusBar)
		rightClickToBackLabel:SetPoint("bottomright", statusBar, "bottomright", -150, 5)

		local bigDogTexture = detailsFramework:NewImage(optionsLeftSideBarMenu, [[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]], 180*0.7, 200*0.7, "overlay", {0, 1, 0, 1}, "backgroundBigDog", "$parentBackgroundBigDog")
		bigDogTexture:SetPoint("bottomleft", custom_window, "bottomleft", 0, 1)
		bigDogTexture:SetAlpha(0)

		local gradientBelowTheLine = DetailsFramework:CreateTexture(optionsLeftSideBarMenu, {gradient = "vertical", fromColor = {0, 0, 0, 0.45}, toColor = "transparent"}, 1, 95, "artwork", {0, 1, 0, 1}, "dogGradient")
		gradientBelowTheLine:SetPoint("bottoms")
		gradientBelowTheLine:Hide()

		local bigDogRowTexture = optionsLeftSideBarMenu:CreateTexture(nil, "artwork")
		bigDogRowTexture:SetPoint("bottomleft", optionsLeftSideBarMenu, "bottomleft", 1, 1)
		bigDogRowTexture:SetPoint("bottomright", optionsLeftSideBarMenu, "bottomright", -1, 1)
		bigDogRowTexture:SetHeight(20)
		bigDogRowTexture:SetColorTexture(.5, .5, .5, .1)
		bigDogRowTexture:Hide()

		--tools title bar
		local titleBarTools = CreateFrame("frame", "$parentToolsHeader", optionsLeftSideBarMenu, "BackdropTemplate")
		PixelUtil.SetPoint(titleBarTools, "topleft", optionsLeftSideBarMenu, "topleft", 2, -3)
		PixelUtil.SetPoint(titleBarTools, "topright", optionsLeftSideBarMenu, "topright", -2, -3)
		titleBarTools:SetHeight(pluginContainerFrame.TitleHeight)

		--tools title label
		local titleBarTools_TitleLabel = detailsFramework:NewLabel(titleBarTools, titleBarTools, nil, "titulo", "Tools", "GameFontHighlightLeft", 12, {227/255, 186/255, 4/255})
		PixelUtil.SetPoint(titleBarTools_TitleLabel, "center", titleBarTools , "center", 0, 0)
		PixelUtil.SetPoint(titleBarTools_TitleLabel, "top", titleBarTools , "top", 0, -5)

		--check if the window isn't out of screen
		pluginContainerFrame:SetScript("OnShow", function()
			C_Timer.After(1, function()
				local right = pluginContainerFrame:GetRight()
				if (right and right > GetScreenWidth() + 500) then
					pluginContainerFrame:ClearAllPoints()
					pluginContainerFrame:SetPoint("center", UIParent, "center", 0, 0)
					LibWindow.SavePosition(pluginContainerFrame)
					Details:Msg("detected options panel out of screen, position has reset")
				end

				local scaleFactor = pluginContainerFrame:GetScale()
				if (scaleFactor < 0.65) then
					pluginContainerFrame:SetScale(0.65)
					Details:Msg("detected options panel scale issue, scale has reset, please reload the UI")
				end
			end)
		end)

		pluginContainerFrame:SetScript("OnHide", function() end)

		pluginContainerFrame:SetScript("OnMouseDown", function(self, button)
			if (button == "RightButton") then
				pluginContainerFrame.ClosePlugin()
			end
		end)

		pluginContainerFrame.Debug = false
		function pluginContainerFrame.DebugMsg(...)
			if (pluginContainerFrame.Debug) then
				print("[Details! Debug]", ...)
			end
		end

		local getPluginObject = function(pluginAbsoluteName)
			local pluginObject = Details:GetPlugin(pluginAbsoluteName)
			if (not pluginObject) then
				for index, plugin in ipairs(pluginContainerFrame.EmbedPlugins) do
					if (plugin.real_name == pluginAbsoluteName) then
						pluginObject = plugin
					end
				end

				if (not pluginObject) then
					pluginContainerFrame.DebugMsg("Plugin not found")
					return
				end
			end
			return pluginObject
		end

		local hideOtherPluginFrames = function(pluginObject)
			local bIsShowingAPlugin = Details222.BreakdownWindow.IsPluginShown()
			local pluginShownInBreakdownWindow = breakdownWindowFrame.GetShownPluginObject()

			for index, thisPluginObject in ipairs(pluginContainerFrame.EmbedPlugins) do
				if (thisPluginObject ~= pluginObject) then
					if (thisPluginObject.__isUtility) then
						--hide this plugin
						if (thisPluginObject.Frame:IsShown()) then
							thisPluginObject.Frame:Hide()
						end
					else
						if (bIsShowingAPlugin) then
							if (pluginShownInBreakdownWindow == thisPluginObject) then
								--do nothing yet
							else
								--hide this plugin
								if (thisPluginObject.Frame:IsShown()) then
									thisPluginObject.Frame:Hide()
								end
							end
						else
							--hide this plugin
							if (thisPluginObject.Frame:IsShown()) then
								thisPluginObject.Frame:Hide()
							end
						end
					end
				end
			end
		end

		local highlightPluginButton = function(pluginAbsoluteName)
			for index, button in ipairs(pluginContainerFrame.MenuButtons) do
				button:Show()

				if (button.PluginAbsName == pluginAbsoluteName) then
					button:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGINPANEL_BUTTONSELECTED_TEMPLATE"))
				else
					button:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGINPANEL_BUTTON_TEMPLATE"))
				end
			end
		end

		function pluginContainerFrame.OnMenuClick(_, _, pluginAbsoluteName, callRefresh)
			local pluginObject = getPluginObject(pluginAbsoluteName)
			if (not pluginObject) then
				return
			end

			--hide other plugin windows
			hideOtherPluginFrames(pluginObject)

			--re set the point of the frame within the main plugin window
			pluginContainerFrame.RefreshFrame(pluginObject.__var_Frame)
			C_Timer.After(0, function()
				pluginContainerFrame.RefreshFrame(pluginObject.__var_Frame)
			end)

			--show the plugin window
			if (pluginObject.RefreshWindow and callRefresh) then
				DetailsFramework:QuickDispatch(pluginObject.RefreshWindow)
			end

			--highlight the plugin button on the menu
			highlightPluginButton(pluginAbsoluteName)

			--show the container
			pluginContainerFrame:Show()

			--check if the plugin has a callback for when showing the frame
			if (pluginObject.__OnClickFromOptionsCallback) then
				--safe run the plugin callback
				DetailsFramework:QuickDispatch(pluginObject.__OnClickFromOptionsCallback)
			end

			return true
		end

		---create a button fro the plugin be selected in the options panel
		---@param self details
		---@param pluginObject any
		---@param bIsUtility any
		---@param parent frame
		---@param onClickFunc function
		---@param width number
		---@param height number
		---@return button
		function Details:CreatePluginMenuButton(pluginObject, bIsUtility, parent, onClickFunc, width, height)
			local newButton = detailsFramework:CreateButton(parent, onClickFunc, width, height, pluginObject.__name, pluginObject.real_name, true)
			newButton.PluginAbsName = pluginObject.real_name
			newButton.PluginName = pluginObject.__name
			newButton.IsUtility = bIsUtility
			pluginObject.__isUtility = bIsUtility

			newButton:SetTemplate("STANDARD_GRAY")
			newButton:SetText(pluginObject.__name)
			newButton.textsize = 10
			newButton:SetIcon(pluginObject.__icon, nil, nil, nil, pluginObject.__iconcoords, pluginObject.__iconcolor, 4)

			return newButton
		end

		local onHide = function(self)
			DetailsPluginContainerWindow.ClosePlugin()
		end

		local setupFrameFunctions = function(frame)
			frame:SetScript("OnMouseDown", nil)
			frame:SetScript("OnMouseUp", nil)
			frame:HookScript("OnHide", onHide)
		end

		function pluginContainerFrame.RefreshFrame(frame, parent)
			frame:EnableMouse(false)
			frame:SetSize(pluginContainerFrame.FrameWidth, pluginContainerFrame.FrameHeight)
			frame:ClearAllPoints()
			PixelUtil.SetPoint(frame, "topleft", parent or pluginContainerFrame, "topleft", 0, 0)
			frame:SetParent(parent or pluginContainerFrame)
			frame:Show()
		end

		---a plugin has request to be embed into the main plugin window
		---@param pluginObject table can be the plugin object or any frame
		---@param frame frame any frame
		---@param bIsUtility boolean if true, the plugin is in fact a regular panel in the options panel
		---@param callback function a callback to run when the plugin is clicked
		function pluginContainerFrame.EmbedPlugin(pluginObject, frame, bIsUtility, callback)
			--check if the plugin has a frame
			if (not pluginObject.Frame) then
				pluginContainerFrame.DebugMsg("plugin doesn't have a frame.")
				return
			end

			--add it to menu table
			if (bIsUtility) then
				--create a button for this plugin
				local pluginButton = Details:CreatePluginMenuButton(pluginObject, bIsUtility, pluginContainerFrame, pluginContainerFrame.OnMenuClick, pluginContainerFrame.MenuButtonWidth, pluginContainerFrame.MenuButtonHeight)

				--only register button if it's a utility, plugins now are placed into the breakdown window
				table.insert(pluginContainerFrame.MenuButtons, pluginButton)

				pluginObject.__var_Frame = frame
				pluginObject.__var_Utility = true

				--sort buttons alphabetically, put utilities at the end
				table.sort(pluginContainerFrame.MenuButtons, function(t1, t2)
					if (t1.IsUtility and t2.IsUtility) then
						return t1.PluginName < t2.PluginName
					elseif (t1.IsUtility) then
						return false
					elseif (t2.IsUtility) then
						return true
					else
						return t1.PluginName < t2.PluginName
					end
				end)

				--reset the buttons points
				for index, button in ipairs(pluginContainerFrame.MenuButtons) do
					button:ClearAllPoints()
					PixelUtil.SetPoint(button, "center", optionsLeftSideBarMenu, "center", 0, 0)
					PixelUtil.SetPoint(button, "top", optionsLeftSideBarMenu, "top", 0, pluginContainerFrame.MenuY +((index-1) * -pluginContainerFrame.MenuButtonHeight ) - index)
					detailsFramework:SetTemplate(button, "STANDARD_GRAY")
				end

				--format the plugin main frame
				pluginContainerFrame.RefreshFrame(frame)
				setupFrameFunctions(frame)

				--save the callback function for when clicking in the button from the options panel
				pluginObject.__OnClickFromOptionsCallback = callback

				--add the plugin to embed table
				table.insert(pluginContainerFrame.EmbedPlugins, pluginObject)
				frame:SetParent(pluginContainerFrame)

				pluginContainerFrame.DebugMsg("plugin added", pluginObject.__name)
			end
		end

		function pluginContainerFrame.OpenPlugin(pluginObject)
			if (pluginObject.__breakdownwindow) then
				breakdownWindowFrame.ShowPluginOnBreakdown(pluginObject)
				return
			end

			--simulate a click on the menu button
			pluginContainerFrame.OnMenuClick(_, _, pluginObject.real_name)
		end

		---hide all embed plugins
		function pluginContainerFrame.ClosePlugin()
			for index, plugin in ipairs(pluginContainerFrame.EmbedPlugins) do
				plugin.Frame:Hide()
			end
			--hide the main frame
			pluginContainerFrame:Hide()
		end

		--[=[
			Function to be used on macros to open a plugin, signature:
			Details:OpenPlugin(PLUGIN_ABSOLUTE_NAME)
			Details:OpenPlugin(PluginObject)
			Details:OpenPlugin("Plugin Name")
			Example: /run Details:OpenPlugin("Time Line")
		--]=]

		---function used when the user uses the macro command /run Details:OpenPlugin("Plugin Name")
		---@param wildCard any
		---@return any
		function Details:OpenPlugin(wildCard)
			local originalName = wildCard

			if (type(wildCard) == "string") then
				--check if passed a plugin absolute name
				local pluginObject = Details:GetPlugin(wildCard)
				if (pluginObject) then
					if (pluginObject.__breakdownwindow) then
						breakdownWindowFrame.ShowPluginOnBreakdown(pluginObject)
						return
					end
					pluginContainerFrame.OpenPlugin(pluginObject)
					return true
				end

				--check if passed a plugin name, remove spaces and make it lower case
				wildCard = string.lower(wildCard)
				wildCard = wildCard:gsub("%s", "")

				for index, pluginInfoTable in ipairs(Details.ToolBar.Menu) do
					local pluginName = pluginInfoTable[1]
					pluginName = string.lower(pluginName)
					pluginName = pluginName:gsub("%s", "")

					if (pluginName ==  wildCard) then
						local pluginObject = pluginInfoTable[3]
						if (pluginObject.__breakdownwindow) then
							breakdownWindowFrame.ShowPluginOnBreakdown(pluginObject)
							return
						end
						pluginContainerFrame.OpenPlugin(pluginObject)
						return true
					end
				end

			--check if passed a plugin object
			elseif (type(wildCard) == "table") then
				if (wildCard.__name) then
					pluginContainerFrame.OpenPlugin(wildCard)
					return true
				end
			end

			Details:Msg("|cFFFF7700plugin not found|r:|cFFFFFF00",(originalName or wildCard), "|rcheck if it is enabled in the addons control panel.") --localize-me
		end
	end