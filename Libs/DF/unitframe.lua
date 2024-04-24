
local detailsFramework = _G["DetailsFramework"]

if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local _
--lua locals
local rawset = rawset --lua local
local rawget = rawget --lua local
local setmetatable = setmetatable --lua local
local unpack = table.unpack or unpack --lua local
local type = type --lua local
local floor = math.floor --lua local
local loadstring = loadstring --lua local
local CreateFrame = CreateFrame

local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitGetIncomingHeals = UnitGetIncomingHeals
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitPowerMax = UnitPowerMax
local UnitPower = UnitPower
local UnitPowerBarID = UnitPowerBarID
local GetUnitPowerBarInfoByID = GetUnitPowerBarInfoByID
local IsInGroup = IsInGroup
local UnitPowerType = UnitPowerType
local UnitIsConnected = UnitIsConnected
local UnitPlayerControlled = UnitPlayerControlled
local UnitIsTapDenied = UnitIsTapDenied
local max = math.max
local min = math.min
local abs = math.abs
local GetSpellInfo = GetSpellInfo or function(spellID) if not spellID then return nil end local si = C_Spell.GetSpellInfo(spellID) if si then return si.name, nil, si.iconID, si.castTime, si.minRange, si.maxRange, si.spellID, si.originalIconID end end

local IS_WOW_PROJECT_MAINLINE = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_NOT_MAINLINE = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE
local IS_WOW_PROJECT_CLASSIC_ERA = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

local CastInfo = detailsFramework.CastInfo

local PixelUtil = PixelUtil or DFPixelUtil

local UnitGroupRolesAssigned = detailsFramework.UnitGroupRolesAssigned
local cleanfunction = function() end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--health bar frame

--[=[
	DF:CreateHealthBar (parent, name, settingsOverride)
	creates a health bar to show an unit health
	@parent = frame to pass for the CreateFrame function
	@name = absolute name of the frame, if omitted it uses the parent's name .. "HealthBar"
	@settingsOverride = table with keys and values to replace the defaults from the framework

	methods:
	healthbar:SetUnit(unit)
	healthBar:GetTexture()
	healthBar:SetTexture(texture)
--]=]

---@class df_healthbarsettings : table
---@field CanTick boolean
---@field ShowHealingPrediction boolean
---@field ShowShields boolean
---@field BackgroundColor table
---@field Texture texturepath|textureid|atlasname
---@field ShieldIndicatorTexture texturepath|textureid|atlasname
---@field ShieldGlowTexture texturepath|textureid|atlasname
---@field ShieldGlowWidth number
---@field DontSetStatusBarTexture boolean
---@field Width number
---@field Height number

---@class df_healthbar : statusbar, df_scripthookmixin, df_statusbarmixin
---@field unit unit
---@field displayedUnit unit
---@field oldHealth number
---@field currentHealth number
---@field currentHealthMax number
---@field nextShieldHook number
---@field WidgetType string
---@field Settings df_healthbarsettings
---@field background texture
---@field incomingHealIndicator texture
---@field shieldAbsorbIndicator texture
---@field healAbsorbIndicator texture
---@field shieldAbsorbGlow texture
---@field barTexture texture
---@field SetUnit fun(self:df_healthbar, unit:unit?, displayedUnit:unit)
---@field GetTexture fun(self:df_healthbar) : texture
---@field SetTexture fun(self:df_healthbar, texture:texturepath|textureid|atlasname)
---@field SetColor fun(self:df_healthbar, red:number, green:number, blue:number, alpha:number)
---@field UpdateHealPrediction fun(self:df_healthbar)
---@field UpdateHealth fun(self:df_healthbar)
---@field UpdateMaxHealth fun(self:df_healthbar)

--healthBar meta prototype
	local healthBarMetaPrototype = {
		WidgetType = "healthBar",
		dversion = detailsFramework.dversion,
	}

	--check if there's a metaPrototype already existing
	if (_G[detailsFramework.GlobalWidgetControlNames["healthBar"]]) then
		--get the already existing metaPrototype
		local oldMetaPrototype = _G[detailsFramework.GlobalWidgetControlNames["healthBar"]]
		--check if is older
		if ( (not oldMetaPrototype.dversion) or (oldMetaPrototype.dversion < detailsFramework.dversion) ) then
			--the version is older them the currently loading one
			--copy the new values into the old metatable
			for funcName, _ in pairs(healthBarMetaPrototype) do
				oldMetaPrototype[funcName] = healthBarMetaPrototype[funcName]
			end
		end
	else
		--first time loading the framework
		_G[detailsFramework.GlobalWidgetControlNames["healthBar"]] = healthBarMetaPrototype
	end

	local healthBarMetaFunctions = _G[detailsFramework.GlobalWidgetControlNames["healthBar"]]
	detailsFramework:Mixin(healthBarMetaFunctions, detailsFramework.ScriptHookMixin)

--hook list
	local defaultHooksForHealthBar = {
		OnHide = {},
		OnShow = {},
		OnHealthChange = {},
		OnHealthMaxChange = {},
		OnAbsorbOverflow = {},
	}

	--use the hook already existing
	healthBarMetaFunctions.HookList = healthBarMetaFunctions.HookList or defaultHooksForHealthBar
	--copy the non existing values from a new version to the already existing hook table
	detailsFramework.table.deploy(healthBarMetaFunctions.HookList, defaultHooksForHealthBar)

