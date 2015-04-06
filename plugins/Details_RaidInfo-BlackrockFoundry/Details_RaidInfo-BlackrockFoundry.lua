
local _detalhes = 		_G._detalhes

local blackrock_foundry = {

	id = 1205, --994 = map id extracted from encounter journal
	ej_id = 477, --encounter journal id

	name = "Blackrock Foundry",

	icons = [[Interface\AddOns\Details_RaidInfo-BlackrockFoundry\boss_faces]],
	icon = [[Interface\AddOns\Details_RaidInfo-BlackrockFoundry\icon256x128]],
	
	is_raid = true,

	backgroundFile = {file = [[Interface\Glues\LOADINGSCREENS\LoadingScreen_BlackrockFoundry]], coords = {0, 1, 132/512, 439/512}},
	backgroundEJ = [[Interface\EncounterJournal\UI-EJ-LOREBG-BlackrockFoundry]],

	boss_names = { 
		--[[ 1 ]] "Gruul",
		--[[ 2 ]] "Oregorger",
		--[[ 3 ]] "Beastlord Darmac",
		--[[ 4 ]] "Flamebender Ka'graz",
		--[[ 5 ]] "Hans'gar and Franzok",
		--[[ 6 ]] "Operator Thogar",
		--[[ 7 ]] "The Blast Furnace",
		--[[ 8 ]] "Kromog",
		--[[ 9 ]] "The Iron Maidens",
		--[[ 10 ]] "Blackhand",
	},

	encounter_ids = { --encounter journal encounter id
		--> Ids by Index
		1161, 1202, 1122, 1123, 1155, 1147, 1154, 1162, 1203, 959,
		
		--> Boss Index
		[1161] = 1, 
		[1202] = 2, 
		[1122] = 3, 
		[1123] = 4, 
		[1155] = 5, 
		[1147] = 6, 
		[1154] = 7,
		[1162] = 8,
		[1203] = 9,
		[959] = 10,
	},
	
	encounter_ids2 = {
		--combatlog encounter id
		[1691] = 1, --Gruul
		[1696] = 2, --Oregorger
		[1694] = 3, --Beastlord Darmac
		[1689] = 4, --Flamebender Ka'graz
		[1693] = 5, --Hans'gar & Franzok
		[1692] = 6, --Operator Thogar
		[1690] = 7, --The Blast Furnace
		[1713] = 8, --Kromog, Legend of the Mountain
		[1695] = 9, --The Iron Maidens
		[1704] = 10, --Blackhand
	},
	
	boss_ids = {
		--npc ids
		[76877] = 1, --Gruul
		[77182] = 2, --Oregorger
		[76865] = 3, --Beastlord Darmac
		[76814] = 4, --Flamebender Ka'graz
		[76974] = 5, --Franzok
		[76973] = 5, --Hans'gar
		[76906] = 6, --Operator Thogar
		[76806] = 7, --Heart of the Mountain
		[77692] = 8, --Kromog, Legend of the Mountain
		[77557] = 9, -- Admiral Gar'an
		[77231] = 9, --Enforcer Sorka
		[77477] = 9, --Marak the Blooded
		[77325] = 10, --Blackhand
	},

	encounters = {
		
		[1] = {
			boss = "Gruul",
			portrait = [[Interface\ENCOUNTERJOURNAL\UI-EJ-BOSS-Gruul]],
			
			--> spell list
			continuo = {
				155080,
				155301,
				155530,
				162322,
				165983,
				173190,
				173192,
			},
		},

		[2] = {
			boss = "Oregorger",
			portrait = [[Interface\ENCOUNTERJOURNAL\UI-EJ-BOSS-Oregorger]],
			
			--> spell list
			continuo = {
				155897,
				155900,
				156203,
				156297,
				156324,
				156374,
				156388,
				156879,
				165983,
				173471,
			},
		},

		[3] = {
			boss = "Beastlord Darmac",
			portrait = [[Interface\ENCOUNTERJOURNAL\UI-EJ-BOSS-Beastlord Darmac]],
			
			--> spell list
			continuo = {
				154956,
				154960,
				154981,
				154989,
				155030,
				155061,
				155198,
				155222,
				155247,
				155499,
				155531,
				155611,
				155657,
				155718,
				156823,
				156824,
				162275,
				162283,
			},
		},
		
		[4] = {
			boss = "Flamebender Ka'graz",
			portrait = [[Interface\ENCOUNTERJOURNAL\UI-EJ-BOSS-Flamebender Kagraz]],

			--> spell list
			continuo = {
				154938,
				155049,
				155074,
				155314,
				155318,
				155484,
				155511,
				156018,
				156040,
				156713,
				163284,
				163633,
				163822,
			},
		},
		
		[5] = {
			boss = "Hans'gar and Franzok",
			portrait = [[Interface\ENCOUNTERJOURNAL\UI-EJ-BOSS-Franzok]],
			
			--> spell list
			continuo = {
				153470,
				155818,
				156938,
				157853,
				158140,
				161570,
			},
		},
		
		[6] = {
			boss = "Operator Thogar",
			portrait = [[Interface\ENCOUNTERJOURNAL\UI-EJ-BOSS-Operator Thogar]],
			
			--> spell list
			continuo = {
				163754,
				156554,
				155921,
				158084,
				163752,
				155701,
				160050,
				156270,
				156655,
			},
		},
		
		[7] = {
			boss = "The Blast Furnace",
			portrait = [[Interface\ENCOUNTERJOURNAL\UI-EJ-BOSS-The Blast Furnace]],
			
			--> spell list
			continuo = {
				155187,
				155201,
				155209,
				155223,
				155242,
				155743,
				156932,
				156937,
				158246,
				159408,
			},
		},
		
		[8] = {
			boss = "Kromog",
			portrait = [[Interface\ENCOUNTERJOURNAL\UI-EJ-BOSS-Kromog]],
			
			--> spell list
			continuo = {
				156704,
				156844,
				157055,
				157059,
				157247,
				157659,
				161893,
				161923,
				162349,
				162392,
			},
		},

		[9] = {
			boss = "The Iron Maidens",
			portrait = [[Interface\ENCOUNTERJOURNAL\UI-EJ-BOSS-Iron Maidens]],
			
			--> spell list
			continuo = {
				155841,
				156637,
				156669,
				157884,
				158078,
				158080,
				158683,
				159335,
				160436,
				160733,
			},
		},
		
		[10] = {
			boss = "Blackhand",
			portrait = [[Interface\ENCOUNTERJOURNAL\UI-EJ-BOSS-Warlord Blackhand]],
			
			--> spell list
			continuo = {
				155992,
				156044,
				156107,
				156401,
				156479,
				156497,
				156731,
				156743,
			},
		},
		
	},

}

_detalhes:InstallEncounter (blackrock_foundry)