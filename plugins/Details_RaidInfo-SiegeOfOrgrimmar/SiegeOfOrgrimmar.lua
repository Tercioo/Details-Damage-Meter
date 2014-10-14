--[[
=====================================================================================================
	Siege of Orgrimmar Mobs and Spells Ids for Details
=====================================================================================================
--]]

local Loc = LibStub ("AceLocale-3.0"):GetLocale ("Details_RaidInfo-SiegeOfOrgrimmar")

local _detalhes = 		_G._detalhes

local siege_of_orgrimmar = {

	id = 1136,
	ej_id = 369,
	
	name = Loc ["STRING_RAID_NAME"],
	
	icons = "Interface\\AddOns\\Details_RaidInfo-SiegeOfOrgrimmar\\images\\boss_faces",
	
	icon = "Interface\\AddOns\\Details_RaidInfo-SiegeOfOrgrimmar\\images\\icon256x128",
	
	is_raid = true,

	backgroundFile = {file = [[Interface\Glues\LOADINGSCREENS\LoadScreenSiegeOfOrgrimmar]], coords = {0, 1, 256/1024, 840/1024}},
	backgroundEJ = [[Interface\EncounterJournal\UI-EJ-LOREBG-SiegeofOrgrimmar]],
	
	boss_names = { 
		-- Vale of Eternal Sorrows
			"Immerseus",
			"The Fallen Protectors",
			"Norushen",
			"Sha of Pride",
		-- Gates of Retribution
			"Galakras",
			"Iron Juggernaut",
			"Kor'kron Dark Shaman",
			"General Nazgrim",
		-- The Underhold
			"Malkorok",
			"Spoils of Pandaria",
			"Thok the Bloodthirsty",
		-- Downfall
			"Siegecrafter Blackfuse",
			"Paragons of the Klaxxi",
			"Garrosh Hellscream"
	},
	
	find_boss_encounter = function()
		--> find galakras (this encounter doesn't have a boss frames before galakras comes into in play)
		if (_detalhes.tabela_vigente and _detalhes.tabela_vigente[1] and _detalhes.tabela_vigente[1]._ActorTable) then
			for _, damage_actor in ipairs (_detalhes.tabela_vigente[1]._ActorTable) do
				local serial = _detalhes:GetNpcIdFromGuid (damage_actor.serial)
				if (serial == 73909) then --Archmage Aethas Sunreaver
					return 5 --> galakras boss index
				end
			end
		end
	end,
	
	encounter_ids = {
		--> Ids by Index
			852, 849, 866, 867, 881, 864, 856, 850, 846, 870, 851, 865, 853, 869,
		-- Vale of Eternal Sorrows
			[852] = 1, -- Immerseus
			[849] = 2, -- Fallen Protectors
			[866] = 3, -- Norushen
			[867] = 4, -- Sha of Pride
		-- Gates of Retribution
			[881] = 5, -- Galakras
			[864] = 6, -- Iron Juggernaut
			[856] = 7, -- Kor'kron Dark Shaman
			[850] = 8, -- General Nazgrim
			
		-- The Underhold
			[846] = 9, -- Malkorok
			[870] = 10, -- Spoils of Pandaria
			[851] = 11, -- Thok the Bloodthirsty
			
		-- Downfall
			[865] = 12, -- Siegecrafter Blackfuse
			[853] = 13, -- Paragons of Klaxy
			[869] = 14, -- Garrosh Hellscream
	},
	
	encounter_ids2 = {
		-- Vale of Eternal Sorrows
			[1602] = 1, -- Immerseus
			[1598] = 2, -- Fallen Protectors
			[1624] = 3, -- Norushen
			[1604] = 4, -- Sha of Pride
		-- Gates of Retribution
			[1622] = 5, -- Galakras
			[1600] = 6, -- Iron Juggernaut
			[1606] = 7, -- Kor'kron Dark Shaman
			[1603] = 8, -- General Nazgrim
			
		-- The Underhold
			[1595] = 9, -- Malkorok
			[1594] = 10, -- Spoils of Pandaria
			[1599] = 11, -- Thok the Bloodthirsty
			
		-- Downfall
			[1601] = 12, -- Siegecrafter Blackfuse
			[1593] = 13, -- Paragons of Klaxy
			[1623] = 14, -- Garrosh Hellscream
	},
	
	boss_ids = {
		-- Vale of Eternal Sorrows
			[71543]	= 1,	-- Immerseus
			[71479]	= 2,	-- He Softfoot
			[71480]	= 2,	-- Sun Tenderheart
			[71475]	= 2,  -- Rook Stonetoe
			[71967]	= 3,	-- Norushen
			[72276]	= 3,	-- Amalgam of Corruption
			[71734]	= 4,	-- Sha of Pride
		
		-- Gates of Retribution
			[72249]	= 5,	-- Galakras
			[71466]	= 6,	-- Iron Juggernaut
			[71859]	= 7,	-- Kor'kron Dark Shaman
			[71858]	= 7,	-- Wavebinder Kardris
			[71515]	= 8,	-- General Nazgrim
		
		-- The Underhold
			[71454]	= 9, -- Malkorok
			[71889]	= 10, -- Spoils of Pandaria
			[71529]	= 11, -- Thok the Bloodthirsty
		
		-- Downfall
			[71504]	= 12, -- Siegecrafter Blackfuse
			[71161]	= 13, -- Kil'ruk the Wind-Reaver
			[71157]	= 13, -- Xaril the Poisoned Mind
			[71156]	= 13, -- Kaz'tik the Manipulator
			[71155]	= 13, -- Korven the Prime
			[71160]	= 13, -- Iyyokuk the Lucid
			[71154]	= 13, -- Ka'roz the Locust
			[71152]	= 13, -- Skeer the Bloodseeker
			[71158]	= 13, -- Rik'kal the Dissector
			[71153]	= 13, -- Hisek the Swarmkeeper
			[71865]	= 14, -- Garrosh Hellscream
	},
	
	trash_ids = {
		--Immerseus
		[73349] = true, --Tormented Initiate
		[73342] = true, --Fallen Pool Tender
		[73226] = true, --Lesser Sha Pool
		[73191] = true, --Aqueius Defender
		
		-- Norushen
		[72655] = true, --Fragment of Pride
		[72658] = true, --Amalmated Hubris
		[72662] = true, --Vanity
		[72663] = true, --Arrogance
		[72661] = true, --Zeal
		
		--Sha of Pride
		[72791] = true, --lingering corruption
		
		--Galakras
		--[72367] = true, --dragonmaw tidal shaman
		--[72354] = true, --dragonmaw bonecrusher
		[72365] = true, --dragonmaw canoner
		[72350] = true, --dragonmaw elite grunt
		--[72351] = true, --dragonmaw flamebarer
		
		--> shamans
		[72412] = true, -- korkron grunt
		[72150] = true, -- kro kron shadowmage
		[72451] = true, --
		[72455] = true, --
		[72490] = true, --overseer mojka
		[72434] = true, --tresure guard
		[72421] = true, --korkron overseer
		[72452] = true, --dire wolf
		[72496] = true, --overseer thathung
		[72562] = true, --poison bolt toten
		
		--> nazgrim
		[72131] = true, -- blind blade master
		[72191] = true, -- overlord runthak
		[72194] = true, -- hellscreen demolisher
		[72564] = true, -- doom lord
		[71771] = true, -- korkron arcweaver
		[71772] = true, -- korkron assassin
		[71773] = true, -- krokron warshaman
		[71770] = true, -- krokron iron blade
		--[71715] = true, -- orgrimmar faithful -- also is used in nazgrim encounter
		
		--> malkorok
		[72728] = true, --korkron blood axe
		[72784] = true, --korkron gunner
		[72903] = true, --korkron siegemaster
		[72744] = true, --korkron skullspliter
		[72768] = true, --korkron warwolf
		[72770] = true, --korkron darkfarseer
		
		--> spoils of pandaria
		[73904] = true, --korkron iron sentinel
		[73742] = true, --thresher turret
		[73767] = true, --korkron shrederer
		[73775] = true, --war master kragg
		[73152] = true, --storeroom guard
		
		--> blackfuse
		[73539] = true, --korkron den mother
		[73541] = true, --korkron wolf puppy
		[73194] = true, --korkron iron scorpion
		--
		[72981] = true, --aggron
		[72964] = true, --gorodan
		[72986] = true, --shanna sparkfizz
		[73091] = true, --blackfuse sellsword
		[73095] = true, --blackfuse enginer
		
		--> thok
		--73195 --krokon jailer
		[73188] = true, --captive cave bat
		[73184] = true, --starved yeti
		[73185] = true, --enraged mushan beast
		[73223] = true, --pterrodax
		
		--> paragons
		[72954] = true, --korthik guard
		[72929] = true, --srathik amber master
		[73012] = true, --klaxxi skirmisher
		[72927] = true, --kovok

		--> garrosh
		[73414] = true, --korkron reaper
		[73452] = true, --harbinger of y'shaarj
		[73415] = true, --ichor of y'shaarj
		
		
		
	},
	
	encounters = {
	
------------> Immerseus ------------------------------------------------------------------------------
		[1] = {
			
			boss =	"Immerseus",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Immerseus]],

			spell_mechanics =	{
						[143295] = {0x1, 0x2000}, --> Sha Bolt
						[143309] = {0x8, 0x40}, --> Swirl
						[143413] = {0x8, 0x40}, --> Swirl
						[143412] = {0x8, 0x40}, --  Swirl
						[143436] = {0x100}, --> Corrosive Blast
						[143281] = {0x8}, --> Seeping Sha
						[143574] = {0x200}, --> Swelling Corruption
						[143498] = {0x1, 0x200, 0x2}, --> Erupting Sha
				 		[143460] = {0x200}, --> Sha Pool
						[143286] = {0x40}, --> Seeping Sha
						[143297] = {0x200}, --> Sha Splash
						[145377] = {0x1}, --> Erupting Water
						[143574] = {0x200}, --> Swelling Corruption (H)
						[143460] = {0x200}, --> 
						[143579] = {} -- Sha Corruption
						
					},
			
			phases = {
				--> phase 1 - Tears of the Vale
				{
					spells = {
							143295, --> Sha Bolt
							143309, --> Swirl
							143413, --> Swirl
							143436, --> Corrosive Blast
							143281, --> Seeping Sha
							143574, --> Swelling Corruption
							143297, --> Sha Splash
							145377, --> Erupting Water
							143574, --> Swelling Corruption (H)
							143579 -- Sha Corruption
						},
						
					adds = {
						71543, --> Immerseus
						71642, --> Congealed Sha
					}
				},
				--> phase 2 - Split
				{
					spells = {
							143459, --> Sha Residue (speed mod over players near sha puddle, trigger on death)
							143540, --> Congealing (speed mod over contaminated puddle)
							143524, --> Purified Residue (full health trigger for contaminated puddle)
							143498, --> Erupting Sha
							143460, --> Sha Pool
							143286, --> Seeping Sha
							143297, --> Sha Splash
							145377, --> Erupting Wate
							143460 --> Sha Pool (H)
						},
						
					adds = {
						71603, --> Sha Puddle
						71604, --> Contaminated Puddle
						71642, --> Congealed Sha
					}
				}
			}
		}, --> end of Immerseus 
		
		
------------> The Fallen Protectors ------------------------------------------------------------------------------
		[2] = {

			boss =	"The Fallen Protectors",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Golden Lotus Council]],

			combat_end = {2, {	71479, -- He Softfoot
							71480, -- Sun Tenderheart
							71475, -- Rook Stonetoe
						}},
			
			spell_mechanics =	{
						[144397] = {0x8000, 0x1}, --> Vengeful Strikes (Rook Stonetoe)
						[143023] = {0x8}, --> Corrupted Brew (Rook Stonetoe)
						[143028] = {0x1}, --> Clash (Rook Stonetoe)
						[143010] = {0x80}, --> Corruption Kick (Rook Stonetoe)
						[143009] = {0x80}, --> Corruption Kick (Rook Stonetoe)
						[144357] = {0x8, 0x1}, --> Defiled Ground (Embodied Misery)
						[143961] = {0x8, 0x1}, --> Defiled Ground (Embodied Misery)
						[143962] = {0x10000}, --> Inferno Strike (Embodied Sorrow)
						[144018] = {0x20, 0x1}, --> Corruption Shock (Embodied Gloom)
						
						[143198] = {0x1}, --> Garrote (He Softfoot)
						[143301] = {0x8000}, --> Gouge (He Softfoot)
						[144367] = {0x8}, --> Noxious Poison (He Softfoot)
						[143224] = {0x1, 0x800}, --> Instant Poison (He Softfoot)
						[143808] = {0x1, 0x2}, --> Mark of Anguish (Embodied Anguish)
						[144365] = {0x1, 0x2}, --> Mark of Anguish (Embodied Anguish)
						
						[143424] = {0x2000}, -->  Sha Sear (Sun Tenderheart)
						[143434] = {0x1, 0x10}, --> Shadow Word: Bane (Sun Tenderheart)
						[143544] = {0x1}, --> Calamity (Sun Tenderheart) --ptr
						[143493] = {0x1}, --> Calamity (Sun Tenderheart) --live
						[143559] = {0x1, 0x40}, --> Dark Meditation
						
						[144007] = {},  --Residual Burn
						[145631] = {},  --Corruption Chain
						[143602] = {},  --Meditation Spike
					},
		

		
			continuo = {
						144397, --> Vengeful Strikes (Rook Stonetoe)
						143023, --> Corrupted Brew (Rook Stonetoe)
						143028, --> Clash (Rook Stonetoe)
						143009, --> Corruption Kick (Rook Stonetoe)
						144357, --> Defiled Ground (Embodied Misery)
						143962, --> Inferno Strike (Embodied Sorrow)
						144018, --> Corruption Shock (Embodied Gloom)
						
						143198, --> Garrote (He Softfoot)
						143301, --> Gouge (He Softfoot)
						144367, --> Noxious Poison (He Softfoot)
						143224, --> Instant Poison (He Softfoot)
						143808, --> Mark of Anguish (Embodied Anguish)
						
						143424, -->  Sha Sear (Sun Tenderheart)
						143434, --> Shadow Word: Bane (Sun Tenderheart)
						143544, --> Calamity (Sun Tenderheart)
						143559, --> Dark Meditation
						
						143010, --> Corruption Kick (Rook Stonetoe)
						143493, --> Calamity (Sun Tenderheart) --live
						144365, --> Mark of Anguish (Embodied Anguish)
						143961, --> Defiled Ground (Embodied Misery)
						
						144007,  --Residual Burn
						145631,  --Corruption Chain
						143602,  --Meditation Spike
			},
		
			phases = {
				{
					--> phase 1 - 
					spells = {
							--> no spell, is all continuo
						},
					adds = 	{
							71479, -- He Softfoot
							71480, -- Sun Tenderheart
							71475, -- Rook Stonetoe
							
							71476, --> Embodied Misery (Rook Stonetoe)
							71481, -->  Embodied Sorrow (Rook Stonetoe)
							71477, -->  Embodied Gloom (Rook Stonetoe)
							
							71478, --> Embodied Anguish (He Softfoot)
							
							71474, --> Embodied Despair (Sun Tenderheart)
							71482, --> Embodied Desperation (Sun Tenderheart)
							71712, --> Despair Spawns  (Sun Tenderheart)
							71993, --> Desperation Spawn
						}
				}			
			} 
	
		}, --> end of The Fallen Protectors
		
