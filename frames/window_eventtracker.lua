
local Details = _G.Details
local C_Timer = _G.C_Timer
local libwindow = LibStub("LibWindow-1.1")

function Details:OpenEventTrackerOptions(bFromOptionsPanel)
	if (not _G.DetailsEventTrackerOptions) then

		local DF = DetailsFramework

		local optionsPanel = DF:CreateSimplePanel(UIParent, 700, 400, "Details! Event Tracker Options", "DetailsEventTrackerOptions")
		optionsPanel:SetPoint("center", _G.UIParent, "center")
		optionsPanel:SetScript("OnMouseDown", nil)
		optionsPanel:SetScript("OnMouseUp", nil)

		local LibWindow = LibStub("LibWindow-1.1")
		LibWindow.RegisterConfig(optionsPanel, Details.event_tracker.options_frame)
		LibWindow.MakeDraggable(optionsPanel)
		LibWindow.RestorePosition(optionsPanel)

		local options_text_template = DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
		local options_dropdown_template = DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
		local options_switch_template = DF:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
		local options_slider_template = DF:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
		local options_button_template = DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

		--frame strata options
			local set_frame_strata = function(_, _, strata)
				Details.event_tracker.frame.strata = strata
				Details:UpdateEventTrackerFrame()
			end
			local strataTable = {}
			strataTable [1] = {value = "BACKGROUND", label = "BACKGROUND", onclick = set_frame_strata}
			strataTable [2] = {value = "LOW", label = "LOW", onclick = set_frame_strata}
			strataTable [3] = {value = "MEDIUM", label = "MEDIUM", onclick = set_frame_strata}
			strataTable [4] = {value = "HIGH", label = "HIGH", onclick = set_frame_strata}
			strataTable [5] = {value = "DIALOG", label = "DIALOG", onclick = set_frame_strata}

		--font options
			local set_font_shadow= function(_, _, shadow)
				Details.event_tracker.font_shadow = shadow
				Details:UpdateEventTrackerFrame()
			end
			local fontShadowTable = {}
			fontShadowTable [1] = {value = "NONE", label = "None", onclick = set_font_shadow}
			fontShadowTable [2] = {value = "OUTLINE", label = "Outline", onclick = set_font_shadow}
			fontShadowTable [3] = {value = "THICKOUTLINE", label = "Thick Outline", onclick = set_font_shadow}

			local on_select_text_font = function(self, fixed_value, value)
				Details.event_tracker.font_face = value
				Details:UpdateEventTrackerFrame()
			end

		--texture options
			local set_bar_texture = function(_, _, value)
				Details.event_tracker.line_texture = value
				Details:UpdateEventTrackerFrame()
			end

			local SharedMedia = _G.LibStub:GetLibrary ("LibSharedMedia-3.0")
			local textures = SharedMedia:HashTable ("statusbar")
			local texTable = {}
			for name, texturePath in pairs(textures) do
				texTable [#texTable + 1] = {value = name, label = name, statusbar = texturePath, onclick = set_bar_texture}
			end
			table.sort (texTable, function(t1, t2) return t1.label < t2.label end)

		--options table
		local options = {
            always_boxfirst = true,
            --language_addonId = addonId,

			{type = "label", get = function() return "Frame Settings:" end, text_template = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE")},
			--enabled
			{
				type = "toggle",
				get = function() return Details.event_tracker.enabled end,
				set = function(self, fixedparam, value)
					Details.event_tracker.enabled = not Details.event_tracker.enabled
					Details:LoadFramesForBroadcastTools()
				end,
				desc = "Enabled",
				name = "Enabled",
				text_template = options_text_template,
			},
			--locked
			{
				type = "toggle",
				get = function() return Details.event_tracker.frame.locked end,
				set = function(self, fixedparam, value)
					Details.event_tracker.frame.locked = not Details.event_tracker.frame.locked
					Details:UpdateEventTrackerFrame()
				end,
				desc = "Locked",
				name = "Locked",
				text_template = options_text_template,
			},
			--showtitle
			{
				type = "toggle",
				get = function() return Details.event_tracker.frame.show_title end,
				set = function(self, fixedparam, value)
					Details.event_tracker.frame.show_title = not Details.event_tracker.frame.show_title
					Details:UpdateEventTrackerFrame()
				end,
				desc = "Show Title",
				name = "Show Title",
				text_template = options_text_template,
			},
			--backdrop color
			{
				type = "color",
				get = function()
					return {Details.event_tracker.frame.backdrop_color[1], Details.event_tracker.frame.backdrop_color[2], Details.event_tracker.frame.backdrop_color[3], Details.event_tracker.frame.backdrop_color[4]}
				end,
				set = function(self, r, g, b, a)
					local color = Details.event_tracker.frame.backdrop_color
					color[1], color[2], color[3], color[4] = r, g, b, a
					Details:UpdateEventTrackerFrame()
				end,
				desc = "Backdrop Color",
				name = "Backdrop Color",
				text_template = options_text_template,
			},
			--statra
			{
				type = "select",
				get = function() return Details.event_tracker.frame.strata end,
				values = function() return strataTable end,
				name = "Frame Strata"
			},
			{type = "breakline"},
			{type = "label", get = function() return "Line Settings:" end, text_template = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE")},
			--line height
			{
				type = "range",
				get = function() return Details.event_tracker.line_height end,
				set = function(self, fixedparam, value)
					Details.event_tracker.line_height = value
					Details:UpdateEventTrackerFrame()
				end,
				min = 4,
				max = 32,
				step = 1,
				name = "Line Height",
				text_template = options_text_template,
			},
			--line texture
			{
				type = "select",
				get = function() return Details.event_tracker.line_texture end,
				values = function() return texTable end,
				name = "Line Texture",
			},
			--line color
			{
				type = "color",
				get = function()
					return {Details.event_tracker.line_color[1], Details.event_tracker.line_color[2], Details.event_tracker.line_color[3], Details.event_tracker.line_color[4]}
				end,
				set = function(self, r, g, b, a)
					local color = Details.event_tracker.line_color
					color[1], color[2], color[3], color[4] = r, g, b, a
					Details:UpdateEventTrackerFrame()
				end,
				desc = "Line Color",
				name = "Line Color",
				text_template = options_text_template,
			},
			--font size
			{
				type = "range",
				get = function() return Details.event_tracker.font_size end,
				set = function(self, fixedparam, value)
					Details.event_tracker.font_size = value
					Details:UpdateEventTrackerFrame()
				end,
				min = 4,
				max = 32,
				step = 1,
				name = "Font Size",
				text_template = options_text_template,
			},
			--font color
			{
				type = "color",
				get = function()
					return {Details.event_tracker.font_color[1], Details.event_tracker.font_color[2], Details.event_tracker.font_color[3], Details.event_tracker.font_color[4]}
				end,
				set = function(self, r, g, b, a)
					local color = Details.event_tracker.font_color
					color[1], color[2], color[3], color[4] = r, g, b, a
					Details:UpdateEventTrackerFrame()
				end,
				desc = "Font Color",
				name = "Font Color",
				text_template = options_text_template,
			},
			--font shadow
			{
				type = "select",
				get = function() return Details.event_tracker.font_shadow end,
				values = function() return fontShadowTable end,
				name = "Font Shadow"
			},
			--font face
			{
				type = "select",
				get = function() return Details.event_tracker.font_face end,
				values = function() return DF:BuildDropDownFontList (on_select_text_font) end,
				name = "Font Face",
				text_template = options_text_template,
			},

			{type = "blank"},

			{
				type = "toggle",
				get = function() return Details.event_tracker.show_crowdcontrol_pvp end,
				set = function(self, fixedparam, value)
					Details.event_tracker.show_crowdcontrol_pvp = value
				end,
				desc = "Show Crowd Control (Arena & BG)",
				name = "Show Crowd Control when inside a PvP zone",
				text_template = options_text_template,
			},
			{
				type = "toggle",
				get = function() return Details.event_tracker.show_crowdcontrol_pvm end,
				set = function(self, fixedparam, value)
					Details.event_tracker.show_crowdcontrol_pvm = value
				end,
				desc = "Show Crowd Control (Dungeon & Raid)",
				name = "Show Crowd Control when inside a PvE zone",
				text_template = options_text_template,
			},
		}

		DF:BuildMenu(optionsPanel, options, 7, -30, 500, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)

		optionsPanel:SetScript("OnHide", function()
			--reopen the options panel
			if (optionsPanel.FromOptionsPanel) then
				C_Timer.After(0.2, function()
					Details:OpenOptionsWindow(Details:GetInstance(1))
				end)
			end
		end)
	end

	_G.DetailsEventTrackerOptions:RefreshOptions()
	_G.DetailsEventTrackerOptions:Show()
	_G.DetailsEventTrackerOptions.FromOptionsPanel = bFromOptionsPanel
end


function Details:CreateEventTrackerFrame(parentObject, name)
	local DF = Details.gump
	local SharedMedia = LibStub:GetLibrary ("LibSharedMedia-3.0")

	--> screen frame
		local screenFrame = CreateFrame("frame", name, parentObject or UIParent,"BackdropTemplate")
		screenFrame:SetPoint("center", UIParent, "center")

		if (not DetailsFramework.IsDragonflight() and not DetailsFramework.IsNonRetailWowWithRetailAPI()) then
			screenFrame:SetMinResize (150, 40)
			screenFrame:SetMaxResize (800, 1024)
		else
			screenFrame:SetResizeBounds(150, 40, 800, 1024)
		end

		screenFrame:SetSize(Details.event_tracker.frame.width, Details.event_tracker.frame.height)

		screenFrame:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tile = true, tileSize = 16, insets = {left = 0, right = 0, top = 0, bottom = 0}})
		screenFrame:SetBackdropColor(unpack(Details.event_tracker.frame.backdrop_color))
		screenFrame:EnableMouse(true)
		screenFrame:SetMovable(true)
		screenFrame:SetResizable(true)
		screenFrame:SetClampedToScreen(true)

		local LibWindow = LibStub("LibWindow-1.1")
		LibWindow.RegisterConfig(screenFrame, Details.event_tracker.frame)
		LibWindow.MakeDraggable(screenFrame)
		LibWindow.RestorePosition(screenFrame)

	--> two resizers
		local leftResize, rightResize = DF:CreateResizeGrips(screenFrame)

		leftResize:SetScript("OnMouseDown", function(self)
			if (not screenFrame.resizing and not Details.event_tracker.frame.locked) then
				screenFrame.resizing = true
				screenFrame:StartSizing("bottomleft")
			end
		end)
		leftResize:SetScript("OnMouseUp", function(self)
			if (screenFrame.resizing) then
				screenFrame.resizing = false
				screenFrame:StopMovingOrSizing()
				Details.event_tracker.frame.width = screenFrame:GetWidth()
				Details.event_tracker.frame.height = screenFrame:GetHeight()
			end
		end)
		rightResize:SetScript("OnMouseDown", function(self)
			if (not screenFrame.resizing and not Details.event_tracker.frame.locked) then
				screenFrame.resizing = true
				screenFrame:StartSizing("bottomright")
			end
		end)
		rightResize:SetScript("OnMouseUp", function(self)
			if (screenFrame.resizing) then
				screenFrame.resizing = false
				screenFrame:StopMovingOrSizing()
				Details.event_tracker.frame.width = screenFrame:GetWidth()
				Details.event_tracker.frame.height = screenFrame:GetHeight()
			end
		end)

		screenFrame:SetScript("OnSizeChanged", function(self)
			--on size changed code
		end)

	--> scroll frame
		--frame config
		local scroll_line_amount = 1
		local scroll_width = 195
		local header_size = 20

		--on tick script
		local lineOnTick = function(self, deltaTime)
			--when this event occured on combat log
			local gameTime = self.GameTime

			--calculate how much time elapsed since the event got triggered
			local elapsedTime = GetTime() - gameTime

			--set the bar animation
			local animationPercent = min (elapsedTime, 1)
			self.Statusbar:SetValue(animationPercent)

			--set the spark location
			if (animationPercent < 1) then
				self.Spark:SetPoint("left", self, "left", (self:GetWidth() * animationPercent) - 10, 0)
				if (not self.Spark:IsShown()) then
					self.Spark:Show()
				end
			else
				if (self.Spark:IsShown()) then
					self.Spark:Hide()
				end
			end
		end

		--create a line on the scroll frame
		local scroll_createline = function(self, index)
			local line = CreateFrame("frame", "$parentLine" .. index, self,"BackdropTemplate")
			line:EnableMouse(false)
			line.Index = index --hack to not trigger error on UpdateWorldTrackerLines since Index is set after this function is ran

			--set its backdrop
			line:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tile = true, tileSize = 16, insets = {left = 0, right = 0, top = 0, bottom = 0}})
			--line:SetBackdropColor(1, 1, 1, 0.75)

			--statusbar
			local statusbar = CreateFrame("statusbar", "$parentStatusBar", line,"BackdropTemplate")
			statusbar:SetAllPoints()
			local statusbartexture = statusbar:CreateTexture(nil, "border")
			statusbar:SetStatusBarTexture(statusbartexture)
			statusbar:SetMinMaxValues(0, 1)
			statusbar:SetValue(0)

			local statusbarspark = statusbar:CreateTexture(nil, "artwork")
			statusbarspark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
			statusbarspark:SetSize(16, 30)
			statusbarspark:SetBlendMode("ADD")
			statusbarspark:Hide()

			--create the icon textures and texts - they are all statusbar childs
			local lefticon = statusbar:CreateTexture("$parentLeftIcon", "overlay")
			lefticon:SetPoint("left", line, "left", 0, 0)

			local righticon = statusbar:CreateTexture("$parentRightIcon", "overlay")
			righticon:SetPoint("right", line, "right", 0, 0)

			local lefttext = statusbar:CreateFontString("$parentLeftText", "overlay", "GameFontNormal")
			DF:SetFontSize(lefttext, 9)
			lefttext:SetPoint("left", lefticon, "right", 2, 0)
			lefttext.__languageId = "enUS"

			local righttext = statusbar:CreateFontString("$parentRightText", "overlay", "GameFontNormal")
			DF:SetFontSize(righttext, 9)
			righttext:SetPoint("right", righticon, "left", -2, 0)

			lefttext:SetJustifyH("left")
			righttext:SetJustifyH("right")

			local actionicon = statusbar:CreateTexture("$parentRightIcon", "overlay")
			actionicon:SetPoint("center", line, "center")

			--set members
			line.LeftIcon = lefticon
			line.RightIcon = righticon
			line.LeftText = lefttext
			line.RightText = righttext
			line.Statusbar = statusbar
			line.StatusbarTexture = statusbartexture
			line.Spark = statusbarspark
			line.ActionIcon = actionicon

			--set some parameters
			Details:UpdateWorldTrackerLines (line)

			--set scripts
			line:SetScript("OnUpdate", lineOnTick)

			return line
		end

		--some consts to help work with indexes
		local SPELLTYPE_COOLDOWN = "cooldown"
		local SPELLTYPE_INTERRUPT = "interrupt"
		local SPELLTYPE_OFFENSIVE = "offensive"
		local SPELLTYPE_CROWDCONTROL = "crowdcontrol"

		local ABILITYTABLE_SPELLTYPE = 1
		local ABILITYTABLE_SPELLID = 2
		local ABILITYTABLE_CASTERNAME = 3
		local ABILITYTABLE_TARGETNAME = 4
		local ABILITYTABLE_TIME = 5
		local ABILITYTABLE_EXTRASPELLID = 6
		local ABILITYTABLE_GAMETIME = 7
		local ABILITYTABLE_CASTERSERIAL = 8
		local ABILITYTABLE_ISENEMY = 9
		local ABILITYTABLE_TARGETSERIAL = 10

		local get_spec_or_class = function(serial, unitName)
			local class
			local spec = Details.cached_specs [serial]
			if (not spec) then
				local _, engClass = UnitClass(unitName)
				if (engClass) then
					class = engClass
				else
					local locClass, engClass, locRace, engRace, gender = GetPlayerInfoByGUID (serial)
					if (engClass) then
						class = engClass
					end
				end
			end

			return spec, class
		end

		local get_player_icon = function(spec, class)
			if (spec) then
				return [[Interface\AddOns\Details\images\spec_icons_normal]], unpack(Details.class_specs_coords [spec])
			elseif (class) then
				return [[Interface\AddOns\Details\images\classes_small]], unpack(Details.class_coords [class])
			else
				return [[Interface\AddOns\Details\images\classes_plus]], 0.50390625, 0.62890625, 0, 0.125
			end
		end

		local add_role_and_class_color = function(unitName, unitSerial)
			--get the actor object
			local actor = Details.tabela_vigente[1]:GetActor(unitName)

			if (actor) then
				--remove realm name
				unitName = Details:GetOnlyName(unitName)

				local class, spec, role = actor.classe, actor.spec, actor.role
				if (not class) then
					spec, class = get_spec_or_class (unitSerial, unitName)
				end

				--add the class color
				if (Details.player_class [class]) then
					--is a player, add the class color
					unitName = Details:AddColorString (unitName, class)
				end

				--add the role icon
				if (role ~= "NONE") then
					--have a role
					unitName = Details:AddRoleIcon (unitName, role, Details.event_tracker.line_height)
				end

			else
				local spec, class = get_spec_or_class (unitSerial, unitName)
				unitName = Details:GetOnlyName(unitName)

				if (class) then
					--add the class color
					if (Details.player_class [class]) then
						--is a player, add the class color
						unitName = Details:AddColorString (unitName, class)
					end
				end
			end

			return unitName
		end

		local get_text_size = function()
			local iconsSpace = Details.event_tracker.line_height * 3
			local textSpace = 4
			local saveSpace = 14

			local availableSpace = (screenFrame:GetWidth() - iconsSpace - textSpace - saveSpace) / 2

			return availableSpace
		end

		local shrink_string = function(fontstring, size)
			local text = fontstring:GetText()
			local loops = 20
			while (fontstring:GetStringWidth() > size and loops > 0) do
				text = strsub (text, 1, #text-1)
				fontstring:SetText(text)
				loops = loops - 1
			end

			return fontstring
		end

		--refresh the scroll frame
		local scroll_refresh = function(self, data, offset, total_lines)

			local textSize = get_text_size()

			for i = 1, total_lines do
				local index = i + offset
				local ability = data [index]

				if (ability) then
					local line = self:GetLine (i)

					local spec, class = get_spec_or_class (ability [ABILITYTABLE_CASTERSERIAL], ability [ABILITYTABLE_CASTERNAME])
					local texture, L, R, T, B = get_player_icon (spec, class)
					line.LeftIcon:SetTexture(texture)
					line.LeftIcon:SetTexCoord(L, R, T, B)

					local sourceName = ability[ABILITYTABLE_CASTERNAME]
					--[=[language system test
					if (math.random(3) == 2) then
						sourceName = "Снизуслева"

					elseif (math.random(3) == 3) then
						sourceName = "質下方的材質"

					elseif (math.random(4) == 1) then
						sourceName = "주문 별 받은 피해"
					end
					--]=]

					local sourceNameNoRealm = Details:GetOnlyName(sourceName)

					--need to use the language system from details framework to detect which language is being used
					local languageId = DF.Language.DetectLanguageId(sourceNameNoRealm)
					--print("lenaguage detected:", languageId, sourceNameNoRealm)

					if (languageId ~= line.LeftText.__languageId) then
						--get a font to use with this language
						local fontPath = DF.Language.GetFontForLanguageID(languageId)
						if (fontPath) then
							if (languageId == "enUS") then
								DF:SetFontFace(line.LeftText, Details.event_tracker.font_face)
							else
								DF:SetFontFace(line.LeftText, fontPath)
							end
							line.LeftText.__languageId = languageId
						end
					end

					line.LeftText:SetText(sourceNameNoRealm)

					if (ability [ABILITYTABLE_ISENEMY]) then
						line:SetBackdropColor(1, .3, .3, 0.5)
					else
						line:SetBackdropColor(1, 1, 1, 0.5)
					end

					if (ability [ABILITYTABLE_SPELLTYPE] == SPELLTYPE_COOLDOWN) then
						local spellName, _, spellIcon = GetSpellInfo(ability [ABILITYTABLE_SPELLID])
						line.RightIcon:SetTexture(spellIcon)
						line.RightIcon:SetTexCoord(.06, .94, .06, .94)

						local targetName = ability [ABILITYTABLE_TARGETNAME]
						if (targetName) then
							local targetSerial = ability [ABILITYTABLE_TARGETSERIAL]
							targetName = add_role_and_class_color (targetName, targetSerial)
						end

						line.RightText:SetText(targetName or spellName)

						line.ActionIcon:SetTexture([[Interface\AddOns\Details\images\event_tracker_icons]])
						line.ActionIcon:SetTexCoord(0, 0.125, 0, 1)

					elseif (ability [ABILITYTABLE_SPELLTYPE] == SPELLTYPE_OFFENSIVE) then
						local spellName, _, spellIcon = GetSpellInfo(ability [ABILITYTABLE_SPELLID])
						line.RightIcon:SetTexture(spellIcon)
						line.RightIcon:SetTexCoord(.06, .94, .06, .94)
						line.RightText:SetText(spellName)

						line.ActionIcon:SetTexture([[Interface\AddOns\Details\images\event_tracker_icons]])
						line.ActionIcon:SetTexCoord(0.127, 0.25, 0, 1)

					elseif (ability [ABILITYTABLE_SPELLTYPE] == SPELLTYPE_INTERRUPT) then
						local spellNameInterrupted, _, spellIconInterrupted = GetSpellInfo(ability [ABILITYTABLE_EXTRASPELLID])
						line.RightIcon:SetTexture(spellIconInterrupted)
						line.RightIcon:SetTexCoord(.06, .94, .06, .94)
						line.RightText:SetText(spellNameInterrupted)

						line.ActionIcon:SetTexture([[Interface\AddOns\Details\images\event_tracker_icons]])
						line.ActionIcon:SetTexCoord(0.251, 0.375, 0, 1)

					elseif (ability [ABILITYTABLE_SPELLTYPE] == SPELLTYPE_CROWDCONTROL) then
						local spellName, _, spellIcon = GetSpellInfo(ability [ABILITYTABLE_SPELLID])
						line.RightIcon:SetTexture(spellIcon)
						line.RightIcon:SetTexCoord(.06, .94, .06, .94)

						local targetName = ability [ABILITYTABLE_TARGETNAME]
						if (targetName) then
							local targetSerial = ability [ABILITYTABLE_TARGETSERIAL]
							targetName = add_role_and_class_color (targetName, targetSerial)
						end

						line.RightText:SetText(targetName or spellName or "")

						line.ActionIcon:SetTexture([[Interface\AddOns\Details\images\event_tracker_icons]])
						line.ActionIcon:SetTexCoord(0.376, 0.5, 0, 1)

					end

					shrink_string (line.LeftText, textSize)
					shrink_string (line.RightText, textSize)

					--set when the ability was registered on combat log
					line.GameTime = ability [ABILITYTABLE_GAMETIME]
					line:Show()
				end
			end
		end

		--title text
		local TitleString = screenFrame:CreateFontString(nil, "overlay", "GameFontNormal")
		TitleString:SetPoint("top", screenFrame, "top", 0, -3)
		TitleString:SetText("Details!: Event Tracker")
		local TitleBackground = screenFrame:CreateTexture(nil, "artwork")
		TitleBackground:SetTexture([[Interface\Tooltips\UI-Tooltip-Background]])
		TitleBackground:SetVertexColor(.1, .1, .1, .9)
		TitleBackground:SetPoint("topleft", screenFrame, "topleft")
		TitleBackground:SetPoint("topright", screenFrame, "topright")
		TitleBackground:SetHeight(header_size)

		--table with spells showing on the scroll frame
		local CurrentShowing = {}

		--scrollframe
		local scrollframe = DF:CreateScrollBox (screenFrame, "$parentScrollFrame", scroll_refresh, CurrentShowing, scroll_width, 400, scroll_line_amount, Details.event_tracker.line_height, scroll_createline, true, true)
		scrollframe:SetPoint("topleft", screenFrame, "topleft", 0, -header_size)
		scrollframe:SetPoint("topright", screenFrame, "topright", 0, -header_size)
		scrollframe:SetPoint("bottomleft", screenFrame, "bottomleft", 0, 0)
		scrollframe:SetPoint("bottomright", screenFrame, "bottomright", 0, 0)

		--update line - used by 'UpdateWorldTrackerLines' function
		local update_line = function(line)

			--get the line index
			local index = line.Index

			--update left text
			DF:SetFontColor(line.LeftText, Details.event_tracker.font_color)
			DF:SetFontFace (line.LeftText, Details.event_tracker.font_face)
			DF:SetFontSize(line.LeftText, Details.event_tracker.font_size)
			DF:SetFontOutline (line.LeftText, Details.event_tracker.font_shadow)

			--update right text
			DF:SetFontColor(line.RightText, Details.event_tracker.font_color)
			DF:SetFontFace (line.RightText, Details.event_tracker.font_face)
			DF:SetFontSize(line.RightText, Details.event_tracker.font_size)
			DF:SetFontOutline (line.RightText, Details.event_tracker.font_shadow)

			--adjust where the line is anchored
			line:SetPoint("topleft", line:GetParent(), "topleft", 1, -0.5 -((index-1)*(Details.event_tracker.line_height+1)))
			line:SetPoint("topright", line:GetParent(), "topright", -1, -0.5 -((index-1)*(Details.event_tracker.line_height+1)))

			--set its height
			line:SetHeight(Details.event_tracker.line_height)

			--set texture
			local texture = SharedMedia:Fetch ("statusbar", Details.event_tracker.line_texture)
			line.StatusbarTexture:SetTexture(texture)
			line.StatusbarTexture:SetVertexColor(unpack(Details.event_tracker.line_color))

			--set icon size
			line.LeftIcon:SetSize(Details.event_tracker.line_height, Details.event_tracker.line_height)
			line.RightIcon:SetSize(Details.event_tracker.line_height, Details.event_tracker.line_height)
			line.ActionIcon:SetSize(Details.event_tracker.line_height-4, Details.event_tracker.line_height-4)
			line.ActionIcon:SetAlpha(0.65)
		end

		-- /run _detalhes.event_tracker.font_shadow = 24
		-- /run _detalhes:UpdateWorldTrackerLines()

		function Details:UpdateWorldTrackerLines (line)
			--don't run if the featured hasn't loaded
			if (not screenFrame) then
				return
			end

			if (line) then
				update_line (line)
			else
				--update all lines
				for index, line in ipairs(scrollframe:GetFrames()) do
					update_line (line)
				end
				scrollframe:SetFramesHeight (Details.event_tracker.line_height)
				scrollframe:Refresh()
			end
		end

		function Details:UpdateEventTrackerFrame()
			--don't run if the featured hasn't loaded
			if (not screenFrame) then
				return
			end

			screenFrame:SetSize(Details.event_tracker.frame.width, Details.event_tracker.frame.height)
			LibWindow.RegisterConfig(screenFrame, Details.event_tracker.frame)
			LibWindow.RestorePosition(screenFrame)
			scrollframe:OnSizeChanged()

			if (Details.event_tracker.frame.locked) then
				screenFrame:EnableMouse(false)
				leftResize:Hide()
				rightResize:Hide()
			else
				screenFrame:EnableMouse(true)
				leftResize:Show()
				rightResize:Show()
			end

			if (Details.event_tracker.frame.show_title) then
				TitleString:Show()
				TitleBackground:Show()
				scrollframe:SetPoint("topleft", screenFrame, "topleft", 0, -header_size)
				scrollframe:SetPoint("topright", screenFrame, "topright", 0, -header_size)
			else
				TitleString:Hide()
				TitleBackground:Hide()
				scrollframe:SetPoint("topleft", screenFrame, "topleft", 0, 0)
				scrollframe:SetPoint("topright", screenFrame, "topright", 0, 0)
			end

			screenFrame:SetBackdropColor(unpack(Details.event_tracker.frame.backdrop_color))
			scrollframe.__background:SetVertexColor(unpack(Details.event_tracker.frame.backdrop_color))

			screenFrame:SetFrameStrata(Details.event_tracker.frame.strata)

			Details:UpdateWorldTrackerLines()
			scrollframe:Refresh()
		end

		--create the first line
		for i = 1, 1 do
			scrollframe:CreateLine (scroll_createline)
		end
		screenFrame.scrollframe = scrollframe
		scrollframe:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16})
		scrollframe:SetBackdropColor(0, 0, 0, 0)

		local combatLog = CreateFrame("frame")
		combatLog:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		local OBJECT_TYPE_PLAYER = 0x00000400
		local OBJECT_TYPE_ENEMY = 0x00000040

		--combat parser
		local is_player = function(flag)
			if (not flag) then
				return false
			end
			return bit.band(flag, OBJECT_TYPE_PLAYER) ~= 0
		end
		local is_enemy = function(flag)
			if (not flag) then
				return false
			end
			return bit.band(flag, OBJECT_TYPE_ENEMY) ~= 0
		end

		local defensiveCDType = {
			[2] = true,
			[3] = true,
			[4] = true,
		}

		combatLog:SetScript("OnEvent", function(self, event)

			local time, token, hidding, caster_serial, caster_name, caster_flags, caster_flags2, target_serial, target_name, target_flags, target_flags2, spellid, spellname, spelltype, extraSpellID, extraSpellName, extraSchool = CombatLogGetCurrentEventInfo()
			local added = false

			--get the spell info from the Open Raid Lib
			local spellInfo = LIB_OPEN_RAID_COOLDOWNS_INFO[spellid]

			--defensive cooldown
			if (token == "SPELL_CAST_SUCCESS" and (spellInfo and defensiveCDType[spellInfo.type]) and is_player (caster_flags)) then
				table.insert(CurrentShowing, 1, {SPELLTYPE_COOLDOWN, spellid, caster_name, target_name, time, false, GetTime(), caster_serial, is_enemy (caster_flags), target_serial})
				added = true

			--offensive cooldown
			elseif (token == "SPELL_CAST_SUCCESS" and (spellInfo and spellInfo.type == 1 and spellInfo.cooldown and spellInfo.cooldown >= 90) and is_player (caster_flags)) then
				table.insert(CurrentShowing, 1, {SPELLTYPE_OFFENSIVE, spellid, caster_name, target_name, time, false, GetTime(), caster_serial, is_enemy (caster_flags), target_serial})
				added = true

			--crowd control
			elseif (token == "SPELL_CAST_SUCCESS" and spellInfo and spellInfo.type == 8) then
				--check if isnt a pet
				if (caster_flags and is_player(caster_flags)) then
					--the target is a player
					if (Details.event_tracker.show_crowdcontrol_pvp) then
						if (Details.zone_type == "arena" or Details.zone_type  == "pvp" or Details.zone_type  == "none") then
							table.insert(CurrentShowing, 1, {SPELLTYPE_CROWDCONTROL, spellid, caster_name, target_name, time, false, GetTime(), caster_serial, is_enemy (caster_flags), target_serial})
							added = true
						end
					end

					if (Details.event_tracker.show_crowdcontrol_pvm) then
						if (Details.zone_type == "party" or Details.zone_type  == "raid") then
							table.insert(CurrentShowing, 1, {SPELLTYPE_CROWDCONTROL, spellid, caster_name, target_name, time, false, GetTime(), caster_serial, is_enemy (caster_flags), target_serial})
							added = true
						end
					end
				end

			--spell interrupt
			elseif (token == "SPELL_INTERRUPT") then
				if (caster_flags and is_player (caster_flags)) then
					table.insert(CurrentShowing, 1, {SPELLTYPE_INTERRUPT, spellid, caster_name, target_name, time, extraSpellID, GetTime(), caster_serial, is_enemy (caster_flags), target_serial})
					added = true
				end
			end

			if (added) then
				local amountOfLines = scrollframe:GetNumFramesShown()
				local amountToShow = #CurrentShowing

				if (amountToShow > amountOfLines) then
					tremove(CurrentShowing, amountToShow)
				end
				scrollframe:Refresh()
			end

		end)

	Details.Broadcaster_EventTrackerLoaded = true
	Details.Broadcaster_EventTrackerFrame = screenFrame
	screenFrame:Hide()
end
