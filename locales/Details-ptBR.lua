local Loc = LibStub("AceLocale-3.0"):NewLocale("Details", "ptBR") 
if not Loc then return end 

--------------------------------------------------------------------------------------------------------------------------------------------

	Loc ["STRING_AUTO"] = "auto"
	Loc ["STRING_LEFT"] = "esquerda"
	Loc ["STRING_CENTER"] = "centro"
	Loc ["STRING_RIGHT"] = "direita"
	Loc ["STRING_TOOOLD"] = "nao pode ser instalado pois sua versao do Details! e muito antiga."

--> Slash
	Loc ["STRING_SLASH_NEW"] = "novo"

--> StatusBar Plugins
	Loc ["STRING_STATUSBAR_NOOPTIONS"] = "Nao ha opcoes para esta ferramenta."
	
--> Fights and Segments

	Loc ["STRING_SEGMENT"] = "Segmento"
	Loc ["STRING_TOTAL"] = "Total"
	Loc ["STRING_OVERALL"] = "Dados Gerais"
	Loc ["STRING_CURRENT"] = "Atual"
	Loc ["STRING_CURRENTFIGHT"] = "Luta Atual"
	Loc ["STRING_FIGHTNUMBER"] = "Luta #"
	Loc ["STRING_UNKNOW"] = "Desconhecido"
	Loc ["STRING_AGAINST"] = "contra"

--> Custom Window -- traduzir

	Loc ["STRING_CUSTOM_REMOVE"] = "Remove"
	Loc ["STRING_CUSTOM_BROADCAST"] = "Shout"
	Loc ["STRING_CUSTOM_NAME"] = "Custom Name"
	Loc ["STRING_CUSTOM_SPELLID"] = "Spell Id"
	Loc ["STRING_CUSTOM_SOURCE"] = "Source"
	Loc ["STRING_CUSTOM_TARGET"] = "Target"
	Loc ["STRING_CUSTOM_TOOLTIPNAME"] = "Insert here the name of your custom display.\nAllow letters and numbers, minimum of 5 characters and 32 max."
	Loc ["STRING_CUSTOM_TOOLTIPSPELL"] = "Select a boss ability from the menu on the right or type the spell name to filter."
	Loc ["STRING_CUSTOM_TOOLTIPSOURCE"] = "Spell source allow:\n|cFF00FF00[all]|r: Search for spell in all Actors.\n|cFFFF9900[raid]|r: Search only in your raid or party members.\n|cFF33CCFF[player]|r: Check only you\nAny other text will be considered an spesific Actor name."
	Loc ["STRING_CUSTOM_TOOLTIPTARGET"] = "Insert the ability (player, monster, boss) target name."
	Loc ["STRING_CUSTOM_TOOLTIPNOTWORKING"] = "Ouch, some gnome engineer touched this and broke it =("
	Loc ["STRING_CUSTOM_BROADCASTSENT"] = "Sent"
	Loc ["STRING_CUSTOM_CREATED"] = "The new display has been created."
	Loc ["STRING_CUSTOM_ICON"] = "Icon"
	Loc ["STRING_CUSTOM_CREATE"] = "Create"
	Loc ["STRING_CUSTOM_INCOMBAT"] = "You are in combat."
	Loc ["STRING_CUSTOM_NOATTRIBUTO"] = "No attribute has been selected."
	Loc ["STRING_CUSTOM_SHORTNAME"] = "Name need at least 5 characters."
	Loc ["STRING_CUSTOM_LONGNAME"] = "Name too long, maximum allowed 32 characters."
	Loc ["STRING_CUSTOM_NOSPELL"] = "Spell field cannot be empty."
	Loc ["STRING_CUSTOM_"] = ""

--> Switch Window

	Loc ["STRING_SWITCH_CLICKME"] = "clique-me"
	
--> Mode Names

	Loc ["STRING_MODE_SELF"] = "Sozinho"
	Loc ["STRING_MODE_GROUP"] = "Grupo"
	Loc ["STRING_MODE_ALL"] = "Tudo"
	Loc ["STRING_MODE_RAID"] = "Raid"	

