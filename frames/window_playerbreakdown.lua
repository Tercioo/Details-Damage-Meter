
local _detalhes = _G._detalhes
local Loc = LibStub("AceLocale-3.0"):GetLocale ( "Details" )
local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")

local gump = 			_detalhes.gump
local _
local addonName, Details222 = ...

--lua locals
local ipairs = ipairs
local pairs = pairs
local type = type
local unpack = unpack

--api locals
local CreateFrame = CreateFrame
local GetTime = GetTime
local _GetSpellInfo = _detalhes.getspellinfo
local _GetCursorPosition = GetCursorPosition
local GameTooltip = GameTooltip

local sub_atributos = _detalhes.sub_atributos
local info = _detalhes.playerDetailWindow
local breakdownWindow = info
local container3_bars_pointFunc

local SummaryWidgets = {}
local CurrentTab = "Summary"

local CONST_BAR_HEIGHT = 20
local CONST_TARGET_HEIGHT = 18

local PLAYER_DETAILS_WINDOW_WIDTH = 890
local PLAYER_DETAILS_WINDOW_HEIGHT = 574

local PLAYER_DETAILS_STATUSBAR_HEIGHT = 20
local PLAYER_DETAILS_STATUSBAR_ALPHA = 1

local containerSettings = {
	spells = {
		width = 419,
		height = 290,
		point = {"TOPLEFT", breakdownWindow, "TOPLEFT", 2, -76},
		scrollHeight = 264,
	},
	targets = {
		width = 418,
		height = 150,
		point = {"BOTTOMLEFT", breakdownWindow, "BOTTOMLEFT", 2, 6 + PLAYER_DETAILS_STATUSBAR_HEIGHT},
	},
}

local spellInfoSettings = {
	width = 430,
	amount = 6,
}

_detalhes.player_details_tabs = {}
info.currentTabsInUse =  {}

------------------------------------------------------------------------------------------------------------------------------
--self = instancia
--jogador = classe_damage ou classe_heal

do
	local gradientStartColor = Details222.ColorScheme.GetColorFor("gradient-background")
	local gradientUp = DetailsFramework:CreateTexture(info, {gradient = "vertical", fromColor = "transparent", toColor = gradientStartColor}, 1, 300, "artwork", {0, 1, 0, 1})
	gradientUp:SetPoint("tops", 1, 1)
	local gradientDown = DetailsFramework:CreateTexture(info, {gradient = "vertical", fromColor = gradientStartColor, toColor = "transparent"}, 1, 50, "artwork", {0, 1, 0, 1})
	gradientDown:SetPoint("bottoms")
end

function Details:GetBreakdownTabsInUse()
	return info.currentTabsInUse
end

function Details:GetBreakdownTabByName(tabName, tablePool)
	tablePool = tablePool or _detalhes.player_details_tabs
	for index = 1, #tablePool do
		local tab = tablePool[index]
		if (tab.tabname == tabName) then
			return tab, index
		end
	end
end

--return the combat being used to show the data in the opened breakdown window
function Details:GetCombatFromBreakdownWindow()
	return info.instancia and info.instancia.showing
end

--return the window that requested to open the player breakdown window
function Details:GetActiveWindowFromBreakdownWindow()
	return info.instancia
end

--return if the breakdown window is showing damage or heal
function Details:GetDisplayTypeFromBreakdownWindow()
	return info.atributo, info.sub_atributo
end

--return the actor object in use by the breakdown window
function Details:GetPlayerObjectFromBreakdownWindow()
	return info.jogador
end

function Details:GetBreakdownWindow()
	return Details.playerDetailWindow
end

function Details:IsBreakdownWindowOpen()
	return info.ativo
end

function Details222.PlayerBreakdown.StartMoving()
	breakdownWindow:StartMoving()
	breakdownWindow.bIsMoving = true
end

function Details222.PlayerBreakdown.StopMoving()
	if (breakdownWindow.bIsMoving) then
		breakdownWindow:StopMovingOrSizing()
		breakdownWindow.bIsMoving = false
	end
end

function Details222.PlayerBreakdown.OnMouseDown(frameClicked, button)
	if (button == "LeftButton" and not breakdownWindow.bIsMoving) then
		breakdownWindow.latestFrameClicked = frameClicked
		Details222.PlayerBreakdown.StartMoving()

	elseif (button == "RightButton" and not breakdownWindow.bIsMoving) then
		Details:CloseBreakdownWindow()
	end
end

function Details222.PlayerBreakdown.OnMouseUp(button)
	if (button == "LeftButton" and breakdownWindow.bIsMoving) then
		Details222.PlayerBreakdown.StopMoving()
	end
end

--english alias
--window object from Details:GetWindow(n) and playerObject from Details:GetPlayer(playerName, attribute)
function Details:OpenPlayerBreakdown(windowObject, playerObject, from_att_change) --windowObject = instanceObject
	windowObject:AbreJanelaInfo(playerObject, from_att_change)
end

