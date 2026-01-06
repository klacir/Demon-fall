-- ==============================================================================
--  SERVICES
-- ==============================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- =========================
-- SISTEMA DE IDIOMA
-- =========================
local globalEnv = (typeof(getgenv) == "function" and getgenv()) or _G
globalEnv.CurrentLang = globalEnv.CurrentLang or "PT"
local CurrentLang = globalEnv.CurrentLang -- Padrão: Português

local TRANSLATIONS = {
    PT = {
        TITLE_MAIN = "MOONDF HUB",
        TOPIC_TEST = "Teste",
        TOPIC_CONFIG = "Configuração",
        FOOTER_TEXT = "Right Ctrl ou use o botão para minimizar • Inputs: Immediate (OK) / Select (no OK)",
     
        -- Config
        LANG_LABEL = "Idioma / Language",
        LANG_DESC = "Altera todo o texto do menu",
        THEME_LABEL = "Tema / Theme",
        THEME_DESC = "Altera as cores da interface",
        OPACITY_LABEL = "Opacidade / Opacity",
        OPACITY_DESC = "Altera a transparência da janela",
        
        -- Test Itens (Mantidos no dicionário para não quebrar referências, mas não usados)
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

        -- Adições para MoonDFHub V2.5
        TOPIC_GENERAL = "Geral",
        TOPIC_MOBS = "Mobs",
        TOPIC_PLAYERS = "Players",
        TOPIC_TELEPORTS = "Teleportes",
        TOPIC_CONFIG = "Configuração",
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
        FOOTER_TEXT = "Right Ctrl or use button to minimize • Inputs: Immediate (OK) / Select (no OK)",
        
        LANG_LABEL = "Language / Idioma",
        LANG_DESC = "Changes all menu text",
        THEME_LABEL = "Theme / Tema",
        THEME_DESC = "Changes UI colors",
        OPACITY_LABEL = "Opacity / Opacidade",
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
        LIST_GROUP = "Group List",
        LIST_GROUP_DESC = "Contains other items",
        ITEM_INNER_1 = "Inner Item 1",
        ITEM_INNER_DESC_1 = "Toggle inside list",
        ITEM_INNER_2 = "Inner Item 2",
        ITEM_INNER_DESC_2 = "Slider inside list",
        NEST_TEST = "Nesting Test",
        NEST_TEST_DESC = "Deep levels",
        LEVEL_1 = "Level 1",
        LEVEL_1_DESC = "Inside first list",
        SUB_LIST = "Sub-List",
        SUB_LIST_DESC = "Level 2",
        BTN_LEVEL_3 = "Button Level 3",
        BTN_LEVEL_3_DESC = "Working",
        TOGGLE_LEVEL_3 = "Toggle Level 3",
        TOGGLE_LEVEL_3_DESC = "Working",

        -- Adições para MoonDFHub V2.5
        TOPIC_GENERAL = "General",
        TOPIC_MOBS = "Mobs",
        TOPIC_PLAYERS = "Players",
        TOPIC_TELEPORTS = "Teleports",
        TOPIC_CONFIG = "Settings",
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
        TP_HAYAKAWA = "Hayakawa",
        TP_HAYAKAWA_DESC = "TP",
        TP_OKUYA = "Okuya",
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
    return TRANSLATIONS[CurrentLang][key] or key
end

-- =========================
-- CONFIGURAÇÃO VISUAL & TEMAS
-- =========================
globalEnv.CurrentThemeName = globalEnv.CurrentThemeName or "Preto / Black"
local CurrentThemeName = globalEnv.CurrentThemeName
globalEnv.CurrentOpacity = globalEnv.CurrentOpacity or 0
local CurrentOpacity = globalEnv.CurrentOpacity
local DEFAULT_WIDTH = 760
local DEFAULT_HEIGHT = 520
local MIN_WIDTH = 420
local MIN_HEIGHT = 260
local RIGHT_AREA_SCALE = 0.33 

-- DEFINIÇÃO DOS TEMAS
local THEME_PRESETS = {
    ["Azul / Blue"] = {
        Background = Color3.fromRGB(15, 18, 25),
        PanelBg    = Color3.fromRGB(30, 35, 45),
        Text       = Color3.fromRGB(240, 245, 255),
        SubText    = Color3.fromRGB(150, 160, 180),
        Off        = Color3.fromRGB(50, 55, 65),
        On         = Color3.fromRGB(0, 160, 255),
        Border     = Color3.fromRGB(60, 100, 140),
        Hover      = Color3.fromRGB(45, 50, 60),
        Danger     = Color3.fromRGB(255, 60, 60),
        Accent     = Color3.fromRGB(0, 160, 255),
        KnobColor  = Color3.fromRGB(245, 245, 245) -- Bolinha Slider Padrão
    },
    ["Vermelho / Red"] = {
        Background = Color3.fromRGB(20, 10, 10),
        PanelBg    = Color3.fromRGB(40, 25, 25),
        Text       = Color3.fromRGB(255, 230, 230),
        SubText    = Color3.fromRGB(180, 140, 140),
        Off        = Color3.fromRGB(60, 40, 40),
        On         = Color3.fromRGB(220, 50, 50),
        Border     = Color3.fromRGB(120, 60, 60),
        Hover      = Color3.fromRGB(55, 30, 30),
        Danger     = Color3.fromRGB(255, 0, 0),
        Accent     = Color3.fromRGB(220, 50, 50),
        KnobColor  = Color3.fromRGB(245, 245, 245)
    },
    ["Amarelo / Yellow"] = {
        Background = Color3.fromRGB(25, 25, 20),
        PanelBg    = Color3.fromRGB(45, 45, 30),
        Text       = Color3.fromRGB(255, 255, 240),
        SubText    = Color3.fromRGB(180, 180, 150),
        Off        = Color3.fromRGB(75, 75, 50),
        On         = Color3.fromRGB(255, 200, 0),
        Border     = Color3.fromRGB(100, 100, 60),
        Hover      = Color3.fromRGB(55, 55, 40),
        Danger     = Color3.fromRGB(220, 60, 60),
        Accent     = Color3.fromRGB(255, 200, 0),
        KnobColor  = Color3.fromRGB(245, 245, 245)
    },
    ["Preto / Black"] = {
        Background = Color3.fromRGB(5, 5, 5),
        PanelBg    = Color3.fromRGB(25, 25, 25),
        Text       = Color3.fromRGB(220, 220, 220),
        SubText    = Color3.fromRGB(120, 120, 120),
        Off        = Color3.fromRGB(40, 40, 40),
        On         = Color3.fromRGB(100, 100, 100),
        Border     = Color3.fromRGB(70, 70, 70),
        Hover      = Color3.fromRGB(35, 35, 35),
        Danger     = Color3.fromRGB(150, 50, 50),
        Accent     = Color3.fromRGB(80, 80, 80), 
        KnobColor  = Color3.fromRGB(245, 245, 245)
    },
    ["Branco / White"] = {
        Background = Color3.fromRGB(255, 255, 255), -- Era PanelBg
        PanelBg    = Color3.fromRGB(235, 235, 240), -- Era Background
        Text       = Color3.fromRGB(30, 30, 35),
        SubText    = Color3.fromRGB(100, 100, 110),
        Off        = Color3.fromRGB(210, 210, 220),
        On         = Color3.fromRGB(40, 40, 40),
        Border     = Color3.fromRGB(180, 180, 190),
        Hover      = Color3.fromRGB(245, 245, 250),
        Danger     = Color3.fromRGB(255, 80, 80),
        Accent     = Color3.fromRGB(255, 255, 255), -- Barra escura para contraste
        KnobColor  = Color3.fromRGB(0, 0, 0)
    },
    ["Cinza / Gray"] = {
        Background = Color3.fromRGB(30, 30, 30),
        PanelBg    = Color3.fromRGB(48, 48, 48),
        Text       = Color3.fromRGB(200, 200, 200),
        SubText    = Color3.fromRGB(140, 140, 140),
        Off        = Color3.fromRGB(65, 65, 65),
        On         = Color3.fromRGB(130, 130, 130),
        Border     = Color3.fromRGB(90, 90, 90),
        Hover      = Color3.fromRGB(55, 55, 55),
        Danger     = Color3.fromRGB(100, 50, 50),
        Accent     = Color3.fromRGB(160, 160, 160),
        KnobColor  = Color3.fromRGB(245, 245, 245)
    }
}

-- Tema Inicial e Variáveis Globais
local THEME = {} 
-- Copia o tema inicial
for k,v in pairs(THEME_PRESETS[CurrentThemeName]) do THEME[k] = v end

-- CORES FIXAS POR TIPO
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

-- =========================
-- VARIÁVEIS DE ESTADO
-- =========================
globalEnv._HubStates = globalEnv._HubStates or {}
globalEnv._HubSelections = globalEnv._HubSelections or {}
globalEnv._ScriptHubStates = globalEnv._ScriptHubStates or {}

-- =========================
-- FUNÇÕES UTILITÁRIAS
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

-- =========================
-- CRIAÇÃO DA JANELA PRINCIPAL
-- =========================

for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "MoonDF_VirginHub" then
        pcall(function() v:Destroy() end)
    end
end

local screenGui = new("ScreenGui", {Name = "MoonDF_VirginHub", Parent = CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})

-- ==============================================================================
--  BOTÃO MINIMIZAR (MODIFICADO - TEXTO DF)
-- ==============================================================================
-- Agora é um TextButton, sem imagem
local miniButton = new("TextButton", { 
    Name = "MiniButton", 
    Parent = screenGui,
    Size = UDim2.new(0, 50, 0, 50),
    Position = UDim2.new(0.1, 0, 0.1, 0),
    BackgroundColor3 = THEME.Background,
    BackgroundTransparency = CurrentOpacity,
    Text = "DF", -- TEXTO DF
    TextColor3 = THEME.Accent,
    Font = Enum.Font.FredokaOne, -- FONTE GORDINHA
    TextSize = 24,
    Visible = false,
    AutoButtonColor = true
})
makeRound(miniButton, 12)
-- Sem borda ou com borda conforme tema (deixei borda no mini para visibilidade se fundo for igual)
local miniStroke = makeStroke(miniButton, THEME.Accent, 2) 

local root = new("Frame", {
    Name = "Root", Parent = screenGui,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, DEFAULT_WIDTH, 0, DEFAULT_HEIGHT),
    BackgroundColor3 = THEME.Background,
    BackgroundTransparency = CurrentOpacity,
    BorderSizePixel = 0,
    ClipsDescendants = true
})
makeRound(root, 10)
local rootStroke = makeStroke(root, THEME.Border, 2)

-- BARRA DE TÍTULO
local titleBar = new("Frame", {Parent = root, Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1})
local titleLabel = new("TextLabel", {
    Parent = titleBar, Position = UDim2.new(0, 12, 0, 8), Size = UDim2.new(1, -120, 1, -12),
    BackgroundTransparency = 1, Text = T("TITLE_MAIN"), TextColor3 = THEME.Text,
    Font = Enum.Font.GothamSemibold, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left
})

-- BOTÕES DE CONTROLE DA JANELA
local controlsContainer = new("Frame", {
    Parent = titleBar, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
    Size = UDim2.new(0, 70, 0, 30), BackgroundTransparency = 1
})

local minBtn = new("TextButton", {
    Parent = controlsContainer, Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(0, 30, 0, 30), BackgroundColor3 = Color3.fromRGB(50, 50, 55),
    Text = "-", TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold, TextSize = 18, BorderSizePixel = 0
})
makeRound(minBtn, 6)

local closeBtn = new("TextButton", {
    Parent = controlsContainer, Position = UDim2.new(0, 36, 0, 0),
    Size = UDim2.new(0, 30, 0, 30), BackgroundColor3 = THEME.Danger,
    Text = "X", 
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0
})
makeRound(closeBtn, 6)

-- PAINÉIS (LAYOUT)
local leftPane = new("Frame", {Parent = root, Position = UDim2.new(0, 10, 0, 56), Size = UDim2.new(0, 220, 1, -76), BackgroundTransparency = 1})
local rightPane = new("Frame", {Parent = root, Position = UDim2.new(0, 240, 0, 56), Size = UDim2.new(1, -250, 1, -76), BackgroundTransparency = 1})

-- MODIFICAÇÃO: Containers aplicam opacidade inicial
local leftBg = new("Frame", {Parent = leftPane, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = THEME.Background, BorderSizePixel = 0, BackgroundTransparency = CurrentOpacity})
makeRound(leftBg, 8);
local leftStroke = makeStroke(leftBg, THEME.Border, 1)

local topicsList = new("ScrollingFrame", {Parent = leftBg, Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(1, -16, 1, -16), BackgroundTransparency = 1, ScrollBarThickness = 6, CanvasSize = UDim2.new(0,0,0,0)})
local topicsLayout = new("UIListLayout", {Parent = topicsList, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder})

local rightBg = new("Frame", {Parent = rightPane, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = THEME.Background, BorderSizePixel = 0, BackgroundTransparency = CurrentOpacity})
makeRound(rightBg, 8);
local rightStroke = makeStroke(rightBg, THEME.Border, 1)

local scroll = new("ScrollingFrame", {Parent = rightBg, Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(1, -16, 1, -16), BackgroundTransparency = 1, ScrollBarThickness = 8, CanvasSize = UDim2.new(0,0,0,0)})
local buttonsLayout = new("UIListLayout", {Parent = scroll, Padding = UDim.new(0, 10)})
buttonsLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- RODAPÉ
local footer = new("TextLabel", {
    Parent = root, Position = UDim2.new(0, 12, 1, -28), Size = UDim2.new(1, -24, 0, 22),
    BackgroundTransparency = 1,
    Text = T("FOOTER_TEXT"),
    TextColor3 = THEME.SubText, Font = Enum.Font.Gotham, TextSize = 11
})

-- REDIMENSIONADOR
local resizer = new("Frame", {Parent = root, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -10, 1, -10), Size = UDim2.new(0, 18, 0, 18), BackgroundTransparency = 1})
local resDot = new("Frame", {Parent = resizer, Size = UDim2.new(1, 1, 1, 1), BackgroundColor3 = THEME.Hover, BorderSizePixel = 0});
makeRound(resDot, 6)

