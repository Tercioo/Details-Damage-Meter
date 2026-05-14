# fw.lua — Framework Core

`fw.lua` is the entry point and grab-bag utility module for `DetailsFramework-1.0` (DF). It registers the library with `LibStub`, exposes the `DetailsFramework` global, builds the version/expansion/locale shims the rest of the framework relies on, and defines the cross-cutting helpers — colors, fonts, anchors, animations, templates, pools, script comms, secure environments, and the `Embed` system — that every other module assumes is already loaded. If a function isn't on a widget mixin, it almost certainly lives here.

The canonical production consumer is **Details! Damage Meter** itself (this lib ships inside `Details/Libs/DF/`), but Plater, WeakAuras shims, OpenRaidLib's frame helpers, and other LibStub consumers all import the framework through this file's `Embed` surface.

---

## Mental model

There is one global, `DetailsFramework`, aliased as `DF` and `detailsFramework`, registered with LibStub as `DetailsFramework-1.0`. Loading is two-phase:

1. **File load** — the file body runs, populating `DF` with constants, tables, and functions. Cross-version compatibility shims (`GetSpellInfo`, `GetSpellBookItemInfo`, `EncounterJournal`, `PixelUtil`, etc.) are resolved here using the current `WOW_PROJECT_ID`, `Toc`, and `GetBuildInfo()` values cached in `DF.BuildId`/`DF.Toc`/`DF.Exp`.
2. **PLAYER_LOGIN** — every function pushed into `detailsFramework.OnLoginSchedules` fires on a one-frame `C_Timer.After(0, ...)` after login. This is where DBM/BigWigs hooks and other things that need other addons to be loaded are wired up.

```
                            ┌──────────────────────────────────┐
                            │  LibStub:NewLibrary(             │
                            │   "DetailsFramework-1.0", 732)   │
                            └──────────────┬───────────────────┘
                                           │
                              ┌────────────┴────────────┐
                              │ DF / detailsFramework   │  ← the singleton
                              │  • shims (spell/EJ/Px)  │
                              │  • version flags        │
                              │  • DF.table.*           │
                              │  • DF.string / strings  │
                              │  • DF.font_templates    │
                              │  • DF.button_templates  │
                              │  • DF.dropdown/...      │
                              │  • DF.alias_text_colors │
                              │  • DF.ClassSpecs / Race │
                              │  • DF.AnchorPoints      │
                              │  • DF.OnLoginSchedules  │ ──► fires once on PLAYER_LOGIN
                              │  • DF.PoolMixin         │
                              │  • DF.DebugMixin        │
                              │  • DF.GlobalWidgetControlNames
                              └──────────┬──────────────┘
                                         │
                              ┌──────────┴──────────┐
                              │ DF:Embed(addonTable)│  ← copies a curated whitelist
                              └─────────────────────┘    of methods onto the consumer
```

**The split that matters most**: `fw.lua` only owns *cross-cutting* utilities. Widget constructors (`CreateButton`, `CreateLabel`, `CreateScrollBox`, `CreateDropDown`, `BuildMenu`, etc.) are *referenced* by the `embedFunctions` whitelist but *defined* in sibling files (`button.lua`, `label.lua`, `scrollbox.lua`, `buildmenu.lua`, …). Don't grep `fw.lua` for their bodies — they're loaded by the addon's `.toc` or `.xml` and attached to the same `DF` table.

---

## Library access

```lua
local DF = LibStub("DetailsFramework-1.0")
-- or, if you do not control load order:
local DF = _G.DetailsFramework
```

The library refuses to load twice — if `LibStub:NewLibrary` returns `nil` (the running version is newer), the file sets `DetailsFrameworkCanLoad = false` and returns. Otherwise `DetailsFrameworkCanLoad = true`. Consumers that include their own copy of DF should check this flag.

### Embedding into an addon

`DF:Embed(target)` copies a whitelist (`embedFunctions`) of widget constructors and helpers onto `target`. The whitelist is fixed; new entries must be added to the table in fw.lua. After embed, `target:CreateButton(...)` is equivalent to `DF:CreateButton(...)`. The framework also stores the consumer in `DF.embeds[target] = true`.

```lua
local MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddon")
LibStub("DetailsFramework-1.0"):Embed(MyAddon)

-- now MyAddon has CreateButton, CreateLabel, BuildMenu, FormatNumber, …
local btn = MyAddon:CreateButton(MyAddon.frame, function() end, 120, 22, "Hello")
```

---

## Version & build detection

The file caches `GetBuildInfo()` at load and uses the integer `Toc` for all version branches:

| Field | Type | Value |
|---|---|---|
| `DF.GamePatch` | `string` | e.g. `"11.0.7"` |
| `DF.BuildId` | `string` | e.g. `"55000"` |
| `DF.Toc` | `number` | e.g. `110007` |
| `DF.Exp` | `number` | `floor(Toc/10000)` |
| `DF.BuildYear` | `number` | parsed from the build date |
| `DF.dversion` / `DF.FrameWorkVersion` | `number` / `string` | internal lib minor version |

All of `DF.IsClassicWow`, `DF.IsTBCWow`, `DF.IsWotLKWow`, `DF.IsCataWow`, `DF.IsPandaWow`, `DF.IsWarlordsWow`, `DF.IsLegionWow`, `DF.IsBFAWow`, `DF.IsShadowlandsWow`, `DF.IsDragonflightWow`, `DF.IsWarWow` (alias `IsTWWWow`), `DF.IsMidnightWow`, `DF.IsTimewalkWoW`, `DF.IsDragonflightAndBeyond`, `DF.IsDragonflightOrBelow`, `DF.IsWarWowOrBelow`, `DF.IsAddonApocalypseWow`, `DF.ExpansionHasEvoker`, `DF.ExpansionHasAugEvoker`, and `DF.IsNonRetailWowWithRetailAPI` (alias `IsWotLKWowWithRetailAPI`) read off the cached `buildInfo`. **They are functions, not booleans** — `if DF.IsDragonflightAndBeyond then ... end` is always true; you have to call them.

```lua
if DF.IsDragonflightAndBeyond() then
    -- C_Traits is available
end
```

---

## API-shim layer

These globals are reassigned to forward-compatible local upvalues at top of file:

| Shim | What it wraps |
|---|---|
| `GetSpellInfo` | `C_Spell.GetSpellInfo` (TWW); returns the legacy 8-tuple shape. |
| `GetSpellBookItemName` / `GetSpellBookItemInfo` | `C_SpellBook.*` with `Enum.SpellBookItemType` → string `"SPELL"`/`"FLYOUT"`/… translation. |
| `GetNumSpellTabs` / `GetSpellTabInfo` | `C_SpellBook.GetNumSpellBookSkillLines` / `GetSpellBookSkillLineInfo`. |
| `IsPassiveSpell` | `C_Spell.IsSpellPassive`. |
| `GetOverrideSpell` | `C_SpellBook.GetOverrideSpell` or `C_Spell.GetOverrideSpell`. |
| `HasPetSpells` | `C_SpellBook.HasPetSpells`. |
| `GetSpecialization`, `GetSpecializationInfo`, `GetSpecializationRole` | `C_SpecializationInfo.*` on TWW. |
| `PixelUtil` | Falls back to a local stub (calls `SetWidth/Height/Size/Point` directly) on Classic/TBC/WotLK. |
| `DF.EncounterJournal` | A table of `EJ_GetInstanceForMap`, `EJ_GetInstanceInfo`, `EJ_SelectInstance`, `EJ_GetEncounterInfoByIndex`, `EJ_GetEncounterInfo`, `EJ_SelectEncounter`, `EJ_GetSectionInfo`, `EJ_GetCreatureInfo`, `EJ_SetDifficulty`, `EJ_GetNumLoot`. Each entry is either the live global or a no-op stub. |
| `SPELLBOOK_BANK_PLAYER` / `SPELLBOOK_BANK_PET` | `Enum.SpellBookSpellBank.Player` / `.Pet` or string fallback. |

