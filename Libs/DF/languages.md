# Language System Documentation

## Overview

`DF.Language` is a localization system that manages translated text across addons. It provides:

- **Language registration**: addons register language tables keyed by language IDs (e.g. `"enUS"`, `"frFR"`)
- **Phrase lookup with fallback**: text is resolved from the current language → game client language → `"enUS"`, in that order
- **Automatic UI updates**: UI objects and table keys registered with the system are automatically updated when the active language changes
- **Font management**: fonts are swapped automatically when switching between language regions (Latin, Cyrillic, CJK)
- **LocTable**: a portable reference to a localization phrase that can be passed around instead of raw strings

All functions live under `DetailsFramework.Language` (aliased as `DF.Language`).

---

## Architecture

### Addon Namespace

Each addon that uses the language system has an **addon namespace** — an internal table stored in `DF.Language.RegisteredNamespaces[addonId]`. The `addonId` can be any string or table.

An addon namespace contains:

| Field | Type | Description |
|---|---|---|
| `addonId` | `string` or `table` | The identifier for the addon. |
| `currentLanguageId` | `string` | The active language. |
| `languages` | `table<string, table>` | Map of `languageId` → language table (phrase translations). |
| `defaultLanguageTable` | `table` or `false` | The first language table registered. Non-default tables fall back to it via `__index`. |
| `registeredObjects` | `table` | Map of UI object → `phraseInfoTable`. |
| `tableKeys` | `table` (weak keys) | Map of `table` → `{key → phraseInfoTable}`. Weak on the table reference. |
| `fonts` | `table<string, string>` | Map of `languageId` → font file path. |
| `callbacks` | `table` | Array of `{callback, payload}` entries triggered on language change. |
| `onLanguageChangeCallback` | `function` or `nil` | Callback set by the language selector dropdown. |
| `options` | `table` | Per-addon options (e.g. `ChangeOnlyRegisteredFont`). |

### PhraseInfoTable

Internally, registered objects and table keys each have a `phraseInfoTable`:

| Field | Type | Description |
|---|---|---|
| `phraseId` | `string` | The phrase key to look up in language tables. |
| `key` | `any` or `nil` | The table key (for table key registrations). |
| `arguments` | `table` or `nil` | Arguments for `string.format(text, ...)`. |

### Language Fallback Chain

When resolving a `phraseId`, the system tries in order:

1. **Current language** (`currentLanguageId`)
2. **Game client language** (`GetLocale()`)
3. **English** (`"enUS"`)

If none have the phrase, returns `false`.

### Default Language Table and __index Fallback

The **first** language table registered for an addon becomes the `defaultLanguageTable`. All subsequently registered language tables get a metatable with `__index` that:

1. Checks `rawget(table, key)` — returns the translation if present.
2. Falls back to `defaultLanguageTable[key]` — returns the default translation.
3. Returns the key itself as a string — prevents nil errors, showing the phraseId as-is.

This means accessing a language table directly (e.g. `L["SOME_KEY"]`) always returns a string, never nil.

---

## Registering Languages

### RegisterLanguage

```lua
local languageTable = DF.Language.RegisterLanguage(addonId, languageId, bNotSupportedWoWLanguage, languageName, languageFont)
```

| # | Name | Type | Required | Description |
|---|---|---|---|---|
| 1 | `addonId` | `string` or `table` | yes | Addon identifier. |
| 2 | `languageId` | `string` | yes | Language code. Standard WoW codes (`"enUS"`, `"frFR"`, etc.) or custom if `bNotSupportedWoWLanguage` is true. |
| 3 | `bNotSupportedWoWLanguage` | `boolean` | no | If true, registers a non-native game language. Requires `languageName` and `languageFont`. |
| 4 | `languageName` | `string` | conditional | Display name for the language (required if `bNotSupportedWoWLanguage`). |
| 5 | `languageFont` | `string` | conditional | Font file path (required if `bNotSupportedWoWLanguage`). |

**Returns**: A language table (plain Lua table) to populate with phrase translations.

**Behavior**:

1. Creates or retrieves the addon namespace.
2. If the `languageId` matches the game client language (`GetLocale()`), sets it as the current language.
3. Creates an empty table and stores it in `addonNamespace.languages[languageId]`.
4. The first language registered becomes the `defaultLanguageTable`. Subsequent tables get a metatable that falls back to the default.
5. For non-WoW languages, registers the font and adds it to `languagesAvailable` for the dropdown.
6. Schedules character registration (for language detection) via `C_Timer.After(0, ...)`.

**Example — Registering multiple languages**:

```lua
local addonId = "MyAddon"

-- Register English (will be the default language table since it's first)
local enUS = DF.Language.RegisterLanguage(addonId, "enUS")
enUS["OPTIONS_TITLE"] = "Options"
enUS["GREETING"] = "Hello, %s!"

-- Register French
local frFR = DF.Language.RegisterLanguage(addonId, "frFR")
frFR["OPTIONS_TITLE"] = "Options"
frFR["GREETING"] = "Bonjour, %s!"
-- Keys not in frFR fall back to enUS via __index
```

---

## Retrieving Localized Text

### GetLanguageTable

```lua
local L = DF.Language.GetLanguageTable(addonId [, languageId])
```

| # | Name | Type | Required | Description |
|---|---|---|---|---|
| 1 | `addonId` | `string` or `table` | yes | Addon identifier. |
| 2 | `languageId` | `string` | no | Specific language. If omitted, uses the current language for the addon. |

**Returns**: The language table for the requested language.

Because non-default language tables have a `__index` metatable, accessing any key always returns a string — either the translation, the default language's translation, or the key itself.

```lua
local L = DF.Language.GetLanguageTable("MyAddon")
print(L["OPTIONS_TITLE"])  -- "Options" (or translated equivalent)
print(L["NONEXISTENT_KEY"])  -- "NONEXISTENT_KEY" (returned as-is by __index)
```

### GetText

```lua
local text, languageId = DF.Language.GetText(addonId, phraseId [, silent])
```

| # | Name | Type | Required | Description |
|---|---|---|---|---|
| 1 | `addonId` | `string` or `table` | yes | Addon identifier. |
| 2 | `phraseId` | `string` | yes | The phrase key. |
| 3 | `silent` | `boolean` | no | If true, returns `phraseId` instead of erroring when the phrase is missing. |

**Returns**: The translated string and the `languageId` where it was found.

**Fallback order**: current language → game client language → `"enUS"`. If not found anywhere and `silent` is false, throws an error. If `silent` is true, returns the `phraseId` string itself.

**Embedded phraseId**: Supports inline phrase references with `@phraseId@` syntax. If a phraseId contains `@SOME_KEY@`, the system extracts `SOME_KEY`, looks it up, and replaces the `@SOME_KEY@` portion in the original string.

```lua
local text = DF.Language.GetText("MyAddon", "OPTIONS_TITLE")
local text = DF.Language.GetText("MyAddon", "MAYBE_MISSING", true)  -- returns "MAYBE_MISSING" if not found
```

### DoesPhraseIDExistsInDefaultLanguage

```lua
local exists = DF.Language.DoesPhraseIDExistsInDefaultLanguage(addonId, phraseId)
```

Checks whether the `phraseId` exists in the addon's default language table (the first one registered). Uses `rawget` — does not trigger `__index` fallback.

---

## Switching Languages

### SetCurrentLanguage

```lua
DF.Language.SetCurrentLanguage(addonId, languageId)
```

Changes the active language for an addon. This triggers a full update:

1. Sets `currentLanguageId` on the addon namespace.
2. Calls the `onLanguageChangeCallback` (set by the language selector dropdown) with `(languageId, addonId)`.
3. Triggers all registered callbacks via `RegisterCallback` with `(addonId, languageId, ...payload)`.
4. Iterates all registered objects and calls `SetText` with the new translation. Also changes fonts if the language region changed.
5. Iterates all registered table keys and updates `table[key]` with the new translation.

### GetLanguageIdForAddonId

```lua
local languageId = DF.Language.GetLanguageIdForAddonId(addonId)
```

Returns the current active `languageId` for the addon. Returns `"enUS"` if the addon is not registered.

---

## Language Selector Dropdown

### CreateLanguageSelector

```lua
local dropdown = DF.Language.CreateLanguageSelector(addonId, parent, callback, selectedLanguage)
```

