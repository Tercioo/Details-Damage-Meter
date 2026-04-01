cooltip.lua documentation — Part 1 (lines 2829–end)

=====================================================================
Overview
=====================================================================

- GameCooltip (aliased as GameCooltip2) is the DetailsFramework
  replacement for Blizzard's built-in tooltips. It supports three
  modes: plain tooltip, tooltip with status bars, and dropdown menus.
- A single global instance is created: GameCooltip (or GameCooltip2).
- The typical workflow is:
      GameCooltip:Reset()          -- wipe all state
      GameCooltip:SetType(...)     -- "tooltip", "tooltipbar", or "menu"
      GameCooltip:SetOwner(frame)  -- anchor to a frame
      GameCooltip:AddLine(...)     -- add content lines
      GameCooltip:AddIcon(...)     -- optional icon per line
      GameCooltip:AddStatusBar()   -- optional bar per line (type 2)
      GameCooltip:AddMenu(...)     -- for menus (type 3)
      GameCooltip:Show()           -- render and display
- Many parameters that accept a color (R, G, B, A numbers) also
  accept a color shortcut. See section 1 for how this works.


=====================================================================
1) Color shortcut system (DF:ParseColors)
=====================================================================

Anywhere a function documents parameters like (colorRed, colorGreen,
colorBlue, colorAlpha), you can instead pass ONE value in the first
parameter and the remaining parameters shift down. The framework calls
DF:ParseColors() internally. The accepted shortcut forms are:

    Color name string (HTML/CSS names)
        "red", "white", "orange", "transparent", "gold", "dodgerblue",
        "deeppink", etc. Full list in colors.lua. WoW class names also
        work: "HUNTER", "WARLOCK", "MAGE", etc.

    Hex string
        "#FF0000"          6-digit: RRGGBB, alpha defaults to 1
        "#80FF0000"        8-digit: AARRGGBB

    Table with indexed values
        {1, 0, 0, 1}      {R, G, B, A}

    Table with named keys
        {r=1, g=0, b=0, a=1}

    ColorTable mixin
        Any table with .IsColorTable = true and a :GetColor() method.

    Comma-separated string
        "1, 0, 0, 1"

    boolean or nil
        Treated as no color (0, 0, 0, 0).

When a function accepts (colorRed, colorGreen, colorBlue, colorAlpha)
and you pass a table or string as colorRed, the code detects the type
and shifts the subsequent parameters. For example in AddStatusBar:

    -- Explicit RGBA:
    GameCooltip:AddStatusBar(75, 1, 0.2, 0.8, 0.2, 1)
    -- Color shortcut (table), glow in next param:
    GameCooltip:AddStatusBar(75, 1, {0.2, 0.8, 0.2, 1}, true)
    -- Color name, glow in next param:
    GameCooltip:AddStatusBar(75, 1, "green", true)


=====================================================================
2) menuType parameter
=====================================================================

Many functions accept a menuType parameter. It determines whether the
content goes to the main frame (frame1) or the secondary/sub frame
(frame2). Accepted values:

    Main frame:     1, "main"
    Sub menu:       2, "sub"

When nil or unrecognized, it defaults to "main". The code calls
gameCooltip:ParseMenuType(menuType) internally.


=====================================================================
3) Reset()
=====================================================================

Signature
    GameCooltip:Reset(fromPreset)

Purpose
    Clears all tooltip/menu data and resets the cooltip to a clean
    state. Must be called before building new tooltip content.

Parameters
    fromPreset  (boolean, optional)
        Internal flag. When true, skips calling Preset(3) at the end
        (used by Preset() itself to avoid recursion). Normal callers
        should omit this or pass nil.

Behavior
    1. Resets frame positions, widths, parents, strata.
    2. Hides selected textures, rounded corners, banner images.
    3. Wipes ALL content tables: LeftTextTable, RightTextTable,
       LeftIconTable, RightIconTable, StatusBarTable, WallpaperTable,
       FunctionsTableMain, FunctionsTableSub, ParametersTableMain,
       ParametersTableSub, PopupFrameTable, and their sub-menu
       counterparts.
    4. Resets Indexes, SubIndexes, FixedValue, HaveSubMenu, etc.
    5. Calls ClearAllOptions() and sets both frames to "transparent".
    6. If not fromPreset, calls Preset(3) to apply the default look.
    7. Sets type to "tooltip".


=====================================================================
4) AddLine() / AddDoubleLine()
=====================================================================

Signature
    GameCooltip:AddLine(leftText, rightText, menuType, ColorR1,
        ColorG1, ColorB1, ColorA1, ColorR2, ColorG2, ColorB2,
        ColorA2, fontSize, fontFace, fontFlag, textWidth, textHeight,
        textContour)

    GameCooltip:AddDoubleLine(...)  -- alias, identical parameters

Purpose
    Adds a new line to the tooltip. This is the primary way to insert
    content. Each call increments the line index.

Parameters
    leftText    (string|number|nil)
        Text shown on the left side of the line. Numbers are
        auto-converted to strings. nil becomes "".

    rightText   (string|number|nil)
        Text shown on the right side of the line. Same coercion rules.

    menuType    (number|string|nil)
        1/"main" for main frame, 2/"sub" for sub frame. See section 2.

    ColorR1, ColorG1, ColorB1, ColorA1  (number or color shortcut)
        Color for the LEFT text. Supports color shortcuts: if ColorR1
        is a table, string, boolean, or nil, DF:ParseColors is called.
        When a shortcut is used the remaining color parameters shift:
            GameCooltip:AddLine("text", nil, 1, "orange")
        is the same as:
            GameCooltip:AddLine("text", nil, 1, 1, 0.647, 0, 1)

    ColorR2, ColorG2, ColorB2, ColorA2  (number or color shortcut)
        Color for the RIGHT text. Same shortcut support. When ColorR1
        uses a shortcut, ColorR2 starts at the position where ColorG1
        would normally be.

    fontSize    (number|nil)
        Font size for both left and right text on this line.

    fontFace    (string|nil)
        Font file path. nil uses the default.

    fontFlag    (string|nil)
        Font flags: "OUTLINE", "THICKOUTLINE", "MONOCHROME", etc.

    textWidth   (number|nil)
        Maximum pixel width for the text. Text wraps or truncates.

    textHeight  (number|nil)
        Explicit height for the text fontstring.

    textContour (any|nil)
        When truthy, draws a text contour (shadow/outline effect).

Examples
    -- Simple one-side line:
    GameCooltip:AddLine("Damage Done")

    -- Two-sided with right text:
    GameCooltip:AddLine("Damage Done", "1,234,567")

    -- With left color as name, right color as table:
    GameCooltip:AddLine("Damage", "1.2M", 1, "orange", {0.5, 1, 0.5, 1})

    -- Full RGBA for both sides:
    GameCooltip:AddLine("Hit", "456", 1, 1, 1, 1, 1, 0.5, 0.5, 0.5, 1)

    -- With font customization:
    GameCooltip:AddLine("Title", nil, 1, "white", nil, 14, nil, "OUTLINE")


=====================================================================
5) AddIcon() / AddTexture()
=====================================================================

Signature
    GameCooltip:AddIcon(iconTexture, menuType, side, iconWidth,
        iconHeight, leftCoord, rightCoord, topCoord, bottomCoord,
        overlayColor, point, desaturated, mask)

    GameCooltip:AddTexture(...)  -- alias, identical parameters

Purpose
    Adds an icon to the LAST line that was added with AddLine(). The
    icon appears on the left or right side of that line.

Requires
    At least one AddLine() call before this. Errors if Indexes == 0.

Parameters
    iconTexture     (string|number|TextureObject)
        Texture path (string), texture file ID (number), or an
        existing WoW Texture object. The framework calls
        DF:ParseTexture() which accepts all three forms.

    menuType        (number|string|nil)
        1/"main" for main frame, 2/"sub" for sub frame.

    side            (number|string|nil)
        Which side of the line to place the icon:
            1, "left"   — left side (default)
            2, "right"  — right side
            3, "top"    — top of sub button (sub menu only)

    iconWidth       (number|nil, default 16)
        Width in pixels.

    iconHeight      (number|nil, default 16)
        Height in pixels.

    leftCoord       (number|nil, default 0)
    rightCoord      (number|nil, default 1)
    topCoord        (number|nil, default 0)
    bottomCoord     (number|nil, default 1)
        Texture coordinates for the icon. Used to crop a region from
        a texture atlas.

    overlayColor    (table|string|nil)
        Vertex color overlay applied to the icon. Accepts a color
        shortcut: {R,G,B,A} table, color name string, or nil for
        white {1,1,1}.

    point           (any|nil)
        Custom anchor point data.

    desaturated     (boolean|nil)
        When true, the icon is shown desaturated (grayscale).

    mask            (any|nil)
        Mask texture to apply.

Examples
    -- Simple spell icon on the left:
    GameCooltip:AddIcon(136243, 1, 1, 20, 20, .1, .9, .1, .9)

    -- Interface path icon on the right:
    GameCooltip:AddIcon([[Interface\Icons\INV_Sword_04]], 1, "right", 16, 16)

    -- Icon with red overlay:
    GameCooltip:AddIcon(spellIcon, 1, "left", 20, 20, 0, 1, 0, 1, "red")

    -- Desaturated icon:
    GameCooltip:AddIcon(spellIcon, 1, 1, 20, 20, 0, 1, 0, 1, nil, nil, true)


=====================================================================
6) AddStatusBar()
=====================================================================

Signature
    GameCooltip:AddStatusBar(statusbarValue, menuType, colorRed,
        colorGreen, colorBlue, colorAlpha, statusbarGlow,
        backgroundBar, barTexture)

Purpose
    Attaches a status bar to the LAST line added. Only visible when
    the cooltip type is 2 ("tooltipbar") or 3 ("menu").

Requires
    At least one AddLine() call before this.

Parameters
    statusbarValue  (number, required)
        Fill percentage, 0–100. Determines how much of the bar is
        filled.

    menuType        (number|string|nil)
        1/"main" for main frame, 2/"sub" for sub frame.

    colorRed        (number|table|string|boolean)
        Red component (0–1). Supports color shortcuts:
        - If a table or string: calls DF:ParseColors. The glow and
          backgroundBar parameters shift to colorGreen and colorBlue:
              AddStatusBar(75, 1, "green", true, false)
              -- means: value=75, menu=1, color="green",
              --        glow=true, backgroundBar=false
        - If a boolean: treated as the glow flag; backgroundBar shifts
          to colorGreen. Color defaults to white (1,1,1,1):
              AddStatusBar(75, 1, true, false)
              -- means: value=75, menu=1, glow=true,
              --        backgroundBar=false, color=white

    colorGreen      (number|nil)
        Green component (0–1) when colorRed is a number.

    colorBlue       (number|nil)
        Blue component (0–1) when colorRed is a number.

    colorAlpha      (number|nil)
        Alpha component (0–1) when colorRed is a number.

    statusbarGlow   (boolean|nil)
        When true, a glow effect is shown on the bar.

    backgroundBar   (boolean|nil)
        When true, a background bar is drawn behind the status bar.

    barTexture      (string|nil)
        Texture path for the bar fill. nil uses the default set via
        SetOption("StatusBarTexture", ...).

Examples
    -- Simple green bar at 75%:
    GameCooltip:AddStatusBar(75, 1, 0, 1, 0, 1)

    -- Using color shortcut with glow:
    GameCooltip:AddStatusBar(50, 1, "dodgerblue", true)

    -- Using table color:
    GameCooltip:AddStatusBar(90, 1, {1, 0.5, 0, 1})


=====================================================================
7) AddStatusBar_MaxValue()
=====================================================================

Signature
    GameCooltip:AddStatusBar_MaxValue(statusbarValue,
        statusbarMaxValue, menuType, colorRed, colorGreen, colorBlue,
        colorAlpha, statusbarGlow, backgroundBar, barTexture)

Purpose
    Like AddStatusBar but takes an absolute value + max value pair
    instead of a percentage. The bar fills proportionally.

Parameters
    statusbarValue      (number, required)
        Current value.

    statusbarMaxValue   (number, required)
        Maximum value. The bar fills to (value / maxValue).

    menuType            (number|string|nil)
        Same as AddStatusBar.

    colorRed ... barTexture
        Same as AddStatusBar, including color shortcut support.

Example
    -- Bar showing 3500 out of 10000 HP:
    GameCooltip:AddStatusBar_MaxValue(3500, 10000, 1, "green")


=====================================================================
8) AddMenu()
=====================================================================

Signature
    GameCooltip:AddMenu(menuType, func, param1, param2, param3,
        leftText, leftIcon, indexUp)

Purpose
    Assigns a click callback to the current line (for menu mode).
    When the user clicks a menu line, func is called with the
    parameters. Can also create new sub-menu entries.

Requires
    At least one AddLine() call before this (Indexes > 0).
    The cooltip type is automatically set to "menu".

Parameters
    menuType    (number|string)
        1/"main" for main menu, 2/"sub" for sub menu.

    func        (function, required)
        The callback function. Called as:
            func(fixedValue, param1, param2, param3, button)
        where fixedValue is the value set via SetFixedParameter.

    param1      (any|nil)
        First parameter passed to func.

    param2      (any|nil)
        Second parameter passed to func.

    param3      (any|nil)
        Third parameter passed to func.

    leftText    (string|nil)
        Text label for a new sub-menu entry. When provided along
        with indexUp=true, a new sub-line is created.

    leftIcon    (string|number|nil)
        Icon for the sub-menu entry. Only used when leftText is
        provided. Shown at 16x16 with default tex coords.

    indexUp     (boolean|nil)
        When true (along with leftText), creates a new entry line
        for the menu or sub-menu instead of attaching to the
        current line.

Behavior
    Main menu:
        Stores func and params for the current line index. When
        leftText/leftIcon are provided, also populates the text
        and icon tables for that line.

    Sub menu:
        Creates an entry under the current main line's sub-menu.
        Requires leftText + indexUp to create a new sub-entry.

Example
    -- Main menu with callback:
    GameCooltip:AddLine("Option 1")
    GameCooltip:AddMenu(1, function(fixedValue, param1)
        print("Selected:", param1)
    end, "myParam")

    -- Sub menu entries:
    GameCooltip:AddLine("Has Sub Menu")
    GameCooltip:AddMenu(2, subFunc, "sub1", nil, nil, "Sub Option A", nil, true)
    GameCooltip:AddMenu(2, subFunc, "sub2", nil, nil, "Sub Option B", nil, true)


=====================================================================
9) AddPopUpFrame()
=====================================================================

Signature
    GameCooltip:AddPopUpFrame(onShowFunc, onHideFunc, param1, param2)

Purpose
    Registers popup callbacks for the current line. When the line's
    sub-menu is shown, onShowFunc fires. When hidden, onHideFunc fires.

Parameters
    onShowFunc  (function|nil)
        Called when the popup/sub-menu for this line is displayed.

    onHideFunc  (function|nil)
        Called when the popup/sub-menu is hidden.

    param1      (any|nil)
        First parameter forwarded to both callbacks.

    param2      (any|nil)
        Second parameter forwarded to both callbacks.


=====================================================================
10) AddSpecial()
=====================================================================

Signature
    GameCooltip:AddSpecial(widgetType, index, subIndex, ...)

Purpose
    Inserts content at a specific index position rather than appending
    to the end. Useful for injecting lines, icons, bars, or menus at
    arbitrary positions in an already-built tooltip.

Parameters
    widgetType  (string, required)
        One of: "line", "icon", "statusbar", "menu".

    index       (number, required)
        The main line index to insert at.

    subIndex    (number|nil)
        The sub-menu line index. If nil, operates on the main menu.

    ...         (varargs)
        The remaining arguments are forwarded to the corresponding
        function (AddLine, AddIcon, AddStatusBar, or AddMenu).

Example
    -- Insert a line at position 2:
    GameCooltip:AddSpecial("line", 2, nil, "Injected Line", "Value")

    -- Insert an icon at main index 3, sub index 1:
    GameCooltip:AddSpecial("icon", 3, 1, spellIcon, 2, 1, 20, 20)


=====================================================================
11) AddFromTable()
=====================================================================

Signature
    GameCooltip:AddFromTable(thisTable)

Purpose
    Bulk-adds content from an array of tables. Each entry can specify
    a menu callback, status bar, icon, or text line.

Parameters
    thisTable   (table, required)
        An array of entry tables. Each entry is checked in order:
        1. If entry.func exists → AddMenu(type, func, param1–3)
        2. If entry.statusbar exists → AddStatusBar(value, type, color)
        3. If entry.icon exists → AddIcon(icon, type, side, w, h, ...)
        4. If entry.textleft/textright/text → AddLine(text, "", type, color)

Entry table keys
    func        function    Menu callback
    param1–3    any         Parameters for the callback
    statusbar   boolean     Flag to add a status bar
    value       number      Status bar fill value
    icon        any         Icon texture
    side        number      Icon side (1=left, 2=right)
    width       number      Icon width
    height      number      Icon height
    l,r,t,b     number      Tex coords (left, right, top, bottom)
    color       any         Color (shortcut supported)
    type        number      menuType (default 1)
    textleft    string      Left text content
    textright   string      Right text content
    text        string      Left text (alternate key)


=====================================================================
12) SetType()
=====================================================================

Signature
    GameCooltip:SetType(newType)

Purpose
    Sets the cooltip display mode.

Parameters
    newType     (number|string, required)
        Number form:
            1  = plain tooltip
            2  = tooltip with status bars
            3  = dropdown menu
        String form:
            "tooltip"     = plain tooltip (type 1)
            "tooltipbar"  = tooltip with bars (type 2)
            "menu"        = dropdown menu (type 3)


=====================================================================
13) GetType() / IsMenu() / IsTooltip()
=====================================================================

GetType()
    Returns "tooltip" if type is 1 or 2, "menu" if type is 3,
    "none" otherwise.

IsMenu()
    Returns true if the cooltip is currently shown and is a menu.

IsTooltip()
    Returns true if the cooltip is currently shown and is a tooltip.


=====================================================================
14) SetOwner() / SetHost()
=====================================================================

Signature
    GameCooltip:SetOwner(frame, myPoint, hisPoint, x, y)
    GameCooltip:SetHost(frame, myPoint, hisPoint, x, y)

Purpose
    Anchors the cooltip to a frame. SetOwner is an alias for SetHost.
    The tooltip will appear relative to this frame.

Parameters
    frame       (WoW frame, required)
        The frame to anchor to. If a DetailsFramework widget is
        passed, .widget is used automatically.

    myPoint     (string|nil)
        Anchor point on the cooltip: "bottom", "top", "left", etc.
        Defaults to "bottom".

    hisPoint    (string|nil)
        Anchor point on the host frame. Defaults to "top".

    x           (number|nil)
        Horizontal offset. Defaults to 0.

    y           (number|nil)
        Vertical offset. Defaults to 0.


=====================================================================
15) GetOwner() / IsOwner()
=====================================================================

GetOwner()
    Returns the frame currently hosting the cooltip, or nil.

IsOwner(frame)
    Returns true if the given frame is the current host.


=====================================================================
16) SetColor()
=====================================================================

Signature
    GameCooltip:SetColor(menuType, ...)

Purpose
    Sets the background color of the main or sub frame.

Parameters
    menuType    (number|string)
        1/"main" or 2/"sub".

    ...         (color shortcut or R, G, B, A)
        Passed directly to DF:ParseColors. Accepts any color form.

Examples
    GameCooltip:SetColor(1, "transparent")
    GameCooltip:SetColor(1, 0.1, 0.1, 0.1, 0.95)
    GameCooltip:SetColor(2, {0.1, 0.1, 0.1, 0.95})


=====================================================================
17) SetBackdrop()
=====================================================================

Signature
    GameCooltip:SetBackdrop(menuType, backdrop, backdropcolor,
        bordercolor)

Purpose
    Sets the backdrop, backdrop color, and border color for the main
    or sub frame.

Parameters
    menuType        (number|string)
        1/"main" or 2/"sub".

    backdrop        (table|nil)
        A Blizzard backdrop table: {bgFile, edgeFile, edgeSize, ...}.
        nil leaves the current backdrop unchanged.

    backdropcolor   (color shortcut or nil)
        Background color. Accepts any form recognized by ParseColors.

    bordercolor     (color shortcut or nil)
        Border color. Same shortcut support.


=====================================================================
18) SetOption() / ClearAllOptions()
=====================================================================

