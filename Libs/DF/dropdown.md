Dropdown Widget – Part 1: Creation Functions & Frame Structure

=====================================================================
Overview
=====================================================================

The dropdown widget is a capsule-pattern object that wraps a WoW
Button frame. When clicked it opens a scrollable menu of options.
Selecting an option updates the button face (label, icon, statusbar,
colors) and fires a callback.

Two public constructors exist:

  DF:CreateDropDown()          – standard dropdown
  DF:CreateDropDownWithText()  – dropdown with an editable TextEntry
                                 overlay on the button face

Both ultimately delegate to DF:NewDropDown(), which builds the
capsule table, creates the raw frame via DF:CreateNewDropdownFrame(),
wires scripts and metamethods, and returns a df_dropdown object.

Individual option rows inside the open menu are built on-demand by
DF:CreateDropdownButton().

The capsule table uses __index / __newindex metamethods so that
property-style access (e.g. dropdown.value, dropdown.width = 200)
is transparently routed through getter/setter functions.

Source file
    Libs/DF/dropdown.lua

Type annotations
    df_dropdown          – standard dropdown capsule
    df_dropdown_text     – text-entry variant (extends df_dropdown)
    dropdownoption       – single option table passed in the menu

Mixins applied to DropDownMetaFunctions (the shared metatable):
    SetPointMixin        – :SetPoint() helpers
    FrameMixin           – :Show() / :Hide() / :SetSize() / etc.
    TooltipHandlerMixin  – :SetTooltip() / :ShowTooltip() / etc.
    ScriptHookMixin      – :SetHook() / :RunHooksForWidget()
    LanguageMixin        – multi-language font selection


=====================================================================
1) DF:CreateDropDown()
=====================================================================

Location
    dropdown.lua  ~line 1710

Signature
    DF:CreateDropDown(parent, func, default, width, height,
                      member, name, template)

Purpose
    Public constructor for a standard dropdown. Thin wrapper that
    reorders parameters and delegates to DF:NewDropDown().

Parameters
    parent    (frame)     The WoW frame that will own this dropdown.
    func      (function)  A function returning a table of
                          dropdownoption tables. Called every time
                          the menu opens.
    default   (any)       Initial selection — a string (matched by
                          label or value) or a number (option index).
    width     (number?)   Button width.  Default 160.
    height    (number?)   Button height. Default 20.
    member    (string?)   If provided, parent[member] = dropdownObj.
    name      (string?)   Global frame name. Auto-generated if nil.
                          Supports "$parent" substitution.
    template  (table?)    Visual template applied after creation.

Returns
    (df_dropdown) The capsule object.

Behavior
    Calls DF:NewDropDown(parent, parent, name, member,
                         width, height, func, default, template)
    with container = parent.

Example
    local myDropdown = DF:CreateDropDown(
        UIParent,
        function() return { {value=1, label="Option A"} } end,
        1, 160, 20
    )


=====================================================================
2) DF:CreateDropDownWithText()
=====================================================================

Location
    dropdown.lua  ~line 1665

Signature
    DF:CreateDropDownWithText(parent, func, default, width, height,
                              member, name, template)

Purpose
    Creates a dropdown that also has an editable text entry overlaid
    on the button face. The user can either pick from the dropdown
    menu or type a value directly.

Parameters
    Same as DF:CreateDropDown().

Returns
    (df_dropdown_text) The capsule object, which has extra methods
    from the dropdownWithTextFunctions mixin.

Behavior
    1. Calls DF:NewDropDown() to build a standard dropdown.
    2. Sets dropDownObject.isText = true.
    3. Creates a DF:CreateTextEntry() overlaid on the button frame
       (topleft → bottomright, one frame level above the button).
    4. Mixes in dropdownWithTextFunctions (SetLeftMargin,
       SetRightMargin, AdjustMargins, SetText,
       SetOnPressEnterFunction, GetTextEntry).
    5. Hooks the label's :SetText() so that any text that would
       normally go to the fontstring is redirected to the TextEntry
       (the underlying label is set to "").
    6. Hooks OnEscapePressed on the TextEntry to close the dropdown.
    7. Applies a default right margin of 30px (room for the arrow).

Extra methods (df_dropdown_text only)
    :SetLeftMargin(left)
        Repositions TextEntry's left anchor with the given offset.

    :SetRightMargin(right)
        Repositions TextEntry's right anchor with the given
        negative offset.

    :AdjustMargins()
        Auto-sets left margin to icon width + 2 and right margin
        to arrow width + 2 (or 0 if arrow hidden).

    :SetText(text)
        Sets text into the TextEntry; clears the original label.

    :SetOnPressEnterFunction(func)
        Wires OnEnterPressed → func(self, fixedValue, text)
        and clears focus. Sets a no-op OnEditFocusLost.

    :GetTextEntry()
        Returns the underlying df_textentry object.

Example
    local editDropdown = DF:CreateDropDownWithText(
        UIParent,
        function() return { {value="abc", label="ABC"} } end,
        "abc", 200, 20
    )
    editDropdown:SetOnPressEnterFunction(function(self, fv, text)
        print("User typed:", text)
    end)


=====================================================================
3) DF:NewDropDown() – Internal Constructor
=====================================================================

Location
    dropdown.lua  ~line 1726

Signature
    DF:NewDropDown(parent, container, name, member,
                   width, height, func, default, template)

Purpose
    Builds the full capsule table, creates the underlying WoW frame,
    attaches scrollbar, hooks, scripts, selects the default option,
    and applies a template if given.

Parameters
    parent     (frame)     Owner frame.
    container  (frame)     Container frame (may differ from parent
                           when parent is itself a DF capsule).
    name       (string?)   Global name. Auto-generated from
                           DF.DropDownCounter if nil. "$parent" in
                           the string is replaced with the parent's
                           name.
    member     (string?)   Key on parent to store the capsule.
    width      (number?)   Default 160.
    height     (number?)   Default 20.
    func       (function)  Menu-builder function.
    default    (any)       Initial selection.
    template   (table?)    Visual template.

Returns
    (df_dropdown) Complete capsule object.

Construction sequence
    1.  Resolve name (auto-generate or $parent substitution).
    2.  Create capsule table: {type="dropdown", dframework=true}.
    3.  If member, store capsule on parent.
    4.  Unwrap parent/container if they are DF capsules (.widget).
    5.  Default: default → 1, width → 160, height → 20.
    6.  Create raw frame via DF:CreateNewDropdownFrame(parent, name),
        then PixelUtil.SetSize(frame, width, height).
    7.  Store references:
            .dropdown   = the raw Button frame
            .container  = container frame
            .widget     = same as .dropdown
            .func       = menu-builder function
            .realsizeW  = 165  (initial menu width)
            .realsizeH  = 300  (initial menu height)
            .FixedValue = nil
            .opened     = false
            .menus      = {}   (option frame cache)
            .myvalue    = nil
    8.  Resolve child references by global name:
            .label      = _G[name .. "_Text"]
            .icon       = _G[name .. "_IconTexture"]
            .statusbar  = _G[name .. "_StatusBarTexture"]
            .select     = _G[name .. "_SelectedTexture"]
    9.  Create scroll bar (DF:NewScrollBar) on the scroll frame,
        skin it (DF:ReskinSlider), hide it initially.
    10. Size label to (button width – 40, 10).
    11. Create HookList table:
            OnEnter, OnLeave, OnHide, OnShow, OnOptionSelected
    12. Set frame scripts:
            OnShow  → DetailsFrameworkDropDownOnShow
            OnHide  → DetailsFrameworkDropDownOnHide
            OnEnter → DetailsFrameworkDropDownOnEnter
            OnLeave → DetailsFrameworkDropDownOnLeave
    13. setmetatable(capsule, DropDownMetaFunctions).
    14. Select the default option:
            string → :Select(default)
            number → :Select(default) then :Select(default, true)
    15. Apply template if provided.


=====================================================================
4) DF:CreateNewDropdownFrame() – Raw Frame Construction
=====================================================================

Location
    dropdown.lua  ~line 1853

Signature
    DF:CreateNewDropdownFrame(parent, name)

Purpose
    Creates the actual WoW Button frame that serves as the visible
    dropdown button, plus the hidden border frame, scroll frame, and
    scroll child that form the open menu.

Parameters
    parent  (frame)   Owner frame.
    name    (string)  Global frame name.

Returns
    (Button) The raw dropdown button frame.

Frame hierarchy (diagram)

    Button "name" (BackdropTemplate, 150×20)
    ├── Texture  "name_StatusBarTexture"    [BACKGROUND]
    ├── Texture  "name_IconTexture"         [ARTWORK]
    ├── Texture  "name_RightTexture"        [OVERLAY]
    ├── Texture  "name_CenterTexture"       [OVERLAY]
    ├── FontString "name_Text"              [ARTWORK]
    ├── Texture  "name_ArrowTexture2"       [OVERLAY sub 2] (highlight, hidden)
    ├── Texture  "name_ArrowTexture"        [OVERLAY sub 1]
    ├── Frame    "name_Border"              [FULLSCREEN] (BackdropTemplate, hidden)
    └── ScrollFrame "name_ScrollFrame"      [FULLSCREEN] (hidden)
        └── Frame "name_ScrollFrame_ScrollChild" (BackdropTemplate)
            ├── Texture (unnamed)                [BACKGROUND] (black fill)
            ├── Texture "..._SelectedTexture"    [BACKGROUND]
            └── Texture "..._MouseOverTexture"   [ARTWORK]


