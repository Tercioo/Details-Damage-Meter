
do

	local INSTANCE_EJID = 786
	local INSTANCE_MAPID = 1530--?
	local HDPATH = "Details_RaidInfo-Nighthold"
	local LOADINGSCREEN_FILE, LOADINGSCREEN_COORDS  = "LoadScreen_SuramarRaid", {0, 1, 282/1024, 872/1024}
	local EJ_LOREBG = "UI-EJ-LOREBG-TheNighthold"
	local PORTRAIT_LIST = {
		"UI-EJ-BOSS-Skorpyron",
		"UI-EJ-BOSS-Chronomatic Anomaly",
		"UI-EJ-BOSS-Trilliax",
		"UI-EJ-BOSS-Spellblade Aluriel",
		"UI-EJ-BOSS-Tichondrius",
		"UI-EJ-BOSS-Krosus",
		"UI-EJ-BOSS-Botanist",
		"UI-EJ-BOSS-Star Augur Etraeus",
		"UI-EJ-BOSS-Grand Magistrix Elisande",
		"UI-EJ-BOSS-Guldan",
	}
	local ENCOUNTER_ID_CL = {
		[1849] = 1, --Skorpyron
		[1865] = 2, --Chronomatic Anomaly
		[1867] = 3, --Trilliax
		[1871] = 4, --Spellblade Aluriel
		[1862] = 5, --Tichondrius
		[1842] = 6, --Krosus 
		[1886] = 7, --High Botanist Tel'arn
		[1863] = 8, --Star Augur Etraeus
		[1872] = 9, --Grand Magistrix Elisande 
		[1866] = 10, --Gul'dan
	}
	local ENCOUNTER_ID_EJ = {
		1706, 1725, 1731, 1751, 1762, 1713, 1761, 1732, 1743, 1737,
		[1706] = 1, --Skorpyron
		[1725] = 2, --Chronomatic Anomaly
		[1731] = 3, --Trilliax
		[1751] = 4, --Spellblade Aluriel
		[1762] = 5, --Tichondrius
		[1713] = 6, --Krosus
		[1761] = 7, --High Botanist Tel'arn
		[1732] = 8, --Star Augur Etraeus
		[1743] = 9, --Grand Magistrix Elisande
		[1737] = 10, --Gul'dan
	}

	function Details:InstallNightholdEncounter()

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
		Details.InstallNightholdEncounter = nil
		
	end
	
	--install the encounter
	Details:ScheduleTimer ("InstallNightholdEncounter", 2)
	
end

