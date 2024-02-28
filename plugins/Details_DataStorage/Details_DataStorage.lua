
DETAILS_STORAGE_VERSION = 6

function Details:CreateStorageDB()
	DetailsDataStorage = {
		VERSION = DETAILS_STORAGE_VERSION,
		[14] = {}, --normal mode (raid)
		[15] = {}, --heroic mode (raid)
		[16] = {}, --mythic mode (raid)
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
print("loaded...")
		if (DetailsDataStorage.VERSION < DETAILS_STORAGE_VERSION) then
			print("is outdated")
			--> do revisions
			if (DetailsDataStorage.VERSION < 6) then
				print("outdated two, data wiped!")
				table.wipe(DetailsDataStorage)
				DetailsDataStorage = Details:CreateStorageDB()
			end
		end

		if (Details and Details.debug) then
			print("|cFFFFFF00Details! Storage|r: loaded!")
		end

		DETAILS_STORAGE_LOADED = true
	end
end)

