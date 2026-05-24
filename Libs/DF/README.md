# LibDFramework-1.0 (Details Framework)
*`LibDFramework-1.0` — commonly called **Details Framework** or **DF** — is a Lua library for the World of Warcraft addon environment. It provides a widget toolkit built on Blizzard's native frame API and an optional scaffold for creating self-contained addons with saved-variable profiles and an options panel.

It is the UI substrate used by `Details!` Damage Meter, Plater Nameplates, World Quest Tracker, OpenRaid, and a number of other published addons.

## Identifiers

| Field | Value |
|---|---|
| Library name (LibStub major) | `DetailsFramework-1.0` |
| Global symbol | `DetailsFramework` (also `_G["DetailsFramework"]`) |
| Conventional embed folder | `Libs\DetailsFramework\` (folder name is at the embedder's discretion; `Libs\DF\` is also common) |
| Maintainer | Terciob |
| Canonical repository | https://github.com/Tercioo/Details-Framework |
| Distribution | https://www.curseforge.com/wow/addons/libdframework |
| License | GNU LGPL 2.1 (see [LICENSE](LICENSE)). Embedders retain their own license on their own code; LGPL governs modifications to framework files. Upstream contributions are welcome via pull request. |

---

## What this library is

DF supplies two layers that callers consume independently:

1. **Widget toolkit.** A collection of constructor functions (`DF:CreateButton`, `DF:CreateDropDown`, `DF:CreateSlider`, `DF:CreateScrollBox`, `DF:CreateGraphicMultiLineFrame`, etc.) that return enriched Blizzard frames. Widgets cooperate with any addon style.
2. **Addon scaffold.** A single entry point, `DF:CreateNewAddOn`, that returns a pre-wired addon object with two lifecycle hooks (`OnLoad`, fired on `ADDON_LOADED`; `OnInit`, fired on `PLAYER_LOGIN`), profile management, and a Blizzard-style options panel.

DF is sufficient on its own — an addon can be written using only DF's API, with no other framework involved.

---

## Acquiring the library

The framework is a LibStub library. Either of the following retrieves the same table:

```lua
local DF = LibStub("DetailsFramework-1.0")
-- or
local DF = DetailsFramework
```

Both references point to the identical table. Use whichever is conventional for your addon.

To embed in your own project, place the library folder inside your addon (commonly `Libs\DetailsFramework\`) and load it before your own files by referencing its `load.xml` from your `.toc`:

```
Libs\DetailsFramework\load.xml
```

Multiple embedders can coexist: LibStub keeps only the highest-versioned copy active.

---

## Public API surface (overview)

| Concern | Primary entry points |
|---|---|
| Panels & containers | `DF:CreateSimplePanel`, `DF:CreateRoundedPanel` |
| Interactive controls | `DF:CreateButton`, `DF:CreateDropDown`, `DF:CreateSlider`, `DF:CreateSwitch`, `DF:CreateTextEntry`, `DF:CreateColorPickButton` |
| Static display | `DF:CreateLabel`, `DF:CreatePicture`, `DF:CreateImage`, `DF:CreateBar`, `DF:CreateSplitBar` |
| Lists & tables | `DF:CreateScrollBox` (variants: list, grid, aura, data, boss, canvas), `DF:CreateScrollBar` |
| Tooltips & overlays | `DF.GameCooltip` (alternative for `GameTooltip`), `DF:CreateBorder`, `DF:CreateGlowOverlay`, `DF:CreateAnts` |
| Visualizations | `DF:CreateGraphicMultiLineFrame` (chart), time bars, timelines |
| Tabbed UI | `DF:CreateTabContainer` |
| Declarative options | `DF:BuildMenu` (generates an options panel from a table) |
| Templates | `DF:GetTemplate`, `DF:InstallTemplate` |
| Animation | `DF:CreateAnimationHub`, `DF:CreateAnimation`, `DF:CreateFlashAnimation`, `DF:CreateFrameShake` |
| Addon lifecycle | `DF:CreateNewAddOn(name, savedVarsName, defaultProfile)` |
| Safe dispatch | `DF:Dispatch(func, ...)` (xpcall wrapper for user callbacks) |
| Mixins | `DF:Mixin(target, mixinTable)` |
| Type helpers | `DF.table.copy/deploy/getfrompath/setfrompath/dump`, `DF.Math.*`, `DF.FormatNumber`, `DF.CommaValue` |

Each entry point is documented in detail in its corresponding `*.md` file in this directory and demonstrated in the matching `*.examples.lua` file.

---

## Examples

Each example below is self-contained: copy it into a fresh `.lua` file loaded by your addon and it will run.

### Panel

```lua
local DF = DetailsFramework

