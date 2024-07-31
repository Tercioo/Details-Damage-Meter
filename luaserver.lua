---Contents for the blizzard_documentation field "Arguments".
---@class blizzard_documentation_arguments : table
---@field Name string the name of the argument
---@field Type string the type of the argument: if is not a primitive type, just use the type name as string
---@field Nilable boolean whether the argument can be nil
---@field Mixin string? the mixin of the argument

---Contents for the blizzard_documentation field "Returns".
---@class blizzard_documentation_returns : table
---@field Name string the name of the return
---@field Type string the type of the return: if is not a primitive type, just use the type name as string
---@field Nilable boolean whether the return can be nil

---This table contains documentation for functions inside C_ChallengeMode.
---@class blizzard_documentation : table
---@field Name string the name of the field, can be
---@field Type string most of the time the type is "Function"
---@field Arguments blizzard_documentation_arguments[]? a table containing the arguments of the function
---@field Returns blizzard_documentation_returns[]? a table containing the returns of the function, the the type is table, it may have "InnerType" which is the type of the elements inside the table

---@class LibStub : table
LibStub = {}
function LibStub:NewLibrary(major, minor)end
function LibStub:GetLibrary(major, silent)end
function LibStub:IterateLibraries()end

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

--escape sequences: are used to represent characters that are not printable, such as new lines, tabs, and other control characters.
--in wow they are used to add colors, textures, and other special characters to a string.
--they always start with a pipe character (|) followed by a letter, and can have a value after the letter, and end with a pipe character (|) followed by another leter.
--color: myTextWithColor = "|cFF00FF00This is a green text|r". |c open the color, FF00FF00 is the color, |r close the color. Color is represented by the hexadecimal value of the color, the first two characters are the alpha, the next two are the red, the next two are the green, and the last two are the blue.
--texture: open with |T and close with |t, the first value is the texture, second and third height and width, offsetX and offsetY, textureWidth and textureHeight, texture coordinates in pixels for leftCoord, rightCoord, topCoord, and bottomCoord, the last three values are: redVertexColor, greenVertexColor, and blueVertexColor in 0 to 255.
--texture: myTextWithTexture = "|TInterface\\Icons\\INV_Misc_QuestionMark:0|tThis is a text with a question mark texture"
--texture: myTextWithTexture = "|TInterface\\Icons\\INV_Misc_QuestionMark:32:32:1:-1:64:64:4:60:4:60:0:0:255|tThis is a text with a question mark texture of size 32x32, with cropped to remove the border of the icon and with a blue color"
--atlas: open with |A and close with |a, the first value is the atlas, second and third height and width, offsetX and offsetY, and redVertexColor, greenVertexColor, and blueVertexColor in 0 to 255.

---@alias animationtype
---| "Alpha"
---| "Rotation"
---| "Scale"
---| "Translation"
---| "Path"
---| "VertexColor"


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
---| "MONOCHROME"
---| "OUTLINE"
---| "THICKOUTLINE"
---| "OUTLINEMONOCHROME"
---| "THICKOUTLINEMONOCHROME"
---| "none"
---| "monochrome"
---| "outline"
---| "thickoutline"
---| "outlinemonochrome"
---| "thickoutlinemonochrome"

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

---@alias animloopmode
---| "NONE"
---| "REPEAT"
---| "BOUNCE"

---@alias animsmoothing
---| "IN"
---| "OUT"
---| "IN_OUT"
---| "NONE"

---@alias aurafilter : table
---| "HELPFUL"
---| "HARMFUL"
---| "PLAYER"
---| "RAID"
---| "CANCELABLE"
---| "NOT_CANCELABLE"
---| "INCLUDE_NAME_PLATE_ONLY"
---| "MAW"

---@class spellinfo : table
---@field name string
---@field iconID number
---@field castTime number
---@field mimRange number
---@field maxRange number
---@field spellID number
---@field originalIconID number

---@class spellchargeinfo
---@field currentCharges number
---@field maxCharges number
---@field cooldownStartTime number
---@field cooldownDuration number
---@field chargeModRate number

---@class privateaura_anchor : table
---@field unitToken unit
---@field auraIndex number
---@field parent frame
---@field showCountdownFrame boolean
---@field showCountdownNumbers boolean
---@field iconInfo privateaura_iconinfo?
---@field durationAnchor privateaura_anchorbinding?

---@class privateaura_iconinfo : table
---@field iconAnchor privateaura_anchorbinding
---@field iconWidth number
---@field iconHeight number

---@class privateaura_anchorbinding : table
---@field point anchorpoint
---@field relativeTo uiobject
---@field relativePoint anchorpoint
---@field offsetX number
---@field offsetY number

---@class privateaura_appliedsoundinfo : table
---@field unitToken unit
---@field spellID spellid
---@field soundFileName string? 	
---@field soundFileID number? 	
---@field outputChannel audiochannels?

---@class privateaura_soundid : number

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

---@class atlasinfo : table
---@field filename any?
---@field file any?
---@field leftTexCoord number?
---@field rightTexCoord number?
---@field topTexCoord number?
---@field bottomTexCoord number?
---@field width number?
---@field height number?
---@field tilesHorizontally boolean?
---@field tilesVertically boolean?


---@alias width number property that represents the horizontal size of a UI element, such as a frame or a texture. Gotten from the first result of GetWidth() or from the first result of GetSize(). It is expected a GetWidth() or GetSize() when the type 'height' is used.
---@alias height number property that represents the vertical size of a UI element, such as a frame or a texture. Gotten from the first result of GetHeight() or from the second result of GetSize(). It is expected a GetHeight() or GetSize() when the type 'height' is used.
---@alias framelevel number represent how high a frame is placed within its strata. The higher the frame level, the more likely it is to appear in front of other frames. The frame level is a number between 0 and 65535. The default frame level is 0. The frame level is set with the SetFrameLevel() function.
---@alias red number color value representing the red component of a color, the value must be between 0 and 1. To retrieve a color from a string or table use: local red, green, blue, alpha = DetailsFramework:ParseColors(color)
---@alias green number color value representing the green component of a color, the value must be between 0 and 1. To retrieve a color from a string or table use: local red, green, blue, alpha = DetailsFramework:ParseColors(color)
---@alias blue number color value representing the blue component of a color, the value must be between 0 and 1. To retrieve a color from a string or table use: local red, green, blue, alpha = DetailsFramework:ParseColors(color)
---@alias alpha number @number(0-1.0) value representing the alpha (transparency) of a UIObject, the value must be between 0 and 1. 0 is fully transparent, 1 is fully opaque.
---@alias unit string string that represents a unit in the game, such as the player, a party member, or a raid member.
---@alias health number amount of hit points (health) of a unit. This value can be changed by taking damage or healing.
---@alias healthmax number max amount of hit points (health) of a unit.
---@alias encounterid number encounter ID number received by the event ENCOUNTER_START and ENCOUNTER_END
---@alias encounterejid number encounter ID number used by the encounter journal
---@alias encountername string encounter name received by the event ENCOUNTER_START and ENCOUNTER_END also used by the encounter journal
---@alias encounterdifficulty number difficulty of the encounter received by the event ENCOUNTER_START and ENCOUNTER_END
---@alias instancename string localized name of an instance (e.g. "The Nighthold")
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
---@alias guildname string name of the guild
---@alias date string date in the format "YYYY-MM-DD"
---@alias keylevel number the level of a mythic dungeon key
---@alias mapid number each map in the game has a unique map id, this id can be used to identify a map.
---@alias challengemapid number each challenge mode map in the game has a unique map id, this id can be used to identify a challenge mode map.
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
---@alias servertime number unixtime on the server
---@alias auraduration number
---@alias gametime number number of seconds that have elapsed since the start of the game session.
---@alias milliseconds number a number in milliseconds, usually need to divide by 1000 to get the seconds.
---@alias coordleft number
---@alias coordright number
---@alias coordtop number
---@alias coordbottom number
---@alias addonname string name of an addon, same as the name of the ToC file.
---@alias profile table a table containing the settings of an addon, usually saved in the SavedVariables file.
---@alias profilename string name of a profile.
---@alias anchorid number a number that represents an anchor point, such as topleft, topright, bottomleft, bottomright, top, bottom, left, right, center.

---@class _G
---@field RegisterAttributeDriver fun(statedriver: frame, attribute: string, conditional: string)
---@field RegisterStateDriver fun(statedriver: frame, attribute: string, conditional: string)
---@field UnitGUID fun(unit: string): string
---@field UnitName fun(unit: string): string
---@field GetCursorPosition fun(): number, number return the position of the cursor on the screen, in pixels, relative to the bottom left corner of the screen.
---@field C_Timer C_Timer

---table containing backdrop functions
BackdropTemplateMixin = {}

---@class timer : table
---@field Cancel fun(self: timer)
---@field IsCancelled fun(self: timer): boolean

---@class C_Timer : table
---@field After fun(delay: number, func: function)
---@field NewTimer fun(delay: number, func: function): timer
---@field NewTicker fun(interval: number, func: function, iterations: number|nil): timer

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
---@field SetIgnoreParentAlpha fun(self: region, ignore: boolean)

---@class animationgroup : uiobject
---@field CreateAnimation fun(self: animationgroup, animationType: animationtype, name: string|nil, inheritsFrom: string|nil) : animation
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
---@field SetLooping fun(self: animationgroup, loop: animloopmode)
---@field SetScript fun(self: animationgroup, event: string, handler: function|nil) "OnEvent"|"OnShow"
---@field SetSmoothProgress fun(self: animationgroup, smooth: animsmoothing)
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
---@field SetStartDelay fun(self: animation, delay: number)
---@field SetEndDelay fun(self: animation, delay: number)
---@field SetOrder fun(self: animation, order: number)
---@field SetScript fun(self: animation, event: string, handler: function?)
---@field SetSmoothing fun(self: animation, smoothing: string)
---@field Stop fun(self: animation)
---@field CreateControlPoint fun(self: animation) : pathcontrolpoint
---@field SetCurveType fun(self: animation, curveType:pathanimationtype)
---@field GetCurveType fun(self: animation) : pathanimationtype
---@field GetControlPoints fun(self: animation) : pathcontrolpoint[]
---@field GetMaxControlPointOrder fun(self: animation) : number
---@field SetFromAlpha fun(self: animation, alpha: number)
---@field SetToAlpha fun(self: animation, alpha: number)
---@field SetScaleFrom fun(self: animation, x: number, y: number)
---@field SetScaleTo fun(self: animation, x: number, y: number)
---@field SetFromScale fun(self: animation, x: number, y: number)
---@field SetToScale fun(self: animation, x: number, y: number)
---@field SetOrigin fun(self: animation, point: anchorpoint, x: number, y: number)
---@field SetDegrees fun(self: animation, degrees: number)
---@field SetOffset fun(self: animation, x: number, y: number)
---@field SetStartColor fun(self: animation, r: red|number, g: green|number, b: blue|number, a: alpha|number|nil)
---@field SetEndColor fun(self: animation, r: red|number, g: green|number, b: blue|number, a: alpha|number|nil)

---@alias pathanimationtype
---| "LINEAR"
---| "SMOOTH"

---@class pathcontrolpoint : animation
---@field SetOffset fun(self: pathcontrolpoint, offsetX: number, offsetY: number)
---@field GetOffset fun(self: pathcontrolpoint) : number, number
---@field SetOrder fun(self: pathcontrolpoint, order: number)
---@field GetOrder fun(self: pathcontrolpoint) : number
---@field SetParent fun(self: pathcontrolpoint, parent: uiobject, order: number?)


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
---@field AddMaskTexture fun(self: texture, maskTexture: texture)
---@field SetDrawLayer fun(self: texture, layer: drawlayer, subLayer: number?)
---@field GetTexture fun(self: texture) : any
---@field SetTexture fun(self: texture, path: textureid|texturepath, horizontalWrap: texturewrap?, verticalWrap: texturewrap?, filter: texturefilter?)
---@field SetAtlas fun(self: texture, atlas: string, useAtlasSize: boolean?, filterMode: texturefilter?, resetTexCoords: boolean?)
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
---@field SetHorizTile fun(self: texture, tile: boolean) set the texture to be tiled horizontally
---@field SetVertTile fun(self: texture, tile: boolean) set the texture to be tiled vertically

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

---@class slider : statusbar
---@field Enable fun(self: slider)
---@field Disable fun(self: slider)
---@field SetEnabled fun(self: slider, enable: boolean)
---@field IsEnabled fun(self: slider) : boolean
---@field GetObeyStepOnDrag fun(self: slider) : boolean
---@field GetStepsPerPage fun(self: slider) : number
---@field GetThumbTexture fun(self: slider) : texture
---@field IsDraggingThumb fun(self: slider) : boolean
---@field SetObeyStepOnDrag fun(self: slider, obeyStep: boolean)
---@field SetThumbTexture fun(self: slider, texture: textureid|texturepath)
---@field SetStepsPerPage fun(self: slider, steps: number)

---@return number
function debugprofilestop() return 0 end

INVSLOT_FIRST_EQUIPPED = true
INVSLOT_LAST_EQUIPPED = true
LE_PARTY_CATEGORY_INSTANCE = true

--functions
C_ChatInfo = true

C_Item = {}
function C_Item.PickupItem() end
function C_Item.IsBoundToAccountUntilEquip() end
function C_Item.LockItem() end
function C_Item.DoesItemMatchTargetEnchantingSpell() end
function C_Item.IsItemCorruptionRelated() end

---return the item's icon texture
---@param itemInfo number|string
---@return number
function C_Item.GetItemIconByID(itemInfo) return 0 end

---return the item's icon texture
---@param itemLocation table
---@return number
function C_Item.GetItemIcon(itemLocation) return 0 end

function C_Item.ConfirmOnUse() end
function C_Item.GetItemIDForItemInfo() end
function C_Item.IsCorruptedItem() end
function C_Item.GetBaseItemTransmogInfo() end
function C_Item.GetItemMaxStackSize() end
function C_Item.ConfirmNoRefundOnUse() end
function C_Item.GetFirstTriggeredSpellForItem() end
function C_Item.GetItemInventorySlotInfo() end
function C_Item.GetItemNameByID() end
function C_Item.IsItemCorrupted() end
function C_Item.ActionBindsItem() end
function C_Item.GetCurrentItemTransmogInfo() end
function C_Item.RequestLoadItemDataByID() end
function C_Item.GetItemSetInfo() end
function C_Item.GetItemCreationContext() end
function C_Item.IsEquippedItem() end
function C_Item.IsItemDataCachedByID() end
function C_Item.ItemHasRange() end
function C_Item.ConfirmBindOnUse() end
function C_Item.GetItemSpecInfo() end
function C_Item.EndBoundTradeable() end
function C_Item.EndRefund() end
function C_Item.UseItemByName() end
function C_Item.IsDressableItemByID() end
function C_Item.GetItemGUID() end
function C_Item.GetItemInventoryTypeByID() end
function C_Item.UnlockItem() end
function C_Item.RequestLoadItemData() end
function C_Item.IsItemInRange() end
function C_Item.IsItemConvertibleAndValidForPlayer() end
function C_Item.DoesItemExist() end
function C_Item.EquipItemByName() end
function C_Item.ReplaceTradeEnchant() end
function C_Item.UnlockItemByGUID() end
function C_Item.DoesItemExistByID() end
function C_Item.LockItemByGUID() end
function C_Item.GetItemQualityColor() end
function C_Item.GetItemIDByGUID() end
function C_Item.IsLocked() end
function C_Item.GetItemLocation() end
function C_Item.IsItemSpecificToPlayerClass() end
function C_Item.GetItemNumAddedSockets() end
function C_Item.IsItemKeystoneByID() end
function C_Item.IsConsumableItem() end
function C_Item.GetItemStats() end
function C_Item.IsCurioItem() end
function C_Item.GetItemStatDelta() end
function C_Item.IsItemDataCached() end
function C_Item.IsItemConduit() end
function C_Item.GetItemNumSockets() end
function C_Item.GetAppliedItemTransmogInfo() end
function C_Item.IsHelpfulItem() end
function C_Item.GetItemClassInfo() end
function C_Item.GetItemUniquenessByID() end
function C_Item.GetItemGemID() end
function C_Item.IsHarmfulItem() end
function C_Item.DropItemOnUnit() end

---@param itemInfo number|string
---@return number actualItemLevel
---@return number previewLevel
---@return number sparseItemLevel
function C_Item.GetDetailedItemLevelInfo(itemInfo) return 0, 0, 0 end

function C_Item.IsEquippedItemType() end
function C_Item.GetItemFamily() end
function C_Item.GetLimitedCurrencyItemInfo() end
function C_Item.GetItemInventorySlotKey() end
function C_Item.IsEquippableItem() end
function C_Item.GetItemConversionOutputIcon() end
function C_Item.ReplaceEnchant() end
function C_Item.GetItemLearnTransmogSet() end
function C_Item.IsCurrentItem() end
function C_Item.IsItemGUIDInInventory() end
function C_Item.GetItemGem() end
function C_Item.IsBound() end
function C_Item.IsCosmeticItem() end
function C_Item.IsArtifactPowerItem() end
function C_Item.IsAnimaItemByID() end
function C_Item.ReplaceTradeskillEnchant() end
function C_Item.GetItemUniqueness() end
function C_Item.GetSetBonusesForSpecializationByItemID() end
function C_Item.GetItemCooldown() end
function C_Item.GetItemSpell() end
function C_Item.GetItemID() end
function C_Item.DoesItemMatchBonusTreeReplacement() end
function C_Item.IsUsableItem() end
function C_Item.GetCurrentItemLevel() end
function C_Item.DoesItemContainSpec() end
function C_Item.CanItemTransmogAppearance() end
function C_Item.GetItemQualityByID() end
function C_Item.GetItemLinkByGUID() end
function C_Item.BindEnchant() end
function C_Item.GetItemQuality() end
function C_Item.IsItemCorruptionResistant() end
function C_Item.CanViewItemPowers() end
function C_Item.GetItemChildInfo() end
function C_Item.GetItemLink() end
function C_Item.CanScrapItem() end

---@return string itemName
---@return string itemLink
---@return number itemQuality
---@return number itemLevel
---@return number itemMinLevel
---@return string itemType
---@return string itemSubType
---@return number itemStackCount
---@return string itemEquipLoc
---@return number itemTexture
---@return number sellPrice
---@return number classID
---@return number subclassID
---@return number bindType
---@return number expansionID
---@return number setID
---@return boolean isCraftingReagent
function C_Item.GetItemInfo() return "", "", 0, 0, 0, "", "", 0, "", 0, 0, 0, 0, 0, 0, 0, true end

