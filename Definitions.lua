
--lower instance: each instance has an ID, starts from 1 and goes on, the lower instance is the opened instance with the lower ID.
--training dummy: a npc within major cities in world of warcraft where players can cast spells and attack to test their damage and healing output

---@alias plugintype
---| "SOLO"
---| "RAID"
---| "TOOLBAR"
---| "STATUSBAR"

---@alias detailsevent
---| "DETAILS_INSTANCE_OPEN"
---| "DETAILS_INSTANCE_CLOSE"
---| "DETAILS_INSTANCE_SIZECHANGED"
---| "DETAILS_INSTANCE_STARTRESIZE"
---| "DETAILS_INSTANCE_ENDRESIZE"
---| "DETAILS_INSTANCE_STARTSTRETCH"
---| "DETAILS_INSTANCE_ENDSTRETCH"
---| "DETAILS_INSTANCE_CHANGESEGMENT"
---| "DETAILS_INSTANCE_CHANGEATTRIBUTE"
---| "DETAILS_INSTANCE_CHANGEMODE"
---| "DETAILS_INSTANCE_NEWROW"
---| "DETAILS_OPTIONS_MODIFIED"
---| "DETAILS_DATA_RESET"
---| "DETAILS_DATA_SEGMENTREMOVED"
---| "COMBAT_ENCOUNTER_START"
---| "COMBAT_ENCOUNTER_END"
---| "COMBAT_PLAYER_ENTER"
---| "COMBAT_PLAYER_LEAVE"
---| "COMBAT_PLAYER_TIMESTARTED"
---| "COMBAT_BOSS_WIPE"
---| "COMBAT_BOSS_DEFEATED"
---| "COMBAT_BOSS_FOUND"
---| "COMBAT_INVALID"
---| "COMBAT_PREPOTION_UPDATED"
---| "COMBAT_CHARTTABLES_CREATING"
---| "COMBAT_CHARTTABLES_CREATED"
---| "COMBAT_ENCOUNTER_PHASE_CHANGED"
---| "COMBAT_ARENA_START"
---| "COMBAT_ARENA_END"
---| "COMBAT_MYTHICDUNGEON_START"
---| "COMBAT_MYTHICDUNGEON_END"
---| "COMBAT_MYTHICDUNGEON_CONTINUE"
---| "GROUP_ONENTER"
---| "GROUP_ONLEAVE"
---| "ZONE_TYPE_CHANGED"
---| "REALM_CHANNEL_ENTER"
---| "REALM_CHANNEL_LEAVE"
---| "COMM_EVENT_RECEIVED"
---| "COMM_EVENT_SENT"
---| "UNIT_SPEC"
---| "UNIT_TALENTS"
---| "PLAYER_TARGET"
---| "DETAILS_PROFILE_APPLYED"

---@alias detailsattributes
---| "DETAILS_ATTRIBUTE_DAMAGE"
---| "DETAILS_ATTRIBUTE_HEAL"
---| "DETAILS_ATTRIBUTE_ENERGY"
---| "DETAILS_ATTRIBUTE_MISC"
---| "DETAILS_SUBATTRIBUTE_DAMAGEDONE"
---| "DETAILS_SUBATTRIBUTE_DPS"
---| "DETAILS_SUBATTRIBUTE_DAMAGETAKEN"
---| "DETAILS_SUBATTRIBUTE_FRIENDLYFIRE"
---| "DETAILS_SUBATTRIBUTE_FRAGS"
---| "DETAILS_SUBATTRIBUTE_ENEMIES"
---| "DETAILS_SUBATTRIBUTE_VOIDZONES"
---| "DETAILS_SUBATTRIBUTE_BYSPELLS"
---| "DETAILS_SUBATTRIBUTE_HEALDONE"
---| "DETAILS_SUBATTRIBUTE_HPS"
---| "DETAILS_SUBATTRIBUTE_OVERHEAL"
---| "DETAILS_SUBATTRIBUTE_HEALTAKEN"
---| "DETAILS_SUBATTRIBUTE_HEALENEMY"
---| "DETAILS_SUBATTRIBUTE_HEALPREVENTED"
---| "DETAILS_SUBATTRIBUTE_HEALABSORBED"
---| "DETAILS_SUBATTRIBUTE_REGENMANA"
---| "DETAILS_SUBATTRIBUTE_REGENRAGE"
---| "DETAILS_SUBATTRIBUTE_REGENENERGY"
---| "DETAILS_SUBATTRIBUTE_REGENRUNE"
---| "DETAILS_SUBATTRIBUTE_RESOURCES"
---| "DETAILS_SUBATTRIBUTE_ALTERNATEPOWER"
---| "DETAILS_SUBATTRIBUTE_CCBREAK"
---| "DETAILS_SUBATTRIBUTE_RESS"
---| "DETAILS_SUBATTRIBUTE_INTERRUPT"
---| "DETAILS_SUBATTRIBUTE_DISPELL"
---| "DETAILS_SUBATTRIBUTE_DEATH"
---| "DETAILS_SUBATTRIBUTE_DCOOLDOWN"
---| "DETAILS_SUBATTRIBUTE_BUFFUPTIME"
---| "DETAILS_SUBATTRIBUTE_DEBUFFUPTIME"

--globals
DETAILS_ATTRIBUTE_DAMAGE = 1
DETAILS_ATTRIBUTE_HEAL = 2
DETAILS_ATTRIBUTE_ENERGY = 3
DETAILS_ATTRIBUTE_MISC = 4
DETAILS_SUBATTRIBUTE_DAMAGEDONE = 1
DETAILS_SUBATTRIBUTE_DPS = 2
DETAILS_SUBATTRIBUTE_DAMAGETAKEN = 3
DETAILS_SUBATTRIBUTE_FRIENDLYFIRE = 4
DETAILS_SUBATTRIBUTE_FRAGS = 5
DETAILS_SUBATTRIBUTE_ENEMIES = 6
DETAILS_SUBATTRIBUTE_VOIDZONES = 7
DETAILS_SUBATTRIBUTE_BYSPELLS = 8
DETAILS_SUBATTRIBUTE_HEALDONE = 1
DETAILS_SUBATTRIBUTE_HPS = 2
DETAILS_SUBATTRIBUTE_OVERHEAL = 3
DETAILS_SUBATTRIBUTE_HEALTAKEN = 4
DETAILS_SUBATTRIBUTE_HEALENEMY = 5
DETAILS_SUBATTRIBUTE_HEALPREVENTED = 6
DETAILS_SUBATTRIBUTE_HEALABSORBED = 7
DETAILS_SUBATTRIBUTE_REGENMANA = 1
DETAILS_SUBATTRIBUTE_REGENRAGE = 2
DETAILS_SUBATTRIBUTE_REGENENERGY = 3
DETAILS_SUBATTRIBUTE_REGENRUNE = 4
DETAILS_SUBATTRIBUTE_RESOURCES = 5
DETAILS_SUBATTRIBUTE_ALTERNATEPOWER = 6
DETAILS_SUBATTRIBUTE_CCBREAK = 1
DETAILS_SUBATTRIBUTE_RESS = 2
DETAILS_SUBATTRIBUTE_INTERRUPT = 3
DETAILS_SUBATTRIBUTE_DISPELL = 4
DETAILS_SUBATTRIBUTE_DEATH = 5
DETAILS_SUBATTRIBUTE_DCOOLDOWN = 6
DETAILS_SUBATTRIBUTE_BUFFUPTIME = 7
DETAILS_SUBATTRIBUTE_DEBUFFUPTIME = 8

