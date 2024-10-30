
local Details = _G.Details
local Loc = _G.LibStub("AceLocale-3.0"):GetLocale ( "Details" )
local SharedMedia = _G.LibStub:GetLibrary("LibSharedMedia-3.0")
local UIParent = UIParent
local _
local addonName, Details222 = ...

--remove warnings in the code
local ipairs = ipairs
local tinsert = table.insert
local tremove = table.remove
local type = type
local unpack = _G.unpack
local PixelUtil = PixelUtil
local UISpecialFrames = UISpecialFrames
local CreateFrame = _G.CreateFrame
local detailsFramework = DetailsFramework
local breakdownWindowFrame = Details.BreakdownWindowFrame

---@type button[]
breakdownWindowFrame.RegisteredPluginButtons = {}
breakdownWindowFrame.RegisteredPlugins = {}

---register a plugin button to be shown in the breakdown window
---@param newPluginButton df_button
---@param newPluginAbsoluteName string
function breakdownWindowFrame.RegisterPluginButton(newPluginButton, newPluginObject, newPluginAbsoluteName)
	newPluginButton:SetParent(DetailsBreakdownLeftMenuPluginsFrame)

	newPluginButton.PluginObject = newPluginObject
	newPluginButton.PluginAbsoluteName = newPluginAbsoluteName
	newPluginButton.PluginFrame = newPluginObject.Frame

	newPluginButton:SetTemplate("STANDARD_GRAY")

	--get the fontstring for this especific button
	local fontString = _G[newPluginButton:GetName() .. "_Text"]
	detailsFramework:SetFontDefault(fontString)

	newPluginObject.__breakdownwindow = true

	local newClickFunction = function(UIObjectButton)
		--GetCapsule() returns the table which encapsulates the UIButton
		local button = UIObjectButton:GetCapsule()
		local pluginObject = button.PluginObject
		breakdownWindowFrame.ShowPluginOnBreakdown(pluginObject, button)
	end

	newPluginButton:SetScript("OnClick", newClickFunction)

	table.insert(breakdownWindowFrame.RegisteredPluginButtons, newPluginButton)
	table.insert(breakdownWindowFrame.RegisteredPlugins, newPluginObject)
end

function breakdownWindowFrame.ShowPluginOnBreakdown(pluginObject, button)
	--hide all frames
	for _, thisPluginObject in ipairs(breakdownWindowFrame.RegisteredPlugins) do
		thisPluginObject.Frame:Hide()
	end

	--check if the breakdown window is closed
	if (not breakdownWindowFrame:IsShown()) then
		--as the breakdown require an actor and an instance, get a random one
		local currentCombat = Details:GetCurrentCombat()
		local damageContainer = currentCombat:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)
		local actorObject = damageContainer._ActorTable[1]
		if (actorObject) then
			local instanceObject = Details:GetInstance(1)
			if (instanceObject) then
				local bFromAttributeChange = false
				local bIsRefresh = false
				local bIsShiftKeyDown = false
				local bIsControlKeyDown = false
				local bIgnoreOverrides = true
				Details:OpenBreakdownWindow(instanceObject, actorObject, bFromAttributeChange, bIsRefresh, bIsShiftKeyDown, bIsControlKeyDown, bIgnoreOverrides)
			end
		end
	end

	if (not breakdownWindowFrame:IsShown()) then
		return
	end

	--reset the template on all plugin buttons
	for _, thisPluginButton in ipairs(breakdownWindowFrame.RegisteredPluginButtons) do
		---@cast thisPluginButton df_button
		thisPluginButton:SetTemplate(detailsFramework:GetTemplate("button", "STANDARD_GRAY")) --"DETAILS_PLUGINPANEL_BUTTON_TEMPLATE"
	end

	local pluginMainFrame = pluginObject.Frame

	--> sets the plugin main frame: pluginObject.Frame, as the frame to be shown in the breakdown window
	pluginMainFrame:EnableMouse(false)
	pluginMainFrame:SetSize(DetailsBreakdownWindow:GetSize())
	pluginMainFrame:ClearAllPoints()
	PixelUtil.SetPoint(pluginMainFrame, "topleft", DetailsBreakdownWindow, "topleft", 0, 0)
	pluginMainFrame:SetParent(DetailsBreakdownWindow)
	pluginMainFrame:Show()

	--> this click is what selects the plugin tab within the plugin code
	--may this be confused as we set OnClick right below, but the :Click() from framework buttons are different than the Blizzard ones
	if (button) then
		button:Click()
		button:SetTemplate(detailsFramework:GetTemplate("button", "DETAILS_PLUGINPANEL_BUTTONSELECTED_TEMPLATE"))
	end

	--> hide the current shown tab in the breakdown window
	Details222.BreakdownWindow.OnShowPluginFrame(pluginObject)
end

local PLAYER_DETAILS_WINDOW_WIDTH = 925
local PLAYER_DETAILS_WINDOW_HEIGHT = 620
local PLAYER_DETAILS_STATUSBAR_HEIGHT = 20
local PLAYER_DETAILS_STATUSBAR_ALPHA = 1

Details222.BreakdownWindow.width = PLAYER_DETAILS_WINDOW_WIDTH
Details222.BreakdownWindow.height = PLAYER_DETAILS_WINDOW_HEIGHT

---@type button[]
Details.player_details_tabs = {}
---@type button[]
breakdownWindowFrame.currentTabsInUse =  {}

Details222.BreakdownWindow.BackdropSettings = {
	backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
	backdropcolor = {DetailsFramework:GetDefaultBackdropColor()},
	backdropbordercolor = {0, 0, 0, 0.7},
}

--create a base frame which will hold the scrollbox and plugin buttons
local breakdownSideMenu = CreateFrame("frame", "DetailsBreakdownLeftMenuFrame", breakdownWindowFrame, "BackdropTemplate")
breakdownWindowFrame.BreakdownSideMenuFrame = breakdownSideMenu

--create a frame to hold plugin buttons
local pluginsFrame = CreateFrame("frame", "DetailsBreakdownLeftMenuPluginsFrame", breakdownSideMenu, "BackdropTemplate")
breakdownWindowFrame.BreakdownPluginSelectionFrame = pluginsFrame

--create the frame to hold tab buttons
local tabButtonsFrame = CreateFrame("frame", "DetailsBreakdownTabsFrame", breakdownWindowFrame, "BackdropTemplate")
breakdownWindowFrame.BreakdownTabsFrame = tabButtonsFrame

