-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--global name declaration
--use lua-language-server annotations to help the linter:
--https://github.com/LuaLS/lua-language-server/wiki/Annotations#documenting-types
--follow definitions declared in the file definitions.lua
--follow game api definitions in the file LibLuaServer.lua

		_ = nil
		_G.Details = LibStub("AceAddon-3.0"):NewAddon("_detalhes", "AceTimer-3.0", "AceComm-3.0", "AceSerializer-3.0", "NickTag-1.0")

		--add the original name to the global namespace
		_detalhes = _G.Details --[[GLOBAL]]

		__details_debug = __details_debug or {}
		if (__details_debug.prescience_timeline) then
			wipe(__details_debug.prescience_timeline)
		end

		local addonName, Details222 = ...
		local version, build, date, tvs = GetBuildInfo()

		Details.build_counter = 13111
		Details.alpha_build_counter = 13111 --if this is higher than the regular counter, use it instead
		Details.dont_open_news = true
		Details.game_version = version
		Details.userversion = version .. " " .. Details.build_counter
		Details.realversion = 161 --core version, this is used to check API version for scripts and plugins (see alias below)
		Details.gametoc = tvs
		Details.APIVersion = Details.realversion --core version
		Details.version = Details.userversion .. " (core " .. Details.realversion .. ")" --simple stirng to show to players

		Details.acounter = 1 --in case of a second release with the same .build_counter
		Details.curseforgeVersion = C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata("Details", "Version")
		if (not Details.curseforgeVersion and GetAddOnMetadata) then
			Details.curseforgeVersion = GetAddOnMetadata("Details", "Version")
		end

		function Details:GetCoreVersion()
			return Details.realversion
		end

		Details.BFACORE = 131 --core version on BFA launch
		Details.SHADOWLANDSCORE = 143 --core version on Shadowlands launch
		Details.DRAGONFLIGHT = 147 --core version on Dragonflight launch
		Details.V11CORE = 160 --core version on V11 launch

		Details = Details

		local gameVersionPrefix = "VCT" --v1, v4, v11

		Details.gameVersionPrefix = gameVersionPrefix

		pcall(function() Details.version_alpha_id = tonumber(Details.curseforgeVersion:match("%-(%d+)%-")) end)

		--WD 10288 RELEASE 10.0.2
		--WD 10288 ALPHA 21 10.0.2
		function Details.GetVersionString()
			local curseforgeVersion = Details.curseforgeVersion or ""
			local alphaId = curseforgeVersion:match("%-(%d+)%-")

			if (not alphaId) then
				--this is a release version
				alphaId = "RELEASE"
			else
				alphaId = "ALPHA " .. alphaId
			end

			return Details.gameVersionPrefix .. " " .. Details.build_counter .. " " .. alphaId .. " " .. Details.game_version .. ""
		end

		Details.DefaultTooltipIconSize = 20

		--namespace for the player breakdown window
		Details.PlayerBreakdown = {}
		Details222.PlayerBreakdown = {
			DamageSpellsCache = {}
		}

		Details222.StartUp = {}

		Details222.Unknown = _G["UNKNOWN"]

		--namespace color
		Details222.ColorScheme = {
			["gradient-background"] = {0.1215, 0.1176, 0.1294, 0.8},
		}
		function Details222.ColorScheme.GetColorFor(colorScheme)
			return Details222.ColorScheme[colorScheme]
		end

		function Details222.DebugMsg(...)
			if (Details.debug) then
				print("|cFFCCAAAADetails! Debug:|r", ...)
			end
		end

		--cache of frames to call :SetColor() when the color scheme changes
		Details222.RegisteredFramesToColor = {}

		Details222.TrainingDummiesNpcId = {
			[194649] = true, --valdraken
			[189617] = true, --valdraken
			[194644] = true, --valdraken
			[198594] = true, --valdraken
			[194643] = true, --valdraken
			[189632] = true, --valdraken
			[194648] = true, --valdraken
			[194646] = true, --valdraken
			[197834] = true, --valdraken
			[31146] = true, --orgrimmar
			[153285] = true, --orgrimmar
			[114840] = true, --orgrimmar
			[114832] = true, --stormwind
			[153292] = true, --stormwind
		}

		---@type details_storage_feature
		---@diagnostic disable-next-line: missing-fields
		local storage = {
			DiffNames = {"normal", "heroic", "mythic", "raidfinder", "10player", "25player", "10playerheroic", "25playerheroic", "raidfinderclassic", "raidfindertimewalking", "timewalking"},
			DiffNamesHash = {normal = 14, heroic = 15, mythic = 16, raidfinder = 17, ["10player"] = 3, ["25player"] = 4, ["10playerheroic"] = 5, ["25playerheroic"] = 6, raidfinderclassic = 7, raidfindertimewalking = 151, timewalking = 33},
			DiffIdToName = {
				[14] = "normal",
				[15] = "heroic",
				[16] = "mythic",
				[17] = "raidfinder",
				[3] = "10player",
				[4] = "25player",
				[5] = "10playerheroic",
				[6] = "25playerheroic",
				[7] = "raidfinderclassic",
				[8] = "mythicdungeon",
				[151] = "raidfindertimewalking",
				[33] = "timewalking"
			},
			IsDebug = false
		}
		Details222.storage = storage

		--namespace for damage spells (spellTable)
		Details222.DamageSpells = {}
		--namespace for texture
		Details222.Textures = {}

		Details222.Debug = {
			DebugPets = false,
			DebugPlayerPets = false,
			DebugBuff = false,
		}

		Details222.Tvs = tvs
		--namespace for pet
		Details222.Pets = {}
		Details222.PetContainer = {
			---@type table<guid, petdata>
			Pets = {},
			---@type table<guid, boolean>
			IgnoredActors = {},
			---table that stores the player guid as keys and their petguid as values
			---this is useful to know which pets are the legit class pet from the UNIT_PET event
			---@type table<guid, guid>
			UnitPetCache = {},
		}

		--auto run code
		Details222.AutoRunCode = {}
		--options panel
		Details222.OptionsPanel = {}
		--store bar icons (left side of the damage bar)
		Details222.BarIconSetList = {}
		Details222.Instances = {}
		Details222.Combat = {}
		Details222.MythicPlus = {
			Charts = {},
			Frames = {},
		}
		Details222.Notes = {}
		Details222.MythicPlusBreakdown = {}
		Details222.EJCache = {}
		Details222.Segments = {}
		Details222.Tables = {}
		Details222.Mixins = {}
		Details222.Cache = {}
		Details222.Perf = {}
		Details222.Cooldowns = {}
		Details222.GarbageCollector = {}
		Details222.BreakdownWindow = {}
		Details222.PlayerStats = {}
		Details222.LoadSavedVariables = {}
		Details222.SaveVariables = {}
		Details222.GuessSpecSchedules = {
			Schedules = {},
		}
		Details222.Profiling = {}
		Details222.ProfilingCache = {}
		Details222.TimeMachine = {}
		Details222.OnUseItem = {Trinkets = {}}

		Details222.Date = {
			GetDateForLogs = function()
				return _G.date("%Y-%m-%d %H:%M:%S")
			end,
		}

		Details222.ClassCache = {}
		Details222.ClassCache.ByName = {}
		Details222.ClassCache.ByGUID = {}
		Details222.UnitIdCache = {}
		Details222.Roskash = {}
		Details222.SpecHelpers = {
			[1473] = {},
		}

		Details222.IgnoredWorldAuras = {}
		Details222.OneHourAuras = {}

		Details222.Parser = {}

		Details222.Actors = {}

		Details222.CurrentDPS = {
			Cache = {}
		}
		--store all data from the encounter journal
		Details222.EncounterJournalDump = {}
		--aura scanner
		Details222.AuraScan = {}

		---@type instancedifficulty
		Details222.InstanceDifficulty = {
			["DungeonNormal"] = 1,
			["DungeonHeroic"] = 2,
			["DungeonMythic"] = 23,
			["DungeonMythicPlus"] = 8,
			["RaidLFR"] = 17,
			["RaidNormal"] = 14,
			["RaidHeroic"] = 15,
			["RaidMythic"] = 16,
		}

		local emptyFunction = function()end
		local emptyTable = {}

		---context manager is a system that evaluates where the player is and create a set of extra rules that fit the content the player is doing
		---@class contextmanager : table
		---@field instanceType string
		---@field instanceName string
		---@field instanceId number
		---@field instanceDifficulty number
		---@field lastInstanceType string
		---@field lastInstanceName string
		---@field lastInstanceDifficulty number
		---@field contextId string
		---@field bContextStarted boolean
		---@field bContextFinished boolean
		---@field bHasContext boolean
		---@field fHasLostInterest function
		---@field fOnContextFinished function
		---@field fOnCombatFinished function
		---@field eventFrame frame
		---@field DetailsEventListener table
		---@field contextEventTable table
		---@field StartContext function
		---@field CheckContextInterest function
		---@field FinishContext function
		---@field GetContext function

		--tells what is the activity the player is doing
		Details222.ContextManager = {
			instanceType = "INIT",
			instanceName = "INIT",
			instanceDifficulty = 0,
			lastInstanceType = "INIT",
			lastInstanceName = "INIT",
			lastInstanceDifficulty = 0,
			contextId = "INIT",
			bContextStarted = false,
			bContextFinished = false,
			bHasContext = false,
			fOnContextFinished = emptyFunction,
			fHasLostInterest = emptyFunction,
			fOnCombatFinished = emptyFunction,
			contextEventTable = emptyTable,

			eventFrame = CreateFrame("frame"),

			---start a new context, this is called from the CheckContextInterest() function
			---@param self contextmanager
			---@param instanceId number
			---@param instanceName string
			---@param instanceType string
			---@param difficultyId number
			---@param contextEventTable table
			---@param fOnCombatFinished function run when details! finishes a combat
			---@param fOnContextFinished function run when the context is finished
			---@param fHasLostInterest function run when CheckContextInterest() fails to find a context
			StartContext = function(self, instanceId, instanceName, instanceType, difficultyId, contextEventTable, fOnCombatFinished, fOnContextFinished, fHasLostInterest)
				self.instanceType = instanceType
				self.instanceName = instanceName
				self.instanceId = instanceId
				self.instanceDifficulty = difficultyId
				self.bContextStarted = true
				self.bContextFinished = false
				self.bHasContext = true
				self.fOnContextFinished = fOnContextFinished
				self.fHasLostInterest = fHasLostInterest
				self.fOnCombatFinished = fOnCombatFinished
				self.contextEventTable = contextEventTable

				--create an event listener to grab the event when Details! finishes a combat
				if (not self.DetailsEventListener) then
					self.DetailsEventListener = Details:CreateEventListener()
				end
				self.DetailsEventListener:UnregisterEvent("COMBAT_PLAYER_LEAVE")
				--register the onFinishCombat for the context
				self.DetailsEventListener:RegisterEvent("COMBAT_PLAYER_LEAVE", fOnCombatFinished)

				--unregister all events
				self.eventFrame:UnregisterAllEvents()

				--register the events that the context require
				for i = 1, #contextEventTable.events do
					self.eventFrame:RegisterEvent(contextEventTable.events[i])
				end

				--if the callback function returns true, the context is finished
				self.eventFrame:SetScript("OnEvent", function(eventFrame, event, ...)
					if (contextEventTable.callback(event, ...)) then
						Details222.DebugMsg("context manager event", event)
						--context completed
						Details222.DebugMsg("Context Completed!")
						C_Timer.After(1, fOnContextFinished)
						C_Timer.After(1.1, function() self:FinishContext() end)
					end
				end)

				Details222.DebugMsg("a new context has been set.")
			end,

			---check if the player is in a context of interest
			---@param self contextmanager
			---@param instanceId number
			---@param instanceName string
			---@param instanceType string
			---@param difficultyId number
			CheckContextInterest = function(self, instanceId, instanceName, instanceType, difficultyId)
				Details222.DebugMsg("Checking for new context:", instanceId, instanceName, instanceType, difficultyId)
				--normal, heroic and mythic0 dungeons on Retail
				local diffTable = Details222.InstanceDifficulty
				if (difficultyId == diffTable.DungeonNormal or difficultyId == diffTable.DungeonHeroic or difficultyId == diffTable.DungeonMythic) then
					if (DetailsFramework.IsDragonflightAndBeyond()) then
						--check if the player is in the same context
						if (self.bHasContext and self.instanceId == instanceId and self.instanceType == instanceType and self.instanceName == instanceName and self.instanceDifficulty == difficultyId) then
							return
						end

						do return end

						--if a context is found, finishes it before a new one is created
						if (self.bHasContext) then
							--discard the context
							Details222.DebugMsg("had an active context, finishing it.")
							self:FinishContext()
						end

						--set a new context where at the end of the dungeon it creates an overall segment for the run
						--function to verify if context is finished, in this case if all objectives of the dungeon has been completed by listening to the SCENARIO_COMPLETED event
						local contextEventTable = {
							events = {"SCENARIO_COMPLETED"},
							callback = function(...)
								--when a context return true, the context is finished and will trigger a call on the fOnContextFinished function
								return true
							end
						}

						--create a contextId to tag combats that are part of the same context
						self.contextId = instanceName .. tostring(time())

						--called when a combat finishes and this context is still active
						local fOnCombatFinished = function()
							local currentCombat = Details:GetCurrentCombat()
							currentCombat.context = self.contextId
						end

						---this function evaluates if this context has lost its interest and should be discarded, return true if the context is no longer valid
						local fHasLostInterest = function(instanceId, instanceName, instanceType, difficultyId)
							--check if the player is still in the same context
							if (self.instanceId ~= instanceId or self.instanceType ~= instanceType or self.instanceName ~= instanceName or self.instanceDifficulty ~= difficultyId) then
								return true
							end
						end

						--will ba called when the context finishes, in this case when the SCENARIO_COMPLETED event is triggered
						local fOnContextFinished = function()
							--check if this is not a mythic+ run
							if (C_ChallengeMode.GetActiveChallengeMapID() or C_ChallengeMode.GetActiveKeystoneInfo() or C_ChallengeMode.IsChallengeModeActive()) then
								print("did not start as this is a m+ run")
								return
							else
								print("this is not a m+ run")
							end

							---@type combat[]
							local interestCombats = {}
							--get all segments
							local segments = Details:GetCombatSegments()
							for i = 1, #segments do
								local segment = segments[i]
								if (segment.context == self.contextId) then
									interestCombats[#interestCombats+1] = segment
								end
							end

							if (#interestCombats > 0) then
								--start a new combat
								Details222.StartCombat()

								Details222.DebugMsg("merging", #interestCombats, "combats into a single combat.")

								---@type combat
								local currentCombat = Details:GetCurrentCombat()

								--iterate over all interest combats
								for i = 1, #interestCombats do
									local interestCombat = interestCombats[i]
									--add the combat to the new combat
									currentCombat:AddCombat(interestCombat, i == 1, i == #interestCombats)
								end

								Details222.DebugMsg("combat time:", currentCombat:GetCombatTime())

								--finish the new combat
								Details:EndCombat()

								currentCombat.is_trash = false
								currentCombat.combat_type = DETAILS_SEGMENTTYPE_DUNGEON_OVERALL
								currentCombat.is_dungeon_overall = true
							end

							Details222.DebugMsg("overall segment has been created.")
						end

						self:StartContext(instanceId, instanceName, instanceType, difficultyId, contextEventTable, fOnCombatFinished, fOnContextFinished, fHasLostInterest)

						return
					end
				else
					--if no context is found, check if there is a current context and check if it lost its interest
					if (self.bHasContext) then
						if (self.fHasLostInterest(self, instanceId, instanceName, instanceType, difficultyId)) then
							Details222.DebugMsg("no context found, but context is active, finishing the current context.")
							--discard the context
							self:FinishContext()
						end
					end
				end
			end,

			---finish the current context
			---@param self contextmanager
			FinishContext = function(self)
				if (not self.bHasContext or not self.bContextStarted or self.bContextFinished) then
					return
				end

				--mark this context as finished
				self.bContextFinished = true

				--reset context
				self.instanceType = "INIT"
				self.instanceName = "INIT"
				self.contextId = "INIT"
				self.instanceId = -1
				self.instanceDifficulty = 0
				self.bContextStarted = false
				self.bHasContext = false
				self.fOnContextFinished = emptyFunction
				self.fHasLostInterest = emptyFunction
				self.fOnCombatFinished = emptyFunction
				self.contextEventTable = emptyTable
			end,

			---return the current contextIndex
			---@param self contextmanager
			---@return number|boolean, string?, string?, number?
			GetContext = function(self)
				if (self.bHasContext) then
					return self.instanceId, self.instanceName, self.instanceType, self.instanceDifficulty
				end
				return false
			end,
		}

        local GetSpellInfo = C_Spell and C_Spell.GetSpellInfo or GetSpellInfo
        Details222.GetSpellInfo = GetSpellInfo

		local UnitBuff = C_UnitAuras and C_UnitAuras.GetBuffDataByIndex or UnitBuff
		Details222.UnitBuff = UnitBuff

		local UnitDebuff = C_UnitAuras and C_UnitAuras.GetDebuffDataByIndex or UnitDebuff
		Details222.UnitDebuff = UnitDebuff

        if (C_Spell and C_Spell.GetSpellInfo) then
            Details222.GetSpellInfo = function(...)
                local result = GetSpellInfo(...)
                if result then
                    return result.name, 1, result.iconID
                end
            end
        end

        if (C_UnitAuras and C_UnitAuras.GetAuraDataByIndex) then
			Details222.UnitBuff = function(unitToken, index, filter)
				local auraData = UnitBuff(unitToken, index, filter)
				if (not auraData) then
					return nil
				end
				return AuraUtil.UnpackAuraData(auraData)
			end

			Details222.UnitDebuff = function(unitToken, index, filter)
				local auraData = UnitDebuff(unitToken, index, filter)
				if (not auraData) then
					return nil
				end
				return AuraUtil.UnpackAuraData(auraData)
			end
        end


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--initialization stuff
local _

do
	local _detalhes = _G.Details
	_detalhes.resize_debug = {}

	local Loc = _G.LibStub("AceLocale-3.0"):GetLocale("Details")

--[=[
Added /note command to create and share a note in mythic+ dungeons.
Rogues do not exit combat when using vanish on combat dummies!!!
New Mythic+ damage graphic.
New Mythic+ Run Completion Panel, more complete and compact.
Major improvements on buff tracking uptime.
Added a buff filter to ignore weekly buffs.
Major overhaul on statistics system, record defeated raid bosses while in guild.
Major bug fixes and stability improvements by refactoring legacy code.
Health for death log now uses health percent at the moment of the hit instead of percent based on the unit normalized max health.
Added an option to limit the number of segments saved for wipes at the same boss.
Added WoW 11 trinket data.
Options panel won't trigger errors when opening in combat.
Updated spells for spec detection for wow 11 (Flamanis).
Add anonymization options to the event tracker (Flamanis).
Fixed several issues with classic and pvp battlegrounds (Flamanis).
Major fixes related to pet detection and pet data (Flamanis).
Made Details! survive for another expansion (Details! Team).
--]=]

	local news = {
		{"v11.0.2.13000.160", "September 07th, 2024"},
		"Added /note command to create and share a note in mythic+ dungeons.",
		"Rogues do not exit combat when using vanish on combat dummies!!!",
		"New Mythic+ damage graphic.",
		"New Mythic+ Run Completion Panel, more complete and compact.",
		"Major improvements on buff tracking uptime.",
		"Added a buff filter to ignore weekly buffs.",
		"Major overhaul on statistics system, record defeated raid bosses while in guild.",
		"Major bug fixes and stability improvements by refactoring legacy code.",
		"Health for death log now uses health percent at the moment of the hit instead of percent based on the unit normalized max health.",
		"Added an option to limit the number of segments saved for wipes at the same boss.",
		"Added WoW 11 trinket data.",
		"Options panel won't trigger errors when opening in combat.",
		"Updated spells for spec detection for wow 11 (Flamanis).",
		"Add anonymization options to the event tracker (Flamanis).",
		"Fixed several issues with classic and pvp battlegrounds (Flamanis).",
		"Major fixes related to pet detection and pet data (Flamanis).",
		"Made Details! survive for another expansion (Details! Team).",

		{"v10.2.7.12800.156", "June 06th, 2024"},
		"Added transliteration for pet names in Cyrillic.",
		"Fixed an error with extra power bars (alternate power) on cataclysm classic.",
		"Fixed a rare error shown as 'combat already deleted' when trying to reset data.",
		"Fixed an issue which was preventing to open the death recap window.",
		"Fixed cataclysm classic attempting to calculate Evoker buffs.",
		"Fixed battleground problems with cataclysm classic. (Flamanis)",
		"Fixed an issue with player nicknames not showing properly when the player isn't inside a guild. (Flamanis)",

		{"v10.2.7.12755.156", "May 19th, 2024"},
		"Pet names on tooltips are now transliterate from Cyrillic.",
		"Default segments amount are now 25 and save 15, users with different amount set won't have their settings changed.",
		"Fixed an error when the user opens the death recap.",
		"Merging the effects of All-Totem of the Mastr (Flamanis).",
		"Added a season setting to stop right click for bookmark: '/run Details.no_bookmark = true' stop the right click for bookmark in combat or not.\n/run Details.no_bookmark_on_combat = true stop the right click for bookmark only in combat.\nYou need to run this command every time you log in or add it into the Auto Run Code.",
		"A few changes has been done in an attempt to fix the loot squares not showing properly in the mythic+ end screen.",
		"The options panel now cannot be dragged outside the screen, this will stop users with two monitors to acciently moving the window out of screen.",
		"Tooltip bar colors are now fixed and won't lost its setting on reload.",
		"The buff Rallied to Victory should now be shown in the player breakdown window Auras tab.",

		{"v10.2.6.12699.156", "May 03th, 2024"},
		"Framework and Backend upgrades.",
		"Added Toc data for Cata classic.",
		"Warrior Arms Whirlwind has been merged into one spell (WillowGryph).",
		"Added an option to control the horizontal gap between two groupped windows (Elitesparkle).",
		"Fixed an issue where looting two itens at the end of a mythic+ would result in the icon of one item and the tooltip of another.",
		"Fixed the preview of the Wallpaper option where it was too high positioned reaching the title bar.",

		{"v10.2.6.12650.156", "April 23th, 2024"},
		"Framework and Backend upgrades.",
		"Added prist's void tendrils to crowd control list.",
		"Fixes for asian clients where the spell names were not showing properly when the spell name is too long.",
		"Cataclysm Clasic and MOP Remix are now working.",

		{"v10.2.6.12578.156", "March 25th, 2024"},
		"Added phase and elapsed time for boss wipes on the segment selection menu.",
		"Added an option to toggle between rounded and squared tooltips.",
		"Fixed an issue with icons not showing on classic versions of the game.",
		"Changed Augmentation tooltip color to darkgreen.",
		"When leaving a m+ dungeon, Details! will wait for the player to re-enter the dungeon before finishing and creating the overall m+ segment.",
		"Added a function for artists add custom icon sets for class or specs: Details:AddCustomIconSet(path, dropdownOptionName[[[[[, isSpecIcons], icon], texCoords], iconSize], iconColor]) (Flamanis).",

		{"v10.2.5.12550.156", "March 13th, 2024"},
		"Added a combat selection option into the breakdown window, providing convenience when browsing damage or healing data in that window.",
		"Added a report button to the breakdown window, allowing you to report spell damage, targets, and phases directly from that window.",
		"Added combat comparison (Compare tab), allowing you to compare yourself between different combats. This is especially useful for training dummies.",
		"Added the option to show or hide the Augmentation Evoker extra bar.",
		"Added bar texture option 'Skyline Compact' and alert sounds 'Details Truck' and 'Details Bass Drop'.",
		"The menu for combat selection has received a visual update.",
		"Breakdown options received text settings, these settings also change the text in the display selection (right click at window title bar).",
		"Applied a visual patch for windows other than the main ones, making them with rounded corners.",

		{"v10.2.5.12329.155", "February 18th, 2024"},
		"Frame for 'Ask to Erase Data' can now be moved.",
		"Small bug fixes and continued development on End of Mythic+ Panel.",

		{"v10.2.5.12307.155", "February 13th, 2024"},
		"Fixed the deaths display, where the windows wasn't usig custom text scripts.",
		"Fixed an issue with custom displays, where it was unable to use class colors in their texts.",
		"More development and bug fixes on the new Mythic+ Run Completion panel.",
		"Framework Update.",

		{"v10.2.5.12294.155", "February 08th, 2024"},
		"General fixes applied to the Mythic+ Panel.",
		"The Mythic+ section in the options panel can now be translated.",
		"More fixes for text color.",

		{"v10.2.5.12281.155", "February 07th, 2024"},
		"Released the new panel for the Mythic+ Run Completion.",
		"The list of Crowd Control spells is now sourced from the Lib Open Raid.",
		"Fixed an issue where the Player Color feature wouldn't work properly if not using class colors.",
		"Fixed an error with Vanilla, where it was trying to access talent data from Retail.",

		{"v10.2.5.12255.155", "February 04th, 2024"},
		"Dungeon followers now correctly show into the damage done section.",
		"Fixed an error while statusbar plugin options.",
		"Backend code maintenance.",

		{"v10.2.5.12236.155", "January 20th, 2024"},
		"Added Blistering Scales and Mana Restored to the Evoker Predicted Damage bar.",
		"Fixed an issue which was making the Evoker Predicted Damage bar to show beyond the window width.",
		"Fixed the key level up animation at the new End of Mythic+ Run panel.",
		"Lib Open Raid updated to use Burst communications (Grim). The command /keys should give all Keys of the party almost instantly now.",
		"Framework updated and other minor fixes.",

		{"v10.2.0.12220.155", "January 14th, 2024"},
		"Ignoring the heal of Smoldering Seedling trinket (Flamanis).",
		"Attribute Judgement of Light to the healed on Wrath (Flamanis).",
		"Fixed an error while scrolling down target npcs in the breakdown window.",
		"Fixed an error when clicking to open the Death Recap by Details!.",
		"End of Mythic Run panel got updates.",
		"Many tooltips in Details! are now rouded!",
		"Evoker extra bar tooltip's, now also show the uptime of Black Attunement and Prescience applications.",
		"Breakdown Window now show Plater Npc Colors in the target box.",
		"Added event: 'COMBAT_MYTHICPLUS_OVERALL_READY', trigger when the overall segment for the mythic+ is ready.",
		"Added event: 'COMBAT_PLAYER_LEAVING', trigger at the beginning of the leave combat process.",
		"Added: Details:IsInMythicPlus() return true if the player is on a mythic dungeon run.",
		"CombatObjects now have the key 'is_challenge' if the combat is a part of a challenge mode or mythic+ run.",
		"Lib Open Raid updated.",

		{"v10.2.0.12188.155", "December 28th, 2023"},
		"Dreamwalker's Healing Potion now shows in the Healing Potion & Stone custom display.",
		"Added the 'Remove Battleground Segments' option to the menu that opens when hovering over the erase button.",
		"Attempt to fix Battleground faction icons, shown on enemy players damage bars.",
		"API: Actor:GetSpellContainer(containerName) now also accepts dispelwhat, interrupt, interruptwhat, interrupttargets.",
		"Fixed custom scripts showing the damage text too close to the dps text.",
		"Fixed Dynamic Overall Data, showing overlapped texts for damage and dps.",
		"Fixed an error when hovering over some spells in the Auras panel on the Player Breakdown window.",
		"Fixed the character item level, which was not showing for players that left the party group on the Player Breakdown window.",
		"Fixed boss images not showing at the segments selection menu.",
		"Other updates related to encounter journal and mythic+, both under development.",
		"Update Details! Framework for bug fixes.",
		"Update lib Open Raid (more cooldowns added).",

		{"v10.2.0.12109.155", "December 14th, 2023"},
		"Classic now uses the same combat log reader as retail (Flamanis).",
		"Merged Rage of Fyr'alath spells (equara)",
		"Added Rogue Ambushes to merged spells (WillowGryph).",
		"The Remove Common Segments option now also removes segments trash between raid bosses.",
		"Fixed an issue where auras applied before combat start, such as Power Infusion and Prescience, which are counted towards the target, were not being accounted for.",
		"Added to Combat Class: classCombat:GetRunTimeNoDefault(). This returns the run time of the Mythic+ if available, nil otherwise.",

		{"v10.2.0.12096.155", "December 1st, 2023"},
		"Added Mythic+ Overall DPS calculation options: 'Use Total Combat Time' and 'Use Run Time'. These options are available in the Mythic Dungeon section of the options panel. The option 'Use Run Time', takes the player's damage and divide by the total elapsed time of the run.",
		"Added reset options: 'Remove Common Segments' and 'Reset, but keep Mythic+ Overall Segments'.",
		"Added trinket 'Corrupted Starlight' and 'Dreambinder, Loom of the Great Cycle' extra information.",
		"Fixes for the API change of distance checks.",
		"Fixed some panels in the options panel, not closing at pressing the X button.",
		"Fixed the Pet of a Pet detection non ending loop (Flamanis).",
		"Fixed the issue of combats having only 1 second of duration.",
		"Fixed the Damage Graphic not showing after a Mythic+ run.",
		"Fixed an issue while renaming a spell, the change wouldn't stick and the spell would be renamed back to the original name.",
		"Fixed death logs now showing the green healing bar.",
		"Fixed Augmentation Evoker not showing the extra predicted damage bar.",
		"Fixed an issue where users were unable to see interrupts and cooldowns.",
		"Added to Combat Class: combat:GetRunTime(). This returns the run time if available or combat:GetCombatTime() if not.",

		{"v10.2.0.12023.155", "November 08th, 2023"},
		"Several fixes to make the addon work with the combat log changes done on patch 10.2.0.",
		"Added trinket data for patch 10.2.0.",
		"Fixed an issue with death tooltips going off-screen when the window is too close to a screen border.",
		"Fixed a spam of errors during battlegrounds when an enemy player heal with a dot spell.",

		{"v10.1.7.12012.155", "October 27th, 2023"},
		"Implemented [Pip's Emerald Friendship Badge] trinket buffs.",
		"Implemented the amount of times 'On Use' trinkets are used.",
		"10.2 trinket damage spells renamed to the item name.",
		"Framework Upgrade",
		"Lib OpenRaid Upgrade.",
		"Fixed the issue 'Segment Not Found' while resetting data.",
		"Fixed Rogue icon",
		"Fixed an issue with the healing merge amount on death tooltips (Flamanis).",
		"Fixed 'extraStatusbar' showing in wrong views (non-player-dmg) (Continuity).",
		"Removed LibCompress (Flamanis).",

		{"v10.1.7.11914.155", "September 13th, 2023"},
		"Added an extra bar within the evoker damage bar, this new bar when hovered over shows the buff uptime of Ebon Might and Prescience on all players.",
		"ToC Files of all plugins got updated.",
		"Fixed the error 'Attempt to compare string with number' on vanilla (Flamanis).",
		"Fixed the error 'object:ToolTip() is invalid'.",

		{"v10.1.7.11901.155", "September 09th, 2023"},
		"Evoker Predicted Damage improvements.",
		"Improved spellId check for first hit when entering a combat (Flamanis).",
		"Replaced Classic Era deprecated functions (Flamanis).",
		"Change DF/pictureedit frame heirarchy to allow for close button and Done button to work right (Flamanis).",
		"Unlocked Retail Streamer plugin for Classic Era (Flamanis).",
		"Attempt to fix death log healing spam where a spell has multiple heals in the same millisecond.",
		"Fixed an error with the old comparison window.",

		{"v10.1.7.11856.155", "August 13th, 2023"},
		"Fixed an issue with importing a profile with a corrupted time type.",
		"Added Elemental Shaman overload spells (WillowGryph).",

		{"v10.1.5.11855.155", "August 12th, 2023"},
		"Forcing update interval to 0.1 on arenas matches using the real-time dps feature.",
		"More parser cleanups and code improvements.",
		"Auras tab now ignores regular 'world auras' (those weekly buffs of reputation, etc)",
		"Fixed the player info tooltip (hovering the spec icon) height not being updated for Evoker Predicted damage.",
		"Framework Update.",
		"Lib Open Raid Update.",
		"Code cleanup and refactoring.",

		{"v10.1.5.11773.151", "July 30th, 2023"},
		"Add animIn/animOut checks for the welcome window (Flamanis)",
		"Fixed an issue with players with the time measurement 'real time' (Flamanis).",

		{"v10.1.5.11770.151", "July 29th, 2023"},
		"Removed 'Real Time DPS' from the time measure dropdown.",
		"Added 'Show 'Real Time' DPS' toggle to show real time dps while in combat.",
		"Added 'Order Bars By Real Time DPS' toggle to order bars by the amount of real time dps.",
		"Added 'Always Use Real Time in Arenas' toggle to always use real time dps in Arenas.",
		"Added .last_dps_realtime to player actors, caches the latest real time dps calculated.",
		"Fixed breakdown window not opening when there's player data available at the window.",
		"Fixed Augmented Evoker buffs placed before the combat start not being counted.",
		"Cyclical pet ownership fix (Flamanis).",
		"Added: Details:FindBuffCastedBy(unitId, buffSpellId, casterName), return up to 19 parameters",
		"Framework and OpenRaid upgrades.",

		{"v10.1.5.11718.151", "July 20th, 2023"},
		"Renamed damageActor.extra_bar to damageActor.total_extra",
		"Added: Details:ShowExtraStatusbar(barLineObject, amount, amountPercent, extraAmount)",
		"Add the evoker predicted damage to overall data.",
		"If any damage actor has 'total_extra' bigger than 0, the extra bar is shown.",
		"List of spec names for spec tooltip detection now load at Startup not at lua compiling.",
		"Renamed InstaciaCallFunction to InstanceCallDetailsFunc.",
		"Fixed things about the Real Time DPS; Open Raid Lib Update.",
		"Fixed Details:FindDebuffDuration(unitId, spellId, casterName) which wasn't taking the casterName in consideration.",
		"Fixes on Encounter Details plugin.",
		"Fixed an issue of clicking in a plugin icon in the title bar of Details! but the plugin wouldn't open.",

		{"v10.1.5.11718.151", "July 13th, 2023"},
		"Added: Hovering over the Augmented Evoker icon shows the Evoker's damage, along with an estimated damage done by its buffs.",
		"Auras tab at the Breakdown Window, now shows damage buffs received from other players (Ebon Might, Precience and Power Infusion).",
		"Auras tab now ignores regular 'world auras' (those weekly buffs of reputation, etc).",
		"Added individual bar for Neltharus Weapons. Weapons on final boss and the Burning Chain (Flamanis).",
		"Update interval is set to 0.1 on arenas matches using the real-time dps feature.",
		"Evoker's predicted damage done is now also shown in the overall data.",
		"Removed 'Real Time DPS' from the time measure dropdown.",
		"Added 'Show Real Time DPS' toggle to show real time dps while in combat.",
		"Added 'Order Bars By Real Time DPS' toggle to order bars by the amount of real time dps.",
		"Added 'Always Use Real Time in Arenas' toggle to always use real time dps in Arenas.",
		"Fixed an issue where the Breakdown Window was not refreshing when the data was reset.",
		"Fixed an issue where clicking on a plugin icon in the Details! title bar would not open the plugin.",
		"Fixed bugs reported for the Encounter Details plugin.",
		"Fixed bugs reported for the Real Time DPS.",
		"Fixed Welcome Window sometimes not opening for new instalations (Flamanis).",
		"*Combat start code verification cleanup (Flamanis).",
		"*Added .last_dps_realtime to player actors, caches the latest real time dps calculated.",
		"*Added: actordamage.total_extra for cases where there's a secondary bar for a damage actor.",
		"*If any damage actor has 'total_extra' bigger than 0, the extra bar is shown.",
		"*Added: Details:ShowExtraStatusbar(lineFrame, amount, extraAmount, totalAmount, topAmount, instanceObject, onEnterFunc, onLeaveFunc)",
		"*Renamed 'InstaciaCallFunction' to 'InstanceCallDetailsFunc'.",
		"*Renamed 'PegaHabilidade' to GetOrCreateSpell.",
		"*Renamed 'PegarCombatente' to 'GetOrCreateActor'.",
		"*List of spec names for spec tooltip detection now load at Startup not at lua compiling stage.",
		"*Fixed custom displays ignoring actor.customColor.",
		"*Details! Framework and LibOpenRaid upgrades.",

		{"v10.1.0.11700.151", "July 11th, 2023"},
		"Effective time is used when displaying tooltips information.",
		"Wrap the specid name locatlization cache in a Details Framework check.",
		"More fixes for real time dps.",
		"Don't populate overall segment on load and force refresh window on segment swap.",
		"Added: spec detection from the specialization name shown on tooltip.",
		"Improvements to class detection by using GetPlayerInfoByGUID()",
		"Removed Breath of Eons from spec detection for augmentation evokers.",
		"When DBM/BW send a callback, check if the current combat in details is valid.",
		"When the actor is considered a ungroupped player, check if that player has a spec and show the spec icon instead.",
		"Segments locked don't swap windows to overall.",
		"Use the new API 'SetSegment' over 'TrocaTabela' for the segment selector.",
		"Sort damage taken tooltip on damage amount.",
		"Added: Details:GetBossEncounterTexture(encounterName); Added combat.bossIcon; Added combat.bossTimers.",
		"Added: Details:DoesCombatWithUIDExists(uniqueCombatId); Details:GetCombatByUID(uniqueCombatId); combat:GetCombatUID().",
		"Added: Details:RemoveSegmentByCombatObject(combatObject).",
		"Details:UnpackDeathTable(deathTable) now return the spec of the character as the last parameter returned.",
		"classCombat:GetTimeData(chartName) now check if the combat has a TimeData table or return an empty table; Added classCombat:EraseTimeData(chartName).",
		"Code for Dispel has been modernized, deathTable now includes the key .spec.",
		"Added: key .unixtime into is_boss to know when the boss was killed.",
		"Fixed an issue with auto run code not saving properly.",
		"Ignore vessel periodic damage when out of combat.",
		"More fixes for Augmentation Evoker on 10.1.5.",
		"Another wave of code changes, modernizations and refactoring.",
		"Combat Objects which has been discarded due to any reason will have the boolean member: __destroyed set to true. With this change, 3rd party code can see if the data cached is up to date or obsolete.",
		"Removed several deprecated code from March 2023 and earlier.",
		"Large amount of code cleanup and refactoring, some functions got renamed, they are listed below:",
		"- 'TravarTempos' renamed to 'LockActivityTime'.",
		"- 'ClearTempTables' renamed to 'ClearCacheTables'.",
		"- 'SpellIsDot' renamed to 'SetAsDotSpell'.",
		"- 'FlagCurrentCombat' remamed to 'FlagNewCombat_PVPState'.",
		"- 'segmentClass:AddCombat(combatObject)' renamed to 'Details222.Combat.AddCombat(combatToBeAdded)'.",
		"- 'CurrentCombat.verifica_combate' timer is now obsolete.",
		"- 'Details.last_closed_combat' is now obsolete.",
		"- 'Details.EstaEmCombate' is now obsolete.",
		"- 'Details.options' is now obsolete.",
		"- Spec Guess Timers are now stored within Details222.GuessSpecSchedules.Schedules, all timers are killed at the end of the combat or at a data reset.",
		"- Initial time delay to send the startup signal (event sent when details has started) reduced from 5 to 4 seconds.",
		"- Fixed some division by zero on ptr 10.1.5.",
		"- Fixed DETAILS_STARTED event not triggering in some cases due to 'event not registered'.",
		"Fixed Auto Run Code window not closing by click on the close button.",
		"Set up statusbar options instead of using metatable.",
		"More code cleanup and framework updates.",
		"TimeData code modernizations.",
		"Implementations to show plugins in the breakdown window.",
		"Damage Taken by Spell overhaul, now it uses modern Details API.",
		"Time Machine overhaul.",
		"Splitted the window_playerbreakdown_spells.lua into three more files.",
		"Added IconTexture directive to the TOC files.",
		"Disabled time captures for spellTables, this should be done by a plugin.",
		"Replacing table.wipe with Details:Destroy().",
	}

	local newsString = "|cFFF1F1F1"

	for i = 1, #news do
		local line = news[i]
		if (type(line) == "table")  then
			local version = line[1]
			local date = line[2]
			newsString = newsString .. "|cFFFFFF00" .. version .. " (|cFFFF8800" .. date .. "|r):|r\n\n"
		else
			if (line ~= "") then
				newsString = newsString .. "|cFFFFFF00-|r " .. line .. "\n\n"
			else
				newsString = newsString .. " \n"
			end
		end
	end

	Loc["STRING_VERSION_LOG"] = newsString

	Loc ["STRING_DETAILS1"] = "|cffffaeaeDetails!:|r "

	--startup
		_detalhes.max_windowline_columns = 11
		_detalhes.initializing = true
		_detalhes.enabled = true
		_detalhes.__index = _detalhes
		_detalhes._tempo = time()
		_detalhes.debug = false
		_detalhes.debug_chr = false
		_detalhes.opened_windows = 0
		_detalhes.last_combat_time = 0
		_detalhes.last_zone_type = "INIT"
		_detalhes.last_zone_id = -1

		--store functions to create options frame
		Details.optionsSection = {}

	--containers
		--armazenas as fun��es do parser - All parse functions
			_detalhes.parser = {}
			_detalhes.parser_functions = {}
			Details222.parser_frame = CreateFrame("Frame")
			Details222.parser_frame:Hide()
			_detalhes.pvp_parser_frame = CreateFrame("Frame")

			_detalhes.MacroList = {
				{Name = "Click on Your Own Bar", Desc = "To open the player details window on your character, like if you click on your bar in the damage window. The number '1' is the window number where it'll click.", MacroText = "/script Details:OpenPlayerDetails(1)"},
				{Name = "Open Encounter Breakdown", Desc = "Open the encounter breakdown plugin. Details! Encounter Breakdown (plugin) must be enabled.", MacroText = "/script Details:OpenPlugin ('Encounter Breakdown')"},
				{Name = "Open Damage per Phase", Desc = "Open the encounter breakdown plugin in the phase tab. Details! Encounter Breakdown (plugin) must be enabled.", MacroText = "/script Details:OpenPlugin ('Encounter Breakdown'); local a=Details_EncounterDetails and Details_EncounterDetails.buttonSwitchPhases:Click()"},
				{Name = "Reset Data", Desc = "Reset the overall and regular segments data. Use 'ResetSegmentOverallData' to reset only the overall.", MacroText = "/script Details:ResetSegmentData()"},
				{Name = "Change What the Window Shows", Desc = "Make a window show different data. SetDisplay uses (segment, displayGroup, displayID), the menu from the sword icon is in order (damage = group 1, overheal is: displayGroup 2 displayID 3.", MacroText = "/script Details:GetWindow(1):SetDisplay( DETAILS_SEGMENTID_CURRENT, 4, 5 )"},
				{Name = "Toggle Window Height to Max Size", Desc = "Make a window be 450 pixel height, pressing the macro again toggle back to the original size. The number '1' if the window number. Hold a click in any window to show their number.", MacroText = "/script Details:GetWindow(1):ToggleMaxSize()"},
			--	/script Details:OpenPlugin ('Advanced Death Logs'); local a = Details_DeathGraphsModeEnduranceButton and Details_DeathGraphsModeEnduranceButton.MyObject:Click()
				{Name = "Report What is Shown In the Window", Desc = "Report the current data shown in the window, the number 1 is the window number, replace it to report another window.", MacroText = "/script Details:FastReportWindow(1)"},
			}

		--current instances of the exp (need to maintain) - deprecated july 2024 - should do this automatically
			Details.InstancesToStoreData = { --mapId
				[2657] = true, --Nerub-ar Palace v11 T1
				[2294] = true, --Nerub-ar Palace v11 T1
			}

		--store shield information for absorbs
			_detalhes.ShieldCache = {}

		--armazena as fun��es dos frames - Frames functions
			_detalhes.gump = _G ["DetailsFramework"]
			function _detalhes:GetFramework()
				return self.gump
			end
			GameCooltip = GameCooltip2
		--anima��es dos icones
			_detalhes.icon_animations = {
				load = {
					in_use = {},
					available = {},
				},
			}

		--make a color namespace
		Details.Colors = {}
		function Details.Colors.GetMenuTextColor()
			return "orange"
		end

		function Details:GetTextureAtlasTable()
			return Details.TextureAtlas
		end

		--armazena as fun��es para inicializa��o dos dados - Metatable functions
			_detalhes.refresh = {}
		--armazena as fun��es para limpar e guardas os dados - Metatable functions
			_detalhes.clear = {}
		--armazena a config do painel de fast switch
			_detalhes.switch = {}
		--armazena os estilos salvos
			_detalhes.savedStyles = {}
		--armazena quais atributos possue janela de atributos - contain attributes and sub attributos wich have a detailed window (left click on a row)
			_detalhes.row_singleclick_overwrite = {}
		--report
			_detalhes.ReportOptions = {}
		--armazena os buffs registrados - store buffs ids and functions
			_detalhes.Buffs = {} --initialize buff table
		-- cache de grupo
			_detalhes.cache_damage_group = {}
			_detalhes.cache_healing_group = {}
			_detalhes.cache_npc_ids = {}
		--cache de specs
			_detalhes.cached_specs = {}
			_detalhes.cached_talents = {}
		--ignored pets
			_detalhes.pets_ignored = {}
			_detalhes.pets_no_owner = {}
		--dual candidates
			_detalhes.duel_candidates = {}
		--armazena as skins dispon�veis para as janelas
			_detalhes.skins = {}
		--armazena os hooks das fun��es do parser
			---@type table<detailshook, function[]>
			_detalhes.hooks = {}
		--informa��es sobre a luta do boss atual
			_detalhes.encounter_end_table = {}
			_detalhes.encounter_table = {}
			_detalhes.encounter_counter = {}
			_detalhes.encounter_dungeons = {}
		--unitId dos inimigos dentro de uma arena
			_detalhes.arena_enemies = {}
		--reliable char data sources
		--actors that are using details! and sent character data, we don't need query inspect on these actors
			_detalhes.trusted_characters = {}
		--informa��es sobre a arena atual
			_detalhes.arena_table = {}
			_detalhes.arena_info = {
				--need to get the new mapID for 8.0.1
				[562] = {file = "LoadScreenBladesEdgeArena", coords = {0, 1, 0.29296875, 0.9375}}, -- Circle of Blood Arena
				[617] = {file = "LoadScreenDalaranSewersArena", coords = {0, 1, 0.29296875, 0.857421875}}, --Dalaran Arena
				[559] = {file = "LoadScreenNagrandArenaBattlegrounds", coords = {0, 1, 0.341796875, 1}}, --Ring of Trials
				[980] = {file = "LoadScreenTolvirArena", coords = {0, 1, 0.29296875, 0.857421875}}, --Tol'Viron Arena
				[572] = {file = "LoadScreenRuinsofLordaeronBattlegrounds", coords = {0, 1, 0.341796875, 1}}, --Ruins of Lordaeron
				[1134] = {file = "LoadingScreen_Shadowpan_bg", coords = {0, 1, 0.29296875, 0.857421875}}, -- Tiger's Peak
				--legion, thanks @pas06 on curse forge for the mapIds
				[1552] = {file = "LoadingScreen_ArenaValSharah_wide", coords = {0, 1, 0.29296875, 0.857421875}}, -- Ashmane's Fall
				[1504] = {file = "LoadingScreen_BlackrookHoldArena_wide", coords = {0, 1, 0.29296875, 0.857421875}}, --Black Rook Hold

				--"LoadScreenOrgrimmarArena", --Ring of Valor
			}

			Details.IgnoredEnemyNpcsTable = {
				[31216] = true, --mirror image
				[53006] = true, --spirit link totem
				[63508] = true, --xuen
				[73967] = true, --xuen
			}

			function _detalhes:GetArenaInfo (mapid)
				local t = _detalhes.arena_info [mapid]
				if (t) then
					return t.file, t.coords
				end
			end
			_detalhes.battleground_info = {
				--need to get the nwee mapID for 8.0.1
				[489] = {file = "LoadScreenWarsongGulch", coords = {0, 1, 121/512, 484/512}}, --warsong gulch
				[727] = {file = "LoadScreenSilvershardMines", coords = {0, 1, 251/1024, 840/1024}}, --silvershard mines
				[529] = {file = "LoadscreenArathiBasin", coords = {0, 1, 126/512, 430/512}}, --arathi basin
				[566] = {file = "LoadScreenNetherBattlegrounds", coords = {0, 1, 142/512, 466/512}}, --eye of the storm
				[30] = {file = "LoadScreenPvpBattleground", coords = {0, 1, 127/512, 500/512}}, --alterac valley
				[761] = {file = "LoadScreenGilneasBG2", coords = {0, 1, 281/1024, 878/1024}}, --the battle for gilneas
				[726] = {file = "LoadScreenTwinPeaksBG", coords = {0, 1, 294/1024, 876/1024}}, --twin peaks
				[998] = {file = "LoadScreenValleyofPower", coords = {0, 1, 257/1024, 839/1024}}, --temple of kotmogu
				[1105] = {file = "LoadScreen_GoldRush", coords = {0, 1, 264/1024, 840/1024}}, --deepwind gorge
				[607] = {file = "LoadScreenNorthrendBG", coords = {0, 1, 302/1024, 879/1024}}, --strand of the ancients
				[628] = {file = "LOADSCREENISLEOFCONQUEST", coords = {0, 1, 297/1024, 878/1024}}, --isle of conquest
				--[] = {file = "", coords = {0, 1, 0, 0}}, --
			}
			function _detalhes:GetBattlegroundInfo(mapid)
				local battlegroundInfo = _detalhes.battleground_info[mapid]
				if (battlegroundInfo) then
					return battlegroundInfo.file, battlegroundInfo.coords
				end
			end

		--tokenid
			_detalhes.TokenID = {
				["SPELL_PERIODIC_DAMAGE"] = 1,
				["SPELL_EXTRA_ATTACKS"] = 2,
				["SPELL_DAMAGE"] = 3,
				["SPELL_BUILDING_DAMAGE"] = 4,
				["SWING_DAMAGE"] = 5,
				["RANGE_DAMAGE"] = 6,
				["DAMAGE_SHIELD"] = 7,
				["DAMAGE_SPLIT"] = 8,
				["RANGE_MISSED"] = 9,
				["SWING_MISSED"] = 10,
				["SPELL_MISSED"] = 11,
				["SPELL_PERIODIC_MISSED"] = 12,
				["SPELL_BUILDING_MISSED"] = 13,
				["DAMAGE_SHIELD_MISSED"] = 14,
				["ENVIRONMENTAL_DAMAGE"] = 15,
				["SPELL_HEAL"] = 16,
				["SPELL_PERIODIC_HEAL"] = 17,
				["SPELL_HEAL_ABSORBED"] = 18,
				["SPELL_ABSORBED"] = 19,
				["SPELL_AURA_APPLIED"] = 20,
				["SPELL_AURA_REMOVED"] = 21,
				["SPELL_AURA_REFRESH"] = 22,
				["SPELL_AURA_APPLIED_DOSE"] = 23,
				["SPELL_ENERGIZE"] = 24,
				["SPELL_PERIODIC_ENERGIZE"] = 25,
				["SPELL_CAST_SUCCESS"] = 26,
				["SPELL_DISPEL"] = 27,
				["SPELL_STOLEN"] = 28,
				["SPELL_AURA_BROKEN"] = 29,
				["SPELL_AURA_BROKEN_SPELL"] = 30,
				["SPELL_RESURRECT"] = 31,
				["SPELL_INTERRUPT"] = 32,
				["UNIT_DIED"] = 33,
				["UNIT_DESTROYED"] = 34,
			}

		---@type table<npcid, textureid>
		local npcIdToIcon = {
			[98035] = 1378282, --dreadstalker
			[17252] = 136216, --felguard
			[136404] = 132182, --bilescourge
			[136398] = 626007, --illidari satyr
			[136403] = 1100177, --void terror
			[136402] = 1581747, --ur'zyk
			[136399] = 1709931, --visious hellhound
			[136406] = 615148, --shivarra
			[136407] = 615025, --wrathguard
			[136408] = 1709932, --darkhound

		}
		_detalhes.NpcIdToIcon = npcIdToIcon

		--armazena instancias inativas
			_detalhes.unused_instances = {}
			_detalhes.default_skin_to_use = "Minimalistic"
			_detalhes.instance_title_text_timer = {}
		--player detail skin
			_detalhes.playerdetailwindow_skins = {}

		_detalhes.BitfieldSwapDebuffsIDs = {265646, 272407, 269691, 273401, 269131, 260900, 260926, 284995, 292826, 311367, 310567, 308996, 307832, 327414, 337253,
											36797, 37122, 362397}
		_detalhes.BitfieldSwapDebuffsSpellIDs = {
			[360418] = true
		}

		--auto run code
		_detalhes.RunCodeTypes = {
			{Name = "On Initialization", Desc = "Run code when Details! initialize or when a profile is changed.", Value = 1, ProfileKey = "on_init"},
			{Name = "On Zone Changed", Desc = "Run code when the zone where the player is in has changed (e.g. entered in a raid).", Value = 2, ProfileKey = "on_zonechanged"},
			{Name = "On Enter Combat", Desc = "Run code when the player enters in combat.", Value = 3, ProfileKey = "on_entercombat"},
			{Name = "On Leave Combat", Desc = "Run code when the player left combat.", Value = 4, ProfileKey = "on_leavecombat"},
			{Name = "On Spec Change", Desc = "Run code when the player has changed its specialization.", Value = 5, ProfileKey = "on_specchanged"},
			{Name = "On Enter/Leave Group", Desc = "Run code when the player has entered or left a party or raid group.", Value = 6, ProfileKey = "on_groupchange"},
		}

		--run a function without stopping the execution in case of an error
		function Details.SafeRun(func, executionName, ...)
			local runToCompletion, errorText = pcall(func, ...)
			if (not runToCompletion) then
				if (Details.debug) then
					Details:Msg("Safe run failed:", executionName, errorText)
				end
				return false
			end
			return true
		end

		--tooltip
			_detalhes.tooltip_backdrop = {
				bgFile = [[Interface\DialogFrame\UI-DialogBox-Background-Dark]],
				edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
				tile = true,
				edgeSize = 16,
				tileSize = 16,
				insets = {left = 3, right = 3, top = 4, bottom = 4}
			}
			_detalhes.tooltip_border_color = {1, 1, 1, 1}
			_detalhes.tooltip_spell_icon = {file = [[Interface\CHARACTERFRAME\UI-StateIcon]], coords = {36/64, 58/64, 7/64, 26/64}}
			_detalhes.tooltip_target_icon = {file = [[Interface\Addons\Details\images\icons]], coords = {0, 0.03125, 0.126953125, 0.15625}}

		--icons
			_detalhes.attribute_icons = [[Interface\AddOns\Details\images\atributos_icones]]
			function _detalhes:GetAttributeIcon (attribute)
				return _detalhes.attribute_icons, 0.125 * (attribute - 1), 0.125 * attribute, 0, 1
			end

		--colors
			_detalhes.default_backdropcolor = {.094117, .094117, .094117, .8}
			_detalhes.default_backdropbordercolor = {0, 0, 0, 1}

	--Plugins

		--plugin templates

		DetailsFramework:NewColor("DETAILS_PLUGIN_BUTTONTEXT_COLOR", 0.9999, 0.8196, 0, 1)
		DetailsFramework:NewColor("DETAILS_HEADER_YELLOW", 227/255, 186/255, 4/255)

		DetailsFramework:InstallTemplate("button", "DETAILS_PLUGINPANEL_BUTTON_TEMPLATE",
			{
				backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
				backdropcolor = {0, 0, 0, .5},
				backdropbordercolor = {0, 0, 0, .5},
				onentercolor = {0.3, 0.3, 0.3, .5},
			}
		)
		DetailsFramework:InstallTemplate("button", "DETAILS_PLUGINPANEL_BUTTONSELECTED_TEMPLATE",
			{
				backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
				backdropcolor = {0, 0, 0, .5},
				backdropbordercolor = {1, 1, 0, 1},
				onentercolor = {0.3, 0.3, 0.3, .5},
			}
		)

		DetailsFramework:InstallTemplate("button", "DETAILS_PLUGIN_BUTTON_TEMPLATE",
			{
				backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
				backdropcolor = {1, 1, 1, .5},
				backdropbordercolor = {0, 0, 0, 1},
				onentercolor = {1, 1, 1, .9},
				textcolor = "DETAILS_PLUGIN_BUTTONTEXT_COLOR",
				textsize = 10,
				width = 120,
				height = 20,
			}
		)
		DetailsFramework:InstallTemplate("button", "DETAILS_PLUGIN_BUTTONSELECTED_TEMPLATE",
			{
				backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
				backdropcolor = {1, 1, 1, .5},
				backdropbordercolor = {1, .7, 0, 1},
				onentercolor = {1, 1, 1, .9},
				textcolor = "DETAILS_PLUGIN_BUTTONTEXT_COLOR",
				textsize = 10,
				width = 120,
				height = 20,
			}
		)

		DetailsFramework:InstallTemplate("button", "DETAILS_TAB_BUTTON_TEMPLATE",
			{
				width = 100,
				height = 20,
			},
			"DETAILS_PLUGIN_BUTTON_TEMPLATE"
		)
		DetailsFramework:InstallTemplate("button","DETAILS_TAB_BUTTONSELECTED_TEMPLATE",
			{
				width = 100,
				height = 20,
			},
			"DETAILS_PLUGIN_BUTTONSELECTED_TEMPLATE"
		)

		Details.PluginsGlobalNames = {}
		Details.PluginsLocalizedNames = {}

		--raid -------------------------------------------------------------------
			--general function for raid mode plugins
				Details.RaidTables = {}
			--menu for raid modes
				Details.RaidTables.Menu = {}
			--plugin objects for raid mode
				Details.RaidTables.Plugins = {}
			--name to plugin object
				Details.RaidTables.NameTable = {}
			--using by
				Details.RaidTables.InstancesInUse = {}
				Details.RaidTables.PluginsInUse = {}

		--solo -------------------------------------------------------------------
			--general functions for solo mode plugins
				Details.SoloTables = {}
			--maintain plugin menu
				Details.SoloTables.Menu = {}
			--plugins objects for solo mode
				Details.SoloTables.Plugins = {}
			--name to plugin object
				Details.SoloTables.NameTable = {}

		--toolbar -------------------------------------------------------------------
			--plugins container
				Details.ToolBar = {}
			--current showing icons
				Details.ToolBar.Shown = {}
				Details.ToolBar.AllButtons = {}
			--plugin objects
				Details.ToolBar.Plugins = {}
			--name to plugin object
				Details.ToolBar.NameTable = {}
				Details.ToolBar.Menu = {}

		--statusbar -------------------------------------------------------------------
			--plugins container
				Details.StatusBar = {}
			--maintain plugin menu
				Details.StatusBar.Menu = {}
			--plugins object
				Details.StatusBar.Plugins = {}
			--name to plugin object
				Details.StatusBar.NameTable = {}

		--constants

		if (DetailsFramework.IsWotLKWow()) then
			--[[global]] DETAILS_HEALTH_POTION_ID = 33447 -- Runic Healing Potion
			--[[global]] DETAILS_HEALTH_POTION2_ID = 41166 -- Runic Healing Injector
			--[[global]] DETAILS_REJU_POTION_ID = 40087 -- Powerful Rejuvenation Potion
			--[[global]] DETAILS_REJU_POTION2_ID = 40077 -- Crazy Alchemist's Potion
			--[[global]] DETAILS_MANA_POTION_ID = 33448 -- Runic Mana Potion
			--[[global]] DETAILS_MANA_POTION2_ID = 42545 -- Runic Mana Injector
			--[[global]] DETAILS_FOCUS_POTION_ID = 307161
			--[[global]] DETAILS_HEALTHSTONE_ID = 47875 --Warlock's Healthstone
			--[[global]] DETAILS_HEALTHSTONE2_ID = 47876 --Warlock's Healthstone (1/2 Talent)
			--[[global]] DETAILS_HEALTHSTONE3_ID = 47877 --Warlock's Healthstone (2/2 Talent)

			--[[global]] DETAILS_INT_POTION_ID = 40212 --Potion of Wild Magic
			--[[global]] DETAILS_AGI_POTION_ID = 40211 --Potion of Speed
			--[[global]] DETAILS_STR_POTION_ID = 307164
			--[[global]] DETAILS_STAMINA_POTION_ID = 40093 --Indestructible Potion
			--[[global]] DETAILS_HEALTH_POTION_LIST = {
					[DETAILS_HEALTH_POTION_ID] = true, -- Runic Healing Potion
					[DETAILS_HEALTH_POTION2_ID] = true, -- Runic Healing Injector
					[DETAILS_HEALTHSTONE_ID] = true, --Warlock's Healthstone
					[DETAILS_HEALTHSTONE2_ID] = true, --Warlock's Healthstone (1/2 Talent)
					[DETAILS_HEALTHSTONE3_ID] = true, --Warlock's Healthstone (2/2 Talent)
					[DETAILS_REJU_POTION_ID] = true, -- Powerful Rejuvenation Potion
					[DETAILS_REJU_POTION2_ID] = true, -- Crazy Alchemist's Potion
					[DETAILS_MANA_POTION_ID] = true, -- Runic Mana Potion
					[DETAILS_MANA_POTION2_ID] = true, -- Runic Mana Injector
				}

		else
			--[[global]] DETAILS_HEALTH_POTION_ID = 307192 -- spiritual healing potion
			--[[global]] DETAILS_HEALTH_POTION2_ID = 359867 --cosmic healing potion
			--[[global]] DETAILS_REJU_POTION_ID = 307194
			--[[global]] DETAILS_MANA_POTION_ID = 307193
			--[[global]] DETAILS_FOCUS_POTION_ID = 307161
			--[[global]] DETAILS_HEALTHSTONE_ID = 6262

			--[[global]] DETAILS_INT_POTION_ID = 307162
			--[[global]] DETAILS_AGI_POTION_ID = 307159
			--[[global]] DETAILS_STR_POTION_ID = 307164
			--[[global]] DETAILS_STAMINA_POTION_ID = 307163
			--[[global]] DETAILS_HEALTH_POTION_LIST = {
					[DETAILS_HEALTH_POTION_ID] = true, --Healing Potion
					[DETAILS_HEALTHSTONE_ID] = true, --Warlock's Healthstone
					[DETAILS_REJU_POTION_ID] = true, --Rejuvenation Potion
					[DETAILS_MANA_POTION_ID] = true, --Mana Potion
					[323436] = true, --Phial of Serenity (from Kyrians)
					[DETAILS_HEALTH_POTION2_ID] = true,
				}
		end

		--[[global]] DETAILS_MODE_GROUP = 2
		--[[global]] DETAILS_MODE_ALL = 3

		Details._detalhes_props = {
			DATA_TYPE_START = 1,	--Something on start
			DATA_TYPE_END = 2,	--Something on end

			MODO_ALONE = 1,	--Solo
			MODO_GROUP = 2,	--Group
			MODO_ALL = 3,		--Everything
			MODO_RAID = 4,	--Raid
		}
		Details.modos = {
			alone = 1, --Solo
			group = 2,	--Group
			all = 3,	--Everything
			raid = 4	--Raid
		}

		Details.divisores = {
			abre = "(",	--open
			fecha = ")",	--close
			colocacao = ". " --dot
		}

		Details.role_texcoord = {
			DAMAGER = "72:130:69:127",
			HEALER = "72:130:2:60",
			TANK = "5:63:69:127",
			NONE = "139:196:69:127",
		}

		Details.role_texcoord_normalized = {
			DAMAGER = {72/256, 130/256, 69/256, 127/256},
			HEALER = {72/256, 130/256, 2/256, 60/256},
			TANK = {5/256, 63/256, 69/256, 127/256},
			NONE = {139/256, 196/256, 69/256, 127/256},
		}

		Details.player_class = {
			["HUNTER"] = true,
			["WARRIOR"] = true,
			["PALADIN"] = true,
			["SHAMAN"] = true,
			["MAGE"] = true,
			["ROGUE"] = true,
			["PRIEST"] = true,
			["WARLOCK"] = true,
			["DRUID"] = true,
			["MONK"] = true,
			["DEATHKNIGHT"] = true,
			["DEMONHUNTER"] = true,
		}
		Details.classstring_to_classid = {
			["WARRIOR"] = 1,
			["PALADIN"] = 2,
			["HUNTER"] = 3,
			["ROGUE"] = 4,
			["PRIEST"] = 5,
			["DEATHKNIGHT"] = 6,
			["SHAMAN"] = 7,
			["MAGE"] = 8,
			["WARLOCK"] = 9,
			["MONK"] = 10,
			["DRUID"] = 11,
			["DEMONHUNTER"] = 12,
		}
		Details.classid_to_classstring = {
			[1] = "WARRIOR",
			[2] = "PALADIN",
			[3] = "HUNTER",
			[4] = "ROGUE",
			[5] = "PRIEST",
			[6] = "DEATHKNIGHT",
			[7] = "SHAMAN",
			[8] = "MAGE",
			[9] = "WARLOCK",
			[10] = "MONK",
			[11] = "DRUID",
			[12] = "DEMONHUNTER",
		}

		local Loc = LibStub("AceLocale-3.0"):GetLocale ("Details")

		Details.segmentos = {
			label = Loc ["STRING_SEGMENT"]..": ",
			overall = Loc ["STRING_TOTAL"],
			overall_standard = Loc ["STRING_OVERALL"],
			current = Loc ["STRING_CURRENT"],
			current_standard = Loc ["STRING_CURRENTFIGHT"],
			past = Loc ["STRING_FIGHTNUMBER"]
		}

		Details._detalhes_props["modo_nome"] = {
				[_detalhes._detalhes_props["MODO_ALONE"]] = Loc ["STRING_MODE_SELF"],
				[_detalhes._detalhes_props["MODO_GROUP"]] = Loc ["STRING_MODE_GROUP"],
				[_detalhes._detalhes_props["MODO_ALL"]] = Loc ["STRING_MODE_ALL"],
				[_detalhes._detalhes_props["MODO_RAID"]] = Loc ["STRING_MODE_RAID"]
		}

		--[[global]] DETAILS_MODE_SOLO = 1
		--[[global]] DETAILS_MODE_RAID = 4
		--[[global]] DETAILS_MODE_GROUP = 2
		--[[global]] DETAILS_MODE_ALL = 3

		Details.icones = {
			--report window
			report = {
					up = "Interface\\FriendsFrame\\UI-Toast-FriendOnlineIcon",
					down = "Interface\\ItemAnimations\\MINIMAP\\TRACKING\\Profession",
					disabled = "Interface\\ItemAnimations\\MINIMAP\\TRACKING\\Profession",
					highlight = nil
				}
		}

		Details.missTypes = {"ABSORB", "BLOCK", "DEFLECT", "DODGE", "EVADE", "IMMUNE", "MISS", "PARRY", "REFLECT", "RESIST"} --do not localize-me


	function Details.SendHighFive()
		Details.users = {{UnitName("player"), GetRealmName(), (Details.userversion or "") .. " (" .. Details.APIVersion .. ")"}}
		Details.sent_highfive = GetTime()
		if (IsInRaid()) then
			Details:SendRaidData(Details.network.ids.HIGHFIVE_REQUEST)
		else
			Details:SendPartyData(Details.network.ids.HIGHFIVE_REQUEST)
		end
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--frames

	local CreateFrame = CreateFrame --api locals
	local UIParent = UIParent --api locals

	--create the breakdown window frame
	---@type breakdownwindow
	Details.BreakdownWindowFrame = CreateFrame("Frame", "DetailsBreakdownWindow", UIParent, "BackdropTemplate")
	Details.PlayerDetailsWindow = Details.BreakdownWindowFrame
	Details.BreakdownWindow = Details.BreakdownWindowFrame

	--Event Frame
	Details.listener = CreateFrame("Frame", nil, UIParent)
	Details.listener:RegisterEvent("ADDON_LOADED")
	Details.listener:SetFrameStrata("LOW")
	Details.listener:SetFrameLevel(9)
	Details.listener.FrameTime = 0

	Details.overlay_frame = CreateFrame("Frame", nil, UIParent)
	Details.overlay_frame:SetFrameStrata("TOOLTIP")

	--Pet Owner Finder
	CreateFrame("GameTooltip", "DetailsPetOwnerFinder", nil, "GameTooltipTemplate")


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--plugin defaults
	--backdrop
	Details.PluginDefaults = {}

	Details.PluginDefaults.Backdrop = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
	edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1,
	insets = {left = 1, right = 1, top = 1, bottom = 1}}
	Details.PluginDefaults.BackdropColor = {0, 0, 0, .6}
	Details.PluginDefaults.BackdropBorderColor = {0, 0, 0, 1}

	function Details.GetPluginDefaultBackdrop()
		return Details.PluginDefaults.Backdrop, Details.PluginDefaults.BackdropColor, Details.PluginDefaults.BackdropBorderColor
	end


------------------------------------------------------------------------------------------
-- welcome panel
	function _detalhes:CreateWelcomePanel(name, parent, width, height, makeMovable)
		local newWelcomePanel = CreateFrame("frame", name, parent or UIParent, "BackdropTemplate")

		DetailsFramework:ApplyStandardBackdrop(newWelcomePanel)
		newWelcomePanel:SetSize(width or 1, height or 1)

		if (makeMovable) then
			newWelcomePanel:SetScript("OnMouseDown", function(self, button)
				if (self.isMoving) then
					return
				end
				if (button == "RightButton") then
					self:Hide()
				else
					self:StartMoving()
					self.isMoving = true
				end
			end)

			newWelcomePanel:SetScript("OnMouseUp", function(self, button)
				if (self.isMoving and button == "LeftButton") then
					self:StopMovingOrSizing()
					self.isMoving = nil
				end
			end)
			newWelcomePanel:SetToplevel(true)
			newWelcomePanel:SetMovable(true)
		end

		return newWelcomePanel
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--functions

	_detalhes.empty_function = function() end
	_detalhes.empty_table = {}

	--register textures and fonts for shared media
		---@type table
		local SharedMedia = LibStub:GetLibrary ("LibSharedMedia-3.0")
		--default bars
		SharedMedia:Register("statusbar", "Details Hyanda Reverse", [[Interface\AddOns\Details\images\bar_textures\bar_hyanda_reverse.png]])
		SharedMedia:Register("statusbar", "You Are the Best!", [[Interface\AddOns\Details\images\bar_textures\bar_best.png]])
		SharedMedia:Register("statusbar", "Details Hyanda", [[Interface\AddOns\Details\images\bar_hyanda]])

		SharedMedia:Register("statusbar", "Details D'ictum", [[Interface\AddOns\Details\images\bar4]])
		SharedMedia:Register("statusbar", "Details Vidro", [[Interface\AddOns\Details\images\bar4_vidro]])
		SharedMedia:Register("statusbar", "Details D'ictum (reverse)", [[Interface\AddOns\Details\images\bar4_reverse]])

		--flat bars
		SharedMedia:Register("statusbar", "Skyline", [[Interface\AddOns\Details\images\bar_skyline]])

		SharedMedia:Register("statusbar", "Details Serenity", [[Interface\AddOns\Details\images\bar_serenity]])
		SharedMedia:Register("statusbar", "BantoBar", [[Interface\AddOns\Details\images\BantoBar]])
		SharedMedia:Register("statusbar", "Skyline Compact", [[Interface\AddOns\Details\images\bar_textures\bar_skyline_compact.png]])
		SharedMedia:Register("statusbar", "WorldState Score", [[Interface\WorldStateFrame\WORLDSTATEFINALSCORE-HIGHLIGHT]])
		SharedMedia:Register("statusbar", "DGround", [[Interface\AddOns\Details\images\bar_background]])
		SharedMedia:Register("statusbar", "Details Flat", [[Interface\AddOns\Details\images\bar_background]])
		SharedMedia:Register("statusbar", "Splitbar", [[Interface\AddOns\Details\images\bar_textures\split_bar]])
		SharedMedia:Register("statusbar", "Details2020", [[Interface\AddOns\Details\images\bar_textures\texture2020]])
		SharedMedia:Register("statusbar", "Left White Gradient", [[Interface\AddOns\Details\images\bar_textures\gradient_white_10percent_left]])
		SharedMedia:Register("statusbar", "Details! Slash", [[Interface\AddOns\Details\images\bar_textures\bar_of_bars.png]])

		--window bg and bar order
		SharedMedia:Register("background", "Details Ground", [[Interface\AddOns\Details\images\background]])
		SharedMedia:Register("border", "Details BarBorder 1", [[Interface\AddOns\Details\images\border_1]])
		SharedMedia:Register("border", "Details BarBorder 2", [[Interface\AddOns\Details\images\border_2]])
		SharedMedia:Register("border", "Details BarBorder 3", [[Interface\AddOns\Details\images\border_3]])
		SharedMedia:Register("border", "1 Pixel", [[Interface\Buttons\WHITE8X8]])

		--misc fonts
		SharedMedia:Register("font", "Oswald", [[Interface\Addons\Details\fonts\Oswald-Regular.ttf]])
		SharedMedia:Register("font", "Nueva Std Cond", [[Interface\Addons\Details\fonts\Nueva Std Cond.ttf]])
		SharedMedia:Register("font", "Accidental Presidency", [[Interface\Addons\Details\fonts\Accidental Presidency.ttf]])
		SharedMedia:Register("font", "TrashHand", [[Interface\Addons\Details\fonts\TrashHand.TTF]])
		SharedMedia:Register("font", "Harry P", [[Interface\Addons\Details\fonts\HARRYP__.TTF]])
		SharedMedia:Register("font", "FORCED SQUARE", [[Interface\Addons\Details\fonts\FORCED SQUARE.ttf]])

		SharedMedia:Register("sound", "Details Gun1", [[Interface\Addons\Details\sounds\sound_gun2.ogg]])
		SharedMedia:Register("sound", "Details Gun2", [[Interface\Addons\Details\sounds\sound_gun3.ogg]])
		SharedMedia:Register("sound", "Details Jedi1", [[Interface\Addons\Details\sounds\sound_jedi1.ogg]])
		SharedMedia:Register("sound", "Details Whip1", [[Interface\Addons\Details\sounds\sound_whip1.ogg]])
		SharedMedia:Register("sound", "Details Horn", [[Interface\Addons\Details\sounds\Details Horn.ogg]])

		SharedMedia:Register("sound", "Details Warning", [[Interface\Addons\Details\sounds\Details Warning 100.ogg]])
		SharedMedia:Register("sound", "Details Truck", [[Interface\Addons\Details\sounds\Details Truck.ogg]])
		SharedMedia:Register("sound", "Details Bass Drop", [[Interface\Addons\Details\sounds\bassdrop2.mp3]])

	--dump table contents over chat panel
		function Details.VarDump(t)
			if (type(t) ~= "table") then
				return
			end
			for a,b in pairs(t) do
				print(a,b)
			end
		end

		local bIsDump = false
		local waitForSpellLoad = CreateFrame("frame")
		if (C_EventUtils.IsEventValid("SPELL_TEXT_UPDATE")) then
			waitForSpellLoad:RegisterEvent("SPELL_TEXT_UPDATE")
			waitForSpellLoad:SetScript("OnEvent", function(self, event, spellId)
				if (bIsDump) then
					dumpt(spellId)
				end
			end)
		end

		function dumpt(value) --[[GLOBAL]]
			--check if this is a spellId
			local spellId = tonumber(value)
			if (spellId) then
				local spellInfo = {Details222.GetSpellInfo(spellId)}
				if (type(spellInfo[1]) == "string") then
					local desc = C_Spell.GetSpellDescription and C_Spell.GetSpellDescription(spellId) or GetSpellDescription(spellId)
					if (not desc or desc == "") then
						bIsDump = true
						return
					end

					if (C_Spell.GetSpellInfo) then
						Details:Dump({desc, C_Spell.GetSpellInfo(spellId)})
						return
					else
						return Details:Dump({desc, spellInfo})
					end

					bIsDump = false
				end
			end

			--check if is an atlas texture
			local atlas
			if (type(value) == "string") then
				atlas = C_Texture.GetAtlasInfo(value)
				if (atlas) then
					return Details:Dump(atlas)
				end
			end

			if (value == nil) then
				local allTooltips = {"GameTooltip", "GameTooltipTooltip", "EventTraceTooltip", "FrameStackTooltip", "GarrisonMissionMechanicTooltip", "GarrisonMissionMechanicFollowerCounterTooltip", "ItemSocketingDescription", "NamePlateTooltip", "PrivateAurasTooltip", "RuneforgeFrameResultTooltip", "ItemRefTooltip", "QuickKeybindTooltip", "SettingsTooltip"}
				for i = 1, #allTooltips do
					local tooltipName = allTooltips[i]
					local tooltip = _G[tooltipName]
					if (tooltip and tooltip:IsVisible()) then
                        if (tooltip.GetTooltipData) then
                            local tooltipData = tooltip:GetTooltipData()
                            if (tooltipData) then
                                if (tooltip.ItemTooltip and tooltip.ItemTooltip:IsVisible()) then
                                    local icon = tooltip.ItemTooltip.Icon
                                    if (icon) then
                                        local texture = icon:GetTexture()
                                        local atlas = icon:GetAtlas()
                                        if (texture or atlas) then
                                            tooltipData.IconTexture = texture
                                            tooltipData.IconAtlas = atlas
                                        end
                                    end
                                end

                                if (tooltipData.hyperlink) then
                                    local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType,
                                    itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
                                    expacID, setID, isCraftingReagent = GetItemInfo(tooltipData.hyperlink)

                                    local itemInfo = {
                                        itemName = itemName,
                                        itemLink = itemLink,
                                        itemQuality = itemQuality,
                                        itemLevel = itemLevel,
                                        itemMinLevel = itemMinLevel,
                                        itemType = itemType,
                                        itemSubType = itemSubType,
                                        itemStackCount = itemStackCount,
                                        itemEquipLoc = itemEquipLoc,
                                        itemTexture = itemTexture,
                                        sellPrice = sellPrice,
                                        classID = classID,
                                        subclassID = subclassID,
                                        bindType = bindType,
                                        expacID = expacID,
                                        setID = setID,
                                        isCraftingReagent = isCraftingReagent
                                    }
                                    DetailsFramework.table.deploy(tooltipData, itemInfo)
                                end

                                return Details:Dump(tooltipData)
                            end
                        else
                            local outputTable = {}
                            for lineNumber = 1, 10 do
                                local leftText = _G[tooltipName..'TextLeft'..lineNumber]
                                local rightText = _G[tooltipName..'TextRight'..lineNumber]
                                if not (leftText and rightText) then
                                    break
                                end

                                outputTable[#outputTable+1] = {left = leftText:GetText(), right = rightText:GetText()}
                            end

                            return Details:Dump(outputTable)
                        end
					end
				end
			end

			return Details:Dump(value)
		end

		function FindSpellByName(spellName) --[[GLOBAL]]
			if (spellName and type(spellName) == "string") then
				local GSI = GetSpellInfo
				local foundSpells = {}
				spellName = spellName:lower()
				for i = 1, 450000 do
					local thisSpellName = GSI(i)
					if (thisSpellName) then
						thisSpellName = thisSpellName:lower()
						if (spellName == thisSpellName) then
							foundSpells[#foundSpells+1] = {GSI(i)}
						end
					end
				end

				if (#foundSpells > 0) then
					dumpt(foundSpells)
				else
					Details:Msg("spell", spellName, "not found.")
				end
			end
		end

	--copies a full table
		function Details.CopyTable(orig)
			local orig_type = type(orig)
			local copy
			if orig_type == 'table' then
				copy = {}
				for orig_key, orig_value in next, orig, nil do
					--print(orig_key, orig_value)
					copy[Details.CopyTable(orig_key)] = Details.CopyTable(orig_value)
				end
			else
				copy = orig
			end
			return copy
		end

	--delay messages
		function _detalhes:DelayMsg(msg)
			_detalhes.delaymsgs = _detalhes.delaymsgs or {}
			_detalhes.delaymsgs[#_detalhes.delaymsgs+1] = msg
		end
		function _detalhes:ShowDelayMsg()
			if (_detalhes.delaymsgs and #_detalhes.delaymsgs > 0) then
				for _, msg in ipairs(_detalhes.delaymsgs) do
					print(msg)
				end
			end
			_detalhes.delaymsgs = {}
		end

	--print messages
		function _detalhes:Msg(str, arg1, arg2, arg3, arg4)
			if (self.__name) then
				print("|cffffaeae" .. self.__name .. "|r |cffcc7c7c(plugin)|r: " .. (str or ""), arg1 or "", arg2 or "", arg3 or "", arg4 or "")
			else
				print(Loc ["STRING_DETAILS1"] .. (str or ""), arg1 or "", arg2 or "", arg3 or "", arg4 or "")
			end
		end

	--welcome
		function _detalhes:WelcomeMsgLogon()
			_detalhes:Msg("you can always reset the addon running the command |cFFFFFF00'/details reinstall'|r if it does fail to load after being updated.")

			function _detalhes:wipe_combat_after_failed_load()
				_detalhes.tabela_historico = _detalhes.historico:CreateNewSegmentDatabase()
				_detalhes.tabela_overall = _detalhes.combate:NovaTabela()
				_detalhes.tabela_vigente = _detalhes.combate:NovaTabela (_, _detalhes.tabela_overall)
				Details222.PetContainer.Reset()

				_detalhes_database.tabela_overall = nil
				_detalhes_database.tabela_historico = nil

				_detalhes:Msg("seems failed to load, please type /reload to try again.")
			end

			Details.Schedules.After(5, _detalhes.wipe_combat_after_failed_load)
		end

		Details.failed_to_load = C_Timer.NewTimer(1, function() Details.Schedules.NewTimer(20, _detalhes.WelcomeMsgLogon) end)

	--key binds
	--[=
		--header
			_G ["BINDING_HEADER_Details"] = "Details!"
			_G ["BINDING_HEADER_DETAILS_KEYBIND_SEGMENTCONTROL"] = Loc ["STRING_KEYBIND_SEGMENTCONTROL"]
			_G ["BINDING_HEADER_DETAILS_KEYBIND_SCROLLING"] = Loc ["STRING_KEYBIND_SCROLLING"]
			_G ["BINDING_HEADER_DETAILS_KEYBIND_WINDOW_CONTROL"] = Loc ["STRING_KEYBIND_WINDOW_CONTROL"]
			_G ["BINDING_HEADER_DETAILS_KEYBIND_BOOKMARK"] = Loc ["STRING_KEYBIND_BOOKMARK"]
			_G ["BINDING_HEADER_DETAILS_KEYBIND_REPORT"] = Loc ["STRING_KEYBIND_WINDOW_REPORT_HEADER"]

		--keys

			_G ["BINDING_NAME_DETAILS_TOGGLE_ALL"] = Loc ["STRING_KEYBIND_TOGGLE_WINDOWS"]

			_G ["BINDING_NAME_DETAILS_RESET_SEGMENTS"] = Loc ["STRING_KEYBIND_RESET_SEGMENTS"]
			_G ["BINDING_NAME_DETAILS_SCROLL_UP"] = Loc ["STRING_KEYBIND_SCROLL_UP"]
			_G ["BINDING_NAME_DETAILS_SCROLL_DOWN"] = Loc ["STRING_KEYBIND_SCROLL_DOWN"]

			_G ["BINDING_NAME_DETAILS_REPORT_WINDOW1"] = string.format(Loc ["STRING_KEYBIND_WINDOW_REPORT"], 1)
			_G ["BINDING_NAME_DETAILS_REPORT_WINDOW2"] = string.format(Loc ["STRING_KEYBIND_WINDOW_REPORT"], 2)

			_G ["BINDING_NAME_DETAILS_TOOGGLE_WINDOW1"] = string.format(Loc ["STRING_KEYBIND_TOGGLE_WINDOW"], 1)
			_G ["BINDING_NAME_DETAILS_TOOGGLE_WINDOW2"] = string.format(Loc ["STRING_KEYBIND_TOGGLE_WINDOW"], 2)
			_G ["BINDING_NAME_DETAILS_TOOGGLE_WINDOW3"] = string.format(Loc ["STRING_KEYBIND_TOGGLE_WINDOW"], 3)
			_G ["BINDING_NAME_DETAILS_TOOGGLE_WINDOW4"] = string.format(Loc ["STRING_KEYBIND_TOGGLE_WINDOW"], 4)
			_G ["BINDING_NAME_DETAILS_TOOGGLE_WINDOW5"] = string.format(Loc ["STRING_KEYBIND_TOGGLE_WINDOW"], 5)

			_G ["BINDING_NAME_DETAILS_BOOKMARK1"] = string.format(Loc ["STRING_KEYBIND_BOOKMARK_NUMBER"], 1)
			_G ["BINDING_NAME_DETAILS_BOOKMARK2"] = string.format(Loc ["STRING_KEYBIND_BOOKMARK_NUMBER"], 2)
			_G ["BINDING_NAME_DETAILS_BOOKMARK3"] = string.format(Loc ["STRING_KEYBIND_BOOKMARK_NUMBER"], 3)
			_G ["BINDING_NAME_DETAILS_BOOKMARK4"] = string.format(Loc ["STRING_KEYBIND_BOOKMARK_NUMBER"], 4)
			_G ["BINDING_NAME_DETAILS_BOOKMARK5"] = string.format(Loc ["STRING_KEYBIND_BOOKMARK_NUMBER"], 5)
			_G ["BINDING_NAME_DETAILS_BOOKMARK6"] = string.format(Loc ["STRING_KEYBIND_BOOKMARK_NUMBER"], 6)
			_G ["BINDING_NAME_DETAILS_BOOKMARK7"] = string.format(Loc ["STRING_KEYBIND_BOOKMARK_NUMBER"], 7)
			_G ["BINDING_NAME_DETAILS_BOOKMARK8"] = string.format(Loc ["STRING_KEYBIND_BOOKMARK_NUMBER"], 8)
			_G ["BINDING_NAME_DETAILS_BOOKMARK9"] = string.format(Loc ["STRING_KEYBIND_BOOKMARK_NUMBER"], 9)
			_G ["BINDING_NAME_DETAILS_BOOKMARK10"] = string.format(Loc ["STRING_KEYBIND_BOOKMARK_NUMBER"], 10)
	--]=]
end

if (select(4, GetBuildInfo()) >= 100000) then
	local f = CreateFrame("frame")
	f:RegisterEvent("ADDON_ACTION_FORBIDDEN")
	f:SetScript("OnEvent", function()
		local text = StaticPopup1 and StaticPopup1.text and StaticPopup1.text:GetText()
		if (text and text:find("Details")) then
			--fix false-positive taints that are being attributed to random addons
			StaticPopup1.button2:Click()
		end
	end)
end

local classCacheName = Details222.ClassCache.ByName
local classCacheGUID = Details222.ClassCache.ByGUID

function Details222.ClassCache.GetClassFromCache(value)
	return classCacheName[value] or classCacheGUID[value]
end

function Details222.ClassCache.AddClassToCache(value, whichCache)
	if (whichCache == "name") then
		classCacheName[value] = true
	elseif (whichCache == "guid") then
		classCacheGUID[value] = true
	end
end

function Details222.ClassCache.GetClass(value)
	local className = Details222.ClassCache.ByName[value] or Details222.ClassCache.ByGUID[value]
	if (className) then
		return className
	end

	local _, unitClass = UnitClass(value)
	return unitClass
end

function Details222.ClassCache.MakeCache()
	--iterage among all segments in the container history, get the damage container and get the actor list, check if the actor is a player and if it is, get the class and store it in the cache
	local segmentsTable = Details:GetCombatSegments()
	for _, combatObject in ipairs(segmentsTable) do
		for _, actorObject in combatObject:GetContainer(DETAILS_ATTRIBUTE_DAMAGE):ListActors() do
			if (actorObject:IsPlayer()) then
				local actorName = actorObject.nome
				local actorClass = actorObject.classe
				local actorGUID = actorObject.serial
				Details222.ClassCache.ByName[actorName] = actorClass
				Details222.ClassCache.ByGUID[actorGUID] = actorClass
			end
		end
	end
end

Details222.UnitIdCache.Party = {"player"}
Details222.UnitIdCache.PartyPet = {"playerpet"}
for i = 1, 4 do
	table.insert(Details222.UnitIdCache.Party, "party" .. i)
	table.insert(Details222.UnitIdCache.PartyPet, "partypet" .. i)
end

Details222.UnitIdCache.Raid = {}
Details222.UnitIdCache.RaidPet = {}
Details222.UnitIdCache.RaidTargets = {}
for i = 1, 40 do
	Details222.UnitIdCache.Raid[i] = "raid" .. i
	Details222.UnitIdCache.RaidPet[i] = "raidpet" .. i
	Details222.UnitIdCache.RaidTargets[i] = "raidtarget" .. i
end

Details222.UnitIdCache.Boss = {}
for i = 1, 9 do
	Details222.UnitIdCache.Boss[i] = "boss" .. i
end

Details222.UnitIdCache.Nameplate = {}
for i = 1, 40 do
	Details222.UnitIdCache.Nameplate[i] = "nameplate" .. i
end

Details222.UnitIdCache.Arena = {}
for i = 1, 5 do
	Details222.UnitIdCache.Arena[i] = "arena" .. i
end


function Details222.Tables.MakeWeakTable(mode)
	local newTable = {}
	setmetatable(newTable, {__mode = mode or "v"})
	return newTable
end

--STRING_CUSTOM_POT_DEFAULT

---add a statistic, log, or any other data to the player stat table
---@param statName string
---@param value number
function Details222.PlayerStats:AddStat(statName, value)
	Details.player_stats[statName] = (Details.player_stats[statName] or 0) + value
end

---get the value of a saved stat
---@param statName string
---@return any
function Details222.PlayerStats:GetStat(statName)
	return Details.player_stats[statName]
end

---same thing as above but set the value instead of adding
---@param statName string
---@param value number
function Details222.PlayerStats:SetStat(statName, value)
	Details.player_stats[statName] = value
end

local profileStartFunc = function(functionName)
	local profile = Details222.ProfilingCache[functionName]

	if (not profile) then
		Details222.ProfilingCache[functionName] = {elapsed = 0, startTime = 0, runs = 0}
		profile = Details222.ProfilingCache[functionName]
	end

	profile.startTime = debugprofilestop()
	profile.runs = profile.runs + 1
end

local profileStopFunc = function(functionName)
	local profile = Details222.ProfilingCache[functionName]
	if (profile) then
		profile.elapsed = profile.elapsed + debugprofilestop() - profile.startTime
	end
end

function Details222.Profiling.ProfileStart()end
function Details222.Profiling.ProfileStop()end

function Details222.Profiling.EnableProfiler()
	Details222.Profiling.ProfileStart = profileStartFunc
	Details222.Profiling.ProfileStop = profileStopFunc
end

function Details222.Profiling.DisableProfiler()
	Details222.Profiling.ProfileStart = function()end
	Details222.Profiling.ProfileStop = function()end
end

function Details222.Profiling.ResetProfiler()
	table.wipe(Details222.ProfilingCache)
end

if (select(4, GetBuildInfo()) >= 100000) then
	Details222.Profiling.EnableProfiler()
end

function Details:ProfilerResult()
	local resultTable = {}
	local total = 0

	for functionName, profile in pairs(Details222.ProfilingCache) do
		local runTime = string.format("%.3f", profile.elapsed / 1000)
		resultTable[functionName] = runTime .. " ms | runs: " .. profile.runs
		total = total + profile.elapsed
	end

	resultTable["Total"] = string.format("%.3f", total / 1000) .. " ms"
	dumpt(resultTable)
end
function Details:ResetProfilerResult()

end

---destroy a table and remove it from the object, if the key isn't passed, the object itself is destroyed
---@param object any
---@param key string|nil
function Details:Destroy(object, key)
	if (key) then
		if (getmetatable(object[key])) then
			setmetatable(object[key], nil)
		end
		object[key].__index = nil
		table.wipe(object[key])
		object[key] = nil
	else
		if (getmetatable(object)) then
			setmetatable(object, nil)
		end
		object.__index = nil
		table.wipe(object)
	end
end

function Details:DestroyCombat(combatObject)
	--destroy each individual actor, hence more cleanups are done
	for i = 1, DETAILS_COMBAT_AMOUNT_CONTAINERS do
		local actorContainer = combatObject:GetContainer(i)
		for index, actorObject in actorContainer:ListActors() do
			Details:DestroyActor(actorObject, actorContainer, combatObject, 3)
		end
	end

	setmetatable(combatObject, nil)
	combatObject.__index = nil
	combatObject.__newindex = nil
	combatObject.__call = nil
	Details:Destroy(combatObject)
	--leave a trace that the actor has been deleted
	combatObject.__destroyed = true
	combatObject.__destroyedBy = debugstack(2, 1, 0)
end

---destroy the actor, also calls container:RemoveActor(actor)
---@param self details
---@param actorObject actor
---@param actorContainer actorcontainer
---@param combatObject combat
function Details:DestroyActor(actorObject, actorContainer, combatObject, callStackDepth)
	local containerType = actorContainer:GetType()
	local combatTotalsTable = combatObject.totals[containerType] --without group
	local combatTotalsTableInGroup = combatObject.totals_grupo[containerType] --with group

	--remove the actor from the parser cache
	local c1, c2, c3, c4 = Details222.Cache.GetParserCacheTables()
	c1[actorObject.serial] = nil
	c2[actorObject.serial] = nil
	c3[actorObject.serial] = nil
	c4[actorObject.serial] = nil

	if (not actorObject.ownerName) then --not a pet
		if (containerType == 1 or containerType == 2) then --damage|healing done
			combatTotalsTable = combatTotalsTable - actorObject.total
			if (actorObject.grupo) then
				combatTotalsTableInGroup = combatTotalsTableInGroup - actorObject.total
			end

		elseif (containerType == 3) then
			---@cast actorObject actorresource
			if (actorObject.total and actorObject.total > 0) then
				if (actorObject.powertype) then
					combatTotalsTable[actorObject.powertype] = combatTotalsTable[actorObject.powertype] - actorObject.total
					combatTotalsTableInGroup[actorObject.powertype] = combatTotalsTableInGroup[actorObject.powertype] - actorObject.total
				end
			end
			if (actorObject.alternatepower and actorObject.alternatepower > 0) then
				combatTotalsTable.alternatepower = combatTotalsTable.alternatepower - actorObject.alternatepower
				combatTotalsTableInGroup.alternatepower = combatTotalsTableInGroup.alternatepower - actorObject.alternatepower
			end

		elseif (containerType == 4) then
			---@cast actorObject actorutility
			--decrease the amount of CC break from the combat totals
			if (actorObject.cc_break and actorObject.cc_break > 0) then
				if (combatTotalsTable.cc_break) then
					combatTotalsTable.cc_break = combatTotalsTable.cc_break - actorObject.cc_break
				end
				if (combatTotalsTableInGroup.cc_break) then
					combatTotalsTableInGroup.cc_break = combatTotalsTableInGroup.cc_break - actorObject.cc_break
				end
			end

			--decrease the amount of dispell from the combat totals
			if (actorObject.dispell and actorObject.dispell > 0) then
				if (combatTotalsTable.dispell) then
					combatTotalsTable.dispell = combatTotalsTable.dispell - actorObject.dispell
				end
				if (combatTotalsTableInGroup.dispell) then
					combatTotalsTableInGroup.dispell = combatTotalsTableInGroup.dispell - actorObject.dispell
				end
			end

			--decrease the amount of interrupt from the combat totals
			if (actorObject.interrupt and actorObject.interrupt > 0) then
				if (combatTotalsTable.interrupt) then
					combatTotalsTable.interrupt = combatTotalsTable.interrupt - actorObject.interrupt
				end
				if (combatTotalsTableInGroup.interrupt) then
					combatTotalsTableInGroup.interrupt = combatTotalsTableInGroup.interrupt - actorObject.interrupt
				end
			end

			--decrease the amount of ress from the combat totals
			if (actorObject.ress and actorObject.ress > 0) then
				if (combatTotalsTable.ress) then
					combatTotalsTable.ress = combatTotalsTable.ress - actorObject.ress
				end
				if (combatTotalsTableInGroup.ress) then
					combatTotalsTableInGroup.ress = combatTotalsTableInGroup.ress - actorObject.ress
				end
			end

			--decrease the amount of dead from the combat totals
			if (actorObject.dead and actorObject.dead > 0) then
				if (combatTotalsTable.dead) then
					combatTotalsTable.dead = combatTotalsTable.dead - actorObject.dead
				end
				if (combatTotalsTableInGroup.dead) then
					combatTotalsTableInGroup.dead = combatTotalsTableInGroup.dead - actorObject.dead
				end
			end

			--decreate the amount of cooldowns used from the combat totals
			if (actorObject.cooldowns_defensive and actorObject.cooldowns_defensive > 0) then
				if (combatTotalsTable.cooldowns_defensive) then
					combatTotalsTable.cooldowns_defensive = combatTotalsTable.cooldowns_defensive - actorObject.cooldowns_defensive
				end
				if (combatTotalsTableInGroup.cooldowns_defensive) then
					combatTotalsTableInGroup.cooldowns_defensive = combatTotalsTableInGroup.cooldowns_defensive - actorObject.cooldowns_defensive
				end
			end

			--decrease the amount of buff uptime from the combat totals
			if (actorObject.buff_uptime and actorObject.buff_uptime > 0) then
				if (combatTotalsTable.buff_uptime) then
					combatTotalsTable.buff_uptime = combatTotalsTable.buff_uptime - actorObject.buff_uptime
				end
				if (combatTotalsTableInGroup.buff_uptime) then
					combatTotalsTableInGroup.buff_uptime = combatTotalsTableInGroup.buff_uptime - actorObject.buff_uptime
				end
			end

			--decrease the amount of debuff uptime from the combat totals
			if (actorObject.debuff_uptime and actorObject.debuff_uptime > 0) then
				if (combatTotalsTable.debuff_uptime) then
					combatTotalsTable.debuff_uptime = combatTotalsTable.debuff_uptime - actorObject.debuff_uptime
				end
				if (combatTotalsTableInGroup.debuff_uptime) then
					combatTotalsTableInGroup.debuff_uptime = combatTotalsTableInGroup.debuff_uptime - actorObject.debuff_uptime
				end
			end
		end
	end

	Details222.TimeMachine.RemoveActor(actorObject)

	local actorName = actorObject:Name()
	combatObject:RemoveActorFromSpellCastTable(actorName)

	setmetatable(actorObject, nil)
	actorObject.__index = nil
	actorObject.__newindex = nil
	Details:Destroy(actorObject)

	--leave a trace that the actor has been deleted
	actorObject.__destroyed = true
	actorObject.__destroyedBy = debugstack(callStackDepth or 2, 1, 0)
end

C_Timer.After(5, function()
--TutorialPointerFrame_1:HookScript("OnShow", function(self) self:Hide() end) --remove on v11 launch
end)