Widget details (main button, 150×20 default)

  statusbar (Texture, BACKGROUND)
      Anchors: topleft → frame topleft, bottomright → frame bottomright
      Purpose: Holds the selected statusbar texture/color when the
               current option has .statusbar set.

  icon (Texture, ARTWORK)
      Anchors: left → frame left + 2
      Size: 20×20
      Default texture: Interface\COMMON\UI-ModelControlPanel
      Default texcoord: (0.625, 0.78125, 0.328125, 0.390625)
      Default alpha: 0.4
      Purpose: Displays the selected option's icon.

  rightTexture (Texture, OVERLAY)
      Anchors: right → frame right – 2
      Size: 20×20
      Purpose: Optional per-option right-side texture.

  centerTexture (Texture, OVERLAY)
      Anchors: center → frame center
      Size: 20×20
      Purpose: Optional per-option center texture.

  text (FontString, ARTWORK, "GameFontHighlightSmall")
      Anchors: left → icon right + 5
      JustifyH: left
      Font size: 10
      Default text: "no option selected" at 40% alpha
      Purpose: Displays the selected option's label.

  arrowTexture2 (Texture, OVERLAY sublevel 2)
      Anchors: right → frame right + 5, offset –1
      Size: 32×28
      Blend: ADD
      Texture: UI-ScrollBar-ScrollDownButton-Highlight
      Hidden by default; shown on mouse enter.

  arrowTexture (Texture, OVERLAY sublevel 1)
      Anchors: right → frame right + 5, offset –1
      Size: 32×28
      Texture: UI-ScrollBar-ScrollDownButton-Up
      Purpose: The always-visible down-arrow indicator.

Scripts on the main button
    OnSizeChanged → resizes label to (width – 40, 10)
    OnMouseDown   → opens or closes the menu (the main interaction)

Backdrop
    bgFile:   Interface\DialogFrame\UI-DialogBox-Background
    edgeFile: Interface\DialogFrame\UI-DialogBox-Border
    edgeSize: 1, tile: true, tileSize: 16
    insets:   {1, 1, 0, 1}
    Color:    (1, 1, 1, 0.5)


Menu container (border frame, "name_Border")

  Type: Frame + BackdropTemplate
  Strata: FULLSCREEN
  Size: 150×300
  Anchor: topleft → main button bottomleft
  Hidden by default.
  Backdrop: edgeFile = Buttons\WHITE8X8, edgeSize 1
  Colors: bg (0,0,0,0.92), border (0.2,0.2,0.2,0.8)
  OnHide: calls DetailsFrameworkDropDownOptionsFrameOnHide (→ Close)
  Added to UISpecialFrames so pressing Escape closes it.


Menu scroll frame ("name_ScrollFrame")

  Type: ScrollFrame + BackdropTemplate
  Strata: FULLSCREEN
  Size: 150×300
  Anchor: topleft → main button bottomleft
  Hidden by default.


Menu scroll child ("name_ScrollFrame_ScrollChild")

  Type: Frame + BackdropTemplate
  Size: 150×300
  Anchor: topleft → scroll frame topleft
  Has DF:ApplyStandardBackdrop().
  Children:
    backgroundTexture (unnamed, BACKGROUND)
        ColorTexture black (0,0,0,1), fills child.

    selected (Texture, BACKGROUND, "..._SelectedTexture")
        Size: 150×16
        Anchor: left → child left + 2
        Texture: Interface\RAIDFRAME\Raid-Bar-Hp-Fill
        Hidden. Shown when the currently-selected option is visible
        in the open menu; colored yellow (1,1,0,0.5).

    mouseover (Texture, ARTWORK, "..._MouseOverTexture")
        Size: 150×15
        Anchor: left → child left + 2
        Blend: ADD
        Texture: Interface\Buttons\UI-Listbox-Highlight
        Hidden. Repositioned on hover to the hovered option row.


=====================================================================
5) DF:CreateDropdownButton() – Option Row Frame
=====================================================================

Location
    dropdown.lua  ~line 1961

Signature
    DF:CreateDropdownButton(parent, name)

Purpose
    Creates a single option row inside the open dropdown menu.
    Option rows are created on demand and cached in object.menus[].

Parameters
    parent  (frame)   The scroll child frame.
    name    (string)  Global name, e.g. "MyDropdownRow1".

Returns
    (Button) The option button frame.

Frame hierarchy

    Button "name" (BackdropTemplate, 150×20)
    ├── Texture  "name_StatusBarTexture"  [ARTWORK]  (fills button)
    ├── Texture  "name_IconTexture"       [OVERLAY]  (left + 2, 20×20)
    ├── FontString "name_Text"            [OVERLAY]  (left of icon + 5, 10pt)
    ├── Button   "nameRightButton"        (DF:CreateButton, hidden)
    ├── Texture  "name_RightTexture"      [OVERLAY]  (right – 2, 20×20)
    └── Texture  "name_CenterTexture"     [OVERLAY]  (center, 20×20)

Widget details

  statusbar (Texture, ARTWORK)
      Anchors: fills the button
      Default texture: Interface\Tooltips\UI-Tooltip-Background
      Purpose: Background color per option (via .statusbar /
               .statusbarcolor in the option table).

  icon (Texture, OVERLAY)
      Anchors: left → button left + 2
      Size: 20×20
      Default texture: Interface\ICONS\Spell_ChargePositive
      Purpose: Per-option icon. Size adjustable via .iconsize.

  label (FontString, OVERLAY, "GameFontHighlightSmall")
      Anchors: left → icon right + 5
      Font size: 10
      Purpose: The option's label text. Repositioned to left of
               statusbar when no icon is present.

  rightButton (DF:CreateButton, hidden by default)
      Anchors: right → button right – 2
      Size: 16×16
      Template: OPTIONS_DROPDOWN_TEMPLATE
      Purpose: An optional secondary button per option, configured
               via the .rightbutton field on the option table.

  rightTexture (Texture, OVERLAY)
      Anchors: right → button right – 2
      Size: 20×20

  centerTexture (Texture, OVERLAY)
      Anchors: center → button center
      Size: 20×20

Scripts
    OnMouseDown → DetailsFrameworkDropDownOptionClick
    OnEnter     → DetailsFrameworkDropDownOptionOnEnter
    OnLeave     → DetailsFrameworkDropDownOptionOnLeave


=====================================================================
6) dropdownoption Table Structure
=====================================================================

Each option in the menu is described by a plain Lua table with
these fields:

  value           (any)           The value stored when this option
                                  is selected. Passed as 3rd arg
                                  to the onclick callback.

  label           (string)        Text displayed on the option row.

  onclick         (function?)     Callback:
                                  onclick(dropdownObj, fixedValue, value)
                                  Called when the option is clicked.

  icon            (string|number?) Texture path or fileID for the
                                  option's icon.

  iconcolor       (any?)          Color applied to the icon via
                                  DF:ParseColors(). Any format.

  iconsize        (number[]?)     {width, height}. Defaults to
                                  (rowHeight – 6, rowHeight – 6).

  texcoord        (number[]?)     {left, right, top, bottom} for
                                  the icon texture coordinates.

  color           (any?)          Color applied to the label text.
                                  Any format accepted by ParseColors.

  font            (string?)       Font object or path for the label.
                                  Overrides GameFontHighlightSmall.

  languageId      (string?)       Language ID for font selection.
                                  Detected automatically if nil.

  rightbutton     (function?)     If set, the rightButton on the
                                  option row is shown and this
                                  function is called:
                                  rightbutton(rightBtn, optionFrame,
                                              optionTable)

  statusbar       (string|number?) Texture for the row background.

  statusbarcolor  (any?)          Vertex color for the statusbar.
                                  Table {r, g, b, a}.

  rightTexture    (string|number?) Texture shown on the right side
                                  of the option row.

  centerTexture   (string|number?) Texture shown at the center of
                                  the option row.

  shown           (boolean|function?) Controls visibility of the
                                  option. If a function, called as
                                  shown(dropdown) and must return
                                  boolean. Options with shown=false
                                  are skipped.


=====================================================================
7) Capsule Object Fields (df_dropdown)
=====================================================================

After DF:NewDropDown() returns, the capsule table contains:

  Direct fields (rawget-accessible)
    .type          = "dropdown"
    .dframework    = true
    .dropdown      = the raw Button frame (same as .widget)
    .widget        = the raw Button frame
    .container     = container frame
    .func          = menu-builder function
    .realsizeW     = 165   (menu width, adjustable via SetMenuSize)
    .realsizeH     = 300   (menu height, adjustable via SetMenuSize)
    .FixedValue    = nil   (set via :SetFixedParameter())
    .opened        = false (toggled by :Open() / :Close())
    .menus         = {}    (cache of option row frames)
    .myvalue       = nil   (selected value)
    .label         = FontString  (name .. "_Text")
    .icon          = Texture     (name .. "_IconTexture")
    .statusbar     = Texture     (name .. "_StatusBarTexture")
    .select        = Texture     (name .. "_SelectedTexture")
    .scroll        = scroll bar object (DF:NewScrollBar)
    .HookList      = {OnEnter={}, OnLeave={}, OnHide={},
                      OnShow={}, OnOptionSelected={}}

  Additional fields (df_dropdown_text only)
    .isText        = true
    .TextEntry     = df_textentry capsule object

  Metamethod-routed properties (via __index / __newindex)

    Getter properties (dropdown.X reads):
      .value       → :GetValue()           → rawget .myvalue
      .text        → label:GetText()
      .shown       → :IsShown()
      .width       → button:GetWidth()
      .height      → button:GetHeight()
      .menuwidth   → rawget .realsizeW
      .menuheight  → rawget .realsizeH
      .tooltip     → :GetTooltip()
      .func        → :GetFunction()        → rawget .func

    Setter properties (dropdown.X = val writes):
      .tooltip     → :SetTooltip(val)
      .show        → if val then :Show() else :Hide()
      .hide        → if val then :Hide() else :Show()
      .width       → dropdown:SetWidth(val)
      .height      → dropdown:SetHeight(val)
      .menuwidth   → :SetMenuSize(val, nil)
      .menuheight  → :SetMenuSize(nil, val)
      .func        → :SetFunction(val)

    Any key not in GetMembers/SetMembers falls through to
    DropDownMetaFunctions (method lookup) or rawset/rawget.


=====================================================================
8) Visual Layout Diagram
=====================================================================

Main button (closed state):
┌──────────────────────────────────────────────────┐
│ [statusbar texture fills entire background]      │
│  ┌──┐                                    ┌────┐ │
│  │  │  Label Text                        │ ▼  │ │
│  │ic│                                    │arr │ │
│  └──┘                                    └────┘ │
│ (icon)                              (arrowTexture)│
└──────────────────────────────────────────────────┘

