addon.lua + savedvars.lua documentation
The addon object and profile system

=====================================================================
Overview
=====================================================================

- addon.lua implements the DetailsFramework addon object (df_addon).
- This object is the central hub of a World of Warcraft addon: it is
  where all parts of the addon connect. It handles events, saved
  variables, profiles, and provides a base for the addon to build upon.
- The public entry point is:
      DF:CreateNewAddOn(addonName, globalSavedVariablesName, savedVarsTemplate)
- User settings are stored in the .profile field. Code throughout the
  addon accesses settings like:
      local userProfile = addon.profile
      local textColor = userProfile.text_color

- savedvars.lua provides the profile management API under the namespace
  DF.SavedVars. It handles profile creation, switching, saving, and
  provides a ready-made profile management panel.


=====================================================================
1) What the addon object is for
=====================================================================

A df_addon is a plain Lua table that acts as the root object of an addon.
It does not use metatables — fields and methods are stored directly on it.

Responsibilities:
- Registers for the three core WoW lifecycle events (ADDON_LOADED,
  PLAYER_LOGIN, PLAYER_LOGOUT) and dispatches them to user-defined
  callbacks.
- Manages saved variables: reads them from the global table that WoW
  populates at load time, and writes them back on logout/reload.
- Manages profiles: each player character can use a different profile
  (named set of settings). New profiles inherit defaults and can copy
  from existing profiles.
- Provides a .profile field where all user-facing settings live.

Layer diagram:

    df_addon (your addon object)
     ├── .__name                      -- TOC addon name (string)
     ├── .__savedGlobalVarsName       -- global saved vars name (string)
     ├── .__savedVarsDefaultTemplate  -- default settings table
     ├── .__frame                     -- hidden frame for event handling
     ├── .profile                     -- current profile table (user settings)
     ├── .OnLoad                      -- callback: ADDON_LOADED
     ├── .OnInit                      -- callback: PLAYER_LOGIN
     ├── .OnProfileChanged            -- callback: profile switched
     └── .SetLogoutLogTable           -- method: set error log table


=====================================================================
2) DF:CreateNewAddOn — the constructor
=====================================================================

Signature
    DF:CreateNewAddOn(addonName, globalSavedVariablesName, savedVarsTemplate)

Returns
    df_addon — the addon object.

Parameter reference

    addonName (string, required)
        The name of the addon as declared in the .toc file. This is also
        the name of the addon's folder inside the game's AddOns directory.
        CRITICAL: This must match EXACTLY. It is case-sensitive and must
        be the folder name — not a display name or title.
        Example: "SliceAndDance" (not "Slice And Dance", not "sliceanddance")

    globalSavedVariablesName (string, required)
        The name of the global variable used for saved variables. This
        must match EXACTLY the name declared in the .toc file under
        "## SavedVariables:".
        CRITICAL: If these do not match, saved variables will not persist
        between game sessions. WoW populates a global variable with this
        exact name at load time. See the Common Pitfalls section below.

    savedVarsTemplate (table or nil)
        A table of default settings. When a new profile is created, it is
        populated with copies of these defaults via DF.table.deploy.
        If nil or omitted, an empty table {} is used.
        IMPORTANT: This table IS the profile content directly. Do NOT wrap
        it in an extra "profile" key. The framework stores the result of
        GetProfile() in addonObject.profile, so wrapping the template
        would produce addonObject.profile.profile.field (double key) instead
        of addonObject.profile.field.
        Correct:
            {
                width = 500,
                height = 500,
                name = "John",
            }
        Wrong (double key):
            {
                profile = {
                    width = 500,
                    ...
                }
            }

Construction sequence
    1. Creates a new empty table (newAddonObject).
    2. Creates a hidden frame (addonFrame) for event handling.
    3. Stores __name, __savedGlobalVarsName, __savedVarsDefaultTemplate
       on both the addon object and the frame.
    4. Cross-references: addonFrame.__addonObject = newAddonObject,
       newAddonObject.__frame = addonFrame.
    5. Registers ADDON_LOADED, PLAYER_LOGIN, PLAYER_LOGOUT events.
    6. Sets the frame's OnEvent script to the internal event dispatcher.
    7. Attaches the SetLogoutLogTable method.
    8. Returns the addon object.


