--localization
	--> english
	do
		local Loc = LibStub("AceLocale-3.0"):NewLocale ("DetailsErrorReport", "enUS", true) 
		if (Loc) then
			Loc ["STRING_PLUGIN_NAME"] = "Error Report"
			Loc ["STRING_TOOLTIP"] = "Did you found a bug? Report here!"
			Loc ["STRING_REPORT"] = "Details Report"
			Loc ["STRING_PROBLEM"] = "problem"
			Loc ["STRING_SUGESTION"] = "sugestion"
			Loc ["STRING_LUAERROR_DESC"] = "send a report about occurrence of lua errors"
			Loc ["STRING_ACCURACY_DESC"] = "you found something which isn't the amount that should be\nfor instance, some healing or damage spell doesn't have the correct amount calculated."
			Loc ["STRING_NOTWORK_DESC"] = "anything which should be doing something and actually isn't"
			Loc ["STRING_OTHER_DESC"] = "any other problem or perhaps a suggesting not involving the subjects above, can be reported here"
			Loc ["STRING_LUA_ERROR"] = "Lua Error"
			Loc ["STRING_ACCURACY_ERROR"] = "Instable Accuracy"
			Loc ["STRING_NOTWORK_ERROR"] = "Isn't Working"
			Loc ["STRING_OTHER_ERROR"] = "Other"
			
			Loc ["STRING_DEFAULT_TEXT_LUA"] = "You can copy and paste here the first 20 lines from the lua error window, also, is important a small description about the error, when it occurs and with what frequency it occurs."
			Loc ["STRING_DEFAULT_TEXT_ACCURACY"] = "A miss accuracy is normal and happen all the time, but when the problem happen with frequency it's important tell to us. A good way to report is analyzing when the instability occurs, if is caused by a spell or if is a untracked pet."
			Loc ["STRING_DEFAULT_TEXT_NOTWORK"] = "When you click in something and the result isn't the expected, could be a bug. If thing like this occurs more then once, report the problem to us, dont forget to mention which button is and the frequency."
			Loc ["STRING_DEFAULT_TEXT_OTHER"] = "Any other problem not mentioned in the other 3 options should be reported here."

			Loc ["STRING_WELCOME_TEXT"] = "Details are in early alpha stages and many errors can occur,\nto try make this report process faster, we'll use this small plug in,\nat least on alpha stage."
			Loc ["STRING_SEND"] = "Send"
			Loc ["STRING_CANCELLED"] = "Cancelled."
			Loc ["STRING_EMPTY"] = "Text field is empty"
			Loc ["STRING_TOOBIG"] = "1024 Text characters limit reached"
			
			Loc ["STRING_FEEDBACK_DESC"] = "Give your opinion about Details!"
			Loc ["STRING_FEEDBACK"] = "Feedback"
			Loc ["STRING_DEFAULT_TEXT_FEEDBACK"] = "Talk about your experience using details, tell us what could be improved or what new features should be implemented."
		end
	end

	--> português
	do
	--[
		local Loc = LibStub("AceLocale-3.0"):NewLocale ("DetailsErrorReport", "ptBR") 
		if (Loc) then
			Loc ["STRING_PLUGIN_NAME"] = "Relatorio de Erros"
			Loc ["STRING_TOOLTIP"] = "Encontrou um bug? reporte aqui"
			Loc ["STRING_REPORT"] = "Details Relatorio de Erros"
			Loc ["STRING_PROBLEM"] = "problema"
			Loc ["STRING_SUGESTION"] = "sugestao"
			Loc ["STRING_LUAERROR_DESC"] = "envia um relatorio sobre erros de lua que estao ocorrendo"
			Loc ["STRING_ACCURACY_DESC"] = "caso voce encontre problemas na quantidade de dano ou healing que esta mais baixo do que deveria ser"
			Loc ["STRING_NOTWORK_DESC"] = "qualquer coisa que voce clique e deveria efetuar uma funcao mas que nao esta"
			Loc ["STRING_OTHER_DESC"] = "outros problemas e por que nao, sugestoes, podem ser enviadas usando este assunto"
			Loc ["STRING_LUA_ERROR"] = "Erro de Lua"
			Loc ["STRING_ACCURACY_ERROR"] = "Precisao dos Dados"
			Loc ["STRING_NOTWORK_ERROR"] = "Algo Nao Funciona"
			Loc ["STRING_OTHER_ERROR"] = "Outro"
			Loc ["STRING_WELCOME_TEXT"] = "Detalhes esta apenas comecando a caminhar e muitos erros podem surgir, para que o erros chegem a nos mais rapidamente estaremos usando este plugin pelo menos na etapa Alfa do projeto."
			Loc ["STRING_SEND"] = "Enviar"
			Loc ["STRING_CANCELLED"] = "Cancelado."
			Loc ["STRING_EMPTY"] = "O campo do texto esta em branco."
			Loc ["STRING_TOOBIG"] = "Limite de 1024 caracteres alcancado."
			
			Loc ["STRING_FEEDBACK_DESC"] = "De sua opiniao sobre o Details!"
			Loc ["STRING_FEEDBACK"] = "Feedback"
			Loc ["STRING_DEFAULT_TEXT_FEEDBACK"] = ""
		end
		--]]
	end


