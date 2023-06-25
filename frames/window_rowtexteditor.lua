
local Details = _G.Details
local detailsFramework = _G.DetailsFramework
local Loc = LibStub("AceLocale-3.0"):GetLocale("Details")

local windowWidth = 950
local scrollWidth = 825

local panel = Details:CreateWelcomePanel("DetailsWindowOptionsBarTextEditor", nil, windowWidth, 600, true)
panel:SetPoint("center", UIParent, "center")
panel:Hide()
panel:SetFrameStrata("FULLSCREEN")
detailsFramework:ApplyStandardBackdrop(panel)
detailsFramework:CreateTitleBar(panel, "Details! Custom Line Text Editor")

function panel:Open(text, callback, host, default)
    if (host) then
        panel:ClearAllPoints()
        panel:SetPoint("center", host, "center")
    end

    text = text:gsub("||", "|")
    panel.default_text = text
    panel.editbox:SetText(text)
    panel.callback = callback
    panel.default = default or ""
    panel:Show()
end

local y = -32
local buttonTemplate = detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

local codeEditor = detailsFramework:NewSpecialLuaEditorEntry(panel, scrollWidth, 555, "editbox", "$parentEntry")
codeEditor:SetPoint("topleft", panel, "topleft", 10, y)
detailsFramework:ApplyStandardBackdrop(codeEditor)
detailsFramework:SetFontSize(codeEditor.editbox, 14)
detailsFramework:ReskinSlider(codeEditor.scroll)

local arg1Button = detailsFramework:NewButton(panel, nil, "$parentButton1", nil, 80, 20, function() codeEditor.editbox:Insert("{data1}") end, nil, nil, nil, string.format(Loc ["STRING_OPTIONS_TEXTEDITOR_DATA"], "1"), 1)
local arg2Button = detailsFramework:NewButton(panel, nil, "$parentButton2", nil, 80, 20, function() codeEditor.editbox:Insert("{data2}") end, nil, nil, nil, string.format(Loc ["STRING_OPTIONS_TEXTEDITOR_DATA"], "2"), 1)
local arg3Button = detailsFramework:NewButton(panel, nil, "$parentButton3", nil, 80, 20, function() codeEditor.editbox:Insert("{data3}") end, nil, nil, nil, string.format(Loc ["STRING_OPTIONS_TEXTEDITOR_DATA"], "3"), 1)
arg1Button:SetPoint("topright", panel, "topright", -12, y)
arg2Button:SetPoint("topright", panel, "topright", -12, y -(20*1))
arg3Button:SetPoint("topright", panel, "topright", -12, y -(20*2))
arg1Button:SetTemplate(buttonTemplate)
arg2Button:SetTemplate(buttonTemplate)
arg3Button:SetTemplate(buttonTemplate)
arg1Button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_DATA_TOOLTIP"]
arg2Button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_DATA_TOOLTIP"]
arg3Button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_DATA_TOOLTIP"]

-- code author Saiket from  http://www.wowinterface.com/forums/showpost.php?p=245759&postcount=6
--- @return StartPos, EndPos of highlight in this editbox.
local function GetTextHighlight( self )
    local Text, Cursor = self:GetText(), self:GetCursorPosition();
    self:Insert( "" ); -- Delete selected text
    local TextNew, CursorNew = self:GetText(), self:GetCursorPosition();
    -- Restore previous text
    self:SetText( Text );
    self:SetCursorPosition( Cursor );
    local Start, End = CursorNew, #Text -( #TextNew - CursorNew );
    self:HighlightText( Start, End );
    return Start, End;
end

