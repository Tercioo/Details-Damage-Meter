local AceLocale = LibStub ("AceLocale-3.0")
local Loc = AceLocale:GetLocale ("Details_Vanguard")

---------------------------------------------------------------------------------------------
local _GetTime = GetTime --> wow api local
local _UFC = UnitAffectingCombat --> wow api local
local _IsInRaid = IsInRaid --> wow api local
local _IsInGroup = IsInGroup --> wow api local
local _UnitAura = UnitAura --> wow api local
local _UnitName = UnitName --> wow api local
local _UnitGroupRolesAssigned = UnitGroupRolesAssigned --> wow api local
local _UnitHealthMax = UnitHealthMax --> wow api local
local _UnitIsPlayer = UnitIsPlayer --> wow api local
local _UnitClass = UnitClass --> wow api local
local _UnitDebuff = UnitDebuff --> wow api local
---------------------------------------------------------------------------------------------
local _cstr = string.format --> lua library local
local _table_insert = table.insert --> lua library local
local _table_remove = table.remove --> lua library local
local _ipairs = ipairs --> lua library local
local _pairs = pairs --> lua library local
local _math_floor = math.floor --> lua library local
local _math_abs = math.abs --> lua library local
local _math_min = math.min --> lua library local
---------------------------------------------------------------------------------------------

--> Create plugin Object
local Vanguard = _detalhes:NewPluginObject ("Details_Vanguard")
--> Main Frame
local VanguardFrame = Vanguard.Frame