SetOption(optionName, value)
    Sets a display option for the current tooltip build.

    optionName  (string, required)
        The option key. Aliases are resolved automatically (e.g.,
        "LeftPadding" → "LeftBorderSize").

    value       (any)
        The value for the option.

ClearAllOptions()
    Wipes all options and resets defaults:
        MyAnchor = "bottom"
        RelativeAnchor = "top"
        WidthAnchorMod = 0
        HeightAnchorMod = 0

Available options (see OptionsList):

    Layout:
        FixedWidth              number   Force tooltip width
        FixedHeight             number   Force tooltip height
        FixedWidthSub           number   Force sub-frame width
        FixedHeightSub          number   Force sub-frame height
        MinWidth                number   Minimum width
        HeighMod                number   Frame height offset
        HeighModSub             number   Sub-frame height offset
        TooltipFrameHeightOffset       number
        TooltipFrameHeightOffsetSub    number
        AlignAsBlizzTooltip     boolean  Match Blizzard tooltip style
        AlignAsBlizzTooltipFrameHeightOffset  number

    Text:
        TextSize                number   Default font size
        TextFont                string   Default font face
        TextColor               color    Default left text color
        TextColorRight          color    Default right text color
        TextShadow              any      Text outline/contour
        TextActuallyShadow      any      Actual drop shadow
        LeftTextWidth           number   Max left text width
        RightTextWidth          number   Max right text width
        LeftTextHeight          number   Left text height
        RightTextHeight         number   Right text height
        NoLanguageDetection     boolean  Skip font auto-detection

    Spacing:
        ButtonsYMod             number   Y offset for first line
        ButtonsYModSub          number   Y offset for first sub line
        YSpacingMod             number   Vertical gap between lines
        YSpacingModSub          number   Vertical gap in sub frame
        ButtonHeightMod         number   Line height offset
        ButtonHeightModSub      number   Sub-frame line height offset
        TextHeightMod           number   Text area height offset
        LeftBorderSize          number   Left padding offset
        RightBorderSize         number   Right padding offset
        TopBorderSize           number   Top padding offset
        RightTextMargin         number   Gap: right text to right icon

    Icons:
        IconSize                number   Override icon size
        IconHeightMod           number   Icon height offset
        IconBlendMode           string   Blend mode for icons
        IconBlendModeHover      string   Blend mode when hovered
        UseTrilinearLeft        boolean  Trilinear filtering left icon
        UseTrilinearRight       boolean  Trilinear filtering right icon

    Status bars:
        StatusBarHeightMod      number   Bar height offset
        StatusBarTexture        string   Bar fill texture path

    Spark (status bar highlight):
        SparkTexture            string   Spark texture path
        SparkHeight             number   Spark height
        SparkWidth              number   Spark width
        SparkHeightOffset       number   Y offset
        SparkWidthOffset        number   X offset
        SparkAlpha              number   Opacity
        SparkColor              color    Spark color
        SparkPositionXOffset    number   X position offset
        SparkPositionYOffset    number   Y position offset

    Anchor:
        MyAnchor                string   Tooltip anchor point
        Anchor                  string   Alternative anchor key
        RelativeAnchor          string   Host frame anchor point
        WidthAnchorMod          number   X anchor offset
        HeightAnchorMod         number   Y anchor offset

    Menus:
        SubMenuIsTooltip        boolean  Show sub-menu as tooltip
        SubFollowButton         boolean  Sub follows button position
        IgnoreSubMenu           boolean  Don't show sub-menus
        IgnoreArrows            boolean  Hide sub-menu arrows
        IgnoreButtonAutoHeight  boolean  Disable auto line heights
        NoLastSelectedBar       boolean  Hide selection highlight
        NoFade                  boolean  Disable fade animations

        SelectedTopAnchorMod    number   Selection bar offsets
        SelectedBottomAnchorMod number
        SelectedLeftAnchorMod   number
        SelectedRightAnchorMod  number

Aliases (friendlier names):
    LineHeightSizeOffset     → ButtonHeightMod
    LineHeightSizeOffsetSub  → ButtonHeightModSub
    FrameHeightSizeOffset    → HeighMod
    FrameHeightSizeOffsetSub → HeighModSub
    TextOutline              → TextShadow
    TextSilhouette           → TextActuallyShadow
    TextContour              → TextActuallyShadow
    LeftPadding              → LeftBorderSize
    RightPadding             → RightBorderSize
    LinePadding              → YSpacingMod
    VerticalPadding          → YSpacingMod
    LinePaddingSub           → YSpacingModSub
    VerticalPaddingSub       → YSpacingModSub
    LineYOffset              → ButtonsYMod
    VerticalOffset           → ButtonsYMod
    LineYOffsetSub           → ButtonsYModSub
    VerticalOffsetSub        → ButtonsYModSub


=====================================================================
19) SetFixedParameter() / GetFixedParameter()
=====================================================================

SetFixedParameter(value, injected)
    Sets a value that is passed as the first argument to all menu
    callback functions when a line is clicked.

    value       (any)
        The fixed value. When injected is nil, this is stored directly.

    injected    (any|nil)
        When present, value is treated as the host frame and injected
        is stored in frame.CoolTip.FixedValue. The FixedValue is
        still set to value for the cooltip itself.

GetFixedParameter()
    Returns the current fixed value.


=====================================================================
20) SetLastSelected() / Select()
=====================================================================

SetLastSelected(menuType, index, index2)
    Marks a menu line as the previously selected option. Only works
    when the cooltip type is "menu" (3).

    menuType    1/"main": sets SelectedIndexMain = index.
    menuType    2/"sub": sets SelectedIndexSec[index] = index2.

Select(menuType, option, mainIndex)
    Visually selects a menu line by showing the selection highlight.

    menuType    1: selects line 'option' on main frame.
    menuType    2: selects line 'option' on sub frame for mainIndex.


=====================================================================
21) SetWallpaper()
=====================================================================

Signature
    GameCooltip:SetWallpaper(menuType, texture, texcoord, color,
        bDesaturated, desaturation)

Purpose
    Sets a background image (wallpaper) behind the tooltip content.

Requires
    At least one AddLine() call.

Parameters
    menuType        (number|string)
        1/"main" or 2/"sub".

    texture         (string|number|TextureObject)
        Texture path, file ID, or texture object. Parsed via
        DF:ParseTexture().

    texcoord        (table|nil)
        {left, right, top, bottom} texture coordinates.
        Defaults to {0, 1, 0, 1}.

    color           (color shortcut|nil)
        Overlay/vertex color for the wallpaper.

    bDesaturated    (boolean|nil)
        When true, the wallpaper is desaturated.

    desaturation    (number|nil)
        Desaturation amount (0–1).


=====================================================================
22) SetBannerImage()
=====================================================================

Signature
    GameCooltip:SetBannerImage(menuType, index, texturePath, width,
        height, anchor, texCoord, overlay)

Purpose
    Places a banner image (decorative header/footer) on the tooltip.

Parameters
    menuType        (number|string)
        1/"main" or 2/"sub".

    index           (number, required)
        1 = primary banner (upperImage)
        2 = secondary banner (upperImage2)

    texturePath     (string|nil)
        Texture file path.

    width           (number|nil)
        Banner width in pixels.

    height          (number|nil)
        Banner height in pixels.

    anchor          (table|nil)
        Anchor point(s). Can be:
        - Single: {myAnchor, hisAnchor, x, y}
        - Multiple: {{myAnchor, hisAnchor, x, y}, {myAnchor, ...}}

    texCoord        (table|nil)
        {left, right, top, bottom} texture coordinates.

    overlay         (color shortcut|nil)
        Vertex color applied to the banner. Parsed via ParseColors.


=====================================================================
23) SetBannerText()
=====================================================================

Signature
    GameCooltip:SetBannerText(menuType, index, text, anchor, color,
        fontSize, fontFace, fontFlag)

Purpose
    Sets text on a banner position above the tooltip content.

Parameters
    menuType    (number|string)
        1/"main" or 2/"sub".

    index       (number, required)
        1 = primary text (tied to upperImage)
        2 = secondary text (tied to frame directly)

    text        (string|nil)
        The text to display.

    anchor      (table|nil)
        {myAnchor, hisAnchor, x, y}. For index 1, anchors relative
        to upperImage. For index 2, anchors relative to the frame.

    color       (color shortcut|nil)
        Text color. Supports all color shortcut forms.

    fontSize    (number|nil, default 13)
        Font size.

    fontFace    (string|nil)
        Font file. Defaults to DF:GetBestFontForLanguage().

    fontFlag    (string|nil)
        Font flags: "OUTLINE", "THICKOUTLINE", etc.


=====================================================================
24) SetNpcModel()
=====================================================================

Signature
    GameCooltip:SetNpcModel(menuType, npcId)

Purpose
    Shows a 3D model of an NPC in the tooltip frame.

Parameters
    menuType    (number|string)
        1/"main" or 2/"sub".

    npcId       (number, required)
        The NPC creature ID to display.


=====================================================================
25) SetSpellByID()
=====================================================================

Signature
    GameCooltip:SetSpellByID(spellId, bShowDescriptionOnly)

Purpose
    Auto-populates the tooltip with spell information: name, icon,
    resource cost, range, cast time, cooldown, and description.
    Calls Preset(2), AddLine, and AddIcon internally.

Parameters
    spellId             (number, required)
        The spell ID. Automatically resolves overridden spells via
        C_Spell.GetOverrideSpell.

    bShowDescriptionOnly  (boolean|nil)
        When true, only shows the spell name and description,
        omitting cost, range, cast time, and cooldown lines.


=====================================================================
26) Show() / ShowCooltip()
=====================================================================

Show(frame, menuType, color)
    Renders and displays the cooltip. This is the final call after
    building content.

    frame       (frame|nil)
        If provided, calls SetHost(frame) first. DetailsFramework
        widgets are unwrapped automatically.

    menuType    (number|string|nil)
        If provided, calls SetType(menuType).

    color       (color shortcut|nil)
        If provided, calls SetColor on both frames.

ShowCooltip(frame, menuType, color)
    The implementation behind Show(). Same parameters and behavior.


=====================================================================
27) Hide() / Close()
=====================================================================

Hide()
    Alias for Close().

Close()
    Fades out both frames, clears the host reference, stops cursor
    tracking, and releases any custom texture objects attached to
    line buttons.


=====================================================================
28) GetText() / GetNumLines()
=====================================================================

GetText(buttonIndex)
    Returns leftText, rightText for the given line index.

GetNumLines()
    Returns the total number of lines currently shown.


=====================================================================
29) Preset()
=====================================================================

Signature
    GameCooltip:Preset(presetId, fromReset)

Purpose
    Applies a preset visual theme. Calls Reset (unless fromReset is
    true) and configures common options.

Parameters
    presetId    (number, required)
        1  = Semi-transparent gray background.
        2  = Fixed width 220, default dark backdrop with border.
             Used by most DetailsFramework widgets.
        3  = Default dark backdrop with border. Applied automatically
             by Reset().

    fromReset   (boolean|nil)
        When true, skips calling Reset() to avoid recursion.

All presets set these common options:
    StatusBarTexture = WorldStateFrame highlight
    TextColor = "orange"
    TextSize = 11
    ButtonsYMod = -4
    YSpacingMod = -4
    IgnoreButtonAutoHeight = true


=====================================================================
30) QuickTooltip() / InjectQuickTooltip()
=====================================================================

QuickTooltip(host, ...)
    Convenience function that builds a simple tooltip from a list of
    strings. Calls Preset(2), SetHost, AddLine for each argument,
    and ShowCooltip.

    host    (frame, required)
        The anchor frame.

    ...     (strings)
        Each string becomes one tooltip line.

    Example:
        GameCooltip:QuickTooltip(myButton, "Line 1", "Line 2", "Line 3")

InjectQuickTooltip(host, ...)
    Like QuickTooltip but permanently hooks the frame's OnEnter and
    OnLeave scripts. The tooltip appears automatically on mouse-over.

    host    (frame, required)
    ...     (strings)

    Example:
        GameCooltip:InjectQuickTooltip(myButton, "Hover info", "More info")


=====================================================================
31) ExecFunc() / CoolTipInject()
=====================================================================

ExecFunc(host, fromClick)
    Executes the build function stored in host.CoolTip.BuildFunc.
    Used by the injection system to dynamically build tooltips.

    host        (frame, required)
        Must have a .CoolTip table with:
            BuildFunc       function  -- called to populate content
            Type            string    -- cooltip type
            FixedValue      any       -- fixed parameter
            MainColor       color     -- main frame background
            SubColor        color     -- sub frame background
            MyAnchor        string    -- tooltip anchor point
            HisAnchor       string    -- host anchor point
            X, Y            number    -- offsets
            Options         table|function  -- option overrides
            Default         string    -- fallback text if no lines added

    fromClick   (boolean|nil)
        When true, plays a flash animation on the frame.

CoolTipInject(host, openOnClick)
    Hooks a frame's OnEnter/OnLeave to automatically show/hide a
    cooltip built by host.CoolTip.BuildFunc.

    host            (frame, required)
        Must have a .CoolTip table (see ExecFunc).
        Original OnEnter/OnLeave scripts are preserved and called.

    openOnClick     (boolean|nil)
        When true and host is a Button, also hooks OnClick.

    Additional .CoolTip keys used by inject:
        ShowSpeed       number  -- delay before showing (default 0.2s)
        HideSpeed       number  -- delay before hiding (default 0.11s)
        OnEnterFunc     function  -- extra OnEnter callback
        OnLeaveFunc     function  -- extra OnLeave callback


=====================================================================
32) ShowMe()
=====================================================================

Signature
    GameCooltip:ShowMe(host, arg2)

Purpose
    Legacy function. If the mouse is not over the cooltip and either
    argument is nil/false, it calls Close(). Otherwise does nothing.
    Prefer using Close() or Hide() directly.


=====================================================================
End of Part 1
=====================================================================


=====================================================================
Part 2 — Positioning, overlap, building, and rendering internals
(lines 1841–2826)
=====================================================================

This part covers the internal engine: the functions that position
frames on screen, build tooltip/menu layouts, render text/icons/bars
into line buttons, and handle the sub-menu display. These functions
are called automatically by Show()/ShowCooltip(). Understanding them
is useful for advanced customization and debugging.


=====================================================================
33) SetMyPoint() — frame positioning and screen-bounds correction
=====================================================================

Signature
    GameCooltip:SetMyPoint(host, xOffset, yOffset)

Purpose
    Positions frame1 (the main tooltip) relative to the host frame
    using the anchor settings from OptionsTable. Automatically detects
    if the tooltip extends outside the screen and corrects the
    position.

Parameters
    host        (frame|nil)
        Not directly used for anchoring (anchor comes from
        OptionsTable.Anchor or gameCooltip.Host). Passed through
        for recursive calls.

    xOffset     (number|string|nil)
        Horizontal pixel offset. If the string "cursor" is passed,
        enables cursor-following mode (frame1.attachToCursor = true)
        and returns immediately.

    yOffset     (number|nil)
        Vertical pixel offset.

Behavior
    1. Anchors frame1 using:
       - OptionsTable.MyAnchor (tooltip anchor point)
       - OptionsTable.RelativeAnchor (host anchor point)
       - OptionsTable.WidthAnchorMod + xOffset (total X offset)
       - OptionsTable.HeightAnchorMod + yOffset + 10 (total Y offset)

    2. If xOffset was not provided, checks screen bounds:
       - If right edge extends past screen → shifts left
       - If left edge extends before 0 → shifts right
       Stores correction in gameCooltip.internal_x_mod.

    3. If yOffset was not provided, checks screen bounds:
       - If top edge extends past screen → shifts down
       - If bottom edge extends below 0 → shifts up
       Stores correction in gameCooltip.internal_y_mod.

    4. If any correction was needed, calls itself recursively with
       the computed offsets.

    5. If frame2 is shown and overlaps frame1, moves frame2 to the
       left side of frame1 (sets gameCooltip.frame2_leftside = true).


=====================================================================
34) CheckOverlap() — frame2 overlap detection
=====================================================================

Signature
    GameCooltip:CheckOverlap()

Purpose
    Checks if frame2 (sub-menu/secondary tooltip) overlaps frame1
    horizontally. If the right edge of frame1 extends past the left
    edge of frame2, moves frame2 to the left side of frame1.

Behavior
    Compares the horizontal endpoints of both frames. If frame2's
    left edge is inside frame1's right edge, re-anchors frame2 to
    "bottomright" of frame1's "bottomleft" and sets
    gameCooltip.frame2_IsOnLeftside = true.


=====================================================================
35) BuildTooltip() — main tooltip rendering
=====================================================================

Signature
    GameCooltip:BuildTooltip()

Purpose
    Renders the main tooltip frame (types 1 and 2). Called internally
    by ShowCooltip() when the type is "tooltip" or "tooltipbar".
    This is the core rendering function for tooltip mode.

Behavior
    1. Hides selection texture, disables mouse on frame1.

    2. Sets frame1 width to FixedWidth if specified.

    3. Iterates through all Indexes (lines):
       - Creates line buttons if they don't exist
         (CreateMainFrameButton).
       - Calls TextAndIcon() to render text, fonts, colors, icons.
       - Calls StatusBar() to render the bar if present.

    4. Hides any unused line buttons beyond Indexes.

    5. Calculates line heights and positions using one of three modes:

       AlignAsBlizzTooltip mode:
           Each line's height is the max of its text/icon heights.
           Lines stack with no spacing. Mimics Blizzard tooltip style.

       IgnoreButtonAutoHeight mode:
           Each line's height is the max of its text/icon heights.
           Lines stack with YSpacingMod gap and ButtonsYMod offset.

       Default mode:
           All lines use uniform height (frame1.hHeight = tallest
           line). Lines positioned at (i-1) * hHeight with TopBorderSize
           and ButtonsYMod offsets.

    6. Calculates frame width:
       - Type 2 (bars): content width + 34px padding.
       - Type 1 (plain): content width + 24px padding.
       - Width stability: avoids flickering by keeping previous width
         if new width is within ±5px.
       - Respects MinWidth and FixedWidth.

    7. Calculates frame height:
       - Uses matching mode (AlignAsBlizzTooltip, IgnoreButtonAutoHeight,
         or default). Minimum 22px.
       - Applies TooltipFrameHeightOffset and FixedHeight overrides.

    8. Sets up wallpaper if configured.

    9. Fades in frame1, calls SetMyPoint() for positioning.

    10. Refreshes spark positions on any visible status bars.

    11. If HaveSubMenu is true, calls BuildTooltipSecondFrame().
        Otherwise hides frame2.


=====================================================================
36) BuildTooltipSecondFrame() — secondary tooltip rendering
=====================================================================

Signature
    GameCooltip:BuildTooltipSecondFrame()

Purpose
    Renders the secondary tooltip frame (frame2) when the main
    tooltip has sub-menu content added via menuType 2/"sub". Called
    from BuildTooltip() when HaveSubMenu is true.

Behavior
    1. Flattens all sub-indexed content tables into single arrays:
       LeftTextTableSub, RightTextTableSub, LeftIconTableSub,
       RightIconTableSub, StatusBarTableSub, WallpaperTableSub,
       TopIconTableSub — all sub-entries across all main indexes
       are merged into sequential lists.

    2. Disables mouse on frame2 (non-interactive, tooltip mode).

    3. Creates line buttons (CreateButtonOnSecondFrame) as needed.

    4. For each line:
       - Calls TextAndIcon() to render text, fonts, colors, icons.
       - Calls StatusBar() to apply status bar settings.

    5. Calculates heights and positions using the same three modes
       as BuildTooltip (AlignAsBlizzTooltip, IgnoreButtonAutoHeight,
       default).

    6. Calculates width (same logic as BuildTooltip: stability check,
       MinWidth, FixedWidthSub).

    7. Calculates height with TooltipFrameHeightOffsetSub.

    8. Sets up wallpaper on frame2 if configured.

    9. Fades in frame2, refreshes spark positions.

    10. Checks horizontal overlap: if frame2 overlaps frame1, moves
        frame2 to the left side (bottomright → bottomleft).


=====================================================================
37) BuildCooltip() — menu rendering
=====================================================================

Signature
    GameCooltip:BuildCooltip(host)

Purpose
    Renders the cooltip as a dropdown menu (type 3). Called by
    ShowCooltip() when the type is "menu".

