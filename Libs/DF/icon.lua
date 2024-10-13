
local detailsFramework = DetailsFramework

if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local unpack = unpack
local G_CreateFrame = _G.CreateFrame
local CreateFrame = function (frameType , name, parent, template, id)
	local frame = G_CreateFrame(frameType , name, parent, template, id)
	detailsFramework:Mixin(frame, detailsFramework.FrameFunctions)
	return frame
end
local PixelUtil = PixelUtil
local GetTime = GetTime
local GetSpellInfo = GetSpellInfo or function(spellID) if not spellID then return nil end local si = C_Spell.GetSpellInfo(spellID) if si then return si.name, nil, si.iconID, si.castTime, si.minRange, si.maxRange, si.spellID, si.originalIconID end end

detailsFramework.GrowDirectionBySide = {
	[1] = 1,
	[2] = 2,
	[3] = 1,
	[4] = 1,
	[5] = 2,
	[6] = 1,
	[7] = 2,
	[8] = 1,
	[9] = 1,
	[10] = 1,
	[11] = 2,
	[12] = 1,
	[13] = 1,
	[14] = 1,
	[15] = 1,
	[16] = 2,
	[17] = 2,
}

detailsFramework.ShouldCenterAlign = {
	[9] = true,
	[10] = true,
	[12] = true,
}

detailsFramework.SideIsCorner = {
	[1] = true,
	[3] = true,
	[5] = true,
	[7] = true,
	[14] = true,
	[15] = true,
	[16] = true,
	[17] = true,
}

---@class df_icon : frame
---@field spellId number
---@field startTime number
---@field duration number
---@field count number
---@field width number
---@field height number
---@field debuffType string
---@field caster string
---@field canStealOrPurge boolean
---@field isBuff boolean
---@field spellName string
---@field timeRemaining number
---@field expirationTime number
---@field lastUpdateCooldown number
---@field identifierKey string
---@field endTime number
---@field nextUpdate number
---@field currentCoords table
---@field textureWidth number
---@field textureHeight number
---@field stacks number
---@field Texture texture
---@field Border texture
---@field StackText fontstring
---@field StackTextShadow fontstring
---@field Desc fontstring
---@field Cooldown cooldown
---@field parentIconRow df_iconrow
---@field cooldownLooper timer

---@class df_iconrow : frame
---@field options table
---@field NextIcon number
---@field IconPool df_icon[]
---@field AuraCache table
---@field shownAmount number
---@field CreateIcon fun(self:df_iconrow, iconName:string?):frame
---@field GetIcon fun(self:df_iconrow):frame
---@field AddSpecificIcon fun(self:df_iconrow, identifierKey:string, spellId:number?, borderColor:table?, startTime:number?, duration:number?, forceTexture:string|number|nil, descText:table?, count:number?, debuffType:string?, caster:string?, canStealOrPurge:boolean?, spellName:string?, isBuff:boolean?)
---@field SetIcon fun(self:df_iconrow, spellId:number?, borderColor:table?, startTime:number?, duration:number?, forceTexture:string?, descText:table?, count:number?, debuffType:string?, caster:string?, canStealOrPurge:boolean?, spellName:string?, isBuff:boolean?, modRate:number?):frame
---@field SetStacks fun(self:df_iconrow, iconFrame:table, bIsShown:boolean, stacksAmount:number?) is shown false to hide the stack text
---@field OnIconTick fun(self:df_icon, deltaTime:number)
---@field FormatCooldownTime fun(thisTime:number):string
---@field FormatCooldownTimeDecimal fun(formattedTime:number):string
---@field RemoveSpecificIcon fun(self:df_iconrow, identifierKey:any)
---@field ClearIcons fun(self:df_iconrow, resetBuffs:boolean?, resetDebuffs:boolean?)
---@field AlignAuraIcons fun(self:df_iconrow)
---@field GetIconGrowDirection fun(self:df_iconrow):number
---@field OnOptionChanged fun(self:df_iconrow, optionName:string)