=====================================================================
3) Lifecycle event handlers
=====================================================================

The addon object responds to three WoW events. These are handled by
internal functions that dispatch to user-defined callbacks.

addonLoaded (ADDON_LOADED)
.....................................................................

Fires when:
    WoW finishes loading an addon's files and saved variables. This
    event fires once per addon, so the handler checks that the
    addonName argument matches .__name before proceeding.

What it does:
    1. Validates addonName matches — ignores events for other addons.
    2. If __savedGlobalVarsName is nil (no saved vars wanted), calls
       OnLoad(self) immediately with no profile and returns.
    3. Otherwise:
       a. Gets the player's GUID.
       b. Retrieves (or creates) the global saved variables table via
          DF.SavedVars.GetSavedVariables.
       c. Looks up which profile ID this character uses from
          tSavedVariables.profile_ids[playerGUID].
       d. If no profile ID is stored, assigns "default".
       e. Loads the profile via DF.SavedVars.GetProfile (creates it if
          it doesn't exist yet).
       f. Stores the profile on addonObject.profile.
       g. Calls OnLoad(self, profile, true).

Callback signature:
    function addon.OnLoad(self, profile, hasSavedVars)
        -- self: the df_addon object
        -- profile: the loaded profile table (or nil if no saved vars)
        -- hasSavedVars: true when saved variables exist

Why it matters:
    This is the earliest point where saved variable data is available.
    UI creation that depends on user settings should happen here.


addonInit (PLAYER_LOGIN)
.....................................................................

Fires when:
    The loading screen is gone and the player character is in the world,
    ready to play.

What it does:
    Calls OnInit(self, profile) if defined on the addon object.

Callback signature:
    function addon.OnInit(self, profile)
        -- self: the df_addon object
        -- profile: the profile table

Why it matters:
    This is the earliest point where most game APIs are fully available
    (unit info, spell data, etc.). Logic that needs the game world ready
    should go here, not in OnLoad.


addonUnload (PLAYER_LOGOUT)
.....................................................................

Fires when:
    The player logs out or reloads the UI (/reload).

What it does:
    1. Calls DF.SavedVars.SaveProfile to persist the current profile.
    2. If the save fails, logs the error with a timestamp into the
       logout log table (if one was set via SetLogoutLogTable).
    3. The log keeps at most 2 entries (inserts at index 1, removes
       index 3).

Why it matters:
    This ensures user settings are written back to the saved variables
    global. Without this, changes made during the session would be lost.


Event dispatcher (addonOnEvent)
.....................................................................

    All three events are routed through a single OnEvent handler. If the
    event is not one of the three lifecycle events, the handler checks if
    addonFrame[event] exists and dispatches to it. This allows the addon
    to register for additional events (like COMBAT_LOG_EVENT_UNFILTERED)
    by storing handler functions on the frame keyed by event name.


=====================================================================
4) Additional methods on df_addon
=====================================================================

SetLogoutLogTable(logTable)
.....................................................................
Purpose
    Provide a table where logout save errors are recorded.

Parameters
    logTable (table) — a table that will receive timestamped error
    entries at index 1 when SaveProfile fails at logout.

Behavior
    Stores the table on addonObject.__frame.logoutLogs. The addonUnload
    handler writes to it on failure.

Example
    addon.logoutErrors = {}
    addon:SetLogoutLogTable(addon.logoutErrors)


=====================================================================
5) Saved variables structure
=====================================================================

The global saved variables table (the one WoW persists) has this
structure:

    _G["YourSavedVariablesName"] = {
        profiles = {
            ["default"]     = { ... user settings ... },
            ["raiding"]     = { ... user settings ... },
            ["PvP"]         = { ... user settings ... },
        },
        profile_ids = {
            ["Player-GUID-1"] = "default",
            ["Player-GUID-2"] = "raiding",
        },
    }

- profiles: a table keyed by profile name, where each value is a table
  of user settings.
- profile_ids: a table keyed by player GUID, where each value is the
  name of the profile that character uses.

This means:
- Each character can use a different profile.
- Multiple characters can share the same profile.
- Profiles persist across sessions because the whole table is saved by
  WoW.


=====================================================================
6) Profile system (DF.SavedVars namespace)
=====================================================================