function C_Item.GetItemName() end
function C_Item.GetItemSubClassInfo() end
function C_Item.GetItemInventoryType() end
function C_Item.GetItemMaxStackSizeByID() end
function C_Item.DoesItemMatchTrackJump() end
function C_Item.GetItemCount() end
function C_Item.GetItemInfoInstant() end
function C_Item.GetStackCount() end

--quests
---@class questrewardcurrencyinfo
---@field texture number
---@field name string
---@field currencyID number
---@field quality number
---@field baseRewardAmount number
---@field bonusRewardAmount number
---@field totalRewardAmount number
---@field questRewardContextFlags table?

--faction
---@class factioninfo
---@field hasBonusRepGain boolean
---@field description string
---@field isHeaderWithRep boolean
---@field isHeader boolean
---@field currentReactionThreshold number
---@field canSetInactive boolean
---@field atWarWith boolean
---@field isWatched boolean
---@field isCollapsed boolean
---@field canToggleAtWar boolean
---@field nextReactionThreshold number
---@field factionID number
---@field name string
---@field currentStanding number
---@field isAccountWide boolean
---@field isChild boolean
---@field reaction number

C_Reputation = {}
---return a table of class 'factioninfo' containing the faction data
---@param id number
---@return factioninfo
function C_Reputation.GetFactionDataByID(id) return {} end

---return a table of class 'factioninfo' containing the player guild rep information
---@return factioninfo
function C_Reputation.GetGuildFactionData() return {} end

C_UnitAuras = {}

---@param privateAuraAnchor privateaura_anchor
function C_UnitAuras.AddPrivateAuraAnchor(privateAuraAnchor)end

---@param privateAuraAnchor privateaura_anchor
---@return number
function C_UnitAuras.AddPrivateAuraAppliedSound(privateAuraAnchor) return 0 end

---@param spellID spellid
---@return boolean
function C_UnitAuras.AuraIsPrivate(spellID) return true end

---@param parent uiobject
---@param anchor privateaura_anchorbinding
function C_UnitAuras.SetPrivateWarningTextAnchor(parent, anchor) end

---@param anchorID number
function C_UnitAuras.RemovePrivateAuraAnchor(anchorID) end

---@param privateAuraSoundID number
function C_UnitAuras.RemovePrivateAuraAppliedSound(privateAuraSoundID) end

---@param unitToken unit
---@param auraInstanceID number
---@return aurainfo
function C_UnitAuras.GetAuraDataByAuraInstanceID(unitToken, auraInstanceID) return {} end

---@param unitToken unit
---@param auraIndex number
---@param filter aurafilter?
---@return aurainfo
function C_UnitAuras.GetAuraDataByIndex(unitToken, auraIndex, filter) return {} end

---@param unitToken unit
---@param auraSlot number
---@return aurainfo
function C_UnitAuras.GetAuraDataBySlot(unitToken, auraSlot) return {} end

---@param unitToken unit
---@param spellName spellname
---@param filter aurafilter?
---@return aurainfo
function C_UnitAuras.GetAuraDataBySpellName(unitToken, spellName, filter) return {} end

---@param unitToken unit
---@param filter aurafilter
---@param maxSlots number
---@param continuationToken number
---@return number outContinuationToken
---@return ...
function C_UnitAuras.GetAuraSlots(unitToken, filter, maxSlots, continuationToken) return 0, 0 end

---@param unitToken unit
---@param index number
---@param filter aurafilter?
---@return aurainfo
function C_UnitAuras.GetBuffDataByIndex(unitToken, index, filter) return {} end

---@param unitToken unit
---@param index number
---@param filter aurafilter?
---@return aurainfo
function C_UnitAuras.GetDebuffDataByIndex(unitToken, index, filter) return {} end

---@param spellID spellid
---@return spellid
function C_UnitAuras.GetCooldownAuraBySpellID(spellID) return 0 end

---@param spellID spellid
---@return aurainfo
function C_UnitAuras.GetPlayerAuraBySpellID(spellID) return {} end

---@param unitToken unit
---@param auraInstanceID number
---@param filterString aurafilter
---@return boolean
function C_UnitAuras.IsAuraFilteredOutByInstanceID(unitToken, auraInstanceID, filterString) return true end

---@param unitToken unit
---@return boolean
function C_UnitAuras.WantsAlteredForm(unitToken) return true end



---linearly interpolates between two values. Example: Lerp(1, 2, 0.5) return 1.5
---@param startValue number The starting value.
---@param endValue number The ending value.
---@param amount number The interpolation amount (between 0 and 1).
---@return number amount The interpolated value.
function Lerp(startValue, endValue, amount) return 0 end

---clamps a value between a minimum and maximum range. Example: Clamp(17, 13, 15) return 15
---@param value number The value to clamp.
---@param min number The minimum value of the range.
---@param max number The maximum value of the range.
---@return number value The clamped value.
function Clamp(value, min, max) return 0 end

--lock a value to be between 0 and 1. Example: Saturate(1.324) return 1, Saturate(-0.324) return 0
---@param value number The value to saturate.
---@return number value The saturated value.
function Saturate(value) return 0 end

---wraps a value within a specified range. Example: Wrap(17, 13) return 4
---@param value number The value to wrap.
---@param max number The maximum value of the range.
---@return number value The wrapped value.
function Wrap(value, max) return 0 end

---wraps a value within a specified range using modular arithmetic. Example: ClampMod(11, 3) return 2 (11 % 3 = 2)
---@param value number The value to be wrapped.
---@param mod number The modulus defining the range. The value will be wrapped within the range from 0 to mod - 1.
---@return number value The wrapped value within the specified range.
function ClampMod(value, mod) return 0 end

---clamps an angle value within the range of 0 to 359 degrees.
---@param value number The angle value to be clamped.
---@return number value The clamped angle value within the range of 0 to 359 degrees.
function ClampDegrees(value) return 0 end

---negates a value if a condition is true, otherwise returns the original value.
---@param value number The value to be negated or returned.
---@param condition boolean The condition determining whether to negate the value.
---@return number value The negated value if the condition is true, otherwise the original value.
function NegateIf(value, condition) return 0 end


---Generates a random floating-point number within a specified range.
---@param minValue number - The minimum value of the range.
---@param maxValue number - The maximum value of the range.
---@return number float - A random floating-point number within the specified range.
function RandomFloatInRange(minValue, maxValue) return 0 end

---Calculates the percentage between two values.
---@param value number The value to calculate the percentage for.
---@param startValue number The starting value.
---@param endValue number The ending value.
---@return number percentage between the startValue and endValue.
function PercentageBetween(value, startValue, endValue) return 0 end

---Calculates the clamped percentage between two values.
---The result is clamped between 0 and 1.
---@param value number The value to calculate the clamped percentage for.
---@param startValue number The starting value.
---@param endValue number The ending value.
---@return number clampedPercentage between the startValue and endValue.
function ClampedPercentageBetween(value, startValue, endValue) return 0 end

---Returns the time in seconds since the last frame was drawn.
---@return number timeSec The time in seconds since the last frame was drawn.
function GetTickTime() return 0 end

---Linearly interpolates between two values.
---@param startValue number The starting value.
---@param endValue number The ending value.
---@param amount number The interpolation amount (between 0 and 1).
---@param timeSec number The time in seconds.
---@return number The interpolated value.
function DeltaLerp(startValue, endValue, amount, timeSec) return 0 end

---@param amount number The interpolation amount (between 0 and 1).
---@return number The interpolated value.
function FrameDeltaLerp(startValue, endValue, amount) return 0 end

---Rounds a value to a specified number of significant digits.
---@param value number The value to round.
---@param numDigits number The number of significant digits.
---@return number The rounded value.
function RoundToSignificantDigits(value, numDigits) return 0 end

---Squares a value.
---@param value number The value to square.
---@return number The squared value.
function Square(value) return 0 end

---Returns the sign of a value.
---@param value number The value to check the sign of.
---@return number The sign of the value (-1, 0, or 1).
function Sign(value) return 0 end

---Checks if a value is within a specified range (inclusive).
---@param value number The value to check.
---@param min number The minimum value of the range.
---@param max number The maximum value of the range.
---@return boolean Whether the value is within the range.
function WithinRange(value, min, max) return true end

---Checks if a value is within a specified range (exclusive).
---@param value number The value to check.
---@param min number The minimum value of the range.
---@param max number The maximum value of the range.
---@return boolean Whether the value is within the range.
function WithinRangeExclusive(value, min, max) return true end

---Checks if two values are approximately equal within a specified epsilon.
---@param v1 number The first value to compare.
---@param v2 number The second value to compare.
---@param epsilon number (optional) The epsilon value for comparison.
---@return boolean Whether the values are approximately equal.
function ApproximatelyEqual(v1, v2, epsilon) return true end

---Calculates the squared distance between two points.
---@param x1 number The x-coordinate of the first point.
---@param y1 number The y-coordinate of the first point.
---@param x2 number The x-coordinate of the second point.
---@param y2 number The y-coordinate of the second point.
---@return number The squared distance between the points.
function CalculateDistanceSq(x1, y1, x2, y2) return 0 end

---Calculates the distance between two points.
---@param x1 number The x-coordinate of the first point.
---@param y1 number The y-coordinate of the first point.
---@param x2 number The x-coordinate of the second point.
---@param y2 number The y-coordinate of the second point.
---@return number The distance between the points.
function CalculateDistance(x1, y1, x2, y2) return 0 end

---Calculates the angle between two points.
---@param x1 number The x-coordinate of the first point.
---@param y1 number The y-coordinate of the first point.
---@param x2 number The x-coordinate of the second point.
---@param y2 number The y-coordinate of the second point.
---@return number The angle between the points.
function CalculateAngleBetween(x1, y1, x2, y2) return 0 end

---Returns a formatted version of its variable number of arguments following the description given in its first argument.
---@param s string|number
---@param ... any
---@return string
---@nodiscard
function format(s, ...) return "" end

---Returns the length of a string.
---@param s string
---@return number
function strlen(s) return 0 end

---Returns a substring of a given string.
---@param s string The input string.
---@param start number The starting index of the substring.
---@param finish number (optional) The ending index of the substring. If not provided, the substring will include all characters from the starting index to the end of the string.
---@return string return The resulting substring.
function strsub(s, start, finish) return "" end

---Rounds a given value to the nearest integer.
---If the value is negative, it rounds up.
---If the value is positive, it rounds down.
---@param value number The value to be rounded.
---@return number roundedValue
function Round(value) return 0 end

table.wipe = true
wipe = true

---returns the maximum value among the given numbers.
---@param ... number The numbers to compare.
---@return number The maximum value.
max = function(...) return 0 end

---returns the minimum value among the given numbers.
---@param ... number The numbers to compare.
---@return number The minimum value.
min = function(...) return 0 end

--- ColorMixin is a mixin that provides functionality for working with colors.
---@class ColorMixin : table
ColorMixin = {}

---@class colorRGB : table, ColorMixin
---@field r number
---@field g number
---@field b number

---Sets the RGBA values of the color.
---@param r number The red component of the color (0-1).
---@param g number The green component of the color (0-1).
---@param b number The blue component of the color (0-1).
---@param a? number The alpha component of the color (0-1).
function ColorMixin:SetRGBA(r, g, b, a) end

---Sets the RGB values of the color.
---@param r number The red component of the color (0-1).
---@param g number The green component of the color (0-1).
---@param b number The blue component of the color (0-1).
function ColorMixin:SetRGB(r, g, b) end

---Returns the RGB values of the color.
---@return number r
---@return number g
---@return number b
function ColorMixin:GetRGB() return 0, 0, 0 end

---Returns the RGB values of the color as bytes (0-255).
---@return number red
---@return number green
---@return number blue
function ColorMixin:GetRGBAsBytes() return 0, 0, 0 end

---Returns the RGBA values of the color.
---@return number red
---@return number green
---@return number blue
---@return number alpha
function ColorMixin:GetRGBA() return 0, 0, 0, 0 end

---Returns the RGBA values of the color as bytes (0-255).
---@return number red
---@return number green
---@return number blue
---@return number alpha
function ColorMixin:GetRGBAAsBytes() return 0, 0, 0, 0 end

---Checks if the RGB values of this color are equal to another color.
---@param otherColor table The other color to compare with.
---@return boolean bIsEqual if the RGB values are equal, false otherwise.
function ColorMixin:IsRGBEqualTo(otherColor) return true end

---Checks if this color is equal to another color.
---@param otherColor table The other color to compare with.
---@return boolean True if the RGB and alpha values are equal, false otherwise.
function ColorMixin:IsEqualTo(otherColor) return true end

---Generates a hexadecimal color string with alpha.
---@return string hexadecimal color string with alpha.
function ColorMixin:GenerateHexColor() return "" end

---Generates a hexadecimal color string without alpha.
---@return string hexadecimal color string without alpha.
function ColorMixin:GenerateHexColorNoAlpha() return "" end

---Generates a hexadecimal color markup string.
---@return string hexadecimal color markup string.
function ColorMixin:GenerateHexColorMarkup() return "" end

---Wraps the given text in a color code using this color.
---@param text string The text to wrap.
---@return string The wrapped text with the color code.
function ColorMixin:WrapTextInColorCode(text) return "" end

---name space for challenge mode functions.
---@documentation: /Blizzard_APIDocumentationGenerated/ChallengeModeInfoDocumentation.lua
C_ChallengeMode = {}

---@class ChallengeModeCompletionMemberInfo
---@field memberGUID string
---@field name string

---@class ChallengeModeGuildAttemptMember
---@field name string
---@field classFileName string

---@class ChallengeModeGuildTopAttempt
---@field name string
---@field classFileName string
---@field keystoneLevel number
---@field mapChallengeModeID number
---@field isYou boolean
---@field members table<ChallengeModeGuildAttemptMember>

---@class MythicPlusRatingLinkInfo : table
---@field mapChallengeModeID number
---@field level number
---@field completedInTime number
---@field dungeonScore number
---@field name string

---@class MythicPlusAffixScoreInfo : table
---@field name string
---@field score number
---@field level number
---@field durationSec number
---@field overTime boolean

---return true if the player is in a challenge mode dungeon.
---@return boolean bIsActive Whether the player is in a challenge mode dungeon.
function C_ChallengeMode.IsChallengeModeActive() return true end

---return the current challenge mode map id.
---@return number mapID The map id of the current challenge mode.
function C_ChallengeMode.GetActiveChallengeMapID() return 0 end

---return the current challenge mode keystone level.
---@return number level The keystone level of the current challenge mode.
---@return number[] affixIDs The affix ids of the current challenge mode.
---@return boolean wasActive Whether the keystone was active.
function C_ChallengeMode.GetActiveKeystoneInfo() return 0, {}, true end

---return the completion information for the current challenge mode.
---@return number mapChallengeModeID The map id of the challenge mode.
---@return number level The keystone level of the challenge mode.
---@return number time The time taken to complete the challenge mode.
---@return boolean onTime Whether the challenge mode was completed within the time limit.
---@return number keystoneUpgradeLevels The number of keystone upgrade levels.
---@return boolean practiceRun Whether the challenge mode was a practice run.
---@return number oldOverallDungeonScore The old overall dungeon score.
---@return number newOverallDungeonScore The new overall dungeon score.
---@return boolean isMapRecord Whether the completion is a map record.
---@return boolean isAffixRecord Whether the completion is an affix record.
---@return number primaryAffix The primary affix id.
---@return boolean isEligibleForScore Whether the completion is eligible for a score.
---@return ChallengeModeCompletionMemberInfo[] members The members of the group.
function C_ChallengeMode.GetCompletionInfo() return 0, 0, 0, true, 0, true, 0, 0, true, true, 0, true, {} end

---return the death count for the current challenge mode.
---@return number numDeaths The number of deaths.
---@return number timeLost The time lost due to deaths.
function C_ChallengeMode.GetDeathCount() return 0, 0 end

---return the color value for the overall season M+ rating.
---@param dungeonScore number The overall season M+ rating.
---@return colorRGB scoreColor The color value for the overall season M+ rating.
function C_ChallengeMode.GetDungeonScoreRarityColor(dungeonScore) return {} end

---return the top guild attempts for the current challenge mode.
---@return ChallengeModeGuildTopAttempt[] topAttempt The top guild attempts for the current challenge mode.
function C_ChallengeMode.GetGuildLeaders() return {} end

---return the color value for the keystone level.
---@param level number The keystone level.
---@return colorRGB levelScore The color value for the keystone level.
function C_ChallengeMode.GetKeystoneLevelRarityColor(level) return {} end

---return the display scores for the current challenge mode map.
---@return MythicPlusRatingLinkInfo[] displayScores The display scores for the current challenge mode map.
function C_ChallengeMode.GetMapScoreInfo() return {} end

---return the map ids for the challenge mode.
---@return number[] mapChallengeModeIDs The map ids for the challenge mode.
function C_ChallengeMode.GetMapTable() return {} end

---return the UI information for the challenge mode map.
---@param mapChallengeModeID number The map id for the challenge mode.
---@return string name The name of the challenge mode map.
---@return number id The id of the challenge mode map.
function C_ChallengeMode.GetMapUIInfo(mapChallengeModeID) return "", 0 end

---return the affix information for the challenge mode.
---@param affixID number The affix id for the challenge mode.
---@return string name The name of the affix.
---@return string description The description of the affix.
---@return number filedataid The file data id for the affix.
function C_ChallengeMode.GetAffixInfo(affixID) return "", "", 0 end

---return true if the player can use the keystone in the current map.
---@param itemLocation ItemLocationMixin The item location of the keystone.
---@return boolean canUse Whether the player can use the keystone in the current map.
function C_ChallengeMode.CanUseKeystoneInCurrentMap(itemLocation) return true end

---clear the keystone.
function C_ChallengeMode.ClearKeystone() end

---close the keystone frame.
function C_ChallengeMode.CloseKeystoneFrame() end

---return true if the player has a slotted keystone.
---@return boolean hasSlottedKeystone Whether the player has a slotted keystone.
function C_ChallengeMode.HasSlottedKeystone() return true end

---remove the keystone.
---@return boolean removalSuccessful Whether the keystone was removed.
function C_ChallengeMode.RemoveKeystone() return true end

