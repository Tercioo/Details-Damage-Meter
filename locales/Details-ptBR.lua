local Loc = LibStub("AceLocale-3.0"):NewLocale("Details", "ptBR") 
if not Loc then return end 

--------------------------------------------------------------------------------------------------------------------------------------------
	Loc ["STRING_VERSION_LOG"] = "|cFFFFFF00v1.8.3|r\n\n|cFFFFFF00-|r Adicionada nova skin: Simple Gray.\n\n|cFFFFFF00-|r Adicionado botoes para o Details! no minimapa e menu de addons no painel de intercace.\n\n|cFFFFFF00-|r Adicionados novas bolhas de tutoriais para aspectos basicos das janelas do Details!.\n\n|cFFFFFF00-|r Corrigido o Modo Panico aonde as vezes ele nao era disparado.\n\n|cFFFFFF00v1.8.0|r\n\n- Adicionado novo plugin: You Are Not Prepared.\n\n|cFFFFFF00-|r Novo painel de opcoes!\n\n|cFFFFFF00v1.7.0|r\n\n- Corrigido alguns problemas com as cores das barras de inimigos.\n\n|cFFFFFF00-|r CC Quebrado foi inteiramente reescrito e agora deve funcionar corretamente.\n\n|cFFFFFF00-|r Adicionado novo sub atributo ao dano: Voidzones & Debuffs.|cFFFFFF00v1.6.7|r\n\n- Adicionado suporte a skins, troque ela atraves do painel de opcoes.\n\n|cFFFFFF00v1.6.5|r\n\n|cFFFFFF00-|r Adicionado o sub atributo 'Inimigos' que mostra, eh claro, somente inimigos.\n\n|cFFFFFF00-|r Corrigido um problema na captura das magias conjuradas.|cFFFFFF00v1.6.3|r\n\n|cFFFFFF00-|r captura de dados agora roda 4% mais rapido.\n\n|cFFFFFF00-|r Corrigido problema onde os ajudantes nao atualizavam o tempo de atividade do dono.\n\n|cFFFFFF00-|r Corrigido problema onde o healing era contado mesmo fora do combate.\n\n|cFFFFFF00-|r Corrigido problema com chefes multiplos como Twin Consorts.\n\n|cFFFFFF00-|r Adicionada opcao para juntar os segmentos de trash mobs.\n\n|cFFFFFF00-|r Adicionada opcao para auto remover os segmentos de trash mobs. \n\n|cFFFFFF00-|r Adicionada opcao para alterar a altura das barras.\n\n|cFFFFFF00-|r Plugin Encounter Details agora mostra quantos cast bem sucedidos as magias interrompidas tiveram.\n\n|cFFFFFF00v1.6.1|r\n\n|cFFFFFF00-|r Corrigido:\n- problema com o tempo de debuffs.\n- dps dos dados gerais e o dps no micro display .\n- varios bugs envolvendo o menu da espada e do livro.\n- o coletor de lixo nao ira mais apagar jogadores com vinculo a membros do grupo.\n\n|cFFFFFF00-|r dados gerais agora sempre ira usar o tempo do combate para medir dps e hps.\n\n|cFFFFFF00v1.6.0|r\n\n|cFFFFFF00-|r Adicionado tempo de debuff no atributo miscelanea.\n\n|cFFFFFF00-|r Atributos desativados agora ficam escurecidos no menu da espada.\n\n|cFFFFFF00-|r Corrigido um problema aonde algumas vezes era necessario dar /reload para trocar um talento.\n\n|cFFFFFF00v1.5.3|r\n\n|cFFFFFF00-|r Corrigido problema ao reportar durante o combate.\n\n|cFFFFFF00-|r Melhorado a reconhecimento dos donos de ajudantes.\n\n|cFFFFFF00-|r Adicionada uma opcao para mostrar apenas frags em cima de jogadores inimigos.\n\n|cFFFFFF00-|r Adicionado cor e icone aos frags.\n\n|cFFFFFF00v1.5.2|r\n\n|cFFFFFF00-|r Corrigido problema onde desativando o tempo dos buffs estava desativando tambem a cura feita.\n\n|cFFFFFF00-|r Estatisticas de Avoidance nao seram mais capturadas para pessoas foram do grupo, monstros ou ajudantes.\n\n|cFFFFFF00-|r Corrigido problema onde as vezes estava demorando muito para salvar o tempo dos buffs ao sair do jogo.\n\n|cFFFFFF00v1.5.1|r\n\n|cFFFFFF00-|r Corrigido problema ao reportar o Dps onde as vezes nao mostrava nenhum jogador.\n\n|cFFFFFF00v1.5.0|r\n\n|cFFFFFF00-|r Buff Uptime foi implementado no atributo miscelanea.\n\n|cFFFFFF00-|r Cooldowns usados agora aparecem nos registros da morte.\n\n|cFFFFFF00-|r Implementado esta janela mostrando as atualizacoes.\n\n|cFFFFFF00-|r Corrigido problema onde algumas vezes clicando no nome do atributo fazia a instancia parar de atualizar.\n\n|cFFFFFF00-|r Desativando a cura agora para as absorcoes tambem. Desligando as Auras nao interrompe as absorcoes. \n\n|cFFFFFF00-|r Fogo Amigo agora conta apenas jogadores dentro do grupo.\n\n|cFFFFFF00-|r Corrigido problema onde o dano feito por um ajudando nao estava contando no alvo do dono.\n\n|cFFFFFF00-|r Corrigido problema onde a atualizacao de um cooldown nao estava sendo contada.\n\n|cFFFFFF00-|r Adicionada as magias de absorcao para 2P tier 16.\n\n|cFFFFFF00-|r Adicionado os comandos de barra 'worldboss' e 'updates'.\n\n|cFFFFFF00-|r Corrigido problema ao reportar onde algumas vezes nao estava funcionando."

	Loc ["STRING_DETAILS1"] = "|cffffaeaeDetalhes:|r " --> color and details name

	Loc ["STRING_YES"] = "Sim"
	Loc ["STRING_NO"] = "Nao"
	
	Loc ["STRING_MINIMAP_TOOLTIP1"] = "|cFFCFCFCFbotao esquerdo|r: abrir o painel de opcoes"
	Loc ["STRING_MINIMAP_TOOLTIP2"] = "|cFFCFCFCFbotao direito|r: menu rapido"
	
	Loc ["STRING_MINIMAPMENU_NEWWINDOW"] = "Criar Nova Janela"
	Loc ["STRING_MINIMAPMENU_RESET"] = "Resetar"
	Loc ["STRING_MINIMAPMENU_REOPEN"] = "Reabrir Janela"
	Loc ["STRING_MINIMAPMENU_REOPENALL"] = "Reabrir Todas"
	Loc ["STRING_MINIMAPMENU_UNLOCK"] = "Destravar"
	Loc ["STRING_MINIMAPMENU_LOCK"] = "Travar"
	
	Loc ["STRING_INTERFACE_OPENOPTIONS"] = "Abrir Painel de Opcoes"
	
	Loc ["STRING_RIGHTCLICK_TYPEVALUE"] = "botao direito para digitar o valor"
	Loc ["STRING_AUTO"] = "auto"
	Loc ["STRING_LEFT"] = "esquerda"
	Loc ["STRING_CENTER"] = "centro"
	Loc ["STRING_RIGHT"] = "direita"
	Loc ["STRING_TOOOLD"] = "nao pode ser instalado pois sua versao do Details! e muito antiga."
	Loc ["STRING_TOOOLD2"] = "a sua versao do Details! nao e a mesma."
	Loc ["STRING_CHANGED_TO_CURRENT"] = "Segmento trocado para atual"
	Loc ["STRING_SEGMENT_TRASH"] = "Caminho do Proximo Boss"
	Loc ["STRING_VERSION_UPDATE"] = "nova versao: clique para ver o que mudou"
	Loc ["STRING_NEWS_TITLE"] = "Quais As Novidades Desta Versao"
	Loc ["STRING_TIME_OF_DEATH"] = "Morreu"
	Loc ["STRING_SHORTCUT_RIGHTCLICK"] = "Menu de Atalho (botao direito para fechar)"
	
	Loc ["STRING_NO_DATA"] = "data já foi limpada"
	Loc ["STRING_ISA_PET"] = "Este Ator e um Ajudante"
	Loc ["STRING_EQUILIZING"] = "Comparilhando dados"
	Loc ["STRING_LEFT_CLICK_SHARE"] = "Clique para enviar relatorio."
	
	Loc ["STRING_LAST_COOLDOWN"] = "ultimo cooldown usado"
	Loc ["STRING_NOLAST_COOLDOWN"] = "nenhum cooldown usado"
	
	Loc ["STRING_INSTANCE_LIMIT"] = "o limite de instancias foi atingido, voce pode modificar este limite no painel de opcoes."
	
	Loc ["STRING_PLEASE_WAIT"] = "Por favor espere"
	Loc ["STRING_UPTADING"] = "atualizando"
	
	Loc ["STRING_RAID_WIDE"] = "[*] cooldown de raide"

	Loc ["STRING_RIGHTCLICK_CLOSE_SHORT"] = "Botao direito para fechar."
	Loc ["STRING_RIGHTCLICK_CLOSE_MEDIUM"] = "Use o botao direito para fechar esta janela."
	Loc ["STRING_RIGHTCLICK_CLOSE_LARGE"] = "Clique com o botao direito do mouse para fechar esta janela."
	
