
local detailsFramework = _G["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

---@cast detailsFramework detailsframework

---pack a table into a string separating values with commas
---example: table: {1, 2, 3, 4, 5, 6, 7, 8, 9}
---returned string: "9,1,2,3,4,5,6,7,8,9", where the first number is the total size of table
---@param table table
---@return string
function detailsFramework.table.pack(table)
    local tableSize = #table
    local newString = "" .. tableSize .. ","
    for i = 1, tableSize do
        newString = newString .. table[i] .. ","
    end

    newString = newString:gsub(",$", "")
    return newString
end

---pack subtables into a string separating values with commas, the first index tells the table length of the first packed table, the index t[currentIndex+length+1] tells the length of the next table.
---can pack strings and numbers, example:
---passed table: { {1, 2, 3}, {4, 5, 6}, {7, 8, 9}, ... }
---returned string: "3,1,2,3,3,4,5,6,3,7,8,9" > 3 indicating the total size of the first subtable followed by the sub table data, then 3 indicating the total size of the second subtable and so on
function detailsFramework.table.packsub(table)
    local newString = ""
    for i = 1, #table do
        newString = newString .. detailsFramework.table.pack(table[i]) .. ","
    end

    newString = newString:gsub(",$", "")
    return newString
end

---merge multiple tables into a single one and pack it into a string separating values with commas where the first index tells the table length
---can pack strings and numbers, example:
---passed table: { {1, 2, 3}, {4, 5, 6}, {7, 8, 9}}
---result string: "9,1,2,3,4,5,6,7,8,9" > 9 indicating the total size of the subtables following by the indexes of the subtables
---@param table table
---@return string
function detailsFramework.table.packsubmerge(table)
    local totalSize = 0
    local subTablesAmount = #table

    for i = 1, subTablesAmount do
        totalSize = totalSize + #table[i]
    end

    --set the first index to be the total size of the subtables
    local newString = "" .. totalSize .. ","

    for i = 1, subTablesAmount do
        local subTable = table[i]
        for subIndex = 1, #subTable do
            newString = newString .. subTable[subIndex] .. ","
        end
    end

    newString = newString:gsub(",$", "")
    return newString
end

---unpack a string and an array of data into a indexed table, starting from the startIndex also returns the next index to start reading
---expected data: "3,1,2,3,4,5,6,7,8" or {3,1,2,3,4,5,6,7,8}, with the example the returned table is: {1, 2, 3} and the next index to read is 5
---@param data string|table
---@param startIndex number?
---@return table, number
function detailsFramework.table.unpack(data, startIndex)
    local splittedTable

    if (type(data) == "table") then
        splittedTable = data
    else
        splittedTable = {}
        for value in data:gmatch("[^,]+") do
            splittedTable[#splittedTable+1] = value
        end
    end

    local currentIndex = startIndex or 1
    local currentTableSize = tonumber(splittedTable[currentIndex])
    if (not currentTableSize) then
        error("Details! Framework: table.unpack: invalid table size.")
    end

    startIndex = (startIndex and startIndex + 1) or 2
    local endIndex = currentIndex + currentTableSize
    local result = {}

    for i = startIndex, endIndex do
        local value = splittedTable[i]
        local asNumber = tonumber(value)
        if (asNumber) then
            table.insert(result, asNumber)
        else
            table.insert(result, value)
        end
    end

    local nextIndex = endIndex + 1
    if (not splittedTable[nextIndex]) then
        return result, 0
    end

    return result, endIndex + 1 --return the position of the last index plus 1 to account for the table size index
end


function detailsFramework.table.unpacksub(data, startIndex)
    startIndex = startIndex or 1

    local splittedTable = {}
    local bIsRunning = true
    local result = {}

    for value in data:gmatch("[^,]+") do
        splittedTable[#splittedTable+1] = value
    end

    while (bIsRunning) do
        local unpackTable, nextIndex = detailsFramework.table.unpack(splittedTable, startIndex)
        table.insert(result, unpackTable)

        if (nextIndex == 0) then
            bIsRunning = false
            break
        else
            startIndex = nextIndex
        end
    end

    return result
end