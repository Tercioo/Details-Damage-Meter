local detailsFramework = DetailsFramework
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

---@class screenanchor : frame
---@field anchorName string The identifier for this anchor
---@field growDirection string The direction frames grow from the anchor ("top", "bottom", "left", "right")
---@field setupFunction function The function to call when setting up a frame
---@field sortFunction function The sort function for ordering frames on this anchor
---@field framePool any The pool of frames on this anchor
---@field MoverTexture texture The texture displayed when the anchor is unlocked
---@field screenAnchors screenanchor[] Array of all anchor frames

---@class anchorsystem
---@field locked boolean Whether the anchors are currently locked
---@field profileTable table The profile table for storing anchor positions
---@field screenAnchors screenanchor[] All created screen anchors
---@field lineSpacing number The spacing between frames when reordering
---@field SetProfileTable fun(self: anchorsystem, profileTable: table) Sets the profile table for anchor position storage
---@field SavePosition fun(self: anchorsystem, anchorFrame: screenanchor) Saves the anchor frame's position to the profile
---@field RestorePosition fun(self: anchorsystem, anchorFrame: screenanchor) Restores the anchor frame's position from the profile
---@field UnlockAnchors fun(self: anchorsystem) Unlocks all anchor frames, allowing them to be moved
---@field LockAnchors fun(self: anchorsystem) Locks all anchor frames, preventing them from being moved
---@field CreateScreenAnchor fun(self: anchorsystem, anchorKey: string, frameName: string, growDirection: string, setupFunction: function, sortFunction: function, frameCreateFunction: function): screenanchor Creates a new screen anchor
---@field GetScreenAnchor fun(self: anchorsystem, anchorName: string): screenanchor Gets a screen anchor by name
---@field HideAll fun(self: anchorsystem) Hides all frames from all anchors
---@field Reorder fun(self: anchorsystem, anchorFrame: screenanchor) Reorders all frames on an anchor frame
---@field ShowFrame fun(self: anchorsystem, anchorName: string, ...): any Shows a frame on the specified anchor
---@field HideFrame fun(self: anchorsystem, frame: any) Hides a frame from whichever anchor it is currently on
---@field SetLineSpacing fun(self: anchorsystem, spacing: number) Sets the line spacing for all anchor frames and reorders their frames
---@field SetGrowDirection fun(self: anchorsystem, anchorName: string, growDirection: string) Sets the grow direction for a specific anchor and reorders its frames

