
--uiobject: is an object that represents a UI element, such as a frame, a texture, or a button. UIObjects are the base class for all UI elements in the WoW API.
--3D World: is an object which is placed behind|below all UI elements, cannot be parent of any object, in the 3D World object is where the game world is rendered
--size: corresponds to the height and height of an object, it is measure in pixels, must be bigger than zero.
--scale: the size of an object is multiplied by this value, it is measure in percentage, must be between 0.65 and 2.40.
--alpha: corresponds to the transparency of an object, the bigger is the value less transparent is the object, it is measure in percentage, must be between 0 and 1, zero is fully transparent and one is fully opaque.
--controller: abstract term to define who's in control of an entity, can be the server or a player.
--npc: an entity shown in the 3d world with a name and a health bar, can be friendly or hostile, can be interacted with, always controlled by the server.
--player: is an entity that represents a player character, the controller is always player, player is always a human.
--pet: represents a npc controlled by the server and can accept commands from the player.
--guadians: represents a npc, the server has the possess of the controller, don't accept commands like pets, helps attacking the enemies of the npc or player.
--role: is a string that represents the role of a unit, such as tank, healer, or damage dealer. only players can have a role.

---@alias auratype
---| "BUFF"
---| "DEBUFF"

---@alias role
---| "TANK"
---| "HEALER"
---| "DAMAGER"
---| "NONE"

---@alias anchorpoint
---| "topleft"
---| "topright"
---| "bottomleft"
---| "bottomright"
---| "top"
---| "bottom"
---| "left"
---| "right"
---| "center"

---@alias edgenames
---| "topleft"
---| "topright"
---| "bottomleft"
---| "bottomright"
---| "TopLeft"
---| "TopRight"
---| "BottomLeft"
---| "BottomRight"

---@alias framestrata
---| "background"
---| "low"
---| "medium"
---| "high"
---| "dialog"
---| "fullscreen"
---| "fullscreen_dialog"
---| "tooltip"
---| "BACKGROUND"
---| "LOW"
---| "MEDIUM"
---| "HIGH"
---| "DIALOG"
---| "FULLSCREEN"
---| "FULLSCREEN_DIALOG"
---| "TOOLTIP"

---@alias sizingpoint
---| "top"
---| "topright"
---| "right"
---| "bottomright"
---| "bottom"
---| "bottomleft"
---| "left"
---| "topleft"

---@alias drawlayer
---| "background"
---| "border"
---| "artwork"
---| "overlay"
---| "highlight"

---@alias buttontype
---| "AnyUp"
---| "AnyDown"
---| "LeftButtonDown"
---| "LeftButtonUp"
---| "MiddleButtonUp"
---| "MiddleButtonDown"
---| "RightButtonDown"
---| "RightButtonUp"
---| "Button4Up"
---| "Button4Down"
---| "Button5Up"
---| "Button5Down"

---@alias justifyh
---| "left"
---| "right"
---| "center"

---@alias justifyv
---| "top"
---| "bottom"
---| "middle"

---@alias fontflags
---| "none"
---| "outline"
---| "thickoutline"
---| "monochrome"

---@alias outline
---| "NONE"
---| "OUTLINE"
---| "THICKOUTLINE"

---@alias orientation
---| "HORIZONTAL"
---| "VERTICAL"

---@alias class
---| "WARRIOR"
---| "PALADIN"
---| "HUNTER"
---| "ROGUE"
---| "PRIEST"
---| "DEATHKNIGHT"
---| "SHAMAN"
---| "MAGE"
---| "WARLOCK"
---| "MONK"
---| "DRUID"
---| "DEMONHUNTER"
---| "EVOKER"

---@alias instancetype
---| "none"
---| "party"
---| "raid"
---| "arena"
---| "pvp"
---| "scenario"

---@alias texturefilter
---| "LINEAR"
---| "TRILINEAR"
---| "NEAREST"

---@alias texturewrap
---| "CLAMP"
---| "CLAMPTOBLACKADDITIVE"
---| "CLAMPTOBLACK"
---| "CLAMPTOWHITEADDITIVE"
---| "CLAMPTOWHITE"
---| "MIRROR"
---| "REPEAT"
---| "MIRRORONCE"

---@alias blendmode
---| "ADD"
---| "BLEND"
---| "DISABLE"
---| "MOD"
---| "MOD2X"
---| "OVERLAY"
---| "ALPHAKEY"
---| "REPLACE"
---| "SUBTRACT"

---@alias objecttype
---| "Frame"
---| "Button"
---| "FontString"
---| "Texture"
---| "StatusBar"
---| "Font"
---| "EditBox"
---| "CheckButton"
---| "Slider"
---| "Model"
---| "PlayerModel"
---| "DressUpModel"
---| "TabardModel"
---| "Cooldown"
---| "ScrollingMessageFrame"
---| "ScrollFrame"
---| "SimpleHTML"
---| "AnimationGroup"
---| "Animation"
---| "MessageFrame"
---| "Minimap"
---| "GameTooltip"

---@alias audiochannels
---| "Master"
---| "SFX"
---| "Music"
---| "Ambience"
---| "Dialog"

---@class aurainfo : table
---@field applications number
---@field auraInstanceID number
---@field canApplyAura boolean
---@field dispelName string if not dispellable, doesn't have this key
---@field duration number
---@field expirationTime number based on GetTime, if zero, it's a permanent aura (usually weekly buffs)
---@field icon number
---@field isBossAura boolean
---@field isFromPlayerOrPlayerPet boolean
---@field isHelpful boolean true for buffs, false for debuffs
---@field isHarmful boolean true for debuffs, false for buffs
---@field isNameplateOnly boolean
---@field isRaid boolean player can cast this aura or the player can dispel this aura
---@field isStealable boolean
---@field nameplateShowPersonal boolean
---@field nameplateShowAll boolean
---@field points table
---@field spellId number
---@field timeMod number
---@field name string aura name
---@field sourceUnit string unitid

---@alias width number property that represents the horizontal size of a UI element, such as a frame or a texture. Gotten from the first result of GetWidth() or from the first result of GetSize(). It is expected a GetWidth() or GetSize() when the type 'height' is used.
---@alias height number property that represents the vertical size of a UI element, such as a frame or a texture. Gotten from the first result of GetHeight() or from the second result of GetSize(). It is expected a GetHeight() or GetSize() when the type 'height' is used.
---@alias framelevel number represent how high a frame is placed within its strata. The higher the frame level, the more likely it is to appear in front of other frames. The frame level is a number between 0 and 65535. The default frame level is 0. The frame level is set with the SetFrameLevel() function.
---@alias red number color value representing the red component of a color, the value must be between 0 and 1. To retrieve a color from a string or table use: local red, green, blue, alpha = DetailsFramework:ParseColors(color)
---@alias green number color value representing the green component of a color, the value must be between 0 and 1. To retrieve a color from a string or table use: local red, green, blue, alpha = DetailsFramework:ParseColors(color)
---@alias blue number color value representing the blue component of a color, the value must be between 0 and 1. To retrieve a color from a string or table use: local red, green, blue, alpha = DetailsFramework:ParseColors(color)
---@alias alpha number @number(0-1.0) value representing the alpha (transparency) of a UIObject, the value must be between 0 and 1. 0 is fully transparent, 1 is fully opaque.
---@alias unit string string that represents a unit in the game, such as the player, a party member, or a raid member.
---@alias health number amount of hit points (health) of a unit. This value can be changed by taking damage or healing.
---@alias encounterid number encounter ID number received by the event ENCOUNTER_START and ENCOUNTER_END
---@alias encounterejid number encounter ID number used by the encounter journal
---@alias encountername string encounter name received by the event ENCOUNTER_START and ENCOUNTER_END also used by the encounter journal
---@alias spellid number each spell in the game has a unique spell id, this id can be used to identify a spell.
---@alias unitname string name of a unit
---@alias unitguid string unique id of a unit (GUID)
---@alias actorname string name of a unit
---@alias petname string refers to a pet's name
---@alias ownername string refers to the pet's owner name
---@alias spellname string name of a spell
---@alias spellschool number each spell in the game has a school, such as fire, frost, shadow and many others. This value can be used to identify the school of a spell.
---@alias actorid string unique id of a unit (GUID)
---@alias serial string unique id of a unit (GUID)
---@alias guid string unique id of a unit (GUID)
---@alias specializationid number the ID of a class specialization
---@alias controlflags number flags telling what unit type the is (player, npc, pet, etc); it's relatiotionship to the player (friendly, hostile, etc); who controls the unit (controlled by the player, controlled by the server, etc)
---@alias color table @table(r: red|number, g: green|number, b: blue|number, a: alpha|number) @table(number, number, number, number) @string(color name) @hex (000000-ffffff) value representing a color, the value must be a table with the following fields: r, g, b, a. r, g, b are numbers between 0 and 1, a is a number between 0 and 1. To retrieve a color from a string or table use: local red, green, blue, alpha = DetailsFramework:ParseColors(color)
---@alias scale number @number(0.65-2.40) value representing the scale factor of the UIObject, the value must be between 0.65 and 2.40, the width and height of the UIObject will be multiplied by this value.
---@alias script string, function is a piece of code that is executed in response to a specific event, such as a button click or a frame update. Scripts can be used to implement behavior and logic for UI elements.
---@alias event string is a notification that is sent to a frame when something happens, such as a button click or a frame update. Events can be used to trigger scripts.
---@alias backdrop table @table(bgFile: string, edgeFile: string, tile: edgeSize: number, backgroundColor: color, borderColor: color) is a table that contains information about the backdrop of a frame. The backdrop is the background of a frame, which can be a solid color, a gradient, or a texture.
---@alias npcid number a number that identifies a specific npc in the game.
---@alias textureid number each texture from the game client has an id.
---@alias texturepath string access textures from addons.
---@alias atlasname string a name of an atlas, an atlas name is used with the SetAtlas() function to display a texture from the game client.
---@alias valueamount number used to represent a value, such as a damage amount, a healing amount, or a resource amount.
---@alias unixtime number a number that represents the number of seconds that have elapsed since 00:00:00 Coordinated Universal Time (UTC), Thursday, 1 January 1970, not counting leap seconds.
---@alias timestring string refers to a string showing a time value, such as "1:23" or "1:23:45".
---@alias combattime number elapsed time of a combat or time in seconds that a unit has been in combat.
---@alias auraduration number
---@alias gametime number number of seconds that have elapsed since the start of the game session.
---@alias coordleft number
---@alias coordright number
---@alias coordtop number
---@alias coordbottom number
---@alias addonname string name of an addon, same as the name of the ToC file.
---@alias profile table a table containing the settings of an addon, usually saved in the SavedVariables file.
---@alias profilename string name of a profile.

