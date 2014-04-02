local _detalhes = 		_G._detalhes
local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )

local gump = 			_detalhes.gump
local _
--lua locals
--local _string_len = string.len
local _math_floor = math.floor
local _ipairs = ipairs
--local _pairs = pairs
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

function _detalhes:AbreJanelaInfo (jogador)

	if (not _detalhes.row_singleclick_overwrite [self.atributo] or not _detalhes.row_singleclick_overwrite [self.atributo][self.sub_atributo]) then
		return
	elseif (_type (_detalhes.row_singleclick_overwrite [self.atributo][self.sub_atributo]) == "function") then
		return _detalhes.row_singleclick_overwrite [self.atributo][self.sub_atributo] (_, jogador, self)
	end
	
	if (self.modo == _detalhes._detalhes_props["MODO_RAID"]) then
		return
	end

	--> _detalhes.info_jogador armazena o jogador que esta sendo mostrado na janela de detalhes
	if (info.jogador and info.jogador == jogador) then
		_detalhes:FechaJanelaInfo() --> se clicou na mesma barra então fecha a janela de detalhes
		return
	elseif (not jogador) then
		return
	end

	--> vamos passar os parâmetros para dentro da tabela da janela...

	info.ativo = true --> sinaliza o addon que a janela esta aberta
	info.atributo = self.atributo --> instancia.atributo -> grava o atributo (damage, heal, etc)
	info.sub_atributo = self.sub_atributo --> instancia.sub_atributo -> grava o sub atributo (damage done, dps, damage taken, etc)
	
	info.jogador = jogador --> de qual jogador (objeto classe_damage)
	info.instancia = self --> salva a referência da instância que pediu o info
	info.mostrando = nil
	
	local nome = info.jogador.nome --> nome do jogador
	local atributo_nome = sub_atributos[info.atributo].lista [info.sub_atributo] .. " " .. Loc ["STRING_ACTORFRAME_REPORTOF"] --> // nome do atributo // precisa ser o sub atributo correto???
	
	--> removendo o nome da realm do jogador
	if (nome:find ("-")) then
		nome = nome:gsub (("-.*"), "")
	end
	info.nome:SetText (nome)
	
	if (info.instancia.atributo == 1 and info.instancia.sub_atributo == 6) then --> enemy
		atributo_nome = sub_atributos [info.atributo].lista [1] .. " " .. Loc ["STRING_ACTORFRAME_REPORTOF"]
	end
	
	info.atributo_nome:SetText (atributo_nome)
	info.atributo_nome:SetPoint ("CENTER", info.nome, "CENTER", 0, 14)
	
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
				info.targets:SetText (Loc ["STRING_TARGETS"] .. ":")
				info.tipo = 1
			end
		elseif (info.sub_atributo == 3) then --> damage taken
			if (info.tipo ~= 2) then --> janela com fundo diferente
				info.bg1:SetTexture ([[Interface\AddOns\Details\images\info_window_background]])
				info.bg1_sec_texture:SetTexture ([[Interface\AddOns\Details\images\info_window_damagetaken]])
				info.targets:SetText (Loc ["STRING_TARGETS"] .. ":")
				info.tipo = 2
			end
		elseif (info.sub_atributo == 4) then --> friendly fire
			if (info.tipo ~= 3) then --> janela com fundo diferente
				info.bg1:SetTexture ([[Interface\AddOns\Details\images\info_window_background]])
				info.bg1_sec_texture:SetTexture ([[Interface\AddOns\Details\images\info_window_friendlyfire]])
				info.targets:SetText (Loc ["STRING_SPELLS"] .. ":")
				info.tipo = 3
			end
		elseif (info.sub_atributo == 6) then --> enemies
			if (info.tipo ~= 3) then --> janela com fundo diferente
				info.bg1:SetTexture ([[Interface\AddOns\Details\images\info_window_background]])
				info.bg1_sec_texture:SetTexture ([[Interface\AddOns\Details\images\info_window_damagetaken]])
				info.targets:SetText (Loc ["STRING_DAMAGE_TAKEN_FROM"])
				info.tipo = 3
			end
		end
	elseif (info.atributo == 2) then --> HEALING
		if (info.sub_atributo == 1 or info.sub_atributo == 2 or info.sub_atributo == 3) then --> damage done / dps
			if (info.tipo ~= 1) then --> janela com as divisorias
				--info.bg1:SetTexture ("Interface\\AddOns\\Details\\images\\info_bg_part1") --> top left
				--info.bg3:SetTexture ("Interface\\AddOns\\Details\\images\\info_bg_part3") --> bottom left
				--info.bg2:SetTexture ("Interface\\AddOns\\Details\\images\\info_bg_part2") --> top right
				--info.bg4:SetTexture ("Interface\\AddOns\\Details\\images\\info_bg_part4") --> bottom right
				
				info.bg1:SetTexture ([[Interface\AddOns\Details\images\info_window_background]])
				info.bg1_sec_texture:SetTexture (nil)
				info.targets:SetText (Loc ["STRING_TARGETS"] .. ":")
				info.tipo = 1
			end
		elseif (info.sub_atributo == 4) then --> Healing taken
			if (info.tipo ~= 2) then --> janela com fundo diferente
				--info.bg1:SetTexture ("Interface\\AddOns\\Details\\images\\bg_part1_sr") --> top left
				--info.bg3:SetTexture ("Interface\\AddOns\\Details\\images\\bg_part3_sr") --> bottom left
				--info.bg2:SetTexture ("Interface\\AddOns\\Details\\images\\bg_part2_sr") --> top right
				--info.bg4:SetTexture ("Interface\\AddOns\\Details\\images\\bg_part4_sr") --> bottom right
				
				info.bg1:SetTexture ([[Interface\AddOns\Details\images\info_window_background]])
				info.bg1_sec_texture:SetTexture ([[Interface\AddOns\Details\images\info_window_damagetaken]])
				info.targets:SetText (Loc ["STRING_TARGETS"] .. ":")
				info.tipo = 2
			end
		end
	elseif (info.atributo == 3) then --> REGEN
		if (info.tipo ~= 2) then --> janela com fundo diferente
			--info.bg1:SetTexture ("Interface\\AddOns\\Details\\images\\bg_part1_sr") --> top left
			--info.bg3:SetTexture ("Interface\\AddOns\\Details\\images\\bg_part3_sr") --> bottom left
			--info.bg2:SetTexture ("Interface\\AddOns\\Details\\images\\bg_part2_sr") --> top right
			--info.bg4:SetTexture ("Interface\\AddOns\\Details\\images\\bg_part4_sr") --> bottom right
			
			info.bg1:SetTexture ([[Interface\AddOns\Details\images\info_window_background]])
			info.bg1_sec_texture:SetTexture (nil)
			info.targets:SetText ("Vindo de:")
			info.tipo = 2
		end
	
	elseif (info.atributo == 4) then --> MISC
		if (info.tipo ~= 2) then --> janela com fundo diferente
			--info.bg1:SetTexture ("Interface\\AddOns\\Details\\images\\bg_part1_sr") --> top left
			--info.bg3:SetTexture ("Interface\\AddOns\\Details\\images\\bg_part3_sr") --> bottom left
			--info.bg2:SetTexture ("Interface\\AddOns\\Details\\images\\bg_part2_sr") --> top right
			--info.bg4:SetTexture ("Interface\\AddOns\\Details\\images\\bg_part4_sr") --> bottom right
			
			info.bg1:SetTexture ([[Interface\AddOns\Details\images\info_window_background]])
			info.bg1_sec_texture:SetTexture (nil)
			info.targets:SetText (Loc ["STRING_TARGETS"] .. ":")
			info.tipo = 2
		end
	end
