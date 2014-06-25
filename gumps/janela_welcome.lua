local _detalhes = 		_G._detalhes
local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")

local g =	_detalhes.gump
local _
function _detalhes:OpenWelcomeWindow ()

	GameCooltip:Close()
	local window = _G.DetailsWelcomeWindow

	if (not window) then
	
		local index = 1
		local pages = {}
		
		local instance = _detalhes.tabela_instancias [1]
		
		window = CreateFrame ("frame", "DetailsWelcomeWindow", UIParent)
		window:SetPoint ("center", UIParent, "center", 0, 0)
		window:SetWidth (512)
		window:SetHeight (256)
		window:SetMovable (true)
		window:SetScript ("OnMouseDown", function() window:StartMoving() end)
		window:SetScript ("OnMouseUp", function() window:StopMovingOrSizing() end)
		
		local background = window:CreateTexture (nil, "background")
		background:SetPoint ("topleft", window, "topleft")
		background:SetPoint ("bottomright", window, "bottomright")
		background:SetTexture ([[Interface\AddOns\Details\images\welcome]])
		
		local rodape_bg = window:CreateTexture (nil, "artwork")
		rodape_bg:SetPoint ("bottomleft", window, "bottomleft", 11, 12)
		rodape_bg:SetPoint ("bottomright", window, "bottomright", -11, 12)
		rodape_bg:SetTexture ([[Interface\Tooltips\UI-Tooltip-Background]])
		rodape_bg:SetHeight (25)
		rodape_bg:SetVertexColor (0, 0, 0, 1)
		
		local logotipo = window:CreateTexture (nil, "overlay")
		logotipo:SetPoint ("topleft", window, "topleft", 16, -20)
		logotipo:SetTexture ([[Interface\Addons\Details\images\logotipo]])
		logotipo:SetTexCoord (0.07421875, 0.73828125, 0.51953125, 0.890625)
		logotipo:SetWidth (186)
		logotipo:SetHeight (50)
		
		local cancel = CreateFrame ("Button", nil, window)
		cancel:SetWidth (22)
		cancel:SetHeight (22)
		cancel:SetPoint ("bottomleft", window, "bottomleft", 12, 14)
		cancel:SetFrameLevel (window:GetFrameLevel()+1)
		cancel:SetPushedTexture ([[Interface\Buttons\UI-GroupLoot-Pass-Down]])
		cancel:SetHighlightTexture ([[Interface\Buttons\UI-GROUPLOOT-PASS-HIGHLIGHT]])
		cancel:SetNormalTexture ([[Interface\Buttons\UI-GroupLoot-Pass-Up]])
		cancel:SetScript ("OnClick", function() window:Hide() end)
		local cancelText = cancel:CreateFontString (nil, "overlay", "GameFontNormal")
		cancelText:SetPoint ("left", cancel, "right", 2, 0)
		cancelText:SetText ("Skip")
		
		local forward = CreateFrame ("button", nil, window)
		forward:SetWidth (26)
		forward:SetHeight (26)
		forward:SetPoint ("bottomright", window, "bottomright", -14, 13)
		forward:SetFrameLevel (window:GetFrameLevel()+1)
		forward:SetPushedTexture ([[Interface\Buttons\UI-SpellbookIcon-NextPage-Down]])
		forward:SetHighlightTexture ([[Interface\Buttons\UI-SpellbookIcon-NextPage-Up]])
		forward:SetNormalTexture ([[Interface\Buttons\UI-SpellbookIcon-NextPage-Up]])
		forward:SetDisabledTexture ([[Interface\Buttons\UI-SpellbookIcon-NextPage-Disabled]])
		
		local backward = CreateFrame ("button", nil, window)
		backward:SetWidth (26)
		backward:SetHeight (26)
		backward:SetPoint ("bottomright", window, "bottomright", -38, 13)
		backward:SetPushedTexture ([[Interface\Buttons\UI-SpellbookIcon-PrevPage-Down]])
		backward:SetHighlightTexture ([[Interface\Buttons\UI-SpellbookIcon-PrevPage-Up]])
		backward:SetNormalTexture ([[Interface\Buttons\UI-SpellbookIcon-PrevPage-Up]])
		backward:SetDisabledTexture ([[Interface\Buttons\UI-SpellbookIcon-PrevPage-Disabled]])
		
		forward:SetScript ("OnClick", function()
			if (index < #pages) then
				for _, widget in ipairs (pages [index]) do 
					widget:Hide()
				end
				
				index = index + 1
				
				for _, widget in ipairs (pages [index]) do 
					widget:Show()
				end
				
				if (index == #pages) then
					forward:Disable()
				end
				backward:Enable()
			end
		end)
		
		backward:SetScript ("OnClick", function()
			if (index > 1) then
				for _, widget in ipairs (pages [index]) do 
					widget:Hide()
				end
				
				index = index - 1
				
				for _, widget in ipairs (pages [index]) do 
					widget:Show()
				end
				
				if (index == 1) then
					backward:Disable()
				end
				forward:Enable()
			end
		end)

		function _detalhes:WelcomeSetLoc()
			local instance = _detalhes.tabela_instancias [1]
			instance.baseframe:ClearAllPoints()
			instance.baseframe:SetPoint ("left", DetailsWelcomeWindow, "right", 10, 0)
		end
		_detalhes:ScheduleTimer ("WelcomeSetLoc", 5)

--/script local f=CreateFrame("frame");local g=false;f:SetScript("OnUpdate",function(s,e)if not g then local r=math.random for i=1,2500000 do local a=r(1,1000000);a=a+1 end g=true else print(string.format("cpu: %.3f",e));f:SetScript("OnUpdate",nil)end end)
	
	function _detalhes:CalcCpuPower()
		local f = CreateFrame ("frame")
		local got = false
		
		f:SetScript ("OnUpdate", function (self, elapsed)
			if (not got and not InCombatLockdown()) then
				local r = math.random
				for i = 1, 2500000 do 
					local a = r (1, 1000000)
					a = a + 1
				end
				got = true
				
			elseif (not InCombatLockdown()) then
				--print ("process time:", elapsed)
				
				if (elapsed < 0.295) then
					_detalhes.use_row_animations = true
					_detalhes.update_speed = 0.2
				
				elseif (elapsed < 0.375) then
					_detalhes.use_row_animations = true
					_detalhes.update_speed = 0.3
					
				elseif (elapsed < 0.475) then
					_detalhes.use_row_animations = true
					_detalhes.update_speed = 0.5
					
				elseif (elapsed < 0.525) then
					_detalhes.update_speed = 0.5
					
				end
			
				DetailsWelcomeWindowSliderUpdateSpeed.MyObject:SetValue (_detalhes.update_speed)
				DetailsWelcomeWindowAnimateSlider.MyObject:SetValue (_detalhes.use_row_animations)

				f:SetScript ("OnUpdate", nil)
			end
		end)
	end
	
	_detalhes:ScheduleTimer ("CalcCpuPower", 10)

	--detect ElvUI
	local ElvUI = _G.ElvUI
	if (ElvUI) then
		--active elvui skin
		local instance = _detalhes.tabela_instancias [1]
		if (instance and instance.ativa) then
			if (instance.skin ~= "ElvUI Frame Style") then
				instance:ChangeSkin ("ElvUI Frame Style")
			end
		end

		--save standard
		local savedObject = {}
		for key, value in pairs (instance) do
			if (_detalhes.instance_defaults [key]) then	
				if (type (value) == "table") then
					savedObject [key] = table_deepcopy (value)
				else
					savedObject [key] = value
				end
			end
		end
		_detalhes.standard_skin = savedObject
	end
		
	do

		local Loc = LibStub ("AceLocale-3.0"):NewLocale ("Details", "enUS", true) 
		if (Loc) then
		
			Loc ["STRING_WELCOME_1"] = "|cFFFFFFFFWelcome to Details! Quick Setup Wizard\n\n|rThis guide will help you with some important configurations.\nYou can skip this at any time just clicking on 'skip' button."
			Loc ["STRING_WELCOME_2"] = "if you change your mind, you can always modify again through options panel"
			Loc ["STRING_WELCOME_3"] = "Choose your DPS and HPS prefered method:"
			Loc ["STRING_WELCOME_4"] = "Activity Time"..": "
			Loc ["STRING_WELCOME_5"] = "Effective Time"..": "
			Loc ["STRING_WELCOME_6"] = "the timer of each raid member is put on hold if his activity is ceased and back again to count when is resumed."
			Loc ["STRING_WELCOME_7"] = "used for rankings, this method uses the elapsed combat time for measure the Dps and Hps of all raid members."
			Loc ["STRING_WELCOME_8"] = "if you change your mind, you can always modify again through options panel"
			Loc ["STRING_WELCOME_9"] = "Details! reads and calculate combat numbers in a very fast way, but if some kind of data is irrelevant for you, you can disable/enable it 'on-the-fly'."
			Loc ["STRING_WELCOME_10"] = "Mouse over each slider to see what they represent."
			Loc ["STRING_WELCOME_11"] = "if you change your mind, you can always modify again through options panel"
			Loc ["STRING_WELCOME_12"] = "In this page you can choose the update speed desired and also enable animations."
			Loc ["STRING_WELCOME_13"] = ""
			Loc ["STRING_WELCOME_14"] = "Update Speed"
			Loc ["STRING_WELCOME_15"] = "This is the delay length between each update in the window,\nthe standard value is 1 second,\nbut you may decrease to 0.3 for more dinamyc updates."
			Loc ["STRING_WELCOME_16"] = "Enable Animations"
			Loc ["STRING_WELCOME_17"] = "Enable or Disable bar animations."
			Loc ["STRING_WELCOME_18"] = "if you change your mind, you can always modify again through options panel"
			Loc ["STRING_WELCOME_19"] = "Memory Adjustments:"
			Loc ["STRING_WELCOME_20"] = "The amount of memory used by addons doesn't affect framerate, but, saving memory in computers which doesn't have much of it, may help the whole system. Details! try to be as flexible as possible to keep the game smooth even in not high-end hardware."
			Loc ["STRING_WELCOME_21"] = "max segments"
			Loc ["STRING_WELCOME_22"] = "How many segments you want to maintain.\nFeel free to adjust this number to be comfortable for you."
			Loc ["STRING_WELCOME_23"] = "memory threshold"
			Loc ["STRING_WELCOME_24"] = "Details! try adjust it self with the amount of memory\navaliable on your system.\n\nAlso is recommeded keep the amount of\nsegments low if your system have 2gb ram or less."
			Loc ["STRING_WELCOME_25"] = "segments saved on logout"
			Loc ["STRING_WELCOME_26"] = "Using the Interface: Stretch"
			Loc ["STRING_WELCOME_27"] = "- When you have the mouse over a Details! window, a |cFFFFFF00small hook|r will appear over the instance button. |cFFFFFF00Click, hold and pull|r up to |cFFFFFF00stretch|r the window, releasing the mouse click, the window |cFFFFFF00back to original|r size.\n\n- If you miss a |cFFFFBB00scroll bar|r, you can active it on the options panel."
			Loc ["STRING_WELCOME_28"] = "Using the Interface: Instance Button"
			Loc ["STRING_WELCOME_29"] = "Instance button basically do three things:\n\n- show |cFFFFFF00what instance|r is it through the |cFFFFFF00#number|r,\n- open a |cFFFFFF00new instance|r window when clicked.\n- show a menu with |cFFFFFF00closed instances|r which can be reopen at any one."
			Loc ["STRING_WELCOME_30"] = "Using the Interface: Fast Switch Panel (shortcuts)"
			Loc ["STRING_WELCOME_31"] = "- Right clicking |cFFFFFF00over a row|r or in the background opens the |cFFFFFF00shortcut menu|r.\n- You can choose which |cFFFFFF00attribute|r the shortcut will have by |cFFFFFF00right clicking|r his icon.\n- Left click |cFFFFFF00selects|r the shortcut attribute and |cFFFFFF00display|r it on the instance\n- Right click anywhere |cFFFFFF00closes|r the switch panel."
			Loc ["STRING_WELCOME_32"] = "Using the Interface: Snap Instances"
			Loc ["STRING_WELCOME_33"] = "You can |cFFFFFF00snap windows|r in vertical or horizontal. A window always snap with |cFFFFFF00previous instance number|r: like the image in the right, instance |cFFFFFF00#5|r snapped with |cFFFFFF00#4|r. When a snapped window is stretched, all other instances in the |cFFFFFF00cluster are also|r stretched."
			Loc ["STRING_WELCOME_34"] = "Using the Interface: Micro Display"
			Loc ["STRING_WELCOME_35"] = "All instances have three |cFFFFFF00mini widgets|r located at the bottom of window. |cFFFFFF00Right clicking|r pops up a menu and with |cFFFFFF00left click|r displays a options panel for that widget."
			Loc ["STRING_WELCOME_36"] = "Using the Interface: Plugins"
			Loc ["STRING_WELCOME_37"] = "|cFFFFFF00Threat, tank avoidance, and others|r are handled by |cFFFFFF00plugins|r. You can open a new instance, select '|cFFFFFF00Widgets|r' and choose what you want at |cFFFFFF00sword|r menu.\n\nTip: click over a bar on |cFFFFFF00Vanguard|r to show avoidance numbers."
			Loc ["STRING_WELCOME_38"] = "Ready to Raid!"
			Loc ["STRING_WELCOME_39"] = "Thank you for choosing Details!\n\nFeel free to always send feedbacks and bug reports to us (|cFFBBFFFFuse the fifth button a blue one|r), we appreciate."

			Loc ["STRING_WELCOME_40"] = "Which parts of a fight is important to you?"
			Loc ["STRING_WELCOME_41"] = "Some Cool Interface Tweaks:"
			
			Loc ["STRING_WELCOME_42"] = "Quick Appearance Settings"
			Loc ["STRING_WELCOME_43"] = "Choose your prefered skin:"
			Loc ["STRING_WELCOME_44"] = "Wallpaper"
			Loc ["STRING_WELCOME_45"] = "For more customization options, check the options panel."
			
		end
	end
	
	do
		local Loc = LibStub ("AceLocale-3.0"):NewLocale ("Details", "ptBR") 
		if (Loc) then
			
			Loc ["STRING_WELCOME_1"] = "|cFFFFFFFFBem vindo ao Details! Setup Rapido\n\n|rEste guia ira ajuda-la a configurar rapidamente aspectos basicos desde addon.\nVoce pode pular este guia a qualquer momento clicando no botao de cancelar."
			Loc ["STRING_WELCOME_2"] = "se voce mudar de ideia, voce pode mudar novamente no painel de opcoes"
			Loc ["STRING_WELCOME_3"] = "Escolha o metodo de DPS e HPS preferido:"
			Loc ["STRING_WELCOME_4"] = "Atividade"..": "
			Loc ["STRING_WELCOME_5"] = "Efetividade"..": "
			Loc ["STRING_WELCOME_6"] = "o tempo do jogador e posto em pausa quando sua atividade e interrompida voltando a contar seu tempo quando voltar a atividade, metodo mais comum."
			Loc ["STRING_WELCOME_7"] = "usado em rankings, este metodo usa o tempo total da luta para medir o Dps e Hps de todos os membros da raide."
			Loc ["STRING_WELCOME_8"] = "se voce mudar de ideia, voce pode mudar novamente no painel de opcoes"
			Loc ["STRING_WELCOME_9"] = "Details! faz a leitura e calculos do combate de uma maneira rapida, mas se algo e irrelevante para voce, e possivel desativa-lo."
			Loc ["STRING_WELCOME_10"] = "Passe o mouse para saber o que cada um representa"
			Loc ["STRING_WELCOME_11"] = "se voce mudar de ideia, voce pode mudar novamente no painel de opcoes"
			Loc ["STRING_WELCOME_12"] = "Aqui voce pode escolher o tempo de intervalo entre cada atualizacao da janela."
			Loc ["STRING_WELCOME_13"] = ""
			
			Loc ["STRING_WELCOME_14"] = "Update Speed"
			Loc ["STRING_WELCOME_14"] = "Intervalo de Atualizacao"
			Loc ["STRING_WELCOME_15"] = "tempo entre cada atualizacao,\nuso da cpu pode |cFFFF9900aumentar levemente|r com valores muito baixos\ne |cFF00FF00ter reducao|r com valores mais altos."
			Loc ["STRING_WELCOME_16"] = "Animar Barras"
			Loc ["STRING_WELCOME_17"] = "ativa ou desativa as animacoes das barras.\nuso da cpu pode |cFFFF9900aumentar levemente|r com esta opcao ligada."
			Loc ["STRING_WELCOME_18"] = "se voce mudar de ideia, voce pode mudar novamente no painel de opcoes"
			Loc ["STRING_WELCOME_19"] = "Ajustes da Memoria:"
			Loc ["STRING_WELCOME_20"] = "A quantidade de memoria nos addons nao afeta a taxa de quadros por segundo, mas, diminuir seu uso em computadores com pouca memoria, pode ajudar o desempenho em todo o sistema."
			Loc ["STRING_WELCOME_21"] = "total de segmentos"
			Loc ["STRING_WELCOME_22"] = "Quantos segmentos voce deseja armazenar."
			Loc ["STRING_WELCOME_23"] = "limites de memoria"
			
			Loc ["STRING_WELCOME_24"] = "Details! tenta auto ajustar a memoria usada de acordo com a memoria disponivel no sistema.\n\nTambem e recomendado limitar a quantidade de segmentos com 2Gb ou menor de memoria ram."
			Loc ["STRING_WELCOME_25"] = "segmentos salvos no logout"
			Loc ["STRING_WELCOME_26"] = "Usando a Interface: Stretch"
			Loc ["STRING_WELCOME_27"] = "- Quando o mouse esta sobre a janela, um |cFFFFFF00gancho|r aparecera no canto direito superior da janela. |cFFFFFF00Clique, segure e arraste|r para cima |cFFFFFF00para esticar|r a janela, soltando o clique o mouse |cFFFFFF00a janela volta ao tamanho original|r.\n\n- Se voce sente falta da |cFFFFBB00barra de rolagem|r, voce pode ativa-la no painel de opcoes."
			Loc ["STRING_WELCOME_28"] = "Usando a Interface: Botao de Instancias (janelas)"
			Loc ["STRING_WELCOME_29"] = "Botao de Instancias (janelas) e usado para:\n\n- mostrar |cFFFFFF00qual instancia|r ele eh, atraves do |cFFFFFF00#numero|r,\n- abrir uma |cFFFFFF00nova instancia do Details!|r quando clicado.\n- mostrado um menu das |cFFFFFF00janelas que estao fechadas|r para reabri-las."
			Loc ["STRING_WELCOME_30"] = "Usando a Interface: Atalhos"
			Loc ["STRING_WELCOME_31"] = "- Clicando com o Direito |cFFFFFF00em uma barra ou na janela|r abre |cFFFFFF00o menu de atalhos|r.\n- Voce pode escolher o |cFFFFFF00atributo|r que o atalho tera |cFFFFFF00clicando com o botao direito|r no seu icone.\n- Botao esquerdo |cFFFFFF00troca para aquele atributo|r \n- Botao direito fecha o painel de atalhos."
			Loc ["STRING_WELCOME_32"] = "Usando a Interface: Juntar Instancias"
			Loc ["STRING_WELCOME_33"] = "Voce pode |cFFFFFF00juntar as janelas|r na vertical ou horizontal. Uma janela grudara com a |cFFFFFF00janela anterior a ela|r: como na imagem a direita, a instancia |cFFFFFF00#5|r grudou na |cFFFFFF00#4|r. Quando grudadas, as janelas redimencionam, esticam e movem-se juntas."
			Loc ["STRING_WELCOME_34"] = "Usando a Interface: Mini Displays"
			Loc ["STRING_WELCOME_35"] = "Todas as janelas possuem 3 |cFFFFFF00mini displays|r localizados na parte inferior da janela. |cFFFFFF00Botao Direiro |r abrira um menu para escolher o que deseja mostrar |cFFFFFF00botao esquerdo|r abre as configuracoes."
			Loc ["STRING_WELCOME_36"] = "Usando a Interface: Plugins"
			Loc ["STRING_WELCOME_37"] = "|cFFFFFF00Ameaca, avoidance do tank, o muito mais|r podem ser vistos atraves de |cFFFFFF00plugins|r. Voce pode abrir uma nova janela e selecionar '|cFFFFFF00Widgets|r' e escolher o plugin no |cFFFFFF00menu da espada|r."
			Loc ["STRING_WELCOME_38"] = "Pronto Para Jogar!"
			Loc ["STRING_WELCOME_39"] = "Obrigado por escolher o Details!\n\nSinta-se a vontade para nos enviar feedbacks do que achou deste addon (|cFFBBFFFFno quinto botao, um azul|r)."

			Loc ["STRING_WELCOME_40"] = "Quais dados sao importantes para voce?"
			Loc ["STRING_WELCOME_41"] = "Alguns ajustes bacanas na interface:"
			
			Loc ["STRING_WELCOME_42"] = "Ajustes na Aparencia"
			Loc ["STRING_WELCOME_43"] = "Escolha sua Skin preferida:"
			Loc ["STRING_WELCOME_44"] = "Papel de Parede"
			Loc ["STRING_WELCOME_45"] = "Para mais ajustes na aparencia, veja o painel de opcoes."

		end
	end
		
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> page 1
		
		--> introduction
		
		local angel = window:CreateTexture (nil, "border")
		angel:SetPoint ("bottomright", window, "bottomright")
		angel:SetTexture ([[Interface\TUTORIALFRAME\UI-TUTORIALFRAME-SPIRITREZ]])
		angel:SetTexCoord (0.162109375, 0.591796875, 0, 1)
		angel:SetWidth (442)
		angel:SetHeight (256)
		angel:SetAlpha (.2)
		
		local texto1 = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto1:SetPoint ("topleft", window, "topleft", 13, -150)
		texto1:SetText (Loc ["STRING_WELCOME_1"])
		texto1:SetJustifyH ("left")
		
		pages [#pages+1] = {texto1, angel}
		
		
		
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> Skins Page

	--SKINS

		local bg55 = window:CreateTexture (nil, "overlay")
		bg55:SetTexture ([[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]])
		bg55:SetPoint ("bottomright", window, "bottomright", -10, 10)
		bg55:SetHeight (125*3)--125
		bg55:SetWidth (89*3)--82
		bg55:SetAlpha (.1)
		bg55:SetTexCoord (1, 0, 0, 1)

		local texto55 = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto55:SetPoint ("topleft", window, "topleft", 20, -80)
		texto55:SetText (Loc ["STRING_WELCOME_42"])

		local texto555 = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto555:SetPoint ("topleft", window, "topleft", 30, -190)
		texto555:SetText (Loc ["STRING_WELCOME_45"])
		texto555:SetTextColor (1, 1, 1, 1)
		
		local changemind = g:NewLabel (window, _, "$parentChangeMind55Label", "changemind55Label", Loc ["STRING_WELCOME_2"], "GameFontNormal", 9, "orange")
		window.changemind55Label:SetPoint ("center", window, "center")
		window.changemind55Label:SetPoint ("bottom", window, "bottom", 0, 19)
		window.changemind55Label.align = "|"
		
		local texto_appearance = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto_appearance:SetPoint ("topleft", window, "topleft", 30, -110)
		texto_appearance:SetText (Loc ["STRING_WELCOME_43"])
		texto_appearance:SetWidth (460)
		texto_appearance:SetHeight (100)
		texto_appearance:SetJustifyH ("left")
		texto_appearance:SetJustifyV ("top")
		texto_appearance:SetTextColor (1, 1, 1, 1)
		
		local skins_image = window:CreateTexture (nil, "overlay")
		skins_image:SetTexture ([[Interface\Addons\Details\images\icons2]])
		skins_image:SetPoint ("topright", window, "topright", -30, -24)
		skins_image:SetWidth (214)
		skins_image:SetHeight (133)
		skins_image:SetTexCoord (0, 0.41796875, 0, 0.259765625) --0, 0, 214 133
		
		
		--skin
			local onSelectSkin = function (_, _, skin_name)
				instance:ChangeSkin (skin_name)
			end

			local buildSkinMenu = function()
				local skinOptions = {}
				for skin_name, skin_table in pairs (_detalhes.skins) do
					skinOptions [#skinOptions+1] = {value = skin_name, label = skin_name, onclick = onSelectSkin, icon = "Interface\\GossipFrame\\TabardGossipIcon", desc = skin_table.desc}
				end
				return skinOptions
			end
			
			local skin_dropdown = g:NewDropDown (window, _, "$parentSkinDropdown", "skinDropdown", 140, 20, buildSkinMenu, 1)
			
			local skin_label = g:NewLabel (window, _, "$parentSkinLabel", "skinLabel", Loc ["STRING_OPTIONS_INSTANCE_SKIN"])
			skin_dropdown:SetPoint ("left", skin_label, "right", 2)
			skin_label:SetPoint ("topleft", window, "topleft", 30, -140)
			
			--skin_dropdown:Select ("Default Skin")
			
		--wallpapper
			--> agora cria os 2 dropdown da categoria e wallpaper
			
			local onSelectSecTexture = function (_, _, texturePath) 
				if (texturePath:find ("TALENTFRAME")) then
					instance:InstanceWallpaper (texturePath, nil, nil, {0, 1, 0, 0.703125})
				else
					instance:InstanceWallpaper (texturePath, nil, nil, {0, 1, 0, 1})
				end
			end
		
			local subMenu = {
				
				["ARCHEOLOGY"] = {
					{value = [[Interface\ARCHEOLOGY\Arch-BookCompletedLeft]], label = "Book Wallpaper", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\Arch-BookCompletedLeft]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\Arch-BookItemLeft]], label = "Book Wallpaper 2", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\Arch-BookItemLeft]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\Arch-Race-DraeneiBIG]], label = "Draenei", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\Arch-Race-DraeneiBIG]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\Arch-Race-DwarfBIG]], label = "Dwarf", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\Arch-Race-DwarfBIG]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\Arch-Race-NightElfBIG]], label = "Night Elf", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\Arch-Race-NightElfBIG]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\Arch-Race-OrcBIG]], label = "Orc", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\Arch-Race-OrcBIG]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\Arch-Race-PandarenBIG]], label = "Pandaren", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\Arch-Race-PandarenBIG]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\Arch-Race-TrollBIG]], label = "Troll", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\Arch-Race-TrollBIG]], texcoord = nil},

					{value = [[Interface\ARCHEOLOGY\ArchRare-AncientShamanHeaddress]], label = "Ancient Shaman", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-AncientShamanHeaddress]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\ArchRare-BabyPterrodax]], label = "Baby Pterrodax", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-BabyPterrodax]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\ArchRare-ChaliceMountainKings]], label = "Chalice Mountain Kings", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-ChaliceMountainKings]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\ArchRare-ClockworkGnome]], label = "Clockwork Gnomes", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-ClockworkGnome]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\ArchRare-QueenAzsharaGown]], label = "Queen Azshara Gown", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-QueenAzsharaGown]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\ArchRare-QuilinStatue]], label = "Quilin Statue", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-QuilinStatue]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\Arch-TempRareSketch]], label = "Rare Sketch", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\Arch-TempRareSketch]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\ArchRare-ScepterofAzAqir]], label = "Scepter of Az Aqir", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-ScepterofAzAqir]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\ArchRare-ShriveledMonkeyPaw]], label = "Shriveled Monkey Paw", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-ShriveledMonkeyPaw]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\ArchRare-StaffofAmmunrae]], label = "Staff of Ammunrae", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-StaffofAmmunrae]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\ArchRare-TinyDinosaurSkeleton]], label = "Tiny Dinosaur", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-TinyDinosaurSkeleton]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\ArchRare-TyrandesFavoriteDoll]], label = "Tyrandes Favorite Doll", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-TyrandesFavoriteDoll]], texcoord = nil},
					{value = [[Interface\ARCHEOLOGY\ArchRare-ZinRokhDestroyer]], label = "ZinRokh Destroyer", onclick = onSelectSecTexture, icon = [[Interface\ARCHEOLOGY\ArchRare-ZinRokhDestroyer]], texcoord = nil},
				},
			
				["CREDITS"] = {
					{value = [[Interface\Glues\CREDITS\Arakkoa2]], label = "Arakkoa", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Arakkoa2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Arcane_Golem2]], label = "Arcane Golem", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Arcane_Golem2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Badlands3]], label = "Badlands", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Badlands3]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\BD6]], label = "Draenei", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\BD6]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Draenei_Character1]], label = "Draenei 2", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Draenei_Character1]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Draenei_Character2]], label = "Draenei 3", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Draenei_Character2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Draenei_Crest2]], label = "Draenei Crest", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Draenei_Crest2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Draenei_Female2]], label = "Draenei 4", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Draenei_Female2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Draenei2]], label = "Draenei 5", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Draenei2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Blood_Elf_One1]], label = "Kael'thas", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Blood_Elf_One1]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\BD2]], label = "Blood Elf", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\BD2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\BloodElf_Priestess_Master2]], label = "Blood elf 2", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\BloodElf_Priestess_Master2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Female_BloodElf2]], label = "Blood Elf 3", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Female_BloodElf2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\CinSnow01TGA3]], label = "Cin Snow", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\CinSnow01TGA3]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\DalaranDomeTGA3]], label = "Dalaran", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\DalaranDomeTGA3]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Darnasis5]], label = "Darnasus", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Darnasis5]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Draenei_CityInt5]], label = "Exodar", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Draenei_CityInt5]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Shattrath6]], label = "Shattrath", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Shattrath6]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Demon_Chamber2]], label = "Demon Chamber", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Demon_Chamber2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Demon_Chamber6]], label = "Demon Chamber 2", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Demon_Chamber6]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Dwarfhunter1]], label = "Dwarf Hunter", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Dwarfhunter1]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Fellwood5]], label = "Fellwood", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Fellwood5]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\HordeBanner1]], label = "Horde Banner", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\HordeBanner1]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Illidan_Concept1]], label = "Illidan", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Illidan_Concept1]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Illidan1]], label = "Illidan 2", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Illidan1]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Naaru_CrashSite2]], label = "Naaru Crash", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Naaru_CrashSite2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\NightElves1]], label = "Night Elves", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\NightElves1]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Ocean2]], label = "Mountain", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Ocean2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Tempest_Keep2]], label = "Tempest Keep", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Tempest_Keep2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Tempest_Keep6]], label = "Tempest Keep 2", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Tempest_Keep6]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Terrokkar6]], label = "Terrokkar", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Terrokkar6]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\ThousandNeedles2]], label = "Thousand Needles", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\ThousandNeedles2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\Troll2]], label = "Troll", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\Troll2]], texcoord = nil},
					{value = [[Interface\Glues\CREDITS\LESSERELEMENTAL_FIRE_03B1]], label = "Fire Elemental", onclick = onSelectSecTexture, icon = [[Interface\Glues\CREDITS\LESSERELEMENTAL_FIRE_03B1]], texcoord = nil},
				},
			
				["DEATHKNIGHT"] = {
					{value = [[Interface\TALENTFRAME\bg-deathknight-blood]], label = "Blood", onclick = onSelectSecTexture, icon = [[Interface\ICONS\Spell_Deathknight_BloodPresence]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-deathknight-frost]], label = "Frost", onclick = onSelectSecTexture, icon = [[Interface\ICONS\Spell_Deathknight_FrostPresence]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-deathknight-unholy]], label = "Unholy", onclick = onSelectSecTexture, icon = [[Interface\ICONS\Spell_Deathknight_UnholyPresence]], texcoord = nil}
				},
				
				["DRESSUP"] = {
					{value = [[Interface\DRESSUPFRAME\DressUpBackground-BloodElf1]], label = "Blood Elf", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.5, 0.625, 0.75, 1}},
					{value = [[Interface\DRESSUPFRAME\DressUpBackground-DeathKnight1]], label = "Death Knight", onclick = onSelectSecTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["DEATHKNIGHT"]},
					{value = [[Interface\DRESSUPFRAME\DressUpBackground-Draenei1]], label = "Draenei", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.5, 0.625, 0.5, 0.75}},
					{value = [[Interface\DRESSUPFRAME\DressUpBackground-Dwarf1]], label = "Dwarf", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.125, 0.25, 0, 0.25}},
					{value = [[Interface\DRESSUPFRAME\DRESSUPBACKGROUND-GNOME1]], label = "Gnome", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.25, 0.375, 0, 0.25}},
					{value = [[Interface\DRESSUPFRAME\DressUpBackground-Goblin1]], label = "Goblin", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.625, 0.75, 0.75, 1}},
					{value = [[Interface\DRESSUPFRAME\DressUpBackground-Human1]], label = "Human", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0, 0.125, 0.5, 0.75}},
					{value = [[Interface\DRESSUPFRAME\DressUpBackground-NightElf1]], label = "Night Elf", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.375, 0.5, 0, 0.25}},
					{value = [[Interface\DRESSUPFRAME\DressUpBackground-Orc1]], label = "Orc", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.375, 0.5, 0.25, 0.5}},
					{value = [[Interface\DRESSUPFRAME\DressUpBackground-Pandaren1]], label = "Pandaren", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.75, 0.875, 0.5, 0.75}},
					{value = [[Interface\DRESSUPFRAME\DressUpBackground-Tauren1]], label = "Tauren", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0, 0.125, 0.25, 0.5}},
					{value = [[Interface\DRESSUPFRAME\DRESSUPBACKGROUND-TROLL1]], label = "Troll", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.25, 0.375, 0.75, 1}},
					{value = [[Interface\DRESSUPFRAME\DressUpBackground-Scourge1]], label = "Undead", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.125, 0.25, 0.75, 1}},
					{value = [[Interface\DRESSUPFRAME\DressUpBackground-Worgen1]], label = "Worgen", onclick = onSelectSecTexture, icon = [[Interface\Glues\CHARACTERCREATE\UI-CHARACTERCREATE-RACES]], texcoord = {0.625, 0.75, 0, 0.25}},
				},
				
				["DRUID"] = {
					{value = [[Interface\TALENTFRAME\bg-druid-bear]], label = "Guardian", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_racial_bearform]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-druid-restoration]], label = "Restoration", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_nature_healingtouch]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-druid-cat]], label = "Feral", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_shadow_vampiricaura]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-druid-balance]], label = "Balance", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_nature_starfall]], texcoord = nil}
				},
				
				["HUNTER"] = {
					{value = [[Interface\TALENTFRAME\bg-hunter-beastmaster]], label = "Beast Mastery", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_hunter_bestialdiscipline]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-hunter-marksman]], label = "Marksmanship", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_hunter_focusedaim]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-hunter-survival]], label = "Survival", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_hunter_camouflage]], texcoord = nil}
				},
				
				["MAGE"] = {
					{value = [[Interface\TALENTFRAME\bg-mage-arcane]], label = "Arcane", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_holy_magicalsentry]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-mage-fire]], label = "Fire", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_fire_firebolt02]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-mage-frost]], label = "Frost", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_frost_frostbolt02]], texcoord = nil}
				},

				["MONK"] = {
					{value = [[Interface\TALENTFRAME\bg-monk-brewmaster]], label = "Brewmaster", onclick = onSelectSecTexture, icon = [[Interface\ICONS\monk_stance_drunkenox]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-monk-mistweaver]], label = "Mistweaver", onclick = onSelectSecTexture, icon = [[Interface\ICONS\monk_stance_wiseserpent]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-monk-battledancer]], label = "Windwalker", onclick = onSelectSecTexture, icon = [[Interface\ICONS\monk_stance_whitetiger]], texcoord = nil}
				},

				["PALADIN"] = {
					{value = [[Interface\TALENTFRAME\bg-paladin-holy]], label = "Holy", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_holy_holybolt]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-paladin-protection]], label = "Protection", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_paladin_shieldofthetemplar]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-paladin-retribution]], label = "Retribution", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_holy_auraoflight]], texcoord = nil}
				},
				
				["PRIEST"] = {
					{value = [[Interface\TALENTFRAME\bg-priest-discipline]], label = "Discipline", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_holy_powerwordshield]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-priest-holy]], label = "Holy", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_holy_guardianspirit]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-priest-shadow]], label = "Shadow", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_shadow_shadowwordpain]], texcoord = nil}
				},

				["ROGUE"] = {
					{value = [[Interface\TALENTFRAME\bg-rogue-assassination]], label = "Assassination", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_rogue_eviscerate]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-rogue-combat]], label = "Combat", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_backstab]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-rogue-subtlety]], label = "Subtlety", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_stealth]], texcoord = nil}
				},

				["SHAMAN"] = {
					{value = [[Interface\TALENTFRAME\bg-shaman-elemental]], label = "Elemental", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_nature_lightning]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-shaman-enhancement]], label = "Enhancement", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_nature_lightningshield]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-shaman-restoration]], label = "Restoration", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_nature_magicimmunity]], texcoord = nil}	
				},
				
				["WARLOCK"] = {
					{value = [[Interface\TALENTFRAME\bg-warlock-affliction]], label = "Affliction", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_shadow_deathcoil]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-warlock-demonology]], label = "Demonology", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_shadow_metamorphosis]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-warlock-destruction]], label = "Destruction", onclick = onSelectSecTexture, icon = [[Interface\ICONS\spell_shadow_rainoffire]], texcoord = nil}
				},
				["WARRIOR"] = {
					{value = [[Interface\TALENTFRAME\bg-warrior-arms]], label = "Arms", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_warrior_savageblow]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-warrior-fury]], label = "Fury", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_warrior_innerrage]], texcoord = nil},
					{value = [[Interface\TALENTFRAME\bg-warrior-protection]], label = "Protection", onclick = onSelectSecTexture, icon = [[Interface\ICONS\ability_warrior_defensivestance]], texcoord = nil}
				},
			}
		
			local buildBackgroundMenu2 = function() 
				return  subMenu [window.backgroundDropdown.value] or {label = "-- -- --", value = 0}
			end
		
			local onSelectMainTexture = function (_, _, choose)
				window.backgroundDropdown2:Select (choose)
			end
		
			local backgroundTable = {
				{value = "ARCHEOLOGY", label = "Archeology", onclick = onSelectMainTexture, icon = [[Interface\ARCHEOLOGY\Arch-Icon-Marker]]},
				{value = "CREDITS", label = "Burning Crusade", onclick = onSelectMainTexture, icon = [[Interface\ICONS\TEMP]]},
				{value = "DEATHKNIGHT", label = "Death Knight", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["DEATHKNIGHT"]},
				{value = "DRESSUP", label = "Class Background", onclick = onSelectMainTexture, icon = [[Interface\ICONS\INV_Chest_Cloth_17]]},
				{value = "DRUID", label = "Druid", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["DRUID"]},
				{value = "HUNTER", label = "Hunter", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["HUNTER"]},
				{value = "MAGE", label = "Mage", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["MAGE"]},
				{value = "MONK", label = "Monk", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["MONK"]},
				{value = "PALADIN", label = "Paladin", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["PALADIN"]},
				{value = "PRIEST", label = "Priest", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["PRIEST"]},
				{value = "ROGUE", label = "Rogue", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["ROGUE"]},
				{value = "SHAMAN", label = "Shaman", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["SHAMAN"]},
				{value = "WARLOCK", label = "Warlock", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["WARLOCK"]},
				{value = "WARRIOR", label = "Warrior", onclick = onSelectMainTexture, icon = _detalhes.class_icons_small, texcoord = _detalhes.class_coords ["WARRIOR"]},
			}
			local buildBackgroundMenu = function() return backgroundTable end		
			
			local wallpaper_switch = g:NewSwitch (window, _, "$parentUseBackgroundSlider", "useBackgroundSlider", 60, 20, _, _, instance.wallpaper.enabled)
			local wallpaper_dropdown1 = g:NewDropDown (window, _, "$parentBackgroundDropdown", "backgroundDropdown", 150, 20, buildBackgroundMenu, nil)
			local wallpaper_dropdown2 = g:NewDropDown (window, _, "$parentBackgroundDropdown2", "backgroundDropdown2", 150, 20, buildBackgroundMenu2, nil)

			local wallpaper_label_switch = g:NewLabel (window, _, "$parentBackgroundLabel", "enablewallpaperLabel", Loc ["STRING_WELCOME_44"])
			wallpaper_label_switch:SetPoint ("topleft", window, "topleft", 30, -160)
			wallpaper_switch:SetPoint ("left", wallpaper_label_switch, "right", 2)
			wallpaper_dropdown1:SetPoint ("left", wallpaper_switch, "right", 2)
			wallpaper_dropdown2:SetPoint ("left", wallpaper_dropdown1, "right", 2)
			
			function _detalhes:WelcomeWallpaperRefresh()
				local spec = GetSpecialization()
				if (spec) then
					local id, name, description, icon, _background, role = GetSpecializationInfo (spec)
					if (_background) then
						local _, class = UnitClass ("player")
						
						local titlecase = function (first, rest)
							return first:upper()..rest:lower()
						end
						class = class:gsub ("(%a)([%w_']*)", titlecase)
						
						local bg = "Interface\\TALENTFRAME\\" .. _background
						
						wallpaper_dropdown1:Select (class)
						wallpaper_dropdown2:Select (1, true)
						
						instance.wallpaper.texture = bg
						instance.wallpaper.texcoord = {0, 1, 0, 0.703125}
						
					end
				end
			end
			
			_detalhes:ScheduleTimer ("WelcomeWallpaperRefresh", 5)
			
			wallpaper_switch.OnSwitch = function (_, _, value)
				instance.wallpaper.enabled = value
				if (value) then
					--> primeira vez que roda:
					if (not instance.wallpaper.texture) then
						local spec = GetSpecialization()
						if (spec) then
							local id, name, description, icon, _background, role = GetSpecializationInfo (spec)
							if (_background) then
								instance.wallpaper.texture = "Interface\\TALENTFRAME\\".._background
							end
						end
						instance.wallpaper.texcoord = {0, 1, 0, 0.703125}
					end
					
					instance.wallpaper.alpha = 0.35

					instance:InstanceWallpaper (true)
				else
					instance:InstanceWallpaper (false)
				end
			end

		pages [#pages+1] = {bg55, texto55, texto555, skins_image, changemind, texto_appearance, skin_dropdown, skin_label, wallpaper_label_switch, wallpaper_switch, wallpaper_dropdown1, wallpaper_dropdown2, }
		
		for _, widget in ipairs (pages[#pages]) do 
			widget:Hide()
		end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> page 2
		
	-- DPS effective or active
		
		local ampulheta = window:CreateTexture (nil, "overlay")
		ampulheta:SetTexture ([[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]])
		ampulheta:SetPoint ("bottomright", window, "bottomright", -10, 10)
		ampulheta:SetHeight (125*3)--125
		ampulheta:SetWidth (89*3)--82
		ampulheta:SetAlpha (.1)
		ampulheta:SetTexCoord (1, 0, 0, 1)		
		
		g:NewLabel (window, _, "$parentChangeMind2Label", "changemind2Label", Loc ["STRING_WELCOME_2"], "GameFontNormal", 9, "orange")
		window.changemind2Label:SetPoint ("center", window, "center")
		window.changemind2Label:SetPoint ("bottom", window, "bottom", 0, 19)
		window.changemind2Label.align = "|"

		local texto2 = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto2:SetPoint ("topleft", window, "topleft", 20, -80)
		texto2:SetText (Loc ["STRING_WELCOME_3"])
		
		local chronometer = CreateFrame ("CheckButton", "WelcomeWindowChronometer", window, "ChatConfigCheckButtonTemplate")
		chronometer:SetPoint ("topleft", window, "topleft", 40, -110)
		local continuous = CreateFrame ("CheckButton", "WelcomeWindowContinuous", window, "ChatConfigCheckButtonTemplate")
		continuous:SetPoint ("topleft", window, "topleft", 40, -160)
		
		_G ["WelcomeWindowChronometerText"]:SetText (Loc ["STRING_WELCOME_4"])
		_G ["WelcomeWindowContinuousText"]:SetText (Loc ["STRING_WELCOME_5"])
		
		local chronometer_text = window:CreateFontString (nil, "overlay", "GameFontNormal")
		chronometer_text:SetText (Loc ["STRING_WELCOME_6"])
		chronometer_text:SetWidth (360)
		chronometer_text:SetHeight (40)
		chronometer_text:SetJustifyH ("left")
		chronometer_text:SetJustifyV ("top")
		chronometer_text:SetTextColor (.8, .8, .8, 1)
		chronometer_text:SetPoint ("topleft", _G ["WelcomeWindowChronometerText"], "topright", 0, 0)
		
		local continuous_text = window:CreateFontString (nil, "overlay", "GameFontNormal")
		continuous_text:SetText (Loc ["STRING_WELCOME_7"])
		continuous_text:SetWidth (340)
		continuous_text:SetHeight (40)
		continuous_text:SetJustifyH ("left")
		continuous_text:SetJustifyV ("top")
		continuous_text:SetTextColor (.8, .8, .8, 1)
		continuous_text:SetPoint ("topleft", _G ["WelcomeWindowContinuousText"], "topright", 0, 0)
		
		chronometer:SetHitRectInsets (0, -70, 0, 0)
		continuous:SetHitRectInsets (0, -70, 0, 0)
		
		if (_detalhes.time_type == 1) then --> chronometer
			chronometer:SetChecked (true)
			continuous:SetChecked (false)
		elseif (_detalhes.time_type == 2) then --> continuous
			chronometer:SetChecked (false)
			continuous:SetChecked (true)
		end
		
		chronometer:SetScript ("OnClick", function() continuous:SetChecked (false); _detalhes.time_type = 1 end)
		continuous:SetScript ("OnClick", function() chronometer:SetChecked (false); _detalhes.time_type = 2 end)
		
		pages [#pages+1] = {ampulheta, texto2, chronometer, continuous, chronometer_text, continuous_text, window.changemind2Label}
		for _, widget in ipairs (pages[#pages]) do 
			widget:Hide()
		end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> page 3

	--CAPTURES

		local mecanica = window:CreateTexture (nil, "overlay")
		mecanica:SetTexture ([[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]])
		mecanica:SetPoint ("bottomright", window, "bottomright", -10, 10)
		mecanica:SetHeight (125*3)--125
		mecanica:SetWidth (89*3)--82
		mecanica:SetAlpha (.1)
		mecanica:SetTexCoord (1, 0, 0, 1)	
		
		g:NewLabel (window, _, "$parentChangeMind3Label", "changemind3Label", Loc ["STRING_WELCOME_8"], "GameFontNormal", 9, "orange")
		window.changemind3Label:SetPoint ("center", window, "center")
		window.changemind3Label:SetPoint ("bottom", window, "bottom", 0, 19)
		window.changemind3Label.align = "|"
		
		local texto3 = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto3:SetPoint ("topleft", window, "topleft", 20, -80)
		texto3:SetText (Loc ["STRING_WELCOME_40"])
		
		local data_text = window:CreateFontString (nil, "overlay", "GameFontNormal")
		data_text:SetText (Loc ["STRING_WELCOME_9"])
		data_text:SetWidth (460)
		data_text:SetHeight (40)
		data_text:SetJustifyH ("left")
		data_text:SetJustifyV ("top")
		data_text:SetTextColor (1, 1, 1, 1)
		data_text:SetPoint ("topleft", window, "topleft", 30, -105)
		
		local data_text2 = window:CreateFontString (nil, "overlay", "GameFontNormal")
		--data_text2:SetText ("Tip: for a best experience, it's recommend leave all turned on.")
		data_text2:SetText (Loc ["STRING_WELCOME_10"])
		data_text2:SetWidth (460)
		data_text2:SetHeight (40)
		data_text2:SetJustifyH ("left")
		data_text2:SetJustifyV ("top")
		data_text2:SetTextColor (1, 1, 1, 1)
		data_text2:SetPoint ("topleft", window, "topleft", 30, -201)
		
	--------------- Captures
		g:NewImage (window, [[Interface\AddOns\Details\images\atributos_captures]], 20, 20, nil, nil, "damageCaptureImage", "$parentCaptureDamage2")
		window.damageCaptureImage:SetPoint (35, -155)
		window.damageCaptureImage:SetTexCoord (0, 0.125, 0, 1)
		
		g:NewImage (window, [[Interface\AddOns\Details\images\atributos_captures]], 20, 20, nil, nil, "healCaptureImage", "$parentCaptureHeal2")
		window.healCaptureImage:SetPoint (170, -155)
		window.healCaptureImage:SetTexCoord (0.125, 0.25, 0, 1)
		
		g:NewImage (window, [[Interface\AddOns\Details\images\atributos_captures]], 20, 20, nil, nil, "energyCaptureImage", "$parentCaptureEnergy2")
		window.energyCaptureImage:SetPoint (305, -155)
		window.energyCaptureImage:SetTexCoord (0.25, 0.375, 0, 1)
		
		g:NewImage (window, [[Interface\AddOns\Details\images\atributos_captures]], 20, 20, nil, nil, "miscCaptureImage", "$parentCaptureMisc2")
		window.miscCaptureImage:SetPoint (35, -175)
		window.miscCaptureImage:SetTexCoord (0.375, 0.5, 0, 1)
		
		g:NewImage (window, [[Interface\AddOns\Details\images\atributos_captures]], 20, 20, nil, nil, "auraCaptureImage", "$parentCaptureAura2")
		window.auraCaptureImage:SetPoint (170, -175)
		window.auraCaptureImage:SetTexCoord (0.5, 0.625, 0, 1)
		
		g:NewLabel (window, _, "$parentCaptureDamageLabel", "damageCaptureLabel", "Damage")
		window.damageCaptureLabel:SetPoint ("left", window.damageCaptureImage, "right", 2)
		g:NewLabel (window, _, "$parentCaptureDamageLabel", "healCaptureLabel", "Healing")
		window.healCaptureLabel:SetPoint ("left", window.healCaptureImage, "right", 2)
		g:NewLabel (window, _, "$parentCaptureDamageLabel", "energyCaptureLabel", "Energy")
		window.energyCaptureLabel:SetPoint ("left", window.energyCaptureImage, "right", 2)
		g:NewLabel (window, _, "$parentCaptureDamageLabel", "miscCaptureLabel", "Misc")
		window.miscCaptureLabel:SetPoint ("left", window.miscCaptureImage, "right", 2)
		g:NewLabel (window, _, "$parentCaptureDamageLabel", "auraCaptureLabel", "Auras")
		window.auraCaptureLabel:SetPoint ("left", window.auraCaptureImage, "right", 2)
		
		local switch_icon_color = function (icon, on_off)
			icon:SetDesaturated (not on_off)
		end
		
		g:NewSwitch (window, _, "$parentCaptureDamageSlider", "damageCaptureSlider", 60, 20, _, _, _detalhes.capture_real ["damage"])
		window.damageCaptureSlider:SetPoint ("left", window.damageCaptureLabel, "right", 2)
		window.damageCaptureSlider.tooltip = "Pause or enable capture of:\n- damage done\n- damage per second\n- friendly fire\n- damage taken"
		window.damageCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes:CaptureSet (value, "damage", true)
			switch_icon_color (window.damageCaptureImage, value)
		end
		switch_icon_color (window.damageCaptureImage, _detalhes.capture_real ["damage"])
		
		g:NewSwitch (window, _, "$parentCaptureHealSlider", "healCaptureSlider", 60, 20, _, _, _detalhes.capture_real ["heal"])
		window.healCaptureSlider:SetPoint ("left", window.healCaptureLabel, "right", 2)
		window.healCaptureSlider.tooltip = "Pause or enable capture of:\n- healing done\n- absorbs\n- healing per second\n- overheal\n- healing taken\n- enemy healed"
		window.healCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes:CaptureSet (value, "heal", true)
			switch_icon_color (window.healCaptureImage, value)
		end
		switch_icon_color (window.healCaptureImage, _detalhes.capture_real ["heal"])
		
		g:NewSwitch (window, _, "$parentCaptureEnergySlider", "energyCaptureSlider", 60, 20, _, _, _detalhes.capture_real ["energy"])
		window.energyCaptureSlider:SetPoint ("left", window.energyCaptureLabel, "right", 2)
		window.energyCaptureSlider.tooltip = "Pause or enable capture of:\n- mana restored\n- rage generated\n- energy generated\n- runic power generated"
		window.energyCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes:CaptureSet (value, "energy", true)
			switch_icon_color (window.energyCaptureImage, value)
		end
		switch_icon_color (window.energyCaptureImage, _detalhes.capture_real ["energy"])
		
		g:NewSwitch (window, _, "$parentCaptureMiscSlider", "miscCaptureSlider", 60, 20, _, _, _detalhes.capture_real ["miscdata"])
		window.miscCaptureSlider:SetPoint ("left", window.miscCaptureLabel, "right", 2)
		window.miscCaptureSlider.tooltip = "Pause or enable capture of:\n- cc breaks\n- dispell\n- interrupts\n- ress\n- deaths\n- frags"
		window.miscCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes:CaptureSet (value, "miscdata", true)
			switch_icon_color (window.miscCaptureImage, value)
		end
		switch_icon_color (window.miscCaptureImage, _detalhes.capture_real ["miscdata"])
		
		g:NewSwitch (window, _, "$parentCaptureAuraSlider", "auraCaptureSlider", 60, 20, _, _, _detalhes.capture_real ["aura"])
		window.auraCaptureSlider:SetPoint ("left", window.auraCaptureLabel, "right", 2)
		window.auraCaptureSlider.tooltip = "Pause or enable capture of:\n- buffs uptime\n- debuffs uptime\n- void zones\n- cooldowns"
		window.auraCaptureSlider.OnSwitch = function (self, _, value)
			_detalhes:CaptureSet (value, "aura", true)
			switch_icon_color (window.auraCaptureImage, value)
		end
		switch_icon_color (window.auraCaptureImage, _detalhes.capture_real ["aura"])		
		
		pages [#pages+1] = {mecanica, texto3, data_text, window.damageCaptureImage, window.healCaptureImage, window.energyCaptureImage, window.miscCaptureImage,
		window.auraCaptureImage, window.damageCaptureSlider, window.healCaptureSlider, window.energyCaptureSlider, window.miscCaptureSlider, window.auraCaptureSlider, 
		window.damageCaptureLabel, window.healCaptureLabel, window.energyCaptureLabel, window.miscCaptureLabel, window.auraCaptureLabel, data_text2, window.changemind3Label}
		
		for _, widget in ipairs (pages[#pages]) do 
			widget:Hide()
		end
		
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> page 4

	-- UPDATE SPEED
		
		local bg = window:CreateTexture (nil, "overlay")
		bg:SetTexture ([[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]])
		bg:SetPoint ("bottomright", window, "bottomright", -10, 10)
		bg:SetHeight (125*3)--125
		bg:SetWidth (89*3)--82
		bg:SetAlpha (.1)
		bg:SetTexCoord (1, 0, 0, 1)
		
		g:NewLabel (window, _, "$parentChangeMind4Label", "changemind4Label", Loc ["STRING_WELCOME_11"], "GameFontNormal", 9, "orange")
		window.changemind4Label:SetPoint ("center", window, "center")
		window.changemind4Label:SetPoint ("bottom", window, "bottom", 0, 19)
		window.changemind4Label.align = "|"
		
		local texto4 = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto4:SetPoint ("topleft", window, "topleft", 20, -80)
		texto4:SetText (Loc ["STRING_WELCOME_41"])
		
		local interval_text = window:CreateFontString (nil, "overlay", "GameFontNormal")
		interval_text:SetText (Loc ["STRING_WELCOME_12"])
		interval_text:SetWidth (460)
		interval_text:SetHeight (40)
		interval_text:SetJustifyH ("left")
		interval_text:SetJustifyV ("top")
		interval_text:SetTextColor (1, 1, 1, 1)
		interval_text:SetPoint ("topleft", window, "topleft", 30, -110)
		
		local dance_text = window:CreateFontString (nil, "overlay", "GameFontNormal")
		dance_text:SetText (Loc ["STRING_WELCOME_13"])
		dance_text:SetWidth (460)
		dance_text:SetHeight (40)
		dance_text:SetJustifyH ("left")
		dance_text:SetJustifyV ("top")
		dance_text:SetTextColor (1, 1, 1, 1)
		dance_text:SetPoint ("topleft", window, "topleft", 30, -175)
		
	--------------- Update Speed
		g:NewLabel (window, _, "$parentUpdateSpeedLabel", "updatespeedLabel", Loc ["STRING_WELCOME_14"])
		window.updatespeedLabel:SetPoint (31, -150)
		--
		
		g:NewSlider (window, _, "$parentSliderUpdateSpeed", "updatespeedSlider", 160, 20, 0.050, 3, 0.050, _detalhes.update_speed, true) --parent, container, name, member, w, h, min, max, step, defaultv
		window.updatespeedSlider:SetPoint ("left", window.updatespeedLabel, "right", 2, 0)
		window.updatespeedSlider:SetThumbSize (50)
		window.updatespeedSlider.useDecimals = true
		local updateColor = function (slider, value)
			if (value < 1) then
				slider.amt:SetTextColor (1, value, 0)
			elseif (value > 1) then
				slider.amt:SetTextColor (-(value-3), 1, 0)
			else
				slider.amt:SetTextColor (1, 1, 0)
			end
		end
		window.updatespeedSlider:SetHook ("OnValueChange", function (self, _, amount) 
			_detalhes:CancelTimer (_detalhes.atualizador)
			_detalhes.update_speed = amount
			_detalhes.atualizador = _detalhes:ScheduleRepeatingTimer ("AtualizaGumpPrincipal", _detalhes.update_speed, -1)
			updateColor (self, amount)
		end)
		updateColor (window.updatespeedSlider, _detalhes.update_speed)
		
		window.updatespeedSlider:SetHook ("OnEnter", function()
			_detalhes:CooltipPreset (1)
			GameCooltip:AddLine (Loc ["STRING_WELCOME_15"])
			GameCooltip:ShowCooltip (window.updatespeedSlider, "tooltip")
			return true
		end)
		
		window.updatespeedSlider.tooltip = Loc ["STRING_WELCOME_15"]
		
	--------------- Animate Rows
		g:NewLabel (window, _, "$parentAnimateLabel", "animateLabel", Loc ["STRING_WELCOME_16"])
		window.animateLabel:SetPoint (31, -175)
		--
		g:NewSwitch (window, _, "$parentAnimateSlider", "animateSlider", 60, 20, _, _, _detalhes.use_row_animations) -- ltext, rtext, defaultv
		window.animateSlider:SetPoint ("left",window.animateLabel, "right", 2, 0)
		window.animateSlider.OnSwitch = function (self, _, value) --> slider, fixedValue, sliderValue (false, true)
			_detalhes.use_row_animations = value
		end	
		window.animateSlider.tooltip = Loc ["STRING_WELCOME_17"]
		
		pages [#pages+1] = {bg, texto4, interval_text, dance_text, window.updatespeedLabel, window.updatespeedSlider, window.animateLabel, window.animateSlider, window.changemind4Label}
		
		for _, widget in ipairs (pages[#pages]) do 
			widget:Hide()
		end
		
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> page 5

	--max segments, memory

		local bg44 = window:CreateTexture (nil, "overlay")
		bg44:SetTexture ([[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]])
		bg44:SetPoint ("bottomright", window, "bottomright", -10, 10)
		bg44:SetHeight (125*3)--125
		bg44:SetWidth (89*3)--82
		bg44:SetAlpha (.1)
		bg44:SetTexCoord (1, 0, 0, 1)
		
		g:NewLabel (window, _, "$parentChangeMind44Label", "changemind44Label", Loc ["STRING_WELCOME_18"], "GameFontNormal", 9, "orange")
		window.changemind44Label:SetPoint ("center", window, "center")
		window.changemind44Label:SetPoint ("bottom", window, "bottom", 0, 19)
		window.changemind44Label.align = "|"
		
		local texto44 = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto44:SetPoint ("topleft", window, "topleft", 20, -80)
		texto44:SetText (Loc ["STRING_WELCOME_19"])
		
		local interval_text4 = window:CreateFontString (nil, "overlay", "GameFontNormal")
		interval_text4:SetText (Loc ["STRING_WELCOME_20"])
		interval_text4:SetWidth (460)
		interval_text4:SetHeight (60)
		interval_text4:SetJustifyH ("left")
		interval_text4:SetJustifyV ("top")
		interval_text4:SetTextColor (1, 1, 1, 1)
		interval_text4:SetPoint ("topleft", window, "topleft", 30, -110)
		
		--[[
		local dance_text = window:CreateFontString (nil, "overlay", "GameFontNormal")
		dance_text:SetText ("Low amount of segments can keep memory .")
		dance_text:SetWidth (460)
		dance_text:SetHeight (40)
		dance_text:SetJustifyH ("left")
		dance_text:SetJustifyV ("top")
		dance_text:SetTextColor (1, 1, 1, 1)
		dance_text:SetPoint ("topleft", window, "topleft", 30, -170)
		--]]
	--------------- Max Segments
		g:NewLabel (window, _, "$parentSliderLabel", "segmentsLabel", Loc ["STRING_WELCOME_21"])
		window.segmentsLabel:SetPoint (31, -170)
		--
		g:NewSlider (window, _, "$parentSlider", "segmentsSlider", 120, 20, 1, 25, 1, _detalhes.segments_amount) -- min, max, step, defaultv
		window.segmentsSlider:SetPoint ("left", window.segmentsLabel, "right", 2, 0)
		window.segmentsSlider:SetHook ("OnValueChange", function (self, _, amount) --> slider, fixedValue, sliderValue
			_detalhes.segments_amount = math.floor (amount)
		end)
		window.segmentsSlider.tooltip = Loc ["STRING_WELCOME_22"]
		
	--------------- memory
		g:NewLabel (window, _, "$parentLabelMemory", "memoryLabel", Loc ["STRING_WELCOME_23"])
		window.memoryLabel:SetPoint (31, -185)
		--
		g:NewSlider (window, _, "$parentSliderMemory", "memorySlider", 130, 20, 1, 4, 1, _detalhes.memory_threshold) -- min, max, step, defaultv
		window.memorySlider:SetPoint ("left", window.memoryLabel, "right", 2, 0)
		window.memorySlider:SetHook ("OnValueChange", function (slider, _, amount) --> slider, fixedValue, sliderValue
			
			amount = math.floor (amount)
			
			if (amount == 1) then
				slider.amt:SetText ("<= 1gb")
				_detalhes.memory_ram = 16
			elseif (amount == 2) then
				slider.amt:SetText ("2gb")
				_detalhes.memory_ram = 32
			elseif (amount == 3) then
				slider.amt:SetText ("4gb")
				_detalhes.memory_ram = 64
			elseif (amount == 4) then
				slider.amt:SetText (">= 6gb")
				_detalhes.memory_ram = 128
			end
			
			_detalhes.memory_threshold = amount
			return true
		end)
		window.memorySlider.tooltip = Loc ["STRING_WELCOME_24"]
		window.memorySlider.thumb:SetSize (40, 10)
		window.memorySlider.thumb:SetTexture ([[Interface\Buttons\UI-Listbox-Highlight2]])
		window.memorySlider.thumb:SetVertexColor (.2, .2, .2, .9)
		local t = _detalhes.memory_threshold
		window.memorySlider:SetValue (1)
		window.memorySlider:SetValue (2)
		window.memorySlider:SetValue (t)
		
	--------------- Max Segments Saved
		g:NewLabel (window, _, "$parentLabelSegmentsSave", "segmentsSaveLabel", Loc ["STRING_WELCOME_25"])
		window.segmentsSaveLabel:SetPoint (31, -200)
		--
		g:NewSlider (window, _, "$parentSliderSegmentsSave", "segmentsSliderToSave", 120, 20, 1, 5, 1, _detalhes.segments_amount_to_save) -- min, max, step, defaultv
		window.segmentsSliderToSave:SetPoint ("left", window.segmentsSaveLabel, "right")
		window.segmentsSliderToSave:SetHook ("OnValueChange", function (self, _, amount) --> slider, fixedValue, sliderValue
			_detalhes.segments_amount_to_save = math.floor (amount)
		end)
		window.segmentsSliderToSave.tooltip = "High values may increase the time between a\nlogout button click and your character selection screen.\n\nIf you rarely check 'last day data', it`s high recommeded save only 1."
		
		pages [#pages+1] = {bg44, window.changemind44Label, texto44, interval_text4, window.memorySlider, window.memoryLabel, window.segmentsLabel, window.segmentsSlider, window.segmentsSaveLabel, window.segmentsSliderToSave}
		
		for _, widget in ipairs (pages[#pages]) do 
			widget:Hide()
		end
		
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> page 5.5


		
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> page 6

		local bg6 = window:CreateTexture (nil, "overlay")
		bg6:SetTexture ([[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]])
		bg6:SetPoint ("bottomright", window, "bottomright", -10, 10)
		bg6:SetHeight (125*3)--125
		bg6:SetWidth (89*3)--82
		bg6:SetAlpha (.1)
		bg6:SetTexCoord (1, 0, 0, 1)

		local texto5 = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto5:SetPoint ("topleft", window, "topleft", 20, -80)
		texto5:SetText (Loc ["STRING_WELCOME_26"])
		
		local texto_stretch = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto_stretch:SetPoint ("topleft", window, "topleft", 181, -105)
		texto_stretch:SetText (Loc ["STRING_WELCOME_27"])
		texto_stretch:SetWidth (310)
		texto_stretch:SetHeight (100)
		texto_stretch:SetJustifyH ("left")
		texto_stretch:SetJustifyV ("top")
		texto_stretch:SetTextColor (1, 1, 1, 1)
		
		local stretch_image = window:CreateTexture (nil, "overlay")
		stretch_image:SetTexture ([[Interface\Addons\Details\images\icons]])
		stretch_image:SetPoint ("right", texto_stretch, "left", -12, 0)
		stretch_image:SetWidth (144)
		stretch_image:SetHeight (61)
		stretch_image:SetTexCoord (0.716796875, 1, 0.876953125, 1)
		
		pages [#pages+1] = {bg6, texto5, stretch_image, texto_stretch}
		
		for _, widget in ipairs (pages[#pages]) do 
			widget:Hide()
		end
		
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> page 7

		local bg6 = window:CreateTexture (nil, "overlay")
		bg6:SetTexture ([[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]])
		bg6:SetPoint ("bottomright", window, "bottomright", -10, 10)
		bg6:SetHeight (125*3)--125
		bg6:SetWidth (89*3)--82
		bg6:SetAlpha (.1)
		bg6:SetTexCoord (1, 0, 0, 1)

		local texto6 = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto6:SetPoint ("topleft", window, "topleft", 20, -80)
		texto6:SetText (Loc ["STRING_WELCOME_28"])
		
		local texto_instance_button = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto_instance_button:SetPoint ("topleft", window, "topleft", 25, -105)
		texto_instance_button:SetText (Loc ["STRING_WELCOME_29"])
		texto_instance_button:SetWidth (270)
		texto_instance_button:SetHeight (100)
		texto_instance_button:SetJustifyH ("left")
		texto_instance_button:SetJustifyV ("top")
		texto_instance_button:SetTextColor (1, 1, 1, 1)
		
		local instance_button_image = window:CreateTexture (nil, "overlay")
		instance_button_image:SetTexture ([[Interface\Addons\Details\images\icons]])
		instance_button_image:SetPoint ("topright", window, "topright", -12, -70)
		instance_button_image:SetWidth (204)
		instance_button_image:SetHeight (141)
		instance_button_image:SetTexCoord (0.31640625, 0.71484375, 0.724609375, 1)
		
		pages [#pages+1] = {bg6, texto6, instance_button_image, texto_instance_button}
		
		for _, widget in ipairs (pages[#pages]) do 
			widget:Hide()
		end
		
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> page 8

		local bg7 = window:CreateTexture (nil, "overlay")
		bg7:SetTexture ([[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]])
		bg7:SetPoint ("bottomright", window, "bottomright", -10, 10)
		bg7:SetHeight (125*3)--125
		bg7:SetWidth (89*3)--82
		bg7:SetAlpha (.1)
		bg7:SetTexCoord (1, 0, 0, 1)

		local texto7 = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto7:SetPoint ("topleft", window, "topleft", 20, -80)
		texto7:SetText (Loc ["STRING_WELCOME_30"])
		
		local texto_shortcut = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto_shortcut:SetPoint ("topleft", window, "topleft", 25, -110)
		texto_shortcut:SetText (Loc ["STRING_WELCOME_31"])
		texto_shortcut:SetWidth (320)
		texto_shortcut:SetHeight (90)
		texto_shortcut:SetJustifyH ("left")
		texto_shortcut:SetJustifyV ("top")
		texto_shortcut:SetTextColor (1, 1, 1, 1)
		
		local shortcut_image1 = window:CreateTexture (nil, "overlay")
		shortcut_image1:SetTexture ([[Interface\Addons\Details\images\icons]])
		shortcut_image1:SetPoint ("topright", window, "topright", -12, -20)
		shortcut_image1:SetWidth (160)
		shortcut_image1:SetHeight (91)
		shortcut_image1:SetTexCoord (0, 0.31250, 0.82421875, 1)
		
		local shortcut_image2 = window:CreateTexture (nil, "overlay")
		shortcut_image2:SetTexture ([[Interface\Addons\Details\images\icons]])
		shortcut_image2:SetPoint ("topright", window, "topright", -12, -110)
		shortcut_image2:SetWidth (160)
		shortcut_image2:SetHeight (106)
		shortcut_image2:SetTexCoord (0, 0.31250, 0.59375, 0.80078125)
		
		pages [#pages+1] = {bg7, texto7, shortcut_image1, shortcut_image2, texto_shortcut}
		
		for _, widget in ipairs (pages[#pages]) do 
			widget:Hide()
		end
		
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> page 9

		local bg77 = window:CreateTexture (nil, "overlay")
		bg77:SetTexture ([[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]])
		bg77:SetPoint ("bottomright", window, "bottomright", -10, 10)
		bg77:SetHeight (125*3)--125
		bg77:SetWidth (89*3)--82
		bg77:SetAlpha (.1)
		bg77:SetTexCoord (1, 0, 0, 1)

		local texto77 = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto77:SetPoint ("topleft", window, "topleft", 20, -80)
		texto77:SetText (Loc ["STRING_WELCOME_32"])
		
		local texto_snap = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto_snap:SetPoint ("topleft", window, "topleft", 25, -101)
		texto_snap:SetText (Loc ["STRING_WELCOME_33"])
		texto_snap:SetWidth (160)
		texto_snap:SetHeight (110)
		texto_snap:SetJustifyH ("left")
		texto_snap:SetJustifyV ("top")
		texto_snap:SetTextColor (1, 1, 1, 1)
		local fonte, _, flags = texto_snap:GetFont()
		texto_snap:SetFont (fonte, 11, flags)
		
		local snap_image1 = window:CreateTexture (nil, "overlay")
		snap_image1:SetTexture ([[Interface\Addons\Details\images\icons]])
		snap_image1:SetPoint ("topright", window, "topright", -12, -95)
		snap_image1:SetWidth (308)
		snap_image1:SetHeight (121)
		snap_image1:SetTexCoord (0, 0.6015625, 0.353515625, 0.58984375)

		
		pages [#pages+1] = {bg77, texto77, snap_image1, texto_snap}
		
		for _, widget in ipairs (pages[#pages]) do 
			widget:Hide()
		end
		
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> page 10

		local bg88 = window:CreateTexture (nil, "overlay")
		bg88:SetTexture ([[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]])
		bg88:SetPoint ("bottomright", window, "bottomright", -10, 10)
		bg88:SetHeight (125*3)--125
		bg88:SetWidth (89*3)--82
		bg88:SetAlpha (.1)
		bg88:SetTexCoord (1, 0, 0, 1)

		local texto88 = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto88:SetPoint ("topleft", window, "topleft", 20, -80)
		texto88:SetText (Loc ["STRING_WELCOME_34"])
		--|cFFFFFF00
		local texto_micro_display = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto_micro_display:SetPoint ("topleft", window, "topleft", 25, -101)
		texto_micro_display:SetText (Loc ["STRING_WELCOME_35"])
		texto_micro_display:SetWidth (160)
		texto_micro_display:SetHeight (110)
		texto_micro_display:SetJustifyH ("left")
		texto_micro_display:SetJustifyV ("top")
		texto_micro_display:SetTextColor (1, 1, 1, 1)
		--local fonte, _, flags = texto_micro_display:GetFont()
		--texto_micro_display:SetFont (fonte, 11, flags)
		
		local micro_image1 = window:CreateTexture (nil, "overlay")
		micro_image1:SetTexture ([[Interface\Addons\Details\images\icons]])
		micro_image1:SetPoint ("topright", window, "topright", -12, -95)
		micro_image1:SetWidth (303)
		micro_image1:SetHeight (128)
		micro_image1:SetTexCoord (0.408203125, 1, 0.09375, 0.341796875)
		
		pages [#pages+1] = {bg88, texto88, micro_image1, texto_micro_display}
		
		for _, widget in ipairs (pages[#pages]) do 
			widget:Hide()
		end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> page 11

		local bg11 = window:CreateTexture (nil, "overlay")
		bg11:SetTexture ([[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]])
		bg11:SetPoint ("bottomright", window, "bottomright", -10, 10)
		bg11:SetHeight (125*3)--125
		bg11:SetWidth (89*3)--82
		bg11:SetAlpha (.1)
		bg11:SetTexCoord (1, 0, 0, 1)

		local texto11 = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto11:SetPoint ("topleft", window, "topleft", 20, -80)
		texto11:SetText (Loc ["STRING_WELCOME_36"])
		--|cFFFFFF00
		local texto_plugins = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto_plugins:SetPoint ("topleft", window, "topleft", 25, -101)
		texto_plugins:SetText (Loc ["STRING_WELCOME_37"])
		texto_plugins:SetWidth (220)
		texto_plugins:SetHeight (110)
		texto_plugins:SetJustifyH ("left")
		texto_plugins:SetJustifyV ("top")
		texto_plugins:SetTextColor (1, 1, 1, 1)
		--local fonte, _, flags = texto_plugins:GetFont()
		--texto_plugins:SetFont (fonte, 11, flags)
		
		local plugins_image1 = window:CreateTexture (nil, "overlay")
		plugins_image1:SetTexture ([[Interface\Addons\Details\images\icons2]])
		plugins_image1:SetPoint ("topright", window, "topright", -12, -35)
		plugins_image1:SetWidth (226)
		plugins_image1:SetHeight (181)
		plugins_image1:SetTexCoord (0.55859375, 1, 0.646484375, 1)
		
		pages [#pages+1] = {bg11, texto11, plugins_image1, texto_plugins}
		
		for _, widget in ipairs (pages[#pages]) do 
			widget:Hide()
		end		
		
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> page 12

		local bg8 = window:CreateTexture (nil, "overlay")
		bg8:SetTexture ([[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]])
		bg8:SetPoint ("bottomright", window, "bottomright", -10, 10)
		bg8:SetHeight (125*3)--125
		bg8:SetWidth (89*3)--82
		bg8:SetAlpha (.1)
		bg8:SetTexCoord (1, 0, 0, 1)

		local texto8 = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto8:SetPoint ("topleft", window, "topleft", 20, -80)
		texto8:SetText (Loc ["STRING_WELCOME_38"])
		
		local texto = window:CreateFontString (nil, "overlay", "GameFontNormal")
		texto:SetPoint ("topleft", window, "topleft", 25, -110)
		texto:SetText (Loc ["STRING_WELCOME_39"])
		texto:SetWidth (410)
		texto:SetHeight (90)
		texto:SetJustifyH ("left")
		texto:SetJustifyV ("top")
		texto:SetTextColor (1, 1, 1, 1)
		
		local report_image1 = window:CreateTexture (nil, "overlay")
		report_image1:SetTexture ([[Interface\Addons\Details\images\icons]])
		report_image1:SetPoint ("topright", window, "topright", -30, -97)
		report_image1:SetWidth (144)
		report_image1:SetHeight (30)
		report_image1:SetTexCoord (0.71875, 1, 0.81640625, 0.875)
	
		pages [#pages+1] = {bg8, texto8, texto, report_image1}
		
		for _, widget in ipairs (pages[#pages]) do 
			widget:Hide()
		end
		
------------------------------------------------------------------------------------------------------------------------------		
		
		--[[
		--forward:Click()
		--forward:Click()
		--forward:Click()
		--forward:Click()
		--forward:Click()
		--forward:Click()
		--forward:Click()
		--forward:Click()
		--forward:Click()
		--forward:Click()
		--]]

	end
	
end