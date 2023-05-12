
local Details = _G.Details
local Loc = _G.LibStub("AceLocale-3.0"):GetLocale ( "Details" )
local SharedMedia = _G.LibStub:GetLibrary("LibSharedMedia-3.0")
local UIParent = UIParent
local gump = 			Details.gump
local _
local addonName, Details222 = ...

--remove warnings in the code
local ipairs = ipairs
local tinsert = tinsert
local tremove = tremove
local type = type
local unpack = _G.unpack
local PixelUtil = PixelUtil
local UISpecialFrames = UISpecialFrames
local wipe = wipe
local CreateFrame = _G.CreateFrame
local detailsFramework = DetailsFramework

local subAttributes = Details.sub_atributos
local breakdownWindow = Details.playerDetailWindow

local SummaryWidgets = {}
local CurrentTab = "Summary"

local PLAYER_DETAILS_WINDOW_WIDTH = 890
local PLAYER_DETAILS_WINDOW_HEIGHT = 574
local PLAYER_DETAILS_STATUSBAR_HEIGHT = 20
local PLAYER_DETAILS_STATUSBAR_ALPHA = 1

Details.player_details_tabs = {}
breakdownWindow.currentTabsInUse =  {}

Details222.BreakdownWindow.BackdropSettings = {
	backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
	backdropcolor = {DetailsFramework:GetDefaultBackdropColor()},
	backdropbordercolor = {0, 0, 0, 0.7},
}

------------------------------------------------------------------------------------------------------------------------------
--self = instancia
--jogador = classe_damage ou classe_heal

function Details:GetBreakdownTabsInUse()
	return breakdownWindow.currentTabsInUse
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
	return breakdownWindow.instancia and breakdownWindow.instancia.showing
end

---return the window that requested to open the player breakdown window
---@return instance
function Details:GetActiveWindowFromBreakdownWindow()
	return breakdownWindow.instancia
end

--return if the breakdown window is showing damage or heal
function Details:GetDisplayTypeFromBreakdownWindow()
	return breakdownWindow.atributo, breakdownWindow.sub_atributo
end

--return the actor object in use by the breakdown window
function Details:GetActorObjectFromBreakdownWindow()
	return breakdownWindow.jogador
end

function Details:GetBreakdownWindow()
	return Details.playerDetailWindow
end

function Details:IsBreakdownWindowOpen()
	return breakdownWindow.ativo
end

