
local MoguShanPalace = {

	id = 994,
	ej_id = 321,
	
	name = "Mogu'Shan Palace",
	
	boss_names = {
		"Trial of the King",
		"Gekkan",
		"Xin the Weaponmaster",
	},
	
	boss_ids = {
	
		--debug
		--[61945] = 2,
	
		[61445] = 1, --haiayn
		[61442] = 1, --kuai
		[61453] = 1, --mushiba
		[61444] = 1, --ming
		--[61337] = 2, --ironhide
		--[61340] = 2, --hexxer
		--[61339] = 2, --oracle
		[61243] = 2, --gekkan
		--[61338] = 2, --skulker
		[61398] = 3, --xin
	},
	
	encounters = {
		[1] = {
			boss =	"Trial of the King",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Ming the Cunning]],
		},
		[2] = {
			boss =	"Gekkan",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Gekkan]],
		},
		[3] = {
			boss =	"Xin the Weaponmaster",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Xin the Weaponmaster]],
		},
	},
	
}
_detalhes:InstallEncounter (MoguShanPalace)

local TempleOfJadeSerpent = {

	id = 960,
	ej_id = 313,
	
	name = "Temple of the Jade Serpent",
	
	boss_names = {
		"Wise Mari",
		"Lorewalker Stonestep",
		"Liu Flameheart",
		"Sha of Doubt",
	},
	
	boss_ids = {
		[56448] = 1, --wise mary
		[56843] = 2, --lorewalker stonestep
		[59051] = 2, --strife
		[59726] = 2, --peril
		[56872] = 2, --osong
		[56732] = 3, --liu framehearth
		[56762] = 3, --yulon
		[56439] = 4, --sha of doubt
		[56792] = 4, --add
	},

	encounters = {
		[1] = {
			boss =	"Wise Mari",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Wise Mari]],
		},
		[2] = {
			boss =	"Lorewalker Stonestep",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Lorewalker Stonestep]],
		},
		[3] = {
			boss =	"Liu Flameheart",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Liu Flameheart]],
		},
		[4] = {
			boss =	"Sha of Doubt",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Sha of Doubt]],
		},
	},
}

_detalhes:InstallEncounter (TempleOfJadeSerpent)

local StormsStoutBrewery = {

	id = 961,
	ej_id = 302,
	
	name = "Stormstout Brewery",
	boss_names = {
		"Ook-Ook",
		"Hoptallus",
		"Yan-Zhu the Uncasked",
	},
	
	boss_ids = {
		[56637] = 1, --ook-ook
		[56717] = 2, --hoptallus
		[59479] = 3, --yan-zhu
	},

	encounters = {
		[1] = {
			boss =	"Ook-Ook",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Ook Ook]],
		},
		[2] = {
			boss =	"Hoptallus",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Hoptallus]],
		},
		[3] = {
			boss =	"Yan-Zhu the Uncasked",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Yan Zhu the Uncasked]],
		},
	},
}

_detalhes:InstallEncounter (StormsStoutBrewery)

local ScarletHalls = {

	id = 1001,
	name = "Scarlet Halls",
	boss_names = {
		"Houndmaster Braun",
		"Armsmaster Harlan",
		"Flameweaver Koegler",
	},
	
	boss_ids = {
		[0] = 1, --
		[0] = 2, --
		[0] = 3, --
	},
	
	encounters = {
		[1] = {
			boss =	"Houndmaster Braun",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Houndmaster Braun]],
		},
		[2] = {
			boss =	"Armsmaster Harlan",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Armsmaster Harlan]],
		},
		[3] = {
			boss =	"Flameweaver Koegler",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Flameweaver Koegler]],
		},
	},
}

_detalhes:InstallEncounter (ScarletHalls)

