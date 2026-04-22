# Saved Variables / Profile System

## Overview

The terms "saved variables" and "profiles" refer to the same system. In WoW, "saved variables" is the persistence mechanism — a global Lua table that WoW writes to disk between sessions. The DetailsFramework profile system builds on top of that mechanism to provide per‑character profile management: creating, switching, copying, and saving named sets of user settings.

All profile functions live in the `detailsFramework.SavedVars` namespace. They operate on a `df_addon` object created by `detailsFramework:CreateNewAddOn()` (documented in `addon.md`). The addon object holds a `.profile` field — a plain table of user settings — that code throughout the addon reads and writes. The profile system handles loading defaults on first run, stripping unchanged defaults before saving to keep the saved‑variable file small, and restoring defaults on the next load.

---

## Integration with the Addon Object

The profile system is not standalone. It depends on the addon object created by `detailsFramework:CreateNewAddOn(addonName, globalSavedVariablesName, savedVarsTemplate)`.

### Fields on `df_addon` Used by the Profile System

| Field | Set By | Description |
|---|---|---|
| `__name` | `CreateNewAddOn` | The addon's folder/ToC name. Used to filter `ADDON_LOADED` events. |
| `__savedGlobalVarsName` | `CreateNewAddOn` | The name of the global variable declared in the `.toc` file under `## SavedVariables:`. The profile system reads from and writes to `_G[this]`. |
| `__savedVarsDefaultTemplate` | `CreateNewAddOn` | A table of default settings. Used to fill missing keys on load and to strip unchanged keys on save. |
| `__frame` | `CreateNewAddOn` | A WoW frame that listens for lifecycle events. |
| `profile` | Lifecycle handler | The active profile table. Set during `ADDON_LOADED`, updated during `SetProfile`. All addon code reads/writes settings here. |
| `OnProfileChanged` | User‑defined | Optional callback. Called after `SetProfile` switches profiles. Signature: `function(addonObject, newProfileTable)`. |

### How `.profile` Gets Attached

`.profile` is **not** set by `CreateNewAddOn`. It is set later, during the `ADDON_LOADED` event handler in `addon.lua`:

1. The handler calls `GetSavedVariables` to retrieve (or create) the global saved table.
2. It looks up the current character's profile name from `profile_ids[playerGUID]`. If none exists, it assigns `"default"`.
3. It calls `GetProfile(addonObject, true)` to load (or create) the profile table, merging defaults.
4. It stores the result in `addonObject.profile`.
5. It calls `addonObject.OnLoad(self, profile, true)` if defined.

After this point, `addonObject.profile` is available for the rest of the session.

---

## Data Structures

### Global Saved Variables Table

This is the table stored in `_G[addonObject.__savedGlobalVarsName]`. WoW reads it from disk at login and writes it back on logout.

```
_G["YourAddonDatabase"] = {
    profile_ids = {
        ["Player-1234-ABCDEF"] = "default",
        ["Player-5678-GHIJKL"] = "raiding",
    },
    profiles = {
        ["default"] = {
            -- only user‑modified values (defaults are stripped on save)
            width = 800,
        },
        ["raiding"] = {
            name = "RaidMode",
            height = 300,
        },
    },
}
```

| Key | Type | Description |
|---|---|---|
| `profile_ids` | `table<string, string>` | Maps player GUID → profile name. Each character can use a different profile. Multiple characters can share the same profile name. |
| `profiles` | `table<string, table>` | Maps profile name → profile data table. Only user‑modified values are persisted; defaults are stripped before saving. |

### Profile Table (In‑Memory)

While in use, the profile table is the **merged** result of saved user values + defaults from `__savedVarsDefaultTemplate`. It also carries a `__loaded` flag:

| Key | Type | Description |
|---|---|---|
| *(user keys)* | any | Settings defined by the addon's default template and/or modified by the user. |
| `__loaded` | `boolean` | Internal flag. Set to `true` after defaults are merged. Removed before saving. Prevents re‑merging defaults on repeated `GetProfile` calls. |

### Default Template

The `savedVarsTemplate` passed to `CreateNewAddOn`. Example:

```lua
{
    width = 500,
    height = 500,
    name = "John",
}
```

This table is never modified. It serves two purposes:

1. **On load** — merged into the profile via `table.deploy` (non‑destructive: only fills keys that are `nil` in the profile).
2. **On save** — compared against the profile via `table.removeduplicate` to strip keys whose values match the defaults.

---

## Default Handling — Deploy and Strip

Two utility functions drive the default system:

### `detailsFramework.table.deploy(destination, source)`

Non‑destructive recursive merge. Copies keys from `source` into `destination` only where `destination[key]` is `nil`. Nested tables are recursed into (creating sub‑tables in `destination` as needed). Existing values in `destination` are never overwritten.

