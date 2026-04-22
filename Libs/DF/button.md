button.lua documentation
Part 1: overview, object architecture, and constructor

=====================================================================
Overview
=====================================================================

- button.lua implements the DetailsFramework button widget (df_button).
- It wraps a standard Blizzard button frame inside a Lua table that provides
  a richer API: callback management, template styling, icon support, tooltip
  handling, script hooks, text alignment, and property access through
  metamethod-driven getters and setters.
- The public entry point for creating a button is:
  DF:CreateButton(parent, callback, width, height, text, param1, param2,
  texture, member, name, shortMethod, buttonTemplate, textTemplate)
- Internally, CreateButton delegates to NewButton which is considered an
  internal function and should not be called directly.

=====================================================================
1) Object architecture
=====================================================================

A DetailsFramework button is a plain Lua table (buttonObject) that holds
references to the underlying Blizzard frame and exposes behavior through a
shared metatable (ButtonMetaFunctions).

Layer diagram:

	buttonObject (df_button)      -- the table you interact with
	 ├── .button / .widget        -- the actual Blizzard button frame (df_blizzbutton)
	 │    ├── .text               -- FontString (ARTWORK layer, GameFontNormal)
	 │    ├── .texture_disabled   -- Texture (OVERLAY layer, hidden by default)
	 │    └── .MyObject           -- back-reference to buttonObject
	 ├── .func                    -- left-click callback
	 ├── .funcright               -- right-click callback
	 ├── .param1, .param2         -- callback parameters
	 ├── .container               -- frame used for drag/move
	 ├── .HookList                -- table of hook arrays per script
	 ├── .text_overlay            -- reference to the FontString global
	 ├── .disabled_overlay        -- reference to the disabled texture global
	 └── metatable: ButtonMetaFunctions

Key types:
- df_button: the wrapper table. This is what DF:CreateButton returns.
- df_blizzbutton: the underlying Blizzard button frame. Accessed via
  buttonObject.button or buttonObject.widget. Has a .MyObject field
  pointing back to the wrapper.

=====================================================================
2) Internal widget creation: createButtonWidgets
=====================================================================

Purpose
- Initializes the visual children of the raw Blizzard button frame before
  the wrapper object finishes construction.

What it creates
- Sets the default frame size to 100 x 20.
- Creates a centered FontString (.text) in the ARTWORK layer, inheriting
  GameFontNormal, with font size forced to 10.
- Creates a full-coverage disabled overlay texture (.texture_disabled) in
  the OVERLAY layer, initially hidden, using the standard tooltip background.
- Wires OnDisable to show the overlay (vertex color 0.1, 0.1, 0.1, alpha
  0.834) and OnEnable to hide it.

Why it matters
- Every button shares this same internal structure. The .text FontString is
  what SetText, SetTextColor, SetFontSize, etc. operate on. The
  .texture_disabled overlay is what makes Disable() visually gray out the
  button.

=====================================================================
3) DF:CreateButton — the public constructor
=====================================================================

Signature
	DF:CreateButton(parent, callback, width, height, text, param1, param2,
	    texture, member, name, shortMethod, buttonTemplate, textTemplate)

Returns
	df_button — the wrapper object.

Parameter reference

	parent (frame, required)
	    The frame that will own this button. Can be a raw Blizzard frame or
	    another DetailsFramework widget (if .dframework is true, the real
	    frame is extracted from .widget automatically).

	callback (function or nil)
	    The function called when the button is left-clicked.
	    Signature: function(blizzardButton, clickType, param1, param2)
	    - blizzardButton is the underlying 'button' frame from the game API.
	    - clickType is the mouse button string ("LeftButton").
	    - param1, param2 are the stored parameter values, they can be changed using button:SetParameters(param1, param2)
	    If callback is nil, an empty function is used (the button does nothing on click).

	width (number)
	    Requested pixel width of the button. Defaults to 100 if omitted.
	    May be overridden automatically if the text label is wider than
	    width - 15 (see shortMethod below).

	height (number)
	    Requested pixel height. Defaults to 20 if omitted.

	text (string or localization table)
	    The label shown on the button. Passed through
	    DetailsFramework.Language.SetTextWithLocTableWithDefault, so it also
	    accepts a localization table for multilingual support.

	param1 (any, optional)
	    First extra parameter stored and passed to the callback on click.

	param2 (any, optional)
	    Second extra parameter stored and passed to the callback on click.

	texture (string, number, or nil, optional)
	    Texture applied to all four button states (normal, pushed, disabled,
	    highlight). Supports:
	    - Atlas name strings (detected via C_Texture.GetAtlasInfo).
	    - File path strings or texture IDs.
	    - HTML color strings (e.g. "#FF0000").
	    - Empty string or nil: no texture is applied (avoids green rectangles).

	member (string or nil, optional)
	    If provided, the button object is stored as parent[member].
	    Example: passing "myBtn" makes parent.myBtn point to the new button.

	name (string or nil, optional)
	    Global name for the underlying Blizzard frame. If omitted, a unique
	    name is auto-generated using a global counter
	    ("DetailsFrameworkButtonNumber" + counter, or parentName + "Button"
	    + counter when the parent has a name).

	shortMethod (boolean, number, or nil, optional)
	    Controls how text overflow (text wider than width - 15) is handled:
	    - nil (omitted): expand the button width to fit the text.
	    - false: do nothing; text may overflow visually.
	    - 1: shrink the font size (down to 8) until the text fits.
	    - 2: reserved / no-op in current code.

	buttonTemplate (table or nil, optional)
	    A visual template table applied via SetTemplate() after construction.
	    See the Template system section below.

	textTemplate (table or nil, optional)
	    A table with optional keys { size, color, font } applied to the
	    button's FontString immediately after creation:
	    - size (number): font size.
	    - color (any parseable color): text color.
	    - font (string): LibSharedMedia font name resolved via
	      SharedMedia:Fetch("font", name).

