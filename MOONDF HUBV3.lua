--[[
    MOONDF HUB - MERGED (PC & MOBILE COMPATIBLE)
    - Mantive nomes de funções públicas (setupFly, toggleNoclip, toggleClickTP, etc.)
    - Popup inicial PC / Mobile. Depois de escolher, o HUD é criado com suporte a toque.
    - Sliders e redimensionamento compatíveis com Touch e Mouse.
    - Variáveis de GUI usam uiRoot para evitar conflito com 'root' do personagem (HumanoidRootPart).
    - Preservadas as funcionalidades do seu V3; apenas organizei a ordem para que callbacks encontrem as funções.
    - FIX DRAG: AnchorPoint (0,0) + delta puro (MakeDraggable) — sem salto ao clicar.

    UPDATE: 
    1. Removido o spam M1 automático quando NPC agressivo próximo (agora só quando não está stunado).
    2. Distância ao ser atingido aumentada para 25 (antes 12).
    3. Lunge melhorado: tempo máximo de corrida aumentado, mais cliques garantidos em intervalo curto.
]]

-- ============================================================================== 
--  SERVICES
-- ============================================================================== 
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local VIM = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Camera = workspace and workspace.CurrentCamera

-- =========================
-- SISTEMA DE IDIOMA & TRADUÇÕES (Usadas por UI)
-- =========================
local globalEnv = (typeof(getgenv) == "function" and getgenv()) or _G
globalEnv.CurrentLang = globalEnv.CurrentLang or "PT"
local CurrentLang = globalEnv.CurrentLang -- Padrão: Português

local TRANSLATIONS = {
    PT = {
        TITLE_MAIN = "MOONDF HUB",
        EMERGENCY = "Emergência",
        EMERGENCY_DESC = "Para farms, ataques, voo e movimentos imediatamente",
        EMERGENCY_DONE = "Emergência: sistemas parados",
        TOPIC_TEST = "Teste",
        TOPIC_CONFIG = "Configuração",
        TOPIC_GENERAL = "Geral",
        TOPIC_MOBS = "Mobs",
        TOPIC_FARM = "Farm",
        TOPIC_AUTOSKILLS = "AutoSkills",
        TOPIC_PLAYERS = "Players",
        TOPIC_TELEPORTS = "Teleportes",
        TOPIC_DEV = "Developer",
        FOOTER_TEXT = "Right Ctrl ou use o botão para minimizar • Inputs: Immediate (OK) / Select (no OK)",

        DEV_TOOLS = "Ferramentas",
        DEV_TOOLS_DESC = "Coords e utilidades",
        DEV_LOAD_MOBS = "Detectar mobs carregados",
        DEV_LOAD_MOBS_DESC = "Lista apenas os mobs que já estão no mapa (sem teleportar)",
        DEV_LOADED_MOBS = "Mobs carregados",
        DEV_LOADED_MOBS_DESC = "Lista nomes exatos sem repetição",
        DEV_MOB_ACTIONS = "Ações do mob",
        DEV_COPY_MOB_NAME = "Copiar nome",
        DEV_COPY_MOB_NAME_DESC = "Copia o nome exato",
        DEV_CAPTURE_NPC_LOGS = "Capturar logs do NPC",
        DEV_CAPTURE_NPC_LOGS_DESC = "Detecta e registra tudo que estiver disponível no NPC carregado",
        DEV_COPY_NPC_LOGS = "Copiar logs capturados",
        DEV_COPY_NPC_LOGS_DESC = "Copia todas as informações capturadas deste NPC",
        DEV_NO_NPC_LOGS = "Nenhum log capturado",
        DEV_NO_NPC_LOGS_DESC = "Use Capturar logs antes de copiar",
        DEV_TELEPORT_MOB = "Teleportar",
        DEV_TELEPORT_MOB_DESC = "Vai até o mob carregado",
        DEV_FARM_MOB = "Farmar",
        DEV_FARM_MOB_DESC = "Inicia ou para o farm deste mob",
        DEV_DETECTED_COUNT = "Mobs detectados: %d",
        DEV_NO_MOBS = "Nenhum mob carregado",
        DEV_NO_MOBS_DESC = "Use o botão de detectar depois que os mobs estiverem carregados",
        DEV_COORDS = "Copiar Coordenadas",
        DEV_COORDS_DESC = "Copia CFrame atual pro clipboard",
        DEV_FUNNY = "Funções Engraçadas",
        DEV_FUNNY_DESC = "Troll / meme",
        DEV_SPIN = "Girar sem parar",
        DEV_SPIN_DESC = "Personagem gira (outros veem)",
        DEV_DISCO = "Disco RGB",
        DEV_DISCO_DESC = "Corpo arco-íris (local)",
        DEV_MOONWALK = "Moonwalk",
        DEV_MOONWALK_DESC = "Anda de costas",
        DEV_GIANT = "Gigante",
        DEV_GIANT_DESC = "Personagem enorme (local)",
        DEV_TINY = "Miniatura",
        DEV_TINY_DESC = "Personagem minúsculo (local)",
        DEV_FLING = "Se lançar",
        DEV_FLING_DESC = "Joga você pro espaço",
        DEV_RAGDOLL = "Ragdoll",
        DEV_RAGDOLL_DESC = "Cai mole por 1s",
        ICE_SLIDE = "Gelo Deslizante",
        ICE_SLIDE_DESC = "Caído no chão desliza + ricochete na parede",
        ICE_INTENSITY = "Intensidade do Gelo",
        ICE_INTENSITY_DESC = "Quanto desliza e ricocheteia",
        DEV_HELI = "Helicóptero",
        DEV_HELI_DESC = "Gira e sobe (visível)",
        DEV_DRUNK = "Bêbado",
        DEV_DRUNK_DESC = "Anda torto aleatório (visível)",
        DEV_BALLOON = "Balão",
        DEV_BALLOON_DESC = "Flutua girando pra cima",
        DEV_ROLL = "Mortal",
        DEV_ROLL_DESC = "Rola no chão sem parar",
        DEV_HOP = "Pulo-pula",
        DEV_HOP_DESC = "Pula enquanto anda",

        LANG_LABEL = "Idioma / Language",
        LANG_DESC = "Altera todo o texto do menu",
        THEME_LABEL = "Tema / Theme",
        THEME_DESC = "Altera as cores da interface",
        OPACITY_LABEL = "Opacidade / Opacity",
        OPACITY_DESC = "Altera a transparência da janela",

        DEMO_LABEL = "Demonstração",
        DEMO_DESC = "Verifique os comentários no código.",
        BTN_HITBOX = "Botão Teste",
        BTN_HITBOX_DESC = "Clique para testar",
        TOGGLE_HITBOX = "Toggle Teste",
        TOGGLE_HITBOX_DESC = "Ativar/Desativar",
        SLIDER_BLUE = "Slider",
        SLIDER_BLUE_DESC = "Arraste para mudar o valor",
        INPUT_OK = "Input com OK",
        INPUT_OK_DESC = "Digitar e confirmar",
        INPUT_OK_PLACE = "Escreva aqui...",
        INPUT_NO_OK = "Input Texto (Sem OK)",
        INPUT_NO_OK_DESC = "Salva ao sair",
        INPUT_NO_OK_PLACE = "Texto...",
        DROPDOWN = "Lista Opções",
        DROPDOWN_DESC = "Selecione uma opção",
        LIST_GROUP = "Grupo de Itens",
        LIST_GROUP_DESC = "Contém outros itens",
        ITEM_INNER_1 = "Item Interno 1",
        ITEM_INNER_DESC_1 = "Toggle dentro da lista",
        ITEM_INNER_2 = "Item Interno 2",
        ITEM_INNER_DESC_2 = "Slider dentro da lista",
        NEST_TEST = "Teste Aninhado",
        NEST_TEST_DESC = "Níveis profundos",
        LEVEL_1 = "Nível 1",
        LEVEL_1_DESC = "Dentro da primeira lista",
        SUB_LIST = "Sub-Lista",
        SUB_LIST_DESC = "Nível 2",
        BTN_LEVEL_3 = "Botão Nível 3",
        BTN_LEVEL_3_DESC = "Funcionando",
        TOGGLE_LEVEL_3 = "Toggle Nível 3",
        TOGGLE_LEVEL_3_DESC = "Funcionando",

        FLY_SPEED = "Fly & Speed",
        FLY_SPEED_DESC = "Controles de movimento",
        SERVER_HOP = "Server Hop",
        SERVER_HOP_DESC = "Entra no servidor público com menor ping",
        SERVER_HOP_SEARCHING = "Procurando o servidor com menor ping...",
        SERVER_HOP_FOUND = "Entrando no servidor com %d ms de ping",
        SERVER_HOP_FAIL = "Não foi possível encontrar um servidor com ping disponível",
        FARM_AUTO_REGEN = "Auto Regen (Farm)",
        FARM_AUTO_REGEN_DESC = "Respawna no HP real fixo de 60 ou menos",
        AUTO_REGEN = "Auto Regen",
        AUTO_REGEN_DESC = "Respawna quando o HP real chegar ao limite",
        AUTO_REGEN_MANUAL_RESPAWN = "Respawn Manual",
        AUTO_REGEN_MANUAL_RESPAWN_DESC = "Respawna seu personagem uma vez imediatamente",
        AUTO_REGEN_THRESHOLD = "Limite Auto Regen",
        AUTO_REGEN_THRESHOLD_DESC = "Regenera quando HP for menor ou igual",
        AUTO_REGEN_ESP = "ESP Vida Real",
        AUTO_REGEN_ESP_DESC = "Mostra o HP real atual e máximo acima do personagem",
        AUTO_REGEN_BREATH_BAR = "Barra de Respiração",
        AUTO_REGEN_BREATH_BAR_BUTTON = "CRIAR BARRA DE RESPIRAÇÃO",
        AUTO_REGEN_BREATH_BAR_DESC = "Ativa a barra branca vertical durante a respiração",
        AUTO_REGEN_BREATH_BAR_CHARACTER = "Barra fixa no boneco",
        AUTO_REGEN_BREATH_BAR_CHARACTER_DESC = "Prende a barra ao personagem com tamanho fixo, sem alterar com o zoom",
        AUTO_REGEN_BREATH_BAR_SCREEN = "Barra fixa na tela (UI)",
        AUTO_REGEN_BREATH_BAR_SCREEN_DESC = "Mostra a barra como UI fixa na tela, um pouco à esquerda",
        AUTO_REGEN_WARNING = "Aviso: limite alto pode causar vários respawns e kick",
        ENABLE_FLY = "Ativar Fly",
        ENABLE_FLY_DESC = "WASD + Space/C",
        FLY_SPEED_SLIDER = "Velocidade Fly",
        FLY_SPEED_SLIDER_DESC = "Ajuste a força",
        ENABLE_SPEED = "Speed",
        ENABLE_SPEED_DESC = "Velocidade no chão",
        SPEED_VALUE_SLIDER = "Valor Speed",
        SPEED_VALUE_SLIDER_DESC = "Velocidade de corrida",

        EXTRAS = "Extras",
        EXTRAS_DESC = "Utilidades",
        CLICK_TP = "Click TP",
        CLICK_TP_DESC = "Clique para TP",
        NO_CLIP = "No Clip",
        NO_CLIP_DESC = "Atravessar paredes",
        NO_FOG = "No Fog",
        NO_FOG_DESC = "Remover neblina",
        ULTRA_LITE = "Ultra Lite",
        ULTRA_LITE_DESC = "Modo Batata (FPS)",
        INFINITE_JUMP = "Infinite Jump",
        INFINITE_JUMP_DESC = "Pulo infinito (segure Espaço)",
        INFINITE_STAMINA = "Infinite Stamina",
        INFINITE_STAMINA_DESC = "Stamina nunca cai (ataque/pulo/formas)",
        ANTI_COMBAT = "Anti Combat",
        ANTI_COMBAT_DESC = "Remove caveira e efeitos do modo combate",

        TP_MODE = "Modo de TP",
        TP_MODE_DESC = "Posição relativa ao mob",
        DISTANCE = "Distância",
        DISTANCE_DESC = "Distância do alvo",
        ANTI_EXECUTE = "Anti Execute",
        ANTI_EXECUTE_DESC = "Longe após morrer; desligado fica perto para morrer",
        EXECUTE_DISTANCE = "Dist. Execute",
        EXECUTE_DISTANCE_DESC = "Distância ao executar",
        AUTO_ATTACK = "Auto Attack",
        AUTO_ATTACK_DESC = "Spam M1",
        AUTOSKILLS_DESC = "Skills e respiração automáticas",
        AUTO_SKILL_1 = "Auto Skill 1",
        AUTO_SKILL_2 = "Auto Skill 2",
        AUTO_SKILL_3 = "Auto Skill 3",
        AUTO_SKILL_4 = "Auto Skill 4",
        AUTO_SKILL_5 = "Auto Skill 5",
        AUTO_SKILL_6 = "Auto Skill 6",
        AUTO_SKILL_7 = "Auto Skill 7",
        AUTO_SKILL_T = "Auto Skill T",
        AUTO_SKILL_Y = "Auto Skill Y",
        AUTO_SKILL_DESC = "Pressiona a cada 5 segundos",
        AUTO_BREATH = "Auto Breath",
        AUTO_BREATH_DESC = "Abaixo de 40%: espera, segura G e tenta novamente se falhar",
        LOAD_MOBS = "Carregar Mobs",
        LOAD_MOBS_DESC = "Detecta os mobs já carregados sem teleportar",
        FARM_MOBS_LIST = "Lista de Farm Mobs",
        FARM_MOBS_LIST_DESC = "Selecione o Mob para farmar",
        FARM = "Farm",
        FARM_DESC = "Auto TP",
        FARM_GENERAL_RAID = "Farm Raid Geral",
        FARM_GENERAL_RAID_DESC = "Prioriza bosses e troca instantaneamente para outro alvo morto",
        FARM_CASTLE = "Farm Castelo",
        FARM_CASTLE_DESC = "Farm de Akaza, Doma e Kokushibo",
        FARM_CASTLE_GENERAL = "Farm Castelo Geral",
        FARM_CASTLE_GENERAL_DESC = "Ativa GenericOni e prioriza Akaza, Doma e Kokushibo",


        RAIDS = "Raids (Locais)",
        RAIDS_DESC = "Farm de Raids",
        EVENTS = "Eventos",
        EVENTS_DESC = "Locais especiais e eventos",
        EVENT_TP_DESC = "Teleporta para o local",
        EVENT_RAID = "Raid",
        EVENT_RAID_DESC = "Teleporta para a área da Raid",
        EVENT_DOUMA = "Douma — Castelo Infinito",
        EVENT_AKAZA = "Akaza — Castelo Infinito",
        EVENT_KOKUSHIBO = "Kokushibo — Castelo Infinito",
        EVENT_SLAYER_CASTLE = "Slayer Corps — Castelo Infinito",
        EVENT_SOUP = "Vendedor de Sopa",
        EVENT_MEAT = "Vendedor de Carne",
        EVENT_JEWEL_SELLER = "Vendedor de Joias",
        EVENT_NICHIRIN_HORN = "Nichirins e Vendedor de Chifres Oni",
        TP_RAID_AREA = "TP Área Raid",
        TP_RAID_AREA_DESC = "Vai para o inicio",
        INFINITE_CASTLE = "Castelo Infinito (Locais)",
        INFINITE_CASTLE_DESC = "Farm & TPs",
        TP_SLAYER_CORPS = "TP Slayer Corps",
        TP_SLAYER_CORPS_DESC = "Coord 1",
        TP_AKAZA_DOMA = "TP Akaza/Doma",
        TP_AKAZA_DOMA_DESC = "Coord 2",
        TP_KOKUSHIBO = "TP Kokushibo",
        TP_KOKUSHIBO_DESC = "Coord 3",
        TRINKET_FARM = "Trinket Farm",
        TRINKET_FARM_DESC = "Coleta automática",
        ORE_FARM = "Farm Minérios",
        ORE_FARM_DESC = "TP + minera com picareta (Z)",

        SELECT_PLAYER = "Selecionar Player",
        SELECT_PLAYER_DESC = "Escolha o alvo",
        UPDATE_LIST = "Atualizar Lista",
        UPDATE_LIST_DESC = "Recarrega os nomes",
        PLAYER_ACTIONS = "Ações do Player",
        PLAYER_ACTIONS_DESC = "Opções para o alvo selecionado",
        GO_TO_PLAYER = "Ir até Player",
        GO_TO_PLAYER_DESC = "TP Fly",
        ESP_PLAYERS = "ESP Players",
        ESP_PLAYERS_DESC = "Wallhack",
        FARM_PLAYER = "Farmar Player",
        FARM_PLAYER_DESC = "Seguir e matar",
        SPECTATE = "Spectate",
        SPECTATE_DESC = "Observar alvo",
        HEIGHT = "Altura",
        HEIGHT_DESC = "Altura camera",
        DISTANCE_SPECTATE = "Distância",
        DISTANCE_SPECTATE_DESC = "Distância camera",
        ENABLE_SPECTATE = "Ativar Spectate",
        ENABLE_SPECTATE_DESC = "Olhar player selecionado",

        VILLAGES = "Vilas",
        VILLAGES_DESC = "Locais principais",
        TP_HAYAKAWA = "Okuya",
        TP_HAYAKAWA_DESC = "TP",
        TP_OKUYA = "Hayakawa",
        TP_OKUYA_DESC = "TP",
        TP_KAMAKURA = "Kamakura",
        TP_KAMAKURA_DESC = "TP",
        TP_SLAYER = "Distrito",
        TP_SLAYER_DESC = "TP",
        TP_DISTRITO = "Slayer Corps",
        TP_DISTRITO_DESC = "TP",
        TP_SLAYER_EXAM = "Slayer Exam",
        TP_SLAYER_EXAM_DESC = "TP",

        BREATHS = "Respirações",
        BREATHS_DESC = "Trainers",
        TP_MIST = "Mist",
        TP_MIST_DESC = "TP",
        TP_WATER = "Water",
        TP_WATER_DESC = "TP",
        TP_WIND = "Wind",
        TP_WIND_DESC = "TP",
        TP_THUNDER = "Thunder",
        TP_THUNDER_DESC = "TP",
        TP_INSECT = "Insect",
        TP_INSECT_DESC = "TP",
        TP_FLAME = "Flame",
        TP_FLAME_DESC = "TP",
        TP_SUN = "Sun",
        TP_SUN_DESC = "TP",
        TP_MOON = "Moon",
        TP_MOON_DESC = "TP",
        TP_BEAST = "Beast",
        TP_BEAST_DESC = "TP",
        TP_SOUND = "Sound",
        TP_SOUND_DESC = "TP",
        TP_FLOWER = "Flower",
        TP_FLOWER_DESC = "TP",
        TP_SERPENT = "Serpent",
        TP_SERPENT_DESC = "TP",
        TP_LOVE = "Love",
        TP_LOVE_DESC = "TP",

        LANGUAGE = "Idioma",
        LANGUAGE_DESC = "Altera idioma",
        THEME = "Tema",
        THEME_DESC = "Altera cores",
        OPACITY = "Opacidade",
        OPACITY_DESC = "Transparência",
        INFO_LABEL = "Info: Se o farm não funcionar, vá para Teleportes e carregue mobs/mapa",
        EXTRAS_MOBS = "Extras",
        EXTRAS_MOBS_DESC = "Funções adicionais",
        LOAD_MAP = "Carregar todo o mapa",
        LOAD_MAP_DESC = "TP por todo o mapa"
    },
    EN = {
        TITLE_MAIN = "MOONDF HUB",
        EMERGENCY = "Emergency",
        EMERGENCY_DESC = "Immediately stops farms, attacks, flight and movement",
        EMERGENCY_DONE = "Emergency: systems stopped",
        TOPIC_TEST = "Test",
        TOPIC_CONFIG = "Settings",
        TOPIC_GENERAL = "General",
        TOPIC_MOBS = "Mobs",
        TOPIC_FARM = "Farm",
        TOPIC_AUTOSKILLS = "AutoSkills",
        TOPIC_PLAYERS = "Players",
        TOPIC_TELEPORTS = "Teleports",
        TOPIC_DEV = "Developer",
        FOOTER_TEXT = "Right Ctrl or use button to minimize • Inputs: Immediate (OK) / Select (no OK)",

        DEV_TOOLS = "Tools",
        DEV_TOOLS_DESC = "Coords and utilities",
        DEV_LOAD_MOBS = "Detect loaded mobs",
        DEV_LOAD_MOBS_DESC = "Lists only mobs already on the map (no teleport)",
        DEV_LOADED_MOBS = "Loaded mobs",
        DEV_LOADED_MOBS_DESC = "Exact names without duplicates",
        DEV_MOB_ACTIONS = "Mob actions",
        DEV_COPY_MOB_NAME = "Copy name",
        DEV_COPY_MOB_NAME_DESC = "Copies the exact name",
        DEV_CAPTURE_NPC_LOGS = "Capture NPC logs",
        DEV_CAPTURE_NPC_LOGS_DESC = "Detects and records everything available on the loaded NPC",
        DEV_COPY_NPC_LOGS = "Copy captured logs",
        DEV_COPY_NPC_LOGS_DESC = "Copies all information captured from this NPC",
        DEV_NO_NPC_LOGS = "No logs captured",
        DEV_NO_NPC_LOGS_DESC = "Use Capture logs before copying",
        DEV_TELEPORT_MOB = "Teleport",
        DEV_TELEPORT_MOB_DESC = "Go to the loaded mob",
        DEV_FARM_MOB = "Farm",
        DEV_FARM_MOB_DESC = "Start or stop farming this mob",
        DEV_DETECTED_COUNT = "Mobs detected: %d",
        DEV_NO_MOBS = "No mobs loaded",
        DEV_NO_MOBS_DESC = "Use the detect button after mobs are loaded",
        DEV_COORDS = "Copy Coordinates",
        DEV_COORDS_DESC = "Copies current CFrame to clipboard",
        DEV_FUNNY = "Funny Functions",
        DEV_FUNNY_DESC = "Troll / meme",
        DEV_SPIN = "Spin Forever",
        DEV_SPIN_DESC = "Character spins (others see)",
        DEV_DISCO = "Disco RGB",
        DEV_DISCO_DESC = "Rainbow body (local)",
        DEV_MOONWALK = "Moonwalk",
        DEV_MOONWALK_DESC = "Walk backwards",
        DEV_GIANT = "Giant",
        DEV_GIANT_DESC = "Huge character (local)",
        DEV_TINY = "Tiny",
        DEV_TINY_DESC = "Tiny character (local)",
        DEV_FLING = "Fling Self",
        DEV_FLING_DESC = "Yeet yourself",
        DEV_RAGDOLL = "Ragdoll",
        DEV_RAGDOLL_DESC = "Go limp for 1s",
        ICE_SLIDE = "Ice Slide",
        ICE_SLIDE_DESC = "While downed slides + wall bounce",
        ICE_INTENSITY = "Ice Intensity",
        ICE_INTENSITY_DESC = "How much you slide and bounce",
        DEV_HELI = "Helicopter",
        DEV_HELI_DESC = "Spin and rise (visible)",
        DEV_DRUNK = "Drunk",
        DEV_DRUNK_DESC = "Random wobbly movement",
        DEV_BALLOON = "Balloon",
        DEV_BALLOON_DESC = "Float upward spinning",
        DEV_ROLL = "Cartwheel",
        DEV_ROLL_DESC = "Roll on the ground",
        DEV_HOP = "Bunny Hop",
        DEV_HOP_DESC = "Hop while walking",

        LANG_LABEL = "Language / Idioma",
        LANG_DESC = "Changes all menu text",
        THEME_LABEL = "Theme / Tema",
        THEME_DESC = "Changes UI colors",
        OPACITY_LABEL = "Opacity / Opacity",
        OPACITY_DESC = "Changes window transparency",

        DEMO_LABEL = "Demo",
        DEMO_DESC = "Check code comments.",
        BTN_HITBOX = "Test Button",
        BTN_HITBOX_DESC = "Click to test",
        TOGGLE_HITBOX = "Test Toggle",
        TOGGLE_HITBOX_DESC = "Enable/Disable",
        SLIDER_BLUE = "Slider",
        SLIDER_BLUE_DESC = "Drag to change value",
        INPUT_OK = "Input with OK",
        INPUT_OK_DESC = "Type and confirm",
        INPUT_OK_PLACE = "Write here...",
        INPUT_NO_OK = "Text Input (No OK)",
        INPUT_NO_OK_DESC = "Saves on exit",
        INPUT_NO_OK_PLACE = "Text...",
        DROPDOWN = "Option List",
        DROPDOWN_DESC = "Select an option",

        FLY_SPEED = "Fly & Speed",
        FLY_SPEED_DESC = "Movement controls",
        SERVER_HOP = "Server Hop",
        SERVER_HOP_DESC = "Joins the public server with the lowest ping",
        SERVER_HOP_SEARCHING = "Searching for the lowest-ping server...",
        SERVER_HOP_FOUND = "Joining server with %d ms ping",
        SERVER_HOP_FAIL = "Could not find a server with available ping",
        FARM_AUTO_REGEN = "Auto Regen (Farm)",
        FARM_AUTO_REGEN_DESC = "Respawns at the fixed real HP of 60 or lower",
        AUTO_REGEN = "Auto Regen",
        AUTO_REGEN_DESC = "Respawns when real HP reaches the limit",
        AUTO_REGEN_MANUAL_RESPAWN = "Manual Respawn",
        AUTO_REGEN_MANUAL_RESPAWN_DESC = "Respawns your character once immediately",
        AUTO_REGEN_THRESHOLD = "Auto Regen Limit",
        AUTO_REGEN_THRESHOLD_DESC = "Regenerates when HP is less than or equal",
        AUTO_REGEN_ESP = "Real Health ESP",
        AUTO_REGEN_ESP_DESC = "Shows current and maximum real HP above your character",
        AUTO_REGEN_BREATH_BAR = "Breathing Bar",
        AUTO_REGEN_BREATH_BAR_BUTTON = "CREATE BREATHING BAR",
        AUTO_REGEN_BREATH_BAR_DESC = "Activates the white vertical bar while breathing",
        AUTO_REGEN_BREATH_BAR_CHARACTER = "Bar fixed to character",
        AUTO_REGEN_BREATH_BAR_CHARACTER_DESC = "Attaches the bar to the character with a fixed size that does not change with zoom",
        AUTO_REGEN_BREATH_BAR_SCREEN = "Bar fixed on screen (UI)",
        AUTO_REGEN_BREATH_BAR_SCREEN_DESC = "Shows the bar as fixed screen UI, slightly to the left",
        AUTO_REGEN_WARNING = "Warning: a high limit may cause repeated respawns and a kick",
        ENABLE_FLY = "Enable Fly",
        ENABLE_FLY_DESC = "WASD + Space/C",
        FLY_SPEED_SLIDER = "Fly Speed",
        FLY_SPEED_SLIDER_DESC = "Adjust strength",
        ENABLE_SPEED = "Speed",
        ENABLE_SPEED_DESC = "Ground speed",
        SPEED_VALUE_SLIDER = "Speed Value",
        SPEED_VALUE_SLIDER_DESC = "Running speed",

        EXTRAS = "Extras",
        EXTRAS_DESC = "Utilities",
        CLICK_TP = "Click TP",
        CLICK_TP_DESC = "Click to TP",
        NO_CLIP = "No Clip",
        NO_CLIP_DESC = "Walk through walls",
        NO_FOG = "No Fog",
        NO_FOG_DESC = "Remove fog",
        ULTRA_LITE = "Ultra Lite",
        ULTRA_LITE_DESC = "Potato Mode (FPS)",
        INFINITE_JUMP = "Infinite Jump",
        INFINITE_JUMP_DESC = "Infinite jump (hold Space)",
        INFINITE_STAMINA = "Infinite Stamina",
        INFINITE_STAMINA_DESC = "Stamina never drops (attack/jump/forms)",
        ANTI_COMBAT = "Anti Combat",
        ANTI_COMBAT_DESC = "Remove skull and combat mode effects",

        TP_MODE = "TP Mode",
        TP_MODE_DESC = "Position relative to mob",
        DISTANCE = "Distance",
        DISTANCE_DESC = "Distance from target",
        ANTI_EXECUTE = "Anti Execute",
        ANTI_EXECUTE_DESC = "Stays far after death; off stays close so you can die",
        EXECUTE_DISTANCE = "Execute Dist.",
        EXECUTE_DISTANCE_DESC = "Distance when executing",
        AUTO_ATTACK = "Auto Attack",
        AUTO_ATTACK_DESC = "Spam M1",
        AUTOSKILLS_DESC = "Automatic skills and breathing",
        AUTO_SKILL_1 = "Auto Skill 1",
        AUTO_SKILL_2 = "Auto Skill 2",
        AUTO_SKILL_3 = "Auto Skill 3",
        AUTO_SKILL_4 = "Auto Skill 4",
        AUTO_SKILL_5 = "Auto Skill 5",
        AUTO_SKILL_6 = "Auto Skill 6",
        AUTO_SKILL_7 = "Auto Skill 7",
        AUTO_SKILL_T = "Auto Skill T",
        AUTO_SKILL_Y = "Auto Skill Y",
        AUTO_SKILL_DESC = "Presses every 5 seconds",
        AUTO_BREATH = "Auto Breath",
        AUTO_BREATH_DESC = "Below 40%: waits, holds G and retries if it fails",
        LOAD_MOBS = "Load Mobs",
        LOAD_MOBS_DESC = "Detects already loaded mobs without teleporting",
        FARM_MOBS_LIST = "Farm Mobs List",
        FARM_MOBS_LIST_DESC = "Select Mob to farm",
        FARM = "Farm",
        FARM_DESC = "Auto TP",
        FARM_GENERAL_RAID = "General Raid Farm",
        FARM_GENERAL_RAID_DESC = "Prioritizes bosses and instantly switches when a target dies",
        FARM_CASTLE = "Castle Farm",
        FARM_CASTLE_DESC = "Farm Akaza, Doma and Kokushibo",
        FARM_CASTLE_GENERAL = "General Castle Farm",
        FARM_CASTLE_GENERAL_DESC = "Activates GenericOni and prioritizes Akaza, Doma and Kokushibo",

        RAIDS = "Raids (Locations)",
        RAIDS_DESC = "Raid Farm",
        EVENTS = "Events",
        EVENTS_DESC = "Special locations and events",
        EVENT_TP_DESC = "Teleport to this location",
        EVENT_RAID = "Raid",
        EVENT_RAID_DESC = "Teleport to the Raid area",
        EVENT_DOUMA = "Douma — Infinite Castle",
        EVENT_AKAZA = "Akaza — Infinite Castle",
        EVENT_KOKUSHIBO = "Kokushibo — Infinite Castle",
        EVENT_SLAYER_CASTLE = "Slayer Corps — Infinite Castle",
        EVENT_SOUP = "Soup Vendor",
        EVENT_MEAT = "Meat Vendor",
        EVENT_JEWEL_SELLER = "Jewel Vendor",
        EVENT_NICHIRIN_HORN = "Nichirin and Oni Horn Vendor",
        TP_RAID_AREA = "TP Raid Area",
        TP_RAID_AREA_DESC = "Go to start",
        INFINITE_CASTLE = "Infinite Castle (Locations)",
        INFINITE_CASTLE_DESC = "Farm & TPs",
        TP_SLAYER_CORPS = "TP Slayer Corps",
        TP_SLAYER_CORPS_DESC = "Coord 1",
        TP_AKAZA_DOMA = "TP Akaza/Doma",
        TP_AKAZA_DOMA_DESC = "Coord 2",
        TP_KOKUSHIBO = "TP Kokushibo",
        TP_KOKUSHIBO_DESC = "Coord 3",
        TRINKET_FARM = "Trinket Farm",
        TRINKET_FARM_DESC = "Auto collect",
        ORE_FARM = "Ore Farm",
        ORE_FARM_DESC = "TP + mine with pickaxe (Z)",

        SELECT_PLAYER = "Select Player",
        SELECT_PLAYER_DESC = "Choose target",
        UPDATE_LIST = "Update List",
        UPDATE_LIST_DESC = "Reload names",
        PLAYER_ACTIONS = "Player Actions",
        PLAYER_ACTIONS_DESC = "Options for selected target",
        GO_TO_PLAYER = "Go to Player",
        GO_TO_PLAYER_DESC = "TP Fly",
        ESP_PLAYERS = "ESP Players",
        ESP_PLAYERS_DESC = "Wallhack",
        FARM_PLAYER = "Farm Player",
        FARM_PLAYER_DESC = "Follow and kill",
        SPECTATE = "Spectate",
        SPECTATE_DESC = "Observe target",
        HEIGHT = "Height",
        HEIGHT_DESC = "Camera height",
        DISTANCE_SPECTATE = "Distance",
        DISTANCE_SPECTATE_DESC = "Camera distance",
        ENABLE_SPECTATE = "Enable Spectate",
        ENABLE_SPECTATE_DESC = "Look at selected player",

        VILLAGES = "Villages",
        VILLAGES_DESC = "Main locations",
        TP_HAYAKAWA = "Okuya",
        TP_HAYAKAWA_DESC = "TP",
        TP_OKUYA = "Hayakawa",
        TP_OKUYA_DESC = "TP",
        TP_KAMAKURA = "Kamakura",
        TP_KAMAKURA_DESC = "TP",
        TP_SLAYER = "Slayer Corps",
        TP_SLAYER_DESC = "TP",
        TP_DISTRITO = "District",
        TP_DISTRITO_DESC = "TP",
        TP_SLAYER_EXAM = "Slayer Exam",
        TP_SLAYER_EXAM_DESC = "TP",

        BREATHS = "Breaths",
        BREATHS_DESC = "Trainers",
        TP_MIST = "Mist",
        TP_MIST_DESC = "TP",
        TP_WATER = "Water",
        TP_WATER_DESC = "TP",
        TP_WIND = "Wind",
        TP_WIND_DESC = "TP",
        TP_THUNDER = "Thunder",
        TP_THUNDER_DESC = "TP",
        TP_INSECT = "Insect",
        TP_INSECT_DESC = "TP",
        TP_FLAME = "Flame",
        TP_FLAME_DESC = "TP",
        TP_SUN = "Sun",
        TP_SUN_DESC = "TP",
        TP_MOON = "Moon",
        TP_MOON_DESC = "TP",
        TP_BEAST = "Beast",
        TP_BEAST_DESC = "TP",
        TP_SOUND = "Sound",
        TP_SOUND_DESC = "TP",
        TP_FLOWER = "Flower",
        TP_FLOWER_DESC = "TP",
        TP_SERPENT = "Serpent",
        TP_SERPENT_DESC = "TP",
        TP_LOVE = "Love",
        TP_LOVE_DESC = "TP",

        LANGUAGE = "Language",
        LANGUAGE_DESC = "Change language",
        THEME = "Theme",
        THEME_DESC = "Change colors",
        OPACITY = "Opacity",
        OPACITY_DESC = "Transparency",
        INFO_LABEL = "Info: If farm doesn't work, go to Teleports and load mobs/map",
        EXTRAS_MOBS = "Extras",
        EXTRAS_MOBS_DESC = "Additional functions",
        LOAD_MAP = "Load entire map",
        LOAD_MAP_DESC = "TP through entire map"
    }
}