Used during **load** to fill a profile with any missing default values.

### `detailsFramework.table.removeduplicate(target, reference)`

Recursive in‑place deletion. Removes keys from `target` whose values equal the corresponding values in `reference`. For numbers, uses a fuzzy comparison (`IsNearlyEqual` with tolerance `0.0001`). Empty sub‑tables are removed after processing. Modifies `target` in place.

Used during **save** to strip default values from the profile so only user‑modified values are persisted.

### Round‑Trip Example

```
Default template:       { width = 500, height = 500, name = "John" }

On disk (first run):    { }   (empty — no saved data yet)

After deploy (load):    { width = 500, height = 500, name = "John", __loaded = true }

User changes width:     { width = 800, height = 500, name = "John", __loaded = true }

After removeduplicate:  { width = 800 }   ← only the changed value
  (save)                __loaded removed, height and name stripped (match defaults)

On disk:                { width = 800 }

Next login, deploy:     { width = 800, height = 500, name = "John", __loaded = true }
                        ↑ width preserved, defaults re‑filled
```

---

## Lifecycle

The full lifecycle from login to logout:

```
Login
  │
  ▼
ADDON_LOADED event fires
  │
  ├─ GetSavedVariables(addon)
  │    └─ reads _G[__savedGlobalVarsName]
  │       (creates empty table if first run)
  │
  ├─ Read profile_ids[playerGUID]
  │    └─ if nil → assign "default"
  │
  ├─ GetProfile(addon, true)
  │    ├─ look up profiles[profileId]
  │    ├─ if nil → create empty table
  │    ├─ table.deploy(profile, defaultTemplate)
  │    ├─ set __loaded = true
  │    └─ return profile
  │
  ├─ addon.profile = profile
  │
  └─ call addon.OnLoad(self, profile, true)
       │
       ▼
PLAYER_LOGIN event fires
  │
  └─ call addon.OnInit(self, profile)
       │
       ▼
  Session active
  ├─ addon code reads/writes addon.profile freely
  ├─ user may call SetProfile() to switch profiles
  │    ├─ saves current profile (SaveProfile)
  │    ├─ updates profile_ids[playerGUID]
  │    ├─ loads new profile (GetProfile, create if needed)
  │    ├─ addon.profile = new profile
  │    └─ calls addon.OnProfileChanged(addon, newProfile)
  │
       ▼
PLAYER_LOGOUT event fires (or /reload)
  │
  └─ SaveProfile(addon)
       ├─ table.removeduplicate(profile, defaultTemplate)
       ├─ remove __loaded flag
       └─ write profile into savedVariables.profiles[profileId]
            │
            ▼
       WoW writes _G[__savedGlobalVarsName] to disk
```

---

## Functions

### `GetSavedVariables(addonObject)`

**Purpose:** Retrieve (or create) the global saved variables table for the addon.

| Parameter | Type | Description |
|---|---|---|
| `addonObject` | `df_addon` | The addon object. |

**Returns:** `table` — the saved variables table. Returns an empty `{}` if `__savedGlobalVarsName` is not set on the addon object.

**Behavior:**

1. Reads `_G[addonObject.__savedGlobalVarsName]`.
2. If `nil` (first run), creates a new empty table and stores it in `_G[__savedGlobalVarsName]`.
3. Returns the table.

**System role:** Data access / initialization. Called during load, save, and profile switching.

---

### `GetCurrentProfileName(addonObject)`

**Purpose:** Get the profile name the current player character is using.

| Parameter | Type | Description |
|---|---|---|
| `addonObject` | `df_addon` | The addon object. |

**Returns:** `string` — the profile name (e.g. `"default"`), or `nil` if no profile has been assigned to the current character.

**Behavior:**

1. Calls `GetSavedVariables` to get the saved table.
2. Reads `savedVariables.profile_ids[UnitGUID("player")]`.
3. Returns the result.

**System role:** Data access. Used by the profile panel and during profile operations.

---

### `GetProfile(addonObject, bCreateIfNotFound, profileToCopyFrom)`

**Purpose:** Retrieve the profile table for the current character. Optionally creates it if missing.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `addonObject` | `df_addon` | Yes | The addon object. |
| `bCreateIfNotFound` | `boolean?` | No | If `true`, create an empty profile when the current character has no profile entry. |
| `profileToCopyFrom` | `table?` | No | If `bCreateIfNotFound` is `true` and this is provided, copy values from this table into the new profile via `table.deploy`. |

**Returns:** `table` or `nil` — the profile table. Returns `nil` if the profile does not exist and `bCreateIfNotFound` is false.

**Behavior:**

1. Gets the player GUID and looks up the profile name from `profile_ids`.
2. Looks up the profile table from `profiles[profileId]`.
3. If not found and `bCreateIfNotFound` is `true`:
   - Creates a new empty table.
   - If `profileToCopyFrom` is provided, deploys (copies) it into the new table.