-- =========================
-- CONTROLE DE VISIBILIDADE & LÓGICA MINIMIZAR
-- =========================
local hubVisible = true
local connections = {}

local function toggleHub()
    hubVisible = not hubVisible
    root.Visible = hubVisible
    miniButton.Visible = not hubVisible
end

-- =========================
-- DRAG SYSTEM (JANELA PRINCIPAL E MINI BUTTON)
-- =========================
do
    -- Lógica de arrastar Janela Principal
    local dragging, dragOffset = false, Vector2.new(0, 0)
    table.insert(connections, titleBar.InputBegan:Connect(function(input)
        if not hubVisible then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local mp = input.Position or UserInputService:GetMouseLocation()
            dragOffset = Vector2.new(mp.X - root.AbsolutePosition.X, mp.Y - root.AbsolutePosition.Y)
        end
    end))
    table.insert(connections, UserInputService.InputChanged:Connect(function(input)
        if not dragging or not hubVisible then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local mp = input.Position or UserInputService:GetMouseLocation()
            local newX = mp.X - dragOffset.X + (root.AbsoluteSize.X * 0.5)
            local newY = mp.Y - dragOffset.Y + (root.AbsoluteSize.Y * 0.5)
            root.Position = UDim2.new(0, newX, 0, newY)
        end
    end))
    table.insert(connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end))

    -- Lógica de arrastar/clicar Botão Flutuante (MiniButton)
    local miniDragging, miniStartPos, miniDragStart = false, Vector2.new(0,0), Vector2.new(0,0)
    
    table.insert(connections, miniButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            miniDragging = true
            miniStartPos = Vector2.new(miniButton.AbsolutePosition.X, miniButton.AbsolutePosition.Y)
            local mp = input.Position
            miniDragStart = Vector2.new(mp.X, mp.Y)
        end
    end))
    
    table.insert(connections, UserInputService.InputChanged:Connect(function(input)
        if miniDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - Vector3.new(miniDragStart.X, miniDragStart.Y, 0)
            miniButton.Position = UDim2.new(0, miniStartPos.X + delta.X, 0, miniStartPos.Y + delta.Y)
        end
    end))
    
    table.insert(connections, miniButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            miniDragging = false
            local dist = (Vector2.new(input.Position.X, input.Position.Y) - miniDragStart).Magnitude
            if dist < 5 then
                toggleHub() 
            end
        end
    end))