---request the leaders for the challenge mode map.
---@param mapChallengeModeID number The map id for the challenge mode.
function C_ChallengeMode.RequestLeaders(mapChallengeModeID) end

---reset the challenge mode.
function C_ChallengeMode.Reset() end

---slot the keystone.
function C_ChallengeMode.SlotKeystone() end

---start the challenge mode.
---@return boolean success Whether the challenge mode was started.
function C_ChallengeMode.StartChallengeMode() return true end

---return the power level damage and health modifiers for the challenge mode.
---@param powerLevel number The power level for the challenge mode.
---@return number damageMod The damage modifier for the challenge mode.
---@return number healthMod The health modifier for the challenge mode.
function C_ChallengeMode.GetPowerLevelDamageHealthMod(powerLevel) return 0, 0 end

---return the overall season M+ rating for the player.
---@return number overallDungeonScore The overall season M+ rating for the player.
function C_ChallengeMode.GetOverallDungeonScore() return 0 end

---return the slotted keystone information.
---@return number mapChallengeModeID The map id for the challenge mode.
---@return number[] affixIDs The affix ids for the challenge mode.
---@return number keystoneLevel The keystone level for the challenge mode.
function C_ChallengeMode.GetSlottedKeystoneInfo() return 0, {}, 0 end

---return the color value for the specific dungeon overall score.
---@param specificDungeonOverallScore number The specific dungeon overall score.
---@return colorRGB specificDungeonOverallScoreColor The color value for the specific dungeon overall score.
function C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(specificDungeonOverallScore) return {} end

---return the color value for the specific dungeon score.
---@param specificDungeonScore number The specific dungeon score.
---@return colorRGB specificDungeonScoreColor The color value for the specific dungeon score.
function C_ChallengeMode.GetSpecificDungeonScoreRarityColor(specificDungeonScore) return {} end

---return the color value for the overall season M+ rating.
---@param overallDungeonScore number The overall season M+ rating.
---@return colorRGB overallDungeonScoreColor The color value for the overall season M+ rating.
function C_ChallengeMode.GetOverallDungeonScoreRarityColor(overallDungeonScore) return {} end



PixelUtil = {}

---@param object statusbar
---@param value number
PixelUtil.SetStatusBarValue = function(object, value) end

---@param object uiobject
---@param width number
PixelUtil.SetWidth = function(object, width) end

---@param object uiobject
---@param height number
PixelUtil.SetHeight = function(object, height) end

---@param object uiobject
---@param width number
---@param height number
PixelUtil.SetSize = function(object, width, height) end

---@param object uiobject
---@param point string
---@param relativeTo uiobject
---@param relativePoint string
---@param offsetX number
---@param offsetY number
PixelUtil.SetPoint = function(object, point, relativeTo, relativePoint, offsetX, offsetY) end

---@param desiredPixels number
---@param layoutScale number
---@return number
PixelUtil.ConvertPixelsToUI = function(desiredPixels, layoutScale) return 0 end

---@param uiUnitSize number
---@param layoutScale number
---@param minPixels number
---@return number
PixelUtil.GetNearestPixelSize = function(uiUnitSize, layoutScale, minPixels) return 0 end

---@return number
PixelUtil.GetPixelToUIUnitFactor = function() return 0 end

---@param desiredPixels number
---@param region region
---@return number
PixelUtil.ConvertPixelsToUIForRegion = function(desiredPixels, region) return 0 end

---@class aurautil
AuraUtil = {}

---a table containing filter flags for aura filtering.
AuraUtil.AuraFilters = {
    Cancelable = "CANCELABLE",                 -- Filter for cancelable auras.
    IncludeNameplateOnly = "INCLUDE_NAME_PLATE_ONLY", -- Filter for including nameplate-only auras.
    Harmful = "HARMFUL",                       -- Filter for harmful auras.
    Raid = "RAID",                             -- Filter for raid auras.
    NotCancelable = "NOT_CANCELABLE",          -- Filter for non-cancelable auras.
    Helpful = "HELPFUL",                       -- Filter for helpful auras.
    Player = "PLAYER",                         -- Filter for player auras.
    Maw = "MAW",                               -- Filter for Maw-related auras.
}

---a function that determines if an aura is a priority debuff.
---@param spellId string The name of the aura to check.
---@return boolean bIsPriorityDebuff Whether the aura is a priority debuff.
AuraUtil.IsPriorityDebuff = function(spellId) return true end

---a function that determines if a buff should be displayed.
---@param unit string The unit ID to check.
---@param spellId string The name of the aura to check.
---@return boolean bShouldDisplayBuff Whether the buff should be displayed.
AuraUtil.ShouldDisplayBuff = function(unit, spellId) return true end

---a function that creates a filter string based on the provided filters.
---@param filters table A table containing aura filters.
---@return string filterString The generated filter string.
AuraUtil.CreateFilterString = function(filters) return "" end

---a function that determines if a debuff should be displayed.
---@param unit string The unit ID to check.
---@param spellId string The name of the aura to check.
---@return boolean bShouldDisplayDebuff Whether the debuff should be displayed.
AuraUtil.ShouldDisplayDebuff = function(unit, spellId) return true end

---a function that processes aura data.
---@param auraInfo aurainfo The aura data to process.
---@param displayOnlyDispellableDebuffs boolean Whether to display only dispellable debuffs.
---@param ignoreBuffs boolean Whether to ignore buffs.
---@param ignoreDebuffs boolean Whether to ignore debuffs.
---@param ignoreDispelDebuffs boolean Whether to ignore dispellable debuffs.
---@return number auraType The processed aura data.
AuraUtil.ProcessAura = function(auraInfo, displayOnlyDispellableDebuffs, ignoreBuffs, ignoreDebuffs, ignoreDispelDebuffs) return 0 end

---a function that finds an aura with the specified criteria.
---@param predicate function The predicate function.
---@param unit string The unit ID to search.
---@param filter string|nil Optional filter for the type of aura to find.
---@param predicateArg1 any Optional first argument to pass to the predicate function.
---@param predicateArg2 any Optional second argument to pass to the predicate function.
---@param predicateArg3 any Optional third argument to pass to the predicate function.
AuraUtil.FindAura = function(predicate, unit, filter, predicateArg1, predicateArg2, predicateArg3) end

---a function that finds an aura by its name.
---@param unit string The unit ID to search.
---@param auraName string The name of the aura to find.
---@param filter string|nil Optional filter for the type of aura to find.
---@return table auraData The found aura data.
AuraUtil.FindAuraByName = function(unit, auraName, filter) return table end

---a function that provides a default comparison function for auras.
---@param auraA table The first aura to compare.
---@param auraB table The second aura to compare.
---@return boolean isEqual Whether the two auras are equal.
AuraUtil.DefaultAuraCompare = function(auraA, auraB) return true end

---a table that updates the changed type of an aura.
AuraUtil.AuraUpdateChangedType = {
    Dispel = 4,                                -- Updated type for dispel auras.
    Debuff = 2,                                -- Updated type for debuff auras.
    Buff = 3,                                  -- Updated type for buff auras.
    None = 1,                                  -- Updated type for no change.
}

---a table containing types for unit frame debuffs.
AuraUtil.UnitFrameDebuffType = {
    NonBossDebuff = 5,                         -- Type for non-boss debuffs.
    NonBossRaidDebuff = 4,                     -- Type for non-boss raid debuffs.
    BossBuff = 2,                              -- Type for boss buffs.
    PriorityDebuff = 3,                        -- Type for priority debuffs.
    BossDebuff = 1,                            -- Type for boss debuffs.
}

---a function that compares unit frame debuffs.
---@param auraInfo1 aurainfo
---@param auraInfo2 aurainfo
---@return table
AuraUtil.UnitFrameDebuffComparator = function(auraInfo1, auraInfo2) return table end

---a function that unpacks aura data.
---@param auraInfo aurainfo
---@return ... Unpacked aura data.
AuraUtil.UnpackAuraData = function(auraInfo) end

---a table containing types of dispellable debuffs.
AuraUtil.DispellableDebuffTypes = {
    Poison = true,                             -- Type for poison debuffs.
    Curse = true,                              -- Type for curse debuffs.
    Magic = true,                              -- Type for magic debuffs.
    Disease = true,                            -- Type for disease debuffs.
}

---a function that iterates over each aura.
---@param unit string The unit ID to iterate over.
---@param filter string|nil Optional filter for the type of aura to iterate over.
---@param maxCount number|nil Optional maximum number of auras to iterate over.
---@param func function The function to call for each aura.
---@param usePackedAura boolean Whether to use packed aura data.
---@return any
AuraUtil.ForEachAura = function(unit, filter, maxCount, func, usePackedAura) end

---@class bit : table
---@field band fun(x: number, y: number) : number
---@field bor fun(x: number, y: number) : number
---@field bxor fun(x: number, y: number) : number
---@field bnot fun(x: number) : number
---@field lshift fun(x: number, y: number) : number
---@field rshift fun(x: number, y: number) : number
---@field rol fun(x: number, y: number) : number
---@field ror fun(x: number, y: number) : number

---@class bit
bit = {}

---returns the bitwise AND of two numbers.
---@param x number The first number.
---@param y number The second number.
---@return number The bitwise AND of the two numbers.
function bit.band(x, y) return 0 end

---returns the bitwise OR of two numbers.
---@param x number The first number.
---@param y number The second number.
---@return number The bitwise OR of the two numbers.
function bit.bor(x, y) return 0 end

---returns the bitwise XOR of two numbers.
---@param x number The first number.
---@param y number The second number.
---@return number The bitwise XOR of the two numbers.
function bit.bxor(x, y) return 0 end

---returns the bitwise NOT of a number.
---@param x number The number to invert.
---@return number The bitwise NOT of the number.
function bit.bnot(x) return 0 end

---returns the bitwise shift left of a number.
---@param x number The number to shift.
---@param y number The number of bits to shift.
---@return number The bitwise shift left of the number.
function bit.lshift(x, y) return 0 end

---returns the bitwise shift right of a number.
---@param x number The number to shift.
---@param y number The number of bits to shift.
---@return number The bitwise shift right of the number.
function bit.rshift(x, y) return 0 end

---returns the bitwise rotate left of a number.
---@param x number The number to rotate.
---@param y number The number of bits to rotate.
---@return number The bitwise rotate left of the number.
function bit.rol(x, y) return 0 end

---returns the bitwise rotate right of a number.
---@param x number The number to rotate.
---@param y number The number of bits to rotate.
---@return number The bitwise rotate right of the number.
function bit.ror(x, y) return 0 end

---return the epoch time in seconds from the server.
---@return number
function GetServerTime() return 0 end

C_Spell = {}

---@param spellID number
---@return spellinfo
function C_Spell.GetSpellInfo(spellID) return {} end

---@param spellID number
---@return spellchargeinfo
function C_Spell.GetSpellCharges(spellID) return {} end

C_Timer = {}
---@param delay number
---@param callback function
---@return table timerHandle
function C_Timer.NewTimer(delay, callback) return {} end

---@param delay number
---@param callback function
function C_Timer.After(delay, callback) end

---@param timerHandle table
function C_Timer.CancelTimer(timerHandle) end

---@param delay number
---@param callback function
---@param repetitions number?
---@return table timerHandle
function C_Timer.NewTicker(delay, callback, repetitions) return {} end

---@param list table
---@param i number?
---@param j number?
---@return ...
function unpack(list, i, j) end

---@param x number
---@return number
function abs(x) return 0 end

LE_PARTY_CATEGORY_HOME = 1
LE_PARTY_CATEGORY_INSTANCE = 2

---retur true if the player is in a group
---@param partyCategory number?
---@return boolean
function IsInGroup(partyCategory) return true end

---@param name string
---@param server string|nil
---@return string
function Ambiguate(name, server) return "" end

---@return boolean
function IsInRaid() return true end

---@param x number
---@return number
function ceil(x) return 0 end

---@param str string
---@param separator string
---@param limit number|nil
---@return ...
function strsplit(str, separator, limit) return "" end

---@param x number
---@return number
function floor(x) return 0 end

---@param table table
---@param index number
---@return any
function tremove(table, index) return nil end

--loads a string and output a function in lua.
---@param code string The Lua code string to be executed.
---@return function func A function to be executed.
function loadstring(code) return function()end end

---lua os.date() function
---@param format string?
---@param time number?
---@return string
function date(format, time) return "" end

---lua os.time() function
---@return number
function time() return 0 end

---returns the number of members in the current group.
---@return number
GetNumGroupMembers = function() return 0 end

---@param spellId number
---@return number, number, number
GetSpellCharges = function(spellId) return 0, 0, 0 end

---@param achievementId number
AddTrackedAchievement = function(achievementId) end

---@return boolean
CanShowAchievementUI = function() return true end
ClearAchievementComparisonUnit = function() end

---@param achievementID number
---@return number
GetAchievementCategory = function(achievementID) return 0 end

---@param achievementID number
---@return string, number, number, number, number, number, number, string, string, string, boolean, boolean, boolean, boolean, number
GetAchievementComparisonInfo = function(achievementID) return "", 0, 0, 0, 0, 0, 0, "", "", "", true, true, true, true, 0 end

---@param achievementID number
---@param criteriaIndex number
---@return string, number, boolean, boolean, number, number, string, number, number, string
GetAchievementCriteriaInfo = function(achievementID, criteriaIndex) return "", 0, true, true, 0, 0, "", 0, 0, "" end

---@param achievementID number
---@return string, number, number, number, number, number, number, string, string, string, boolean, boolean, boolean, boolean, number
GetAchievementInfo = function(achievementID) return "", 0, 0, 0, 0, 0, 0, "", "", "", true, true, true, true, 0 end

---@param criteriaID number
---@return number
GetAchievementInfoFromCriteria = function(criteriaID) return 0 end

---@param achievementID number
---@return string
GetAchievementLink = function(achievementID) return "" end

---@param achievementID number
---@return number
GetAchievementNumCriteria = function(achievementID) return 0 end

---@param specIndex number
---@param isInspect boolean
---@param isPet boolean
---@param sex number
---@param level number
---@return number, string, string, string, number, string
GetSpecializationInfo = function(specIndex, isInspect, isPet, sex, level) return 0, "", "", "", 0, "" end

---@param specID number
---@param isInspect boolean?
---@param isPet boolean?
---@param inspectTarget string?
---@return number specId
---@return string name
---@return string description
---@return string icon
---@return number role
---@return ...
GetSpecializationInfoByID = function(specID, isInspect, isPet, inspectTarget) return 0, "", "", "", 0, "" end

---Retrieves specialization information for a given class ID and the specialization index (1 to 3 or 4 on Druids).
---@param classID number The ID of the class.
---@param index number The index of the specialization.
---@return number specializationID The ID of the specialization.
---@return string specName The name of the specialization.
---@return string specDescription The description of the specialization.
---@return string icon The icon of the specialization.
---@return number role The role of the specialization.
---@return boolean recommended Whether the specialization is recommended.
---@return boolean allowedForBoost Whether the specialization is allowed for boost.
---@return number masterySpell1 The ID of the first mastery spell.
---@return number masterySpell2 The ID of the second mastery spell.
GetSpecializationInfoForClassID = function(classID, index) return 0, "", "", "", 0, true, true, 0, 0 end

--make here the documentation for the function GetSpecializationInfoForSpecID() following the same pattern as the other functions
---@param specID number
---@return number specializationID The ID of the specialization.
---@return string specName The name of the specialization.
---@return string specDescription The description of the specialization.
---@return string icon The icon of the specialization.
---@return number role The role of the specialization.
---@return boolean recommended Whether the specialization is recommended.
---@return boolean allowedForBoost Whether the specialization is allowed for boost.
---@return number masterySpell1 The ID of the first mastery spell.
---@return number masterySpell2 The ID of the second mastery spell.
GetSpecializationInfoForSpecID = function(specID) return 0, "", "", "", 0, true, true, 0, 0 end

---@param achievementID number
---@return number
GetAchievementNumRewards = function(achievementID) return 0 end

---@param categoryID number
---@return string, string, number
GetCategoryInfo = function(categoryID) return "", "", 0 end

---@return table
GetCategoryList = function() return {} end

---@param isInspect boolean
---@param isPet boolean
---@return number
GetSpecialization = function(isInspect, isPet) return 0 end

---@param categoryID number
---@return number
GetCategoryNumAchievements = function(categoryID) return 0 end

---@return number
GetComparisonAchievementPoints = function() return 0 end

---@param categoryID number
---@return number
GetComparisonCategoryNumAchievements = function(categoryID) return 0 end

---@param statisticID number
---@return string
GetComparisonStatistic = function(statisticID) return "" end

---@return table
GetLatestCompletedAchievements = function() return {} end

---@return table
GetLatestCompletedComparisonAchievements = function() return {} end

---@return table
GetLatestUpdatedComparisonStatsGetLatestUpdatedStats = function() return {} end
---@return number
GetNextAchievement = function() return 0 end

---@return number
GetNumComparisonCompletedAchievements = function() return 0 end

---@return number
GetNumCompletedAchievements = function() return 0 end

---@return number
GetPreviousAchievement = function() return 0 end

---@param categoryID number
---@return string
GetStatistic = function(categoryID) return "" end

---@return table
GetStatisticsCategoryList = function() return {} end

---@return number
GetTotalAchievementPoints = function() return 0 end

---@return table
GetTrackedAchievements = function() return {} end

---@return number
GetNumTrackedAchievements = function() return 0 end

---@param achievementID number
RemoveTrackedAchievement = function(achievementID) end

---@param unit string
SetAchievementComparisonUnit = function(unit) end

---@param slot number
ActionButtonDown = function(slot) end

---@param slot number
ActionButtonUp = function(slot) end

---@param slot number
---@return boolean
ActionHasRange = function(slot) return true end

CameraOrSelectOrMoveStart = function() end

CameraOrSelectOrMoveStop = function() end

---@param page number
ChangeActionBarPage = function(page) end

---@return number
GetActionBarPage = function() return 0 end

---@return boolean, boolean, boolean
GetActionBarToggles = function() return true, true, true end

---@param slot number
---@return number, number
GetActionCooldown = function(slot) return 0, 0 end

---@param slot number
---@return number
GetActionCount = function(slot) return 0 end

---@param slot number
---@return string, string, string, boolean, boolean, boolean, boolean
GetActionInfo = function(slot) return "", "", "", true, true, true, true end

