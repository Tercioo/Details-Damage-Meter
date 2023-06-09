
	local addonName, Details222 = ...
	local Details = 		_G.Details
	local _
	local ipairs = ipairs
	local _time = _G.time

	local timeMachine = Details.timeMachine
	local _tempo = _time()

	timeMachine.bIsEnabled = false

	local calculateTimeFor_PvP = function(self)
		for attributeType, thisDatabase in ipairs(self.playerDatabase) do
			for actorObject in pairs(thisDatabase) do
				if (not actorObject.last_event) then
					print("actor without last event, is destroyed?", actorObject.__destroyed, actorObject.__destroyedBy)
				end
				if (actorObject.last_event + 3 > _tempo) then
					if (actorObject.on_hold) then --the timer is on pause, turn it on
						Details222.TimeMachine.SetOrGetPauseState(actorObject, false)
					end
				else
					if (not actorObject.on_hold) then --not in pause, need to pause
						--check if the player is casting something that takes more than 3 seconds
						Details222.TimeMachine.SetOrGetPauseState(actorObject, true)
					end
				end
			end
		end
	end

	local calculateTimeFor_PvE = function(self)
		for attributeType, thisDatabase in ipairs(self.playerDatabase) do
			for actorObject in pairs(thisDatabase) do
				if (not actorObject.last_event) then
					print("actor without last event, is destroyed?", actorObject.__destroyed, actorObject.__destroyedBy)
				end
				if (actorObject.last_event + 10 > _tempo) then
					if (actorObject.on_hold) then --the timer is on pause, turn it on
						Details222.TimeMachine.SetOrGetPauseState(actorObject, false)
					end
				else
					if (not actorObject.on_hold) then --not in pause, need to pause
						--check if the player is casting something that takes more than 3 seconds
						Details222.TimeMachine.SetOrGetPauseState(actorObject, true)
					end
				end
			end
		end
	end

	function Details222.TimeMachine.Ticker()
		_tempo = _time()
		Details._tempo = _tempo
		Details:UpdateGears()

		if (Details.is_in_battleground or Details.is_in_arena) then
			return calculateTimeFor_PvP(timeMachine)
		else
			return calculateTimeFor_PvE(timeMachine)
		end
	end

	function Details222.TimeMachine.Start()
		timeMachine.updateTicker = Details.Schedules.NewTicker(1, Details222.TimeMachine.Ticker)
		timeMachine.bIsEnabled = true

		---@type table<actor, boolean>
		local storeDamageActors = setmetatable({}, Details.weaktable)
		---@type table<actor, boolean>
		local storeHealingActors = setmetatable({}, Details.weaktable)

		---@type {key1: table<actor, boolean>, key2: table<actor, boolean>}
		timeMachine.playerDatabase = {
			storeDamageActors, --store damage actors
			storeHealingActors --store healing actors
		}

		---@type combat
		local currentCombat = Details:GetCurrentCombat()
		---@type actorcontainer
		local damageContainer = currentCombat:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)

		for _, actorObject in damageContainer:ListActors() do
			---@cast actorObject actor
			if (actorObject.dps_started) then
				Details222.TimeMachine.AddActor(actorObject)
			end
		end
	end

	---remove actors with __destroyed flag
	function Details222.TimeMachine.Cleanup()
		for attributeType, thisDatabase in ipairs(timeMachine.playerDatabase) do
			for actorObject in pairs(thisDatabase) do
				if (actorObject.__destroyed) then
					thisDatabase[actorObject] = nil
				end
			end
		end
	end

	function Details222.TimeMachine.Restart()
		Details:Destroy(timeMachine.playerDatabase[1])
		Details:Destroy(timeMachine.playerDatabase[2])

		---@type table<actor, boolean>
		local storeDamageActors = setmetatable({}, Details.weaktable)
		---@type table<actor, boolean>
		local storeHealingActors = setmetatable({}, Details.weaktable)

		---@type {key1: table<actor, boolean>, key2: table<actor, boolean>}
		timeMachine.playerDatabase = {
			storeDamageActors, --store damage actors
			storeHealingActors --store healing actors
		}
	end

	---@param actorObject actor
	function Details222.TimeMachine.RemoveActor(actorObject)
		local thisDatabase = timeMachine.playerDatabase[actorObject.tipo]
		--check if the database exists, the type could be wrong due to passing an resource or utility actor
		if (thisDatabase) then
			if (thisDatabase[actorObject]) then
				thisDatabase[actorObject] = nil
			end
		end
	end

	function Details222.TimeMachine.AddActor(actorObject)
		local thisDatabase = timeMachine.playerDatabase[actorObject.tipo]
		if (thisDatabase) then
			thisDatabase[actorObject] = true
		end
	end

	function Details222.TimeMachine.StopTime(actorObject)
		if (actorObject.end_time) then
			return
		end

		if (actorObject.on_hold) then
			Details222.TimeMachine.SetOrGetPauseState(actorObject, false)
		end

		actorObject.end_time = _tempo
	end

	---get the pause state or pause/unpause the timer of the player
	---@param actorObject actor
	---@param bIsPaused boolean|nil
	function Details222.TimeMachine.SetOrGetPauseState(actorObject, bIsPaused)
		if (bIsPaused == nil) then
			return actorObject.on_hold --return if the timer is paused or not

		elseif (bIsPaused) then --if true - pause the timer
			if (not actorObject.last_event) then
				print("actor without last event, is destroyed?", actorObject.__destroyed, actorObject.__destroyedBy)
			end
			actorObject.delay = math.floor(actorObject.last_event) --_tempo - 10
			if (actorObject.delay < actorObject.start_time) then
				actorObject.delay = actorObject.start_time
			end
			actorObject.on_hold = true

		else --if false - unpause the timer
			local diff = _tempo - actorObject.delay - 1
			if (diff > 0) then
				actorObject.start_time = actorObject.start_time + diff
			end
			actorObject.on_hold = false
		end
	end

	---@param self actor
	function Details:Tempo()
		if (self.pvp) then
			--pvp timer
			if (self.end_time) then --the timer of the player is locked
				local timer = self.end_time - self.start_time
				if (timer < 3) then
					timer = 3
				end
				return timer

			elseif (self.on_hold) then --the timer is paused
				local timer = self.delay - self.start_time
				if (timer < 3) then
					timer = 3
				end
				return timer

			else
				if (self.start_time == 0) then
					return 3
				end

				local timer = _tempo - self.start_time
				if (timer < 3) then
					if (Details.in_combat) then
						local combat_time = Details.tabela_vigente:GetCombatTime()
						if (combat_time < 3) then
							return combat_time
						end
					end
					timer = 3
				end
				return timer
			end
		else
			--pve timer
			if (self.end_time) then --the timer of the player is locked
				local timer = self.end_time - self.start_time
				if (timer < 10) then
					timer = 10
				end
				return timer

			elseif (self.on_hold) then --the timer is paused
				local timer = self.delay - self.start_time
				if (timer < 10) then
					timer = 10
				end
				return timer

			else
				if (self.start_time == 0) then
					return 10
				end

				local timer = _tempo - self.start_time
				if (timer < 10) then
					if (Details.in_combat) then
						---@type combat
						local currentCombat = Details:GetCurrentCombat()
						local combatTime = currentCombat:GetCombatTime()
						if (combatTime < 10) then
							return combatTime
						end
					end

					timer = 10
				end

				return timer
			end
		end
	end