local summaryWidgets = {}
local currentTab = "Summary"
local subAttributes = Details.sub_atributos

---return true if the breakdown window is shown and showing a plugin
---@return boolean
function Details222.BreakdownWindow.IsPluginShown()
	if (breakdownWindowFrame:IsShown()) then
		return breakdownWindowFrame.shownPluginObject ~= nil
	end
	return false
end

function breakdownWindowFrame.GetShownPluginObject()
	return breakdownWindowFrame.shownPluginObject
end

function Details222.BreakdownWindow.OnShowPluginFrame(pluginObject)
	--need to selected the selected tab and hide its content
	for index = 1, #Details.player_details_tabs do
		local tabButton = Details.player_details_tabs[index]
		tabButton.frame:Hide()
	end

	breakdownWindowFrame.BreakdownTabsFrame:Hide()
	breakdownWindowFrame.shownPluginObject = pluginObject

	breakdownWindowFrame.classIcon:Hide()
	breakdownWindowFrame.closeButton:Hide()
	breakdownWindowFrame.actorName:Hide()
	breakdownWindowFrame.attributeName:Hide()
	breakdownWindowFrame.avatar:Hide()
	breakdownWindowFrame.avatar_bg:Hide()
	breakdownWindowFrame.avatar_attribute:Hide()
	breakdownWindowFrame.avatar_nick:Hide()
end

function Details222.BreakdownWindow.HidePluginFrame()
	if (breakdownWindowFrame.shownPluginObject) then
		breakdownWindowFrame.shownPluginObject.Frame:Hide()
		breakdownWindowFrame.shownPluginObject = nil
	end

	breakdownWindowFrame.classIcon:Show()
	breakdownWindowFrame.closeButton:Show()
	breakdownWindowFrame.actorName:Show()
	breakdownWindowFrame.attributeName:Show()
	breakdownWindowFrame.avatar:Show()
	breakdownWindowFrame.avatar_bg:Show()
	breakdownWindowFrame.avatar_attribute:Show()
	breakdownWindowFrame.avatar_nick:Show()

	--reset the template on all plugin buttons
	for _, thisPluginButton in ipairs(breakdownWindowFrame.RegisteredPluginButtons) do
		---@cast thisPluginButton df_button
		thisPluginButton:SetTemplate(detailsFramework:GetTemplate("button", "STANDARD_GRAY"))
	end
end


function Details222.BreakdownWindow.ApplyFontSettings(fontString)
	detailsFramework:SetFontSize(fontString, Details.breakdown_general.font_size)
	detailsFramework:SetFontColor(fontString, Details.breakdown_general.font_color)
	detailsFramework:SetFontOutline(fontString, Details.breakdown_general.font_outline)
	detailsFramework:SetFontFace(fontString, Details.breakdown_general.font_face)
end

function Details222.BreakdownWindow.ApplyTextureSettings(statusBar)
	local textureFile = SharedMedia:Fetch("statusbar", Details.breakdown_general.bar_texture)
	local texture = statusBar:GetStatusBarTexture()
	if (texture) then
		texture:SetTexture(textureFile)
	else
		statusBar:SetStatusBarTexture(textureFile)
	end
end

------------------------------------------------------------------------------------------------------------------------------
--self = instancia
--jogador = classe_damage ou classe_heal

function Details:GetBreakdownTabsInUse()
	return breakdownWindowFrame.currentTabsInUse
end

function Details:GetBreakdownTabByName(tabName, tablePool)
	tablePool = tablePool or Details.player_details_tabs
	for index = 1, #tablePool do
		local tab = tablePool[index]
		if (tab.tabname == tabName) then
			return tab, index
		end
	end
end

--return the combat being used to show the data in the opened breakdown window
function Details:GetCombatFromBreakdownWindow()
	---@type instance
	local instance = breakdownWindowFrame.instancia
	return instance:GetCombat()
end

---return the window that requested to open the player breakdown window
---@return instance
function Details:GetActiveWindowFromBreakdownWindow()
	return breakdownWindowFrame.instancia
end

--return if the breakdown window is showing damage or heal
function Details:GetDisplayTypeFromBreakdownWindow()
	return breakdownWindowFrame.atributo, breakdownWindowFrame.sub_atributo
end

---return the actor object in use by the breakdown window
---@return actor actorObject
function Details:GetActorObjectFromBreakdownWindow()
	return breakdownWindowFrame.jogador
end

function Details:GetBreakdownWindow()
	return Details.BreakdownWindowFrame
end

function Details:IsBreakdownWindowOpen()
	return breakdownWindowFrame.ativo
end

function Details222.BreakdownWindow.RefreshPlayerScroll()
	if (breakdownWindowFrame.playerScrollBox) then
		breakdownWindowFrame.playerScrollBox:Refresh()
	end
end

Details.PlayerBreakdown.RoundedCornerPreset = {
	roundness = 12,
	color = {.1, .1, .1, 0.834},
}

Details222.RegisteredFramesToColor = {}

