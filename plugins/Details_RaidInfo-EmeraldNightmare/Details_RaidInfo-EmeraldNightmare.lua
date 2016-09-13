
do

	local INSTANCE_EJID = 768
	local INSTANCE_MAPID = 1520
	local HDPATH = "Details_RaidInfo-EmeraldNightmare"
	local LOADINGSCREEN_FILE, LOADINGSCREEN_COORDS  = "LoadScreen_EmeraldNightmareRaid_wide", {0, 1, 228/1024, 874/1024}
	local EJ_LOREBG = "UI-EJ-LOREBG-TheEmeraldNightmare"
	local PORTRAIT_LIST = {
		"UI-EJ-BOSS-Nythendra",
		"UI-EJ-BOSS-Elerethe Renferal",
		"UI-EJ-BOSS-Ilgynoth Heart of Corruption",
		"UI-EJ-BOSS-Ursoc",
		"UI-EJ-BOSS-Dragons of Nightmare",
		"UI-EJ-BOSS-Cenarius",
		"UI-EJ-BOSS-Xavius",
	}
	local ENCOUNTER_ID_CL = {
		[1853] = 1, --Nythendra
		[1876] = 2, --Elerethe Renferal
		[1873] = 3, --Il'gynoth, Heart of Corruption
		[1841] = 4, --Ursoc
		[1854] = 5, --Dragons of Nightmare
		[1877] = 6, --Cenarius
		[1864] = 7, --Xavius
	}
	local ENCOUNTER_ID_EJ = {
		1703, 1744, 1738, 1667, 1704, 1750, 1726,
		[1703] = 1, --Nythendra
		[1744] = 2, --Elerethe Renferal
		[1738] = 3, --Il'gynoth, Heart of Corruption
		[1667] = 4, --Ursoc
		[1704] = 5, --Dragons of Nightmare
		[1750] = 6, --Cenarius
		[1726] = 7, --Xavius
	}
	
	function Details:InstallEmeraldNightmareEncounter()

		--load encounter journal
		EJ_SelectInstance (INSTANCE_EJID)

		local InstanceName = EJ_GetInstanceInfo (INSTANCE_EJID)

		--build the boss names list
		local BOSSNAMES = {}
		local ENCOUNTERS = {}
		
		for i = 1, #PORTRAIT_LIST do
			local bossName = EJ_GetEncounterInfoByIndex (i, INSTANCE_EJID)
			if (bossName) then
				tinsert (BOSSNAMES, bossName)
				local encounterTable = {
					boss = bossName,
					portrait = "Interface\\EncounterJournal\\" .. PORTRAIT_LIST [i],
				}
				tinsert (ENCOUNTERS, encounterTable)
			else
				break
			end
		end

		_detalhes:InstallEncounter ({
			
			id = INSTANCE_MAPID, --map id
			ej_id = INSTANCE_EJID, --encounter journal id
			name = InstanceName,
			icons = "Interface\\AddOns\\" .. HDPATH .. "\\boss_faces",
			icon = "Interface\\AddOns\\" .. HDPATH .. "\\icon256x128",
			is_raid = true,
			backgroundFile = {file = "Interface\\Glues\\LOADINGSCREENS\\" .. LOADINGSCREEN_FILE, coords = LOADINGSCREEN_COORDS},
			backgroundEJ = "Interface\\EncounterJournal\\" .. EJ_LOREBG,
			
			encounter_ids = ENCOUNTER_ID_EJ,
			encounter_ids2 = ENCOUNTER_ID_CL,
			boss_names = BOSSNAMES,
			encounters = ENCOUNTERS,
			
			boss_ids = { --npc ids
				
			},
		})
		
		--remove the install from the memory
		Details.InstallEmeraldNightmareEncounter = nil
		
	end
	
	--install the encounter
	Details:ScheduleTimer ("InstallEmeraldNightmareEncounter", 2)
	
end

