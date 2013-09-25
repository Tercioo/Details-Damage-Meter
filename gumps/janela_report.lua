local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )

local _detalhes = 		_G._detalhes
local gump = 			_detalhes.gump

--lua locals
local _cstr = tostring --> lua local
local _math_ceil = math.ceil --> lua local
local _math_floor = math.floor --> lua local
local _string_len = string.len --> lua local
local _pairs = pairs --> lua local
local	_tinsert = tinsert --> lua local
local _IsInRaid = IsInRaid --> lua local

local _CreateFrame = CreateFrame --> wow api locals
local _IsInGuild = IsInGuild --> wow api locals
local _GetChannelList = GetChannelList --> wow api locals
local _UIParent = UIParent --> wow api locals

--> got weird errors with globals, not sure why
local _UIDropDownMenu_SetSelectedID = UIDropDownMenu_SetSelectedID --> wow api locals
local _UIDropDownMenu_CreateInfo = UIDropDownMenu_CreateInfo --> wow api locals
local _UIDropDownMenu_AddButton = UIDropDownMenu_AddButton --> wow api locals
local _UIDropDownMenu_Initialize = UIDropDownMenu_Initialize --> wow api locals
local _UIDropDownMenu_SetWidth = UIDropDownMenu_SetWidth --> wow api locals
local _UIDropDownMenu_SetButtonWidth = UIDropDownMenu_SetButtonWidth --> wow api locals
local _UIDropDownMenu_SetSelectedValue = UIDropDownMenu_SetSelectedValue --> wow api locals
local _UIDropDownMenu_JustifyText = UIDropDownMenu_JustifyText --> wow api locals
local _UISpecialFrames = UISpecialFrames --> wow api locals


--> details API functions -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	function _detalhes:SendReportLines (lines)
		if (type (lines) == "string") then
			lines = {lines}
		elseif (type (lines) ~= "table") then
			return _detalhes:NewError ("SendReportLines parameter 1 must be a table or string.")
		end
		return _detalhes:envia_relatorio (lines, true)
	end

	function _detalhes:SendReportWindow (func, _current, _inverse, _slider)

		if (type (func) ~= "function") then
			return _detalhes:NewError ("SendReportWindow parameter 1 must be a function.")
		end

		if (not _detalhes.janela_report) then
			_detalhes.janela_report = gump:CriaJanelaReport()
		end

		if (_current) then
			_G ["Details_Report_CB_1"]:Enable()
			_G ["Details_Report_CB_1Text"]:SetTextColor (1, 1, 1, 1)
		else
			_G ["Details_Report_CB_1"]:Disable()
			_G ["Details_Report_CB_1Text"]:SetTextColor (.5, .5, .5, 1)
		end
		
		if (_inverse) then
			_G ["Details_Report_CB_2"]:Enable()
			_G ["Details_Report_CB_2Text"]:SetTextColor (1, 1, 1, 1)
		else
			_G ["Details_Report_CB_2"]:Disable()
			_G ["Details_Report_CB_2Text"]:SetTextColor (.5, .5, .5, 1)
		end
		
		if (_slider) then
			_detalhes.janela_report.slider:Enable()
			_detalhes.janela_report.slider.lockTexture:Hide()
			_detalhes.janela_report.slider.amt:Show()
		else
			_detalhes.janela_report.slider:Disable()
			_detalhes.janela_report.slider.lockTexture:Show()
			_detalhes.janela_report.slider.amt:Hide()
		end
		
		if (_detalhes.janela_report.ativa) then 
			_detalhes.janela_report:Flash (0.2, 0.2, 0.4, true, 0, 0)
		end
		
		_detalhes.janela_report.ativa = true
		_detalhes.janela_report.enviar:SetScript ("OnClick", function() func (_G ["Details_Report_CB_1"]:GetChecked(), _G ["Details_Report_CB_2"]:GetChecked(), _detalhes.report_lines) end)
		
		gump:Fade (_detalhes.janela_report, 0)
		
		return true
	end

	
