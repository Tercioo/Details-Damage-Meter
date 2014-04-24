local Loc = LibStub("AceLocale-3.0"):NewLocale("Details", "ptBR") 
if not Loc then return end 

--------------------------------------------------------------------------------------------------------------------------------------------

	Loc ["STRING_VERSION_LOG"] = "|cFFFFFF00v1.13.0|r\n\n|cFFFFFF00-|r Added four more abbreviation types.\n\n|cFFFFFF00-|r Fixed issue where the instance menu wasnt respecting the amount limit of instances.\n\n|cFFFFFF00-|r Added options for cutomize the right text of a row.\n\n|cFFFFFF00-|r Added a option to be able to chance the framestrata of an window.\n\n|cFFFFFF00-|r Added shift, ctrl, alt interaction for rows which shows all spells, targets or pets when pressed.\n\n|cFFFFFF00-|r Fixed a issue where changing the alpha of a window makes it disappear on the next logon.\n\n|cFFFFFF00-|r Added a option for auto transparency to ignore rows.\n\n|cFFFFFF00-|r Added option to be able to set shadow on the attribute text.\n\n|cFFFFFF00-|r Fixed a issue with window snap where disabled statusbar makes a gap between the windows.\n\n|cFFFFFF00-|r Added a hidden menu on the top left corner (experimental).\n\n|cFFFFFF00v1.12.3|r\n\n|cFFFFFF00-|r - Fixed 'Healing Per Second' which wasn't working at all.\n\n|cFFFFFF00-|r - Fixed the percent amount for target of damage done where sometimes it pass 100%.\n\n|cFFFFFF00-|r - Changes on Skins: Minimalistic and Elm UI Frame Style. Its necessary re-apply.\n\n|cFFFFFF00-|r - Added more cooldowns and spells for Monk tank over avoidance panel.\n\n|cFFFFFF00-|r - Player avatar now is also shown on the Player Details window.\n\n|cFFFFFF00-|r - Leaving empty the the icon file box, make details use no icons on bars.\n\n|cFFFFFF00-|r - Added new feature: Auto Transparency, hide or show menus, statusbar and borders when mouse enter or leaves the window.\n\n|cFFFFFF00-|r - Added new feature: Attribute Text, shows on the toolbar or statusbar the current attribute shown.\n\n|cFFFFFF00-|r - Added new fueature: Auto Hide Menu, which hide or show the menus when mouse enter or leaves the window.\n\n|cFFFFFF00-|r - Image Editor now can Flip the image without messing with the crop.\n\n|cFFFFFF00v1.12.0|r\n\n|cFFFFFF00-|r Added support to Profiles, now you can share the same config between two or more characters.\n\n|cFFFFFF00-|r - Options window now can be opened while in combat without triggering 'script ran too long' error.\n\n|cFFFFFF00-|r Added support for BattleTag friends over report window.\n\n|cFFFFFF00-|r Added pet threat to Tiny Threat plugin when out of a party or raid group.\n\n|cFFFFFF00-|r Fixed a issue with close button where it disappear without close the window when toolbar is in bottom side.\n\n|cFFFFFF00-|r Also fixed a issue where swapping toolbar positioning was sometimes making close button disappear.\n\n|cFFFFFF00-|r Fixed a problem opening options panel through minimap when there is no window opened.\n\n|cFFFFFF00v1.11.10|r\n\n|cFFFFFF00-|r Accuracy with warcraftlogs.com now is very high and okey with worldoflogs.com. Make sure the option |cFFFFDD00Time Measure|r under General Settings -> Combat is set to |cFFFFDD00Effective Time|r.\n\n|cFFFFFF00-|r Options Window has been revamped, again.\n\n|cFFFFFF00-|r Added a option for change the class icons.\n\n|cFFFFFF00-|r Added options for show Total Bar and configure it.\n\n|cFFFFFF00-|r Added a option for save a Standard Skin, new windows opened use this skin.\n\n|cFFFFFF00-|r Added a new skin: ElvUI Frame Style.\n\n|cFFFFFF00-|r When hover a spell icon under Player Details Window, the spell description is shown.\n\n|cFFFFFF00-|r Pressing Shift key on a spell bar over the Encounter Details Window, shows up the spell description.\n\n|cFFFFFF00v1.11.6|r\n\n|cFFFFFF00-|r Adicionado nova skin: Minimalistic.\n\n|cFFFFFF00-|r Adicionado nova aba chamada avoidance no painel de detalhes do jogador apenas para tanques.\n\n|cFFFFFF00-|r Adicionado opcao de Copiar e Coloar na janela de criar relatorios. Agora voce pode dizer seu dps aos seus amigos no twitter e facebook!\n\n|cFFFFFF00-|r Adicionada nova opcao de troca o que uma janela esta mostrando quando voce entrar em combate.\n\n|cFFFFFF00-|r Corrigido problema com a transparencia da janela onde ela mudava sozinha sempre que a janela de opcoes eta aberta.\n\n|cFFFFFF00-|r Corrigido o vao em branco que ficava entre o inicio de uma barra e o fundo da janela quando as bordas eram desligadas.\n\n|cFFFFFF00-|r Feito algumas melhorias no plugin Tiny Threat.\n\n|cFFFFFF00v1.11.3|r\n\n|cFFFFFF00-|r Corrigido mais problemas conhecidos com as Skins.\n\n|cFFFFFF00-|r Corrigido problema onde os icones dos plugins nao eram escondidos apos fechar todas as janelas.\n\n|cFFFFFF00v1.11.2|r\n\n|cFFFFFF00-|r Corrigido problemas onde o Details! parava de funcionar se nenhum plugin estiver ligado no painel de addons do Wow.|cFFFFFF00v1.11.0|r\n\n|cFFFFFF00-|r Adicionado opcao para abreviar o Dps e o Hps.\n\n|cFFFFFF00-|r Corrigido um problema onde o icone da janela desaparecia ao reabri-la.\n\n|cFFFFFF00-|r Melhorias no reconhecimento das classes.\n\n|cFFFFFF00-|r As seguintes magias foram adicionadas como cooldowns: Healing Tide Totem, Spirit Link Totem, Demoralizing Banner, Mass Spell Reflection and Shield Block.\n\n|cFFFFFF00-|r Mais melhorias feitas no plugin Encounter Details.\n\n|cFFFFFF00-|r Melhorias feitas nos plugins disponiveis para download: Timeline e Advanced Death Logs.\n\n|cFFFFFF00v1.10.0|r\n\n|cFFFFFF00-|r Corrigido um problema no Dps no segmento total quando existia apenas 1 segmento.\n\n|cFFFFFF00-|r Cores e imagem de fundo dos menus foram alterados.\n\n|cFFFFFF00-|r A altura do painel de opcoes foi aumentada.\n\n|cFFFFFF00-|r Adicionada opcao para esconder ou alterar a transparencia da janela quando estiver em combate.\n\n|cFFFFFF00-|r Adicionado um painel de controle de plugins para ativar ou desativa-los.\n\n|cFFFFFF00v1.9.5|r\n\n|cFFFFFF00-|rMais correcoes para as Skins e suporte a novos plugins.|r\n\n|cFFFFFF00v1.9.4|r\n\n|cFFFFFF00-|r Pequenas correcoes e melhorias na tela de boas vindas.\n\n|cFFFFFF00v1.9.3|r\n\n|cFFFFFF00-|r A barra agora comeca apos o icone e nao mais na borda esquerda da janela.\n\n|cFFFFFF00-|r Janela de boas vindas agora esta traduzida para outros idiomas.\n\n|cFFFFFF00-|r Corrigido o problema que estava afetando o plugin de Rank de Dano.\n\n|cFFFFFF00v1.9.1|r\n\n|cFFFFFF00-|r corrigido problema do icone na janela principal quando nao havia nenhum plugin instalado. \n\n|cFFFFFF00-|r corrigido problema com alguns botoes no painel de opcoes onde o texto estava fora do lugar.\n\n|cFFFFFF00-|r corrigido a posicao dos sub menus quando proximos a borda direita do monitor.\n\n|cFFFFFF00-|r corrigida a posicao do botao de fechar do skin padrao.\n\n|cFFFFFF00-|r corrigido um erro nas skins ao selecionar um plugin de raide ou solo.|cFFFFFF00v1.9.0|r\n\n|cFFFFFF00-|r Corrigido o problema de nao movimentar o botao no minimapa.\n\n|cFFFFFF00-|r Suporte a skins foi reescrito e agora ficou mais flexivel.\n\n|cFFFFFF00-|r Adicionadas mais de 20 opcoes de customizacao no painel de opcoes."

	Loc ["STRING_DETAILS1"] = "|cffffaeaeDetalhes:|r " --> color and details name

	Loc ["STRING_YES"] = "Sim"
	Loc ["STRING_NO"] = "Nao"
	
	Loc ["STRING_TOP"] = "topo"
	Loc ["STRING_BOTTOM"] = "baixo"
	Loc ["STRING_AUTO"] = "auto"
	Loc ["STRING_LEFT"] = "esquerda"
	Loc ["STRING_CENTER"] = "centro"
	Loc ["STRING_RIGHT"] = "direita"
	
	Loc ["STRING_MINIMAP_TOOLTIP1"] = "|cFFCFCFCFbotao esquerdo|r: abrir o painel de opcoes"
	Loc ["STRING_MINIMAP_TOOLTIP2"] = "|cFFCFCFCFbotao direito|r: menu rapido"
	
	Loc ["STRING_MINIMAPMENU_NEWWINDOW"] = "Criar Nova Janela"
	Loc ["STRING_MINIMAPMENU_RESET"] = "Resetar"
	Loc ["STRING_MINIMAPMENU_REOPEN"] = "Reabrir Janela"
	Loc ["STRING_MINIMAPMENU_REOPENALL"] = "Reabrir Todas"
	Loc ["STRING_MINIMAPMENU_UNLOCK"] = "Destravar"
	Loc ["STRING_MINIMAPMENU_LOCK"] = "Travar"
	
	Loc ["STRING_RESETBUTTON_WRONG_INSTANCE"] = "Aviso, o botao de reset nao esta na janela que esta sendo editada."
	
	Loc ["STRING_INTERFACE_OPENOPTIONS"] = "Abrir Painel de Opcoes"
	
	Loc ["STRING_RIGHTCLICK_TYPEVALUE"] = "botao direito para digitar o valor"
	Loc ["STRING_TOOOLD"] = "nao pode ser instalado pois sua versao do Details! e muito antiga."
	Loc ["STRING_TOOOLD2"] = "a sua versao do Details! nao e a mesma."
	Loc ["STRING_CHANGED_TO_CURRENT"] = "Segmento trocado para atual"
	Loc ["STRING_SEGMENT_TRASH"] = "Caminho do Proximo Boss"
	Loc ["STRING_VERSION_UPDATE"] = "nova versao: clique para ver o que mudou"
	Loc ["STRING_NEWS_TITLE"] = "Quais As Novidades Desta Versao"
	Loc ["STRING_NEWS_REINSTALL"] = "Encontrou problemas apos atualizar? tente o comando '/details reinstall'."
	Loc ["STRING_TIME_OF_DEATH"] = "Morreu"
	Loc ["STRING_SHORTCUT_RIGHTCLICK"] = "Menu de Atalho (botao direito para fechar)"
	
	Loc ["STRING_NO_DATA"] = "data já foi limpada"
	Loc ["STRING_ISA_PET"] = "Este Ator e um Ajudante"
	Loc ["STRING_EQUILIZING"] = "Comparilhando dados"
	Loc ["STRING_LEFT_CLICK_SHARE"] = "Clique para enviar relatorio."
	
	Loc ["STRING_REPORT_BUTTON_TOOLTIP"] = "Clique para abrir a Caixa de Relatorios."
	
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
	
	Loc ["STRING_SLASH_WIPECONFIG"] = "reinstalar"
	Loc ["STRING_SLASH_WIPECONFIG_DESC"] = "faz a reinstalacao do addon limpando toda a configuracao, use caso o Details! nao esteja funcionando corretamente."
	Loc ["STRING_SLASH_WIPECONFIG_CONFIRM"] = "Continuar com a reinstalacao?."
	
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
	Loc ["STRING_REPORTFRAME_COPY"] = "Copiar e Colar"
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

	Loc ["STRING_MUSIC_DETAILS_ROBERTOCARLOS"] = "Nao adianta nem tentar me esquecer\nDurante muito tempo em sua vida eu vou viver\n Detalhes tao pequenos de nos dois"

	Loc ["STRING_OPTIONS_SWITCHINFO"] = "|cFFF79F81 ESQUERDA DESATIVADO|r  |cFF81BEF7 DIREITA ATIVADO|r"
	
	Loc ["STRING_OPTIONS_PICKCOLOR"] = "cor"
	Loc ["STRING_OPTIONS_EDITIMAGE"] = "Editar Imagem"
	
	Loc ["STRING_OPTIONS_PRESETTOOLD"] = "Esta predefinicao requer uma versao atualizada do Details!."
	Loc ["STRING_OPTIONS_PRESETNONAME"] = "De um nome a sua predefinicao."
	
	Loc ["STRING_OPTIONS_EDITINSTANCE"] = "Editando a Instancia:"
	
	Loc ["STRING_OPTIONS_GENERAL"] = "Configuracoes Gerais"
	Loc ["STRING_OPTIONS_APPEARANCE"] = "Aparencia"
	Loc ["STRING_OPTIONS_PERFORMANCE"] = "Performance"
	Loc ["STRING_OPTIONS_PLUGINS"] = "Plugins"
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
	Loc ["STRING_OPTIONS_MINIMAP"] = "Icone no Mini Mapa"
	Loc ["STRING_OPTIONS_MINIMAP_DESC"] = "Mostra ou esconde o icone no mini mapa."
	Loc ["STRING_OPTIONS_TIMEMEASURE"] = "Medidas do Tempo"
	Loc ["STRING_OPTIONS_TIMEMEASURE_DESC"] = "|cFFFFFFFFTempo de Atividade|r: o tempo de cada membro da raide eh posto em pausa quando ele ficar ocioso e volta a contar o tempo quando ele voltar a atividade, eh a maneira mais comum de medir o Dps e Hps.\n\n|cFFFFFFFFTempo Efetivo|r: muito usado para ranqueamentos, este metodo usa o tempo total da luta para medir o Dps e Hps de todos os membros da raide."
	Loc ["STRING_OPTIONS_HIDECOMBAT"] = "Esconder no Combate"
	Loc ["STRING_OPTIONS_HIDECOMBAT_DESC"] = "Se ativada, a janela desta instancia ficara oculta quando voce entrar em combate."
	Loc ["STRING_OPTIONS_HIDECOMBATALPHA"] = "Transparencia"
	Loc ["STRING_OPTIONS_HIDECOMBATALPHA_DESC"] = "A janela pode ser completamente escondida ou apenas ficar mais transparente."
	Loc ["STRING_OPTIONS_PS_ABBREVIATE"] = "PS Abreviacao"
	Loc ["STRING_OPTIONS_PS_ABBREVIATE_DESC"] = "Escolha o metodo de abreviacao para o Dps e Hps.\n\n|cFFFFFFFFNenhuma|r: sem abreviacao, o numero inteiro e mostrado.\n\n|cFFFFFFFFCem I|r: o numero e reduzido e uma letra indica o valor.\n\n59874 = 59.8K\n100.000 = 100.0K\n19.530.000 = 19.53M\n\n|cFFFFFFFFHundreds II|r: o numero e reduzido e uma letra indica o valor.\n\n59874 = 59.8K\n100.000 = 100K\n19.530.000 = 19.53M"
	Loc ["STRING_OPTIONS_AUTO_SWITCH"] = "Troca Automatica"
	Loc ["STRING_OPTIONS_AUTO_SWITCH_DESC"] = "Quando voce entra em combate, esta janela mudara o atributo mostrado para outro atributo ou plugin.\n\nSaindo do combate o atributo antigo volta a ser mostrado."
	Loc ["STRING_OPTIONS_PS_ABBREVIATE_NONE"] = "Nenhuma"
	Loc ["STRING_OPTIONS_PS_ABBREVIATE_TOK"] = "Cem I"
	Loc ["STRING_OPTIONS_PS_ABBREVIATE_TOK2"] = "Cem II"
	
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
	
	
	Loc ["STRING_OPTIONS_BARS"] = "Configuracoes das Barras"
	Loc ["STRING_OPTIONS_BARS_DESC"] = "Estas opcoes controlam a aparencia das barra da janela."

	Loc ["STRING_OPTIONS_BAR_TEXTURE"] = "Textura"
	Loc ["STRING_OPTIONS_BAR_TEXTURE_DESC"] = "Esta opcao altera a textura superior das barras."
	
	Loc ["STRING_OPTIONS_BAR_BTEXTURE"] = "Textura de Fundo"
	Loc ["STRING_OPTIONS_BAR_BTEXTURE_DESC"] = "Altere a textura do fundo da barra, lembre-se de alterar a cor da textura e diminuir sua transparencia."
	
	Loc ["STRING_OPTIONS_BAR_BCOLOR"] = "Cor da Textura de Fundo"
	Loc ["STRING_OPTIONS_BAR_BCOLOR_DESC"] = "Escolha a cor que a textura do fundo da barra tera, no painel, ha um controle de transparencia, nao esqueca de alterar."
	
	Loc ["STRING_OPTIONS_BAR_HEIGHT"] = "Altura"
	Loc ["STRING_OPTIONS_BAR_HEIGHT_DESC"] = "Altera a altura das barras."
	
	Loc ["STRING_OPTIONS_BAR_COLORBYCLASS"] = "Cor da Classe"
	Loc ["STRING_OPTIONS_BAR_COLORBYCLASS_DESC"] = "Quando ativada, as barras aplicam a cor da classe do personagem na textura superior.\n\nQuando desligado, a barra ira utilizar a cor fixa determinada na caixa a direita."
	
	Loc ["STRING_OPTIONS_BAR_COLORBYCLASS2"] = "Cor da Classe (fundo)"
	Loc ["STRING_OPTIONS_BAR_COLORBYCLASS2_DESC"] = "Quando ativada, as barras aplicam a cor da classe do personagem na textura de fundo.\n\nQuando desligado, a barra ira utilizar a cor fixa determinada na caixa a direita."
	--
	Loc ["STRING_OPTIONS_TEXT"] = "Opcoes dos Textos das Barras"
	Loc ["STRING_OPTIONS_TEXT_DESC"] = "Os ajustes abaixo personalizam os textos mostrados nas barras."
	
	Loc ["STRING_OPTIONS_TEXT_SIZE"] = "Tamanho"
	Loc ["STRING_OPTIONS_TEXT_SIZE_DESC"] = "Altera o tamanho da fonte do texto."
	
	Loc ["STRING_OPTIONS_TEXT_FONT"] = "Font"
	Loc ["STRING_OPTIONS_TEXT_FONT_DESC"] = "Modifica a fonte do texto usado nas barras."
	
	Loc ["STRING_OPTIONS_TEXT_LOUTILINE"] = "Sombra do Texto Esquerdo"
	Loc ["STRING_OPTIONS_TEXT_LOUTILINE_DESC"] = "Quando ativado o texto esquerdo ganhara um efeito de sombra ao seu redor."
	
	Loc ["STRING_OPTIONS_TEXT_ROUTILINE"] = "Sombra do Texto Direito"
	Loc ["STRING_OPTIONS_TEXT_ROUTILINE_DESC"] = "Quando ativado o texto da direita ganhara um efeito de sombra ao seu redor."
	
	Loc ["STRING_OPTIONS_TEXT_LCLASSCOLOR"] = "Texto Esquerdo Cor da Classe"
	Loc ["STRING_OPTIONS_TEXT_LCLASSCOLOR_DESC"] = "Quando ativado a cor do texto esquerdo sera automaticamento ajustado para a cor da classe do personagem mostrado.\n\nQuando desligado a cor na caixa a direita eh usado."
	
	Loc ["STRING_OPTIONS_TEXT_RCLASSCOLOR"] = "Texto Direito Cor da Classe"
	Loc ["STRING_OPTIONS_TEXT_RCLASSCOLOR_DESC"] = "Quando ativado a cor do texto da direita sera automaticamento ajustado para a cor da classe do personagem mostrado.\n\nQuando desligado a cor na caixa a direita eh usado."
	--
	Loc ["STRING_OPTIONS_INSTANCE"] = "Configuracoes da Janela"
	Loc ["STRING_OPTIONS_INSTANCE_DESC"] = "Estes ajustes configuram atributos basicos da janela da instancia."
	
	Loc ["STRING_OPTIONS_INSTANCE_COLOR"] = "Cor e Transparencia"
	Loc ["STRING_OPTIONS_INSTANCE_COLOR_DESC"] = "Altera a cor e a transparencia da janela."
	
	Loc ["STRING_OPTIONS_INSTANCE_ALPHA"] = "Transparencia do Fundo"
	Loc ["STRING_OPTIONS_INSTANCE_ALPHA_DESC"] = "Esta opcao altera a transparencia do fundo da janela."
	Loc ["STRING_OPTIONS_INSTANCE_ALPHA2"] = "Cor de Fundo"
	Loc ["STRING_OPTIONS_INSTANCE_ALPHA2_DESC"] = "Seleciona a cor do fundo da janela."
	
	Loc ["STRING_OPTIONS_INSTANCE_CURRENT"] = "Mudar Para Atual"
	Loc ["STRING_OPTIONS_INSTANCE_CURRENT_DESC"] = "Quando qualquer combate comecar e nao ha nenhuma instancia no segmento atual, esta instancia automaticamente troca para o segmento atual."

	Loc ["STRING_OPTIONS_SHOW_SIDEBARS"] = "Mostrar Barras Laterais"
	Loc ["STRING_OPTIONS_SHOW_SIDEBARS_DESC"] = "Mostrar ou esconder as barras laterais na esquerda e direita da janela."
	
	Loc ["STRING_OPTIONS_INSTANCE_SKIN"] = "Pele (skin)"
	Loc ["STRING_OPTIONS_INSTANCE_SKIN_DESC"] = "Modifica todas as texturas e opcoes da janela atraves de um padrao pre definido."
	
	Loc ["STRING_OPTIONS_SKIN_A"] = "Ajustes da Pele (Skin)"
	Loc ["STRING_OPTIONS_SKIN_A_DESC"] = "Estas opcoes alteram as caracteristicas gerais da janela."

	Loc ["STRING_OPTIONS_TOOLBAR_SETTINGS"] = "Ajustes da Barra de Menus"
	Loc ["STRING_OPTIONS_TOOLBAR_SETTINGS_DESC"] = "Estas opcoes lidam com a barra de ferramentas."
		
	Loc ["STRING_OPTIONS_DESATURATE_MENU"] = "Menu em Preto e Branco"
	Loc ["STRING_OPTIONS_DESATURATE_MENU_DESC"] = "Ativando esta opcao o menu na barra de ferramentas torna-se preto e branco."

	Loc ["STRING_OPTIONS_HIDE_ICON"] = "Esconder Icone"
	Loc ["STRING_OPTIONS_HIDE_ICON_DESC"] = "Quando ativado, o icone do atributo na barra de ferramentas eh escondido."

	Loc ["STRING_OPTIONS_MENU_X"] = "Posicao X Do Menu"
	Loc ["STRING_OPTIONS_MENU_X_DESC"] = "Move a barra de menus para a esquerda ou direita no eixo horizontal."

	Loc ["STRING_OPTIONS_MENU_Y"] = "Posicao Y Do Menu"
	Loc ["STRING_OPTIONS_MENU_Y_DESC"] = "Move a barra de menus para cima ou para baixo no eixo vertical."

	Loc ["STRING_OPTIONS_RESET_TEXTCOLOR"] = "Cor do Texto (reset)"
	Loc ["STRING_OPTIONS_RESET_TEXTCOLOR_DESC"] = "Muda a cor do texto do botao de reset.\n\nO botao de reset eh apenas mostrado na janela 'mais baixa' (com o menor numero)."

	Loc ["STRING_OPTIONS_RESET_TEXTFONT"] = "Fonte do Texto (reset)"
	Loc ["STRING_OPTIONS_RESET_TEXTFONT_DESC"] = "Muda a fonte do texto do botao de reset.\n\nO botao de reset eh apenas mostrado na janela 'mais baixa' (com o menor numero)."

	Loc ["STRING_OPTIONS_RESET_TEXTSIZE"] = "Tamanho do Texto (reset)"
	Loc ["STRING_OPTIONS_RESET_TEXTSIZE_DESC"] = "Muda o tamanho do texto do botao de reset.\n\nO botao de reset eh apenas mostrado na janela 'mais baixa' (com o menor numero)."

	Loc ["STRING_OPTIONS_RESET_OVERLAY"] = "Overlay (reset)"
	Loc ["STRING_OPTIONS_RESET_OVERLAY_DESC"] = "Altera a cor do botao de reset.\n\nO botao de reset eh apenas mostrado na janela 'mais baixa' (com o menor numero)."

	Loc ["STRING_OPTIONS_RESET_SMALL"] = "Reset Sempre Pequeno"
	Loc ["STRING_OPTIONS_RESET_SMALL_DESC"] = "O botao de reset sempre sera mostrado na sua versao pequena.\n\nO botao de reset eh apenas mostrado na janela 'mais baixa' (com o menor numero)."

	Loc ["STRING_OPTIONS_INSTANCE_TEXTCOLOR"] = "Cor do Texto (instancia)"
	Loc ["STRING_OPTIONS_INSTANCE_TEXTCOLOR_DESC"] = "Altera a cor do texto no botao da instancia."

	Loc ["STRING_OPTIONS_INSTANCE_TEXTFONT"] = "Fonte do Texto (instancia)"
	Loc ["STRING_OPTIONS_INSTANCE_TEXTFONT_DESC"] = "Altera a fonte do texto no botao da instancia."

	Loc ["STRING_OPTIONS_INSTANCE_TEXTSIZE"] = "Tamanho do Texto (instancia)"
	Loc ["STRING_OPTIONS_INSTANCE_TEXTSIZE_DESC"] = "Altera o tamanho do texto no botao da instancia."

	Loc ["STRING_OPTIONS_INSTANCE_OVERLAY"] = "Overlay (instancia)"
	Loc ["STRING_OPTIONS_INSTANCE_OVERLAY_DESC"] = "Altera a cor do botao da instancia."

	Loc ["STRING_OPTIONS_CLOSE_OVERLAY"] = "Cor do Botao de Fechar"
	Loc ["STRING_OPTIONS_CLOSE_OVERLAY_DESC"] = "Modifica a cor do botao de fechar."

	Loc ["STRING_OPTIONS_STRETCH"] = "Posicao do Botao de Esticar"
	Loc ["STRING_OPTIONS_STRETCH_DESC"] = "Modifica a posicao do botao de esticar, ele pode ser mostrado em:\n\nTopo: o pegador eh mostrado logo acima do botao da instancia e do botao de fechar.\n\nBaixo: mostrado na parte central e inferior da janela."

	Loc ["STRING_OPTIONS_PICONS_DIRECTION"] = "Direcao dos Icones dos Plugins"
	Loc ["STRING_OPTIONS_PICONS_DIRECTION_DESC"] = "Altera o lado que os icones dos plugins serao mostrados na barra de ferramentas."

	Loc ["STRING_OPTIONS_INSBUTTON_X"] = "Eixo X Botao da Instancia"
	Loc ["STRING_OPTIONS_INSBUTTON_X_DESC"] = "Move o botao da instancia para a esquerda ou direita."

	Loc ["STRING_OPTIONS_INSBUTTON_Y"] = "Eixo Y Botao da Instancia"
	Loc ["STRING_OPTIONS_INSBUTTON_Y_DESC"] = "Move o botao da instancia para cima ou para baixo."

	Loc ["STRING_OPTIONS_TOOLBARSIDE"] = "Posicao Barra de Ferramentas"
	Loc ["STRING_OPTIONS_TOOLBARSIDE_DESC"] = "Altera aonde sera mostrada a barra de ferramentas, ela pode ser mostrada no topo da janela ou na parte inferior."

	Loc ["STRING_OPTIONS_BARGROW_DIRECTION"] = "Direcao de Crescimento"
	Loc ["STRING_OPTIONS_BARGROW_DIRECTION_DESC"] = "Altera a posicao em que as barras comecam a serem mostradas, de cima da janela para baixo ou de baixo da janela para cima."

	Loc ["STRING_OPTIONS_BARSORT_DIRECTION"] = "Ordem das Barras"
	Loc ["STRING_OPTIONS_BARSORT_DIRECTION_DESC"] = "Altera como as barras sao preenchidas, crescente ou decrescente, mas ainda mostrando sempre os primeiros colocados."
		
	Loc ["STRING_OPTIONS_WP"] = "Papel de Parede"
	Loc ["STRING_OPTIONS_WP_DESC"] = "Estas opcoes controlam o papel de parede que eh mostrado no fundo da janela."
	
	Loc ["STRING_OPTIONS_WP_ENABLE"] = "Ativar/Desativar"
	Loc ["STRING_OPTIONS_WP_ENABLE_DESC"] = "Liga ou desliga o papel de parede.\n\nVoce pode escolher qual papel de parede voce deseja usar nas caixas abaixo."
	
	Loc ["STRING_OPTIONS_WP_GROUP"] = "Categoria"
	Loc ["STRING_OPTIONS_WP_GROUP_DESC"] = "Nesta caixa, selecione o tipo do papel de parede, apos selecionar, a caixa a direita ira mostrar as opcoes da categoria escolhida."
	
	Loc ["STRING_OPTIONS_WP_GROUP2"] = "Papel de Parede"
	Loc ["STRING_OPTIONS_WP_GROUP2_DESC"] = "Selecione qual voce deseja colocar no fundo da janela, para mais opcoes troque de categoria na caixa da esquerda."
	
	Loc ["STRING_OPTIONS_WP_ALIGN"] = "Alinhamento"
	Loc ["STRING_OPTIONS_WP_ALIGN_DESC"] = "Selecione como o papel de parede sera alinhado com a janela.\n\n- |cFFFFFFFFPreencher|r: redimenciona e alinha com os quatro cantos da janela.\n\n- |cFFFFFFFFCentralizado|r: nao redimenciona e alinha com o centro da janeça.\n\n-|cFFFFFFFFEsticado|r: redimenciona na vertical ou horizontal e alinha com os cantos da esquerda-direita ou lado superior-inferior.\n\n-|cFFFFFFFFQuatro Laterais|r: alinha com um canto especifico, nao ha redimencionamento automatico."
	
	Loc ["STRING_OPTIONS_WP_EDIT"] = "Editar Imagem"
	Loc ["STRING_OPTIONS_WP_EDIT_DESC"] = "Abre o editor de imagens para alterar os aspectos do papel de parede escolhido."

	Loc ["STRING_OPTIONS_SAVELOAD"] = "Salvar e Carregar"
	Loc ["STRING_OPTIONS_SAVELOAD_DESC"] = "Estas opcoes permitem guardar as configuracoes da janela podendo carrega-las em outros personagens."
	
	Loc ["STRING_OPTIONS_SAVELOAD_PNAME"] = "Nome"
	Loc ["STRING_OPTIONS_SAVELOAD_SAVE"] = "salvar"
	Loc ["STRING_OPTIONS_SAVELOAD_LOAD"] = "carregar"
	Loc ["STRING_OPTIONS_SAVELOAD_REMOVE"] = "x"
	Loc ["STRING_OPTIONS_SAVELOAD_RESET"] = "resetar p/ padroes"
	Loc ["STRING_OPTIONS_SAVELOAD_APPLYTOALL"] = "aplicar em todas as janelas"