local function T(key)
    return TRANSLATIONS[CurrentLang] and TRANSLATIONS[CurrentLang][key] or key
end

-- =========================
-- CONFIGURAÇÃO VISUAL & TEMAS
-- =========================
globalEnv.CurrentThemeName = globalEnv.CurrentThemeName or "Material You"
local CurrentThemeName = globalEnv.CurrentThemeName
globalEnv.CurrentOpacity = globalEnv.CurrentOpacity or 0
local CurrentOpacity = globalEnv.CurrentOpacity

local THEME_PRESETS = {
    -- Paleta padrão inspirada no Material You (M3): superfícies tonais,
    -- contraste acessível e uma cor primária usada nos estados ativos.
    ["Material You"] = {
        Background = Color3.fromRGB(18, 19, 24),
        PanelBg    = Color3.fromRGB(30, 31, 38),
        Surface    = Color3.fromRGB(30, 31, 38),
        SurfaceContainer = Color3.fromRGB(36, 37, 45),
        SurfaceVariant = Color3.fromRGB(70, 70, 79),
        Text       = Color3.fromRGB(232, 225, 229),
        OnSurface  = Color3.fromRGB(232, 225, 229),
        SubText    = Color3.fromRGB(202, 196, 208),
        OnSurfaceVariant = Color3.fromRGB(202, 196, 208),
        Off        = Color3.fromRGB(73, 69, 79),
        On         = Color3.fromRGB(208, 188, 255),
        Border     = Color3.fromRGB(147, 143, 153),
        Outline    = Color3.fromRGB(147, 143, 153),
        OutlineVariant = Color3.fromRGB(70, 70, 79),
        Hover      = Color3.fromRGB(49, 47, 56),
        Danger     = Color3.fromRGB(255, 180, 171),
        Accent     = Color3.fromRGB(208, 188, 255),
        Primary    = Color3.fromRGB(208, 188, 255),
        PrimaryContainer = Color3.fromRGB(79, 55, 139),
        OnPrimary  = Color3.fromRGB(56, 30, 114),
        KnobColor  = Color3.fromRGB(255, 251, 255)
    },
    ["Carbon"] = {
        Background = Color3.fromRGB(17, 18, 20),
        PanelBg    = Color3.fromRGB(29, 30, 33),
        Surface    = Color3.fromRGB(29, 30, 33),
        SurfaceContainer = Color3.fromRGB(36, 37, 40),
        SurfaceVariant = Color3.fromRGB(67, 70, 76),
        Text       = Color3.fromRGB(232, 232, 236),
        OnSurface  = Color3.fromRGB(232, 232, 236),
        SubText    = Color3.fromRGB(194, 195, 201),
        OnSurfaceVariant = Color3.fromRGB(194, 195, 201),
        Off        = Color3.fromRGB(72, 73, 78),
        On         = Color3.fromRGB(196, 199, 208),
        Border     = Color3.fromRGB(145, 147, 154),
        Outline    = Color3.fromRGB(145, 147, 154),
        OutlineVariant = Color3.fromRGB(67, 70, 76),
        Hover      = Color3.fromRGB(47, 49, 53),
        Danger     = Color3.fromRGB(255, 180, 171),
        Accent     = Color3.fromRGB(196, 199, 208),
        Primary    = Color3.fromRGB(196, 199, 208),
        PrimaryContainer = Color3.fromRGB(66, 70, 80),
        OnPrimary  = Color3.fromRGB(35, 37, 43),
        KnobColor  = Color3.fromRGB(250, 250, 255)
    },
    ["Arctic"] = {
        Background = Color3.fromRGB(247, 249, 255),
        PanelBg    = Color3.fromRGB(239, 241, 248),
        Surface    = Color3.fromRGB(239, 241, 248),
        SurfaceContainer = Color3.fromRGB(231, 233, 241),
        SurfaceVariant = Color3.fromRGB(222, 226, 236),
        Text       = Color3.fromRGB(25, 28, 36),
        OnSurface  = Color3.fromRGB(25, 28, 36),
        SubText    = Color3.fromRGB(72, 76, 88),
        OnSurfaceVariant = Color3.fromRGB(72, 76, 88),
        Off        = Color3.fromRGB(119, 121, 129),
        On         = Color3.fromRGB(67, 91, 145),
        Border     = Color3.fromRGB(119, 121, 129),
        Outline    = Color3.fromRGB(119, 121, 129),
        OutlineVariant = Color3.fromRGB(198, 202, 212),
        Hover      = Color3.fromRGB(226, 228, 237),
        Danger     = Color3.fromRGB(186, 26, 26),
        Accent     = Color3.fromRGB(67, 91, 145),
        Primary    = Color3.fromRGB(67, 91, 145),
        PrimaryContainer = Color3.fromRGB(215, 226, 255),
        OnPrimary  = Color3.fromRGB(255, 255, 255),
        KnobColor  = Color3.fromRGB(255, 255, 255)
    },
    ["Nebula"] = {
        Background = Color3.fromRGB(24, 20, 30),
        PanelBg    = Color3.fromRGB(35, 30, 42),
        Surface    = Color3.fromRGB(35, 30, 42),
        SurfaceContainer = Color3.fromRGB(44, 38, 52),
        SurfaceVariant = Color3.fromRGB(76, 69, 84),
        Text       = Color3.fromRGB(239, 228, 242),
        OnSurface  = Color3.fromRGB(239, 228, 242),
        SubText    = Color3.fromRGB(205, 190, 209),
        OnSurfaceVariant = Color3.fromRGB(205, 190, 209),
        Off        = Color3.fromRGB(79, 70, 85),
        On         = Color3.fromRGB(235, 184, 255),
        Border     = Color3.fromRGB(155, 143, 158),
        Outline    = Color3.fromRGB(155, 143, 158),
        OutlineVariant = Color3.fromRGB(76, 69, 84),
        Hover      = Color3.fromRGB(55, 47, 64),
        Danger     = Color3.fromRGB(255, 180, 171),
        Accent     = Color3.fromRGB(235, 184, 255),
        Primary    = Color3.fromRGB(235, 184, 255),
        PrimaryContainer = Color3.fromRGB(103, 44, 121),
        OnPrimary  = Color3.fromRGB(74, 18, 91),
        KnobColor  = Color3.fromRGB(255, 244, 255)
    },
    ["Neon"] = {
        Background = Color3.fromRGB(13, 22, 19),
        PanelBg    = Color3.fromRGB(20, 35, 30),
        Surface    = Color3.fromRGB(20, 35, 30),
        SurfaceContainer = Color3.fromRGB(26, 45, 38),
        SurfaceVariant = Color3.fromRGB(61, 79, 70),
        Text       = Color3.fromRGB(220, 255, 238),
        OnSurface  = Color3.fromRGB(220, 255, 238),
        SubText    = Color3.fromRGB(171, 216, 192),
        OnSurfaceVariant = Color3.fromRGB(171, 216, 192),
        Off        = Color3.fromRGB(65, 82, 73),
        On         = Color3.fromRGB(108, 235, 170),
        Border     = Color3.fromRGB(139, 170, 151),
        Outline    = Color3.fromRGB(139, 170, 151),
        OutlineVariant = Color3.fromRGB(61, 79, 70),
        Hover      = Color3.fromRGB(31, 51, 42),
        Danger     = Color3.fromRGB(255, 180, 171),
        Accent     = Color3.fromRGB(108, 235, 170),
        Primary    = Color3.fromRGB(108, 235, 170),
        PrimaryContainer = Color3.fromRGB(0, 83, 54),
        OnPrimary  = Color3.fromRGB(0, 55, 35),
        KnobColor  = Color3.fromRGB(219, 255, 235)
    },
    ["Carmesim"] = {
        Background = Color3.fromRGB(30, 17, 18),
        PanelBg    = Color3.fromRGB(46, 25, 27),
        Surface    = Color3.fromRGB(46, 25, 27),
        SurfaceContainer = Color3.fromRGB(57, 31, 33),
        SurfaceVariant = Color3.fromRGB(88, 64, 65),
        Text       = Color3.fromRGB(255, 237, 238),
        OnSurface  = Color3.fromRGB(255, 237, 238),
        SubText    = Color3.fromRGB(233, 188, 190),
        OnSurfaceVariant = Color3.fromRGB(233, 188, 190),
        Off        = Color3.fromRGB(93, 64, 66),
        On         = Color3.fromRGB(255, 180, 171),
        Border     = Color3.fromRGB(188, 139, 141),
        Outline    = Color3.fromRGB(188, 139, 141),
        OutlineVariant = Color3.fromRGB(88, 64, 65),
        Hover      = Color3.fromRGB(69, 37, 40),
        Danger     = Color3.fromRGB(255, 180, 171),
        Accent     = Color3.fromRGB(255, 180, 171),
        Primary    = Color3.fromRGB(255, 180, 171),
        PrimaryContainer = Color3.fromRGB(147, 0, 10),
        OnPrimary  = Color3.fromRGB(105, 0, 5),
        KnobColor  = Color3.fromRGB(255, 248, 247)
    },
    ["Galaxy"] = {
        Background = Color3.fromRGB(17, 19, 31),
        PanelBg    = Color3.fromRGB(27, 30, 47),
        Surface    = Color3.fromRGB(27, 30, 47),
        SurfaceContainer = Color3.fromRGB(35, 39, 58),
        SurfaceVariant = Color3.fromRGB(67, 70, 94),
        Text       = Color3.fromRGB(228, 225, 255),
        OnSurface  = Color3.fromRGB(228, 225, 255),
        SubText    = Color3.fromRGB(193, 194, 224),
        OnSurfaceVariant = Color3.fromRGB(193, 194, 224),
        Off        = Color3.fromRGB(70, 72, 97),
        On         = Color3.fromRGB(190, 198, 255),
        Border     = Color3.fromRGB(145, 145, 178),
        Outline    = Color3.fromRGB(145, 145, 178),
        OutlineVariant = Color3.fromRGB(67, 70, 94),
        Hover      = Color3.fromRGB(42, 46, 67),
        Danger     = Color3.fromRGB(255, 180, 171),
        Accent     = Color3.fromRGB(190, 198, 255),
        Primary    = Color3.fromRGB(190, 198, 255),
        PrimaryContainer = Color3.fromRGB(65, 73, 137),
        OnPrimary  = Color3.fromRGB(39, 47, 106),
        KnobColor  = Color3.fromRGB(244, 243, 255)
    },
    ["Blush"] = {
        Background = Color3.fromRGB(255, 247, 249),
        PanelBg    = Color3.fromRGB(255, 237, 243),
        Surface    = Color3.fromRGB(255, 237, 243),
        SurfaceContainer = Color3.fromRGB(255, 228, 237),
        SurfaceVariant = Color3.fromRGB(246, 218, 228),
        Text       = Color3.fromRGB(45, 28, 35),
        OnSurface  = Color3.fromRGB(45, 28, 35),
        SubText    = Color3.fromRGB(112, 76, 89),
        OnSurfaceVariant = Color3.fromRGB(112, 76, 89),
        Off        = Color3.fromRGB(137, 106, 118),
        On         = Color3.fromRGB(174, 52, 102),
        Border     = Color3.fromRGB(166, 124, 139),
        Outline    = Color3.fromRGB(166, 124, 139),
        OutlineVariant = Color3.fromRGB(230, 194, 207),
        Hover      = Color3.fromRGB(255, 226, 235),
        Danger     = Color3.fromRGB(186, 26, 26),
        Accent     = Color3.fromRGB(174, 52, 102),
        Primary    = Color3.fromRGB(174, 52, 102),
        PrimaryContainer = Color3.fromRGB(255, 216, 229),
        OnPrimary  = Color3.fromRGB(255, 255, 255),
        KnobColor  = Color3.fromRGB(255, 255, 255)
    },
    ["Branco"] = {
        Background = Color3.fromRGB(255, 251, 254),
        PanelBg    = Color3.fromRGB(247, 242, 247),
        Surface    = Color3.fromRGB(247, 242, 247),
        SurfaceContainer = Color3.fromRGB(241, 236, 241),
        SurfaceVariant = Color3.fromRGB(232, 224, 231),
        Text       = Color3.fromRGB(30, 28, 32),
        OnSurface  = Color3.fromRGB(30, 28, 32),
        SubText    = Color3.fromRGB(76, 70, 78),
        OnSurfaceVariant = Color3.fromRGB(76, 70, 78),
        Off        = Color3.fromRGB(121, 116, 123),
        On         = Color3.fromRGB(103, 80, 110),
        Border     = Color3.fromRGB(121, 116, 123),
        Outline    = Color3.fromRGB(121, 116, 123),
        OutlineVariant = Color3.fromRGB(202, 196, 202),
        Hover      = Color3.fromRGB(239, 233, 239),
        Danger     = Color3.fromRGB(186, 26, 26),
        Accent     = Color3.fromRGB(103, 80, 110),
        Primary    = Color3.fromRGB(103, 80, 110),
        PrimaryContainer = Color3.fromRGB(235, 219, 239),
        OnPrimary  = Color3.fromRGB(255, 255, 255),
        KnobColor  = Color3.fromRGB(255, 251, 255)
    },
}

local THEME = {}
if THEME_PRESETS[CurrentThemeName] then
    for k,v in pairs(THEME_PRESETS[CurrentThemeName]) do THEME[k] = v end
else
    CurrentThemeName = "Carbon"
    globalEnv.CurrentThemeName = CurrentThemeName
    for k,v in pairs(THEME_PRESETS[CurrentThemeName]) do THEME[k] = v end
end

local TYPE_COLORS = {
    Label          = Color3.fromRGB(145, 143, 153),
    Single         = Color3.fromRGB(128, 218, 188),
    Toggle         = Color3.fromRGB(255, 180, 171),
    Slider         = Color3.fromRGB(174, 203, 255),
    InputImmediate = Color3.fromRGB(225, 190, 231),
    InputSelect    = Color3.fromRGB(255, 216, 228),
    ListPersistent = Color3.fromRGB(255, 216, 145),
    ListAuto       = Color3.fromRGB(255, 216, 145),
    Container      = Color3.fromRGB(208, 188, 255)
}

globalEnv._HubStates = globalEnv._HubStates or {}
globalEnv._HubSelections = globalEnv._HubSelections or {}
globalEnv._ScriptHubStates = globalEnv._ScriptHubStates or {}

-- =========================
-- UTILITÁRIAS UI
-- =========================
local function new(class, props)
    local o = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            if k ~= "Parent" then pcall(function() o[k] = v end) end
        end
        if props.Parent then o.Parent = props.Parent end
    end
    return o
end

local function tween(inst, props, t, style, dir)
    local info = TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local tw = TweenService:Create(inst, info, props)
    tw:Play()
    return tw
end

local function makeRound(inst, rad) return new("UICorner", {Parent = inst, CornerRadius = UDim.new(0, rad)}) end
local function makeStroke(inst, col, th) return new("UIStroke", {Parent = inst, Color = col or THEME.Border, Thickness = th or 1}) end
local function clamp(v, a, b) if v < a then return a end if v > b then return b end return v end
local function contrastText(color)
    local lum = (color.R * 0.299 + color.G * 0.587 + color.B * 0.114)
    return lum > 0.55 and Color3.fromRGB(28, 28, 32) or Color3.new(1, 1, 1)
end

local function MakeDraggable(handle, target)
    local dragging = false
    local dragStart = nil
    local startPos = nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        local delta = input.Position - dragStart
        target.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end)
end

for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "MoonDF_VirginHub" then
        pcall(function() v:Destroy() end)
    end
end

local screenGui = new("ScreenGui", {
    Name = "MoonDF_VirginHub",
    Parent = CoreGui,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    ResetOnSpawn = false,
    DisplayOrder = 50,
    IgnoreGuiInset = true,
})
pcall(function() screenGui.Enabled = true end)

-- ======================================================================
-- GAME LOGIC
-- ======================================================================

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

globalEnv.flyToggle = globalEnv.flyToggle or false
local flyToggle = globalEnv.flyToggle
globalEnv.flySpeedValue = globalEnv.flySpeedValue or 150
local flySpeedValue = globalEnv.flySpeedValue
local flyConn, bg, bv
globalEnv.speedToggle = globalEnv.speedToggle or false
local speedToggle = globalEnv.speedToggle
globalEnv.walkSpeed = globalEnv.walkSpeed or 16
local walkSpeed = globalEnv.walkSpeed
local speedConn
local BASE_WALKSPEED = 16

local coordsEnabled = false
local coordsGui, coordsLabel, coordsConn
globalEnv.noFogEnabled = globalEnv.noFogEnabled or false
local noFogEnabled = globalEnv.noFogEnabled
globalEnv.ultraLiteEnabled = globalEnv.ultraLiteEnabled or false
local ultraLiteEnabled = globalEnv.ultraLiteEnabled
local liteLoop = nil

globalEnv.trinketFarm = globalEnv.trinketFarm or false
local trinketFarm = globalEnv.trinketFarm
globalEnv.oreFarm = globalEnv.oreFarm or false
local oreFarm = globalEnv.oreFarm
globalEnv.autoAttack = globalEnv.autoAttack or false
local autoAttack = globalEnv.autoAttack
local currentMob = nil
local isEnabled = false
local farmRespawnBusy = false
local farmRespawnLast = 0
local FARM_RESPAWN_HEALTH = 60
local FARM_RESPAWN_COOLDOWN = 3
globalEnv.generalAutoRegenThreshold = tonumber(globalEnv.generalAutoRegenThreshold) or 60
local generalAutoRegenThreshold = globalEnv.generalAutoRegenThreshold
globalEnv.farmAutoRegen = globalEnv.farmAutoRegen == true
local farmAutoRegen = globalEnv.farmAutoRegen
globalEnv.generalAutoRegen = globalEnv.generalAutoRegen == true
local generalAutoRegen = globalEnv.generalAutoRegen
globalEnv.autoRegenHealthESP = globalEnv.autoRegenHealthESP == true
local autoRegenHealthESP = globalEnv.autoRegenHealthESP
local manualRespawnBusy = false
local farmRespawnCooldownLogLast = 0
local farmHealthLogLast = 0
local FARM_HEALTH_LOG_INTERVAL = 0.50
-- No modo geral, guarda o CFrame antes do respawn para voltar ao mesmo
-- ponto assim que o novo personagem for criado. O modo Farm não usa isso.
local generalAutoRegenReturnCFrame = nil
local generalAutoRegenRestoreConn = nil
local raidFarmActive = false
local farmIsRaid = false
local farmScope = nil
local farmCanFinalize = false
local raidFarmTarget = nil
local raidFarmLastScan = 0
local raidFarmScanInterval = 0.35
local RAID_GENERAL_TARGET = "__MOONDF_GENERAL_RAID__"
local castleFarmActive = false
local castleFarmTarget = nil
local castleFarmLastScan = 0
local castleBossEngaged = false
local CASTLE_GENERAL_TARGET = "__MOONDF_GENERAL_CASTLE__"
local connection = nil
local loadingAllMobs = false
local notifyDev
local teleportAndLookLooping = false
local farmNoclipWasEnabled = false
local oreFarmNoclipWasEnabled = false
local autoAttackLoopToken = 0
globalEnv.selectedPlayerName = globalEnv.selectedPlayerName or nil
local selectedPlayerName = globalEnv.selectedPlayerName
globalEnv.teleportMode = globalEnv.teleportMode or "Behind"
local teleportMode = globalEnv.teleportMode
globalEnv.FARM_DISTANCE = globalEnv.FARM_DISTANCE or 4
local FARM_DISTANCE = globalEnv.FARM_DISTANCE
local savedExecuteDistance = tonumber(globalEnv._ScriptHubStates["ExecuteDistance"])
if savedExecuteDistance then
    globalEnv.EXECUTE_DISTANCE = savedExecuteDistance
elseif globalEnv.EXECUTE_DISTANCE == nil or tonumber(globalEnv.EXECUTE_DISTANCE) == 1 then
    globalEnv.EXECUTE_DISTANCE = 20
end
local EXECUTE_DISTANCE = globalEnv.EXECUTE_DISTANCE
local PLAYER_EXECUTE_DISTANCE = 20
globalEnv.antiExecute = globalEnv.antiExecute ~= false
local antiExecute = globalEnv.antiExecute

local function autoRegenIsEnabled()
    return generalAutoRegen or (isEnabled and farmAutoRegen)
end

local function activeAutoRegenThreshold()
    if isEnabled and farmAutoRegen then
        return FARM_RESPAWN_HEALTH
    end
    return generalAutoRegenThreshold
end

local function isGeneralAutoRegenMode()
    return generalAutoRegen and not (isEnabled and farmAutoRegen)
end

local function captureGeneralAutoRegenPosition()
    if not isGeneralAutoRegenMode() then
        generalAutoRegenReturnCFrame = nil
        return false
    end

    local currentRoot = character
        and character.Parent
        and character:FindFirstChild("HumanoidRootPart")
    if not currentRoot or not currentRoot:IsA("BasePart") then
        generalAutoRegenReturnCFrame = nil
        return false
    end

    -- CFrame preserva posição e rotação exatas, ao contrário de salvar
    -- apenas o Vector3 da posição.
    generalAutoRegenReturnCFrame = currentRoot.CFrame
    return true
end

local function restoreGeneralAutoRegenPosition(newCharacter)
    local savedCFrame = generalAutoRegenReturnCFrame
    if not savedCFrame or not newCharacter then
        return
    end

    if generalAutoRegenRestoreConn then
        generalAutoRegenRestoreConn:Disconnect()
        generalAutoRegenRestoreConn = nil
    end

    local newRoot = newCharacter:FindFirstChild("HumanoidRootPart")
        or newCharacter:WaitForChild("HumanoidRootPart", 2)
    if not newRoot or not newRoot:IsA("BasePart") then
        return
    end

    local restoreStartedAt = os.clock()
    local restoreWindow = 2
    local function applySavedPosition()
        if not newCharacter.Parent or not newRoot.Parent then
            return false
        end

        -- O servidor pode aplicar o ponto aleatório do respawn alguns
        -- frames depois do CharacterAdded. Reaplica o CFrame por uma janela
        -- curta para vencer essa sobrescrita sem deixar loop permanente.
        pcall(function()
            newRoot.CFrame = savedCFrame
            newRoot.AssemblyLinearVelocity = Vector3.zero
            newRoot.AssemblyAngularVelocity = Vector3.zero
        end)
        return true
    end

    -- Primeiro teleporte é imediato; os próximos cobrem a correção tardia
    -- feita pelo respawn do servidor.
    applySavedPosition()
    generalAutoRegenRestoreConn = RunService.Heartbeat:Connect(function()
        if os.clock() - restoreStartedAt >= restoreWindow
            or not applySavedPosition()
        then
            if generalAutoRegenRestoreConn then
                generalAutoRegenRestoreConn:Disconnect()
                generalAutoRegenRestoreConn = nil
            end
        end
    end)
    generalAutoRegenReturnCFrame = nil
end

function toggleFarmAutoRegen(state)
    farmAutoRegen = state == true
    globalEnv.farmAutoRegen = farmAutoRegen
end

function toggleGeneralAutoRegen(state)
    generalAutoRegen = state == true
    globalEnv.generalAutoRegen = generalAutoRegen
    if generalAutoRegen and notifyDev then
        notifyDev(T("AUTO_REGEN_WARNING"))
    end
end

function toggleAutoRegenHealthESP(state)
    autoRegenHealthESP = state == true
    globalEnv.autoRegenHealthESP = autoRegenHealthESP
end

-- Equipamento legítimo da Katana:
-- a Tool precisa estar no Backpack (ou já no Character) do jogador.
-- Não força estado por RemoteEvent; Humanoid:EquipTool replica a ação
-- normalmente para o servidor da experiência.
local KATANA_NAME = "Katana"

local function equipKatana()
    local currentCharacter = player and player.Character
    local currentHumanoid = currentCharacter
        and currentCharacter:FindFirstChildOfClass("Humanoid")
    if not currentCharacter or not currentHumanoid then
        return false
    end

    local equipped = currentCharacter:FindFirstChild(KATANA_NAME)
    if equipped and equipped:IsA("Tool") then
        return true
    end

    local backpack = player:FindFirstChildOfClass("Backpack")
    local katana = backpack and backpack:FindFirstChild(KATANA_NAME)
    if not katana or not katana:IsA("Tool") then
        return false
    end

    currentHumanoid:EquipTool(katana)
    return true
end

-- No Demon Fall, o HP real fica em Character.Health ou Player.Health;
-- Humanoid.Health/MaxHealth não é usado para essa verificação.
local function readFarmHealth()
    local currentCharacter = player and player.Character
    local health = nil
    local source = "nenhuma"

    local characterHealth = currentCharacter
        and currentCharacter:FindFirstChild("Health")
    if characterHealth and characterHealth:IsA("ValueBase") then
        health = tonumber(characterHealth.Value)
        source = "Character.Health"
    end

    if health == nil then
        local playerHealth = player and player:FindFirstChild("Health")
        if playerHealth and playerHealth:IsA("ValueBase") then
            health = tonumber(playerHealth.Value)
            source = "Player.Health"
        end
    end

    local now = os.clock()
    if autoRegenIsEnabled() and (now - (farmHealthLogLast or 0)) >= FARM_HEALTH_LOG_INTERVAL then
        farmHealthLogLast = now
        print(string.format(
            "[MOONDF][HP] farm=%s source=%s health=%s threshold=%d character=%s",
            tostring(isEnabled),
            source,
            health == nil and "nil" or tostring(health),
            activeAutoRegenThreshold(),
            currentCharacter and currentCharacter.Name or "nil"
        ))
    end

    return health, source
end

-- Recria o personagem quando o Auto Regen ativo atinge seu limite.
-- O botão do farm usa 60 fixo; o botão geral usa o limite configurado.
-- A chamada roda em uma thread separada para não travar o loop do farm
-- caso o InvokeServer demore para responder.
local function respawnFarmCharacterIfLowHealth()
    if not autoRegenIsEnabled() or farmRespawnBusy then
        return false
    end

    local health, source = readFarmHealth()
    local threshold = activeAutoRegenThreshold()

    if health == nil or health > threshold then
        return false
    end

    local now = os.clock()
    if (now - farmRespawnLast) < FARM_RESPAWN_COOLDOWN then
        if (now - (farmRespawnCooldownLogLast or 0)) >= FARM_HEALTH_LOG_INTERVAL then
            farmRespawnCooldownLogLast = now
            print(string.format(
                "[MOONDF][RESPAWN] cooldown ativo: health=%s source=%s threshold=%d",
                tostring(health),
                source,
                threshold
            ))
        end
        return false
    end

    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local sync = remotes and remotes:FindFirstChild("Sync")
    if not sync or not sync:IsA("RemoteFunction") then
        warn("[MOONDF][RESPAWN] Remotes.Sync não encontrado para SpawnCharacter.")
        farmRespawnLast = now
        return false
    end

    farmRespawnBusy = true
    farmRespawnLast = now
    -- A captura precisa acontecer imediatamente antes do respawn para que
    -- o retorno use a posição real onde o jogador estava no momento do HP
    -- baixo. Isso é exclusivo do modo geral.
    captureGeneralAutoRegenPosition()
    print(string.format(
        "[MOONDF][RESPAWN] disparando: health=%s source=%s threshold=%d",
        tostring(health),
        source,
        threshold
    ))

    task.spawn(function()
        local success, err = pcall(function()
            sync:InvokeServer("Player", "SpawnCharacter")
        end)
        if not success then
            generalAutoRegenReturnCFrame = nil
            warn("[MOONDF][RESPAWN] falha ao chamar SpawnCharacter:", err)
        else
            print("[MOONDF][RESPAWN] SpawnCharacter chamado com sucesso.")
            -- Evita que uma falha silenciosa do jogo deixe uma posição antiga
            -- pendente para um CharacterAdded posterior.
            local pendingReturnCFrame = generalAutoRegenReturnCFrame
            task.delay(3, function()
                if generalAutoRegenReturnCFrame == pendingReturnCFrame then
                    generalAutoRegenReturnCFrame = nil
                end
            end)
        end
        task.wait(1.5)
        farmRespawnBusy = false
        print("[MOONDF][RESPAWN] monitor liberado.")
    end)

    return true
end

-- Monitor independente do loop de ataque: mantém o respawn funcionando
-- mesmo quando o farm está sem alvo ou aguardando um boss.
if globalEnv._MoonDFFarmHealthMonitorConnection then
    pcall(function()
        globalEnv._MoonDFFarmHealthMonitorConnection:Disconnect()
    end)
end
local farmHealthMonitorConnection = RunService.Heartbeat:Connect(function()
    if autoRegenIsEnabled() and not farmRespawnBusy then
        respawnFarmCharacterIfLowHealth()
    end
end)
globalEnv._MoonDFFarmHealthMonitorConnection = farmHealthMonitorConnection

-- Botão Developer: respawn manual, uma única chamada por clique.
local function respawnCharacterOnce()
    if manualRespawnBusy then
        return
    end

    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local sync = remotes and remotes:FindFirstChild("Sync")
    if not sync or not sync:IsA("RemoteFunction") then
        warn("[MOONDF HUB] Remotes.Sync não encontrado para Respawnar.")
        return
    end

    manualRespawnBusy = true
    -- Quando o botão estiver dentro do Auto Regen Geral, mantém o mesmo
    -- comportamento do respawn automático e retorna ao ponto atual.
    captureGeneralAutoRegenPosition()
    -- Evita que o monitor de HP dispare um segundo respawn imediatamente
    -- depois do clique manual.
    farmRespawnLast = os.clock()
    task.spawn(function()
        local success, err = pcall(function()
            sync:InvokeServer("Player", "SpawnCharacter")
        end)
        if not success then
            warn("[MOONDF HUB] Falha ao respawnar manualmente:", err)
        end
        task.wait(1.5)
        manualRespawnBusy = false
    end)
end

if globalEnv._MoonDFKatanaKeyConnection then
    pcall(function()
        globalEnv._MoonDFKatanaKeyConnection:Disconnect()
    end)
end
globalEnv._MoonDFKatanaKeyConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or input.KeyCode ~= Enum.KeyCode.R then
        return
    end
    equipKatana()
end)

-- Sistema de AutoSkills mantido em uma tabela global para não estourar
-- o limite de registradores locais do Luau neste script grande.
AutoSkillSystem = globalEnv._MoonDFAutoSkillSystem or {}
globalEnv._MoonDFAutoSkillSystem = AutoSkillSystem
AutoSkillSystem.enabled = {}
AutoSkillSystem.nextUse = {}
AutoSkillSystem.keyMap = {
    ["1"] = Enum.KeyCode.One,
    ["2"] = Enum.KeyCode.Two,
    ["3"] = Enum.KeyCode.Three,
    ["4"] = Enum.KeyCode.Four,
    ["5"] = Enum.KeyCode.Five,
    ["6"] = Enum.KeyCode.Six,
    ["7"] = Enum.KeyCode.Seven,
    T = Enum.KeyCode.T,
    Y = Enum.KeyCode.Y
}
AutoSkillSystem.loopRunning = false
AutoSkillSystem.autoBreath = false
AutoSkillSystem.breathBarEnabled = globalEnv.autoBreathBar == true
AutoSkillSystem.breathBarMode = globalEnv.autoBreathBarMode or "Screen"
AutoSkillSystem.breathHolding = false
AutoSkillSystem.breathPreparing = false
AutoSkillSystem.breathStartedAt = 0
AutoSkillSystem.breathPrepareStartedAt = 0
AutoSkillSystem.breathRetryAt = 0
AutoSkillSystem.breathRetryPending = false
AutoSkillSystem.breathMonitorRunning = false
AutoSkillSystem.breathSafeDistance = 150
AutoSkillSystem.skillInterval = 5
AutoSkillSystem.breathThreshold = 40
AutoSkillSystem.breathPrepareDelay = 2
AutoSkillSystem.breathChargeTimeout = 4
AutoSkillSystem.breathRetryDelay = 6
AutoSkillSystem.breathValueNames = {
    breathing = true,
    currentbreathing = true,
    breath = true
}

AutoSkillSystem.readBreathingNode = function(node)
    if not node then return nil end

    local nodeName = string.lower(tostring(node.Name or ""))
    if AutoSkillSystem.breathValueNames[nodeName] then
        local ok, value = pcall(function()
            if node:IsA("ValueBase") then
                return tonumber(node.Value)
            end
        end)
        if ok and value ~= nil then
            return math.clamp(value, 0, 100)
        end
    end

    local ok, attributes = pcall(node.GetAttributes, node)
    if ok and attributes then
        for name, value in pairs(attributes) do
            if AutoSkillSystem.breathValueNames[string.lower(tostring(name))] then
                local number = tonumber(value)
                if number then return math.clamp(number, 0, 100) end
            end
        end
    end

    return nil
end

AutoSkillSystem.readBreathing = function()
    local sources = {player, player and player.Character}
    for _, source in ipairs(sources) do
        if source then
            local direct = AutoSkillSystem.readBreathingNode(source)
            if direct ~= nil then return direct end

            local ok, descendants = pcall(source.GetDescendants, source)
            if ok and descendants then
                for _, descendant in ipairs(descendants) do
                    local number = AutoSkillSystem.readBreathingNode(descendant)
                    if number ~= nil then return number end
                end
            end
        end
    end
    return nil
end

