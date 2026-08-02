-- ================================================
-- DEMON FALL - HUD CS2 + SPECTATOR 3D + X-RAY GLOW + PRIVACIDADE ESC
-- FIXES: indicadores M1/M2/Forma com detecção real Demon Fall
--   M1=AttackAnnounce/Attacking | M2=HeavyAnnounce/HeavyCooldown
--   Forma=Activate*/ItemCooldown (Busy NÃO classifica sozinho)
-- ================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera
local ABSOLUTE_MAX_HP = 280
local RECOVERY_THRESHOLD_PCT = 0.15

-- Prevenir duplicação de instâncias/conexões
if CoreGui:FindFirstChild("CS2TournamentSystem") then
    CoreGui.CS2TournamentSystem:Destroy()
end
if _G.CS2OverlayConnection then _G.CS2OverlayConnection:Disconnect() _G.CS2OverlayConnection = nil end
if _G.CS2SpectatorConnection then _G.CS2SpectatorConnection:Disconnect() _G.CS2SpectatorConnection = nil end
if _G.CS2EscMenuConnection then _G.CS2EscMenuConnection:Disconnect() _G.CS2EscMenuConnection = nil end
if _G.CS2PrivacyBlackout then pcall(function() _G.CS2PrivacyBlackout:Destroy() end) _G.CS2PrivacyBlackout = nil end

-- ================================================
-- VARIÁVEIS COMPARTILHADAS E CONFIGURAÇÕES
-- ================================================
local selectedTeam1 = {} -- Time A (Azul)
local selectedTeam2 = {} -- Time B (Vermelho)
local maxHpCache = {}
local lastHpCache = {}
local knockedState = {}
local avatarCache = {}
local playerSpawnTime = {}
local xrayHighlights = {}
local xrayEnabled = false
local privacyModeEnabled = true -- Ativado por padrão
local cloneCache = {} 
local lastCloneTime = {}
local formActiveUntil = {} -- Forma: buffer anti-flicker
local m2HoldUntil = {} -- M2: buffer endlag para não apagar cedo
local styleCache = {} -- cache do estilo de respiração

local function setupPlayer(player)
    player.CharacterAdded:Connect(function(char)
        maxHpCache[player.UserId] = nil
        playerSpawnTime[player.UserId] = os.clock()
        if cloneCache[player.UserId] then
            pcall(function() cloneCache[player.UserId]:Destroy() end)
            cloneCache[player.UserId] = nil
        end
        lastCloneTime[player.UserId] = nil
        formActiveUntil[player.UserId] = nil
        m2HoldUntil[player.UserId] = nil
    end)
end
for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
    if player.Character then playerSpawnTime[player.UserId] = os.clock() end
end
Players.PlayerAdded:Connect(setupPlayer)

-- ================================================
-- LÓGICA DE FORMATAÇÃO E CENSURA DE NOME
-- ================================================
local function maskText(str)
    if type(str) ~= "string" or str == "" then return "**" end
    local len = #str
    if len <= 1 then return str end
    if len == 2 then return string.sub(str, 1, 1) .. "*" end

    local ratio = 0.35 + math.random() * 0.15
    local numMask = math.clamp(math.floor(len * ratio + 0.5), 1, len - 1)

    local pool = {}
    for i = 2, len do table.insert(pool, i) end
    for i = #pool, 2, -1 do
        local j = math.random(1, i)
        pool[i], pool[j] = pool[j], pool[i]
    end

    local maskSet = {}
    for i = 1, math.min(numMask, #pool) do maskSet[pool[i]] = true end

    local out = {}
    for i = 1, len do
        if maskSet[i] then table.insert(out, "*") else table.insert(out, string.sub(str, i, i)) end
    end
    return table.concat(out, "")
end
local maskedNameCache = {}
local function getFormattedName(player)
    local displayName = player.DisplayName
    local username = player.Name
    if string.lower(displayName) == string.lower(username) then
        local key = player.UserId .. "|" .. displayName
        if not maskedNameCache[key] then
            math.randomseed(player.UserId % 2147483647 + os.clock() * 1000)
            maskedNameCache[key] = maskText(displayName)
            math.randomseed(tick() * 1000)
        end
        return maskedNameCache[key]
    end
    return displayName
end

local function createDrawnX(button)
    button.Text = ""
    button.AutoButtonColor = true
    local line1 = Instance.new("Frame")
    line1.Size = UDim2.new(0, 12, 0, 2)
    line1.Position = UDim2.new(0.5, 0, 0.5, 0)
    line1.AnchorPoint = Vector2.new(0.5, 0.5)
    line1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    line1.BorderSizePixel = 0
    line1.Rotation = 45
    line1.ZIndex = 5
    line1.Parent = button
    Instance.new("UICorner", line1).CornerRadius = UDim.new(1, 0)
    local line2 = Instance.new("Frame")
    line2.Size = UDim2.new(0, 12, 0, 2)
    line2.Position = UDim2.new(0.5, 0, 0.5, 0)
    line2.AnchorPoint = Vector2.new(0.5, 0.5)
    line2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    line2.BorderSizePixel = 0
    line2.Rotation = -45
    line2.ZIndex = 5
    line2.Parent = button
    Instance.new("UICorner", line2).CornerRadius = UDim.new(1, 0)
end

-- ================================================
-- SCREEN GUI PRINCIPAL & BLACKOUT
-- ================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CS2TournamentSystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = (gethui and gethui()) or CoreGui

local PrivacyBlackout = Instance.new("Frame")
PrivacyBlackout.Name = "PrivacyBlackout"
PrivacyBlackout.Size = UDim2.new(1, 0, 2/3, 0)
PrivacyBlackout.Position = UDim2.new(0, 0, 1/3, 0)
PrivacyBlackout.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
PrivacyBlackout.BorderSizePixel = 0
PrivacyBlackout.Visible = false
PrivacyBlackout.ZIndex = 9999
PrivacyBlackout.Active = true
PrivacyBlackout.Parent = ScreenGui
_G.CS2PrivacyBlackout = PrivacyBlackout

local PrivacyLabel = Instance.new("TextLabel")
PrivacyLabel.Size = UDim2.new(1, -40, 0, 40)
PrivacyLabel.Position = UDim2.new(0, 20, 0, 12)
PrivacyLabel.BackgroundTransparency = 1
PrivacyLabel.Text = "⚠️ PRIVACIDADE ATIVA — 2/3 inferiores ocultos"
PrivacyLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
PrivacyLabel.Font = Enum.Font.GothamBold
PrivacyLabel.TextSize = 14
PrivacyLabel.Parent = PrivacyBlackout

local topInset = 36
pcall(function()
    local inset = GuiService:GetGuiInset()
    if inset and inset.Y then topInset = math.max(36, inset.Y + 4) end
end)

local OpenMenuBtn = Instance.new("TextButton")
OpenMenuBtn.Size = UDim2.new(0, 110, 0, 30)
OpenMenuBtn.Position = UDim2.new(0, 15, 0, topInset)
OpenMenuBtn.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
OpenMenuBtn.Text = "⚙ PLAYERS HUD"
OpenMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenMenuBtn.Font = Enum.Font.GothamBold
OpenMenuBtn.TextSize = 11
OpenMenuBtn.Parent = ScreenGui
Instance.new("UICorner", OpenMenuBtn).CornerRadius = UDim.new(0, 6)

local OpenSpecBtn = Instance.new("TextButton")
OpenSpecBtn.Size = UDim2.new(0, 110, 0, 30)
OpenSpecBtn.Position = UDim2.new(0, 135, 0, topInset)
OpenSpecBtn.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
OpenSpecBtn.Text = "🎥 ESPECTAR"
OpenSpecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenSpecBtn.Font = Enum.Font.GothamBold
OpenSpecBtn.TextSize = 11
OpenSpecBtn.Parent = ScreenGui
Instance.new("UICorner", OpenSpecBtn).CornerRadius = UDim.new(0, 6)

local isGameHudVisible = true
local ToggleHudBtn = Instance.new("TextButton")
ToggleHudBtn.Size = UDim2.new(0, 160, 0, 30)
ToggleHudBtn.Position = UDim2.new(0, 255, 0, topInset)
ToggleHudBtn.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
ToggleHudBtn.Text = "👁️ OCULTAR HUD DO JOGO"
ToggleHudBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleHudBtn.Font = Enum.Font.GothamBold
ToggleHudBtn.TextSize = 11
ToggleHudBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleHudBtn).CornerRadius = UDim.new(0, 6)
ToggleHudBtn.MouseButton1Click:Connect(function()
    isGameHudVisible = not isGameHudVisible
    ToggleHudBtn.Text = isGameHudVisible and "👁️ OCULTAR HUD DO JOGO" or "👁️ MOSTRAR HUD DO JOGO"
    ToggleHudBtn.BackgroundColor3 = isGameHudVisible and Color3.fromRGB(20, 22, 28) or Color3.fromRGB(180, 40, 50)
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "CS2TournamentSystem" then
                gui.Enabled = isGameHudVisible
            end
        end
    end
end)

-- ================================================
-- PAINEL DE CONTROLE
-- ================================================
local ControlFrame = Instance.new("Frame")
ControlFrame.Name = "ControlFrame"
ControlFrame.Size = UDim2.new(0, 420, 0, 320)
ControlFrame.Position = UDim2.new(0.5, -210, 0.15, 0)
ControlFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
ControlFrame.Active = true
ControlFrame.Visible = false
ControlFrame.Parent = ScreenGui
Instance.new("UICorner", ControlFrame).CornerRadius = UDim.new(0, 10)

