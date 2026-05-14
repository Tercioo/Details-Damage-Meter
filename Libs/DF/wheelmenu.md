# wheelmenu.lua — Radial Wheel Menu

A wheel (a.k.a. pie / radial) menu that opens at the cursor, presents N options arranged around a ring, highlights the option under the cursor by angle, and confirms the selection on left mouse release. The module is small — one constructor (`DF:CreateWheelMenu`) and one mixin (`WheelMenuMixin`) — but it ships with deliberately empty appearance hooks, so consumers are expected to override styling in place. No production consumer in the `Details/Libs/DF/` sibling files calls `CreateWheelMenu` yet; treat the module as a building block awaiting wiring.

---

## Mental model

The wheel is **not** a hit-test of N button frames. It is a single circular frame whose center is the wheel pivot. Every frame, the mouse position is converted to an angle around that pivot; the angle picks the option index. The visible option buttons (icon + text) are just decoration placed at the slice centers — clicking the empty space between two buttons still selects the option whose slice the cursor lies in.

```
                          firstOptionAngle = pi/2 (top, default)
                                    │
                                    ▼
                            ┌─────[1]─────┐
                       ┌────┘             └────┐
                  ┌────┘                       └────┐
                 [6]      ┌──innerRadius──┐       [2]
                 │        │  (no select)  │         │
                 │        │  CenterText   │         │   ← outerRadius
                 │        └───────────────┘         │
                 [5]                              [3]
                  └────┐                       ┌────┘
                       └────┐             ┌────┘
                            └─────[4]─────┘

                slices advance COUNTERCLOCKWISE
                (math-convention angles, not clock face)
```

Three radii govern everything:

- `innerRadius` — dead zone in the center. Cursor inside ⇒ no selection.
- `outerRadius` — ring outer edge. Cursor outside ⇒ no selection.
- `optionRadius` — where the option *buttons* are drawn (defaults to the midpoint of inner and outer). Independent of the selection ring.

**The split that matters most**: the option *data* is `wheelmenuoption[]` (text, icon, onClick, value). The option *buttons* are a recycle pool (`optionButtons[]`) — created on demand, hidden when unused. Refreshing the menu rebinds buttons to options; it never destroys or replaces them. Buttons outlive the data.

---

## Library access

```lua
local DF = _G["DetailsFramework"] -- or LibStub("DetailsFramework-1.0")
local wheel = DF:CreateWheelMenu(parent, name, wheelOptions, config)
```

---

## CreateWheelMenu — signature

```lua
---@param parent frame?
---@param name string?
---@param wheelOptions wheelmenuoption[]?
---@param config wheelconfig?
---@return wheelmenuframe
function detailsFramework:CreateWheelMenu(parent, name, wheelOptions, config)
```

> Note: the source's EmmyLua `---@param` block lists `name` before `parent`, but the actual Lua signature is `(parent, name, ...)`. Trust the signature, not the annotation order. See "Pitfalls" below.

### Parameters

| # | Name | Type | Required | Description |
|---|---|---|---|---|
| 1 | `parent` | `frame?` | No | Parent frame. Defaults to `UIParent`. |
| 2 | `name` | `string?` | No | Global frame name passed to `CreateFrame`. May be nil. |
| 3 | `wheelOptions` | `wheelmenuoption[]?` | No | Initial options. Defaults to `{}`. You can replace later via `SetOptions`. |
| 4 | `config` | `wheelconfig?` | No | Geometry / strata / center text. See below. |

### Config table (`wheelconfig`)