--> Slash
	Loc ["STRING_COMMAND_LIST"] = "lista de comandos"
	
	Loc ["STRING_SLASH_SHOW"] = "mostrar"
	Loc ["STRING_SLASH_SHOW_DESC"] = "abre uma janela caso nao tenha nenhuma aberta."

	Loc ["STRING_SLASH_DISABLE"] = "desativar"
	Loc ["STRING_SLASH_DISABLE_DESC"] = "desliga todas as capturas de dados."
	Loc ["STRING_SLASH_CAPTUREOFF"] = "todas as capturas foram desligadas."
	
	Loc ["STRING_SLASH_ENABLE"] = "ativa"
	Loc ["STRING_SLASH_ENABLE_DESC"] = "liga todas as capturas de dados."
	Loc ["STRING_SLASH_CAPTUREON"] = "todas as capturas foram ligadas."

	Loc ["STRING_SLASH_OPTIONS"] = "opcoes"
	Loc ["STRING_SLASH_OPTIONS_DESC"] = "abre o painel de opcoes."
	
	Loc ["STRING_SLASH_NEW"] = "novo"
	Loc ["STRING_SLASH_NEW_DESC"] = "abre ou reabre uma instancia."
	
	Loc ["STRING_SLASH_CHANGES"] = "updates"
	Loc ["STRING_SLASH_CHANGES_DESC"] = "mostra o que foi implementado e corrigido nesta versao do Details."
	
	Loc ["STRING_SLASH_WORLDBOSS"] = "worldboss"
	Loc ["STRING_SLASH_WORLDBOSS_DESC"] = "executa uma macro mostrando quais 'world boss' voce matou esta semana."
	Loc ["STRING_KILLED"] = "Morto"
	Loc ["STRING_ALIVE"] = "Vivo"
	