local ControlTitleBar = Instance.new("Frame")
ControlTitleBar.Size = UDim2.new(1, 0, 0, 35)
ControlTitleBar.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
ControlTitleBar.Parent = ControlFrame
Instance.new("UICorner", ControlTitleBar).CornerRadius = UDim.new(0, 10)

local ControlTitleText = Instance.new("TextLabel")
ControlTitleText.Size = UDim2.new(1, -40, 1, 0)
ControlTitleText.Position = UDim2.new(0, 12, 0, 0)
ControlTitleText.Text = "CONFIGURAÇÃO DE TRANSMISSÃO"
ControlTitleText.TextColor3 = Color3.fromRGB(240, 240, 245)
ControlTitleText.TextSize = 11
ControlTitleText.Font = Enum.Font.GothamBold
ControlTitleText.TextXAlignment = Enum.TextXAlignment.Left
ControlTitleText.BackgroundTransparency = 1
ControlTitleText.Parent = ControlTitleBar

local ControlCloseBtn = Instance.new("TextButton")
ControlCloseBtn.Size = UDim2.new(0, 24, 0, 24)
ControlCloseBtn.Position = UDim2.new(1, -28, 0.5, -12)
ControlCloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 65)
ControlCloseBtn.Parent = ControlTitleBar
Instance.new("UICorner", ControlCloseBtn).CornerRadius = UDim.new(1, 0)
createDrawnX(ControlCloseBtn)

OpenMenuBtn.MouseButton1Click:Connect(function() ControlFrame.Visible = not ControlFrame.Visible end)
ControlCloseBtn.MouseButton1Click:Connect(function() ControlFrame.Visible = false end)

do
    local dragging, dragInput, dragStart, startPos
    ControlTitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging, dragStart, startPos = true, input.Position, ControlFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    ControlTitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            ControlFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Size = UDim2.new(1, -24, 1, -50)
ScrollList.Position = UDim2.new(0, 12, 0, 42)
ScrollList.BackgroundTransparency = 1
ScrollList.ScrollBarThickness = 4
ScrollList.Parent = ControlFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 6)
UIList.Parent = ScrollList

local function refreshPlayerList()
    for _, child in ipairs(ScrollList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        local ItemFrame = Instance.new("Frame")
        ItemFrame.Size = UDim2.new(1, -8, 0, 36)
        ItemFrame.BackgroundColor3 = Color3.fromRGB(25, 28, 36)
        ItemFrame.Parent = ScrollList
        Instance.new("UICorner", ItemFrame).CornerRadius = UDim.new(0, 6)

        local NameLbl = Instance.new("TextLabel")
        NameLbl.Size = UDim2.new(0.5, 0, 1, 0)
        NameLbl.Position = UDim2.new(0, 10, 0, 0)
        NameLbl.Text = getFormattedName(p)
        NameLbl.TextColor3 = Color3.fromRGB(220, 225, 235)
        NameLbl.TextSize = 12
        NameLbl.Font = Enum.Font.GothamMedium
        NameLbl.TextXAlignment = Enum.TextXAlignment.Left
        NameLbl.BackgroundTransparency = 1
        NameLbl.Parent = ItemFrame

        local T1Btn = Instance.new("TextButton")
        T1Btn.Size = UDim2.new(0, 70, 0, 24)
        T1Btn.Position = UDim2.new(1, -150, 0.5, -12)
        T1Btn.BackgroundColor3 = selectedTeam1[p.UserId] and Color3.fromRGB(30, 120, 240) or Color3.fromRGB(40, 45, 55)
        T1Btn.Text = "TIME A"
        T1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        T1Btn.TextSize = 10
        T1Btn.Font = Enum.Font.GothamBold
        T1Btn.Parent = ItemFrame
        Instance.new("UICorner", T1Btn).CornerRadius = UDim.new(0, 4)

        local T2Btn = Instance.new("TextButton")
        T2Btn.Size = UDim2.new(0, 70, 0, 24)
        T2Btn.Position = UDim2.new(1, -75, 0.5, -12)
        T2Btn.BackgroundColor3 = selectedTeam2[p.UserId] and Color3.fromRGB(240, 50, 80) or Color3.fromRGB(40, 45, 55)
        T2Btn.Text = "TIME B"
        T2Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        T2Btn.TextSize = 10
        T2Btn.Font = Enum.Font.GothamBold
        T2Btn.Parent = ItemFrame
        Instance.new("UICorner", T2Btn).CornerRadius = UDim.new(0, 4)

        T1Btn.MouseButton1Click:Connect(function()
            if selectedTeam1[p.UserId] then selectedTeam1[p.UserId] = nil else
                selectedTeam1[p.UserId] = p; selectedTeam2[p.UserId] = nil
            end
            refreshPlayerList()
        end)
        T2Btn.MouseButton1Click:Connect(function()
            if selectedTeam2[p.UserId] then selectedTeam2[p.UserId] = nil else
                selectedTeam2[p.UserId] = p; selectedTeam1[p.UserId] = nil
            end
            refreshPlayerList()
        end)
    end
    ScrollList.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y)
end
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(function(p)
    selectedTeam1[p.UserId] = nil; selectedTeam2[p.UserId] = nil
    maxHpCache[p.UserId] = nil; lastHpCache[p.UserId] = nil
    knockedState[p.UserId] = nil; avatarCache[p.UserId] = nil
    playerSpawnTime[p.UserId] = nil
    pcall(function() destroyXRay(p.UserId) end)
    if cloneCache[p.UserId] then pcall(function() cloneCache[p.UserId]:Destroy() end) cloneCache[p.UserId] = nil end
    formActiveUntil[p.UserId] = nil
    m2HoldUntil[p.UserId] = nil
    refreshPlayerList()
end)
refreshPlayerList()

-- ================================================
-- DETECÇÃO DE COMBATE (logs reais Demon Fall)
--   M1:    AttackAnnounce / Attacking
--          + ActivateLunge / ItemCooldown→LungeCooldown (Lunge = M1)
--   M2:    HeavyAnnounce / HeavyCooldown
--   Forma: Activate<Skill> (exceto Lunge) / ItemCooldown (exceto Lunge)
--   Busy aparece nos 3 → NÃO classifica sozinho
-- ================================================
local function getPlayerActionStates(player)
    local char = player.Character
    if not char or not char.Parent then
        local held = (formActiveUntil[player.UserId] or 0) > os.clock()
        return false, false, held
    end

    local hasAttackAnnounce, hasAttacking = false, false
    local hasHeavyAnnounce, hasHeavyCooldown = false, false
    local hasActivateForm = false
    local hasActivateLunge = false
    local hasItemCooldownForm = false
    local hasItemCooldownLunge = false

    for _, child in ipairs(char:GetChildren()) do
        local n = child.Name

        if n == "AttackAnnounce" then
            hasAttackAnnounce = true
        elseif n == "Attacking" then
            hasAttacking = true
        elseif n == "HeavyAnnounce" then
            hasHeavyAnnounce = true
        elseif n == "HeavyCooldown" then
            hasHeavyCooldown = true
        elseif string.sub(n, 1, 8) == "Activate" then
            local low = string.lower(n)
            -- utilitários Z/X (Crow, Dash, etc.) NÃO contam como Forma
            local isUtil = string.find(low, "crow", 1, true)
                or string.find(low, "dash", 1, true)
                or string.find(low, "scar", 1, true)
                or string.find(low, "meditat", 1, true)
                or string.find(low, "utility", 1, true)
                or string.find(low, "emote", 1, true)
                or string.find(low, "item", 1, true)
            if isUtil then
                -- ignora
            elseif n == "ActivateLunge" or string.find(low, "lunge", 1, true) then
                hasActivateLunge = true
            else
                hasActivateForm = true
            end
        elseif n == "ItemCooldown" then
            local targetName = ""
            pcall(function()
                if child:IsA("ObjectValue") and child.Value then
                    targetName = tostring(child.Value.Name or child.Value)
                elseif child:IsA("StringValue") then
                    targetName = tostring(child.Value)
                end
            end)
            local low = string.lower(targetName)
            local isUtil = string.find(low, "crow", 1, true)
                or string.find(low, "dash", 1, true)
                or string.find(low, "scar", 1, true)
                or string.find(low, "meditat", 1, true)
                or string.find(low, "utility", 1, true)
                or string.find(low, "emote", 1, true)
                or low == "" -- ItemCooldown sem alvo = genérico, ignora
            if isUtil then
                -- ignora utilitário
            elseif string.find(low, "lunge", 1, true) then
                hasItemCooldownLunge = true
            else
                hasItemCooldownForm = true
            end
        end
    end

    -- Prioridade: Forma > M2 > M1
    local isForm = false
    if hasActivateForm or hasItemCooldownForm then
        isForm = true
        formActiveUntil[player.UserId] = os.clock() + 0.45
    elseif (formActiveUntil[player.UserId] or 0) > os.clock() then
        isForm = true
    else
        formActiveUntil[player.UserId] = nil
    end

    if isForm then
        return false, false, true
    end

    if hasHeavyAnnounce or hasHeavyCooldown then
        return false, true, false
    end

    -- M1: AttackAnnounce/Attacking OU Lunge (ActivateLunge / LungeCooldown)
    if hasAttackAnnounce or hasAttacking or hasActivateLunge or hasItemCooldownLunge then
        return true, false, false
    end

    return false, false, false