--Health Bar Meta Functions

	--health bar settings
	healthBarMetaFunctions.Settings = {
		CanTick = false, --if true calls the method 'OnTick' every tick, the function needs to be overloaded, it receives self and deltaTime as parameters
		ShowHealingPrediction = true, --when casting a healing pass, show the amount of health that spell will heal
		ShowShields = true, --indicator of the amount of damage absortion the unit has
		DontSetStatusBarTexture = false,

		--appearance
		BackgroundColor = detailsFramework:CreateColorTable (.2, .2, .2, .8),
		Texture = [[Interface\RaidFrame\Raid-Bar-Hp-Fill]],
		ShieldIndicatorTexture = [[Interface\RaidFrame\Shield-Fill]],
		ShieldGlowTexture = [[Interface\RaidFrame\Shield-Overshield]],
		ShieldGlowWidth = 16,

		--default size
		Width = 100,
		Height = 20,
	}

	healthBarMetaFunctions.HealthBarEvents = {
		{"PLAYER_ENTERING_WORLD"},
		{"UNIT_HEALTH", true},
		{"UNIT_MAXHEALTH", true},
		{(IS_WOW_PROJECT_NOT_MAINLINE) and "UNIT_HEALTH_FREQUENT", true}, -- this one is classic-only...
		{"UNIT_HEAL_PREDICTION", true},
		{(IS_WOW_PROJECT_MAINLINE) and "UNIT_ABSORB_AMOUNT_CHANGED", true},
		{(IS_WOW_PROJECT_MAINLINE) and "UNIT_HEAL_ABSORB_AMOUNT_CHANGED", true},
	}

	--setup the castbar to be used by another unit
	healthBarMetaFunctions.SetUnit = function(self, unit, displayedUnit)
		if (self.unit ~= unit or self.displayedUnit ~= displayedUnit or unit == nil) then
			self.unit = unit
			self.displayedUnit = displayedUnit or unit

			--register events
			if (unit) then
				self.currentHealth = UnitHealth(unit) or 0
				self.currentHealthMax = UnitHealthMax(unit) or 0

				for _, eventTable in ipairs(self.HealthBarEvents) do
					local event = eventTable[1]
					local isUnitEvent = eventTable[2]
					if event then
						if (isUnitEvent) then
							self:RegisterUnitEvent(event, self.displayedUnit, self.unit)
						else
							self:RegisterEvent(event)
						end
					end
				end

				--check for settings and update some events
				if (not self.Settings.ShowHealingPrediction) then
					self:UnregisterEvent("UNIT_HEAL_PREDICTION")
					if IS_WOW_PROJECT_MAINLINE then
						self:UnregisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
					end
					self.incomingHealIndicator:Hide()
					self.healAbsorbIndicator:Hide()
				end
				if (not self.Settings.ShowShields) then
					if IS_WOW_PROJECT_MAINLINE then
						self:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
					end
					self.shieldAbsorbIndicator:Hide()
					self.shieldAbsorbGlow:Hide()
				end

				--set scripts
				self:SetScript("OnEvent", self.OnEvent)

				if (self.Settings.CanTick) then
					self:SetScript("OnUpdate", self.OnTick)
				end

				self:PLAYER_ENTERING_WORLD(self.unit, self.displayedUnit)
			else
				--remove all registered events
				for _, eventTable in ipairs(self.HealthBarEvents) do
					local event = eventTable[1]
					if event then
						self:UnregisterEvent(event)
					end
				end

				--remove scripts
				self:SetScript("OnEvent", nil)
				self:SetScript("OnUpdate", nil)
				self:Hide()
			end
		end
	end

	healthBarMetaFunctions.Initialize = function(self)
		PixelUtil.SetWidth(self, self.Settings.Width, 1)
		PixelUtil.SetHeight(self, self.Settings.Height, 1)

		self:SetTexture(self.Settings.Texture)

		self.background:SetAllPoints()
		self.background:SetColorTexture(self.Settings.BackgroundColor:GetColor())

		--setpoint of these widgets are set inside the function that updates the incoming heal
		self.incomingHealIndicator:SetTexture(self:GetTexture())
		self.healAbsorbIndicator:SetTexture(self:GetTexture())
		self.healAbsorbIndicator:SetVertexColor(.1, .8, .8)
		self.shieldAbsorbIndicator:SetTexture(self.Settings.ShieldIndicatorTexture, true, true)

		self.shieldAbsorbGlow:SetWidth(self.Settings.ShieldGlowWidth)
		self.shieldAbsorbGlow:SetTexture(self.Settings.ShieldGlowTexture)
		self.shieldAbsorbGlow:SetBlendMode("ADD")
		self.shieldAbsorbGlow:SetPoint("topright", self, "topright", 8, 0)
		self.shieldAbsorbGlow:SetPoint("bottomright", self, "bottomright", 8, 0)
		self.shieldAbsorbGlow:Hide()

		self:SetUnit(nil)

		self.currentHealth = 1
		self.currentHealthMax = 2
	end

	--call every tick
	healthBarMetaFunctions.OnTick = function(self, deltaTime) end --if overrided, set 'CanTick' to true on the settings table

	--when an event happen for this unit, send it to the apropriate function
	healthBarMetaFunctions.OnEvent = function(self, event, ...)
		local eventFunc = self[event]
		if (eventFunc) then
			--the function doesn't receive which event was, only 'self' and the parameters
			eventFunc(self, ...)
		end
	end

	--when the unit max health is changed
	healthBarMetaFunctions.UpdateMaxHealth = function(self)
		local maxHealth = UnitHealthMax(self.displayedUnit)
		self:SetMinMaxValues(0, maxHealth)
		self.currentHealthMax = maxHealth

		if (self.OnHealthMaxChange) then --direct call
			self.OnHealthMaxChange(self, self.displayedUnit)
		else
			self:RunHooksForWidget("OnHealthMaxChange", self, self.displayedUnit)
		end
	end

	healthBarMetaFunctions.UpdateHealth = function(self)
		-- update max health regardless to avoid weird wrong values on UpdateMaxHealth sometimes
		-- local maxHealth = UnitHealthMax(self.displayedUnit)
		-- self:SetMinMaxValues(0, maxHealth)
		-- self.currentHealthMax = maxHealth

		self.oldHealth = self.currentHealth
		local health = UnitHealth(self.displayedUnit)
		self.currentHealth = health
		PixelUtil.SetStatusBarValue(self, health)

		if (self.OnHealthChange) then --direct call
			self.OnHealthChange(self, self.displayedUnit)
		else
			self:RunHooksForWidget("OnHealthChange", self, self.displayedUnit)
		end
	end

	--health and absorbs prediction
	healthBarMetaFunctions.UpdateHealPrediction = function(self)
		local currentHealth = self.currentHealth
		local currentHealthMax = self.currentHealthMax

		if (not currentHealthMax or currentHealthMax <= 0) then
			return
		end

		local healthPercent = currentHealth / currentHealthMax

		--order is: the health of the unit > damage absorb > heal absorb > incoming heal
		local width = self:GetWidth()

		if (self.Settings.ShowHealingPrediction) then
			--incoming heal on the unit from all sources
			local unitHealIncoming = self.displayedUnit and UnitGetIncomingHeals(self.displayedUnit) or 0
			--heal absorbs
			local unitHealAbsorb = IS_WOW_PROJECT_MAINLINE and self.displayedUnit and UnitGetTotalHealAbsorbs(self.displayedUnit) or 0

			if (unitHealIncoming > 0) then
				--calculate what is the percent of health incoming based on the max health the player has
				local incomingPercent = unitHealIncoming / currentHealthMax
				self.incomingHealIndicator:Show()
				self.incomingHealIndicator:SetWidth(max(1, min (width * incomingPercent, abs(healthPercent - 1) * width)))
				self.incomingHealIndicator:SetPoint("topleft", self, "topleft", width * healthPercent, 0)
				self.incomingHealIndicator:SetPoint("bottomleft", self, "bottomleft", width * healthPercent, 0)
			else
				self.incomingHealIndicator:Hide()
			end

			if (unitHealAbsorb > 0) then
				local healAbsorbPercent = unitHealAbsorb / currentHealthMax
				self.healAbsorbIndicator:Show()
				self.healAbsorbIndicator:SetWidth(max(1, min (width * healAbsorbPercent, abs(healthPercent - 1) * width)))
				self.healAbsorbIndicator:SetPoint("topleft", self, "topleft", width * healthPercent, 0)
				self.healAbsorbIndicator:SetPoint("bottomleft", self, "bottomleft", width * healthPercent, 0)
			else
				self.healAbsorbIndicator:Hide()
			end
		end

		if (self.Settings.ShowShields and IS_WOW_PROJECT_MAINLINE) then
			--damage absorbs
			local unitDamageAbsorb = self.displayedUnit and UnitGetTotalAbsorbs (self.displayedUnit) or 0

			if (unitDamageAbsorb > 0) then
				local damageAbsorbPercent = unitDamageAbsorb / currentHealthMax
				self.shieldAbsorbIndicator:Show()
				--set the width where the max width size is what is lower: the absorb size or the missing amount of health in the health bar
				--/dump NamePlate1PlaterUnitFrameHealthBar.shieldAbsorbIndicator:GetSize()
				self.shieldAbsorbIndicator:SetWidth(max(1, min (width * damageAbsorbPercent, abs(healthPercent - 1) * width)))
				self.shieldAbsorbIndicator:SetPoint("topleft", self, "topleft", width * healthPercent, 0)
				self.shieldAbsorbIndicator:SetPoint("bottomleft", self, "bottomleft", width * healthPercent, 0)

				--if the absorb percent pass 100%, show the glow
				if ((healthPercent + damageAbsorbPercent) > 1) then
					self.nextShieldHook = self.nextShieldHook or 0

					if (GetTime() >= self.nextShieldHook) then
						self:RunHooksForWidget("OnAbsorbOverflow", self, self.displayedUnit, healthPercent + damageAbsorbPercent - 1)
						self.nextShieldHook = GetTime() + 0.2
					end

					self.shieldAbsorbGlow:Show()
				else
					self.shieldAbsorbGlow:Hide()
					if (self.nextShieldHook) then
						self:RunHooksForWidget("OnAbsorbOverflow", self, self.displayedUnit, 0)
						self.nextShieldHook = nil
					end
				end
			else
				self.shieldAbsorbIndicator:Hide()
				self.shieldAbsorbGlow:Hide()
				if (self.nextShieldHook) then
					self:RunHooksForWidget("OnAbsorbOverflow", self, self.displayedUnit, 0)
					self.nextShieldHook = nil
				end
			end
		else
			self.shieldAbsorbIndicator:Hide()
			self.shieldAbsorbGlow:Hide()
			if (self.nextShieldHook) then
				self:RunHooksForWidget("OnAbsorbOverflow", self, self.displayedUnit, 0)
				self.nextShieldHook = nil
			end
		end
	end

	--Health Events
		healthBarMetaFunctions.PLAYER_ENTERING_WORLD = function(self, ...)
			self:UpdateMaxHealth()
			self:UpdateHealth()
			self:UpdateHealPrediction()
		end

		healthBarMetaFunctions.UNIT_HEALTH = function(self, unitId)
			self:UpdateHealth()
			self:UpdateHealPrediction()
		end

		healthBarMetaFunctions.UNIT_MAXHEALTH = function(self, unitId)
			self:UpdateMaxHealth()
			self:UpdateHealth()
			self:UpdateHealPrediction()
		end

		healthBarMetaFunctions.UNIT_HEALTH_FREQUENT = function(self, ...)
			self:UpdateHealth()
			self:UpdateHealPrediction()
		end

		healthBarMetaFunctions.UNIT_HEAL_PREDICTION = function(self, ...)
			self:UpdateMaxHealth()
			self:UpdateHealth()
			self:UpdateHealPrediction()
		end

		healthBarMetaFunctions.UNIT_ABSORB_AMOUNT_CHANGED = function(self, ...)
			self:UpdateMaxHealth()
			self:UpdateHealth()
			self:UpdateHealPrediction()
		end

		healthBarMetaFunctions.UNIT_HEAL_ABSORB_AMOUNT_CHANGED = function(self, ...)
			self:UpdateMaxHealth()
			self:UpdateHealth()
			self:UpdateHealPrediction()
		end

-- ~healthbar

---comment
---@param parent frame
---@param name string?
---@param settingsOverride table?  a table with key/value pairs to override the default settings
---@return df_healthbar
function detailsFramework:CreateHealthBar(parent, name, settingsOverride)
	assert(name or parent:GetName(), "DetailsFramework:CreateHealthBar parameter 'name' omitted and parent has no name.")

	local healthBar = CreateFrame("StatusBar", name or (parent:GetName() .. "HealthBar"), parent, "BackdropTemplate")
		do --layers
			--background
			healthBar.background = healthBar:CreateTexture(nil, "background")
			healthBar.background:SetDrawLayer("background", -6)

			--artwork
			--healing incoming
			healthBar.incomingHealIndicator = healthBar:CreateTexture(nil, "artwork", nil, 5)
			healthBar.incomingHealIndicator:SetDrawLayer("artwork", 4)
			--current shields on the unit
			healthBar.shieldAbsorbIndicator =  healthBar:CreateTexture(nil, "artwork", nil, 3)
			healthBar.shieldAbsorbIndicator:SetDrawLayer("artwork", 5)
			--debuff absorbing heal
			healthBar.healAbsorbIndicator = healthBar:CreateTexture(nil, "artwork", nil, 4)
			healthBar.healAbsorbIndicator:SetDrawLayer("artwork", 6)
			--the shield fills all the bar, show that cool glow
			healthBar.shieldAbsorbGlow = healthBar:CreateTexture(nil, "artwork", nil, 6)
			healthBar.shieldAbsorbGlow:SetDrawLayer("artwork", 7)
			--statusbar texture
			healthBar.barTexture = healthBar:CreateTexture(nil, "artwork", nil, 1)
		end

	--mixins
	detailsFramework:Mixin(healthBar, healthBarMetaFunctions)
	detailsFramework:Mixin(healthBar, detailsFramework.StatusBarFunctions)

	healthBar:CreateTextureMask()
	healthBar:SetTexture([[Interface\WorldStateFrame\WORLDSTATEFINALSCORE-HIGHLIGHT]])

	--settings and hooks
	local settings = detailsFramework.table.copy({}, healthBarMetaFunctions.Settings)
	if (settingsOverride) then
		detailsFramework.table.copy(settings, settingsOverride)
	end
	healthBar.Settings = settings

	if (healthBar.Settings.DontSetStatusBarTexture) then
		healthBar.barTexture:SetAllPoints()
	else
		healthBar:SetStatusBarTexture(healthBar.barTexture)
	end

	--hook list
	healthBar.HookList = detailsFramework.table.copy({}, healthBarMetaFunctions.HookList)

	--initialize the cast bar
	healthBar:Initialize()

	return healthBar
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--power bar frame

--[=[
	DF:CreatePowerBar (parent, name, settingsOverride)
	creates statusbar frame to show the unit power bar
	@parent = frame to pass for the CreateFrame function
	@name = absolute name of the frame, if omitted it uses the parent's name .. "PPowerBar"
	@settingsOverride = table with keys and values to replace the defaults from the framework
--]=]

---@class df_powerbarsettings : table
---@field ShowAlternatePower boolean
---@field ShowPercentText boolean
---@field HideIfNoPower boolean
---@field CanTick boolean
---@field BackgroundColor table
---@field Texture texturepath|textureid|atlasname
---@field Width number
---@field Height number

---@class df_powerbar : statusbar, df_scripthookmixin, df_statusbarmixin
---@field unit string
---@field displayedUnit string
---@field WidgetType string
---@field currentPower number
---@field currentPowerMax number
---@field powerType number
---@field minPower number
---@field Settings df_powerbarsettings
---@field background texture
---@field percentText fontstring
---@field SetUnit fun(self:df_healthbar, unit:unit?, displayedUnit:unit?)