4. If the profile exists (or was just created) and `__loaded` is not set, and the addon has a `__savedVarsDefaultTemplate`:
   - Calls `table.deploy(profileTable, defaultTemplate)` to fill missing defaults.
   - Sets `profileTable.__loaded = true`.
5. Returns the profile table.

**System role:** Initialization / profile switching. Called during `ADDON_LOADED` and `SetProfile`.

**Important:** The `__loaded` flag prevents defaults from being re‑deployed on repeated calls within the same session. It is removed during `SaveProfile`.

---

### `SetProfile(addonObject, profileName, bCopyFromCurrentProfile)`

**Purpose:** Switch the current character to a different profile.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `addonObject` | `df_addon` | Yes | The addon object. |
| `profileName` | `string` | Yes | Name of the profile to switch to. |
| `bCopyFromCurrentProfile` | `boolean?` | No | If `true`, copy the current profile's data into the new profile (only if the new profile is being created). |

**Returns:** Nothing.

**Behavior:**

1. Retrieves the current profile via `GetProfile`.
2. Saves the current profile via `SaveProfile` (strips defaults, writes to saved variables).
3. Updates `profile_ids[playerGUID]` to `profileName`.
4. Calls `GetProfile(addonObject, true, ...)` with `bCreateIfNotFound = true`. If `bCopyFromCurrentProfile` is `true`, passes the (already‑saved) current profile as the copy source.
5. Sets `addonObject.profile` to the new profile table.
6. If `addonObject.OnProfileChanged` is defined, dispatches it with `(addonObject, newProfileTable)`.

**System role:** Profile switching. Called by user action (profile panel dropdown or create button).

**Note:** If `profileName` matches an existing profile, that profile is loaded. If it does not exist, a new profile is created (optionally seeded from the current profile).

---

### `SaveProfile(addonObject)`

**Purpose:** Persist the current in‑memory profile to the saved variables table, stripping values that match the default template.

| Parameter | Type | Description |
|---|---|---|
| `addonObject` | `df_addon` | The addon object. |

**Returns:** Nothing.

**Behavior:**

1. Reads `addonObject.profile` via `rawget` (avoids metatables).
2. If the profile exists and `__loaded` is `true`:
   - If `__savedVarsDefaultTemplate` exists, calls `table.removeduplicate(profileTable, defaultTemplate)` to strip unchanged default values.
   - Sets `profileTable.__loaded = nil` (removes the flag so it is not persisted).
   - Looks up the character's profile ID from `profile_ids[playerGUID]`.
   - Writes the cleaned profile into `savedVariables.profiles[profileId]`.
3. If the profile does not exist or `__loaded` is not set, does nothing.

**System role:** Persistence. Called during `PLAYER_LOGOUT`, during `/reload`, and before switching profiles in `SetProfile`.

**Important:** After `SaveProfile`, the profile table no longer has defaults filled in. If the addon continues to run (e.g. `SetProfile` is being called), `GetProfile` is called again immediately after, which re‑deploys defaults and re‑sets `__loaded`.

---

### `CreateProfilePanel(addonObject, frameName, parentFrame, options)`

**Purpose:** Create a ready‑made UI panel for profile management. Users can view, select, and create profiles.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `addonObject` | `df_addon` | Yes | The addon object. |
| `frameName` | `string` | Yes | Global name for the frame. |
| `parentFrame` | `frame` | Yes | Parent frame. |
| `options` | `table?` | No | Panel options. Missing keys are filled from defaults. |

**Returns:** `df_profilepanel` — the profile management frame.

#### Panel Options

| Key | Type | Default | Description |
|---|---|---|---|
| `width` | `number` | `600` | Panel width. |
| `height` | `number` | `400` | Panel height. |
| `title` | `string` | `"Profile Management"` | Panel title (declared in defaults but not used visibly in the current code). |

#### What the Panel Contains

| Element | Type | Description |
|---|---|---|
| `ProfileNameValueLabel` | `FontString` | Displays the current profile name. |
| `ProfileSelectionDropdown` | `df_dropdown` | Dropdown listing all existing profiles. Selecting one calls `SetProfile`. |
| `ProfileNameTextEntry` | `df_textentry` | Text input for typing a new profile name. |
| Create button | `df_button` | Calls `OnClickCreateNewProfile` which creates/switches to the profile named in the text entry. |

The panel refreshes automatically on `OnShow` via `RefreshProfilePanel`. It starts hidden — call `:Show()` to display it.

#### Panel Fields

| Field | Type | Description |
|---|---|---|
| `AddonObject` | `df_addon` | Reference to the addon object. |
| `ProfileNameValueLabel` | `FontString` | Current profile name display. |
| `ProfileSelectionDropdown` | `df_dropdown` | Profile selection dropdown. |
| `ProfileNameTextEntry` | `df_textentry` | New profile name text entry. |