| Key | Type | Default | Purpose |
|---|---|---|---|
| `inner_radius` | `number?` | `42` | Cursor dead-zone radius (px). Inside ⇒ nothing selected. |
| `outer_radius` | `number?` | `170` | Wheel outer radius (px). Outside ⇒ nothing selected. Also sets frame size to `outerRadius * 2` on each side. |
| `option_radius` | `number?` | `(outer + inner) / 2` | Radius at which option buttons are placed. Independent from the selection ring. |
| `option_button_width` | `number?` | `122` | Width of each option button. |
| `option_button_height` | `number?` | `24` | Height of each option button. |
| `first_option_angle` | `number?` | `math.pi * 0.5` | Angle (radians, math convention) where option index 1 is centered. Default places option 1 at the top; slices advance counterclockwise from there. |
| `frame_strata` | `string?` | `"FULLSCREEN"` | Strata for the menu. The default sits above almost everything, which is appropriate for a transient radial menu. |
| `frame_level` | `number?` | `120` | Frame level. |
| `center_text` | `string?` | `""` | Static text shown in the inner disc. |

**Returns:** `wheelmenuframe` — a `Frame` with `WheelMenuMixin` mixed in, hidden on creation, with `OnMouseUp` and `OnHide` already bound. The frame has `EnableMouse(true)` and `SetClampedToScreen(true)`.

### Minimal example

```lua
local wheel = DetailsFramework:CreateWheelMenu(UIParent, "MyAddonWheel", {
    {text = "Attack",  icon = 132212, onClick = function(self, opt) print("attack")  end},
    {text = "Defend",  icon = 132340, onClick = function(self, opt) print("defend")  end},
    {text = "Heal",    icon = 135907, onClick = function(self, opt) print("heal")    end},
    {text = "Retreat", icon = 132331, onClick = function(self, opt) print("retreat") end},
})
wheel:Refresh()

-- Later, bind to a key / mouse macro:
SomeButton:SetScript("OnMouseDown", function() wheel:OpenAtCursor() end)
```

---

## Option entries — `wheelmenuoption`

| Field | Type | Description |
|---|---|---|
| `text` | `string?` | Button label. Empty string used when nil. |
| `icon` | `string\|number?` | Texture path or fileID. When nil, the icon texture is hidden. |
| `onClick` | `fun(option: wheelmenuoption, menu: wheelmenuframe)?` | Confirmation callback. See "Click dispatch is asymmetric" in Pitfalls — the first argument is **not always** the option. |
| `value` | `any` | Free-form payload. The framework never reads this; it's for the consumer. |

`SetOptions(options)` only assigns the array — it does NOT call `Refresh()`. After mutating the option list, you must call `Refresh()` yourself.

---

## Selection algorithm — how the cursor maps to an option

The math is small but worth understanding:

1. Get wheel center on screen: `centerX, centerY = self:GetCenter()`.
2. `dx, dy = cursorX - centerX, cursorY - centerY`. Compare `dx*dx + dy*dy` against the squared radii — outside `[innerRadius, outerRadius]` ⇒ return nil.
3. Compute `angle = atan2(dy, dx)`, normalize into `[0, 2π)`.
4. `sliceAngle = 2π / optionCount`. Subtract `firstOptionAngle`, add half a slice so the boundary lies *between* slices, normalize again.
5. `index = floor(adjustedAngle / sliceAngle) + 1`, clamped to `[1, optionCount]`.

Two consequences:

- **There is no "no selection" zone between slices.** Once the cursor is in the ring, exactly one option owns the angle. The visible buttons are sparse; the angular slices are not.
- **Angles are math convention, not clock convention.** `firstOptionAngle = 0` puts option 1 to the *right* (3 o'clock). `math.pi * 0.5` puts it at the *top*. `math.pi` left, `math.pi * 1.5` (or `-math.pi * 0.5`) bottom. Slices advance counterclockwise.

The diagnostic comment `---@diagnostic disable-next-line: deprecated` on the `atan2` call acknowledges that Blizzard's environment has flagged `math.atan2` as deprecated in favor of `math.atan(y, x)` with two args. Functionally identical here; left in place rather than rewritten.

---

## Lifecycle — Open / Close / Refresh

### `OpenAtCursor()`

1. Reads cursor position via `detailsFramework:GetCursorPosition()`.
2. Re-anchors the frame: `SetPoint("center", UIParent, "bottomleft", mouseX, mouseY)` so the wheel's center is exactly under the cursor.
3. Clears the hovered index.
4. Shows the frame.
5. Installs an `OnUpdate` that runs `self:OnUpdate()` every frame — that's where the angle-based hover happens.

The anchor strategy assumes `GetCursorPosition` returns coordinates in `UIParent` bottomleft space. If you use a different cursor utility, you must match the same coordinate system or the wheel will open offset from the cursor.

### `CloseMenu()`

Clears the `OnUpdate` script, clears the hovered index, hides the frame. The `OnHide` handler also clears `OnUpdate` defensively — so `wheel:Hide()` directly is equivalent to `wheel:CloseMenu()` for cleanup purposes (modulo not clearing `hoveredIndex`, which next open does anyway).

### `Refresh()`

Rebinds every option to its button, sets text and icon, clears hover, then calls `UpdateButtons` to (re)position buttons around the ring. Call this any time you change the option array.

### `UpdateButtons()`

Layout pass. For each option `i`:

```lua
local angle = normalizeAngle(firstOptionAngle + (i - 1) * sliceAngle)
local x = cos(angle) * optionRadius
local y = sin(angle) * optionRadius
button:SetPoint("center", self, "center", x, y)
button.SectorStartAngle = normalizeAngle(angle - sliceAngle * 0.5)
button.SectorEndAngle   = normalizeAngle(angle + sliceAngle * 0.5)
```

The per-button `SectorStartAngle` / `SectorEndAngle` are written for consumer code that wants to draw filled sector textures behind each option (e.g. via a custom texture sliced by angle). The framework itself never reads them.

After laying out the live buttons, `HideUnusedButtons` runs from `optionCount + 1` to `#optionButtons`, hiding the trailing pool entries. This is why shrinking the option list never leaks visible widgets.

### `OnUpdate` — hover tracking

```
mouseX, mouseY = DF:GetCursorPosition()
index = GetOptionIndexUnderCursor(mouseX, mouseY)   -- can be nil
SetHoveredButtonIndex(index)                         -- no-op if unchanged
```

`SetHoveredButtonIndex` early-exits when the index hasn't changed, so the `ResetAppearance` + `ApplyHoveredAppearance` cycle only fires on transitions, not every frame. Worth preserving this if you override.

### `ConfirmHoveredOption()`

Wired to the menu frame's `OnMouseUp` for `LeftButton`. If there's a hovered index and the option has an `onClick`, it calls `xpcall(option.onClick, geterrorhandler(), self, option)` — i.e. `onClick(menu, option)`. Right-click closes without confirmation.

---

## Buttons — the recycle pool

| Method | Purpose |
|---|---|
| `CreateOptionButton(parent, width, height)` | Builds a bare `Button` with `Icon` (16×16 left-anchored texture) and `Text` (left-justified `GameFontNormal` fontstring), wires `OnClick`, appends to `optionButtons`, returns it. |
| `GetOptionButton(index, dontCreate)` | Returns `optionButtons[index]`. If absent and `dontCreate` is falsy, creates one via `CreateOptionButton`. Pass `dontCreate = true` from hover code so you never accidentally inflate the pool while just inspecting. |
| `GetAllOptionsButtons()` | Returns the entire pool, including any currently-hidden trailing entries. |
| `GetNumOptionButtonsCreated()` | `#optionButtons`. Equal to the high-water mark of option count over the menu's lifetime. |
| `HideUnusedButtons()` | Hides pool entries past `GetNumOptions()`. Called automatically from `UpdateButtons`. |

The buttons created by `CreateOptionButton` have no backdrop, no highlight texture, no border — just an icon and a text label. Skinning is on the consumer. The simplest way is to override `CreateOptionButton` on a specific instance before any option fetch happens, or to walk the pool after the first `Refresh()` and decorate each entry.

---

## Customizing appearance — the two stub hooks

```lua
function WheelMenuMixin:ResetAppearance()
    for index, button in ipairs(self:GetAllOptionsButtons()) do
        -- intentionally empty: override per-instance
    end
end

function WheelMenuMixin:ApplyHoveredAppearance(button)
    -- intentionally empty: override per-instance
end
```

These are deliberate no-ops on the mixin. The hover transition will *call* them every time the active slice changes, but nothing visual happens until you override. The override slot is per-instance (or via a fresh mixin you compose yourself):

```lua
wheel.ResetAppearance = function(self)
    for _, btn in ipairs(self:GetAllOptionsButtons()) do
        btn.Text:SetTextColor(0.85, 0.85, 0.85)
        if btn.HoverBg then btn.HoverBg:Hide() end
    end
end

wheel.ApplyHoveredAppearance = function(self, button)
    button.Text:SetTextColor(1, 0.82, 0.0)
    button.HoverBg = button.HoverBg or button:CreateTexture(nil, "BACKGROUND")
    button.HoverBg:SetAllPoints()
    button.HoverBg:SetColorTexture(1, 0.82, 0, 0.15)
    button.HoverBg:Show()
end
```

`ResetAppearance` fires on every hover transition (including hover-to-nothing), so it must be cheap and idempotent.

---

## Pitfalls

### `---@param` annotation order disagrees with the function signature

The source has `---@param name string?` listed before `---@param parent frame?`, but the actual signature is `function detailsFramework:CreateWheelMenu(parent, name, wheelOptions, config)`. LuaLS readers and AI agents using the annotations may pass arguments in the wrong order.

**Mechanism**: pure documentation drift inside the file. The runtime signature is authoritative.

**Fix**: call with positional args as `(parent, name, wheelOptions, config)`, ignoring what the EmmyLua block implies. If you regenerate the annotations, fix the order.

### Click dispatch is asymmetric — `onClick` receives different first arguments depending on click path

Two paths call your `onClick`:

1. **Mouse released over empty ring space**: menu frame's `OnMouseUp` fires `ConfirmHoveredOption`, which calls `option.onClick(menu, option)` — first arg is the **menu frame**.
2. **Mouse clicked directly on the option button frame**: button's own `OnClick` fires `clickedOption.onClick(button, option)` — first arg is the **button**.

**Mechanism**: `CreateOptionButton` installs its own `OnClick` that hands `(clickedButton, clickedOption)` to `onClick`. The menu's `OnMouseUp` instead hands `(menu, option)`. Both paths can be exercised by the user — the buttons are children of the menu, but only the buttons that the cursor physically lands on receive the button-level click; cursor in the gap between buttons goes to the menu's `OnMouseUp`.

**Fix**: type-check the first argument inside `onClick`, or branch on `option` (the second arg, which is consistent), or store everything you need on `option` itself (recommended):

```lua
local onClick = function(_, option)
    -- ignore the first arg; the option is what matters
    doThing(option.value)
end
```

### `CreateOptionButton`'s `OnClick` does not nil-guard `onClick`

The button-level click handler does:

```lua
xpcall(clickedOption.onClick, geterrorhandler(), clickedButton, clickedOption)
```

— without checking that `clickedOption.onClick` is non-nil. Clicking a button whose option lacks `onClick` errors. `ConfirmHoveredOption` has the symmetric guard (`if option and option.onClick then`).

**Fix**: either always supply `onClick` for every option, or override `CreateOptionButton` with a guarded handler:

```lua
wheel.CreateOptionButton = function(self, parent, w, h)
    local btn = WheelMenuMixin.CreateOptionButton(self, parent, w, h)
    btn:SetScript("OnClick", function(b)
        local o = b.Option
        if o and o.onClick then xpcall(o.onClick, geterrorhandler(), b, o) end
    end)
    return btn
end
```

### `SetOptions` does not call `Refresh`

Replacing the option array updates `self.options` and nothing else — the visible buttons still reflect the previous options until you call `Refresh()`.

**Fix**: always pair them.

```lua
wheel:SetOptions(newOptions)
wheel:Refresh()
```

### `firstOptionAngle` is math-convention radians, not clock-convention degrees

A common reflex is "I want option 1 at 12 o'clock and slices to go clockwise." The defaults give you the first part (`math.pi * 0.5` is the top), but slices advance counterclockwise (option 2 is on the upper-left), because each subsequent angle is `firstOptionAngle + (i - 1) * sliceAngle` and `sin` is positive on the upper half going counterclockwise.

**Fix (clockwise layout)**: pass options in reverse order, or override `UpdateButtons` / `GetOptionIndexUnderCursor` together to subtract instead of add the slice step. Don't try to invert just one — the layout and the hit-test must agree, or hovering one slot highlights another.

### No "no selection" zone between buttons

Because `GetOptionIndexUnderCursor` divides the entire ring into equal slices, there is never an in-ring position that selects nothing. If your design wants gaps (slot 1, slot 2, gap, slot 3), you'll need to add an angular gap check after the index calculation, or define a hidden "spacer" option whose `onClick` is nil and whose `text`/`icon` are empty.

### Hover detection relies on `GetCenter()` being in screen space

The angle math uses `self:GetCenter()` as the pivot. `GetCenter()` returns coordinates in the frame's parent's coordinate system. Because `OpenAtCursor` re-anchors to `UIParent` and `GetCursorPosition` (DF helper) returns `UIParent`-relative coordinates, the two are consistent.

**Mechanism**: if you re-anchor the menu to some other frame's `bottomleft` (e.g. inside a scaled container), `GetCenter()` will return coordinates in that container's space, but `GetCursorPosition` will still return `UIParent`-relative — and angles will be wrong.

**Fix**: keep the menu anchored to `UIParent` while open. Don't reparent it mid-lifecycle. If you must, swap `GetCursorPosition` for the matching coordinate helper too.

### `frame_strata = "FULLSCREEN"` is intentional and high

The default strata is one above `"DIALOG"`. Any modal you draw with `"DIALOG"` or below will be under the wheel; anything at `"FULLSCREEN_DIALOG"` or `"TOOLTIP"` will be on top of it. If you wrap the wheel inside an options panel and the wheel disappears behind it, you've probably lowered its strata via `config.frame_strata`.

### `OnUpdate` is installed by `OpenAtCursor`, cleared by `CloseMenu` and `OnHide`

These three points cover every documented path. If you bypass them — e.g. by setting `OnUpdate` yourself, or replacing the `OnHide` script without forwarding to the original — you can either lose the hover tracking or leak a running OnUpdate on a hidden frame.

**Fix**: if you need your own `OnHide`, hook-chain it:

```lua
local origOnHide = wheel:GetScript("OnHide")
wheel:SetScript("OnHide", function(self)
    if origOnHide then origOnHide(self) end
    -- your code
end)
```

### `ResetAppearance` / `ApplyHoveredAppearance` are no-ops by default

Already covered above, but worth restating as a pitfall: the framework calls these on every hover transition, and the bare mixin does nothing. A wheel menu with no overrides has zero visual hover feedback — users see no indication of which slice is active. This is the single most common "looks broken" report you'll get from a first-time consumer.

**Fix**: see "Customizing appearance" above. Implement both — `ResetAppearance` for the leave path, `ApplyHoveredAppearance` for the enter path.

---

## Public method reference

| Method | Purpose |
|---|---|
| `SetOptions(options)` | Replace the option array. Does **not** refresh. |
| `GetOptions()` | Return the current option array. |
| `GetOption(index)` | Return the option at index. |
| `GetNumOptions()` | `#self.options`. |
| `Refresh()` | Rebind options to buttons (text, icon), clear hover, re-layout. Call after `SetOptions` or after any mutation to the option array. |
| `OpenAtCursor()` | Position the menu under the cursor, show it, start hover tracking. |
| `CloseMenu()` | Stop hover tracking, clear hover, hide. |
| `OnUpdate()` | Internal per-frame hover update. Called by the installed `OnUpdate` script. |
| `GetOptionIndexUnderCursor(cursorX, cursorY)` | Returns the 1-based option index for a screen position, or nil if the cursor is in the dead zone / outside the ring. |
| `SetHoveredButtonIndex(index)` | Set hovered index (or nil). Triggers `ResetAppearance` + `ApplyHoveredAppearance`. No-op when the index hasn't changed. |
| `ConfirmHoveredOption()` | If a hovered option has `onClick`, call it as `onClick(menu, option)` under `xpcall`. |
| `CreateOptionButton(parent, width, height)` | Pool-create a new option button. Appends to `optionButtons`. Override to skin. |
| `GetOptionButton(index, dontCreate)` | Fetch from pool, creating on demand unless `dontCreate` is truthy. |
| `GetAllOptionsButtons()` | The whole pool (including hidden entries). |
| `GetNumOptionButtonsCreated()` | `#optionButtons` — pool size, not visible count. |
| `HideUnusedButtons()` | Hide pool entries past `GetNumOptions()`. Called by `UpdateButtons`. |
| `UpdateButtons()` | Lay out the buttons around the ring and set their `SectorStart/EndAngle`. Called by `Refresh`. |
| `ResetAppearance()` | Hook: reset visual state of every button. No-op by default — override per instance. |
| `ApplyHoveredAppearance(button)` | Hook: apply hover visuals to one button. No-op by default — override per instance. |

---

## Usage Examples

### Basic — six radial actions

```lua
local DF = _G["DetailsFramework"]

local wheel = DF:CreateWheelMenu(UIParent, "MyWheelMenu", {
    {text = "Tank",   icon = 132280, onClick = function(_, opt) print(opt.text) end, value = "TANK"},
    {text = "Healer", icon = 135907, onClick = function(_, opt) print(opt.text) end, value = "HEALER"},
    {text = "DPS",    icon = 132331, onClick = function(_, opt) print(opt.text) end, value = "DAMAGER"},
    {text = "Mark",   icon = 137008, onClick = function(_, opt) print(opt.text) end, value = "MARK"},
    {text = "Ping",   icon = 132311, onClick = function(_, opt) print(opt.text) end, value = "PING"},
    {text = "Cancel", icon = 132338, onClick = function(_, opt) end,                 value = "CANCEL"},
})

wheel:Refresh()

-- bind to something:
SLASH_OPENWHEEL1 = "/wheel"
SlashCmdList.OPENWHEEL = function() wheel:OpenAtCursor() end
```

### Richer — skinned buttons + shared dispatcher

The two appearance hooks plus a single dispatcher that branches on `option.value`:

```lua
local DF = _G["DetailsFramework"]

local function onChoose(_, option)
    if     option.value == "TANK"    then setRole("TANK")
    elseif option.value == "HEALER"  then setRole("HEALER")
    elseif option.value == "DAMAGER" then setRole("DAMAGER")
    elseif option.value == "CANCEL"  then -- no-op
    end
end

local wheel = DF:CreateWheelMenu(UIParent, "RoleWheel", {
    {text = "Tank",    icon = 132280, value = "TANK",    onClick = onChoose},
    {text = "Healer",  icon = 135907, value = "HEALER",  onClick = onChoose},
    {text = "DPS",     icon = 132331, value = "DAMAGER", onClick = onChoose},
    {text = "Cancel",  icon = 132338, value = "CANCEL",  onClick = onChoose},
}, {
    inner_radius        = 50,
    outer_radius        = 180,
    option_button_width = 140,
    option_button_height = 28,
    first_option_angle  = math.pi * 0.5,  -- option 1 at top
    center_text         = "Choose role",
})

-- skin overrides: per-instance, called by SetHoveredButtonIndex on every transition
wheel.ResetAppearance = function(self)
    for _, btn in ipairs(self:GetAllOptionsButtons()) do
        btn.Text:SetTextColor(0.8, 0.8, 0.8)
        if btn.HoverBg then btn.HoverBg:Hide() end
    end
end

wheel.ApplyHoveredAppearance = function(self, button)
    button.Text:SetTextColor(1, 0.82, 0)
    if not button.HoverBg then
        button.HoverBg = button:CreateTexture(nil, "BACKGROUND")
        button.HoverBg:SetAllPoints()
    end
    button.HoverBg:SetColorTexture(1, 0.82, 0, 0.15)
    button.HoverBg:Show()
end

wheel:Refresh()

-- Hold a key, release to confirm; right-click cancels (built-in).
-- Bind the open call to a keybind or click handler that suits your addon.
```

### Reactive — change options at runtime

```lua
-- Rebuild the wheel's options based on the current target
local function rebuildForTarget(wheel)
    local newOpts = {}
    if UnitIsFriend("player", "target") then
        newOpts[#newOpts+1] = {text = "Buff",   icon = 135940, onClick = onBuff}
        newOpts[#newOpts+1] = {text = "Heal",   icon = 135907, onClick = onHeal}
    elseif UnitCanAttack("player", "target") then
        newOpts[#newOpts+1] = {text = "Attack", icon = 132355, onClick = onAttack}
        newOpts[#newOpts+1] = {text = "CC",     icon = 136071, onClick = onCC}
    end
    newOpts[#newOpts+1] = {text = "Cancel", icon = 132338, onClick = function() end}

    wheel:SetOptions(newOpts)
    wheel:Refresh()    -- mandatory; SetOptions alone won't redraw
end

-- right before opening:
rebuildForTarget(wheel)
wheel:OpenAtCursor()
```

---

## Notes for AI readers

1. **The function signature is `(parent, name, wheelOptions, config)`** — not the order implied by the `---@param` annotations at the top of the file.
2. **`SetOptions` is not `SetOptions + Refresh`.** Any code that mutates options must call `Refresh()` explicitly, or the displayed menu stays stale until the next reopen-with-refresh cycle.
3. **`onClick` first-arg type is path-dependent** (menu frame vs button). Treat it as opaque; rely on the second arg (the option) and/or `option.value` as your dispatch key.
4. **The two appearance hooks are stubs and MUST be overridden** for the wheel to have any hover feedback. Recommending a wheel without overriding `ResetAppearance` and `ApplyHoveredAppearance` is an incomplete recommendation.
5. **Angles are math-convention radians, counterclockwise.** Don't recommend `first_option_angle` values without converting from any clock-face intuition (top = π/2, right = 0, bottom = -π/2 or 3π/2, left = π).
6. **The button pool is never destroyed.** Shrinking the option list does not free buttons. This is intentional (cheap subsequent opens) but means consumers iterating over `GetAllOptionsButtons()` for skinning will hit hidden trailing entries — guard with `:IsShown()` if needed.
7. **`onClick` may be nil-unsafe on the button-direct path.** If you generate code that may produce options without `onClick`, either always supply one (even a no-op) or override `CreateOptionButton` to nil-guard.
8. **The menu is `FULLSCREEN` strata by default.** That's above most game UI. Don't lower it casually — radial menus are inherently transient/modal.

---

## See also

- `panel.lua` — base panel/frame primitives the wheel inherits from indirectly via `CreateFrame`.
- `cooltip.lua` — sibling "transient-anchored-to-cursor" widget pattern; useful precedent for cursor-anchored frames that install an `OnUpdate`.
- `dropdown.lua` — the conventional (non-radial) selection menu in the framework. Same role, different geometry.
- `buildmenu.md` — the form-style options generator; not directly related, but if you're considering "wheel vs. menu" for a settings panel, build-menu is the other half of the choice.