AutoSkillSystem.isActiveCooldownValue = function(value)
    if value:IsA("BoolValue") then return value.Value == true end
    if value:IsA("NumberValue") or value:IsA("IntValue") then
        return tonumber(value.Value) ~= nil and tonumber(value.Value) > 0
    end
    if value:IsA("StringValue") then
        local text = string.lower(tostring(value.Value))
        return text ~= "" and text ~= "0" and text ~= "false" and text ~= "ready"
    end
    return false
end

AutoSkillSystem.matchesSkillCooldown = function(name, key)
    local lower = string.lower(name)
    if not string.find(lower, "cooldown", 1, true) then return false end
    local token = string.lower(tostring(key))
    local patterns = {
        "skill" .. token,
        "form" .. token,
        "ability" .. token,
        "slot" .. token,
        "key" .. token,
        "cooldown" .. token,
        token .. "cooldown"
    }
    for _, pattern in ipairs(patterns) do
        if string.find(lower, pattern, 1, true) then return true end
    end
    -- Alguns servidores usam um único FormCooldown para a forma atual.
    return string.find(lower, "form", 1, true) ~= nil
end

AutoSkillSystem.isSkillOnCooldown = function(key)
    local sources = {player, character}
    for _, source in ipairs(sources) do
        if source then
            for _, descendant in ipairs(source:GetDescendants()) do
                if descendant:IsA("ValueBase")
                    and AutoSkillSystem.matchesSkillCooldown(descendant.Name, key)
                    and AutoSkillSystem.isActiveCooldownValue(descendant) then
                    return true
                end
            end
            for name, value in pairs(source:GetAttributes()) do
                if AutoSkillSystem.matchesSkillCooldown(name, key) then
                    local number = tonumber(value)
                    if value == true
                        or (number and number > 0)
                        or (type(value) == "string" and value ~= "" and value ~= "0") then
                        return true
                    end
                end
            end
        end
    end
    return false
end

AutoSkillSystem.isActionBusy = function()
    local sources = {character, player}
    local stateNames = {
        "attacking", "attack", "m1", "m2",
        "busy", "usingability",
        "usingskill", "skillactive", "abilityactive",
        "formactive", "transforming", "transformation"
    }

    local function isStateName(name)
        local lower = string.lower(tostring(name or "")):gsub("[%s_%-]", "")
        if string.find(lower, "cooldown", 1, true)
            or string.find(lower, "timer", 1, true)
            or lower == "cd" then
            return false
        end
        for _, state in ipairs(stateNames) do
            if lower == state or string.find(lower, state, 1, true) then
                return true
            end
        end
        return false
    end

    local function isActiveValue(value)
        if value == true then return true end
        local number = tonumber(value)
        if number then return number ~= 0 end
        local text = string.lower(tostring(value or ""))
        return text ~= "" and text ~= "false" and text ~= "ready"
            and text ~= "idle" and text ~= "none" and text ~= "0"
    end

    for _, source in ipairs(sources) do
        if source then
            for name, value in pairs(source:GetAttributes()) do
                if isStateName(name) and isActiveValue(value) then
                    return true
                end
            end
            for _, descendant in ipairs(source:GetDescendants()) do
                if isStateName(descendant.Name) then
                    if descendant:IsA("BoolValue") and descendant.Value then
                        return true
                    elseif descendant:IsA("StringValue") and isActiveValue(descendant.Value) then
                        return true
                    elseif (descendant:IsA("NumberValue") or descendant:IsA("IntValue"))
                        and tonumber(descendant.Value) ~= 0 then
                        return true
                    end
                end
            end
        end
    end

    local char = player and player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    if animator then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            local name = string.lower(tostring(track.Name or ""))
            local animationId = ""
            pcall(function()
                if track.Animation then
                    animationId = string.lower(tostring(track.Animation.AnimationId or ""))
                end
            end)
            if name:find("attack", 1, true)
                or name:find("skill", 1, true)
                or name:find("ability", 1, true)
                or name:find("form", 1, true)
                or animationId:find("attack", 1, true) then
                return true
            end
        end
    end
    return false
end

AutoSkillSystem.releaseBreath = function()
    if AutoSkillSystem.breathHolding then
        pcall(function()
            VIM:SendKeyEvent(false, Enum.KeyCode.G, false, game)
        end)
    end
    AutoSkillSystem.breathHolding = false
    AutoSkillSystem.breathPreparing = false
    AutoSkillSystem.breathStartedAt = 0
    AutoSkillSystem.breathPrepareStartedAt = 0
end

AutoSkillSystem.updateBreath = function()
    if not AutoSkillSystem.autoBreath then
        AutoSkillSystem.releaseBreath()
        return
    end

    local breath = AutoSkillSystem.readBreathing()
    if AutoSkillSystem.breathHolding then
        if (breath and breath >= 99.5)
        then
            print("[MoonDF AutoBreath] respiração chegou a 100%; soltando G")
            AutoSkillSystem.releaseBreath()
        elseif os.clock() - AutoSkillSystem.breathStartedAt >= AutoSkillSystem.breathChargeTimeout then
            print("[MoonDF AutoBreath] falha: não chegou a 100% em 4s; nova tentativa em 6s")
            AutoSkillSystem.releaseBreath()
            AutoSkillSystem.breathRetryAt = os.clock() + AutoSkillSystem.breathRetryDelay
            AutoSkillSystem.breathRetryPending = true
        end
    elseif breath and breath >= AutoSkillSystem.breathThreshold
        and AutoSkillSystem.breathPreparing then
        -- A barra pode se recuperar sozinha enquanto a animação termina.
        AutoSkillSystem.breathPreparing = false
        AutoSkillSystem.breathPrepareStartedAt = 0
    elseif breath
        and (breath < AutoSkillSystem.breathThreshold
            or AutoSkillSystem.breathRetryPending)
        and os.clock() >= (AutoSkillSystem.breathRetryAt or 0) then
        if not AutoSkillSystem.breathPreparing then
            AutoSkillSystem.breathPreparing = true
            AutoSkillSystem.breathPrepareStartedAt = os.clock()
            if AutoSkillSystem.breathRetryPending then
                print("[MoonDF AutoBreath] nova tentativa de respiração; aguardando 2s")
            else
                print("[MoonDF AutoBreath] respiração abaixo de 40%; aguardando 2s")
            end
        end

        -- Primeiro deixa a forma/ataque atual terminar. Pressionar G durante
        -- uma forma ativa é ignorado pelo jogo.
        local preparingFor = os.clock() - AutoSkillSystem.breathPrepareStartedAt
        if not AutoSkillSystem.isActionBusy()
            and preparingFor >= AutoSkillSystem.breathPrepareDelay then
            AutoSkillSystem.breathHolding = true
            AutoSkillSystem.breathStartedAt = os.clock()
            AutoSkillSystem.breathRetryPending = false
            pcall(function()
                print("[MoonDF AutoBreath] pressionando G | respiração: " .. tostring(breath))
                VIM:SendKeyEvent(true, Enum.KeyCode.G, false, game)
            end)
        end
    end
end

AutoSkillSystem.pressSkill = function(key)
    local keyCode = AutoSkillSystem.keyMap[key]
    if not keyCode then return end
    pcall(function()
        VIM:SendKeyEvent(true, keyCode, false, game)
        task.wait(0.04)
        VIM:SendKeyEvent(false, keyCode, false, game)
    end)
end

AutoSkillSystem.hasWork = function()
    if AutoSkillSystem.autoBreath then return true end
    for _, enabled in pairs(AutoSkillSystem.enabled) do
        if enabled then return true end
    end
    return false
end

AutoSkillSystem.startLoop = function()
    if AutoSkillSystem.loopRunning then return end
    AutoSkillSystem.loopRunning = true
    task.spawn(function()
        while AutoSkillSystem.loopRunning and AutoSkillSystem.hasWork() do
            for key, enabled in pairs(AutoSkillSystem.enabled) do
                if enabled
                    and not AutoSkillSystem.breathPreparing
                    and not AutoSkillSystem.breathHolding
                    and not AutoSkillSystem.isActionBusy()
                    and not AutoSkillSystem.isSkillOnCooldown(key)
                    and os.clock() >= (AutoSkillSystem.nextUse[key] or 0)
                then
                    AutoSkillSystem.pressSkill(key)
                    AutoSkillSystem.nextUse[key] = os.clock() + AutoSkillSystem.skillInterval
                end
            end
            task.wait(0.08)
        end
        AutoSkillSystem.releaseBreath()
        AutoSkillSystem.loopRunning = false
    end)
end

AutoSkillSystem.startBreathMonitor = function()
    if AutoSkillSystem.breathMonitorRunning then return end
    AutoSkillSystem.breathMonitorRunning = true
    task.spawn(function()
        while AutoSkillSystem.breathMonitorRunning and AutoSkillSystem.autoBreath do
            local ok, err = pcall(AutoSkillSystem.updateBreath)
            if not ok then
                warn("[MoonDF AutoBreath] erro no monitor: " .. tostring(err))
            end
            task.wait(0.1)
        end
        AutoSkillSystem.breathMonitorRunning = false
    end)
end

AutoSkillSystem.toggleSkill = function(key, state)
    AutoSkillSystem.enabled[key] = state == true
    if state then AutoSkillSystem.startLoop() end
end

AutoSkillSystem.toggleBreath = function(state)
    AutoSkillSystem.autoBreath = state == true
    if state then
        AutoSkillSystem.breathRetryAt = 0
        AutoSkillSystem.startBreathMonitor()
        AutoSkillSystem.startLoop()
    else
        AutoSkillSystem.releaseBreath()
        AutoSkillSystem.breathRetryAt = 0
        AutoSkillSystem.breathRetryPending = false
        AutoSkillSystem.breathMonitorRunning = false
    end
end

globalEnv.clickTPToggle = globalEnv.clickTPToggle or false
local clickTPToggle = globalEnv.clickTPToggle
local clickTPConn = nil
local hubInteracting = false
local isPointerOverHub
globalEnv.noclipToggle = globalEnv.noclipToggle or false
local noclipToggle = globalEnv.noclipToggle
local noclipConn = nil
local noclipOriginalCollision = {}
globalEnv.spectateToggle = globalEnv.spectateToggle or false
local spectateToggle = globalEnv.spectateToggle
local spectatePlayer = nil
local spectateConn = nil
local originalCFrame = nil
globalEnv.spectateHeight = globalEnv.spectateHeight or 20
local spectateHeight = globalEnv.spectateHeight
globalEnv.spectateDistance = globalEnv.spectateDistance or 12
local spectateDistance = globalEnv.spectateDistance
local cameraAngleX = 0
local cameraAngleY = 15
local isMouseDownSpec = false
local lastMousePosSpec = nil
local shiftLockMode = false
local spectateInputBegan, spectateInputEnded, spectateInputChanged = nil, nil, nil

globalEnv.espEnabled = globalEnv.espEnabled or false
local espEnabled = globalEnv.espEnabled
local espUpdateLoop = nil
local ABSOLUTE_MAX_HP = 280
local maxHealthCache = {}
local playerSpawnTime = {}
local espFolder = Instance.new("Folder")
espFolder.Name = "MoonDF_ESPFolder"
pcall(function() espFolder.Parent = CoreGui end)
if not espFolder.Parent then
    pcall(function() espFolder.Parent = player:WaitForChild("PlayerGui") end)
end

globalEnv.infiniteJump = globalEnv.infiniteJump or false
local infiniteJump = globalEnv.infiniteJump
local infJumpConn, infJumpRequestConn = nil, nil

globalEnv.infiniteStamina = globalEnv.infiniteStamina or false
local infiniteStamina = globalEnv.infiniteStamina
globalEnv.antiCombat = globalEnv.antiCombat or false
local antiCombat = globalEnv.antiCombat
local staminaCombatConn = nil
local antiCombatCharacterConn = nil
local antiCombatGuiConn = nil
local COMBAT_TAGS = { Combat = true, Aggro = true, Busy = true, Stun = true, Down = true, Ragdoll = true }
local STAMINA_TAGS = { Stamina = true }

local blockedStates = {
    Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.Freefall, Enum.HumanoidStateType.GettingUp,
    Enum.HumanoidStateType.Seated, Enum.HumanoidStateType.PlatformStanding, Enum.HumanoidStateType.Dead, Enum.HumanoidStateType.Physics,
}

local FARM = { "GenericSlayer", "GenericOni", "FrostyOni", "Green Demon", "Blue Demon", "Zenitsu", "Gyutaro", "Kaigaku" }

local LOCATIONS = {
    Raid = CFrame.new(7099.3, 1762.3, 1342.9),
    Hayakawa = CFrame.new(-3571.8, 714.1, -994.5),
    Okuya = CFrame.new(893.3, 772.6, -2260.9),
    Kamakura = CFrame.new(-2343.6, 1166.6, -1678.2),
    Slayer = CFrame.new(-5433.1, 761.0, -6392.9),
    Distrito = CFrame.new(-1986.7, 871.8, -6484.5),
    SlayerExam = CFrame.new(-5123, 815, -3037),
    Castelo1 = CFrame.new(-9986.8, 6898.9, -4678.2),
    Castelo2 = CFrame.new(3433.3, 3732.3, 1879.8),
    Castelo3 = CFrame.new(3396.3, 4010.6, 1768.6)
}

local EVENT_LOCATIONS = {
    Raid = LOCATIONS.Raid,
    Douma = CFrame.new(3358.5, 3738.2, 1673.3),
    Akaza = CFrame.new(3440.8, 3735.8, 1855.5),
    Kokushibo = CFrame.new(3458.0, 4022.0, 1618.1),
    SlayerCastle = CFrame.new(-10065.0, 6907.6, -4570.1),
    SoupVendor = CFrame.new(-3695.3, 709.9, -1272.5),
    MeatVendor = CFrame.new(-3414.2, 706.4, -1579.0),
    JewelVendor = CFrame.new(-3635.1, 707.9, -1473.6),
    NichirinHornVendor = CFrame.new(-1419.5, 874.1, -6309.4)
}

local BREATHS = {
    Mist = CFrame.new(3237, 778.8, -4051.3),
    Serpent = CFrame.new(991.8, 1071.3, -1144.8),
    Love = CFrame.new(1192.8, 1079.3, -1107.6),
    Flame = CFrame.new(1493, 1245, -354),
    Moon = CFrame.new(1820, 1121, -5958),
    Wind = CFrame.new(-3294, 708, -1267),
    Thunder = CFrame.new(-750, 705, 552),
    Insect = CFrame.new(-1635, 913, -6493),
    Sound = CFrame.new(-1266, 877.9, -6432.9),
    Flower = CFrame.new(-1320, 872.5, -6237),
    Beast = CFrame.new(-3112, 785, -6596),
    Water = CFrame.new(-925, 851.5, -994.6),
    Sun = CFrame.new(393, 819.7, -421)
}

local LOAD_COORDINATES = {
    Vector3.new(-3398.0, 722.4, -1128.5),
    Vector3.new(-2740.9, 737.8, -3378.0),
    Vector3.new(-4571.8, 776.6, -6140.8),
    Vector3.new(-6456.1, 815.1, -6298.2),
    Vector3.new(-1944.1, 874.4, -2510.4),
    Vector3.new(1634.1, 1190.1, -1446.3),
    Vector3.new(1406.2, 769.3, -6549.3),
    Vector3.new(893.3, 772.6, -2260.9),
}

local ORE_LOAD_COORDS = {
    Vector3.new(-3627.3, 1310.7, -2810.3),
    Vector3.new(-2065.2, 846.2, -3978.5),
    Vector3.new(-3891.5, 817.8, 1027.7),
    Vector3.new(-1977.2, 845.9, -2708.2),
}
globalEnv.oreAreasLoaded = globalEnv.oreAreasLoaded or false
local oreAreasLoaded = globalEnv.oreAreasLoaded

local function isInBlockedState(h)
    if not h then return true end
    if h.PlatformStand == true then return true end
    for _, v in ipairs(blockedStates) do if h:GetState() == v then return true end end
    return false
end

-- Procura o menor ping anunciado pela API pública de servidores do Roblox.
-- O endpoint pode ser acessado por executores via game:HttpGet ou request().
local serverHopBusy = false
local SERVER_HOP_MAX_PAGES = 5

local function requestServerList(url)
    local body
    local ok = pcall(function()
        local requestFn

        if syn and typeof(syn.request) == "function" then
            requestFn = syn.request
        elseif typeof(http_request) == "function" then
            requestFn = http_request
        elseif typeof(request) == "function" then
            requestFn = request
        elseif fluxus and typeof(fluxus.request) == "function" then
            requestFn = fluxus.request
        end

        if requestFn then
            local response = requestFn({
                Url = url,
                Method = "GET",
            })
            body = response and (response.Body or response.body)
        else
            body = game:HttpGet(url)
        end
    end)

    return ok and body or nil
end

local function findLowestPingServer()
    local bestServer
    local cursor

    for _ = 1, SERVER_HOP_MAX_PAGES do
        local url = string.format(
            "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s",
            game.PlaceId,
            cursor and ("&cursor=" .. HttpService:UrlEncode(cursor)) or ""
        )
        local body = requestServerList(url)
        if not body then break end

        local decoded
        local decodedOk = pcall(function()
            decoded = HttpService:JSONDecode(body)
        end)
        if not decodedOk or type(decoded) ~= "table" then break end

        for _, server in ipairs(decoded.data or {}) do
            local ping = tonumber(server.ping)
            local playing = tonumber(server.playing)
            local maxPlayers = tonumber(server.maxPlayers)
            local isAvailable = not maxPlayers or not playing or playing < maxPlayers

            if server.id
                and server.id ~= game.JobId
                and ping
                and ping > 0
                and isAvailable
                and (not bestServer or ping < bestServer.ping)
            then
                bestServer = {
                    id = server.id,
                    ping = ping,
                }
            end
        end

        cursor = decoded.nextPageCursor
        if not cursor then break end
    end

    return bestServer
end

function serverHopLowestPing()
    if serverHopBusy then return end
    serverHopBusy = true
    notifyDev(T("SERVER_HOP_SEARCHING"))

    task.spawn(function()
        local server = findLowestPingServer()
        if server then
            notifyDev(string.format(T("SERVER_HOP_FOUND"), math.floor(server.ping)))
            local ok, err = pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, player)
            end)
            if not ok then
                warn("[MOONDF][SERVER HOP] Falha no teleporte:", err)
                notifyDev(T("SERVER_HOP_FAIL"))
            end
        else
            warn("[MOONDF][SERVER HOP] Nenhum servidor com ping disponível foi encontrado.")
            notifyDev(T("SERVER_HOP_FAIL"))
        end
        serverHopBusy = false
    end)
end

local function calculateFlySpeed(sliderVal)
    if sliderVal <= 5000 then return (sliderVal / 5000) * 400
    else local excess = sliderVal - 5000 return 400 + (excess * 2) end
end

function setupFly()
    if not root then return end
    if bg then bg:Destroy() end
    if bv then bv:Destroy() end
    bg = Instance.new("BodyGyro", root)
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.P = 9e4
    bg.CFrame = root.CFrame
    bv = Instance.new("BodyVelocity", root)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.new(0,0,0)
    humanoid.PlatformStand = true

    if flyConn then flyConn:Disconnect() end

    local function getMoveInputs(cam)
        local forward = 0
        local right = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then forward = forward + 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then forward = forward - 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then right = right + 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then right = right - 1 end

        if math.abs(forward) < 1e-6 and math.abs(right) < 1e-6 then
            local md = (humanoid and humanoid.MoveDirection) or Vector3.new(0,0,0)
            if md and md.Magnitude > 0.01 and cam then
                forward = md:Dot(cam.CFrame.LookVector)
                right = md:Dot(cam.CFrame.RightVector)
            end
        end

        return forward, right
    end

    flyConn = RunService.Heartbeat:Connect(function()
        if not flyToggle or not root then return end
        local cam = workspace.CurrentCamera
        if not cam then return end

        local currentSpeed = calculateFlySpeed(flySpeedValue)

        local vertical = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vertical = vertical + currentSpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.C) then vertical = vertical - currentSpeed end

        local fComp, rComp = getMoveInputs(cam)

        local moveVec = Vector3.new(0,0,0)
        if math.abs(fComp) > 1e-6 or math.abs(rComp) > 1e-6 then
            moveVec = (cam.CFrame.LookVector * fComp) + (cam.CFrame.RightVector * rComp)
            if moveVec.Magnitude > 0.001 then
                moveVec = moveVec.Unit * currentSpeed
            else
                moveVec = Vector3.new(0,0,0)
            end
        else
            moveVec = Vector3.new(0,0,0)
        end

        bv.Velocity = moveVec + Vector3.new(0, vertical, 0)

        if cam.CFrame.LookVector then
            bg.CFrame = CFrame.new(root.Position, root.Position + cam.CFrame.LookVector)
        end
    end)
end

function setupOreFly()
    if not root then return end
    if bg then bg:Destroy() end
    if bv then bv:Destroy() end
    bg = Instance.new("BodyGyro", root)
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.P = 9e4
    bg.CFrame = root.CFrame
    bv = Instance.new("BodyVelocity", root)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.new(0, 0, 0)
    humanoid.PlatformStand = true

    if flyConn then flyConn:Disconnect() end

    flyConn = RunService.Heartbeat:Connect(function()
        if not oreFarm or not root then return end
        bg.CFrame = root.CFrame
        bv.Velocity = Vector3.new(0, 0, 0)
    end)
end

