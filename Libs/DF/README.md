# LibDFramework-1.0 (Details Framework)

**LibDFramework-1.0**, also referred to as **Details Framework** or **DF**, is a UI and addon framework for World of Warcraft addons. It is currently used by several addons including Plater Nameplates, World Quest Tracker, Details!, and many more.

- **Library name (LibStub):** `DetailsFramework-1.0`
- **Global table:** `_G["DetailsFramework"]` (also reachable as `DetailsFramework`)
- **Author:** Terciob
- **CurseForge page:** https://www.curseforge.com/wow/addons/libdframework
- **Shipped with:** Several addons use the framework for fast and easy addon development.
- **License:** GNU LGPL 2.1 (see [LICENSE](LICENSE)). Addons that embed the framework keep their own license — LGPL only covers modifications to the framework files themselves. If you make improvements, send a pull request to the GitHub repository so all users can benefit from the changes.

This framework provides high-level building blocks for in-game UI: panels, buttons, dropdowns, sliders, scroll boxes, tooltips (Cooltip), tab containers, charts, timelines, time bars, unit frames, an addon scaffolding system with profile management, and more. 

---

## Loading the framework
You need a copy of the framework in your project; it can be in any folder but is usually placed in `Libs\DetailsFramework\`.

You can:
- Download it and place it there.
- Use the file `.pkgmeta` in the root folder of your project (create one if it doesn't exist) to make the CurseForge packager download the library for you.
- Fork the library's repository and embed your fork in a folder in your project.

In your project's `.toc` file, add the line that loads the framework — place it before your own files: `Libs\DetailsFramework\load.xml`

The framework is a [LibStub](https://www.wowace.com/projects/libstub) library:

```lua
local DF = LibStub("DetailsFramework-1.0")
```

It also exposes itself on the global table during initialization:

```lua
local DF = _G["DetailsFramework"]
```

Both references point to the same table.

---

## Quickstart examples

### Create a panel (frame with template)

```lua
local DF = _G["DetailsFramework"]

local panel = DF:CreateSimplePanel(UIParent, 400, 300, "My Panel Title", "MyAddonMainPanel")
panel:SetPoint("center")
panel:Show()
```

### Create a button

```lua
local function onClick(self, button, value)
    print("clicked", value)
end

local btn = DF:CreateButton(panel, onClick, 120, 24, "Click Me", "myValue")
btn:SetPoint("topleft", panel, "topleft", 10, -40)
```

### Create a scroll box (line-based list)

```lua
local lineHeight = 20
local lineAmount = 10

local refreshFunc = function(self, data, offset, totalLines)
    for i = 1, totalLines do
        local index = i + offset
        local thisData = data[index]
        if (thisData) then
            local line = self:GetLine(i)
            line.NameText:SetText(thisData.name)
        end
    end
end

local createLineFunc = function(self, index)
    local line = CreateFrame("button", "$parentLine" .. index, self)
    line:SetPoint("topleft", self, "topleft", 0, -lineHeight * (index - 1))
    line:SetSize(200, lineHeight)
    line.NameText = line:CreateFontString(nil, "overlay", "GameFontNormal")
    line.NameText:SetPoint("left", line, "left", 2, 0)
    return line
end

local data = { {name = "Alpha"}, {name = "Beta"}, {name = "Gamma"} }
local scroll = DF:CreateScrollBox(panel, "$parentScroll", refreshFunc, data, 200, 200, lineAmount, lineHeight)
for i = 1, lineAmount do
    scroll:CreateLine(createLineFunc)
end
scroll:Refresh()
```

See [scrollbox.md](scrollbox.md) for the full scrollbox API including grid, aura, data, boss-selector, and canvas variants. The canvas scrollbox supports smooth scrolling, momentum / inertia, velocity-based acceleration, and click-and-drag scrolling.

### Create a dropdown

```lua
local dropdownFunc = function()
    return {
        {label = "Option A", value = "a", onclick = function() print("a") end},
        {label = "Option B", value = "b", onclick = function() print("b") end},
    }
end

local dropdown = DF:CreateDropDown(panel, dropdownFunc, "a", 160, 20, "myDropdown", "$parentDropdown")
dropdown:SetPoint("center")
```

### Create a slider

```lua
local onValueChanged = function(self, fixedValue, value)
    print("new value", value)
end