--> StatusBar Plugins
	Loc ["STRING_STATUSBAR_NOOPTIONS"] = "Nao ha opcoes para esta ferramenta."
	
--> Fights and Segments

	Loc ["STRING_SEGMENT"] = "Segmento"
	Loc ["STRING_SEGMENT_LOWER"] = "segmento"
	Loc ["STRING_SEGMENT_EMPTY"] = "este segmento esta vazio"
	Loc ["STRING_SEGMENT_START"] = "Inicio"
	Loc ["STRING_SEGMENT_END"] = "Fim"
	Loc ["STRING_SEGMENT_ENEMY"] = "Contra"
	Loc ["STRING_SEGMENT_TIME"] = "Tempo"
	Loc ["STRING_SEGMENT_OVERALL"] = "Total dos Segmentos Atuais"
	Loc ["STRING_TOTAL"] = "Total"
	Loc ["STRING_OVERALL"] = "Dados Gerais"
	Loc ["STRING_CURRENT"] = "Atual"
	Loc ["STRING_CURRENTFIGHT"] = "Luta Atual"
	Loc ["STRING_FIGHTNUMBER"] = "Luta #"
	Loc ["STRING_UNKNOW"] = "Desconhecido"
	Loc ["STRING_AGAINST"] = "contra"

--> Custom Window -- traduzir

	Loc ["STRING_CUSTOM_REMOVE"] = "Remover"
	Loc ["STRING_CUSTOM_BROADCAST"] = "Enviar"
	Loc ["STRING_CUSTOM_NAME"] = "Nome"
	Loc ["STRING_CUSTOM_SPELLID"] = "Id da Magia"
	Loc ["STRING_CUSTOM_SOURCE"] = "Fonte"
	Loc ["STRING_CUSTOM_TARGET"] = "Alvo"
	Loc ["STRING_CUSTOM_TOOLTIPNAME"] = "Insira aqui o nome da sua customizacao.\nPermitido letras e numeros, minimo de 5 caracteres e no maximo 32."
	Loc ["STRING_CUSTOM_TOOLTIPSPELL"] = "Selecione uma habilidade de um chefe no botao a direita ou digite o nome para filtrar todas as habilidades."
	Loc ["STRING_CUSTOM_TOOLTIPSOURCE"] = "Fonte da magia (com os colchetes):\n|cFF00FF00[all]|r: Procura pela magia em todos os atores.\n|cFFFF9900[raid]|r: Busca apenas na raide ou no grupo.\n|cFF33CCFF[player]|r: Procura apenas em voce.\nQualquer outro texto sera considerado um nome de um ator."
	Loc ["STRING_CUSTOM_TOOLTIPTARGET"] = "Insert the ability (player, monster, boss) target name."
	Loc ["STRING_CUSTOM_TOOLTIPNOTWORKING"] = "Ouch, algum gnomo tocou nisso e acabou quebrando =("
	Loc ["STRING_CUSTOM_BROADCASTSENT"] = "Enviar"
	Loc ["STRING_CUSTOM_CREATED"] = "Sua customizacao foi criada."
	Loc ["STRING_CUSTOM_ICON"] = "Icone"
	Loc ["STRING_CUSTOM_CREATE"] = "Criar"
	Loc ["STRING_CUSTOM_INCOMBAT"] = "Voce esta em combate."
	Loc ["STRING_CUSTOM_NOATTRIBUTO"] = "Nenhum atributo foi selecionado."
	Loc ["STRING_CUSTOM_SHORTNAME"] = "O nome precisa de pelo menos 5 caracteres."
	Loc ["STRING_CUSTOM_LONGNAME"] = "O nome esta fora do permitido, use ate 32 caracteres."
	Loc ["STRING_CUSTOM_NOSPELL"] = "O campo do Id da magia nao pode ser ignorado."
	Loc ["STRING_CUSTOM_HELP1"] = "Remove a previously created custom\nSend this custom to all raid members."
	Loc ["STRING_CUSTOM_HELP2"] = "Escolha aqui o atributo, se a sua magia for de curar, voce deve escolher cura."
	Loc ["STRING_CUSTOM_HELP3"] = "O nome da customizacao e usado no menu de atributos do Detalhes, e tambem mostrado no relatorio ao reportar."
	Loc ["STRING_CUSTOM_HELP4"] = "Voce pode escolher uma magia de algum encontro de uma raide, basta deixar o ponteiro do mouse sobre o botao para que o menu seja mostrado."
	Loc ["STRING_CUSTOM_ACCETP_CUSTOM"] = "lhe enviou um display customizado. Voce deseja adicionar esta customizacao a sua biblioteca de displays customizados?"

--> Switch Window

	Loc ["STRING_SWITCH_CLICKME"] = "clique-me"
	
--> Mode Names

	Loc ["STRING_MODE_GROUP"] = "Grupo & Raide"
	Loc ["STRING_MODE_ALL"] = "Mostrar Tudo"
	
	Loc ["STRING_MODE_SELF"] = "Lobo Solitario"
	Loc ["STRING_MODE_RAID"] = "Acessorios"
	Loc ["STRING_MODE_PLUGINS"] = "plugins"
	
	Loc ["STRING_OPTIONS_WINDOW"] = "Painel de Opcoes"
	
