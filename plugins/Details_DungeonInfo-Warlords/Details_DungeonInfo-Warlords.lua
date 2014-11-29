--Auchindoun
--Bloodmaul Slag Mines
--The Everbloom
--GrimrailDepot
--IronDocks
--ShadowmoonBurialGrounds
--Skyreach
--UpperBlackrockSpire

local Auchindoun = {
	id = 1182, --mapid
	ej_id = 547, --encounter journal id
	
	name = "Auchindoun",
	
	boss_names = {
		"Vigilant Kaathar",
		"Soulbinder Nyami",
		"Azzakel",
		"Teron'gor",
	},
	
	boss_ids = {
		[86217] = 1, --Vigilant Kaathar
		[75839] = 1, --Vigilant Kaathar
		[86218] = 2, --Soulbinder Nyami
		[76177] = 2, --Soulbinder Nyami
		[86219] = 3, --Azzakel
		[75927] = 3, --Azzakel
		[86220] = 4, --Teron'gor
		[77734] = 4, --Teron'gor
	},

	encounters = {
		[1] = {
			boss =	"Vigilant Kaathar",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Auchindoun Defense Construct]],
		},
		[2] = {
			boss =	"Soulbinder Nyami",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Soulbinder Nyami]],
		},
		[3] = {
			boss =	"Azzakel",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Azzakel Vanguard Of The Legion]],
		},
		[4] = {
			boss =	"Teron'gor",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Terongor]],
		},
	},
}

_detalhes:InstallEncounter (Auchindoun)


local BloodmaulSlagMines = {
	id = 1175, --mapid
	ej_id = 385, --encounter journal id
	
	name = "Bloodmaul Slag Mines",
	
	boss_names = {
		"Slave Watcher Crushto",
		"Forgemaster Gog'duh",
		"Roltall",
		"Gug'rokk",
	},
	
	boss_ids = {
		[86222] = 1, --Slave Watcher Crushto
		[74787] = 1, --Slave Watcher Crushto
		[74366] = 2, --Forgemaster Gog'duh
		[86223] = 3, --Roltall
		[75786] = 3, --Roltall
		[86224] = 4, --Gug'rokk
		[74790] = 4, --Gug'rokk
	},
	
	encounters = {
		[1] = {
			boss =	"Slave Watcher Crushto",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Slave Watcher Crushto]],
		},
		[2] = {
			boss =	"Forgemaster Gog'duh",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Magmolatus]],
		},
		[3] = {
			boss =	"Roltall",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Roltall]],
		},
		[4] = {
			boss =	"Gug'rokk",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Gugrokk]],
		},
	},

}

_detalhes:InstallEncounter (BloodmaulSlagMines)

local TheEverbloom = {
	id = 1279, --mapid
	ej_id = 556, --encounter journal id
	
	name = "The Everbloom",
	
	boss_names = {
		"Witherbark",
		"Ancient Protectors",
		"Xeri'tac",
		"Archmage Sol",
		"Yalnu",
	},
	
	boss_ids = {
		[81522] = 1, --Witherbark
		[86242] = 1, --Witherbark
		[83894] = 2, --Ancient Protectors
		[83893] = 2, --Ancient Protectors
		[83892] = 2, --Ancient Protectors
		[86244] = 2, --Ancient Protectors
		[86247] = 3, --Xeri'tac
		[86246] = 4, --Archmage Sol
		[82682] = 4, --Archmage Sol
		[86248] = 5, --Yalnu
		[84336] = 5, --Yalnu
		[83846] = 5, --Yalnu
	},

	encounters = {
		[1] = {
			boss =	"Witherbark",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Witherbark]],
		},
		[2] = {
			boss =	"Ancient Protectors",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Dulhu]],
		},
		[3] = {
			boss =	"Xeri'tac",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Xeritac]],
		},
		[4] = {
			boss =	"Archmage Sol",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Archmage Sol]],
		},
		[5] = {
			boss =	"Yalnu",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Yalnu]],
		},
	},
}

_detalhes:InstallEncounter (TheEverbloom)

local GrimrailDepot = {
	id = 1208, --mapid
	ej_id = 536, --encounter journal id
	
	name = "Grimrail Depot",
	
	boss_names = {
		"Rocketspark and Borka",
		"Nitrogg Thundertower",
		"Skylord Tovra",
	},
	
	boss_ids = {
		[86225] = 1, --Rocketspark and Borka
		[86226] = 1, --Rocketspark and Borka
		[79548] = 1, --Rocketspark and Borka
		[77816] = 1, --Rocketspark and Borka
		[86227] = 2, --Nitrogg Thundertower
		[79545] = 2, --Nitrogg Thundertower
		[86228] = 3, --Skylord Tovra
		[80005] = 3, --Skylord Tovra
	},

	encounters = {
		[1] = {
			boss =	"Rocketspark and Borka",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Pauli Rocketspark]],
		},
		[2] = {
			boss =	"Nitrogg Thundertower",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Blackrock Assault Commander]],
		},
		[3] = {
			boss =	"Skylord Tovra",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Thunderlord General]],
		},
	},
}