------------> Norushen ------------------------------------------------------------------------------

		[3] = {
			boss =	"Norushen",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Norushen]],
			
			--combat_end = {1, 72276},
			encounter_start = {delay = 0},
			equalize = true,
			
			spell_mechanics =	{
						[146707] = {0x1}, --> Disheartening Laugh
						[144514] = {0x10}, --> Lingering Corruption
						
						[144628] = {0x40}, --> Titanic Smash
						[144649] = {0x20}, --> Hurl Corruption
						[144654] = {0x8}, --> Burst of Corruption
						[144657] = {0x800}, --> Piercing Corruption
						
						[145212] = {0x1}, --> Unleashed Anger
						[146124] = {0x100}, --> Self Doubt (not a damage)
						[145733] = {0x1}, --> Icy Fear -ptr
						[145735] = {0x1}, --> Icy Fear -live
						[145227] = {0x8, 0x40}, --> Blind Hatred
						
						[147082] = {0x1, 0x2}, --> Burst of Anger
						[145073] = {0x200, 0x8}, --> Residual Corruption
						[144548] = {0x200}, --> Expel Corruption
						[145134] = {0x200}, --> Expel Corruption -live
						[144482] = {} --> Tear Reality
					},
			
			continuo = {
						146707, --> Disheartening Laugh
						144514, -->  Lingering Corruption
						
						144628, -->  Titanic Smash
						144649, -->  Hurl Corruption
						144654, -->  Burst of Corruption
						144657, -->  Piercing Corruption
						
						145212, -->  Unleashed Anger
						146124, -->  Self Doubt
						145733, -->  Icy Fear
						145735, --> Icy Fear -live
						145227, -->  Blind Hatred
						
						147082, -->  Burst of Anger
						145073, -->  Residual Corruption
						144548, -->  Expel Corruption
						145134, -->  Expel Corruption
						144482, --> Tear Reality
			},
			
			phases = {
				{
					adds = 	{
							72276, --> Amalgam of Corruption
							
							71977, --> Manifestation of Corruption (dps test)
							72264, --> Unleashed Manifestation of Corruption
							71976, --> Essences of Corruption (dps test)
							72263, --> Unleashed Essences of Corruption
							
							72001, --> Greater Corruption (healer test)
							
							72051, --> Titanc Corruption (tank test)
						}
				}
			}

		}, --> end of Norushen
		
