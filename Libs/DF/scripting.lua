
local detailsFramework = DetailsFramework

if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local unpack = unpack
local CreateFrame = CreateFrame
local geterrorhandler = geterrorhandler
local wipe = wipe

local parseCodeForNamedLocalFunctions = function(codeBlock, startIndex, listOfFunctionsFound)
    local nestedLevel = 0
    local endIndex = startIndex
    local currentQuote = ""
    ---@type number for the 'function' keyword, need to ignore the one that started the 'local function' capture
    local ignoreFunctionIndex = startIndex + 6

    ---@type boolean
    local bFoundEnd = false
    ---@type boolean
    local bIsInString = false
    ---@type boolean
    local bIsInComment = false

    while (endIndex <= #codeBlock) do
        local char = string.sub(codeBlock, endIndex, endIndex)

        --check if the character is inside a comment
        if (char == "-") then
            local nextChar = string.sub(codeBlock, endIndex + 1, endIndex + 1)
            if nextChar == "-" then
                bIsInComment = true
            end

        elseif (char == "\n") then
            bIsInComment = false
        end

        if (not bIsInComment) then
            --check if it is inside a string
            if (char == "'" or char == '"') then
                if (not bIsInString) then
                    bIsInString = true
                    currentQuote = char

                elseif (bIsInString and currentQuote == char) then
                    bIsInString = false
                    currentQuote = ""
                end
            end

            if (not bIsInString) then
                --check if the word starts with "i", "f", "d" or "e"
                if (char == "i") then
                    local nextChars = string.sub(codeBlock, endIndex, endIndex + 1)
                    if (nextChars == "if") then
                        nestedLevel = nestedLevel + 1
                    end

                elseif (char == "f") then
                    local nextChars = string.sub(codeBlock, endIndex, endIndex + 7)
                    --also check if the index isn't the one that started the 'local function' capture
                    if (nextChars == "function" and endIndex ~= ignoreFunctionIndex) then
                        nestedLevel = nestedLevel + 1
                    end

                --for 'do' keyword, used by for and while and also by the 'do' keyword itself creating a block
                elseif (char == "d") then
                    local nextChars = string.sub(codeBlock, endIndex, endIndex + 1)
                    if (nextChars == "do") then
                        nestedLevel = nestedLevel + 1
                    end

                elseif (char == "e") then
                    local nextChars = string.sub(codeBlock, endIndex, endIndex + 2)
                    if (nextChars == "end") then
                        if (nestedLevel > 0) then
                            --reduce the nested level by 1
                            nestedLevel = nestedLevel - 1
                        else
                            --if the nested level is zero then the end of the function got found
                            bFoundEnd = true
                            endIndex = endIndex + 2 --adjust endIndex to include the 'end' keyword
                            break
                        end
                    end
                end
            end
        end

        endIndex = endIndex + 1
    end

    if (bFoundEnd) then
        ---@type string get the function body
        local functionBody = string.sub(codeBlock, startIndex, endIndex)
        table.insert(listOfFunctionsFound, functionBody)
        return endIndex
    end
end

---search a code block for named local functions and bring them to the top of the code block
---this is useful for when you want to call a function before it's defined
---same thing as been implemented in Lua 5.2 but not in WoW Lua
---@param codeBlock string
function detailsFramework:BringNamedLocalFunctionToTop(codeBlock)
    ---@type string[]
    local listOfFunctionsFound = {}
    ---@type number|nil
    local startIndex = string.find(codeBlock, "local function")

    while startIndex do
        startIndex = parseCodeForNamedLocalFunctions(codeBlock, startIndex, listOfFunctionsFound)
        if (not startIndex) then
            break
        end
        startIndex = string.find(codeBlock, "local function", startIndex + 1)
    end

    for i = #listOfFunctionsFound, 1, -1 do
        local thisMatch = listOfFunctionsFound[i]
        local blockStartIndex = thisMatch[2]
        local blockEndIndex = thisMatch[3]
        codeBlock = codeBlock:sub(1, blockStartIndex - 1) .. codeBlock:sub(blockEndIndex + 1)
    end

    for i = #listOfFunctionsFound, 1, -1 do
        codeBlock = listOfFunctionsFound[i][1] .. "\n\n" .. codeBlock
    end
end