Parameters
    host    (frame|nil)
        Passed to SetMyPoint() for positioning.

Behavior
    1. If no lines exist (Indexes == 0), resets and shows a fallback
       "There is no options." tooltip.

    2. Creates/reuses line buttons (CreateMainFrameButton) and calls
       SetupMainButton() for each line — which renders text/icons,
       sets up status bars, and registers click handlers.

    3. Shows the selection highlight on SelectedIndexMain if set.

    4. Hides unused line buttons.

    5. For menu layout, lines can be:
       - "$div" divider: 4px tall with a horizontal divider bar.
         divider offset top/bottom come from LeftTextTable[i][2] and
         LeftTextTable[i][3].
       - Normal lines: height = hHeight + ButtonHeightMod. Positioned
         top-down with YSpacingMod spacing.

    6. Width: content + 24px. Added 16px extra if sub-menu arrows
       are shown. Respects FixedWidth, MinWidth.

    7. Height: hHeight * Indexes + 12 + HeighMod. Respects FixedHeight.

    8. Shows sub-menu arrows on lines that have sub-entries (unless
       IgnoreArrows or SubMenuIsTooltip).

    9. Positions with SetMyPoint(host).

    10. Shows title text/icon if configured.

    11. Shows wallpaper if configured.

    12. Fades in frame1.

    13. If the previously selected main index has sub entries, calls
        ShowSub() to display the sub-menu.


=====================================================================
38) ShowSub() — sub-menu display for menus
=====================================================================

Signature
    GameCooltip:ShowSub(index)

Purpose
    Builds and shows the sub-menu (frame2) for main menu line 'index'.
    Called when hovering over or clicking a main menu line that has
    sub-entries.

Parameters
    index   (number, required)
        The main menu line index whose sub-menu to display.

Behavior
    1. Returns early if IgnoreSubMenu option is set.

    2. Creates line buttons (CreateButtonOnSecondFrame) for each
       sub-entry and calls SetupButtonOnSecondFrame().

    3. If SubMenuIsTooltip: disables mouse on frame2 and all buttons.
       Otherwise enables mouse for interactive sub-menus.

    4. Shows selection highlight on SelectedIndexSec[index] if set.

    5. Hides unused sub-menu line buttons.

    6. Positions sub-entries top-down. Supports "$div" dividers same
       as BuildCooltip.

    7. Sets frame2 height: hHeight * subCount + 12 + HeighModSub.

    8. Shows TopIconTableSub[index] as upper image if present.

    9. Applies wallpaper from WallpaperTableSub[index] if present.

    10. Width: content + 44px (or FixedWidthSub).

    11. Fades in frame2, calls CheckOverlap().

    12. Positions frame2 relative to frame1:
        - SubFollowButton: anchors to the right (or left) of the
          specific main line button.
        - frame2_IsOnLeftside: anchors to frame1's left.
        - Default: anchors to frame1's right.


=====================================================================
39) HideSub()
=====================================================================

Signature
    GameCooltip:HideSub()

Purpose
    Hides the sub-menu frame (frame2) by fading it out.


=====================================================================
40) TextAndIcon() — line content renderer
=====================================================================

Signature
    GameCooltip:TextAndIcon(index, frame, menuButton, leftTextSettings,
        rightTextSettings, leftIconSettings, rightIconSettings,
        isSecondFrame)

Purpose
    Renders the text and icons for a single tooltip/menu line button.
    This is the workhorse that translates stored data arrays into
    visible UI elements. Called by BuildTooltip, BuildCooltipSecondFrame,
    SetupMainButton, and SetupButtonOnSecondFrame.

Parameters
    index               (number)
        The line index being rendered.

    frame               (frame)
        frame1 or frame2 — used for width tracking (frame.w, frame.hHeight).

    menuButton          (button)
        The line's button frame containing leftText, rightText,
        leftIcon, rightIcon fontstrings/textures.

    leftTextSettings    (table|nil)
        Data array from LeftTextTable[i]:
            [1] text string
            [2] red      [3] green    [4] blue     [5] alpha
            [6] fontSize  [7] fontFace [8] fontFlag
            [9] textWidth [10] textHeight [11] textContour/shadow color

    rightTextSettings   (table|nil)
        Data array from RightTextTable[i]. Same structure as left.

    leftIconSettings    (table|nil)
        Data array from LeftIconTable[i]:
            [1] texture (path, ID, or TextureObject)
            [2] width    [3] height
            [4] left     [5] right    [6] top      [7] bottom  (texcoords)
            [8] overlayColor (table or color shortcut)
            [9] desaturated (boolean)
            [10] mask texture

    rightIconSettings   (table|nil)
        Same structure as leftIconSettings.

    isSecondFrame       (boolean|nil)
        When true, width tracking uses frame2 logic (FixedWidthSub).

Text rendering behavior
    1. Resets text dimensions to 0.
    2. Language detection: if TextFont is not set and
       NoLanguageDetection is false, detects the language of the text
       and selects an appropriate font (e.g., CJK fonts for Chinese).
    3. Color: if RGBA is all zeros (0,0,0,0), falls back to
       OptionsTable.TextColor (left) or TextColorRight (right).
    4. Font size: per-line fontSize > OptionsTable.TextSize > 10.
    5. Font face: per-line fontFace > OptionsTable.TextFont > default.
       Supports SharedMedia font names.
    6. Font flags (outline): per-line fontFlag > OptionsTable.TextShadow.
    7. Text shadow color: per-line textContour > OptionsTable.TextActuallyShadow > black.
    8. Width/height constraints from options: LeftTextWidth,
       RightTextWidth, LeftTextHeight, RightTextHeight.
    9. Per-line overrides for width (leftTextSettings[9]) and
       height (leftTextSettings[10]).

Icon rendering behavior
    1. If icon is a TextureObject (a real WoW Texture): parents it
       to the button, positions it over the placeholder icon, stores
       as menuButton.customLeftTexture / customRightTexture.
    2. Otherwise sets the texture path/ID on the built-in icon.
    3. Applies texcoords, size, overlay color (ParseColors), blend
       mode (IconBlendMode option), desaturation, and mask.
    4. If OptionsTable.IconSize is set, overrides all icon sizes.

Width tracking
    After rendering, calculates total content width:
    leftTextWidth + rightTextWidth + leftIconWidth + rightIconWidth.
    Updates frame.w if this line is wider. Also tracks the tallest
    line height in frame.hHeight.

For type 2 (tooltip with bars), calls LeftTextSpace() to constrain
the left text width to fit within the bar area.


=====================================================================
41) StatusBar() — status bar renderer
=====================================================================

Signature
    GameCooltip:StatusBar(menuButton, statusBarSettings)

Purpose
    Configures the status bar on a line button. Called for each line
    during tooltip/menu building.

Parameters
    menuButton          (button)
        The line button containing .statusbar, .statusbar2, .spark,
        .spark2 elements.

    statusBarSettings   (table|nil)
        Data array from StatusBarTable[i]:
            [1] value (0–100 or absolute when using MaxValue)
            [2] red    [3] green   [4] blue    [5] alpha
            [6] glow (boolean) — show spark
            [7] backgroundBar — table with:
                .value    number   (fill value)
                .texture  string   (bar texture)
                .color    color    (bar color, shortcut supported)
                .specialSpark boolean (show spark2)
            [8] barTexture (string) — overrides StatusBarTexture option
            [9] maxValue (only from AddStatusBar_MaxValue)

        When nil, the bar is hidden (value set to 0, sparks hidden).

Behavior
    1. Sets statusbar value (clamped to 0–maxStatusBarValue).
    2. Sets statusbar color from RGBA.
    3. Sets height: 20 + StatusBarHeightMod option.
    4. Shows/hides spark based on glow flag.
    5. Configures statusbar2 (background bar) if provided.
    6. Sets bar texture: per-bar > StatusBarTexture option > default.
       Supports SharedMedia texture lookup.
    7. Positions bar: respects LeftBorderSize and RightBorderSize
       padding options.


=====================================================================
42) RefreshSpark() — spark position updater
=====================================================================

Signature
    GameCooltip:RefreshSpark(menuButton)

Purpose
    Recalculates spark position on a status bar after the bar's
    value or width has changed.

Behavior
    Reads spark options (SparkTexture, SparkWidth, SparkHeight,
    SparkAlpha, SparkColor, SparkWidthOffset, SparkHeightOffset,
    SparkPositionXOffset, SparkPositionYOffset) and positions the
    spark at the bar's current fill point.


=====================================================================
43) SetupMainButton() — main menu line setup
=====================================================================

Signature
    GameCooltip:SetupMainButton(menuButton, index)

Purpose
    Configures a main frame line button for menu mode. Called by
    BuildCooltip() for each line.

Behavior
    1. Calls TextAndIcon() with the main frame's text/icon data.
    2. Calls StatusBar() with the main frame's bar data.
    3. Registers left-click via RegisterForClicks("LeftButtonDown").
    4. Calculates content width and updates frame1.w.
    5. Sets OnClick to the main button click handler
       (OnClickFunctionMainButton).


=====================================================================
44) SetupButtonOnSecondFrame() — sub-menu line setup
=====================================================================

Signature
    GameCooltip:SetupButtonOnSecondFrame(menuButton, index,
        mainMenuIndex)

Purpose
    Configures a secondary frame line button for sub-menu mode.
    Called by ShowSub() for each sub-entry.

Parameters
    menuButton      (button)
    index           (number) — sub-menu line index
    mainMenuIndex   (number) — parent main menu line index

Behavior
    1. Sets menuButton.index and menuButton.mainIndex.
    2. Calls TextAndIcon() with the sub-menu's text/icon data
       (indexed by [mainMenuIndex][index]).
    3. Calls StatusBar() with sub-menu bar data.
    4. Registers left-click.
    5. Positions the button top-down in frame2.
    6. Tracks content width in frame2.w.
    7. Sets OnClick to sub button click handler
       (OnClickFunctionSecondaryButton).


=====================================================================
45) SetupWallpaper() — wallpaper texture renderer
=====================================================================

Signature
    GameCooltip:SetupWallpaper(wallpaperTable, wallpaper)

Purpose
    Applies wallpaper settings to a texture object. Used for both
    frame1 and frame2 wallpapers.

Parameters
    wallpaperTable  (table)
        Data array from WallpaperTable:
            [1] texture (path/color name/table)
            [2] leftCoord   [3] rightCoord
            [4] topCoord    [5] bottomCoord
            [6] overlayColor (table, shortcut supported)
            [7] bDesaturated (boolean)
            [8] desaturation (number, 0–1)

    wallpaper       (texture)
        The texture object to configure (frame.frameWallpaper).

Behavior
    - If texture is a color name or table, uses SetColorTexture.
    - Otherwise sets the texture path.
    - Applies texcoords, vertex color, desaturation.
    - Shows the texture.


=====================================================================
46) CreateDivBar() — divider bar creation
=====================================================================

Signature
    GameCooltip:CreateDivBar(button)

Purpose
    Creates a thin horizontal divider texture on a line button.
    Used when a line's left text is "$div".

Behavior
    Creates a desaturated texture from the quest auto-accept art,
    3px tall, 10% alpha. Stored as button.divbar.


=====================================================================
47) LeftTextSpace() — text width constraint for bar mode
=====================================================================

Signature
    GameCooltip:LeftTextSpace(row)

Purpose
    Constrains the left text width on a line when the cooltip type
    is 2 (tooltip with bars). Ensures text doesn't overlap the
    right-side content.

Behavior
    Sets leftText width to: row width - 30 - leftIcon width -
    rightIcon width - rightText string width.
    Sets leftText height to 10.


=====================================================================
48) Divider lines ("$div" special text)
=====================================================================

When AddLine() is called with leftText = "$div", the line is treated
as a horizontal divider instead of a text line.

For main menus (BuildCooltip):
    - Line height is set to 4px.
    - A desaturated divider bar is shown across the line.
    - LeftTextTable[i][2] = top offset (number, pixels above)
    - LeftTextTable[i][3] = bottom offset (number, pixels below)
    These offsets adjust the divider's spacing from adjacent lines.

For sub-menus (ShowSub):
    - Same behavior, but offsets come from
      RightTextTableSub[index][i][2] and [3].

Example
    -- Add a divider between menu sections:
    GameCooltip:AddLine("Option A")
    GameCooltip:AddMenu(1, funcA, "a")
    GameCooltip:AddLine("$div")        -- divider line
    GameCooltip:AddLine("Option B")
    GameCooltip:AddMenu(1, funcB, "b")

    -- Divider with 8px space above and 4px below:
    GameCooltip:AddLine("$div", nil, 1, 8, 4)
    -- (ColorR1 position = top offset, ColorG1 = bottom offset)


=====================================================================
49) Line height calculation modes
=====================================================================

Three mutually exclusive modes determine how line heights are
computed in both BuildTooltip() and BuildCooltip():

AlignAsBlizzTooltip (option)
    Each line's height = max(2, leftText height, rightText height,
    leftIcon height, rightIcon height, AlignAsBlizzTooltipForceHeight).
    Lines stack tightly with no extra spacing. This mode produces
    Blizzard-like compact tooltips. TopBorderSize sets the initial
    top offset.

IgnoreButtonAutoHeight (option)
    Each line's height = max(text/icon heights). Lines stack with
    YSpacingMod spacing and ButtonsYMod vertical offset. The total
    frame height is computed from accumulated heightValue.

Default mode
    All lines share uniform height = frame.hHeight (the tallest
    line). Lines positioned at (i-1) * hHeight + TopBorderSize +
    ButtonsYMod + accumulated YSpacingMod. This gives evenly spaced
    rows suitable for menus.


=====================================================================
50) Width calculation behavior
=====================================================================

For tooltips (type 1):
    Width = max content width + 24px padding.
    Width stability: if the new width is within ±5px of the last
    shown width, the old width is kept to prevent flickering during
    mouse-over updates.

For tooltip with bars (type 2):
    Width = max content width + 34px padding (extra for the bar).

For menus (type 3):
    Width = max content width + 24px. Extra 16px if sub-menu arrows
    are visible.

All modes respect FixedWidth (overrides completely), MinWidth
(floor), and FixedWidthSub for the secondary frame.


=====================================================================
End of Part 2
=====================================================================


=====================================================================
Part 3 — Text, icon, status bar, and button rendering internals
(lines 1031–1839)
=====================================================================

These functions are the low-level renderers that translate stored
data arrays into visible UI elements on each line button. They are
called automatically by the build functions documented in Part 2.
Understanding them is useful for debugging display issues, extending
the tooltip system, or creating custom rendering pipelines.


=====================================================================
51) TextAndIcon() — full internal reference
=====================================================================

Signature
    GameCooltip:TextAndIcon(index, frame, menuButton,
        leftTextSettings, rightTextSettings,
        leftIconSettings, rightIconSettings, isSecondFrame)

Purpose
    Renders all visual elements (left text, right text, left icon,
    right icon) for a single tooltip/menu line. This is the largest
    internal function in cooltip.lua and is responsible for converting
    the raw data arrays stored by AddLine()/AddIcon() into the
    actual font strings and textures the player sees.

Called by
    - SetupMainButton()             (menu mode, main frame)
    - SetupButtonOnSecondFrame()    (menu mode, sub frame)
    - BuildTooltip()                (tooltip mode, main frame)
    - BuildTooltipSecondFrame()     (tooltip mode, sub frame)

Parameters
    index               (number)
        Line index being rendered.

    frame               (frame)
        frame1 or frame2. Used for width (frame.w) and height
        (frame.hHeight) accumulation across all lines.

    menuButton          (button)
        The line's button widget. Contains these child objects:
            .leftText       FontString
            .rightText      FontString
            .leftIcon       Texture
            .rightIcon      Texture
            .leftIconMask   MaskTexture
            .rightIconMask  MaskTexture
            .statusbar      StatusBar
            .statusbar2     StatusBar (background bar)
            .spark          Texture (spark on statusbar)
            .spark2         Texture (spark on statusbar2)

    leftTextSettings    (table|nil)
        LeftTextTable[index] — array with:
            [1]  text           (string)
            [2]  colorRed       (number, 0–1)
            [3]  colorGreen     (number, 0–1)
            [4]  colorBlue      (number, 0–1)
            [5]  colorAlpha     (number, 0–1)
            [6]  fontSize       (number|nil)
            [7]  fontFace       (string|nil — font name or SharedMedia key)
            [8]  fontFlag       (string|nil — "OUTLINE", "THICKOUTLINE", etc.)
            [9]  textWidth      (number|nil — per-line width override)
            [10] textHeight     (number|nil — per-line height override)
            [11] shadowColor    (color|nil — ParseColors-compatible)

    rightTextSettings   (table|nil)
        RightTextTable[index] — same structure as leftTextSettings.

    leftIconSettings    (table|nil)
        LeftIconTable[index] — array with:
            [1]  texture        (string|number|TextureObject)
            [2]  width          (number)
            [3]  height         (number)
            [4]  texCoordLeft   (number, 0–1)
            [5]  texCoordRight  (number, 0–1)
            [6]  texCoordTop    (number, 0–1)
            [7]  texCoordBottom (number, 0–1)
            [8]  overlayColor   (color — ParseColors-compatible)
            [9]  desaturated    (boolean)
            [10] maskTexture    (string|nil — custom mask path)

    rightIconSettings   (table|nil)
        RightIconTable[index] — same structure as leftIconSettings.

    isSecondFrame       (boolean|nil)
        When true, width tracking uses FixedWidthSub logic for the
        secondary frame instead of FixedWidth.


---------------------------------------------------------------------
51a) Text rendering pipeline (left and right)
---------------------------------------------------------------------

The same pipeline runs for both left and right text, with minor
differences noted below.

Step 1 — Reset
    Sets text width and height to 0. Positions rightText relative
    to rightIcon with RightTextMargin offset (default -3).

Step 2 — Language detection
    Runs only when:
        - OptionsTable.NoLanguageDetection is false (default)
        - OptionsTable.TextFont is not set (font not forced)
    Calls DF.Language.DetectLanguageId() on the text string. If the
    detected language differs from menuButton.leftText.languageId:
        - Gets the appropriate font via GetFontForLanguageID().
        - Sets the font face with DF:SetFontFace().
        - For non-Latin alphabets (CJK, Cyrillic, etc.), stores the
          font as menuButton.leftText.requiredFont to ensure the
          font chain (step 5) does not override it.

Step 3 — Text color
    Reads RGBA from settings[2..5].
    If all four are 0 (the default when AddLine omitted colors):
        Left text:  falls back to OptionsTable.TextColor, then white.
        Right text: falls back to OptionsTable.TextColorRight, then
                    OptionsTable.TextColor, then white.

Step 4 — Font size
    Priority: OptionsTable.TextSize (if settings[6] is nil) >
              settings[6] (per-line override) > 10 (hardcoded default).

Step 5 — Font face resolution chain
    This is the most complex part. The font is resolved in order:

    1. requiredFont (set by language detector for non-Latin text)
       → Uses this font, ignoring all other settings.

    2. OptionsTable.TextFont (global options font, per-line not set)
       a. If _G[TextFont] exists → SetFontObject (treats as global
          font object name).
       b. Otherwise → SharedMedia:Fetch("font", TextFont) and calls
          SetFont with resolved size/flags.

    3. settings[7] (per-line font face from AddLine)
       a. If _G[fontFace] exists → SetFontObject, then re-applies
          size/flags from settings[6]/[8] or options.
       b. Otherwise → SharedMedia:Fetch("font", fontFace).

    4. Default → parseFont(gameCooltip.defaultFont) which calls
       DF:GetBestFontForLanguage(). Size = settings[6] or
       OptionsTable.TextSize or 10. Flags = settings[8] or
       OptionsTable.TextShadow or "".

Step 6 — Font outline
    settings[8] (per-line flag) > "NONE" (default).
    Applied via DF:SetFontOutline().

Step 7 — Text dimension constraints
    LeftTextWidth / RightTextWidth options override the fontstring
    width. LeftTextHeight / RightTextHeight override height.
    If not set, dimensions are 0 (auto-sized by WoW).

Step 8 — Text shadow color
    settings[11] (per-line) > OptionsTable.TextActuallyShadow >
    default black (0, 0, 0, 1).
    All values parsed through DF:ParseColors() to support shortcuts.

Step 9 — Text positioning
    leftText is anchored to leftIcon center and "right of leftIcon"
    with a 3px gap +  TextHeightMod vertical offset.
    rightText is anchored to "left of rightIcon" with
    RightTextMargin offset.


