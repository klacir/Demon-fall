--[[
    MOONDF HUB - MERGED (PC & MOBILE COMPATIBLE)
    - Mantive nomes de funções públicas (setupFly, toggleNoclip, toggleClickTP, etc.)
    - Popup inicial PC / Mobile. Depois de escolher, o HUD é criado com suporte a toque.
    - Sliders e redimensionamento compatíveis com Touch e Mouse.
    - Variáveis de GUI usam uiRoot para evitar conflito com 'root' do personagem (HumanoidRootPart).
    - Preservadas as funcionalidades do seu V3; apenas organizei a ordem para que callbacks encontrem as funções.
    - FIX DRAG: AnchorPoint (0,0) + delta puro (MakeDraggable) — sem salto ao clicar.
]]

-- ============================================================================== 
--  SERVICES
-- ============================================================================== 
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local VIM = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
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
        TOPIC_TEST = "Teste",
        TOPIC_CONFIG = "Configuração",
        TOPIC_GENERAL = "Geral",
        TOPIC_MOBS = "Mobs",
        TOPIC_FARM = "Farm",
        TOPIC_PLAYERS = "Players",
        TOPIC_TELEPORTS = "Teleportes",
        TOPIC_DEV = "Developer",
        FOOTER_TEXT = "Right Ctrl ou use o botão para minimizar • Inputs: Immediate (OK) / Select (no OK)",

        DEV_TOOLS = "Ferramentas",
        DEV_TOOLS_DESC = "Coords e utilidades",
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
        CLICK_TP_DESC = "Ctrl + Click para TP",
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
        EXECUTE_DISTANCE = "Dist. Execute",
        EXECUTE_DISTANCE_DESC = "Distância ao executar",
        AUTO_ATTACK = "Auto Attack",
        AUTO_ATTACK_DESC = "Spam M1",
        LOAD_MOBS = "Carregar Mobs",
        LOAD_MOBS_DESC = "TP pelos spawns",
        FARM_MOBS_LIST = "Lista de Farm Mobs",
        FARM_MOBS_LIST_DESC = "Selecione o Mob para farmar",
        FARM = "Farm",
        FARM_DESC = "Auto TP",


        RAIDS = "Raids (Locais)",
        RAIDS_DESC = "Farm de Raids",
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
        TOPIC_TEST = "Test",
        TOPIC_CONFIG = "Settings",
        TOPIC_GENERAL = "General",
        TOPIC_MOBS = "Mobs",
        TOPIC_FARM = "Farm",
        TOPIC_PLAYERS = "Players",
        TOPIC_TELEPORTS = "Teleports",
        TOPIC_DEV = "Developer",
        FOOTER_TEXT = "Right Ctrl or use button to minimize • Inputs: Immediate (OK) / Select (no OK)",

        DEV_TOOLS = "Tools",
        DEV_TOOLS_DESC = "Coords and utilities",
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
        CLICK_TP_DESC = "Ctrl + Click to TP",
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
        EXECUTE_DISTANCE = "Execute Dist.",
        EXECUTE_DISTANCE_DESC = "Distance when executing",
        AUTO_ATTACK = "Auto Attack",
        AUTO_ATTACK_DESC = "Spam M1",
        LOAD_MOBS = "Load Mobs",
        LOAD_MOBS_DESC = "TP through spawns",
        FARM_MOBS_LIST = "Farm Mobs List",
        FARM_MOBS_LIST_DESC = "Select Mob to farm",
        FARM = "Farm",
        FARM_DESC = "Auto TP",

        RAIDS = "Raids (Locations)",
        RAIDS_DESC = "Raid Farm",
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
globalEnv.CurrentThemeName = globalEnv.CurrentThemeName or "Carbon"
local CurrentThemeName = globalEnv.CurrentThemeName
globalEnv.CurrentOpacity = globalEnv.CurrentOpacity or 0
local CurrentOpacity = globalEnv.CurrentOpacity