local panel = DF:CreateSimplePanel(UIParent, 400, 300, "My Panel Title", "MyAddonMainPanel")
panel:SetPoint("center")
panel:Show()
```

### Button

```lua
local DF = DetailsFramework

local panel = DF:CreateSimplePanel(UIParent, 400, 300, "Button Demo", "MyAddonButtonDemo")
panel:SetPoint("center")

local function onClick(self, mouseButton, value)
    print("clicked", value)
end

local btn = DF:CreateButton(panel, onClick, 120, 24, "Click Me", "myValue")
btn:SetPoint("topleft", panel, "topleft", 10, -40)
```

### Scroll box (line-based list)

```lua
local DF = DetailsFramework

local panel = DF:CreateSimplePanel(UIParent, 240, 240, "List", "MyAddonListDemo")
panel:SetPoint("center")

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
scroll:SetPoint("topleft", panel, "topleft", 10, -30)
for i = 1, lineAmount do
    scroll:CreateLine(createLineFunc)
end
scroll:Refresh()
```

See [scrollbox.md](scrollbox.md) for grid, aura, data, boss-selector, and canvas variants (the canvas variant supports smooth scrolling, momentum, and click-and-drag).

### Dropdown

```lua
local DF = DetailsFramework

local panel = DF:CreateSimplePanel(UIParent, 240, 120, "Dropdown", "MyAddonDropdownDemo")
panel:SetPoint("center")

local dropdownFunc = function()
    return {
        {label = "Option A", value = "a", onclick = function() print("a") end},
        {label = "Option B", value = "b", onclick = function() print("b") end},
    }
end

local dropdown = DF:CreateDropDown(panel, dropdownFunc, "a", 160, 20, "myDropdown", "$parentDropdown")
dropdown:SetPoint("center")
```

### Slider

```lua
local DF = DetailsFramework

local panel = DF:CreateSimplePanel(UIParent, 240, 120, "Slider", "MyAddonSliderDemo")
panel:SetPoint("center")

local onValueChanged = function(self, fixedValue, value)
    print("new value", value)
end

local sliderTemplate = DF:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
local slider = DF:CreateSlider(panel, 160, 20, 0, 100, 1, 50, false, "$parentSlider", "mySlider", "Volume", sliderTemplate)
slider:SetPoint("center")
slider:SetHook("OnValueChanged", onValueChanged)
```

### Declarative options menu

```lua
local DF = DetailsFramework

MyAddonDB = MyAddonDB or { enabled = true, size = 50, color = {1, 1, 1, 1} }

local panel = DF:CreateSimplePanel(UIParent, 320, 280, "Options", "MyAddonOptions")
panel:SetPoint("center")