---@class df_icontemplate : table
---@field id any
---@field texture texturepath|textureid
---@field startTime number?
---@field duration number?
---@field count number?
---@field coords table?
---@field width number?
---@field height number?
---@field points table?
---@field borderColor table?
---@field borderTexture texturepath|textureid|nil
---@field scale number?
---@field alpha number?

local spellIconCache = {}
local spellNameCache = {}
local emptyTable = {}
local white = {1, 1, 1, 1}

local iconFrameOnHideScript = function(self)
	if (self.cooldownLooper) then
		self.cooldownLooper:Cancel()
	end
end

detailsFramework.IconMixin = {
	---create a new icon frame
	---@param self df_iconrow the parent frame
	---@param iconName string the name of the icon frame
	---@return df_icon
    CreateIcon = function(self, iconName)
		---@type df_icon
        local iconFrame = CreateFrame("frame", iconName, self, "BackdropTemplate")

		---@type texture
        iconFrame.Texture = iconFrame:CreateTexture(nil, "artwork")
        PixelUtil.SetPoint(iconFrame.Texture, "topleft", iconFrame, "topleft", 1, -1)
        PixelUtil.SetPoint(iconFrame.Texture, "bottomright", iconFrame, "bottomright", -1, 1)

		---@type texture
        iconFrame.Border = iconFrame:CreateTexture(nil, "background")
        iconFrame.Border:SetAllPoints()
        iconFrame.Border:SetColorTexture(0, 0, 0)

		---@type fontstring
        iconFrame.StackText = iconFrame:CreateFontString(nil, "overlay", "GameFontNormal")
        iconFrame.StackText:SetPoint("bottomright", iconFrame, "bottomright", 0, 0)
        iconFrame.StackText:Hide()
        iconFrame.StackTextShadow = iconFrame:CreateFontString(nil, "artwork", "GameFontNormal")
        iconFrame.StackTextShadow:SetPoint("center", iconFrame.StackText, "center", 0, 0)
		iconFrame.StackTextShadow:SetTextColor(0, 0, 0)
        iconFrame.StackTextShadow:Hide()

		---@type fontstring
        iconFrame.Desc = iconFrame:CreateFontString(nil, "overlay", "GameFontNormal")
        iconFrame.Desc:SetPoint("bottom", iconFrame, "top", 0, 2)
        iconFrame.Desc:Hide()

        local cooldownFrame = CreateFrame("cooldown", "$parentCooldown", iconFrame, "CooldownFrameTemplate, BackdropTemplate")
        cooldownFrame:SetAllPoints()
        cooldownFrame:EnableMouse(false)
        cooldownFrame:SetFrameLevel(iconFrame:GetFrameLevel()+1)
        iconFrame.Cooldown = cooldownFrame

		---@type fontstring
        iconFrame.CountdownText = cooldownFrame:CreateFontString(nil, "overlay", "GameFontNormal")
        iconFrame.CountdownText:SetPoint("center", iconFrame, "center", 0, 0)
        iconFrame.CountdownText:Hide()

		iconFrame.stacks = 0
		iconFrame:SetScript("OnHide", iconFrameOnHideScript)

		return iconFrame
    end,

	---get an icon frame from the pool
	---@param self df_iconrow the parent frame
	---@return df_icon
	GetIcon = function(self)
		---@type df_icon
		local iconFrame = self.IconPool[self.NextIcon]

		if (not iconFrame) then
			---@type df_icon
            iconFrame = self:CreateIcon("$parentIcon" .. self.NextIcon)
            iconFrame.parentIconRow = self

			iconFrame:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
			iconFrame:SetBackdropBorderColor(0, 0, 0, 0)
			iconFrame:EnableMouse(false)
			iconFrame.Cooldown:SetHideCountdownNumbers(self.options.surpress_blizzard_cd_timer)
			iconFrame.Cooldown.noCooldownCount = self.options.surpress_tulla_omni_cc
			iconFrame.CountdownText:ClearAllPoints()
			iconFrame.CountdownText:SetPoint(self.options.text_anchor or "center", iconFrame, self.options.text_rel_anchor or "center", self.options.text_x_offset or 0, self.options.text_y_offset or 0)
			iconFrame.Desc:ClearAllPoints()
			iconFrame.Desc:SetPoint(self.options.desc_text_anchor or "bottom", iconFrame, self.options.desc_text_rel_anchor or "top", self.options.desc_text_x_offset or 0, self.options.desc_text_y_offset or 2)


            iconFrame.StackText:ClearAllPoints()
            iconFrame.StackText:SetPoint(self.options.stack_text_anchor or "center", iconFrame, self.options.stack_text_rel_anchor or "center", self.options.stack_text_x_offset or 0, self.options.stack_text_y_offset or 0)

			self.IconPool[self.NextIcon] = iconFrame
			iconFrame = iconFrame
		end

		iconFrame:ClearAllPoints()

		local anchor = self.options.anchor
		local anchorTo = self.NextIcon == 1 and self or self.IconPool[self.NextIcon - 1]
		local xPadding = self.NextIcon == 1 and self.options.left_padding or self.options.icon_padding or 1
		local growDirection = self.options.grow_direction

		if (growDirection == 1) then --grow to right
			if (self.NextIcon == 1) then
				PixelUtil.SetPoint(iconFrame, "left", anchorTo, "left", xPadding, 0)
			else
				PixelUtil.SetPoint(iconFrame, "left", anchorTo, "right", xPadding, 0)
			end

		elseif (growDirection == 2) then --grow to left
			if (self.NextIcon == 1) then
				PixelUtil.SetPoint(iconFrame, "right", anchorTo, "right", xPadding, 0)
			else
				PixelUtil.SetPoint(iconFrame, "right", anchorTo, "left", xPadding, 0)
			end

		end

		detailsFramework:SetFontColor(iconFrame.CountdownText, self.options.text_color)

		self.NextIcon = self.NextIcon + 1
		return iconFrame
	end,

	---adds only if not existing already in the cache
	---@param self df_iconrow the parent frame
	AddSpecificIcon = function(self, identifierKey, spellId, borderColor, startTime, duration, forceTexture, descText, count, debuffType, caster, canStealOrPurge, spellName, isBuff, modRate)
		if (not identifierKey or identifierKey == "") then
			return
		end

		if (not self.AuraCache[identifierKey]) then
			---@type df_icon
			local icon = self:SetIcon(spellId, borderColor, startTime, duration, forceTexture, descText, count, debuffType, caster, canStealOrPurge, spellName, isBuff or false, modRate)
			icon.identifierKey = identifierKey
			self.AuraCache[identifierKey] = true
		end
	end,

	---set an icon frame
	---@param self df_iconrow the parent frame
	---@return df_icon?
	SetIcon = function(self, spellId, borderColor, startTime, duration, forceTexture, descText, count, debuffType, caster, canStealOrPurge, spellName, isBuff, modRate)
		local actualSpellName, _, spellIcon = GetSpellInfo(spellId)

		if forceTexture then
			spellIcon = forceTexture
		end

		spellName = spellName or actualSpellName or "unknown_aura"
		modRate = modRate or 1

		if (spellIcon) then
			---@type df_icon
			local iconFrame = self:GetIcon()
			iconFrame.Texture:SetTexture(spellIcon)
			iconFrame.Texture:SetTexCoord(unpack(self.options.texcoord))

			if (borderColor) then
				iconFrame:SetBackdropBorderColor(detailsFramework:ParseColors(borderColor))
			else
				iconFrame:SetBackdropBorderColor(0, 0, 0 ,0)
			end

			--iconFrame.Border:SetColorTexture(0, 0, 0, 1)

			if (startTime) then
				local now = GetTime()

				iconFrame.timeRemaining = (startTime + duration - now) / (modRate or 1)
				iconFrame.expirationTime = startTime + duration
				
				if iconFrame.timeRemaining > 0 then
					CooldownFrame_Set(iconFrame.Cooldown, startTime, duration, true, true, modRate)
				end

				if (self.options.show_text) then
					iconFrame.CountdownText:Show()

					local formattedTime = (iconFrame.timeRemaining > 0) and (self.options.decimal_timer and iconFrame.parentIconRow.FormatCooldownTimeDecimal(iconFrame.timeRemaining) or iconFrame.parentIconRow.FormatCooldownTime(iconFrame.timeRemaining)) or ""
					iconFrame.CountdownText:SetText(formattedTime)

					iconFrame.CountdownText:SetPoint(self.options.text_anchor or "center", iconFrame, self.options.text_rel_anchor or "center", self.options.text_x_offset or 0, self.options.text_y_offset or 0)
					detailsFramework:SetFontSize(iconFrame.CountdownText, self.options.text_size)
					detailsFramework:SetFontFace (iconFrame.CountdownText, self.options.text_font)
					detailsFramework:SetFontOutline (iconFrame.CountdownText, self.options.text_outline)

					if self.options.on_tick_cooldown_update then
						iconFrame.lastUpdateCooldown = now
						iconFrame:SetScript("OnUpdate", self.OnIconTick)
					else
						iconFrame:SetScript("OnUpdate", nil)
					end

				else
					iconFrame:SetScript("OnUpdate", nil)
					iconFrame.CountdownText:Hide()
				end

				iconFrame.Cooldown:SetReverse(self.options.cooldown_reverse)
				iconFrame.Cooldown:SetDrawSwipe(self.options.cooldown_swipe_enabled)
				iconFrame.Cooldown:SetEdgeTexture(self.options.cooldown_edge_texture)
				iconFrame.Cooldown:SetHideCountdownNumbers(self.options.surpress_blizzard_cd_timer)
				iconFrame.Cooldown:Show()
			else
				iconFrame.timeRemaining = nil
				iconFrame.expirationTime = nil
				iconFrame:SetScript("OnUpdate", nil)
				iconFrame.CountdownText:Hide()
				iconFrame.Cooldown:Hide()
			end

			if (descText and self.options.desc_text) then
				iconFrame.Desc:Show()
				iconFrame.Desc:SetText(descText.text)
				iconFrame.Desc:SetTextColor(detailsFramework:ParseColors(descText.text_color or self.options.desc_text_color))
				iconFrame.Desc:SetPoint(self.options.desc_text_anchor or "bottom", iconFrame, self.options.desc_text_rel_anchor or "top", self.options.desc_text_x_offset or 0, self.options.desc_text_y_offset or 2)
				detailsFramework:SetFontSize(iconFrame.Desc, descText.text_size or self.options.desc_text_size)
				detailsFramework:SetFontFace(iconFrame.Desc, self.options.desc_text_font)
				detailsFramework:SetFontOutline(iconFrame.Desc, self.options.desc_text_outline)
			else
				iconFrame.Desc:Hide()
			end

			if (count and count > 1 and self.options.stack_text) then
				iconFrame.StackText:Show()
				iconFrame.StackText:SetText(count)
				iconFrame.StackText:SetTextColor(detailsFramework:ParseColors(self.options.stack_text_color))
				iconFrame.StackText:SetPoint(self.options.stack_text_anchor or "center", iconFrame, self.options.stack_text_rel_anchor or "center", self.options.stack_text_x_offset or 0, self.options.stack_text_y_offset or 0)
				detailsFramework:SetFontSize(iconFrame.StackText, self.options.stack_text_size)
				detailsFramework:SetFontFace(iconFrame.StackText, self.options.stack_text_font)
				detailsFramework:SetFontOutline(iconFrame.StackText, self.options.stack_text_outline)
			else
				iconFrame.StackText:Hide()
			end

			iconFrame.stacks = count or 0

			iconFrame.width = self.options.icon_width
			iconFrame.height = self.options.icon_height
			iconFrame.textureWidth = iconFrame.Texture:GetWidth()
			iconFrame.textureHeight = iconFrame.Texture:GetHeight()
			PixelUtil.SetSize(iconFrame, iconFrame.width, iconFrame.height)
			iconFrame:Show()

			--update the size of the frame
			self:SetWidth((self.options.left_padding * 2) + (self.options.icon_padding * (self.NextIcon-2)) + (self.options.icon_width * (self.NextIcon - 1)))
			self:SetHeight(self.options.icon_height + (self.options.top_padding * 2))

			--make information available
			iconFrame.spellId = spellId
			iconFrame.startTime = startTime
			iconFrame.duration = duration
			iconFrame.count = count
			iconFrame.debuffType = debuffType
			iconFrame.caster = caster
			iconFrame.canStealOrPurge = canStealOrPurge
			iconFrame.isBuff = isBuff
			iconFrame.spellName = spellName
			iconFrame.modRate = modRate

			iconFrame.identifierKey = nil -- only used for "specific" add/remove

			--add the spell into the cache
			self.AuraCache[spellId or -1] = true
			self.AuraCache[spellName] = true
			self.AuraCache.canStealOrPurge = self.AuraCache.canStealOrPurge or canStealOrPurge
			self.AuraCache.hasEnrage = self.AuraCache.hasEnrage or debuffType == "" --yes, enrages are empty-string...

			--show the frame
			self:Show()

			return iconFrame
		end
	end,

	SetStacks = function(self, iconFrame, bIsShown, stacksAmount)
		if (bIsShown) then
			iconFrame.StackText:Show()
			iconFrame.StackTextShadow:Show()
			iconFrame.StackText:SetText(stacksAmount)
			iconFrame.StackTextShadow:SetText(stacksAmount)
			iconFrame.stacks = stacksAmount
		else
			iconFrame.StackText:Hide()
			iconFrame.StackTextShadow:Hide()
			iconFrame.stacks = 0
		end
	end,

	---@param self df_icon
	---@param deltaTime number
	OnIconTick = function(self, deltaTime)
		local now = GetTime()
		if (self.lastUpdateCooldown + 0.05) <= now then
			self.timeRemaining = (self.expirationTime - now) / (self.modRate or 1)
			if self.timeRemaining > 0 then
				if self.parentIconRow.options.decimal_timer then
					self.CountdownText:SetText(self.parentIconRow.FormatCooldownTimeDecimal(self.timeRemaining))
				else
					self.CountdownText:SetText(self.parentIconRow.FormatCooldownTime(self.timeRemaining))
				end
			else
				self.CountdownText:SetText("")
			end
			self.lastUpdateCooldown = now
		end
	end,

	FormatCooldownTime = function(thisTime)
		if (thisTime >= 3600) then
			thisTime = math.floor(thisTime / 3600) .. "h"

		elseif (thisTime >= 60) then
			thisTime = math.floor(thisTime / 60) .. "m"

		else
			thisTime = math.floor(thisTime)
		end
		return thisTime
	end,

	FormatCooldownTimeDecimal = function(formattedTime)
        if formattedTime < 10 then
            return ("%.1f"):format(formattedTime)

        elseif formattedTime < 60 then
            return ("%d"):format(formattedTime)

        elseif formattedTime < 3600 then
            return ("%d:%02d"):format(formattedTime/60%60, formattedTime%60)

        elseif formattedTime < 86400 then
            return ("%dh %02dm"):format(formattedTime/(3600), formattedTime/60%60)

        else
            return ("%dd %02dh"):format(formattedTime/86400, (formattedTime/3600) - (math.floor(formattedTime/86400) * 24))
        end
	end,

	---@param self df_iconrow the parent frame
	---@param identifierKey any
	RemoveSpecificIcon = function(self, identifierKey)
		if (not identifierKey or identifierKey == "") then
			return
		end

		if (not self.AuraCache[identifierKey]) then
			return
		end
		self.AuraCache[identifierKey] = nil

		local iconPool = self.IconPool

		--find and hide the icon frame
		for i = 1, self.NextIcon -1 do
			local iconFrame = iconPool[i]
			if (iconFrame.identifierKey and iconFrame.identifierKey == identifierKey) then
				iconFrame:Hide()
				iconFrame:ClearAllPoints()
				iconFrame.identifierKey = nil
			else
				self.AuraCache[iconFrame.spellId] = true
				self.AuraCache[iconFrame.spellName] = true
				self.AuraCache.canStealOrPurge = self.AuraCache.canStealOrPurge or iconFrame.canStealOrPurge
				self.AuraCache.hasEnrage = self.AuraCache.hasEnrage or iconFrame.debuffType == "" --yes, enrages are empty-string...
			end
		end

		self:AlignAuraIcons()
	end,

	---@param self df_iconrow the parent frame
	ClearIcons = function(self, resetBuffs, resetDebuffs)
		resetBuffs = resetBuffs ~= false
		resetDebuffs = resetDebuffs ~= false
		table.wipe(self.AuraCache)

		local iconPool = self.IconPool
		local iconsActive = 0

		for i = 1, self.NextIcon -1 do
			local iconFrame = iconPool[i]
			if (iconFrame.isBuff == nil) then
				iconFrame:Hide()
				iconFrame:ClearAllPoints()

			elseif (resetBuffs and iconFrame.isBuff) then
				iconFrame:Hide()
				iconFrame:ClearAllPoints()

			elseif (resetDebuffs and not iconFrame.isBuff) then
				iconFrame:Hide()
				iconFrame:ClearAllPoints()

			else
				self.AuraCache[iconFrame.spellId] = true
				self.AuraCache[iconFrame.spellName] = true
				self.AuraCache.canStealOrPurge = self.AuraCache.canStealOrPurge or iconFrame.canStealOrPurge
				self.AuraCache.hasEnrage = self.AuraCache.hasEnrage or iconFrame.debuffType == "" --yes, enrages are empty-string...
				iconsActive = iconsActive + 1
			end
		end

		-- this is needed in any case, to ensure updated 'self.NextIcon'
		self:AlignAuraIcons()
	end,

	---@param self df_iconrow the parent frame
	AlignAuraIcons = function(self)
		local iconPool = self.IconPool
		local iconAmount = #iconPool
		local countStillShown = 0

		if iconAmount == 0 then
			self:Hide()
		else
			table.sort(iconPool, function(i1, i2) return i1:IsShown() and not i2:IsShown() end)
			local shownAmount = 0
			for i = 1, iconAmount do
				if iconPool[i]:IsShown() then
					shownAmount = shownAmount + 1
				end
			end

			local width = 0

			--re-anchor not hidden
			for i = 1, shownAmount do
				local iconFrame = iconPool[i]
				local anchor = self.options.anchor
				local anchorTo = i == 1 and self or self.IconPool[i - 1]
				local xPadding = i == 1 and self.options.left_padding or self.options.icon_padding or 1
				local growDirection = self.options.grow_direction

				countStillShown = countStillShown + (iconFrame:IsShown() and 1 or 0)

				iconFrame:ClearAllPoints()

				if (growDirection == 1) then --grow to right
					if (i == 1) then
						PixelUtil.SetPoint(iconFrame, "left", anchorTo, "left", xPadding, 0)
					else
						PixelUtil.SetPoint(iconFrame, "left", anchorTo, "right", xPadding, 0)
					end

				elseif (growDirection == 2) then --grow to left
					if (i == 1) then
						PixelUtil.SetPoint(iconFrame, "right", anchorTo, "right", xPadding, 0)
					else
						PixelUtil.SetPoint(iconFrame, "right", anchorTo, "left", xPadding, 0)
					end
				end

				width = width + ((iconFrame.width or iconFrame:GetWidth()) * iconFrame:GetScale()) + xPadding
			end

			if (self.options.center_alignment) then
				self:SetWidth(width)
			end

			self.shownAmount = shownAmount
		end
		
		if countStillShown > 0 then
			self:Show()
		end

		self.NextIcon = countStillShown + 1

		if countStillShown > 0 then
			self:Show()
		end
	end,

	---@param self df_iconrow the parent frame
	GetIconGrowDirection = function(self)
		local side = self.options.anchor.side
		return detailsFramework.GrowDirectionBySide[side]
	end,

	---@param self df_iconrow the parent frame
	OnOptionChanged = function(self, optionName)
		if (self.SetBackdropColor) then
			self:SetBackdropColor(unpack(self.options.backdrop_color))
			self:SetBackdropBorderColor(unpack(self.options.backdrop_border_color))
		end
	end,
}