--[[
  TEMAS REFEITOS DO ZERO (atmosfera Tornify-inspired)
  Nomes únicos (sem barra). Crimson e Amethyst removidos.
]]
local THEME_PRESETS = {
    -- Carbon: preto fosco premium
    ["Carbon"] = {
        Background = Color3.fromRGB(9, 9, 9),
        PanelBg    = Color3.fromRGB(21, 21, 21),
        Text       = Color3.fromRGB(244, 244, 244),
        SubText    = Color3.fromRGB(154, 154, 154),
        Off        = Color3.fromRGB(40, 40, 40),
        On         = Color3.fromRGB(255, 255, 255),
        Border     = Color3.fromRGB(35, 35, 35),
        Hover      = Color3.fromRGB(32, 32, 32),
        Danger     = Color3.fromRGB(220, 60, 70),
        Accent     = Color3.fromRGB(255, 255, 255),
        KnobColor  = Color3.fromRGB(255, 255, 255)
    },
    -- Arctic: gelo limpo e claro
    ["Arctic"] = {
        Background = Color3.fromRGB(237, 245, 255),
        PanelBg    = Color3.fromRGB(221, 235, 255),
        Text       = Color3.fromRGB(23, 36, 51),
        SubText    = Color3.fromRGB(90, 120, 150),
        Off        = Color3.fromRGB(190, 210, 230),
        On         = Color3.fromRGB(94, 184, 255),
        Border     = Color3.fromRGB(180, 210, 240),
        Hover      = Color3.fromRGB(200, 225, 250),
        Danger     = Color3.fromRGB(230, 55, 70),
        Accent     = Color3.fromRGB(94, 184, 255),
        KnobColor  = Color3.fromRGB(255, 255, 255)
    },
    -- Nebula: roxo espacial profundo
    ["Nebula"] = {
        Background = Color3.fromRGB(16, 8, 30),
        PanelBg    = Color3.fromRGB(35, 25, 60),
        Text       = Color3.fromRGB(240, 230, 255),
        SubText    = Color3.fromRGB(160, 140, 200),
        Off        = Color3.fromRGB(50, 40, 80),
        On         = Color3.fromRGB(184, 146, 255),
        Border     = Color3.fromRGB(70, 55, 110),
        Hover      = Color3.fromRGB(45, 35, 75),
        Danger     = Color3.fromRGB(255, 70, 100),
        Accent     = Color3.fromRGB(184, 146, 255),
        KnobColor  = Color3.fromRGB(255, 245, 255)
    },
    -- Neon: radioativo / toxic
    ["Neon"] = {
        Background = Color3.fromRGB(0, 17, 0),
        PanelBg    = Color3.fromRGB(0, 42, 26),
        Text       = Color3.fromRGB(0, 255, 170),
        SubText    = Color3.fromRGB(0, 180, 120),
        Off        = Color3.fromRGB(0, 60, 40),
        On         = Color3.fromRGB(0, 255, 136),
        Border     = Color3.fromRGB(0, 120, 80),
        Hover      = Color3.fromRGB(0, 55, 35),
        Danger     = Color3.fromRGB(255, 50, 50),
        Accent     = Color3.fromRGB(0, 255, 136),
        KnobColor  = Color3.fromRGB(0, 255, 170)
    },
    -- Carmesim: carmesin profundo
    ["Carmesim"] = {
        Background = Color3.fromRGB(10, 0, 0),
        PanelBg    = Color3.fromRGB(26, 0, 0),
        Text       = Color3.fromRGB(255, 240, 240),
        SubText    = Color3.fromRGB(200, 120, 120),
        Off        = Color3.fromRGB(55, 10, 10),
        On         = Color3.fromRGB(139, 0, 0),
        Border     = Color3.fromRGB(100, 20, 20),
        Hover      = Color3.fromRGB(40, 5, 5),
        Danger     = Color3.fromRGB(255, 60, 60),
        Accent     = Color3.fromRGB(255, 59, 59),
        KnobColor  = Color3.fromRGB(255, 220, 220)
    },
    -- Galaxy: midnight azul-espacial
    ["Galaxy"] = {
        Background = Color3.fromRGB(10, 15, 44),
        PanelBg    = Color3.fromRGB(13, 19, 43),
        Text       = Color3.fromRGB(230, 240, 255),
        SubText    = Color3.fromRGB(120, 140, 200),
        Off        = Color3.fromRGB(30, 40, 80),
        On         = Color3.fromRGB(59, 76, 192),
        Border     = Color3.fromRGB(40, 55, 120),
        Hover      = Color3.fromRGB(20, 28, 60),
        Danger     = Color3.fromRGB(255, 70, 90),
        Accent     = Color3.fromRGB(107, 142, 245),
        KnobColor  = Color3.fromRGB(220, 230, 255)
    },
    -- Blush: rosa suave amanhecer
    ["Blush"] = {
        Background = Color3.fromRGB(255, 225, 238),
        PanelBg    = Color3.fromRGB(245, 207, 224),
        Text       = Color3.fromRGB(45, 31, 41),
        SubText    = Color3.fromRGB(120, 90, 105),
        Off        = Color3.fromRGB(230, 190, 210),
        On         = Color3.fromRGB(255, 126, 185),
        Border     = Color3.fromRGB(220, 170, 190),
        Hover      = Color3.fromRGB(248, 221, 232),
        Danger     = Color3.fromRGB(230, 55, 80),
        Accent     = Color3.fromRGB(255, 126, 185),
        KnobColor  = Color3.fromRGB(255, 255, 255)
    },
    -- Branco: branco sofisticado limpo
    ["Branco"] = {
        Background = Color3.fromRGB(252, 252, 250),
        PanelBg    = Color3.fromRGB(242, 242, 238),
        Text       = Color3.fromRGB(28, 28, 26),
        SubText    = Color3.fromRGB(110, 110, 100),
        Off        = Color3.fromRGB(210, 210, 200),
        On         = Color3.fromRGB(60, 60, 55),
        Border     = Color3.fromRGB(200, 200, 190),
        Hover      = Color3.fromRGB(235, 235, 230),
        Danger     = Color3.fromRGB(220, 50, 60),
        Accent     = Color3.fromRGB(50, 50, 45),
        KnobColor  = Color3.fromRGB(255, 255, 255)
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
    Label          = Color3.fromRGB(255, 255, 255),
    Single         = Color3.fromRGB(0, 255, 128),
    Toggle         = Color3.fromRGB(255, 50, 50),
    Slider         = Color3.fromRGB(0, 170, 255),
    InputImmediate = Color3.fromRGB(170, 0, 255),
    InputSelect    = Color3.fromRGB(200, 0, 255),
    ListPersistent = Color3.fromRGB(255, 170, 0),
    ListAuto       = Color3.fromRGB(255, 170, 0),
    Container      = Color3.fromRGB(255, 255, 0)
}

-- Estados globais
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

-- ======================================================================
-- MakeDraggable — DELTA PURO (funciona com qualquer AnchorPoint)
-- Não mistura mouse com AbsolutePosition no mesmo cálculo → sem salto.
-- ======================================================================
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

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            -- apenas guarda referência se necessário
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

-- Remove instâncias antigas do Hub
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
-- GAME LOGIC (preservado / funções públicas mantidas)
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
local connection = nil
local loadingAllMobs = false
local teleportAndLookLooping = false
globalEnv.selectedPlayerName = globalEnv.selectedPlayerName or nil
local selectedPlayerName = globalEnv.selectedPlayerName
globalEnv.teleportMode = globalEnv.teleportMode or "Behind"
local teleportMode = globalEnv.teleportMode
globalEnv.FARM_DISTANCE = globalEnv.FARM_DISTANCE or 4
local FARM_DISTANCE = globalEnv.FARM_DISTANCE
globalEnv.EXECUTE_DISTANCE = globalEnv.EXECUTE_DISTANCE or 1
local EXECUTE_DISTANCE = globalEnv.EXECUTE_DISTANCE
local PLAYER_EXECUTE_DISTANCE = 20

globalEnv.clickTPToggle = globalEnv.clickTPToggle or false
local clickTPToggle = globalEnv.clickTPToggle
local clickTPConn = nil
globalEnv.noclipToggle = globalEnv.noclipToggle or false
local noclipToggle = globalEnv.noclipToggle
local noclipConn = nil
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
    noclipToggle = state
    globalEnv.noclipToggle = state
    if state then
        if noclipConn then noclipConn:Disconnect() end
        noclipConn = RunService.Stepped:Connect(function()
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() end
    end
end

function toggleClickTP(state)
    clickTPToggle = state
    globalEnv.clickTPToggle = state
    if state then
        if clickTPConn then clickTPConn:Disconnect() end
        clickTPConn = UserInputService.InputBegan:Connect(function(input, gp)
            if not clickTPToggle or gp then return end
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            if input.UserInputType == Enum.UserInputType.Touch or UserInputService.TouchEnabled then
                return
            end
            if not UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and not UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
                return
            end
            if not root then return end
            local mouse = player:GetMouse()
            if mouse and mouse.Hit then
                root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end)
    else
        if clickTPConn then clickTPConn:Disconnect(); clickTPConn = nil end
    end
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

local function findEnemy(mobName)
    local targetPlayer = Players:FindFirstChild(mobName)
    if targetPlayer and targetPlayer.Character then return targetPlayer.Character end
    return workspace:FindFirstChild(mobName)
end

local function teleportAndLook()
    local enemy = currentMob and findEnemy(currentMob)
    if not enemy or not root then return end
    local enemyRoot = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Torso")
    if not enemyRoot then
        local success, pivot = pcall(function() return enemy:GetPivot() end)
        if success and pivot then enemyRoot = { Position = pivot.Position, CFrame = pivot } end
        if not enemyRoot then return end
    end

    local currentDistance = FARM_DISTANCE
    local isExecuting = false
    if enemy:FindFirstChild("Executing") or enemy:FindFirstChild("Execute") then isExecuting = true end

    if isExecuting then
        if Players:GetPlayerFromCharacter(enemy) then currentDistance = PLAYER_EXECUTE_DISTANCE else currentDistance = EXECUTE_DISTANCE end
    end

    local offset = Vector3.new(0, 0, 0)
    if teleportMode == "Below" then offset = Vector3.new(0, -currentDistance, 0)
    elseif teleportMode == "Above" then offset = Vector3.new(0, currentDistance, 0)
    elseif teleportMode == "Behind" then
        local lookVec = enemyRoot.CFrame.LookVector
        offset = -lookVec * currentDistance
    end
    root.CFrame = CFrame.new(enemyRoot.Position + offset, enemyRoot.Position)
    root.Velocity = Vector3.new(0,0,0)
end

local function teleportAndLookWithKeys()
    local b_timer = 0
    while teleportAndLookLooping do
        teleportAndLook()
        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        if b_timer <= 0 then
            VIM:SendKeyEvent(true, Enum.KeyCode.B, false, game)
            VIM:SendKeyEvent(false, Enum.KeyCode.B, false, game)
            b_timer = 5
        end
        local delta = 0.2
        b_timer = b_timer - delta
        task.wait(delta)
    end
end

local farmAttackLooping = false

local function getCombatRemote()
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
    if not currentMob then return nil end
    return findEnemy(currentMob)
end

local hubInteracting = false

local function isPointerOverHub()
    local ok, over = pcall(function()
        if not screenGui or not screenGui.Parent then return false end
        local pos = UserInputService:GetMouseLocation()
        for _, gui in ipairs(screenGui:GetDescendants()) do
            if gui:IsA("GuiObject") and gui.Visible then
                local ap, as = gui.AbsolutePosition, gui.AbsoluteSize
                if as.X > 0 and as.Y > 0
                    and pos.X >= ap.X and pos.X <= ap.X + as.X
                    and pos.Y >= ap.Y and pos.Y <= ap.Y + as.Y then
                    return true
                end
            end
        end
        return false
    end)
    return ok and over
end

local function shouldSkipVisualClick()
    if hubInteracting then return true end
    if isPointerOverHub() then return true end
    return false
end

UserInputService.InputBegan:Connect(function(input, _gp)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        if isPointerOverHub() then
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

local function sendM1()
    pcall(function()
        local remote = getCombatRemote()
        if remote then
            remote:FireServer("Combat", "Server")
        end
    end)
    if not shouldSkipVisualClick() then
        pcall(function()
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            task.wait(0.04)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end)
    end
end

local function sendM2()
    pcall(function()
        local remote = getCombatRemote()
        if remote then
            remote:FireServer("Combat", "Heavy")
        end
    end)
    if not shouldSkipVisualClick() then
        pcall(function()
            VIM:SendMouseButtonEvent(0, 0, 1, true, game, 1)
            task.wait(0.05)
            VIM:SendMouseButtonEvent(0, 0, 1, false, game, 1)
        end)
    end
end

local function smartAttackOnce()
    local enemy = getCurrentFarmCharacter()
    if enemy and isTargetBlocking(enemy) then
        local safety = 0
        while (autoAttack or isEnabled) and safety < 40 do
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

local function autoAttackLoop()
    while autoAttack do
        if isEnabled and currentMob then
            smartAttackOnce()
        else
            sendM1()
        end
        task.wait(0.14)
    end
end

local function farmAttackLoop()
    while farmAttackLooping and isEnabled do
        if not autoAttack then
            smartAttackOnce()
        end
        task.wait(0.14)
    end
end

function toggleTeleport(enable, mobName)
    if enable then
        if connection then connection:Disconnect() end
        teleportAndLookLooping = true
        connection = RunService.RenderStepped:Connect(teleportAndLook)
        spawn(teleportAndLookWithKeys)
        currentMob = mobName
        isEnabled = true
        farmAttackLooping = true
        spawn(farmAttackLoop)
    else
        if connection then connection:Disconnect() connection = nil end
        teleportAndLookLooping = false
        farmAttackLooping = false
        isEnabled = false
        currentMob = nil
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

local function loadAllMobs()
    if loadingAllMobs then return end
    loadingAllMobs = true
    local initialPosition = root.CFrame
    for i, coord in ipairs(LOAD_COORDINATES) do
        root.CFrame = CFrame.new(coord)
        task.wait(2)
    end
    root.CFrame = initialPosition
    loadingAllMobs = false
end

local function loadAllMap()
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

local function setupHealthPlayer(plr)
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

local function findRealHealthAndMax(plr)
    local char = plr.Character
    if not char then return nil, nil end

    local currentHp = nil
    local detectedMaxHp = nil
    local maxHpNames = {"MaxHealth", "MaxHP", "Max_Health", "MHP", "Max_HP", "MaximumHealth"}

    local hpVal = char:FindFirstChild("Health") or char:FindFirstChild("HP") or char:FindFirstChild("CurrentHealth")
    if hpVal and hpVal:IsA("ValueBase") then
        currentHp = tonumber(hpVal.Value)
    end

    for _, name in ipairs(maxHpNames) do
        local mVal = char:FindFirstChild(name)
        if mVal and mVal:IsA("ValueBase") and tonumber(mVal.Value) and tonumber(mVal.Value) > 100 then
            detectedMaxHp = tonumber(mVal.Value)
            break
        end
    end

    local foldersToCheck = {"Status", "Data", "Stats", "leaderstats"}
    for _, folderName in ipairs(foldersToCheck) do
        local folder = plr:FindFirstChild(folderName) or char:FindFirstChild(folderName)
        if folder then
            if not currentHp then
                local pHP = folder:FindFirstChild("Health") or folder:FindFirstChild("HP")
                if pHP and pHP:IsA("ValueBase") then currentHp = tonumber(pHP.Value) end
            end
            if not detectedMaxHp then
                for _, name in ipairs(maxHpNames) do
                    local pMax = folder:FindFirstChild(name)
                    if pMax and pMax:IsA("ValueBase") and tonumber(pMax.Value) and tonumber(pMax.Value) > 100 then
                        detectedMaxHp = tonumber(pMax.Value)
                        break
                    end
                end
            end
        end
    end

    if not currentHp and char:GetAttribute("Health") then
        currentHp = tonumber(char:GetAttribute("Health"))
    end
    if not detectedMaxHp then
        for _, name in ipairs(maxHpNames) do
            if char:GetAttribute(name) and tonumber(char:GetAttribute(name)) > 100 then
                detectedMaxHp = tonumber(char:GetAttribute(name))
                break
            end
        end
    end

    if not currentHp then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then currentHp = hum.Health end
    end

    if currentHp then
        local userId = plr.UserId
        local timeSinceSpawn = os.clock() - (playerSpawnTime[userId] or 0)
        local isRecoveringFromRespawn = (timeSinceSpawn < 4)

        if not isRecoveringFromRespawn then
            if not maxHealthCache[userId] or currentHp > maxHealthCache[userId] then
                maxHealthCache[userId] = currentHp
            end
        end

        if detectedMaxHp and detectedMaxHp > 100 then
            maxHealthCache[userId] = math.max(maxHealthCache[userId] or 100, detectedMaxHp)
        end

        local baseMax = maxHealthCache[userId] or 100
        local finalMaxHp = math.clamp(baseMax, currentHp, ABSOLUTE_MAX_HP)
        return math.floor(currentHp), math.floor(finalMaxHp)
    end

    return nil, nil
end

local function clearAllHealthESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            if head then
                local tag = head:FindFirstChild("MoonDFHealthESP")
                if tag then tag:Destroy() end
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

local function drawHealthESP()
    if not espEnabled then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
        local char = plr.Character
        if not char then
            if espFolder then
                local hl = espFolder:FindFirstChild("HL_" .. tostring(plr.UserId))
                if hl then hl:Destroy() end
            end
        else

        local head = char:FindFirstChild("Head")
        local hrp = char:FindFirstChild("HumanoidRootPart")

        local tag = head and head:FindFirstChild("MoonDFHealthESP")
        if head and not tag then
            tag = Instance.new("BillboardGui")
            tag.Name = "MoonDFHealthESP"
            tag.Size = UDim2.new(0, 180, 0, 32)
            tag.StudsOffset = Vector3.new(0, 3.2, 0)
            tag.AlwaysOnTop = true
            tag.MaxDistance = 2000
            tag.Parent = head

            local txt = Instance.new("TextLabel")
            txt.Name = "TextDisplay"
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.Font = Enum.Font.GothamBold
            txt.TextSize = 13
            txt.TextStrokeTransparency = 0.15
            txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            txt.Parent = tag
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
            if highlight.Adornee ~= char then
                highlight.Adornee = char
            end
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
                tag.TextDisplay.Text = string.format("%s | %d/%d HP", plr.DisplayName, math.floor(currentHp), math.floor(maxHp))
            else
                tag.TextDisplay.Text = plr.DisplayName .. " | ..."
            end
            tag.TextDisplay.TextColor3 = healthColor
        end

        if highlight then
            highlight.FillColor = healthColor
            highlight.OutlineColor = healthColor
            highlight.Enabled = true
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

local function processStaminaAndCombat()
    local char = character
    if not char then return end

    if antiCombat then
        for _, obj in ipairs(char:GetChildren()) do
            local n = obj.Name
            if COMBAT_TAGS[n] or string.find(string.lower(n), "combat") or string.find(string.lower(n), "aggro") then
                pcall(function() obj:Destroy() end)
            end
        end
        pcall(function()
            local pg = player:FindFirstChild("PlayerGui")
            if pg then
                for _, g in ipairs(pg:GetDescendants()) do
                    if g:IsA("ImageLabel") or g:IsA("ImageButton") then
                        local nm = string.lower(g.Name)
                        if string.find(nm, "skull") or string.find(nm, "combat") or string.find(nm, "caveira") then
                            g.Visible = false
                        end
                    end
                end
            end
        end)
    end

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

local function ensureStaminaCombatLoop()
    if staminaCombatConn then return end
    staminaCombatConn = RunService.Heartbeat:Connect(function()
        if not (infiniteStamina or antiCombat) then return end
        pcall(processStaminaAndCombat)
    end)
    if character then
        character.ChildAdded:Connect(function(child)
            if not antiCombat then return end
            local n = child.Name
            if COMBAT_TAGS[n] or string.find(string.lower(n), "combat") or string.find(string.lower(n), "aggro") then
                task.defer(function() pcall(function() child:Destroy() end) end)
            end
        end)
    end
end

function toggleInfiniteStamina(state)
    infiniteStamina = state
    globalEnv.infiniteStamina = state
    if state then ensureStaminaCombatLoop() end
end

function toggleAntiCombat(state)
    antiCombat = state
    globalEnv.antiCombat = state
    if state then
        ensureStaminaCombatLoop()
        pcall(processStaminaAndCombat)
    end
end

local devSpinConn, devDiscoConn, devMoonConn, devIceConn = nil, nil, nil, nil
local devHeliConn, devDrunkConn, devBalloonConn, devRollConn, devHopConn = nil, nil, nil, nil, nil
local devSpin, devDisco, devMoonwalk, devGiant, devTiny = false, false, false, false, false
local devIceSlide, devHeli, devDrunk, devBalloon, devRoll, devHop = false, false, false, false, false, false
local devOriginalSizes = {}
local devIceVel = Vector3.new(40, 0, 0)
local devLastWallHit = 0
globalEnv.iceSlideIntensity = globalEnv.iceSlideIntensity or 50
local iceSlideIntensity = globalEnv.iceSlideIntensity

local function notifyDev(msg)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "MOONDF Dev",
            Text = tostring(msg),
            Duration = 3,
        })
    end)