---@alias detailstotals
---| "DETAILS_TOTALS_ONLYGROUP"

---@alias detailssegmentid
---| "DETAILS_SEGMENTID_OVERALL"
---| "DETAILS_SEGMENTID_CURRENT"

---@alias detailscombatamountcontainers
---| "DETAILS_COMBAT_AMOUNT_CONTAINERS"

---@alias detailssegmenttype
---| "DETAILS_SEGMENTTYPE_GENERIC"
---| "DETAILS_SEGMENTTYPE_OVERALL"
---| "DETAILS_SEGMENTTYPE_DUNGEON_TRASH"
---| "DETAILS_SEGMENTTYPE_DUNGEON_BOSS"
---| "DETAILS_SEGMENTTYPE_DUNGEON_OVERALL"
---| "DETAILS_SEGMENTTYPE_RAID_TRASH"
---| "DETAILS_SEGMENTTYPE_RAID_BOSS"
---| "DETAILS_SEGMENTTYPE_MYTHICDUNGEON"
---| "DETAILS_SEGMENTTYPE_MYTHICDUNGEON_GENERIC"
---| "DETAILS_SEGMENTTYPE_MYTHICDUNGEON_TRASH"
---| "DETAILS_SEGMENTTYPE_MYTHICDUNGEON_OVERALL"
---| "DETAILS_SEGMENTTYPE_MYTHICDUNGEON_TRASHOVERALL"
---| "DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSS"
---| "DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSSTRASH"
---| "DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSSWIPE"
---| "DETAILS_SEGMENTTYPE_PVP_ARENA"
---| "DETAILS_SEGMENTTYPE_PVP_BATTLEGROUND"
---| "DETAILS_SEGMENTTYPE_EVENT_VALENTINEDAY"
---| "DETAILS_SEGMENTTYPE_TRAININGDUMMY"

DETAILS_TOTALS_ONLYGROUP = true
DETAILS_SEGMENTID_OVERALL = true
DETAILS_SEGMENTID_CURRENT = true
DETAILS_COMBAT_AMOUNT_CONTAINERS = true
DETAILS_SEGMENTTYPE_GENERIC = true
DETAILS_SEGMENTTYPE_OVERALL = true
DETAILS_SEGMENTTYPE_DUNGEON_TRASH = true
DETAILS_SEGMENTTYPE_DUNGEON_BOSS = true
DETAILS_SEGMENTTYPE_DUNGEON_OVERALL = true
DETAILS_SEGMENTTYPE_RAID_TRASH = true
DETAILS_SEGMENTTYPE_RAID_BOSS = true
DETAILS_SEGMENTTYPE_MYTHICDUNGEON = true
DETAILS_SEGMENTTYPE_MYTHICDUNGEON_GENERIC = true
DETAILS_SEGMENTTYPE_MYTHICDUNGEON_TRASH = true
DETAILS_SEGMENTTYPE_MYTHICDUNGEON_OVERALL = true
DETAILS_SEGMENTTYPE_MYTHICDUNGEON_TRASHOVERALL = true
DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSS = true
DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSSTRASH = true
DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSSWIPE = true
DETAILS_SEGMENTTYPE_PVP_ARENA = true
DETAILS_SEGMENTTYPE_PVP_BATTLEGROUND = true
DETAILS_SEGMENTTYPE_EVENT_VALENTINEDAY = true
DETAILS_SEGMENTTYPE_TRAININGDUMMY = true

---@class mythicdungeontrashinfo
---@field ZoneName string
---@field MapID number
---@field Level number
---@field EJID number

---@class mythicdungeoninfo
---@field StartedAt number?
---@field EndedAt number?
---@field WorldStateTimerStart number?
---@field WorldStateTimerEnd number?
---@field RunTime number?
---@field TotalTime number?
---@field TimeInCombat number?
---@field SegmentID string?
---@field RunID number?
---@field OverallSegment boolean?
---@field ZoneName string?
---@field EJID number?
---@field MapID number?
---@field Level number?
---@field OnTime boolean?
---@field KeystoneUpgradeLevels number?
---@field PracticeRun boolean?
---@field OldDungeonScore number?
---@field NewDungeonScore number?
---@field IsAffixRecord boolean?
---@field IsMapRecord boolean?
---@field PrimaryAffix number?
---@field IsEligibleForScore boolean?
---@field UpgradeMembers table?
---@field TimeLimit number?
---@field DungeonName string?
---@field DungeonID number?
---@field DungeonTexture string?
---@field DungeonBackgroundTexture string|number?
---@field SegmentType number?
---@field SegmentName string?

---@alias containertype number this container type is the number used to identify the actorcontainer type when using combat:GetContainer(containertype), can be 1, 2, 3, or 4.

---@alias actorclass string this is the class of the actor, can be "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "DEATHKNIGHT", "SHAMAN", "MAGE", "WARLOCK", "MONK", "DRUID", "DEMONHUNTER"
---@alias actorspec number this is the specID of the actor
---@alias uniquecombatid number a unique ID to point to a single combat, each character has its ID counter, use with Details:DoesCombatWithUIDExists(); Details:GetCombatByUID(); retrive with combat:GetCombatUID()

---@alias cleuname string

---@class petinfo : table
---@field key1 ownername
---@field key2 guid
---@field key3 unixtime
---@field key4 boolean
---@field key5 petname
---@field key6 guid

---@class petownerinfo : table
---@field key1 unitname owner name
---@field key2 guid owner guid
---@field key3 controlflags owner flags
---@field key4 unixtime time when the pet was created
---@field key5 boolean true if the pet is part of the player's group
---@field key6 petname pet name
---@field key7 guid pet guid

---@class bossinfo : table .is_boss on combatObjects
---@field diff_string string?
---@field index number?
---@field zone string?
---@field encounter string?
---@field mapid number?
---@field try_number number?
---@field name string?
---@field ej_instance_id number?
---@field id number?
---@field unixtime unixtime?
---@field diff number?
---@field killed boolean?
---@field bossimage texturepath|number?

---@class details_encounter_table
---@field start number gettime() when the encounter started
---@field end number gettime() when the encounter ended
---@field id number the encounter id from encounter_start
---@field name string the encounter name
---@field diff number the difficulty id from encounter_start
---@field size number the raid size from encounter_start
---@field zone string the zone name from getinstanceinfo()
---@field mapid number the zone map id from getinstanceinfo()
---@field phase number the current phase of the encounter
---@field kill boolean if the encounter was a kill or a wipe