local default_icon_row_options = {
	icon_width = 20,
	icon_height = 20,
	texcoord = {.1, .9, .1, .9},
	show_text = true,
	text_color = {1, 1, 1, 1},
	text_size = 12,
	text_font = "Arial Narrow",
	text_outline = "NONE",
	text_anchor = "center",
	text_rel_anchor = "center",
	text_x_offset = 0,
	text_y_offset = 0,
	desc_text = true,
	desc_text_color = {1, 1, 1, 1},
	desc_text_size = 7,
	desc_text_font = "Arial Narrow",
	desc_text_outline = "NONE",
	desc_text_anchor = "bottom",
	desc_text_rel_anchor = "top",
	desc_text_x_offset = 0,
	desc_text_y_offset = 2,
	stack_text = true,
	stack_text_color = {1, 1, 1, 1},
	stack_text_size = 10,
	stack_text_font = "Arial Narrow",
	stack_text_outline = "NONE",
	stack_text_anchor = "center",
	stack_text_rel_anchor = "bottomright",
	stack_text_x_offset = 0,
	stack_text_y_offset = 0,
	left_padding = 1, --distance between right and left
	top_padding = 1, --distance between top and bottom
	icon_padding = 1, --distance between each icon
	backdrop = {},
	backdrop_color = {0, 0, 0, 0.5},
	backdrop_border_color = {0, 0, 0, 1},
	anchor = {side = 6, x = 2, y = 0},
	grow_direction = 1, --1 = to right 2 = to left
	center_alignment = false, --if true if will align the icons with grow_direction and then set the iconRow width to match the length used by all icons
	surpress_blizzard_cd_timer = false,
	surpress_tulla_omni_cc = false,
	on_tick_cooldown_update = true,
	decimal_timer = false,
	cooldown_reverse = false,
	cooldown_swipe_enabled = true,
	cooldown_edge_texture = "Interface\\Cooldown\\edge",
}

---@param parent frame
---@param name string?
---@param options table?
---@return df_iconrow
function detailsFramework:CreateIconRow(parent, name, options)
	local newIconRowFrame = CreateFrame("frame", name, parent, "BackdropTemplate")
	newIconRowFrame.IconPool = {}
	newIconRowFrame.NextIcon = 1
	newIconRowFrame.AuraCache = {}
	newIconRowFrame.shownAmount = 0

	detailsFramework:Mixin(newIconRowFrame, detailsFramework.IconMixin)
	detailsFramework:Mixin(newIconRowFrame, detailsFramework.OptionsFunctions)

	newIconRowFrame:BuildOptionsTable(default_icon_row_options, options)

	newIconRowFrame:SetSize(newIconRowFrame.options.icon_width, newIconRowFrame.options.icon_height + (newIconRowFrame.options.top_padding * 2))

	newIconRowFrame:SetBackdrop(newIconRowFrame.options.backdrop)
	newIconRowFrame:SetBackdropColor(unpack(newIconRowFrame.options.backdrop_color))
	newIconRowFrame:SetBackdropBorderColor(unpack(newIconRowFrame.options.backdrop_border_color))

	return newIconRowFrame
end