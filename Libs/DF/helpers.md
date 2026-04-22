# Details Framework Helper Documentation

## DF:GetDurability()
- Description: Returns the current equipped gear durability as an average percent, and the percent durability of the lowest equipped item.
- Parameters: none
- Returns:
  - `number gearDurability` — average durability percent for all equipped items (0-100)
  - `number lowestGearDurability` — lowest durability percent among equipped items

## DF:GetBattlegroundSize(instanceInfoMapId)
- Description: Returns the expected team size for a battleground identified by its instance map ID.
- Parameters:
  - `instanceInfoMapId` — instance ID used as the lookup key in `DF.BattlegroundSizes`
- Returns:
  - `number?` — battleground team size, or `nil` if the instance is not in the lookup table

## DF:GetSpecInfoFromSpecId(specId)
- Description: Returns the specialization metadata table for a given specialization ID.
- Parameters:
  - `specId` (`number`) — the specialization ID to query
- Returns:
  - `specinfo?` — metadata table for the spec, or `nil` if not found

## DF:GetSpecInfoFromSpecIcon(specIcon)
- Description: Returns the specialization metadata table for a given specialization icon ID.
- Parameters:
  - `specIcon` (`number`) — the icon ID used to identify a specialization
- Returns:
  - `specinfo?` — metadata table for the spec, or `nil` if no matching icon is found

## DF:GetSpecIdFromSpecIcon(specIcon)
- Description: Returns the spec ID that corresponds to a given spec icon.
- Parameters:
  - `specIcon` (`number`) — specialization icon ID
- Returns:
  - `number?` — spec ID when found, otherwise `nil`

## DF:IsValidSpecId(specId)
- Description: Checks whether a specialization ID is valid for the player's current class and excludes tutorial-only specs.
- Parameters:
  - `specId` (`number`) — the specialization ID to validate
- Returns:
  - `boolean` — `true` if the spec is valid for the player’s class, `false` otherwise

## DF:IsSpecFromClass(class, specId)
- Description: Checks whether a spec ID belongs to a specific class.
- Parameters:
  - `class` (`string`) — class name, such as `DRUID`, `MAGE`, etc.
  - `specId` (`number`) — specialization ID to test
- Returns:
  - `boolean` — `true` if the spec belongs to the class, `false` otherwise

## DF:GetClassSpecs(class)
- Description: Returns the spec lookup table for a class, where each valid spec ID is a key with value `true`.
- Parameters:
  - `class` (`string`) — class name to query
- Returns:
  - `table?` — class spec lookup table, or `nil` if the class is unknown

## DF:GetSpecListFromClass(class)
- Description: Returns the numeric list of specialization IDs for a class.
- Parameters:
  - `class` (`string`) — class name to query
- Returns:
  - `number[]?` — array of spec IDs, or `nil` if the class is unknown

## DF:GetSpellsForRangeCheck()
- Description: Returns the table of range-check spells keyed by specialization ID.
- Parameters: none
- Returns:
  - `table` — mapping of `specId -> spellId` used for range checking

## DF:GetPlayerRole()
- Description: Returns the player's assigned role from group role assignment, or derives the role from the current specialization when no role is assigned.
- Parameters: none
- Returns:
  - `string` — role name such as `TANK`, `HEALER`, `DAMAGER`, or `NONE`

## DF:GetRoleTCoordsAndTexture(roleID)
- Description: Returns the role icon texture coordinates and texture path for a given role identifier.
- Parameters:
  - `roleID` (`string`) — role name, such as `TANK`, `HEALER`, `DAMAGER`, or `NONE`
- Returns:
  - `number l` — left texture coordinate
  - `number r` — right texture coordinate
  - `number t` — top texture coordinate
  - `number b` — bottom texture coordinate
  - `string texture` — texture path for the role icon

## DF:AddRoleIconToText(text, role, size)
- Description: Prefixes text with a role icon texture escape sequence using the role's icon coordinates.
- Parameters:
  - `text` (`string`) — text to prefix with the role icon
  - `role` (`string`) — role name, such as `TANK`, `HEALER`, `DAMAGER`, or `NONE`
  - `size` (`number?`) — optional icon size in pixels; defaults to `14`
- Returns:
  - `string` — the original text prefixed with the role icon when valid, otherwise the unchanged text

## DF:GetRoleIconAndCoords(role)
- Description: Returns the texture path and texture coordinates for a given role.
- Parameters:
  - `role` (`string`) — role name, such as `TANK`, `HEALER`, `DAMAGER`, or `NONE`
- Returns:
  - `string texture` — role icon texture path
  - `number left` — left coordinate
  - `number right` — right coordinate
  - `number top` — top coordinate
  - `number bottom` — bottom coordinate

## DF:GetCharacterRaceList()
- Description: Builds and returns a cached list of playable races available to the client.
- Parameters: none
- Returns:
  - `table[]` — list of race tables with fields `Name`, `FileString`, and `ID`
- Notes: The returned list is cached in `DF.RaceCache` after the first call.
- Example:
```lua
local races = DF:GetCharacterRaceList()
for _, raceInfo in ipairs(races) do
  print(raceInfo.Name, raceInfo.FileString, raceInfo.ID)
end
```

## DF:GetArmorIconByArmorSlot(equipSlotId)
- Description: Returns the icon path for an equipment slot.
- Parameters:
  - `equipSlotId` (`number`) — inventory slot ID, such as `INVSLOT_HEAD`, `INVSLOT_CHEST`, etc.
- Returns:
  - `string` — icon texture path, or empty string if the slot ID is not mapped
- Example:
```lua
local iconPath = DF:GetArmorIconByArmorSlot(INVSLOT_HEAD)
print(iconPath)
```

## DF:GetClassIdByFileName(fileName)
- Description: Returns the class numeric ID for a Blizzard class file name.
- Parameters:
  - `fileName` (`string`) — class token like `WARRIOR`, `MAGE`, `DRUID`
- Returns:
  - `number?` — class ID, or `nil` if the class name is unknown
- Example:
```lua
local classId = DF:GetClassIdByFileName("DRUID")
print(classId) -- 11
```

## DF:GetClassList()
- Description: Returns a cached list of player classes with localized names, texture info, and icon coordinates.
- Parameters: none
- Returns:
  - `table[]` — each entry contains `ID`, `Name`, `Texture`, `TexCoord`, and `FileString`
- Notes: The result is cached in `DF.ClassCache` after the first successful lookup.
- Example:
```lua
local classes = DF:GetClassList()
for _, classInfo in ipairs(classes) do
  print(classInfo.ID, classInfo.Name, classInfo.FileString)
end
```

## DF:GetClassSpecIds(engClass)
- Description: Returns the list of specialization IDs available for a class.
- Parameters:
  - `engClass` (`string`) — class token like `MAGE`, `PALADIN`, `EVOKER`
- Returns:
  - `number[]?` — array of spec IDs, or `nil` if the class is unknown
- Example:
```lua
local specIds = DF:GetClassSpecIds("PALADIN")
print(table.concat(specIds, ", "))
```

## DF:GetCurrentClassName()
- Description: Returns the player's current class token.
- Parameters: none
- Returns:
  - `string?` — player class name, such as `DRUID`, `WARRIOR`, or `MAGE`
- Example:
```lua
print("Player class:", DF:GetCurrentClassName())
```

## DF:GetCurrentSpecName()
- Description: Returns the current specialization name of the player, if available.
- Parameters: none
- Returns:
  - `string?` — spec name, or `nil` if the player has no valid specialization
- Example:
```lua
print("Current spec:", DF:GetCurrentSpecName())
```

## DF:GetCurrentSpecId()
- Description: Returns the current specialization ID of the player, if available.
- Parameters: none
- Returns:
  - `number?` — spec ID, or `nil` if the player has no valid specialization
- Example:
```lua
print("Current spec ID:", DF:GetCurrentSpecId())
```

## DF:ReskinSlider(slider, heightOffset)
- Description: Applies DetailsFramework slider styling to a slider or scrollbar widget.
- Parameters:
  - `slider` (`table`) — slider object or scrollbar object; the function detects the widget shape and applies the appropriate styling branch.
  - `heightOffset` (`number?`) — optional vertical offset used for scrollbar placement in some slider layouts
- Returns:
  - `nil` — modifies the passed widget in place
- Branch behavior:
  - If `slider.slider` exists, the function skins a modern DetailsFramework slider.
  - Else if `slider.Background` is a frame and `slider.Track`, `slider.Back`, and `slider.Forward` exist, it skins a classic slider frame.
  - Else if `slider.scrollBar`, `slider.scrollDown`, `slider.scrollUp`, and `slider.ScrollChild` exist, it skins a classic scrollbox scrollbar.
  - Otherwise, it skins a generic `slider.ScrollBar` with up/down buttons.
- Example:
```lua
DF:ReskinSlider(mySlider)
```

## DF:CreateBorder(parent, alpha1, alpha2, alpha3)
- Description: Adds a three-layer border around `parent` using three textures per side, with each layer using different alpha values.
- Parameters:
  - `parent` (`frame`) — the frame to attach the border to
  - `alpha1` (`number?`) — alpha for the front border layer
  - `alpha2` (`number?`) — alpha for the second border layer
  - `alpha3` (`number?`) — alpha for the third border layer
- Returns:
  - `nil` — modifies the parent frame in place
- Side effects:
  - Adds `parent.Borders` table and methods `SetBorderAlpha`, `SetBorderColor`, `SetLayerVisibility`