detailsFramework.PowerFrameFunctions = {
	WidgetType = "powerBar",

	HookList = {
		OnHide = {},
		OnShow = {},
	},

	Settings = {
		--misc
		ShowAlternatePower = true, --if true it'll show alternate power over the regular power the unit uses
		ShowPercentText = true, --if true show a text with the current energy percent
		HideIfNoPower = true, --if true and the UnitMaxPower returns zero, it'll hide the power bar with self:Hide()
		CanTick = false, --if it calls the OnTick function every tick

		--appearance
		BackgroundColor = detailsFramework:CreateColorTable (.2, .2, .2, .8),
		Texture = [[Interface\RaidFrame\Raid-Bar-Resource-Fill]],

		--default size
		Width = 100,
		Height = 20,
	},

	PowerBarEvents = {
		{"PLAYER_ENTERING_WORLD"},
		{"UNIT_DISPLAYPOWER", true},
		{"UNIT_POWER_BAR_SHOW", true},
		{"UNIT_POWER_BAR_HIDE", true},
		{"UNIT_MAXPOWER", true},
		{"UNIT_POWER_UPDATE", true},
		{"UNIT_POWER_FREQUENT", true},
	},

	--setup the castbar to be used by another unit
	SetUnit = function(self, unit, displayedUnit)
		if (self.unit ~= unit or self.displayedUnit ~= displayedUnit or unit == nil) then
			self.unit = unit
			self.displayedUnit = displayedUnit or unit

			--register events
			if (unit) then
				for _, eventTable in ipairs(self.PowerBarEvents) do
					local event = eventTable[1]
					local isUnitEvent = eventTable[2]

					if (isUnitEvent) then
						self:RegisterUnitEvent(event, self.displayedUnit)
					else
						self:RegisterEvent(event)
					end
				end

				--set scripts
				self:SetScript("OnEvent", self.OnEvent)

				if (self.Settings.CanTick) then
					self:SetScript("OnUpdate", self.OnTick)
				end

				self:Show()
				self:UpdatePowerBar()
			else
				--remove all registered events
				for _, eventTable in ipairs(self.PowerBarEvents) do
					local event = eventTable[1]
					self:UnregisterEvent(event)
				end

				--remove scripts
				self:SetScript("OnEvent", nil)
				self:SetScript("OnUpdate", nil)
				self:Hide()
			end
		end
	end,

	Initialize = function(self)
		PixelUtil.SetWidth (self, self.Settings.Width)
		PixelUtil.SetHeight(self, self.Settings.Height)

		self:SetTexture(self.Settings.Texture)

		self.background:SetAllPoints()
		self.background:SetColorTexture(self.Settings.BackgroundColor:GetColor())

		if (self.Settings.ShowPercentText) then
			self.percentText:Show()
			PixelUtil.SetPoint(self.percentText, "center", self, "center", 0, 0)

			detailsFramework:SetFontSize(self.percentText, 9)
			detailsFramework:SetFontColor(self.percentText, "white")
			detailsFramework:SetFontOutline(self.percentText, "OUTLINE")
		else
			self.percentText:Hide()
		end

		self:SetUnit(nil)
	end,

	--call every tick
	OnTick = function(self, deltaTime) end, --if overrided, set 'CanTick' to true on the settings table

	--when an event happen for this unit, send it to the apropriate function
	OnEvent = function(self, event, ...)
		local eventFunc = self[event]
		if (eventFunc) then
			--the function doesn't receive which event was, only 'self' and the parameters
			eventFunc(self, ...)
		end
	end,

	UpdatePowerBar = function(self)
		self:UpdatePowerInfo()
		self:UpdateMaxPower()
		self:UpdatePower()
		self:UpdatePowerColor()
	end,

	--power update
	UpdateMaxPower = function(self)
		self.currentPowerMax = UnitPowerMax(self.displayedUnit, self.powerType)
		self:SetMinMaxValues(self.minPower, self.currentPowerMax)

		if (self.currentPowerMax == 0 and self.Settings.HideIfNoPower) then
			self:Hide()
		end
	end,

	UpdatePower = function(self)
		self.currentPower = UnitPower(self.displayedUnit, self.powerType)
		PixelUtil.SetStatusBarValue(self, self.currentPower)

		if (self.Settings.ShowPercentText) then
			self.percentText:SetText(floor(self.currentPower / self.currentPowerMax * 100) .. "%")
		end
	end,

	--when a event different from unit_power_update is triggered, update which type of power the unit should show
	UpdatePowerInfo = function(self)
		if (IS_WOW_PROJECT_MAINLINE and self.Settings.ShowAlternatePower) then -- not available in classic
			local barID = UnitPowerBarID(self.displayedUnit)
			local barInfo = GetUnitPowerBarInfoByID(barID)
			--local name, tooltip, cost = GetUnitPowerBarStringsByID(barID);
			--barInfo.barType,barInfo.minPower, barInfo.startInset, barInfo.endInset, barInfo.smooth, barInfo.hideFromOthers, barInfo.showOnRaid, barInfo.opaqueSpark, barInfo.opaqueFlash, barInfo.anchorTop, name, tooltip, cost, barInfo.ID, barInfo.forcePercentage, barInfo.sparkUnderFrame;
			if (barInfo and barInfo.showOnRaid and IsInGroup()) then
				self.powerType = ALTERNATE_POWER_INDEX
				self.minPower = barInfo.minPower
				return
			end
		end

		self.powerType = UnitPowerType (self.displayedUnit)
		self.minPower = 0
	end,

	--tint the bar with the color of the power, e.g. blue for a mana bar
	UpdatePowerColor = function(self)
		if (not UnitIsConnected (self.unit)) then
			self:SetStatusBarColor(.5, .5, .5)
			return
		end

		if (self.powerType == ALTERNATE_POWER_INDEX) then
			--don't change this, keep the same color as the game tints on CompactUnitFrame.lua
			self:SetStatusBarColor(0.7, 0.7, 0.6)
			return
		end

		local powerColor = PowerBarColor[self.powerType] --don't appear to be, but PowerBarColor is a global table with all power colors /run Details:Dump (PowerBarColor)
		if (powerColor) then
			self:SetStatusBarColor(powerColor.r, powerColor.g, powerColor.b)
			return
		end

		local _, _, r, g, b = UnitPowerType(self.displayedUnit)
		if (r) then
			self:SetStatusBarColor(r, g, b)
			return
		end

		--if everything else fails, tint as rogue energy
		powerColor = PowerBarColor["ENERGY"]
		self:SetStatusBarColor(powerColor.r, powerColor.g, powerColor.b)
	end,

	--events
	PLAYER_ENTERING_WORLD = function(self, ...)
		self:UpdatePowerBar()
	end,
	UNIT_DISPLAYPOWER  = function(self, ...)
		self:UpdatePowerBar()
	end,
	UNIT_POWER_BAR_SHOW = function(self, ...)
		self:UpdatePowerBar()
	end,
	UNIT_POWER_BAR_HIDE = function(self, ...)
		self:UpdatePowerBar()
	end,

	UNIT_MAXPOWER = function(self, ...)
		self:UpdateMaxPower()
		self:UpdatePower()
	end,
	UNIT_POWER_UPDATE = function(self, ...)
		self:UpdatePower()
	end,
	UNIT_POWER_FREQUENT = function(self, ...)
		self:UpdatePower()
	end,
}

detailsFramework:Mixin(detailsFramework.PowerFrameFunctions, detailsFramework.ScriptHookMixin)

-- ~powerbar

---create a power bar
---@param parent frame
---@param name string?
---@param settingsOverride table? a table with key/value pairs to override the default settings
---@return df_powerbar
function detailsFramework:CreatePowerBar(parent, name, settingsOverride)
	assert(name or parent:GetName(), "DetailsFramework:CreatePowerBar parameter 'name' omitted and parent has no name.")

	local powerBar = CreateFrame("StatusBar", name or (parent:GetName() .. "PowerBar"), parent, "BackdropTemplate")
		do --layers
			--background
			powerBar.background = powerBar:CreateTexture(nil, "background")
			powerBar.background:SetDrawLayer("background", -6)

			--artwork
			powerBar.barTexture = powerBar:CreateTexture(nil, "artwork")
			powerBar:SetStatusBarTexture(powerBar.barTexture)

			--overlay
			powerBar.percentText = powerBar:CreateFontString(nil, "overlay", "GameFontNormal")
		end

	--mixins
	detailsFramework:Mixin(powerBar, detailsFramework.PowerFrameFunctions)
	detailsFramework:Mixin(powerBar, detailsFramework.StatusBarFunctions)

	powerBar:CreateTextureMask()
	powerBar:SetTexture([[Interface\WorldStateFrame\WORLDSTATEFINALSCORE-HIGHLIGHT]])

	--settings and hooks
	local settings = detailsFramework.table.copy({}, detailsFramework.PowerFrameFunctions.Settings)
	if (settingsOverride) then
		detailsFramework.table.copy(settings, settingsOverride)
	end
	powerBar.Settings = settings

	local hookList = detailsFramework.table.copy({}, detailsFramework.PowerFrameFunctions.HookList)
	powerBar.HookList = hookList

	--initialize the cast bar
	powerBar:Initialize()

	return powerBar
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--cast bar frame

--[=[
	DF:CreateCastBar (parent, name, settingsOverride)
	creates a cast bar to show an unit cast
	@parent = frame to pass for the CreateFrame function
	@name = absolute name of the frame, if omitted it uses the parent's name .. "CastBar"
	@settingsOverride = table with keys and values to replace the defaults from the framework
--]=]

---@class df_castbarsettings : table
---@field NoFadeEffects  boolean if true it won't play fade effects when a cast if finished
---@field ShowTradeSkills boolean if true, it shows cast for trade skills, e.g. creating an icon with blacksmith
---@field ShowShield boolean if true, shows the shield above the spell icon for non interruptible casts
---@field CanTick boolean if true it will run its OnTick function every tick.
---@field ShowCastTime boolean if true, show the remaining time to finish the cast, lazy tick must be enabled
---@field FadeInTime number amount of time in seconds to go from zero to 100% alpha when starting to cast
---@field FadeOutTime number amount of time in seconds to go from 100% to zero alpha when the cast finishes
---@field CanLazyTick boolean if true, it'll execute the lazy tick function, it ticks in a much slower pace comparece with the regular tick
---@field LazyUpdateCooldown number amount of time to wait for the next lazy update, this updates non critical things like the cast timer
---@field ShowEmpoweredDuration boolean full hold time for empowered spells
---@field FillOnInterrupt boolean
---@field HideSparkOnInterrupt boolean
---@field Width number
---@field Height number
---@field Colors df_castcolors
---@field BackgroundColor table
---@field Texture texturepath|textureid
---@field BorderShieldWidth number
---@field BorderShieldHeight number
---@field BorderShieldCoords table
---@field BorderShieldTexture number
---@field SpellIconWidth number
---@field SpellIconHeight number
---@field ShieldIndicatorTexture texturepath|textureid
---@field ShieldGlowTexture texturepath|textureid
---@field SparkTexture texturepath|textureid
---@field SparkWidth number
---@field SparkHeight number
---@field SparkOffset number

---@alias caststage_color
---| "Casting"
---| "Channeling"
---| "Interrupted"
---| "Failed"
---| "NotInterruptable"
---| "Finished"

---@class df_castcolors : table
---@field Casting table
---@field Channeling table
---@field Interrupted table
---@field Failed table
---@field NotInterruptable table
---@field Finished table

---@class df_castbar : statusbar, df_scripthookmixin, df_statusbarmixin
---@field unit string
---@field displayedUnit string
---@field WidgetType string
---@field value number
---@field maxValue number
---@field spellStartTime number
---@field spellEndTime number
---@field empowered boolean
---@field curStage number
---@field numStages number
---@field empStages {start:number, finish:number}[]
---@field stagePips texture[]
---@field holdAtMaxTime number
---@field casting boolean
---@field channeling boolean
---@field interrupted boolean
---@field failed boolean
---@field finished boolean
---@field canInterrupt boolean
---@field spellID spellid
---@field castID number
---@field spellName spellname
---@field spellTexture textureid
---@field Colors df_castcolors
---@field Settings df_castbarsettings
---@field background texture
---@field extraBackground texture
---@field Text fontstring
---@field BorderShield texture
---@field Icon texture
---@field Spark texture
---@field percentText fontstring
---@field barTexture texture
---@field flashTexture texture
---@field fadeOutAnimation animationgroup
---@field fadeInAnimation animationgroup
---@field flashAnimation animationgroup
---@field SetUnit fun(self:df_castbar, unit:string?)
---@field SetDefaultColor fun(self:df_castbar, colorType: caststage_color, red:any, green:number?, blue:number?, alpha:number?)
---@field UpdateCastColor fun(self:df_castbar) after setting a new color, call this function to update the bar color (while casting or channeling)
---@field GetCastColor fun(self:df_castbar) return a table with the color values for the current state of the casting process