-- Mini Tutorials -----------------------------------------------------------------------------------------------------------------

	Loc ["STRING_MINITUTORIAL_1"] = "Botao de Instancias:\n\nClique para abrir uma nova janela do Details!.\n\nPasse o mouse sobre o botao para reabrir janelas fechadas."
	Loc ["STRING_MINITUTORIAL_2"] = "Botao de Esticar:\n\nClique, segure e puxe para esticar a janela.\n\nSolte o botao para a janela retornar ao tamanho normal."
	Loc ["STRING_MINITUTORIAL_3"] = "Redimencionar e Trancar:\n\nUse este botao para mudar o tamanho da janela.\n\nTrancando ela, impede que a janela seja movida."
	Loc ["STRING_MINITUTORIAL_4"] = "Painel de Atalhos:\n\nClicando com o botao direito sobre uma barra ou no fundo da janela, o painel de atalho eh mostrado."
	Loc ["STRING_MINITUTORIAL_5"] = "Micro Displays:\n\nMostram informacoes importantes a voce.\n\nBotao esquerdo para configura-las.\n\nBotao direito para escolhar outra informacao."
	Loc ["STRING_MINITUTORIAL_6"] = "Juntar Janelas:\n\nMova uma janela proxima a outra para junta-las.\n\nSempre junte janelas com o numero anterior, exemplo: #5 junta com a #4, #2 junta com a #1, etc."