--[[
=====================================================================================================
	Throne of Thunder Mobs and Spells Ids for Details
=====================================================================================================
]]--

local Loc = LibStub ("AceLocale-3.0"):GetLocale ("Details_RaidInfo-ThroneOfThunder")

local _detalhes = 		_G._detalhes

local throne_of_thunder = {

	id = 1098,
	ej_id = 362,
	
	name = Loc ["STRING_RAID_NAME"],
	
	icons = "Interface\\AddOns\\Details_RaidInfo-ThroneOfThunder\\images\\tot",
	
	icon = "Interface\\AddOns\\Details_RaidInfo-ThroneOfThunder\\images\\icon256x128",
	
	is_raid = true,
	
	backgroundFile = {file = [[Interface\Glues\LOADINGSCREENS\LoadscreenThunderkingRaid]], coords = {0, 1, 256/1024, 840/1024}},
	backgroundEJ = [[Interface\EncounterJournal\UI-EJ-LOREBG-ThunderKingRaid]],
	
	boss_names = { 
		"Jin'rokh the Breaker",
		"Horridon",
		"Frost King Malakk",
		"Tortos",
		"Magaera",
		"Ji-Kun",
		"Durumu the Forgotten",
		"Primordius",
		"Dark Animus",
		"Iron Qon",
		"Lu'lin",
		"Lei Shen",
		"Ra-den"
	},
	
	encounter_ids = {
		--> Ids by Index
			827, 819, 816, 825, 821, 828, 818, 820, 824, 817, 829, 832,
			[827] = 1, -- Jin'rokh the Breaker
			[819] = 2, -- Horridon
			[816] = 3, -- Frost King Malakk
			[825] = 4, -- Tortos
			[821] = 5, -- Magaera
			[828] = 6, -- Ji-Kun
			[818] = 7, -- Durumu the Forgotten
			[820] = 8, -- Primordius
			[824] = 9, -- Dark Animus
			[817] = 10, -- Iron Qon
			[829] = 11, -- Lu'lin
			[832] = 12, -- Lei Shen
			--[] = 13, -- Ra-den
	},
	
	boss_ids = {
		-- Last Stand of the Zandalari
		[69465]	= 1,	-- Jin'rokh the Breaker
		[68476]	= 2,	-- Horridon
		[69134]	= 3,	-- Kazra'jin, Council of Elders
		[69078]	= 3,	-- Sul the Sandcrawler, Council of Elders
		[69131]	= 3,	-- Frost King Malakk, Council of Elders
		[69132]	= 3,	-- High Priestess Mar'li, Council of Elders
		-- Forgotten Depths
		[67977]	= 4,	-- Tortos
		[70229]	= 5,	-- Flaming Head <Head of Megaera>
		[70250]	= 5,	-- Frozen Head <Head of Megaera>
		[70251]	= 5,	-- Venomous Head <Head of Megaera>
		[70247]	= 5,	-- Venomous Head <Head of Megaera>
		[69712]	= 6,	-- Ji-Kun
		-- Halls of Flesh-Shaping
		[68036]	= 7,	-- Durumu the Forgotten
		[69017]	= 8,	-- Primordius
		[69427]	= 9,	-- Dark Animus
		-- Pinnacle of Storms
		[68078]	= 10, -- Iron Qon <Master of Quilen>
		[68905]	= 11, -- Lu'lin <Mistress of Solitude>, Twin Consorts
		[68904]	= 11, -- Suen <Mistress of Anger>, Twin Consorts
		[68397]	= 12	-- Lei Shen <The Thunder King>
	},
	
	encounters = {
	
------------> Jin'rokh the Breaker ------------------------------------------------------------------------------
		[1] = {
			
			boss =	"Jin'rokh the Breaker",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Jinrokh the Breaker]],
			
			combat_end = {1, 69465},

			--[
			spell_mechanics =	{
						[137261] = {0x1, 0x40}, --> Lightning Storm
						[137162] = {0x1, 0x100}, --> Static Burst 
						[138389] = {0x100},  --> Static Wound
						[137423] = {0x80}, --> Focused Lightning
						[137374] = {0x40}, --> Focused Lightning Detonation
						[138133] = {0x40}, --> Lightning Fissure Conduction
						[137485] = {0x40}, --> Lightning Fissure
						[137370] = {0x200, 0x1}, --> Thundering Throw
						[137167] = {0x200, 0x1}, --> Thundering Throw
						[137905] = {0x40}, --> Lightning Diffusion
						[138733] = {0x10, 0x40}, --> Ionization
						[137647] = {0x40}, --> Lightning Strike
					},
			--]]
			phases = {
				--> fase 1
				{
					spells = {
							137261, --> Lightning Storm
							137162, --> Static Burst
							138389, --> Static Wound
							137423, --> Focused Lightning
							137374, --> Focused Lightning Detonation
							138133, --> Lightning Fissure Conduction
							137370, --> Thundering Throw
							137167 --> Thundering Throw
						},
						
					adds = {
						69465, -- Jin'rokh the Breaker
					}
				}
			}
		},
