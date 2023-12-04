local detailsFramework = _G ["DetailsFramework"]
if (not detailsFramework) then
	return
end

local IS_WOW_PROJECT_MAINLINE = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_NOT_MAINLINE = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_CLASSIC_ERA = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

detailsFramework.CastInfo = detailsFramework.CastInfo or {}

--NOTE: This NEEDs a chance to run, as Plater is depending on this working and LibCC is not bundled neccessarily in other addons.
-- for classic era use LibClassicCasterino:

--in vanilla wow, other addons might load the framework before an addon with libCasterino loads
--check here if libCasterino is loaded, if is, check if the framework is already using libCasterino, if not, make it use
function detailsFramework:LoadLCC(LibCC)
	local fCast = CreateFrame("frame")

	local getCastBar = function(unitId)
		local plateFrame = C_NamePlate.GetNamePlateForUnit (unitId)
		if (not plateFrame) then
			return
		end

		local castBar = plateFrame.unitFrame and plateFrame.unitFrame.castBar
		if (not castBar) then
			return
		end

		return castBar
	end

	local triggerCastEvent = function(castBar, event, unitId, ...)
		if (castBar and castBar.OnEvent) then
			return castBar.OnEvent (castBar, event, unitId)
		end
	end

	local funcCast = function(event, unitId, ...)
		local castBar = getCastBar (unitId)
		if (castBar) then
			return triggerCastEvent (castBar, event, unitId)
		end
	end

	fCast.UNIT_SPELLCAST_START = function(self, event, unitId, ...)
		return triggerCastEvent (getCastBar (unitId), event, unitId)
	end

	fCast.UNIT_SPELLCAST_STOP = function(self, event, unitId, ...)
		return triggerCastEvent (getCastBar (unitId), event, unitId)
	end

	fCast.UNIT_SPELLCAST_DELAYED = function(self, event, unitId, ...)
		return triggerCastEvent (getCastBar (unitId), event, unitId)
	end

	fCast.UNIT_SPELLCAST_FAILED = function(self, event, unitId, ...)
		return triggerCastEvent (getCastBar (unitId), event, unitId)
	end

	fCast.UNIT_SPELLCAST_INTERRUPTED = function(self, event, unitId, ...)
		return triggerCastEvent (getCastBar (unitId), event, unitId)
	end

	fCast.UNIT_SPELLCAST_CHANNEL_START = function(self, event, unitId, ...)
		return triggerCastEvent (getCastBar (unitId), event, unitId)
	end

	fCast.UNIT_SPELLCAST_CHANNEL_UPDATE = function(self, event, unitId, ...)
		return triggerCastEvent (getCastBar (unitId), event, unitId)
	end

	fCast.UNIT_SPELLCAST_CHANNEL_STOP = function(self, event, unitId, ...)
		return triggerCastEvent (getCastBar (unitId), event, unitId)
	end

	LibCC.RegisterCallback(fCast,"UNIT_SPELLCAST_START", funcCast)
	LibCC.RegisterCallback(fCast,"UNIT_SPELLCAST_DELAYED", funcCast) -- only for player
	LibCC.RegisterCallback(fCast,"UNIT_SPELLCAST_STOP", funcCast)
	LibCC.RegisterCallback(fCast,"UNIT_SPELLCAST_FAILED", funcCast)
	LibCC.RegisterCallback(fCast,"UNIT_SPELLCAST_INTERRUPTED", funcCast)
	LibCC.RegisterCallback(fCast,"UNIT_SPELLCAST_CHANNEL_START", funcCast)
	LibCC.RegisterCallback(fCast,"UNIT_SPELLCAST_CHANNEL_UPDATE", funcCast) -- only for player
	LibCC.RegisterCallback(fCast,"UNIT_SPELLCAST_CHANNEL_STOP", funcCast)

	detailsFramework.CastInfo.UnitCastingInfo = function(unit)
		return LibCC:UnitCastingInfo (unit)
	end

	detailsFramework.CastInfo.UnitChannelInfo = function(unit)
		return LibCC:UnitChannelInfo (unit)
	end
end

if IS_WOW_PROJECT_CLASSIC_ERA and false then --disable this for now, as it appears to be working now through API changes...
	local LibCC = LibStub("LibClassicCasterino", true)
	if (LibCC and not _G.DetailsFrameworkLCCLoaded) then
		detailsFramework:LoadLCC(LibCC)
		_G.DetailsFrameworkLCCLoaded = true

	elseif not LibCC then
		detailsFramework.CastInfo.UnitCastingInfo = CastingInfo
		detailsFramework.CastInfo.UnitChannelInfo = ChannelInfo
	end
else -- end classic era

	detailsFramework.CastInfo.UnitCastingInfo = UnitCastingInfo
	detailsFramework.CastInfo.UnitChannelInfo = UnitChannelInfo
end


if (not DetailsFrameworkCanLoad) then
	return
end