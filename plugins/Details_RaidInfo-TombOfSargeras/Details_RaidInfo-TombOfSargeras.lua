
do

	local INSTANCE_EJID = 875
	local INSTANCE_MAPID = 1676
	local HDPATH = "Details_RaidInfo-TombOfSargeras"
	local LOADINGSCREEN_FILE, LOADINGSCREEN_COORDS  = "LoadScreen_TombOfSargerasRAID_wide", {0, 1, 285/1024, 875/1024}
	local EJ_LOREBG = "UI-EJ-LOREBG-TombOfSargeras"
	local PORTRAIT_LIST = {
		"UI-EJ-BOSS-Goroth", --1579934, --Goroth - Goroth
		"UI-EJ-BOSS-Inquisition", --1579936, --Atrigan - Demonic Inquisition
		"UI-EJ-BOSS-NagaBrute", --1579940, --Harjatan - Harjatan
		"UI-EJ-BOSS-HuntressKasparian", --1579935, --Huntress Kasparian - Sisters of the Moon
		"UI-EJ-BOSS-MistressSasszine", --1579939, --Mistress Sassz'ine - Mistress Sassz'ine
		"UI-EJ-BOSS-Veliskarr", --1579943, --Engine of Souls - The Desolate Host
		"UI-EJ-BOSS-FelTitan", --1579933, --Maiden of Vigilance - Maiden of Vigilance
		"UI-EJ-BOSS-FallenAvatar", --1579932, --Fallen Avatar - Fallen Avatar
		"UI-EJ-BOSS-KiljaedenLegion", --1385746, --Kil'jaeden - Kil'jaeden
	}
	local ENCOUNTER_ID_CL = {
		2032, 2048, 2036, 2050, 2037, 2054, 2052, 2038, 2051,
		[2032] = 1, --Goroth
		[2048] = 2, --Demonic Inquisition
		[2036] = 3, --Harjatan
		[2050] = 4, --Sisters of the Moon
		[2037] = 5, --Mistress Sassz'ine
		[2054] = 6, --The Desolate Host
		[2052] = 7, --Maiden of Vigilance
		[2038] = 8, --Fallen Avatar
		[2051] = 9, --Kil'jaeden
	}
	local ENCOUNTER_ID_EJ = {
		1862, 1867, 1856, 1903, 1861, 1896, 1897, 1873, 1898,
		[1862] = 1, --Goroth
		[1867] = 2, --Demonic Inquisition
		[1856] = 3, --Harjatan
		[1903] = 4, --Sisters of the Moon
		[1861] = 5, --Mistress Sassz'ine
		[1896] = 6, --The Desolate Host
		[1897] = 7, --Maiden of Vigilance
		[1873] = 8, --Fallen Avatar
		[1898] = 9, --Kil'jaeden
	}

	function Details:InstallTombOfSargerasEncounter()

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
		Details.InstallTombOfSargerasEncounter = nil
		
	end
	
	--install the encounter
	Details:ScheduleTimer ("InstallTombOfSargerasEncounter", 2)
	
end

