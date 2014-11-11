
DETAILS_STORAGE_VERSION = 1

function _detalhes:CreateStorageDB()
	DetailsDataStorage = {VERSION = DETAILS_STORAGE_VERSION, RAID_STORAGE = {}}
	return DetailsDataStorage
end

DetailsDataStorage = DetailsDataStorage or _detalhes:CreateStorageDB()

if (DetailsDataStorage.VERSION < DETAILS_STORAGE_VERSION) then
	--> do revisions
end