---------------------------------------------------------------------
51b) Icon rendering pipeline (left and right)
---------------------------------------------------------------------

The same pipeline runs for both left and right icons.

Step 1 — Presence check
    If iconSettings is nil or iconSettings[1] is nil, the icon is
    hidden (texture cleared, size set to 1×1). Any previously attached
    custom texture object is hidden and dereferenced.

Step 2 — Texture Object detection
    If iconSettings[1] is a table with :GetObjectType() == "Texture",
    it is treated as a real WoW Texture widget:
        - The built-in icon is set to a tiny placeholder color.
        - The texture object is reparented to the button.
        - All anchor points are copied from the built-in icon.
        - Stored as menuButton.customLeftTexture or customRightTexture.
    Otherwise, the built-in icon's texture is set via SetTexture()
    with CLAMP wrapping and LINEAR filtering (or TRILINEAR if
    UseTrilinearLeft/UseTrilinearRight option is set).

Step 3 — Size and texcoords
    Width/height from iconSettings[2]/[3].
    TexCoords from iconSettings[4..7] (left, right, top, bottom).

Step 4 — Mask texture
    iconSettings[10] overrides the mask. Default mask is
    Interface\COMMON\common-iconmask (Dragonflight+) or
    Interface\CHATFRAME\chatframebackground (older clients).

Step 5 — Vertex color
    iconSettings[8] parsed through DF:ParseColors(). Applied to
    the texture object (custom or built-in).

Step 6 — Blend mode
    OptionsTable.IconBlendMode or "BLEND" (default).

Step 7 — Desaturation
    iconSettings[9] passed to SetDesaturated().

Note (right icon)
    When a right-side TextureObject is passed, there is a known
    behavior: the placeholder size is set from leftIconSettings[2]/[3]
    instead of rightIconSettings[2]/[3]. This is a code quirk across
    all versions.


---------------------------------------------------------------------
51c) Icon size override
---------------------------------------------------------------------

After both icons are rendered, if OptionsTable.IconSize is set,
it overrides all four icon dimensions (left width, left height,
right width, right height) to this single value.


---------------------------------------------------------------------
51d) Type 2 text constraint
---------------------------------------------------------------------

For type 2 (tooltip with bars), calls LeftTextSpace() immediately
after icon rendering to constrain the left text width so it fits
alongside the status bar and right-side content.

After this, OptionsTable.LeftTextHeight and RightTextHeight may
further override the fontstring heights.


---------------------------------------------------------------------
51e) Width and height accumulation
---------------------------------------------------------------------

After all rendering, the function measures:
    leftTextWidth       GetStringWidth() of left fontstring
    rightTextWidth      GetStringWidth() of right fontstring
    leftIconWidth       GetWidth() of left icon
    rightIconWidth      GetWidth() of right icon
    leftTextHeight      GetStringHeight() of left fontstring
    rightTextHeight     GetStringHeight() of right fontstring

Secret value check: if any of these values are "secret" (a WoW
client protection for hidden data), the width/height accumulation
is skipped entirely for this line.

Width tracking (main frame, not FixedWidth):
    stringWidth = leftText + rightText + leftIcon + rightIcon + 10
    Updates frame.w if this line is wider.

Width tracking (main frame, FixedWidth):
    Forces leftText width = FixedWidth - leftIcon - rightText -
    rightIcon - 22.

Width tracking (sub frame, not FixedWidthSub):
    stringWidth = leftText + rightText + leftIcon + rightIcon
    Updates frame.w if wider.

Width tracking (sub frame, FixedWidthSub):
    Forces leftText width = FixedWidthSub - leftIcon - 12.

Height tracking:
    height = max(leftIcon height, rightIcon height,
                 leftTextHeight, rightTextHeight)
    Updates frame.hHeight if this line is taller.


---------------------------------------------------------------------
51f) Per-line dimension overrides
---------------------------------------------------------------------

After width/height accumulation:
    - leftTextSettings[9] (number): overrides leftText:SetWidth().
    - leftTextSettings[10] (number): overrides leftText:SetHeight().

These allow individual lines to have custom text wrapping widths or
fixed text heights independent of the global options.


=====================================================================
52) RefreshSpark() — spark position and style updater
=====================================================================

Signature
    GameCooltip:RefreshSpark(menuButton)

Purpose
    Recalculates the position, size, texture, color, and alpha of the
    spark (glow indicator) on a status bar. Called after the bar's
    value or width has changed.

Option-driven properties
    SparkTexture            texture path (or original spark texture)
    SparkAlpha              alpha (default 1)
    SparkColor              color shortcut (default "white")
    SparkWidth              base width (or original width)
    SparkHeight             base height (or original height)
    SparkWidthOffset        added to width (default 0)
    SparkHeightOffset       added to height (default 0)
    SparkPositionXOffset    X shift (default 0)
    SparkPositionYOffset    Y shift (default 0)

Behavior
    1. Reads options, falling back to the spark's original stored
       values (set at creation time).
    2. Sets size = (base + offset) for width and height.
    3. Sets texture, vertex color (via ParseColors), alpha.
    4. Positions spark at the bar's current fill point:
       spark X = value * (barWidth / 100) - 5 + XOffset
    5. Positions spark2 similarly but with a -16 offset.


=====================================================================
53) StatusBar() — status bar renderer
=====================================================================

Signature
    GameCooltip:StatusBar(menuButton, statusBarSettings)

Purpose
    Configures the primary and secondary status bars on a line button.
    Called for each line during tooltip/menu building.

Parameters
    menuButton          (button)
        The line button containing child widgets:
            .statusbar      primary StatusBar widget
            .statusbar2     secondary (background) StatusBar widget
            .spark          primary spark Texture
            .spark2         secondary spark Texture

    statusBarSettings   (table|nil)
        StatusBarTable[index] — array with:
            [1] value       (number) — fill value (0–100 or absolute
                            with maxValue from AddStatusBar_MaxValue)
            [2] colorRed    (number, 0–1)
            [3] colorGreen  (number, 0–1)
            [4] colorBlue   (number, 0–1)
            [5] colorAlpha  (number, 0–1)
            [6] glow        (boolean) — show primary spark
            [7] backgroundBar (table|nil) — secondary bar config:
                    .value          number  (fill value)
                    .texture        string  (bar texture path)
                    .color          color   (ParseColors-compatible)
                    .specialSpark   boolean (show spark2)
            [8] barTexture  (string|nil) — per-line bar texture
            [9] maxValue    (number|nil — from AddStatusBar_MaxValue)

        When nil, both bars are hidden (value=0, sparks hidden).

Behavior — when settings exist
    1. Primary bar value: Clamped between 0 and maxStatusBarValue
       (100,000,000). Skips setting if value is a WoW "secret value".
    2. Primary bar color: SetStatusBarColor(R, G, B, A).
    3. Primary bar height: 20 + StatusBarHeightMod option.
    4. Primary spark: shown if glow ([6]) is true, hidden otherwise.
    5. Secondary bar (statusbar2): if [7] exists:
       - Sets value (clamped), texture, color (via ParseColors).
       - Shows spark2 if .specialSpark is true.
       When [7] is nil: secondary bar value = 0, spark2 hidden.
    6. Bar texture resolution:
       [8] per-line texture > OptionsTable.StatusBarTexture >
       default "UI-Character-Skills-Bar".
       Each level tries SharedMedia:Fetch("statusbar", ...) first,
       falls back to raw path.

Behavior — when settings are nil
    Sets both bars to 0, hides both sparks.

Bar positioning
    Left edge:  10 + LeftBorderSize option (default 0).
    Right edge: -10 + RightBorderSize option (default 0).


=====================================================================
54) SetupMainButton() — main menu line configuration
=====================================================================

Signature
    GameCooltip:SetupMainButton(menuButton, index)

Purpose
    Fully configures a main frame line button for menu mode.
    Called by BuildCooltip() for each visible line.

Parameters
    menuButton  (button) — the line button from frame1.Lines[index]
    index       (number) — the line index (1-based)

Behavior
    1. Sets menuButton.index = index.
    2. Calls TextAndIcon() with main-frame data tables:
       LeftTextTable[index], RightTextTable[index],
       LeftIconTable[index], RightIconTable[index].
    3. Calls StatusBar() with StatusBarTable[index].
    4. Registers the button for "LeftButtonDown" clicks.
    5. Width tracking: if FixedWidth is not set, measures
       leftText + rightText + leftIcon + rightIcon string widths
       and updates frame1.w.
    6. Sets OnClick = OnClickFunctionMainButton.
    7. Shows the button.


=====================================================================
55) SetupButtonOnSecondFrame() — sub-menu line configuration
=====================================================================

Signature
    GameCooltip:SetupButtonOnSecondFrame(menuButton, index,
        mainMenuIndex)

Purpose
    Fully configures a secondary frame line button for sub-menus.
    Called by ShowSub() for each sub-entry.

Parameters
    menuButton      (button) — frame2.Lines[index]
    index           (number) — sub-menu line index (1-based)
    mainMenuIndex   (number) — parent main menu line index

Behavior
    1. Sets menuButton.index and menuButton.mainIndex.
    2. Calls TextAndIcon() with sub-menu data tables:
       LeftTextTableSub[mainMenuIndex][index],
       RightTextTableSub[mainMenuIndex][index],
       LeftIconTableSub[mainMenuIndex][index],
       RightIconTableSub[mainMenuIndex][index].
       Passes isSecondFrame = true.
    3. Calls StatusBar() with
       StatusBarTableSub[mainMenuIndex][index].
    4. Registers "LeftButtonDown" clicks.
    5. Positions the button in frame2:
       - center of frame2
       - top = ((index-1) * 20) * -1 - 3  (stacks downward)
       - left/right edges flush with frame2.
    6. Fades the button in (instant show).
    7. Width tracking: measures content width, updates frame2.w.
    8. Sets OnClick = OnClickFunctionSecondaryButton.
    9. Returns true.


=====================================================================
56) SetupWallpaper() — wallpaper texture configuration
=====================================================================

Signature
    GameCooltip:SetupWallpaper(wallpaperTable, wallpaper)

Purpose
    Applies wallpaper settings to a Texture object. Used for both
    frame1.frameWallpaper and frame2.frameWallpaper.

Parameters
    wallpaperTable  (table) — data array from WallpaperTable:
        [1] texture         (string|table|color-name)
        [2] texCoordLeft    (number, 0–1)
        [3] texCoordRight   (number, 0–1)
        [4] texCoordTop     (number, 0–1)
        [5] texCoordBottom  (number, 0–1)
        [6] overlayColor    (color|nil — ParseColors-compatible)
        [7] bDesaturated    (boolean|nil)
        [8] desaturation    (number|nil — 0 to 1 partial desat)

    wallpaper       (Texture) — the target texture widget.

Behavior
    1. Texture detection:
       - If [1] is an HTML color name (DF:IsHtmlColor) or a table,
         calls SetColorTexture with parsed RGBA.
       - Otherwise calls SetTexture with the path/ID.

    2. TexCoords: Sets from [2..5].

    3. Vertex color: if [6] exists, parses color and sets. Otherwise
       resets to white (1,1,1,1).

    4. Desaturation:
       - [7] true → full desaturation.
       - [7] false and [8] exists → partial desaturation value.

    5. Shows the texture.


=====================================================================
57) ShowSub() — sub-menu builder for menu mode
=====================================================================

Signature
    GameCooltip:ShowSub(index)

Purpose
    Builds and displays the sub-menu (frame2) for a specific main
    menu line. Called when hovering over or selecting a main menu
    line that has sub-entries. This is the menu-mode counterpart of
    BuildTooltipSecondFrame().

Parameters
    index   (number, required) — main menu line index whose sub-menu
            to display.

Early returns
    - OptionsTable.IgnoreSubMenu: fades out frame2 and returns.
    - IndexesSub[index] is nil: no sub-data, returns silently.

Behavior
    1. Resets frame2 height, width (frame2.w), and hHeight.

    2. Applies FixedWidthSub if set.

    3. If SubMenuIsTooltip: disables mouse on frame2 and all buttons
       (non-interactive tooltip-style sub-display).

    4. Creates line buttons (CreateButtonOnSecondFrame) as needed.
       Calls SetupButtonOnSecondFrame() for each sub-entry.

    5. Mouse enable/disable per button based on SubMenuIsTooltip.

    6. Selected texture: if SelectedIndexSec[index] is set, shows
       the selection highlight on that sub-button (unless
       NoLastSelectedBar is set).

    7. Hides unused line buttons beyond IndexesSub[index].

    8. Line positioning with "$div" support:
       - "$div" lines: 4px height, divider bar shown, text cleared.
         Top/bottom offsets from RightTextTableSub[index][i][2] and
         [3]. Spacing accumulates.
       - Normal lines: height = hHeight + ButtonHeightModSub.
         Positioned at ((i-1) * hHeight) * -1 - 4 + ButtonsYModSub
         + accumulated spacing. Adds YSpacingModSub per line.

    9. Frame height: hHeight * IndexesSub[index] + 12 - spacing
       + HeighModSub.

    10. Top icon: if TopIconTableSub[index] exists, shows
        frame2.upperImage with texture, size, texcoords.

    11. Wallpaper: if WallpaperTableSub[index] exists, calls
        SetupWallpaper(). Otherwise hides wallpaper.

    12. Width: frame2.w + 44 (unless FixedWidthSub).

    13. Fades in frame2, calls CheckOverlap().

    14. Positioning (four cases):
        a. SubFollowButton + not leftside: anchors frame2 to the
           right of the specific main button (4px gap).
        b. SubFollowButton + leftside: anchors to the left of the
           main button (-4px gap).
        c. frame2_IsOnLeftside (no follow): anchors frame2's
           bottomright to frame1's bottomleft.
        d. Default: anchors frame2's bottomleft to frame1's
           bottomright.


=====================================================================
58) HideSub()
=====================================================================

Signature
    GameCooltip:HideSub()

Purpose
    Fades out frame2 (the sub-menu/secondary frame).

Behavior
    Single call to DF:FadeFrame(frame2, 1) — fades to invisible.


=====================================================================
59) LeftTextSpace() — left text width constraint for bar mode
=====================================================================

Signature
    GameCooltip:LeftTextSpace(row)

Purpose
    Constrains the left text fontstring width so it doesn't overlap
    with other elements when the cooltip is in type 2 (tooltip with
    bars) mode.

Parameters
    row     (button) — the line button

Behavior
    Sets leftText width to:
        row:GetWidth() - 30 - leftIcon:GetWidth() -
        rightIcon:GetWidth() - rightText:GetStringWidth()
    Sets leftText height to 10.

    This ensures the left text truncates/wraps before reaching the
    right-side content area, leaving room for icons, right text,
    and the status bar margins.


=====================================================================
60) Data flow: from AddLine() to rendered pixels
=====================================================================

This section traces exactly how user-facing API calls end up as
rendered content through the functions documented in this part.

    AddLine("Hello", "World", 1, 1, 1, 0, 1)
        → Stores into LeftTextTable[N] = {"Hello", 1, 1, 0, 1}
        → Stores into RightTextTable[N] = {"World", 0, 0, 0, 0}

    AddIcon(texture, 1, 1, 20, 20)
        → Stores into LeftIconTable[N] = {texture, 20, 20, 0, 1, 0, 1, ...}

    AddStatusBar(75, 1, 0, 1, 0, 1)
        → Stores into StatusBarTable[N] = {75, 0, 1, 0, 1}

    Show()
        → ShowCooltip()
            → Type 1/2: BuildTooltip()
                for each line i:
                    → TextAndIcon(i, frame1, button,
                        LeftTextTable[i], RightTextTable[i],
                        LeftIconTable[i], RightIconTable[i])
                    → StatusBar(button, StatusBarTable[i])
                → Positions with SetMyPoint()

            → Type 3: BuildCooltip()
                for each line i:
                    → SetupMainButton(button, i)
                        → TextAndIcon(...)  (same data)
                        → StatusBar(...)
                → Positions with SetMyPoint()
                → ShowSub(selectedIndex) if needed
                    → SetupButtonOnSecondFrame(button, j, i)
                        → TextAndIcon(j, frame2, button,
                            LeftTextTableSub[i][j], ...)
                        → StatusBar(...)


=====================================================================
61) Font resolution quick reference
=====================================================================

When TextAndIcon processes a text line, the font is resolved in
this priority order. The first match wins.

    ┌─────────────────────────────────────────────────────────────┐
    │ Priority │ Source                  │ When it applies        │
    ├──────────┼─────────────────────────┼────────────────────────┤
    │ 1 (high) │ requiredFont            │ Non-Latin text detected│
    │ 2        │ OptionsTable.TextFont   │ Set + no per-line font │
    │ 3        │ settings[7] (per-line)  │ Per-line font from     │
    │          │                         │ AddLine fontFace param │
    │ 4 (low)  │ gameCooltip.defaultFont │ No font specified      │
    └─────────────────────────────────────────────────────────────┘

At each level, the font name is resolved:
    1. Check _G[name] — if it exists, treat as a FontObject.
    2. SharedMedia:Fetch("font", name) — lookup as a media key.
    3. Treat as a raw font path.

Size follows: settings[6] > OptionsTable.TextSize > 10.
Flags follow: settings[8] > OptionsTable.TextShadow > "".


=====================================================================
62) Icon settings quick reference
=====================================================================

    ┌──────────────────────────────────────────────────────────────┐
    │ Index │ Field           │ Type              │ Example        │
    ├───────┼─────────────────┼───────────────────┼────────────────┤
    │ [1]   │ texture         │ path/ID/TexObj    │ 136243         │
    │ [2]   │ width           │ number            │ 20             │
    │ [3]   │ height          │ number            │ 20             │
    │ [4]   │ texCoordLeft    │ 0–1               │ 0.08           │
    │ [5]   │ texCoordRight   │ 0–1               │ 0.92           │
    │ [6]   │ texCoordTop     │ 0–1               │ 0.08           │
    │ [7]   │ texCoordBottom  │ 0–1               │ 0.92           │
    │ [8]   │ overlayColor    │ color/shortcut    │ "white"        │
    │ [9]   │ desaturated     │ boolean           │ true           │
    │ [10]  │ maskTexture     │ string/nil        │ "Interface\\…" │
    └──────────────────────────────────────────────────────────────┘

    If [1] is a Texture object (widget), it is reparented and
    positioned over the built-in icon placeholder.

    OptionsTable.IconSize overrides [2] and [3] for both icons.
    OptionsTable.IconBlendMode overrides the blend mode.
    OptionsTable.UseTrilinearLeft / UseTrilinearRight controls
    texture filtering quality.


=====================================================================
63) Status bar settings quick reference
=====================================================================

    ┌──────────────────────────────────────────────────────────────┐
    │ Index │ Field           │ Type              │ Default        │
    ├───────┼─────────────────┼───────────────────┼────────────────┤
    │ [1]   │ value           │ number (0–100)    │ 0              │
    │ [2]   │ colorRed        │ 0–1               │ —              │
    │ [3]   │ colorGreen      │ 0–1               │ —              │
    │ [4]   │ colorBlue       │ 0–1               │ —              │
    │ [5]   │ colorAlpha      │ 0–1               │ —              │
    │ [6]   │ glow (spark)    │ boolean           │ false          │
    │ [7]   │ backgroundBar   │ table/nil         │ nil            │
    │ [8]   │ barTexture      │ string/nil        │ options or def │
    │ [9]   │ maxValue        │ number/nil        │ 100000000      │
    └──────────────────────────────────────────────────────────────┘

    [7] backgroundBar sub-fields:
        .value          number      fill value
        .texture        string      bar texture (or default HP fill)
        .color          color       ParseColors-compatible
        .specialSpark   boolean     show spark2

    Bar texture resolution: [8] > StatusBarTexture option >
    "UI-Character-Skills-Bar". Each tries SharedMedia first.

    Bar edges padded by LeftBorderSize / RightBorderSize options.