------------> Sha of Pride ------------------------------------------------------------------------------	
		[4] = {
			boss =	"Sha of Pride",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Sha of Pride]],
			
			combat_end = {1, 71734},
			
			spell_mechanics = {
				[144400] = {0x1}, --> Swelling Pride
				[144774] = {0x40}, --> Reaching Attack 
				[144358] = {0x100}, --> Wounded Pride (not a damage)
				[144351] = {0x10, 0x200}, --> Mark of Arrogance
				[144911] = {0x8}, --> Bursting Pride
				[145320] = {0x200}, --> Projection
				[146818] = {0x2000}, --> Aura of Pride
				[144379] = {0x20}, --> Mocking Blast 
				[144832] = {0x1, 0x2}, --> Unleashed
				[144836] = {0x1, 0x2}, --> Unleashed
				[144788] = {0x200}, --> Self-Reflection
				[144636] = {0x1, 0x200}, --> Corrupted Prison
				[144684] = {0x1, 0x200}, --> Corrupted Prison
				[144574] = {0x1, 0x200}, --> Corrupted Prison
				[144683] = {0x1, 0x200}, --> Corrupted Prison
				[144774] = {0x40}, -->  Reaching Attack
				
				[145215] = {}, --Banishment
				[147198] = {}, --Unstable Corruption
			},
			
			continuo = {
				144400, --> Swelling Pride
				144774, --> Reaching Attack 
				144358, --> Wounded Pride (not a damage)
				144351, --> Mark of Arrogance
				144911, --> Bursting Pride
				145320, --> Projection
				146818, --> Aura of Pride
				144379, --> Mocking Blast
				144832, --> Unleashed
				144836, --> Unleashed
				144788, --> Self-Reflection
				144636, --> Corrupted Prison
				144684, --> Corrupted Prison
				144574, --> Corrupted Prison
				144683, --> Corrupted Prison
				144774, --> Reaching Attack
				
				145215, --Banishment
				147198, --Unstable Corruption
			},
			
			phases = { 
				{ --> phase 1
					adds = {
						71734, --> Sha of Pride
						72172, --> Reflections
						71946, --> Manifestation of Pride
						} 
				}
			}
		}, --> end of Sha of Pride
		