-->
	
	Loc ["STRING_NEWROW"] = "esperando atualizar..."
	Loc ["STRING_WAITPLUGIN"] = "esperando por\nplugins"
	
--> Cooltip
	
	Loc ["STRING_COOLTIP_NOOPTIONS"] = "Nao ha opcoes"

--> Attributes	

	Loc ["STRING_ATTRIBUTE_DAMAGE"] = "Dano"
		Loc ["STRING_ATTRIBUTE_DAMAGE_DONE"] = "Dano Feito"
		Loc ["STRING_ATTRIBUTE_DAMAGE_DPS"] = "Dano por Segundo"
		Loc ["STRING_ATTRIBUTE_DAMAGE_TAKEN"] = "Dano Recebido"
		Loc ["STRING_ATTRIBUTE_DAMAGE_FRIENDLYFIRE"] = "Fogo Amigo"
		
	Loc ["STRING_ATTRIBUTE_HEAL"] = "Cura"
		Loc ["STRING_ATTRIBUTE_HEAL_DONE"] = "Cura Feita"
		Loc ["STRING_ATTRIBUTE_HEAL_HPS"] = "Cura Por Segundo"
		Loc ["STRING_ATTRIBUTE_HEAL_OVERHEAL"] = "Sobrecura"
		Loc ["STRING_ATTRIBUTE_HEAL_TAKEN"] = "Cura Recebida"
		
	Loc ["STRING_ATTRIBUTE_ENERGY"] = "Energia"
		Loc ["STRING_ATTRIBUTE_ENERGY_MANA"] = "Mana Restaurada"
		Loc ["STRING_ATTRIBUTE_ENERGY_RAGE"] = "e_rage Gerada"
		Loc ["STRING_ATTRIBUTE_ENERGY_ENERGY"] = "Energia Gerada"
		Loc ["STRING_ATTRIBUTE_ENERGY_RUNEPOWER"] = "Power Runico Gerado"
		
	Loc ["STRING_ATTRIBUTE_MISC"] = "Miscelanea"
		Loc ["STRING_ATTRIBUTE_MISC_CCBREAK"] = "Quebras de CC"
		Loc ["STRING_ATTRIBUTE_MISC_RESS"] = "Revividos"
		Loc ["STRING_ATTRIBUTE_MISC_INTERRUPT"] = "Interrupcoes"
		Loc ["STRING_ATTRIBUTE_MISC_DISPELL"] = "Dissipados"
		Loc ["STRING_ATTRIBUTE_MISC_DEAD"] = "Mortes"
		
	Loc ["STRING_ATTRIBUTE_CUSTOM"] = "Customizados"	
	
--> Tooltips & Info Box	

	Loc ["STRING_SPELLS"] = "Habilidades"
	Loc ["STRING_NO_SPELL"] = "Nenhuma habilidade foi usada"
	Loc ["STRING_TARGET"] = "Alvo"
	Loc ["STRING_TARGETS"] = "Alvos"
	Loc ["STRING_PET"] = "Ajudante"
	Loc ["STRING_DPS"] = "Dps"
	Loc ["STRING_SEE_BELOW"] = "veja abaixo"
	Loc ["STRING_GERAL"] = "Geral"
	Loc ["STRING_PERCENTAGE"] = "Porcentagem"
	Loc ["STRING_MEDIA"] = "Media"
	Loc ["STRING_HITS"] = "Golpes"
	Loc ["STRING_DAMAGE"] = "Dano"
	Loc ["STRING_NORMAL_HITS"] = "Golpes Normais"
	Loc ["STRING_CRITICAL_HITS"] = "Golpes Criticos"
	Loc ["STRING_MINIMUM"] = "Minimo"
	Loc ["STRING_MAXIMUM"] = "Maximo"
	Loc ["STRING_DEFENSES"] = "Defensas"
	Loc ["STRING_GLANCING"] = "Glancing"
	Loc ["STRING_RESISTED"] = "Resistido"
	Loc ["STRING_ABSORBED"] = "Absorvido"
	Loc ["STRING_BLOCKED"] = "Bloqueado"
	Loc ["STRING_FAIL_ATTACKS"] = "Falhas de Ataque"
	Loc ["STRING_MISS"] = "Errou"
	Loc ["STRING_PARRY"] = "Aparo"
	Loc ["STRING_DODGE"] = "Desvio"
	Loc ["STRING_DAMAGE_FROM"] = "Recebeu dano de"
	Loc ["STRING_HEALING_FROM"] = "Cura recebida de"
	Loc ["STRING_PLAYERS"] = "Jogadores"
	
	Loc ["STRING_HPS"] = "Hps"
	Loc ["STRING_HEAL"] = "Cura"
	Loc ["STRING_HEAL_ABSORBED"] = "Cura absorvida"
	Loc ["STRING_OVERHEAL"] = "Sobrecura"