function _detalhes:AbreJanelaInfo (jogador, from_att_change, refresh, ShiftKeyDown, ControlKeyDown)
	--create the player list frame in the left side of the window
	Details.PlayerBreakdown.CreatePlayerListFrame()

	if (not _detalhes.row_singleclick_overwrite [self.atributo] or not _detalhes.row_singleclick_overwrite [self.atributo][self.sub_atributo]) then
		_detalhes:FechaJanelaInfo()
		return

	elseif (type(_detalhes.row_singleclick_overwrite [self.atributo][self.sub_atributo]) == "function") then
		if (from_att_change) then
			_detalhes:FechaJanelaInfo()
			return
		end
		return _detalhes.row_singleclick_overwrite [self.atributo][self.sub_atributo] (_, jogador, self, ShiftKeyDown, ControlKeyDown)
	end

	if (self.modo == _detalhes._detalhes_props["MODO_RAID"]) then
		_detalhes:FechaJanelaInfo()
		return
	end

	if (not breakdownWindow.registeredLibWindow) then
		local LibWindow = LibStub("LibWindow-1.1")
		breakdownWindow.registeredLibWindow = true
		if (LibWindow) then
			breakdownWindow.libWindowTable = breakdownWindow.libWindowTable or {}
			LibWindow.RegisterConfig(breakdownWindow, breakdownWindow.libWindowTable)
			LibWindow.RestorePosition(breakdownWindow)
			LibWindow.MakeDraggable(breakdownWindow)
			LibWindow.SavePosition(breakdownWindow)
		else
			breakdownWindow:SetScript("OnMouseDown", function(self, button)
				Details222.PlayerBreakdown.OnMouseDown(button)
			end)
			breakdownWindow:SetScript("OnMouseUp", function(self, button)
				Details222.PlayerBreakdown.OnMouseUp(button)
			end)
		end
	end

	---@type function
	local onEventFunction = breakdownWindow:GetScript("OnEvent")

	if (not onEventFunction) then
		---this is a workaround of an issue when a frame calls StartMoving() on the parent, many times the child doesn't receive the OnMouseUp event
		---@param breakdownWindow frame
		---@param event string
		---@param button string
		breakdownWindow:SetScript("OnEvent", function(breakdownWindow, event, button)
			if (breakdownWindow.bIsMoving and breakdownWindow.latestFrameClicked) then
				Details222.PlayerBreakdown.StopMoving()
				local OnMouseUp = breakdownWindow.latestFrameClicked:GetScript("OnMouseUp")
				if (OnMouseUp) then
					OnMouseUp(breakdownWindow.latestFrameClicked, button)
				end
				breakdownWindow.latestFrameClicked = nil
			end
		end)
		breakdownWindow:RegisterEvent("GLOBAL_MOUSE_UP")
	end

	--_detalhes.info_jogador armazena o jogador que esta sendo mostrado na janela de detalhes
	if (info.jogador and info.jogador == jogador and self and info.atributo and self.atributo == info.atributo and self.sub_atributo == info.sub_atributo and not refresh) then
		_detalhes:FechaJanelaInfo() --se clicou na mesma barra ent�o fecha a janela de detalhes
		return
	elseif (not jogador) then
		_detalhes:FechaJanelaInfo()
		return
	end

	if (info.barras1) then
		for index, barra in ipairs(info.barras1) do
			barra.other_actor = nil
		end
	end

	if (info.barras2) then
		for index, barra in ipairs(info.barras2) do
			barra.icone:SetTexture("")
			barra.icone:SetTexCoord(0, 1, 0, 1)
		end
	end

	if (not info.bHasInitialized) then
		local infoNumPoints = info:GetNumPoints()
		for i = 1, infoNumPoints do
			local point1, anchorObject, point2, x, y = info:GetPoint(i)
			if (not anchorObject) then
				info:ClearAllPoints()
			end
		end

		info:SetUserPlaced(false)
		info:SetDontSavePosition(true)

		local okay, errorText = pcall(function()
			info:SetPoint("center", _G.UIParent, "center", 0, 0)
		end)

		if (not okay) then
			info:ClearAllPoints()
			info:SetPoint("center", _G.UIParent, "center", 0, 0)
		end

		info.bHasInitialized = true
	end

	if (not info.RightSideBar) then
		info.RightSideBar = CreateFrame("frame", nil, info, "BackdropTemplate")
		info.RightSideBar:SetWidth(20)
		info.RightSideBar:SetPoint("topleft", info, "topright", 1, 0)
		info.RightSideBar:SetPoint("bottomleft", info, "bottomright", 1, 0)
		local rightSideBarAlpha = 0.75

		DetailsFramework:ApplyStandardBackdrop(info.RightSideBar)

		local toggleMergePlayerSpells = function()
			Details.merge_player_abilities = not Details.merge_player_abilities
			local playerObject = Details:GetPlayerObjectFromBreakdownWindow()
			local instanceObject = Details:GetActiveWindowFromBreakdownWindow()
			Details:OpenPlayerBreakdown(instanceObject, playerObject) --toggle
			Details:OpenPlayerBreakdown(instanceObject, playerObject)
		end
		local mergePlayerSpellsCheckbox = DetailsFramework:CreateSwitch(info, toggleMergePlayerSpells, Details.merge_player_abilities, _, _, _, _, _, _, _, _, _, _, DetailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
		mergePlayerSpellsCheckbox:SetAsCheckBox()
		mergePlayerSpellsCheckbox:SetPoint("bottom", info.RightSideBar, "bottom", 0, 2)

		local mergePlayerSpellsLabel = info.RightSideBar:CreateFontString(nil, "overlay", "GameFontNormal")
		mergePlayerSpellsLabel:SetText("Merge Player Spells")
		DetailsFramework:SetFontRotation(mergePlayerSpellsLabel, 90)
		mergePlayerSpellsLabel:SetPoint("center", mergePlayerSpellsCheckbox.widget, "center", -6, mergePlayerSpellsCheckbox:GetHeight()/2 + mergePlayerSpellsLabel:GetStringWidth() / 2)

		--

		local toggleMergePetSpells = function()
			Details.merge_pet_abilities = not Details.merge_pet_abilities
			local playerObject = Details:GetPlayerObjectFromBreakdownWindow()
			local instanceObject = Details:GetActiveWindowFromBreakdownWindow()
			Details:OpenPlayerBreakdown(instanceObject, playerObject) --toggle
			Details:OpenPlayerBreakdown(instanceObject, playerObject)
		end
		local mergePetSpellsCheckbox = DetailsFramework:CreateSwitch(info, toggleMergePetSpells, Details.merge_pet_abilities, _, _, _, _, _, _, _, _, _, _, DetailsFramework:GetTemplate("switch", "OPTIONS_CHECKBOX_BRIGHT_TEMPLATE"))
		mergePetSpellsCheckbox:SetAsCheckBox(true)
		mergePetSpellsCheckbox:SetPoint("bottom", info.RightSideBar, "bottom", 0, 160)

		local mergePetSpellsLabel = info.RightSideBar:CreateFontString(nil, "overlay", "GameFontNormal")
		mergePetSpellsLabel:SetText("Merge Pet Spells")
		DetailsFramework:SetFontRotation(mergePetSpellsLabel, 90)
		mergePetSpellsLabel:SetPoint("center", mergePetSpellsCheckbox.widget, "center", -6, mergePetSpellsCheckbox:GetHeight()/2 + mergePetSpellsLabel:GetStringWidth() / 2)

		mergePlayerSpellsCheckbox:SetAlpha(rightSideBarAlpha)
		mergePlayerSpellsLabel:SetAlpha(rightSideBarAlpha)
		mergePetSpellsCheckbox:SetAlpha(rightSideBarAlpha)
		mergePetSpellsLabel:SetAlpha(rightSideBarAlpha)
	end

	info.ativo = true --sinaliza o addon que a janela esta aberta
	info.atributo = self.atributo --instancia.atributo -> grava o atributo (damage, heal, etc)
	info.sub_atributo = self.sub_atributo --instancia.sub_atributo -> grava o sub atributo (damage done, dps, damage taken, etc)
	info.jogador = jogador --de qual jogador (objeto classe_damage)
	info.instancia = self --salva a refer�ncia da inst�ncia que pediu o info
	info.target_text = Loc ["STRING_TARGETS"] .. ":"
	info.target_member = "total"
	info.target_persecond = false

	info.mostrando = nil

	local nome = info.jogador.nome --nome do jogador
	local atributo_nome = sub_atributos[info.atributo].lista [info.sub_atributo] .. " " .. Loc ["STRING_ACTORFRAME_REPORTOF"] --// nome do atributo // precisa ser o sub atributo correto???

	--removendo o nome da realm do jogador
	if (nome:find("-")) then
		nome = nome:gsub(("-.*"), "")
	end

	if (info.instancia.atributo == 1 and info.instancia.sub_atributo == 6) then --enemy
		atributo_nome = sub_atributos [info.atributo].lista [1] .. " " .. Loc ["STRING_ACTORFRAME_REPORTOF"]
	end

	info.nome:SetText(nome)
	info.atributo_nome:SetText(atributo_nome)

	local serial = jogador.serial
	local avatar
	if (serial ~= "") then
		avatar = NickTag:GetNicknameTable (serial)
	end

	if (avatar and avatar [1]) then
		info.nome:SetText((not _detalhes.ignore_nicktag and avatar [1]) or nome)
	end

	if (avatar and avatar [2]) then
		info.avatar:SetTexture(avatar [2])
		info.avatar_bg:SetTexture(avatar [4])
		if (avatar [5]) then
			info.avatar_bg:SetTexCoord(unpack(avatar [5]))
		end
		if (avatar [6]) then
			info.avatar_bg:SetVertexColor(unpack(avatar [6]))
		end

		info.avatar_nick:SetText(avatar [1] or nome)
		info.avatar_attribute:SetText(atributo_nome)

		info.avatar_attribute:SetPoint("CENTER", info.avatar_nick, "CENTER", 0, 14)
		info.avatar:Show()
		info.avatar_bg:Show()
		info.avatar_bg:SetAlpha(.65)
		info.avatar_nick:Show()
		info.avatar_attribute:Show()
		info.nome:Hide()
		info.atributo_nome:Hide()
	else
		info.avatar:Hide()
		info.avatar_bg:Hide()
		info.avatar_nick:Hide()
		info.avatar_attribute:Hide()

		info.nome:Show()
		info.atributo_nome:Show()
	end

	info.atributo_nome:SetPoint("CENTER", info.nome, "CENTER", 0, 14)

	--need a way to comunicate with the main tab showing spells
	--need to send a signal to reset its contents and prepare for a new player
	--spellsTab.ResetBars()

	local classe = jogador.classe

	if (not classe) then
		classe = "monster"
	end

	info.classe_icone:SetTexture("Interface\\AddOns\\Details\\images\\classes") --top left
	info.SetClassIcon (jogador, classe)

	Details.FadeHandler.Fader(info, 0)
	Details:UpdateBreakdownPlayerList()
	Details:InitializeAurasTab()
	Details:InitializeCompareTab()

	--open tab
	local tabsShown = {}
	local tabsReplaced = {}
	local tabReplacedAmount = 0

	table.wipe(info.currentTabsInUse)

	for index = 1, #_detalhes.player_details_tabs do
		local tab = _detalhes.player_details_tabs[index]
		tab.replaced = nil
		tabsShown[#tabsShown+1] = tab
	end

	for index = 1, #tabsShown do
		--get the tab
		local tab = tabsShown[index]

		if (tab.replaces) then
			local attributeList = tab.replaces.attributes
			if (attributeList[info.atributo]) then
				if (attributeList[info.atributo][info.sub_atributo]) then
					local tabReplaced, tabIndex = Details:GetBreakdownTabByName(tab.replaces.tabNameToReplace, tabsShown)
					if (tabReplaced and tabIndex < index) then
						tabReplaced:Hide()
						tabReplaced.frame:Hide()
						tinsert(tabsReplaced, tabReplaced)
						tremove(tabsShown, tabIndex)
						tinsert(tabsShown, tabIndex, tab)

						if (tabReplaced.tabname == info.selectedTab) then
							info.selectedTab = tab.tabname
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
	info.currentTabsInUse = newTabsShown

	info:ShowTabs()
	Details222.BreakdownWindow.CurrentDefaultTab = nil

	local shownTab
	for index = 1, #tabsShown do
		local tabButton = tabsShown[index]
		if (tabButton:condition(info.jogador, info.atributo, info.sub_atributo)) then
			if (tabButton.IsDefaultTab) then
				Details222.BreakdownWindow.CurrentDefaultTab = tabButton
			end

			if (info.selectedTab == tabButton.tabname) then
				tabButton:DoClick()
				tabButton:OnShowFunc()
				shownTab = tabButton
			end
		end
	end

	if (shownTab) then
		shownTab:Click()
	end
end --end of "AbreJanelaInfo()"


--alias
function Details:CloseBreakdownWindow(bFromEscape)
	return _detalhes:FechaJanelaInfo(bFromEscape)
end

function _detalhes:FechaJanelaInfo(fromEscape)
	if (info.ativo) then
		if (fromEscape) then
			Details.FadeHandler.Fader(info, "in")
		else
			Details.FadeHandler.Fader(info, 1)
		end
		info.ativo = false --sinaliza o addon que a janela esta agora fechada

		--_detalhes.info_jogador.detalhes = nil
		info.jogador = nil
		info.atributo = nil
		info.sub_atributo = nil
		info.instancia = nil

		info.nome:SetText("")
		info.atributo_nome:SetText("")
	end
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

--determina qual a pocis�o que a barra de detalhes vai ocupar
------------------------------------------------------------------------------------------------------------------------------
--namespace
function Details222.BreakdownWindow.GetBlockIndex(index) --getting the infomation from the new spells tab, this will be depreccated soon
	return Details.playerDetailWindow.grupos_detalhes[index]
end

---receives spell data to show in the summary tab
---@param data table
---@param actorObject actor
---@param combatObject combat
---@param instance instance
function Details222.BreakdownWindow.SendSpellData(data, actorObject, combatObject, instance)
	--need to get the tab showing the summary and transmit the data to it
	local tab = Details222.BreakdownWindow.CurrentDefaultTab
	if (tab) then
		--tab is the tab button
		if (tab.OnReceiveSpellData) then
			tab.OnReceiveSpellData(data, actorObject, combatObject, instance)
		end
	end
end

--cria os textos em geral da janela info
function breakdownWindow.CreateTexts(SWW)
	breakdownWindow.nome = breakdownWindow:CreateFontString(nil, "OVERLAY", "QuestFont_Large")
	breakdownWindow.nome:SetPoint("TOPLEFT", breakdownWindow, "TOPLEFT", 105, -54)

	breakdownWindow.atributo_nome = breakdownWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")

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


local default_icon_change = function(jogador, classe)
	if (classe ~= "UNKNOW" and classe ~= "UNGROUPPLAYER") then
		info.classe_icone:SetTexCoord(_detalhes.class_coords [classe][1], _detalhes.class_coords [classe][2], _detalhes.class_coords [classe][3], _detalhes.class_coords [classe][4])
		if (jogador.enemy) then
			if (_detalhes.faction_against == "Horde") then
				info.nome:SetTextColor(1, 91/255, 91/255, 1)
			else
				info.nome:SetTextColor(151/255, 215/255, 1, 1)
			end
		else
			info.nome:SetTextColor(1, 1, 1, 1)
		end
	else
		if (jogador.enemy) then
			if (_detalhes.class_coords [_detalhes.faction_against]) then
				info.classe_icone:SetTexCoord(unpack(_detalhes.class_coords [_detalhes.faction_against]))
				if (_detalhes.faction_against == "Horde") then
					info.nome:SetTextColor(1, 91/255, 91/255, 1)
				else
					info.nome:SetTextColor(151/255, 215/255, 1, 1)
				end
			else
				info.nome:SetTextColor(1, 1, 1, 1)
			end
		else
			info.classe_icone:SetTexCoord(_detalhes.class_coords ["MONSTER"][1], _detalhes.class_coords ["MONSTER"][2], _detalhes.class_coords ["MONSTER"][3], _detalhes.class_coords ["MONSTER"][4])
		end
	end
end

function _detalhes:InstallPDWSkin(skin_name, func)
	if (not skin_name) then
		return false -- sem nome
	elseif (_detalhes.playerdetailwindow_skins[skin_name]) then
		return false -- ja existe
	end

	_detalhes.playerdetailwindow_skins[skin_name] = func
	return true
end

function _detalhes:ApplyPDWSkin(skin_name)
--already built
	if (not DetailsBreakdownWindow.Loaded) then
		if (skin_name) then
			_detalhes.player_details_window.skin = skin_name
		end
		return
	end

--hide extra frames
	local window = DetailsBreakdownWindow
	if (window.extra_frames) then
		for framename, frame in pairs(window.extra_frames) do
			frame:Hide()
		end
	end

--apply default first
	local default_skin = _detalhes.playerdetailwindow_skins["WoWClassic"]
	pcall(default_skin.func)

--than do the change
	if (not skin_name) then
		skin_name = _detalhes.player_details_window.skin
	end

	local skin = _detalhes.playerdetailwindow_skins [skin_name]
	if (skin) then
		local successful, errortext = pcall(skin.func)
		if (not successful) then
			_detalhes:Msg("error occurred on skin call():", errortext)
			local former_skin = _detalhes.playerdetailwindow_skins [_detalhes.player_details_window.skin]
			pcall(former_skin.func)
		else
			_detalhes.player_details_window.skin = skin_name
		end
	else
		_detalhes:Msg("skin not found.")
	end

	if (info and info:IsShown() and info.jogador and info.jogador.classe) then
		info.SetClassIcon (info.jogador, info.jogador.classe)
	end

	_detalhes:ApplyRPSkin (skin_name)
end

function _detalhes:SetPlayerDetailsWindowTexture (texture)
	DetailsBreakdownWindow.bg1:SetTexture(texture)
end

function _detalhes:SetPDWBarConfig (texture)
	local window = DetailsBreakdownWindow

	if (texture) then
		_detalhes.player_details_window.bar_texture = texture
		local texture = SharedMedia:Fetch ("statusbar", texture)

		for _, bar in ipairs(window.barras1) do
			bar.textura:SetStatusBarTexture(texture)
		end
		for _, bar in ipairs(window.barras2) do
			bar.textura:SetStatusBarTexture(texture)
		end
		for _, bar in ipairs(window.barras3) do
			bar.textura:SetStatusBarTexture(texture)
		end
	end
end

local default_skin = function()end
_detalhes:InstallPDWSkin("WoWClassic", {func = default_skin, author = "Details! Team", version = "v1.0", desc = "Default skin."}) --deprecated

local elvui_skin = function()
	local window = DetailsBreakdownWindow
	window.bg1:SetTexture([[Interface\AddOns\Details\images\background]], true)
	window.bg1:SetAlpha(0.7)
	window.bg1:SetVertexColor(0.27, 0.27, 0.27)
	window.bg1:SetVertTile(true)
	window.bg1:SetHorizTile(true)
	window.bg1:SetSize(PLAYER_DETAILS_WINDOW_WIDTH, PLAYER_DETAILS_WINDOW_HEIGHT)

	window:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\AddOns\Details\images\background]]})
	window:SetBackdropColor(1, 1, 1, 0.3)
	window:SetBackdropBorderColor(0, 0, 0, 1)
	local bgs_alpha = 0.6

	window.leftbars1_backgound:SetPoint("topleft", window.container_barras, "topleft", -2, 3)
	window.leftbars1_backgound:SetPoint("bottomright", window.container_barras, "bottomright", 3, -3)
	window.leftbars2_backgound:SetPoint("topleft", window.container_alvos, "topleft", -2, 23)
	window.leftbars2_backgound:SetPoint("bottomright", window.container_alvos, "bottomright", 4, 0)

	window.leftbars1_backgound:SetAlpha(bgs_alpha)
	window.leftbars2_backgound:SetAlpha(bgs_alpha)

	window.right_background1:SetAlpha(bgs_alpha)
	window.right_background2:SetAlpha(bgs_alpha)
	window.right_background3:SetAlpha(bgs_alpha)
	window.right_background4:SetAlpha(bgs_alpha)
	window.right_background5:SetAlpha(bgs_alpha)

	window.close_button:GetNormalTexture():SetDesaturated(true)

	local titlebar = window.extra_frames ["ElvUITitleBar"]
	if (not titlebar) then
		titlebar = CreateFrame("frame", nil, window, "BackdropTemplate")
		titlebar:SetPoint("topleft", window, "topleft", 2, -3)
		titlebar:SetPoint("topright", window, "topright", -2, -3)
		titlebar:SetHeight(20)
		titlebar:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\AddOns\Details\images\background]], tileSize = 64, tile = true})
		titlebar:SetBackdropColor(.5, .5, .5, 1)
		titlebar:SetBackdropBorderColor(0, 0, 0, 1)
		window.extra_frames ["ElvUITitleBar"] = titlebar

		local name_bg_texture = window:CreateTexture(nil, "background")
		name_bg_texture:SetTexture([[Interface\PetBattles\_PetBattleHorizTile]], true)
		name_bg_texture:SetHorizTile(true)
		name_bg_texture:SetTexCoord(0, 1, 126/256, 19/256)
		name_bg_texture:SetPoint("topleft", window, "topleft", 2, -22)
		--name_bg_texture:SetPoint("topright", window, "topright", -2, -22)
		name_bg_texture:SetPoint("bottomright", window, "bottomright")
		name_bg_texture:SetHeight(54)
		name_bg_texture:SetVertexColor(0, 0, 0, 0.2)
		window.extra_frames ["ElvUINameTexture"] = name_bg_texture
	else
		titlebar:Show()
		window.extra_frames ["ElvUINameTexture"]:Show()
	end

	window.title_string:ClearAllPoints()
	window.title_string:SetPoint("center", window, "center")
	window.title_string:SetPoint("top", window, "top", 0, -7)
	window.title_string:SetParent(titlebar)
	window.title_string:SetTextColor(.8, .8, .8, 1)

	window.classe_icone:SetParent(titlebar)
	window.classe_icone:SetDrawLayer("overlay")
	window.classe_icone:SetPoint("TOPLEFT", window, "TOPLEFT", 2, -25)
	window.classe_icone:SetWidth(49)
	window.classe_icone:SetHeight(49)
	window.classe_icone:SetAlpha(1)

	window.close_button:SetWidth(20)
	window.close_button:SetHeight(20)
	window.close_button:SetPoint("TOPRIGHT", window, "TOPRIGHT", 0, -3)


	window.avatar:SetParent(titlebar)

	--bar container
	window.container_barras:SetPoint(unpack(containerSettings.spells.point))
	window.container_barras:SetSize(containerSettings.spells.width, containerSettings.spells.height)

	--target container
	window.container_alvos:SetPoint(unpack(containerSettings.targets.point))
	window.container_alvos:SetSize(containerSettings.targets.width, containerSettings.targets.height)

	--texts
	window.nome:SetPoint("TOPLEFT", window, "TOPLEFT", 105, -48)

	--report button
	window.topleft_report:SetPoint("BOTTOMLEFT", window.container_barras, "TOPLEFT",  43, 2)

	--no targets texture
	window.no_targets:SetPoint("BOTTOMLEFT", window, "BOTTOMLEFT", 3, 6)
	window.no_targets:SetSize(418, 150)
	window.no_targets:SetAlpha(0.4)

	--right panel textures
	window.bg2_sec_texture:SetPoint("topleft", window.bg1_sec_texture, "topleft", 7, 0)
	window.bg2_sec_texture:SetPoint("bottomright", window.bg1_sec_texture, "bottomright", -30, 0)
	window.bg2_sec_texture:SetTexture([[Interface\Glues\CREDITS\Warlords\Shadowmoon_Color_jlo3]])
	window.bg2_sec_texture:SetDesaturated(true)
	window.bg2_sec_texture:SetAlpha(0)

	window.bg3_sec_texture:SetPoint("topleft", window.bg2_sec_texture, "topleft", 0, 0)
	window.bg3_sec_texture:SetPoint("bottomright", window.bg2_sec_texture, "bottomright", 0, 0)
	window.bg3_sec_texture:SetTexture(0, 0, 0, 0.3)

	--the 5 spell details blocks - not working
	for i, infoblock in ipairs(_detalhes.playerDetailWindow.grupos_detalhes) do
		infoblock.bg:SetSize(330, 47)
	end
	local xLocation = {-85, -136, -191, -246, -301}
	local heightTable = {50, 50, 50, 50, 50, 48}

	for i = 1, spellInfoSettings.amount do
		window ["right_background" .. i]:SetPoint("topleft", window, "topleft", 351, xLocation [i])
		window ["right_background" .. i]:SetSize(spellInfoSettings.width, heightTable [i])

	end

	--seta configs dos 5 blocos da direita
	info:SetDetailInfoConfigs("Interface\\AddOns\\Details\\images\\bar_background_dark", {1, 1, 1, 0.35}, -6 + 100, 0)

	window.bg1_sec_texture:SetPoint("topleft", window.bg1, "topleft", 446, -86)
	window.bg1_sec_texture:SetWidth(337)
	window.bg1_sec_texture:SetHeight(362)

	--container 3 bars
	local x_start = 56
	local y_start = -10

	local janela = window.container_detalhes

	container3_bars_pointFunc = function(barra, index)
		local y = (index-1) * 17
		y = y*-1

		barra:SetPoint("LEFT", info.bg1_sec_texture, "LEFT", 0, 0)
		barra:SetPoint("RIGHT", info.bg1_sec_texture, "RIGHT", 0, 0)

		--barra:SetPoint("LEFT", janela, "LEFT", x_start, 0)
		--barra:SetPoint("RIGHT", janela, "RIGHT", 62, 0)
		barra:SetPoint("TOP", janela, "TOP", 0, y+y_start)
	end

	for index, barra in ipairs(window.barras3) do
		local y = (index-1) * 17
		y = y*-1
		barra:SetPoint("LEFT", janela, "LEFT", x_start, 0)
		barra:SetPoint("RIGHT", janela, "RIGHT", 62, 0)
		barra:SetPoint("TOP", janela, "TOP", 0, y+y_start)
	end

	--scrollbar
	do
		--get textures
		local normalTexture = window.container_barras.cima:GetNormalTexture()
		local pushedTexture = window.container_barras.cima:GetPushedTexture()
		local disabledTexture = window.container_barras.cima:GetDisabledTexture()

		--set the new textures
		normalTexture:SetTexture([[Interface\Buttons\Arrow-Up-Up]])
		pushedTexture:SetTexture([[Interface\Buttons\Arrow-Up-Down]])
		disabledTexture:SetTexture([[Interface\Buttons\Arrow-Up-Disabled]])

		normalTexture:SetPoint("topleft", window.container_barras.cima, "topleft", 1, 0)
		normalTexture:SetPoint("bottomright", window.container_barras.cima, "bottomright", 1, 0)
		pushedTexture:SetPoint("topleft", window.container_barras.cima, "topleft", 1, 0)
		pushedTexture:SetPoint("bottomright", window.container_barras.cima, "bottomright", 1, 0)
		disabledTexture:SetPoint("topleft", window.container_barras.cima, "topleft", 1, 0)
		disabledTexture:SetPoint("bottomright", window.container_barras.cima, "bottomright", 1, 0)

		disabledTexture:SetAlpha(0.5)

		window.container_barras.cima:SetSize(16, 16)
		window.container_barras.cima:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\AddOns\Details\images\background]]})
		window.container_barras.cima:SetBackdropColor(0, 0, 0, 0.3)
		window.container_barras.cima:SetBackdropBorderColor(0, 0, 0, 1)
	end

	do
		--get textures
		local normalTexture = window.container_barras.baixo:GetNormalTexture()
		local pushedTexture = window.container_barras.baixo:GetPushedTexture()
		local disabledTexture = window.container_barras.baixo:GetDisabledTexture()

		--set the new textures
		normalTexture:SetTexture([[Interface\Buttons\Arrow-Down-Up]])
		pushedTexture:SetTexture([[Interface\Buttons\Arrow-Down-Down]])
		disabledTexture:SetTexture([[Interface\Buttons\Arrow-Down-Disabled]])

		normalTexture:SetPoint("topleft", window.container_barras.baixo, "topleft", 1, -4)
		normalTexture:SetPoint("bottomright", window.container_barras.baixo, "bottomright", 1, -4)

		pushedTexture:SetPoint("topleft", window.container_barras.baixo, "topleft", 1, -4)
		pushedTexture:SetPoint("bottomright", window.container_barras.baixo, "bottomright", 1, -4)

		disabledTexture:SetPoint("topleft", window.container_barras.baixo, "topleft", 1, -4)
		disabledTexture:SetPoint("bottomright", window.container_barras.baixo, "bottomright", 1, -4)

		disabledTexture:SetAlpha(0.5)

		window.container_barras.baixo:SetSize(16, 16)
		window.container_barras.baixo:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\AddOns\Details\images\background]]})
		window.container_barras.baixo:SetBackdropColor(0, 0, 0, 0.3)
		window.container_barras.baixo:SetBackdropBorderColor(0, 0, 0, 1)
	end

	window.container_barras.slider:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\AddOns\Details\images\background]]})
	window.container_barras.slider:SetBackdropColor(0, 0, 0, 0.35)
	window.container_barras.slider:SetBackdropBorderColor(0, 0, 0, 1)

	window.container_barras.slider:Altura (containerSettings.spells.scrollHeight)
	window.container_barras.slider:cimaPoint (0, 13)
	window.container_barras.slider:baixoPoint (0, -13)

	window.container_barras.slider.thumb:SetTexture([[Interface\AddOns\Details\images\icons2]])
	window.container_barras.slider.thumb:SetTexCoord(482/512, 492/512, 104/512, 120/512)
	window.container_barras.slider.thumb:SetSize(12, 12)
	window.container_barras.slider.thumb:SetVertexColor(0.6, 0.6, 0.6, 0.95)

	--


	do
		local f = window.container_alvos

		--get textures
		local normalTexture = f.cima:GetNormalTexture()
		local pushedTexture = f.cima:GetPushedTexture()
		local disabledTexture = f.cima:GetDisabledTexture()

		--set the new textures
		normalTexture:SetTexture([[Interface\Buttons\Arrow-Up-Up]])
		pushedTexture:SetTexture([[Interface\Buttons\Arrow-Up-Down]])
		disabledTexture:SetTexture([[Interface\Buttons\Arrow-Up-Disabled]])

		normalTexture:SetPoint("topleft", f.cima, "topleft", 1, 0)
		normalTexture:SetPoint("bottomright", f.cima, "bottomright", 1, 0)
		pushedTexture:SetPoint("topleft", f.cima, "topleft", 1, 0)
		pushedTexture:SetPoint("bottomright", f.cima, "bottomright", 1, 0)
		disabledTexture:SetPoint("topleft", f.cima, "topleft", 1, 0)
		disabledTexture:SetPoint("bottomright", f.cima, "bottomright", 1, 0)

		disabledTexture:SetAlpha(0.5)

		f.cima:SetSize(16, 16)
		f.cima:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\AddOns\Details\images\background]]})
		f.cima:SetBackdropColor(0, 0, 0, 0.3)
		f.cima:SetBackdropBorderColor(0, 0, 0, 1)
	end

	do
		local f = window.container_alvos

		--get textures
		local normalTexture = f.baixo:GetNormalTexture()
		local pushedTexture = f.baixo:GetPushedTexture()
		local disabledTexture = f.baixo:GetDisabledTexture()

		--set the new textures
		normalTexture:SetTexture([[Interface\Buttons\Arrow-Down-Up]])
		pushedTexture:SetTexture([[Interface\Buttons\Arrow-Down-Down]])
		disabledTexture:SetTexture([[Interface\Buttons\Arrow-Down-Disabled]])

		normalTexture:SetPoint("topleft", f.baixo, "topleft", 1, -4)
		normalTexture:SetPoint("bottomright", f.baixo, "bottomright", 1, -4)

		pushedTexture:SetPoint("topleft", f.baixo, "topleft", 1, -4)
		pushedTexture:SetPoint("bottomright", f.baixo, "bottomright", 1, -4)

		disabledTexture:SetPoint("topleft", f.baixo, "topleft", 1, -4)
		disabledTexture:SetPoint("bottomright", f.baixo, "bottomright", 1, -4)

		disabledTexture:SetAlpha(0.5)

		f.baixo:SetSize(16, 16)
		f.baixo:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\AddOns\Details\images\background]]})
		f.baixo:SetBackdropColor(0, 0, 0, 0.3)
		f.baixo:SetBackdropBorderColor(0, 0, 0, 1)
	end

	window.container_alvos.slider:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\AddOns\Details\images\background]]})
	window.container_alvos.slider:SetBackdropColor(0, 0, 0, 0.35)
	window.container_alvos.slider:SetBackdropBorderColor(0, 0, 0, 1)

	window.container_alvos.slider:Altura (137)
	window.container_alvos.slider:cimaPoint (0, 13)
	window.container_alvos.slider:baixoPoint (0, -13)

	window.container_alvos.slider.thumb:SetTexture([[Interface\AddOns\Details\images\icons2]])
	window.container_alvos.slider.thumb:SetTexCoord(482/512, 492/512, 104/512, 120/512)
	window.container_alvos.slider.thumb:SetSize(12, 12)
	window.container_alvos.slider.thumb:SetVertexColor(0.6, 0.6, 0.6, 0.95)

	--class icon
	---set the spell, spec or class icon
	---@param actorObject actor
	---@param class string|nil
	window.SetClassIcon = function(actorObject, class)
		if (actorObject.spellicon) then
			window.classe_icone:SetTexture(actorObject.spellicon)
			window.classe_icone:SetTexCoord(.1, .9, .1, .9)

		elseif (actorObject.spec) then
			window.classe_icone:SetTexture([[Interface\AddOns\Details\images\spec_icons_normal_alpha]])
			window.classe_icone:SetTexCoord(unpack(_detalhes.class_specs_coords [actorObject.spec]))
			--esta_barra.icone_classe:SetVertexColor(1, 1, 1)
		else
			local coords = CLASS_ICON_TCOORDS[class]
			if (coords) then
				info.classe_icone:SetTexture([[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-CLASSES]])
				local l, r, t, b = unpack(coords)
				info.classe_icone:SetTexCoord(l+0.01953125, r-0.01953125, t+0.01953125, b-0.01953125)
			else

				local c = _detalhes.class_coords ["MONSTER"]
				info.classe_icone:SetTexture("Interface\\AddOns\\Details\\images\\classes")
				info.classe_icone:SetTexCoord(c[1], c[2], c[3], c[4])
			end
		end
	end
