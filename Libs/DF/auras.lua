
local DF = _G ["DetailsFramework"]
if (not DF or not DetailsFrameworkCanLoad) then
	return 
end

local _
local tinsert = tinsert
local GetSpellInfo = GetSpellInfo
local lower = string.lower
local GetSpellBookItemInfo = GetSpellBookItemInfo

local cleanfunction = function() end

do
	local metaPrototype = {
		WidgetType = "aura_tracker",
		SetHook = DF.SetHook,
		RunHooksForWidget = DF.RunHooksForWidget,
	}

	_G [DF.GlobalWidgetControlNames ["aura_tracker"]] = _G [DF.GlobalWidgetControlNames ["aura_tracker"]] or metaPrototype
end

local AuraTrackerMetaFunctions = _G [DF.GlobalWidgetControlNames ["aura_tracker"]]

--create panels
local on_profile_changed = function (self, newdb)
	self.db = newdb
	self.tracking_method:Select (newdb.aura_tracker.track_method)
	
	--automatic
	self.buff_ignored:SetData (newdb.aura_tracker.buff_banned)
	self.debuff_ignored:SetData (newdb.aura_tracker.debuff_banned)
	self.buff_available:Refresh()
	self.buff_ignored:Refresh()
	self.debuff_available:Refresh()
	self.debuff_ignored:Refresh()
	
	--manual
	self.buffs_added:SetData (newdb.aura_tracker.buff)
	self.debuffs_added:SetData (newdb.aura_tracker.debuff)
	self.buffs_added:Refresh()
	self.debuffs_added:Refresh()
	
	--method
	if (newdb.aura_tracker.track_method == 0x1) then
		self.f_auto:Show()
		self.f_manual:Hide()
	elseif (newdb.aura_tracker.track_method == 0x2) then
		self.f_auto:Hide()
		self.f_manual:Show()
	end
end