- Example:
```lua
DF:CreateBorder(myFrame, 0.5, 0.3, 0.1)
myFrame:SetBorderColor(1, 0, 0)
```

## DF:CreateBorderWithSpread(parent, alpha1, alpha2, alpha3, size, spread)
- Description: Adds a three-layer border around `parent`, similar to `CreateBorder`, but intended to support offset spread.
- Parameters:
  - `parent` (`frame`) — frame to attach the border to
  - `alpha1` (`number?`) — alpha for the first layer
  - `alpha2` (`number?`) — alpha for the second layer
  - `alpha3` (`number?`) — alpha for the third layer
  - `size` (`number?`) — width/height of each border texture, defaults to `1`
  - `spread` (`number?`) — currently ignored because the implementation sets local `spread = 0`
- Returns:
  - `nil` — modifies the parent frame in place
- Side effects:
  - Adds the same methods as `CreateBorder`: `SetBorderAlpha`, `SetBorderColor`, `SetLayerVisibility`
- Example:
```lua
DF:CreateBorderWithSpread(myFrame, 0.5, 0.3, 0.1, 1, 2)
myFrame:SetLayerVisibility(true, false, true)
```

## DF:CreateFullBorder(name, parent)
- Description: Creates a full border frame attached to `parent` and returns it as a standalone frame.
- Parameters:
  - `name` (`string`) — frame name for the new border frame
  - `parent` (`frame`) — parent frame to cover
- Returns:
  - `frame` — border frame with `Left`, `Right`, `Top`, `Bottom`, and `Textures` fields and mixin methods
- Example:
```lua
local border = DF:CreateFullBorder("MyBorder", myFrame)
border:SetVertexColor(1, 0, 0, 1)
border:SetBorderSizes(2, 2, 4, 4)
border:UpdateSizes()
```

## DF:CreateAnts(parent, antTable, leftOffset, rightOffset, topOffset, bottomOffset)
- Description: Creates a moving "ants" animation frame around its parent using a texture atlas.
- Parameters:
  - `parent` (`frame`) — parent frame to attach the ants animation
  - `antTable` (`table`) — animation settings table; required fields include `Texture`, `TextureWidth`, `TextureHeight`, `TexturePartsWidth`, `TexturePartsHeight`, and `AmountParts`; optional fields include `BlendMode`, `Color`, and `Throttle`
  - `leftOffset` (`number?`) — left inset/outset offset, default `0`
  - `rightOffset` (`number?`) — right inset/outset offset, default `0`
  - `topOffset` (`number?`) — top inset/outset offset, default `0`
  - `bottomOffset` (`number?`) — bottom inset/outset offset, default `0`
- Returns:
  - `frame` — the new ants animation frame
- Example:
```lua
local ants = DF:CreateAnts(myFrame, {
  Texture = "Interface\\AddOns\\Details\\images\\ants",
  TextureWidth = 256,
  TextureHeight = 256,
  TexturePartsWidth = 16,
  TexturePartsHeight = 16,
  AmountParts = 8,
  Color = "white",
})
```

## DF:CreateGlowOverlay(parent, antsColor, glowColor)
- Description: Creates a custom spell glow overlay frame attached to `parent` and returns it.
- Parameters:
  - `parent` (`frame`) — frame to anchor the overlay to
  - `antsColor` (`any`) — color passed to the overlay's `SetColor` method for the ant animation
  - `glowColor` (`any`) — color passed to the overlay's `SetColor` method for the glow
- Returns:
  - `frame` — overlay frame with methods `Play`, `Stop`, and `SetColor`
- Notes: Uses a patch-safe template selection based on `buildInfo` and `DF.IsTBCWow()`.
- Example:
```lua
local glow = DF:CreateGlowOverlay(myButton, {1, 1, 1, 1}, {0.5, 0.8, 1, 1})
glow:Play()
```

## DF:CreateAnimationHub(parent, onPlay, onFinished)
- Description: Creates an animation hub wrapper around a frame's animation group.
- Parameters:
  - `parent` (`uiobject`) — the object that owns the animation group
  - `onPlay` (`function?`) — optional callback fired when the animation hub plays
  - `onFinished` (`function?`) — optional callback fired when the animation hub finishes or stops
- Returns:
  - `animationgroup` — animation group with `NextAnimation` counter initialized
- Example:
```lua
local hub = DF:CreateAnimationHub(myFrame,
  function() print("animation started") end,
  function() print("animation finished") end)
```

## DF:CreateAnimation(animationGroup, animationType, order, duration, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
- Description: Adds an animation to an animation hub and configures it according to the requested animation type.
- Parameters:
  - `animationGroup` (`animationgroup`) — hub created with `DF:CreateAnimationHub`
  - `animationType` (`animationtype`) — one of `"Alpha"`, `"Scale"`, `"Translation"`, `"Rotation"`, `"Path"`, or `"VertexColor"`
  - `order` (`number`) — drawing order within the animation group; lower values run earlier
  - `duration` (`number`) — animation duration in seconds
  - `arg1`..`arg8` (`any`) — meaning depends on `animationType`
- Returns:
  - `animation` — configured animation object
- Behavior by `animationType`:
  - `"Alpha"`: uses `arg1` as `fromAlpha`, `arg2` as `toAlpha`
  - `"Scale"`: uses `arg1`, `arg2` as `fromScaleX`, `fromScaleY`; `arg3`, `arg4` as `toScaleX`, `toScaleY`; `arg5`..`arg7` as origin point parameters
  - `"Rotation"`: uses `arg1` as degrees, `arg2`..`arg4` as origin point and offsets
  - `"Translation"`: uses `arg1`, `arg2` as X/Y offset
  - `"Path"`: creates a control point then sets curve type from `arg4`; `arg2`,`arg3` are offset values
  - `"VertexColor"`/`"Color"`: accepts start and end colors; each color may be passed as raw RGBA values, a color table, or a color name string
- Notes: For retail/Dragonflight and compatible APIs, scale animation uses `SetScaleFrom`/`SetScaleTo`; older APIs use `SetFromScale`/`SetToScale`.
- Examples:
```lua
local hub = DF:CreateAnimationHub(myFrame)
local alphaAnim = DF:CreateAnimation(hub, "Alpha", 1, 0.3, 0, 1)
local translateAnim = DF:CreateAnimation(hub, "Translation", 2, 0.4, 20, 0)
local rotateAnim = DF:CreateAnimation(hub, "Rotation", 3, 0.5, 180, "center", 0, 0)
local scaleAnim = DF:CreateAnimation(hub, "Scale", 4, 0.5, 0.5, 0.5, 1.2, 1.2, "center", 0, 0)
local colorAnim = DF:CreateAnimation(hub, "VertexColor", 5, 0.6, 1, 0, 0, 1, 0, 1, 0, 1)
```

## DF:CreateFadeAnimation(UIObject, fadeInTime, fadeOutTime, fadeInAlpha, fadeOutAlpha)
- Description: Creates hover-based fade-in and fade-out animations for a UI object.
- Parameters:
  - `UIObject` (`uiobject`) — object to fade in/out
  - `fadeInTime` (`number?`) — fade-in duration in seconds, default `0.1`
  - `fadeOutTime` (`number?`) — fade-out duration in seconds, default `0.1`
  - `fadeInAlpha` (`number?`) — alpha after fade-in, default `1`
  - `fadeOutAlpha` (`number?`) — alpha after fade-out, default `0`
- Returns:
  - `nil` — hooks `OnEnter` and `OnLeave` on the object (or its parent for FontString/Texture)
- Behavior: `OnEnter` stops the fade-out animation and plays fade-in; `OnLeave` stops fade-in and plays fade-out.
- Example:
```lua
DF:CreateFadeAnimation(myButton, 0.15, 0.15, 1, 0)
```

## DF:CreateFlashAnimation(frame, onFinishFunc, onLoopFunc)
- Description: Creates a reusable flash animation group on a frame and attaches helper methods.
- Parameters:
  - `frame` (`uiobject`) — frame that will receive the flash animation
  - `onFinishFunc` (`function?`) — optional callback fired when the flash animation finishes
  - `onLoopFunc` (`function?`) — optional callback fired each time the animation loops
- Returns:
  - `animationgroup` — flash animation group stored on `frame.FlashAnimation`
- Notes:
  - Attaches `frame.Flash` and `frame.Stop` methods to the frame.
  - The animation uses a fade from alpha 0 to 1, then back from 1 to 0.
- Example:
```lua
local flash = DF:CreateFlashAnimation(myFrame,
  function(frame) print("flash finished", frame:GetName()) end,
  function() print("flash looped") end)
myFrame:Flash(0.1, 0.1, 1, true, 0, 0, "REPEAT")
```

## DF:CreatePunchAnimation(frame, scale)
- Description: Creates a quick punch/bounce scale animation for a frame.
- Parameters:
  - `frame` (`uiobject`) — frame that receives the punch animation
  - `scale` (`number?`) — target scale factor for the punch effect, default `1.1`; capped at `1.9`
- Returns:
  - `animationgroup` — animation hub with a scale-up and scale-down sequence
- Notes:
  - The returned animation group does not start automatically.
  - It preserves the frame's original width and height while animating.
- Example:
```lua
local punch = DF:CreatePunchAnimation(myFrame, 1.2)
punch:Play()
```