All profile functions live under DF.SavedVars and take the addon object
as the first argument.


GetSavedVariables(addonObject)
.....................................................................
Purpose
    Retrieve (or create) the global saved variables table for this addon.

Parameters
    addonObject (df_addon) — the addon object.

Returns
    (table) — the saved variables table. Returns an empty table if
    __savedGlobalVarsName is not set.

Behavior
    1. Looks up _G[addonObject.__savedGlobalVarsName].
    2. If it doesn't exist (first run), creates a new table with:
       - profiles = {}     (empty profiles table)
       - profile_ids = {}  (empty GUID-to-profile mapping)
    3. Stores this new table in _G so WoW will save it.

Important
    This function is safe to call at any time. On first run, it
    initializes the structure. On subsequent runs, it returns the
    existing persisted data.


GetCurrentProfileName(addonObject)
.....................................................................
Purpose
    Get the name of the profile the current player character is using.

Parameters
    addonObject (df_addon) — the addon object.

Returns
    (string) — the profile name (e.g. "default", "raiding").

Behavior
    Reads profile_ids[UnitGUID("player")] from the saved variables.


GetProfile(addonObject, bCreateIfNotFound, profileToCopyFrom)
.....................................................................
Purpose
    Retrieve the profile table for the current character.

Parameters
    addonObject        (df_addon)
    bCreateIfNotFound  (boolean or nil)
        If true and no profile exists for this character, creates a new
        empty profile table.
    profileToCopyFrom  (table or nil)
        If provided and bCreateIfNotFound is true, copies the values
        from this table into the new profile.

Returns
    (table or nil) — the profile table, or nil if not found and
    bCreateIfNotFound is false.

Behavior
    1. Gets the player's profile ID from the saved variables.
    2. Looks up profiles[profileId].
    3. If not found and bCreateIfNotFound is true:
       a. Creates a new empty table.
       b. If profileToCopyFrom is provided, copies its values via
          DF.table.deploy (non-destructive merge).
    4. If the profile hasn't been "loaded" yet (no __loaded flag):
       a. Deploys the default template values (does not overwrite
          existing user values).
       b. Sets __loaded = true.
    5. Returns the profile table.

The __loaded flag
    The __loaded flag tracks whether default values have been merged
    into this profile for the current session. It is:
    - Set to true after deploying defaults in GetProfile.
    - Removed during SaveProfile (before persisting to disk).
    This ensures defaults are always available at runtime but never
    redundantly stored on disk — only user-modified values are saved.


SetProfile(addonObject, profileName, bCopyFromCurrentProfile)
.....................................................................
Purpose
    Switch the current character to a different profile.

Parameters
    addonObject             (df_addon)
    profileName             (string) — the name of the profile to switch to.
    bCopyFromCurrentProfile (boolean or nil) — if true, copies the current
                             profile data into the new profile.

Behavior
    1. Saves the current profile via SaveProfile.
    2. Updates profile_ids[playerGUID] to profileName.
    3. Loads the new profile via GetProfile (creates if not found).
    4. Stores the new profile on addonObject.profile.
    5. If addonObject.OnProfileChanged is defined, calls it with
       (addonObject, newProfileTable).

Example
    -- Switch to "raiding" profile:
    DF.SavedVars.SetProfile(addon, "raiding")

    -- Switch and copy current settings:
    DF.SavedVars.SetProfile(addon, "mythicPlus", true)


SaveProfile(addonObject)
.....................................................................
Purpose
    Persist the current in-memory profile to the saved variables table.

Parameters
    addonObject (df_addon)

Behavior
    1. Gets the current profile from addonObject.profile.
    2. If the profile is loaded (__loaded is true):
       a. Removes keys that are identical to the default template (via
          DF.table.removeduplicate). This means only user-modified
          values are stored on disk, reducing saved variable file size.
       b. Removes the __loaded flag.
       c. Writes the cleaned profile to savedVariables.profiles[profileId].

Why only modified values are saved
    When the profile is loaded, default values are deployed into it.
    When saving, those defaults are stripped out. On next load, they
    are deployed again. This means:
    - If you update your addon's defaults, all users automatically get
      the new defaults for any setting they haven't customized.
    - The saved variable file stays small.


=====================================================================
7) Profile management panel
=====================================================================