end

--> self é qualquer coisa que chamar esta função
------------------------------------------------------------------------------------------------------------------------------
-- é chamado pelo click no X e pelo reset do historico
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


--> seta os scripts da janela de informações
------------------------------------------------------------------------------------------------------------------------------
local function seta_scripts (este_gump)

	--> Janela
	este_gump:SetScript ("OnMouseDown", 
					function (self, botao)
						if (botao == "LeftButton") then
							self:StartMoving()
							self.isMoving = true
						end
					end)
					
	este_gump:SetScript ("OnMouseUp", 
					function (self)
						if (self.isMoving) then
							self:StopMovingOrSizing()
							self.isMoving = false
						end
					end)
					
	este_gump.container_barras.gump:SetScript ("OnMouseDown", 
					function (self, botao)
						if (botao == "LeftButton") then
							este_gump:StartMoving()
							este_gump.isMoving = true
						end
					end)
					
	este_gump.container_barras.gump:SetScript ("OnMouseUp", 
					function (self)
						if (este_gump.isMoving) then
							este_gump:StopMovingOrSizing()
							este_gump.isMoving = false
						end
					end)
					
	este_gump.container_detalhes:SetScript ("OnMouseDown", 
					function (self, botao)
						if (botao == "LeftButton") then
							este_gump:StartMoving()
							este_gump.isMoving = true
						end
					end)
					
	este_gump.container_detalhes:SetScript ("OnMouseUp", 
					function (self)
						if (este_gump.isMoving) then
							este_gump:StopMovingOrSizing()
							este_gump.isMoving = false
						end
					end)		

	este_gump.container_alvos.gump:SetScript ("OnMouseDown", 
					function (self, botao)
						if (botao == "LeftButton") then
							este_gump:StartMoving()
							este_gump.isMoving = true
						end
					end)
					
	este_gump.container_alvos.gump:SetScript ("OnMouseUp", 
					function (self)
						if (este_gump.isMoving) then
							este_gump:StopMovingOrSizing()
							este_gump.isMoving = false
						end
					end)	

	--> botão fechar
	este_gump.fechar:SetScript ("OnClick", function(self) 
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

--> cria a barra de detalhes a direita da janela de informações
------------------------------------------------------------------------------------------------------------------------------
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
	"Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON")
	info.bg.reportar:SetPoint ("BOTTOMLEFT", info.bg.overlay, "BOTTOMRIGHT",  -33, 10)
	gump:Fade (info.bg.reportar, 1)
	
	info.bg:SetScript ("OnEnter", 
		function(self) 
			gump:Fade (self.overlay, "OUT") 
			gump:Fade (self.reportar, "OUT")
		end)
	info.bg:SetScript ("OnLeave", 
		function(self) 
			gump:Fade (self.overlay, "IN")
			gump:Fade (self.reportar, "IN")
		end)

	info.bg.reportar:SetScript ("OnEnter", 
		function(self) 
			gump:Fade (info.bg.overlay, "OUT")
			gump:Fade (self, "OUT")
		end)
	info.bg.reportar:SetScript ("OnLeave", 
		function(self) 
			gump:Fade (info.bg.overlay, "IN")
			gump:Fade (self, "IN")
		end)	
	
	info.bg_end = info.bg:CreateTexture (nil, "BACKGROUND")
	info.bg_end:SetHeight (47)
	--este_gump.bg4:SetPoint ("BOTTOMRIGHT", este_gump, "BOTTOMRIGHT", 0, 0)
	--este_gump.bg4:SetWidth (128)
	--este_gump.bg4:SetHeight (256)
	info.bg_end:SetTexture ("Interface\\AddOns\\Details\\images\\bar_detalhes2_end")
	--info.bg = _detalhes.janela_info.container_detalhes:CreateTexture (nil, "BACKGROUND")
	--info.bg:SetWidth (400)
	--info.bg:SetHeight (70)
	--info.bg:SetTexture ("Interface\\MONEYFRAME\\UI-MoneyFrame2")

	_detalhes.janela_info.grupos_detalhes [index] = info