| # | Name | Type | Required | Description |
|---|---|---|---|---|
| 1 | `addonId` | `string` or `table` | yes | Addon identifier. |
| 2 | `parent` | `frame` | yes | Parent frame for the dropdown. |
| 3 | `callback` | `function` | yes | Called when language changes: `callback(languageId, addonId)`. |
| 4 | `selectedLanguage` | `string` or `nil` | no | Pre-selected language. Defaults to the addon's current language. |

**Returns**: A DF dropdown widget. The dropdown also has a `.languageLabel` child (a `df_label` showing "Language:").

**When the user selects a language**:

1. `DF.Language.SetCurrentLanguage` is called → all registered objects and table keys are updated.
2. After 0.5 seconds, the dropdown re-selects the chosen language (to update its display text).
3. The `callback` fires.

The dropdown is populated with all languages registered for the addon, using display names and fonts from the internal `languagesAvailable` table.

---

## Callbacks

### RegisterCallback

```lua
DF.Language.RegisterCallback(addonId, callback, ...)
```

Registers a callback to fire whenever the language changes for the given addon. The callback is invoked via `xpcall` (error-safe) with parameters: `callback(addonId, languageId, ...payload)`.

The `...` varargs are stored as payload and unpacked into each callback invocation.

### UnregisterCallback

```lua
DF.Language.UnregisterCallback(addonId, callback)
```

Removes a previously registered callback. Matches by function reference.

---

## Object Registration

Registered objects are UI objects (fontstrings, buttons, or any table with a `SetText` method) that automatically update their text when the active language changes.

### RegisterObject

```lua
DF.Language.RegisterObject(addonId, object, phraseId [, silent [, ...]])
```

| # | Name | Type | Required | Description |
|---|---|---|---|---|
| 1 | `addonId` | `string` or `table` | yes | Addon identifier. |
| 2 | `object` | `table` with `SetText` | yes | The UI object. |
| 3 | `phraseId` | `string` | yes | The phrase key to resolve. |
| 4 | `silent` | `boolean` | no | If true, uses `phraseId` as text when the phrase is missing instead of erroring. |
| 5+ | `...` | `any` | no | Arguments for `string.format(translatedText, ...)`. |

**Behavior**:

1. Stores the object and its `phraseInfoTable` in `addonNamespace.registeredObjects[object]`.
2. Sets internal members on the object: `__languageAddonId`, `__languagePhraseId`, `__languageArguments`, `__languageId`.
3. Adds a `SetTextByPhraseID(phraseId, ...)` method to the object for later phrase changes.
4. Immediately resolves the phrase and calls `object:SetText(formattedText)`.
5. If the language region differs from the object's current font, swaps the font.

If the object was already registered, updates its phraseId and arguments.

### RegisterObjectWithDefault

```lua
DF.Language.RegisterObjectWithDefault(addonId, object, phraseId, defaultText [, ...])
```

**Helper function.** If `phraseId` is truthy, calls `RegisterObject`. If `phraseId` is nil/false, calls `object:SetText(defaultText)` directly. This is useful when a phrase might not exist.

### UpdateObjectArguments

```lua
DF.Language.UpdateObjectArguments(addonId, object, ...)
```

Updates the format arguments for a previously registered object and immediately re-renders the text. The object must already be registered via `RegisterObject`.

### SetTextByPhraseID (on registered objects)

After registration, each object gains a method:

```lua
object:SetTextByPhraseID(phraseId, ...)
```

This updates the object's phraseId and arguments, resolves the text, and updates the display. It uses the `addonId` stored in `object.__languageAddonId`.

---

## Table Key Registration

Table key registration allows the system to automatically update values inside Lua tables (e.g. tooltip text, dropdown labels) when the language changes.

Internally, table keys are stored in `addonNamespace.tableKeys` — a weak-keyed table (`__mode = "k"`) so that tables can be garbage-collected.

### RegisterTableKey

```lua
DF.Language.RegisterTableKey(addonId, table, key, phraseId [, silent [, ...]])
```

| # | Name | Type | Required | Description |
|---|---|---|---|---|
| 1 | `addonId` | `string` or `table` | yes | Addon identifier. |
| 2 | `table` | `table` | yes | The Lua table containing the key. |
| 3 | `key` | `any` (not nil/boolean) | yes | The key in the table to update. |
| 4 | `phraseId` | `string` | yes | The phrase key. |
| 5 | `silent` | `boolean` | no | If true, uses `phraseId` as text on missing phrase. |
| 6+ | `...` | `any` | no | Arguments for `string.format`. |