--> internal details report functions -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	function _detalhes:Reportar (param2, options)

		if (not _detalhes.janela_report) then
			_detalhes.janela_report = gump:CriaJanelaReport()
		end
		
		--> trabalha com as opções:
		if (options and options._no_current) then
			_G ["Details_Report_CB_1"]:Disable()
			_G ["Details_Report_CB_1Text"]:SetTextColor (.5, .5, .5, 1)
		else
			_G ["Details_Report_CB_1"]:Enable()
			_G ["Details_Report_CB_1Text"]:SetTextColor (1, 1, 1, 1)
		end
		
		if (options and options._no_inverse) then
			_G ["Details_Report_CB_2"]:Disable()
			_G ["Details_Report_CB_2Text"]:SetTextColor (.5, .5, .5, 1)
		else
			_G ["Details_Report_CB_2"]:Enable()
			_G ["Details_Report_CB_2Text"]:SetTextColor (1, 1, 1, 1)
		end
		
		_detalhes.janela_report.slider:Enable()
		_detalhes.janela_report.slider.lockTexture:Hide()
		_detalhes.janela_report.slider.amt:Show()

		if (options) then
			_detalhes.janela_report.enviar:SetScript ("OnClick", function() self:monta_relatorio (param2, options._custom) end)
		else
			_detalhes.janela_report.enviar:SetScript ("OnClick", function() self:monta_relatorio (param2) end)
		end

		if (_detalhes.janela_report.ativa) then 
			_detalhes.janela_report:Flash (0.2, 0.2, 0.4, true, 0, 0)
		end
		
		_detalhes.janela_report.ativa = true
		gump:Fade (_detalhes.janela_report, 0)
	end
	
--> build report frame gump -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--> script
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
	end