_detalhes:InstallEncounter (GrimrailDepot)

local IronDocks = {
	id = 1195, --mapid
	ej_id = 558, --encounter journal id
	
	name = "Iron Docks",
	
	boss_names = {
		"Fleshrender Nok'gar",
		"Ahri'ok Dugru",
		"Oshir",
		"Skulloc",
	},

	boss_ids = {
		[81297] = 1, --Dreadfang
		[81305] = 1, --Fleshrender Nok'gar	
		[87451] = 1, --Fleshrender Nok'gar
		[87452] = 2, --Ahri'ok Dugru
		[86231] = 2, --Makogg Emberblade
		[80808] = 2, --Neesa Nox
		[86232] = 3, --Oshir
		[79852] = 3, --Oshir
		[86233] = 4, --Skulloc
		[83612] = 4, --Skulloc
		[83616] = 4, --Skulloc
	},

	encounters = {
		[1] = {
			boss =	"Fleshrender Nok'gar",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Warsong Battlemaster]],
		},
		[2] = {
			boss =	"Ahri'ok Dugru",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Blood Shaman]],
		},
		[3] = {
			boss =	"Oshir",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Oshir]],
		},
		[4] = {
			boss =	"Skulloc",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Skulloc]],
		},
	},
}

_detalhes:InstallEncounter (IronDocks)

local ShadowmoonBurialGrounds = {
	id = 1176, --mapid
	ej_id = 537, --encounter journal id
	
	name = "Shadowmoon Burial Grounds",
	
	boss_names = {
		"Sadana Bloodfury",
		"Bonemaw",
		"Ner'zhul",
		"Nhallish",
	},
	
	boss_ids = {
		[86234] = 1, --Sadana Bloodfury
		[75509] = 1, --Sadana Bloodfury
		[86236] = 2, --Bonemaw
		[75452] = 2, --Bonemaw
		[76268] = 3, --Ner'zhul
		[76407] = 3, --Ner'zhul
		[75829] = 4, --Nhallish
	},
	
	encounters = {
		[1] = {
			boss =	"Sadana Bloodfury",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Sadana Bloodfury]],
		},
		[2] = {
			boss =	"Bonemaw",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Bonemaw]],
		},
		[3] = {
			boss =	"Ner'zhul",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Nerzhul]],
		},
		[4] = {
			boss =	"Nhallish",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Nhallish Feaster of Souls]],
		},
	},
}

_detalhes:InstallEncounter (ShadowmoonBurialGrounds)

local Skyreach = {
	id = 1209, --mapid
	ej_id = 476, --encounter journal id
	
	name = "Skyreach",
	
	boss_names = {
		"Ranjit",
		"Araknath",
		"Rukhran",
		"High Sage Viryx",
	},
	
	boss_ids = {
		[86238] = 1, --Ranjit
		[75964] = 1, --Ranjit
		[86239] = 2, --Araknath
		[76141] = 2, --Araknath
		[76379] = 3, --Rukhran
		[76143] = 3, --Rukhran
		[86241] = 4, --High Sage Viryx
		[76266] = 4, --High Sage Viryx
	},
	
	encounters = {
		[1] = {
			boss =	"Ranjit",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Ranjit]],
		},
		[2] = {
			boss =	"Araknath",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Araknath]],
		},
		[3] = {
			boss =	"Rukhran",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Rukhran]],
		}, 
		[4] = {
			boss =	"High Sage Viryx",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-High Sage Viryx]],
		},
	},
}

_detalhes:InstallEncounter (Skyreach)

local UpperBlackrockSpire = {
	id = 1358, --mapid
	ej_id = 559, --encounter journal id
	
	name = "Upper Blackrock Spire",
	
	boss_names = {
		"Orebender Gor'ashan",
		"Kyrak",
		"Commander Tharbek",
		"Ragewing the Untamed",
		"Warlord Zaela",
		"The Lanticore",
	},
	
	boss_ids = {
		[86249] = 1, --Orebender Gor'ashan
		[76413] = 1, --Orebender Gor'ashan
		[86250] = 2, --Kyrak
		[76021] = 2, --Kyrak
		[86251] = 3, --Commander Tharbek
		[79912] = 3, --Commander Tharbek
		[76585] = 4, --Ragewing the Untamed
		[77120] = 5, --Warlord Zaela
		[77081] = 6, --The Lanticore
	},

	encounters = {
		[1] = {
			boss =	"Orebender Gor'ashan",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Orebender Gorashan]],
		},
		[2] = {
			boss =	"Kyrak",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Kyrak]],
		},
		[3] = {
			boss =	"Commander Tharbek",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Ironmarch Commander Tharbek]],
		},
		[4] = {
			boss =	"Ragewing the Untamed",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Ragewing the Untamed]],
		},		
		[5] = {
			boss =	"Warlord Zaela",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Warlord Zaela]],
		},
		[6] = {
			boss =	"The Lanticore",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Warlord Zaela]],
		},
	},
}

_detalhes:InstallEncounter (UpperBlackrockSpire)