end

-- ================================================
-- CONTAINERS, CÁLCULO DE VIDA E CAPTURA 3D
-- ================================================
local Team1Container = Instance.new("Frame")
Team1Container.AnchorPoint = Vector2.new(0.5, 0.5)
Team1Container.Position = UDim2.new(0.25, 0, 0.86, 0)
Team1Container.Size = UDim2.new(0, 0, 0, 95)
Team1Container.AutomaticSize = Enum.AutomaticSize.X
Team1Container.BackgroundTransparency = 1
Team1Container.Parent = ScreenGui
local T1Layout = Instance.new("UIListLayout")
T1Layout.FillDirection = Enum.FillDirection.Horizontal
T1Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
T1Layout.VerticalAlignment = Enum.VerticalAlignment.Center
T1Layout.Padding = UDim.new(0, 12)
T1Layout.Parent = Team1Container

local Team2Container = Instance.new("Frame")
Team2Container.AnchorPoint = Vector2.new(0.5, 0.5)
Team2Container.Position = UDim2.new(0.75, 0, 0.86, 0)
Team2Container.Size = UDim2.new(0, 0, 0, 95)
Team2Container.AutomaticSize = Enum.AutomaticSize.X
Team2Container.BackgroundTransparency = 1
Team2Container.Parent = ScreenGui
local T2Layout = Instance.new("UIListLayout")
T2Layout.FillDirection = Enum.FillDirection.Horizontal
T2Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
T2Layout.VerticalAlignment = Enum.VerticalAlignment.Center
T2Layout.Padding = UDim.new(0, 12)
T2Layout.Parent = Team2Container

local function getHealth(player)
    local char = player.Character

    -- ========== HP ATUAL ==========
    -- Demon Fall: NumberValue "Health" no Character (replica) ou no Player
    local hp = nil
    if char then
        local hpVal = char:FindFirstChild("Health")
        if hpVal and hpVal:IsA("ValueBase") then
            hp = tonumber(hpVal.Value)
        end
    end
    if hp == nil then
        local pHp = player:FindFirstChild("Health")
        if pHp and pHp:IsA("ValueBase") then
            hp = tonumber(pHp.Value)
        end
    end
    -- NÃO usar Humanoid.Health (no DF costuma ser 100 falso)
    hp = hp or 0

    -- ========== HP MÁXIMO REAL ==========
    -- Fonte oficial: Player.MaxHealth (IntValue) — NÃO usa "maior HP já visto"
    local maxHp = nil
    local maxVal = player:FindFirstChild("MaxHealth")
    if maxVal and maxVal:IsA("ValueBase") then
        local v = tonumber(maxVal.Value)
        if v and v > 0 then
            maxHp = v
            maxHpCache[player.UserId] = v -- só backup se o Value sumir 1 frame
        end
    end
    -- fallback raro: Character.MaxHealth
    if not maxHp and char then
        local cMax = char:FindFirstChild("MaxHealth")
        if cMax and cMax:IsA("ValueBase") then
            local v = tonumber(cMax.Value)
            if v and v > 0 then
                maxHp = v
                maxHpCache[player.UserId] = v
            end
        end
    end
    -- último recurso: último MaxHealth conhecido deste player (não "pico de dano")
    if not maxHp then
        maxHp = maxHpCache[player.UserId]
    end
    if not maxHp or maxHp < 1 then
        maxHp = math.max(hp, 100)
    end
    if maxHp < hp then maxHp = hp end

    return math.floor(hp), math.floor(maxHp)
end

-- Barra de respiração (0-100). Fonte: Player.Breathing (NumberValue)
local function getBreathing(player)
    local b = player:FindFirstChild("Breathing")
    if b and b:IsA("ValueBase") then
        local v = tonumber(b.Value)
        if v then return math.clamp(v, 0, 100) end
    end
    local char = player.Character
    if char then
        local cb = char:FindFirstChild("Breathing")
        if cb and cb:IsA("ValueBase") then
            local v = tonumber(cb.Value)
            if v then return math.clamp(v, 0, 100) end
        end
    end
    return nil
end

-- ================================================
-- DETECÇÃO DE ESTILO DE RESPIRAÇÃO (via Form*Cooldown)
-- ================================================
local STYLE_HINTS = {
    ["Water Surface"] = "Water", ["Water Wheel"] = "Water", ["Flowing Dance"] = "Water",
    ["Whirlpool"] = "Water", ["Striking Tide"] = "Water", ["Blessed Rain"] = "Water",
    ["Drop Ripple"] = "Water", ["Waterfall Basin"] = "Water", ["Splashing Water"] = "Water",
    ["Constant Flux"] = "Water",
    ["Flame Bend"] = "Flame", ["Rengoku"] = "Flame", ["Unknowing Fire"] = "Flame",
    ["Rising Scorching"] = "Flame", ["Blooming Flame"] = "Flame", ["Burning Bones"] = "Flame",
    ["Flame Tiger"] = "Flame", ["Scorching Sun"] = "Flame",
    ["Obscuring Clouds"] = "Mist", ["Eight-Layered"] = "Mist", ["Scattering Mist"] = "Mist",
    ["Shifting Flow"] = "Mist", ["Sea of Clouds"] = "Mist",
    ["Thunderclap"] = "Thunder", ["Rice Spirit"] = "Thunder", ["Thunder Swarm"] = "Thunder",
    ["Distant Thunder"] = "Thunder", ["Heat Lightning"] = "Thunder", ["Rumble"] = "Thunder",
    ["Flaming Thunder"] = "Thunder",
    ["Butterfly"] = "Insect", ["Dance of the Bee"] = "Insect", ["Dragonfly"] = "Insect",
    ["Centipede"] = "Insect", ["Compound Eye"] = "Insect",
    ["Dust Whirlwind"] = "Wind", ["Clean Storm"] = "Wind", ["Rising Dust"] = "Wind",
    ["Cold Mountain"] = "Wind", ["Black Wind"] = "Wind", ["Gale"] = "Wind",
    ["Clear Blue Sky"] = "Sun", ["Raging Sun"] = "Sun", ["Setting Sun"] = "Sun",
    ["Solar Heat Haze"] = "Sun", ["Beneficent Sun"] = "Sun", ["Sun Halo"] = "Sun",
    ["Dragon Sun"] = "Sun", ["Fire Wheel"] = "Sun",
    ["Dark Moon"] = "Moon", ["Pearl Eyes"] = "Moon", ["Loathsome Moon"] = "Moon",
    ["Moon Spirit"] = "Moon", ["Moonbow"] = "Moon", ["Perpetual Night"] = "Moon",
    ["Mirror of Misfortune"] = "Moon",
    ["Fang"] = "Beast", ["Devour"] = "Beast", ["Crazy Cutting"] = "Beast",
    ["Spatial Awareness"] = "Beast", ["Palisade"] = "Beast",
    ["Roar"] = "Sound", ["String Performance"] = "Sound", ["Disturbing"] = "Sound",
    ["Constant Resounding"] = "Sound",
    ["Equinoctial"] = "Flower", ["Honorable Shadow"] = "Flower", ["Crimson Hanagora"] = "Flower",
    ["Hanaguma"] = "Flower", ["Peony"] = "Flower", ["Whirling Peach"] = "Flower",
    ["Winding Serpent"] = "Serpent", ["Venom Fangs"] = "Serpent", ["Coil"] = "Serpent",
    ["Slithering"] = "Serpent", ["Twin-Headed"] = "Serpent",
    ["Catlove"] = "Love", ["Love Pounce"] = "Love", ["Shivers of First Love"] = "Love",
    ["Stone Crush"] = "Stone", ["Upper Smash"] = "Stone", ["Stone Skin"] = "Stone",
    ["Volcanic"] = "Stone",
    -- Demon Arts (Blood Demon Arts) — nomes de skill/cooldown
    ["Blood"] = "Blood",
    ["Blood Burst"] = "Blood",
    ["Blood Letter"] = "Blood",
    ["Blood Sickle"] = "Blood",
    ["BloodSickle"] = "Blood",
    ["Sanguine"] = "Blood",
    ["Hemorrhage"] = "Blood",
    ["Crimson"] = "Blood",
    ["Flaming Blood"] = "Blood",
    ["Explosive Blood"] = "Blood",
    ["Exploding Blood"] = "Blood",
    ["DarkThunder"] = "DarkThunder",
    ["Dark Thunder"] = "DarkThunder",
    ["Black Lightning"] = "DarkThunder",
    ["Thunder Blood"] = "DarkThunder",
    -- Hantengu (clones: madeira / vento / trovão / grito)
    ["Wood Dragon"] = "Hantengu",
    ["Wind Hurricane"] = "Hantengu",
    ["Wind Lance"] = "Hantengu",
    ["Thunderbolt"] = "Hantengu",
    ["Demon Scream"] = "Hantengu",
    ["LowScream"] = "Hantengu",
    ["Hantengu"] = "Hantengu",
    ["Emotion"] = "Hantengu",
    ["Zohakuten"] = "Hantengu",
    ["Sekido"] = "Hantengu",
    ["Karaku"] = "Hantengu",
    ["Urogi"] = "Hantengu",
    ["Aizetsu"] = "Hantengu",
    -- Outras Demon Arts
    ["Arrow"] = "Arrow",
    ["Blood Arrow"] = "Arrow",
    ["Ice"] = "Ice",
    ["Frozen"] = "Ice",
    ["Frost"] = "Ice",
    ["Shadow"] = "Shadow",
    ["Umbral"] = "Shadow",
    ["Shockwave"] = "Shockwave",
    ["String"] = "String",
    ["Thread"] = "String",
    ["Web"] = "String",
    ["Sickle"] = "Sickle",
    ["Obi"] = "Obi",
    ["Swamp"] = "Swamp",
    ["Bog"] = "Swamp",
    -- Akaza (Destructive Death / Compass Needle)
    ["Compass Needle"] = "Akaza",
    ["Air Type"] = "Akaza",
    ["Annihilation Type"] = "Akaza",
    ["Flying Planet"] = "Akaza",
    ["Thousand Wheels"] = "Akaza",
    ["Explosive Flurry"] = "Akaza",
    ["Shocking Jack"] = "Akaza",
    ["Destructive Death"] = "Akaza",
    ["Akaza"] = "Akaza",
    ["BDA"] = "Blood",
    ["Demon Art"] = "Blood",
}