If you need to write code that runs across all flavors, call **these** rather than the raw globals — `fw.lua` already did the version branching for you.

---

## Constants & lookup tables

| Constant | Purpose |
|---|---|
| `DF.FrameStrataLevels` | Ordered `{"BACKGROUND","LOW","MEDIUM","HIGH","DIALOG","FULLSCREEN","FULLSCREEN_DIALOG","TOOLTIP"}`. |
| `DF.FRAMELEVEL_OVERLAY` | `750` — frame level for overlay textures across widgets. |
| `DF.FRAMELEVEL_BACKGROUND` | `150` — frame level for background textures. |
| `DF.AnchorPoints` | Human-readable names for the 17 anchor sides (`"Top Left"` … `"Inside Top Right"`). |
| `DF.AnchorPointsByIndex` | The 9 Blizzard anchor strings (`"topleft"` … `"center"`). |
| `DF.AnchorPointsToInside` / `DF.InsidePointsToAnchor` | Bidirectional remap between sides 1–9 and inside-sides 10–17. |
| `DF.ClassIndexToFileName` / `DF.ClassFileNameToIndex` | Class id ↔ uppercase file name (e.g. `12` ↔ `"DEMONHUNTER"`). Includes `EVOKER = 13`. |
| `DF.ClassSpecs` | `[CLASSFILE][specId] = true` hash. |
| `DF.SpecListByClass` | `[CLASSFILE] = {specId, specId, ...}` array. |
| `DF.RaceList` / `DF.AlliedRaceList` | Race id → English file name. |
| `DF.GroupTypes` | `{Name, ID}` rows for arena/pvp/raid/party/scenario/none. |
| `DF.RoleTypes` | `{Name, ID, Texture}` rows for `DAMAGER`/`HEALER`/`TANK`/`NONE` using the in-game inline icons. |
| `DF.BattlegroundSizes` | `[instanceMapId] = teamSize`. |
| `DF.CLEncounterID` | Hardcoded `{ID, Name}` list of current cross-realm encounter ids. |
| `DF.DefaultRoundedCornerPreset` | `{roundness=6, color={.1,.1,.1,.98}, border_color={.05,.05,.05,.834}}`. |
| `DF.GlobalWidgetControlNames` | Map of widget kind → global meta-table name (e.g. `button = "DF_ButtonMetaFunctions"`). Used by `AddMemberForWidget`. |
| `DF.LabelNameCounter`, `DF.PictureNameCounter`, `DF.BarNameCounter`, `DF.DropDownCounter`, `DF.PanelCounter`, `DF.SimplePanelCounter`, `DF.ButtonCounter`, `DF.SliderCounter`, `DF.SwitchCounter`, `DF.SplitBarCounter` | Seeded with `math.random(1, 1000000)` so widget-creation calls that need a unique `$parent…` global name don't collide across reloads. |

