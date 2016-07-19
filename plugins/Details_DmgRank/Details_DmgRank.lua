local AceLocale = LibStub ("AceLocale-3.0")
local Loc = AceLocale:GetLocale ("DetailsDmgRank")

--> Needed locals
local _GetTime = GetTime --> wow api local
local _UFC = UnitAffectingCombat --> wow api local
local _IsInRaid = IsInRaid --> wow api local
local _IsInGroup = IsInGroup --> wow api local
local _UnitAura = UnitAura --> wow api local
local _math_floor = math.floor --> lua library local
local _cstr = string.format --> lua library local

--> Create the plugin Object
local DmgRank = _detalhes:NewPluginObject ("Details_DmgRank")
--> Main Frame
local DmgRankFrame = DmgRank.Frame

DmgRank:SetPluginDescription ("A plugin for you have fun with a training dummy testing your damage skill and gear, leveling through many challenges.")


--> this function will run when the plugin receives the Addon_Loaded event, ["data"] = previus saved player rank
local function CreatePluginFrames (data)

	--> catch Details! main object
	local _detalhes = _G._detalhes
	local DetailsFrameWork = _detalhes.gump
	--local 
	
	--> default rank table
	DmgRank.rank = DmgRank.db
	--DmgRank.rank.level = 20
	
	--> OnEvent Table
	function DmgRank:OnDetailsEvent (event, ...)
		if (event == "HIDE") then --> plugin hidded, disabled
			DmgRankFrame:SetScript ("OnUpdate", nil) 
			DmgRank:Cancel()
		
		elseif (event == "SHOW") then
		
		elseif (event == "REFRESH") then --> requested a refresh window
			DmgRank:Refresh()

		elseif (event == "COMBAT_PLAYER_ENTER") then --> combat started	
			--print ("recebeu event start")
			local combat = select (1, ...)
			DmgRank:Start()
			
		elseif (event == "PLUGIN_DISABLED") then
			DmgRankFrame:SetScript ("OnUpdate", nil) 
			DmgRank:Cancel()
			
		elseif (event == "PLUGIN_ENABLED") then
			

		end
	end
	
	local close_button = DmgRank:CreateSoloCloseButton()
	close_button:SetPoint ("TOPRIGHT", DmgRankFrame, "TOPRIGHT", 3, 5)
	close_button:SetSize (24, 24)
	
