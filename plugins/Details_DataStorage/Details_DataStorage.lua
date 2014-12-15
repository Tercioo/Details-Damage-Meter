
DETAILS_STORAGE_VERSION = 2

function _detalhes:CreateStorageDB()
	DetailsDataStorage = {VERSION = DETAILS_STORAGE_VERSION, RAID_STORAGE = {}, SELF_STORAGE = {}}
	return DetailsDataStorage
end

local f = CreateFrame ("frame", nil, UIParent)
f:Hide()
f:RegisterEvent ("ADDON_LOADED")

f:SetScript ("OnEvent", function (self, event, addonName)
	if (addonName == "Details_DataStorage") then
		DetailsDataStorage = DetailsDataStorage or _detalhes:CreateStorageDB()
		if (DetailsDataStorage.VERSION < DETAILS_STORAGE_VERSION) then
			--> do revisions
			if (DetailsDataStorage.VERSION == 1) then
				DetailsDataStorage.SELF_STORAGE = {}
				DetailsDataStorage.VERSION = 2
			end
		end
		print ("|cFFFFFF00Details! Storage|r: loaded!")
		DETAILS_STORAGE_LOADED = true
	end
end)