## DF:CreateFrameShake(parent, duration, amplitude, frequency, absoluteSineX, absoluteSineY, scaleX, scaleY, fadeInTime, fadeOutTime, anchorPoints)
- Description: Creates a frame shake configuration and attaches frame shake methods to the parent.
- Parameters:
  - `parent` (`uiobject`) — frame to shake
  - `duration` (`number?`) — total shake duration in seconds, defaults to `0.3`
  - `amplitude` (`number?`) — base movement magnitude, defaults to `2`
  - `frequency` (`number?`) — speed of shake oscillation, defaults to `5`
  - `absoluteSineX` (`boolean?`) — when true, X motion uses absolute sine waves and never reverses direction
  - `absoluteSineY` (`boolean?`) — when true, Y motion uses absolute sine waves and never reverses direction
  - `scaleX` (`number?`) — X scale multiplier, defaults to `0.2`
  - `scaleY` (`number?`) — Y scale multiplier, defaults to `1`
  - `fadeInTime` (`number?`) — fade-in time in seconds, defaults to `0.01`
  - `fadeOutTime` (`number?`) — fade-out time in seconds, defaults to `0.01`
  - `anchorPoints` (`table?`) — optional anchor table to use for the shake; if omitted, the current parent points are captured dynamically when playback begins
- Returns:
  - `df_frameshake` — shake state object created for the parent
- Effects:
  - Adds or reuses `parent.__frameshakes` and registers `parent` with the global shake updater.
  - Injects methods onto `parent`: `PlayFrameShake`, `StopFrameShake`, `UpdateFrameShake`, and `SetFrameShakeSettings`.
- Example:
```lua
local shake = DF:CreateFrameShake(myFrame, 0.4, 3, 6, false, false, 0.3, 1, 0.05, 0.05)
myFrame:PlayFrameShake(shake)
```
- myFrame:PlayFrameShake(parent, shakeObject, scaleDirection, scaleAmplitude, scaleFrequency, scaleDuration)
- Description: Starts or restarts a specific shake object on the parent.
- Parameters:
  - `parent` (`uiobject`) — the frame with the shake methods injected
  - `shakeObject` (`df_frameshake`) — shake object returned by `DF:CreateFrameShake`
  - `scaleDirection` (`number?`) — multiplier for `ScaleX` and `ScaleY` relative to original values
  - `scaleAmplitude` (`number?`) — multiplier for amplitude relative to original value
  - `scaleFrequency` (`number?`) — multiplier for frequency relative to original value
  - `scaleDuration` (`number?`) — multiplier for duration relative to original value
- Notes: If the shake is already playing, it resets duration and adjusts fade state.
- Example:
```lua
myFrame:PlayFrameShake(shake, 1, 1.5, 1.2, 1)
```

myFrame:StopFrameShake(parent, shakeObject)
- Description: Immediately stops the specified shake and restores the parent’s original anchors.
- Parameters:
  - `parent` (`uiobject`)
  - `shakeObject` (`df_frameshake`)
- Example:
```lua
myFrame:StopFrameShake(shake)
```

myFrame:UpdateFrameShake(parent, shakeObject, deltaTime)
- Description: Updates a single shake object by applying the current oscillation and fade-state offsets.
- Parameters:
  - `parent` (`uiobject`)
  - `shakeObject` (`df_frameshake`)
  - `deltaTime` (`number?`) — elapsed time since the last update; defaults to `0`
- Notes: This is normally driven by the global frame shake updater and rarely called directly.
- Example:
```lua
myFrame:UpdateFrameShake(shake, 0.016)
```

myFrame:SetFrameShakeSettings(parent, shakeObject, duration, amplitude, frequency, absoluteSineX, absoluteSineY, scaleX, scaleY, fadeInTime, fadeOutTime)
- Description: Reconfigures an existing shake object’s timing and motion settings.
- Parameters:
  - `parent` (`uiobject`)
  - `shakeObject` (`df_frameshake`)
  - `duration` (`number?`)
  - `amplitude` (`number?`)
  - `frequency` (`number?`)
  - `absoluteSineX` (`boolean?`)
  - `absoluteSineY` (`boolean?`)
  - `scaleX` (`number?`)
  - `scaleY` (`number?`)
  - `fadeInTime` (`number?`)
  - `fadeOutTime` (`number?`)
- Example:
```lua
myFrame:SetFrameShakeSettings(shake, 0.5, 4, 8, false, false, 0.25, 1, 0.05, 0.05)
```

## DF:GetAvailableSpells()
- Description: Returns a lookup table of available non-passive spells for the player and their pet.
- Parameters: none
- Returns:
  - `table<number, boolean>` — spell IDs mapped to `true` for available spells
- Notes:
  - Includes current specialization spells, racial spells from the general spellbook tab, and pet spells.
  - Filters out passive spells and resolves override spell IDs.
- Example:
```lua
local spells = DF:GetAvailableSpells()
if spells[116] then
  print("Frostbolt is available")
end
```

## DF:GetNpcIdFromGuid(GUID)
- Description: Parses an NPC GUID string and returns its numeric NPC ID.
- Parameters:
  - `GUID` (`string`) — unit GUID, typically in the form `Creature-0-0000-00000-00000-12345-0000000000`
- Returns:
  - `number` — parsed NPC ID, or `0` if the ID cannot be extracted
- Example:
```lua
local npcId = DF:GetNpcIdFromGuid("Creature-0-0000-00000-00000-12345-0000000000")
print(npcId) -- 12345
```

## DF:GetCursorPosition()
- Description: Returns the current cursor position scaled by `UIParent`'s effective UI scale.
- Parameters: none
- Returns:
  - `number` — scaled X coordinate
  - `number` — scaled Y coordinate
- Example:
```lua
local x, y = DF:GetCursorPosition()
myFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
```

## DF:GetAsianNumberSymbols()
- Description: Returns the numeric unit symbols used for Asian localizations when formatting large numbers.
- Parameters: none
- Returns:
  - `string` — symbol for thousands
  - `string` — symbol for ten-thousands
  - `string` — symbol for hundreds of millions
- Behavior:
  - `koKR` => `천`, `만`, `억`
  - `zhCN` => `千`, `万`, `亿`
  - `zhTW` => `千`, `萬`, `億`
  - other locales => fallback to Korean symbols
- Example:
```lua
local oneK, tenK, oneB = DF:GetAsianNumberSymbols()
print(oneK, tenK, oneB)
```

## DF:FormatNumber(number)
- Description: Formats a large integer into a compact string with locale-appropriate units.
- Parameters:
  - `number` (`number`) — value to format
- Returns:
  - `string|number` — formatted number string for large values, or integer for smaller western values
- Behavior:
  - Asian localizations use `천`, `만`, `억` units and format values below 1,000 with one decimal place.
  - Western localizations use `K`, `M`, `B` units and return a floored integer for values under 1,000.
- Example:
```lua
print(DF:FormatNumber(1250000)) -- "1.25M" on western clients
```

## DF:CommaValue(value)
- Description: Formats an integer value with comma separators.
- Parameters:
  - `value` (`number`) — input number
- Returns:
  - `string` — comma-formatted number, or `"0"` for nil/zero values
- Notes:
  - Floors the input value before formatting.
- Example:
```lua
print(DF:CommaValue(1234567)) -- "1,234,567"
```

## DF:GroupIterator(callback, ...)
- Description: Iterates all group units and invokes a callback for each.
- Parameters:
  - `callback` (`function`) — function called per unit
  - `...` (`any`) — extra arguments forwarded to the callback
- Returns: none
- Behavior:
  - In raid: iterates `raid1` through `raidN`.
  - In party: iterates `party1` through `partyN-1`, then `player`.
  - Solo: invokes callback with `player` only.
- Example:
```lua
DF:GroupIterator(function(unit)
  print(unit)
end)
```

## DF:GetSizeFromPercent(uiObject, percent)
- Description: Calculates a size based on the smaller dimension of a UI object.
- Parameters:
  - `uiObject` (`uiobject`) — object with `GetSize()`
  - `percent` (`number`) — fraction of the smaller side to return
- Returns:
  - `number` — computed size
- Example:
```lua
local size = DF:GetSizeFromPercent(myFrame, 0.5)
```

## DF:IntegerToTimer(value)
- Description: Formats an integer number of seconds as `minutes:seconds`.
- Parameters:
  - `value` (`number`) — seconds to format
- Returns:
  - `string` — formatted time string
- Example:
```lua
print(DF:IntegerToTimer(1005)) -- "16:45"
```

## DF:IntegerToCooldownTime(value)
- Description: Formats seconds as a compact cooldown string.
- Parameters:
  - `value` (`number`) — cooldown duration in seconds
- Returns:
  - `string` — cooldown string using `h`, `m`, or `s`
- Behavior:
  - `>= 3600` => hours
  - `> 60` => minutes
  - otherwise => seconds
- Example:
```lua
print(DF:IntegerToCooldownTime(3610)) -- "1h"
```

## DF:RemoveRealmName(name)
- Description: Removes the realm suffix from a full player name.
- Parameters:
  - `name` (`string`) — name with an optional realm suffix
- Returns:
  - `string` — name without its realm suffix
  - `number` — number of replacements made
- Example:
```lua
print(DF:RemoveRealmName("Thrall-Deathwing")) -- "Thrall"
```

## DF:RemoveOwnerName(name)
- Description: Removes the owner segment from a pet or guardian name.
- Parameters:
  - `name` (`string`) — name containing ` <Owner>` syntax
- Returns:
  - `string` — name without the owner suffix
  - `number` — number of replacements made
- Example:
```lua
print(DF:RemoveOwnerName("Spirit Wolf <Thrall>")) -- "Spirit Wolf"
```

