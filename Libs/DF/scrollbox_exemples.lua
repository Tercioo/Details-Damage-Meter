

    --Documentation for scroll box
    --Scroll box example:

    local detailsFramework = DetailsFramework

    --a frame to use as parent
    local frame = CreateFrame("frame", "DetailsFrameworkScrollBarExample", UIParent)
    frame:SetSize(200, 500)
    frame:SetPoint("center", UIParent, "center", 0, 0)

    local amountOfLines = 10
    local lineHeight = 20

    --this is the function which will refresh the scroll box lines
    ---@param self df_scrollbox
    ---@param data table an indexed table with subtables holding the data necessary to refresh each line
    ---@param offset number used to know which line to start showing
    ---@param totalLines number of lines shown in the scroll box
    local refresFunc = function(self, data, offset, totalLines)
        for i = 1, totalLines do
            local index = i + offset
            local thisData = data[index]
            if (thisData) then
                local line = self:GetLine(i)
                --update the line with the data
                line.NameText:SetText(thisData.name)
                line:Show()
            end
        end
    end

    ---this function creates a new line for the scroll box
    ---@param self df_scrollbox
    ---@param index number line index
    local createLineFunc = function(self, index)
        --create a new line
        local line = CreateFrame("button", "$parentLine" .. index, self)
        line:SetPoint("topleft", self, "topleft", 0, lineHeight * index * -1)
        line:SetPoint("topright", self, "topright", 0, lineHeight * index * -1)
        line:SetHeight(lineHeight)

        --setup the line creating frames, texts and other widgets, they are refreshed in the refresFunc
        local nameText = line:CreateFontString(nil, "overlay", "GameFontNormal")
        nameText:SetPoint("left", line, "left", 2, 0)
        line.NameText = nameText

        return line
    end

    local dataPlaceholder = {}

    ---CreateScrollBox parameters:
    ---@param parent frame a frame to be the parent of the scroll box
    ---@param name string it is important to give a unique name to the scroll box frame
    ---@param refreshFunc the function which will refresh the scroll box lines
    ---@param data table the data table to be used to refresh the lines
    ---@param width number
    ---@param height number
    ---@param lineAmount number
    ---@param lineHeight number
    ---@param createLineFunc function?
    ---@param autoAmount boolean? it'll automatically calculate the amount of lines based on the height and lineHeight
    ---@param noScroll boolean? if true, the scroll box will not have a scrollbar
    ---@param noBackdrop boolean? if true, the scroll box will not have a backdrop

    local scrollBox = detailsFramework:CreateScrollBox(frame, "$parentScrollbox", refresFunc, dataPlaceholder, 1, 1, amountOfLines, lineHeight)
    --used 1 for width and height because we will set the size using anchors
    scrollBox:SetPoint("topleft", frame, "topleft", 0, 0)
    scrollBox:SetPoint("bottomright", frame, "bottomright", 0, 0)
    --appearance
    detailsFramework:ReskinSlider(scrollBox)

    frame.ScrollBox = scrollBox

    --manually create the lines when the createLineFunc is not provided
    for i = 1, amountOfLines do
        scrollBox:CreateLine(createLineFunc)
    end

    --if the data is not available at the time of creating the scroll box, you can set it later using SetData
    local newData = {
        {name = "Sarah"},
        {name = "John"},
        {name = "Michael"},
        {name = "Jessica"},
        {name = "Daniel"},
    }
    scrollBox:SetData(newData)

    --call a refresh in the scrollBox
    scrollBox:Refresh()

    --the method 'RefreshMe' can be used to manipulate data and then set it.
    --this is very usefull to keep the code organized, delegating data manipulation to the scroll box itself
    function scrollBox:RefreshMe()
        local newData = {
            {name = "Priest"},
            {name = "Warlock"},
            {name = "Warrior"},
        }
        self:SetData(newData)
        self:Refresh()
    end
