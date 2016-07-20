 
do

	local Details = Details
	if (not Details) then
		print ("Calc Leech cannot be installed: Details! not found.")
		return
	end

	local _

	--> minimal details version required to run this plugin
	local MINIMAL_DETAILS_VERSION_REQUIRED = 81
	local CLEECH_VERSION = "v1.2"

	--> create a plugin object
	local calcLeech = Details:NewPluginObject ("Details_CalcLeech", DETAILSPLUGIN_ALWAYSENABLED)
	--> just localizing here the plugin's main frame
	local frame = calcLeech.Frame
	--> set the description
	calcLeech:SetPluginDescription ("Calculates the healing done by the trinket leech.")
	--> get the framework object
	local framework = calcLeech:GetFramework()
	
	local CUSTOM_DISPLAY_VERSION = 3
	local CUSTOM_DISPLAY_NAME = "CalcLeech"
	
	local create_custom_object = function()
		local new_object = {
			name = CUSTOM_DISPLAY_NAME,
			icon = [[Interface\ICONS\spell_shadow_lifedrain02]],
			attribute = false,
			spellid = false,
			author = "Details!",
			desc = "Calculates healing done from leech trinket.",
			source = false,
			target = false,
			script_version = CUSTOM_DISPLAY_VERSION,
			script = [[
				--get the parameters passed
				local Combat, CustomContainer, Instance = ...
				--declade the values to return
				local total, top, amount = 0, 0, 0
				
				if (Combat.PlayerLeechTrinket) then
					for playerName, amount in pairs (Combat.PlayerLeechTrinket) do
						local healActor = Combat:GetActor (2, playerName)
						if (healActor) then
							CustomContainer:AddValue (healActor, amount)
						end
					end
				end
				
				--if not managed inside the loop, get the values of total, top and amount
				total, top = CustomContainer:GetTotalAndHighestValue()
				amount = CustomContainer:GetNumActors()

				--return the values
				return total, top, amount
			]],
			tooltip = [[
				
			]],
		}
		
		calcLeech:InstallCustomObject (new_object)	
	end
	
	local rosterLeechAmount = {}
	
	local f = CreateFrame ("frame")
	f:SetScript ("OnEvent", function (self, event, time, token, hidding, who_serial, who_name, who_flags, who_flags2, target_serial, target_name, target_flags, target_flags2, spellid, spellname, spelltype, amount, overhealing, absorbed, critical, multistrike, is_shield)
		if (token == "SPELL_HEAL" and spellid == 143924) then --http://www.wowhead.com/spell=143924/leech
			
			--> The next few lines of code is based on an aura for WeakAuras 2, I couldn't find who is the original author since this same code is used on many different versions of the aura.
			--> If you are the original author, please contact-me on curseforge so I can add the credits here.
			local healed = amount - overhealing
			if (healed > 0) then
				wipe (rosterLeechAmount)
				local total_leech = 0
				
				for i = 1, 40 do 
					local name, _, _, _, _, _, _, source, _, _, id, _, _, _, _, _, leech = UnitAura (target_name, i)
					if (type (leech) == "number") then
						if (name and id == 184671 and source) then
							rosterLeechAmount [UnitName (source)] = leech
							total_leech = total_leech + leech
						end
					end
				end 
				
				if (total_leech > 0) then
					for from, leech_amount in pairs (rosterLeechAmount) do
						if (not calcLeech.combat.PlayerLeechTrinket [from]) then
							calcLeech.combat.PlayerLeechTrinket [from] = 0
						end 
						calcLeech.combat.PlayerLeechTrinket [from] = calcLeech.combat.PlayerLeechTrinket [from] + (healed * (leech_amount / total_leech))
					end	
				end
			end
			-------------
			
		--elseif (token == "SPELL_AURA_APPLIED") then
			
		--elseif (token == "SPELL_AURA_REMOVED") then
			
		--elseif (token == "SPELL_AURA_REFRESH") then
			
		end
	end)		

	--> when receiving an event from details, handle it here
	local player_has_trinket = function (combat)
	
		calcLeech.combat = combat
	
		-->  check if exists a custom display to show the trinket leech
		local customObject = calcLeech:GetCustomObject (CUSTOM_DISPLAY_NAME)
		if (customObject) then
			if (customObject.script_version < CUSTOM_DISPLAY_VERSION) then
				calcLeech:RemoveCustomObject (CUSTOM_DISPLAY_NAME)
				create_custom_object()
			end
		else
			create_custom_object()
		end
		
		calcLeech.combat.PlayerLeechTrinket = {}
		
		f:RegisterEvent ("COMBAT_LOG_EVENT_UNFILTERED")
		
	end
	
	local handle_details_event = function (event, ...)
		
		if (event == "COMBAT_PLAYER_ENTER") then
			if (true) then
				player_has_trinket (...)
			else
				local role = UnitGroupRolesAssigned ("player")
				if (role == "HEALER") then
					local trinket1 = GetInventoryItemLink ("player", 13)
					if (trinket1 and trinket1:find ("124234")) then
						player_has_trinket (...)
					end
					local trinket2 = GetInventoryItemLink ("player", 14)
					if (trinket2 and trinket2:find ("124234")) then
						player_has_trinket (...)
					end
				end
			end
			
		elseif (event == "COMBAT_PLAYER_LEAVE") then
			--> details finished a segment
			f:UnregisterEvent ("COMBAT_LOG_EVENT_UNFILTERED")
		
		elseif (event == "PLUGIN_DISABLED") then
			--> plugin has been disabled at the details options panel
		
		elseif (event == "PLUGIN_ENABLED") then
			--> plugin has been enabled at the details options panel
		
		end
		
	end
	
	function calcLeech:OnEvent (_, event, ...)
	
		if (event == "ADDON_LOADED") then
			local AddonName = select (1, ...)
			if (AddonName == "Details_CalcLeech") then
				
				--> every plugin must have a OnDetailsEvent function
				function calcLeech:OnDetailsEvent (event, ...)
					return handle_details_event (event, ...)
				end
				
				--> Install: install -> if successful installed; saveddata -> a table saved inside details db, used to save small amount of data like configs
				local install, saveddata = Details:InstallPlugin ("TOOLBAR", "Leech Trinket", "Interface\\Icons\\spell_shadow_lifedrain02", calcLeech, "DETAILS_PLUGIN_LEECH_TRINKET", MINIMAL_DETAILS_VERSION_REQUIRED, "Details! Team", CLEECH_VERSION)
				if (type (install) == "table" and install.error) then
					print (install.error)
				end
				
				--> registering details events we need
				Details:RegisterEvent (calcLeech, "COMBAT_PLAYER_ENTER") --when details creates a new segment, not necessary the player entering in combat.
				Details:RegisterEvent (calcLeech, "COMBAT_PLAYER_LEAVE") --when details finishs a segment, not necessary the player leaving the combat.
			end
		end

	end

end




