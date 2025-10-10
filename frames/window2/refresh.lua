
local Details = Details
local addonName, Details222 = ...
---@type detailsframework
local detailsFramework = DetailsFramework
local _

---@type details_allinonewindow
local AllInOneWindow = Details222.AllInOneWindow

--this table has player names in order to the refresh function of the window set the line contents
---@type string[]
local refresherPlayerCache = {}

local tickerCallback = function()
    local allWindowsOpened = AllInOneWindow:GetAllWindows()
    for i = 1, #allWindowsOpened do
        local windowFrame = allWindowsOpened[i]
        if (windowFrame:IsOpen()) then
            AllInOneWindow:RefreshWindow(windowFrame)
        end
    end
end

---@type timer?
local ticker

--this function is currently called from COMBAT_PLAYER_ENTER
function AllInOneWindow:StartRefresher()
    --before starting a timer to keep refreshing, need to refresh the header, do need? the refresh window frames does that.
    if (ticker and not ticker:IsCancelled()) then
        ticker:Cancel()
        ticker = nil
    end

    local refreshSpeed = 1
    ticker = C_Timer.NewTicker(refreshSpeed, tickerCallback)
    --AllInOneWindow:Print("refresher started.", ticker)
end

function AllInOneWindow:StopRefresher()
    if (ticker and not ticker:IsCancelled()) then
        ticker:Cancel()
        ticker = nil
    end
end

function AllInOneWindow:IsRefreshInProgress()
    return ticker and not ticker:IsCancelled() or true
end