Open menu (below button):
┌──────────────────────────────────────────────────┐
│ [border frame: dark backdrop with 1px edge]      │
│  ┌────────────────────────────────────────────┐  │
│  │ [scroll child]                             │  │
│  │  ■ selected highlight (yellow bar)         │  │
│  │  ┌──┐ Option A label         [rightTex]    │  │
│  │  │ic│ Option B label         [rightTex]    │  │
│  │  └──┘ Option C label         [rightBtn]    │  │
│  │  ▒ mouseover highlight (ADD blend)         │  │
│  │  ...                                       │  │
│  └────────────────────────────────────────────┘  │
│                                        [scrollbar│
│                                         if needed│
└──────────────────────────────────────────────────┘

Each option row:
┌──────────────────────────────────────────────────┐
│ [statusbar fills row]                            │
│ ┌──┐                    ┌───┐  ┌──┐  ┌────────┐ │
│ │ic│ Label text         │ctr│  │rt│  │rightBtn│ │
│ └──┘                    └───┘  └──┘  └────────┘ │
│(icon)              (centerTex)(rightTex)(button) │
└──────────────────────────────────────────────────┘


=====================================================================
9) Frame Scripts Summary (Part 1 scope)
=====================================================================

Main button scripts (set in CreateNewDropdownFrame):
    OnSizeChanged → resizes label width to (frame width – 40)
    OnMouseDown   → DetailsFrameworkDropDownOnMouseDown
                    If not opened and not locked down:
                      calls func() to get options, builds menu
                      rows, opens scroll frame and border.
                    If opened: calls :Close().

Main button scripts (set in NewDropDown):
    OnShow  → DetailsFrameworkDropDownOnShow  (fires OnShow hooks)
    OnHide  → DetailsFrameworkDropDownOnHide  (fires OnHide hooks,
              calls :Close())
    OnEnter → DetailsFrameworkDropDownOnEnter (backdrop highlight,
              shows arrowTexture2, shows tooltip)
    OnLeave → DetailsFrameworkDropDownOnLeave (resets backdrop,
              hides arrowTexture2, hides tooltip)

Border frame:
    OnHide  → DetailsFrameworkDropDownOptionsFrameOnHide
              (calls :Close() on the capsule)

Option row scripts (set in CreateDropdownButton):
    OnMouseDown → DetailsFrameworkDropDownOptionClick
                  Calls :Selected(optionTable), :Close(),
                  runs onclick callback, stores myvalue/myvaluelabel.
    OnEnter     → DetailsFrameworkDropDownOptionOnEnter
                  Positions mouseover highlight on this row.
                  If option has a .desc, shows GameCooltip2 tooltip.
    OnLeave     → DetailsFrameworkDropDownOptionOnLeave
                  Hides mouseover highlight, hides GameCooltip2.


=====================================================================
End of Part 1
=====================================================================


=====================================================================
Part 2: Metamethod Members (__index / __newindex)
=====================================================================

Lines 113–251 define property-style access for the dropdown capsule
object. Two tables — GetMembers and SetMembers — map string keys
to local getter/setter functions. The __index and __newindex
metamethods on DropDownMetaFunctions check these tables first,
giving the illusion of native Lua fields:

    local v = myDropdown.value     -- __index → GetMembers["value"]()
    myDropdown.width = 200         -- __newindex → SetMembers["width"]()

Keys that are NOT in GetMembers/SetMembers fall through to
rawget/rawset or the DropDownMetaFunctions method table.


=====================================================================
10) __index Metamethod
=====================================================================

Location
    dropdown.lua  lines 175–186

Signature (internal)
    DropDownMetaFunctions.__index = function(object, key)

Lookup order
    1. Check GetMembers[key] — if found, call the getter function
       and return its result.
    2. rawget(object, key) — return the value if it exists directly
       on the capsule table.
    3. Fall through to DropDownMetaFunctions[key] — method lookup
       (e.g. :Select, :Open, :Close, etc.).


=====================================================================
11) GetMembers — Getter Properties
=====================================================================

Location
    dropdown.lua  lines 115–172

Purpose
    Each entry maps a string key to a local function that reads
    a value from the capsule object. These are invoked transparently
    when you read dropdown.KEY via __index.

  ┌──────────┬────────────────────────────┬──────────────────────────┐
  │ Key      │ Getter function            │ What it returns          │
  ├──────────┼────────────────────────────┼──────────────────────────┤
  │ value    │ gmemberValue(object)       │ object:GetValue()        │
  │          │                            │ → rawget(object,"myvalue")│
  ├──────────┼────────────────────────────┼──────────────────────────┤
  │ text     │ gmemberText(object)        │ object.label:GetText()   │
  ├──────────┼────────────────────────────┼──────────────────────────┤
  │ shown    │ gmemberShown(object)       │ object:IsShown()         │
  ├──────────┼────────────────────────────┼──────────────────────────┤
  │ width    │ gmemberWidth(object)       │ object.button:GetWidth() │
  ├──────────┼────────────────────────────┼──────────────────────────┤
  │ height   │ gmemberHeight(object)      │ object.button:GetHeight()│
  ├──────────┼────────────────────────────┼──────────────────────────┤
  │ menuwidth│ gmemberMenuWidth(object)   │ rawget(object,"realsizeW")│
  ├──────────┼────────────────────────────┼──────────────────────────┤
  │menuheight│ gmemberMenuHeight(object)  │ rawget(object,"realsizeH")│
  ├──────────┼────────────────────────────┼──────────────────────────┤
  │ tooltip  │ gmemberTooltip(object)     │ object:GetTooltip()      │
  ├──────────┼────────────────────────────┼──────────────────────────┤
  │ func     │ gmemberFunction(object)    │ object:GetFunction()     │
  │          │                            │ → rawget(object,"func")  │
  └──────────┴────────────────────────────┴──────────────────────────┘

Section details
---------------------------------------------------------------

11a) value
    Location   line 115
    Access     local v = dropdown.value
    Calls      object:GetValue()
    Returns    (any) The value stored when an option was last
               selected. Internally stored in .myvalue via rawset.
               nil if no option has been selected.

11b) tooltip
    Location   line 120
    Access     local tt = dropdown.tooltip
    Calls      object:GetTooltip()  (from TooltipHandlerMixin)
    Returns    The tooltip data previously set with :SetTooltip().

11c) shown
    Location   line 125
    Access     local vis = dropdown.shown
    Calls      object:IsShown()  (from FrameMixin → widget:IsShown())
    Returns    (boolean) Whether the dropdown button frame is visible.

11d) width
    Location   line 130
    Access     local w = dropdown.width
    Calls      object.button:GetWidth()
    Returns    (number) The pixel width of the dropdown button.
    Note       Uses object.button — this refers to the raw Button
               frame (.dropdown / .widget).

11e) height
    Location   line 135
    Access     local h = dropdown.height
    Calls      object.button:GetHeight()
    Returns    (number) The pixel height of the dropdown button.

11f) text
    Location   line 140
    Access     local t = dropdown.text
    Calls      object.label:GetText()
    Returns    (string) The text currently displayed on the button
               face — i.e. the selected option's label.

11g) func
    Location   line 145
    Access     local f = dropdown.func
    Calls      object:GetFunction() → rawget(object, "func")
    Returns    (function) The menu-builder function that returns
               the table of dropdownoption tables.

11h) menuwidth
    Location   line 150
    Access     local mw = dropdown.menuwidth
    Calls      rawget(object, "realsizeW")
    Returns    (number) The width of the open dropdown menu.
               Default 165, adjustable via :SetMenuSize().

11i) menuheight
    Location   line 155
    Access     local mh = dropdown.menuheight
    Calls      rawget(object, "realsizeH")
    Returns    (number) The height of the open dropdown menu.
               Default 300, adjustable via :SetMenuSize().


=====================================================================
12) __newindex Metamethod
=====================================================================

Location
    dropdown.lua  lines 243–251

Signature (internal)
    DropDownMetaFunctions.__newindex = function(object, key, value)

Behavior
    1. Check SetMembers[key] — if found, call the setter function
       with (object, value) and return.
    2. Otherwise rawset(object, key, value) — store directly on
       the capsule table (no interception).


=====================================================================
13) SetMembers — Setter Properties
=====================================================================

Location
    dropdown.lua  lines 191–241

Purpose
    Each entry maps a string key to a local function that writes
    a value into the capsule object. Invoked transparently when
    you write dropdown.KEY = val via __newindex.

  ┌──────────┬────────────────────────────┬──────────────────────────┐
  │ Key      │ Setter function            │ What it does             │
  ├──────────┼────────────────────────────┼──────────────────────────┤
  │ tooltip  │ smemberTooltip(obj, val)   │ obj:SetTooltip(val)      │
  ├──────────┼────────────────────────────┼──────────────────────────┤
  │ show     │ smemberShow(obj, val)      │ if val: Show() else Hide()│
  ├──────────┼────────────────────────────┼──────────────────────────┤
  │ hide     │ smemberHide(obj, val)      │ if val: Hide() else Show()│
  ├──────────┼────────────────────────────┼──────────────────────────┤
  │ width    │ smemberWidth(obj, val)     │ obj.dropdown:SetWidth(val)│
  ├──────────┼────────────────────────────┼──────────────────────────┤
  │ height   │ smemberHeight(obj, val)    │ obj.dropdown:SetHeight(val)│
  ├──────────┼────────────────────────────┼──────────────────────────┤
  │ menuwidth│ smemberMenuWidth(obj, val) │ obj:SetMenuSize(val, nil)│
  ├──────────┼────────────────────────────┼──────────────────────────┤
  │menuheight│ smemberMenuHeight(obj, val)│ obj:SetMenuSize(nil, val)│
  ├──────────┼────────────────────────────┼──────────────────────────┤
  │ func     │ smemberFunction(obj, val)  │ obj:SetFunction(val)     │
  │          │                            │ → rawset(obj,"func",val) │
  └──────────┴────────────────────────────┴──────────────────────────┘

Section details
---------------------------------------------------------------

13a) tooltip
    Location   line 193
    Access     dropdown.tooltip = "Click to pick"
    Calls      object:SetTooltip(value)  (from TooltipHandlerMixin)
    Effect     Stores the tooltip data; shown on mouse enter.

13b) show
    Location   line 198
    Access     dropdown.show = true   -- shows the dropdown
               dropdown.show = false  -- hides the dropdown
    Calls      object:Show() or object:Hide()
    Effect     Toggles visibility. Note the key is "show" (not
               "shown"); writing dropdown.shown = x would rawset
               because "shown" has no setter, only a getter.

