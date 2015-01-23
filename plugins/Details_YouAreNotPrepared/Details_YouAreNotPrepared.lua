-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> init the plugin

	--> localization
	local Loc = LibStub ("AceLocale-3.0"):GetLocale ("Details_YouAreNotPrepared")
	--> create the plugin object
	local YouAreNotPrepared = _detalhes:NewPluginObject ("Details_YouAreNotPrepared", DETAILSPLUGIN_ALWAYSENABLED)
	tinsert (UISpecialFrames, "Details_YouAreNotPrepared")
	--> main frame (shortcut)
	local YouAreNotPreparedFrame = YouAreNotPrepared.Frame

	local debugmode = false
	
	YouAreNotPrepared:SetPluginDescription ("Tracks your deaths during raid encounters and shows it for you right after the fight end.")
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> init the frames

	local function CreatePluginFrames()

		--> catch Details! main object
		local _detalhes = _G._detalhes
		local DetailsFrameWork = _detalhes.gump

		local GameCooltip = GameCooltip
		local _GetSpellInfo = _detalhes.getspellinfo
		
		YouAreNotPrepared.last_death_combat_id = -1

	---------- event parser -------------	
		function YouAreNotPrepared:OnDetailsEvent (event, ...)
			if (event == "HIDE") then --> plugin hidded, disabled
				self.open = false
			
			elseif (event == "SHOW") then --> plugin hidded, disabled
				self.open = true
				
			elseif (event == "COMBAT_PLAYER_ENTER") then --> combat started
			
			elseif (event == "COMBAT_PLAYER_LEAVE") then --> combat ended
				YouAreNotPrepared:EndCombat()
				
			elseif (event == "DETAILS_DATA_RESET") then
				table.wipe (YouAreNotPrepared.db.deaths_table)
				YouAreNotPrepared:Clear()
				
			elseif (event == "PLUGIN_DISABLED") then
				table.wipe (YouAreNotPrepared.db.deaths_table)
				YouAreNotPrepared:Clear()
				YouAreNotPreparedFrame:Hide()
				
			elseif (event == "PLUGIN_ENABLED") then
				
			end
		end
		
	---------- build frames -------------
		
		local BAR_HEIGHT = 13
		local BAR_AMOUNT = 10
		local BUTTON_AMOUNT = 6

		function YouAreNotPrepared:Clear()
			table.wipe (YouAreNotPrepared.db.deaths_table)
			
			for i = 1, BUTTON_AMOUNT do
				local button = YouAreNotPrepared.buttons [i]
				button:Disable()
				button.widget.b_texture:SetDesaturated (true)
				button.lefttext.text = "#" .. i
			end
			
			for bar_index = 1, BAR_AMOUNT do 
				YouAreNotPrepared.container_bars.bars [bar_index]:Hide()
			end
		end

		--main frame
		YouAreNotPreparedFrame:SetSize (424, 223)
		YouAreNotPreparedFrame:SetPoint ("center", UIParent, "center")
		YouAreNotPreparedFrame:EnableMouse (true)
		YouAreNotPreparedFrame:SetResizable (false)
		YouAreNotPreparedFrame:SetMovable (true)
		
		YouAreNotPreparedFrame:SetScript ("OnMouseUp", function (self, button)
			if (button == "RightButton") then
				YouAreNotPrepared.db.rightclick_closed = true
				YouAreNotPreparedFrame:Hide()
			else
				if (YouAreNotPreparedFrame.isMoving) then
					YouAreNotPreparedFrame:StopMovingOrSizing()
					YouAreNotPreparedFrame.isMoving = false
				end
			end
		end)
		
		YouAreNotPreparedFrame:SetScript ("OnMouseDown", function (self, button)
			if (button == "LeftButton") then
				if (not YouAreNotPreparedFrame.isMoving) then
					YouAreNotPreparedFrame:StartMoving()
					YouAreNotPreparedFrame.isMoving = true
				end
			end
		end)
		
		--close button
		local c = CreateFrame ("Button", nil, YouAreNotPreparedFrame, "UIPanelCloseButton")
		c:SetWidth (32)
		c:SetHeight (32)
		c:SetPoint ("TOPRIGHT",  YouAreNotPreparedFrame, "TOPRIGHT", 1, -15)
		c:SetFrameLevel (YouAreNotPreparedFrame:GetFrameLevel()+1)

		--background image	
		local b = DetailsFrameWork:NewImage (YouAreNotPreparedFrame, [[Interface\AddOns\Details_YouAreNotPrepared\background]], 512, 256, "background", nil, nil, "$parentBackground")
		b:SetPoint ("topleft", YouAreNotPreparedFrame, "topleft")
		
		--title
		local t = DetailsFrameWork:NewLabel (YouAreNotPreparedFrame, nil, "$parentTitle", nil, Loc ["STRING_PLUGIN_NAME"], "GameFontHighlightLeft", 12, {227/255, 186/255, 4/255})
		
		t:SetPoint ("top", YouAreNotPreparedFrame, "top", 20, -26)
		t:SetPoint ("center", YouAreNotPreparedFrame, "center", 0, 0)

		local on_mouse_down = function (self, button)
			if (button == "RightButton" and not YouAreNotPreparedFrame.isMoving) then
				YouAreNotPrepared.db.rightclick_closed = true
				YouAreNotPreparedFrame:Hide()
			else
				if (not YouAreNotPreparedFrame.isMoving) then
					YouAreNotPreparedFrame:StartMoving()
					YouAreNotPreparedFrame.isMoving = true
				end
			end
		end
		local on_mouse_up = function (self, button)
			if (YouAreNotPreparedFrame.isMoving) then
				YouAreNotPreparedFrame:StopMovingOrSizing()
				YouAreNotPreparedFrame.isMoving = false
			end
		end
		
		--bar container
		local container_bars = CreateFrame ("frame", "Details_YouAreNotPrepared_FauxScroll_Box", YouAreNotPreparedFrame)
		container_bars:SetPoint ("topleft", YouAreNotPreparedFrame, "topleft", 23, -80)
		container_bars:SetSize (252, 137)
		container_bars:SetBackdrop ({bgFile = "Interface\\AddOns\\Details\\images\\background", tile = true, tileSize = 16,
		insets = {left = 0, right = 0, top = 0, bottom = 0}})
		container_bars:SetBackdropColor (.1, .1, .1, .2)
		YouAreNotPrepared.container_bars = container_bars
		
		container_bars:SetScript ("OnMouseDown", on_mouse_down)
		container_bars:SetScript ("OnMouseUp", on_mouse_up)
		
		container_bars.bars = {}
		
		local MouseDownCloseHook = function (_, button)
			if (button == "RightButton") then
				YouAreNotPrepared.db.rightclick_closed = true
				YouAreNotPreparedFrame:Hide()
				return true --> interrupt hook
			end
		end
		
		local on_enter_bar = function (self)
			if (self.MyObject.spellid) then
				GameTooltip:SetOwner (self, "ANCHOR_TOPLEFT")
				GameTooltip:SetSpellByID (self.MyObject.spellid)
				GameTooltip:Show()
			end
		end
		local on_leave_bar = function (self)
			GameTooltip:Hide()
		end

		function container_bars:CreateChild()
		
			local bar_number = #self.bars + 1
			
			local bar = DetailsFrameWork:NewPanel (self, YouAreNotPreparedFrame, "$parentBar" .. bar_number, nil, 250, BAR_HEIGHT)
			bar:SetPoint ("topleft", self, "topleft", 1, bar_number*13*-1+9)
			bar:SetHook ("OnMouseDown", MouseDownCloseHook)
			bar.locked = false
			bar.backdrop = nil
			bar.hide = true
			
			local statusbar = DetailsFrameWork:NewBar (bar, nil, "$parentStatusbar", "statusbar", 250, BAR_HEIGHT)
			statusbar:SetPoint ("left", bar, "left")
			statusbar.fontsize = 9
			statusbar.textleft:SetHeight (16)
			YouAreNotPrepared:SetFontFace (statusbar.textleft, "GameFontHighlightSmall")
			YouAreNotPrepared:SetFontFace (statusbar.textleft, "GameFontNormal")
			
			statusbar:SetHook ("OnEnter", on_enter_bar)
			statusbar:SetHook ("OnLeave", on_leave_bar)
			statusbar:SetHook ("OnMouseDown", on_mouse_down)
			statusbar:SetHook ("OnMouseUp", on_mouse_up)
			
			bar:SetHook ("OnMouseDown", on_mouse_down)
			bar:SetHook ("OnMouseUp", on_mouse_up)
			
			container_bars.bars [bar_number] = bar
			
			return bar
		end
		
		function container_bars:UpdateChild (bar_number, data, time_of_death, max_health)
		
			--> death parser
			
			local spellname, _, icon = _GetSpellInfo (data[2])
			local bar = container_bars.bars [bar_number]
			
			if (spellname) then
			
				local hp = math.floor (data[5] / max_health * 100)
				if (hp > 100) then 
					hp = 100
				end

				if (data[1] and type (data [1]) == "boolean") then --> damage
					bar.statusbar.textleft:SetText (string.format ("%.1f", data [4] - time_of_death) .. "s " .. spellname .. " (" .. data [6] .. ")")
					bar.statusbar.textright:SetText ("-" .. YouAreNotPrepared:ToK (data [3]) .. " (" .. hp .. "%)")
					bar.statusbar._icon:SetTexture (icon)
					if (data [9]) then
						bar.statusbar.color = "darkorange"
					else
						bar.statusbar.color = "red"
					end
					bar.statusbar.background:SetVertexColor (1, 0, 0, .2)
					bar.statusbar.textleft:SetWidth (250 - bar.statusbar.textright:GetStringWidth() - 20)
					bar.statusbar.value = hp
					bar.statusbar.spellid = data[2]
					return true
					
				elseif (not data[1] and type (data [1]) == "boolean") then --> healing
					bar.statusbar.textleft:SetText (string.format ("%.1f", data [4] - time_of_death) .. "s " .. spellname .. " (" .. data [6] .. ")")
					bar.statusbar.textright:SetText ("+" .. YouAreNotPrepared:ToK (data [3]) .. " (" .. hp .. "%)")
					bar.statusbar._icon:SetTexture (icon)
					bar.statusbar.color = "green"
					bar.statusbar.background:SetVertexColor (0, 1, 0, .2)
					bar.statusbar.textleft:SetWidth (250 - bar.statusbar.textright:GetStringWidth() - 20)
					bar.statusbar.value = hp
					bar.statusbar.spellid = data[2]
					return true
					
				end
			end
			
			return false
		end
		
		--create 10 childs (bars)
		for i = 1, 10 do 
			container_bars:CreateChild()
		end
		
		--create scrollbar
		
		local refresh_function = function (self)
			local offset = FauxScrollFrame_GetOffset (self)

			for bar_index = 1, BAR_AMOUNT do 
				local data = YouAreNotPrepared.s_table[4] [bar_index + offset] --bar_index + offset ---------- preciso pegar os dados de uma pool

				if (data) then
					local successful = container_bars:UpdateChild (bar_index, data, YouAreNotPrepared.s_table[6], YouAreNotPrepared.s_table[5]) --index, death table, clock time of death, max health
					if (not successful) then
						container_bars.bars [bar_index]:Hide()
					else
						container_bars.bars [bar_index]:Show()
					end
				else
					container_bars.bars [bar_index]:Hide()
				end
			end
			
		end

		local scrollbar = CreateFrame ("scrollframe", "Details_YouAreNotPrepared_FauxScroll", container_bars, "FauxScrollFrameTemplate")
		scrollbar:SetScript ("OnVerticalScroll", function (self, offset) FauxScrollFrame_OnVerticalScroll (self, offset, BAR_HEIGHT, refresh_function) end)
		scrollbar:SetPoint ("topleft", YouAreNotPreparedFrame, "topleft", 23, -80)
		scrollbar:SetSize (250, 138)
		scrollbar:SetScript ("OnMouseDown", function (self, button)
			if (button == "RightButton" and not YouAreNotPreparedFrame.isMoving) then
				YouAreNotPrepared.db.rightclick_closed = true
				YouAreNotPreparedFrame:Hide()
			else
				if (not YouAreNotPreparedFrame.isMoving) then
					YouAreNotPreparedFrame:StartMoving()
					YouAreNotPreparedFrame.isMoving = true
				end
			end
		end)
		scrollbar:SetScript ("OnMouseUp", function (self, button)
			if (button == "LeftButton") then
				if (YouAreNotPreparedFrame.isMoving) then
					YouAreNotPreparedFrame:StopMovingOrSizing()
					YouAreNotPreparedFrame.isMoving = false
				end
			end
		end)

		container_bars:EnableMouse (true)
		
		--choose death menu
		
		YouAreNotPrepared.buttons = {}
		
		local select_death = function (selected)
			YouAreNotPrepared.s_table = YouAreNotPrepared.db.deaths_table [selected]
			if (not YouAreNotPrepared.s_table) then
				return
			end
			FauxScrollFrame_Update (scrollbar, #YouAreNotPrepared.s_table[4], BAR_AMOUNT, BAR_HEIGHT)
			refresh_function (scrollbar)
		end
		YouAreNotPrepared.select_death = select_death
		
		function YouAreNotPrepared:CreateDeathButton()
			local button_number = #self.buttons + 1
			
			local button = DetailsFrameWork:NewButton (YouAreNotPreparedFrame, _, "$parentButton" .. button_number, nil, 113, 20, select_death, button_number)
			button:SetPoint ("topleft", YouAreNotPreparedFrame, "topleft", 300, -59 + (button_number*23*-1))
			button:Disable()
			
			local b_texture = button:CreateTexture (nil, "artwork")
			b_texture:SetTexture ([[Interface\AddOns\Details\images\icons]])
			b_texture:SetTexCoord (0.297851, 0.444335, 0.004882, 0.040039) --152 228     2 21    0.0009765625
			b_texture:SetPoint ("topleft", button.widget, "topleft")
			b_texture:SetSize (113, 20)
			b_texture:SetDesaturated (true)
			button.widget.b_texture = b_texture

			local icon = DetailsFrameWork:NewImage (button, nil, 20, 20, nil, nil, "icon", "$parentIcon")
			icon:SetTexCoord (0, 0.4921875, 0, 0.4921875) --0.0078125
			icon:SetPoint ("left", button, "left", 1, 0)
			icon.texture = [[Interface\WorldStateFrame\SkullBones]]
			icon:SetBlendMode ("ADD")
			icon:SetAlpha (.5)
			
			button:SetHook ("OnMouseDown", function (self, button)
				self.b_texture:SetPoint ("topleft", self, "topleft", 1, -1)
				--self.MyObject.lefttext:SetPoint ("left", self.MyObject.icon, "right", 2, 0)
				self.MyObject.icon:SetPoint ("left", self, "left", 2, -1)
			end)
			button:SetHook ("OnMouseUp", function (self, button)
				self.b_texture:SetPoint ("topleft", self, "topleft")
				--self.MyObject.lefttext:SetPoint ("left", self.MyObject.icon, "right", 2, 0)
				self.MyObject.icon:SetPoint ("left", self, "left", 1, 0)
			end)
			button:SetHook ("OnEnter", function (self, button)
				self.b_texture:SetBlendMode ("ADD")
			end)
			button:SetHook ("OnLeave", function (self, button)
				self.b_texture:SetBlendMode ("BLEND")
			end)

			local lefttext = DetailsFrameWork:NewLabel (button, nil, "$parentLeftText", "lefttext", "", "GameFontHighlightSmall", 9)
			lefttext:SetPoint ("left", icon, "right", 2)
			lefttext.width = 80
			lefttext.height = 13
			
			local righttext = DetailsFrameWork:NewLabel (button, nil, "$parentRightText", "righttext", " ", "GameFontHighlightSmall", 9)
			righttext:SetPoint ("right", button, "right", -1)
			
			YouAreNotPrepared.buttons [button_number] = button
			
			return bar
		end
		
		for i = 1, 6 do 
			YouAreNotPrepared:CreateDeathButton()
		end
		
		function YouAreNotPrepared:AddDeath (t)
		
			--> t = [1] = enemy name [2] = time of death [3] = last cooldown [4] = death table [5] = max health [6] = clock time of the death
			
			--add and remove
			table.insert (YouAreNotPrepared.db.deaths_table, 1, t)
			table.remove (YouAreNotPrepared.db.deaths_table, 7)
			
			--update buttons
			for i = 1, 6 do
				local button = YouAreNotPrepared.buttons [i]
				local death_table = YouAreNotPrepared.db.deaths_table [i]
				if (death_table) then
					button:Enable()
					button.widget.b_texture:SetDesaturated (false)
					button.lefttext.text = "#" .. i .. " " .. death_table [1]
				else
					button:Disable()
					button.widget.b_texture:SetDesaturated (true)
					button.lefttext.text = "#" .. i
				end
			end
			
			YouAreNotPrepared:DeathWarning()
		end
		
		function YouAreNotPrepared:UpdateButtons()
			for i = 1, 6 do
				local button = YouAreNotPrepared.buttons [i]
				local death_table = YouAreNotPrepared.db.deaths_table [i]
				if (death_table) then
					button:Enable()
					button.widget.b_texture:SetDesaturated (false)
					button.lefttext.text = "#" .. i .. " " .. death_table [1]
				else
					button:Disable()
					button.widget.b_texture:SetDesaturated (true)
					button.lefttext.text = "#" .. i
				end
			end
		end
		
		function YouAreNotPrepared:ShowMe() --> used for debug
			YouAreNotPreparedFrame:Show()
			
			YouAreNotPrepared:UpdateButtons()

			_detalhes:InstanceAlert (Loc ["STRING_PLUGIN_ALERT"], {[[Interface\ICONS\Achievement_Boss_Illidan]], 14, 14, false, 0.8984375, 0.0546875, 0.0546875, 0.8984375}, YouAreNotPrepared.db.shown_time, {YouAreNotPrepared.ShowMeFromInstanceAlert})
		end
		
		--auto open box
		local autoopen_checkbox = CreateFrame ("CheckButton", "YANP_AutoOpenCheckBox", YouAreNotPreparedFrame, "ChatConfigCheckButtonTemplate")
		autoopen_checkbox:SetPoint ("bottomleft", container_bars, "topleft", 45, -1)
		local text = _G ["YANP_AutoOpenCheckBoxText"]
		text:SetText ("Auto Open")
		autoopen_checkbox:SetFrameLevel (YouAreNotPreparedFrame:GetFrameLevel()+5)
		--YouAreNotPrepared:SetFontSize (text, 10)
		text:ClearAllPoints()
		text:SetPoint ("left", autoopen_checkbox, "right", -2, 1)
		--checkbox.tooltip = Loc ["STRING_REPORTFRAME_CURRENTINFO"]
		autoopen_checkbox:SetHitRectInsets (0, -60, 0, 0)
		autoopen_checkbox:SetScript ("PostClick", function(self)
			if (self:GetChecked()) then
				YouAreNotPrepared.db.auto_open = true
			else
				YouAreNotPrepared.db.auto_open = false
			end
		end)
		YouAreNotPrepared:SetFontColor (text, "greenyellow")
		
	--> open options
		local options_button = CreateFrame ("button", nil, YouAreNotPreparedFrame)
		options_button:SetPoint ("left", text, "right", 2, 0)
		options_button:SetSize (18, 18)
		options_button:SetAlpha (0.8)
		options_button:SetNormalTexture ([[Interface\Buttons\UI-OptionsButton]])
		options_button:SetHighlightTexture ([[Interface\Buttons\UI-OptionsButton]])
		options_button:SetPushedTexture ([[Interface\Buttons\UI-OptionsButton]])
		options_button:SetScript ("OnClick", YouAreNotPrepared.OpenOptionsPanel)
		local right_text = YouAreNotPrepared.gump:CreateLabel (YouAreNotPreparedFrame, "Options", nil, "greenyellow", "GameFontHighlight", "optionstext", "$parentOptionsText")
		right_text:SetPoint ("left", options_button, "right", 2, 0)
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> functions
	
	function YouAreNotPrepared:ShowMeFromInstanceAlert()
		YouAreNotPreparedFrame:Show()
		YouAreNotPrepared.select_death (1)
		YouAreNotPrepared:UpdateButtons()
		_detalhes:InstanceAlert (false)
	end

	function YouAreNotPrepared:DeathWarning()
		_detalhes:InstanceAlert (Loc ["STRING_PLUGIN_ALERT"], {[[Interface\ICONS\Achievement_Boss_Illidan]], 14, 14, false, 0.8984375, 0.0546875, 0.0546875, 0.8984375} , 15, {YouAreNotPrepared.ShowMeFromInstanceAlert})
	end

	function YouAreNotPrepared:EndCombat()
		if (YouAreNotPrepared.last_death_combat_id == YouAreNotPrepared.combat_counter) then
			if (YouAreNotPrepared.db.auto_open) then
				YouAreNotPrepared.ShowMeFromInstanceAlert()
			else
				_detalhes:InstanceAlert (Loc ["STRING_PLUGIN_ALERT"], {[[Interface\ICONS\Achievement_Boss_Illidan]], 14, 14, false, 0.8984375, 0.0546875, 0.0546875, 0.8984375} , 25, {YouAreNotPrepared.ShowMeFromInstanceAlert})
			end
		end
	end

	function YouAreNotPrepared:OnDeath (token, time, who_serial, who_name, who_flags, alvo_serial, alvo_name, alvo_flags, death_table, last_cooldown, time_of_death, max_health)
		--> hooks run inside parser and do not check if the plugin is enabled or not.
		--> we need to check this here before continue.
		if (not YouAreNotPrepared.__enabled) then
			return
		end

		if (alvo_name == YouAreNotPrepared.playername) then
			local combat = YouAreNotPrepared:GetCombat ("current")

			--> store death
			local d = YouAreNotPrepared:reverse_table (death_table)
			death_table = d
			
			if (combat.is_boss) then --> encounter or pvp
				YouAreNotPrepared.last_death_combat_id = YouAreNotPrepared.combat_counter
				return YouAreNotPrepared:AddDeath ({combat.is_boss.name or combat.enemy or "Unknown", time_of_death, last_cooldown, death_table, max_health, time})
			end
		end
	end
	
	local build_options_panel = function()
		local options_frame = CreateFrame ("frame", "YouAreNotPreparedOptionsWindow", UIParent, "ButtonFrameTemplate")
		tinsert (UISpecialFrames, "YouAreNotPreparedOptionsWindow")
		options_frame:SetSize (500, 200)
		options_frame:SetFrameStrata ("DIALOG")
		options_frame:SetScript ("OnMouseDown", function(self) self:StartMoving()end)
		options_frame:SetScript ("OnMouseUp", function(self) self:StopMovingOrSizing()end)
		options_frame:SetMovable (true)
		options_frame:EnableMouse (true)
		options_frame:Hide()
		options_frame:SetPoint ("center", UIParent, "center")
		options_frame.TitleText:SetText ("You Are Not Prepared Options")
		options_frame.portrait:SetTexture ([[Interface\CHARACTERFRAME\TEMPORARYPORTRAIT-FEMALE-BLOODELF]])
		
		local menu = {
			--show when dropdown
			{
				type = "range",
				get = function() return YouAreNotPrepared.db.shown_time end,
				set = function (self, fixedparam, value) YouAreNotPrepared.db.shown_time = value end,
				min = 15,
				max = 120,
				step = 1,
				desc = "How much time the alert stay shown in the window.",
				name = "Alert Timeout"
			},
			{
				type = "toggle",
				get = function() return YouAreNotPrepared.db.auto_open end,
				set = function (self, fixedparam, value) YouAreNotPrepared.db.auto_open = value end,
				desc = "Open the window after leave the combat.",
				name = "Auto Open"
			},
		}
		
		_detalhes.gump:BuildMenu (options_frame, menu, 15, -75, 260)
		
	end
	YouAreNotPrepared.OpenOptionsPanel = function()
		if (not YouAreNotPreparedOptionsWindow) then
			build_options_panel()
		end
		YouAreNotPreparedOptionsWindow:Show()
	end
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> events
	
	function YouAreNotPrepared:OnEvent (_, event, ...)

		if (event == "ADDON_LOADED") then
			local AddonName = select (1, ...)
			if (AddonName == "Details_YouAreNotPrepared") then
				
				if (_G._detalhes) then

					--> create widgets
					CreatePluginFrames()

					--> core version required
					local MINIMAL_DETAILS_VERSION_REQUIRED = 12
					
					local default_settings = {
						shown_time = 30, --
						auto_open = true, --
						hide_on_combat = true, --
						rightclick_closed = false,
						deaths_table = {}
					}
					
					--> install
					local install, saveddata, is_enabled = _G._detalhes:InstallPlugin ("TOOLBAR", Loc ["STRING_PLUGIN_NAME"], [[Interface\ICONS\Achievement_Boss_Illidan]], YouAreNotPrepared, "DETAILS_PLUGIN_YANP", MINIMAL_DETAILS_VERSION_REQUIRED, "Details! Team", "v1.1.2", default_settings)
					if (type (install) == "table" and install.error) then
						return print (install.error)
					end
					
					YouAreNotPrepared.db = saveddata

					YANP_AutoOpenCheckBox:SetChecked (saveddata.auto_open)
					
					--> register needed events
					_G._detalhes:RegisterEvent (YouAreNotPrepared, "DETAILS_DATA_RESET")
					_G._detalhes:RegisterEvent (YouAreNotPrepared, "COMBAT_PLAYER_LEAVE")
					
					--> register needed hooks
					_G._detalhes:InstallHook (DETAILS_HOOK_DEATH, YouAreNotPrepared.OnDeath)
					
					--> create right click to close
					if (not YouAreNotPrepared.db.rightclick_closed) then
						local right_click = YouAreNotPrepared.gump:NewImage (YouAreNotPreparedFrame, [[Interface\TUTORIALFRAME\UI-TUTORIAL-FRAME]], 16, 18, "overlay", {8/512, 70/512, 328/512, 409/512})
						right_click:SetPoint ("left", _G [YouAreNotPreparedFrame:GetName() .. "OptionsText"], "right", 2, 0)
						local right_text = YouAreNotPrepared.gump:CreateLabel (YouAreNotPreparedFrame, "Right Click to Close", nil, "greenyellow", "GameFontHighlight", "rightclicktext", "$parentRightClickText")
						right_text:SetPoint ("left", right_click, "right", 2, 0)
					end
					
					--> install slash command
					SLASH_Details_YouAreNotPrepared1 = "/yanp"
					function SlashCmdList.Details_YouAreNotPrepared (msg, editbox)
						YouAreNotPrepared:ShowMeFromInstanceAlert()
					end

				end
			end
		end
	end
