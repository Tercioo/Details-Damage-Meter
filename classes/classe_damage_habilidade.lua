--[[ classe do dano aplicado, usado nos eventos:
- SPELL_PERIODIC_DAMAGE
- SPELL_DAMAGE
- SWING_DAMAGE
- RANGE_DAMAGE

Parents: 
	addon -> combate atual -> Npc/Player Swicth -> Container de Habilidades -> esta tabela
 ]]

local _detalhes = 		_G._detalhes
local gump = 			_detalhes.gump

local alvo_da_habilidade = 	_detalhes.alvo_da_habilidade
local habilidade_dano = 	_detalhes.habilidade_dano
local container_combatentes =	_detalhes.container_combatentes
local container_damage_target = _detalhes.container_type.CONTAINER_DAMAGETARGET_CLASS

--lua locals
local _setmetatable = setmetatable
local _ipairs = ipairs
local _pairs =  pairs
local _
--api locals
local _UnitAura = UnitAura
--local _GetSpellInfo = _detalhes.getspellinfo

local container_playernpc = _detalhes.container_type.CONTAINER_PLAYERNPC

local _recording_ability_with_buffs = false

--id, nome, type, miss, dano, cura, overkill, school, resisted, blocked, absorbed, critico, glacing, crushing
function habilidade_dano:NovaTabela (id, link, token) --aqui eu não sei que parâmetros passar

	local _newDamageSpell = {
	
		total = 0, --total de dano aplicado por esta habilidade
		counter = 0, --conta quantas vezes a habilidade foi chamada
		id = id,
		successful_casted = 0,
		
		--> normal
		n_min = 0,
		n_max = 0,
		n_amt = 0,
		n_dmg = 0,
		
		--> criticos
		c_min = 0,
		c_max = 0,
		c_amt = 0,
		c_dmg = 0,

		--> glacing
		g_amt = 0,
		g_dmg = 0,
		
		--> resisted
		r_amt = 0,
		r_dmg = 0,
		
		--> blocked
		b_amt = 0,
		b_dmg = 0,

		--> obsorved
		a_amt = 0,
		a_dmg = 0,
		
		targets = container_combatentes:NovoContainer (container_damage_target)
	}
	
	_setmetatable (_newDamageSpell, habilidade_dano)
	
	if (link) then
		_newDamageSpell.targets.shadow = link.targets
	end
	
	if (token == "SPELL_PERIODIC_DAMAGE") then
		_detalhes:SpellIsDot (id)
	end
	
	return _newDamageSpell
end


function habilidade_dano:AddMiss (serial, nome, flags, who_nome, missType)
	self.counter = self.counter + 1

	local miss = self [missType] or 0
	miss = miss + 1
	self [missType] = miss
	
	local alvo = self.targets:PegarCombatente (serial, nome, flags, true)
	return alvo:AddQuantidade (0)
end

function habilidade_dano:AddFF (amount)
	self.counter = self.counter + 1
	self.total = self.total + amount
end

