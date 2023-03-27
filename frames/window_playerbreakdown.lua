
local _detalhes = 		_G._detalhes
local Loc = LibStub("AceLocale-3.0"):GetLocale ( "Details" )
local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")

local gump = 			_detalhes.gump
local _
local addonName, Details222 = ...
--lua locals
--local _string_len = string.len
local _math_floor = math.floor
local ipairs = ipairs
local pairs = pairs
local type = type
--api locals
local CreateFrame = CreateFrame
local GetTime = GetTime
local _GetSpellInfo = _detalhes.getspellinfo
local _GetCursorPosition = GetCursorPosition
local _unpack = unpack

local atributos = _detalhes.atributos
local sub_atributos = _detalhes.sub_atributos

local info = _detalhes.playerDetailWindow
local classe_icones = _G.CLASS_ICON_TCOORDS
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
		point = {"TOPLEFT", DetailsPlayerDetailsWindow, "TOPLEFT", 2, -76},
		scrollHeight = 264,
	},
	targets = {
		width = 418,
		height = 150,
		point = {"BOTTOMLEFT", DetailsPlayerDetailsWindow, "BOTTOMLEFT", 2, 6 + PLAYER_DETAILS_STATUSBAR_HEIGHT},
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

	--passar os par�metros para dentro da tabela da janela.

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

	info.no_targets:Hide()
	info.no_targets.text:Hide()
	gump:TrocaBackgroundInfo (info)

	gump:HidaAllBarrasInfo()
	gump:HidaAllBarrasAlvo()
	gump:HidaAllDetalheInfo()

	gump:JI_AtualizaContainerBarras (-1)

	local classe = jogador.classe

	if (not classe) then
		classe = "monster"
	end

	--info.classe_icone:SetTexture("Interface\\AddOns\\Details\\images\\"..classe:lower()) --top left
	info.classe_icone:SetTexture("Interface\\AddOns\\Details\\images\\classes") --top left
	info.SetClassIcon (jogador, classe)

	if (_detalhes.player_details_window.skin == "WoWClassic") then
		if (jogador.grupo and IsInRaid() and not avatar) then
			for i = 1, GetNumGroupMembers() do
				local playerName, realmName = UnitName ("raid" .. i)
				if (realmName and realmName ~= "") then
					playerName = playerName .. "-" .. realmName
				end
				if (playerName == jogador.nome) then
					SetPortraitTexture (info.classe_icone, "raid" .. i)
					info.classe_icone:SetTexCoord(0, 1, 0, 1)
					break
				end
			end
		end
	end

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

	local shownTab
	for index = 1, #tabsShown do
		local tab = tabsShown[index]
		if (tab:condition(info.jogador, info.atributo, info.sub_atributo)) then
			if (info.selectedTab == tab.tabname) then
				tabsShown[index]:Click()
				tabsShown[index]:OnShowFunc()
				shownTab = tabsShown[index]
			end
		end
	end

	if (shownTab) then
		shownTab:Click()
	end
end --end of "AbreJanelaInfo()"

-- for beta todo: info background need a major rewrite
function gump:TrocaBackgroundInfo() --> spells tab
	info.bg3_sec_texture:Hide()
	info.bg2_sec_texture:Hide()

	info.apoio_icone_esquerdo:Show()
	info.apoio_icone_direito:Show()

	info.report_direita:Hide()

	for i = 1, spellInfoSettings.amount do
		info ["right_background" .. i]:Show()
	end

	if (info.atributo == 1) then --DANO

		if (info.sub_atributo == 1 or info.sub_atributo == 2) then --damage done / dps
			info.bg1_sec_texture:SetTexture("")
			info.tipo = 1

			if (info.sub_atributo == 2) then
				info.targets:SetText(Loc ["STRING_TARGETS"] .. " " .. Loc ["STRING_ATTRIBUTE_DAMAGE_DPS"] .. ":")
				info.target_persecond = true
			else
				info.targets:SetText(Loc ["STRING_TARGETS"] .. ":")
			end

		elseif (info.sub_atributo == 3) then --damage taken

			--info.bg1_sec_texture:SetTexture([[Interface\AddOns\Details\images\info_window_damagetaken]])
			info.bg1_sec_texture:SetColorTexture(.05, .05, .05, .4)
			info.bg3_sec_texture:Show()
			info.bg2_sec_texture:Show()
			info.tipo = 2

			for i = 1, spellInfoSettings.amount do
				info ["right_background" .. i]:Hide()
			end

			info.targets:SetText(Loc ["STRING_TARGETS"] .. ":")
			info.no_targets:Show()
			info.no_targets.text:Show()

			info.apoio_icone_esquerdo:Hide()
			info.apoio_icone_direito:Hide()
			info.report_direita:Show()

		elseif (info.sub_atributo == 4) then --friendly fire
			--info.bg1_sec_texture:SetTexture([[Interface\AddOns\Details\images\info_window_damagetaken]])
			info.bg1_sec_texture:SetColorTexture(.05, .05, .05, .4)
			info.bg3_sec_texture:Show()
			info.bg2_sec_texture:Show()
			info.tipo = 3

			for i = 1, spellInfoSettings.amount do
				info ["right_background" .. i]:Hide()
			end

			info.targets:SetText(Loc ["STRING_SPELLS"] .. ":")

			info.apoio_icone_esquerdo:Hide()
			info.apoio_icone_direito:Hide()
			info.report_direita:Show()

		elseif (info.sub_atributo == 6) then --enemies
			--info.bg1_sec_texture:SetTexture([[Interface\AddOns\Details\images\info_window_damagetaken]])
			info.bg1_sec_texture:SetColorTexture(.05, .05, .05, .4)
			info.bg3_sec_texture:Show()
			info.bg2_sec_texture:Show()
			info.tipo = 3

			for i = 1, spellInfoSettings.amount do
				info ["right_background" .. i]:Hide()
			end

			info.targets:SetText(Loc ["STRING_DAMAGE_TAKEN_FROM"])
		end

	elseif (info.atributo == 2) then --HEALING
		if (info.sub_atributo == 1 or info.sub_atributo == 2 or info.sub_atributo == 3) then --damage done / dps
			info.bg1_sec_texture:SetTexture("")
			info.tipo = 1

			if (info.sub_atributo == 3) then
				info.targets:SetText(Loc ["STRING_OVERHEALED"] .. ":")
				info.target_member = "overheal"
				info.target_text = Loc ["STRING_OVERHEALED"] .. ":"
			elseif (info.sub_atributo == 2) then
				info.targets:SetText(Loc ["STRING_TARGETS"] .. " " .. Loc ["STRING_ATTRIBUTE_HEAL_HPS"] .. ":")
				info.target_persecond = true
			else
				info.targets:SetText(Loc ["STRING_TARGETS"] .. ":")
			end

		elseif (info.sub_atributo == 4) then --Healing taken
			info.bg1_sec_texture:SetColorTexture(.05, .05, .05, .4)
			info.bg3_sec_texture:Show()
			info.bg2_sec_texture:Show()
			info.tipo = 2

			for i = 1, spellInfoSettings.amount do
				info ["right_background" .. i]:Hide()
			end

			info.targets:SetText(Loc ["STRING_TARGETS"] .. ":")
			info.no_targets:Show()
			info.no_targets.text:Show()

			info.apoio_icone_esquerdo:Hide()
			info.apoio_icone_direito:Hide()
			info.report_direita:Show()
		end

	elseif (info.atributo == 3) then --REGEN
		info.bg1_sec_texture:SetTexture("")
		info.tipo = 2
		info.targets:SetText("Vindo de:")

	elseif (info.atributo == 4) then --MISC
		info.bg1_sec_texture:SetTexture("")
		info.tipo = 2

		info.targets:SetText(Loc ["STRING_TARGETS"] .. ":")
	end
end

do --close the breakdown window  --> spells tab
	--self � qualquer coisa que chamar esta fun��o
	------------------------------------------------------------------------------------------------------------------------------
	-- � chamado pelo click no X e pelo reset do historico

	--alias
	function Details:CloseBreakdownWindow(bFromEscape)
		return _detalhes:FechaJanelaInfo(bFromEscape)
	end

	function _detalhes:FechaJanelaInfo(fromEscape)
		if (info.ativo) then --se a janela tiver aberta
			--playerDetailWindow:Hide()
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

			gump:JI_AtualizaContainerBarras (-1) --reseta o frame das barras
		end
	end
end

do --hide bars on the scrollbars of the window  --> spells tab

	--esconde todas as barras das skills na janela de info
	------------------------------------------------------------------------------------------------------------------------------
	function gump:HidaAllBarrasInfo()
		local barras = _detalhes.playerDetailWindow.barras1
		for index = 1, #barras, 1 do
			barras [index]:Hide()
			barras [index].textura:SetStatusBarColor(1, 1, 1, 1)
			barras [index].on_focus = false
		end
	end

	--esconde todas as barras dos alvos do jogador
	------------------------------------------------------------------------------------------------------------------------------
	function gump:HidaAllBarrasAlvo()
		local barras = _detalhes.playerDetailWindow.barras2
		for index = 1, #barras, 1 do
			barras [index]:Hide()
		end
	end

	--esconde as 5 barras a direita na janela de info
	------------------------------------------------------------------------------------------------------------------------------
	function gump:HidaAllDetalheInfo()
		for i = 1, spellInfoSettings.amount do
			gump:HidaDetalheInfo (i)
		end
		for _, barra in ipairs(info.barras3) do
			barra:Hide()
		end
		_detalhes.playerDetailWindow.spell_icone:SetTexture("")
	end
end

--set scripts on each bar of the scrollbars of the window  --> spells tab
	--seta os scripts da janela de informa��es
	local mouse_down_func = function(self, button)
		if (button == "LeftButton") then
			info:StartMoving()
			info.isMoving = true
		elseif (button == "RightButton" and not self.isMoving) then
			_detalhes:FechaJanelaInfo()
		end
	end

	local mouse_up_func = function(self, button)
		if (info.isMoving) then
			info:StopMovingOrSizing()
			info.isMoving = false
		end
	end

	local function seta_scripts (este_gump)  --> spells tab
		--Janela
		este_gump:SetScript("OnMouseDown", mouse_down_func)
		este_gump:SetScript("OnMouseUp", mouse_up_func)

		este_gump.container_barras.gump:SetScript("OnMouseDown", mouse_down_func)
		este_gump.container_barras.gump:SetScript("OnMouseUp", mouse_up_func)

		este_gump.container_detalhes:SetScript("OnMouseDown", mouse_down_func)
		este_gump.container_detalhes:SetScript("OnMouseUp", mouse_up_func)

		este_gump.container_alvos.gump:SetScript("OnMouseDown", mouse_down_func)
		este_gump.container_alvos.gump:SetScript("OnMouseUp", mouse_up_func)

		--bot�o fechar
		este_gump.close_button:SetScript("OnClick", function(self)
			_detalhes:FechaJanelaInfo()
		end)
	end

------------------------------------------------------------------------------------------------------------------------------
function gump:HidaDetalheInfo (index)  --> spells tab
	local info = _detalhes.playerDetailWindow.grupos_detalhes [index]
	info.nome:SetText("")
	info.nome2:SetText("")
	info.dano:SetText("")
	info.dano_porcento:SetText("")
	info.dano_media:SetText("")
	info.dano_dps:SetText("")
	info.bg:Hide()
end

--cria a barra de detalhes a direita da janela de informa��es
------------------------------------------------------------------------------------------------------------------------------

local detalhe_infobg_onenter = function(self)
	Details.FadeHandler.Fader(self.overlay, "OUT")
	Details.FadeHandler.Fader(self.reportar, "OUT")
end

local detalhe_infobg_onleave = function(self)
	Details.FadeHandler.Fader(self.overlay, "IN")
	Details.FadeHandler.Fader(self.reportar, "IN")
end

local detalhes_inforeport_onenter = function(self)
	Details.FadeHandler.Fader(self:GetParent().overlay, "OUT")
	Details.FadeHandler.Fader(self, "OUT")
end
local detalhes_inforeport_onleave = function(self)
	Details.FadeHandler.Fader(self:GetParent().overlay, "IN")
	Details.FadeHandler.Fader(self, "IN")
end

local getFrameFromDetailInfoBlock = function(self)
	return self.bg
end

function gump:CriaDetalheInfo(index)  --> spells tab
	local spellInfoBlock = {}
	spellInfoBlock.GetFrame = getFrameFromDetailInfoBlock

	spellInfoBlock.bg = CreateFrame("StatusBar", "DetailsPlayerDetailsWindow_DetalheInfoBG" .. index, _detalhes.playerDetailWindow.container_detalhes, "BackdropTemplate")
	--spellInfoBlock.bg:SetStatusBarTexture("")  --Interface\\AddOns\\Details\\images\\bar_detalhes2
	--bar_detalhes2 bar_background
	spellInfoBlock.bg:SetStatusBarTexture("Interface\\AddOns\\Details\\images\\bar_background")  --Interface\\AddOns\\Details\\images\\bar_detalhes2
	spellInfoBlock.bg:SetStatusBarColor(1, 1, 1, .84)
	spellInfoBlock.bg:SetMinMaxValues(0, 100)
	spellInfoBlock.bg:SetValue(100)
	spellInfoBlock.bg:SetSize(320, 47)

	spellInfoBlock.nome = spellInfoBlock.bg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	spellInfoBlock.nome2 = spellInfoBlock.bg:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	spellInfoBlock.dano = spellInfoBlock.bg:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	spellInfoBlock.dano_porcento = spellInfoBlock.bg:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	spellInfoBlock.dano_media = spellInfoBlock.bg:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	spellInfoBlock.dano_dps = spellInfoBlock.bg:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")

	spellInfoBlock.middleStringUp = spellInfoBlock.bg:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	spellInfoBlock.middleStringDown = spellInfoBlock.bg:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	spellInfoBlock.middleStringMiddle = spellInfoBlock.bg:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")

	spellInfoBlock.bg.overlay = spellInfoBlock.bg:CreateTexture("DetailsPlayerDetailsWindow_DetalheInfoBG_Overlay" .. index, "ARTWORK")
	spellInfoBlock.bg.overlay:SetTexture("Interface\\AddOns\\Details\\images\\overlay_detalhes")
	spellInfoBlock.bg.overlay:SetWidth(341)
	spellInfoBlock.bg.overlay:SetHeight(61)
	spellInfoBlock.bg.overlay:SetPoint("TOPLEFT", spellInfoBlock.bg, "TOPLEFT", -7, 6)
	Details.FadeHandler.Fader(spellInfoBlock.bg.overlay, 1)

	spellInfoBlock.bg.reportar = gump:NewDetailsButton (spellInfoBlock.bg, nil, nil, _detalhes.Reportar, _detalhes.playerDetailWindow, 10+index, 16, 16,
	"Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", nil, "DetailsJanelaInfoReport1")
	spellInfoBlock.bg.reportar:SetPoint("BOTTOMLEFT", spellInfoBlock.bg.overlay, "BOTTOMRIGHT",  -33, 10)
	Details.FadeHandler.Fader(spellInfoBlock.bg.reportar, 1)

	spellInfoBlock.bg:SetScript("OnEnter", detalhe_infobg_onenter)
	spellInfoBlock.bg:SetScript("OnLeave", detalhe_infobg_onleave)

	spellInfoBlock.bg.reportar:SetScript("OnEnter", detalhes_inforeport_onenter)
	spellInfoBlock.bg.reportar:SetScript("OnLeave", detalhes_inforeport_onleave)

	spellInfoBlock.bg_end = spellInfoBlock.bg:CreateTexture("DetailsPlayerDetailsWindow_DetalheInfoBG_bg_end" .. index, "BACKGROUND")
	spellInfoBlock.bg_end:SetHeight(40)
	spellInfoBlock.bg_end:SetTexture("Interface\\AddOns\\Details\\images\\bar_detalhes2_end")

	_detalhes.playerDetailWindow.grupos_detalhes[index] = spellInfoBlock
end

function info:SetDetailInfoConfigs(texture, color, x, y)  --> spells tab
	for i = 1, spellInfoSettings.amount do
		if (texture) then
			info.grupos_detalhes[i].bg:SetStatusBarTexture(texture)
		end

		if (color) then
			local texture = info.grupos_detalhes[i].bg:GetStatusBarTexture()
			texture:SetVertexColor(unpack(color))
		end

		if (x or y) then
			gump:SetaDetalheInfoAltura(i, x, y)
		end
	end
end

--determina qual a pocis�o que a barra de detalhes vai ocupar
------------------------------------------------------------------------------------------------------------------------------
--namespace
Details222.BreakdownWindow = {}
function Details222.BreakdownWindow.GetBlockIndex(index)
	return Details.playerDetailWindow.grupos_detalhes[index]
end

function gump:SetaDetalheInfoAltura(index, xmod, ymod)
	local spellInfoBlock = _detalhes.playerDetailWindow.grupos_detalhes[index]
	--local janela =  _detalhes.playerDetailWindow.container_detalhes
	--local altura = {-10, -63, -118, -173, -228, -279}
	--altura = altura[index]

	local background
	local yOffset = -74 - ((index-1) * 79.5)

	if (index == 1) then
		_detalhes.playerDetailWindow.right_background1:SetPoint("topleft", _detalhes.playerDetailWindow, "topleft", 357 + (xmod or 0), yOffset)
		background = _detalhes.playerDetailWindow.right_background1

	elseif (index == 2) then
		_detalhes.playerDetailWindow.right_background2:SetPoint("topleft", _detalhes.playerDetailWindow, "topleft", 357 + (xmod or 0), yOffset)
		background = _detalhes.playerDetailWindow.right_background2

	elseif (index == 3) then
		_detalhes.playerDetailWindow.right_background3:SetPoint("topleft", _detalhes.playerDetailWindow, "topleft", 357 + (xmod or 0), yOffset)
		background = _detalhes.playerDetailWindow.right_background3

	elseif (index == 4) then
		_detalhes.playerDetailWindow.right_background4:SetPoint("topleft", _detalhes.playerDetailWindow, "topleft", 357 + (xmod or 0), yOffset)
		background = _detalhes.playerDetailWindow.right_background4

	elseif (index == 5) then
		_detalhes.playerDetailWindow.right_background5:SetPoint("topleft", _detalhes.playerDetailWindow, "topleft", 357 + (xmod or 0), yOffset)
		background = _detalhes.playerDetailWindow.right_background5

	elseif (index == 6) then
		_detalhes.playerDetailWindow.right_background6:SetPoint("topleft", _detalhes.playerDetailWindow, "topleft", 357 + (xmod or 0), yOffset)
		background = _detalhes.playerDetailWindow.right_background6

	end

	background:SetHeight(75)

	--3 textos da esquerda e direita
	local yOffset = -3
	local xOffset = 3
	local right = -1

	spellInfoBlock.nome:SetPoint("TOPLEFT", background, "TOPLEFT", xOffset, yOffset + (-2))
	spellInfoBlock.dano:SetPoint("TOPLEFT", background, "TOPLEFT", xOffset, yOffset + (-24))
	spellInfoBlock.dano_media:SetPoint("TOPLEFT", background, "TOPLEFT", xOffset, yOffset + (-44))

	spellInfoBlock.nome2:SetPoint("TOPRIGHT", background, "TOPRIGHT", -xOffset + right,  yOffset + (-4))
	spellInfoBlock.dano_porcento:SetPoint("TOPRIGHT", background, "TOPRIGHT", -xOffset + right, yOffset + (-24))
	spellInfoBlock.dano_dps:SetPoint("TOPRIGHT", background, "TOPRIGHT", -xOffset + right, yOffset + (-44))

	spellInfoBlock.middleStringUp:SetPoint("center", background, "center", 0, 0)
	spellInfoBlock.middleStringUp:SetPoint("top", background, "top", 0, -7)

	spellInfoBlock.middleStringDown:SetPoint("center", background, "center", 0, 0)
	spellInfoBlock.middleStringDown:SetPoint("bottom", background, "bottom", 0, 19)

	spellInfoBlock.middleStringMiddle:SetPoint("center", background, "center", 0, 6)

	spellInfoBlock.bg:SetPoint("TOPLEFT", background, "TOPLEFT", 1, -1)
	spellInfoBlock.bg:SetHeight(background:GetHeight() - 2)
	spellInfoBlock.bg:SetWidth(background:GetWidth())

	spellInfoBlock.bg_end:SetPoint("LEFT", spellInfoBlock.bg, "LEFT", spellInfoBlock.bg:GetValue()*2.19, 0)
	spellInfoBlock.bg_end:SetHeight(background:GetHeight()-2)
	spellInfoBlock.bg_end:SetWidth(6)
	spellInfoBlock.bg_end:SetAlpha(.75)

	spellInfoBlock.bg.overlay:SetWidth(background:GetWidth() + 24)
	spellInfoBlock.bg.overlay:SetHeight(background:GetHeight() + 16)

	spellInfoBlock.bg:Hide()
end

--seta o conte�do da barra de detalhes
------------------------------------------------------------------------------------------------------------------------------
function gump:SetaDetalheInfoTexto(index, data, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
	local spellInfoBlock = _detalhes.playerDetailWindow.grupos_detalhes[index]

	if (data) then
		if (type(data) == "table") then
			spellInfoBlock.bg:SetValue(data.p)
			spellInfoBlock.bg:SetStatusBarColor(data.c[1], data.c[2], data.c[3], data.c[4] or 1)
		else
			local percentAmount = data
			spellInfoBlock.bg:SetValue(percentAmount)
			spellInfoBlock.bg:SetStatusBarColor(1, 1, 1, .5)
		end

		spellInfoBlock.bg_end:Show()
		spellInfoBlock.bg_end:SetPoint("LEFT", spellInfoBlock.bg, "LEFT", (spellInfoBlock.bg:GetValue() * (spellInfoBlock.bg:GetWidth( ) / 100)) - 3, 0) -- 2.19
		spellInfoBlock.bg:Show()
	end

	if (spellInfoBlock.IsPet) then
		spellInfoBlock.bg.PetIcon:Hide()
		spellInfoBlock.bg.PetText:Hide()
		spellInfoBlock.bg.PetDps:Hide()
		Details.FadeHandler.Fader(spellInfoBlock.bg.overlay, "IN")
		spellInfoBlock.IsPet = false
	end

	if (arg1) then
		spellInfoBlock.nome:SetText(arg1)
	end

	if (arg2) then
		spellInfoBlock.dano:SetText(arg2)
	end

	if (arg3) then
		spellInfoBlock.dano_porcento:SetText(arg3)
	end

	if (arg4) then
		spellInfoBlock.dano_media:SetText(arg4)
	end

	if (arg5) then
		spellInfoBlock.dano_dps:SetText(arg5)
	end

	if (arg6) then
		spellInfoBlock.nome2:SetText(arg6)
	end

	if (arg7) then
		spellInfoBlock.middleStringUp:SetText(arg7)
	else
		spellInfoBlock.middleStringUp:SetText("")
	end

	if (arg8) then
		spellInfoBlock.middleStringDown:SetText(arg8)
	else
		spellInfoBlock.middleStringDown:SetText("")
	end

	if (arg9) then
		spellInfoBlock.middleStringMiddle:SetText(arg9)
	else
		spellInfoBlock.middleStringMiddle:SetText("")
	end

	spellInfoBlock.nome:Show()
	spellInfoBlock.dano:Show()
	spellInfoBlock.dano_porcento:Show()
	spellInfoBlock.dano_media:Show()
	spellInfoBlock.dano_dps:Show()
	spellInfoBlock.nome2:Show()
	spellInfoBlock.middleStringUp:Show()
	spellInfoBlock.middleStringDown:Show()
	spellInfoBlock.middleStringDown:Show()
	spellInfoBlock.middleStringMiddle:Show()
end

--cria as 5 caixas de detalhes infos que ser�o usados
------------------------------------------------------------------------------------------------------------------------------
local function cria_barras_detalhes()
	_detalhes.playerDetailWindow.grupos_detalhes = {}
	for i = 1, spellInfoSettings.amount do
		gump:CriaDetalheInfo (i)
		gump:SetaDetalheInfoAltura(i)
	end
end

--cria os textos em geral da janela info
------------------------------------------------------------------------------------------------------------------------------
local function cria_textos (este_gump, SWW)
	este_gump.nome = este_gump:CreateFontString(nil, "OVERLAY", "QuestFont_Large")
	este_gump.nome:SetPoint("TOPLEFT", este_gump, "TOPLEFT", 105, -54)

	este_gump.atributo_nome = este_gump:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")

	este_gump.targets = SWW:CreateFontString(nil, "OVERLAY", "QuestFont_Large")
	este_gump.targets:SetPoint("TOPLEFT", este_gump, "TOPLEFT", 24, -273)
	este_gump.targets:SetText(Loc ["STRING_TARGETS"] .. ":")

	este_gump.avatar = este_gump:CreateTexture(nil, "overlay")
	este_gump.avatar_bg = este_gump:CreateTexture(nil, "overlay")
	este_gump.avatar_attribute = este_gump:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
	este_gump.avatar_nick = este_gump:CreateFontString(nil, "overlay", "QuestFont_Large")
	este_gump.avatar:SetDrawLayer("overlay", 3)
	este_gump.avatar_bg:SetDrawLayer("overlay", 2)
	este_gump.avatar_nick:SetDrawLayer("overlay", 4)

	este_gump.avatar:SetPoint("TOPLEFT", este_gump, "TOPLEFT", 60, -10)
	este_gump.avatar_bg:SetPoint("TOPLEFT", este_gump, "TOPLEFT", 60, -12)
	este_gump.avatar_bg:SetSize(275, 60)

	este_gump.avatar_nick:SetPoint("TOPLEFT", este_gump, "TOPLEFT", 195, -54)

	este_gump.avatar:Hide()
	este_gump.avatar_bg:Hide()
	este_gump.avatar_nick:Hide()
end

--esquerdo superior
local function cria_container_barras (este_gump, SWW)
	local container_barras_window = CreateFrame("ScrollFrame", "Details_Info_ContainerBarrasScroll", SWW, "BackdropTemplate")
	local container_barras = CreateFrame("Frame", "Details_Info_ContainerBarras", container_barras_window, "BackdropTemplate")

	container_barras:SetAllPoints(container_barras_window)
	container_barras:SetWidth(300)
	container_barras:SetHeight(150)
	container_barras:EnableMouse(true)
	container_barras:SetMovable(true)

	container_barras_window:SetWidth(300)
	container_barras_window:SetHeight(145)
	container_barras_window:SetScrollChild(container_barras)
	container_barras_window:SetPoint("TOPLEFT", este_gump, "TOPLEFT", 21, -76)

	container_barras_window:SetScript("OnSizeChanged", function(self)
		container_barras:SetSize(self:GetSize())
	end)

	gump:NewScrollBar (container_barras_window, container_barras, 6, -17)
	container_barras_window.slider:Altura (117)
	container_barras_window.slider:cimaPoint (0, 1)
	container_barras_window.slider:baixoPoint (0, -3)

	container_barras_window.ultimo = 0

	container_barras_window.gump = container_barras
	--container_barras_window.slider = slider_gump
	este_gump.container_barras = container_barras_window

end

function gump:JI_AtualizaContainerBarras (amt)
	local container = _detalhes.playerDetailWindow.container_barras

	if (amt >= 9 and container.ultimo ~= amt) then
		local tamanho = (CONST_BAR_HEIGHT + 1) * amt
		container.gump:SetHeight(tamanho)
		container.slider:Update()
		container.ultimo = amt

	elseif (amt < 8 and container.slider.ativo) then
		container.slider:Update (true)
		container.gump:SetHeight(140)
		container.scroll_ativo = false
		container.ultimo = 0
	end
end

function gump:JI_AtualizaContainerAlvos (amt)

	local container = _detalhes.playerDetailWindow.container_alvos

	if (amt >= 6 and container.ultimo ~= amt) then
		local tamanho = (CONST_TARGET_HEIGHT + 1) * amt
		container.gump:SetHeight(tamanho)
		container.slider:Update()
		container.ultimo = amt

	elseif (amt <= 5 and container.slider.ativo) then
		container.slider:Update (true)
		container.gump:SetHeight(100)
		container.scroll_ativo = false
		container.ultimo = 0
	end
end

--container direita
local function cria_container_detalhes (este_gump, SWW)
	local container_detalhes = CreateFrame("Frame", "Details_Info_ContainerDetalhes", SWW, "BackdropTemplate")

	container_detalhes:SetPoint("TOPRIGHT", este_gump, "TOPRIGHT", -74, -76)
	container_detalhes:SetWidth(220)
	container_detalhes:SetHeight(270)
	container_detalhes:EnableMouse(true)
	container_detalhes:SetResizable(false)
	container_detalhes:SetMovable(true)

	este_gump.container_detalhes = container_detalhes
end

--esquerdo inferior
local function cria_container_alvos (este_gump, SWW)
	local container_alvos_window = CreateFrame("ScrollFrame", "Details_Info_ContainerAlvosScroll", SWW, "BackdropTemplate")
	local container_alvos = CreateFrame("Frame", "Details_Info_ContainerAlvos", container_alvos_window, "BackdropTemplate")

	container_alvos:SetAllPoints(container_alvos_window)
	container_alvos:SetWidth(300)
	container_alvos:SetHeight(100)
	container_alvos:EnableMouse(true)
	container_alvos:SetMovable(true)

	container_alvos_window:SetWidth(300)
	container_alvos_window:SetHeight(100)
	container_alvos_window:SetScrollChild(container_alvos)
	container_alvos_window:SetPoint("BOTTOMLEFT", este_gump, "BOTTOMLEFT", 20, 6) --56 default

	container_alvos_window:SetScript("OnSizeChanged", function(self)
		container_alvos:SetSize(self:GetSize())
	end)

	gump:NewScrollBar (container_alvos_window, container_alvos, 7, 4)
	container_alvos_window.slider:Altura (88)
	container_alvos_window.slider:cimaPoint (0, 1)
	container_alvos_window.slider:baixoPoint (0, -3)

	container_alvos_window.gump = container_alvos
	este_gump.container_alvos = container_alvos_window
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
				info.classe_icone:SetTexCoord(_unpack(_detalhes.class_coords [_detalhes.faction_against]))
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
	elseif (_detalhes.playerdetailwindow_skins [skin_name]) then
		return false -- ja existe
	end

	_detalhes.playerdetailwindow_skins [skin_name] = func
	return true
end

function _detalhes:ApplyPDWSkin(skin_name)
--already built
	if (not DetailsPlayerDetailsWindow.Loaded) then
		if (skin_name) then
			_detalhes.player_details_window.skin = skin_name
		end
		return
	end

--hide extra frames
	local window = DetailsPlayerDetailsWindow
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
	DetailsPlayerDetailsWindow.bg1:SetTexture(texture)
end

function _detalhes:SetPDWBarConfig (texture)
	local window = DetailsPlayerDetailsWindow

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
_detalhes:InstallPDWSkin ("WoWClassic", {func = default_skin, author = "Details! Team", version = "v1.0", desc = "Default skin."})

local elvui_skin = function()
	local window = DetailsPlayerDetailsWindow
	window.bg1:SetTexture([[Interface\AddOns\Details\images\background]], true)
	window.bg1:SetAlpha(0.7)
	window.bg1:SetVertexColor(0.27, 0.27, 0.27)
	window.bg1:SetVertTile(true)
	window.bg1:SetHorizTile(true)
	window.bg1:SetSize(PLAYER_DETAILS_WINDOW_WIDTH, PLAYER_DETAILS_WINDOW_HEIGHT)

	window:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\AddOns\Details\images\background]]})
	window:SetBackdropColor(1, 1, 1, 0.3)
	window:SetBackdropBorderColor(0, 0, 0, 1)
	window.bg_icone_bg:Hide()
	window.bg_icone:Hide()
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
	window.targets:SetPoint("topleft", window.container_alvos, "topleft", 3, 18)
	window.nome:SetPoint("TOPLEFT", window, "TOPLEFT", 105, -48)

	--report button
	window.topleft_report:SetPoint("BOTTOMLEFT", window.container_barras, "TOPLEFT",  43, 2)

	--icons
	window.apoio_icone_direito:SetBlendMode("ADD")
	window.apoio_icone_esquerdo:SetBlendMode("ADD")

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
	window.SetClassIcon = function(player, class)
		if (player.spellicon) then
			window.classe_icone:SetTexture(player.spellicon)
			window.classe_icone:SetTexCoord(.1, .9, .1, .9)

		elseif (player.spec) then
			window.classe_icone:SetTexture([[Interface\AddOns\Details\images\spec_icons_normal_alpha]])
			window.classe_icone:SetTexCoord(_unpack(_detalhes.class_specs_coords [player.spec]))
			--esta_barra.icone_classe:SetVertexColor(1, 1, 1)
		else
			local coords = CLASS_ICON_TCOORDS [class]
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
_detalhes:InstallPDWSkin ("ElvUI", {func = elvui_skin, author = "Details! Team", version = "v1.0", desc = "Skin compatible with ElvUI addon."})

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

	breakdownFrame.SummaryWindowWidgets = CreateFrame("frame", "DetailsPlayerDetailsWindowSummaryWidgets", breakdownFrame, "BackdropTemplate")
	local SWW = breakdownFrame.SummaryWindowWidgets
	SWW:SetAllPoints()
	table.insert(SummaryWidgets, SWW) --where SummaryWidgets is declared: at the header of the file, what is the purpose of this table?

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

	--�cone da magia selecionada para mais detalhes (is this a window thing or tab thing?)
	--or this is even in use?
	breakdownFrame.bg_icone_bg = breakdownFrame:CreateTexture(nil, "ARTWORK")
	breakdownFrame.bg_icone_bg:SetPoint("TOPRIGHT", breakdownFrame, "TOPRIGHT",  -15, -12)
	breakdownFrame.bg_icone_bg:SetTexture("Interface\\AddOns\\Details\\images\\icone_bg_fundo")
	breakdownFrame.bg_icone_bg:SetDrawLayer("ARTWORK", -1)
	breakdownFrame.bg_icone_bg:Show()

	breakdownFrame.bg_icone = breakdownFrame:CreateTexture(nil, "OVERLAY")
	breakdownFrame.bg_icone:SetPoint("TOPRIGHT", breakdownFrame, "TOPRIGHT",  -15, -12)
	breakdownFrame.bg_icone:SetTexture("Interface\\AddOns\\Details\\images\\icone_bg")
	breakdownFrame.bg_icone:Show()

	--title
	DetailsFramework:NewLabel(breakdownFrame, breakdownFrame, nil, "title_string", Loc ["STRING_PLAYER_DETAILS"] .. " (|cFFFF8811Under Maintenance|r)", "GameFontHighlightLeft", 12, {227/255, 186/255, 4/255})
	breakdownFrame.title_string:SetPoint("center", breakdownFrame, "center")
	breakdownFrame.title_string:SetPoint("top", breakdownFrame, "top", 0, -18)

	--spell icon is still in use? what's the difference from the bg_icone?
	breakdownFrame.spell_icone = breakdownFrame:CreateTexture(nil, "ARTWORK")
	breakdownFrame.spell_icone:SetPoint("BOTTOMRIGHT", breakdownFrame.bg_icone, "BOTTOMRIGHT",  -19, 2)
	breakdownFrame.spell_icone:SetWidth(35)
	breakdownFrame.spell_icone:SetHeight(34)
	breakdownFrame.spell_icone:SetDrawLayer("ARTWORK", 0)
	breakdownFrame.spell_icone:Show()
	breakdownFrame.spell_icone:SetTexCoord(4/64, 60/64, 4/64, 60/64)

	--coisinhas do lado do icone - is this still in use?
	breakdownFrame.apoio_icone_esquerdo = breakdownFrame:CreateTexture(nil, "ARTWORK")
	breakdownFrame.apoio_icone_direito = breakdownFrame:CreateTexture(nil, "ARTWORK")
	breakdownFrame.apoio_icone_esquerdo:SetTexture("Interface\\PaperDollInfoFrame\\PaperDollSidebarTabs")
	breakdownFrame.apoio_icone_direito:SetTexture("Interface\\PaperDollInfoFrame\\PaperDollSidebarTabs")

	local apoio_altura = 13/256
	breakdownFrame.apoio_icone_esquerdo:SetTexCoord(0, 1, 0, apoio_altura)
	breakdownFrame.apoio_icone_direito:SetTexCoord(0, 1, apoio_altura+(1/256), apoio_altura+apoio_altura)

	breakdownFrame.apoio_icone_esquerdo:SetPoint("bottomright", breakdownFrame.bg_icone, "bottomleft",  42, 0)
	breakdownFrame.apoio_icone_direito:SetPoint("bottomleft", breakdownFrame.bg_icone, "bottomright",  -17, 0)

	breakdownFrame.apoio_icone_esquerdo:SetWidth(64)
	breakdownFrame.apoio_icone_esquerdo:SetHeight(13)
	breakdownFrame.apoio_icone_direito:SetWidth(64)
	breakdownFrame.apoio_icone_direito:SetHeight(13)

	breakdownFrame.topright_text1 = breakdownFrame:CreateFontString(nil, "overlay", "GameFontNormal")
	breakdownFrame.topright_text1:SetPoint("bottomright", breakdownFrame, "topright",  -18 - (94 * (1-1)), -36)
	breakdownFrame.topright_text1:SetJustifyH("right")
	_detalhes.gump:SetFontSize(breakdownFrame.topright_text1, 10)

	breakdownFrame.topright_text2 = breakdownFrame:CreateFontString(nil, "overlay", "GameFontNormal")
	breakdownFrame.topright_text2:SetPoint("bottomright", breakdownFrame, "topright",  -18 - (94 * (1-1)), -48)
	breakdownFrame.topright_text2:SetJustifyH("right")
	_detalhes.gump:SetFontSize(breakdownFrame.topright_text2, 10)

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
			_detalhes.gump:SetFontSize(breakdownFrame.topright_text1, size)
			_detalhes.gump:SetFontSize(breakdownFrame.topright_text2, size)
		end
		if (color) then
			_detalhes.gump:SetFontColor(breakdownFrame.topright_text1, color)
			_detalhes.gump:SetFontColor(breakdownFrame.topright_text2, color)
		end
		if (font) then
			_detalhes.gump:SetFontFace (breakdownFrame.topright_text1, font)
			_detalhes.gump:SetFontFace (breakdownFrame.topright_text2, font)
		end
	end

	local alpha_bgs = 1

	local este_gump = breakdownFrame

	-- backgrounds das 5 boxes do lado direito
		local right_background_X = 457
		local right_background_Y = {-85, -136, -191, -246, -301}

		for i = 1, spellInfoSettings.amount do
			local right_background1 = CreateFrame("frame", "DetailsPlayerDetailsWindow_right_background" .. i, SWW, "BackdropTemplate")
			right_background1:EnableMouse(false)
			right_background1:SetPoint("topleft", este_gump, "topleft", right_background_X, right_background_Y [i])
			right_background1:SetSize(220, 43)
			Details.gump:ApplyStandardBackdrop(right_background1)
			este_gump ["right_background" .. i] = right_background1

			local gradientDown = DetailsFramework:CreateTexture(right_background1, {gradient = "vertical", fromColor = {0, 0, 0, 0.1}, toColor = "transparent"}, 1, 43, "artwork", {0, 1, 0, 1})
			gradientDown:SetPoint("bottoms")
		end

	-- fundos especiais de friendly fire e outros
		este_gump.bg1_sec_texture = SWW:CreateTexture("DetailsPlayerDetailsWindow_BG1_SEC_Texture", "BORDER")
		este_gump.bg1_sec_texture:SetDrawLayer("BORDER", 4)
		este_gump.bg1_sec_texture:SetPoint("topleft", este_gump.bg1, "topleft", 450, -86)
		este_gump.bg1_sec_texture:SetHeight(462)
		este_gump.bg1_sec_texture:SetWidth(264)

		este_gump.bg2_sec_texture = SWW:CreateTexture("DetailsPlayerDetailsWindow_BG2_SEC_Texture", "BORDER")
		este_gump.bg2_sec_texture:SetDrawLayer("BORDER", 3)
		este_gump.bg2_sec_texture:SetPoint("topleft", este_gump.bg1_sec_texture, "topleft", 8, 0)
		este_gump.bg2_sec_texture:SetPoint("bottomright", este_gump.bg1_sec_texture, "bottomright", -30, 0)
		este_gump.bg2_sec_texture:SetTexture([[Interface\Glues\CREDITS\Warlords\Shadowmoon_Color_jlo3]])
		este_gump.bg2_sec_texture:SetDesaturated(true)
		este_gump.bg2_sec_texture:SetAlpha(0.3)
		este_gump.bg2_sec_texture:Hide()

		este_gump.bg3_sec_texture = SWW:CreateTexture("DetailsPlayerDetailsWindow_BG3_SEC_Texture", "BORDER")
		este_gump.bg3_sec_texture:SetDrawLayer("BORDER", 2)
		este_gump.bg3_sec_texture:SetPoint("topleft", este_gump.bg2_sec_texture, "topleft", 0, 0)
		este_gump.bg3_sec_texture:SetPoint("bottomright", este_gump.bg2_sec_texture, "bottomright", 0, 0)
		este_gump.bg3_sec_texture:Hide()

		este_gump.no_targets = SWW:CreateTexture("DetailsPlayerDetailsWindow_no_targets", "overlay")
		este_gump.no_targets:SetPoint("BOTTOMLEFT", este_gump, "BOTTOMLEFT", 20, 6)
		este_gump.no_targets:SetSize(301, 100)
		este_gump.no_targets:SetTexture([[Interface\QUESTFRAME\UI-QUESTLOG-EMPTY-TOPLEFT]])
		este_gump.no_targets:SetTexCoord(0.015625, 1, 0.01171875, 0.390625)
		este_gump.no_targets:SetDesaturated(true)
		este_gump.no_targets:SetAlpha(.7)
		este_gump.no_targets.text = SWW:CreateFontString(nil, "overlay", "GameFontNormal")
		este_gump.no_targets.text:SetPoint("center", este_gump.no_targets, "center")
		este_gump.no_targets.text:SetText(Loc ["STRING_NO_TARGET_BOX"])
		este_gump.no_targets.text:SetTextColor(1, 1, 1, .4)
		este_gump.no_targets:Hide()

	--cria os textos da janela
	cria_textos (este_gump, SWW)

	--cria o frama que vai abrigar as barras das habilidades
	cria_container_barras (este_gump, SWW)

	--cria o container que vai abrirgar as 5 barras de detalhes
	cria_container_detalhes (este_gump, SWW)

	--cria o container onde vai abrigar os alvos do jogador
	cria_container_alvos (este_gump, SWW)

	local leftbars1_backgound = CreateFrame("frame", "DetailsPlayerDetailsWindow_Left_SpellsBackground", SWW, "BackdropTemplate")
	leftbars1_backgound:EnableMouse(false)
	leftbars1_backgound:SetSize(303, 149)
	leftbars1_backgound:SetAlpha(alpha_bgs)
	leftbars1_backgound:SetFrameLevel(SWW:GetFrameLevel())
	Details.gump:ApplyStandardBackdrop(leftbars1_backgound)
	este_gump.leftbars1_backgound = leftbars1_backgound

	local leftbars2_backgound = CreateFrame("frame", "DetailsPlayerDetailsWindow_Left_TargetBackground", SWW, "BackdropTemplate")
	leftbars2_backgound:EnableMouse(false)
	leftbars2_backgound:SetSize(303, 122)
	leftbars2_backgound:SetAlpha(alpha_bgs)
	leftbars2_backgound:SetFrameLevel(SWW:GetFrameLevel())
	Details.gump:ApplyStandardBackdrop(leftbars2_backgound)
	este_gump.leftbars2_backgound = leftbars2_backgound

	leftbars1_backgound:SetPoint("topleft", este_gump.container_barras, "topleft", -3, 3)
	leftbars1_backgound:SetPoint("bottomright", este_gump.container_barras, "bottomright", 3, -3)
	leftbars2_backgound:SetPoint("topleft", este_gump.container_alvos, "topleft", -3, 23)
	leftbars2_backgound:SetPoint("bottomright", este_gump.container_alvos, "bottomright", 3, 0)

	--cria as 5 barras de detalhes a direita da janela
	cria_barras_detalhes()

	--seta os scripts dos frames da janela
	seta_scripts (este_gump)

	--vai armazenar os objetos das barras de habilidade
	este_gump.barras1 = {}

	--vai armazenar os objetos das barras de alvos
	este_gump.barras2 = {}

	--vai armazenar os objetos das barras da caixa especial da direita
	este_gump.barras3 = {}

	este_gump.SetClassIcon = default_icon_change

	--bot�o de reportar da caixa da esquerda, onde fica as barras principais
	este_gump.report_esquerda = gump:NewDetailsButton (SWW, este_gump, nil, _detalhes.Reportar, este_gump, 1, 16, 16,
	"Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", nil, "DetailsJanelaInfoReport2")
	este_gump.report_esquerda:SetPoint("BOTTOMLEFT", este_gump.container_barras, "TOPLEFT",  33, 3)
	este_gump.report_esquerda:SetFrameLevel(este_gump:GetFrameLevel()+2)
	este_gump.topleft_report = este_gump.report_esquerda

	--bot�o de reportar da caixa dos alvos
	este_gump.report_alvos = gump:NewDetailsButton (SWW, este_gump, nil, _detalhes.Reportar, este_gump, 3, 16, 16,
	"Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", nil, "DetailsJanelaInfoReport3")
	este_gump.report_alvos:SetPoint("BOTTOMRIGHT", este_gump.container_alvos, "TOPRIGHT",  -2, -1)
	este_gump.report_alvos:SetFrameLevel(3) --solved inactive problem

	--bot�o de reportar da caixa da direita, onde est�o os 5 quadrados
	este_gump.report_direita = gump:NewDetailsButton (SWW, este_gump, nil, _detalhes.Reportar, este_gump, 2, 16, 16,
	"Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", nil, "DetailsJanelaInfoReport4")
	este_gump.report_direita:SetPoint("TOPRIGHT", este_gump, "TOPRIGHT",  -10, -70)
	este_gump.report_direita:Show()

	--statusbar
	local statusBar = CreateFrame("frame", nil, este_gump, "BackdropTemplate")
	statusBar:SetPoint("bottomleft", este_gump, "bottomleft")
	statusBar:SetPoint("bottomright", este_gump, "bottomright")
	statusBar:SetHeight(PLAYER_DETAILS_STATUSBAR_HEIGHT)
	DetailsFramework:ApplyStandardBackdrop(statusBar)
	statusBar:SetAlpha(PLAYER_DETAILS_STATUSBAR_ALPHA)

	statusBar.Text = DetailsFramework:CreateLabel(statusBar)
	statusBar.Text:SetPoint("left", 2, 0)

	function este_gump:SetStatusbarText (text, fontSize, fontColor)
		if (not text) then
			este_gump:SetStatusbarText ("Details! Damage Meter | Use '/details stats' for statistics", 10, "gray")
			return
		end
		statusBar.Text.text = text
		statusBar.Text.fontsize = fontSize
		statusBar.Text.fontcolor = fontColor
	end

	--set default text
	este_gump:SetStatusbarText()

	--apply default skin
	_detalhes:ApplyPDWSkin()

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--tabs

	--tabs:
	--tab default

	local iconTableSummary = {
		texture = [[Interface\AddOns\Details\images\icons]],
		coords = {238/512, 255/512, 0, 18/512},
		width = 16,
		height = 16,
	}

	_detalhes:CreatePlayerDetailsTab("Summary", Loc ["STRING_SPELLS"], --[1] tab name [2] localized name
			function(tabOBject, playerObject) --[3] condition
				if (playerObject) then
					return true
				else
					return false
				end
			end,
			nil, --[4] fill function
			function() --[5] onclick
				for _, tab in ipairs(Details:GetBreakdownTabsInUse()) do
					tab.frame:Hide()
				end
			end,
			nil, --[6] oncreate
			iconTableSummary --[7] icon table
	)

	-- ~tab ~tabs
		function este_gump:ShowTabs()
			local tabsShown = 0
			local secondRowIndex = 1
			local breakLine = 6 --th tab it'll start the second line

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

		este_gump:SetScript("OnHide", function(self)
			_detalhes:FechaJanelaInfo()
			for _, tab in ipairs(_detalhes.player_details_tabs) do
				tab:Hide()
				tab.frame:Hide()
			end
		end)

	este_gump.tipo = 1 --tipo da janela // 1 = janela normal

	return este_gump

