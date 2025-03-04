
---@alias openraid_unitname string the name of the unit including realm name if the unit isn't from the same realm, e.g. "Unitname-Realmname"
---@alias openraid_spellid number the id of a spell

---@alias openraid_cooldownfilter
---| "defensive-raid"
---| "defensive-target"
---| "defensive-personal"
---| "ofensive"
---| "utility"
---| "interrupt"
---| "itemutil"
---| "itemheal"
---| "itempower"
---| "crowdcontrol"

---@class openraid : table
---@field RequestAllData fun() send a request to all players in the group to send their data
---@field GetUnitInfo fun(unitId: string) : openraid_unitinfo return a table containing information of a single unit
---@field GetAllUnitsInfo fun() : table<openraid_unitname, openraid_unitinfo> return a table containing all information of units
---@field GetUnitGear fun(unitId: string) : openraid_unitgear return a table containing gear information of a single unit
---@field GetAllUnitsGear fun() : table<openraid_unitname, openraid_unitgear> return a table containing all gear information of units
---@field GetUnitCooldowns fun(unitId: string, filter:string?) : table<openraid_spellid, openraid_cooldowninfo> return a table containing cooldown information of a single unit
---@field GetAllUnitsCooldown fun() : table<openraid_unitname, table<openraid_spellid, openraid_cooldowninfo>> return a table containing all cooldown information of units
---@field DoesSpellPassFilters fun(spellId: openraid_spellid, filter: openraid_cooldownfilter) : boolean check if a spell passes the filter

---@class openraid_cooldowninfo : table
---@field [1] number timeLeft
---@field [2] number charges
---@field [3] number startOffset
---@field [4] number duration
---@field [5] number updateTime, when the cooldown received an update from the unit
---@field [6] number auraDuration

---@class openraid_unitinfo : table
---@field specId number
---@field specName string
---@field role string
---@field renown number
---@field covenantId number
---@field talents table
---@field conduits table
---@field pvpTalents table
---@field class string
---@field classId number
---@field className string
---@field name string
---@field nameFull string

---@class openraid_unitgear : table
---@field itemLevel number
---@field durability number overall percentage durability of the gear
---@field weaponEnchant number
---@field noGems table
---@field noEnchants table
---@field mainHandEnchantId number
---@field offHandEnchantId number
---@field equippedGear openraid_iteminfo[]

---@class openraid_iteminfo : table
---@field slotId number
---@field gemSlots number
---@field itemLevel number
---@field itemLink string
---@field itemQuality number
---@field itemId number
---@field itemName string
---@field isTier boolean
---@field enchantId number
---@field gemId number
