

--> install data for raiding tiers

do
	--> data for Uldir (BFA tier 1)
	
--	UldirRaid_BossFaces.tga
--	UldirRaid_Icon256x128.tga
	
	local INSTANCE_EJID = 1031
	local INSTANCE_MAPID = 1861
	local HDIMAGESPATH = "Details\\images\\raid"
	local HDFILEPREFIX = "UldirRaid"
	local LOADINGSCREEN_FILE, LOADINGSCREEN_COORDS  = "Loadingscreen_NazmirRaid", {0, 1, 285/1024, 875/1024}
	local EJ_LOREBG = "UI-EJ-LOREBG-Uldir"
	
	local PORTRAIT_LIST = {
		2176749, --Taloc - Taloc
		2176741, --MOTHER - MOTHER
		2176725, --Fetid Devourer - Fetid Devourer
		2176761, --Zek'voz - Zek'voz, Herald of N'zoth
		2176757, --Vectis - Vectis
		2176762, --Zul - Zul, Reborn
		2176742, --Mythrax the Unraveler - Mythrax the Unraveler
		2176728, --G'huun - G'huun
	}
	
	local ENCOUNTER_ID_CL = {
		2144, 2141, 2128, 2136, 2134, 2145, 2135, 2122,
		[2144] = 1, --Taloc - Taloc
		[2141] = 2, --MOTHER - MOTHER
		[2128] = 3, --Fetid Devourer - Fetid Devourer
		[2136] = 4, --Zek'voz - Zek'voz, Herald of N'zoth
		[2134] = 5, --Vectis - Vectis
		[2145] = 6, --Zul - Zul, Reborn
		[2135] = 7, --Mythrax the Unraveler - Mythrax the Unraveler
		[2122] = 8, --G'huun - G'huun
	}
	
	local ENCOUNTER_ID_EJ = {
		2168, 2167, 2146, 2169, 2166, 2195, 2194, 2147,
		[2168] = 1, --Taloc
		[2167] = 2, --MOTHER
		[2146] = 3, --Fetid Devourer
		[2169] = 4, --Zek'voz, Herald of N'zoth
		[2166] = 5, --Vectis
		[2195] = 6, --Zul, Reborn
		[2194] = 7, --Mythrax the Unraveler
		[2147] = 8, --G'huun
	}
	
	--> install the raid
	C_Timer.After (10, function()

		--load encounter journal
		EJ_SelectInstance (INSTANCE_EJID)

		local InstanceName = EJ_GetInstanceInfo (INSTANCE_EJID)

		--build the boss name list
		local BOSSNAMES = {}
		local ENCOUNTERS = {}
		
		for i = 1, #PORTRAIT_LIST do
			local bossName = EJ_GetEncounterInfoByIndex (i, INSTANCE_EJID)
			if (bossName) then
				tinsert (BOSSNAMES, bossName)
				local encounterTable = {
					boss = bossName,
					--portrait = "Interface\\EncounterJournal\\" .. PORTRAIT_LIST [i],
					portrait = PORTRAIT_LIST [i],
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
			icons = "Interface\\AddOns\\" .. HDIMAGESPATH .. "\\" .. HDFILEPREFIX .. "_BossFaces",
			icon = "Interface\\AddOns\\" .. HDIMAGESPATH .. "\\" .. HDFILEPREFIX .. "_Icon256x128",
			is_raid = true,
			backgroundFile = {file = "Interface\\Glues\\LOADINGSCREENS\\" .. LOADINGSCREEN_FILE, coords = LOADINGSCREEN_COORDS},
			backgroundEJ = "Interface\\EncounterJournal\\" .. EJ_LOREBG,
			
			encounter_ids = ENCOUNTER_ID_EJ,
			encounter_ids2 = ENCOUNTER_ID_CL,
			boss_names = BOSSNAMES,
			encounters = ENCOUNTERS,
			
			boss_ids = { 
				--npc ids
			},
		})
	end)

end


do
	--> data for Antorus, the Burning Throne raid
	