local SORTED_STYLE_HINTS = {}
for hint, style in pairs(STYLE_HINTS) do
    table.insert(SORTED_STYLE_HINTS, {hint = hint, style = style})
end
table.sort(SORTED_STYLE_HINTS, function(a, b) return #a.hint > #b.hint end)

local STYLE_EMOJI = {
    Water = "💧", Flame = "🔥", Mist = "🌫️", Thunder = "⚡", Insect = "🦋",
    Wind = "💨", Sun = "☀️", Moon = "🌙", Beast = "🐗", Sound = "🔊",
    Flower = "🌸", Serpent = "🐍", Love = "💕", Stone = "🪨",
    -- Demon Arts
    Blood = "🩸", DarkThunder = "💜", Wood = "🌲", Scream = "😱",
    Arrow = "🏹", Ice = "❄️", Shadow = "🌑", Shockwave = "💥",
    String = "🕸️", Sickle = "🔪", Obi = "🎀", Hantengu = "🎭", Swamp = "🐊",
    Akaza = "💥", Shockwave = "💥",
    None = "FR", Unknown = "❓",
}

local STYLE_COLOR = {
    Water = Color3.fromRGB(70, 170, 255),
    Flame = Color3.fromRGB(255, 120, 40),
    Mist = Color3.fromRGB(190, 210, 230),
    Thunder = Color3.fromRGB(255, 220, 60),
    Insect = Color3.fromRGB(140, 230, 100),
    Wind = Color3.fromRGB(120, 230, 190),
    Sun = Color3.fromRGB(255, 200, 50),
    Moon = Color3.fromRGB(170, 150, 255),
    Beast = Color3.fromRGB(210, 150, 90),
    Sound = Color3.fromRGB(255, 110, 190),
    Flower = Color3.fromRGB(255, 160, 210),
    Serpent = Color3.fromRGB(80, 200, 120),
    Love = Color3.fromRGB(255, 120, 180),
    Stone = Color3.fromRGB(170, 160, 150),
    Blood = Color3.fromRGB(200, 40, 55),
    DarkThunder = Color3.fromRGB(140, 90, 255),
    Wood = Color3.fromRGB(90, 160, 70),
    Scream = Color3.fromRGB(220, 80, 120),
    Arrow = Color3.fromRGB(220, 100, 80),
    Ice = Color3.fromRGB(140, 210, 255),
    Shadow = Color3.fromRGB(80, 70, 120),
    Shockwave = Color3.fromRGB(255, 160, 60),
    String = Color3.fromRGB(200, 80, 100),
    Sickle = Color3.fromRGB(180, 60, 70),
    Obi = Color3.fromRGB(255, 140, 180),
    Hantengu = Color3.fromRGB(200, 120, 220),
    Swamp = Color3.fromRGB(70, 140, 90),
    Akaza = Color3.fromRGB(255, 90, 50),
    None = Color3.fromRGB(90, 95, 110),
    Unknown = Color3.fromRGB(255, 180, 60),
}

local function detectBreathingStyle(player)
    if not player then return "None" end
    local uid = player.UserId
    local remembered = styleCache[uid] and styleCache[uid].style

    -- Utilitários Z/X e cooldowns genéricos — NUNCA contam como estilo
    local UTILITY_BLACKLIST = {
        crow = true, dash = true, lunge = true, combat = true,
        block = true, parry = true, dodge = true, roll = true,
        scar = true, meditation = true, utility = true,
        camera = true, shift = true, menu = true, inventory = true,
        item = true, tool = true, weapon = true, equip = true,
        health = true, stamina = true, hunger = true, breathing = true,
        experience = true, prestige = true, level = true,
        maxhealth = true, maxstamina = true, maxhunger = true,
        spawn = true, ragdoll = true, stun = true, busy = true,
        aggro = true, sequence = true, fighting = true,
        sawed = true, gun = true, pistol = true,
        emote = true, dance = true, sit = true,
    }

    local function isUtilityCooldown(name)
        local low = string.lower(tostring(name or ""))
        -- remove sufixo Cooldown para checar a base
        local base = low:gsub("cooldown", ""):gsub("%s+", ""):gsub("%-", ""):gsub("_", "")
        if UTILITY_BLACKLIST[base] then return true end
        for key in pairs(UTILITY_BLACKLIST) do
            if string.find(low, key, 1, true) and (
                key == "crow" or key == "dash" or key == "lunge"
                or key == "combat" or key == "scar" or key == "meditation"
                or key == "utility" or key == "item" or key == "emote"
            ) then
                return true
            end
        end
        -- nomes curtos demais / só "Cooldown"
        if #base < 3 then return true end
        return false
    end

    local votes = {}
    -- SÓ Player IntValue *Cooldown* (skills reais ficam aqui)
    -- NÃO usa Character Activate* — utilitários Z/X criam Activate e geram falso positivo
    for _, child in ipairs(player:GetChildren()) do
        if child:IsA("IntValue") then
            local n = child.Name
            if string.find(n, "Cooldown", 1, true) and not isUtilityCooldown(n) then
                for _, entry in ipairs(SORTED_STYLE_HINTS) do
                    if string.find(n, entry.hint, 1, true) then
                        votes[entry.style] = (votes[entry.style] or 0) + 1
                        break
                    end
                end
            end
        end
    end

    local best, bestN = nil, 0
    for style, n in pairs(votes) do
        if n > bestN then best, bestN = style, n end
    end

    -- PERSISTENTE: uma vez detectado por skill real, NUNCA volta pra None
    if best then
        styleCache[uid] = {style = best, at = os.clock()}
        return best
    end
    if remembered and remembered ~= "None" then
        return remembered
    end
    return "None"
end


-- Stamina atual e máxima (Player ou Character)
local function getStamina(player)
    local cur, maxS = nil, nil
    local s = player:FindFirstChild("Stamina")
    if s and s:IsA("ValueBase") then cur = tonumber(s.Value) end
    local ms = player:FindFirstChild("MaxStamina")
    if ms and ms:IsA("ValueBase") then maxS = tonumber(ms.Value) end
    local char = player.Character
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
    cur = math.clamp(cur, 0, maxS)
    return cur, maxS
end


local function popDamageText(card, damageAmount)
    local dmgLabel = Instance.new("TextLabel")
    dmgLabel.Size = UDim2.new(1, 0, 0, 24)
    dmgLabel.Position = UDim2.new(0, 0, 0, -92)
    dmgLabel.BackgroundTransparency = 1
    dmgLabel.Text = "-" .. tostring(damageAmount)
    dmgLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    dmgLabel.TextSize = 20
    dmgLabel.Font = Enum.Font.GothamBold
    dmgLabel.TextStrokeTransparency = 0.3
    dmgLabel.ZIndex = 12
    dmgLabel.Parent = card
    local tween = TweenService:Create(dmgLabel, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, -125), TextTransparency = 1, TextStrokeTransparency = 1
    })
    tween:Play()
    tween.Completed:Connect(function() dmgLabel:Destroy() end)
end

local function isCharacterAlive(char)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 then return false end
    if char:FindFirstChild("Dead") or char:FindFirstChild("Ragdoll") then return false end
    return char:FindFirstChild("HumanoidRootPart") ~= nil or char:FindFirstChild("Head") ~= nil
end

local function captureClone(player)
    local char = player.Character
    if not char or not isCharacterAlive(char) then return nil end
    local ok, clone = pcall(function() char.Archivable = true; local c = char:Clone(); char.Archivable = false; return c end)
    if not ok or not clone then return nil end
    for _, part in ipairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then part.Anchored = true; part.CanCollide = false
        elseif part:IsA("Script") or part:IsA("LocalScript") then part:Destroy() end
    end
    local hum = clone:FindFirstChildOfClass("Humanoid")
    if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None; pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end) end
    return clone
end

-- ================================================
-- CRIAÇÃO DO CARD 3D E INDICADORES (M1, M2, FORMA)
-- ================================================
local activeCards = {}
local cardViewportConnections = {}
local cardSetupFns = {} 