function Details:RegisterFrameToColor(frame)
	Details222.RegisteredFramesToColor[#Details222.RegisteredFramesToColor+1] = frame
	local colorTable = Details.frame_background_color
	frame:SetColor(unpack(colorTable))
end

function Details:RefreshWindowColor()
	local colorTable = Details.frame_background_color
	Details:SetWindowColor(unpack(colorTable))
end

function Details:SetWindowColor(r, g, b, a)
	--SetColor implemented by rounded corners
	breakdownWindowFrame:SetColor(r, g, b, a)
	breakdownSideMenu:SetColor(r, g, b, a)

	if (DetailsOptionsWindow) then
		DetailsOptionsWindow:SetColor(r, g, b, a)
		DetailsPluginContainerWindowMenuFrame:SetColor(r, g, b, a)
	end

	if (DetailsReportWindow) then
		DetailsReportWindow:SetColor(r, g, b, a)
	end

	if (DetailsAllAttributesFrame) then
		DetailsAllAttributesFrame:SetColor(r, g, b, a)
	end

	if (DetailsSpellBreakdownOptionsPanel) then
		DetailsSpellBreakdownOptionsPanel:SetColor(r, g, b, a)
	end

	for idx, frame in ipairs(Details222.RegisteredFramesToColor) do
		frame:SetColor(r, g, b, a)
	end

	local colorTable = Details.frame_background_color
	colorTable[1] = r
	colorTable[2] = g
	colorTable[3] = b
	colorTable[4] = a

	local instanceTable = Details:GetAllInstances()
	for _, instance in ipairs(instanceTable) do
		if (instance:IsEnabled()) then
			local baseFrame = instance.baseframe
			local fullWindowFrame = baseFrame.fullWindowFrame
			if (fullWindowFrame.__rcorners) then
				if (fullWindowFrame.BottomHorizontalEdge:IsShown()) then
					fullWindowFrame:SetColor(r, g, b, a)
				end
			end
		end
	end
end

---open the breakdown window
---@param self details
---@param instanceObject instance
---@param actorObject actor
---@param bFromAttributeChange boolean|nil
---@param bIsRefresh boolean|nil
---@param bIsShiftKeyDown boolean|nil
---@param bIsControlKeyDown boolean|nil
---@param bIgnoreOverrides boolean|nil
function Details:OpenBreakdownWindow(instanceObject, actorObject, bFromAttributeChange, bIsRefresh, bIsShiftKeyDown, bIsControlKeyDown, bIgnoreOverrides)
	---@type number, number
	local mainAttribute, subAttribute = instanceObject:GetDisplay()

	if (not breakdownWindowFrame.__rcorners) then
		breakdownWindowFrame:SetBackdropColor(.1, .1, .1, 0)
		breakdownWindowFrame:SetBackdropBorderColor(.1, .1, .1, 0)
		detailsFramework:AddRoundedCornersToFrame(breakdownWindowFrame, Details.PlayerBreakdown.RoundedCornerPreset)
		detailsFramework:AddRoundedCornersToFrame(breakdownSideMenu, Details.PlayerBreakdown.RoundedCornerPreset)
	end

	Details:SetWindowColor(unpack(Details.frame_background_color))

	if (not bIgnoreOverrides) then
		if (not Details.row_singleclick_overwrite[mainAttribute] or not Details.row_singleclick_overwrite[mainAttribute][subAttribute]) then
			Details:CloseBreakdownWindow()
			return

		elseif (type(Details.row_singleclick_overwrite[mainAttribute][subAttribute]) == "function") then
			if (bFromAttributeChange) then
				Details:CloseBreakdownWindow()
				return
			end
			Details.row_singleclick_overwrite[mainAttribute][subAttribute](_, actorObject, instanceObject, bIsShiftKeyDown, bIsControlKeyDown)
			return
		end
	end

	if (instanceObject:GetMode() == DETAILS_MODE_RAID) then
		Details:CloseBreakdownWindow()
		return
	end

	--Details.info_jogador armazena o jogador que esta sendo mostrado na janela de detalhes
	if (breakdownWindowFrame.jogador and breakdownWindowFrame.jogador == actorObject and instanceObject and breakdownWindowFrame.atributo and mainAttribute == breakdownWindowFrame.atributo and subAttribute == breakdownWindowFrame.sub_atributo and not bIsRefresh) then
		if (not breakdownWindowFrame.shownPluginObject) then
			Details:CloseBreakdownWindow() --clicked in the same player bar, close the window
			return
		end
	end

	if (not actorObject) then
		Details:CloseBreakdownWindow()
		return
	end

	--create the player list frame in the left side of the window
	Details.PlayerBreakdown.CreatePlayerListFrame()
	Details.PlayerBreakdown.CreateDumpDataFrame()

	--show the frame containing the tab buttons
	breakdownWindowFrame.BreakdownTabsFrame:Show()

	--hide the plugin if any is shown
	Details222.BreakdownWindow.HidePluginFrame()

	if (not breakdownWindowFrame.bHasInitialized) then
		local infoNumPoints = breakdownWindowFrame:GetNumPoints()
		for i = 1, infoNumPoints do
			local point1, anchorObject, point2, x, y = breakdownWindowFrame:GetPoint(i)
			if (not anchorObject) then
				breakdownWindowFrame:ClearAllPoints()
			end
		end

		breakdownWindowFrame:SetUserPlaced(false)
		breakdownWindowFrame:SetDontSavePosition(true)

		local okay, errorText = pcall(function()
			breakdownWindowFrame:SetPoint("center", UIParent, "center", 0, 0)
		end)

		if (not okay) then
			breakdownWindowFrame:ClearAllPoints()
			breakdownWindowFrame:SetPoint("center", UIParent, "center", 0, 0)
		end

		breakdownWindowFrame.bHasInitialized = true
	end

	if (not breakdownWindowFrame.RightSideBar) then
		--breakdownWindow:CreateRightSideBar()
	end

	--todo: all portuguese keys to english

	breakdownWindowFrame.ativo = true --sinaliza o addon que a janela esta aberta
	breakdownWindowFrame.atributo = mainAttribute --instancia.atributo -> grava o atributo (damage, heal, etc)
	breakdownWindowFrame.sub_atributo = subAttribute --instancia.sub_atributo -> grava o sub atributo (damage done, dps, damage taken, etc)
	breakdownWindowFrame.jogador = actorObject --de qual jogador (objeto classe_damage)
	breakdownWindowFrame.instancia = instanceObject --salva a refer�ncia da inst�ncia que pediu o breakdownWindow
	breakdownWindowFrame.target_text = Loc ["STRING_TARGETS"] .. ":"
	breakdownWindowFrame.target_member = "total"
	breakdownWindowFrame.target_persecond = false
	breakdownWindowFrame.mostrando = nil

	local playerName = breakdownWindowFrame.jogador:Name()
	local atributo_nome = subAttributes[breakdownWindowFrame.atributo].lista [breakdownWindowFrame.sub_atributo] .. " " .. Loc ["STRING_ACTORFRAME_REPORTOF"] --// nome do atributo // precisa ser o sub atributo correto???

	--removendo o nome da realm do jogador
	if (playerName:find("-")) then
		playerName = playerName:gsub(("-.*"), "")
	end

	if (breakdownWindowFrame.instancia.atributo == 1 and breakdownWindowFrame.instancia.sub_atributo == 6) then --enemy
		atributo_nome = subAttributes [breakdownWindowFrame.atributo].lista [1] .. " " .. Loc ["STRING_ACTORFRAME_REPORTOF"]
	end

	breakdownWindowFrame.actorName:SetText(playerName) --found it
	breakdownWindowFrame.attributeName:SetText(atributo_nome)

	local serial = actorObject.serial
	local avatar
	if (serial ~= "") then
		avatar = NickTag:GetNicknameTable(serial)
	end

	if (avatar and avatar[1]) then
		breakdownWindowFrame.actorName:SetText((not Details.ignore_nicktag and avatar[1]) or playerName)
	end

	if (avatar and avatar[2]) then
		breakdownWindowFrame.avatar:SetTexture(avatar[2])
		breakdownWindowFrame.avatar_bg:SetTexture(avatar[4])
		if (avatar[5]) then
			breakdownWindowFrame.avatar_bg:SetTexCoord(unpack(avatar[5]))
		end
		if (avatar[6]) then
			breakdownWindowFrame.avatar_bg:SetVertexColor(unpack(avatar[6]))
		end

		breakdownWindowFrame.avatar_nick:SetText(avatar[1] or playerName)
		breakdownWindowFrame.avatar_attribute:SetText(atributo_nome)

		breakdownWindowFrame.avatar_attribute:SetPoint("CENTER", breakdownWindowFrame.avatar_nick, "CENTER", 0, 14)
		breakdownWindowFrame.avatar:Show()
		breakdownWindowFrame.avatar_bg:Show()
		breakdownWindowFrame.avatar_bg:SetAlpha(.65)
		breakdownWindowFrame.avatar_nick:Show()
		breakdownWindowFrame.avatar_attribute:Show()
		breakdownWindowFrame.actorName:Hide()
		breakdownWindowFrame.attributeName:Hide()
	else
		breakdownWindowFrame.avatar:Hide()
		breakdownWindowFrame.avatar_bg:Hide()
		breakdownWindowFrame.avatar_nick:Hide()
		breakdownWindowFrame.avatar_attribute:Hide()

		breakdownWindowFrame.actorName:Show()
		breakdownWindowFrame.attributeName:Show()
	end

	breakdownWindowFrame.attributeName:SetPoint("bottomleft", breakdownWindowFrame.actorName, "topleft", 0, 2)

	---@type string
	local actorClass = actorObject:Class()

	if (not actorClass) then
		actorClass = "monster"
	end

	breakdownWindowFrame.classIcon:SetTexture("Interface\\AddOns\\Details\\images\\classes") --top left
	breakdownWindowFrame.SetClassIcon(actorObject, actorClass)

	Details.FadeHandler.Fader(breakdownWindowFrame, 0)
	Details:UpdateBreakdownPlayerList()
	Details:InitializeAurasTab()
	Details:InitializeCompareTab()

	--open tab
	local tabsShown = {}
	local tabsReplaced = {}
	local tabReplacedAmount = 0

	Details:Destroy(breakdownWindowFrame.currentTabsInUse)

	for index = 1, #Details.player_details_tabs do
		local tab = Details.player_details_tabs[index]
		tab.replaced = nil
		tabsShown[#tabsShown+1] = tab
	end

	for index = 1, #tabsShown do
		--get the tab
		local tab = tabsShown[index]

		if (tab.replaces) then
			local attributeList = tab.replaces.attributes
			if (attributeList[breakdownWindowFrame.atributo]) then
				if (attributeList[breakdownWindowFrame.atributo][breakdownWindowFrame.sub_atributo]) then
					local tabReplaced, tabIndex = Details:GetBreakdownTabByName(tab.replaces.tabNameToReplace, tabsShown)
					if (tabReplaced and tabIndex < index) then
						tabReplaced:Hide()
						tabReplaced.frame:Hide()
						tinsert(tabsReplaced, tabReplaced)
						tremove(tabsShown, tabIndex)
						tinsert(tabsShown, tabIndex, tab)

						if (tabReplaced.tabname == breakdownWindowFrame.selectedTab) then
							breakdownWindowFrame.selectedTab = tab.tabname
						end

						tabReplaced.replaced = true
						tabReplacedAmount = tabReplacedAmount  + 1
					end
				end
			end
		end
	end

	local newTabsShown = {}
	local tabAlreadyInUse = {}

	for index = 1, #tabsShown do
		if (not tabAlreadyInUse[tabsShown[index].tabname]) then
			tabAlreadyInUse[tabsShown[index].tabname] = true
			tinsert(newTabsShown, tabsShown[index])
		end
	end

	tabsShown = newTabsShown
	breakdownWindowFrame.currentTabsInUse = newTabsShown

	breakdownWindowFrame:ShowTabs()
	Details222.BreakdownWindow.CurrentDefaultTab = nil

	local shownTab
	for index = 1, #tabsShown do
		local tabButton = tabsShown[index]
		if (tabButton:condition(breakdownWindowFrame.jogador, breakdownWindowFrame.atributo, breakdownWindowFrame.sub_atributo)) then
			if (tabButton.IsDefaultTab) then
				Details222.BreakdownWindow.CurrentDefaultTab = tabButton
			end

			if (breakdownWindowFrame.selectedTab == tabButton.tabname) then
				tabButton:DoClick()
				tabButton:OnShowFunc()
				shownTab = tabButton

				actorObject:MontaInfo() --old api to update the breakdown window
			end
		end
	end

	if (shownTab) then
		shownTab:Click()
	end
end

function Details:CloseBreakdownWindow()
	if (breakdownWindowFrame.ativo) then
		Details.FadeHandler.Fader(breakdownWindowFrame, 1)

		breakdownWindowFrame.ativo = false --sinaliza o addon que a janela esta agora fechada
		breakdownWindowFrame.jogador = nil
		breakdownWindowFrame.atributo = nil
		breakdownWindowFrame.sub_atributo = nil
		breakdownWindowFrame.instancia = nil

		breakdownWindowFrame.actorName:SetText("")
		breakdownWindowFrame.attributeName:SetText("")

		--iterate all tabs and clear caches
		local tabsInUse = Details:GetBreakdownTabsInUse()
		for index = 1, #tabsInUse do
			local tabButton = tabsInUse[index]
			tabButton.last_actor = nil
		end
	end
end

function Details.PlayerBreakdown.CreateDumpDataFrame()
	local playerSelectionScrollFrame = DetailsBreakdownWindowPlayerScrollBox
	breakdownWindowFrame.dumpDataFrame = CreateFrame("frame", "$parentDumpTableFrame", playerSelectionScrollFrame, "BackdropTemplate")
	breakdownWindowFrame.dumpDataFrame:SetPoint("topleft", playerSelectionScrollFrame, "topleft", 0, 0)
	breakdownWindowFrame.dumpDataFrame:SetPoint("bottomright", playerSelectionScrollFrame, "bottomright", 0, 0)
	breakdownWindowFrame.dumpDataFrame:SetFrameLevel(playerSelectionScrollFrame:GetFrameLevel() + 10)
	detailsFramework:ApplyStandardBackdrop(breakdownWindowFrame.dumpDataFrame, true)
	breakdownWindowFrame.dumpDataFrame:Hide()

	--create a details framework special lua editor
	breakdownWindowFrame.dumpDataFrame.luaEditor = detailsFramework:NewSpecialLuaEditorEntry(breakdownWindowFrame.dumpDataFrame, 1, 1, "text", "$parentCodeEditorWindow")
	breakdownWindowFrame.dumpDataFrame.luaEditor:SetPoint("topleft", breakdownWindowFrame.dumpDataFrame, "topleft", 2, -2)
	breakdownWindowFrame.dumpDataFrame.luaEditor:SetPoint("bottomright", breakdownWindowFrame.dumpDataFrame, "bottomright", -2, 2)
	breakdownWindowFrame.dumpDataFrame.luaEditor:SetFrameLevel(breakdownWindowFrame.dumpDataFrame:GetFrameLevel()+1)
	breakdownWindowFrame.dumpDataFrame.luaEditor:SetBackdrop({})

	--hide the scroll bar
	DetailsBreakdownWindowPlayerScrollBoxDumpTableFrameCodeEditorWindowScrollBar:Hide()
end

function breakdownWindowFrame:CreateRightSideBar() --not enabled
	breakdownWindowFrame.RightSideBar = CreateFrame("frame", nil, breakdownWindowFrame, "BackdropTemplate")
	breakdownWindowFrame.RightSideBar:SetWidth(20)
	breakdownWindowFrame.RightSideBar:SetPoint("topleft", breakdownWindowFrame, "topright", 1, 0)
	breakdownWindowFrame.RightSideBar:SetPoint("bottomleft", breakdownWindowFrame, "bottomright", 1, 0)
	local rightSideBarAlpha = 0.75

	detailsFramework:ApplyStandardBackdrop(breakdownWindowFrame.RightSideBar)

	local toggleMergePlayerSpells = function()
		Details.merge_player_abilities = not Details.merge_player_abilities
		local playerObject = Details:GetActorObjectFromBreakdownWindow()
		local instanceObject = Details:GetActiveWindowFromBreakdownWindow()
		Details:OpenBreakdownWindow(instanceObject, playerObject) --toggle
		Details:OpenBreakdownWindow(instanceObject, playerObject)
	end

	local mergePlayerSpellsCheckbox = detailsFramework:CreateSwitch(breakdownWindowFrame, toggleMergePlayerSpells, Details.merge_player_abilities, _, _, _, _, _, _, _, _, _, _, detailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
	mergePlayerSpellsCheckbox:SetAsCheckBox()
	mergePlayerSpellsCheckbox:SetPoint("bottom", breakdownWindowFrame.RightSideBar, "bottom", 0, 2)

	local mergePlayerSpellsLabel = breakdownWindowFrame.RightSideBar:CreateFontString(nil, "overlay", "GameFontNormal")
	mergePlayerSpellsLabel:SetText("Merge Player Spells")
	detailsFramework:SetFontRotation(mergePlayerSpellsLabel, 90)
	mergePlayerSpellsLabel:SetPoint("center", mergePlayerSpellsCheckbox.widget, "center", -6, mergePlayerSpellsCheckbox:GetHeight()/2 + mergePlayerSpellsLabel:GetStringWidth() / 2)

	--

	local toggleMergePetSpells = function()
		Details.merge_pet_abilities = not Details.merge_pet_abilities
		local playerObject = Details:GetActorObjectFromBreakdownWindow()
		local instanceObject = Details:GetActiveWindowFromBreakdownWindow()
		Details:OpenBreakdownWindow(instanceObject, playerObject) --toggle
		Details:OpenBreakdownWindow(instanceObject, playerObject)
	end
	local mergePetSpellsCheckbox = detailsFramework:CreateSwitch(breakdownWindowFrame, toggleMergePetSpells, Details.merge_pet_abilities, _, _, _, _, _, _, _, _, _, _, detailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
	mergePetSpellsCheckbox:SetAsCheckBox(true)
	mergePetSpellsCheckbox:SetPoint("bottom", breakdownWindowFrame.RightSideBar, "bottom", 0, 160)

	local mergePetSpellsLabel = breakdownWindowFrame.RightSideBar:CreateFontString(nil, "overlay", "GameFontNormal")
	mergePetSpellsLabel:SetText("Merge Pet Spells")
	detailsFramework:SetFontRotation(mergePetSpellsLabel, 90)
	mergePetSpellsLabel:SetPoint("center", mergePetSpellsCheckbox.widget, "center", -6, mergePetSpellsCheckbox:GetHeight()/2 + mergePetSpellsLabel:GetStringWidth() / 2)

	mergePlayerSpellsCheckbox:SetAlpha(rightSideBarAlpha)
	mergePlayerSpellsLabel:SetAlpha(rightSideBarAlpha)
	mergePetSpellsCheckbox:SetAlpha(rightSideBarAlpha)
	mergePetSpellsLabel:SetAlpha(rightSideBarAlpha)
end

---@type {[number]: boolean}
Details222.BreakdownWindow.ExpandedSpells = {}

---set a spell as expanded or not in the breakdown window
---@param key any
---@param bIsExpanded boolean
function Details222.BreakdownWindow.SetSpellAsExpanded(key, bIsExpanded)
	Details222.BreakdownWindow.ExpandedSpells[key] = bIsExpanded
end

---get the state of the expanded for a spell
---@param key any
---@return boolean
function Details222.BreakdownWindow.IsSpellExpanded(key)
	return Details222.BreakdownWindow.ExpandedSpells[key]
end

---receives spell data to show in the summary tab
---@param data breakdownspelldatalist
---@param actorObject actor
---@param combatObject combat
---@param instance instance
function Details222.BreakdownWindow.SendSpellData(data, actorObject, combatObject, instance)
	--need to get the tab showing the summary and transmit the data to it
	local tabButton = Details222.BreakdownWindow.CurrentDefaultTab
	if (tabButton) then
		--tab is the tab button
		if (tabButton.OnReceiveSpellData) then
			tabButton.OnReceiveSpellData(data, actorObject, combatObject, instance)
		end
	end
end

function Details222.BreakdownWindow.SendTargetData(targetList, actorObject, combatObject, instance)
	local tabButton = Details222.BreakdownWindow.CurrentDefaultTab
	if (tabButton) then
		if (tabButton.OnReceiveTargetData) then
			tabButton.OnReceiveTargetData(targetList, actorObject, combatObject, instance)
		end
	end
end

function Details222.BreakdownWindow.SendGenericData(resultTable, actorObject, combatObject, instance)
	local tabButton = Details222.BreakdownWindow.CurrentDefaultTab
	if (tabButton) then
		if (tabButton.OnReceiveGenericData) then
			tabButton.OnReceiveGenericData(resultTable, actorObject, combatObject, instance)
		end
	end
end

---set the class or spec icon for the actor displayed
---@param actorObject actor
---@param class string
function breakdownWindowFrame.SetClassIcon(actorObject, class)
	if (actorObject.spellicon) then
		breakdownWindowFrame.classIcon:SetTexture(actorObject.spellicon)
		breakdownWindowFrame.classIcon:SetTexCoord(.1, .9, .1, .9)

	elseif (actorObject.spec) then
		breakdownWindowFrame.classIcon:SetTexture([[Interface\AddOns\Details\images\spec_icons_normal_alpha]])
		breakdownWindowFrame.classIcon:SetTexCoord(unpack(_detalhes.class_specs_coords [actorObject.spec]))
	else
		local coords = CLASS_ICON_TCOORDS[class]
		if (coords) then
			breakdownWindowFrame.classIcon:SetTexture([[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-CLASSES]])
			local l, r, t, b = unpack(coords)
			breakdownWindowFrame.classIcon:SetTexCoord(l+0.01953125, r-0.01953125, t+0.01953125, b-0.01953125)
		else
			local c = _detalhes.class_coords ["MONSTER"]
			breakdownWindowFrame.classIcon:SetTexture("Interface\\AddOns\\Details\\images\\classes")
			breakdownWindowFrame.classIcon:SetTexCoord(c[1], c[2], c[3], c[4])
		end
	end
end

--search key: ~create ~inicio ~start
function Details:CreateBreakdownWindow()
	table.insert(UISpecialFrames, breakdownWindowFrame:GetName())
	breakdownWindowFrame.extra_frames = {}
	breakdownWindowFrame.Loaded = true
	Details.BreakdownWindowFrame = breakdownWindowFrame

	breakdownWindowFrame:SetWidth(PLAYER_DETAILS_WINDOW_WIDTH)
	breakdownWindowFrame:SetHeight(PLAYER_DETAILS_WINDOW_HEIGHT)
	breakdownWindowFrame:SetFrameStrata("HIGH")
	breakdownWindowFrame:SetToplevel(true)
	breakdownWindowFrame:EnableMouse(true)
	breakdownWindowFrame:SetResizable(true)
	breakdownWindowFrame:SetMovable(true)
	--breakdownWindowFrame:SetClampedToScreen(true)

	--make the window movable
	if (not breakdownWindowFrame.registeredLibWindow) then
		local LibWindow = LibStub("LibWindow-1.1")
		breakdownWindowFrame.registeredLibWindow = true
		if (LibWindow) then
			breakdownWindowFrame.libWindowTable = breakdownWindowFrame.libWindowTable or {}
			LibWindow.RegisterConfig(breakdownWindowFrame, breakdownWindowFrame.libWindowTable)
			LibWindow.RestorePosition(breakdownWindowFrame)
			LibWindow.MakeDraggable(breakdownWindowFrame)
			LibWindow.SavePosition(breakdownWindowFrame)

			breakdownWindowFrame:SetScript("OnMouseDown", function(self, button)
				if (button == "RightButton") then
					Details:CloseBreakdownWindow()
				end
			end)
		end
	end

	--host the textures and fontstring of the default frame of the player breakdown window
	--what is the summary window: is the frame where all the widgets for the summary tab are created
	breakdownWindowFrame.SummaryWindowWidgets = CreateFrame("frame", "DetailsBreakdownWindowSummaryWidgets", breakdownWindowFrame, "BackdropTemplate")
	local SWW = breakdownWindowFrame.SummaryWindowWidgets
	SWW:SetAllPoints()
	table.insert(summaryWidgets, SWW) --where SummaryWidgets is declared: at the header of the file, what is the purpose of this table?
	breakdownWindowFrame.SummaryWindowWidgets:Hide()

	local scaleBar = detailsFramework:CreateScaleBar(breakdownWindowFrame, Details.player_details_window)
	scaleBar.label:AdjustPointsOffset(-3, 1)
	scaleBar.label:SetTextColor{0.8902, 0.7294, 0.0157, 1}
	scaleBar.label:SetIgnoreParentAlpha(true)
	breakdownWindowFrame:SetScale(Details.player_details_window.scale)

	--1, 0.8235, 0, 1 - text color of the label of the scale bar | plugins text color: 0.8902, 0.7294, 0.0157, 1 | 0.8902, 0.7294, 0.0157, 1

	--class icon
	breakdownWindowFrame.classIcon = breakdownWindowFrame:CreateTexture(nil, "overlay", nil, 1)
	breakdownWindowFrame.classIcon:SetPoint("topleft", breakdownWindowFrame, "topleft", 2, -17)
	breakdownWindowFrame.classIcon:SetSize(54, 54)
	breakdownWindowFrame.classIcon:SetAlpha(0.7)

	local closeButton = detailsFramework:CreateCloseButton(breakdownWindowFrame)
	closeButton:SetPoint("topright", breakdownWindowFrame, "topright", -2, -2)
    closeButton:SetScript("OnClick", function(self)
        Details:CloseBreakdownWindow()
    end)
	breakdownWindowFrame.closeButton = closeButton

	--title
	detailsFramework:NewLabel(breakdownWindowFrame, breakdownWindowFrame, nil, "titleText", Loc ["STRING_PLAYER_DETAILS"], "GameFontHighlightLeft", 12, {227/255, 186/255, 4/255})
	breakdownWindowFrame.titleText:SetPoint("center", breakdownWindowFrame, "center")
	breakdownWindowFrame.titleText:SetPoint("top", breakdownWindowFrame, "top", 0, -5)

	--create the texts shown on the window
	do
		breakdownWindowFrame.actorName = breakdownWindowFrame:CreateFontString(nil, "overlay", "QuestFont_Large")
		breakdownWindowFrame.actorName:SetPoint("left", breakdownWindowFrame.classIcon, "right", 20, -7)

		breakdownWindowFrame.attributeName = breakdownWindowFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		breakdownWindowFrame.avatar = breakdownWindowFrame:CreateTexture(nil, "overlay")
		breakdownWindowFrame.avatar_bg = breakdownWindowFrame:CreateTexture(nil, "overlay")
		breakdownWindowFrame.avatar_attribute = breakdownWindowFrame:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
		breakdownWindowFrame.avatar_nick = breakdownWindowFrame:CreateFontString(nil, "overlay", "QuestFont_Large")
		breakdownWindowFrame.avatar:SetDrawLayer("overlay", 3)
		breakdownWindowFrame.avatar_bg:SetDrawLayer("overlay", 2)
		breakdownWindowFrame.avatar_nick:SetDrawLayer("overlay", 4)

		breakdownWindowFrame.avatar:SetPoint("TOPLEFT", breakdownWindowFrame, "TOPLEFT", 60, -10)
		breakdownWindowFrame.avatar_bg:SetPoint("TOPLEFT", breakdownWindowFrame, "TOPLEFT", 60, -12)
		breakdownWindowFrame.avatar_bg:SetSize(275, 60)

		breakdownWindowFrame.avatar_nick:SetPoint("TOPLEFT", breakdownWindowFrame, "TOPLEFT", 195, -54)

		breakdownWindowFrame.avatar:Hide()
		breakdownWindowFrame.avatar_bg:Hide()
		breakdownWindowFrame.avatar_nick:Hide()
	end

	--statusbar
	local statusBar = CreateFrame("frame", nil, breakdownWindowFrame, "BackdropTemplate")
	statusBar:SetPoint("bottomleft", breakdownWindowFrame, "bottomleft")
	statusBar:SetPoint("bottomright", breakdownWindowFrame, "bottomright")
	statusBar:SetHeight(PLAYER_DETAILS_STATUSBAR_HEIGHT)
	--detailsFramework:ApplyStandardBackdrop(statusBar)
	statusBar:SetAlpha(PLAYER_DETAILS_STATUSBAR_ALPHA)
	breakdownWindowFrame.statusBar = statusBar

	statusBar.Text = detailsFramework:CreateLabel(statusBar)
	statusBar.Text:SetPoint("left", 12, 0)

	--create the gradients in the top and bottom side of the breakdown window
	local gradientStartColor = Details222.ColorScheme.GetColorFor("gradient-background")
	local gradientUp = detailsFramework:CreateTexture(breakdownWindowFrame, {gradient = "vertical", fromColor = gradientStartColor, toColor = {0, 0, 0, 0.2}}, 1, 68, "artwork", {0, 1, 0, 1})
	gradientUp:SetPoint("tops", 1, 18)
	breakdownWindowFrame.gradientUp = gradientUp

	local gradientHeight = 481
	local gradientDown = detailsFramework:CreateTexture(breakdownWindowFrame, {gradient = "vertical", fromColor = "transparent", toColor = {0, 0, 0, 0.7}}, 1, gradientHeight, "border", {0, 1, 0, 1})
	gradientDown:SetPoint("bottomleft", breakdownWindowFrame.statusBar, "topleft", 1, 1)
	gradientDown:SetPoint("bottomright", breakdownWindowFrame.statusBar, "topright", -1, 1)
	breakdownWindowFrame.gradientDown = gradientDown

	--visual debugging
	gradientUp:Hide()
	gradientDown:Hide()

	function breakdownWindowFrame:SetStatusbarText(text, fontSize, fontColor)
		if (not text) then
			breakdownWindowFrame:SetStatusbarText("An AddOn by Terciob | Part of Details! Damage Meter | Click 'Options' button for settings.", 10, "gray")
			return
		end
		statusBar.Text.text = text
		statusBar.Text.fontsize = fontSize
		statusBar.Text.fontcolor = fontColor
	end

	local rightClickToCloseLabel = Details:CreateRightClickToCloseLabel(statusBar)
	rightClickToCloseLabel:SetPoint("right", -283, 3)

	--set default text
	breakdownWindowFrame:SetStatusbarText()

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--tabs ~tabs
	function breakdownWindowFrame:ShowTabs()
		local tabsShown = 0
		local secondRowIndex = 1
		local breakLine = 7 --the tab it'll start the second line

		local tablePool = Details:GetBreakdownTabsInUse()

		for index = 1, #tablePool do
			local tabButton = tablePool[index]

			if (tabButton:condition(breakdownWindowFrame.jogador, breakdownWindowFrame.atributo, breakdownWindowFrame.sub_atributo) and not tabButton.replaced) then
				--test if can show the tutorial for the comparison tab
				if (tabButton.tabname == "Compare") then
					--Details:SetTutorialCVar ("DETAILS_INFO_TUTORIAL1", false)
					if (not Details:GetTutorialCVar("DETAILS_INFO_TUTORIAL1")) then
						Details:SetTutorialCVar ("DETAILS_INFO_TUTORIAL1", true)

						local alert = CreateFrame("frame", "DetailsInfoPopUp1", breakdownWindowFrame, "DetailsHelpBoxTemplate")
						alert.ArrowUP:Show()
						alert.ArrowGlowUP:Show()
						alert.Text:SetText(Loc ["STRING_INFO_TUTORIAL_COMPARISON1"])
						alert:SetPoint("bottom", tabButton.widget or tabButton, "top", 5, 28)
						alert:Show()
					end
				end

				tabButton:Show()
				tabsShown = tabsShown + 1

				tabButton:ClearAllPoints()

				--get the button width
				local buttonTemplate = detailsFramework:GetTemplate("button", "DETAILS_TAB_BUTTON_TEMPLATE")
				local buttonWidth = buttonTemplate.width + 1

				--pixelutil might not be compatible with classic wow
				if (PixelUtil) then
					PixelUtil.SetSize(tabButton, buttonTemplate.width, buttonTemplate.height)
					if (tabsShown >= breakLine) then --next row of icons
						PixelUtil.SetPoint(tabButton, "bottomright", breakdownWindowFrame, "topright", -613 + (buttonWidth * (secondRowIndex)), -48)
						secondRowIndex = secondRowIndex + 1
					else
						PixelUtil.SetPoint(tabButton, "bottomright", breakdownWindowFrame, "topright", -613 + (buttonWidth * tabsShown), -69)
					end
				else
					tabButton:SetSize(buttonTemplate.width, buttonTemplate.height)
					if (tabsShown >= breakLine) then --next row of icons
						tabButton:SetPoint("bottomright", breakdownWindowFrame, "topright", -613 + (buttonWidth * (secondRowIndex)), -48)
						secondRowIndex = secondRowIndex + 1
					else
						tabButton:SetPoint("bottomright", breakdownWindowFrame, "topright", -613 + (buttonWidth * tabsShown), -69)
					end
				end

				tabButton:SetAlpha(0.8)
			else
				tabButton.frame:Hide()
				tabButton:Hide()
			end
		end

		if (tabsShown < 2) then
			tablePool[1]:SetPoint("bottomleft", breakdownWindowFrame.container_barras, "topleft", 490 - (94 * (1-0)), 1)
		end

		--selected by default
		tablePool[1]:Click()
	end

	breakdownWindowFrame:SetScript("OnHide", function(self)
		Details:CloseBreakdownWindow()
		for _, tab in ipairs(Details.player_details_tabs) do
			tab:Hide()
			tab.frame:Hide()
		end
	end)

	breakdownWindowFrame.tipo = 1 --tipo da janela // 1 = janela normal
	return breakdownWindowFrame
end

breakdownWindowFrame.selectedTab = "Summary"

function Details:CreatePlayerDetailsTab(tabName, locName, conditionFunc, fillFunc, tabOnClickFunc, onCreateFunc, iconSettings, replace, bIsDefaultTab) --~tab
	if (not tabName) then
		tabName = "unnamed"
	end

	--create a button to select the tab
	local tabButton = detailsFramework:CreateButton(breakdownWindowFrame.BreakdownTabsFrame, function()end, 20, 20, locName, nil, nil, nil, nil, breakdownWindowFrame:GetName() .. "TabButton" .. tabName .. math.random(1, 1000), nil, "DETAILS_TAB_BUTTON_TEMPLATE")
	tabButton:SetFrameLevel(breakdownWindowFrame.BreakdownTabsFrame:GetFrameLevel()+1)
	tabButton:Hide()

	if (tabName == "Summary") then
		tabButton:SetTemplate("DETAILS_TAB_BUTTONSELECTED_TEMPLATE")
	end

	tabButton.IsDefaultTab = bIsDefaultTab
	tabButton.condition = conditionFunc
	tabButton.tabname = tabName
	tabButton.localized_name = locName
	tabButton.onclick = tabOnClickFunc
	tabButton.fillfunction = fillFunc
	tabButton.last_actor = {} --need to double check is this getting cleared

	---@type tabframe
	local tabFrame = CreateFrame("frame", breakdownWindowFrame:GetName() .. "TabFrame" .. tabName .. math.random(1, 10000), breakdownWindowFrame, "BackdropTemplate")
	tabFrame:SetFrameLevel(breakdownWindowFrame:GetFrameLevel()+1)
	tabFrame:SetPoint("topleft", breakdownWindowFrame, "topleft", 1, -70)
	tabFrame:SetPoint("bottomright", breakdownWindowFrame, "bottomright", -1, 20)
	tabFrame:Hide()

	--DetailsFramework:ApplyStandardBackdrop(tabFrame)
	--tabFrame:SetBackdropColor(0, 0, 0, 0)
	--tabFrame:SetBackdropBorderColor(0, 0, 0, 0)
	--tabFrame.__background:SetAlpha(0)
	--tabFrame.RightEdge:Hide()

	--create the gradients in the top and bottom side of the breakdown window
	local gradientStartColor = Details222.ColorScheme.GetColorFor("gradient-background")
	local red, green, blue = unpack(gradientStartColor)

	local gradientUpDown = detailsFramework:CreateTexture(tabFrame, {gradient = "vertical", fromColor = {red, green, blue, 0}, toColor = {red, green, blue, 0.4}}, 1, 34*2, "artwork", {0, 1, 0, 1})
	gradientUpDown:SetPoint("topleft", tabFrame, "topleft", 0, 0)
	gradientUpDown:SetPoint("topright", tabFrame, "topright", 0, 0)

	tabButton.tabFrame = tabFrame
	tabButton.frame = tabFrame

	if (iconSettings) then
		local texture = iconSettings.texture
		local coords = iconSettings.coords
		local width = iconSettings.width
		local height = iconSettings.height

		local overlay, textdistance, leftpadding, textheight, short_method --nil

		tabButton:SetIcon(texture, width, height, "overlay", coords, overlay, textdistance, leftpadding, textheight, short_method)
		if (iconSettings.desaturated) then
			tabButton.icon:SetDesaturated(true)
		end
	end

	if (tabButton.fillfunction) then
		tabFrame:SetScript("OnShow", function()
			---@type actor
			local actorObject = Details:GetActorObjectFromBreakdownWindow()

			if (tabButton.last_actor == actorObject) then
				return
			end

			---@type instance
			local instanceObject = Details:GetActiveWindowFromBreakdownWindow()
			---@type combat
			local combatObject = instanceObject:GetCombat()

			tabButton.last_actor = actorObject --it's caching the actor, on pre-reset need to clean up this variable (need to check this later)
			tabButton:fillfunction(actorObject, combatObject)
		end)
	end

	if (onCreateFunc) then
		onCreateFunc(tabButton, tabFrame)
	end

	tabButton.replaces = replace
	Details.player_details_tabs[#Details.player_details_tabs+1] = tabButton

	local onTabClickCallback = function(self) --self = tabButton
		self = self.MyObject or self --framework button

		for _, thisTabButton in ipairs(Details:GetBreakdownTabsInUse()) do
			thisTabButton.frame:Hide()
			thisTabButton:SetTemplate("DETAILS_TAB_BUTTON_TEMPLATE")
		end

		self:SetTemplate("DETAILS_TAB_BUTTONSELECTED_TEMPLATE")
		breakdownWindowFrame.selectedTab = self.tabname
	end

	if (not tabOnClickFunc) then
		tabButton.OnShowFunc = function(self)
			--hide all tab frames, reset the template on all tabs
			--then set the template on this tab and set as selected tab
			onTabClickCallback(self)
			--show the tab frame
			tabFrame:Show()
		end
		tabButton:SetScript("OnClick", tabButton.OnShowFunc)
	else
		--custom
		tabButton.OnShowFunc = function(self)
			--hide all tab frames, reset the template on all tabs
			--then set the template on this tab and set as selected tab
			onTabClickCallback(self)

			--run onclick func
			local result, errorText = pcall(tabOnClickFunc, tabButton, tabFrame)
			if (not result) then
				print("error on running tabOnClick function:", errorText)
			end
		end
		tabButton:SetScript("OnClick", tabButton.OnShowFunc)
	end

	function tabButton:DoClick()
		self:GetScript("OnClick")(self)
	end

	tabButton:SetScript("PostClick", function(self)
		currentTab = self.tabname or self.MyObject.tabname

		if (currentTab ~= "Summary") then
			for _, widget in ipairs(summaryWidgets) do
				widget:Hide()
			end
		else
			for _, widget in ipairs(summaryWidgets) do
				widget:Show()
			end
		end
	end)

	return tabButton, tabFrame
end