=====================================================================
64) Wallpaper settings quick reference
=====================================================================

    ┌──────────────────────────────────────────────────────────────┐
    │ Index │ Field           │ Type              │ Default        │
    ├───────┼─────────────────┼───────────────────┼────────────────┤
    │ [1]   │ texture         │ path/color/table  │ —              │
    │ [2]   │ texCoordLeft    │ 0–1               │ —              │
    │ [3]   │ texCoordRight   │ 0–1               │ —              │
    │ [4]   │ texCoordTop     │ 0–1               │ —              │
    │ [5]   │ texCoordBottom  │ 0–1               │ —              │
    │ [6]   │ overlayColor    │ color/nil         │ white          │
    │ [7]   │ bDesaturated    │ boolean/nil       │ false          │
    │ [8]   │ desaturation    │ 0–1 / nil         │ 0              │
    └──────────────────────────────────────────────────────────────┘

    If [1] is an HTML color name or a table, SetColorTexture is used
    instead of SetTexture. Partial desaturation via [8] only applies
    when [7] is false.


=====================================================================
End of Part 3
=====================================================================


=====================================================================
Part 4 — Options reference (lines 121–224)
=====================================================================

Options are set via GameCooltip:SetOption(name, value) and cleared
with GameCooltip:ClearAllOptions(). They customize every aspect of
the tooltip's appearance and behavior for a single show/hide cycle.
Options are stored in gameCooltip.OptionsTable and wiped on Reset().

Many options have friendlier alias names (listed under each option).
Aliases resolve to the canonical name internally.

Usage:
    GameCooltip:SetOption("TextSize", 12)
    GameCooltip:SetOption("VerticalPadding", -2)  -- alias


=====================================================================
65) RightTextMargin
=====================================================================

Type        number
Default     -3
Aliases     (none)

Controls the horizontal offset between the right-side text and the
right-side icon. The right text is anchored to the left of the right
icon with this pixel offset.

Used in     TextAndIcon() — line 1037
    menuButton.rightText:SetPoint("right", menuButton.rightIcon,
        "left", RightTextMargin or -3, 0)

Example
    GameCooltip:SetOption("RightTextMargin", -8)


=====================================================================
66) IconSize
=====================================================================

Type        number
Default     nil (icons use their per-line sizes from AddIcon)
Aliases     (none)

Overrides the width AND height of both left and right icons on every
line to this single value. Applied after per-line icon settings in
TextAndIcon(). Useful for enforcing uniform icon sizes.

Used in     TextAndIcon() — lines 1391–1395

Example
    GameCooltip:SetOption("IconSize", 16)


=====================================================================
67) HeightAnchorMod
=====================================================================

Type        number
Default     0 (set by ClearAllOptions)
Aliases     (none)

Vertical pixel offset added when positioning frame1 relative to its
host. Positive values move the tooltip up, negative values move it
down. Added to the base 10px vertical offset in SetMyPoint().

Also set automatically by SetHost() when anchor parameters are
provided.

Used in     SetMyPoint() — line 2503, SetHost() — lines 2677–2689

Example
    GameCooltip:SetOption("HeightAnchorMod", -5)


=====================================================================
68) WidthAnchorMod
=====================================================================

Type        number
Default     0 (set by ClearAllOptions)
Aliases     (none)

Horizontal pixel offset added when positioning frame1 relative to
its host. Positive shifts right, negative shifts left. Added to the
base 0px horizontal offset in SetMyPoint().

Also set automatically by SetHost() when anchor parameters are
provided.

Used in     SetMyPoint() — line 2503, SetHost() — lines 2676–2691

Example
    GameCooltip:SetOption("WidthAnchorMod", 10)


=====================================================================
69) MinWidth
=====================================================================

Type        number
Default     nil (no minimum)
Aliases     (none)

Sets a minimum width for the tooltip frame. After the content width
is calculated, if the result is less than MinWidth, the frame width
is raised to MinWidth. Applied via math.max().

Affects both frame1 and frame2 in tooltip mode. Affects frame1 in
menu mode.

Used in     BuildTooltip() — lines 2228/2244,
            BuildTooltipSecondFrame() — lines 1981/1997,
            BuildCooltip() — line 2374

Example
    GameCooltip:SetOption("MinWidth", 200)


=====================================================================
70) FixedWidth
=====================================================================

Type        number
Default     nil (auto-sized to content)
Aliases     (none)

Forces the tooltip to an exact pixel width, ignoring content width
calculations. When set:
    - Frame1 width is set immediately in BuildTooltip/BuildCooltip.
    - TextAndIcon constrains leftText width to fit within the fixed
      width minus icon and right text space.
    - Width stability checks are skipped.

Used in     BuildTooltip() — lines 2145–2149,
            BuildCooltip() — lines 2314–2318,
            TextAndIcon() — lines 1430–1438

Example
    GameCooltip:SetOption("FixedWidth", 300)


=====================================================================
71) FixedHeight
=====================================================================

Type        number
Default     nil (auto-sized to content)
Aliases     (none)

Forces the tooltip to an exact pixel height, ignoring content height
calculations. Applied after all line positioning is complete.

Used in     BuildTooltip() — lines 2253–2254,
            BuildTooltipSecondFrame() — lines 2006–2007,
            BuildCooltip() — lines 2443–2444

Example
    GameCooltip:SetOption("FixedHeight", 150)


=====================================================================
72) FixedWidthSub
=====================================================================

Type        number
Default     nil (auto-sized to content)
Aliases     (none)

Forces the secondary frame (frame2) to an exact pixel width. Works
the same as FixedWidth but for the sub-menu/sub-tooltip frame.

In TextAndIcon, constrains leftText width to FixedWidthSub minus
icon width minus 12px padding.

Used in     ShowSub() — lines 1672–1673,
            BuildTooltipSecondFrame() — lines 1896–1897,
            TextAndIcon() — lines 1441–1449

Example
    GameCooltip:SetOption("FixedWidthSub", 250)


=====================================================================
73) FixedHeightSub
=====================================================================

Type        number
Default     nil
Aliases     (none)

Reserved option for forcing frame2 height. Declared in the options
list but not referenced in the current code. FixedHeight is used
for frame2 in BuildTooltipSecondFrame instead.


=====================================================================
74) AlignAsBlizzTooltip
=====================================================================

Type        boolean
Default     nil / false
Aliases     (none)

Enables Blizzard-style tooltip height calculation. When true, each
line's height is computed as:
    max(2, leftText height, rightText height, leftIcon height,
        rightIcon height, AlignAsBlizzTooltipForceHeight or 2)

Lines stack tightly with no extra spacing (no YSpacingMod, no
ButtonsYMod). This produces compact tooltips that look like native
Blizzard tooltips.

Mutually exclusive with IgnoreButtonAutoHeight and default mode —
the first matching mode wins (AlignAsBlizzTooltip is checked first).

Used in     BuildTooltip() — lines 2203–2208,
            BuildTooltipSecondFrame() — lines 1955–1960

Example
    GameCooltip:SetOption("AlignAsBlizzTooltip", true)


=====================================================================
75) AlignAsBlizzTooltipFrameHeightOffset
=====================================================================

Type        number
Default     0
Aliases     (none)

Additional pixel offset added to the frame height when using
AlignAsBlizzTooltip mode. The frame height formula becomes:
    ((heightValue - 10) * -1) + AlignAsBlizzTooltipFrameHeightOffset

Used in     BuildTooltip() — line 2257,
            BuildTooltipSecondFrame() — line 2010

Example
    GameCooltip:SetOption("AlignAsBlizzTooltipFrameHeightOffset", 4)


=====================================================================
76) AlignAsBlizzTooltipForceHeight
=====================================================================

Type        number
Default     2
Aliases     (none)

Minimum line height when using AlignAsBlizzTooltip mode. Each line's
height is at least this value (used in the max() computation). Not
in the OptionsList but accepted via OptionsTable.

Used in     BuildTooltip() — line 2204,
            BuildTooltipSecondFrame() — line 1956

Example
    GameCooltip:SetOption("AlignAsBlizzTooltipForceHeight", 14)


=====================================================================
77) IgnoreSubMenu
=====================================================================

Type        boolean
Default     nil / false
Aliases     (none)

When true, prevents sub-menus from being displayed. ShowSub() will
immediately fade out frame2 and return. Use this when you want to
show a menu with no secondary panel.

Used in     ShowSub() — line 1660

Example
    GameCooltip:SetOption("IgnoreSubMenu", true)


=====================================================================
78) IgnoreButtonAutoHeight
=====================================================================

Type        boolean
Default     nil / false
Aliases     (none)

Enables the second height calculation mode. When true (and
AlignAsBlizzTooltip is false), each line's height is the max of its
content heights. Lines stack with YSpacingMod gap and ButtonsYMod
offset. The frame height is computed from accumulated heightValue.

This mode is between the tight Blizzard mode and the default
uniform-height mode.

Used in     BuildTooltip() — lines 2209–2215,
            BuildTooltipSecondFrame() — lines 1961–1968

Example
    GameCooltip:SetOption("IgnoreButtonAutoHeight", true)


=====================================================================
79) TextHeightMod
=====================================================================

Type        number
Default     0
Aliases     (none)

Vertical pixel offset applied to the left text positioning relative
to its icon. Shifts the text up (positive) or down (negative) within
its line button. Also affects the mouse-down/mouse-up text animation.

Used in     TextAndIcon() — line 1148,
            GameCooltipButtonMouseDown — line 738,
            GameCooltipButtonMouseUp — line 744

Example
    GameCooltip:SetOption("TextHeightMod", 2)


=====================================================================
80) ButtonHeightMod
=====================================================================

Type        number
Default     nil (falls back to default_height = 20 in some contexts)
Aliases     LineHeightSizeOffset

Modifies line button heights. Behavior depends on context:

    Tooltip mode (default height calc):
        Each line height = hHeight + ButtonHeightMod.
        When used as initial button height before content:
        button:SetHeight(ButtonHeightMod or default_height).

    Menu mode (BuildCooltip):
        Each non-divider line height = hHeight + ButtonHeightMod.

Used in     BuildTooltip() — lines 2164, 2215,
            BuildTooltipSecondFrame() — lines 1915, 1968,
            BuildCooltip() — line 2425

Example
    GameCooltip:SetOption("ButtonHeightMod", 24)
    -- or using alias:
    GameCooltip:SetOption("LineHeightSizeOffset", 24)


=====================================================================
81) ButtonHeightModSub
=====================================================================

Type        number
Default     0
Aliases     LineHeightSizeOffsetSub

Same as ButtonHeightMod but for the secondary frame (frame2) in
ShowSub(). Each sub-menu line height = hHeight + ButtonHeightModSub.

Used in     ShowSub() — line 1765

Example
    GameCooltip:SetOption("ButtonHeightModSub", 4)


=====================================================================
82) YSpacingMod
=====================================================================

Type        number
Default     nil / 0
Aliases     LinePadding, VerticalPadding

Vertical spacing between lines. The spacing value accumulates: each
line adds YSpacingMod to the running spacing offset. Negative values
bring lines closer together, positive values spread them apart.

Does NOT work with IgnoreButtonAutoHeight mode (explicitly checked
and skipped). Works with AlignAsBlizzTooltip and default mode.

Used in     BuildTooltip() — lines 2182–2220,
            BuildTooltipSecondFrame() — lines 1934–1973,
            BuildCooltip() — lines 2369–2431

Example
    GameCooltip:SetOption("YSpacingMod", -2)
    -- or:
    GameCooltip:SetOption("VerticalPadding", -2)


=====================================================================
83) YSpacingModSub
=====================================================================

Type        number
Default     nil / 0
Aliases     LinePaddingSub, VerticalPaddingSub

Same as YSpacingMod but for the sub-menu frame (ShowSub). Spacing
between sub-menu lines.

Used in     ShowSub() — lines 1716–1773

Example
    GameCooltip:SetOption("YSpacingModSub", -1)


=====================================================================
84) ButtonsYMod
=====================================================================

Type        number
Default     0
Aliases     LineYOffset, VerticalOffset

Vertical offset for all lines within the frame. Shifts the entire
block of lines up or down relative to the frame's top edge. Added
to the initial height calculation alongside TopBorderSize.

In default height mode, also factors into line-by-line positioning.
In IgnoreButtonAutoHeight mode, factors into heightValue
accumulation.

Used in     BuildTooltip() — lines 2187, 2213, 2216, 2263,
            BuildTooltipSecondFrame() — lines 1939, 1965, 1969, 2018,
            BuildCooltip() — lines 2405, 2429

Example
    GameCooltip:SetOption("ButtonsYMod", -4)
    -- or:
    GameCooltip:SetOption("VerticalOffset", -4)


=====================================================================
85) ButtonsYModSub
=====================================================================

Type        number
Default     0
Aliases     LineYOffsetSub, VerticalOffsetSub

Same as ButtonsYMod but for the sub-menu frame (ShowSub). Offsets
all sub-menu lines vertically.

Used in     ShowSub() — lines 1744, 1770

Example
    GameCooltip:SetOption("ButtonsYModSub", -2)


=====================================================================
86) IconHeightMod
=====================================================================

Type        number
Default     nil
Aliases     (none)

Declared in the options list but not referenced in the current code.
Reserved for future use — likely intended to modify icon heights
globally.


=====================================================================
87) StatusBarHeightMod
=====================================================================

Type        number
Default     0
Aliases     (none)

Added to the base 20px status bar height. Positive values make bars
taller, negative values make them shorter.

Used in     StatusBar() — line 1502
    menuButton.statusbar:SetHeight(20 + StatusBarHeightMod)

Example
    GameCooltip:SetOption("StatusBarHeightMod", -6)


=====================================================================
88) StatusBarTexture
=====================================================================

Type        string
Default     nil (falls back to "UI-Character-Skills-Bar")
Aliases     (none)

Global status bar texture path or SharedMedia key. Applied to all
lines that don't have a per-line bar texture (statusBarSettings[8]).

Resolution: tries SharedMedia:Fetch("statusbar", ...) first. If
that returns nil, uses the raw string as a texture path.

Used in     StatusBar() — lines 1535–1540

Example
    GameCooltip:SetOption("StatusBarTexture", "Details D'ictum")


=====================================================================
89) TextSize
=====================================================================

Type        number
Default     nil (falls back to 10)
Aliases     (none)

Global font size for both left and right text on all lines. Applied
when the line does not have a per-line fontSize (settings[6]).

Used in     TextAndIcon() — lines 1073–1074 (left), 1191–1196 (right),
            and in font setup chains (lines 1110, 1120, 1127, etc.)

Example
    GameCooltip:SetOption("TextSize", 11)


=====================================================================
90) TextFont
=====================================================================

Type        string
Default     nil (uses default font from DF:GetBestFontForLanguage)
Aliases     (none)

Global font face for both left and right text. Can be:
    - A global FontObject name (e.g., "GameFontNormal")
    - A SharedMedia font key (e.g., "Friz Quadrata TT")

When set, overrides per-line font faces unless a per-line fontFace
(settings[7]) is provided. Also disables automatic language
detection (language detection requires TextFont to be nil).

Used in     TextAndIcon() — lines 1042, 1103–1107 (left),
            1157, 1219–1223 (right)

Example
    GameCooltip:SetOption("TextFont", "Friz Quadrata TT")


=====================================================================
91) TextColor
=====================================================================

Type        color (ParseColors-compatible: table, string, or RGBA)
Default     nil (falls back to white 1,1,1,1)
Aliases     (none)

Default color for left text when the line's own color is all zeros
(0,0,0,0) — i.e., when AddLine was called without specifying colors.
Also used as a secondary fallback for right text (after
TextColorRight).

Used in     TextAndIcon() — lines 1063–1064 (left), 1181–1182 (right)

Example
    GameCooltip:SetOption("TextColor", "wheat")
    GameCooltip:SetOption("TextColor", {0.9, 0.8, 0.5, 1})


=====================================================================
92) TextColorRight
=====================================================================

Type        color (ParseColors-compatible)
Default     nil (falls back to TextColor, then white)
Aliases     (none)

Default color for right text when the line's own right color is all
zeros. Checked before TextColor for right text — use this to have
different default colors for left and right columns.

Used in     TextAndIcon() — lines 1178–1179

Example
    GameCooltip:SetOption("TextColorRight", "silver")


=====================================================================
93) TextShadow
=====================================================================

Type        string
Default     nil (no outline — falls back to "")
Aliases     TextOutline

Despite the name, this option controls font OUTLINE flags, not
shadow. The value is passed to SetFont() as the fontFlags parameter.

Accepted values: "OUTLINE", "THICKOUTLINE", "MONOCHROME",
                 "OUTLINE, MONOCHROME", etc.

Applied when no per-line fontFlag (settings[8]) is provided.

Used in     TextAndIcon() — lines 1109, 1119, 1126, 1134 (left),
            1225, 1234, 1240, 1245 (right)

Example
    GameCooltip:SetOption("TextShadow", "OUTLINE")
    -- or using the clearer alias:
    GameCooltip:SetOption("TextOutline", "OUTLINE")


=====================================================================
94) TextActuallyShadow
=====================================================================

Type        color (ParseColors-compatible)
Default     nil (falls back to black 0,0,0,1)
Aliases     TextSilhouette, TextContour

Controls the actual text shadow color (SetShadowColor on the
fontstring). Applied when no per-line shadowColor (settings[11])
is provided.

Used in     TextAndIcon() — lines 1141–1142 (left), 1252–1253 (right)

Example
    GameCooltip:SetOption("TextActuallyShadow", {0, 0, 0, 0.8})
    -- or using alias:
    GameCooltip:SetOption("TextContour", "black")


=====================================================================
95) LeftTextWidth
=====================================================================

Type        number
Default     nil (auto-sized, 0 = unlimited)
Aliases     (none)

Forces the left text fontstring to a specific pixel width on all
lines. When set, text will word-wrap or truncate at this width.

Used in     TextAndIcon() — lines 1087–1088

Example
    GameCooltip:SetOption("LeftTextWidth", 150)


=====================================================================
96) RightTextWidth
=====================================================================

Type        number
Default     nil (auto-sized)
Aliases     (none)

Forces the right text fontstring to a specific pixel width on all
lines.

Used in     TextAndIcon() — lines 1209–1210

Example
    GameCooltip:SetOption("RightTextWidth", 80)


=====================================================================
97) LeftTextHeight
=====================================================================

Type        number
Default     nil (auto-sized)
Aliases     (none)

Forces the left text fontstring to a specific pixel height. Applied
both during initial text setup and after icon rendering.

Used in     TextAndIcon() — lines 1093–1094, 1404–1405

Example
    GameCooltip:SetOption("LeftTextHeight", 12)


=====================================================================
98) RightTextHeight
=====================================================================

Type        number
Default     nil (auto-sized)
Aliases     (none)

Forces the right text fontstring to a specific pixel height.

Used in     TextAndIcon() — lines 1407–1408

Example
    GameCooltip:SetOption("RightTextHeight", 12)


=====================================================================
99) NoFade
=====================================================================

Type        boolean
Default     nil / false
Aliases     (none)

Declared in the options list. When true, intended to skip the fade
animation when showing/hiding the tooltip (instant show/hide).
The option is registered but the Show/Hide code references it
through DF:FadeFrame which checks internal fade state.


=====================================================================
100) MyAnchor
=====================================================================

Type        string (anchor point)
Default     "bottom" (set in SetHost)
Aliases     (none)

The anchor point on the tooltip frame (frame1) used when positioning
it relative to the host. Standard WoW anchor points: "topleft",
"top", "topright", "left", "center", "right", "bottomleft",
"bottom", "bottomright".

Used in     SetMyPoint() — line 2503, SetHost() — line 2673

Example
    GameCooltip:SetOption("MyAnchor", "topleft")


=====================================================================
101) Anchor
=====================================================================

Type        frame
Default     nil (falls back to gameCooltip.Host)
Aliases     (none)

Overrides the frame used as the positioning anchor. Normally the
tooltip anchors to gameCooltip.Host (set by SetOwner/SetHost).
Setting this option makes the tooltip anchor to a different frame
while keeping Host for ownership purposes.

Used in     SetMyPoint() — line 2500

Example
    GameCooltip:SetOption("Anchor", UIParent)


=====================================================================
102) RelativeAnchor
=====================================================================

Type        string (anchor point)
Default     "top" (set in SetHost)
Aliases     (none)

The anchor point on the host frame (or Anchor frame) used when
positioning the tooltip. Combined with MyAnchor to determine
relative placement.

Used in     SetMyPoint() — line 2503

Example
    -- Tooltip's bottom-left attaches to host's top-left:
    GameCooltip:SetOption("MyAnchor", "bottomleft")
    GameCooltip:SetOption("RelativeAnchor", "topleft")


=====================================================================
103) NoLastSelectedBar
=====================================================================