------------> Horridon ------------------------------------------------------------------------------
		[2] = {
		
			boss =	"Horridon",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Horridon]],

			combat_end = {1, 68476},
			equalize = true,
			
			spell_mechanics =	{
						[136719] = {0x10}, --> Blazing Sunlight (Wastewalker)
						[136723] = {0x8},  --> Sand Trap (Voidzone)
						[136725] = {0x8},  --> Sand Trap Heroic (Voidzone)
						[136654] = {0x1}, --> Rending Charge (Bloodlord)
						[136653] = {0x1}, --> Rending Charge (Bloodlord)
						[136587] = {0x20, 0x10, 0x1}, -->  Venom Bolt Volley (Venom Priest & Venomous Effusions)
						[136646] = {0x8},  -->  Living Poison (Voidzone)
						[136710] = {0x400, 0x10}, --> Deadly Plague (Drakkari Champions & Drakkari Warriors)
						[136670] = {0x800, 0x1}, --> Mortal Strike (Frozen Warlords)
						[136573] = {0x8}, --> Frozen Bolt (Voidzone)	
						[136465] = {0x1, 0x20}, --> Fireball (Amani'shi Flame Casters)
						[136480] = {0x20, 0x40, 0x1}, --> Chain Lightning (Amani'shi Beast Shaman)
						[136513] = {0x10, 0x1}, --> Hex of Confusion (Amani'shi Beast Shaman)
						[136489] = {0x8}, --> Lightning Nova (Voidzone)
						[136490] = {0x8}, --> Lightning Nova (Voidzone)
						[136817] = {0x200, 0x2, 0x1}, --> Bestial Cry (dpsrun)
						[136740] = {0x40}, --> Double Swipe (frontal)
						[136739] = {0x40}, --> Double Swipe (trazeiro)
						[137458] = {0x1}, --> Dire Call (heroic)
						[136767] = {0x1, 0x100}, --> Triple Puncture
						[136463] = {0x40} --> Swipe (Amani Warbear)
					},
		
			continuo = {
				136767, --> Triple Puncture 10m normal (Horridon)
				136740, -- Double Swipe (frontal)
				136739, -- Double Swipe (trazeiro)
				137458 --> Dire Call (heroic)
			},
		
			phases = {
				{
					--> fase 1 - The Farraki
					spells = {
							136719, --> Blazing Sunlight 10m normal (Wastewalker)
							136723,  --> Sand Trap 10m normal (Voidzone)
							136725  --> Sand Trap 10m heroic (Voidzone)
						},
					adds = 	{
							69175, --> Farraki Wastewalker
							69172, --> Sul'lithuz Stonegazers
							69173 --> Farraki Skirmishers
						}
				},
				{
					--> fase 2 - The Gurubashi
					spells = {
							136654, --> Rending Charge 10m normal (Bloodlord)
							136587, -->  Venom Bolt Volley 10m normal (Venom Priest & Venomous Effusions)
							136646  -->  Living Poison 10m normal (Voidzone)
						},
					adds =	{
							69167, -- Gurubashi Bloodlord
							69164, -- Gurubashi Venom Priest
							69314, -- Venomous Effusion
							68476 -- Horridon
						}
				},
				{
					--> fase 3 - The Drakkari
					spells = {
							136710, --> Deadly Plague (Drakkari Champions & Drakkari Warriors)
							136670, --> Mortal Strike (Frozen Warlords)
							139573 --> Frozen Bolt (Voidzone)
					},
					adds = 	{
							69178,-- "Drakkari Frozen Warlord",
							69184,-- "Risen Drakkari Warriors",
							69185, --"Risen Drakkari Champions"
							68476 -- Horridon
					}
				},
				{
					--> fase 4 - The Amani
					spells = 	{
							136465, --> Fireball (Amani'shi Flame Casters)
							136480, --> Chain Lightning (Amani'shi Beast Shaman)
							136513, --> Hex of Confusion (Amani'shi Beast Shaman)
							136489, --> Lightning Nova (Voidzone)
							136463 --> Swipe (Warbears)
					},
					adds =	{
							69169, -- "Amani'shi Protector",
							69168, -- "Amani'shi Flame Caster",
							69177, -- "Amani Warbear",
							69176, -- "Amani'shi Beast Shaman"
							68476 -- Horridon
					}
				},
				{
					--> fase 5 - War-God Jalak's
					spells = 	{
							136817 --> Bestial Cry
					},
					adds =		{
							69374, --"War-God Jalak"
							68476 -- Horridon
					}
				}
				
			} --> fim das fasses do segundo boss
	
		}, --> fim do segundo boss
		
------------> Concil of Elders ------------------------------------------------------------------------------
		[3] = {
			boss =	"Council of Elders",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Council of Elders]],
			
			combat_end = {2, {69131, 69134, 69078, 69132}},
			
			--> this is a fix for twisted fate spell, due Mar'li adds comes with exactly the same name as the player name, the add spell are assigned to the player
			func = function() 
				local combat = _detalhes:GetCombat ("current")
				local actorList = combat:GetActorList (DETAILS_ATTRIBUTE_DAMAGE)
				
				for _, actor in ipairs (actorList) do 
					local TwistedFate = actor.spell_tables:GetSpell (137972) --> twisted fate adds spell
					if (TwistedFate) then
						if (not actor.lastTwistedFate) then
							actor.lastTwistedFate = 0
						end
						actor.total = actor.total - (TwistedFate.total - actor.lastTwistedFate)
						actor.lastTwistedFate = TwistedFate.total
					end
				end
			end,
			
			funcType = 0x3, -- 0x1 + 0x2 --> realtime + end of combat
			
			spell_mechanics =	{
						[136507] = {0x2}, --> Dark Power (Todos)
					
						[136190] = {0x20, 0x1}, --> Sandbold (Sul the Sandcrawler)
						[138740] = {0x20, 0x1}, --> Sandbolt (Sul the Sandcrawler)
						[136899] = {0x1}, --> Sandstorm (Sul the Sandcrawler)
						[136860] = {0x10, 0x8}, --> Quicksand (Sul the Sandcrawler)
						
						[137344] = {0x20, 0x1}, --> Wrath of the Loa (High Priestess Mar'li)
						[137347] = {0x20, 0x1}, --> Wrath of the Loa (High Priestess Mar'li)
						[137390] = {0x80, 0x1000}, --> Shadowed Gift (High Priestess Mar'li)
						[137407] = {0x80, 0x1000}, --> Shadowed Gift (High Priestess Mar'li)
						[137972] = {0x200, 0x40}, -->  Twisted Fate (High Priestess Mar'li)
						
						[136937] = {0x40, 0x1}, --> Frostbite (Frost King Malakk)
						[136990] = {0x40, 0x1}, --> Frostbite (Frost King Malakk)
						[136911] = {0x1}, --> Frigid Assault (Frost King Malakk)
						[136991] = {0x40}, --> Biting Cold (Frost King Malakk)
						[136917] = {0x40}, --> Biting Cold (Frost King Malakk)

						[137151] = {0x1}, --> Overload (Kazra'jin)
						[136935] = {0x1}, --> Discharge (Kazra'jin)
						[137122] = {0x8}, -->  Reckless Charge (Kazra'jin)
						[137133] = {0x8}, -->  Reckless Charge (Kazra'jin)
						
						[137641] = {0x200, 0x1} --> Soul Fragment
					},
			
			continuo = {
				136507, --> Dark Power (Todos)
				137641, --> Soul Fragment

				136190, --> Sandbold (Sul the Sandcrawler)
				138740, --> Sandbolt (Sul the Sandcrawler)
				136899, --> Sandstorm (Sul the Sandcrawler)
				136860, --> Quicksand (Sul the Sandcrawler)
				
				137344, -->  Wrath of the Loa (High Priestess Mar'li)
				137390, --> Shadowed Gift (High Priestess Mar'li)
				137407, --> Shadowed Gift (High Priestess Mar'li)
				137347, --> Wrath of the Loa (High Priestess Mar'li)
				137972, -->  Twisted Fate (High Priestess Mar'li)
				
				136937, --> Frostbite (Frost King Malakk)
				136990, --> Frostbite (Frost King Malakk)
				136911, --> Frigid Assault (Frost King Malakk)
				136991, --> Biting Cold (Frost King Malakk)
				136917, --> Biting Cold (Frost King Malakk)

				137151, --> Overload (Kazra'jin)
				137122, -->  Reckless Charge (Kazra'jin)
				137133, -->  Reckless Charge (Kazra'jin)
				136935 --> Discharge (Kazra'jin)
			},
			
			phases = {
				{
					adds = 	{
							69548, -- "Shadowed Loa Spirit"
							69491, -- "Blessed Loa Spirit"
							69480, -- "Living Sand"
							69131, -- Frost King Malakk
							69134, -- Kazra'jin
							69078, -- Sul the Sandcrawler
							69132 -- High Priestess Mar'li

						}
				}
			}

		},
		
------------> Tortos ------------------------------------------------------------------------------	
		[4] = {
			boss =	"Tortos",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Tortos]],
			
			combat_end = {1, 67977},
			
			spell_mechanics = {
				[134476] = {0x1}, --> "Rockfall",
				[134920] = {0x1}, --> "Quake Stomp",
				[134011] = {0x1, 0x40}, --> "Spinning Shell",
				[135251] = {0x1}, --> "Snapping Bite",
				[134539] = {0x8, 0x40}, --> "Rockfall",
				[135101] = {0x4, 0x200, 0x800} --> "Drain the Weak",

			},
			
			continuo = {
				134476, --> "Rockfall",
				134920, --> "Quake Stomp",
				134011, --> "Spinning Shell",
				135251, --> "Snapping Bite",
				134539, --> "Rockfall",
				135101 --> "Drain the Weak",
			},
			
			phases = { 
				{
					adds = {
							67966, --"Whirl Turtle", 
							68497, -- "Vampiric Cave Bat"
							67977 -- Tortos
						} 
				}
			}
		},
		
------------> Megaera ------------------------------------------------------------------------------
		[5] = {
			boss =	"Megaera",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Megaera]],
			
			spell_mechanics = {
				[139549] = {0x1}, --Rampage blue
				[139548] = {0x1}, --rampage red
				[139551] = {0x1}, --rampage green
				[139552] = {0x1}, --rampage arcane
				
				[139842] = {0x100}, --Arctic Freeze
				[137731] = {0x100}, --Ignite Flesh
				[137730] = {0x100}, --Ignite Flesh
				[139839] = {0x100}, --Rot Armor
				
				[139850] = {0x80, 0x40}, -- Acid Rain
				[139836] = {0x10}, --Cinders
				[139822] = {0x10}, --Cinders
				[139836] = {0x8},--Cinders voidzone
				[139909] = {0x8}, -- Icy Ground
				[139889] = {0x80}, -- Torrent of Ice
				[139992] = {0x100}, -- Diffusion
				[140178] = {0x20} --Nether Spike
			},
			
			continuo = {
				139549, --Rampage blue
				139548, --rampage red
				139551, --rampage green
				139552, --rampage arcane
				
				139842, --Arctic Freeze
				137731, --Ignite Flesh
				137730, --Ignite Flesh
				139839, --Rot Armor
				
				139850, -- Acid Rain
				139822, --Cinders
				139836,--Cinders voidzone
				139909, -- Icy Ground
				139889, -- Torrent of Ice
				140178, --Nether Spike
				139992 --Diffusion
			},
			
			phases = {
				{
					adds = 	{
						70235, --"Frozen Head",
						70247, --"Venomous Head",
						70212, --"Flaming Head"
						70248, --"Arcane Head"
						70507 -- Nether Wyrm (heroic)
					}
				}
			}
		},
		
------------> Ji-Kun ------------------------------------------------------------------------------
		[6] = {
			boss =	"Ji'kun",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Ji Kun]],
			
			combat_end = {1, 69712},
			
			spell_mechanics = {
				[134381] = {0x1}, --Quills
				[140092] = {0x100}, -- Infected Talons
				[134366] = {0x100}, -- Talon Rake
				[139100] = {0x100}, -- Talon Strike
				[134256] = {0x200, 0x1, 0x8}, -- Slimed
				[134375] = {0x1, 0x40}, -- Caw
				[138319] = {0x200, 0x1}, -- Feed Pool
				[140129] = {0x1}, -- Cheep
				[139296] = {0x1}, -- Cheep
				[140570] = {0x1}, -- Cheep
				[139298] = {0x1} -- Cheep
			},
			
			continuo = {
				134381, --Quills
				140092, -- Infected Talons
				134256, -- Slimed
				134366, -- Talon Rake
				139100, -- Talon Strike
				134375, -- Caw
				138319, -- Feed Pool
				140129, -- Cheep
				139296, -- Cheep
				140570, -- Cheep
				139298 -- Cheep
			},
			
			phases = {
				{
					adds = 	{
						68192, --Hatchling
						69628, --Mature Egg of Ji-Kun
						68192, --Fledgling
						69836, --Juvenile
						70134 --Nest Guardian
					}
				}
			}
		},

------------> Durumu the forgotten ------------------------------------------------------------------------------
		[7] = {
			boss =	"Durumu the Forgotten",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Durumu]],
			
			combat_end = {1, 68036},
			
			spell_mechanics =	{
				[133732] = {0x1, 0x200}, --> Infrared Light
				[133738] = {0x1, 0x200}, --> Bright Light
				[133677] = {0x1, 0x200}, --> Blue Rays
				[139107] = {0x1}, --> Mind Daggers
				[133597] = {0x10, 0x200}, --> Dark Parasite
				[134755] = {0x40}, --> Eye Sore
				[133765] = {0x100}, --> Hard Stare
				[133768] = {0x1, 0x100}, --> Arterial Cut
				[133793] = {0x8}, --> Lingering Gaze
				[134044] = {0x8}, --> Lingering Gaze
				[140495] = {0x8}, --> Lingering Gaze
				[133798] = {0x200}, --> Life Drain
				[134005] = {0x1}, --> Devour
				[134010] = {0x1}, --> Devour
				[136154] = {0x1}, --> Caustic Spike
				[136123] = {0x200}, --> Burst of Amber
				[136175] = {0x1}, --> Amber Retaliation
				[134029] = {0x40}, --> Gaze
				[136413] = {0x40}, --> Force of Will
				[134169] = {0x80} --> Disintegration Beam
			},

			continuo = {},
			
			phases = {
			{
				spells = 	{
					139107, --> Mind Daggers
					133732, -->  Infrared Light
					133738, -->  Bright Light
					133597, -->  Dark Parasite
					133677, -->  Blue Rays
					133765, -->  Hard Stare
					133793, -->  Lingering Gaze
					133798, -->  Life Drain
					134044, -->  Lingering Gaze
					134005, -->  Devour
					136154, -->  Caustic Spike
					134010, -->  Devour
					140495, -->  Lingering Gaze
					133768, -->  Arterial Cut
					136123, --> Burst of Amber
					136175, --> Amber Retaliation
					134029, --> Gaze
					136413 --> Force of Will
				},
				adds = 	{
					68036, --> Durumu the Forgotten
					69050, --> Crimson Fogs
					69052, --> Azure Fog
					69051, --> Amber Fog
					67859, --> Hungry Eye
					68024, --> Wandering Eye
					68291 --> Ice Wall
				}
			},
			{
				spells = 	{
					139107, --> Mind Daggers
					133597, -->  Dark Parasite
					134755, -->  Eye Sore
					133793, -->  Lingering Gaze
					134044, -->  Lingering Gaze
					134005, -->  Devour
					134010, -->  Devour
					140495, -->  Lingering Gaze
					134169 --> Disintegration Beam
				},
				adds = 	{
					68036, --> Durumu the Forgotten
					67859, --> Hungry Eye
					68024, --> Wandering Eye
					68291 --> Ice Wall
				}
			}

		}
		},
		
------------> Primordius ------------------------------------------------------------------------------
		[8] = {
			boss =	"Primordius",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Primordius]],
			
			combat_end = {1, 69017},
			
			spell_mechanics =	{
				[136220] = {0x1, 0x2000}, --> Acidic Explosion
				[136216] = {0x1, 0x40}, --> Caustic Gas
				[136178] = {0x1}, --> Mutation
				[136211] = {0x1}, --> Ventral Sacs
				[137000] = {0x100, 0x1}, --> Black Blood
				[136247] = {0x40}, --> Pustule Eruption
				[136050] = {0x100, 0x1}, --> Malformed Blood
				[136231] = {0x1}, --> Volatile Pathogen
				[136037] = {0x800, 0x1}, --> Primordial Strike
				[140508] = {0x1} --> Volatile Mutation
			},
			continuo = {
				136220, --> Acidic Explosion
				136216, --> Caustic Gas
				136178, --> Mutation
				136211, --> Ventral Sacs
				137000, --> Black Blood
				136247, --> Pustule Eruption
				136050, --> Malformed Blood
				136231, --> Volatile Pathogen
				136037, --> Primordial Strike
				140508 --> Volatile Mutation
			},
			phases = {
			{
				spells = 	{},
				adds = 	{
					69069, --> living-fluid
					69017, --> Primordius
					69070 --> Viscous Horror
				}
			}
		}
		},
		
------------> Dark Animus ------------------------------------------------------------------------------

		[9] = {
			boss =	"Dark Animus",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Dark Animus]],
			
			combat_end = {1, 69427},
			
			spell_mechanics =	{
				[139867] = {0x1, 0x4000}, --> Interrupting Jolt
				[138659] = {0x1}, --> Touch of the Animus
				[138707] = {0x2000, 0x1}, --> Anima Font
				[138618] = {0x200, 0x10}, --> Matter Swap
				[138569] = {0x40, 0x100}, --> Explosive Slam
				[136962] = {0x100}, --> Anima Ring
				[138480] = {0x8, 0x80} --> Crimson Wake
			},
			continuo = {
				139867, --> Interrupting Jolt
				138659, --> Touch of the Animus
				138707, --> Anima Font
				138618, --> Matter Swap
				138569, --> Explosive Slam
				136962, --> Anima Ring
				138480 --> Crimson Wake
			},
			phases = {
			{
				spells = 	{
				},
				adds = 	{
					69427, --> Dark Animus
					69701, --> Anima Golem
					69699, --> Massive Anima Golem
					69700 --> Large Anima Golem
				}
			}
		}
		},

------------> Iron Qon ------------------------------------------------------------------------------		
		[10] = {
			boss =	"Iron Qon",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Iron Qon]],
			
			combat_end = {1, 68078},
			
			spell_mechanics =	{
				[136925] = {0x40}, --> Burning Blast
				[134628] = {0x200, 0x1}, --> Unleashed Flame
				[134664] = {0x200}, --> Molten Inferno
				
				[136193] = {0x2000}, --> Arcing Lightning
				[137669] = {0x8}, --> Storm Cloud
				[136577] = {0x80}, --> Wind Storm
				[139167] = {0x40}, --> Whirling Winds
				[136192] = {0x200}, --> Lightning Storm
				[136498] = {0x1}, --> Storm Surge
				[137654] = {0x80}, --> Rushing Winds
				
				[137709] = {0x1}, --> Shatter
				[135146] = {0x1}, --> Shatter
				[137664] = {0x8}, --> Frozen Blood
				[136520] = {0x8}, --> Frozen Blood
				[135142] = {0x1}, --> Frozen Resilience	
				[139180] = {0x40}, --> Frost Spike
				[134759] = {0x8}, --> Ground Rupture
				
				[136147] = {0x2, 0x1}, --> Fist Smash
				[134691] = {0x100}, --> Impale
				[134926] = {0x40} --> Throw Spear
			},
			
			continuo = {
				134691 --> Impale
			},
			
			phases = {
			--> phase 1 Ro'shak
			{
				spells = 	{
					136925, --> Burning Blast
					134664, --> Molten Inferno
					134628, --> Unleashed Flame
					139167, --> Whirling Winds
					136192, --> Lightning Storm
					139167, --> Whirling Winds
					136498 --> Storm Surge
				},
				adds = 	{
					68079 --> Ro'shak
				}
			},
			
			--> phase 2 Quet'zal
			{
				spells = 	{
					136193, --> Arcing Lightning
					137669, --> Storm Cloud
					136577, --> Wind Storm
					139167, --> Whirling Winds
					136192, --> Lightning Storm
					136498, --> Storm Surge
					137654, --> Rushing Winds
					139180 --> Frost Spike
				},
				adds = 	{
					68080 --> Quet'zal
				}
			},
			
			--> phase 3 Dam'ren
			{
				spells = 	{
					137709, --> Shatter
					135146, --> Shatter
					137664, --> Frozen Blood
					136520, --> Frozen Blood
					135142, --> Frozen Resilience	
					139180, --> Frost Spike
					134759, --> Ground Rupture
					134664, --> Molten Inferno
					134628 --> Unleashed Flame
				},
				adds = 	{
					68081 --> Dam'ren
				}
			},
			
			--> phase 4 Iron Qon
			{
				spells = 	{
					139167, --> Whirling Winds
					136147, --> Fist Smash
					134691, --> Impale
					134664, --> Molten Inferno
					134628, --> Unleashed Flame
					139180, --> Frost Spike
					139167, --> Whirling Winds
					136498 --> Storm Surge
				},
				adds = 	{
					68078 --> Iron Qon
				}
			}
		}
		},

------------> Twin Consorts ------------------------------------------------------------------------------
		[11] = {
			boss =	"Twin Consorts",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Empyreal Queens]],
			
			combat_end = {2, {68904, 68905}},
			equalize = true,
			
			spell_mechanics =	{
				[137410] = {0x200, 0x1}, --> Blazing Radiance
				[137492] = {0x1}, --> Nuclear Inferno
				[137382] = {0x1}, --> Darkness
				[138682] = {0x1}, --> Darkness
				[137129] = {0x1, 0x2000}, --> Crashing Star
				[137405] = {0x1}, --> Tears of the Sun
				[138746] = {0x1}, --> Tears of the Sun
				[137494] = {0x1, 0x2000}, --> Light of Day
				[137403] = {0x1, 0x2000}, --> Light of Day
				[138804] = {0x1, 0x2000}, --> Light of Day
				[137360] = {0x200}, --> Corrupted Healing
				[137408] = {0x100}, --> Fan of Flames
				[136722] = {0x40}, --> Slumber Spores
				[137417] = {0x8}, --> Flames of Passion
				[137414] = {0x8}, --> Flames of Passion
				[138688] = {0x1}, --> Tidal Force
				[137716] = {0x1}, --> Tidal Force
				[137419] = {0x1, 0x2000} --> Ice Comet
			},
			
			continuo = {
			},
			
			phases = {
			--> phase 1 (night)
			{
				spells = 	{
					137382, --> Darkness
					138682, --> Darkness
					137405, --> Tears of the Sun
					138746, --> Tears of the Sun
					137494, --> Light of Day
					137403, --> Light of Day
					138804, --> Light of Day
					137360, --> Corrupted Healing
					136722, --> Slumber Spores
					137129 --> Crashing Star
					
				},
				adds = 	{
					69591, -- Lurker in the Night
					69479, -- Beast of Nightmares
					68905, --> Lu'lin
					68904 --> Suen
				}
			},
			--> phase 2 (day)
			{
				spells = 	{
					137492, --> Nuclear Inferno
					137410, --> Blazing Radiance
					137408, --> Fan of Flames
					137417, --> Flames of Passion
					137419, --> Ice Comet
					137129 --> Crashing Star
				},
				adds = 	{
					68904 --> Suen
				}
			},
			--> phase 3 (dusk)
			{
				spells = 	{
					137492, --> Nuclear Inferno
					137410, --> Blazing Radiance
					138688, --> Tidal Force
					137419, --> Ice Comet
					137494, --> Light of Day
					137403, --> Light of Day
					138804, --> Light of Day
					137410 --> Blazing Radiance
				},
				adds = 	{
					68905, --> Lu'lin
					68904 --> Suen
				}
			},
			--> phase 4
			{
				spells = 	{
					137492, --> Nuclear Inferno
					137410, --> Blazing Radiance
					137382, --> Darkness
					138682, --> Darkness
					137360, --> Corrupted Healing
					137408, --> Fan of Flames
					136722, --> Slumber Spores
					137417, --> Flames of Passion
					137129 --> Crashing Star
				},
				adds = 	{
					69591, --Lurker in the Night
					69479, --Beast of Nightmares
					68905, --> Lu'lin
					68904 --> Suen
				}
			}
		}
		},

------------> Lei Shen ------------------------------------------------------------------------------
		[12] = {
			boss =	"Lei Shen",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Lei Shen]],
			
			combat_end = {1, 68397},
			
			spell_mechanics =	{
				[136889] = {0x2, 0x1}, --> Violent Gale Winds 
				[135096] = {0x40}, --> Thunderstruck 
				[135703] = {0x200}, --> Static Shock 
				[134821] = {0x200}, --> Discharged Energy 
				[136366] = {0x1}, --> Bouncing Bolt 
				[136620] = {0x1}, --> Ball Lightning 
				[136543] = {0x1}, --> Summon Ball Lightning 
				[136021] = {0x40}, --> Chain Lightning 
				[135150] = {0x8}, --> Crashing Thunder 
				[135153] = {0x8}, --> Crashing Thunder 
				[136914] = {0x1}, --> Electrical Shock 
				[136019] = {0x40}, --> Chain Lightning 
				[136018] = {0x40}, --> Chain Lightning 
				[139011] = {0x1}, --> Helm of Command 
				[134916] = {0x80, 0x100}, --> Decapitate 
				[136326] = {0x40}, --> Overcharge 
				[136478] = {0x100}, --> Fusion Slash 
				[135991] = {0x40}, --> Diffusion Chain 
				[136853] = {0x8}, --> Lightning Bolt 
				[137176] = {0x8}, --> Overloaded Circuits 
				[136850] = {0x8, 0x40} --> Lightning Whip 
			},
			continuo = {
				135703, --> Static Shock 
				136366, --> Bouncing Bolt 
				136021, --> Chain Lightning 
				136019, --> Chain Lightning 
				136018, --> Chain Lightning 
				136326, --> Overcharge 
				135991 --> Diffusion Chain 
			},
			phases = {
			
			--> phase 1
			{
				spells = 	{
					135096, --> Thunderstruck 
					134821, --> Discharged Energy 
					135150, --> Crashing Thunder 
					135153, --> Crashing Thunder 
					134916 --> Decapitate 
				},
				adds = 	{
					69013, --> Diffused Lightning
					69133, --> Unharnessed Power
					68397 --> Lei Shen
				}
			},
			
			--> phase 2
			{
				spells = 	{
				
				},
				adds = 	{
					69013, --> Diffused Lightning
					69133 --> Unharnessed Power
				}
			},
			
			--> phase 3
			{
				spells = 	{
					134821, --> Discharged Energy 
					136620, --> Ball Lightning 
					136543, --> Summon Ball Lightning 
					139011, --> Helm of Command 
					136478, --> Fusion Slash 
					136853, --> Lightning Bolt 
					137176, --> Overloaded Circuits 
					136850 --> Lightning Whip 
				},
				adds = 	{
					69013, --> Diffused Lightning
					69133, --> Unharnessed Power
					69232, --> Ball Lightning
					68397 --> Lei Shen
				}
			},
			
			--> phase 4
			{
				spells = 	{
					137176 --> Overloaded Circuits 
				},
				adds = 	{
					69013, --> Diffused Lightning
					69133 --> Unharnessed Power
				}
			},
			
			--> phase 5
			{
				spells = 	{
					136889, --> Violent Gale Winds 
					135096, --> Thunderstruck 
					134821, --> Discharged Energy 
					136620, --> Ball Lightning 
					136543, --> Summon Ball Lightning 
					136914, --> Electrical Shock 
					139011, --> Helm of Command 
					136478, --> Fusion Slash 
					136853, --> Lightning Bolt 
					137176, --> Overloaded Circuits 
					136850 --> Lightning Whip 
				},
				adds = 	{
					69013, --> Diffused Lightning
					69133, --> Unharnessed Power
					69232, --> Ball Lightning
					68397 --> Lei Shen
				}
			}
		}
	},

------------> Ra-den ------------------------------------------------------------------------------
		[13] = {
			boss =	"Ra-Den",
			phases = {}
		}
		
	} --> Fim da lista dos Bosses de Throne of Thunder
}


_detalhes:InstallEncounter (throne_of_thunder)