=====================================================================
4) Construction sequence (what happens inside NewButton)
=====================================================================

Step-by-step:

	1. Validation: errors if parent is nil.

	2. Name generation: builds a unique global name if none provided.

	3. Wrapper creation: creates the buttonObject table with
	   { type = "button", dframework = true }.

	4. Member registration: if member is provided, stores buttonObject on
	   the parent table.

	5. Parent unwrapping: if parent is a DetailsFramework widget, extracts
	   parent.widget to get the raw frame.

	6. Container setup: stores container = parent (used for drag behavior).

	7. Default state: is_locked = true, options = { OnGrab = false }.

	8. Blizzard frame creation: CreateFrame("button", name, parent,
	   "BackdropTemplate"). Mixes in WidgetFunctions.

	9. Widget initialization: calls createButtonWidgets to build .text and
	   .texture_disabled children. Sets pixel-perfect size.

	10. Cross-references: buttonObject.widget = buttonObject.button;
	    buttonObject.button.MyObject = buttonObject.

	11. API bridging (one-time): on the first button ever created, iterates
	    the Blizzard button metatable and copies any missing functions into
	    ButtonMetaFunctions so they can be called directly on df_button.

	12. Global references: stores text_overlay and disabled_overlay from
	    global name lookup.

	13. Texture application: applies the texture parameter to all four
	    button states (normal, pushed, disabled, highlight). Handles atlas
	    names, HTML colors, and empty strings as special cases.

	14. Text: sets the label text via the localization system and centers
	    the FontString.

	15. Text overflow: applies the shortMethod logic to handle text wider
	    than width - 15.

	16. Callbacks: stores func (or emptyFunction if nil), funcright
	    (emptyFunction), param1, param2.

	17. Text template: applies textTemplate { size, color, font } if
	    provided.

	18. Hook list: creates HookList with empty tables for OnEnter, OnLeave,
	    OnHide, OnShow, OnMouseDown, OnMouseUp.

	19. Script wiring: sets OnEnter, OnLeave, OnHide, OnShow, OnMouseDown,
	    OnMouseUp on the Blizzard frame.

	20. Metatable: sets ButtonMetaFunctions as the metatable, enabling all
	    methods and property accessors.

	21. Button template: applies buttonTemplate via SetTemplate() if
	    provided.

	22. Return: returns the completed df_button object.

=====================================================================
5) Button parts reference
=====================================================================

After creation, a df_button contains these accessible parts:

	.button / .widget (df_blizzbutton)
	    The real Blizzard button frame. You rarely need to access this
	    directly; the wrapper forwards most operations.

	.button.text (FontString)
	    The label FontString. Operated on by SetText(), SetTextColor(),
	    SetFontSize(), SetFontFace().

	.button.texture_disabled (Texture)
	    Full-coverage overlay shown when the button is disabled. Managed
	    automatically by Enable()/Disable().

	.func (function)
	    Left-click callback. Signature:
	    function(blizzardButton, clickType, param1, param2)

	.funcright (function)
	    Right-click callback. Same signature as .func.

	.param1, .param2 (any)
	    Parameters forwarded to the callback on click.

	.container (frame)
	    The frame used when the button is dragged (if unlocked and movable).

	.HookList (table)
	    Hook registry. Keys: OnEnter, OnLeave, OnHide, OnShow,
	    OnMouseDown, OnMouseUp. Each value is an array of hook functions.

	.icon (Texture, created on demand)
	    Only exists after calling SetIcon(). Anchored to the left of the
	    button; the text is re-anchored to the right of the icon.

	.text_overlay (FontString)
	    Global-name reference to .button.text.

	.disabled_overlay (Texture)
	    Global-name reference to .button.texture_disabled.

	.is_locked (boolean)
	    Whether the button is locked (not draggable). Defaults to true.

=====================================================================
6) Template system (SetTemplate)
=====================================================================

Purpose
- Applies a batch of visual properties from a keyed table.
- Called automatically by the constructor when buttonTemplate is passed,
  or manually at any time via button:SetTemplate(template).

Supported template keys

	width (number)              - button pixel width.
	height (number)             - button pixel height.
	backdrop (table)            - backdrop definition table.
	backdropcolor (color)       - backdrop fill color.
	backdropbordercolor (color) - backdrop border color (also stored as
	                              onleave_backdrop_border_color).
	onentercolor (color)        - backdrop color on mouse enter.
	onleavecolor (color)        - backdrop color on mouse leave.
	onenterbordercolor (color)  - border color on mouse enter.
	onleavebordercolor (color)  - border color on mouse leave.
	icon (table)                - icon definition with sub-keys:
	    .texture, .width, .height, .layout, .texcoord, .color,
	    .textdistance, .leftPadding.
	textsize (number)           - font size.
	textfont (string)           - font face (goes through smember_textfont).
	textcolor (color)           - text color.
	textalign (string)          - "left", "center", or "right".
	rounded_corner (table)      - enables rounded corner visuals via
	    DF:AddRoundedCornersToFrame (removes backdrop).

All color values go through DF:ParseColors() and accept any format:
color name strings, {r, g, b, a} tables, HTML hex strings, etc.

=====================================================================
7) Usage examples
=====================================================================

Minimal button:
	local btn = DF:CreateButton(UIParent, function(self, button)
	    print("Clicked!")
	end, 120, 25, "Click Me")
	btn:SetPoint("CENTER")

Button with parameters:
	local btn = DF:CreateButton(parentFrame, function(self, button, p1, p2)
	    print("Player:", p1, "Action:", p2)
	end, 100, 20, "Do Action", "PlayerName", "Cast")

Button with template:
	local template = DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")
	local btn = DF:CreateButton(parentFrame, myFunc, 140, 22,
	    "Settings", nil, nil, nil, nil, nil, nil, template)