----------------	
	Loc ["ABILITY_ID"] = "id da habilidade"

--> BuiltIn Plugins

	Loc ["STRING_PLUGIN_MINSEC"] = "Minutos & Segundos"
	Loc ["STRING_PLUGIN_SECONLY"] = "Somentte Segundos"
	Loc ["STRING_PLUGIN_TIMEDIFF"] = "Diferenca do Ultimo Combate"

	Loc ["STRING_PLUGIN_TOOLTIP_LEFTBUTTON"] = "Configura a ferramenta atual"
	Loc ["STRING_PLUGIN_TOOLTIP_RIGHTBUTTON"] = "Escolher uma outra ferramenta"
	
	Loc ["STRING_PLUGIN_CLOCKTYPE"] = "Tipo do Tempo"
	
	Loc ["STRING_PLUGIN_CLOCKNAME"] = "Tempo de Luta"
	Loc ["STRING_PLUGIN_PSEGMENTNAME"] = "Segmento Mostrado"
	Loc ["STRING_PLUGIN_PDPSNAME"] = "Dps da Raide"
	Loc ["STRING_PLUGIN_THREATNAME"] = "Minha Ameaça"
	Loc ["STRING_PLUGIN_PATTRIBUTENAME"] = "Atributo"
	
	Loc ["STRING_PLUGINOPTIONS_COMMA"] = "Virgula"
	Loc ["STRING_PLUGINOPTIONS_ABBREVIATE"] = "Abreviar"
	Loc ["STRING_PLUGINOPTIONS_NOFORMAT"] = "Nenhum"
	
	Loc ["STRING_PLUGINOPTIONS_TEXTSTYLE"] = "Estilo do Texto"
	Loc ["STRING_PLUGINOPTIONS_TEXTCOLOR"] = "Cor do Texto"
	Loc ["STRING_PLUGINOPTIONS_TEXTSIZE"] = "Tamanho"
	Loc ["STRING_PLUGINOPTIONS_TEXTALIGN"] = "Alinhamento"
	
	Loc ["STRING_PLUGINOPTIONS_FONTFACE"] = "Fonte"
	Loc ["STRING_PLUGINOPTIONS_TEXTALIGN_X"] = "Alinhamento X"
	Loc ["STRING_PLUGINOPTIONS_TEXTALIGN_Y"] = "Alinhamento Y"
	
	Loc ["STRING_OPTIONS_COLOR"] = "Cor"
	Loc ["STRING_OPTIONS_SIZE"] = "Tamanho"
	Loc ["STRING_OPTIONS_ANCHOR"] = "Lado"

--> Details Instances

	Loc ["STRING_SOLO_SWITCHINCOMBAT"] = "Voce esta em combate"
	Loc ["STRING_CUSTOM_NEW"] = "Criar Novo"
	Loc ["STRING_CUSTOM_REPORT"] = "Relatorio para (custom)"
	Loc ["STRING_REPORT"] = "Relatorio para"
	Loc ["STRING_REPORT_FIGHT"] = "luta"
	Loc ["STRING_REPORT_LAST"] = "Ultimas"
	Loc ["STRING_REPORT_FIGHTS"] = "lutas"
	Loc ["STRING_REPORT_LASTFIGHT"] = "ultima luta"
	Loc ["STRING_REPORT_PREVIOUSFIGHTS"] = "lutas anteriores"
	Loc ["STRING_REPORT_INVALIDTARGET"] = "O alvo nao pode ser encontrado"
	