--> dropdown menus

	local function cria_drop_down (este_gump)

		local selecionar = _CreateFrame ("Button", "Details_Report_DropDown", este_gump, "UIDropDownMenuTemplate")
		este_gump.select = selecionar
		
		selecionar:SetPoint ("topleft", este_gump, "topleft", 93, -53)

		local function OnClick (self)
			_UIDropDownMenu_SetSelectedID (selecionar, self:GetID())
			_detalhes.report_where = self.value
		end
		
		local lista = {
			{Loc ["STRING_REPORTFRAME_PARTY"], "PARTY", function() return GetNumSubgroupMembers() > 0 end},
			{Loc ["STRING_REPORTFRAME_RAID"], "RAID", _IsInRaid}, 
			{Loc ["STRING_REPORTFRAME_GUILD"], "GUILD", _IsInGuild}, 
			{Loc ["STRING_REPORTFRAME_OFFICERS"], "OFFICER", _IsInGuild}, 
			{Loc ["STRING_REPORTFRAME_WHISPER"], "WHISPER"}, 
			{Loc ["STRING_REPORTFRAME_WHISPERTARGET"], "WHISPER2"}, 
			{Loc ["STRING_REPORTFRAME_SAY"], "SAY"} 
		}
		
		local function initialize (self, level)
			local info = _UIDropDownMenu_CreateInfo()

			for i = 8, #lista do 
				lista [i] = nil
			end
			
			local channels = {_GetChannelList()} --> coloca o resultado em uma tabela .. {id1, canal1, id2, canal2}
			for i = 1, #channels, 2 do --> total de canais
				lista [#lista+1] = {channels [i]..". "..channels [i+1], "CHANNEL|"..channels [i+1]}
			end

			for index, v in _pairs (lista) do
			
				if (not v[3] or (type (v[3]) == "function" and v[3]())) then
					info = _UIDropDownMenu_CreateInfo()
					info.text = v[1]
					info.value = v[2]
					info.func = OnClick
					_UIDropDownMenu_AddButton (info, level)
				end
			end
		end

		_UIDropDownMenu_Initialize (selecionar, initialize)
		_UIDropDownMenu_SetWidth (selecionar, 165)
		_UIDropDownMenu_SetButtonWidth (selecionar, 120)
		_UIDropDownMenu_SetSelectedValue (selecionar, "WHISPER")
		_detalhes.report_where = "WHISPER"
		_UIDropDownMenu_JustifyText (selecionar, "LEFT")
	end

--> slider

	local function cria_slider (este_gump)

		este_gump.linhas_amt = este_gump:CreateFontString (nil, "OVERLAY", "GameFontHighlight")
		este_gump.linhas_amt:SetText (Loc ["STRING_REPORTFRAME_LINES"])
		este_gump.linhas_amt:SetTextColor (.9, .9, .9, 1)
		este_gump.linhas_amt:SetPoint ("bottomleft", este_gump, "bottomleft", 58, 12)
		_detalhes:SetFontSize (este_gump.linhas_amt, 10)
		
		local slider = _CreateFrame ("Slider", "Details_Report_Slider", este_gump)
		este_gump.slider = slider
		slider:SetPoint ("bottomleft", este_gump, "bottomleft", 58, -7)
		
		slider.thumb = slider:CreateTexture (nil, "artwork")
		slider.thumb:SetTexture ("Interface\\Buttons\\UI-ScrollBar-Knob")
		slider.thumb:SetSize (30, 24)
		slider.thumb:SetAlpha (0.7)
		
		local lockTexture = slider:CreateTexture (nil, "overlay")
		lockTexture:SetPoint ("center", slider.thumb, "center", -1, -1)
		lockTexture:SetTexture ("Interface\\Buttons\\CancelButton-Up")
		lockTexture:SetWidth (29)
		lockTexture:SetHeight (24)
		lockTexture:Hide()
		slider.lockTexture = lockTexture

		slider:SetThumbTexture (slider.thumb) --depois 
		slider:SetOrientation ("HORIZONTAL")
		slider:SetMinMaxValues (1.0, 25.0)
		slider:SetValueStep (1.0)
		slider:SetWidth (232)
		slider:SetHeight (20)

		local last_value = _detalhes.report_lines or 5
		slider:SetValue (math.floor (last_value))
		
		slider.amt = slider:CreateFontString (nil, "OVERLAY", "GameFontHighlightSmall")
		local amt = slider:GetValue()
		if (amt < 10) then
			amt = "0"..amt
		end
		slider.amt:SetText (amt)
		slider.amt:SetTextColor (.8, .8, .8, 1)
		
		slider.amt:SetPoint ("center", slider.thumb, "center")
		
		slider:SetScript ("OnValueChanged", function (self) 
			local amt = math.floor (self:GetValue())
			_detalhes.report_lines = amt
			if (amt < 10) then
				amt = "0"..amt
			end
			self.amt:SetText (amt)
			end)
		
		slider:SetScript ("OnEnter", function (self)
				slider.thumb:SetAlpha (1)
		end)
		
		slider:SetScript ("OnLeave", function (self)
				slider.thumb:SetAlpha (0.7)
		end)
		
	end

--> whisper taget field

	local function cria_wisper_field (este_gump)
		
		este_gump.wisp_who = este_gump:CreateFontString (nil, "OVERLAY", "GameFontHighlight")
		este_gump.wisp_who:SetText (Loc ["STRING_REPORTFRAME_WHISPER"] .. ":")
		este_gump.wisp_who:SetTextColor (1, 1, 1, 1)
		
		este_gump.wisp_who:SetPoint ("topleft", este_gump.select, "topleft", 28, -30)
		
		_detalhes:SetFontSize (este_gump.wisp_who, 10)

		--editbox
		local editbox = _CreateFrame ("EditBox", nil, este_gump)
		este_gump.editbox = editbox
		
		editbox:SetAutoFocus (false)
		editbox:SetFontObject ("GameFontHighlightSmall")
		
		editbox:SetPoint ("TOPLEFT", este_gump.select, "TOPLEFT", 78, -28)
		
		editbox:SetHeight (14)
		editbox:SetWidth (120)
		editbox:SetJustifyH ("LEFT")
		editbox:EnableMouse(true)
		editbox:SetBackdrop ({
			bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
			edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
			tile = true, edgeSize = 1, tileSize = 5,
			})
		editbox:SetBackdropColor(0, 0, 0, 0.0)
		editbox:SetBackdropBorderColor(0.0, 0.0, 0.0, 0.0)
		
		local last_value = _detalhes.report_to_who or ""
		editbox:SetText (last_value)
		editbox.perdeu_foco = nil
		editbox.focus = false
		
		editbox:SetScript ("OnEnterPressed", function () 
			local texto = _detalhes:trim (editbox:GetText())
			if (_string_len (texto) > 0) then
				_detalhes.report_to_who = texto
				editbox:AddHistoryLine (texto)
				editbox:SetText (texto)
			else 
				_detalhes.report_to_who = ""
				editbox:SetText ("")
			end 
			editbox.perdeu_foco = true --> isso aqui pra quando estiver editando e clicar em outra caixa
			editbox:ClearFocus()
		end)
		
		editbox:SetScript ("OnEscapePressed", function() 
			editbox:SetText("") 
			_detalhes.report_to_who = ""
			editbox.perdeu_foco = true
			editbox:ClearFocus() 
		end)
		
		editbox:SetScript ("OnEnter", function() 
			editbox.mouse_over = true 
			editbox:SetBackdropColor(0.1, 0.1, 0.1, 0.7)
			if (editbox:GetText() == "" and not editbox.focus) then
				editbox:SetText (Loc ["STRING_REPORTFRAME_INSERTNAME"])
			end 
		end)
		
		editbox:SetScript ("OnLeave", function() 
			editbox.mouse_over = false 
			editbox:SetBackdropColor(0.0, 0.0, 0.0, 0.0)
			if (not editbox:HasFocus()) then 
				if (editbox:GetText() == Loc ["STRING_REPORTFRAME_INSERTNAME"]) then
					editbox:SetText("") 
				end 
			end 
		end)

		editbox:SetScript ("OnEditFocusGained", function()
			if (editbox:GetText() == Loc ["STRING_REPORTFRAME_INSERTNAME"]) then
				editbox:SetText("") 
			end
			
			if (editbox:GetText() ~= "") then
				--> selecionar todo o texto
				editbox:HighlightText (0, editbox:GetNumLetters())
			end
			
			editbox.focus = true
		end)
		
		editbox:SetScript ("OnEditFocusLost", function()
			if (editbox.perdeu_foco == nil) then
				local texto = _detalhes:trim (editbox:GetText())
				if (_string_len (texto) > 0) then 
					_detalhes.report_to_who = texto
				else
					_detalhes.report_to_who = ""
					editbox:SetText ("")
				end 
			else
				editbox.perdeu_foco = nil
			end
			
			editbox.focus = false
		end)
	end

--> both check buttons
		
	function cria_check_buttons (este_gump)
		local checkbox = _CreateFrame ("CheckButton", "Details_Report_CB_1", este_gump, "ChatConfigCheckButtonTemplate")
		checkbox:SetPoint ("topleft", este_gump.wisp_who, "bottomleft", -25, -4)
		_G [checkbox:GetName().."Text"]:SetText (Loc ["STRING_REPORTFRAME_CURRENT"])
		_detalhes:SetFontSize (_G [checkbox:GetName().."Text"], 10)
		checkbox.tooltip = Loc ["STRING_REPORTFRAME_CURRENTINFO"]
		checkbox:SetHitRectInsets (0, -35, 0, 0)
		
		local checkbox2 = _CreateFrame ("CheckButton", "Details_Report_CB_2", este_gump, "ChatConfigCheckButtonTemplate")
		checkbox2:SetPoint ("topleft", este_gump.wisp_who, "bottomleft", 35, -4)
		_G [checkbox2:GetName().."Text"]:SetText (Loc ["STRING_REPORTFRAME_REVERT"])
		_detalhes:SetFontSize (_G [checkbox2:GetName().."Text"], 10)
		checkbox2.tooltip = Loc ["STRING_REPORTFRAME_REVERTINFO"]
		checkbox2:SetHitRectInsets (0, -35, 0, 0)
	end

--> frame creation function

	function gump:CriaJanelaReport()
		
		local este_gump = _CreateFrame ("Frame", "DetailsReportWindow", _UIParent)
		este_gump:SetFrameStrata ("HIGH")

		_tinsert (_UISpecialFrames, este_gump:GetName())
		
		este_gump:SetScript ("OnHide", function (self)
			--[[ avoid taint problems
			if (not este_gump.hidden or este_gump.fading_in) then --> trick to fade an window closed by pressing escape
				este_gump:Show()
				gump:Fade (este_gump, "in")
			end
			--]]
			_detalhes.janela_report.ativa = false
		end)
		
		este_gump:SetPoint ("CENTER", UIParent)
		este_gump:SetWidth (320)
		este_gump:SetHeight (128)
		este_gump:EnableMouse (true)
		este_gump:SetResizable (false)
		este_gump:SetMovable (true)

		_detalhes.janela_report = este_gump
		
		--> icone
		este_gump.icone = este_gump:CreateTexture (nil, "BACKGROUND")
		este_gump.icone:SetPoint ("TOPLEFT", este_gump, "TOPLEFT", 40, -10)
		este_gump.icone:SetTexture ("Interface\\AddOns\\Details\\images\\report_frame_icons") --> top left
		este_gump.icone:SetWidth (64)
		este_gump.icone:SetHeight (64)
		este_gump.icone:SetTexCoord (1/256, 64/256, 1/256, 64/256) --left right top bottom
		
		--> cria as 2 partes do fundo da janela
		este_gump.bg1 = este_gump:CreateTexture (nil, "BORDER")
		este_gump.bg1:SetPoint ("TOPLEFT", este_gump, "TOPLEFT", 0, 0)
		este_gump.bg1:SetTexture ("Interface\\AddOns\\Details\\images\\report_frame1") --> top left

		este_gump.bg2 = este_gump:CreateTexture (nil, "BORDER")
		este_gump.bg2:SetPoint ("TOPRIGHT", este_gump, "TOPRIGHT", 0, 0)
		este_gump.bg2:SetTexture ("Interface\\AddOns\\Details\\images\\report_frame2") --> top right

		--> botão de fechar
		este_gump.fechar = CreateFrame ("Button", nil, este_gump, "UIPanelCloseButton")
		este_gump.fechar:SetWidth (32)
		este_gump.fechar:SetHeight (32)
		este_gump.fechar:SetPoint ("TOPRIGHT", este_gump, "TOPRIGHT", -20, -23)
		este_gump.fechar:SetText ("X")
		este_gump.fechar:SetScript ("OnClick", function()
			gump:Fade (este_gump, 1)
			_detalhes.janela_report.ativa = false
		end)	

		este_gump.titulo = este_gump:CreateFontString (nil, "OVERLAY", "GameFontHighlightLeft")
		este_gump.titulo:SetText (Loc ["STRING_REPORTFRAME_WINDOW_TITLE"])
		este_gump.titulo:SetTextColor (0.999, 0.819, 0, 1)
		este_gump.titulo:SetPoint ("topleft", este_gump, "topleft", 120, -33)

		seta_scripts (este_gump)

		cria_drop_down (este_gump)
		cria_slider (este_gump)
		cria_wisper_field (este_gump)
		cria_check_buttons (este_gump)

		este_gump.enviar = _CreateFrame ("Button", nil, este_gump, "OptionsButtonTemplate")
		
		este_gump.enviar:SetPoint ("topleft", este_gump.editbox, "topleft", 61, -19)
		
		este_gump.enviar:SetWidth (60)
		este_gump.enviar:SetHeight (15)
		este_gump.enviar:SetText (Loc ["STRING_REPORTFRAME_SEND"])

		gump:Fade (este_gump, 1)
		gump:CreateFlashAnimation (este_gump)
		
		return este_gump
		
	end