---open the breakdown window
---@param self details
---@param instanceObject instance
---@param actorObject actor
---@param bFromAttributeChange boolean|nil
---@param bIsRefresh boolean|nil
---@param bIsShiftKeyDown boolean|nil
---@param bIsControlKeyDown boolean|nil
function Details:OpenBreakdownWindow(instanceObject, actorObject, bFromAttributeChange, bIsRefresh, bIsShiftKeyDown, bIsControlKeyDown)
	---@type number, number
	local mainAttribute, subAttribute = instanceObject:GetDisplay()

	--create the player list frame in the left side of the window
	Details.PlayerBreakdown.CreatePlayerListFrame()
	Details.PlayerBreakdown.CreateDumpDataFrame()

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

	if (instanceObject:GetMode() == DETAILS_MODE_RAID) then
		Details:CloseBreakdownWindow()
		return
	end

	--Details.info_jogador armazena o jogador que esta sendo mostrado na janela de detalhes
	if (breakdownWindow.jogador and breakdownWindow.jogador == actorObject and instanceObject and breakdownWindow.atributo and mainAttribute == breakdownWindow.atributo and subAttribute == breakdownWindow.sub_atributo and not bIsRefresh) then
		Details:CloseBreakdownWindow() --se clicou na mesma barra ent�o fecha a janela de detalhes
		return

	elseif (not actorObject) then
		Details:CloseBreakdownWindow()
		return
	end

	if (not breakdownWindow.bHasInitialized) then
		local infoNumPoints = breakdownWindow:GetNumPoints()
		for i = 1, infoNumPoints do
			local point1, anchorObject, point2, x, y = breakdownWindow:GetPoint(i)
			if (not anchorObject) then
				breakdownWindow:ClearAllPoints()
			end
		end

		breakdownWindow:SetUserPlaced(false)
		breakdownWindow:SetDontSavePosition(true)

		local okay, errorText = pcall(function()
			breakdownWindow:SetPoint("center", UIParent, "center", 0, 0)
		end)

		if (not okay) then
			breakdownWindow:ClearAllPoints()
			breakdownWindow:SetPoint("center", UIParent, "center", 0, 0)
		end

		breakdownWindow.bHasInitialized = true
	end

	if (not breakdownWindow.RightSideBar) then
		--breakdownWindow:CreateRightSideBar()
	end

	--todo: all portuguese keys to english

	breakdownWindow.ativo = true --sinaliza o addon que a janela esta aberta
	breakdownWindow.atributo = mainAttribute --instancia.atributo -> grava o atributo (damage, heal, etc)
	breakdownWindow.sub_atributo = subAttribute --instancia.sub_atributo -> grava o sub atributo (damage done, dps, damage taken, etc)
	breakdownWindow.jogador = actorObject --de qual jogador (objeto classe_damage)
	breakdownWindow.instancia = instanceObject --salva a refer�ncia da inst�ncia que pediu o breakdownWindow
	breakdownWindow.target_text = Loc ["STRING_TARGETS"] .. ":"
	breakdownWindow.target_member = "total"
	breakdownWindow.target_persecond = false
	breakdownWindow.mostrando = nil

	local nome = breakdownWindow.jogador.nome --nome do jogador
	local atributo_nome = subAttributes[breakdownWindow.atributo].lista [breakdownWindow.sub_atributo] .. " " .. Loc ["STRING_ACTORFRAME_REPORTOF"] --// nome do atributo // precisa ser o sub atributo correto???

	--removendo o nome da realm do jogador
	if (nome:find("-")) then
		nome = nome:gsub(("-.*"), "")
	end

	if (breakdownWindow.instancia.atributo == 1 and breakdownWindow.instancia.sub_atributo == 6) then --enemy
		atributo_nome = subAttributes [breakdownWindow.atributo].lista [1] .. " " .. Loc ["STRING_ACTORFRAME_REPORTOF"]
	end

	breakdownWindow.actorName:SetText(nome) --found it
	breakdownWindow.attributeName:SetText(atributo_nome)

	local serial = actorObject.serial
	local avatar
	if (serial ~= "") then
		avatar = NickTag:GetNicknameTable (serial)
	end

	if (avatar and avatar [1]) then
		breakdownWindow.actorName:SetText((not Details.ignore_nicktag and avatar [1]) or nome)
	end

	if (avatar and avatar [2]) then
		breakdownWindow.avatar:SetTexture(avatar [2])
		breakdownWindow.avatar_bg:SetTexture(avatar [4])
		if (avatar [5]) then
			breakdownWindow.avatar_bg:SetTexCoord(unpack(avatar [5]))
		end
		if (avatar [6]) then
			breakdownWindow.avatar_bg:SetVertexColor(unpack(avatar [6]))
		end

		breakdownWindow.avatar_nick:SetText(avatar [1] or nome)
		breakdownWindow.avatar_attribute:SetText(atributo_nome)

		breakdownWindow.avatar_attribute:SetPoint("CENTER", breakdownWindow.avatar_nick, "CENTER", 0, 14)
		breakdownWindow.avatar:Show()
		breakdownWindow.avatar_bg:Show()
		breakdownWindow.avatar_bg:SetAlpha(.65)
		breakdownWindow.avatar_nick:Show()
		breakdownWindow.avatar_attribute:Show()
		breakdownWindow.actorName:Hide()
		breakdownWindow.attributeName:Hide()
	else
		breakdownWindow.avatar:Hide()
		breakdownWindow.avatar_bg:Hide()
		breakdownWindow.avatar_nick:Hide()
		breakdownWindow.avatar_attribute:Hide()

		breakdownWindow.actorName:Show()
		breakdownWindow.attributeName:Show()
	end

	breakdownWindow.attributeName:SetPoint("bottomleft", breakdownWindow.actorName, "topleft", 0, 2)

	---@type string
	local actorClass = actorObject.classe --classe not registered because it should be renamed to english 'class'

	if (not actorClass) then
		actorClass = "monster"
	end

	breakdownWindow.classIcon:SetTexture("Interface\\AddOns\\Details\\images\\classes") --top left
	breakdownWindow.SetClassIcon(actorObject, actorClass)

	Details.FadeHandler.Fader(breakdownWindow, 0)
	Details:UpdateBreakdownPlayerList()
	Details:InitializeAurasTab()
	Details:InitializeCompareTab()

	--open tab
	local tabsShown = {}
	local tabsReplaced = {}
	local tabReplacedAmount = 0

	wipe(breakdownWindow.currentTabsInUse)

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
			if (attributeList[breakdownWindow.atributo]) then
				if (attributeList[breakdownWindow.atributo][breakdownWindow.sub_atributo]) then
					local tabReplaced, tabIndex = Details:GetBreakdownTabByName(tab.replaces.tabNameToReplace, tabsShown)
					if (tabReplaced and tabIndex < index) then
						tabReplaced:Hide()
						tabReplaced.frame:Hide()
						tinsert(tabsReplaced, tabReplaced)
						tremove(tabsShown, tabIndex)
						tinsert(tabsShown, tabIndex, tab)

						if (tabReplaced.tabname == breakdownWindow.selectedTab) then
							breakdownWindow.selectedTab = tab.tabname
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
	breakdownWindow.currentTabsInUse = newTabsShown

	breakdownWindow:ShowTabs()
	Details222.BreakdownWindow.CurrentDefaultTab = nil

	local shownTab
	for index = 1, #tabsShown do
		local tabButton = tabsShown[index]
		if (tabButton:condition(breakdownWindow.jogador, breakdownWindow.atributo, breakdownWindow.sub_atributo)) then
			if (tabButton.IsDefaultTab) then
				Details222.BreakdownWindow.CurrentDefaultTab = tabButton
			end

			if (breakdownWindow.selectedTab == tabButton.tabname) then
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
	if (breakdownWindow.ativo) then
		Details.FadeHandler.Fader(breakdownWindow, 1)

		breakdownWindow.ativo = false --sinaliza o addon que a janela esta agora fechada
		breakdownWindow.jogador = nil
		breakdownWindow.atributo = nil
		breakdownWindow.sub_atributo = nil
		breakdownWindow.instancia = nil

		breakdownWindow.actorName:SetText("")
		breakdownWindow.attributeName:SetText("")

		--iterate all tabs and clear caches
		local tabsInUse = Details:GetBreakdownTabsInUse()
		for index = 1, #tabsInUse do
			local tabButton = tabsInUse[index]
			tabButton.last_actor = nil
		end
	end