local aura_panel_defaultoptions = {
	height = 400, 
	row_height = 16,
	width = 230,
}
function DF:CreateAuraConfigPanel (parent, name, db, method_change_callback, options)

	local options_text_template = DF:GetTemplate ("font", "OPTIONS_FONT_TEMPLATE")
	local options_dropdown_template = DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
	local options_switch_template = DF:GetTemplate ("switch", "OPTIONS_CHECKBOX_TEMPLATE")
	local options_slider_template = DF:GetTemplate ("slider", "OPTIONS_SLIDER_TEMPLATE")
	local options_button_template = DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE")
	
	local f = CreateFrame ("frame", name, parent)
	f.db = db
	f.OnProfileChanged = on_profile_changed
	options = options or {}
	self.table.deploy (options, aura_panel_defaultoptions)
	
	local f_auto = CreateFrame ("frame", "$parent_Automatic", f)
	local f_manual = CreateFrame ("frame", "$parent_Manual", f)
	f_auto:SetPoint ("topleft", f, "topleft", 0, -24)
	f_manual:SetPoint ("topleft", f, "topleft", 0, -24)
	f_auto:SetSize (600, 600)
	f_manual:SetSize (600, 600)
	f.f_auto = f_auto
	f.f_manual = f_manual
	
	local on_select_tracking_option = function (_, _, method)
		f.db.aura_tracker.track_method = method
		if (method_change_callback) then
			method_change_callback (self, method)
		end

		if (method == 0x1) then
			f_auto:Show()
			f_manual:Hide()
			f.desc_label.text = "Auras are being tracked automatically, the addon controls what to show. You may entry an aura to ignore.\nCast spells to fill the Buff and Buff available boxes."
			f.desc_label:SetPoint ("topleft", f.tracking_method, "topright", 10, 8)
		elseif (method == 0x2) then
			f_auto:Hide()
			f_manual:Show()
			f.desc_label.text = "Auras are being tracked manually, the addon only check for auras you entered below."
			f.desc_label:SetPoint ("topleft", f.tracking_method, "topright", 10, 1)
		end
	end
	
	local tracking_options = function()
		return {
			{label = "Automatic", value = 0x1, onclick = on_select_tracking_option, desc = "Show all your auras by default, you can exclude those you don't want to show."},
			{label = "Manual", value = 0x2, onclick = on_select_tracking_option, desc = "Do not show any aura by default, you need to manually add each aura you want to track."},
		}
	end
	
	local tracking_method_label = self:CreateLabel (f, "Tracking Aura Method:", 12, "orange")
	local tracking_method = self:CreateDropDown (f, tracking_options, f.db.aura_tracker.track_method, 120, 20, "dropdown_tracking_method", _, self:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
	
	tracking_method_label:SetPoint ("topleft", f, "topleft", 10, -10)
	tracking_method:SetPoint ("left", tracking_method_label, "right", 2, 0)
	tracking_method:SetFrameStrata ("tooltip")
	tracking_method.tooltip = "Choose which aura tracking method you want to use."
	f.tracking_method = tracking_method
	
	f.desc_label = self:CreateLabel (f, "", 10, "silver")
	f.desc_label:SetSize (400, 40)
	f.desc_label:SetPoint ("topleft", tracking_method, "topright", 10, 8)
	f.desc_label:SetJustifyV ("top")

--------automatic

	local ALL_BUFFS = {}
	local ALL_DEBUFFS = {}
	
	local width, height, row_height = options.width, options.height, options.row_height
	
	local buff_ignored = self:CreateSimpleListBox (f_auto, "$parentBuffIgnored", "Buffs Ignored", "The list is empty, select a spell from the buff list to ignore it.", f.db.aura_tracker.buff_banned, 
	function (spellid)
		f.db.aura_tracker.buff_banned [spellid] = nil;
	end, 
	{
		icon = function(spellid) return select (3, GetSpellInfo (spellid)) end, 
		text = function(spellid) return select (1, GetSpellInfo (spellid)) end,
		height = height, 
		row_height = row_height,
		width = width, 
		onenter = function(self, capsule, value) GameTooltip:SetOwner (self, "ANCHOR_RIGHT"); GameTooltip:SetSpellByID(value); GameTooltip:AddLine (" "); GameTooltip:AddLine ("Click to un-ignore this aura", .2, 1, .2); GameTooltip:Show() end, 
	})

	local buff_available = self:CreateSimpleListBox (f_auto, "$parentBuffAvailable", "Buffs Available", "The list is empty, cast spells to fill it", ALL_BUFFS, function (spellid)
		f.db.aura_tracker.buff_banned [spellid] = true; buff_ignored:Refresh()
	end, 
	{
		icon = function(spellid) return select (3, GetSpellInfo (spellid)) end, 
		text = function(spellid) return select (1, GetSpellInfo (spellid)) end,
		height = height, 
		row_height = row_height,
		width = width, 
		onenter = function(self, capsule, value) GameTooltip:SetOwner (self, "ANCHOR_RIGHT"); GameTooltip:SetSpellByID(value); GameTooltip:AddLine (" "); GameTooltip:AddLine ("Click to ignore this aura", .2, 1, .2); GameTooltip:Show() end, 
	})
	
	local debuff_ignored = self:CreateSimpleListBox (f_auto, "$parentDebuffIgnored", "Debuffs Ignored", "The list is empty, select a spell from the debuff list to ignore it.", f.db.aura_tracker.debuff_banned, function (spellid)
		f.db.aura_tracker.debuff_banned [spellid] = nil;
	end, 
	{
		icon = function(spellid) return select (3, GetSpellInfo (spellid)) end, 
		text = function(spellid) return select (1, GetSpellInfo (spellid)) end,
		height = height, 
		row_height = row_height,
		width = width, 
		onenter = function(self, capsule, value) GameTooltip:SetOwner (self, "ANCHOR_RIGHT"); GameTooltip:SetSpellByID(value); GameTooltip:AddLine (" "); GameTooltip:AddLine ("Click to un-ignore this aura", .2, 1, .2); GameTooltip:Show() end, 
	})
	
	local debuff_available = self:CreateSimpleListBox (f_auto, "$parentDebuffAvailable", "Debuffs Available", "The list is empty, cast spells to fill it", ALL_DEBUFFS, function (spellid)
		f.db.aura_tracker.debuff_banned [spellid] = true; debuff_ignored:Refresh()
	end, {
		icon = function(spellid) return select (3, GetSpellInfo (spellid)) end, 
		text = function(spellid) return select (1, GetSpellInfo (spellid)) end,
		height = height, 
		row_height = row_height,
		width = width, 
		onenter = function(self, capsule, value) GameTooltip:SetOwner (self, "ANCHOR_RIGHT"); GameTooltip:SetSpellByID(value); GameTooltip:AddLine (" "); GameTooltip:AddLine ("Click to ignore this aura", .2, 1, .2); GameTooltip:Show() end, 
	})
	
	--como ira preencher ela no inicio e como ficara o lance dos profiles

	local y = -40
	buff_available:SetPoint ("topleft", f_auto, "topleft", 0, y)
	buff_ignored:SetPoint ("topleft", f_auto, "topleft", 6 + width, y)
	debuff_available:SetPoint ("topleft", f_auto, "topleft", 12 + (width*2), y)
	debuff_ignored:SetPoint ("topleft", f_auto, "topleft", 18 + (width*3), y)
	
	f.buff_available = buff_available
	f.buff_ignored = buff_ignored
	f.debuff_available = debuff_available
	f.debuff_ignored = debuff_ignored

	local readCombatLog = CreateFrame ("frame", nil, f_auto)
	readCombatLog:SetScript ("OnEvent", function (self, event, time, token, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellid, spellname, spellschool, auraType, amount)
		if (auraType == "BUFF" and sourceGUID == readCombatLog.playerGUID) then
			if (not ALL_BUFFS [spellid]) then
				ALL_BUFFS [spellid] = true
				buff_available:Refresh()
			end
		elseif (auraType == "DEBUFF" and sourceGUID == readCombatLog.playerGUID) then
			if (not ALL_DEBUFFS [spellid]) then
				ALL_DEBUFFS [spellid] = true
				debuff_available:Refresh()
			end
		end
	end)
	
	f_auto:SetScript ("OnShow", function()
		for i = 1, BUFF_MAX_DISPLAY do
			local name, rank, texture, count, debuffType, duration, expirationTime, caster, _, nameplateShowPersonal, spellId, _, _, _, nameplateShowAll = UnitAura ("player", i, "HELPFUL")
			if (name) then
				ALL_BUFFS [spellId] = true
			end
			local name, rank, texture, count, debuffType, duration, expirationTime, caster, _, nameplateShowPersonal, spellId, _, _, _, nameplateShowAll = UnitAura ("player", i, "HARMFUL")
			if (name) then
				ALL_DEBUFFS [spellId] = true
			end
		end
		
		buff_available:Refresh()
		buff_ignored:Refresh()
		debuff_available:Refresh()
		debuff_ignored:Refresh()
		
		readCombatLog.playerGUID = UnitGUID ("player")
		readCombatLog:RegisterEvent ("COMBAT_LOG_EVENT_UNFILTERED")
	end)
	f_auto:SetScript ("OnHide", function()
		readCombatLog:UnregisterEvent ("COMBAT_LOG_EVENT_UNFILTERED")
	end)
	
	--show the frame selecton on the f.db
	on_select_tracking_option (_, _, f.db.aura_tracker.track_method)
	
-------manual

	--> build the two aura scrolls for buff and debuff
	
	local scroll_width = width
	local scroll_height = height
	local scroll_lines = 15
	local scroll_line_height = 20
	
	local backdrop_color = {.8, .8, .8, 0.2}
	local backdrop_color_on_enter = {.8, .8, .8, 0.4}
	
	local line_onenter = function (self)
		self:SetBackdropColor (unpack (backdrop_color_on_enter))
		local spellid = select (7, GetSpellInfo (self.value))
		if (spellid) then
			GameTooltip:SetOwner (self, "ANCHOR_RIGHT");
			GameTooltip:SetSpellByID (spellid)
			GameTooltip:AddLine (" ")
			GameTooltip:AddLine ("Click to untrack this aura", .2, 1, .2)
			GameTooltip:Show()
		end
	end
	
	local line_onleave = function (self)
		self:SetBackdropColor (unpack (backdrop_color))
		GameTooltip:Hide()
	end
	local line_onclick = function (self)
		local spell = self.value
		local data = self:GetParent():GetData()
		
		for i = 1, #data do
			if (data[i] == spell) then
				tremove (data, i)
				break
			end
		end
		
		self:GetParent():Refresh()
	end
	
	local scroll_createline = function (self, index)
		local line = CreateFrame ("button", "$parentLine" .. index, self)
		line:SetPoint ("topleft", self, "topleft", 0, -((index-1)*(scroll_line_height+1)))
		line:SetSize (scroll_width, scroll_line_height)
		line:SetScript ("OnEnter", line_onenter)
		line:SetScript ("OnLeave", line_onleave)
		line:SetScript ("OnClick", line_onclick)
		
		line:SetBackdrop ({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
		line:SetBackdropColor (unpack (backdrop_color))
		
		local icon = line:CreateTexture ("$parentIcon", "overlay")
		icon:SetSize (scroll_line_height, scroll_line_height)
		local name = line:CreateFontString ("$parentName", "overlay", "GameFontNormal")
		icon:SetPoint ("left", line, "left", 2, 0)
		name:SetPoint ("left", icon, "right", 2, 0)
		line.icon = icon
		line.name = name
		
		return line
	end

	local scroll_refresh = function (self, data, offset, total_lines)
		for i = 1, total_lines do
			local index = i + offset
			local aura = data [index]
			if (aura) then
				local line = self:GetLine (i)
				local name, _, icon = GetSpellInfo (aura)
				line.value = aura
				if (name) then
					line.name:SetText (name)
					line.icon:SetTexture (icon)
				else
					line.name:SetText (aura)
					line.icon:SetTexture ([[Interface\InventoryItems\WoWUnknownItem01]])
				end
			end
		end
	end
	
	local buffs_added = self:CreateScrollBox (f_manual, "$parentBuffsAdded", scroll_refresh, f.db.aura_tracker.buff, scroll_width, scroll_height, scroll_lines, scroll_line_height)
	buffs_added:SetPoint ("topleft", f_manual, "topleft", 0, y)
	buffs_added:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
	buffs_added:SetBackdropColor (0, 0, 0, 0.2)
	buffs_added:SetBackdropBorderColor (0, 0, 0, 1)
	for i = 1, scroll_lines do 
		buffs_added:CreateLine (scroll_createline)
	end
	
	local debuffs_added = self:CreateScrollBox (f_manual, "$parentDebuffsAdded", scroll_refresh, f.db.aura_tracker.debuff, scroll_width, scroll_height, scroll_lines, scroll_line_height)
	debuffs_added:SetPoint ("topleft", f_manual, "topleft", width+30, y)
	debuffs_added:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
	debuffs_added:SetBackdropColor (0, 0, 0, 0.2)
	debuffs_added:SetBackdropBorderColor (0, 0, 0, 1)
	for i = 1, scroll_lines do 
		debuffs_added:CreateLine (scroll_createline)
	end
	
	f.buffs_added = buffs_added
	f.debuffs_added = debuffs_added
	
	local buffs_added_name = DF:CreateLabel (buffs_added, "Buffs", 12, "silver")
	buffs_added_name:SetTemplate (DF:GetTemplate ("font", "OPTIONS_FONT_TEMPLATE"))
	buffs_added_name:SetPoint ("bottomleft", buffs_added, "topleft", 0, 2)
	buffs_added.Title = buffs_added_name
	local debuffs_added_name = DF:CreateLabel (debuffs_added, "Debuffs", 12, "silver")
	debuffs_added_name:SetTemplate (DF:GetTemplate ("font", "OPTIONS_FONT_TEMPLATE"))
	debuffs_added_name:SetPoint ("bottomleft", debuffs_added, "topleft", 0, 2)
	debuffs_added.Title = debuffs_added_name
	
	-->  build the text entry to type the spellname
	local new_buff_string = self:CreateLabel (f_manual, "Add Buff")
	local new_debuff_string = self:CreateLabel (f_manual, "Add Debuff")
	
	local new_buff_entry = self:CreateTextEntry (f_manual, function()end, 200, 20, "NewBuffTextBox", _, _, options_dropdown_template)
	local new_debuff_entry = self:CreateTextEntry (f_manual, function()end, 200, 20, "NewDebuffTextBox", _, _, options_dropdown_template)
	
	new_buff_entry:SetJustifyH ("left")
	new_debuff_entry:SetJustifyH ("left")
	
	DF:SetAutoCompleteWithSpells (new_buff_entry)
	DF:SetAutoCompleteWithSpells (new_debuff_entry)
	
	local add_buff_button = self:CreateButton (f_manual, function()
		local text = new_buff_entry.text
		new_buff_entry:SetText ("")
		new_buff_entry:ClearFocus()
		if (text ~= "") then
			--> check for more than one spellname
			if (text:find (";")) then
				for _, spellname in ipairs ({strsplit (";", text)}) do
					spellname = self:trim (spellname)
					if (string.len (spellname) > 0) then
						tinsert (f.db.aura_tracker.buff, spellname)
					end
				end
			else
				tinsert (f.db.aura_tracker.buff, text)
			end
			
			buffs_added:Refresh()
		end
	end, 100, 20, "Add Buff", nil, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"))
	local add_debuff_button = self:CreateButton (f_manual, function()
		local text = new_debuff_entry.text
		new_debuff_entry:SetText ("")
		new_debuff_entry:ClearFocus()
		if (text ~= "") then
			--> check for more than one spellname
			if (text:find (";")) then
				for _, spellname in ipairs ({strsplit (";", text)}) do
					spellname = self:trim (spellname)
					if (string.len (spellname) > 0) then
						tinsert (f.db.aura_tracker.debuff, spellname)
					end
				end
			else
				tinsert (f.db.aura_tracker.debuff, text)
			end
			debuffs_added:Refresh()
		end
	end, 100, 20, "Add Debuff", nil, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"))
	
	local multiple_spells_label = DF:CreateLabel (buffs_added, "You can add multiple auras at once by separating them with ';'.\nExample: Fireball; Frostbolt; Flamestrike", 10, "gray")
	multiple_spells_label:SetSize (350, 60)
	multiple_spells_label:SetJustifyV ("top")
	
	local export_box = self:CreateTextEntry (f_manual, function()end, 242, 20, "ExportAuraTextBox", _, _, options_dropdown_template)
	
	local export_buff_button = self:CreateButton (f_manual, function()
		local str = ""
		for _, spellname in ipairs (f.db.aura_tracker.buff) do
			str = str .. spellname .. "; "
		end
		export_box.text = str
		export_box:SetFocus (true)
		export_box:HighlightText()
		
	end, 120, 20, "Export Buffs", nil, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"))
	
	local export_debuff_button = self:CreateButton (f_manual, function()
		local str = ""
		for _, spellname in ipairs (f.db.aura_tracker.debuff) do
			str = str .. spellname .. "; "
		end
		export_box.text = str
		export_box:SetFocus (true)
		export_box:HighlightText()
		
	end, 120, 20, "Export Debuffs", nil, nil, nil, nil, nil, nil, DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE"))
	
	multiple_spells_label:SetPoint ("topleft", f_manual, "topleft", 480, -120)
	
	export_buff_button:SetPoint ("topleft", f_manual, "topleft", 480, -160)
	export_debuff_button:SetPoint ("left",export_buff_button, "right", 2, 0)
	export_box:SetPoint ("topleft", f_manual, "topleft", 480, -185)
	
	new_buff_string:SetPoint ("topleft", f_manual, "topleft", 480, -40)
	new_buff_entry:SetPoint ("topleft", new_buff_string, "bottomleft", 0, -2)
	add_buff_button:SetPoint ("left", new_buff_entry, "right", 2, 0)
	add_buff_button.tooltip = "Add the aura to be tracked.\n\nClick an aura on the list to remove it."
	
	new_debuff_string:SetPoint ("topleft", f_manual, "topleft", 480, -80)
	new_debuff_entry:SetPoint ("topleft", new_debuff_string, "bottomleft", 0, -2)
	add_debuff_button:SetPoint ("left", new_debuff_entry, "right", 2, 0)
	add_debuff_button.tooltip = "Add the aura to be tracked.\n\nClick an aura on the list to remove it."
	
	buffs_added:Refresh()
	debuffs_added:Refresh()
	
	return f
end


function DF:GetAllPlayerSpells (include_lower_case)
	local playerSpells = {}
	local tab, tabTex, offset, numSpells = GetSpellTabInfo (2)
	for i = 1, numSpells do
		local index = offset + i
		local spellType, spellId = GetSpellBookItemInfo (index, "player")
		if (spellType == "SPELL") then
			local spellName = GetSpellInfo (spellId)
			tinsert (playerSpells, spellName)
			if (include_lower_case) then
				tinsert (playerSpells, lower (spellName))
			end
		end
	end
	return playerSpells
end

function DF:SetAutoCompleteWithSpells (textentry)
	textentry:SetHook ("OnEditFocusGained", function()
		local playerSpells = DF:GetAllPlayerSpells (true)
		textentry.WordList = playerSpells
	end)
	textentry:SetAsAutoComplete ("WordList")
end

--check for aura


-- add aura


--handle savedvariables


--remove a aura





--handle UNIT_AURA event


