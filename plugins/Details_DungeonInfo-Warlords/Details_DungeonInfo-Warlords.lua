--Auchindoun
--Bloodmail Slag Mines
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
		[86218] = 2, --Soulbinder Nyami
		[86219] = 3, --Azzakel
		[86220] = 4, --Teron'gor
	},

	encounters = {
		[1] = {
			boss =	"Vigilant Kaathar",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Auchindoun Defense Construct]],
		},
		[2] = {
			boss =	"Soulbinder Nyami",
			portrait = [[Interface\EncounterJournal\journal/UI-EJ-BOSS-Soulbinder Nyami]],
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


local BloodmailSlagMines = {
	id = 0, --mapid
	ej_id = 385, --encounter journal id
	
	name = "Bloodmail Slag Mines",
	
	boss_names = {
		"Slave Watcher Crushto",
		"Forgemaster Gog'duh",
		"Roltall",
		"Gug'rokk",
	},
	
	boss_ids = {
		[86222] = 1, --Slave Watcher Crushto
		[74366] = 2, --Forgemaster Gog'duh
		[86223] = 3, --Roltall
		[86224] = 4, --Gug'rokk
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

_detalhes:InstallEncounter (BloodmailSlagMines)

local TheEverbloom = {
	id = 0, --mapid
	ej_id = 556, --encounter journal id
	
	name = "The Everbloom",
	
	boss_names = {
		"Ancient Protectors",
		"Archmage Sol",
		"Xeri'tac",
		"Witherbark",
		"Yalnu",
	},
	
	boss_ids = {
		[83894] = 1, --Ancient Protectors
		[86246] = 2, --Archmage Sol
		[86247] = 3, --Xeri'tac
		[86242] = 4, --Witherbark
		[86248] = 5, --Yalnu
	},

	encounters = {
		[1] = {
			boss =	"Ancient Protectors",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Dulhu]],
		},
		[2] = {
			boss =	"Archmage Sol",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Archmage Sol]],
		},
		[3] = {
			boss =	"Xeri'tac",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Xeritac]],
		},
		[4] = {
			boss =	"Witherbark",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Witherbark]],
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
		"Skylord Tovra",
		"Rocketspark and Borka",
		"Nitrogg Thundertower",
	},
	
	boss_ids = {
		[86228] = 1, --Skylord Tovra
		[86225] = 2, --Rocketspark and Borka
		[86227] = 3, --Nitrogg Thundertower
	},
	
	encounters = {
		[1] = {
			boss =	"Skylord Tovra",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Thunderlord General]],
		},
		[2] = {
			boss =	"Rocketspark and Borka",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Pauli Rocketspark]],
		},
		[3] = {
			boss =	"Nitrogg Thundertower",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Blackrock Assault Commander]],
		},
	},
}

_detalhes:InstallEncounter (GrimrailDepot)

local IronDocks = {
	id = 0, --mapid
	ej_id = 558, --encounter journal id
	
	name = "Iron Docks",
	
	boss_names = {
		"Fleshrender Nok'gar",
		"Ahri'ok Dugru",
		"Oshir",
		"Skulloc",
	},
	
	boss_ids = {
		[87451] = 1, --Fleshrender Nok'gar
		[87452] = 2, --Ahri'ok Dugru
		[86232] = 3, --Oshir
		[86233] = 4, --Skulloc
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
	id = 0, --mapid
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
		[86236] = 2, --Bonemaw
		[76268] = 3, --Ner'zhul
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
		[86239] = 2, --Araknath
		[76379] = 3, --Rukhran
		[86241] = 4, --High Sage Viryx
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
		[86250] = 2, --Kyrak
		[86251] = 3, --Commander Tharbek
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