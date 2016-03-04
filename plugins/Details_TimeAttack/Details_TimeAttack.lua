local AceLocale = LibStub ("AceLocale-3.0")
local Loc = AceLocale:GetLocale ("Details_TimeAttack")

local _GetTime = GetTime --> wow api local
local _UFC = UnitAffectingCombat --> wow api local
local _IsInRaid = IsInRaid --> wow api local
local _IsInGroup = IsInGroup --> wow api local
local _UnitAura = UnitAura --> wow api local

local _math_floor = math.floor --> lua library local
local _cstr = string.format --> lua library local

--> Create the plugin Object
local TimeAttack = _detalhes:NewPluginObject ("Details_TimeAttack")
--> Main Frame
local TimeAttackFrame = TimeAttack.Frame

TimeAttack:SetPluginDescription ("Special tool for measure damage within a period of time.\n\nYou can save the attempts and try again other time when you got new gear or changed the specialization.")

local function CreatePluginFrames()

	--> catch Details! main object
	local _detalhes = _G._detalhes
	local DetailsFrameWork = _detalhes.gump
	local instance --> shortcut for details instance wich are holding solo plugins
	local GameCooltip = GameCooltip
	
	TimeAttack.try = 1
	
	--> OnEvent Table
	function TimeAttack:OnDetailsEvent (event)
		if (event == "HIDE") then --> plugin hidded, disabled
			TimeAttackFrame:SetScript ("OnUpdate", nil) 
			TimeAttack:Cancel()
			
		elseif (event == "SHOW") then
			instance = _detalhes.SoloTables.instancia --> update wich instance solo mode are running
			DetailsFrameWork:RegisterForDetailsMove (DetailsTimeAttackHistoryBackground, instance)
			TimeAttack:RequestRealmResults()
		
		elseif (event == "COMBAT_PLAYER_ENTER") then --> combat started
			TimeAttack:ScheduleTimer ("TimeAttackPluginStart", 2)

		elseif (event == "PLUGIN_DISABLED") then
			
		elseif (event == "PLUGIN_ENABLED") then
		
		elseif (event == "DETAILS_STARTED") then
			TimeAttack:CheckTimeAttackTutorial()
			TimeAttack.PlayerRealm = GetRealmName()
			
		end
	end
	