--plugin object
	local ErrorReport = _G._detalhes:NewPluginObject ("Details_ErrorReport")
	tinsert (UISpecialFrames, "Details_ErrorReport")
	local Loc = LibStub ("AceLocale-3.0"):GetLocale ("DetailsErrorReport")
	
--plugin panel
	local BuildReportPanel = function()

		function ErrorReport:OnDetailsEvent (event, ...)
			if (event == "PLUGIN_DISABLED") then
				ErrorReport:HideToolbarIcon (ErrorReport.ToolbarButton)
				
			elseif (event == "PLUGIN_ENABLED") then
				ErrorReport:ShowToolbarIcon (ErrorReport.ToolbarButton)
				
			end
		end
	
		--> catch Details! main object
		local _detalhes = _G._detalhes
		local DetailsFrameWork = _detalhes.gump

		--> create the button to show on toolbar [1] function OnClick [2] texture [3] tooltip [4] width or 14 [5] height or 14 [6] frame name or nil
		function ErrorReport:OpenWindow()
			ErrorReport.Frame:SetPoint ("center", UIParent, "center")
			ErrorReport.Frame:Show()
		end
		ErrorReport.ToolbarButton = _detalhes.ToolBar:NewPluginToolbarButton (ErrorReport.OpenWindow, "Interface\\HELPFRAME\\HelpIcon-Bug", Loc ["STRING_PLUGIN_NAME"], Loc ["STRING_TOOLTIP"], 20, 20, "DETAILS_ERRORREPORT_BUTTON")
		--> setpoint anchors mod if needed
		ErrorReport.ToolbarButton.y = 0
		ErrorReport.ToolbarButton.x = 0
		
		ErrorReport:ShowToolbarIcon (ErrorReport.ToolbarButton)
		
		local mainFrame = ErrorReport.Frame
		mainFrame:SetWidth (400)
		mainFrame:SetHeight (400)

		--> build widgets
		
			--background
			DetailsFrameWork:NewPanel (mainFrame, _, "DetailsErrorReportBackground", "background", 400, 400)
			local bg = mainFrame.background
			bg:SetPoint()
			
			bg.close_with_right = true
			
			bg:SetHook ("OnHide", function()
				mainFrame:Hide()
			end)
			mainFrame:SetScript ("OnShow", function()
				bg:Show()
			end)
			
			--title
			DetailsFrameWork:NewLabel (bg, _, _, "titlelabel", Loc ["STRING_REPORT"], "GameFontHighlightSmall", 11)
			bg.titlelabel:SetPoint (10, -10)
			
			--welcome
			DetailsFrameWork:NewLabel (bg, _, _, "welcomelabel", Loc ["STRING_WELCOME_TEXT"], "GameFontHighlightSmall", 9)
			bg.welcomelabel:SetPoint (10, -25)
			
			local textArray = {Loc ["STRING_DEFAULT_TEXT_FEEDBACK"], Loc ["STRING_DEFAULT_TEXT_LUA"], Loc ["STRING_DEFAULT_TEXT_ACCURACY"], Loc ["STRING_DEFAULT_TEXT_NOTWORK"], Loc ["STRING_DEFAULT_TEXT_OTHER"]}
			
			--text field background
			DetailsFrameWork:NewPanel (bg, _, "DetailsErrorReportTextFieldBackground", "textfieldBackground", 390, 260)
			bg.textfieldBackground:SetPoint (5, -85)

			local lastValue = 1
			
			--text field
			DetailsFrameWork:NewTextEntry (bg, _, "DetailsErrorReportText", "textfield", 380, 260)
			bg.textfield:SetBackdrop (nil)
			bg.textfield:SetPoint (10, -90) -- topleft anchor and parent will be use in this case
			bg.textfield:SetFrameLevel (1, bg.textfieldBackground) -- +1 relative to other frame
			bg.textfield.text = Loc ["STRING_DEFAULT_TEXT_FEEDBACK"]
			bg.textfield.multiline = true
			bg.textfield.align = "left"
			
			bg.textfield:SetHook ("OnEditFocusGained", function() 
				if (bg.textfield.text == textArray [lastValue]) then
					bg.textfield.text = ""
				end
			end)
			
			bg.textfield:SetHook ("OnEditFocusLost", function()
				if (bg.textfield.text == "") then
					bg.textfield.text = textArray [lastValue]
				end
			end)
			
			--type dropdown
			local selected = function (self, _, index)
				if (bg.textfield.text == textArray [self.lastValue]) then
					bg.textfield.text = textArray [index]
				end
				self.lastValue = index
				lastValue = index
			end

			local options = {
				{onclick = selected, desc = Loc ["STRING_FEEDBACK_DESC"], value = 1, icon = "Interface\\ICONS\\INV_Misc_Note_05", label = Loc ["STRING_FEEDBACK"], color = "white", selected = true },
				{onclick = selected, desc = Loc ["STRING_LUAERROR_DESC"], value = 2, icon = "Interface\\ICONS\\INV_Pet_Cockroach", label = Loc ["STRING_LUA_ERROR"], color = "white" },
				{onclick = selected, desc = Loc ["STRING_ACCURACY_DESC"], value = 3, icon = "Interface\\ICONS\\Ability_Hunter_FocusedAim", label = Loc ["STRING_ACCURACY_ERROR"], color = "white" },
				{onclick = selected, desc = Loc ["STRING_NOTWORK_DESC"], value = 4, icon = "Interface\\ICONS\\INV_Misc_ScrewDriver_01", label = Loc ["STRING_NOTWORK_ERROR"], color = "white" },
				{onclick = selected, desc = Loc ["STRING_OTHER_DESC"], value = 5, icon = "Interface\\ICONS\\Achievement_Reputation_01", label = Loc ["STRING_OTHER_ERROR"], color = "white" },
			}
			local buildMenu = function()
				return options
			end
			DetailsFrameWork:NewDropDown (bg, _, "DetailsErrorReportType", "type", 250, 20, buildMenu, 1) -- func, default
			bg.type:SetPoint (10, -60)
			bg.type:SetFrameLevel (2, bg)
			bg.type.lastValue = 1
			
			local c = bg:CreateRightClickLabel ("medium")
			c:SetPoint ("bottomright", bg, "bottomright", -3, 1)
			
			local moreinfo = DetailsFrameWork:NewLabel (bg, _, "DetailsErrorReportMoreInfo", _, "feedback recipient: detailsaddonwow@gmail.com\n")
			moreinfo:SetPoint ("bottomright", bg, "bottomright", -3, 36)
			moreinfo.align = ">"
			moreinfo.valign = "^"

			--send button
			local sendFunc = function()
			
				if (string.len (bg.textfield.text) < 2) then
					print (Loc ["STRING_EMPTY"])
					return
				end
				
				if (string.len (bg.textfield.text) > 1024) then
					print (Loc ["STRING_TOOBIG"])
					return
				end
				
				if (bg.textfield.text == textArray [lastValue]) then
					print (Loc ["STRING_CANCELLED"])
					mainFrame:Hide()
					return
				end
			
				local subject = {
					"Feedback", "LuaError", "InstableAccuracy", "IsntWorking", "Other"
				}
			
				local url = "http://reporttodevs.hol.es/sendtodev.php?dev=detailsaddon&subject=" .. subject [bg.type.value] .. "&text=v" .. _detalhes.userversion .. "-" .. bg.textfield.text:gsub (" ", "%%20")

				ErrorReport:CopyPaste (url)
				mainFrame:Hide()
			end
			
			DetailsFrameWork:NewButton (bg, _, "DetailsErrorReportButton", "send", 100, 20, sendFunc, _, _, _, Loc ["STRING_SEND"])
			bg.send:InstallCustomTexture()
			bg.send:SetPoint (10, -370)
			
			
	end

--events
	function ErrorReport:OnEvent (_, event, ...)

		if (event == "ADDON_LOADED") then
			local AddonName = select (1, ...)
			if (AddonName == "Details_ErrorReport") then
				
				if (_G._detalhes) then
					
					--> create widgets
					BuildReportPanel (data)

					--> Install
					local install, saveddata = _G._detalhes:InstallPlugin ("TOOLBAR", Loc ["STRING_PLUGIN_NAME"], "Interface\\HELPFRAME\\HelpIcon-Bug", ErrorReport, "DETAILS_PLUGIN_REPORT_ERRORS", 1, "Details! Team", "v1.03")
					if (type (install) == "table" and install.error) then
						print (install.error)
					end
					
				end
			end
		end
	end