--> Library NickTag is a small library for share individual nicknames and avatars.

--> Basic Functions:
-- NickTag:SetNickname (name) -> set the player nick name, after set nicktag will broadcast the nick over addon guild channel.
-- 

local major, minor = "NickTag-1.0", 10
local NickTag, oldminor = LibStub:NewLibrary (major, minor)

if (not NickTag) then 
	return 
end

--> fix for old nicktag version
if (_G.NickTag) then
	if (_G.NickTag.OnEvent) then
		_G.NickTag:UnregisterComm ("NickTag")
		_G.NickTag.OnEvent = nil
	end
end

------------------------------------------------------------------------------------------------------------------------------------------------------
--> constants

	local CONST_INDEX_NICKNAME = 1
	local CONST_INDEX_AVATAR_PATH = 2
	local CONST_INDEX_AVATAR_TEXCOORD = 3
	local CONST_INDEX_BACKGROUND_PATH = 4
	local CONST_INDEX_BACKGROUND_TEXCOORD = 5
	local CONST_INDEX_BACKGROUND_COLOR = 6
	local CONST_INDEX_REVISION = 7

	local CONST_COMM_FULLPERSONA = 1
	local CONST_COMM_LOGONREVISION = 2
	local CONST_COMM_REQUESTPERSONA = 3
	
	--[[global]] NICKTAG_DEFAULT_AVATAR = [[Interface\EncounterJournal\UI-EJ-BOSS-Default]]
	--[[global]] NICKTAG_DEFAULT_BACKGROUND = [[Interface\PetBattles\Weather-ArcaneStorm]]
	--[[global]] NICKTAG_DEFAULT_BACKGROUND_CORDS = {0.129609375, 1, 1, 0}
	
------------------------------------------------------------------------------------------------------------------------------------------------------
--> library stuff

	_G.NickTag = NickTag --> nicktag object over global container

	local pool = {default = true} --> pointer to the cache pool and the default pool if no cache
	local queue_request = {}
	local queue_send = {}
	local last_queue = 0
	local is_updating = false
	NickTag.debug = false
	
	local GetGuildRosterInfo = GetGuildRosterInfo

	LibStub:GetLibrary ("AceComm-3.0"):Embed (NickTag)
	LibStub:GetLibrary ("AceSerializer-3.0"):Embed (NickTag)
	LibStub:GetLibrary ("AceTimer-3.0"):Embed (NickTag)
	local CallbackHandler = LibStub:GetLibrary ("CallbackHandler-1.0")
	NickTag.callbacks = NickTag.callbacks or CallbackHandler:New (NickTag)
	
	NickTag.embeds = NickTag.embeds or {}
	local embed_functions = {
		"SetNickname",
		"SetNicknameAvatar",
		"SetNicknameBackground",
		"GetNickname",
		"GetNicknameAvatar",
		"GetNicknameBackground",
		"GetNicknameTable",
		"NickTagSetCache"
	}
	function NickTag:Embed (target)
		for k, v in pairs (embed_functions) do
			target[v] = self[v]
		end
		self.embeds [target] = true
		return target
	end
	
	function NickTag:Msg (...)
		if (NickTag.debug) then
			print ("|cFFFFFF00NickTag:|r", ...)
		end
	end
	
	local enUS = LibStub("AceLocale-3.0"):NewLocale ("NickTag-1.0", "enUS", true)
	if (enUS) then
		enUS ["STRING_ERROR_1"] = "Your nickname is too long, max of 12 characters is allowed."
		enUS ["STRING_ERROR_2"] = "Only letters and two spaces are allowed."
		enUS ["STRING_ERROR_3"] = "You can't use the same letter three times consecutively, two spaces consecutively or more then two spaces."
		enUS ["STRING_ERROR_4"] = "Name isn't a valid string."
		enUS ["STRING_INVALID_NAME"] = "Invalid Name"
	end
	
	local ptBR = LibStub("AceLocale-3.0"):NewLocale ("NickTag-1.0", "ptBR")
	if (ptBR) then
		ptBR ["STRING_ERROR_1"] = "Seu apelido esta muito longo, o maximo permitido sao 12 caracteres."
		ptBR ["STRING_ERROR_2"] = "Apenas letras, numeros e espacos sao permitidos no apelido."
		ptBR ["STRING_ERROR_3"] = "Voce nao pode usar a mesma letra mais de 2 vezes consecutivas, dois espacos consecutivos ou mais de 2 espacos."
		ptBR ["STRING_ERROR_4"] = "Nome nao eh uma string valida."
		ptBR ["STRING_INVALID_NAME"] = "Nome Invalido"
	end
	
	NickTag.background_pool = {
		{[[Interface\PetBattles\Weather-ArcaneStorm]], "Arcane Storm", {0.129609375, 1, 1, 0}},
		{[[Interface\PetBattles\Weather-Blizzard]], "Blizzard", {0.068704154, 1, 1, 0}},
		{[[Interface\PetBattles\Weather-BurntEarth]], "Burnt Earth", {0.087890625, 0.916015625, 1, 0}},
		{[[Interface\PetBattles\Weather-Darkness]], "Darkness", {0.080078125, 0.931640625, 1, 0}},
		{[[Interface\PetBattles\Weather-Moonlight]], "Moonlight", {0.02765625, 0.94359375, 1, 0}},
		{[[Interface\PetBattles\Weather-Moonlight]], "Moonlight (reverse)", {0.94359375, 0.02765625, 1, 0}},
		{[[Interface\PetBattles\Weather-Mud]], "Mud", {0.068359375, 0.94359375, 1, 0}},
		{[[Interface\PetBattles\Weather-Rain]], "Rain", {0.078125, 0.970703125, 1, 0}},
		{[[Interface\PetBattles\Weather-Sandstorm]], "Sand Storm", {0.048828125, 0.947265625, 1, 0}},
		{[[Interface\PetBattles\Weather-StaticField]], "Static Field", {0.1171875, 0.953125, 1, 0}},
		{[[Interface\PetBattles\Weather-Sunlight]], "Sun Light", {0.1772721, 0.953125, 1, 0}},
		{[[Interface\PetBattles\Weather-Windy]], "Windy", {0.9453125, 0.07421875, 0.8203125, 0}}
	}
	
	NickTag.avatar_pool = {
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Arcanist Doan]], "Arcanist Doan"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Archbishop Benedictus]], "Archbishop Benedictus"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Argent Confessor Paletress]], "Argent Confessor Paletress"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Armsmaster Harlan]], "Armsmaster Harlan"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Asira Dawnslayer]], "Asira Dawnslayer"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Baelog]], "Baelog"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Baron Ashbury]], "Baron Ashbury"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Baron Silverlaine]], "Baron Silverlaine"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Blood Guard Porung]], "Blood Guard Porung"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Bronjahm]], "Bronjahm"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Brother Korloff]], "Brother Korloff"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Captain Skarloc]], "Captain Skarloc"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Chief Ukorz Sandscalp]], "Chief Ukorz Sandscalp"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Commander Kolurg]], "Commander Kolurg"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Commander Malor]], "Commander Malor"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Commander Sarannis]], "Commander Sarannis"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Commander Springvale]], "Commander Springvale"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Commander Stoutbeard]], "Commander Stoutbeard"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Corla, Herald of Twilight]], "Corla, Herald of Twilight"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Cyanigosa]], "Cyanigosa"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Darkmaster Gandling]], "Darkmaster Gandling"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Doctor Theolen Krastinov]], "Doctor Theolen Krastinov"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-DoomRel]], "DoomRel"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Eadric the Pure]], "Eadric the Pure"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Emperor Thaurissan]], "Emperor Thaurissan"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Empyreal Queens]], "Lu'lin"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Exarch Maladaar]], "Exarch Maladaar"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Fineous Darkvire]], "Fineous Darkvire"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Galdarah]], "Galdarah"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Garajal the Spiritbinder]], "Garajal the Spiritbinder"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Garrosh Hellscream]], "Garrosh Hellscream"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-General Nazgrim]], "General Nazgrim"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Grand Champions-Alliance]], "Grand Champions-Alliance"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Grand Champions-Horde]], "Grand Champions-Horde"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Grand Magus Telestra]], "Grand Magus Telestra"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-HateRel]], "HateRel"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Hazzarah]], "Hazzarah"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Hearthsinger Forresten]], "Hearthsinger Forresten"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Helix Gearbreaker]], "Helix Gearbreaker"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-High Botanist Freywinn]], "High Botanist Freywinn"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-High Inquisitor Whitemane]], "High Inquisitor Whitemane"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-High Interrogator Gerstahn]], "High Interrogator Gerstahn"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-High Justice Grimstone]], "High Justice Grimstone"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Houndmaster Braun]], "Houndmaster Braun"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Houndmaster Loksey]], "Houndmaster Loksey"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Hydromancer Velratha]], "Hydromancer Velratha"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Illyanna Ravenoak]], "Illyanna Ravenoak"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Ingvar the Plunderer]], "Ingvar the Plunderer"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Instructor Galford]], "Instructor Galford"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Instructor Malicia]], "Instructor Malicia"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Interrogator Vishas]], "Interrogator Vishas"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Isiset]], "Isiset"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-JainaProudmoore]], "Jaina Proudmoore"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Jandice Barov]], "Jandice Barov"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Kaelthas Sunstrider]], "Kaelthas Sunstrider"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Kelidan the Breaker]], "Kelidan the Breaker"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Krick]], "Krick"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Lady Anacondra]], "Lady Anacondra"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Lady Illucia Barov]], "Lady Illucia Barov"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Lethtendris]], "Lethtendris"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Loken]], "Loken"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Lord Alexei Barov]], "Lord Alexei Barov"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Lord Aurius Rivendare]], "Lord Aurius Rivendare"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Lord Cobrahn]], "Lord Cobrahn"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Lord Pythas]], "Lord Pythas"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Lord Serpentis]], "Lord Serpentis"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Lorgus Jett]], "Lorgus Jett"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Mage Lord Urom]], "Mage Lord Urom"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Magister Kalendris]], "Magister Kalendris"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Magistrate Barthilas]], "Magistrate Barthilas"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Maiden of Grief]], "Maiden of Grief"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Maleki the Pallid]], "Maleki the Pallid"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Nethermancer Sepethrea]], "Nethermancer Sepethrea"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Olaf]], "Olaf"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Pathaleon the Calculator]], "Pathaleon the Calculator"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Prince Tortheldrin]], "Prince Tortheldrin"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Princess Moira Bronzebeard]], "Princess Moira Bronzebeard"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-QueenAzshara]], "Queen Azshara"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Randolph Moloch]], "Randolph Moloch"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Renataki]], "Renataki"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Ribbly Screwspigot]], "Ribbly Screwspigot"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Scarlet Commander Mograine]], "Scarlet Commander Mograine"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Selin Fireheart]], "Selin Fireheart"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Siegecrafter Blackfuse]], "Siegecrafter Blackfuse"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Skarvald the Constructor]], "Skarvald the Constructor"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Tribunal of the Ages]], "Tribunal of the Ages"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-TyrandeWhisperwind]], "Tyrande Whisperwind"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Twilight Lord Kelris]], "Twilight Lord Kelris"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Vanessa VanCleef]], "Vanessa VanCleef"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Vazruden]], "Vazruden"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Warchief Rend Blackhand]], "Warchief Rend Blackhand"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Willey Hopebreaker]], "Willey Hopebreaker"},
		{[[Interface\EncounterJournal\UI-EJ-BOSS-Witch Doctor Zumrah]], "Witch Doctor Zumrah"},
	}