local slider = DF:CreateSlider(panel, 160, 20, 0, 100, 1, 50, false, "$parentSlider", "mySlider", "Volume", DF:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE"))
slider:SetPoint("topleft", panel, "topleft", 10, -80)
slider:SetHook("OnValueChanged", onValueChanged)
```

### Create a build-menu (form generator)

```lua
local menuOptions = {
    {type = "label", get = function() return "Settings:" end, text_template = DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")},
    {type = "toggle", get = function() return MyAddonDB.enabled end, set = function(self, fixedParam, value) MyAddonDB.enabled = value end, name = "Enable Feature"},
    {type = "range", get = function() return MyAddonDB.size end, set = function(self, fixedParam, value) MyAddonDB.size = value end, min = 1, max = 100, step = 1, name = "Size"},
    {type = "color", get = function() return MyAddonDB.color end, set = function(self, r, g, b, a) MyAddonDB.color = {r, g, b, a} end, name = "Color"},
}

DF:BuildMenu(panel, menuOptions, 10, -40, 250, true, DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE"), DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"), DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"), DF:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE"), DF:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE"))
```

See [buildmenu.md](buildmenu.md) and [buildmenu_search.md](buildmenu_search.md) for the full menu system.

### Create an addon with profiles

```lua
local DF = _G["DetailsFramework"]

local defaultProfile = {
    text_color = {1, 1, 1, 1},
    enabled = true,
    threshold = 50,
}

local addon = DF:CreateNewAddOn("MyAddon", "MyAddonDB", defaultProfile)

addon.OnLoad = function(self)
    -- ADDON_LOADED has fired, profile is ready
    local profile = self.profile
    print("loaded with threshold", profile.threshold)
end

addon.OnInit = function(self)
    -- PLAYER_LOGIN has fired
end
```

See [addon.md](addon.md) and [savedvars.md](savedvars.md) for the addon scaffolding and profile system.

---

## Module index

Each module has its own focused documentation file. The framework is split into ~70 Lua modules organised by concern.

### Core / framework

| Module | Description | Docs |
|---|---|---|
| `fw.lua` | Library entry point. Defines `DetailsFramework-1.0` via LibStub. Hosts `DF.AuthorInfo`, version, build info, dispatch helpers. | — |
| `mixins.lua` | Mixin helpers (`DF:Mixin(target, mixin)`). Used to attach methods from a `*Mixin` table onto a frame. | — |
| `definitions.lua` | LuaCATS / EmmyLua type annotations (`---@class detailsframework`, etc.). | — |
| `helpers.md` | `DF.table.*`, `DF.Math.*`, parsing utilities, dispatch helpers. | [helpers.md](helpers.md) |
| `math.lua` | Numeric helpers — vectors, nine-points, clamping, truncation. | — |

### Widgets

| Module | Description | Docs |
|---|---|---|
| Panel / Frame | Containers, simple panels, generic backdrops. | [frames.md](frames.md), [containers.md](containers.md) |
| Button | `DF:CreateButton(parent, callback, w, h, text, ...)`. | [button.md](button.md) |
| Dropdown | `DF:CreateDropDown(parent, optionsFunc, default, w, h, ...)`. Menu-driven option selectors. | [dropdown.md](dropdown.md) |
| Slider | `DF:CreateSlider(parent, w, h, min, max, step, default, isDecimal, ...)`. | [slider.md](slider.md) |
| TextEntry | `DF:CreateTextEntry(parent, callback, w, h, ...)`. | [textentry.md](textentry.md) |
| Label | `DF:CreateLabel(parent, text, size, color, ...)`. | [label.md](label.md) |
| Picture (texture) | `DF:CreatePicture(parent, ...)`. | [picture.md](picture.md) |
| Icon | Generic icon and atlas-aware icon helpers. | [icon.md](icon.md), [icongeneric.md](icongeneric.md), [icon-row.md](icon-row.md), [icon-row-generic.md](icon-row-generic.md) |
| Header | Column header for table views, with sorting hooks. | [header.md](header.md) |
| Tab Container | Multi-tab UI with content frames per tab. | [tabcontainer.md](tabcontainer.md) |
| Scroll Box | Multiple variants — list, grid, aura, data scroll, boss selector, canvas (with smooth/momentum/drag scrolling). | [scrollbox.md](scrollbox.md) |
| Cooltip | `DF.GameCooltip` — replacement for GameTooltip with line-by-line rich content. | [cooltip.md](cooltip.md) |
| Time Bar | Cooldown / duration bar. | [timebar.md](timebar.md) |
| Timeline | Horizontal timeline visualization with rows of events. | [timeline.md](timeline.md) |
| Charts | Line / area chart rendering. | [charts.md](charts.md) |
| Unit Frame | Health / power frames bound to unit IDs. | [unitframe.md](unitframe.md) |
| Keybind UI | Keybind capture widgets. | [keybind.md](keybind.md) |
| Anchor System | Visual anchoring helpers (nine-point selector, anchor frames). | [anchorsystem.md](anchorsystem.md) |

### Addon infrastructure

| Module | Description | Docs |
|---|---|---|
| `addon.lua` | `DF:CreateNewAddOn(name, savedVarsName, defaultProfile)` — addon object with lifecycle hooks (`OnLoad`, `OnInit`, `OnReady`). | [addon.md](addon.md) |
| `savedvars.lua` | Profile management: create, switch, copy, delete profiles. Includes a ready-made profile management panel. | [savedvars.md](savedvars.md) |
| `schedules.lua` | `DF.Schedules.NewTimer`, recurring tasks. | [schedules.md](schedules.md) |
| `packtable.lua` | Compact serialization helpers for table data (used for sharing strings between players). | [packtable.md](packtable.md) |
| `languages.lua` | Locale/translation table helpers. | [languages.md](languages.md) |
| `ejournal.lua` | Encounter Journal accessors for boss/dungeon data. | [ejournal.md](ejournal.md) |
| `elapsedtime.lua` | Elapsed-time tracker (used by Details! plugins). | [elapsedtime.md](elapsedtime.md) |
| `DFPixelUtil.lua` | Pixel-perfect scaling helpers. | [DFPixelUtil.md](DFPixelUtil.md) |
| `pools.md` | Object pooling for frame reuse. | [pools.md](pools.md) |

### Build menu (form generator)

| Module | Description | Docs |
|---|---|---|
| `buildmenu.lua` | `DF:BuildMenu(parent, options, x, y, height, useScrollFrame, ...)` — declarative form construction from option tables. Supports `label`, `toggle`, `range`, `color`, `dropdown`, `textentry`, `button`, `select`, `execute`, `blank`. | [buildmenu.md](buildmenu.md), [buildmenu_search.md](buildmenu_search.md) |

Each documented module also has a corresponding `*.examples.lua` file in this directory with runnable usage examples (e.g. `button.examples.lua`, `scrollbox.examples.lua`, `cooltip.examples.lua`, etc.).

---

## Conventions

### Public API surface

All public functions are accessed through the `DF` table (or `detailsFramework` — both refer to the same library):

```lua
DF:CreateButton(parent, callback, width, height, text, ...)
DF:CreateScrollBox(parent, name, refreshFunc, data, width, height, lineAmount, lineHeight, ...)
DF:CreateNewAddOn(addonName, globalSavedVariablesName, savedVarsTemplate)
DF:Mixin(target, mixin)
DF:Dispatch(func, ...)
DF.table.copy(source)
DF.Math.GetNinePoints(frame)
DF.GameCooltip:Reset()
```

Methods that return a widget are typically named `Create<Widget>` and accept the parent frame as their first argument.

### Type annotations (LuaCATS / EmmyLua)

The framework uses LuaCATS-style annotations consistently. Every widget has a class:

```lua
---@class df_button : button
---@class df_scrollbox : scrollframe, df_sortmixin, df_scrollboxmixin
---@class df_addon : table
---@class df_canvasscrollbox : scrollframe, df_optionsmixin, df_canvasscrollboxmixin
```

Internal types use a `df_` prefix. Mixins use a `*Mixin` suffix on the table and a `df_<name>mixin` class annotation.

### Mixins

The `*Mixin` pattern is used widely:

```lua
DF.SortFunctions = { Sort = function(self, ...) ... end }
DF.ScrollBoxFunctions = { Refresh = function(self) ... end, ... }
DF.CanvasScrollBoxMixin = { SetScrollSpeed = function(self, n) ... end, ... }

-- Applied like this:
DF:Mixin(targetFrame, DF.SortFunctions)
DF:Mixin(targetFrame, DF.ScrollBoxFunctions)
```

Each mixin is a plain table of methods. `DF:Mixin(target, mixin)` copies them onto the target.

### Templates

Recurring visual styles (font, button, dropdown, slider, switch) live in template tables retrieved via `DF:GetTemplate(category, templateName)`:

```lua
local optionsFontTemplate = DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
local optionsButtonTemplate = DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")
local optionsSliderTemplate = DF:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
```

Custom templates can be installed with `DF:InstallTemplate(category, name, templateTable, parentName)`.

### Dispatch (safe pcall)

`DF:Dispatch(func, ...)` wraps `func` in `xpcall(func, geterrorhandler(), ...)`. Used internally for any user-supplied callback so that user errors don't break framework loops.

### `DF.table` helpers

```lua
DF.table.copy(target, source)         -- shallow copy
DF.table.deploy(target, defaults)     -- fills missing keys from defaults
DF.table.getfrompath(t, "a.b.c")      -- nested table access by string path
DF.table.setfrompath(t, "a.b.c", v)
DF.table.dump(t)                       -- pretty-print a table
```

---

## Used by

The framework is loaded into a single shared LibStub slot, so multiple addons can embed it without conflict — only the highest version loads.

Known consumers (non-exhaustive):

- **`Details!` Damage Meter** — the host addon. Uses the framework throughout for breakdown windows, options panels, and plugin UIs.
- **`Plater Nameplates`** — uses `Plater_Designer` (consumes `DF:CreateEditor`, `DF:CreateScrollBox`, `DF:CreateDropDown`, `DF:BuildMenu`, etc.) for its layout/profile editor.
- **`OpenRaid` library** — uses `DF.Schedules` and `DF.table` helpers.

If you embed this framework in your own addon, the recommended pattern is to copy `Libs/DF/` into your addon and reference `Libs\DF\LibDFramework-1.0.toc` from your `.toc` file before your own files. LibStub will keep only the highest-versioned copy active.

---

## Source layout

```
Libs/DF/
  LibDFramework-1.0.toc      -- TOC entry point
  load.xml                    -- file load order
  fw.lua                      -- library bootstrap (LibStub registration)
  definitions.lua             -- LuaCATS type definitions
  mixins.lua                  -- Mixin helper
  helpers.md                  -- DF.table, DF.Math, dispatch
  panel.lua / frames.lua      -- container frames
  containers.lua              -- box / inset containers
  button.lua                  -- buttons
  dropdown.lua                -- dropdowns
  slider.lua                  -- sliders
  textentry.lua               -- text entries
  label.lua                   -- labels (FontStrings + alignment)
  picture.lua                 -- texture widgets
  icon.lua / icongeneric.lua  -- icon widgets
  header.lua                  -- table headers
  tabcontainer.lua            -- tabbed UIs
  scrollbox.lua               -- scroll boxes (list/grid/aura/data/boss/canvas)
  cooltip.lua                 -- GameCooltip replacement
  timebar.lua                 -- cooldown / duration bars
  timeline.lua                -- timeline visualization
  charts.lua                  -- chart rendering
  unitframe.lua               -- unit frames
  keybind.lua                 -- keybind UI
  anchorsystem.lua            -- anchor frames + nine-point system
  addon.lua                   -- df_addon (CreateNewAddOn)
  savedvars.lua               -- profile management
  schedules.lua               -- timers / recurring tasks
  packtable.lua               -- table packing/serialization
  languages.lua               -- localisation tables
  ejournal.lua                -- encounter journal access
  elapsedtime.lua             -- elapsed-time tracker
  buildmenu.lua               -- declarative form generator
  editor.lua                  -- profile editor (used by Plater_Designer)
  DFPixelUtil.lua             -- pixel-perfect scaling
  math.lua                    -- vector / geometry helpers
  colors.lua                  -- color tables
  pools.md                    -- object pooling
  *.examples.lua              -- runnable usage examples
  *.md                        -- per-module documentation
  *.xml                       -- frame templates / inheritance trees
```

---

## Related documentation

- [scrollbox.md](scrollbox.md) — scrollbox system (list, grid, aura, data, boss, canvas; smooth/momentum/drag scrolling).
- [buildmenu.md](buildmenu.md), [buildmenu_search.md](buildmenu_search.md) — declarative menu generator.
- [addon.md](addon.md), [savedvars.md](savedvars.md) — addon scaffolding and profile management.
- [cooltip.md](cooltip.md) — `DF.GameCooltip` rich tooltip system.
- [helpers.md](helpers.md) — `DF.table`, `DF.Math`, dispatch.
- [tabcontainer.md](tabcontainer.md) — tabbed UI containers.
- [timebar.md](timebar.md), [timeline.md](timeline.md), [charts.md](charts.md) — visualization widgets.
- [unitframe.md](unitframe.md) — unit frame widgets.

---

## Versioning

The library is version-stamped by `dversion` in `fw.lua`. LibStub will only activate the highest version present at load time. When making a fork or modification, increment `dversion` to ensure your version is preferred.

```lua
local dversion = 726
local major, minor = "DetailsFramework-1.0", dversion
local DF, oldminor = LibStub:NewLibrary(major, minor)
```

---

## Reporting issues / contributing

This framework lives inside the `Details!` addon repository. Issues and PRs go through the `Details!` project on its hosting platform (CurseForge / WoWInterface / GitHub mirror, depending on where the upstream maintainer publishes).

The framework is authored and maintained by **Terciob**.