function habilidade_dano:Add (serial, nome, flag, amount, who_nome, resisted, blocked, absorbed, critical, glacing, token)

	self.counter = self.counter + 1
	
	local alvo = self.targets._NameIndexTable [nome]
	if (not alvo) then
		alvo = self.targets:PegarCombatente (serial, nome, flag, true)
	else
		alvo = self.targets._ActorTable [alvo]
	end

	if (resisted and resisted > 0) then
		self.r_dmg = self.r_dmg+amount --> tabela.total é o total de dano
		self.r_amt = self.r_amt+1 --> tabela.total é o total de dano
	end
	
	if (blocked and blocked > 0) then
		self.b_dmg = self.b_dmg+amount --> amount é o total de dano
		self.b_amt = self.b_amt+1 --> amount é o total de dano
	end
	
	if (absorbed and absorbed > 0) then
		self.a_dmg = self.a_dmg+amount --> amount é o total de dano
		self.a_amt = self.a_amt+1 --> amount é o total de dano
	end	
	
		self.total = self.total + amount
		alvo.total = alvo.total + amount

		if (glacing) then
			self.g_dmg = self.g_dmg+amount --> amount é o total de dano
			self.g_amt = self.g_amt+1 --> amount é o total de dano

		elseif (critical) then
			self.c_dmg = self.c_dmg+amount --> amount é o total de dano
			self.c_amt = self.c_amt+1 --> amount é o total de dano
			if (amount > self.c_max) then
				self.c_max = amount
			end
			if (self.c_min > amount or self.c_min == 0) then
				self.c_min = amount
			end
		else
			self.n_dmg = self.n_dmg+amount
			self.n_amt = self.n_amt+1
			if (amount > self.n_max) then
				self.n_max = amount
			end
			if (self.n_min > amount or self.n_min == 0) then
				self.n_min = amount
			end
		end
	--end
	
	if (_recording_ability_with_buffs) then
		if (who_nome == _detalhes.playername) then --aqui ele vai detalhar tudo sobre a magia usada
		
			local buffsNames = _detalhes.SoloTables.BuffsTableNameCache
			
			local SpellBuffDetails = self.BuffTable
			if (not SpellBuffDetails) then
				self.BuffTable = {}
				SpellBuffDetails = self.BuffTable
			end
			
			if (token == "SPELL_PERIODIC_DAMAGE") then
				--> precisa ver se ele tinha na hora que aplicou
				local SoloDebuffPower = _detalhes.tabela_vigente.SoloDebuffPower
				if (SoloDebuffPower) then
					local ThisDebuff = SoloDebuffPower [self.id]
					if (ThisDebuff) then
						local ThisDebuffOnTarget = ThisDebuff [serial]
						if (ThisDebuffOnTarget) then
							for index, buff_name in _ipairs (ThisDebuffOnTarget.buffs) do
								local buff_info = SpellBuffDetails [buff_name] or {["counter"] = 0, ["total"] = 0, ["critico"] = 0, ["critico_dano"] = 0}
								buff_info.counter = buff_info.counter+1
								buff_info.total = buff_info.total+amount
								if (critical ~= nil) then
									buff_info.critico = buff_info.critico+1
									buff_info.critico_dano = buff_info.critico_dano+amount
								end
								SpellBuffDetails [buff_name] = buff_info
							end
						end
					end
				end
				
			else

				for BuffName, _ in _pairs (_detalhes.Buffs.BuffsTable) do
					local name = _UnitAura ("player", BuffName)
					if (name ~= nil) then
						local buff_info = SpellBuffDetails [name] or {["counter"] = 0, ["total"] = 0, ["critico"] = 0, ["critico_dano"] = 0}
						buff_info.counter = buff_info.counter+1
						buff_info.total = buff_info.total+amount
						if (critical ~= nil) then
							buff_info.critico = buff_info.critico+1
							buff_info.critico_dano = buff_info.critico_dano+amount
						end
						SpellBuffDetails [name] = buff_info
					end
				end
			end
		end
	end

end

function _detalhes.refresh:r_habilidade_dano (habilidade, shadow) --recebeu o container shadow
	_setmetatable (habilidade, habilidade_dano)
	habilidade.__index = habilidade_dano
	habilidade.shadow = shadow._ActorTable [habilidade.id]
	_detalhes.refresh:r_container_combatentes (habilidade.targets, habilidade.shadow.targets)
end

function _detalhes.clear:c_habilidade_dano (habilidade)
	--habilidade.__index = {}
	habilidade.__index = nil
	habilidade.shadow = nil
	
	_detalhes.clear:c_container_combatentes (habilidade.targets)
end