Button with icon:
	local btn = DF:CreateButton(parentFrame, myFunc, 130, 24, "Spell")
	btn:SetIcon(spellIcon, 20, 20, "artwork", nil, nil, 4, 2)

Button with text template:
	local textTmpl = { size = 12, color = "gold", font = "Friz Quadrata TT" }
	local btn = DF:CreateButton(parentFrame, myFunc, 100, 20,
	    "Styled", nil, nil, nil, nil, nil, nil, nil, textTmpl)

Member registration:
	DF:CreateButton(parentFrame, myFunc, 80, 20, "Go", nil, nil, nil, "goButton")
	-- parentFrame.goButton is now the df_button object

Simulating a click programmatically:
	-- using the __call metamethod:
	btn()
	-- or using Exec or Click:
	btn:Exec()
	btn:Click()

Right-click simulation:
	btn:RightClick()

=====================================================================
End of Part 1
=====================================================================

=====================================================================
Part 2: metamethod-driven getters and setters
=====================================================================

Context
- df_button uses __index and __newindex metamethods to intercept property
  reads and writes on the wrapper table.
- Reading a key that exists in the GetMembers table calls a getter function
  and returns its result. This means property-style access like
  'local w = btn.width' actually executes a function.
- Writing a key that exists in the SetMembers table calls a setter function
  instead of storing the raw value. This means 'btn.text = "Hello"'
  actually calls SetText on the underlying FontString.
- Keys not in either table fall through to rawget/rawset, behaving like
  normal table fields.

=====================================================================
8) Getter keys (GetMembers)
=====================================================================

These are the keys that can be read as properties on a df_button object.
Reading them triggers the corresponding getter function.

	"tooltip"
	    Returns: string or nil — the current tooltip text.
	    Calls object:GetTooltip() (from TooltipHandlerMixin).
	    Example: local tt = btn.tooltip

	"shown"
	    Returns: boolean — whether the button is currently shown.
	    Calls object:IsShown() on the wrapper.
	    Example: if btn.shown then ... end

	"width"
	    Returns: number — the pixel width of the underlying Blizzard button.
	    Calls object.button:GetWidth().
	    Example: local w = btn.width

	"height"
	    Returns: number — the pixel height of the underlying Blizzard button.
	    Calls object.button:GetHeight().
	    Example: local h = btn.height

	"text"
	    Returns: string or nil — the text currently displayed on the button.
	    Calls object.button.text:GetText() on the internal FontString.
	    Example: local label = btn.text

	"clickfunction"
	    Returns: function — the left-click callback stored on the object.
	    Uses rawget(object, "func") to bypass metamethods.
	    Example: local fn = btn.clickfunction

	"texture"
	    Returns: table — an array of four texture objects:
	    { NormalTexture, HighlightTexture, PushedTexture, DisabledTexture }.
	    Retrieves all four state textures from the Blizzard button.
	    Example: local textures = btn.texture

	"locked"
	    Returns: boolean — whether the button is locked (not draggable).
	    Uses rawget(object, "is_locked") to read the internal flag.
	    Example: if btn.locked then ... end

	"fontcolor" / "textcolor" (aliases of each other)
	    Returns: number, number, number, number — r, g, b, a text color.
	    Calls object.button.text:GetTextColor() on the FontString.
	    Example: local r, g, b, a = btn.fontcolor

	"fontface" / "textfont" (aliases of each other)
	    Returns: string — the font file path currently in use.
	    Calls object.button.text:GetFont() and returns only the first value
	    (the font face path, discarding font size).
	    Example: local face = btn.fontface

	"fontsize" / "textsize" (aliases of each other)
	    Returns: number — the current font size.
	    Calls object.button.text:GetFont() and returns only the second value
	    (the size, discarding the font face path).
	    Example: local size = btn.fontsize

__index resolution order
- The __index metamethod checks in this order:
  1. GetMembers[key] — if found, calls the getter and returns its result.
  2. rawget(object, key) — returns any value stored directly on the table.
  3. ButtonMetaFunctions[key] — returns any method from the shared metatable.

=====================================================================
9) Setter keys (SetMembers)
=====================================================================

