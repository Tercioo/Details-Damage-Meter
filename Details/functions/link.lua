--[[ Link actor with his twin shadow ]]

do 
	local _detalhes = _G._detalhes

	local _rawget = rawget
	local _setmetatable =	setmetatable

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

	--> create the link
	function _detalhes:CriaLink (link)
		--> se tiver a tabela no overall
		if (link) then 
			link:FazLinkagem (self)
		end
	end
end