Type        boolean
Default     nil / false
Aliases     (none)

Hides the selection highlight texture when a menu item is clicked.
Normally, clicking a menu line shows a highlight bar on the selected
item. Setting this to true prevents that visual feedback.

Used in     OnClickFunctionMainButton — line 993,
            OnClickFunctionSecondaryButton — line 1023,
            ShowSub() — line 1704,
            BuildCooltip() — line 2351

Example
    GameCooltip:SetOption("NoLastSelectedBar", true)


=====================================================================
104) SubMenuIsTooltip
=====================================================================

Type        boolean
Default     nil / false
Aliases     (none)

Treats the sub-menu (frame2) as a non-interactive tooltip instead of
a clickable menu. When true:
    - frame2 and all its buttons have mouse disabled.
    - Sub-menu arrows are hidden on main menu lines.
    - frame2 OnEnter resets the parent tooltip timer (keeps it alive).
    - Secondary button OnEnter only shows highlight, no click handler.

Used in     ShowSub() — line 1680,
            BuildCooltip() — line 2451,
            OnEnterMainButton — line 804,
            OnEnterSecondaryButton — line 886,
            frame2 OnEnter — line 532

Example
    GameCooltip:SetOption("SubMenuIsTooltip", true)


=====================================================================
105) LeftBorderSize
=====================================================================

Type        number
Default     0 (base padding is 10px)
Aliases     LeftPadding

Additional pixels added to the left edge of status bars. The bar
starts at 10 + LeftBorderSize pixels from the left edge of the
button.

Used in     StatusBar() — lines 1552–1553

Example
    GameCooltip:SetOption("LeftBorderSize", 5)
    -- or:
    GameCooltip:SetOption("LeftPadding", 5)


=====================================================================
106) RightBorderSize
=====================================================================

Type        number
Default     0 (base padding is -10px)
Aliases     RightPadding

Additional pixels added to the right edge of status bars. The bar
ends at -10 + RightBorderSize pixels from the right edge of the
button. Use negative values to add more padding.

Used in     StatusBar() — lines 1558–1559

Example
    GameCooltip:SetOption("RightBorderSize", -5)
    -- or:
    GameCooltip:SetOption("RightPadding", -5)


=====================================================================
107) TopBorderSize
=====================================================================

Type        number
Default     -6
Aliases     (none)

Offset between the top of the frame and the first line of content.
More negative values push content further down from the top edge.
Used in the default and IgnoreButtonAutoHeight height calculation
modes as the initial heightValue offset.

Used in     BuildTooltip() — line 2187,
            BuildTooltipSecondFrame() — line 1939,
            default mode positioning — lines 1969, 2216

Example
    GameCooltip:SetOption("TopBorderSize", -10)


=====================================================================
108) HeighMod
=====================================================================

Type        number
Default     0
Aliases     FrameHeightSizeOffset

Additional pixels added to the total frame1 height in menu mode
(BuildCooltip). The frame height formula is:
    (hHeight * Indexes) + 12 + HeighMod

Used in     BuildCooltip() — line 2446

Example
    GameCooltip:SetOption("HeighMod", 4)
    -- or:
    GameCooltip:SetOption("FrameHeightSizeOffset", 4)


=====================================================================
109) HeighModSub
=====================================================================

Type        number
Default     0
Aliases     FrameHeightSizeOffsetSub

Same as HeighMod but for frame2 in ShowSub(). Additional pixels
added to the sub-menu frame height.

Used in     ShowSub() — line 1786

Example
    GameCooltip:SetOption("HeighModSub", 4)


=====================================================================
110) TooltipFrameHeightOffset
=====================================================================

Type        number
Default     0
Aliases     (none)

Additional pixels added to frame1 height in tooltip mode (types 1
and 2). Applied after the height calculation in BuildTooltip(),
added to the calculated height value.

Used in     BuildTooltip() — line 2251

Example
    GameCooltip:SetOption("TooltipFrameHeightOffset", 6)


=====================================================================
111) TooltipFrameHeightOffsetSub
=====================================================================

Type        number
Default     0
Aliases     (none)

Same as TooltipFrameHeightOffset but for frame2 in
BuildTooltipSecondFrame().

Used in     BuildTooltipSecondFrame() — line 2004

Example
    GameCooltip:SetOption("TooltipFrameHeightOffsetSub", 4)


=====================================================================
112) IconBlendMode
=====================================================================

Type        string
Default     nil (falls back to "BLEND")
Aliases     (none)

Sets the blend mode for all icons (left and right) on all lines.
Also used as the "rest state" blend mode when the mouse leaves a
button (restored from IconBlendModeHover).

WoW blend modes: "BLEND", "ADD", "ALPHAKEY", "DISABLE", "MOD".

Used in     TextAndIcon() — lines 1309–1310 (left), 1372–1373 (right),
            OnLeaveMainButton — lines 836–838,
            OnLeaveSecondaryButton — lines 920–922

Example
    GameCooltip:SetOption("IconBlendMode", "ADD")


=====================================================================
113) IconBlendModeHover
=====================================================================

Type        string
Default     nil (no hover change)
Aliases     (none)

Sets the blend mode for icons when the mouse hovers over a line
button. When the mouse leaves, the blend mode reverts to
IconBlendMode (or "BLEND").

Used in     OnEnterMainButton — lines 791–792,
            OnEnterSecondaryButton — lines 897–898

Example
    GameCooltip:SetOption("IconBlendModeHover", "ADD")
    GameCooltip:SetOption("IconBlendMode", "BLEND")


=====================================================================
114) SubFollowButton
=====================================================================

Type        boolean
Default     nil / false
Aliases     (none)

When true, the sub-menu (frame2) is positioned adjacent to the
specific main menu button that triggered it, rather than aligned
to the full frame1. The sub-menu's left edge aligns with the
button's right edge (or vice versa if on the left side).

Used in     ShowSub() — lines 1813–1820

Example
    GameCooltip:SetOption("SubFollowButton", true)


=====================================================================
115) IgnoreArrows
=====================================================================

Type        boolean
Default     nil / false
Aliases     (none)

Hides the sub-menu arrow indicators on main menu lines. Normally,
lines that have sub-entries show a small ">" arrow on the right side
and the frame width is increased by 16px to accommodate it. Setting
this to true hides those arrows and removes the extra width.

Used in     BuildCooltip() — line 2451

Example
    GameCooltip:SetOption("IgnoreArrows", true)


=====================================================================
116) SelectedTopAnchorMod / SelectedBottomAnchorMod /
     SelectedLeftAnchorMod / SelectedRightAnchorMod
=====================================================================

Type        number (each)
Default     0 (each)
Aliases     (none)

Pixel offsets that adjust the position of the selection highlight
texture relative to the selected button. The selection highlight
consists of top/bottom/middle textures anchored to the button edges.

    SelectedLeftAnchorMod   shifts left edges (default base: 4)
    SelectedRightAnchorMod  shifts right edges (default base: -4)
    SelectedTopAnchorMod    shifts top edges (default base: 0)
    SelectedBottomAnchorMod shifts bottom edges (default base: 0)

Used in     SetSelectedAnchor() — lines 967–971

Example
    GameCooltip:SetOption("SelectedLeftAnchorMod", -2)
    GameCooltip:SetOption("SelectedRightAnchorMod", 2)


=====================================================================
117) SparkTexture
=====================================================================

Type        string (texture path)
Default     nil (uses the spark's original texture set at creation)
Aliases     (none)

Overrides the texture used for the spark (glow) effect on status
bars.

Used in     RefreshSpark() — line 1474

Example
    GameCooltip:SetOption("SparkTexture",
        "Interface\\CastingBar\\UI-CastingBar-Spark")


=====================================================================
118) SparkWidth / SparkHeight
=====================================================================

Type        number (each)
Default     nil (uses the spark's original dimensions)
Aliases     (none)

Override the base width and height of the spark texture.

Used in     RefreshSpark() — lines 1478–1479

Example
    GameCooltip:SetOption("SparkWidth", 24)
    GameCooltip:SetOption("SparkHeight", 24)


=====================================================================
119) SparkWidthOffset / SparkHeightOffset
=====================================================================

Type        number (each)
Default     0
Aliases     (none)

Additional pixels added to the spark width/height. Combined with
SparkWidth/SparkHeight (or original size) for the final dimensions:
    finalWidth = SparkWidth + SparkWidthOffset
    finalHeight = SparkHeight + SparkHeightOffset

Used in     RefreshSpark() — lines 1480–1481

Example
    GameCooltip:SetOption("SparkWidthOffset", 4)
    GameCooltip:SetOption("SparkHeightOffset", 4)


=====================================================================
120) SparkAlpha
=====================================================================

Type        number (0–1)
Default     1
Aliases     (none)

Alpha transparency of the spark texture.

Used in     RefreshSpark() — line 1476

Example
    GameCooltip:SetOption("SparkAlpha", 0.7)


=====================================================================
121) SparkColor
=====================================================================

Type        color (ParseColors-compatible)
Default     "white"
Aliases     (none)

Vertex color applied to the spark texture.

Used in     RefreshSpark() — line 1477

Example
    GameCooltip:SetOption("SparkColor", "yellow")
    GameCooltip:SetOption("SparkColor", {1, 0.8, 0, 1})


=====================================================================
122) SparkPositionXOffset / SparkPositionYOffset
=====================================================================

Type        number (each)
Default     0
Aliases     (none)

Additional pixel offset for the spark position. The spark is
normally positioned at the bar's fill point. These offsets shift
it horizontally and vertically from that calculated position.

Used in     RefreshSpark() — lines 1482–1483, 1489–1493

Example
    GameCooltip:SetOption("SparkPositionXOffset", 2)
    GameCooltip:SetOption("SparkPositionYOffset", -1)


=====================================================================
123) NoLanguageDetection
=====================================================================

Type        boolean
Default     nil / false
Aliases     (none)

Disables automatic font language detection. Normally, TextAndIcon
detects the language of each text string and switches to an
appropriate font (e.g., CJK fonts for Chinese characters). Setting
this to true keeps the current font regardless of text content.

Only effective when TextFont is not set (TextFont also disables
language detection).

Used in     TextAndIcon() — lines 1042, 1157

Example
    GameCooltip:SetOption("NoLanguageDetection", true)


=====================================================================
124) UseTrilinearLeft
=====================================================================

Type        boolean
Default     nil / false
Aliases     (none)

Enables trilinear filtering on left-side icon textures. When true,
textures use "TRILINEAR" filtering instead of "LINEAR". Produces
smoother icon rendering at the cost of slightly more GPU work.

Used in     TextAndIcon() — line 1289

Example
    GameCooltip:SetOption("UseTrilinearLeft", true)


=====================================================================
125) UseTrilinearRight
=====================================================================

Type        boolean
Default     nil / false
Aliases     (none)

Same as UseTrilinearLeft but for right-side icon textures.

Used in     TextAndIcon() — line 1356

Example
    GameCooltip:SetOption("UseTrilinearRight", true)


=====================================================================
126) Aliases quick reference
=====================================================================

    ┌─────────────────────────────┬──────────────────────────────┐
    │ Alias name                  │ Resolves to                  │
    ├─────────────────────────────┼──────────────────────────────┤
    │ LineHeightSizeOffset        │ ButtonHeightMod              │
    │ LineHeightSizeOffsetSub     │ ButtonHeightModSub           │
    │ FrameHeightSizeOffset       │ HeighMod                     │
    │ FrameHeightSizeOffsetSub    │ HeighModSub                  │
    │ TextOutline                 │ TextShadow                   │
    │ TextSilhouette              │ TextActuallyShadow           │
    │ TextContour                 │ TextActuallyShadow           │
    │ LeftPadding                 │ LeftBorderSize               │
    │ RightPadding                │ RightBorderSize              │
    │ LinePadding                 │ YSpacingMod                  │
    │ VerticalPadding             │ YSpacingMod                  │
    │ LinePaddingSub              │ YSpacingModSub               │
    │ VerticalPaddingSub          │ YSpacingModSub               │
    │ LineYOffset                 │ ButtonsYMod                  │
    │ VerticalOffset              │ ButtonsYMod                  │
    │ LineYOffsetSub              │ ButtonsYModSub               │
    │ VerticalOffsetSub           │ ButtonsYModSub               │
    └─────────────────────────────┴──────────────────────────────┘


=====================================================================
End of Part 4
=====================================================================


=====================================================================
Part 5 — Fields, frame creation, button widgets, and scripts
(lines 227–1029)
=====================================================================

This final part covers the gameCooltip instance fields (state
tracking, defaults, data containers), the frame construction factory,
the button widget factory, and all the interactive scripts that drive
menu hover/leave/click behavior.


=====================================================================
127) Instance fields — data containers (lines 94–109)
=====================================================================

Location
    [cooltip.lua lines 94–109](Libs/DF/cooltip.lua#L94-L109)

Purpose
    These tables hold all the per-build content added via AddLine(),
    AddIcon(), AddStatusBar(), AddMenu(), etc. They are wiped on
    Reset().

Fields
    LeftTextTable           (table)  Main frame left-text entries.
    LeftTextTableSub        (table)  Sub frame left-text entries
                                     (keyed by main-line index).
    RightTextTable          (table)  Main frame right-text entries.
    RightTextTableSub       (table)  Sub frame right-text entries.
    LeftIconTable           (table)  Main frame left-icon entries.
    LeftIconTableSub        (table)  Sub frame left-icon entries.
    RightIconTable          (table)  Main frame right-icon entries.
    RightIconTableSub       (table)  Sub frame right-icon entries.
    Banner                  (table)  {false, false, false} — banner
                                     images; indexed 1–3.
    TopIconTableSub         (table)  Sub frame top-icon entries.
    StatusBarTable          (table)  Main frame status-bar entries.
    StatusBarTableSub       (table)  Sub frame status-bar entries.
    WallpaperTable          (table)  Main frame wallpaper entries.
    WallpaperTableSub       (table)  Sub frame wallpaper entries.
    PopupFrameTable         (table)  Popup callbacks per line index.
                                     Each entry: {onEnter, onLeave,
                                     param1, param2}.

Behavior
    All tables are populated by the AddLine/AddIcon/AddStatusBar/
    AddMenu/AddPopUpFrame APIs. They are consumed by the build
    functions (BuildTooltip, BuildCooltip, ShowSub) and then wiped
    during Reset().


=====================================================================
128) Instance fields — menu state (lines 111–118)
=====================================================================

Location
    [cooltip.lua lines 111–118](Libs/DF/cooltip.lua#L111-L118)

Purpose
    Track menu callback functions, their parameters, and the
    currently selected menu entries.

Fields
    FunctionsTableMain      (table)  Click callbacks for main-menu
                                     lines. Keyed by line index.
    FunctionsTableSub       (table)  Click callbacks for sub-menu
                                     lines. Keyed [mainIndex][subIndex].
    ParametersTableMain     (table)  Parameters for main callbacks.
                                     Each entry: {param1, param2, param3}.
    ParametersTableSub      (table)  Parameters for sub callbacks.
                                     Keyed [mainIndex][subIndex].
    FixedValue              (any|nil) A fixed value passed as the
                                     second argument to all menu
                                     callbacks (after Host). Set via
                                     SetFixedParameter().
    SelectedIndexMain       (number|nil) Index of the currently
                                     selected main-menu line.
    SelectedIndexSec        (table)  Map of mainIndex → selected
                                     sub-menu index.

Usage locations
    - FunctionsTableMain/ParametersTableMain: populated by AddMenu()
      (line 3046), consumed by OnClickFunctionMainButton (line 1001).
    - FunctionsTableSub/ParametersTableSub: populated by AddMenu()
      (line 3046), consumed by OnClickFunctionSecondaryButton
      (line 1015).
    - SelectedIndexMain: set on click (line 996, 1027), read by
      BuildCooltip (line 2348, 2482) and ShowSub (line 2327).
    - SelectedIndexSec: set on click (line 1028), read by ShowSub
      (line 1701), wiped on Reset (line 2861).


=====================================================================
129) Instance fields — runtime counters (lines 227–243)
=====================================================================

Location
    [cooltip.lua lines 227–243](Libs/DF/cooltip.lua#L227-L243)

Purpose
    Track how many lines exist, which mode is active, and misc
    internal state required by the build/position pipeline.

Fields
    Indexes         (number, default 0)
        Number of lines currently added to the main frame. Incremented
        by AddLine(), consumed by all build functions and by Show().

    IndexesSub      (table, default {})
        Map of mainIndex → number of sub-lines for that main line.
        Populated by AddMenu() in sub-mode. Used by ShowSub() to know
        how many sub-buttons to render (line 1666, 1687, 1711), by
        OnEnterMainButton to decide whether to show a sub-menu
        (line 803), and by BuildCooltip for arrow display (line 2453).

    HaveSubMenu     (boolean, default false)
        Set to true when any sub-menu content is added via AddMenu()
        (line 3096). Checked by BuildTooltip (line 2287), BuildCooltip
        (line 2451, 2483), and ShowSub.

    SubIndexes      (number, default 0)
        Tracks the current sub-line index within the last main-line
        being built. Used internally by AddMenu() sub-mode to index
        into sub-content tables (line 3018, 3039, 3046).

    Type            (number, default 1)
        The cooltip display mode:
            1 = tooltip
            2 = tooltip with status bars
            3 = dropdown menu
        Set by SetType(). Read by virtually every script and build
        function. The guard `Type ~= 1 and Type ~= 2` means "is menu
        mode" and gates all interactive button behavior.

    Host            (frame|nil, default nil)
        The WoW frame the cooltip is anchored to. Set by SetHost()
        (line 2665). Used by SetMyPoint for anchor positioning
        (line 2500), by OnLeave handlers to check if the host is the
        leaving frame (line 550, 581), and by click callbacks as the
        first argument (line 1001, 1015). Cleared on Close (line 3850).

    LastSize        (number, default 0)
        Caches the most recent calculated width of the tooltip. Used
        in BuildTooltip and BuildTooltipSecondFrame for width
        stabilization — if the new width is within ±5 pixels of
        LastSize, the old value is kept to prevent flickering
        (line 1990, 2237).

    LastIndex       (number, default 0)
        Declared but not actively read anywhere in the current code.
        Reserved for future use.

    internalYMod    (number, default 0)
        Internal Y-axis modifier. Reset to 0 on Reset() (line 2855–
        2856). Note: the field is assigned twice on the same value in
        the init block (lines 241–242), which appears to be a
        copy/paste artifact.

    overlapChecked  (boolean, default false)
        Tracks whether CheckOverlap() has already run for the current
        build cycle. Reset to false during Reset() (line 2858).


=====================================================================
130) Instance fields — defaults (lines 245–261)
=====================================================================

Location
    [cooltip.lua lines 245–261](Libs/DF/cooltip.lua#L245-L261)

Purpose
    Provide fallback values for button height, text rendering, menu
    selection anchoring, and the rounded-corner visual preset.

Fields
    default_height      (number, default 20)
        The default pixel height of each line button. Used by
        BuildTooltip (line 2164) and BuildTooltipSecondFrame
        (line 1915) as the fallback when the ButtonHeightMod option
        is not set:
            button:SetHeight(ButtonHeightMod or default_height)

    default_text_size   (number, default 10.5)
        Declared but not directly referenced by name in the rendering
        code. The TextAndIcon function uses the literal 10 as a
        fallback instead. Reserved for external use.

    default_text_font   (string, default "GameFontHighlight")
        Declared but not directly referenced by name in the rendering
        code. The TextAndIcon function uses the TextFont option or
        resolves via defaultFont. Reserved for external use.

    selectedAnchor      (table)
        Base insets for the selection highlight texture. Initially
        set at line 249–253 ({left=2, right=0, top=0, bottom=0}),
        then overwritten at line 949–952 ({left=4, right=-4, top=0,
        bottom=0}). The final values are used by SetSelectedAnchor()
        (line 967–971) combined with the SelectedLeftAnchorMod etc.
        options.

    defaultFont         (string)
        Set to DF:GetBestFontForLanguage() — a font file path
        appropriate for the current WoW client locale. Used as the
        font for both left and right text in TextAndIcon() when no
        per-line font override is provided (line 1134, 1245).

    RoundedFramePreset  (table)
        Visual configuration for rounded corners:
            { color = {.075,.075,.075,1},
              border_color = {.3,.3,.3,1},
              roundness = 8 }
        Passed to DF:AddRoundedCornersToFrame() during frame creation
        (line 284). The border_color is also used during Reset() to
        restore the original border (line 2847–2848).


=====================================================================
131) parseFont() — font resolution helper (lines 263–274)
=====================================================================