--> Wait Messages
	
	Loc ["STRING_NEWROW"] = "esperando atualizar..."
	Loc ["STRING_WAITPLUGIN"] = "esperando por\nplugins"
	
--> Cooltip
	
	Loc ["STRING_COOLTIP_NOOPTIONS"] = "Nao ha opcoes"

--> Attributes	

	Loc ["STRING_ATTRIBUTE_DAMAGE"] = "Dano"
		Loc ["STRING_ATTRIBUTE_DAMAGE_DONE"] = "Dano Feito"
		Loc ["STRING_ATTRIBUTE_DAMAGE_DPS"] = "Dano por Segundo"
		Loc ["STRING_ATTRIBUTE_DAMAGE_TAKEN"] = "Dano Recebido"
		Loc ["STRING_DAMAGE_TAKEN_FROM"] = "Dano Recebido Vindo De"
		Loc ["STRING_DAMAGE_TAKEN_FROM2"] = "aplicou dano com"
		Loc ["STRING_ATTRIBUTE_DAMAGE_FRIENDLYFIRE"] = "Fogo Amigo"
		Loc ["STRING_ATTRIBUTE_DAMAGE_FRAGS"] = "Abatimentos"
		Loc ["STRING_ATTRIBUTE_DAMAGE_ENEMIES"] = "Inimigos"
		Loc ["STRING_ATTRIBUTE_DAMAGE_DEBUFFS"] = "Auras & Voidzones"
		Loc ["STRING_ATTRIBUTE_DAMAGE_DEBUFFS_REPORT"] = "Dano e Tempo de Atividade da Aura"
		
	Loc ["STRING_ATTRIBUTE_HEAL"] = "Cura"
		Loc ["STRING_ATTRIBUTE_HEAL_DONE"] = "Cura Feita"
		Loc ["STRING_ATTRIBUTE_HEAL_HPS"] = "Cura Por Segundo"
		Loc ["STRING_ATTRIBUTE_HEAL_OVERHEAL"] = "Sobrecura"
		Loc ["STRING_ATTRIBUTE_HEAL_TAKEN"] = "Cura Recebida"
		Loc ["STRING_ATTRIBUTE_HEAL_ENEMY"] = "Cura no Inimigo"
		Loc ["STRING_ATTRIBUTE_HEAL_PREVENT"] = "Dano Prevenido"
		
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
		Loc ["STRING_ATTRIBUTE_MISC_DEFENSIVE_COOLDOWNS"] = "Cooldowns"
		Loc ["STRING_ATTRIBUTE_MISC_BUFF_UPTIME"] = "Buff Tempo Ativo"
		Loc ["STRING_ATTRIBUTE_MISC_DEBUFF_UPTIME"] = "Debuff Tempo Ativo"
		
	Loc ["STRING_ATTRIBUTE_CUSTOM"] = "Customizados"	
	
--> Tooltips & Info Box	

	Loc ["STRING_SPELLS"] = "Habilidades"
	Loc ["STRING_NO_SPELL"] = "Nenhuma habilidade foi usada"
	Loc ["STRING_TARGET"] = "Alvo"
	Loc ["STRING_TARGETS"] = "Alvos"
	Loc ["STRING_FROM"] = "Fonte"
	Loc ["STRING_PET"] = "Ajudante"
	Loc ["STRING_PETS"] = "Ajudantes"
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
	Loc ["STRING_HEAL_CRIT"] = "Cura Critica"
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
	
	Loc ["STRING_PLUGIN_DURABILITY"] = "Durabilidade"
	Loc ["STRING_PLUGIN_LATENCY"] = "Latencia"
	Loc ["STRING_PLUGIN_GOLD"] = "Dinheiro"
	Loc ["STRING_PLUGIN_FPS"] = "Quadros por Segundo"
	Loc ["STRING_PLUGIN_TIME"] = "Relogio"
	Loc ["STRING_PLUGIN_CLOCKNAME"] = "Tempo de Luta"
	Loc ["STRING_PLUGIN_PSEGMENTNAME"] = "Segmento Mostrado"
	Loc ["STRING_PLUGIN_PDPSNAME"] = "Dps da Raide"
	Loc ["STRING_PLUGIN_THREATNAME"] = "Minha Ameaça"
	Loc ["STRING_PLUGIN_PATTRIBUTENAME"] = "Atributo"
	Loc ["STRING_PLUGIN_CLEAN"] = "Nenhum"
	
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
	Loc ["STRING_REPORT_LEFTCLICK"] = "Clique para abrir a janela de relatorio"
	Loc ["STRING_REPORT_FIGHT"] = "luta"
	Loc ["STRING_REPORT_LAST"] = "Ultimas"
	Loc ["STRING_REPORT_FIGHTS"] = "lutas"
	Loc ["STRING_REPORT_LASTFIGHT"] = "ultima luta"
	Loc ["STRING_REPORT_PREVIOUSFIGHTS"] = "lutas anteriores"
	Loc ["STRING_REPORT_INVALIDTARGET"] = "O alvo nao pode ser encontrado"
	Loc ["STRING_REPORT_SINGLE_DEATH"] = "detalhes da morte de"
	Loc ["STRING_REPORT_SINGLE_COOLDOWN"] = "cooldowns usados por"
	Loc ["STRING_REPORT_SINGLE_BUFFUPTIME"] = "duracao dos buffs de"
	Loc ["STRING_REPORT_SINGLE_DEBUFFUPTIME"]  = "duracao dos debuffs de"
	Loc ["STRING_NOCLOSED_INSTANCES"] = "Nao ha instancias fechadas,\nclique para abrir uma nova."
	
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
	
	Loc ["STRING_HELP_MENUS"] = "Menu da Engrenagem: altera o modo de jogo.\nSolo: ferramentas para voce jogar sozinho.\nGroup: mostra apenas os atores que pertencem ao seu grupo de raide.\nAll: mostra tudo.\nRaid: ferramentas para auxiliar em grupos de raide.\n\nMenu do Livro: altera o segmento que esta sendo mostrado na janela.\n\nMenu da Espada: muda o atributo que esta janela esta mostrando."
	Loc ["STRING_HELP_ERASE"] = "Apaga todo o historico de lutas."
	Loc ["STRING_HELP_INSTANCE"] = "Clique: abre uma nova janela.\n\nMouse em cima: mostra um menu com todas as janelas fechadas, voce pode reabrilas quando quiser."
	Loc ["STRING_HELP_STATUSBAR"] = "A barra de status armazena 3 plugins: um na esquerda, outro no centro e na direita.\n\nBotao direito: seleciona outro plugin para mostrar.\n\nBotao esquerdo: mostra as opcoes do plugin."
	Loc ["STRING_HELP_SWITCH"] = "Botao direito: mostra o painel de mudanca rapida.\n\nBotao esquerdo em uma opcao do painel de mudanca rapida: muda o atributo que a janela esta mostrando.\nbotao direito: fecha o painel.\n\nVoce pode clicar nos icones para escolher outro atributo."
	Loc ["STRING_HELP_RESIZE"] = "Botoes de redimencionar e travar a janela."
	Loc ["STRING_HELP_STRETCH"] = "Clique, segure e puxe para esticar a janela."
	
	Loc ["STRING_HELP_MODESELF"] = "Este modo possui plugins destinados apenas ao seu personagem. Voce pode escolher o plugin que deseja usar no menu da espada."
	Loc ["STRING_HELP_MODEGROUP"] = "Neste modo somendo é mostrado personagens que estao no seu grupo ou raide."
	Loc ["STRING_HELP_MODEALL"] = "Nesta opcao os filtros de grupo estao desativados, o Details! mostra tudo o que foi capturado, incluindo monstros, chefes, adds, entre outros."
	Loc ["STRING_HELP_MODERAID"] = "O modo raide eh o oposto do modo lobo solitario, aqui voce encontra plugins destinados ao seu grupo em geral."
	