end

-- Botão Minimizar
table.insert(connections, minBtn.MouseButton1Click:Connect(toggleHub))

-- Botão Fechar
table.insert(connections, closeBtn.MouseButton1Click:Connect(function()
    for _, conn in pairs(connections) do pcall(function() conn:Disconnect() end) end
    screenGui:Destroy()
end))

-- Keybind (Right Control)
table.insert(connections, UserInputService.InputBegan:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.RightControl then
        toggleHub()
    end
end))

-- Resize (Simplificado)
local resizing, startSize, startMouse = false, nil, nil
table.insert(connections, resizer.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = true; startSize = root.Size; local m = UserInputService:GetMouseLocation(); startMouse = Vector2.new(m.X, m.Y)
    end
end))
table.insert(connections, UserInputService.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local m = UserInputService:GetMouseLocation()
        local d = Vector2.new(m.X, m.Y) - startMouse
        root.Size = UDim2.new(0, math.max(MIN_WIDTH, startSize.X.Offset + d.X), 0, math.max(MIN_HEIGHT, startSize.Y.Offset + d.Y))
    end
end))
table.insert(connections, UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end end))


-- =========================
-- FACTORY DE ELEMENTOS UI
-- =========================

local function createHamburger(parent)
    local icon = new("Frame", {Parent = parent, Size = UDim2.new(0, 28, 0, 20), BackgroundTransparency = 1})
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

local function makeHoverAnimate(bg, rightScale)
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

