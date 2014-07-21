local L = LibStub("AceLocale-3.0"):NewLocale("Details", "ptBR") 
if not L then return end 

--------------------------------------------------------------------------------------------------------------------------------------------
L["ABILITY_ID"] = "id da habilidade"
L["STRING_"] = ""
L["STRING_ABSORBED"] = "Absorvido"
L["STRING_ACTORFRAME_NOTHING"] = "n\195\163o h\195\161 nada para reportar" -- Needs review
L["STRING_ACTORFRAME_REPORTAT"] = "em"
L["STRING_ACTORFRAME_REPORTOF"] = "de"
L["STRING_ACTORFRAME_REPORTTARGETS"] = "relat\195\179rio para os alvos de" -- Needs review
L["STRING_ACTORFRAME_REPORTTO"] = "relat\195\179rio para" -- Needs review
L["STRING_ACTORFRAME_SPELLDETAILS"] = "detalhes da habilidade"
L["STRING_ACTORFRAME_SPELLUSED"] = "Todas as habilidades usadas"
L["STRING_AGAINST"] = "contra"
L["STRING_ALIVE"] = "Vivo"
L["STRING_ANCHOR_BOTTOM"] = "Fundo"
L["STRING_ANCHOR_BOTTOMLEFT"] = "Fundo esquerdo"
L["STRING_ANCHOR_BOTTOMRIGHT"] = "Fundo direito"
L["STRING_ANCHOR_LEFT"] = "Esquerda"
L["STRING_ANCHOR_RIGHT"] = "Direita"
L["STRING_ANCHOR_TOP"] = "Topo"
L["STRING_ANCHOR_TOPLEFT"] = "Superior esquerdo"
L["STRING_ANCHOR_TOPRIGHT"] = "Superior direito"
L["STRING_ATACH_DESC"] = "Janela #%d se fixa com a janela #%d."
L["STRING_ATTRIBUTE_CUSTOM"] = "Customizados"
L["STRING_ATTRIBUTE_DAMAGE"] = "Dano"
L["STRING_ATTRIBUTE_DAMAGE_DEBUFFS"] = "Auras & Voidzones"
L["STRING_ATTRIBUTE_DAMAGE_DEBUFFS_REPORT"] = "Dano e Tempo de Atividade da Aura"
L["STRING_ATTRIBUTE_DAMAGE_DONE"] = "Dano Feito"
L["STRING_ATTRIBUTE_DAMAGE_DPS"] = "Dano por Segundo"
L["STRING_ATTRIBUTE_DAMAGE_ENEMIES"] = "Inimigos"
L["STRING_ATTRIBUTE_DAMAGE_FRAGS"] = "Abatimentos"
L["STRING_ATTRIBUTE_DAMAGE_FRIENDLYFIRE"] = "Fogo Amigo"
L["STRING_ATTRIBUTE_DAMAGE_TAKEN"] = "Dano Recebido"
L["STRING_ATTRIBUTE_ENERGY"] = "Energia"
L["STRING_ATTRIBUTE_ENERGY_ENERGY"] = "Energia Gerada"
L["STRING_ATTRIBUTE_ENERGY_MANA"] = "Mana Restaurada"
L["STRING_ATTRIBUTE_ENERGY_RAGE"] = "Raiva Gerada" -- Needs review
L["STRING_ATTRIBUTE_ENERGY_RUNEPOWER"] = "Poder R\195\186nico Gerado" -- Needs review
L["STRING_ATTRIBUTE_HEAL"] = "Cura"
L["STRING_ATTRIBUTE_HEAL_DONE"] = "Cura Feita"
L["STRING_ATTRIBUTE_HEAL_ENEMY"] = "Cura no Inimigo"
L["STRING_ATTRIBUTE_HEAL_HPS"] = "Cura Por Segundo"
L["STRING_ATTRIBUTE_HEAL_OVERHEAL"] = "Sobrecura"
L["STRING_ATTRIBUTE_HEAL_PREVENT"] = "Dano Prevenido"
L["STRING_ATTRIBUTE_HEAL_TAKEN"] = "Cura Recebida"
L["STRING_ATTRIBUTE_MISC"] = "Diversos" -- Needs review
L["STRING_ATTRIBUTE_MISC_BUFF_UPTIME"] = "Tempo Ativo: Buff" -- Needs review
L["STRING_ATTRIBUTE_MISC_CCBREAK"] = "Quebras de CC"
L["STRING_ATTRIBUTE_MISC_DEAD"] = "Mortes"
L["STRING_ATTRIBUTE_MISC_DEBUFF_UPTIME"] = "Tempo Ativo: Debuff" -- Needs review
L["STRING_ATTRIBUTE_MISC_DEFENSIVE_COOLDOWNS"] = "Cooldowns"
L["STRING_ATTRIBUTE_MISC_DISPELL"] = "Dissipados"
L["STRING_ATTRIBUTE_MISC_INTERRUPT"] = "Interrup\195\167\195\181es" -- Needs review
L["STRING_ATTRIBUTE_MISC_RESS"] = "Revividos"
L["STRING_AUTO"] = "auto"
L["STRING_AUTOSHOT"] = "Tiro Autom\195\161tico" -- Needs review
L["STRING_BLOCKED"] = "Bloqueado"
L["STRING_BOTTOM"] = "baixo"
L["STRING_CCBROKE"] = "CC Quebrados"
L["STRING_CENTER"] = "centro"
L["STRING_CHANGED_TO_CURRENT"] = "Segmento trocado para atual"
L["STRING_CLOSEALL"] = "Todas as janelas do Details est\195\163o fechadas, digite '/details new' para reabri-las." -- Needs review
L["STRING_COMMAND_LIST"] = "lista de comandos"
L["STRING_COOLTIP_NOOPTIONS"] = "N\195\163o h\195\161 op\195\167\195\181es" -- Needs review
L["STRING_CRITICAL_HITS"] = "Golpes Cr\195\173ticos" -- Needs review
L["STRING_CURRENT"] = "Atual"
L["STRING_CURRENTFIGHT"] = "Luta Atual"
L["STRING_CUSTOM_ATTRIBUTE_DAMAGE"] = "Dano" -- Needs review
L["STRING_CUSTOM_ATTRIBUTE_HEAL"] = "Cura" -- Needs review
L["STRING_CUSTOM_ATTRIBUTE_SCRIPT"] = "Script Customizado" -- Needs review
L["STRING_CUSTOM_AUTHOR"] = "Autor:" -- Needs review
L["STRING_CUSTOM_AUTHOR_DESC"] = "Quem criou este display." -- Needs review
L["STRING_CUSTOM_CANCEL"] = "Cancelar" -- Needs review
L["STRING_CUSTOM_CREATE"] = "Criar" -- Needs review
L["STRING_CUSTOM_CREATED"] = "O novo display foi criado com sucesso." -- Needs review
L["STRING_CUSTOM_DESCRIPTION"] = "Descri\195\167\195\163o:" -- Needs review
L["STRING_CUSTOM_DESCRIPTION_DESC"] = "Descreva o que este display ir\195\161 mostrar." -- Needs review
L["STRING_CUSTOM_DONE"] = "Terminar" -- Needs review
L["STRING_CUSTOM_EDIT"] = "Editar" -- Needs review
L["STRING_CUSTOM_EDITCODE_DESC"] = "Esta \195\169 uma fun\195\167\195\163o avan\195\167ada aonde o usu\195\161rio pode criar seu pr\195\179prio c\195\179digo de display." -- Needs review
L["STRING_CUSTOM_EDIT_SEARCH_CODE"] = "Editar o C\195\179digo" -- Needs review
L["STRING_CUSTOM_EDIT_TOOLTIP_CODE"] = "Editar o Tooltip" -- Needs review
L["STRING_CUSTOM_EDITTOOLTIP_DESC"] = "Este c\195\179digo \195\169 executado quando o usu\195\161rio passa o mouse sobre uma barra, o c\195\179digo deve montar o tooltip." -- Needs review
L["STRING_CUSTOM_ENEMY_DT"] = "Dano Recebido" -- Needs review
L["STRING_CUSTOM_EXPORT"] = "Exportar" -- Needs review
L["STRING_CUSTOM_FUNC_INVALID"] = "O script customizado \195\169 inv\195\161lido e n\195\163o foi poss\195\173vel atualizar a janela." -- Needs review
L["STRING_CUSTOM_HEALTHSTONE_DEFAULT"] = "Pedra da Vida Usada" -- Needs review
L["STRING_CUSTOM_HEALTHSTONE_DEFAULT_DESC"] = "Mostra quem no seu grupo de raide usou a Pedra da Vida." -- Needs review
L["STRING_CUSTOM_ICON"] = "Icone:" -- Needs review
L["STRING_CUSTOM_IMPORT"] = "Importar" -- Needs review
L["STRING_CUSTOM_IMPORT_ALERT"] = "Display carregado, clique em importar para confirmar." -- Needs review
L["STRING_CUSTOM_IMPORT_BUTTON"] = "Importar" -- Needs review
L["STRING_CUSTOM_IMPORTED"] = "O display foi importado com sucesso." -- Needs review
L["STRING_CUSTOM_IMPORT_ERROR"] = "Falha ao importar, a linha \195\169 inv\195\161lida." -- Needs review
L["STRING_CUSTOM_LONGNAME"] = "O nome est\195\161 muito longo, permite apenas 32 letras." -- Needs review
L["STRING_CUSTOM_NAME"] = "Nome:" -- Needs review
L["STRING_CUSTOM_NAME_DESC"] = "Insira o nome que o novo display ter\195\161." -- Needs review
L["STRING_CUSTOM_NEW"] = "Criar Novo"
L["STRING_CUSTOM_PASTE"] = "Cole aqui:" -- Needs review
L["STRING_CUSTOM_POT_DEFAULT"] = "Po\195\167\195\181es Usadas" -- Needs review
L["STRING_CUSTOM_POT_DEFAULT_DESC"] = "Mostra quem na sua raide usou po\195\167\195\181es durante a luta." -- Needs review
L["STRING_CUSTOM_REMOVE"] = "Remover" -- Needs review
L["STRING_CUSTOM_REPORT"] = "Relat\195\179rio para (custom)" -- Needs review
L["STRING_CUSTOM_SAVE"] = "Salvar Altera\195\167\195\181es" -- Needs review
L["STRING_CUSTOM_SAVED"] = "O display foi salvo." -- Needs review
L["STRING_CUSTOM_SHORTNAME"] = "O nome precisa ter no m\195\173nimo 5 letras." -- Needs review
L["STRING_CUSTOM_SOURCE"] = "Fonte:" -- Needs review
L["STRING_CUSTOM_SOURCE_DESC"] = "Quem est\195\161 causando este efeito.\
\
O bot\195\163o na direita mostra uma lista pr\195\169-definida com v\195\161rios npcs." -- Needs review
L["STRING_CUSTOM_SPELLID"] = "Id da Magia:" -- Needs review
L["STRING_CUSTOM_SPELLID_DESC"] = "Opcional, \195\169 a magia que esta causando o efeito no alvo.\
\
O bot\195\163o na direita mostra uma lista de magias." -- Needs review
L["STRING_CUSTOM_TARGET"] = "Alvo:" -- Needs review
L["STRING_CUSTOM_TARGET_DESC"] = "Este \195\169 o alvo aonde a Fonte esta causando o efeito.\
\
O bot\195\163o na direita mostra uma lista pr\195\169-definida com npcs." -- Needs review
L["STRING_CUSTOM_TEMPORARILY"] = " (|cFFFFC000tempor\195\161rio|r)" -- Needs review
L["STRING_DAMAGE"] = "Dano"
L["STRING_DAMAGE_DPS_IN"] = "DPS recebido de"
L["STRING_DAMAGE_FROM"] = "Recebeu dano de"
L["STRING_DAMAGE_TAKEN_FROM"] = "Dano Recebido Vindo De"
L["STRING_DAMAGE_TAKEN_FROM2"] = "aplicou dano com"
L["STRING_DEFENSES"] = "Defesas" -- Needs review
L["STRING_DETACH_DESC"] = "Desagrupar janelas"
L["STRING_DISPELLED"] = "Auras Removidas"
L["STRING_DODGE"] = "Desvio"
L["STRING_DOT"] = " (DoT)"
L["STRING_DPS"] = "Dps"
L["STRING_EMPTY_SEGMENT"] = "Segmento vazio"
L["STRING_EQUILIZING"] = "Compartilhando dados" -- Needs review
L["STRING_ERASE"] = "apagar"
L["STRING_ERASE_DATA"] = "Zerar todos os dados"
L["STRING_ERASE_DATA_OVERALL"] = "Zerar os dados gerais"
L["STRING_ERASE_IN_COMBAT"] = "Agendar limpeza completa ap\195\179s combate."
L["STRING_EXAMPLE"] = "Exemplo" -- Needs review
L["STRING_FAIL_ATTACKS"] = "Falhas de Ataque"
L["STRING_FIGHTNUMBER"] = "Luta #"
L["STRING_FREEZE"] = "Este segmento n\195\163o est\195\161 dispon\195\173vel no momento"
L["STRING_FROM"] = "Fonte"
L["STRING_GERAL"] = "Geral"
L["STRING_GLANCING"] = "Glancing"
L["STRING_HEAL"] = "Cura"
L["STRING_HEAL_ABSORBED"] = "Cura absorvida"
L["STRING_HEAL_CRIT"] = "Cura Critica"
L["STRING_HEALING_FROM"] = "Cura recebida de"
L["STRING_HEALING_HPS_FROM"] = "HPS recebido de"
L["STRING_HELP_ERASE"] = "Apaga todo o hist\195\179rico de lutas." -- Needs review
L["STRING_HELP_INSTANCE"] = "Clique: abre uma nova janela.\
\
Mouse em cima: mostra um menu com todas as janelas fechadas, voc\195\170 pode reabri-las quando quiser." -- Needs review
L["STRING_HELP_MENUS"] = "Menu da Engrenagem: altera o modo de jogo.\
Solo: ferramentas para voc\195\170 jogar sozinho.\
Group: mostra apenas os atores que pertencem ao seu grupo de raide.\
All: mostra tudo.\
Raid: ferramentas para auxiliar em grupos de raide.\
\
Menu do Livro: altera o segmento que esta sendo mostrado na janela.\
\
Menu da Espada: muda o atributo que esta janela esta mostrando." -- Needs review
L["STRING_HELP_MODEALL"] = "Nesta op\195\167\195\163o os filtros de grupo est\195\163o desativados, o Details! mostra tudo o que foi capturado, incluindo monstros, chefes, adds, entre outros." -- Needs review
L["STRING_HELP_MODEGROUP"] = "Neste modo somente \195\169 mostrado personagens que est\195\163o no seu grupo ou raide." -- Needs review
L["STRING_HELP_MODERAID"] = "O modo raide eh o oposto do modo lobo solit\195\161rio, aqui voc\195\170 encontra plugins destinados ao seu grupo em geral." -- Needs review
L["STRING_HELP_MODESELF"] = "Este modo possui plugins destinados apenas ao seu personagem. Voc\195\170 pode escolher o plugin que deseja usar no menu da espada." -- Needs review
L["STRING_HELP_RESIZE"] = "Bot\195\181es de redimensionar e travar a janela." -- Needs review
L["STRING_HELP_STATUSBAR"] = "A barra de status armazena 3 plugins: um na esquerda, outro no centro e na direita.\
\
Bot\195\163o direito: seleciona outro plugin para mostrar.\
\
Botao esquerdo: mostra as op\195\167\195\181es do plugin." -- Needs review
L["STRING_HELP_STRETCH"] = "Clique, segure e puxe para esticar a janela."
L["STRING_HELP_SWITCH"] = "Bot\195\163o direito: mostra o painel de mudan\195\167a r\195\161pida.\
\
Bot\195\163o esquerdo em uma op\195\167\195\163o do painel de mudan\195\167a r\195\161pida: muda o atributo que a janela esta mostrando.\
bot\195\163o direito: fecha o painel.\
\
Voc\195\170 pode clicar nos icones para escolher outro atributo." -- Needs review
L["STRING_HITS"] = "Golpes"
L["STRING_HPS"] = "Hps"
L["STRING_IMAGEEDIT_ALPHA"] = "Transpar\195\170ncia" -- Needs review
L["STRING_IMAGEEDIT_COLOR"] = "Cor" -- Needs review
L["STRING_IMAGEEDIT_CROPBOTTOM"] = "Cortar Baixo" -- Needs review
L["STRING_IMAGEEDIT_CROPLEFT"] = "Cortar Esquerda" -- Needs review
L["STRING_IMAGEEDIT_CROPRIGHT"] = "Cortar Direita" -- Needs review
L["STRING_IMAGEEDIT_CROPTOP"] = "Cortar Topo" -- Needs review
L["STRING_IMAGEEDIT_DONE"] = "TERMINAR" -- Needs review
L["STRING_IMAGEEDIT_FLIPH"] = "Inverter Horizontal" -- Needs review
L["STRING_IMAGEEDIT_FLIPV"] = "Inverter Vertical" -- Needs review
L["STRING_INSTANCE_LIMIT"] = "o limite de janelas criadas foi atingido, voc\195\170 pode modificar este limite no painel de op\195\167\195\181es." -- Needs review
L["STRING_INTERFACE_OPENOPTIONS"] = "Abrir Painel de Op\195\167\195\181es" -- Needs review
L["STRING_ISA_PET"] = "Este Ator e um Ajudante"
L["STRING_KILLED"] = "Morto"
L["STRING_LAST_COOLDOWN"] = "ultimo cooldown usado"
L["STRING_LEFT"] = "esquerda"
L["STRING_LEFT_CLICK_SHARE"] = "Clique para enviar relat\195\179rio." -- Needs review
L["STRING_LOCK_DESC"] = "Travar ou destravar esta janela"
L["STRING_LOCK_WINDOW"] = "travar"
L["STRING_MASTERY"] = "Maestria"
L["STRING_MAXIMUM"] = "M\195\161ximo" -- Needs review
L["STRING_MEDIA"] = "Media"
L["STRING_MELEE"] = "Corpo-a-Corpo"
L["STRING_MENU_CLOSE_INSTANCE"] = "Fechar esta janela"
L["STRING_MENU_CLOSE_INSTANCE_DESC"] = "A janela fechada \195\169 considerada inativa e pode ser aberta a qualquer momento, usando o bot\195\163o # da inst\195\162ncia."
L["STRING_MENU_CLOSE_INSTANCE_DESC2"] = "Para destruir totalmente a janela, verifique a sess\195\163o Diversos no painel de op\195\167\195\181es."
L["STRING_MINIMAPMENU_LOCK"] = "Travar"
L["STRING_MINIMAPMENU_NEWWINDOW"] = "Criar Nova Janela"
L["STRING_MINIMAPMENU_REOPEN"] = "Reabrir Janela"
L["STRING_MINIMAPMENU_REOPENALL"] = "Reabrir Todas"
L["STRING_MINIMAPMENU_RESET"] = "Resetar"
L["STRING_MINIMAPMENU_UNLOCK"] = "Destravar"
L["STRING_MINIMAP_TOOLTIP1"] = "|cFFCFCFCFbot\195\163o esquerdo|r: abrir o painel de op\195\167\195\181es" -- Needs review
L["STRING_MINIMAP_TOOLTIP11"] = "|cFFCFCFCFbot\195\163o esquerdo|r: Limpe todos os segmentos." -- Needs review
L["STRING_MINIMAP_TOOLTIP2"] = "|cFFCFCFCFbot\195\163o direito|r: menu r\195\161pido" -- Needs review
L["STRING_MINIMUM"] = "M\195\173nimo" -- Needs review
L["STRING_MINITUTORIAL_1"] = "Bot\195\163o de Janelas:\
\
Clique para abrir uma nova janela do Details!.\
\
Passe o mouse sobre o bot\195\163o para reabrir janelas fechadas." -- Needs review
L["STRING_MINITUTORIAL_2"] = "Bot\195\163o de Esticar:\
\
Clique, segure e puxe para esticar a janela.\
\
Solte o botao para a janela retornar ao tamanho normal." -- Needs review
L["STRING_MINITUTORIAL_3"] = "Redimensionar e Trancar:\
\
Use este bot\195\163o para mudar o tamanho da janela.\
\
Trancando ela, impede que a janela seja movida." -- Needs review
L["STRING_MINITUTORIAL_4"] = "Painel de Atalhos:\
\
Clicando com o bot\195\163o direito sobre uma barra ou no fundo da janela, o painel de atalho eh mostrado." -- Needs review
L["STRING_MINITUTORIAL_5"] = "Micro Displays:\
\
Mostram informa\195\167\195\181es importantes a voc\195\170.\
\
Bot\195\163o esquerdo para configura-las.\
\
Bot\195\163o direito para escolher outra informa\195\167\195\163o." -- Needs review
L["STRING_MINITUTORIAL_6"] = "Juntar Janelas:\
\
Mova uma janela pr\195\179xima a outra para junta-las.\
\
Sempre junte janelas com o n\195\186mero anterior, exemplo: #5 junta com a #4, #2 junta com a #1, etc." -- Needs review
L["STRING_MISS"] = "Errou"
L["STRING_MODE_ALL"] = "Mostrar Tudo"
L["STRING_MODE_GROUP"] = "Grupo & Raide"
L["STRING_MODE_PLUGINS"] = "plugins"
L["STRING_MODE_RAID"] = "Plugins: Raide" -- Needs review
L["STRING_MODE_SELF"] = "Plugins: Individual" -- Needs review
L["STRING_MORE_INFO"] = "Veja a caixa da direita para mais informa\195\167\195\181es."
L["STRING_MUSIC_DETAILS_ROBERTOCARLOS"] = "N\195\163o adianta nem tentar me esquecer\
Durante muito tempo em sua vida eu vou viver\
Detalhes t\195\163o pequenos de nos dois" -- Needs review
L["STRING_NEWROW"] = "esperando atualizar..."
L["STRING_NEWS_REINSTALL"] = "Encontrou problemas ap\195\179s atualizar? tente o comando '/details reinstall'." -- Needs review
L["STRING_NEWS_TITLE"] = "Quais As Novidades Desta Vers\195\163o" -- Needs review
L["STRING_NO"] = "N\195\163o" -- Needs review
L["STRING_NOCLOSED_INSTANCES"] = "N\195\163o h\195\161 janelas fechadas,\
clique para abrir uma nova." -- Needs review
L["STRING_NO_DATA"] = "data j\195\161 foi limpada"
L["STRING_NOLAST_COOLDOWN"] = "nenhum cooldown usado"
L["STRING_NORMAL_HITS"] = "Golpes Normais"
L["STRING_NO_SPELL"] = "Nenhuma habilidade foi usada"
L["STRING_NO_TARGET"] = "Nenhum alvo encontrado."
L["STRING_NO_TARGET_BOX"] = "Nenhum alvo dispon\195\173vel."
L["STRING_OPTIONS_ADVANCED"] = "Avan\195\167ado"
L["STRING_OPTIONS_ALPHAMOD_ANCHOR"] = " (|cFFFFC000tempor\195\161rio|r)" -- Needs review
L["STRING_OPTIONS_ANCHOR"] = "Lado"
L["STRING_OPTIONS_ANIMATEBARS"] = "Animar as Barras"
L["STRING_OPTIONS_ANIMATEBARS_DESC"] = "Quando ativa as barras das janelas s\195\163o animadas ao inv\195\169s de 'pularem'." -- Needs review
L["STRING_OPTIONS_ANIMATESCROLL"] = "Animar Barra de Rolagem"
L["STRING_OPTIONS_ANIMATESCROLL_DESC"] = "Quanto ativa, a barra de rolagem faz uma anima\195\167\195\163o ao ser mostrada e escondida." -- Needs review
L["STRING_OPTIONS_APPEARANCE"] = "Apar\195\170ncia" -- Needs review
L["STRING_OPTIONS_ATTRIBUTE_TEXT"] = "Configura\195\167\195\181es de T\195\173tulos"
L["STRING_OPTIONS_ATTRIBUTE_TEXT_DESC"] = "Essas op\195\167\195\181es controlam as configura\195\167\195\181es dos t\195\173tulos de uma janela."
L["STRING_OPTIONS_AUTO_SWITCH"] = "Troca Autom\195\161tica" -- Needs review
L["STRING_OPTIONS_AUTO_SWITCH_COMBAT"] = "|cFFFFAA00(em combate)|r"
L["STRING_OPTIONS_AUTO_SWITCH_DAMAGER_DESC"] = "Quando estiver com especializa\195\167\195\163o de dano, esta janela mostra o atributo ou plugin escolhido." -- Needs review
L["STRING_OPTIONS_AUTO_SWITCH_DESC"] = "Quando voc\195\170 entra em combate, esta janela mudara o atributo mostrado para outro atributo ou plugin.\
\
Saindo do combate o atributo antigo volta a ser mostrado." -- Needs review
L["STRING_OPTIONS_AUTO_SWITCH_HEALER_DESC"] = "Quando estiver com especializa\195\167\195\163o de cura, esta janela mostra o atributo ou plugin escolhido." -- Needs review
L["STRING_OPTIONS_AUTO_SWITCH_TANK_DESC"] = "Quando estiver com especializa\195\167\195\163o de tanque, esta janela mostra o atributo ou plugin escolhido." -- Needs review
L["STRING_OPTIONS_AUTO_SWITCH_WIPE"] = "Depois de derrota em encontro"
L["STRING_OPTIONS_AUTO_SWITCH_WIPE_DESC"] = "Depois de uma tentativa fracassada de derrotar um chefe inimigo num combate de raid, esta janela automaticamente mostrar\195\161 isso."
L["STRING_OPTIONS_AVATAR"] = "Escolha o Seu Avatar"
L["STRING_OPTIONS_AVATAR_ANCHOR"] = "Identidade:"
L["STRING_OPTIONS_AVATAR_DESC"] = "O avatar tamb\195\169m \195\169 enviado aos membros da guilda, ele eh mostrado sobre o tooltip quando passa o mouse sobre uma barra." -- Needs review
L["STRING_OPTIONS_BAR_BACKDROP_ANCHOR"] = "Borda:"
L["STRING_OPTIONS_BAR_BACKDROP_COLOR"] = "Cor"
L["STRING_OPTIONS_BAR_BACKDROP_COLOR_DESC"] = "Muda a cor da borda."
L["STRING_OPTIONS_BAR_BACKDROP_ENABLED"] = "Habilitado"
L["STRING_OPTIONS_BAR_BACKDROP_ENABLED_DESC"] = "Habilita ou desabilita as bordas da linha."
L["STRING_OPTIONS_BAR_BACKDROP_SIZE"] = "Tamanho"
L["STRING_OPTIONS_BAR_BACKDROP_SIZE_DESC"] = "Aumenta ou diminui o tamanho da borda."
L["STRING_OPTIONS_BAR_BACKDROP_TEXTURE"] = "Textura"
L["STRING_OPTIONS_BAR_BACKDROP_TEXTURE_DESC"] = "Muda a apar\195\170ncia da borda."
L["STRING_OPTIONS_BAR_BCOLOR"] = "Cor da Textura de Fundo"
L["STRING_OPTIONS_BAR_BCOLOR_DESC"] = "Escolha a cor que a textura do fundo da barra ter\195\161, no painel, h\195\161 um controle de transpar\195\170ncia, n\195\163o esque\195\167a de alterar." -- Needs review
L["STRING_OPTIONS_BAR_BTEXTURE"] = "Textura de Fundo"
L["STRING_OPTIONS_BAR_BTEXTURE_DESC"] = "Altere a textura do fundo da barra, lembre-se de alterar a cor da textura e diminuir sua transpar\195\170ncia." -- Needs review
L["STRING_OPTIONS_BAR_COLORBYCLASS"] = "Cor da Classe"
L["STRING_OPTIONS_BAR_COLORBYCLASS2"] = "Cor da Classe (fundo)"
L["STRING_OPTIONS_BAR_COLORBYCLASS2_DESC"] = "Quando ativada, as barras aplicam a cor da classe do personagem na textura de fundo.\
\
Quando desligado, a barra ira utilizar a cor fixa determinada na caixa a direita."
L["STRING_OPTIONS_BAR_COLORBYCLASS_DESC"] = "Quando ativada, as barras aplicam a cor da classe do personagem na textura superior.\
\
Quando desligado, a barra ira utilizar a cor fixa determinada na caixa a direita."
L["STRING_OPTIONS_BAR_COLOR_DESC"] = "Escolha a cor da textura.\
Essa cor ser\195\161 ignorada quando a op\195\167\195\163o Usar cor da Classe estiver ativo."
L["STRING_OPTIONS_BARGROW_DIRECTION"] = "Dire\195\167\195\163o de Crescimento" -- Needs review
L["STRING_OPTIONS_BARGROW_DIRECTION_DESC"] = "Altera a posi\195\167\195\163o em que as barras come\195\167am a serem mostradas, de cima da janela para baixo ou de baixo da janela para cima." -- Needs review
L["STRING_OPTIONS_BAR_HEIGHT"] = "Altura"
L["STRING_OPTIONS_BAR_HEIGHT_DESC"] = "Altera a altura das barras."
L["STRING_OPTIONS_BAR_ICONFILE"] = "Arquivo de \195\173cone"
L["STRING_OPTIONS_BAR_ICONFILE_DESC"] = "Arquivo .tga respons\195\161vel pelos \195\173cones das classes.\
\
H\195\161 tr\195\170s arquivos de \195\173cones que vem junto ao instalar o addon:\
\
- |cFFFFFF00classes|r\
- |cFFFFFF00classes_small|r\
- |cFFFFFF00classes_small_alpha|r"
L["STRING_OPTIONS_BARLEFTTEXTCUSTOM"] = "Texto Customizado Ativado" -- Needs review
L["STRING_OPTIONS_BARLEFTTEXTCUSTOM2"] = "n\195\163o usou" -- Needs review
L["STRING_OPTIONS_BARLEFTTEXTCUSTOM2_DESC"] = "|cFFFFFF00{data1}|r: simboliza o n\195\186mero da coloca\195\167\195\163o do jogador.\
\
|cFFFFFF00{data2}|r: simboliza o nome do jogador.\
\
|cFFFFFF00{data3}|r: simboliza o \195\173cone da fac\195\167\195\163o ou da especializa\195\167\195\163o do jogador (em alguns casos).\
\
|cFFFFFF00{func}|r: executa uma fun\195\167\195\163o Lua customizada adicionando seu valor de retorno ao texto.\
Exemplo:\
{func return 'ola azeroth'}\
\
|cFFFFFF00Sequencias de Escape|r: usado para mudar a cor do texto ou adicionar imagens, pesquise por 'UI escape sequences' para mais informa\195\167\195\181es." -- Needs review
L["STRING_OPTIONS_BARLEFTTEXTCUSTOM_DESC"] = "Quando ativado, o texto da esquerda \195\169 formatado seguindo o modelo posto no campo de texto abaixo." -- Needs review
L["STRING_OPTIONS_BARRIGHTTEXTCUSTOM"] = "Texto personalizado habilitado"
L["STRING_OPTIONS_BARRIGHTTEXTCUSTOM2"] = ""
L["STRING_OPTIONS_BARRIGHTTEXTCUSTOM2_DESC"] = "|cFFFFFF00{data1}|r: \195\169 o primeiro numero passado, geralmente esse numero representa o total feito.\
\
|cFFFFFF00{data2}|r: \195\169 o segundo n\195\186mero passado, na maioria das vezes representa a m\195\169dia por segundos.\
\
|cFFFFFF00{data3}|r: terceiro n\195\186mero passado, normalmente \195\169 a porcentagem. \
\
|cFFFFFF00{func}|r: Executa uma fun\195\167\195\163o Lua customizada, adicionando seu valor retornado ao texto.\
Example: \
{func return 'hello azeroth'}\
\
|cFFFFFF00Chaves de Edi\195\167\195\163o de Texto|r: use para mudar a cor ou adicionar texturas. Busque por 'UI escape sequences' para mais informa\195\167\195\181es." -- Needs review
L["STRING_OPTIONS_BARRIGHTTEXTCUSTOM_DESC"] = "Quando habilitado, o texto a direita \195\169 formatado seguindo as regras na caixa."
L["STRING_OPTIONS_BARS"] = "Configura\195\167\195\181es das Barras" -- Needs review
L["STRING_OPTIONS_BARS_DESC"] = "Estas op\195\167\195\181es controlam a apar\195\170ncia das barra da janela." -- Needs review
L["STRING_OPTIONS_BARSORT_DIRECTION"] = "Ordem das Barras"
L["STRING_OPTIONS_BARSORT_DIRECTION_DESC"] = "Altera como as barras s\195\163o preenchidas, crescente ou decrescente, mas ainda mostrando sempre os primeiros colocados." -- Needs review
L["STRING_OPTIONS_BAR_SPACING"] = "Espa\195\167amento"
L["STRING_OPTIONS_BAR_SPACING_DESC"] = "Aumenta ou diminui a dimens\195\163o de tamanho entre cada linha."
L["STRING_OPTIONS_BARSTART"] = "Barra inicia depois do \195\173cone"
L["STRING_OPTIONS_BARSTART_DESC"] = "Quando desabilitado, a textura superior inicia no \195\173cone do lado esquerdo ao inv\195\169s do direito (\195\186til para \195\173cones transparentes)."
L["STRING_OPTIONS_BAR_TEXTURE"] = "Textura"
L["STRING_OPTIONS_BAR_TEXTURE_DESC"] = "Esta op\195\167\195\163o altera a textura superior das barras." -- Needs review
L["STRING_OPTIONS_CAURAS"] = "Coletar Auras"
L["STRING_OPTIONS_CAURAS_DESC"] = "Ativa a Captura de:\
\
- |cFFFFFFFFTempo de Buffs|r\
- |cFFFFFFFFTempo de Debuffs|r\
- |cFFFFFFFFVoid Zones|r\
-|cFFFFFFFF Cooldowns|r"
L["STRING_OPTIONS_CDAMAGE"] = "Coletar Dano"
L["STRING_OPTIONS_CDAMAGE_DESC"] = "Ativa a Captura de:\
\
- |cFFFFFFFFDano Feito|r\
- |cFFFFFFFFDano Por Segundo|r\
- |cFFFFFFFFFogo Amigo|r\
- |cFFFFFFFFDano Sofrido|r"
L["STRING_OPTIONS_CENERGY"] = "Coletar Energia"
L["STRING_OPTIONS_CENERGY_DESC"] = "Ativa a Captura de:\
\
- |cFFFFFFFFMana Restaurada|r\
- |cFFFFFFFFRaiva Gerada|r\
- |cFFFFFFFFEnergia Gerada|r\
- |cFFFFFFFFPoder R\195\186nico Gerado|r" -- Needs review
L["STRING_OPTIONS_CHART_ADD"] = "Adicionar Data" -- Needs review
L["STRING_OPTIONS_CHART_ADD2"] = "Adicionar" -- Needs review
L["STRING_OPTIONS_CHART_ADDAUTHOR"] = "Autor:" -- Needs review
L["STRING_OPTIONS_CHART_ADDCODE"] = "C\195\179digo:" -- Needs review
L["STRING_OPTIONS_CHART_ADDICON"] = "\195\141cone:" -- Needs review
L["STRING_OPTIONS_CHART_ADDNAME"] = "Nome:" -- Needs review
L["STRING_OPTIONS_CHART_ADDVERSION"] = "Vers\195\163o:" -- Needs review
L["STRING_OPTIONS_CHART_AUTHOR"] = "Autor" -- Needs review
L["STRING_OPTIONS_CHART_AUTHORERROR"] = "O nome do autor \195\169 inv\195\161lido" -- Needs review
L["STRING_OPTIONS_CHART_CANCEL"] = "Cancelar" -- Needs review
L["STRING_OPTIONS_CHART_CLOSE"] = "Fechar" -- Needs review
L["STRING_OPTIONS_CHART_CODELOADED"] = "O c\195\179digo j\195\161 esta carregado e n\195\163o pode ser alterado." -- Needs review
L["STRING_OPTIONS_CHART_EDIT"] = "Editar C\195\179digo" -- Needs review
L["STRING_OPTIONS_CHART_ENABLED"] = "Ativado" -- Needs review
L["STRING_OPTIONS_CHART_EXPORT"] = "Exportar" -- Needs review
L["STRING_OPTIONS_CHART_FUNCERROR"] = "Fun\195\167\195\163o \195\169 Inv\195\161lida" -- Needs review
L["STRING_OPTIONS_CHART_ICON"] = "\195\141cone" -- Needs review
L["STRING_OPTIONS_CHART_IMPORT"] = "Importar" -- Needs review
L["STRING_OPTIONS_CHART_IMPORTERROR"] = "A linha importada \195\169 inv\195\161lida." -- Needs review
L["STRING_OPTIONS_CHART_NAME"] = "Nome" -- Needs review
L["STRING_OPTIONS_CHART_NAMEERROR"] = "O nome \195\169 inv\195\161lido" -- Needs review
L["STRING_OPTIONS_CHART_PLUGINWARNING"] = "Instale Chart Viewer Plugin para mostrar os gr\195\161ficos customizados." -- Needs review
L["STRING_OPTIONS_CHART_REMOVE"] = "Remover" -- Needs review
L["STRING_OPTIONS_CHART_SAVE"] = "Salvar" -- Needs review
L["STRING_OPTIONS_CHART_VERSION"] = "Vers\195\163o" -- Needs review
L["STRING_OPTIONS_CHART_VERSIONERROR"] = "Vers\195\163o \195\169 inv\195\161lida." -- Needs review
L["STRING_OPTIONS_CHEAL"] = "Coletar Cura"
L["STRING_OPTIONS_CHEAL_DESC"] = "Ativa a Captura de:\
\
- |cFFFFFFFFCura Feita|r\
- |cFFFFFFFFAbsor\195\167\195\181es|r\
- |cFFFFFFFFCura Por Segundo|r\
- |cFFFFFFFFSobre Cura|r\
- |cFFFFFFFFCura Recebida|r\
- |cFFFFFFFFCura Inimiga|r\
- |cFFFFFFFFDano Prevenido|r" -- Needs review
L["STRING_OPTIONS_CLEANUP"] = "Apagar Segmentos de Limpeza"
L["STRING_OPTIONS_CLEANUP_DESC"] = "Segmentos com 'trash mobs' s\195\163o considerados segmentos de limpeza.\
\
Esta op\195\167\195\163o ativa a remo\195\167\195\163o autom\195\161tica destes segmentos quando poss\195\173vel." -- Needs review
L["STRING_OPTIONS_CLOSE_BUTTON_ANCHOR"] = "Bot\195\163o Fechar:"
L["STRING_OPTIONS_CLOSE_OVERLAY"] = "Sobreposi\195\167\195\163o de cor"
L["STRING_OPTIONS_CLOSE_OVERLAY_DESC"] = "Muda o bot\195\163o fechar da sobreposi\195\167\195\163o de cor."
L["STRING_OPTIONS_CLOUD"] = "Captura Atrav\195\169s de Nuvem" -- Needs review
L["STRING_OPTIONS_CLOUD_DESC"] = "Quando ativado, as informa\195\167\195\181es de capturas desligadas eh buscada em outros membros da raide." -- Needs review
L["STRING_OPTIONS_CMISC"] = "Coletar Diversos" -- Needs review
L["STRING_OPTIONS_CMISC_DESC"] = "Ativa a Captura de:\
\
- |cFFFFFFFFQuebra de CC|r\
- |cFFFFFFFFDissipa\195\167\195\181es|r\
- |cFFFFFFFFInterrup\195\167\195\181es|r\
- |cFFFFFFFFRevividos|r\
- |cFFFFFFFFMortes|r" -- Needs review
L["STRING_OPTIONS_COLOR"] = "Cor"
L["STRING_OPTIONS_COLORANDALPHA"] = "Cor & Transpar\195\170ncia" -- Needs review
L["STRING_OPTIONS_COLORFIXED"] = "Cor Fixada"
L["STRING_OPTIONS_COMBAT_ALPHA"] = "Modificar tipo"
L["STRING_OPTIONS_COMBAT_ALPHA_1"] = "Sem modifica\195\167\195\181es"
L["STRING_OPTIONS_COMBAT_ALPHA_2"] = "Durante o combate"
L["STRING_OPTIONS_COMBAT_ALPHA_3"] = "Enquanto fora de combate"
L["STRING_OPTIONS_COMBAT_ALPHA_4"] = "Enquanto fora de um grupo"
L["STRING_OPTIONS_COMBAT_ALPHA_DESC"] = "Seleciona a forma como o combate afeta a transpar\195\170ncia da janela.\
\
|cFFFFFF00Nenhuma modifica\195\167\195\163o|r: N\195\163o modifica o alpha.\
\
|cFFFFFF00Durante o combate|r: Quando seu personagem estiver em combate, o alpha escolhido \195\169 aplicado a janela.\
\
|cFFFFFF00Quando fora de combate|r: O alpha \195\169 aplicado sempre que seu personagem n\195\163o estiver em combate.\
\
|cFFFFFF00Quando fora de um grupo|r: Quando voc\195\170 n\195\163o estiver num grupo ou numa raid, a janela assume o alfa selecionado.\
\
|cFFFFFF00Important|r: Essa op\195\167\195\163o sobrescreve o alfa determinado pela op\195\167\195\163o de Auto Transpar\195\170ncia." -- Needs review
L["STRING_OPTIONS_COMBATTWEEKS"] = "Ajustes de Combate"
L["STRING_OPTIONS_COMBATTWEEKS_DESC"] = "Ajustes comportamentais de como Details! lida com alguns aspectos de combate."
L["STRING_OPTIONS_CUSTOMSPELL_ADD"] = "Adicionar feiti\195\167o"
L["STRING_OPTIONS_CUSTOMSPELLTITLE"] = "Configura\195\167\195\181es de edi\195\167\195\163o de feiti\195\167o"
L["STRING_OPTIONS_CUSTOMSPELLTITLE_DESC"] = "Esse painel permite voc\195\170 modificar o nome e o \195\173cone de feiti\195\167os." -- Needs review
L["STRING_OPTIONS_DATABROKER"] = "Exportar dados:"
L["STRING_OPTIONS_DATABROKER_TEXT"] = "Texto"
L["STRING_OPTIONS_DATABROKER_TEXT1"] = "DPS da Raide" -- Needs review
L["STRING_OPTIONS_DATABROKER_TEXT2"] = "HPS da Raide" -- Needs review
L["STRING_OPTIONS_DATABROKER_TEXT3"] = "Tempo do Combate" -- Needs review
L["STRING_OPTIONS_DATABROKER_TEXT4"] = "DPS do Jogador" -- Needs review
L["STRING_OPTIONS_DATABROKER_TEXT5"] = "HPS do Jogador" -- Needs review
L["STRING_OPTIONS_DATABROKER_TEXT_DESC"] = "Selecione qual valor \195\169 exportado."
L["STRING_OPTIONS_DATACHARTTITLE"] = "Criar dados cronometrados para tabelas"
L["STRING_OPTIONS_DATACHARTTITLE_DESC"] = "Esse painel permite que voc\195\170 crie capturas de dados customizados para cria\195\167\195\163o de tabelas."
L["STRING_OPTIONS_DATACOLLECT_ANCHOR"] = "Tipos de dados:"
L["STRING_OPTIONS_DESATURATE_MENU"] = "Menu de Dessatura\195\167\195\163o" -- Needs review
L["STRING_OPTIONS_DESATURATE_MENU_DESC"] = "Habilitando essa op\195\167\195\163o far\195\161 com que os \195\173cones do menu da barra de ferramentas se tornem brancos e pretos."
L["STRING_OPTIONS_EDITIMAGE"] = "Editar Imagem"
L["STRING_OPTIONS_EDITINSTANCE"] = "Editando a Janela:" -- Needs review
L["STRING_OPTIONS_ERASECHARTDATA"] = "Apagar Gr\195\161ficos" -- Needs review
L["STRING_OPTIONS_ERASECHARTDATA_DESC"] = "Quando deslogar do jogo, as informa\195\167\195\181es guardadas para gerar gr\195\161ficos s\195\163o apagadas." -- Needs review
L["STRING_OPTIONS_EXTERNALS_TITLE"] = "Widgets Externos"
L["STRING_OPTIONS_EXTERNALS_TITLE2"] = "Esta op\195\167\195\163o controla o comportamento de v\195\161rios widgets externos."
L["STRING_OPTIONS_GENERAL"] = "Configura\195\167\195\181es Gerais" -- Needs review
L["STRING_OPTIONS_GENERAL_ANCHOR"] = "Geral:"
L["STRING_OPTIONS_HIDECOMBATALPHA"] = "Transpar\195\170ncia" -- Needs review
L["STRING_OPTIONS_HIDECOMBATALPHA_DESC"] = "A janela pode ser completamente escondida ou apenas ficar mais transparente."
L["STRING_OPTIONS_HIDE_ICON"] = "Esconder \195\173cone"
L["STRING_OPTIONS_HIDE_ICON_DESC"] = "Quando habilitado, o \195\173cone no canto superior esquerdo n\195\163o ser\195\161 exibido.\
\
Algumas skins talvez prefiram remover esse \195\173cone."
L["STRING_OPTIONS_HOTCORNER"] = "Mostrar bot\195\163o"
L["STRING_OPTIONS_HOTCORNER_ACTION"] = "no clique"
L["STRING_OPTIONS_HOTCORNER_ACTION_DESC"] = "Selecione o que fazer quando o bot\195\163o da Hotcorner bar \195\169 clicado com o bot\195\163o esquerdo do mouse."
L["STRING_OPTIONS_HOTCORNER_ANCHOR"] = "Hotcorner:"
L["STRING_OPTIONS_HOTCORNER_DESC"] = "Exibe ou oculta o bot\195\163o sobre o painel Hotcorner."
L["STRING_OPTIONS_HOTCORNER_QUICK_CLICK"] = "Habilitar clique r\195\161pido"
L["STRING_OPTIONS_HOTCORNER_QUICK_CLICK_DESC"] = "Habilita ou desabilita a op\195\167\195\163o clique r\195\161pido para os Hotcorners.\
\
O bot\195\163o r\195\161pido est\195\161 localizado no canto superior esquerdo do pixel, movendo seu mouse por toda essa \195\161rea, ativa o hot corner superior esquerdo e quando clicado, uma a\195\167\195\163o \195\169 executada." -- Needs review
L["STRING_OPTIONS_HOTCORNER_QUICK_CLICK_FUNC"] = "Clique r\195\161pido no clique"
L["STRING_OPTIONS_HOTCORNER_QUICK_CLICK_FUNC_DESC"] = "Seleciona o que fazer quando o bot\195\163o de clique r\195\161pido do Hotcorner \195\169 acionado."
L["STRING_OPTIONS_INSBUTTON_X"] = "Bot\195\163o de Janela X" -- Needs review
L["STRING_OPTIONS_INSBUTTON_X_DESC"] = "Muda o bot\195\163o de janela de posi\195\167\195\163o." -- Needs review
L["STRING_OPTIONS_INSBUTTON_Y"] = "Bot\195\163o de Janela Y" -- Needs review
L["STRING_OPTIONS_INSBUTTON_Y_DESC"] = "Muda o bot\195\163o de janela de posi\195\167\195\163o." -- Needs review
L["STRING_OPTIONS_INSTANCE_ALPHA"] = "Transpar\195\170ncia do Fundo" -- Needs review
L["STRING_OPTIONS_INSTANCE_ALPHA2"] = "Cor de Fundo"
L["STRING_OPTIONS_INSTANCE_ALPHA2_DESC"] = "Seleciona a cor do fundo da janela."
L["STRING_OPTIONS_INSTANCE_ALPHA_DESC"] = "Esta op\195\167\195\163o altera a transpar\195\170ncia do fundo da janela." -- Needs review
L["STRING_OPTIONS_INSTANCE_BACKDROP"] = "Textura de fundo"
L["STRING_OPTIONS_INSTANCE_BACKDROP_DESC"] = "Seleciona a textura de fundo usada por essa janela.\
\
|cFFFFFF00Padr\195\163o|r: Details Background."
L["STRING_OPTIONS_INSTANCE_BUTTON_ANCHOR"] = "Bot\195\163o de Janela:" -- Needs review
L["STRING_OPTIONS_INSTANCE_COLOR"] = "Cor e Transpar\195\170ncia" -- Needs review
L["STRING_OPTIONS_INSTANCE_COLOR_DESC"] = "Altera a cor e a transpar\195\170ncia da janela." -- Needs review
L["STRING_OPTIONS_INSTANCE_CURRENT"] = "Mudar Para Atual"
L["STRING_OPTIONS_INSTANCE_CURRENT_DESC"] = "Quando qualquer combate come\195\167ar e n\195\163o h\195\161 nenhuma janela no segmento atual, esta janela automaticamente troca para o segmento atual." -- Needs review
L["STRING_OPTIONS_INSTANCE_DELETE"] = "Apagar"
L["STRING_OPTIONS_INSTANCE_DELETE_DESC"] = "Remove permanentemente uma janela.\
Seu jogo poder\195\161 recarregar durante o processo de limpeza."
L["STRING_OPTIONS_INSTANCE_OVERLAY"] = "Sobrepor cor"
L["STRING_OPTIONS_INSTANCE_OVERLAY_DESC"] = "Muda a sobreposi\195\167\195\163o de cor do bot\195\163o de inst\195\162ncia."
L["STRING_OPTIONS_INSTANCES"] = "Janelas:"
L["STRING_OPTIONS_INSTANCE_SKIN"] = "Pele (skin)"
L["STRING_OPTIONS_INSTANCE_SKIN_DESC"] = "Modifica todas as texturas e op\195\167\195\181es da janela atrav\195\169s de um padr\195\163o pr\195\169-definido." -- Needs review
L["STRING_OPTIONS_INSTANCE_STATUSBAR_ANCHOR"] = "Barra de Status:"
L["STRING_OPTIONS_INSTANCE_STATUSBARCOLOR"] = "Cor e transpar\195\170ncia" -- Needs review
L["STRING_OPTIONS_INSTANCE_STATUSBARCOLOR_DESC"] = "Seleciona a cor usada pela barra de status.\
\
|cFFFFFF00Importante|r: Essa op\195\167\195\163o sobrescreve a cor e a transpar\195\170ncia da cor da janela escolhida."
L["STRING_OPTIONS_INSTANCE_STRATA"] = "Ajuste de Camada" -- Needs review
L["STRING_OPTIONS_INSTANCE_STRATA_DESC"] = "Seleciona a altura da camada em que o quadro ser\195\161 posicionado.\
\
Camada inferior \195\169 o padr\195\163o e faz com que a janela fique atr\195\161s da maioria dos pain\195\169is de interface.\
\
Usar uma camada alta far\195\161 com que a janela fica na frente dos outros pain\195\169is..\
\
Quando alterando as camadas voc\195\170 pode encontar alguns conflitos com outros pain\195\169is cobrindo uns aos outros." -- Needs review
L["STRING_OPTIONS_INSTANCE_TEXTCOLOR"] = "Cor de texto"
L["STRING_OPTIONS_INSTANCE_TEXTCOLOR_DESC"] = "Muda o bot\195\163o de inst\195\162ncia de cor de texto."
L["STRING_OPTIONS_INSTANCE_TEXTFONT"] = "Fonte de texto"
L["STRING_OPTIONS_INSTANCE_TEXTFONT_DESC"] = "Muda o bot\195\163o de inst\195\162ncia de fonte de texto."
L["STRING_OPTIONS_INSTANCE_TEXTSIZE"] = "Tamanho de texto"
L["STRING_OPTIONS_INSTANCE_TEXTSIZE_DESC"] = "Muda o bot\195\163o de inst\195\162ncia de tamanho de texto."
L["STRING_OPTIONS_INTERFACEDIT"] = "Editar Interface" -- Needs review
L["STRING_OPTIONS_LEFT_MENU_ANCHOR"] = "Op\195\167\195\181es de Menu:"
L["STRING_OPTIONS_LOCKSEGMENTS"] = "Segmentos travados"
L["STRING_OPTIONS_LOCKSEGMENTS_DESC"] = "Quando habilitado, modificar um seguimento em uma janela tamb\195\169m modifica todas as outras."
L["STRING_OPTIONS_MAXINSTANCES"] = "Quantidade de Janelas" -- Needs review
L["STRING_OPTIONS_MAXINSTANCES_DESC"] = "Limita o numero de janelas que podem ser criadas.\
\
Voc\195\170 pode abrir ou reabrir as janelas atrav\195\169s do bot\195\163o de janela localizado a esquerda do bot\195\163o de fechar." -- Needs review
L["STRING_OPTIONS_MAXSEGMENTS"] = "Quantidade de Segmentos" -- Needs review
L["STRING_OPTIONS_MAXSEGMENTS_DESC"] = "Esta op\195\167\195\163o controla quantos segmentos voc\195\170 deseja manter.\
\
O recomendado eh |cFFFFFFFF12|r, mas sinta-se livre para ajustar este numero como desejar.\
\
Computadores com |cFFFFFFFF2GB|r ou menos de memoria ram devem manter um numero de segmentos baixo, isto pode ajudar a preservar a memoria." -- Needs review
L["STRING_OPTIONS_MEMORYT"] = "Ajuste de Mem\195\179ria" -- Needs review
L["STRING_OPTIONS_MEMORYT_DESC"] = "Details! possui mecanismos internos que lidam com a memoria e tentam ajustar o uso dela de acordo com a memoria dispon\195\173vel no seu sistema.\
\
Tamb\195\169m eh recomendado limitar o numero de segmentos se o seu computador tiver |cFFFFFFFF2GB|r ou menos de memoria." -- Needs review
L["STRING_OPTIONS_MENU2_X"] = "Menu Pos X"
L["STRING_OPTIONS_MENU2_X_DESC"] = "Muda a posi\195\167\195\163o de todos os bot\195\181es de menu da direita."
L["STRING_OPTIONS_MENU2_Y"] = "Menu Pos Y"
L["STRING_OPTIONS_MENU2_Y_DESC"] = "Muda a posi\195\167\195\163o de todos os bot\195\181es de menu da direita."
L["STRING_OPTIONS_MENU_ALPHA"] = "Interagir auto transpar\195\170ncia:"
L["STRING_OPTIONS_MENU_ALPHAENABLED"] = "Habilitar"
L["STRING_OPTIONS_MENU_ALPHAENABLED_DESC"] = "Habilita ou desabilita a auto-transpar\195\170ncia. Quando habilitada, o alfa muda automaticamente quando voc\195\170 arrasta e solta a janela.\
\
|cFFFFFF00Important|r: Essa configura\195\167\195\163o sobrescreve o alfa selecionado para a cor de janela." -- Needs review
L["STRING_OPTIONS_MENU_ALPHAENTER"] = "Quando interagindo"
L["STRING_OPTIONS_MENU_ALPHAENTER_DESC"] = "Quando voc\195\170 tiver um mouse sobre uma janela, a transpar\195\170ncia muda para este valor"
L["STRING_OPTIONS_MENU_ALPHAICONSTOO"] = "Afetar bot\195\181es"
L["STRING_OPTIONS_MENU_ALPHAICONSTOO_DESC"] = "Se habilitado, todos os \195\173cones e bot\195\181es tamb\195\169m ter\195\163o seu alfa afetado por essa op\195\167\195\163o."
L["STRING_OPTIONS_MENU_ALPHALEAVE"] = "Em espera"
L["STRING_OPTIONS_MENU_ALPHALEAVE_DESC"] = "Quando voc\195\170 n\195\163o tiver o mouse sobre a janela, a transpar\195\170ncia muda para este valor"
L["STRING_OPTIONS_MENU_ALPHAWARNING"] = "Auto transpar\195\170ncia est\195\161 habilitada, o alfa pode n\195\163o ser afetado."
L["STRING_OPTIONS_MENU_ANCHOR"] = "Lado da \195\130ncora do Menu"
L["STRING_OPTIONS_MENU_ANCHOR_DESC"] = "Muda a posi\195\167\195\163o da \195\162ncora do menu, podendo posiciona-lo a direita ou esquerda da janela." -- Needs review
L["STRING_OPTIONS_MENU_ATTRIBUTE_ANCHORX"] = "Pos X"
L["STRING_OPTIONS_MENU_ATTRIBUTE_ANCHORX_DESC"] = "Ajusta a localiza\195\167\195\163o de atributo de texto no eixo X." -- Needs review
L["STRING_OPTIONS_MENU_ATTRIBUTE_ANCHORY"] = "Pos Y"
L["STRING_OPTIONS_MENU_ATTRIBUTE_ANCHORY_DESC"] = "Ajusta a localiza\195\167\195\163o de atributo de texto no eixo Y." -- Needs review
L["STRING_OPTIONS_MENU_ATTRIBUTE_ENABLED"] = "Habilitar"
L["STRING_OPTIONS_MENU_ATTRIBUTE_ENABLED_DESC"] = "Habilita ou desabilita o nome do atributo que est\195\161 sendo exibido atualmente nessa janela." -- Needs review
L["STRING_OPTIONS_MENU_ATTRIBUTE_FONT"] = "Fonte de texto"
L["STRING_OPTIONS_MENU_ATTRIBUTE_FONT_DESC"] = "Seleciona a fonte de texto para o texto do atributo."
L["STRING_OPTIONS_MENU_ATTRIBUTESETTINGS_ANCHOR"] = "Configura\195\167\195\181es:"
L["STRING_OPTIONS_MENU_ATTRIBUTE_SHADOW"] = "Sombreamento"
L["STRING_OPTIONS_MENU_ATTRIBUTE_SHADOW_DESC"] = "Habilita ou desabilita o sombreamento no texto"
L["STRING_OPTIONS_MENU_ATTRIBUTE_SIDE"] = "\195\130ncora de texto"
L["STRING_OPTIONS_MENU_ATTRIBUTE_SIDE_DESC"] = "Selecionar onde o texto est\195\161 ancorado."
L["STRING_OPTIONS_MENU_ATTRIBUTETEXT_ANCHOR"] = "Textos:"
L["STRING_OPTIONS_MENU_ATTRIBUTE_TEXTCOLOR"] = "Cor do texto"
L["STRING_OPTIONS_MENU_ATTRIBUTE_TEXTCOLOR_DESC"] = "Muda a cor do texto do atributo."
L["STRING_OPTIONS_MENU_ATTRIBUTE_TEXTSIZE"] = "Tamanho do texto"
L["STRING_OPTIONS_MENU_ATTRIBUTE_TEXTSIZE_DESC"] = "Ajusta o tamanho do texto do atributo."
L["STRING_OPTIONS_MENU_AUTOHIDE_ANCHOR"] = "Auto esconder bot\195\181es de menu"
L["STRING_OPTIONS_MENU_AUTOHIDE_DESC"] = "Quando habilitado o menu automaticamente esconde a si mesmo quando o mouse deixa a janela e aparece novamente quando voc\195\170 estiver interagindo com ela novamente." -- Needs review
L["STRING_OPTIONS_MENU_AUTOHIDE_LEFT"] = "Menu auto esconder"
L["STRING_OPTIONS_MENU_AUTOHIDE_RIGHT"] = "Menu auto esconder"
L["STRING_OPTIONS_MENU_BUTTONSSIZE"] = "Tamanho dos bot\195\181es" -- Needs review
L["STRING_OPTIONS_MENU_BUTTONSSIZE_DESC"] = "Escolher os tamanhos dos bot\195\181es. Isso tamb\195\169m modifica os \195\173cones adicionados por plugins." -- Needs review
L["STRING_OPTIONSMENU_COMBAT"] = "Combate" -- Needs review
L["STRING_OPTIONSMENU_DATACHART"] = "Dados Para Gr\195\161ficos" -- Needs review
L["STRING_OPTIONSMENU_DATACOLLECT"] = "Coletor de Dados" -- Needs review
L["STRING_OPTIONSMENU_DATAFEED"] = "Alimenta\195\167\195\163o de Dados" -- Needs review
L["STRING_OPTIONSMENU_DISPLAY"] = "Display" -- Needs review
L["STRING_OPTIONSMENU_DISPLAY_DESC"] = "Ajustes b\195\161sicos gerais e controles r\195\161pidos da janela." -- Needs review
L["STRING_OPTIONS_MENU_IGNOREBARS"] = "Ignore linhas"
L["STRING_OPTIONS_MENU_IGNOREBARS_DESC"] = "Quando habilitada, todas as linhas nessa janela n\195\163o ser\195\163o afetadas por esse mecanismo." -- Needs review
L["STRING_OPTIONSMENU_LEFTMENU"] = "Menu da Esquerdo" -- Needs review
L["STRING_OPTIONSMENU_MISC"] = "Diversos" -- Needs review
L["STRING_OPTIONSMENU_PERFORMANCE"] = "Ajustes de Performance" -- Needs review
L["STRING_OPTIONSMENU_PLUGINS"] = "Gerenciador de Plugins" -- Needs review
L["STRING_OPTIONSMENU_PROFILES"] = "Perfis" -- Needs review
L["STRING_OPTIONSMENU_RIGHTMENU"] = "Menu da Direita"
L["STRING_OPTIONSMENU_ROWSETTINGS"] = "Ajustes das Barras" -- Needs review
L["STRING_OPTIONSMENU_ROWTEXTS"] = "Ajustes dos Textos" -- Needs review
L["STRING_OPTIONS_MENU_SHOWBUTTONS"] = "Exibir bot\195\181es"
L["STRING_OPTIONS_MENU_SHOWBUTTONS_DESC"] = "Seleciona quais bot\195\181es s\195\163o exibidos na barra de ferramentas."
L["STRING_OPTIONSMENU_SHOWHIDE"] = "Mostrar e Esconder Janela" -- Needs review
L["STRING_OPTIONSMENU_SKIN"] = "Seletor de Skin" -- Needs review
L["STRING_OPTIONSMENU_SPELLS"] = "Customiza\195\167\195\163o de Magia" -- Needs review
L["STRING_OPTIONSMENU_TITLETEXT"] = "Texto do T\195\173tulo" -- Needs review
L["STRING_OPTIONSMENU_TOOLTIP"] = "Tooltips" -- Needs review
L["STRING_OPTIONSMENU_WALLPAPER"] = "Papel de Parede" -- Needs review
L["STRING_OPTIONSMENU_WINDOW"] = "Configura\195\167\195\181es da Janela" -- Needs review
L["STRING_OPTIONS_MENU_X"] = "Menu Pos X"
L["STRING_OPTIONS_MENU_X_DESC"] = "Muda a posi\195\167\195\163o de todos os bot\195\181es de menu a esquerda."
L["STRING_OPTIONS_MENU_Y"] = "Menu Pos Y"
L["STRING_OPTIONS_MENU_Y_DESC"] = "Muda a posi\195\167\195\163o de todos os bot\195\181es de menu a esquerda."
L["STRING_OPTIONS_MICRODISPLAYSSIDE"] = "\195\162ncora dos Mini Displays"
L["STRING_OPTIONS_MICRODISPLAYSSIDE_DESC"] = "Muda a posi\195\167\195\163o dos mini displays para a posi\195\167\195\163o no topo ou no fundo da janela." -- Needs review
L["STRING_OPTIONS_MICRODISPLAYWARNING"] = "Mini displays n\195\163o est\195\163o sendo mostrados pois a barra de status esta desligada."
L["STRING_OPTIONS_MINIMAP"] = "\195\141cone no Mini Mapa" -- Needs review
L["STRING_OPTIONS_MINIMAP_ACTION"] = "no clique"
L["STRING_OPTIONS_MINIMAP_ACTION1"] = "Abrir painel de controle"
L["STRING_OPTIONS_MINIMAP_ACTION2"] = "Resetar segmentos"
L["STRING_OPTIONS_MINIMAP_ACTION_DESC"] = "Selecionar o que fazer quando o \195\173cone do minimapa \195\169 clicado com o bot\195\163o esquerdo do mouse."
L["STRING_OPTIONS_MINIMAP_ANCHOR"] = "Minimapa:"
L["STRING_OPTIONS_MINIMAP_DESC"] = "Mostra ou esconde o \195\173cone no mini mapa." -- Needs review
L["STRING_OPTIONS_MISCTITLE"] = "Configura\195\167\195\181es Diversas" -- Needs review
L["STRING_OPTIONS_MISCTITLE2"] = "Essa op\195\167\195\163o controla v\195\161rias op\195\167\195\181es."
L["STRING_OPTIONS_NICKNAME"] = "Apelido"
L["STRING_OPTIONS_NICKNAME_DESC"] = "Digite o seu apelido neste campo. O apelido escolhido ser\195\161 enviado aos membros da sua guilda e o Details! ira substituir o nome do personagem pelo apelido." -- Needs review
L["STRING_OPTIONS_OVERALL_ALL"] = "Todos os segmentos"
L["STRING_OPTIONS_OVERALL_ALL_DESC"] = "Todos os segmentos s\195\163o adicionados aos dados globais."
L["STRING_OPTIONS_OVERALL_ANCHOR"] = "Dados Globais:"
L["STRING_OPTIONS_OVERALL_CHALLENGE"] = "Limpar em Modo desafio"
L["STRING_OPTIONS_OVERALL_CHALLENGE_DESC"] = "Quando habilitado, os dados globais s\195\163o limpos automaticamente quando um nova nova tentativa no modo desafio come\195\167a."
L["STRING_OPTIONS_OVERALL_DUNGEONBOSS"] = "Chefes de Masmorras"
L["STRING_OPTIONS_OVERALL_DUNGEONBOSS_DESC"] = "Segmentos com chefes de masmorras s\195\163o adicionados aos dados globais."
L["STRING_OPTIONS_OVERALL_DUNGEONCLEAN"] = "'Trash' de Masmorra"
L["STRING_OPTIONS_OVERALL_DUNGEONCLEAN_DESC"] = "Segmentos de limpeza de 'trash mobs' em masmorras s\195\163o adicionados aos dados globais." -- Needs review
L["STRING_OPTIONS_OVERALL_NEWBOSS"] = "Limpar em um novo chefe"
L["STRING_OPTIONS_OVERALL_NEWBOSS_DESC"] = "Quando habilitado, os dados gerais s\195\163o limpos automaticamente quando enfrentando um novo chefe."
L["STRING_OPTIONS_OVERALL_RAIDBOSS"] = "Chefes de raide" -- Needs review
L["STRING_OPTIONS_OVERALL_RAIDBOSS_DESC"] = "Segmentos com encontros de raide s\195\163o adicionados aos dados globais." -- Needs review
L["STRING_OPTIONS_OVERALL_RAIDCLEAN"] = "Trash de Raide" -- Needs review
L["STRING_OPTIONS_OVERALL_RAIDCLEAN_DESC"] = "Segmentos de limpeza de 'trash mobs' em raides s\195\163o adicionados aos dados globais." -- Needs review
L["STRING_OPTIONS_PANIMODE"] = "Modo de P\195\162nico" -- Needs review
L["STRING_OPTIONS_PANIMODE_DESC"] = "Quando voc\195\170 cair do jogo durante uma luta contra um Chefe de uma Raide e esta op\195\167\195\163o estiver ativa, todos os segmentos s\195\163o apagados para o processo de logoff ser r\195\161pido." -- Needs review
L["STRING_OPTIONS_PERCENT_TYPE"] = "Tipo de porcentagem"
L["STRING_OPTIONS_PERCENT_TYPE_DESC"] = "Muda o m\195\169todo de porcentagem:\
\
|cFFFFFF00Relativo ao Total|r: a porcentagem indica o total da fra\195\167\195\163o que o jogador fez comparado ao total feito pela raide.\
\
|cFFFFFF00Relativo ao Melhor Jogador|r: A porcentagem \195\169 relativa com o total do melhor jogador."
L["STRING_OPTIONS_PERFORMANCE"] = "Performance"
L["STRING_OPTIONS_PERFORMANCE1"] = "Ajustes de Performance"
L["STRING_OPTIONS_PERFORMANCE1_DESC"] = "Estas op\195\167\195\181es podem ajudar no desempenho deste addon." -- Needs review
L["STRING_OPTIONS_PERFORMANCE_ANCHOR"] = "Geral:"
L["STRING_OPTIONS_PERFORMANCE_ARENA"] = "Arena"
L["STRING_OPTIONS_PERFORMANCE_BG15"] = "Campo de batalha 15"
L["STRING_OPTIONS_PERFORMANCE_BG40"] = "Campo de batalha 40"
L["STRING_OPTIONS_PERFORMANCECAPTURES"] = "Coletor de Informa\195\167\195\163o do Combate" -- Needs review
L["STRING_OPTIONS_PERFORMANCECAPTURES_DESC"] = "Esta op\195\167\195\163o controla quais informa\195\167\195\181es ser\195\163o capturadas durante o combate." -- Needs review
L["STRING_OPTIONS_PERFORMANCE_DUNGEON"] = "Masmorra"
L["STRING_OPTIONS_PERFORMANCE_ENABLE"] = "Habilitar"
L["STRING_OPTIONS_PERFORMANCE_ENABLE_DESC"] = "Se habilitado, essas configura\195\167\195\181es ser\195\163o aplicadas quando sua raide for compat\195\173vel com o tipo de raide selecionado." -- Needs review
L["STRING_OPTIONS_PERFORMANCE_MYTHIC"] = "M\195\173tico"
L["STRING_OPTIONS_PERFORMANCE_PROFILE_LOAD"] = "Perfil de desempenho alterado: "
L["STRING_OPTIONS_PERFORMANCEPROFILES_ANCHOR"] = "Perfis de performance:"
L["STRING_OPTIONS_PERFORMANCE_RAID15"] = "Raide 10-15" -- Needs review
L["STRING_OPTIONS_PERFORMANCE_RAID30"] = "Raide 16-30" -- Needs review
L["STRING_OPTIONS_PERFORMANCE_RF"] = "Localizador de raide" -- Needs review
L["STRING_OPTIONS_PERFORMANCE_TYPES"] = "Tipo"
L["STRING_OPTIONS_PERFORMANCE_TYPES_DESC"] = "Estes s\195\163o os tipos de raide onde diferentes op\195\167\195\181es podem mudar automaticamente." -- Needs review
L["STRING_OPTIONS_PICKCOLOR"] = "cor"
L["STRING_OPTIONS_PICONS_DIRECTION"] = "Dire\195\167\195\163o dos \195\173cones de plugin"
L["STRING_OPTIONS_PICONS_DIRECTION_DESC"] = "Muda a dire\195\167\195\163o dos \195\173cones dos plugins que s\195\163o exibidos na barra de ferramentas."
L["STRING_OPTIONS_PLUGINS"] = "Plugins"
L["STRING_OPTIONS_PLUGINS_AUTHOR"] = "Autor"
L["STRING_OPTIONS_PLUGINS_ENABLED"] = "Habilitar"
L["STRING_OPTIONS_PLUGINS_NAME"] = "Nome"
L["STRING_OPTIONS_PLUGINS_OPTIONS"] = "Op\195\167\195\181es" -- Needs review
L["STRING_OPTIONS_PLUGINS_RAID_ANCHOR"] = "Plugins de raide" -- Needs review
L["STRING_OPTIONS_PLUGINS_SOLO_ANCHOR"] = "Solo Plugins"
L["STRING_OPTIONS_PLUGINS_TOOLBAR_ANCHOR"] = "Toolbar Plugins"
L["STRING_OPTIONS_PLUGINS_VERSION"] = "Vers\195\163o"
L["STRING_OPTIONS_PRESETNONAME"] = "De um nome a sua predefini\195\167\195\163o." -- Needs review
L["STRING_OPTIONS_PRESETTOOLD"] = "Esta predefini\195\167\195\163o requer uma vers\195\163o atualizada do Details!." -- Needs review
L["STRING_OPTIONS_PROFILE_COPYOKEY"] = "C\195\179pia de perfil bem sucedida."
L["STRING_OPTIONS_PROFILE_FIELDEMPTY"] = "Campo do nome est\195\161 vazio"
L["STRING_OPTIONS_PROFILE_LOADED"] = "Perfil carregado:"
L["STRING_OPTIONS_PROFILE_NOTCREATED"] = "Perfil n\195\163o criado."
L["STRING_OPTIONS_PROFILE_POSSIZE"] = "Salvar tamanho e posi\195\167\195\163o"
L["STRING_OPTIONS_PROFILE_POSSIZE_DESC"] = "Quando habilitado, este perfil preserva o posicionamento e o tamanho das janelas."
L["STRING_OPTIONS_PROFILE_REMOVEOKEY"] = "Remo\195\167\195\163o de perfil bem sucedida."
L["STRING_OPTIONS_PROFILES_ANCHOR"] = "Configura\195\167\195\181es:"
L["STRING_OPTIONS_PROFILES_COPY"] = "Copiar perfil de"
L["STRING_OPTIONS_PROFILES_COPY_DESC"] = "Copia todas as configura\195\167\195\181es do perfil selecionado para o atual perfil, sobrescrevendo todos os valores."
L["STRING_OPTIONS_PROFILES_CREATE"] = "Criar perfil"
L["STRING_OPTIONS_PROFILES_CREATE_DESC"] = "Criar novo perfil."
L["STRING_OPTIONS_PROFILES_CURRENT"] = "Perfil atual:"
L["STRING_OPTIONS_PROFILES_CURRENT_DESC"] = "Este \195\169 o nome do seu perfil atualmente ativo."
L["STRING_OPTIONS_PROFILE_SELECT"] = "Selecione um perfil."
L["STRING_OPTIONS_PROFILES_ERASE"] = "Remover perfil"
L["STRING_OPTIONS_PROFILES_ERASE_DESC"] = "Remove o perfil selecionado."
L["STRING_OPTIONS_PROFILES_RESET"] = "Restabelecer o perfil atual" -- Needs review
L["STRING_OPTIONS_PROFILES_RESET_DESC"] = "Reinicia para os valores padr\195\163o todas as configura\195\167\195\181es do perfil selecionado"
L["STRING_OPTIONS_PROFILES_SELECT"] = "Selecionar perfil"
L["STRING_OPTIONS_PROFILES_SELECT_DESC"] = "Carrega um perfil, todas as configura\195\167\195\181es s\195\163o sobrescritas pelas configura\195\167\195\181es do novo perfil"
L["STRING_OPTIONS_PROFILES_TITLE"] = "Perfis"
L["STRING_OPTIONS_PROFILES_TITLE_DESC"] = "Essa op\195\167\195\163o permite a voc\195\170 dividir as mesmas configura\195\167\195\181es com diferentes personagens"
L["STRING_OPTIONS_PS_ABBREVIATE"] = "Abreviar Texto" -- Needs review
L["STRING_OPTIONS_PS_ABBREVIATE_COMMA"] = "Separado por pontos" -- Needs review
L["STRING_OPTIONS_PS_ABBREVIATE_DESC"] = "Escolha o m\195\169todo de abrevia\195\167\195\163o para o Dps e Hps.\
\
|cFFFFFFFFNenhuma|r: sem abrevia\195\167\195\163o, o numero inteiro e mostrado.\
\
|cFFFFFFFFCentenas I|r: o numero e reduzido e uma letra indica o valor.\
\
59874 = 59.8K\
100.000 = 100.0K\
19.530.000 = 19.53M\
\
|cFFFFFFFFCentenas II|r: o numero e reduzido e uma letra indica o valor.\
\
59874 = 59.8K\
100.000 = 100K\
19.530.000 = 19.53M" -- Needs review
L["STRING_OPTIONS_PS_ABBREVIATE_NONE"] = "Nenhuma"
L["STRING_OPTIONS_PS_ABBREVIATE_TOK"] = "Centena I" -- Needs review
L["STRING_OPTIONS_PS_ABBREVIATE_TOK0"] = "Milhar I Caixa-alta" -- Needs review
L["STRING_OPTIONS_PS_ABBREVIATE_TOK0MIN"] = "Milhar I" -- Needs review
L["STRING_OPTIONS_PS_ABBREVIATE_TOK2"] = "Centena II Caixa-Alta" -- Needs review
L["STRING_OPTIONS_PS_ABBREVIATE_TOK2MIN"] = "Centena II" -- Needs review
L["STRING_OPTIONS_PS_ABBREVIATE_TOKMIN"] = "Centena I" -- Needs review
L["STRING_OPTIONS_PVPFRAGS"] = "Apenas Abates de PvP" -- Needs review
L["STRING_OPTIONS_PVPFRAGS_DESC"] = "Quando ativado, ser\195\163o registrados apenas mortes de jogadores da fac\195\167\195\163o inimiga." -- Needs review
L["STRING_OPTIONS_REALMNAME"] = "Remover o Nome do Reino"
L["STRING_OPTIONS_REALMNAME_DESC"] = "Quando ativado, o nome do reino do que o personagem pertence n\195\163o eh mostrado.\
\
|cFFFFFFFFExemplo:|r\
\
Charles-Azralon |cFFFFFFFF(desativado)|r\
Charles |cFFFFFFFF(ativado)|r" -- Needs review
L["STRING_OPTIONS_RESET_BUTTON_ANCHOR"] = "Bot\195\163o Reset:"
L["STRING_OPTIONS_RESET_OVERLAY"] = "Sobrepor cor"
L["STRING_OPTIONS_RESET_OVERLAY_DESC"] = "Modifica a cor do bot\195\163o reset." -- Needs review
L["STRING_OPTIONS_RESET_SMALL"] = "Always Small"
L["STRING_OPTIONS_RESET_SMALL_DESC"] = "Quando habilitado, o bot\195\163o reset sempre  ser\195\161 exibido no seu menor tamanho.\
\
Apenas aplicado quando o bot\195\163o reset est\195\161 hospedado nesta inst\195\162ncia."
L["STRING_OPTIONS_RESET_TEXTCOLOR"] = "Cor do texto"
L["STRING_OPTIONS_RESET_TEXTCOLOR_DESC"] = "Modifica o bot\195\163o reset da cor de texto.\
\
Apenas aplicado quando o bot\195\163o reset est\195\161 hospedado nesta inst\195\162ncia."
L["STRING_OPTIONS_RESET_TEXTFONT"] = "Text Font"
L["STRING_OPTIONS_RESET_TEXTFONT_DESC"] = "Modifica o bot\195\163o reset da fonte de texto.\
\
Apenas aplicado quando o bot\195\163o reset est\195\161 hospedado nesta inst\195\162ncia."
L["STRING_OPTIONS_RESET_TEXTSIZE"] = "Text Size"
L["STRING_OPTIONS_RESET_TEXTSIZE_DESC"] = "Modifica o bot\195\163o reset da tamanho de texto.\
\
Apenas aplicado quando o bot\195\163o reset est\195\161 hospedado nesta inst\195\162ncia."
L["STRING_OPTIONS_ROW_SETTING_ANCHOR"] = "Geral:"
L["STRING_OPTIONS_SAVELOAD"] = "Salvar e Carregar"
L["STRING_OPTIONS_SAVELOAD_APPLYALL"] = "A skin atual foi aplicada a todas as outras inst\195\162ncias."
L["STRING_OPTIONS_SAVELOAD_APPLYALL_DESC"] = "Aplica a skin atual em todas as janelas criadas." -- Needs review
L["STRING_OPTIONS_SAVELOAD_APPLYTOALL"] = "aplicar em todas as janelas"
L["STRING_OPTIONS_SAVELOAD_CREATE_DESC"] = "Digite o nome da skin customizada no campo e clique no bot\195\163o 'criar'.\
\
Esse processo cria uma skin customizada que voc\195\170 pode carregar em outras inst\195\162ncias ou apenas deixar salva para outra hora." -- Needs review
L["STRING_OPTIONS_SAVELOAD_DESC"] = "Estas op\195\167\195\181es permitem guardar as configura\195\167\195\181es da janela podendo carrega-las em outros personagens." -- Needs review
L["STRING_OPTIONS_SAVELOAD_ERASE_DESC"] = "Essa op\195\167\195\163o apaga a skin previamente salva." -- Needs review
L["STRING_OPTIONS_SAVELOAD_EXPORT"] = "Exportar" -- Needs review
L["STRING_OPTIONS_SAVELOAD_EXPORT_COPY"] = "Pressione CTRL + C" -- Needs review
L["STRING_OPTIONS_SAVELOAD_EXPORT_DESC"] = "Salva a skin no formato de texto." -- Needs review
L["STRING_OPTIONS_SAVELOAD_IMPORT"] = "Importar" -- Needs review
L["STRING_OPTIONS_SAVELOAD_IMPORT_DESC"] = "Importa uma skin " -- Needs review
L["STRING_OPTIONS_SAVELOAD_IMPORT_OKEY"] = "Skin importada com sucesso." -- Needs review
L["STRING_OPTIONS_SAVELOAD_LOAD"] = "Carregar" -- Needs review
L["STRING_OPTIONS_SAVELOAD_LOAD_DESC"] = "Escolha uma das skins previamente salvas para ser aplicada a atual janela selecionada." -- Needs review
L["STRING_OPTIONS_SAVELOAD_MAKEDEFAULT"] = "Salva a skin padr\195\163o."
L["STRING_OPTIONS_SAVELOAD_PNAME"] = "Nome"
L["STRING_OPTIONS_SAVELOAD_REMOVE"] = "Excluir" -- Needs review
L["STRING_OPTIONS_SAVELOAD_RESET"] = "resetar p/ padr\195\181es" -- Needs review
L["STRING_OPTIONS_SAVELOAD_SAVE"] = "salvar"
L["STRING_OPTIONS_SAVELOAD_SKINCREATED"] = "Skin criada."
L["STRING_OPTIONS_SAVELOAD_STD_DESC"] = "Skin padr\195\163o \195\169 aplicada em todas as novas inst\195\162ncias criadas." -- Needs review
L["STRING_OPTIONS_SAVELOAD_STDSAVE"] = "Skin padr\195\163o foi salva, novas janelas estar\195\163o usando essa skin por padr\195\163o." -- Needs review
L["STRING_OPTIONS_SCROLLBAR"] = "Barra de Rolagem"
L["STRING_OPTIONS_SCROLLBAR_DESC"] = "Ativa ou desativa a barra de rolagem.\
\
Details! usa como padr\195\163o um mecanismo para estivar a janela.\
\
A |cFFFFFFFFal\195\167a|r para estica-lo encontra-se fora da janela em cima do bot\195\163o de fechar e de criar janelas." -- Needs review
L["STRING_OPTIONS_SEGMENTSSAVE"] = "Segmentos Salvos"
L["STRING_OPTIONS_SEGMENTSSAVE_DESC"] = "Esta op\195\167\195\163o controla quantos segmentos voc\195\170 deseja salvar entre as sess\195\181es de jogo.\
\
Valores altos podem fazer o tempo de logoff do seu personagem demorar mais.\
\
Se voc\195\170 raramente olha os dados da raide do dia anterior, eh muito recomendado deixar esta op\195\167\195\163o em 1|cFFFFFFFF1|r." -- Needs review
L["STRING_OPTIONS_SHOWHIDE"] = "Exibir & Ocultar Configura\195\167\195\181es"
L["STRING_OPTIONS_SHOWHIDE_DESC"] = "Controla quando uma janela deve se ocultar ou aparecer na janela."
L["STRING_OPTIONS_SHOW_SIDEBARS"] = "Mostrar Barras Laterais"
L["STRING_OPTIONS_SHOW_SIDEBARS_DESC"] = "Mostrar ou esconder as barras laterais na esquerda e direita da janela."
L["STRING_OPTIONS_SHOW_STATUSBAR"] = "Exibir barra de Status"
L["STRING_OPTIONS_SHOW_STATUSBAR_DESC"] = "Exibe ou Oculta a barra de status inferior."
L["STRING_OPTIONS_SHOW_TOTALBAR"] = "Exibir barra total"
L["STRING_OPTIONS_SHOW_TOTALBAR_COLOR_DESC"] = "Seleciona a cor. A transpar\195\170ncia segue a linha do valor alfa."
L["STRING_OPTIONS_SHOW_TOTALBAR_DESC"] = "Exibe ou oculta a barra total"
L["STRING_OPTIONS_SHOW_TOTALBAR_ICON"] = "\195\141cone"
L["STRING_OPTIONS_SHOW_TOTALBAR_ICON_DESC"] = "Seleciona o \195\173cone exibido na barra total"
L["STRING_OPTIONS_SHOW_TOTALBAR_INGROUP"] = "Apenas em grupo"
L["STRING_OPTIONS_SHOW_TOTALBAR_INGROUP_DESC"] = "A barra total n\195\163o \195\169 exibida se voc\195\170 n\195\163o estiver em um grupo."
L["STRING_OPTIONS_SIZE"] = "Tamanho"
L["STRING_OPTIONS_SKIN_A"] = "Ajustes da Pele (Skin)"
L["STRING_OPTIONS_SKIN_A_DESC"] = "Estas op\195\167\195\181es alteram as caracter\195\173sticas gerais da janela." -- Needs review
L["STRING_OPTIONS_SKIN_ELVUI_BUTTON1"] = "Alinhar Com o Chat da Direita" -- Needs review
L["STRING_OPTIONS_SKIN_ELVUI_BUTTON1_DESC"] = "Move e redimensiona as janelas |cFFFFFF00#1|r e |cFFFFFF00#2|r colocando-as em cima do chat da direita.\
\
Este processo n\195\163o trava ou gruda as janelas." -- Needs review
L["STRING_OPTIONS_SKIN_EXTRA_OPTIONS_ANCHOR"] = "Op\195\167\195\181es de Skin:"
L["STRING_OPTIONS_SKIN_LOADED"] = "Carregamento de skin bem sucedido."
L["STRING_OPTIONS_SKIN_PRESETS_ANCHOR"] = "Salvar Skin:" -- Needs review
L["STRING_OPTIONS_SKIN_REMOVED"] = "skin removida."
L["STRING_OPTIONS_SKIN_SELECT"] = "selecione uma skin"
L["STRING_OPTIONS_SKIN_SELECT_ANCHOR"] = "Sele\195\167\195\163o de skin:"
L["STRING_OPTIONS_SOCIAL"] = "Social"
L["STRING_OPTIONS_SOCIAL_DESC"] = "Diga-nos o seu apelido ou como voc\195\170 \195\169 conhecido na sua guilda." -- Needs review
L["STRING_OPTIONS_SPELL_ADD"] = "Adicionar" -- Needs review
L["STRING_OPTIONS_SPELL_ADDICON"] = "Novo \195\141cone:" -- Needs review
L["STRING_OPTIONS_SPELL_ADDNAME"] = "Novo Nome:" -- Needs review
L["STRING_OPTIONS_SPELL_ADDSPELL"] = "Adicionar Magia" -- Needs review
L["STRING_OPTIONS_SPELL_ADDSPELLID"] = "Id da Magia" -- Needs review
L["STRING_OPTIONS_SPELL_CLOSE"] = "Fechar" -- Needs review
L["STRING_OPTIONS_SPELL_ICON"] = "\195\141cone" -- Needs review
L["STRING_OPTIONS_SPELL_IDERROR"] = "Id da magias esta inv\195\161lido." -- Needs review
L["STRING_OPTIONS_SPELL_INDEX"] = "Index" -- Needs review
L["STRING_OPTIONS_SPELL_NAME"] = "Nome" -- Needs review
L["STRING_OPTIONS_SPELL_NAMEERROR"] = "O nome da magia esta inv\195\161lido." -- Needs review
L["STRING_OPTIONS_SPELL_NOTFOUND"] = "Magia n\195\163o encontrada." -- Needs review
L["STRING_OPTIONS_SPELL_REMOVE"] = "Remover" -- Needs review
L["STRING_OPTIONS_SPELL_RESET"] = "Resetar" -- Needs review
L["STRING_OPTIONS_SPELL_SPELLID"] = "ID da Magia" -- Needs review
L["STRING_OPTIONS_SPELL_SPELLID_DESC"] = "A ID \195\169 o n\195\186mero \195\186nico para identificar uma magia dentro do jogo. H\195\161 v\195\161rias formas de obt\195\170-lo:\
\
- Na janela de detalhes do jogador, segure o bot\195\163o SHIFT e passe o mouse sobre uma barra de uma habilidade.\
- Digite o nome da habilidade no campo do ID, uma lista ser\195\161 mostrada em um tooltip.\
- P\195\161ginas na internet da comunidade do WoW, na maioria deles o id da habilidade esta junto ao link do site.\
- Navegando no bloco abaixo:" -- Needs review
L["STRING_OPTIONS_STRETCH"] = "\195\130ncora do bot\195\163o de esticar"
L["STRING_OPTIONS_STRETCH_DESC"] = "Altera a posi\195\167\195\163o da al\195\167a de esticar.\
\
|cFFFFFF00Cima|r: a al\195\167a \195\169 posta no canto direito superior da janela.\
\
|cFFFFFF00Baixo|r: a al\195\167a \195\169 posta no centro abaixo da janela." -- Needs review
L["STRING_OPTIONS_STRETCHTOP"] = "Bot\195\163o de esticar sempre vis\195\173vel"
L["STRING_OPTIONS_STRETCHTOP_DESC"] = "O bot\195\163o de esticar ser\195\161 posto mais alto do que as outras janelas e estar\195\161 sempre vis\195\173vel ao passar o mouse sobre ele.\
\
|cFFFFFF00Importante|r: Movendo a al\195\167a para cima, far\195\161 com que ela as vezes fica em cima de outras janelas como sua mochila entre outros." -- Needs review
L["STRING_OPTIONS_SWITCHINFO"] = "|cFFF79F81 ESQUERDA DESATIVADO|r  |cFF81BEF7 DIREITA ATIVADO|r"
L["STRING_OPTIONS_TESTBARS"] = "Criar Barras de Teste" -- Needs review
L["STRING_OPTIONS_TEXT"] = "Op\195\167\195\181es dos Textos das Barras" -- Needs review
L["STRING_OPTIONS_TEXT_DESC"] = "Os ajustes abaixo personalizam os textos mostrados nas barras."
L["STRING_OPTIONS_TEXTEDITOR_CANCEL"] = "Cancelar" -- Needs review
L["STRING_OPTIONS_TEXTEDITOR_CANCEL_TOOLTIP"] = "Termina a edi\195\167\195\163o sem salvar as mudan\195\167as." -- Needs review
L["STRING_OPTIONS_TEXTEDITOR_COLOR"] = "Cor"
L["STRING_OPTIONS_TEXTEDITOR_COLOR_TOOLTIP"] = "Para mudar a cor do texto, selecione-o e ent\195\163o clique no bot\195\163o da cor."
L["STRING_OPTIONS_TEXTEDITOR_COMMA"] = "V\195\173rgula"
L["STRING_OPTIONS_TEXTEDITOR_COMMA_TOOLTIP"] = "Add a comma function call for use inside functions on return values."
L["STRING_OPTIONS_TEXTEDITOR_DATA"] = "[Data %s]" -- Needs review
L["STRING_OPTIONS_TEXTEDITOR_DATA_TOOLTIP"] = "Adiciona dados:\
\
|cFFFFFF00Data 1|r: representa o total feito ou o n\195\186mero da coloca\195\167\195\163o do jogador.\
\
|cFFFFFF00Data 2|r: representa o valor por segundo como DPS e HPS ou o nome do jogador.\
\
|cFFFFFF00Data 3|r: representa a porcentagem ou o \195\173cone da fac\195\167\195\163o ou da especializa\195\167\195\163o." -- Needs review
L["STRING_OPTIONS_TEXTEDITOR_DONE"] = "Terminar" -- Needs review
L["STRING_OPTIONS_TEXTEDITOR_DONE_TOOLTIP"] = "Termina a edi\195\167\195\163o e salva o c\195\179digo." -- Needs review
L["STRING_OPTIONS_TEXTEDITOR_FUNC"] = "Fun\195\167\195\163o"
L["STRING_OPTIONS_TEXTEDITOR_FUNC_TOOLTIP"] = "Adiciona uma fun\195\167\195\163o, fun\195\167\195\181es sempre precisam retornar um n\195\186mero."
L["STRING_OPTIONS_TEXTEDITOR_RESET"] = "Reset" -- Needs review
L["STRING_OPTIONS_TEXTEDITOR_RESET_TOOLTIP"] = "Limpa todo o c\195\179digo e adiciona o c\195\179digo padr\195\163o" -- Needs review
L["STRING_OPTIONS_TEXTEDITOR_TOK"] = "Centenas" -- Needs review
L["STRING_OPTIONS_TEXTEDITOR_TOK_TOOLTIP"] = "Add a abbreviation function call for use inside functions on return values."
L["STRING_OPTIONS_TEXT_FIXEDCOLOR"] = "Cor de Texto"
L["STRING_OPTIONS_TEXT_FIXEDCOLOR_DESC"] = "Muda a cor dos textos da direita e esquerda.\
\
\195\137 ignorado se |cFFFFFFFFcor pela classe|r estiver ativado."
L["STRING_OPTIONS_TEXT_FONT"] = "Fonte" -- Needs review
L["STRING_OPTIONS_TEXT_FONT_DESC"] = "Modifica a fonte do texto usado nas barras."
L["STRING_OPTIONS_TEXT_LCLASSCOLOR"] = "Texto Esquerdo Cor da Classe"
L["STRING_OPTIONS_TEXT_LCLASSCOLOR_DESC"] = "Quando ativado a cor do texto esquerdo ser\195\161 automaticamente ajustado para a cor da classe do personagem mostrado.\
\
Quando desligado a cor na caixa a direita \195\169 usado." -- Needs review
L["STRING_OPTIONS_TEXT_LEFT_ANCHOR"] = "Texto a Esquerda:"
L["STRING_OPTIONS_TEXT_LOUTILINE"] = "Sombra do Texto Esquerdo"
L["STRING_OPTIONS_TEXT_LOUTILINE_DESC"] = "Quando ativado o texto esquerdo ganhara um efeito de sombra ao seu redor."
L["STRING_OPTIONS_TEXT_LPOSITION"] = "Mostrar N\195\186mero" -- Needs review
L["STRING_OPTIONS_TEXT_LPOSITION_DESC"] = "Mostra o n\195\186mero da coloca\195\167\195\163o do jogador ao lado esquerdo do seu nome." -- Needs review
L["STRING_OPTIONS_TEXT_RCLASSCOLOR"] = "Texto Direito Cor da Classe"
L["STRING_OPTIONS_TEXT_RCLASSCOLOR_DESC"] = "Quando ativado a cor do texto da direita ser\195\161 automaticamente ajustado para a cor da classe do personagem mostrado.\
\
Quando desligado a cor na caixa a direita \195\169 usado." -- Needs review
L["STRING_OPTIONS_TEXT_RIGHT_ANCHOR"] = "Texto a Direita:"
L["STRING_OPTIONS_TEXT_ROUTILINE"] = "Sombra do Texto Direito"
L["STRING_OPTIONS_TEXT_ROUTILINE_DESC"] = "Quando ativado o texto da direita ganhara um efeito de sombra ao seu redor."
L["STRING_OPTIONS_TEXT_ROWCOLOR"] = "Cor"
L["STRING_OPTIONS_TEXT_ROWCOLOR2"] = "Cor"
L["STRING_OPTIONS_TEXT_ROWCOLOR_NOTCLASS"] = "Por classe"
L["STRING_OPTIONS_TEXT_ROWICONS_ANCHOR"] = "\195\141cones:"
L["STRING_OPTIONS_TEXT_SIZE"] = "Tamanho"
L["STRING_OPTIONS_TEXT_SIZE_DESC"] = "Altera o tamanho da fonte do texto."
L["STRING_OPTIONS_TEXT_TEXTUREL_ANCHOR"] = "Textura inferior:"
L["STRING_OPTIONS_TEXT_TEXTUREU_ANCHOR"] = "Textura superior:"
L["STRING_OPTIONS_TIMEMEASURE"] = "Medidas do Tempo"
L["STRING_OPTIONS_TIMEMEASURE_DESC"] = "|cFFFFFFFFTempo de Atividade|r: o tempo de cada membro da raide eh posto em pausa quando ele ficar ocioso e volta a contar o tempo quando ele voltar a atividade, eh a maneira mais comum de medir o Dps e Hps.\
\
|cFFFFFFFFTempo Efetivo|r: muito usado para ranqueamentos, este metodo usa o tempo total da luta para medir o Dps e Hps de todos os membros da raide."
L["STRING_OPTIONS_TOOLBAR2_SETTINGS"] = "Configura\195\167\195\181es do menu direito"
L["STRING_OPTIONS_TOOLBAR2_SETTINGS_DESC"] = "This options change the reset, instance and close buttons from the toolbar menu on the top of the window."
L["STRING_OPTIONS_TOOLBAR_SETTINGS"] = "Configura\195\167\195\181es do menu esquerdo"
L["STRING_OPTIONS_TOOLBAR_SETTINGS_DESC"] = "Essa op\195\167\195\163o altera o menu principal no topo da janela"
L["STRING_OPTIONS_TOOLBARSIDE"] = "\195\130ncora da Barra de Ferramentas" -- Needs review
L["STRING_OPTIONS_TOOLBARSIDE_DESC"] = "Coloca a barra de ferramentas no topo ou no fundo de uma janela."
L["STRING_OPTIONS_TOOLTIP_ANCHOR"] = "Configura\195\167\195\181es:"
L["STRING_OPTIONS_TOOLTIP_ANCHORTEXTS"] = "Textos:"
L["STRING_OPTIONS_TOOLTIPS_ABBREVIATION"] = "Tipo de abrevia\195\167\195\163o"
L["STRING_OPTIONS_TOOLTIPS_ABBREVIATION_DESC"] = "Escolha como os n\195\186meros exibidos nos tooltips s\195\163o formatados."
L["STRING_OPTIONS_TOOLTIPS_ANCHOR_ATTACH"] = "Lado do tooltip"
L["STRING_OPTIONS_TOOLTIPS_ANCHOR_ATTACH_DESC"] = "Qual lado do tooltip ser\195\161 anexado a sua \195\162ncora."
L["STRING_OPTIONS_TOOLTIPS_ANCHOR_POINT"] = "\195\130ncora:"
L["STRING_OPTIONS_TOOLTIPS_ANCHOR_RELATIVE"] = "Lado da \195\162ncora"
L["STRING_OPTIONS_TOOLTIPS_ANCHOR_RELATIVE_DESC"] = "Qual lado da \195\162ncora o tooltip ser\195\161 colocado."
L["STRING_OPTIONS_TOOLTIPS_ANCHOR_TEXT"] = "\195\130ncora do Tooltip"
L["STRING_OPTIONS_TOOLTIPS_ANCHOR_TEXT_DESC"] = "Clique com a direita para travar."
L["STRING_OPTIONS_TOOLTIPS_ANCHOR_TO"] = "\195\130ncora"
L["STRING_OPTIONS_TOOLTIPS_ANCHOR_TO1"] = "Barra da Janela"
L["STRING_OPTIONS_TOOLTIPS_ANCHOR_TO2"] = "Ponto na Tela"
L["STRING_OPTIONS_TOOLTIPS_ANCHOR_TO_CHOOSE"] = "Mover o Ponto na Tela"
L["STRING_OPTIONS_TOOLTIPS_ANCHOR_TO_CHOOSE_DESC"] = "Move a posi\195\167\195\163o da \195\162ncora quando o tipo da \195\162ncora esta em |cFFFFFF00Ponto na Tela|r." -- Needs review
L["STRING_OPTIONS_TOOLTIPS_ANCHOR_TO_DESC"] = "O tooltip \195\169 mostrado sobre uma barra da janela ou anexado a um ponto fixo na tela."
L["STRING_OPTIONS_TOOLTIPS_BACKGROUNDCOLOR"] = "Cor de fundo"
L["STRING_OPTIONS_TOOLTIPS_BACKGROUNDCOLOR_DESC"] = "Seleciona a cor usada no fundo."
L["STRING_OPTIONS_TOOLTIPS_FONTCOLOR"] = "Cor de texto"
L["STRING_OPTIONS_TOOLTIPS_FONTCOLOR_DESC"] = "Muda a cor usada nos textos do tooltip."
L["STRING_OPTIONS_TOOLTIPS_FONTFACE"] = "Fonte de texto"
L["STRING_OPTIONS_TOOLTIPS_FONTFACE_DESC"] = "Seleciona a fonte utilizada nos textos do tooltip."
L["STRING_OPTIONS_TOOLTIPS_FONTSHADOW"] = "Sombreamento de texto"
L["STRING_OPTIONS_TOOLTIPS_FONTSHADOW_DESC"] = "Habilita ou desabilita o sombreamento em um texto."
L["STRING_OPTIONS_TOOLTIPS_FONTSIZE"] = "Tamanho de texto."
L["STRING_OPTIONS_TOOLTIPS_FONTSIZE_DESC"] = "Aumenta ou diminui o tamanho do texto de um tooltip"
L["STRING_OPTIONS_TOOLTIPS_MAXIMIZE"] = "Maximizar m\195\169todo"
L["STRING_OPTIONS_TOOLTIPS_MAXIMIZE1"] = "usando Shift Ctrl Alt"
L["STRING_OPTIONS_TOOLTIPS_MAXIMIZE2"] = "Sempre maximizado"
L["STRING_OPTIONS_TOOLTIPS_MAXIMIZE3"] = "Apenas o Bloco do SHIFT" -- Needs review
L["STRING_OPTIONS_TOOLTIPS_MAXIMIZE4"] = "Apenas o bloco do CTRL" -- Needs review
L["STRING_OPTIONS_TOOLTIPS_MAXIMIZE5"] = "Apenas o bloco do ALT" -- Needs review
L["STRING_OPTIONS_TOOLTIPS_MAXIMIZE_DESC"] = "Seleciona o m\195\169todo utilizado para expandir a informa\195\167\195\163o exibida no tooltip.\
\
|cFFFFFF00 Teclas de Controle|r: a caixa do tooltip \195\169 expandida ao pressionar Shift, Ctrl or Alt.\
\
|cFFFFFF00 Sempre Maximizado|r: O tooltip sempre mostra toda a informa\195\167\195\163o sem nenhuma limita\195\167\195\163o de linhas.\
\
|cFFFFFF00Apenas o bloco Shift|r: O primeiro bloco no tooptip \195\169 sempre expandido por padr\195\163o.\
\
|cFFFFFF00Apenas o bloco Ctrl|r: o segundo bloco \195\169 sempre expandido por padr\195\163o.\
\
|cFFFFFF00Apenas o bloco Alt|r: o terceiro bloco \195\169 sempre expandido por padr\195\163o." -- Needs review
L["STRING_OPTIONS_TOOLTIPS_OFFSETX"] = "Dist\195\162ncia X"
L["STRING_OPTIONS_TOOLTIPS_OFFSETX_DESC"] = "Qu\195\163o distante horizontalmente o tooltip \195\169 colocado da sua \195\162ncora."
L["STRING_OPTIONS_TOOLTIPS_OFFSETY"] = "Dist\195\162ncia Y"
L["STRING_OPTIONS_TOOLTIPS_OFFSETY_DESC"] = "Qu\195\163o distante verticalmente o tooltip \195\169 colocado da sua \195\162ncora"
L["STRING_OPTIONS_TOOLTIPS_SHOWAMT"] = "Mostrar quantidade"
L["STRING_OPTIONS_TOOLTIPS_SHOWAMT_DESC"] = "Exibe um n\195\186mero indicando quantas abilidades, alvos e pets existem no tooptip." -- Needs review
L["STRING_OPTIONS_TOOLTIPS_TITLE"] = "Tooltips"
L["STRING_OPTIONS_TOOLTIPS_TITLE_DESC"] = "Essa op\195\167\195\163o controla a apar\195\170ncia dos tooltips."
L["STRING_OPTIONS_WALLPAPER_ALPHA"] = "Transpar\195\170ncia:" -- Needs review
L["STRING_OPTIONS_WALLPAPER_ANCHOR"] = "Sele\195\167\195\163o de papel de parede:"
L["STRING_OPTIONS_WALLPAPER_BLUE"] = "Azul:" -- Needs review
L["STRING_OPTIONS_WALLPAPER_CBOTTOM"] = "Recorte (|cFFC0C0C0baixo|r):" -- Needs review
L["STRING_OPTIONS_WALLPAPER_CLEFT"] = "Recorte (|cFFC0C0C0esquerda|r):" -- Needs review
L["STRING_OPTIONS_WALLPAPER_CRIGHT"] = "Recorte (|cFFC0C0C0direita|r):" -- Needs review
L["STRING_OPTIONS_WALLPAPER_CTOP"] = "Recorte (|cFFC0C0C0topo|r):" -- Needs review
L["STRING_OPTIONS_WALLPAPER_FILE"] = "Arquivo:" -- Needs review
L["STRING_OPTIONS_WALLPAPER_GREEN"] = "Verde:" -- Needs review
L["STRING_OPTIONS_WALLPAPER_LOAD"] = "Carregar Imagem" -- Needs review
L["STRING_OPTIONS_WALLPAPER_LOAD_DESC"] = "Seleciona uma imagem no seu computador para usar como papel de parede." -- Needs review
L["STRING_OPTIONS_WALLPAPER_LOAD_EXCLAMATION"] = "A imagem precisa:\
\
- Ser no formato Truevision TGA (.tga extension).\
- Estar dentro da pasta raiz WOW/Interface/.\
- Precisa ser do tamanho 256 x 256 pixels.\
- Voc\195\170 precisa fechar e reabrir o jogo ap\195\179s colar a imagem." -- Needs review
L["STRING_OPTIONS_WALLPAPER_LOAD_FILENAME"] = "Nome do Arquivo:" -- Needs review
L["STRING_OPTIONS_WALLPAPER_LOAD_FILENAME_DESC"] = "Insira apenas o nome do arquivo, extens\195\163o e caminho ficam de fora." -- Needs review
L["STRING_OPTIONS_WALLPAPER_LOAD_OKEY"] = "Carregar" -- Needs review
L["STRING_OPTIONS_WALLPAPER_LOAD_TITLE"] = "Do Computador:" -- Needs review
L["STRING_OPTIONS_WALLPAPER_LOAD_TROUBLESHOOT"] = "Solu\195\167\195\163o de Problemas" -- Needs review
L["STRING_OPTIONS_WALLPAPER_LOAD_TROUBLESHOOT_TEXT"] = "Se o papel de parede ficou todo verde:\
\
- Feche e reabra o cliente do jogo.\
- tenha certeza que o tamanho do arquivo \195\169 256 pixels de altura e comprimento.\
- Verifique se a imagem esta no formato .TGA e esta salva com 32 bits/pixel.\
- Esta dentro da pasta Interface, exemplo: C:/Arquivos de Programas/World of Warcraft/Interface/" -- Needs review
L["STRING_OPTIONS_WALLPAPER_RED"] = "Vermelho:" -- Needs review
L["STRING_OPTIONS_WC_ANCHOR"] = "Controle R\195\161pido da Janela (#%s):" -- Needs review
L["STRING_OPTIONS_WC_CLOSE"] = "Fechar" -- Needs review
L["STRING_OPTIONS_WC_CLOSE_DESC"] = "Fecha esta janela.\
\
Quando fechada, a janela \195\169 considerada inativa e pode ser reaberta a qualquer momento atrav\195\169s do bot\195\163o de janelas #.\
\
Para deleta-la completamente, veja a sess\195\163o Diversos -> Apagar." -- Needs review
L["STRING_OPTIONS_WC_CREATE"] = "Criar Janela" -- Needs review
L["STRING_OPTIONS_WC_CREATE_DESC"] = "Cria uma nova janela." -- Needs review
L["STRING_OPTIONS_WC_LOCK"] = "Travar" -- Needs review
L["STRING_OPTIONS_WC_LOCK_DESC"] = "Trava ou Destrava a janela.\
\
Quando travada, a janela n\195\163o pode ser movida." -- Needs review
L["STRING_OPTIONS_WC_REOPEN"] = "Reabrir" -- Needs review
L["STRING_OPTIONS_WC_UNLOCK"] = "Destravar" -- Needs review
L["STRING_OPTIONS_WC_UNSNAP"] = "Desgrudar" -- Needs review
L["STRING_OPTIONS_WC_UNSNAP_DESC"] = "Quebra o link entre duas janelas grudadas." -- Needs review
L["STRING_OPTIONS_WINDOW"] = "Painel de Op\195\167\195\181es" -- Needs review
L["STRING_OPTIONS_WINDOW_ANCHOR"] = "Ajustes de apar\195\170ncia:"
L["STRING_OPTIONS_WINDOWSPEED"] = "Velocidade de Atualiza\195\167\195\163o" -- Needs review
L["STRING_OPTIONS_WINDOWSPEED_DESC"] = "Segundos entre cada atualiza\195\167\195\163o da janela.\
\
|cFFFFFFFF0.3|r: atualiza cerca de 3 vezes por segundo.\
\
|cFFFFFFFF3.0|r: atualiza a cada 3 segundos." -- Needs review
L["STRING_OPTIONS_WINDOW_TITLE"] = "Configura\195\167\195\181es de Janela"
L["STRING_OPTIONS_WINDOW_TITLE_DESC"] = "Essa op\195\167\195\163o controla a apar\195\170ncia da janela de uma inst\195\162ncia selecionada."
L["STRING_OPTIONS_WP"] = "Papel de Parede"
L["STRING_OPTIONS_WP_ALIGN"] = "Alinhamento"
L["STRING_OPTIONS_WP_ALIGN_DESC"] = "Selecione como o papel de parede ser\195\161 alinhado com a janela.\
\
- |cFFFFFFFFPreencher|r: redimensiona e alinha com os quatro cantos da janela.\
\
- |cFFFFFFFFCentralizado|r: n\195\163o redimensiona e alinha com o centro da jane\195\167a.\
\
-|cFFFFFFFFEsticado|r: redimensiona na vertical ou horizontal e alinha com os cantos da esquerda-direita ou lado superior-inferior.\
\
-|cFFFFFFFFQuatro Laterais|r: alinha com um canto especifico, n\195\163o h\195\161 redimensionamento autom\195\161tico." -- Needs review
L["STRING_OPTIONS_WP_DESC"] = "Estas op\195\167\195\181es controlam o papel de parede que eh mostrado no fundo da janela." -- Needs review
L["STRING_OPTIONS_WP_EDIT"] = "Editar Imagem"
L["STRING_OPTIONS_WP_EDIT_DESC"] = "Abre o editor de imagens para alterar os aspectos do papel de parede escolhido."
L["STRING_OPTIONS_WP_ENABLE"] = "Ativar/Desativar"
L["STRING_OPTIONS_WP_ENABLE_DESC"] = "Liga ou desliga o papel de parede.\
\
Voc\195\170 pode escolher qual papel de parede voc\195\170 deseja usar nas caixas abaixo." -- Needs review
L["STRING_OPTIONS_WP_GROUP"] = "Categoria"
L["STRING_OPTIONS_WP_GROUP2"] = "Papel de Parede"
L["STRING_OPTIONS_WP_GROUP2_DESC"] = "Selecione qual voc\195\170 deseja colocar no fundo da janela, para mais op\195\167\195\181es troque de categoria na caixa da esquerda." -- Needs review
L["STRING_OPTIONS_WP_GROUP_DESC"] = "Nesta caixa, selecione o tipo do papel de parede, ap\195\179s selecionar, a caixa a direita ira mostrar as opcoes da categoria escolhida." -- Needs review
L["STRING_OVERALL"] = "Dados Gerais"
L["STRING_OVERHEAL"] = "Sobrecura"
L["STRING_OVERHEALED"] = "Sobrecura"
L["STRING_PARRY"] = "Aparo"
L["STRING_PERCENTAGE"] = "Porcentagem"
L["STRING_PET"] = "Ajudante"
L["STRING_PETS"] = "Ajudantes"
L["STRING_PLAYER_DETAILS"] = "Detalhes do Jogador"
L["STRING_PLAYERS"] = "Jogadores"
L["STRING_PLEASE_WAIT"] = "Por favor espere"
L["STRING_PLUGIN_CLEAN"] = "Nenhum"
L["STRING_PLUGIN_CLOCKNAME"] = "Tempo de Luta"
L["STRING_PLUGIN_CLOCKTYPE"] = "Tipo do Tempo"
L["STRING_PLUGIN_DURABILITY"] = "Durabilidade"
L["STRING_PLUGIN_FPS"] = "Quadros por Segundo"
L["STRING_PLUGIN_GOLD"] = "Dinheiro"
L["STRING_PLUGIN_LATENCY"] = "Lat\195\170ncia" -- Needs review
L["STRING_PLUGIN_MINSEC"] = "Minutos & Segundos"
L["STRING_PLUGIN_NAMEALREADYTAKEN"] = "Details! n\195\163o pode instalar um plugin pois o nome dele j\195\161 esta em uso" -- Needs review
L["STRING_PLUGINOPTIONS_ABBREVIATE"] = "Abreviar"
L["STRING_PLUGINOPTIONS_COMMA"] = "V\195\173rgula" -- Needs review
L["STRING_PLUGINOPTIONS_FONTFACE"] = "Fonte"
L["STRING_PLUGINOPTIONS_NOFORMAT"] = "Nenhum"
L["STRING_PLUGINOPTIONS_TEXTALIGN"] = "Alinhamento"
L["STRING_PLUGINOPTIONS_TEXTALIGN_X"] = "Alinhamento X"
L["STRING_PLUGINOPTIONS_TEXTALIGN_Y"] = "Alinhamento Y"
L["STRING_PLUGINOPTIONS_TEXTCOLOR"] = "Cor do Texto"
L["STRING_PLUGINOPTIONS_TEXTSIZE"] = "Tamanho"
L["STRING_PLUGINOPTIONS_TEXTSTYLE"] = "Estilo do Texto"
L["STRING_PLUGIN_PATTRIBUTENAME"] = "Atributo"
L["STRING_PLUGIN_PDPSNAME"] = "Dps da Raide"
L["STRING_PLUGIN_PSEGMENTNAME"] = "Segmento Mostrado"
L["STRING_PLUGIN_SECONLY"] = "Somente Segundos" -- Needs review
L["STRING_PLUGIN_SEGMENTTYPE"] = "Tipo de Segmento"
L["STRING_PLUGIN_SEGMENTTYPE_1"] = "Combate #X"
L["STRING_PLUGIN_SEGMENTTYPE_2"] = "Nome do Encontro"
L["STRING_PLUGIN_SEGMENTTYPE_3"] = "Nome do encontro mais segmento"
L["STRING_PLUGIN_THREATNAME"] = "Minha Amea\195\167a"
L["STRING_PLUGIN_TIME"] = "Rel\195\179gio" -- Needs review
L["STRING_PLUGIN_TIMEDIFF"] = "Diferen\195\167a do Ultimo Combate" -- Needs review
L["STRING_PLUGIN_TOOLTIP_LEFTBUTTON"] = "Configura a ferramenta atual"
L["STRING_PLUGIN_TOOLTIP_RIGHTBUTTON"] = "Escolher uma outra ferramenta"
L["STRING_RAID_WIDE"] = "[*] cooldown de raide"
L["STRING_REPORT"] = "Relat\195\179rio para" -- Needs review
L["STRING_REPORT_BUTTON_TOOLTIP"] = "Clique para abrir a Caixa de Relat\195\179rios." -- Needs review
L["STRING_REPORT_FIGHT"] = "luta"
L["STRING_REPORT_FIGHTS"] = "lutas"
L["STRING_REPORTFRAME_COPY"] = "Copiar e Colar"
L["STRING_REPORTFRAME_CURRENT"] = "Mostrando"
L["STRING_REPORTFRAME_CURRENTINFO"] = "Reporta apenas as informa\195\167\195\181es que est\195\163o sendo mostradas no momento." -- Needs review
L["STRING_REPORTFRAME_GUILD"] = "Guilda"
L["STRING_REPORTFRAME_INSERTNAME"] = "entre com um nome"
L["STRING_REPORTFRAME_LINES"] = "Linhas"
L["STRING_REPORTFRAME_OFFICERS"] = "Canal dos Oficiais"
L["STRING_REPORTFRAME_PARTY"] = "Grupo"
L["STRING_REPORTFRAME_RAID"] = "Raide"
L["STRING_REPORTFRAME_REVERT"] = "Inverter"
L["STRING_REPORTFRAME_REVERTED"] = "invertido"
L["STRING_REPORTFRAME_REVERTINFO"] = "Inverte as posi\195\167\195\181es colocando em ordem crescente." -- Needs review
L["STRING_REPORTFRAME_SAY"] = "Dizer"
L["STRING_REPORTFRAME_SEND"] = "Enviar"
L["STRING_REPORTFRAME_WHISPER"] = "Sussurrar"
L["STRING_REPORTFRAME_WHISPERTARGET"] = "Sussurrar o Alvo" -- Needs review
L["STRING_REPORTFRAME_WINDOW_TITLE"] = "Emitir Relat\195\179rio" -- Needs review
L["STRING_REPORT_INVALIDTARGET"] = "O alvo n\195\163o pode ser encontrado" -- Needs review
L["STRING_REPORT_LAST"] = "Ultimas"
L["STRING_REPORT_LASTFIGHT"] = "ultima luta"
L["STRING_REPORT_LEFTCLICK"] = "Clique para abrir a janela de relat\195\179rio" -- Needs review
L["STRING_REPORT_PREVIOUSFIGHTS"] = "lutas anteriores"
L["STRING_REPORT_SINGLE_BUFFUPTIME"] = "dura\195\167\195\163o dos buffs de" -- Needs review
L["STRING_REPORT_SINGLE_COOLDOWN"] = "cooldowns usados por"
L["STRING_REPORT_SINGLE_DEATH"] = "detalhes da morte de"
L["STRING_REPORT_SINGLE_DEBUFFUPTIME"] = "dura\195\167\195\163o dos debuffs de" -- Needs review
L["STRING_RESISTED"] = "Resistido"
L["STRING_RESIZE_ALL"] = "Redimensiona livremente\
 e reajusta todas as janelas" -- Needs review