---@class _G
---@field RegisterAttributeDriver fun(statedriver: frame, attribute: string, conditional: string)
---@field RegisterStateDriver fun(statedriver: frame, attribute: string, conditional: string)
---@field UnitGUID fun(unit: string): string
---@field UnitName fun(unit: string): string
---@field GetCursorPosition fun(): number, number return the position of the cursor on the screen, in pixels, relative to the bottom left corner of the screen.
---@field C_Timer C_Timer

---@class timer : table
---@field Cancel fun(self: timer)
---@field IsCancelled fun(self: timer): boolean

---@class C_Timer : table
---@field After fun(delay: number, func: function)
---@field NewTimer fun(delay: number, func: function): timer
---@field NewTicker fun(interval: number, func: function, iterations: number|nil): timer

---@class C_ChallengeMode : table
---@field GetActiveKeystoneInfo fun(): number, number[], boolean @returns keystoneLevel, affixIDs, wasActive

---@class tablesize : {H: number, W: number}
---@class tablecoords : {L: number, R: number, T: number, B: number}
---@class texturecoords: {left: number, right: number, top: number, bottom: number}
---@class objectsize : {height: number, width: number}
---@class texturetable : {texture: string, coords: texturecoords, size: objectsize}

---@class uiobject
---@field GetObjectType fun(self: uiobject) : objecttype
---@field IsObjectType fun(self: uiobject, objectType: string) : boolean
---@field Show fun(self: uiobject) make the object be shown on the user screen
---@field Hide fun(self: uiobject) make the object be hidden from the user screen
---@field SetShown fun(self: uiobject, state: boolean) show or hide the object
---@field IsVisible fun(self: uiobject) : boolean return if the object is visible or not, visibility accounts for the object parent's be not shown
---@field IsShown fun(self: uiobject) : boolean return if the object is shown or not
---@field SetAllPoints fun(self: uiobject, target: uiobject|nil) set the object to be the same size as its parent or the target object
---@field SetParent fun(self: uiobject, parent: frame) set the parent object of the object
---@field SetSize fun(self: uiobject, width: width|number, height: height|number) set the width and height of the object
---@field SetWidth fun(self: uiobject, width: width|number) set only the width of the object
---@field SetHeight fun(self: uiobject, height: height|number) set only the height of the object
---@field SetAlpha fun(self: uiobject, alpha: alpha|number) set the transparency of the object
---@field SetScale fun(self: uiobject, scale: scale|number)
---@field GetWidth fun(self: uiobject) : width|number
---@field GetHeight fun(self: uiobject) : height|number
---@field GetScale fun(self: uiobject) : scale|number
---@field GetAlpha fun(self: uiobject) : alpha|number
---@field GetSize fun(self: uiobject) : width|number, height|number
---@field GetParent fun(self: uiobject) : any
---@field GetPoint fun(self: uiobject, index: number): string, frame, string, number, number
---@field GetCenter fun(self: uiobject): number, number
---@field SetPoint fun(self: uiobject, point: anchorpoint, relativeFrame: uiobject, relativePoint: anchorpoint, xOffset: number, yOffset: number)
---@field ClearAllPoints fun(self: uiobject)
---@field CreateAnimationGroup fun(self: uiobject, name: string|nil, templateName: string|nil) : animationgroup

---@class animationgroup : uiobject
---@field CreateAnimation fun(self: animationgroup, animationType: string, name: string|nil, inheritsFrom: string|nil) : animation
---@field GetAnimation fun(self: animationgroup, name: string) : animation
---@field GetAnimations fun(self: animationgroup) : table
---@field GetDuration fun(self: animationgroup) : number
---@field GetEndDelay fun(self: animationgroup) : number
---@field GetLoopState fun(self: animationgroup) : boolean
---@field GetScript fun(self: animationgroup, event: string) : function
---@field GetSmoothProgress fun(self: animationgroup) : boolean
---@field IsDone fun(self: animationgroup) : boolean
---@field IsPaused fun(self: animationgroup) : boolean
---@field IsPlaying fun(self: animationgroup) : boolean
---@field Pause fun(self: animationgroup)
---@field Play fun(self: animationgroup)
---@field Resume fun(self: animationgroup)
---@field SetDuration fun(self: animationgroup, duration: number)
---@field SetEndDelay fun(self: animationgroup, delay: number)
---@field SetLooping fun(self: animationgroup, loop: boolean)
---@field SetScript fun(self: animationgroup, event: string, handler: function|nil) "OnEvent"|"OnShow"
---@field SetSmoothProgress fun(self: animationgroup, smooth: boolean)
---@field Stop fun(self: animationgroup)

---@class animation : uiobject
---@field GetDuration fun(self: animation) : number
---@field GetEndDelay fun(self: animation) : number
---@field GetOrder fun(self: animation) : number
---@field GetScript fun(self: animation, event: string) : function
---@field GetSmoothing fun(self: animation) : string
---@field IsDone fun(self: animation) : boolean
---@field IsPaused fun(self: animation) : boolean
---@field IsPlaying fun(self: animation) : boolean
---@field Pause fun(self: animation)
---@field Play fun(self: animation)
---@field Resume fun(self: animation)
---@field SetDuration fun(self: animation, duration: number)
---@field SetEndDelay fun(self: animation, delay: number)
---@field SetOrder fun(self: animation, order: number)
---@field SetScript fun(self: animation, event: string, handler: function?)
---@field SetSmoothing fun(self: animation, smoothing: string)
---@field Stop fun(self: animation)

---@class line : uiobject
---@field GetEndPoint fun(self: line) : relativePoint: anchorpoint, relativeTo: anchorpoint, offsetX: number, offsetY: number
---@field GetStartPoint fun(self: line) : relativePoint: anchorpoint, relativeTo: anchorpoint, offsetX: number, offsetY: number
---@field GetThickness fun(self: line) : number
---@field SetStartPoint fun(self: line, point: anchorpoint, relativeFrame: uiobject|number, relativePoint: anchorpoint|number, xOffset: number?, yOffset: number?)
---@field SetEndPoint fun(self: line, point: anchorpoint, relativeFrame: uiobject|number, relativePoint: anchorpoint|number, xOffset: number?, yOffset: number?)
---@field SetColorTexture fun(self: line, red: number, green: number, blue: number, alpha: number?)
---@field SetThickness fun(self: line, thickness: number)