local function createPlayerCard(player, teamColor)
    local Card = Instance.new("Frame")
    -- [NOVO] Aumentado a largura de 120 para 146 para caber a barra de indicadores na direita
    Card.Size = UDim2.new(0, 150, 0, 98)
    Card.BackgroundColor3 = Color3.fromRGB(15, 17, 22)
    Card.BorderSizePixel = 0
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

    local DarkBackground = Instance.new("Frame", Card)
    DarkBackground.Size = UDim2.new(1, 0, 1, 0)
    DarkBackground.BackgroundColor3 = Color3.fromRGB(25, 28, 35)
    Instance.new("UICorner", DarkBackground).CornerRadius = UDim.new(0, 8)

    local HealthFill = Instance.new("Frame", Card)
    HealthFill.Name = "HealthFill"
    HealthFill.Size = UDim2.new(1, 0, 1, 0)
    HealthFill.BackgroundColor3 = teamColor
    HealthFill.ClipsDescendants = true
    Instance.new("UICorner", HealthFill).CornerRadius = UDim.new(0, 8)

    local CharacterContainer = Instance.new("Frame", Card)
    CharacterContainer.Name = "CharacterContainer"
    CharacterContainer.Size = UDim2.new(0, 90, 0, 90)
    -- Ajustado para a esquerda para abrir espaço na direita
    CharacterContainer.Position = UDim2.new(0, 10, 0, -88)
    CharacterContainer.BackgroundTransparency = 1
    CharacterContainer.ZIndex = 8

    local AvatarImg = Instance.new("ImageLabel", CharacterContainer)
    AvatarImg.Size = UDim2.new(1, 0, 1, 0)
    AvatarImg.BackgroundTransparency = 1
    AvatarImg.ZIndex = 8
    task.spawn(function()
        if avatarCache[player.UserId] then AvatarImg.Image = avatarCache[player.UserId] else
            local content, isReady = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
            if isReady then avatarCache[player.UserId] = content; AvatarImg.Image = content end
        end
    end)

    local Viewport = Instance.new("ViewportFrame", CharacterContainer)
    Viewport.Name = "Viewport"
    Viewport.Size = UDim2.new(1, 0, 1, 0)
    Viewport.BackgroundTransparency = 1
    Viewport.ZIndex = 9
    Viewport.Visible = false
    Viewport.Ambient = Color3.fromRGB(200, 200, 200)

    local World = Instance.new("WorldModel", Viewport)
    local Cam = Instance.new("Camera", Viewport)
    Viewport.CurrentCamera = Cam

    local function applyCloneToViewport(sourceClone)
        if not sourceClone then return false end
        local clone = sourceClone:Clone()
        World:ClearAllChildren()
        clone.Parent = World
        local head = clone:FindFirstChild("Head") or clone:FindFirstChild("HumanoidRootPart")
        if head then
            local headPos = head.Position
            Cam.CFrame = CFrame.lookAt(headPos + (head.CFrame.LookVector * 2.6) + Vector3.new(0, -0.15, 0), headPos)
            Viewport.Visible = true; AvatarImg.Visible = false
            return true
        end
        return false
    end

    local function setup3DRender(forceRecapture)
        local userId = player.UserId
        if not forceRecapture and cloneCache[userId] and cloneCache[userId].Parent == nil then
            if applyCloneToViewport(cloneCache[userId]) then return end
        end
        local char = player.Character
        if not char or not isCharacterAlive(char) then
            if cloneCache[userId] then applyCloneToViewport(cloneCache[userId]) end return
        end
        task.wait(0.25)
        local newClone = captureClone(player)
        if newClone then
            if cloneCache[userId] then pcall(function() cloneCache[userId]:Destroy() end) end
            newClone.Parent = nil; cloneCache[userId] = newClone; applyCloneToViewport(newClone)
        elseif cloneCache[userId] then applyCloneToViewport(cloneCache[userId]) end
    end
    cardSetupFns[player.UserId] = setup3DRender
    if player.Character then task.spawn(function() setup3DRender(true) end) end
    cardViewportConnections[player.UserId] = player.CharacterAdded:Connect(function()
        task.spawn(function() task.wait(0.5); setup3DRender(true) end)
    end)

    local NameLbl = Instance.new("TextLabel", Card)
    NameLbl.Size = UDim2.new(1, -30, 0, 22)
    NameLbl.Position = UDim2.new(0, 6, 1, -24)
    NameLbl.Text = getFormattedName(player):upper()
    NameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLbl.TextSize = 12
    NameLbl.Font = Enum.Font.GothamBold
    NameLbl.BackgroundTransparency = 1
    NameLbl.TextXAlignment = Enum.TextXAlignment.Left
    NameLbl.ZIndex = 6

    local HealthLbl = Instance.new("TextLabel", Card)
    HealthLbl.Name = "HealthText"
    HealthLbl.Size = UDim2.new(1, -30, 0, 38)
    HealthLbl.Position = UDim2.new(0, 6, 0.2, 0)
    HealthLbl.Text = "100"
    HealthLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    HealthLbl.TextSize = 28
    HealthLbl.Font = Enum.Font.GothamBold
    HealthLbl.BackgroundTransparency = 1
    HealthLbl.TextXAlignment = Enum.TextXAlignment.Left
    HealthLbl.ZIndex = 6

    -- ================================================
    -- [NOVO] COLUNA DOS 3 QUADRADOS INDICADORES (M1, M2, RESP)
    -- ================================================
    local IndicatorBar = Instance.new("Frame", Card)
    IndicatorBar.Name = "IndicatorBar"
    IndicatorBar.Size = UDim2.new(0, 24, 1, -10)
    IndicatorBar.Position = UDim2.new(1, -30, 0, 5)
    IndicatorBar.BackgroundTransparency = 1
    IndicatorBar.ZIndex = 7

    local IndLayout = Instance.new("UIListLayout", IndicatorBar)
    IndLayout.FillDirection = Enum.FillDirection.Vertical
    IndLayout.Padding = UDim.new(0, 5)
    IndLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local function createIndicator(name, text, activeColor, textSize)
        local frame = Instance.new("Frame")
        frame.Name = name
        frame.Size = UDim2.new(0, 24, 0, 24)
        frame.BackgroundColor3 = Color3.fromRGB(28, 32, 40)
        frame.BorderSizePixel = 0
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

        local stroke = Instance.new("UIStroke")
        stroke.Name = "Stroke"
        stroke.Color = Color3.fromRGB(45, 50, 60)
        stroke.Thickness = 1
        stroke.Transparency = 0.35
        stroke.Parent = frame

        frame:SetAttribute("ActiveColor", activeColor)
        frame:SetAttribute("IdleColor", Color3.fromRGB(28, 32, 40))

        local lbl = Instance.new("TextLabel", frame)
        lbl.Name = "Label"
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(130, 135, 145)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = textSize or 10
        return frame
    end

    -- M1 / M2 / Estilo (emoji da respiração)
    local indM1 = createIndicator("M1Box", "M1", Color3.fromRGB(255, 210, 60), 10)
    indM1.Parent = IndicatorBar

    local indM2 = createIndicator("M2Box", "M2", Color3.fromRGB(255, 110, 55), 10)
    indM2.Parent = IndicatorBar

    local indForm = createIndicator("FormBox", "FR", Color3.fromRGB(80, 220, 255), 11)
    indForm.Parent = IndicatorBar

    -- ================================================
    -- BARRA DE RESPIRAÇÃO (moderna, abaixo do nome)
    -- ================================================
    -- Stamina (verde) em cima, Breathing (ciano) embaixo
    local StaminaTrack = Instance.new("Frame", Card)
    StaminaTrack.Name = "StaminaTrack"
    StaminaTrack.Size = UDim2.new(1, -36, 0, 4)
    StaminaTrack.Position = UDim2.new(0, 6, 1, -12)
    StaminaTrack.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
    StaminaTrack.BorderSizePixel = 0
    StaminaTrack.ZIndex = 7
    Instance.new("UICorner", StaminaTrack).CornerRadius = UDim.new(1, 0)

    local StaminaFill = Instance.new("Frame", StaminaTrack)
    StaminaFill.Name = "StaminaFill"
    StaminaFill.Size = UDim2.new(1, 0, 1, 0)
    StaminaFill.BackgroundColor3 = Color3.fromRGB(80, 230, 120)
    StaminaFill.BorderSizePixel = 0
    StaminaFill.ZIndex = 8
    Instance.new("UICorner", StaminaFill).CornerRadius = UDim.new(1, 0)
    local sGrad = Instance.new("UIGradient", StaminaFill)
    sGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 180, 90)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 255, 160)),
    })

    local BreathTrack = Instance.new("Frame", Card)
    BreathTrack.Name = "BreathTrack"
    BreathTrack.Size = UDim2.new(1, -36, 0, 4)
    BreathTrack.Position = UDim2.new(0, 6, 1, -6)
    BreathTrack.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
    BreathTrack.BorderSizePixel = 0
    BreathTrack.ZIndex = 7
    Instance.new("UICorner", BreathTrack).CornerRadius = UDim.new(1, 0)

    local BreathFill = Instance.new("Frame", BreathTrack)
    BreathFill.Name = "BreathFill"
    BreathFill.Size = UDim2.new(1, 0, 1, 0)
    BreathFill.BackgroundColor3 = Color3.fromRGB(80, 220, 255)
    BreathFill.BorderSizePixel = 0
    BreathFill.ZIndex = 8
    Instance.new("UICorner", BreathFill).CornerRadius = UDim.new(1, 0)
    local grad = Instance.new("UIGradient", BreathFill)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 180, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 255, 230)),
    })

    NameLbl.Position = UDim2.new(0, 6, 1, -30)
    NameLbl.Size = UDim2.new(1, -30, 0, 16)

    return Card
end

-- ================================================
-- ATUALIZAÇÃO DO X-RAY (versão original restaurada)
-- Highlight no ScreenGui do torneio — mesmo padrão que funcionava antes.
-- ================================================
local XRayFolder = Instance.new("Folder")
XRayFolder.Name = "CS2_XRayHighlights"
XRayFolder.Parent = ScreenGui