---@class details
---@field encounter_table table store the encounter data for the current encounter
---@field boss1_health_percent number store the health percentage (one to zero) of the boss1
---@field pets table<guid, petinfo> store the pet guid as the key and the petinfo as the value
---@field SpellTableMixin spelltablemixin
---@field BreakdownWindowFrame breakdownwindow
---@field PlayerBreakdown table
---@field container_type table<containertype, string> [containertype] = "damage" or "heal" or "energy" or "utility"
---@field TextureAtlas table<atlasname, df_atlasinfo>
---@field playername string
---@field breakdown_general profile_breakdown_settings
---@field DefaultTooltipIconSize number default size of the icons in the tooltip, this also dictates the size of each line in the tooltip
---@field Format fun(self: details, number: number) : string
---@field OpenSpecificBreakdownWindow fun(self: details, combatObject: combat, actorName: string, mainAttribute: number, subAttribute: number)
---@field GetInstanceInfo fun(self: details, id: instanceid|instancename|mapid) : details_instanceinfo
---@field CreatePlayerPortrait fun(self: details, parent: frame, name: string) : frame
---@field GetCurrentEncounterInfo fun(self: details) : details_encounter_table
---@field GetAllInstances fun(self: details) : instance[] return a table with all the instances
---@field GetCoreVersion fun(self: details) : number return the core version, this is used to check API version for scripts and plugins
---@field 
---@field GetItemLevelFromGuid fun(self: details, guid: guid) : number return the item level of the player, if the player is not found, return 0
---@field GenerateActorInfo fun(self: details, actor: actor, errorText:string, bIncludeStack:boolean) : table<string, boolean|string|number> generates a table with the main attributes of the actor, this is mainly for debug purposes
---@field DumpActorInfo fun(self: details, actor: actor) open a window showig the main attributes of an actor, this is mainly for debug purposes
---@field GetDisplayClassByDisplayId fun(self: details, displayId: number) : table -return the class object for the given displayId (attributeId)
---@field GetTextureAtlas fun(self: details, atlasName: atlasname) : df_atlasinfo return the texture atlas data
---@field GetTextureAtlasTable fun(self: details) : table<atlasname, df_atlasinfo>[] return the table with the texture atlas data
---@field Msg fun(self: details, msg: string) print a message to the chat frame
---@field RemoveSegmentByCombatObject fun(self: details, combatObject: combat) : boolean, combat|nil remove the passed combatObject from the segments list
---@field RemoveSegment fun(self: details, segmentIndex: number) : boolean, combat
---@field GetCombatByUID fun(self: details, uniqueCombatId: uniquecombatid) : combat? get a unique combat id and return the combat object
---@field DoesCombatWithUIDExists fun(self: details, uniqueCombatId: uniquecombatid) : boolean
---@field GetOverallCombat fun(self: details) : combat return the overall combat
---@field SetCurrentCombat fun(self: details, combatObject: combat) set the current active combat
---@field GetCurrentCombat fun(self: details) : combat return the current active combat
---@field ResetSegmentData fun(self: details) reset all segments inclusing overall data
---@field ResetSegmentOverallData fun(self: details) reset only the overall data
---@field UpdateBreakdownPlayerList fun(self: details) update the player list in the breakdown window
---@field GetLowerInstanceNumber fun(self: details) : number return the lower instance number
---@field Name fun(self: details|actor, actor:actor?) : string return the name of the actor
---@field SetSpecId fun(self: actor, specId: number) set the specId of the actor
---@field GetOnlyName fun(self: details|actor, string: string?) : string return the name of the player without the realm name
---@field GetRoleIcon fun(self: details, role: role) : string, number, number, number, number return the path to a texture file and the texture coordinates for the given role
---@field GetSpecIcon fun(self: details, spec: number, useAlpha: boolean) : string, number, number, number, number return the path to a texture file and the texture coordinates for the given spec
---@field GetActiveWindowFromBreakdownWindow fun(self: details) : instance return the window (instance) that requested to open the player breakdown window
---@field OpenBreakdownWindow fun(self: details, instanceObject: instance, actorObject: actor, bFromAttributeChange: boolean?, bIsRefresh: boolean?, bIsShiftKeyDown: boolean?, bIsControlKeyDown: boolean?)
---@field GetActorObjectFromBreakdownWindow fun(self: details) : actor return the actor object that is currently shown in the breakdown window
---@field GetDisplayTypeFromBreakdownWindow fun(self: details) : number, number return the attribute and subattribute display type of the breakdown window
---@field GetCombatFromBreakdownWindow fun(self: details) : combat return the combat beaing used in the breakdown window
---@field GetInstance fun(self: details, instanceId: number) : instance return the instance object by its ID
---@field GetWindow fun(self: details) : instance this is an alias of GetInstance
---@field GetCombat fun(self: details, segmentId:any) : combat return the combat object by its segmentId
---@field GetSpellSchoolFormatedName fun(self: details, spellschool: spellschool) : string return the formated name of the spell school
---@field CommaValue fun(self: details, number: number) : string
---@field CreateEventListener fun(self: details) : table
---@field GetFullName fun(self: details, unitId: any, ambiguateString: any) : string create a CLEU compatible name of the unit passed, return string is in the format "playerName-realmName", the string will also be ambiguated using the ambiguateString passed
---@field GetTextColor fun(self:actor, instanceObject: instance, textSide: string) : number, number, number, number
---@field GetCombatSegments fun(self: details) : combat[] return a table with all the combat segments
---@field ListInstances fun(self: details) : instance[] return a table with all the instances
---@field UnpackMythicDungeonInfo fun(self: details, mythicDungeonInfo: mythicdungeoninfo) : boolean, segmentid, number, number, number, string, number, string, number, number, number unpack the mythic dungeon info and return the values
---@field CreateRightClickToCloseLabel fun(self: details, parent: frame) : df_label return a df_label with the text "Right click to close", need to set point
---@field IsValidActor fun(self: details, actor: actor) : boolean return true if the actor is valid
---@field GetCrowdControlSpells fun(self: details) : table<spellid, boolean> return a table of crowd control spells
---@field UnpackDeathTable fun(self: details, deathTable: deathtable) : actorname, actorclass, unixtime, combattime, timestring, number, table, {key1: unixtime, key2: spellid}, specializationid unpack values inside a deathTable, deathEvents is in order or first event in the first index and last event on latest index
---@field UnpackDeathEvent fun(self: details, deathEvent: table) : any, spellid, number, number, number, string, number?, number, boolean, number, boolean, boolean evType, spellId, amount, eventTime, heathPercent, sourceName, absorbed, spellSchool, friendlyFire, overkill, criticalHit, crushing.

---@class detailseventlistener : table
---@field RegisterEvent fun(self: detailseventlistener, event: detailsevent, callback: function)
---@field UnregisterEvent fun(self: detailseventlistener, event: detailsevent)

---@class deathtable : table
---@field key1 any[] what happened to the player before death
---@field key2 number unix time
---@field key3 string player name
---@field key4 string player class
---@field key5 number max health
---@field key6 string time of death as string
---@field dead boolean just a boolean to indicate this is a death table
---@field last_cooldown {key1: unixtime, key2: spellid}
---@field dead_at combattime
---@field spec specializationid

---@class customspellinfo : {name: string, isPassive: boolean, itemId: number, icon: string|number}

---@class customiteminfo: table
---@field itemId number
---@field isPassive boolean?
---@field nameExtra string?
---@field icon string|number|nil
---@field onUse boolean?
---@field isSummon boolean?
---@field castId spellid?
---@field defaultName string?
---@field aura1 spellid?
---@field aura2 spellid?

---@class pvpcombatinfo : table
---@field name string zone name
---@field mapid number zone mapid

---@class arenacombatinfo : table
---@field name string zone name
---@field zone string zone name
---@field mapid number zone mapid

---@class savedspelldata : {key1: number, key2: string, key3: number}
---@class alternatepowertable : {last: number, total: number}

---@class overallsegmentadded : table
---@field name string combat name
---@field elapsed number combat time
---@field clock string start date
---@field type number combat type