## DF:CleanUpName(name)
- Description: Cleans a name by removing realm suffixes, owner suffixes, `[*] ` prefixes, and texture escape sequences.
- Parameters:
  - `name` (`string`) — raw actor name string
- Returns:
  - `string` — cleaned name
- Example:
```lua
print(DF:CleanUpName("Thrall-Deathwing <Owner> |Ticon:0:0|t")) -- "Thrall"
```

## DF:RemoveRealName(name)
- Description: Removes the realm suffix from a name.
- Parameters:
  - `name` (`string`) — name with an optional realm suffix
- Returns:
  - `string` — name without the realm suffix
  - `number` — number of replacements made
- Example:
```lua
print(DF:RemoveRealName("Jaina-Proudmoore")) -- "Jaina"
```

## DF:TruncateNumber(number, fractionDigits)
- Description: Rounds a number to the specified number of fractional digits using a half-away-from-zero approach.
- Parameters:
  - `number` (`number`) — value to truncate
  - `fractionDigits` (`number`) — digits after the decimal; defaults to `2`
- Returns:
  - `number` — truncated value
- Notes:
  - Uses `floor()` for non-negative values and `ceil()` for negative values.
- Example:
```lua
print(DF:TruncateNumber(3.14159, 2)) -- 3.14
print(DF:TruncateNumber(-3.14159, 2)) -- -3.14
```

## DF:CleanTruncateUTF8String(text)
- Description: Removes a trailing incomplete UTF-8 sequence from a string after truncation.
- Parameters:
  - `text` (`string`) — truncated text that may end in a partial multibyte character
- Returns:
  - `string` — cleaned string with any partial UTF-8 tail removed
- Notes:
  - Checks the last 1 to 3 bytes and trims leftover UTF-8 sequence starts.
- Example:
```lua
local clean = DF:CleanTruncateUTF8String("Olá")
print(clean)
```

## DF:TruncateTextBinarySearch(fontString, maxWidth)
- Description: Truncates a FontString's text to fit within `maxWidth` using binary search.
- Parameters:
  - `fontString` (`fontstring`) — font object to truncate
  - `maxWidth` (`number`) — target maximum width in pixels
- Returns: none
- Notes:
  - Uses `GetUnboundedStringWidth()` to measure text width and sets the cleaned truncated string.
- Example:
```lua
myFontString:SetText("This is a long label")
DF:TruncateTextBinarySearch(myFontString, 100)
```

## DF:TruncateTextSafeBinarySearch(fontString, maxWidth)
- Description: Truncates a FontString using binary search with a maximum of 10 iterations.
- Parameters:
  - `fontString` (`fontstring`) — font object to truncate
  - `maxWidth` (`number`) — target maximum width in pixels
- Returns: none
- Notes:
  - Safer for very long text because it stops after 10 search iterations.
- Example:
```lua
myFontString:SetText("This is a very long label")
DF:TruncateTextSafeBinarySearch(myFontString, 120)
```

## DF:TruncateText(fontString, maxWidth)
- Description: Truncates a FontString by removing one character at a time until it fits.
- Parameters:
  - `fontString` (`fontstring`) — font object to truncate
  - `maxWidth` (`number`) — target maximum width in pixels
- Returns: none
- Notes:
  - Removes characters until the rendered string is equal to or below `maxWidth`.
- Example:
```lua
myFontString:SetText("Hello World")
DF:TruncateText(myFontString, 80)
```

## DF:TruncateTextSafe(fontString, maxWidth)
- Description: Truncates a FontString by removing at most 10 characters while trying to fit within `maxWidth`.
- Parameters:
  - `fontString` (`fontstring`) — font object to truncate
  - `maxWidth` (`number`) — target maximum width in pixels
- Returns: none
- Notes:
  - Stops after 10 removals to avoid long loops, so the result may still slightly exceed `maxWidth`.
- Example:
```lua
myFontString:SetText("Hello World Timer")
DF:TruncateTextSafe(myFontString, 100)
```

## DF:Trim(string)
- Description: Removes leading and trailing whitespace from a string.
- Parameters:
  - `string` (`string`) — text to trim
- Returns:
  - `string` — trimmed text
- Notes:
  - Delegates to `DF:trim`.
- Example:
```lua
print(DF:Trim("  Hello World  ")) -- "Hello World"
```

## DF:SetFontOutline(fontString, outline)
- Description: Sets or clears the outline flag on a FontString while preserving its font face and size.
- Parameters:
  - `fontString` (`fontstring`) — font object to modify
  - `outline` (`outline`) — outline style, such as `"NONE"`, `"OUTLINE"`, `"THICKOUTLINE"`, `"MONOCHROME"`, `true`, `false`, `1`, or `2`
- Returns: none
- Notes:
  - Boolean `true` maps to `OUTLINE`; `false` clears the outline.
  - Numeric `1` maps to `OUTLINE`; numeric `2` maps to `THICKOUTLINE`.
- Example:
```lua
DF:SetFontOutline(myFontString, "THICKOUTLINE")
``` 

## DF:SetFontSize(fontString, ...)
- Description: Sets the font size of a FontString to the maximum of the provided values.
- Parameters:
  - `fontString` (`fontstring`) — FontString object whose size will be updated
  - `...` (`number`) — one or more font sizes; the largest value is applied
- Returns: none
- Example:
```lua
DF:SetFontSize(myFontString, 12, 14, 16)
```

## DF:SetFontFace(fontString, fontface)
- Description: Changes a FontString's font face while preserving its current size and outline.
- Parameters:
  - `fontString` (`fontstring`) — FontString object to update
  - `fontface` (`string`) — font name, shared media font key, global font object name, or `"DEFAULT"`
- Returns: none
- Behavior:
  - If `fontface == "DEFAULT"`, it restores the default game font.
  - If a shared media font key is available, it resolves that to the actual font path.
  - If a global font object exists with that name, it uses its font.
- Example:
```lua
DF:SetFontFace(myFontString, "Friz Quadrata TT")
```

## DF:GetFontSize(fontString)
- Description: Returns the current font size of a FontString.
- Parameters:
  - `fontString` (`fontstring`) — FontString object to query
- Returns:
  - `number` — current font size
- Example:
```lua
local size = DF:GetFontSize(myFontString)
print(size)
```

## DF:GetFontFace(fontString)
- Description: Returns the font face/path used by a FontString.
- Parameters:
  - `fontString` (`fontstring`) — FontString object to query
- Returns:
  - `string` — font face or font file path
- Example:
```lua
local fontFace = DF:GetFontFace(myFontString)
print(fontFace)
```

## DF:SetFontDefault(fontString)
- Description: Resets a FontString to the default Blizzard game font.
- Parameters:
  - `fontString` (`fontstring`) — FontString object to update
- Returns: none
- Example:
```lua
DF:SetFontDefault(myFontString)
```

## DF:SetFontColor(fontString, r, g, b, a)
- Description: Sets the text color of a FontString using flexible color input.
- Parameters:
  - `fontString` (`fontstring`) — FontString object to update
  - `r` (`any`) — red component, HTML color string, color table, or other supported color input
  - `g` (`number?`) — green component
  - `b` (`number?`) — blue component
  - `a` (`number?`) — alpha component
- Returns: none
- Notes:
  - Uses `DF:ParseColors` to normalize the color input.
- Example:
```lua
DF:SetFontColor(myFontString, 1, 0.5, 0)
```

## DF:SetFontShadow(fontString, r, g, b, a, x, y)
- Description: Sets a FontString's shadow color and offset.
- Parameters:
  - `fontString` (`fontstring`) — FontString object to update
  - `r` (`any`) — red component, HTML color string, color table, or other supported color input
  - `g` (`number?`) — green component
  - `b` (`number?`) — blue component
  - `a` (`number?`) — alpha component
  - `x` (`number?`) — shadow X offset; preserves current offset if nil
  - `y` (`number?`) — shadow Y offset; preserves current offset if nil
- Returns: none
- Notes:
  - Uses `DF:ParseColors` to normalize the shadow color.
- Example:
```lua
DF:SetFontShadow(myFontString, 0, 0, 0, 0.75, 1, -1)
```

## DF:SetFontRotation(fontString, degrees)
- Description: Applies a deprecated rotation effect to a FontString using an internal animation.
- Parameters:
  - `fontString` (`fontstring`) — FontString object to rotate
  - `degrees` (`number`) — rotation in degrees
- Returns: none
- Notes:
  - This method is deprecated; on retail use `fontString:SetRotation(math.rad(degrees))` instead.
  - If `degrees` is not a number, no action is taken.
- Example:
```lua
DF:SetFontRotation(myFontString, 45)
```

## DF:GetTextWidth(text, size)
- Description: Returns the pixel width of a text string using a temporary hidden FontString.
- Parameters:
  - `text` (`string`) — text to measure
  - `size` (`number?`) — optional font size, defaults to `12`
- Returns:
  - `number` — width in pixels
- Example:
```lua
local width = DF:GetTextWidth("Hello World", 14)
print(width)
```

## DF:AddColorToText(text, color)
- Description: Wraps text in WoW color escape codes using a normalized color input.
- Parameters:
  - `text` (`string`) — text to colorize
  - `color` (`any`) — color value accepted by `DF:ParseColors`
- Returns:
  - `string` — text wrapped with `|c...|r`, or original text when the color cannot be parsed
- Example:
```lua
local colored = DF:AddColorToText("Warning", "orange")
```

## DF:RemoveColorCodes(text)
- Description: Removes Blizzard color escape sequences from a string.
- Parameters:
  - `text` (`string`) — text containing `|c...` and `|r` color codes
