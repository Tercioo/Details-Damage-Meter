---@class combat : table
---@field GetCombatTime fun(combat)
---@field GetDeaths fun(combat) --get the table which contains the deaths of the combat
---@field end_time number
---@field start_time number
---@field GetStartTime fun(combat: combat, time: number)
---@field SetStartTime fun(combat: combat, time: number)
---@field GetEndTime fun(combat: combat, time: number)
---@field SetEndTime fun(combat: combat, time: number)
---@field CopyDeathsFrom fun(combat1: combat, combat2: combat, bMythicPlus: boolean)

---@class actorcontainer : table
---@field _ActorTable table

---@class spellcontainer : table
---@field _ActorTable table

---@class spelltable : table

---@class actor : table
---@field debuff_uptime_spells table
---@field buff_uptime_spells table
---@field spells table
---@field cooldowns_defensive_spells table