CreateProfilePanel(addonObject, frameName, parentFrame, options)
.....................................................................
Purpose
    Create a ready-made UI panel where users can view, select, and create
    profiles.

Parameters
    addonObject (df_addon)
    frameName   (string) — global frame name.
    parentFrame (frame)  — the parent frame.
    options     (table or nil) — optional overrides:
        width  (number) — panel width, default 600.
        height (number) — panel height, default 400.
        title  (string) — panel title, default "Profile Management".

Returns
    df_profilepanel — the profile management frame.

What it creates
    1. A frame with rounded corners (uses Details theming).
    2. "Current Profile:" label showing the active profile name.
    3. A dropdown (df_dropdown) listing all existing profiles. Selecting
       a profile calls SetProfile to switch to it.
    4. "Create New:" label with a text entry field and a "Create" button.
       Typing a name and clicking Create calls SetProfile with that name,
       which creates the profile if it doesn't exist.
    5. An OnShow script that refreshes the panel automatically.
    6. The panel starts hidden — call :Show() to display it.

Panel fields
    .AddonObject              (df_addon)       — reference to the addon
    .ProfileNameValueLabel    (fontstring)      — shows current profile name
    .ProfileSelectionDropdown (df_dropdown)     — profile picker dropdown
    .ProfileNameTextEntry     (df_textentry)    — new profile name input

Panel methods
    RefreshSelectProfileDropdown()
        Rebuilds the dropdown options from all existing profiles.

    OnClickCreateNewProfile()
        Reads the text entry, calls SetProfile with the entered name.


RefreshProfilePanel(profilePanel)
.....................................................................
Purpose
    Refresh all elements of the profile panel to reflect the current
    addon state.

Parameters
    profilePanel (df_profilepanel) — the panel created by
    CreateProfilePanel.

Behavior
    1. Updates the current profile name label.
    2. Refreshes the dropdown options.
    3. Clears the text entry field.


=====================================================================
8) Common pitfalls
=====================================================================

Wrong addonName
.....................................................................
Problem:
    Passing the wrong string as addonName to CreateNewAddOn.

What goes wrong:
    The ADDON_LOADED handler compares the incoming addonName (from WoW)
    against __name. If they don't match, the handler silently returns
    and OnLoad is NEVER called. No error is shown.

The rule:
    addonName MUST be the exact folder name of your addon inside the
    game's Interface/AddOns/ directory. This is also the same string
    that appears as the first field in the .toc filename (without the
    .toc extension).

    Folder:  Interface/AddOns/SliceAndDance/
    TOC:     SliceAndDance.toc
    Correct: DF:CreateNewAddOn("SliceAndDance", ...)
    Wrong:   DF:CreateNewAddOn("Slice And Dance", ...)
    Wrong:   DF:CreateNewAddOn("sliceanddance", ...)
    Wrong:   DF:CreateNewAddOn("SliceAndDance.toc", ...)

How to debug:
    If OnLoad is never firing, print the addonName argument in the
    ADDON_LOADED event and compare it against what you passed.


Wrong globalSavedVariablesName
.....................................................................
Problem:
    Passing a globalSavedVariablesName that doesn't match the
    "## SavedVariables:" line in the .toc file.

What goes wrong:
    WoW populates _G[variableName] at load time using the name from the
    .toc file. If you pass a different name to CreateNewAddOn, the addon
    will create a NEW global table under that name — but WoW won't save
    it. The result: settings appear to work during the session but are
    LOST on logout/reload. No error is shown.

The rule:
    The globalSavedVariablesName string must be an exact,
    case-sensitive match of the variable name in the .toc file.

    TOC line:   ## SavedVariables: SliceAndDanceDatabase
    Correct:    DF:CreateNewAddOn("SliceAndDance", "SliceAndDanceDatabase", ...)
    Wrong:      DF:CreateNewAddOn("SliceAndDance", "SliceAndDanceDB", ...)
    Wrong:      DF:CreateNewAddOn("SliceAndDance", "sliceanddancedatabase", ...)

How to debug:
    Check _G["YourVariableName"] after ADDON_LOADED. If it's nil at
    that point but non-nil after your code runs, WoW didn't populate
    it — the name doesn't match the .toc declaration.