---@class combat : table
---@field pvp boolean
---@field data_fim string|number
---@field data_inicio string|number
---@field tempo_start gametime
---@field segments_added overallsegmentadded[]
---@field enemy string the name of the enemy in the combat, can be boss name, encounter name
---@field contra string the name of the player enemy in a 1v1 pvp combat
---@field bossTimers table[] stored timers for bigwigs and dbm
---@field last_events_tables table[] where the death log of each player is stored
---@field boss_hp number percentage of the health points of the boss
---@field training_dummy boolean if true, the combat is against a training dummy
---@field playerTalents table<actorname, string> [playerName] = "talent string"
---@field bossName string? the name of the boss, if the combat has no unitId "boss1", this value is nil
---@field context string? for the context manager
---@field combat_id number
---@field timeStart number time() when the combat started
---@field timeEnd number time() when the combat ended
---@field bloodlust number[]? combat time of when the player received a bloodlust/heroism
---@field bloodlust_overall number[]? exists only in segments that received a merge, uses time()
---@field compressed_charts table store chart data
---@field 
---@field __call table
---@field __index table
---@field zoneName string
---@field mapId number
---@field EncounterName string
---@field bossIcon texturepath|textureid
---@field bIsClosed boolean if true the combat is closed (passed by the EndCombat() function)
---@field __destroyedBy string
---@field amountCasts {[string]: table<string, number>} playername -> spellname -> amount
---@field instance_type instancetype "raid" or "party" or "pvp" or "arena" or "none" or "scenario"
---@field run_time number mythic plus time without death penalties
---@field elapsed_time number mythic plus total time
---@field is_challenge boolean mythic plus challenge mode
---@field total_segments_added number for a mythic+ overall segment, indicates how many segments were added
---@field start_time gametime
---@field end_time gametime
---@field combat_counter number
---@field is_dungeon_overall boolean
---@field combat_type number
---@field is_trash boolean while in raid this is set to true if the combat isn't raid boss, in dungeon this is set to true if the combat isn't a boss or if the dungeon isn't a mythic+
---@field is_boss bossinfo
---@field is_world_trash_combat boolean when true this combat is a regular combat done in the world, not in a dungeon, raid, battleground, arena, ...
---@field is_mythic_dungeon mythicdungeoninfo
---@field is_mythic_dungeon_run_id number
---@field is_mythic_dungeon_segment boolean
---@field is_pvp pvpcombatinfo
---@field is_arena arenacombatinfo
---@field arena boolean
---@field raid_roster table<string, string> [unitName] = unitGUID
---@field overall_added boolean is true when the combat got added into the overall combat
---@field trinketProcs table<actorname, table<spellid, {cooldown: number, total: number}>>
---@field _trashoverallalreadyadded boolean
---@field alternate_power table<actorname, alternatepowertable>
---@field totals {key1: table, key2: table, key3: table, key3: table}
---@field totals_grupo {key1: table, key2: table, key3: table, key3: table}
---@field __destroyed boolean
---@field PhaseData table
---@field player_last_events table<string, table[]> record the latest events of each player, latter used to build the death log
---@field
---@field GetCrowdControlSpells fun(self: combat, actorName: string) : table<spellid, number> return the amount of casts of crowd control spell by an actor
---@field GetCCCastAmount fun(self: combat, actorName: string) : number returns the number of crowd control casts made by the specified actor
---@field GetInterruptCastAmount fun(self: combat, actorName: string) : number
---@field LockActivityTime fun(self: combat)
---@field AddCombat fun(self: combat, givingCombat: combat, bSetStartDate:boolean?, bSetEndDate:boolean?)
---@field CutDeathEventsByTime fun(self: combat, time: number?) remove death events by time, default 10 seconds
---@field GetTotal fun(self: combat, attribute: number, subAttribute: number?, onlyGroup: boolean?) : number return the total amount of the requested attribute
---@field GetCurrentPhase fun(self: combat) : number return the current phase of the combat or the phase where the combat ended
---@field StoreTalents fun(self:combat)
---@field FindEnemyName fun(self: combat) : string attempt to get the name of the enemy in the combat by getting the top most damaged unit by the player
---@field GetTryNumber fun(self: combat) : number?
---@field GetFormattedCombatTime fun(self: combat) : string
---@field GetMSTime fun(self: combat) : number, number
---@field GetSegmentSlotId fun(self: combat) : segmentid
---@field GetCombatName fun(self: combat, bOnlyName: boolean?, bTryFind: boolean?) : string, number?, number?, number?, number? get the name of the combat
---@field GetCombatIcon fun(self: combat) : df_atlasinfo, df_atlasinfo?
---@field GetTrinketProcsForPlayer fun(self: combat, playerName: string) : table<spellid, trinketprocdata> return a key|value table containing the spellId as key and a table with information about the trinket as value
---@field IsMythicDungeon fun(self: combat) : boolean, number return a boolean indicating if the combat is from a mythic+ dungeon, if true, also return the runId
---@field GetMythicDungeonInfo fun(self: combat) : mythicdungeoninfo
---@field GetCombatType fun(self: combat) : number
---@field GetCombatUID fun(self: combat) : uniquecombatid
---@field GetTimeData fun(self: combat, dataName: string) : table
---@field GetPhases fun(self: combat) : table
---@field GetCombatTime fun(self: combat) : number
---@field GetRunTime fun(self: combat) : number return the elapsed time of a mythic+ dungeon run, if not exists, return the combat time
---@field GetRunTimeNoDefault fun(self: combat) : number return the elapsed time of a mythic+ dungeon run, nil if not exists
---@field GetDeaths fun(self: combat) : table --get the table which contains the deaths of the combat
---@field GetStartTime fun(self: combat) : number
---@field SetStartTime fun(self: combat, time: number)
---@field GetEndTime fun(self: combat) : number
---@field GetDifficulty fun(self: combat) : number, string return the dungeon or raid difficulty for boss fights as a number, the string is an english difficulty name in lower case which is not always present
---@field GetEncounterCleuID fun(self: combat) : number return the encounterId for boss fights, this number is gotten from the ENCOUNTER_START event
---@field GetBossInfo fun(self: combat) : bossinfo a table containing many informations about the boss fight
---@field SetEndTime fun(self: combat, time: number)
---@field CopyDeathsFrom fun(combat1: combat, combat2: combat, bMythicPlus: boolean) copy the deaths from combat2 to combat1, use true on bMythicPlus if the combat is from a mythic plus run
---@field GetContainer fun(self: combat, containerType: containertype) : actorcontainer get an actorcontainer, containerType can be 1 for damage, 2 heal, 3 resources, 4 utility
---@field GetSpellCastAmount fun(self: combat, actorName: string, spellName: string) : number get the amount of times a spell was casted
---@field RemoveActorFromSpellCastTable fun(self: combat, actorName: string)
---@field GetSpellCastTable fun(self: combat, actorName: string|nil) : table
---@field GetSpellUptime fun(self: combat, actorName: string, spellId: number, auraType: string|nil) : number get the uptime of a buff or debuff
---@field GetActor fun(self: combat, containerType: number, playerName: string) : actor
---@field CreateAlternatePowerTable fun(self: combat, actorName: string) : alternatepowertable
---@field GetCombatNumber fun(self: combat) : number get a unique number representing the combatId, each combat has a unique number
---@field SetDate fun(self: combat, startDate: string?, endDate: string?) set the start and end date of the combat, format: "H:M:S"
---@field GetDate fun(self: combat) : string, string get the start and end date of the combat, format: "H:M:S"
---@field GetRoster fun(self: combat) : table<string, string> get the roster of the combat, the table contains the names of the players in the combat
---@field GetInstanceType fun(self: combat) : instancetype get the instance type of the combat, can be "raid" or "party" or "pvp" or "arena" or "none"
---@field IsTrash fun(self: combat) : boolean is true if the combat is a trash combat
---@field GetEncounterName fun(self: combat) : string get the name of the encounter
---@field GetBossImage fun(self: combat) : texturepath|textureid get the icon of the encounter
---@field SetDateToNow fun(self: combat, bSetStartDate: boolean?, bSetEndDate: boolean?) set the date to the current time. format: "H:M:S"
---@field GetBossHealth fun(self: combat) : number get the percentage of the boss health when the combat ended
---@field GetBossHealthString fun(self: combat) : string get the percentage of the boss health when the combat ended as a string
---@field GetBossName fun(self: combat) : string? return the name of the unitId "boss1", nil if the unit doesn't existed during the combat