-- FUNÇÃO RECURSIVA PRINCIPAL PARA CRIAR BOTÕES
local function createEntry(params, parentFrame, depth, onChildrenChanged)
    depth = depth or 0
    local baseH = 60
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
    local accent = new("Frame", {Parent = bg, Position = UDim2.new(0, 8 + depth * 12, 0.5, -18), Size = UDim2.new(0, 6, 0, 36), BackgroundColor3 = barColor})
    makeRound(accent, 6)

    local nameLabel = new("TextLabel", {
        Parent = bg, Position = UDim2.new(0, 28 + depth * 12, 0, 8), Size = UDim2.new(0.6, -28, 0, 20),
        BackgroundTransparency = 1, Text = params.Name or "Unnamed", TextColor3 = THEME.Text,
        Font = Enum.Font.GothamSemibold, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2
    })
    local descLabel = new("TextLabel", {
        Parent = bg, Position = UDim2.new(0, 28 + depth * 12, 0, 30), Size = UDim2.new(1, -164, 0, 18),
        BackgroundTransparency = 1, Text = params.Description or "", TextColor3 = THEME.SubText,
        Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2
    })

    local rightArea = new("Frame", {
        Parent = bg, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(RIGHT_AREA_SCALE, -12, 0, 44), BackgroundTransparency = 1, ZIndex = 5
    })

    local childrenContainer = new("Frame", {Parent = wrapper, Position = UDim2.new(0, 0, 0, baseH), Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, ClipsDescendants = true})
    local childrenHolder = new("Frame", {Parent = childrenContainer, Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(1, -16, 1, -16), BackgroundTransparency = 1})
    local childrenLayout = new("UIListLayout", {Parent = childrenHolder, Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Top})
    
    local hoverBox = makeHoverAnimate(bg, RIGHT_AREA_SCALE)

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

    -- LOGICA POR TIPO
    if params.Type == "Label" then
        -- Visual apenas

    elseif params.Type == "Toggle" then
        local state = false
        if params.StateKey then state = globalEnv._HubStates[params.StateKey] or false end
        local knob = new("Frame", {Parent = rightArea, Size = UDim2.new(0, 46, 0, 26), Position = UDim2.new(1, -46, 0.5, -13), BackgroundColor3 = THEME.Off});
        makeRound(knob, 14)
        local subKnob = new("Frame", {Parent = knob, Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 4, 0, 4), BackgroundColor3 = Color3.new(1, 1, 1)});
        makeRound(subKnob, 999)
        local function applyVisual(s)
            if s then
                tween(knob, {BackgroundColor3 = THEME.On}, 0.15)
                tween(subKnob, {Position = UDim2.new(1, -22, 0, 4)}, 0.15)
                
                if CurrentThemeName == "Preto / Black" then
                     tween(bg, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}, 0.15)
                end
            else
                tween(knob, {BackgroundColor3 = THEME.Off}, 0.15)
                tween(subKnob, {Position = UDim2.new(0, 4, 0, 4)}, 0.15)
                
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
        local txtBox = new("TextBox", {Parent = rightArea, Size = UDim2.new(1, -76, 0, 28), Position = UDim2.new(0, 0, 0.5, -14), BackgroundColor3 = THEME.Background, Text = "", PlaceholderText = params.Placeholder or "...", TextColor3 = THEME.Text, Font = Enum.Font.Gotham, TextSize = 14, ClearTextOnFocus = false, ZIndex = 6});
        makeRound(txtBox, 6)
        
        -- Botão OK Centralizado
        local okBtn = new("TextButton", {
            Parent = rightArea, 
            AnchorPoint = Vector2.new(1, 0.5), 
            Position = UDim2.new(1, 0, 0.5, 0), 
            Size = UDim2.new(0, 68, 0, 28), 
            BackgroundColor3 = THEME.Accent, -- [MODIFICADO] No tema preto, Accent agora é cinza
            Text = "OK", 
            TextColor3 = Color3.new(1, 1, 1), 
            Font = Enum.Font.GothamBold, 
            TextSize = 14, 
            ZIndex = 6
        })
        makeRound(okBtn, 6)
        
        table.insert(connections, okBtn.MouseButton1Click:Connect(function() if hubVisible and params.Callback then params.Callback(txtBox.Text) end end))
        table.insert(connections, txtBox.FocusLost:Connect(function(enter) if enter and hubVisible and params.Callback then params.Callback(txtBox.Text) end end))

    elseif params.Type == "InputSelect" then
        local txtBox = new("TextBox", {Parent = rightArea, Size = UDim2.new(1, 0, 0, 28), Position = UDim2.new(0, 0, 0.5, -14), BackgroundColor3 = THEME.Background, Text = params.Default or "", PlaceholderText = params.Placeholder or "...", TextColor3 = THEME.Text, Font = Enum.Font.Gotham, TextSize = 14, ClearTextOnFocus = true, ZIndex = 6});
        makeRound(txtBox, 6)
        table.insert(connections, txtBox.FocusLost:Connect(function() if params.StateKey then globalEnv._HubSelections[params.StateKey] = txtBox.Text end end))

    elseif params.Type == "ListAuto" or params.Type == "Container" then
        local ham = createHamburger(rightArea)
        ham.Frame.Position = UDim2.new(1, -28, 0, 8)
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
        ham.Frame.Position = UDim2.new(1, -28, 0, 8)
        local selectedValLabel = new("TextLabel", {Parent = bg, BackgroundTransparency = 1, TextColor3 = THEME.Text, Font = Enum.Font.GothamSemibold, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, Text = "", ZIndex = 2})
        
        local function updateSelectedLabelPos()
            local bounds = nameLabel.TextBounds
            selectedValLabel.Position = UDim2.new(0, 28 + depth * 12 + bounds.X + 4, 0, 8)
            selectedValLabel.Size = UDim2.new(0, 200, 0, 20)
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
        local track = new("Frame", {Parent = rightArea, Size = UDim2.new(1, -28, 0, 8), Position = UDim2.new(0, 8, 0.5, -4), BackgroundColor3 = THEME.Off, BorderSizePixel = 0})
        makeRound(track, 6)
        local fill = new("Frame", {Parent = track, Size = UDim2.new(0,0,1,0), Position = UDim2.new(0,0,0,0), BackgroundColor3 = THEME.Accent, BorderSizePixel = 0})
        makeRound(fill, 6)
        local knob = new("Frame", {Parent = rightArea, Size = UDim2.new(0,16,0,16), Position = UDim2.new(0,8,0.5,-8), BackgroundColor3 = (THEME.KnobColor or Color3.fromRGB(245,245,245)), BorderSizePixel = 0})
        makeRound(knob, 999)
        knob.Active = true; knob.ClipsDescendants = true
        local valLabel = new("TextLabel", {Parent = rightArea, AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1,-10,0,6), Size = UDim2.new(0,46,0,18), BackgroundTransparency = 1, Text = tostring(cur), TextColor3 = THEME.SubText, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right})
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
                knob.Position = UDim2.new(0, knobX, 0.5, -8)
            else
                tween(fill, {Size = UDim2.new(0, fillW, 1, 0)}, 0.12)
                tween(knob, {Position = UDim2.new(0, knobX, 0.5, -8)}, 0.12)
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
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragConnChanged = UserInputService.InputChanged:Connect(function(inp)
                    if not dragging then return end
                    if inp.UserInputType == Enum.UserInputType.MouseMovement then
                        local v = xToValue(inp.Position.X)
                        if v ~= cur then
                            cur = v
                            updateVisuals(false)
                            fireChange()
                        end
                    end
                end)
                dragConnEnded = UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                        if dragConnChanged then dragConnChanged:Disconnect(); dragConnChanged = nil end
                        if dragConnEnded then dragConnEnded:Disconnect(); dragConnEnded = nil end
                    end
                end)
                table.insert(connections, dragConnChanged); table.insert(connections, dragConnEnded)
            end
        end))
        table.insert(connections, track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local pos = (input.Position and input.Position.X) or UserInputService:GetMouseLocation().X
                local v = xToValue(pos)
                if v ~= cur then
                    cur = v
                    updateVisuals(false)
                    fireChange()
                end
            end
        end))
        table.insert(connections, fill.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local pos = (input.Position and input.Position.X) or UserInputService:GetMouseLocation().X
                local v = xToValue(pos)
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

-- =========================
-- GERENCIADOR DE TÓPICOS
-- =========================
local togglesCreated = {}
local initTopics -- Declaração antecipada

local function addTopic(name, items)
    local btn = new("TextButton", {
        Parent = topicsList, 
        Size = UDim2.new(1, 0, 0, 42), 
        BackgroundColor3 = THEME.PanelBg, 
        BorderSizePixel = 0, 
        Text = name, 
        TextColor3 = THEME.Text, 
        Font = Enum.Font.Gotham, 
        TextSize = 14,
        BackgroundTransparency = CurrentOpacity
    })
    makeRound(btn, 8)
    
    table.insert(connections, btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = THEME.Hover}, 0.12) end))
    table.insert(connections, btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = THEME.PanelBg}, 0.12) end))
    
    table.insert(connections, btn.MouseButton1Click:Connect(function()
        if not hubVisible then return end
        for _, c in pairs(scroll:GetChildren()) do if c:IsA("Frame") and c.Name == "Entry" then c:Destroy() end end
        
        togglesCreated[name] = togglesCreated[name] or {}
        for _, it in ipairs(items) do
            createEntry(it, scroll, 0)
        end
        refreshMainScroll()
    end))
