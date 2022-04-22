

if (not LIB_OPEN_RAID_CAN_LOAD) then
	return
end

local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0")

--> deprecated: 'RequestAllPlayersInfo' has been replaced by 'RequestAllData'
    function openRaidLib.RequestAllPlayersInfo()
        openRaidLib.DeprecatedMessage("openRaidLib.RequestAllPlayersInfo() is deprecated, please use openRaidLib.RequestAllData().")
    end

--> deprecated: 'playerInfoManager' has been replaced by 'UnitInfoManager'
    openRaidLib.playerInfoManager = {}
    local deprecatedMetatable = {
        __newindex = function()
            openRaidLib.DeprecatedMessage("openRaidLib.playerInfoManager table is deprecated, please use openRaidLib.UnitInfoManager.")
            return
        end,
        __index = function(t, key)
            return rawget(t, key) or openRaidLib.DeprecatedMessage("openRaidLib.playerInfoManager table is deprecated, please use openRaidLib.UnitInfoManager.")
        end,
    }
    function openRaidLib.playerInfoManager.GetPlayerInfo()
        openRaidLib.DeprecatedMessage("openRaidLib.playerInfoManager.GetPlayerInfo(unitName) is deprecated, please use openRaidLib.GetUnitInfo(unitId).")
    end
    function openRaidLib.playerInfoManager.GetAllPlayersInfo()
        openRaidLib.DeprecatedMessage("openRaidLib.playerInfoManager.GetAllPlayersInfo() is deprecated, please use openRaidLib.GetAllUnitsInfo().")
    end
    setmetatable(openRaidLib.playerInfoManager, deprecatedMetatable)

--> deprecated: 'gearManager' has been replaced by 'GearManager'
    openRaidLib.gearManager = {}
    local deprecatedMetatable = {
        __newindex = function()
            openRaidLib.DeprecatedMessage("openRaidLib.gearManager table is deprecated, please use openRaidLib.GearManager (the G is in upper case).")
            return
        end,
        __index = function(t, key)
            return rawget(t, key) or openRaidLib.DeprecatedMessage("openRaidLib.gearManager table is deprecated, please use openRaidLib.GearManager (the G is in upper case).")
        end,
    }
    function openRaidLib.gearManager.GetAllPlayersGear()
        openRaidLib.DeprecatedMessage("openRaidLib.gearManager.GetAllPlayersGear() is deprecated, please use openRaidLib.GetAllUnitsGear().")
    end
    function openRaidLib.gearManager.GetPlayerGear()
        openRaidLib.DeprecatedMessage("openRaidLib.gearManager.GetPlayerGear() is deprecated, please use openRaidLib.GetUnitGear(unitId).")
    end
    setmetatable(openRaidLib.gearManager, deprecatedMetatable)

--> deprecated: 'cooldownManager' has been replaced by 'CooldownManager'
    openRaidLib.cooldownManager = {}
    local deprecatedMetatable = {
        __newindex = function()
            openRaidLib.DeprecatedMessage("openRaidLib.cooldownManager table is deprecated, please use openRaidLib.CooldownManager (the C is in upper case).")
            return
        end,
        __index = function(t, key)
            return rawget(t, key) or openRaidLib.DeprecatedMessage("openRaidLib.cooldownManager table is deprecated, please use openRaidLib.CooldownManager (the C is in upper case).")
        end,
    }
    function openRaidLib.cooldownManager.GetAllPlayersCooldown()
        openRaidLib.DeprecatedMessage("openRaidLib.cooldownManager.GetAllPlayersCooldown() is deprecated, please use openRaidLib.GetAllUnitsCooldown().")
    end
    function openRaidLib.cooldownManager.GetPlayerCooldowns()
        openRaidLib.DeprecatedMessage("openRaidLib.cooldownManager.GetPlayerCooldowns() is deprecated, please use openRaidLib.GetUnitCooldowns(unitId).")
    end
    setmetatable(openRaidLib.cooldownManager, deprecatedMetatable)