L["STRING_RESIZE_COMMON"] = "Redimensiona livremente\
"
L["STRING_RESIZE_HORIZONTAL"] = "Redimensiona a largura\
 de todas as janelas na linha horizontal" -- Needs review
L["STRING_RESIZE_VERTICAL"] = "Redimensiona a altura\
 de todas as janelas na linha horizontal" -- Needs review
L["STRING_RIGHT"] = "direita"
L["STRING_RIGHTCLICK_CLOSE_LARGE"] = "Clique com o bot\195\163o direito do mouse para fechar esta janela." -- Needs review
L["STRING_RIGHTCLICK_CLOSE_MEDIUM"] = "Use o bot\195\163o direito para fechar esta janela." -- Needs review
L["STRING_RIGHTCLICK_CLOSE_SHORT"] = "Bot\195\163o direito para fechar." -- Needs review
L["STRING_RIGHTCLICK_TYPEVALUE"] = "bot\195\163o direito para digitar o valor" -- Needs review
L["STRING_SEE_BELOW"] = "veja abaixo"
L["STRING_SEGMENT"] = "Segmento"
L["STRING_SEGMENT_EMPTY"] = "este segmento esta vazio"
L["STRING_SEGMENT_END"] = "Fim"
L["STRING_SEGMENT_ENEMY"] = "Contra"
L["STRING_SEGMENT_LOWER"] = "segmento"
L["STRING_SEGMENT_OVERALL"] = "Dados Gerais" -- Needs review
L["STRING_SEGMENT_START"] = "Inicio"
L["STRING_SEGMENT_TIME"] = "Tempo"
L["STRING_SEGMENT_TRASH"] = "Limpeza de Trash" -- Needs review
L["STRING_SHORTCUT_RIGHTCLICK"] = "Menu de Atalho (bot\195\163o direito para fechar)" -- Needs review
L["STRING_SLASH_CAPTUREOFF"] = "todas as capturas foram desligadas."
L["STRING_SLASH_CAPTUREON"] = "todas as capturas foram ligadas."
L["STRING_SLASH_CHANGES"] = "updates"
L["STRING_SLASH_CHANGES_ALIAS1"] = "novidades" -- Needs review
L["STRING_SLASH_CHANGES_ALIAS2"] = "mudan\195\167as" -- Needs review
L["STRING_SLASH_CHANGES_DESC"] = "mostra o que foi implementado e corrigido nesta vers\195\163o do Details." -- Needs review
L["STRING_SLASH_DISABLE"] = "desativar"
L["STRING_SLASH_DISABLE_DESC"] = "desliga todas as capturas de dados."
L["STRING_SLASH_ENABLE"] = "ativa"
L["STRING_SLASH_ENABLE_DESC"] = "liga todas as capturas de dados."
L["STRING_SLASH_HIDE"] = "esconder" -- Needs review
L["STRING_SLASH_HIDE_ALIAS1"] = "fechar" -- Needs review
L["STRING_SLASH_HIDE_DESC"] = "fecha todas as janelas abertas." -- Needs review
L["STRING_SLASH_NEW"] = "novo"
L["STRING_SLASH_NEW_DESC"] = "abre ou reabre uma janela." -- Needs review
L["STRING_SLASH_OPTIONS"] = "op\195\167\195\181es" -- Needs review
L["STRING_SLASH_OPTIONS_DESC"] = "abre o painel de op\195\167\195\181es." -- Needs review
L["STRING_SLASH_SHOW"] = "mostrar"
L["STRING_SLASH_SHOW_ALIAS1"] = "abrir" -- Needs review
L["STRING_SLASH_SHOW_DESC"] = "abre uma janela caso n\195\163o tenha nenhuma aberta." -- Needs review
L["STRING_SLASH_WIPECONFIG"] = "reinstalar"
L["STRING_SLASH_WIPECONFIG_CONFIRM"] = "Continuar com a reinstala\195\167\195\163o?." -- Needs review
L["STRING_SLASH_WIPECONFIG_DESC"] = "faz a reinstala\195\167\195\163o do addon limpando toda a configura\195\167\195\163o, use caso o Details! n\195\163o esteja funcionando corretamente." -- Needs review
L["STRING_SLASH_WORLDBOSS"] = "worldboss"
L["STRING_SLASH_WORLDBOSS_DESC"] = "executa uma macro mostrando quais 'world boss' voc\195\170 matou esta semana." -- Needs review
L["STRING_SPELL_INTERRUPTED"] = "Magias Interrompidas"
L["STRING_SPELLS"] = "Habilidades"
L["STRING_STATUSBAR_NOOPTIONS"] = "N\195\163o h\195\161 opcoes para esta ferramenta." -- Needs review
L["STRING_SWITCH_CLICKME"] = "clique-me"
L["STRING_SWITCH_WARNING"] = "Especializa\195\167\195\163o Alterada. Trocando: |cFFFFAA00%s|r  " -- Needs review
L["STRING_TARGET"] = "Alvo"
L["STRING_TARGETS"] = "Alvos"
L["STRING_TIME_OF_DEATH"] = "Morreu"
L["STRING_TOOOLD"] = "n\195\163o pode ser instalado pois sua vers\195\163o do Details! e muito antiga." -- Needs review
L["STRING_TOP"] = "topo"
L["STRING_TOTAL"] = "Total"
L["STRING_UNKNOW"] = "Desconhecido"
L["STRING_UNKNOWSPELL"] = "Magia Desconhecida"
L["STRING_UNLOCK"] = "Separe as janelas\
neste bot\195\163o" -- Needs review
L["STRING_UNLOCK_WINDOW"] = "destravar"
L["STRING_UPTADING"] = "atualizando"
L["STRING_VERSION_UPDATE"] = "nova vers\195\163o: clique para ver o que mudou" -- Needs review
L["STRING_VOIDZONE_TOOLTIP"] = "Dano e tempo:"
L["STRING_WAITPLUGIN"] = "esperando por\
plugins"
L["STRING_YES"] = "Sim"