13c) hide
    Location   line 207
    Access     dropdown.hide = true   -- hides the dropdown
               dropdown.hide = false  -- shows the dropdown
    Calls      object:Hide() or object:Show()
    Effect     Inverse of "show". Both exist for readability in
               different contexts.

13d) width
    Location   line 216
    Access     dropdown.width = 200
    Calls      object.dropdown:SetWidth(200)
    Effect     Resizes the main button frame's width. This also
               triggers OnSizeChanged which resizes the label.

13e) height
    Location   line 221
    Access     dropdown.height = 30
    Calls      object.dropdown:SetHeight(30)
    Effect     Resizes the main button frame's height.

13f) func
    Location   line 226
    Access     dropdown.func = myNewMenuBuilder
    Calls      object:SetFunction(val) → rawset(object, "func", val)
    Effect     Replaces the menu-builder function. Next time the
               menu opens it calls this new function.

13g) menuwidth
    Location   line 231
    Access     dropdown.menuwidth = 300
    Calls      object:SetMenuSize(300, nil)
    Effect     Changes .realsizeW — the width used when the
               dropdown menu opens.

13h) menuheight
    Location   line 236
    Access     dropdown.menuheight = 400
    Calls      object:SetMenuSize(nil, 400)
    Effect     Changes .realsizeH — the height used when the
               dropdown menu opens.


=====================================================================
14) Getter/Setter Asymmetry Notes
=====================================================================

Not every getter key has a corresponding setter and vice versa.

  Getter-only keys (read-only):
    value      – Use :SetValue(v) or :Select() to change.
    text       – Read-only; set by :Selected() when an option is
                 picked, or by :SetText() on df_dropdown_text.
    shown      – Read-only via property; use .show or .hide to set.

  Setter-only keys (write-only):
    show       – Has no getter in GetMembers. Read .shown instead.
    hide       – Has no getter in GetMembers. Read .shown instead.

  Bidirectional keys (both read and write):
    width, height, menuwidth, menuheight, tooltip, func

  Keys that bypass metamethods:
    Any key not listed in GetMembers or SetMembers goes directly
    through rawget/rawset. This includes all the internal fields
    like .opened, .menus, .myvalue, .FixedValue, .realsizeW, etc.
    Accessing them by dot notation does NOT route through a getter
    or setter — they are plain table fields.

Example
    -- reading
    local w = dropdown.width        -- → gmemberWidth → button:GetWidth()
    local rw = dropdown.realsizeW   -- → rawget (no getter for this key)

    -- writing
    dropdown.width = 200            -- → smemberWidth → dropdown:SetWidth(200)
    dropdown.realsizeW = 200        -- → rawset (no setter for this key)
    -- The two writes above achieve similar effects through different
    -- paths. Using .menuwidth is preferred because it goes through
    -- SetMenuSize() which is the official API.


=====================================================================
Part 3: API Methods (lines 255–713)
=====================================================================


=====================================================================
15) IsText()
=====================================================================

Location
    dropdown.lua  line 255

Signature
    dropdown:IsText()

Purpose
    Returns whether this dropdown is the text-entry variant
    (df_dropdown_text) created by DF:CreateDropDownWithText().

Parameters
    None.

Returns
    (boolean) true if .isText is set, false otherwise.
    Regular dropdowns created with DF:CreateDropDown() do not have
    .isText on their capsule table, so rawget returns nil and this
    method returns false.

Behavior
    return self.isText or false

Example
    if myDropdown:IsText() then
        myDropdown:GetTextEntry():SetText("custom value")
    end


=====================================================================
16) SetMenuSize()
=====================================================================

Location
    dropdown.lua  line 262

Signature
    dropdown:SetMenuSize(width, height)

Purpose
    Sets the width and/or height of the dropdown menu that appears
    when the button is clicked. Either parameter may be nil to leave
    that dimension unchanged.

Parameters
    width   (number?)  New menu width.  Stored as .realsizeW.
    height  (number?)  New menu height. Stored as .realsizeH.

Returns
    Nothing.

Behavior
    Uses rawset to write directly on the capsule table, bypassing
    the __newindex metamethod (avoids infinite recursion since
    the "menuwidth" setter calls this method).

Example
    dropdown:SetMenuSize(300, 500)
    dropdown:SetMenuSize(nil, 400) -- change height only


=====================================================================
17) GetMenuSize()
=====================================================================

Location
    dropdown.lua  line 273

Signature
    dropdown:GetMenuSize()

Purpose
    Returns the current width and height of the dropdown menu.

Parameters
    None.

Returns
    (number, number) .realsizeW, .realsizeH
    Defaults are 165 and 300 (set in DF:NewDropDown).

Example
    local w, h = dropdown:GetMenuSize()


=====================================================================
18) SetFunction()
=====================================================================

Location
    dropdown.lua  line 279

Signature
    dropdown:SetFunction(func)

Purpose
    Replaces the menu-builder function. The next time the dropdown
    opens it will call this new function to obtain the options table.

Parameters
    func  (function)  A function receiving (self) and returning
                      a table of dropdownoption tables.

Returns
    Nothing (rawset return).

Behavior
    rawset(self, "func", func)

Example
    dropdown:SetFunction(function(self)
        return {
            {value = 1, label = "New Option A"},
            {value = 2, label = "New Option B"},
        }
    end)


=====================================================================
19) GetFunction()
=====================================================================

Location
    dropdown.lua  line 283

Signature
    dropdown:GetFunction()

Purpose
    Returns the current menu-builder function.

Parameters
    None.

Returns
    (function) The function stored in .func.

Example
    local builder = dropdown:GetFunction()


=====================================================================
20) GetValue()
=====================================================================

Location
    dropdown.lua  line 289

Signature
    dropdown:GetValue()

Purpose
    Returns the value of the currently selected option.

Parameters
    None.

Returns
    (any) The .myvalue field, or nil if nothing is selected.
    This is the .value field from the dropdownoption table that
    was last selected.

Example
    local selectedId = dropdown:GetValue()


=====================================================================
21) SetValue()
=====================================================================

Location
    dropdown.lua  line 293

Signature
    dropdown:SetValue(value)

Purpose
    Manually overrides the stored selected value without changing
    the visual state of the button (label, icon, etc.). This does
    NOT trigger callbacks or update the button face. To visually
    select an option, use :Select() instead.

Parameters
    value  (any)  The value to store.

Returns
    Nothing (rawset return).

Example
    dropdown:SetValue(42)


=====================================================================
22) SetFrameLevel()
=====================================================================

Location
    dropdown.lua  line 299

Signature
    dropdown:SetFrameLevel(level, frame)

Purpose
    Sets the frame level of the dropdown's button frame, optionally
    relative to another frame.

Parameters
    level  (number)  The frame level, or the offset if frame is given.
    frame  (frame?)  If provided, the final level is
                     frame:GetFrameLevel() + level.

Returns
    Nothing.

Behavior
    Without frame: self.dropdown:SetFrameLevel(level)
    With frame:    self.dropdown:SetFrameLevel(
                       frame:GetFrameLevel() + level)

Example
    dropdown:SetFrameLevel(5)
    dropdown:SetFrameLevel(3, UIParent) -- UIParent level + 3


=====================================================================
23) IsEnabled()
=====================================================================

Location
    dropdown.lua  line 311

Signature
    dropdown:IsEnabled()

Purpose
    Returns whether the dropdown is currently enabled (clickable).

Parameters
    None.

Returns
    (boolean) Delegates to the raw button's :IsEnabled().

Example
    if dropdown:IsEnabled() then
        dropdown:Open()
    end


=====================================================================
24) Enable()
=====================================================================

Location
    dropdown.lua  line 316

Signature
    dropdown:Enable()

Purpose
    Re-enables the dropdown after it was disabled.

Parameters
    None.

Returns
    Nothing.

Behavior
    1. Sets alpha to 1 (fully opaque).
    2. rawset .lockdown = false (allows OnMouseDown to open menu).
    3. If this is a text dropdown (:IsText()), also enables the
       TextEntry widget.
    4. Calls self.OnEnable(self) if the callback exists.

Example
    dropdown:Enable()


=====================================================================
25) Disable()
=====================================================================

Location
    dropdown.lua  line 329

Signature
    dropdown:Disable()

Purpose
    Disables the dropdown so it cannot be opened.

Parameters
    None.

Returns
    Nothing.

Behavior
    1. Sets alpha to 0.4 (dimmed / grayed out).
    2. rawset .lockdown = true (prevents OnMouseDown from opening).
    3. If this is a text dropdown (:IsText()), also disables the
       TextEntry widget.
    4. Calls self.OnDisable(self) if the callback exists.

Note
    The .lockdown field is checked in DetailsFrameworkDropDownOnMouseDown
    as the first guard: if (not object.opened and not rawget(object, "lockdown")).

Example
    dropdown:Disable()


=====================================================================
26) SetFixedParameter()
=====================================================================

Location
    dropdown.lua  line 343

Signature
    dropdown:SetFixedParameter(value)

Purpose
    Sets a fixed value that is sent as the second argument to
    every option's onclick callback, regardless of which option
    is selected. Useful for passing context when multiple dropdowns
    share the same callback function.

Parameters
    value  (any)  The fixed parameter. nil is valid.

Returns
    Nothing.

Behavior
    rawset(self, "FixedValue", value)

Callback signature reminder
    onclick(dropdownObject, fixedValue, optionValue)

Example
    dropdown:SetFixedParameter("damage_settings")


=====================================================================
27) GetFixedParameter()
=====================================================================

Location
    dropdown.lua  line 347

Signature
    dropdown:GetFixedParameter()

Purpose
    Returns the fixed parameter previously set.

Parameters
    None.

Returns
    (any) The .FixedValue field.

Example
    local ctx = dropdown:GetFixedParameter()


=====================================================================
28) isOptionVisible() — Local Helper
=====================================================================

Location
    dropdown.lua  lines 353–363

Signature (local)
    isOptionVisible(self, thisOption)

Purpose
    Determines whether a single dropdownoption should be displayed.
    Used internally by Select() and DetailsFrameworkDropDownOnMouseDown
    when building/filtering the option list.