These are the keys that can be written as properties on a df_button object.
Writing them triggers the corresponding setter function instead of storing
the raw value.

	"tooltip"
	    Accepts: string or nil — the tooltip text to display.
	    Calls object:SetTooltip(value) (from TooltipHandlerMixin).
	    Example: btn.tooltip = "Click to reset"

	"show"
	    Accepts: boolean — true to show, false to hide.
	    Calls object:Show() when value is truthy, object:Hide() otherwise.
	    Example: btn.show = true

	"hide"
	    Accepts: boolean — true to hide, false to show.
	    Inverse logic of "show": calls object:Hide() when truthy,
	    object:Show() when falsy.
	    Example: btn.hide = true

	"width"
	    Accepts: number — the new pixel width.
	    Calls object.button:SetWidth(value) on the Blizzard frame.
	    Example: btn.width = 150

	"height"
	    Accepts: number — the new pixel height.
	    Calls object.button:SetHeight(value) on the Blizzard frame.
	    Example: btn.height = 30

	"text"
	    Accepts: string — the new button label text.
	    Calls object.button.text:SetText(value) on the internal FontString.
	    Example: btn.text = "Apply"

	"clickfunction"
	    Accepts: function — the new left-click callback.
	    Uses rawset(object, "func", value) to store the function directly,
	    bypassing metamethods.
	    Example: btn.clickfunction = function(self, mb) print(mb) end

	"param1"
	    Accepts: any — the first callback parameter.
	    Uses rawset(object, "param1", value).
	    Example: btn.param1 = "playerName"

	"param2"
	    Accepts: any — the second callback parameter.
	    Uses rawset(object, "param2", value).
	    Example: btn.param2 = 42

	"textcolor" / "fontcolor" (aliases of each other)
	    Accepts: any color value — passed through DF:ParseColors().
	    Supports color name strings ("red"), {r, g, b, a} tables, HTML hex
	    strings, or individual r, g, b, a numbers.
	    Sets the text color on the internal FontString.
	    Example: btn.textcolor = "gold"
	    Example: btn.fontcolor = {1, 0, 0, 1}

	"textfont" / "fontface" (aliases of each other)
	    Accepts: string — a font file path or LibSharedMedia font name.
	    Calls DF:SetFontFace(object.button.text, value).
	    Example: btn.textfont = [[Fonts\FRIZQT__.TTF]]

	"textsize" / "fontsize" (aliases of each other)
	    Accepts: number — the desired font size.
	    Calls DF:SetFontSize(object.button.text, value).
	    Example: btn.textsize = 14

	"texture"
	    Accepts: any texture value — file path, atlas name, or texture ID.
	    Calls DF:SetButtonTexture(object, value, 0, 1, 0, 1) which applies
	    the texture to all button states with default tex coords.
	    Example: btn.texture = [[Interface\Tooltips\UI-Tooltip-Background]]

	"locked"
	    Accepts: boolean — true to lock (prevent dragging), false to unlock.
	    When true: calls button:SetMovable(false) and stores is_locked = true.
	    When false: calls button:SetMovable(true) and stores is_locked = false.
	    Example: btn.locked = false

	"textalign"
	    Accepts: string — "left" (or "<"), "center" (or "|"), "right" (or ">").
	    Re-anchors the text FontString within the button and stores the
	    alignment in object.capsule_textalign for use by mouse-down/mouse-up
	    text offset animations.
	    Example: btn.textalign = "left"

__newindex resolution order
- The __newindex metamethod checks:
  1. SetMembers[key] — if found, calls the setter with the value.
  2. Otherwise, falls through to rawset(object, key, value) for normal
     table storage.

=====================================================================
10) Important notes on metamember usage
=====================================================================

- Getters and setters are syntactic sugar. These two are equivalent:
	btn.text = "Hello"          -- triggers smember_text via __newindex
	btn:SetText("Hello")        -- calls the method directly
  Both update the same internal FontString.

- Alias keys exist for convenience:
	fontcolor / textcolor       -- both point to the same getter/setter
	fontface / textfont         -- both point to the same getter/setter
	fontsize / textsize         -- both point to the same getter/setter

- The "show" and "hide" setters have inverse boolean logic:
	btn.show = true   -- shows the button
	btn.hide = true   -- hides the button
	btn.show = false  -- hides the button
	btn.hide = false  -- shows the button

- The "clickfunction" key maps to the .func field internally. Reading it
  returns rawget(object, "func"), and writing it does rawset(object, "func").

- Writing to any key not in SetMembers stores the value directly on the
  table via rawset. This means custom fields can be added freely:
	btn.myCustomData = { score = 100 }  -- stored normally

=====================================================================
Part 3: methods
=====================================================================

Context
- All methods below live in the ButtonMetaFunctions metatable and are
  called on the df_button wrapper object (e.g. btn:SetText("Hello")).
- Because the __index metamethod falls through to ButtonMetaFunctions,
  every method listed here is available on any df_button instance.


=====================================================================
11) Callback management
=====================================================================

SetClickFunction(func, param1, param2, clickType)
.....................................................................
Purpose
  Replace the function called when the button is clicked, and optionally
  update the stored parameters at the same time.

Parameters
  func      (function or nil)
      The new callback. If nil, an empty no-op function is stored.
  param1    (any or nil)
      If not nil, replaces the stored param1.
  param2    (any or nil)
      If not nil, replaces the stored param2.
  clickType (string or nil)
      Determines which callback slot is written:
      - nil or a string containing "left" (case-insensitive): sets the
        left-click callback (.func) and optionally param1/param2.
      - A string containing "right" (case-insensitive): sets the
        right-click callback (.funcright). param1/param2 are NOT updated
        for right-click registration.

Behavior
  - Uses rawset to store .func / .funcright directly on the wrapper table
    (bypasses __newindex setters).
  - param1 and param2 are only updated when the value passed is not nil.
    Pass explicit values to clear them or use SetParameters separately.

Example
  btn:SetClickFunction(function(self, button, p1, p2)
      print("Left clicked", p1)
  end, "hello", 42)

  btn:SetClickFunction(function(self, button, p1, p2)
      print("Right clicked")
  end, nil, nil, "RightButton")


SetParameters(param1, param2)
.....................................................................
Purpose
  Change the parameters passed to the callback without replacing the
  callback function itself.

Parameters
  param1  (any or nil)  — stored only when not nil.
  param2  (any or nil)  — stored only when not nil.

Behavior
  Uses rawset to write .param1 and .param2. If you need to set a
  parameter to nil explicitly, use rawset(btn, "param1", nil) directly.

Example
  btn:SetParameters("newParam1", "newParam2")


=====================================================================
12) Text methods
=====================================================================

SetText(text)
.....................................................................
Purpose
  Set the label shown on the button.

Parameters
  text (string) — the new label text.

Behavior
  Directly calls :SetText() on the internal FontString (self.button.text).

Example
  btn:SetText("Apply")


SetTextTruncated(text, maxWidth)
.....................................................................
Purpose
  Set the label and automatically truncate it with an ellipsis if it
  exceeds maxWidth pixels.

Parameters
  text     (string) — the new label text.
  maxWidth (number) — maximum pixel width for the text before truncation.

Behavior
  Sets the text first, then calls DF:TruncateText on the FontString.

Example
  btn:SetTextTruncated("Very Long Spell Name Here", 80)


SetTextColor(...)
.....................................................................
Purpose
  Set the color of the button label.

