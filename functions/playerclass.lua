--[[ detect actor class ]]

do 

	local _detalhes	= 	_G._detalhes
	local _
	local _pairs = pairs
	local _ipairs = ipairs
	local _UnitClass = UnitClass
	local _select = select
	local _unpack = unpack

	-- try get the class from actor name
	function _detalhes:GetClass (name)
		local _, class = _UnitClass (name)
		
		if (not class) then
			for _, container in _ipairs (_detalhes.tabela_overall) do
				local index = container._NameIndexTable [name]
				if (index) then
					local actor = container._ActorTable [index]
					if (actor.classe ~= "UNGROUPPLAYER") then
						return actor.classe, _detalhes:unpacks (_detalhes.class_coords [actor.classe] or {0.75, 1, 0.75, 1}, _detalhes.class_colors [actor.classe])
					end
				end
			end
		else
			return class, _detalhes:unpacks (_detalhes.class_coords [class] or {0.75, 1, 0.75, 1}, _detalhes.class_colors [class])
		end
	end
	
	local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
	function _detalhes:GetClassIcon (class)
	
		local c
	
		if (self.classe) then
			c = self.classe
		elseif (type (class) == "table" and class.classe) then
			c = class.classe
		elseif (type (class) == "string") then
			c = class
		else
			c = "UNKNOW"
		end
		
		if (c == "UNKNOW") then
			return [[Interface\LFGFRAME\LFGROLE_BW]], 0.25, 0.5, 0, 1
		elseif (c == "UNGROUPPLAYER") then
			return [[Interface\ICONS\Achievement_Character_Orc_Male]], 0, 1, 0, 1
		elseif (c == "PET") then
			return [[Interface\AddOns\Details\images\classes_small]], 0.25, 0.49609375, 0.75, 1
		else
			return [[Interface\AddOns\Details\images\classes_small]], _unpack (CLASS_ICON_TCOORDS [c])
		end
	end
	
	local default_color = {1, 1, 1, 1}
	function _detalhes:GetClassColor (class)
		if (self.classe) then
			return unpack (_detalhes.class_colors [self.classe] or default_color)
			
		elseif (type (class) == "table" and class.classe) then
			return unpack (_detalhes.class_colors [class.classe] or default_color)
		
		elseif (type (class) == "string") then
			return unpack (_detalhes.class_colors [class] or default_color)
			
		else
			unpack (default_color)
		end
	end
	
	function _detalhes:GuessClass (t)
	
		local Actor, container, tries = t[1], t[2], t[3]
		
		if (not Actor) then
			return false
		end
		
		if (Actor.spells) then --> correcao pros containers misc, precisa pegar os diferentes tipos de containers de  lá
			for spellid, _ in _pairs (Actor.spells._ActorTable) do 
				local class = _detalhes.ClassSpellList [spellid]
				if (class) then
					Actor.classe = class
					Actor.shadow.classe = class
					Actor.guessing_class = nil
					
					if (container) then
						container.need_refresh = true
						container.shadow.need_refresh = true
					end
					
					if (Actor.minha_barra) then
						Actor.minha_barra.minha_tabela = nil
					end
				
					return class
				end
			end
		end

		local class = _detalhes:GetClass (Actor.nome)
		if (class) then
			Actor.classe = class
			Actor.shadow.classe = class
			Actor.need_refresh = true
			Actor.shadow.need_refresh = true
			Actor.guessing_class = nil
			
			if (container) then
				container.need_refresh = true
				container.shadow.need_refresh = true
			end
			
			if (Actor.minha_barra) then
				Actor.minha_barra.minha_tabela = nil
			end
			
			return class
		end
		
		if (tries and tries < 10) then 
			_detalhes:ScheduleTimer ("GuessClass", 2, {Actor, container, tries+1})
		end
		
		return false
	end

end