end



--search key: ~create ~inicio ~start
function gump:CriaJanelaInfo()
	local breakdownFrame = info
	table.insert(UISpecialFrames, breakdownFrame:GetName())
	breakdownFrame.extra_frames = {}
	breakdownFrame.Loaded = true
	Details.playerDetailWindow = breakdownFrame

	--stopped: started the skin merge with the window creation

	breakdownFrame:SetWidth(PLAYER_DETAILS_WINDOW_WIDTH)
	breakdownFrame:SetHeight(PLAYER_DETAILS_WINDOW_HEIGHT)
	breakdownFrame:SetFrameStrata("HIGH")
	breakdownFrame:SetToplevel(true)
	breakdownFrame:EnableMouse(true)
	breakdownFrame:SetResizable(false)
	breakdownFrame:SetMovable(true)

	--host the textures and fontstring of the default frame of the player breakdown window
	breakdownFrame.SummaryWindowWidgets = CreateFrame("frame", "DetailsBreakdownWindowSummaryWidgets", breakdownFrame, "BackdropTemplate")
	local SWW = breakdownFrame.SummaryWindowWidgets
	SWW:SetAllPoints()
	table.insert(SummaryWidgets, SWW) --where SummaryWidgets is declared: at the header of the file, what is the purpose of this table?
	--what is the summary window: is the frame where all the widgets for the summary tab are created

	DetailsFramework:CreateScaleBar(breakdownFrame, Details.player_details_window)
	breakdownFrame:SetScale(Details.player_details_window.scale)

	--class icon
	breakdownFrame.classe_icone = breakdownFrame:CreateTexture(nil, "BACKGROUND", nil, 1)
	breakdownFrame.classe_icone:SetPoint("TOPLEFT", breakdownFrame, "TOPLEFT", 4, 0)
	breakdownFrame.classe_icone:SetSize(64, 64)

	--background topleft?
	breakdownFrame.bg1 = breakdownFrame:CreateTexture("DetailsPSWBackground", "BORDER", nil, 1)
	breakdownFrame.bg1:SetPoint("TOPLEFT", breakdownFrame, "TOPLEFT", 0, 0)

	--close button
	breakdownFrame.close_button = CreateFrame("Button", nil, breakdownFrame, "UIPanelCloseButton")
	breakdownFrame.close_button:SetSize(32, 32)
	breakdownFrame.close_button:SetPoint("TOPRIGHT", breakdownFrame, "TOPRIGHT", 5, -8)
	breakdownFrame.close_button:SetText("X")
	breakdownFrame.close_button:SetFrameLevel(breakdownFrame:GetFrameLevel()+5)
    breakdownFrame.close_button:SetScript("OnClick", function(self)
        Details:CloseBreakdownWindow()
    end)

	--�cone da magia selecionada para mais detalhes (is this a window thing or tab thing?)
	--or this is even in use?

	--title
	DetailsFramework:NewLabel(breakdownFrame, breakdownFrame, nil, "title_string", Loc ["STRING_PLAYER_DETAILS"] .. " (|cFFFF8811Under Maintenance|r)", "GameFontHighlightLeft", 12, {227/255, 186/255, 4/255})
	breakdownFrame.title_string:SetPoint("center", breakdownFrame, "center")
	breakdownFrame.title_string:SetPoint("top", breakdownFrame, "top", 0, -18)

	breakdownFrame.topright_text1 = breakdownFrame:CreateFontString(nil, "overlay", "GameFontNormal")
	breakdownFrame.topright_text1:SetPoint("bottomright", breakdownFrame, "topright",  -18 - (94 * (1-1)), -36)
	breakdownFrame.topright_text1:SetJustifyH("right")
	DetailsFramework:SetFontSize(breakdownFrame.topright_text1, 10)

	breakdownFrame.topright_text2 = breakdownFrame:CreateFontString(nil, "overlay", "GameFontNormal")
	breakdownFrame.topright_text2:SetPoint("bottomright", breakdownFrame, "topright",  -18 - (94 * (1-1)), -48)
	breakdownFrame.topright_text2:SetJustifyH("right")
	DetailsFramework:SetFontSize(breakdownFrame.topright_text2, 10)

	--what goes in the top right text? - looks like it's not in use
	function breakdownFrame:SetTopRightTexts(text1, text2, size, color, font)
		if (text1) then
			breakdownFrame.topright_text1:SetText(text1)
		else
			breakdownFrame.topright_text1:SetText("")
		end

		if (text2) then
			breakdownFrame.topright_text2:SetText(text2)
		else
			breakdownFrame.topright_text2:SetText("")
		end

		if (size and type(size) == "number") then
			DetailsFramework:SetFontSize(breakdownFrame.topright_text1, size)
			DetailsFramework:SetFontSize(breakdownFrame.topright_text2, size)
		end

		if (color) then
			DetailsFramework:SetFontColor(breakdownFrame.topright_text1, color)
			DetailsFramework:SetFontColor(breakdownFrame.topright_text2, color)
		end

		if (font) then
			DetailsFramework:SetFontFace (breakdownFrame.topright_text1, font)
			DetailsFramework:SetFontFace (breakdownFrame.topright_text2, font)
		end
	end

	--create the texts shown on the window
	breakdownWindow.CreateTexts(SWW)

	breakdownFrame.SetClassIcon = default_icon_change

	--statusbar
	local statusBar = CreateFrame("frame", nil, breakdownFrame, "BackdropTemplate")
	statusBar:SetPoint("bottomleft", breakdownFrame, "bottomleft")
	statusBar:SetPoint("bottomright", breakdownFrame, "bottomright")
	statusBar:SetHeight(PLAYER_DETAILS_STATUSBAR_HEIGHT)
	DetailsFramework:ApplyStandardBackdrop(statusBar)
	statusBar:SetAlpha(PLAYER_DETAILS_STATUSBAR_ALPHA)

	statusBar.Text = DetailsFramework:CreateLabel(statusBar)
	statusBar.Text:SetPoint("left", 2, 0)

	function breakdownFrame:SetStatusbarText(text, fontSize, fontColor)
		if (not text) then
			breakdownFrame:SetStatusbarText("Details! Damage Meter | Use '/details stats' for statistics", 10, "gray")
			return
		end
		statusBar.Text.text = text
		statusBar.Text.fontsize = fontSize
		statusBar.Text.fontcolor = fontColor
	end

	--set default text
	breakdownFrame:SetStatusbarText()

	--apply default skin
	--_detalhes:ApplyPDWSkin()

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--tabs ~tabs
	function breakdownFrame:ShowTabs()
		local tabsShown = 0
		local secondRowIndex = 1
		local breakLine = 6 --the tab it'll start the second line

		local tablePool = Details:GetBreakdownTabsInUse()

		for index = 1, #tablePool do
			local tab = tablePool[index]

			if (tab:condition(info.jogador, info.atributo, info.sub_atributo) and not tab.replaced) then
				--test if can show the tutorial for the comparison tab
				if (tab.tabname == "Compare") then
					--_detalhes:SetTutorialCVar ("DETAILS_INFO_TUTORIAL1", false)
					if (not _detalhes:GetTutorialCVar("DETAILS_INFO_TUTORIAL1")) then
						_detalhes:SetTutorialCVar ("DETAILS_INFO_TUTORIAL1", true)

						local alert = CreateFrame("frame", "DetailsInfoPopUp1", info, "DetailsHelpBoxTemplate")
						alert.ArrowUP:Show()
						alert.ArrowGlowUP:Show()
						alert.Text:SetText(Loc ["STRING_INFO_TUTORIAL_COMPARISON1"])
						alert:SetPoint("bottom", tab.widget or tab, "top", 5, 28)
						alert:Show()
					end
				end

				tab:Show()
				tabsShown = tabsShown + 1

				tab:ClearAllPoints()

				--get the button width
				local buttonTemplate = gump:GetTemplate("button", "DETAILS_TAB_BUTTON_TEMPLATE")
				local buttonWidth = buttonTemplate.width + 1

				--pixelutil might not be compatible with classic wow
				if (PixelUtil) then
					PixelUtil.SetSize(tab, buttonTemplate.width, buttonTemplate.height)
					if (tabsShown >= breakLine) then --next row of icons
						PixelUtil.SetPoint(tab, "bottomright", info, "topright",  -514 + (buttonWidth * (secondRowIndex)), -50)
						secondRowIndex = secondRowIndex + 1
					else
						PixelUtil.SetPoint(tab, "bottomright", info, "topright",  -514 + (buttonWidth * tabsShown), -72)
					end
				else
					tab:SetSize(buttonTemplate.width, buttonTemplate.height)
					if (tabsShown >= breakLine) then --next row of icons
						tab:SetPoint("bottomright", info, "topright",  -514 + (buttonWidth * (secondRowIndex)), -50)
						secondRowIndex = secondRowIndex + 1
					else
						tab:SetPoint("bottomright", info, "topright", -514 + (buttonWidth * tabsShown), -72)
					end
				end

				tab:SetAlpha(0.8)
			else
				tab.frame:Hide()
				tab:Hide()
			end
		end

		if (tabsShown < 2) then
			tablePool[1]:SetPoint("BOTTOMLEFT", info.container_barras, "TOPLEFT",  490 - (94 * (1-0)), 1)
		end

		--selected by default
		tablePool[1]:Click()
	end
		breakdownFrame:SetScript("OnHide", function(self)
			_detalhes:FechaJanelaInfo()
			for _, tab in ipairs(_detalhes.player_details_tabs) do
				tab:Hide()
				tab.frame:Hide()
			end
		end)

	breakdownFrame.tipo = 1 --tipo da janela // 1 = janela normal
	return breakdownFrame