------------- Build TimeAttack Object ------------------------------------------------------------------------------------------------

	--> main frame and background texture
		TimeAttackFrame:SetResizable (false) --> cant resize, this is a fixed size
		TimeAttackFrame:SetWidth (300) --> need to be 300x300 to fit details window
		TimeAttackFrame:SetHeight (300) --> need to be 300x300 to fit details window
	
		local close_button = TimeAttack:CreateSoloCloseButton()
		close_button:SetPoint ("TOPRIGHT", TimeAttackFrame, "TOPRIGHT", -68, 3)
		close_button:SetSize (24, 24)
	
	--> default background picture, will hold the actor spec background, like old school talent frame
		local background = TimeAttackFrame:CreateTexture (nil, "background")
	
	--> some times the current spec isn't avaliable yet, so we try to catch 5 seconds after character logon
		function _detalhes:TimeAttackStartupBackground()
			local spec = GetSpecialization()
			if (spec) then
				local id, name, description, icon, _background, role = GetSpecializationInfo (spec)
				if (_background) then
					background:SetTexture ("Interface\\TALENTFRAME\\".._background)
				end
			end
		end
		TimeAttack:ScheduleTimer ("TimeAttackStartupBackground", 5)
	
		background:SetTexCoord (0, 1, 0, 0.705078125)
		background:SetPoint ("topleft", TimeAttackFrame, "topleft", 2, 0)
		background:SetPoint ("bottomright", TimeAttackFrame, "bottomright", -2, 0)
		background:SetVertexColor (.3, .3, .3, 1)
		background:SetDrawLayer ("background", 1)
		TimeAttack.BackgroundTex = background

	--> Time attack string
		local title = DetailsFrameWork:NewLabel (TimeAttackFrame, TimeAttackFrame, nil, "title", "Time Attack", "QuestFont_Super_Huge", _, {1, 1, 1, 1})
		title:SetPoint ("topleft", TimeAttackFrame, 5, -8)
	
	--> background glow bellow title string
		local texturetitle = TimeAttackFrame:CreateTexture (nil, "artwork")
		texturetitle:SetTexture ("Interface\\ACHIEVEMENTFRAME\\UI-Achievement-Borders")
		texturetitle:SetTexCoord (0.287109375, 1, 0.26, 0.5)
		texturetitle:SetVertexColor (1, 1, 1, .5)
		texturetitle:SetPoint ("topleft", TimeAttackFrame)
		texturetitle:SetWidth (300)
		texturetitle:SetHeight (128)
	
	--> help button
	--> after 10 logins on the character this help button will not be show any more
		if (_detalhes.tutorial.main_help_button < 10) then
			local help = DetailsFrameWork:NewHelp (TimeAttackFrame, 280, 280, 0, -20, 40, 40)
			help:SetPoint ("topright", TimeAttackFrame, "topright", 8, 9)
			help:AddHelp (300, 300, 0, 0, 138, -138, Loc ["STRING_HELP"])
			help:SetFrameLevel (TimeAttackFrame:GetFrameLevel()+2)
		end
	
	--> a dark blue image on bottom of window
		local texturedown = TimeAttackFrame:CreateTexture (nil, "artwork")
		texturedown:SetTexture ("Interface\\PetBattles\\Weather-Darkness")
		texturedown:SetTexCoord (.15, .85, 1, 0)
		texturedown:SetVertexColor (1, 1, 1, .25)
		texturedown:SetPoint ("bottomright", TimeAttackFrame)
		texturedown:SetWidth (300)
	
	--> slider
		--local TimeAmount = DetailsFrameWork:NewSlider (TimeAttackFrame, nil, "DetailsTimeAttackTimeSelect", "TimeSelect", 270, 20, 30, 330, 1, TimeAttack.db.time)
		--TimeAmount:SetPoint ("topleft", TimeAttackFrame, 15, -270)
		--TimeAmount.OnChangeHook = function (_, _, value) TimeAttack.db.time = value end
		
		local on_select_time = function (_, _, time)
			TimeAttack.db.time = time
		end
		local icon = [[Interface\Challenges\challenges-minimap-banner]]
		local textcoord = {0.2, 0.8, 0.2, 0.8}
		local time_table = {
			{value = 40, icon = icon, texcoord = textcoord, label = "40 seconds", onclick = on_select_time},
			{value = 90, icon = icon, texcoord = textcoord, label = "1 minute 30 seconds", onclick = on_select_time},
			{value = 120, icon = icon, texcoord = textcoord, label = "2 minutes", onclick = on_select_time},
			{value = 180, icon = icon, texcoord = textcoord, label = "3 minutes", onclick = on_select_time},
			{value = 300, icon = icon, texcoord = textcoord, label = "5 minutes", onclick = on_select_time},
			{value = 480, icon = icon, texcoord = textcoord, label = "8 minutes", onclick = on_select_time},
		}
		local build_time_menu = function()
			return time_table
		end
		local TimeAmount2 = DetailsFrameWork:NewDropDown (TimeAttackFrame, _, "$parentTimeDropdown", "TimeDropdown", 180, 20, build_time_menu, TimeAttack.db.time)

	--> text informing about the amount of time
		local TimeDesc = DetailsFrameWork:NewLabel (TimeAttackFrame, TimeAttackFrame, nil, "TimeDesc", "Time Amount:", "GameFontNormal")
		TimeDesc:SetPoint ("topleft", TimeAttackFrame, 10, -280)
		
		local text_size = TimeDesc:GetStringWidth()
		local TimeAmountWidth = 300 - text_size - 11 - 4 - 14
		TimeAmount2:SetWidth (TimeAmountWidth)
		
		--TimeAmount2:SetPoint ("topleft", TimeAttackFrame, 15, -270)
		TimeAmount2:SetPoint ("left", TimeDesc, "right", 4, 0)
	
	--> main time/damage/dps texts
		local clock = DetailsFrameWork:NewLabel (TimeAttackFrame, TimeAttackFrame, nil, "TIMER", "00:", "GameFontHighlightLarge")
		clock:SetPoint ("center", TimeAttackFrame, -25, -20)
		local clock2 = DetailsFrameWork:NewLabel (TimeAttackFrame, TimeAttackFrame, nil, "TIMER", "00:", "GameFontHighlightLarge")
		clock2:SetPoint ("center", TimeAttackFrame, 0, -20)
		local clock3 = DetailsFrameWork:NewLabel (TimeAttackFrame, TimeAttackFrame, nil, "TIMER", "00", "GameFontHighlightLarge")
		clock3:SetPoint ("center", TimeAttackFrame, 23, -20)
		
		local damage = DetailsFrameWork:NewLabel (TimeAttackFrame, TimeAttackFrame, nil, "DAMAGE", "00.000.000", "GameFontHighlightLarge")
		damage:SetPoint ("center", TimeAttackFrame, 0, -40)
		local persecond = DetailsFrameWork:NewLabel (TimeAttackFrame, TimeAttackFrame, nil, "DPS", "000.000", "GameFontHighlightLarge")
		persecond:SetPoint ("center", TimeAttackFrame, 0, -60)

	--> two yellow rows 
		local barraUP = TimeAttackFrame:CreateTexture (nil, "overlay")
		barraUP:SetTexture ("Interface\\TALENTFRAME\\talent-main")
		barraUP:SetWidth (300)
		barraUP:SetHeight (3)
		barraUP:SetPoint ("topleft", TimeAttackFrame, 0, -49)
		barraUP:SetTexCoord (0, 0.7890625, 0.248046875, 0.264625) 

		local barraDOWN = TimeAttackFrame:CreateTexture (nil, "overlay")
		barraDOWN:SetTexture ("Interface\\TALENTFRAME\\talent-main")
		barraDOWN:SetWidth (300)
		barraDOWN:SetHeight (3)
		barraDOWN:SetPoint ("topleft", TimeAttackFrame, 0, -148)
		barraDOWN:SetTexCoord (0, 0.7890625, 0.248046875, 0.264625) 
	
	--> background between the two yellow rows
		local bg1 = DetailsFrameWork:NewPanel (TimeAttackFrame, _, "DetailsTimeAttackHistoryBackground", _, 295, 100)
		bg1:SetBackdrop ({tile = true, tileSize = 16, bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"})
		bg1:SetBackdropColor ({.95, .95, .95, .6})
		bg1:SetPoint ("center", TimeAttackFrame, 0, 50)
		--> default panel options come with enabled gradiens, we want to disable this

	--> this is the main table wich will hold the times and labels also is a class
		local HistoryPanelObject = {
			NowShowing = 1, --> 1 for recently 2 for saved
			LabelsCreated = {},
			Recently = {},
			Hystory = TimeAttack.db.history
		}
		HistoryPanelObject.__index = HistoryPanelObject
		TimeAttack.HistoryPanelObject = HistoryPanelObject
	
	--> build the button to switch between recent times and saved times
		local displayTipes = {Loc ["STRING_RECENTLY"], Loc ["STRING_SAVED"]}
		local switchButton
		local function changedisplay (self, button, param)
			HistoryPanelObject.NowShowing = param
			HistoryPanelObject:Refresh()
			--HistoryPanelObject.NowShowing = math.abs (HistoryPanelObject.NowShowing-3)
			--switchButton.text = displayTipes [HistoryPanelObject.NowShowing]
		end
		
		switchButton = DetailsFrameWork:NewButton (TimeAttackFrame, nil, "DetailsTimeAttackSwitchButton", "switchButton", 70, 14, changedisplay, 1)
		switchButton:InstallCustomTexture (nil, nil, nil, nil, true)
		switchButton:SetPoint (227, -35)
		switchButton.text = displayTipes [HistoryPanelObject.NowShowing]
		
		local savedButton = DetailsFrameWork:NewButton (TimeAttackFrame, nil, "DetailsTimeAttackSavedButton", "SavedButton", 70, 14, changedisplay, 2)
		savedButton:InstallCustomTexture (nil, nil, nil, nil, true)
		savedButton:SetPoint (227, -19)
		savedButton.text = "Saved"
		
		local realmButton = DetailsFrameWork:NewButton (TimeAttackFrame, nil, "DetailsTimeAttackSwitchButton", "RealmButton", 70, 14, changedisplay, 3)
		realmButton:InstallCustomTexture (nil, nil, nil, nil, true)
		realmButton:SetPoint (227, -3)
		realmButton.text = "Realm"

	--> realm times
	
	--> select realm history type
		local on_select_historytype = function (_, _, type)
			TimeAttack.db.realm_last_shown = type
			changedisplay (_, _, 3)
		end
		local menu = {
			{value = 40, icon = icon, iconcolor = "orange", texcoord = textcoord, label = "40 seconds", onclick = on_select_historytype},
			{value = 90, icon = icon, iconcolor = "orange", texcoord = textcoord, label = "1 minute 30 seconds", onclick = on_select_historytype},
			{value = 120, icon = icon, iconcolor = "orange", texcoord = textcoord, label = "2 minutes", onclick = on_select_historytype},
			{value = 180, icon = icon, iconcolor = "orange", texcoord = textcoord, label = "3 minutes", onclick = on_select_historytype},
			{value = 300, icon = icon, iconcolor = "orange", texcoord = textcoord, label = "5 minutes", onclick = on_select_historytype},
			{value = 480, icon = icon, iconcolor = "orange", texcoord = textcoord, label = "8 minutes", onclick = on_select_historytype}
		}
		local build_historytype_menu = function()
			return menu
		end
		local RealmHistoryType = DetailsFrameWork:NewDropDown (TimeAttackFrame, _, "$parentRealmHistoryType", "RealmHistoryType", 180, 20, build_historytype_menu, TimeAttack.db.realm_last_shown)
		RealmHistoryType:SetPoint ("topleft", TimeAttackFrame, "topleft", 2, -31)
		RealmHistoryType:SetPoint ("right", switchButton, "left", -4, 1)
	
		local scrollframe_realm = CreateFrame ("scrollframe", "TimeAttackRealmDpsScroll", TimeAttackFrame, "ListScrollFrameTemplate")
		scrollframe_realm:SetPoint ("topleft", TimeAttackFrame, "topleft", 0, -50)
		scrollframe_realm:SetSize (295, 100)
		
		local sort_dps = function (t1, t2) return t1.Dps > t2.Dps end
		
		local update_scrollrealm = function (self)
			
			local sample_size = TimeAttack.db.realm_last_shown
			local container = TimeAttack.db.realm_history
			
			local samples = {}
			for i = 1, #container do
				local this_sample = TimeAttack.db.realm_history [i]
				if (this_sample.Time == sample_size) then
					tinsert (samples, this_sample)
				end
			end
			
			table.sort (samples, sort_dps)
			
			local total_samples = #samples
			local offset = FauxScrollFrame_GetOffset (self)
			--print (total_samples)

			for i = 1, 14 do
				local frame = self.childs [i]
				local index = (offset * 2) + i
				
				local sample = samples [index]
				
				if (index <= total_samples and sample) then
					frame:Show()
					local player_name = sample.Source
					if (player_name:find (TimeAttack.PlayerRealm)) then
						player_name = TimeAttack:GetOnlyName (player_name)
					end
					frame.lefttext.text = index .. ". " .. player_name
					frame.righttext.text = TimeAttack:comma_value (_math_floor (sample.Dps))
					frame.sample = sample
				else
					frame:Hide()
				end
			end
			
			FauxScrollFrame_Update (self, ceil (#samples / 2) , 5, 14)
		end
		
		scrollframe_realm.Update = update_scrollrealm
		scrollframe_realm:SetScript ("OnVerticalScroll", function (self, offset) FauxScrollFrame_OnVerticalScroll (scrollframe_realm, offset, 14, update_scrollrealm) end)
		scrollframe_realm.childs = {}
		
		local on_enter = function (self)
			self:SetBackdrop ({tile = true, tileSize = 16, bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = [[Interface\AddOns\Details\images\border_2]], edgeSize = 8})
			self:SetBackdropColor (.1, .1, .1, .1)
			
			GameCooltip:Reset()
			
			local TimeObject = self.sample
			
			GameCooltip:AddLine (TimeAttack:comma_value (TimeObject.DamageDone))
			GameCooltip:AddIcon ("Interface\\TARGETINGFRAME\\PetBadge-Undead")
			
			GameCooltip:AddLine (TimeAttack:comma_value (_math_floor (TimeObject.Dps)))
			GameCooltip:AddIcon ("Interface\\TARGETINGFRAME\\PetBadge-Elemental")
			
			GameCooltip:AddLine (string.format ("%.1f", TimeObject.ItemLevel))
			GameCooltip:AddIcon ("Interface\\TARGETINGFRAME\\PetBadge-Humanoid")

			local age = _math_floor ((time() - TimeObject [1]) / 86400) --one day
			GameCooltip:AddLine (age .. " days")
			GameCooltip:AddIcon ([[Interface\FriendsFrame\StatusIcon-Away]], 1, 1, 16, 16, 0, 0.85, 0, 1)
			
			GameCooltip:ShowCooltip (self, "tooltip")
			
		end
		local on_leave = function (self)
			self:SetBackdrop ({tile = true, tileSize = 16, bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"})
			self:SetBackdropColor (.1, .1, .1, .3)
			GameCooltip:Hide()
		end
		
		local row_index = 0
		for i = 1, 14 do
			local child = CreateFrame ("frame", "TimeAttackRealmDpsScrollChield" .. i, TimeAttackFrame)
			if (i%2 == 0) then
				child:SetPoint ("left", scrollframe_realm.childs [i-1], "right", 2, 0)
			else
				child:SetPoint ("topleft", scrollframe_realm, "topleft", 2, (row_index*14*-1) - 2)
				row_index = row_index + 1
			end
			
			child:SetFrameLevel (scrollframe_realm:GetFrameLevel()+1)
			child:SetSize (146, 13)
			child:SetBackdrop ({tile = true, tileSize = 16, bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"})
			child:SetBackdropColor (.1, .1, .1, .3)
			scrollframe_realm.childs [i] = child
			
			local left_text = DetailsFrameWork:CreateLabel (child, "", 10, "white", nil, "lefttext")
			left_text:SetPoint ("left", child, "left", 2, 0)
			local right_text = DetailsFrameWork:CreateLabel (child, "", 10, "white", nil, "righttext")
			right_text:SetPoint ("right", child, "right", -2, 0)
			
			child:SetScript ("OnEnter", on_enter)
			child:SetScript ("OnLeave", on_leave)
		end
		
		function TimeAttack:HideRealmScroll()
			RealmHistoryType:Hide()
			scrollframe_realm:Hide()
			for i = 1, 14 do
				scrollframe_realm.childs [i]:Hide()
			end
		end
		function TimeAttack:ShowRealmScroll()
			RealmHistoryType:Show()
			scrollframe_realm:Show()
			for i = 1, 14 do
				scrollframe_realm.childs [i]:Show()
			end
			scrollframe_realm:Update()
		end
		
	--> remove a saved or recently time
		local remove = function (self, button, index)
			if (HistoryPanelObject.NowShowing == 1) then --> recently
				table.remove (HistoryPanelObject.Recently, index)
			else --> history
				table.remove (TimeAttack.db.history, index)
			end
			HistoryPanelObject:Refresh()
		end
	
	--> save a recently time
		local save = function (self, button, RecentlyIndex)
			if (RecentlyIndex) then --> click on any label
				local ToSaveTimeObject = HistoryPanelObject.Recently [RecentlyIndex]
				if (ToSaveTimeObject and not ToSaveTimeObject.FinishSaved) then
					local NewSave = {}
					NewSave.DamageDone = ToSaveTimeObject.FinishDamage
					NewSave.Dps = ToSaveTimeObject.FinishDps
					NewSave.Time = ToSaveTimeObject.FinishTime
					NewSave.ItemLevel = ToSaveTimeObject.FinishIlevel
					NewSave.Date = ToSaveTimeObject.Date
					NewSave.note = ToSaveTimeObject.note
					NewSave.ID = ToSaveTimeObject.ID or math.random (10000000, 99999999)
					NewSave.Age = ToSaveTimeObject.Age or time()

					table.insert (TimeAttack.db.history, 1, NewSave)
					table.remove (TimeAttack.db.history, 25)
					HistoryPanelObject:AddHistory (NewSave)
					ToSaveTimeObject.FinishSaved = true
					HistoryPanelObject:Refresh()
					
					if (TimeAttack.Time == ToSaveTimeObject) then
						TimeAttackFrame ["SaveButton"]:Disable()
					end
				end
				
			elseif (TimeAttack.Time and TimeAttack.Time.FinishOkey and not TimeAttack.Time.FinishSaved) then --> click on SAVE button
			
				local NewSave = {}
				
				NewSave.DamageDone = TimeAttack.Time.FinishDamage
				NewSave.Dps = TimeAttack.Time.FinishDps
				NewSave.Time = TimeAttack.Time.FinishTime
				NewSave.ItemLevel = TimeAttack.Time.FinishIlevel
				NewSave.Date = TimeAttack.Time.Date
				NewSave.ID = TimeAttack.Time.ID or math.random (10000000, 99999999)
				NewSave.Age = TimeAttack.Time.Age or time()
				
				TimeAttack.Time.FinishSaved = true
				table.insert (TimeAttack.db.history, 1, NewSave)
				table.remove (TimeAttack.db.history, 25)
				HistoryPanelObject:AddHistory (NewSave)
				HistoryPanelObject:Refresh()
				TimeAttackFrame ["SaveButton"]:Disable()
			end
		end

	--> save button
	
		local SaveButton = DetailsFrameWork:NewButton (TimeAttackFrame, nil, "DetailsTimeAttackSaveButton", "SaveButton", 70, 20, save)
		SaveButton:InstallCustomTexture()
		SaveButton.text = Loc ["STRING_SAVE"]
		SaveButton:SetPoint ("center", 0, -90)
		SaveButton:Disable()
	
		function HistoryPanelObject:AddRecently (data)
			table.insert (self.Recently, 1, data)
			table.remove (self.Recently, 24)
			if (self.NowShowing == 1) then
				HistoryPanelObject:Refresh()
			end
		end
	
		function HistoryPanelObject:AddHistory (data)
			if (self.NowShowing == 2) then
				HistoryPanelObject:Refresh()
			end
		end
	
	--> report button
		local reportFunc = function (IsCurrent, IsReverse, AmtLines) --> localize-me
			local lines = {	Loc ["STRING_REPORT"]..":",
						TimeAttack:comma_value (TimeAttack.Time.FinishDamage) .. " " .. Loc ["STRING_DAMAGEOVER"] .. " " .. TimeAttack.Time.FinishTime .. " " .. Loc ["STRING_SECONDS"] .. ".",
						Loc ["STRING_AVERAGEDPS"] .. " " .. TimeAttack:comma_value (_math_floor (TimeAttack.Time.FinishDps)) .. " " .. Loc ["STRING_WITH"] .. " " .. _cstr ("%.1f", TimeAttack.Time.FinishIlevel) .. " " .. Loc ["STRING_ITEMLEVEL"] ..  "."}
			TimeAttack:SendReportLines (lines)
		end
		
		--[1] fucntion wich will build report lines after click on 'Send Button' [2] enable current button [3] enable reverse button
		local ReportButton = DetailsFrameWork:NewButton (TimeAttackFrame, nil, "DetailsTimeAttackReportButton", "ReportButton", 20, 20, function() TimeAttack:SendReportWindow (reportFunc) end)
		ReportButton.texture = "Interface\\COMMON\\VOICECHAT-ON"
		ReportButton:SetPoint ("left", DetailsTimeAttackSaveButton, "right", -10, 0)
		ReportButton:Hide()
	
--------------> general functions: ----------------

	function HistoryPanelObject:RefreshLabel (AttemptTable, AlreadySaved, First)

		self.table = AttemptTable
		
		if (AlreadySaved) then --> showing historic
		
			self.remove:SetPoint ("left", self.background.frame, "left", 20, 0)
			self.note:SetPoint ("left", self.remove, "right")
			
			if (AttemptTable.note) then
				self.note:SetNormalTexture ("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
				self.note.tooltip = AttemptTable.note
			else
				self.note:SetNormalTexture ("Interface\\Buttons\\UI-GuildButton-PublicNote-Disabled")
				self.note.tooltip = Loc ["STRING_SETNOTE"]
			end
			self.save:Hide()
			local diamesano = string.gsub (AttemptTable.Date, "(.-)%s", "")
			self.text:SetText (diamesano)
			
			self.rownumber:SetText ("#" .. self.index)
			
		elseif (not AttemptTable.FinishSaved) then --> não foi salvo ainda
			self.remove:Show()
			self.save:Show()
			self.remove:SetPoint ("left", self.background.frame, "left", 16, 0)
			self.note:SetPoint ("left", self.save.button, "right")
			if (AttemptTable.note) then
				self.note:SetNormalTexture ("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
				self.note.tooltip = AttemptTable.note
			else
				self.note:SetNormalTexture ("Interface\\Buttons\\UI-GuildButton-PublicNote-Disabled")
				self.note.tooltip = Loc ["STRING_SETNOTE"]
			end
			if (First) then
				self.text:SetText ("-".. TimeAttack:ToK (First-AttemptTable.FinishDamage))
			else
				self.text:SetText (TimeAttack:ToK (AttemptTable.FinishDamage))
			end
			self.rownumber:SetText ("#" .. AttemptTable.N)
			self.rownumber:SetPoint ("left", self.background.frame)
			
		else --> ta mostrando recentes e ja foi salvo
			self.remove:Show()
			self.remove:SetPoint ("left", self.background.frame, "left", 16, 0)
			self.note:SetPoint ("left", self.remove.button, "right")
			if (AttemptTable.note) then
				self.note:SetNormalTexture ("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
				self.note.tooltip = AttemptTable.note
			else
				self.note:SetNormalTexture ("Interface\\Buttons\\UI-GuildButton-PublicNote-Disabled")
				self.note.tooltip = Loc ["STRING_SETNOTE"]
			end
			self.save:Hide()
			if (First) then
				self.text:SetText ("-".. TimeAttack:ToK (First-AttemptTable.FinishDamage))
			else
				self.text:SetText (TimeAttack:ToK (AttemptTable.FinishDamage))
			end
			self.rownumber:SetText ("#" .. AttemptTable.N)
			self.rownumber:SetPoint ("left", self.background.frame)
		end
		
		self.background:Show()
	end

	local OnEnterHook = function (self, arg2, arg3)
	
		self:SetBackdrop ({tile = true, tileSize = 16, bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = [[Interface\AddOns\Details\images\border_2]], edgeSize = 8})
		self:SetBackdropColor (.1, .1, .1, .1)
	
		self = self.BoxObject
	
		if (HistoryPanelObject.NowShowing == 1) then --> recently
		
			GameCooltip:Reset()
			
			local TimeObject = HistoryPanelObject.Recently [self.index]
			
			GameCooltip:AddLine (TimeAttack:comma_value (TimeObject.FinishDamage))
			GameCooltip:AddIcon ("Interface\\TARGETINGFRAME\\PetBadge-Undead")
			
			GameCooltip:AddLine (TimeAttack:comma_value (math.floor (TimeObject.FinishDps)))
			GameCooltip:AddIcon ("Interface\\TARGETINGFRAME\\PetBadge-Elemental")
			
			GameCooltip:AddLine (TimeObject.FinishTime.." " .. Loc ["STRING_SECONDS"])
			GameCooltip:AddIcon ("Interface\\TARGETINGFRAME\\PetBadge-Mechanical")

			GameCooltip:AddLine (string.format ("%.1f", TimeObject.FinishIlevel))
			GameCooltip:AddIcon ("Interface\\TARGETINGFRAME\\PetBadge-Humanoid")

			GameCooltip:ShowCooltip (self.background, "tooltip")
			
		else --> history

			GameCooltip:Reset()
			
			local TimeObject = TimeAttack.db.history [self.index]
			
			GameCooltip:AddLine (TimeAttack:comma_value (TimeObject.DamageDone))
			GameCooltip:AddIcon ("Interface\\TARGETINGFRAME\\PetBadge-Undead")
			
			GameCooltip:AddLine (TimeAttack:comma_value (math.floor (TimeObject.Dps)))
			GameCooltip:AddIcon ("Interface\\TARGETINGFRAME\\PetBadge-Elemental")
			
			GameCooltip:AddLine (TimeObject.Time.." " .. Loc ["STRING_SECONDS"])
			GameCooltip:AddIcon ("Interface\\TARGETINGFRAME\\PetBadge-Mechanical")

			GameCooltip:AddLine (string.format ("%.1f", TimeObject.ItemLevel))
			GameCooltip:AddIcon ("Interface\\TARGETINGFRAME\\PetBadge-Humanoid")
			
			GameCooltip:ShowCooltip (self.background, "tooltip")
		end
		
		return true
	end
	
	local OnLeaveHook= function (self)
		GameCooltip:ShowMe (false)
		self:SetBackdrop ({tile = true, tileSize = 16, bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"})
		self:SetBackdropColor (.1, .1, .1, .3)
		
		return true
	end
	
	TimeAttack.HistoryX = 4
	TimeAttack.HistoryY = -52
	
	local WriteNoteStop = function()

		local editbox = TimeAttackFrame ["NoteEntry"]
	
		local texto = editbox:GetText()
		if (string.len (texto) > 0) then
			if (HistoryPanelObject.NowShowing == 1) then --> recently
				HistoryPanelObject.Recently [editbox.editing].note = texto
			else
				TimeAttack.db.history [editbox.editing].note = texto
			end
		end
		editbox:SetText ("")
		editbox.editing = nil
		editbox:Hide()
		switchButton:Enable()
		
		if (TimeAttack.Time and TimeAttack.Time.FinishOkey and not TimeAttack.Time.FinishSaved) then
			SaveButton:Enable()
			ReportButton:Show()
		end
		
		HistoryPanelObject:Refresh()
	end
	
	--local NoteInsertField = DetailsFrameWork:NewTextBox (TimeAttackFrame, TimeAttackFrame, "NoteEntry", WriteNoteStop, _, _, 296, 15)
	local NoteInsertField = DetailsFrameWork:NewTextEntry (TimeAttackFrame, nil, "DetailsTimeAttackNoteEntry", "NoteEntry", 296, 15, WriteNoteStop)
	NoteInsertField:SetBackdropColor (0, 0, 0, 1)
	NoteInsertField:SetPoint ("bottom", barraDOWN, "top", 0, 0)
	NoteInsertField:SetFrameLevel (TimeAttackFrame:GetFrameLevel()+3)
	NoteInsertField:Hide()
	
	NoteInsertField.OnEscapePressedHook = function() 
			NoteInsertField.editing = nil
			NoteInsertField:SetText ("")
			switchButton:Enable()
			NoteInsertField:Hide() 
			
			if (TimeAttack.Time and TimeAttack.Time.FinishOkey and not TimeAttack.Time.FinishSaved) then
				SaveButton:Enable()
				ReportButton:Show()
			end
			
		end
	
	local WriteNoteStart = function (self, button, index)
	
		if (HistoryPanelObject.NowShowing == 1 and HistoryPanelObject.Recently [index].note) then --> recently
			NoteInsertField:SetText (HistoryPanelObject.Recently [index].note)
		elseif (HistoryPanelObject.NowShowing == 2 and TimeAttack.db.history [index].note) then
			NoteInsertField:SetText (TimeAttack.db.history [index].note)
		else
			NoteInsertField:SetText ("")
		end
		
		NoteInsertField.editing = index
		NoteInsertField:Show()
		NoteInsertField:SetFocus()
		switchButton:Disable()
		SaveButton:Disable()
		ReportButton:Hide()
	end

	function HistoryPanelObject:CreateNewLabel (index)
	
		local LabelBoxObject = {}
		self.LabelsCreated [#self.LabelsCreated+1] = LabelBoxObject
		setmetatable (LabelBoxObject, HistoryPanelObject)
		LabelBoxObject.index = index
		
		local LabelBackground = DetailsFrameWork:NewPanel (bg1.frame, bg1.frame, "DetailsTimeAttackPanel"..index, "label"..index, 95, 12, 
		{tile = true, tileSize = 16, bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"}, {.1, .1, .1, .3})

		LabelBackground:SetPoint ("topleft", TimeAttackFrame, TimeAttack.HistoryX, TimeAttack.HistoryY)
		LabelBackground.frame:SetFrameLevel (bg1.frame:GetFrameLevel()+1)
		
		LabelBackground:SetHook ("OnEnter", OnEnterHook)
		LabelBackground:SetHook ("OnLeave", OnLeaveHook)
		
		LabelBackground.frame.BoxObject = LabelBoxObject
		
		TimeAttack.HistoryY = TimeAttack.HistoryY - 12
		if (TimeAttack.HistoryY <= -148) then
			TimeAttack.HistoryY = -52
			TimeAttack.HistoryX = TimeAttack.HistoryX + 99
		end

		local LabelText = DetailsFrameWork:NewLabel (LabelBackground.frame, LabelBackground.frame, nil, "text", "000.000", "GameFontHighlightSmall")
		LabelText:SetPoint ("right", LabelBackground.frame, 0, 0)
		LabelText:SetJustifyH ("right")
		
		local RowNumber = DetailsFrameWork:NewLabel (LabelBackground.frame, LabelBackground.frame, nil, "rownumber", "#1", "GameFontHighlightSmall")
		RowNumber:SetPoint ("left", LabelBackground.frame)
		RowNumber:SetJustifyH ("left")
		
		--local LabelRemoveButton = DetailsFrameWork:NewDetailsButton (LabelBackground.frame, LabelBackground.frame, _, remove, index, index, 10, 10, "Interface\\PetBattles\\DeadPetIcon")
		local LabelRemoveButton = DetailsFrameWork:NewButton (LabelBackground.frame, nil, "DetailsTimeAttackRemoveButton"..index, "RemoveButton"..index, 12, 12, remove, index, index, "Interface\\PetBattles\\DeadPetIcon")
		LabelRemoveButton:SetPoint ("left", LabelBackground.frame, "left", 16, 0)
		LabelRemoveButton.tooltip = Loc ["STRING_REMOVERECORD"]
		
		--local LabelSaveButton = DetailsFrameWork:NewDetailsButton (LabelBackground.frame, LabelBackground.frame, _, save, index, index, 10, 10, "Interface\\Scenarios\\ScenarioIcon-Check")
		local LabelSaveButton = DetailsFrameWork:NewButton (LabelBackground.frame, nil, "DetailsTimeAttackSaveButton"..index, "SaveButton"..index, 12, 12, save, index, index, "Interface\\Scenarios\\ScenarioIcon-Check")
		LabelSaveButton:SetPoint ("left", LabelRemoveButton.button, "right", -1, 0)
		LabelSaveButton.tooltip = Loc ["STRING_SAVERECORD"]
		
		--local LabelSetnoteButton = DetailsFrameWork:NewDetailsButton (LabelBackground.frame, LabelBackground.frame, _, WriteNoteStart, index, index, 10, 10, "Interface\\Buttons\\UI-GuildButton-PublicNote-Disabled")
		local LabelSetnoteButton = DetailsFrameWork:NewButton (LabelBackground.frame, nil, "DetailsTimeAttackSetNoteButton"..index, "SetNoteButton"..index, 12, 12, WriteNoteStart, index, index, "Interface\\Buttons\\UI-GuildButton-PublicNote-Disabled")
		LabelSetnoteButton:SetPoint ("left", LabelSaveButton.button, "right", -2, 0)
		LabelSetnoteButton.tooltip = Loc ["STRING_SETNOTE"]
		
		LabelBoxObject.rownumber = RowNumber
		LabelBoxObject.text = LabelText
		LabelBoxObject.background = LabelBackground
		LabelBoxObject.remove = LabelRemoveButton
		LabelBoxObject.save = LabelSaveButton
		LabelBoxObject.note = LabelSetnoteButton
		LabelBoxObject.HaveNote = false
		
		return LabelBoxObject
	end

	function HistoryPanelObject:Refresh()
	
		if (self.NowShowing == 1) then --> recent
			
			TimeAttackFrame.switchButton:SetTextColor (1, 1, 1, 1)
			TimeAttackFrame.SavedButton:SetTextColor (1, 0.8, 0, 1)
			TimeAttackFrame.RealmButton:SetTextColor (1, 0.8, 0, 1)
			TimeAttack:HideRealmScroll()
			
			--> sort by damage done
			table.sort (self.Recently, function (a,b) return a.FinishDamage > b.FinishDamage end)
			local first = self.Recently [1]
			if (first) then
				first = first.FinishDamage
			end
			for index, AttemptTable in ipairs (self.Recently) do 
				
				local thisLabel = self.LabelsCreated [index]
				if (not thisLabel) then
					thisLabel = self:CreateNewLabel (index)
				end
				if (index == 1) then
					thisLabel:RefreshLabel (AttemptTable, false)
				else
					thisLabel:RefreshLabel (AttemptTable, false, first)
				end
			end

			for amt = #self.Recently+1, #self.LabelsCreated do
				local thisLabel = self.LabelsCreated [amt]
				thisLabel.background:Hide()
			end
			
		elseif (self.NowShowing == 2) then --> saved
		
			TimeAttackFrame.switchButton:SetTextColor (1, 0.8, 0, 1)
			TimeAttackFrame.SavedButton:SetTextColor (1, 1, 1, 1)
			TimeAttackFrame.RealmButton:SetTextColor (1, 0.8, 0, 1)
			TimeAttack:HideRealmScroll()
		
			for index, AttemptTable in ipairs (TimeAttack.db.history) do 
				local thisLabel = self.LabelsCreated [index]
				if (not thisLabel) then
					thisLabel = self:CreateNewLabel (index)
				end
				thisLabel:RefreshLabel (AttemptTable, true)
			end

			for amt = #TimeAttack.db.history+1, #self.LabelsCreated do
				local thisLabel = self.LabelsCreated [amt]
				thisLabel.background:Hide()
			end
			
		elseif (self.NowShowing == 3) then --> realm
			
			for amt = 1, #self.LabelsCreated do
				local thisLabel = self.LabelsCreated [amt]
				thisLabel.background:Hide()
			end
			
			TimeAttackFrame.switchButton:SetTextColor (1, 0.8, 0, 1)
			TimeAttackFrame.SavedButton:SetTextColor (1, 0.8, 0, 1)
			TimeAttackFrame.RealmButton:SetTextColor (1, 1, 1, 1)
			
			TimeAttack:ShowRealmScroll()
		end
	end
	
	HistoryPanelObject:Refresh()
	
	local update = 0
	local player --> short cut for Player Actor Object
	
	--> Cancel function
	function TimeAttack:Cancel()
		if (TimeAttack.Time) then
			TimeAttack.Time.Working = false
			TimeAttack.Time.Done = true
		end
		TimeAttack.Frame:SetScript ("OnUpdate", nil)
	end

	--> Exec function
	local DoTimeAttack = function (self, elapsed)
	
		TimeAttack.Time.Elapsed = TimeAttack.Time.Elapsed + elapsed
		update = update + elapsed
		if (_GetTime() > TimeAttack.Time.EndTime) then --> reached the end time
			if (TimeAttack.Time.Working and not TimeAttack.Time.Done) then
				TimeAttack:Cancel()
				TimeAttack:Finish()
			else
				TimeAttack:Cancel()
			end
		else
			--> aqui vem as funções que verificam se o jogador esta em grupo ou se tem algum buff proibido
			TimeAttack.Time.Tick = TimeAttack.Time.Tick + elapsed
			if (TimeAttack.Time.Tick > 1) then
				TimeAttack.Time.Tick = 0
				if (not _UFC ("player")) then --> isn't in combat
					TimeAttack:Cancel()
				end
			else
				local minutos, segundos = _math_floor (TimeAttack.Time.Elapsed/60), _math_floor (TimeAttack.Time.Elapsed%60)

				if (segundos < 10) then
					segundos = "0"..segundos
				end
				
				local mili = _cstr ("%.2f", TimeAttack.Time.Elapsed-_math_floor (TimeAttack.Time.Elapsed))*100
				if (mili < 10) then
					mili = "0"..mili
				end
				
				clock:SetText ("0".. minutos .. ":")
				clock2:SetText (segundos ..":")
				clock3:SetText (mili)
				damage:SetText (TimeAttack:comma_value (player.total))
				
				if (TimeAttack.Time.Elapsed > 3) then
					persecond:SetText (TimeAttack:comma_value (_math_floor (player.total/TimeAttack.Time.Elapsed)))
				end
			end
		end
		
	end
	
	
	--> When the time is gone
	function TimeAttack:Finish()
		TimeAttack.Time.FinishOkey = true
		TimeAttack.Time.FinishSaved = false
		TimeAttack.Time.FinishDamage = player.total
		TimeAttack.Time.FinishDps = player.total/TimeAttack.Time.Elapsed
		local _, equipped = GetAverageItemLevel()
		TimeAttack.Time.FinishIlevel = equipped
		TimeAttack.Time.Date = date ("%H:%M %d/%m/%y")
		TimeAttack.Time.N = TimeAttack.try
		TimeAttack.Time.ID = math.random (10000000, 99999999)
		TimeAttack.Time.Age = time()
		HistoryPanelObject:AddRecently (TimeAttack.Time)
		TimeAttack.try = TimeAttack.try + 1
		SaveButton:Enable()
		ReportButton:Show()
		
		TimeAttack:ShareRecently (TimeAttack.Time)
	end
	
	function _detalhes:TimeAttackPluginStart()
		TimeAttack:Start()
	end
	
	--> When a new combat is received by the PlugIn
	function TimeAttack:Start()

		if (TimeAttack.Time and TimeAttack.Time.Working) then
			TimeAttack:Cancel()
		end

		TimeAttack.Time = {}
		TimeAttack.Time.StartTime = _GetTime()
		TimeAttack.Time.EndTime = TimeAttack.Time.StartTime + TimeAttack.db.time - 2
		TimeAttack.Time.Elapsed = 2
		TimeAttack.Time.Done = nil
		TimeAttack.Time.Working = true
		TimeAttack.Time.Tick = 0
		
		TimeAttack.Time.FinishOkey = false
		TimeAttack.Time.FinishSaved = false
		TimeAttack.Time.FinishDamage = nil
		TimeAttack.Time.FinishTime = TimeAttack.db.time
		TimeAttack.Time.FinishDps = nil
		TimeAttack.Time.FinishIlevel = nil
		TimeAttack.Time.Date = nil

		SaveButton:Disable()
		ReportButton:Hide()

		player = TimeAttack:GetActor ("current", 1, UnitName ("player")) --> param 1 = combat | param 2 = attribute | param 3 = player name | all none = current, damage, player

		if (not player) then
			print (Loc ["STRING_COMBATFAIL"])
			return
		end

		update = 0
		TimeAttack.Frame:SetScript ("OnUpdate", DoTimeAttack)
		
	end

	local options = DetailsFrameWork:NewButton (TimeAttackFrame, nil, "$parentOptionsButton", "OptionsButton", 86, 16, TimeAttack.OpenOptionsPanel, nil, nil, nil, "Options")
	options:SetPoint ("bottomleft", TimeAttackFrame, "bottomleft", 5, 22)
	--options:SetPoint ("bottomright", TimeAttackFrame, "bottomright", -10, 30)
	--options:SetPoint ("bottomright", TimeAmount2, "topright", 0, 1)
	--options:InstallCustomTexture()
	options:SetTextColor (1, 0.93, 0.74)
	options:SetIcon ([[Interface\Buttons\UI-OptionsButton]], 14, 14, nil, {0, 1, 0, 1}, nil, 3)
end

function TimeAttack:CheckTimeAttackTutorial()
	--TimeAttack:SetTutorialCVar ("TIME_ATTACK_TUTORIAL1", nil)
	if (not TimeAttack:GetTutorialCVar ("TIME_ATTACK_TUTORIAL1")) then
		--tutorial disabled
		--TimeAttackFrame:RegisterEvent ("PLAYER_TARGET_CHANGED")
	end
end

function TimeAttack:CheckTargetForTutorial()
	local guid = UnitGUID ("target")
	if (guid) then
		local mobid = TimeAttack:GetNpcIdFromGuid (guid)
		if (mobid == 31144 or mobid == 32666 or mobid == 31146 or mobid == 32667 or mobid == 67127 or mobid == 46647 or mobid == 87762 or mobid == 87761) then 
			TimeAttack:SetTutorialCVar ("TIME_ATTACK_TUTORIAL1", true)
			TimeAttackFrame:UnregisterEvent ("PLAYER_TARGET_CHANGED")
			TimeAttack:ShowTargetTutorial()
		end
	end
end

function TimeAttack:ShowTargetTutorial()
	if (TimeAttack:GetFreeInstancesAmount() > 0) then
		local func = function()
			local newinstance = TimeAttack:CreateInstance (true) --> force create a new one
			if (newinstance) then
				newinstance:SetMode (DETAILS_MODE_SOLO)
				TimeAttack.SoloTables:switch (nil, "DETAILS_PLUGIN_TIME_ATTACK")
			end
		end
		TimeAttack:GetFramework():ShowTutorialAlertFrame ("Open Time Attack", "plugin for measure dps", func)
	end
end



function TimeAttack:AddRealmData (damage, time, ilevel, age, id, class, source)
	local t = {
		age,
		DamageDone = damage[1],
		Dps = damage[2],
		Time = time,
		ItemLevel = ilevel,
		ID = id,
		Source = source
	}
	
	tinsert (TimeAttack.db.realm_history, t)
	table.sort (TimeAttack.db.realm_history, TimeAttack.Sort1)
	
	if (#TimeAttack.db.realm_history > 60) then
		table.remove (TimeAttack.db.realm_history, 61)
	end
end



--request data
	function TimeAttack:RequestRealmResults()
		if (TimeAttack.last_channel_request+600 < time()) then
			TimeAttack.last_channel_request = time()
			TimeAttack:SendPluginCommMessage ("TARE", nil, select (2, UnitClass ("player")))
		end
	end

	function TimeAttack:OnReceiveRequest (class)
		if (class == select (2, UnitClass ("player")) and TimeAttack.last_forced_share+20 < time()) then
			TimeAttack.last_forced_share = time()
			TimeAttack:ShareResults() --share saved
			TimeAttack:ShareAllRecently() --share recently
		end
	end

--saved
	function TimeAttack:ShareResults()
		for i = TimeAttack.db.history_lastindex+1, TimeAttack.db.history_lastindex+3 do
			local this_saved = TimeAttack.db.history [i]
			if (not this_saved) then
				TimeAttack.db.history_lastindex = 0
				break
			end
			
			TimeAttack:ShareSaved (this_saved)
			TimeAttack.db.history_lastindex = i
		end
	end

	function TimeAttack:ShareSaved (saved)
		local data = TimeAttack:PrepareToShare (saved)
		
		if (TimeAttack.db.saved_as_anonymous) then
			data [7] = "Unidentified"
		else
			data [7] = UnitName ("player") .. "-" .. GetRealmName()
		end
		
		TimeAttack:ScheduleTimer ("SendQueuedData", math.random (1, 5), data)
	end

--recentrly
	function TimeAttack:ShareAllRecently()
		local amt = 0
		for index, recent in ipairs (TimeAttack.HistoryPanelObject.Recently) do
			TimeAttack:ShareRecently (recent)
			amt = amt + 1
			if (amt == 3) then
				break
			end
		end
	end

	function TimeAttack:ShareRecently (recent)
		local data = TimeAttack:PrepareToShare (recent)
		
		if (TimeAttack.db.recently_as_anonymous) then
			data [7] = "Unidentified"
		else
			data [7] = UnitName ("player") .. "-" .. GetRealmName()
		end
		
		TimeAttack:ScheduleTimer ("SendQueuedData", math.random (1, 5), data)
	end

--send and receive data functions

	function TimeAttack:OnReceiveShared (damage, time, ilevel, age, id, class, source)
		--print ("TA:", damage[1], damage[2], time, ilevel, age, id, class, source) --debug
		
		if (not TimeAttack:IsPluginEnabled()) then
			return
		end
		
		--same class
		if (class ~= select (2, UnitClass ("player"))) then
			return
		end
		--already exists
		for index, data in ipairs (TimeAttack.db.realm_history) do
			if (data.ID == id) then
				return
			end
		end
		for index, data in ipairs (TimeAttack.HistoryPanelObject.Recently) do
			if (data.ID == id) then
				return
			end
		end
		for index, data in ipairs (TimeAttack.db.history) do
			if (data.ID == id) then
				return
			end
		end
		--add
		TimeAttack:AddRealmData (damage, time, ilevel, age, id, class, source)
	end
	
	function TimeAttack:SendQueuedData (data)
		TimeAttack:SendPluginCommMessage ("TASH", nil, data[1], data[2], data[3], data[4], data[5], data[6], data [7])
	end

	function TimeAttack:PrepareToShare (sample)
		local send_table = {}
		send_table [1] = {_math_floor (sample.FinishDamage or sample.DamageDone), _math_floor (sample.FinishDps or sample.Dps)} --damage and dps
		send_table [2] = sample.FinishTime or sample.Time --time
		send_table [3] = _math_floor (sample.FinishIlevel or sample.ItemLevel) --ilevel
		send_table [4] = sample.Age --age
		send_table [5] = sample.ID --id
		send_table [6] = select (2, UnitClass ("player"))
		return send_table
	end



	
	

--options
local build_options_panel = function()
	
	local options_frame = TimeAttack:CreatePluginOptionsFrame ("TimeAttackOptionsWindow", "Time Attack Options", 1)
	local menu = {
		{
			type = "toggle",
			get = function() return TimeAttack.db.recently_as_anonymous end,
			set = function (self, fixedparam, value) TimeAttack.db.recently_as_anonymous = value end,
			desc = "When enabled, your recently samples are shared without telling your character name.",
			name = "Share Recently as Anonymous"
		},
		{
			type = "toggle",
			get = function() return TimeAttack.db.saved_as_anonymous end,
			set = function (self, fixedparam, value) TimeAttack.db.saved_as_anonymous = value end,
			desc = "When enabled, your saved samples are shared without telling your character name.",
			name = "Share Saved as Anonymous"
		},
		{
			type = "toggle",
			get = function() return TimeAttack.db.disable_sharing end,
			set = function (self, fixedparam, value) TimeAttack.db.disable_sharing = value end,
			desc = "When enabled, your damage samples aren't shared with other players in your realm.\n\n|cFFFFFF00Important|r: when disabled you also can't get samples from other players.",
			name = "Disable Sharing"
		},
	}
	
	_detalhes.gump:BuildMenu (options_frame, menu, 15, -65, 260)

end
TimeAttack.OpenOptionsPanel = function()
	if (not TimeAttackOptionsWindow) then
		build_options_panel()
	end
	TimeAttackOptionsWindow:Show()
end					

function TimeAttack:OnEvent (_, event, ...)

	if (event == "PLAYER_TARGET_CHANGED") then
		TimeAttack:CheckTargetForTutorial()

	elseif (event == "ADDON_LOADED") then
		local AddonName = select (1, ...)
		if (AddonName == "Details_TimeAttack") then
			
			if (_G._detalhes) then

				local MINIMAL_DETAILS_VERSION_REQUIRED = 1
				
				local default_settings = {
					time = 40, 
					dps = 0, 
					history = {},
					history_lastindex = 0,
					realm_history = {},
					realm_lastamt = 0,
					realm_last_shown = 40,
					recently_as_anonymous = true,
					saved_as_anonymous = true,
					disable_sharing = false,
				}
				
				if (_detalhes_databaseTimeAttack) then
					default_settings.history = _detalhes_databaseTimeAttack.history
					_detalhes_databaseTimeAttack = nil
				end
				
				--> Install
				local install, saveddata = _G._detalhes:InstallPlugin ("SOLO", Loc ["STRING_PLUGIN_NAME"], "Interface\\Icons\\SPELL_HOLY_BORROWEDTIME", TimeAttack, "DETAILS_PLUGIN_TIME_ATTACK", MINIMAL_DETAILS_VERSION_REQUIRED, "Details! Team", "v1.05", default_settings)
				if (type (install) == "table" and install.error) then
					print (install.errortext)
					return
				end
				
				--> fix for old versions
				local ta = TimeAttack.db.time
				if (ta ~= 40 and ta ~= 90 and ta ~= 120 and ta ~= 180 and ta ~= 300 and ta ~= 480) then
					TimeAttack.db.time = 40
				end
				for index, saved in ipairs (TimeAttack.db.history) do
					if (not saved.ID) then
						saved.ID = math.random (10000000, 99999999)
					end
					if (not saved.Age) then
						saved.Age = time()
					end
				end
				--
				
				--> Register needed events
				_G._detalhes:RegisterEvent (TimeAttack, "COMBAT_PLAYER_ENTER")
				_G._detalhes:RegisterEvent (TimeAttack, "REALM_CHANNEL_ENTER")
				_G._detalhes:RegisterEvent (TimeAttack, "REALM_CHANNEL_LEAVE")

				--> create widgets
				CreatePluginFrames()
				
				--> register comm
				TimeAttack:RegisterPluginComm ("TASH", "OnReceiveShared")
				TimeAttack:RegisterPluginComm ("TARE", "OnReceiveRequest")
				TimeAttack.last_forced_share = 0
				TimeAttack.last_channel_request = 0
				
				--/run DETAILS_PLUGIN_TIME_ATTACK:ShareResults()
				
				--> register background task
				TimeAttack:RegisterBackgroundTask ("TimeAttackSharer", "ShareResults", "LOW")

				--> Register slash commands
				SLASH_DETAILS_TIMEATTACK1, SLASH_DETAILS_TIMEATTACK2 = "/timeattack", "/ta"
				function SlashCmdList.DETAILS_TIMEATTACK (msg, editbox)
					if (not TimeAttackFrame:IsShown()) then
						--> check if there is a instance closed with time attack
						for index, instance in TimeAttack:ListInstances() do
							if (instance:IsSoloMode (true)) then
								instance:EnableInstance()
								TimeAttack.SoloTables:switch (nil, "DETAILS_PLUGIN_TIME_ATTACK")
								return
							end
						end
						--> open a new instance
						if (TimeAttack:GetFreeInstancesAmount() > 0) then
							local newinstance = TimeAttack:CreateInstance (true) --> force create a new one
							if (newinstance) then
								newinstance:SetMode (DETAILS_MODE_SOLO)
								TimeAttack.SoloTables:switch (nil, "DETAILS_PLUGIN_TIME_ATTACK")
							end
						end
					end
				end
				
			end
		end
	end
end