detailsFramework.CastFrameFunctions = {
	WidgetType = "castBar",

	HookList = {
		OnHide = {},
		OnShow = {},

		--can be regular cast or channel
		OnCastStart = {},
	},

	CastBarEvents = {
		{"UNIT_SPELLCAST_INTERRUPTED"},
		{"UNIT_SPELLCAST_DELAYED"},
		{"UNIT_SPELLCAST_CHANNEL_START"},
		{"UNIT_SPELLCAST_CHANNEL_UPDATE"},
		{"UNIT_SPELLCAST_CHANNEL_STOP"},
		{(IS_WOW_PROJECT_MAINLINE) and "UNIT_SPELLCAST_EMPOWER_START"},
		{(IS_WOW_PROJECT_MAINLINE) and "UNIT_SPELLCAST_EMPOWER_UPDATE"},
		{(IS_WOW_PROJECT_MAINLINE) and "UNIT_SPELLCAST_EMPOWER_STOP"},
		{(IS_WOW_PROJECT_MAINLINE) and "UNIT_SPELLCAST_INTERRUPTIBLE"},
		{(IS_WOW_PROJECT_MAINLINE) and "UNIT_SPELLCAST_NOT_INTERRUPTIBLE"},
		{"PLAYER_ENTERING_WORLD"},
		{"UNIT_SPELLCAST_START", true},
		{"UNIT_SPELLCAST_STOP", true},
		{"UNIT_SPELLCAST_FAILED", true},
	},

	Settings = {
		NoFadeEffects = false, --if true it won't play fade effects when a cast if finished
		ShowTradeSkills = false, --if true, it shows cast for trade skills, e.g. creating an icon with blacksmith
		ShowShield = true, --if true, shows the shield above the spell icon for non interruptible casts
		CanTick = true, --if true it will run its OnTick function every tick.
		ShowCastTime = true, --if true, show the remaining time to finish the cast, lazy tick must be enabled
		FadeInTime = 0.1, --amount of time in seconds to go from zero to 100% alpha when starting to cast
		FadeOutTime = 0.5, --amount of time in seconds to go from 100% to zero alpha when the cast finishes
		CanLazyTick = true, --if true, it'll execute the lazy tick function, it ticks in a much slower pace comparece with the regular tick
		LazyUpdateCooldown = 0.2, --amount of time to wait for the next lazy update, this updates non critical things like the cast timer

		ShowEmpoweredDuration = true, --full hold time for empowered spells

		FillOnInterrupt = true,
		HideSparkOnInterrupt = true,

		--default size
		Width = 100,
		Height = 20,

		--colour the castbar statusbar by the type of the cast
		Colors = {
			Casting = detailsFramework:CreateColorTable (1, 0.73, .1, 1),
			Channeling = detailsFramework:CreateColorTable (1, 0.73, .1, 1),
			Finished = detailsFramework:CreateColorTable (0, 1, 0, 1),
			NonInterruptible = detailsFramework:CreateColorTable (.7, .7, .7, 1),
			Failed = detailsFramework:CreateColorTable (.4, .4, .4, 1),
			Interrupted = detailsFramework:CreateColorTable (.965, .754, .154, 1),
		},

		--appearance
		BackgroundColor = detailsFramework:CreateColorTable (.2, .2, .2, .8),
		Texture = [[Interface\TargetingFrame\UI-StatusBar]],
		BorderShieldWidth = 10,
		BorderShieldHeight = 12,
		BorderShieldCoords = {0.26171875, 0.31640625, 0.53125, 0.65625},
		BorderShieldTexture = 1300837,
		SpellIconWidth = 10,
		SpellIconHeight = 10,
		ShieldIndicatorTexture = [[Interface\RaidFrame\Shield-Fill]],
		ShieldGlowTexture = [[Interface\RaidFrame\Shield-Overshield]],
		SparkTexture = [[Interface\CastingBar\UI-CastingBar-Spark]],
		SparkWidth = 16,
		SparkHeight = 16,
		SparkOffset = 0,
	},

	Initialize = function(self)
		self.unit = "unutilized unit"
		self.lazyUpdateCooldown = self.Settings.LazyUpdateCooldown
		self.Colors = self.Settings.Colors

		self:SetUnit(nil)
		PixelUtil.SetWidth (self, self.Settings.Width)
		PixelUtil.SetHeight(self, self.Settings.Height)

		self.background:SetColorTexture(self.Settings.BackgroundColor:GetColor())
		self.background:SetAllPoints()
		self.extraBackground:SetColorTexture(0, 0, 0, 1)
		self.extraBackground:SetVertexColor(self.Settings.BackgroundColor:GetColor())
		self.extraBackground:SetAllPoints()

		self:SetTexture(self.Settings.Texture)

		self.BorderShield:SetPoint("center", self, "left", 0, 0)
		self.BorderShield:SetTexture(self.Settings.BorderShieldTexture)
		self.BorderShield:SetTexCoord(unpack(self.Settings.BorderShieldCoords))
		self.BorderShield:SetSize(self.Settings.BorderShieldWidth, self.Settings.BorderShieldHeight)

		self.Icon:SetPoint("center", self, "left", 2, 0)
		self.Icon:SetSize(self.Settings.SpellIconWidth, self.Settings.SpellIconHeight)

		self.Spark:SetTexture(self.Settings.SparkTexture)
		self.Spark:SetSize(self.Settings.SparkWidth, self.Settings.SparkHeight)

		self.percentText:SetPoint("right", self, "right", -2, 0)
		self.percentText:SetJustifyH("right")

		self.fadeOutAnimation.alpha1:SetDuration(self.Settings.FadeOutTime)
		self.fadeInAnimation.alpha1:SetDuration(self.Settings.FadeInTime)
	end,

	SetDefaultColor = function(self, colorType, r, g, b, a)
		assert(type(colorType) == "string", "DetailsFramework: CastBar:SetDefaultColor require a string in the first argument.")
		self.Colors[colorType]:SetColor(r, g, b, a)
	end,

	--this get a color suggestion based on the type of cast being shown in the cast bar
	GetCastColor = function(self)
		if (not self.canInterrupt) then
			return self.Colors.NonInterruptible

		elseif (self.channeling) then
			return self.Colors.Channeling

		elseif (self.failed) then
			return self.Colors.Failed

		elseif (self.interrupted) then
			return self.Colors.Interrupted

		elseif (self.finished) then
			return self.Colors.Finished

		else
			return self.Colors.Casting
		end
	end,

	--update all colors of the cast bar
	UpdateCastColor = function(self)
		local castColor = self:GetCastColor()
		self:SetColor(castColor) --SetColor handles with ParseColors()
	end,

	--initial checks to know if this is a valid cast and should show the cast bar, if this fails the cast bar won't show
	IsValid = function(self, unit, castName, isTradeSkill, ignoreVisibility)
		if (not ignoreVisibility and not self:IsShown()) then
			return false
		end

		if (not self.Settings.ShowTradeSkills) then
			if (isTradeSkill) then
				return false
			end
		end

		if (not castName) then
			return false
		end

		return true
	end,

	--handle the interrupt state of the cast
	--this does not change the cast bar color because this function is called inside the start cast where is already handles the cast color
	UpdateInterruptState = function(self)
		if (self.Settings.ShowShield and not self.canInterrupt) then
			self.BorderShield:Show()
		else
			self.BorderShield:Hide()
		end
	end,

	--this check if the cast did reach 100% in the statusbar, mostly called from OnTick
	CheckCastIsDone = function(self, event, isFinished)
		--check max value
		if (not isFinished and not self.finished) then
			if (self.casting) then
				if (self.value >= self.maxValue) then
					isFinished = true
				end

			elseif (self.channeling) then
				if (self.value > self.maxValue or self.value <= 0) then
					isFinished = true
				end
			end

			--check if passed an event (not begin used at the moment)
			if (event) then
				if (event == UNIT_SPELLCAST_STOP or event == UNIT_SPELLCAST_CHANNEL_STOP) then
					isFinished = true
				end
			end
		end

		--the cast is finished
		if (isFinished) then
			if (self.casting) then
				self.UNIT_SPELLCAST_STOP(self, self.unit, self.unit, self.castID, self.spellID)

			elseif (self.channeling) then
				self.UNIT_SPELLCAST_CHANNEL_STOP(self, self.unit, self.unit, self.castID, self.spellID)
			end

			return true
		end
	end,

	--setup the castbar to be used by another unit
	SetUnit = function(self, unit, displayedUnit)
		if (self.unit ~= unit or self.displayedUnit ~= displayedUnit or unit == nil) then
			self.unit = unit
			self.displayedUnit = displayedUnit or unit

			--reset the cast bar
			self.casting = nil
			self.channeling = nil
			self.caninterrupt = nil

			--register events
			if (unit) then
				for _, eventTable in ipairs(self.CastBarEvents) do
					local event = eventTable[1]
					local isUnitEvent = eventTable[2]

					if event then
						if (isUnitEvent) then
							self:RegisterUnitEvent(event, unit)
						else
							self:RegisterEvent(event)
						end
					end
				end

				--set scripts
				self:SetScript("OnEvent", self.OnEvent)
				self:SetScript("OnShow", self.OnShow)
				self:SetScript("OnHide", self.OnHide)

				if (self.Settings.CanTick) then
					self:SetScript("OnUpdate", self.OnTick)
				end

				--check is can show the cast time text
				if (self.Settings.ShowCastTime and self.Settings.CanLazyTick) then
					self.percentText:Show()
				else
					self.percentText:Hide()
				end

				--setup animtions
				self:CancelScheduleToHide()

				--self:PLAYER_ENTERING_WORLD (unit, unit)
				self:OnEvent("PLAYER_ENTERING_WORLD", unit, unit)

			else
				for _, eventTable in ipairs(self.CastBarEvents) do
					local event = eventTable[1]
					if event then
						self:UnregisterEvent(event)
					end
				end

				--register main events
				self:SetScript("OnUpdate", nil)
				self:SetScript("OnEvent", nil)
				self:SetScript("OnShow", nil)
				self:SetScript("OnHide", nil)

				self:Hide()
			end
		end
	end,

	--executed after a scheduled to hide timer is done
	DoScheduledHide = function(timerObject)
		timerObject.castBar.scheduledHideTime = nil

		--just to make sure it isn't casting
		if (not timerObject.castBar.casting and not timerObject.castBar.channeling) then
			if (not timerObject.castBar.Settings.NoFadeEffects) then
				timerObject.castBar:Animation_FadeOut()
			else
				timerObject.castBar:Hide()
			end
		end
	end,

	HasScheduledHide = function(self)
		return self.scheduledHideTime and not self.scheduledHideTime:IsCancelled()
	end,

	CancelScheduleToHide = function(self)
		if (self:HasScheduledHide()) then
			self.scheduledHideTime:Cancel()
		end
	end,

	--after an interrupt, do not immediately hide the cast bar, let it up for short amount of time to give feedback to the player
	ScheduleToHide = function(self, delay)
		if (not delay) then
			if (self.scheduledHideTime and not self.scheduledHideTime:IsCancelled()) then
				self.scheduledHideTime:Cancel()
			end

			self.scheduledHideTime = nil
			return
		end

		--already have a scheduled timer?
		if (self.scheduledHideTime and not self.scheduledHideTime:IsCancelled()) then
			self.scheduledHideTime:Cancel()
		end

		self.scheduledHideTime = C_Timer.NewTimer(delay, self.DoScheduledHide)
		self.scheduledHideTime.castBar = self
	end,

	OnHide = function(self)
		--just in case some other effects made it have a different alpha since SetUnit won't load if the unit is the same.
		self:SetAlpha(1)
		--cancel any timer to hide scheduled
		self:CancelScheduleToHide()
	end,

	--just update the current value if a spell is being cast since it wasn't running its tick function during the hide state
	--everything else should be in the correct state
	OnShow = function(self)
		self.flashTexture:Hide()

		if (self.unit) then
			if (self.casting) then
				local name, text, texture, startTime = CastInfo.UnitCastingInfo(self.unit)
				if (name) then
					--[[if not self.spellStartTime then
						self:UpdateCastingInfo(self.unit)
					end]]--
					self.value = GetTime() - self.spellStartTime
				end

				self:RunHooksForWidget("OnShow", self, self.unit)

			elseif (self.channeling) then
				local name, text, texture, endTime = CastInfo.UnitChannelInfo(self.unit)
				if (name) then
					--[[if not self.spellEndTime then
						self:UpdateChannelInfo(self.unit)
					end]]--
					self.value = self.empowered and (GetTime() - self.spellStartTime) or (self.spellEndTime - GetTime())
				end

				self:RunHooksForWidget("OnShow", self, self.unit)
			end
		end
	end,

	--it's triggering several events since it's not registered for the unit with RegisterUnitEvent
	OnEvent = function(self, event, ...)
		local arg1 = ...
		local unit = self.unit

		if (event == "PLAYER_ENTERING_WORLD") then
			local newEvent = self.PLAYER_ENTERING_WORLD (self, unit, ...)
			if (newEvent) then
				self.OnEvent (self, newEvent, unit)
				return
			end

		elseif (arg1 ~= unit) then
			return
		end

		local eventFunc = self [event]
		if (eventFunc) then
			eventFunc (self, unit, ...)
		end
	end,

	OnTick_LazyTick = function(self)
		--run the lazy tick if allowed
		if (self.Settings.CanLazyTick) then
			--update the cast time
			if (self.Settings.ShowCastTime) then
				if (self.casting) then
					self.percentText:SetText(format("%.1f", abs(self.value - self.maxValue)))

				elseif (self.channeling) then
					local remainingTime = self.empowered and abs(self.value - self.maxValue) or abs(self.value)
					if (remainingTime > 999) then
						self.percentText:SetText("")
					else
						self.percentText:SetText(format("%.1f", remainingTime))
					end
				else
					self.percentText:SetText("")
				end
			end

			return true
		else
			return false
		end
	end,

	--tick function for regular casts
	OnTick_Casting = function(self, deltaTime)
		self.value = self.value + deltaTime

		if (self:CheckCastIsDone()) then
			return
		else
			self:SetValue(self.value)
		end

		--update spark position
		local sparkPosition = self.value / self.maxValue * self:GetWidth()
		self.Spark:SetPoint("center", self, "left", sparkPosition + self.Settings.SparkOffset, 0)


		--in order to allow the lazy tick run, it must return true, it tell that the cast didn't finished
		return true
	end,

	--tick function for channeling casts
	OnTick_Channeling = function(self, deltaTime)
		self.value = self.empowered and self.value + deltaTime or self.value - deltaTime

		if (self:CheckCastIsDone()) then
			return
		else
			self:SetValue(self.value)
		end

		--update spark position
		local sparkPosition = self.value / self.maxValue * self:GetWidth()
		self.Spark:SetPoint("center", self, "left", sparkPosition + self.Settings.SparkOffset, 0)

		self:CreateOrUpdateEmpoweredPips()

		return true
	end,

	OnTick = function(self, deltaTime)
		if (self.casting) then
			if (not self:OnTick_Casting(deltaTime)) then
				return
			end

			--lazy tick
			self.lazyUpdateCooldown = self.lazyUpdateCooldown - deltaTime
			if (self.lazyUpdateCooldown < 0) then
				self:OnTick_LazyTick()
				self.lazyUpdateCooldown = self.Settings.LazyUpdateCooldown
			end

		elseif (self.channeling) then
			if (not self:OnTick_Channeling(deltaTime)) then
				return
			end

			--lazy tick
			self.lazyUpdateCooldown = self.lazyUpdateCooldown - deltaTime
			if (self.lazyUpdateCooldown < 0) then
				self:OnTick_LazyTick()
				self.lazyUpdateCooldown = self.Settings.LazyUpdateCooldown
			end
		end
	end,

	--animation start script
	Animation_FadeOutStarted = function(self)

	end,

	--animation finished script
	Animation_FadeOutFinished = function(self)
		local castBar = self:GetParent()
		castBar:SetAlpha(1)
		castBar:Hide()
	end,

	--animation start script
	Animation_FadeInStarted = function(self)

	end,

	--animation finished script
	Animation_FadeInFinished = function(self)
		local castBar = self:GetParent()
		castBar:Show()
		castBar:SetAlpha(1)
	end,

	--animation calls
	Animation_FadeOut = function(self)
		self:ScheduleToHide(false)

		if (self.fadeInAnimation:IsPlaying()) then
			self.fadeInAnimation:Stop()
		end

		if (not self.fadeOutAnimation:IsPlaying()) then
			self.fadeOutAnimation:Play()
		end
	end,

	Animation_FadeIn = function(self)
		self:ScheduleToHide (false)

		if (self.fadeOutAnimation:IsPlaying()) then
			self.fadeOutAnimation:Stop()
		end

		if (not self.fadeInAnimation:IsPlaying()) then
			self.fadeInAnimation:Play()
		end
	end,

	Animation_Flash = function(self)
		if (not self.flashAnimation:IsPlaying()) then
			self.flashAnimation:Play()
		end
	end,

	Animation_StopAllAnimations = function(self)
		if (self.flashAnimation:IsPlaying()) then
			self.flashAnimation:Stop()
		end

		if (self.fadeOutAnimation:IsPlaying()) then
			self.fadeOutAnimation:Stop()
		end

		if (self.fadeInAnimation:IsPlaying()) then
			self.fadeInAnimation:Stop()
		end
	end,

	PLAYER_ENTERING_WORLD = function(self, unit, arg1)
		local isChannel = CastInfo.UnitChannelInfo(unit)
		local isRegularCast = CastInfo.UnitCastingInfo(unit)

		if (isChannel) then
			self.channeling = true
			self:UpdateChannelInfo(unit)
			return self.unit == arg1 and "UNIT_SPELLCAST_CHANNEL_START"

		elseif (isRegularCast) then
			self.casting = true
			self:UpdateCastingInfo(unit)
			return self.unit == arg1 and "UNIT_SPELLCAST_START"

		else
			self.casting = nil
			self.channeling = nil
			self.failed = nil
			self.finished = nil
			self.interrupted = nil
			self.Spark:Hide()
			self:Hide()
		end
	end,

	UpdateCastingInfo = function(self, unit, ...)
		local unitID, castID, spellID = ...
		local name, text, texture, startTime, endTime, isTradeSkill, uciCastID, notInterruptible, uciSpellID = CastInfo.UnitCastingInfo(unit)
		spellID = uciSpellID or spellID
		castID = uciCastID or castID
		
		if spellID and (not name or not texture or not text) then
			local siName, _, siIcon, siCastTime = GetSpellInfo(spellID)
			texture = texture or siIcon
			name = name or siName
			text = text or siName
			if not startTime then
				startTime = GetTime()
				endTime = startTime + siCastTime
			end
		end

		--is valid?
		if (not self:IsValid(unit, name, isTradeSkill, true)) then
			return
		end

		--empowered? no!
			self.holdAtMaxTime = nil
			self.empowered = false
			self.curStage = nil
			self.numStages = nil
			self.empStages = nil
			self:CreateOrUpdateEmpoweredPips()

		--setup cast
			self.casting = true
			self.channeling = nil
			self.interrupted = nil
			self.failed = nil
			self.finished = nil
			self.canInterrupt = not notInterruptible
			self.spellID = spellID
			self.castID = castID
			self.spellName = name
			self.spellTexture = texture
			self.spellStartTime = startTime / 1000
			self.spellEndTime = endTime / 1000
			self.value = GetTime() - self.spellStartTime
			self.maxValue = self.spellEndTime - self.spellStartTime

			self:SetMinMaxValues(0, self.maxValue)
			self:SetValue(self.value)
			self:SetAlpha(1)
			self.Icon:SetTexture(texture)
			self.Icon:Show()
			self.Text:SetText(text or name)

			if (self.Settings.ShowCastTime and self.Settings.CanLazyTick) then
				self.percentText:Show()
			end

			self.flashTexture:Hide()
			self:Animation_StopAllAnimations()

			self:SetAlpha(1)

			--set the statusbar color
			self:UpdateCastColor()

			if (not self:IsShown() and not self.Settings.NoFadeEffects) then
				self:Animation_FadeIn()
			end

			self.Spark:Show()
			self:Show()

		--update the interrupt cast border
		self:UpdateInterruptState()
	end,

	UNIT_SPELLCAST_START = function(self, unit, ...)
		self:UpdateCastingInfo(unit, ...)
		self:RunHooksForWidget("OnCastStart", self, self.unit, "UNIT_SPELLCAST_START")
	end,

	CreateOrUpdateEmpoweredPips = function(self, unit, numStages, startTime, endTime)
		unit = unit or self.unit
		numStages = numStages or self.numStages
		startTime = startTime or ((self.spellStartTime or 0) * 1000)
		endTime = endTime or ((self.spellEndTime or 0) * 1000)

		if not self.empStages or not numStages or numStages <= 0 then
			self.stagePips = self.stagePips or {}
			for i, stagePip in pairs(self.stagePips) do
				stagePip:Hide()
			end
			return
		end

		local width = self:GetWidth()
		local height = self:GetHeight()
		for i = 1, numStages, 1 do
			local curStartTime = self.empStages[i] and self.empStages[i].start
			local curEndTime = self.empStages[i] and self.empStages[i].finish
			local curDuration = curEndTime - curStartTime
			local offset = width * curEndTime / (endTime - startTime) * 1000
			if curDuration > -1 then
				local stagePip = self.stagePips[i]
				if not stagePip then
					stagePip = self:CreateTexture(nil, "overlay", nil, 2)
					stagePip:SetBlendMode("ADD")
					stagePip:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
					stagePip:SetTexCoord(11/32,18/32,9/32,23/32)
					stagePip:SetSize(2, height)
					--stagePip = CreateFrame("FRAME", nil, self, "CastingBarFrameStagePipTemplate")
					self.stagePips[i] = stagePip
				end

				stagePip:ClearAllPoints()
				--stagePip:SetPoint("TOP", self, "TOPLEFT", offset, -1)
				--stagePip:SetPoint("BOTTOM", self, "BOTTOMLEFT", offset, 1)
				--stagePip.BasePip:SetVertexColor(1, 1, 1, 1)
				stagePip:SetPoint("CENTER", self, "LEFT", offset, 0)
				stagePip:SetVertexColor(1, 1, 1, 1)
				stagePip:Show()
			end
		end
	end,

	UpdateChannelInfo = function(self, unit, ...)
		local unitID, castID, spellID = ...
		local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, uciSpellID, _, numStages = CastInfo.UnitChannelInfo (unit)
		spellID = uciSpellID or spellID
		castID = uciCastID or castID
		
		if spellID and (not name or not texture or not text) then
			local siName, _, siIcon, siCastTime = GetSpellInfo(spellID)
			texture = texture or siIcon
			name = name or siName
			text = text or siName
			if not startTime then
				startTime = GetTime()
				endTime = startTime + siCastTime
			end
		end

		--is valid?
		if (not self:IsValid (unit, name, isTradeSkill, true)) then
			return
		end

		--empowered?
			self.empStages = {}
			self.stagePips = self.stagePips or {}
			for i, stagePip in pairs(self.stagePips) do
				stagePip:Hide()
			end

			if numStages and numStages > 0 then
				self.holdAtMaxTime = GetUnitEmpowerHoldAtMaxTime(self.unit)
				self.empowered = true
				self.numStages = numStages

				local lastStageEndTime = 0
				for i = 1, numStages do
					self.empStages[i] = {
						start = lastStageEndTime,
						finish = lastStageEndTime + GetUnitEmpowerStageDuration(unit, i - 1) / 1000,
					}
					lastStageEndTime = self.empStages[i].finish

					if startTime / 1000 + lastStageEndTime <= GetTime() then
						self.curStage = i
					end
				end

				if (self.Settings.ShowEmpoweredDuration) then
					endTime = endTime + self.holdAtMaxTime
				end

				--create/update pips
				self:CreateOrUpdateEmpoweredPips(unit, numStages, startTime, endTime)
			else
				self.holdAtMaxTime = nil
				self.empowered = false
				self.curStage = nil
				self.numStages = nil
			end

		--setup cast
			self.casting = nil
			self.channeling = true
			self.interrupted = nil
			self.failed = nil
			self.finished = nil
			self.canInterrupt = not notInterruptible
			self.spellID = spellID
			self.castID = castID
			self.spellName = name
			self.spellTexture = texture
			self.spellStartTime = startTime / 1000
			self.spellEndTime = endTime / 1000
			self.value = self.empowered and (GetTime() - self.spellStartTime) or (self.spellEndTime - GetTime())
			self.maxValue = self.spellEndTime - self.spellStartTime
			self.reverseChanneling = self.empowered

			self:SetMinMaxValues(0, self.maxValue)
			self:SetValue(self.value)

			self:SetAlpha(1)
			self.Icon:SetTexture(texture)
			self.Icon:Show()
			self.Text:SetText(text)

			if (self.Settings.ShowCastTime and self.Settings.CanLazyTick) then
				self.percentText:Show()
			end

			self.flashTexture:Hide()
			self:Animation_StopAllAnimations()

			self:SetAlpha(1)

			--set the statusbar color
			self:UpdateCastColor()

			if (not self:IsShown() and not self.Settings.NoFadeEffects) then
				self:Animation_FadeIn()
			end

			self.Spark:Show()
			self:Show()

		--update the interrupt cast border
		self:UpdateInterruptState()

	end,

	UNIT_SPELLCAST_CHANNEL_START = function(self, unit, ...)
		self:UpdateChannelInfo(unit, ...)
		self:RunHooksForWidget("OnCastStart", self, self.unit, "UNIT_SPELLCAST_CHANNEL_START")
	end,

	UNIT_SPELLCAST_STOP = function(self, unit, ...)
		local unitID, castID, spellID = ...
		if (self.castID == castID) then
			if (self.interrupted) then
				if (self.Settings.HideSparkOnInterrupt) then
					self.Spark:Hide()
				end
			else
				self.Spark:Hide()
			end

			self.percentText:Hide()

			local value = self:GetValue()
			local _, maxValue = self:GetMinMaxValues()

			if (self.interrupted) then
				if (self.Settings.FillOnInterrupt) then
					self:SetValue(self.maxValue or maxValue or 1)
				end
			else
				self:SetValue(self.maxValue or maxValue or 1)
			end

			self.casting = nil
			self.channeling = nil
			self.finished = true
			self.castID = nil

			if (not self:HasScheduledHide()) then
				--check if settings has no fade option or if its parents are not visible
				if (not self:IsVisible()) then
					self:Hide()

				elseif (self.Settings.NoFadeEffects) then
					self:ScheduleToHide (0.3)

				else
					self:Animation_Flash()
					self:Animation_FadeOut()
				end
			end

			self:UpdateCastColor()
		end
	end,

	UNIT_SPELLCAST_CHANNEL_STOP = function(self, unit, ...)
		local unitID, castID, spellID = ...

		if (self.channeling and castID == self.castID) then
			self.Spark:Hide()
			self.percentText:Hide()

			local value = self:GetValue()
			local _, maxValue = self:GetMinMaxValues()
			self:SetValue(self.maxValue or maxValue or 1)

			self.casting = nil
			self.channeling = nil
			self.finished = true
			self.castID = nil

			if (not self:HasScheduledHide()) then
				--check if settings has no fade option or if its parents are not visible
				if (not self:IsVisible()) then
					self:Hide()

				elseif (self.Settings.NoFadeEffects) then
					self:ScheduleToHide (0.3)

				else
					self:Animation_Flash()
					self:Animation_FadeOut()
				end
			end

			self:UpdateCastColor()
		end
	end,

	UNIT_SPELLCAST_EMPOWER_START = function(self, unit, ...)
		self:UNIT_SPELLCAST_CHANNEL_START(unit, ...)
	end,

	UNIT_SPELLCAST_EMPOWER_UPDATE = function(self, unit, ...)
		self:UNIT_SPELLCAST_CHANNEL_UPDATE(unit, ...)
	end,

	UNIT_SPELLCAST_EMPOWER_STOP = function(self, unit, ...)
		self:UNIT_SPELLCAST_CHANNEL_STOP(unit, ...)
	end,

	UNIT_SPELLCAST_FAILED = function(self, unit, ...)
		local unitID, castID, spellID = ...

		if ((self.casting or self.channeling) and castID == self.castID and not self.fadeOut) then
			self.casting = nil
			self.channeling = nil
			self.failed = true
			self.finished = true
			self.castID = nil
			self:SetValue(self.maxValue or select(2, self:GetMinMaxValues()) or 1)

			--set the statusbar color
			self:UpdateCastColor()

			self.Spark:Hide()
			self.percentText:Hide()
			self.Text:SetText(FAILED) --auto locale within the global namespace

			self:ScheduleToHide (1)
		end
	end,

	UNIT_SPELLCAST_INTERRUPTED = function(self, unit, ...)
		local unitID, castID, spellID = ...

		if ((self.casting or self.channeling) and castID == self.castID and not self.fadeOut) then
			self.casting = nil
			self.channeling = nil
			self.interrupted = true
			self.finished = true
			self.castID = nil

			if (self.Settings.FillOnInterrupt) then
				self:SetValue(self.maxValue or select(2, self:GetMinMaxValues()) or 1)
			end

			if (self.Settings.HideSparkOnInterrupt) then
				self.Spark:Hide()
			end

			local castColor = self:GetCastColor()
			self:SetColor(castColor) --SetColor handles with ParseColors()

			self.percentText:Hide()
			self.Text:SetText(INTERRUPTED) --auto locale within the global namespace

			self:ScheduleToHide(1)
		end
	end,

	UNIT_SPELLCAST_DELAYED = function(self, unit, ...)
		local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = CastInfo.UnitCastingInfo (unit)

		if (not self:IsValid (unit, name, isTradeSkill)) then
			return
		end

		--update the cast time
		self.spellStartTime = startTime / 1000
		self.spellEndTime = endTime / 1000
		self.value = GetTime() - self.spellStartTime
		self.maxValue = self.spellEndTime - self.spellStartTime
		self:SetMinMaxValues(0, self.maxValue)
	end,

	UNIT_SPELLCAST_CHANNEL_UPDATE = function(self, unit, ...)
		local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID, _, numStages = CastInfo.UnitChannelInfo (unit)

		if (not self:IsValid(unit, name, isTradeSkill)) then
			return
		end

		--update the cast time
		self.spellStartTime = startTime / 1000
		self.spellEndTime = endTime / 1000
		self.value = self.empowered and (GetTime() - self.spellStartTime) or (self.spellEndTime - GetTime())
		self.maxValue = self.spellEndTime - self.spellStartTime

		if (self.value < 0 or self.value > self.maxValue) then
			self.value = 0
		end

		self:SetMinMaxValues(0, self.maxValue)
		self:SetValue(self.value)
	end,

	--cast changed its state to interruptable
	UNIT_SPELLCAST_INTERRUPTIBLE = function(self, unit, ...)
		self.canInterrupt = true
		self:UpdateCastColor()
		self:UpdateInterruptState()
	end,

	--cast changed its state to non interruptable
	UNIT_SPELLCAST_NOT_INTERRUPTIBLE = function(self, unit, ...)
		self.canInterrupt = false
		self:UpdateCastColor()
		self:UpdateInterruptState()
	end,
}