---@param slot number
---@return string
GetActionText = function(slot) return "" end

---@param slot number
---@return string
GetActionTexture = function(slot) return "" end

---@return number
GetBonusBarOffset = function() return 0 end

---@return string
GetMouseButtonClicked = function() return "" end

---@return number
GetMultiCastBarOffset = function() return 0 end

---@param slot number
---@return boolean, string
GetPossessInfo = function(slot) return true, "" end

---@param slot number
---@return boolean
HasAction = function(slot) return true end

---@param slot number
---@return number
IsActionInRange = function(slot) return 0 end

---@param slot number
---@return boolean
IsAttackAction = function(slot) return true end

---@param slot number
---@return boolean
IsAutoRepeatAction = function(slot) return true end

---@param slot number
---@return boolean
IsCurrentAction = function(slot) return true end

---@param slot number
---@return boolean
IsConsumableAction = function(slot) return true end

---@param slot number
---@return boolean
IsEquippedAction = function(slot) return true end

---@param slot number
---@return boolean, boolean
IsUsableAction = function(slot) return true, true end

---@return boolean
PetHasActionBar = function() return true end

---@param slot number
PickupAction = function(slot) end

---@param slot number
PickupPetAction = function(slot) end

---@param slot number
PlaceAction = function(slot) end

---@param bottomLeftState number
---@param bottomRightState number
---@param sideRightState number
---@param sideRight2State number
---@param alwaysShow number
SetActionBarToggles = function(bottomLeftState, bottomRightState, sideRightState, sideRight2State, alwaysShow) end

StopAttack = function() end

TurnOrActionStart = function() end

TurnOrActionStop = function() end

---@param slot number
---@param checkCursor boolean
UseAction = function(slot, checkCursor) end

AcceptDuel = function() end

AttackTarget = function() end

CancelDuel = function() end

CancelLogout = function() end

ClearTutorials = function() end

CancelSummon = function() end

ConfirmSummon = function() end

DescendStop = function() end

Dismount = function() end

---@param tutorial number
FlagTutorial = function(tutorial) end

ForceQuit = function() end

---@return number
GetPVPTimer = function() return 0 end

---@return string
GetSummonConfirmAreaName = function() return "" end

---@return string
GetSummonConfirmSummoner = function() return "" end

---@return number
GetSummonConfirmTimeLeft = function() return 0 end
---@param min number
---@param max number
RandomRoll = function(min, max) end

---@param enable boolean
SetPVP = function(enable) end

---@param unit string
StartDuel = function(unit) end

TogglePVP = function() end

ToggleSheath = function() end

---@param type string
UseSoulstone = function(type) end

---@return boolean
CanSolveArtifact = function() return true end

UIParent = {}

---@param raceIndex number
---@return number, string, string, number, number, number, number, number
GetArtifactInfoByRace = function(raceIndex) return 0, "", "", 0, 0, 0, 0, 0 end

---@return number, number
GetArtifactProgress = function() return 0, 0 end

---@param raceIndex number
---@return number
GetNumArtifactsByRace = function(raceIndex) return 0 end

---@return number, string, string, number, number, number, number, number
GetSelectedArtifactInfo = function() return 0, "", "", 0, 0, 0, 0, 0 end

---@return boolean
IsArtifactCompletionHistoryAvailable = function() return true end

---@param itemID number
---@return boolean
ItemAddedToArtifact = function(itemID) return true end

---@param itemID number
RemoveItemFromArtifact = function(itemID) end

RequestArtifactCompletionHistory = function() end

---@param itemID number
SocketItemToArtifact = function(itemID) end

---@param teamIndex number
AcceptArenaTeam = function(teamIndex) end

---@param playerName string
ArenaTeamInviteByName = function(playerName) end

---@param playerName string
ArenaTeamSetLeaderByName = function(playerName) end

---@param teamIndex number
ArenaTeamLeave = function(teamIndex) end

ArenaTeamRoster = function() end

---@param playerName string
ArenaTeamUninviteByName = function(playerName) end

ArenaTeamDisband = function() end

DeclineArenaTeam = function() end

---@param index number
---@return string, string, number, number, number, number, number, number, number
GetArenaTeam = function(index) return "", "", 0, 0, 0, 0, 0, 0, 0 end

GetArenaTeamGdfInf = function() end

---@param index number
---@param member number
---@return string, string, number, number, number, number, number, number, number
GetArenaTeamRosterInfo = function(index, member) return "", "", 0, 0, 0, 0, 0, 0, 0 end

---@param index number
---@return number, number, number, number, number, number, number, number
GetBattlefieldTeamInfo = function(index) return 0, 0, 0, 0, 0, 0, 0, 0 end

GetCurrentArenaSeason = function() end

---@param unit string
---@return string, string, number, number, number, number, number, number, number
GetInspectArenaTeamData = function(unit) return "", "", 0, 0, 0, 0, 0, 0, 0 end

---@param index number
---@return number
GetNumArenaTeamMembers = function(index) return 0 end

GetPreviousArenaSeason = function() end

IsActiveBattlefieldArena = function() end

IsArenaTeamCaptain = function() end

IsInArenaTeam = function() end

---@param duration number
---@param itemCount number
---@param stackSize number
---@return number
CalculateAuctionDeposit = function(duration, itemCount, stackSize) return 0 end

CanCancelAuction = function() end

CancelSell = function() end

CanSendAuctionQuery = function() end

---@param index number
CancelAuction = function(index) end

ClickAuctionSellItemButton = function() end

CloseAuctionHouse = function() end

---@return number
GetAuctionHouseDepositRate = function() return 0 end

GetAuctionInvTypes = function() end

GetAuctionItemClasses = function() end

---@param list number
---@param index number
---@return string, string, number, number, number, number, number, number, number, number, number
GetAuctionItemInfo = function(list, index) return "", "", 0, 0, 0, 0, 0, 0, 0, 0, 0 end

---@param list number
---@param index number
---@return string
GetAuctionItemLink = function(list, index) return "" end

GetAuctionItemSubClasses = function() end

---@param list number
---@param index number
---@return number
GetAuctionItemTimeLeft = function(list, index) return 0 end

---@return string, string, number, number, number, number, number, number, number, number, number
GetAuctionSellItemInfo = function() return "", "", 0, 0, 0, 0, 0, 0, 0, 0, 0 end

---@param index number
---@return string, string, number, number, number, number, number, number, number, number, number
GetBidderAuctionItems = function(index) return "", "", 0, 0, 0, 0, 0, 0, 0, 0, 0 end

---@param list number
---@return number
GetNumAuctionItems = function(list) return 0 end

---@param index number
---@return string, string, number, number, number, number, number, number, number, number, number
GetOwnerAuctionItems = function(index) return "", "", 0, 0, 0, 0, 0, 0, 0, 0, 0 end

---@param list number
---@return number
GetSelectedAuctionItem = function(list) return 0 end

---@return boolean
IsAuctionSortReversed = function() return true end

---@param list number
---@param index number
---@param bid number
PlaceAuctionBid = function(list, index, bid) end

---@param name string
---@param minLevel number
---@param maxLevel number
---@param page number
---@param isUsable boolean
---@param qualityIndex number
---@param getAll boolean
---@param exactMatch boolean
QueryAuctionItems = function(name, minLevel, maxLevel, page, isUsable, qualityIndex, getAll, exactMatch) end

---@param show boolean
SetAuctionsTabShowing = function(show) end
---@param list number
---@param index number
SetSelectedAuctionItem = function(list, index) end

---@param list string
---@param sort string
SortAuctionItems = function(list, sort) end

---@param minBid number
---@param buyoutPrice number
---@param runTime number
StartAuction = function(minBid, buyoutPrice, runTime) end

---@param buttonID number
---@return number
BankButtonIDToInvSlotID = function(buttonID) return 0 end

CloseBankFrame = function() end

---@return number
GetBankSlotCost = function() return 0 end

---@return number
GetNumBankSlots = function() return 0 end

---@param numSlots number
PurchaseSlot = function(numSlots) end

AcceptAreaSpiritHeal = function() end

---@param accept boolean
AcceptBattlefieldPort = function(accept) end

CancelAreaSpiritHeal = function() end

---@return boolean
CanJoinBattlefieldAsGroup = function() return true end

---@return boolean
CheckSpiritHealerDist = function() return true end

---@return number
GetAreaSpiritHealerTime = function() return 0 end

---@return number
GetBattlefieldEstimatedWaitTime = function() return 0 end

---@return number, number
GetBattlefieldFlagPosition = function() return 0, 0 end

---@return number
GetBattlefieldInstanceExpiration = function() return 0 end

---@return number
GetBattlefieldInstanceRunTime = function() return 0 end

---@return number
GetBattlefieldMapIconScale = function() return 0 end

---@return number
GetBattlefieldPortExpiration = function() return 0 end

---@return number, number
GetBattlefieldPosition = function() return 0, 0 end

---@return number, number, number, number, number, number, number, number, number, number, number
GetBattlefieldScore = function() return 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 end

---@return number, number, number
GetBattlefieldStatData = function() return 0, 0, 0 end

---@return string, string
GetBattlefieldStatInfo = function() return "", "" end

---@return number, string, number, number, number, number, number, number, number, number, number
GetBattlefieldStatus = function() return 0, "", 0, 0, 0, 0, 0, 0, 0, 0, 0 end

---@return number
GetBattlefieldTimeWaited = function() return 0 end

---@return number
GetBattlefieldWinner = function() return 0 end

---@return string, string, number, number, number, number, number, number, number, number, number
GetBattlegroundInfo = function() return "", "", 0, 0, 0, 0, 0, 0, 0, 0, 0 end

---@return number
GetNumBattlefieldFlagPositions = function() return 0 end

---@return number
GetNumBattlefieldPositions = function() return 0 end

---@return number
GetNumBattlefieldScores = function() return 0 end

GetNumBattlefieldStats = function() end

GetNumWorldStateUI = function() end

GetWintergraspWaitTime = function() end

---@param index number
GetWorldStateUIInfo = function(index) end

IsPVPTimerRunning = function() end

---@param index number
---@param asGroup boolean
JoinBattlefield = function(index, asGroup) end

LeaveBattlefield = function() end

---@param player string
ReportPlayerIsPVPAFK = function(player) end

RequestBattlefieldPositions = function() end

RequestBattlefieldScoreData = function() end

RequestBattlegroundInstanceInfo = function() end

---@param faction number
SetBattlefieldScoreFaction = function(faction) end

---@param index number
---@return string, string, string
GetBinding = function(index) return "", "", "" end

---@param action string
---@return string
GetBindingAction = function(action) return "" end

---@param binding string
---@return string
GetBindingKey = function(binding) return "" end

---@param binding string
---@return string
GetBindingText = function(binding) return "" end

---@return number, number
GetCurrentBindingSet = function() return 0, 0 end

GetNumBindings = function() return 0 end

---@param which number
LoadBindings = function(which) end

---@param binding string
RunBinding = function(binding) end

---@param which number
SaveBindings = function(which) end

---@param key string
---@param command string
SetBinding = function(key, command) end

---@param key string
---@param spell string
SetBindingSpell = function(key, spell) end

---@param key string
---@param button string
SetBindingClick = function(key, button) end

---@param key string
---@param item string
SetBindingItem = function(key, item) end

---@param key string
---@param macro string
SetBindingMacro = function(key, macro) end

---@param key string
SetConsoleKey = function(key) end

---@param key string
---@param command string
SetOverrideBinding = function(key, command) end

---@param key string
---@param spell string
SetOverrideBindingSpell = function(key, spell) end

---@param key string
---@param button string
SetOverrideBindingClick = function(key, button) end

---@param key string
---@param item string
SetOverrideBindingItem = function(key, item) end

---@param key string
---@param macro string
SetOverrideBindingMacro = function(key, macro) end

ClearOverrideBindings = function() end

---@param key string
SetMouselookOverrideBinding = function(key) end

---@return boolean
IsModifierKeyDown = function() return true end
---@param action string
---@return boolean
IsModifiedClick = function(action) return true end

---@param button string
---@return boolean
IsMouseButtonDown = function(button) return true end

---@param unit string
---@param index number
CancelUnitBuff = function(unit, index) end

CancelShapeshiftForm = function() end

---@param slot number
CancelItemTempEnchantment = function(slot) end

---@return boolean, number, number, number, number
GetWeaponEnchantInfo = function() return true, 0, 0, 0, 0 end

---@param unit string
---@param index number
---@return string, string, string, number, number, number, string, number, string
UnitAura = function(unit, index) return "", "", "", 0, 0, 0, "", 0, "" end

---@param unit string
---@param index number
---@return string, string, string, number, number, number, string, number, string
UnitBuff = function(unit, index) return "", "", "", 0, 0, 0, "", 0, "" end

---@param unit string
---@param index number
---@return string, string, string, number, number, number, string, number, string
UnitDebuff = function(unit, index) return "", "", "", 0, 0, 0, "", 0, "" end

---@param index number
---@param name string
AddChatWindowChannel = function(index, name) end
---@param channel string
---@param player string
ChannelBan = function(channel, player) end

---@param channel string
---@param player string
ChannelInvite = function(channel, player) end

---@param channel string
---@param player string
ChannelKick = function(channel, player) end

---@param channel string
---@param player string
ChannelModerator = function(channel, player) end

---@param channel string
---@param player string
ChannelMute = function(channel, player) end

---@param channel string
ChannelToggleAnnouncements = function(channel) end

---@param channel string
---@param player string
ChannelUnban = function(channel, player) end

---@param channel string
---@param player string
ChannelUnmoderator = function(channel, player) end

---@param channel string
---@param player string
ChannelUnmute = function(channel, player) end

---@param channel string
DisplayChannelOwner = function(channel) end

DeclineInvite = function() end

---@return table
EnumerateServerChannels = function() return {} end

---@return table
GetChannelList = function() return {} end

---@param channel string
---@return string
GetChannelName = function(channel) return "" end

---@return table
GetChatWindowChannels = function() return {} end

---@param channel string
JoinChannelByName = function(channel) end

---@param channel string
LeaveChannelByName = function(channel) end

---@param channel string
---@return table
ListChannelByName = function(channel) return {} end

---@return table
ListChannels = function() return {} end

---@param index number
RemoveChatWindowChannel = function(index) end

---@param msg string
---@param chatType string
---@param languageId number
---@param channel string
SendChatMessage = function(msg, chatType, languageId, channel) end

---@param channel string
---@param newOwner string
SetChannelOwner = function(channel, newOwner) end

---@param channel string
---@param password string
SetChannelPassword = function(channel, password) end

AcceptResurrect = function() end

AcceptXPLoss = function() end

CheckBinderDist = function() end

ConfirmBinder = function() end

DeclineResurrect = function() end

---@param totemType number
DestroyTotem = function(totemType) end

---@return string
GetBindLocation = function() return "" end

---@param unit string
---@return number
GetComboPoints = function(unit) return 0 end

---@return number
GetCorpseRecoveryDelay = function() return 0 end

---@return number
GetCurrentTitle = function() return 0 end

---@param timerIndex number
---@return string, number, number, boolean
GetMirrorTimerInfo = function(timerIndex) return "", 0, 0, true end

---@param timerIndex number
---@return number
GetMirrorTimerProgress = function(timerIndex) return 0 end

---@return number
GetMoney = function() return 0 end

---@return number
GetNumTitles = function() return 0 end

---@return number
GetPlayerFacing = function() return 0 end

---@return boolean
GetPVPDesired = function() return true end

---@return number
GetReleaseTimeRemaining = function() return 0 end

---@return number
GetResSicknessDuration = function() return 0 end

---@return number, string, boolean
GetRestState = function() return 0, "", true end

---@param runeIndex number
---@return number, number
GetRuneCooldown = function(runeIndex) return 0, 0 end

---@param runeIndex number
---@return number
GetRuneCount = function(runeIndex) return 0 end

---@param runeIndex number
---@return number
GetRuneType = function(runeIndex) return 0 end

---@return number
GetTimeToWellRested = function() return 0 end

---@param titleId number
---@return string
GetTitleName = function(titleId) return "" end

---@param unit string
---@return number
GetUnitPitch = function(unit) return 0 end

---@return number
GetXPExhaustion = function() return 0 end

---@return boolean
HasFullControl = function() return true end

---@return string
HasSoulstone = function() return "" end

---@return boolean
IsFalling = function() return true end

---@return boolean
IsFlying = function() return true end

---@return boolean
IsFlyableArea = function() return true end

---@return boolean
IsIndoors = function() return true end

---@return boolean
IsMounted = function() return true end

---@return boolean
IsOutdoors = function() return true end

---@return boolean
IsOutOfBounds = function() return true end

---@return boolean
IsResting = function() return true end

---@return boolean
IsStealthed = function() return true end

---@return boolean
IsSwimming = function() return true end

---@param titleId number
---@return boolean
IsTitleKnown = function(titleId) return true end

---@return boolean
IsXPUserDisabled = function() return true end

NotWhileDeadError = function() end

---@return boolean
ResurrectHasSickness = function() return true end

---@return boolean
ResurrectHasTimer = function() return true end

---@return string
ResurrectGetOfferer = function() return "" end

RetrieveCorpse = function() end

SetCurrentTitle = function() end

TargetTotem = function() end

---@return number
GetArmorPenetration = function() return 0 end

---@param statId number
---@return number
GetAttackPowerForStat = function(statId) return 0 end

---@return number
GetAverageItemLevel = function() return 0 end

---@return number
GetBlockChance = function() return 0 end

---@param combatRatingIdentifier number
---@return number
GetCombatRating = function(combatRatingIdentifier) return 0 end

---@return number
GetCombatRatingBonus = function() return 0 end

---@return number
GetCritChance = function() return 0 end

---@param unitId string
---@return number
GetCritChanceFromAgility = function(unitId) return 0 end

---@return number
GetDodgeChance = function() return 0 end

---@return number
GetExpertise = function() return 0 end

---@return number
GetExpertisePercent = function() return 0 end

---@return number
GetManaRegen = function() return 0 end

---@return number
GetMaxCombatRatingBonus = function() return 0 end

---@return number
GetParryChance = function() return 0 end

---@return number
GetPetSpellBonusDamage = function() return 0 end

---@return number
GetPowerRegen = function() return 0 end

---@param school number
---@return number
GetSpellBonusDamage = function(school) return 0 end