--> report frame

	Loc ["STRING_REPORTFRAME_PARTY"] = "Grupo"
	Loc ["STRING_REPORTFRAME_RAID"] = "Raide"
	Loc ["STRING_REPORTFRAME_GUILD"] = "Guilda"
	Loc ["STRING_REPORTFRAME_OFFICERS"] = "Canal dos Oficiais"
	Loc ["STRING_REPORTFRAME_WHISPER"] = "Sussurrar"
	Loc ["STRING_REPORTFRAME_WHISPERTARGET"] = "Sussurar o Alvo"
	Loc ["STRING_REPORTFRAME_SAY"] = "Dizer"
	Loc ["STRING_REPORTFRAME_LINES"] = "Linhas"
	Loc ["STRING_REPORTFRAME_INSERTNAME"] = "entre com um nome"
	Loc ["STRING_REPORTFRAME_CURRENT"] = "Mostrando"
	Loc ["STRING_REPORTFRAME_REVERT"] = "Inverter"
	Loc ["STRING_REPORTFRAME_REVERTED"] = "invertido"
	Loc ["STRING_REPORTFRAME_CURRENTINFO"] = "Reporta apenas as informacoes que estao sendo mostradas no momento."
	Loc ["STRING_REPORTFRAME_REVERTINFO"] = "Inverte as posicoes colocando em ordem crescente."
	Loc ["STRING_REPORTFRAME_WINDOW_TITLE"] = "Emitir Relatorio"
	Loc ["STRING_REPORTFRAME_SEND"] = "Enviar"
	
--> player details frame

	Loc ["STRING_ACTORFRAME_NOTHING"] = "nao ha nada para reportar"
	Loc ["STRING_ACTORFRAME_REPORTTO"] = "relatorio para"
	Loc ["STRING_ACTORFRAME_REPORTTARGETS"] = "relatorio para os alvos de"
	Loc ["STRING_ACTORFRAME_REPORTOF"] = "de"
	Loc ["STRING_ACTORFRAME_REPORTAT"] = "em"
	Loc ["STRING_ACTORFRAME_SPELLUSED"] = "Todas as habilidades usadas"
	Loc ["STRING_ACTORFRAME_SPELLDETAILS"] = "detalhes da habilidade"
	Loc ["STRING_MASTERY"] = "Maestria"
	
--> Main Window

	Loc ["STRING_OPTIONS_WINDOW"] = "opcoes"
	Loc ["STRING_LOCK_WINDOW"] = "travar"
	Loc ["STRING_UNLOCK_WINDOW"] = "destravar"
	Loc ["STRING_ERASE"] = "apagar"
	Loc ["STRING_UNLOCK"] = "Separe as janelas\n neste botao"
	Loc ["STRING_PLUGIN_NAMEALREADYTAKEN"] = "Details! nao pode instalar um plugin pois o nome dele ja esta em uso"
	Loc ["STRING_RESIZE_COMMON"] = "Redimensiona livremente\n"
	Loc ["STRING_RESIZE_HORIZONTAL"] = "Redimenciona a largura\n de todas as janelas na linha horizontal"
	Loc ["STRING_RESIZE_VERTICAL"] = "Redimenciona a altura\n de todas as janelas na linha horizontal"
	Loc ["STRING_RESIZE_ALL"] = "Redimenciona livremente\n e reajusta todas as janelas"
	Loc ["STRING_FREEZE"] = "Este segmento não está disponível no momento"
	Loc ["STRING_CLOSEALL"] = "Todas as janelas do Details estao fechadas, digite '/details new' para reabri-las."
------------------------------------------------------------------------------------------------------------------------------------
--> MISC

	Loc ["STRING_PLAYER_DETAILS"] = "Detalhes do Jogador"
	Loc ["STRING_MELEE"] = "Corpo-a-Corpo"
	Loc ["STRING_AUTOSHOT"] = "Tiro Automatico"
	Loc ["STRING_UNKNOWSPELL"] = "Magia Desconhecida"
	
	Loc ["STRING_CCBROKE"] = "CC Quebrados"
	Loc ["STRING_DISPELLED"] = "Auras Removidas"
	Loc ["STRING_SPELL_INTERRUPTED"] = "Magias Interrompidas"
	
	Loc ["STRING_DOT"] = " (DoT)"