function toggleNoclip(state)
    local wasEnabled = noclipToggle
    noclipToggle = state
    globalEnv.noclipToggle = state
    if state then
        if not wasEnabled then
            noclipOriginalCollision = {}
        end
        if noclipConn then noclipConn:Disconnect() end
        noclipConn = RunService.Stepped:Connect(function()
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if noclipOriginalCollision[part] == nil then
                            noclipOriginalCollision[part] = part.CanCollide
                        end
                        if part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() end
        for part, originalCanCollide in pairs(noclipOriginalCollision) do
            if part and part.Parent then
                pcall(function()
                    part.CanCollide = originalCanCollide
                end)
            end
        end
        noclipOriginalCollision = {}
    end
end

function toggleClickTP(state)
    clickTPToggle = state
    globalEnv.clickTPToggle = state
    if clickTPConn then
        clickTPConn:Disconnect()
        clickTPConn = nil
    end
    if not state then return end

    clickTPConn = UserInputService.InputBegan:Connect(function(input, gp)
        if not clickTPToggle then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        if hubInteracting or (typeof(isPointerOverHub) == "function" and isPointerOverHub()) then
            return
        end

        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            hrp = root
        end
        if not hrp then return end

        local cam = workspace.CurrentCamera
        if not cam then return end
        local mousePos = UserInputService:GetMouseLocation()
        local ray = cam:ViewportPointToRay(mousePos.X, mousePos.Y)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { char }
        params.IgnoreWater = true

        local result = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
        local targetPos
        if result then
            targetPos = result.Position + Vector3.new(0, 3, 0)
        else
            local ok, hit = pcall(function()
                local m = player:GetMouse()
                return m and m.Hit and m.Hit.Position
            end)
            if ok and hit then
                targetPos = hit + Vector3.new(0, 3, 0)
            else
                targetPos = ray.Origin + ray.Direction * 100
            end
        end

        pcall(function()
            hrp.CFrame = CFrame.new(targetPos)
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            if hrp:IsA("BasePart") then
                pcall(function() hrp.Velocity = Vector3.new(0, 0, 0) end)
            end
        end)
        root = hrp
    end)
end

function applyNoFog(state)
    noFogEnabled = state
    globalEnv.noFogEnabled = state
    if state then
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        Lighting.GlobalShadows = false
        Lighting.Brightness = 2
        for _, v in pairs(Lighting:GetChildren()) do if v:IsA("Atmosphere") then v.Density = 0 end end
    else
        Lighting.FogEnd = 500
        Lighting.GlobalShadows = true
    end
end

function toggleUltraLite(state)
    ultraLiteEnabled = state
    globalEnv.ultraLiteEnabled = state
    if state then
        pcall(function() settings().Rendering.QualityLevel = 1 end)
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        if liteLoop then liteLoop:Disconnect() end
        liteLoop = RunService.RenderStepped:Connect(function()
            Lighting.FogEnd = 9e9
            Lighting.GlobalShadows = false
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then v.Enabled = false end
            end
        end)
    else
        if liteLoop then liteLoop:Disconnect() end
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 500
    end
end

-- Cache + throttle: evita GetDescendants a cada RenderStepped quando o mob morreu
-- (causa principal de freeze ao farmar alvos inexistentes).
local enemyCache = { name = nil, model = nil, lastScan = 0, interval = 0.75 }

local function modelHasZeroHP(model)
    if not model or not model.Parent then return false end
    if model:FindFirstChild("Dead") or model:FindFirstChild("Executed") then return true end
    local hpVal = model:FindFirstChild("Health")
    if hpVal and hpVal:IsA("ValueBase") and tonumber(hpVal.Value) <= 0 then
        return true
    end
    local hum = model:FindFirstChildOfClass("Humanoid")
    return hum ~= nil and hum.Health <= 0
end

function isValidEnemyModel(model)
    if not model or not model.Parent then return false end
    if not model:IsA("Model") then return false end
    if not model:FindFirstChildOfClass("Humanoid") then return false end
    local modelRoot = model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("Torso")
        or model:FindFirstChild("Head")
    return modelRoot ~= nil and not modelHasZeroHP(model)
end

-- Procura apenas nos containers onde personagens/mobs costumam ficar.
-- Evita GetDescendants no RenderStepped, que travava quando o alvo não existia.
local function forEachPotentialEnemyModel(callback)
    local seen = {}
    local function visit(instance)
        if instance:IsA("Model") and not seen[instance] then
            seen[instance] = true
            callback(instance)
        end
    end

    for _, child in ipairs(workspace:GetChildren()) do
        visit(child)
        if child:IsA("Folder") or child:IsA("Model") then
            local name = string.lower(tostring(child.Name or ""))
            local likelyContainer = string.find(name, "live", 1, true)
                or string.find(name, "npc", 1, true)
                or string.find(name, "mob", 1, true)
                or string.find(name, "enemy", 1, true)
                or string.find(name, "character", 1, true)
            if likelyContainer then
                for _, nested in ipairs(child:GetChildren()) do
                    visit(nested)
                end
            end
        end
    end
end

function findEnemy(mobName)
    if not mobName or mobName == "" then return nil end

    -- Fast path: cache ainda válido
    if enemyCache.name == mobName and isValidEnemyModel(enemyCache.model) then
        return enemyCache.model
    end

    -- Farm de mob comum precisa continuar no alvo morto para conseguir
    -- aproximar e enviar B. Farms de raid/player não usam esse caminho.
    if farmCanFinalize
        and enemyCache.name == mobName
        and enemyCache.model
        and enemyCache.model.Parent
        and modelHasZeroHP(enemyCache.model) then
        return enemyCache.model
    end

    -- Player (barato)
    local targetPlayer = Players:FindFirstChild(mobName)
    if targetPlayer and targetPlayer.Character and isValidEnemyModel(targetPlayer.Character) then
        enemyCache.name = mobName
        enemyCache.model = targetPlayer.Character
        return targetPlayer.Character
    end

    -- Filho direto do workspace (barato)
    local direct = workspace:FindFirstChild(mobName)
    if direct and isValidEnemyModel(direct) then
        enemyCache.name = mobName
        enemyCache.model = direct
        return direct
    end

    -- Scan leve e throttled — não percorre a árvore inteira quando não há mob
    local now = os.clock()
    if (now - (enemyCache.lastScan or 0)) < (enemyCache.interval or 0.40) then
        return nil
    end
    enemyCache.lastScan = now

    local found = nil
    forEachPotentialEnemyModel(function(descendant)
        if not found and descendant.Name == mobName and isValidEnemyModel(descendant) then
            found = descendant
        end
    end)
    enemyCache.name = mobName
    enemyCache.model = found
    return found
end

local FS = {
    safeDist = 28,
    ragdollWait = 0.55,
    lungeCd = 1.0,
    lungeRunHold = 0.51,
    lungeExtraDelay = 0.20,
    stunRecoilHold = 1.5,
    stunHoldUntil = 0,
    returnLungePending = false,
    execInterval = 5,
    execLockTime = 60,
    wasRagdoll = false,
    ragdollSince = 0,
    lastLunge = 0,
    lastExec = 0,
    lunging = false,
    didLunge = false,
    playerStunned = false,
    curDist = nil,
    execUntil = 0,
    execTarget = nil,
    predLeadMin = 0.12,
    predLeadMax = 0.55,
}

FS.isDemon = function()
    local char = player and player.Character
    if not char then return false end
    local race = ""
    local ok, r = pcall(function() return char:GetAttribute("Race") end)
    if ok and r then race = tostring(r) end
    if race == "" then
        if char:FindFirstChild("Demon") then race = "Demon"
        elseif char:FindFirstChild("Demon Slayer") then race = "Demon Slayer" end
    end
    race = string.lower(race)
    if race == "" or string.find(race, "slayer", 1, true) then return false end
    return string.find(race, "demon", 1, true) ~= nil
end

FS.zeroHP = function(enemy)
    if not enemy or not enemy.Parent then return false end
    if enemy:FindFirstChild("Dead") or enemy:FindFirstChild("Executed") then return true end
    local hpVal = enemy:FindFirstChild("Health")
    if hpVal and hpVal:IsA("ValueBase") and tonumber(hpVal.Value) <= 0 then return true end
    local hum = enemy:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 then return true end
    return false
end

-- Alvos permitidos exclusivamente pelo "Farm Raid Geral":
-- Enemy, Rengoku, Shinobu, Yoriichi e Kokushibo.
-- Não reutilizar FARM aqui: a lista comum contém mobs que não devem
-- ser selecionados pelo botão de raid geral.
local raidEnemyNames = {
    ["enemy"] = true,
}

local raidFarmNames = {
    [string.lower(RAID_GENERAL_TARGET)] = true,
    ["enemy"] = true,
    ["kokushiboraid"] = true,
    ["rengokuraid"] = true,
    ["shinoburaid"] = true,
    ["shinouburaid"] = true,
    ["yoriichi"] = true,
    ["yoriichiraid"] = true,
}

local function isRaidFarmName(name)
    return raidFarmNames[string.lower(tostring(name or ""))] == true
end

local function isRaidBossModel(model)
    if not model or not model.Parent then return false end
    local name = string.lower(tostring(model.Name or ""))
    return string.find(name, "rengoku", 1, true) ~= nil
        or string.find(name, "shinobu", 1, true) ~= nil
        or string.find(name, "shinoubu", 1, true) ~= nil
        or string.find(name, "kokushibo", 1, true) ~= nil
        or string.find(name, "yoriichi", 1, true) ~= nil
end

local function isRaidEnemyModel(model)
    if not model or not model.Parent then return false end
    local name = string.lower(tostring(model.Name or ""))
    if raidEnemyNames[name] then return true end
    return name:match("^enemy[%s_%-]?%d*$") ~= nil
end

local function raidModelDistance(model)
    local modelRoot = model and (model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("Torso")
        or model:FindFirstChild("Head"))
    if not modelRoot or not root then return math.huge end
    return (modelRoot.Position - root.Position).Magnitude
end

local function collectRaidTargets()
    local bosses, enemies = {}, {}
    forEachPotentialEnemyModel(function(model)
        if model:IsA("Model")
            and model ~= character
            and not Players:GetPlayerFromCharacter(model)
            and isValidEnemyModel(model)
            and not FS.zeroHP(model) then
            if isRaidBossModel(model) then
                table.insert(bosses, model)
            elseif isRaidEnemyModel(model) then
                table.insert(enemies, model)
            end
        end
    end)

    local byDistance = function(a, b)
        return raidModelDistance(a) < raidModelDistance(b)
    end
    table.sort(bosses, byDistance)
    table.sort(enemies, byDistance)
    return bosses, enemies
end

local function selectRaidFarmTarget()
    local current = raidFarmTarget
    local currentAlive = isValidEnemyModel(current) and not FS.zeroHP(current)
    local now = os.clock()

    -- Um alvo morto força uma nova varredura imediatamente; não espera o throttle.
    local forceScan = current ~= nil and not currentAlive
    if not forceScan and (now - (raidFarmLastScan or 0)) < raidFarmScanInterval then
        return current
    end

    local bosses, enemies = collectRaidTargets()
    raidFarmLastScan = now
    local nextTarget = nil

    -- Boss sempre tem prioridade, mesmo que o alvo atual seja um enemy normal.
    if #bosses > 0 then
        if currentAlive and isRaidBossModel(current) then
            nextTarget = current
        else
            nextTarget = bosses[1]
        end
    elseif currentAlive and isRaidEnemyModel(current) then
        nextTarget = current
    else
        nextTarget = enemies[1]
    end

    if nextTarget ~= raidFarmTarget then
        raidFarmTarget = nextTarget
        -- Estado abaixo é específico do alvo anterior e não pode bloquear o novo.
        FS.wasRagdoll = false
        FS.didLunge = false
        FS.execTarget = nil
        FS.execUntil = 0
    end
    return raidFarmTarget
end

-- Farm específico do Castelo Infinito:
-- usa somente GenericOni como fallback e Akaza/Doma/Kokushibo como bosses.
-- Depois que um boss é encontrado, o farm não volta para GenericOni:
-- fica aguardando outro boss aparecer.
local castleBossNames = {
    ["akaza"] = true,
    ["doma"] = true,
    ["kokushibo"] = true,
}

local castleEnemyNames = {
    ["genericoni"] = true,
}

local function isCastleBossModel(model)
    if not model or not model.Parent then return false end
    return castleBossNames[string.lower(tostring(model.Name or ""))] == true
end

local function isCastleEnemyModel(model)
    if not model or not model.Parent then return false end
    return castleEnemyNames[string.lower(tostring(model.Name or ""))] == true
end

local function collectCastleTargets()
    local bosses, enemies = {}, {}
    forEachPotentialEnemyModel(function(model)
        if model:IsA("Model")
            and model ~= character
            and not Players:GetPlayerFromCharacter(model)
            and isValidEnemyModel(model)
            and not FS.zeroHP(model) then
            if isCastleBossModel(model) then
                table.insert(bosses, model)
            elseif isCastleEnemyModel(model) then
                table.insert(enemies, model)
            end
        end
    end)

    local byDistance = function(a, b)
        return raidModelDistance(a) < raidModelDistance(b)
    end
    table.sort(bosses, byDistance)
    table.sort(enemies, byDistance)
    return bosses, enemies
end

local function selectCastleFarmTarget()
    local current = castleFarmTarget
    local currentAlive = isValidEnemyModel(current) and not FS.zeroHP(current)
    local now = os.clock()
    local forceScan = current ~= nil and not currentAlive

    if not forceScan and (now - (castleFarmLastScan or 0)) < raidFarmScanInterval then
        return current
    end

    local bosses, enemies = collectCastleTargets()
    castleFarmLastScan = now
    local nextTarget = nil

    if #bosses > 0 then
        castleBossEngaged = true
        if currentAlive and isCastleBossModel(current) then
            nextTarget = current
        else
            nextTarget = bosses[1]
        end
    elseif castleBossEngaged then
        -- Um boss já foi encontrado; aguarda somente outro boss.
        nextTarget = nil
    elseif currentAlive and isCastleEnemyModel(current) then
        nextTarget = current
    else
        nextTarget = enemies[1]
    end

    if nextTarget ~= castleFarmTarget then
        castleFarmTarget = nextTarget
        FS.wasRagdoll = false
        FS.didLunge = false
        FS.execTarget = nil
        FS.execUntil = 0
    end
    return castleFarmTarget
end

FS.ragdolled = function(enemy)
    if not enemy or not enemy.Parent then return false end
    if enemy:FindFirstChild("Ragdoll") then return true end
    local hum = enemy:FindFirstChildOfClass("Humanoid")
    return hum ~= nil and hum.PlatformStand == true
end

FS.iAmStunned = function()
    local char = player and player.Character
    if not char then return false end
    if char:FindFirstChild("Stun") or char:FindFirstChild("Ragdoll") then return true end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum ~= nil and hum.PlatformStand == true
end

FS.execLocked = function(enemy)
    return enemy and tick() < FS.execUntil and FS.execTarget == enemy
end

FS.markExec = function(enemy)
    if not enemy then return end
    FS.execTarget = enemy
    FS.execUntil = tick() + FS.execLockTime
end

FS.predictPlayerPos = function(enemy)
    if not enemy then return nil end
    local plr = Players:GetPlayerFromCharacter(enemy)
    if not plr then return nil end
    local eRoot = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Torso")
    if not eRoot then return nil end
    local hum = enemy:FindFirstChildOfClass("Humanoid")
    local vel = Vector3.zero
    pcall(function()
        vel = eRoot.AssemblyLinearVelocity or eRoot.Velocity or Vector3.zero
    end)
    local flat = Vector3.new(vel.X, 0, vel.Z)
    local speed = flat.Magnitude
    if speed < 10 then return nil end
    local t = FS.predLeadMin + (math.clamp(speed, 10, 40) - 10) / 30 * (FS.predLeadMax - FS.predLeadMin)
    local pred = eRoot.Position + flat.Unit * (speed * t)
    if hum then
        local md = hum.MoveDirection
        if md and md.Magnitude > 0.2 then
            local mdFlat = Vector3.new(md.X, 0, md.Z)
            if mdFlat.Magnitude > 0.1 then
                pred = eRoot.Position + mdFlat.Unit * (speed * t)
            end
        end
    end
    return pred
end

AutoSkillSystem.targetFormActiveUntil = setmetatable({}, {__mode = "k"})
AutoSkillSystem.targetFormDistance = 150

function targetIsUsingForm(target)
    if not target or not target.Parent then return false end

    local hasForm = false
    for _, child in ipairs(target:GetChildren()) do
        local name = tostring(child.Name or "")
        local lower = string.lower(name)

        if string.sub(name, 1, 8) == "Activate" then
            local utility = string.find(lower, "crow", 1, true)
                or string.find(lower, "dash", 1, true)
                or string.find(lower, "scar", 1, true)
                or string.find(lower, "meditat", 1, true)
                or string.find(lower, "utility", 1, true)
                or string.find(lower, "emote", 1, true)
                or string.find(lower, "item", 1, true)
            if not utility and not string.find(lower, "lunge", 1, true) then
                hasForm = true
                break
            end
        elseif name == "ItemCooldown" then
            local targetName = ""
            pcall(function()
                if child:IsA("ObjectValue") and child.Value then
                    targetName = tostring(child.Value.Name or child.Value)
                elseif child:IsA("StringValue") then
                    targetName = tostring(child.Value)
                end
            end)
            local utility = targetName == ""
                or string.find(string.lower(targetName), "crow", 1, true)
                or string.find(string.lower(targetName), "dash", 1, true)
                or string.find(string.lower(targetName), "scar", 1, true)
                or string.find(string.lower(targetName), "meditat", 1, true)
                or string.find(string.lower(targetName), "utility", 1, true)
                or string.find(string.lower(targetName), "emote", 1, true)
                or string.find(string.lower(targetName), "lunge", 1, true)
            if not utility then
                hasForm = true
                break
            end
        end
    end

    local now = os.clock()
    if hasForm then
        -- Pequeno buffer para o objeto desaparecer sem deixar o farm colado
        -- no alvo no mesmo frame em que a forma termina.
        AutoSkillSystem.targetFormActiveUntil[target] = now + 0.45
        return true
    end
    if (AutoSkillSystem.targetFormActiveUntil[target] or 0) > now then
        return true
    end
    AutoSkillSystem.targetFormActiveUntil[target] = nil
    return false
end

-- Estabilizador de câmera durante farm (tabela única = 1 registrador local).
FarmCam = FarmCam or {
    active = false,
    locked = false, -- Scriptable só após achar o primeiro mob válido
    savedType = nil,
    savedSubject = nil,
}
function FarmCam.start()
    -- NÃO trava a câmera aqui. Apenas marca intenção de farm.
    -- A câmera só vira Scriptable quando FarmCam.update receber um focus real.
    if not FarmCam.active then
        FarmCam.active = true
        FarmCam.locked = false
        FarmCam.savedType = nil
        FarmCam.savedSubject = nil
    end
end
function FarmCam.stop()
    local cam = workspace.CurrentCamera
    if cam and FarmCam.locked then
        pcall(function()
            cam.CameraType = FarmCam.savedType or Enum.CameraType.Custom
            if FarmCam.savedSubject and FarmCam.savedSubject.Parent then
                cam.CameraSubject = FarmCam.savedSubject
            elseif humanoid and humanoid.Parent then
                cam.CameraSubject = humanoid
            else
                local char = player and player.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then cam.CameraSubject = hum end
            end
        end)
    end
    FarmCam.active = false
    FarmCam.locked = false
    FarmCam.savedType = nil
    FarmCam.savedSubject = nil
end
function FarmCam.unlockIfIdle()
    -- Restaura câmera se farm está ativo mas nenhum mob foi encontrado (evita freeze no canto)
    if not FarmCam.active or not FarmCam.locked then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    pcall(function()
        cam.CameraType = FarmCam.savedType or Enum.CameraType.Custom
        if FarmCam.savedSubject and FarmCam.savedSubject.Parent then
            cam.CameraSubject = FarmCam.savedSubject
        elseif humanoid and humanoid.Parent then
            cam.CameraSubject = humanoid
        end
    end)
    FarmCam.locked = false
    FarmCam.savedType = nil
    FarmCam.savedSubject = nil
end
function FarmCam.update(focusPos)
    if not FarmCam.active or not root or not root.Parent then return end
    if not focusPos then
        FarmCam.unlockIfIdle()
        return
    end
    local cam = workspace.CurrentCamera
    if not cam then return end
    -- Primeiro frame com mob válido: salva estado e trava Scriptable
    if not FarmCam.locked then
        FarmCam.savedType = cam.CameraType
        FarmCam.savedSubject = cam.CameraSubject
        FarmCam.locked = true
        cam.CameraType = Enum.CameraType.Scriptable
    end
    local focus = focusPos
    local back = root.Position - focus
    local flat = Vector3.new(back.X, 0, back.Z)
    if flat.Magnitude < 0.15 then
        flat = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
        if flat.Magnitude < 0.15 then flat = Vector3.new(0, 0, 1) end
    end
    flat = flat.Unit
    local camPos = root.Position + flat * 11 + Vector3.new(0, 7, 0)
    cam.CFrame = CFrame.new(camPos, focus + Vector3.new(0, 1.5, 0))
end

function teleportAndLook()
    local enemy = (castleFarmActive and selectCastleFarmTarget())
        or (raidFarmActive and selectRaidFarmTarget())
        or (currentMob and findEnemy(currentMob))
    local currentCharacter = player and player.Character
    local currentRoot = currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart")
    if currentCharacter and currentRoot then
        character = currentCharacter
        root = currentRoot
        humanoid = currentCharacter:FindFirstChildOfClass("Humanoid") or humanoid
    end
    -- Sem inimigo: NÃO teleporta, NÃO trava câmera, libera Scriptable se estava preso
    if not enemy or not root or not root.Parent then
        FarmCam.unlockIfIdle()
        return false
    end
    local enemyRoot = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Torso")
    if not enemyRoot then
        local success, pivot = pcall(function() return enemy:GetPivot() end)
        if success and pivot then enemyRoot = { Position = pivot.Position, CFrame = pivot } end
        if not enemyRoot then
            FarmCam.unlockIfIdle()
            return false
        end
    end

    if FS.execTarget and FS.execTarget ~= enemy then
        FS.execTarget = nil
        FS.execUntil = 0
    end

    local currentDistance = FS.curDist or FARM_DISTANCE
    local isExecuting = enemy:FindFirstChild("Executing") or enemy:FindFirstChild("Execute")
    local isZeroHP = FS.zeroHP(enemy)
    local realPlayerHealth = select(1, readFarmHealth())
    local localPlayerDead = (realPlayerHealth ~= nil and realPlayerHealth <= 0)
    if not localPlayerDead then
        localPlayerDead = not humanoid or humanoid.Health <= 0
    end
    local enemyUsingForm = targetIsUsingForm(enemy)

    if localPlayerDead then
        -- Anti Execute ligado mantém o personagem afastado após morrer.
        -- Desligado força a aproximação para o personagem poder morrer.
        if antiExecute then
            currentDistance = math.max(
                PLAYER_EXECUTE_DISTANCE,
                tonumber(EXECUTE_DISTANCE) or PLAYER_EXECUTE_DISTANCE
            )
        else
            currentDistance = 1
        end
    elseif isZeroHP and not isExecuting then
        currentDistance = 1
    elseif isExecuting then
        if Players:GetPlayerFromCharacter(enemy) then
            currentDistance = PLAYER_EXECUTE_DISTANCE
        else
            currentDistance = math.max(0, tonumber(EXECUTE_DISTANCE) or 1)
        end
    end
    if enemyUsingForm and not (localPlayerDead and not antiExecute) then
        currentDistance = math.max(currentDistance, AutoSkillSystem.targetFormDistance or 150)
    end
    if AutoSkillSystem.breathPreparing or AutoSkillSystem.breathHolding then
        currentDistance = math.max(currentDistance, AutoSkillSystem.breathSafeDistance or 150)
    end

    local targetPos = enemyRoot.Position
    local pred = FS.predictPlayerPos(enemy)
    if pred then
        targetPos = pred
    end

    local offset = Vector3.new(0, 0, 0)
    local lookCF = enemyRoot.CFrame
    if teleportMode == "Below" then
        offset = Vector3.new(0, -currentDistance, 0)
    elseif teleportMode == "Above" then
        offset = Vector3.new(0, currentDistance, 0)
    else
        local lookVec
        if pred then
            local flatVel = Vector3.new((pred - enemyRoot.Position).X, 0, (pred - enemyRoot.Position).Z)
            if flatVel.Magnitude > 0.1 then
                lookVec = flatVel.Unit
            else
                lookVec = lookCF and lookCF.LookVector or Vector3.new(0, 0, -1)
            end
        else
            lookVec = lookCF and lookCF.LookVector or Vector3.new(0, 0, -1)
        end
        offset = -lookVec * currentDistance
    end

    local desired = targetPos + offset
    root.CFrame = CFrame.new(desired, targetPos)
    pcall(function()
        root.Velocity = Vector3.new(0, 0, 0)
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end)
    FarmCam.update(targetPos)
    return true
end

function teleportAndLookWithKeys()
    while teleportAndLookLooping do
        local hasTarget = teleportAndLook()
        if hasTarget
            and not AutoSkillSystem.breathPreparing
            and not AutoSkillSystem.breathHolding then
            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end
        task.wait(0.2)
    end
end

local farmAttackLooping = false

function getCombatRemote()
    local rs = game:GetService("ReplicatedStorage")
    local remotes = rs:FindFirstChild("Remotes")
    if remotes then
        local async = remotes:FindFirstChild("Async")
        if async then return async end
    end
    return nil
end

local function isTargetBlocking(char)
    if not char or not char.Parent then return false end
    if char:FindFirstChild("Block") then return true end
    for _, child in ipairs(char:GetChildren()) do
        local n = child.Name:lower()
        if (n == "block" or n == "blocking" or n == "isblocking" or n == "guard") then
            if child:IsA("BoolValue") then
                if child.Value == true then return true end
            else
                return true
            end
        end
    end
    local attrs = {"IsBlocking", "Blocking", "Block", "Guarding", "IsGuard", "HoldingBlock"}
    for _, name in ipairs(attrs) do
        local ok, val = pcall(function() return char:GetAttribute(name) end)
        if ok and (val == true or val == 1 or val == "true") then return true end
    end
    local status = char:FindFirstChild("Status") or char:FindFirstChild("States") or char:FindFirstChild("State")
    if status then
        if status:FindFirstChild("Block") or status:FindFirstChild("Blocking") or status:FindFirstChild("IsBlocking") then
            return true
        end
        local stateVal = status:FindFirstChild("State") or status:FindFirstChild("CurrentState")
        if stateVal and stateVal:IsA("ValueBase") then
            local s = tostring(stateVal.Value):lower()
            if s:find("block") or s:find("guard") or s == "defending" then
                return true
            end
        end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        for _, name in ipairs(attrs) do
            local ok, val = pcall(function() return hum:GetAttribute(name) end)
            if ok and (val == true or val == 1) then return true end
        end
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                local an = (track.Name or ""):lower()
                local id = ""
                pcall(function()
                    if track.Animation then id = tostring(track.Animation.AnimationId or ""):lower() end
                end)
                if an:find("block") or an:find("guard") or an:find("defend") or id:find("block") then
                    return true
                end
            end
        end
    end
    local okTag, hasTag = pcall(function()
        return game:GetService("CollectionService"):HasTag(char, "Blocking")
            or game:GetService("CollectionService"):HasTag(char, "Block")
    end)
    if okTag and hasTag then return true end
    return false
end

local function getCurrentFarmCharacter()
    if castleFarmActive then
        return selectCastleFarmTarget()
    end
    if raidFarmActive then
        return selectRaidFarmTarget()
    end
    if not currentMob then return nil end
    return findEnemy(currentMob)
end

local function isGuiVisibleAtPosition(gui, pos)
    if not gui or not gui:IsA("GuiObject") or not gui.Visible then
        return false
    end

    local ancestor = gui
    while ancestor do
        if ancestor:IsA("GuiObject") and not ancestor.Visible then
            return false
        end
        if ancestor:IsA("LayerCollector") and not ancestor.Enabled then
            return false
        end
        ancestor = ancestor.Parent
    end

    local absolutePosition = gui.AbsolutePosition
    local absoluteSize = gui.AbsoluteSize
    return absoluteSize.X > 0
        and absoluteSize.Y > 0
        and pos.X >= absolutePosition.X
        and pos.X <= absolutePosition.X + absoluteSize.X
        and pos.Y >= absolutePosition.Y
        and pos.Y <= absolutePosition.Y + absoluteSize.Y
end

isPointerOverHub = function(pos)
    local ok, over = pcall(function()
        if not screenGui or not screenGui.Parent or not screenGui.Enabled then
            return false
        end

        pos = pos or UserInputService:GetMouseLocation()
        for _, gui in ipairs(screenGui:GetDescendants()) do
            if isGuiVisibleAtPosition(gui, pos) then
                return true
            end
        end
        return false
    end)
    return ok and over
end

-- O clique visual automático nunca é enviado diretamente sobre uma
-- interface. Quando necessário, ele é redirecionado para um ponto livre.
-- O input real do usuário continua chegando à GUI, então botões, TextBox,
-- sliders e arraste não são desativados.
local function isPointerOverInterface(pos)
    pos = pos or UserInputService:GetMouseLocation()

    if isPointerOverHub(pos) then
        return true
    end

    local ok, guiObjects = pcall(function()
        return GuiService:GetGuiObjectsAtPosition(pos.X, pos.Y)
    end)
    if not ok or not guiObjects then
        return false
    end

    for _, gui in ipairs(guiObjects) do
        if isGuiVisibleAtPosition(gui, pos) then
            return true
        end
    end
    return false
end

-- Retorna a posição original quando ela está livre. Se o cursor estiver
-- sobre uma interface, procura um ponto livre para que o clique automático
-- continue acionando a espada/lunge sem clicar em nenhum elemento da UI.
local function getSafeVisualClickPosition(preferredPos)
    local viewport = Camera and Camera.ViewportSize
    if not viewport or viewport.X <= 2 or viewport.Y <= 2 then
        return nil
    end

    local candidates = {
        preferredPos,
        Vector2.new(viewport.X * 0.50, viewport.Y * 0.50),
        Vector2.new(viewport.X * 0.08, viewport.Y * 0.50),
        Vector2.new(viewport.X * 0.92, viewport.Y * 0.50),
        Vector2.new(viewport.X * 0.50, viewport.Y * 0.12),
        Vector2.new(viewport.X * 0.50, viewport.Y * 0.88),
        Vector2.new(8, 8),
        Vector2.new(viewport.X - 8, 8),
        Vector2.new(8, viewport.Y - 8),
        Vector2.new(viewport.X - 8, viewport.Y - 8),
    }

    for _, rawPos in ipairs(candidates) do
        if rawPos and rawPos.X >= 1 and rawPos.Y >= 1
            and rawPos.X <= viewport.X - 1
            and rawPos.Y <= viewport.Y - 1 then
            local pos = Vector2.new(rawPos.X, rawPos.Y)
            if not isPointerOverInterface(pos) then
                return pos
            end
        end
    end

    return nil
end

local function shouldSkipVisualClick(pos)
    if hubInteracting then return true end
    return isPointerOverInterface(pos)
end

UserInputService.InputBegan:Connect(function(input, _gp)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        if isPointerOverHub(input.Position) then
            hubInteracting = true
        end
    end
end)
UserInputService.InputEnded:Connect(function(input, _gp)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        hubInteracting = false
    end
end)

local function sendMouseM1()
    pcall(function()
        local mousePos = UserInputService:GetMouseLocation()
        local clickPos = getSafeVisualClickPosition(mousePos)
        if not clickPos then return end

        local x, y = clickPos.X, clickPos.Y
        VIM:SendMouseButtonEvent(x, y, 0, true, game, 1)
        task.wait(0.04)
        VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
    end)
end

local function sendRemoteM1()
    pcall(function()
        local remote = getCombatRemote()
        if remote then remote:FireServer("Combat", "Server") end
    end)
end

local function sendM1(allowDuringLunge)
    if AutoSkillSystem.breathPreparing or AutoSkillSystem.breathHolding then return end
    if FS.lunging and not allowDuringLunge then return end
    sendRemoteM1()
    sendMouseM1()
end

local function sendM2()
    if AutoSkillSystem.breathPreparing or AutoSkillSystem.breathHolding then return end
    if FS.lunging then return end
    pcall(function()
        local remote = getCombatRemote()
        if remote then remote:FireServer("Combat", "Heavy") end
    end)
    if not shouldSkipVisualClick() then
        pcall(function()
            VIM:SendMouseButtonEvent(0, 0, 1, true, game, 1)
            task.wait(0.05)
            VIM:SendMouseButtonEvent(0, 0, 1, false, game, 1)
        end)
    end
end

FS.doLunge = function()
    if AutoSkillSystem.breathPreparing or AutoSkillSystem.breathHolding then return end
    if FS.lunging or FS.playerStunned then return end
    if (tick() - FS.lastLunge) < FS.lungeCd then return end
    FS.lunging = true
    FS.lastLunge = tick()
    pcall(function()
        -- Double-tap W inicia o sprint; cliques M1 começam 10ms depois do timing anterior.
        -- lungeRunHold sincronizado com a duração real da sequência (0.11 + 5*0.08 = 0.51).
        VIM:SendKeyEvent(true, Enum.KeyCode.W, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, Enum.KeyCode.W, false, game)
        task.wait(0.08)
        VIM:SendKeyEvent(true, Enum.KeyCode.W, false, game)
        local runStarted = tick()
        task.wait(0.11) -- +10ms vs 0.10: primeiro clique do lunge 10ms depois

        for _ = 1, 5 do
            -- Nunca força um clique sobre uma interface; o cursor continua
            -- livre para usar o hub enquanto a sequência de lunge roda.
            sendMouseM1()
            task.wait(0.08)
        end

        local remainingRun = (FS.lungeRunHold or 0.51) - (tick() - runStarted)
        if remainingRun > 0 then
            task.wait(remainingRun)
        end
        VIM:SendKeyEvent(false, Enum.KeyCode.W, false, game)
    end)
    task.wait(0.05)
    FS.lunging = false
end

FS.doExec = function()
    if AutoSkillSystem.breathPreparing or AutoSkillSystem.breathHolding then return end
    local localHumanoid = player and player.Character
        and player.Character:FindFirstChildOfClass("Humanoid")
    if localHumanoid and localHumanoid.Health <= 0 then return end
    if (tick() - FS.lastExec) < FS.execInterval then return end
    FS.lastExec = tick()
    pcall(function()
        VIM:SendKeyEvent(true, Enum.KeyCode.B, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, Enum.KeyCode.B, false, game)
    end)
end

local function smartAttackOnce()
    if AutoSkillSystem.breathPreparing or AutoSkillSystem.breathHolding then
        return
    end

    local enemy = getCurrentFarmCharacter()
    local demonMode = FS.isDemon()

    if not enemy or not enemy.Parent then
        return
    end

    local localHumanoid = player and player.Character
        and player.Character:FindFirstChildOfClass("Humanoid")
    if localHumanoid and localHumanoid.Health <= 0 then
        return
    end

    if targetIsUsingForm(enemy) then
        return
    end

    local enemyIsDead = FS.zeroHP(enemy)
    if enemyIsDead and farmCanFinalize then
        FS.markExec(enemy)
    end
    if farmCanFinalize and FS.execLocked(enemy) then
        FS.doExec()
        return
    end
    if enemyIsDead then
        return
    end

    -- Oni e Slayer usam o mesmo stun/recuo. A única diferença do Oni
    -- é não executar o lunge quando o recuo termina.
    if FS.playerStunned or tick() < (FS.stunHoldUntil or 0) then
        return
    end

    if FS.ragdolled(enemy) then
        if not demonMode then
            if not FS.wasRagdoll then
                FS.wasRagdoll = true
                FS.ragdollSince = tick()
                FS.didLunge = false
            end
            if not FS.didLunge and (tick() - FS.ragdollSince) >= FS.ragdollWait then
                FS.doLunge()
                FS.didLunge = true
            end
        end
        -- Oni espera o ragdoll terminar, mas não usa lunge.
        return
    end

    if FS.wasRagdoll then
        FS.wasRagdoll = false
        FS.didLunge = false
    end

    if isTargetBlocking(enemy) then
        local safety = 0
        while isEnabled and safety < 40 do
            enemy = getCurrentFarmCharacter()
            if not enemy or not enemy.Parent or not isTargetBlocking(enemy) then break end
            sendM2()
            task.wait(0.11)
            safety = safety + 1
        end
    else
        sendM1()
    end
end

local function autoAttackOnce()
    if AutoSkillSystem.breathPreparing or AutoSkillSystem.breathHolding then
        return
    end

    -- Auto Attack é independente do farm: usa somente o remote de M1
    -- e não chama smartAttackOnce, não usa alvo do farm e não injeta clique.
    sendRemoteM1()
end

local function autoAttackLoop(loopToken)
    while autoAttack and loopToken == autoAttackLoopToken do
        autoAttackOnce()
        task.wait(0.14)
    end
end

local function farmAttackLoop()
    local nextFarmExecute = 0
    while farmAttackLooping and isEnabled do
        if respawnFarmCharacterIfLowHealth() then
            -- Pausa brevemente para o novo personagem carregar.
            task.wait(0.25)
        elseif farmRespawnBusy then
            task.wait(0.14)
        elseif AutoSkillSystem.breathPreparing or AutoSkillSystem.breathHolding then
            task.wait(0.14)
        else
        local demonMode = FS.isDemon()
        local stunnedNow = FS.iAmStunned()
        if stunnedNow and not FS.playerStunned then
            FS.playerStunned = true
            -- Oni e Slayer se afastam durante o stun.
            FS.curDist = FS.safeDist
            FS.stunHoldUntil = 0
            FS.returnLungePending = false
        elseif not stunnedNow and FS.playerStunned then
            -- Stun acabou: ambos aguardam o mesmo recuo.
            -- Apenas o Slayer agenda o lunge no fim desse recuo.
            FS.playerStunned = false
            FS.stunHoldUntil = tick() + (FS.stunRecoilHold or 1.5)
            FS.curDist = FS.safeDist
            FS.returnLungePending = not demonMode
        elseif not FS.playerStunned and FS.curDist and (FS.stunHoldUntil or 0) > 0 then
            local now = tick()
            -- Mantém o comportamento original: o lunge começa no fim do recuo,
            -- imediatamente antes de voltar para a distância de ataque.
            -- O atraso extra de 0,20 s deixa a sequência um pouco mais lenta que a anterior.
            local lead = math.max(0.05,
                (FS.lungeRunHold or 0.51) + 0.08 - (FS.lungeExtraDelay or 0.30))
            if not demonMode and FS.returnLungePending and now >= (FS.stunHoldUntil - lead) then
                FS.returnLungePending = false
                spawn(function()
                    FS.doLunge()
                end)
            end
            if now >= FS.stunHoldUntil then
                FS.curDist = nil
                FS.stunHoldUntil = 0
            end
        end
        if tick() >= nextFarmExecute then
            FS.doExec()
            nextFarmExecute = tick() + (FS.execInterval or 5)
        end
        smartAttackOnce()
        task.wait(0.14)
        end
    end
end

local function teleportFarmPlayerUp()
    local currentCharacter = player and player.Character
    local currentRoot = currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart")
    if not currentRoot then
        currentRoot = root
    end
    if currentRoot and currentRoot.Parent then
        pcall(function()
            currentRoot.CFrame = currentRoot.CFrame + Vector3.new(0, 12, 0)
            currentRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            currentRoot.Velocity = Vector3.new(0, 0, 0)
        end)
    end
end

function toggleTeleport(enable, mobName, scope)
    if enable then
        castleFarmActive = mobName == CASTLE_GENERAL_TARGET
        raidFarmActive = mobName == RAID_GENERAL_TARGET
        farmIsRaid = castleFarmActive or raidFarmActive or isRaidFarmName(mobName)
        farmScope = scope or "FARM"
        farmCanFinalize = farmScope == "FARM"
            and not farmIsRaid
            and Players:FindFirstChild(tostring(mobName or "")) == nil
        raidFarmTarget = nil
        raidFarmLastScan = 0
        castleFarmTarget = nil
        castleFarmLastScan = 0
        castleBossEngaged = false
        if not isEnabled then
            farmNoclipWasEnabled = noclipToggle
        end
        toggleNoclip(true)
        if connection then connection:Disconnect() end
        teleportAndLookLooping = true
        enemyCache.name = nil
        enemyCache.model = nil
        enemyCache.lastScan = 0
        FarmCam.start()
        connection = RunService.RenderStepped:Connect(teleportAndLook)
        spawn(teleportAndLookWithKeys)
        -- O alvo de fallback do modo geral do castelo é o mob exato
        -- "GenericOni"; bosses têm prioridade dentro de selectCastleFarmTarget.
        currentMob = castleFarmActive and "GenericOni" or mobName
        equipKatana()
        isEnabled = true
        farmAttackLooping = true
        FS.wasRagdoll = false
        FS.didLunge = false
        FS.playerStunned = false
        FS.curDist = nil
        FS.stunHoldUntil = 0
        FS.returnLungePending = false
        FS.lastExec = 0
        FS.execUntil = 0
        FS.execTarget = nil
        FS.lunging = false
        spawn(farmAttackLoop)
    else
        local hadFarmEnabled = isEnabled
        local wasRaidFarm = farmIsRaid
        raidFarmActive = false
        castleFarmActive = false
        farmIsRaid = false
        farmScope = nil
        farmCanFinalize = false
        raidFarmTarget = nil
        raidFarmLastScan = 0
        castleFarmTarget = nil
        castleFarmLastScan = 0
        castleBossEngaged = false
        if connection then connection:Disconnect() connection = nil end
        teleportAndLookLooping = false
        farmAttackLooping = false
        isEnabled = false
        currentMob = nil
        enemyCache.name = nil
        enemyCache.model = nil
        enemyCache.lastScan = 0
        FS.wasRagdoll = false
        FS.didLunge = false
        FS.playerStunned = false
        FS.curDist = nil
        FS.stunHoldUntil = 0
        FS.returnLungePending = false
        FS.execUntil = 0
        FS.execTarget = nil
        FS.lunging = false
        FarmCam.stop()
        if hadFarmEnabled then
            toggleNoclip(farmNoclipWasEnabled)
            farmNoclipWasEnabled = false
            if not wasRaidFarm then
                teleportFarmPlayerUp()
            end
        end
    end
end

function emergencyStop()
    local hadMobFarm = isEnabled
    local hadRaidFarm = farmIsRaid
    local hadOreFarm = oreFarm
    local hadTrinketFarm = trinketFarm

    autoAttack = false
    globalEnv.autoAttack = false
    autoAttackLoopToken = autoAttackLoopToken + 1

    if hadMobFarm then
        toggleTeleport(false)
    end

    oreFarm = false
    globalEnv.oreFarm = false
    trinketFarm = false
    globalEnv.trinketFarm = false
    flyToggle = false
    globalEnv.flyToggle = false
    if bg then bg:Destroy(); bg = nil end
    if bv then bv:Destroy(); bv = nil end
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if humanoid then humanoid.PlatformStand = false end

    -- Ore/trinket não passam por toggleTeleport, então recebem a mesma
    -- saída segura dos farms comuns. Farm de raid nunca teleporta ao parar.
    if not (hadMobFarm and hadRaidFarm) and (hadOreFarm or hadTrinketFarm) then
        teleportFarmPlayerUp()
    end

    toggleNoclip(false)
    pcall(function()
        VIM:SendKeyEvent(false, Enum.KeyCode.W, false, game)
        VIM:SendKeyEvent(false, Enum.KeyCode.B, false, game)
        VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        VIM:SendKeyEvent(false, Enum.KeyCode.Z, false, game)
    end)

    if notifyDev then
        notifyDev(T("EMERGENCY_DONE"))
    end
end

local function getAllAvailableOres()
    local list = {}
    local map = workspace:FindFirstChild("Map")
    local minerals = map and map:FindFirstChild("Minerals")
    if not minerals then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v.Name == "Mineral" and (v:IsA("MeshPart") or v:IsA("BasePart")) then
                local nameVal = v:FindFirstChild("MineralName")
                local spawnVal = v:FindFirstChild("Spawn")
                if nameVal and spawnVal and spawnVal.Value ~= nil then
                    table.insert(list, v)
                end
            end
        end
        return list
    end
    for _, v in ipairs(minerals:GetDescendants()) do
        if v.Name == "Mineral" and (v:IsA("MeshPart") or v:IsA("BasePart")) then
            local nameVal = v:FindFirstChild("MineralName")
            local spawnVal = v:FindFirstChild("Spawn")
            if nameVal and spawnVal and spawnVal.Value ~= nil then
                table.insert(list, v)
            end
        end
    end
    return list
end

local function isOreStillAvailable(ore)
    if not ore or not ore.Parent then return false end
    local spawnVal = ore:FindFirstChild("Spawn")
    if not spawnVal then return false end
    if spawnVal.Value == nil then return false end
    return true
end

local function mineHit()
    pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        local remotes = rs:FindFirstChild("Remotes")
        if remotes then
            local sync = remotes:FindFirstChild("Sync")
            if sync then
                sync:InvokeServer("Pickaxe", "Server")
            end
            local async = remotes:FindFirstChild("Async")
            if async then
                async:FireServer("Pickaxe", "Server")
            end
        end
    end)
    pcall(function()
        VIM:SendKeyEvent(true, Enum.KeyCode.Z, false, game)
        task.wait(0.03)
        VIM:SendKeyEvent(false, Enum.KeyCode.Z, false, game)
    end)
end

local function oreFarmLoop()
    if not oreAreasLoaded and root then
        for _, coord in ipairs(ORE_LOAD_COORDS) do
            if not oreFarm then return end
            root.CFrame = CFrame.new(coord)
            task.wait(1)
        end
        oreAreasLoaded = true
        globalEnv.oreAreasLoaded = true
    end

    while oreFarm do
        local ok, err = pcall(function()
            if not root or not character then
                task.wait(0.3)
                return
            end
            if not flyToggle then
                flyToggle = true
                globalEnv.flyToggle = true
                setupOreFly()
            end
            local ores = getAllAvailableOres()
            if #ores == 0 then
                task.wait(1)
                return
            end
            for _, ore in ipairs(ores) do
                if not oreFarm then break end
                if isOreStillAvailable(ore) then
                    local pos = ore.Position
                    root.CFrame = CFrame.new(pos + Vector3.new(0, -1.5, -2), pos)
                    pcall(function() root.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end)
                    pcall(function() root.Velocity = Vector3.new(0, 0, 0) end)

                    local hits = 0
                    while oreFarm and isOreStillAvailable(ore) and hits < 12 do
                        root.CFrame = CFrame.new(ore.Position + Vector3.new(0, -1.5, -2), ore.Position)
                        mineHit()
                        hits = hits + 1
                        task.wait(0.35)
                    end
                    task.wait(0.08)
                end
            end
        end)
        if not ok then
            task.wait(0.5)
        else
            task.wait(0.1)
        end
    end
end

local loadedMobNames = {}
local loadedMobNameSet = {}
globalEnv._MoonDFCapturedNpcLogs = globalEnv._MoonDFCapturedNpcLogs or {}