Parameters
    self        (table)           The dropdown capsule (unused in
                                  the body except by DF:Dispatch).
    thisOption  (dropdownoption)  The option table to check.

Returns
    (boolean) Whether the option is visible.

Behavior
    - If thisOption.shown is a boolean, return it directly.
    - If thisOption.shown is a function, call it via DF:Dispatch
      passing self (the dropdown), return the result.
    - If thisOption.shown is nil or any other type, return true
      (default: visible).


=====================================================================
29) GetMenuFrames()
=====================================================================

Location
    dropdown.lua  line 367

Signature
    dropdown:GetMenuFrames()

Purpose
    Returns the table of cached option row frames (Button objects)
    that have been created so far. These are the frames in the open
    menu, built on-demand by CreateDropdownButton().

Parameters
    None.

Returns
    (table) The .menus array. Indices correspond to visible option
    rows in creation order. Some trailing frames may be hidden if
    fewer options exist than were created in a prior opening.

Note
    The source comments this method as "not tested."

Example
    local frames = dropdown:GetMenuFrames()
    for i, frame in ipairs(frames) do
        print(frame:GetName(), frame:IsShown())
    end


=====================================================================
30) GetFrameForOption()
=====================================================================

Location
    dropdown.lua  line 375

Signature
    dropdown:GetFrameForOption(optionsTable, value)

Purpose
    Returns the option row frame corresponding to a specific option,
    looked up by value/label string or numeric index.

Parameters
    optionsTable  (table)         The table of dropdownoption tables
                                  (as returned by the menu-builder).
    value         (string|number) If string: matched against
                                  .value or .label of each option.
                                  If number: direct index into
                                  .menus[].

Returns
    (Button|nil) The option row frame, or nil if not found.

Note
    The source comments this method as "not tested."

Example
    local opts = dropdown:GetFunction()(dropdown)
    local frame = dropdown:GetFrameForOption(opts, "Option A")


=====================================================================
31) Refresh()
=====================================================================

Location
    dropdown.lua  line 393

Signature
    dropdown:Refresh()

Purpose
    Re-calls the menu-builder function to check if valid options
    exist. Does NOT rebuild or re-render the open menu — that
    happens in OnMouseDown. This method is primarily used to
    validate that the dropdown has valid options and update the
    no-options state.

Parameters
    None.

Returns
    (boolean) false if the options table is empty (enters "no
    options" state), true otherwise.

Behavior
    1. Asserts that self.func is a function.
    2. Calls self.func(self) via xpcall.
    3. If the table is empty → NoOption(true), returns false.
    4. If previously empty but now has options → NoOption(false),
       NoOptionSelected(), returns true.
    5. Otherwise returns true.

Example
    if not dropdown:Refresh() then
        print("Dropdown has no options")
    end


=====================================================================
32) NoOptionSelected() — Internal
=====================================================================

Location
    dropdown.lua  line 412

Signature
    dropdown:NoOptionSelected()

Purpose
    Resets the button face to the "no option selected" state:
    default text, default icon, dimmed colors. Called internally
    when Select() cannot find a matching option.

Parameters
    None.

Returns
    Nothing.

Behavior
    - If .no_options is true, does nothing (defers to NoOption).
    - Sets label to .empty_text or "no option selected" at 40% alpha.
    - Sets icon to .empty_icon or the default ModelControlPanel icon
      with specific texcoords, at 40% alpha.
    - Clears .last_select = nil.


=====================================================================
33) NoOption() — Internal
=====================================================================

Location
    dropdown.lua  line 431

Signature
    dropdown:NoOption(state)

Purpose
    Enters or exits the "no options available" state. When active
    the dropdown is disabled and shows a warning icon with
    "no options" text.

Parameters
    state  (boolean)  true = enter no-options state,
                      false = exit no-options state.

Returns
    Nothing.

Behavior
    state = true:
        - Calls :Disable(), :SetAlpha(0.5)
        - Sets .no_options = true
        - Sets label to "no options", icon to
          UI-Player-PlayTimeUnhealthy, all at 40% alpha.
    state = false:
        - Sets .no_options = false
        - Calls :Enable(), :SetAlpha(1)


=====================================================================
34) runCallbackFunctionForButton() — Local Helper
=====================================================================

Location
    dropdown.lua  line 449

Signature (local)
    runCallbackFunctionForButton(button)

Purpose
    Executes the onclick callback for an option row when the user
    clicks it. Also fires the OnOptionSelected hook.

Parameters
    button  (Button)  The option row frame. Must have:
                      .table = the dropdownoption table
                      .object = the dropdown capsule (via .FixedValue)

Behavior
    If button.table.onclick exists:
      1. xpcall(onclick, handler, dropdownObject, fixedValue, value)
      2. RunHooksForWidget("OnOptionSelected", ..., fixedValue, value)

    The dropdownObject is obtained by traversing the frame hierarchy:
      button → scrollChild → scrollFrame → main button → .MyObject

Callback signature
    onclick(dropdownObject, fixedValue, optionValue)


=====================================================================
35) canRunCallbackFunctionForOption() — Local Helper
=====================================================================

Location
    dropdown.lua  line 460

Signature (local)
    canRunCallbackFunctionForOption(canRunCallback, optionTable,
                                    dropdownObject)

Purpose
    Conditionally runs an option's onclick callback. Used by
    Select() when the runCallback parameter is true.

Parameters
    canRunCallback   (boolean)        Whether to actually run.
    optionTable      (dropdownoption) The selected option.
    dropdownObject   (df_dropdown)    The capsule.

Behavior
    If canRunCallback is truthy and optionTable.onclick exists:
      1. Gets fixedValue via rawget(dropdownObject, "FixedValue").
      2. xpcall(onclick, handler, dropdownObject, fixedValue, value).
      3. RunHooksForWidget("OnOptionSelected", ...).


=====================================================================
36) SelectDelayed()
=====================================================================

Location
    dropdown.lua  line 477

Signature
    dropdown:SelectDelayed(optionName, byOptionNumber,
                           bOnlyShown, runCallback)

Purpose
    Calls :Select() after a short random delay (16ms–300ms). Useful
    to avoid re-entrance issues when selecting from within a
    callback.

Parameters
    Same as :Select() (see section 37).

Returns
    Nothing (fires asynchronously).

Behavior
    DF.Schedules.After(randomDelay, function()
        self:Select(optionName, byOptionNumber, bOnlyShown, runCallback)
    end)

Example
    dropdown:SelectDelayed("Option B", false, false, true)


=====================================================================
37) Select()
=====================================================================

Location
    dropdown.lua  line 488

Signature
    dropdown:Select(optionName, byOptionNumber, bOnlyShown,
                    runCallback)

Purpose
    Programmatically selects an option, updating the button face
    and optionally firing the onclick callback. This is the
    primary method for setting the dropdown's selection from code.

Parameters
    optionName      (string|number|boolean)
        If string: matched against .label or .value of each option.
        If number (with byOptionNumber=true): used as an index.
        If false (boolean): clears selection → NoOptionSelected().

    byOptionNumber  (boolean?)
        If true, optionName is treated as a numeric index into the
        options table rather than a label/value match.

    bOnlyShown      (boolean?)
        Only meaningful when byOptionNumber is true. If true, builds
        a filtered list of only visible options (those whose .shown
        is true or returns true) and indexes into THAT list.

    runCallback     (boolean?)
        If true, fires the selected option's .onclick callback
        after selecting (via canRunCallbackFunctionForOption).

Returns
    (boolean) true if an option was successfully selected,
              false if no matching option was found.

Behavior
    1. If optionName is false → NoOptionSelected(), return false.
    2. Calls self.func(self) via xpcall to get the options table.
    3. If options table is empty → NoOption(true), return true.
    4. By number (byOptionNumber=true, optionName is number):
       a. If bOnlyShown: filters options to visible-only, then
          indexes the filtered list.
       b. Else: indexes optionsTable directly.
       c. If index is out of range → NoOptionSelected(), return false.
       d. Calls :Selected(optionTable), optionally runs callback.
    5. By name/value (default path):
       Iterates all options, finds first where .label == optionName
       OR .value == optionName AND isOptionVisible() is true.
       Calls :Selected(optionTable), optionally runs callback.
    6. If no match found → return false (does NOT clear selection).

Example
    -- Select by label string
    dropdown:Select("Fire Mage")

    -- Select by value
    dropdown:Select(63)  -- matches option where .value == 63

    -- Select 3rd option by index
    dropdown:Select(3, true)

    -- Select 2nd visible option, also trigger callback
    dropdown:Select(2, true, true, true)

    -- Clear selection
    dropdown:Select(false)


=====================================================================
38) SetEmptyTextAndIcon()
=====================================================================

Location
    dropdown.lua  line 573

Signature
    dropdown:SetEmptyTextAndIcon(text, icon)

Purpose
    Customizes the text and icon displayed when no option is
    selected or when the options table is empty.

Parameters
    text  (string?)         Replacement for "no option selected".
                            Stored in .empty_text.
    icon  (string|number?)  Replacement for the default
                            ModelControlPanel icon.
                            Stored in .empty_icon.

Returns
    Nothing.

Behavior
    Saves .empty_text and/or .empty_icon, then calls
    :Selected(self.last_select) to re-render the button.
    If nothing was selected, this re-render will pick up
    the new empty text/icon via NoOptionSelected().

Example
    dropdown:SetEmptyTextAndIcon("Pick a spell", spellIconId)


=====================================================================
39) UseSimpleHeader()
=====================================================================

Location
    dropdown.lua  line 585

Signature
    dropdown:UseSimpleHeader(value)

Purpose
    When enabled, the button face ignores per-option color, font,
    and statusbar customization from the selected option. The label
    stays white with the default font and no statusbar coloring.

Parameters
    value  (boolean)  true to enable, false to disable.

Returns
    Nothing.

Behavior
    Sets self.isSimpleHeader = value. This flag is checked in
    :Selected() at lines where it applies statusbar, color, and
    font from the option table:
      - if thisOption.statusbar and not self.isSimpleHeader
      - if thisOption.color and not self.isSimpleHeader
      - if thisOption.font and not self.isSimpleHeader

Example
    dropdown:UseSimpleHeader(true)