Accessing profile before OnLoad
.....................................................................
Problem:
    Reading addon.profile before the ADDON_LOADED event fires.

What goes wrong:
    addon.profile is nil until addonLoaded assigns it after loading
    saved variables. Any code that runs at file parse time (top-level
    code in your .lua files) cannot access the profile.

The rule:
    Only read addon.profile inside OnLoad, OnInit, or in response to
    user actions (clicks, etc.) that happen after the addon is loaded.


Profile not persisting on reload
.....................................................................
Problem:
    Settings are lost after /reload but work fine during the session.

Possible causes:
    1. globalSavedVariablesName mismatch (see above).
    2. SaveProfile is erroring silently — use SetLogoutLogTable to
       capture errors:
           addon.logErrors = {}
           addon:SetLogoutLogTable(addon.logErrors)
       Then check addon.logErrors after reloading.
    3. The profile only saves values that differ from the default
       template. If you're reading a value that equals the default,
       it won't appear in the saved file — but it WILL be present at
       runtime after GetProfile deploys the defaults.


=====================================================================
9) Usage examples
=====================================================================

Minimal addon setup:
    local addonName, privateTable = ...
    local DF = DetailsFramework

    local addon = DF:CreateNewAddOn(
        addonName,
        "MyAddonSavedVars",
        { fontSize = 12, showTooltips = true }
    )

    function addon:OnLoad(profile)
        print("Loaded! Font size:", profile.fontSize)
    end

    function addon:OnInit(profile)
        print("Player is in the world")
    end

Accessing the profile from anywhere:
    -- After OnLoad has fired:
    local profile = addon.profile
    local fontSize = profile.fontSize       -- 12 (default or user-set)
    profile.fontSize = 16                   -- change persists on logout

Switching profiles:
    DF.SavedVars.SetProfile(addon, "raiding")
    -- addon.profile is now the "raiding" profile table
    -- OnProfileChanged fires if defined

Getting the current profile name:
    local name = DF.SavedVars.GetCurrentProfileName(addon)
    print("Using profile:", name) -- e.g. "default"

Creating a profile management panel:
    local panel = DF.SavedVars.CreateProfilePanel(
        addon,
        "MyAddonProfilePanel",
        settingsFrame
    )
    panel:SetPoint("CENTER")
    panel:Show()

Handling profile changes:
    function addon:OnProfileChanged(newProfile)
        -- Re-read all settings from the new profile
        self:ApplySettings(newProfile)
    end

Sharing the addon object between files:
    -- In your main file:
    local addonName, privateTable = ...
    local addon = DF:CreateNewAddOn(addonName, "MyDB", defaults)
    privateTable.addon = addon

    -- In another file:
    local _, privateTable = ...
    local addon = privateTable.addon
    -- Use addon.profile after OnLoad has fired

Enabling logout error logging:
    function addon:OnLoad(profile)
        self.logErrors = {}
        self:SetLogoutLogTable(self.logErrors)
    end


=====================================================================
10) Complete .toc and code reference
=====================================================================

Example .toc file (SliceAndDance.toc):
    ## Interface: 120100
    ## Title: Slice And Dance
    ## Notes: Show a slice and dice bar for rogues
    ## SavedVariables: SliceAndDanceDatabase
    SliceAndDance_Core.lua

Matching code (SliceAndDance_Core.lua):
    local addonName, privateTable = ...
    local DF = DetailsFramework

    local addon = DF:CreateNewAddOn(
        addonName,                      -- "SliceAndDance" (from the ... payload)
        "SliceAndDanceDatabase",        -- must match ## SavedVariables exactly
        {
            width = 500,
            height = 500,
            name = "John",
        }
    )

    _G.SliceAndDanceAddOn = addon       -- optional: make globally accessible
    privateTable.public = addon         -- share across addon files

    function addon:OnLoad()
        local profile = self.profile
        print("Loaded, width is", profile.width)
    end

    function addon:OnInit()
        print("Player ready to play")
    end

Note: the first return value of ... (the varargs at the top of every
addon Lua file) is the addon name as a string. It matches the folder
name and .toc filename exactly. Using this variable as the addonName
argument to CreateNewAddOn is the safest approach — it eliminates the
risk of typos.


=====================================================================
End of documentation
=====================================================================