---@param self details_allinonewindow
---@param windowFrame details_allinonewindow_frame
function AllInOneWindow:RefreshWindow(windowFrame)
    --first step is to get which column the data is sorted by;
    --then get which container this data belongs to and sort the players by the data;
    --iterate line by line and fill the data for each column;

    if (not windowFrame:IsOpen()) then
        return
    end

    local headerFrame = windowFrame:GetHeader()

    --get which column (from the header) is currently selected and the sort order
    local columnIndex, order, key, columnName = headerFrame:GetSelectedColumn() --column name is, for example, "healhpspercent"

    ---@type details_allinonewindow_headercolumndata
    local columnData = headerFrame:GetSelectedHeaderColumnData() --columndata is the tables declared in the file header_data.lua

    --error: columnData is nil, as there is no column selected yet.
    local sortByIndex = 2

    --então, tenho a coluna que vai dar sort, o que fazer agora?
    --precisa dar sort no container onde esse dado está inserido.
    --por examplo, o header é "interrupt", então o container que é dado sort é o utility pela key interrupt.

    --this is the attribute used to sort the data
    local attribute = columnData.attribute
    local subAttribute = columnData.subAttribute

    --get the combat data for the segment id
    local segmentId = windowFrame:GetSegmentId()
    ---@type combat
    local combatObject = Details:GetCombat(segmentId)

    Details:JustSortData(combatObject, attribute, subAttribute, order)
    local actorContainer = combatObject:GetContainer(attribute)

    local topActor = Details:FindTopPlayer(actorContainer, order)

    local onlyGroup = true
    local total = combatObject:GetTotal(attribute, subAttribute, onlyGroup)
    local attributeKeyName = Details:GetKeyNameFromAttribute(attribute, subAttribute)
    windowFrame:SetSortKeyTopAndTotal(key, math.max(topActor and topActor[attributeKeyName] or 0, 0.1), math.max(total, 0.1)) --set the total in the window frame, so the scroll frame can use it to calculate percentages

    --drop cache
    table.wipe(refresherPlayerCache)

    --pegar a quantidade de linhas? -- é garantido que cada ator tenha uma tabela no misc?: não
    --se só 2 actors tiver interrupt mas o resto não tiver, dar sort no resto por nome, damage ou healing done? resposta: depende da role, damager e tank = damager
    --então, se o sort for no attributo 4, dar sort também no attribute 1 ou 2

    --if it is showing the utility, it can have cases where the actor does not have any data to show.
    --to counter this, actors that does not have data, will be added by damage or heal.
    local secondActorContainer

    if (attribute == DETAILS_ATTRIBUTE_MISC) then
        local role = detailsFramework:GetPlayerRole()
        if (role == "TANK" or role == "DAMAGER") then
            Details:JustSortData(combatObject, DETAILS_ATTRIBUTE_DAMAGE, DETAILS_SUBATTRIBUTE_DAMAGEDONE)
            secondActorContainer = combatObject:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)
        else
            Details:JustSortData(combatObject, DETAILS_ATTRIBUTE_HEAL, DETAILS_SUBATTRIBUTE_HEALDONE)
            secondActorContainer = combatObject:GetContainer(DETAILS_ATTRIBUTE_HEAL)
        end
    end

    local avoidDuplications = {}

    do
        local mainActorContainer = combatObject:GetContainer(attribute) --this can be damage, heal or utility
        ---@type actor[]
        local actorTable = mainActorContainer._ActorTable
        for i = 1, #actorTable do
            local thisActor = actorTable[i]
            if (thisActor.grupo) then --fast way to know if the actor is a player
                refresherPlayerCache[#refresherPlayerCache+1] = thisActor.nome
                if (attribute == DETAILS_ATTRIBUTE_MISC) then
                    avoidDuplications[thisActor.nome] = true
                    self.ActorCache[thisActor.nome] = thisActor
                end
            end
        end
    end

    if (attribute == DETAILS_ATTRIBUTE_MISC) then
        local actorTable = secondActorContainer._ActorTable
        for i = 1, #actorTable do
            local thisActor = actorTable[i]
            if (thisActor.grupo and not avoidDuplications[thisActor.nome]) then
                refresherPlayerCache[#refresherPlayerCache+1] = thisActor.nome
                self.ActorCache[thisActor.nome] = thisActor
            end
        end
    end

    --so, here it should create a table with player names? and then in the refresh function it access the combat data and get the values from there.
    --it is much less garbage being generated this way

    --get the scroll frame of the window, using the function to get it
    local scrollFrame = windowFrame:GetScrollFrame()

    scrollFrame:SetData(refresherPlayerCache)
    scrollFrame:Refresh()

    local testVisibility = false
    if (testVisibility) then
        local firstLine = scrollFrame:GetLine(1)
        if (firstLine) then
            print("line debug: W, H, #P, Shown, Visible:", firstLine:GetWidth(), firstLine:GetHeight(), firstLine:GetNumPoints(), firstLine:IsShown(), firstLine:IsVisible())
        else
            print("testVisibility", "no first line found.")
        end

        print("window debug: W, H, #P, Shown, Visible:", windowFrame:GetWidth(), windowFrame:GetHeight(), windowFrame:GetNumPoints(), windowFrame:IsShown(), windowFrame:IsVisible())
    end
end

---update the header following the settings
---@param self details_allinonewindow
---@param windowFrame details_allinonewindow_frame
function AllInOneWindow:RefreshHeader(windowFrame) --~header
    local headerFrame = windowFrame.Header
    headerFrame.options.header_backdrop_color = windowFrame.settings.header.background_color

    --each columns the window will show
    local headerColumnsNames = windowFrame.settings.header.column_names --displays is an array with column IDs, default is: {"icon", "rank", "pname", "dmg", "dmgdps", "dmgdpspercent", "heal", "healhps", "healhpspercent", "death", "interrupt", "dispel"}
    local selectedHeaderName = windowFrame.settings.header.column_selected

    --column data has information about each display type
    local columnData = self.HeaderColumnData
    local columnDataKeyToIndex = self.HeaderColumnDataKeyToIndex

    --this header table will be used in the headerFrame:SetHeaderTable()
    ---@type details_allinonewindow_headercolumndata[]
    local headerTable = {}

    local columnWidths = windowFrame.settings.header.column_width

    local showColumnText = windowFrame.settings.header.column_show_text
    local showColumnIcon = windowFrame.settings.header.column_show_icon

    for i = 1, #headerColumnsNames do
        local columnId = headerColumnsNames[i]
        local thisColumnData = columnData[columnDataKeyToIndex[columnId]]

        if (showColumnText[columnId] == nil) then
            showColumnText[columnId] = thisColumnData.showText
        end

        if (showColumnIcon[columnId] == nil) then
            showColumnIcon[columnId] = true
        end

        local showHeaderText = showColumnText[columnId]
        local showHeaderIcon = showColumnIcon[columnId]

        local columnWidth = columnWidths[thisColumnData.name]
        if (columnWidth) then
            thisColumnData.width = columnWidth
        else
            columnWidths[thisColumnData.name] = thisColumnData.width
        end

        ---@type details_allinonewindow_headercolumndata
        local headerColumnData = {
            width = thisColumnData.width,
            text = showHeaderText and thisColumnData.text or "",
            name = thisColumnData.name,
            attribute = thisColumnData.attribute,
            subAttribute = thisColumnData.subAttribute,
            label = thisColumnData.label,
            --these values may be nil
            selected = selectedHeaderName == thisColumnData.name,
            align = thisColumnData.align,
            canSort = thisColumnData.canSort,
            --dataType = thisColumnData.dataType,
            order = headerFrame.columnOrder,
            offset = thisColumnData.offset,
            key = thisColumnData.key,
            icon = showHeaderIcon and thisColumnData.icon or "",
            texcoord = thisColumnData.texcoord,
            columnSpan = thisColumnData.columnSpan or 0,
        }

        headerTable[#headerTable+1] = headerColumnData
    end

    --the setheadtable is somehow resetting the order set in the 'order' key above
    headerFrame:SetHeaderTable(headerTable) --setting the headerTable, will make the headerFrame to resize itself

    local clearHeaders = {"icon", "rank", "pname"}
    for i = 1, #clearHeaders do
        local headerName = clearHeaders[i]
        local headerColumnFrame = headerFrame:GetHeaderColumnByName(headerName)
        if (headerColumnFrame) then
            headerColumnFrame.Text:SetText("")
            headerColumnFrame.Icon:Hide()
            if (headerName ~= "pname") then
                headerColumnFrame.Separator:Hide()
                headerColumnFrame.resizerButton:Hide()
            end
        end
    end

    --the window width has to be the same size of the header
    local headerWidth = headerFrame:GetWidth()
    windowFrame:SetWidth(headerWidth + 4) --+4 for the border
end

local getAnyActor = function(actorObjects)
    return actorObjects[DETAILS_ATTRIBUTE_DAMAGE] or actorObjects[DETAILS_ATTRIBUTE_HEAL] or actorObjects[DETAILS_ATTRIBUTE_ENERGY] or actorObjects[DETAILS_ATTRIBUTE_MISC]
end

---@param self details_allinonewindow
---@param index number
---@param windowFrame details_allinonewindow_frame
---@param line details_allinonewindow_line
---@param headerColumnFrame details_allinonewindow_line_dataframe
---@param containers actorcontainer[]
---@param headerName string
---@param playerName string
---@param combatObject combat
---@param actorObjects actor[]
function AllInOneWindow:RefreshColumn(index, windowFrame, line, headerColumnFrame, containers, headerName, playerName, combatObject, actorObjects)
    local combatTime = combatObject:GetCombatTime()
    if (headerColumnFrame) then
        headerColumnFrame.actorObject = nil

        if (headerName == "icon") then
            local anyActor = getAnyActor(actorObjects)
            if (anyActor) then
                local actorSpec = anyActor.spec
                if (actorSpec and actorSpec ~= 0) then
                    local useAlpha = false
                    local texture, left, right, top, bottom = Details:GetSpecIcon(actorSpec, useAlpha)
                    line.PlayerIconTexture:SetTexture(texture)
                    line.PlayerIconTexture:SetTexCoord(left, right, top, bottom)
                    line.PlayerIconTexture:Show()
                end
            end
            return 1

        elseif (headerName == "rank") then
            headerColumnFrame.Text:SetText(index)
            return index

        elseif (headerName == "pname") then
            headerColumnFrame.Text:SetText(detailsFramework:RemoveRealmName(playerName))
            return detailsFramework.string.GetSortValueFromString(playerName)

        elseif (headerName == "dmg") then
            local damageActor = actorObjects[DETAILS_ATTRIBUTE_DAMAGE]
            if damageActor then
                headerColumnFrame.actorObject = damageActor
                headerColumnFrame.Text:SetText(Details:Format(damageActor.total))
                return damageActor.total
            else
                headerColumnFrame.Text:SetText("0")
                return 0
            end

        elseif (headerName == "dps") then
            local damageActor = actorObjects[DETAILS_ATTRIBUTE_DAMAGE]
            if damageActor then
                headerColumnFrame.actorObject = damageActor
                headerColumnFrame.Text:SetText(Details:Format(damageActor.total / combatTime))
                return damageActor.total / combatTime
            else
                headerColumnFrame.Text:SetText("0")
                return 0
            end

        elseif (headerName == "dmgdps") then
            local damageActor = actorObjects[DETAILS_ATTRIBUTE_DAMAGE]
            if damageActor then
                headerColumnFrame.actorObject = damageActor
                headerColumnFrame.Text:SetText(Details:Format(damageActor.total) .. " / " .. Details:Format(damageActor.total / combatTime))
                return damageActor.total
            else
                headerColumnFrame.Text:SetText("0")
                return 0
            end

        --elseif (headerName == "dmgdpspercent") then --not implemented
        elseif (headerName == "heal") then
            local healActor = actorObjects[DETAILS_ATTRIBUTE_HEAL]
            if (healActor) then
                headerColumnFrame.actorObject = healActor
                headerColumnFrame.Text:SetText(Details:Format(healActor.total))
                return healActor.total
            else
                headerColumnFrame.Text:SetText("0")
                return 0
            end

        elseif (headerName == "overheal") then
            local healActor = actorObjects[DETAILS_ATTRIBUTE_HEAL]
            if (healActor) then
                ---@cast healActor actorheal
                headerColumnFrame.actorObject = healActor
                headerColumnFrame.Text:SetText(Details:Format(healActor.totalover))
                return healActor.totalover
            else
                headerColumnFrame.Text:SetText("0")
                return 0
            end

        elseif (headerName == "hps") then
            local healActor = actorObjects[DETAILS_ATTRIBUTE_HEAL]
            if (healActor) then
                headerColumnFrame.actorObject = healActor
                headerColumnFrame.Text:SetText(Details:Format(healActor.total / combatTime))
                return healActor.total / combatTime
            else
                headerColumnFrame.Text:SetText("0")
                return 0
            end

        elseif (headerName == "healhps") then
            local healActor = actorObjects[DETAILS_ATTRIBUTE_HEAL]
            if (healActor) then
                headerColumnFrame.actorObject = healActor
                headerColumnFrame.Text:SetText(Details:Format(healActor.total) .. " / " .. Details:Format(healActor.total / combatTime))
                return healActor.total
            else
                headerColumnFrame.Text:SetText("0")
                return 0
            end

        --elseif (headerName == "healhpspercent") then --not implemented
        elseif (headerName == "death") then
            --deaths aren't stored in the misc container, need to get from the combat directly
            local playerDeaths = combatObject:GetPlayerDeaths(playerName)
            headerColumnFrame.Text:SetText(playerDeaths and #playerDeaths or 0)
            return playerDeaths and #playerDeaths or 0

        elseif (headerName == "interrupt") then
            ---@type actorutility
            local utilityActor = actorObjects[DETAILS_ATTRIBUTE_MISC]
            if (utilityActor) then
                headerColumnFrame.Text:SetText(math.floor(utilityActor.interrupt or 0))
                headerColumnFrame.actorObject = utilityActor
                return utilityActor.interrupt or 0
            else
                headerColumnFrame.Text:SetText("0")
                return 0
            end

        elseif (headerName == "dispel") then
            ---@type actorutility
            local utilityActor = actorObjects[DETAILS_ATTRIBUTE_MISC]
            if (utilityActor) then
                headerColumnFrame.Text:SetText(math.floor(utilityActor.dispell or 0))
                headerColumnFrame.actorObject = utilityActor
                return utilityActor.dispell or 0
            else
                headerColumnFrame.Text:SetText("0")
                return 0
            end
        end
    end

    return 0
end