end

function Details.PlayerBreakdown.CreateDumpDataFrame()
	breakdownWindow.dumpDataFrame = CreateFrame("frame", "$parentDumpTableFrame", DetailsBreakdownWindowPlayerScrollBox, "BackdropTemplate")
	breakdownWindow.dumpDataFrame:SetPoint("topleft", DetailsBreakdownWindowPlayerScrollBox, "topleft", 0, 0)
	breakdownWindow.dumpDataFrame:SetPoint("bottomright", DetailsBreakdownWindowPlayerScrollBox, "bottomright", 0, 0)
	breakdownWindow.dumpDataFrame:SetFrameLevel(DetailsBreakdownWindowPlayerScrollBox:GetFrameLevel() + 10)
	detailsFramework:ApplyStandardBackdrop(breakdownWindow.dumpDataFrame, true)
	breakdownWindow.dumpDataFrame:Hide()

	--create a details framework special lua editor
	breakdownWindow.dumpDataFrame.luaEditor = detailsFramework:NewSpecialLuaEditorEntry(breakdownWindow.dumpDataFrame, 1, 1, "text", "$parentCodeEditorWindow")
	breakdownWindow.dumpDataFrame.luaEditor:SetPoint("topleft", breakdownWindow.dumpDataFrame, "topleft", 2, -2)
	breakdownWindow.dumpDataFrame.luaEditor:SetPoint("bottomright", breakdownWindow.dumpDataFrame, "bottomright", -2, 2)
	breakdownWindow.dumpDataFrame.luaEditor:SetFrameLevel(breakdownWindow.dumpDataFrame:GetFrameLevel()+1)
	breakdownWindow.dumpDataFrame.luaEditor:SetBackdrop({})

	--hide the scroll bar
	DetailsBreakdownWindowPlayerScrollBoxDumpTableFrameCodeEditorWindowScrollBar:Hide()