local function destroyXRay(userId)
    local h = xrayHighlights[userId]
    if h then
        pcall(function() h:Destroy() end)
        xrayHighlights[userId] = nil
    end
end

local function destroyAllXRay()
    for uid in pairs(xrayHighlights) do
        destroyXRay(uid)
    end
    for _, c in ipairs(XRayFolder:GetChildren()) do
        pcall(function() c:Destroy() end)
    end
end

local function updateXRayGlow(player, teamColor, hpPct)
    local userId = player.UserId
    local char = player.Character
    if not xrayEnabled or not char or not char.Parent then
        destroyXRay(userId)
        return
    end

    local highlight = xrayHighlights[userId]
    if (not highlight) or (not highlight.Parent) or (highlight.Adornee ~= char) then
        if highlight then pcall(function() highlight:Destroy() end) end
        highlight = Instance.new("Highlight")
        highlight.Name = "CS2_XRay_" .. tostring(userId)
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Adornee = char
        highlight.Parent = XRayFolder
        xrayHighlights[userId] = highlight
    end

    highlight.Enabled = true
    highlight.FillColor = teamColor
    local isRed = (teamColor.R > 0.7 and teamColor.G < 0.4)
    highlight.OutlineColor = isRed and Color3.fromRGB(255, 80, 100) or Color3.fromRGB(255, 255, 255)
    local fillT = math.clamp(1 - (hpPct * 0.7), 0.15, 0.85)
    local outT = math.clamp(1 - (hpPct * 0.9), 0.0, 0.7)
    if isRed then
        fillT = math.clamp(fillT - 0.1, 0.1, 0.8)
        outT = math.clamp(outT - 0.15, 0.0, 0.65)
    end
    highlight.FillTransparency = fillT
    highlight.OutlineTransparency = outT
end