---@return number
GetRangedCritChance = function() return 0 end

---@return number
GetSpellBonusHealing = function() return 0 end

---@return number
GetSpellCritChance = function() return 0 end

---@return number
GetShieldBlock = function() return 0 end

---@return number
GetSpellCritChanceFromIntellect = function() return 0 end

---@return number
GetSpellPenetration = function() return 0 end

---@param index number
---@param channelName string
AddChatWindowChannel = function(index, channelName) end

---@param type string
---@param red number
---@param green number
---@param blue number
ChangeChatColor = function(type, red, green, blue) end

---@param frame string
---@param channelName string
ChatFrame_AddChannel = function(frame, channelName) end

---@param event string
---@param filterFunc function
ChatFrame_AddMessageEventFilter = function(event, filterFunc) end

---@return table
ChatFrame_GetMessageEventFilters = function() return {} end

---@param frame string
---@param link string
---@param text string
---@param button string
ChatFrame_OnHyperlinkShow = function(frame, link, text, button) end

---@param event string
---@param filterFunc function
ChatFrame_RemoveMessageEventFilter = function(event, filterFunc) end

---@return table
GetAutoCompleteResults = function() return {} end

---@param chatType string
---@return number
GetChatTypeIndex = function(chatType) return 0 end

---@param windowId number
---@return table
GetChatWindowChannels = function(windowId) return {} end

---@param windowId number
---@return string
GetChatWindowInfo = function(windowId) return "" end

---@param windowId number
---@return table
GetChatWindowMessages = function(windowId) return {} end

---@param channelName string
JoinChannelByName = function(channelName) end

LoggingChat = function() end

LoggingCombat = function() end

---@param index number
---@return boolean
RemoveChatWindowChannel = function(index) return true end

---@param index number
---@param message string
---@return boolean
RemoveChatWindowMessages = function(index, message) return true end

---@param index number
---@param alpha number
---@return boolean
SetChatWindowAlpha = function(index, alpha) return true end

---@param index number
---@param red number
---@param green number
---@param blue number
---@return boolean
SetChatWindowColor = function(index, red, green, blue) return true end

---@param index number
---@param docked boolean
---@return boolean
SetChatWindowDocked = function(index, docked) return true end

---@param index number
---@param locked boolean
---@return boolean
SetChatWindowLocked = function(index, locked) return true end

---@param index number
---@param name string
---@return boolean
SetChatWindowName = function(index, name) return true end

---@param index number
---@param shown boolean
---@return boolean
SetChatWindowShown = function(index, shown) return true end

---@param index number
---@param size number
---@return boolean
SetChatWindowSize = function(index, size) return true end

---@param index number
---@param uninteractable boolean
---@return boolean
SetChatWindowUninteractable = function(index, uninteractable) return true end

---@param token string
---@param unit string?
---@param hold boolean?
DoEmote = function(token, unit, hold) end

---@return string
GetDefaultLanguage = function() return "" end

---@param index number
---@return string
GetLanguageByIndex = function(index) return "" end

---@return number
GetNumLanguages = function() return 0 end

---@return table
GetRegisteredAddonMessagePrefixes = function() return {} end

---@param prefix string
---@return boolean
IsAddonMessagePrefixRegistered = function(prefix) return true end

---@param prefix string
RegisterAddonMessagePrefix = function(prefix) end

---@param prefix string
---@param message string
---@param channel string
---@param target string
---@param priority string
---@return boolean
SendAddonMessage = function(prefix, message, channel, target, priority) return true end

---@param message string
---@param chatType string
---@param language string
---@param target string
---@param target2 string
---@param channel number
---@param target3 string
---@param unknown1 number
---@param unknown2 number
---@param unknown3 number
---@return boolean
SendChatMessage = function(message, chatType, language, target, target2, channel, target3, unknown1, unknown2, unknown3) return true end

---@param index number
CallCompanion = function(index) end

---@param index number
DismissCompanion = function(index) end

---@param index number
---@return string, string, string, number, boolean
GetCompanionInfo = function(index) return "", "", "", 0, true end

---@return number
GetNumCompanions = function() return 0 end

---@param index number
---@return number, number, number, number
GetCompanionCooldown = function(index) return 0, 0, 0, 0 end

---@param index number
PickupCompanion = function(index) end

---@return boolean
SummonRandomCritter = function() return true end

---@param bagID number
---@param slot number
---@return number
ContainerIDToInventoryID = function(bagID, slot) return 0 end

---@param bagID number
---@return string
GetBagName = function(bagID) return "" end

---@param bagID number
---@param slot number
---@return number, number
GetContainerItemCooldown = function(bagID, slot) return 0, 0 end

---@param bagID number
---@param slot number
---@return number, number, number, number
GetContainerItemDurability = function(bagID, slot) return 0, 0, 0, 0 end

---@param bagID number
---@param slot number
---@return table
GetContainerItemGems = function(bagID, slot) return {} end

---@param bagID number
---@param slot number
---@return number
GetContainerItemID = function(bagID, slot) return 0 end

---@param bagID number
---@param slot number
---@return string, string, number, number, boolean, boolean
GetContainerItemInfo = function(bagID, slot) return "", "", 0, 0, true, true end

---@param bagID number
---@param slot number
---@return string
GetContainerItemLink = function(bagID, slot) return "" end

---@param bagID number
---@return number
GetContainerNumSlots = function(bagID) return 0 end

---@param bagID number
---@param slot number
---@return string, boolean
GetContainerItemQuestInfo = function(bagID, slot) return "", true end

---@param bagID number
---@return number
GetContainerNumFreeSlots = function(bagID) return 0 end

OpenAllBags = function() end

CloseAllBags = function() end

---@param slot number
PickupBagFromSlot = function(slot) end

---@param bagID number
---@param slot number
PickupContainerItem = function(bagID, slot) end

PutItemInBackpack = function() end

---@param bagID number
PutItemInBag = function(bagID) end

PutKeyInKeyRing = function() end

---@param bagID number
---@param slot number
---@param split number
SplitContainerItem = function(bagID, slot, split) end

ToggleBackpack = function() end

---@param bagID number
ToggleBag = function(bagID) end

---@param money number
---@param separator string
---@return string
GetCoinText = function(money, separator) return "" end

---@param money number
---@param highlight boolean
---@return string
GetCoinTextureString = function(money, highlight) return "" end

---@param index number
---@return string, number, boolean, boolean, boolean, boolean, boolean
GetCurrencyInfo = function(index) return "", 0, true, true, true, true, true end

---@return number
GetCurrencyListSize = function() return 0 end

---@param index number
---@return string, number, number, boolean
GetCurrencyListInfo = function(index) return "", 0, 0, true end

ExpandCurrencyList = function() end

SetCurrencyUnused = function(index) end

---@return number
GetNumWatchedTokens = function() return 0 end

---@param currencyType number
---@return string, number, number, number, number, number
GetBackpackCurrencyInfo = function(currencyType) return "", 0, 0, 0, 0, 0 end

---@param currencyType number
---@param backpack boolean
SetCurrencyBackpack = function(currencyType, backpack) end

AutoEquipCursorItem = function() end

ClearCursor = function() end

---@param bag number
---@param slot number
---@return boolean
CursorCanGoInSlot = function(bag, slot) return true end

---@return boolean
CursorHasItem = function() return true end

---@return boolean
CursorHasMoney = function() return true end

---@return boolean
CursorHasSpell = function() return true end
DeleteCursorItem = function() end

---@param amount number
DropCursorMoney = function(amount) end

---@param unit string
DropItemOnUnit = function(unit) end

EquipCursorItem = function() end

---@return string, string, number
GetCursorInfo = function() return "", "", 0 end

---@return number, number
GetCursorPosition = function() return 0, 0 end

HideRepairCursor = function() end

---@return boolean
InRepairMode = function() return true end

---@param slot number
PickupAction = function(slot) end

---@param slot number
PickupBagFromSlot = function(slot) end

---@param bagID number
---@param slot number
PickupContainerItem = function(bagID, slot) end

---@param unit string
---@param slot number
PickupInventoryItem = function(unit, slot) end

---@param itemName string
PickupItem = function(itemName) end

---@param macroIndex number
PickupMacro = function(macroIndex) end

---@param index number
PickupMerchantItem = function(index) end

---@param slot number
PickupPetAction = function(slot) end

---@param spellSlot number
PickupSpell = function(spellSlot) end

---@param index number
PickupStablePet = function(index) end

PickupTradeMoney = function() end

---@param slotID number
PlaceAction = function(slotID) end

PutItemInBackpack = function() end

---@param bagID number
PutItemInBag = function(bagID) end

ResetCursor = function() end

---@param itemID number
SetCursor = function(itemID) end

ShowContainerSellCursor = function() end

ShowInspectCursor = function() end

ShowInventorySellCursor = function() end

ShowMerchantSellCursor = function() end

ShowRepairCursor = function() end

---@param bagID number
---@param slot number
---@param split number
SplitContainerItem = function(bagID, slot, split) end

---@param weaponHand number
---@return string, string, number, string
GetWeaponEnchantInfo = function(weaponHand) return "", "", 0, "" end

---@param index number
ReplaceEnchant = function(index) end

---@param index number
ReplaceTradeEnchant = function(index) end

---@param index number
BindEnchant = function(index) end

---@param factionIndex number
CollapseFactionHeader = function(factionIndex) end

CollapseAllFactionHeaders = function() end

---@param factionIndex number
ExpandFactionHeader = function(factionIndex) end

ExpandAllFactionHeaders = function() end

---@param factionIndex number
FactionToggleAtWar = function(factionIndex) end

---@param index number
---@return string, number, number, number, number, number, number, number, number, number, number, number, number, number, number, number
GetFactionInfo = function(index) return "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 end

---@return number
GetNumFactions = function() return 0 end

---@return number
GetSelectedFaction = function() return 0 end

---@return string, number, number, number, number, boolean, boolean
GetWatchedFactionInfo = function() return "", 0, 0, 0, 0, true, true end

---@param factionIndex number
---@return boolean
IsFactionInactive = function(factionIndex) return true end

---@param factionIndex number
SetFactionActive = function(factionIndex) end

---@param factionIndex number
SetFactionInactive = function(factionIndex) end

---@param factionIndex number
SetSelectedFaction = function(factionIndex) end

---@param factionIndex number
SetWatchedFactionIndex = function(factionIndex) end

---@param unit string
---@return string, number
UnitFactionGroup = function(unit) return "", 0 end

---@param frameType string
---@param name string | nil
---@param parent table | nil
---@param template string | nil
---@return table
CreateFrame = function(frameType, name, parent, template) return {} end

---@param fontName string
---@param fontHeight number
---@param fontFlags string | nil
---@return table
CreateFont = function(fontName, fontHeight, fontFlags) return {} end

---@param eventName string
---@return table
GetFramesRegisteredForEvent = function(eventName) return {} end

---@return number
GetNumFrames = function() return 0 end

---@return table
EnumerateFrames = function() return {} end

---@return table
GetMouseFocus = function() return {} end

---@param level number
---@param menuFrame table
---@param anchor table
---@param x number
---@param y number
---@param displayMode string | nil
---@param autoHideDelay number | nil
ToggleDropDownMenu = function(level, menuFrame, anchor, x, y, displayMode, autoHideDelay) end

---@param frame table
---@param fadeInTime number
---@param startAlpha number
---@param endAlpha number
UIFrameFadeIn = function(frame, fadeInTime, startAlpha, endAlpha) end

---@param frame table
---@param fadeOutTime number
---@param startAlpha number
---@param endAlpha number
UIFrameFadeOut = function(frame, fadeOutTime, startAlpha, endAlpha) end

---@param frame table
---@param fadeInTime number
---@param fadeOutTime number
---@param flashDuration number
---@param showWhenDone boolean
---@param flashInHoldTime number | nil
---@param flashOutHoldTime number | nil
UIFrameFlash = function(frame, fadeInTime, fadeOutTime, flashDuration, showWhenDone, flashInHoldTime, flashOutHoldTime) end

---@param menuList table
---@param menuFrame table | nil
---@param anchor table | nil
---@param x number | nil
---@param y number | nil
---@param displayMode string | nil
---@param autoHideDelay number | nil
EasyMenu = function(menuList, menuFrame, anchor, x, y, displayMode, autoHideDelay) end

---@param name string
AddFriend = function(name) end

---@param name string
AddOrRemoveFriend = function(name) end

---@param index number
---@return string, string, number, number, boolean, boolean, boolean
GetFriendInfo = function(index) return "", "", 0, 0, true, true, true end

---@param friendName string
---@param notes string
SetFriendNotes = function(friendName, notes) end

---@return number
GetNumFriends = function() return 0 end

---@return number
GetSelectedFriend = function() return 0 end

---@param name string
RemoveFriend = function(name) end

---@param index number
SetSelectedFriend = function(index) end

ShowFriends = function() end

ToggleFriendsFrame = function() end

---@param index number
---@return number
GetNumGlyphSockets = function(index) return 0 end

---@param index number
---@return string, string, number
GetGlyphSocketInfo = function(index) return "", "", 0 end

---@param index number
---@return string
GetGlyphLink = function(index) return "" end

---@param glyphID number
---@param socketID number
---@return boolean
GlyphMatchesSocket = function(glyphID, socketID) return true end

---@param glyphID number
---@param socketID number
PlaceGlyphInSocket = function(glyphID, socketID) end
---@param socketID number
RemoveGlyphFromSocket = function(socketID) end

---@param spellID number
---@return boolean
SpellCanTargetGlyph = function(spellID) return true end

CanComplainChat = function() end

---@param index number
---@return boolean
CanComplainInboxItem = function(index) return true end

---@param chatID number
ComplainChat = function(chatID) end

---@param mailID number
ComplainInboxItem = function(mailID) end

CloseGossip = function() end

---@param npcID number
ForceGossip = function(npcID) end

---@return table
GetGossipActiveQuests = function() return {} end

---@return table
GetGossipAvailableQuests = function() return {} end

---@return table
GetGossipOptions = function() return {} end

---@return string
GetGossipText = function() return "" end

---@return number
GetNumGossipActiveQuests = function() return 0 end

---@return number
GetNumGossipAvailableQuests = function() return 0 end

---@return number
GetNumGossipOptions = function() return 0 end

---@param questIndex number
SelectGossipActiveQuest = function(questIndex) end

---@param questIndex number
SelectGossipAvailableQuest = function(questIndex) end

---@param optionIndex number
SelectGossipOption = function(optionIndex) end

AcceptGroup = function() end

ConfirmReadyCheck = function() end

ConvertToRaid = function() end

DeclineGroup = function() end

DoReadyCheck = function() end

---@return string, string
GetLootMethod = function() return "", "" end

---@return number
GetLootThreshold = function() return 0 end

---@param index number
---@return string, string
GetMasterLootCandidate = function(index) return "", "" end

---@return number
GetNumPartyMembers = function() return 0 end

---@return number
GetRealNumPartyMembers = function() return 0 end

---@return number
GetPartyLeaderIndex = function() return 0 end

---@param unit string
---@return string, string, string, string, number, number
GetPartyMember = function(unit) return "", "", "", "", 0, 0 end

---@param unit string
InviteUnit = function(unit) end

---@param unit string
---@return boolean
IsPartyLeader = function(unit) return true end

LeaveParty = function() end

---@param unit string
PromoteToLeader = function(unit) end

---@param method string
---@param masterUnit string | nil
SetLootMethod = function(method, masterUnit) end

---@param threshold string
SetLootThreshold = function(threshold) end

---@param unit string
UninviteUnit = function(unit) end

---@param unit string
---@return boolean
UnitInParty = function(unit) return true end

---@param unit string
---@return boolean
UnitIsPartyLeader = function(unit) return true end

AcceptGuild = function() end

BuyGuildCharter = function() end

---@return boolean
CanEditGuildEvent = function() return true end

---@return boolean
CanEditGuildInfo = function() return true end

---@return boolean
CanEditMOTD = function() return true end

---@return boolean
CanEditOfficerNote = function() return true end

---@return boolean
CanEditPublicNote = function() return true end

---@param unit string
---@return boolean
CanGuildDemote = function(unit) return true end

---@param unit string
---@return boolean
CanGuildInvite = function(unit) return true end

---@param unit string
---@return boolean
CanGuildPromote = function(unit) return true end

---@param unit string
---@return boolean
CanGuildRemove = function(unit) return true end

---@return boolean
CanViewOfficerNote = function() return true end

CloseGuildRegistrar = function() end

CloseGuildRoster = function() end

CloseTabardCreation = function() end

DeclineGuild = function() end

---@return number
GetGuildCharterCost = function() return 0 end

---@param index number
---@return string, string, number, number, number, boolean, boolean, string, string
GetGuildEventInfo = function(index) return "", "", 0, 0, 0, true, true, "", "" end

---@param unit string
---@return string, string, number, number, number, number, string, string, number, string
GetGuildInfo = function(unit) return "", "", 0, 0, 0, 0, "", "", 0, "" end

---@return string
GetGuildInfoText = function() return "" end

---@param index number
---@return string, string, string, number, number, string, string, string, string, boolean, string, number, boolean, boolean
GetGuildRosterInfo = function(index) return "", "", "", 0, 0, "", "", "", "", true, "", 0, true, true end

---@param index number
---@return number
GetGuildRosterLastOnline = function(index) return 0 end

---@return string
GetGuildRosterMOTD = function() return "" end

---@return number
GetGuildRosterSelection = function() return 0 end

---@return boolean
GetGuildRosterShowOffline = function() return true end

---@return number
GetNumGuildEvents = function() return 0 end

---@return number
GetNumGuildMembers = function() return 0 end

---@return number
GetTabardCreationCost = function() return 0 end

---@return string, string, number, number
GetTabardInfo = function() return "", "", 0, 0 end

---@param rankName string
GuildControlAddRank = function(rankName) end

---@param rankOrder number
GuildControlDelRank = function(rankOrder) end

---@return number
GuildControlGetNumRanks = function() return 0 end

---@param rankOrder number
---@return boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean
GuildControlGetRankFlags = function(rankOrder) return true, true, true, true, true, true, true, true end

---@param rankOrder number
---@return string
GuildControlGetRankName = function(rankOrder) return "" end

GuildControlSaveRank = function() end

---@param rankOrder number
---@param rankName string
GuildControlSetRank = function(rankOrder, rankName) end