end

function breakdownWindow:CreateRightSideBar() --not enabled
	breakdownWindow.RightSideBar = CreateFrame("frame", nil, breakdownWindow, "BackdropTemplate")
	breakdownWindow.RightSideBar:SetWidth(20)
	breakdownWindow.RightSideBar:SetPoint("topleft", breakdownWindow, "topright", 1, 0)
	breakdownWindow.RightSideBar:SetPoint("bottomleft", breakdownWindow, "bottomright", 1, 0)
	local rightSideBarAlpha = 0.75

	detailsFramework:ApplyStandardBackdrop(breakdownWindow.RightSideBar)

	local toggleMergePlayerSpells = function()
		Details.merge_player_abilities = not Details.merge_player_abilities
		local playerObject = Details:GetActorObjectFromBreakdownWindow()
		local instanceObject = Details:GetActiveWindowFromBreakdownWindow()
		Details:OpenBreakdownWindow(instanceObject, playerObject) --toggle
		Details:OpenBreakdownWindow(instanceObject, playerObject)
	end

	local mergePlayerSpellsCheckbox = detailsFramework:CreateSwitch(breakdownWindow, toggleMergePlayerSpells, Details.merge_player_abilities, _, _, _, _, _, _, _, _, _, _, detailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
	mergePlayerSpellsCheckbox:SetAsCheckBox()
	mergePlayerSpellsCheckbox:SetPoint("bottom", breakdownWindow.RightSideBar, "bottom", 0, 2)

	local mergePlayerSpellsLabel = breakdownWindow.RightSideBar:CreateFontString(nil, "overlay", "GameFontNormal")
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
	local mergePetSpellsCheckbox = detailsFramework:CreateSwitch(breakdownWindow, toggleMergePetSpells, Details.merge_pet_abilities, _, _, _, _, _, _, _, _, _, _, detailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
	mergePetSpellsCheckbox:SetAsCheckBox(true)
	mergePetSpellsCheckbox:SetPoint("bottom", breakdownWindow.RightSideBar, "bottom", 0, 160)

	local mergePetSpellsLabel = breakdownWindow.RightSideBar:CreateFontString(nil, "overlay", "GameFontNormal")
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
---@param spellID number
---@param bIsExpanded boolean
function Details222.BreakdownWindow.SetSpellAsExpanded(spellID, bIsExpanded)
	Details222.BreakdownWindow.ExpandedSpells[spellID] = bIsExpanded
end

---get the state of the expanded for a spell
---@param spellID number
---@return boolean
function Details222.BreakdownWindow.IsSpellExpanded(spellID)
	return Details222.BreakdownWindow.ExpandedSpells[spellID]
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
function breakdownWindow.SetClassIcon(actorObject, class)
	if (actorObject.spellicon) then
		breakdownWindow.classIcon:SetTexture(actorObject.spellicon)
		breakdownWindow.classIcon:SetTexCoord(.1, .9, .1, .9)

	elseif (actorObject.spec) then
		breakdownWindow.classIcon:SetTexture([[Interface\AddOns\Details\images\spec_icons_normal_alpha]])
		breakdownWindow.classIcon:SetTexCoord(unpack(_detalhes.class_specs_coords [actorObject.spec]))
	else
		local coords = CLASS_ICON_TCOORDS[class]
		if (coords) then
			breakdownWindow.classIcon:SetTexture([[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-CLASSES]])
			local l, r, t, b = unpack(coords)
			breakdownWindow.classIcon:SetTexCoord(l+0.01953125, r-0.01953125, t+0.01953125, b-0.01953125)
		else
			local c = _detalhes.class_coords ["MONSTER"]
			breakdownWindow.classIcon:SetTexture("Interface\\AddOns\\Details\\images\\classes")
			breakdownWindow.classIcon:SetTexCoord(c[1], c[2], c[3], c[4])
		end
	end
end

function Details:SetBreakdownWindowBackgroundTexture(texture)
	breakdownWindow.backgroundTexture:SetTexture(texture)
end

--search key: ~create ~inicio ~start
function Details:CreateBreakdownWindow()
	table.insert(UISpecialFrames, breakdownWindow:GetName())
	breakdownWindow.extra_frames = {}
	breakdownWindow.Loaded = true
	Details.playerDetailWindow = breakdownWindow

	breakdownWindow:SetWidth(PLAYER_DETAILS_WINDOW_WIDTH)
	breakdownWindow:SetHeight(PLAYER_DETAILS_WINDOW_HEIGHT)
	breakdownWindow:SetFrameStrata("HIGH")
	breakdownWindow:SetToplevel(true)
	breakdownWindow:EnableMouse(true)
	breakdownWindow:SetResizable(true)
	breakdownWindow:SetMovable(true)
	breakdownWindow:SetClampedToScreen(true)

	--make the window movable
	if (not breakdownWindow.registeredLibWindow) then
		local LibWindow = LibStub("LibWindow-1.1")
		breakdownWindow.registeredLibWindow = true
		if (LibWindow) then
			breakdownWindow.libWindowTable = breakdownWindow.libWindowTable or {}
			LibWindow.RegisterConfig(breakdownWindow, breakdownWindow.libWindowTable)
			LibWindow.RestorePosition(breakdownWindow)
			LibWindow.MakeDraggable(breakdownWindow)
			LibWindow.SavePosition(breakdownWindow)

			breakdownWindow:SetScript("OnMouseDown", function(self, button)
				if (button == "RightButton") then
					Details:CloseBreakdownWindow()
				end
			end)
		end
	end

	detailsFramework:ApplyStandardBackdrop(breakdownWindow)

	--background
	breakdownWindow.backgroundTexture = breakdownWindow:CreateTexture("$parent", "background", nil, -3)
	breakdownWindow.backgroundTexture:SetAllPoints()
	breakdownWindow.backgroundTexture:Hide()

	--host the textures and fontstring of the default frame of the player breakdown window
	--what is the summary window: is the frame where all the widgets for the summary tab are created
	breakdownWindow.SummaryWindowWidgets = CreateFrame("frame", "DetailsBreakdownWindowSummaryWidgets", breakdownWindow, "BackdropTemplate")
	local SWW = breakdownWindow.SummaryWindowWidgets
	SWW:SetAllPoints()
	table.insert(SummaryWidgets, SWW) --where SummaryWidgets is declared: at the header of the file, what is the purpose of this table?
	breakdownWindow.SummaryWindowWidgets:Hide()

	detailsFramework:CreateScaleBar(breakdownWindow, Details.player_details_window)
	breakdownWindow:SetScale(Details.player_details_window.scale)

	--class icon
	breakdownWindow.classIcon = breakdownWindow:CreateTexture(nil, "overlay", nil, 1)
	breakdownWindow.classIcon:SetPoint("topleft", breakdownWindow, "topleft", 2, -17)
	breakdownWindow.classIcon:SetSize(54, 54)
	breakdownWindow.classIcon:SetAlpha(0.7)

	--close button
	breakdownWindow.closeButton = CreateFrame("Button", nil, breakdownWindow, "UIPanelCloseButton")
	breakdownWindow.closeButton:SetSize(20, 20)
	breakdownWindow.closeButton:SetPoint("TOPRIGHT", breakdownWindow, "TOPRIGHT", -5, -4)
	breakdownWindow.closeButton:SetFrameLevel(breakdownWindow:GetFrameLevel()+5)
	breakdownWindow.closeButton:GetNormalTexture():SetDesaturated(true)
	breakdownWindow.closeButton:GetNormalTexture():SetVertexColor(.6, .6, .6)
    breakdownWindow.closeButton:SetScript("OnClick", function(self)
        Details:CloseBreakdownWindow()
    end)

	--title
	detailsFramework:NewLabel(breakdownWindow, breakdownWindow, nil, "titleText", Loc ["STRING_PLAYER_DETAILS"], "GameFontHighlightLeft", 12, {227/255, 186/255, 4/255})
	breakdownWindow.titleText:SetPoint("center", breakdownWindow, "center")
	breakdownWindow.titleText:SetPoint("top", breakdownWindow, "top", 0, -6)

	--create the texts shown on the window
	do
		breakdownWindow.actorName = breakdownWindow:CreateFontString(nil, "overlay", "QuestFont_Large")
		breakdownWindow.actorName:SetPoint("left", breakdownWindow.classIcon, "right", 20, -7)

		breakdownWindow.attributeName = breakdownWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")

		breakdownWindow.avatar = breakdownWindow:CreateTexture(nil, "overlay")
		breakdownWindow.avatar_bg = breakdownWindow:CreateTexture(nil, "overlay")
		breakdownWindow.avatar_attribute = breakdownWindow:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
		breakdownWindow.avatar_nick = breakdownWindow:CreateFontString(nil, "overlay", "QuestFont_Large")
		breakdownWindow.avatar:SetDrawLayer("overlay", 3)
		breakdownWindow.avatar_bg:SetDrawLayer("overlay", 2)
		breakdownWindow.avatar_nick:SetDrawLayer("overlay", 4)

		breakdownWindow.avatar:SetPoint("TOPLEFT", breakdownWindow, "TOPLEFT", 60, -10)
		breakdownWindow.avatar_bg:SetPoint("TOPLEFT", breakdownWindow, "TOPLEFT", 60, -12)
		breakdownWindow.avatar_bg:SetSize(275, 60)

		breakdownWindow.avatar_nick:SetPoint("TOPLEFT", breakdownWindow, "TOPLEFT", 195, -54)

		breakdownWindow.avatar:Hide()
		breakdownWindow.avatar_bg:Hide()
		breakdownWindow.avatar_nick:Hide()
	end

	--statusbar
	local statusBar = CreateFrame("frame", nil, breakdownWindow, "BackdropTemplate")
	statusBar:SetPoint("bottomleft", breakdownWindow, "bottomleft")
	statusBar:SetPoint("bottomright", breakdownWindow, "bottomright")
	statusBar:SetHeight(PLAYER_DETAILS_STATUSBAR_HEIGHT)
	detailsFramework:ApplyStandardBackdrop(statusBar)
	statusBar:SetAlpha(PLAYER_DETAILS_STATUSBAR_ALPHA)
	breakdownWindow.statusBar = statusBar

	statusBar.Text = detailsFramework:CreateLabel(statusBar)
	statusBar.Text:SetPoint("left", 2, 0)

	--create the gradients in the top and bottom side of the breakdown window
	local gradientStartColor = Details222.ColorScheme.GetColorFor("gradient-background")
	local gradientUp = detailsFramework:CreateTexture(breakdownWindow, {gradient = "vertical", fromColor = gradientStartColor, toColor = {0, 0, 0, 0.2}}, 1, 68, "artwork", {0, 1, 0, 1})
	gradientUp:SetPoint("tops", 1, 1)

	local gradientHeight = 481
	local gradientDown = detailsFramework:CreateTexture(breakdownWindow, {gradient = "vertical", fromColor = "transparent", toColor = {0, 0, 0, 0.7}}, 1, gradientHeight, "border", {0, 1, 0, 1})
	gradientDown:SetPoint("bottomleft", breakdownWindow.statusBar, "topleft", 1, 1)
	gradientDown:SetPoint("bottomright", breakdownWindow.statusBar, "topright", -1, 1)

	function breakdownWindow:SetStatusbarText(text, fontSize, fontColor)
		if (not text) then
			breakdownWindow:SetStatusbarText("Details! Damage Meter | Use '/details stats' for statistics", 10, "gray")
			return
		end
		statusBar.Text.text = text
		statusBar.Text.fontsize = fontSize
		statusBar.Text.fontcolor = fontColor
	end

	--set default text
	breakdownWindow:SetStatusbarText()

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--tabs ~tabs
	function breakdownWindow:ShowTabs()
		local tabsShown = 0
		local secondRowIndex = 1
		local breakLine = 6 --the tab it'll start the second line

		local tablePool = Details:GetBreakdownTabsInUse()

		for index = 1, #tablePool do
			local tabButton = tablePool[index]

			if (tabButton:condition(breakdownWindow.jogador, breakdownWindow.atributo, breakdownWindow.sub_atributo) and not tabButton.replaced) then
				--test if can show the tutorial for the comparison tab
				if (tabButton.tabname == "Compare") then
					--Details:SetTutorialCVar ("DETAILS_INFO_TUTORIAL1", false)
					if (not Details:GetTutorialCVar("DETAILS_INFO_TUTORIAL1")) then
						Details:SetTutorialCVar ("DETAILS_INFO_TUTORIAL1", true)

						local alert = CreateFrame("frame", "DetailsInfoPopUp1", breakdownWindow, "DetailsHelpBoxTemplate")
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
				local buttonTemplate = gump:GetTemplate("button", "DETAILS_TAB_BUTTON_TEMPLATE")
				local buttonWidth = buttonTemplate.width + 1

				--pixelutil might not be compatible with classic wow
				if (PixelUtil) then
					PixelUtil.SetSize(tabButton, buttonTemplate.width, buttonTemplate.height)
					if (tabsShown >= breakLine) then --next row of icons
						PixelUtil.SetPoint(tabButton, "bottomright", breakdownWindow, "topright", -514 + (buttonWidth * (secondRowIndex)), -50)
						secondRowIndex = secondRowIndex + 1
					else
						PixelUtil.SetPoint(tabButton, "bottomright", breakdownWindow, "topright", -514 + (buttonWidth * tabsShown), -69)
					end
				else
					tabButton:SetSize(buttonTemplate.width, buttonTemplate.height)
					if (tabsShown >= breakLine) then --next row of icons
						tabButton:SetPoint("bottomright", breakdownWindow, "topright", -514 + (buttonWidth * (secondRowIndex)), -50)
						secondRowIndex = secondRowIndex + 1
					else
						tabButton:SetPoint("bottomright", breakdownWindow, "topright", -514 + (buttonWidth * tabsShown), -69)
					end
				end

				tabButton:SetAlpha(0.8)
			else
				tabButton.frame:Hide()
				tabButton:Hide()
			end
		end

		if (tabsShown < 2) then
			tablePool[1]:SetPoint("bottomleft", breakdownWindow.container_barras, "topleft", 490 - (94 * (1-0)), 1)
		end

		--selected by default
		tablePool[1]:Click()
	end

	breakdownWindow:SetScript("OnHide", function(self)
		Details:CloseBreakdownWindow()
		for _, tab in ipairs(Details.player_details_tabs) do
			tab:Hide()
			tab.frame:Hide()
		end
	end)

	breakdownWindow.tipo = 1 --tipo da janela // 1 = janela normal
	return breakdownWindow
end

breakdownWindow.selectedTab = "Summary"

function Details:CreatePlayerDetailsTab(tabName, locName, conditionFunc, fillFunc, tabOnClickFunc, onCreateFunc, iconSettings, replace, bIsDefaultTab) --~tab
	if (not tabName) then
		tabName = "unnamed"
	end

	--create a button to select the tab
	local tabButton = detailsFramework:CreateButton(breakdownWindow, function()end, 20, 20, locName, nil, nil, nil, nil, breakdownWindow:GetName() .. "TabButton" .. tabName .. math.random(1, 1000), nil, "DETAILS_TAB_BUTTON_TEMPLATE")
	tabButton:SetFrameLevel(breakdownWindow:GetFrameLevel()+1)
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
	local tabFrame = CreateFrame("frame", breakdownWindow:GetName() .. "TabFrame" .. tabName .. math.random(1, 10000), breakdownWindow, "BackdropTemplate")
	tabFrame:SetFrameLevel(breakdownWindow:GetFrameLevel()+1)
	tabFrame:SetPoint("topleft", breakdownWindow, "topleft", 0, -70)
	tabFrame:SetPoint("bottomright", breakdownWindow, "bottomright", -1, 20)
	tabFrame:Hide()

	DetailsFramework:ApplyStandardBackdrop(tabFrame)
	tabFrame:SetBackdropBorderColor(0, 0, 0, 0.3)
	tabFrame.__background:SetAlpha(0.3)
	tabFrame.RightEdge:Hide()

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
		breakdownWindow.selectedTab = self.tabname
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
		CurrentTab = self.tabname or self.MyObject.tabname

		if (CurrentTab ~= "Summary") then
			for _, widget in ipairs(SummaryWidgets) do
				widget:Hide()
			end
		else
			for _, widget in ipairs(SummaryWidgets) do
				widget:Show()
			end
		end
	end)

	return tabButton, tabFrame
end