---@class actorcontainer : table contains two tables _ActorTable and _NameIndexTable, the _ActorTable contains the actors, the _NameIndexTable contains the index of the actors in the _ActorTable, making quick to reorder them without causing overhead
---@field need_refresh boolean when true the container is dirty and needs to be refreshed
---@field _ActorTable table a table containing all actors stored in the container
---@field _NameIndexTable table<string, number> [actorName] = actorIndex in the _ActorTable, actorcontainer:Remap() refreshes the _NameIndexTable
---@field GetActor fun(container: actorcontainer, actorName: string) get an actor by its name
---@field GetOrCreateActor fun(container: actorcontainer, actorSerial: guid, actorName: actorname, actorFlags: controlflags, bShouldCreateActor: boolean) get an actor by its name, if the actor doesn't exist it will be created
---@field GetSpellSource fun(container: actorcontainer, spellId: number) get the first actor found which casted the spell
---@field GetAmount fun(container: actorcontainer, actorName: string, key: string) get the amount of actor[key]
---@field GetTotal fun(container: actorcontainer, key: string) get the total amount of actor[key] for all actors
---@field GetTotalOnRaid fun(container: actorcontainer, key: string, combat: combat) get the total amount of actor[key] only for the actors which are in the raid
---@field GetActorTable fun(container: actorcontainer) get the table<actorIndex, actorObject> which contains the actors
---@field ListActors fun(container: actorcontainer) usage: for index, actorObject in container:ListActors() do
---@field RemoveActor fun(container: actorcontainer, actor: actor) remove an actor from the container
---@field GetType fun(container: actorcontainer) : number get the container type, 1 for damage, 2 for heal, 3 for energy, 4 for utility
---@field Remap fun(container: actorcontainer) refreshes the _NameIndexTable part of the container
---@field Cleanup fun(container: actorcontainer) remove all destroyed actors from the container

---@class spellcontainer : table
---@field _ActorTable table store [spellId] = spelltable
---@field GetSpell fun(container: spellcontainer, spellId: number) get a spell by its id, does not create if not found
---@field ListActors fun(container: spellcontainer) : any, any usage: for spellId, spelltable in container:ListActors() do
---@field ListSpells fun(container: spellcontainer) : any, any usage: for spellId, spelltable in container:ListActors() do
---@field HasTwoOrMoreSpells fun(container: spellcontainer) : boolean return true if the container has two or more spells
---@field GetOrCreateSpell fun(self: spellcontainer, spellId: number, bCanCreateSpellIfMissing: boolean|nil, cleuToken: string|nil) : spelltable

---@class friendlyfiretable : table
---@field total number total amount of friendly fire caused by the actor
---@field spells table<spellid, number> spellId = total

---@class spelltable : table
---@field uptime number
---@field total number
---@field spellschool number
---@field counter number amount of hits
---@field c_amt number critical hits by a damage or heal spell
---@field c_min number min damage or healing done by critical hits of the spell
---@field c_max number min damage or healing done by critical hits of the spell
---@field c_total number total damage or heal made by critical hits of the spell
---@field n_amt number normal hits by a damage or heal spell
---@field n_min number min damage or healing done by normal hits of the spell
---@field n_max number min damage or healing done by normal hits of the spell
---@field n_total number total damage or heal made by normal hits of the spell
---@field targets table<string, number> store the [target name] = total value
---@field targets_overheal table<string, number>
---@field targets_absorbs table<string, number>
---@field extra table store extra data
---@field id number --spellid
---@field is_shield boolean --true if the spell is a shield
---@field successful_casted number successful casted times (only for enemies)
---@field g_amt number glacing hits
---@field g_dmg number
---@field r_amt number --resisted
---@field r_dmg number
---@field b_amt number --blocked
---@field b_dmg number
---@field a_amt number --absorved
---@field a_dmg number
---@field e_total number
---@field e_amt number
---@field e_lvl table<number, number>
---@field e_dmg table<number, number>
---@field e_heal table<number, number>
---@field isReflection boolean
---@field totalabsorb number healing absorbed
---@field absorbed number damage absorbed by shield | healing absorbed by buff or debuff
---@field overheal number
---@field totaldenied number

---@class targettable : {[string]: number}

---@class actor : table
---@field owner actor
---@field tipo number the container type
---@field ownerName string name of the owner of the pet, a pet without an owner is considered an orphan and be suitable for garbage collection
---@field pets table<number, string>
---@field arena_enemy boolean if true the actor is an enemy in an arena match
---@field dps_started boolean if true the actor started to do damage or healing
---@field start_time unixtime when this actor started to be tracked
---@field end_time number when this actor stopped to be tracked, end_time - start_time is the activity time of the actor
---@field displayName string actor name shown in the regular window
---@field pvp boolean indicates if the actor is a part of a pvp match
---@field flag_original number original actor flag from what was received in the combat log
---@field debuff_uptime_spells table
---@field buff_uptime_spells table
---@field spells spellcontainer
---@field aID number|string actorID is a realm-playername or npcID
---@field spellicon number|string
---@field cooldowns_defensive_spells table
---@field nome string name of the actor
---@field isTank boolean if true the player had the spec TANK during the combat
---@field serial string
---@field spec number
---@field grupo boolean
---@field classe string
---@field fight_component boolean
---@field boss_fight_component boolean
---@field pvp_component boolean
---@field boss boolean
---@field last_event unixtime
---@field total_without_pet number
---@field total number
---@field total_extra number
---@field last_dps_realtime number
---@field targets targettable
---@field GetSpell fun(actor: actor, spellId: number) : spelltable
---@field BuildSpellTargetFromBreakdownSpellData fun(actor: actor, bkSpellData: spelltableadv) : table
---@field BuildSpellTargetFromSpellTable fun(actor: actor, spellTable: spelltable) : table
---@field raid_targets table<number, number>
---@field IsPlayer fun(actor: actor) : boolean return true if the actor is controlled by a player
---@field IsPetOrGuardian fun(actor: actor) : boolean return true if the actor is a pet or guardian
---@field IsGroupPlayer fun(actor: actor) : boolean return true if the actor is a player in the group (or was in the group during the combat)
---@field GetSpellContainer fun(actor: actor, containerType: "debuff"|"buff"|"spell"|"cooldowns"|"dispel") : spellcontainer
---@field Class fun(actor: actor) : string get the ingame class of the actor
---@field Spec fun(actor: actor) : number get the ingame spec of the actor
---@field Name fun(actor: actor) : string get the name of the actor
---@field Tempo fun(actor: actor) : number get the activity or effective time of the actor
---@field GetPets fun(actor: actor) : table<number, string> get a table with all pet names that belong to the player
---@field GetSpellList fun(actor: actor) : table<number, spelltable>
---@field GetSpellContainerNames fun(container: actorcontainer) : string[] get the table which contains the names of the spell containers
---@field GetDisplayName fun(actor: actor) : string Get the display name of the actor. Display name is often the player name without the realm name.
---@field GetActorSpells fun(actor: actor) : spellcontainer get the spell container of the actor
---@field Pets fun(actor: actor) : petname[] get the pets of the actor
---@field SetSpecId fun(actor: actor, specId: number) set the specId of the actor
---@field 