end

-- =========================
-- LAYOUT RESPONSIVO
-- =========================
local function updateLayout()
    local totalW = root.AbsoluteSize.X
    local leftWidth = math.clamp(math.floor(totalW * 0.26), 140, 320)
    leftWidth = math.min(leftWidth, math.max(120, totalW - 220))
    
    leftPane.Size = UDim2.new(0, leftWidth, 1, -80)
    local rightX = leftWidth + 20
    rightPane.Position = UDim2.new(0, rightX, 0, 56)
    rightPane.Size = UDim2.new(0, totalW - rightX - 10, 1, -80)
    
    refreshMainScroll()
end
table.insert(connections, root:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateLayout))
table.insert(connections, topicsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    topicsList.CanvasSize = UDim2.new(0, 0, 0, topicsLayout.AbsoluteContentSize.Y + 12)
end))
table.insert(connections, buttonsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshMainScroll))

task.defer(updateLayout)

-- =========================
-- ATUALIZAÇÃO VISUAL DE TEMA ESTÁTICO
-- =========================
local function refreshStaticUI()
    -- Atualiza Frames Base
    root.BackgroundColor3 = THEME.Background
    leftBg.BackgroundColor3 = THEME.Background 
    rightBg.BackgroundColor3 = THEME.Background
    miniButton.BackgroundColor3 = THEME.Background
    miniButton.BackgroundTransparency = CurrentOpacity
    
    -- MODIFICAÇÃO: Atualiza cores do Botão DF
    miniButton.TextColor3 = THEME.Accent
    miniStroke.Color = THEME.Accent
    
    -- Atualiza Textos
    titleLabel.TextColor3 = THEME.Text
    footer.TextColor3 = THEME.SubText
    
    -- Atualiza Bordas (Strokes)
    rootStroke.Color = THEME.Border
    leftStroke.Color = THEME.Border
    rightStroke.Color = THEME.Border
end

-- =========================
-- INICIALIZAÇÃO
-- =========================

