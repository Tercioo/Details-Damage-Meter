local _detalhes = 		_G._detalhes
local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")

local gump = 			_detalhes.gump
local _
--lua locals
--local _string_len = string.len
local _math_floor = math.floor
local _ipairs = ipairs
local _pairs = pairs
local _type = type
--api locals
local _CreateFrame = CreateFrame
local _GetTime = GetTime
local _GetSpellInfo = _detalhes.getspellinfo
local _GetCursorPosition = GetCursorPosition
local _unpack = unpack

local atributos = _detalhes.atributos
local sub_atributos = _detalhes.sub_atributos

local info = _detalhes.janela_info
local classe_icones = _G.CLASS_ICON_TCOORDS

------------------------------------------------------------------------------------------------------------------------------
--self = instancia
--jogador = classe_damage ou classe_heal

function _detalhes:AbreJanelaInfo (jogador, from_att_change)

	if (not _detalhes.row_singleclick_overwrite [self.atributo] or not _detalhes.row_singleclick_overwrite [self.atributo][self.sub_atributo]) then
		_detalhes:FechaJanelaInfo()
		return
	elseif (_type (_detalhes.row_singleclick_overwrite [self.atributo][self.sub_atributo]) == "function") then
		if (from_att_change) then
			_detalhes:FechaJanelaInfo()
			return
		end
		return _detalhes.row_singleclick_overwrite [self.atributo][self.sub_atributo] (_, jogador, self)
	end
	
	if (self.modo == _detalhes._detalhes_props["MODO_RAID"]) then
		_detalhes:FechaJanelaInfo()
		return
	end

	--> _detalhes.info_jogador armazena o jogador que esta sendo mostrado na janela de detalhes
	if (info.jogador and info.jogador == jogador and self and info.atributo and self.atributo == info.atributo and self.sub_atributo == info.sub_atributo) then
		_detalhes:FechaJanelaInfo() --> se clicou na mesma barra ent�o fecha a janela de detalhes
		return
	elseif (not jogador) then
		_detalhes:FechaJanelaInfo()
		return
	end

	if (info.barras1) then
		for index, barra in ipairs (info.barras1) do 
			barra.other_actor = nil
		end
	end
	
	if (info.barras2) then
		for index, barra in ipairs (info.barras2) do 
			barra.icone:SetTexture (nil)
			barra.icone:SetTexCoord (0, 1, 0, 1)
		end
	end
	
	--> vamos passar os par�metros para dentro da tabela da janela...

	info.ativo = true --> sinaliza o addon que a janela esta aberta
	info.atributo = self.atributo --> instancia.atributo -> grava o atributo (damage, heal, etc)
	info.sub_atributo = self.sub_atributo --> instancia.sub_atributo -> grava o sub atributo (damage done, dps, damage taken, etc)
	info.jogador = jogador --> de qual jogador (objeto classe_damage)
	info.instancia = self --> salva a refer�ncia da inst�ncia que pediu o info
	
	info.target_text = Loc ["STRING_TARGETS"] .. ":"
	info.target_member = "total"
	info.target_persecond = false
	
	info.mostrando = nil
	
	local nome = info.jogador.nome --> nome do jogador
	local atributo_nome = sub_atributos[info.atributo].lista [info.sub_atributo] .. " " .. Loc ["STRING_ACTORFRAME_REPORTOF"] --> // nome do atributo // precisa ser o sub atributo correto???
	
	--> removendo o nome da realm do jogador
	if (nome:find ("-")) then
		nome = nome:gsub (("-.*"), "")
	end

	if (info.instancia.atributo == 1 and info.instancia.sub_atributo == 6) then --> enemy
		atributo_nome = sub_atributos [info.atributo].lista [1] .. " " .. Loc ["STRING_ACTORFRAME_REPORTOF"]
	end

	info.nome:SetText (nome)
	info.atributo_nome:SetText (atributo_nome)

	local serial = jogador.serial
	local avatar
	if (serial ~= "") then
		avatar = NickTag:GetNicknameTable (serial)
	end
	
	if (avatar and avatar [1]) then
		info.nome:SetText (avatar [1] or nome)
	end
	
	if (avatar and avatar [2]) then

		info.avatar:SetTexture (avatar [2])
		info.avatar_bg:SetTexture (avatar [4])
		if (avatar [5]) then
			info.avatar_bg:SetTexCoord (unpack (avatar [5]))
		end
		if (avatar [6]) then
			info.avatar_bg:SetVertexColor (unpack (avatar [6]))
		end
		
		info.avatar_nick:SetText (avatar [1] or nome)
		info.avatar_attribute:SetText (atributo_nome)
		
		info.avatar_attribute:SetPoint ("CENTER", info.avatar_nick, "CENTER", 0, 14)
		info.avatar:Show()
		info.avatar_bg:Show()
		info.avatar_bg:SetAlpha (.65)
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
	
	info.atributo_nome:SetPoint ("CENTER", info.nome, "CENTER", 0, 14)
	
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
	
	--info.classe_icone:SetTexture ("Interface\\AddOns\\Details\\images\\"..classe:lower()) --> top left
	info.classe_icone:SetTexture ("Interface\\AddOns\\Details\\images\\classes") --> top left

	if (classe ~= "UNKNOW" and classe ~= "UNGROUPPLAYER") then

		
		info.classe_icone:SetTexCoord (_detalhes.class_coords [classe][1], _detalhes.class_coords [classe][2], _detalhes.class_coords [classe][3], _detalhes.class_coords [classe][4])
		if (jogador.enemy) then 
			--> completa com a borda
			--info.classe_iconePlus:SetTexture ("Interface\\AddOns\\Details\\images\\classes_plus")
			if (_detalhes.faction_against == "Horde") then
				--info.classe_iconePlus:SetTexCoord (0.25, 0.5, 0, 0.25)
				info.nome:SetTextColor (1, 91/255, 91/255, 1)
			else
				--info.classe_iconePlus:SetTexCoord (0, 0.25, 0, 0.25)
				info.nome:SetTextColor (151/255, 215/255, 1, 1)
			end
		else
			info.classe_iconePlus:SetTexture()
			info.nome:SetTextColor (1, 1, 1, 1)
		end
	else
		if (jogador.enemy) then 
			if (_detalhes.class_coords [_detalhes.faction_against]) then
				info.classe_icone:SetTexCoord (_unpack (_detalhes.class_coords [_detalhes.faction_against]))
				if (_detalhes.faction_against == "Horde") then
					info.nome:SetTextColor (1, 91/255, 91/255, 1)
				else
					info.nome:SetTextColor (151/255, 215/255, 1, 1)
				end
			else
				info.nome:SetTextColor (1, 1, 1, 1)
			end
		else
			--info.classe_icone:SetTexture ("Interface\\AddOns\\Details\\images\\monster")
			--info.classe_icone:SetTexCoord (0, 1, 0, 1)
			info.classe_icone:SetTexCoord (_detalhes.class_coords ["MONSTER"][1], _detalhes.class_coords ["MONSTER"][2], _detalhes.class_coords ["MONSTER"][3], _detalhes.class_coords ["MONSTER"][4])
		end
		
		info.classe_iconePlus:SetTexture()
	end
	
	info:ShowTabs()
	gump:Fade (info, 0)
	
	return jogador:MontaInfo()
end

-- for beta todo: info background need a major rewrite
function gump:TrocaBackgroundInfo()

	if (info.atributo == 1) then --> DANO
	
		if (info.sub_atributo == 1 or info.sub_atributo == 2) then --> damage done / dps
			if (info.tipo ~= 1) then --> janela com as divisorias
				info.bg1:SetTexture ([[Interface\AddOns\Details\images\info_window_background]])
				info.bg1_sec_texture:SetTexture (nil)
				info.tipo = 1
			end
			
			if (info.sub_atributo == 2) then
				info.targets:SetText (Loc ["STRING_TARGETS"] .. " " .. Loc ["STRING_ATTRIBUTE_DAMAGE_DPS"] .. ":")
				info.target_persecond = true
			else
				info.targets:SetText (Loc ["STRING_TARGETS"] .. ":")
			end
			
		elseif (info.sub_atributo == 3) then --> damage taken
			if (info.tipo ~= 2) then --> janela com fundo diferente
				info.bg1:SetTexture ([[Interface\AddOns\Details\images\info_window_background]])
				info.bg1_sec_texture:SetTexture ([[Interface\AddOns\Details\images\info_window_damagetaken]])
				info.tipo = 2
			end
			
			info.targets:SetText (Loc ["STRING_TARGETS"] .. ":")
			info.no_targets:Show()
			info.no_targets.text:Show()
			
		elseif (info.sub_atributo == 4) then --> friendly fire
			if (info.tipo ~= 3) then --> janela com fundo diferente
				info.bg1:SetTexture ([[Interface\AddOns\Details\images\info_window_background]])
				info.bg1_sec_texture:SetTexture ([[Interface\AddOns\Details\images\info_window_damagetaken]])
				info.tipo = 3
			end
			info.targets:SetText (Loc ["STRING_SPELLS"] .. ":")
			
		elseif (info.sub_atributo == 6) then --> enemies
			if (info.tipo ~= 3) then --> janela com fundo diferente
				info.bg1:SetTexture ([[Interface\AddOns\Details\images\info_window_background]])
				info.bg1_sec_texture:SetTexture ([[Interface\AddOns\Details\images\info_window_damagetaken]])
				info.tipo = 3
			end
			info.targets:SetText (Loc ["STRING_DAMAGE_TAKEN_FROM"])
		end
		
	elseif (info.atributo == 2) then --> HEALING
		if (info.sub_atributo == 1 or info.sub_atributo == 2 or info.sub_atributo == 3) then --> damage done / dps
			if (info.tipo ~= 1) then --> janela com as divisorias
				info.bg1:SetTexture ([[Interface\AddOns\Details\images\info_window_background]])
				info.bg1_sec_texture:SetTexture (nil)
				info.tipo = 1
			end
			
			if (info.sub_atributo == 3) then
				info.targets:SetText (Loc ["STRING_OVERHEALED"] .. ":")
				info.target_member = "overheal"
				info.target_text = Loc ["STRING_OVERHEALED"] .. ":"
			elseif (info.sub_atributo == 2) then
				info.targets:SetText (Loc ["STRING_TARGETS"] .. " " .. Loc ["STRING_ATTRIBUTE_HEAL_HPS"] .. ":")
				info.target_persecond = true
			else
				info.targets:SetText (Loc ["STRING_TARGETS"] .. ":")
			end
			
		elseif (info.sub_atributo == 4) then --> Healing taken
			if (info.tipo ~= 2) then --> janela com fundo diferente			
				info.bg1:SetTexture ([[Interface\AddOns\Details\images\info_window_background]])
				info.bg1_sec_texture:SetTexture ([[Interface\AddOns\Details\images\info_window_damagetaken]])
				info.tipo = 2
			end
			
			info.targets:SetText (Loc ["STRING_TARGETS"] .. ":")
			info.no_targets:Show()
			info.no_targets.text:Show()
		end
		
	elseif (info.atributo == 3) then --> REGEN
		if (info.tipo ~= 2) then --> janela com fundo diferente
			info.bg1:SetTexture ([[Interface\AddOns\Details\images\info_window_background]])
			info.bg1_sec_texture:SetTexture (nil)
			info.tipo = 2
		end
		info.targets:SetText ("Vindo de:")
	
	elseif (info.atributo == 4) then --> MISC
		if (info.tipo ~= 2) then --> janela com fundo diferente
			info.bg1:SetTexture ([[Interface\AddOns\Details\images\info_window_background]])
			info.bg1_sec_texture:SetTexture (nil)
			info.tipo = 2
		end
		info.targets:SetText (Loc ["STRING_TARGETS"] .. ":")
		
	end
end

--> self � qualquer coisa que chamar esta fun��o
------------------------------------------------------------------------------------------------------------------------------
-- � chamado pelo click no X e pelo reset do historico
function _detalhes:FechaJanelaInfo (fromEscape)
	if (info.ativo) then --> se a janela tiver aberta
		--janela_info:Hide()
		if (fromEscape) then
			gump:Fade (info, "in")
		else
			gump:Fade (info, 1)
		end
		info.ativo = false --> sinaliza o addon que a janela esta agora fechada
		
		--_detalhes.info_jogador.detalhes = nil
		info.jogador = nil
		info.atributo = nil
		info.sub_atributo = nil
		info.instancia = nil
		
		info.nome:SetText ("")
		info.atributo_nome:SetText ("")
		
		gump:JI_AtualizaContainerBarras (-1) --> reseta o frame das barras			
	end
end

--> esconde todas as barras das skills na janela de info
------------------------------------------------------------------------------------------------------------------------------
function gump:HidaAllBarrasInfo()
	local barras = _detalhes.janela_info.barras1
	for index = 1, #barras, 1 do
		barras [index]:Hide()
		barras [index].textura:SetStatusBarColor (1, 1, 1, 1)
		barras [index].on_focus = false
	end
end

--> esconde todas as barras dos alvos do jogador
------------------------------------------------------------------------------------------------------------------------------
function gump:HidaAllBarrasAlvo()
	local barras = _detalhes.janela_info.barras2
	for index = 1, #barras, 1 do
		barras [index]:Hide()
	end
end

--> esconde as 5 barras a direita na janela de info
------------------------------------------------------------------------------------------------------------------------------
function gump:HidaAllDetalheInfo()
	for i = 1, 5 do
		gump:HidaDetalheInfo (i)
	end
	for _, barra in _ipairs (info.barras3) do 
		barra:Hide()
	end
	_detalhes.janela_info.spell_icone:SetTexture ("")
end


--> seta os scripts da janela de informa��es
local mouse_down_func = function (self, button)
	if (button == "LeftButton") then
		info:StartMoving()
		info.isMoving = true
	elseif (button == "RightButton" and not self.isMoving) then
		_detalhes:FechaJanelaInfo()
	end
end

local mouse_up_func = function (self, button)
	if (info.isMoving) then
		info:StopMovingOrSizing()
		info.isMoving = false
	end
end

------------------------------------------------------------------------------------------------------------------------------
local function seta_scripts (este_gump)

	--> Janela
	este_gump:SetScript ("OnMouseDown", mouse_down_func)
	este_gump:SetScript ("OnMouseUp", mouse_up_func)

	este_gump.container_barras.gump:SetScript ("OnMouseDown", mouse_down_func)
	este_gump.container_barras.gump:SetScript ("OnMouseUp", mouse_up_func)
					
	este_gump.container_detalhes:SetScript ("OnMouseDown", mouse_down_func)
	este_gump.container_detalhes:SetScript ("OnMouseUp", mouse_up_func)

	este_gump.container_alvos.gump:SetScript ("OnMouseDown", mouse_down_func)
	este_gump.container_alvos.gump:SetScript ("OnMouseUp", mouse_up_func)

	--> bot�o fechar
	este_gump.fechar:SetScript ("OnClick", function (self) 
		_detalhes:FechaJanelaInfo()
	end)
end



------------------------------------------------------------------------------------------------------------------------------
function gump:HidaDetalheInfo (index)
	local info = _detalhes.janela_info.grupos_detalhes [index]
	info.nome:SetText ("")
	info.nome2:SetText ("")
	info.dano:SetText ("")
	info.dano_porcento:SetText ("")
	info.dano_media:SetText ("")
	info.dano_dps:SetText ("")
	info.bg:Hide()
end

--> cria a barra de detalhes a direita da janela de informa��es
------------------------------------------------------------------------------------------------------------------------------

local detalhe_infobg_onenter = function (self)
	gump:Fade (self.overlay, "OUT") 
	gump:Fade (self.reportar, "OUT")
end

local detalhe_infobg_onleave = function (self)
	gump:Fade (self.overlay, "IN")
	gump:Fade (self.reportar, "IN")
end

local detalhes_inforeport_onenter = function (self)
	gump:Fade (self:GetParent().overlay, "OUT")
	gump:Fade (self, "OUT")
end
local detalhes_inforeport_onleave = function (self)
	gump:Fade (self:GetParent().overlay, "IN")
	gump:Fade (self, "IN")
end

function gump:CriaDetalheInfo (index)

	local info = {}
	info.nome = _detalhes.janela_info.container_detalhes:CreateFontString (nil, "OVERLAY", "GameFontHighlightSmall")
	info.nome2 = _detalhes.janela_info.container_detalhes:CreateFontString (nil, "OVERLAY", "GameFontHighlightSmall")
	info.dano = _detalhes.janela_info.container_detalhes:CreateFontString (nil, "OVERLAY", "GameFontHighlightSmall")
	info.dano_porcento = _detalhes.janela_info.container_detalhes:CreateFontString (nil, "OVERLAY", "GameFontHighlightSmall")
	info.dano_media = _detalhes.janela_info.container_detalhes:CreateFontString (nil, "OVERLAY", "GameFontHighlightSmall")
	info.dano_dps = _detalhes.janela_info.container_detalhes:CreateFontString (nil, "OVERLAY", "GameFontHighlightSmall")
	
	info.bg = _CreateFrame ("StatusBar", nil, _detalhes.janela_info.container_detalhes)
	info.bg:SetStatusBarTexture ("Interface\\AddOns\\Details\\images\\bar_detalhes2")
	info.bg:SetMinMaxValues (0, 100)
	info.bg:SetValue (100)
	
	info.bg:SetWidth (219)
	info.bg:SetHeight (47)
	
	info.bg.overlay = info.bg:CreateTexture (nil, "ARTWORK")
	info.bg.overlay:SetTexture ("Interface\\AddOns\\Details\\images\\overlay_detalhes")
	info.bg.overlay:SetWidth (241)
	info.bg.overlay:SetHeight (61)
	info.bg.overlay:SetPoint ("TOPLEFT", info.bg, "TOPLEFT", -7, 6)
	gump:Fade (info.bg.overlay, 1)
	
	info.bg.reportar = gump:NewDetailsButton (info.bg, nil, nil, _detalhes.Reportar, _detalhes.janela_info, 10+index, 16, 16,
	--_detalhes.icones.report.up, _detalhes.icones.report.down, _detalhes.icones.report.disabled)
	"Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", nil, "DetailsJanelaInfoReport1")
	info.bg.reportar:SetPoint ("BOTTOMLEFT", info.bg.overlay, "BOTTOMRIGHT",  -33, 10)
	gump:Fade (info.bg.reportar, 1)
	
	info.bg:SetScript ("OnEnter", detalhe_infobg_onenter)
	info.bg:SetScript ("OnLeave", detalhe_infobg_onleave)

	info.bg.reportar:SetScript ("OnEnter", detalhes_inforeport_onenter)
	info.bg.reportar:SetScript ("OnLeave", detalhes_inforeport_onleave)

	info.bg_end = info.bg:CreateTexture (nil, "BACKGROUND")
	info.bg_end:SetHeight (47)
	info.bg_end:SetTexture ("Interface\\AddOns\\Details\\images\\bar_detalhes2_end")

	_detalhes.janela_info.grupos_detalhes [index] = info