function collectLoadedMobNames()
    local unique = {}
    for _, model in ipairs(workspace:GetDescendants()) do
        if model:IsA("Model") and model ~= character
            and not Players:GetPlayerFromCharacter(model)
            and model:FindFirstChildOfClass("Humanoid")
            and (model:FindFirstChild("HumanoidRootPart")
                or model:FindFirstChild("Torso")
                or model:FindFirstChild("Head")) then
            unique[model.Name] = true
        end
    end

    local names = {}
    for name in pairs(unique) do
        table.insert(names, name)
    end
    table.sort(names, function(a, b)
        local lowerA, lowerB = string.lower(a), string.lower(b)
        if lowerA == lowerB then return a < b end
        return lowerA < lowerB
    end)
    return names
end

function rememberLoadedMobNames()
    for _, name in ipairs(collectLoadedMobNames()) do
        if not loadedMobNameSet[name] then
            loadedMobNameSet[name] = true
            table.insert(loadedMobNames, name)
        end
    end
    table.sort(loadedMobNames, function(a, b)
        local lowerA, lowerB = string.lower(a), string.lower(b)
        if lowerA == lowerB then return a < b end
        return lowerA < lowerB
    end)
end

function detectLoadedMobs()
    if loadingAllMobs then return end
    loadingAllMobs = true
    loadedMobNames = {}
    loadedMobNameSet = {}
    rememberLoadedMobNames()
    loadingAllMobs = false
    notifyDev(#loadedMobNames > 0
        and string.format(T("DEV_DETECTED_COUNT"), #loadedMobNames)
        or T("DEV_NO_MOBS"))
end

function teleportToEvent(cframe)
    if root and cframe then
        root.CFrame = cframe
    end
end

function loadAllMap()
    if loadingAllMobs then return end
    loadingAllMobs = true
    local initialPosition = root.CFrame
    local allCoords = {
        Vector3.new(-3398.0, 722.4, -1128.5),
        Vector3.new(-2740.9, 737.8, -3378.0),
        Vector3.new(-4571.8, 776.6, -6140.8),
        Vector3.new(-6456.1, 815.1, -6298.2),
        Vector3.new(-1944.1, 874.4, -2510.4),
        Vector3.new(1634.1, 1190.1, -1446.3),
        Vector3.new(1406.2, 769.3, -6549.3),
        Vector3.new(893.3, 772.6, -2260.9),
        Vector3.new(7099.3, 1762.3, 1342.9),
        Vector3.new(-3571.8, 714.1, -994.5),
        Vector3.new(-2343.6, 1166.6, -1678.2),
        Vector3.new(-5433.1, 761.0, -6392.9),
        Vector3.new(-1986.7, 871.8, -6484.5),
        Vector3.new(-5123, 815, -3037),
        Vector3.new(-9986.8, 6898.9, -4678.2),
        Vector3.new(3433.3, 3732.3, 1879.8),
        Vector3.new(3396.3, 4010.6, 1768.6)
    }
    for i, coord in ipairs(allCoords) do
        root.CFrame = CFrame.new(coord)
        task.wait(2)
    end
    root.CFrame = initialPosition
    loadingAllMobs = false
end

function setupHealthPlayer(plr)
    plr.CharacterAdded:Connect(function()
        maxHealthCache[plr.UserId] = nil
        playerSpawnTime[plr.UserId] = os.clock()
    end)
end

for _, plr in ipairs(Players:GetPlayers()) do
    setupHealthPlayer(plr)
    if plr.Character then
        playerSpawnTime[plr.UserId] = os.clock()
    end
end
Players.PlayerAdded:Connect(setupHealthPlayer)
Players.PlayerRemoving:Connect(function(plr)
    maxHealthCache[plr.UserId] = nil
    playerSpawnTime[plr.UserId] = nil
end)

function findRealHealthAndMax(plr)
    local char = plr.Character
    if not char then return nil, nil end

    local currentHp = nil
    local hpVal = char:FindFirstChild("Health")
    if hpVal and hpVal:IsA("ValueBase") then
        currentHp = tonumber(hpVal.Value)
    end
    if not currentHp then
        local pHp = plr:FindFirstChild("Health")
        if pHp and pHp:IsA("ValueBase") then currentHp = tonumber(pHp.Value) end
    end
    if not currentHp then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then currentHp = hum.Health end
    end
    if not currentHp then return nil, nil end

    local maxHp = nil
    local maxVal = plr:FindFirstChild("MaxHealth")
    if maxVal and maxVal:IsA("ValueBase") then
        local v = tonumber(maxVal.Value)
        if v and v > 0 then maxHp = v end
    end
    if not maxHp then
        local cMax = char:FindFirstChild("MaxHealth")
        if cMax and cMax:IsA("ValueBase") then
            local v = tonumber(cMax.Value)
            if v and v > 0 then maxHp = v end
        end
    end
    local userId = plr.UserId
    local timeSinceSpawn = os.clock() - (playerSpawnTime[userId] or 0)
    if timeSinceSpawn >= 4 then
        if not maxHealthCache[userId] or currentHp > (maxHealthCache[userId] or 0) then
            maxHealthCache[userId] = currentHp
        end
    end
    if maxHp then
        maxHealthCache[userId] = maxHp
    else
        maxHp = maxHealthCache[userId] or math.max(currentHp, 100)
    end
    if maxHp < currentHp then maxHp = currentHp end
    if maxHp > ABSOLUTE_MAX_HP then maxHp = ABSOLUTE_MAX_HP end

    return math.floor(currentHp), math.floor(maxHp)
end

function clearAutoRegenHealthTag()
    if globalEnv._MoonDFAutoRegenHealthTag then
        pcall(function() globalEnv._MoonDFAutoRegenHealthTag:Destroy() end)
        globalEnv._MoonDFAutoRegenHealthTag = nil
    end
end

function updateAutoRegenHealthTag()
    if not autoRegenHealthESP then
        clearAutoRegenHealthTag()
        return
    end

    local char = player and player.Character
    local head = char and char:FindFirstChild("Head")
    if not head then
        clearAutoRegenHealthTag()
        return
    end

    if globalEnv._MoonDFAutoRegenHealthTag
        and globalEnv._MoonDFAutoRegenHealthTag.Parent ~= head
    then
        clearAutoRegenHealthTag()
    end

    if not globalEnv._MoonDFAutoRegenHealthTag then
        local tag = Instance.new("BillboardGui")
        tag.Name = "MoonDFAutoRegenHealth"
        tag.Size = UDim2.new(0, 190, 0, 30)
        tag.StudsOffset = Vector3.new(0, 3.6, 0)
        tag.AlwaysOnTop = true
        tag.MaxDistance = 0
        tag.LightInfluence = 0
        tag.Parent = head
        globalEnv._MoonDFAutoRegenHealthTag = tag

        local label = Instance.new("TextLabel")
        label.Name = "TextDisplay"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextStrokeTransparency = 0.2
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.Parent = tag
    end

    local currentHp, maxHp = findRealHealthAndMax(player)
    local label = globalEnv._MoonDFAutoRegenHealthTag:FindFirstChild("TextDisplay")
    if not label then return end

    if currentHp and maxHp and maxHp > 0 then
        local percent = math.clamp(currentHp / maxHp, 0, 1)
        label.Text = string.format("HP REAL: %d / %d", currentHp, maxHp)
        label.TextColor3 = Color3.fromHSV(percent * 0.33, 0.95, 1)
    else
        label.Text = "HP REAL: ..."
        label.TextColor3 = Color3.fromRGB(180, 180, 200)
    end
end

if globalEnv._MoonDFAutoRegenHealthConnection then
    pcall(function()
        globalEnv._MoonDFAutoRegenHealthConnection:Disconnect()
    end)
end
globalEnv._MoonDFAutoRegenHealthConnection = RunService.Heartbeat:Connect(updateAutoRegenHealthTag)

function getPlayerStamina(plr)
    local cur, maxS = nil, nil
    local s = plr:FindFirstChild("Stamina")
    if s and s:IsA("ValueBase") then cur = tonumber(s.Value) end
    local ms = plr:FindFirstChild("MaxStamina")
    if ms and ms:IsA("ValueBase") then maxS = tonumber(ms.Value) end
    local char = plr.Character
    if char then
        if not cur then
            local cs = char:FindFirstChild("Stamina")
            if cs and cs:IsA("ValueBase") then cur = tonumber(cs.Value) end
        end
        if not maxS then
            local cms = char:FindFirstChild("MaxStamina")
            if cms and cms:IsA("ValueBase") then maxS = tonumber(cms.Value) end
        end
    end
    if not cur then return nil, nil end
    maxS = maxS or 200
    if maxS < 1 then maxS = 1 end
    return math.clamp(cur, 0, maxS), maxS
end

-- O bloco principal já está próximo do limite de 200 registradores locais
-- do Luau. Guardar esta função na tabela compartilhada evita criar mais um
-- registrador local sem mudar o comportamento do ESP.
AutoSkillSystem.getPlayerBreathing = function(plr)
    if not plr then return nil end
    local b = plr:FindFirstChild("Breathing")
    if b and b:IsA("ValueBase") then
        local v = tonumber(b.Value)
        if v then return math.clamp(v, 0, 100) end
    end
    local char = plr.Character
    if char then
        local cb = char:FindFirstChild("Breathing")
        if cb and cb:IsA("ValueBase") then
            local v = tonumber(cb.Value)
            if v then return math.clamp(v, 0, 100) end
        end
    end
    return nil
end

-- Mantido fora dos registradores locais do bloco principal.
ESP_MAX_DIST = 180

function clearAllHealthESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            if head then
                local tag = head:FindFirstChild("MoonDFHealthESP")
                if tag then tag:Destroy() end
            end
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, n in ipairs({"MoonDF_StaminaBar", "MoonDF_BreathBar"}) do
                    local b = hrp:FindFirstChild(n)
                    if b then b:Destroy() end
                end
            end
            local oldHl = plr.Character:FindFirstChild("MoonDFHighlight")
            if oldHl then oldHl:Destroy() end
        end
        if espFolder then
            local hl = espFolder:FindFirstChild("HL_" .. tostring(plr.UserId))
            if hl then hl:Destroy() end
        end
    end
end

function ensureSideBar(hrp, name, offsetX)
    local gui = hrp:FindFirstChild(name)
    if gui and gui:IsA("BillboardGui") then return gui end
    if gui then gui:Destroy() end
    gui = Instance.new("BillboardGui")
    gui.Name = name
    gui.Size = UDim2.new(0, 6, 0, 52)
    gui.StudsOffset = Vector3.new(offsetX, 0.2, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = ESP_MAX_DIST
    gui.LightInfluence = 0
    gui.Parent = hrp

    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, 0, 1, 0)
    track.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    track.BackgroundTransparency = 0.25
    track.BorderSizePixel = 0
    track.Parent = gui
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.AnchorPoint = Vector2.new(0, 1)
    fill.Position = UDim2.new(0, 0, 1, 0)
    fill.Size = UDim2.new(1, 0, 1, 0)
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    return gui
end

-- Barra 3D presa ao personagem. Diferente de BillboardGui, o tamanho destas
-- peças é medido em studs e acompanha a câmera como um objeto do mundo.
function ensureCharacterBreathBar(character, hrp, name, offsetX)
    local oldBar = hrp:FindFirstChild(name) or character:FindFirstChild(name)
    if oldBar and oldBar:IsA("Model")
        and oldBar:GetAttribute("MoonDFWorldBreathBar") == true then
        return oldBar
    end
    if oldBar then
        pcall(function() oldBar:Destroy() end)
    end

    local model = Instance.new("Model")
    model.Name = name
    model:SetAttribute("MoonDFWorldBreathBar", true)
    model.Parent = character

    local width = 0.12
    local depth = 0.16
    -- Deixa a barra fora do braço, atrás das costas e alinhada à lateral
    -- do braço, sem alterar o modo de barra fixa na tela.
    local height = 2.8
    local baseCFrame = hrp.CFrame * CFrame.new(offsetX, 0.2, 0.75)

    local track = Instance.new("Part")
    track.Name = "Track"
    track.Size = Vector3.new(width, height, depth)
    track.CFrame = baseCFrame
    track.Color = Color3.fromRGB(20, 22, 28)
    track.Transparency = 0.25
    track.Material = Enum.Material.SmoothPlastic
    track.CanCollide = false
    track.CanTouch = false
    track.CanQuery = false
    track.CastShadow = false
    track.Massless = true
    track.Parent = model

    local trackWeld = Instance.new("Weld")
    trackWeld.Name = "TrackWeld"
    trackWeld.Part0 = hrp
    trackWeld.Part1 = track
    trackWeld.C0 = hrp.CFrame:ToObjectSpace(baseCFrame)
    trackWeld.Parent = model

    local fill = Instance.new("Part")
    fill.Name = "Fill"
    fill.Size = Vector3.new(width * 1.08, height, depth * 1.08)
    fill.CFrame = baseCFrame
    fill.Color = Color3.new(1, 1, 1)
    fill.Material = Enum.Material.Neon
    fill.CanCollide = false
    fill.CanTouch = false
    fill.CanQuery = false
    fill.CastShadow = false
    fill.Massless = true
    fill.Parent = model

    local fillWeld = Instance.new("Weld")
    fillWeld.Name = "FillWeld"
    fillWeld.Part0 = hrp
    fillWeld.Part1 = fill
    fillWeld.C0 = hrp.CFrame:ToObjectSpace(baseCFrame)
    fillWeld.Parent = model

    model.PrimaryPart = track
    model:SetAttribute("FullHeight", height)
    model:SetAttribute("BarWidth", width * 1.08)
    model:SetAttribute("BarDepth", depth * 1.08)
    return model
end

function setCharacterBreathBarVisible(model, visible)
    if not model or not model:IsA("Model") then return end
    local track = model:FindFirstChild("Track")
    local fill = model:FindFirstChild("Fill")
    if track and track:IsA("BasePart") then
        track.Transparency = visible and 0.25 or 1
    end
    if fill and fill:IsA("BasePart") then
        fill.Transparency = visible and 0 or 1
    end
end

-- Barra de respiração fixa na tela. Diferente das barras do ESP dos outros
-- jogadores, esta não fica presa ao personagem nem depende da câmera.
function ensureFixedBreathBar()
    local gui = globalEnv._MoonDFAutoBreathBar
    if gui and gui.Parent == screenGui and gui:IsA("Frame") then
        return gui
    end
    if gui then
        pcall(function() gui:Destroy() end)
        globalEnv._MoonDFAutoBreathBar = nil
    end

    gui = Instance.new("Frame")
    gui.Name = "MoonDF_AutoBreathBar"
    gui.AnchorPoint = Vector2.new(0.5, 0.5)
    -- Um pouco mais à esquerda, centralizada verticalmente.
    gui.Position = UDim2.new(17 / 32, 0, 0.5, 0)
    gui.Size = UDim2.new(0, 6, 0, 110)
    gui.BackgroundTransparency = 1
    gui.BorderSizePixel = 0
    gui.Visible = false
    gui.ZIndex = 100
    gui.Parent = screenGui

    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, 0, 1, 0)
    track.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    track.BackgroundTransparency = 0.25
    track.BorderSizePixel = 0
    track.ZIndex = 100
    track.Parent = gui
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.AnchorPoint = Vector2.new(0, 1)
    fill.Position = UDim2.new(0, 0, 1, 0)
    fill.Size = UDim2.new(1, 0, 1, 0)
    fill.BackgroundColor3 = Color3.new(1, 1, 1)
    fill.BorderSizePixel = 0
    fill.ZIndex = 101
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    globalEnv._MoonDFAutoBreathBar = gui
    return gui
end

function setAutoBreathBarMode(mode)
    if mode ~= "Character" and mode ~= "Screen" then
        return
    end

    AutoSkillSystem.breathBarMode = mode
    globalEnv.autoBreathBarMode = mode

    -- Troca o tipo de GUI imediatamente; o próximo Heartbeat recria a barra
    -- no novo destino sem perder o valor atual da respiração.
    local currentBar = globalEnv._MoonDFAutoBreathBar
    if currentBar then
        pcall(function() currentBar:Destroy() end)
        globalEnv._MoonDFAutoBreathBar = nil
    end
end

function setSideBarPct(gui, pct, color)
    if not gui then return end
    if gui:IsA("Model") and gui:GetAttribute("MoonDFWorldBreathBar") == true then
        local track = gui:FindFirstChild("Track")
        local fill = gui:FindFirstChild("Fill")
        if not track or not fill
            or not track:IsA("BasePart")
            or not fill:IsA("BasePart") then
            return
        end
        pct = math.clamp(pct or 0, 0, 1)
        local fullHeight = gui:GetAttribute("FullHeight") or 2.2
        local barWidth = gui:GetAttribute("BarWidth") or 0.13
        local barDepth = gui:GetAttribute("BarDepth") or 0.17
        local fillHeight = math.max(0.001, fullHeight * pct)
        fill.Size = Vector3.new(barWidth, fillHeight, barDepth)
        -- Mantém a base do preenchimento no mesmo lugar enquanto ele sobe.
        local fillWeld = gui:FindFirstChild("FillWeld")
        if fillWeld and fillWeld:IsA("Weld") then
            local targetCFrame = track.CFrame
                * CFrame.new(0, (fillHeight - fullHeight) / 2, 0)
            fillWeld.C0 = fillWeld.Part0.CFrame:ToObjectSpace(targetCFrame)
        end
        if color then fill.Color = color end
        return
    end
    local track = gui:FindFirstChild("Track")
    local fill = track and track:FindFirstChild("Fill")
    if not fill then return end
    pct = math.clamp(pct or 0, 0, 1)
    fill.Size = UDim2.new(1, 0, pct, 0)
    if color then fill.BackgroundColor3 = color end
end

function toggleAutoBreathBar(state)
    AutoSkillSystem.breathBarEnabled = state == true
    globalEnv.autoBreathBar = AutoSkillSystem.breathBarEnabled
    if not AutoSkillSystem.breathBarEnabled then
        clearAutoBreathBar()
    else
        local currentBreath = AutoSkillSystem.getPlayerBreathing(player)
        AutoSkillSystem.breathBarLastValue = currentBreath
        AutoSkillSystem.breathBarLastActivity = 0
        -- Começa no valor real atual, sem animar desde o zero.
        AutoSkillSystem.breathBarDisplay = currentBreath
            and math.clamp(currentBreath / 100, 0, 1)
            or AutoSkillSystem.breathBarDisplay
    end
end

function clearAutoBreathBar()
    local bar = globalEnv._MoonDFAutoBreathBar
    if bar then
        pcall(function() bar:Destroy() end)
        globalEnv._MoonDFAutoBreathBar = nil
    end
    AutoSkillSystem.breathBarGui = nil
    AutoSkillSystem.breathBarDisplay = 0
    AutoSkillSystem.breathBarLastValue = nil
    AutoSkillSystem.breathBarLastActivity = 0
    AutoSkillSystem.breathBarNextProbe = 0
end

-- O valor pode já estar em 100 quando o jogador aperta para respirar.
-- Nesse caso ele não sobe, então o InputBegan é o sinal que mantém a barra
-- visível mesmo com a respiração cheia.
if globalEnv._MoonDFAutoBreathBarInputConnection then
    pcall(function()
        globalEnv._MoonDFAutoBreathBarInputConnection:Disconnect()
    end)
end
globalEnv._MoonDFAutoBreathBarInputConnection = UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.G then
        AutoSkillSystem.breathBarLastActivity = os.clock()
    end
end)

function updateAutoBreathBar(dt)
    if not AutoSkillSystem.breathBarEnabled then
        if globalEnv._MoonDFAutoBreathBar then
            clearAutoBreathBar()
        end
        return
    end

    if not player or not player.Character then
        clearAutoBreathBar()
        return
    end

    local now = os.clock()
    local breath = AutoSkillSystem.getPlayerBreathing(player)
    if breath == nil and now >= (AutoSkillSystem.breathBarNextProbe or 0) then
        AutoSkillSystem.breathBarNextProbe = now + 0.12
        breath = AutoSkillSystem.readBreathing()
    end
    local lastBreath = AutoSkillSystem.breathBarLastValue
    local startedBreathing = breath
        and lastBreath
        and breath > lastBreath + 0.01

    -- AutoBreath indica respiração ativa mesmo quando o valor já chegou ao
    -- máximo; para respiração manual, a subida do valor marca a atividade.
    if startedBreathing or AutoSkillSystem.breathHolding then
        AutoSkillSystem.breathBarLastActivity = now
    end
    AutoSkillSystem.breathBarLastValue = breath

    local lastActivity = AutoSkillSystem.breathBarLastActivity or 0
    local breathingRecently = breath
        and lastActivity > 0
        and (now - lastActivity) <= 2.5
    if not breathingRecently then
        local oldBar = globalEnv._MoonDFAutoBreathBar
        if oldBar then
            if oldBar:IsA("GuiObject") then
                oldBar.Visible = false
            elseif oldBar:IsA("BillboardGui") then
                oldBar.Enabled = false
            elseif oldBar:IsA("Model") then
                setCharacterBreathBarVisible(oldBar, false)
            end
        end
        -- A barra fica oculta, mas conserva e atualiza o valor real da
        -- respiração para reaparecer já preenchida no próximo uso.
        if breath then
            AutoSkillSystem.breathBarDisplay = math.clamp(breath / 100, 0, 1)
        end
        return
    end

    local bar = globalEnv._MoonDFAutoBreathBar
    local barMode = AutoSkillSystem.breathBarMode or "Screen"
    local barCharacter = player.Character
    local barRoot = barCharacter and barCharacter:FindFirstChild("HumanoidRootPart")

    if barMode == "Character" then
        if not barRoot then
            if bar then
                if bar:IsA("GuiObject") then bar.Visible = false end
                if bar:IsA("BillboardGui") then bar.Enabled = false end
                if bar:IsA("Model") then setCharacterBreathBarVisible(bar, false) end
            end
            return
        end

        if bar and (bar.Parent ~= barCharacter or not bar:IsA("Model")
            or bar:GetAttribute("MoonDFWorldBreathBar") ~= true) then
            pcall(function() bar:Destroy() end)
            bar = nil
            globalEnv._MoonDFAutoBreathBar = nil
        end
        if not bar then
            bar = ensureCharacterBreathBar(
                barCharacter,
                barRoot,
                "MoonDF_AutoBreathBar",
                1.65
            )
            globalEnv._MoonDFAutoBreathBar = bar
        end

        setCharacterBreathBarVisible(bar, true)
    else
        if bar and (bar.Parent ~= screenGui or not bar:IsA("Frame")) then
            pcall(function() bar:Destroy() end)
            bar = nil
            globalEnv._MoonDFAutoBreathBar = nil
        end
        if not bar then
            bar = ensureFixedBreathBar()
            globalEnv._MoonDFAutoBreathBar = bar
        end

        -- Barra própria do Auto Regen: fixa na tela e maior que as barras
        -- comuns do ESP.
        bar.Size = UDim2.new(0, 6, 0, 110)
        bar.Position = UDim2.new(17 / 32, 0, 0.5, 0)
        bar.Visible = true
    end

    local targetPct = math.clamp(breath / 100, 0, 1)
    local currentPct = AutoSkillSystem.breathBarDisplay or 0
    local smoothing = math.clamp((dt or 0.016) * 8, 0, 1)
    AutoSkillSystem.breathBarDisplay = currentPct
        + (targetPct - currentPct) * smoothing
    setSideBarPct(bar, AutoSkillSystem.breathBarDisplay, Color3.new(1, 1, 1))
end

clearAutoBreathBar()
if globalEnv._MoonDFAutoBreathBarConnection then
    pcall(function()
        globalEnv._MoonDFAutoBreathBarConnection:Disconnect()
    end)
end
globalEnv._MoonDFAutoBreathBarConnection = RunService.Heartbeat:Connect(function(dt)
    pcall(updateAutoBreathBar, dt)
end)

function drawHealthESP()
    if not espEnabled then return end
    local myRoot = root
    local myPos = myRoot and myRoot.Position

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == player then
        else
            local char = plr.Character
            if not char then
                if espFolder then
                    local hl = espFolder:FindFirstChild("HL_" .. tostring(plr.UserId))
                    if hl then hl:Destroy() end
                end
            else
                local head = char:FindFirstChild("Head")
                local hrp = char:FindFirstChild("HumanoidRootPart")

                local inRangeBars = true
                if myPos and hrp then
                    inRangeBars = (hrp.Position - myPos).Magnitude <= ESP_MAX_DIST
                end

                local tag = head and head:FindFirstChild("MoonDFHealthESP")
                if head and not tag then
                    tag = Instance.new("BillboardGui")
                    tag.Name = "MoonDFHealthESP"
                    tag.Size = UDim2.new(0, 160, 0, 28)
                    tag.StudsOffset = Vector3.new(0, 2.8, 0)
                    tag.AlwaysOnTop = true
                    tag.MaxDistance = 0
                    tag.Parent = head

                    local txt = Instance.new("TextLabel")
                    txt.Name = "TextDisplay"
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.Font = Enum.Font.GothamBold
                    txt.TextSize = 12
                    txt.TextStrokeTransparency = 0.2
                    txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    txt.Parent = tag
                end
                if tag then
                    tag.Enabled = true
                    tag.MaxDistance = 0
                end

                local stamGui, breathGui
                if hrp then
                    stamGui = ensureSideBar(hrp, "MoonDF_StaminaBar", -1.35)
                    breathGui = ensureSideBar(hrp, "MoonDF_BreathBar", 1.35)
                    stamGui.Enabled = inRangeBars
                    breathGui.Enabled = inRangeBars
                end

                local hlName = "HL_" .. tostring(plr.UserId)
                local highlight = espFolder and espFolder:FindFirstChild(hlName)
                if not highlight and espFolder then
                    highlight = Instance.new("Highlight")
                    highlight.Name = hlName
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.FillTransparency = 0.55
                    highlight.OutlineTransparency = 0
                    highlight.Parent = espFolder
                end
                if highlight then
                    if highlight.Adornee ~= char then highlight.Adornee = char end
                    highlight.Enabled = true
                end
                local legacy = char:FindFirstChild("MoonDFHighlight")
                if legacy then legacy:Destroy() end

                local currentHp, maxHp = findRealHealthAndMax(plr)
                local healthColor
                if currentHp and maxHp and maxHp > 0 then
                    local percent = math.clamp(currentHp / maxHp, 0, 1)
                    healthColor = Color3.fromHSV(percent * 0.33, 0.95, 1)
                else
                    healthColor = Color3.fromRGB(180, 180, 200)
                end

                if tag and tag:FindFirstChild("TextDisplay") then
                    if currentHp and maxHp then
                        tag.TextDisplay.Text = string.format("%s | %d/%d", plr.DisplayName, math.floor(currentHp), math.floor(maxHp))
                    else
                        tag.TextDisplay.Text = plr.DisplayName .. " | ..."
                    end
                    tag.TextDisplay.TextColor3 = healthColor
                end

                if highlight then
                    highlight.FillColor = healthColor
                    highlight.OutlineColor = healthColor
                end

                if stamGui then
                    local cur, maxS = getPlayerStamina(plr)
                    if cur and maxS then
                        local pct = math.clamp(cur / maxS, 0, 1)
                        local col = pct > 0.4 and Color3.fromRGB(70, 220, 110)
                            or (pct > 0.2 and Color3.fromRGB(230, 200, 50) or Color3.fromRGB(230, 70, 60))
                        setSideBarPct(stamGui, pct, col)
                    else
                        setSideBarPct(stamGui, 0, Color3.fromRGB(50, 55, 60))
                    end
                end

                if breathGui then
                    local breath = AutoSkillSystem.getPlayerBreathing(plr)
                    if breath then
                        local pct = math.clamp(breath / 100, 0, 1)
                        local col = pct > 0.45 and Color3.fromRGB(70, 210, 255)
                            or (pct > 0.2 and Color3.fromRGB(255, 190, 60) or Color3.fromRGB(255, 70, 80))
                        setSideBarPct(breathGui, pct, col)
                    else
                        setSideBarPct(breathGui, 0, Color3.fromRGB(50, 55, 60))
                    end
                end
            end
        end
    end
end

function toggleESP(state)
    espEnabled = state
    globalEnv.espEnabled = state
    if state then
        if espUpdateLoop then espUpdateLoop:Disconnect() end
        if not espFolder or not espFolder.Parent then
            espFolder = Instance.new("Folder")
            espFolder.Name = "MoonDF_ESPFolder"
            pcall(function() espFolder.Parent = CoreGui end)
            if not espFolder.Parent then
                pcall(function() espFolder.Parent = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui") end)
            end
        end
        drawHealthESP()
        espUpdateLoop = RunService.Heartbeat:Connect(drawHealthESP)
    else
        if espUpdateLoop then
            espUpdateLoop:Disconnect()
            espUpdateLoop = nil
        end
        clearAllHealthESP()
    end
end

function toggleInfiniteJump(state)
    infiniteJump = state
    globalEnv.infiniteJump = state
    if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
    if infJumpRequestConn then infJumpRequestConn:Disconnect(); infJumpRequestConn = nil end
    if not state then return end

    infJumpRequestConn = UserInputService.JumpRequest:Connect(function()
        if not infiniteJump then return end
        local hum = humanoid
        local r = root
        if not hum or not r or not hum.Parent then return end
        pcall(function()
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, math.max(r.AssemblyLinearVelocity.Y, 50), r.AssemblyLinearVelocity.Z)
        end)
    end)

    infJumpConn = RunService.Heartbeat:Connect(function()
        if not infiniteJump then return end
        local hum = humanoid
        local r = root
        if not hum or not r or not hum.Parent then return end

        local holding = UserInputService:IsKeyDown(Enum.KeyCode.Space)
            or UserInputService:IsKeyDown(Enum.KeyCode.ButtonA)

        if holding then
            pcall(function()
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                local v = r.AssemblyLinearVelocity
                if v.Y < 45 then
                    r.AssemblyLinearVelocity = Vector3.new(v.X, 50, v.Z)
                end
            end)
        end
    end)
end

function processStaminaAndCombat()
    local char = character
    if not char then return end

    if infiniteStamina then
        for _, obj in ipairs(char:GetDescendants()) do
            local n = string.lower(obj.Name)
            if string.find(n, "stamina") and not string.find(n, "max") then
                if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                    local maxV = 999
                    local parent = obj.Parent
                    if parent then
                        local mx = parent:FindFirstChild("MaxStamina") or parent:FindFirstChild("Max_Stamina") or char:FindFirstChild("MaxStamina")
                        if mx and (mx:IsA("NumberValue") or mx:IsA("IntValue")) then
                            maxV = mx.Value
                        end
                    end
                    if obj.Value < maxV then
                        obj.Value = maxV
                    end
                end
            end
        end
        pcall(function()
            local names = {"Stamina", "stamina", "Stam", "CurrentStamina"}
            for _, nm in ipairs(names) do
                local v = char:GetAttribute(nm)
                if typeof(v) == "number" then
                    local mx = char:GetAttribute("MaxStamina") or char:GetAttribute("Max_Stamina") or player:GetAttribute("MaxStamina") or 100
                    if v < mx then char:SetAttribute(nm, mx) end
                end
            end
        end)
        pcall(function()
            local stam = player:FindFirstChild("Stamina") or (player:FindFirstChild("Stats") and player.Stats:FindFirstChild("Stamina"))
            if stam and (stam:IsA("NumberValue") or stam:IsA("IntValue")) then
                local mx = player:FindFirstChild("MaxStamina")
                stam.Value = (mx and mx.Value) or math.max(stam.Value, 100)
            end
        end)
    end
end

local function isCombatObject(instance)
    local name = instance and instance.Name
    if not name then return false end
    local lowerName = string.lower(name)
    return COMBAT_TAGS[name]
        or string.find(lowerName, "combat", 1, true)
        or string.find(lowerName, "aggro", 1, true)
end

local function removeCombatObject(instance)
    if not antiCombat or not instance or not instance.Parent then
        return
    end
    if isCombatObject(instance) then
        pcall(function() instance:Destroy() end)
    end
end

local function hideCombatGui(instance)
    if not antiCombat
        or not instance
        or not (instance:IsA("ImageLabel") or instance:IsA("ImageButton"))
    then
        return
    end

    local name = string.lower(instance.Name)
    if string.find(name, "skull", 1, true)
        or string.find(name, "combat", 1, true)
        or string.find(name, "caveira", 1, true)
    then
        instance.Visible = false
    end
end

local function disconnectAntiCombatListeners()
    if antiCombatCharacterConn then
        antiCombatCharacterConn:Disconnect()
        antiCombatCharacterConn = nil
    end
    if antiCombatGuiConn then
        antiCombatGuiConn:Disconnect()
        antiCombatGuiConn = nil
    end
end

local function installAntiCombatListeners()
    disconnectAntiCombatListeners()
    if not antiCombat then return end

    local char = character
    if char then
        -- Faz uma limpeza única ao ativar, em vez de varrer o personagem
        -- inteiro a cada Heartbeat.
        for _, obj in ipairs(char:GetChildren()) do
            removeCombatObject(obj)
        end
        antiCombatCharacterConn = char.ChildAdded:Connect(removeCombatObject)
    end

    local playerGui = player:FindFirstChild("PlayerGui")
        or player:WaitForChild("PlayerGui", 2)
    if playerGui then
        for _, gui in ipairs(playerGui:GetDescendants()) do
            hideCombatGui(gui)
        end
        antiCombatGuiConn = playerGui.DescendantAdded:Connect(hideCombatGui)
    end
end

function ensureStaminaCombatLoop()
    if not infiniteStamina or staminaCombatConn then return end
    staminaCombatConn = RunService.Heartbeat:Connect(function()
        if not infiniteStamina then return end
        pcall(processStaminaAndCombat)
    end)
end

function toggleInfiniteStamina(state)
    infiniteStamina = state
    globalEnv.infiniteStamina = state
    if state then
        ensureStaminaCombatLoop()
    elseif not antiCombat and staminaCombatConn then
        staminaCombatConn:Disconnect()
        staminaCombatConn = nil
    end
end

function toggleAntiCombat(state)
    antiCombat = state
    globalEnv.antiCombat = state
    if state then
        installAntiCombatListeners()
    else
        disconnectAntiCombatListeners()
        if not infiniteStamina and staminaCombatConn then
            staminaCombatConn:Disconnect()
            staminaCombatConn = nil
        end
    end