---@class actordamage : actor
---@field friendlyfire_total number
---@field friendlyfire table<actorname, friendlyfiretable>
---@field damage_taken number amount of damage the actor took during the segment
---@field damage_from table<actorname, boolean> store the name of the actors which damaged the actor, format: [actorName] = true
---@field totalabsorbed number amount of damage dealt by the actor by got absorbed by the target, this is a "ABSORB" type of miss but still counts as damage done
---@field augmentedSpellsContainer spellcontainer

---@class actorheal : actor
---@field healing_taken number amount of healing the actor took during the segment
---@field totalover number amount of healing that was overhealed
---@field totalabsorb number amount of healing that was absorbed
---@field heal_enemy_amt number amount of healing done to enemies this included enemy to enemy heals
---@field totaldenied number amount of healing that was denied by the target - from cleu event SPELL_HEAL_ABSORBED
---@field totalover_without_pet number amount of healing that was overhealed without the pet healing
---@field healing_from table<string, boolean> store the name of the actors which healed the actor, format: [actorName] = true
---@field heal_enemy table<number, number> store the amount of healing done by each spell that landed into an enemy, format: [spellId] = healing done
---@field targets_overheal table<string, number> [targetName] = overheal
---@field targets_absorbs table<string, number> [targetName] = absorbs

---@class actorresource : actor
---@field powertype number power type of the actor
---@field alternatepower number alternate power of the actor

---@class actorutility : actor
---@field cc_break number amount of times the actor broke a cc
---@field interrupt number amount of times the actor interrupted a spell
---@field ress number amount of times the actor ressed a player
---@field dead number amount of times the actor died
---@field cooldowns_defensive number amount of times the actor used a defensive cooldown
---@field buff_uptime number amount of time the actor had a buff
---@field debuff_uptime number amount of time the actor had a debuff
---@field cc_done number amount of times the actor applyed a crowdcontrol on a target
---@field cc_done_targets table<string, number> [targetName] = amount of times the actor cc'd the target
---@field cc_done_spells spellcontainer
---@field dispell number amount of times the actor dispelled a buff or debuff
---@field dispell_spells spellcontainer
---@field dispell_targets table<string, number> [targetName] = amount
---@field dispell_oque table<number, number> [spellId] = amount, amount of times the actor dispelled the spellId
---@field interrompeu_oque table<number, number> [spellId] = amount, amount of times the actor interrupted the spellId
--interrupt_targets interrupt_spells interrompeu_oque
--cc_break_targets cc_break_spells cc_break_oque


---@class segmentid : number
---@class instanceid : number
---@class attributeid : number
---@class modeid : number

---@class instance : table --~i ~instance
---@field segmento segmentid
---@field showing combat
---@field meu_id instanceid
---@field is_interacting boolean
---@field modo modeid
---@field atributo attributeid
---@field sub_atributo attributeid
---@field ativa boolean
---@field freezed boolean
---@field sub_atributo_last table
---@field row_info table
---@field show_interrupt_casts boolean
---@field
---@field
---@field GetActorBySubDisplayAndRank fun(self: instance, displayid: attributeid, subDisplay: attributeid, rank: number) : actor
---@field GetSize fun(instance: instance) : width, height
---@field GetInstanceGroup fun() : table
---@field GetCombat fun(instance: instance)
---@field ChangeIcon fun(instance: instance)
---@field CheckIntegrity fun(instance: instance)
---@field SetMode fun(instance: instance, mode: modeid)
---@field GetMode fun(instance: instance) : modeid
---@field IsInteracting fun(instance: instance) : boolean
---@field IsLowerInstance fun(instance: instance) : boolean
---@field IsEnabled fun(instance: instance) : boolean
---@field GetId fun(instance: instance) : instanceid
---@field SetSegmentId fun(instance: instance, segment: segmentid) set the segmentId for the instance and nothing else, use 'SetSegment' for a full update
---@field GetSegmentId fun(instance: instance) : segmentid
---@field RefreshCombat fun(instance: instance)
---@field Freeze fun(instance: instance)
---@field UnFreeze fun(instance: instance)
---@field SetSegment fun(instance: instance, segment: segmentid, force: boolean|nil)
---@field SetDisplay fun(instance: instance, segmentId: segmentid?, attributeId: attributeid?, subAttributeId: attributeid?, modeId: modeid?)
---@field GetDisplay fun(instance: instance) : attributeid, attributeid
---@field IsShowing fun(instance: instance, segmentId: segmentid, displayId: attributeid, subDisplayId: attributeid) : boolean
---@field ResetWindow fun(instance: instance, resetType: number|nil, segmentId: segmentid|nil)
---@field RefreshData fun(instance: instance, force: boolean|nil)
---@field RefreshWindow fun(instance: instance, force: boolean|nil)

---@class trinketdata : table
---@field itemName string
---@field spellName string
---@field lastActivation number
---@field lastPlayerName string
---@field totalCooldownTime number
---@field activations number
---@field lastCombatId number
---@field minTime number
---@field maxTime number
---@field averageTime number

---@class trinketprocdata : table
---@field cooldown number
---@field total number

---@class tabframe : frame this is the tab frame object for the breakdown window

---@class breakdownwindow : frame
---@field shownPluginObject table
---@field BreakdownSideMenuFrame frame frame attached to the left or right side of the breakdown window
---@field BreakdownPluginSelectionFrame frame frame which has buttons to select a plugin to show in the breakdown window
---@field BreakdownTabsFrame frame where the tab buttons are located (parent frame)
---@field RegisteredPluginButtons button[] table which contains plugins buttons that are registered to the breakdown window
---@field PlayerSelectionHeader df_headerframe
---@field RefreshPlayerScroll fun() refresh the player scroll frame (shown in the left side of the breakdown window)
---@field RegisterPluginButton fun(button: button, pluginObject: table, pluginAbsolutename: string) register a plugin button to the breakdown window
---@field GetShownPluginObject fun() : table get the plugin object that is currently shown in the breakdown window

---@class breakdownscrolldata : table
---@field totalValue number total done by the actor
---@field combatTime number
---@field [spelltableadv] spelltableadv indexed part of the table

---@class headercolumndatasaved : {enabled: boolean, width: number, align: string}

---@class breakdownexpandbutton : button
---@field texture texture

---@class breakdownsegmentline : button
---@field segmentText df_label
---@field segmentIcon df_image
---@field segmentSubIcon df_image
---@field UpdateLine function
---@field combatUniqueID uniquecombatid
---@field isSelected boolean

---@class breakdownsegmentdata
---@field UID uniquecombatid
---@field combatName string
---@field combatIcon df_atlasinfo
---@field combatIcon2 df_atlasinfo? used for the second icon in the segment line, this shows the trash or boss icon where the primary icon shows the mythic+ icon for example
---@field r number
---@field g number
---@field b number

---has formartted data to use while reporting data from the breakdown
---@class breakdownreportdata : table
---@field name string
---@field amount string
---@field percent string

---@class breakdownreporttable : table contains 'title' with a string as title of the report and in the indexed part breakdownreporttable[]
---@field title string the title of the report to send before the report data

---@class breakdownspellscrollframe : df_scrollboxmixin, scrollframe
---@field Header df_headerframe
---@field SortKey string
---@field SortOrder string
---@field RefreshMe fun(scrollFrame: breakdownspellscrollframe, data: table|nil)
---@field GetReportData fun(scrollFrame: breakdownphasescrollframe) : breakdownreportdata[]