end

--> determina qual a pocisão que a barra de detalhes vai ocupar
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

--> seta o conteúdo da barra de detalhes
------------------------------------------------------------------------------------------------------------------------------
function gump:SetaDetalheInfoTexto (index, p, arg1, arg2, arg3, arg4, arg5, arg6)
	local info = _detalhes.janela_info.grupos_detalhes [index]
	
	if (p) then
		if (_type (p) == "table") then
			info.bg:SetValue (p.p)
			info.bg:SetStatusBarColor (p.c[1], p.c[2], p.c[3])
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

--> cria as 5 caixas de detalhes infos que serão usados
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
	
	container_alvos:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
		insets = {left = 1, right = 1, top = 0, bottom = 1},})		
	container_alvos:SetBackdropColor (50/255, 50/255, 50/255, 0.6)
	
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
	
	--> começa a montar as texturas <--
	
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
	
	--> cria as 4 partes do fundo da janela
	
	--> top left
	este_gump.bg1 = este_gump:CreateTexture (nil, "BORDER")
	este_gump.bg1:SetPoint ("TOPLEFT", este_gump, "TOPLEFT", 0, 0)
	--este_gump.bg1:SetWidth (512)
	--este_gump.bg1:SetHeight (256)
	este_gump.bg1:SetTexture ("Interface\\AddOns\\Details\\images\\info_bg_part1") 
	este_gump.bg1:SetTexture ("Interface\\AddOns\\Details\\images\\info_window_background")
	este_gump.bg1:SetDrawLayer ("BORDER", 1)
	
	este_gump.bg1_sec_texture = este_gump:CreateTexture (nil, "BORDER")
	este_gump.bg1_sec_texture:SetDrawLayer ("BORDER", 2)
	este_gump.bg1_sec_texture:SetPoint ("topleft", este_gump.bg1, "topleft", 356, -86)
	este_gump.bg1_sec_texture:SetHeight (262)
	este_gump.bg1_sec_texture:SetWidth (258)

	--> bottom left
	este_gump.bg3 = este_gump:CreateTexture (nil, "BORDER")
	--este_gump.bg3:SetPoint ("BOTTOMLEFT", este_gump, "BOTTOMLEFT", 0, 0)
	este_gump.bg3:SetPoint ("TOPLEFT", este_gump, "TOPLEFT", 0, -256)
	este_gump.bg3:SetWidth (512)
	este_gump.bg3:SetHeight (128)
	este_gump.bg3:SetTexture ("Interface\\AddOns\\Details\\images\\info_bg_part3") 
	este_gump.bg3:Hide()
	
	--> top right
	este_gump.bg2 = este_gump:CreateTexture (nil, "BORDER")
	este_gump.bg2:SetPoint ("TOPLEFT", este_gump, "TOPLEFT", 512, 0)
	este_gump.bg2:SetWidth (128)
	este_gump.bg2:SetHeight (128)
	este_gump.bg2:SetTexture ("Interface\\AddOns\\Details\\images\\info_bg_part2") 
	este_gump.bg2:Hide()
	
	--> bottom right
	este_gump.bg4 = este_gump:CreateTexture (nil, "BORDER")
	--este_gump.bg4:SetPoint ("BOTTOMRIGHT", este_gump, "BOTTOMRIGHT", 0, 0)
	--este_gump.bg4:SetPoint ("BOTTOMLEFT", este_gump, "BOTTOMLEFT", 512, 0)
	este_gump.bg4:SetPoint ("TOPLEFT", este_gump, "TOPLEFT", 512, -128)
	este_gump.bg4:SetWidth (128)
	este_gump.bg4:SetHeight (256)
	este_gump.bg4:SetTexture ("Interface\\AddOns\\Details\\images\\info_bg_part4") 
	este_gump.bg4:Hide()

	--> botão de fechar
	este_gump.fechar = _CreateFrame ("Button", nil, este_gump, "UIPanelCloseButton")
	este_gump.fechar:SetWidth (32)
	este_gump.fechar:SetHeight (32)
	este_gump.fechar:SetPoint ("TOPRIGHT", este_gump, "TOPRIGHT", 5, -8)
	este_gump.fechar:SetText ("X")
	este_gump.fechar:SetFrameLevel (este_gump:GetFrameLevel()+2)

	function este_gump:ToFront()
		if (_detalhes.bosswindow) then
			if (_detalhes.bosswindow:GetFrameLevel() > este_gump:GetFrameLevel()) then 
				este_gump:SetFrameLevel (este_gump:GetFrameLevel()+3)
				_detalhes.bosswindow:SetFrameLevel (_detalhes.bosswindow:GetFrameLevel()-3)
			end
		end
	end
	
	este_gump.grab = gump:NewDetailsButton (este_gump, este_gump, _, este_gump.ToFront, nil, nil, 590, 73, "", "", "", "", {OnGrab = "PassClick"})
	este_gump.grab:SetPoint ("topleft",este_gump, "topleft")
	este_gump.grab:SetFrameLevel (este_gump:GetFrameLevel()+1)
	
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


	--> botão de reportar da caixa da esquerda, onde fica as barras principais
	este_gump.report_esquerda = gump:NewDetailsButton (este_gump, este_gump, nil, _detalhes.Reportar, este_gump, 1, 16, 16,
	"Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON")
	--este_gump.report_esquerda:SetPoint ("BOTTOMLEFT", este_gump.container_barras, "TOPLEFT",  281, 3)
	este_gump.report_esquerda:SetPoint ("BOTTOMLEFT", este_gump.container_barras, "TOPLEFT",  33, 3)
	este_gump.report_esquerda:SetFrameLevel (este_gump:GetFrameLevel()+2)

	--> botão de reportar da caixa dos alvos
	este_gump.report_alvos = gump:NewDetailsButton (este_gump, este_gump, nil, _detalhes.Reportar, este_gump, 3, 16, 16,
	"Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON")
	este_gump.report_alvos:SetPoint ("BOTTOMRIGHT", este_gump.container_alvos, "TOPRIGHT",  -2, -1)
	este_gump.report_alvos:SetFrameLevel (3) --> solved inactive problem

	--> ícone da magia selecionada para mais detalhes
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

	--> botão de reportar da caixa da direita, onde estão os 5 quadrados
	este_gump.report_direita = gump:NewDetailsButton (este_gump, este_gump, nil, _detalhes.Reportar, este_gump, 2, 16, 16,
	"Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON", "Interface\\COMMON\\VOICECHAT-ON")
	este_gump.report_direita:SetPoint ("TOPRIGHT", este_gump, "TOPRIGHT",  -8, -57)	
	este_gump.report_direita:Hide()

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
			spells_texture:SetPoint ("topleft", frame, "topleft", 400, -100)
			spells_texture:SetTexture ([[Interface\ACHIEVEMENTFRAME\UI-Achievement-HorizontalShadow]])
			spells_texture:SetSize (128, 16)
			local spells_text = frame:CreateFontString (nil, "artwork", "GameFontNormal")
			spells_text:SetText ("Spells")
			spells_text :SetPoint ("left", spells_texture, "left", 2, 0)
			
			for i = 1, 9 do 
				local icon = frame:CreateTexture (nil, "artwork")
				icon:SetSize (14, 14)
				icon:SetPoint ("topleft", frame, "topleft", 405, -120 + ((i-1)*15)*-1)
				local spell = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
				spell:SetPoint ("left", icon, "right", 2, 0)
				spell:SetText ("spell name:") --> localize-me
				spell:SetTextColor (.8, .8, .8, 1)
				local spell_amt = frame:CreateFontString (nil, "artwork", "GameFontHighlightSmall")
				spell_amt:SetPoint ("left", spell,  "right", 2, 0)
				spell_amt:SetText ("0")
				tab ["spell" .. i] = {spell, spell_amt, icon}
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
					d = d / ps * 100
					if (inverse) then
						diff = "|cFF00FF00+" .. _math_floor (math.abs (d)) .. "%|r"
					else
						diff = "|cFFFF0000+" .. _math_floor (math.abs (d)) .. "%|r"
					end
				else
					local d = lastvalue - ps
					d = d / lastvalue * 100
					if (inverse) then
						diff = "|cFFFF0000-" .. _math_floor (math.abs (d)) .. "%|r"
					else
						diff = "|cFF00FF00-" .. _math_floor (math.abs (d)) .. "%|r"
					end
				end
			end
			
			return ps, diff
		end
		
		local spells_by_class = {
			["DRUID"] = {
				[132402] = true, --savage defense
				[135286] = true, -- tooth and claw
			},
			["DEATHKNIGHT"] = {
				[145676] = true, --riposte
				[77535] = true, --blood shield
			},
			["MONK"] = {
				[118604] = true, --guard
				[115307] = true, --shuffle
				[115308] = true, --elusive brew
			},
			["PALADIN"] = {
				[132403] = true, --shield of the righteous
				[114163] = true, --eternal-flame
				[20925] = true, --sacred shield
			},
			["WARRIOR"] = {
				[145672] = true, --riposte
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
				local damagetaken = player.damage_taken
				local last_damage_received = 0
				if (last_actor) then
					last_damage_received = last_actor.damage_taken / last_combat:GetCombatTime()
				end
				
				tab.damagereceived:SetText (_detalhes:ToK2 (damagetaken))
				
				local ps, diff = getpercent (damagetaken, last_damage_received, elapsed_time)
				tab.damagepersecond:SetText (_detalhes:comma_value (_math_floor (ps)) .. " (" .. diff .. ")")

			--> absorbs
				local totalabsorbs = player.avoidance.overall.ABSORB_AMT
				local incomingtotal = damagetaken + totalabsorbs
				
				local last_total_absorbs = 0
				if (last_actor) then
					last_total_absorbs = last_actor.avoidance.overall.ABSORB_AMT / last_combat:GetCombatTime()
				end
				
				tab.absorbstotal:SetText (_detalhes:ToK2 (totalabsorbs) .. " (" .. _math_floor (totalabsorbs / incomingtotal * 100) .. "%)")
				
				local ps, diff = getpercent (totalabsorbs, last_total_absorbs, elapsed_time, true)
				tab.absorbstotalpersecond:SetText (_detalhes:comma_value (_math_floor (ps)) .. " (" .. diff .. ")")
				
			--> dodge
				local totaldodge = player.avoidance.overall.DODGE
				tab.dodge:SetText (totaldodge)
				
				local last_total_dodge = 0
				if (last_actor) then
					last_total_dodge = last_actor.avoidance.overall.DODGE / last_combat:GetCombatTime()
				end
				local ps, diff = getpercent (totaldodge, last_total_dodge, elapsed_time, true)
				tab.dodgepersecond:SetText ( string.format ("%.2f", ps) .. " (" .. diff .. ")")
			
			--> parry
				local totalparry = player.avoidance.overall.PARRY
				tab.parry:SetText (totalparry)
				
				local last_total_parry = 0
				if (last_actor) then
					last_total_parry = last_actor.avoidance.overall.PARRY / last_combat:GetCombatTime()
				end
				local ps, diff = getpercent (totalparry, last_total_parry, elapsed_time, true)
				tab.parrypersecond:SetText (string.format ("%.2f", ps) .. " (" .. diff .. ")")
				
			--> absorb
				local fullabsorb = player.avoidance.overall.FULL_ABSORBED
				local halfabsorb = player.avoidance.overall.PARTIAL_ABSORBED
				local halfabsorb_amt = player.avoidance.overall.PARTIAL_ABSORB_AMT
				local noabsorb = player.avoidance.overall.FULL_HIT
				
				tab.fullsbsorbed:SetText (fullabsorb)
				tab.partiallyabsorbed:SetText (halfabsorb)
				tab.noabsorbs:SetText (noabsorb)
				
				if (halfabsorb_amt > 0) then
					local average = halfabsorb_amt / halfabsorb --tenho o average
					local last_average = 0
					if (last_actor) then
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
					local este_alvo = actor_heal.targets._NameIndexTable [player.nome]
					if (este_alvo) then
						este_alvo = actor_heal.targets._ActorTable [este_alvo]
						local heal_total = este_alvo.total
						tab.selfhealing:SetText (_detalhes:ToK2 (heal_total))
						
						if (last_actor_heal) then
							local este_alvo = last_actor_heal.targets._NameIndexTable [player.nome]
							if (este_alvo) then
							
								este_alvo = actor_heal.targets._ActorTable [este_alvo]
								
								local last_heal = este_alvo.total / last_combat:GetCombatTime()
								
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
						local amount = targets:GetAmount (player.nome, "total")
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
								local amount = targets:GetAmount (player.nome, "total")
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
					if (misc_player.cooldowns_defensive_spell_tables) then
						local minha_tabela = misc_player.cooldowns_defensive_spell_tables._ActorTable
						local cooldowns_usados = {}
						
						for _spellid, _tabela in pairs (minha_tabela) do
							cooldowns_usados [#cooldowns_usados+1] = {_spellid, _tabela.counter}
						end
						table.sort (cooldowns_usados, function (t1, t2) return t1[2] > t2[2] end)
						
						if (#cooldowns_usados > 1) then
							for i = 1, #cooldowns_usados do
								local esta_habilidade = cooldowns_usados[i]
								local nome_magia, _, icone_magia = _GetSpellInfo (esta_habilidade[1])
								
								local label1, label2, icon1 = unpack (tab ["spell" .. i])
								
								label1:SetText (nome_magia .. ":")
								label2:SetText (esta_habilidade[2])
								icon1:SetTexture (icone_magia)
								icon1:SetTexCoord (0.0625, 0.953125, 0.0625, 0.953125)
								
								index_used = index_used + 1
							end
						end
					end
				end
				

				
				--> buffs de druida
				if (index_used < 9) then
					if (misc_player.buff_uptime_spell_tables) then
						local minha_tabela = misc_player.buff_uptime_spell_tables._ActorTable
						for _spellid, _tabela in pairs (minha_tabela) do
							if (spells_by_class [player.classe] [_spellid] and index_used < 9) then 
								local nome_magia, _, icone_magia = GetSpellInfo (_spellid)
								local label1, label2, icon1 = unpack (tab ["spell" .. index_used])
								
								label1:SetText (nome_magia .. ":")
								local minutos, segundos = _math_floor (_tabela.uptime / 60), _math_floor (_tabela.uptime % 60)
								label2:SetText (minutos .. "m " .. segundos .. "s")
								icon1:SetTexture (icone_magia)
								icon1:SetTexCoord (0.0625, 0.953125, 0.0625, 0.953125)
								
								index_used = index_used + 1
							end
						end
					end
				end
				
				for i = index_used, 9 do
					local label1, label2, icon1 = unpack (tab ["spell" .. i])
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
				_detalhes.player_details_tabs[1]:Hide()
			end
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
			end
			newtab.frame:Show()
		end)
	else
		--> custom
		newtab:SetScript ("OnClick", onclick)
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
	
	if (botao == 1) then --> botão da esquerda
		report_lines = {"Details! " .. Loc ["STRING_ACTORFRAME_REPORTTO"] .. " " .. _detalhes.sub_atributos [atributo].lista [sub_atributo] .. " " .. Loc ["STRING_ACTORFRAME_REPORTOF"] .. " " .. player.nome}
		for index, barra in _ipairs (info.barras1) do 
			if (barra:IsShown()) then
				report_lines [#report_lines+1] = barra.texto_esquerdo:GetText().." -> ".. _detalhes:comma_value (barra.texto_direita:GetText())
			end
			if (index == amt) then
				break
			end
		end
		
	elseif (botao == 3) then --> botão dos alvos
	
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
		
	elseif (botao == 2) then --> botão da direita
	
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

	
	--> pega o conteúdo da janela da direita
	
	return instancia:envia_relatorio (report_lines)
end

local row_on_enter = function (self)
	if (info.fading_in or info.faded) then
		return
	end
	
	self.mouse_over = true

	--> aumenta o tamanho da barra
	self:SetHeight (17) --> altura determinada pela instância
	--> poe a barra com alfa 1 ao invés de 0.9
	self:SetAlpha(1)

	--> troca a cor da barra enquanto o mouse estiver em cima dela
	self:SetBackdrop({
		--bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 16, edgeSize = 10,
		insets = {left = 1, right = 1, top = 0, bottom = 1},})	
	self:SetBackdropBorderColor (0.666, 0.666, 0.666)
	self:SetBackdropColor (0.0941, 0.0941, 0.0941)
	
	if (self.isAlvo) then --> monta o tooltip do alvo
		--> talvez devesse escurecer a janela no fundo... pois o tooltip é transparente e pode confundir
		GameTooltip:SetOwner (self, "ANCHOR_TOPRIGHT")
		
		-- ~erro
		if (self.spellid == "enemies") then --> damage taken enemies
			if (not self.minha_tabela or not self.minha_tabela:MontaTooltipDamageTaken (self, self._index)) then  -- > poderia ser aprimerado para uma tailcall
				return
			end
		
		elseif (not self.minha_tabela or not self.minha_tabela:MontaTooltipAlvos (self, self._index)) then  -- > poderia ser aprimerado para uma tailcall
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
		if (not info.mostrando) then --> não esta mostrando nada na direita
			info.mostrando = self --> agora o mostrando é igual a esta barra
			info.mostrando_mouse_over = true --> o conteudo da direta esta sendo mostrado pq o mouse esta passando por cima do bagulho e não pq foi clicado
			info.showing = self._index --> diz  o index da barra que esta sendo mostrado na direita

			info.jogador.detalhes = self.show --> minha tabela = jogador = jogador.detales = spellid ou nome que esta sendo mostrado na direita
			info.jogador:MontaDetalhes (self.show, self) --> passa a spellid ou nome e a barra
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
		
		--> remover o conteúdo que estava sendo mostrado na direita
		if (info.mostrando_mouse_over) then
			info.mostrando = nil
			info.mostrando_mouse_over = false
			info.showing = nil
			
			info.jogador.detalhes = nil
			gump:HidaAllDetalheInfo()
		end
	end
end

local function SetBarraScripts (esta_barra, instancia, i)
	
	esta_barra._index = i
	
	esta_barra:SetScript ("OnEnter", row_on_enter)
	esta_barra:SetScript ("OnLeave", row_on_leave)

	esta_barra:SetScript ("OnMouseDown", function (self)
	
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
		
	end)
	
	esta_barra:SetScript ("OnMouseUp", function (self)

		if (self.fading_in) then
			return
		end
	
		if (info.isMoving) then
			info:StopMovingOrSizing()
			info.isMoving = false
			--instancia:SaveMainWindowPosition() --> precisa fazer algo pra salvar o trem
		end
	
		local x, y = _GetCursorPosition()
		x = _math_floor (x)
		y = _math_floor (y)
		if ((self.mouse_down+0.4 > _GetTime() and (x == self.x and y == self.y)) or (x == self.x and y == self.y)) then
			--> setar os textos
			
			if (self.isMain) then --> se não for uma barra de alvo
			
				local barra_antiga = info.mostrando --> ??
				
				--> on_focus = quando a barra esta precionada
				
				if (barra_antiga and not info.mostrando_mouse_over) then
				
					barra_antiga.textura:SetStatusBarColor (1, 1, 1, 1) --> volta a textura normal
					barra_antiga.on_focus = false --> não esta mais no foco

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
				
				--> NÃO TINHA BARRAS PRECIONADAS
				-- info.mostrando = self
				info.mostrando_mouse_over = false
				self:SetAlpha (1)
				self.textura:SetStatusBarColor (129/255, 125/255, 69/255, 1)
				self.on_focus = true
			end
			
		end
	end)	
end

local function CriaTexturaBarra (instancia, barra)
	barra.textura = _CreateFrame ("StatusBar", nil, barra)
	barra.textura:SetAllPoints (barra)
	--barra.textura:SetStatusBarTexture (instancia.row_info.texture_file)
	barra.textura:SetStatusBarTexture (_detalhes.default_texture)
	barra.textura:SetStatusBarColor(.5, .5, .5, 0)
	barra.textura:SetMinMaxValues(0,100)
	
	barra.texto_esquerdo = barra.textura:CreateFontString (nil, "OVERLAY", "GameFontHighlightSmall")
	barra.texto_esquerdo:SetPoint ("LEFT", barra.textura, "LEFT", 22, 0)
	barra.texto_esquerdo:SetJustifyH ("LEFT")
	barra.texto_esquerdo:SetTextColor (1,1,1,1)
	
	barra.texto_esquerdo:SetNonSpaceWrap (true)
	barra.texto_esquerdo:SetWordWrap (false)
	
	barra.texto_direita = barra.textura:CreateFontString (nil, "OVERLAY", "GameFontHighlightSmall")
	barra.texto_direita:SetPoint ("RIGHT", barra.textura, "RIGHT", -2)
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

function gump:CriaNovaBarraInfo1 (instancia, index)

	if (_detalhes.janela_info.barras1 [index]) then
		print ("erro a barra "..index.." ja existe na janela de detalhes...")
		return
	end

	local janela = info.container_barras.gump

	local esta_barra = _CreateFrame ("Button", "Details_infobox1_bar_"..index, info.container_barras.gump)
	esta_barra:SetWidth (300) --> tamanho da barra de acordo com o tamanho da janela
	esta_barra:SetHeight (16) --> altura determinada pela instância

	local y = (index-1)*17 --> 17 é a altura da barra
	y = y*-1 --> baixo
	
	esta_barra:SetPoint ("LEFT", janela, "LEFT")
	esta_barra:SetPoint ("RIGHT", janela, "RIGHT")
	esta_barra:SetPoint ("TOP", janela, "TOP", 0, y)
	esta_barra:SetFrameLevel (janela:GetFrameLevel() + 1)

	esta_barra:EnableMouse (true)
	esta_barra:RegisterForClicks ("LeftButtonDown","RightButtonUp")	
	
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
	
	esta_barra.textura:SetStatusBarColor (1, 1, 1, 1) --> isso aqui é a parte da seleção e desceleção
	esta_barra.on_focus = false --> isso aqui é a parte da seleção e desceleção
	
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
	esta_barra:SetHeight (16) --> altura determinada pela instância

	local y = (index-1)*17 --> 17 é a altura da barra
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
	esta_barra:SetHeight (16) --> altura determinada pela instância
	
	local y = (index-1)*17 --> 17 é a altura da barra
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
