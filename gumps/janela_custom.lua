--> custom window

	local _detalhes = 		_G._detalhes
	local gump = 			_detalhes.gump
	local _
	
	local AceComm = LibStub ("AceComm-3.0")
	local AceSerializer = LibStub ("AceSerializer-3.0")
	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> local pointers

	
	local _cstr = string.format --lua local
	local _math_ceil = math.ceil --lua local
	local _math_floor = math.floor --lua local
	local _ipairs = ipairs --lua local
	local _pairs = pairs --lua local
	local _string_lower = string.lower --lua local
	local _table_sort = table.sort --lua local
	local _table_insert = table.insert --lua local
	local _unpack = unpack --lua local
	local _setmetatable = setmetatable --lua local

	local _GetSpellInfo = _detalhes.getspellinfo --api local
	local _CreateFrame = CreateFrame --api local
	local _GetTime = GetTime --api local
	local _GetCursorPosition = GetCursorPosition --api local
	local _GameTooltip = GameTooltip --api local
	local _UIParent = UIParent --api local
	local _GetScreenWidth = GetScreenWidth --api local
	local _GetScreenHeight = GetScreenHeight --api local
	local _IsAltKeyDown = IsAltKeyDown --api local
	local _IsShiftKeyDown = IsShiftKeyDown --api local
	local _IsControlKeyDown = IsControlKeyDown --api local

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> constants
	
	local atributos = _detalhes.atributos
	local sub_atributos = _detalhes.sub_atributos

	local CLASS_ICON_TCOORDS = _G.CLASS_ICON_TCOORDS

	local class_type_dano = _detalhes.atributos.dano
	local class_type_misc = _detalhes.atributos.misc
	
	local object_keys = {
		["name"] = true,
		["icon"] = true,
		["attribute"] = true,
		["spellid"] = true,
		["author"] = true,
		["desc"] = true,
		["source"] = true,
		["target"] = true,
		["script"] = true,
		["tooltip"] = true,
	}

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> create the window

	function _detalhes:CloseCustomDisplayWindow()
	
		--> cancel editing or creation
		if (DetailsCustomPanel.CodeEditing) then
			DetailsCustomPanel:CancelFunc()
		end
		if (DetailsCustomPanel.IsEditing) then
			DetailsCustomPanel:CancelFunc()
		end
		
		DetailsCustomPanel:Reset()
		DetailsCustomPanel:ClearFocus()
		
		--> hide the frame
		_G.DetailsCustomPanel:Hide()
	end

	function _detalhes:OpenCustomDisplayWindow()

		if (not _G.DetailsCustomPanel) then
	
			local GameCooltip = GameCooltip
	
			--> main frame
			local custom_window = _CreateFrame ("frame", "DetailsCustomPanel", UIParent)
			custom_window:SetPoint ("center", UIParent, "center")
			custom_window:SetSize (850, 370)
			custom_window:EnableMouse (true)
			custom_window:SetMovable (true)
			custom_window:SetScript ("OnMouseDown", function (self, button)
				if (button == "LeftButton") then
					if (not self.moving) then
						self.moving = true
						self:StartMoving()
					end
				elseif (button == "RightButton") then
					if (not self.moving) then
						_detalhes:CloseCustomDisplayWindow()
					end
				end
			end)
			custom_window:SetScript ("OnMouseUp", function (self)
				if (self.moving) then
					self.moving = false
					self:StopMovingOrSizing()
				end
			end)
			custom_window:SetScript ("OnShow", function()
				GameCooltip:Hide()
			end)
			
			tinsert (UISpecialFrames, "DetailsCustomPanel")
			
			--> background texture
			custom_window.background = custom_window:CreateTexture (nil, "border")
			custom_window.background:SetTexture ([[Interface\AddOns\Details\images\custom_bg]])
			custom_window.background:SetPoint ("topleft", custom_window, "topleft")
			--custom_window.background:Hide()
			
			local bigdog = gump:NewImage (custom_window, [[Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human]], 180*0.7, 200*0.7, "overlay", {0, 1, 0, 1}, "backgroundBigDog", "$parentBackgroundBigDog")
			bigdog:SetPoint ("bottomleft", custom_window, "bottomleft", 15, 9)
			bigdog:SetAlpha (0.5)

			--> close button
			custom_window.close = _CreateFrame ("button", nil, custom_window, "UIPanelCloseButton")
			custom_window.close:SetSize (32, 32)
			custom_window.close:SetPoint ("topright", custom_window, "topright", 5, -8)
			custom_window.close:SetFrameLevel (custom_window:GetFrameLevel()+2)
			custom_window.close:SetScript ("OnClick", function() 
				_detalhes:CloseCustomDisplayWindow()
			end)
			custom_window.close:SetScript ("OnHide", function()
				_detalhes:CloseCustomDisplayWindow()
			end)

			--> title
			custom_window.title = gump:NewLabel (custom_window, nil, nil, nil, "Custom Display", "GameFontHighlightLeft", 12, {227/255, 186/255, 4/255})
			custom_window.title:SetPoint ("center", custom_window, "center")
			custom_window.title:SetPoint ("top", custom_window, "top", 0, -18)
			
			--> icon
			custom_window.icon = custom_window:CreateTexture (nil, "background")
			custom_window.icon:SetPoint ("topleft", custom_window, "topleft", 4, 0)
			custom_window.icon:SetSize (64, 64)
			custom_window.icon:SetDrawLayer ("background", 2)
			custom_window.icon:SetTexture ([[Interface\AddOns\Details\images\classes_plus]])
			custom_window.icon:SetTexCoord (0, 0.25, 0.25, 0.5)

			--> menu background
			custom_window.menubackground = custom_window:CreateTexture (nil, "background")
			custom_window.menubackground:SetTexture ([[Interface\DialogFrame\UI-DialogBox-Background-Dark]])
			custom_window.menubackground:SetPoint ("topleft", custom_window, "topleft", 19, -34)
			custom_window.menubackground:SetSize (151, 326)
			custom_window.menubackground:SetDrawLayer ("background", 1)
			custom_window.menubackground:SetAlpha (0.75)
			
			--> select panel background
			custom_window.selectbackground = custom_window:CreateTexture (nil, "background")
			custom_window.selectbackground:SetTexture ([[Interface\DialogFrame\UI-DialogBox-Background-Dark]])
			custom_window.selectbackground:SetPoint ("topleft", custom_window, "topleft", 175, -36)
			custom_window.selectbackground:SetSize (666, 324)
			custom_window.selectbackground:SetDrawLayer ("background", 1)
			custom_window.selectbackground:SetAlpha (0.75)
			
			DetailsCustomPanel.BoxType = 1
			DetailsCustomPanel.IsEditing = false
			DetailsCustomPanel.IsImporting = false
			DetailsCustomPanel.CodeEditing = false
			DetailsCustomPanel.current_attribute = "damagedone"
			
			DetailsCustomPanel.code1_default = [[
							--get the parameters passed
							local Combat, CustomContainer, Instance = ...
							--declade the values to return
							local total, top, amount = 0, 0, 0
							
							--do the loop
								--CustomContainer:AddValue (actor, actor.value)
							--loop end
							
							--if not managed inside the loop, get the values of total, top and amount
							total, top = Container:GetTotalAndHighestValue()
							amount = Container:GetNumActors()
							
							--return the values
							return total, top, amount
						]]
			DetailsCustomPanel.code1 = DetailsCustomPanel.code1_default
			
			DetailsCustomPanel.code2_default = [[
							--get the parameters passed
							local actor, combat, instance = ...
							
							--get the cooltip object (we dont use the convencional GameTooltip here)
							local GameCooltip = GameCooltip
							
							--Cooltip code
						]]
			DetailsCustomPanel.code2 = DetailsCustomPanel.code2_default
			
			DetailsCustomPanel.code3_default = [[
							local value, top, total, combat, instance = ...
							return math.floor (value)
						]]
			DetailsCustomPanel.code3 = DetailsCustomPanel.code3_default
			
			DetailsCustomPanel.code4_default = [[
							local value, top, total, combat, instance = ...
							return string.format ("%.1f", value/total*100)
						]]
			DetailsCustomPanel.code4 = DetailsCustomPanel.code4_default
			
			function DetailsCustomPanel:ClearFocus()
				custom_window.desc_field:ClearFocus()
				custom_window.name_field:ClearFocus()
				custom_window.author_field:ClearFocus()
			end
			
			function DetailsCustomPanel:Reset()
				self.name_field:SetText ("")
				self.icon_image:SetTexture ([[Interface\ICONS\TEMP]])
				self.desc_field:SetText ("")
				
				self.author_field:SetText (UnitName ("player") .. "-" .. GetRealmName())
				self.author_field:Enable()
				
				self.source_dropdown:Select (1, true)
				self.source_field:SetText ("")
				
				self.target_dropdown:Select (1, true)
				self.target_field:SetText ("")
				
				self.spellid_entry:SetText ("")
				
				DetailsCustomPanel.code1 = DetailsCustomPanel.code1_default
				DetailsCustomPanel.code2 = DetailsCustomPanel.code2_default
				DetailsCustomPanel.code3 = DetailsCustomPanel.code3_default
				DetailsCustomPanel.code4 = DetailsCustomPanel.code4_default
				
				DetailsCustomPanel.current_attribute = "damagedone"
				DetailsCustomPanelAttributeMenu1:Click()
				
				DetailsCustomPanel:ClearFocus()
			end
			
			function DetailsCustomPanel:RemoveDisplay (custom_object, index)
				table.remove (_detalhes.custom, index)
				
				for _, instance in _ipairs (_detalhes.tabela_instancias) do 
					if (instance.atributo == 5 and instance.sub_atributo == index) then 
						instance:ResetAttribute()
					elseif (instance.atributo == 5 and instance.sub_atributo > index) then
						instance.sub_atributo = instance.sub_atributo - 1
						instance.sub_atributo_last [5] = 1
					else
						instance.sub_atributo_last [5] = 1
					end
				end
				
				_detalhes.switch:OnRemoveCustom (index)
				_detalhes:ResetCustomFunctionsCache()
			end
			
			function DetailsCustomPanel:StartEdit (custom_object, import)
				
				DetailsCustomPanel:Reset()
				DetailsCustomPanel:ClearFocus()
				
				DetailsCustomPanel.IsEditing = custom_object
				DetailsCustomPanel.IsImporting = import
				
				self.name_field:SetText (custom_object:GetName())
				self.desc_field:SetText (custom_object:GetDesc())
				self.icon_image:SetTexture (custom_object:GetIcon())
				
				self.author_field:SetText (custom_object:GetAuthor())
				self.author_field:Disable()
				
				if (custom_object:IsScripted()) then
				
					custom_window.script_button_attribute:Click()
					
					DetailsCustomPanel.code1 = custom_object:GetScript()
					DetailsCustomPanel.code2 = custom_object:GetScriptToolip()
					DetailsCustomPanel.code3 = custom_object:GetScriptTotal() or DetailsCustomPanel.code3_default
					DetailsCustomPanel.code4 = custom_object:GetScriptPercent() or DetailsCustomPanel.code4_default
					
				else
				
					local attribute = custom_object:GetAttribute()
					if (attribute == "damagedone") then
						DetailsCustomPanelAttributeMenu1:Click()
					elseif (attribute == "healdone") then
						DetailsCustomPanelAttributeMenu2:Click()
					end
				
					local source = custom_object:GetSource()
					if (source == "[all]") then
						self.source_dropdown:Select (1, true)
						self.source_field:SetText ("")
						self.source_field:Disable()
					elseif (source == "[raid]") then
						self.source_dropdown:Select (2, true)
						self.source_field:SetText ("")
						self.source_field:Disable()
					elseif (source == "[player]") then
						self.source_dropdown:Select (3, true)
						self.source_field:SetText ("")
						self.source_field:Disable()
					else
						self.source_dropdown:Select (4, true)
						self.source_field:SetText (source)
						self.source_field:Enable()
					end
					
					local target = custom_object:GetTarget()
					
					if (not target) then
						self.target_dropdown:Select (5, true)
						self.target_field:SetText ("")
						self.target_field:Disable()
					elseif (target == "[all]") then
						self.target_dropdown:Select (1, true)
						self.target_field:SetText ("")
						self.target_field:Disable()
					elseif (target == "[raid]") then
						self.target_dropdown:Select (2, true)
						self.target_field:SetText ("")
						self.target_field:Disable()
					elseif (target == "[player]") then
						self.target_dropdown:Select (3, true)
						self.target_field:SetText ("")
						self.target_field:Disable()
					else
						self.target_dropdown:Select (4, true)
						self.target_field:SetText (target)
						self.target_field:Enable()
					end
					
					self.spellid_entry:SetText (custom_object:GetSpellId() or "")
					
				end
				
				if (import) then
					DetailsCustomPanel:SetAcceptButtonText (Loc ["STRING_CUSTOM_IMPORT_BUTTON"])
				else
					DetailsCustomPanel:SetAcceptButtonText (Loc ["STRING_CUSTOM_SAVE"])
				end
			end
			
			function DetailsCustomPanel:CreateNewCustom()
			
				local name = self.name_field:GetText()
				DetailsCustomPanel:ClearFocus()
				_detalhes.MicroButtonAlert:Hide()
				
				if (string.len (name) < 5) then
					return false, _detalhes:Msg (Loc ["STRING_CUSTOM_SHORTNAME"])
				elseif (string.len (name) > 32) then
					return false, _detalhes:Msg (Loc ["STRING_CUSTOM_LONGNAME"])
				end
				
				_detalhes:ResetCustomFunctionsCache()

				local icon = self.icon_image:GetTexture()
				local desc = self.desc_field:GetText()
				local author = self.author_field:GetText()
				
				if (DetailsCustomPanel.BoxType == 1) then
					local source = self.source_dropdown:GetValue()
					local target = self.target_dropdown:GetValue()
					local spellid = self.spellid_entry:GetText()
					
					if (not source) then
						source = self.source_field:GetText()
					end
					
					if (not target) then
						target = self.target_field:GetText()
					elseif (target == "[none]") then
						target = false
					end
					
					if (spellid == "") then
						spellid = false
					end

					if (DetailsCustomPanel.IsEditing) then
						local object = DetailsCustomPanel.IsEditing
						object.name = name
						object.icon = icon
						object.desc = desc
						object.author = author
						object.attribute = DetailsCustomPanel.current_attribute
						object.source = source
						object.target = target
						object.spellid = tonumber (spellid)
						object.script = false
						object.tooltip = false

						if (DetailsCustomPanel.IsImporting) then
							_detalhes:Msg (Loc ["STRING_CUSTOM_IMPORTED"])
						else
							_detalhes:Msg (Loc ["STRING_CUSTOM_SAVED"])
						end
						
						if (DetailsCustomPanel.IsImporting) then
							tinsert (_detalhes.custom, object)
						end
						
						DetailsCustomPanel.IsEditing = false
						DetailsCustomPanel.IsImporting = false
						self.author_field:Enable()
						return true
					else
						local new_custom_object = {
							["name"] = name,
							["icon"] = icon,
							["desc"] = desc,
							["author"] = author,
							["attribute"] = DetailsCustomPanel.current_attribute,
							["source"] = source,
							["target"] = target,
							["spellid"] = tonumber (spellid),
							["script"] = false,
							["tooltip"] = false,
						}

						tinsert (_detalhes.custom, new_custom_object)
						_setmetatable (new_custom_object, _detalhes.atributo_custom)
						new_custom_object.__index = _detalhes.atributo_custom
						_detalhes:Msg (Loc ["STRING_CUSTOM_CREATED"])
					end
					
					DetailsCustomPanel:Reset()
					
				elseif (DetailsCustomPanel.BoxType == 2) then
					
					local main_code = DetailsCustomPanel.code1
					local tooltip_code = DetailsCustomPanel.code2
					local total_code = DetailsCustomPanel.code3
					local percent_code = DetailsCustomPanel.code4
					
					if (DetailsCustomPanel.IsEditing) then
						local object = DetailsCustomPanel.IsEditing
						object.name = name
						object.icon = icon
						object.desc = desc
						object.author = author
						object.attribute = false
						object.source = false
						object.target = false
						object.spellid = false
						object.script = main_code
						object.tooltip = tooltip_code
						
						if (total_code ~= DetailsCustomPanel.code3_default) then
							object.total_script = total_code
						else
							object.total_script = false
						end
						
						if (percent_code ~= DetailsCustomPanel.code4_default) then
							object.percent_script = percent_code
						else
							object.percent_script = false
						end
						
						if (DetailsCustomPanel.IsImporting) then
							_detalhes:Msg (Loc ["STRING_CUSTOM_IMPORTED"])
						else
							_detalhes:Msg (Loc ["STRING_CUSTOM_SAVED"])
						end
						
						if (DetailsCustomPanel.IsImporting) then
							tinsert (_detalhes.custom, object)
						end
						
						DetailsCustomPanel.IsEditing = false
						DetailsCustomPanel.IsImporting = false
						self.author_field:Enable()
						return true
					else
						local new_custom_object = {
							["name"] = name,
							["icon"] = icon,
							["desc"] = desc,
							["author"] = author,
							["attribute"] = false,
							["source"] = false,
							["target"] = false,
							["spellid"] = false,
							["script"] = main_code,
							["tooltip"] = tooltip_code,
						}
						
						local total_code = DetailsCustomPanel.code3
						local percent_code = DetailsCustomPanel.code4
						
						if (total_code ~= DetailsCustomPanel.code3_default) then
							new_custom_object.total_script = total_code
						else
							new_custom_object.total_script = false
						end
						
						if (percent_code ~= DetailsCustomPanel.code4_default) then
							new_custom_object.percent_script = percent_code
						else
							new_custom_object.percent_script = false
						end
						
						tinsert (_detalhes.custom, new_custom_object)
						_setmetatable (new_custom_object, _detalhes.atributo_custom)
						new_custom_object.__index = _detalhes.atributo_custom
						_detalhes:Msg (Loc ["STRING_CUSTOM_CREATED"])
					end
					
					DetailsCustomPanel:Reset()
					
				end

			end
			
			function DetailsCustomPanel:AcceptFunc()
				
				_detalhes.MicroButtonAlert:Hide()
				
				if (DetailsCustomPanel.CodeEditing) then
					--> close the edit box saving the text
					if (DetailsCustomPanel.CodeEditing == 1) then
						DetailsCustomPanel.code1 = custom_window.codeeditor:GetText()
					elseif (DetailsCustomPanel.CodeEditing == 2) then
						DetailsCustomPanel.code2 = custom_window.codeeditor:GetText()
					elseif (DetailsCustomPanel.CodeEditing == 3) then
						DetailsCustomPanel.code3 = custom_window.codeeditor:GetText()
					elseif (DetailsCustomPanel.CodeEditing == 4) then
						DetailsCustomPanel.code4 = custom_window.codeeditor:GetText()
					end
					
					DetailsCustomPanel.CodeEditing = false
					
					if (DetailsCustomPanel.IsImporting) then
						DetailsCustomPanel:SetAcceptButtonText (Loc ["STRING_CUSTOM_IMPORT_BUTTON"])
					elseif (DetailsCustomPanel.IsEditing) then
						DetailsCustomPanel:SetAcceptButtonText (Loc ["STRING_CUSTOM_SAVE"])
					else
						DetailsCustomPanel:SetAcceptButtonText (Loc ["STRING_CUSTOM_CREATE"])
					end
					custom_window.codeeditor:Hide()
				
				elseif (DetailsCustomPanel.IsEditing) then
				
					local succesful_edit = DetailsCustomPanel:CreateNewCustom()
					if (succesful_edit) then
						DetailsCustomPanel.IsEditing = false
						DetailsCustomPanel.IsImporting = false
						DetailsCustomPanel:SetAcceptButtonText (Loc ["STRING_CUSTOM_CREATE"])
						DetailsCustomPanel:Reset()
					end
				else
					DetailsCustomPanel:CreateNewCustom()
				end
				
			end
			
			function DetailsCustomPanel:CancelFunc()
				
				DetailsCustomPanel:ClearFocus()
				_detalhes.MicroButtonAlert:Hide()
				
				if (DetailsCustomPanel.CodeEditing) then
					--> close the edit box without save
					custom_window.codeeditor:Hide()
					DetailsCustomPanel.CodeEditing = false
					
					if (DetailsCustomPanel.IsImporting) then
						DetailsCustomPanel:SetAcceptButtonText (Loc ["STRING_CUSTOM_IMPORT_BUTTON"])
					elseif (DetailsCustomPanel.IsEditing) then
						DetailsCustomPanel:SetAcceptButtonText (Loc ["STRING_CUSTOM_SAVE"])
					else
						DetailsCustomPanel:SetAcceptButtonText (Loc ["STRING_CUSTOM_CREATE"])
					end
					
				elseif (DetailsCustomPanel.IsEditing) then
					DetailsCustomPanel.IsEditing = false
					DetailsCustomPanel.IsImporting = false
					DetailsCustomPanel:SetAcceptButtonText (Loc ["STRING_CUSTOM_CREATE"])
					DetailsCustomPanel:Reset()
					
				else
					_detalhes:CloseCustomDisplayWindow()
				end
				
			end
			
			function DetailsCustomPanel:SetAcceptButtonText (text)
				custom_window.box0.acceptbutton:SetText (text)
			end

			function select_attribute (self)
			
				if (not self.attribute_table) then
					return
				end
				
				DetailsCustomPanel:ClearFocus()
				
				custom_window.selected_left:SetPoint ("topleft", self, "topleft")
				custom_window.selected_right:SetPoint ("topright", self, "topright")
				
				DetailsCustomPanel.current_attribute = self.attribute_table.attribute
			
				if (not self.attribute_table.attribute) then
					--is scripted
					DetailsCustomPanel.BoxType = 2
					custom_window.box1:Hide()
					custom_window.box2:Show()

				else
					--no scripted
					--> check if is editing the code
					if (DetailsCustomPanel.CodeEditing) then
						DetailsCustomPanel.AcceptFunc()
					end
					
					DetailsCustomPanel.BoxType = 1
					custom_window.box1:Show()
					custom_window.box2:Hide()
					custom_window.codeeditor:Hide()
				end
			end

			function DetailsCustomPanel.StartEditCode (_, _, code)
				if (code == 1) then --> edit main code
				
					custom_window.codeeditor:SetText (DetailsCustomPanel.code1)
					
				elseif (code == 2) then --> edit tooltip code
				
					custom_window.codeeditor:SetText (DetailsCustomPanel.code2)
				
				elseif (code == 3) then --> edit total code
				
					custom_window.codeeditor:SetText (DetailsCustomPanel.code3)
					
				elseif (code == 4) then --> edit percent code
				
					custom_window.codeeditor:SetText (DetailsCustomPanel.code4)
				
				end
				
				custom_window.codeeditor:Show()
				DetailsCustomPanel.CodeEditing = code
				DetailsCustomPanel:SetAcceptButtonText (Loc ["STRING_CUSTOM_DONE"])
			end
			

			
			--> left menu
			custom_window.menu = {}
			local menu_start = -50
			local menu_up_frame = _CreateFrame ("frame", nil, custom_window)
			menu_up_frame:SetFrameLevel (custom_window:GetFrameLevel()+2)
			
			local onenter = function (self)
				self.icontexture:SetVertexColor (1, 1, 1, 1)
			end
			local onleave = function (self)
				self.icontexture:SetVertexColor (.9, .9, .9, 1)
			end
			
			function custom_window:CreateMenuButton (label, icon, clickfunc, param1, param2, tooltip, name, coords)
			
				local index = #custom_window.menu+1
				
				local circle = menu_up_frame:CreateTexture (nil, "overlay")
				circle:SetSize (128*0.5, 82*0.5)
				circle:SetPoint ("topleft", self, "topleft", 13, ((82*0.5)*index*-1) + menu_start)
				circle:SetTexture ("Interface\\Glues\\CHARACTERCREATE\\AlternateForm")
				circle:SetTexCoord (0, 1, 0, 0.3203125)
				circle:SetDrawLayer ("overlay", 4)
				
				local texture = menu_up_frame:CreateTexture (nil, "overlay")
				texture:SetSize (128*0.23, 82*0.32)
				texture:SetTexture (icon)
				--texture:SetDesaturated (true)
				texture:SetVertexColor (.9, .9, .9, 1)
				if (coords) then
					texture:SetTexCoord (unpack (coords))
				else
					texture:SetTexCoord (5/64, 60/64, 4/64, 62/64)
				end
				texture:SetPoint ("topleft", circle, "topleft", 5, -9)
				texture:SetDrawLayer ("overlay", 3)
				
				local fillgap = menu_up_frame:CreateTexture (nil, "overlay")
				fillgap:SetDrawLayer ("overlay", 2)
				fillgap:SetTexture (0, 0, 0, 1)
				fillgap:SetSize (2, 10)
				fillgap:SetPoint ("left", texture, "right")
				
				local button = gump:NewButton (self, nil, "$parent" .. name, nil, 110, 20, clickfunc, param1, param2, nil, label)
				button:SetPoint ("topleft", circle, "topright", -32, -14)
				button:InstallCustomTexture()
				button:SetHook ("OnEnter", onenter)
				button:SetHook ("OnLeave", onleave)
				button.widget.icontexture = texture
				button.tooltip = tooltip

				custom_window.menu [index] = {circle = circle, icon = texture, button = button}
			end
			
			local build_menu = function (self, button, func, param2)
				GameCooltip:Reset()
				
				for index, custom_object in _ipairs (_detalhes.custom) do
					GameCooltip:AddLine (custom_object:GetName())
					GameCooltip:AddIcon (custom_object:GetIcon())
					GameCooltip:AddMenu (1, func, custom_object, index, true)
				end
				
				GameCooltip:SetOption ("ButtonsYMod", -2)
				GameCooltip:SetOption ("YSpacingMod", 0)
				GameCooltip:SetOption ("TextHeightMod", 0)
				GameCooltip:SetOption ("IgnoreButtonAutoHeight", false)
				GameCooltip:SetWallpaper (1, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0, 0.64453125}, {1, 1, 1, 0.1}, true)
				
				GameCooltip:SetBackdrop (1, _detalhes.tooltip_backdrop, nil, _detalhes.tooltip_border_color)
				GameCooltip:SetBackdrop (2, _detalhes.tooltip_backdrop, nil, _detalhes.tooltip_border_color)
				
				GameCooltip:SetType ("menu")
				GameCooltip:SetHost (self, "left", "right", -7, 0)
				GameCooltip:Show()
			end
			
			--> edit button
			local start_edit = function (_, _, custom_object, index)
				GameCooltip:Hide()
				DetailsCustomPanel:StartEdit (custom_object)
			end
			custom_window:CreateMenuButton (Loc ["STRING_CUSTOM_EDIT"], "Interface\\ICONS\\INV_Inscription_RunescrollOfFortitude_Red", build_menu, start_edit, nil, nil, "Edit", {0.07, 0.93, 0.07, 0.93}) --> localize
			
			--> remove button
			local remove_display = function (_, _, custom_object, index)
				GameCooltip:Hide()
				DetailsCustomPanel:RemoveDisplay (custom_object, index)
			end
			custom_window:CreateMenuButton (Loc ["STRING_CUSTOM_REMOVE"], "Interface\\ICONS\\Spell_BrokenHeart", build_menu, remove_display, nil, nil, "Remove", {1, 0, 0, 1}) --> localize
			
			--> export button
			local export_display = function (_, _, custom_object, index)
				GameCooltip:Hide()

				local export_object = {}
				
				for key, value in pairs (custom_object) do
					if (object_keys [key]) then
						if (type (value) == "table") then
							export_object [key] = table_deepcopy (value)
						else
							export_object [key] = value
						end
					end
				end
				
				local serialized_table = _detalhes:Serialize (export_object)
				--local zip = LibStub:GetLibrary ("LibCompress"):CompressHuffman (serialized_table)
				--local encoded = _detalhes._encode:Encode (zip)
				local encoded = _detalhes._encode:Encode (serialized_table)
				
				if (not custom_window.ExportBox) then
					local editbox = _detalhes.gump:NewTextEntry (custom_window, nil, "$parentExportBox", "ExportBox", 842, 20)
					editbox:SetPoint ("topleft", DetailsCustomPanel, "bottomleft", 10, 0)
					editbox:SetPoint ("topright", DetailsCustomPanel, "bottomright")
					editbox:SetAutoFocus (false)
					editbox:SetHook ("OnEditFocusLost", function() 
						editbox:Hide()
					end)
					editbox:SetHook ("OnChar", function() 
						editbox:Hide()
					end)
				end
				
				if (custom_window.ImportBox) then
					custom_window.ImportBox:Hide()
					custom_window.exportLabel:Hide()
					custom_window.ImportConfirm:Hide()
				end
				
				custom_window.ExportBox:Show()
				custom_window.ExportBox:SetText (encoded)
				custom_window.ExportBox:HighlightText()
				custom_window.ExportBox:SetFocus()
				
			end
			custom_window:CreateMenuButton (Loc ["STRING_CUSTOM_EXPORT"], "Interface\\ICONS\\INV_Misc_Gift_01", build_menu, export_display, nil, nil, "Export", {0.00, 0.9, 0.07, 0.93}) --> localize

			--> import buttonRaceChange
			local import_display = function (_, _, custom_object, index)
				GameCooltip:Hide()
				
				if (not custom_window.ImportBox) then
				
					local export_string = gump:NewLabel (custom_window, custom_window, "$parenImportLabel", "exportLabel", Loc ["STRING_CUSTOM_PASTE"], "GameFontNormal")
					export_string:SetPoint ("topleft", DetailsCustomPanel, "bottomleft", 10, -5)
				
					local editbox = _detalhes.gump:NewTextEntry (custom_window, nil, "$parentImportBox", "ImportBox", 772 - export_string.width - 2, 20)
					editbox:SetPoint ("left", export_string, "right", 2, 0)
					editbox:SetAutoFocus (false)
					
					local import = function()
						local text = editbox:GetText()
						
						local decode = _detalhes._encode:Decode (text)
						--local unzip = LibStub:GetLibrary ("LibCompress"):DecompressHuffman (decode)
						--local deserialized_object = select (2, _detalhes:Deserialize (unzip))
						
						if (type (decode) ~= "string") then
							_detalhes:Msg (Loc ["STRING_CUSTOM_IMPORT_ERROR"])
							return
						end
						
						local deserialized_object = select (2, _detalhes:Deserialize (decode))

						if (DetailsCustomPanel.CodeEditing) then
							DetailsCustomPanel:CancelFunc()
						end

						if (type (deserialized_object) == "string") then
							_detalhes:Msg (Loc ["STRING_CUSTOM_IMPORT_ERROR"])
							return
						end
						
						setmetatable (deserialized_object, _detalhes.atributo_custom)
						deserialized_object.__index = _detalhes.atributo_custom
						
						_detalhes.MicroButtonAlert.Text:SetText (Loc ["STRING_CUSTOM_IMPORT_ALERT"])
						_detalhes.MicroButtonAlert:SetPoint ("bottom", custom_window.box0.acceptbutton.widget, "top", 0, 20)
						_detalhes.MicroButtonAlert:SetHeight (200)
						_detalhes.MicroButtonAlert:Show()
						
						DetailsCustomPanel:StartEdit (deserialized_object, true)
						
						custom_window.ImportBox:ClearFocus()
						custom_window.ImportBox:Hide()
						custom_window.exportLabel:Hide()
						custom_window.ImportConfirm:Hide()
					end
					
					local okey_button = gump:NewButton (custom_window, nil, "$parentImportConfirm", "ImportConfirm", 65, 18, import, nil, nil, nil, Loc ["STRING_CUSTOM_IMPORT_BUTTON"])
					okey_button:InstallCustomTexture()
					okey_button:SetPoint ("left", editbox, "right", 2, 0)
				end
				
				if (custom_window.ExportBox) then
					custom_window.ExportBox:Hide()
				end
				
				custom_window.ImportBox:SetText ("")
				custom_window.ImportBox:Show()
				custom_window.exportLabel:Show()
				custom_window.ImportConfirm:Show()
				custom_window.ImportBox:SetFocus()
				
			end
			custom_window:CreateMenuButton (Loc ["STRING_CUSTOM_IMPORT"], "Interface\\ICONS\\INV_MISC_NOTE_02", import_display, nil, nil, nil, "Import", {0.00, 0.9, 0.07, 0.93}) --> localize
			
			local box_types = {
				{}, --normal
				{}, --custom script
			}
			
			local attributes = {
				{icon = [[Interface\ICONS\Spell_Fire_Fireball02]], label = Loc ["STRING_CUSTOM_ATTRIBUTE_DAMAGE"], box = 1, attribute = "damagedone", boxtype = 1},
				{icon = [[Interface\ICONS\SPELL_NATURE_HEALINGTOUCH]], label = Loc ["STRING_CUSTOM_ATTRIBUTE_HEAL"], box = 1, attribute = "healdone", boxtype = 1},
				{icon = [[Interface\ICONS\INV_Inscription_Scroll]], label = Loc ["STRING_CUSTOM_ATTRIBUTE_SCRIPT"], box = 2, attribute = false, boxtype = 2},
				
				--{icon = [[Interface\ICONS\INV_Inscription_Scroll]], label = "Custom Script", box = 2, attribute = false, boxtype = 2},
				--{icon = [[Interface\ICONS\INV_Inscription_Scroll]], label = "Custom Script", box = 2, attribute = false, boxtype = 2},
				--{icon = [[Interface\ICONS\INV_Inscription_Scroll]], label = "Custom Script", box = 2, attribute = false, boxtype = 2},
				--{icon = [[Interface\ICONS\INV_Inscription_Scroll]], label = "Custom Script", box = 2, attribute = false, boxtype = 2},
				--{icon = [[Interface\ICONS\INV_Inscription_Scroll]], label = "Custom Script", box = 2, attribute = false, boxtype = 2},
				--{icon = [[Interface\ICONS\INV_Inscription_Scroll]], label = "Custom Script", box = 2, attribute = false, boxtype = 2},
				--{icon = [[Interface\ICONS\INV_Inscription_Scroll]], label = "Custom Script", box = 2, attribute = false, boxtype = 2},
				--{icon = [[Interface\ICONS\INV_Inscription_Scroll]], label = "Custom Script", box = 2, attribute = false, boxtype = 2},
				--{icon = [[Interface\ICONS\INV_Inscription_Scroll]], label = "Custom Script", box = 2, attribute = false, boxtype = 2},
			}

			--> create box
			local attribute_box = _CreateFrame ("frame", nil, custom_window)
			attribute_box:SetPoint ("topleft", custom_window, "topleft", 200, -60)
			attribute_box:SetSize (180, 260)
			--attribute_box:SetBackdrop ({
			--	bgFile = "Interface\\AddOns\\Details\\images\\background", 
			--	tile = true, tileSize = 16})
			--attribute_box:SetBackdropColor (1, 1, 1, 1)
			
			local button_onenter = function (self)
				self:SetBackdropColor (.3, .3, .3, .3)
				self.icon:SetBlendMode ("ADD")
			end
			local button_onleave = function (self)
				self:SetBackdropColor (0, 0, 0, .2)
				self.icon:SetBlendMode ("BLEND")
			end

			--960 1020 68 101
			
			local selected_left = attribute_box:CreateTexture (nil, "overlay")
			selected_left:SetTexture ([[Interface\Store\Store-Main]])
			selected_left:SetSize (50, 20)
			selected_left:SetVertexColor (1, .8, 0, 1)
			selected_left:SetTexCoord (960/1024, 1020/1024, 68/1024, 101/1024)
			custom_window.selected_left = selected_left
			
			local selected_right = attribute_box:CreateTexture (nil, "overlay")
			selected_right:SetTexture ([[Interface\Store\Store-Main]])
			selected_right:SetSize (31, 20)
			selected_right:SetVertexColor (1, .8, 0, 1)
			selected_right:SetTexCoord (270/1024, 311/1024, 873/1024, 906/1024)
			custom_window.selected_right = selected_right
			
			local selected_center = attribute_box:CreateTexture (nil, "overlay")
			selected_center:SetTexture ([[Interface\Store\Store-Main]])
			selected_center:SetSize (49, 20)
			selected_center:SetVertexColor (1, .8, 0, 1)
			selected_center:SetTexCoord (956/1024, 1004/1024, 164/1024, 197/1024)
			
			selected_center:SetPoint ("left", selected_left, "right")
			selected_center:SetPoint ("right", selected_right, "left")
			
			--selected_center:SetHorizTile (true)
			--selected_center:SetVertTile (true)
			
			local p = 0.0625 --> 32/512
			
			for i = 1, 10 do
			
				if (attributes [i]) then
			
				local button = _CreateFrame ("button", "DetailsCustomPanelAttributeMenu" .. i, attribute_box)
				button:SetPoint ("topleft", attribute_box, "topleft", 2, ((i-1)*23*-1) + (-26))
				button:SetPoint ("topright", attribute_box, "topright", 2, ((i-1)*23*-1) + (-26))
				button:SetHeight (20)
				
				button:SetBackdrop ({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tile = true, tileSize = 16})
				button:SetBackdropColor (0, 0, 0, .2)
				
				button:SetScript ("OnEnter", button_onenter)
				button:SetScript ("OnLeave", button_onleave)
				
				button.attribute_table = attributes [i]
				
				if (attributes [i] and not attributes [i].attribute) then
					custom_window.script_button_attribute = button
				end
				
				button:SetScript ("OnClick", select_attribute)
				
				button.icon = button:CreateTexture (nil, "overlay")
				button.icon:SetPoint ("left", button, "left", 6, 0)
				button.icon:SetSize (22, 22)
				button.icon:SetTexture ([[Interface\AddOns\Details\images\custom_icones]])
				button.icon:SetTexCoord (p*(i-1), p*(i), 0, 1)
				
				button.text = button:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
				button.text:SetPoint ("left", button.icon, "right", 4, 0)
				button.text:SetText (attributes [i] and attributes [i].label or "")
				button.text:SetTextColor (.9, .9, .9, 1)
				
				end
			end
			
			--> create box 0, holds the name, author, desc and icon
			local box0 = _CreateFrame ("frame", "DetailsCustomPanelBox0", custom_window)
			custom_window.box0 = box0
			box0:SetSize (450, 360)
			--box0:SetBackdrop ({
			--	bgFile = "Interface\\AddOns\\Details\\images\\background", 
			--	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
			--	tile = true, tileSize = 16, edgeSize = 12})
			--box0:SetBackdropColor (0, 0, 0, .5)
			box0:SetPoint ("topleft", attribute_box, "topright", 26, 10)
			
			--name
				local name_label = gump:NewLabel (box0, box0, "$parenNameLabel", "name", Loc ["STRING_CUSTOM_NAME"], "GameFontHighlightLeft") --> localize-me
				name_label:SetPoint ("topleft", box0, "topleft", 10, -20)
				
				local name_field = gump:NewTextEntry (box0, nil, "$parentNameEntry", "nameentry", 200, 20)
				name_field:SetPoint ("left", name_label, "left", 62, 0)
				name_field.tooltip = Loc ["STRING_CUSTOM_NAME_DESC"]
				custom_window.name_field = name_field
				
			--author
				local author_label = gump:NewLabel (box0, box0, "$parenAuthorLabel", "author", Loc ["STRING_CUSTOM_AUTHOR"], "GameFontHighlightLeft") --> localize-me
				author_label:SetPoint ("topleft", name_label, "bottomleft", 0, -12)
				
				local author_field = gump:NewTextEntry (box0, nil, "$parentAuthorEntry", "authorentry", 200, 20)
				author_field:SetPoint ("left", author_label, "left", 62, 0)
				author_field.tooltip = Loc ["STRING_CUSTOM_AUTHOR_DESC"]
				author_field:SetText (UnitName ("player") .. "-" .. GetRealmName())
				custom_window.author_field = author_field
				
			--description
				local desc_label = gump:NewLabel (box0, box0, "$parenDescLabel", "desc", Loc ["STRING_CUSTOM_DESCRIPTION"], "GameFontHighlightLeft") --> localize-me
				desc_label:SetPoint ("topleft", author_label, "bottomleft", 0, -12)
				
				local desc_field = gump:NewTextEntry (box0, nil, "$parentDescEntry", "descentry", 200, 20)
				desc_field:SetPoint ("left", desc_label, "left", 62, 0)
				desc_field.tooltip = Loc ["STRING_CUSTOM_DESCRIPTION_DESC"]
				custom_window.desc_field = desc_field

			--icon
				local icon_label = gump:NewLabel (box0, box0, "$parenIconLabel", "icon", Loc ["STRING_CUSTOM_ICON"], "GameFontHighlightLeft") --> localize-me
				icon_label:SetPoint ("topleft", desc_label, "bottomleft", 0, -12)
				
				local pickicon_callback = function (texture)
					box0.icontexture:SetTexture (texture)
					
				end
				local pickicon = function()
					gump:IconPick (pickicon_callback, true)
				end
				local icon_image = gump:NewImage (box0, [[Interface\ICONS\TEMP]], 20, 20, nil, nil, "icontexture", "$parentIconTexture")
				local icon_button = gump:NewButton (box0, nil, "$parentIconButton", "IconButton", 20, 20, pickicon)
				icon_button:InstallCustomTexture()
				icon_button:SetPoint ("left", icon_label, "left", 64, 0)
				icon_image:SetPoint ("left", icon_label, "left", 64, 0)
				custom_window.icon_image = icon_image

			--cancel
				local cancel_button = gump:NewButton (box0, nil, "$parentCancelButton", "cancelbutton", 130, 20, DetailsCustomPanel.CancelFunc, nil, nil, nil, Loc ["STRING_CUSTOM_CANCEL"])
				cancel_button:SetPoint ("bottomleft", attribute_box, "bottomright", 37, -10)
				cancel_button:InstallCustomTexture()
				
			--accept
				local accept_button = gump:NewButton (box0, nil, "$parentAcceptButton", "acceptbutton", 130, 20, DetailsCustomPanel.AcceptFunc, nil, nil, nil, Loc ["STRING_CUSTOM_CREATE"])
				accept_button:SetPoint ("left", cancel_button, "right", 2, 0)
				accept_button:InstallCustomTexture()
				

			
			--> create box type 1
				local box1 = _CreateFrame ("frame", "DetailsCustomPanelBox1", custom_window)
				custom_window.box1 = box1
				box1:SetSize (450, 180)
				--box1:SetBackdrop ({
				--	bgFile = "Interface\\AddOns\\Details\\images\\background", 
				--	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
				--	tile = true, tileSize = 16, edgeSize = 12})
				--box1:SetBackdropColor (1, 0, 0, .9)
				box1:SetPoint ("topleft", icon_label.widget, "bottomleft", -10, -20)
				
				box1:SetFrameLevel (box0:GetFrameLevel()+1)
			
				--source
					local source_label = gump:NewLabel (box1, box1, "$parenSourceLabel", "source", Loc ["STRING_CUSTOM_SOURCE"], "GameFontHighlightLeft") --> localize-me
					source_label:SetPoint ("topleft", box1, "topleft", 10, 0)
					
					local disable_source_field = function()
						box1.sourceentry:Disable()
					end
					local enable_source_field = function()
						box1.sourceentry:Enable()
						box1.sourceentry:SetFocus (true)
					end
					
					local source_icon = [[Interface\COMMON\Indicator-Yellow]]
					
					local targeting_options = {
						{value = "[all]", label = "All Characters", desc = "Search for matches in all characters.", onclick = disable_source_field, icon = source_icon},
						{value = "[raid]", label = "Raid or Party Group", desc = "Search for matches in all characters which is part of your party or raid group.", onclick = disable_source_field, icon = source_icon},
						{value = "[player]", label = "Only You", desc = "Search for matches only in your character.", onclick = disable_source_field, icon = source_icon},
						{value = false, label = "Specific Character", desc = "Type the name of the character used to search.", onclick = enable_source_field, icon = source_icon},
					}
					local build_source_list = function() return targeting_options end
					local source_dropdown = gump:NewDropDown (box1, nil, "$parentSourceDropdown", "sourcedropdown", 178, 20, build_source_list, 1)
					source_dropdown:SetPoint ("left", source_label, "left", 62, 0)
					source_dropdown.tooltip = Loc ["STRING_CUSTOM_SOURCE_DESC"]
					custom_window.source_dropdown = source_dropdown
					
					local source_field = gump:NewTextEntry (box1, nil, "$parentSourceEntry", "sourceentry", 201, 20)
					source_field:SetPoint ("topleft", source_dropdown, "bottomleft", 0, -2)
					source_field:Disable()
					custom_window.source_field = source_field
					
					local adds_boss = CreateFrame ("frame", nil, box1)
					adds_boss:SetPoint ("left", source_dropdown.widget, "right", 2, 0)
					adds_boss:SetSize (20, 20)
					
					local adds_boss_image = adds_boss:CreateTexture (nil, "overlay")
					adds_boss_image:SetPoint ("center", adds_boss)
					adds_boss_image:SetTexture ("Interface\\Buttons\\UI-MicroButton-Raid-Up")
					adds_boss_image:SetTexCoord (0.046875, 0.90625, 0.40625, 0.953125)
					adds_boss_image:SetWidth (20)
					adds_boss_image:SetHeight (16)

					local actorsFrame = gump:NewPanel (custom_window, _, "DetailsCustomActorsFrame2", "actorsFrame", 1, 1)
					actorsFrame:SetPoint ("topleft", custom_window, "topright", 5, -60)
					actorsFrame:Hide()
					
					local modelFrame = _CreateFrame ("playermodel", "DetailsCustomActorsFrame2Model", custom_window)
					modelFrame:SetSize (138, 261)
					modelFrame:SetPoint ("topright", actorsFrame.widget, "topleft", -15, -8)
					modelFrame:Hide()
					local modelFrameTexture = modelFrame:CreateTexture (nil, "background")
					modelFrameTexture:SetAllPoints()
					
					local modelFrameBackground = custom_window:CreateTexture (nil, "artwork")
					modelFrameBackground:SetSize (138, 261)
					modelFrameBackground:SetPoint ("topright", actorsFrame.widget, "topleft", -15, -8)
					modelFrameBackground:SetTexture ([[Interface\ACHIEVEMENTFRAME\UI-GuildAchievement-Parchment-Horizontal-Desaturated]])
					modelFrameBackground:SetRotation (90)
					modelFrameBackground:SetVertexColor (.5, .5, .5, 0.5)
					
					local modelFrameBackgroundIcon = custom_window:CreateTexture (nil, "overlay")
					modelFrameBackgroundIcon:SetPoint ("center", modelFrameBackground, "center")
					modelFrameBackgroundIcon:SetTexture ([[Interface\CHARACTERFRAME\Disconnect-Icon]])
					modelFrameBackgroundIcon:SetVertexColor (.5, .5, .5, 0.7)
					
					
					local selectedEncounterActor = function (actorName, model)
						source_field:SetText (actorName)
						source_dropdown:Select (4, true)
						box1.sourceentry:Enable()
						actorsFrame:Hide()
						GameCooltip:Hide()
					end
					
					local actorsFrameButtons = {}

					local buttonMouseOver = function (button)
						button.MyObject.image:SetBlendMode ("ADD")
						button.MyObject.line:SetBlendMode ("ADD")
						button.MyObject.label:SetTextColor (1, 1, 1, 1)
						GameTooltip:SetOwner (button, "ANCHOR_TOPLEFT")
						GameTooltip:AddLine (button.MyObject.actor)
						GameTooltip:Show()
						
						local name, description, bgImage, buttonImage, loreImage, dungeonAreaMapID, link = EJ_GetInstanceInfo (button.MyObject.ej_id)
						
						modelFrameTexture:SetTexture (bgImage)
						modelFrameTexture:SetTexCoord (3/512, 370/512, 5/512, 429/512)
						modelFrame:Show()
						
						modelFrame:SetDisplayInfo (button.MyObject.model)
					end
					local buttonMouseOut = function (button)
						button.MyObject.image:SetBlendMode ("BLEND")
						button.MyObject.line:SetBlendMode ("BLEND")
						button.MyObject.label:SetTextColor (.8, .8, .8, .8)
						GameTooltip:Hide()
						modelFrame:Hide()
					end
					
					local EncounterSelect = function (_, _, instanceId, bossIndex, ej_id)
						
						DetailsCustomSpellsFrame:Hide()
						DetailsCustomActorsFrame:Hide()
						DetailsCustomActorsFrame2:Show()
						GameCooltip:Hide()
						
						local encounterID = _detalhes:GetEncounterIdFromBossIndex (instanceId, bossIndex)
						
						if (encounterID) then
							local actors = _detalhes:GetEncounterActorsName (encounterID)

							local x = 10
							local y = 10
							local i = 1
							
							for actor, actorTable in pairs (actors) do 
							
								local thisButton = actorsFrameButtons [i]
								
								if (not thisButton) then
									thisButton = gump:NewButton (actorsFrame.frame, actorsFrame.frame, "DetailsCustomActorsFrame2Button"..i, "button"..i, 130, 20, selectedEncounterSpell)
									thisButton:SetPoint ("topleft", "DetailsCustomActorsFrame2", "topleft", x, -y)
									thisButton:SetHook ("OnEnter", buttonMouseOver)
									thisButton:SetHook ("OnLeave", buttonMouseOut)
									
									local t = gump:NewImage (thisButton, nil, 20, 20, nil, nil, "image", "DetailsCustomActors2EncounterImageButton"..i)
									t:SetPoint ("left", thisButton)
									t:SetTexture ([[Interface\MINIMAP\TRACKING\Target]])
									t:SetDesaturated (true)
									t:SetSize (20, 20)
									t:SetAlpha (0.7)
									
									local text = gump:NewLabel (thisButton, nil, "DetailsCustomActorsFrame2Button"..i.."Label", "label", "Spell", nil, 9.5, {.8, .8, .8, .8})
									text:SetPoint ("left", t.image, "right", 2, 0)
									text:SetWidth (123)
									text:SetHeight (10)
									
									local border = gump:NewImage (thisButton, "Interface\\SPELLBOOK\\Spellbook-Parts", 40, 38, nil, nil, "border", "DetailsCustomActors2EncounterBorderButton"..i)
									border:SetTexCoord (0.00390625, 0.27734375, 0.44140625,0.69531250)
									border:SetDrawLayer ("background")
									border:SetPoint ("topleft", thisButton.button, "topleft", -9, 9)
									
									local line = gump:NewImage (thisButton, "Interface\\SPELLBOOK\\Spellbook-Parts", 134, 25, nil, nil, "line", "DetailsCustomActors2EncounterLineButton"..i)
									line:SetTexCoord (0.31250000, 0.96484375, 0.37109375, 0.52343750)
									line:SetDrawLayer ("background")
									line:SetPoint ("left", thisButton.button, "right", -110, -3)
									
									table.insert (actorsFrameButtons, #actorsFrameButtons+1, thisButton)
								end
								
								y = y + 20
								if (y >= 260) then
									y = 10
									x = x + 150
								end
								
								thisButton.label:SetText (actor)
								thisButton:SetClickFunction (selectedEncounterActor, actor, actorTable.model)
								thisButton.actor = actor
								thisButton.ej_id = ej_id
								thisButton.model = actorTable.model
								thisButton:Show()
								i = i + 1
							end
							
							for maxIndex = i, #actorsFrameButtons do
								actorsFrameButtons [maxIndex]:Hide()
							end
							
							i = i-1
							actorsFrame:SetSize (math.ceil (i/13)*160, math.min (i*20 + 20, 280))
						
						end
					end
					
					local BuildEncounterMenu = function()
					
						GameCooltip:Reset()
						GameCooltip:SetType ("menu")
						GameCooltip:SetOwner (adds_boss)

						for instanceId, instanceTable in pairs (_detalhes.EncounterInformation) do 
						
							if (_detalhes:InstanceIsRaid (instanceId)) then
						
								GameCooltip:AddLine (instanceTable.name, _, 1, "white")
								GameCooltip:AddIcon (instanceTable.icon, 1, 1, 64, 32)

								for index, encounterName in ipairs (instanceTable.boss_names) do 
									GameCooltip:AddMenu (2, EncounterSelect, instanceId, index, instanceTable.ej_id, encounterName, nil, true)
									local L, R, T, B, Texture = _detalhes:GetBossIcon (instanceId, index)
									GameCooltip:AddIcon (Texture, 2, 1, 20, 20, L, R, T, B)
								end
								
								GameCooltip:SetWallpaper (2, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0, 0.64453125}, {1, 1, 1, 0.1}, true)
							
							end
						end
						
						GameCooltip:SetOption ("HeightAnchorMod", -10)
						GameCooltip:SetOption ("ButtonsYMod", -2)
						GameCooltip:SetOption ("YSpacingMod", 0)
						GameCooltip:SetOption ("TextHeightMod", 0)
						GameCooltip:SetOption ("IgnoreButtonAutoHeight", false)
						GameCooltip:SetWallpaper (1, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0, 0.64453125}, {1, 1, 1, 0.1}, true)
						
						GameCooltip:ShowCooltip()
					end
					
					adds_boss:SetScript ("OnEnter", function() 
						adds_boss_image:SetBlendMode ("ADD")
						BuildEncounterMenu()
					end)
					
					adds_boss:SetScript ("OnLeave", function() 
						adds_boss_image:SetBlendMode ("BLEND")
					end)
					
				--target
					local target_label = gump:NewLabel (box1, box1, "$parenTargetLabel", "target", Loc ["STRING_CUSTOM_TARGET"], "GameFontHighlightLeft")
					target_label:SetPoint ("topleft", source_label, "bottomleft", 0, -40)
					
					local disable_target_field = function()
						box1.targetentry:Disable()
					end
					local enable_target_field = function()
						box1.targetentry:Enable()
						box1.targetentry:SetFocus (true)
					end
					
					local target_icon = [[Interface\COMMON\Indicator-Yellow]]
					local target_icon2 = [[Interface\COMMON\Indicator-Gray]]
					
					local targeting_options = {
						{value = "[all]", label = "All Characters", desc = "Search for matches in all characters.", onclick = disable_target_field, icon = target_icon},
						{value = "[raid]", label = "Raid or Party Group", desc = "Search for matches in all characters which is part of your party or raid group.", onclick = disable_target_field, icon = target_icon},
						{value = "[player]", label = "Only You", desc = "Search for matches only in your character.", onclick = disable_target_field, icon = target_icon},
						{value = false, label = "Specific Character", desc = "Type the name of the character used to search.", onclick = enable_target_field, icon = target_icon},
						{value = "[none]", label = "No Target", desc = "Do not search for targets.", onclick = disable_target_field, icon = target_icon2},
					}
					local build_target_list = function() return targeting_options end
					local target_dropdown = gump:NewDropDown (box1, nil, "$parentTargetDropdown", "targetdropdown", 178, 20, build_target_list, 1)
					target_dropdown:SetPoint ("left", target_label, "left", 62, 0)
					target_dropdown.tooltip = Loc ["STRING_CUSTOM_TARGET_DESC"]
					custom_window.target_dropdown = target_dropdown
					
					local target_field = gump:NewTextEntry (box1, nil, "$parentTargetEntry", "targetentry", 201, 20)
					target_field:SetPoint ("topleft", target_dropdown, "bottomleft", 0, -2)
					target_field:Disable()
					custom_window.target_field = target_field
					--
					
					local adds_boss = CreateFrame ("frame", nil, box1)
					adds_boss:SetPoint ("left", target_dropdown.widget, "right", 2, 0)
					adds_boss:SetSize (20, 20)
					local adds_boss_image = adds_boss:CreateTexture (nil, "overlay")
					adds_boss_image:SetPoint ("center", adds_boss)
					adds_boss_image:SetTexture ("Interface\\Buttons\\UI-MicroButton-Raid-Up")
					adds_boss_image:SetTexCoord (0.046875, 0.90625, 0.40625, 0.953125)
					adds_boss_image:SetWidth (20)
					adds_boss_image:SetHeight (16)
					
					local actorsFrame = gump:NewPanel (custom_window, _, "DetailsCustomActorsFrame", "actorsFrame", 1, 1)
					actorsFrame:SetPoint ("topleft", custom_window, "topright", 5, -60)
					actorsFrame:Hide()
					
					local modelFrame = _CreateFrame ("playermodel", "DetailsCustomActorsFrameModel", custom_window)
					modelFrame:SetSize (138, 261)
					modelFrame:SetPoint ("topright", actorsFrame.widget, "topleft", -15, -8)
					modelFrame:Hide()
					local modelFrameTexture = modelFrame:CreateTexture (nil, "background")
					modelFrameTexture:SetAllPoints()
					
					local selectedEncounterActor = function (actorName)
						target_field:SetText (actorName)
						target_dropdown:Select (4, true)
						box1.targetentry:Enable()
						actorsFrame:Hide()
						GameCooltip:Hide()
					end
					
					local actorsFrameButtons = {}

					local buttonMouseOver = function (button)
						button.MyObject.image:SetBlendMode ("ADD")
						button.MyObject.line:SetBlendMode ("ADD")
						button.MyObject.label:SetTextColor (1, 1, 1, 1)
						GameTooltip:SetOwner (button, "ANCHOR_TOPLEFT")
						GameTooltip:AddLine (button.MyObject.actor)
						GameTooltip:Show()
						
						local name, description, bgImage, buttonImage, loreImage, dungeonAreaMapID, link = EJ_GetInstanceInfo (button.MyObject.ej_id)
						
						modelFrameTexture:SetTexture (bgImage)
						modelFrameTexture:SetTexCoord (3/512, 370/512, 5/512, 429/512)
						modelFrame:Show()
						
						modelFrame:SetDisplayInfo (button.MyObject.model)
					end
					local buttonMouseOut = function (button)
						button.MyObject.image:SetBlendMode ("BLEND")
						button.MyObject.line:SetBlendMode ("BLEND")
						button.MyObject.label:SetTextColor (.8, .8, .8, .8)
						GameTooltip:Hide()
						
						modelFrame:Hide()
					end
					
					local EncounterSelect = function (_, _, instanceId, bossIndex, ej_id)
						
						DetailsCustomSpellsFrame:Hide()
						DetailsCustomActorsFrame:Show()
						DetailsCustomActorsFrame2:Hide()
						GameCooltip:Hide()
						
						local encounterID = _detalhes:GetEncounterIdFromBossIndex (instanceId, bossIndex)
						if (encounterID) then
							local actors = _detalhes:GetEncounterActorsName (encounterID)

							local x = 10
							local y = 10
							local i = 1
							
							for actor, actorTable in pairs (actors) do 
							
								local thisButton = actorsFrameButtons [i]
								
								if (not thisButton) then
									thisButton = gump:NewButton (actorsFrame.frame, actorsFrame.frame, "DetailsCustomActorsFrameButton"..i, "button"..i, 130, 20, selectedEncounterSpell)
									thisButton:SetPoint ("topleft", "DetailsCustomActorsFrame", "topleft", x, -y)
									thisButton:SetHook ("OnEnter", buttonMouseOver)
									thisButton:SetHook ("OnLeave", buttonMouseOut)
									
									local t = gump:NewImage (thisButton, nil, 20, 20, nil, nil, "image", "DetailsCustomActorsEncounterImageButton"..i)
									t:SetPoint ("left", thisButton)
									t:SetTexture ([[Interface\MINIMAP\TRACKING\Target]])
									t:SetDesaturated (true)
									t:SetSize (20, 20)
									t:SetAlpha (0.7)
									
									local text = gump:NewLabel (thisButton, nil, "DetailsCustomActorsFrameButton"..i.."Label", "label", "Spell", nil, 9.5, {.8, .8, .8, .8})
									text:SetPoint ("left", t.image, "right", 2, 0)
									text:SetWidth (123)
									text:SetHeight (10)
									
									local border = gump:NewImage (thisButton, "Interface\\SPELLBOOK\\Spellbook-Parts", 40, 38, nil, nil, "border", "DetailsCustomActorsEncounterBorderButton"..i)
									border:SetTexCoord (0.00390625, 0.27734375, 0.44140625,0.69531250)
									border:SetDrawLayer ("background")
									border:SetPoint ("topleft", thisButton.button, "topleft", -9, 9)
									
									local line = gump:NewImage (thisButton, "Interface\\SPELLBOOK\\Spellbook-Parts", 84, 25, nil, nil, "line", "DetailsCustomActorsEncounterLineButton"..i)
									line:SetTexCoord (0.31250000, 0.96484375, 0.37109375, 0.52343750)
									line:SetDrawLayer ("background")
									line:SetPoint ("left", thisButton.button, "right", -110, -3)
									
									table.insert (actorsFrameButtons, #actorsFrameButtons+1, thisButton)
								end
								
								y = y + 20
								if (y >= 260) then
									y = 10
									x = x + 150
								end
								
								thisButton.label:SetText (actor)
								thisButton:SetClickFunction (selectedEncounterActor, actor)
								thisButton.actor = actor
								thisButton.ej_id = ej_id
								thisButton.model = actorTable.model
								thisButton:Show()
								i = i + 1
							end
							
							for maxIndex = i, #actorsFrameButtons do
								actorsFrameButtons [maxIndex]:Hide()
							end
							
							i = i-1
							actorsFrame:SetSize (math.ceil (i/13)*160, math.min (i*20 + 20, 280))
						
						end
					end
					
					local BuildEncounterMenu = function()
					
						GameCooltip:Reset()
						GameCooltip:SetType ("menu")
						GameCooltip:SetOwner (adds_boss)
						
						for instanceId, instanceTable in pairs (_detalhes.EncounterInformation) do 
						
							if (_detalhes:InstanceIsRaid (instanceId)) then
						
								GameCooltip:AddLine (instanceTable.name, _, 1, "white")
								GameCooltip:AddIcon (instanceTable.icon, 1, 1, 64, 32)

								for index, encounterName in ipairs (instanceTable.boss_names) do 
									GameCooltip:AddMenu (2, EncounterSelect, instanceId, index, instanceTable.ej_id, encounterName, nil, true)
									local L, R, T, B, Texture = _detalhes:GetBossIcon (instanceId, index)
									GameCooltip:AddIcon (Texture, 2, 1, 20, 20, L, R, T, B)
								end
								
								GameCooltip:SetWallpaper (2, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0, 0.64453125}, {1, 1, 1, 0.1}, true)
							
							end
						end
						
						GameCooltip:SetOption ("HeightAnchorMod", -10)
						GameCooltip:SetOption ("ButtonsYMod", -2)
						GameCooltip:SetOption ("YSpacingMod", 0)
						GameCooltip:SetOption ("TextHeightMod", 0)
						GameCooltip:SetOption ("IgnoreButtonAutoHeight", false)
						GameCooltip:SetWallpaper (1, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0, 0.64453125}, {1, 1, 1, 0.1}, true)
						GameCooltip:ShowCooltip()
					end
					
					adds_boss:SetScript ("OnEnter", function() 
						adds_boss_image:SetBlendMode ("ADD")
						BuildEncounterMenu()
					end)
					
					adds_boss:SetScript ("OnLeave", function() 
						adds_boss_image:SetBlendMode ("BLEND")
					end)					
					
				--spellid
					local spellid_label = gump:NewLabel (box1, box1, "$parenSpellidLabel", "spellid", Loc ["STRING_CUSTOM_SPELLID"], "GameFontHighlightLeft") --> localize-me
					spellid_label:SetPoint ("topleft", target_label, "bottomleft", 0, -40)
					
					local spellid_entry = gump:NewSpellEntry (box1, function()end, 178, 20, nil, nil, "spellidentry", "$parentSpellIdEntry")
					spellid_entry:SetPoint ("left", spellid_label, "left", 62, 0)
					spellid_entry.tooltip = Loc ["STRING_CUSTOM_SPELLID_DESC"]
					custom_window.spellid_entry = spellid_entry
			
					local spell_id_boss = CreateFrame ("frame", nil, box1)
					spell_id_boss:SetPoint ("left", spellid_entry.widget, "right", 2, 0)
					spell_id_boss:SetSize (20, 20)
					local spell_id_boss_image = spell_id_boss:CreateTexture (nil, "overlay")
					spell_id_boss_image:SetPoint ("center", spell_id_boss)
					spell_id_boss_image:SetTexture ("Interface\\Buttons\\UI-MicroButton-Raid-Up")
					spell_id_boss_image:SetTexCoord (0.046875, 0.90625, 0.40625, 0.953125)
					spell_id_boss_image:SetWidth (20)
					spell_id_boss_image:SetHeight (16)
					
					local spellsFrame = gump:NewPanel (custom_window, _, "DetailsCustomSpellsFrame", "spellsFrame", 1, 1)
					spellsFrame:SetPoint ("topleft", custom_window, "topright", 5, 0)
					spellsFrame:Hide()
					
					local selectedEncounterSpell = function (spellId)
						local _, _, icon = _GetSpellInfo (spellId)
						spellid_entry:SetText (spellId)
						box0.icontexture:SetTexture (icon)
						spellsFrame:Hide()
						GameCooltip:Hide()
					end
					
					local spellsFrameButtons = {}

					local buttonMouseOver = function (button)
						button.MyObject.image:SetBlendMode ("ADD")
						button.MyObject.line:SetBlendMode ("ADD")
						button.MyObject.label:SetTextColor (1, 1, 1, 1)

						GameTooltip:SetOwner (button, "ANCHOR_TOPLEFT")
						_detalhes:GameTooltipSetSpellByID (button.MyObject.spellid)
						GameTooltip:Show()
					end
					local buttonMouseOut = function (button)
						button.MyObject.image:SetBlendMode ("BLEND")
						button.MyObject.line:SetBlendMode ("BLEND")
						button.MyObject.label:SetTextColor (.8, .8, .8, .8)
						GameTooltip:Hide()
					end
					
					local EncounterSelect = function (_, _, instanceId, bossIndex)
						
						DetailsCustomSpellsFrame:Show()
						DetailsCustomActorsFrame:Hide()
						DetailsCustomActorsFrame2:Hide()
						
						GameCooltip:Hide()
						
						local spells = _detalhes:GetEncounterSpells (instanceId, bossIndex)
						
						local x = 10
						local y = 10
						local i = 1
						
						for spell, _ in pairs (spells) do 
						
							local thisButton = spellsFrameButtons [i]
							
							if (not thisButton) then
								thisButton = gump:NewButton (spellsFrame.frame, spellsFrame.frame, "DetailsCustomSpellsFrameButton"..i, "button"..i, 80, 20, selectedEncounterSpell)
								thisButton:SetPoint ("topleft", "DetailsCustomSpellsFrame", "topleft", x, -y)
								thisButton:SetHook ("OnEnter", buttonMouseOver)
								thisButton:SetHook ("OnLeave", buttonMouseOut)
								
								local t = gump:NewImage (thisButton, nil, 20, 20, nil, nil, "image", "DetailsCustomEncounterImageButton"..i)
								t:SetPoint ("left", thisButton)
								
								local text = gump:NewLabel (thisButton, nil, "DetailsCustomSpellsFrameButton"..i.."Label", "label", "Spell", nil, 9.5, {.8, .8, .8, .8})
								text:SetPoint ("left", t.image, "right", 2, 0)
								text:SetWidth (73)
								text:SetHeight (10)
								
								local border = gump:NewImage (thisButton, "Interface\\SPELLBOOK\\Spellbook-Parts", 40, 38, nil, nil, "border", "DetailsCustomEncounterBorderButton"..i)
								border:SetTexCoord (0.00390625, 0.27734375, 0.44140625,0.69531250)
								border:SetDrawLayer ("background")
								border:SetPoint ("topleft", thisButton.button, "topleft", -9, 9)
								
								local line = gump:NewImage (thisButton, "Interface\\SPELLBOOK\\Spellbook-Parts", 84, 25, nil, nil, "line", "DetailsCustomEncounterLineButton"..i)
								line:SetTexCoord (0.31250000, 0.96484375, 0.37109375, 0.52343750)
								line:SetDrawLayer ("background")
								line:SetPoint ("left", thisButton.button, "right", -60, -3)
								
								table.insert (spellsFrameButtons, #spellsFrameButtons+1, thisButton)
							end
							
							y = y + 20
							if (y >= 400) then
								y = 10
								x = x + 100
							end
							
							local nome_magia, _, icone_magia = _GetSpellInfo (spell)
							thisButton.image:SetTexture (icone_magia)
							thisButton.label:SetText (nome_magia)
							thisButton:SetClickFunction (selectedEncounterSpell, spell)
							thisButton.spellid = spell
							thisButton:Show()
							i = i + 1
						end
						
						for maxIndex = i, #spellsFrameButtons do
							spellsFrameButtons [maxIndex]:Hide()
						end
						
						i = i-1
						spellsFrame:SetSize (math.ceil (i/20)*110, math.min (i*20 + 20, 420))
						
					end
					
					local BuildEncounterMenu = function()
					
						GameCooltip:Reset()
						GameCooltip:SetType ("menu")
						GameCooltip:SetOwner (spell_id_boss)
						
						for instanceId, instanceTable in pairs (_detalhes.EncounterInformation) do 
						
							if (_detalhes:InstanceisRaid (instanceId)) then
						
								GameCooltip:AddLine (instanceTable.name, _, 1, "white")
								GameCooltip:AddIcon (instanceTable.icon, 1, 1, 64, 32)

								for index, encounterName in ipairs (instanceTable.boss_names) do 
									GameCooltip:AddMenu (2, EncounterSelect, instanceId, index, nil, encounterName, nil, true)
									local L, R, T, B, Texture = _detalhes:GetBossIcon (instanceId, index)
									GameCooltip:AddIcon (Texture, 2, 1, 20, 20, L, R, T, B)
								end
							
								GameCooltip:SetWallpaper (2, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0, 0.64453125}, {1, 1, 1, 0.1}, true)
							
							end
						end
						
						GameCooltip:SetOption ("ButtonsYMod", -2)
						GameCooltip:SetOption ("YSpacingMod", 0)
						GameCooltip:SetOption ("TextHeightMod", 0)
						GameCooltip:SetOption ("IgnoreButtonAutoHeight", false)
						GameCooltip:SetWallpaper (1, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0, 0.64453125}, {1, 1, 1, 0.1}, true)
						
						GameCooltip:SetOption ("HeightAnchorMod", -10)
						GameCooltip:ShowCooltip()
					end
					
					spell_id_boss:SetScript ("OnEnter", function() 
						spell_id_boss_image:SetBlendMode ("ADD")
						BuildEncounterMenu()
					end)
					
					spell_id_boss:SetScript ("OnLeave", function() 
						spell_id_boss_image:SetBlendMode ("BLEND")
					end)
			
			--select target
			--select spell
			
			--> create box type 2
				local box2 = _CreateFrame ("frame", "DetailsCustomPanelBox2", custom_window)
				custom_window.box2 = box2
				box2:SetSize (450, 180)
				--box2:SetBackdrop ({
				--	bgFile = "Interface\\AddOns\\Details\\images\\background", 
				--	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
				--	tile = true, tileSize = 16, edgeSize = 12})
				--box2:SetBackdropColor (1, 0, 0, .9)
				box2:SetPoint ("topleft", icon_label.widget, "bottomleft", -10, -20)
				
				box2:SetFrameLevel (box0:GetFrameLevel()+1)
			
				--edit main code
				local maincode_button = gump:NewButton (box2, nil, "$parentMainCodeButton", "maiccodebutton", 160, 20, DetailsCustomPanel.StartEditCode, 1, nil, nil, Loc ["STRING_CUSTOM_EDIT_SEARCH_CODE"])
				maincode_button:SetPoint ("topleft", box2, "topleft", 10, -15)
				maincode_button.tooltip = Loc ["STRING_CUSTOM_EDITCODE_DESC"]
				maincode_button:InstallCustomTexture (nil, nil, nil, nil, true)
				
				--edit tooltip code
				local tooltipcode_button = gump:NewButton (box2, nil, "$parentTooltipCodeButton", "tooltipcodebutton", 160, 20, DetailsCustomPanel.StartEditCode, 2, nil, nil, Loc ["STRING_CUSTOM_EDIT_TOOLTIP_CODE"])
				tooltipcode_button:SetPoint ("topleft", maincode_button, "bottomleft", 0, -8)
				tooltipcode_button.tooltip = Loc ["STRING_CUSTOM_EDITTOOLTIP_DESC"]
				tooltipcode_button:InstallCustomTexture (nil, nil, nil, nil, true)
				
				--edit total code
				local totalcode_button = gump:NewButton (box2, nil, "$parentTotalCodeButton", "totalcodebutton", 160, 20, DetailsCustomPanel.StartEditCode, 3, nil, nil, "Edit Total Code")
				totalcode_button:SetPoint ("topleft", tooltipcode_button, "bottomleft", 0, -8)
				totalcode_button.tooltip = "This code is responsible for edit the total number shown in the player bar.\n\nThis is not necessary if you want show exactly the value gotten in the search code."
				totalcode_button:InstallCustomTexture (nil, nil, nil, nil, true)
				
				--edit percent code
				local percentcode_button = gump:NewButton (box2, nil, "$parentPercentCodeButton", "percentcodebutton", 160, 20, DetailsCustomPanel.StartEditCode, 4, nil, nil, "Edit Percent Code")
				percentcode_button:SetPoint ("topleft", totalcode_button, "bottomleft", 0, -8)
				percentcode_button.tooltip = "Edit the code responsible for the percent number in the player bar.\n\nThis is not required if you want to use simple percentage (comparing with total)."
				percentcode_button:InstallCustomTexture (nil, nil, nil, nil, true)
				
				box2:Hide()
			
			--> create the code editbox
				local code_editor = gump:NewSpecialLuaEditorEntry (custom_window, 420, 238, "codeeditor", "$parentCodeEditor")
				code_editor:SetPoint ("topleft", attribute_box, "topright", 30, 0)
				code_editor:SetFrameLevel (custom_window:GetFrameLevel()+4)
				code_editor:SetBackdrop ({bgFile = [[Interface\AddOns\Details\images\background]], edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], 
				tile = 1, tileSize = 16, edgeSize = 16, insets = {left = 5, right = 5, top = 5, bottom = 5}})
				code_editor:SetBackdropColor (0, 0, 0, 1)
				code_editor:Hide()
				code_editor.font_size = 11
				
				local file, size, flags = code_editor.editbox:GetFont()
				code_editor.editbox:SetFont (file, 11, flags)
				
				local expand_func = function()
					if (code_editor.expanded) then
						code_editor:SetSize (420, 238)
						code_editor.expanded = nil
					else
						code_editor:SetSize (950, 800)
						code_editor.expanded = true
					end
				end
				
				local font_change = function (size)
					if (size) then
						local file, size, flags = code_editor.editbox:GetFont()
						code_editor.font_size = code_editor.font_size + 1
						code_editor.editbox:SetFont (file, code_editor.font_size, flags)
					else
						local file, size, flags = code_editor.editbox:GetFont()
						code_editor.font_size = code_editor.font_size - 1
						code_editor.editbox:SetFont (file, code_editor.font_size, flags)
					end
				end
				
				local apply_code = function()
				
					_detalhes:ResetCustomFunctionsCache()
				
					if (DetailsCustomPanel.CodeEditing == 1) then
						DetailsCustomPanel.code1 = custom_window.codeeditor:GetText()
					elseif (DetailsCustomPanel.CodeEditing == 2) then
						DetailsCustomPanel.code2 = custom_window.codeeditor:GetText()
					elseif (DetailsCustomPanel.CodeEditing == 3) then
						DetailsCustomPanel.code3 = custom_window.codeeditor:GetText()
					elseif (DetailsCustomPanel.CodeEditing == 4) then
						DetailsCustomPanel.code4 = custom_window.codeeditor:GetText()
					end
					
					local main_code = DetailsCustomPanel.code1
					local tooltip_code = DetailsCustomPanel.code2
					local total_code = DetailsCustomPanel.code3
					local percent_code = DetailsCustomPanel.code4
					
					local object = DetailsCustomPanel.IsEditing
					
					if (type (object) ~= "table") then
						return _detalhes:Msg ("This object need to be saved before.")
					end
					
					object.script = main_code
					object.tooltip = tooltip_code
					
					if (total_code ~= DetailsCustomPanel.code3_default) then
						object.total_script = total_code
					else
						object.total_script = false
					end
					
					if (percent_code ~= DetailsCustomPanel.code4_default) then
						object.percent_script = percent_code
					else
						object.percent_script = false
					end

					return true
				end
				
				local expand = gump:NewButton (code_editor, nil, "$parentExpand", "expandbutton", 8, 10, expand_func, 4, nil, nil, "^")
				expand:SetPoint ("bottomleft", code_editor, "topleft", 3, 0)
				local font_size1 = gump:NewButton (code_editor, nil, "$parentFont1", "font1button", 8, 10, font_change, true, nil, nil, "+")
				font_size1:SetPoint ("left", expand, "right", -4, 2)
				local font_size2 = gump:NewButton (code_editor, nil, "$parentFont2", "font2button", 8, 10, font_change, nil, nil, nil, "-")
				font_size2:SetPoint ("left", font_size1, "right", -4, 2)
				local apply1 = gump:NewButton (code_editor, nil, "$parentApply", "applybutton", 8, 10, apply_code, nil, nil, nil, "apply")
				apply1:SetPoint ("left", font_size2, "right", -4, 1)

				local open_API = gump:NewButton (code_editor, nil, "$parentOpenAPI", "openAPIbutton", 8, 10, _detalhes.OpenAPI, nil, nil, nil, "Open Details! API")
				open_API:SetPoint ("left", apply1, "right", -4, -1)
				
				
			--> select damage
				DetailsCustomPanelAttributeMenu1:Click()
		else
			_G.DetailsCustomPanel:Show()
		end
	end
	