Parameters
  ... — any color format accepted by DF:ParseColors:
      - Color name string: "red"
      - r, g, b, a numbers: 1, 0, 0, 1
      - Table: {1, 0, 0, 1}
      - HTML hex string: "#FF0000"

Alias
  SetFontColor — points to the same function.

Example
  btn:SetTextColor("red")
  btn:SetTextColor(1, 1, 0, 1)
  btn:SetFontColor({0.5, 0.8, 1, 1})


SetFontSize(...)
.....................................................................
Purpose
  Change the font size of the button label.

Parameters
  ... (number) — the new font size, passed to DF:SetFontSize.

Example
  btn:SetFontSize(14)


SetFontFace(font)
.....................................................................
Purpose
  Change the font face of the button label.

Parameters
  font (string) — path to a font file.

Example
  btn:SetFontFace([[Fonts\FRIZQT__.TTF]])


=====================================================================
13) Texture methods
=====================================================================

SetTexture(normalTexture, highlightTexture, pressedTexture, disabledTexture)
.....................................................................
Purpose
  Set the four standard button-state textures individually.

Parameters
  Each parameter controls one button state. The type determines behavior:

  normalTexture (string, number, or nil)
      - string/number: sets the normal texture.
      - nil: clears the normal texture (sets to "").
      - false (boolean): does nothing (skips this state).

  highlightTexture (string, number, boolean, or nil)
      - string/number: sets the highlight texture with "ADD" blend.
      - true: copies normalTexture with "ADD" blend.
      - nil: clears the highlight texture.

  pressedTexture (string, number, boolean, or nil)
      - string/number: sets the pushed texture.
      - true: copies normalTexture as the pushed texture.
      - nil: clears the pushed texture.

  disabledTexture (string, number, boolean, or nil)
      - string/number: sets the disabled texture.
      - true: copies normalTexture as the disabled texture.
      - nil: clears the disabled texture.

Behavior
  The boolean shorthand (true) reuses the normal texture for the other
  states, providing a quick way to apply one texture across all states.

Example
  -- Set a different texture per state:
  btn:SetTexture(
      [[Interface\Buttons\Normal]],
      [[Interface\Buttons\Highlight]],
      [[Interface\Buttons\Pressed]],
      [[Interface\Buttons\Disabled]]
  )

  -- Use one texture for all states:
  btn:SetTexture([[Interface\Tooltips\UI-Tooltip-Background]], true, true, true)

  -- Clear all textures:
  btn:SetTexture(nil, nil, nil, nil)


=====================================================================
14) Icon methods
=====================================================================

SetIcon(texture, width, height, layout, texcoord, overlay, textDistance,
        leftPadding, textHeight, shortMethod, filterMode)
.....................................................................
Purpose
  Add or update an icon to the left of the button text.

Parameters
  texture      (string, number, or table)
      The texture path, texture ID, or atlas name. Also accepts an HTML
      color string (e.g. "#FF0000") which creates a solid color icon.
      Passed through DF:ParseTexture.

  width        (number or nil)
      Icon width in pixels. Defaults to button height * 0.8.

  height       (number or nil)
      Icon height in pixels. Defaults to button height * 0.8.

  layout       (string or nil)
      Draw layer: "background", "border", "artwork", "overlay".
      Defaults to "artwork".

  texcoord     (table or nil)
      Texture coordinates as {left, right, top, bottom}.

  overlay      (any or nil)
      Color tint applied to the icon via SetVertexColor. Accepts any
      DF:ParseColors format. Defaults to white {1, 1, 1, 1}.

  textDistance  (number or nil)
      Pixel gap between the icon and the text. Default: 2.

  leftPadding  (number or nil)
      Extra pixels from the left edge to the icon. Default: 0.

  textHeight   (number or nil)
      Vertical offset for the text anchor relative to the icon. Default: 0.

  shortMethod  (boolean, number, or nil)
      How to handle text that overflows the remaining space:
      - false: do nothing (allow overflow).
      - nil: grow the button width to fit text + icon.
      - 1: shrink the font size (down to size 8 minimum) until it fits.
      - 2: truncate the text with an ellipsis.

  filterMode   (string or nil)
      Texture filter: "BILINEAR", "TRILINEAR", or "NEAREST".

Behavior
  On first call, creates the .icon texture child and re-anchors the text
  FontString to sit to the right of the icon. Subsequent calls reuse the
  same texture. The icon is accessible afterwards as btn.icon.

  The shortMethod overflow logic only fires when the text is wider than
  (buttonWidth - 15 - iconWidth).

Example
  btn:SetIcon(spellIcon, 20, 20, "artwork", nil, nil, 4, 2)
  btn.icon:SetAlpha(0.4)

  -- Atlas icon:
  btn:SetIcon("common-search-clearbutton", 12, 12, "OVERLAY")

  -- Icon with overflow truncation:
  btn:SetIcon(texture, 24, 24, nil, nil, nil, 4, 2, nil, 2)


GetIconTexture()
.....................................................................
Purpose
  Returns the texture set on the icon, or nil if no icon exists.

Returns
  (number or nil) — the texture ID/path of the icon.

Example
  local tex = btn:GetIconTexture()
  if tex then print("Icon is", tex) end


SetIconFilterMode(filterMode)
.....................................................................
Purpose
  Change the texture filter mode on an existing icon.

Parameters
  filterMode (string) — "BILINEAR", "TRILINEAR", or "NEAREST".

Behavior
  Re-applies the icon's current texture with the new filter mode.
  Does nothing if no icon exists.

Example
  btn:SetIconFilterMode("TRILINEAR")


=====================================================================
15) Enable / Disable methods
=====================================================================

IsEnabled()
.....................................................................
Purpose
  Query whether the button is currently enabled.

Returns
  (boolean) — true if the underlying Blizzard button is enabled.

Example
  if btn:IsEnabled() then print("Can click") end