local StripColors;
do
    local CursorPosition, CursorDelta;
    --- Callback for gsub to remove unescaped codes.
    local function StripCodeGsub( Escapes, Code, End )
        if ( #Escapes % 2 == 0 ) then -- Doesn't escape Code
            if ( CursorPosition and CursorPosition >= End - 1 ) then
                CursorDelta = CursorDelta - #Code;
            end
            return Escapes;
        end
    end
    --- Removes a single escape sequence.
    local function StripCode( Pattern, Text, OldCursor )
        CursorPosition, CursorDelta = OldCursor, 0;
        return Text:gsub( Pattern, StripCodeGsub ), OldCursor and CursorPosition + CursorDelta;
    end
    --- Strips Text of all color escape sequences.
    -- @param Cursor  Optional cursor position to keep track of.
    -- @return Stripped text, and the updated cursor position if Cursor was given.
    function StripColors( Text, Cursor )
        Text, Cursor = StripCode( "(|*)(|c%x%x%x%x%x%x%x%x)()", Text, Cursor );
        return StripCode( "(|*)(|r)()", Text, Cursor );
    end
end

local COLOR_END = "|r";
--- Wraps this editbox's selected text with the given color.
local function ColorSelection( self, ColorCode )
    local Start, End = GetTextHighlight( self );
    local Text, Cursor = self:GetText(), self:GetCursorPosition();
    if ( Start == End ) then -- Nothing selected
        --Start, End = Cursor, Cursor; -- Wrap around cursor
        return; -- Wrapping the cursor in a color code and hitting backspace crashes the client!
    end
    -- Find active color code at the end of the selection
    local ActiveColor;
    if ( End < #Text ) then -- There is text to color after the selection
        local ActiveEnd;
        local CodeEnd, _, Escapes, Color = 0;
        while( true ) do
            _, CodeEnd, Escapes, Color = Text:find( "(|*)(|c%x%x%x%x%x%x%x%x)", CodeEnd + 1 );
            if ( not CodeEnd or CodeEnd > End ) then
                break;
            end
            if ( #Escapes % 2 == 0 ) then -- Doesn't escape Code
                ActiveColor, ActiveEnd = Color, CodeEnd;
            end
        end

        if ( ActiveColor ) then
            -- Check if color gets terminated before selection ends
            CodeEnd = 0;
            while( true ) do
                _, CodeEnd, Escapes = Text:find( "(|*)|r", CodeEnd + 1 );
                if ( not CodeEnd or CodeEnd > End ) then
                    break;
                end
                if ( CodeEnd > ActiveEnd and #Escapes % 2 == 0 ) then -- Terminates ActiveColor
                    ActiveColor = nil;
                    break;
                end
            end
        end
    end

    local Selection = Text:sub( Start + 1, End );
    -- Remove color codes from the selection
    local Replacement, CursorReplacement = StripColors( Selection, Cursor - Start );

    self:SetText(( "" ):join(
        Text:sub( 1, Start ),
        ColorCode, Replacement, COLOR_END,
        ActiveColor or "", Text:sub( End + 1 )
    ) );

    -- Restore cursor and highlight, adjusting for wrapper text
    Cursor = Start + CursorReplacement;
    if ( CursorReplacement > 0 ) then -- Cursor beyond start of color code
        Cursor = Cursor + #ColorCode;
    end
    if ( CursorReplacement >= #Replacement ) then -- Cursor beyond end of color
        Cursor = Cursor + #COLOR_END;
    end

    self:SetCursorPosition( Cursor );
    -- Highlight selection and wrapper
    self:HighlightText( Start, #ColorCode + ( #Replacement - #Selection ) + #COLOR_END + End );
end

local colorFunc = function(_, r, g, b, a)
    local hex = Details:hex(a * 255) .. Details:hex(r * 255) .. Details:hex(g * 255) .. Details:hex(b * 255)
    ColorSelection(codeEditor.editbox, "|c" .. hex)
end

local funcButton = detailsFramework:NewButton(panel, nil, "$parentButton4", nil, 80, 20, function() codeEditor.editbox:Insert("{func local player, combat = ...; return 0;}") end, nil, nil, nil, Loc ["STRING_OPTIONS_TEXTEDITOR_FUNC"], 1)
local colorButton = detailsFramework:NewColorPickButton(panel, "$parentButton5", nil, colorFunc)
colorButton:SetSize(80, 20)
colorButton:SetTemplate(buttonTemplate)

funcButton:SetPoint("topright", panel, "topright", -12, y -(20*3))
funcButton:SetTemplate(buttonTemplate)

colorButton.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_COLOR_TOOLTIP"]
funcButton.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_FUNC_TOOLTIP"]
local done = function()
    local text = panel.editbox:GetText()
    panel.callback(text)
    panel:Hide()
end

local applyButton = detailsFramework:NewButton(panel, nil, "$parentApply", nil, 80, 20, function() panel.callback(panel.editbox:GetText()) end, nil, nil, nil, "Apply", 1) --localize-me
applyButton:SetTemplate(buttonTemplate)
applyButton:SetPoint("topright", panel, "topright", -14, -128)

local okButton = detailsFramework:NewButton(panel, nil, "$parentButtonOk", nil, 80, 20, done, nil, nil, nil, Loc ["STRING_OPTIONS_TEXTEDITOR_DONE"], 1)
okButton.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_DONE_TOOLTIP"]
okButton:SetTemplate(buttonTemplate)
okButton:SetPoint("topright", panel, "topright", -14, -194)

local resetButton = detailsFramework:NewButton(panel, nil, "$parentDefaultOk", nil, 80, 20, function() codeEditor.editbox:SetText(panel.default); panel.callback(panel.editbox:GetText()) end, nil, nil, nil, Loc ["STRING_OPTIONS_TEXTEDITOR_RESET"], 1)
resetButton.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_RESET_TOOLTIP"]
resetButton:SetTemplate(buttonTemplate)
resetButton:SetPoint("topright", panel, "topright", -14, -150)

local cancelButton = detailsFramework:NewButton(panel, nil, "$parentDefaultCancel", nil, 80, 20, function() codeEditor.editbox:SetText(panel.default_text); done(); end, nil, nil, nil, Loc ["STRING_OPTIONS_TEXTEDITOR_CANCEL"], 1)
cancelButton.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_CANCEL_TOOLTIP"]
cancelButton:SetTemplate(buttonTemplate)
cancelButton:SetPoint("topright", panel, "topright", -14, -172)