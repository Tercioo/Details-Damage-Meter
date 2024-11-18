
---@type detailsframework
local detailsFramework = _G["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local _
local type = type
local floor = math.floor
local GetTime = GetTime

---@class df_timebar : statusbar, df_scripthookmixin, df_widgets
---@field type string
---@field dframework boolean
---@field statusBar df_timebar_statusbar
---@field widget statusbar
---@field direction string
---@field HookList table
---@field tooltip string
---@field locked boolean
---@field HasTimer fun(self:df_timebar):boolean return if the timer bar is active showing a timer
---@field SetTimer fun(self:df_timebar, currentTime:number, startTime:number|boolean|nil, endTime:number|nil)
---@field StartTimer fun(self:df_timebar, currentTime:number, startTime:number, endTime:number)
---@field StopTimer fun(self:df_timebar)
---@field ShowSpark fun(self:df_timebar, state:boolean, alpha:number|nil, color:string|nil)
---@field ShowTimer fun(self:df_timebar, bShowTimer:boolean)
---@field SetIcon fun(self:df_timebar, texture:string, L:number|nil, R:number|nil, T:number|nil, B:number|nil)
---@field SetIconSize fun(self:df_timebar, width:number, height:number)
---@field SetTexture fun(self:df_timebar, texture:texturepath|textureid)
---@field SetColor fun(self:df_timebar, color:any, green:number|nil, blue:number|nil, alpha:number|nil)
---@field SetLeftText fun(self:df_timebar, text:string)
---@field SetRightText fun(self:df_timebar, text:string)
---@field SetFont fun(self:df_timebar, font:string|nil, size:number|nil, color:any, shadow:boolean|nil)
---@field SetThrottle fun(self:df_timebar, seconds:number)
---@field SetDirection fun(self:df_timebar, direction:string)
---@field SetBackgroundColor fun(self:df_timebar, color:any, green:number|nil, blue:number|nil, alpha:number|nil)

---@class df_timebar_statusbar : statusbar
---@field MyObject df_timebar
---@field hasTimer boolean
---@field startTime number
---@field endTime number
---@field timeLeft1 number
---@field timeLeft2 number
---@field throttle number
---@field isUsingThrottle boolean
---@field showTimer boolean
---@field amountThrottle number
---@field sparkAlpha number
---@field sparkColorR number
---@field sparkColorG number
---@field sparkColorB number
---@field dontShowSpark boolean
---@field direction string
---@field spark texture
---@field icon texture
---@field leftText fontstring
---@field rightText fontstring
---@field backgroundTexture texture
---@field barTexture texture

local APITimeBarFunctions

do
	local metaPrototype = {
		WidgetType = "timebar",
		dversion = detailsFramework.dversion,
	}

	--check if there's a metaPrototype already existing
	if (_G[detailsFramework.GlobalWidgetControlNames["timebar"]]) then
		--get the already existing metaPrototype
		local oldMetaPrototype = _G[detailsFramework.GlobalWidgetControlNames["timebar"]]
		--check if is older
		if ( (not oldMetaPrototype.dversion) or (oldMetaPrototype.dversion < detailsFramework.dversion) ) then
			--the version is older them the currently loading one
			--copy the new values into the old metatable
			for funcName, _ in pairs(metaPrototype) do
				oldMetaPrototype[funcName] = metaPrototype[funcName]
			end
		end
	else
		--first time loading the framework
		_G[detailsFramework.GlobalWidgetControlNames["timebar"]] = metaPrototype
	end
end

local TimeBarMetaFunctions = _G[detailsFramework.GlobalWidgetControlNames["timebar"]]
detailsFramework:Mixin(TimeBarMetaFunctions, detailsFramework.ScriptHookMixin)

--methods
TimeBarMetaFunctions.SetMembers = TimeBarMetaFunctions.SetMembers or {}
TimeBarMetaFunctions.GetMembers = TimeBarMetaFunctions.GetMembers or {}

TimeBarMetaFunctions.__index = function(table, key)
    local func = TimeBarMetaFunctions.GetMembers[key]
    if (func) then
        return func(table, key)
    end

    local fromMe = rawget(table, key)
    if (fromMe) then
        return fromMe
    end

    return TimeBarMetaFunctions[key]
end

TimeBarMetaFunctions.__newindex = function(table, key, value)
    local func = TimeBarMetaFunctions.SetMembers[key]
    if (func) then
        return func(table, value)
    else
        return rawset(table, key, value)
    end
end

--scripts
local OnEnterFunc = function(statusBar)
    local kill = statusBar.MyObject:RunHooksForWidget("OnEnter", statusBar, statusBar.MyObject)
    if (kill) then
        return
    end

    if (statusBar.MyObject.tooltip) then
        GameCooltip2:Reset()
        GameCooltip2:AddLine(statusBar.MyObject.tooltip)
        GameCooltip2:ShowCooltip(statusBar, "tooltip")
    end
end

local OnLeaveFunc = function(statusBar)
    local kill = statusBar.MyObject:RunHooksForWidget("OnLeave", statusBar, statusBar.MyObject)
    if (kill) then
        return
    end

    if (statusBar.MyObject.tooltip) then
        GameCooltip2:Hide()
    end
end

local OnHideFunc = function(statusBar)
    local kill = statusBar.MyObject:RunHooksForWidget("OnHide", statusBar, statusBar.MyObject)
    if (kill) then
        return
    end
end

local OnShowFunc = function(statusBar)
    local kill = statusBar.MyObject:RunHooksForWidget("OnShow", statusBar, statusBar.MyObject)
    if (kill) then
        return
    end
end

local OnMouseDownFunc = function(statusBar, mouseButton)
    local kill = statusBar.MyObject:RunHooksForWidget("OnMouseDown", statusBar, statusBar.MyObject)
    if (kill) then
        return
    end
end

local OnMouseUpFunc = function(statusBar, mouseButton)
    local kill = statusBar.MyObject:RunHooksForWidget("OnMouseUp", statusBar, statusBar.MyObject)
    if (kill) then
        return
    end
end

--timer functions
function TimeBarMetaFunctions:SetIconSize(width, height)
    if (width and not height) then
        self.statusBar.icon:SetWidth(width)

    elseif (not width and height) then
        self.statusBar.icon:SetHeight(height)

    elseif (width and height) then
        self.statusBar.icon:SetSize(width, height)
    end
end

function TimeBarMetaFunctions:SetIcon(texture, L, R, T, B)
    if (texture) then
        self.statusBar.icon:Show()
        self.statusBar.icon:SetPoint("left", self.statusBar, "left", 2, 0)
        self.statusBar.icon:SetSize(self.statusBar:GetHeight()-2, self.statusBar:GetHeight()-2)
        self.statusBar.leftText:ClearAllPoints()
        self.statusBar.leftText:SetPoint("left", self.statusBar.icon, "right", 2, 0)
        self.statusBar.icon:SetTexture(texture)

        if (L) then
            self.statusBar.icon:SetTexCoord(L, R, T, B)
        end
    else
        self.statusBar.icon:Hide()
        self.statusBar.leftText:ClearAllPoints()
        self.statusBar.leftText:SetPoint("left", self.statusBar, "left", 2, 0)
    end
end

function TimeBarMetaFunctions:GetIcon()
    return self.statusBar.icon
end

function TimeBarMetaFunctions:SetTexture(texture)
    self.statusBar.barTexture:SetTexture(texture)
end

function TimeBarMetaFunctions:SetColor(color, green, blue, alpha)
    local r, g, b, a = detailsFramework:ParseColors(color, green, blue, alpha)
    self.statusBar.barTexture:SetVertexColor(r, g, b, a)
end

function TimeBarMetaFunctions:SetLeftText(text)
    self.statusBar.leftText:SetText(text)
end
function TimeBarMetaFunctions:SetRightText(text)
    self.statusBar.rightText:SetText(text)
end

function TimeBarMetaFunctions:SetFont(font, size, color, shadow)
    if (font) then
        detailsFramework:SetFontFace(self.statusBar.leftText, font)
    end

    if (size) then
        detailsFramework:SetFontSize(self.statusBar.leftText, size)
    end

    if (color) then
        detailsFramework:SetFontColor(self.statusBar.leftText, color)
    end

    if (shadow) then
        detailsFramework:SetFontOutline(self.statusBar.leftText, shadow)
    end
end

--set background texture color
function TimeBarMetaFunctions:SetBackgroundColor(color, green, blue, alpha)
    local r, g, b, a = detailsFramework:ParseColors(color, green, blue, alpha)
    self.statusBar.backgroundTexture:SetVertexColor(r, g, b, a)
end

---set a throttle for the timer bar, the timer will only update every X seconds
---calling without parameters will disable the throttle
---@param seconds number|nil the amount of seconds to throttle the timer
function TimeBarMetaFunctions:SetThrottle(seconds)
    if (seconds and seconds > 0) then
        self.statusBar.isUsingThrottle = true
        self.statusBar.amountThrottle = seconds
    else
        self.statusBar.isUsingThrottle = false
    end
end

---accept 'left' 'right' or nil, if ommited will default to right
---@param direction "left"|"right"|nil the direction of the timer bar
function TimeBarMetaFunctions:SetDirection(direction)
    direction = direction or "right"
    self.direction = direction
end

function TimeBarMetaFunctions:HasTimer()
    return self.statusBar.hasTimer
end

function TimeBarMetaFunctions:StopTimer()
    if (self.statusBar.hasTimer) then
        self.statusBar.hasTimer = nil
        local kill = self:RunHooksForWidget("OnTimerEnd", self.statusBar, self)
        if (kill) then
            return
        end
    end

    local statusBar = self.statusBar
    statusBar:SetScript("OnUpdate", nil)

    statusBar:SetMinMaxValues(0, 100)
    statusBar:SetValue(100)
    statusBar.rightText:SetText("")

    statusBar.spark:Hide()
end

function TimeBarMetaFunctions:ShowTimer(bShowTimer)
    if (bShowTimer) then
        self.statusBar.showTimer = true
    else
        self.statusBar.showTimer = nil
    end
end

function TimeBarMetaFunctions:ShowSpark(state, alpha, color)
    if (type(state) == "boolean" and state == false) then
        self.statusBar.dontShowSpark = true
    else
        self.statusBar.dontShowSpark = nil
    end

    if (alpha) then
        self.statusBar.sparkAlpha = alpha
    else
        self.statusBar.sparkAlpha = nil
    end

    if (color) then
        local r, g, b = detailsFramework:ParseColors(color)
        if (r and g and b) then
            self.statusBar.sparkColorR = r
            self.statusBar.sparkColorG = g
            self.statusBar.sparkColorB = b
        end
    else
        self.statusBar.sparkColorR = nil
        self.statusBar.sparkColorG = nil
        self.statusBar.sparkColorB = nil
    end
end

---@param self df_timebar_statusbar
---@param deltaTime number
local OnUpdateFunc = function(self, deltaTime)
    if (self.isUsingThrottle) then
        self.throttle = self.throttle + deltaTime
        if (self.throttle < self.amountThrottle) then
            return
        end
        self.throttle = 0
    end

    local timeNow = GetTime()
    self:SetValue(timeNow)

    --adjust the spark
    local spark = self.spark
    local startTime, endTime = self:GetMinMaxValues()

    if (not self.dontShowSpark) then
        if (self.direction == "right") then
            if (endTime - startTime > 0) then
                local pct = abs((timeNow - endTime) / (endTime - startTime))
                pct = abs(1 - pct)
                spark:SetPoint("left", self, "left", (self:GetWidth() * pct) - 16, 0)
                spark:Show()
            else
                spark:Hide()
            end
        else
            spark:SetPoint("right", self, "right", self:GetWidth() * (timeNow/self.endTime), 0)
        end
    end

    if (self.showTimer) then
        local timeLeft = floor(endTime - timeNow) + 1
        local formatedTimeLeft = detailsFramework:IntegerToTimer(timeLeft)
        self.rightText:SetText(formatedTimeLeft)
    end

    --check if finished
    if (timeNow >= self.endTime) then
        self.MyObject:StopTimer()
    end

    self.MyObject:RunHooksForWidget("OnUpdate", self, self, deltaTime)
end

---start a timer on the timebar
---calling without parameters will stop the timer
---@param self df_timebar
---@param currentTime number the time in seconds if startTime is a boolean true. GetTime() when start and end time are passed
---@param startTime number|boolean|nil GetTime() when the timer started. if passed true: startTime and endTime are GetTime() and GetTime() + currentTime, currenTime is the time in seconds
---@param endTime number|nil GetTime() when the timer will end. ignored if startTime is a boolean true
function TimeBarMetaFunctions:SetTimer(currentTime, startTime, endTime)
    self.statusBar:Show()

    if (not currentTime or currentTime == 0) then
        self:StopTimer()
        return
    end

    if (startTime and endTime) then
        if (self.statusBar.hasTimer and currentTime == self.statusBar.timeLeft1) then
            --it is the same timer called again
            return
        end
        self.statusBar.startTime = tonumber(startTime) or 0 --fit the number type
        self.statusBar.endTime = endTime
    else
        local bForceNewTimer = type(startTime) == "boolean" and startTime
        if (self.statusBar.hasTimer and currentTime == self.statusBar.timeLeft2 and not bForceNewTimer) then
            --it is the same timer called again
            return
        end
        self.statusBar.startTime = GetTime()
        self.statusBar.endTime = GetTime() + currentTime
        self.statusBar.timeLeft2 = currentTime
    end

    self.statusBar:SetMinMaxValues(self.statusBar.startTime, self.statusBar.endTime)

    if (self.direction == "right") then
        self.statusBar:SetReverseFill(false)
    else
        self.statusBar:SetReverseFill(true)
    end

    if (self.statusBar.dontShowSpark) then
        self.statusBar.spark:Hide()
    else
        self.statusBar.spark:Show()
        self.statusBar.spark:SetHeight(self.statusBar:GetHeight()+20)

        if (self.statusBar.sparkAlpha) then
            self.statusBar.spark:SetAlpha(self.statusBar.sparkAlpha)
        else
            self.statusBar.spark:SetAlpha(1)
        end

        if (self.statusBar.sparkColorR) then
            self.statusBar.spark:SetVertexColor(self.statusBar.sparkColorR, self.statusBar.sparkColorG, self.statusBar.sparkColorB)
        else
            self.statusBar.spark:SetVertexColor(1, 1, 1)
        end
    end

    self.statusBar.hasTimer = true
    self.statusBar.direction = self.direction
    self.statusBar.throttle = 0

    self.statusBar:SetScript("OnUpdate", OnUpdateFunc)

    local kill = self:RunHooksForWidget("OnTimerStart", self.statusBar, self)
    if (kill) then
        return
    end
end

---create a time bar widget, a timebar is a statubar that can have a timer and a spark
---@param parent frame the parent frame
---@param texture texturepath|textureid the texture of the bar
---@param width number? the width of the bar, default is 150
---@param height number? the height of the bar, default is 20
---@param value number? the initial value of the bar, default is 0
---@param member string? the name of the member in the parent frame
---@param name string? the name of the widget
---@return df_timebar
function detailsFramework:CreateTimeBar(parent, texture, width, height, value, member, name)
    if (not name) then
		name = "DetailsFrameworkBarNumber" .. detailsFramework.BarNameCounter
		detailsFramework.BarNameCounter = detailsFramework.BarNameCounter + 1

	elseif (not parent) then
		error("Details! FrameWork: parent not found.", 2)
	end

	if (name:find("$parent")) then
		local parentName = detailsFramework:GetParentName(parent)
		name = name:gsub("$parent", parentName)
	end

	local timeBar = {
        type = "timebar",
        dframework = true
    }

	if (member) then
		parent[member] = timeBar
	end

    ---@diagnostic disable-next-line: undefined-field
	if (parent.dframework) then
    ---@diagnostic disable-next-line: undefined-field
		parent = parent.widget
	end

	value = value or 0
	width = width or 150
	height = height or 20
	timeBar.locked = false

    timeBar.statusBar = CreateFrame("statusbar", name, parent, "BackdropTemplate")
    timeBar.widget = timeBar.statusBar
    detailsFramework:Mixin(timeBar.statusBar, detailsFramework.WidgetFunctions)
    timeBar.statusBar.MyObject = timeBar
    timeBar.direction = "right"

    if (not APITimeBarFunctions) then
        APITimeBarFunctions = true
        local idx = getmetatable(timeBar.statusBar).__index
        for funcName, funcAddress in pairs(idx) do
            if (not TimeBarMetaFunctions[funcName]) then
                TimeBarMetaFunctions[funcName] = function(object, ...)
                    local x = loadstring("return _G['"..object.statusBar:GetName().."']:"..funcName.."(...)")
                    if (x) then
                        return x(...)
                    end
                end
            end
        end
    end

    --create widgets
        timeBar.statusBar:SetWidth(width)
		timeBar.statusBar:SetHeight(height)
		timeBar.statusBar:SetFrameLevel(parent:GetFrameLevel()+1)
		timeBar.statusBar:SetMinMaxValues(0, 100)
		timeBar.statusBar:SetValue(value or 100)
		timeBar.statusBar:EnableMouse(false)

        timeBar.statusBar.backgroundTexture = timeBar.statusBar:CreateTexture(nil, "border")
        timeBar.statusBar.backgroundTexture:SetColorTexture(.9, .9, .9, 1)
        timeBar.statusBar.backgroundTexture:SetVertexColor(.1, .1, .1, .6)
        timeBar.statusBar.backgroundTexture:SetAllPoints()

        timeBar.statusBar.barTexture = timeBar.statusBar:CreateTexture(nil, "artwork")
        timeBar.statusBar.barTexture:SetTexture(texture or [[Interface\WorldStateFrame\WORLDSTATEFINALSCORE-HIGHLIGHT]])
        timeBar.statusBar:SetStatusBarTexture(timeBar.statusBar.barTexture)

        timeBar.statusBar.spark = timeBar.statusBar:CreateTexture(nil, "overlay", nil, 7)
        timeBar.statusBar.spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
        timeBar.statusBar.spark:SetBlendMode("ADD")
        timeBar.statusBar.spark:Hide()

        timeBar.statusBar.icon = timeBar.statusBar:CreateTexture(nil, "overlay", nil, 5)
        timeBar.statusBar.icon:SetPoint("left", timeBar.statusBar, "left", 2, 0)

        timeBar.statusBar.leftText = timeBar.statusBar:CreateFontString("$parentLeftText", "overlay", "GameFontNormal", 4)
        timeBar.statusBar.leftText:SetPoint("left", timeBar.statusBar.icon, "right", 2, 0)

        timeBar.statusBar.rightText = timeBar.statusBar:CreateFontString(nil, "overlay", "GameFontNormal", 4)
        timeBar.statusBar.rightText:SetPoint("right", timeBar.statusBar, "right", -2, 0)
        timeBar.statusBar.rightText:SetJustifyH("left")

	--hooks
		timeBar.HookList = {
			OnEnter = {},
			OnLeave = {},
			OnHide = {},
			OnShow = {},
            OnUpdate = {},
			OnMouseDown = {},
            OnMouseUp = {},
            OnTimerStart = {},
			OnTimerEnd = {},
		}

		timeBar.statusBar:SetScript("OnEnter", OnEnterFunc)
		timeBar.statusBar:SetScript("OnLeave", OnLeaveFunc)
		timeBar.statusBar:SetScript("OnHide", OnHideFunc)
		timeBar.statusBar:SetScript("OnShow", OnShowFunc)
		timeBar.statusBar:SetScript("OnMouseDown", OnMouseDownFunc)
		timeBar.statusBar:SetScript("OnMouseUp", OnMouseUpFunc)

	--set class
	setmetatable(timeBar, TimeBarMetaFunctions)

	return timeBar
end