---@class frame : uiobject
---@field __background texture
---@field CreateLine fun(self: frame, name: string?, drawLayer: drawlayer, templateName: string?, subLevel: number?) : line
---@field SetID fun(self: frame, id: number) set an ID for the frame
---@field SetAttribute fun(self: frame, name: string, value: any)
---@field SetScript fun(self: frame, event: string, handler: function?)
---@field GetScript fun(self: frame, event: string) : function
---@field SetFrameStrata fun(self: frame, strata: framestrata)
---@field SetFrameLevel fun(self: frame, level: number)
---@field SetClampedToScreen fun(self: frame, clamped: boolean)
---@field SetClampRectInsets fun(self: frame, left: number, right: number, top: number, bottom: number)
---@field SetMovable fun(self: frame, movable: boolean)
---@field SetUserPlaced fun(self: frame, userPlaced: boolean)
---@field SetBackdrop fun(self: frame, backdrop: backdrop|table)
---@field SetBackdropColor fun(self: frame, red: red|number, green: green|number, blue: blue|number, alpha: alpha|number?)
---@field SetBackdropBorderColor fun(self: frame, red: red|number, green: green|number, blue: blue|number, alpha: alpha|number?)
---@field GetBackdrop fun(self: frame) : backdrop
---@field GetBackdropColor fun(self: frame) : red|number, green|number, blue|number, alpha|number
---@field GetBackdropBorderColor fun(self: frame) : red|number, green|number, blue|number, alpha|number
---@field SetHitRectInsets fun(self: frame, left: number, right: number, top: number, bottom: number)
---@field SetToplevel fun(self: frame, toplevel: boolean)
---@field SetPropagateKeyboardInput fun(self: frame, propagate: boolean)
---@field SetPropagateGamepadInput fun(self: frame, propagate: boolean)
---@field StartMoving fun(self: frame)
---@field IsMovable fun(self: frame) : boolean
---@field StartSizing fun(self: frame, sizingpoint: sizingpoint?)
---@field StopMovingOrSizing fun(self: frame)
---@field GetAttribute fun(self: frame, name: string) : any
---@field GetFrameLevel fun(self: frame) : number
---@field GetFrameStrata fun(self: frame) : framestrata
---@field GetNumChildren fun(self: frame) : number
---@field GetNumPoints fun(self: frame) : number
---@field GetNumRegions fun(self: frame) : number
---@field GetName fun(self: frame) : string
---@field GetChildren fun(self: frame) : frame[]
---@field GetRegions fun(self: frame) : region[]
---@field CreateTexture fun(self: frame, name: string?, layer: drawlayer, inherits: string?, subLayer: number?) : texture
---@field CreateMaskTexture fun(self: frame, name: string?, layer: drawlayer, inherits: string?, subLayer: number?) : texture
---@field CreateFontString fun(self: frame, name: string?, layer: drawlayer, inherits: string?, subLayer: number?) : fontstring
---@field EnableMouse fun(self: frame, enable: boolean) enable mouse interaction
---@field SetResizable fun(self: frame, enable: boolean) enable resizing of the frame
---@field EnableMouseWheel fun(self: frame, enable: boolean) enable mouse wheel scrolling
---@field RegisterForDrag fun(self: frame, button: string) register the frame for drag events, allowing it to be dragged by the mouse
---@field SetResizeBounds fun(self: frame, minWidth: number, minHeight: number, maxWidth: number, maxHeight: number) set the minimum and maximum size of the frame
---@field RegisterEvent fun(self: frame, event: string) register for an event, trigers "OnEvent" script when the event is fired
---@field RegisterUnitEvent fun(self: frame, event: string, unitId: unit) register for an event, trigers "OnEvent" only if the event occurred for the registered unit
---@field UnregisterEvent fun(self: frame, event: string) unregister for an event
---@field HookScript fun(self: frame, event: string, handler: function) run a function after the frame's script has been executed, carrying the same arguments

---@class cooldown : frame
---@field Clear fun(self: cooldown)
---@field GetCooldownDuration fun(self: cooldown) : number @returns duration
---@field GetCooldownTimes fun(self: cooldown) : number, number @returns startTime, duration
---@field GetCooldownDisplayDuration fun(self: cooldown) : number @returns duration
---@field GetDrawBling fun(self: cooldown) : boolean @returns drawBling
---@field GetDrawEdge fun(self: cooldown) : boolean @returns drawEdge
---@field GetDrawSwipe fun(self: cooldown) : boolean @returns drawSwipe
---@field GetEdgeScale fun(self: cooldown) : number @returns scale
---@field GetReverse fun(self: cooldown) : boolean @returns reverse
---@field GetRotation fun(self: cooldown) : number @returns radians
---@field IsPaused fun(self: cooldown) : boolean
---@field Pause fun(self: cooldown)
---@field Resume fun(self: cooldown)
---@field SetBlingTexture fun(self: cooldown, texture: textureid|texturepath, r: red|number?, g: green|number?, b: blue|number?, a: alpha|number?)
---@field SetCooldown fun(self: cooldown, startTime: gametime, duration: number, modRate: number?) set the cooldown to start at startTime and last for duration seconds
---@field SetCooldownDuration fun(self: cooldown, duration: number, modRate: number?)
---@field SetCooldownUNIX fun(self: cooldown, startTime: unixtime, duration: number, modRate: number?)
---@field SetCountdownAbbrevThreshold fun(self: cooldown, seconds: number)
---@field SetCountdownFont fun(self: cooldown, font: string)
---@field SetDrawBling fun(self: cooldown, draw: boolean)
---@field SetDrawEdge fun(self: cooldown, draw: boolean)
---@field SetDrawSwipe fun(self: cooldown, draw: boolean)
---@field SetEdgeScale fun(self: cooldown, scale: number)
---@field SetEdgeTexture fun(self: cooldown, texture: textureid|texturepath, r: red|number?, g: green|number?, b: blue|number?, a: alpha|number?)
---@field SetHideCountdownNumbers fun(self: cooldown, hide: boolean)
---@field SetReverse fun(self: cooldown, reverse: boolean)
---@field SetRotation fun(self: cooldown, radians: number)
---@field SetSwipeColor fun(self: cooldown, r: red|number, g: green|number, b: blue|number, a: alpha|number?)
---@field SetSwipeTexture fun(self: cooldown, texture: textureid|texturepath, r: red|number?, g: green|number?, b: blue|number?, a: alpha|number?)
---@field SetUseCircularEdge fun(self: cooldown, use: boolean)

---@class button : frame
---@field Click fun(self: button)
---@field SetNormalTexture fun(self: button, texture: textureid|texturepath)
---@field SetPushedTexture fun(self: button, texture: textureid|texturepath)
---@field SetHighlightTexture fun(self: button, texture: textureid|texturepath)
---@field SetDisabledTexture fun(self: button, texture: textureid|texturepath)
---@field SetCheckedTexture fun(self: button, texture: textureid|texturepath)
---@field SetNormalFontObject fun(self: button, fontString: fontstring)
---@field SetHighlightFontObject fun(self: button, fontString: fontstring)
---@field SetDisabledFontObject fun(self: button, fontString: fontstring)
---@field SetText fun(self: button, text: string)
---@field GetText fun(self: button) : string
---@field SetTextInsets fun(self: button, left: number, right: number, top: number, bottom: number)
---@field GetTextInsets fun(self: button) : number, number, number, number
---@field SetDisabledTextColor fun(self: button, r: red|number, g: green|number, b: blue|number, a: alpha|number?)
---@field GetDisabledTextColor fun(self: button) : number, number, number, number
---@field SetFontString fun(self: button, fontString: fontstring)
---@field GetFontString fun(self: button) : fontstring
---@field SetButtonState fun(self: button, state: string, enable: boolean)
---@field GetButtonState fun(self: button, state: string) : boolean
---@field RegisterForClicks fun(self: button, button1: buttontype?, button2: buttontype?, button3: buttontype?, button4: buttontype?)
---@field GetNormalTexture fun(self: button) : texture
---@field GetPushedTexture fun(self: button) : texture
---@field GetHighlightTexture fun(self: button) : texture
---@field GetDisabledTexture fun(self: button) : texture

---@class statusbar : frame
---@field SetStatusBarColor fun(self: statusbar, r: red|number, g: green|number, b: blue|number, a: alpha|number?)
---@field SetStatusBarTexture fun(self: statusbar, path: string|texture)
---@field GetStatusBarTexture fun(self: statusbar) : texture
---@field SetMinMaxValues fun(self: statusbar, minValue: number, maxValue: number)
---@field SetValue fun(self: statusbar, value: number)
---@field SetValueStep fun(self: statusbar, valueStep: number)
---@field SetOrientation fun(self: statusbar, orientation: orientation)
---@field SetReverseFill fun(self: statusbar, reverseFill: boolean)
---@field GetMinMaxValues fun(self: statusbar) : number, number
---@field GetValue fun(self: statusbar) : number
---@field GetValueStep fun(self: statusbar) : number
---@field GetOrientation fun(self: statusbar) : orientation
---@field GetReverseFill fun(self: statusbar) : boolean

---@class scrollframe : frame
---@field SetScrollChild fun(self: scrollframe, child: frame)
---@field GetScrollChild fun(self: scrollframe) : frame
---@field SetHorizontalScroll fun(self: scrollframe, offset: number)
---@field SetVerticalScroll fun(self: scrollframe, offset: number)
---@field GetHorizontalScroll fun(self: scrollframe) : number
---@field GetVerticalScroll fun(self: scrollframe) : number
---@field GetHorizontalScrollRange fun(self: scrollframe) : number
---@field GetVerticalScrollRange fun(self: scrollframe) : number

---@class region : uiobject