------------> Galakras ------------------------------------------------------------------------------	
		[5] = {
			boss =	"Galakras",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Galakras]],

			combat_end = {1, 72249},
			
			spell_mechanics = {
				[146902] = {0x1, 0x100}, -- Poison-Tipped Blades (Korgra the Snake)
				[147705] = {0x8}, -- Poison Cloud (Korgra the Snake)
				[147711] = {0x200}, -- Curse of Venom (Korgra the Snake)
				[147713] = {0x1}, -- Venom Bolt Volley (Korgra the Snake)
				[147688] = {0x40}, -- Arcing Smash (Lieutenant Krugruk)
				[147683] = {0x1}, -- Thunder Clap (Lieutenant Krugruk)
				[146849] = {0x40}, -- Shattering Strike (High Enforcer Thranok)
				[146769] = {0x200}, -- Crusher's Call (High Enforcer Thranok)
				[146848] = {0x80}, -- Skull Cracker (High Enforcer Thranok)
				[146773] = {0x1}, -- Shoot (Master Cannoneer Dagryn)
				[147824] = {0x40}, -- Muzzle Spray (Master Cannoneer Dagryn)

				[146899] = {0x200}, -- Fracture (Dragonmaw Bonecrushers)
				[146897] = {0x1}, -- Shattering Roar (Dragonmaw Bonecrushers)
				[147204] = {0x1}, -- Shattering Roar (Dragonmaw Bonecrushers)
				[146728] = {0x20}, -- Chain Heal (Dragonmaw Tidal Shamans)
				[149188] = {0x40}, -- Tidal Wwave (Dragonmaw Tidal Shamans)
				[149187] = {0x40}, -- Tidal Wave (Dragonmaw Tidal Shamans)
				[143474] = {0x200}, -- Healing Tide Totems (Dragonmaw Tidal Shamans)
				[143477] = {0x200}, -- Healing Tide (Healing Tide Totems)
				[147552] = {0x1, 0x8}, -- Flame Arrows (Dragonmaw Flameslingers)
				[146764] = {0x1, 0x8}, -- Flame Arrows (Dragonmaw Flameslingers)
				[146763] = {0x1, 0x8}, -- Flame Arrows (Dragonmaw Flameslingers)
				[146747] = {0x1}, -- Dragonmaw Strike (Dragonmaw Grunts)
				[147669] = {0x1}, -- Throw Axe (Dragonmaw Grunts)
				[148352] = {0x200}, -- DrakeFire (Dragonmaw Proto-Drakes)
				[148560] = {0x200}, -- DrakeFire (Dragonmaw Proto-Drakes)
				-- missing spells from Dragonmaw Wind Reavers
				[146776] = {0x40}, -- Flame Breath (Dragonmaw Proto-Drakes)
				[148311] = {0x40}, -- Bombard (Kor'kron Demolishers)
				[148310] = {0x40}, -- Bombard (Kor'kron Demolishers)
				[147029] = {0x200}, -- Flames of Galakrond
				[146992] = {0x200}, -- Flames of Galakrond
				[147043] = {0x2}, -- Pulsing Flames
			},
			
			continuo = {
				
			},
			
			phases = { 
				{ --> phase 1: Bring Her Down!
					adds = {
							72456, --Korgra the Snake
							72357, --Lieutenant Krugruk
							72355, --High Enforcer Thranok
							72356, --Master Cannoneer Dagryn
							
							72352, --Dragonmaw Ebon Stalkers
							72354, --Dragonmaw Bonecrushers
							72367, --Dragonmaw Tidal Shamans
							71610, --Healing Tide Totem
							72353, --Dragonmaw Flameslingers
							72941, --Dragonmaw Grunts
							72600, --Dragonmaw Wind Reavers
							72943, --Dragonmaw Proto-Drakes
							72351, --Dragonmaw Flagbearers
							--missing npc id for Banners placed from Dragonmaw Flagbearers
							72947, --Kor'kron Demolishers
						},
					spells = {
							146902, --Poison-Tipped Blades (Korgra the Snake)
							147705, --Poison Cloud (Korgra the Snake)
							147711, --Curse of Venom (Korgra the Snake)
							147713, --Venom Bolt Volley (Korgra the Snake)
							147688, --Arcing Smash (Lieutenant Krugruk)
							147683, --Thunder Clap (Lieutenant Krugruk)
							146849, --Shattering Strike (High Enforcer Thranok)
							146769, --Crusher's Call (High Enforcer Thranok)
							146848, --Skull Cracker (High Enforcer Thranok)
							146773, --Shoot (Master Cannoneer Dagryn)
							147824, --Muzzle Spray (Master Cannoneer Dagryn)
							148560, -- DrakeFire (Dragonmaw Proto-Drakes)
							146899, --Fracture (Dragonmaw Bonecrushers)
							146897, --Shattering Roar (Dragonmaw Bonecrushers)
							147204, -- Shattering Roar (Dragonmaw Bonecrushers)
							146728, --Chain Heal (Dragonmaw Tidal Shamans)
							149188, --Tidal Wwave (Dragonmaw Tidal Shamans)
							149187, --Tidal Wave (Dragonmaw Tidal Shamans)
							143474, --Healing Tide Totems (Dragonmaw Tidal Shamans)
							143477, --Healing Tide (Healing Tide Totems)
							147552, --Flame Arrows (Dragonmaw Flameslingers)
							146764, --Flame Arrows (Dragonmaw Flameslingers)
							146763, --Flame Arrows (Dragonmaw Flameslingers)
							146747, --Dragonmaw Strike (Dragonmaw Grunts)
							147669, --Throw Axe (Dragonmaw Grunts)
							148352, --DrakeFire (Dragonmaw Proto-Drakes)
							-- missing spells from Dragonmaw Wind Reavers
							146776, --Flame Breath (Dragonmaw Proto-Drakes)
							148311, --Bombard (Kor'kron Demolishers)
							148310, --Bombard (Kor'kron Demolishers)
							
						}
				},
				{ --> phase 2: Galakras, The Last of His Progeny
					adds = {
							72249, --Galakras
						},
					spells = {
							147029, --Flames of Galakrond
							146992, --Flames of Galakrond
							147043, --Pulsing Flames
						}
				}
			}
		}, --> end of Galakras
		
------------> Iron Juggernaut ------------------------------------------------------------------------------	
		[6] = {
			boss =	"Iron Juggernaut",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Iron Juggernaut]],
			combat_end = {1, 71466},
			
			spell_mechanics = {
						[144464] = {0x100}, --> Flame Vents
						[144467] = {0x100, 0x1}, -->  Ignite Armor
						[144791] = {0x1, 0x200, 0x40}, -->   Engulfed Explosion
						[144218] = {0x40}, --> Borer Drill
						[144459] = {0x1}, --> Laser Burn
						--[144439] = {}, -->Ricochet
						[144483] = {0x1}, --> Seismic Activity
						[144484] = {0x1}, --> Seismic Activity
						[144485] = {0x1, 0x40}, --> Shock Pulse 
						[144154] = {0x2000}, --> Demolisher Cannons 
						[144316] = {0x2000}, --> Mortar Blast
						[144918] = {0x40, 0x80}, --> Cutter Laser
						[144498] = {0x8, 0x200}, --> Explosive Tar 
						[144327] = {}, --> Ricochet 
						[144919] = {}, --> Tar Explosion
			},
			
			continuo = {
				
			},
			
			phases = { 
				{ --> phase 1: Pressing the Attack: Assault Mode
					adds = {
						72050, --> Crawler Mines
						71466 --> iron juggernaut
					},
					spells = {
						144464, --> Flame Vents
						144218, --> Borer Drill
						144459, --> Laser Burn
						--> Mortar Cannon
						--144439 --> Ricochet
						144467, --> Ignite Armor
						144316, --> Mortar Blast
						144791, --> Engulfed Explosion
						144327, --> Ricochet 
					}
				},
				{ --> phase 2: Breaking the Defense: Siege Mode: 
					adds = {
						71466 --> iron juggernaut
					},
					spells = {
						144483, --> Seismic Activity
						144484, --> Seismic Activity
						144485, --> Shock Pulse 
						144154, --> Demolisher Cannons 
						144918, --> Cutter Laser
						144498, --> Explosive Tar 
						144919,
					}
				}
			},
			
		}, --> end of Iron Juggernaut
		
------------> Kor'kron Dark Shaman ------------------------------------------------------------------------------	
		[7] = {
			boss =	"Kor'kron Dark Shaman",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-KorKron Dark Shaman]],
			combat_end = {1, 71859},

			spell_mechanics = {
				[144303] = {0x1}, --Swipe
				[144304] = {0x1}, --Rend
				
				[144215] = {0x100}, --Froststorm Strike
				[144089] = {0x1}, --Toxic Mist 90%
				[144090] = {0x8}, --Foul Stream 80%
				[144070] = {0x200}, --Ashen Wall 70%
				
				[144214] = {0x1}, --Froststorm Bolt
				[144005] = {0x8}, --Toxic Storm 90%
				[144017] = {0x8}, --Toxic Storm 90%
				[144030] = {0x40}, -- Toxic Tornado
				[143990] = {0x80, 0x40}, --Foul Geyser 80%
				[143993] = {0x80, 0x40}, --Foul Geyser 80%
				[143973] = {0x8}, --Falling Ash 70%
				[143987] = {0x8}, --Falling Ash 70%
				
				[144064] = {0x40}, --Foulness
				[144066] = {0x40}, --Foulness
				
				[144328] = {}, --> Iron Tomb
				[144334] = {}, --> Iron Tomb
				[144330] = {}, --> Iron Prison
				[144331] = {}, --> Iron Prison
			},
			
			continuo = {
				144303, --Swipe
				144304, --Rend
				
				144215, --Froststorm Strike
				144089, --Toxic Mist
				144090, --Foul Stream
				144070, --Ashen Wall
				
				144214, --Froststorm Bolt
				144005, --Toxic Storm
				144017, --Toxic Storm
				144030, --Toxic Tornado
				143990, --Foul Geyser
				143993, --Foul Geyser
				143973, --Falling Ash
				143987, --Falling Ash
				144064, --Foulness
				144066, --Foulness
				144328, --> Iron Tomb
				144334, --> Iron Tomb
				144330, --> Iron Prison
				144331, --> Iron Prison
			},
			
			phases = { 
				{ --> phase 1: 
					adds = {
						71859, --> Earthbreaker Haromm
						71858, --> Wavebinder Kardris
						71921, --> Darkfang
						71923, --> Bloodclaw
						71801, --> Toxic Storm
						71827, --> Ash Elemental
						71825 --> Foul Slimes
					},
					spells = {
						--> 
					}
				},
			},
			
		}, --> end of Kor'kron Dark Shaman
		