=====================================================================
40) Selected() — Internal Renderer
=====================================================================

Location
    dropdown.lua  line 590

Signature
    dropdown:Selected(thisOption)

Purpose
    Updates the button face (label, icon, statusbar, colors, font,
    textures) to reflect a given option table. This is the core
    rendering method called by :Select(), DetailsFrameworkDropDownOptionClick,
    and internally after option selection.

Parameters
    thisOption  (dropdownoption|nil)  The option to render.
                If nil, calls :Refresh() and falls back to
                NoOptionSelected().

Returns
    Nothing.

Behavior
    If thisOption is nil:
        - Calls :Refresh(). If that returns false, clears
          .last_select and returns.
        - Otherwise calls :NoOptionSelected() and returns.

    If thisOption is provided:
        1. Stores .last_select = thisOption.
        2. Calls :NoOption(false) to exit any no-options state.
        3. Font/language:
           - If .addonId exists, looks up language font via
             DF.Language; stores override font if language changed.
           - If .addonId and .phraseId, sets label to
             DF.Language.GetText(addonId, phraseId).
           - Otherwise sets label to thisOption.label, disables
             word wrap, truncates to button width – 30.
        4. Icon:
           - Sets icon texture to thisOption.icon.
           - If icon exists: positions label to right of icon,
             applies .texcoord (default 0,1,0,1), .iconcolor
             (default white), .iconsize (default height – 4).
           - If no icon: label anchored to parent left + 4.
        5. Center/right textures:
           - Sets centerTexture and rightTexture from option,
             or clears them.
        6. Statusbar (unless .isSimpleHeader):
           - Sets texture and vertex color from .statusbar /
             .statusbarcolor. Clears if not present.
           - If .__rcorners, insets statusbar by 2px.
        7. Text color (unless .isSimpleHeader):
           - Applies .color via DF:ParseColors, default white.
        8. Font (unless .isSimpleHeader):
           - Uses override font, or .font, or
             GameFontHighlightSmall at size 10.
        9. Calls :SetValue(thisOption.value).


=====================================================================
41) DetailsFrameworkDropDownOptionClick() — Global Handler
=====================================================================

Location
    dropdown.lua  line 716

Signature (global)
    DetailsFrameworkDropDownOptionClick(button)

Purpose
    Script handler for OnMouseDown on option row frames. Fired
    when the user clicks an option in the open dropdown menu.

Parameters
    button  (Button)  The option row frame. Has:
                      .object = dropdown capsule
                      .table  = dropdownoption table for this row

Behavior
    1. button.object:Selected(button.table)
       Updates the button face.
    2. button.object:Close()
       Closes the dropdown menu.
    3. runCallbackFunctionForButton(button)
       Fires the onclick callback and OnOptionSelected hooks.
    4. Stores button.object.myvalue = button.table.value
       and button.object.myvaluelabel = button.table.label.


=====================================================================
Part 4: Menu Control, Script Handlers & Font List (lines 715–1158)
=====================================================================


=====================================================================
42) Open()
=====================================================================

Location
    dropdown.lua  line 732

Signature
    dropdown:Open()

Purpose
    Shows the dropdown menu (scroll frame + border frame) and
    marks the dropdown as opened.

Parameters
    None.

Returns
    Nothing.

Behavior
    1. Shows self.dropdown.dropdownframe (the ScrollFrame).
    2. Shows self.dropdown.dropdownborder (the border Frame).
    3. Sets self.opened = true.
    4. If another dropdown was previously opened (tracked in the
       file-local `lastOpened`), calls lastOpened:Close() first.
       This ensures only one dropdown menu is open at a time.
    5. Sets lastOpened = self.

Note
    This method only shows the already-populated frames. The actual
    option rows are built by DetailsFrameworkDropDownOnMouseDown
    before calling :Open().


=====================================================================
43) IsOpen()
=====================================================================

Location
    dropdown.lua  line 743

Signature
    dropdown:IsOpen()

Purpose
    Returns whether the dropdown menu is currently open.

Parameters
    None.

Returns
    (boolean) true if .opened is true OR the border frame is shown.
    The OR handles edge cases where the flag and frame visibility
    get out of sync.


=====================================================================
44) Close()
=====================================================================

Location
    dropdown.lua  line 748

Signature
    dropdown:Close()

Purpose
    Closes the dropdown menu: hides the border and scroll frames,
    hides the selected-highlight texture, and resets the opened
    flag.

Parameters
    None.

Returns
    Nothing.

Behavior
    1. If the border frame is still shown, hides it and returns.
       (The border's OnHide script will call Close() again to
       finish cleanup — two-phase close.)
    2. Hides the scroll frame (dropdownframe).
    3. Hides the selected texture in the scroll child.
    4. Sets self.opened = false.
    5. Clears lastOpened = false.

Note
    The two-phase approach means that both Escape-key closure
    (via UISpecialFrames hiding the border) and programmatic
    Close() converge on the same cleanup path.


=====================================================================
45) DetailsFrameworkDropDownOptionsFrameOnHide()
=====================================================================

Location
    dropdown.lua  line 764

Signature (global)
    DetailsFrameworkDropDownOptionsFrameOnHide(self)

Purpose
    OnHide handler for the border frame. Called when the border
    is hidden (e.g. by Escape via UISpecialFrames, or by Close()).

Parameters
    self  (frame)  The border frame ("name_Border").

Behavior
    Calls self:GetParent().MyObject:Close() — delegates to the
    capsule's Close() method for the rest of cleanup.


=====================================================================
46) DetailsFrameworkDropDownOptionOnEnter()
=====================================================================

Location
    dropdown.lua  line 769

Signature (global)
    DetailsFrameworkDropDownOptionOnEnter(self)

Purpose
    OnEnter handler for option row frames in the open menu.
    Positions the mouseover highlight and optionally shows a
    tooltip and plays an audio cue.

Parameters
    self  (Button)  The option row frame. Has .table = the
                    dropdownoption for this row.

Behavior
    1. If self.table.desc exists:
       a. Configures GameCooltip2 (Preset 2).
       b. If .addonId exists, uses DF.Language.GetText for text.
       c. Otherwise uses .desc directly as tooltip text.
       d. If .descfont, sets GameCooltip2 TextFont option.
       e. If .tooltipwidth, sets GameCooltip2 FixedWidth option.
       f. Shows GameCooltip2 anchored to the right of the row.
       g. Sets self.tooltip = true.

    2. If self.table.audiocue exists:
       a. Stops any currently playing sound (DF.CurrentSoundHandle).
       b. Plays the audio file via PlaySoundFile on "Master" channel.
       c. Stores the new sound handle in DF.CurrentSoundHandle.

    3. Positions the mouseover highlight texture at this row:
       self:GetParent().mouseover:SetPoint("left", self)
       self:GetParent().mouseover:Show()

Additional dropdownoption fields used here
    .desc           (string|number)  Tooltip text (or phraseId
                                     if .addonId is set).
    .descfont       (string?)        Font for the tooltip text.
    .tooltipwidth   (number?)        Fixed width for the tooltip.
    .audiocue       (string?)        Sound file path to preview.


=====================================================================
47) DetailsFrameworkDropDownOptionOnLeave()
=====================================================================

Location
    dropdown.lua  line 810

Signature (global)
    DetailsFrameworkDropDownOptionOnLeave(frame)

Purpose
    OnLeave handler for option row frames.

Parameters
    frame  (Button)  The option row frame.

Behavior
    1. If frame.table.desc exists, hides GameCooltip2.
    2. Hides the mouseover highlight:
       frame:GetParent().mouseover:Hide()


=====================================================================
48) DetailsFrameworkDropDownOnMouseDown() — Main Menu Builder
=====================================================================

Location
    dropdown.lua  line 821

Signature (global)
    DetailsFrameworkDropDownOnMouseDown(button, buttontype)

Purpose
    The primary interaction handler. When the user clicks the
    dropdown button this function either builds and opens the menu
    or closes an already-open menu.

Parameters
    button      (Button)  The raw dropdown button frame (.dropdown).
    buttontype  (string)  Mouse button identifier ("LeftButton", etc.).

Returns
    Nothing.

Behavior — Close path
    If object.opened is true OR object.lockdown is true:
        Calls object:Close() and returns.

Behavior — Open path (main flow)
    1. Calls object.func(object) via DF:Dispatch to get optionsTable.
       Stores result in object.builtMenu.
    2. Initializes frameWitdh = object.realsizeW.
    3. If optionsTable is empty or nil → does nothing (clear menu).
    4. Resolves child frames by global name:
       scrollFrame, scrollChild, scrollBorder, selectedTexture,
       mouseOverTexture.
    5. If object.OnMouseDownHook exists, calls it with
       (button, buttontype, optionsTable, scrollFrame, scrollChild,
       selectedTexture). If it returns truthy → aborts (interrupt).

    6. Iterates optionsTable:
       For each visible option (isOptionVisible check):

       a. Frame creation (lazy):
          If object.menus[i] doesn't exist yet, creates a new
          option row via DF:CreateDropdownButton(scrollChild, name).
          Positions it at topleft offset (1, -(index * 20)).
          Stores .object = capsule on the row frame.
          Fires object.OnCreateOptionFrame callback if set.

       b. Sets frame strata and level (+10 above parent).

       c. Populates row widgets from the dropdownoption table:
          - rightTexture, centerTexture (set or clear)
          - icon: texture, texcoord, iconcolor, iconsize
          - label position: right of icon if icon, else left of
            statusbar
          - statusbar: texture and color
          - rightbutton: dispatches callback to set up the
            rightButton widget, or hides it
          - Font/language: detects or uses .languageId, falls back
            to GameFontHighlightSmall at 10.5pt
          - Label text: sets .label
          - Text color: applies .color to all fontstrings on the row

       d. Selected highlight:
          If the row's label matches the current button text,
          positions and shows the selectedTexture (yellow bar).
          Records currentIndex for scroll positioning.

       e. Auto-width:
          Measures label string width; if label + 40 > frameWitdh,
          expands frameWitdh.

       f. Shows the row frame.
       g. Fires object.OnUpdateOptionFrame callback if set.

    7. Hides surplus cached rows (showing+1 .. #object.menus).

    8. Scroll/sizing logic:
       If (showing * 20) > object.realsizeH → scrollbar needed:
         - Shows scroll bar, enables mouse wheel.
         - Sets scroll range: 0 to (showing * 20 – size + 2).
         - Sizes border/scroll/child to frameWitdh + 20 (room for
           scrollbar).
         - Border/scroll height = realsizeH + 2.
         - Child height = (showing * 20) + 20.
         - Row topright offset = –22 (scrollbar clearance).
         - mouseOver/selected width = frameWitdh – 7 / – 9.

       Else → no scrollbar:
         - Hides scroll bar, disables mouse wheel.
         - Sizes border/scroll/child to frameWitdh.
         - Border/scroll height = (showing * 20) + 1.
         - Row topright offset = –5.
         - mouseOver/selected width = frameWitdh – 1.

    9. Scroll position:
       If a selected option exists and scrollbar is shown,
       scrolls to roughly center the selection:
         scroll:SetValue(max((currentIndex * 20) – 80, 0)).
       Otherwise scrolls to 0.

    10. Calls object:Open().

Hooks/callbacks referenced
    object.OnMouseDownHook(button, buttontype, optionsTable,
                           scrollFrame, scrollChild, selectedTexture)
        Return truthy to interrupt menu opening.

    object.OnCreateOptionFrame(dropdown, optionFrame, optionTable)
        Called once per new option frame creation.

    object.OnUpdateOptionFrame(dropdown, optionFrame, optionTable)
        Called every time an option frame is updated/shown.


=====================================================================
49) DetailsFrameworkDropDownOnEnter()
=====================================================================