--> MISC

	Loc ["STRING_PLAYER_DETAILS"] = "Detalhes do Jogador"
	Loc ["STRING_MELEE"] = "Corpo-a-Corpo"
	Loc ["STRING_AUTOSHOT"] = "Tiro Automatico"
	Loc ["STRING_DOT"] = " (DoT)"
	Loc ["STRING_UNKNOWSPELL"] = "Magia Desconhecida"
	
	Loc ["STRING_CCBROKE"] = "CC Quebrados"
	Loc ["STRING_DISPELLED"] = "Auras Removidas"
	Loc ["STRING_SPELL_INTERRUPTED"] = "Magias Interrompidas"
	
-- OPTIONS PANEL -----------------------------------------------------------------------------------------------------------------

	Loc ["STRING_OPTIONS_SWITCHINFO"] = "|cFFF79F81 ESQUERDA DESATIVADO|r  |cFF81BEF7 DIREITA ATIVADO|r"
	
	Loc ["STRING_OPTIONS_PICKCOLOR"] = "cor"
	Loc ["STRING_OPTIONS_EDITIMAGE"] = "Editar Imagem"
	
	Loc ["STRING_OPTIONS_PRESETTOOLD"] = "Esta predefinicao requer uma versao atualizada do Details!."
	Loc ["STRING_OPTIONS_PRESETNONAME"] = "De um nome a sua predefinicao."
	
	Loc ["STRING_OPTIONS_EDITINSTANCE"] = "Editando a Instancia:"
	
	Loc ["STRING_OPTIONS_GENERAL"] = "Configuracoes Gerais"
	Loc ["STRING_OPTIONS_APPEARANCE"] = "Aparencia"
	Loc ["STRING_OPTIONS_PERFORMANCE"] = "Performance"
	Loc ["STRING_OPTIONS_SOCIAL"] = "Social"
	Loc ["STRING_OPTIONS_SOCIAL_DESC"] = "Diga como voce gostaria de ser conhecido na sua guilda."
	Loc ["STRING_OPTIONS_NICKNAME"] = "Apelido"
	Loc ["STRING_OPTIONS_NICKNAME_DESC"] = "Digite o seu apelido neste campo. O apelido escolhido sera enviado aos membros da sua guilda e o Details! ira substituir o nome do personagem pelo aplido."
	Loc ["STRING_OPTIONS_AVATAR"] = "Escolha o Seu Avatar"
	Loc ["STRING_OPTIONS_AVATAR_DESC"] = "O avatar tambem eh enviado aos membros da guilda, ele eh mostrado sobre o tooltip quando passa o mouse sobre uma barra."
	Loc ["STRING_OPTIONS_REALMNAME"] = "Remover o Nome do Reino"
	Loc ["STRING_OPTIONS_REALMNAME_DESC"] = "Quando ativado, o nome do reino do que o personagem pertence nao eh mostrado.\n\n|cFFFFFFFFExemplo:|r\n\nCharles-Azralon |cFFFFFFFF(desativado)|r\nCharles |cFFFFFFFF(ativado)|r"
	
	Loc ["STRING_OPTIONS_MAXSEGMENTS"] = "Max. Segmentos"
	Loc ["STRING_OPTIONS_MAXSEGMENTS_DESC"] = "Esta opcao controla quantos segmentos voce deseja manter.\n\nO recomendado eh |cFFFFFFFF12|r, mas sinta-se livre para ajustar este numero como desejar.\n\nComputadores com |cFFFFFFFF2GB|r ou menos de memoria ram devem manter um numero de segmentos baixo, isto pode ajudar a preservar a memoria."
	
	Loc ["STRING_OPTIONS_SCROLLBAR"] = "Barra de Rolagem"
	Loc ["STRING_OPTIONS_SCROLLBAR_DESC"] = "Ativa ou desativa a barra de rolagem.\n\nDetails! usa como padrao um mecanismo para estivar a janela.\n\nA |cFFFFFFFFalca|r para estica-lo encontra-se fora da janela em cima do botao de fechar e de criar instancias."
	Loc ["STRING_OPTIONS_MAXINSTANCES"] = "Max. Instancias"
	Loc ["STRING_OPTIONS_MAXINSTANCES_DESC"] = "Limita o numero de janelas que podem ser criadas.\n\nVoce pode abrir ou reabrir as janelas atraves do botao de instancia localizado a esquerda do botao de fechar."
	Loc ["STRING_OPTIONS_PVPFRAGS"] = "Apenas Frags de Pvp"
	Loc ["STRING_OPTIONS_PVPFRAGS_DESC"] = "Quando ativado, serao registrados apenas mortes de jogadores da faccao inimiga."
	Loc ["STRING_OPTIONS_TIMEMEASURE"] = "Medidas do Tempo"
	Loc ["STRING_OPTIONS_TIMEMEASURE_DESC"] = "|cFFFFFFFFTempo de Atividade|r: o tempo de cada membro da raide eh posto em pausa quando ele ficar ocioso e volta a contar o tempo quando ele voltar a atividade, eh a maneira mais comum de medir o Dps e Hps.\n\n|cFFFFFFFFTempo Efetivo|r: muito usado para ranqueamentos, este metodo usa o tempo total da luta para medir o Dps e Hps de todos os membros da raide."
	
	Loc ["STRING_OPTIONS_PERFORMANCE1"] = "Ajustes de Performance"
	Loc ["STRING_OPTIONS_PERFORMANCE1_DESC"] = "Estas opcoes podem ajudar no desempenho deste addon."
	
	Loc ["STRING_OPTIONS_MEMORYT"] = "Ajuste de Memoria"
	Loc ["STRING_OPTIONS_MEMORYT_DESC"] = "Details! possui mecanismos internos que lidam com a memoria e tentam ajustar o uso dela de acordo com a memoria disponivel no seu sistema.\n\nTambem eh recomendado limitar o numero de segmentos se o seu computador tiver |cFFFFFFFF2GB|r ou menos de memoria."
	
	Loc ["STRING_OPTIONS_SEGMENTSSAVE"] = "Segmentos Salvos"
	Loc ["STRING_OPTIONS_SEGMENTSSAVE_DESC"] = "Esta opcao controla quantos segmentos voce deseja salvar entre logouts e loginss.\n\nValores altos podem fazer o tempo de logoff do seu personagem demorar mais.\n\nSe voce raramente olha os dados da raide do dia anterior, eh muito recomendado deixar esta opcao em 1|cFFFFFFFF1|r."
	
	Loc ["STRING_OPTIONS_PANIMODE"] = "Modo de Panico"
	Loc ["STRING_OPTIONS_PANIMODE_DESC"] = "Quando voce cair do jogo durante uma luta contra um Chefe de uma Raide e esta opcao estiver antiva, todos os segmentos sao apagados para o processo de logoff ser rapido."
	
	Loc ["STRING_OPTIONS_ANIMATEBARS"] = "Animar as Barras"
	Loc ["STRING_OPTIONS_ANIMATEBARS_DESC"] = "Quando ativa as barras das janelas sao animadas ao inves de 'pularem'."
	
	Loc ["STRING_OPTIONS_ANIMATESCROLL"] = "Animar Barra de Rolagem"
	Loc ["STRING_OPTIONS_ANIMATESCROLL_DESC"] = "Quanto ativa, a barra de rolagem faz uma animacao ao ser mostrada e escondida."
	
	Loc ["STRING_OPTIONS_WINDOWSPEED"] = "Velocidade de Atualizacao"
	Loc ["STRING_OPTIONS_WINDOWSPEED_DESC"] = "Segundos entre cada atualizacao da janela.\n\n|cFFFFFFFF0.3|r: atualiza cerca de 3 vezes por segundo.\n\n|cFFFFFFFF3.0|r: atualiza a cada 3 segundos."
	
	Loc ["STRING_OPTIONS_CLEANUP"] = "Apagar Segmentos de Limpeza"
	Loc ["STRING_OPTIONS_CLEANUP_DESC"] = "Segmentos com 'trash mobs' sao considerados segmentos de limpeza.\n\nEsta opcao ativa a remocao automatica destes segmetnso quando possivel."
	
	Loc ["STRING_OPTIONS_PERFORMANCECAPTURES"] = "Coletor de Informacao do Combate"
	Loc ["STRING_OPTIONS_PERFORMANCECAPTURES_DESC"] = "Esta opcao controla quais informacoes serao capturadas durante o combate."
	
	
	Loc ["STRING_OPTIONS_CDAMAGE"] = "Coletar Dano"
	Loc ["STRING_OPTIONS_CHEAL"] = "Coletar Cura"
	Loc ["STRING_OPTIONS_CENERGY"] = "Coletar Energia"
	Loc ["STRING_OPTIONS_CMISC"] = "Coletar Misc"
	Loc ["STRING_OPTIONS_CAURAS"] = "Coletar Auras"
	
	Loc ["STRING_OPTIONS_CDAMAGE_DESC"] = "Ativa a Captura de:\n\n- |cFFFFFFFFDano Feito|r\n- |cFFFFFFFFDano Por Segundo|r\n- |cFFFFFFFFFogo Amigo|r\n- |cFFFFFFFFDano Sofrido|r"
	Loc ["STRING_OPTIONS_CHEAL_DESC"] = "Ativa a Captura de:\n\n- |cFFFFFFFFCura Feita|r\n- |cFFFFFFFFAbsorcoes|r\n- |cFFFFFFFFCura Por Segundo|r\n- |cFFFFFFFFSobre Cura|r\n- |cFFFFFFFFCura Recebida|r\n- |cFFFFFFFFCura Inimiga|r\n- |cFFFFFFFFDano Prevenido|r"
	Loc ["STRING_OPTIONS_CENERGY_DESC"] = "Ativa a Captura de:\n\n- |cFFFFFFFFMana Restaurada|r\n- |cFFFFFFFFRaiva Gerada|r\n- |cFFFFFFFFEnergia Gerada|r\n- |cFFFFFFFFPoder Runico Gerado|r"
	Loc ["STRING_OPTIONS_CMISC_DESC"] = "Ativa a Captura de:\n\n- |cFFFFFFFFQuebra de CC|r\n- |cFFFFFFFFDissipacoes|r\n- |cFFFFFFFFInterrupcoes|r\n- |cFFFFFFFFRess|r\n- |cFFFFFFFFMortes|r"
	Loc ["STRING_OPTIONS_CAURAS_DESC"] = "Ativa a Captura de:\n\n- |cFFFFFFFFTempo de Buffs|r\n- |cFFFFFFFFTempo de Debuffs|r\n- |cFFFFFFFFVoid Zones|r\n-|cFFFFFFFF Cooldowns|r"
	
	Loc ["STRING_OPTIONS_CLOUD"] = "Captura Atraves de Nuvem"
	Loc ["STRING_OPTIONS_CLOUD_DESC"] = "Quando ativado, as informacoes de capturas deligadas eh buscada em outros membros da raide."
	
	
	Loc ["STRING_OPTIONS_BARS"] = "Bar Settings"
	Loc ["STRING_OPTIONS_BARS_DESC"] = "This options control the appearance of the instance bars."

	Loc ["STRING_OPTIONS_BAR_TEXTURE"] = "Texture"
	Loc ["STRING_OPTIONS_BAR_TEXTURE_DESC"] = "Choose the texture of bars."
	
	Loc ["STRING_OPTIONS_BAR_BTEXTURE"] = "Background Texture"
	Loc ["STRING_OPTIONS_BAR_BTEXTURE_DESC"] = "Choose the background texture of bars."
	
	Loc ["STRING_OPTIONS_BAR_BCOLOR"] = "Background Color"
	Loc ["STRING_OPTIONS_BAR_BCOLOR_DESC"] = "Choose the background color of bars."
	
	Loc ["STRING_OPTIONS_BAR_HEIGHT"] = "Height"
	Loc ["STRING_OPTIONS_BAR_HEIGHT_DESC"] = "Change the height of bars."
	
	Loc ["STRING_OPTIONS_BAR_COLORBYCLASS"] = "Color By Class"
	Loc ["STRING_OPTIONS_BAR_COLORBYCLASS_DESC"] = "When enabled, the instance bars have the color of the character class.\n\nDisabled: bars have a fixed color."
	
	Loc ["STRING_OPTIONS_BAR_COLORBYCLASS2"] = "Background Color By Class"
	Loc ["STRING_OPTIONS_BAR_COLORBYCLASS2_DESC"] = "When enabled, the instance bars  background have the color of the character class.\n\nDisabled: bars have a fixed color."
	--
	Loc ["STRING_OPTIONS_TEXT"] = "Text Settings"
	Loc ["STRING_OPTIONS_TEXT_DESC"] = "This options control the appearance of the instance bar texts."
	
	Loc ["STRING_OPTIONS_TEXT_SIZE"] = "Size"
	Loc ["STRING_OPTIONS_TEXT_SIZE_DESC"] = "Change the size of bar texts."
	
	Loc ["STRING_OPTIONS_TEXT_FONT"] = "Font"
	Loc ["STRING_OPTIONS_TEXT_FONT_DESC"] = "Change the font of bar texts."
	
	Loc ["STRING_OPTIONS_TEXT_LOUTILINE"] = "Left Text Outline"
	Loc ["STRING_OPTIONS_TEXT_LOUTILINE_DESC"] = "Enable or Disable the outline for left text."
	
	Loc ["STRING_OPTIONS_TEXT_ROUTILINE"] = "Right Text Outline"
	Loc ["STRING_OPTIONS_TEXT_ROUTILINE_DESC"] = "Enable or Disable the outline for right text."
	
	Loc ["STRING_OPTIONS_TEXT_LCLASSCOLOR"] = "Left Text Color By Class"
	Loc ["STRING_OPTIONS_TEXT_LCLASSCOLOR_DESC"] = "When enabled, the left text uses the class color of the character.\n\nIf disabled, choose the color on the color picker button."
	
	Loc ["STRING_OPTIONS_TEXT_RCLASSCOLOR"] = "Right Text Color By Class"
	Loc ["STRING_OPTIONS_TEXT_RCLASSCOLOR_DESC"] = "When enabled, the right text uses the class color of the character.\n\nIf disabled, choose the color on the color picker button."
	--
	Loc ["STRING_OPTIONS_INSTANCE"] = "Instance Settings"
	Loc ["STRING_OPTIONS_INSTANCE_DESC"] = "This options control the appearance of the instance it self."
	
	Loc ["STRING_OPTIONS_INSTANCE_COLOR"] = "Color"
	Loc ["STRING_OPTIONS_INSTANCE_COLOR_DESC"] = "Change the color of instance window."
	
	Loc ["STRING_OPTIONS_INSTANCE_ALPHA"] = "Alpha"
	Loc ["STRING_OPTIONS_INSTANCE_ALPHA_DESC"] = "This option let you change the color and transparency of instance window background."
	
	Loc ["STRING_OPTIONS_INSTANCE_CURRENT"] = "Auto Switch To Current"
	Loc ["STRING_OPTIONS_INSTANCE_CURRENT_DESC"] = "Whenever a combat start and there is no other instance on current segment, this instance auto switch to current segment."

	Loc ["STRING_OPTIONS_INSTANCE_SKIN"] = "Skin"
	Loc ["STRING_OPTIONS_INSTANCE_SKIN_DESC"] = "Modify all window textures based on a skin theme."
	
	Loc ["STRING_OPTIONS_WP"] = "Wallpaper Settings"
	Loc ["STRING_OPTIONS_WP_DESC"] = "This options control the wallpaper of instance."
	
	Loc ["STRING_OPTIONS_WP_ENABLE"] = "Show"
	Loc ["STRING_OPTIONS_WP_ENABLE_DESC"] = "Enable or Disable the wallpaper of the instance.\n\nSelect the category and the image you want on the two following boxes."
	
	Loc ["STRING_OPTIONS_WP_GROUP"] = "Category"
	Loc ["STRING_OPTIONS_WP_GROUP_DESC"] = "In this box, you select the group of the wallpaper, the images of this category can be chosen on the next dropbox."
	
	Loc ["STRING_OPTIONS_WP_GROUP2"] = "Wallpaper"
	Loc ["STRING_OPTIONS_WP_GROUP2_DESC"] = "Select the wallpaper, for more, choose a diferent category on the left dropbox."
	
	Loc ["STRING_OPTIONS_WP_ALIGN"] = "Align"
	Loc ["STRING_OPTIONS_WP_ALIGN_DESC"] = "Select how the wallpaper will align within the window instance.\n\n- |cFFFFFFFFFill|r: auto resize and align with all corners.\n\n- |cFFFFFFFFCenter|r: doesn`t resize and align with the center of the window.\n\n-|cFFFFFFFFStretch|r: auto resize on vertical or horizontal and align with left-right or top-bottom sides.\n\n-|cFFFFFFFFFour Corners|r: align with specified corner, no auto resize is made."
	
	Loc ["STRING_OPTIONS_WP_EDIT"] = "Edit Image"
	Loc ["STRING_OPTIONS_WP_EDIT_DESC"] = "Open the image editor to change some wallpaper aspects."

	Loc ["STRING_OPTIONS_SAVELOAD"] = "Save and Load"
	Loc ["STRING_OPTIONS_SAVELOAD_DESC"] = "This options allow you to save or load predefined settings."
	
	Loc ["STRING_OPTIONS_SAVELOAD_PNAME"] = "Preset Name"
	Loc ["STRING_OPTIONS_SAVELOAD_SAVE"] = "save"
	Loc ["STRING_OPTIONS_SAVELOAD_LOAD"] = "load"
	Loc ["STRING_OPTIONS_SAVELOAD_REMOVE"] = "x"
	Loc ["STRING_OPTIONS_SAVELOAD_RESET"] = "reset to default"
	Loc ["STRING_OPTIONS_SAVELOAD_APPLYTOALL"] = "apply to all instances"