---@param rankOrder number
---@param enabled boolean
---@param allow boolean
---@param memberNote boolean
---@param officerNote boolean
---@param viewOfficerNote boolean
---@param editOfficerNote boolean
---@param invite boolean
---@param remove boolean
---@param promote boolean
---@param demote boolean
---@param speakInGuildChat boolean
---@param inviteRecruit boolean
GuildControlSetRankFlag = function(rankOrder, enabled, allow, memberNote, officerNote, viewOfficerNote, editOfficerNote, invite, remove, promote, demote, speakInGuildChat, inviteRecruit) end

---@param unit string
---@param rankOrder number
GuildDemote = function(unit, rankOrder) end

GuildDisband = function() end

---@param unit string
GuildInfo = function(unit) end

---@param unit string
GuildInvite = function(unit) end

GuildLeave = function() end

---@param unit string
GuildPromote = function(unit) end

GuildRoster = function() end

---@param unit string
---@param officerNote string
GuildRosterSetOfficerNote = function(unit, officerNote) end

---@param unit string
---@param publicNote string
GuildRosterSetPublicNote = function(unit, publicNote) end

---@param motd string
GuildSetMOTD = function(motd) end

---@param unit string
GuildSetLeader = function(unit) end

---@param unit string
GuildUninvite = function(unit) end

---@param unit string
---@return boolean
IsGuildLeader = function(unit) return true end

---return true if the player is in a guild
---@return boolean
IsInGuild = function() return true end

---@param eventIndex number
QueryGuildEventLog = function(eventIndex) end

---@param text string
SetGuildInfoText = function(text) end

---@param index number
SetGuildRosterSelection = function(index) end

---@param showOffline boolean
SetGuildRosterShowOffline = function(showOffline) end

SortGuildRoster = function() end

---@param unit string
---@return number
UnitGetGuildXP = function(unit) return 0 end

---@param tab number
---@param index number
AutoStoreGuildBankItem = function(tab, index) end

BuyGuildBankTab = function() end

---@return boolean
CanGuildBankRepair = function() return true end

---@return boolean
CanWithdrawGuildBankMoney = function() return true end

CloseGuildBankFrame = function() end

---@param amount number
DepositGuildBankMoney = function(amount) end

---@return number
GetCurrentGuildBankTab = function() return 0 end

---@param tab number
---@param slot number
---@return string, string, number, number
GetGuildBankItemInfo = function(tab, slot) return "", "", 0, 0 end

---@param tab number
---@param slot number
---@return string
GetGuildBankItemLink = function(tab, slot) return "" end

---@return number
GetGuildBankMoney = function() return 0 end

---@param transactionIndex number
---@return number, string, number
GetGuildBankMoneyTransaction = function(transactionIndex) return 0, "", 0 end

---@return number
GetGuildBankTabCost = function() return 0 end

---@param tab number
---@return number, string, string, number, number
GetGuildBankTabInfo = function(tab) return 0, "", "", 0, 0 end

---@param tab number
---@param index number
---@return boolean, boolean
GetGuildBankTabPermissions = function(tab, index) return true, true end

---@return string
GetGuildBankText = function() return "" end

---@param transactionIndex number
---@return string, string, string, number, number, number
GetGuildBankTransaction = function(transactionIndex) return "", "", "", 0, 0, 0 end

---@return string, string
GetGuildTabardFileNames = function() return "", "" end

---@return number
GetNumGuildBankMoneyTransactions = function() return 0 end

---@return number
GetNumGuildBankTabs = function() return 0 end

---@return number
GetNumGuildBankTransactions = function() return 0 end

---@param tab number
---@param slot number
PickupGuildBankItem = function(tab, slot) end

---@param amount number
PickupGuildBankMoney = function(amount) end

---@param logIndex number
QueryGuildBankLog = function(logIndex) end

---@param tab number
QueryGuildBankTab = function(tab) end

---@param tab number
SetCurrentGuildBankTab = function(tab) end

---@param tab number
---@param name string
---@param icon string
---@param isViewable boolean
---@param canDeposit boolean
SetGuildBankTabInfo = function(tab, name, icon, isViewable, canDeposit) end

---@param tab number
---@param index number
---@param viewable boolean
---@param depositable boolean
SetGuildBankTabPermissions = function(tab, index, viewable, depositable) end

---@param itemID number
---@param quantity number
SplitGuildBankItem = function(itemID, quantity) end

---@param amount number
WithdrawGuildBankMoney = function(amount) end

---@return number, number, number
GetHolidayBGHonorCurrencyBonuses = function() return 0, 0, 0 end

---@param unit string
---@return number, number, number, number
GetInspectHonorData = function(unit) return 0, 0, 0, 0 end

---@return number, number, number, number, number
GetPVPLifetimeStats = function() return 0, 0, 0, 0, 0 end

---@param factionIndex number
---@return string, string, number, number, number
GetPVPRankInfo = function(factionIndex) return "", "", 0, 0, 0 end

---@return number, number, number
GetPVPRankProgress = function() return 0, 0, 0 end

---@return number, number, number
GetPVPSessionStats = function() return 0, 0, 0 end

---@return number, number, number
GetPVPYesterdayStats = function() return 0, 0, 0 end

---@return number, number, number
GetRandomBGHonorCurrencyBonuses = function() return 0, 0, 0 end

---@param unit string
---@return boolean
HasInspectHonorData = function(unit) return true end

---@param unit string
RequestInspectHonorData = function(unit) end

---@param unit string
---@param name string
---@return string
UnitPVPName = function(unit, name) return "" end

---@param unit string
---@return number
UnitPVPRank = function(unit) return 0 end

---@param name string
AddIgnore = function(name) end

---@param name string
---@param add boolean
AddOrDelIgnore = function(name, add) end

---@param name string
DelIgnore = function(name) end

---@param index number
---@return string
GetIgnoreName = function(index) return "" end

---@return number
GetNumIgnores = function() return 0 end

---@return number
GetSelectedIgnore = function() return 0 end

---@param index number
SetSelectedIgnore = function(index) end

---@param unit string
---@return boolean
CanInspect = function(unit) return true end

---@param unit string
---@param distIndex number
---@return boolean
CheckInteractDistance = function(unit, distIndex) return true end

ClearInspectPlayer = function() end

---@return string, number, number
GetInspectArenaTeamData = function() return "", 0, 0 end

---@param unit string
---@return boolean
HasInspectHonorData = function(unit) return true end

---@param unit string
RequestInspectHonorData = function(unit) end

---@param unit string
---@return number, number, number, number
GetInspectHonorData = function(unit) return 0, 0, 0, 0 end

---@param unit string
NotifyInspect = function(unit) end

---@param unit string
InspectUnit = function(unit) end

CanShowResetInstances = function() end

---@param talentId number
---@param specGroupIndex number?
---@param isInspect  boolean?
---@param inspectUnit string?
---@return number talentID
---@return string talentName
---@return number icon
---@return boolean selected
---@return boolean available
---@return number spellID
---@return boolean unlocked
---@return number row
---@return number column
---@return boolean known
---@return boolean grantedByAura
GetPvpTalentInfoByID = function(talentId, specGroupIndex, isInspect, inspectUnit) return 0, "", 0, true, true, 0, true, 0, 0, true, true end

---@param index number
---@return number
GetBattlefieldInstanceExpiration = function(index) return 0 end

---@param index number
---@return string, string, number, number, number, number, boolean, boolean, boolean, boolean, boolean
GetBattlefieldInstanceInfo = function(index) return "", "", 0, 0, 0, 0, true, true, true, true, true end

---@return number, number
GetBattlefieldInstanceRunTime = function() return 0, 0 end

---@return number
GetInstanceBootTimeRemaining = function() return 0 end

---retrive information about the zone the player is in
---@return string name
---@return string instanceType
---@return number difficultyID
---@return string difficultyName
---@return number maxPlayers
---@return number dynamicDifficulty
---@return boolean isDynamic
---@return number instanceID
---@return number instanceGroupSize
---@return number LfgDungeonID
GetInstanceInfo = function() return "", "", 0, "", 0, 0, true, 0, 0, 0 end

---@return number
GetNumSavedInstances = function() return 0 end

---@param index number
---@return string, string, number, boolean, boolean, boolean, boolean, number, boolean
GetSavedInstanceInfo = function(index) return "", "", 0, true, true, true, true, 0, true end

---@return boolean bInsideInstance
---@return string instancetype
IsInInstance = function() return true, "" end

ResetInstances = function() end

---@return number, number
GetDungeonDifficulty = function() return 0, 0 end

---@param difficulty number
SetDungeonDifficulty = function(difficulty) end

---@return number
GetInstanceDifficulty = function() return 0 end

---@return number
GetInstanceLockTimeRemaining = function() return 0 end

---@return number
GetInstanceLockTimeRemainingEncounter = function() return 0 end

AutoEquipCursorItem = function() end

---@param bankButtonID number
---@return number
BankButtonIDToInvSlotID = function(bankButtonID) return 0 end

CancelPendingEquip = function() end

ConfirmBindOnUse = function() end

---@param containerID number
---@param slot number
---@return number
ContainerIDToInventoryID = function(containerID, slot) return 0 end

---@param slotID number
---@param bagID number
---@return boolean
CursorCanGoInSlot = function(slotID, bagID) return true end

EquipCursorItem = function() end

EquipPendingItem = function() end

---@return boolean
GetInventoryAlertStatus = function() return true end

---@param slotID number
---@return boolean
GetInventoryItemBroken = function(slotID) return true end

---@param slotID number
---@return number, number
GetInventoryItemCooldown = function(slotID) return 0, 0 end

---@param slotID number
---@return number
GetInventoryItemCount = function(slotID) return 0 end

---@param slotID number
---@return number, number
GetInventoryItemDurability = function(slotID) return 0, 0 end

---@param slotID number
---@return table
GetInventoryItemGems = function(slotID) return {} end

---@param slotID number
---@return number
GetInventoryItemID = function(slotID) return 0 end

---@param slotID number
---@return string
GetInventoryItemLink = function(slotID) return "" end

---@param slotID number
---@return number
GetInventoryItemQuality = function(slotID) return 0 end

---@param slotID number
---@return string
GetInventoryItemTexture = function(slotID) return "" end

---@param slotName string
---@return string, string, number
GetInventorySlotInfo = function(slotName) return "", "", 0 end

---@return boolean
GetWeaponEnchantInfo = function() return true end

---@return boolean
HasWandEquipped = function() return true end

---@param slotID number
---@return boolean
IsInventoryItemLocked = function(slotID) return true end

---@param keyRingButtonID number
---@return number
KeyRingButtonIDToInvSlotID = function(keyRingButtonID) return 0 end

---@param slotID number
PickupBagFromSlot = function(slotID) end

---@param slotID number
PickupInventoryItem = function(slotID) end

UpdateInventoryAlertStatus = function() end

---@param slotID number
UseInventoryItem = function(slotID) end

---@param itemName string
EquipItemByName = function(itemName) end

---@param index number
---@return string
GetAuctionItemLink = function(index) return "" end

---@param bagID number
---@param slot number
---@return string
GetContainerItemLink = function(bagID, slot) return "" end

---@param slotID number
---@return number, number
GetItemCooldown = function(slotID) return 0, 0 end

---@param itemID number
---@return number
GetItemCount = function(itemID) return 0 end

---@param itemID number
---@return number
GetItemFamily = function(itemID) return 0 end

---@param itemID number
---@return string
GetItemIcon = function(itemID) return "" end

---@param itemID number
---@return string, string, number, number
GetItemInfo = function(itemID) return "", "", 0, 0 end

---@param quality number
---@return table
GetItemQualityColor = function(quality) return {} end

---@param itemID number
---@return string
GetItemSpell = function(itemID) return "" end

---@param itemID number
---@return table
GetItemStats = function(itemID) return {} end

---@param index number
---@return string
GetMerchantItemLink = function(index) return "" end

---@param questID number
---@return string
GetQuestItemLink = function(questID) return "" end

---@param questLogIndex number
---@return string
GetQuestLogItemLink = function(questLogIndex) return "" end

---@param index number
---@return string
GetTradePlayerItemLink = function(index) return "" end

---@param index number
---@return string
GetTradeSkillItemLink = function(index) return "" end

---@param tradeSkillID number
---@param reagentIndex number
---@return string
GetTradeSkillReagentItemLink = function(tradeSkillID, reagentIndex) return "" end

---@param index number
---@return string
GetTradeTargetItemLink = function(index) return "" end

---@param itemNameOrItemID string|number
---@return boolean
IsUsableItem = function(itemNameOrItemID) return true end

---@param itemNameOrItemID string|number
---@return boolean
IsConsumableItem = function(itemNameOrItemID) return true end

---@return boolean
IsCurrentItem = function() return true end

---@param itemNameOrItemID string|number
---@return boolean
IsEquippedItem = function(itemNameOrItemID) return true end

---@param itemNameOrItemID string|number
---@return boolean
IsEquippableItem = function(itemNameOrItemID) return true end

---@param itemID number
---@return boolean
IsEquippedItemType = function(itemID) return true end

---@param unit string
---@param itemID number
---@return boolean
IsItemInRange = function(unit, itemID) return true end

---@param itemNameOrItemID string|number
---@return boolean
ItemHasRange = function(itemNameOrItemID) return true end

---@return boolean
OffhandHasWeapon = function() return true end

---@param bagID number
---@param slot number
---@param quantity number
SplitContainerItem = function(bagID, slot, quantity) end

---@param link string
SetItemRef = function(link) end

AcceptSockets = function() end

---@param socketIndex number
ClickSocketButton = function(socketIndex) end

CloseSocketInfo = function() end

---@param socketIndex number
---@return string, number
GetSocketItemInfo = function(socketIndex) return "", 0 end

---@param socketIndex number
---@return boolean
GetSocketItemRefundable = function(socketIndex) return true end

---@param socketIndex number
---@return boolean
GetSocketItemBoundTradeable = function(socketIndex) return true end

---@return number
GetNumSockets = function() return 0 end

---@return table
GetSocketTypes = function() return {} end

---@param socketIndex number
---@return string, string, number
GetExistingSocketInfo = function(socketIndex) return "", "", 0 end

---@param socketIndex number
---@return string
GetExistingSocketLink = function(socketIndex) return "" end

---@param socketIndex number
---@return string, string, number
GetNewSocketInfo = function(socketIndex) return "", "", 0 end

---@param socketIndex number
---@return string
GetNewSocketLink = function(socketIndex) return "" end

---@param slot number
SocketInventoryItem = function(slot) end

---@param bagID number
---@param slot number
SocketContainerItem = function(bagID, slot) end

CloseItemText = function() end

---@return string
ItemTextGetCreator = function() return "" end

---@return string
ItemTextGetItem = function() return "" end

---@return string
ItemTextGetMaterial = function() return "" end

---@param page number
---@return string
ItemTextGetPage = function(page) return "" end

---@return string
ItemTextGetText = function() return "" end

---@return boolean
ItemTextHasNextPage = function() return true end

ItemTextNextPage = function() end

ItemTextPrevPage = function() end

---@return string
GetMinimapZoneText = function() return "" end

---@return string
GetRealZoneText = function() return "" end

---@return string
GetSubZoneText = function() return "" end

---@return string, boolean, boolean
GetZonePVPInfo = function() return "", true, true end

---@return string
GetZoneText = function() return "" end

CompleteLFGRoleCheck = function() end

---@return number
GetLFGDeserterExpiration = function() return 0 end

---@return number
GetLFGRandomCooldownExpiration = function() return 0 end

---@return number
GetLFGBootProposal = function() return 0 end

---@return string
GetLFGMode = function() return "" end

---@return number, number, number, number, number
GetLFGQueueStats = function() return 0, 0, 0, 0, 0 end

---@return boolean, boolean, boolean, boolean
GetLFGRoles = function() return true, true, true, true end

GetLFGRoleUpdate = function() end

---@param slot number
---@return number
GetLFGRoleUpdateSlot = function(slot) return 0 end

---@param vote number
---@param slot number
SetLFGBootVote = function(vote, slot) end

---@param comment string
SetLFGComment = function(comment) end

---@param tank boolean
---@param healer boolean
---@param dps boolean
SetLFGRoles = function(tank, healer, dps) end

---@param unit string
UninviteUnit = function(unit) end

---@param unit string
---@return string
UnitGroupRolesAssigned = function(unit) return "" end

---@param unit string
---@return boolean
UnitHasLFGDeserter = function(unit) return true end

---@param unit string
---@return boolean
UnitHasLFGRandomCooldown = function(unit) return true end

CloseLoot = function() end

ConfirmBindOnUse = function() end

---@param rollID number
---@param roll number
ConfirmLootRoll = function(rollID, roll) end

---@param slot number
ConfirmLootSlot = function(slot) end

---@return string
GetLootMethod = function() return "" end

---@param index number
---@return string, string, number
GetLootRollItemInfo = function(index) return "", "", 0 end

---@param index number
---@return string
GetLootRollItemLink = function(index) return "" end

---@param index number
---@return number
GetLootRollTimeLeft = function(index) return 0 end

---@param index number
---@return string, string, number
GetLootSlotInfo = function(index) return "", "", 0 end

---@param index number
---@return string
GetLootSlotLink = function(index) return "" end

---@return number
GetLootThreshold = function() return 0 end

---@param index number
---@return string
GetMasterLootCandidate = function(index) return "" end

---@return number
GetNumLootItems = function() return 0 end

---@return boolean
GetOptOutOfLoot = function() return true end

---@param candidate string
---@param index number
GiveMasterLoot = function(candidate, index) end

---@return boolean
IsFishingLoot = function() return true end

---@param slot number
LootSlot = function(slot) end

---@param slot number
---@return boolean
LootSlotIsCoin = function(slot) return true end

---@param slot number
---@return boolean
LootSlotIsCurrency = function(slot) return true end

---@param slot number
---@return boolean
LootSlotIsItem = function(slot) return true end

---@param index number
---@param roll number
RollOnLoot = function(index, roll) end

---@param method string
---@param masterPlayer string
SetLootMethod = function(method, masterPlayer) end

---@param texture string
SetLootPortrait = function(texture) end

---@param threshold number
SetLootThreshold = function(threshold) end

---@param optOut boolean
SetOptOutOfLoot = function(optOut) end

---@return boolean
CursorHasMacro = function() return true end

---@param index number
DeleteMacro = function(index) end