end

--> determina qual a pocis�o que a barra de detalhes vai ocupar
------------------------------------------------------------------------------------------------------------------------------
function gump:SetaDetalheInfoAltura (index)
	local info = _detalhes.janela_info.grupos_detalhes [index]
	local janela =  _detalhes.janela_info.container_detalhes
	local altura = {-10, -63, -118, -173, -228}
	local x1 = 64
	local x2 = 160
	
	altura = altura [index]
	
	info.bg:SetPoint ("TOPLEFT", janela, "TOPLEFT", x1-2, altura+2)
	info.bg_end:SetPoint ("LEFT", info.bg, "LEFT", info.bg:GetValue()*2.19, 0)
	info.bg:Hide()
	
	info.nome:SetPoint ("TOPLEFT", janela, "TOPLEFT", x1, altura)
	info.nome2:SetPoint ("TOPLEFT", janela, "TOPLEFT", x2, altura)
	info.dano:SetPoint ("TOPLEFT", janela, "TOPLEFT", x1, altura + (-20))
	info.dano_porcento:SetPoint ("TOPLEFT", janela, "TOPLEFT", x2, altura + (-20))
	info.dano_media:SetPoint ("TOPLEFT", janela, "TOPLEFT", x1, altura + (-30))
	info.dano_dps:SetPoint ("TOPLEFT", janela, "TOPLEFT", x2, altura + (-30))
end

--> seta o conte�do da barra de detalhes
------------------------------------------------------------------------------------------------------------------------------
function gump:SetaDetalheInfoTexto (index, p, arg1, arg2, arg3, arg4, arg5, arg6)
	local info = _detalhes.janela_info.grupos_detalhes [index]
	
	if (p) then
		if (_type (p) == "table") then
			info.bg:SetValue (p.p)
			info.bg:SetStatusBarColor (p.c[1], p.c[2], p.c[3], p.c[4] or 1)
		else
			info.bg:SetValue (p)
			info.bg:SetStatusBarColor (1, 1, 1)
		end
		
		info.bg_end:SetPoint ("LEFT", info.bg, "LEFT", (info.bg:GetValue()*2.19)-6, 0)
		info.bg:Show()
	end
	
	if (info.IsPet) then 
		info.bg.PetIcon:Hide()
		info.bg.PetText:Hide()
		info.bg.PetDps:Hide()
		gump:Fade (info.bg.overlay, "IN")
		info.IsPet = false
	end
	
	if (arg1) then
		info.nome:SetText (arg1)
	end
	
	if (arg2) then
		info.dano:SetText (arg2)
	end
	
	if (arg3) then
		info.dano_porcento:SetText (arg3)
	end
	
	if (arg4) then
		info.dano_media:SetText (arg4)
	end
	
	if (arg5) then
		info.dano_dps:SetText (arg5)
	end
	
	if (arg6) then
		info.nome2:SetText (arg6)
	end
	
	info.nome:Show()
	info.dano:Show()
	info.dano_porcento:Show()
	info.dano_media:Show()
	info.dano_dps:Show()
	info.nome2:Show()
	
end

--> cria as 5 caixas de detalhes infos que ser�o usados
------------------------------------------------------------------------------------------------------------------------------
local function cria_barras_detalhes()
	_detalhes.janela_info.grupos_detalhes = {}

	gump:CriaDetalheInfo (1)
	gump:SetaDetalheInfoAltura (1)
	gump:CriaDetalheInfo (2)
	gump:SetaDetalheInfoAltura (2)
	gump:CriaDetalheInfo (3)
	gump:SetaDetalheInfoAltura (3)
	gump:CriaDetalheInfo (4)
	gump:SetaDetalheInfoAltura (4)
	gump:CriaDetalheInfo (5)
	gump:SetaDetalheInfoAltura (5)
end

--> cria os textos em geral da janela info
------------------------------------------------------------------------------------------------------------------------------
local function cria_textos (este_gump)
	este_gump.nome = este_gump:CreateFontString (nil, "OVERLAY", "QuestFont_Large")
	este_gump.nome:SetPoint ("TOPLEFT", este_gump, "TOPLEFT", 105, -54)
	
	este_gump.atributo_nome = este_gump:CreateFontString (nil, "OVERLAY", "GameFontHighlightSmall")
	
	este_gump.targets = este_gump:CreateFontString (nil, "OVERLAY", "QuestFont_Large")
	este_gump.targets:SetPoint ("TOPLEFT", este_gump, "TOPLEFT", 24, -235)
	este_gump.targets:SetText (Loc ["STRING_TARGETS"] .. ":")

	este_gump.avatar = este_gump:CreateTexture (nil, "overlay")
	este_gump.avatar_bg = este_gump:CreateTexture (nil, "overlay")
	este_gump.avatar_attribute = este_gump:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
	este_gump.avatar_nick = este_gump:CreateFontString (nil, "overlay", "QuestFont_Large")
	este_gump.avatar:SetDrawLayer ("overlay", 3)
	este_gump.avatar_bg:SetDrawLayer ("overlay", 2)
	este_gump.avatar_nick:SetDrawLayer ("overlay", 4)
	
	este_gump.avatar:SetPoint ("TOPLEFT", este_gump, "TOPLEFT", 60, -10)
	este_gump.avatar_bg:SetPoint ("TOPLEFT", este_gump, "TOPLEFT", 60, -12)
	este_gump.avatar_bg:SetSize (275, 60)
	
	este_gump.avatar_nick:SetPoint ("TOPLEFT", este_gump, "TOPLEFT", 195, -54)
	
	este_gump.avatar:Hide()
	este_gump.avatar_bg:Hide()
	este_gump.avatar_nick:Hide()
	
end


--> esquerdo superior
local function cria_container_barras (este_gump)

	local container_barras_window = _CreateFrame ("ScrollFrame", "Details_Info_ContainerBarrasScroll", este_gump) 
	local container_barras = _CreateFrame ("Frame", "Details_Info_ContainerBarras", container_barras_window)

	container_barras_window:SetBackdrop({
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-gold-Border", tile = true, tileSize = 16, edgeSize = 5,
		insets = {left = 1, right = 1, top = 0, bottom = 1},})		
	container_barras_window:SetBackdropBorderColor (0, 0, 0, 0)
	
	container_barras:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
		insets = {left = 1, right = 1, top = 0, bottom = 1},})		
	container_barras:SetBackdropColor (0, 0, 0, 0)

	container_barras:SetAllPoints (container_barras_window)
	container_barras:SetWidth (300)
	container_barras:SetHeight (150)
	container_barras:EnableMouse (true)
	container_barras:SetResizable (false)
	container_barras:SetMovable (true)
	
	container_barras_window:SetWidth (300)
	container_barras_window:SetHeight (145)
	container_barras_window:SetScrollChild (container_barras)
	container_barras_window:SetPoint ("TOPLEFT", este_gump, "TOPLEFT", 21, -76)

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

	local container = _detalhes.janela_info.container_barras
	
	if (amt >= 9 and container.ultimo ~= amt) then
		local tamanho = 17*amt
		container.gump:SetHeight (tamanho)
		container.slider:Update()
		container.ultimo = amt
	elseif (amt < 8 and container.slider.ativo) then
		container.slider:Update (true)
		container.gump:SetHeight (140)
		container.scroll_ativo = false
		container.ultimo = 0
	end
end


function gump:JI_AtualizaContainerAlvos (amt)

	local container = _detalhes.janela_info.container_alvos
	
	if (amt >= 6 and container.ultimo ~= amt) then
		local tamanho = 17*amt
		container.gump:SetHeight (tamanho)
		container.slider:Update()
		container.ultimo = amt
	elseif (amt <= 5 and container.slider.ativo) then
		container.slider:Update (true)
		container.gump:SetHeight (100)
		container.scroll_ativo = false
		container.ultimo = 0
	end
end

--> container direita
local function cria_container_detalhes (este_gump)
	local container_detalhes = _CreateFrame ("Frame", "Details_Info_ContainerDetalhes", este_gump)
	
	container_detalhes:SetPoint ("TOPRIGHT", este_gump, "TOPRIGHT", -74, -76)
	container_detalhes:SetWidth (220)
	container_detalhes:SetHeight (270)
	container_detalhes:EnableMouse (true)
	container_detalhes:SetResizable (false)
	container_detalhes:SetMovable (true)
	
	este_gump.container_detalhes = container_detalhes
end

--> esquerdo inferior
local function cria_container_alvos (este_gump)
	local container_alvos_window = _CreateFrame ("ScrollFrame", "Details_Info_ContainerAlvosScroll", este_gump)
	local container_alvos = _CreateFrame ("Frame", "Details_Info_ContainerAlvos", container_alvos_window)

	container_alvos_window:SetBackdrop({
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-gold-Border", tile = true, tileSize = 16, edgeSize = 5,
		insets = {left = 1, right = 1, top = 0, bottom = 1},})		
	container_alvos_window:SetBackdropBorderColor (0,0,0,0)
	
	--container_alvos:SetBackdrop({
	--	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
	--	insets = {left = 1, right = 1, top = 0, bottom = 1},})		
	--container_alvos:SetBackdropColor (50/255, 50/255, 50/255, 0.6)
	
	container_alvos:SetAllPoints (container_alvos_window)
	container_alvos:SetWidth (300)
	container_alvos:SetHeight (100)
	container_alvos:EnableMouse (true)
	container_alvos:SetResizable (false)
	container_alvos:SetMovable (true)
	
	container_alvos_window:SetWidth (300)
	container_alvos_window:SetHeight (100)
	container_alvos_window:SetScrollChild (container_alvos)
	container_alvos_window:SetPoint ("BOTTOMLEFT", este_gump, "BOTTOMLEFT", 20, 6) --56 default

	gump:NewScrollBar (container_alvos_window, container_alvos, 7, 4)
	container_alvos_window.slider:Altura (88)
	container_alvos_window.slider:cimaPoint (0, 1)
	container_alvos_window.slider:baixoPoint (0, -3)
	
	container_alvos_window.gump = container_alvos
	este_gump.container_alvos = container_alvos_window
end