-- Mini Tutorials -----------------------------------------------------------------------------------------------------------------

	Loc ["STRING_MINITUTORIAL_1"] = "Botao de Instancias:\n\nClique para abrir uma nova janela do Details!.\n\nPasse o mouse sobre o botao para reabrir janelas fechadas."
	Loc ["STRING_MINITUTORIAL_2"] = "Botao de Esticar:\n\nClique, segure e puxe para esticar a janela.\n\nSolte o botao para a janela retornar ao tamanho normal."
	Loc ["STRING_MINITUTORIAL_3"] = "Redimencionar e Trancar:\n\nUse este botao para mudar o tamanho da janela.\n\nTrancando ela, impede que a janela seja movida."
	Loc ["STRING_MINITUTORIAL_4"] = "Painel de Atalhos:\n\nClicando com o botao direito sobre uma barra ou no fundo da janela, o painel de atalho eh mostrado."
	Loc ["STRING_MINITUTORIAL_5"] = "Micro Displays:\n\nMostram informacoes importantes a voce.\n\nBotao esquerdo para configura-las.\n\nBotao direito para escolhar outra informacao."
	Loc ["STRING_MINITUTORIAL_6"] = "Juntar Janelas:\n\nMova uma janela proxima a outra para junta-las.\n\nSempre junte janelas com o numero anterior, exemplo: #5 junta com a #4, #2 junta com a #1, etc."