end

local function copyCoordinates()
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

local function toggleDevSpin(state)
    devSpin = state
    if devSpinConn then devSpinConn:Disconnect(); devSpinConn = nil end
    if not state then return end
    devSpinConn = RunService.Heartbeat:Connect(function(dt)
        if not devSpin or not root then return end
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(720 * dt), 0)
    end)
end

local function toggleDevDisco(state)
    devDisco = state
    if devDiscoConn then devDiscoConn:Disconnect(); devDiscoConn = nil end
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
    devDiscoConn = RunService.Heartbeat:Connect(function()
        if not devDisco or not character then return end
        local h = (tick() - t0) % 1
        local c = Color3.fromHSV(h, 1, 1)
        for _, p in ipairs(character:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                p.Color = c
            end
        end
    end)
end

local function toggleDevMoonwalk(state)
    devMoonwalk = state
    if devMoonConn then devMoonConn:Disconnect(); devMoonConn = nil end
    if not state then return end
    devMoonConn = RunService.Heartbeat:Connect(function()
        if not devMoonwalk or not humanoid or not root then return end
        local move = humanoid.MoveDirection
        if move.Magnitude > 0.05 then
            root.CFrame = CFrame.lookAt(root.Position, root.Position - move)
        end
    end)
end

local function setCharacterScale(mult)
    if not character then return end
    for _, p in ipairs(character:GetDescendants()) do
        if p:IsA("BasePart") then
            if not devOriginalSizes[p] then
                devOriginalSizes[p] = p.Size
            end
            p.Size = devOriginalSizes[p] * mult
        end
    end
end

local function restoreCharacterScale()
    for part, size in pairs(devOriginalSizes) do
        if part and part.Parent then
            pcall(function() part.Size = size end)
        end
    end
    devOriginalSizes = {}
end

local function toggleDevGiant(state)
    devGiant = state
    if state then
        devTiny = false
        setCharacterScale(3)
    else
        restoreCharacterScale()
    end
end

local function toggleDevTiny(state)
    devTiny = state
    if state then
        devGiant = false
        setCharacterScale(0.4)
    else
        restoreCharacterScale()
    end
end

local function devFlingSelf()
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

local function devRagdollOnce()
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

local function toggleDevIceSlide(state)
    devIceSlide = state
    if devIceConn then devIceConn:Disconnect(); devIceConn = nil end
    if not state then return end

    local function baseSpeed()
        return 15 + (iceSlideIntensity / 100) * 105
    end
    local function maxSpeed()
        return 40 + (iceSlideIntensity / 100) * 160
    end
    local function bounceMult()
        return 1.05 + (iceSlideIntensity / 100) * 0.9
    end
    local function bounceBoost()
        return 8 + (iceSlideIntensity / 100) * 45
    end
    local function friction()
        return 0.25 - (iceSlideIntensity / 100) * 0.22
    end
    local function spinRate()
        return 80 + (iceSlideIntensity / 100) * 280
    end
    local function bounceUp()
        return 10 + (iceSlideIntensity / 100) * 40
    end

    local ang = math.random() * math.pi * 2
    local bs = baseSpeed()
    devIceVel = Vector3.new(math.cos(ang) * bs, 0, math.sin(ang) * bs)
    devLastWallHit = 0

    devIceConn = RunService.Heartbeat:Connect(function(dt)
        if not devIceSlide or not root or not character or not humanoid then return end

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
                devIceVel = Vector3.new(move.X, 0, move.Z).Unit * bs
            end
            return
        end

        local horiz = Vector3.new(devIceVel.X, 0, devIceVel.Z)
        if horiz.Magnitude < 5 then
            local a = math.random() * math.pi * 2
            horiz = Vector3.new(math.cos(a), 0, math.sin(a)) * bs
            devIceVel = horiz
        end

        local dir = horiz.Unit
        local origin = root.Position + Vector3.new(0, 1, 0)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { character }

        local hit = workspace:Raycast(origin, dir * 4.5, params)
        if hit and (tick() - devLastWallHit) > 0.12 then
            devLastWallHit = tick()
            local n = Vector3.new(hit.Normal.X, 0, hit.Normal.Z)
            if n.Magnitude > 0.05 then
                n = n.Unit
                local reflected = horiz - 2 * horiz:Dot(n) * n
                local speed = math.clamp(horiz.Magnitude * bounceMult() + bounceBoost(), bs * 0.8, maxSpeed())
                devIceVel = reflected.Unit * speed
                root.AssemblyLinearVelocity = Vector3.new(devIceVel.X, bounceUp(), devIceVel.Z)
            end
        else
            local speed = horiz.Magnitude
            local fr = friction()
            if speed > 8 then
                devIceVel = dir * (speed * (1 - fr * dt))
            else
                devIceVel = dir * bs
            end
            local vy = root.AssemblyLinearVelocity.Y
            root.AssemblyLinearVelocity = Vector3.new(devIceVel.X, vy, devIceVel.Z)
        end

        root.CFrame = root.CFrame * CFrame.Angles(0, 0, math.rad(spinRate() * dt))
    end)
end

local function toggleDevHeli(state)
    devHeli = state
    if devHeliConn then devHeliConn:Disconnect(); devHeliConn = nil end
    if not state then return end
    devHeliConn = RunService.Heartbeat:Connect(function(dt)
        if not devHeli or not root then return end
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(900 * dt), 0)
        local v = root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity = Vector3.new(v.X * 0.5, 35, v.Z * 0.5)
    end)