**Behavior**: Stores the registration, resolves the phrase, and sets `table[key] = formattedText`. On language change, `table[key]` is automatically reassigned.

### RegisterTableKeyWithDefault

```lua
DF.Language.RegisterTableKeyWithDefault(addonId, table, key, phraseId, defaultText [, ...])
```

**Helper function.** If both `addonId` and `phraseId` are truthy, calls `RegisterTableKey`. Otherwise sets `table[key] = defaultText`.

### UpdateTableKeyArguments

```lua
DF.Language.UpdateTableKeyArguments(addonId, table, key, ...)
```

Updates the format arguments for a previously registered table key and re-renders the text.

---

## LocTable System

A **LocTable** is a lightweight table that encapsulates a reference to a localization phrase. It can be passed to DF widget constructors (like `CreateLabel`) in place of a raw text string, enabling automatic registration and updates.

### Creating a LocTable

```lua
local locTable = DF.Language.CreateLocTable(addonId, phraseId [, shouldRegister [, silent [, ...]]])
```

| # | Name | Type | Required | Default | Description |
|---|---|---|---|---|---|
| 1 | `addonId` | `string` or `table` | yes | — | Addon identifier. |
| 2 | `phraseId` | `string` | yes | — | The phrase key. |
| 3 | `shouldRegister` | `boolean` or `nil` | no | `true` | Whether objects using this locTable should be auto-registered for language updates. |
| 4 | `silent` | `boolean` | no | — | If true, no error on missing phrase. |
| 5+ | `...` | `any` | no | — | Format arguments. |

**Returns**: A locTable or `nil` (if silent and phrase not found).

A locTable is a plain table with these fields:

| Field | Type | Description |
|---|---|---|
| `addonId` | `string` or `table` | The addon identifier. |
| `phraseId` | `string` | The phrase key. |
| `shouldRegister` | `boolean` | Whether to register objects for auto-update. |
| `arguments` | `table` or `nil` | Format arguments. |

### LocTable Utility Functions

#### IsLocTable

```lua
local isLoc = DF.Language.IsLocTable(value)
```

Returns `true` if the value is a table with both `addonId` and `phraseId` fields.

#### CanRegisterLocTable

```lua
local canRegister = DF.Language.CanRegisterLocTable(locTable)
```

Returns the `shouldRegister` field. Errors if not a valid locTable.

#### UnpackLocTable

```lua
local addonId, phraseId, shouldRegister, arguments = DF.Language.UnpackLocTable(locTable)
```

Extracts all fields from a locTable.

### Using LocTables with Objects

#### SetTextWithLocTable

```lua
DF.Language.SetTextWithLocTable(object, locTable)
```

If the locTable has `shouldRegister = true`, calls `RegisterObjectWithLocTable` (registers the object for auto-updates). Otherwise, resolves the text and calls `SetText` directly without registering.

#### SetTextWithLocTableWithDefault

```lua
DF.Language.SetTextWithLocTableWithDefault(object, locTable, defaultText)
```

If `locTable` is a valid locTable, calls `SetTextWithLocTable`. Otherwise, calls `object:SetText(defaultText)`.

#### SetTextIfLocTableOrDefault

```lua
DF.Language.SetTextIfLocTableOrDefault(object, locTableOrString)
```

If the second argument is a locTable, calls `SetTextWithLocTable`. If it's a plain string, calls `object:SetText(string)`.

#### RegisterObjectWithLocTable

```lua
DF.Language.RegisterObjectWithLocTable(object, locTable [, silence])
```

Extracts `addonId`, `phraseId`, and `arguments` from the locTable and calls `RegisterObject`. Requires `shouldRegister = true`.

#### RegisterTableKeyWithLocTable

```lua
DF.Language.RegisterTableKeyWithLocTable(table, key, locTable [, silence])
```

Extracts fields from the locTable and calls `RegisterTableKey`. Requires `shouldRegister = true`.

### LocTable Integration with DF Widgets

When a DF widget constructor (e.g. `CreateLabel`) receives a locTable as the text parameter, the widget's label system detects it via `IsLocTable` and calls `RegisterObjectWithLocTable`, so the widget automatically updates when the language changes.