Location
    [cooltip.lua lines 263–274](Libs/DF/cooltip.lua#L263-L274)

Signature
    local parseFont = function(font)

Purpose
    Resolves a font identifier to a usable font file path. Handles
    three formats:
    1. SharedMedia font name → calls SharedMedia:Fetch("font", font)
    2. Font object reference → extracts path via :GetFont()
    3. Raw file path string → returned as-is

Parameters
    font    (string|table)
        A SharedMedia font name, a WoW FontObject reference, or a
        direct font file path.

Returns
    (string) A font file path usable with :SetFont().

Usage
    Called by TextAndIcon() when setting left/right text fonts
    (line 1134, 1245). Wraps gameCooltip.defaultFont or the
    TextFont option before passing to :SetFont().


=====================================================================
132) createTooltipFrames() — frame construction factory (lines 278–381)
=====================================================================

Location
    [cooltip.lua lines 278–381](Libs/DF/cooltip.lua#L278-L381)

Signature
    local createTooltipFrames = function(self)

Purpose
    Initializes a tooltip frame (either frame1 or frame2) with all
    its visual layers: backdrop, background textures, selection
    highlight, banner images, title elements, gradient overlay, and
    a 3D model frame.

Parameters
    self    (frame)
        The frame to initialize (frame1 or frame2).

Behavior
    1. Sets initial size to 500×500 and anchors to CENTER of UIParent.

    2. Rounded corners setup (lines 281–286):
       - If not already done (HaveRoundedCorners flag), calls
         DF:AddRoundedCornersToFrame() with RoundedFramePreset,
         then immediately disables them.
       - Sets HaveRoundedCorners = true so this only runs once.

    3. Backdrop (lines 288–290):
       - Applies defaultBackdrop (tooltip background + white 1px
         border).
       - Sets backdrop color to defaultBackdropColor (dark gray 95%
         opacity).
       - Sets border color to defaultBackdropBorderColor (near black).

    4. frameBackgroundTexture (lines 293–296):
       - BACKGROUND layer, sublevel 2.
       - Initially transparent (0,0,0,0).
       - Colors are set at runtime by SetColor().

    5. frameWallpaper (lines 299–302):
       - BACKGROUND layer, sublevel 4.
       - Fills the full frame area.
       - Texture set at runtime by SetupWallpaper().

    6. Selection highlight textures (lines 304–325):
       selectedTop
           ARTWORK layer, gray 75% opacity, 3px height strip.
       selectedBottom
           ARTWORK layer, gray 75% opacity, 3px height strip.
       selectedMiddle
           ARTWORK layer, gray 75% opacity, stretched between
           selectedTop's bottom and selectedBottom's top.
       These three textures form a highlight box around the
       currently selected menu button. Controlled by
       ShowSelectedTexture/HideSelectedTexture/SetSelectedAnchor.

    7. gradientTexture (lines 312–315):
       - OVERLAY layer, sublevel -7.
       - Vertical gradient from {0,0,0,0.2} at bottom to
         {0,0,0,0} at top. Covers entire frame.
       - Adds subtle depth. Hidden when rounded corners are enabled.

    8. Banner elements (lines 327–358):
       upperImage      OVERLAY texture, anchored at bottom of top
                        edge. Hidden by default.
       upperImage2     ARTWORK texture, same anchor. Hidden.
       upperImageText  OVERLAY fontstring, left of upperImage,
                        13pt GameTooltipHeaderText.
       upperImageText2 OVERLAY fontstring, positioned at BOTTOMRIGHT
                        → LEFT of frame.
       These are shown via SetBannerImage() and SetBannerText().

    9. Title elements (lines 360–373):
       titleIcon       OVERLAY texture using Challenges atlas,
                        anchored at bottom of top edge. Hidden.
       titleText       OVERLAY fontstring (10pt), centered on
                        titleIcon.
       Controlled by SetTitle() and SetTitleAnchor().

   10. modelFrame (lines 375–380):
       A PlayerModel frame filling the frame with 5px padding.
       Hidden by default. Shown by SetNpcModel().

Created textures/regions per frame (summary):
    ┌──────────────────────┬──────────────┬───────────────┐
    │ Element              │ Draw Layer   │ Sublevel      │
    ├──────────────────────┼──────────────┼───────────────┤
    │ frameBackgroundTexture│ BACKGROUND  │ 2             │
    │ frameWallpaper       │ BACKGROUND   │ 4             │
    │ selectedTop          │ ARTWORK      │ default       │
    │ selectedBottom       │ ARTWORK      │ default       │
    │ selectedMiddle       │ ARTWORK      │ default       │
    │ gradientTexture      │ OVERLAY      │ -7            │
    │ upperImage           │ OVERLAY      │ default       │
    │ upperImage2          │ ARTWORK      │ default       │
    │ titleIcon            │ OVERLAY      │ default       │
    │ modelFrame           │ (frame)      │ —             │
    └──────────────────────┴──────────────┴───────────────┘


=====================================================================
133) Frame1 and Frame2 initialization (lines 384–450)
=====================================================================

Location
    [cooltip.lua lines 384–450](Libs/DF/cooltip.lua#L384-L450)

Purpose
    Creates (or reuses) the two global tooltip frames and sets up
    runtime references on the gameCooltip table.

Frame1 — main tooltip frame (lines 385–397)
    - Global name: "GameCooltipFrame1"
    - Created as a BackdropTemplate Frame parented to UIParent.
    - Added to UISpecialFrames so pressing Escape closes it.
    - Gets a flash animation via DF:CreateFlashAnimation().
    - Initialized by createTooltipFrames(frame1).

Frame2 — secondary / sub-menu frame (lines 399–412)
    - Global name: "GameCooltipFrame2"
    - Also a BackdropTemplate Frame on UIParent.
    - SetClampedToScreen(true) — cannot go off-screen.
    - Added to UISpecialFrames.
    - Initialized by createTooltipFrames(frame2).
    - Default anchor: bottomleft → bottomright of frame1, offset
      (4, 0) — sub-menu appears to the right of the main frame.
    - Gets a flash animation.

Post-initialization (lines 445–450)
    gameCooltip.frame1 = frame1
    gameCooltip.frame2 = frame2
    - Both frames are immediately faded out via DF:FadeFrame(_, 0).
    - frame1.Lines = {} and frame2.Lines = {} are initialized as
      empty arrays to hold button widgets.


=====================================================================
134) ShowRoundedCorner() / HideRoundedCorner() (lines 414–443)
=====================================================================

Location
    [cooltip.lua lines 414–443](Libs/DF/cooltip.lua#L414-L443)

ShowRoundedCorner()
    Enables the rounded-corner visual mode on both frames.
    - Calls EnableRoundedCorners() on each frame.
    - Removes the backdrop (SetBackdrop(nil)) since rounded corners
      render their own background.
    - Hides frameBackgroundTexture and gradientTexture on both frames
      to avoid visual conflicts.
    - Early-returns if HaveRoundedCorners is false (corners were
      never created).

HideRoundedCorner()
    Disables rounded corners and restores the standard appearance.
    - Calls DisableRoundedCorners() on each frame.
    - Shows frameBackgroundTexture and gradientTexture on both frames.
    - Early-returns if HaveRoundedCorners is false.

Usage
    Called by Preset() and Reset() to switch visual modes. Rounded
    corners use DF:AddRoundedCornersToFrame() which was set up in
    createTooltipFrames().


=====================================================================
135) SetTitle() (lines 457–462)
=====================================================================

Location
    [cooltip.lua lines 457–462](Libs/DF/cooltip.lua#L457-L462)

Signature
    gameCooltip:SetTitle(frameId, text)

Purpose
    Marks that a title should be displayed on the specified frame.

Parameters
    frameId     (number) Only frameId == 1 is handled.
    text        (string) Title text to display.

Behavior
    Sets gameCooltip.title1 = true and stores the text in
    gameCooltip.title_text. The actual rendering is handled by
    BuildTooltip/BuildCooltip when they check these flags.

Note
    Only frame1 is supported. Passing frameId == 2 has no effect.


=====================================================================
136) SetTitleAnchor() (lines 464–505)
=====================================================================

Location
    [cooltip.lua lines 464–505](Libs/DF/cooltip.lua#L464-L505)

Signature
    gameCooltip:SetTitleAnchor(frameId, anchorPoint, ...)

Purpose
    Positions the title icon and title text on the specified frame.

Parameters
    frameId         (number) 1 for main frame, 2 for sub frame.
    anchorPoint     (string) "left", "center", or "right"
                    (case-insensitive — lowered internally).
    ...             (vararg) Additional offset values passed to
                    SetPoint().

Behavior by anchorPoint
    "left":
        titleIcon anchored LEFT of the frame.
        titleText anchored to the RIGHT of titleIcon.

    "center":
        titleIcon at CENTER horizontally, BOTTOM → TOP of frame.
        titleText to the RIGHT of titleIcon.
        On frame1, text is set to "TESTE" (debug placeholder) and
        both elements are explicitly shown.

    "right":
        titleIcon anchored RIGHT of the frame.
        titleText to the LEFT of titleIcon.


=====================================================================
137) Frame interaction state fields (lines 511–513)
=====================================================================

Location
    [cooltip.lua lines 511–513](Libs/DF/cooltip.lua#L511-L513)

Purpose
    Track the mouse/interaction state used by the tooltip/menu
    auto-hide system.

Fields
    mouseOver       (boolean, default false)
        True when the mouse is over any cooltip frame or button.
        Set to true on OnEnter, false on OnLeave. Checked by the
        OnUpdate fade timers to decide whether to close.

    buttonClicked   (boolean, default false)
        True after any menu button has been clicked. Prevents the
        auto-close timer from hiding the menu while a click is
        being processed. Reset on frame1 OnHide (line 611).

    active          (boolean)
        Not initialized in this block but used throughout. Set to
        true on OnEnter (frame or button), false on OnLeave. The
        fade timers check `not active` before closing.

    hadInteractions (boolean)
        Set to true on any OnEnter. Not cleared during the build
        cycle. Used externally to detect if the user interacted.

    lastButtonInteracted (number|nil)
        Index of the last main-menu button the mouse entered. Used
        by OnEnterMainButton to re-show the sub-menu for the
        previously hovered button when the user moves between
        buttons (line 808). Cleared when frame2 is hidden.


=====================================================================
138) frame1 OnEnter script (lines 516–528)
=====================================================================

Location
    [cooltip.lua lines 516–528](Libs/DF/cooltip.lua#L516-L528)

Purpose
    Handles mouse entering the main tooltip frame.

Behavior
    Only activates in menu mode (Type ~= 1 and ~= 2):
    1. Sets active = true, mouseOver = true, hadInteractions = true.
    2. Stops any pending fade timer (SetScript OnUpdate nil).
    3. Ensures frame1 is fully visible (FadeFrame 0 = full opacity).
    4. If sub_menus exist, also ensures frame2 is visible.

    In tooltip mode (Type 1 or 2), does nothing — tooltips don't
    respond to mouse interaction on their frame.


=====================================================================
139) frame2 OnEnter script (lines 532–544)
=====================================================================

Location
    [cooltip.lua lines 532–544](Libs/DF/cooltip.lua#L532-L544)

Purpose
    Handles mouse entering the secondary frame.

Behavior
    If SubMenuIsTooltip option is set, immediately calls Close() —
    the sub-frame is purely informational and entering it should
    dismiss everything.

    Otherwise (menu mode, Type ~= 1 and ~= 2):
    1. Sets active = true, mouseOver = true, hadInteractions = true.
    2. Stops fade timers on frame2.
    3. Ensures both frame1 and frame2 are fully visible.


=====================================================================
140) OnLeaveUpdateFrame1 — frame1 fade timer (lines 548–561)
=====================================================================

Location
    [cooltip.lua lines 548–561](Libs/DF/cooltip.lua#L548-L561)

Signature
    local OnLeaveUpdateFrame1 = function(self, deltaTime)

Purpose
    An OnUpdate handler that closes the tooltip/menu 0.7 seconds
    after the mouse leaves frame1, unless the user re-enters.

Behavior
    Accumulates elapsed time. After 0.7 seconds:
    - If not active AND not buttonClicked AND `self == Host`:
      fades out both frames.
    - If not active (general case): fades out both frames.
    - Clears both frame OnUpdate scripts.

    The 0.7-second delay gives the user time to move the mouse
    between frame1, frame2, or buttons without causing a close.


=====================================================================
141) frame1 OnLeave script (lines 565–575)
=====================================================================

Location
    [cooltip.lua lines 565–575](Libs/DF/cooltip.lua#L565-L575)

Purpose
    Handles mouse leaving frame1.

Behavior
    Sets active = false, mouseOver = false. Resets elapsedTime = 0.
    Installs OnLeaveUpdateFrame1 as the OnUpdate handler to start
    the 0.7-second close countdown.

    Note: both branches (menu mode and tooltip mode) execute the
    same code — this appears to be a simplification where the
    original two cases collapsed to identical behavior.


=====================================================================
142) OnLeaveUpdateFrame2 — frame2 fade timer (lines 579–592)
=====================================================================

Location
    [cooltip.lua lines 579–592](Libs/DF/cooltip.lua#L579-L592)

Signature
    local OnLeaveUpdateFrame2 = function(self, deltaTime)

Purpose
    Mirror of OnLeaveUpdateFrame1 but for frame2. Same 0.7-second
    delay logic. Fades both frames and clears both OnUpdate scripts.


=====================================================================
143) frame2 OnLeave script (lines 596–606)
=====================================================================

Location
    [cooltip.lua lines 596–606](Libs/DF/cooltip.lua#L596-L606)

Purpose
    Mirror of frame1's OnLeave. Sets active/mouseOver to false,
    resets timer, installs OnLeaveUpdateFrame2.


=====================================================================
144) frame1 OnHide script (lines 610–618)
=====================================================================

Location
    [cooltip.lua lines 610–618](Libs/DF/cooltip.lua#L610-L618)

Purpose
    Cleanup when frame1 is hidden (by fading, Escape, or Close()).

Behavior
    1. Sets active = false, buttonClicked = false, mouseOver = false.
    2. Re-parents both frames to UIParent (in case they were
       reparented to a host's parent for strata matching).
    3. Resets both frames to "TOOLTIP" frame strata.


=====================================================================
145) createButtonWidgets() — line button factory (lines 625–734)
=====================================================================

Location
    [cooltip.lua lines 625–734](Libs/DF/cooltip.lua#L625-L734)

Signature
    local createButtonWidgets = function(self)

Purpose
    Populates a newly created button frame with all the visual
    widgets needed for one cooltip line: status bar, icons, text,
    sparks, arrow, and background highlight.

Parameters
    self    (button frame)
        The raw Button frame to be decorated.

Widgets created (in order)

    self.statusbar                  (StatusBar frame)
        Main progress bar. Anchored to fill the button with 10px
        left/right padding. Default height 20. Min/max 0–100.
        Default texture: UI-Character-Skills-Bar.
        Children:
            .texture            Status bar fill texture (BACKGROUND).
            .spark              Original spark effect (BACKGROUND),
                                12×24, blend ADD. Hidden by default.
            .background         Highlight overlay (ARTWORK). Hidden.
                                Uses FriendsFrame highlight bar.
            .leftIcon           Left icon (OVERLAY), 16×16.
            .leftIconMask       Mask texture for leftIcon.
            .rightIcon          Right icon (OVERLAY), 16×16.
            .rightIconMask      Mask texture for rightIcon.
            .spark2             Second spark (OVERLAY), 32×32, ADD.
                                Hidden by default.
            .subMenuArrow       Right-side arrow texture (OVERLAY),
                                12×12, ADD blend. Uses ChatFrame
                                expand arrow. Hidden by default.
            .leftText           FontString left-aligned, 10pt.
            .rightText          FontString right-aligned, 10pt.

    self.statusbar2                 (StatusBar frame)
        Background/underlayer status bar. Anchored to match
        statusbar's position. Used for dual-bar display (background
        bar behind the main value bar). Initial value = 0.

Shortcut references
    After creation, the function installs shortcut references on
    the button itself for quick access:
        self.leftIcon       = self.statusbar.leftIcon
        self.rightIcon      = self.statusbar.rightIcon
        self.leftIconMask   = self.statusbar.leftIconMask
        self.rightIconMask  = self.statusbar.rightIconMask
        self.texture        = self.statusbar.texture
        self.spark          = self.statusbar.spark
        self.spark2         = self.statusbar.spark2
        self.leftText       = self.statusbar.leftText
        self.rightText      = self.statusbar.rightText
        self.background     = self.statusbar.background

Frame level management
    statusbar:  button:GetFrameLevel() + 2
    statusbar2: statusbar:GetFrameLevel() - 1
    This ensures the main bar renders above the background bar.

Scripts installed
    OnMouseDown → GameCooltipButtonMouseDown
    OnMouseUp   → GameCooltipButtonMouseUp
    Registers for "LeftButtonDown" clicks.


=====================================================================
146) GameCooltipButtonMouseDown / MouseUp (lines 737–747)
=====================================================================

Location
    [cooltip.lua lines 737–747](Libs/DF/cooltip.lua#L737-L747)

Purpose
    Visual press/release feedback on button text. When the mouse
    button is pressed, the left text shifts down-left by 1 pixel.
    On release, it returns to its normal position.

GameCooltipButtonMouseDown(button)
    Reads TextHeightMod from options (default 0).
    Repositions leftText:
        anchor1: center of leftIcon, offset (0, 0 + heightMod)
        anchor2: right of leftIcon, offset (4, -1 + heightMod)

GameCooltipButtonMouseUp(button)
    Same TextHeightMod. Restores leftText:
        anchor1: center of leftIcon, offset (0, 0 + heightMod)
        anchor2: right of leftIcon, offset (3, 0 + heightMod)

    The difference: MouseDown uses x=4, y=-1; MouseUp uses x=3,
    y=0. This creates a subtle downward press animation.


=====================================================================
147) gameCooltip:CreateButton() (lines 750–753)
=====================================================================

Location
    [cooltip.lua lines 750–753](Libs/DF/cooltip.lua#L750-L753)

Signature
    gameCooltip:CreateButton(index, frame, name)

Purpose
    Creates a new Button frame, decorates it with createButtonWidgets,
    and stores it in the parent frame's Lines array.

Parameters
    index   (number)    Position in frame.Lines[].
    frame   (frame)     Parent frame (frame1 or frame2).
    name    (string)    Global name for the button.

Returns
    The new button frame.

Note
    The local variable is named "newNutton" (typo for "newButton").


=====================================================================
148) OnEnterUpdateButton — sub-menu show timer (lines 756–763)
=====================================================================

Location
    [cooltip.lua lines 756–763](Libs/DF/cooltip.lua#L756-L763)

Signature
    local OnEnterUpdateButton = function(self, deltaTime)

Purpose
    A minimal OnUpdate timer that triggers ShowSub() after a tiny
    delay (0.001 seconds) when the mouse enters a main-menu button
    that has sub-entries.

Behavior
    1. Accumulates deltaTime.
    2. After 0.001 seconds (effectively next frame):
       - Calls ShowSub(self.index) to display the sub-menu.
       - Stores self.index in lastButtonInteracted.
       - Clears the OnUpdate script.

    The delay prevents the sub-menu from flickering when the mouse
    moves quickly between buttons.


=====================================================================
149) OnLeaveUpdateButton — button fade-out timer (lines 766–777)
=====================================================================

Location
    [cooltip.lua lines 766–777](Libs/DF/cooltip.lua#L766-L777)

Signature
    local OnLeaveUpdateButton = function(self, deltaTime)

Purpose
    Closes the cooltip 0.7 seconds after the mouse leaves a main
    button, unless the user re-enters (active becomes true again).

Behavior
    After 0.7 seconds:
    - If not active AND not buttonClicked: fades both frames.
    - If not active (general): fades both frames.
    - Clears frame1's OnUpdate script.


=====================================================================
150) OnEnterMainButton — main button hover handler (lines 781–825)
=====================================================================