Enable()
.....................................................................
Purpose
  Enable the button, making it clickable and removing the grayed-out
  overlay.

Behavior
  - If the button has a BuildMenu label (.hasLabel) with a stored
    original color, restores that label's color.
  - Calls the Blizzard button's :Enable(), which hides the
    .texture_disabled overlay (see createButtonWidgets).

Example
  btn:Enable()


Disable()
.....................................................................
Purpose
  Disable the button, making it unclickable and showing the grayed-out
  overlay.

Behavior
  - If the button has a BuildMenu label (.hasLabel), stores its current
    text color in .__original_color (only once) and dims it to
    (0.5, 0.5, 0.5).
  - Calls the Blizzard button's :Disable(), which shows the
    .texture_disabled overlay.

Example
  btn:Disable()


SetEnabled(enable)
.....................................................................
Purpose
  Convenience wrapper that calls Enable() or Disable() based on a
  boolean.

Parameters
  enable (boolean) — true to enable, false to disable.

Example
  btn:SetEnabled(someCondition)


=====================================================================
16) Click simulation methods
=====================================================================

Exec()
.....................................................................
Purpose
  Programmatically fire the left-click callback without user interaction.

Behavior
  Calls DF:CoreDispatch with the left-click callback (.func), passing
  the Blizzard button frame, "LeftButton", .param1, and .param2.

Example
  btn:Exec()


Click()
.....................................................................
Purpose
  Identical to Exec(). Fires the left-click callback.

Behavior
  Same as Exec(): dispatches .func with "LeftButton" and params.

Example
  btn:Click()


RightClick()
.....................................................................
Purpose
  Programmatically fire the right-click callback.

Behavior
  Calls DF:CoreDispatch with the right-click callback (.funcright),
  passing "RightButton", .param1, and .param2.

Example
  btn:RightClick()


Note on __call
  The df_button wrapper table also supports the call operator:
      btn()
  This fires the left-click callback via CoreDispatch, equivalent to
  Exec() and Click().


=====================================================================
17) Legacy method
=====================================================================

InstallCustomTexture()
.....................................................................
Purpose
  Deprecated. Applies the standard "OPTIONS_BUTTON_TEMPLATE" template.

Behavior
  Calls self:SetTemplate(DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")).

Note
  This method exists for backward compatibility only. Use SetTemplate()
  directly instead.


=====================================================================
18) SetTemplate (detailed behavior)
=====================================================================

SetTemplate(template)
.....................................................................
Purpose
  Apply a batch of visual properties from a keyed table or a named
  template string.

Parameters
  template (table or string)
      If a string, it is resolved via DF:ParseTemplate("button", template)
      to get the actual table. If the lookup fails, an error is raised.

Supported keys and their behavior

  width (number)
      Sets the button width via PixelUtil.SetWidth.

  height (number)
      Sets the button height via PixelUtil.SetHeight.

  backdrop (table)
      Applies a backdrop table via self:SetBackdrop().

  backdropcolor (color)
      Sets the backdrop color and stores it as the onleave_backdrop
      default. This means the button reverts to this color when the
      mouse leaves.

  backdropbordercolor (color)
      Sets the backdrop border color and stores it as the
      onleave_backdrop_border_color default.

  onentercolor (color)
      The backdrop color to apply when the mouse enters the button.
      Stored in self.onenter_backdrop.

  onleavecolor (color)
      The backdrop color to apply when the mouse leaves the button.
      Overrides the backdropcolor onleave value if both are provided.
      Stored in self.onleave_backdrop.

  onenterbordercolor (color)
      The border color to apply on mouse enter.
      Stored in self.onenter_backdrop_border_color.

  onleavebordercolor (color)
      The border color to apply on mouse leave.
      Overrides backdropbordercolor onleave value if both are provided.
      Stored in self.onleave_backdrop_border_color.

  icon (table)
      Calls SetIcon internally. The table should contain:
          texture, width, height, layout, texcoord, color,
          textdistance, leftPadding

  textsize (number)
      Sets the text size via the "textsize" setter (triggers __newindex).

  textfont (string)
      Sets the text font via the "textfont" setter.

  textcolor (color)
      Sets the text color via the "textcolor" setter.

  textalign (string)
      Sets the text alignment via the "textalign" setter.
      Accepted values: "left", "center", "right".

  rounded_corner (table)
      Removes the standard backdrop and calls
      DF:AddRoundedCornersToFrame to apply rounded corners.
      Has special handling for color picker buttons: re-layers the
      color and background textures and applies an alpha mask.

Color values
  All color keys are passed through DF:ParseColors and accept any
  format: color name strings, {r, g, b, a} tables, HTML hex, or
  individual r, g, b, a numbers.

Hover color cycle
  When onentercolor and/or onenterbordercolor are set through the
  template, the button's OnEnter/OnLeave scripts (see Part 4) use these
  stored colors to animate the backdrop on hover. The cycle is:
      Mouse enters → apply onenter_backdrop, onenter_backdrop_border_color
      Mouse leaves → apply onleave_backdrop, onleave_backdrop_border_color

Example
  local template = {
      backdrop = {bgFile = [[Interface\Tooltips\UI-Tooltip-Background]]},
      backdropcolor = {0.1, 0.1, 0.1, 0.8},
      backdropbordercolor = {0, 0, 0, 1},
      onentercolor = {0.3, 0.3, 0.3, 0.8},
      onleavecolor = {0.1, 0.1, 0.1, 0.8},
      textcolor = "white",
      textsize = 11,
  }
  btn:SetTemplate(template)

  -- Using a named template:
  btn:SetTemplate(DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"))


=====================================================================
End of Part 3
=====================================================================

=====================================================================
Part 4: color picker button, tab button, close button
=====================================================================

These are standalone widget types that live in button.lua alongside the
base df_button. Each has its own constructor and mixin. They are NOT
created with DF:CreateButton — they have dedicated factory functions.


=====================================================================
19) Color picker button (df_colorpickbutton)
=====================================================================