---@param index number
---@return string
GetMacroBody = function(index) return "" end

---@param index number
---@return string, number, number
GetMacroIconInfo = function(index) return "", 0, 0 end

---@param index number
---@return string, number, number
GetMacroItemIconInfo = function(index) return "", 0, 0 end

---@param name string
---@return number
GetMacroIndexByName = function(name) return 0 end

---@param index number
---@return string, string, string
GetMacroInfo = function(index) return "", "", "" end

---@return number
GetNumMacroIcons = function() return 0 end

---@return number
GetNumMacroItemIcons = function() return 0 end

---@return number
GetNumMacros = function() return 0 end

---@param index number
PickupMacro = function(index) end

---@param index number
RunMacro = function(index) end

---@param index number
RunMacroText = function(index) end

---@param option string
---@return string
SecureCmdOptionParse = function(option) return "" end

StopMacro = function() end

---@param index number
AutoLootMailItem = function(index) end

CheckInbox = function() end

ClearSendMail = function() end

ClickSendMailItemButton = function() end

CloseMail = function() end

---@param index number
DeleteInboxItem = function(index) end

---@param currencyIndex number
---@return string
GetCoinIcon = function(currencyIndex) return "" end

---@param index number
---@return string, boolean, boolean, boolean, boolean, boolean, boolean, number, number
GetInboxHeaderInfo = function(index) return "", true, true, true, true, true, true, 0, 0 end

---@param index number
---@param itemIndex number
---@return string, number, number, string, number
GetInboxItem = function(index, itemIndex) return "", 0, 0, "", 0 end

---@param index number
---@param itemIndex number
---@return string
GetInboxItemLink = function(index, itemIndex) return "" end

---@return number
GetInboxNumItems = function() return 0 end

---@param index number
---@return string
GetInboxText = function(index) return "" end

---@param index number
---@return string, string, number
GetInboxInvoiceInfo = function(index) return "", "", 0 end

---@return number
GetNumPackages = function() return 0 end

---@return number
GetNumStationeries = function() return 0 end

---@param index number
---@return string, boolean
GetPackageInfo = function(index) return "", true end

---@return string
GetSelectedStationeryTexture = function() return "" end

---@return number
GetSendMailCOD = function() return 0 end

---@param index number
---@return string, number, number, string, number
GetSendMailItem = function(index) return "", 0, 0, "", 0 end

---@param index number
---@return string
GetSendMailItemLink = function(index) return "" end

---@return number
GetSendMailMoney = function() return 0 end

---@return number
GetSendMailPrice = function() return 0 end

---@param index number
---@return string, number
GetStationeryInfo = function(index) return "", 0 end

---@return boolean
HasNewMail = function() return true end

---@param index number
---@return boolean
InboxItemCanDelete = function(index) return true end

---@param index number
ReturnInboxItem = function(index) end

---@param index number
SelectPackage = function(index) end

---@param index number
SelectStationery = function(index) end

---@param subject string
---@param body string
SendMail = function(subject, body) end

---@param codAmount number
SetSendMailCOD = function(codAmount) end

---@param money number
SetSendMailMoney = function(money) end

---@param index number
TakeInboxItem = function(index) end

---@return number
TakeInboxMoney = function() return 0 end

---@param index number
TakeInboxTextItem = function(index) end

ClickLandmark = function() end

---@return number, number
GetCorpseMapPosition = function() return 0, 0 end

---@return number
GetCurrentMapContinent = function() return 0 end

---@return number
GetCurrentMapDungeonLevel = function() return 0 end

---@return number
GetNumDungeonMapLevels = function() return 0 end

---@return number
GetCurrentMapAreaID = function() return 0 end

---@return string
GetCurrentMapZone = function() return "" end

---@return table
GetMapContinents = function() return {} end

---@param index number
---@return string, string, number, number, number, number, number, number
GetMapDebugObjectInfo = function(index) return "", "", 0, 0, 0, 0, 0, 0 end

---@param mapID number
---@return string, string, number, number, number, number, number, number
GetMapInfo = function(mapID) return "", "", 0, 0, 0, 0, 0, 0 end

---@param index number
---@return string, number, number, number
GetMapLandmarkInfo = function(index) return "", 0, 0, 0 end

---@param index number
---@return string, number, number, number, number
GetMapOverlayInfo = function(index) return "", 0, 0, 0, 0 end

---@param continentID number
---@return table
GetMapZones = function(continentID) return {} end

---@return number
GetNumMapDebugObjects = function() return 0 end

---@return number
GetNumMapLandmarks = function() return 0 end

---@return number
GetNumMapOverlays = function() return 0 end

---@return number, number
GetPlayerMapPosition = function() return 0, 0 end

---@param cursorType string
ProcessMapClick = function(cursorType) end

RequestBattlefieldPositions = function() end

---@param dungeonLevel number
SetDungeonMapLevel = function(dungeonLevel) end

---@param mapID number
SetMapByID = function(mapID) end

SetMapToCurrentZone = function() end

---@param zoomLevel number
SetMapZoom = function(zoomLevel) end

---@param mapFrame table
PositionWorldMapArrowFrame = function(mapFrame) end

---@param index number
---@param quantity number
BuyMerchantItem = function(index, quantity) end

---@param index number
BuybackItem = function(index) end

---@return boolean
CanMerchantRepair = function() return true end

CloseMerchant = function() end

---@param index number
---@return string, string, number, number
GetBuybackItemInfo = function(index) return "", "", 0, 0 end

---@param index number
---@return string
GetBuybackItemLink = function(index) return "" end

---@param index number
---@return number, string, number, number, number
GetMerchantItemCostInfo = function(index) return 0, "", 0, 0, 0 end

---@param index number
---@return string, number
GetMerchantItemCostItem = function(index) return "", 0 end

---@param index number
---@return string, string, number, number, number, number, number, number, number
GetMerchantItemInfo = function(index) return "", "", 0, 0, 0, 0, 0, 0, 0 end

---@param index number
---@return string
GetMerchantItemLink = function(index) return "" end

---@param index number
---@return number
GetMerchantItemMaxStack = function(index) return 0 end

---@return number
GetMerchantNumItems = function() return 0 end

---@return number
GetRepairAllCost = function() return 0 end

HideRepairCursor = function() end

---@return boolean
InRepairMode = function() return true end

---@param index number
PickupMerchantItem = function(index) end

RepairAllItems = function() end

ShowMerchantSellCursor = function() end

ShowRepairCursor = function() end

---@return number
GetNumBuybackItems = function() return 0 end

---@param index number
CastPetAction = function(index) end

ClosePetStables = function() end

---@param unit string
---@param bagID number
---@param slot number
DropItemOnUnit = function(unit, bagID, slot) end

---@param slotID number
---@return number, number, boolean
GetPetActionCooldown = function(slotID) return 0, 0, true end

---@param slotID number
---@return string, string, boolean, boolean
GetPetActionInfo = function(slotID) return "", "", true, true end

---@param slotID number
---@return boolean
GetPetActionSlotUsable = function(slotID) return true end

---@return boolean
GetPetActionsUsable = function() return true end

---@return number, number, number
GetPetExperience = function() return 0, 0, 0 end

---@return table
GetPetFoodTypes = function() return {} end

---@return number
GetPetHappiness = function() return 0 end

---@return string
GetPetIcon = function() return "" end

---@return number
GetPetTimeRemaining = function() return 0 end

---@return table
GetStablePetFoodTypes = function() return {} end

---@param index number
---@return string, number, number, string, string, boolean, boolean
GetStablePetInfo = function(index) return "", 0, 0, "", "", true, true end

---@return boolean
HasPetSpells = function() return true end

---@return boolean
HasPetUI = function() return true end

PetAbandon = function() end

PetAggressiveMode = function() end

PetAttack = function() end

---@return boolean
IsPetAttackActive = function() return true end

PetStopAttack = function() end

---@return boolean
PetCanBeAbandoned = function() return true end

---@return boolean
PetCanBeDismissed = function() return true end

---@return boolean
PetCanBeRenamed = function() return true end

PetDefensiveMode = function() end

PetDismiss = function() end

PetFollow = function() end

---@return boolean
PetHasActionBar = function() return true end

PetPassiveMode = function() end

---@param name string
PetRename = function(name) end

PetWait = function() end

---@param slotID number
PickupPetAction = function(slotID) end

PickupStablePet = function() end

SetPetStablePaperdoll = function() end

---@param slotID number
---@param enabled boolean
TogglePetAutocast = function(slotID, enabled) end

---@param index number
---@param enabled boolean
ToggleSpellAutocast = function(index, enabled) end

---@param index number
---@return boolean
GetSpellAutocast = function(index) return true end

AddQuestWatch = function() end

---@return number
GetActiveLevel = function() return 0 end

---@return string
GetActiveTitle = function() return "" end

---@param questID number
---@return number
GetAvailableLevel = function(questID) return 0 end

---@param questID number
---@return string
GetAvailableTitle = function(questID) return "" end

---@param questIndex number
---@return string, boolean, boolean
GetAvailableQuestInfo = function(questIndex) return "", true, true end

---@param npcID number
---@return string
GetGreetingText = function(npcID) return "" end

---@return number
GetNumQuestLeaderBoards = function() return 0 end

---@return number
GetNumQuestWatches = function() return 0 end

---@param questIndex number
---@param objectiveIndex number
---@return string
GetObjectiveText = function(questIndex, objectiveIndex) return "" end

---@param questIndex number
---@param progressIndex number
---@return string
GetProgressText = function(questIndex, progressIndex) return "" end

---@param questLevel number
---@return boolean
GetQuestGreenRange = function(questLevel) return true end

---@param questID number
---@return number
GetQuestIndexForWatch = function(questID) return 0 end

---@param questID number
---@return string
GetQuestLink = function(questID) return "" end

---@param index number
---@return number
GetQuestLogGroupNum = function(index) return 0 end

---@param questIndex number
---@param objectiveIndex number
---@return string, string, boolean, number, number, boolean
GetQuestLogLeaderBoard = function(questIndex, objectiveIndex) return "", "", true, 0, 0, true end

---@param index number
---@return string, number, number, number, number, boolean, boolean
GetQuestLogTitle = function(index) return "", 0, 0, 0, 0, true, true end

---@return number, string, number, number
GetQuestReward = function() return 0, "", 0, 0 end

---@return number
GetRewardArenaPoints = function() return 0 end

---@return number
GetRewardHonor = function() return 0 end

---@return number
GetRewardMoney = function() return 0 end

---@return number
GetRewardSpell = function() return 0 end

---@return number
GetRewardTalents = function() return 0 end

---@return string
GetRewardText = function() return "" end

---@return string
GetRewardTitle = function() return "" end

---@return number
GetRewardXP = function() return 0 end

---@param questID number
---@return boolean
IsQuestWatched = function(questID) return true end

---@param unit string
---@param questID number
---@return boolean
IsUnitOnQuest = function(unit, questID) return true end

QuestFlagsPVP = function() end

---@return boolean
QuestGetAutoAccept = function() return true end

---@param questIndex number
RemoveQuestWatch = function(questIndex) end

---@param questIndex number
---@param offset number
ShiftQuestWatches = function(questIndex, offset) end

SortQuestWatches = function() end

---@param questID number
---@return boolean
QueryQuestsCompleted = function(questID) return true end

---@return table
GetQuestsCompleted = function() return {} end

---@param questID number
---@return boolean
QuestIsDaily = function(questID) return true end

---@param unit string
DemoteAssistant = function(unit) end

---@return boolean
GetAllowLowLevelRaid = function() return true end

---@return number
GetNumRaidMembers = function() return 0 end

---@return number
GetRealNumRaidMembers = function() return 0 end

---@param unit string
---@return string, string
GetPartyAssignment = function(unit) return "", "" end

---@param raidID number
---@return string, string
GetRaidRosterInfo = function(raidID) return "", "" end

---@param unit string
---@return number
GetRaidTargetIndex = function(unit) return 0 end

---@return boolean, boolean, boolean
GetReadyCheckStatus = function() return true, true, true end

InitiateRolePoll = function() end

---@return boolean
IsRaidLeader = function() return true end

---@param unit string
---@return boolean
IsRaidOfficer = function(unit) return true end

---@param raidTargetIndex number
PlaceRaidMarker = function(raidTargetIndex) end

---@param unit string
PromoteToAssistant = function(unit) end

RequestRaidInfo = function() end

---@param unit string
---@param role string
SetPartyAssignment = function(unit, role) end

---@param enabled boolean
SetAllowLowLevelRaid = function(enabled) end

---@param index number
SetRaidRosterSelection = function(index) end

---@param unit string
---@param subgroup number
SetRaidSubgroup = function(unit, subgroup) end

---@param unit1 string
---@param unit2 string
SwapRaidSubgroup = function(unit1, unit2) end

---@param unit string
---@param raidTargetIndex number
SetRaidTarget = function(unit, raidTargetIndex) end

---@param unit string
---@return boolean
UnitInRaid = function(unit) return true end

GetInstanceLockTimeRemainingEncounter = function() end

---@param dungeonID number
SearchLFGGetEncounterResults = function(dungeonID) end

---@return number
SearchLFGGetJoinedID = function() return 0 end

---@return number
SearchLFGGetNumResults = function() return 0 end

---@return number
SearchLFGGetPartyResults = function() return 0 end

---@return number
SearchLFGGetResults = function() return 0 end

---@param resultID number
SearchLFGJoin = function(resultID) end

SearchLFGLeave = function() end

---@param sortOrder string
SearchLFGSort = function(sortOrder) end

---@param comment string
SetLFGComment = function(comment) end

ClearAllLFGDungeons = function() end

---@param dungeonID number
JoinLFG = function(dungeonID) end

---@param dungeonID number
RequestLFDPlayerLockInfo = function(dungeonID) end

---@param dungeonID number
SetLFGDungeon = function(dungeonID) end

---@param dungeonID number
---@param enabled boolean
SetLFGDungeonEnabled = function(dungeonID, enabled) end

---@param categoryID number
---@param collapsed boolean
SetLFGHeaderCollapsed = function(categoryID, collapsed) end

---@param func function
---@return number
GetFunctionCPUUsage = function(func) return 0 end

---@param varName string
---@return boolean
issecure = function(varName) return true end

---@param func function
forceinsecure = function(func) end

---@param varName string
---@return boolean
issecurevariable = function(varName) return true end

---@param func function
---@vararg ...
---@return any
securecall = function(func, ...) return nil end

---@param tbl table|string the table where the function is located, if nil, the function is a global function
---@param origFunc string|function
---@param hookFunc function?
hooksecurefunc = function(tbl, origFunc, hookFunc) end

InCombatLockdown = function() end

---@param unit string
CombatTextSetActiveUnit = function(unit) end

---@param cvarName string
---@return string
GetCVar = function(cvarName) return "" end

---@param cvarName string
---@return string
GetCVarDefault = function(cvarName) return "" end

---@param cvarName string
---@return boolean
GetCVarBool = function(cvarName) return true end

---@param cvarName string
---@return table
GetCVarInfo = function(cvarName) return {} end

---@return boolean
DownloadSettings = function() return true end

---@return number
GetCurrentMultisampleFormat = function() return 0 end

---@return number
GetCurrentResolution = function() return 0 end

---@return number
GetScriptCPUUsage = function() return 0 end

---@return boolean
ResetCPUUsage = function() return true end

---@return boolean
UpdateAddOnCPUUsage = function() return true end

---@return boolean
UpdateAddOnMemoryUsage = function() return true end

---@return number, number, number
GetGamma = function() return 0, 0, 0 end

---@return table
GetMultisampleFormats = function() return {} end

---@param formatIndex number
---@return table
GetRefreshRates = function(formatIndex) return {} end

---@return table
GetScreenResolutions = function() return {} end

---@param category string
---@return boolean
GetVideoCaps = function(category) return true end

---@return boolean
IsThreatWarningEnabled = function() return true end

---@return boolean
ResetPerformanceValues = function() return true end

---@return boolean
ResetTutorials = function() return true end

---@param cvarName string
---@param value any
RegisterCVar = function(cvarName, value) end

---@param cvarName string
---@param value any
SetCVar = function(cvarName, value) end

SetEuropeanNumbers = function() end

---@param gamma number
SetGamma = function(gamma) end

---@param enabled boolean
SetLayoutMode = function(enabled) end

---@param formatIndex number
SetMultisampleFormat = function(formatIndex) end

---@param resolutionIndex number
SetScreenResolution = function(resolutionIndex) end

---@param show boolean
ShowCloak = function(show) return true end

---@param show boolean
ShowHelm = function(show) return true end

---@param show boolean
ShowNumericThreat = function(show) return true end

---@return boolean
ShowingCloak = function() return true end

---@return boolean
ShowingHelm = function() return true end

---@param settings table
UploadSettings = function(settings)
    return true
end

---@param skillIndex number
AbandonSkill = function(skillIndex) end

---@param formIndex number
CastShapeshiftForm = function(formIndex) end

---@param spellName string
---@param target string
CastSpell = function(spellName, target) end

---@param spellName string
---@param target string
CastSpellByName = function(spellName, target) end

---@param totemIndex number
---@return table
GetMultiCastTotemSpells = function(totemIndex) return {} end

---@return number
GetNumShapeshiftForms = function() return 0 end

---@return number
GetNumSpellTabs = function() return 0 end

---@return number
GetShapeshiftForm = function() return 0 end

---@param formIndex number
---@return number, number, number
GetShapeshiftFormCooldown = function(formIndex) return 0, 0, 0 end

---@param formIndex number
---@return string, boolean, boolean, number
GetShapeshiftFormInfo = function(formIndex) return "", false, false, 0 end

---@param spellID number
---@return boolean
GetSpellAutocast = function(spellID) return true end

---@param spellSlot number
---@param bookType string
---@return string, string
GetSpellBookItemInfo = function(spellSlot, bookType) return "", "" end

---@param spellSlot number
---@param bookType string
---@return string
GetSpellBookItemName = function(spellSlot, bookType) return "" end

---@param spellID number
---@return number, number
GetSpellCooldown = function(spellID) return 0, 0 end

---@param spellName string
---@return string
GetSpellDescription = function(spellName) return "" end

---@param spellNameOrID string|number
---@return string, number, number, number, number, number, number, number
GetSpellInfo = function(spellNameOrID) return "", 0, 0, 0, 0, 0, 0, 0 end

---@param spellID number
---@return string
GetSpellLink = function(spellID) return "" end