--> search key: ~create
function gump:CriaJanelaInfo()

	--> cria a janela em si
	local este_gump = info
	este_gump:SetFrameStrata ("MEDIUM")
	
	--> fehcar com o esc
	tinsert (UISpecialFrames, este_gump:GetName())

	--> propriedades da janela
	este_gump:SetPoint ("CENTER", UIParent)
	--este_gump:SetWidth (640)
	este_gump:SetWidth (590)
	este_gump:SetHeight (354)
	este_gump:EnableMouse (true)
	este_gump:SetResizable (false)
	este_gump:SetMovable (true)
	
	--> joga a janela para a global
	_detalhes.janela_info = este_gump
	
	--> come�a a montar as texturas <--
	
	--> icone da classe no canto esquerdo superior
	este_gump.classe_icone = este_gump:CreateTexture (nil, "BACKGROUND")
	este_gump.classe_icone:SetPoint ("TOPLEFT", este_gump, "TOPLEFT", 4, 0)
	este_gump.classe_icone:SetWidth (64)
	este_gump.classe_icone:SetHeight (64)
	este_gump.classe_icone:SetDrawLayer ("BACKGROUND", 1)
	--> complemento do icone
	este_gump.classe_iconePlus = este_gump:CreateTexture (nil, "BACKGROUND")
	este_gump.classe_iconePlus:SetPoint ("TOPLEFT", este_gump, "TOPLEFT", 4, 0)
	este_gump.classe_iconePlus:SetWidth (64)
	este_gump.classe_iconePlus:SetHeight (64)
	este_gump.classe_iconePlus:SetDrawLayer ("BACKGROUND", 2)
	
	--> top left
	este_gump.bg1 = este_gump:CreateTexture (nil, "BORDER")
	este_gump.bg1:SetPoint ("TOPLEFT", este_gump, "TOPLEFT", 0, 0)
	este_gump.bg1:SetDrawLayer ("BORDER", 1)
	
	function _detalhes:SetPlayerDetailsWindowTexture (texture)
		este_gump.bg1:SetTexture (texture)
	end
	_detalhes:SetPlayerDetailsWindowTexture ("Interface\\AddOns\\Details\\images\\info_window_background")

	--> bot�o de fechar
	este_gump.fechar = _CreateFrame ("Button", nil, este_gump, "UIPanelCloseButton")
	este_gump.fechar:SetWidth (32)
	este_gump.fechar:SetHeight (32)
	este_gump.fechar:SetPoint ("TOPRIGHT", este_gump, "TOPRIGHT", 5, -8)
	este_gump.fechar:SetText ("X")
	este_gump.fechar:SetFrameLevel (este_gump:GetFrameLevel()+2)

	este_gump.no_targets = este_gump:CreateTexture (nil, "overlay")
	este_gump.no_targets:SetPoint ("BOTTOMLEFT", este_gump, "BOTTOMLEFT", 20, 6)
	este_gump.no_targets:SetSize (301, 100)
	este_gump.no_targets:SetTexture ([[Interface\QUESTFRAME\UI-QUESTLOG-EMPTY-TOPLEFT]])
	este_gump.no_targets:SetTexCoord (0.015625, 1, 0.01171875, 0.390625)
	este_gump.no_targets:SetDesaturated (true)
	este_gump.no_targets:SetAlpha (.7)
	este_gump.no_targets.text = este_gump:CreateFontString (nil, "overlay", "GameFontNormal")
	este_gump.no_targets.text:SetPoint ("center", este_gump.no_targets, "center")
	este_gump.no_targets.text:SetText (Loc ["STRING_NO_TARGET_BOX"])
	este_gump.no_targets.text:SetTextColor (1, 1, 1, .4)
	este_gump.no_targets:Hide()
	
	--> titulo
	gump:NewLabel (este_gump, este_gump, nil, "titulo", Loc ["STRING_PLAYER_DETAILS"], "GameFontHighlightLeft", 12, {227/255, 186/255, 4/255})
	este_gump.titulo:SetPoint ("center", este_gump, "center")
	este_gump.titulo:SetPoint ("top", este_gump, "top", 0, -18)
	
	--> cria os textos da janela
	cria_textos (este_gump)	
	
	--> cria o frama que vai abrigar as barras das habilidades
	cria_container_barras (este_gump)
	
	--> cria o container que vai abrirgar as 5 barras de detalhes
	cria_container_detalhes (este_gump)
	
	--> cria o container onde vai abrigar os alvos do jogador
	cria_container_alvos (este_gump)

	--> cria as 5 barras de detalhes a direita da janela
	cria_barras_detalhes()
	
	--> seta os scripts dos frames da janela
	seta_scripts (este_gump)

	--> vai armazenar os objetos das barras de habilidade
	este_gump.barras1 = {} 
	
	--> vai armazenar os objetos das barras de alvos
	este_gump.barras2 = {} 
	
	--> vai armazenar os objetos das barras da caixa especial da direita
	este_gump.barras3 = {} 


	--> bot�o de reportar da caixa da esquerda, onde fica as barras principais
	este_gump.report_esquerda = gump:NewDetailsButton (este_gump, este_gump, nil, _detalhes.Reportar, este_gump, 1, 16, 16,
	"Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", nil, "DetailsJanelaInfoReport2")
	--este_gump.report_esquerda:SetPoint ("BOTTOMLEFT", este_gump.container_barras, "TOPLEFT",  281, 3)
	este_gump.report_esquerda:SetPoint ("BOTTOMLEFT", este_gump.container_barras, "TOPLEFT",  33, 3)
	este_gump.report_esquerda:SetFrameLevel (este_gump:GetFrameLevel()+2)

	--> bot�o de reportar da caixa dos alvos
	este_gump.report_alvos = gump:NewDetailsButton (este_gump, este_gump, nil, _detalhes.Reportar, este_gump, 3, 16, 16,
	"Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", nil, "DetailsJanelaInfoReport3")
	este_gump.report_alvos:SetPoint ("BOTTOMRIGHT", este_gump.container_alvos, "TOPRIGHT",  -2, -1)
	este_gump.report_alvos:SetFrameLevel (3) --> solved inactive problem

	--> �cone da magia selecionada para mais detalhes
	este_gump.bg_icone_bg = este_gump:CreateTexture (nil, "ARTWORK")
	este_gump.bg_icone_bg:SetPoint ("TOPRIGHT", este_gump, "TOPRIGHT",  -15, -12)
	este_gump.bg_icone_bg:SetTexture ("Interface\\AddOns\\Details\\images\\icone_bg_fundo")
	este_gump.bg_icone_bg:SetDrawLayer ("ARTWORK", -1)
	este_gump.bg_icone_bg:Show()
	
	este_gump.bg_icone = este_gump:CreateTexture (nil, "OVERLAY")
	este_gump.bg_icone:SetPoint ("TOPRIGHT", este_gump, "TOPRIGHT",  -15, -12)
	este_gump.bg_icone:SetTexture ("Interface\\AddOns\\Details\\images\\icone_bg")
	este_gump.bg_icone:Show()
	
	--este_gump:Hide()
	
	este_gump.spell_icone = este_gump:CreateTexture (nil, "ARTWORK")
	este_gump.spell_icone:SetPoint ("BOTTOMRIGHT", este_gump.bg_icone, "BOTTOMRIGHT",  -19, 2)
	este_gump.spell_icone:SetWidth (35)
	este_gump.spell_icone:SetHeight (34)
	este_gump.spell_icone:SetDrawLayer ("ARTWORK", 0)
	este_gump.spell_icone:Show()
	
	--> coisinhas do lado do icone
	este_gump.apoio_icone_esquerdo = este_gump:CreateTexture (nil, "ARTWORK")
	este_gump.apoio_icone_direito = este_gump:CreateTexture (nil, "ARTWORK")
	este_gump.apoio_icone_esquerdo:SetTexture ("Interface\\PaperDollInfoFrame\\PaperDollSidebarTabs")
	este_gump.apoio_icone_direito:SetTexture ("Interface\\PaperDollInfoFrame\\PaperDollSidebarTabs")
	
	local apoio_altura = 13/256
	este_gump.apoio_icone_esquerdo:SetTexCoord (0, 1, 0, apoio_altura)
	este_gump.apoio_icone_direito:SetTexCoord (0, 1, apoio_altura+(1/256), apoio_altura+apoio_altura)
	
	este_gump.apoio_icone_esquerdo:SetPoint ("bottomright", este_gump.bg_icone, "bottomleft",  42, 0)
	este_gump.apoio_icone_direito:SetPoint ("bottomleft", este_gump.bg_icone, "bottomright",  -17, 0)
	
	este_gump.apoio_icone_esquerdo:SetWidth (64)
	este_gump.apoio_icone_esquerdo:SetHeight (13)
	este_gump.apoio_icone_direito:SetWidth (64)
	este_gump.apoio_icone_direito:SetHeight (13)

	--> bot�o de reportar da caixa da direita, onde est�o os 5 quadrados
	este_gump.report_direita = gump:NewDetailsButton (este_gump, este_gump, nil, _detalhes.Reportar, este_gump, 2, 16, 16,
	"Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", nil, "DetailsJanelaInfoReport4")
	este_gump.report_direita:SetPoint ("TOPRIGHT", este_gump, "TOPRIGHT",  -8, -57)	
	este_gump.report_direita:Hide()

	local red = "FFFFAAAA"
	local green = "FFAAFFAA"
	
	--> tabs:
	--> tab default
	_detalhes:CreatePlayerDetailsTab ("Summary", --[1] tab name
			function (tabOBject, playerObject) --[2] condition
				if (playerObject) then 
					return true 
				else 
					return false 
				end
			end, 
			nil, --[3] fill function
			function() --[4] onclick
				for _, tab in _ipairs (_detalhes.player_details_tabs) do
					tab.frame:Hide()
				end
			end,
			nil --[5] oncreate
			)
		
		--> search key: ~avoidance
		
		local avoidance_create = function (tab, frame)
		
		--> MAIN ICON
			local mainicon = frame:CreateTexture (nil, "artwork")
			mainicon:SetPoint ("topright", frame, "topright", -12, -12)
			mainicon:SetTexture ([[Interface\ACHIEVEMENTFRAME\UI-ACHIEVEMENT-SHIELDS]])
			mainicon:SetTexCoord (0, .5, .5, 1)
			mainicon:SetSize (64, 64)
			
			local tankname = frame:CreateFontString (nil, "artwork", "GameFontNormal")
			tankname:SetPoint ("right", mainicon, "left", -2, 2)
			tab.tankname = tankname
		
		--> Percent Desc
			local percent_desc = frame:CreateFontString (nil, "artwork", "GameFontNormal")
			percent_desc:SetText ("Percent values are comparisons with the previous try.")
			percent_desc:SetPoint ("bottomleft", frame, "bottomleft", 13, 13)
			percent_desc:SetTextColor (.5, .5, .5, 1)
		
		--> SUMMARY
			local summary_texture = frame:CreateTexture (nil, "artwork")
			summary_texture:SetPoint ("topleft", frame, "topleft", 10, -15)
			summary_texture:SetTexture ([[Interface\ACHIEVEMENTFRAME\UI-Achievement-HorizontalShadow]])
			summary_texture:SetSize (128, 16)
			local summary_text = frame:CreateFontString (nil, "artwork", "GameFontNormal")
			summary_text:SetText ("Summary")
			summary_text :SetPoint ("left", summary_texture, "left", 2, 0)
		
			--total damage received
			local damagereceived = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
			damagereceived:SetPoint ("topleft", frame, "topleft", 15, -35)
			damagereceived:SetText ("Total Damage Taken:") --> localize-me
			damagereceived:SetTextColor (.8, .8, .8, 1)
			local damagereceived_amt = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
			damagereceived_amt:SetPoint ("left", damagereceived,  "right", 2, 0)
			damagereceived_amt:SetText ("0")
			tab.damagereceived = damagereceived_amt
		
			--per second
			local damagepersecond = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
			damagepersecond:SetPoint ("topleft", frame, "topleft", 20, -50)
			damagepersecond:SetText ("Per Second:") --> localize-me
			local damagepersecond_amt = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
			damagepersecond_amt:SetPoint ("left", damagepersecond,  "right", 2, 0)
			damagepersecond_amt:SetText ("0")
			tab.damagepersecond = damagepersecond_amt
			
			--total absorbs
			local absorbstotal = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
			absorbstotal:SetPoint ("topleft", frame, "topleft", 15, -65)
			absorbstotal:SetText ("Total Absorbs:") --> localize-me
			absorbstotal:SetTextColor (.8, .8, .8, 1)
			local absorbstotal_amt = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
			absorbstotal_amt:SetPoint ("left", absorbstotal,  "right", 2, 0)
			absorbstotal_amt:SetText ("0")
			tab.absorbstotal = absorbstotal_amt
			
			--per second
			local absorbstotalpersecond = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
			absorbstotalpersecond:SetPoint ("topleft", frame, "topleft", 20, -80)
			absorbstotalpersecond:SetText ("Per Second:") --> localize-me
			local absorbstotalpersecond_amt = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
			absorbstotalpersecond_amt:SetPoint ("left", absorbstotalpersecond,  "right", 2, 0)
			absorbstotalpersecond_amt:SetText ("0")
			tab.absorbstotalpersecond = absorbstotalpersecond_amt
		
		--> MELEE
		
			local melee_texture = frame:CreateTexture (nil, "artwork")
			melee_texture:SetPoint ("topleft", frame, "topleft", 10, -100)
			melee_texture:SetTexture ([[Interface\ACHIEVEMENTFRAME\UI-Achievement-HorizontalShadow]])
			melee_texture:SetSize (128, 16)
			local melee_text = frame:CreateFontString (nil, "artwork", "GameFontNormal")
			melee_text:SetText ("Melee")
			melee_text :SetPoint ("left", melee_texture, "left", 2, 0)
			
			--dodge
			local dodge = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
			dodge:SetPoint ("topleft", frame, "topleft", 15, -120)
			dodge:SetText ("Dodge:") --> localize-me
			dodge:SetTextColor (.8, .8, .8, 1)
			local dodge_amt = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
			dodge_amt:SetPoint ("left", dodge,  "right", 2, 0)
			dodge_amt:SetText ("0")
			tab.dodge = dodge_amt

			local dodgepersecond = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
			dodgepersecond:SetPoint ("topleft", frame, "topleft", 20, -135)
			dodgepersecond:SetText ("Per Second:") --> localize-me
			local dodgepersecond_amt = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
			dodgepersecond_amt:SetPoint ("left", dodgepersecond,  "right", 2, 0)
			dodgepersecond_amt:SetText ("0")
			tab.dodgepersecond = dodgepersecond_amt
			
			-- parry
			local parry = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
			parry:SetPoint ("topleft", frame, "topleft", 15, -150)
			parry:SetText ("Parry:") --> localize-me
			parry:SetTextColor (.8, .8, .8, 1)
			local parry_amt = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
			parry_amt:SetPoint ("left", parry,  "right", 2, 0)
			parry_amt:SetText ("0")
			tab.parry = parry_amt
			
			local parrypersecond = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
			parrypersecond:SetPoint ("topleft", frame, "topleft", 20, -165)
			parrypersecond:SetText ("Per Second:") --> localize-me
			local parrypersecond_amt = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
			parrypersecond_amt:SetPoint ("left", parrypersecond,  "right", 2, 0)
			parrypersecond_amt:SetText ("0")
			tab.parrypersecond = parrypersecond_amt

		--> ABSORBS
		
			local absorb_texture = frame:CreateTexture (nil, "artwork")
			absorb_texture:SetPoint ("topleft", frame, "topleft", 200, -15)
			absorb_texture:SetTexture ([[Interface\ACHIEVEMENTFRAME\UI-Achievement-HorizontalShadow]])
			absorb_texture:SetSize (128, 16)
			local absorb_text = frame:CreateFontString (nil, "artwork", "GameFontNormal")
			absorb_text:SetText ("Absorb")
			absorb_text :SetPoint ("left", absorb_texture, "left", 2, 0)
		
			--full absorbs
			local fullsbsorbed = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
			fullsbsorbed:SetPoint ("topleft", frame, "topleft", 205, -35)
			fullsbsorbed:SetText ("Full Absorbs:") --> localize-me
			fullsbsorbed:SetTextColor (.8, .8, .8, 1)
			local fullsbsorbed_amt = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
			fullsbsorbed_amt:SetPoint ("left", fullsbsorbed,  "right", 2, 0)
			fullsbsorbed_amt:SetText ("0")
			tab.fullsbsorbed = fullsbsorbed_amt
			
			--partially absorbs
			local partiallyabsorbed = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
			partiallyabsorbed:SetPoint ("topleft", frame, "topleft", 205, -50)
			partiallyabsorbed:SetText ("Partially Absorbed:") --> localize-me
			partiallyabsorbed:SetTextColor (.8, .8, .8, 1)
			local partiallyabsorbed_amt = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
			partiallyabsorbed_amt:SetPoint ("left", partiallyabsorbed,  "right", 2, 0)
			partiallyabsorbed_amt:SetText ("0")
			tab.partiallyabsorbed = partiallyabsorbed_amt
		
			--partially absorbs per second
			local partiallyabsorbedpersecond = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
			partiallyabsorbedpersecond:SetPoint ("topleft", frame, "topleft", 210, -65)
			partiallyabsorbedpersecond:SetText ("Average:") --> localize-me
			local partiallyabsorbedpersecond_amt = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
			partiallyabsorbedpersecond_amt:SetPoint ("left", partiallyabsorbedpersecond,  "right", 2, 0)
			partiallyabsorbedpersecond_amt:SetText ("0")
			tab.partiallyabsorbedpersecond = partiallyabsorbedpersecond_amt
			
			--no absorbs
			local noabsorbs = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
			noabsorbs:SetPoint ("topleft", frame, "topleft", 205, -80)
			noabsorbs:SetText ("No Absorption:") --> localize-me
			noabsorbs:SetTextColor (.8, .8, .8, 1)
			local noabsorbs_amt = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
			noabsorbs_amt:SetPoint ("left", noabsorbs,  "right", 2, 0)
			noabsorbs_amt:SetText ("0")
			tab.noabsorbs = noabsorbs_amt
		
		--> HEALING
		
			local healing_texture = frame:CreateTexture (nil, "artwork")
			healing_texture:SetPoint ("topleft", frame, "topleft", 200, -100)
			healing_texture:SetTexture ([[Interface\ACHIEVEMENTFRAME\UI-Achievement-HorizontalShadow]])
			healing_texture:SetSize (128, 16)
			local healing_text = frame:CreateFontString (nil, "artwork", "GameFontNormal")
			healing_text:SetText ("Healing")
			healing_text :SetPoint ("left", healing_texture, "left", 2, 0)
			
			--self healing
			local selfhealing = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
			selfhealing:SetPoint ("topleft", frame, "topleft", 205, -120)
			selfhealing:SetText ("Self Healing:") --> localize-me
			selfhealing:SetTextColor (.8, .8, .8, 1)
			local selfhealing_amt = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
			selfhealing_amt:SetPoint ("left", selfhealing,  "right", 2, 0)
			selfhealing_amt:SetText ("0")
			tab.selfhealing = selfhealing_amt

			--self healing per second
			local selfhealingpersecond = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
			selfhealingpersecond:SetPoint ("topleft", frame, "topleft", 210, -135)
			selfhealingpersecond:SetText ("Per Second:") --> localize-me
			local selfhealingpersecond_amt = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
			selfhealingpersecond_amt:SetPoint ("left", selfhealingpersecond,  "right", 2, 0)
			selfhealingpersecond_amt:SetText ("0")
			tab.selfhealingpersecond = selfhealingpersecond_amt
		
			for i = 1, 5 do 
				local healer = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
				healer:SetPoint ("topleft", frame, "topleft", 205, -160 + ((i-1)*15)*-1)
				healer:SetText ("healer name:") --> localize-me
				healer:SetTextColor (.8, .8, .8, 1)
				local healer_amt = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
				healer_amt:SetPoint ("left", healer,  "right", 2, 0)
				healer_amt:SetText ("0")
				tab ["healer" .. i] = {healer, healer_amt}
			end
			
		--SPELLS
			local spells_texture = frame:CreateTexture (nil, "artwork")
			spells_texture:SetPoint ("topleft", frame, "topleft", 400, -80)
			spells_texture:SetTexture ([[Interface\ACHIEVEMENTFRAME\UI-Achievement-HorizontalShadow]])
			spells_texture:SetSize (128, 16)
			local spells_text = frame:CreateFontString (nil, "artwork", "GameFontNormal")
			spells_text:SetText ("Spells")
			spells_text :SetPoint ("left", spells_texture, "left", 2, 0)
			
			local frame_tooltip_onenter = function (self)
				if (self.spellid) then
					self:SetBackdrop ({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 512, edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", edgeSize = 8})
					self:SetBackdropColor (.5, .5, .5, .5)
					GameTooltip:SetOwner (self, "ANCHOR_TOPLEFT")
					GameTooltip:SetSpellByID (self.spellid)
					GameTooltip:Show()
				end
			end
			local frame_tooltip_onleave = function (self)
				if (self.spellid) then
					self:SetBackdrop (nil)
					GameTooltip:Hide()
				end
			end
			
			for i = 1, 10 do 
				local frame_tooltip = CreateFrame ("frame", nil, frame)
				frame_tooltip:SetPoint ("topleft", frame, "topleft", 405, -100 + ((i-1)*15)*-1)
				frame_tooltip:SetSize (150, 14)
				frame_tooltip:SetScript ("OnEnter", frame_tooltip_onenter)
				frame_tooltip:SetScript ("OnLeave", frame_tooltip_onleave)
				
				local icon = frame_tooltip:CreateTexture (nil, "artwork")
				icon:SetSize (14, 14)
				icon:SetPoint ("left", frame_tooltip, "left")
				
				local spell = frame_tooltip:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
				spell:SetPoint ("left", icon, "right", 2, 0)
				spell:SetText ("spell name:") --> localize-me
				spell:SetTextColor (.8, .8, .8, 1)
				
				local spell_amt = frame_tooltip:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
				spell_amt:SetPoint ("left", spell,  "right", 2, 0)
				spell_amt:SetText ("0")
				
				tab ["spell" .. i] = {spell, spell_amt, icon, frame_tooltip}
			end
		
		end
		
		local getpercent = function (value, lastvalue, elapsed_time, inverse)
			local ps = value / elapsed_time
			local diff
			
			if (lastvalue == 0) then
				diff = "+0%"
			else
				if (ps >= lastvalue) then
					local d = ps - lastvalue
					d = d / lastvalue * 100
					d = _math_floor (math.abs (d))

					if (d > 999) then
						d = "> 999"
					end
					
					if (inverse) then
						diff = "|c" .. green .. "+" .. d .. "%|r"
					else
						diff = "|c" .. red .. "+" .. d .. "%|r"
					end
				else
					local d = lastvalue - ps
					d = d / ps * 100
					d = _math_floor (math.abs (d))
					
					if (d > 999) then
						d = "> 999"
					end
					
					if (inverse) then
						diff = "|c" .. red .. "-" .. d .. "%|r"
					else
						diff = "|c" .. green .. "-" .. d .. "%|r"
					end
				end
			end
			
			return ps, diff
		end
		
		-- ~buff
		local spells_by_class = { --buffss uptime
			["DRUID"] = {
				[132402] = true, --savage defense
				[135286] = true, -- tooth and claw
			},
			["DEATHKNIGHT"] = {
				[145677] = true, --riposte
				[77535] = true, --blood shield
				--[49222] = true, --bone shield
				[51460] = true, --runic corruption
			},
			["MONK"] = {
				[115295] = true, --guard
				[115307] = true, --shuffle
				[115308] = true, --elusive brew
				--[128939] = true, --elusive brew
				[125359] = true, --tiger power
			},
			["PALADIN"] = {
				[132403] = true, --shield of the righteous
				[114163] = true, --eternal-flame
				[20925] = true, --sacred shield
			},
			["WARRIOR"] = {
				[145672] = true, --riposte
				[2565] = true, -- shield Block
				[871] = true, --shield wall
				[112048] = true, --shield barrier
			},
		}
		
		local avoidance_fill = function (tab, player, combat)

			local elapsed_time = combat:GetCombatTime()
			
			local last_combat = combat.previous_combat
			if (not last_combat or not last_combat [1]) then
				last_combat = combat
			end
			local last_actor = last_combat (1, player.nome)
			local n = player.nome
			if (n:find ("-")) then
				n = n:gsub (("-.*"), "")
			end
			tab.tankname:SetText ("Avoidance of\n" .. n) --> localize-me
			
			--> damage taken
				local playerdamage = combat (1, player.nome)
				
				local damagetaken = playerdamage.damage_taken
				local last_damage_received = 0
				if (last_actor) then
					last_damage_received = last_actor.damage_taken / last_combat:GetCombatTime()
				end
				
				tab.damagereceived:SetText (_detalhes:ToK2 (damagetaken))
				
				local ps, diff = getpercent (damagetaken, last_damage_received, elapsed_time)
				tab.damagepersecond:SetText (_detalhes:comma_value (_math_floor (ps)) .. " (" .. diff .. ")")

			--> absorbs
				local totalabsorbs = playerdamage.avoidance.overall.ABSORB_AMT
				local incomingtotal = damagetaken + totalabsorbs
				
				local last_total_absorbs = 0
				if (last_actor and last_actor.avoidance) then
					last_total_absorbs = last_actor.avoidance.overall.ABSORB_AMT / last_combat:GetCombatTime()
				end
				
				tab.absorbstotal:SetText (_detalhes:ToK2 (totalabsorbs) .. " (" .. _math_floor (totalabsorbs / incomingtotal * 100) .. "%)")
				
				local ps, diff = getpercent (totalabsorbs, last_total_absorbs, elapsed_time, true)
				tab.absorbstotalpersecond:SetText (_detalhes:comma_value (_math_floor (ps)) .. " (" .. diff .. ")")
				
			--> dodge
				local totaldodge = playerdamage.avoidance.overall.DODGE
				tab.dodge:SetText (totaldodge)
				
				local last_total_dodge = 0
				if (last_actor and last_actor.avoidance) then
					last_total_dodge = last_actor.avoidance.overall.DODGE / last_combat:GetCombatTime()
				end
				local ps, diff = getpercent (totaldodge, last_total_dodge, elapsed_time, true)
				tab.dodgepersecond:SetText ( string.format ("%.2f", ps) .. " (" .. diff .. ")")
			
			--> parry
				local totalparry = playerdamage.avoidance.overall.PARRY
				tab.parry:SetText (totalparry)
				
				local last_total_parry = 0
				if (last_actor and last_actor.avoidance) then
					last_total_parry = last_actor.avoidance.overall.PARRY / last_combat:GetCombatTime()
				end
				local ps, diff = getpercent (totalparry, last_total_parry, elapsed_time, true)
				tab.parrypersecond:SetText (string.format ("%.2f", ps) .. " (" .. diff .. ")")
				
			--> absorb
				local fullabsorb = playerdamage.avoidance.overall.FULL_ABSORBED
				local halfabsorb = playerdamage.avoidance.overall.PARTIAL_ABSORBED
				local halfabsorb_amt = playerdamage.avoidance.overall.PARTIAL_ABSORB_AMT
				local noabsorb = playerdamage.avoidance.overall.FULL_HIT
				
				tab.fullsbsorbed:SetText (fullabsorb)
				tab.partiallyabsorbed:SetText (halfabsorb)
				tab.noabsorbs:SetText (noabsorb)
				
				if (halfabsorb_amt > 0) then
					local average = halfabsorb_amt / halfabsorb --tenho o average
					local last_average = 0
					if (last_actor and last_actor.avoidance and last_actor.avoidance.overall.PARTIAL_ABSORBED > 0) then
						last_average = last_actor.avoidance.overall.PARTIAL_ABSORB_AMT / last_actor.avoidance.overall.PARTIAL_ABSORBED
					end
					
					local ps, diff = getpercent (halfabsorb_amt, last_average, halfabsorb, true)
					tab.partiallyabsorbedpersecond:SetText (_detalhes:comma_value (_math_floor (ps)) .. " (" .. diff .. ")")
				else
					tab.partiallyabsorbedpersecond:SetText ("0.00 (0%)")
				end
				

				
			--> healing
			
				local actor_heal = combat (2, player.nome)
				if (not actor_heal) then
					tab.selfhealing:SetText ("0")
					tab.selfhealingpersecond:SetText ("0 (0%)")
				else
					local last_actor_heal = last_combat (2, player.nome)
					local este_alvo = actor_heal.targets [player.nome]
					if (este_alvo) then
						local heal_total = este_alvo
						tab.selfhealing:SetText (_detalhes:ToK2 (heal_total))
						
						if (last_actor_heal) then
							local este_alvo = last_actor_heal.targets [player.nome]
							if (este_alvo) then
								local heal = este_alvo
								
								local last_heal = heal / last_combat:GetCombatTime()
								
								local ps, diff = getpercent (heal_total, last_heal, elapsed_time, true)
								tab.selfhealingpersecond:SetText (_detalhes:comma_value (_math_floor (ps)) .. " (" .. diff .. ")")
								
							else
								tab.selfhealingpersecond:SetText ("0 (0%)")
							end
						else
							tab.selfhealingpersecond:SetText ("0 (0%)")
						end
						
					else
						tab.selfhealing:SetText ("0")
						tab.selfhealingpersecond:SetText ("0 (0%)")
					end
					
					
					-- taken from healer
					local heal_from = actor_heal.healing_from
					local myReceivedHeal = {}
					
					for actorName, _ in pairs (heal_from) do 
						local thisActor = combat (2, actorName)
						local targets = thisActor.targets --> targets is a container with target classes
						local amount = targets [player.nome] or 0
						myReceivedHeal [#myReceivedHeal+1] = {actorName, amount, thisActor.classe}
					end
					
					table.sort (myReceivedHeal, _detalhes.Sort2) --> Sort2 sort by second index
					
					for i = 1, 5 do 
						local label1, label2 = unpack (tab ["healer" .. i])
						if (myReceivedHeal [i]) then
							local name = myReceivedHeal [i][1]
							if (name:find ("-")) then
								name = name:gsub (("-.*"), "")
							end
							label1:SetText (name .. ":")
							local class = myReceivedHeal [i][3]
							if (class) then
								local c = RAID_CLASS_COLORS [class]
								if (c) then
									label1:SetTextColor (c.r, c.g, c.b)
								end
							else
								label1:SetTextColor (.8, .8, .8, 1)
							end
							
							local last_actor = last_combat (2, myReceivedHeal [i][1])
							if (last_actor) then
								local targets = last_actor.targets
								local amount = targets [player.nome] or 0
								if (amount) then
									
									local last_heal = amount
									
									local ps, diff = getpercent (myReceivedHeal[i][2], last_heal, 1, true)
									label2:SetText ( _detalhes:ToK2 (myReceivedHeal[i][2] or 0) .. " (" .. diff .. ")")
									
								else
									label2:SetText ( _detalhes:ToK2 (myReceivedHeal[i][2] or 0))
								end
							else
								label2:SetText ( _detalhes:ToK2 (myReceivedHeal[i][2] or 0))
							end
							
							
						else
							label1:SetText ("-- -- -- --")
							label1:SetTextColor (.8, .8, .8, 1)
							label2:SetText ("")
						end
					end
				end
				
			--> Spells
				--> cooldowns
				
				local index_used = 1
				
				local misc_player = combat (4, player.nome)
				
				if (misc_player) then
					if (misc_player.cooldowns_defensive_spells) then
						local minha_tabela = misc_player.cooldowns_defensive_spells._ActorTable
						local cooldowns_usados = {}
						
						for _spellid, _tabela in pairs (minha_tabela) do
							cooldowns_usados [#cooldowns_usados+1] = {_spellid, _tabela.counter}
						end
						table.sort (cooldowns_usados, _detalhes.Sort2)
						
						if (#cooldowns_usados > 1) then
							for i = 1, #cooldowns_usados do
								local esta_habilidade = cooldowns_usados[i]
								local nome_magia, _, icone_magia = _GetSpellInfo (esta_habilidade[1])
								
								local label1, label2, icon1, framebg = unpack (tab ["spell" .. i])
								framebg.spellid = esta_habilidade[1]
								
								label1:SetText (nome_magia .. ":")
								label2:SetText (esta_habilidade[2])
								icon1:SetTexture (icone_magia)
								icon1:SetTexCoord (0.0625, 0.953125, 0.0625, 0.953125)
								
								index_used = index_used + 1
							end
						end
					end
				end

				--> buffs uptime
				if (index_used < 11) then
					if (misc_player.buff_uptime_spells) then
						local minha_tabela = misc_player.buff_uptime_spells._ActorTable
						
						local encounter_time = combat:GetCombatTime()
						
						for _spellid, _tabela in pairs (minha_tabela) do
							if (spells_by_class [player.classe] [_spellid] and index_used <= 10) then 
								local nome_magia, _, icone_magia = GetSpellInfo (_spellid)
								local label1, label2, icon1, framebg = unpack (tab ["spell" .. index_used])
								
								framebg.spellid = _spellid
								
								local t = _tabela.uptime / encounter_time * 100
								label1:SetText (nome_magia .. ":")
								local minutos, segundos = _math_floor (_tabela.uptime / 60), _math_floor (_tabela.uptime % 60)
								label2:SetText (minutos .. "m " .. segundos .. "s" .. " (" .. _math_floor (t) .. "%)")
								icon1:SetTexture (icone_magia)
								icon1:SetTexCoord (0.0625, 0.953125, 0.0625, 0.953125)
								
								index_used = index_used + 1
							end
						end
					end
				end
				
				for i = index_used, 10 do
					local label1, label2, icon1, framebg = unpack (tab ["spell" .. i])
					
					framebg.spellid = nil
					label1:SetText ("-- -- -- --")
					label2:SetText ("")
					icon1:SetTexture (nil)
				end
				
			--> habilidade usada para interromper

				
				
			
--[[
			
--]]
		end
		
		_detalhes:CreatePlayerDetailsTab ("Avoidance", --[1] tab name
			function (tabOBject, playerObject)  --[2] condition
				if (playerObject.isTank) then 
					return true 
				else 
					return false 
				end
			end, 
			
			avoidance_fill, --[3] fill function
			
			nil, --[4] onclick
			
			avoidance_create --[5] oncreate
			)
	
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		local target_texture = [[Interface\MINIMAP\TRACKING\Target]]
		local empty_text = ""
		
		local plus = red .. "-(" 
		local minor = green .. "+("

		local fill_compare_targets = function (self, player, other_players, target_pool)
			
			local offset = FauxScrollFrame_GetOffset (self)
			
			local frame2 = DetailsPlayerComparisonTarget2
			local frame3 = DetailsPlayerComparisonTarget3
			
			local total = player.total_without_pet
			
			if (not target_pool [1]) then
				for i = 1, 4 do 
					local bar = self.bars [i]
					local bar_2 = frame2.bars [i]
					local bar_3 = frame3.bars [i]
					
					bar [1]:SetTexture (nil)
					bar [2].lefttext:SetText (empty_text)
					bar [2].lefttext:SetTextColor (.5, .5, .5, 1)
					bar [2].righttext:SetText ("")
					bar [2]:SetValue (0)
					bar [3][4] = nil
					bar_2 [1]:SetTexture (nil)
					bar_2 [2].lefttext:SetText (empty_text)
					bar_2 [2].lefttext:SetTextColor (.5, .5, .5, 1)
					bar_2 [2].righttext:SetText ("")
					bar_2 [2]:SetValue (0)
					bar_2 [3][4] = nil
					bar_3 [1]:SetTexture (nil)
					bar_3 [2].lefttext:SetText (empty_text)
					bar_3 [2].lefttext:SetTextColor (.5, .5, .5, 1)
					bar_3 [2].righttext:SetText ("")
					bar_3 [2]:SetValue (0)
					bar_3 [3][4] = nil
				end
				
				return
			end
			
			local top = target_pool [1] [2]
			
			--player 2
			local player_2 = other_players [1]
			local player_2_target_pool
			local player_2_top
			if (player_2) then
				local player_2_target = player_2.targets
				player_2_target_pool = {}
				for target_name, amount in _pairs (player_2_target) do
					player_2_target_pool [#player_2_target_pool+1] = {target_name, amount}
				end
				table.sort (player_2_target_pool, _detalhes.Sort2)
				if (player_2_target_pool [1]) then
					player_2_top = player_2_target_pool [1] [2]
				else
					player_2_top = 0
				end
				--1 skill, 
			end

			--player 3
			local player_3 = other_players [2]
			local player_3_target_pool
			local player_3_top
			if (player_3) then
				local player_3_target = player_3.targets
				player_3_target_pool = {}
				for target_name, amount in _pairs (player_3_target) do 
					player_3_target_pool [#player_3_target_pool+1] = {target_name, amount}
				end
				table.sort (player_3_target_pool, _detalhes.Sort2)
				if (player_3_target_pool [1]) then
					player_3_top = player_3_target_pool [1] [2]
				else
					player_3_top = 0
				end
			end

			for i = 1, 4 do 
				local bar = self.bars [i]
				local bar_2 = frame2.bars [i]
				local bar_3 = frame3.bars [i]
				
				local index = i + offset
				local data = target_pool [index]
				
				if (data) then --[name] [total]
				
					local target_name = data [1]
					
					bar [1]:SetTexture (target_texture)
					bar [1]:SetDesaturated (true)
					bar [1]:SetAlpha (.7)
					
					bar [2].lefttext:SetText (index .. ". " .. target_name)
					bar [2].lefttext:SetTextColor (1, 1, 1, 1)
					bar [2].righttext:SetText (_detalhes:ToK2Min (data [2])) -- .. " (" .. _math_floor (data [2] / total * 100) .. "%)"
					bar [2]:SetValue (data [2] / top * 100)
					bar [3][1] = player.nome --name
					bar [3][2] = target_name
					bar [3][3] = data [2] --total
					bar [3][4] = player
					
					-- 2
					if (player_2) then

						local player_2_target_total
						local player_2_target_index
						
						for index, t in _ipairs (player_2_target_pool) do
							if (t[1] == target_name) then
								player_2_target_total = t[2]
								player_2_target_index = index
								break
							end
						end
						
						if (player_2_target_total) then
							bar_2 [1]:SetTexture (target_texture)
							bar_2 [1]:SetDesaturated (true)
							bar_2 [1]:SetAlpha (.7)
							
							bar_2 [2].lefttext:SetText (player_2_target_index .. ". " .. target_name)
							bar_2 [2].lefttext:SetTextColor (1, 1, 1, 1)
							
							if (data [2] > player_2_target_total) then
								local diff = data [2] - player_2_target_total
								local up = diff / player_2_target_total * 100
								up = _math_floor (up)
								if (up > 999) then
									up = ">" .. 999
								end
								bar_2 [2].righttext:SetText (_detalhes:ToK2Min (player_2_target_total) .. " |c" .. minor .. up .. "%)|r")
							else
								local diff = player_2_target_total - data [2]
								local down = diff / data [2] * 100
								down = _math_floor (down)
								if (down > 999) then
									down = ">" .. 999
								end
								bar_2 [2].righttext:SetText (_detalhes:ToK2Min (player_2_target_total) .. " |c" .. plus .. down .. "%)|r")
							end
							
							bar_2 [2]:SetValue (player_2_target_total / player_2_top * 100)
							bar_2 [3][1] = player_2.nome
							bar_2 [3][2] = target_name
							bar_2 [3][3] = player_2_target_total
							bar_2 [3][4] = player_2
							
						else
							bar_2 [1]:SetTexture (nil)
							bar_2 [2].lefttext:SetText (empty_text)
							bar_2 [2].lefttext:SetTextColor (.5, .5, .5, 1)
							bar_2 [2].righttext:SetText ("")
							bar_2 [2]:SetValue (0)
							bar_2 [3][4] = nil
						end
					else
						bar_2 [1]:SetTexture (nil)
						bar_2 [2].lefttext:SetText (empty_text)
						bar_2 [2].lefttext:SetTextColor (.5, .5, .5, 1)
						bar_2 [2].righttext:SetText ("")
						bar_2 [2]:SetValue (0)
						bar_2 [3][4] = nil
					end
					
					-- 3
					if (player_3) then

						local player_3_target_total
						local player_3_target_index
						
						for index, t in _ipairs (player_3_target_pool) do
							if (t[1] == target_name) then
								player_3_target_total = t[2]
								player_3_target_index = index
								break
							end
						end
						
						if (player_3_target_total) then
							bar_3 [1]:SetTexture (target_texture)
							bar_3 [1]:SetDesaturated (true)
							bar_3 [1]:SetAlpha (.7)
							
							bar_3 [2].lefttext:SetText (player_3_target_index .. ". " .. target_name)
							bar_3 [2].lefttext:SetTextColor (1, 1, 1, 1)
							
							if (data [2] > player_3_target_total) then
								local diff = data [2] - player_3_target_total
								local up = diff / player_3_target_total * 100
								up = _math_floor (up)
								if (up > 999) then
									up = ">" .. 999
								end
								bar_3 [2].righttext:SetText (_detalhes:ToK2Min (player_3_target_total) .. " |c" .. minor .. up .. "%)|r")
							else
								local diff = player_3_target_total - data [2]
								local down = diff / data [2] * 100
								down = _math_floor (down)
								if (down > 999) then
									down = ">" .. 999
								end
								bar_3 [2].righttext:SetText (_detalhes:ToK2Min (player_3_target_total) .. " |c" .. plus .. down .. "%)|r")
							end
							
							bar_3 [2]:SetValue (player_3_target_total / player_3_top * 100)
							bar_3 [3][1] = player_3.nome
							bar_3 [3][2] = target_name
							bar_3 [3][3] = player_3_target_total
							bar_3 [3][4] = player_3
							
						else
							bar_3 [1]:SetTexture (nil)
							bar_3 [2].lefttext:SetText (empty_text)
							bar_3 [2].lefttext:SetTextColor (.5, .5, .5, 1)
							bar_3 [2].righttext:SetText ("")
							bar_3 [2]:SetValue (0)
							bar_3 [3][4] = nil
						end
					else
						bar_3 [1]:SetTexture (nil)
						bar_3 [2].lefttext:SetText (empty_text)
						bar_3 [2].lefttext:SetTextColor (.5, .5, .5, 1)
						bar_3 [2].righttext:SetText ("")
						bar_3 [2]:SetValue (0)
						bar_3 [3][4] = nil
					end
					
				else
					bar [1]:SetTexture (nil)
					bar [2].lefttext:SetText (empty_text)
					bar [2].lefttext:SetTextColor (.5, .5, .5, 1)
					bar [2].righttext:SetText ("")
					bar [2]:SetValue (0)
					bar [3][4] = nil
					bar_2 [1]:SetTexture (nil)
					bar_2 [2].lefttext:SetText (empty_text)
					bar_2 [2].lefttext:SetTextColor (.5, .5, .5, 1)
					bar_2 [2].righttext:SetText ("")
					bar_2 [2]:SetValue (0)
					bar_2 [3][4] = nil
					bar_3 [1]:SetTexture (nil)
					bar_3 [2].lefttext:SetText (empty_text)
					bar_3 [2].lefttext:SetTextColor (.5, .5, .5, 1)
					bar_3 [2].righttext:SetText ("")
					bar_3 [2]:SetValue (0)
					bar_3 [3][4] = nil
				end
			end
			
		end

		local fill_compare_actors = function (self, player, other_players)
			
			--primeiro preenche a nossa barra
			local spells_sorted = {}
			for spellid, spelltable in _pairs (player.spells._ActorTable) do
				spells_sorted [#spells_sorted+1] = {spelltable, spelltable.total}
			end
			table.sort (spells_sorted, _detalhes.Sort2)
		
			self.player = player:Name()
		
			local offset = FauxScrollFrame_GetOffset (self)
		
			local total = player.total_without_pet
			local top = spells_sorted [1] [2]
			
			local frame2 = DetailsPlayerComparisonBox2
			frame2.player = other_players [1]:Name()
			local player_2_total = other_players [1].total_without_pet
			local player_2_spells_sorted = {}
			for spellid, spelltable in _pairs (other_players [1].spells._ActorTable) do
				player_2_spells_sorted [#player_2_spells_sorted+1] = {spelltable, spelltable.total}
			end
			table.sort (player_2_spells_sorted, _detalhes.Sort2)
			local player_2_top = player_2_spells_sorted [1] [2]
			local player_2_spell_info = {}
			for index, spelltable in _ipairs (player_2_spells_sorted) do 
				player_2_spell_info [spelltable[1].id] = index
			end
			
			local frame3 = DetailsPlayerComparisonBox3
			frame3.player = other_players [2] and other_players [2]:Name()
			local player_3_total = other_players [2] and other_players [2].total_without_pet
			local player_3_spells_sorted = {}
			local player_3_spell_info = {}
			local player_3_top
			
			if (other_players [2]) then
				for spellid, spelltable in _pairs (other_players [2].spells._ActorTable) do
					player_3_spells_sorted [#player_3_spells_sorted+1] = {spelltable, spelltable.total}
				end
				table.sort (player_3_spells_sorted, _detalhes.Sort2)
				player_3_top = player_3_spells_sorted [1] [2]
				for index, spelltable in _ipairs (player_3_spells_sorted) do 
					player_3_spell_info [spelltable[1].id] = index
				end
			end

			for i = 1, 9 do 
				local bar = self.bars [i]
				local index = i + offset
				
				local data = spells_sorted [index]
				
				if (data) then
					--seta no box principal
					local spellid = data [1].id
					local name, _, icon = _GetSpellInfo (spellid)
					bar [1]:SetTexture (icon)
					bar [2].lefttext:SetText (index .. ". " .. name)
					bar [2].lefttext:SetTextColor (1, 1, 1, 1)
					bar [2].righttext:SetText (_detalhes:ToK2Min (data [2])) -- .. " (" .. _math_floor (data [2] / total * 100) .. "%)"
					bar [2]:SetValue (data [2] / top * 100)
					bar [3][1] = data [1].counter --tooltip hits
					bar [3][2] = data [2] / data [1].counter --tooltip average
					bar [3][3] = _math_floor (data [1].c_amt / data [1].counter * 100) --tooltip critical
					bar [3][4] = spellid
					
					--seta no segundo box
					local player_2 = other_players [1]
					local spell = player_2.spells._ActorTable [spellid]
					local bar_2 = frame2.bars [i]
					
					-- ~compare
					if (spell) then
						bar_2 [1]:SetTexture (icon)
						bar_2 [2].lefttext:SetText (player_2_spell_info [spellid] .. ". " .. name)
						bar_2 [2].lefttext:SetTextColor (1, 1, 1, 1)
						
						if (spell.total == 0 and data [2] == 0) then
							bar_2 [2].righttext:SetText ("0 +(0%)")
							
						elseif (data [2] > spell.total) then
							if (spell.total > 0) then
								local diff = data [2] - spell.total
								local up = diff / spell.total * 100
								up = _math_floor (up)
								if (up > 999) then
									up = ">" .. 999
								end
								bar_2 [2].righttext:SetText (_detalhes:ToK2Min (spell.total) .. " |c" .. minor .. up .. "%)|r")
							else
								bar_2 [2].righttext:SetText ("0 +(0%)")
							end
							
						else
							if (data [2] > 0) then
								local diff = spell.total - data [2]
								local down = diff / data [2] * 100
								down = _math_floor (down)
								if (down > 999) then
									down = ">" .. 999
								end
								bar_2 [2].righttext:SetText (_detalhes:ToK2Min (spell.total) .. " |c" .. plus .. down .. "%)|r")
							else
								bar_2 [2].righttext:SetText ("0 +(0%)")
							end
						end
						
						bar_2 [2]:SetValue (spell.total / player_2_top * 100)
						bar_2 [3][1] = spell.counter --tooltip hits
						bar_2 [3][2] = spell.total / spell.counter --tooltip average
						bar_2 [3][3] = _math_floor (spell.c_amt / spell.counter * 100) --tooltip critical
					else
						bar_2 [1]:SetTexture (nil)
						bar_2 [2].lefttext:SetText (empty_text)
						bar_2 [2].lefttext:SetTextColor (.5, .5, .5, 1)
						bar_2 [2].righttext:SetText ("")
						bar_2 [2]:SetValue (0)
					end
					
					--seta o terceiro box
					local bar_3 = frame3.bars [i]
					
					if (player_3_total) then
						local player_3 = other_players [2]
						local spell = player_3.spells._ActorTable [spellid]
						
						if (spell) then
							bar_3 [1]:SetTexture (icon)
							bar_3 [2].lefttext:SetText (player_3_spell_info [spellid] .. ". " .. name)
							bar_3 [2].lefttext:SetTextColor (1, 1, 1, 1)
							
							if (spell.total == 0 and data [2] == 0) then
								bar_3 [2].righttext:SetText ("0 +(0%)")
								
							elseif (data [2] > spell.total) then
								if (spell.total > 0) then
									local diff = data [2] - spell.total
									local up = diff / spell.total * 100
									up = _math_floor (up)
									if (up > 999) then
										up = ">" .. 999
									end
									bar_3 [2].righttext:SetText (_detalhes:ToK2Min (spell.total) .. " |c" .. minor .. up .. "%)|r")
								else
									bar_3 [2].righttext:SetText ("0 +(0%)")
								end
							else
								if (data [2] > 0) then
									local diff = spell.total - data [2]
									local down = diff / data [2] * 100
									down = _math_floor (down)
									if (down > 999) then
										down = ">" .. 999
									end
									bar_3 [2].righttext:SetText (_detalhes:ToK2Min (spell.total) .. " |c" .. plus .. down .. "%)|r")
								else
									bar_3 [2].righttext:SetText ("0 +(0%)")
								end
							end
							
							bar_3 [2]:SetValue (spell.total / player_3_top * 100)
							bar_3 [3][1] = spell.counter --tooltip hits
							bar_3 [3][2] = spell.total / spell.counter --tooltip average
							bar_3 [3][3] = _math_floor (spell.c_amt / spell.counter * 100) --tooltip critical
						else
							bar_3 [1]:SetTexture (nil)
							bar_3 [2].lefttext:SetText (empty_text)
							bar_3 [2].lefttext:SetTextColor (.5, .5, .5, 1)
							bar_3 [2].righttext:SetText ("")
							bar_3 [2]:SetValue (0)
						end
					else
						bar_3 [1]:SetTexture (nil)
						bar_3 [2].lefttext:SetText (empty_text)
						bar_3 [2].lefttext:SetTextColor (.5, .5, .5, 1)
						bar_3 [2].righttext:SetText ("")
						bar_3 [2]:SetValue (0)
					end
				else
					bar [1]:SetTexture (nil)
					bar [2].lefttext:SetText (empty_text)
					bar [2].lefttext:SetTextColor (.5, .5, .5, 1)
					bar [2].righttext:SetText ("")
					bar [2]:SetValue (0)
					local bar_2 = frame2.bars [i]
					bar_2 [1]:SetTexture (nil)
					bar_2 [2].lefttext:SetText (empty_text)
					bar_2 [2].lefttext:SetTextColor (.5, .5, .5, 1)
					bar_2 [2].righttext:SetText ("")
					bar_2 [2]:SetValue (0)
					local bar_3 = frame3.bars [i]
					bar_3 [1]:SetTexture (nil)
					bar_3 [2].lefttext:SetText (empty_text)
					bar_3 [2].lefttext:SetTextColor (.5, .5, .5, 1)
					bar_3 [2].righttext:SetText ("")
					bar_3 [2]:SetValue (0)
				end
				
			end
			
			for index, spelltable in _ipairs (spells_sorted) do
				
			end
			
		end
	
		local refresh_comparison_box = function (self)
			--atualiza a scroll
			FauxScrollFrame_Update (self, math.max (self.tab.spells_amt, 10), 9, 15)
			fill_compare_actors (self, self.tab.player, self.tab.players)
		end
		
		local refresh_target_box = function (self)
			
			--player 1 targets
			local my_targets = self.tab.player.targets
			local target_pool = {}
			for target_name, amount in _pairs (my_targets) do 
				target_pool [#target_pool+1] = {target_name, amount}
			end
			table.sort (target_pool, _detalhes.Sort2)
			
			FauxScrollFrame_Update (self, math.max (#target_pool, 5), 4, 14)

			fill_compare_targets (self, self.tab.player, self.tab.players, target_pool)
		end
	
		local compare_fill = function (tab, player, combat)
			local players_to_compare = tab.players
			
			DetailsPlayerComparisonBox1.name_label:SetText (player:Name())
			
			local label2 = _G ["DetailsPlayerComparisonBox2"].name_label
			local label3 = _G ["DetailsPlayerComparisonBox3"].name_label
			
			if (players_to_compare [1]) then
				label2:SetText (players_to_compare [1]:Name())
			end
			if (players_to_compare [2]) then
				label3:SetText (players_to_compare [2]:Name())
			else
				label3:SetText ("Player 3")
			end
			
			refresh_comparison_box (DetailsPlayerComparisonBox1)
			refresh_target_box (DetailsPlayerComparisonTarget1)
			
		end
	
		local on_enter_target = function (self)
		
			local frame1 = DetailsPlayerComparisonTarget1
			local frame2 = DetailsPlayerComparisonTarget2
			local frame3 = DetailsPlayerComparisonTarget3
		
			local bar1 = frame1.bars [self.index]
			local bar2 = frame2.bars [self.index]
			local bar3 = frame3.bars [self.index]

			local player_1 = bar1 [3] [4]
			if (not player_1) then
				return
			end
			local player_2 = bar2 [3] [4]
			local player_3 = bar3 [3] [4]
			
			local target_name = bar1 [3] [2]
			
			frame1.tooltip:SetPoint ("bottomleft", bar1[2], "topleft", -18, 5)
			frame2.tooltip:SetPoint ("bottomleft", bar2[2], "topleft", -18, 5)
			frame3.tooltip:SetPoint ("bottomleft", bar3[2], "topleft", -18, 5)

			local actor1_total = bar1 [3] [3]
			local actor2_total = bar1 [3] [3]
			local actor3_total = bar1 [3] [3]
			
			-- player 1
			local player_1_skills = {}
			for spellid, spell in _pairs (player_1.spells._ActorTable) do
				for name, amount in _pairs (spell.targets) do
					if (name == target_name) then
						player_1_skills [#player_1_skills+1] = {spellid, amount}
					end
				end
			end
			table.sort (player_1_skills, _detalhes.Sort2)
			local player_1_top = player_1_skills [1] [2]
			
			-- player 2
			local player_2_skills = {}
			local player_2_top
			if (player_2) then
				for spellid, spell in _pairs (player_2.spells._ActorTable) do
					for name, amount in _pairs (spell.targets) do
						if (name == target_name) then
							player_2_skills [#player_2_skills+1] = {spellid, amount}
						end
					end
				end
				table.sort (player_2_skills, _detalhes.Sort2)
				player_2_top = player_2_skills [1] [2]
			end
			
			-- player 3
			local player_3_skills = {}
			local player_3_top
			if (player_3) then
				for spellid, spell in _pairs (player_3.spells._ActorTable) do
					for name, amount in _pairs (spell.targets) do
						if (name == target_name) then
							player_3_skills [#player_3_skills+1] = {spellid, amount}
						end
					end
				end
				table.sort (player_3_skills, _detalhes.Sort2)
				player_3_top = player_3_skills [1] [2]
			end
			
			-- build tooltip
			frame1.tooltip:Reset()
			frame2.tooltip:Reset()
			frame3.tooltip:Reset()
			
			frame1.tooltip:Show()
			frame2.tooltip:Show()
			frame3.tooltip:Show()
			
			local frame2_gotresults = false
			local frame3_gotresults = false
			
			for index, spell in _ipairs (player_1_skills) do
				local bar = frame1.tooltip.bars [index]
				if (not bar) then
					bar = frame1.tooltip:CreateBar()
				end
				
				local name, _, icon = _GetSpellInfo (spell[1])
				bar [1]:SetTexture (icon)
				bar [2].lefttext:SetText (index .. ". " .. name)
				bar [2].righttext:SetText (_detalhes:ToK2Min (spell [2]))
				bar [2]:SetValue (spell [2]/player_1_top*100)
				
				if (player_2) then
					local player_2_skill
					local found_skill = false
					for this_index, this_spell in _ipairs (player_2_skills) do
						if (spell [1] == this_spell[1]) then
							local bar = frame2.tooltip.bars [index]
							if (not bar) then
								bar = frame2.tooltip:CreateBar (index)
							end
							
							bar [1]:SetTexture (icon)
							bar [2].lefttext:SetText (this_index .. ". " .. name)
							
							if (spell [2] > this_spell [2]) then
								local diff = spell [2] - this_spell [2]
								local up = diff / this_spell [2] * 100
								up = _math_floor (up)
								if (up > 999) then
									up = ">" .. 999
								end
								bar [2].righttext:SetText (_detalhes:ToK2Min (this_spell [2]) .. " |c" .. minor .. up .. "%)|r")
							else
								local diff = this_spell [2] - spell [2]
								local down = diff / spell [2] * 100
								down = _math_floor (down)
								if (down > 999) then
									down = ">" .. 999
								end
								bar [2].righttext:SetText (_detalhes:ToK2Min (this_spell [2]) .. " |c" .. plus .. down .. "%)|r")
							end

							bar [2]:SetValue (this_spell [2]/player_2_top*100)
							found_skill = true
							frame2_gotresults = true
							break
						end
					end
					if (not found_skill) then
						local bar = frame2.tooltip.bars [index]
						if (not bar) then
							bar = frame2.tooltip:CreateBar (index)
						end
						bar [1]:SetTexture (nil)
						bar [2].lefttext:SetText ("")
						bar [2].righttext:SetText ("")
					end
				end
				
				if (player_3) then
					local player_3_skill
					local found_skill = false
					for this_index, this_spell in _ipairs (player_3_skills) do
						if (spell [1] == this_spell[1]) then
							local bar = frame3.tooltip.bars [index]
							if (not bar) then
								bar = frame3.tooltip:CreateBar (index)
							end
							
							bar [1]:SetTexture (icon)
							bar [2].lefttext:SetText (this_index .. ". " .. name)
							
							if (spell [2] > this_spell [2]) then
								local diff = spell [2] - this_spell [2]
								local up = diff / this_spell [2] * 100
								up = _math_floor (up)
								if (up > 999) then
									up = ">" .. 999
								end
								bar [2].righttext:SetText (_detalhes:ToK2Min (this_spell [2]) .. " |c" .. minor .. up .. "%)|r")
							else
								local diff = this_spell [2] - spell [2]
								local down = diff / spell [2] * 100
								down = _math_floor (down)
								if (down > 999) then
									down = ">" .. 999
								end
								bar [2].righttext:SetText (_detalhes:ToK2Min (this_spell [2]) .. " |c" .. plus .. down .. "%)|r")
							end

							bar [2]:SetValue (this_spell [2]/player_3_top*100)
							found_skill = true
							frame3_gotresults = true
							break
						end
					end
					if (not found_skill) then
						local bar = frame3.tooltip.bars [index]
						if (not bar) then
							bar = frame3.tooltip:CreateBar (index)
						end
						bar [1]:SetTexture (nil)
						bar [2].lefttext:SetText ("")
						bar [2].righttext:SetText ("")
					end
				end
				
			end
			
			frame1.tooltip:SetHeight ( (#player_1_skills*15) + 10)
			frame2.tooltip:SetHeight ( (#player_1_skills*15) + 10)
			frame3.tooltip:SetHeight ( (#player_1_skills*15) + 10)
			
			if (not frame2_gotresults) then
				frame2.tooltip:Hide()
			end
			if (not frame3_gotresults) then
				frame3.tooltip:Hide()
			end

		end
		
		local on_leave_target = function (self)
			local frame1 = DetailsPlayerComparisonTarget1
			local frame2 = DetailsPlayerComparisonTarget2
			local frame3 = DetailsPlayerComparisonTarget3
		
			local bar1 = frame1.bars [self.index]
			local bar2 = frame2.bars [self.index]
			local bar3 = frame3.bars [self.index]
		
			bar1[2]:SetStatusBarColor (.5, .5, .5, 1)
			bar1[2].icon:SetTexCoord (0, 1, 0, 1)
			bar2[2]:SetStatusBarColor (.5, .5, .5, 1)
			bar2[2].icon:SetTexCoord (0, 1, 0, 1)
			bar3[2]:SetStatusBarColor (.5, .5, .5, 1)
			bar3[2].icon:SetTexCoord (0, 1, 0, 1)
			
			frame1.tooltip:Hide()
			frame2.tooltip:Hide()
			frame3.tooltip:Hide()
		end
	
		local on_enter = function (self)
		
			local frame1 = DetailsPlayerComparisonBox1
			local frame2 = DetailsPlayerComparisonBox2
			local frame3 = DetailsPlayerComparisonBox3
		
			local bar1 = frame1.bars [self.index]
			local bar2 = frame2.bars [self.index]
			local bar3 = frame3.bars [self.index]

			frame1.tooltip:SetPoint ("bottomleft", bar1[2], "topleft", -18, 5)
			frame2.tooltip:SetPoint ("bottomleft", bar2[2], "topleft", -18, 5)
			frame3.tooltip:SetPoint ("bottomleft", bar3[2], "topleft", -18, 5)

			local spellid = bar1[3][4]
			local player1 = frame1.player
			local player2 = frame2.player
			local player3 = frame3.player
			
			local hits = bar1[3][1]
			local average = bar1[3][2]
			local critical = bar1[3][3]

			local player1_misc = info.instancia.showing (4, player1)
			local player2_misc = info.instancia.showing (4, player2)
			local player3_misc = info.instancia.showing (4, player3)
			
			local player1_uptime
			
			if (bar1[2].righttext:GetText()) then
				bar1[2]:SetStatusBarColor (1, 1, 1, 1)
				bar1[2].icon:SetTexCoord (.1, .9, .1, .9)
				frame1.tooltip.hits_label2:SetText (hits)
				frame1.tooltip.average_label2:SetText (_detalhes:ToK2Min (average))
				frame1.tooltip.crit_label2:SetText (critical .. "%")
				
				if (player1_misc) then
					local spell = player1_misc.debuff_uptime_spells and player1_misc.debuff_uptime_spells._ActorTable and player1_misc.debuff_uptime_spells._ActorTable [spellid]
					if (spell) then
						local minutos, segundos = _math_floor (spell.uptime/60), _math_floor (spell.uptime%60)
						player1_uptime = spell.uptime
						frame1.tooltip.uptime_label2:SetText (minutos .. "m" .. segundos .. "s")
					else
						frame1.tooltip.uptime_label2:SetText ("--x--x--")
					end
				else
					frame1.tooltip.uptime_label2:SetText ("--x--x--")
				end
				
				frame1.tooltip:Show()
			end
			
			if (bar2[2].righttext:GetText()) then
			
				bar2[2]:SetStatusBarColor (1, 1, 1, 1)
				bar2[2].icon:SetTexCoord (.1, .9, .1, .9)
				
				if (hits > bar2[3][1]) then
					local diff = hits - bar2[3][1]
					local up = diff / bar2[3][1] * 100
					up = _math_floor (up)
					if (up > 999) then
						up = ">" .. 999
					end
					frame2.tooltip.hits_label2:SetText (bar2[3][1] .. " |c" .. minor .. up .. "%)|r")
				else
					local diff = bar2[3][1] - hits
					local down = diff / hits * 100
					down = _math_floor (down)
					if (down > 999) then
						down = ">" .. 999
					end
					frame2.tooltip.hits_label2:SetText (bar2[3][1] .. " |c" .. plus .. down .. "%)|r")
				end
				
				if (average > bar2[3][2]) then
					local diff = average - bar2[3][2]
					local up = diff / bar2[3][2] * 100
					up = _math_floor (up)
					if (up > 999) then
						up = ">" .. 999
					end
					frame2.tooltip.average_label2:SetText (_detalhes:ToK2Min (bar2[3][2]) .. " |c" .. minor .. up .. "%)|r")
				else
					local diff = bar2[3][2] - average
					local down = diff / average * 100
					down = _math_floor (down)
					if (down > 999) then
						down = ">" .. 999
					end
					frame2.tooltip.average_label2:SetText (_detalhes:ToK2Min (bar2[3][2]) .. " |c" .. plus .. down .. "%)|r")
				end
				
				if (critical > bar2[3][3]) then
					local diff = critical - bar2[3][3]
					local up = diff / bar2[3][3] * 100
					up = _math_floor (up)
					if (up > 999) then
						up = ">" .. 999
					end
					frame2.tooltip.crit_label2:SetText (bar2[3][3] .. "%" .. " |c" .. minor .. up .. "%)|r")
				else
					local diff = bar2[3][3] - critical
					local down = diff / critical * 100
					down = _math_floor (down)
					if (down > 999) then
						down = ">" .. 999
					end
					frame2.tooltip.crit_label2:SetText (bar2[3][3] .. "%" .. " |c" .. plus .. down .. "%)|r")
				end
				
				if (player2_misc) then
					local spell = player2_misc.debuff_uptime_spells and player2_misc.debuff_uptime_spells._ActorTable and player2_misc.debuff_uptime_spells._ActorTable [spellid]
					if (spell and spell.uptime) then
						local minutos, segundos = _math_floor (spell.uptime/60), _math_floor (spell.uptime%60)
						
						if (not player1_uptime) then
							frame2.tooltip.uptime_label2:SetText (minutos .. "m" .. segundos .. "s (0%)|r")
						
						elseif (player1_uptime > spell.uptime) then
							local diff = player1_uptime - spell.uptime
							local up = diff / spell.uptime * 100
							up = _math_floor (up)
							if (up > 999) then
								up = ">" .. 999
							end
							frame2.tooltip.uptime_label2:SetText (minutos .. "m" .. segundos .. "s |c" .. minor .. up .. "%)|r")
						else
							local diff = spell.uptime - player1_uptime
							local down = diff / player1_uptime * 100
							down = _math_floor (down)
							if (down > 999) then
								down = ">" .. 999
							end
							frame2.tooltip.uptime_label2:SetText (minutos .. "m" .. segundos .. "s |c" .. plus .. down .. "%)|r")
						end
					else
						frame2.tooltip.uptime_label2:SetText ("--x--x--")
					end
				else
					frame2.tooltip.uptime_label2:SetText ("--x--x--")
				end

				frame2.tooltip:Show()
			end
			
			---------------------------------------------------
			
			if (bar3[2].righttext:GetText()) then
				bar3[2]:SetStatusBarColor (1, 1, 1, 1)
				bar3[2].icon:SetTexCoord (.1, .9, .1, .9)
				
				if (hits > bar3[3][1]) then
					local diff = hits - bar3[3][1]
					local up = diff / bar3[3][1] * 100
					up = _math_floor (up)
					if (up > 999) then
						up = ">" .. 999
					end
					frame3.tooltip.hits_label2:SetText (bar3[3][1] .. " |c" .. minor .. up .. "%)|r")
				else
					local diff = bar3[3][1] - hits
					local down = diff / hits * 100
					down = _math_floor (down)
					if (down > 999) then
						down = ">" .. 999
					end
					frame3.tooltip.hits_label2:SetText (bar3[3][1] .. " |c" .. plus .. down .. "%)|r")
				end

				if (average > bar3[3][2]) then
					local diff = average - bar3[3][2]
					local up = diff / bar3[3][2] * 100
					up = _math_floor (up)
					if (up > 999) then
						up = ">" .. 999
					end
					frame3.tooltip.average_label2:SetText (_detalhes:ToK2Min (bar3[3][2]) .. " |c" .. minor .. up .. "%)|r")
				else
					local diff = bar3[3][2] - average
					local down = diff / average * 100
					down = _math_floor (down)
					if (down > 999) then
						down = ">" .. 999
					end
					frame3.tooltip.average_label2:SetText (_detalhes:ToK2Min (bar3[3][2]) .. " |c" .. plus .. down .. "%)|r")
				end
				
				if (critical > bar3[3][3]) then
					local diff = critical - bar3[3][3]
					local up = diff / bar3[3][3] * 100
					up = _math_floor (up)
					if (up > 999) then
						up = ">" .. 999
					end
					frame3.tooltip.crit_label2:SetText (bar3[3][3] .. "%" .. " |c" .. minor .. up .. "%)|r")
				else
					local diff = bar3[3][3] - critical
					local down = diff / critical * 100
					down = _math_floor (down)
					if (down > 999) then
						down = ">" .. 999
					end
					frame3.tooltip.crit_label2:SetText (bar3[3][3] .. "%" .. " |c" .. plus .. down .. "%)|r")
				end

				if (player3_misc) then
					local spell = player3_misc.debuff_uptime_spells and player3_misc.debuff_uptime_spells._ActorTable and player3_misc.debuff_uptime_spells._ActorTable [spellid]
					if (spell and spell.uptime) then
						local minutos, segundos = _math_floor (spell.uptime/60), _math_floor (spell.uptime%60)
						
						if (not player1_uptime) then
							frame3.tooltip.uptime_label2:SetText (minutos .. "m" .. segundos .. "s (0%)|r")
							
						elseif (player1_uptime > spell.uptime) then
							local diff = player1_uptime - spell.uptime
							local up = diff / spell.uptime * 100
							up = _math_floor (up)
							if (up > 999) then
								up = ">" .. 999
							end
							frame3.tooltip.uptime_label2:SetText (minutos .. "m" .. segundos .. "s |c" .. minor .. up .. "%)|r")
						else
							local diff = spell.uptime - player1_uptime
							local down = diff / player1_uptime * 100
							down = _math_floor (down)
							if (down > 999) then
								down = ">" .. 999
							end
							frame3.tooltip.uptime_label2:SetText (minutos .. "m" .. segundos .. "s |c" .. plus .. down .. "%)|r")
						end
					else
						frame3.tooltip.uptime_label2:SetText ("--x--x--")
					end
				else
					frame3.tooltip.uptime_label2:SetText ("--x--x--")
				end
				
				frame3.tooltip:Show()
			end
		end
		
		local on_leave = function (self)
			local frame1 = DetailsPlayerComparisonBox1
			local frame2 = DetailsPlayerComparisonBox2
			local frame3 = DetailsPlayerComparisonBox3
		
			local bar1 = frame1.bars [self.index]
			local bar2 = frame2.bars [self.index]
			local bar3 = frame3.bars [self.index]
		
			bar1[2]:SetStatusBarColor (.5, .5, .5, 1)
			bar1[2].icon:SetTexCoord (0, 1, 0, 1)
			bar2[2]:SetStatusBarColor (.5, .5, .5, 1)
			bar2[2].icon:SetTexCoord (0, 1, 0, 1)
			bar3[2]:SetStatusBarColor (.5, .5, .5, 1)
			bar3[2].icon:SetTexCoord (0, 1, 0, 1)
			
			frame1.tooltip:Hide()
			frame2.tooltip:Hide()
			frame3.tooltip:Hide()
		end
	
		local compare_create = function (tab, frame)
		
			local create_bar = function (name, parent, index, main, is_target)
				local y = ((index-1) * -15) - 7
			
				local spellicon = parent:CreateTexture (nil, "overlay")
				spellicon:SetSize (14, 14)
				spellicon:SetPoint ("topleft", parent, "topleft", 4, y)
				spellicon:SetTexture ([[Interface\InventoryItems\WoWUnknownItem01]])
			
				local bar = CreateFrame ("StatusBar", name, parent)
				bar.index = index
				bar:SetPoint ("topleft", spellicon, "topright", 0, 0)
				bar:SetPoint ("topright", parent, "topright", -4, y)
				bar:SetStatusBarTexture ([[Interface\AddOns\Details\images\bar_serenity]])
				bar:SetStatusBarColor (.5, .5, .5, 1)
				bar:SetMinMaxValues (0, 100)
				bar:SetValue (100)
				bar:SetHeight (14)
				bar.icon = spellicon
				
				if (is_target) then
					bar:SetScript ("OnEnter", on_enter_target)
					bar:SetScript ("OnLeave", on_leave_target)
				else
					bar:SetScript ("OnEnter", on_enter)
					bar:SetScript ("OnLeave", on_leave)
				end
				
				bar.lefttext = bar:CreateFontString (nil, "OVERLAY", "GameFontHighlightSmall")

				local _, size, flags = bar.lefttext:GetFont()
				local font = SharedMedia:Fetch ("font", "Arial Narrow")
				bar.lefttext:SetFont (font, 11)
				
				bar.lefttext:SetPoint ("left", bar, "left", 2, 0)
				bar.lefttext:SetJustifyH ("left")
				bar.lefttext:SetTextColor (1, 1, 1, 1)
				bar.lefttext:SetNonSpaceWrap (true)
				bar.lefttext:SetWordWrap (false)
				if (main) then
					bar.lefttext:SetWidth (110)
				else
					bar.lefttext:SetWidth (70)
				end
				
				bar.righttext = bar:CreateFontString (nil, "OVERLAY", "GameFontHighlightSmall")
				
				local _, size, flags = bar.righttext:GetFont()
				local font = SharedMedia:Fetch ("font", "Arial Narrow")
				bar.righttext:SetFont (font, 11)
				
				bar.righttext:SetPoint ("right", bar, "right", -2, 0)
				bar.righttext:SetJustifyH ("right")
				bar.righttext:SetTextColor (1, 1, 1, 1)
				
				tinsert (parent.bars, {spellicon, bar, {0, 0, 0}})
			end
			
			local create_tooltip = function (name)
				local tooltip = CreateFrame ("frame", name, UIParent)
				tooltip:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], tile = true, tileSize = 16, edgeSize = 12, insets = {left = 1, right = 1, top = 1, bottom = 1},})	
				tooltip:SetBackdropColor (0, 0, 0, 1)
				tooltip:SetSize (175, 67)
				tooltip:SetFrameStrata ("tooltip")
				
				local background = tooltip:CreateTexture (nil, "artwork")
				background:SetTexture ([[Interface\SPELLBOOK\Spellbook-Page-1]])
				background:SetTexCoord (.6, 0.1, 0, 0.64453125)
				background:SetVertexColor (1, 1, 1, 0.2)
				background:SetPoint ("topleft", tooltip, "topleft", 2, -4)
				background:SetPoint ("bottomright", tooltip, "bottomright", -4, 2)
				
				tooltip.hits_label = tooltip:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
				tooltip.hits_label:SetPoint ("topleft", tooltip, "topleft", 10, -10)
				tooltip.hits_label:SetText ("Total Hits:")
				tooltip.hits_label:SetJustifyH ("left")
				tooltip.hits_label2 = tooltip:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
				tooltip.hits_label2:SetPoint ("topright", tooltip, "topright", -10, -10)
				tooltip.hits_label2:SetText ("0")
				tooltip.hits_label2:SetJustifyH ("right")
				
				tooltip.average_label = tooltip:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
				tooltip.average_label:SetPoint ("topleft", tooltip, "topleft", 10, -22)
				tooltip.average_label:SetText ("Average:")
				tooltip.average_label:SetJustifyH ("left")
				tooltip.average_label2 = tooltip:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
				tooltip.average_label2:SetPoint ("topright", tooltip, "topright", -10, -22)
				tooltip.average_label2:SetText ("0")
				tooltip.average_label2:SetJustifyH ("right")
				
				tooltip.crit_label = tooltip:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
				tooltip.crit_label:SetPoint ("topleft", tooltip, "topleft", 10, -34)
				tooltip.crit_label:SetText ("Critical:")
				tooltip.crit_label:SetJustifyH ("left")
				tooltip.crit_label2 = tooltip:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
				tooltip.crit_label2:SetPoint ("topright", tooltip, "topright", -10, -34)
				tooltip.crit_label2:SetText ("0")
				tooltip.crit_label2:SetJustifyH ("right")
				
				tooltip.uptime_label = tooltip:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
				tooltip.uptime_label:SetPoint ("topleft", tooltip, "topleft", 10, -46)
				tooltip.uptime_label:SetText ("Uptime:")
				tooltip.uptime_label:SetJustifyH ("left")
				tooltip.uptime_label2 = tooltip:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
				tooltip.uptime_label2:SetPoint ("topright", tooltip, "topright", -10, -46)
				tooltip.uptime_label2:SetText ("0")
				tooltip.uptime_label2:SetJustifyH ("right")
				
				return tooltip
			end

			local create_tooltip_target = function (name)
				local tooltip = CreateFrame ("frame", name, UIParent)
				tooltip:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], tile = true, tileSize = 16, edgeSize = 12, insets = {left = 1, right = 1, top = 1, bottom = 1},})	
				tooltip:SetBackdropColor (0, 0, 0, 1)
				tooltip:SetSize (175, 67)
				tooltip:SetFrameStrata ("tooltip")
				tooltip.bars = {}
				
				function tooltip:Reset()
					for index, bar in _ipairs (tooltip.bars) do 
						bar [1]:SetTexture (nil)
						bar [2].lefttext:SetText ("")
						bar [2].righttext:SetText ("")
						bar [2]:SetValue (0)
					end
				end
				
				function tooltip:CreateBar (index)
				
					if (index) then
						if (index > #tooltip.bars+1) then
							for i = #tooltip.bars+1, index-1 do
								tooltip:CreateBar()
							end
						end
					end
				
					local index = #tooltip.bars+1
					local y = ((index-1) * -15) - 7
					local parent = tooltip
				
					local spellicon = parent:CreateTexture (nil, "overlay")
					spellicon:SetSize (14, 14)
					spellicon:SetPoint ("topleft", parent, "topleft", 4, y)
					spellicon:SetTexture ([[Interface\InventoryItems\WoWUnknownItem01]])
				
					local bar = CreateFrame ("StatusBar", name .. "Bar" .. index, parent)
					bar.index = index
					bar:SetPoint ("topleft", spellicon, "topright", 0, 0)
					bar:SetPoint ("topright", parent, "topright", -4, y)
					bar:SetStatusBarTexture ([[Interface\AddOns\Details\images\bar_serenity]])
					bar:SetStatusBarColor (.5, .5, .5, 1)
					bar:SetMinMaxValues (0, 100)
					bar:SetValue (0)
					bar:SetHeight (14)
					bar.icon = spellicon
		
					bar.lefttext = bar:CreateFontString (nil, "OVERLAY", "GameFontHighlightSmall")
					local _, size, flags = bar.lefttext:GetFont()
					local font = SharedMedia:Fetch ("font", "Arial Narrow")
					bar.lefttext:SetFont (font, 11)					
					bar.lefttext:SetPoint ("left", bar, "left", 2, 0)
					bar.lefttext:SetJustifyH ("left")
					bar.lefttext:SetTextColor (1, 1, 1, 1)
					bar.lefttext:SetNonSpaceWrap (true)
					bar.lefttext:SetWordWrap (false)
					
					if (name:find ("1")) then
						bar.lefttext:SetWidth (110)
					else
						bar.lefttext:SetWidth (80)
					end
					
					bar.righttext = bar:CreateFontString (nil, "OVERLAY", "GameFontHighlightSmall")	
					local _, size, flags = bar.righttext:GetFont()
					local font = SharedMedia:Fetch ("font", "Arial Narrow")
					bar.righttext:SetFont (font, 11)					
					bar.righttext:SetPoint ("right", bar, "right", -2, 0)
					bar.righttext:SetJustifyH ("right")
					bar.righttext:SetTextColor (1, 1, 1, 1)
					
					local object = {spellicon, bar}
					tinsert (tooltip.bars, object)
					return object
				end
				
				local background = tooltip:CreateTexture (nil, "artwork")
				background:SetTexture ([[Interface\SPELLBOOK\Spellbook-Page-1]])
				background:SetTexCoord (.6, 0.1, 0, 0.64453125)
				background:SetVertexColor (0, 0, 0, 0.6)
				background:SetPoint ("topleft", tooltip, "topleft", 2, -4)
				background:SetPoint ("bottomright", tooltip, "bottomright", -4, 2)
				
				return tooltip
			end
			
			local frame1 = CreateFrame ("scrollframe", "DetailsPlayerComparisonBox1", frame, "FauxScrollFrameTemplate")
			frame1:SetScript ("OnVerticalScroll", function (self, offset) FauxScrollFrame_OnVerticalScroll (self, offset, 14, refresh_comparison_box) end)			
			frame1:SetSize (175, 150)
			frame1:SetPoint ("topleft", frame, "topleft", 10, -30)
			frame1:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 16, edgeSize = 10, insets = {left = 1, right = 1, top = 0, bottom = 1},})	
			frame1:SetBackdropColor (0, 0, 0, .7)
			frame1.bars = {}
			frame1.tab = tab
			frame1.tooltip = create_tooltip ("DetailsPlayerComparisonBox1Tooltip")
			
			local playername1 = frame1:CreateFontString (nil, "overlay", "GameFontNormal")
			playername1:SetPoint ("bottomleft", frame1, "topleft", 2, 0)
			playername1:SetText ("Player 1")
			frame1.name_label = playername1
			
			--criar as barras do frame1
			for i = 1, 9 do
				create_bar ("DetailsPlayerComparisonBox1Bar"..i, frame1, i, true)
			end

			--cria o box dos targets
			local target1 = CreateFrame ("scrollframe", "DetailsPlayerComparisonTarget1", frame, "FauxScrollFrameTemplate")
			target1:SetScript ("OnVerticalScroll", function (self, offset) FauxScrollFrame_OnVerticalScroll (self, offset, 14, refresh_target_box) end)			
			target1:SetSize (175, 70)
			target1:SetPoint ("topleft", frame1, "bottomleft", 0, -10)
			target1:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 16, edgeSize = 10, insets = {left = 1, right = 1, top = 0, bottom = 1},})	
			target1:SetBackdropColor (0, 0, 0, .7)
			target1.bars = {}
			target1.tab = tab
			target1.tooltip = create_tooltip_target ("DetailsPlayerComparisonTarget1Tooltip")
			
			--criar as barras do target1
			for i = 1, 4 do
				create_bar ("DetailsPlayerComparisonTarget1Bar"..i, target1, i, true, true)
			end
			
--------------------------------------------
			local frame2 = CreateFrame ("frame", "DetailsPlayerComparisonBox2", frame)
			local frame3 = CreateFrame ("frame", "DetailsPlayerComparisonBox3", frame)
			
			frame2:SetPoint ("topleft", frame1, "topright", 25, 0)
			frame2:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 16, edgeSize = 10, insets = {left = 1, right = 1, top = 0, bottom = 1},})	
			frame2:SetSize (170, 150)
			frame2:SetBackdropColor (0, 0, 0, .7)
			frame2.bars = {}
			frame2.tooltip = create_tooltip ("DetailsPlayerComparisonBox2Tooltip")
			
			local playername2 = frame2:CreateFontString (nil, "overlay", "GameFontNormal")
			playername2:SetPoint ("bottomleft", frame2, "topleft", 2, 0)
			playername2:SetText ("Player 2")
			frame2.name_label = playername2
			
			--criar as barras do frame2
			for i = 1, 9 do
				create_bar ("DetailsPlayerComparisonBox2Bar"..i, frame2, i)
			end
			
			--cria o box dos targets
			local target2 = CreateFrame ("frame", "DetailsPlayerComparisonTarget2", frame)
			target2:SetSize (170, 70)
			target2:SetPoint ("topleft", frame2, "bottomleft", 0, -10)
			target2:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 16, edgeSize = 10, insets = {left = 1, right = 1, top = 0, bottom = 1},})	
			target2:SetBackdropColor (0, 0, 0, .7)
			target2.bars = {}
			target2.tooltip = create_tooltip_target ("DetailsPlayerComparisonTarget2Tooltip")
			
			--criar as barras do target2
			for i = 1, 4 do
				create_bar ("DetailsPlayerComparisonTarget2Bar"..i, target2, i, nil, true)
			end
			
			frame3:SetPoint ("topleft", frame2, "topright", 5, 0)
			frame3:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 16, edgeSize = 10, insets = {left = 1, right = 1, top = 0, bottom = 1},})	
			frame3:SetSize (170, 150)
			frame3:SetBackdropColor (0, 0, 0, .7)
			frame3.bars = {}
			frame3.tooltip = create_tooltip ("DetailsPlayerComparisonBox3Tooltip")
			
			local playername3 = frame3:CreateFontString (nil, "overlay", "GameFontNormal")
			playername3:SetPoint ("bottomleft", frame3, "topleft", 2, 0)
			playername3:SetText ("Player 3")
			frame3.name_label = playername3
			
			--criar as barras do frame3
			for i = 1, 9 do
				create_bar ("DetailsPlayerComparisonBox3Bar"..i, frame3, i)
			end
			
			--cria o box dos targets
			local target3 = CreateFrame ("frame", "DetailsPlayerComparisonTarget3", frame)
			target3:SetSize (170, 70)
			target3:SetPoint ("topleft", frame3, "bottomleft", 0, -10)
			target3:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 16, edgeSize = 10, insets = {left = 1, right = 1, top = 0, bottom = 1},})	
			target3:SetBackdropColor (0, 0, 0, .7)
			target3.bars = {}
			target3.tooltip = create_tooltip_target ("DetailsPlayerComparisonTarget3Tooltip")
			
			--criar as barras do target1
			for i = 1, 4 do
				create_bar ("DetailsPlayerComparisonTarget3Bar"..i, target3, i, nil, true)
			end
		end

		-- ~compare
		_detalhes:CreatePlayerDetailsTab ("Compare", --[1] tab name
			function (tabOBject, playerObject)  --[2] condition
			
				if (info.atributo > 2) then
					return false
				end

				local same_class = {}
				local class = playerObject.classe
				local my_spells = {}
				local my_spells_total = 0
				--> build my spell list
				for spellid, _ in _pairs (playerObject.spells._ActorTable) do
					my_spells [spellid] = true
					my_spells_total = my_spells_total + 1
				end
				
				tabOBject.players = {}
				tabOBject.player = playerObject
				tabOBject.spells_amt = my_spells_total
				
				for index, actor in _ipairs (info.instancia.showing [info.atributo]._ActorTable) do 
					if (actor.classe == class and actor ~= playerObject) then

						local same_spells = 0
						for spellid, _ in _pairs (actor.spells._ActorTable) do
							if (my_spells [spellid]) then
								same_spells = same_spells + 1
							end
						end
						
						local match_percentage = same_spells / my_spells_total * 100

						if (match_percentage > 30) then
							tinsert (tabOBject.players, actor)
						end
					end
				end
				
				if (#tabOBject.players > 0) then
					return true
				end
				
				return false
				--return true
			end, 
			
			compare_fill, --[3] fill function
			
			nil, --[4] onclick
			
			compare_create --[5] oncreate
		)
	
		function este_gump:ShowTabs()
			local amt_positive = 0

			for index = #_detalhes.player_details_tabs, 1, -1 do
				
				local tab = _detalhes.player_details_tabs [index]
				
				if (tab:condition (info.jogador, info.atributo, info.sub_atributo)) then
					tab:Show()
					amt_positive = amt_positive + 1
					tab:SetPoint ("BOTTOMLEFT", info.container_barras, "TOPLEFT",  390 - (67 * (amt_positive-1)), 1)
				else
					tab.frame:Hide()
					tab:Hide()
				end
			end
			
			if (amt_positive < 2) then
				--_detalhes.player_details_tabs[1]:Hide()
				_detalhes.player_details_tabs[1]:SetPoint ("BOTTOMLEFT", info.container_barras, "TOPLEFT",  390 - (67 * (2-1)), 1)
			end
			
			_detalhes.player_details_tabs[1]:Click()
			
		end

		este_gump:SetScript ("OnHide", function (self)
			_detalhes:FechaJanelaInfo()
			for _, tab in _ipairs (_detalhes.player_details_tabs) do
				tab:Hide()
				tab.frame:Hide()
			end
		end)
	
	--DetailsInfoWindowTab1Text:SetText ("Avoidance")
	este_gump.tipo = 1 --> tipo da janela // 1 = janela normal
	
	return este_gump
	
end

_detalhes.player_details_tabs = {}

function _detalhes:CreatePlayerDetailsTab (tabname, condition, fillfunction, onclick, oncreate)
	if (not tabname) then
		tabname = "unnamed"
	end

	local index = #_detalhes.player_details_tabs
	
	local newtab = CreateFrame ("button", "DetailsInfoWindowTab" .. index, info, "ChatTabTemplate")
	newtab:SetText (tabname)
	newtab:SetFrameStrata ("HIGH")
	newtab:Hide()
	
	newtab.condition = condition
	newtab.tabname = tabname
	newtab.onclick = onclick
	newtab.fillfunction = fillfunction
	newtab.last_actor = {}
	
	--> frame
	newtab.frame = CreateFrame ("frame", nil, UIParent)
	newtab.frame:SetFrameStrata ("HIGH")
	newtab.frame:EnableMouse (true)
	
	if (newtab.fillfunction) then
		newtab.frame:SetScript ("OnShow", function()
			if (newtab.last_actor == info.jogador) then
				return
			end
			newtab.last_actor = info.jogador
			newtab:fillfunction (info.jogador, info.instancia.showing)
		end)
	end
	
	if (oncreate) then
		oncreate (newtab, newtab.frame)
	end
	
	newtab.frame:SetBackdrop({
		bgFile = [[Interface\ACHIEVEMENTFRAME\UI-GuildAchievement-Parchment-Horizontal-Desaturated]], tile = true, tileSize = 512,
		edgeFile = [[Interface\ACHIEVEMENTFRAME\UI-Achievement-WoodBorder]], edgeSize = 32,
		insets = {left = 0, right = 0, top = 0, bottom = 0}})		
	newtab.frame:SetBackdropColor (.5, .50, .50, 1)
	
	newtab.frame:SetPoint ("TOPLEFT", info, "TOPLEFT", 19, -76)
	newtab.frame:SetSize (569, 274)
	
	newtab.frame:Hide()
	
	--> adicionar ao container
	_detalhes.player_details_tabs [#_detalhes.player_details_tabs+1] = newtab
	
	if (not onclick) then
		--> hide all tabs
		newtab:SetScript ("OnClick", function() 
			for _, tab in _ipairs (_detalhes.player_details_tabs) do
				tab.frame:Hide()
				tab.leftSelectedTexture:SetVertexColor (1, 1, 1, 1)
				tab.middleSelectedTexture:SetVertexColor (1, 1, 1, 1)
				tab.rightSelectedTexture:SetVertexColor (1, 1, 1, 1)
			end
			
			newtab.leftSelectedTexture:SetVertexColor (1, .7, 0, 1)
			newtab.middleSelectedTexture:SetVertexColor (1, .7, 0, 1)
			newtab.rightSelectedTexture:SetVertexColor (1, .7, 0, 1)
			newtab.frame:Show()
		end)
	else
		--> custom
		newtab:SetScript ("OnClick", function() 
			for _, tab in _ipairs (_detalhes.player_details_tabs) do
				tab.frame:Hide()
				tab.leftSelectedTexture:SetVertexColor (1, 1, 1, 1)
				tab.middleSelectedTexture:SetVertexColor (1, 1, 1, 1)
				tab.rightSelectedTexture:SetVertexColor (1, 1, 1, 1)
			end
			
			newtab.leftSelectedTexture:SetVertexColor (1, .7, 0, 1)
			newtab.middleSelectedTexture:SetVertexColor (1, .7, 0, 1)
			newtab.rightSelectedTexture:SetVertexColor (1, .7, 0, 1)
			
			onclick()
		end)
	end
	
	--> remove os scripts padroes
	newtab:SetScript ("OnDoubleClick", nil)
	newtab:SetScript ("OnEnter", nil)
	newtab:SetScript ("OnLeave", nil)
	newtab:SetScript ("OnDragStart", nil)

end

function _detalhes.janela_info:monta_relatorio (botao)
	
	local atributo = info.atributo
	local sub_atributo = info.sub_atributo
	local player = info.jogador
	local instancia = info.instancia

	local amt = _detalhes.report_lines
	
	local report_lines
	
	if (botao == 1) then --> bot�o da esquerda
		report_lines = {"Details! " .. Loc ["STRING_ACTORFRAME_SPELLSOF"] .. " " .. player.nome .. " (" .. _detalhes.sub_atributos [atributo].lista [sub_atributo] .. ")"}
		for index, barra in _ipairs (info.barras1) do 
			if (barra:IsShown()) then
				local spellid = barra.show
				if (spellid > 10) then
					local link = GetSpellLink (spellid)
					report_lines [#report_lines+1] = index .. ". " .. link .. ": " .. barra.texto_direita:GetText()
				else
					local spellname = barra.texto_esquerdo:GetText():gsub ((".*%."), "")
					spellname = spellname:gsub ("|c%x%x%x%x%x%x%x%x", "")
					spellname = spellname:gsub ("|r", "")
					report_lines [#report_lines+1] = index .. ". " .. spellname .. ": " .. barra.texto_direita:GetText()
				end
			end
			if (index == amt) then
				break
			end
		end
		
	elseif (botao == 3) then --> bot�o dos alvos
	
		if (atributo == 1 and sub_atributo == 3) then
			print (Loc ["STRING_ACTORFRAME_NOTHING"])
			return
		end
	
		report_lines = {"Details! " .. Loc ["STRING_ACTORFRAME_REPORTTARGETS"] .. " " .. _detalhes.sub_atributos [1].lista [1] .. " " .. Loc ["STRING_ACTORFRAME_REPORTOF"] .. " " .. player.nome}

		for index, barra in _ipairs (info.barras2) do
			if (barra:IsShown()) then
				report_lines [#report_lines+1] = barra.texto_esquerdo:GetText().." -> ".. barra.texto_direita:GetText()
			end
			if (index == amt) then
				break
			end
		end
		
	elseif (botao == 2) then --> bot�o da direita
	
			--> diferentes tipos de amostragem na caixa da direita
		     --dano                       --damage done                 --dps                                 --heal
		if ((atributo == 1 and (sub_atributo == 1 or sub_atributo == 2)) or (atributo == 2)) then
			if (not player.detalhes) then
				print (Loc ["STRING_ACTORFRAME_NOTHING"])
				return
			end
			local nome = _GetSpellInfo (player.detalhes)
			report_lines = {"Details! " .. Loc ["STRING_ACTORFRAME_REPORTTO"] .. " " .. _detalhes.sub_atributos [atributo].lista [sub_atributo] .. " " .. Loc ["STRING_ACTORFRAME_REPORTOF"] .. " " .. player.nome, 
			Loc ["STRING_ACTORFRAME_SPELLDETAILS"] .. ": " .. nome}
			
			for i = 1, 5 do
			
				--> pega os dados dos quadrados --> Aqui mostra o resumo de todos os quadrados...
				local caixa = info.grupos_detalhes [i]
				if (caixa.bg:IsShown()) then
				
					local linha = ""

					local nome2 = caixa.nome2:GetText() --> golpes
					if (nome2 and nome2 ~= "") then
						if (i == 1) then
							linha = linha..nome2.." / "
						else
							linha = linha..caixa.nome:GetText().." "..nome2.." / "
						end
					end			
					
					local dano = caixa.dano:GetText() --> dano
					if (dano and dano ~= "") then
						linha = linha..dano.." / "
					end
					
					local media = caixa.dano_media:GetText() --> media
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
		
			report_lines = {"Details! " .. Loc ["STRING_ACTORFRAME_REPORTTO"] .. " " .. _detalhes.sub_atributos [1].lista [1] .. " " .. Loc ["STRING_ACTORFRAME_REPORTOF"] .. " " .. player.detalhes.. " " .. Loc ["STRING_ACTORFRAME_REPORTAT"] .. " " .. player.nome}

			for index, barra in _ipairs (info.barras3) do 
			
				if (barra:IsShown()) then
					report_lines [#report_lines+1] = barra.texto_esquerdo:GetText().." -> ".. barra.texto_direita:GetText()
				end
				if (index == amt) then
					break
				end
				
			end
		end
		
	elseif (botao >= 11) then --> primeira caixa dos detalhes
		
		botao =  botao - 10
		
		local nome
		if (_type (spellid) == "string") then
			--> is a pet
		else
			nome = _GetSpellInfo (player.detalhes)
		end
		
		if (not nome) then
			nome = ""
		end
		report_lines = {"Details! " .. Loc ["STRING_ACTORFRAME_REPORTTO"] .. " " .. _detalhes.sub_atributos [atributo].lista [sub_atributo].. " " .. Loc ["STRING_ACTORFRAME_REPORTOF"] .. " " .. player.nome, 
		Loc ["STRING_ACTORFRAME_SPELLDETAILS"] .. ": " .. nome} 
		
		local caixa = info.grupos_detalhes [botao]
		
		local linha = ""
		local nome2 = caixa.nome2:GetText() --> golpes
		if (nome2 and nome2 ~= "") then
			if (i == 1) then
				linha = linha..nome2.." / "
			else
				linha = linha..caixa.nome:GetText().." "..nome2.." / "
			end
		end

		local dano = caixa.dano:GetText() --> dano
		if (dano and dano ~= "") then
			linha = linha..dano.." / "
		end

		local media = caixa.dano_media:GetText() --> media
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
	
	--local report_lines = {"Details! Relatorio para ".._detalhes.sub_atributos [self.atributo].lista [self.sub_atributo]}

	
	--> pega o conte�do da janela da direita
	
	return instancia:envia_relatorio (report_lines)
end

local row_on_enter = function (self)
	if (info.fading_in or info.faded) then
		return
	end
	
	self.mouse_over = true

	--> aumenta o tamanho da barra
	self:SetHeight (17) --> altura determinada pela inst�ncia
	--> poe a barra com alfa 1 ao inv�s de 0.9
	self:SetAlpha(1)

	--> troca a cor da barra enquanto o mouse estiver em cima dela
	self:SetBackdrop({
		--bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 16, edgeSize = 10,
		insets = {left = 1, right = 1, top = 0, bottom = 1},})	
	self:SetBackdropBorderColor (0.666, 0.666, 0.666)
	self:SetBackdropColor (0.0941, 0.0941, 0.0941)
	
	if (self.isAlvo) then --> monta o tooltip do alvo
		--> talvez devesse escurecer a janela no fundo... pois o tooltip � transparente e pode confundir
		GameTooltip:SetOwner (self, "ANCHOR_TOPRIGHT")
		
		-- ~erro
		if (self.spellid == "enemies") then --> damage taken enemies
			if (not self.minha_tabela or not self.minha_tabela:MontaTooltipDamageTaken (self, self._index, info.instancia)) then  -- > poderia ser aprimerado para uma tailcall
				return
			end
		
		elseif (not self.minha_tabela or not self.minha_tabela:MontaTooltipAlvos (self, self._index, info.instancia)) then  -- > poderia ser aprimerado para uma tailcall
			return
			
		end
		GameTooltip:Show()
		
	elseif (self.isMain) then
	
		if (IsShiftKeyDown()) then
			if (type (self.show) == "number") then
				GameTooltip:SetOwner (self, "ANCHOR_TOPRIGHT")
				GameTooltip:AddLine (Loc ["ABILITY_ID"] .. ": " .. self.show)
				GameTooltip:Show()	
			end
		end
	
		--> da zoom no icone
		self.icone:SetWidth (17)
		self.icone:SetHeight (17)	
		--> poe a alfa do icone em 1.0
		self.icone:SetAlpha (1)
		
		--> mostrar temporariamente o conteudo da barra nas caixas de detalhes
		if (not info.mostrando) then --> n�o esta mostrando nada na direita
			info.mostrando = self --> agora o mostrando � igual a esta barra
			info.mostrando_mouse_over = true --> o conteudo da direta esta sendo mostrado pq o mouse esta passando por cima do bagulho e n�o pq foi clicado
			info.showing = self._index --> diz  o index da barra que esta sendo mostrado na direita

			info.jogador.detalhes = self.show --> minha tabela = jogador = jogador.detales = spellid ou nome que esta sendo mostrado na direita
			info.jogador:MontaDetalhes (self.show, self, info.instancia) --> passa a spellid ou nome e a barra
		end
	end
end

local row_on_leave = function (self)
	if (self.fading_in or self.faded or not self:IsShown() or self.hidden) then
		return
	end

	self.mouse_over = false

	--> diminui o tamanho da barra
	self:SetHeight (16)
	--> volta com o alfa antigo da barra que era de 0.9
	self:SetAlpha(0.9)
	
	--> volto o background ao normal
	self:SetBackdrop({
		bgFile = "", edgeFile = "", tile = true, tileSize = 16, edgeSize = 32,
		insets = {left = 1, right = 1, top = 0, bottom = 1},})	
	self:SetBackdropBorderColor (0, 0, 0, 0)
	self:SetBackdropColor (0, 0, 0, 0)
	
	GameTooltip:Hide() 
	
	if (self.isMain) then
		--> retira o zoom no icone
		self.icone:SetWidth (14)
		self.icone:SetHeight (14)
		--> volta com a alfa antiga da barra
		self.icone:SetAlpha (0.8)
		
		--> remover o conte�do que estava sendo mostrado na direita
		if (info.mostrando_mouse_over) then
			info.mostrando = nil
			info.mostrando_mouse_over = false
			info.showing = nil
			
			info.jogador.detalhes = nil
			gump:HidaAllDetalheInfo()
		end
	end
end

local row_on_mousedown = function (self)
	if (self.fading_in) then
		return
	end

	self.mouse_down = _GetTime()
	local x, y = _GetCursorPosition()
	self.x = _math_floor (x)
	self.y = _math_floor (y)

	if ((not info.isLocked) or (info.isLocked == 0)) then
		info:StartMoving()
		info.isMoving = true
	end	
end

local row_on_mouseup = function (self)
	if (self.fading_in) then
		return
	end

	if (info.isMoving) then
		info:StopMovingOrSizing()
		info.isMoving = false
	end

	local x, y = _GetCursorPosition()
	x = _math_floor (x)
	y = _math_floor (y)
	if ((self.mouse_down+0.4 > _GetTime() and (x == self.x and y == self.y)) or (x == self.x and y == self.y)) then
		--> setar os textos
		
		if (self.isMain) then --> se n�o for uma barra de alvo
		
			local barra_antiga = info.mostrando			
			if (barra_antiga and not info.mostrando_mouse_over) then
			
				barra_antiga.textura:SetStatusBarColor (1, 1, 1, 1) --> volta a textura normal
				barra_antiga.on_focus = false --> n�o esta mais no foco

				--> CLICOU NA MESMA BARRA
				if (barra_antiga == self) then --> 
					info.mostrando_mouse_over = true
					return
					
				--> CLICOU EM OUTRA BARRA
				else --> clicou em outra barra e trocou o foco
					barra_antiga:SetAlpha (.9) --> volta a alfa antiga
				
					info.mostrando = self
					info.showing = i
					
					info.jogador.detalhes = self.show
					info.jogador:MontaDetalhes (self.show, self)
					
					self:SetAlpha (1)
					self.textura:SetStatusBarColor (129/255, 125/255, 69/255, 1)
					self.on_focus = true
					return
				end
			end
			
			--> N�O TINHA BARRAS PRECIONADAS
			-- info.mostrando = self
			info.mostrando_mouse_over = false
			self:SetAlpha (1)
			self.textura:SetStatusBarColor (129/255, 125/255, 69/255, 1)
			self.on_focus = true
		end
		
	end
end

local function SetBarraScripts (esta_barra, instancia, i)
	
	esta_barra._index = i
	
	esta_barra:SetScript ("OnEnter", row_on_enter)
	esta_barra:SetScript ("OnLeave", row_on_leave)

	esta_barra:SetScript ("OnMouseDown", row_on_mousedown)
	esta_barra:SetScript ("OnMouseUp", row_on_mouseup)

end

local function CriaTexturaBarra (instancia, barra)
	barra.textura = _CreateFrame ("StatusBar", nil, barra)
	barra.textura:SetAllPoints (barra)
	--barra.textura:SetStatusBarTexture (instancia.row_info.texture_file)
	barra.textura:SetStatusBarTexture (_detalhes.default_texture)
	barra.textura:SetStatusBarColor (.5, .5, .5, 0)
	barra.textura:SetMinMaxValues (0,100)
	
	if (barra.targets) then
		barra.targets:SetParent (barra.textura)
		barra.targets:SetFrameLevel (barra.textura:GetFrameLevel()+2)
	end
	
	barra.texto_esquerdo = barra.textura:CreateFontString (nil, "OVERLAY", "GameFontHighlightSmall")
	barra.texto_esquerdo:SetPoint ("LEFT", barra.textura, "LEFT", 22, 0)
	barra.texto_esquerdo:SetJustifyH ("LEFT")
	barra.texto_esquerdo:SetTextColor (1,1,1,1)
	
	barra.texto_esquerdo:SetNonSpaceWrap (true)
	barra.texto_esquerdo:SetWordWrap (false)
	
	barra.texto_direita = barra.textura:CreateFontString (nil, "OVERLAY", "GameFontHighlightSmall")
	if (barra.targets) then
		barra.texto_direita:SetPoint ("RIGHT", barra.targets, "LEFT", -2, 0)
	else
		barra.texto_direita:SetPoint ("RIGHT", barra, "RIGHT", -2, 0)
	end
	barra.texto_direita:SetJustifyH ("RIGHT")
	barra.texto_direita:SetTextColor (1,1,1,1)
	
	barra.textura:Show()
end

local miniframe_func_on_enter = function (self)
	local barra = self:GetParent()
	if (barra.show and type (barra.show) == "number") then
		local spellname = GetSpellInfo (barra.show)
		if (spellname) then
			GameTooltip:SetOwner (self, "ANCHOR_TOPLEFT")
			GameTooltip:SetSpellByID (barra.show)
			GameTooltip:Show()
		end
	end
	barra:GetScript("OnEnter")(barra)
end

local miniframe_func_on_leave = function (self)
	GameTooltip:Hide()
	self:GetParent():GetScript("OnLeave")(self:GetParent())
end

local target_on_enter = function (self)

	local barra = self:GetParent():GetParent()
	
	if (barra.show and type (barra.show) == "number") then
		local actor = barra.other_actor or info.jogador
		local spell = actor.spells:PegaHabilidade (barra.show)
		if (spell) then
		
			local ActorTargetsSortTable = {}
			local ActorTargetsContainer
			
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
			
			--add and sort
			for target_name, amount in _pairs (ActorTargetsContainer) do
				ActorTargetsSortTable [#ActorTargetsSortTable+1] = {target_name, amount or 0}
			end
			table.sort (ActorTargetsSortTable, _detalhes.Sort2)
			
			local spellname = _GetSpellInfo (barra.show)
			
			GameTooltip:SetOwner (self, "ANCHOR_TOPRIGHT")
			GameTooltip:AddLine (barra.index .. ". " .. spellname)
			GameTooltip:AddLine (info.target_text)
			GameTooltip:AddLine (" ")
			
			--get time type
			local meu_tempo
			if (_detalhes.time_type == 1 or not actor.grupo) then
				meu_tempo = actor:Tempo()
			elseif (_detalhes.time_type == 2) then
				meu_tempo = info.instancia.showing:GetCombatTime()
			end
			
			for index, target in ipairs (ActorTargetsSortTable) do 
				if (target [2] > 0) then
					local class = _detalhes:GetClass (target [1])
					if (class and _detalhes.class_coords [class]) then
						local cords = _detalhes.class_coords [class]
						if (info.target_persecond) then
							GameTooltip:AddDoubleLine (index .. ". |TInterface\\AddOns\\Details\\images\\classes_small_alpha:14:14:0:0:128:128:"..cords[1]*128 ..":"..cords[2]*128 ..":"..cords[3]*128 ..":"..cords[4]*128 .."|t " .. target [1], _detalhes:comma_value ( _math_floor (target [2] / meu_tempo) ), 1, 1, 1, 1, 1, 1)
						else
							GameTooltip:AddDoubleLine (index .. ". |TInterface\\AddOns\\Details\\images\\classes_small_alpha:14:14:0:0:128:128:"..cords[1]*128 ..":"..cords[2]*128 ..":"..cords[3]*128 ..":"..cords[4]*128 .."|t " .. target [1], _detalhes:comma_value (target [2]), 1, 1, 1, 1, 1, 1)
						end
					else
						if (info.target_persecond) then
							GameTooltip:AddDoubleLine (index .. ". " .. target [1], _detalhes:comma_value ( _math_floor (target [2] / meu_tempo)), 1, 1, 1, 1, 1, 1)
						else
							GameTooltip:AddDoubleLine (index .. ". " .. target [1], _detalhes:comma_value (target [2]), 1, 1, 1, 1, 1, 1)
						end
					end
				end
			end
			
			GameTooltip:Show()
		else
			GameTooltip:SetOwner (self, "ANCHOR_TOPRIGHT")
			GameTooltip:AddLine (barra.index .. ". " .. barra.show)
			GameTooltip:AddLine (info.target_text)
			GameTooltip:AddLine (Loc ["STRING_NO_TARGET"], 1, 1, 1)
			GameTooltip:AddLine (Loc ["STRING_MORE_INFO"], 1, 1, 1)
			GameTooltip:Show()
		end
	else
		GameTooltip:SetOwner (self, "ANCHOR_TOPRIGHT")
		GameTooltip:AddLine (barra.index .. ". " .. barra.show)
		GameTooltip:AddLine (info.target_text)
		GameTooltip:AddLine (Loc ["STRING_NO_TARGET"], 1, 1, 1)
		GameTooltip:AddLine (Loc ["STRING_MORE_INFO"], 1, 1, 1)
		GameTooltip:Show()
	end
	
	self.texture:SetAlpha (1)
	self:SetAlpha (1)
	barra:GetScript("OnEnter")(barra)
end

local target_on_leave = function (self)
	GameTooltip:Hide()
	self:GetParent():GetParent():GetScript("OnLeave")(self:GetParent():GetParent())
	self.texture:SetAlpha (.7)
	self:SetAlpha (.7)
end

function gump:CriaNovaBarraInfo1 (instancia, index)

	if (_detalhes.janela_info.barras1 [index]) then
		print ("erro a barra "..index.." ja existe na janela de detalhes...")
		return
	end

	local janela = info.container_barras.gump

	local esta_barra = _CreateFrame ("Button", "Details_infobox1_bar_"..index, info.container_barras.gump)
	esta_barra:SetWidth (300) --> tamanho da barra de acordo com o tamanho da janela
	esta_barra:SetHeight (16) --> altura determinada pela inst�ncia
	esta_barra.index = index

	local y = (index-1)*17 --> 17 � a altura da barra
	y = y*-1 --> baixo
	
	esta_barra:SetPoint ("LEFT", janela, "LEFT")
	esta_barra:SetPoint ("RIGHT", janela, "RIGHT")
	esta_barra:SetPoint ("TOP", janela, "TOP", 0, y)
	esta_barra:SetFrameLevel (janela:GetFrameLevel() + 1)

	esta_barra:EnableMouse (true)
	esta_barra:RegisterForClicks ("LeftButtonDown","RightButtonUp")	
	
	esta_barra.targets = CreateFrame ("frame", "Details_infobox1_bar_"..index.."Targets", esta_barra)
	esta_barra.targets:SetPoint ("right", esta_barra, "right")
	esta_barra.targets:SetSize (15, 15)
	esta_barra.targets.texture = esta_barra.targets:CreateTexture (nil, overlay)
	esta_barra.targets.texture:SetTexture ([[Interface\MINIMAP\TRACKING\Target]])
	esta_barra.targets.texture:SetAllPoints()
	esta_barra.targets.texture:SetDesaturated (true)
	esta_barra.targets:SetAlpha (.7)
	esta_barra.targets.texture:SetAlpha (.7)
	esta_barra.targets:SetScript ("OnEnter", target_on_enter)
	esta_barra.targets:SetScript ("OnLeave", target_on_leave)
	
	CriaTexturaBarra (instancia, esta_barra)
	
	--> icone
	esta_barra.miniframe = CreateFrame ("frame", nil, esta_barra)
	esta_barra.miniframe:SetSize (14, 14)
	esta_barra.miniframe:SetPoint ("RIGHT", esta_barra.textura, "LEFT", 20, 0)
	
	esta_barra.miniframe:SetScript ("OnEnter", miniframe_func_on_enter)
	esta_barra.miniframe:SetScript ("OnLeave", miniframe_func_on_leave)
	
	esta_barra.icone = esta_barra.textura:CreateTexture (nil, "OVERLAY")
	esta_barra.icone:SetWidth (14)
	esta_barra.icone:SetHeight (14)
	esta_barra.icone:SetPoint ("RIGHT", esta_barra.textura, "LEFT", 20, 0)
	
	esta_barra:SetAlpha(0.9)
	esta_barra.icone:SetAlpha (0.8)
	
	esta_barra.isMain = true
	
	SetBarraScripts (esta_barra, instancia, index)
	
	info.barras1 [index] = esta_barra --> barra adicionada
	
	esta_barra.textura:SetStatusBarColor (1, 1, 1, 1) --> isso aqui � a parte da sele��o e descele��o
	esta_barra.on_focus = false --> isso aqui � a parte da sele��o e descele��o
	
	return esta_barra
end

function gump:CriaNovaBarraInfo2 (instancia, index)

	if (_detalhes.janela_info.barras2 [index]) then
		print ("erro a barra "..index.." ja existe na janela de detalhes...")
		return
	end
	
	local janela = info.container_alvos.gump

	local esta_barra = _CreateFrame ("Button", "Details_infobox2_bar_"..index, info.container_alvos.gump)
	esta_barra:SetWidth (300) --> tamanho da barra de acordo com o tamanho da janela
	esta_barra:SetHeight (16) --> altura determinada pela inst�ncia

	local y = (index-1)*17 --> 17 � a altura da barra
	y = y*-1 --> baixo
	
	esta_barra:SetPoint ("LEFT", janela, "LEFT")
	esta_barra:SetPoint ("RIGHT", janela, "RIGHT")
	esta_barra:SetPoint ("TOP", janela, "TOP", 0, y)
	esta_barra:SetFrameLevel (janela:GetFrameLevel() + 1)

	esta_barra:EnableMouse (true)
	esta_barra:RegisterForClicks ("LeftButtonDown","RightButtonUp")	
	
	CriaTexturaBarra (instancia, esta_barra)

	--> icone
	esta_barra.icone = esta_barra.textura:CreateTexture (nil, "OVERLAY")
	esta_barra.icone:SetWidth (14)
	esta_barra.icone:SetHeight (14)
	esta_barra.icone:SetPoint ("RIGHT", esta_barra.textura, "LEFT", 0+20, 0)
	
	esta_barra:SetAlpha(0.9)
	esta_barra.icone:SetAlpha (0.8)
	
	esta_barra.isAlvo = true
	
	SetBarraScripts (esta_barra, instancia, index)
	
	info.barras2 [index] = esta_barra --> barra adicionada
	
	return esta_barra
end

local x_start = 62
local y_start = -10

function gump:CriaNovaBarraInfo3 (instancia, index)

	if (_detalhes.janela_info.barras3 [index]) then
		print ("erro a barra "..index.." ja existe na janela de detalhes...")
		return
	end

	local janela = info.container_detalhes

	local esta_barra = CreateFrame ("Button", "Details_infobox3_bar_"..index, janela)
	esta_barra:SetWidth (220) --> tamanho da barra de acordo com o tamanho da janela
	esta_barra:SetHeight (16) --> altura determinada pela inst�ncia
	
	local y = (index-1)*17 --> 17 � a altura da barra
	y = y*-1 --> baixo	
	
	esta_barra:SetPoint ("LEFT", janela, "LEFT", x_start, 0)
	esta_barra:SetPoint ("RIGHT", janela, "RIGHT", 59, 0)
	esta_barra:SetPoint ("TOP", janela, "TOP", 0, y+y_start)
	
	esta_barra:EnableMouse (true)
	
	CriaTexturaBarra (instancia, esta_barra)

	--> icone
	esta_barra.icone = esta_barra.textura:CreateTexture (nil, "OVERLAY")
	esta_barra.icone:SetWidth (14)
	esta_barra.icone:SetHeight (14)
	esta_barra.icone:SetPoint ("RIGHT", esta_barra.textura, "LEFT", 0+20, 0)
	
	esta_barra:SetAlpha(0.9)
	esta_barra.icone:SetAlpha (0.8)
	
	esta_barra.isDetalhe = true
		
	SetBarraScripts (esta_barra, instancia, index)
	
	info.barras3 [index] = esta_barra --> barra adicionada
	
	return esta_barra
end
