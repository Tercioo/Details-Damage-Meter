local Loc = LibStub("AceLocale-3.0"):NewLocale("Details", "ptBR") 
if not Loc then return end 

--------------------------------------------------------------------------------------------------------------------------------------------

	Loc ["STRING_VERSION_LOG"] = "|cFFFFFF00v1.6.7|r\n\n- Adicionado suporte a skins, troque ela atraves do painel de opcoes.\n\n|cFFFFFF00v1.6.5|r\n\n|cFFFFFF00-|r Adicionado o sub atributo 'Inimigos' que mostra, eh claro, somente inimigos.\n\n|cFFFFFF00-|r Corrigido um problema na captura das magias conjuradas.|cFFFFFF00v1.6.3|r\n\n|cFFFFFF00-|r captura de dados agora roda 4% mais rapido.\n\n|cFFFFFF00-|r Corrigido problema onde os ajudantes nao atualizavam o tempo de atividade do dono.\n\n|cFFFFFF00-|r Corrigido problema onde o healing era contado mesmo fora do combate.\n\n|cFFFFFF00-|r Corrigido problema com chefes multiplos como Twin Consorts.\n\n|cFFFFFF00-|r Adicionada opcao para juntar os segmentos de trash mobs.\n\n|cFFFFFF00-|r Adicionada opcao para auto remover os segmentos de trash mobs. \n\n|cFFFFFF00-|r Adicionada opcao para alterar a altura das barras.\n\n|cFFFFFF00-|r Plugin Encounter Details agora mostra quantos cast bem sucedidos as magias interrompidas tiveram.\n\n|cFFFFFF00v1.6.1|r\n\n|cFFFFFF00-|r Corrigido:\n- problema com o tempo de debuffs.\n- dps dos dados gerais e o dps no micro display .\n- varios bugs envolvendo o menu da espada e do livro.\n- o coletor de lixo nao ira mais apagar jogadores com vinculo a membros do grupo.\n\n|cFFFFFF00-|r dados gerais agora sempre ira usar o tempo do combate para medir dps e hps.\n\n|cFFFFFF00v1.6.0|r\n\n|cFFFFFF00-|r Adicionado tempo de debuff no atributo miscelanea.\n\n|cFFFFFF00-|r Atributos desativados agora ficam escurecidos no menu da espada.\n\n|cFFFFFF00-|r Corrigido um problema aonde algumas vezes era necessario dar /reload para trocar um talento.\n\n|cFFFFFF00v1.5.3|r\n\n|cFFFFFF00-|r Corrigido problema ao reportar durante o combate.\n\n|cFFFFFF00-|r Melhorado a reconhecimento dos donos de ajudantes.\n\n|cFFFFFF00-|r Adicionada uma opcao para mostrar apenas frags em cima de jogadores inimigos.\n\n|cFFFFFF00-|r Adicionado cor e icone aos frags.\n\n|cFFFFFF00v1.5.2|r\n\n|cFFFFFF00-|r Corrigido problema onde desativando o tempo dos buffs estava desativando tambem a cura feita.\n\n|cFFFFFF00-|r Estatisticas de Avoidance nao seram mais capturadas para pessoas foram do grupo, monstros ou ajudantes.\n\n|cFFFFFF00-|r Corrigido problema onde as vezes estava demorando muito para salvar o tempo dos buffs ao sair do jogo.\n\n|cFFFFFF00v1.5.1|r\n\n|cFFFFFF00-|r Corrigido problema ao reportar o Dps onde as vezes nao mostrava nenhum jogador.\n\n|cFFFFFF00v1.5.0|r\n\n|cFFFFFF00-|r Buff Uptime foi implementado no atributo miscelanea.\n\n|cFFFFFF00-|r Cooldowns usados agora aparecem nos registros da morte.\n\n|cFFFFFF00-|r Implementado esta janela mostrando as atualizacoes.\n\n|cFFFFFF00-|r Corrigido problema onde algumas vezes clicando no nome do atributo fazia a instancia parar de atualizar.\n\n|cFFFFFF00-|r Desativando a cura agora para as absorcoes tambem. Desligando as Auras nao interrompe as absorcoes. \n\n|cFFFFFF00-|r Fogo Amigo agora conta apenas jogadores dentro do grupo.\n\n|cFFFFFF00-|r Corrigido problema onde o dano feito por um ajudando nao estava contando no alvo do dono.\n\n|cFFFFFF00-|r Corrigido problema onde a atualizacao de um cooldown nao estava sendo contada.\n\n|cFFFFFF00-|r Adicionada as magias de absorcao para 2P tier 16.\n\n|cFFFFFF00-|r Adicionado os comandos de barra 'worldboss' e 'updates'.\n\n|cFFFFFF00-|r Corrigido problema ao reportar onde algumas vezes nao estava funcionando."

	Loc ["STRING_DETAILS1"] = "|cffffaeaeDetalhes:|r " --> color and details name

	Loc ["STRING_YES"] = "Sim"
	Loc ["STRING_NO"] = "Nao"
	
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
		Loc ["STRING_DAMAGE_TAKEN_FROM"] = "Dano Recebido Vindo De"
		Loc ["STRING_DAMAGE_TAKEN_FROM2"] = "aplicou dano com"
		Loc ["STRING_ATTRIBUTE_DAMAGE_FRIENDLYFIRE"] = "Fogo Amigo"
		Loc ["STRING_ATTRIBUTE_DAMAGE_FRAGS"] = "Inimigos Abatidos"
		Loc ["STRING_ATTRIBUTE_DAMAGE_ENEMIES"] = "Inimigos"
		
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
	--Loc ["STRING_REPORT_FRAG"] = 
	
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