end

info.selectedTab = "Summary"

function _detalhes:CreatePlayerDetailsTab(tabName, locName, conditionFunc, fillFunc, tabOnClickFunc, onCreateFunc, iconSettings, replace, bIsDefaultTab) --~tab
	if (not tabName) then
		tabName = "unnamed"
	end

	--create a button for the tab
	--tabOnClickFunc
	local newTabButton = gump:CreateButton(info, function()end, 20, 20, nil, nil, nil, nil, nil, breakdownWindow:GetName() .. "TabButton" .. tabName .. math.random(1, 1000))
	newTabButton:SetTemplate("DETAILS_TAB_BUTTON_TEMPLATE")
	if (tabName == "Summary") then
		newTabButton:SetTemplate("DETAILS_TAB_BUTTONSELECTED_TEMPLATE")
	end

	newTabButton.IsDefaultTab = bIsDefaultTab

	newTabButton:SetText(locName)
	newTabButton:SetFrameStrata("HIGH")
	newTabButton:SetFrameLevel(info:GetFrameLevel()+1)
	newTabButton:Hide()

	newTabButton.condition = conditionFunc
	newTabButton.tabname = tabName
	newTabButton.localized_name = locName
	newTabButton.onclick = tabOnClickFunc
	newTabButton.fillfunction = fillFunc
	newTabButton.last_actor = {}

	---@type tabframe
	local tabFrame = CreateFrame("frame", breakdownWindow:GetName() .. "TabFrame" .. tabName .. math.random(1, 1000), UIParent, "BackdropTemplate")
	DetailsFramework:ApplyStandardBackdrop(tabFrame)
	newTabButton.tabFrame = tabFrame
	newTabButton.frame = tabFrame

	tabFrame:SetParent(info)
	tabFrame:SetFrameStrata("HIGH")
	tabFrame:SetFrameLevel(info:GetFrameLevel()+5)
	tabFrame:EnableMouse(true)
	tabFrame:SetPoint("topleft", breakdownWindow, "topleft", 0, -70)
	tabFrame:SetPoint("bottomright", breakdownWindow, "bottomright", 0, 20)
	tabFrame:Hide()

	if (iconSettings) then
		local texture = iconSettings.texture
		local coords = iconSettings.coords
		local width = iconSettings.width
		local height = iconSettings.height

		local overlay, textdistance, leftpadding, textheight, short_method --nil

		newTabButton:SetIcon (texture, width, height, "overlay", coords, overlay, textdistance, leftpadding, textheight, short_method)
		if (iconSettings.desaturated) then
			newTabButton.icon:SetDesaturated(true)
		end
	end

	if (newTabButton.fillfunction) then
		tabFrame:SetScript("OnShow", function()
			if (newTabButton.last_actor == info.jogador) then
				return
			end
			newTabButton.last_actor = info.jogador
			newTabButton:fillfunction(info.jogador, info.instancia.showing)
		end)
	end

	if (onCreateFunc) then
		onCreateFunc(newTabButton, tabFrame)
	end

	newTabButton.replaces = replace
	_detalhes.player_details_tabs[#_detalhes.player_details_tabs+1] = newTabButton

	local onTabClickCallback = function(self)
		self = self.MyObject or self

		for _, tab in ipairs(Details:GetBreakdownTabsInUse()) do
			tab.frame:Hide()
			tab:SetTemplate("DETAILS_TAB_BUTTON_TEMPLATE")
		end

		self:SetTemplate("DETAILS_TAB_BUTTONSELECTED_TEMPLATE")
		info.selectedTab = self.tabname
	end

	if (not tabOnClickFunc) then
		newTabButton.OnShowFunc = function(self)
			--hide all tab frames, reset the template on all tabs
			--then set the template on this tab and set as selected tab
			onTabClickCallback(self)
			--show the tab frame
			tabFrame:Show()
		end
		newTabButton:SetScript("OnClick", newTabButton.OnShowFunc)
	else
		--custom
		newTabButton.OnShowFunc = function(self)
			--hide all tab frames, reset the template on all tabs
			--then set the template on this tab and set as selected tab
			onTabClickCallback(self)

			--run onclick func
			local result, errorText = pcall(tabOnClickFunc, newTabButton, tabFrame)
			if (not result) then
				print("error on running tabOnClick function:", errorText)
			end
		end
		newTabButton:SetScript("OnClick", newTabButton.OnShowFunc)
	end

	function newTabButton:DoClick()
		self:GetScript("OnClick")(self)
	end

	newTabButton:SetScript("PostClick", function(self)
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

	return newTabButton, tabFrame
end