---@type table
local anchorSystemMixin = {
    ---Sets the profile table for anchor position storage
    ---@param self anchorsystem
    ---@param profileTable table The profile table to use for all position storage
    SetProfileTable = function(self, profileTable)
        self.profileTable = profileTable
    end,

    ---Saves the anchor frame's position to the profile
    ---@param self anchorsystem
    ---@param anchorFrame screenanchor The anchor frame whose position to save
    SavePosition = function(self, anchorFrame)
        local left, bottom = anchorFrame:GetLeft(), anchorFrame:GetBottom()
        local width, height = UIParent:GetSize()

        local anchorTable = self.profileTable[anchorFrame.anchorName]
        if (not anchorTable) then
            anchorTable = {
                leftPercent = left / width,
                bottomPercent = bottom / height,
                uiParentWidth = width,
                uiParentHeight = height,
                scale = 1,
            }
            self.profileTable[anchorFrame.anchorName] = anchorTable
        else
            anchorTable.leftPercent = left / width
            anchorTable.bottomPercent = bottom / height
            anchorTable.uiParentWidth = width
            anchorTable.uiParentHeight = height
        end
    end,

    ---Restores the anchor frame's position from the profile
    ---@param self anchorsystem
    ---@param anchorFrame screenanchor The anchor frame whose position to restore
    RestorePosition = function(self, anchorFrame)
        local anchorTable = self.profileTable[anchorFrame.anchorName]

        if not anchorTable then
            --No saved position, center the anchor on screen
            anchorFrame:ClearAllPoints()
            anchorFrame:SetPoint("center", UIParent, "center", 0, 0)
            return
        end

        local leftPercent = anchorTable.leftPercent
        local bottomPercent = anchorTable.bottomPercent
        local uiParentWidth = anchorTable.uiParentWidth
        local uiParentHeight = anchorTable.uiParentHeight

        local newUIParentWidth, newUIParentHeight = UIParent:GetSize()

        local left, bottom = leftPercent * newUIParentWidth, bottomPercent * newUIParentHeight

        anchorFrame:ClearAllPoints()
        anchorFrame:SetPoint("bottomleft", UIParent, "bottomleft", left, bottom)
    end,

    ---Unlocks all anchor frames, allowing them to be moved
    ---@param self anchorsystem
    UnlockAnchors = function(self)
        self.locked = false

        for i = 1, #self.screenAnchors do
            local thisAnchor = self.screenAnchors[i]
            thisAnchor.MoverTexture:Show()
            thisAnchor:EnableMouse(true)
            thisAnchor:SetMovable(true)
            thisAnchor:RegisterForDrag("LeftButton")
            thisAnchor:SetScript("OnDragStart", function(frame)
                frame:StartMoving()
            end)
            thisAnchor:SetScript("OnDragStop", function(frame)
                frame:StopMovingOrSizing()
                self:SavePosition(frame)
            end)
        end
    end,

    ---Locks all anchor frames, preventing them from being moved
    ---@param self anchorsystem
    LockAnchors = function(self)
        self.locked = true

        for i = 1, #self.screenAnchors do
            local thisAnchor = self.screenAnchors[i]
            thisAnchor:EnableMouse(false)
            thisAnchor:SetMovable(false)
            thisAnchor:SetScript("OnDragStart", nil)
            thisAnchor:SetScript("OnDragStop", nil)
            thisAnchor.MoverTexture:Hide()
        end
    end,

    ---Creates a new screen anchor for displaying frames
    ---@param self anchorsystem
    ---@param anchorKey string The key identifying this anchor type
    ---@param frameName string The name to give the frame
    ---@param growDirection string The direction frames grow from the anchor ("top", "bottom", "left", "right")
    ---@param setupFunction function The function to call when setting up a frame for this anchor
    ---@param sortFunction function The sort function for ordering frames on this anchor
    ---@param frameCreateFunction function The function to call to create frames for the pool
    ---@return screenanchor The newly created anchor frame
    CreateScreenAnchor = function(self, anchorKey, frameName, growDirection, setupFunction, sortFunction, frameCreateFunction)
        ---@type screenanchor
        local anchorFrame = CreateFrame("frame", frameName, UIParent)
        anchorFrame:SetSize(20, 20)
        anchorFrame:EnableMouse(false)
        anchorFrame:SetClampedToScreen(true)
        anchorFrame:SetFrameStrata("MEDIUM")
        anchorFrame.anchorName = anchorKey
        anchorFrame.growDirection = growDirection
        anchorFrame.setupFunction = setupFunction
        anchorFrame.sortFunction = sortFunction

        local moverTexture = anchorFrame:CreateTexture("$parentMoverTexture", "overlay")
        moverTexture:SetAllPoints()
        moverTexture:SetSize(16, 16)
        moverTexture:SetColorTexture(1, 0.1, 0.1, 0.8)
        moverTexture:Hide()
        anchorFrame.MoverTexture = moverTexture

        table.insert(self.screenAnchors, anchorFrame)

        self:RestorePosition(anchorFrame)

        anchorFrame.framePool = detailsFramework:CreatePool(frameCreateFunction, anchorFrame)
        anchorFrame.framePool:SetCallbackOnRelease(function(frame) frame:Hide() end)
        anchorFrame.framePool:SetCallbackOnReleaseAll(function(frame) frame:Hide() end)
        anchorFrame.framePool:SetSortFunction(sortFunction)

        return anchorFrame
    end,

    ---Gets a screen anchor by name
    ---@param self anchorsystem
    ---@param anchorName string The name of the anchor to retrieve
    ---@return screenanchor The screen anchor with the given name
    GetScreenAnchor = function(self, anchorName)
        for i = 1, #self.screenAnchors do
            local thisAnchor = self.screenAnchors[i]
            if (thisAnchor.anchorName == anchorName) then
                return thisAnchor
            end

            ---@diagnostic disable-next-line: missing-return
        end
    end,

    ---Hides all frames from all anchors
    ---@param self anchorsystem
    HideAll = function(self)
        for i = 1, #self.screenAnchors do
            local thisAnchor = self.screenAnchors[i]
            thisAnchor.framePool:ReleaseAll()
        end
    end,

    ---Reorders all frames on an anchor frame
    ---@param self anchorsystem
    ---@param anchorFrame screenanchor The anchor frame to reorder
    Reorder = function(self, anchorFrame)
        anchorFrame.framePool:Sort()
        local allComponentsShown = anchorFrame.framePool:GetAllInUse()

        local lastComponent = nil
        local lineSpacing = self.lineSpacing

        for i = 1, #allComponentsShown do
            local thisComponent = allComponentsShown[i]
            thisComponent:ClearAllPoints()

            local growDir = anchorFrame.growDirection

            if (lastComponent) then
                --Attach relative to the previous frame
                if growDir == "top" then
                    thisComponent:SetPoint("bottom", lastComponent.widget or lastComponent, "top", 0, lineSpacing)
                elseif growDir == "bottom" then
                    thisComponent:SetPoint("top", lastComponent.widget or lastComponent, "bottom", 0, -lineSpacing)
                elseif growDir == "left" then
                    thisComponent:SetPoint("right", lastComponent.widget or lastComponent, "left", lineSpacing, 0)
                elseif growDir == "right" then
                    thisComponent:SetPoint("left", lastComponent.widget or lastComponent, "right", lineSpacing, 0)
                end
            else
                --Attach first frame to the center of anchorFrame
                if growDir == "top" then
                    thisComponent:SetPoint("bottom", anchorFrame, "center", 0, 0)
                elseif growDir == "bottom" then
                    thisComponent:SetPoint("top", anchorFrame, "center", 0, 0)
                elseif growDir == "left" then
                    thisComponent:SetPoint("right", anchorFrame, "center", 0, 0)
                elseif growDir == "right" then
                    thisComponent:SetPoint("left", anchorFrame, "center", 0, 0)
                end
            end

            lastComponent = thisComponent
        end
    end,

    ---Sets the line spacing for all anchor frames and reorders their frames
    ---@param self anchorsystem
    ---@param spacing number The spacing between frames
    SetLineSpacing = function(self, spacing)
        self.lineSpacing = spacing

        for i = 1, #self.screenAnchors do
            local anchorFrame = self.screenAnchors[i]
            self:Reorder(anchorFrame)
        end
    end,

    ---Sets the grow direction for a specific anchor and immediately reorders its frames
    ---@param self anchorsystem
    ---@param anchorName string The name of the anchor whose grow direction to change
    ---@param growDirection string The new direction ("top", "bottom", "left", "right")
    SetGrowDirection = function(self, anchorName, growDirection)
        local anchorFrame = self:GetScreenAnchor(anchorName)
        if anchorFrame then
            anchorFrame.growDirection = growDirection
            self:Reorder(anchorFrame)
        end
    end,

    ---Shows a frame on the specified anchor
    ---@param self anchorsystem
    ---@param anchorName string The name of the anchor to show the frame on
    ---@param ... any Additional data to pass to the setup function
    ---@return any The frame that was shown
    ShowFrame = function(self, anchorName, ...)
        local anchorFrame = self:GetScreenAnchor(anchorName)
        local frame = anchorFrame.framePool:Acquire()
        frame:SetParent(anchorFrame)

        anchorFrame.setupFunction(anchorFrame, frame, ...)

        self:Reorder(anchorFrame)

        return frame
    end,

    ---Hides a frame from whichever anchor it is currently on
    ---@param self anchorsystem
    ---@param frame any The frame to hide
    HideFrame = function(self, frame)
        for i = 1, #self.screenAnchors do
            local anchorFrame = self.screenAnchors[i]
            local allComponentsShown = anchorFrame.framePool:GetAllInUse()

            for o = 1, #allComponentsShown do
                local thisComponent = allComponentsShown[o]
                if (thisComponent == frame) then
                    anchorFrame.framePool:Release(thisComponent)
                    self:Reorder(anchorFrame)
                    return
                end
            end
        end
    end,
}

---Creates a new independent anchor system instance
---@return anchorsystem screenanchors A new anchor system instance with all methods and isolated state
function detailsFramework:CreateAnchorSystem()
    ---@type anchorsystem
    ---@diagnostic disable-next-line: missing-fields
    local screenanchors = {}
    screenanchors.locked = false

    ---@type table The profile table for storing anchor positions
    screenanchors.profileTable = nil

    ---@type screenanchor[] All created screen anchors
    screenanchors.screenAnchors = {}

    ---@type number The spacing between frames when reordering
    screenanchors.lineSpacing = 1

    detailsFramework:Mixin(screenanchors, anchorSystemMixin)

    return screenanchors
end