- Returns:
  - `string` — text with color codes removed
- Example:
```lua
print(DF:RemoveColorCodes("|cffff0000Error|r")) -- Error
```

## DF:RemoveTextureCodes(text)
- Description: Removes WoW texture escape sequences from a string.
- Parameters:
  - `text` (`string`) — text containing `|T...|t` texture codes
- Returns:
  - `string` — text with texture codes removed
- Example:
```lua
print(DF:RemoveTextureCodes("|Ticon:0:0|t Hello")) -- Hello
```

## DF:GetClassColorByClassId(classId)
- Description: Returns the RGB class color for a class ID.
- Parameters:
  - `classId` (`number`) — Blizzard class numeric ID
- Returns:
  - `number` — red component
  - `number` — green component
  - `number` — blue component
- Notes:
  - Falls back to white `1, 1, 1` when no class info is available.
- Example:
```lua
local r, g, b = DF:GetClassColorByClassId(8) -- Mage
```

## DF:AddClassColorToText(text, className)
- Description: Wraps text with the class color for the provided class name or index.
- Parameters:
  - `text` (`string`) — text to colorize
  - `className` (`class|string|number`) — class token or numeric class index
- Returns:
  - `string` — text wrapped with class color escape codes, or cleaned text if the class is invalid
- Notes:
  - Invalid or unsupported classes return the text with realm/owner names removed.
- Example:
```lua
print(DF:AddClassColorToText("Player", "MAGE"))
```

## DF:GetClassTCoordsAndTexture(class)
- Description: Returns the class icon texture coordinates and texture path.
- Parameters:
  - `class` (`string|number`) — class token or numeric class index
- Returns:
  - `number` — left coordinate
  - `number` — right coordinate
  - `number` — top coordinate
  - `number` — bottom coordinate
  - `string` — texture path
- Example:
```lua
local l, r, t, b, texture = DF:GetClassTCoordsAndTexture("MAGE")
```

## DF:MakeStringFromSpellId(spellId)
- Description: Creates a string containing a spell icon and spell name using WoW texture escape codes.
- Parameters:
  - `spellId` (`any`) — spell ID to query
- Returns:
  - `string` — formatted icon string, or empty string if the spell is invalid
- Example:
```lua
local label = DF:MakeStringFromSpellId(116)
```

## DF:AddClassIconToText(text, playerName, englishClassName, useSpec, iconSize)
- Description: Prefixes text with a class or specialization icon.
- Parameters:
  - `text` (`string`) — text to annotate
  - `playerName` (`string`) — player unit name or unit token used to resolve spec info when `useSpec` is true
  - `englishClassName` (`string`) — English class token used to locate class icon coordinates
  - `useSpec` (`boolean|number?`) — if truthy, attempts to use specialization icon data from Details or a spec ID
  - `iconSize` (`number?`) — icon pixel size, default `16`
- Returns:
  - `string` — text prefixed with an icon, or original text if icon data is unavailable
- Notes:
  - Uses Details addon cached spec/class icon tables when available.
- Example:
```lua
local iconText = DF:AddClassIconToText("Jaina", nil, "MAGE", false, 16)
```

## DF:AddClassIconToString(text, engClass, size)
- Description: Prefixes text with the standard Blizzard class icon for an English class token.
- Parameters:
  - `text` (`string`) — text to annotate
  - `engClass` (`string`) — English class token such as `"MAGE"`
  - `size` (`number?`) — icon pixel size, default `16`
- Returns:
  - `string|nil` — text prefixed with the icon, or `nil` if the class token is not found
- Example:
```lua
local iconText = DF:AddClassIconToString("Thrall", "SHAMAN", 16)
```

## DF:AddSpecIconToString(text, specId, size)
- Description: Prefixes text with a specialization icon.
- Parameters:
  - `text` (`string`) — text to annotate
  - `specId` (`number?`) — specialization ID; if omitted, uses the player's current specialization
  - `size` (`number?`) — icon pixel size, default `16`
- Returns:
  - `string|nil` — text prefixed with the spec icon, or `nil` if the spec cannot be resolved
- Example:
```lua
local specText = DF:AddSpecIconToString("Arcane", 62, 16)
```

## DF:CreateTextureInfo(texture, textureWidth, textureHeight, left, right, top, bottom, imageWidth, imageHeight)
- Description: Builds a texture info table for use with icon string generation.
- Parameters:
  - `texture` (`any`) — texture path, atlas, or texture ID
  - `textureWidth` (`any`) — display width of the texture, default `16`
  - `textureHeight` (`any`) — display height of the texture, default `16`
  - `left` (`any`) — left UV coordinate, default `0`
  - `right` (`any`) — right UV coordinate, default `1`
  - `top` (`any`) — top UV coordinate, default `0`
  - `bottom` (`any`) — bottom UV coordinate, default `1`
  - `imageWidth` (`any`) — source texture width, defaults to `textureWidth`
  - `imageHeight` (`any`) — source texture height, defaults to `textureHeight`
- Returns:
  - `table` — texture info with `.texture`, `.width`, `.height`, `.coords`, `.imageWidth`, and `.imageHeight`
- Example:
```lua
local info = DF:CreateTextureInfo("Interface\Icons\Spell_Frost_IceStorm", 16, 16)
```

## DF:AddTextureToText(text, textureInfo, bAddSpace, bAddAfterText)
- Description: Adds a texture escape code to a string, either before or after the text.
- Parameters:
  - `text` (`string`) — base text
  - `textureInfo` (`table`) — texture info created by `DF:CreateTextureInfo`
  - `bAddSpace` (`any`) — insert a space between the texture and text when truthy
  - `bAddAfterText` (`any`) — when truthy, appends the texture after the text; otherwise prepends it
- Returns:
  - `string` — formatted string containing the texture code and text
- Notes:
  - Uses the texture info width, height, image dimensions, and UV coords to build the `|T...|t` sequence.
- Example:
```lua
local info = DF:CreateTextureInfo("Interface\Icons\INV_Misc_QuestionMark", 16, 16)
local label = DF:AddTextureToText("Hello", info, true, false)
```


## DF:SetTemplate(frame, template)
- Description: Applies a DetailsFramework template to a frame, texture, or widget.
- Parameters:
  - `frame` (`uiobject`) — the object to style.
  - `template` (`string|table`) — a registered template name or an inline template table.
- Returns:
  - `nil` — modifies the target object in place.
- Behavior:
  - resolves string templates through `DF:ParseTemplate`.
  - if the target frame does not support `SetBackdrop`, it may mix in `BackdropTemplateMixin`.
  - applies `backdrop`, `backdropcolor`, `backdropbordercolor`, hover colors, icon settings, text font settings, and text alignment.
  - for textures that support `SetColorTexture`, it applies `backdropcolor` as the fill color.
- Example:
```lua
local button = CreateFrame("Button", "MyButton", UIParent)
DF:SetTemplate(button, "OPTIONS_BUTTON_TEMPLATE")
```

## DF:ParseTemplate(templateCategory, template)
- Description: Resolves a template name to a template table, or returns a template table unchanged.
- Parameters:
  - `templateCategory` (`templatecategory`) — widget category such as `font`, `dropdown`, `button`, `switch`, or `slider`.
  - `template` (`string|table`) — template name or inline template definition.
- Returns:
  - `table` — the resolved template table.
- Behavior:
  - template category aliases: `label` maps to `font`; `textentry` maps to `dropdown`.
  - if the template name is not found in the requested category, it searches all registered template tables.
  - if the passed value is already a table, it returns it unchanged.
- Example:
```lua
local template = DF:ParseTemplate("button", "STANDARD_GRAY")
```

## DF:InstallTemplate(templateCategory, templateName, template, parentName)
- Description: Registers a new reusable template, optionally inheriting from an existing template.
- Parameters:
  - `templateCategory` (`templatecategory`) — `font`, `dropdown`, `button`, `switch`, or `slider`.
  - `templateName` (`string`) — name used to reference the template.
  - `template` (`table`) — fields to define or override.
  - `parentName` (`string?`) — optional template name to inherit fields from.
- Returns:
  - `table` — the newly installed template table.
- Behavior:
  - when `parentName` is provided, it copies the parent template into the new template first.
  - then it copies the passed template fields, overriding parent values when necessary.
  - `font` templates automatically adjust the `font` field for the client language.
- Example:
```lua
DF:InstallTemplate("button", "MY_RED_BUTTON", {
  backdropcolor = {0.5, 0, 0, 1},
  textcolor = {1, 1, 1, 1},
}, "OPTIONS_BUTTON_TEMPLATE")

local btn = CreateFrame("Button", "MyRedButton", UIParent)
DF:SetTemplate(btn, "MY_RED_BUTTON")
```

## DF:GetTemplate(widgetType, templateName)
- Description: Returns a registered template table by category and name.
- Parameters:
  - `widgetType` (`string`) — template category: `font`, `dropdown`, `button`, `switch`, or `slider`.
  - `templateName` (`string`) — registered template name.
- Returns:
  - `table?` — the template table if found, otherwise `nil`.
- Example:
```lua
local tpl = DF:GetTemplate("button", "STANDARD_GRAY")
```

## DF Template System Overview
- Description: The template system stores reusable style definitions in category tables such as `DF.font_templates`, `DF.dropdown_templates`, `DF.button_templates`, `DF.switch_templates`, and `DF.slider_templates`.
- Template categories:
  - `font` for label/font templates.
  - `dropdown` for dropdown and text entry styles.
  - `button` for buttons.
  - `switch` for switches and checkboxes.
  - `slider` for sliders.
