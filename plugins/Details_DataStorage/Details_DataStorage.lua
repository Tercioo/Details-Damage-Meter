
DETAILS_STORAGE_VERSION = 7

function Details:CreateStorageDB()
	DetailsDataStorage = {
		VERSION = DETAILS_STORAGE_VERSION,
		normal = {}, --raid difficulties
		heroic = {}, --raid difficulties
		mythic = {}, --raid difficulties
		--[14] = {}, --normal mode (raid)
		--[15] = {}, --heroic mode (raid)
		--[16] = {}, --mythic mode (raid)
		["totalkills"] = {},
		["mythic_plus"] = {}, --(dungeons)
		["saved_encounters"] = {}, --(a segment)
	}
	return DetailsDataStorage
end

local f = CreateFrame("frame", nil, UIParent)
f:Hide()
f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent", function(self, event, addonName)
	if (addonName == "Details_DataStorage") then
		DetailsDataStorage = DetailsDataStorage or Details:CreateStorageDB()
		DetailsDataStorage.Data = {}

		if (DetailsDataStorage.VERSION < DETAILS_STORAGE_VERSION) then
			table.wipe(DetailsDataStorage)
			DetailsDataStorage = Details:CreateStorageDB()
		end

		if (Details and Details.debug) then
			print("|cFFFFFF00Details! Storage|r: loaded!")
		end

		DETAILS_STORAGE_LOADED = true
	end
end)