end

local function toggleDevDrunk(state)
    devDrunk = state
    if devDrunkConn then devDrunkConn:Disconnect(); devDrunkConn = nil end
    if not state then return end
    local nextJolt = 0
    devDrunkConn = RunService.Heartbeat:Connect(function()
        if not devDrunk or not root then return end
        if tick() > nextJolt then
            nextJolt = tick() + 0.25 + math.random() * 0.35
            local j = Vector3.new(math.random(-40, 40), math.random(-5, 15), math.random(-40, 40))
            root.AssemblyLinearVelocity = root.AssemblyLinearVelocity + j
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(math.random(-40, 40)), 0)
        end
    end)
end

local function toggleDevBalloon(state)
    devBalloon = state
    if devBalloonConn then devBalloonConn:Disconnect(); devBalloonConn = nil end
    if not state then return end
    devBalloonConn = RunService.Heartbeat:Connect(function(dt)
        if not devBalloon or not root then return end
        local v = root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity = Vector3.new(v.X * 0.85, 18, v.Z * 0.85)
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(90 * dt), 0)
    end)
end

local function toggleDevRoll(state)
    devRoll = state
    if devRollConn then devRollConn:Disconnect(); devRollConn = nil end
    if not state then return end
    devRollConn = RunService.Heartbeat:Connect(function(dt)
        if not devRoll or not root then return end
        root.CFrame = root.CFrame * CFrame.Angles(math.rad(540 * dt), 0, 0)
        local look = root.CFrame.LookVector
        local v = root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity = Vector3.new(look.X * 28, v.Y, look.Z * 28)
    end)
end

local function toggleDevHop(state)
    devHop = state
    if devHopConn then devHopConn:Disconnect(); devHopConn = nil end
    if not state then return end
    local nextHop = 0
    devHopConn = RunService.Heartbeat:Connect(function()
        if not devHop or not root or not humanoid then return end
        if humanoid.MoveDirection.Magnitude > 0.1 and tick() > nextHop then
            nextHop = tick() + 0.28
            local v = root.AssemblyLinearVelocity
            root.AssemblyLinearVelocity = Vector3.new(v.X, 55, v.Z)
        end
    end)
end

local function disconnectSpectateInputs()
    if spectateInputBegan then spectateInputBegan:Disconnect(); spectateInputBegan = nil end
    if spectateInputEnded then spectateInputEnded:Disconnect(); spectateInputEnded = nil end
    if spectateInputChanged then spectateInputChanged:Disconnect(); spectateInputChanged = nil end
end