------------- Build Ranking ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

	--> damage goal table
	DmgRank.TimeGoal = {
	
		--> The 30 seconds Trial
		{time = 30, damage = 3500000, name = Loc ["CHALLENGENAME_1"]}, -- Ready to Raid -- rank 2 -->  -- Patrulha --> ~11K DPS required
		{time = 30, damage = 4200000, name = Loc ["CHALLENGENAME_2"]}, -- Damage Practice --rank 3 -->  -- Soldier --> ~14K DPS required
		{time = 30, damage = 5000000, name = Loc ["CHALLENGENAME_3"]}, -- The Training Continue... -- rank 4 -->  -- Corporal --> ~16K DPS required
		
		--> 90 seconds bracket
		{time = 90, damage = 16010100, name = Loc ["CHALLENGENAME_4"]}, -- You Just Need a Little More Time -- rank 5 -->  -- Sergeant --> ~17K DPS required
		{time = 90, damage = 16666600, name = Loc ["CHALLENGENAME_5"]}, -- Became a Knight -- rank 6 -->  -- Sergeant --> ~18K DPS required
		
		--> middle bracket
		{time = 120, damage = 22541200, name = Loc ["CHALLENGENAME_6"]}, -- Two Minutes -- rank 7 -->   Iron Knight --> ~18K DPS required
		{time = 120, damage = 24095000, name = Loc ["CHALLENGENAME_7"]}, --rank 8 -->  Steel Knight --> ~20K DPS required
		{time = 180, damage = 33900000, name = Loc ["CHALLENGENAME_8"]}, --rank 9 -->  --> The High Knight --> ~18K DPS required
		{time = 180, damage = 34990000, name = Loc ["CHALLENGENAME_9"]}, --rank 10 --> Yes Sir! --   Thorium Knight --> ~19K DPS required
		{time = 180, damage = 37840510, name = Loc ["CHALLENGENAME_10"]}, --rank 11 --> Salute  --   Silver Lieutenant --> ~21K DPS required
		
		--> burst bracket
		{time = 40, damage = 13511440, name = Loc ["CHALLENGENAME_11"]}, --rank 12 --> In Burst We Trust  --   Gold Lieutenant --> ~33K DPS required
		{time = 40, damage = 14944040, name = Loc ["CHALLENGENAME_12"]}, --rank 13 -->  Watch me Explode  --   Stone Guardian --> ~37K DPS required
		{time = 40, damage = 15699000, name = Loc ["CHALLENGENAME_13"]}, --rank 14 --> T.N.T--   Fel Guardian --> ~39K DPS required
		
		--> long run bracket
		{time = 300, damage = 62112010, name = Loc ["CHALLENGENAME_14"]}, --rank 15 --> Time is Damage My Friend --   Titan Guardian --> ~20K DPS required
		{time = 300, damage = 68424590, name = Loc ["CHALLENGENAME_15"]}, --rank 16 - Just a Little Patience -->  Bronze Centurion --> ~22K DPS required
		{time = 300, damage = 75119830, name = Loc ["CHALLENGENAME_16"]}, --rank 17 -->  Silver Centurion --> ~25K DPS required
		
		{time = 120, damage = 40111000, name = Loc ["CHALLENGENAME_17"]}, --rank 18 -->  Flame Centurion --> ~33K DPS required
		{time = 120, damage = 43000000, name = Loc ["CHALLENGENAME_18"]}, --rank 19 -->  Lower Vanquisher --> 35K DPS required
		{time = 60, damage = 26500000, name = Loc ["CHALLENGENAME_19"]}, --rank 20 -->  Middle Vanquisher --> 44K DPS required
		
		--> end
		{time = nil, damage = nil, name = ""}, --rank 21 --> none
	}

	--> tiles and badges
	DmgRank.Titles = {
	
		Loc ["RANKNAME_1"], --> rank 1 -->  -- recruit -- Recruta -- Farmer
		Loc ["RANKNAME_2"], --> rank 2 -->  soldier
		Loc ["RANKNAME_3"], --> rank 3 -->    corporal
		
		Loc ["RANKNAME_4"], --> rank 4 -->  -- Gold Sergeant
		Loc ["RANKNAME_5"], --> rank 5 -->  -- Star Sergeant
		
		Loc ["RANKNAME_6"], --> rank 6 - Iron Knight
		Loc ["RANKNAME_7"], --> rank 7 - Steel Knight
		Loc ["RANKNAME_8"], --> rank 8 - Mithril Knight
		Loc ["RANKNAME_9"], --> rank 9 - Thorium Knight
		
		Loc ["RANKNAME_10"], --> rank 10 - Silver Lieutenant
		Loc ["RANKNAME_11"], --> rank 11 - Gold Lieutenant
		
		Loc ["RANKNAME_12"], --> rank 12 - Stone Guardian
		Loc ["RANKNAME_13"], --> rank 13 - Fel Guardian
		Loc ["RANKNAME_14"], --> rank 14 - Titan Guardian
		
		Loc ["RANKNAME_15"], --> rank 15 - Bronze Centurion
		Loc ["RANKNAME_16"], --> rank 16 - Silver Centurion
		Loc ["RANKNAME_17"], --> rank 17 - Flame Centurion
		
		Loc ["RANKNAME_18"], --> rank 18 - "Lower Vanquisher"
		Loc ["RANKNAME_19"], --> rank 19 - "Middle Vanquisher"
		Loc ["RANKNAME_20"], --> rank 20 - "High Vanquisher"
		
		--[[
		legionary
		Commander
		General
		marshal
		Champion  -- campeoao
		Conqueror -- conquistador
		--]]
		
	}
	DmgRank.Badges = {}
	DmgRank.Badges.TexCoords = {
		{0.7734375, 0.89453125, 0.060546875, 0.181640625}, --> rank 1
		{0.1640625, 0.259765625, 0.083984375, 0.185546875}, --> rank 2 - soldier
		{0.31640625, 0.412109375, 0.06640625, 0.18359375}, --> rank 3 --> Corporal
		{0.45703125, 0.55078125, 0.05859375, 0.177734375}, --> rank 4 --> Gold Sergeant
		{0.607421875, 0.701171875, 0.044921875, 0.177734375}, --> rank 5 --> star Sergeant
		
		{0.017578125, 0.169921875, 0.236328125, 0.3984375}, --> rank 6 - Iron Knight
		{0.201171875, 0.357421875, 0.234375, 0.3984375}, --> rank 7 - Steel Knight	
		{0.38671875, 0.541015625, 0.234375, 0.3984375}, --> rank 8 - Mithril Knight
		{0.572265625, 0.7265625, 0.234375, 0.3984375}, --> rank 9 - Thorium Knight
		
		{0.16015625, 0.2734375, 0.44921875, 0.583984375}, --> rank 10 - Silver Lieutenant
		{0.0234375, 0.130859375, 0.44921875, 0.583984375}, --> rank 11 - Gold Lieutenant
		
		{0.30078125, 0.4375, 0.44140625, 0.5859375}, --> rank 12 - Stone Guardian
		{0.45703125, 0.59375, 0.44140625, 0.5859375}, --> rank 13 - Fel Guardian
		{0.61328125, 0.75, 0.44140625, 0.5859375}, --> rank 14 - Titan Guardian
		
		{0.017578125, 0.173828125, 0.625, 0.78125}, --> rank 15 - Bronze Centurion
		{0.212890625, 0.369140625, 0.625, 0.78125}, --> rank 16 - Silver Centurion
		{0.408203125, 0.56640625, 0.625, 0.78125}, --> rank 17 - Flame Centurion
		
		{0.00390625, 0.208984375, 0.810546875, 0.9765625}, --> rank 18 - Lower Vanquisher
		{0.21875, 0.42578125, 0.810546875, 0.9765625}, --> rank 19 - Middle Vanquisher
		{0.43359375, 0.638671875, 0.810546875, 0.9765625}, --> rank 20 - High Vanquisher

	}
	DmgRank.Badges.Sizes = {
		{50, 50}, --> rank 1
		{50, 52}, --> rank 2 - soldier
		{50, 60}, --> rank 3 - Corporal
		{49, 59}, --> rank 4 - Gold Sergeant
		{48, 61}, ---> rank 5 - star Sergeant
		{56, 63}, --> rank 6 - Iron Knight
		{56, 63}, -->rank 7 - Steel Knight	
		{56, 63}, --> rank 8 - Mithril Knight
		{56, 63}, --> rank 9 - Thorium Knight
		
		{61, 59}, --> rank 10 - Silver Lieutenant
		{55, 67}, --> rank 11 - Gold Lieutenant
		
		{70, 74}, --> rank 12 - Stone Guardian
		{70, 74}, --> rank 13 - Fel Guardian
		{70, 74}, --> rank 14 - Titan Guardian
		
		{70, 70}, --> rank 15 - Bronze Centurion
		{70, 70}, --> rank 16 - Silver Centurion
		{70, 70}, --> rank 17 - Flame Centurion
		
		{80, 65}, --> rank 18 - Lower Vanquisher
		{80, 65}, --> rank 19 - Middle Vanquisher
		{80, 65}, --> rank 20 - High Vanquisher
	}
	DmgRank.Badges.SetPointMod = {
		{0, 6}, --> rank 1
		{0, 5}, --> rank 2 - soldier
		{0, 10}, --> rank 3 - Corporal
		{0, 10}, --> rank 4 - Gold Sergeant
		{0, 16}, --> rank 5 - star Sergeant
		{0, 12}, --> rank 6 - Iron Knight
		{0, 12}, --> rank 7 - Steel Knight
		{0, 12}, --> rank 8 - Mithril Knight
		{0, 12}, --> rank 9 - Thorium Knight
		
		{0, 12}, --> rank 10 - Silver Lieutenant
		{0, 17}, --> rank 11 - Gold Lieutenant
		
		{0, 20}, --> rank 12 - Stone Guardian
		{0, 20}, --> rank 13 - Fel Guardian
		{0, 20}, --> rank 14 - Titan Guardian
		
		{0, 20}, --> rank 15 - Bronze Centurion
		{0, 20}, --> rank 16 - Silver Centurion
		{0, 20}, --> rank 17 - Flame Centurion
		
		{-3, 16}, --> rank 18 - Lower Vanquisher
		{-3, 16}, --> rank 19 - Middle Vanquisher
		{-3, 16}, --> rank 20 - High Vanquisher

	}

	--> main frame and background texture
	
	DmgRankFrame:SetPoint ("topleft", UIParent)
	DmgRankFrame:SetResizable (false) --> cant resize, this is a fixed size
	DmgRankFrame:SetWidth (300) --> need to be 300x300 to fit details window
	DmgRankFrame:SetHeight (300) --> need to be 300x300 to fit details window
	DmgRank.Frame = DmgRankFrame
	DmgRankFrame:Hide()
	
	--> default background picture
	local background = DmgRankFrame:CreateTexture (nil, "background")
	background:SetTexture ("Interface\\ACHIEVEMENTFRAME\\UI-Achievement-StatsBackground")
	background:SetPoint ("topleft", DmgRankFrame, "topleft", 2, 0)
	background:SetPoint ("bottomright", DmgRankFrame, "bottomright", -2, 0)
	background:SetVertexColor (.7, .7, .7, 1)
	background:SetDrawLayer ("background", 1)
	DmgRank.BackgroundTex = background
	
	--> next rank at display
	local challengeName = DetailsFrameWork:NewLabel (DmgRankFrame, DmgRankFrame, nil, "challengeName", "", "QuestFont_Shadow_Huge")
	challengeName:SetPoint ("center", DmgRankFrame, "center")
	challengeName:SetPoint ("top", DmgRankFrame, "top", 0, -98)
	DmgRank.challengeName = challengeName
	
	local challengeGoal = DetailsFrameWork:NewLabel (DmgRankFrame, DmgRankFrame, nil, "challengeGoal", "", "GameFontHighlightSmall")
	challengeGoal:SetPoint ("center", DmgRankFrame, "center")
	challengeGoal:SetPoint ("top", DmgRankFrame, "top", 0, -118)
	DmgRank.challengeGoal = challengeGoal

	--> main time display
	local showTimeMinutes = DetailsFrameWork:NewLabel (DmgRankFrame, DmgRankFrame, nil, "showTimeMinutes", "00:", "GameFontHighlightLarge")
	showTimeMinutes:SetPoint ("center", DmgRankFrame, "center")
	showTimeMinutes:SetPoint ("top", DmgRankFrame, "top", -25, -150)
	showTimeMinutes:SetJustifyH ("RIGHT")
	DmgRank.TimeMinutes = showTimeMinutes
	
	local showTimeSeconds = DetailsFrameWork:NewLabel (DmgRankFrame, DmgRankFrame, nil, "showTimeSeconds", "00:", "GameFontHighlightLarge")
	showTimeSeconds:SetPoint ("center", DmgRankFrame, "center")
	showTimeSeconds:SetPoint ("top", DmgRankFrame, "top", 0, -150)
	DmgRank.TimeSeconds = showTimeSeconds
	
	local showTimeMiliSeconds = DetailsFrameWork:NewLabel (DmgRankFrame, DmgRankFrame, nil, "showTimeMiliSeconds", "00", "GameFontHighlightLarge")
	showTimeMiliSeconds:SetPoint ("center", DmgRankFrame, "center")
	showTimeMiliSeconds:SetPoint ("top", DmgRankFrame, "top", 23, -150)
	DmgRank.TimeMiliSeconds = showTimeMiliSeconds
	
	--> main damage display
	local damage = DetailsFrameWork:NewLabel (DmgRankFrame, DmgRankFrame, "showdamage", nil, "00.000.000", "GameFontHighlightLarge")
	damage:SetPoint ("center", DmgRankFrame, "center")
	damage:SetPoint ("top", DmgRankFrame, "top", 0, -170)
	DmgRank.MainDamageDisplay = damage

	--> background da badge e titulo
	local bg1 = DetailsFrameWork:NewPanel (DmgRankFrame, _, "DetailsDmgRankBadgeBackground", _, 280, 75)
	bg1:SetPoint ("topleft", DmgRankFrame, 10, -10)
	
	local GlowFrame = CreateFrame ("frame", "DetailsRankUpGlowFrame", bg1.widget, "DetailsAlertRankUpTemplate")
	GlowFrame:SetPoint ("topleft", bg1.widget)
	GlowFrame:SetWidth (280)
	GlowFrame:SetHeight (60)
	GlowFrame:Hide()
	
	--> badge icon display
	local titleIcon = bg1:CreateTexture (nil, "overlay")
	titleIcon:SetTexture ("Interface\\AddOns\\Details_DmgRank\\images\\badges")
	titleIcon:SetTexCoord (unpack (DmgRank.Badges.TexCoords [DmgRank.rank.level]))
	titleIcon:SetWidth (DmgRank.Badges.Sizes [DmgRank.rank.level] [1]*1.33)
	titleIcon:SetHeight (DmgRank.Badges.Sizes [DmgRank.rank.level] [2]*1.33)
	titleIcon:SetPoint ("topleft", DmgRankFrame, "topleft", 20, -20)
	DmgRank.TitleIcon = titleIcon
	
	--> title
	local pretitle = DetailsFrameWork:NewLabel (bg1, bg1, nil, "pretitle", Loc ["STRING_CURRENTRANK"], "GameFontHighlightSmall")
	pretitle:SetPoint ("left", titleIcon, "right", 20, 9)
	DmgRank.PreTitle = pretitle
	
	local title = DetailsFrameWork:NewLabel (bg1, bg1, nil, "title", DmgRank.Titles [DmgRank.rank.level], "GameFontHighlightLarge")
	title:SetPoint ("left", titleIcon, "right", 20, -9)
	DmgRank.Title = title
	
	--> help button
	--> after 10 logins on the character this help button will not be show any more
	if (_detalhes.tutorial.main_help_button < 10) then
		local help = DetailsFrameWork:NewHelp (DmgRankFrame, 280, 280, 0, -20, 40, 40)
		help:SetPoint ("topright", DmgRankFrame, "topright", 8, 9)
		help:AddHelp (300, 300, 0, 0, 138, -138, Loc ["STRING_HELP"])
		help:SetFrameLevel (DmgRankFrame:GetFrameLevel()+2)
	end
	
	--> announce switch
	local announce = DetailsFrameWork:NewSwitch (bg1, _, "DetailsDmgRankAnnouce", "announceSwitch", 60, 20, _, _, DmgRank.rank.annouce)
	bg1.announceSwitch:SetPoint ("topleft", DmgRankFrame, 12, -184)
	bg1.announceSwitch.OnSwitch = function (self, _, value) 
		DmgRank.rank.annouce = value
	end
	DetailsFrameWork:NewLabel (bg1, _, nil, "announceLabel", Loc ["STRING_ANNOUNCE"], "GameFontHighlightSmall")
	bg1.announceLabel:SetPoint ("bottom", bg1.announceSwitch, "top", -5, -2)
	
	--> background dos tempos das ultimas tries
	local lasttrylabel = DetailsFrameWork:NewLabel (bg1, bg1, nil, "lasttrylabel", Loc ["STRING_LASTTRIES"], "GameFontHighlightSmall") --> 
	lasttrylabel:SetPoint ("topleft", DmgRankFrame, 12, -204)
	local lastranklabel = DetailsFrameWork:NewLabel (bg1, bg1, nil, "lastranklabel", Loc ["STRING_LASTRANKS"], "GameFontHighlightSmall") --> 
	lastranklabel:SetPoint ("topleft", DmgRankFrame, 162, -204)
	
	local bg_esq = DetailsFrameWork:NewPanel (DmgRankFrame, _, "DetailsDmgRankLeftBackground", _, 130, 85, _, {.9, .9, .9, .7})
	bg_esq:SetPoint ("topleft", DmgRankFrame, 10, -215)
	local bg_dir = DetailsFrameWork:NewPanel (DmgRankFrame, _, "DetailsDmgRankRightBackground", _, 130, 85, _, {.9, .9, .9, .7})
	bg_dir:SetPoint ("topleft", DmgRankFrame, 160, -215)
	
	--> try dps dos 5 ultimos ranks
	DmgRank.Try = {}
	for i = 1, 5 do 
		DetailsFrameWork:NewLabel (bg_esq, bg_esq, nil, "try"..i, "0", "GameFontHighlightSmall")
		bg_esq ["try"..i]:SetPoint ("bottomleft", DmgRankFrame, "bottomleft", 20, math.abs (i*15-83))
		DmgRank.Try [i] = bg_esq ["try"..i]
	end
	
	--> dps dos 5 ultimos ranks
	DmgRank.Dps = {}
	for i = 1, 5 do 
		DetailsFrameWork:NewLabel (bg_dir, bg_dir, nil, "dps"..i, "0", "GameFontHighlightSmall")
		bg_dir ["dps"..i]:SetPoint ("bottomleft", DmgRankFrame, "bottomleft", 170, math.abs (i*15-83))
		DmgRank.Dps [i] = bg_dir ["dps"..i]
	end
	
	--> refresh all window components
	function DmgRank:Refresh()
		--> update badge icon and text
		
		if (not self) then
			self = DmgRank
		end
		
		self.challengeName:SetText (self.TimeGoal[DmgRank.rank.level].name)
		if (self.TimeGoal[DmgRank.rank.level].damage) then
			self.challengeGoal:SetText (_detalhes:comma_value (self.TimeGoal[DmgRank.rank.level].damage) .. " ".. Loc ["STRING_DAMAGEIN"] .." " .. self.TimeGoal[DmgRank.rank.level].time .. " " ..Loc ["STRING_SECONDS"])
		else
			self.challengeGoal:SetText ("")
		end
		self.Title:SetText (self.Titles [DmgRank.rank.level])
		
		self.TitleIcon:SetTexCoord (unpack (self.Badges.TexCoords [DmgRank.rank.level]))
		self.TitleIcon:SetWidth (self.Badges.Sizes [DmgRank.rank.level] [1]*1.33)
		self.TitleIcon:SetHeight (self.Badges.Sizes [DmgRank.rank.level] [2]*1.33)
		self.TitleIcon:SetPoint ("topleft", DmgRankFrame, 20+self.Badges.SetPointMod[DmgRank.rank.level][1], -20+self.Badges.SetPointMod[DmgRank.rank.level][2])
	
		--> update last try atempts
		for i = 1, 5 do 
			if (DmgRank.rank.lasttry [i]) then
				self.Try [i]:SetText ("#"..i..": ".. _detalhes:comma_value (DmgRank.rank.lasttry [i]))
			else
				self.Try [i]:SetText ("-")
			end
		end
		
		--> update last levels ups
		for i = 1, 5 do 
			if (DmgRank.rank.dpshistory [i]) then
				self.Dps [i]:SetText (Loc ["STRING_RANK"] .. " ".. DmgRank.rank.dpshistory [i])
			else
				self.Dps [i]:SetText ("-")				
			end
		end
	end
	
	--> Refresh on Addon Load
	DmgRank:Refresh()
	
	local update = 0
	local player --> short cut for Player Actor Object
	
	--> Cancel function
	function DmgRank:Cancel()
		if (DmgRank.Time and DmgRank.Time.Working) then
			print (Loc ["STRING_CANCELLED"])
			DmgRank.Time.Working = false
			DmgRank.Time.Done = true
			DmgRank.Frame:SetScript ("OnUpdate", nil)
		end
	end
	
	--> Exec function
	local DoDmgRank = function (self, elapsed)

		DmgRank.Time.Elapsed = DmgRank.Time.Elapsed + elapsed
		update = update + elapsed
		
		if (_GetTime() > DmgRank.Time.EndTime) then --> reached the end time
			if (DmgRank.Time.Working and not DmgRank.Time.Done) then
				DmgRank:Finish()
			else
				DmgRank.Time.Working = false
				DmgRank.Time.Done = true
				DmgRank.Frame:SetScript ("OnUpdate", nil)
			end
		else

			DmgRank.Time.Tick = DmgRank.Time.Tick + elapsed
			
			if (DmgRank.Time.Tick > 1) then
				DmgRank.Time.Tick = 0
				if (not _UFC ("player")) then --> isn't in combat
					DmgRank:Finish()
				end
			else
				if (not player) then
					player = _detalhes:GetActor()
				end
				
				if (player) then
					local minutos, segundos = _math_floor (DmgRank.Time.Elapsed/60), _math_floor (DmgRank.Time.Elapsed%60)
					if (segundos < 10) then
						segundos = "0"..segundos
					end
					
					local mili = _cstr ("%.2f", DmgRank.Time.Elapsed - _math_floor (DmgRank.Time.Elapsed))*100
					if (mili < 10) then
						mili = "0"..mili
					end
					
					DmgRank.TimeMinutes:SetText ("0".. minutos .. ":")
					DmgRank.TimeSeconds:SetText (segundos ..":")
					DmgRank.TimeMiliSeconds:SetText (mili)
					
					local DamageGoal = DmgRank.TimeGoal [DmgRank.rank.level].damage
					if (player.total > DamageGoal) then --> yeah, you didit
						DmgRank.MainDamageDisplay:SetTextColor (0.3, 1, 0.1)
					else
						DmgRank.MainDamageDisplay:SetTextColor (1, 1, 1)
					end
					
					DmgRank.MainDamageDisplay:SetText (_detalhes:comma_value (player.total))
				end
			end
		end
		
	end
	
	--> add failed attempt to falied records
	function DmgRank:FailedLevelUpRank()
		table.insert (DmgRank.rank.lasttry, 1, player.total)
		table.remove (DmgRank.rank.lasttry, 6)
		DmgRank:Refresh()
	end
	
	--> Levelup
	function DmgRank:LevelUpRank()
		_detalhes:PlayGlow (GlowFrame)
		DmgRank.rank.level = DmgRank.rank.level + 1
		
		if (DmgRank.rank.annouce) then
			SendChatMessage (UnitName ("player") .. " " .. Loc ["STRING_ANNOUNCE_STRING"] .. " " .. DmgRank.rank.level .. " (" .. self.Titles [DmgRank.rank.level] .. ") " .. Loc ["STRING_ANNOUNCE_ON"] .. " Details!: " .. Loc ["STRING_PLUGIN_NAME"] .. ".", "GUILD")
		end
		
		DmgRank.rank.dps = player.total
		table.insert (DmgRank.rank.dpshistory, 1, DmgRank.rank.level..": ".._detalhes:comma_value (player.total))
		table.remove (DmgRank.rank.dpshistory, 6)
		DmgRank:Refresh()
	end
	
	--> When the time is gone
	function DmgRank:Finish()
		DmgRank.Frame:SetScript ("OnUpdate", nil)
		
		if (player) then
			local DamageGoal = DmgRank.TimeGoal [DmgRank.rank.level].damage --> damage
			if (player.total > DamageGoal) then --> yeah, you didit
				DmgRank:LevelUpRank()
			else
				DmgRank:FailedLevelUpRank()
			end
		end
		
		DmgRank.Time.Working = false
		DmgRank.Time.Done = true
	end
	
	--> When a new combat is received by the PlugIn
	function DmgRank:Start()

		if (DmgRank.Time and DmgRank.Time.Working) then
			DmgRank:Msg ("Plugin already in use.")
			return
		end
		
		if (not DmgRank.TimeGoal[DmgRank.rank.level].damage) then
			DmgRank:Msg ("There is no goal for this level.")
			return
		end
	
		--> reset
		DmgRank.TimeMinutes:SetText ("00:")
		DmgRank.TimeSeconds:SetText ("00:")
		DmgRank.TimeMiliSeconds:SetText ("00")
		DmgRank.MainDamageDisplay:SetText ("00.000.000")

		DmgRank.Time = {}
		DmgRank.Time.StartTime = _GetTime()
		DmgRank.Time.EndTime = DmgRank.Time.StartTime + DmgRank.TimeGoal [DmgRank.rank.level].time
		DmgRank.Time.Elapsed = 3
		DmgRank.Time.Done = nil
		DmgRank.Time.Working = true
		DmgRank.Time.Tick = 0
		player = _detalhes:GetActor() --> param 1 = combat | param 2 = attribute | param 3 = player name
		update = 0
		
		DmgRank.starting = DmgRank:ScheduleTimer ("StartUpdate", 3)
	end

	function DmgRank:StartUpdate()
		player = _detalhes:GetActor()
		DmgRank.Frame:SetScript ("OnUpdate", DoDmgRank)
	end
	
end

function DmgRank:OnEvent (_, event, ...)

	if (event == "ADDON_LOADED") then
		local AddonName = select (1, ...)
		if (AddonName == "Details_DmgRank") then
			
			if (_G._detalhes) then
				
				local MINIMAL_DETAILS_VERSION_REQUIRED = 50

				local default_config = {level = 1, dps = 0, dpshistory = {}, lasttry = {}, annouce = true}
				
				--> Install plugin inside details
				local install, saveddata = _G._detalhes:InstallPlugin ("SOLO", Loc ["STRING_PLUGIN_NAME"], "Interface\\Icons\\ACHIEVEMENT_GUILDPERK_HONORABLEMENTION_RANK2", DmgRank, "DETAILS_PLUGIN_DAMAGE_RANK", MINIMAL_DETAILS_VERSION_REQUIRED, "Details! Team", "v1.2.0", default_config)
				if (type (install) == "table" and install.error) then
					print (install.error)
				end
				
				--> create widgets
				CreatePluginFrames()
				
				--> Register needed events
				_G._detalhes:RegisterEvent (DmgRank, "COMBAT_PLAYER_ENTER")
				
			end
		end

	end
end