---@class fontstring : region
---@field SetDrawLayer fun(self: fontstring, layer: drawlayer, subLayer: number?)
---@field SetFont fun(self: fontstring, font: string, size: number, flags: string)
---@field SetText fun(self: fontstring, text: string|number)
---@field GetText fun(self: fontstring) : string
---@field GetFont fun(self: fontstring) : string, number, string
---@field GetStringWidth fun(self: fontstring) : number return the width of the string in pixels
---@field GetStringHeight fun(self: fontstring) : number return the height of the string in pixels
---@field SetShadowColor fun(self: fontstring, r: red|number, g: green|number, b: blue|number, a: alpha|number?)
---@field GetShadowColor fun(self: fontstring) : number, number, number, number
---@field SetShadowOffset fun(self: fontstring, offsetX: number, offsetY: number)
---@field GetShadowOffset fun(self: fontstring) : number, number
---@field SetTextColor fun(self: fontstring, r: red|number, g: green|number, b: blue|number, a: alpha|number?)
---@field GetTextColor fun(self: fontstring) : number, number, number, number
---@field SetJustifyH fun(self: fontstring, justifyH: justifyh)
---@field GetJustifyH fun(self: fontstring) : string
---@field SetJustifyV fun(self: fontstring, justifyV: justifyv)
---@field GetJustifyV fun(self: fontstring) : string
---@field SetNonSpaceWrap fun(self: fontstring, nonSpaceWrap: boolean)
---@field GetNonSpaceWrap fun(self: fontstring) : boolean
---@field SetIndentedWordWrap fun(self: fontstring, indentedWordWrap: boolean)
---@field GetIndentedWordWrap fun(self: fontstring) : boolean
---@field SetMaxLines fun(self: fontstring, maxLines: number)
---@field GetMaxLines fun(self: fontstring) : number
---@field SetWordWrap fun(self: fontstring, wordWrap: boolean)
---@field GetWordWrap fun(self: fontstring) : boolean
---@field SetSpacing fun(self: fontstring, spacing: number)
---@field GetSpacing fun(self: fontstring) : number
---@field SetLineSpacing fun(self: fontstring, lineSpacing: number)
---@field GetLineSpacing fun(self: fontstring) : number
---@field SetMaxLetters fun(self: fontstring, maxLetters: number)
---@field GetMaxLetters fun(self: fontstring) : number
---@field SetTextInsets fun(self: fontstring, left: number, right: number, top: number, bottom: number)
---@field GetTextInsets fun(self: fontstring) : number, number, number, number
---@field SetTextJustification fun(self: fontstring, justifyH: string, justifyV: string)
---@field GetTextJustification fun(self: fontstring) : string, string
---@field SetTextShadowColor fun(self: fontstring, r: red|number, g: green|number, b: blue|number, a: alpha|number?)
---@field GetTextShadowColor fun(self: fontstring) : number, number, number, number
---@field SetTextShadowOffset fun(self: fontstring, offsetX: number, offsetY: number)
---@field GetTextShadowOffset fun(self: fontstring) : number, number
---@field SetTextShadow fun(self: fontstring, offsetX: number, offsetY: number, r: red|number, g: green|number, b: blue|number, a: alpha|number?)
---@field SetTextTruncate fun(self: fontstring, truncate: string)
---@field GetTextTruncate fun(self: fontstring) : string
---@field SetTextTruncateWidth fun(self: fontstring, width: number)
---@field GetTextTruncateWidth fun(self: fontstring) : number
---@field SetTextTruncateLines fun(self: fontstring, lines: number)
---@field GetTextTruncateLines fun(self: fontstring) : number

---@class texture : region
---@field SetDrawLayer fun(self: texture, layer: drawlayer, subLayer: number?)
---@field GetTexture fun(self: texture) : any
---@field SetTexture fun(self: texture, path: textureid|texturepath, horizontalWrap: texturewrap?, verticalWrap: texturewrap?, filter: texturefilter?)
---@field SetAtlas fun(self: texture, atlas: string)
---@field SetColorTexture fun(self: texture, r: red|number, g: green|number, b: blue|number, a: alpha|number?)
---@field SetDesaturated fun(self: texture, desaturate: boolean)
---@field SetDesaturation fun(self: texture, desaturation: number)
---@field SetBlendMode fun(self: texture, mode: blendmode)
---@field SetVertexColor fun(self: texture, r: red|number, g: green|number, b: blue|number, a: alpha|number?)
---@field GetPoint fun(self: texture, index: number) : string, table, string, number, number
---@field SetShown fun(self: texture, state: boolean)
---@field IsShown fun(self: texture) : boolean
---@field GetParent fun(self: texture) : table
---@field SetTexCoord fun(self: texture, left: number, right: number, top: number, bottom: number)
---@field GetTexCoord fun(self: texture) : number, number, number, number
---@field SetRotation fun(self: texture, rotation: number)
---@field GetRotation fun(self: texture) : number
---@field SetRotationRadians fun(self: texture, rotation: number)
---@field GetRotationRadians fun(self: texture) : number
---@field SetRotationDegrees fun(self: texture, rotation: number)
---@field GetRotationDegrees fun(self: texture) : number
---@field SetMask fun(self: texture, mask: table)
---@field GetMask fun(self: texture) : table
---@field SetMaskTexture fun(self: texture, maskTexture: table)
---@field GetMaskTexture fun(self: texture) : table
---@field GetDesaturated fun(self: texture) : boolean
---@field SetGradient fun(self: texture, gradient: string)
---@field GetGradient fun(self: texture) : string
---@field SetGradientAlpha fun(self: texture, gradient: string)
---@field GetGradientAlpha fun(self: texture) : string
---@field SetGradientRotation fun(self: texture, rotation: number)
---@field GetGradientRotation fun(self: texture) : number
---@field SetGradientRotationRadians fun(self: texture, rotation: number)
---@field GetGradientRotationRadians fun(self: texture) : number
---@field SetGradientRotationDegrees fun(self: texture, rotation: number)
---@field GetGradientRotationDegrees fun(self: texture) : number
---@field SetGradientColors fun(self: texture, ...)
---@field GetGradientColors fun(self: texture) : number, number, number, number, number, number, number, number, number, number, number, number
---@field GetBlendMode fun(self: texture) : string
---@field GetVertexColor fun(self: texture) : number, number, number, number

---@class editbox : frame
---@field SetText fun(self: editbox, text: string)
---@field GetText fun(self: editbox) : string
---@field SetCursorPosition fun(self: editbox, position: number)
---@field GetCursorPosition fun(self: editbox) : number
---@field SetMaxLetters fun(self: editbox, maxLetters: number)
---@field GetMaxLetters fun(self: editbox) : number
---@field SetNumeric fun(self: editbox, numeric: boolean)
---@field GetNumeric fun(self: editbox) : boolean
---@field SetMultiLine fun(self: editbox, multiLine: boolean)
---@field GetMultiLine fun(self: editbox) : boolean
---@field SetAutoFocus fun(self: editbox, autoFocus: boolean)
---@field GetAutoFocus fun(self: editbox) : boolean
---@field SetFont fun(self: editbox, font: string, size: number, flags: string)
---@field SetFontObject fun(self: editbox, fontString: fontstring)
---@field GetFont fun(self: editbox) : string, number, string
---@field SetTextColor fun(self: editbox, r: red|number, g: green|number, b: blue|number, a: alpha|number?)
---@field SetJustifyH fun(self:editbox, alignment:string)
---@field SetTextInsets fun(self:editbox, left:number, right:number, top:number, bottom:number)
---@field SetFocus fun(self:editbox, focus:boolean)
---@field HasFocus fun(self:editbox) : boolean return true if the editbox has focus
---@field HighlightText fun(self:editbox, start:number?, finish:number?) select a portion of the text, passing zero will select the entire text