local ShadoPanMonastery = {

	id = 959,
	name = "Shado-Pan Monastery",
	boss_names = {
		"Gu Cloudstrike",
		"Master Snowdrift",
		"Sha of Violence",
		"Taran Zhu",
	},
	
	boss_ids = {
		[0] = 1, --
		[0] = 2, --
		[0] = 3, --
	},
	
	encounters = {
		[1] = {
			boss =	"Gu Cloudstrike",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Gu Cloudstrike]],
		},
		[2] = {
			boss =	"Master Snowdrift",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Master Snowdrift]],
		},
		[3] = {
			boss =	"Sha of Violence",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Sha of Violence]],
		},
		[4] = {
			boss =	"Taran Zhu",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Taran Zhu]],
		},
	},
}

_detalhes:InstallEncounter (ShadoPanMonastery)

local ScarletMonastery = {

	id = 1004,
	name = "Scarlet Monastery",
	boss_names = {
		"Thalnos the Soulrender",
		"Brother Korloff",
		"High Inquisitor Whitemane",
	},
	
	boss_ids = {
		[0] = 1, --
		[0] = 2, --
		[0] = 3, --
	},
	
	encounters = {
		[1] = {
			boss =	"Thalnos the Soulrender",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Thalnos the Soulrender]],
		},
		[2] = {
			boss =	"Brother Korloff",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Brother Korloff]],
		},
		[3] = {
			boss =	"High Inquisitor Whitemane",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-High Inquisitor Whitemane]],
		},
	},
}

_detalhes:InstallEncounter (ScarletMonastery)

local SiegeOfNiuzaoTemple = {

	id = 1011,
	name = "Siege of Niuzao Temple",
	boss_names = {
		"Vizier Jin'bak",
		"Commander Vo'jak",
		"General Pa'valak",
		"Wing Leader Ner'onok",
	},
	
	boss_ids = {
		[0] = 1, --
		[0] = 2, --
		[0] = 3, --
	},
	
	encounters = {
		[1] = {
			boss =	"Vizier Jin'bak",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Vizier Jinbak]],
		},
		[2] = {
			boss =	"Commander Vo'jak",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Commander Vojak]],
		},
		[3] = {
			boss =	"General Pa'valak",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-General Pavalak]],
		},
		[4] = {
			boss =	"Wing Leader Ner'onok",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Wing Leader Neronok]],
		},
	},
}

_detalhes:InstallEncounter (SiegeOfNiuzaoTemple)

local GateOfSettingSun = {

	id = 962,
	name = "Gate of the Setting Sun",
	boss_names = {
		"Saboteur Kip'tilak",
		"Striker Ga'dok",
		"Commander Ri'mok",
		"Raigonn",
	},
	
	boss_ids = {
		[0] = 1, --
		[0] = 2, --
		[0] = 3, --
	},
	
	encounters = {
		[1] = {
			boss =	"Saboteur Kip'tilak",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Saboteur Kiptilak]],
		},
		[2] = {
			boss =	"Striker Ga'dok",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Striker Gadok]],
		},
		[3] = {
			boss =	"Commander Ri'mok",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Commander Rimok]],
		},
		[4] = {
			boss =	"Raigonn",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Raigonn]],
		},
	},
}

_detalhes:InstallEncounter (GateOfSettingSun)

local Scholomance = {

	id = 1007,
	name = "Scholomance",
	boss_names = {
		"Instructor Chillheart",
		"Jandice Barov",
		"Rattlegore",
		"Lilian Voss",
		"Darkmaster Gandling",
	},
	
	boss_ids = {
		[0] = 1, --
		[0] = 2, --
		[0] = 3, --
	},
	
	encounters = {
		[1] = {
			boss =	"Instructor Chillheart",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Instructor Chillheart]],
		},
		[2] = {
			boss =	"Jandice Barov",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Jandice Barov]],
		},
		[3] = {
			boss =	"Rattlegore",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Rattlegore]],
		},		
		[4] = {
			boss =	"Lilian Voss",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Lillian Voss]],
		},
		[5] = {
			boss =	"Darkmaster Gandling",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Darkmaster Gandling]],
		},
	},
}

_detalhes:InstallEncounter (Scholomance)