local function connectSpectateInputs()
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

local function stopSpectateCamera()
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
    if antiCombat then
        character.ChildAdded:Connect(function(child)
            if not antiCombat then return end
            local n = child.Name
            if COMBAT_TAGS[n] or string.find(string.lower(n), "combat") or string.find(string.lower(n), "aggro") then
                task.defer(function() pcall(function() child:Destroy() end) end)
            end
        end)
    end
    if infiniteJump then toggleInfiniteJump(true) end
end)

local function getPlayerNames()
    local list = {}
    for _, v in pairs(Players:GetPlayers()) do if v ~= player then table.insert(list, v.Name) end end
    return list
end

-- ======================================================================
-- UI (POPUP + HUD)
-- ======================================================================

local isMobile = false
local SCALE_FACTOR = 1
local DEFAULT_WIDTH = 760
local DEFAULT_HEIGHT = 520
local MIN_WIDTH = 420
local MIN_HEIGHT = 260
local RIGHT_AREA_SCALE = 0.33

local userChoice = nil
local POPUP_W, POPUP_H = 520, 220
local popup = new("Frame", {
    Name = "ModePopup",
    Parent = screenGui,
    AnchorPoint = Vector2.new(0, 0), -- FIX: 0,0 (sem salto)
    Position = UDim2.new(0.5, -POPUP_W/2, 0.5, -POPUP_H/2),
    Size = UDim2.new(0, POPUP_W, 0, POPUP_H),
    BackgroundColor3 = THEME.PanelBg,
    BorderSizePixel = 0,
    ZIndex = 50
})
makeRound(popup, 12)
local popupStroke = makeStroke(popup, THEME.Border, 1)

local popupTitle = new("TextLabel", {
    Parent = popup,
    Position = UDim2.new(0, 16, 0, 12),
    Size = UDim2.new(1, -32, 0, 30),
    BackgroundTransparency = 1,
    Text = T("TITLE_MAIN"),
    TextColor3 = THEME.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextXAlignment = Enum.TextXAlignment.Left
})