---@class breakdowntargetscrollframe : df_scrollboxmixin, scrollframe
---@field Header df_headerframe
---@field RefreshMe fun(scrollFrame: breakdowntargetscrollframe, data: table|nil)
---@field GetReportData fun(scrollFrame: breakdownphasescrollframe) : breakdownreportdata[]

---@class breakdowngenericscrollframe : df_scrollboxmixin, scrollframe
---@field Header df_headerframe
---@field RefreshMe fun(scrollFrame: breakdowngenericscrollframe, data: table|nil)

---@class breakdownphasescrollframe : df_scrollboxmixin, scrollframe
---@field Header df_headerframe
---@field RefreshMe fun(scrollFrame: breakdownphasescrollframe, data: table|nil)
---@field GetReportData fun(scrollFrame: breakdownphasescrollframe) : breakdownreportdata[]

---@class breakdownphasebar : button, df_headerfunctions
---@field index number
---@field Icon texture
---@field InLineTexts fontstring[]
---@field statusBar breakdownspellbarstatusbar

---@class breakdowngenericbar : button, df_headerfunctions
---@field index number
---@field rank number
---@field name string
---@field percent number
---@field amount number
---@field total number
---@field actorName string
---@field spellId number?
---@field Icon texture
---@field IconFrame frame
---@field InLineTexts fontstring[]
---@field statusBar breakdownspellbarstatusbar
---@field overlayTexture texture
---@field bIsFromLeftScroll boolean
---@field bIsFromRightScroll boolean

---@class breakdowntargetbar : button, df_headerfunctions
---@field index number
---@field rank number
---@field name string
---@field percent number
---@field amount number
---@field total number
---@field actorName string
---@field bkTargetData breakdowntargettable
---@field Icon texture
---@field InLineTexts fontstring[]
---@field statusBar breakdownspellbarstatusbar

---@class breakdownspellbar : button, df_headerfunctions
---@field index number
---@field rank number
---@field spellId number
---@field name string
---@field combatTime number
---@field perSecond number
---@field percent number
---@field amountCasts number
---@field average number
---@field castAverage number
---@field onMouseUpTime number GetTime() of when the spellbar got OnMouseUp event
---@field cursorPosX number mouse position when the spellbar got OnMouseDown event
---@field cursorPosY number mouse position when the spellbar got OnMouseDown event
---@field spellTable spelltable
---@field bkSpellData spelltableadv
---@field statusBar breakdownspellbarstatusbar
---@field expandButton breakdownexpandbutton
---@field spellIconFrame frame
---@field spellIcon texture
---@field targetsSquareFrame breakdowntargetframe
---@field targetsSquareTexture texture
---@field overlayTexture texture
---@field bIsExpandedSpell boolean
---@field ExpandedChildren breakdownspellbar[] store the spellbars which are expanded from this spellbar (spellbars shown when the expand button is pressed)
---@field InLineTexts fontstring[]

---@class breakdownspellbarstatusbar : statusbar
---@field backgroundTexture texture
---@field overlayTexture texture
---@field highlightTexture texture

---spelltableadv is similar to spelltable but allow custom members, methods and any modification isn't save to saved variables
---@class spelltableadv : spelltable, spelltablemixin
---@field expanded boolean? if is true the show the nested spells
---@field spellTables spelltable[]
---@field nestedData bknesteddata[]
---@field bCanExpand boolean
---@field expandedIndex number?
---@field bIsExpanded boolean?
---@field statusBarValue number?
---@field npcId any
---@field actorName string? --when showing an actor header, this is the actor name
---@field bIsActorHeader boolean? if this is true, the spellbar is an actor header, which is a bar with the actor name with the actor spells nested
---@field actorIcon textureid|texturepath?

---@class bknesteddata : {spellId: number, spellTable: spelltable, actorName: string, value: number, bIsActorHeader: boolean} fills .nestedData table in spelltableadv, used to store the nested spells data, 'value' is set when the breakdown sort the values by the selected header

---@class breakdowntargetframe : frame
---@field spellId number
---@field bkSpellData spelltableadv
---@field spellTable spelltable
---@field texture texture
---@field bIsMainLine boolean

---@class breakdowntargettablelist : breakdowntargettable[]
---@field totalValue number
---@field totalValueOverheal number
---@field combatTime number

---@class breakdowntargettable : table
---@field name string
---@field total number
---@field overheal number|nil
---@field absorbed number|nil
---@field statusBarValue number

---@class breakdownspelldatalist : spelltableadv[]
---@field totalValue number
---@field combatTime number

---@class breakdownspellstab : tabframe
---@field SpellScrollFrame breakdownspellscrollframe
---@field SpellBlockFrame breakdownspellblockframe

---@class breakdownspellblockframe : frame container for the spellblocks in the breakdown window
---@field SpellBlocks breakdownspellblock[] array of spellblocks
---@field blocksInUse number number of blocks currently in use
---@field UpdateBlocks fun(self: breakdownspellblockframe) update the blocks
---@field ClearBlocks fun(self: breakdownspellblockframe) clear all blocks
---@field GetBlock fun(self: breakdownspellblockframe, index: number) : breakdownspellblock return the block at the index
---@field GetBlocksInUse fun(self: breakdownspellblockframe) : number return the number of blocks currently in use
---@field GetBlocksAmount fun(self: breakdownspellblockframe) : number return the total blocks created
---@field ShowEmptyBlock fun(self: breakdownspellblockframe, index: number) show the empty block

---@class breakdownspellblock : statusbar breakdownspellblock object which is created inside the breakdownspellblockframe
---@field Lines breakdownspellblockline[]
---@field reportButton button
---@field overlay texture
---@field statusBarTexture texture
---@field sparkTexture texture
---@field gradientTexture texture
---@field backgroundTexture texture
---@field GetLine fun(self: breakdownspellblock, index: number) : breakdownspellblockline
---@field GetLines fun(self: breakdownspellblock) : breakdownspellblockline, breakdownspellblockline, breakdownspellblockline
---@field SetColor fun(self: breakdownspellblock, r: any, g: number|nil, b: number|nil, a: number|nil)

---@class breakdownspellblockline : frame a line inside a breakdownspellblock, there's 3 of them in each breakdownspellblock
---@field leftText fontstring
---@field centerText fontstring
---@field rightText fontstring

---@class reportoverlaybutton : button
---@field scrollFrame df_scrollbox
---@field reportText fontstring
---@field backgroundTexture texture