end

-- DevFX: estado + conexões empacotados (libera dezenas de registradores locais).
DevFX = DevFX or {
    spinConn = nil, discoConn = nil, moonConn = nil, iceConn = nil,
    heliConn = nil, drunkConn = nil, balloonConn = nil, rollConn = nil, hopConn = nil,
    spin = false, disco = false, moonwalk = false, giant = false, tiny = false,
    iceSlide = false, heli = false, drunk = false, balloon = false, roll = false, hop = false,
    originalSizes = {},
    iceVel = Vector3.new(40, 0, 0),
    lastWallHit = 0,
    iceSlideIntensity = (globalEnv.iceSlideIntensity or 50),
}
globalEnv.iceSlideIntensity = globalEnv.iceSlideIntensity or DevFX.iceSlideIntensity

notifyDev = function(msg)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "MOONDF Dev",
            Text = tostring(msg),
            Duration = 3,
        })
    end)
end

function copyTextToClipboard(text)
    local ok = false
    pcall(function()
        if typeof(setclipboard) == "function" then
            setclipboard(text)
            ok = true
        elseif typeof(toclipboard) == "function" then
            toclipboard(text)
            ok = true
        end
    end)
    return ok
end

function copyMobName(name)
    local exactName = tostring(name)
    local copied = copyTextToClipboard(exactName)
    notifyDev(copied and ("Nome copiado: " .. exactName) or exactName)
    print("[MOONDF] Mob:", exactName)
end

function formatNpcLogValue(value)
    local valueType = typeof(value)
    if valueType == "string" then
        return string.format("%q", value)
    elseif valueType == "Instance" then
        local ok, fullName = pcall(function() return value:GetFullName() end)
        return ok and fullName or tostring(value)
    elseif valueType == "Vector3"
        or valueType == "Vector2"
        or valueType == "CFrame"
        or valueType == "Color3"
        or valueType == "BrickColor"
        or valueType == "UDim"
        or valueType == "UDim2"
        or valueType == "Rect"
        or valueType == "Ray"
        or valueType == "Region3"
        or valueType == "EnumItem"
    then
        return tostring(value)
    elseif value == nil then
        return "nil"
    end
    return tostring(value)
end

function appendNpcLogLine(lines, key, value)
    table.insert(lines, "    " .. tostring(key) .. " = " .. formatNpcLogValue(value))
end

function appendNpcAttributes(lines, instance)
    local ok, attributes = pcall(function() return instance:GetAttributes() end)
    if not ok or type(attributes) ~= "table" then return end

    local names = {}
    for name in pairs(attributes) do table.insert(names, tostring(name)) end
    table.sort(names)
    for _, name in ipairs(names) do
        appendNpcLogLine(lines, "Attribute." .. name, attributes[name])
    end
end

function appendNpcInstanceDetails(lines, instance)
    local okClass, className = pcall(function() return instance.ClassName end)
    local okName, instanceName = pcall(function() return instance.Name end)
    local okFullName, fullName = pcall(function() return instance:GetFullName() end)
    if not (okClass and okName) then return end

    table.insert(lines, "")
    table.insert(lines, "[" .. tostring(className) .. "] " .. tostring(instanceName))
    if okFullName then appendNpcLogLine(lines, "FullName", fullName) end
    appendNpcAttributes(lines, instance)

    local okTags, tags = pcall(function()
        return game:GetService("CollectionService"):GetTags(instance)
    end)
    if okTags and #tags > 0 then
        table.sort(tags)
        appendNpcLogLine(lines, "Tags", table.concat(tags, ", "))
    end

    if instance:IsA("Model") then
        local okPrimary, primaryPart = pcall(function() return instance.PrimaryPart end)
        if okPrimary and primaryPart then appendNpcLogLine(lines, "PrimaryPart", primaryPart) end
        local okPivot, pivot = pcall(function() return instance:GetPivot() end)
        if okPivot then appendNpcLogLine(lines, "Pivot", pivot) end
    elseif instance:IsA("BasePart") then
        appendNpcLogLine(lines, "CFrame", instance.CFrame)
        appendNpcLogLine(lines, "Position", instance.Position)
        appendNpcLogLine(lines, "Size", instance.Size)
        appendNpcLogLine(lines, "Anchored", instance.Anchored)
        appendNpcLogLine(lines, "CanCollide", instance.CanCollide)
        appendNpcLogLine(lines, "CanTouch", instance.CanTouch)
        appendNpcLogLine(lines, "CanQuery", instance.CanQuery)
        appendNpcLogLine(lines, "Transparency", instance.Transparency)
        appendNpcLogLine(lines, "Material", instance.Material)
        appendNpcLogLine(lines, "Color", instance.Color)
    elseif instance:IsA("Humanoid") then
        appendNpcLogLine(lines, "Health", instance.Health)
        appendNpcLogLine(lines, "MaxHealth", instance.MaxHealth)
        appendNpcLogLine(lines, "WalkSpeed", instance.WalkSpeed)
        appendNpcLogLine(lines, "JumpPower", instance.JumpPower)
        appendNpcLogLine(lines, "JumpHeight", instance.JumpHeight)
        appendNpcLogLine(lines, "AutoRotate", instance.AutoRotate)
        appendNpcLogLine(lines, "RigType", instance.RigType)
        appendNpcLogLine(lines, "DisplayName", instance.DisplayName)
        appendNpcLogLine(lines, "Sit", instance.Sit)
        appendNpcLogLine(lines, "PlatformStand", instance.PlatformStand)
    elseif instance:IsA("ValueBase") then
        appendNpcLogLine(lines, "Value", instance.Value)
    elseif instance:IsA("ProximityPrompt") then
        appendNpcLogLine(lines, "ActionText", instance.ActionText)
        appendNpcLogLine(lines, "ObjectText", instance.ObjectText)
        appendNpcLogLine(lines, "HoldDuration", instance.HoldDuration)
        appendNpcLogLine(lines, "MaxActivationDistance", instance.MaxActivationDistance)
        appendNpcLogLine(lines, "RequiresLineOfSight", instance.RequiresLineOfSight)
        appendNpcLogLine(lines, "Enabled", instance.Enabled)
    elseif instance:IsA("ClickDetector") then
        appendNpcLogLine(lines, "MaxActivationDistance", instance.MaxActivationDistance)
    elseif instance:IsA("Sound") then
        appendNpcLogLine(lines, "SoundId", instance.SoundId)
        appendNpcLogLine(lines, "Volume", instance.Volume)
        appendNpcLogLine(lines, "PlaybackSpeed", instance.PlaybackSpeed)
        appendNpcLogLine(lines, "Playing", instance.Playing)
    elseif instance:IsA("ParticleEmitter") then
        appendNpcLogLine(lines, "Texture", instance.Texture)
        appendNpcLogLine(lines, "Rate", instance.Rate)
        appendNpcLogLine(lines, "Enabled", instance.Enabled)
    end
end

function captureNpcLogs(mobName)
    local exactName = tostring(mobName)
    local mob = findLoadedMobModel(exactName)
    if not mob then
        notifyDev("NPC não está carregado: " .. exactName)
        return false
    end

    local descendants = mob:GetDescendants()
    table.sort(descendants, function(a, b)
        local aName = a:GetFullName()
        local bName = b:GetFullName()
        return aName < bName
    end)

    local lines = {
        "========== MOONDF NPC LOG ==========",
        "CapturedAt = " .. os.date("%Y-%m-%d %H:%M:%S"),
        "NPC = " .. exactName,
        "ClassName = " .. mob.ClassName,
        "FullName = " .. mob:GetFullName(),
        "DescendantCount = " .. tostring(#descendants),
    }

    appendNpcAttributes(lines, mob)
    local humanoid = mob:FindFirstChildOfClass("Humanoid")
    if humanoid then
        table.insert(lines, "")
        table.insert(lines, "[Summary: Humanoid]")
        appendNpcLogLine(lines, "Health", humanoid.Health)
        appendNpcLogLine(lines, "MaxHealth", humanoid.MaxHealth)
        appendNpcLogLine(lines, "WalkSpeed", humanoid.WalkSpeed)
        appendNpcLogLine(lines, "RigType", humanoid.RigType)
    end

    for _, instance in ipairs(descendants) do
        appendNpcInstanceDetails(lines, instance)
    end
    table.insert(lines, "")
    table.insert(lines, "========== END NPC LOG ==========")

    globalEnv._MoonDFCapturedNpcLogs[exactName] = table.concat(lines, "\n")
    notifyDev(string.format("Logs capturados: %s (%d itens)", exactName, #descendants + 1))
    print(globalEnv._MoonDFCapturedNpcLogs[exactName])
    return true
end

function copyCapturedNpcLogs(mobName)
    local exactName = tostring(mobName)
    local logText = globalEnv._MoonDFCapturedNpcLogs[exactName]
    if not logText then
        notifyDev(T("DEV_NO_NPC_LOGS") .. ": " .. exactName)
        return false
    end

    local copied = copyTextToClipboard(logText)
    notifyDev(copied and (T("DEV_COPY_NPC_LOGS") .. ": " .. exactName) or logText)
    print("[MOONDF] NPC logs " .. (copied and "copied: " or "captured: ") .. exactName)
    return copied
end

findLoadedMobModel = function(mobName)
    local targetPlayer = Players:FindFirstChild(mobName)
    if targetPlayer and targetPlayer.Character then
        return targetPlayer.Character
    end

    local direct = workspace:FindFirstChild(mobName)
    if direct and direct:IsA("Model") then
        return direct
    end

    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant:IsA("Model") and descendant.Name == mobName
            and descendant ~= character
            and not Players:GetPlayerFromCharacter(descendant)
            and descendant:FindFirstChildOfClass("Humanoid")
            and (descendant:FindFirstChild("HumanoidRootPart")
                or descendant:FindFirstChild("Torso")
                or descendant:FindFirstChild("Head")) then
            return descendant
        end
    end
    return nil
end

function teleportToLoadedMob(mobName)
    local mob = findLoadedMobModel(mobName)
    if not mob then
        notifyDev("Mob não está carregado: " .. tostring(mobName))
        return
    end

    local mobRoot = mob:FindFirstChild("HumanoidRootPart")
        or mob:FindFirstChild("Torso")
        or mob:FindFirstChild("Head")
    local targetCFrame
    if mobRoot and mobRoot:IsA("BasePart") then
        targetCFrame = mobRoot.CFrame * CFrame.new(0, 0, 4)
    else
        local ok, pivot = pcall(function() return mob:GetPivot() end)
        if ok then targetCFrame = pivot * CFrame.new(0, 0, 4) end
    end

    if root and targetCFrame then
        root.CFrame = targetCFrame
        notifyDev("Teleportado para: " .. tostring(mobName))
    end
end

function getLoadedMobNameOptions()
    local options = {}
    rememberLoadedMobNames()
    for _, mobName in ipairs(loadedMobNames) do
        local exactName = mobName
        table.insert(options, {
            Type = "ListAuto",
            Name = exactName,
            Description = T("DEV_MOB_ACTIONS"),
            Options = {
                {
                    Type = "Single",
                    Name = T("DEV_COPY_MOB_NAME"),
                    Description = T("DEV_COPY_MOB_NAME_DESC"),
                    Callback = function()
                        copyMobName(exactName)
                    end
                },
                {
                    Type = "Single",
                    Name = T("DEV_CAPTURE_NPC_LOGS"),
                    Description = T("DEV_CAPTURE_NPC_LOGS_DESC"),
                    Callback = function()
                        captureNpcLogs(exactName)
                    end
                },
                {
                    Type = "Single",
                    Name = T("DEV_COPY_NPC_LOGS"),
                    Description = T("DEV_COPY_NPC_LOGS_DESC"),
                    Callback = function()
                        copyCapturedNpcLogs(exactName)
                    end
                },
                {
                    Type = "Single",
                    Name = T("DEV_TELEPORT_MOB"),
                    Description = T("DEV_TELEPORT_MOB_DESC"),
                    Callback = function()
                        teleportToLoadedMob(exactName)
                    end
                },
                {
                    Type = "Toggle",
                    StateKey = "DevFarmMob_" .. exactName,
                    Name = T("DEV_FARM_MOB"),
                    Description = T("DEV_FARM_MOB_DESC"),
                    OnEnable = function()
                        if findLoadedMobModel(exactName) then
                            toggleTeleport(true, exactName, "DEV")
                        else
                            notifyDev("Mob não está carregado: " .. exactName)
                        end
                    end,
                    OnDisable = function()
                        toggleTeleport(false)
                    end
                }
            }
        })
    end
    if #options == 0 then
        table.insert(options, {
            Type = "Single",
            Name = T("DEV_NO_MOBS"),
            Description = T("DEV_NO_MOBS_DESC"),
            Callback = function()
                notifyDev(T("DEV_NO_MOBS"))
            end
        })
    end
    return options
end

function copyCoordinates()
    if not root then
        notifyDev("Sem personagem / HRP")
        return
    end
    local p = root.Position
    local line = string.format("CFrame.new(%.1f, %.1f, %.1f)", p.X, p.Y, p.Z)
    local ok = false
    pcall(function()
        if typeof(setclipboard) == "function" then
            setclipboard(line)
            ok = true
        elseif typeof(toclipboard) == "function" then
            toclipboard(line)
            ok = true
        end
    end)
    notifyDev(ok and ("Copiado: " .. line) or line)
    print("[MOONDF] Coords:", line)
end

function toggleDevSpin(state)
    DevFX.spin = state
    if DevFX.spinConn then DevFX.spinConn:Disconnect(); DevFX.spinConn = nil end
    if not state then return end
    DevFX.spinConn = RunService.Heartbeat:Connect(function(dt)
        if not DevFX.spin or not root then return end
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(720 * dt), 0)
    end)
end

function toggleDevDisco(state)
    DevFX.disco = state
    if DevFX.discoConn then DevFX.discoConn:Disconnect(); DevFX.discoConn = nil end
    if not state then
        pcall(function()
            if character then
                for _, p in ipairs(character:GetDescendants()) do
                    if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                        p.Color = Color3.fromRGB(163, 162, 165)
                    end
                end
            end
        end)
        return
    end
    local t0 = tick()
    DevFX.discoConn = RunService.Heartbeat:Connect(function()
        if not DevFX.disco or not character then return end
        local h = (tick() - t0) % 1
        local c = Color3.fromHSV(h, 1, 1)
        for _, p in ipairs(character:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                p.Color = c
            end
        end
    end)
end

function toggleDevMoonwalk(state)
    DevFX.moonwalk = state
    if DevFX.moonConn then DevFX.moonConn:Disconnect(); DevFX.moonConn = nil end
    if not state then return end
    DevFX.moonConn = RunService.Heartbeat:Connect(function()
        if not DevFX.moonwalk or not humanoid or not root then return end
        local move = humanoid.MoveDirection
        if move.Magnitude > 0.05 then
            root.CFrame = CFrame.lookAt(root.Position, root.Position - move)
        end
    end)
end

function setCharacterScale(mult)
    if not character then return end
    for _, p in ipairs(character:GetDescendants()) do
        if p:IsA("BasePart") then
            if not DevFX.originalSizes[p] then
                DevFX.originalSizes[p] = p.Size
            end
            p.Size = DevFX.originalSizes[p] * mult
        end
    end
end

function restoreCharacterScale()
    for part, size in pairs(DevFX.originalSizes) do
        if part and part.Parent then
            pcall(function() part.Size = size end)
        end
    end
    DevFX.originalSizes = {}
end

function toggleDevGiant(state)
    DevFX.giant = state
    if state then
        DevFX.tiny = false
        setCharacterScale(3)
    else
        restoreCharacterScale()
    end
end

function toggleDevTiny(state)
    DevFX.tiny = state
    if state then
        DevFX.giant = false
        setCharacterScale(0.4)
    else
        restoreCharacterScale()
    end
end

function devFlingSelf()
    if not root then return end
    pcall(function()
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.Velocity = Vector3.new(math.random(-120, 120), math.random(80, 160), math.random(-120, 120))
        bv.Parent = root
        task.delay(0.35, function()
            if bv then bv:Destroy() end
        end)
    end)
    notifyDev("Whee!")
end

function devRagdollOnce()
    if not humanoid then return end
    pcall(function()
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        task.delay(1.2, function()
            if humanoid and humanoid.Parent then
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)
    end)
end

function toggleDevIceSlide(state)
    DevFX.iceSlide = state
    if DevFX.iceConn then DevFX.iceConn:Disconnect(); DevFX.iceConn = nil end
    if not state then return end

    local function baseSpeed()
        return 15 + (DevFX.iceSlideIntensity / 100) * 105
    end
    local function maxSpeed()
        return 40 + (DevFX.iceSlideIntensity / 100) * 160
    end
    local function bounceMult()
        return 1.05 + (DevFX.iceSlideIntensity / 100) * 0.9
    end
    local function bounceBoost()
        return 8 + (DevFX.iceSlideIntensity / 100) * 45
    end
    local function friction()
        return 0.25 - (DevFX.iceSlideIntensity / 100) * 0.22
    end
    local function spinRate()
        return 80 + (DevFX.iceSlideIntensity / 100) * 280
    end
    local function bounceUp()
        return 10 + (DevFX.iceSlideIntensity / 100) * 40
    end

    local ang = math.random() * math.pi * 2
    local bs = baseSpeed()
    DevFX.iceVel = Vector3.new(math.cos(ang) * bs, 0, math.sin(ang) * bs)
    DevFX.lastWallHit = 0

    DevFX.iceConn = RunService.Heartbeat:Connect(function(dt)
        if not DevFX.iceSlide or not root or not character or not humanoid then return end

        local isDown = character:FindFirstChild("Down")
            or character:FindFirstChild("Ragdoll")
            or humanoid:GetState() == Enum.HumanoidStateType.Physics
            or humanoid:GetState() == Enum.HumanoidStateType.Ragdoll
            or humanoid:GetState() == Enum.HumanoidStateType.FallingDown
            or humanoid.PlatformStand
            or humanoid.Sit

        local bs = baseSpeed()
        if not isDown then
            local move = humanoid.MoveDirection
            if move.Magnitude > 0.1 then
                DevFX.iceVel = Vector3.new(move.X, 0, move.Z).Unit * bs
            end
            return
        end

        local horiz = Vector3.new(DevFX.iceVel.X, 0, DevFX.iceVel.Z)
        if horiz.Magnitude < 5 then
            local a = math.random() * math.pi * 2
            horiz = Vector3.new(math.cos(a), 0, math.sin(a)) * bs
            DevFX.iceVel = horiz
        end

        local dir = horiz.Unit
        local origin = root.Position + Vector3.new(0, 1, 0)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { character }

        local hit = workspace:Raycast(origin, dir * 4.5, params)
        if hit and (tick() - DevFX.lastWallHit) > 0.12 then
            DevFX.lastWallHit = tick()
            local n = Vector3.new(hit.Normal.X, 0, hit.Normal.Z)
            if n.Magnitude > 0.05 then
                n = n.Unit
                local reflected = horiz - 2 * horiz:Dot(n) * n
                local speed = math.clamp(horiz.Magnitude * bounceMult() + bounceBoost(), bs * 0.8, maxSpeed())
                DevFX.iceVel = reflected.Unit * speed
                root.AssemblyLinearVelocity = Vector3.new(DevFX.iceVel.X, bounceUp(), DevFX.iceVel.Z)
            end
        else
            local speed = horiz.Magnitude
            local fr = friction()
            if speed > 8 then
                DevFX.iceVel = dir * (speed * (1 - fr * dt))
            else
                DevFX.iceVel = dir * bs
            end
            local vy = root.AssemblyLinearVelocity.Y
            root.AssemblyLinearVelocity = Vector3.new(DevFX.iceVel.X, vy, DevFX.iceVel.Z)
        end

        root.CFrame = root.CFrame * CFrame.Angles(0, 0, math.rad(spinRate() * dt))
    end)
end

function toggleDevHeli(state)
    DevFX.heli = state
    if DevFX.heliConn then DevFX.heliConn:Disconnect(); DevFX.heliConn = nil end
    if not state then return end
    DevFX.heliConn = RunService.Heartbeat:Connect(function(dt)
        if not DevFX.heli or not root then return end
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(900 * dt), 0)
        local v = root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity = Vector3.new(v.X * 0.5, 35, v.Z * 0.5)
    end)
end

function toggleDevDrunk(state)
    DevFX.drunk = state
    if DevFX.drunkConn then DevFX.drunkConn:Disconnect(); DevFX.drunkConn = nil end
    if not state then return end
    local nextJolt = 0
    DevFX.drunkConn = RunService.Heartbeat:Connect(function()
        if not DevFX.drunk or not root then return end
        if tick() > nextJolt then
            nextJolt = tick() + 0.25 + math.random() * 0.35
            local j = Vector3.new(math.random(-40, 40), math.random(-5, 15), math.random(-40, 40))
            root.AssemblyLinearVelocity = root.AssemblyLinearVelocity + j
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(math.random(-40, 40)), 0)
        end
    end)
end

function toggleDevBalloon(state)
    DevFX.balloon = state
    if DevFX.balloonConn then DevFX.balloonConn:Disconnect(); DevFX.balloonConn = nil end
    if not state then return end
    DevFX.balloonConn = RunService.Heartbeat:Connect(function(dt)
        if not DevFX.balloon or not root then return end
        local v = root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity = Vector3.new(v.X * 0.85, 18, v.Z * 0.85)
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(90 * dt), 0)
    end)
end

function toggleDevRoll(state)
    DevFX.roll = state
    if DevFX.rollConn then DevFX.rollConn:Disconnect(); DevFX.rollConn = nil end
    if not state then return end
    DevFX.rollConn = RunService.Heartbeat:Connect(function(dt)
        if not DevFX.roll or not root then return end
        root.CFrame = root.CFrame * CFrame.Angles(math.rad(540 * dt), 0, 0)
        local look = root.CFrame.LookVector
        local v = root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity = Vector3.new(look.X * 28, v.Y, look.Z * 28)
    end)
end

function toggleDevHop(state)
    DevFX.hop = state
    if DevFX.hopConn then DevFX.hopConn:Disconnect(); DevFX.hopConn = nil end
    if not state then return end
    local nextHop = 0
    DevFX.hopConn = RunService.Heartbeat:Connect(function()
        if not DevFX.hop or not root or not humanoid then return end
        if humanoid.MoveDirection.Magnitude > 0.1 and tick() > nextHop then
            nextHop = tick() + 0.28
            local v = root.AssemblyLinearVelocity
            root.AssemblyLinearVelocity = Vector3.new(v.X, 55, v.Z)
        end
    end)
end

function disconnectSpectateInputs()
    if spectateInputBegan then spectateInputBegan:Disconnect(); spectateInputBegan = nil end
    if spectateInputEnded then spectateInputEnded:Disconnect(); spectateInputEnded = nil end
    if spectateInputChanged then spectateInputChanged:Disconnect(); spectateInputChanged = nil end
end

function connectSpectateInputs()
    disconnectSpectateInputs()

    spectateInputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or not spectateToggle then return end
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            isMouseDownSpec = true
            lastMousePosSpec = UserInputService:GetMouseLocation()
        elseif input.KeyCode == Enum.KeyCode.LeftShift then
            shiftLockMode = not shiftLockMode
        end
    end)

    spectateInputEnded = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            isMouseDownSpec = false
        end
    end)

    spectateInputChanged = UserInputService.InputChanged:Connect(function(input)
        if not spectateToggle then return end
        if isMouseDownSpec and input.UserInputType == Enum.UserInputType.MouseMovement then
            local currentPos = UserInputService:GetMouseLocation()
            if lastMousePosSpec then
                local delta = currentPos - lastMousePosSpec
                cameraAngleX = cameraAngleX - delta.X * 0.4
                cameraAngleY = math.clamp(cameraAngleY + delta.Y * 0.4, -75, 75)
            end
            lastMousePosSpec = currentPos
        elseif input.UserInputType == Enum.UserInputType.MouseWheel then
            spectateDistance = math.clamp(spectateDistance - input.Position.Z * 2, 4, 40)
            globalEnv.spectateDistance = spectateDistance
        end
    end)
end

function stopSpectateCamera()
    if spectateConn then spectateConn:Disconnect(); spectateConn = nil end
    disconnectSpectateInputs()
    isMouseDownSpec = false
    shiftLockMode = false
    local cam = workspace.CurrentCamera
    if cam then
        cam.CameraType = Enum.CameraType.Custom
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            cam.CameraSubject = player.Character.Humanoid
        end
    end
end

function toggleSpectate(state, targetPlayerName)
    spectateToggle = state
    globalEnv.spectateToggle = state

    if state then
        local targetPlayer = Players:FindFirstChild(targetPlayerName)
        if not targetPlayer or not targetPlayer.Character then
            spectateToggle = false
            globalEnv.spectateToggle = false
            return
        end
        spectatePlayer = targetPlayer
        originalCFrame = root and root.CFrame or nil
        cameraAngleX = 0
        cameraAngleY = 15
        isMouseDownSpec = false
        shiftLockMode = false

        local cam = workspace.CurrentCamera
        if cam then cam.CameraType = Enum.CameraType.Scriptable end

        connectSpectateInputs()

        if spectateConn then spectateConn:Disconnect() end
        spectateConn = RunService.RenderStepped:Connect(function()
            if not spectateToggle or not spectatePlayer or not spectatePlayer.Character then return end

            local char = spectatePlayer.Character
            local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
            if not hrp then return end

            local targetPos = hrp.Position + Vector3.new(0, 2, 0)
            local cam = workspace.CurrentCamera
            if not cam then return end

            local dist = spectateDistance or 12

            if shiftLockMode then
                local lookVector = hrp.CFrame.LookVector
                local camPos = targetPos - (lookVector * dist) + Vector3.new(0, 2, 0)
                cam.CFrame = CFrame.new(camPos, targetPos)
            else
                local radX = math.rad(cameraAngleX)
                local radY = math.rad(cameraAngleY)

                local xOffset = dist * math.cos(radY) * math.sin(radX)
                local yOffset = dist * math.sin(radY)
                local zOffset = dist * math.cos(radY) * math.cos(radX)

                local heightBoost = (spectateHeight or 20) * 0.05
                local camPos = targetPos + Vector3.new(xOffset, yOffset + heightBoost, zOffset)
                cam.CFrame = CFrame.new(camPos, targetPos)
            end
        end)
    else
        stopSpectateCamera()
        spectatePlayer = nil
    end
end

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    root = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    restoreGeneralAutoRegenPosition(newChar)
    if isEnabled then
        task.defer(equipKatana)
    end
    if not flyToggle and humanoid then
        humanoid.PlatformStand = false
    end
    if flyToggle then
        if oreFarm then
            setupOreFly()
        else
            setupFly()
        end
    end
    if speedToggle then
        if speedConn then speedConn:Disconnect() end
        speedConn = RunService.Heartbeat:Connect(function() if humanoid then humanoid.WalkSpeed = walkSpeed end end)
    end
    installAntiCombatListeners()
    if infiniteJump then toggleInfiniteJump(true) end
end)

function getPlayerNames()
    local list = {}
    for _, v in pairs(Players:GetPlayers()) do if v ~= player then table.insert(list, v.Name) end end
    return list
end

-- ======================================================================
-- UI (POPUP + HUD)
-- ======================================================================

-- Empacotado para não estourar o limite de 200 registradores locais do Luau.
UILayout = UILayout or {
    isMobile = false,
    SCALE_FACTOR = 1,
    DEFAULT_WIDTH = 760,
    DEFAULT_HEIGHT = 520,
    MIN_WIDTH = 420,
    MIN_HEIGHT = 260,
    RIGHT_AREA_SCALE = 0.33,
}

