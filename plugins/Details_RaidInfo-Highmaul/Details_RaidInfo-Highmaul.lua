
local _detalhes = 		_G._detalhes

local highmaul = {

	id = 1228, --994 = map id extracted from encounter journal
	ej_id = 477, --encounter journal id

	name = "Highmaul",

	icons = [[Interface\AddOns\Details_RaidInfo-Highmaul\boss_faces]],
	icon = [[Interface\AddOns\Details_RaidInfo-Highmaul\icon256x128]],
	
	is_raid = true,

	backgroundFile = {file = [[Interface\Glues\LOADINGSCREENS\LoadingScreen_HighMaulRaid]], coords = {0, 1, 265/1024, 875/1024}},
	backgroundEJ = [[Interface\EncounterJournal\UI-EJ-LOREBG-Highmaul]],

	boss_names = { 
		--[[ 1 ]] "Kargath Bladefist",
		--[[ 2 ]] "The Butcher",
		--[[ 3 ]] "Tectus",
		--[[ 4 ]] "Brackenspore",
		--[[ 5 ]] "Twin Ogron",
		--[[ 6 ]] "Ko'ragh",
		--[[ 7 ]] "Imperator Mar'gok",
	},

	encounter_ids = { --encounter journal encounter id
		--> Ids by Index
		1128, 971, 1195, 1196, 1148, 1153, 1197,
		
		--> Boss Index
		[1128] = 1, 
		[971] = 2, 
		[1195] = 3, 
		[1196] = 4, 
		[1148] = 5, 
		[1153] = 6, 
		[1197] = 7,
	},
	
	encounter_ids2 = {
		--combatlog encounter id
		
	},
	
	boss_ids = {
		--npc ids
		
	},
	
	encounters = {
		
		[1] = {
			boss = "Kargath Bladefist",
			portrait = [[Interface\ENCOUNTERJOURNAL\UI-EJ-BOSS-Kargath Bladefist]],
			
			--> spell list
			continuo = {},
		},

		[2] = {
			boss = "The Butcher",
			portrait = [[Interface\ENCOUNTERJOURNAL\UI-EJ-BOSS-The Butcher]],
			
			--> spell list
			continuo = {},
		},

		[3] = {
			boss = "Tectus",
			portrait = [[Interface\ENCOUNTERJOURNAL\UI-EJ-BOSS-Tectus The Living Mountain]],
			
			--> spell list
			continuo = {},
		},
		
		[4] = {
			boss = "Brackenspore",
			portrait = [[Interface\ENCOUNTERJOURNAL\UI-EJ-BOSS-Brackenspore]],
			
			--> spell list
			continuo = {},
		},
		
		[5] = {
			boss = "Twin Ogron",
			portrait = [[Interface\ENCOUNTERJOURNAL\UI-EJ-BOSS-Twin Ogron]],
			
			--> spell list
			continuo = {},
		},
		
		[6] = {
			boss = "Ko'ragh",
			portrait = [[Interface\ENCOUNTERJOURNAL\UI-EJ-BOSS-Fel Breaker]],
			
			--> spell list
			continuo = {},
		},
		
		[7] = {
			boss = "Imperator Mar'gok",
			portrait = [[Interface\ENCOUNTERJOURNAL\UI-EJ-BOSS-Imperator Margok]],
			
			--> spell list
			continuo = {},
		},
		
	},

}

_detalhes:InstallEncounter (highmaul)