local popupDesc = new("TextLabel", {
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

local btnContainer = new("Frame", {Parent = popup, Position = UDim2.new(0, 16, 1, -68), Size = UDim2.new(1, -32, 0, 52), BackgroundTransparency = 1})
local pcBtn = new("TextButton", {
    Parent = btnContainer,
    AnchorPoint = Vector2.new(0, 0),
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(0.5, -8, 1, 0),
    BackgroundColor3 = THEME.Accent,
    Text = "PC",
    TextColor3 = Color3.new(1,1,1),
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    BorderSizePixel = 0
})
makeRound(pcBtn, 8)

local mobileBtn = new("TextButton", {
    Parent = btnContainer,
    AnchorPoint = Vector2.new(0, 0),
    Position = UDim2.new(0.5, 8, 0, 0),
    Size = UDim2.new(0.5, -8, 1, 0),
    BackgroundColor3 = THEME.On,
    Text = "Mobile",
    TextColor3 = Color3.new(1,1,1),
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    BorderSizePixel = 0
})
makeRound(mobileBtn, 8)

local popupClose = new("TextButton", {Parent = popup, AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1, -10, 0, 8), Size = UDim2.new(0, 36, 0, 28), BackgroundColor3 = THEME.Danger, Text = "X", TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0})
makeRound(popupClose, 6)

local function applyPlatformChoice(choice)
    userChoice = choice
    isMobile = (choice == "MOBILE")
    SCALE_FACTOR = isMobile and 0.62 or 1.0
    if Camera and Camera.ViewportSize then
        local vx, vy = Camera.ViewportSize.X, Camera.ViewportSize.Y
        if isMobile then
            DEFAULT_WIDTH = math.floor(math.clamp(vx * 0.72, 260, 420))
            DEFAULT_HEIGHT = math.floor(math.clamp(vy * 0.48, 200, 340))
            MIN_WIDTH = 240
            MIN_HEIGHT = 170
            RIGHT_AREA_SCALE = 0.38
        else
            DEFAULT_WIDTH = 760
            DEFAULT_HEIGHT = 520
            MIN_WIDTH = 420
            MIN_HEIGHT = 260
            RIGHT_AREA_SCALE = 0.33
        end
    end
    if popup and popup.Parent then popup:Destroy() end
    createHubUI()
end

pcBtn.MouseButton1Click:Connect(function() applyPlatformChoice("PC") end)
mobileBtn.MouseButton1Click:Connect(function() applyPlatformChoice("MOBILE") end)
popupClose.MouseButton1Click:Connect(function()
    for _, v in pairs(screenGui:GetDescendants()) do pcall(function() if v and v.Parent then v:Destroy() end end) end
end)

spawn(function()
    task.wait(6)
    if not userChoice then
        local usingTouch = UserInputService.TouchEnabled
        applyPlatformChoice(usingTouch and "MOBILE" or "PC")
    end
end)

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
        Size = UDim2.new(0, isMobile and 36 or 50, 0, isMobile and 36 or 50),
        Position = UDim2.new(0.1, 0, 0.1, 0),
        BackgroundColor3 = THEME.Background,
        BackgroundTransparency = CurrentOpacity,
        Text = "DF",
        TextColor3 = THEME.Accent,
        Font = Enum.Font.FredokaOne,
        TextSize = (isMobile and 22 or 24),
        Visible = false,
        AutoButtonColor = true,
        ZIndex = 30
    })
    makeRound(miniButton, isMobile and 10 or 12)
    local miniStroke = makeStroke(miniButton, THEME.Accent, 2)

    local cam = workspace.CurrentCamera
    local vx = (cam and cam.ViewportSize.X) or 1280
    local vy = (cam and cam.ViewportSize.Y) or 720
    local startX = math.floor((vx - DEFAULT_WIDTH) / 2)
    local startY = math.floor((vy - DEFAULT_HEIGHT) / 2)

    -- FIX: AnchorPoint (0,0) + posição em offset absoluto
    local uiRoot = new("Frame", {
        Name = "MoonDF_VirginHub_Root",
        Parent = screenGui,
        AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.new(0, startX, 0, startY),
        Size = UDim2.new(0, DEFAULT_WIDTH, 0, DEFAULT_HEIGHT),
        BackgroundColor3 = THEME.Background,
        BackgroundTransparency = CurrentOpacity,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 20
    })
    makeRound(uiRoot, 10)
    local uiRootStroke = makeStroke(uiRoot, THEME.Border, 2)

    local titleBar = new("Frame", {
        Parent = uiRoot,
        Size = UDim2.new(1, 0, 0, isMobile and 30 or 42),
        BackgroundTransparency = 1,
        Active = true,
        ZIndex = 25
    })
    local titleLabel = new("TextLabel", {
        Parent = titleBar, Position = UDim2.new(0, 12, 0, isMobile and 6 or 8), Size = UDim2.new(1, -120, 1, isMobile and -12 or -12),
        BackgroundTransparency = 1, Text = T("TITLE_MAIN"), TextColor3 = THEME.Text,
        Font = Enum.Font.GothamSemibold, TextSize = (isMobile and 13 or 18), TextXAlignment = Enum.TextXAlignment.Left
    })

    local controlsContainer = new("Frame", {
        Parent = titleBar, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0, isMobile and 62 or 70, 0, isMobile and 26 or 30), BackgroundTransparency = 1
    })

    local minBtn = new("TextButton", {
        Parent = controlsContainer, Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, isMobile and 26 or 30, 0, isMobile and 26 or 30), BackgroundColor3 = THEME.Off,
        Text = "-", TextColor3 = THEME.Text,
        Font = Enum.Font.GothamBold, TextSize = (isMobile and 16 or 18), BorderSizePixel = 0
    })
    makeRound(minBtn, 6)

    local closeBtn = new("TextButton", {
        Parent = controlsContainer, Position = UDim2.new(0, isMobile and 32 or 36, 0, 0),
        Size = UDim2.new(0, isMobile and 26 or 30, 0, isMobile and 26 or 30), BackgroundColor3 = THEME.Danger,
        Text = "X",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold, TextSize = (isMobile and 12 or 14), BorderSizePixel = 0
    })
    makeRound(closeBtn, 6)

    local leftPane = new("Frame", {Parent = uiRoot, Position = UDim2.new(0, isMobile and 6 or 10, 0, isMobile and 36 or 56), Size = UDim2.new(0, isMobile and 110 or 220, 1, isMobile and -52 or -76), BackgroundTransparency = 1})
    local rightPane = new("Frame", {Parent = uiRoot, Position = UDim2.new(0, (isMobile and 120 or 240), 0, isMobile and 36 or 56), Size = UDim2.new(1, -(isMobile and 126 or 250), 1, isMobile and -52 or -76), BackgroundTransparency = 1})

    local leftBg = new("Frame", {Parent = leftPane, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = THEME.Background, BorderSizePixel = 0, BackgroundTransparency = CurrentOpacity})
    makeRound(leftBg, 8);
    local leftStroke = makeStroke(leftBg, THEME.Border, 1)

    local topicsList = new("ScrollingFrame", {Parent = leftBg, Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(1, -16, 1, -16), BackgroundTransparency = 1, ScrollBarThickness = isMobile and 8 or 6, CanvasSize = UDim2.new(0,0,0,0)})
    local topicsLayout = new("UIListLayout", {Parent = topicsList, Padding = UDim.new(0, isMobile and 4 or 8), SortOrder = Enum.SortOrder.LayoutOrder})

    local rightBg = new("Frame", {Parent = rightPane, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = THEME.Background, BorderSizePixel = 0, BackgroundTransparency = CurrentOpacity})
    makeRound(rightBg, 8);
    local rightStroke = makeStroke(rightBg, THEME.Border, 1)

    local scroll = new("ScrollingFrame", {Parent = rightBg, Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(1, -16, 1, -16), BackgroundTransparency = 1, ScrollBarThickness = isMobile and 10 or 8, CanvasSize = UDim2.new(0,0,0,0)})
    local buttonsLayout = new("UIListLayout", {Parent = scroll, Padding = UDim.new(0, isMobile and 5 or 10)})
    buttonsLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local footer = new("TextLabel", {
        Parent = uiRoot, Position = UDim2.new(0, 12, 1, isMobile and -26 or -28), Size = UDim2.new(1, -24, 0, isMobile and 20 or 22),
        BackgroundTransparency = 1,
        Text = T("FOOTER_TEXT"),
        TextColor3 = THEME.SubText, Font = Enum.Font.Gotham, TextSize = (isMobile and 10 or 11)
    })

    local resizer = new("Frame", {Parent = uiRoot, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, isMobile and -8 or -10, 1, isMobile and -8 or -10), Size = UDim2.new(0, isMobile and 14 or 18, 0, isMobile and 14 or 18), BackgroundTransparency = 1})
    local resDot = new("Frame", {Parent = resizer, Size = UDim2.new(1, 1, 1, 1), BackgroundColor3 = THEME.Hover, BorderSizePixel = 0});
    makeRound(resDot, isMobile and 6 or 6)

    -- Drag da janela principal (MakeDraggable = delta puro)
    MakeDraggable(titleBar, uiRoot)

    -- Drag do mini-button + click para restaurar
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
        local icon = new("Frame", {Parent = parent, Size = UDim2.new(0, isMobile and 24 or 28, 0, isMobile and 16 or 20), BackgroundTransparency = 1})
        local barTop = new("Frame", {Parent = icon, Size = UDim2.new(1, 0, 0, 3), Position = UDim2.new(0, 0, 0, 2), BackgroundColor3 = THEME.SubText, BorderSizePixel = 0});
        makeRound(barTop, 2)
        local barMid = new("Frame", {Parent = icon, Size = UDim2.new(1, 0, 0, 3), Position = UDim2.new(0, 0, 0, 8.5), BackgroundColor3 = THEME.SubText, BorderSizePixel = 0});
        makeRound(barMid, 2)
        local barBot = new("Frame", {Parent = icon, Size = UDim2.new(1, 0, 0, 3), Position = UDim2.new(0, 0, 0, 15), BackgroundColor3 = THEME.SubText, BorderSizePixel = 0});
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
        table.insert(connections, hb.MouseLeave:Connect(function() tween(bg, {BackgroundColor3 = THEME.PanelBg}, 0.12) end))
        return hb
    end

    local function refreshMainScroll()
        if scroll and scroll.Parent and buttonsLayout then
            scroll.CanvasSize = UDim2.new(0, 0, 0, buttonsLayout.AbsoluteContentSize.Y + 12)
        end
    end

    local function createEntry(params, parentFrame, depth, onChildrenChanged)
        depth = depth or 0
        local baseH = isMobile and 40 or 60
        local barColor = params.Color or TYPE_COLORS[params.Type] or THEME.Accent

        local wrapper = new("Frame", {Parent = parentFrame, Name = "Entry", Size = UDim2.new(1, -12, 0, baseH), BackgroundTransparency = 1, ClipsDescendants = true})
        local entryObj = {Frame = wrapper}

        local bg = new("Frame", {
            Parent = wrapper,
            Name = "ElementBackground",
            Size = UDim2.new(1, 0, 0, baseH),
            BackgroundColor3 = THEME.PanelBg,
            BorderSizePixel = 0,
            BackgroundTransparency = CurrentOpacity
        })
        makeRound(bg, 8);
        local accent = new("Frame", {Parent = bg, Position = UDim2.new(0, 8 + depth * 12, 0.5, isMobile and -16 or -18), Size = UDim2.new(0, 6, 0, isMobile and 32 or 36), BackgroundColor3 = barColor})
        makeRound(accent, 6)

        local nameLabel = new("TextLabel", {
            Parent = bg, Position = UDim2.new(0, 28 + depth * 12, 0, 8), Size = UDim2.new(0.6, -28, 0, isMobile and 18 or 20),
            BackgroundTransparency = 1, Text = params.Name or "Unnamed", TextColor3 = THEME.Text,
            Font = Enum.Font.GothamSemibold, TextSize = (isMobile and 13 or 15), TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2
        })
        local descLabel = new("TextLabel", {
            Parent = bg, Position = UDim2.new(0, 28 + depth * 12, 0, isMobile and 28 or 30), Size = UDim2.new(1, -164, 0, isMobile and 16 or 18),
            BackgroundTransparency = 1, Text = params.Description or "", TextColor3 = THEME.SubText,
            Font = Enum.Font.Gotham, TextSize = (isMobile and 11 or 12), TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2
        })

        local rightArea = new("Frame", {
            Parent = bg, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
            Size = UDim2.new(RIGHT_AREA_SCALE, -12, 0, isMobile and 40 or 44), BackgroundTransparency = 1, ZIndex = 5
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
            -- nothing

        elseif params.Type == "Toggle" then
            local state = false
            if params.StateKey then state = globalEnv._HubStates[params.StateKey] or false end
            local knob = new("Frame", {Parent = rightArea, Size = UDim2.new(0, isMobile and 40 or 46, 0, isMobile and 22 or 26), Position = UDim2.new(1, isMobile and -40 or -46, 0.5, isMobile and -11 or -13), BackgroundColor3 = THEME.Off});
            makeRound(knob, 14)
            local subKnob = new("Frame", {Parent = knob, Size = UDim2.new(0, isMobile and 16 or 18, 0, isMobile and 16 or 18), Position = UDim2.new(0, isMobile and 3 or 4, 0, isMobile and 3 or 4), BackgroundColor3 = Color3.new(1, 1, 1)});
            makeRound(subKnob, 999)
            local function applyVisual(s)
                if s then
                    tween(knob, {BackgroundColor3 = THEME.On}, 0.15)
                    tween(subKnob, {Position = UDim2.new(1, isMobile and -18 or -22, 0, isMobile and 3 or 4)}, 0.15)
                    tween(bg, {BackgroundColor3 = THEME.Hover}, 0.15)
                else
                    tween(knob, {BackgroundColor3 = THEME.Off}, 0.15)
                    tween(subKnob, {Position = UDim2.new(0, isMobile and 3 or 4, 0, isMobile and 3 or 4)}, 0.15)
                    tween(bg, {BackgroundColor3 = THEME.PanelBg}, 0.15)
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
            applyVisual(state)
            table.insert(connections, hoverBox.MouseButton1Click:Connect(function() if hubVisible then applyState(not state) end end))

        elseif params.Type == "Single" then
            table.insert(connections, hoverBox.MouseButton1Click:Connect(function()
                if hubVisible then
                    tween(bg, {BackgroundColor3 = THEME.Hover}, 0.06);
                    task.wait(0.06); tween(bg, {BackgroundColor3 = THEME.PanelBg}, 0.12)
                    if params.Callback then pcall(params.Callback) end
                end
            end))

        elseif params.Type == "InputImmediate" then
            local txtBox = new("TextBox", {Parent = rightArea, Size = UDim2.new(1, -76, 0, isMobile and 26 or 28), Position = UDim2.new(0, 0, 0.5, isMobile and -13 or -14), BackgroundColor3 = THEME.Background, Text = "", PlaceholderText = params.Placeholder or "...", TextColor3 = THEME.Text, Font = Enum.Font.Gotham, TextSize = (isMobile and 12 or 14), ClearTextOnFocus = false, ZIndex = 6});
            makeRound(txtBox, 6)

            local okBtn = new("TextButton", {
                Parent = rightArea,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.new(0, isMobile and 60 or 68, 0, isMobile and 26 or 28),
                BackgroundColor3 = THEME.Accent,
                Text = "OK",
                TextColor3 = Color3.new(1, 1, 1),
                Font = Enum.Font.GothamBold,
                TextSize = (isMobile and 12 or 14),
                ZIndex = 6
            })
            makeRound(okBtn, 6)

            table.insert(connections, okBtn.MouseButton1Click:Connect(function() if hubVisible and params.Callback then params.Callback(txtBox.Text) end end))
            table.insert(connections, txtBox.FocusLost:Connect(function(enter) if enter and hubVisible and params.Callback then params.Callback(txtBox.Text) end end))

        elseif params.Type == "InputSelect" then
            local txtBox = new("TextBox", {Parent = rightArea, Size = UDim2.new(1, 0, 0, isMobile and 26 or 28), Position = UDim2.new(0, 0, 0.5, isMobile and -13 or -14), BackgroundColor3 = THEME.Background, Text = params.Default or "", PlaceholderText = params.Placeholder or "...", TextColor3 = THEME.Text, Font = Enum.Font.Gotham, TextSize = (isMobile and 12 or 14), ClearTextOnFocus = true, ZIndex = 6});
            makeRound(txtBox, 6)
            table.insert(connections, txtBox.FocusLost:Connect(function() if params.StateKey then globalEnv._HubSelections[params.StateKey] = txtBox.Text end end))

        elseif params.Type == "ListAuto" or params.Type == "Container" then
            local ham = createHamburger(rightArea)
            ham.Frame.Position = UDim2.new(1, isMobile and -24 or -28, 0, isMobile and 6 or 8)
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
            ham.Frame.Position = UDim2.new(1, isMobile and -24 or -28, 0, isMobile and 6 or 8)
            local selectedValLabel = new("TextLabel", {Parent = bg, BackgroundTransparency = 1, TextColor3 = THEME.Text, Font = Enum.Font.GothamSemibold, TextSize = (isMobile and 13 or 15), TextXAlignment = Enum.TextXAlignment.Left, Text = "", ZIndex = 2})

            local function updateSelectedLabelPos()
                local bounds = nameLabel.TextBounds
                selectedValLabel.Position = UDim2.new(0, 28 + depth * 12 + bounds.X + 4, 0, 8)
                selectedValLabel.Size = UDim2.new(0, isMobile and 140 or 200, 0, isMobile and 16 or 20)
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
            local track = new("Frame", {Parent = rightArea, Size = UDim2.new(1, -28, 0, isMobile and 6 or 8), Position = UDim2.new(0, 8, 0.5, isMobile and -3 or -4), BackgroundColor3 = THEME.Off, BorderSizePixel = 0})
            makeRound(track, 6)
            local fill = new("Frame", {Parent = track, Size = UDim2.new(0,0,1,0), Position = UDim2.new(0,0,0,0), BackgroundColor3 = THEME.Accent, BorderSizePixel = 0})
            makeRound(fill, 6)
            local knob = new("Frame", {Parent = rightArea, Size = UDim2.new(0,isMobile and 14 or 16,0,isMobile and 14 or 16), Position = UDim2.new(0,8,0.5,isMobile and -7 or -8), BackgroundColor3 = (THEME.KnobColor or Color3.fromRGB(245,245,245)), BorderSizePixel = 0})
            makeRound(knob, 999)
            knob.Active = true; knob.ClipsDescendants = true
            local valLabel = new("TextLabel", {Parent = rightArea, AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1, -4, 0.5, 0), Size = UDim2.new(0, isMobile and 44 or 52, 0, isMobile and 16 or 18), BackgroundTransparency = 1, Text = tostring(cur), TextColor3 = THEME.SubText, Font = Enum.Font.GothamBold, TextSize = (isMobile and 11 or 12), TextXAlignment = Enum.TextXAlignment.Right})
            track.Active = true
            fill.Active = true
            local function updateVisuals(instant)
                local pct = 0
                if maxV > minV then pct = (cur - minV) / (maxV - minV) end
                local trackW = math.max(0, track.AbsoluteSize.X)
                local maxTrackW = math.max(60, trackW)
                local fillW = math.floor(maxTrackW * pct + 0.5)
                local knobX = math.floor(8 + fillW - (knob.AbsoluteSize.X / 2) + 0.5)

                if instant then
                    fill.Size = UDim2.new(0, fillW, 1, 0)
                    knob.Position = UDim2.new(0, knobX, 0.5, isMobile and -7 or -8)
                else
                    tween(fill, {Size = UDim2.new(0, fillW, 1, 0)}, 0.12)
                    tween(knob, {Position = UDim2.new(0, knobX, 0.5, isMobile and -7 or -8)}, 0.12)
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
        local a = THEME.Accent
        local lum = (a.R * 0.299 + a.G * 0.587 + a.B * 0.114)
        local onAccentText = (lum > 0.55) and Color3.fromRGB(20, 20, 20) or Color3.new(1, 1, 1)
        for k, b in pairs(topicButtons) do
            if k == key then
                tween(b, {BackgroundColor3 = THEME.Accent}, 0.12)
                b.TextColor3 = onAccentText
            else
                tween(b, {BackgroundColor3 = THEME.PanelBg}, 0.12)
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
            Size = UDim2.new(1, 0, 0, isMobile and 36 or 42),
            BackgroundColor3 = THEME.PanelBg,
            BorderSizePixel = 0,
            Text = label,
            TextColor3 = THEME.Text,
            Font = Enum.Font.Gotham,
            TextSize = (isMobile and 12 or 14),
            BackgroundTransparency = CurrentOpacity
        })
        makeRound(btn, 8)
        topicButtons[key] = btn
        topicItemsMap[key] = items

        table.insert(connections, btn.MouseEnter:Connect(function()
            if selectedTopicKey ~= key then
                tween(btn, {BackgroundColor3 = THEME.Hover}, 0.12)
            end
        end))
        table.insert(connections, btn.MouseLeave:Connect(function()
            if selectedTopicKey ~= key then
                tween(btn, {BackgroundColor3 = THEME.PanelBg}, 0.12)
            end
        end))

        table.insert(connections, btn.MouseButton1Click:Connect(function()
            selectTopic(key)
        end))
    end

    local function updateLayout()
        local totalW = uiRoot.AbsoluteSize.X
        local leftWidth = math.clamp(math.floor(totalW * (isMobile and 0.28 or 0.26)), 120, 320)
        leftWidth = math.min(leftWidth, math.max(100, totalW - 160))
        leftPane.Size = UDim2.new(0, leftWidth, 1, isMobile and -70 or -80)
        local rightX = leftWidth + 20
        rightPane.Position = UDim2.new(0, rightX, 0, isMobile and 50 or 56)
        rightPane.Size = UDim2.new(0, totalW - rightX - 10, 1, isMobile and -70 or -80)
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

    -- Resizer
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
            uiRoot.Size = UDim2.new(0, math.max(MIN_WIDTH, startSize.X.Offset + d.X), 0, math.max(MIN_HEIGHT, startSize.Y.Offset + d.Y))
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
        leftBg.BackgroundColor3 = THEME.Background
        rightBg.BackgroundColor3 = THEME.Background
        miniButton.BackgroundColor3 = THEME.Background
        miniButton.BackgroundTransparency = CurrentOpacity
        miniButton.TextColor3 = THEME.Accent
        miniStroke.Color = THEME.Accent
        titleLabel.TextColor3 = THEME.Text
        footer.TextColor3 = THEME.SubText
        uiRootStroke.Color = THEME.Border
        leftStroke.Color = THEME.Border
        rightStroke.Color = THEME.Border

        titleLabel.Text = T("TITLE_MAIN")
        footer.Text = T("FOOTER_TEXT")

        addTopic("GENERAL", T("TOPIC_GENERAL"), {
            { Type = "ListAuto", Name = T("FLY_SPEED"), Description = T("FLY_SPEED_DESC"), Options = {
                { Type = "Toggle", StateKey = "EnableFly", Name = T("ENABLE_FLY"), Description = T("ENABLE_FLY_DESC"), OnEnable = function() flyToggle = true globalEnv.flyToggle = true setupFly() end, OnDisable = function() flyToggle = false globalEnv.flyToggle = false if bg then bg:Destroy() end if bv then bv:Destroy() end if flyConn then flyConn:Disconnect() end humanoid.PlatformStand = false end },
                { Type = "Slider", StateKey = "FlySpeedValue", Name = T("FLY_SPEED_SLIDER"), Description = T("FLY_SPEED_SLIDER_DESC"), Min = 0, Max = 10000, Default = 150, OnChange = function(v) flySpeedValue = v globalEnv.flySpeedValue = v end },
                { Type = "Toggle", StateKey = "EnableSpeed", Name = T("ENABLE_SPEED"), Description = T("ENABLE_SPEED_DESC"), OnEnable = function() speedToggle = true globalEnv.speedToggle = true if speedConn then speedConn:Disconnect() end speedConn = RunService.Heartbeat:Connect(function() if humanoid then humanoid.WalkSpeed = walkSpeed end end) end, OnDisable = function() speedToggle = false globalEnv.speedToggle = false if speedConn then speedConn:Disconnect() end humanoid.WalkSpeed = BASE_WALKSPEED end },
                { Type = "Slider", StateKey = "WalkSpeed", Name = T("SPEED_VALUE_SLIDER"), Description = T("SPEED_VALUE_SLIDER_DESC"), Min = 16, Max = 500, Default = 16, OnChange = function(v) walkSpeed = v globalEnv.walkSpeed = v end }
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
                { Type = "Slider", StateKey = "IceSlideIntensity", Name = T("ICE_INTENSITY"), Description = T("ICE_INTENSITY_DESC"), Min = 1, Max = 100, Default = iceSlideIntensity or 50, OnChange = function(v) iceSlideIntensity = v globalEnv.iceSlideIntensity = v end }
            }}
        })

        local mobFarmOptions = {}
        for _, mob in ipairs(FARM) do
            table.insert(mobFarmOptions, { Type = "Toggle", StateKey = "Farm" .. mob, Name = T("FARM") .. " " .. mob, Description = T("FARM_DESC"), OnEnable = function() toggleTeleport(true, mob) end, OnDisable = function() toggleTeleport(false) end })
        end

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
                    trinketFarm = false
                    globalEnv.trinketFarm = false
                end },
                { Type = "Toggle", StateKey = "AutoAttack", Name = T("AUTO_ATTACK"), Description = T("AUTO_ATTACK_DESC"), OnEnable = function() autoAttack = true globalEnv.autoAttack = true spawn(autoAttackLoop) end, OnDisable = function() autoAttack = false globalEnv.autoAttack = false end },
                { Type = "Toggle", StateKey = "OreFarm", Name = T("ORE_FARM"), Description = T("ORE_FARM_DESC"), OnEnable = function()
                    oreFarm = true
                    globalEnv.oreFarm = true
                    flyToggle = true
                    globalEnv.flyToggle = true
                    setupOreFly()
                    spawn(oreFarmLoop)
                end, OnDisable = function()
                    oreFarm = false
                    globalEnv.oreFarm = false
                    flyToggle = false
                    globalEnv.flyToggle = false
                    if bg then bg:Destroy() end
                    if bv then bv:Destroy() end
                    if flyConn then flyConn:Disconnect() end
                    if humanoid then humanoid.PlatformStand = false end
                end }
            }},
            { Type = "ListAuto", Name = T("TP_MODE"), Description = T("TP_MODE_DESC"), Options = {
                { Type = "ListPersistent", StateKey = "TeleportMode", Name = T("TP_MODE"), Description = T("TP_MODE_DESC"), Options = tp_mode_options, Callback = function(v)
                    local mapped = tp_mode_map[v] or "Behind"
                    teleportMode = mapped
                    globalEnv.teleportMode = mapped
                end },
                { Type = "Slider", StateKey = "FarmDistance", Name = T("DISTANCE"), Description = T("DISTANCE_DESC"), Min = 0, Max = 50, Default = 4, OnChange = function(v) FARM_DISTANCE = v globalEnv.FARM_DISTANCE = v end },
                { Type = "Slider", StateKey = "ExecuteDistance", Name = T("EXECUTE_DISTANCE"), Description = T("EXECUTE_DISTANCE_DESC"), Min = 0, Max = 100, Default = 20, OnChange = function(v) EXECUTE_DISTANCE = v globalEnv.EXECUTE_DISTANCE = v end }
            }},
            { Type = "ListAuto", Name = T("FARM_MOBS_LIST"), Description = T("FARM_MOBS_LIST_DESC"), Options = mobFarmOptions },
            { Type = "ListAuto", Name = T("RAIDS"), Description = T("RAIDS_DESC"), Options = {
                { Type = "Single", Name = T("TP_RAID_AREA"), Description = T("TP_RAID_AREA_DESC"), Callback = function() if root then root.CFrame = LOCATIONS.Raid end end },
                { Type = "Toggle", StateKey = "FarmShinobuRaid", Name = T("FARM") .. " Shinobu Raid", Description = T("FARM_DESC"), OnEnable = function() toggleTeleport(true, "ShinoubuRaid") end, OnDisable = function() toggleTeleport(false) end },
                { Type = "Toggle", StateKey = "FarmRengokuRaid", Name = T("FARM") .. " Rengoku Raid", Description = T("FARM_DESC"), OnEnable = function() toggleTeleport(true, "RengokuRaid") end, OnDisable = function() toggleTeleport(false) end },
                { Type = "Toggle", StateKey = "FarmKokushiboRaid", Name = T("FARM") .. " Kokushibo Raid", Description = T("FARM_DESC"), OnEnable = function() toggleTeleport(true, "KokushiboRaid") end, OnDisable = function() toggleTeleport(false) end },
                { Type = "Toggle", StateKey = "FarmEnemyRaid", Name = T("FARM") .. " Enemy Raid", Description = "Foca no inimigo 'Enemy'", OnEnable = function() toggleTeleport(true, "Enemy") end, OnDisable = function() toggleTeleport(false) end },
                { Type = "Toggle", StateKey = "FarmYoriichi", Name = T("FARM") .. " Yoriichi", Description = T("FARM_DESC"), OnEnable = function() toggleTeleport(true, "Yoriichi") end, OnDisable = function() toggleTeleport(false) end }
            }}
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
                { Type = "Toggle", StateKey = "FarmPlayer", Name = T("FARM_PLAYER"), Description = T("FARM_PLAYER_DESC"), OnEnable = function() if selectedPlayerName then toggleTeleport(true, selectedPlayerName) end end, OnDisable = function() toggleTeleport(false) end },
                { Type = "Toggle", StateKey = "EnableSpectate", Name = T("ENABLE_SPECTATE"), Description = T("ENABLE_SPECTATE_DESC"), OnEnable = function() if selectedPlayerName then toggleSpectate(true, selectedPlayerName) end end, OnDisable = function() toggleSpectate(false) end }
            }}
        })

        addTopic("TELEPORTS", T("TOPIC_TELEPORTS"), {
            { Type = "Single", Name = T("LOAD_MOBS"), Description = T("LOAD_MOBS_DESC"), Callback = loadAllMobs },
            { Type = "Single", Name = T("LOAD_MAP"), Description = T("LOAD_MAP_DESC"), Callback = loadAllMap },
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
                { Type = "Single", Name = T("DEV_COORDS"), Description = T("DEV_COORDS_DESC"), Callback = copyCoordinates },
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
            { Type = "ListPersistent", Name = T("THEME"), Description = T("THEME_DESC"), Options = {"Carbon", "Arctic", "Nebula", "Neon", "Carmesim", "Galaxy", "Blush", "Branco"}, Callback = function(val) if THEME_PRESETS[val] then CurrentThemeName = val globalEnv.CurrentThemeName = val for k,v in pairs(THEME_PRESETS[val]) do THEME[k] = v end initTopics() end end },
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
