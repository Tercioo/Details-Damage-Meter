
---@type details
local Details = _G.Details
local Loc = LibStub("AceLocale-3.0"):GetLocale("Details")
---@type detailsframework
local detailsFramework = DetailsFramework
local _, Details222 = ...

---@class detailssegmentselectionmidnight : table
---@field MainFrameMixin table
---@field SegmentFrameMixin table
---@field OnClickLine fun(line: segmentframeline)
---@field IsLineSelected fun(panel: segmentframelist, rowData: table): boolean

---@type detailssegmentselectionmidnight
local segmentSelectionMidnight = Details222.SegmentSelectionMidnight

--segmentSelectionMidnight.settings.
local linePadding = segmentSelectionMidnight.settings.linePadding
local lineTopOffset = segmentSelectionMidnight.settings.lineTopOffset
local lineHeight = segmentSelectionMidnight.settings.lineHeight
local frameTopOffset = segmentSelectionMidnight.settings.frameTopOffset
local lineAmount = segmentSelectionMidnight.settings.lineAmount
local frameWidth = segmentSelectionMidnight.settings.frameWidth
local byUser = true

---@param linesInUse number
---@return number
local calculateMainFrameHeight = function(linesInUse)
    local visibleLines = math.max(linesInUse or 0, 0)
    local lineSpacing = math.max(visibleLines - 1, 0) * linePadding
    local linesContentHeight = lineTopOffset + (visibleLines * lineHeight) + lineSpacing
    return frameTopOffset + linesContentHeight
end

segmentSelectionMidnight.MainFrameMixin = {
    GetInstance = function(self)
        return self.instance
    end,

    GetStatusBarTexture = function(self)
        local instance = self:GetInstance()
        if instance then
            local SharedMedia = LibStub("LibSharedMedia-3.0")
            local textureFile = SharedMedia:Fetch("statusbar", instance.row_info.texture)
            if textureFile then
                return textureFile
            end
        end
        return [[Interface\TargetingFrame\NameplateFill]]
    end,

    SetDataProviders = function(self, leftProvider, rightProvider)
        if leftProvider ~= nil then
            assert(type(leftProvider) == "function", "Left provider must be a function.")
            self.CustomLeftDataProvider = leftProvider
        end

        if rightProvider ~= nil then
            assert(type(rightProvider) == "function", "Right provider must be a function.")
            self.CustomRightDataProvider = rightProvider
        end
    end,

    RefreshMe = function(self)
        local leftProvider = self.CustomLeftDataProvider or self.LeftDataProvider
        local rightProvider = self.CustomRightDataProvider or self.RightDataProvider
        local leftData = leftProvider(self)
        local rightData = rightProvider(self)

        --as the lines on each segment frame list goes from bottom to top, the data needs to be reversed
        leftData = detailsFramework.table.reverse(leftData)
        rightData = detailsFramework.table.reverse(rightData)

        assert(type(leftData) == "table", "Left provider must return a table.")
        assert(type(rightData) == "table", "Right provider must return a table.")

        local linesInUseLeft = self.LeftPanel:Refresh(leftData)
        local linesInUseRight = self.RightPanel:Refresh(rightData)

        local mainFrameHeight = calculateMainFrameHeight(math.max(linesInUseLeft, linesInUseRight))
        self:SetHeight(mainFrameHeight)
    end,

    CloseFrame = function(self)
        self:Hide()
    end,
}