detailsFramework:Mixin(detailsFramework.CastFrameFunctions, detailsFramework.ScriptHookMixin)

-- ~castbar

---create a castbar widget
---@param parent frame
---@param name string?
---@param settingsOverride table? a table with key/value pairs to override the default settings
---@return df_castbar
function detailsFramework:CreateCastBar(parent, name, settingsOverride)
	assert(name or parent:GetName(), "DetailsFramework:CreateCastBar parameter 'name' omitted and parent has no name.")

	local castBar = CreateFrame("StatusBar", name or (parent:GetName() .. "CastBar"), parent, "BackdropTemplate")

		do --layers

			--these widgets was been made with back compatibility in mind
			--they are using the same names as the retail game uses on the nameplate castbar
			--this should make Plater core and Plater scripts made by users compatible with the new unit frame made on the framework

			--background
			castBar.background = castBar:CreateTexture(nil, "background", nil, -6)
			castBar.extraBackground = castBar:CreateTexture(nil, "background", nil, -5)

			--overlay
			castBar.Text = castBar:CreateFontString(nil, "overlay", "SystemFont_Shadow_Small")
			castBar.Text:SetDrawLayer("overlay", 1)
			castBar.Text:SetPoint("center", 0, 0)

			castBar.BorderShield = castBar:CreateTexture(nil, "overlay", nil, 5)
			castBar.BorderShield:Hide()

			castBar.Icon = castBar:CreateTexture(nil, "overlay", nil, 4)
			castBar.Icon:Hide()

			castBar.Spark = castBar:CreateTexture(nil, "overlay", nil, 3)
			castBar.Spark:SetBlendMode("ADD")

			--time left on the cast
			castBar.percentText = castBar:CreateFontString(nil, "overlay", "SystemFont_Shadow_Small")
			castBar.percentText:SetDrawLayer("overlay", 7)

			--statusbar texture
			castBar.barTexture = castBar:CreateTexture(nil, "artwork", nil, -6)
			castBar:SetStatusBarTexture(castBar.barTexture)

			--animations fade in and out
			local fadeOutAnimationHub = detailsFramework:CreateAnimationHub(castBar, detailsFramework.CastFrameFunctions.Animation_FadeOutStarted, detailsFramework.CastFrameFunctions.Animation_FadeOutFinished)
			fadeOutAnimationHub.alpha1 = detailsFramework:CreateAnimation(fadeOutAnimationHub, "ALPHA", 1, 1, 1, 0)
			castBar.fadeOutAnimation = fadeOutAnimationHub

			local fadeInAnimationHub = detailsFramework:CreateAnimationHub(castBar, detailsFramework.CastFrameFunctions.Animation_FadeInStarted, detailsFramework.CastFrameFunctions.Animation_FadeInFinished)
			fadeInAnimationHub.alpha1 = detailsFramework:CreateAnimation(fadeInAnimationHub, "ALPHA", 1, 0.150, 0, 1)
			castBar.fadeInAnimation = fadeInAnimationHub

			--animatios flash
			local flashTexture = castBar:CreateTexture(nil, "overlay", nil, 7)
			flashTexture:SetColorTexture(1, 1, 1, 1)
			flashTexture:SetAllPoints()
			flashTexture:SetAlpha(0)
			flashTexture:Hide()
			flashTexture:SetBlendMode("ADD")
			castBar.flashTexture = flashTexture

			local flashAnimationHub = detailsFramework:CreateAnimationHub(flashTexture, function() flashTexture:Show() end, function() flashTexture:Hide() end)
			detailsFramework:CreateAnimation(flashAnimationHub, "ALPHA", 1, 0.2, 0, 0.8)
			detailsFramework:CreateAnimation(flashAnimationHub, "ALPHA", 2, 0.2, 1, 0)
			castBar.flashAnimation = flashAnimationHub
		end

	--mixins
	detailsFramework:Mixin(castBar, detailsFramework.CastFrameFunctions)
	detailsFramework:Mixin(castBar, detailsFramework.StatusBarFunctions)


	castBar:CreateTextureMask()
	castBar:AddMaskTexture(castBar.flashTexture)
	castBar:AddMaskTexture(castBar.background)
	castBar:AddMaskTexture(castBar.extraBackground)

	castBar:SetTexture([[Interface\WorldStateFrame\WORLDSTATEFINALSCORE-HIGHLIGHT]])

	--settings and hooks
	local settings = detailsFramework.table.copy({}, detailsFramework.CastFrameFunctions.Settings)
	if (settingsOverride) then
		detailsFramework.table.copy(settings, settingsOverride)
	end
	castBar.Settings = settings

	local hookList = detailsFramework.table.copy({}, detailsFramework.CastFrameFunctions.HookList)
	castBar.HookList = hookList

	--initialize the cast bar
	castBar:Initialize()

	return castBar
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--unit frame