function initTopics()
    -- Limpa lista lateral
    for _, v in pairs(topicsList:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    -- Limpa conteúdo principal
    for _, c in pairs(scroll:GetChildren()) do 
        if c:IsA("Frame") and c.Name == "Entry" then c:Destroy() end 
    end
    
    -- Atualiza textos globais e cores
    refreshStaticUI()
    titleLabel.Text = T("TITLE_MAIN")
    footer.Text = T("FOOTER_TEXT")

    -- AQUI FICAVA A ABA TESTE (REMOVIDA)

    -- =========================
    -- TÓPICO: CONFIGURAÇÃO
    -- =========================
    addTopic(T("TOPIC_CONFIG"), {
        -- Seletor de Idioma
        {
            Type = "ListPersistent",
            Name = T("LANG_LABEL"),
            Description = T("LANG_DESC"),
            StateKey = "LanguageSelection",
            Options = {"Português", "English"},
            Callback = function(val)
                local oldLang = CurrentLang
                CurrentLang = (val == "English") and "EN" or "PT"
                globalEnv.CurrentLang = CurrentLang
                if oldLang ~= CurrentLang then
                    initTopics()
                end
            end
        },
        -- Seletor de Temas
        {
            Type = "ListPersistent",
            Name = T("THEME_LABEL") .. " [" .. CurrentThemeName .. "]",
            Description = T("THEME_DESC"),
            StateKey = "ThemeSelection",
            Options = {"Azul / Blue", "Vermelho / Red", "Amarelo / Yellow", "Preto / Black", "Branco / White", "Cinza / Gray"},
            Callback = function(val)
                if THEME_PRESETS[val] then
                    CurrentThemeName = val
                    globalEnv.CurrentThemeName = val
                    for k,v in pairs(THEME_PRESETS[val]) do
                        THEME[k] = v
                    end
                    initTopics()
                end
            end
        },
        -- Slider de Opacidade
        {
            Type = "Slider",
            StateKey = "OpacityValue",
            Name = T("OPACITY_LABEL"),
            Description = T("OPACITY_DESC"),
            Min = 0, Max = 100, Default = (1 - CurrentOpacity) * 100, 
            OnChange = function(val)
                local transp = 1 - (val / 100)
                CurrentOpacity = transp
                globalEnv.CurrentOpacity = transp
                
                -- Aplica no background principal
                root.BackgroundTransparency = transp
                leftBg.BackgroundTransparency = transp
                rightBg.BackgroundTransparency = transp
                miniButton.BackgroundTransparency = transp
                
                for _, desc in pairs(screenGui:GetDescendants()) do
                    if desc:IsA("Frame") and desc.Name == "ElementBackground" or desc:IsA("TextButton") and desc.Parent == topicsList then
                        desc.BackgroundTransparency = transp
                    end
                end
            end
        }
    })
end

-- Inicialização
initTopics()








-- ==============================================================================
--  SERVICES & VARIÁVEIS DO MOONDF HUB V1
-- ==============================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VIM = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

-- Variáveis de Voo e Speed
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

-- Variáveis Visuais
local coordsEnabled = false
local coordsGui, coordsLabel, coordsConn
globalEnv.noFogEnabled = globalEnv.noFogEnabled or false
local noFogEnabled = globalEnv.noFogEnabled
globalEnv.ultraLiteEnabled = globalEnv.ultraLiteEnabled or false
local ultraLiteEnabled = globalEnv.ultraLiteEnabled
local liteLoop = nil

-- Variáveis de Farm e Combate
globalEnv.trinketFarm = globalEnv.trinketFarm or false
local trinketFarm = globalEnv.trinketFarm
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

-- Variáveis Diversas
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
globalEnv.spectateDistance = globalEnv.spectateDistance or 5
local spectateDistance = globalEnv.spectateDistance
globalEnv.espEnabled = globalEnv.espEnabled or false
local espEnabled = globalEnv.espEnabled
local espConnections = {}
local espUpdateLoop = nil
local espPlayers = {}

-- Tabelas e Coordenadas
local blockedStates = {
    Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.Freefall, Enum.HumanoidStateType.GettingUp,
    Enum.HumanoidStateType.Seated, Enum.HumanoidStateType.PlatformStanding, Enum.HumanoidStateType.Dead, Enum.HumanoidStateType.Physics,
}

local MOBS = { "GenericSlayer", "GenericOni", "FrostyOni", "Green Demon", "Blue Demon", "Zenitsu", "Gyutaro", "Kaigaku" }

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

-- ==========================================
-- FUNÇÕES LÓGICAS (PORTADAS)
-- ==========================================

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

local function setupFly()
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
    flyConn = RunService.Heartbeat:Connect(function()
        if not flyToggle or not root then return end
        local cam = workspace.CurrentCamera
        local vertical = 0
        local currentSpeed = calculateFlySpeed(flySpeedValue)
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vertical += currentSpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.C) then vertical -= currentSpeed end
        bv.Velocity = humanoid.MoveDirection * currentSpeed + Vector3.new(0, vertical, 0)
        bg.CFrame = cam.CFrame
    end)
end