```lua
local locTable = DF.Language.CreateLocTable("MyAddon", "OPTIONS_TITLE")
local label = DF:CreateLabel(parent, locTable, 14, "white")
-- label is now registered and will auto-update on language change
```

---

## Font Management

The system handles font switching when the target language uses a different character set than the current font supports.

### Font Compatibility Groups

| Group ID | Languages | Default Font |
|---|---|---|
| 1 (Latin) | deDE, enUS, esES, esMX, frFR, itIT, ptBR | `Fonts\FRIZQT__.TTF` |
| 2 (Chinese Simplified) | zhCN | `Fonts\ARHei.ttf` |
| 3 (Chinese Traditional) | zhTW | `Fonts\ARHei.ttf` |
| 4 (Korean) | koKR | `Fonts\2002.TTF` |
| 5 (Cyrillic) | ruRU | `Fonts\FRIZQT___CYR.TTF` |

When a registered object's text changes to a different language group, the system automatically swaps the font on the fontstring/button.

### SetFontForLanguageId

```lua
DF.Language.SetFontForLanguageId(addonId, languageId, fontPath)
```

Registers a specific font file for a language within an addon namespace.

### SetFontByAlphabetOrRegion

```lua
DF.Language.SetFontByAlphabetOrRegion(addonId, latin, cyrillic, china, korean, taiwan)
```

Bulk-registers fonts by script region. Each parameter is a font path string (or nil to skip).

| Parameter | Sets font for |
|---|---|
| `latin` | deDE, enUS, esES, esMX, frFR, itIT, ptBR |
| `cyrillic` | ruRU |
| `china` | zhCN |
| `korean` | zhTW (note: code maps korean parameter to zhTW) |
| `taiwan` | zhTW |

### GetFontForLanguageID

```lua
local fontPath = DF.Language.GetFontForLanguageID(languageId [, addonId])
```

Returns a font path compatible with the given language. Checks the addon's registered fonts first (if `addonId` provided), then falls back to `languagesAvailable` defaults, then `"Fonts\FRIZQT__.TTF"`.

### Font Change Behavior

When `SetCurrentLanguage` updates registered objects, each object's font is checked:

1. Compare the font compatibility group of the old language vs the new language.
2. If the groups differ, look for a registered font for the new language.
3. If no font is registered and `ChangeOnlyRegisteredFont` option is false (default), use the default font from `GetFontForLanguageID`.
4. If `ChangeOnlyRegisteredFont` is true, only change the font if one was explicitly registered.
5. The font size and flags are preserved; only the font face changes.

---

## Options

### SetOption

```lua
DF.Language.SetOption(addonId, optionId, value)
```

### ShowOptionsHelp

```lua
DF.Language.ShowOptionsHelp()
```

Prints available option IDs and their descriptions.

| Option ID | Default | Description |
|---|---|---|
| `ChangeOnlyRegisteredFont` | `false` | When true, font changes on language switch only occur if a font was explicitly registered for that language via `SetFontForLanguageId` or `SetFontByAlphabetOrRegion`. |

---

## Language Detection

### DetectLanguageId

```lua
local languageId = DF.Language.DetectLanguageId(text)
```

Analyzes the characters in `text` against `DF.LanguageKnowledge` (a byte-code-to-languageId mapping built from registered language tables). Returns the first matching non-Latin language, or `"enUS"` as default.

---

## Differences Between Registration Methods

| Function | Registers for auto-update? | Handles missing phraseId | Target |
|---|---|---|---|
| `RegisterObject` | yes | errors (or uses phraseId if `silent`) | UI object with `SetText` |
| `RegisterObjectWithDefault` | yes, if phraseId is truthy | calls `SetText(defaultText)` if phraseId is nil | UI object with `SetText` |
| `RegisterTableKey` | yes | errors (or uses phraseId if `silent`) | `table[key]` |
| `RegisterTableKeyWithDefault` | yes, if addonId and phraseId are truthy | sets `table[key] = defaultText` if not | `table[key]` |
| `RegisterObjectWithLocTable` | yes | depends on locTable creation | UI object with `SetText` |
| `RegisterTableKeyWithLocTable` | yes | depends on locTable creation | `table[key]` |
| `SetTextWithLocTable` | yes, if `shouldRegister` is true | — | UI object with `SetText` |
| `SetTextWithLocTableWithDefault` | yes, if locTable is valid | falls back to `defaultText` | UI object with `SetText` |
| `SetTextIfLocTableOrDefault` | yes, if value is a locTable | treats value as plain string | UI object with `SetText` |