--[=[
	DF:CreateUnitFrame(parent, name, settingsOverride)
	creates a very basic unit frame with a healthbar, castbar and power bar
	each unit frame has a .Settings table which isn't shared among other unit frames created with this method
	all members names are the same as the unit frame from the retail game

	@parent = frame to pass for the CreateFrame function
	@name = absolute name of the frame, if omitted a random name is created
	@settingsOverride = table with keys and values to replace the defaults from the framework

--]=]


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--unit frame

	--return true if the unit has been claimed by another player (health bar is gray)
	local isUnitTapDenied = function(unit)
		return unit and not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)
	end

	---@class df_unitframesettings : table
	---@field ClearUnitOnHide boolean true
	---@field ShowCastBar boolean true
	---@field ShowPowerBar boolean true
	---@field ShowUnitName boolean true
	---@field ShowBorder boolean true
	---@field CanModifyHealhBarColor boolean true
	---@field ColorByAggro boolean false
	---@field FixedHealthColor boolean false
	---@field UseFriendlyClassColor boolean true
	---@field UseEnemyClassColor boolean true
	---@field ShowTargetOverlay boolean true
	---@field BorderColor table
	---@field CanTick boolean
	---@field Width number
	---@field Height number
	---@field PowerBarHeight number
	---@field CastBarHeight number

	---@class df_unitframemixin
	---@field WidgetType string
	---@field Settings df_unitframesettings
	---@field SetHealthBarColor fun(self:df_unitframe, r:number, g:number?, b:number?, a:number?)
	---@field SetUnit fun(self:df_unitframe, unit:string?) sets the unit to be shown in the unit frame
	---@field OnTick fun(self:df_unitframe, deltaTime:number?) if CanTick is true, this function will be called every frame

	detailsFramework.UnitFrameFunctions = {
		WidgetType = "unitFrame",

		Settings = {
			--unit frames
			ClearUnitOnHide = true, --if tue it'll set the unit to nil when the unit frame is set to hide
			ShowCastBar = true, --if this is false, the cast bar for the unit won't be shown
			ShowPowerBar = true, --if true it'll show the power bar for the unit, e.g. the mana bar
			ShowUnitName = true, --if false, the unit name won't show
			ShowBorder = true, --if false won't show the border frame

			--health bar color
			CanModifyHealhBarColor = true, --if false it won't change the color of the health bar
			ColorByAggro = false, --if true it'll color the healthbar with red color when the unit has aggro on player
			FixedHealthColor = false, --color override with a table {r=1, g=1, b=1}
			UseFriendlyClassColor = true, --make the healthbar class color for friendly players
			UseEnemyClassColor = true, --make the healthbar class color for enemy players

			--misc
			ShowTargetOverlay = true, --shows a highlighht for the player current target
			BorderColor = detailsFramework:CreateColorTable(0, 0, 0, 1), --border color, set to alpha zero for no border
			CanTick = false, --if true it'll run the OnTick event

			--size
			Width = 100,
			Height = 20,
			PowerBarHeight = 4,
			CastBarHeight = 8,
		},

		UnitFrameEvents = {
			--run for all units
			{"PLAYER_ENTERING_WORLD"},
			{"PARTY_MEMBER_DISABLE"},
			{"PARTY_MEMBER_ENABLE"},
			{"PLAYER_TARGET_CHANGED"},

			--run for one unit
			{"UNIT_NAME_UPDATE", true},
			{"UNIT_CONNECTION", true},
			{"UNIT_ENTERED_VEHICLE", true},
			{"UNIT_EXITED_VEHICLE", true},
			{"UNIT_PET", true},
			{"UNIT_THREAT_LIST_UPDATE", true},
		},

		--used when a event is triggered to quickly check if is a unit event
		IsUnitEvent = {
			["UNIT_NAME_UPDATE"] = true,
			["UNIT_CONNECTION"] = true,
			["UNIT_ENTERED_VEHICLE"] = true,
			["UNIT_EXITED_VEHICLE"] = true,
			["UNIT_PET"] = true,
			["UNIT_THREAT_LIST_UPDATE"] = true,
		},

		Initialize = function(self)
			self.border:SetBorderColor(self.Settings.BorderColor)

			PixelUtil.SetWidth(self, self.Settings.Width, 1)
			PixelUtil.SetHeight(self, self.Settings.Height, 1)

			PixelUtil.SetPoint(self.powerBar, "bottomleft", self, "bottomleft", 0, 0, 1, 1)
			PixelUtil.SetPoint(self.powerBar, "bottomright", self, "bottomright", 0, 0, 1, 1)
			PixelUtil.SetHeight(self.powerBar, self.Settings.PowerBarHeight, 1)

			--make the castbar overlap the powerbar
			PixelUtil.SetPoint(self.castBar, "bottomleft", self, "bottomleft", 0, 0, 1, 1)
			PixelUtil.SetPoint(self.castBar, "bottomright", self, "bottomright", 0, 0, 1, 1)
			PixelUtil.SetHeight(self.castBar, self.Settings.CastBarHeight, 1)
		end,

		SetHealthBarColor = function(self, r, g, b, a)
			self.healthBar:SetColor(r, g, b, a)
		end,

		--register all events which will be used by the unit frame
		RegisterEvents = function(self)
			--register events
			for index, eventTable in ipairs(self.UnitFrameEvents) do
				local event, isUnitEvent = unpack(eventTable)
				if (not isUnitEvent) then
					self:RegisterEvent(event)
				else
					self:RegisterUnitEvent (event, self.unit, self.displayedUnit ~= unit and self.displayedUnit or nil)
				end
			end

			--check settings and unregister events for disabled features
			if (not self.Settings.ColorByAggro) then
				self:UnregisterEvent ("UNIT_THREAT_LIST_UPDATE")
			end

			--set scripts
			self:SetScript("OnEvent", self.OnEvent)
			self:SetScript("OnHide", self.OnHide)

			if (self.Settings.CanTick) then
				self:SetScript("OnUpdate", self.OnTick)
			end
		end,

		--unregister events, called when this unit frame losses its unit
		UnregisterEvents = function(self)
			for index, eventTable in ipairs(self.UnitFrameEvents) do
				local event, firstUnit, secondUnit = unpack(eventTable)
				self:UnregisterEvent(event)
			end

			self:SetScript("OnEvent", nil)
			self:SetScript("OnUpdate", nil)
			self:SetScript("OnHide", nil)
		end,

		--call every tick
		OnTick = function(self, deltaTime) end, --if overrided, set 'CanTick' to true on the settings table

		--when an event happen for this unit, send it to the apropriate function
		OnEvent = function(self, event, ...)
			--run the function for this event
			local eventFunc = self[event]
			if (eventFunc) then
				--is this event an unit event?
				if (self.IsUnitEvent[event]) then
					local unit = ...
					--check if is for this unit (even if the event is registered only for the unit)
					if (unit == self.unit or unit == self.displayedUnit) then
						eventFunc(self, ...)
					end
				else
					eventFunc(self, ...)
				end
			end
		end,

		OnHide = function(self)
			if (self.Settings.ClearUnitOnHide) then
				self:SetUnit(nil)
			end
		end,

		--run if the unit currently shown is different than the new one
		SetUnit = function(self, unit)
			if (unit ~= self.unit or unit == nil) then
				self.unit = unit --absolute unit
				self.displayedUnit = unit --~todo rename to 'displayedUnit' for back compatibility with older scripts in Plater
				self.unitInVehicle = nil --true when the unit is in a vehicle

				if (unit) then
					self:RegisterEvents()

					self.guid = UnitGUID(unit)
					self.class = select(2, UnitClass(unit))
					self.name = UnitName(unit)

					self.healthBar:SetUnit(unit, self.displayedUnit)

					--is using castbars?
					if (self.Settings.ShowCastBar) then
						self.castBar:SetUnit(unit, self.displayedUnit)
					else
						self.castBar:SetUnit(nil)
					end

					--is using powerbars?
					if (self.Settings.ShowPowerBar) then
						self.powerBar:SetUnit(unit, self.displayedUnit)
					else
						self.powerBar:SetUnit(nil)
					end

					--is using the border?
					if (self.Settings.ShowBorder) then
						self.border:Show()
					else
						self.border:Hide()
					end

					if (not self.Settings.ShowUnitName) then
						self.unitName:Hide()
					end
				else
					self:UnregisterEvents()
					self.healthBar:SetUnit(nil)
					self.castBar:SetUnit(nil)
					self.powerBar:SetUnit(nil)
				end

				self:UpdateUnitFrame()
			end
		end,

		--if the unit is controlling a vehicle, need to show the vehicle instead
		--.unit and .displayedUnit is always the same execept when the unit is controlling a vehicle, then .displayedUnit is the unitID for the vehicle
		--todo: see what 'UnitTargetsVehicleInRaidUI' is, there's a call for this in the CompactUnitFrame.lua but zero documentation
		CheckVehiclePossession = function(self)
			--this unit is possessing a vehicle?
			local unitPossessVehicle = (IS_WOW_PROJECT_MAINLINE) and UnitHasVehicleUI(self.unit)	or false
			if (unitPossessVehicle) then
				if (not self.unitInVehicle) then
					if (UnitIsUnit("player", self.unit)) then
						self.displayedUnit = "vehicle"
						self.unitInVehicle = true
						self:RegisterEvents()
						self:UpdateAllWidgets()
						return true
					end

					local prefix, id, suffix = string.match(self.unit, "([^%d]+)([%d]*)(.*)") --CompactUnitFrame.lua
					local vehicleUnitID = prefix .. "pet" .. id .. suffix
					if (UnitExists(vehicleUnitID)) then
						self.displayedUnit = vehicleUnitID
						self.unitInVehicle = true
						self:RegisterEvents()
						self:UpdateAllWidgets()
						return true
					end
				end
			end

			if (self.unitInVehicle) then
				self.displayedUnit = self.unit
				self.unitInVehicle = nil
				self:RegisterEvents()
				self:UpdateAllWidgets()
			end
		end,

		--find a color for the health bar, if a color has been passed in the arguments use it instead, 'CanModifyHealhBarColor' must be true for this function run
		UpdateHealthColor = function(self, r, g, b)
			--check if color changes is disabled
			if (not self.Settings.CanModifyHealhBarColor) then
				return
			end

			local unit = self.displayedUnit

			--check if a color has been passed within the parameters
			if (r) then
				--check if passed a special color
				if (type(r) ~= "number") then
					r, g, b = detailsFramework:ParseColors(r)
				end

				self:SetHealthBarColor(r, g, b)
				return
			end

			--check if there is a color override in the settings
			if (self.Settings.FixedHealthColor) then
				local FixedHealthColor = self.Settings.FixedHealthColor
				r, g, b = FixedHealthColor.r, FixedHealthColor.g, FixedHealthColor.b
				self:SetHealthBarColor(r, g, b)
				return
			end

			--check if the unit is a player
			if (UnitIsPlayer(unit)) then
				--check if the unit is disconnected (in case it is a player
				if (not UnitIsConnected(unit)) then
					self:SetHealthBarColor(.5, .5, .5)
					return
				end

				--is a friendly or enemy player?
				if (UnitIsFriend ("player", unit)) then
					if (self.Settings.UseFriendlyClassColor) then
						local _, className = UnitClass(unit)
						if (className) then
							local classColor = RAID_CLASS_COLORS[className]
							if (classColor) then
								self:SetHealthBarColor(classColor.r, classColor.g, classColor.b)
								return
							end
						end
					else
						self:SetHealthBarColor(0, 1, 0)
						return
					end
				else
					if (self.Settings.UseEnemyClassColor) then
						local _, className = UnitClass(unit)
						if (className) then
							local classColor = RAID_CLASS_COLORS[className]
							if (classColor) then
								self:SetHealthBarColor(classColor.r, classColor.g, classColor.b)
								return
							end
						end
					else
						self:SetHealthBarColor(1, 0, 0)
						return
					end
				end
			end

			--is tapped?
			if (isUnitTapDenied(unit)) then
				self:SetHealthBarColor(.6, .6, .6)
				return
			end

			--is this is a npc attacking the player?
			if (self.Settings.ColorByAggro) then
				local _, threatStatus = UnitDetailedThreatSituation("player", unit)
				if (threatStatus) then
					self:SetHealthBarColor(1, 0, 0)
					return
				end
			end

			-- get the regular color by selection
			r, g, b = UnitSelectionColor(unit)
			self:SetHealthBarColor (r, g, b)
		end,

		--misc
		UpdateName = function(self)
			if (not self.Settings.ShowUnitName) then
				return
			end

			--unit name without realm names by default
			local name = UnitName(self.unit)
			self.unitName:SetText(name)
			self.unitName:Show()
		end,

		--this runs when the player it self changes its target, need to update the current target overlay
		--todo: add focus overlay
		UpdateTargetOverlay = function(self)
			if (not self.Settings.ShowTargetOverlay) then
				self.targetOverlay:Hide()
				return
			end

			if (UnitIsUnit(self.displayedUnit, "target")) then
				self.targetOverlay:Show()
			else
				self.targetOverlay:Hide()
			end
		end,

		UpdateAllWidgets = function(self)
			if (UnitExists(self.displayedUnit)) then
				local unit = self.unit
				local displayedUnit = self.displayedUnit

				self:SetUnit(unit, displayedUnit)

				--is using castbars?
				if (self.Settings.ShowCastBar) then
					self.castBar:SetUnit(unit, displayedUnit)
				end

				--is using powerbars?
				if (self.Settings.ShowPowerBar) then
					self.powerBar:SetUnit(unit, displayedUnit)
				end

				self:UpdateName()
				self:UpdateTargetOverlay()
				self:UpdateHealthColor()
			end
		end,

		--update the unit frame and its widgets
		UpdateUnitFrame = function(self)
			local unitInVehicle = self:CheckVehiclePossession()

			--if the unit is inside a vehicle, the vehicle possession function will call an update on all widgets
			if (not unitInVehicle) then
				self:UpdateAllWidgets()
			end
		end,

		--event handles
		PLAYER_ENTERING_WORLD = function(self, ...)
			self:UpdateUnitFrame()
		end,

		--update overlays when the player changes its target
		PLAYER_TARGET_CHANGED = function(self, ...)
			self:UpdateTargetOverlay()
		end,

		--unit received a name update
		UNIT_NAME_UPDATE = function(self, ...)
			self:UpdateName()
		end,

		--this is registered only if .settings.ColorByAggro is true
		UNIT_THREAT_LIST_UPDATE = function(self, ...)
			if (self.Settings.ColorByAggro) then
				self:UpdateHealthColor()
			end
		end,

		--vehicle
		UNIT_ENTERED_VEHICLE = function(self, ...)
			self:UpdateUnitFrame()
		end,
		UNIT_EXITED_VEHICLE = function(self, ...)
			self:UpdateUnitFrame()
		end,

		--pet
		UNIT_PET = function(self, ...)
			self:UpdateUnitFrame()
		end,

		--player connection
		UNIT_CONNECTION = function(self, ...)
			if (UnitIsConnected (self.unit)) then
				self:UpdateUnitFrame()
			end
		end,

		PARTY_MEMBER_ENABLE = function(self, ...)
			if (UnitIsConnected(self.unit)) then
				self:UpdateName()
			end
		end,
	}

---@class df_unitframe : button, df_unitframemixin
---@field unit string
---@field displayedUnit string
---@field guid guid
---@field class class
---@field name actorname
---@field unitInVehicle boolean
---@field border frame
---@field overlayFrame frame
---@field unitName fontstring
---@field healthBar df_healthbar
---@field castBar df_castbar
---@field powerBar df_powerbar
---@field targetOverlay texture
---@field Settings df_unitframesettings

local globalBaseFrameLevel = 1 -- to be increased + used across each new plate

-- ~unitframe
---create a unit frame with a health bar, cast bar and power bar
---@param parent frame
---@param name string?
---@param unitFrameSettingsOverride table?
---@param healthBarSettingsOverride table?
---@param castBarSettingsOverride table?
---@param powerBarSettingsOverride table?
---@return df_unitframe
function detailsFramework:CreateUnitFrame(parent, name, unitFrameSettingsOverride, healthBarSettingsOverride, castBarSettingsOverride, powerBarSettingsOverride)
	local parentName = name or ("DetailsFrameworkUnitFrame" .. tostring(math.random(1, 100000000)))

	--create the main unit frame
	local mewUnitFrame = CreateFrame("button", parentName, parent, "BackdropTemplate")

	--base level
	--local baseFrameLevel = f:GetFrameLevel()
	local baseFrameLevel = globalBaseFrameLevel
	globalBaseFrameLevel = globalBaseFrameLevel + 10

	mewUnitFrame:SetFrameLevel(baseFrameLevel)

	--create the healthBar
	local healthBar = detailsFramework:CreateHealthBar(mewUnitFrame, nil, healthBarSettingsOverride)
	healthBar:SetFrameLevel(baseFrameLevel + 1)
	mewUnitFrame.healthBar = healthBar

	--create the power bar
	local powerBar = detailsFramework:CreatePowerBar(mewUnitFrame, nil, powerBarSettingsOverride)
	powerBar:SetFrameLevel(baseFrameLevel + 2)
	mewUnitFrame.powerBar = powerBar

	--create the castBar
	local castBar = detailsFramework:CreateCastBar(mewUnitFrame, nil, castBarSettingsOverride)
	castBar:SetFrameLevel(baseFrameLevel + 3)
	mewUnitFrame.castBar = castBar

	--border frame
	local borderFrame = detailsFramework:CreateBorderFrame(mewUnitFrame, mewUnitFrame:GetName() .. "Border")
	borderFrame:SetFrameLevel(mewUnitFrame:GetFrameLevel() + 5)
	mewUnitFrame.border = borderFrame

	--overlay frame (widgets that need to stay above the unit frame)
	local overlayFrame = CreateFrame("frame", "$parentOverlayFrame", mewUnitFrame, "BackdropTemplate")
	overlayFrame:SetFrameLevel(mewUnitFrame:GetFrameLevel() + 6)
	mewUnitFrame.overlayFrame = overlayFrame

	--unit frame layers
		do
			--artwork
			mewUnitFrame.unitName = mewUnitFrame:CreateFontString(nil, "artwork", "GameFontHighlightSmall")
			PixelUtil.SetPoint(mewUnitFrame.unitName, "topleft", healthBar, "topleft", 2, -2, 1, 1)

			--target overlay - it's parented in the healthbar so other widgets won't get the overlay
			mewUnitFrame.targetOverlay = overlayFrame:CreateTexture(nil, "artwork")
			mewUnitFrame.targetOverlay:SetTexture(healthBar:GetTexture())
			mewUnitFrame.targetOverlay:SetBlendMode("ADD")
			mewUnitFrame.targetOverlay:SetAlpha(.5)
			mewUnitFrame.targetOverlay:SetAllPoints(healthBar)
		end

	--mixins
		--inject mixins
		detailsFramework:Mixin(mewUnitFrame, detailsFramework.UnitFrameFunctions)

		--create the settings table and copy the overrides into it, the table is set into the frame after the mixin
		local unitFrameSettings = detailsFramework.table.copy({}, detailsFramework.UnitFrameFunctions.Settings)
		if (unitFrameSettingsOverride) then
			unitFrameSettings = detailsFramework.table.copy(unitFrameSettings, unitFrameSettingsOverride)
		end
		mewUnitFrame.Settings = unitFrameSettings

	--initialize scripts
		--unitframe
		mewUnitFrame:Initialize()

	return mewUnitFrame
end