- Common template fields:
  - `backdrop` — frame backdrop definition.
  - `backdropcolor` — color for backdrop or texture fill.
  - `backdropbordercolor` — border color for the backdrop.
  - `onentercolor` / `onleavecolor` — hover color changes for the frame backdrop.
  - `onenterbordercolor` / `onleavebordercolor` — hover border color changes.
  - `width`, `height` — forced frame size.
  - `textsize` — font size for text frames.
  - `textfont` — font face for text frames.
  - `textcolor` — text color.
  - `textalign` — text horizontal alignment: `left`, `center`, or `right`.
  - `icon` — icon settings for widgets that support `SetIcon`.
- Category-specific fields:
  - dropdowns: `dropicon`, `dropiconsize`, `dropiconpoints`.
  - sliders: `thumbtexture`, `thumbwidth`, `thumbheight`, `thumbcolor`.
  - switches: `enabled_backdropcolor`, `disabled_backdropcolor`, `checked_texture`, `checked_color`.
- Inheritance:
  - Use `DF:InstallTemplate(..., parentName)` to create a template that starts from an existing template and overrides only the fields you want.
- Usage:
  - create or install a template once, then apply it with `DF:SetTemplate(frame, templateName)`.
  - pass a template table directly to `DF:SetTemplate(frame, templateTable)` for one-off styling.

## DF:GetClientRegion()
- Description: Returns the broad language region for the client locale, used for font and localization decisions.
- Parameters: none
- Returns:
  - `string` — one of `"western"`, `"russia"`, or `"asia"`
- Behavior:
  - `zhCN`, `koKR`, `zhTW` => `"asia"`
  - `ruRU` => `"russia"`
  - otherwise => `"western"`
- Example:
```lua
local region = DF:GetClientRegion()
print("Client region:", region)
```

## DF:GetBestFontPathForLanguage(languageId)
- Description: Returns a font file path for a given language locale, falling back to built-in defaults when no registered override exists.
- Parameters:
  - `languageId` (`string`) — locale token such as `enUS`, `frFR`, `zhCN`, `koKR`, `ruRU`, etc.
- Returns:
  - `string` — font file path
- Behavior:
  - returns `DF.registeredFontPaths[languageId]` when present
  - otherwise returns known font paths for common locales
  - unknown locales fall back to `Fonts\FRIZQT__.TTF`
- Example:
```lua
local fontPath = DF:GetBestFontPathForLanguage("zhCN")
print(fontPath) -- Fonts\ARKai_T.ttf
```

## DF:IsLatinLanguage(languageId)
- Description: Returns whether the specified locale is one of the supported Western Latin languages.
- Parameters:
  - `languageId` (`string`) — locale token
- Returns:
  - `boolean` — `true` for `enUS`, `deDE`, `esES`, `esMX`, `frFR`, `itIT`, `ptBR`
- Example:
```lua
print(DF:IsLatinLanguage("frFR")) -- true
print(DF:IsLatinLanguage("ruRU")) -- false
```

## DF:GetBestFontForLanguage(languageId, western, cyrillic, china, korean, taiwan)
- Description: Returns a font name tailored to a locale, defaulting `DF.ClientLanguage` when no locale is provided.
- Parameters:
  - `languageId` (`string?`) — locale token, optional
  - `western` (`string?`) — fallback font name for Western Latin locales
  - `cyrillic` (`string?`) — fallback font name for Russian
  - `china` (`string?`) — fallback font name for Simplified Chinese
  - `korean` (`string?`) — fallback font name for Korean
  - `taiwan` (`string?`) — fallback font name for Traditional Chinese
- Returns:
  - `string?` — font name or `nil` when locale is unsupported
- Behavior:
  - uses `DF.ClientLanguage` when `languageId` is omitted
  - returns built-in defaults when specific fallback names are not provided
- Example:
```lua
local font = DF:GetBestFontForLanguage(nil, "Friz Quadrata TT", "Friz Quadrata TT", "AR CrystalzcuheiGBK Demibold", "2002", "AR CrystalzcuheiGBK Demibold")
print(font)
```

## DF:IsHtmlColor(colorName)
- Description: Checks whether a named color alias exists in `DF.alias_text_colors`.
- Parameters:
  - `colorName` (`any`) — color alias key
- Returns:
  - `unknown` — truthy color table if the alias exists, otherwise `nil`
- Example:
```lua
if DF:IsHtmlColor("white") then
  print("White is a registered alias")
end
```

## DF:CreateColorTable(r, g, b, a)
- Description: Creates a color table object with `r`, `g`, `b`, `a` members and mixin methods `GetColor()` and `SetColor()`.
- Parameters:
  - `r` (`number?`) — red component, defaults to `1`
  - `g` (`number?`) — green component, defaults to `1`
  - `b` (`number?`) — blue component, defaults to `1`
  - `a` (`number?`) — alpha component, defaults to `1`
- Returns:
  - `table` — color table object
- Example:
```lua
local color = DF:CreateColorTable(0.2, 0.4, 0.6, 1)
print(color:GetColor()) -- 0.2, 0.4, 0.6, 1
```

## DF:FormatColor(newFormat, r, g, b, a, decimalsAmount)
- Description: Converts a color into the requested format after normalizing its components.
- Parameters:
  - `newFormat` (`string`) — one of `"commastring"`, `"tablestring"`, `"table"`, `"tablemembers"`, `"numbers"`, or `"hex"`
  - `r` (`number|string|table`) — red component, color string, or color table
  - `g` (`number?`) — green component
  - `b` (`number?`) — blue component
  - `a` (`number?`) — alpha component
  - `decimalsAmount` (`number?`) — number of decimals for numeric output; defaults to `4`
- Returns:
  - `string|table|number|nil` — converted color value, or `nil` when `newFormat` is unsupported
  - `number?` — second return value only when `newFormat` is `"numbers"`
  - `number?` — third return value only when `newFormat` is `"numbers"`
  - `number?` — fourth return value only when `newFormat` is `"numbers"`
- Notes:
  - `"hex"` returns alpha-first ARGB as a hex string.
  - other formats return a comma string, table, table-members table, or separate numeric components.
- Example:
```lua
print(DF:FormatColor("commastring", 1, 0, 0, 1)) -- "1, 0, 0, 1"
print(DF:FormatColor("table", 1, 0, 0, 1)[1]) -- 1
print(DF:FormatColor("hex", 1, 0, 0, 1)) -- "FFFF0000"
```

## DF:ParseColors(red, green, blue, alpha)
- Description: Normalizes a color input into four numeric components `r`, `g`, `b`, `a`.
- Parameters:
  - `red` (`any`) — can be a color table, color string, comma-separated string, or numeric red component
  - `green` (`any?`) — green component when numeric inputs are used
  - `blue` (`any?`) — blue component when numeric inputs are used
  - `alpha` (`any?`) — alpha component when numeric inputs are used
- Returns:
  - `number` — red component (0-1)
  - `number` — green component (0-1)
  - `number` — blue component (0-1)
  - `number` — alpha component (0-1)
- Supported input forms:
  - color table objects created by `DF:CreateColorTable()`, which expose `GetColor()`
  - color tables with `{r=..., g=..., b=..., a=...}` members
  - indexed color tables like `{1, 0, 0, 1}`
  - hex strings `"#RRGGBB"` or `"#AARRGGBB"`
  - named color aliases defined in `DF.alias_text_colors`
  - comma-separated strings like `"1,0,0,1"`
  - numeric component values passed separately
- Behavior:
  - missing or invalid numeric values default to `1`
  - output values are clamped with `Saturate()` to the range `0` to `1`
- Examples:
```lua
print(DF:ParseColors({1, 0, 0, 1}))            -- 1, 0, 0, 1
print(DF:ParseColors({r=0, g=1, b=0}))         -- 0, 1, 0, 1
print(DF:ParseColors("#FF0000FF"))            -- 1, 0, 0, 1
print(DF:ParseColors("#00FF00"))              -- 0, 1, 0, 1
print(DF:ParseColors("white"))                -- values from DF.alias_text_colors.white
print(DF:ParseColors("0,0,1,0.5"))           -- 0, 0, 1, 0.5
print(DF:ParseColors(0.1, 0.2, 0.3, 0.4))       -- 0.1, 0.2, 0.3, 0.4
```

## DF:GetColorBrightness(r, g, b)
- Description: Returns the perceived brightness of a color, using a standard luminance weight formula.
- Parameters:
  - `r` (`number`) — red component
  - `g` (`number`) — green component
  - `b` (`number`) — blue component
- Returns:
  - `number` — brightness value from `0` to `1`
- Behavior:
  - normalizes inputs with `DF:ParseColors()` first
  - returns `0.2134*r + 0.7152*g + 0.0721*b`
- Example:
```lua
local brightness = DF:GetColorBrightness(1, 0, 0)
print(brightness) -- 0.2134
```

## DF:GetColorHue(r, g, b)
- Description: Returns the hue of a color in the standard 0–6 hue circle used by HSL/HSV models.
- Parameters:
  - `r` (`number`) — red component
  - `g` (`number`) — green component
  - `b` (`number`) — blue component
- Returns:
  - `number` — hue value, or `0` when the color is grayscale
- Behavior:
  - normalizes inputs with `DF:ParseColors()` first
  - computes hue based on the max/min channels and returns a value between `0` and `6`
- Example:
```lua
print(DF:GetColorHue(1, 0, 0)) -- 0
print(DF:GetColorHue(0, 1, 0)) -- 2
print(DF:GetColorHue(0, 0, 1)) -- 4
```