---

## Update Propagation Flow

When `SetCurrentLanguage(addonId, newLanguageId)` is called:

```
SetCurrentLanguage
  ├── set addonNamespace.currentLanguageId = newLanguageId
  ├── call onLanguageChangeCallback(languageId, addonId)       -- dropdown callback
  ├── call all RegisterCallback callbacks via xpcall            -- addon callbacks
  ├── updateAllRegisteredObjectsText                            -- iterate registeredObjects
  │     └── for each object:
  │           ├── getText(phraseId)                             -- resolve with fallback chain
  │           ├── check font compatibility group change
  │           │     └── swap font face if needed
  │           └── object:SetText(formattedText)
  └── updateAllRegisteredTableKeyText                           -- iterate tableKeys
        └── for each table[key]:
              ├── getText(phraseId)
              └── table[key] = formattedText
```

---

## Complete Example

```lua
local addonId = "MyAddon"

-- 1. Register languages (enUS first = default)
local enUS = DF.Language.RegisterLanguage(addonId, "enUS")
enUS["OPTIONS_TITLE"] = "Options Panel"
enUS["GREETING"] = "Hello, %s!"
enUS["STATUS_COUNT"] = "You have %d items"

local frFR = DF.Language.RegisterLanguage(addonId, "frFR")
frFR["OPTIONS_TITLE"] = "Panneau d'options"
frFR["GREETING"] = "Bonjour, %s!"
-- STATUS_COUNT not translated → falls back to enUS via __index

-- 2. Set fonts for regions
DF.Language.SetFontByAlphabetOrRegion(addonId,
    "Fonts\\FRIZQT__.TTF",      -- latin
    "Fonts\\FRIZQT___CYR.TTF",  -- cyrillic
    "Fonts\\ARHei.ttf",          -- china
    "Fonts\\2002.TTF",           -- korean
    "Fonts\\ARHei.ttf"           -- taiwan
)

-- 3. Retrieve text directly
local L = DF.Language.GetLanguageTable(addonId)
print(L["OPTIONS_TITLE"])  -- depends on current language

local text = DF.Language.GetText(addonId, "GREETING")

-- 4. Register UI objects for auto-update
local titleFontString = myFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
DF.Language.RegisterObject(addonId, titleFontString, "OPTIONS_TITLE")

-- With format arguments
local statusFontString = myFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
DF.Language.RegisterObject(addonId, statusFontString, "STATUS_COUNT", false, 42)
-- Displays: "You have 42 items"

-- Update arguments later
DF.Language.UpdateObjectArguments(addonId, statusFontString, 99)
-- Now displays: "You have 99 items"

-- 5. Register with default fallback
DF.Language.RegisterObjectWithDefault(addonId, someLabel, maybePhraseId, "Fallback Text")

-- 6. Register a table key
local tooltipData = { tooltip = "" }
DF.Language.RegisterTableKey(addonId, tooltipData, "tooltip", "OPTIONS_TITLE")
-- tooltipData.tooltip is now "Options Panel" (or translated)

-- 7. Use LocTables
local locTable = DF.Language.CreateLocTable(addonId, "OPTIONS_TITLE")
local label = DF:CreateLabel(parentFrame, locTable, 14, "white")
-- label auto-updates when language changes

-- 8. Create language selector dropdown
local dropdown = DF.Language.CreateLanguageSelector(addonId, parentFrame, function(languageId, addonId)
    print("Language changed to:", languageId)
end, "enUS")
dropdown:SetPoint("topright", parentFrame, "topright", -10, -10)

-- 9. Register a callback
DF.Language.RegisterCallback(addonId, function(addonId, languageId)
    print("Language is now:", languageId)
end)

-- 10. Check phrase existence before registering
if DF.Language.DoesPhraseIDExistsInDefaultLanguage(addonId, "MAYBE_KEY") then
    DF.Language.RegisterObject(addonId, someObject, "MAYBE_KEY")
else
    someObject:SetText("Default")
end
```