-- ================================================
-- LOOP PRINCIPAL (OVERLAY + SENSORES)
-- ================================================
_G.CS2OverlayConnection = RunService.RenderStepped:Connect(function()
    local allSelected = {}
    for userId, player in pairs(selectedTeam1) do allSelected[userId] = {player = player, color = Color3.fromRGB(30, 120, 240), container = Team1Container} end
    for userId, player in pairs(selectedTeam2) do allSelected[userId] = {player = player, color = Color3.fromRGB(255, 40, 70), container = Team2Container} end

    for userId, data in pairs(allSelected) do
        local player = data.player
        if player and player.Parent then
            if not activeCards[userId] then activeCards[userId] = createPlayerCard(player, data.color); activeCards[userId].Parent = data.container end
            local card = activeCards[userId]
            local hp, maxHp = getHealth(player)
            if lastHpCache[userId] and hp < lastHpCache[userId] then popDamageText(card, lastHpCache[userId] - hp) end
            lastHpCache[userId] = hp

            local wasKnocked = knockedState[userId]
            if hp <= 0 then knockedState[userId] = true
            elseif knockedState[userId] and hp >= (maxHp * RECOVERY_THRESHOLD_PCT) then
                knockedState[userId] = false
                if cardSetupFns[userId] then task.spawn(function() cardSetupFns[userId](true) end) end
            end

            if knockedState[userId] and not wasKnocked then
                if cardSetupFns[userId] and cloneCache[userId] then task.spawn(function() cardSetupFns[userId](false) end) end
            end

            local pct = math.clamp(hp / math.max(maxHp, 1), 0, 1)
            card.HealthFill:TweenSizeAndPosition(UDim2.new(1, 0, pct, 0), UDim2.new(0, 0, 1 - pct, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
            updateXRayGlow(player, data.color, pct)
            if knockedState[userId] then
                card.HealthText.Text = "DEAD"
                card.HealthText.TextColor3 = Color3.fromRGB(220, 50, 50)
            else
                card.HealthText.Text = tostring(hp)
                card.HealthText.TextColor3 = Color3.fromRGB(255, 255, 255)
            end

            -- Barra de stamina (verde)
            local stamTrack = card:FindFirstChild("StaminaTrack")
            if stamTrack then
                local fill = stamTrack:FindFirstChild("StaminaFill")
                local cur, maxS = getStamina(player)
                if fill then
                    if not cur then
                        fill.Size = UDim2.new(0, 0, 1, 0)
                        fill.BackgroundColor3 = Color3.fromRGB(60, 65, 75)
                    else
                        local pctS = math.clamp(cur / math.max(maxS or 200, 1), 0, 1)
                        fill:TweenSize(UDim2.new(pctS, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.12, true)
                        if pctS > 0.4 then
                            fill.BackgroundColor3 = Color3.fromRGB(80, 230, 120)
                        elseif pctS > 0.2 then
                            fill.BackgroundColor3 = Color3.fromRGB(230, 200, 60)
                        else
                            fill.BackgroundColor3 = Color3.fromRGB(230, 80, 70)
                        end
                    end
                end
            end

            -- Barra de respiração (ciano)
            local breathTrack = card:FindFirstChild("BreathTrack")
            if breathTrack then
                local fill = breathTrack:FindFirstChild("BreathFill")
                local breath = getBreathing(player)
                if fill then
                    if breath == nil then
                        fill.Size = UDim2.new(0, 0, 1, 0)
                        fill.BackgroundColor3 = Color3.fromRGB(60, 65, 75)
                    else
                        local pctB = math.clamp(breath / 100, 0, 1)
                        fill:TweenSize(UDim2.new(pctB, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.12, true)
                        if pctB > 0.45 then
                            fill.BackgroundColor3 = Color3.fromRGB(80, 220, 255)
                        elseif pctB > 0.2 then
                            fill.BackgroundColor3 = Color3.fromRGB(255, 190, 60)
                        else
                            fill.BackgroundColor3 = Color3.fromRGB(255, 70, 80)
                        end
                    end
                end
            end

            -- ================================================
            -- ATUALIZA M1 / M2 / EMOJI DA RESPIRAÇÃO
            -- ================================================
            local isM1, isM2, isForm = false, false, false
            pcall(function()
                isM1, isM2, isForm = getPlayerActionStates(player)
            end)
            local breathStyle = "None"
            pcall(function()
                breathStyle = detectBreathingStyle(player) or "None"
            end)
            local styleEmoji = STYLE_EMOJI[breathStyle] or STYLE_EMOJI.None
            local styleCol = STYLE_COLOR[breathStyle] or STYLE_COLOR.None
            local indBar = card:FindFirstChild("IndicatorBar")

            if indBar and not knockedState[userId] then
                local m1Box = indBar:FindFirstChild("M1Box")
                local m2Box = indBar:FindFirstChild("M2Box")
                local formBox = indBar:FindFirstChild("FormBox")

                local function setBox(box, active, activeColor, idleLabelColor)
                    if not box then return end
                    local idle = box:GetAttribute("IdleColor") or Color3.fromRGB(28, 32, 40)
                    local ac = activeColor or box:GetAttribute("ActiveColor")
                    box.BackgroundColor3 = active and ac or idle
                    local lbl = box:FindFirstChild("Label")
                    if lbl then
                        lbl.TextColor3 = active and Color3.fromRGB(20, 20, 22) or (idleLabelColor or Color3.fromRGB(130, 135, 145))
                    end
                    local st = box:FindFirstChild("Stroke")
                    if st then
                        st.Color = active and ac or Color3.fromRGB(45, 50, 60)
                        st.Transparency = active and 0.1 or 0.35
                    end
                end

                setBox(m1Box, isM1)
                setBox(m2Box, isM2)

                if formBox then
                    local lbl = formBox:FindFirstChild("Label")
                    if lbl then
                        lbl.Text = styleEmoji
                        -- FR (sem estilo) menor; emoji maior
                        lbl.TextSize = (breathStyle == "None") and 10 or 14
                    end
                    -- Ativo (form) = fundo na cor do estilo; idle = tom suave do estilo
                    if isForm and breathStyle ~= "None" then
                        formBox.BackgroundColor3 = styleCol
                        if lbl then lbl.TextColor3 = Color3.fromRGB(20, 20, 22) end
                        local st = formBox:FindFirstChild("Stroke")
                        if st then st.Color = styleCol; st.Transparency = 0.05 end
                    elseif breathStyle ~= "None" then
                        formBox.BackgroundColor3 = Color3.fromRGB(
                            math.floor(styleCol.R * 255 * 0.22 + 18),
                            math.floor(styleCol.G * 255 * 0.22 + 18),
                            math.floor(styleCol.B * 255 * 0.22 + 20)
                        )
                        if lbl then lbl.TextColor3 = styleCol end
                        local st = formBox:FindFirstChild("Stroke")
                        if st then st.Color = styleCol; st.Transparency = 0.45 end
                    else
                        formBox.BackgroundColor3 = Color3.fromRGB(28, 32, 40)
                        if lbl then lbl.TextColor3 = Color3.fromRGB(100, 105, 115) end
                        local st = formBox:FindFirstChild("Stroke")
                        if st then st.Color = Color3.fromRGB(45, 50, 60); st.Transparency = 0.35 end
                    end
                end
            elseif indBar and knockedState[userId] then
                for _, box in ipairs(indBar:GetChildren()) do
                    if box:IsA("Frame") then
                        box.BackgroundColor3 = Color3.fromRGB(28, 32, 40)
                        local lbl = box:FindFirstChild("Label")
                        if lbl then
                            if box.Name == "FormBox" then
                                lbl.Text = "💀"
                                lbl.TextColor3 = Color3.fromRGB(160, 70, 70)
                            else
                                lbl.TextColor3 = Color3.fromRGB(100, 105, 115)
                            end
                        end
                        local st = box:FindFirstChild("Stroke")
                        if st then st.Color = Color3.fromRGB(45, 50, 60); st.Transparency = 0.4 end
                    end
                end
            end
        end
    end

    for userId, card in pairs(activeCards) do
        if not allSelected[userId] then
            if cardViewportConnections[userId] then cardViewportConnections[userId]:Disconnect() cardViewportConnections[userId] = nil end
            destroyXRay(userId)
            cardSetupFns[userId] = nil; card:Destroy(); activeCards[userId] = nil; lastHpCache[userId] = nil; knockedState[userId] = nil
        end
    end
end)

-- ================================================
-- PAINEL DE ESPECTADOR & RESTANTE DO CÓDIGO
-- ================================================
local spectatingTarget, isSpectating, shiftLockMode = nil, false, false
local cameraDistance, cameraAngleX, cameraAngleY = 12, 0, 15
local lastMousePos, isMouseDown, isSpecMinimized = nil, false, false

local SpecFrame = Instance.new("Frame", ScreenGui)
SpecFrame.Size = UDim2.new(0, 320, 0, 320); SpecFrame.Position = UDim2.new(0.5, 220, 0.15, 0)
SpecFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 26); SpecFrame.Visible = false; SpecFrame.Active = true
Instance.new("UICorner", SpecFrame).CornerRadius = UDim.new(0, 10)

local SpecTitleBar = Instance.new("Frame", SpecFrame)
SpecTitleBar.Size = UDim2.new(1, 0, 0, 35); SpecTitleBar.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
Instance.new("UICorner", SpecTitleBar).CornerRadius = UDim.new(0, 10)

local SpecTitleText = Instance.new("TextLabel", SpecTitleBar)
SpecTitleText.Size = UDim2.new(1, -70, 1, 0); SpecTitleText.Position = UDim2.new(0, 12, 0, 0)
SpecTitleText.Text = "CÂMERA & VISUAL"; SpecTitleText.TextColor3 = Color3.fromRGB(240, 240, 245)
SpecTitleText.TextSize = 11; SpecTitleText.Font = Enum.Font.GothamBold; SpecTitleText.BackgroundTransparency = 1; SpecTitleText.TextXAlignment = Enum.TextXAlignment.Left

local SpecMinimizeBtn = Instance.new("TextButton", SpecTitleBar)
SpecMinimizeBtn.Size = UDim2.new(0, 24, 0, 24); SpecMinimizeBtn.Position = UDim2.new(1, -56, 0.5, -12)
SpecMinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 220); SpecMinimizeBtn.Text = "─"; SpecMinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpecMinimizeBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", SpecMinimizeBtn).CornerRadius = UDim.new(1, 0)

local SpecCloseBtn = Instance.new("TextButton", SpecTitleBar)
SpecCloseBtn.Size = UDim2.new(0, 24, 0, 24); SpecCloseBtn.Position = UDim2.new(1, -28, 0.5, -12)
SpecCloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 65); Instance.new("UICorner", SpecCloseBtn).CornerRadius = UDim.new(1, 0); createDrawnX(SpecCloseBtn)

OpenSpecBtn.MouseButton1Click:Connect(function() SpecFrame.Visible = not SpecFrame.Visible end)
SpecCloseBtn.MouseButton1Click:Connect(function() SpecFrame.Visible = false end)

do
    local dragging, dragInput, dragStart, startPos
    SpecTitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging, dragStart, startPos = true, input.Position, SpecFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    SpecTitleBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            SpecFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local XRayBtn = Instance.new("TextButton", SpecFrame)
XRayBtn.Size = UDim2.new(1, -24, 0, 26); XRayBtn.Position = UDim2.new(0, 12, 0, 42)
XRayBtn.BackgroundColor3 = Color3.fromRGB(40, 45, 55); XRayBtn.Text = "✨ X-RAY (GLOW DE VIDA): OFF"; XRayBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
XRayBtn.Font = Enum.Font.GothamBold; XRayBtn.TextSize = 10; Instance.new("UICorner", XRayBtn).CornerRadius = UDim.new(0, 6)
XRayBtn.MouseButton1Click:Connect(function()
    xrayEnabled = not xrayEnabled
    if isSpecMinimized then
        XRayBtn.Text = "✨"
    else
        XRayBtn.Text = xrayEnabled and "✨ X-RAY: ON" or "✨ X-RAY: OFF"
    end
    XRayBtn.BackgroundColor3 = xrayEnabled and Color3.fromRGB(140, 60, 220) or Color3.fromRGB(40, 45, 55)
    if not xrayEnabled then
        destroyAllXRay()
    end
end)

local PrivacyBtn = Instance.new("TextButton", SpecFrame)
PrivacyBtn.Size = UDim2.new(1, -24, 0, 26); PrivacyBtn.Position = UDim2.new(0, 12, 0, 72)
PrivacyBtn.BackgroundColor3 = Color3.fromRGB(30, 180, 100); PrivacyBtn.Text = "⚠️ PRIVACIDADE ESC: ON"; PrivacyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PrivacyBtn.Font = Enum.Font.GothamBold; PrivacyBtn.TextSize = 10; Instance.new("UICorner", PrivacyBtn).CornerRadius = UDim.new(0, 6)
PrivacyBtn.MouseButton1Click:Connect(function()
    privacyModeEnabled = not privacyModeEnabled
    if isSpecMinimized then PrivacyBtn.Text = "⚠️" else PrivacyBtn.Text = privacyModeEnabled and "⚠️ PRIVACIDADE ESC: ON" or "⚠️ PRIVACIDADE ESC: OFF" end
    PrivacyBtn.BackgroundColor3 = privacyModeEnabled and Color3.fromRGB(30, 180, 100) or Color3.fromRGB(180, 50, 50)
    if not privacyModeEnabled then PrivacyBlackout.Visible = false end
end)

local QuickControlFrame = Instance.new("Frame", SpecFrame)
QuickControlFrame.Size = UDim2.new(1, -24, 0, 32); QuickControlFrame.Position = UDim2.new(0, 12, 0, 104); QuickControlFrame.BackgroundTransparency = 1

local ShiftLockBtn = Instance.new("TextButton", QuickControlFrame)
ShiftLockBtn.Size = UDim2.new(0, 130, 1, 0); ShiftLockBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
ShiftLockBtn.Text = "🔒 SHIFT LOCK: OFF"; ShiftLockBtn.TextColor3 = Color3.fromRGB(200, 200, 210); ShiftLockBtn.Font = Enum.Font.GothamBold; ShiftLockBtn.TextSize = 10; Instance.new("UICorner", ShiftLockBtn).CornerRadius = UDim.new(0, 6)
local function toggleShiftLock()
    shiftLockMode = not shiftLockMode
    if isSpecMinimized then ShiftLockBtn.Text = "🔒" else ShiftLockBtn.Text = shiftLockMode and "🔒 SHIFT LOCK: ON" or "🔒 SHIFT LOCK: OFF" end
    ShiftLockBtn.BackgroundColor3 = shiftLockMode and Color3.fromRGB(30, 180, 100) or Color3.fromRGB(35, 40, 50)
end
ShiftLockBtn.MouseButton1Click:Connect(toggleShiftLock)

local PrevBtn = Instance.new("TextButton", QuickControlFrame)
PrevBtn.Size = UDim2.new(0, 75, 1, 0); PrevBtn.Position = UDim2.new(1, -155, 0, 0); PrevBtn.BackgroundColor3 = Color3.fromRGB(40, 45, 55); PrevBtn.Text = "◀ ANTER"; PrevBtn.TextColor3 = Color3.fromRGB(255, 255, 255); PrevBtn.Font = Enum.Font.GothamBold; PrevBtn.TextSize = 10; Instance.new("UICorner", PrevBtn).CornerRadius = UDim.new(0, 6)

local NextBtn = Instance.new("TextButton", QuickControlFrame)
NextBtn.Size = UDim2.new(0, 75, 1, 0); NextBtn.Position = UDim2.new(1, -75, 0, 0); NextBtn.BackgroundColor3 = Color3.fromRGB(40, 45, 55); NextBtn.Text = "PRÓX ▶"; NextBtn.TextColor3 = Color3.fromRGB(255, 255, 255); NextBtn.Font = Enum.Font.GothamBold; NextBtn.TextSize = 10; Instance.new("UICorner", NextBtn).CornerRadius = UDim.new(0, 6)

local SpecList = Instance.new("ScrollingFrame", SpecFrame)
SpecList.Size = UDim2.new(1, -24, 1, -185); SpecList.Position = UDim2.new(0, 12, 0, 142); SpecList.BackgroundTransparency = 1; SpecList.ScrollBarThickness = 4
local SpecUIList = Instance.new("UIListLayout", SpecList)
SpecUIList.SortOrder = Enum.SortOrder.LayoutOrder; SpecUIList.Padding = UDim.new(0, 6)

local StopSpecBtn = Instance.new("TextButton", SpecFrame)
StopSpecBtn.Size = UDim2.new(1, -24, 0, 28); StopSpecBtn.Position = UDim2.new(0, 12, 1, -34); StopSpecBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 50); StopSpecBtn.Text = "SOLTAR CÂMERA"; StopSpecBtn.TextColor3 = Color3.fromRGB(255, 255, 255); StopSpecBtn.Font = Enum.Font.GothamBold; StopSpecBtn.TextSize = 10; Instance.new("UICorner", StopSpecBtn).CornerRadius = UDim.new(0, 6)

