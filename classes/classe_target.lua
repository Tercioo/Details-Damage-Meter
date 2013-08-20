
local _detalhes = 		_G._detalhes
--local AceLocale = LibStub ("AceLocale-3.0")
--local Loc = AceLocale:GetLocale ( "Details" )

local gump = 			_detalhes.gump

local alvo_da_habilidade = 	_detalhes.alvo_da_habilidade

--lua locals
local _setmetatable = setmetatable
--api locals

--esta tabela irá ser usada por todas os tipos? tipo dano, cura, interrupts?

function alvo_da_habilidade:NovaTabela (link)

	local esta_tabela = {total = 0}
	_setmetatable (esta_tabela, alvo_da_habilidade)
	
	return esta_tabela
end

function alvo_da_habilidade:AddQuantidade (amt)
	self.total = self.total + amt
	if (self.shadow) then
		return self.shadow:AddQuantidade (amt)
	end
end

function _detalhes.refresh:r_alvo_da_habilidade (este_alvo, shadow)
	--print (shadow)
	--print (este_alvo.shadow)
	_setmetatable (este_alvo, alvo_da_habilidade)
	este_alvo.__index = alvo_da_habilidade
	if (shadow ~= -1) then
		este_alvo.shadow = shadow._ActorTable [shadow._NameIndexTable[este_alvo.nome]]
	end
end

function _detalhes.clear:c_alvo_da_habilidade (este_alvo)
	este_alvo.shadow = nil
	este_alvo.__index = {}
end

alvo_da_habilidade.__sub = function (tabela1, tabela2)
	tabela1.total = tabela1.total - tabela2.total
	if (tabela1.overheal) then
		tabela1.overheal = tabela1.overheal - tabela2.overheal
		tabela1.absorbed = tabela1.absorbed - tabela2.absorbed
	end
end