---@class breakdownspelltab
---@field selectedSpellBar breakdownspellbar
---@field TabFrame breakdownspellstab
---@field mainAttribute number
---@field subAttribute number
---@field TargetScrollFrame breakdowntargetscrollframe
---@field PhaseScrollFrame breakdownphasescrollframe
---@field GenericScrollFrameLeft breakdowngenericscrollframe
---@field GenericScrollFrameRight breakdowngenericscrollframe
---@field SpellContainerFrame df_framecontainer
---@field BlocksContainerFrame df_framecontainer
---@field TargetsContainerFrame df_framecontainer
---@field PhaseContainerFrame df_framecontainer
---@field GenericContainerFrameLeft df_framecontainer
---@field GenericContainerFrameRight df_framecontainer
---@field ReportOverlays reportoverlaybutton[]
---@field GetActor fun() : actor
---@field GetCombat fun() : combat
---@field GetInstance fun() : instance
---@field GetSpellScrollFrame fun() : breakdownspellscrollframe
---@field GetSpellBlockFrame fun() : breakdownspellblockframe
---@field GetTargetScrollFrame fun() : breakdowntargetscrollframe
---@field GetSpellScrollContainer fun() : df_framecontainer
---@field GetSpellBlockContainer fun() : df_framecontainer
---@field GetTargetScrollContainer fun() : df_framecontainer
---@field OnProfileChange fun()
---@field UpdateHeadersSettings fun(containerType: string)
---@field BuildHeaderTable fun(containerType: string) : {name: string, width: number, text: string, align: string}[]
---@field SelectSpellBar fun(spellBar: breakdownspellbar)
---@field UnSelectSpellBar fun()
---@field GetSelectedSpellBar fun() : breakdownspellbar
---@field HasSelectedSpellBar fun() : boolean
---@field OnShownTab fun()
---@field OnCreateTabCallback fun(tabButton: button, tabFrame: frame)
---@field CreateSpellBlock fun(spellBlockContainer: breakdownspellblockframe, index: number) : breakdownspellblock
---@field CreateSpellBlockContainer fun(tabFrame: tabframe) : breakdownspellblockframe
---@field UpdateShownSpellBlock fun()
---@field CreateTargetContainer fun(tabFrame: tabframe) : breakdowntargetscrollframe
---@field CreateGenericContainers fun(tabFrame: tabframe) : breakdowngenericscrollframe, breakdowngenericscrollframe
---@field CreateSpellScrollContainer fun(tabFrame: tabframe) : breakdownspellscrollframe
---@field CreateTargetBar fun(self: breakdowntargetscrollframe, index: number) : breakdowntargetbar
---@field CreateSpellBar fun(self: breakdownspellscrollframe, index: number) : breakdownspellbar
---@field SetShownReportOverlay fun(bIsShown: boolean)

---@class details_encounterinfo : table
---@field name string
---@field mapId number
---@field instanceId number
---@field dungeonEncounterId number
---@field journalEncounterId number
---@field journalInstanceId number
---@field creatureName string
---@field creatureIcon string
---@field creatureId number
---@field creatureDisplayId number
---@field creatureUIModelSceneId number

---@class details_instanceinfo : table
---@field name string
---@field bgImage string
---@field mapId number
---@field instanceId number
---@field journalInstanceId number
---@field encountersArray details_encounterinfo[]
---@field encountersByName table<string, details_encounterinfo>
---@field encountersByDungeonEncounterId table<number, details_encounterinfo>
---@field encountersByJournalEncounterId table<number, details_encounterinfo>
---@field icon string
---@field iconSize table<number, number>
---@field iconCoords table<number, number, number, number>
---@field iconLore string
---@field iconLoreSize table<number, number>
---@field iconLoreCoords table<number, number, number, number>
---@field iconTexture string
---@field iconTextureSize table<number, number>
---@field iconTextureCoords table<number, number, number, number>

---@class timemachine : table
---@field Ticker fun() runs each second and check if actors are performing damage and healing actions, if the actor isn't, stop the activity time of that actor
---@field Start fun() start the time machine, called once from the start.lua
---@field Cleanup fun() check for actors with __destroyed flag and remove them from the time machine
---@field Restart fun() reset all data inside the time machine
---@field AddActor fun(actor: actor) add the actor to the time machine
---@field RemoveActor fun(actor: actor) remove the actor from the time machine
---@field StopTime fun(actor: actor) stop the time of the actor
---@field SetOrGetPauseState fun(actor: actor, bPause: boolean|nil) : boolean|nil set or get the pause state of the actor, if bPause is nil, then it will return the current pause state

---@class instancedifficulty : table
---@field DungeonNormal number
---@field DungeonHeroic number
---@field DungeonMythic number
---@field DungeonMythicPlus number
---@field RaidLFR number
---@field RaidNormal number
---@field RaidHeroic number
---@field RaidMythic number


---@class details222 : table
---@field TimeMachine timemachine
---@field PetContainer petcontainer
---@field InstanceDifficulty instancedifficulty
---@field ContextManager contextmanager

---@class profile_breakdown_settings : table
---@field font_size number
---@field font_color color
---@field font_outline outline
---@field font_face string

---@class animatedtexture : texture, df_frameshake
---@field CreateRandomBounceSettings function
---@field BounceFrameShake df_frameshake

---@class playerbanner : frame
---@field index number
---@field BackgroundBannerMaskTexture texture
---@field BackgroundBannerGradient texture
---@field FadeInAnimation animationgroup
---@field BackgroundShowAnim animationgroup
---@field DungeonBackdropShowAnim animationgroup
---@field BackgroundGradientAnim animationgroup
---@field BackgroundBannerFlashTextureColorAnimation animationgroup
---@field BounceFrameShake df_frameshake
---@field NextLootSquare number
---@field LootSquares details_lootsquare[]
---@field LevelUpFrame frame
---@field LevelUpTextFrame frame
---@field WaitingForLootLabel df_label
---@field RantingLabel df_label
---@field LevelFontString fontstring
---@field KeyStoneDungeonTexture texture
---@field DungeonBorderTexture texture
---@field FlashTexture texture
---@field LootSquare frame
---@field LootIcon texture
---@field LootIconBorder texture
---@field LootItemLevel fontstring
---@field unitId string
---@field unitName string
---@field PlayerNameFontString fontstring
---@field PlayerNameBackgroundTexture texture
---@field DungeonBackdropTexture texture
---@field BackgroundBannerTexture animatedtexture
---@field BackgroundBannerFlashTexture animatedtexture
---@field RoleIcon texture
---@field Portrait texture
---@field Border texture
---@field Name fontstring
---@field AnimIn animationgroup
---@field AnimOut animationgroup
---@field StartTextDotAnimation fun(self:playerbanner)
---@field StopTextDotAnimation fun(self:playerbanner)
---@field ClearLootSquares fun(self:playerbanner)
---@field GetLootSquare fun(self:playerbanner):details_lootsquare

---@class details_lootsquare : frame
---@field LootIcon texture
---@field LootIconBorder texture
---@field LootItemLevel fontstring
---@field LootItemLevelBackgroundTexture texture
---@field itemLink string
---@field ShadowTexture texture

---@class details_loot_cache : table
---@field playerName string
---@field itemLink string
---@field effectiveILvl number
---@field itemQuality number
---@field itemID number
---@field time number

---@class lootframe : frame
---@field LootCache details_loot_cache[]

---@class details_mplus_endframe : frame
---@field unitCacheByName playerbanner[]
---@field entryAnimationDuration number
---@field AutoCloseTimeBar df_timebar
---@field OpeningAnimation animationgroup
---@field HeaderFadeInAnimation animationgroup
---@field HeaderTexture texture
---@field TopFrame frame
---@field ContentFrame frame
---@field ContentFrameFadeInAnimation animationgroup
---@field YellowSpikeCircle texture
---@field YellowFlash texture
---@field Level fontstring
---@field leftFiligree texture
---@field rightFiligree texture
---@field bottomFiligree texture
---@field CloseButton df_closebutton
---@field ConfigButton df_button
---@field ShowBreakdownButton df_button
---@field ShowChartButton df_button
---@field PlayerBanners playerbanner[]
---@field YouBeatTheTimerLabel fontstring
---@field RantingLabel df_label
---@field ElapsedTimeIcon texture
---@field ElapsedTimeText fontstring
---@field OutOfCombatIcon texture
---@field OutOfCombatText fontstring
---@field SandTimeIcon texture
---@field KeylevelText fontstring
---@field StrongArmIcon texture