## DF:NewColor(colorName, red, green, blue, alpha)
- Description: Registers a named color alias in `DF.alias_text_colors` and returns the normalized color table.
- Parameters:
  - `colorName` (`string`) — alias key to register
  - `red` (`number|string|table`) — red component or color value
  - `green` (`number?`) — green component
  - `blue` (`number?`) — blue component
  - `alpha` (`number?`) — alpha component
- Returns:
  - `table` — normalized color table stored in `DF.alias_text_colors[colorName]`
- Behavior:
  - asserts that `colorName` is a string
  - normalizes the color with `DF:ParseColors()`
  - converts the normalized color to a table with `DF:FormatColor("table", ...)`
  - stores the result in `DF.alias_text_colors[colorName]`
- Example:
```lua
local namedColor = DF:NewColor("MY_BLUE", 0, 0.5, 1, 1)
print(namedColor[1], namedColor[2], namedColor[3], namedColor[4]) -- 0, 0.5, 1, 1
```

## DF:CheckPoints(point1, point2, point3, point4, point5, object)
- Description: Normalizes a flexible set of anchor arguments into a standard `SetPoint`-style return tuple.
- Parameters:
  - `point1` (`string|number|table|nil`) — anchor point, x coordinate, frame, or global frame name
  - `point2` (`string|number|table|nil`) — second anchor value; may be a target frame, x coordinate, or string name
  - `point3` (`string|number|nil`) — relative anchor point or x offset
  - `point4` (`number?`) — x offset
  - `point5` (`number?`) — y offset
  - `object` (`table`) — wrapper containing `widget`, used when defaulting the anchor target
- Returns:
  - `string` — normalized `point1` anchor, defaulting to `"topleft"`
  - `uiobject` — resolved anchor target, defaulting to `object.widget:GetParent()`
  - `string` — normalized `point3` anchor, defaulting to `"topleft"`
  - `number` — x offset, defaulting to `0`
  - `number` — y offset, defaulting to `0`
- Behavior:
  - no point1/point2: returns `"topleft"`, parent, `"topleft"`, `0`, `0`
  - resolves named global frames from `_G` when `point1` or `point2` is a string
  - supports shorthand forms like:
    - `("left", frame, x, y)`
    - `("topleft", x, y)`
    - `(x, y)`
    - `(frame, x, y)`
  - unwraps DetailsFramework wrapper objects when `point2.dframework` is present
- Example:
```lua
local point1, anchorTo, point3, x, y = DF:CheckPoints("left", myFrame, 10, 10, nil, wrapper)
print(point1, anchorTo, point3, x, y)
```

## DF:ConvertAnchorOffsets(widget, referenceWidget, anchorTable, newAnchorSide)
- Description: Recomputes an anchor table's side and offset values when changing the attachment side.
- Parameters:
  - `widget` (`uiobject`) — the frame whose anchor is being converted
  - `referenceWidget` (`uiobject`) — the reference frame used to calculate relative offsets
  - `anchorTable` (`df_anchor`) — current anchor descriptor with `side`, `x`, `y`
  - `newAnchorSide` (`number`) — desired anchor side
- Returns:
  - `df_anchor` — updated anchor table with adjusted `side`, `x`, and `y`
- Behavior:
  - returns immediately when `anchorTable.side == newAnchorSide`
  - uses `DF.Math.GetNinePoints(widget)` and `DF.Math.GetNinePoints(referenceWidget)` to compute offsets
  - supports inside anchor sides and center positions:
    - `14` = inside top left
    - `15` = inside bottom left
    - `16` = inside bottom right
    - `17` = inside top right
    - `10` = inside left
    - `11` = inside right
    - `12` = inside top
    - `13` = inside bottom
    - `9` = center
- Example:
```lua
local anchorTable = {side = 10, x = 5, y = 0}
DF:ConvertAnchorOffsets(myWidget, parentFrame, anchorTable, 12)
print(anchorTable.side, anchorTable.x, anchorTable.y)
```

## DF:SetAnchor(widget, anchorTable, anchorTo)
- Description: Applies a `df_anchor` anchor descriptor to a widget using a selected built-in anchor function.
- Parameters:
  - `widget` (`uiobject`) — the frame to anchor
  - `anchorTable` (`df_anchor`) — anchor descriptor with `side`, `x`, `y`
  - `anchorTo` (`uiobject?`) — optional target frame to attach to
- Returns:
  - `nil`
- Behavior:
  - selects one of 17 anchor functions based on `anchorTable.side`
  - uses `anchorTable.x` and `anchorTable.y` as offset values
  - supports both outer and inside anchor positions
- Anchor side mapping:
  - `1` = Top Left
  - `2` = Left
  - `3` = Bottom Left
  - `4` = Bottom
  - `5` = Bottom Right
  - `6` = Right
  - `7` = Top Right
  - `8` = Top
  - `9` = Center
  - `10` = Inside Left
  - `11` = Inside Right
  - `12` = Inside Top
  - `13` = Inside Bottom
  - `14` = Inside Top Left
  - `15` = Inside Bottom Left
  - `16` = Inside Bottom Right
  - `17` = Inside Top Right
- Example:
```lua
local anchorTable = {side = 1, x = 0, y = 0}
DF:SetAnchor(myWidget, anchorTable, parentFrame)
```

## DF.strings.tabletostring(t, bDoCompression)
- Description: Converts an array of values into a comma-separated string.
- Parameters:
  - `t` (`table`) — array of values to join
  - `bDoCompression` (`boolean?`) — when truthy, compresses the result using `LibDeflate` if the library is available
- Returns:
  - `string` — comma-separated string of values, optionally compressed
- Notes:
  - Values are concatenated in order using `,` as the delimiter.
  - Compression is only applied when `LibDeflate` is loaded and `bDoCompression` is truthy.
- Example:
```lua
local text = DF.strings.tabletostring({"apple", "banana", "cherry"})
print(text) -- apple,banana,cherry
```

## DF.strings.stringtotable(thisString, bDoCompression)
- Description: Splits a comma-delimited string into a table of values.
- Parameters:
  - `thisString` (`string`) — comma-separated input text
  - `bDoCompression` (`boolean?`) — when truthy, decompresses the string with `LibDeflate` before splitting
- Returns:
  - `table` — array of values from the input string
- Notes:
  - If compression is requested, the function only decompresses when `LibDeflate` is available.
- Example:
```lua
local values = DF.strings.stringtotable("apple,banana,cherry")
print(values[1], values[2], values[3]) -- apple banana cherry
```

## DF.string.FormatDateByLocale(timestamp, ignoreYear)
- Description: Formats a timestamp into a localized date string.
- Parameters:
  - `timestamp` (`number`) — seconds since the epoch
  - `ignoreYear` (`boolean?`) — when truthy, omits the year from the result
- Returns:
  - `string` — formatted date string
- Behavior:
  - `enUS` returns `Mon D, YYYY` or `Mon D` when year is ignored.
  - all other locales return `D Mon YYYY` or `D Mon` when year is ignored.
- Example:
```lua
print(DF.string.FormatDateByLocale(time(), true)) -- "19 Apr" or "Apr 19"
```

## DF.string.GetSortValueFromString(value)
- Description: Computes a numeric sort weight from a string using its first two characters.
- Parameters:
  - `value` (`string`) — text to convert into a sort value
- Returns:
  - `number` — numeric sort weight
- Notes:
  - Uppercases the input and uses the byte values of the first two characters.
  - This is intended as a lightweight ordering heuristic rather than a locale-safe sort key.
- Example:
```lua
print(DF.string.GetSortValueFromString("Apple"))
```

## DF.string.Acronym(phrase)
- Description: Builds an acronym from the uppercase initial letters of words in a phrase.
- Parameters:
  - `phrase` (`string`) — input text
- Returns:
  - `string` — acronym containing uppercase initials
- Notes:
  - Hyphens are removed before acronym extraction.
  - Only uppercase letters are included from each word.
- Example:
```lua
print(DF.string.Acronym("World of Warcraft")) -- "WW"
```

## DF:SplitTextInLines(text)
- Description: Splits a string into lines separated by `\n`.
- Parameters:
  - `text` (`string`) — multi-line text
- Returns:
  - `table` — array of lines without the line break characters
- Notes:
  - Consecutive newline separators produce empty lines only when characters exist before the newline.
- Example:
```lua
local lines = DF:SplitTextInLines("line1\nline2\nline3")
print(lines[2]) -- line2
```

## DF.table.dump(t, resultString, deep)
- Description: Converts a table into a readable string representation.
- Parameters:
  - `t` (`table`) — table to dump
  - `resultString` (`string?`) — ignored by the implementation; always rebuilt internally
  - `deep` (`number?`) — ignored by the implementation; used internally for recursion depth
- Returns:
  - `string` — formatted representation of the table contents
- Notes:
  - Detects circular references and marks them with `--CIRCULAR REFERENCE`.
  - UI objects are displayed using their object type.
- Example:
```lua
print(DF.table.dump({a = 1, b = {c = 2}}))
```

## DF.table.deploy(t1, t2)
- Description: Recursively copies values from `t2` into `t1` only when `t1` does not already contain the key.
- Parameters:
  - `t1` (`table`) — target table to receive missing values
  - `t2` (`table`) — source table to copy from
- Returns:
  - `table` — updated `t1`
- Behavior:
  - If a nested value is a table, it recurses only when `t1[key]` is `nil` or already a table.
  - Existing non-table keys in `t1` are preserved.