SpecMinimizeBtn.MouseButton1Click:Connect(function()
    isSpecMinimized = not isSpecMinimized
    if isSpecMinimized then
        SpecFrame.Size = UDim2.new(0, 200, 0, 70); SpecList.Visible = false; StopSpecBtn.Visible = false
        XRayBtn.Parent = QuickControlFrame; PrivacyBtn.Parent = QuickControlFrame
        QuickControlFrame.Position = UDim2.new(0, 8, 0, 38); QuickControlFrame.Size = UDim2.new(1, -16, 0, 28)
        local x = 0
        for _, btn in ipairs({XRayBtn, PrivacyBtn, ShiftLockBtn, PrevBtn, NextBtn}) do
            btn.Size = UDim2.new(0, 28, 0, 28); btn.Position = UDim2.new(0, x, 0, 0); btn.TextSize = 14; x = x + 34
        end
        XRayBtn.Text = "✨"; PrivacyBtn.Text = "⚠️"; ShiftLockBtn.Text = "🔒"; PrevBtn.Text = "◀"; NextBtn.Text = "▶"
    else
        SpecFrame.Size = UDim2.new(0, 320, 0, 320); SpecList.Visible = true; StopSpecBtn.Visible = true
        XRayBtn.Parent = SpecFrame; PrivacyBtn.Parent = SpecFrame
        XRayBtn.Size = UDim2.new(1, -24, 0, 26); XRayBtn.Position = UDim2.new(0, 12, 0, 42); XRayBtn.TextSize = 10; XRayBtn.Text = xrayEnabled and "✨ X-RAY: ON" or "✨ X-RAY: OFF"
        PrivacyBtn.Size = UDim2.new(1, -24, 0, 26); PrivacyBtn.Position = UDim2.new(0, 12, 0, 72); PrivacyBtn.TextSize = 10; PrivacyBtn.Text = privacyModeEnabled and "⚠️ PRIVACIDADE ESC: ON" or "⚠️ PRIVACIDADE ESC: OFF"
        QuickControlFrame.Position = UDim2.new(0, 12, 0, 104); QuickControlFrame.Size = UDim2.new(1, -24, 0, 32)
        ShiftLockBtn.Size = UDim2.new(0, 130, 1, 0); ShiftLockBtn.Position = UDim2.new(0, 0, 0, 0); ShiftLockBtn.TextSize = 10; ShiftLockBtn.Text = shiftLockMode and "🔒 SHIFT LOCK: ON" or "🔒 SHIFT LOCK: OFF"
        PrevBtn.Size = UDim2.new(0, 75, 1, 0); PrevBtn.Position = UDim2.new(1, -155, 0, 0); PrevBtn.Text = "◀ ANTER"; PrevBtn.TextSize = 10
        NextBtn.Size = UDim2.new(0, 75, 1, 0); NextBtn.Position = UDim2.new(1, -75, 0, 0); NextBtn.Text = "PRÓX ▶"; NextBtn.TextSize = 10
    end
end)

local function stopSpectating()
    isSpectating = false; spectatingTarget = nil; CurrentCamera.CameraType = Enum.CameraType.Custom
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid end
end
StopSpecBtn.MouseButton1Click:Connect(stopSpectating)

local function getActivePlayersList()
    local targetList = {}
    for _, p in pairs(selectedTeam1) do if p and p.Parent then table.insert(targetList, p) end end
    for _, p in pairs(selectedTeam2) do if p and p.Parent then table.insert(targetList, p) end end
    return targetList
end

local function spectatePlayer(player)
    if not player or not player.Character then return end
    spectatingTarget = player; isSpectating = true; CurrentCamera.CameraType = Enum.CameraType.Scriptable
end

local function cyclePlayer(dir)
    local list = getActivePlayersList()
    if #list == 0 then return end
    local currentIndex = 1
    for i, p in ipairs(list) do if p == spectatingTarget then currentIndex = i break end end
    local newIndex = currentIndex + dir
    if newIndex > #list then newIndex = 1 end
    if newIndex < 1 then newIndex = #list end
    spectatePlayer(list[newIndex])
end
PrevBtn.MouseButton1Click:Connect(function() cyclePlayer(-1) end)
NextBtn.MouseButton1Click:Connect(function() cyclePlayer(1) end)

local function updateSpecList()
    for _, child in ipairs(SpecList:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    local list = getActivePlayersList()
    local targetStillInList = false
    for _, p in ipairs(list) do
        if p == spectatingTarget then targetStillInList = true end
        local ItemFrame = Instance.new("Frame", SpecList)
        ItemFrame.Size = UDim2.new(1, -8, 0, 32); ItemFrame.BackgroundColor3 = Color3.fromRGB(25, 28, 36)
        Instance.new("UICorner", ItemFrame).CornerRadius = UDim.new(0, 6)

        local NameLbl = Instance.new("TextLabel", ItemFrame)
        NameLbl.Size = UDim2.new(0.65, 0, 1, 0); NameLbl.Position = UDim2.new(0, 10, 0, 0)
        NameLbl.Text = (selectedTeam1[p.UserId] and "[A] " or "[B] ") .. getFormattedName(p)
        NameLbl.TextColor3 = selectedTeam1[p.UserId] and Color3.fromRGB(100, 180, 255) or Color3.fromRGB(255, 100, 100)
        NameLbl.TextSize = 11; NameLbl.Font = Enum.Font.GothamMedium; NameLbl.TextXAlignment = Enum.TextXAlignment.Left; NameLbl.BackgroundTransparency = 1

        local SpecBtn = Instance.new("TextButton", ItemFrame)
        SpecBtn.Size = UDim2.new(0, 70, 0, 22); SpecBtn.Position = UDim2.new(1, -75, 0.5, -11)
        local isWatching = (spectatingTarget == p and isSpectating)
        SpecBtn.BackgroundColor3 = isWatching and Color3.fromRGB(30, 180, 100) or Color3.fromRGB(40, 120, 220)
        SpecBtn.Text = isWatching and "ASSISTINDO" or "ASSISTIR"; SpecBtn.TextColor3 = Color3.fromRGB(255, 255, 255); SpecBtn.TextSize = 9; SpecBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", SpecBtn).CornerRadius = UDim.new(0, 4)

        SpecBtn.MouseButton1Click:Connect(function()
            if spectatingTarget == p and isSpectating then stopSpectating() else spectatePlayer(p) end
            updateSpecList()
        end)
    end
    if isSpectating and spectatingTarget and not targetStillInList then stopSpectating() end
    SpecList.CanvasSize = UDim2.new(0, 0, 0, SpecUIList.AbsoluteContentSize.Y)
end
task.spawn(function() while task.wait(1) do if SpecFrame.Visible then updateSpecList() end end end)

local privacyPanicOverride = false
local function isRobloxSettingsOpen() local ok, open = pcall(function() return GuiService.MenuIsOpen == true end); return ok and open == true end
local function updatePrivacyBlackout()
    if privacyPanicOverride then PrivacyBlackout.Visible = false return end
    PrivacyBlackout.Visible = (privacyModeEnabled and isRobloxSettingsOpen())
end

UserInputService.InputBegan:Connect(function(input, _gpe) if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then privacyPanicOverride = true; PrivacyBlackout.Visible = false end end)
UserInputService.InputEnded:Connect(function(input) if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then privacyPanicOverride = false; updatePrivacyBlackout() end end)
_G.CS2EscMenuConnection = RunService.Heartbeat:Connect(function() updatePrivacyBlackout() end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then isMouseDown = true; lastMousePos = UserInputService:GetMouseLocation() elseif input.KeyCode == Enum.KeyCode.LeftShift then toggleShiftLock() end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton2 then isMouseDown = false end end)
UserInputService.InputChanged:Connect(function(input)
    if isMouseDown and input.UserInputType == Enum.UserInputType.MouseMovement then
        local currentPos = UserInputService:GetMouseLocation()
        cameraAngleX = cameraAngleX - (currentPos - lastMousePos).X * 0.4; cameraAngleY = math.clamp(cameraAngleY + (currentPos - lastMousePos).Y * 0.4, -75, 75)
        lastMousePos = currentPos
    elseif input.UserInputType == Enum.UserInputType.MouseWheel then cameraDistance = math.clamp(cameraDistance - input.Position.Z * 2, 4, 40) end
end)

_G.CS2SpectatorConnection = RunService.RenderStepped:Connect(function()
    if not isSpectating or not spectatingTarget or not spectatingTarget.Character then return end
    local char = spectatingTarget.Character
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
    if not hrp then return end
    local targetPos = hrp.Position + Vector3.new(0, 2, 0)
    if shiftLockMode then
        CurrentCamera.CFrame = CFrame.new(targetPos - (hrp.CFrame.LookVector * cameraDistance) + Vector3.new(0, 2, 0), targetPos)
    else
        local radX, radY = math.rad(cameraAngleX), math.rad(cameraAngleY)
        CurrentCamera.CFrame = CFrame.new(targetPos + Vector3.new(cameraDistance * math.cos(radY) * math.sin(radX), cameraDistance * math.sin(radY), cameraDistance * math.cos(radY) * math.cos(radX)), targetPos)
    end
end)
