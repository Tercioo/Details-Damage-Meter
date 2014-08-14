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
			
		elseif (event == "COMBAT_PLAYER_ENTER") then --> combat started
			TimeAttack:ScheduleTimer ("TimeAttackPluginStart", 2)

		elseif (event == "PLUGIN_DISABLED") then
			
		elseif (event == "PLUGIN_ENABLED") then
		
		elseif (event == "DETAILS_STARTED") then
			TimeAttack:CheckTimeAttackTutorial()
		end
	end
	
------------- Build TimeAttack Object ------------------------------------------------------------------------------------------------

	--> main frame and background texture
		TimeAttackFrame:SetResizable (false) --> cant resize, this is a fixed size
		TimeAttackFrame:SetWidth (300) --> need to be 300x300 to fit details window
		TimeAttackFrame:SetHeight (300) --> need to be 300x300 to fit details window
	
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
	
	--> text informing about the amount of time
		local TimeDesc = DetailsFrameWork:NewLabel (TimeAttackFrame, TimeAttackFrame, nil, "TimeDesc", Loc ["STRING_TIME_SELECTION"])
		TimeDesc:SetPoint ("topleft", TimeAttackFrame, 15, -260)
	--> slider

		local TimeAmount = DetailsFrameWork:NewSlider (TimeAttackFrame, nil, "DetailsTimeAttackTimeSelect", "TimeSelect", 270, 20, 30, 330, 1, TimeAttack.db.time)
		TimeAmount:SetPoint ("topleft", TimeAttackFrame, 15, -270)
		TimeAmount.OnChangeHook = function (_, _, value) TimeAttack.db.time = value end
	
	--> main time/damage/dps texts
		local clock = DetailsFrameWork:NewLabel (TimeAttackFrame, TimeAttackFrame, nil, "TIMER", "00:00:00", "GameFontHighlightLarge")
		clock:SetPoint ("center", TimeAttackFrame, 0, -20)
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
		bg1:DisableGradient()

	--> this is the main table wich will hold the times and labels also is a class
		local HistoryPanelObject = {
			NowShowing = 1, --> 1 for recently 2 for saved
			LabelsCreated = {},
			Recently = {},
			Hystory = TimeAttack.db.history
		}
		HistoryPanelObject.__index = HistoryPanelObject
	
	--> build the button to switch between recent times and saved times
		local displayTipes = {Loc ["STRING_RECENTLY"], Loc ["STRING_SAVED"]}
		local switchButton
		function changedisplay()
			HistoryPanelObject.NowShowing = math.abs (HistoryPanelObject.NowShowing-3)
			HistoryPanelObject:Refresh()
			switchButton.text = displayTipes [HistoryPanelObject.NowShowing]
		end
		
		switchButton = DetailsFrameWork:NewButton (TimeAttackFrame, nil, "DetailsTimeAttackSwitchButton", "switchButton", 70, 15, changedisplay)
		switchButton:InstallCustomTexture()
		switchButton:SetPoint (227, -35)
		switchButton.text = displayTipes [HistoryPanelObject.NowShowing]
		
		local leftSwitchTexture = switchButton:CreateTexture (nil, "overlay")
		leftSwitchTexture:SetTexture ("Interface\\TALENTFRAME\\talent-main")
		leftSwitchTexture:SetTexCoord (0.13671875, 0.25, 0.486328125, 0.576171875)
		leftSwitchTexture:SetPoint ("left", switchButton.button, 0, 0)
		leftSwitchTexture:SetWidth (10)
		leftSwitchTexture:SetHeight (17)
		
		local rightSwitchTexture = switchButton:CreateTexture (nil, "overlay")
		rightSwitchTexture:SetTexture ("Interface\\TALENTFRAME\\talent-main")
		rightSwitchTexture:SetTexCoord (0.01953125, 0.13671875, 0.486328125, 0.576171875)
		rightSwitchTexture:SetPoint ("right", switchButton.button, 0, 0)	
		rightSwitchTexture:SetWidth (10)
		rightSwitchTexture:SetHeight (17)

	--> remove a saved or recently time
		local remove = function (index)
			if (HistoryPanelObject.NowShowing == 1) then --> recently
				table.remove (HistoryPanelObject.Recently, index)
			else --> history
				table.remove (TimeAttack.db.history, index)
			end
			HistoryPanelObject:Refresh()
		end
	
	--> save a recently time
		local save = function (RecentlyIndex)
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
	end
	
	local OnLeaveHook= function (self)
		GameCooltip:ShowMe (false)
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
	
	local WriteNoteStart = function (index)
	
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
		{tile = true, tileSize = 16, bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"}, {.5, .5, .5, 1})
		
		LabelBackground:SetPoint ("topleft", TimeAttackFrame, TimeAttack.HistoryX, TimeAttack.HistoryY)
		LabelBackground.frame.Gradient.OnEnter = {.9, .9, .9, 1}
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
			
		elseif (self.NowShowing == 2) then
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
		end
	end
	
	HistoryPanelObject:Refresh()
	
	local update = 0
	local player --> short cut for Player Actor Object
	
	--> Cancel function
	function TimeAttack:Cancel()
		if (TimeAttack.Time and TimeAttack.Time.Working) then
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
				if (update > 0.050) then
					--> Update Timer Here
					
					local minutos, segundos = _math_floor (TimeAttack.Time.Elapsed/60), _math_floor (TimeAttack.Time.Elapsed%60)

					if (segundos < 10) then
						segundos = "0"..segundos
					end
					
					local mili = _cstr ("%.2f", TimeAttack.Time.Elapsed-_math_floor (TimeAttack.Time.Elapsed))*100
					if (mili < 10) then
						mili = "0"..mili
					end
					
					clock:SetText ("0".. minutos .. ":"..segundos ..":"..mili)
					damage:SetText (TimeAttack:comma_value (player.total))
					
					if (TimeAttack.Time.Elapsed > 3) then
						persecond:SetText (TimeAttack:comma_value (_math_floor (player.total/TimeAttack.Time.Elapsed)))
					end

					update = 0
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
		HistoryPanelObject:AddRecently (TimeAttack.Time)
		TimeAttack.try = TimeAttack.try + 1
		SaveButton:Enable()
		ReportButton:Show()
	end
	
	function _detalhes:TimeAttackPluginStart()
		TimeAttack:Start()
	end
	
	--> When a new combat is received by the PlugIn
	function TimeAttack:Start()

		if (TimeAttack.Time and TimeAttack.Time.Working) then
			return
		end

		TimeAttack.Time = {}
		TimeAttack.Time.StartTime = _GetTime()
		TimeAttack.Time.EndTime = TimeAttack.Time.StartTime + TimeAmount.value - 2
		TimeAttack.Time.Elapsed = 2
		TimeAttack.Time.Done = nil
		TimeAttack.Time.Working = true
		TimeAttack.Time.Tick = 0
		
		TimeAttack.Time.FinishOkey = false
		TimeAttack.Time.FinishSaved = false
		TimeAttack.Time.FinishDamage = nil
		TimeAttack.Time.FinishTime = TimeAmount.value
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

end

function TimeAttack:CheckTimeAttackTutorial()
	--TimeAttack:SetTutorialCVar ("TIME_ATTACK_TUTORIAL1", nil)
	if (not TimeAttack:GetTutorialCVar ("TIME_ATTACK_TUTORIAL1")) then
		TimeAttackFrame:RegisterEvent ("PLAYER_TARGET_CHANGED")
	end
end

function TimeAttack:CheckTargetForTutorial()
	local guid = UnitGUID ("target")
	if (guid) then
		local mobid = tonumber (guid:sub (6, 10), 16)
		if (mobid == 31144 or mobid == 32666 or mobid == 31146 or mobid == 32667 or mobid == 67127 or mobid == 46647) then 
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

function TimeAttack:OnEvent (_, event, ...)

	if (event == "PLAYER_TARGET_CHANGED") then
		TimeAttack:CheckTargetForTutorial()

	elseif (event == "ADDON_LOADED") then
		local AddonName = select (1, ...)
		if (AddonName == "Details_TimeAttack") then
			
			if (_G._detalhes) then

				local MINIMAL_DETAILS_VERSION_REQUIRED = 1
				
				local default_settings = {
					time = 60, 
					dps = 0, 
					history = {},
				}
				
				if (_detalhes_databaseTimeAttack) then
					default_settings.history = _detalhes_databaseTimeAttack.history
					_detalhes_databaseTimeAttack = nil
				end
				
				--> Install
				local install, saveddata = _G._detalhes:InstallPlugin ("SOLO", Loc ["STRING_PLUGIN_NAME"], "Interface\\Icons\\SPELL_HOLY_BORROWEDTIME", TimeAttack, "DETAILS_PLUGIN_TIME_ATTACK", MINIMAL_DETAILS_VERSION_REQUIRED, "Details! Team", "v1.04", default_settings)
				if (type (install) == "table" and install.error) then
					print (install.errortext)
					return
				end
				
				--> Register needed events
				_G._detalhes:RegisterEvent (TimeAttack, "COMBAT_PLAYER_ENTER")
				
				--> create widgets
				CreatePluginFrames()
				
			end
		end
	end
end