Location
    dropdown.lua  line 1107

Signature (global)
    DetailsFrameworkDropDownOnEnter(self)

Purpose
    OnEnter handler for the main dropdown button frame (not the
    option rows). Highlights the button and shows the tooltip.

Parameters
    self  (Button)  The raw dropdown button frame.

Behavior
    1. Fires OnEnter hooks via RunHooksForWidget. If any return
       truthy → abort.
    2. Sets backdrop color:
       - If .onenter_backdrop exists on capsule → use that color.
       - Otherwise default (0.2, 0.2, 0.2, 0.2).
    3. If .onenter_backdrop_border_color exists → apply it.
    4. Shows arrowTexture2 (the ADD-blend highlight arrow).
    5. Calls object:ShowTooltip() (from TooltipHandlerMixin).

Customizable fields on the capsule
    .onenter_backdrop              (table?) {r, g, b, a}
    .onenter_backdrop_border_color (table?) {r, g, b, a}


=====================================================================
50) DetailsFrameworkDropDownOnLeave()
=====================================================================

Location
    dropdown.lua  line 1125

Signature (global)
    DetailsFrameworkDropDownOnLeave(self)

Purpose
    OnLeave handler for the main dropdown button frame.

Parameters
    self  (Button)  The raw dropdown button frame.

Behavior
    1. Fires OnLeave hooks. If any return truthy → abort.
    2. Restores backdrop color:
       - If .onleave_backdrop exists → use it.
       - Otherwise default (1, 1, 1, 0.5).
    3. If .onleave_backdrop_border_color exists → apply it.
    4. Hides arrowTexture2.
    5. Calls object:HideTooltip().

Customizable fields on the capsule
    .onleave_backdrop              (table?) {r, g, b, a}
    .onleave_backdrop_border_color (table?) {r, g, b, a}


=====================================================================
51) DetailsFrameworkDropDownOnSizeChanged()
=====================================================================

Location
    dropdown.lua  line 1145

Signature (global)
    DetailsFrameworkDropDownOnSizeChanged(self)

Purpose
    OnSizeChanged handler for the main button. Keeps the label
    fontstring width in sync with the button width.

Parameters
    self  (Button)  The raw dropdown button frame.

Behavior
    object.label:SetSize(self:GetWidth() – 40, 10)


=====================================================================
52) DetailsFrameworkDropDownOnShow()
=====================================================================

Location
    dropdown.lua  line 1150

Signature (global)
    DetailsFrameworkDropDownOnShow(self)

Purpose
    OnShow handler for the main button frame.

Parameters
    self  (Button)  The raw dropdown button frame.

Behavior
    Fires OnShow hooks via RunHooksForWidget. If any return
    truthy → abort (prevents default behavior, though there is
    none beyond the hook dispatch).


=====================================================================
53) DetailsFrameworkDropDownOnHide()
=====================================================================

Location
    dropdown.lua  line 1157

Signature (global)
    DetailsFrameworkDropDownOnHide(self)

Purpose
    OnHide handler for the main button frame.

Parameters
    self  (Button)  The raw dropdown button frame.

Behavior
    1. Fires OnHide hooks via RunHooksForWidget. If any return
       truthy → abort.
    2. Calls object:Close() — ensures the menu is closed when
       the dropdown button itself is hidden.


=====================================================================
Part 5: Template, List Generators & Pre-Built Dropdowns
        (lines 1158–1594)
=====================================================================


=====================================================================
54) DF:BuildDropDownFontList()
=====================================================================

Location
    dropdown.lua  line 1161

Signature
    DF:BuildDropDownFontList(onClick, icon, iconTexcoord,
                             iconSize, bIncludeDefault)

Purpose
    Builds and returns a table of dropdownoption entries — one per
    font registered in LibSharedMedia-3.0.  Each option uses the
    font's own path so the label is rendered in that font, and
    sets .descfont = "abcdefg ABCDEFG" for a preview tooltip.

Parameters
    onClick         (function)   onclick callback for every option.
    icon            (any?)       Texture shown on each option.
    iconTexcoord    (table?)     {l, r, t, b} for the icon.
    iconSize        (number?)    Icon size (square). Default {16,16}.
    bIncludeDefault (boolean?)   If true, prepends a "DEFAULT" entry
                                 with an empty font path.

Returns
    (dropdownoption[]) Sorted alphabetically by label.

Example
    local fontOptions = DF:BuildDropDownFontList(
        myCallback,
        [[Interface\AnimCreate\AnimCreateIcons]],
        {0, 0.25, 0.5, 0.75},
        16
    )


=====================================================================
55) SetTemplate()
=====================================================================

Location
    dropdown.lua  line 1189

Signature
    dropdown:SetTemplate(template)

Purpose
    Applies a visual template to the dropdown. Templates control
    backdrop, border, colors, hover effects, and the drop-arrow
    icon.

Parameters
    template  (table|string)  A template table or a template name
              resolved by DF:ParseTemplate("dropdown", template).

Returns
    Nothing.

Behavior
    1. Resolves template via DF:ParseTemplate(self.type, template).
    2. Stores self.template = template.
    3. Applies dimensional overrides:
       - template.width  → PixelUtil.SetWidth
       - template.height → PixelUtil.SetHeight
    4. Applies backdrop:
       - template.backdrop → self:SetBackdrop()
    5. Applies colors — each parsed via DF:ParseColors():
       - template.backdropcolor → SetBackdropColor + .onleave_backdrop
       - template.backdropbordercolor → SetBackdropBorderColor
         + .onleave_backdrop_border_color
       - template.onentercolor → .onenter_backdrop
       - template.onleavecolor → .onleave_backdrop
       - template.onenterbordercolor → .onenter_backdrop_border_color
       - template.onleavebordercolor → .onleave_backdrop_border_color
    6. Calls :RefreshDropIcon().

Template table fields
    .width                (number?)   Override button width.
    .height               (number?)   Override button height.
    .backdrop             (table?)    Backdrop table.
    .backdropcolor        (any?)      Resting backdrop color.
    .backdropbordercolor  (any?)      Resting border color.
    .onentercolor         (any?)      Backdrop color on mouse enter.
    .onleavecolor         (any?)      Backdrop color on mouse leave.
    .onenterbordercolor   (any?)      Border color on mouse enter.
    .onleavebordercolor   (any?)      Border color on mouse leave.
    .dropicon             (string?)   Texture for the drop arrow.
    .dropiconsize         (table?)    {w, h} for the drop arrow.
    .dropiconcoords       (table?)    {l, r, t, b} for the arrow.
    .dropiconpoints       (table?)    {x, y} offset for the arrow
                                      anchor (right of button).

Example
    dropdown:SetTemplate(DF:GetTemplate("dropdown",
        "OPTIONS_DROPDOWN_TEMPLATE"))


=====================================================================
56) RefreshDropIcon()
=====================================================================

Location
    dropdown.lua  line 1237

Signature
    dropdown:RefreshDropIcon()

Purpose
    Re-applies the drop-arrow icon settings from the stored
    template. Called automatically at the end of SetTemplate().

Parameters
    None.

Returns
    Nothing.

Behavior
    If self.template is nil, returns immediately. Otherwise:
    - .dropicon: sets texture on both arrowTexture and arrowTexture2.
    - .dropiconsize: resizes both arrows.
    - .dropiconcoords: sets texcoords on arrowTexture
      (default 0,1,0,1 if absent).
    - .dropiconpoints: clears and re-anchors both arrows to
      ("right", dropdown, "right", x, y).


=====================================================================
57) DF:CreateFontListGenerator()
=====================================================================

Location
    dropdown.lua  line 1270

Signature
    DF:CreateFontListGenerator(callback, bIncludeDefault)

Purpose
    Returns a menu-builder function (suitable for the `func`
    parameter of CreateDropDown) that builds a font list from
    LibSharedMedia when called.

Parameters
    callback        (function)   onclick callback for every option.
    bIncludeDefault (boolean?)   Prepend "DEFAULT" entry.

Returns
    (function) A closure that calls DF:BuildDropDownFontList()
    with a fixed icon (AnimCreateIcons), texcoords, and size 16.


=====================================================================
58) DF:CreateColorListGenerator()
=====================================================================

Location
    dropdown.lua  line 1278

Signature
    DF:CreateColorListGenerator(callback)

Purpose
    Returns a menu-builder function that lists named colors from
    DF:GetDefaultColorList(). Each option has the color applied to
    both label text (.color) and a statusbar background.

Parameters
    callback  (function)  onclick callback for every option.

Returns
    (function) A closure returning dropdownoption[].

Option structure
    Each option: value = colorTable, label = colorName,
    color = colorTable, statusbar = UI-Tooltip-Background,
    statusbarcolor = {0.1, 0.1, 0.1, 0.8}.
    First entry is always "no color" / value = "blank".