---@param tabIndex number
---@param isFlyout boolean?
---@return string, string, number, number
GetSpellTabInfo = function(tabIndex, isFlyout) return "", "", 0, 0 end

---@param spellName string
---@return string
GetSpellTexture = function(spellName) return "" end

---@param totemIndex number
---@return string, number, number, number, number, number, number, number, number
GetTotemInfo = function(totemIndex) return "", 0, 0, 0, 0, 0, 0, 0, 0 end

---@param spellId number
---@return boolean
IsAttackSpell = function(spellId) return true end

---@param spellId number
---@return boolean
IsAutoRepeatSpell = function(spellId) return true end

---@param spellId number
---@param spellBank string
---@return boolean
IsPassiveSpell = function(spellId, spellBank) return true end

---@param spellName string
---@param target string
---@return boolean
IsSpellInRange = function(spellName, target) return true end

---@param spellName string
---@return boolean
IsUsableSpell = function(spellName) return true end

---@param spellName string
PickupSpell = function(spellName) end

---@param sequenceName string
---@return string
QueryCastSequence = function(sequenceName) return "" end

---@param spellName string
---@param totemIndex number
SetMultiCastSpell = function(spellName, totemIndex) end

---@param unit string
---@param spellName string
---@return boolean
SpellCanTargetUnit = function(unit, spellName) return true end

---@param spellName string
---@return boolean
SpellHasRange = function(spellName) return true end

---@return boolean
SpellIsTargeting = function() return true end

---@return boolean
SpellStopCasting = function() return true end

---@return boolean
SpellStopTargeting = function() return true end

---@param unit string
SpellTargetUnit = function(unit) end

ToggleSpellAutocast = function() end

---@return string, string, number, number, boolean, string
UnitCastingInfo = function() return "", "", 0, 0, false, "" end

---@param unit string
---@return string, string, number, number, boolean, string
UnitChannelInfo = function(unit) return "", "", 0, 0, false, "" end

---@param command string
ConsoleExec = function(command) end

---@return string game version
---@return string buildId
---@return string compileDate
---@return number buildNumber
GetBuildInfo = function() return "", "", "", 0 end

---@return number
GetFramerate = function() return 0 end

---@return number, number
GetGameTime = function() return 0, 0 end

---@return string
GetLocale = function() return "" end

---@return number, number
GetCursorPosition = function() return 0, 0 end

---@return number, number, number, number
GetNetStats = function() return 0, 0, 0, 0 end

---@return string
GetRealmName = function() return "" end

---@return number
GetScreenHeight = function() return 0 end

---@return number
GetScreenWidth = function() return 0 end

---@param frame string
---@return string
GetText = function(frame) return "" end

---@return number
GetTime = function() return 0 end

---@return boolean
IsAltKeyDown = function() return true end

---@return boolean
InCinematic = function() return true end

---@return boolean
IsControlKeyDown = function() return true end

---@return boolean
DetectWowMouse = function() return true end

---@return function
geterrorhandler = function() return function() end end

---@return number
GetAddOnCPUUsage = function() return 0 end

LeaveLFG = function() end

RequestLFDPartyLockInfo = function() end

---@return number
GetAddOnMemoryUsage = function() return 0 end

---@return number
GetEventCPUUsage = function() return 0 end

---@return number
GetFrameCPUUsage = function() return 0 end

---@param dungeonID number
LFGGetDungeonInfoByID = function(dungeonID) end

RefreshLFGList = function() end

---@param questID number
---@return boolean
QuestIsWeekly = function(questID) return true end

---@param unit string
ClearRaidMarker = function(unit) end

ConvertToRaid = function() end

ConvertToParty = function() end

---@return table
GetCurrentKeyBoardFocus = function() return {} end

---@return table
GetExistingLocales = function() return {} end

---@return boolean
IsDebugBuild = function() return true end

---@return boolean
IsDesaturateSupported = function() return true end

---@return boolean
IsLeftAltKeyDown = function() return true end

---@return boolean
IsLeftControlKeyDown = function() return true end

---@return boolean
IsLeftShiftKeyDown = function() return true end

---@return boolean
IsLinuxClient = function() return true end

---@return boolean
function ZoomOut() return true end

---@param scale number
function SetupFullscreenScale(scale) end

---@param highlightType string
---@param texturePath string
---@param textureX number
---@param textureY number
---@param pulseTexturePath string
---@param pulseTextureX number
---@param pulseTextureY number
function UpdateMapHighlight(highlightType, texturePath, textureX, textureY, pulseTexturePath, pulseTextureX, pulseTextureY) end

---@return table
function CreateWorldMapArrowFrame() return {} end

---@param arrowFrame table
---@param playerX number
---@param playerY number
function UpdateWorldMapArrowFrames(arrowFrame, playerX, playerY) end

---@param arrowFrame table
function ShowWorldMapArrowFrame(arrowFrame) end

---@return boolean
function IsLoggedIn() return true end

---@return boolean
function IsMacClient() return true end

---@return boolean
function IsRightAltKeyDown() return true end

---@return boolean
function IsRightControlKeyDown() return true end

---@return boolean
function IsRightShiftKeyDown() return true end

---@return boolean
function IsShiftKeyDown() return true end

---@return boolean
function IsStereoVideoAvailable() return true end

---@return boolean
function IsWindowsClient() return true end

---@param cinematicIndex number
function OpeningCinematic(cinematicIndex) end

---@param musicFile string
function PlayMusic(musicFile) end

---fire SOUNDKIT_FINISHED if runFinishCallback is true
---@param soundFile string
---@param channel string?
---@param forceNoDuplicates boolean?
---@param runFinishCallback boolean?
---@return boolean bWillPlay
---@return number soundHandle
function PlaySound(soundFile, channel, forceNoDuplicates, runFinishCallback) return true, 0 end

---@param soundFile string
---@param channel string?
---@return boolean bWillPlay
---@return number soundHandle
function PlaySoundFile(soundFile, channel) return true, 0 end

---@param soundHandle number
---@param fadeOutTime number?
function StopSound(soundHandle, fadeOutTime) end

---@param soundId string|number
function MuteSoundFile(soundId) end

---@param soundId string|number
function UnmuteSoundFile(soundId) end

function ReloadUI() end

function RepopMe() end

---@return number, number, number, number
function RequestTimePlayed() return 0, 0, 0, 0 end

function RestartGx() end

---@param script string
function RunScript(script) end

function Screenshot() end

---@param autoDecline boolean
function SetAutoDeclineGuildInvites(autoDecline) end

---@param errorHandler function
function seterrorhandler(errorHandler) end

function StopCinematic() end

function StopMusic() end

---@param addonName string
function UIParentLoadAddOn(addonName) end

---@param delay number
function TakeScreenshot(delay) end

---@param trainerIndex number
---@param talentIndex number
function BuyTrainerService(trainerIndex, talentIndex) end

---@return number, number
function CheckTalentMasterDist() return 0, 0 end

function ConfirmTalentWipe() end

---@return number
function GetActiveTalentGroup() return 0 end

---@return number
function GetNumTalentTabs() return 0 end

---@param tabIndex number
---@return number
function GetNumTalents(tabIndex) return 0 end

---@param tabIndex number
---@param talentIndex number
---@param isInspect boolean
---@return string, string, string, number, number, boolean
function GetTalentInfo(tabIndex, talentIndex, isInspect) return "", "", "", 0, 0, true end

---@param tabIndex number
---@param talentIndex number
---@param isInspect boolean
---@return string
function GetTalentLink(tabIndex, talentIndex, isInspect) return "" end

---@param tabIndex number
---@param talentIndex number
---@param isInspect boolean
---@return number
function GetTalentPrereqs(tabIndex, talentIndex, isInspect) return 0 end

---@param tabIndex number
---@return number, string, string, number, number, string, number, boolean
function GetTalentTabInfo(tabIndex) return 0, "", "", 0, 0, "", 0, false end

---@param tabIndex number
---@param talentIndex number
function LearnTalent(tabIndex, talentIndex) end

---@param talentGroup number
function SetActiveTalentGroup(talentGroup) end

---@return number
function GetNumTalentGroups() return 0 end

---@return number
function GetActiveTalentGroup() return 0 end

---@param amount number
function AddPreviewTalentPoints(amount) end

---@param talentGroup number
---@return number
function GetGroupPreviewTalentPointsSpent(talentGroup) return 0 end

---@return number
function GetPreviewTalentPointsSpent() return 0 end

---@return number
function GetUnspentTalentPoints() return 0 end

function LearnPreviewTalents() end

---@param talentGroup number
function ResetGroupPreviewTalentPoints(talentGroup) end

function ResetPreviewTalentPoints() end

---@param unit string
function AssistUnit(unit) end

function AttackTarget() end

function ClearTarget() end

function ClickTargetTradeButton() end

function TargetLastEnemy() end

function TargetLastTarget() end

function TargetNearestEnemy() end

function TargetNearestEnemyPlayer() end

function TargetNearestFriend() end

function TargetNearestFriendPlayer() end

function TargetNearestPartyMember() end

function TargetNearestRaidMember() end

---@param unit string
function TargetUnit(unit) end

function ToggleBackpack() end

function ToggleBag() end

function ToggleCharacter() end

function ToggleFriendsFrame() end

function ToggleSpellBook() end

function TradeSkill() end

function CloseTradeSkill() end

---@param index number
function CollapseTradeSkillSubClass(index) end

---@param amount number
function PickupPlayerMoney(amount) end

---@param amount number
function PickupTradeMoney(amount) end

---@param money number
function SetTradeMoney(money) end

---@param slotId number
function ReplaceTradeEnchant(slotId) end

---@param unit string
function AssistUnit(unit) end

---@param unit string
---@param maxDistance number
---@return boolean
function CheckInteractDistance(unit, maxDistance) return true end

---@param itemName string
---@param unit string
function DropItemOnUnit(itemName, unit) end

---@param unit string
function FollowUnit(unit) end

---@param unit string
function FocusUnit(unit) end

function ClearFocus() end

---if bFullName is true, return the full name of the unit if the unit is from another realm, otherwise return the short name
---@param unit unit
---@param bFullName boolean
---@return string
function GetUnitName(unit, bFullName) return "" end

---@param unit string
---@return number
function GetUnitPitch(unit) return 0 end

---@param unit string
---@return number
function GetUnitSpeed(unit) return 0 end

---@param unit string
function InviteUnit(unit) end

---@param unit string
---@param questID number
---@return boolean
function IsUnitOnQuest(unit, questID) return true end

---@param spellNameOrID string|number
---@param unit string
---@return boolean
function SpellCanTargetUnit(spellNameOrID, unit) return true end

---@param unit string
function SpellTargetUnit(unit) end

---@param unit string
function TargetUnit(unit) end

---@param unit string
---@return boolean
function UnitAffectingCombat(unit) return true end

---@param unit string
---@return number
function UnitArmor(unit) return 0 end

---@param unit string
---@return number
function UnitAttackBothHands(unit) return 0 end

---@param unit string
---@return number
function UnitAttackPower(unit) return 0 end

---@param unit string
---@return number
function UnitAttackSpeed(unit) return 0 end

---@param unit string
---@param index number
---@param filter string|nil
---@return string, number, string, number, number, string
function UnitAura(unit, index, filter) return "", 0, "", 0, 0, "" end

---@param unit string
---@param index number
---@param filter string|nil
---@return string, number, string, number, number, string
function UnitBuff(unit, index, filter) return "", 0, "", 0, 0, "" end

---@param unit string
---@return boolean
function UnitCanAssist(unit) return true end

---@param unit string
---@return boolean
function UnitCanAttack(unit) return true end

---@param unit string
---@return boolean
function UnitCanCooperate(unit) return true end

---@param unit string
---@return string, string
function UnitClass(unit) return "", "" end

---@param unit string
---@return string
function UnitClassification(unit) return "" end

---@param unit string
---@return string
function UnitCreatureFamily(unit) return "" end

---@param unit string
---@return string
function UnitCreatureType(unit) return "" end

---@param unit string
---@return number, number, number, number
function UnitDamage(unit) return 0, 0, 0, 0 end

---@param unit string
---@param index number
---@param filter string|nil
---@return string, number, string, number, number, string
function UnitDebuff(unit, index, filter) return "", 0, "", 0, 0, "" end

---@param unit string
---@return number
function UnitDefense(unit) return 0 end

---@param unit string
---@param mobUnit string
---@return number, string, number, number, number
function UnitDetailedThreatSituation(unit, mobUnit) return 0, "", 0, 0, 0 end

---@param unit string
---@return boolean
function UnitExists(unit) return true end

---@param unit string
---@return string
function UnitFactionGroup(unit) return "" end

---@param unit string
---@return string
function UnitGUID(unit) return "" end

---@param guid string
---@return string, string, string, string
function GetPlayerInfoByGUID(guid) return "", "", "", "" end

---@param unit string
---@return boolean
function UnitHasLFGDeserter(unit) return true end

---@param unit string
---@return boolean
function UnitHasLFGRandomCooldown(unit) return true end

---@param unit string
---@return boolean
function UnitHasRelicSlot(unit) return true end

---@param unit string
---@return number
function UnitHealth(unit) return 0 end

---@param unit string
---@return number
function UnitHealthMax(unit) return 0 end

---@param unit string
---@return boolean
function UnitInParty(unit) return true end

---@param unit string
---@return boolean
function UnitInRaid(unit) return true end

---@param unit string
---@return boolean
function UnitInBattleground(unit) return true end

---@param unit string
---@return boolean
function UnitIsInMyGuild(unit) return true end

---@param unit string
---@return boolean
function UnitInRange(unit) return true end

---@param unit string
---@return boolean
function UnitIsAFK(unit) return true end

---@param unit string
---@return boolean
function UnitIsCharmed(unit) return true end

---@param unit string
---@return boolean
function UnitIsConnected(unit) return true end

---@param unit string
---@return boolean
function UnitIsCorpse(unit) return true end

---@param unit string
---@return boolean
function UnitIsDead(unit) return true end

---@param unit string
---@return boolean
function UnitIsDeadOrGhost(unit) return true end

---@param unit string
---@return boolean
function UnitIsDND(unit) return true end

---@param unit string
---@return boolean
function UnitIsEnemy(unit) return true end

---@param unit string
---@return boolean
function UnitIsFeignDeath(unit) return true end

---@param unit string
---@return boolean
function UnitIsFriend(unit) return true end

---@param unit string
---@return boolean
function UnitIsGhost(unit) return true end

---@param unit string
---@return boolean
function UnitIsPVP(unit) return true end

---@param unit string
---@return boolean
function UnitIsPVPFreeForAll(unit) return true end

---@param unit string
---@return boolean
function UnitIsPVPSanctuary(unit) return true end

---@param unit string
---@return boolean
function UnitIsPartyLeader(unit) return true end

---@param unit string
---@return boolean
function UnitIsPlayer(unit) return true end

---@param unit string
---@return boolean
function UnitIsPossessed(unit) return true end

---@param unit string
---@return boolean
function UnitIsRaidOfficer(unit) return true end

---@param unit string
---@return boolean
function UnitIsSameServer(unit) return true end

---@param unit string
---@return boolean
function UnitIsTapped(unit) return true end

---@param unit string
---@return boolean
function UnitIsTappedByPlayer(unit) return true end

---@param unit string
---@return boolean
function UnitIsTappedByAllThreatList(unit) return true end

---@param unit string
---@return boolean
function UnitIsTrivial(unit) return true end

---@param unit1 string
---@param unit2 string
---@return boolean
function UnitIsUnit(unit1, unit2) return true end

---@param unit string
---@return boolean
function UnitIsVisible(unit) return true end

---@param unit string
---@return number
function UnitLevel(unit) return 0 end

---@param unit string
---@return number
function UnitMana(unit) return 0 end

---@param unit string
---@return number
function UnitManaMax(unit) return 0 end

---@param unit string
---@return string
function UnitName(unit) return "" end

---@param unit string
---@return boolean
function UnitOnTaxi(unit) return true end

---@param unit string
---@return boolean
function UnitPlayerControlled(unit) return true end

---@param unit string
---@return boolean
function UnitPlayerOrPetInParty(unit) return true end

---@param unit string
---@return boolean
function UnitPlayerOrPetInRaid(unit) return true end

---@param unit string
---@return string
function UnitPVPName(unit) return "" end

---@param unit string
---@return number
function UnitPVPRank(unit) return 0 end

---@param unit string
---@param powerType number
---@return number
function UnitPower(unit, powerType) return 0 end

---@param unit string
---@param powerType number
---@return number
function UnitPowerMax(unit, powerType) return 0 end

---@param unit string
---@param powerType number
---@return number
function UnitPowerType(unit, powerType) return 0 end

---@param unit string
---@return string
function UnitRace(unit) return "" end

---@param unit string
function UnitRangedAttack(unit) end

---@param unit string
---@return number
function UnitRangedAttackPower(unit) return 0 end

---@param unit string
---@return number, number
function UnitRangedDamage(unit) return 0, 0 end

---@param unit string
---@param otherUnit string
---@return number
function UnitReaction(unit, otherUnit) return 0 end

---@param unit string
---@param school number
---@return number
function UnitResistance(unit, school) return 0 end

---@param unit string
---@return number, number, number, number
function UnitSelectionColor(unit) return 0, 0, 0, 0 end

---@param unit string
---@return number
function UnitSex(unit) return 0 end

---@param unit string
---@param index number
---@return number
function UnitStat(unit, index) return 0 end

---@param unit string
---@param mobUnit string
---@return number, string, number, number, number
function UnitThreatSituation(unit, mobUnit) return 0, "", 0, 0, 0 end

---@param unit string
---@return boolean
function UnitUsingVehicle(unit) return true end

---@param status number
---@return number, number, number
function GetThreatStatusColor(status) return 0, 0, 0 end

---Retrieves the current experience points of a unit.
---@param unit string
---@return number
function UnitXP(unit) return 0 end

---Retrieves the maximum experience points of a unit.
---@param unit string
---@return number
function UnitXPMax(unit) return 0 end

---Sets the portrait texture of a frame.
---@param frame table
---@param texture string
function SetPortraitTexture(frame, texture) end

---Sets the portrait texture of a frame to a specific texture.
---@param frame table
---@param texture string
function SetPortraitToTexture(frame, texture) end

---Inserts a value into a table.
---@param table table
---@param value any
function tinsert(table, value) end