segmentSelectionMidnight.SegmentFrameMixin = {
    ---@param data table
    Refresh = function(self, data) --~refresh
        local lineIndex = math.min(#data, lineAmount)

        self:HideAllLines()
        local statusBarTexture = self:GetParent():GetStatusBarTexture()
        local leftTextMaxWidth = frameWidth - 55
        local linesInUse = 0

        for i = 1, lineAmount do
            local thisSegmentData = data[i]
            if thisSegmentData then
                local line = self:GetLine(lineIndex)

                if thisSegmentData.separator then
                    line.LeftText:SetText("")
                    line.RightText:SetText("")
                    line.StatusBar:SetStatusBarTexture([[Interface\Buttons\WHITE8X8]])
                    line.StatusBar:SetStatusBarColor(0, 0, 0, 0)
                    line.StatusBar:SetValue(1)
                    line.SelectedTexture:Hide()
                    line.Icon:SetTexture("")
                    line.rowData = nil
                    line.dataFor = nil
                else
                    local icon = thisSegmentData.icon
                    local leftText = thisSegmentData.leftText
                    local rightText = thisSegmentData.rightText
                    local percent = detailsFramework.Math.Clamp(0, 1, thisSegmentData.durationPercent)

                    detailsFramework:SetAtlas(line.Icon, icon)

                    line.LeftText:SetText(leftText or "")
                    detailsFramework:TruncateText(line.LeftText, leftTextMaxWidth)

                    line.RightText:SetText(rightText or "")

                    line.StatusBar:SetStatusBarTexture(statusBarTexture)
                    local statusBarColor = thisSegmentData.statusbarColor
                    line.StatusBar:SetStatusBarColor(unpack(statusBarColor))
                    line.StatusBar:SetValue(percent or 0)

                    if segmentSelectionMidnight.IsLineSelected(self, thisSegmentData) then
                        line.SelectedTexture:Show()
                    else
                        line.SelectedTexture:Hide()
                    end

                    line.rowData = thisSegmentData
                    line.dataFor = self.dataFor
                end
                line:Show()
                lineIndex = lineIndex - 1
                linesInUse = linesInUse + 1
            end
        end

        return linesInUse
    end,

    HideAllLines = function(self)
        for i = 1, lineAmount do
            self.Lines[i]:Hide()
            self.Lines[i].rowData = nil
            self.Lines[i].dataFor = nil
        end
    end,

    GetLine = function(self, index)
        return self.Lines[index]
    end,
}

---@param line segmentframeline
segmentSelectionMidnight.OnClickLine = function(line) --~click õnclick ~onclick
    local panel = line:GetParent()
    local mainFrame = panel:GetParent()
    local sourceType = line.dataFor
    local rowData = line.rowData
    local instance = mainFrame:GetInstance()
    assert(instance, "Instance not found for segment selection frame.")

    if sourceType == "blizzard" then
        local bForceRefresh = true
        local afterSetSession = function()
            instance:RefreshWindow(bForceRefresh)
            mainFrame:RefreshMe()
        end

        local selectExpired = function(sessionId)
            instance:SetNewSegmentId(sessionId, byUser)
            instance:SetSegmentType(2, bForceRefresh, byUser)
            afterSetSession()
        end
        local selectCurrent = function()
            instance:SetSegmentType(1, bForceRefresh, byUser)
            afterSetSession()
        end
        local selectOverall = function()
            instance:SetSegmentType(0, bForceRefresh, byUser)
            afterSetSession()
        end

        if rowData.segmentId == -1 then
            selectOverall()
        elseif rowData.segmentId == 0 then
            selectCurrent()
        else
            selectExpired(rowData.segmentId)
        end

    elseif sourceType == "details" then
        instance:SetSegmentId(rowData.segmentId, byUser)
        Details.no_fade_animation = true
        Details:UpdateCombatObjectInUse(instance)
        Details:RefreshMainWindow(instance, true)

        Details.no_fade_animation = false
    end

    --mainFrame:CloseFrame()
end

---@param panel segmentframelist
---@param rowData table
---@return boolean
segmentSelectionMidnight.IsLineSelected = function(panel, rowData)
    local mainFrame = panel:GetParent()
    local instance = mainFrame:GetInstance()

    if panel.dataFor == "blizzard" then
        if instance:GetApocalypseSourceType() == Details222.Apocalypse.TypeDetails then
            return false
        end

        local selectedSegmentType = instance:GetSegmentType()
        if rowData.segmentId == -1 then
            return selectedSegmentType == 0

        elseif rowData.segmentId == 0 then
            return selectedSegmentType == 1

        else
            return selectedSegmentType == 2 and rowData.segmentId == instance:GetNewSegmentId()
        end

    elseif panel.dataFor == "details" then
        if instance:GetApocalypseSourceType() == Details222.Apocalypse.TypeGame then
            return false
        end
        return rowData.segmentId == instance:GetSegmentId()
    end

    return false
end

---@class savedsegmentheader : table
---@field name string
---@field mythicPlusOverall boolean?
---@field mythicPlusLevel number?
---@field mythicPlusZoneName string?
---@field date number timestamp of when the segment was saved
---@field elapsedTime number duration of the combat

---@class savedsegment : table
---@field combatData string compressed combat data
---@field header savedsegmentheader

function segmentSelectionMidnight.SaveSegment(combatObject)
    local compressedData = segmentSelectionMidnight.CompressSegment(combatObject)
    local savedSegments = Details.apocalypse_savedsegments

    local mythicDungeonInfo = combatObject.is_mythic_dungeon
    local segmentName = combatObject:GetCombatName()

    ---@type savedsegment
    local data = {
        combatData = compressedData,
        header = {
            date = time(),
            name = segmentName,
            elapsedTime = combatObject:GetCombatTime(),
            mythicPlusOverall = mythicDungeonInfo and mythicDungeonInfo.OverallSegment,
            mythicPlusLevel = mythicDungeonInfo and mythicDungeonInfo.Level,
            mythicPlusZoneName = mythicDungeonInfo and mythicDungeonInfo.ZoneName,
        },
    }

    table.insert(savedSegments, 1, data)
end

Details.SaveSegment = segmentSelectionMidnight.SaveSegment

function segmentSelectionMidnight.ListSavedSegments()
    local savedSegments = Details.apocalypse_savedsegments
    return savedSegments
end

function segmentSelectionMidnight.CompressSegment(combatObject)
    local cleanCopy = Details222.Segments.MakeCleanSegmentCopy(combatObject)
    local serialized = C_EncodingUtil.SerializeCBOR(cleanCopy)
    local combatCompressed = C_EncodingUtil.CompressString(serialized, Enum.CompressionMethod.Deflate, Enum.CompressionLevel.OptimizeForSize)
    return combatCompressed
end

function segmentSelectionMidnight.DecompressSegment(compressedData)
    local decompressed = C_EncodingUtil.DecompressString(compressedData, Enum.CompressionMethod.Deflate)
    local deserialized = C_EncodingUtil.DeserializeCBOR(decompressed)
    local restoredCombat = Details222.Segments.RestoreSegment(deserialized)
    return restoredCombat
end

Details.DecompressSegment = segmentSelectionMidnight.DecompressSegment