--> Create plugin objects, function and widgets
local function CreatePluginFrames (data)

	--> catch Details! main object
	local _detalhes = _G._detalhes
	local DetailsFrameWork = _detalhes.gump

	--> any saved data cames here
	Vanguard.data = data or {}
	
	--> main locals
	local _combat_object = nil --> demais current combat object
	local _track_player_object = nil --> Damage Actor in current damage object
	local _track_player_unit = "player" --> current tracking unit
	local _track_player_name = _UnitName (_track_player_unit) --> current tracking unit name
	local instancia --> instancia object (details window)
	local MyName = _UnitName ("player") --> player name
	
	--> running yes or not
	Vanguard.Running = false
	
	--> window size requirements
	Vanguard.MinWidth = 300
	Vanguard.MinHeight = 100
	
	--> OnDetailsEvent Parser
	function Vanguard:OnDetailsEvent (event, ...)
	
		if (event == "HIDE") then --> plugin hidded, disabled
			VanguardFrame:SetScript ("OnUpdate", nil) 
			VanguardFrame:UnregisterEvent ("ROLE_CHANGED_INFORM")
			VanguardFrame:UnregisterEvent ("RAID_ROSTER_UPDATE")
			VanguardFrame:UnregisterEvent ("PLAYER_TARGET_CHANGED")
			Vanguard:Cancel()
			
		elseif (event == "SHOW") then --> plugin shown, enabled
		
			instancia = _detalhes.RaidTables.instancia
			for index, tankframe in _ipairs (Vanguard.TankFrames) do 
				DetailsFrameWork:RegisterForDetailsMove (tankframe.Frame.frame, instancia)
			end
			DetailsFrameWork:RegisterForDetailsMove (VanguardFrame ["DamageRowBackground"].frame, instancia)
			
			Vanguard:OnResize()
			
			VanguardFrame:RegisterEvent ("ROLE_CHANGED_INFORM")
			VanguardFrame:RegisterEvent ("RAID_ROSTER_UPDATE")
			VanguardFrame:RegisterEvent ("PLAYER_TARGET_CHANGED")
			
			Vanguard:ResetBars()
			Vanguard:ResetDamage()
			Vanguard:ResetDebuffs()
			
			Vanguard:IdentifyTanks()
			
			if (Vanguard:IsInCombat()) then
				instancia = _detalhes.RaidTables.instancia
				_combat_object = _detalhes.tabela_vigente
				_track_player_object = nil
				_track_player_name = nil
				Vanguard.Running = true
				
				VanguardFrame:RegisterEvent ("PLAYER_TARGET_CHANGED")
				
				Vanguard:Start()
			end
			
		elseif (event == "REFRESH") then --> requested a refresh window
			-->

		elseif (event == "COMBAT_PLAYER_ENTER") then --> a new combat has been started
		
			instancia = _detalhes.RaidTables.instancia
			_combat_object = select (1, ...)
			_track_player_object = nil
			_track_player_name = nil
			Vanguard.Running = true
			
			VanguardFrame:RegisterEvent ("UNIT_HEALTH")
			
			Vanguard:Start()
			
		elseif (event == "DETAILS_INSTANCE_ENDRESIZE" or event == "DETAILS_INSTANCE_SIZECHANGED") then
			Vanguard:OnResize()
			
		elseif (event == "DETAILS_INSTANCE_STARTSTRETCH") then
			VanguardFrame:SetFrameStrata ("TOOLTIP")
			VanguardFrame:SetFrameLevel (instancia.baseframe:GetFrameLevel()+1)

		elseif (event == "DETAILS_INSTANCE_ENDSTRETCH") then
			VanguardFrame:SetFrameStrata ("MEDIUM")
			Vanguard:OnResize()
		
		elseif (event == "COMBAT_PLAYER_LEAVE") then --> current combat has finished
		
			_combat_object = select (1, ...)
			
			Vanguard.Running = false
			VanguardFrame:SetScript ("OnUpdate", onupdate)
			
			Vanguard:ResetBars()
			Vanguard:ResetDamage()
			Vanguard:ResetDebuffs()
			
			VanguardFrame:UnregisterEvent ("UNIT_HEALTH")
			
			for i = 1, 3 do 
				Vanguard.TankFrames [i].Life (100)
			end
			
		end
	end
	
	function Vanguard:OnResize()
	
		local w, h = instancia:GetSize()
		VanguardFrame:SetHeight (h)
		Vanguard:OnResizeDamageLabels()
		Vanguard:OnResizeTankBoxes()
		
		Vanguard.DamageVsHeal.width = w - 6
		Vanguard.TookVsAvoid.width = w - 6
		
		if (h >= 95) then
			--> show two bars
			Vanguard.DamageVsHeal:Show()
			Vanguard.TookVsAvoid:Show()
			--> show last hit box
			Vanguard.LastHitsBackground:Show()
			Vanguard.LastHitsBackground:SetPoint ("topleft", VanguardFrame, 2, -35)
			--> show tank boxes
			for i = 1, Vanguard.TankFrames.Spots do 
				Vanguard.TankFrames [i].Frame:SetPoint ("bottomleft", VanguardFrame, 2 + ((i-1)*95), 0)
			end

			return
		end
		
		if (h < 95 and h >= 60) then
			--> hide two bars
			Vanguard.DamageVsHeal:Hide()
			Vanguard.TookVsAvoid:Hide()
			--> move up last hit box
			Vanguard.LastHitsBackground:Show()
			Vanguard.LastHitsBackground:SetPoint (3, -3)
			--> move up the 3 tank boxes
			for i = 1, Vanguard.TankFrames.Spots do 
				Vanguard.TankFrames [i].Frame:SetPoint ("bottomleft", VanguardFrame, 2 + ((i-1)*95), 0)
			end
			
			return
		end
		
		if (h < 60) then
			--> hide two bars (hide again due stretch)
			Vanguard.DamageVsHeal:Hide()
			Vanguard.TookVsAvoid:Hide()
			--> hide last hit box
			Vanguard.LastHitsBackground:Hide()
			--> move up the 3 tank boxes
			for i = 1, Vanguard.TankFrames.Spots do 
				Vanguard.TankFrames [i].Frame:SetPoint ("bottomleft", VanguardFrame, 2 + ((i-1)*95), 0)
			end
		end
	end
	
	function Vanguard:HealthChanged (unitId)
		if (Vanguard.TankListHash [unitId]) then
			Vanguard:UpdateHealth (Vanguard.TankListHash [unitId], unitId)
		end
	end
	
	--> list with tank names
	Vanguard.TankList = {} --> indexes
	Vanguard.TankListHash = {} --> name hash
	
	--> search for tanks in the raid or party group 
	function Vanguard:IdentifyTanks()
	
		table.wipe (Vanguard.TankList)
		table.wipe (Vanguard.TankListHash)
		
		if (IsInRaid()) then
		
			local playerName = _UnitName ("player")
		
			for i = 1, GetNumGroupMembers(), 1 do
				local role = _UnitGroupRolesAssigned ("raid"..i)
				if (role == "TANK") then
					local tankName = _UnitName ("raid"..i)
					if (tankName == playerName) then
						playerName = "SELFISTANK"
					end
					Vanguard.TankList [#Vanguard.TankList+1] = tankName
					Vanguard.TankListHash ["raid"..i] = #Vanguard.TankList
					if (#Vanguard.TankList == 5) then
						break
					end
				end
			end
			
			if (#Vanguard.TankList < 5 and playerName ~= "SELFISTANK") then
				Vanguard.TankList [#Vanguard.TankList+1] = _UnitName ("player")
				Vanguard.TankListHash ["player"] = #Vanguard.TankList
			end
			
		elseif (IsInGroup()) then
		
			local playerName = _UnitName ("player")
		
			for i = 1, GetNumGroupMembers()-1, 1 do
				local role = _UnitGroupRolesAssigned ("party"..i)
				if (role == "TANK") then
					local tankName = _UnitName ("party"..i)
					if (tankName == playerName) then
						playerName = "SELFISTANK"
					end
					Vanguard.TankList [#Vanguard.TankList+1] = tankName
					Vanguard.TankListHash ["party"..i] = #Vanguard.TankList
					if (#Vanguard.TankList == 5) then
						break
					end
				end
			end
			
			if (#Vanguard.TankList < 5 and playerName ~= "SELFISTANK") then
				Vanguard.TankList [#Vanguard.TankList+1] = _UnitName ("player")
				Vanguard.TankListHash ["player"] =#Vanguard.TankList
			end
		
		else
			Vanguard.TankList [#Vanguard.TankList+1] = _UnitName ("player")
			Vanguard.TankListHash ["player"] =#Vanguard.TankList
		end
		
		for index, tankname in _ipairs (Vanguard.TankList) do 
			Vanguard.TankFrames [index]:SetTank (tankname)
		end
		
		for i = #Vanguard.TankList+1, 5 do
			Vanguard.TankFrames [i]:SetTank (nil, i)
		end
		
	end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> Build Frames and Gadgets
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	--> Vanguard frame attributes
	--[[
		VanguardFrame:SetBackdrop ({
				bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
				tile = true, tileSize = 16,
				insets = {left = 1, right = 1, top = 0, bottom = 1},})
		VanguardFrame:SetBackdropColor (.3, .3, .3, .3)
--]]

		VanguardFrame:SetWidth (300)
		VanguardFrame:SetHeight (100)

-------> Build two splits bars for damage vs heal and avoid vs hits --------------------------------------------------------------------------------------------------
		
	--> Damage Vs Healing bar
	
		local infoFrame = DetailsFrameWork:NewPanel (VanguardFrame, VanguardFrame, "VanguardInfoFrame", "infoFrame", 300, 100)
		infoFrame:SetPoint ("topleft", VanguardFrame, "topleft")
		infoFrame:Hide()
		infoFrame:SetFrameLevel (5)
		VanguardFrame.InfoShown = false
		
		infoFrame:SetBackdrop ("Interface\\DialogFrame\\UI-DialogBox-Background-Dark")
		infoFrame:SetBackdropColor ("black")
		infoFrame:SetGradient ("OnEnter", "black")
		
		local c = infoFrame:CreateRightClickLabel()
		c:SetPoint ("bottomright", infoFrame, "bottomright", -3, 1)
		
		--> report button
		local reportFunc = function (IsCurrent, IsReverse, AmtLines)
			local lines = {	Loc ["STRING_REPORT"]..": " .. Loc ["STRING_REPORT_AVOIDANCE"] .. ": " .. MyName,
						Loc ["STRING_HITS"] .. ": " .. infoFrame ["hitsReceivedAmount"].text,
						Loc ["STRING_DODGE"] .. ": " .. infoFrame ["dodgeAmount"].text,
						Loc ["STRING_PARRY"] .. ": " .. infoFrame ["parryAmount"].text,
						Loc ["STRING_DAMAGETAKEN"] .. ": " .. infoFrame ["damageTakenAmount"].text,
						Loc ["STRING_DTPS"] .. ": " .. infoFrame ["damageTakenSecAmount"].text
						}
			Vanguard:SendReportLines (lines)
		end

		--[1] fucntion wich will build report lines after click on 'Send Button' [2] enable current button [3] enable reverse button
		local ReportButton = DetailsFrameWork:NewButton (infoFrame, nil, "DetailsVanguardAvoidanceReportButton", "ReportButton", 20, 20, function() Vanguard:SendReportWindow (reportFunc) end)
		ReportButton.texture = "Interface\\COMMON\\VOICECHAT-ON"
		ReportButton:SetPoint ("topright", infoFrame, "topright", -5, -1)
		ReportButton.tooltip = Loc ["STRING_REPORT_AVOIDANCE_TOOLTIP"]
		
		infoFrame:SetHook ("OnMouseUp", function (_, button) 
			if (string.lower (button):find ("right")) then
				VanguardFrame.InfoShown = false
				infoFrame:Hide()
				if (infoFrame.refreshTick) then
					Vanguard:CancelTimer (infoFrame.refreshTick)
					infoFrame.refreshTick = nil
				end
			end
		end)
	
		local funcInfo = function() 
			VanguardFrame.InfoShown = true
			Vanguard:VanguardRefreshInfoFrame()
			local w, h = instancia:GetSize()
			infoFrame.width = w
			infoFrame.height = h
			infoFrame:Show()
			infoFrame.refreshTick = Vanguard:ScheduleRepeatingTimer ("VanguardRefreshInfoFrame", 1)
		end
		
		--> Info frame widgets:
			local healReceived = DetailsFrameWork:NewLabel (infoFrame, nil, "VanguardInfoHealReceived", nil, Loc ["STRING_HEALRECEIVED"]..":", "GameFontHighlightSmall", 9.5)
			healReceived:SetPoint (10, -5)
			local healReceivedNumber = DetailsFrameWork:NewLabel (infoFrame, nil, "VanguardInfoHealReceivedAmount", nil, "0", "GameFontHighlightSmall", 9.5)
			healReceivedNumber:SetPoint ("left", healReceived, "right", 2)
			
			local healPerSecond = DetailsFrameWork:NewLabel (infoFrame, nil, "VanguardInfoHealHps", nil, Loc ["STRING_HPS"]..":", "GameFontHighlightSmall", 9.5)
			healPerSecond:SetPoint (10, -20)
			local healPerSecondNumber = DetailsFrameWork:NewLabel (infoFrame, nil, "VanguardInfoHealHealHpsAmount", nil, "0", "GameFontHighlightSmall", 9.5)
			healPerSecondNumber:SetPoint ("left", healPerSecond, "right", 2)
			
			local icon1 = DetailsFrameWork:NewImage (infoFrame, nil, "VanguardInfoHealTop1Icon", nil, 14, 14)
			local topHealer1 = DetailsFrameWork:NewLabel (infoFrame, nil, "VanguardInfoHealTop1", nil, "", "GameFontHighlightSmall", 9.5)
			topHealer1:SetWidth (80)
			topHealer1:SetHeight (10)
			local topHealer1Amount = DetailsFrameWork:NewLabel (infoFrame, nil, "VanguardInfoHealTop1Amount", nil, "", "GameFontHighlightSmall", 9.5)
			icon1:SetPoint (10, -35)
			topHealer1:SetPoint ("left", icon1, "right", 2)
			topHealer1Amount:SetPoint ("left", topHealer1, "right", 2)
			
			local icon2 = DetailsFrameWork:NewImage (infoFrame, nil, "VanguardInfoHealTop2Icon", nil, 14, 14)
			local topHealer2 = DetailsFrameWork:NewLabel (infoFrame, nil, "VanguardInfoHealTop2", nil, "", "GameFontHighlightSmall", 9.5)
			topHealer2:SetWidth (80)
			topHealer2:SetHeight (10)
			local topHealer2Amount = DetailsFrameWork:NewLabel (infoFrame, nil, "VanguardInfoHealTop2Amount", nil, "", "GameFontHighlightSmall", 9.5)
			icon2:SetPoint (10, -50)
			topHealer2:SetPoint ("left", icon2, "right", 2)
			topHealer2Amount:SetPoint ("left", topHealer2, "right", 2)
			
			local icon3 = DetailsFrameWork:NewImage (infoFrame, nil, "VanguardInfoHealTop3Icon", nil, 14, 14)
			local topHealer3 = DetailsFrameWork:NewLabel (infoFrame, nil, "VanguardInfoHealTop3", nil, "", "GameFontHighlightSmall", 9.5)
			topHealer3:SetWidth (80)
			topHealer3:SetHeight (10)
			local topHealer3Amount = DetailsFrameWork:NewLabel (infoFrame, nil, "VanguardInfoHealTop3Amount", nil, "", "GameFontHighlightSmall", 9.5)
			icon3:SetPoint (10, -64)
			topHealer3:SetPoint ("left", icon3, "right", 2)
			topHealer3Amount:SetPoint ("left", topHealer3, "right", 2)
			
			local icon4 = DetailsFrameWork:NewImage (infoFrame, nil, "VanguardInfoHealTop4Icon", nil, 14, 14)
			local topHealer4 = DetailsFrameWork:NewLabel (infoFrame, nil, "VanguardInfoHealTop4", nil, "", "GameFontHighlightSmall", 9.5)
			topHealer4:SetWidth (80)
			topHealer4:SetHeight (10)
			local topHealer4Amount = DetailsFrameWork:NewLabel (infoFrame, nil, "VanguardInfoHealTop4Amount", nil, "", "GameFontHighlightSmall", 9.5)
			icon4:SetPoint (10, -80)
			topHealer4:SetPoint ("left", icon4, "right", 2)
			topHealer4Amount:SetPoint ("left", topHealer4, "right", 2)
			
			local iconTable = {icon1, icon2, icon3, icon4}
			local healerTable = {topHealer1, topHealer2, topHealer3, topHealer4}
			local healerAmountTable = {topHealer1Amount, topHealer2Amount, topHealer3Amount, topHealer4Amount}

			local hitsReceived = DetailsFrameWork:NewLabel (infoFrame, nil, "VanguardInfoHitsReceived", nil, Loc ["STRING_HITS"], "GameFontHighlightSmall", 9.5)
			hitsReceived:SetPoint (150, -5)
			local hitsReceivedAmount = DetailsFrameWork:NewLabel (infoFrame, nil, "VanguardInfoHitsReceivedAmount", "hitsReceivedAmount", "0", "GameFontHighlightSmall", 9.5)
			hitsReceivedAmount:SetPoint ("left", hitsReceived, "right", 2)
			
			local dodge = DetailsFrameWork:NewLabel (infoFrame, nil, "VanguardInfoDodge", nil, Loc ["STRING_DODGE"], "GameFontHighlightSmall", 9.5)
			dodge:SetPoint (150, -20)
			local dodgeAmount = DetailsFrameWork:NewLabel (infoFrame, nil, "VanguardInfoDodgeAmount", "dodgeAmount", "0", "GameFontHighlightSmall", 9.5)
			dodgeAmount:SetPoint ("left", dodge, "right", 2)
			
			local parry = DetailsFrameWork:NewLabel (infoFrame, nil, "VanguardInfoParry", nil, Loc ["STRING_PARRY"], "GameFontHighlightSmall", 9.5)
			parry:SetPoint (150, -35)
			local parryAmount = DetailsFrameWork:NewLabel (infoFrame, nil, "VanguardInfoParryAmount", "parryAmount", "0", "GameFontHighlightSmall", 9.5)
			parryAmount:SetPoint ("left", parry, "right", 2)
			
			local damageTaken = DetailsFrameWork:NewLabel (infoFrame, nil, "VanguardInfoDamageTaken", nil, Loc ["STRING_DAMAGETAKEN"], "GameFontHighlightSmall", 9.5)
			damageTaken:SetPoint (150, -50)
			local damageTakenAmount = DetailsFrameWork:NewLabel (infoFrame, nil, "VanguardInfoDamageTakenAmount", "damageTakenAmount", "0", "GameFontHighlightSmall", 9.5)
			damageTakenAmount:SetPoint ("left", damageTaken, "right", 2)
			
			local damageTakenSec = DetailsFrameWork:NewLabel (infoFrame, nil, "VanguardInfoDamageSec", nil, Loc ["STRING_DTPS"], "GameFontHighlightSmall", 9.5)
			damageTakenSec:SetPoint (150, -65)
			local damageTakenSecAmount = DetailsFrameWork:NewLabel (infoFrame, nil, "VanguardInfoDamageTakenSecAmount", "damageTakenSecAmount", "0", "GameFontHighlightSmall", 9.5)
			damageTakenSecAmount:SetPoint ("left", damageTakenSec, "right", 2)
		----------
		--> need to be a member of _detalhes bacause we want to use a schedule timer
		--> once a member of _detalhes we can call through plugin object like Vanguard:VanguardRefreshInfoFrame()
		_detalhes.VanguardRefreshInfoFrame = function()
			
			--> data mine
				
				--> Get heal actor
					local actorHeal = Vanguard:GetActor ("current", DETAILS_ATTRIBUTE_HEAL, _track_player_name) --> [1] combat [2] attribute [3] name
					local combat = Vanguard:GetCombat ("current")
					
					if (actorHeal) then
						--> members can be found at details/classes/classe_heal line 75
						healReceivedNumber.text = Vanguard:ToK (actorHeal.healing_taken or 0)
						healPerSecondNumber.text = Vanguard:ToK (actorHeal.healing_taken / combat:GetCombatTime())
						
						local heal_from = actorHeal.healing_from --> table with [name] = true
						local myReceivedHeal = {}
						
						for actorName, _ in pairs (heal_from) do 
							local thisActor = Vanguard:GetActor ("current", DETAILS_ATTRIBUTE_HEAL, actorName)
							local targets = thisActor.targets --> targets is a container with target classes
							local amount = targets:GetAmount (_track_player_name, "total")
							myReceivedHeal [#myReceivedHeal+1] = {actorName, amount}
						end
						
						table.sort (myReceivedHeal, Vanguard.Sort2) --> Sort2 sort by second index
						
						for i = 1, 4 do 
							if (myReceivedHeal[i]) then
								healerTable [i].text = myReceivedHeal[i][1]..":"
								healerAmountTable[i].text = Vanguard:ToK (myReceivedHeal[i][2] or 0)
								iconTable [i].texture = Vanguard.class_icons_small
								
								local _, L, R, T, B =   Vanguard:GetClass (myReceivedHeal[i][1])
								if (L) then
									iconTable [i]:SetTexCoord (L, R, T, B)
								end
							else
								iconTable [i].texture = nil
								healerTable [i].text = "-- -- --"
								healerAmountTable[i].text = ""
							end
						end
					else
						--> reset
						healReceivedNumber.text = "0"
						healPerSecondNumber.text = "0"
						for i = 1, 4 do 
							iconTable [i].texture = nil
							healerTable [i].text = "-- -- --"
							healerAmountTable[i].text = ""
						end
					end
				
				--> Get damage actor
					local actorDamage = Vanguard:GetActor ("current", DETAILS_ATTRIBUTE_DAMAGE, _track_player_name) --> [1] combat [2] attribute [3] name
					if (actorDamage) then
						--> members can be found at details/classes/classe_damage line 75
						local avoidance = actorDamage.avoidance --> table with DODGE, PARRY, HITS members

						local totalAvoid = avoidance.DODGE + avoidance.PARRY
						local totalOver = totalAvoid + avoidance.HITS
						
						if (totalOver > 0) then
							hitsReceivedAmount.text = avoidance.HITS .. " (" .. _math_floor (avoidance.HITS / totalOver * 100) .. "%)"
							dodgeAmount.text = avoidance.DODGE .. " (" .. _math_floor (avoidance.DODGE / totalOver * 100) .. "%)"
							parryAmount.text = avoidance.PARRY .. " (" .. _math_floor (avoidance.PARRY / totalOver * 100) .. "%)"
						else
							hitsReceivedAmount.text = "0 (0%)"
							dodgeAmount.text = "0 (0%)"
							parryAmount.text = "0 (0%)"
						end
						
						damageTakenAmount.text = Vanguard:ToK (actorDamage.damage_taken)
						damageTakenSecAmount.text = Vanguard:ToK (actorDamage.damage_taken / combat:GetCombatTime())
					else
						hitsReceivedAmount.text = "0"
						dodgeAmount.text = "0"
						parryAmount.text = "0"
						damageTakenAmount.text = "0"
						damageTakenSecAmount.text = "0"
					end
		
		end
		
		local DamageVsHeal = DetailsFrameWork:NewSplitBar (VanguardFrame, VanguardFrame, "VanguardDamageVsHealBar", "DamageVsHealBar", 294, 14)
		
		DamageVsHeal:SetPoint (3, -3)
		
		DamageVsHeal.fontsize = 10
		DamageVsHeal.lefticon = "Interface\\ICONS\\misc_arrowright"
		DamageVsHeal.righticon = "Interface\\ICONS\\misc_arrowleft"
		DamageVsHeal.tooltip = Loc ["STRING_HEALVSDAMAGETOOLTIP"]
		DamageVsHeal:SetHook ("OnMouseUp", funcInfo)
		
		DamageVsHeal.iconleft:SetVertexColor (.5, 1, .5, 1)
		DamageVsHeal.iconright:SetVertexColor (1, .5, .5, 1)
		
		Vanguard.DamageVsHeal = DamageVsHeal

	--> Hits vs Avoidance bar
		local TookVsAvoid = DetailsFrameWork:NewSplitBar (VanguardFrame, VanguardFrame, "VanguardTookVsAvoidBar", "TookVsAvoidBar", 294, 14)
		TookVsAvoid:SetPoint ("topleft", VanguardFrame, 3, -18)
		TookVsAvoid.lefticon = "Interface\\TIMEMANAGER\\RWButton"
		TookVsAvoid.righticon = "Interface\\TIMEMANAGER\\FFButton"
		TookVsAvoid.tooltip = Loc ["STRING_AVOIDVSHITSTOOLTIP"]
		TookVsAvoid:SetHook ("OnMouseUp", funcInfo)
		
		TookVsAvoid.iconleft:SetWidth (18)
		TookVsAvoid.iconleft:SetHeight (18)
		TookVsAvoid.iconleft:SetPoint ("left", VanguardTookVsAvoidBar, "left", -2, 0)
		TookVsAvoid.iconright:SetWidth (18)
		TookVsAvoid.iconright:SetHeight (18)
		TookVsAvoid.iconright:SetPoint ("right", VanguardTookVsAvoidBar, "right", 3, 0)
		
		Vanguard.TookVsAvoid = TookVsAvoid
		
	--> Reset both splits bars
		function Vanguard:ResetBars()
			
			TookVsAvoid:SetSplit (50)
			TookVsAvoid:SetLeftText ("Avoid") --> localize-me
			TookVsAvoid:SetRightText ("Hits") --> localize-me
			TookVsAvoid:SetRightColor (.25, 0, 0, 1) --> .1, .5, .5, 1 cor boa pr pet
			TookVsAvoid:SetLeftColor (0, .25, 0, 1)
			
			DamageVsHeal:SetSplit (50)
			DamageVsHeal:SetLeftText ("Inc Heal") --> localize-me
			DamageVsHeal:SetRightText ("Inc Damage") --> localize-me
			DamageVsHeal:SetLeftColor (.1, .9, .1, 1)
			DamageVsHeal:SetRightColor (.9, .1, .1, 1)
		end
		
---------> build damage text entries ---------------------------------------------------------------------------------------------------------------------------------------------------------

		--> entry functions
			Vanguard.DamageLabels = {}
			Vanguard.DamageLabels.Spots = 6
			
			function Vanguard:InsertDamage (damage, index, hp)
				Vanguard.DamageLabels [index]:SetText (_detalhes:ToK (damage))
				local percent = damage / hp
				local abs = _math_abs (percent-1)
				Vanguard.DamageLabels [index]:SetTextColor (1, abs, abs, 1)
			end
			
			function Vanguard:ResetDamage()
				for i = 1, Vanguard.DamageLabels.Spots do
					Vanguard.DamageLabels [i]:SetText ("0.0k")
					Vanguard.DamageLabels [i]:SetTextColor (1, 1, 1, 1)
					Vanguard.DamageLabels [i]:Show()
				end
				for i = Vanguard.DamageLabels.Spots + 1, #Vanguard.DamageLabels do
					Vanguard.DamageLabels [i]:Hide()
				end
			end
			
		--> bg frame
			local LastHitsBackground = DetailsFrameWork:NewPanel (VanguardFrame, _, "DetailsVanguardRowBackground", "DamageRowBackground", 296, 20)
			LastHitsBackground:SetPoint ("topleft", VanguardFrame, 2, -35)
			LastHitsBackground.tooltip = Loc ["STRING_DAMAGESCROLL"]
			Vanguard.LastHitsBackground = LastHitsBackground
			
		--> labels
		
			for i = 1, Vanguard.DamageLabels.Spots do
				local ThisLabel = DetailsFrameWork:NewLabel (LastHitsBackground, Vanguard, nil, "DamageLabel"..i, "0.0k", "GameFontHighlightSmall", 11, {1, 1, 1, 1})
				Vanguard.DamageLabels [i] = ThisLabel
				ThisLabel:SetPoint ("left", LastHitsBackground.frame, 9 + ((i-1)*50), 0)
			end
			
			function Vanguard:OnResizeDamageLabels()
				local w, h = instancia:GetSize()
				LastHitsBackground.width = w - 6
				
				local amt = math.floor (w / 50)
				
				if (amt > Vanguard.DamageLabels.Spots) then
					for i = Vanguard.DamageLabels.Spots + 1, amt do
						local ThisLabel = DetailsFrameWork:NewLabel (LastHitsBackground, Vanguard, nil, "DamageLabel"..i, "0.0k", "GameFontHighlightSmall", 11, {1, 1, 1, 1})
						Vanguard.DamageLabels [i] = ThisLabel
						ThisLabel:SetPoint ("left", LastHitsBackground.frame, 9 + ((i-1)*50), 0)
					end
				end
				
				Vanguard.DamageLabels.Spots = amt
				Vanguard:ResetDamage()
			end			
	
	
---------> build 3 tanks debuff frames -------------------------------------------------------------------------------------------------------------------------------------------------------

		local tankframemeta = {}
		tankframemeta.__index = tankframemeta
		
		
		
		--> update tank information
		function tankframemeta:SetTank (name, index)
			if (not name) then
				self.name = nil
				self.TankName:SetText ("Tank "..index)
				self.Frame:SetBackdropBorderColor (.5, .5, .5, 1)
				
			else
				self.name = name
				self.TankName:SetText (name)
				
				-- GetClass return [1] unlocalized class [2-5] TexCoords [6-8] RGB colors
				local class, L, R, T, B, Red, Green, Blue = Vanguard:GetClass (name)
				if (class) then
					local color = RAID_CLASS_COLORS [class]
					self.Frame:SetBackdropBorderColor (Red, Green, Blue, 1)
					self.Frame:SetBackdropColor (Red, Green, Blue, 1)
					self.Frame.tanknamebg:SetVertexColor (Red, Green, Blue, .8)
				end
			end

			self:Disable()
		end
		
		--> refresh debuff information
		function tankframemeta:Update (index, icon, expire, count, name)
		
			if (not icon) then
				self ["Icon"..index]:SetTexture (nil)
				self ["Icon"..index.."DurationText"]:SetText ("")
				self ["Icon"..index.."StackText"]:SetText ("")
				self ["BlackBG"..index]:Hide()
				self ["Icon"..index.."Frame"].tooltip = nil
				
				local debuffName = self.DebuffsName [index]
				self.DebuffsName [index] = nil
				self.DebuffsIndex [debuffName] = nil
				self.FreeSpots [index] = true
				self.InUse = self.InUse - 1
				return
			end
			
			self ["Icon"..index]:SetTexture (icon)
			local minutos, segundos = _math_floor (expire/60), _math_floor (expire%60)
			if (minutos > 0) then
				self ["Icon"..index.."DurationText"]:SetText (minutos..":"..segundos)
				Vanguard:SetFontSize (self ["Icon"..index.."DurationText"], 10)
				self ["Icon"..index.."Frame"].tooltip = Loc ["STRING_DEBUFF"] .. ": " .. name .. "\n" .. Loc ["STRING_DURATION"] .. ":" .. minutos..":"..segundos
			else
				self ["Icon"..index.."DurationText"]:SetText (_math_floor (expire))
				Vanguard:SetFontSize (self ["Icon"..index.."DurationText"], 18)
				self ["Icon"..index.."Frame"].tooltip = Loc ["STRING_DEBUFF"] .. ": " .. name .. "\n" .. Loc ["STRING_DURATION"] .. ":" .. _math_floor (expire)
			end
			self ["Icon"..index.."StackText"]:SetText (count)
			self ["BlackBG"..index]:Show()
		end
		
		--> clear all texts and icons
		function tankframemeta:Disable()
			self.Icon1:SetTexture (nil)
			self.Icon1DurationText:SetText ("")
			self.Icon1StackText:SetText ("")
			self.Icon1Frame.tooltip = nil
			self.BlackBG1:Hide()
			
			self.Icon2:SetTexture (nil)
			self.Icon2DurationText:SetText ("")
			self.Icon2StackText:SetText ("")
			self.Icon2Frame.tooltip = nil
			self.BlackBG2:Hide()
			
			self.Icon3:SetTexture (nil)
			self.Icon3DurationText:SetText ("")
			self.Icon3StackText:SetText ("")
			self.Icon3Frame.tooltip = nil
			self.BlackBG3:Hide()
			
			table.wipe (self.DebuffsName)
			table.wipe (self.DebuffsIndex)
			for i = 1, 3 do 
				self.FreeSpots [i] = true
			end
			self.InUse = 0
		end

		function Vanguard:ResetDebuffs()
			for _, TankFrame in _ipairs (Vanguard.TankFrames) do
				TankFrame:Disable()
			end
		end
	
		function Vanguard:UpdateHealth (index, unit)
			local percent = UnitHealth (unit) / UnitHealthMax (unit) * 100
			Vanguard.TankFrames [index].Life (percent)
		end
	
		--> build the boxes
		Vanguard.TankFrames = {}
		Vanguard.TankFrames.Spots = 5
		
		local iconMouseOver = function (iconFrame)
			iconFrame.icon:SetBlendMode ("ADD")
			local OnEnterColors = iconFrame.parent.Gradient.OnEnter
			local _r, _g, _b, _a = iconFrame.parent:GetBackdropColor()
			DetailsFrameWork:GradientEffect (iconFrame.parent, "frame", _r, _g, _b, _a, OnEnterColors[1], OnEnterColors[2], OnEnterColors[3], OnEnterColors[4], .3)
		end
		local iconMouseOut = function (iconFrame)
			iconFrame.icon:SetBlendMode ("BLEND")
			local _r, _g, _b, _a = iconFrame.parent:GetBackdropColor()
			if (_r) then
				local OnLeaveColors = iconFrame.parent.Gradient.OnLeave
				DetailsFrameWork:GradientEffect (iconFrame.parent, "frame", _r, _g, _b, _a, OnLeaveColors[1], OnLeaveColors[2], OnLeaveColors[3], OnLeaveColors[4], .3)
			end
		end
		
		for i = 1, Vanguard.TankFrames.Spots do
		
			local ThisBoxObject = {}
			setmetatable (ThisBoxObject, tankframemeta)
			
			ThisBoxObject.DebuffsIndex = {}
			ThisBoxObject.DebuffsName = {}
			ThisBoxObject.FreeSpots = {true, true, true}
			ThisBoxObject.InUse = 0

			local Frame = DetailsFrameWork:NewPanel (VanguardFrame, nil, "DetailsVanguardFrameBox"..i, _, 95, 40)
			Frame:SetPoint ("bottomleft", VanguardFrame, 2 + ((i-1)*95), 0)
			Frame.color = {.1, .1, .1, 1}
			ThisBoxObject.Frame = Frame
			
			local life = DetailsFrameWork:NewBar (Frame, Frame, "DetailsVanguardFrameBox"..i.."Life", nil, 91, 36, 100)
			life:SetPoint (Frame, 2, -2)
			life:SetFrameLevel (-1, Frame)
			ThisBoxObject.Life = life
			
			local tanknameTexture = DetailsFrameWork:NewImage (Frame, Frame, "DetailsVanguardTankName"..i.."bG", "tanknamebg", 80, 10, "Interface\\ACHIEVEMENTFRAME\\UI-Achievement-Parchment-Highlight")
			
			tanknameTexture:SetTexCoord (0.15234375, 0.82421875, 0, 0.2734375)
			tanknameTexture:SetPoint ("center", Frame)
			tanknameTexture:SetPoint ("top", Frame, "top", 0, -3)
			
			
			local tankname = DetailsFrameWork:NewLabel (Frame, Vanguard, nil, "DetailsVanguardTankName"..i, "Tank "..i, "GameFontHighlightSmall", 10, {1, 1, 1, 1})
			tankname:SetPoint ("center", Frame)
			tankname:SetPoint ("top", Frame, "top", 0, -2)
			ThisBoxObject.TankName = tankname

			-------------------------------------------------------------------------------------
			
			local Icon1 = DetailsFrameWork:NewImage (Frame, Vanguard, "DetailsVanguardFrameBox"..i.."Icon1", nil, 24, 24, "Interface\\ICONS\\Ability_Creature_Amber_02")
			Icon1:SetDrawLayer ("overlay", 1)
			Icon1:SetPoint ("bottomleft", ThisBoxObject.Frame.frame, 4, 3)

			local frameIcon1 = DetailsFrameWork:NewPanel (Frame, VanguardFrame, "DetailsVanguardFrameBox"..i.."IconBG1", nil, 24, 24, false)
			frameIcon1:SetPoint (Icon1)
			frameIcon1.widget.icon = Icon1
			frameIcon1.widget.parent = Frame.widget
			frameIcon1:SetHook ("OnEnter", iconMouseOver)
			frameIcon1:SetHook ("OnLeave", iconMouseOut)
			
			local Icon1Text = DetailsFrameWork:NewLabel (ThisBoxObject.Frame.frame, Vanguard, "DetailsVanguardFrameBox"..i.."Text1", nil, "25", "GameFontHighlightLarge", 18, {1, 1, 0, 1})
			Icon1Text:SetPoint ("center", Icon1, "center")
			
			local blackbg1 = DetailsFrameWork:NewImage (Frame, Vanguard, "DetailsVanguardFrameBox"..i.."BlackBG1", nil, 12, 12)
			blackbg1:SetDrawLayer ("overlay", 2)
			blackbg1:SetTexture (0, 0, 0, 1)
			blackbg1:SetPoint ("bottomright", Icon1, 5, -5)
			
			local Icon1Text2 = DetailsFrameWork:NewLabel (Frame, Vanguard, "DetailsVanguardFrameBox"..i.."Text21", nil, "1", "GameFontHighlightSmall", 13, {1, 1, 1, 1})
			Icon1Text2:SetPoint ("center", blackbg1, "center")
			
			ThisBoxObject.Icon1 = Icon1
			ThisBoxObject.Icon1Frame = frameIcon1
			ThisBoxObject.Icon1DurationText = Icon1Text
			ThisBoxObject.Icon1StackText = Icon1Text2
			ThisBoxObject.BlackBG1 = blackbg1
			
			-------------------------------------------------------------------------------------
			
			local Icon2 = DetailsFrameWork:NewImage (Frame, Vanguard, "DetailsVanguardFrameBox"..i.."Icon2", nil, 24, 24, "Interface\\ICONS\\Ability_Creature_Amber_02")
			Icon2:SetDrawLayer ("overlay", 1)
			Icon2:SetPoint ("bottomleft", Frame, 37, 3)
			
			local frameIcon2 = DetailsFrameWork:NewPanel (Frame, VanguardFrame, "DetailsVanguardFrameBox"..i.."IconBG2", nil, 24, 24, false)
			frameIcon2:SetPoint (Icon2)
			frameIcon2.widget.icon = Icon2
			frameIcon2.widget.parent = Frame.widget
			frameIcon2:SetHook ("OnEnter", iconMouseOver)
			frameIcon2:SetHook ("OnLeave", iconMouseOut)
			
			local Icon2Text = DetailsFrameWork:NewLabel (Frame, Vanguard, "DetailsVanguardFrameBox"..i.."Text2", nil, "3", "GameFontHighlightLarge", 18, {1, 1, 0, 1})
			Icon2Text:SetPoint ("center", Icon2, "center")
			
			local blackbg2 = DetailsFrameWork:NewImage (Frame, Vanguard, "DetailsVanguardFrameBox"..i.."BlackBG2", nil, 12, 12)
			blackbg2:SetDrawLayer ("overlay", 2)
			blackbg2:SetTexture (0, 0, 0, 1)
			blackbg2:SetPoint ("bottomright", Icon2, 5, -5)
			
			local Icon2Text2 = DetailsFrameWork:NewLabel (Frame, Vanguard, "DetailsVanguardFrameBox"..i.."Text22", nil, "2", "GameFontHighlightSmall", 13, {1, 1, 1, 1})
			Icon2Text2:SetPoint ("center", blackbg2, "center")
			
			ThisBoxObject.Icon2 = Icon2
			ThisBoxObject.Icon2Frame = frameIcon2
			ThisBoxObject.Icon2DurationText = Icon2Text
			ThisBoxObject.Icon2StackText = Icon2Text2
			ThisBoxObject.BlackBG2 = blackbg2
			
			-------------------------------------------------------------------------------------
			
			local Icon3 = DetailsFrameWork:NewImage (Frame, Vanguard, "DetailsVanguardFrameBox"..i.."Icon3", nil, 24, 24, "Interface\\ICONS\\Ability_Creature_Amber_02")
			Icon3:SetDrawLayer ("overlay", 1)
			Icon3:SetPoint ("bottomleft", ThisBoxObject.Frame.frame, 70, 3)
			
			local frameIcon3 = DetailsFrameWork:NewPanel (Frame, VanguardFrame, "DetailsVanguardFrameBox"..i.."IconBG3", nil, 24, 24, false)
			frameIcon3:SetPoint (Icon3)
			frameIcon3.widget.icon = Icon3
			frameIcon3.widget.parent = Frame.widget
			frameIcon3:SetHook ("OnEnter", iconMouseOver)
			frameIcon3:SetHook ("OnLeave", iconMouseOut)
			
			local Icon3Text = DetailsFrameWork:NewLabel (ThisBoxObject.Frame.frame, Vanguard, "DetailsVanguardFrameBox"..i.."Text3", nil, "5", "GameFontHighlightLarge", 18, {1, 1, 0, 1})
			Icon3Text:SetPoint ("center", Icon3, "center")
			
			local blackbg3 = DetailsFrameWork:NewImage (Frame, Vanguard, "DetailsVanguardFrameBox"..i.."BlackBG3", nil, 12, 12)
			blackbg3:SetDrawLayer ("overlay", 2)
			blackbg3:SetTexture (0, 0, 0, 1)
			blackbg3:SetPoint ("bottomright", Icon3, 5, -5)
			
			local Icon3Text2 = DetailsFrameWork:NewLabel (Frame, Vanguard, "DetailsVanguardFrameBox"..i.."Text23", nil, "3", "GameFontHighlightSmall", 13, {1, 1, 1, 1})
			Icon3Text2:SetPoint ("center", blackbg2, "center")
			
			ThisBoxObject.Icon3 = Icon3
			ThisBoxObject.Icon3Frame = frameIcon3
			ThisBoxObject.Icon3DurationText = Icon3Text
			ThisBoxObject.Icon3StackText = Icon3Text2
			ThisBoxObject.BlackBG3 = blackbg3
			
			Vanguard.TankFrames [#Vanguard.TankFrames+1] = ThisBoxObject
			
			blackbg1:Hide()
			blackbg2:Hide()
			blackbg3:Hide()
		end
	
		function Vanguard:OnResizeTankBoxes()
			local w, h = instancia:GetSize()
			local amt = math.floor (w / 95)

			for i = 1, amt do 
				Vanguard.TankFrames [i].Frame:Show()
			end
			
			for i = amt+1, #Vanguard.TankFrames do
				Vanguard.TankFrames [i].Frame:Hide()
			end
			
			Vanguard.TankFrames.Spots = amt
			
		end
	
-------> Core function --------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	--> cancel function
	function Vanguard:Cancel()
		VanguardFrame:SetScript ("OnUpdate", nil)
		return true
	end
	
	--> when target change, need to verify if the new target is a player, if true, cancel everething and restart
	function Vanguard:TargetChanged()

		local NewTarget = _UnitName ("target")
		if (NewTarget and _UnitIsPlayer ("target")) then
			if (VanguardFrame.InfoShown and not Vanguard.Running) then
				_track_player_name = NewTarget
				Vanguard:VanguardRefreshInfoFrame()
				return
			end
		
			Vanguard:Cancel()
			Vanguard:Start()
		else
			_track_player_name = UnitName ("player")
			
		end
	end

	--> inject into details a delayed function for vanguard
	function _detalhes:VanguardWait()
		Vanguard:Start()
	end
	
	--> main onupdate locals
	local hits_last = 0
	local hits_taken = {}
	local hits_now = 0
	
	local avoid_last = 0
	local avoid_taken = {}
	local avoid_now = 0
	
	local damage_last = 0
	local damage_taken = {}
	local damage_now = 0
	
	local on_second_tick = 0
	local half_second_tick = 0

	local onupdate = function (self, elapsed)
	
		half_second_tick = half_second_tick + elapsed
		on_second_tick = on_second_tick + elapsed
		
		if (on_second_tick >= 1) then
			
			--> capture debuffs
				for TankIndex, TankName in _ipairs (Vanguard.TankList) do 
				
					local ThisTankFrame = Vanguard.TankFrames [TankIndex]
					
					if (not ThisTankFrame) then
						break
					end
					
					local updated = {false, false, false}
					
					for i = 1, 41 do 
					
						-- pega o primeiro debuff
						local name, _, icon, count, _, duration, expirationTime, _, _, _, spellId = _UnitDebuff (TankName, i)
						
						if (name) then
							
							--> already shown?
							local debuffShowingIndex = ThisTankFrame.DebuffsIndex [name]
							if (debuffShowingIndex) then
							
								local expire = expirationTime - _GetTime()
								updated [debuffShowingIndex] = true
								ThisTankFrame:Update (debuffShowingIndex, icon, expire, count, name)
							
							--> have a free slot?
							elseif (ThisTankFrame.InUse < 3) then
							
								local expire = expirationTime - _GetTime()
								if (expire < 180 and expire > 0) then
									for o = 1, 3 do 
										if (ThisTankFrame.FreeSpots [o]) then
											ThisTankFrame.DebuffsIndex [name] = o
											ThisTankFrame.DebuffsName [o] = name
											ThisTankFrame.FreeSpots [o] = false
											ThisTankFrame.InUse = ThisTankFrame.InUse + 1
											updated [o] = true
											ThisTankFrame:Update (o, icon, expire, count, name)
											break
										end
									end
								end
							end
							
						else
							break
						end
					end
					
					for i = 1, 3 do
						if (not updated [i] and ThisTankFrame.DebuffsName [i]) then
							ThisTankFrame:Update (i, false)
						end
					end

				end

			on_second_tick = 0
		end
		
		if (half_second_tick > 0.5) then
			
			--> capture the amount of hits and avoids
			
				_table_insert (hits_taken, 1, _track_player_object.avoidance.HITS - hits_last)
				hits_now = hits_now + (_track_player_object.avoidance.HITS - hits_last)
				if (#hits_taken > 10) then
					hits_now = hits_now - hits_taken [11]
					_table_remove (hits_taken, 11)
				end
				hits_last = _track_player_object.avoidance.HITS
				
				_table_insert (avoid_taken, 1, _track_player_object.avoidance.DODGE + _track_player_object.avoidance.PARRY - avoid_last)
				avoid_now = avoid_now + (_track_player_object.avoidance.DODGE + _track_player_object.avoidance.PARRY - avoid_last)
				if (#avoid_taken > 10) then
					avoid_now = avoid_now - avoid_taken [11]
					_table_remove (avoid_taken, 11)
				end
				avoid_last = _track_player_object.avoidance.DODGE + _track_player_object.avoidance.PARRY
				
			--> compute the hits vs avoid
				
				if (hits_now == 0 and avoid_now == 0) then
					TookVsAvoid:SetLeftText ("50%")
					TookVsAvoid:SetRightText ("50%")
					TookVsAvoid:SetSplit (50)
				else
					local avoidance = avoid_now
				
					local avoid_percentage = _math_floor (avoidance / (hits_now+avoid_now) * 100)
					local hit_percentage = _math_abs (avoid_percentage-100)

					avoid_percentage = avoid_percentage or 0
					hit_percentage = hit_percentage or 0
					
					TookVsAvoid:SetLeftText (avoid_percentage.."%")
					TookVsAvoid:SetRightText (hit_percentage.."%")
					
					TookVsAvoid:SetRightColor (hit_percentage/100, 0, 0, 1)
					TookVsAvoid:SetLeftColor (0, avoid_percentage/100, 0, 1)
					
					if (hit_percentage > 0 and avoid_percentage > 0) then
						if (hit_percentage > avoid_percentage) then 
							local p = avoid_percentage / hit_percentage * 100
							p = _math_abs (p - 100)
							p = p / 2
							p = p + 50
							p = _math_abs (p - 100)
							TookVsAvoid:SetSplit (p)
						else
							local p = hit_percentage / avoid_percentage * 100
							p = _math_abs (p - 100)
							p = p / 2
							p = p + 50
							
							TookVsAvoid:SetSplit (p)
						end
					elseif (hit_percentage > 0) then
						TookVsAvoid:SetSplit (6)
					elseif (avoid_percentage > 0) then
						TookVsAvoid:SetSplit (96)
					else
						TookVsAvoid:SetSplit (50)
					end
				end

			--> capture the amount of damage taken in last 5 seconds
			
				_table_insert (damage_taken, 1, _track_player_object.damage_taken - damage_last)
				damage_now = damage_now + (_track_player_object.damage_taken - damage_last)
				if (#damage_taken > 10) then
					damage_now = damage_now - damage_taken [11]
					_table_remove (damage_taken, 11)
				end
				damage_last = _track_player_object.damage_taken
				
			--> compute the damage taken vs incoming heal
			
				local dmgAmt = damage_now / #damage_taken
				DamageVsHeal:SetRightText (Vanguard:ToK ( _math_floor (dmgAmt)))

				local IncomingHeal = UnitGetIncomingHeals (_track_player_name) or 0
				DamageVsHeal:SetLeftText (Vanguard:ToK (IncomingHeal))
				
				if (dmgAmt > 0 and IncomingHeal > 0) then
					if (dmgAmt > IncomingHeal) then 
						local p = IncomingHeal / dmgAmt * 100
						
						--DamageVsHeal:SetLeftColor (0, p/100, 0, 1)
						p = _math_abs (p - 100)
						--DamageVsHeal:SetRightColor (p/100, 0, 0, 1)
						
						p = p / 2
						p = p + 50
						p = _math_abs (p - 100)
						DamageVsHeal:SetSplit (p)
					else
						local p = dmgAmt / IncomingHeal * 100
						--DamageVsHeal:SetRightColor (p/100, 0, 0, 1)
						p = _math_abs (p - 100)
						--DamageVsHeal:SetLeftColor (0, p/100, 0, 1)
						p = p / 2
						p = p + 50
						
						DamageVsHeal:SetSplit (p)
					end
				elseif (dmgAmt > 0) then
					DamageVsHeal:SetSplit (6)
				elseif (IncomingHeal > 0) then
					DamageVsHeal:SetSplit (94)
				end
			
			--> capture the last 6 hits taken
				
				local amt = 1
				local hp = _UnitHealthMax (_track_player_name)/3
				
				for _, tabela in _ipairs (_track_player_object.last_events_table) do 
					if (tabela[1]) then
						Vanguard:InsertDamage (tabela[3], amt, hp)
						if (amt == Vanguard.DamageLabels.Spots) then
							break
						end
						amt = amt+1
					end
				end
			
			half_second_tick = 0
		end
	end

	function Vanguard:Start()
		
		if (not Vanguard.Running) then
			return
		else
			--> reset widgets
			Vanguard:ResetDamage()
			Vanguard:ResetBars()
		end
		
		--> first, we need to get what we want to track:
		local MyTarget, Realm = _UnitName ("target")
		if (MyTarget and _UnitIsPlayer ("target")) then
			if (Realm) then
				MyTarget = MyTarget.."-"..Realm
			end
			_track_player_object = _combat_object (1, MyTarget)
			if (not _track_player_object) then
				--print ("Vanguard: Object not found 1.")
				_detalhes:ScheduleTimer ("VanguardWait", 1)
				return
			end
			
			_track_player_name = MyTarget
			
			if (VanguardFrame.InfoShown) then
				Vanguard:VanguardRefreshInfoFrame()
			end
		else
			_track_player_object = _combat_object (1, MyName)
			if (not _track_player_object) then
				--print ("Vanguard: Object not found 2.")
				_detalhes:ScheduleTimer ("VanguardWait", 1) 
				return
			end
			
			_track_player_name = MyName
			
			if (VanguardFrame.InfoShown) then
				Vanguard:VanguardRefreshInfoFrame()
			end
		end
		
		--print ("Vanguard: playername: ".. _track_player_name)

		hits_last = 0
		hits_now = 0
		hits_taken = {}
		
		avoid_last = 0
		avoid_now = 0
		avoid_taken = {}
		
		damage_last = 0
		damage_now = 0
		damage_taken = {}
	
		VanguardFrame:SetScript ("OnUpdate", onupdate)
		
	end

	--> identify tanks on startup
	Vanguard:IdentifyTanks()
	Vanguard:ResetBars()
	
end

function Vanguard:OnEvent (_, event, ...)

	if (event == "UNIT_HEALTH") then
		Vanguard:HealthChanged (...)
		
	elseif (event == "ADDON_LOADED") then
		local AddonName = select (1, ...)
		if (AddonName == "Details_Vanguard") then
			
			if (_G._detalhes) then
				
				--> create widgets
				CreatePluginFrames (data)

				local MINIMAL_DETAILS_VERSION_REQUIRED = 1
				
				--> Install
				local install = _G._detalhes:InstallPlugin ("TANK", Loc ["STRING_PLUGIN_NAME"], "Interface\\Icons\\INV_Shield_77", Vanguard, "DETAILS_PLUGIN_VANGUARD", MINIMAL_DETAILS_VERSION_REQUIRED)
				if (type (install) == "table" and install.error) then
					print (install.error)
				end
				
				--> Register needed events
				_G._detalhes:RegisterEvent (Vanguard, "COMBAT_PLAYER_ENTER")
				_G._detalhes:RegisterEvent (Vanguard, "COMBAT_PLAYER_LEAVE")
				_G._detalhes:RegisterEvent (Vanguard, "DETAILS_INSTANCE_ENDRESIZE")
				_G._detalhes:RegisterEvent (Vanguard, "DETAILS_INSTANCE_SIZECHANGED")
				_G._detalhes:RegisterEvent (Vanguard, "DETAILS_INSTANCE_STARTSTRETCH")
				_G._detalhes:RegisterEvent (Vanguard, "DETAILS_INSTANCE_ENDSTRETCH")
				
				VanguardFrame:RegisterEvent ("ZONE_CHANGED_NEW_AREA")
				VanguardFrame:RegisterEvent ("PLAYER_ENTERING_WORLD")
			end
		end
		
	elseif (event == "PLAYER_LOGOUT") then
		_detalhes_databaseVanguard = Vanguard.data
		
	elseif (event == "PLAYER_TARGET_CHANGED") then
		Vanguard:TargetChanged()
	
	elseif (event == "ROLE_CHANGED_INFORM" or event == "RAID_ROSTER_UPDATE") then --> raid changes
		Vanguard:IdentifyTanks()
		
	elseif (event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_ENTERING_WORLD") then --> logon or map changes
		Vanguard:IdentifyTanks()

	end
end
