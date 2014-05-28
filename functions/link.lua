--[[ Link actor with his twin shadow ]]

do 
	local _detalhes = _G._detalhes

	local _rawget = rawget
	local _setmetatable =	setmetatable
	local _ipairs = ipairs
	
	--> default weaktable
	_detalhes.weaktable = {__mode = "v"}

	--> create link between two tables
	function _detalhes:FazLinkagem (objeto)
		local meus_links = _rawget (self, "links")
		if (not meus_links) then
			meus_links = _setmetatable ({}, _detalhes.weaktable)
			self.links = meus_links
		end
		meus_links [#meus_links+1] = objeto
	end
	
	--> check if there is a link between tables
	function _detalhes:EstaoLinkados (objeto)
		local meus_links = _rawget (self, "links")
		if (not meus_links) then
			return false
		end
		for index, actor in _ipairs (meus_links) do
			if (actor == objeto) then
				return true
			end
		end
		
		return false
	end

	--> create the link
	function _detalhes:CriaLink (link)
		--> se tiver a tabela no overall
		--if (link) then 
		--	link:FazLinkagem (self)
		--end
	end
end