- Example:
```lua
local base = {a = 1}
local defaults = {a = 2, b = 3}
DF.table.deploy(base, defaults)
print(base.b) -- 3
```

## DF.table.inserts(t1, ...)
- Description: Appends each extra argument to the end of a table.
- Parameters:
  - `t1` (`table`) — target array-style table
  - `...` (`any`) — values to append
- Returns:
  - `table` — updated `t1`
- Example:
```lua
local t = {1}
DF.table.inserts(t, 2, 3)
print(table.concat(t, ", ")) -- 1, 2, 3
```

## DF.table.append(t1, t2)
- Description: Appends all array values from `t2` onto the end of `t1`.
- Parameters:
  - `t1` (`table`) — destination array-style table
  - `t2` (`table`) — source array-style table
- Returns:
  - `table` — updated `t1`
- Notes:
  - Only numeric array elements from `t2` are appended.
- Example:
```lua
local a = {1, 2}
DF.table.append(a, {3, 4})
print(table.concat(a, ", ")) -- 1, 2, 3, 4
```

## DF.table.removeduplicate(table1, table2)
- Description: Removes entries from `table1` that are equal to entries in `table2`.
- Parameters:
  - `table1` (`table`) — table whose matching values will be removed
  - `table2` (`table`) — reference table used for removal
- Returns: none
- Behavior:
  - Recurses into nested tables when both values are tables.
  - Numeric values are compared with `DF:IsNearlyEqual()` when both sides are numbers.
- Example:
```lua
local a = {x = 1, y = 2}
DF.table.removeduplicate(a, {x = 1})
print(a.x) -- nil
```

## DF.table.copytocompress(t1, t2)
- Description: Copies non-function values from `t2` into `t1`, skipping values that cannot be compressed.
- Parameters:
  - `t1` (`table`) — destination table
  - `t2` (`table`) — source table
- Returns:
  - `table` — updated `t1`
- Behavior:
  - Skips function values and keys named `__index`.
  - Recurse into ordinary tables, but does not recurse into UI object tables that expose `GetObjectType`.
- Example:
```lua
local a = {x = 1}
DF.table.copytocompress(a, {y = 2, z = function() end})
print(a.y) -- 2
```

## DF.table.copy(t1, t2)
- Description: Recursively copies values from `t2` into `t1`, overwriting existing values.
- Parameters:
  - `t1` (`table`) — destination table
  - `t2` (`table`) — source table
- Returns:
  - `table` — updated `t1`
- Behavior:
  - Recurses into nested tables for all table values.
  - Skips `__index` and `__newindex` keys.
- Example:
```lua
local a = {x = 1}
DF.table.copy(a, {x = 5, y = 6})
print(a.x, a.y) -- 5 6
```

## DF.table.duplicate(t1, t2)
- Description: Recursively copies values from `t2` into `t1`, preserving UI object references.
- Parameters:
  - `t1` (`table`) — destination table
  - `t2` (`table`) — source table
- Returns:
  - `table` — updated `t1`
- Behavior:
  - If a value is a UI object table, it assigns that object directly instead of recursing.
  - Otherwise behaves like a deep copy.
- Example:
```lua
local a = {x = {1}}
DF.table.duplicate(a, {x = {2}})
print(a.x[1]) -- 2
```

## DF.table.remove(t, value)
- Description: Removes all occurrences of `value` from an array-style table.
- Parameters:
  - `t` (`table`) — array-style table to modify
  - `value` (`any`) — value to remove
- Returns:
  - `boolean` — `true` if at least one value was removed
  - `number` — number of removed elements
- Example:
```lua
local t = {1, 2, 1}
local removed, count = DF.table.remove(t, 1)
print(removed, count) -- true 2
```

## DF.table.reverse(t)
- Description: Creates a new array with the elements from `t` in reverse order.
- Parameters:
  - `t` (`table`) — source array-style table
- Returns:
  - `table` — new reversed table
- Example:
```lua
local rev = DF.table.reverse({1, 2, 3})
print(table.concat(rev, ", ")) -- 3, 2, 1
```

## DF.table.addunique(t, index, value)
- Description: Adds a value to a table only when it is not already present.
- Parameters:
  - `t` (`table`) — target array-style table
  - `index` (`integer|any`) — insertion position, or the value when `value` is omitted
  - `value` (`any?`) — value to insert; if omitted, `index` is used as the value and appended
- Returns:
  - `boolean` — `true` when the value was inserted, `false` when it already existed
- Example:
```lua
local t = {1, 2}
DF.table.addunique(t, 3)
print(table.concat(t, ", ")) -- 1, 2, 3
DF.table.addunique(t, 3)
```

## DF.table.countkeys(t)
- Description: Counts all keys in a table.
- Parameters:
  - `t` (`table`) — table to count
- Returns:
  - `number` — number of keys in the table
- Example:
```lua
print(DF.table.countkeys({a = 1, b = 2})) -- 2
```

## DF.table.setfrompath(t, path, value)
- Description: Sets a nested table entry using a dot/bracket path.
- Parameters:
  - `t` (`table`) — table to modify
  - `path` (`string`) — path such as `"a.b.c"` or `"a[1].b"`
  - `value` (`any`) — value to assign at the final path
- Returns:
  - `boolean?` — `true` when the assignment succeeds, otherwise `false`
- Behavior:
  - Splits the path on `.` and `[]` tokens.
  - Numeric keys are converted to numbers when possible.
  - Does not create missing intermediate tables; it only writes to the final existing parent table.
- Example:
```lua
local tbl = {a = {b = {c = 1}}}
DF.table.setfrompath(tbl, "a.b.c", 42)
print(tbl.a.b.c) -- 42
```

## DF.table.getfrompath(t, path, subOffset)
- Description: Returns a nested table value using a dot/bracket path.
- Parameters:
  - `t` (`table`) — table to read from
  - `path` (`string`) — path such as `"a.b.c"` or `"a[1].b"`
  - `subOffset` (`number?`) — optional depth at which to return the value early
- Returns:
  - `any` — value at the requested path, or `nil` if any key is missing
- Behavior:
  - Splits the path on alphanumeric/underscore segments.
  - If `subOffset` is provided, returns the intermediate value at that depth.
- Example:
```lua
local tbl = {a = {b = {c = 1}}}
print(DF.table.getfrompath(tbl, "a.b.c")) -- 1
```

## DF:GetParentNamePath(object)
- Description: Builds a dot-separated parent path using object names and fallback parent keys.
- Parameters:
  - `object` (`any`) — UI object to inspect
- Returns:
  - `string` — path of parent names/keys from root to the object
- Behavior:
  - Uses `GetName()` when available.
  - Falls back to the parent object's `GetParentKey()` when a name is missing.
- Example:
```lua
print(DF:GetParentNamePath(myFrame))
```

## DF:GetParentKeyPath(object)
- Description: Builds a dot-separated parent path using only `GetParentKey()` values.
- Parameters:
  - `object` (`any`) — UI object to inspect
- Returns:
  - `string` — path of parent keys from root to the object
- Behavior:
  - Returns an empty string when no `GetParentKey()` is available.
- Example:
```lua
print(DF:GetParentKeyPath(myFrame))
```

## DF.table.findsubtable(t, index, value)
- Description: Searches an array of tables for the first entry where `entry[index] == value`.
- Parameters:
  - `t` (`table`) — array of tables
  - `index` (`number`) — key inside each subtable
  - `value` (`any`) — value to match
- Returns:
  - `integer|nil` — index of the matching subtable, or `nil` if none found
- Example:
```lua
local list = {{id = 1}, {id = 2}}
print(DF.table.findsubtable(list, "id", 2)) -- 2
```

## DF.table.find(t, value)
- Description: Searches an array table for the first value matching `value`.
- Parameters:
  - `t` (`table`) — array-style table
  - `value` (`any`) — value to search for
- Returns:
  - `integer|nil` — index of the matching element, or `nil` when not found
- Example:
```lua
print(DF.table.find({"a", "b", "c"}, "b")) -- 2
```

## DF:RandomBool(odds)
- Description: Returns a random boolean.
- Parameters:
  - `odds` (`number?`) — optional probability threshold between `0` and `1`
- Returns:
  - `boolean` — random boolean result
- Behavior:
  - When `odds` is provided, returns `true` with probability `odds`.
  - When `odds` is omitted, returns `true` or `false` with equal probability.
- Example:
```lua
print(DF:RandomBool()) -- true or false
print(DF:RandomBool(0.25)) -- true ~25% of the time
```

## DF:SetTexCoordFromAtlasInfo(texture, atlasInfo)
- Description: Applies atlas texture coordinates from an atlas info table to a texture object.
- Parameters:
  - `texture` (`texture`) — texture object to update
  - `atlasInfo` (`table`) — atlas info containing `leftTexCoord`, `rightTexCoord`, `topTexCoord`, and `bottomTexCoord`
- Returns: none
- Notes:
  - Directly passes the atlas coordinate values to `texture:SetTexCoord(...)`.
- Example:
```lua
DF:SetTexCoordFromAtlasInfo(myTexture, atlasInfo)
```

## DF:GetDefaultBackdropColor()
- Description: Returns the default backdrop color used by addons.
- Parameters: none
- Returns:
  - `number` — red component (0-1)
  - `number` — green component (0-1)
  - `number` — blue component (0-1)
  - `number` — alpha component (0-1)
- Example:
```lua
local r, g, b, a = DF:GetDefaultBackdropColor()
print(r, g, b, a) -- 0.1215, 0.1176, 0.1294, 0.8
```