Overview
- A specialized button that opens the WoW color picker dialog when clicked.
- Extends df_button (created internally via NewButton) with additional
  color-specific fields and methods.
- Displays a color swatch texture that updates live as the user picks a
  color. Behind the swatch, a transparency grid hints at the alpha value.

Type: df_colorpickbutton (inherits from df_button)

Constructor
.....................................................................

DF:CreateColorPickButton(parent, name, member, callback, alpha, buttonTemplate)

  Alias: DF:NewColorPickButton (same function)

Parameters
  parent          (frame, required)
      The parent frame. Can be a raw Blizzard frame or a DF widget.

  name            (string or nil)
      Global name for the underlying Blizzard frame.

  member          (string or nil)
      If provided, stores the button as parent[member].

  callback        (function)
      Called whenever the user changes the color in the picker.
      Signature:
          function(buttonObject, red, green, blue, alpha)
      - buttonObject is the df_colorpickbutton wrapper.
      - red, green, blue, alpha are numbers in [0, 1].

  alpha           (number or nil)
      Passed as param1 to the internal NewButton call. Typically not
      used directly — the color alpha comes from the color picker.

  buttonTemplate  (table or nil)
      Visual template applied via SetTemplate. If nil, defaults to
      "OPTIONS_BUTTON_TEMPLATE".

Returns
  df_colorpickbutton — the color picker button object.

Construction details
  1. Creates a base df_button (16x16) with the click callback set to
     open the color picker.
  2. Stores the user callback in .color_callback.
  3. Creates a background texture (.background_texture) using the
     "AnimCreate_Icon_Texture" atlas at 30% alpha — this is the
     transparency grid behind the color swatch.
  4. Creates a color texture (.color_texture) as a white ColorTexture
     that shows the current color via SetVertexColor.
  5. Registers a "OnColorChanged" hook list so external code can listen
     to color changes.
  6. Applies the button template.

Additional fields (beyond df_button)
  .color_callback     (function)  — the user-provided callback
  .color_texture      (texture)   — the swatch texture showing the color
  .background_texture (texture)   — the transparency grid behind the swatch
  .__iscolorpicker    (boolean)   — always true; used by SetTemplate for
                                    special rounded-corner handling
  .Cancel             (function)  — hides the ColorPickerFrame

Additional methods
  SetColor(...)
      Set the displayed color without opening the picker.
      Accepts any format handled by DF:ParseColors.
      Example: btn:SetColor(1, 0, 0, 1)  -- red

  GetColor()
      Returns red, green, blue, alpha of the current swatch color.
      Example: local r, g, b, a = btn:GetColor()

  Cancel()
      Hides the ColorPickerFrame (closes the color picker dialog).

How the color picker callback works
  When the user picks a color:
  1. pickcolorCallback fires with red, green, blue, alpha.
  2. Alpha is clamped to [0, 1].
  3. The .color_texture vertex color is updated to show the new color.
  4. The .color_callback is called via CoreDispatch (safe-called).
  5. The "OnColorChanged" hook list is run.

Example
  local colorBtn = DF:CreateColorPickButton(
      parentFrame,
      "MyColorPicker",
      nil,
      function(self, r, g, b, a)
          print("New color:", r, g, b, a)
          myFrame:SetBackdropColor(r, g, b, a)
      end
  )
  colorBtn:SetPoint("CENTER")
  colorBtn:SetColor(0.5, 0.8, 1.0, 1.0) -- start with light blue


=====================================================================
20) Utility functions (color picker support)
=====================================================================

DF:SetButtonTexture(button, texture, left, right, top, bottom)
.....................................................................
Purpose
  Sets the same texture on all four button states (normal, pushed,
  highlight, disabled) of a raw Blizzard button.

  This is NOT called on df_button wrappers — it operates on the raw
  Blizzard button frame. Used internally by the smember_texture setter.

Parameters
  button   (button)   — the raw Blizzard button frame.
  texture  (string, number, or table)
      - string / number: applied to all four states. If the string is a
        valid atlas name, uses SetAtlas instead of SetTexture.
      - table: {normalPath, pushedPath, highlightPath, disabledPath} —
        sets each state individually.
  left     (number, table, or nil) — left texcoord, or a table
           {left, right, top, bottom} that unpacks all four coords.
  right    (number or nil)
  top      (number or nil)
  bottom   (number or nil)

  If left is nil, defaults to 0, 1, 0, 1 (full texture).

Example
  DF:SetButtonTexture(btn.button, [[Interface\Tooltips\UI-Tooltip-Background]], 0, 1, 0, 1)


DF:SetButtonVertexColor(button, red, green, blue, alpha)
.....................................................................
Purpose
  Sets the vertex color on all four button-state textures at once.

Parameters
  button (button) — the raw Blizzard button frame.
  red, green, blue, alpha — color values passed through DF:ParseColor.

Example
  DF:SetButtonVertexColor(btn.button, 1, 0.5, 0, 1) -- orange tint


=====================================================================
21) Tab button (df_tabbutton)
=====================================================================

Overview
- A button styled to look like a tab, with left/right/middle atlas
  textures that change appearance when selected.
- Uses raw Blizzard button frame with the TabButtonMixin mixed in
  (NOT a df_button wrapper — no metamember getters/setters).
- Automatically adjusts width to fit text content.
- Includes an optional close button in the top-right corner.

Type: df_tabbutton (inherits from button via CreateFrame)

Constructor
.....................................................................

DF:CreateTabButton(parent, frameName)

Parameters
  parent     (frame, required)
      The parent frame.

  frameName  (string or nil)
      Global name for the button frame.

Returns
  df_tabbutton — the tab button object.