local menuOptions = {
    {type = "label",
     get  = function() return "Settings:" end,
     text_template = DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")},

    {type = "toggle",
     get  = function() return MyAddonDB.enabled end,
     set  = function(self, fixedParam, value) MyAddonDB.enabled = value end,
     name = "Enable Feature"},

    {type = "range",
     get  = function() return MyAddonDB.size end,
     set  = function(self, fixedParam, value) MyAddonDB.size = value end,
     min  = 1, max = 100, step = 1,
     name = "Size"},

    {type = "color",
     get  = function() return MyAddonDB.color end,
     set  = function(self, r, g, b, a) MyAddonDB.color = {r, g, b, a} end,
     name = "Color"},
}

DF:BuildMenu(
    panel, menuOptions, 10, -40, 250, true,
    DF:GetTemplate("font",     "OPTIONS_FONT_TEMPLATE"),
    DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"),
    DF:GetTemplate("button",   "OPTIONS_BUTTON_TEMPLATE"),
    DF:GetTemplate("slider",   "OPTIONS_SLIDER_TEMPLATE"),
    DF:GetTemplate("switch",   "OPTIONS_CHECKBOX_TEMPLATE")
)
```

See [buildmenu.md](buildmenu.md) and [buildmenu_search.md](buildmenu_search.md) for the full type catalogue (`label`, `toggle`, `range`, `color`, `dropdown`, `textentry`, `button`, `select`, `execute`, `blank`).

### Addon scaffold with profiles

```lua
local DF = DetailsFramework

local defaultProfile = {
    text_color = {1, 1, 1, 1},
    enabled    = true,
    threshold  = 50,
}

local addon = DF:CreateNewAddOn("MyAddon", "MyAddonDB", defaultProfile)

addon.OnLoad = function(self)
    -- ADDON_LOADED has fired; self.profile is populated.
    local profile = self.profile
    print("loaded with threshold", profile.threshold)
end

addon.OnInit = function(self)
    -- PLAYER_LOGIN has fired.
end
```

See [addon.md](addon.md) and [savedvars.md](savedvars.md).

---

## Module index

The library is composed of roughly 70 Lua modules. Each module focuses on one concern and ships with a matching `*.md` reference and a `*.examples.lua` file containing runnable usage.

### Core

| Module | Description | Reference |
|---|---|---|
| `fw.lua` | Library entry point. Registers `DetailsFramework-1.0` via LibStub. Hosts versioning, dispatch helpers, and shared state. | [fw.md](fw.md) |
| `mixins.lua` | The `DF:Mixin(target, mixinTable)` helper used to copy methods from a mixin table onto a frame. | — |
| `definitions.lua` | LuaCATS / EmmyLua type annotations consumed by Lua language servers. | — |
| `helpers.md` | `DF.table.*`, `DF.Math.*`, string and dispatch helpers. | [helpers.md](helpers.md) |
| `math.lua` | Vector and geometry primitives, nine-points, clamping, truncation. | [math.md](math.md) |

### Widgets

| Module | Description | Reference |
|---|---|---|
| Panel / Frame | Containers, simple panels, generic backdrops, rounded panels. | [frames.md](frames.md), [containers.md](containers.md), [rounded_panel.md](rounded_panel.md), [frame_helpers.md](frame_helpers.md) |
| Button | `DF:CreateButton(parent, callback, w, h, text, ...)`. | [button.md](button.md) |
| Dropdown | `DF:CreateDropDown(parent, optionsFunc, default, w, h, ...)`. | [dropdown.md](dropdown.md) |
| Slider | `DF:CreateSlider(parent, w, h, min, max, step, default, isDecimal, ...)`. | [slider.md](slider.md) |
| Text entry | `DF:CreateTextEntry(parent, callback, w, h, ...)`. | [textentry.md](textentry.md) |
| Label | `DF:CreateLabel(parent, text, size, color, ...)`. | [label.md](label.md) |
| Picture / texture | `DF:CreatePicture(parent, ...)`. | [picture.md](picture.md) |
| Icon | Generic icon and atlas-aware icon helpers, plus icon-rows. | [icon.md](icon.md), [icongeneric.md](icongeneric.md), [icon-row.md](icon-row.md), [icon-row-generic.md](icon-row-generic.md) |
| Header | Column header for table views with sort hooks. | [header.md](header.md) |
| Tab container | Multi-tab UI with one content frame per tab. | [tabcontainer.md](tabcontainer.md) |
| Scroll box | Variants: list, grid, aura, data, boss-selector, canvas (smooth / momentum / drag scrolling). | [scrollbox.md](scrollbox.md), [scrollbar.md](scrollbar.md) |
| Cooltip | `DF.GameCooltip` — line-by-line rich tooltip alternative for `GameTooltip`. | [cooltip.md](cooltip.md) |
| Time bar | Cooldown / duration bars. | [timebar.md](timebar.md), [normal_bar.md](normal_bar.md), [split_bar.md](split_bar.md) |
| Timeline | Horizontal timeline visualization with rows of events. | [timeline.md](timeline.md) |
| Line indicator | Vertical / horizontal indicator lines. | [line_indicator.md](line_indicator.md) |
| Charts | `DF:CreateGraphicMultiLineFrame` — multi-line chart with per-line color, SMA / LOESS smoothing, axes, backdrop indicators, async drawing. | [charts.md](charts.md) |
| Unit frame | Health / power frames bound to unit IDs. | [unitframe.md](unitframe.md) |
| Keybind control panel | Widget for setting up keyboard shortcuts. | [keybind.md](keybind.md) |
| Auras | Aura display helpers. | [auras.md](auras.md) |
| Editor | Profile / layout editor with real-time preview. | [editor.md](editor.md) |
| Wheel menu | Radial menu widget. | [wheelmenu.md](wheelmenu.md) |
| Anchor system | Visual anchoring helpers, nine-point selector. | [anchorsystem.md](anchorsystem.md) |
| Item info | Item / equipment data helpers. | [iteminfo.md](iteminfo.md) |

### Forms & menus

| Module | Description | Reference |
|---|---|---|
| `buildmenu.lua` | `DF:BuildMenu(parent, options, x, y, height, useScrollFrame, ...)` — declarative form construction. | [buildmenu.md](buildmenu.md), [buildmenu_search.md](buildmenu_search.md) |
| `loadconditions.lua` | Conditional load-out helpers (specialisation / talent / class gating). | [loadconditions.md](loadconditions.md) |

### Addon infrastructure

| Module | Description | Reference |
|---|---|---|
| `addon.lua` | `DF:CreateNewAddOn(name, savedVarsName, defaultProfile)` — addon object with `OnLoad` (fired on `ADDON_LOADED`) and `OnInit` (fired on `PLAYER_LOGIN`). | [addon.md](addon.md) |
| `savedvars.lua` | Profile management — create, switch, copy, delete profiles. Ships a reusable profile-management panel. | [savedvars.md](savedvars.md) |
| `schedules.lua` | `DF.Schedules.NewTimer`, recurring tasks, lazy execute. | [schedules.md](schedules.md) |
| `packtable.lua` | Compact serialization for table data (used for sharing strings between players). | [packtable.md](packtable.md) |
| `languages.lua` | Localization table helpers. | [languages.md](languages.md) |
| `ejournal.lua` | Encounter Journal access for boss / dungeon metadata. | [ejournal.md](ejournal.md) |
| `elapsedtime.lua` | Elapsed-time tracker used by `Details!` plugins. | [elapsedtime.md](elapsedtime.md) |
| `DFPixelUtil.lua` | Pixel-perfect scaling helpers. | [DFPixelUtil.md](DFPixelUtil.md) |
| `pools.md` | Object pooling for frame reuse. | [pools.md](pools.md) |

---

## Vocabulary

The codebase uses a small number of recurring terms with specific meanings. They appear unprefixed in source comments and prefixed with `df_` in type annotations.

| Term | Meaning |
|---|---|
| **Widget** | A Blizzard frame enriched by a `DF:Create*` constructor. Returned to the caller; the caller anchors and parents it like any frame. |
| **Mixin** | A plain Lua table whose method entries are copied onto a target frame by `DF:Mixin(target, mixinTable)`. The codebase exposes named mixins such as `DF.SortFunctions`, `DF.ScrollBoxFunctions`, `DF.CanvasScrollBoxMixin`. |
| **Template** | A table of visual properties (font, button, slider, dropdown, switch) retrieved via `DF:GetTemplate(category, templateName)`. Custom templates can be installed with `DF:InstallTemplate(category, name, table, parentName)`. |
| **Dispatch** | The call-pattern `DF:Dispatch(func, ...)`, which wraps `func` in `xpcall(func, geterrorhandler(), ...)`. Used internally for every user-supplied callback so a caller error does not break framework loops. |
| **Cooltip** | The custom tooltip system exposed as `DF.GameCooltip`. A drop-in alternative to `GameTooltip` supporting line-by-line rich content. |
| **df_addon** | The object returned by `DF:CreateNewAddOn(...)`. Exposes `OnLoad`, `OnInit`, `profile`, `db`. |
| **df_chartmulti** | The chart object returned by `DF:CreateGraphicMultiLineFrame(parent, name)`. Hosts multiple `df_chart` sub-frames, each for one data line. |
| **df_chart** | An internal sub-frame, one per data line in a multi-line chart. Created automatically by `df_chartmulti:AddData(...)`. |

### Type annotations

Public widgets declare LuaCATS classes prefixed with `df_`. Examples:

```lua
---@class df_button : button
---@class df_scrollbox : scrollframe, df_sortmixin, df_scrollboxmixin
---@class df_addon : table
---@class df_canvasscrollbox : scrollframe, df_optionsmixin, df_canvasscrollboxmixin
```

Mixin tables use a `*Mixin` suffix on the table name and a `df_<name>mixin` class annotation.

---

## Conventions

### Method shape

Constructor methods are named `Create<Widget>` and accept the parent frame as their first argument:

```lua
DF:CreateButton(parent, callback, width, height, text, ...)
DF:CreateScrollBox(parent, name, refreshFunc, data, width, height, lineAmount, lineHeight, ...)
DF:CreateNewAddOn(addonName, savedVariablesName, defaultProfile)
```

Helpers on subtables follow ordinary dot syntax:

```lua
DF.table.copy(source)
DF.table.getfrompath(t, "a.b.c")
DF.Math.GetNinePoints(frame)
DF:Dispatch(func, ...)
DF.GameCooltip:Reset()
```

### Mixin pattern

```lua
DF.SortFunctions       = { Sort = function(self, ...) ... end }
DF.ScrollBoxFunctions  = { Refresh = function(self) ... end, ... }
DF.CanvasScrollBoxMixin = { SetScrollSpeed = function(self, n) ... end, ... }

DF:Mixin(targetFrame, DF.SortFunctions)
DF:Mixin(targetFrame, DF.ScrollBoxFunctions)
```

`DF:Mixin(target, mixin)` shallow-copies the mixin's keys onto `target`.

### Template pattern

```lua
local optionsFontTemplate   = DF:GetTemplate("font",   "OPTIONS_FONT_TEMPLATE")
local optionsButtonTemplate = DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")
local optionsSliderTemplate = DF:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
```

Recurring visual styles live in template tables. Custom templates can be installed via `DF:InstallTemplate(category, name, tableData, parentName)`.

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

Multiple published addons embed this framework. LibStub keeps only the highest-versioned copy across all loaded addons, so embedding is conflict-free. Here are 6 examples:

- **`Details!` Damage Meter** — uses the framework throughout for breakdown windows, options panels, and plugin UIs.
- **`Plater Nameplates`** — uses the framework for nameplate health bar, cast bar, power bar, options window and `Plater_Designer` (consumes `DF:CreateEditor`, `DF:CreateScrollBox`, `DF:CreateDropDown`, `DF:BuildMenu`, and others) for its layout / profile editor.
- **`World Quest Tracker`** — uses widgets for its main UI and options panel.
- **`ClassUIEnhanced`** — uses for all its widgets and options panel.
- **`FrameInspect`** — uses DF for the entire user interface.
- **`NorthernSkyRaidTools`** — uses widgets for its main UI and options panel.


To embed: copy the library folder into your addon's `Libs\` directory and reference its `load.xml` from your `.toc` before your own files, e.g. `Libs\DetailsFramework\load.xml`.

---

## Source layout

```
Libs/DetailsFramework/         -- (folder name is up to the embedder; Details! itself uses Libs/DF/)
  LibDFramework-1.0.toc        -- standalone TOC (for running the library on its own)
  load.xml                     -- file load order (embedders reference this from their .toc)
  fw.lua                       -- library bootstrap (LibStub registration)
  definitions.lua              -- LuaCATS type definitions
  mixins.lua                   -- Mixin helper
  helpers.md                   -- DF.table, DF.Math, dispatch helpers
  panel.lua / frames.lua       -- container frames
  containers.lua               -- box / inset containers
  button.lua                   -- buttons
  dropdown.lua                 -- dropdowns
  slider.lua                   -- sliders
  textentry.lua                -- text entries
  label.lua                    -- labels
  picture.lua                  -- texture widgets
  icon.lua / icongeneric.lua   -- icon widgets
  header.lua                   -- table headers
  tabcontainer.lua             -- tabbed UIs
  scrollbox.lua                -- scroll boxes (list/grid/aura/data/boss/canvas)
  cooltip.lua                  -- GameCooltip replacement
  timebar.lua                  -- cooldown / duration bars
  timeline.lua                 -- timeline visualization
  charts.lua                   -- chart rendering (DF:CreateGraphicMultiLineFrame)
  unitframe.lua                -- unit frames
  keybind.lua                  -- keybind UI
  anchorsystem.lua             -- anchor frames + nine-point system
  addon.lua                    -- df_addon (CreateNewAddOn)
  savedvars.lua                -- profile management
  schedules.lua                -- timers / recurring tasks
  packtable.lua                -- table packing / serialization
  languages.lua                -- localisation tables
  ejournal.lua                 -- encounter journal access
  elapsedtime.lua              -- elapsed-time tracker
  buildmenu.lua                -- declarative form generator
  editor.lua                   -- profile / layout editor
  externals.lua                -- optional integrations
  DFPixelUtil.lua              -- pixel-perfect scaling
  math.lua                     -- vector / geometry helpers
  colors.lua                   -- color tables
  pools.md                     -- object pooling
  *.examples.lua               -- runnable usage examples per widget
  *.md                         -- per-module reference documentation
  *.xml                        -- frame templates / inheritance trees
```

---

## Versioning

The library is version-stamped by an integer `dversion` in `fw.lua`:

```lua
local dversion = 726
local major, minor = "DetailsFramework-1.0", dversion
local DF, oldminor = LibStub:NewLibrary(major, minor)
```

LibStub activates the highest version present at load time.

---

## Reporting issues / contributing

Open issues and pull requests on the canonical repository: https://github.com/Tercioo/Details-Framework

Maintainer: Terciob.
l DF, oldminor = LibStub:NewLibrary(major, minor)
```

The framework is authored and maintained by **Terciob**.