function showPlatformPopup()
    local userChoice = nil
    local POPUP_W, POPUP_H = 520, 220
    local popup = new("Frame", {
        Name = "ModePopup",
        Parent = screenGui,
        AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.new(0.5, -POPUP_W/2, 0.5, -POPUP_H/2),
        Size = UDim2.new(0, POPUP_W, 0, POPUP_H),
        BackgroundColor3 = THEME.SurfaceContainer or THEME.PanelBg,
        BorderSizePixel = 0,
        ZIndex = 50
    })
    makeRound(popup, 20)
    makeStroke(popup, THEME.Outline, 1)

    new("TextLabel", {
        Parent = popup,
        Position = UDim2.new(0, 16, 0, 12),
        Size = UDim2.new(1, -32, 0, 30),
        BackgroundTransparency = 1,
        Text = T("TITLE_MAIN"),
        TextColor3 = THEME.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    new("TextLabel", {
        Parent = popup,
        Position = UDim2.new(0, 16, 0, 46),
        Size = UDim2.new(1, -32, 0, 48),
        BackgroundTransparency = 1,
        Text = "Selecione a plataforma / Select platform\nPC -> Versão normal | Mobile -> Versão compacta (toque compatível)",
        TextColor3 = THEME.SubText,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local btnContainer = new("Frame", {
        Parent = popup,
        Position = UDim2.new(0, 16, 1, -68),
        Size = UDim2.new(1, -32, 0, 52),
        BackgroundTransparency = 1
    })
    local pcBtn = new("TextButton", {
        Parent = btnContainer,
        AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0.5, -8, 1, 0),
        BackgroundColor3 = THEME.Primary,
        Text = "PC",
        TextColor3 = THEME.OnPrimary,
        Font = Enum.Font.GothamSemibold,
        TextSize = 16,
        BorderSizePixel = 0
    })
    makeRound(pcBtn, 14)
    makeStroke(pcBtn, THEME.Primary, 1)

    local mobileBtn = new("TextButton", {
        Parent = btnContainer,
        AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.new(0.5, 8, 0, 0),
        Size = UDim2.new(0.5, -8, 1, 0),
        BackgroundColor3 = THEME.PrimaryContainer or THEME.Hover,
        Text = "Mobile",
        TextColor3 = THEME.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 16,
        BorderSizePixel = 0
    })
    makeRound(mobileBtn, 14)
    makeStroke(mobileBtn, THEME.OutlineVariant, 1)

    local popupClose = new("TextButton", {
        Parent = popup,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -10, 0, 8),
        Size = UDim2.new(0, 36, 0, 28),
        BackgroundColor3 = THEME.Danger,
        Text = "X",
        TextColor3 = contrastText(THEME.Danger),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        BorderSizePixel = 0
    })
    makeRound(popupClose, 10)

    local function applyPlatformChoice(choice)
        userChoice = choice
        UILayout.isMobile = (choice == "MOBILE")
        UILayout.SCALE_FACTOR = UILayout.isMobile and 0.62 or 1.0
        if Camera and Camera.ViewportSize then
            local vx, vy = Camera.ViewportSize.X, Camera.ViewportSize.Y
            if UILayout.isMobile then
                UILayout.DEFAULT_WIDTH = math.floor(math.clamp(vx * 0.72, 280, 420))
                UILayout.DEFAULT_HEIGHT = math.floor(math.clamp(vy * 0.48, 200, 340))
                UILayout.MIN_WIDTH = 280
                UILayout.MIN_HEIGHT = 170
                UILayout.RIGHT_AREA_SCALE = 0.38
            else
                UILayout.DEFAULT_WIDTH = 760
                UILayout.DEFAULT_HEIGHT = 520
                UILayout.MIN_WIDTH = 420
                UILayout.MIN_HEIGHT = 260
                UILayout.RIGHT_AREA_SCALE = 0.33
            end
        end
        if popup and popup.Parent then popup:Destroy() end
        createHubUI()
    end

    pcBtn.MouseButton1Click:Connect(function() applyPlatformChoice("PC") end)
    mobileBtn.MouseButton1Click:Connect(function() applyPlatformChoice("MOBILE") end)
    popupClose.MouseButton1Click:Connect(function()
        for _, v in pairs(screenGui:GetDescendants()) do
            pcall(function()
                if v and v.Parent then v:Destroy() end
            end)
        end
    end)
end

function createHubUI()
    for _, v in pairs(screenGui:GetChildren()) do
        if v.Name == "MoonDF_VirginHub_Root" then
            pcall(function() v:Destroy() end)
        end
    end

    local connections = {}
    local hubVisible = true

    local miniButton = new("TextButton", {
        Name = "MiniButton",
        Parent = screenGui,
        Size = UDim2.new(0, UILayout.isMobile and 36 or 50, 0, UILayout.isMobile and 36 or 50),
        Position = UDim2.new(0.1, 0, 0.1, 0),
        BackgroundColor3 = THEME.Primary,
        BackgroundTransparency = CurrentOpacity,
        Text = "DF",
        TextColor3 = THEME.OnPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = (UILayout.isMobile and 18 or 21),
        Visible = false,
        AutoButtonColor = true,
        ZIndex = 30
    })
    makeRound(miniButton, UILayout.isMobile and 14 or 18)
    local miniStroke = makeStroke(miniButton, THEME.Primary, 1)

    local cam = workspace.CurrentCamera
    local vx = (cam and cam.ViewportSize.X) or 1280
    local vy = (cam and cam.ViewportSize.Y) or 720
    local startX = math.floor((vx - UILayout.DEFAULT_WIDTH) / 2)
    local startY = math.floor((vy - UILayout.DEFAULT_HEIGHT) / 2)

    local uiRoot = new("Frame", {
        Name = "MoonDF_VirginHub_Root",
        Parent = screenGui,
        AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.new(0, startX, 0, startY),
        Size = UDim2.new(0, UILayout.DEFAULT_WIDTH, 0, UILayout.DEFAULT_HEIGHT),
        BackgroundColor3 = THEME.Background,
        BackgroundTransparency = CurrentOpacity,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 20
    })
    makeRound(uiRoot, 22)
    local uiRootStroke = makeStroke(uiRoot, THEME.Outline, 1)

    local titleBar = new("Frame", {
        Parent = uiRoot,
        Size = UDim2.new(1, 0, 0, UILayout.isMobile and 30 or 42),
        BackgroundTransparency = 1,
        Active = true,
        ZIndex = 25
    })
    local titleAccent = new("Frame", {
        Parent = titleBar,
        Position = UDim2.new(0, 14, 1, -2),
        Size = UDim2.new(0, UILayout.isMobile and 42 or 58, 0, 2),
        BackgroundColor3 = THEME.Primary,
        BorderSizePixel = 0,
        ZIndex = 26
    })
    makeRound(titleAccent, 2)
    local titleLabel = new("TextLabel", {
        Parent = titleBar, Position = UDim2.new(0, 12, 0, UILayout.isMobile and 6 or 8), Size = UDim2.new(1, -120, 1, UILayout.isMobile and -12 or -12),
        BackgroundTransparency = 1, Text = T("TITLE_MAIN"), TextColor3 = THEME.Text,
        Font = Enum.Font.GothamBold, TextSize = (UILayout.isMobile and 13 or 18), TextXAlignment = Enum.TextXAlignment.Left
    })

    local controlsContainer = new("Frame", {
        Parent = titleBar, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0, UILayout.isMobile and 62 or 70, 0, UILayout.isMobile and 26 or 30), BackgroundTransparency = 1
    })

    local minBtn = new("TextButton", {
        Parent = controlsContainer, Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, UILayout.isMobile and 26 or 30, 0, UILayout.isMobile and 26 or 30), BackgroundColor3 = THEME.SurfaceVariant or THEME.Off,
        Text = "-", TextColor3 = THEME.Text,
        Font = Enum.Font.GothamBold, TextSize = (UILayout.isMobile and 16 or 18), BorderSizePixel = 0
    })
    makeRound(minBtn, 10)
    makeStroke(minBtn, THEME.OutlineVariant, 1)

    local closeBtn = new("TextButton", {
        Parent = controlsContainer, Position = UDim2.new(0, UILayout.isMobile and 32 or 36, 0, 0),
        Size = UDim2.new(0, UILayout.isMobile and 26 or 30, 0, UILayout.isMobile and 26 or 30), BackgroundColor3 = THEME.Danger,
        Text = "X",
        TextColor3 = contrastText(THEME.Danger),
        Font = Enum.Font.GothamBold, TextSize = (UILayout.isMobile and 12 or 14), BorderSizePixel = 0
    })
    makeRound(closeBtn, 10)

    local leftPane = new("Frame", {Parent = uiRoot, Position = UDim2.new(0, UILayout.isMobile and 6 or 10, 0, UILayout.isMobile and 36 or 56), Size = UDim2.new(0, UILayout.isMobile and 110 or 220, 1, UILayout.isMobile and -42 or -66), BackgroundTransparency = 1})
    local rightPane = new("Frame", {Parent = uiRoot, Position = UDim2.new(0, (UILayout.isMobile and 120 or 240), 0, UILayout.isMobile and 36 or 56), Size = UDim2.new(1, -(UILayout.isMobile and 126 or 250), 1, UILayout.isMobile and -42 or -66), BackgroundTransparency = 1})

    local leftBg = new("Frame", {Parent = leftPane, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = THEME.SurfaceContainer or THEME.Background, BorderSizePixel = 0, BackgroundTransparency = CurrentOpacity})
    makeRound(leftBg, 16);
    local leftStroke = makeStroke(leftBg, THEME.OutlineVariant or THEME.Border, 1)

    local topicsList = new("ScrollingFrame", {Parent = leftBg, Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(1, -16, 1, -16), BackgroundTransparency = 1, ScrollBarThickness = 0, CanvasSize = UDim2.new(0,0,0,0)})
    local topicsLayout = new("UIListLayout", {Parent = topicsList, Padding = UDim.new(0, UILayout.isMobile and 4 or 8), SortOrder = Enum.SortOrder.LayoutOrder})

    local rightBg = new("Frame", {Parent = rightPane, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = THEME.Background, BorderSizePixel = 0, BackgroundTransparency = CurrentOpacity})
    makeRound(rightBg, 16);
    local rightStroke = makeStroke(rightBg, THEME.OutlineVariant or THEME.Border, 1)

    local scroll = new("ScrollingFrame", {Parent = rightBg, Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(1, -16, 1, -16), BackgroundTransparency = 1, ScrollBarThickness = 0, CanvasSize = UDim2.new(0,0,0,0)})
    local buttonsLayout = new("UIListLayout", {Parent = scroll, Padding = UDim.new(0, UILayout.isMobile and 5 or 10)})
    buttonsLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local resizer = new("Frame", {Parent = uiRoot, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, UILayout.isMobile and -8 or -10, 1, UILayout.isMobile and -8 or -10), Size = UDim2.new(0, UILayout.isMobile and 14 or 18, 0, UILayout.isMobile and 14 or 18), BackgroundTransparency = 1})
    local resDot = new("Frame", {Parent = resizer, Size = UDim2.new(1, 1, 1, 1), BackgroundColor3 = THEME.Hover, BorderSizePixel = 0});
    makeRound(resDot, UILayout.isMobile and 6 or 6)

    MakeDraggable(titleBar, uiRoot)

    do
        local miniDragging = false
        local miniStart = nil
        local miniStartPos = nil
        local clickThreshold = 6

        miniButton.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1
                and input.UserInputType ~= Enum.UserInputType.Touch then
                return
            end
            miniDragging = true
            hubInteracting = true
            miniStart = input.Position
            miniStartPos = miniButton.Position
        end)

        UserInputService.InputChanged:Connect(function(input)
            if not miniDragging then return end
            if input.UserInputType ~= Enum.UserInputType.MouseMovement
                and input.UserInputType ~= Enum.UserInputType.Touch then
                return
            end
            local delta = input.Position - miniStart
            miniButton.Position = UDim2.new(
                miniStartPos.X.Scale, miniStartPos.X.Offset + delta.X,
                miniStartPos.Y.Scale, miniStartPos.Y.Offset + delta.Y
            )
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1
                and input.UserInputType ~= Enum.UserInputType.Touch then
                return
            end
            if not miniDragging then return end
            miniDragging = false
            hubInteracting = false
            local delta = input.Position - miniStart
            if delta.Magnitude < clickThreshold then
                hubVisible = true
                uiRoot.Visible = true
                miniButton.Visible = false
            end
        end)
    end

    local function createHamburger(parent)
        local icon = new("Frame", {Parent = parent, Size = UDim2.new(0, UILayout.isMobile and 24 or 28, 0, UILayout.isMobile and 16 or 20), BackgroundTransparency = 1})
        local barTop = new("Frame", {Parent = icon, Size = UDim2.new(1, 0, 0, 3), Position = UDim2.new(0, 0, 0, 2), BackgroundColor3 = THEME.OnSurfaceVariant or THEME.SubText, BorderSizePixel = 0});
        makeRound(barTop, 2)
        local barMid = new("Frame", {Parent = icon, Size = UDim2.new(1, 0, 0, 3), Position = UDim2.new(0, 0, 0, 8.5), BackgroundColor3 = THEME.OnSurfaceVariant or THEME.SubText, BorderSizePixel = 0});
        makeRound(barMid, 2)
        local barBot = new("Frame", {Parent = icon, Size = UDim2.new(1, 0, 0, 3), Position = UDim2.new(0, 0, 0, 15), BackgroundColor3 = THEME.OnSurfaceVariant or THEME.SubText, BorderSizePixel = 0});
        makeRound(barBot, 2)

        local function setOpen(val)
            if val then
                tween(barTop, {Position = UDim2.new(0, 0, 0, 8.5), Rotation = 45}, 0.18)
                tween(barMid, {BackgroundTransparency = 1}, 0.12)
                tween(barBot, {Position = UDim2.new(0, 0, 0, 8.5), Rotation = -45}, 0.18)
            else
                tween(barTop, {Position = UDim2.new(0, 0, 0, 2), Rotation = 0}, 0.18)
                tween(barMid, {BackgroundTransparency = 0}, 0.12)
                tween(barBot, {Position = UDim2.new(0, 0, 0, 15), Rotation = 0}, 0.18)
            end
        end
        return {Frame = icon, SetOpen = setOpen}
    end

    local function makeHoverAnimate(bg)
        local hb = new("TextButton", {Parent = bg, BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 1})
        hb.Size = UDim2.new(1, 0, 1, 0)
        table.insert(connections, hb.MouseEnter:Connect(function() if hubVisible then tween(bg, {BackgroundColor3 = THEME.Hover}, 0.12) end end))
        table.insert(connections, hb.MouseLeave:Connect(function() tween(bg, {BackgroundColor3 = THEME.Surface or THEME.PanelBg}, 0.12) end))
        return hb
    end

    local function refreshMainScroll()
        if scroll and scroll.Parent and buttonsLayout then
            scroll.CanvasSize = UDim2.new(0, 0, 0, buttonsLayout.AbsoluteContentSize.Y + 12)
        end
    end

    local function createEntry(params, parentFrame, depth, onChildrenChanged)
        depth = depth or 0
        local baseH = UILayout.isMobile and 54 or 66
        local barColor = params.Color or TYPE_COLORS[params.Type] or THEME.Accent

        local wrapper = new("Frame", {Parent = parentFrame, Name = "Entry", Size = UDim2.new(1, -12, 0, baseH), BackgroundTransparency = 1, ClipsDescendants = true})
        local entryObj = {Frame = wrapper}

        local bg = new("Frame", {
            Parent = wrapper,
            Name = "ElementBackground",
            Size = UDim2.new(1, 0, 0, baseH),
            BackgroundColor3 = THEME.Surface or THEME.PanelBg,
            BorderSizePixel = 0,
            BackgroundTransparency = CurrentOpacity
        })
        makeRound(bg, 14)
        makeStroke(bg, THEME.OutlineVariant or THEME.Border, 1)
        local accent = new("Frame", {Parent = bg, Position = UDim2.new(0, 10 + depth * 12, 0.5, UILayout.isMobile and -18 or -20), Size = UDim2.new(0, 4, 0, UILayout.isMobile and 36 or 40), BackgroundColor3 = barColor})
        makeRound(accent, 4)

        local textRightPad = UILayout.isMobile and 20 or 28
        local nameLabel = new("TextLabel", {
            Parent = bg, Position = UDim2.new(0, 28 + depth * 12, 0, UILayout.isMobile and 6 or 8),
            Size = UDim2.new(1 - UILayout.RIGHT_AREA_SCALE, -textRightPad - (depth * 12), 0, UILayout.isMobile and 16 or 20),
            BackgroundTransparency = 1, Text = params.Name or "Unnamed", TextColor3 = THEME.Text,
            Font = Enum.Font.GothamBold, TextSize = (UILayout.isMobile and 12 or 14), TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.None, ZIndex = 2
        })
        local descLabel = new("TextLabel", {
            Parent = bg, Position = UDim2.new(0, 28 + depth * 12, 0, UILayout.isMobile and 24 or 30),
            Size = UDim2.new(1 - UILayout.RIGHT_AREA_SCALE, -textRightPad - (depth * 12), 0, UILayout.isMobile and 18 or 18),
            BackgroundTransparency = 1, Text = params.Description or "", TextColor3 = THEME.SubText,
            Font = Enum.Font.Gotham, TextSize = (UILayout.isMobile and 10 or 11), TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.None, ZIndex = 2
        })

        local rightArea = new("Frame", {
            Parent = bg, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
            Size = UDim2.new(UILayout.RIGHT_AREA_SCALE, -8, 0, UILayout.isMobile and 42 or 44), BackgroundTransparency = 1, ZIndex = 5,
            ClipsDescendants = true
        })

        local childrenContainer = new("Frame", {Parent = wrapper, Position = UDim2.new(0, 0, 0, baseH), Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, ClipsDescendants = true})
        local childrenHolder = new("Frame", {Parent = childrenContainer, Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(1, -16, 1, -16), BackgroundTransparency = 1})
        local childrenLayout = new("UIListLayout", {Parent = childrenHolder, Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Top})

        local hoverBox = makeHoverAnimate(bg)

        local expanded = false
        local childRefs = {}

        local function expandTo(height)
            tween(wrapper, {Size = UDim2.new(1, -12, 0, baseH + height)}, 0.18)
            tween(childrenContainer, {Size = UDim2.new(1, 0, 0, height)}, 0.18)
            task.defer(function()
                if onChildrenChanged then onChildrenChanged() end
                refreshMainScroll()
            end)
        end

        local function collapse()
            expandTo(0)
            expanded = false
        end

        table.insert(connections, childrenLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if expanded then
                local newTarget = childrenLayout.AbsoluteContentSize.Y + 12
                expandTo(newTarget)
            end
        end))

        local function buildChildren(list)
            for _, c in pairs(childRefs) do if c and c.Frame then c.Frame:Destroy() end end
            childRefs = {}
            if type(list) == "function" then
                local ok, resolved = pcall(list)
                list = ok and resolved or {}
            end
            for _, childParam in ipairs(list or {}) do
                local child = createEntry(childParam, childrenHolder, depth + 1, function()
                    if expanded then
                        local newTarget = childrenLayout.AbsoluteContentSize.Y + 12
                        expandTo(newTarget)
                    end
                end)
                table.insert(childRefs, child)
            end
            task.wait()
            local target = childrenLayout.AbsoluteContentSize.Y + 12
            expandTo(target)
            expanded = true
        end

        if params.Type == "Label" then
        elseif params.Type == "Toggle" then
            local state = false
            if params.StateKey then state = globalEnv._HubStates[params.StateKey] or false end
            local baseKnobW = UILayout.isMobile and 40 or 46
            local baseKnobH = UILayout.isMobile and 22 or 26
            local baseSub = UILayout.isMobile and 16 or 18
            local basePad = UILayout.isMobile and 3 or 4

            local knob = new("Frame", {
                Parent = rightArea,
                AnchorPoint = Vector2.new(1, 0.5),
                Size = UDim2.new(0, baseKnobW, 0, baseKnobH),
                Position = UDim2.new(1, -2, 0.5, 0),
                BackgroundColor3 = THEME.Off
            })
            makeRound(knob, 14)
            makeStroke(knob, THEME.OutlineVariant or THEME.Border, 1)
            local subKnob = new("Frame", {
                Parent = knob,
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0, baseSub, 0, baseSub),
                Position = UDim2.new(0, basePad, 0.5, 0),
                BackgroundColor3 = THEME.KnobColor or Color3.new(1, 1, 1)
            })
            makeRound(subKnob, 999)

            local curKnobW, curKnobH, curSub, curPad = baseKnobW, baseKnobH, baseSub, basePad

            local function layoutToggle()
                local areaW = math.max(0, rightArea.AbsoluteSize.X)
                local areaH = math.max(0, rightArea.AbsoluteSize.Y)
                local maxW = math.max(24, areaW - 4)
                local maxH = math.max(14, areaH - 4)
                curKnobW = math.min(baseKnobW, maxW)
                curKnobH = math.min(baseKnobH, maxH)
                local scale = math.min(curKnobW / baseKnobW, curKnobH / baseKnobH)
                curSub = math.max(10, math.floor(baseSub * scale + 0.5))
                curPad = math.max(2, math.floor(basePad * scale + 0.5))
                if curSub + curPad * 2 > curKnobW then
                    curSub = math.max(8, curKnobW - curPad * 2)
                end

                knob.Size = UDim2.new(0, curKnobW, 0, curKnobH)
                knob.Position = UDim2.new(1, -2, 0.5, 0)
                subKnob.Size = UDim2.new(0, curSub, 0, curSub)
                if state then
                    subKnob.Position = UDim2.new(1, -(curSub + curPad), 0.5, 0)
                    subKnob.AnchorPoint = Vector2.new(0, 0.5)
                else
                    subKnob.Position = UDim2.new(0, curPad, 0.5, 0)
                    subKnob.AnchorPoint = Vector2.new(0, 0.5)
                end
            end

            local function applyVisual(s)
                if s then
                    tween(knob, {BackgroundColor3 = THEME.On}, 0.15)
                    tween(subKnob, {BackgroundColor3 = THEME.OnPrimary or THEME.KnobColor}, 0.15)
                    tween(subKnob, {Position = UDim2.new(1, -(curSub + curPad), 0.5, 0)}, 0.15)
                    tween(bg, {BackgroundColor3 = THEME.Hover}, 0.15)
                else
                    tween(knob, {BackgroundColor3 = THEME.Off}, 0.15)
                    tween(subKnob, {BackgroundColor3 = THEME.KnobColor or Color3.new(1, 1, 1)}, 0.15)
                    tween(subKnob, {Position = UDim2.new(0, curPad, 0.5, 0)}, 0.15)
                    tween(bg, {BackgroundColor3 = THEME.Surface or THEME.PanelBg}, 0.15)
                end
            end
            local function applyState(s)
                state = s
                if params.StateKey then globalEnv._HubStates[params.StateKey] = state end
                applyVisual(state)
                if state then
                    if params.OnEnable then pcall(params.OnEnable) end
                else
                    if params.OnDisable then pcall(params.OnDisable) end
                end
            end
            table.insert(connections, rightArea:GetPropertyChangedSignal("AbsoluteSize"):Connect(layoutToggle))
            task.defer(layoutToggle)
            applyVisual(state)
            table.insert(connections, hoverBox.MouseButton1Click:Connect(function() if hubVisible then applyState(not state) end end))

        elseif params.Type == "Single" then
            table.insert(connections, hoverBox.MouseButton1Click:Connect(function()
                if hubVisible then
                    tween(bg, {BackgroundColor3 = THEME.Hover}, 0.06);
                    task.wait(0.06); tween(bg, {BackgroundColor3 = THEME.Surface or THEME.PanelBg}, 0.12)
                    if params.Callback then pcall(params.Callback) end
                end
            end))

        elseif params.Type == "InputImmediate" then
            local txtBox = new("TextBox", {Parent = rightArea, Size = UDim2.new(1, -76, 0, UILayout.isMobile and 30 or 32), Position = UDim2.new(0, 0, 0.5, UILayout.isMobile and -15 or -16), BackgroundColor3 = THEME.SurfaceVariant or THEME.Background, Text = "", PlaceholderText = params.Placeholder or "...", TextColor3 = THEME.Text, Font = Enum.Font.Gotham, TextSize = (UILayout.isMobile and 12 or 14), ClearTextOnFocus = false, ZIndex = 6});
            makeRound(txtBox, 10)
            makeStroke(txtBox, THEME.OutlineVariant or THEME.Border, 1)

            local okBtn = new("TextButton", {
                Parent = rightArea,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.new(0, UILayout.isMobile and 60 or 68, 0, UILayout.isMobile and 30 or 32),
                BackgroundColor3 = THEME.Primary or THEME.Accent,
                Text = "OK",
                TextColor3 = THEME.OnPrimary or Color3.new(1, 1, 1),
                Font = Enum.Font.GothamBold,
                TextSize = (UILayout.isMobile and 12 or 14),
                ZIndex = 6
            })
            makeRound(okBtn, 10)
            makeStroke(okBtn, THEME.Primary, 1)

            table.insert(connections, okBtn.MouseButton1Click:Connect(function() if hubVisible and params.Callback then params.Callback(txtBox.Text) end end))
            table.insert(connections, txtBox.FocusLost:Connect(function(enter) if enter and hubVisible and params.Callback then params.Callback(txtBox.Text) end end))

        elseif params.Type == "InputSelect" then
            local txtBox = new("TextBox", {Parent = rightArea, Size = UDim2.new(1, 0, 0, UILayout.isMobile and 30 or 32), Position = UDim2.new(0, 0, 0.5, UILayout.isMobile and -15 or -16), BackgroundColor3 = THEME.SurfaceVariant or THEME.Background, Text = params.Default or "", PlaceholderText = params.Placeholder or "...", TextColor3 = THEME.Text, Font = Enum.Font.Gotham, TextSize = (UILayout.isMobile and 12 or 14), ClearTextOnFocus = true, ZIndex = 6});
            makeRound(txtBox, 10)
            makeStroke(txtBox, THEME.OutlineVariant or THEME.Border, 1)
            table.insert(connections, txtBox.FocusLost:Connect(function() if params.StateKey then globalEnv._HubSelections[params.StateKey] = txtBox.Text end end))

        elseif params.Type == "ListAuto" or params.Type == "Container" then
            local ham = createHamburger(rightArea)
            ham.Frame.Position = UDim2.new(1, UILayout.isMobile and -24 or -28, 0, UILayout.isMobile and 6 or 8)
            table.insert(connections, hoverBox.MouseButton1Click:Connect(function()
                if not hubVisible then return end
                if not expanded then
                    buildChildren(params.Options or params.Children or {})
                    ham.SetOpen(true)
                else
                    collapse()
                    ham.SetOpen(false)
                end
            end))

        elseif params.Type == "ListPersistent" then
            local ham = createHamburger(rightArea)
            ham.Frame.Position = UDim2.new(1, UILayout.isMobile and -24 or -28, 0, UILayout.isMobile and 6 or 8)
            local selectedValLabel = new("TextLabel", {Parent = bg, BackgroundTransparency = 1, TextColor3 = THEME.Text, Font = Enum.Font.GothamSemibold, TextSize = (UILayout.isMobile and 13 or 15), TextXAlignment = Enum.TextXAlignment.Left, Text = "", ZIndex = 2})

            local function updateSelectedLabelPos()
                local bounds = nameLabel.TextBounds
                selectedValLabel.Position = UDim2.new(0, 28 + depth * 12 + bounds.X + 4, 0, UILayout.isMobile and 6 or 8)
                selectedValLabel.Size = UDim2.new(0, UILayout.isMobile and 100 or 200, 0, UILayout.isMobile and 16 or 20)
            end
            updateSelectedLabelPos()
            nameLabel:GetPropertyChangedSignal("TextBounds"):Connect(updateSelectedLabelPos)

            if params.StateKey then
                local storedVal = globalEnv._HubSelections[params.StateKey]
                if storedVal then
                    selectedValLabel.Text = ": " .. storedVal
                    updateSelectedLabelPos()
                end
            end

            table.insert(connections, hoverBox.MouseButton1Click:Connect(function()
                if not hubVisible then return end
                if not expanded then
                    local opts = {}
                    for _, opt in ipairs(params.Options or {}) do
                        local customColor = nil
                        if THEME_PRESETS[opt] then customColor = THEME_PRESETS[opt].Accent end

                        table.insert(opts, {
                            Type = "Single", Name = opt, Description = "", Color = customColor,
                            Callback = function()
                                selectedValLabel.Text = ": " .. opt
                                updateSelectedLabelPos()
                                if params.StateKey then globalEnv._HubSelections[params.StateKey] = opt end
                                if params.Callback then params.Callback(opt) end
                                collapse()
                                ham.SetOpen(false)
                            end
                        })
                    end
                    buildChildren(opts)
                    ham.SetOpen(true)
                else
                    collapse()
                    ham.SetOpen(false)
                end
            end))

        elseif params.Type == "Slider" or params.Type == "Intensity" then
            local minV = tonumber(params.Min) or 0
            local maxV = tonumber(params.Max) or 100
            if maxV < minV then maxV = minV end
            local step = params.Step and tonumber(params.Step) or nil
            local key = params.StateKey or params.Name or ("Slider_"..tostring(math.random(100000,999999)))

            local cur = globalEnv._ScriptHubStates[key] ~= nil and globalEnv._ScriptHubStates[key] or (params.Default ~= nil and tonumber(params.Default) or minV)
            cur = clamp(math.floor(cur + 0.5), minV, maxV)
            local SOFT_MIN_TRACK = UILayout.isMobile and 36 or 52
            local valWFull = UILayout.isMobile and 32 or 52
            local trackPad = UILayout.isMobile and 3 or 6
            local knobSize = UILayout.isMobile and 12 or 16
            local trackH = UILayout.isMobile and 6 or 8
            local knobYOff = UILayout.isMobile and -6 or -8
            local valLabelH = UILayout.isMobile and 14 or 18

            local track = new("Frame", {Parent = rightArea, Size = UDim2.new(1, -(valWFull + trackPad + 4), 0, trackH), Position = UDim2.new(0, trackPad, 0.5, -trackH/2), BackgroundColor3 = THEME.SurfaceVariant or THEME.Off, BorderSizePixel = 0})
            makeRound(track, 6)
            local fill = new("Frame", {Parent = track, Size = UDim2.new(0,0,1,0), Position = UDim2.new(0,0,0,0), BackgroundColor3 = THEME.Primary or THEME.Accent, BorderSizePixel = 0})
            makeRound(fill, 6)
            local knob = new("Frame", {Parent = rightArea, Size = UDim2.new(0, knobSize, 0, knobSize), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, trackPad, 0.5, 0), BackgroundColor3 = (THEME.KnobColor or Color3.fromRGB(245,245,245)), BorderSizePixel = 0})
            makeRound(knob, 999)
            makeStroke(knob, THEME.Primary or THEME.Accent, 1)
            knob.Active = true
            local valLabel = new("TextLabel", {Parent = rightArea, AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1, -1, 0.5, 0), Size = UDim2.new(0, valWFull, 0, valLabelH), BackgroundTransparency = 1, Text = tostring(cur), TextColor3 = THEME.SubText, Font = Enum.Font.GothamBold, TextSize = (UILayout.isMobile and 10 or 12), TextXAlignment = Enum.TextXAlignment.Right})
            track.Active = true
            fill.Active = true

            local function layoutTrack()
                local areaW = math.max(0, rightArea.AbsoluteSize.X)
                local edgePad = UILayout.isMobile and 2 or 6
                local maxTrackPossible = math.max(0, areaW - trackPad - edgePad)

                local useValW = valWFull
                local remainingForTrack = maxTrackPossible - useValW - 2
                if remainingForTrack < SOFT_MIN_TRACK then
                    useValW = math.max(0, maxTrackPossible - SOFT_MIN_TRACK - 2)
                    if useValW < 12 then
                        useValW = 0
                        valLabel.Visible = false
                    else
                        valLabel.Visible = true
                        valLabel.Size = UDim2.new(0, useValW, 0, valLabelH)
                    end
                else
                    valLabel.Visible = true
                    valLabel.Size = UDim2.new(0, useValW, 0, valLabelH)
                end

                local trackW = math.max(0, maxTrackPossible - (valLabel.Visible and (useValW + 2) or 0))
                trackW = math.min(trackW, maxTrackPossible)
                track.Size = UDim2.new(0, trackW, 0, trackH)
                track.Position = UDim2.new(0, trackPad, 0.5, -trackH/2)
                return trackW
            end

            local function updateVisuals(instant)
                local trackW = layoutTrack()
                local areaW = math.max(0, rightArea.AbsoluteSize.X)
                local pct = 0
                if maxV > minV then pct = (cur - minV) / (maxV - minV) end
                local fillW = math.floor(trackW * pct + 0.5)
                fillW = clamp(fillW, 0, trackW)

                local kSize = knobSize
                local availForKnob = math.max(8, areaW - 4)
                if availForKnob < knobSize then
                    kSize = math.max(8, math.floor(availForKnob))
                end
                if math.abs(knob.Size.X.Offset - kSize) > 0.5 then
                    knob.Size = UDim2.new(0, kSize, 0, kSize)
                end

                local half = kSize / 2
                local desired = trackPad + fillW
                local knobX = clamp(desired, half, math.max(half, areaW - half))

                if instant then
                    fill.Size = UDim2.new(0, fillW, 1, 0)
                    knob.Position = UDim2.new(0, knobX, 0.5, 0)
                else
                    tween(fill, {Size = UDim2.new(0, fillW, 1, 0)}, 0.12)
                    tween(knob, {Position = UDim2.new(0, knobX, 0.5, 0)}, 0.12)
                end
                valLabel.Text = tostring(cur)
            end
            local function fireChange()
                globalEnv._ScriptHubStates[key] = cur
                if params.OnChange then
                    pcall(function() params.OnChange(cur) end)
                end
            end
            local function xToValue(absX)
                local tx = track.AbsolutePosition.X
                local tw = track.AbsoluteSize.X
                if tw <= 0 then return cur end
                local rel = (absX - tx) / math.max(1, tw)
                rel = clamp(rel, 0, 1)
                local raw = minV + (rel * (maxV - minV))
                if step and step > 0 then
                    raw = math.floor((raw / step) + 0.5) * step
                end
                return clamp(math.floor(raw + 0.5), minV, maxV)
            end
            table.insert(connections, track:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() updateVisuals(true) end))
            table.insert(connections, rightArea:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() updateVisuals(true) end))
            task.defer(function() updateVisuals(true) end)
            local dragging = false
            local dragConnChanged, dragConnEnded
            table.insert(connections, knob.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    hubInteracting = true
                    dragConnChanged = UserInputService.InputChanged:Connect(function(inp)
                        if not dragging then return end
                        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                            local pos = inp.Position or UserInputService:GetMouseLocation()
                            local v = xToValue(pos.X)
                            if v ~= cur then
                                cur = v
                                updateVisuals(false)
                                fireChange()
                            end
                        end
                    end)
                    dragConnEnded = UserInputService.InputEnded:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                            dragging = false
                            hubInteracting = false
                            if dragConnChanged then dragConnChanged:Disconnect(); dragConnChanged = nil end
                            if dragConnEnded then dragConnEnded:Disconnect(); dragConnEnded = nil end
                        end
                    end)
                    table.insert(connections, dragConnChanged); table.insert(connections, dragConnEnded)
                end
            end))
            table.insert(connections, track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local posX = (input.Position and input.Position.X) or UserInputService:GetMouseLocation().X
                    local v = xToValue(posX)
                    if v ~= cur then
                        cur = v
                        updateVisuals(false)
                        fireChange()
                    end
                end
            end))
            table.insert(connections, fill.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local posX = (input.Position and input.Position.X) or UserInputService:GetMouseLocation().X
                    local v = xToValue(posX)
                    if v ~= cur then
                        cur = v
                        updateVisuals(false)
                        fireChange()
                    end
                end
            end))
            valLabel.Active = true
            entryObj.Get = function() return cur end
            entryObj.Set = function(v)
                cur = clamp(math.floor(tonumber(v) or minV + 0.5), minV, maxV)
                updateVisuals(false)
                fireChange()
            end
        end

        return entryObj
    end

    local togglesCreated = {}
    local topicButtons = {}
    local topicItemsMap = {}
    local selectedTopicKey = nil

    local function setTopicSelected(key)
        selectedTopicKey = key
        -- Texto permanece THEME.Text (não inverte contraste no selecionado)
        for k, b in pairs(topicButtons) do
            if k == key then
                tween(b, {BackgroundColor3 = THEME.Primary or THEME.Accent}, 0.12)
                b.TextColor3 = THEME.Text
            else
                tween(b, {BackgroundColor3 = THEME.Surface or THEME.PanelBg}, 0.12)
                b.TextColor3 = THEME.Text
            end
        end
    end

    local function selectTopic(key)
        if not key or not topicItemsMap[key] then return end
        if not uiRoot or not uiRoot.Parent or not uiRoot.Visible then return end
        for _, c in pairs(scroll:GetChildren()) do
            if c:IsA("Frame") and c.Name == "Entry" then c:Destroy() end
        end
        local items = topicItemsMap[key]
        togglesCreated[key] = togglesCreated[key] or {}
        for _, it in ipairs(items) do
            createEntry(it, scroll, 0)
        end
        setTopicSelected(key)
        refreshMainScroll()
    end

    local function addTopic(key, label, items)
        local btn = new("TextButton", {
            Parent = topicsList,
            Size = UDim2.new(1, 0, 0, UILayout.isMobile and 36 or 42),
            BackgroundColor3 = THEME.Surface or THEME.PanelBg,
            BorderSizePixel = 0,
            Text = label,
            TextColor3 = THEME.Text,
            Font = Enum.Font.GothamSemibold,
            TextSize = (UILayout.isMobile and 12 or 14),
            BackgroundTransparency = CurrentOpacity
        })
        makeRound(btn, 12)
        makeStroke(btn, THEME.OutlineVariant or THEME.Border, 1)
        topicButtons[key] = btn
        topicItemsMap[key] = items

        table.insert(connections, btn.MouseEnter:Connect(function()
            if selectedTopicKey ~= key then
                tween(btn, {BackgroundColor3 = THEME.Hover}, 0.12)
            end
        end))
        table.insert(connections, btn.MouseLeave:Connect(function()
            if selectedTopicKey ~= key then
                tween(btn, {BackgroundColor3 = THEME.Surface or THEME.PanelBg}, 0.12)
            end
        end))

        table.insert(connections, btn.MouseButton1Click:Connect(function()
            selectTopic(key)
        end))
    end

    local function updateLayout()
        local totalW = uiRoot.AbsoluteSize.X
        local leftWidth = math.clamp(math.floor(totalW * (UILayout.isMobile and 0.28 or 0.26)), 120, 320)
        leftWidth = math.min(leftWidth, math.max(100, totalW - 160))
        leftPane.Size = UDim2.new(0, leftWidth, 1, UILayout.isMobile and -48 or -66)
        local rightX = leftWidth + 20
        rightPane.Position = UDim2.new(0, rightX, 0, UILayout.isMobile and 42 or 56)
        rightPane.Size = UDim2.new(0, totalW - rightX - 10, 1, UILayout.isMobile and -48 or -66)
        refreshMainScroll()
    end

    table.insert(connections, uiRoot:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateLayout))
    table.insert(connections, topicsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        topicsList.CanvasSize = UDim2.new(0, 0, 0, topicsLayout.AbsoluteContentSize.Y + 12)
    end))
    table.insert(connections, buttonsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshMainScroll))

    task.defer(updateLayout)

    local function toggleHub()
        hubVisible = not hubVisible
        uiRoot.Visible = hubVisible
        miniButton.Visible = not hubVisible
    end

    table.insert(connections, minBtn.MouseButton1Click:Connect(toggleHub))
    table.insert(connections, closeBtn.MouseButton1Click:Connect(function()
        for _, conn in pairs(connections) do pcall(function() conn:Disconnect() end) end
        screenGui:Destroy()
    end))

    table.insert(connections, UserInputService.InputBegan:Connect(function(input, gp)
        if input.KeyCode == Enum.KeyCode.RightControl then
            toggleHub()
        end
    end))

    local resizing, startSize, startMouse = false, nil, nil
    table.insert(connections, resizer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            hubInteracting = true
            startSize = uiRoot.Size
            local m = input.Position or UserInputService:GetMouseLocation()
            startMouse = Vector2.new(m.X, m.Y)
        end
    end))
    table.insert(connections, UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local m = input.Position or UserInputService:GetMouseLocation()
            local d = Vector2.new(m.X, m.Y) - startMouse
            uiRoot.Size = UDim2.new(0, math.max(UILayout.MIN_WIDTH, startSize.X.Offset + d.X), 0, math.max(UILayout.MIN_HEIGHT, startSize.Y.Offset + d.Y))
        end
    end))
    table.insert(connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = false
            hubInteracting = false
        end
    end))

    function initTopics()
        local previousKey = selectedTopicKey

        for _, v in pairs(topicsList:GetChildren()) do
            if v:IsA("TextButton") then v:Destroy() end
        end
        for _, c in pairs(scroll:GetChildren()) do
            if c:IsA("Frame") and c.Name == "Entry" then c:Destroy() end
        end
        topicButtons = {}
        topicItemsMap = {}

        uiRoot.BackgroundColor3 = THEME.Background
        leftBg.BackgroundColor3 = THEME.SurfaceContainer or THEME.Background
        rightBg.BackgroundColor3 = THEME.Background
        miniButton.BackgroundColor3 = THEME.Primary or THEME.Background
        miniButton.BackgroundTransparency = CurrentOpacity
        miniButton.TextColor3 = THEME.OnPrimary or THEME.Accent
        miniStroke.Color = THEME.Primary or THEME.Accent
        minBtn.BackgroundColor3 = THEME.SurfaceVariant or THEME.Off
        minBtn.TextColor3 = THEME.Text
        closeBtn.BackgroundColor3 = THEME.Danger
        closeBtn.TextColor3 = contrastText(THEME.Danger)
        titleLabel.TextColor3 = THEME.Text
        titleAccent.BackgroundColor3 = THEME.Primary or THEME.Accent
        uiRootStroke.Color = THEME.Outline or THEME.Border
        leftStroke.Color = THEME.OutlineVariant or THEME.Border
        rightStroke.Color = THEME.OutlineVariant or THEME.Border

        titleLabel.Text = T("TITLE_MAIN")

        addTopic("GENERAL", T("TOPIC_GENERAL"), {
            { Type = "Single", Name = T("EMERGENCY"), Description = T("EMERGENCY_DESC"), Callback = emergencyStop },
            { Type = "Single", Name = T("SERVER_HOP"), Description = T("SERVER_HOP_DESC"), Callback = serverHopLowestPing },
            { Type = "ListAuto", Name = T("FLY_SPEED"), Description = T("FLY_SPEED_DESC"), Options = {
                { Type = "Toggle", StateKey = "EnableFly", Name = T("ENABLE_FLY"), Description = T("ENABLE_FLY_DESC"), OnEnable = function() flyToggle = true globalEnv.flyToggle = true setupFly() end, OnDisable = function() flyToggle = false globalEnv.flyToggle = false if bg then bg:Destroy() end if bv then bv:Destroy() end if flyConn then flyConn:Disconnect() end humanoid.PlatformStand = false end },
                { Type = "Slider", StateKey = "FlySpeedValue", Name = T("FLY_SPEED_SLIDER"), Description = T("FLY_SPEED_SLIDER_DESC"), Min = 0, Max = 10000, Default = 150, OnChange = function(v) flySpeedValue = v globalEnv.flySpeedValue = v end },
                { Type = "Toggle", StateKey = "EnableSpeed", Name = T("ENABLE_SPEED"), Description = T("ENABLE_SPEED_DESC"), OnEnable = function() speedToggle = true globalEnv.speedToggle = true if speedConn then speedConn:Disconnect() end speedConn = RunService.Heartbeat:Connect(function() if humanoid then humanoid.WalkSpeed = walkSpeed end end) end, OnDisable = function() speedToggle = false globalEnv.speedToggle = false if speedConn then speedConn:Disconnect() end humanoid.WalkSpeed = BASE_WALKSPEED end },
                { Type = "Slider", StateKey = "WalkSpeed", Name = T("SPEED_VALUE_SLIDER"), Description = T("SPEED_VALUE_SLIDER_DESC"), Min = 16, Max = 500, Default = 16, OnChange = function(v) walkSpeed = v globalEnv.walkSpeed = v end }
            }},
            { Type = "ListAuto", Name = T("AUTO_REGEN"), Description = T("AUTO_REGEN_DESC"), Options = {
                { Type = "Toggle", StateKey = "GeneralAutoRegen", Name = T("AUTO_REGEN"), Description = T("AUTO_REGEN_DESC"), OnEnable = function() toggleGeneralAutoRegen(true) end, OnDisable = function() toggleGeneralAutoRegen(false) end },
                { Type = "Single", Name = T("AUTO_REGEN_MANUAL_RESPAWN"), Description = T("AUTO_REGEN_MANUAL_RESPAWN_DESC"), Callback = respawnCharacterOnce },
                { Type = "Slider", StateKey = "GeneralAutoRegenThreshold", Name = T("AUTO_REGEN_THRESHOLD"), Description = T("AUTO_REGEN_THRESHOLD_DESC"), Min = 1, Max = 200, Default = generalAutoRegenThreshold, OnChange = function(v)
                    generalAutoRegenThreshold = math.max(1, tonumber(v) or 60)
                    globalEnv.generalAutoRegenThreshold = generalAutoRegenThreshold
                end },
                { Type = "Toggle", StateKey = "AutoRegenHealthESP", Name = T("AUTO_REGEN_ESP"), Description = T("AUTO_REGEN_ESP_DESC"), OnEnable = function() toggleAutoRegenHealthESP(true) end, OnDisable = function() toggleAutoRegenHealthESP(false) end },
                { Type = "Toggle", StateKey = "AutoRegenBreathBarCharacterMode", Name = T("AUTO_REGEN_BREATH_BAR_CHARACTER"), Description = T("AUTO_REGEN_BREATH_BAR_CHARACTER_DESC"),
                    OnEnable = function()
                        setAutoBreathBarMode("Character")
                        if not AutoSkillSystem.breathBarEnabled then
                            toggleAutoBreathBar(true)
                        end
                    end,
                    OnDisable = function()
                        if AutoSkillSystem.breathBarMode == "Character" then
                            toggleAutoBreathBar(false)
                        end
                    end
                },
                { Type = "Toggle", StateKey = "AutoRegenBreathBarScreenMode", Name = T("AUTO_REGEN_BREATH_BAR_SCREEN"), Description = T("AUTO_REGEN_BREATH_BAR_SCREEN_DESC"),
                    OnEnable = function()
                        setAutoBreathBarMode("Screen")
                        if not AutoSkillSystem.breathBarEnabled then
                            toggleAutoBreathBar(true)
                        end
                    end,
                    OnDisable = function()
                        if AutoSkillSystem.breathBarMode == "Screen" then
                            toggleAutoBreathBar(false)
                        end
                    end
                }
            }},
            { Type = "ListAuto", Name = T("EXTRAS"), Description = T("EXTRAS_DESC"), Options = {
                { Type = "Toggle", StateKey = "ClickTP", Name = T("CLICK_TP"), Description = T("CLICK_TP_DESC"), OnEnable = function() toggleClickTP(true) end, OnDisable = function() toggleClickTP(false) end },
                { Type = "Toggle", StateKey = "NoClip", Name = T("NO_CLIP"), Description = T("NO_CLIP_DESC"), OnEnable = function() toggleNoclip(true) end, OnDisable = function() toggleNoclip(false) end },
                { Type = "Toggle", StateKey = "NoFog", Name = T("NO_FOG"), Description = T("NO_FOG_DESC"), OnEnable = function() applyNoFog(true) end, OnDisable = function() applyNoFog(false) end },
                { Type = "Toggle", StateKey = "UltraLite", Name = T("ULTRA_LITE"), Description = T("ULTRA_LITE_DESC"), OnEnable = function() toggleUltraLite(true) end, OnDisable = function() toggleUltraLite(false) end },
                { Type = "Toggle", StateKey = "InfiniteJump", Name = T("INFINITE_JUMP"), Description = T("INFINITE_JUMP_DESC"), OnEnable = function() toggleInfiniteJump(true) end, OnDisable = function() toggleInfiniteJump(false) end },
                { Type = "Toggle", StateKey = "InfiniteStamina", Name = T("INFINITE_STAMINA"), Description = T("INFINITE_STAMINA_DESC"), OnEnable = function() toggleInfiniteStamina(true) end, OnDisable = function() toggleInfiniteStamina(false) end },
                { Type = "Toggle", StateKey = "AntiCombat", Name = T("ANTI_COMBAT"), Description = T("ANTI_COMBAT_DESC"), OnEnable = function() toggleAntiCombat(true) end, OnDisable = function() toggleAntiCombat(false) end },
                { Type = "Toggle", StateKey = "IceSlide", Name = T("ICE_SLIDE"), Description = T("ICE_SLIDE_DESC"), OnEnable = function() toggleDevIceSlide(true) end, OnDisable = function() toggleDevIceSlide(false) end },
                { Type = "Slider", StateKey = "IceSlideIntensity", Name = T("ICE_INTENSITY"), Description = T("ICE_INTENSITY_DESC"), Min = 1, Max = 100, Default = DevFX.iceSlideIntensity or 50, OnChange = function(v) DevFX.iceSlideIntensity = v; globalEnv.iceSlideIntensity = v end }
            }}
        })

        local mobFarmOptions = {}
        for _, mob in ipairs(FARM) do
            table.insert(mobFarmOptions, { Type = "Toggle", StateKey = "Farm" .. mob, Name = T("FARM") .. " " .. mob, Description = T("FARM_DESC"), OnEnable = function() toggleTeleport(true, mob, "FARM") end, OnDisable = function() toggleTeleport(false) end })
        end

        local castleFarmOptions = {
            { Type = "Toggle", StateKey = "FarmCastleGeneral", Name = T("FARM_CASTLE_GENERAL"), Description = T("FARM_CASTLE_GENERAL_DESC"), OnEnable = function()
                toggleTeleport(true, CASTLE_GENERAL_TARGET, "FARM")
            end, OnDisable = function()
                toggleTeleport(false)
            end },
            { Type = "Toggle", StateKey = "FarmCastleAkaza", Name = T("FARM") .. " Akaza", Description = T("FARM_DESC"), OnEnable = function()
                toggleTeleport(true, "Akaza", "FARM")
            end, OnDisable = function()
                toggleTeleport(false)
            end },
            { Type = "Toggle", StateKey = "FarmCastleDoma", Name = T("FARM") .. " Doma", Description = T("FARM_DESC"), OnEnable = function()
                toggleTeleport(true, "Doma", "FARM")
            end, OnDisable = function()
                toggleTeleport(false)
            end },
            { Type = "Toggle", StateKey = "FarmCastleKokushibo", Name = T("FARM") .. " Kokushibo", Description = T("FARM_DESC"), OnEnable = function()
                toggleTeleport(true, "Kokushibo", "FARM")
            end, OnDisable = function()
                toggleTeleport(false)
            end }
        }

        local tp_mode_options = (CurrentLang == "EN") and {"Behind", "Above", "Below"} or {"Atrás", "Acima", "Abaixo"}
        local tp_mode_map = {
            ["Behind"] = "Behind", ["Above"] = "Above", ["Below"] = "Below",
            ["Atrás"] = "Behind", ["Acima"] = "Above", ["Abaixo"] = "Below"
        }

        addTopic("FARM", T("TOPIC_FARM"), {
            { Type = "Label", Name = T("INFO_LABEL") },
            { Type = "ListAuto", Name = T("EXTRAS_MOBS"), Description = T("EXTRAS_MOBS_DESC"), Options = {
                { Type = "Toggle", StateKey = "TrinketFarm", Name = T("TRINKET_FARM"), Description = T("TRINKET_FARM_DESC"), OnEnable = function()
                    trinketFarm = true
                    globalEnv.trinketFarm = true
                    spawn(function()
                        while trinketFarm do
                            task.wait(0.1)
                            pcall(function()
                                if workspace:FindFirstChild("Trinkets") then
                                    for _, trinket in pairs(workspace.Trinkets:GetChildren()) do
                                        if not trinketFarm then break end
                                        if trinket:IsA("Part") and trinket:FindFirstChild("Spawned") then
                                            if root then root.CFrame = trinket.CFrame * CFrame.new(0, 3, 0) end
                                            task.wait(0.15)
                                            local attempts = 0
                                            while trinketFarm and trinket.Parent and trinket:FindFirstChild("Spawned") and attempts < 10 do
                                                VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                                task.wait(0.05)
                                                VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                                task.wait(0.1)
                                                attempts = attempts + 1
                                            end
                                        end
                                    end
                                end
                            end)
                        end
                    end)
                end, OnDisable = function()
                    local hadTrinketFarm = trinketFarm
                    trinketFarm = false
                    globalEnv.trinketFarm = false
                    if hadTrinketFarm and not (isEnabled and farmIsRaid) then
                        teleportFarmPlayerUp()
                    end
                end },
                { Type = "Toggle", StateKey = "AutoAttack", Name = T("AUTO_ATTACK"), Description = T("AUTO_ATTACK_DESC"), OnEnable = function()
                    autoAttack = true
                    globalEnv.autoAttack = true
                    autoAttackLoopToken = autoAttackLoopToken + 1
                    local loopToken = autoAttackLoopToken
                    spawn(function() autoAttackLoop(loopToken) end)
                end, OnDisable = function()
                    autoAttack = false
                    globalEnv.autoAttack = false
                    autoAttackLoopToken = autoAttackLoopToken + 1
                end },
                { Type = "Toggle", StateKey = "OreFarm", Name = T("ORE_FARM"), Description = T("ORE_FARM_DESC"), OnEnable = function()
                    oreFarm = true
                    globalEnv.oreFarm = true
                    oreFarmNoclipWasEnabled = noclipToggle
                    toggleNoclip(true)
                    flyToggle = true
                    globalEnv.flyToggle = true
                    setupOreFly()
                    spawn(oreFarmLoop)
                end, OnDisable = function()
                    local hadOreFarm = oreFarm
                    oreFarm = false
                    globalEnv.oreFarm = false
                    flyToggle = false
                    globalEnv.flyToggle = false
                    if bg then bg:Destroy() end
                    if bv then bv:Destroy() end
                    if flyConn then flyConn:Disconnect() end
                    if humanoid then humanoid.PlatformStand = false end
                    if not isEnabled then
                        toggleNoclip(oreFarmNoclipWasEnabled)
                        if hadOreFarm then
                            teleportFarmPlayerUp()
                        end
                    end
                    oreFarmNoclipWasEnabled = false
                end }
            }},
            { Type = "ListAuto", Name = T("TP_MODE"), Description = T("TP_MODE_DESC"), Options = {
                { Type = "ListPersistent", StateKey = "TeleportMode", Name = T("TP_MODE"), Description = T("TP_MODE_DESC"), Options = tp_mode_options, Callback = function(v)
                    local mapped = tp_mode_map[v] or "Behind"
                    teleportMode = mapped
                    globalEnv.teleportMode = mapped
                end },
                { Type = "Toggle", StateKey = "AntiExecute", Name = T("ANTI_EXECUTE"), Description = T("ANTI_EXECUTE_DESC"), OnEnable = function() antiExecute = true globalEnv.antiExecute = true end, OnDisable = function() antiExecute = false globalEnv.antiExecute = false end },
                { Type = "Toggle", StateKey = "FarmAutoRegen", Name = T("FARM_AUTO_REGEN"), Description = T("FARM_AUTO_REGEN_DESC"), OnEnable = function() toggleFarmAutoRegen(true) end, OnDisable = function() toggleFarmAutoRegen(false) end },
                { Type = "Slider", StateKey = "FarmDistance", Name = T("DISTANCE"), Description = T("DISTANCE_DESC"), Min = 0, Max = 50, Default = 4, OnChange = function(v) FARM_DISTANCE = v globalEnv.FARM_DISTANCE = v end },
                { Type = "Slider", StateKey = "ExecuteDistance", Name = T("EXECUTE_DISTANCE"), Description = T("EXECUTE_DISTANCE_DESC"), Min = 0, Max = 100, Default = 20, OnChange = function(v) EXECUTE_DISTANCE = v globalEnv.EXECUTE_DISTANCE = v end }
            }},
            { Type = "ListAuto", Name = T("FARM_MOBS_LIST"), Description = T("FARM_MOBS_LIST_DESC"), Options = mobFarmOptions },
            { Type = "ListAuto", Name = T("FARM_CASTLE"), Description = T("FARM_CASTLE_DESC"), Options = castleFarmOptions },
            { Type = "ListAuto", Name = T("RAIDS"), Description = T("RAIDS_DESC"), Options = {
                { Type = "Single", Name = T("TP_RAID_AREA"), Description = T("TP_RAID_AREA_DESC"), Callback = function() if root then root.CFrame = LOCATIONS.Raid end end },
                { Type = "Toggle", StateKey = "FarmGeneralRaid", Name = T("FARM_GENERAL_RAID"), Description = T("FARM_GENERAL_RAID_DESC"), OnEnable = function() toggleTeleport(true, RAID_GENERAL_TARGET, "FARM") end, OnDisable = function() toggleTeleport(false) end },
                { Type = "Toggle", StateKey = "FarmShinobuRaid", Name = T("FARM") .. " Shinobu Raid", Description = T("FARM_DESC"), OnEnable = function() toggleTeleport(true, "ShinoubuRaid", "FARM") end, OnDisable = function() toggleTeleport(false) end },
                { Type = "Toggle", StateKey = "FarmRengokuRaid", Name = T("FARM") .. " Rengoku Raid", Description = T("FARM_DESC"), OnEnable = function() toggleTeleport(true, "RengokuRaid", "FARM") end, OnDisable = function() toggleTeleport(false) end },
                { Type = "Toggle", StateKey = "FarmKokushiboRaid", Name = T("FARM") .. " Kokushibo Raid", Description = T("FARM_DESC"), OnEnable = function() toggleTeleport(true, "KokushiboRaid", "FARM") end, OnDisable = function() toggleTeleport(false) end },
                { Type = "Toggle", StateKey = "FarmEnemyRaid", Name = T("FARM") .. " Enemy Raid", Description = "Foca no inimigo 'Enemy'", OnEnable = function() toggleTeleport(true, "Enemy", "FARM") end, OnDisable = function() toggleTeleport(false) end },
                { Type = "Toggle", StateKey = "FarmYoriichi", Name = T("FARM") .. " Yoriichi", Description = T("FARM_DESC"), OnEnable = function() toggleTeleport(true, "Yoriichi", "FARM") end, OnDisable = function() toggleTeleport(false) end }
            }}
        })

        addTopic("AUTOSKILLS", T("TOPIC_AUTOSKILLS"), {
            { Type = "Label", Name = T("AUTOSKILLS_DESC") },
            { Type = "Toggle", StateKey = "AutoSkill1", Name = T("AUTO_SKILL_1"), Description = T("AUTO_SKILL_DESC"), OnEnable = function() AutoSkillSystem.toggleSkill("1", true) end, OnDisable = function() AutoSkillSystem.toggleSkill("1", false) end },
            { Type = "Toggle", StateKey = "AutoSkill2", Name = T("AUTO_SKILL_2"), Description = T("AUTO_SKILL_DESC"), OnEnable = function() AutoSkillSystem.toggleSkill("2", true) end, OnDisable = function() AutoSkillSystem.toggleSkill("2", false) end },
            { Type = "Toggle", StateKey = "AutoSkill3", Name = T("AUTO_SKILL_3"), Description = T("AUTO_SKILL_DESC"), OnEnable = function() AutoSkillSystem.toggleSkill("3", true) end, OnDisable = function() AutoSkillSystem.toggleSkill("3", false) end },
            { Type = "Toggle", StateKey = "AutoSkill4", Name = T("AUTO_SKILL_4"), Description = T("AUTO_SKILL_DESC"), OnEnable = function() AutoSkillSystem.toggleSkill("4", true) end, OnDisable = function() AutoSkillSystem.toggleSkill("4", false) end },
            { Type = "Toggle", StateKey = "AutoSkill5", Name = T("AUTO_SKILL_5"), Description = T("AUTO_SKILL_DESC"), OnEnable = function() AutoSkillSystem.toggleSkill("5", true) end, OnDisable = function() AutoSkillSystem.toggleSkill("5", false) end },
            { Type = "Toggle", StateKey = "AutoSkill6", Name = T("AUTO_SKILL_6"), Description = T("AUTO_SKILL_DESC"), OnEnable = function() AutoSkillSystem.toggleSkill("6", true) end, OnDisable = function() AutoSkillSystem.toggleSkill("6", false) end },
            { Type = "Toggle", StateKey = "AutoSkill7", Name = T("AUTO_SKILL_7"), Description = T("AUTO_SKILL_DESC"), OnEnable = function() AutoSkillSystem.toggleSkill("7", true) end, OnDisable = function() AutoSkillSystem.toggleSkill("7", false) end },
            { Type = "Toggle", StateKey = "AutoSkillT", Name = T("AUTO_SKILL_T"), Description = T("AUTO_SKILL_DESC"), OnEnable = function() AutoSkillSystem.toggleSkill("T", true) end, OnDisable = function() AutoSkillSystem.toggleSkill("T", false) end },
            { Type = "Toggle", StateKey = "AutoSkillY", Name = T("AUTO_SKILL_Y"), Description = T("AUTO_SKILL_DESC"), OnEnable = function() AutoSkillSystem.toggleSkill("Y", true) end, OnDisable = function() AutoSkillSystem.toggleSkill("Y", false) end },
            { Type = "Toggle", StateKey = "AutoBreath", Name = T("AUTO_BREATH"), Description = T("AUTO_BREATH_DESC"), OnEnable = function() AutoSkillSystem.toggleBreath(true) end, OnDisable = function() AutoSkillSystem.toggleBreath(false) end }
        })

        addTopic("PLAYERS", T("TOPIC_PLAYERS"), {
            { Type = "ListPersistent", StateKey = "SelectedPlayer", Name = T("SELECT_PLAYER"), Description = T("SELECT_PLAYER_DESC"), Options = getPlayerNames(), Callback = function(v) selectedPlayerName = v globalEnv.selectedPlayerName = v end },
            { Type = "Single", Name = T("UPDATE_LIST"), Description = T("UPDATE_LIST_DESC"), Callback = function() initTopics() end },
            { Type = "ListAuto", Name = T("PLAYER_ACTIONS"), Description = T("PLAYER_ACTIONS_DESC"), Options = {
                { Type = "Single", Name = T("GO_TO_PLAYER"), Description = T("GO_TO_PLAYER_DESC"), Callback = function()
                    local t = Players:FindFirstChild(selectedPlayerName)
                    if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and root then
                        root.CFrame = t.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
                    end
                end},
                { Type = "Toggle", StateKey = "ESPPlayers", Name = T("ESP_PLAYERS"), Description = T("ESP_PLAYERS_DESC"), OnEnable = function() toggleESP(true) end, OnDisable = function() toggleESP(false) end },
                { Type = "Toggle", StateKey = "FarmPlayer", Name = T("FARM_PLAYER"), Description = T("FARM_PLAYER_DESC"), OnEnable = function() if selectedPlayerName then toggleTeleport(true, selectedPlayerName, "PLAYER") end end, OnDisable = function() toggleTeleport(false) end },
                { Type = "Toggle", StateKey = "EnableSpectate", Name = T("ENABLE_SPECTATE"), Description = T("ENABLE_SPECTATE_DESC"), OnEnable = function() if selectedPlayerName then toggleSpectate(true, selectedPlayerName) end end, OnDisable = function() toggleSpectate(false) end }
            }}
        })

        addTopic("TELEPORTS", T("TOPIC_TELEPORTS"), {
            { Type = "Single", Name = T("LOAD_MOBS"), Description = T("LOAD_MOBS_DESC"), Callback = detectLoadedMobs },
            { Type = "Single", Name = T("LOAD_MAP"), Description = T("LOAD_MAP_DESC"), Callback = loadAllMap },
            { Type = "ListAuto", Name = T("EVENTS"), Description = T("EVENTS_DESC"), Options = {
                { Type = "Single", Name = T("EVENT_RAID"), Description = T("EVENT_RAID_DESC"), Callback = function() teleportToEvent(EVENT_LOCATIONS.Raid) end },
                { Type = "Single", Name = T("EVENT_DOUMA"), Description = T("EVENT_TP_DESC"), Callback = function() teleportToEvent(EVENT_LOCATIONS.Douma) end },
                { Type = "Single", Name = T("EVENT_AKAZA"), Description = T("EVENT_TP_DESC"), Callback = function() teleportToEvent(EVENT_LOCATIONS.Akaza) end },
                { Type = "Single", Name = T("EVENT_KOKUSHIBO"), Description = T("EVENT_TP_DESC"), Callback = function() teleportToEvent(EVENT_LOCATIONS.Kokushibo) end },
                { Type = "Single", Name = T("EVENT_SLAYER_CASTLE"), Description = T("EVENT_TP_DESC"), Callback = function() teleportToEvent(EVENT_LOCATIONS.SlayerCastle) end },
                { Type = "Single", Name = T("EVENT_SOUP"), Description = T("EVENT_TP_DESC"), Callback = function() teleportToEvent(EVENT_LOCATIONS.SoupVendor) end },
                { Type = "Single", Name = T("EVENT_MEAT"), Description = T("EVENT_TP_DESC"), Callback = function() teleportToEvent(EVENT_LOCATIONS.MeatVendor) end },
                { Type = "Single", Name = T("EVENT_JEWEL_SELLER"), Description = T("EVENT_TP_DESC"), Callback = function() teleportToEvent(EVENT_LOCATIONS.JewelVendor) end },
                { Type = "Single", Name = T("EVENT_NICHIRIN_HORN"), Description = T("EVENT_TP_DESC"), Callback = function() teleportToEvent(EVENT_LOCATIONS.NichirinHornVendor) end }
            }},
            { Type = "ListAuto", Name = T("VILLAGES"), Description = T("VILLAGES_DESC"), Options = {
                { Type = "Single", Name = T("TP_HAYAKAWA"), Description = T("TP_HAYAKAWA_DESC"), Callback = function() if root then root.CFrame = LOCATIONS.Hayakawa end end },
                { Type = "Single", Name = T("TP_OKUYA"), Description = T("TP_OKUYA_DESC"), Callback = function() if root then root.CFrame = LOCATIONS.Okuya end end },
                { Type = "Single", Name = T("TP_KAMAKURA"), Description = T("TP_KAMAKURA_DESC"), Callback = function() if root then root.CFrame = LOCATIONS.Kamakura end end },
                { Type = "Single", Name = T("TP_SLAYER"), Description = T("TP_SLAYER_DESC"), Callback = function() if root then root.CFrame = LOCATIONS.Slayer end end },
                { Type = "Single", Name = T("TP_DISTRITO"), Description = T("TP_DISTRITO_DESC"), Callback = function() if root then root.CFrame = LOCATIONS.Distrito end end },
                { Type = "Single", Name = T("TP_SLAYER_EXAM"), Description = T("TP_SLAYER_EXAM_DESC"), Callback = function() if root then root.CFrame = LOCATIONS.SlayerExam end end }
            }},
            { Type = "ListAuto", Name = T("BREATHS"), Description = T("BREATHS_DESC"), Options = {
                { Type = "Single", Name = T("TP_MIST"), Description = T("TP_MIST_DESC"), Callback = function() if root then root.CFrame = BREATHS.Mist end end },
                { Type = "Single", Name = T("TP_WATER"), Description = T("TP_WATER_DESC"), Callback = function() if root then root.CFrame = BREATHS.Water end end },
                { Type = "Single", Name = T("TP_WIND"), Description = T("TP_WIND_DESC"), Callback = function() if root then root.CFrame = BREATHS.Wind end end },
                { Type = "Single", Name = T("TP_THUNDER"), Description = T("TP_THUNDER_DESC"), Callback = function() if root then root.CFrame = BREATHS.Thunder end end },
                { Type = "Single", Name = T("TP_INSECT"), Description = T("TP_INSECT_DESC"), Callback = function() if root then root.CFrame = BREATHS.Insect end end },
                { Type = "Single", Name = T("TP_FLAME"), Description = T("TP_FLAME_DESC"), Callback = function() if root then root.CFrame = BREATHS.Flame end end },
                { Type = "Single", Name = T("TP_SUN"), Description = T("TP_SUN_DESC"), Callback = function() if root then root.CFrame = BREATHS.Sun end end },
                { Type = "Single", Name = T("TP_MOON"), Description = T("TP_MOON_DESC"), Callback = function() if root then root.CFrame = BREATHS.Moon end end },
                { Type = "Single", Name = T("TP_BEAST"), Description = T("TP_BEAST_DESC"), Callback = function() if root then root.CFrame = BREATHS.Beast end end },
                { Type = "Single", Name = T("TP_SOUND"), Description = T("TP_SOUND_DESC"), Callback = function() if root then root.CFrame = BREATHS.Sound end end },
                { Type = "Single", Name = T("TP_FLOWER"), Description = T("TP_FLOWER_DESC"), Callback = function() if root then root.CFrame = BREATHS.Flower end end },
                { Type = "Single", Name = T("TP_SERPENT"), Description = T("TP_SERPENT_DESC"), Callback = function() if root then root.CFrame = BREATHS.Serpent end end },
                { Type = "Single", Name = T("TP_LOVE"), Description = T("TP_LOVE_DESC"), Callback = function() if root then root.CFrame = BREATHS.Love end end }
            }}
        })

        addTopic("DEV", T("TOPIC_DEV"), {
            { Type = "ListAuto", Name = T("DEV_TOOLS"), Description = T("DEV_TOOLS_DESC"), Options = {
                { Type = "Single", Name = T("DEV_LOAD_MOBS"), Description = T("DEV_LOAD_MOBS_DESC"), Callback = detectLoadedMobs },
                { Type = "ListAuto", Name = T("DEV_LOADED_MOBS"), Description = T("DEV_LOADED_MOBS_DESC"), Options = getLoadedMobNameOptions },
                { Type = "Single", Name = T("DEV_COORDS"), Description = T("DEV_COORDS_DESC"), Callback = copyCoordinates },
                { Type = "Single", Name = "Respawnar", Description = "Respawna seu personagem uma vez", Callback = respawnCharacterOnce },
            }},
            { Type = "ListAuto", Name = T("DEV_FUNNY"), Description = T("DEV_FUNNY_DESC"), Options = {
                { Type = "Toggle", StateKey = "DevSpin", Name = T("DEV_SPIN"), Description = T("DEV_SPIN_DESC"), OnEnable = function() toggleDevSpin(true) end, OnDisable = function() toggleDevSpin(false) end },
                { Type = "Toggle", StateKey = "DevHeli", Name = T("DEV_HELI"), Description = T("DEV_HELI_DESC"), OnEnable = function() toggleDevHeli(true) end, OnDisable = function() toggleDevHeli(false) end },
                { Type = "Toggle", StateKey = "DevDrunk", Name = T("DEV_DRUNK"), Description = T("DEV_DRUNK_DESC"), OnEnable = function() toggleDevDrunk(true) end, OnDisable = function() toggleDevDrunk(false) end },
                { Type = "Toggle", StateKey = "DevBalloon", Name = T("DEV_BALLOON"), Description = T("DEV_BALLOON_DESC"), OnEnable = function() toggleDevBalloon(true) end, OnDisable = function() toggleDevBalloon(false) end },
                { Type = "Toggle", StateKey = "DevRoll", Name = T("DEV_ROLL"), Description = T("DEV_ROLL_DESC"), OnEnable = function() toggleDevRoll(true) end, OnDisable = function() toggleDevRoll(false) end },
                { Type = "Toggle", StateKey = "DevHop", Name = T("DEV_HOP"), Description = T("DEV_HOP_DESC"), OnEnable = function() toggleDevHop(true) end, OnDisable = function() toggleDevHop(false) end },
                { Type = "Toggle", StateKey = "DevMoonwalk", Name = T("DEV_MOONWALK"), Description = T("DEV_MOONWALK_DESC"), OnEnable = function() toggleDevMoonwalk(true) end, OnDisable = function() toggleDevMoonwalk(false) end },
                { Type = "Toggle", StateKey = "DevDisco", Name = T("DEV_DISCO"), Description = T("DEV_DISCO_DESC"), OnEnable = function() toggleDevDisco(true) end, OnDisable = function() toggleDevDisco(false) end },
                { Type = "Toggle", StateKey = "DevGiant", Name = T("DEV_GIANT"), Description = T("DEV_GIANT_DESC"), OnEnable = function() toggleDevGiant(true) end, OnDisable = function() toggleDevGiant(false) end },
                { Type = "Toggle", StateKey = "DevTiny", Name = T("DEV_TINY"), Description = T("DEV_TINY_DESC"), OnEnable = function() toggleDevTiny(true) end, OnDisable = function() toggleDevTiny(false) end },
                { Type = "Single", Name = T("DEV_FLING"), Description = T("DEV_FLING_DESC"), Callback = devFlingSelf },
                { Type = "Single", Name = T("DEV_RAGDOLL"), Description = T("DEV_RAGDOLL_DESC"), Callback = devRagdollOnce },
            }},
        })

        addTopic("CONFIG", T("TOPIC_CONFIG"), {
            { Type = "ListPersistent", Name = T("LANGUAGE"), Description = T("LANGUAGE_DESC"), Options = {"Português", "English"}, Callback = function(val) CurrentLang = (val == "English") and "EN" or "PT" globalEnv.CurrentLang = CurrentLang initTopics() end },
            { Type = "ListPersistent", Name = T("THEME"), Description = T("THEME_DESC"), Options = {"Material You", "Carbon", "Arctic", "Nebula", "Neon", "Carmesim", "Galaxy", "Blush", "Branco"}, Callback = function(val) if THEME_PRESETS[val] then CurrentThemeName = val globalEnv.CurrentThemeName = val for k,v in pairs(THEME_PRESETS[val]) do THEME[k] = v end initTopics() end end },
            { Type = "Slider", Name = T("OPACITY"), Description = T("OPACITY_DESC"), Min = 0, Max = 100, Default = (1 - CurrentOpacity) * 100, OnChange = function(val)
                local transp = 1 - (val / 100)
                CurrentOpacity = transp
                globalEnv.CurrentOpacity = transp
                uiRoot.BackgroundTransparency = transp
                leftBg.BackgroundTransparency = transp
                rightBg.BackgroundTransparency = transp
                miniButton.BackgroundTransparency = transp
                for _, desc in pairs(uiRoot:GetDescendants()) do if desc.Name == "ElementBackground" and desc:IsA("Frame") then desc.BackgroundTransparency = transp end end
                for _, desc in pairs(topicsList:GetDescendants()) do if desc:IsA("TextButton") then desc.BackgroundTransparency = transp end end
            end }
        })

        if previousKey and topicItemsMap[previousKey] then
            selectTopic(previousKey)
        end
    end

    initTopics()
end

showPlatformPopup()
