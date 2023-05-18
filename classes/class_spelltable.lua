
local addonName, Details222 = ...
local Details = Details
local detailsFramework = DetailsFramework

--this are the fields from spellTable that can be summed
local spellTable_FieldsToSum = {
	["counter"] = true,
	["total"] = true,
	["c_amt"] = true,
	["c_min"] = true,
	["c_max"] = true,
	["c_total"] = true,
	["n_amt"] = true,
	["n_total"] = true,
	["n_min"] = true,
	["n_max"] = true,
	["successful_casted"] = true,
	["g_amt"] = true,
	["g_dmg"] = true,
	["r_amt"] = true,
	["r_dmg"] = true,
	["b_amt"] = true,
	["b_dmg"] = true,
	["a_amt"] = true,
	["a_dmg"] = true,
	["totalabsorb"] = true,
	["absorbed"] = true,
	["overheal"] = true,
	["totaldenied"] = true,
    ["e_amt"] = true,
    ["e_dmg"] = true,
    ["e_heal"] = true,
    ["e_lvl"] = true,
    ["e_total"] = true,
    ["DODGE"] = true,
    ["PARRY"] = true,
    ["MISS"] = true,
}

---@class spelltablemixin
---@field GetCritPercent fun(spellTable: spelltable) : number
---@field GetCritAverage fun(spellTable: spelltable) : number
---@field GetCastAmount fun(spellTable: spelltable, actorName: string, combatObject: combat)
---@field GetCastAverage fun(spellTable: spelltable, castAmount: number)
---@field SumSpellTables fun(spellTables: spelltable[], targetTable: table)

Details.SpellTableMixin = {
    ---return the critical hits percent
    ---@param spellTable spelltable
    ---@return number
    GetCritPercent = function(spellTable)
        return (spellTable.c_amt / math.max(spellTable.counter, 0.0001)) * 100
    end,

    ---return the average value of critical hits
    ---@param spellTable spelltable
    ---@return number
    GetCritAverage = function(spellTable)
        return spellTable.c_total / math.max(spellTable.c_amt, 0.0001)
    end,

    ---return the amount of casts the spell had
    ---@param spellTable spelltable
    ---@param actorName string
    ---@param combatObject combat
    ---@return number
    GetCastAmount = function(spellTable, actorName, combatObject)
        local spellName = GetSpellInfo(spellTable.id)
        return combatObject:GetSpellCastAmount(actorName, spellName)
    end,

    ---return the average damage per cast
    ---@param spellTable spelltable
    ---@param castAmount number
    ---@return number
    GetCastAverage = function(spellTable, castAmount)
        if (castAmount > 0) then
            return spellTable.total / castAmount
        end
        return 0
    end,

    ---get the array of spelltables and sum each spellTable with the first spellTable found or on targetTable
    ---only sum the keys found in the spellTable_FieldsToSum table
    ---@param spellTables spelltable[]
    ---@param targetTable table
    SumSpellTables = function(spellTables, targetTable)
        local amtSpellTables = #spellTables

        if (amtSpellTables == 0) then
            return
        end

        targetTable = targetTable or spellTables[1]

        for i = 1, amtSpellTables do
            local spellTable = spellTables[i]
            if (spellTable) then
                for key, value in pairs(spellTable) do
                    if (spellTable_FieldsToSum[key]) then
                        --evoker empowerment levels
                        if (key == "e_lvl" or key == "e_heal" or key == "e_dmg") then
                            targetTable[key] = targetTable[key] or {}
                            for level, amount in pairs(value) do
                                targetTable[key][level] = (targetTable[key][level] or 0) + amount
                            end

                        elseif (key == "c_max" or key == "n_max") then
                            targetTable[key] = math.max(targetTable[key] or value, value)

                        elseif (key == "c_min" or key == "n_min") then
                            targetTable[key] = math.min(targetTable[key] or value, value)

                        else
                            targetTable[key] = (targetTable[key] or 0) + value
                        end
                    end
                end
            end
        end
    end,
}

--detailsFramework:Mixin(Details, Details.SpellTableMixin)