Construction details
  1. Creates a raw Blizzard button (50x20) with BackdropTemplate.
  2. Mixes in TabButtonMixin for tab-specific methods.
  3. Creates child textures:
     - .LeftTexture (artwork layer) — left edge of the tab
     - .RightTexture (artwork layer) — right edge of the tab
     - .MiddleTexture (artwork layer) — stretching center of the tab
     - .SelectedTexture (overlay layer) — additive highlight shown when
       selected, using the yellow tab highlight texture, alpha 0.5,
       hidden by default
  4. Creates a centered FontString (.Text) using GameFontNormal.
  5. Creates a close button (.CloseButton) via DF:CreateCloseButton,
     sized 10x10, anchored top-right, alpha 0.6, hidden by default.
  6. Anchors all textures: left edge pinned left, right edge pinned
     right, middle stretches between them.
  7. Sets default atlas names for normal and selected states.

Fields
  .LeftTexture                (texture)     — left edge texture
  .RightTexture               (texture)     — right edge texture
  .MiddleTexture              (texture)     — stretching center texture
  .SelectedTexture            (texture)     — highlight overlay
  .Text                       (fontstring)  — the tab label
  .CloseButton                (df_closebutton) — optional close button
  .bIsSelected                (boolean)     — current selection state
  .leftTextureName            (string)      — "Options_Tab_Left"
  .rightTextureName           (string)      — "Options_Tab_Right"
  .middleTextureName          (string)      — "Options_Tab_Middle"
  .leftTextureSelectedName    (string)      — "Options_Tab_Active_Left"
  .rightTextureSelectedName   (string)      — "Options_Tab_Active_Right"
  .middleTextureSelectedName  (string)      — "Options_Tab_Active_Middle"

Methods (from TabButtonMixin)
.....................................................................

  SetText(text)
      Set the tab label. Automatically resizes the button width to
      fit the text plus 20px padding.
      Example: tab:SetText("Settings")

  SetSelected(selected)
      Toggle the selected visual state. When selected is true:
      - Left/Right/Middle textures switch to the "Active" atlas variants.
      - .SelectedTexture is shown.
      When false, textures revert to the normal variants.
      Example: tab:SetSelected(true)

  SetShowCloseButton(show)
      Show or hide the close button in the top-right corner.
      Example: tab:SetShowCloseButton(true)

  IsSelected()
      Returns whether the tab is currently selected.
      Example: if tab:IsSelected() then ... end

  Reset()
      Resets the tab to default state: normal atlas textures, empty
      text, bIsSelected = false, SelectedTexture hidden.
      Example: tab:Reset()

  GetFontString()
      Returns the .Text FontString for direct font manipulation.
      Example: local fs = tab:GetFontString()

Example
  -- Create a tab bar with 5 tabs
  local frame = CreateFrame("frame", "MyTabFrame", UIParent)
  frame:SetSize(650, 100)
  frame:SetPoint("CENTER")
  DetailsFramework:ApplyStandardBackdrop(frame)
  frame.TabButtons = {}

  local tabOnClick = function(self)
      for _, tab in ipairs(frame.TabButtons) do
          tab:SetSelected(false)
      end
      self:SetSelected(true)
  end

  for i = 1, 5 do
      local tab = DF:CreateTabButton(frame, "$parentTab" .. i)
      tab:SetPoint("bottomleft", frame, "topleft", (i-1) * 130, 0)
      tab:SetText("Tab " .. i)
      tab:SetWidth(128)
      tab:SetScript("OnClick", tabOnClick)
      table.insert(frame.TabButtons, tab)
  end

  frame.TabButtons[1]:SetSelected(true)
  frame.TabButtons[2]:SetShowCloseButton(true)


=====================================================================
22) Close button (df_closebutton)
=====================================================================

Overview
- A small "X" button that hides its parent frame when clicked.
- Uses the standard Blizzard UIPanelCloseButton template, reskinned with
  red exit atlas textures that are desaturated to appear gray, turning
  red on hover.
- Uses raw Blizzard button frame with CloseButtonMixin mixed in.

Type: df_closebutton (inherits from button via CreateFrame)

Constructor
.....................................................................

DF:CreateCloseButton(parent, frameName)

Parameters
  parent     (frame, required)
      The frame that the close button will hide when clicked.

  frameName  (string or nil)
      Global name for the button frame.

Returns
  df_closebutton — the close button object.

Construction details
  1. Creates a button using the "UIPanelCloseButton" template (16x16).
  2. Sets frame level to parent level + 1 (ensures it draws above the
     parent's content).
  3. Mixes in CloseButtonMixin.
  4. Reskins the four state textures:
     - Normal:    "RedButton-Exit" (desaturated)
     - Highlight: "RedButton-Highlight" (desaturated)
     - Pushed:    "RedButton-exit-pressed" (desaturated)
     - Disabled:  "RedButton-Exit-Disabled"
  5. Sets alpha to 0.7 for a subtle appearance.
  6. Wires OnClick, OnEnter, OnLeave from the mixin.

Mixin behavior (CloseButtonMixin)
.....................................................................

  OnClick(self)
      Hides the parent frame: self:GetParent():Hide()

  OnEnter(self)
      Sets the normal texture vertex color to red (1, 0, 0) —
      the button turns red on hover.

  OnLeave(self)
      Resets the normal texture vertex color to white (1, 1, 1) —
      the button returns to its desaturated gray appearance.

Fields
  Standard Blizzard button fields. No additional custom fields beyond
  the mixin methods.

Example
  local frame = CreateFrame("frame", "MyFrame", UIParent)
  frame:SetSize(200, 200)
  frame:SetPoint("CENTER")

  local closeBtn = DF:CreateCloseButton(frame, "$parentCloseButton")
  closeBtn:SetPoint("topright", frame, "topright", 0, 0)
  -- Clicking the close button will call frame:Hide()


=====================================================================
End of Part 4
=====================================================================
