
local _detalhes = 		_G._detalhes

local trash_mobs_ids = {
	
}

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
		[1721] = 1, --kargath
		[1706] = 2, --the butcher
		[1722] = 3, --tectus
		[1720] = 4, --brakenspore
		[1719] = 5, --twin ogron
		[1723] = 6, --Koragh
		[1705] = 7, --Margok
	},
	
	boss_ids = {
		--npc ids
		[78714] = 1, --Kargath
		[77404] = 2, --The Butcher
		[78948] = 3, --Tectus
		[78491] = 4, --Brakenspore
		[78238] = 5, --Pol
		[78237] = 5, --Phemos
		[79015] = 6, --Koragh
		[77428] = 7, --Margok
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
			
			funcType = 0x2,
			func = function (combat) 
				local removed = false
				local list = combat:GetActorList (DETAILS_ATTRIBUTE_DAMAGE)
				for i = #list, 1, -1 do
					local id = _detalhes:GetNpcIdFromGuid (list[i].serial)
					if (trash_mobs_ids [id]) then
						tremove (list, i)
						combat.totals [DETAILS_ATTRIBUTE_DAMAGE] = combat.totals [DETAILS_ATTRIBUTE_DAMAGE] - list[i].total
						removed = true
					end
				end
				if (removed) then
					combat[DETAILS_ATTRIBUTE_DAMAGE]:Remap()
				end
			end,
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