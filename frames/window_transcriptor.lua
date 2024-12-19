
local Details = _G.Details
---@type detailsframework
local detailsFramework = _G.DetailsFramework
local _, Details222 = ...
_ = nil

---@class transcriptor : table
---@field timeline df_timeline

---@class simplepanel
---@field RightResizerGrip button

---@class timeline : df_timeline
---@field OnMainFrameSizeChanged fun(self:timeline)

local transcriptor = {}

function Details222.CreateTranscriptorFrame()
    local defaultWidth = 1220
    local defaultHeight = 620
    local headerWidth = 150
    local windowTitle = "Details! Transcriptor"

    if (not Details.transcriptor_frame.width) then
        Details.transcriptor_frame.width = defaultWidth
        Details.transcriptor_frame.height = defaultHeight
    else
        defaultWidth = Details.transcriptor_frame.width
        defaultHeight = Details.transcriptor_frame.height
    end

    local transcriptorFrame = detailsFramework:CreateSimplePanel(UIParent, defaultWidth, defaultHeight, windowTitle, "DetailsTranscriptorFame", {UseScaleBar = false, NoScripts = true})

    detailsFramework:MakeDraggable(transcriptorFrame)
    detailsFramework:ApplyStandardBackdrop(transcriptorFrame)
    transcriptorFrame:SetPoint("center", UIParent, "center", 0, -150)
    transcriptorFrame:SetFrameStrata("HIGH")
    transcriptorFrame:SetToplevel(true)

    local LibWindow = LibStub("LibWindow-1.1")
    LibWindow.RegisterConfig(transcriptorFrame, Details.transcriptor_frame)
    LibWindow.MakeDraggable(transcriptorFrame)
    LibWindow.RestorePosition(transcriptorFrame)

    local leftGrip, rightGrip = detailsFramework:CreateResizeGrips(transcriptorFrame, {width = 20, height = 20})
    leftGrip:Hide()
    transcriptorFrame.RightResizerGrip = rightGrip

    transcriptorFrame:SetResizable(true)
    transcriptorFrame:SetScript("OnSizeChanged", function()
        local timeline = transcriptor.timeline
        timeline.OnMainFrameSizeChanged(timeline)
        Details.transcriptor_frame.width = transcriptorFrame:GetWidth()
        Details.transcriptor_frame.height = transcriptorFrame:GetHeight()
    end)

    --> timeline
    ---@type df_elapsedtime_options
    ---@diagnostic disable-next-line: missing-fields
    local elapsedTimeOptions = {
        draw_line_color = {1, 1, 1, 0.1},
    }

    local onCreateLine = function(line)

    end

    local onRefreshLine = function(line)

    end

    local onEnterLine = function(line)

    end

    local onLeaveLine = function(line)

    end

    local onCreateBlock = function(block)

    end

    local onEnterBlock = function(block)

    end

    local onLeaveBlock = function(block)

    end

    local onClickBlock = function(block, mouseButton)

    end

    local onCreateBlockLengthFrame = function(blockLengthFrame)

    end

    local onEnterBlockLengthFrame = function(blockLengthFrame)

    end

    local onLeaveBlockLengthFrame = function(blockLengthFrame)

    end

    local onClickBlockLengthFrame = function(blockLengthFrame, mouseButton)

    end

    local timelineOptions = {
        width = transcriptorFrame:GetWidth() - 24 - headerWidth,
        height = transcriptorFrame:GetHeight() - 124,
        auto_height = false,
        can_resize = false,
        line_height = 20,
        line_padding = 1,
        zoom_out_zero = true,
        show_elapsed_timeline = true,
        elapsed_timeline_height = 20,
        header_width = 150,
        header_detached = true,
        backdrop_color = {0, 0, 0, 0.2},
        backdrop_color_highlight = {1, 1, 1, .5},

        header_on_enter = function(lineHeader)
            print("mouse entered header")
        end,

        header_on_leave = function(lineHeader)
            print("mouse left header")
        end,

        on_create_line = function(line)
            onCreateLine(line)
        end,

        on_refresh_line = function(line)
            onRefreshLine(line)
        end,

        on_enter = function(line) --on enter line
            onEnterLine(line)
        end,

        on_leave = function(line) --on leave line
            onLeaveLine(line)
        end,

        block_on_create = function(self)
            onCreateBlock(self)
        end,

        --on entering a spell icon
        block_on_enter = function(self)
            onEnterBlock(self)
        end,

        block_on_leave = function(self)
            onLeaveBlock(self)
        end,

        block_on_click = function(blockClicked, mouseButton)
            onClickBlock(blockClicked, mouseButton)
        end,

        block_on_create_blocklength = function(blockLengthFrame)
            onCreateBlockLengthFrame(blockLengthFrame)
        end,

        block_on_enter_blocklength = function(blockLengthFrame)
            onEnterBlockLengthFrame(blockLengthFrame)
        end,

        block_on_leave_blocklength = function(blockLengthFrame)
            onLeaveBlockLengthFrame(blockLengthFrame)
        end,

        block_on_click_blocklength = function(blockLengthFrame, mouseButton)
            onClickBlockLengthFrame(blockLengthFrame, mouseButton)
        end,

        scale_min = 0.1, --number

        --block_on_set_data = function(blockFrame, blockData)
        --end,

        --pixels_per_second number
        --scale_max number
        --backdrop backdrop
        --backdrop_color number[]
        --backdrop_color_highlight number[]
        --backdrop_border_color number[]
        --slider_backdrop backdrop
        --slider_backdrop_color number[]
        --slider_backdrop_border_color number[]
        --title_template string "ORANGE_FONT_TEMPLATE"
        --text_tempate string "OPTIONS_FONT_TEMPLATE"
    }

    ---@type timeline
    local timelineFrame, timelineHeader = detailsFramework:CreateTimeLineFrame(transcriptorFrame, "$parentTimeLineH", timelineOptions, elapsedTimeOptions)
    timelineFrame:SetPoint("topleft", transcriptorFrame, "topleft", headerWidth + 2, -56)
    transcriptor.timeline = timelineFrame

    function timelineFrame.OnMainFrameSizeChanged(self)
        local width, height = transcriptorFrame:GetSize()
        self:SetSize(width - headerWidth - 22, height - 124)
        self:OnSizeChanged()
    end

end