
do

	local INSTANCE_EJID = 861
	local INSTANCE_MAPID = 1648
	local HDPATH = "Details_RaidInfo-TrialOfValor"
	local LOADINGSCREEN_FILE, LOADINGSCREEN_COORDS  = "LoadingScreen_TrialsofValor", {0, 1, 228/1024, 874/1024}
	local EJ_LOREBG = "UI-EJ-LOREBG-TrialofValor"
	local PORTRAIT_LIST = {
		"UI-EJ-BOSS-Odyn",
		"UI-EJ-BOSS-Guarm",
		"UI-EJ-BOSS-Helya"
	}
	local ENCOUNTER_ID_CL = {
		[1958] = 1, --Odyn
		[1962] = 2, --Guarm
		[2008] = 3, --Helya
	}
	local ENCOUNTER_ID_EJ = {
		1819, 1830, 1829,
		[1819] = 1, --Odyn	
		[1830] = 2, --Guarm
		[1829] = 3, --Helya
	}
	
	function Details:InstallTrialOfValorRaidInfo()

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
		Details.InstallTrialOfValorRaidInfo = nil
		
	end
	
	--install the encounter
	Details:ScheduleTimer ("InstallTrialOfValorRaidInfo", 2)
	
end