habilidade_dano.__add = function (tabela1, tabela2)
	tabela1.total = tabela1.total + tabela2.total
	tabela1.counter = tabela1.counter + tabela2.counter
	tabela1.successful_casted = tabela1.successful_casted + tabela2.successful_casted
	
	tabela1.n_min = tabela1.n_min + tabela2.n_min
	tabela1.n_max = tabela1.n_max + tabela2.n_max
	tabela1.n_amt = tabela1.n_amt + tabela2.n_amt
	tabela1.n_dmg = tabela1.n_dmg + tabela2.n_dmg

	tabela1.c_min = tabela1.c_min + tabela2.c_min
	tabela1.c_max = tabela1.c_max + tabela2.c_max
	tabela1.c_amt = tabela1.c_amt + tabela2.c_amt
	tabela1.c_dmg = tabela1.c_dmg + tabela2.c_dmg
	
	--tabela1.g_min = tabela1.g_min + tabela2.g_min
	--tabela1.g_max = tabela1.g_max + tabela2.g_max
	tabela1.g_amt = tabela1.g_amt + tabela2.g_amt 
	tabela1.g_dmg = tabela1.g_dmg + tabela2.g_dmg
	
	--tabela1.r_min = tabela1.r_min + tabela2.r_min
	--tabela1.r_max = tabela1.r_max + tabela2.r_max
	tabela1.r_amt = tabela1.r_amt + tabela2.r_amt 
	tabela1.r_dmg = tabela1.r_dmg + tabela2.r_dmg
	
	--tabela1.b_min = tabela1.b_min + tabela2.b_min
	--tabela1.b_max = tabela1.b_max + tabela2.b_max
	tabela1.b_amt = tabela1.b_amt + tabela2.b_amt
	tabela1.b_dmg = tabela1.b_dmg + tabela2.b_dmg
	
	--tabela1.a_min = tabela1.a_min + tabela2.a_min 
	--tabela1.a_max = tabela1.a_max + tabela2.a_max 
	tabela1.a_amt = tabela1.a_amt + tabela2.a_amt 
	tabela1.a_dmg = tabela1.a_dmg + tabela2.a_dmg
	
	--tabela1.crushing = tabela1.crushing + tabela2.crushing 
	
	return tabela1
end

habilidade_dano.__sub = function (tabela1, tabela2)
	tabela1.total = tabela1.total - tabela2.total
	tabela1.counter = tabela1.counter - tabela2.counter
	tabela1.successful_casted = tabela1.successful_casted - tabela2.successful_casted

	tabela1.n_min = tabela1.n_min - tabela2.n_min
	tabela1.n_max = tabela1.n_max - tabela2.n_max
	tabela1.n_amt = tabela1.n_amt - tabela2.n_amt
	tabela1.n_dmg = tabela1.n_dmg - tabela2.n_dmg

	tabela1.c_min = tabela1.c_min - tabela2.c_min
	tabela1.c_max = tabela1.c_max - tabela2.c_max
	tabela1.c_amt = tabela1.c_amt - tabela2.c_amt
	tabela1.c_dmg = tabela1.c_dmg - tabela2.c_dmg
	
	--tabela1.g_min = tabela1.g_min - tabela2.g_min
	--tabela1.g_max = tabela1.g_max - tabela2.g_max
	tabela1.g_amt = tabela1.g_amt - tabela2.g_amt 
	tabela1.g_dmg = tabela1.g_dmg - tabela2.g_dmg
	
	--tabela1.r_min = tabela1.r_min - tabela2.r_min
	--tabela1.r_max = tabela1.r_max - tabela2.r_max
	tabela1.r_amt = tabela1.r_amt - tabela2.r_amt 
	tabela1.r_dmg = tabela1.r_dmg - tabela2.r_dmg
	
	--tabela1.b_min = tabela1.b_min - tabela2.b_min
	--tabela1.b_max = tabela1.b_max - tabela2.b_max
	tabela1.b_amt = tabela1.b_amt - tabela2.b_amt
	tabela1.b_dmg = tabela1.b_dmg - tabela2.b_dmg
	
	--tabela1.a_min = tabela1.a_min - tabela2.a_min 
	--tabela1.a_max = tabela1.a_max - tabela2.a_max 
	tabela1.a_amt = tabela1.a_amt - tabela2.a_amt 
	tabela1.a_dmg = tabela1.a_dmg - tabela2.a_dmg
	
	--tabela1.crushing = tabela1.crushing - tabela2.crushing 
	
	return tabela1
end

function _detalhes:UpdateDamageAbilityGears()
	_recording_ability_with_buffs = _detalhes.RecordPlayerAbilityWithBuffs
end