=====================================================================
59) DF:CreateOutlineListGenerator()
=====================================================================

Location
    dropdown.lua  line 1313

Signature
    DF:CreateOutlineListGenerator(callback)

Purpose
    Returns a menu-builder function listing font outline flags
    from DF.FontOutlineFlags.

Parameters
    callback  (function)  onclick callback.

Returns
    (function) Closure returning dropdownoption[].

Option structure
    value = outline flag string (e.g. "OUTLINE"),
    label = human-readable name.


=====================================================================
60) DF:CreateAnchorPointListGenerator()
=====================================================================

Location
    dropdown.lua  line 1333

Signature
    DF:CreateAnchorPointListGenerator(callback)

Purpose
    Returns a menu-builder function listing WoW anchor points
    from DF.AnchorPoints (e.g. "TOPLEFT", "CENTER", etc.).

Parameters
    callback  (function)  onclick callback.

Returns
    (function) Closure returning dropdownoption[].

Option structure
    value = numeric index, label = anchor point name.


=====================================================================
61) DF:CreateRaidInstanceListGenerator()
=====================================================================

Location
    dropdown.lua  line 1351

Signature
    DF:CreateRaidInstanceListGenerator(callback)

Purpose
    Returns a menu-builder function listing all current raid
    instances from the Encounter Journal (DF.Ejc).

Parameters
    callback  (function)  onclick callback.

Returns
    (function) Closure returning dropdownoption[].

Option structure
    value = journalInstanceId, label = instance name,
    icon = instance icon, texcoord = icon coordinates.

Note
    The instance list is captured at generator creation time
    (not on each call), so it reflects the instances available
    when the generator was created.


=====================================================================
62) DF:CreateBossListGenerator()
=====================================================================

Location
    dropdown.lua  line 1374

Signature
    DF:CreateBossListGenerator(callback, instanceId)

Purpose
    Returns a menu-builder function listing all encounters for
    a specific raid instance.

Parameters
    callback    (function)  onclick callback.
    instanceId  (number)    The journalInstanceId.

Returns
    (function) Closure returning dropdownoption[].
    Returns an empty-table function if no encounters found.

Option structure
    value = journalEncounterId, label = encounter name,
    icon = creature icon, texcoord = creature icon coords.


=====================================================================
63) DF:CreateAudioListGenerator()
=====================================================================

Location
    dropdown.lua  line 1399

Signature
    DF:CreateAudioListGenerator(callback)

Purpose
    Returns a menu-builder function listing all sound files
    registered in LibSharedMedia-3.0 ("sound" type). Includes
    a "--x--x--" entry at the top for "no sound".

Parameters
    callback  (function)  onclick callback.

Returns
    (function) Closure returning dropdownoption[].

Option structure
    value = audio file path, label = audio name.
    Sorted alphabetically. First entry has value = "".

Note
    Each call rebuilds DF.AudioCues from SharedMedia, so newly
    registered sounds are picked up dynamically.


=====================================================================
64) DF:CreateStatusbarTextureListGenerator()
=====================================================================

Location
    dropdown.lua  line 1438

Signature
    DF:CreateStatusbarTextureListGenerator(callback)

Purpose
    Returns a menu-builder function listing all statusbar textures
    from LibSharedMedia-3.0. Each option previews its texture in
    the row's statusbar.

Parameters
    callback  (function)  onclick callback.

Returns
    (function) Closure returning dropdownoption[].

Option structure
    value = texture name, label = texture name,
    statusbar = texture path. Sorted alphabetically.


=====================================================================
65) DF:CreateFrameStrataListGenerator()
=====================================================================

Location
    dropdown.lua  line 1462

Signature
    DF:CreateFrameStrataListGenerator(callback)

Purpose
    Returns a menu-builder function listing WoW frame strata
    levels from DF.FrameStrataLevels.

Parameters
    callback  (function)  onclick callback.

Returns
    (function) Closure returning dropdownoption[].

Option structure
    value = strata string (e.g. "BACKGROUND", "MEDIUM"),
    label = same strata string.


=====================================================================
66) DF:CreateFontDropDown()
=====================================================================

Location
    dropdown.lua  line 1480

Signature
    DF:CreateFontDropDown(parent, callback, default, width, height,
                          member, name, template, bIncludeDefault)

Purpose
    Convenience constructor: creates a dropdown pre-filled with
    all fonts from LibSharedMedia.

Parameters
    parent          (frame)      Owner frame.
    callback        (function)   onclick for when a font is selected.
                                 Receives (dropdown, fixedValue, fontName).
    default         (any)        Initial selection (font name).
    width           (number?)    Button width.
    height          (number?)    Button height.
    member          (string?)    Key on parent to store the capsule.
    name            (string?)    Global frame name.
    template        (table?)     Visual template.
    bIncludeDefault (boolean?)   Prepend "DEFAULT" entry.

Returns
    (df_dropdown) The dropdown capsule.

Behavior
    Creates a font list generator via CreateFontListGenerator(),
    then delegates to DF:NewDropDown().


=====================================================================
67) DF:CreateStatusbarTextureDropDown()
=====================================================================

Location
    dropdown.lua  line 1497

Signature
    DF:CreateStatusbarTextureDropDown(parent, callback, default,
                                      width, height, member,
                                      name, template)

Purpose
    Convenience constructor: creates a dropdown pre-filled with
    all statusbar textures from LibSharedMedia.

Parameters
    Same 8-parameter pattern as CreateFontDropDown (without
    bIncludeDefault).

Returns
    (df_dropdown)


=====================================================================
68) DF:CreateFrameStrataDropDown()
=====================================================================

Location
    dropdown.lua  line 1510

Signature
    DF:CreateFrameStrataDropDown(parent, callback, default,
                                 width, height, member,
                                 name, template)

Purpose
    Convenience constructor: creates a dropdown pre-filled with
    frame strata levels.

Parameters
    Same 8-parameter pattern.

Returns
    (df_dropdown)


=====================================================================
69) DF:CreateColorDropDown()
=====================================================================

Location
    dropdown.lua  line 1521

Signature
    DF:CreateColorDropDown(parent, callback, default, width, height,
                           member, name, template)

Purpose
    Convenience constructor: creates a dropdown pre-filled with
    named colors from DF:GetDefaultColorList().

Parameters
    Same 8-parameter pattern.

Returns
    (df_dropdown)


=====================================================================
70) DF:CreateOutlineDropDown()
=====================================================================

Location
    dropdown.lua  line 1527

Signature
    DF:CreateOutlineDropDown(parent, callback, default, width,
                             height, member, name, template)

Purpose
    Convenience constructor: creates a dropdown pre-filled with
    font outline options.

Parameters
    Same 8-parameter pattern.

Returns
    (df_dropdown)


=====================================================================
71) DF:CreateAnchorPointDropDown()
=====================================================================

Location
    dropdown.lua  line 1533

Signature
    DF:CreateAnchorPointDropDown(parent, callback, default, width,
                                 height, member, name, template)

Purpose
    Convenience constructor: creates a dropdown pre-filled with
    WoW anchor points (TOPLEFT, CENTER, etc.).

Parameters
    Same 8-parameter pattern.

Returns
    (df_dropdown)


=====================================================================
72) DF:CreateAudioDropDown()
=====================================================================

Location
    dropdown.lua  line 1539

Signature
    DF:CreateAudioDropDown(parent, callback, default, width, height,
                           member, name, template)

Purpose
    Convenience constructor: creates a dropdown pre-filled with
    audio cues from LibSharedMedia.

Parameters
    Same 8-parameter pattern.

Returns
    (df_dropdown)


=====================================================================
73) DF:CreateRaidInstanceSelectorDroDown()
=====================================================================

Location
    dropdown.lua  line 1545

Signature
    DF:CreateRaidInstanceSelectorDroDown(parent, callback, default,
                                         width, height, member,
                                         name, template)

Purpose
    Convenience constructor: creates a dropdown listing all current
    raid instances from the Encounter Journal.

Parameters
    Same 8-parameter pattern.
    default  (number)  May be an index (1-based) into the instances
             array or a journalInstanceId directly.

Returns
    (df_dropdown)

Behavior
    1. Creates generator via CreateRaidInstanceListGenerator().
    2. If default ≤ #allInstances, converts the index to the
       corresponding journalInstanceId.
    3. Validates that default is current content via
       DF.Ejc.IsCurrentContent(). If not, falls back to the
       first instance.
    4. Delegates to DF:NewDropDown().

Note
    Name has a typo ("DroDown") preserved from the source.


=====================================================================
74) DF:CreateBossSelectorDroDown()
=====================================================================

Location
    dropdown.lua  line 1575

Signature
    DF:CreateBossSelectorDroDown(parent, callback, instanceId,
                                  default, width, height, member,
                                  name, template)

Purpose
    Convenience constructor: creates a dropdown listing all
    encounters (bosses) for a given raid instance. Includes an
    extra :SetInstance() method to switch instances.

Parameters
    parent      (frame)      Owner frame.
    callback    (function)   onclick callback.
    instanceId  (number)     journalInstanceId for initial bosses.
    default     (any)        Initial selection.
    width       (number?)    Button width.
    height      (number?)    Button height.
    member      (string?)    Key on parent.
    name        (string?)    Global name.
    template    (table?)     Visual template.

Returns
    (df_dropdown_bossselector) A df_dropdown with extra methods.

Behavior
    1. Creates generator via CreateBossListGenerator(callback, instanceId).
    2. Creates dropdown via DF:NewDropDown().
    3. Sets fixedParameter to instanceId.
    4. Attaches .SetInstance method and .callbackFunc.

Extra type: df_dropdown_bossselector
    .callbackFunc  (function)  The original callback.
    :SetInstance(instanceId)
        Updates the dropdown to show bosses from a different instance:
        1. Sets fixedParameter to new instanceId.
        2. Replaces .func with a new CreateBossListGenerator.
        3. Calls :Refresh().

Example
    local bossDrop = DF:CreateBossSelectorDroDown(
        parent, onBossSelect, 1195, 1, 200, 20
    )
    -- later, switch to a different instance:
    bossDrop:SetInstance(1200)

Note
    Name has a typo ("DroDown") preserved from the source.