`DF.folder` is computed once from `debugstack` and stores the full path to the framework root (`Interface\AddOns\Details\Libs\DF\` for the bundled copy). Use `DF:GetFrameworkFolder()` to read it.

---

## `DF:Embed(target)`

Copies the curated whitelist of methods from `DF` onto `target`. The whitelist (defined as the local `embedFunctions` array near the top of the file) is the *only* place the framework's public surface is enumerated:

```
table, RemoveRealName, BuildDropDownFontList, SetFontSize, SetFontFace, SetFontColor,
GetFontSize, GetFontFace, SetFontOutline, trim, Msg, CreateFlashAnimation, Fade,
NewColor, IsHtmlColor, ParseColors, BuildMenu, ShowTutorialAlertFrame, GetNpcIdFromGuid,
SetAsOptionsPanel, GetPlayerRole, GetCharacterTalents, GetCharacterPvPTalents,
CreateDropDown, CreateButton, CreateColorPickButton, CreateLabel, CreateBar, CreatePanel,
CreateFillPanel, ColorPick, IconPick, CreateSimplePanel, CreateChartPanel, CreateImage,
CreateScrollBar, CreateSwitch, CreateSlider, CreateSplitBar, CreateTextEntry, Create1PxPanel,
CreateOptionsFrame, NewSpecialLuaEditorEntry, ShowPromptPanel, ShowTextPromptPanel,
GetTemplate, InstallTemplate, GetFrameworkFolder, ShowPanicWarning, SetFrameworkDebugState,
FindHighestParent, OpenInterfaceProfile, CreateInCombatTexture, CreateAnimationHub,
CreateAnimation, CreateScrollBox, CreateBorder, FormatNumber, IntegerToTimer, QuickDispatch,
Dispatch, CommaValue, RemoveRealmName, Trim, CreateGlowOverlay, CreateAnts, CreateFrameShake,
RegisterScriptComm, SendScriptComm
```

If you add a function to `DF` and want consumer addons to be able to call it as `MyAddon:NewFunc()`, you must also add its name to `embedFunctions`. Functions that aren't listed are still callable as `DetailsFramework:NewFunc()` — just not as embedded methods.

---

## `DF.table` — table helpers

`DF.table` is the conventional namespace for non-Blizzard table operations. **Don't confuse it with the global `table.*` library** — these helpers have different semantics and Lua's `table.*` is still there.

| Method | Purpose |
|---|---|
| `DF.table.find(t, value)` | Linear scan, returns the first index where `t[i] == value`, or nil. Array semantics. |
| `DF.table.findsubtable(t, index, value)` | Like above but for arrays of sub-tables; returns `i` where `t[i][index] == value`. |
| `DF.table.countkeys(t)` | Walks `pairs(t)`. Use over `#t` when the table is a hash. |
| `DF.table.addunique(t, index, value)` | Inserts `value` only if not already in `t`. Two-arg form (`t, value`) appends at end. |
| `DF.table.reverse(t)` | Returns a new reversed array. |
| `DF.table.remove(t, value)` | Removes **all** occurrences of `value`. Returns `bRemoved, count`. |
| `DF.table.copy(t1, t2)` | Deep-copies values from `t2` into `t1`, overwriting. Tables are recursively merged. **Treats UIObjects as regular tables** — will recurse into a frame's metatable members. Skip `__index`/`__newindex` keys. |
| `DF.table.duplicate(t1, t2)` | Same as `copy` but preserves UIObject references by detecting `value:GetObjectType()` — sub-tables that are frames are assigned by reference, not recursed into. **Use this when copying tables that might contain frames; use `copy` for plain data.** |
| `DF.table.copytocompress(t1, t2)` | Like `copy` but strips functions and UIObjects — meant to prepare a table for serialization/compression. |
| `DF.table.deploy(t1, t2)` | Copy only keys that are missing from `t1` (i.e. apply defaults). Recursive. |
| `DF.table.removeduplicate(t1, t2)` | Removes from `t1` any key whose value matches `t2`'s. Numbers compare with `DF:IsNearlyEqual(..., 0.0001)`. Empty sub-tables are pruned. Used to shrink saved variables by removing values that match defaults. |
| `DF.table.append(t1, t2)` | Push every numeric index of `t2` onto the end of `t1`. |
| `DF.table.inserts(t1, ...)` | Push each vararg onto the end of `t1`. |
| `DF.table.dump(t, ...)` | Color-coded recursive `tostring` of a table; safe against circular references; UIObjects show their object type. Output is colorized for chat. |
| `DF.table.getfrompath(t, path, subOffset?)` | Read `t.a.b.c` from the path string `"a.b.c"`. `subOffset` lets you stop early and return an intermediate node. Numeric path segments work (`"a.1.b"`). |
| `DF.table.setfrompath(t, path, value)` | Write `t.a.b.c = value` from a path. Returns `true` on success. Path parser tokenizes on `.` and `[]`. Auto-detects numeric keys with `tonumber`. |

`getfrompath`/`setfrompath` are how the rest of the framework supports "edit a value at some nested location in a profile" without hardcoding the shape. See the editor module (`editor.md`) for the canonical consumer pattern.

---

## Strings, numbers, text

### Number formatting
`DF.FormatNumber(number)` is **rebuilt per-locale at file load**. For Korean / Simplified Chinese / Traditional Chinese it uses Asian breakpoints (천/만/억, 千/万/亿, 千/萬/億); otherwise it uses K/M/B at `>999`/`>999999`/`>999999999`. The breakpoint thresholds differ subtly between the two implementations — **don't rely on `FormatNumber` to be lossless or invertible**.

`DF:CommaValue(value)` adds `,` thousand separators using a single regex pass.
`DF:IntegerToTimer(value)` → `"MM:SS"`.
`DF:IntegerToCooldownTime(value)` → `"3h"` / `"2m"` / `"45s"` depending on magnitude.
`DF:TruncateNumber(number, fractionDigits)` rounds to N decimals using `floor(n*mult+0.5)/mult` (note: rounds away from zero for negatives via `ceil`).

### Text truncation
Four variants of "shrink fontString text until it fits maxWidth":

| Function | Stop condition | Iterations |
|---|---|---|
| `DF:TruncateText(fs, maxWidth)` | Until `GetStringWidth() <= maxWidth`. | Unbounded (down to length 1). |
| `DF:TruncateTextSafe(fs, maxWidth)` | Same, but **capped at 10 chars removed** then bail. | ≤ 10. |
| `DF:TruncateTextBinarySearch(fs, maxWidth)` | Binary search over substring length, using `GetUnboundedStringWidth`. | `O(log n)`. |
| `DF:TruncateTextSafeBinarySearch(fs, maxWidth)` | Binary search, **capped at 10 iterations**. | ≤ 10. |

All four call `DF:CleanTruncateUTF8String(text)` at the end to drop trailing partial UTF-8 sequences (bytes ≥ 0xC2 / 0xE0 / 0xF0). Use the binary-search variant when `maxWidth` is small and text is long — the naive shrink can stall the frame.

### Name cleanup
- `DF:RemoveRealmName(name)` — strips `-Realm` suffix.
- `DF:RemoveOwnerName(name)` — strips ` <OwnerName>` from pet/guardian names.
- `DF:CleanUpName(name)` — strips realm, owner, leading `[*] ` spell-actor marker, and `|T...|t` texture sequences.
- `DF:RemoveColorCodes(text)` — strips `|c…` / `|r`.
- `DF:RemoveTextureCodes(text)` — strips `|T…|t`.
- `DF:AddColorToText(text, color)` — wraps with `|c<hex>…|r`. `color` accepts any `ParseColors`-compatible form.
- `DF:AddClassColorToText(text, className)` — uses `RAID_CLASS_COLORS`. Accepts class file name or class id. Returns `RemoveRealName(text)` when class is `UNKNOW`/`PET` or missing.
- `DF:AddClassIconToText(text, playerName, englishClassName, useSpec?, iconSize?)` — depends on `Details!` being loaded (`Details.class_specs_coords`, `Details.class_coords`). Falls through to plain text otherwise.

### Fonts
`DF:SetFontFace(fs, fontFaceOrSlug)` — `fontFace` may be:
- the literal string `"DEFAULT"` (delegates to `SetFontDefault`)
- a name registered with LibSharedMedia-3.0 (preferred)
- the global name of an existing `Font` object (e.g. `"GameFontNormal"`) — DF reads the file path from it
- a raw font file path

The `SetFont` call is wrapped in `pcall` because Blizzard rejects fonts whose path the client can't load (rare, but it happens on some Asian builds with custom SharedMedia entries).

`DF:SetFontOutline(fs, outline)` — accepts string (`"OUTLINE"`, `"THICKOUTLINE"`, `"MONOCHROME"`, `"OUTLINEMONOCHROME"`, `"THICKOUTLINEMONOCHROME"`, `"SLUG"`, `"SLUG,OUTLINE"`, `"NONE"`/`""`), boolean (`true` → `"OUTLINE"`), or number (`1` → `"OUTLINE"`, `2` → `"THICKOUTLINE"`). Invalid input is coerced to `""`. The valid set is in `ValidOutlines`; `DF.FontOutlineFlags` is the user-facing list (with display labels) suitable for dropdowns.

`DF:GetTextWidth(text, size?)` uses a single hidden FontString (`dummyFontString`) created at file load. **Not reentrant** — if you call it from inside an OnUpdate that also calls it, you'll clobber the previous measurement before reading it.

---

## Colors

### `DF:ParseColors(red, green, blue, alpha)`
The framework's universal color de-confuser. Input shapes accepted:

| Shape | Example |
|---|---|
| 4 numbers | `ParseColors(1, .5, 0, 1)` |
| `{r, g, b, a}` indexed table | `ParseColors({1, .5, 0, 1})` |
| `{r=…, g=…, b=…, a=…}` keyed table | `ParseColors({r=1, g=.5, b=0})` |
| Color-table mixin (with `IsColorTable = true`) | returns `colorTable:GetColor()` |
| Named alias | `ParseColors("orange")` — looks up `DF.alias_text_colors["orange"]` |
| Hex string | `"#RRGGBB"` or `"#AARRGGBB"` |
| Comma string | `"1,0.5,0,1"` |

Returns four numbers, all `Saturate`d to `[0, 1]`. Missing values default to `1`. **Always passes through this function** before handing values to `SetVertexColor`/`SetColorTexture` — every widget mixin does. If you write a new mixin, do the same.

### `DF:FormatColor(newFormat, r, g, b, a?, decimalsAmount?)`
Convert to any of `"commastring"`, `"tablestring"`, `"table"`, `"tablemembers"`, `"numbers"`, `"hex"`. The hex output is `AARRGGBB` (not RRGGBBAA) because that's what `|c<hex>…|r` color codes expect.

### `DF:CreateColorTable(r, g, b, a)` → table with `colorTableMixin`
The mixin provides `GetColor()`/`SetColor(...)` and flag `IsColorTable = true`. `ParseColors` recognizes the flag and short-circuits to `GetColor()` — these tables are safe to pass anywhere a color is expected.

### `DF:NewColor(name, r, g, b, a?)`
Registers a named color in `DF.alias_text_colors` so it becomes addressable as `"name"` everywhere `ParseColors` runs. The values are run through `ParseColors`+`FormatColor("table", …)` first, so you can register from any source format.

### Utilities
- `DF:GetColorBrightness(r, g, b)` → ITU-R BT.709 luminance.
- `DF:GetColorHue(r, g, b)` → 0–6 hue value (HSV-style).
- `DF:IsHtmlColor(name)` → returns the alias table if `name` is registered.

---

## Anchor system

The 17 anchor sides are the spine of widget positioning across the framework. Sides 1–8 are exterior corners and edges (clockwise from top-left), side 9 is center, sides 10–13 are interior edges (inside-left/right/top/bottom), and sides 14–17 are interior corners (inside-topleft/bottomleft/bottomright/topright). The 17 closures in the local `anchoringFunctions` array call `frame:ClearAllPoints()` followed by `frame:SetPoint(…)` for each side.

```lua
---@class df_anchor : table
---@field side number  -- 1..17
---@field x number
---@field y number
```

| Function | Purpose |
|---|---|
| `DF:SetAnchor(widget, anchorTable, anchorTo?)` | Looks up `anchoringFunctions[anchorTable.side]` and applies it. `anchorTo` defaults to `widget:GetParent()`. |
| `DF:ConvertAnchorPointToInside(side)` | Map exterior side → interior side via `AnchorPointsToInside`. |
| `DF:ConvertAnchorOffsets(widget, ref, anchorTable, newSide)` | Recompute `x`,`y` so the visual position stays the same after changing the anchor side. Uses `DF.Math.GetNinePoints` to read on-screen coordinates of the nine reference points. |
| `DF:CheckPoints(p1, p2, p3, p4, p5, object)` | Polymorphic `SetPoint` argument normaliser. Accepts the many shorthand forms widget constructors take (`("left", frame, x, y)`, `(x, y)`, `(frame, x, y)`, etc.) and returns `(point, relativeTo, relativePoint, ofsx, ofsy)`. |

See `anchorsystem.md` for the screen-anchor manager built on top of this.

---

## Templates

Four named-template categories live on `DF`:

| Table | Used by |
|---|---|
| `DF.font_templates` | `SetFontFace`/`SetFontSize`/`SetFontColor` on FontString-bearing widgets. |
| `DF.dropdown_templates` | DropDown and TextEntry backdrops. |
| `DF.button_templates` | Buttons (including rounded-corner buttons via `rounded_corner`). |
| `DF.switch_templates` | Switches / checkboxes. |
| `DF.slider_templates` | Sliders. |

The defaults installed in this file include `ORANGE_FONT_TEMPLATE`, `OPTIONS_FONT_TEMPLATE`, `SMALL_SILVER`, `OPTIONS_DROPDOWN_TEMPLATE`, `OPTIONS_DROPDOWNDARK_TEMPLATE`, `OLD_DROPDOWN_TEMPLATE`, `OPTIONS_CHECKBOX_TEMPLATE`, `OPTIONS_CIRCLECHECKBOX_TEMPLATE`, `OPTIONS_CHECKBOX_BRIGHT_TEMPLATE`, `OPTIONS_BUTTON_TEMPLATE`, `OPTIONS_CIRCLEBUTTON_TEMPLATE`, `OPTIONS_BUTTON_GOLDENBORDER_TEMPLATE`, `STANDARD_GRAY`, `OPAQUE_DARK`, `OPTIONS_SLIDER_TEMPLATE`, `OPTIONS_SLIDERDARK_TEMPLATE`, `MODERN_SLIDER_TEMPLATE`. Look at any of them as a starting reference for the recognised option keys.

| Method | Purpose |
|---|---|
| `DF:GetTemplate(widgetType, templateName)` | Return the template table from the relevant category. |
| `DF:InstallTemplate(category, templateName, template, parentName?)` | Register a new template. If `parentName` is given, the parent is copied first, then `template` overrides — basic inheritance. |
| `DF:ParseTemplate(category, template)` | Resolve a name or table to a template table. The `category` argument accepts widget aliases — `"label"` → `font_templates`, `"textentry"` → `dropdown_templates`, etc. If the name isn't in the matching category, the function walks **all five** template tables. Returns the table form unchanged. |
| `detailsFramework:SetTemplate(frame, template)` | Apply a (resolved) template to a frame. Mixes in `BackdropTemplateMixin` if needed. Wires `OnEnter`/`OnLeave` hooks for the `onentercolor`/`onleavecolor`/`onenterbordercolor`/`onleavebordercolor` keys; stores the leave colors on `frame.onleave_backdrop` so the hook can restore them. |

Recognised template keys (across all categories — not every key is meaningful for every widget):
`backdrop`, `backdropcolor`, `backdropbordercolor`, `width`, `height`, `onentercolor`, `onleavecolor`, `onenterbordercolor`, `onleavebordercolor`, `icon = {texture, width, height, layout, texcoord, color, textdistance, leftpadding}`, `textsize`, `textfont`, `textcolor`, `textalign` (`"left"`/`"center"`/`"right"` or `<`/`|`/`>`), and switch-only: `enabled_backdropcolor`, `disabled_backdropcolor`, `is_checkbox`, `checked_texture`, `checked_size_percent`, `checked_xoffset`, `checked_yoffset`, `checked_color`, `rounded_corner = {color, border_color, roundness}`, slider-only: `thumbtexture`, `thumbwidth`, `thumbheight`, `thumbcolor`, `slider_left`, `slider_right`, `slider_middle`, `amount_color`, `amount_size`, `amount_outline`, dropdown-only: `dropicon`, `dropiconsize`, `dropiconpoints`.

`DF:AddMemberForWidget(widgetName, "GET" | "SET", memberName, func)` — the entry point for extending a widget's `__index` table dynamically. The widget's global meta-table is looked up via `DF.GlobalWidgetControlNames[widgetName]`.

---

## Animations

```lua
local hub = DF:CreateAnimationHub(parent, onPlay?, onFinished?)
-- hub:Play()/:Stop()/:Pause() like a normal animation group.
-- hub.NextAnimation is bumped each time CreateAnimation is called on it.

local anim = DF:CreateAnimation(hub, "Alpha"|"Scale"|"Translation"|"Rotation"|"Path"|"VertexColor",
                                order?, duration, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
```

The argument slots are type-dependent. Lifted from the EmmyLua comments in the source:

| Type | `arg1` | `arg2` | `arg3` | `arg4` | `arg5` | `arg6` | `arg7` |
|---|---|---|---|---|---|---|---|
| `Alpha` | fromAlpha | toAlpha | | | | | |
| `Scale` | fromX | fromY | toX | toY | originPoint (default `"center"`) | originXOffset | originYOffset |
| `Translation` | xOffset | yOffset | | | | | |
| `Rotation` | degrees | originPoint | originXOffset | originYOffset | | | |
| `Path` | xOffset (unused) | xOffset | yOffset | curveType (default `"SMOOTH"`) | | | |
| `VertexColor` / `Color` | r1 | g1 | b1 | a1 | r2 | g2 | b2, a2 |

If `order` is omitted, `hub.NextAnimation` is used and incremented — call sites can omit it and get sequential ordering for free.

For Scale, the function picks between `SetFromScale`/`SetScaleFrom` based on `IsDragonflightAndBeyond()` (the API renamed between expansions).

For VertexColor, `r1`/`r2` may be color names or tables — `ParseColors` is called on each.

Higher-level helpers:

| Function | Returns | Use |
|---|---|---|
| `DF:CreateFlashAnimation(frame, onFinishFunc?, onLoopFunc?)` | the animation group, also attaches `frame.Flash(fadeInTime, fadeOutTime, flashDuration, showWhenDone, flashInHoldTime, flashOutHoldTime, loopType)` and `frame.Stop()`. | A two-anim group (fade out → fade in) that loops for `flashDuration`. |
| `DF:CreatePunchAnimation(frame, scale)` | hub | Two scale steps, mimics a "punch" pop. `scale` clamped to `≤ 1.9`. |
| `DF:CreateFadeAnimation(uiObject, fadeInTime?, fadeOutTime?, fadeInAlpha?, fadeOutAlpha?)` | nothing | Hooks `OnEnter`/`OnLeave` on the object (or its parent if it's a FontString/Texture) to play fade-in/fade-out. |
| `DF:FadeFrame(frame, t)` | nothing | Instant `t==0` → show full alpha; `t==1` → hide alpha 0. Sets boolean flags `hidden`/`faded`/`fading_in`/`fading_out` for consumers that track fade state. |

---

## Frame shakes

A frame shake is an OnUpdate-driven sine-wave perturbation of a frame's anchor points, with optional fade-in and fade-out. The framework owns a single hidden updater frame (`DetailsFrameworkFrameshakeControl`) that ticks all registered parents.

```lua
---@class df_frameshake : table
---@field Amplitude number          -- pixel magnitude
---@field Frequency number          -- radians/sec advance through the sine
---@field Duration number
---@field FadeInTime number
---@field FadeOutTime number
---@field ScaleX number             -- direction/intensity multiplier per-axis
---@field ScaleY number
---@field AbsoluteSineX boolean     -- abs() the sine (one-sided shake)
---@field AbsoluteSineY boolean
---@field IsPlaying boolean
---@field TimeLeft number
---@field OriginalScaleX/Y, OriginalFrequency, OriginalAmplitude, OriginalDuration number
```

```lua
local shake = DF:CreateFrameShake(parent, duration?, amplitude?, frequency?,
                                  absoluteSineX?, absoluteSineY?,
                                  scaleX?, scaleY?,
                                  fadeInTime?, fadeOutTime?,
                                  anchorPoints?)

parent:PlayFrameShake(shake, scaleDirection?, scaleAmplitude?, scaleFrequency?, scaleDuration?)
parent:StopFrameShake(shake)
parent:SetFrameShakeSettings(shake, duration?, amplitude?, frequency?,
                             absoluteSineX?, absoluteSineY?, scaleX?, scaleY?,
                             fadeInTime?, fadeOutTime?)
```

Defaults: `amplitude=2`, `frequency=5`, `duration=0.3`, `fadeInTime=0.01`, `fadeOutTime=0.01`, `scaleX=0.2`, `scaleY=1`.

If `anchorPoints` is omitted, the shake captures `parent:GetPoint(i)` at every `Play` call (`IsDynamicAnchor = true`). Otherwise it shakes around the static anchor list you pass.

**Multiple shakes on one frame** — each `CreateFrameShake` call appends to `parent.__frameshakes`, and `parent.__frameshakes.enabled` is the active count. The updater short-circuits when `enabled == 0`.

---

## Glow / ants

| Function | Purpose |
|---|---|
| `DF:CreateGlowOverlay(parent, antsColor?, glowColor?)` | Wraps `ActionButtonSpellAlertTemplate` (or `ActionBarButtonSpellActivationAlert` pre-11.1.7), exposes `:Play()`, `:Stop()`, `:SetColor(antsColor, glowColor)`. Also stored as `parent.overlay`. Hooked to start/stop on `OnShow`/`OnHide`. Frame name shortens names longer than 50 characters. |
| `DF:CreateAnts(parent, antTable, leftOffset?, rightOffset?, topOffset?, bottomOffset?)` | OnUpdate-driven `AnimateTexCoords` flipbook. `antTable` keys: `Texture`, `TextureWidth`, `TextureHeight`, `TexturePartsWidth`, `TexturePartsHeight`, `AmountParts`, `Throttle` (default 0.025), `BlendMode` (default `"ADD"`), `Color`. |

---

## Borders

| Function | Purpose |
|---|---|
| `DF:CreateBorder(parent, alpha1?, alpha2?, alpha3?)` | Three concentric black-rectangle borders with descending alpha (defaults .5/.3/.1) on each side. Attaches `parent.SetBorderAlpha`, `parent.SetBorderColor(r, g, b)`, `parent.SetLayerVisibility(a, b, c)`. Mutates `parent.Borders = {Layer1, Layer2, Layer3, Alpha1, Alpha2, Alpha3}`. |
| `DF:CreateBorderWithSpread(parent, a1, a2, a3, size?, spread)` | Same idea but with width/height parameters. Note: the `spread` argument is shadowed by `local spread = 0` inside the function — it's dead code. |
| `DF:CreateFullBorder(name, parent)` | Mixed-in version of Blizzard's `NameplateFullBorderTemplate`. Returns a frame with `Left`, `Right`, `Top`, `Bottom` 1px white textures and the `df_nameplate_border_mixin` methods (`SetVertexColor`, `GetVertexColor`, `SetBorderSizes`, `UpdateSizes`). Useful for crisp 1-pixel outlines that don't blur on non-integer-scaled UIs. |

### `df_nameplate_border_mixin` fields

| Field | Type | Description |
|---|---|---|
| `Left` / `Right` / `Top` / `Bottom` | `texture` | The four edge textures. |
| `Textures` | `texture[]` | Array of all four edges (used by the `SetVertexColor` loop). |
| `borderSize` | `number` | Logical border width set by `SetBorderSizes`. |
| `borderSizeMinPixels` | `number` | Minimum pixel size for PixelUtil. |
| `upwardExtendHeightPixels` | `number` | How far the side edges extend above the top edge. |
| `upwardExtendHeightMinPixels` | `number` | Minimum-pixel version of the above. |

---

## Roles, classes, specs

### Role
- `DF.UnitGroupRolesAssigned(unitId, bUseSupport?, specId?)` — version-safe wrapper. If `specId == 1473` (Augmentation) and `bUseSupport` is true, returns `"SUPPORT"`. On Classic, falls back to `Details.cached_roles[guid]` (if Details! is loaded), then to `GetRoleByClassicTalentTree`, then to `"DAMAGER"`.
- `DF:GetRoleByClassicTalentTree()` — heuristic for Classic/TBC/WotLK using talent-tree-icon → role lookup.
- `DF:GetPlayerRole()` — your role.
- `DF:ConvertRole(value, valueType?)` — string ↔ number (`"DAMAGER"` ↔ `3`).
- `DF:GetRoleTCoordsAndTexture(roleId)` / `DF:GetRoleIconAndCoords(role)` / `DF:AddRoleIconToText(text, role, size?)` — escape-code helpers.

### Class
- `DF:GetCurrentClassName()` / `DF:GetCurrentSpec()` / `DF:GetCurrentSpecId()` / `DF:GetCurrentSpecName()`.
- `DF:GetClassIdByFileName(fileName)` / `DF:GetClassList()` — `ClassList` is cached on first call into `DF.ClassCache`.
- `DF:GetClassTCoordsAndTexture(class)` — returns `l, r, t, b, texture` (the texture is `Interface\WORLDSTATEFRAME\Icons-Classes`).
- `DF:GetClassColorByClassId(classId)` — from `C_CreatureInfo.GetClassInfo` + `RAID_CLASS_COLORS`.
- `DF:AddClassColorToText(text, className)` — wrap with `|c<colorStr>…|r`. Auto-converts numeric class id.
- `DF:AddClassIconToString(text, engClass, size?)` — `|T…|t` icon prefix using `CLASS_ICON_TCOORDS`.

### Spec
- `DF:GetSpecialization()` / `DF:GetSpecializationInfo(...)` / `DF:GetSpecializationInfoByID(specId)` / `DF:GetSpecializationRole(...)` — TWW-safe wrappers.
- `DF:GetSpecInfoFromSpecId(specId)` / `DF:GetSpecInfoFromSpecIcon(specIcon)` / `DF:GetSpecIdFromSpecIcon(specIcon)` — read against the hardcoded `specInformation` table.
- `DF:GetClassSpecIDs(engClass)` (alias `GetClassSpecIds`), `DF:GetClassSpecs(class)`, `DF:GetSpecListFromClass(class)`.
- `DF:IsValidSpecId(specId)` — for the player's current class only.
- `DF:IsSpecFromClass(class, specId)` — for an arbitrary class.
- `DF:AddSpecIconToString(text, specId?, size?)` — defaults `specId` to the player's current spec.

### `specinfo` fields (`DF:GetSpecInfoFromSpecId`)

| Field | Type | Description |
|---|---|---|
| `specId` | `number` | The numeric spec ID (62..1480). |
| `name` | `string` | Localised English name (e.g. `"Arcane"`, `"Augmentation"`). |
| `specIcon` | `number` | File data ID for the spec icon. |
| `role` | `string` | `"DAMAGER"` / `"HEALER"` / `"TANK"`. |
| `classId` | `number` | 1–13 (class file index). |
| `className` | `string` | English class file name (e.g. `"MAGE"`). |
| `specIndex` | `number` | 0-based index within the class. |
| `flags` | `number` | Bitfield (matches `ChrSpecialization.db2`). |
| `primaryStatPriority` | `number` | Match to `PRIMARY_STAT_*`. |

---

## Talents & spellbook

| Function | Purpose |
|---|---|
| `DF:GetSpellBookSpells()` | Returns `(namesHash, idsArray)` of player tab spells. Skips the General tab (`tabTexture == 136830`) and skips off-spec tabs — only processes tabs where `offspecId == 0`. |
| `DF:GetAvailableSpells()` | Hash of `[spellId] = true` for the player's currently active spec, including racials (filtered by `LIB_OPEN_RAID_COOLDOWNS_INFO[spellId].raceid`) and pet spells. Passives are excluded. Spell ids are run through `GetOverrideSpell`. |
| `DF:GetAllTalents()` | Indexed list of `{Name, ID, Texture, IsSelected}` for **every** talent node in the active config (Dragonflight onward). |
| `DF:GetHeroTalentId()` | Walks the tree to find the active sub-tree's `subTreeID`. Returns `0` if none. |
| `DF:GetCharacterTalents(onlySelected?, onlySelectedHash?)` | Pre-DF (toc 70000–99999) iterates rows × columns of `GetTalentInfo`. Post-DF, delegates to `GetAllTalents` for the full list, or walks the traits API for the selected-only path. |
| `DF:GetCharacterPvPTalents(onlySelected?, onlySelectedHash?)` | Reads `C_SpecializationInfo.GetAllSelectedPvpTalentIDs` (for the selected path) or iterates the 4 slots' `availableTalentIDs` (for the full list). |
| `DF:GetDragonlightTalentString()` | Returns `C_Traits.GenerateImportString(activeConfigID)`. Safe-wrapped — errors return `""`. |

---

## Pool

```lua
---@class df_pool : table
---@field objectsCreated number
---@field inUse table[]
---@field notUse table[]
---@field payload table          -- captured varargs from CreatePool
---@field newObjectFunc fun(self:df_pool, ...):table
---@field sortFunc fun(a, b):boolean
---@field onAcquire fun(object)
---@field onRelease fun(object)
---@field onReset fun(object)
```

```lua
local pool = DF:CreatePool(function(self, parent)
    local f = CreateFrame("Frame", nil, parent)
    return f
end, parentFrame)

local frame, wasNew = pool:Get()            -- alias: :Acquire()
pool:Release(frame)
pool:Reset()                                 -- alias: :ReleaseAll()
pool:Hide() / pool:Show()                    -- on in-use objects only
pool:Sort(func?)                             -- uses pool.sortFunc if no func
pool:RunForInUse(func)
pool:GetAmount() -- total, notUse, inUse
pool:SetSortFunction(func)
pool:SetOnAcquire(func)  -- alias: SetCallbackOnGet
pool:SetOnRelease(func)  -- alias: SetCallbackOnRelease
pool:SetOnReset(func)    -- alias: SetCallbackOnReleaseAll
```

`Get()` returns `(object, bIsNew)`. The varargs passed to `CreatePool` are captured into `pool.payload` and re-passed to `newObjectFunc` on every fresh allocation — useful for fixing a parent frame, template name, or anchor target without closing over it.

See `pools.md` for the standalone pool documentation.

---

## Script comms (`_GSC` channel)

Three external libs (loaded via LibStub when present) back this: `AceComm-3.0`, `AceSerializer-3.0`, `LibDeflate`. If any is missing, the registration and dispatch are silently no-op.

```lua
DF:RegisterScriptComm(ID, function(sourcePlayerName, ...) ... end)
DF:SendScriptComm(ID, ...)
```

Wire format: AceSerializer pack of `(ID, GUID, "name-realm", ..., timestamp?)` → `LibDeflate:CompressDeflate(level=9)` → `LibDeflate:EncodeForWoWAddonChannel` → AceComm "PARTY" channel under prefix `"_GSC"`. Inbound handlers run inside `DF:Dispatch` (xpcall) and have their environment swapped via `DF:MakeFunctionSecure` (see Secure environments).

Each `ID` may only register one handler; subsequent calls overwrite. Sending with an `ID` you haven't registered is a no-op — that's the gate, not a separate auth step.

---

## Secure environments

Used by Plater/WeakAuras-style script-running code to keep user scripts from touching things they shouldn't.

```lua
DF:SetEnvironment(func, environmentHandle?, newEnvironment?)
DF:MakeFunctionSecure(func) -- alias for SetEnvironment(func) using the default handle
```

The default handle (`DF.DefaultSecureScriptEnvironmentHandle`) is a metatable whose `__index` denies a hardcoded `forbiddenFunction` set (auction house, bank, trade, mail, `RunScript`, `pcall`, `xpcall`, `setfenv`, `getfenv`, `setmetatable`, macro/binding APIs, guild commands, `PlaterDB`, `_detalhes_global`, `WeakAurasSaved`, and others) and proxies everything else through to `_G`. `C_GuildInfo.RemoveFromGuild` is replaced with a synthetic sub-table that omits the function — the lookup is precomputed into `C_SubFunctionsTable` so it doesn't have to rebuild per call.

The defense is best-effort and *not* a sandbox: a sufficiently determined script can still escape via metatables on returned tables. Don't run untrusted code under this thinking it's safe — it's an honest-mistake fence, not a security boundary.

---

## Error handling — `Dispatch` family

| Function | Behavior on bad input |
|---|---|
| `DF:QuickDispatch(func, ...)` | Type-checks `func`; silently returns if not a function. Otherwise `xpcall` with `geterrorhandler()`. **Returns `true` on a successful dispatch**, otherwise nil. |
| `DF:Dispatch(func, ...)` | Asserts `type(func) == "function"`. `xpcall`. Returns the result values (skipping the boolean from xpcall). |
| `DF:CoreDispatch(context, func, ...)` | Used inside the framework. Errors out with a debugstack-tagged message if `func` isn't callable. Returns up to four result values. |

Use `QuickDispatch` for user-provided callbacks where "function might be nil" is fine; `Dispatch` when you know the function exists and want results; `CoreDispatch` only when a missing function is a programming error and you want the stack.

---

## OnLoginSchedules

```lua
detailsFramework.OnLoginSchedules[#detailsFramework.OnLoginSchedules+1] = function()
    -- runs once, one frame after PLAYER_LOGIN
end
```

Use this when you need other addons to be loaded first (DBM, BigWigs, OpenRaidLib, etc.). The framework itself uses it to install boss-mod callbacks for encounter phase/timer integration via `RegisterEncounterPhaseChange` and `RegisterEncounterTimeBar`.

---

## Debug & diagnostics

| Method | Purpose |
|---|---|
| `DF:Msg(msg, ...)` / `DF:MsgWarning(msg, ...)` | Pretty-printed framework chat output prefixed by `self.__name or "Details!Framework"`. |
| `DF:Error(text)` | Red prefixed error including `self:GetName()`, `self.WidgetType`, and a stack snippet. |
| `DF:DebugVisibility(obj)` | Prints `IsShown`, `IsVisible`, alpha, size, anchor count — first thing to call when a frame "should be visible but isn't". |
| `DF:DebugTexture(t, l, r, t, b)` / `DF:PreviewTexture(...)` | Shows `DetailsFrameworkTexturePreview` in the center of the screen with the given texture path, atlas, or `|T…|t` escape sequence. |
| `DF.DebugMixin` | A mixin with `CheckPoint(name, ...)`, `CheckVisibilityState(widget?)`, `CheckStack()`. |
| `_G.__benchmark(bNoPrint?)` | Toggling global benchmark. First call captures `debugprofilestop`; second call returns elapsed ms (and prints unless `bNoPrint`). |

`DF:SetFrameworkDebugState(true)` flips `DF.debug` — several functions (notably `AddMemberForWidget`) only call `error()` for invalid input when this is on.

---

## Misc helpers

| Method | Returns / Purpose |
|---|---|
| `DF:Mixin(object, ...)` | Thin wrapper over Blizzard's `Mixin` (copy named methods). |
| `DF:MixinX(object, ...)` | Special-cased mixin that calls `_G[k]()` for keys that match global function names, normalises hex strings to `{r,g,b,a}` tables, and exposes a single-letter alias (`object[k:sub(1,1)]`). Niche — used by certain script utilities. |
| `DF:GetCursorPosition()` | `(x, y)` scaled by `UIParent:GetEffectiveScale()`. |
| `DF:GetSizeFromPercent(uiObject, percent)` | `min(width, height) * percent` — useful when scaling an icon proportional to its parent. |
| `DF:GetNpcIdFromGuid(GUID)` | Splits the GUID and returns field 6 as a number; `0` if missing. |
| `DF:IsUnitTapDenied(unitId)` | True if a non-player-controlled mob is tap-denied (gray health). |
| `DF:GetWorldDeltaSeconds()` | The most recent delta-time from the framework's hidden updater frame — handy when your code doesn't have its own OnUpdate. |
| `DF:GroupIterator(callback, ...)` | Calls `callback(unitId, ...)` for each group member through `QuickDispatch`. Switches between `"raid1..N"`, `"party1..N-1"+"player"`, and `"player"` solo. |
| `DF:GetDurability()` | `(avgPercent, lowestPercent)` across `INVSLOT_FIRST_EQUIPPED..INVSLOT_LAST_EQUIPPED`. |
| `DF:GetBattlegroundSize(instanceMapId)` | Look up `DF.BattlegroundSizes`. |
| `DF:GetArmorIconByArmorSlot(slotId)` | Hardcoded icon path per slot id. |
| `DF:GetParentKeyPath(object)` / `DF:GetParentNamePath(object)` | Walk parents producing a dotted path. Used by the editor system for stable widget identity. |
| `DF:SortOrder1`/`2`/`3` / `…R` | Comparators for `table.sort` over `t[1]`/`t[2]`/`t[3]` (descending; `R` variants ascending). |
| `DF:GetCLEncounterIDs()` | The cross-realm encounter list. |

`DF:CreateOptionsFrame(name, title, template)` is **deprecated** — see `addon.md` for the current options-panel setup.

`DF.CatchString(...)` is a `string.char` shim — on pre-Dragonflight it bails out (returning early), otherwise calls `string.char(...)`. Only used by very old code paths.

---

## Pitfalls

### Calling `DF:Embed` before all DF files have loaded
`embedFunctions` is iterated *eagerly*: `target[v] = self[v]`. If `CreateScrollBox` (defined in `scrollbox.lua`) hasn't been registered into `DF` yet because that file hasn't run, `target.CreateScrollBox` gets set to `nil` — silently. Subsequent calls to `target:CreateScrollBox` will nil-error.

**Symptom**: a previously-working consumer suddenly throws `attempt to call method 'CreateScrollBox' (a nil value)` after a load-order shuffle.

**Fix**: ensure all sibling `*.lua` are listed before the consumer in your `.toc`, or call `DF:Embed(target)` from the consumer's `PLAYER_LOGIN` schedule rather than at file-load time.

### Version-check functions are functions, not booleans
```lua
-- WRONG — always true:
if DF.IsDragonflightAndBeyond then ... end
-- RIGHT:
if DF.IsDragonflightAndBeyond() then ... end
```

Easy to miss because half the framework reads `DF.something` as a plain field. Every name starting with `Is…Wow`, `Is…WowAPI`, `ExpansionHas…` is a function.

### `DF.table.copy` recurses into UIObjects; `DF.table.duplicate` doesn't
Tables that hold frames will be recursively traversed by `copy`, which is almost certainly *not* what you want — you'll end up duplicating font strings or, worse, recursing into a metatable. Use `duplicate` for any structure that mixes data and frames, and `copy` only for pure data tables.

### `DF.table.setfrompath` silently succeeds on partial paths but doesn't create missing keys
If the path is `"a.b.c"` and `t.a` is `nil`, the loop walks off `nil` and `lastTable`/`lastKey` are still set from the first iteration — so the function will write `t.a = value` and return `true`. You won't get the intermediate node creation.

**Fix**: ensure every parent on the path exists before calling `setfrompath`, or guard with `getfrompath` to verify the structure first.

### `GetTextWidth` is not reentrant
`dummyFontString` is a single shared FontString. If two pieces of code measure text in the same frame (e.g. a nested OnUpdate triggers a layout pass that also measures), they'll clobber each other's intermediate state. Read the width before calling anything that might recurse.

### `DF:SetTemplate` hooks accumulate
`SetTemplate` calls `frame:HookScript("OnEnter", templateOnEnter)` every time the template specifies `onentercolor`. The guard flags `__has_onentercolor_script` / `__has_onleavecolor_script` prevent re-hooking the same script, **but only for the same color key** — applying a second template with a different `onenterbordercolor` will re-hook OnEnter for that border path independently. After enough template swaps you'll have multiple OnEnter callbacks firing per mouse-over.

**Fix**: apply templates once at construction; if you need to swap templates, use `frame:SetScript("OnEnter", nil)` then re-mix the new template.

### `ParseColors` returns `Saturate`d numbers — input out of [0,1] is silently clamped
If you pass `(255, 128, 0)` thinking you're using 0–255, you'll get back `(1, 1, 0)`. The function does not attempt to detect range. Use hex strings or normalized floats.

### `DF.alias_text_colors.none` is the fallback for unrecognised color strings
If you typo a color name (`"redd"` instead of `"red"`) `ParseColors` returns whatever `none` is set to (white by default). No error, no warning. If colors look wrong, double-check the spelling.

### `CreateFrameShake` requires `PlayFrameShake` on the parent, not on the shake
The methods (`PlayFrameShake`, `StopFrameShake`, `UpdateFrameShake`, `SetFrameShakeSettings`) are attached to **`parent`**, not to the returned `shakeObject`. The shake object is just the data table. Save the parent reference if it's not the obvious widget.

### `OnLoginSchedules` only fires once
Don't register handlers that need to re-run on `/reload` separately — `PLAYER_LOGIN` fires after every reload, so the schedule runs again. But if you register additional functions after the first `PLAYER_LOGIN` fires (e.g. lazy-load an addon module), they will *not* be invoked. Register at file load.

### Script comms silently drop when libs are missing
If `AceComm-3.0`, `AceSerializer-3.0`, or `LibDeflate` aren't available, both `RegisterScriptComm` and `SendScriptComm` short-circuit without errors. If your script comm isn't working and the bus seems "asleep", verify all three libs are loaded.

### `DF.folder` can be wrong if the file isn't named `fw.lua`
The detection uses `debugstack(1, 1, 0):match("AddOns\\(.+)fw.lua")`. If someone renames the file or repackages the lib under a different filename, `DF.folder` is the cached old value or `""`. Always-pass-along paths via `DF:GetFrameworkFolder()` rather than re-deriving in consumers.

### `CreateAnimationHub`'s `onFinished` is also installed as `OnStop`
```lua
newAnimation:SetScript("OnFinished", onFinished)
newAnimation:SetScript("OnStop",     onFinished)
```
If you call `hub:Stop()` programmatically, your `onFinished` callback will fire — same as natural completion. If you need to distinguish, check `hub:IsPlaying()` inside the callback (it will be false in both cases) or pass state explicitly via `hub.foo = …` and clear in one branch.

### Hardcoded specInformation entries lag behind the live game
The `specInformation` table is hardcoded for known spec IDs at code-write time. A new spec or icon (e.g. the demo Devourer hero spec at `1480`) requires editing fw.lua. If `DF:GetSpecInfoFromSpecId(newId)` returns `nil`, that's why.

---

## Available animation types (`DF:CreateAnimation`)

| Type | Effect | Arguments |
|---|---|---|
| `"Alpha"` | Fade in/out | `fromAlpha, toAlpha` |
| `"Scale"` | Scale around an origin | `fromX, fromY, toX, toY, originPoint, originXOffset, originYOffset` |
| `"Translation"` | Move by offset | `xOffset, yOffset` |
| `"Rotation"` | Rotate around origin | `degrees, originPoint, originXOffset, originYOffset` |
| `"Path"` | Move along a curve | `_, xOffset, yOffset, curveType` |
| `"VertexColor"` / `"Color"` | Tween texture color | `r1, g1, b1, a1, r2, g2, b2, a2` (or two color tables in `r1`/`g1`) |

---

## Available anchor sides (1–17)

| # | Name | SetPoint |
|---|---|---|
| 1 | Top Left | `"bottomleft", anchorTo, "topleft", x, y` |
| 2 | Left | `"right", "left"` |
| 3 | Bottom Left | `"topleft", "bottomleft"` |
| 4 | Bottom | `"top", "bottom"` |
| 5 | Bottom Right | `"topright", "bottomright"` |
| 6 | Right | `"left", "right"` |
| 7 | Top Right | `"bottomright", "topright"` |
| 8 | Top | `"bottom", "top"` |
| 9 | Center | `"center", "center"` |
| 10 | Inside Left | `"left", "left"` |
| 11 | Inside Right | `"right", "right"` |
| 12 | Inside Top | `"top", "top"` |
| 13 | Inside Bottom | `"bottom", "bottom"` |
| 14 | Inside Top Left | `"topleft", "topleft"` |
| 15 | Inside Bottom Left | `"bottomleft", "bottomleft"` |
| 16 | Inside Bottom Right | `"bottomright", "bottomright"` |
| 17 | Inside Top Right | `"topright", "topright"` |

---

## Usage Examples

### Basic — embed and create a simple panel
```lua
local DF = LibStub("DetailsFramework-1.0")
local MyAddon = {}
DF:Embed(MyAddon)

local panel = MyAddon:CreateSimplePanel(UIParent, 400, 200, "My Panel")
MyAddon:CreateLabel(panel, "Hello", 16, "white"):SetPoint("center", panel, "center")
MyAddon:CreateButton(panel, function()
    print("clicked")
end, 100, 22, "Click me"):SetPoint("bottom", panel, "bottom", 0, 10)
```

### Color round-trip
```lua
-- Register a named color
DF:NewColor("myorange", 1, 0.55, 0.1, 1)

-- All four of these end up at the same numbers:
local r, g, b, a = DF:ParseColors("myorange")
local r, g, b, a = DF:ParseColors({1, 0.55, 0.1})
local r, g, b, a = DF:ParseColors({r=1, g=0.55, b=0.1})
local r, g, b, a = DF:ParseColors("#FF8C1A")

-- Wrap text with it:
local colored = DF:AddColorToText("Look at me", "myorange")
```

### Pool of frames anchored to a parent
```lua
local frames = DF:CreatePool(function(self, parent)
    local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    f:SetSize(120, 22)
    f:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]]})
    f:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    return f
end, MyAddon.frame)

frames:SetOnAcquire(function(frame) frame:Show() end)
frames:SetOnRelease(function(frame) frame:Hide() end)

local function refreshList(items)
    frames:Reset()
    for i, item in ipairs(items) do
        local f, isNew = frames:Get()
        if isNew then
            f.text = f:CreateFontString(nil, "overlay", "GameFontNormal")
            f.text:SetPoint("left", f, "left", 4, 0)
        end
        f.text:SetText(item.name)
        f:ClearAllPoints()
        f:SetPoint("topleft", MyAddon.frame, "topleft", 4, -22*(i-1) - 24)
    end
end
```

### Frame shake on damage taken
```lua
local shake = DF:CreateFrameShake(MyHealthBar,
    0.4,    -- duration
    4,      -- amplitude
    8,      -- frequency
    false,  -- absolute sine X
    false,  -- absolute sine Y
    1,      -- scaleX
    0.4,    -- scaleY (less vertical)
    0.05,   -- fade in
    0.1     -- fade out
)

-- later:
MyHealthBar:PlayFrameShake(shake)
```

### Install a custom button template
```lua
DF:InstallTemplate("button", "MY_DANGER_BUTTON", {
    backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1,
                bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tile = true, tileSize = 64},
    backdropcolor       = {0.40, 0.10, 0.10, 0.8},
    backdropbordercolor = {0.90, 0.20, 0.20, 1.0},
    onentercolor        = {0.60, 0.15, 0.15, 0.9},
    onenterbordercolor  = {1.00, 0.50, 0.50, 1.0},
}, "OPAQUE_DARK")

local btn = MyAddon:CreateButton(parent, callback, 120, 22, "Delete")
btn:SetTemplate("MY_DANGER_BUTTON")
```

### Script comm
```lua
DF:RegisterScriptComm("MY_ROSTER_PING", function(sourcePlayerName, score, region)
    if region == DF:GetClientRegion() then
        print(sourcePlayerName, "scored", score)
    end
end)

-- Anywhere:
DF:SendScriptComm("MY_ROSTER_PING", 9000, DF:GetClientRegion())
```

### Defer setup until login
```lua
detailsFramework.OnLoginSchedules[#detailsFramework.OnLoginSchedules+1] = function()
    if _G.DBM then
        _G.DBM:RegisterCallback("DBM_SetStage", function(_, _, _, phase)
            -- safe: DBM is loaded
        end)
    end
end
```

---

## Notes for AI readers

1. **Always check if a method exists in `embedFunctions` before suggesting it as a member call.** If it's only on `DF` and not in the embed whitelist, consumers must call `DetailsFramework:Foo()` rather than `self:Foo()`.
2. **All `IsXxxWow` flags are functions.** Never recommend `if DF.IsDragonflightWow then …` — it's always truthy.
3. **`DF.table.copy` and `DF.table.duplicate` are not equivalent.** If the table can contain frames, use `duplicate`. If it's pure data, `copy` is fine.
4. **Color inputs are polymorphic but `Saturate`d.** Don't recommend 0–255 RGB values to `SetVertexColor` callers — `ParseColors` will clip to 1.
5. **The `Toc` integer is the version gate.** Don't suggest `WOW_PROJECT_ID` checks where the framework already does a clean `Toc` range — use `IsDragonflightAndBeyond()` etc.
6. **Pools return `(object, bIsNew)`.** Don't drop the second return when a freshly-allocated object needs first-time wiring.
7. **`SetTemplate` re-hooks `OnEnter`/`OnLeave` on every call** for color keys it hasn't seen on this frame. Apply templates once, not in an update loop.
8. **The framework caches `DF.folder` from `debugstack`.** Don't recommend hardcoding `Interface\AddOns\Details\Libs\DF\` in a consumer — use `DF:GetFrameworkFolder()`.
9. **Hardcoded `specInformation` may not cover newly-released specs.** If `GetSpecInfoFromSpecId` returns nil for a "current" spec, the table needs an update; don't recommend the lookup as authoritative.
10. **The "secure environment" is not a sandbox.** Don't pitch `DF:MakeFunctionSecure` as a security boundary — it's a guard against accidental damage.

---

## See also

- `anchorsystem.md` — screen-anchor manager built on `df_anchor` / `DF:SetAnchor`.
- `pools.md` — extended docs for `df_pool`.
- `helpers.md` — flat-style API reference for the role/spec/durability helpers.
- `languages.md` — locale handling that complements `DF:GetClientRegion` / `DF:GetBestFontPathForLanguage`.
- `math.md` — `DF.Math.GetNinePoints` used by `ConvertAnchorOffsets`.
- `addon.md` — the addon-options panel surface (`DF:CreateAddOn`, `OpenInterfaceProfile`).
- `editor.md` — canonical consumer of `DF.table.getfrompath` / `setfrompath` for path-based profile editing.
- `buildmenu.md` — large options-builder that composes many widgets from this file's templates.
- `scrollbox.md`, `tabcontainer.md`, `label.md`, `button.md`, `dropdown.md`, `slider.md`, `textentry.md` — widget constructors referenced by `embedFunctions`.
- `Details/classes/spells/spells_main.lua` — `LIB_OPEN_RAID_COOLDOWNS_INFO` referenced by `DF:GetAvailableSpells`.