--	AntorusRaid_BossFaces
--	AntorusRaid_Icon256x128
	
	local INSTANCE_EJID = 946
	local INSTANCE_MAPID = 1712
	local HDIMAGESPATH = "Details\\images\\raid"
	local HDFILEPREFIX = "AntorusRaid"
	local LOADINGSCREEN_FILE, LOADINGSCREEN_COORDS  = "LoadingScreen_ArgusRaid_Widescreen", {0, 1, 285/1024, 875/1024}
	local EJ_LOREBG = "UI-EJ-LOREBG-Antorus"
	
	local PORTRAIT_LIST = {
		1715210, --Garothi Worldbreaker - Garothi Worldbreaker
		1715209, --F'harg - Felhounds of Sargeras
		1715225, --Admiral Svirax - Antoran High Command
		1715219, --Portal Keeper Hasabel - Portal Keeper Hasabel
		1715208, --Essence of Eonar - Eonar the Life-Binder
		1715211, --Imonar the Soulhunter - Imonar the Soulhunter
		1715213, --Kin'garoth - Kin'garoth
		1715223, --Varimathras - Varimathras
		1715222, --Noura, Mother of Flames - The Coven of Shivarra
		1715207, --Aggramar - Aggramar
		1715536, --Argus the Unmaker - Argus the Unmaker
	}
	
	local ENCOUNTER_ID_CL = {
		2076, 2074, 2070, 2075, 2064, 2082, 2088, 2069, 2073, 2063, 2092, 
		[2076]  = 1, --Garothi Worldbreaker
		[2074]  = 2, --Felhounds of Sargeras
		[2070]  = 3, --Antoran High Command
		[2075]  = 4, --Eonar
		[2064]  = 5, --Portal Keeper Hasabel
		[2082]  = 6, --Imonar the Soulhunter
		[2088]  = 7, --Kin'garoth
		[2069]  = 8, --Varimathras
		[2073]  = 9, --The Coven of Shivarra
		[2063]  = 10, --Aggramar
		[2092]  = 11, --Argus the Unmaker
	}
	
	local ENCOUNTER_ID_EJ = {
		1992, 1987, 1997, 1985, 2025, 2009, 2004, 1983, 1986, 1984, 2031,
		[1992] = 1, --Garothi Worldbreaker
		[1987] = 2, --Felhounds of Sargeras
		[1997] = 3, --Antoran High Command
		[1985] = 4, --Portal Keeper Hasabel
		[2025] = 5, --Eonar the Life-Binder
		[2009] = 6, --Imonar the Soulhunter
		[2004] = 7, --Kin'garoth
		[1983] = 8, --Varimathras
		[1986] = 9, --The Coven of Shivarra
		[1984] = 10, --Aggramar
		[2031] = 11, --Argus the Unmaker
	}
	
	--> install the raid
	function Details:ScheduleInstallRaidDataForAntorus()

		--load encounter journal
		EJ_SelectInstance (INSTANCE_EJID)

		local InstanceName = EJ_GetInstanceInfo (INSTANCE_EJID)

		--build the boss name list
		local BOSSNAMES = {}
		local ENCOUNTERS = {}
		
		for i = 1, #PORTRAIT_LIST do
			local bossName = EJ_GetEncounterInfoByIndex (i, INSTANCE_EJID)
			if (bossName) then
				tinsert (BOSSNAMES, bossName)
				local encounterTable = {
					boss = bossName,
					--portrait = "Interface\\EncounterJournal\\" .. PORTRAIT_LIST [i],
					portrait = PORTRAIT_LIST [i],
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
			icons = "Interface\\AddOns\\" .. HDIMAGESPATH .. "\\" .. HDFILEPREFIX .. "_BossFaces",
			icon = "Interface\\AddOns\\" .. HDIMAGESPATH .. "\\" .. HDFILEPREFIX .. "_Icon256x128",
			is_raid = true,
			backgroundFile = {file = "Interface\\Glues\\LOADINGSCREENS\\" .. LOADINGSCREEN_FILE, coords = LOADINGSCREEN_COORDS},
			backgroundEJ = "Interface\\EncounterJournal\\" .. EJ_LOREBG,
			
			encounter_ids = ENCOUNTER_ID_EJ,
			encounter_ids2 = ENCOUNTER_ID_CL,
			boss_names = BOSSNAMES,
			encounters = ENCOUNTERS,
			
			boss_ids = { 
				--npc ids
			},
		})
		
	end
	
	Details:ScheduleTimer ("ScheduleInstallRaidDataForAntorus", 2)
	
end