local function toggleNoclip(state)
    noclipToggle = state
    globalEnv.noclipToggle = state
    if state then
        if noclipConn then noclipConn:Disconnect() end
        noclipConn = RunService.Stepped:Connect(function()
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() end
    end
end

local function toggleClickTP(state)
    clickTPToggle = state
    globalEnv.clickTPToggle = state
    if state then
        if clickTPConn then clickTPConn:Disconnect() end
        local mouse = player:GetMouse()
        clickTPConn = mouse.Button1Down:Connect(function()
            if clickTPToggle and mouse.Target and root then
                root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end)
    else
        if clickTPConn then clickTPConn:Disconnect() end
    end
end

local function applyNoFog(state)
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

local function toggleUltraLite(state)
    ultraLiteEnabled = state
    globalEnv.ultraLiteEnabled = state
    if state then
        settings().Rendering.QualityLevel = 1
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

-- Lógica de Farm
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

local function toggleTeleport(enable, mobName)
    if enable then
        if connection then connection:Disconnect() end
        teleportAndLookLooping = true
        connection = RunService.RenderStepped:Connect(teleportAndLook)
        spawn(teleportAndLookWithKeys)
        currentMob = mobName
        isEnabled = true
    else
        if connection then connection:Disconnect() connection = nil end
        teleportAndLookLooping = false
        isEnabled = false
        currentMob = nil
    end
end

local function autoAttackLoop()
    while autoAttack do
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        task.wait(0.15)
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

-- ESP e Spectate
local function createESPLabel(hrp, playerName, distance)
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Size = UDim2.new(0, 120, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 5, 0) 
    billboardGui.MaxDistance = 3000 
    billboardGui.Adornee = hrp
    billboardGui.Parent = hrp
    billboardGui.AlwaysOnTop = true
    local textLabel = Instance.new("TextLabel", billboardGui)
    textLabel.BackgroundTransparency = 0.5 
    textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    textLabel.TextScaled = true
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    return billboardGui, textLabel
end

local function enableESP()
    for _, v in pairs(espPlayers) do if v.box then v.box:Destroy() end if v.billGui then v.billGui:Destroy() end end
    espPlayers = {}
    if espUpdateLoop then espUpdateLoop:Disconnect() end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            local box = Instance.new("BoxHandleAdornment", hrp)
            box.Size = Vector3.new(3, 6, 2)
            box.Adornee = hrp
            box.Color3 = Color3.new(1, 0, 0)
            box.Transparency = 0.6
            box.AlwaysOnTop = true
            box.ZIndex = 10
            local billGui, textLabel = createESPLabel(hrp, plr.Name, 0)
            espPlayers[plr.Name] = { player = plr, box = box, billGui = billGui, textLabel = textLabel }
        end
    end
    espUpdateLoop = RunService.Heartbeat:Connect(function()
        if not espEnabled then return end
        for playerName, espData in pairs(espPlayers) do
            if espData.player and espData.player.Character and espData.player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = espData.player.Character.HumanoidRootPart
                local hum = espData.player.Character:FindFirstChild("Humanoid")
                local dist = (root.Position - hrp.Position).Magnitude
                if espData.textLabel and hum then
                    espData.textLabel.Text = string.format("%s\nHP: %d\n%.1fm", playerName, math.floor(hum.Health), dist)
                end
            else
                if espData.box then espData.box:Destroy() end
                if espData.billGui then espData.billGui:Destroy() end
                espPlayers[playerName] = nil
            end
        end
    end)
end

local function toggleESP(state)
    espEnabled = state
    globalEnv.espEnabled = state
    if state then
        enableESP()
    else
        if espUpdateLoop then espUpdateLoop:Disconnect() end
        for _, v in pairs(espPlayers) do if v.box then v.box:Destroy() end if v.billGui then v.billGui:Destroy() end end
        espPlayers = {}
    end
end

local function toggleSpectate(state, targetPlayerName)
    spectateToggle = state
    globalEnv.spectateToggle = state
    if state then
        local targetPlayer = Players:FindFirstChild(targetPlayerName)
        if not targetPlayer or not targetPlayer.Character then return end
        spectatePlayer = targetPlayer
        originalCFrame = root.CFrame
        if spectateConn then spectateConn:Disconnect() end
        spectateConn = RunService.RenderStepped:Connect(function()
            if spectateToggle and spectatePlayer and spectatePlayer.Character and spectatePlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetRoot = spectatePlayer.Character.HumanoidRootPart
                local cam = workspace.CurrentCamera
                cam.CFrame = CFrame.new(targetRoot.Position + Vector3.new(spectateDistance, spectateHeight, spectateDistance), targetRoot.Position + Vector3.new(0, 2, 0))
            end
        end)
    else
        if spectateConn then spectateConn:Disconnect() end
        if root and originalCFrame then workspace.CurrentCamera.CFrame = CFrame.new(root.Position + Vector3.new(0, 3, 5), root.Position) end
    end
end

player.CharacterAdded:Connect(function(newChar)
    char = newChar
    root = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
    if flyToggle then setupFly() end
    if speedToggle then
        if speedConn then speedConn:Disconnect() end
        speedConn = RunService.Heartbeat:Connect(function() if humanoid then humanoid.WalkSpeed = walkSpeed end end)
    end
end)

local function getPlayerNames()
    local list = {}
    for _, v in pairs(Players:GetPlayers()) do if v ~= player then table.insert(list, v.Name) end end
    return list
end

-- ==============================================================================
--  DEFINIÇÃO DA UI (INIT TOPICS)
-- ==============================================================================

function initTopics()
    for _, v in pairs(topicsList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, c in pairs(scroll:GetChildren()) do if c:IsA("Frame") and c.Name == "Entry" then c:Destroy() end end
    refreshStaticUI()
    titleLabel.Text = "MOONDF HUB V2.5"
    footer.Text = "Versão Portada para Nova Base • V2.5"

    -- GERAL
    addTopic(T("TOPIC_GENERAL"), {
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
            { Type = "Toggle", StateKey = "UltraLite", Name = T("ULTRA_LITE"), Description = T("ULTRA_LITE_DESC"), OnEnable = function() toggleUltraLite(true) end, OnDisable = function() toggleUltraLite(false) end }
        }}
    })

    -- FARM & MOBS (REORGANIZADO)
    local mobFarmOptions = {}
    for _, mob in ipairs(MOBS) do
        table.insert(mobFarmOptions, { Type = "Toggle", StateKey = "Farm" .. mob, Name = T("FARM") .. " " .. mob, Description = T("FARM_DESC"), OnEnable = function() toggleTeleport(true, mob) end, OnDisable = function() toggleTeleport(false) end })
    end

    addTopic(T("TOPIC_MOBS"), {
        { Type = "Label", Name = T("INFO_LABEL") },
        { Type = "ListAuto", Name = T("EXTRAS_MOBS"), Description = T("EXTRAS_MOBS_DESC"), Options = {
            { Type = "Toggle", StateKey = "TrinketFarm", Name = T("TRINKET_FARM"), Description = T("TRINKET_FARM_DESC"), OnEnable = function()
                trinketFarm = true
                globalEnv.trinketFarm = true
                spawn(function()
                    while trinketFarm do
                        task.wait(0.1)
                        if workspace:FindFirstChild("Trinkets") then
                            for _, t in pairs(workspace.Trinkets:GetChildren()) do
                                if not trinketFarm then break end
                                if t:IsA("Part") and t:FindFirstChild("Spawned") and root then
                                    root.CFrame = t.CFrame * CFrame.new(0,3,0)
                                    task.wait(0.15)
                                    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                    task.wait(0.05)
                                    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                end
                            end
                        end
                    end
                end)
            end, OnDisable = function() trinketFarm = false globalEnv.trinketFarm = false end },
            { Type = "Toggle", StateKey = "AutoAttack", Name = T("AUTO_ATTACK"), Description = T("AUTO_ATTACK_DESC"), OnEnable = function() autoAttack = true globalEnv.autoAttack = true spawn(autoAttackLoop) end, OnDisable = function() autoAttack = false globalEnv.autoAttack = false end }
        }},
        { Type = "ListAuto", Name = T("TP_MODE"), Description = T("TP_MODE_DESC"), Options = {
            { Type = "ListPersistent", StateKey = "TeleportMode", Name = T("TP_MODE"), Description = T("TP_MODE_DESC"), Options = {"Behind", "Above", "Below"}, Callback = function(v) teleportMode = v globalEnv.teleportMode = v end },
            { Type = "Slider", StateKey = "FarmDistance", Name = T("DISTANCE"), Description = T("DISTANCE_DESC"), Min = 0, Max = 50, Default = 4, OnChange = function(v) FARM_DISTANCE = v globalEnv.FARM_DISTANCE = v end },
            { Type = "Slider", StateKey = "ExecuteDistance", Name = T("EXECUTE_DISTANCE"), Description = T("EXECUTE_DISTANCE_DESC"), Min = 0, Max = 100, Default = 20, OnChange = function(v) EXECUTE_DISTANCE = v globalEnv.EXECUTE_DISTANCE = v end }
        }},
        { Type = "ListAuto", Name = T("FARM_MOBS_LIST"), Description = T("FARM_MOBS_LIST_DESC"), Options = mobFarmOptions },
        { Type = "ListAuto", Name = T("RAIDS"), Description = T("RAIDS_DESC"), Options = {
            { Type = "Single", Name = T("TP_RAID_AREA"), Description = T("TP_RAID_AREA_DESC"), Callback = function() if root then root.CFrame = LOCATIONS.Raid end end },
            { Type = "Toggle", StateKey = "FarmShinobuRaid", Name = T("FARM") .. " Shinobu Raid", Description = T("FARM_DESC"), OnEnable = function() toggleTeleport(true, "ShinoubuRaid") end, OnDisable = function() toggleTeleport(false) end },
            { Type = "Toggle", StateKey = "FarmRengokuRaid", Name = T("FARM") .. " Rengoku Raid", Description = T("FARM_DESC"), OnEnable = function() toggleTeleport(true, "RengokuRaid") end, OnDisable = function() toggleTeleport(false) end },
            { Type = "Toggle", StateKey = "FarmKokushiboRaid", Name = T("FARM") .. " Kokushibo Raid", Description = T("FARM_DESC"), OnEnable = function() toggleTeleport(true, "KokushiboRaid") end, OnDisable = function() toggleTeleport(false) end },
            { Type = "Toggle", StateKey = "FarmYoriichi", Name = T("FARM") .. " Yoriichi", Description = T("FARM_DESC"), OnEnable = function() toggleTeleport(true, "Yoriichi") end, OnDisable = function() toggleTeleport(false) end }
        }},
        { Type = "ListAuto", Name = T("INFINITE_CASTLE"), Description = T("INFINITE_CASTLE_DESC"), Options = {
            { Type = "Single", Name = T("TP_SLAYER_CORPS"), Description = T("TP_SLAYER_CORPS_DESC"), Callback = function() if root then root.CFrame = LOCATIONS.Castelo1 end end },
            { Type = "Single", Name = T("TP_AKAZA_DOMA"), Description = T("TP_AKAZA_DOMA_DESC"), Callback = function() if root then root.CFrame = LOCATIONS.Castelo2 end end },
            { Type = "Single", Name = T("TP_KOKUSHIBO"), Description = T("TP_KOKUSHIBO_DESC"), Callback = function() if root then root.CFrame = LOCATIONS.Castelo3 end end },
            { Type = "Toggle", StateKey = "FarmAkaza", Name = T("FARM") .. " Akaza", Description = T("FARM_DESC"), OnEnable = function() toggleTeleport(true, "Akaza") end, OnDisable = function() toggleTeleport(false) end },
            { Type = "Toggle", StateKey = "FarmDoma", Name = T("FARM") .. " Doma", Description = T("FARM_DESC"), OnEnable = function() toggleTeleport(true, "Doma") end, OnDisable = function() toggleTeleport(false) end },
            { Type = "Toggle", StateKey = "FarmKokushibo", Name = T("FARM") .. " Kokushibo", Description = T("FARM_DESC"), OnEnable = function() toggleTeleport(true, "Kokushibo") end, OnDisable = function() toggleTeleport(false) end }
        }}
    })

    -- PLAYERS (REORGANIZADO)
    addTopic(T("TOPIC_PLAYERS"), {
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
            { Type = "Toggle", StateKey = "FarmPlayer", Name = T("FARM_PLAYER"), Description = T("FARM_PLAYER_DESC"), OnEnable = function() if selectedPlayerName then toggleTeleport(true, selectedPlayerName) end end, OnDisable = function() toggleTeleport(false) end }
        }},
        { Type = "ListAuto", Name = T("SPECTATE"), Description = T("SPECTATE_DESC"), Options = {
            { Type = "Slider", StateKey = "SpectateHeight", Name = T("HEIGHT"), Description = T("HEIGHT_DESC"), Min = 5, Max = 100, Default = 20, OnChange = function(v) spectateHeight = v globalEnv.spectateHeight = v end },
            { Type = "Slider", StateKey = "SpectateDistance", Name = T("DISTANCE_SPECTATE"), Description = T("DISTANCE_SPECTATE_DESC"), Min = 5, Max = 100, Default = 5, OnChange = function(v) spectateDistance = v globalEnv.spectateDistance = v end },
            { Type = "Toggle", StateKey = "EnableSpectate", Name = T("ENABLE_SPECTATE"), Description = T("ENABLE_SPECTATE_DESC"), OnEnable = function() if selectedPlayerName then toggleSpectate(true, selectedPlayerName) end end, OnDisable = function() toggleSpectate(false) end }
        }}
    })

    -- TELEPORTES
    addTopic(T("TOPIC_TELEPORTS"), {
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

    -- CONFIGURAÇÃO
    addTopic(T("TOPIC_CONFIG"), {
        { Type = "ListPersistent", Name = T("LANGUAGE"), Description = T("LANGUAGE_DESC"), Options = {"Português", "English"}, Callback = function(val) CurrentLang = (val == "English") and "EN" or "PT" globalEnv.CurrentLang = CurrentLang initTopics() end },
        { Type = "ListPersistent", Name = T("THEME"), Description = T("THEME_DESC"), Options = {"Azul / Blue", "Vermelho / Red", "Amarelo / Yellow", "Preto / Black", "Branco / White", "Cinza / Gray"}, Callback = function(val) if THEME_PRESETS[val] then CurrentThemeName = val globalEnv.CurrentThemeName = val for k,v in pairs(THEME_PRESETS[val]) do THEME[k] = v end initTopics() end end },
        { Type = "Slider", Name = T("OPACITY"), Description = T("OPACITY_DESC"), Min = 0, Max = 100, Default = (1 - CurrentOpacity) * 100, OnChange = function(val)
            local transp = 1 - (val / 100)
            CurrentOpacity = transp
            globalEnv.CurrentOpacity = transp
            root.BackgroundTransparency = transp
            leftBg.BackgroundTransparency = transp
            rightBg.BackgroundTransparency = transp
            miniButton.BackgroundTransparency = transp
            for _, desc in pairs(scroll:GetDescendants()) do if desc.Name == "ElementBackground" then desc.BackgroundTransparency = transp end end
            for _, desc in pairs(topicsList:GetDescendants()) do if desc:IsA("TextButton") then desc.BackgroundTransparency = transp end end
        end }
    })
end

initTopics()