Location
    [cooltip.lua lines 781–825](Libs/DF/cooltip.lua#L781-L825)

Signature
    local OnEnterMainButton = function(self)

Purpose
    Handles mouse entering a main-menu line button. Shows highlight,
    manages sub-menu display, and triggers popup callbacks.

Behavior (menu mode only — Type ~= 1 and ~= 2, and not a divider)

    1. State setup:
       - active = true, mouseOver = true, hadInteractions = true.
       - Clears OnUpdate timers on both frames.
       - Shows self.background (highlight bar).

    2. Icon blend mode:
       - Sets leftIcon blend to IconBlendModeHover option if set,
         otherwise "BLEND" (line 792).

    3. Decision tree for sub-content:

       a. PopupFrameTable[self.index] exists (line 797):
          Calls the onEnter callback from the popup table with
          frame1, param1, param2.

       b. IndexesSub[self.index] > 0 (line 803):
          This button has sub-menu entries.
          - If SubMenuIsTooltip option is set:
            Shows sub-menu immediately via ShowSub(), resets
            self.index to self.ID.
          - Otherwise:
            If lastButtonInteracted exists, shows that sub-menu
            first (to maintain context). Then installs
            OnEnterUpdateButton to show this button's sub-menu
            after the 0.001s delay.

       c. No sub-content:
          Fades out frame2 and clears lastButtonInteracted.

    In tooltip mode (Type 1 or 2):
       Only sets mouseOver = true and hadInteractions = true.
       No highlight or sub-menu logic.


=====================================================================
151) OnLeaveMainButton — main button leave handler (lines 829–858)
=====================================================================

Location
    [cooltip.lua lines 829–858](Libs/DF/cooltip.lua#L829-L858)

Signature
    local OnLeaveMainButton = function(self)

Purpose
    Handles mouse leaving a main-menu line button. Hides highlight,
    restores icon blend mode, and starts the close countdown.

Behavior (menu mode)
    1. Sets active = false, mouseOver = false.
    2. Clears OnUpdate on the button itself.
    3. Hides self.background.
    4. Restores icon blend mode:
       - If IconBlendMode option is set, applies it to both left
         and right icons (line 840).
       - Otherwise uses "BLEND".
    5. If PopupFrameTable[self.index] exists, calls the onLeave
       callback (line 844–847).
    6. Starts the 0.7-second close timer via OnLeaveUpdateButton
       on frame1.

    In tooltip mode: same close timer behavior, no highlight logic.


=====================================================================
152) CreateMainFrameButton() (lines 863–867)
=====================================================================

Location
    [cooltip.lua lines 863–867](Libs/DF/cooltip.lua#L863-L867)

Signature
    gameCooltip:CreateMainFrameButton(i)

Purpose
    Creates a complete line button for the main frame (frame1).

Behavior
    1. Calls CreateButton(i, frame1, "GameCooltipMainButton"..i).
    2. Stores i in newButton.ID (the permanent index, distinct from
       self.index which may be reassigned).
    3. Sets OnEnter to OnEnterMainButton.
    4. Sets OnLeave to OnLeaveMainButton.

Returns
    The new button frame.


=====================================================================
153) OnLeaveUpdateButtonSec — secondary button fade timer (lines 872–882)
=====================================================================

Location
    [cooltip.lua lines 872–882](Libs/DF/cooltip.lua#L872-L882)

Signature
    local OnLeaveUpdateButtonSec = function(self, deltaTime)

Purpose
    Same as OnLeaveUpdateButton but for secondary frame buttons.
    After 0.7 seconds without re-entry, fades both frames and
    clears frame2's OnUpdate.


=====================================================================
154) OnEnterSecondaryButton — sub-menu button hover (lines 886–911)
=====================================================================

Location
    [cooltip.lua lines 886–911](Libs/DF/cooltip.lua#L886-L911)

Signature
    local OnEnterSecondaryButton = function(self)

Purpose
    Handles mouse entering a sub-menu line button.

Behavior
    If SubMenuIsTooltip is set, immediately calls Close() — the
    sub-frame is read-only and hovering a button should dismiss.

    Otherwise (menu mode):
    1. Sets active = true, mouseOver = true, hadInteractions = true.
    2. Shows self.background highlight.
    3. Applies IconBlendModeHover to leftIcon if set, else "BLEND".
    4. Cancels OnUpdate timers on both frames.
    5. Ensures both frames stay visible (FadeFrame 0).


=====================================================================
155) OnLeaveSecondaryButton — sub-menu button leave (lines 915–935)
=====================================================================

Location
    [cooltip.lua lines 915–935](Libs/DF/cooltip.lua#L915-L935)

Signature
    local OnLeaveSecondaryButton = function(self)

Purpose
    Handles mouse leaving a sub-menu line button.

Behavior (menu mode)
    1. Sets active = false, mouseOver = false.
    2. Hides self.background.
    3. Restores icon blend to IconBlendMode option or "BLEND".
    4. Starts the 0.7-second close timer via OnLeaveUpdateButtonSec
       on frame2.

    In tooltip mode: same close timer, no highlight logic.


=====================================================================
156) CreateButtonOnSecondFrame() (lines 939–943)
=====================================================================

Location
    [cooltip.lua lines 939–943](Libs/DF/cooltip.lua#L939-L943)

Signature
    gameCooltip:CreateButtonOnSecondFrame(i)

Purpose
    Creates a complete line button for the secondary frame (frame2).

Behavior
    1. Calls CreateButton(i, frame2, "GameCooltipSecButton"..i).
    2. Sets newButton.ID = i.
    3. Sets OnEnter to OnEnterSecondaryButton.
    4. Sets OnLeave to OnLeaveSecondaryButton.

Returns
    The new button frame.


=====================================================================
157) Selected anchor re-initialization (lines 948–952)
=====================================================================

Location
    [cooltip.lua lines 948–952](Libs/DF/cooltip.lua#L948-L952)

Purpose
    Overwrites the initial selectedAnchor values set at lines 249–253
    with the final production values.

Values (after overwrite)
    selectedAnchor.left   = 4     (was 2)
    selectedAnchor.right  = -4    (was 0)
    selectedAnchor.top    = 0     (unchanged)
    selectedAnchor.bottom = 0     (unchanged)

Note
    This second assignment is the effective one. The initial values
    at lines 249–253 are immediately overridden. The 4/-4 insets
    create a tighter selection box than the original 2/0 values.


=====================================================================
158) HideSelectedTexture() / ShowSelectedTexture() (lines 954–963)
=====================================================================

Location
    [cooltip.lua lines 954–963](Libs/DF/cooltip.lua#L954-L963)

HideSelectedTexture(frame)
    Hides all three selection textures (selectedTop, selectedBottom,
    selectedMiddle) on the given frame.

ShowSelectedTexture(frame)
    Shows all three selection textures on the given frame.

Parameters
    frame   (frame) Either frame1 or frame2.


=====================================================================
159) SetSelectedAnchor() (lines 965–981)
=====================================================================

Location
    [cooltip.lua lines 965–981](Libs/DF/cooltip.lua#L965-L981)

Signature
    gameCooltip:SetSelectedAnchor(frame, button)

Purpose
    Positions the selection highlight textures around a specific
    menu button, then shows them.

Parameters
    frame   (frame)  The parent frame (frame1 or frame2).
    button  (button) The button to highlight.

Behavior
    1. Calculates offsets from selectedAnchor base values plus
       the Selected*AnchorMod options:
       left   = selectedAnchor.left + SelectedLeftAnchorMod
       right  = selectedAnchor.right + SelectedRightAnchorMod
       top    = selectedAnchor.top + SelectedTopAnchorMod
       bottom = selectedAnchor.bottom + SelectedBottomAnchorMod

    2. Anchors selectedTop:
       TOPLEFT  → button TOPLEFT + (left+1, top)
       TOPRIGHT → button TOPRIGHT + (right-1, top)

    3. Anchors selectedBottom:
       BOTTOMLEFT  → button BOTTOMLEFT + (left+1, bottom)
       BOTTOMRIGHT → button BOTTOMRIGHT + (right-1, bottom)

    4. selectedMiddle stretches between them automatically via its
       fixed anchors set in createTooltipFrames.

    5. Calls ShowSelectedTexture(frame).


=====================================================================
160) OnClickFunctionMainButton — main button click (lines 984–1005)
=====================================================================

Location
    [cooltip.lua lines 984–1005](Libs/DF/cooltip.lua#L984-L1005)

Signature
    local OnClickFunctionMainButton = function(self, button)

Purpose
    Handles clicking a main-menu line button. Shows sub-menu if
    available, updates selection state, and fires the registered
    callback.

Parameters
    self    (button) The clicked button. Has .index (current line).
    button  (string) Mouse button name ("LeftButton", etc.).

Behavior
    1. Sub-menu check (line 985–987):
       If IndexesSub[self.index] > 0, calls ShowSub(self.index) and
       sets lastButtonInteracted.

    2. Selection (line 989–994):
       Sets buttonClicked = true.
       Calls SetSelectedAnchor(frame1, self) to position highlight.
       If NoLastSelectedBar option is NOT set, shows the selection
       texture.
       Sets SelectedIndexMain = self.index.

    3. Callback execution (line 998–1004):
       If FunctionsTableMain[self.index] exists:
       - Gets parameterTable from ParametersTableMain[self.index].
       - Calls: func(Host, FixedValue, param1, param2, param3,
         button) via xpcall with error handler.
       - Prints error on failure.


=====================================================================
161) OnClickFunctionSecondaryButton — sub button click (lines 1009–1028)
=====================================================================

Location
    [cooltip.lua lines 1009–1028](Libs/DF/cooltip.lua#L1009-L1028)

Signature
    local OnClickFunctionSecondaryButton = function(self, button)

Purpose
    Handles clicking a sub-menu line button. Fires the sub-callback,
    updates selection on both frames.

Parameters
    self    (button) The clicked button. Has .index (sub-line index)
            and .mainIndex (parent main-line index).
    button  (string) Mouse button name.

Behavior
    1. Sets buttonClicked = true.
    2. Positions selection highlight on frame2 around this button.

    3. Callback execution (line 1012–1019):
       Looks up FunctionsTableSub[self.mainIndex][self.index].
       If found, calls: func(Host, FixedValue, param1, param2,
       param3, button) via xpcall.

    4. Main frame selection (line 1021–1026):
       Also highlights the parent main-menu button by calling
       SetSelectedAnchor(frame1, frame1.Lines[self.mainIndex]).
       If NoLastSelectedBar is NOT set, shows frame1's selection.

    5. Stores selection indices:
       SelectedIndexMain = self.mainIndex
       SelectedIndexSec[self.mainIndex] = self.index


=====================================================================
162) Button widget layout diagram
=====================================================================

This diagram shows the visual hierarchy of a single line button as
created by createButtonWidgets():

    ┌─ Button (full width of tooltip) ─────────────────────────┐
    │                                                           │
    │  ┌─ statusbar2 (background bar, frame level N-1) ──────┐ │
    │  │  [background fill texture]                           │ │
    │  └──────────────────────────────────────────────────────┘ │
    │                                                           │
    │  ┌─ statusbar (main bar, frame level N+2) ──────────────┐ │
    │  │                                                       │ │
    │  │  [leftIcon 16x16]  [leftText ──→]  [←── rightText]   │ │
    │  │                     [bar fill]      [rightIcon 16x16] │ │
    │  │                                                       │ │
    │  │  [spark]                            [spark2]          │ │
    │  │  [background highlight]             [subMenuArrow →]  │ │
    │  └───────────────────────────────────────────────────────┘ │
    │                                                           │
    └───────────────────────────────────────────────────────────┘

    Key relationships:
    - leftText is anchored LEFT of leftIcon (3px gap)
    - rightText is anchored RIGHT of rightIcon (3px gap)
    - spark is at the RIGHT edge of statusbar
    - spark2 is an overlay spark at RIGHT-17
    - subMenuArrow is at RIGHT+3, shown for lines with sub-menus
    - background is a highlight that shows on hover


=====================================================================
163) Script assignment summary
=====================================================================

This table shows which script handler is assigned to each frame or
button type:

    ┌──────────────────┬────────────────────┬───────────────────────────────┐
    │ Frame / Widget   │ Script             │ Handler                       │
    ├──────────────────┼────────────────────┼───────────────────────────────┤
    │ frame1           │ OnEnter            │ (inline) menu keep-alive      │
    │ frame1           │ OnLeave            │ (inline) → OnLeaveUpdateFrame1│
    │ frame1           │ OnHide             │ (inline) cleanup state/strata │
    │ frame2           │ OnEnter            │ (inline) menu keep-alive      │
    │ frame2           │ OnLeave            │ (inline) → OnLeaveUpdateFrame2│
    │ main button      │ OnEnter            │ OnEnterMainButton             │
    │ main button      │ OnLeave            │ OnLeaveMainButton             │
    │ main button      │ OnClick            │ OnClickFunctionMainButton     │
    │ main button      │ OnMouseDown        │ GameCooltipButtonMouseDown    │
    │ main button      │ OnMouseUp          │ GameCooltipButtonMouseUp      │
    │ secondary button │ OnEnter            │ OnEnterSecondaryButton        │
    │ secondary button │ OnLeave            │ OnLeaveSecondaryButton        │
    │ secondary button │ OnClick            │ OnClickFunctionSecondaryButton│
    │ secondary button │ OnMouseDown        │ GameCooltipButtonMouseDown    │
    │ secondary button │ OnMouseUp          │ GameCooltipButtonMouseUp      │
    └──────────────────┴────────────────────┴───────────────────────────────┘

    Note: OnClick handlers are assigned later by SetupMainButton()
    (line 1576) and SetupButtonOnSecondFrame() (line 1600), not in
    the creation functions.


=====================================================================
164) Auto-hide timing diagram
=====================================================================

This shows the flow of the auto-hide system for menus:

    Mouse enters frame/button
        → active = true, mouseOver = true
        → cancel any pending OnUpdate fade timer
        → ensure frames visible (FadeFrame 0)

    Mouse leaves button
        → active = false, mouseOver = false
        → elapsedTime = 0
        → install OnLeaveUpdate* as OnUpdate

    OnUpdate fires each frame:
        → elapsedTime += deltaTime
        → if elapsedTime > 0.7 AND not active AND not buttonClicked:
            → FadeFrame(frame1, 1)  -- fade out
            → FadeFrame(frame2, 1)  -- fade out
            → clear OnUpdate

    If mouse re-enters before 0.7s:
        → active = true (cancels the check)
        → OnUpdate cleared

    On click:
        → buttonClicked = true (prevents auto-close)
        → auto-close only resets on frame1 OnHide


=====================================================================
165) Menu click callback flow
=====================================================================

When a user clicks a menu line, the full callback chain is:

    User clicks main button index 3
        │
        ├→ OnClickFunctionMainButton(self, button)
        │   │
        │   ├→ IndexesSub[3] > 0 ? ShowSub(3) : skip
        │   ├→ buttonClicked = true
        │   ├→ SetSelectedAnchor(frame1, self)  -- highlight
        │   ├→ SelectedIndexMain = 3
        │   └→ FunctionsTableMain[3](Host, FixedValue, p1, p2, p3, button)
        │
        └─ done

    User clicks sub-button (main=3, sub=2)
        │
        ├→ OnClickFunctionSecondaryButton(self, button)
        │   │
        │   ├→ buttonClicked = true
        │   ├→ SetSelectedAnchor(frame2, self) -- highlight sub
        │   ├→ FunctionsTableSub[3][2](Host, FixedValue, p1, p2, p3, button)
        │   ├→ SetSelectedAnchor(frame1, frame1.Lines[3]) -- highlight main
        │   ├→ SelectedIndexMain = 3
        │   └→ SelectedIndexSec[3] = 2
        │
        └─ done


=====================================================================
166) Complete field reference table
=====================================================================

    ┌──────────────────────────┬─────────────┬───────────┬─────────────────────────────────────────┐
    │ Field                    │ Type        │ Default   │ Purpose                                 │
    ├──────────────────────────┼─────────────┼───────────┼─────────────────────────────────────────┤
    │ LeftTextTable            │ table       │ {}        │ Main frame left-text per line            │
    │ LeftTextTableSub         │ table       │ {}        │ Sub frame left-text per line             │
    │ RightTextTable           │ table       │ {}        │ Main frame right-text per line           │
    │ RightTextTableSub        │ table       │ {}        │ Sub frame right-text per line            │
    │ LeftIconTable            │ table       │ {}        │ Main frame left-icon per line            │
    │ LeftIconTableSub         │ table       │ {}        │ Sub frame left-icon per line             │
    │ RightIconTable           │ table       │ {}        │ Main frame right-icon per line           │
    │ RightIconTableSub        │ table       │ {}        │ Sub frame right-icon per line            │
    │ Banner                   │ table       │{F,F,F}    │ Banner image storage (3 slots)           │
    │ TopIconTableSub          │ table       │ {}        │ Sub frame top-icon entries               │
    │ StatusBarTable           │ table       │ {}        │ Main frame status-bar per line           │
    │ StatusBarTableSub        │ table       │ {}        │ Sub frame status-bar per line            │
    │ WallpaperTable           │ table       │ {}        │ Main frame wallpaper per line            │
    │ WallpaperTableSub        │ table       │ {}        │ Sub frame wallpaper per line             │
    │ PopupFrameTable          │ table       │ {}        │ Popup callbacks per line                 │
    │ FunctionsTableMain       │ table       │ {}        │ Click callbacks for main lines           │
    │ FunctionsTableSub        │ table       │ {}        │ Click callbacks for sub lines            │
    │ ParametersTableMain      │ table       │ {}        │ Callback params for main lines           │
    │ ParametersTableSub       │ table       │ {}        │ Callback params for sub lines            │
    │ FixedValue               │ any         │ nil       │ Fixed param for all callbacks            │
    │ SelectedIndexMain        │ number      │ nil       │ Currently selected main line             │
    │ SelectedIndexSec         │ table       │ {}        │ Selected sub line per main line          │
    │ Indexes                  │ number      │ 0         │ Line count on main frame                 │
    │ IndexesSub               │ table       │ {}        │ Sub-line count per main line             │
    │ HaveSubMenu              │ boolean     │ false     │ Any sub-menu content exists              │
    │ SubIndexes               │ number      │ 0         │ Current sub-line cursor                  │
    │ Type                     │ number      │ 1         │ Display mode (1/2/3)                     │
    │ Host                     │ frame       │ nil       │ Anchor frame                             │
    │ LastSize                 │ number      │ 0         │ Cached width for stabilization           │
    │ LastIndex                │ number      │ 0         │ Reserved (unused)                        │
    │ internalYMod             │ number      │ 0         │ Internal Y modifier                      │
    │ overlapChecked           │ boolean     │ false     │ Overlap detection done flag              │
    │ default_height           │ number      │ 20        │ Button height fallback                   │
    │ default_text_size        │ number      │ 10.5      │ Text size fallback (unused in code)      │
    │ default_text_font        │ string      │ GFHighlight│ Font fallback (unused in code)          │
    │ selectedAnchor           │ table       │ {4,-4,0,0}│ Selection highlight insets               │
    │ defaultFont              │ string      │ (auto)    │ Best font for current locale             │
    │ RoundedFramePreset       │ table       │ (preset)  │ Rounded corner visual config             │
    │ LanguageEditBox          │ editbox     │ (created) │ Hidden editbox for language detection    │
    │ mouseOver                │ boolean     │ false     │ Mouse is over frame/button               │
    │ buttonClicked            │ boolean     │ false     │ A button was clicked                     │
    │ active                   │ boolean     │ (nil)     │ Interaction is active                    │
    │ hadInteractions          │ boolean     │ (nil)     │ Any interaction occurred                 │
    │ lastButtonInteracted     │ number      │ nil       │ Last hovered main button index           │
    │ NumLines                 │ number      │ 0         │ Line count (set during build)            │
    │ frame1                   │ frame       │ (created) │ Main tooltip frame                       │
    │ frame2                   │ frame       │ (created) │ Secondary/sub tooltip frame              │
    │ frame2_IsOnLeftside      │ boolean     │ nil       │ frame2 flipped to left side              │
    │ sub_menus                │ any         │ nil       │ Sub-menu existence flag                  │
    │ OptionsTable             │ table       │ {}        │ Active options for current build         │
    │ OptionsList              │ table       │ (53 keys) │ Valid option name registry               │
    │ AliasList                │ table       │ (18 keys) │ Option alias → canonical name map        │
    └──────────────────────────┴─────────────┴───────────┴─────────────────────────────────────────┘


=====================================================================
End of Part 5
=====================================================================