--functions
C_ChatInfo = true
unpack = true
abs = true
IsInGroup = true
Ambiguate = true
IsInRaid = true
LE_PARTY_CATEGORY_INSTANCE = true
C_Timer = true
ceil = true
strsplit = true
INVSLOT_FIRST_EQUIPPED = true
INVSLOT_LAST_EQUIPPED = true
floor = true
tremove = true
GetSpellCharges = function(spellId) end
AddTrackedAchievement = true
CanShowAchievementUI = true
ClearAchievementComparisonUnit = true
GetAchievementCategory = true
GetAchievementComparisonInfo = true
GetAchievementCriteriaInfo = true
GetAchievementInfo = true
GetAchievementInfoFromCriteria = true
GetAchievementLink = true
GetAchievementNumCriteria = true
GetSpecializationInfo = true
GetAchievementNumRewards = true
GetCategoryInfo = true
GetCategoryList = true
GetSpecialization = true
GetCategoryNumAchievements = true
GetComparisonAchievementPoints = true
GetComparisonCategoryNumAchievements = true
GetComparisonStatistic = true
GetLatestCompletedAchievements = true
GetLatestCompletedComparisonAchievements = true
GetLatestUpdatedComparisonStatsGetLatestUpdatedStats = true
GetNextAchievement = true
GetNumComparisonCompletedAchievements = true
GetNumCompletedAchievements = true
GetPreviousAchievement = true
GetStatistic = true
GetStatisticsCategoryList = true
GetTotalAchievementPoints = true
GetTrackedAchievements = true
GetNumTrackedAchievements = true
RemoveTrackedAchievement = true
SetAchievementComparisonUnit = true
ActionButtonDown = true
ActionButtonUp = true
ActionHasRange = true
CameraOrSelectOrMoveStart = true
CameraOrSelectOrMoveStop = true
ChangeActionBarPage = true
GetActionBarPage = true
GetActionBarToggles = true
GetActionCooldown = true
GetActionCount = true
GetActionInfo = true
GetActionText = true
GetActionTexture = true
GetBonusBarOffset = true
GetMouseButtonClicked = true
GetMultiCastBarOffset = true
GetPossessInfo = true
HasAction = true
IsActionInRange = true
IsAttackAction = true
IsAutoRepeatAction = true
IsCurrentAction = true
IsConsumableAction = true
IsEquippedAction = true
IsUsableAction = true
PetHasActionBar = true
PickupAction = true
PickupPetAction = true
PlaceAction = true
SetActionBarToggles = true
StopAttack = true
TurnOrActionStart = true
TurnOrActionStop = true
UseAction = true
AcceptDuel = true
AttackTarget = true
CancelDuel = true
CancelLogout = true
ClearTutorials = true
CancelSummon = true
ConfirmSummon = true
DescendStop = true
Dismount = true
FlagTutorial = true
ForceQuit = true
GetPVPTimer = true
GetSummonConfirmAreaName = true
GetSummonConfirmSummoner = true
GetSummonConfirmTimeLeft = true
RandomRoll = true
SetPVP = true
StartDuel = true
TogglePVP = true
ToggleSheath = true
UseSoulstone = true
CanSolveArtifact = true
UIParent = true
GetArtifactInfoByRace = true
GetArtifactProgress = true
GetNumArtifactsByRace = true
GetSelectedArtifactInfo = true
IsArtifactCompletionHistoryAvailable = true
ItemAddedToArtifact = true
RemoveItemFromArtifact = true
RequestArtifactCompletionHistory = true
SocketItemToArtifact = true
AcceptArenaTeam = true
ArenaTeamInviteByName = true
ArenaTeamSetLeaderByName = true
ArenaTeamLeave = true
ArenaTeamRoster = true
ArenaTeamUninviteByName = true
ArenaTeamDisband = true
DeclineArenaTeam = true
GetArenaTeam = true
GetArenaTeamGdfInf = true
oGetArenaTeamRosterInfo = true
GetBattlefieldTeamInfo = true
GetCurrentArenaSeason = true
GetInspectArenaTeamData = true
GetNumArenaTeamMembers = true
GetPreviousArenaSeason = true
IsActiveBattlefieldArena = true
IsArenaTeamCaptain = true
IsInArenaTeam = true
CalculateAuctionDeposit = true
CanCancelAuction = true
CancelSell = true
CanSendAuctionQuery = true
CancelAuction = true
ClickAuctionSellItemButton = true
CloseAuctionHouse = true
GetAuctionHouseDepositRate = true
GetAuctionInvTypes = true
GetAuctionItemClasses = true
GetAuctionItemInfo = true
GetAuctionItemLink = true
GetAuctionItemSubClasses = true
GetAuctionItemTimeLeft = true
GetAuctionSellItemInfo = true
GetBidderAuctionItems = true
GetNumAuctionItems = true
GetOwnerAuctionItems = true
GetSelectedAuctionItem = true
IsAuctionSortReversed = true
PlaceAuctionBid = true
QueryAuctionItems = true
SetAuctionsTabShowing = true
SetSelectedAuctionItem = true
SortAuctionItems = true
StartAuction = true
BankButtonIDToInvSlotID = true
CloseBankFrame = true
GetBankSlotCost = true
GetNumBankSlots = true
PurchaseSlot = true
AcceptAreaSpiritHeal = true
AcceptBattlefieldPort = true
CancelAreaSpiritHeal = true
CanJoinBattlefieldAsGroup = true
CheckSpiritHealerDist = true
GetAreaSpiritHealerTime = true
GetBattlefieldEstimatedWaitTime = true
GetBattlefieldFlagPosition = true
GetBattlefieldInstanceExpiration = true
GetBattlefieldInstanceRunTime = true
GetBattlefieldMapIconScale = true
GetBattlefieldPortExpiration = true
GetBattlefieldPosition = true
GetBattlefieldScore = true
GetBattlefieldStatData = true
GetBattlefieldStatInfo = true
GetBattlefieldStatus = true
GetBattlefieldTimeWaited = true
GetBattlefieldWinner = true
GetBattlegroundInfo = true
GetNumBattlefieldFlagPositions = true
GetNumBattlefieldPositions = true
GetNumBattlefieldScores = true
GetNumBattlefieldStats = true
GetNumWorldStateUI = true
GetWintergraspWaitTime = true
GetWorldStateUIInfo = true
IsPVPTimerRunning = true
JoinBattlefield = true
LeaveBattlefield = true
ReportPlayerIsPVPAFK = true
RequestBattlefieldPositions = true
RequestBattlefieldScoreData = true
RequestBattlegroundInstanceInfo = true
SetBattlefieldScoreFaction = true
GetBinding = true
GetBindingAction = true
GetBindingKey = true
GetBindingText = true
GetCurrentBindingSet = true
GetNumBindings = true
LoadBindings = true
RunBinding = true
SaveBindings = true
SetBinding = true
SetBindingSpell = true
SetBindingClick = true
SetBindingItem = true
SetBindingMacro = true
SetConsoleKey = true
SetOverrideBinding = true
SetOverrideBindingSpell = true
SetOverrideBindingClick = true
SetOverrideBindingItem = true
SetOverrideBindingMacro = true
ClearOverrideBindings = true
SetMouselookOverrideBinding = true
IsModifierKeyDown = true
IsModifiedClick = true
IsMouseButtonDown = true
CancelUnitBuff = true
CancelShapeshiftForm = true
CancelItemTempEnchantment = true
GetWeaponEnchantInfo = true
UnitAura = true
UnitBuff = true
UnitDebuff = true
AddChatWindowChannel = true
ChannelBan = true
ChannelInvite = true
ChannelKick = true
ChannelModerator = true
ChannelMute = true
ChannelToggleAnnouncements = true
ChannelUnban = true
ChannelUnmoderator = true
ChannelUnmute = true
DisplayChannelOwner = true
DeclineInvite = true
EnumerateServerChannels = true
GetChannelList = true
GetChannelName = true
GetChatWindowChannels = true
JoinChannelByName = true
LeaveChannelByName = true
ListChannelByName = true
ListChannels = true
RemoveChatWindowChannel = true
SendChatMessage = true
SetChannelOwner = true
SetChannelPassword = true
AcceptResurrect = true
AcceptXPLoss = true
CheckBinderDist = true
ConfirmBinder = true
DeclineResurrect = true
DestroyTotem = true
GetBindLocation = true
GetComboPoints = true
GetCorpseRecoveryDelay = true
GetCurrentTitle = true
GetMirrorTimerInfo = true
GetMirrorTimerProgress = true
GetMoney = true
GetNumTitles = true
GetPlayerFacing = true
GetPVPDesired = true
GetReleaseTimeRemaining = true
GetResSicknessDuration = true
GetRestState = true
GetRuneCooldown = true
GetRuneCount = true
GetRuneType = true
GetTimeToWellRested = true
GetTitleName = true
GetUnitPitch = true
GetXPExhaustion = true
HasFullControl = true
HasSoulstone = true
IsFalling = true
IsFlying = true
IsFlyableArea = true
IsIndoors = true
IsMounted = true
IsOutdoors = true
IsOutOfBounds = true
IsResting = true
IsStealthed = true
IsSwimming = true
IsTitleKnown = true
IsXPUserDisabled = true
NotWhileDeadError = true
ResurrectHasSickness = true
ResurrectHasTimer = true
ResurrectGetOfferer = true
RetrieveCorpse = true
SetCurrentTitle = true
TargetTotem = true
GetArmorPenetration = true
GetAttackPowerForStat = true
GetAverageItemLevel = true
GetBlockChance = true
GetCombatRating = true
GetCombatRatingBonus = true
GetCritChance = true
GetCritChanceFromAgility = true
GetDodgeChance = true
GetExpertise = true
GetExpertisePercent = true
GetManaRegen = true
GetMaxCombatRatingBonus = true
GetParryChance = true
GetPetSpellBonusDamage = true
GetPowerRegen = true
GetSpellBonusDamage = true
GetRangedCritChance = true
GetSpellBonusHealing = true
GetSpellCritChance = true
GetShieldBlock = true
GetSpellCritChanceFromIntellect = true
GetSpellPenetration = true
AddChatWindowChannel = true
ChangeChatColor = true
ChatFrame_AddChannel = true
ChatFrame_AddMessageEventFilter = true
ChatFrame_GetMessageEventFilters = true
ChatFrame_OnHyperlinkShow = true
ChatFrame_RemoveMessageEventFilter = true
GetAutoCompleteResults = true
GetChatTypeIndex = true
GetChatWindowChannels = true
GetChatWindowInfo = true
GetChatWindowMessages = true
JoinChannelByName = true
LoggingChat = true
LoggingCombat = true
RemoveChatWindowChannel = true
RemoveChatWindowMessages = true
SetChatWindowAlpha = true
SetChatWindowColor = true
SetChatWindowDocked = true
SetChatWindowLocked = true
SetChatWindowName = true
SetChatWindowShown = true
SetChatWindowSize = true
SetChatWindowUninteractable = true
DoEmote = true
GetDefaultLanguage = true
GetLanguageByIndex = true
GetNumLanguages = true
GetRegisteredAddonMessagePrefixes = true
IsAddonMessagePrefixRegistered = true
RegisterAddonMessagePrefix = true
SendAddonMessage = true
SendChatMessage = true
CallCompanion = true
DismissCompanion = true
GetCompanionInfo = true
GetNumCompanions = true
GetCompanionCooldown = true
PickupCompanion = true
SummonRandomCritter = true
ContainerIDToInventoryID = true
GetBagName = true
GetContainerItemCooldown = true
GetContainerItemDurability = true
GetContainerItemGems = true
GetContainerItemID = true
GetContainerItemInfo = true
GetContainerItemLink = true
GetContainerNumSlots = true
GetContainerItemQuestInfo = true
GetContainerNumFreeSlots = true
OpenAllBags = true
CloseAllBags = true
PickupBagFromSlot = true
PickupContainerItem = true
PutItemInBackpack = true
PutItemInBag = true
PutKeyInKeyRing = true
SplitContainerItem = true
ToggleBackpack = true
ToggleBag = true
GetCoinText = true
GetCoinTextureString = true
GetCurrencyInfo = true
GetCurrencyListSize = true
GetCurrencyListInfo = true
ExpandCurrencyList = true
SetCurrencyUnused = true
GetNumWatchedTokens = true
GetBackpackCurrencyInfo = true
SetCurrencyBackpack = true
AutoEquipCursorItem = true
ClearCursor = true
CursorCanGoInSlot = true
CursorHasItem = true
CursorHasMoney = true
CursorHasSpell = true
DeleteCursorItem = true
DropCursorMoney = true
DropItemOnUnit = true
EquipCursorItem = true
GetCursorInfo = true
GetCursorPosition = true
HideRepairCursor = true
InRepairMode = true
PickupAction = true
PickupBagFromSlot = true
PickupContainerItem = true
PickupInventoryItem = true
PickupItem = true
PickupMacro = true
PickupMerchantItem = true
PickupPetAction = true
PickupSpell = true
PickupStablePet = true
PickupTradeMoney = true
PlaceAction = true
PutItemInBackpack = true
PutItemInBag = true
ResetCursor = true
SetCursor = true
ShowContainerSellCursor = true
ShowInspectCursor = true
ShowInventorySellCursor = true
ShowMerchantSellCursor = true
ShowRepairCursor = true
SplitContainerItem = true
GetWeaponEnchantInfo = true
ReplaceEnchant = true
ReplaceTradeEnchant = true
BindEnchant = true
CollapseFactionHeader = true
CollapseAllFactionHeaders = true
ExpandFactionHeader = true
ExpandAllFactionHeaders = true
FactionToggleAtWar = true
GetFactionInfo = true
GetNumFactions = true
GetSelectedFaction = true
GetWatchedFactionInfo = true
IsFactionInactive = true
SetFactionActive = true
SetFactionInactive = true
SetSelectedFaction = true
SetWatchedFactionIndex = true
UnitFactionGroup = true
CreateFrame = true
CreateFont = true
GetFramesRegisteredForEvent = true
GetNumFrames = true
EnumerateFrames = true
GetMouseFocus = true
ToggleDropDownMenu = true
UIFrameFadeIn = true
UIFrameFadeOut = true
UIFrameFlash = true
EasyMenu = true
AddFriend = true
AddOrRemoveFriend = true
GetFriendInfo = true
SetFriendNotes = true
GetNumFriends = true
GetSelectedFriend = true
RemoveFriend = true
SetSelectedFriend = true
ShowFriends = true
ToggleFriendsFrame = true
GetNumGlyphSockets = true
GetGlyphSocketInfo = true
GetGlyphLink = true
GlyphMatchesSocket = true
PlaceGlyphInSocket = true
RemoveGlyphFromSocket = true
SpellCanTargetGlyph = true
CanComplainChat = true
CanComplainInboxItem = true
ComplainChat = true
ComplainInboxItem = true
CloseGossip = true
ForceGossip = true
GetGossipActiveQuests = true
GetGossipAvailableQuests = true
GetGossipOptions = true
GetGossipText = true
GetNumGossipActiveQuests = true
GetNumGossipAvailableQuests = true
GetNumGossipOptions = true
SelectGossipActiveQuest = true
SelectGossipAvailableQuest = true
SelectGossipOption = true
AcceptGroup = true
ConfirmReadyCheck = true
ConvertToRaid = true
DeclineGroup = true
DoReadyCheck = true
GetLootMethod = true
GetLootThreshold = true
GetMasterLootCandidate = true
GetNumPartyMembers = true
GetRealNumPartyMembers = true
GetPartyLeaderIndex = true
GetPartyMember = true
InviteUnit = true
IsPartyLeader = true
LeaveParty = true
PromoteToLeader = true
SetLootMethod = true
SetLootThreshold = true
UninviteUnit = true
UnitInParty = true
UnitIsPartyLeader = true
AcceptGuild = true
BuyGuildCharter = true
CanEditGuildEvent = true
CanEditGuildInfo = true
CanEditMOTD = true
CanEditOfficerNote = true
CanEditPublicNote = true
CanGuildDemote = true
CanGuildInvite = true
CanGuildPromote = true
CanGuildRemove = true
CanViewOfficerNote = true
CloseGuildRegistrar = true
CloseGuildRoster = true
CloseTabardCreation = true
DeclineGuild = true
GetGuildCharterCost = true
GetGuildEventInfo = true
GetGuildInfo = true
GetGuildInfoText = true
GetGuildRosterInfo = true
GetGuildRosterLastOnline = true
GetGuildRosterMOTD = true
GetGuildRosterSelection = true
GetGuildRosterShowOffline = true
GetNumGuildEvents = true
GetNumGuildMembers = true
GetTabardCreationCost = true
GetTabardInfo = true
GuildControlAddRank = true
GuildControlDelRank = true
GuildControlGetNumRanks = true
GuildControlGetRankFlags = true
GuildControlGetRankName = true
GuildControlSaveRank = true
GuildControlSetRank = true
GuildControlSetRankFlag = true
GuildDemote = true
GuildDisband = true
GuildInfo = true
GuildInvite = true
GuildLeave = true
GuildPromote = true
GuildRoster = true
GuildRosterSetOfficerNote = true
GuildRosterSetPublicNote = true
GuildSetMOTD = true
GuildSetLeader = true
GuildUninvite = true
IsGuildLeader = true
IsInGuild = true
QueryGuildEventLog = true
SetGuildInfoText = true
SetGuildRosterSelection = true
SetGuildRosterShowOffline = true
SortGuildRoster = true
UnitGetGuildXP = true
AutoStoreGuildBankItem = true
BuyGuildBankTab = true
CanGuildBankRepair = true
CanWithdrawGuildBankMoney = true
CloseGuildBankFrame = true
DepositGuildBankMoney = true
GetCurrentGuildBankTab = true
GetGuildBankItemInfo = true
GetGuildBankItemLink = true
GetGuildBankMoney = true
GetGuildBankMoneyTransaction = true
GetGuildBankTabCost = true
GetGuildBankTabInfo = true
GetGuildBankTabPermissions = true
GetGuildBankText = true
GetGuildBankTransaction = true
GetGuildTabardFileNames = true
GetNumGuildBankMoneyTransactions = true
GetNumGuildBankTabs = true
GetNumGuildBankTransactions = true
PickupGuildBankItem = true
PickupGuildBankMoney = true
QueryGuildBankLog = true
QueryGuildBankTab = true
SetCurrentGuildBankTab = true
SetGuildBankTabInfo = true
SetGuildBankTabPermissions = true
SplitGuildBankItem = true
WithdrawGuildBankMoney = true
GetHolidayBGHonorCurrencyBonuses = true
GetInspectHonorData = true
GetPVPLifetimeStats = true
GetPVPRankInfo = true
GetPVPRankProgress = true
GetPVPSessionStats = true
GetPVPYesterdayStats = true
GetRandomBGHonorCurrencyBonuses = true
HasInspectHonorData = true
RequestInspectHonorData = true
UnitPVPName = true
UnitPVPRank = true
AddIgnore = true
AddOrDelIgnore = true
DelIgnore = true
GetIgnoreName = true
GetNumIgnores = true
GetSelectedIgnore = true
SetSelectedIgnore = true
CanInspect = true
CheckInteractDistance = true
ClearInspectPlayer = true
GetInspectArenaTeamData = true
HasInspectHonorData = true
RequestInspectHonorData = true
GetInspectHonorData = true
NotifyInspect = true
InspectUnit = true
CanShowResetInstances = true
GetBattlefieldInstanceExpiration = true
GetBattlefieldInstanceInfo = true
GetBattlefieldInstanceRunTime = true
GetInstanceBootTimeRemaining = true
GetInstanceInfo = true
GetNumSavedInstances = true
GetSavedInstanceInfo = true
IsInInstance = true
ResetInstances = true
GetDungeonDifficulty = true
SetDungeonDifficulty = true
GetInstanceDifficulty = true
GetInstanceLockTimeRemaining = true
GetInstanceLockTimeRemainingEncounter = true
AutoEquipCursorItem = true
BankButtonIDToInvSlotID = true
CancelPendingEquip = true
ConfirmBindOnUse = true
ContainerIDToInventoryID = true
CursorCanGoInSlot = true
EquipCursorItem = true
EquipPendingItem = true
GetInventoryAlertStatus = true
GetInventoryItemBroken = true
GetInventoryItemCooldown = true
GetInventoryItemCount = true
GetInventoryItemDurability = true
GetInventoryItemGems = true
GetInventoryItemID = true
GetInventoryItemLink = true
GetInventoryItemQuality = true
GetInventoryItemTexture = true
GetInventorySlotInfo = true
GetWeaponEnchantInfo = true
HasWandEquipped = true
IsInventoryItemLocked = true
KeyRingButtonIDToInvSlotID = true
PickupBagFromSlot = true
PickupInventoryItem = true
UpdateInventoryAlertStatus = true
UseInventoryItem = true
EquipItemByName = true
GetAuctionItemLink = true
GetContainerItemLink = true
GetItemCooldown = true
GetItemCount = true
GetItemFamily = true
GetItemIcon = true
GetItemInfo = true
GetItemQualityColor = true
GetItemSpell = true
GetItemStats = true
GetMerchantItemLink = true
GetQuestItemLink = true
GetQuestLogItemLink = true
GetTradePlayerItemLink = true
GetTradeSkillItemLink = true
GetTradeSkillReagentItemLink = true
GetTradeTargetItemLink = true
IsUsableItem = true
IsConsumableItem = true
IsCurrentItem = true
IsEquippedItem = true
IsEquippableItem = true
IsEquippedItemType = true
IsItemInRange = true
ItemHasRange = true
OffhandHasWeapon = true
SplitContainerItem = true
SetItemRef = true
AcceptSockets = true
ClickSocketButton = true
CloseSocketInfo = true
GetSocketItemInfo = true
GetSocketItemRefundable = true
GetSocketItemBoundTradeable = true
GetNumSockets = true
GetSocketTypes = true
GetExistingSocketInfo = true
GetExistingSocketLink = true
GetNewSocketInfo = true
GetNewSocketLink = true
SocketInventoryItem = true
SocketContainerItem = true
CloseItemText = true
ItemTextGetCreator = true
ItemTextGetItem = true
ItemTextGetMaterial = true
ItemTextGetPage = true
ItemTextGetText = true
ItemTextHasNextPage = true
ItemTextNextPage = true
ItemTextPrevPage = true
GetMinimapZoneText = true
GetRealZoneText = true
GetSubZoneText = true
GetZonePVPInfo = true
GetZoneText = true
CompleteLFGRoleCheck = true
GetLFGDeserterExpiration = true
GetLFGRandomCooldownExpiration = true
GetLFGBootProposal = true
GetLFGMode = true
GetLFGQueueStats = true
GetLFGRoles = true
GetLFGRoleUpdate = true
GetLFGRoleUpdateSlot = true
SetLFGBootVote = true
SetLFGComment = true
SetLFGRoles = true
UninviteUnit = true
UnitGroupRolesAssigned = true
UnitHasLFGDeserter = true
UnitHasLFGRandomCooldown = true
CloseLoot = true
ConfirmBindOnUse = true
ConfirmLootRoll = true
ConfirmLootSlot = true
GetLootMethod = true
GetLootRollItemInfo = true
GetLootRollItemLink = true
GetLootRollTimeLeft = true
GetLootSlotInfo = true
GetLootSlotLink = true
GetLootThreshold = true
GetMasterLootCandidate = true
GetNumLootItems = true
GetOptOutOfLoot = true
GiveMasterLoot = true
IsFishingLoot = true
LootSlot = true
LootSlotIsCoin = true
LootSlotIsCurrency = true
LootSlotIsItem = true
RollOnLoot = true
SetLootMethod = true
SetLootPortrait = true
SetLootThreshold = true
SetOptOutOfLoot = true
CursorHasMacro = true
DeleteMacro = true
GetMacroBody = true
GetMacroIconInfo = true
GetMacroItemIconInfo = true
GetMacroIndexByName = true
GetMacroInfo = true
GetNumMacroIcons = true
GetNumMacroItemIcons = true
GetNumMacros = true
PickupMacro = true
RunMacro = true
RunMacroText = true
SecureCmdOptionParse = true
StopMacro = true
AutoLootMailItem = true
CheckInbox = true
ClearSendMail = true
ClickSendMailItemButton = true
CloseMail = true
DeleteInboxItem = true
GetCoinIcon = true
GetInboxHeaderInfo = true
GetInboxItem = true
GetInboxItemLink = true
GetInboxNumItems = true
GetInboxText = true
GetInboxInvoiceInfo = true
GetNumPackages = true
GetNumStationeries = true
GetPackageInfo = true
GetSelectedStationeryTexture = true
GetSendMailCOD = true
GetSendMailItem = true
GetSendMailItemLink = true
GetSendMailMoney = true
GetSendMailPrice = true
GetStationeryInfo = true
HasNewMail = true
InboxItemCanDelete = true
ReturnInboxItem = true
SelectPackage = true
SelectStationery = true
SendMail = true
SetSendMailCOD = true
SetSendMailMoney = true
TakeInboxItem = true
TakeInboxMoney = true
TakeInboxTextItem = true
ClickLandmark = true
GetCorpseMapPosition = true
GetCurrentMapContinent = true
GetCurrentMapDungeonLevel = true
GetNumDungeonMapLevels = true
GetCurrentMapAreaID = true
GetCurrentMapZone = true
GetMapContinents = true
GetMapDebugObjectInfo = true
GetMapInfo = true
GetMapLandmarkInfo = true
GetMapOverlayInfo = true
GetMapZones = true
GetNumMapDebugObjects = true
GetNumMapLandmarks = true
GetNumMapOverlays = true
GetPlayerMapPosition = true
ProcessMapClick = true
RequestBattlefieldPositions = true
SetDungeonMapLevel = true
SetMapByID = true
SetMapToCurrentZone = true
SetMapZoom = true
SetupFullscreenScale = true
UpdateMapHighlight = true
CreateWorldMapArrowFrame = true
UpdateWorldMapArrowFrames = true
ShowWorldMapArrowFrame = true
PositionWorldMapArrowFrame = true
ZoomOut = true
BuyMerchantItem = true
BuybackItem = true
CanMerchantRepair = true
CloseMerchant = true
GetBuybackItemInfo = true
GetBuybackItemLink = true
GetMerchantItemCostInfo = true
GetMerchantItemCostItem = true
GetMerchantItemInfo = true
GetMerchantItemLink = true
GetMerchantItemMaxStack = true
GetMerchantNumItems = true
GetRepairAllCost = true
HideRepairCursor = true
InRepairMode = true
PickupMerchantItem = true
RepairAllItems = true
ShowMerchantSellCursor = true
ShowRepairCursor = true
GetNumBuybackItems = true
CastPetAction = true
ClosePetStables = true
DropItemOnUnit = true
GetPetActionCooldown = true
GetPetActionInfo = true
GetPetActionSlotUsable = true
GetPetActionsUsable = true
GetPetExperience = true
GetPetFoodTypes = true
GetPetHappiness = true
GetPetIcon = true
GetPetTimeRemaining = true
GetStablePetFoodTypes = true
GetStablePetInfo = true
HasPetSpells = true
HasPetUI = true
PetAbandon = true
PetAggressiveMode = true
PetAttack = true
IsPetAttackActive = true
PetStopAttack = true
PetCanBeAbandoned = true
PetCanBeDismissed = true
PetCanBeRenamed = true
PetDefensiveMode = true
PetDismiss = true
PetFollow = true
PetHasActionBar = true
PetPassiveMode = true
PetRename = true
PetWait = true
PickupPetAction = true
PickupStablePet = true
SetPetStablePaperdoll = true
TogglePetAutocast = true
ToggleSpellAutocast = true
GetSpellAutocast = true
AddQuestWatch = true
GetActiveLevel = true
GetActiveTitle = true
GetAvailableLevel = true
GetAvailableTitle = true
GetAvailableQuestInfo = true
GetGreetingText = true
GetNumQuestLeaderBoards = true
GetNumQuestWatches = true
GetObjectiveText = true
GetProgressText = true
GetQuestGreenRange = true
GetQuestIndexForWatch = true
GetQuestLink = true
GetQuestLogGroupNum = true
GetQuestLogLeaderBoard = true
GetQuestLogTitle = true
GetQuestReward = true
GetRewardArenaPoints = true
GetRewardHonor = true
GetRewardMoney = true
GetRewardSpell = true
GetRewardTalents = true
GetRewardText = true
GetRewardTitle = true
GetRewardXP = true
IsQuestWatched = true
IsUnitOnQuest = true
QuestFlagsPVP = true
QuestGetAutoAccept = true
RemoveQuestWatch = true
ShiftQuestWatches = true
SortQuestWatches = true
QueryQuestsCompleted = true
GetQuestsCompleted = true
QuestIsDaily = true
QuestIsWeekly = true
ClearRaidMarker = true
ConvertToRaid = true
ConvertToParty = true
DemoteAssistant = true
GetAllowLowLevelRaid = true
GetNumRaidMembers = true
GetRealNumRaidMembers = true
GetPartyAssignment = true
GetPartyAssignment = true
GetRaidRosterInfo = true
GetRaidTargetIndex = true
GetReadyCheckStatus = true
InitiateRolePoll = true
IsRaidLeader = true
IsRaidOfficer = true
PlaceRaidMarker = true
PromoteToAssistant = true
RequestRaidInfo = true
SetPartyAssignment = true
SetAllowLowLevelRaid = true
SetRaidRosterSelection = true
SetRaidSubgroup = true
SwapRaidSubgroup = true
SetRaidTarget = true
UnitInRaid = true
LFGGetDungeonInfoByID = true
GetInstanceLockTimeRemainingEncounter = true
RefreshLFGList = true
SearchLFGGetEncounterResults = true
SearchLFGGetJoinedID = true
SearchLFGGetNumResults = true
SearchLFGGetPartyResults = true
SearchLFGGetResults = true
SearchLFGJoin = true
SearchLFGLeave = true
SearchLFGSort = true
SetLFGComment = true
ClearAllLFGDungeons = true
JoinLFG = true
LeaveLFG = true
RequestLFDPartyLockInfo = true
RequestLFDPlayerLockInfo = true
SetLFGDungeon = true
SetLFGDungeonEnabled = true
SetLFGHeaderCollapsed = true
GetAddOnCPUUsage = true
GetAddOnMemoryUsage = true
GetEventCPUUsage = true
GetFrameCPUUsage = true
GetFunctionCPUUsage = true
GetScriptCPUUsage = true
ResetCPUUsage = true
UpdateAddOnCPUUsage = true
UpdateAddOnMemoryUsage = true
issecure = true
forceinsecure = true
issecurevariable = true
securecall = true
hooksecurefunc = true
InCombatLockdown = true
CombatTextSetActiveUnit = true
DownloadSettings = true
GetCVar = true
GetCVarDefault = true
GetCVarBool = true
GetCVarInfo = true
GetCurrentMultisampleFormat = true
GetCurrentResolution = true
GetGamma = true
GetMultisampleFormats = true
GetRefreshRates = true
GetScreenResolutions = true
GetVideoCaps = true
IsThreatWarningEnabled = true
RegisterCVar = true
ResetPerformanceValues = true
ResetTutorials = true
SetCVar = true
SetEuropeanNumbers = true
SetGamma = true
SetLayoutMode = true
SetMultisampleFormat = true
SetScreenResolution = true
ShowCloak = true
ShowHelm = true
ShowNumericThreat = true
ShowingCloak = true
ShowingHelm = true
UploadSettings = true
AbandonSkill = true
CastShapeshiftForm = true
CastSpell = true
CastSpellByName = true
GetMultiCastTotemSpells = true
GetNumShapeshiftForms = true
GetNumSpellTabs = true
GetShapeshiftForm = true
GetShapeshiftFormCooldown = true
GetShapeshiftFormInfo = true
GetSpellAutocast = true
GetSpellBookItemInfo = true
GetSpellBookItemName = true
GetSpellCooldown = true
GetSpellDescription = true
GetSpellInfo = true
GetSpellLink = true
GetSpellTabInfo = true
GetSpellTexture = true
GetTotemInfo = true
IsAttackSpell = true
IsAutoRepeatSpell = true
IsPassiveSpell = true
IsSpellInRange = true
IsUsableSpell = true
PickupSpell = true
QueryCastSequence = true
SetMultiCastSpell = true
SpellCanTargetUnit = true
SpellHasRange = true
SpellIsTargeting = true
SpellStopCasting = true
SpellStopTargeting = true
SpellTargetUnit = true
ToggleSpellAutocast = true
UnitCastingInfo = true
UnitChannelInfo = true
ConsoleExec = true
DetectWowMouse = true
GetBuildInfo = true
geterrorhandler = true
GetCurrentKeyBoardFocus = true
GetExistingLocales = true
GetFramerate = true
GetGameTime = true
GetLocale = true
GetCursorPosition = true
GetNetStats = true
GetRealmName = true
GetScreenHeight = true
GetScreenWidth = true
GetText = true
GetTime = true
IsAltKeyDown = true
InCinematic = true
IsControlKeyDown = true
IsDebugBuild = true
IsDesaturateSupported = true
IsLeftAltKeyDown = true
IsLeftControlKeyDown = true
IsLeftShiftKeyDown = true
IsLinuxClient = true
IsLoggedIn = true
IsMacClient = true
IsRightAltKeyDown = true
IsRightControlKeyDown = true
IsRightShiftKeyDown = true
IsShiftKeyDown = true
IsStereoVideoAvailable = true
IsWindowsClient = true
OpeningCinematic = true
PlayMusic = true
PlaySound = true
PlaySoundFile = true
ReloadUI = true
RepopMe = true
RequestTimePlayed = true
RestartGx = true
RunScript = true
Screenshot = true
SetAutoDeclineGuildInvites = true
seterrorhandler = true
StopCinematic = true
StopMusic = true
UIParentLoadAddOn = true
TakeScreenshot = true
BuyTrainerService = true
CheckTalentMasterDist = true
ConfirmTalentWipe = true
GetActiveTalentGroup = true
GetNumTalentTabs = true
GetNumTalents = true
GetTalentInfo = true
GetTalentLink = true
GetTalentPrereqs = true
GetTalentTabInfo = true
LearnTalent = true
SetActiveTalentGroup = true
GetNumTalentGroups = true
GetActiveTalentGroup = true
AddPreviewTalentPoints = true
GetGroupPreviewTalentPointsSpent = true
GetPreviewTalentPointsSpent = true
GetUnspentTalentPoints = true
LearnPreviewTalents = true
ResetGroupPreviewTalentPoints = true
ResetPreviewTalentPoints = true
AssistUnit = true
AttackTarget = true
ClearTarget = true
ClickTargetTradeButton = true
TargetLastEnemy = true
TargetLastTarget = true
TargetNearestEnemy = true
TargetNearestEnemyPlayer = true
TargetNearestFriend = true
TargetNearestFriendPlayer = true
TargetNearestPartyMember = true
TargetNearestRaidMember = true
TargetUnit = true
ToggleBackpack = true
ToggleBag = true
ToggleCharacter = true
ToggleFriendsFrame = true
ToggleSpellBook = true
TradeSkill = true
CloseTradeSkill = true
CollapseTradeSkillSubClass = true
PickupPlayerMoney = true
PickupTradeMoney = true
SetTradeMoney = true
ReplaceTradeEnchant = true
AssistUnit = true
CheckInteractDistance = true
DropItemOnUnit = true
FollowUnit = true
FocusUnit = true
ClearFocus = true
GetUnitName = true
GetUnitPitch = true
GetUnitSpeed = true
InviteUnit = true
IsUnitOnQuest = true
SpellCanTargetUnit = true
SpellTargetUnit = true
TargetUnit = true
UnitAffectingCombat = true
UnitArmor = true
UnitAttackBothHands = true
UnitAttackPower = true
UnitAttackSpeed = true
UnitAura = true
UnitBuff = true
UnitCanAssist = true
UnitCanAttack = true
UnitCanCooperate = true
UnitClass = true
UnitClassification = true
UnitCreatureFamily = true
UnitCreatureType = true
UnitDamage = true
UnitDebuff = true
UnitDefense = true
UnitDetailedThreatSituation = true
UnitExists = true
UnitFactionGroup = true
UnitGroupRolesAssigned = true
UnitGUID = true
GetPlayerInfoByGUID = true
UnitHasLFGDeserter = true
UnitHasLFGRandomCooldown = true
UnitHasRelicSlot = true
UnitHealth = true
UnitHealthMax = true
UnitInParty = true
UnitInRaid = true
UnitInBattleground = true
UnitIsInMyGuild = true
UnitInRange = true
UnitIsAFK = true
UnitIsCharmed = true
UnitIsConnected = true
UnitIsCorpse = true
UnitIsDead = true
UnitIsDeadOrGhost = true
UnitIsDND = true
UnitIsEnemy = true
UnitIsFeignDeath = true
UnitIsFriend = true
UnitIsGhost = true
UnitIsPVP = true
UnitIsPVPFreeForAll = true
UnitIsPVPSanctuary = true
UnitIsPartyLeader = true
UnitIsPlayer = true
UnitIsPossessed = true
UnitIsRaidOfficer = true
UnitIsSameServer = true
UnitIsTapped = true
UnitIsTappedByPlayer = true
UnitIsTappedByAllThreatList = true
UnitIsTrivial = true
UnitIsUnit = true
UnitIsVisible = true
UnitLevel = true
UnitMana = true
UnitManaMax = true
UnitName = true
UnitOnTaxi = true
UnitPlayerControlled = true
UnitPlayerOrPetInParty = true
UnitPlayerOrPetInRaid = true
UnitPVPName = true
UnitPVPRank = true
UnitPower = true
UnitPowerMax = true
UnitPowerType = true
UnitRace = true
UnitRangedAttack = true
UnitRangedAttackPower = true
UnitRangedDamage = true
UnitReaction = true
UnitResistance = true
UnitSelectionColor = true
UnitSex = true
UnitStat = true
UnitThreatSituation = true
UnitUsingVehicle = true
GetThreatStatusColor = true
UnitXP = true
UnitXPMax = true
SetPortraitTexture = true
SetPortraitToTexture = true
tinsert = true