#### Panel Methods (from `profilePanelMixin`)

| Method | Description |
|---|---|
| `RefreshSelectProfileDropdown()` | Rebuilds the dropdown options from `savedVariables.profiles`, refreshes the dropdown, and selects the current profile. |
| `OnClickCreateNewProfile()` | Reads the text entry value, calls `SetProfile` with that name, then refreshes the panel. |

---

### `RefreshProfilePanel(profilePanel)`

**Purpose:** Refresh all elements of a profile panel to reflect the current addon state.

| Parameter | Type | Description |
|---|---|---|
| `profilePanel` | `df_profilepanel` | The panel created by `CreateProfilePanel`. |

**Returns:** Nothing.

**Behavior:**

1. Updates `ProfileNameValueLabel` with the current profile name.
2. Calls `RefreshSelectProfileDropdown()` on the panel to rebuild the dropdown.
3. Clears the `ProfileNameTextEntry` text field.

---

## Edge Cases

### First Run (No Saved Data)

When WoW has no saved file for the addon:

1. `GetSavedVariables` finds `_G[name]` is `nil` → creates a new empty table and assigns it to `_G[name]`.
2. `profile_ids` does not exist yet → the `ADDON_LOADED` handler accesses `savedVariables.profile_ids[playerGUID]`, which is `nil`.
3. The handler sets `profile_ids[playerGUID] = "default"`.
4. `GetProfile` finds `profiles["default"]` is `nil` → creates a new empty table (because `bCreateIfNotFound` is `true`).
5. `table.deploy` fills the empty table with all values from `__savedVarsDefaultTemplate`.
6. The profile is now fully populated with defaults.

### Missing Profile

If a character's `profile_ids` entry points to a profile name that no longer exists in `profiles`:

- `GetProfile` with `bCreateIfNotFound = true` creates a new empty profile for that name.
- Defaults are deployed into it.
- The character continues with a fresh default profile under the same name.

### No `__savedGlobalVarsName`

If the addon was created without a `globalSavedVariablesName`:

- `GetSavedVariables` returns an empty `{}`.
- The `ADDON_LOADED` handler calls `OnLoad` immediately and returns without setting up profiles.
- `addonObject.profile` is never set.

### No `__savedVarsDefaultTemplate`

If no template was provided (or it is empty):

- `GetProfile` skips the `table.deploy` step (nothing to merge).
- `SaveProfile` skips the `table.removeduplicate` step (nothing to strip).
- The profile is saved as‑is with all keys.

### Saving a Profile That Was Never Loaded

`SaveProfile` checks `profileTable.__loaded`. If `__loaded` is not `true`, the function does nothing. This prevents saving a profile that was never initialized through `GetProfile`.

---

## Usage Examples

### Minimal Addon with Profiles

```lua
local addonName, privateTable = ...

local defaults = {
    width = 500,
    height = 500,
    name = "John",
}

local addon = DetailsFramework:CreateNewAddOn(addonName, "MyAddonDB", defaults)

function addon.OnLoad(self, profile)
    -- profile = { width = 500, height = 500, name = "John" } on first run
    print("Width is:", profile.width)
end

function addon.OnInit(self, profile)
    -- game world is ready
end
```

### Reading and Writing the Profile

```lua
-- After OnLoad has fired:
local profile = addon.profile

-- Read a setting
local w = profile.width   -- 500

-- Write a setting (persists automatically on logout)
profile.width = 800
```

### Switching Profiles

```lua
-- Switch to a profile named "raiding" (creates it if needed)
DetailsFramework.SavedVars.SetProfile(addon, "raiding")

-- Switch and copy current settings into the new profile
DetailsFramework.SavedVars.SetProfile(addon, "mythicPlus", true)
```

### Reacting to Profile Changes

```lua
function addon.OnProfileChanged(self, newProfile)
    -- Update UI elements to reflect new settings
    myFrame:SetWidth(newProfile.width)
    myFrame:SetHeight(newProfile.height)
end
```

### Creating a Profile Panel

```lua
local panel = DetailsFramework.SavedVars.CreateProfilePanel(
    addon,
    "MyAddonProfilePanel",
    UIParent,
    { width = 400, height = 300 }
)

-- Show the panel (e.g. from a settings button)
panel:Show()
```

### Querying Profile Information

```lua
-- Get the current profile name
local name = DetailsFramework.SavedVars.GetCurrentProfileName(addon)

-- Get the raw saved variables table
local saved = DetailsFramework.SavedVars.GetSavedVariables(addon)

-- List all profiles
for profileName, profileData in pairs(saved.profiles) do
    print(profileName)
end
```