end

info.selectedTab = "Summary"

function _detalhes:CreatePlayerDetailsTab (tabname, localized_name, condition, fillfunction, onclick, oncreate, iconSettings, replace)
	if (not tabname) then
		tabname = "unnamed"
	end

	--create a button for the tab
	local newTabButton = gump:CreateButton(info, onclick, 20, 20, nil, nil, nil, nil, nil, "DetailsPlayerBreakdownWindowTab" .. tabname)
	newTabButton:SetTemplate("DETAILS_TAB_BUTTON_TEMPLATE")
	if (tabname == "Summary") then
		newTabButton:SetTemplate("DETAILS_TAB_BUTTONSELECTED_TEMPLATE")
	end
	newTabButton:SetText(localized_name)
	newTabButton:SetFrameStrata("HIGH")
	newTabButton:SetFrameLevel(info:GetFrameLevel()+1)
	newTabButton:Hide()

	newTabButton.condition = condition
	newTabButton.tabname = tabname
	newTabButton.localized_name = localized_name
	newTabButton.onclick = onclick
	newTabButton.fillfunction = fillfunction
	newTabButton.last_actor = {}

	newTabButton.frame = CreateFrame("frame", "DetailsPDWTabFrame" .. tabname, UIParent,"BackdropTemplate")
	newTabButton.frame:SetParent(info)
	newTabButton.frame:SetFrameStrata("HIGH")
	newTabButton.frame:SetFrameLevel(info:GetFrameLevel()+5)
	newTabButton.frame:EnableMouse(true)

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
		newTabButton.frame:SetScript("OnShow", function()
			if (newTabButton.last_actor == info.jogador) then
				return
			end
			newTabButton.last_actor = info.jogador
			newTabButton:fillfunction (info.jogador, info.instancia.showing)
		end)
	end

	if (oncreate) then
		oncreate (newTabButton, newTabButton.frame)
	end

	newTabButton.frame:SetBackdrop({
		edgeFile = [[Interface\Buttons\WHITE8X8]],
		edgeSize = 1,
		bgFile = [[Interface\AddOns\Details\images\background]],
		tileSize = 64,
		tile = true,
		insets = {left = 0, right = 0, top = 0, bottom = 0}}
	)

	newTabButton.frame:SetBackdropColor(0, 0, 0, 0.3)
	newTabButton.frame:SetBackdropBorderColor(.3, .3, .3, 0)

	newTabButton.frame:SetPoint("TOPLEFT", info.container_barras, "TOPLEFT", 0, 2)
	--newTabButton.frame:SetPoint("bottomright", info, "bottomright", -3, 3) --issue with: Action[SetPoint] failed because[SetPoint would result in anchor family connection]: attempted from: DetailsPlayerDetailsWindow:SetPoint.
	newTabButton.frame:SetSize(569, 274)

	newTabButton.frame:Hide()

	newTabButton.replaces = replace
	_detalhes.player_details_tabs [#_detalhes.player_details_tabs+1] = newTabButton

	if (not onclick) then
		--hide all tabs
		newTabButton.OnShowFunc = function(self)
			self = self.MyObject or self

			for _, tab in ipairs(Details:GetBreakdownTabsInUse()) do
				tab.frame:Hide()
				tab:SetTemplate("DETAILS_TAB_BUTTON_TEMPLATE")
			end

			self:SetTemplate("DETAILS_TAB_BUTTONSELECTED_TEMPLATE")
			self.frame:Show()
			info.selectedTab = self.tabname
		end

		newTabButton:SetScript("OnClick", newTabButton.OnShowFunc)
	else
		--custom
		newTabButton.OnShowFunc = function(self)
			self = self.MyObject or self

			for _, tab in ipairs(Details:GetBreakdownTabsInUse()) do
				tab.frame:Hide()
				tab:SetTemplate("DETAILS_TAB_BUTTON_TEMPLATE")
			end

			self:SetTemplate("DETAILS_TAB_BUTTONSELECTED_TEMPLATE")

			info.selectedTab = self.tabname

			--run onclick func
			local result, errorText = pcall(self.onclick)
			if (not result) then
				print(errorText)
			end
		end

		newTabButton:SetScript("OnClick", newTabButton.OnShowFunc)
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

	return newTabButton, newTabButton.frame
end

function _detalhes.playerDetailWindow:monta_relatorio (botao)
	local atributo = info.atributo
	local sub_atributo = info.sub_atributo
	local player = info.jogador
	local instancia = info.instancia

	local amt = _detalhes.report_lines

	if (not player) then
		_detalhes:Msg("Player not found.")
		return
	end

	local report_lines

	if (botao == 1) then --bot�o da esquerda


		if (atributo == 1 and sub_atributo == 4) then --friendly fire
			report_lines = {"Details!: " .. player.nome .. " " .. Loc ["STRING_ATTRIBUTE_DAMAGE_FRIENDLYFIRE"] .. ":"}

		elseif (atributo == 1 and sub_atributo == 3) then --damage taken
			report_lines = {"Details!: " .. player.nome .. " " .. Loc ["STRING_ATTRIBUTE_DAMAGE_TAKEN"] .. ":"}

		else
		--	report_lines = {"Details! " .. Loc ["STRING_ACTORFRAME_SPELLSOF"] .. " " .. player.nome .. " (" .. _detalhes.sub_atributos [atributo].lista [sub_atributo] .. ")"}
			report_lines = {"Details!: " .. player.nome .. " - " .. _detalhes.sub_atributos [atributo].lista [sub_atributo] .. ""}

		end

		for index, barra in ipairs(info.barras1) do
			if (barra:IsShown()) then
				local spellid = barra.show
				if (atributo == 1 and sub_atributo == 4) then --friendly fire
					report_lines [#report_lines+1] = barra.lineText1:GetText() .. ": " .. barra.lineText4:GetText()

				elseif (type(spellid) == "number" and spellid > 10) then
					local link = GetSpellLink(spellid)
					report_lines [#report_lines+1] = index .. ". " .. link .. ": " .. barra.lineText4:GetText()
				else
					local spellname = barra.lineText1:GetText():gsub((".*%."), "")
					spellname = spellname:gsub("|c%x%x%x%x%x%x%x%x", "")
					spellname = spellname:gsub("|r", "")
					report_lines [#report_lines+1] = index .. ". " .. spellname .. ": " .. barra.lineText4:GetText()
				end
			end
			if (index == amt) then
				break
			end
		end

	elseif (botao == 3) then --bot�o dos alvos

		if (atributo == 1 and sub_atributo == 3) then
			print(Loc ["STRING_ACTORFRAME_NOTHING"])
			return
		end

		report_lines = {"Details! " .. Loc ["STRING_ACTORFRAME_REPORTTARGETS"] .. " " .. _detalhes.sub_atributos [1].lista [1] .. " " .. Loc ["STRING_ACTORFRAME_REPORTOF"] .. " " .. player.nome}

		for index, barra in ipairs(info.barras2) do
			if (barra:IsShown()) then
				report_lines [#report_lines+1] = barra.lineText1:GetText().." -> ".. barra.lineText4:GetText()
			end
			if (index == amt) then
				break
			end
		end

	elseif (botao == 2) then --bot�o da direita

			--diferentes tipos de amostragem na caixa da direita
		     --dano                       --damage done                 --dps                                 --heal
		if ((atributo == 1 and (sub_atributo == 1 or sub_atributo == 2)) or (atributo == 2)) then
			if (not player.detalhes) then
				print(Loc ["STRING_ACTORFRAME_NOTHING"])
				return
			end
			local nome = _GetSpellInfo(player.detalhes)
			report_lines = {"Details! " .. Loc ["STRING_ACTORFRAME_REPORTTO"] .. " " .. _detalhes.sub_atributos [atributo].lista [sub_atributo] .. " " .. Loc ["STRING_ACTORFRAME_REPORTOF"] .. " " .. player.nome,
			Loc ["STRING_ACTORFRAME_SPELLDETAILS"] .. ": " .. nome}

			for i = 1, 5 do

				--pega os dados dos quadrados --Aqui mostra o resumo de todos os quadrados...
				local caixa = info.grupos_detalhes [i]
				if (caixa.bg:IsShown()) then

					local linha = ""

					local nome2 = caixa.nome2:GetText() --golpes
					if (nome2 and nome2 ~= "") then
						if (i == 1) then
							linha = linha..nome2.." / "
						else
							linha = linha..caixa.nome:GetText().." "..nome2.." / "
						end
					end

					local dano = caixa.dano:GetText() --dano
					if (dano and dano ~= "") then
						linha = linha..dano.." / "
					end

					local media = caixa.dano_media:GetText() --media
					if (media and media ~= "") then
						linha = linha..media.." / "
					end

					local dano_dps = caixa.dano_dps:GetText()
					if (dano_dps and dano_dps ~= "") then
						linha = linha..dano_dps.." / "
					end

					local dano_porcento = caixa.dano_porcento:GetText()
					if (dano_porcento and dano_porcento ~= "") then
						linha = linha..dano_porcento.." "
					end

					report_lines [#report_lines+1] = linha

				end

				if (i == amt) then
					break
				end
			end

			--dano                       --damage tanken (mostra as magias que o alvo usou)
		elseif ( (atributo == 1 and sub_atributo == 3) or atributo == 3) then
			if (player.detalhes) then
				report_lines = {"Details! " .. Loc ["STRING_ACTORFRAME_REPORTTO"] .. " " .. _detalhes.sub_atributos [1].lista [1] .. " " .. Loc ["STRING_ACTORFRAME_REPORTOF"] .. " " .. player.detalhes.. " " .. Loc ["STRING_ACTORFRAME_REPORTAT"] .. " " .. player.nome}
				for index, barra in ipairs(info.barras3) do
					if (barra:IsShown()) then
						report_lines [#report_lines+1] = barra.lineText1:GetText().." ....... ".. barra.lineText4:GetText()
					end
					if (index == amt) then
						break
					end
				end
			else
				report_lines = {}
			end
		end

	elseif (botao >= 11) then --primeira caixa dos detalhes
		botao =  botao - 10

		local nome
		if (type(spellid) == "string") then
			--is a pet
		else
			nome = _GetSpellInfo(player.detalhes)
			local spelllink = GetSpellLink(player.detalhes)
			if (spelllink) then
				nome = spelllink
			end
		end

		if (not nome) then
			nome = ""
		end
		report_lines = {"Details! " .. Loc ["STRING_ACTORFRAME_REPORTTO"] .. " " .. _detalhes.sub_atributos [atributo].lista [sub_atributo].. " " .. Loc ["STRING_ACTORFRAME_REPORTOF"] .. " " .. player.nome,
		Loc ["STRING_ACTORFRAME_SPELLDETAILS"] .. ": " .. nome}

		local caixa = info.grupos_detalhes [botao]

		local linha = ""
		local nome2 = caixa.nome2:GetText() --golpes
		if (nome2 and nome2 ~= "") then
			if (i == 1) then
				linha = linha..nome2.." / "
			else
				linha = linha..caixa.nome:GetText().." "..nome2.." / "
			end
		end

		local dano = caixa.dano:GetText() --dano
		if (dano and dano ~= "") then
			linha = linha..dano.." / "
		end

		local media = caixa.dano_media:GetText() --media
		if (media and media ~= "") then
			linha = linha..media.." / "
		end

		local dano_dps = caixa.dano_dps:GetText()
		if (dano_dps and dano_dps ~= "") then
			linha = linha..dano_dps.." / "
		end

		local dano_porcento = caixa.dano_porcento:GetText()
		if (dano_porcento and dano_porcento ~= "") then
			linha = linha..dano_porcento.." "
		end

		--remove a cor da school
		linha = linha:gsub("|c%x?%x?%x?%x?%x?%x?%x?%x?", "")
		linha = linha:gsub("|r", "")

		report_lines [#report_lines+1] = linha

	end

	return instancia:envia_relatorio (report_lines)
end

local row_backdrop = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		insets = {left = 0, right = 0, top = 0, bottom = 0}}
local row_backdrop_onleave = {bgFile = "", edgeFile = "", tile = true, tileSize = 16, edgeSize = 32,
		insets = {left = 1, right = 1, top = 0, bottom = 1}}

local row_on_enter = function(self)
	if (info.fading_in or info.faded) then
		return
	end

	self.mouse_over = true

	for index, block in pairs(_detalhes.playerDetailWindow.grupos_detalhes) do
		detalhe_infobg_onleave (block.bg)
	end

	--aumenta o tamanho da barra
	self:SetHeight(CONST_BAR_HEIGHT + 1)
	--poe a barra com alfa 1 ao inv�s de 0.9
	self:SetAlpha(1)

	--troca a cor da barra enquanto o mouse estiver em cima dela
	self:SetBackdrop(row_backdrop)
	self:SetBackdropColor(0.8, 0.8, 0.8, 0.3)

	if (self.isAlvo) then --monta o tooltip do alvo
		--talvez devesse escurecer a janela no fundo... pois o tooltip � transparente e pode confundir
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")

		if (self.spellid == "enemies") then --damage taken enemies
			if (not self.minha_tabela or not self.minha_tabela:MontaTooltipDamageTaken (self, self._index, info.instancia)) then  -- > poderia ser aprimerado para uma tailcall
				return
			end
			GameTooltip:Show()
			self:SetHeight(CONST_TARGET_HEIGHT + 1)
			return
		end

		if (not self.minha_tabela or not self.minha_tabela:MontaTooltipAlvos (self, self._index, info.instancia)) then  -- > poderia ser aprimerado para uma tailcall
			return
		end

	elseif (self.isMain) then
		if (IsShiftKeyDown()) then
			if (type(self.show) == "number") then
				GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
				GameTooltip:AddLine(Loc ["ABILITY_ID"] .. ": " .. self.show)
				GameTooltip:Show()
			end
		end

		if (self.show == 98021) then
			GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
			GameTooltip:AddLine(Loc ["STRING_SPIRIT_LINK_TOTEM_DESC"])
			GameTooltip:Show()
		end

		--da zoom no icone
		self.icone:SetWidth(CONST_BAR_HEIGHT + 2)
		self.icone:SetHeight(CONST_BAR_HEIGHT + 2)
		--poe a alfa do icone em 1.0
		self.icone:SetAlpha(1)

		--mostrar temporariamente o conteudo da barra nas caixas de detalhes
		if (not info.mostrando) then --n�o esta mostrando nada na direita
			info.mostrando = self --agora o mostrando � igual a esta barra
			info.mostrando_mouse_over = true --o conteudo da direta esta sendo mostrado pq o mouse esta passando por cima do bagulho e n�o pq foi clicado
			info.showing = self._index --diz  o index da barra que esta sendo mostrado na direita

			info.jogador.detalhes = self.show --minha tabela = jogador = jogador.detales = spellid ou nome que esta sendo mostrado na direita
			info.jogador:MontaDetalhes (self.show, self, info.instancia) --passa a spellid ou nome e a barra
		end
	elseif (self.isDetalhe and type(self.show) == "number") then
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
		Details:GameTooltipSetSpellByID(self.show)
		GameTooltip:Show()
	end
end

local row_on_leave = function(self)
	if (self.fading_in or self.faded or not self:IsShown() or self.hidden) then
		return
	end

	self.mouse_over = false

	--diminui o tamanho da barra
	self:SetHeight(CONST_BAR_HEIGHT)
	--volta com o alfa antigo da barra que era de 0.9
	self:SetAlpha(0.9)

	--volto o background ao normal
	self:SetBackdrop(row_backdrop_onleave)
	self:SetBackdropBorderColor(0, 0, 0, 0)
	self:SetBackdropColor(0, 0, 0, 0)

	GameTooltip:Hide()

	GameCooltip:Hide()

	if (self.isMain) then
		--retira o zoom no icone
		self.icone:SetWidth(CONST_BAR_HEIGHT)
		self.icone:SetHeight(CONST_BAR_HEIGHT)
		--volta com a alfa antiga da barra
		self.icone:SetAlpha(1)

		--remover o conte�do que estava sendo mostrado na direita
		if (info.mostrando_mouse_over) then
			info.mostrando = nil
			info.mostrando_mouse_over = false
			info.showing = nil

			info.jogador.detalhes = nil
			gump:HidaAllDetalheInfo()
		end

	elseif (self.isAlvo) then
		self:SetHeight(CONST_TARGET_HEIGHT)
	elseif (self.isDetalhe) then
		self:SetHeight(16)
	end
end

local row_on_mousedown = function(self, button)
	if (self.fading_in) then
		return
	end

	self.mouse_down = GetTime()
	local x, y = _GetCursorPosition()
	self.x = _math_floor(x)
	self.y = _math_floor(y)

	if (button == "RightButton" and not info.isMoving) then
		_detalhes:FechaJanelaInfo()

	elseif (not info.isMoving and button == "LeftButton" and not self.isDetalhe) then
		info:StartMoving()
		info.isMoving = true
	end
end

local row_on_mouseup = function(self, button)
	if (self.fading_in) then
		return
	end

	if (info.isMoving and button == "LeftButton" and not self.isDetalhe) then
		info:StopMovingOrSizing()
		info.isMoving = false
	end

	local x, y = _GetCursorPosition()
	x = _math_floor(x)
	y = _math_floor(y)
	if ((self.mouse_down+0.4 > GetTime() and (x == self.x and y == self.y)) or (x == self.x and y == self.y)) then
		--setar os textos

		if (self.isMain) then --se n�o for uma barra de alvo

			local barra_antiga = info.mostrando
			if (barra_antiga and not info.mostrando_mouse_over) then

				barra_antiga.textura:SetStatusBarColor(1, 1, 1, 1) --volta a textura normal
				barra_antiga.on_focus = false --n�o esta mais no foco

				--clicou na mesma barra
				if (barra_antiga == self) then -->
					info.mostrando_mouse_over = true
					return

				--clicou em outra barra
				else --clicou em outra barra e trocou o foco
					barra_antiga:SetAlpha(.9) --volta a alfa antiga

					info.mostrando = self
					info.showing = i

					info.jogador.detalhes = self.show
					info.jogador:MontaDetalhes (self.show, self)

					self:SetAlpha(1)
					self.textura:SetStatusBarColor(129/255, 125/255, 69/255, 1)
					self.on_focus = true
					return
				end
			end

			--nao tinha barras pressionadas
			info.mostrando_mouse_over = false
			self:SetAlpha(1)
			self.textura:SetStatusBarColor(129/255, 125/255, 69/255, 1)
			self.on_focus = true
		end
	end
end

local function SetBarraScripts (esta_barra, instancia, i)
	esta_barra._index = i

	esta_barra:SetScript("OnEnter", row_on_enter)
	esta_barra:SetScript("OnLeave", row_on_leave)

	esta_barra:SetScript("OnMouseDown", row_on_mousedown)
	esta_barra:SetScript("OnMouseUp", row_on_mouseup)
end

local function CriaTexturaBarra(newLine)
	newLine.textura = CreateFrame("StatusBar", nil, newLine, "BackdropTemplate")
	newLine.textura:SetFrameLevel(newLine:GetFrameLevel()-1)
	newLine.textura:SetAllPoints(newLine)
	newLine.textura:SetAlpha(0.5)
	newLine.textura:Show()

	local textureObject = newLine.textura:CreateTexture(nil, "artwork")
	local texturePath = SharedMedia:Fetch("statusbar", _detalhes.player_details_window.bar_texture)
	textureObject:SetTexture(texturePath)
	newLine.textura:SetStatusBarTexture(textureObject)
	newLine.textura:SetStatusBarColor(.5, .5, .5, 1)
	--newLine.textura:SetColorFill(.5, .5, .5, 1) --(r, g, b, a) --only in 10.0?
	newLine.textura:SetMinMaxValues(0, 100)

	local backgroundTexture = newLine.textura:CreateTexture(nil, "background")
	backgroundTexture:SetAllPoints()
	backgroundTexture:SetColorTexture(.5, .5, .5, 0.18)
	newLine.textura.bg = backgroundTexture

	if (newLine.targets) then
		newLine.targets:SetParent(newLine.textura)
		newLine.targets:SetFrameLevel(newLine.textura:GetFrameLevel()+2)
	end

	--create the left text
	newLine.lineText1 = newLine:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	newLine.lineText1:SetPoint("LEFT", newLine.icone, "RIGHT", 2, 0)
	newLine.lineText1:SetJustifyH("LEFT")
	newLine.lineText1:SetTextColor(1,1,1,1)
	newLine.lineText1:SetNonSpaceWrap(true)
	newLine.lineText1:SetWordWrap(false)

	--create the rigth text
	newLine.lineText4 = newLine:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	if (newLine.targets) then
		newLine.lineText4:SetPoint("RIGHT", newLine.targets, "LEFT", -2, 0)
	else
		newLine.lineText4:SetPoint("RIGHT", newLine, "RIGHT", -2, 0)
	end
	newLine.lineText4:SetJustifyH("RIGHT")
	newLine.lineText4:SetTextColor(1,1,1,1)
end

local miniframe_func_on_enter = function(self)
	local barra = self:GetParent()
	if (barra.show and type(barra.show) == "number") then
		local spellname = _GetSpellInfo(barra.show)
		if (spellname) then
			GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
			_detalhes:GameTooltipSetSpellByID (barra.show)
			GameTooltip:Show()
		end
	end
	barra:GetScript("OnEnter")(barra)
end

local miniframe_func_on_leave = function(self)
	GameTooltip:Hide()
	self:GetParent():GetScript("OnLeave")(self:GetParent())
end

local target_on_enter = function(self)
	local barra = self:GetParent():GetParent()

	if (barra.show and type(barra.show) == "number") then
		local actor = barra.other_actor or info.jogador
		local spell = actor.spells and actor.spells:PegaHabilidade (barra.show)
		if (spell) then

			local ActorTargetsSortTable = {}
			local ActorTargetsContainer
			local total = 0

			if (spell.isReflection) then
				ActorTargetsContainer = spell.extra
			else
				local attribute, sub_attribute = info.instancia:GetDisplay()
				if (attribute == 1 or attribute == 3) then
					ActorTargetsContainer = spell.targets
				else
					if (sub_attribute == 3) then --overheal
						ActorTargetsContainer = spell.targets_overheal
					elseif (sub_attribute == 6) then --absorbs
						ActorTargetsContainer = spell.targets_absorbs
					else
						ActorTargetsContainer = spell.targets
					end
				end
			end

			--add and sort
			for target_name, amount in pairs(ActorTargetsContainer) do
				ActorTargetsSortTable [#ActorTargetsSortTable+1] = {target_name, amount or 0}
				total = total + (amount or 0)
			end
			table.sort (ActorTargetsSortTable, _detalhes.Sort2)

			local spellname = _GetSpellInfo(barra.show)

			GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
			GameTooltip:AddLine(barra.index .. ". " .. spellname)
			GameTooltip:AddLine(info.target_text)
			GameTooltip:AddLine(" ")

			--get time type
			local meu_tempo
			if (_detalhes.time_type == 1 or not actor.grupo) then
				meu_tempo = actor:Tempo()
			elseif (_detalhes.time_type == 2) then
				meu_tempo = info.instancia.showing:GetCombatTime()
			end

			local SelectedToKFunction = _detalhes.ToKFunctions [_detalhes.ps_abbreviation]

			if (spell.isReflection) then
				_detalhes:FormatCooltipForSpells()
				GameCooltip:SetOwner(self, "bottomright", "top", 4, -2)

				_detalhes:AddTooltipSpellHeaderText ("Spells Reflected", {1, 0.9, 0.0, 1}, 1, select(3, _GetSpellInfo(spell.id)), 0.1, 0.9, 0.1, 0.9) --localize-me
				_detalhes:AddTooltipHeaderStatusbar (1, 1, 1, 0.4)

				GameCooltip:AddIcon(select(3, _GetSpellInfo(spell.id)), 1, 1, 16, 16, .1, .9, .1, .9)
				_detalhes:AddTooltipHeaderStatusbar (1, 1, 1, 0.5)

				local topDamage = ActorTargetsSortTable[1] and ActorTargetsSortTable[1][2]

				for index, target in ipairs(ActorTargetsSortTable) do
					if (target [2] > 0) then
						local spellId = target[1]
						local damageDone = target[2]
						local spellName, _, spellIcon = _GetSpellInfo(spellId)
						GameCooltip:AddLine(spellName, SelectedToKFunction (_, damageDone) .. " (" .. floor(damageDone / topDamage * 100) .. "%)")
						GameCooltip:AddIcon(spellIcon, 1, 1, 16, 16, .1, .9, .1, .9)
						_detalhes:AddTooltipBackgroundStatusbar (false, damageDone / topDamage * 100)
					end
				end

				GameCooltip:Show()

				self.texture:SetAlpha(1)
				self:SetAlpha(1)
				barra:GetScript("OnEnter")(barra)
				return
			else
				for index, target in ipairs(ActorTargetsSortTable) do
					if (target [2] > 0) then
						local class = _detalhes:GetClass(target [1])
						if (class and _detalhes.class_coords [class]) then
							local cords = _detalhes.class_coords [class]
							if (info.target_persecond) then
								GameTooltip:AddDoubleLine (index .. ". |TInterface\\AddOns\\Details\\images\\classes_small_alpha:14:14:0:0:128:128:"..cords[1]*128 ..":"..cords[2]*128 ..":"..cords[3]*128 ..":"..cords[4]*128 .."|t " .. target [1], _detalhes:comma_value ( _math_floor(target [2] / meu_tempo) ), 1, 1, 1, 1, 1, 1)
							else
								GameTooltip:AddDoubleLine (index .. ". |TInterface\\AddOns\\Details\\images\\classes_small_alpha:14:14:0:0:128:128:"..cords[1]*128 ..":"..cords[2]*128 ..":"..cords[3]*128 ..":"..cords[4]*128 .."|t " .. target [1], SelectedToKFunction (_, target [2]), 1, 1, 1, 1, 1, 1)
							end
						else
							if (info.target_persecond) then
								GameTooltip:AddDoubleLine (index .. ". " .. target [1], _detalhes:comma_value ( _math_floor(target [2] / meu_tempo)), 1, 1, 1, 1, 1, 1)
							else
								GameTooltip:AddDoubleLine (index .. ". " .. target [1], SelectedToKFunction (_, target [2]), 1, 1, 1, 1, 1, 1)
							end
						end
					end
				end
			end

			GameTooltip:Show()
		else
			GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
			GameTooltip:AddLine(barra.index .. ". " .. barra.show)
			GameTooltip:AddLine(info.target_text)
			GameTooltip:AddLine(Loc ["STRING_NO_TARGET"], 1, 1, 1)
			GameTooltip:AddLine(Loc ["STRING_MORE_INFO"], 1, 1, 1)
			GameTooltip:Show()
		end
	else
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
		GameTooltip:AddLine(barra.index .. ". " .. barra.show)
		GameTooltip:AddLine(info.target_text)
		GameTooltip:AddLine(Loc ["STRING_NO_TARGET"], 1, 1, 1)
		GameTooltip:AddLine(Loc ["STRING_MORE_INFO"], 1, 1, 1)
		GameTooltip:Show()
	end

	self.texture:SetAlpha(1)
	self:SetAlpha(1)
	barra:GetScript("OnEnter")(barra)
end

local target_on_leave = function(self)
	GameTooltip:Hide()
	GameCooltip:Hide()
	self:GetParent():GetParent():GetScript("OnLeave")(self:GetParent():GetParent())
	self.texture:SetAlpha(.7)
	self:SetAlpha(.7)
end

function gump:CriaNovaBarraInfo1(instancia, index)
	if (_detalhes.playerDetailWindow.barras1[index]) then
		return
	end

	local parentFrame = info.container_barras.gump

	local newLine = CreateFrame("Button", "Details_infobox1_bar_" .. index, parentFrame, "BackdropTemplate")
	newLine:SetHeight(CONST_BAR_HEIGHT)
	newLine.index = index

	local y = (index-1) * (CONST_BAR_HEIGHT + 1)
	y = y * -1

	newLine:SetPoint("LEFT", parentFrame, "LEFT", CONST_BAR_HEIGHT, 0)
	newLine:SetPoint("RIGHT", parentFrame, "RIGHT")
	newLine:SetPoint("TOP", parentFrame, "TOP", 0, y)
	newLine:SetFrameLevel(parentFrame:GetFrameLevel() + 1)
	newLine:SetAlpha(1)
	newLine:EnableMouse(true)
	newLine:RegisterForClicks("LeftButtonDown","RightButtonUp")
	newLine.isMain = true

	--create a square frame which is placed at the right side of the line to show which targets for damaged by the spell
	newLine.targets = CreateFrame("frame", "$parentTargets", newLine, "BackdropTemplate")
	newLine.targets:SetPoint("right", newLine, "right", 0, 0)
	newLine.targets:SetSize(CONST_BAR_HEIGHT-1, CONST_BAR_HEIGHT-1)
	newLine.targets:SetAlpha(.7)
	newLine.targets:SetScript("OnEnter", target_on_enter)
	newLine.targets:SetScript("OnLeave", target_on_leave)
	newLine.targets.texture = newLine.targets:CreateTexture(nil, "overlay")
	newLine.targets.texture:SetTexture([[Interface\MINIMAP\TRACKING\Target]])
	newLine.targets.texture:SetAllPoints()
	newLine.targets.texture:SetDesaturated(true)
	newLine.targets.texture:SetAlpha(1)

	--create the icon to show the spell icon
	newLine.icone = newLine:CreateTexture(nil, "OVERLAY")
	newLine.icone:SetWidth(CONST_BAR_HEIGHT-2)
	newLine.icone:SetHeight(CONST_BAR_HEIGHT-2)
	newLine.icone:SetPoint("RIGHT", newLine, "LEFT", 0, 0)
	newLine.icone:SetAlpha(1)
	--frame which will show the spell tooltip
	newLine.miniframe = CreateFrame("frame", nil, newLine, "BackdropTemplate")
	newLine.miniframe:SetSize(CONST_BAR_HEIGHT * 2, CONST_BAR_HEIGHT-2)
	newLine.miniframe:SetPoint("right", newLine, "left", CONST_BAR_HEIGHT, 0)
	newLine.miniframe:SetScript("OnEnter", miniframe_func_on_enter)
	newLine.miniframe:SetScript("OnLeave", miniframe_func_on_leave)

	CriaTexturaBarra(newLine)
	SetBarraScripts (newLine, instancia, index)

	info.barras1[index] = newLine
	newLine.textura:SetStatusBarColor(1, 1, 1, 1)
	newLine.on_focus = false

	return newLine
end

function gump:CriaNovaBarraInfo2(instancia, index)
	if (_detalhes.playerDetailWindow.barras2 [index]) then
		print("erro a barra "..index.." ja existe na janela de detalhes...")
		return
	end

	local janela = info.container_alvos.gump

	local esta_barra = CreateFrame("Button", "Details_infobox2_bar_"..index, info.container_alvos.gump, "BackdropTemplate")
	esta_barra:SetHeight(CONST_TARGET_HEIGHT)

	local y = (index-1) * (CONST_TARGET_HEIGHT + 1)
	y = y*-1 --baixo

	esta_barra:SetPoint("LEFT", janela, "LEFT", CONST_TARGET_HEIGHT, 0)
	esta_barra:SetPoint("RIGHT", janela, "RIGHT", 0, 0)
	esta_barra:SetPoint("TOP", janela, "TOP", 0, y)
	esta_barra:SetFrameLevel(janela:GetFrameLevel() + 1)

	esta_barra:EnableMouse(true)
	esta_barra:RegisterForClicks ("LeftButtonDown","RightButtonUp")

	--icone
	esta_barra.icone = esta_barra:CreateTexture(nil, "OVERLAY")
	esta_barra.icone:SetWidth(CONST_TARGET_HEIGHT)
	esta_barra.icone:SetHeight(CONST_TARGET_HEIGHT)
	esta_barra.icone:SetPoint("RIGHT", esta_barra, "LEFT", 0, 0)

	CriaTexturaBarra(esta_barra)

	esta_barra:SetAlpha(ALPHA_BLEND_AMOUNT)
	esta_barra.icone:SetAlpha(1)

	esta_barra.isAlvo = true

	SetBarraScripts(esta_barra, instancia, index)

	info.barras2 [index] = esta_barra --barra adicionada

	return esta_barra
end

function gump:CriaNovaBarraInfo3 (instancia, index)
	if (_detalhes.playerDetailWindow.barras3 [index]) then
		print("erro a barra "..index.." ja existe na janela de detalhes...")
		return
	end

	local janela = info.container_detalhes

	local esta_barra = CreateFrame("Button", "Details_infobox3_bar_"..index, janela, "BackdropTemplate")
	esta_barra:SetHeight(16)

	local y = (index-1) * 17
	y = y*-1
	container3_bars_pointFunc (esta_barra, index)
	esta_barra:EnableMouse(true)

	--icone
	esta_barra.icone = esta_barra:CreateTexture(nil, "OVERLAY")
	esta_barra.icone:SetWidth(14)
	esta_barra.icone:SetHeight(14)
	esta_barra.icone:SetPoint("LEFT", esta_barra, "LEFT", 0, 0)

	CriaTexturaBarra(esta_barra)

	esta_barra:SetAlpha(0.9)
	esta_barra.icone:SetAlpha(1)

	esta_barra.isDetalhe = true

	SetBarraScripts (esta_barra, instancia, index)

	info.barras3 [index] = esta_barra --barra adicionada

	return esta_barra
end