------------> General Nazgrim ------------------------------------------------------------------------------	
		[8] = {
			boss =	"General Nazgrim",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-General Nazgrim]],

			combat_end = {1, 71515},
			
			spell_mechanics = {
				[143494] = {0x100}, --Sundering Blow
				[143638] = {0x1}, --Bonecracker
				[143716] = {0x2000}, --Heroic Shockwave
				[143712] = {0x80, 0x8}, --Aftershocks
				[143503] = {0x1}, --War Song
				[143872] = {0x80, 0x40}, --Ravager
				
				[143420] = {0x80, 0x40}, --Ironstorm (Kor'kron Ironblades)
				[143421] = {0x80, 0x40}, --Ironstorm (Kor'kron Ironblades)
				[143481] = {0x200, 0x1000}, --Backstab (Kor'kron Assassins)
				[143432] = {0x20, 0x1}, --Arcane Shock (Kor'kron Arcweavers)
				[143431] = {0x20, 0x1}, --Magistrike (Kor'kron Arcweavers)
			},
			
			continuo = {
				143494, --Sundering Blow
				143638, --Bonecracker
				143716, --Heroic Shockwave
				143712, --Aftershocks
				143503, --War Song
				143872, --Ravager
				
				143420, --Ironstorm (Kor'kron Ironblades)
				143421, --Ironstorm (Kor'kron Ironblades)
				143481, --Backstab (Kor'kron Assassins)
				143432, --Arcane Shock (Kor'kron Arcweavers)
				143431, --Magistrike (Kor'kron Arcweavers)
				
			},
			
			phases = { 
				{ --> phase 1: 
					adds = {
						71515, --General Nazgrim
						71626, --Kor'kron Banner
						71715, --Orgrimmar Faithful
						71516, --Kor'kron Ironblades
						71518, --Kor'kron Assassins
						71517, --Kor'kron Arcweavers
						71519, --Kor'kron Warshamans
						71610, --Healing Tide Totem
					},
					spells = {
						--> 
					}
				},
			},
			
		}, --> end of General Nazgrim
		
------------> Malkorok ------------------------------------------------------------------------------	
		[9] = {
			boss =	"Malkorok",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Malkorok]],

			combat_end = {1, 71454},
			
			spell_mechanics = {
						[142861] = {0x200}, --Ancient Miasma
						[142906] = {0x200}, --Ancient Miasma
						[142990] = {0x100}, --Fatal Strike
						[142851] = {0x2000}, --Seismic Slam
						[142849] = {0x2000}, --Seismic Slam
						[142826] = {0x40}, --Arcing Smash
						[142815] = {0x40}, --Arcing Smash
						[142816] = {0x40}, --Breath of Y'Shaarj
						[142987] = {0x200, 0x1}, --Imploding Energy
						[142986] = {0x200, 0x1}, --Imploding Energy
						[142879] = {0x10000}, --Blood Rage
						[142890] = {0x10000}, --Blood Rage
						[142913] = {0x80}, --Displaced Energy
			},
			
			continuo = {

			},
			
			phases = { 
				{ --> phase 1: Might of the Kor'kron
					adds = {
						71454, --Malkorok
						71644 --living corruption
					},
					spells = {
						142861, --Ancient Miasma
						142906, --Ancient Miasma
						142990, --Fatal Strike
						142851, --Seismic Slam
						142849, --Seismic Slam
						142826, --Arcing Smash
						142815, --Arcing Smash
						142816, --Breath of Y'Shaarj
						142987, --Imploding Energy
						142986 --Imploding Energy
					}
				},
				{ --> phase 2: Blood Rage
					adds = {

					},
					spells = {
						142879, --Blood Rage
						142890, --Blood Rage
						142913 --Displaced Energy
					}
				},
			},
			
		}, --> end of Malkorok
		
------------> Spoils of Pandaria ------------------------------------------------------------------------------	
		[10] = {
			boss =	"Spoils of Pandaria",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Spolis of Pandaria]],

			spell_mechanics = {
				--Lightweight Crates -> Mogu Crates
				[145218] = {0x10, 0x20}, --Harden Flesh (Animated Stone Mogu)
				[144923] = {0x20}, --Earthen Shard (Animated Stone Mogu)
				[142775] = {0x40}, --Nova (Sparks of Life)
				[142765] = {0x40}, --Pulse (Sparks of Life)
				[142759] = {0x40}, --Pulse (Sparks of Life)
				[144853] = {0x1}, --Carnivorous Bite (Quilen Guardians)
				--Stout Crates -> Mogu Crates
				[145393] = {0x200}, --Matter Scramble (Modified Anima Golems)
				--[145271] = {}, --Crimson Reconstitution (Modified Anima Golems)
				[142942] = {0x200, 0x10}, --Torment (Mogu Shadow Ritualists)
				[142983] = {0x200, 0x10}, --Torment (Mogu Shadow Ritualists)
				[145240] = {0x20}, --Forbidden Magic (Mogu Shadow Ritualists)
				--[145460] = {}, --Mogu Rune of Power (Mogu Shadow Ritualists)
				--Massive Crates -> Mogu Crates
				[145489] = {0x1}, --Return to Stone
				[145514] = {0x1}, --Return to Stone
				[148515] = {0x40}, --Shadow Volley (Jun-Wei)
				[148516] = {0x40}, --Shadow Volley (Jun-Wei)
				[148517] = {0x40}, --Molten Fist (Zu-Yin)
				[148518] = {0x40}, --Molten Fist (Zu-Yin)
				[148582] = {0x40}, --Jade Tempest (Xiang-Lin)
				[148583] = {0x40}, --Jade Tempest (Xiang-Lin)
				[148513] = {0x40}, --Fracture (Kun-Da)
				[148514] = {0x40}, --Fracture (Kun-Da)
				
				--Lightweight Crates -> Mantid Crates
				[145718] = {0x8}, -- Gusting Bomb (Sri'thik Bombardiers)
				[145716] = {0x8}, -- Gusting Bomb (Sri'thik Bombardiers)
				[145706] = {0x1, 0x2000}, --Throw Explosives (Sri'thik Bombardiers)
				[145748] = {0x8}, -- Encapsulated Pheromones (Sri'thik Bombardiers)
				--[145692] = {}, -- Enrage (Kor'thik Warcallerss)
				--Stout Crates -> Mantid Crates
				--[145808] = {}, --Mantid Swarm (Zar'thik Amber Priests)
				--[145790] = {}, --Residue (Zar'thik Amber Priests)
				[145817] = {0x40}, --Windstorm (Set'thik Wind Wielders)
				--[145812] = {}, --Rage of the Empress (Set'thik Wind Wielders)
				--Massive Crates -> Mantid Crates
				[148760] = {0x1}, --Pheromone Cloud (Pheromone Cloud)
				[145993] = {0x200}, --Set to Blow (Ka'thik Demolisher)
				[142997] = {0x200}, --Set to Blow (Ka'thik Demolisher)
				[145987] = {0x200}, --Set to Blow (Ka'thik Demolisher)
				[145996] = {0x200}, --Set to Blow (Ka'thik Demolisher)
				[146365] = {0x200}, --Set to Blow (Ka'thik Demolisher)
				[147404] = {0x200}, --Set to Blow (Ka'thik Demolisher)
				[148054] = {0x200}, --Set to Blow (Ka'thik Demolisher)
				[148055] = {0x200}, --Set to Blow (Ka'thik Demolisher)
				[148056] = {0x200}, --Set to Blow (Ka'thik Demolisher)
				
				--Pandaren Crates
				[146217] = {0x2000}, -- Keg Toss (Ancient Brewmaster Spirits)
				[146222] = {0x40}, --Breath of Fire (Ancient Brewmaster Spirits)
				[146226] = {0x40}, --Breath of Fire (Ancient Brewmaster Spirits)
				[146230] = {0x40}, --Breath of Fire (Ancient Brewmaster Spirits)
				--[146081] = {}, --(Ancient Brewmaster Spirits)
				[146180] = {0x40, 0x1}, --Gusting Crane Kick (Wise Mistweaver Spirits)
				[146182] = {0x40, 0x1}, --Gusting Crane Kick (Wise Mistweaver Spirits)
				--[146189] = {},  Eminence --(Wise Mistweaver Spirits)
				--[146679] = {}, --(Wise Mistweaver Spirits)
				[146257] = {0x8, 0x2000}, --(Nameless Windwalker Spirits)
				--[146142] = {}, --(Nameless Windwalker Spirits)
			},
			
			continuo = {
				
			},
			
			phases = { 
				{ --> phase 1:
					adds = {
						--Lightweight Crates -> Mogu Crates
						71380, --Animated Stone Mogu
						71382, --Burial Urns
						71433,--Sparks of Life
						71378, --Quilen Guardians
						--Stout Crates -> Mogu Crates
						71395, --Modified Anima Golems
						71393, --Mogu Shadow Ritualists
						--Massive Crates -> Mogu Crates
						72535, --Stone Statue
						73723, --Jun-Wei
						73724, --Zu-Yin
						73725, --Xiang-Lin
						71408, --Kun-Da
						
						--Lightweight Crates -> 
						71385, --Sri'thik Bombardiers
						71383, --Kor'thik Warcallerss
						--Stout Crates -> Mantid Crates
						71397, --Zar'thik Amber Priests
						71398, --Zar'thik Swarmer
						71405, --Set'thik Wind Wielders
						--Massive Crates -> Mantid Crates
						--unknow id -- Ka'thik Demolisher
						
						--Pandaren Crates
						71427, --Ancient Brewmaster Spirits
						71428, --Wise Mistweaver Spirits
						71430 --Nameless Windwalker Spirits
					},
					spells = {
						--Lightweight Crates -> Mogu Crates
						145218, --Harden Flesh (Animated Stone Mogu)
						144923, --Earthen Shard (Animated Stone Mogu)
						142775, --Nova (Sparks of Life)
						142765, --Pulse (Sparks of Life)
						142759, --Pulse (Sparks of Life)
						144853, --Carnivorous Bite (Quilen Guardians)
						--Stout Crates -> Mogu Crates
						145393, --Matter Scramble (Modified Anima Golems)
						145271, --Crimson Reconstitution (Modified Anima Golems)
						142942, --Torment (Mogu Shadow Ritualists)
						142983, --Torment (Mogu Shadow Ritualists)
						146885, --Torment (Mogu Shadow Ritualists)
						145240, --Forbidden Magic (Mogu Shadow Ritualists)
						145460, --Mogu Rune of Power (Mogu Shadow Ritualists)
						--Massive Crates -> Mogu Crates
						145514, --Return to Stone
						145489, --Return to Stone
						148515, --Shadow Volley (Jun-Wei)
						148516, --Shadow Volley (Jun-Wei)
						148517, --Molten Fist (Zu-Yin)
						148518, --Molten Fist (Zu-Yin)
						148582, --Jade Tempest (Xiang-Lin)
						148583, --Jade Tempest (Xiang-Lin)
						148513, --Fracture (Kun-Da)
						148514, --Fracture (Kun-Da)
						
						--Lightweight Crates -> 
						145718, -- Gusting Bomb (Sri'thik Bombardiers)
						145716, -- Gusting Bomb (Sri'thik Bombardiers)
						145706, --Throw Explosives (Sri'thik Bombardiers)
						145748, -- Encapsulated Pheromones (Sri'thik Bombardiers)
						145692, -- Enrage (Kor'thik Warcallerss)
						--Stout Crates -> Mantid Crates
						145808, --Mantid Swarm (Zar'thik Amber Priests)
						145790, --Residue (Zar'thik Amber Priests)
						145817, --Windstorm (Set'thik Wind Wielders)
						145812, --Rage of the Empress (Set'thik Wind Wielders)
						--Massive Crates -> Mantid Crates
						148760, --Pheromone Cloud (Pheromone Cloud)
						145993, --Set to Blow (Ka'thik Demolisher)
						142997, --Set to Blow (Ka'thik Demolisher)
						145987, --Set to Blow (Ka'thik Demolisher)
						145996, --Set to Blow (Ka'thik Demolisher)
						146365, --Set to Blow (Ka'thik Demolisher)
						147404, --Set to Blow (Ka'thik Demolisher)
						148054, --Set to Blow (Ka'thik Demolisher)
						148055, --Set to Blow (Ka'thik Demolisher)
						148056, --Set to Blow (Ka'thik Demolisher)
						
						--Pandaren Crates
						146217, --(Ancient Brewmaster Spirits)
						146222, --Breath of Fire(Ancient Brewmaster Spirits)
						146226, --Breath of Fire(Ancient Brewmaster Spirits)
						146230, --Breath of Fire(Ancient Brewmaster Spirits)
						146081, --(Ancient Brewmaster Spirits)
						146180, --(Wise Mistweaver Spirits)
						146189, --(Wise Mistweaver Spirits)
						146679, --(Wise Mistweaver Spirits)
						146257, --Path of Blossoms (Nameless Windwalker Spirits)
						146142, --(Nameless Windwalker Spirits)
						146182, --Gusting Crane Kick (Wise Mistweaver Spirits)
					}
				}
			},
			
		}, --> end of Spoils of Pandaria

------------> Thok the Bloodthirsty ------------------------------------------------------------------------------	
		[11] = {
			boss =	"Thok the Bloodthirsty",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Thok the Bloodthirsty]],
			
			combat_end = {1, 71529},
			
			spell_mechanics = {
				[143426] = {0x100}, --Fearsome Roar
				[143428] = {0x40}, --Tail Lash
				[143707] = {0x1}, --Shock Blast
				[143343] = {0x1, 0x4000}, --Deafening Screech
				--[143452] = {}, --Bloodied
				
				[143780] = {0x100}, --Acid Breath
				[143791] = {0x1}, --Corrosive Blood
				
				[143773] = {0x100}, --Freezing Breath
				[143800] = {0x1}, --Icy Blood
				
				[143767] = {0x100}, --Scorching Breath 
				[143783] = {0x1, 0x8}, --Burning Blood
			},
			
			continuo = {
				
			},
			
			phases = { 
				{ --> phase 1: A Cry in the Darkness 
					adds = {
						71529 --> Thok the Bloodthirsty
					},
					spells = {
						143426, --Fearsome Roar
						143428, --Tail Lash
						143707, --Shock Blast
						143343, --Deafening Screech
						143452, --Bloodied
						
						143780, --Acid Breath
						143791, --Corrosive Blood
						
						143773, --Freezing Breath
						143800, --Icy Blood
						
						143767, --Scorching Breath 
						143783 --Burning Blood
					}
				},
				{ --> phase 2: Frenzy for Blood!
					adds = {
						71658 --Kor'kron Jailer
					},
					spells = {
						
					}
				},
			},
			
		}, --> end of Thok the Bloodthirsty
		
------------> Siegecrafter Blackfuse ------------------------------------------------------------------------------	
		[12] = {
			boss =	"Siegecrafter Blackfuse",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Siegecrafter Blackfuse]],

			combat_end = {1, 71504},
			
			spell_mechanics = {
						[144335] = {0x8}, --Matter Purification Beam
						[143385] = {0x100}, --Electrostatic Charge
						[143265] = {0x40}, --Launch Sawblade
						--[144213] = {}, --Automatic Repair Beam
						[144210] = {0x40, 0x8}, --Death From Above
						[145444] = {0x1}, --Overload
						
						[144664] = {0x8, 0x40}, --Shockwave Missile (Missile Turrets)
						[144663] = {0x8, 0x40}, --Shockwave Missile (Missile Turrets)
						[144662] = {0x8, 0x40}, --Shockwave Missile (Missile Turrets)
						[144661] = {0x8, 0x40}, --Shockwave Missile (Missile Turrets)
						[144660] = {0x8, 0x40}, --Shockwave Missile (Missile Turrets)
						[143641] = {0x8, 0x40}, --Shockwave Missile (Missile Turrets)
						
						[143856] = {0x40, 0x8}, --Superheated (Laser Turrets)
						[144466] = {0x1, 0x200}, --Magnetic Crush (Electromagnets)
						[149146] = {0x80}, --Detonate! (Crawler Mines)
						[143327] = {0x40}, --Serrated Slash
			},
			
			continuo = {
			
			},
			
			phases = { 
				{ --> phase 1: 
					adds = {
						71504, --Siegecrafter Blackfuse
						71591, --Automated Shredders
						72050, --Crawler Mines
						71790, --Disassembled Crawler Mines
						71591, --Automated Shredder
						71638, --Activated Missile Turrets
						71606, --Deactivated Missile Turrets
						71752, --Activated Laser Turrets
						71751, --Deactivated Laser Turrets
						71696, --Activated Electromagnets
						71694 --Deactivated Electromagnets

					},
					spells = {
						144335, --Matter Purification Beam
						143385, --Electrostatic Charge
						143265, --Launch Sawblade
						144213, --Automatic Repair Beam
						144210, --Death From Above
						145444, --Overload
						143856, --Superheated (Laser Turrets)
						144466, --Magnetic Crush (Electromagnets)
						149146, --Detonate! (Crawler Mines)
						143327, --Serrated Slash
						144664, --Shockwave Missile (Missile Turrets)
						144663, --Shockwave Missile (Missile Turrets)
						144662, --Shockwave Missile (Missile Turrets)
						144661, --Shockwave Missile (Missile Turrets)
						144660, --Shockwave Missile (Missile Turrets)
						143641, --Shockwave Missile (Missile Turrets)
						
					}
				}
			},
			
		}, --> end of Siegecrafter Blackfuse
		
------------> Paragons of the Klaxxi ------------------------------------------------------------------------------	
		[13] = {
			boss =	"Paragons of the Klaxxi",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Klaxxi Paragons]],
			
			combat_end = {2, {
						71161, --Kil'ruk the Wind-Reaver
						71157, --Xaril the Poisoned Mind
						71158, --Rik'kal the Dissector 
						71152, --Skeer the Bloodseeker
						71160, --Iyyokuk the Lucid
						71155, --Korven the Prime
						71156, -- Kaz'tik the Manipulator
						71154, -- Ka'roz the Locust
						71153, -- Hisek the Swarmkeeper
						}},

			spell_mechanics = {
				--Kil'ruk the Wind-Reaver
				[142931] = {}, --Exposed Veins
				[143939] = {}, --Gouge
				[143941] = {}, --Mutilate
				[142232] = {}, --Death from Above 
				[142270] = {}, --Reave
				[142922] = {}, --Razor Sharp Blades
				[142930] = {}, --Razor Sharp Blades
				
				--Xaril the Poisoned Mind
				[142929] = {}, --Tenderizing Strikes
				[142315] = {}, --Caustic Blood
				[142317] = {}, --Bloody Explosion 
				[142528] = {}, --Toxic Injection
				[148656] = {}, --Vast Apothecarial Knowledge
				[142877] = {}, --Volatile Poultice
				[143735] = {}, --Caustic Amber
				[142797] = {}, --Noxious Vapors
				
				--Kaz'tik the Manipulator
				[142667] = {}, --Thick Shell
				[115268] = {}, --Mesmerize
				[142649] = {}, --Devour
				[142270] = {}, --Reave
				[142651] = {}, --Molt
				[144275] = {}, --Swipe
				[142655] = {}, --Swipe
				[143768] = {}, --Sonic Projection
				
				--Korven the Prime
				[142564] = {}, --Encase in Amber
				[143974] = {}, --Shield Bash
				
				[143979] = {}, --Vicious Assault
				[143980] = {}, --Vicious Assault
				[143981] = {}, --Vicious Assault
				[143982] = {}, --Vicious Assault
				[143984] = {}, --Vicious Assault
				[143985] = {}, --Vicious Assault
				
				[148649] = {}, --Master of Amber
				
				--Iyyokuk the Lucid
				[143666] = {}, --Diminish 
				[142514] = {}, --Calculate
				[142416] = {}, --Insane Calculation: Fiery Edge
				[142809] = {}, --Fiery Edgeficious Assault
				[142735] = {}, --Reaction: Blue
				[142736] = {}, --Reaction: Red
				[141858] = {}, --Ingenious 
				
				--Ka'roz the Locust
				[143701] = {}, --Whirling
				[143702] = {}, --Whirling
				[143733] = {}, --Hurl Amber
				[148650] = {}, --Strong Legs
				[142564] = {}, --Encase in Amber 
				
				--Skeer the Bloodseeker
				[143274] = {}, --Hewn 
				[143275] = {}, --Hewn 
				[143280] = {}, --Bloodletting
				[148655] = {}, --Bloodthirsty 
				
				--Rik'kal the Dissector
				[143278] = {}, --Genetic Alteration
				[143279] = {}, --Genetic Alteration
				[143339] = {}, --Injection
				[144274] = {}, --Claw
				[142655] = {}, --Swipe
				[144276] = {}, --Sting 
				[143373] = {}, --Gene Splice
				[143337] = {}, --Mutate
				
				--Hisek the Swarmkeeper
				[144839] = {}, --Multi-Shot 
				[142948] = {}, --Aim

			},
			
			continuo = {
				--Kil'ruk the Wind-Reaver
				142931, --Exposed Veins
				143939, --Gouge
				143941, --Mutilate
				142232, --Death from Above 
				142270, --Reave
				142922, --Razor Sharp Blades
				142930, --Razor Sharp Blades
				
				--Xaril the Poisoned Mind
				142929, --Tenderizing Strikes
				142315, --Caustic Blood
				142317, --Bloody Explosion 
				142528, --Toxic Injection
				148656, --Vast Apothecarial Knowledge
				142877, --Volatile Poultice
				143735, --Caustic Amber
				142797, --Noxious Vapors
				
				--Kaz'tik the Manipulator
				142667, --Thick Shell
				115268, --Mesmerize
				142649, --Devour
				142270, --Reave
				142651, --Molt
				144275, --Swipe
				142655, --Swipe
				143768, --Sonic Projection
				
				--Korven the Prime
				142564, --Encase in Amber
				143974, --Shield Bash
				
				143979, --Vicious Assault
				143980, --Vicious Assault
				143981, --Vicious Assault
				143982, --Vicious Assault
				143984, --Vicious Assault
				143985, --Vicious Assault
				
				148649, --Master of Amber
				
				--Iyyokuk the Lucid
				143666, --Diminish 
				142514, --Calculate
				142416, --Insane Calculation: Fiery Edge
				142809, --Fiery Edgeficious Assault
				142735, --Reaction: Blue
				142736, --Reaction: Red
				141858, --Ingenious 
				
				--Ka'roz the Locust
				143701, --Whirling
				143702, --Whirling
				143733, --Hurl Amber
				148650, --Strong Legs
				142564, --Encase in Amber 
				
				--Skeer the Bloodseeker
				143274, --Hewn 
				143275, --Hewn 
				143280, --Bloodletting
				148655, --Bloodthirsty 
				
				--Rik'kal the Dissector
				143278, --Genetic Alteration
				143279, --Genetic Alteration
				143339, --Injection
				144274, --Claw
				142655, --Swipe
				144276, --Sting 
				143373, --Gene Splice
				143337, --Mutate
				
				--Hisek the Swarmkeeper
				144839, --Multi-Shot 
				142948, --Aim
			},
			
			phases = { 
				{ --> phase 1: 
					adds = {
						71161, --Kil'ruk the Wind-Reaver
						71157, --Xaril the Poisoned Mind
						71158, --Rik'kal the Dissector 
						71152, --Skeer the Bloodseeker
						71160, --Iyyokuk the Lucid
						71155, --Korven the Prime
						71156, -- Kaz'tik the Manipulator
						71154, -- Ka'roz the Locust
						71153, -- Hisek the Swarmkeeper
						
						71578, --Amber Parasites 
						71542, --Bloods
						71420, --Hungry Kunchongs
						71425, --Mature Kunchongs
					},
					spells = {
						
					}
				}
			},
			
		}, --> end of Paragons of the Klaxxi
		
------------> Garrosh Hellscream ------------------------------------------------------------------------------	
		[14] = {
			boss =	"Garrosh Hellscream",
			portrait = [[Interface\EncounterJournal\UI-EJ-BOSS-Garrosh Hellscream]],

			combat_end = {1, 71865},
			equalize = true,
			
			spell_mechanics = {
				[144582] = {0x1}, --Hamstring (Kor'kron Warbringers)
				[144758] = {0x1, 0x40}, --Desecrate
				[144762] = {0x8}, --desecrated (Desecrated Weapon)
				[144584] = {0x20}, --Chain Lightning (Farseer Wolf Riders)
				[144989] = {0x40}, --Whirling Corruption
				[145033] = {0x2000}, --Empowered Whirling Corruption
				[145599] = {0x20}, --Touch of Y'Shaarj (mc casted)
				[145183] = {0x100}, --Gripping Despair
				[145195] = {0x100} --Empowered Gripping Despair
			},
			
			continuo = {
			
			},
			
			phases = { 
				{ --> phase 1: 
					adds = {
						72154, --Desecrated Weapon
						71979, --Kor'kron Warbringers
						71983, --Farseer Wolf Riders
						71984, --Siege Engineers
						71865, --Garrosh Hellscream
					},
					spells = {
						144758, --Desecrate
						144582, --Hamstring (Kor'kron Warbringers)
						144762, --desecrated (Desecrated Weapon)
						144583, --Ancestral Chain Heal (Farseer Wolf Riders)
						144584, --Chain Lightning (Farseer Wolf Riders)
					}
				},
				
				{ --> phase 2:
					adds = {
						72237, --Embodied Fears
						72238, --Embodied Doubts
						72236, --Embodied Despairs
						71865, --Garrosh Hellscream
					},
					spells = {
						144969 --Annihilate
					}
				},
				
				{ --> phase 3:
					adds = {
						72272, --Minion of Y'Shaarj
						71865, --Garrosh Hellscream
					},
					spells = {
						144989, --Whirling Corruption
						145033, --Empowered Whirling Corruption
						145599, --Touch of Y'Shaarj (mc casted)
						145183, --Gripping Despair
						145195, --Empowered Gripping Despair
						145213, --Explosive Despair
						144758, --Desecrate
						145829, --Empowered Desecrate
						144762, --desecrated (Desecrated Weapon)
					}
				},

				{ --> phase 4:
					adds = {
						72272, --Minion of Y'Shaarj
						71865, --Garrosh Hellscream
					},
					spells = {
						145033, --Empowered Whirling Corruption
						145195, --Empowered Gripping Despair
						145829, --Empowered Desecrate
						145599, --Touch of Y'Shaarj (mc casted)
					}
				},
			},
			
		}, --> end of Garrosh Hellscream
		
	} --> End SoO
}

--[[
				[0x1] = "|cFF00FF00"..Loc ["STRING_HEAL"].."|r", 
				[0x2] = "|cFF710000"..Loc ["STRING_LOWDPS"].."|r", 
				[0x4] = "|cFF057100"..Loc ["STRING_LOWHEAL"].."|r", 
				[0x8] = "|cFFd3acff"..Loc ["STRING_VOIDZONE"].."|r", 
				[0x10] = "|cFFbce3ff"..Loc ["STRING_DISPELL"].."|r", 
				[0x20] = "|cFFffdc72"..Loc ["STRING_INTERRUPT"].."|r", 
				[0x40] = "|cFFd9b77c"..Loc ["STRING_POSITIONING"].."|r", 
				[0x80] = "|cFFd7ff36"..Loc ["STRING_RUNAWAY"].."|r", 
				[0x100] = "|cFF9a7540"..Loc ["STRING_TANKSWITCH"] .."|r", 
				[0x200] = "|cFFff7800"..Loc ["STRING_MECHANIC"].."|r", 
				[0x400] = "|cFFbebebe"..Loc ["STRING_CROWDCONTROL"].."|r", 
				[0x800] = "|cFF6e4d13"..Loc ["STRING_TANKCOOLDOWN"].."|r", 
				[0x1000] = "|cFFffff00"..Loc ["STRING_KILLADD"].."|r", 
				[0x2000] = "|cFFff9999"..Loc ["STRING_SPREADOUT"].."|r", 
				[0x4000] = "|cFFffff99"..Loc ["STRING_STOPCAST"].."|r",
				[0x8000] = "|cFFffff99"..Loc ["STRING_FACING"].."|r",
				[0x10000] = "|cFFffff99"..Loc ["STRING_STACK"].."|r",
--]]

_detalhes:InstallEncounter (siege_of_orgrimmar)