------------------------------------------------------------------------------------------------------------------------------------------------------
--> send and receive functions

	function NickTag:OnReceiveComm (prefix, data, channel, source)
	
		if (not source) then
			return
		end
	
		local _type, serial, arg3, name, realm, version =  select (2, NickTag:Deserialize (data))

		--> 0x1: received a full persona
		if (_type == CONST_COMM_FULLPERSONA) then
			local receivedPersona = arg3
			version = name
			
			if (not receivedPersona or type (receivedPersona) ~= "table") then
				NickTag:Msg ("FULLPERSONA received but it's invalid ", source)
				return
			end
			
			if (source ~= UnitName ("player") and (version and version == minor) and receivedPersona) then

				local storedPersona = NickTag:GetNicknameTable (source)
				if (not storedPersona) then
					storedPersona = NickTag:Create (source)
				end
				
				if (storedPersona [CONST_INDEX_REVISION] < receivedPersona [CONST_INDEX_REVISION]) then
					storedPersona [CONST_INDEX_REVISION] = receivedPersona [CONST_INDEX_REVISION]
					
					--> we need to check if the received nickname fit in our rules.
					local allowNickName = NickTag:CheckName (receivedPersona [CONST_INDEX_NICKNAME])
					if (allowNickName) then
						storedPersona [CONST_INDEX_NICKNAME] = receivedPersona [CONST_INDEX_NICKNAME]
					else
						storedPersona [CONST_INDEX_NICKNAME] = LibStub ("AceLocale-3.0"):GetLocale ("NickTag-1.0")["STRING_INVALID_NAME"]
					end
					
					storedPersona [CONST_INDEX_NICKNAME] = receivedPersona [CONST_INDEX_NICKNAME]
					
					--> update the rest
						--avatar path
						storedPersona [CONST_INDEX_AVATAR_PATH] = type (receivedPersona [CONST_INDEX_AVATAR_PATH]) == "string" and receivedPersona [CONST_INDEX_AVATAR_PATH] or ""
						
						--avatar texcoord
						if (type (receivedPersona [CONST_INDEX_AVATAR_TEXCOORD]) == "boolean") then
							storedPersona [CONST_INDEX_AVATAR_TEXCOORD] = {0, 1, 0, 1}
							
						elseif (type (receivedPersona [CONST_INDEX_AVATAR_TEXCOORD]) == "table") then
							storedPersona [CONST_INDEX_AVATAR_TEXCOORD] = storedPersona [CONST_INDEX_AVATAR_TEXCOORD] or {}
							storedPersona [CONST_INDEX_AVATAR_TEXCOORD][1] = type (receivedPersona [CONST_INDEX_AVATAR_TEXCOORD][1]) == "number" and receivedPersona [CONST_INDEX_AVATAR_TEXCOORD][1] or 0
							storedPersona [CONST_INDEX_AVATAR_TEXCOORD][2] = type (receivedPersona [CONST_INDEX_AVATAR_TEXCOORD][2]) == "number" and receivedPersona [CONST_INDEX_AVATAR_TEXCOORD][2] or 1
							storedPersona [CONST_INDEX_AVATAR_TEXCOORD][3] = type (receivedPersona [CONST_INDEX_AVATAR_TEXCOORD][3]) == "number" and receivedPersona [CONST_INDEX_AVATAR_TEXCOORD][3] or 0
							storedPersona [CONST_INDEX_AVATAR_TEXCOORD][4] = type (receivedPersona [CONST_INDEX_AVATAR_TEXCOORD][4]) == "number" and receivedPersona [CONST_INDEX_AVATAR_TEXCOORD][4] or 1
						else
							storedPersona [CONST_INDEX_AVATAR_TEXCOORD] = {0, 1, 0, 1}
						end
						
						--background texcoord
						if (type (receivedPersona [CONST_INDEX_BACKGROUND_TEXCOORD]) == "boolean") then
							storedPersona [CONST_INDEX_BACKGROUND_TEXCOORD] = {0, 1, 0, 1}
							
						elseif (type (receivedPersona [CONST_INDEX_BACKGROUND_TEXCOORD]) == "table") then
							storedPersona [CONST_INDEX_BACKGROUND_TEXCOORD] = storedPersona [CONST_INDEX_BACKGROUND_TEXCOORD] or {}
							storedPersona [CONST_INDEX_BACKGROUND_TEXCOORD][1] = type (receivedPersona [CONST_INDEX_BACKGROUND_TEXCOORD][1]) == "number" and receivedPersona [CONST_INDEX_BACKGROUND_TEXCOORD][1] or 0
							storedPersona [CONST_INDEX_BACKGROUND_TEXCOORD][2] = type (receivedPersona [CONST_INDEX_BACKGROUND_TEXCOORD][2]) == "number" and receivedPersona [CONST_INDEX_BACKGROUND_TEXCOORD][2] or 1
							storedPersona [CONST_INDEX_BACKGROUND_TEXCOORD][3] = type (receivedPersona [CONST_INDEX_BACKGROUND_TEXCOORD][3]) == "number" and receivedPersona [CONST_INDEX_BACKGROUND_TEXCOORD][3] or 0
							storedPersona [CONST_INDEX_BACKGROUND_TEXCOORD][4] = type (receivedPersona [CONST_INDEX_BACKGROUND_TEXCOORD][4]) == "number" and receivedPersona [CONST_INDEX_BACKGROUND_TEXCOORD][4] or 1
						else
							storedPersona [CONST_INDEX_BACKGROUND_TEXCOORD] = {0, 1, 0, 1}
						end						
						
						--background path
						storedPersona [CONST_INDEX_BACKGROUND_PATH] = type (receivedPersona [CONST_INDEX_BACKGROUND_PATH]) == "string" and receivedPersona [CONST_INDEX_BACKGROUND_PATH] or ""
						
						--background color
						if (type (receivedPersona [CONST_INDEX_BACKGROUND_COLOR]) == "table") then
							storedPersona [CONST_INDEX_BACKGROUND_COLOR] = storedPersona [CONST_INDEX_BACKGROUND_COLOR] or {}
							storedPersona [CONST_INDEX_BACKGROUND_COLOR][1] = type (receivedPersona [CONST_INDEX_BACKGROUND_COLOR][1]) == "number" and receivedPersona [CONST_INDEX_BACKGROUND_COLOR][1] or 1
							storedPersona [CONST_INDEX_BACKGROUND_COLOR][2] = type (receivedPersona [CONST_INDEX_BACKGROUND_COLOR][2]) == "number" and receivedPersona [CONST_INDEX_BACKGROUND_COLOR][2] or 1
							storedPersona [CONST_INDEX_BACKGROUND_COLOR][3] = type (receivedPersona [CONST_INDEX_BACKGROUND_COLOR][3]) == "number" and receivedPersona [CONST_INDEX_BACKGROUND_COLOR][3] or 1
						else
							storedPersona [CONST_INDEX_BACKGROUND_COLOR] = {1, 1, 1}
						end
						
						NickTag:Msg ("FULLPERSONA received and updated for character: ", source, "new nickname: ", receivedPersona [CONST_INDEX_NICKNAME])
				end
			end
		
		--> 0x2: received a revision version from a guy which logon in the game
		elseif (_type == CONST_COMM_LOGONREVISION) then
		
			if (UnitName ("player") == source) then
				return
			end
		
			local receivedRevision = arg3
			local storedPersona = NickTag:GetNicknameTable (source)
			
			NickTag:Msg ("LOGONREVISION rev: ", receivedRevision, " source: ", source)
			
			if (type (version) ~= "number" or version ~= minor) then
				return
			end
			
			if (not storedPersona or storedPersona [CONST_INDEX_REVISION] < receivedRevision) then
				--> put in queue our request for receive a updated persona
				NickTag:ScheduleTimer ("QueueRequest", math.random (10, 60), source)
				
				NickTag:Msg ("LOGONREVISION from: " .. source .. " |cFFFF0000is out of date|r, queueing a request persona.")
			else
				NickTag:Msg ("LOGONREVISION from: " .. source .. " |cFF00FF00is up to date.")
			end
			
		--> 0x3: someone requested my persona, so i need to send to him
		elseif (_type == CONST_COMM_REQUESTPERSONA) then
			if (type (version) ~= "number" or version ~= minor) then
				return
			end
			
			--> queue to send our persona for requested person
			NickTag:Msg ("REQUESTPERSONA from: " .. source .. ", the request has been placed in queue.")
			
			NickTag:QueueSend (source)
		end

	end

	NickTag:RegisterComm ("NickTag", "OnReceiveComm")
	
	function NickTag:UpdateRoster()
		--> do not update roster if is in combat
		if (not UnitAffectingCombat ("player")) then
			GuildRoster()
		end
	end
	
	function NickTag:IsOnline (name)
	
		local isShownOffline = GetGuildRosterShowOffline()
		if (isShownOffline) then
			SetGuildRosterShowOffline (false)
		end
		
		local _, numOnlineMembers = GetNumGuildMembers()

		NickTag:Msg ("IsOnline(): " .. numOnlineMembers .. " online members.")
		
		for i = 1, numOnlineMembers do
			local player_name = GetGuildRosterInfo (i)
			if (player_name:find (name)) then
				if (isShownOffline) then
					SetGuildRosterShowOffline (true)
				end
				return true
			end
		end
		if (isShownOffline) then
			SetGuildRosterShowOffline (true)
		end
		return false
	end
	
	local event_frame = CreateFrame ("frame", nil, UIParent)
	event_frame:Hide()
	event_frame:SetScript ("OnEvent", function (_, _, local_update)
		if (not local_update) then
		
			--> roster was been updated
			if (last_queue < time()) then
				last_queue = time()+11
			else
				return
			end
			
			--> do not share if we are in combat
			if (UnitAffectingCombat ("player")) then
				return
			end
			
			--> start with send requested personas
			if (#queue_send > 0) then

				local name = queue_send [1]
				table.remove (queue_send, 1)
			
				NickTag:Msg ("QUEUE -> ready to send persona to " .. name)
				
				--> check if the player is online
				if (NickTag:IsOnline (name)) then
					NickTag:Msg ("QUEUE -> " .. name .. " is online, running SendPersona().")
					NickTag:SendPersona (name)
				else
					NickTag:Msg ("QUEUE -> " .. name .. " is offline, cant request his persona.")
				end
				
				if (#queue_send == 0 and #queue_request == 0) then
					NickTag:StopRosterUpdates()
				end
				
			elseif (#queue_request > 0) then

				local name = queue_request [1]
				table.remove (queue_request, 1)
				
				NickTag:Msg ("QUEUE -> ready to request the persona of " .. name)
				
				--> check if the player is online
				if (NickTag:IsOnline (name)) then
					NickTag:Msg ("QUEUE -> " .. name .. " is online, running RequestPersona().")
					NickTag:RequestPersona (name)
				else
					NickTag:Msg ("QUEUE -> " .. name .. " is offline, cant request his persona.")
				end
				
				if (#queue_request == 0 and #queue_request == 0) then
					NickTag:StopRosterUpdates()
				end
				
			else
				NickTag:StopRosterUpdates()
			end
		end
	end)
	
	function NickTag:StopRosterUpdates()
		NickTag:Msg ("ROSTER -> updates has been stopped")
		if (NickTag.UpdateRosterTimer) then
			NickTag:CancelTimer (NickTag.UpdateRosterTimer)
		end
		NickTag.UpdateRosterTimer = nil
		event_frame:UnregisterEvent ("GUILD_ROSTER_UPDATE")
		is_updating = false
	end
	
	function NickTag:StartRosterUpdates()
		NickTag:Msg ("ROSTER -> updates has been actived")
		event_frame:RegisterEvent ("GUILD_ROSTER_UPDATE")
		if (not NickTag.UpdateRosterTimer) then
			NickTag.UpdateRosterTimer = NickTag:ScheduleRepeatingTimer ("UpdateRoster", 12)
			NickTag:Msg ("ROSTER -> new update thread created.")
		else
			NickTag:Msg ("ROSTER -> a update thread already exists.")
		end
		is_updating = true
	end
	
	--> we queue data for roster update and also check for combat
	function NickTag:QueueRequest (name)
		table.insert (queue_request, name)
		if (not is_updating) then
			NickTag:StartRosterUpdates()
		end
	end
	function NickTag:QueueSend (name)
		table.insert (queue_send, name)
		if (not is_updating) then
			NickTag:StartRosterUpdates()
		end
	end

	--> after logon, we send our revision, who needs update my persona will send 0x3 (request persona) to me and i send back 0x1 (send persona)
	function NickTag:SendRevision()
		local playerName = UnitName ("player")
		local myPersona = NickTag:GetNicknameTable (playerName)
		if (myPersona) then
			NickTag:Msg ("SendRevision() -> SENT")
			if (IsInGuild()) then
				NickTag:SendCommMessage ("NickTag", NickTag:Serialize (CONST_COMM_LOGONREVISION, 0, myPersona [CONST_INDEX_REVISION], UnitName ("player"), GetRealmName(), minor), "GUILD")
			end
		end
	end
	
	--> i received 0x2 and his persona is out of date here, so i need to send 0x3 to him and him will send 0x1.
	function NickTag:RequestPersona (target)
		NickTag:Msg ("RequestPersona() -> requesting of " .. target)
		if (IsInGuild()) then
			NickTag:SendCommMessage ("NickTag", NickTag:Serialize (CONST_COMM_REQUESTPERSONA, 0, 0, UnitName ("player"), GetRealmName(), minor), "WHISPER", target)
		end
	end

	--> this broadcast my persona to entire guild when i update my persona or send my persona to someone who doesn't have it or need to update.
	function NickTag:SendPersona (target)
		if (target) then
			NickTag:Msg ("SendPersona() -> sent to " .. target)
		else
			NickTag:Msg ("SendPersona() -> broadcast")
		end
		
		--> auto change nickname if we have a invalid nickname
		if (NickTag:GetNickname (UnitName ("player")) == LibStub ("AceLocale-3.0"):GetLocale ("NickTag-1.0")["STRING_INVALID_NAME"]) then
			local nickTable = NickTag:GetNicknameTable (UnitName ("player"))
			if (nickTable) then
				nickTable [CONST_INDEX_NICKNAME] = UnitName ("player")
			end
		end
		
		if (target) then
			--> was requested
			if (IsInGuild()) then
				NickTag:SendCommMessage ("NickTag", NickTag:Serialize (CONST_COMM_FULLPERSONA, 0, NickTag:GetNicknameTable (UnitName ("player")), minor), "WHISPER", target)
			end
		else
			--> updating my own persona
			NickTag.send_scheduled = false
			--> broadcast only happen when something has changed on the local player persona, it needs to increase the revision before sending
			NickTag:IncRevision()
			--> broadcast over guild channel
			if (IsInGuild()) then
				NickTag:SendCommMessage ("NickTag", NickTag:Serialize (CONST_COMM_FULLPERSONA, 0, NickTag:GetNicknameTable (UnitName ("player")), minor), "GUILD")
			end
		end
	end

------------------------------------------------------------------------------------------------------------------------------------------------------
--> on logon stuff
	
	--> reset cache
	function NickTag:ResetCache()
	
		local playerName = UnitName ("player")
		
		if (playerName) then
			local player = NickTag:GetNicknameTable (playerName)
			if (player and pool.last_version == minor) then
				for thisPlayerName, _ in pairs (pool) do
					if (thisPlayerName ~= playerName) then
						pool [thisPlayerName] = nil
					end
				end
				--vardump (pool)
			else
				table.wipe (pool)
			end
			
			pool.nextreset = time() + (60*60*24*15) --> 15 days or 1296000 seconds
			pool.last_version = minor
		else
			--> sometimes player guid isn't available right after logon, so, just schedule until it become available.
			NickTag:ScheduleTimer ("ResetCache", 0.3)
		end
	end
	
	function NickTag:NickTagSetCache (_table)
		if (not pool.default) then
			return table.wipe (_table)
		end
		
		pool = _table
		
		if (not pool.nextreset) then
			pool.nextreset = time() + (60*60*24*15)
		end
		if (not pool.last_version) then
			pool.last_version = minor
		end
		if (pool.last_version < minor) then
			pool.nextreset = 1
		end
		if (time() > pool.nextreset) then
			NickTag:ResetCache()
		end
		
		NickTag:ScheduleTimer ("SendRevision", 30)
	end

------------------------------------------------------------------------------------------------------------------------------------------------------
--> basic functions

	--> trim from from http://lua-users.org/wiki/StringTrim
	function trim (s)
		local from = s:match"^%s*()"
		return from > #s and "" or s:match(".*%S", from)
	end
	--
	local titlecase = function (first, rest)
		return first:upper()..rest:lower()
	end
	--
	local have_repeated = false
	local count_spaces = 0
	local check_repeated = function (char) 
		if (char == "  ") then
			have_repeated = true
		elseif (string.len (char) > 2) then
			have_repeated = true
		elseif (char == " ") then
			count_spaces = count_spaces + 1
		end
	end
	
	--> we need to keep game smooth checking and formating nicknames.
	--> SetNickname and names comming from other player need to be check.
	function NickTag:CheckName (name)
		
		--> as nicktag only work internally in the guild, we think that is not necessary a work filter to avoid people using bad language.
		
		if (type (name) ~= "string") then
			return false, LibStub ("AceLocale-3.0"):GetLocale ("NickTag-1.0")["STRING_ERROR_4"] --> error 4 = name isn't a valid string
		end
		
		name = trim (name)
		
		--> limit nickname to 12 characters, same as wow.
		local len = string.len (name)
		if (len > 12) then
			return false, LibStub ("AceLocale-3.0"):GetLocale ("NickTag-1.0")["STRING_ERROR_1"] --> error 1 = nickname is too long, max of 12 characters.
		end
		
		--> check if contain any non allowed characters, by now only accpet letters, numbers and spaces.
		--> by default wow do not accetp spaces, but here will allow.
		--> tested over lua 5.2 and this capture was okey with accents, not sure why inside wow this doesn't work.
		local notallow = string.find (name, "[^a-zA-Z�������%s]")
		if (notallow) then
			return false, LibStub ("AceLocale-3.0"):GetLocale ("NickTag-1.0")["STRING_ERROR_2"] --> error 2 = nickname only support letters, numbers and spaces.
		end
		
		--> check if there is sequencial repeated characters, like "Jasooon" were repeats 3 times the "o" character.
		--> got this from http://stackoverflow.com/questions/15608299/lua-pattern-matching-repeating-character
		have_repeated = false
		count_spaces = 0
		string.gsub (name, '.', '\0%0%0'):gsub ('(.)%z%1','%1'):gsub ('%z.([^%z]+)', check_repeated)
		if (count_spaces > 2) then
			have_repeated = true
		end
		if (have_repeated) then
			return false, LibStub ("AceLocale-3.0"):GetLocale ("NickTag-1.0")["STRING_ERROR_3"] --> error 3 = cant use the same letter three times consecutively, 2 spaces consecutively or 3 or more spaces.
		end
		
		return true
	end

	--> set the "player" nickname and schedule for send updated persona
	function NickTag:SetNickname (name)
	
		--> check data before
		assert (type (name) == "string", "NickTag 'SetNickname' expects a string on #1 argument.")
		
		--> check if the nickname is okey to allowed to use.
		local okey, errortype = NickTag:CheckName (name)
		if (not okey) then
			NickTag:Msg ("SetNickname() invalid name ", name)
			return false, errortype
		end
		
		--> here we format the text to match titles, e.g converts name like "JASON NICKSHOW" into "Jason Nickshow". 
		name = name:gsub ("(%a)([%w_']*)", titlecase)
		
		local playerName = UnitName ("player")
		
		--> get the full nick table.
		local nickTable = NickTag:GetNicknameTable (playerName)
		if (not nickTable) then
			nickTable = NickTag:Create (playerName, true)
		end
		
		--> change the nickname for the player nick table.
		if (nickTable [CONST_INDEX_NICKNAME] ~= name) then
			nickTable [CONST_INDEX_NICKNAME] = name
			
			--> send the update for script which need it.
			NickTag.callbacks:Fire ("NickTag_Update", CONST_INDEX_NICKNAME)
			
			--> schedule a update for revision and broadcast full persona.
			--> this is a kind of protection for scripts which call SetNickname, SetColor and SetAvatar one after other, so scheduling here avoid three revisions upgrades and 3 broadcasts to the guild.			
			if (not NickTag.send_scheduled) then
				NickTag.send_scheduled = true
				NickTag:ScheduleTimer ("SendPersona", 1)
			end
			
		else
			NickTag:Msg ("SetNickname() name is the same on the pool ", name, nickTable [CONST_INDEX_NICKNAME])
		end
		
		return true
	end
	
	function NickTag:SetNicknameAvatar (texture, l, r, t, b)

		if (l == nil) then
			l, r, t, b = 0, 1, 0, 1
		elseif (type (l) == "table") then
			l, r, t, b = unpack (l)
		end
		
		--> check data before
		assert (texture and l and r and t and b, "NickTag 'SetNicknameAvatar' bad format. Usage NickTag:SetAvatar (texturepath [, L, R, T, B] or texturepath [, {L, R, T, B}])")
		
		local playerName = UnitName ("player")
		
		local nickTable = NickTag:GetNicknameTable (playerName)
		if (not nickTable) then
			nickTable = NickTag:Create (playerName, true)
		end
		
		if (nickTable [CONST_INDEX_AVATAR_PATH] ~= texture) then
			nickTable [CONST_INDEX_AVATAR_PATH] = texture
			
			--> by default, CONST_INDEX_AVATAR_TEXCOORD comes as boolean false
			if (type (nickTable [CONST_INDEX_AVATAR_TEXCOORD]) == "boolean") then
				nickTable [CONST_INDEX_AVATAR_TEXCOORD] = {}
			end
			
			nickTable [CONST_INDEX_AVATAR_TEXCOORD][1] = l
			nickTable [CONST_INDEX_AVATAR_TEXCOORD][2] = r
			nickTable [CONST_INDEX_AVATAR_TEXCOORD][3] = t
			nickTable [CONST_INDEX_AVATAR_TEXCOORD][4] = b
			
			NickTag.callbacks:Fire ("NickTag_Update", CONST_INDEX_AVATAR_PATH)
			
			if (not NickTag.send_scheduled) then
				NickTag.send_scheduled = true
				NickTag:ScheduleTimer ("SendPersona", 1)
			end
		end

		return true
	end
	
	--> set the background
	function NickTag:SetNicknameBackground (path, texcoord, color, silent)
	
		if (not silent) then
			assert (type (path) == "string", "NickTag 'SetNicknameBackground' expects a string on #1 argument.")
		else
			if (type (path) ~= "string") then
				return
			end
		end
	
		if (not texcoord) then
			texcoord = {0, 1, 0, 1}
		end
		
		if (not color) then
			color = {1, 1, 1}
		end
	
		local playerName = UnitName ("player")
		
		local nickTable = NickTag:GetNicknameTable (playerName)
		if (not nickTable) then
			nickTable = NickTag:Create (playerName, true)
		end
	
		local need_sync = false
		if (nickTable [CONST_INDEX_BACKGROUND_PATH] ~= path) then
			nickTable [CONST_INDEX_BACKGROUND_PATH] = path
			need_sync = true
		end
		
		if (nickTable [CONST_INDEX_BACKGROUND_TEXCOORD] ~= texcoord) then
			nickTable [CONST_INDEX_BACKGROUND_TEXCOORD] = texcoord
			need_sync = true
		end
		
		if (nickTable [CONST_INDEX_BACKGROUND_COLOR] ~= color) then
			nickTable [CONST_INDEX_BACKGROUND_COLOR] = color
			need_sync = true
		end
		
		if (need_sync) then
			NickTag.callbacks:Fire ("NickTag_Update", CONST_INDEX_BACKGROUND_PATH)
			
			if (not NickTag.send_scheduled) then
				NickTag.send_scheduled = true
				NickTag:ScheduleTimer ("SendPersona", 1)
			end
		end
		
		return true
	end	

	function NickTag:GetNickname (playerName, default, silent)
		if (not silent) then
			assert (type (playerName) == "string", "NickTag 'GetNickname' expects a string or string on #1 argument.")
		end
		
		local _table = pool [playerName]
		if (not _table) then
			return default or nil
		end
		return _table [CONST_INDEX_NICKNAME] or default or nil
	end
	
	--> return the avatar and the texcoord.
	function NickTag:GetNicknameAvatar (playerName, default, silent)
		if (not silent) then
			assert (type (playerName) == "string", "NickTag 'GetNicknameAvatar' expects a string or string on #1 argument.")
		end
		
		local _table = pool [playerName]
		
		if (not _table and default) then
			return default, {0, 1, 0, 1}
		elseif (not _table) then
			return "", {0, 1, 0, 1}
		end
		return _table [CONST_INDEX_AVATAR_PATH] or default or "", _table [CONST_INDEX_AVATAR_TEXCOORD] or {0, 1, 0, 1}
	end

	function NickTag:GetNicknameBackground (playerName, default_path, default_texcoord, default_color, silent)
		if (not silent) then
			assert (type (playerName) == "string", "NickTag 'GetNicknameBackground' expects a string or string on #1 argument.")
		end
		
		local _table = pool [playerName]
		if (not _table) then
			return default_path, default_texcoord, default_color
		end
		return _table [CONST_INDEX_BACKGROUND_PATH] or default_path, _table [CONST_INDEX_BACKGROUND_TEXCOORD] or default_texcoord, _table [CONST_INDEX_BACKGROUND_COLOR] or default_color
	end
	
	--> get the full nicktag table 
	function NickTag:GetNicknameTable (playerName, silent)
		--> check data before
		if (not silent) then
			assert (type (playerName) == "string", "NickTag 'GetNicknameTable' expects a string on #1 argument.")
		else
			if (not playerName or type (playerName) ~= "string") then
				return
			end
		end
		
		return pool [playerName]
	end

------------------------------------------------------------------------------------------------------------------------------------------------------
--> internal functions
	
	--> create a empty nick table for the player
	function NickTag:Create (playerName, isSelf)
		--> check data before
		assert (type (playerName) == "string", "NickTag 'Create' expects a string on #1 argument.")
		
		--> check if alredy exists
		local alredyHave = pool [playerName]
		if (alredyHave) then
			return alredyHave
		end
		
		--> create the table: 
		local newTable = { 
			UnitName ("player"), --[1] player nickname
			false, --[2] avatar texture path
			false, --[3] avatar texture coord
			false, --[4] background texture path
			false, --[5] background texcoord
			false, --[6] background color
			1 --[7] revision
		}
		
		--> if not my persona, set revision to 0, this make always get update after creation
		if (not isSelf) then
			newTable [CONST_INDEX_REVISION] = 0
		end
		
		pool [playerName] = newTable
		return newTable
	end

	--> inc the revision of the player persona after update nick or avatar
	function NickTag:IncRevision()
		local playerName = UnitName ("player")
		local nickTable = NickTag:GetNicknameTable (playerName)
		if (not nickTable) then
			nickTable = NickTag:Create (playerName, true)
		end
		
		nickTable [CONST_INDEX_REVISION] = nickTable [CONST_INDEX_REVISION] + 1
		
		return true
	end

	--> convert GUID into serial number (deprecated, it uses player name - realm name)
	function NickTag:GetSerial (serial, silent)
		return 0
	end
	
	--> choose avatar window
do
	local avatar_pick_frame = CreateFrame ("frame", "AvatarPickFrame", UIParent)
	avatar_pick_frame:SetFrameStrata ("DIALOG")
	avatar_pick_frame:SetBackdrop ({bgFile = [[Interface\FrameGeneral\UI-Background-Marble]], edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]], tile = true, tileSize = 256, edgeSize = 32,	insets = {left = 11, right = 12, top = 12, bottom = 11}})
	avatar_pick_frame:SetBackdropColor (.3, .3, .3, .9)
	avatar_pick_frame:SetWidth (460)
	avatar_pick_frame:SetHeight (240)
	
	avatar_pick_frame.selected_avatar = 1
	avatar_pick_frame.selected_background = 1
	avatar_pick_frame.selected_color = {1, 1, 1}
	avatar_pick_frame.selected_texcoord = {0, 1, 0, 1}
	
	avatar_pick_frame:SetPoint ("center", UIParent, "center", 200, 0)
	---
		local avatar_texture = avatar_pick_frame:CreateTexture ("AvatarPickFrameAvatarPreview", "overlay")
		avatar_texture:SetPoint ("topleft", avatar_pick_frame, "topleft", 167, -10)
		avatar_texture:SetTexture ([[Interface\EncounterJournal\UI-EJ-BOSS-Default]])
		--
		local background_texture = avatar_pick_frame:CreateTexture ("AvatarPickFrameBackgroundPreview", "artwork")
		background_texture:SetPoint ("topleft", avatar_pick_frame, "topleft", 167, 2)
		background_texture:SetWidth (290)
		background_texture:SetHeight (75)
		background_texture:SetTexture (NickTag.background_pool[1][1])
		background_texture:SetTexCoord (unpack (NickTag.background_pool[1][3]))
		--
		local name = avatar_pick_frame:CreateFontString ("AvatarPickFrameName", "overlay", "GameFontHighlightHuge")
		name:SetPoint ("left", avatar_texture, "right", -11, -17)
		name:SetText (UnitName ("player"))
	---

	local OnClickFunction = function (button) 
		if (button.isAvatar) then
			local avatar = NickTag.avatar_pool [button.IconID]
			_G.AvatarPickFrameAvatarPreview:SetTexture ( avatar [1] )
			avatar_pick_frame.selected_avatar = avatar [1]
		elseif (button.isBackground) then
			local background = NickTag.background_pool [button.IconID]
			_G.AvatarPickFrameBackgroundPreview:SetTexture ( background [1] )
			_G.AvatarPickFrameBackgroundPreview:SetTexCoord (unpack (background [3]))
			avatar_pick_frame.selected_background = background [1]
			avatar_pick_frame.selected_texcoord = background [3]
		end
	end
	
	local selectedColor = function()
		local r, g, b = ColorPickerFrame:GetColorRGB()
		background_texture:SetVertexColor (r, g, b)
		avatar_pick_frame.selected_color[1] = r
		avatar_pick_frame.selected_color[2] = g
		avatar_pick_frame.selected_color[3] = b
	end
	
	local okey = CreateFrame ("button", "AvatarPickFrameAccept", avatar_pick_frame, "OptionsButtonTemplate")
	okey:SetPoint ("bottomright", avatar_pick_frame, "bottomright", -37, 12)
	okey:SetText ("Accept")
	okey:SetFrameLevel (avatar_pick_frame:GetFrameLevel()+2)
	okey:SetScript ("OnClick", function (self) 
		avatar_pick_frame:Hide()
		if (avatar_pick_frame.callback) then
			avatar_pick_frame.callback (avatar_pick_frame.selected_avatar, {0, 1, 0, 1}, avatar_pick_frame.selected_background, avatar_pick_frame.selected_texcoord, avatar_pick_frame.selected_color)
		end
	end)
	local change_color = CreateFrame ("button", "AvatarPickFrameColor", avatar_pick_frame, "OptionsButtonTemplate")
	change_color:SetPoint ("bottomright", avatar_pick_frame, "bottomright", -205, 12)
	change_color:SetText ("Color")
	change_color:SetFrameLevel (avatar_pick_frame:GetFrameLevel()+2)
	
	change_color:SetScript ("OnClick", function (self) 
		ColorPickerFrame.func = selectedColor
		ColorPickerFrame.hasOpacity = false
		ColorPickerFrame:SetParent (avatar_pick_frame)
		ColorPickerFrame:SetColorRGB (_G.AvatarPickFrameBackgroundPreview:GetVertexColor())
		ColorPickerFrame:ClearAllPoints()
		ColorPickerFrame:SetPoint ("left", avatar_pick_frame, "right", 0, -10)
		ColorPickerFrame:Show()
	end)
	
	local buttons = {}
	for i = 0, 2 do 
		local newbutton = CreateFrame ("button", "AvatarPickFrameAvatarScrollButton"..i+1, avatar_pick_frame)
		newbutton:SetScript ("OnClick", OnClickFunction)
		newbutton:SetWidth (128)
		newbutton:SetHeight (64)
		newbutton:SetPoint ("topleft", avatar_pick_frame, "topleft", 15, (i*70*-1) - 20)
		newbutton:SetID (i+1)
		newbutton.isAvatar = true
		buttons [#buttons+1] = newbutton
	end
	
	local buttonsbg = {}
	for i = 0, 2 do 
		local newbutton = CreateFrame ("button", "AvatarPickFrameBackgroundScrollButton"..i+1, avatar_pick_frame)
		newbutton:SetScript ("OnClick", OnClickFunction)
		newbutton:SetWidth (275)
		newbutton:SetHeight (60)
		newbutton:SetPoint ("topleft", avatar_pick_frame, "topleft", 157, (i*50*-1) - 80)
		newbutton:SetID (i+1)
		newbutton.isBackground = true
		buttonsbg [#buttonsbg+1] = newbutton
	end
	
	local avatar_list = CreateFrame ("ScrollFrame", "AvatarPickFrameAvatarScroll", avatar_pick_frame, "ListScrollFrameTemplate")
	avatar_list:SetPoint ("topleft", avatar_pick_frame, "topleft", 10, -10)
	local background_list = CreateFrame ("ScrollFrame", "AvatarPickFrameBackgroundScroll", avatar_pick_frame, "ListScrollFrameTemplate")
	background_list:SetPoint ("topleft", avatar_pick_frame, "topleft", 147, -85)

	avatar_list:SetWidth (128)
	avatar_list:SetHeight (220)
	background_list:SetWidth (275)
	background_list:SetHeight (140)

	local avatar_scroll_update = function (self)
		local numMacroIcons = #NickTag.avatar_pool
		local macroPopupIcon, macroPopupButton, index, texture
		local macroPopupOffset = FauxScrollFrame_GetOffset (avatar_list)
		
		for i = 1, 3 do
			macroPopupIcon = _G ["AvatarPickFrameAvatarScrollButton"..i]
			macroPopupButton = _G ["AvatarPickFrameAvatarScrollButton"..i]
			index = (macroPopupOffset * 1) + i

			texture = NickTag.avatar_pool [index][1]
			if ( index <= numMacroIcons and texture ) then
				macroPopupButton:SetNormalTexture (texture)
				macroPopupButton:SetPushedTexture (texture)
				macroPopupButton:SetDisabledTexture (texture)
				macroPopupButton:SetHighlightTexture (texture, "ADD")
				macroPopupButton.IconID = index
				macroPopupButton:Show()
			else
				macroPopupButton:Hide()
			end
		end
		FauxScrollFrame_Update (avatar_list, numMacroIcons , 3, 64)
	end
	local background_scroll_update = function (self)
		local numMacroIcons = #NickTag.background_pool
		local macroPopupIcon, macroPopupButton, index, texture
		local macroPopupOffset = FauxScrollFrame_GetOffset (background_list)
		
		for i = 1, 3 do
			macroPopupIcon = _G ["AvatarPickFrameBackgroundScrollButton"..i]
			macroPopupButton = _G ["AvatarPickFrameBackgroundScrollButton"..i]
			index = (macroPopupOffset * 1) + i

			texture = NickTag.background_pool [index][1]
			if ( index <= numMacroIcons and texture ) then
				macroPopupButton:SetNormalTexture (texture)
				macroPopupButton:SetPushedTexture (texture)
				macroPopupButton:SetDisabledTexture (texture)
				macroPopupButton:SetHighlightTexture (texture, "ADD")
				macroPopupButton.IconID = index
				macroPopupButton:Show()
			else
				macroPopupButton:Hide()
			end
		end
		FauxScrollFrame_Update (background_list, numMacroIcons , 3, 40)
	end
	
	avatar_list:SetScript ("OnVerticalScroll", function (self, offset) 
		FauxScrollFrame_OnVerticalScroll (avatar_list, offset, 64, avatar_scroll_update) 
	end)
	background_list:SetScript ("OnVerticalScroll", function (self, offset) 
		FauxScrollFrame_OnVerticalScroll (background_list, offset, 40, background_scroll_update) 
	end)
	
	avatar_scroll_update (avatar_list)
	background_scroll_update (background_list)
	
	function avatar_pick_frame:SetAvatar (n)
		if (type (n) ~= "number") then
			n = 1
		end
		if (n > #NickTag.avatar_pool) then
			n = 1
		end
		local avatar = NickTag.avatar_pool [n]
		_G.AvatarPickFrameAvatarPreview:SetTexture ( avatar [1] )
		avatar_pick_frame.selected_avatar = avatar [1]
	end
	function avatar_pick_frame:SetBackground (n)
		if (type (n) ~= "number") then
			n = 1
		end
		if (n > #NickTag.background_pool) then
			n = 1
		end
		local background = NickTag.background_pool [n]
		_G.AvatarPickFrameBackgroundPreview:SetTexture ( background [1] )
		_G.AvatarPickFrameBackgroundPreview:SetTexCoord (unpack (background [3]))
		_G.AvatarPickFrameBackgroundPreview:SetVertexColor (unpack (avatar_pick_frame.selected_color))
		avatar_pick_frame.selected_background = background [1]
	end
	function avatar_pick_frame:SetColor (r, g, b)
		if (type (r) ~= "number" or r > 1) then
			r = 1
		end
		if (type (g) ~= "number" or g > 1) then
			g = 1
		end
		if (type (b) ~= "number" or b > 1) then
			b = 1
		end
		_G.AvatarPickFrameBackgroundPreview:SetVertexColor (r, g, b)
		avatar_pick_frame.selected_color[1] = r
		avatar_pick_frame.selected_color[2] = g
		avatar_pick_frame.selected_color[3] = b
	end
	
	local CONST_INDEX_NICKNAME = 1
	local CONST_INDEX_AVATAR_PATH = 2
	local CONST_INDEX_AVATAR_TEXCOORD = 3
	local CONST_INDEX_BACKGROUND_PATH = 4
	local CONST_INDEX_BACKGROUND_TEXCOORD = 5
	local CONST_INDEX_BACKGROUND_COLOR = 6	
	
	avatar_pick_frame:SetScript ("OnShow", function()
		--get player avatar
		local avatar = NickTag:GetNicknameTable (UnitGUID ("player"))
		if (avatar) then
			_G.AvatarPickFrameName:SetText ( avatar [1] or UnitName ("player"))
			
			_G.AvatarPickFrameAvatarPreview:SetTexture ( avatar [CONST_INDEX_AVATAR_PATH] or [[Interface\EncounterJournal\UI-EJ-BOSS-Default]] )
			avatar_pick_frame.selected_avatar = avatar [CONST_INDEX_AVATAR_PATH] or [[Interface\EncounterJournal\UI-EJ-BOSS-Default]]
			
			_G.AvatarPickFrameAvatarPreview:SetTexCoord ( 0, 1, 0, 1 ) --> always
			
			_G.AvatarPickFrameBackgroundPreview:SetTexture ( avatar [CONST_INDEX_BACKGROUND_PATH] or [[Interface\PetBattles\Weather-ArcaneStorm]] )
			avatar_pick_frame.selected_background = avatar [CONST_INDEX_BACKGROUND_PATH] or [[Interface\PetBattles\Weather-ArcaneStorm]]
			
			if (avatar [CONST_INDEX_BACKGROUND_TEXCOORD]) then
				_G.AvatarPickFrameBackgroundPreview:SetTexCoord ( unpack (avatar [CONST_INDEX_BACKGROUND_TEXCOORD]) )
				avatar_pick_frame.selected_texcoord = avatar [CONST_INDEX_BACKGROUND_TEXCOORD]
			else
				_G.AvatarPickFrameBackgroundPreview:SetTexCoord ( 0.129609375, 1, 1, 0 )
				avatar_pick_frame.selected_texcoord = {0.129609375, 1, 1, 0}
			end
			
			if (avatar [CONST_INDEX_BACKGROUND_COLOR]) then
				_G.AvatarPickFrameBackgroundPreview:SetVertexColor ( unpack (avatar [CONST_INDEX_BACKGROUND_COLOR]) )
				avatar_pick_frame.selected_color = avatar [CONST_INDEX_BACKGROUND_COLOR]
			else
				_G.AvatarPickFrameBackgroundPreview:SetVertexColor ( 1, 1, 1 )
				avatar_pick_frame.selected_color = {1, 1, 1}
			end
		else
			--> if none
			_G.AvatarPickFrameAvatarPreview:SetTexture ( [[Interface\EncounterJournal\UI-EJ-BOSS-Default]] )
			avatar_pick_frame.selected_avatar = [[Interface\EncounterJournal\UI-EJ-BOSS-Default]]
			
			local background = NickTag.background_pool [1]
			
			if (background) then
				_G.AvatarPickFrameBackgroundPreview:SetTexture ( background [1] )
				avatar_pick_frame.selected_background = background [1]
				_G.AvatarPickFrameBackgroundPreview:SetTexCoord (unpack (background [3]))
				avatar_pick_frame.selected_texcoord = background [3]
				_G.AvatarPickFrameBackgroundPreview:SetVertexColor (unpack (avatar_pick_frame.selected_color))
				avatar_pick_frame.selected_color = avatar_pick_frame.selected_color
			end
			
		end
	end)
	
	avatar_pick_frame:Hide()
end
