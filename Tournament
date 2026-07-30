-- ================================================
-- DEMON FALL - HUD CS2 + ESPECTADOR (EIXO Y INVERTIDO) + OCULTAR HUD ORIGINAL
-- ================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera

local ABSOLUTE_MAX_HP = 280
local RECOVERY_THRESHOLD_PCT = 0.15

-- Prevenir duplicação
if CoreGui:FindFirstChild("CS2TournamentSystem") then
    CoreGui.CS2TournamentSystem:Destroy()
end
if _G.CS2OverlayConnection then
    _G.CS2OverlayConnection:Disconnect()
    _G.CS2OverlayConnection = nil
end
if _G.CS2SpectatorConnection then
    _G.CS2SpectatorConnection:Disconnect()
    _G.CS2SpectatorConnection = nil
end

-- ================================================
-- VARIÁVEIS COMPARTILHADAS
-- ================================================
local selectedTeam1 = {} -- Time A (Azul)
local selectedTeam2 = {} -- Time B (Vermelho)

local maxHpCache = {}
local lastHpCache = {}
local knockedState = {} 
local avatarCache = {}

-- ================================================
-- SCREEN GUI PRINCIPAL
-- ================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CS2TournamentSystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = (gethui and gethui()) or CoreGui

-- ================================================
-- BOTÕES SUPERIORES FLUTUANTES (MENUS)
-- ================================================
-- Botão de HUD (Times)
local OpenMenuBtn = Instance.new("TextButton")
OpenMenuBtn.Size = UDim2.new(0, 110, 0, 30)
OpenMenuBtn.Position = UDim2.new(0, 15, 0, 15)
OpenMenuBtn.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
OpenMenuBtn.Text = "⚙ PLAYERS HUD"
OpenMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenMenuBtn.Font = Enum.Font.GothamBold
OpenMenuBtn.TextSize = 11
OpenMenuBtn.Parent = ScreenGui
Instance.new("UICorner", OpenMenuBtn).CornerRadius = UDim.new(0, 6)

-- Botão de Espectador
local OpenSpecBtn = Instance.new("TextButton")
OpenSpecBtn.Size = UDim2.new(0, 110, 0, 30)
OpenSpecBtn.Position = UDim2.new(0, 135, 0, 15)
OpenSpecBtn.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
OpenSpecBtn.Text = "🎥 ESPECTAR"
OpenSpecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenSpecBtn.Font = Enum.Font.GothamBold
OpenSpecBtn.TextSize = 11
OpenSpecBtn.Parent = ScreenGui
Instance.new("UICorner", OpenSpecBtn).CornerRadius = UDim.new(0, 6)

-- NOVO: Botão para Ocultar/Mostrar HUD original do Jogo (Demon Fall)
local isGameHudVisible = true
local ToggleHudBtn = Instance.new("TextButton")
ToggleHudBtn.Size = UDim2.new(0, 160, 0, 30)
ToggleHudBtn.Position = UDim2.new(0, 255, 0, 15)
ToggleHudBtn.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
ToggleHudBtn.Text = "👁️ OCULTAR HUD DO JOGO"
ToggleHudBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleHudBtn.Font = Enum.Font.GothamBold
ToggleHudBtn.TextSize = 11
ToggleHudBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleHudBtn).CornerRadius = UDim.new(0, 6)

ToggleHudBtn.MouseButton1Click:Connect(function()
    isGameHudVisible = not isGameHudVisible
    
    if isGameHudVisible then
        ToggleHudBtn.Text = "👁️ OCULTAR HUD DO JOGO"
        ToggleHudBtn.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    else
        ToggleHudBtn.Text = "👁️ MOSTRAR HUD DO JOGO"
        ToggleHudBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 50)
    end

    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetChildren()) do
            -- Ignora a nossa própria interface, mas oculta todo o resto
            if gui:IsA("ScreenGui") and gui.Name ~= "CS2TournamentSystem" then
                gui.Enabled = isGameHudVisible
            end
        end
    end
end)

-- ================================================
-- PARTE 1: PAINEL DE CONTROLE (SELEÇÃO DE TIMES)
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
local ControlStroke = Instance.new("UIStroke")
ControlStroke.Color = Color3.fromRGB(45, 50, 65)
ControlStroke.Thickness = 1.5
ControlStroke.Parent = ControlFrame

local ControlTitleBar = Instance.new("Frame")
ControlTitleBar.Size = UDim2.new(1, 0, 0, 35)
ControlTitleBar.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
ControlTitleBar.Parent = ControlFrame
Instance.new("UICorner", ControlTitleBar).CornerRadius = UDim.new(0, 10)

local ControlTitleText = Instance.new("TextLabel")
ControlTitleText.Size = UDim2.new(1, -40, 1, 0)
ControlTitleText.Position = UDim2.new(0, 12, 0, 0)
ControlTitleText.Text = "CONFIGURAÇÃO DE TRANSMISSÃO (CS2 BROADCAST)"
ControlTitleText.TextColor3 = Color3.fromRGB(240, 240, 245)
ControlTitleText.TextSize = 12
ControlTitleText.Font = Enum.Font.GothamBold
ControlTitleText.TextXAlignment = Enum.TextXAlignment.Left
ControlTitleText.BackgroundTransparency = 1
ControlTitleText.Parent = ControlTitleBar

local ControlCloseBtn = Instance.new("TextButton")
ControlCloseBtn.Size = UDim2.new(0, 24, 0, 24)
ControlCloseBtn.Position = UDim2.new(1, -28, 0.5, -12)
ControlCloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 65)
ControlCloseBtn.Text = "✕"
ControlCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ControlCloseBtn.Font = Enum.Font.GothamBold
ControlCloseBtn.Parent = ControlTitleBar
Instance.new("UICorner", ControlCloseBtn).CornerRadius = UDim.new(0, 6)

OpenMenuBtn.MouseButton1Click:Connect(function() ControlFrame.Visible = not ControlFrame.Visible end)
ControlCloseBtn.MouseButton1Click:Connect(function() ControlFrame.Visible = false end)

-- Drag ControlFrame
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
        NameLbl.Text = p.DisplayName .. " (@" .. p.Name .. ")"
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
                selectedTeam1[p.UserId] = p
                selectedTeam2[p.UserId] = nil
            end
            refreshPlayerList()
        end)

        T2Btn.MouseButton1Click:Connect(function()
            if selectedTeam2[p.UserId] then selectedTeam2[p.UserId] = nil else
                selectedTeam2[p.UserId] = p
                selectedTeam1[p.UserId] = nil
            end
            refreshPlayerList()
        end)
    end
    ScrollList.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y)
end

Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(function(p)
    selectedTeam1[p.UserId] = nil
    selectedTeam2[p.UserId] = nil
    maxHpCache[p.UserId] = nil
    lastHpCache[p.UserId] = nil
    knockedState[p.UserId] = nil
    avatarCache[p.UserId] = nil
    refreshPlayerList()
end)
refreshPlayerList()

-- ================================================
-- CONTAINERS E LÓGICA DE VIDA DO HUD
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
    if not char then return 0, 100 end

    local hp = nil
    local hpVal = char:FindFirstChild("Health") or char:FindFirstChild("HP") or char:FindFirstChild("CurrentHealth")
    if hpVal and hpVal:IsA("ValueBase") then hp = tonumber(hpVal.Value) end

    if not hp then
        local folders = {"Status", "Data", "Stats", "leaderstats"}
        for _, fName in ipairs(folders) do
            local folder = player:FindFirstChild(fName) or char:FindFirstChild(fName)
            if folder then
                local pHP = folder:FindFirstChild("Health") or folder:FindFirstChild("HP")
                if pHP and pHP:IsA("ValueBase") then hp = tonumber(pHP.Value) break end
            end
        end
    end

    if not hp and char:GetAttribute("Health") then hp = tonumber(char:GetAttribute("Health")) end
    hp = hp or 0
    
    if not maxHpCache[player.UserId] or hp > maxHpCache[player.UserId] then maxHpCache[player.UserId] = hp end
    local maxHp = math.clamp(maxHpCache[player.UserId] or 100, hp, ABSOLUTE_MAX_HP)
    return math.floor(hp), math.floor(maxHp)
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

local activeCards = {}
local function createPlayerCard(player, teamColor)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(0, 120, 0, 95)
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

    local AvatarImg = Instance.new("ImageLabel", Card)
    AvatarImg.Name = "AvatarImage"
    AvatarImg.Size = UDim2.new(0, 90, 0, 90)
    AvatarImg.Position = UDim2.new(0.5, -45, 0, -88)
    AvatarImg.BackgroundTransparency = 1
    AvatarImg.ZIndex = 8

    task.spawn(function()
        if avatarCache[player.UserId] then AvatarImg.Image = avatarCache[player.UserId] else
            local content, isReady = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
            if isReady then avatarCache[player.UserId] = content; AvatarImg.Image = content end
        end
    end)

    local NameLbl = Instance.new("TextLabel", Card)
    NameLbl.Size = UDim2.new(1, -8, 0, 22)
    NameLbl.Position = UDim2.new(0, 4, 1, -24)
    NameLbl.Text = player.DisplayName:upper()
    NameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLbl.TextSize = 12
    NameLbl.Font = Enum.Font.GothamBold
    NameLbl.BackgroundTransparency = 1
    NameLbl.ZIndex = 6

    local HealthLbl = Instance.new("TextLabel", Card)
    HealthLbl.Name = "HealthText"
    HealthLbl.Size = UDim2.new(1, 0, 0, 38)
    HealthLbl.Position = UDim2.new(0, 0, 0.2, 0)
    HealthLbl.Text = "100"
    HealthLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    HealthLbl.TextSize = 28
    HealthLbl.Font = Enum.Font.GothamBold
    HealthLbl.BackgroundTransparency = 1
    HealthLbl.ZIndex = 6

    return Card
end

_G.CS2OverlayConnection = RunService.RenderStepped:Connect(function()
    local allSelected = {}
    for userId, player in pairs(selectedTeam1) do allSelected[userId] = {player = player, color = Color3.fromRGB(30, 120, 240), container = Team1Container} end
    for userId, player in pairs(selectedTeam2) do allSelected[userId] = {player = player, color = Color3.fromRGB(240, 50, 80), container = Team2Container} end

    for userId, data in pairs(allSelected) do
        local player = data.player
        if player and player.Parent then
            if not activeCards[userId] then
                local card = createPlayerCard(player, data.color)
                card.Parent = data.container
                activeCards[userId] = card
            end

            local card = activeCards[userId]
            local hp, maxHp = getHealth(player)

            if lastHpCache[userId] and hp < lastHpCache[userId] then
                popDamageText(card, lastHpCache[userId] - hp)
            end
            lastHpCache[userId] = hp

            if hp <= 0 then knockedState[userId] = true
            elseif knockedState[userId] and hp >= (maxHp * RECOVERY_THRESHOLD_PCT) then knockedState[userId] = false end

            local pct = math.clamp(hp / maxHp, 0, 1)
            card.HealthFill:TweenSizeAndPosition(UDim2.new(1, 0, pct, 0), UDim2.new(0, 0, 1 - pct, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)

            local avatarImg = card:FindFirstChild("AvatarImage")
            if knockedState[userId] then
                card.HealthText.Text = "DEAD"
                card.HealthText.TextColor3 = Color3.fromRGB(220, 50, 50)
                if avatarImg then avatarImg.ImageTransparency = 0.65 end
            else
                card.HealthText.Text = tostring(hp)
                card.HealthText.TextColor3 = Color3.fromRGB(255, 255, 255)
                if avatarImg then avatarImg.ImageTransparency = 0 end
            end
        end
    end

    for userId, card in pairs(activeCards) do
        if not allSelected[userId] then
            card:Destroy(); activeCards[userId] = nil; lastHpCache[userId] = nil; knockedState[userId] = nil
        end
    end
end)

-- ================================================
-- PARTE 2: PAINEL DE ESPECTADOR (EIXO Y INVERTIDO)
-- ================================================
local spectatingTarget = nil
local isSpectating = false
local shiftLockMode = false
local cameraDistance = 12
local cameraAngleX = 0
local cameraAngleY = 15
local lastMousePos = nil
local isMouseDown = false

local SpecFrame = Instance.new("Frame")
SpecFrame.Name = "SpecFrame"
SpecFrame.Size = UDim2.new(0, 320, 0, 260)
SpecFrame.Position = UDim2.new(0.5, 220, 0.15, 0)
SpecFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
SpecFrame.Visible = false
SpecFrame.Active = true
SpecFrame.Parent = ScreenGui

Instance.new("UICorner", SpecFrame).CornerRadius = UDim.new(0, 10)
local SpecStroke = Instance.new("UIStroke")
SpecStroke.Color = Color3.fromRGB(45, 50, 65)
SpecStroke.Thickness = 1.5
SpecStroke.Parent = SpecFrame

local SpecTitleBar = Instance.new("Frame")
SpecTitleBar.Size = UDim2.new(1, 0, 0, 35)
SpecTitleBar.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
SpecTitleBar.Parent = SpecFrame
Instance.new("UICorner", SpecTitleBar).CornerRadius = UDim.new(0, 10)

local SpecTitleText = Instance.new("TextLabel", SpecTitleBar)
SpecTitleText.Size = UDim2.new(1, -40, 1, 0)
SpecTitleText.Position = UDim2.new(0, 12, 0, 0)
SpecTitleText.Text = "CÂMERA (APENAS TIMES)"
SpecTitleText.TextColor3 = Color3.fromRGB(240, 240, 245)
SpecTitleText.TextSize = 11
SpecTitleText.Font = Enum.Font.GothamBold
SpecTitleText.TextXAlignment = Enum.TextXAlignment.Left
SpecTitleText.BackgroundTransparency = 1

local SpecCloseBtn = Instance.new("TextButton", SpecTitleBar)
SpecCloseBtn.Size = UDim2.new(0, 24, 0, 24)
SpecCloseBtn.Position = UDim2.new(1, -28, 0.5, -12)
SpecCloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 65)
SpecCloseBtn.Text = "✕"
SpecCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpecCloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", SpecCloseBtn).CornerRadius = UDim.new(0, 6)

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
    SpecTitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            SpecFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local QuickControlFrame = Instance.new("Frame", SpecFrame)
QuickControlFrame.Size = UDim2.new(1, -24, 0, 36)
QuickControlFrame.Position = UDim2.new(0, 12, 0, 42)
QuickControlFrame.BackgroundTransparency = 1

local ShiftLockBtn = Instance.new("TextButton", QuickControlFrame)
ShiftLockBtn.Size = UDim2.new(0, 130, 1, 0)
ShiftLockBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
ShiftLockBtn.Text = "🔒 SHIFT LOCK: OFF"
ShiftLockBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
ShiftLockBtn.Font = Enum.Font.GothamBold
ShiftLockBtn.TextSize = 10
Instance.new("UICorner", ShiftLockBtn).CornerRadius = UDim.new(0, 6)

local function toggleShiftLock()
    shiftLockMode = not shiftLockMode
    if shiftLockMode then
        ShiftLockBtn.Text = "🔒 SHIFT LOCK: ON"; ShiftLockBtn.BackgroundColor3 = Color3.fromRGB(30, 180, 100); ShiftLockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        ShiftLockBtn.Text = "🔒 SHIFT LOCK: OFF"; ShiftLockBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 50); ShiftLockBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    end
end
ShiftLockBtn.MouseButton1Click:Connect(toggleShiftLock)

local PrevBtn = Instance.new("TextButton", QuickControlFrame)
PrevBtn.Size = UDim2.new(0, 75, 1, 0)
PrevBtn.Position = UDim2.new(1, -155, 0, 0)
PrevBtn.BackgroundColor3 = Color3.fromRGB(40, 45, 55)
PrevBtn.Text = "◀ ANTER"
PrevBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PrevBtn.Font = Enum.Font.GothamBold
PrevBtn.TextSize = 10
Instance.new("UICorner", PrevBtn).CornerRadius = UDim.new(0, 6)

local NextBtn = Instance.new("TextButton", QuickControlFrame)
NextBtn.Size = UDim2.new(0, 75, 1, 0)
NextBtn.Position = UDim2.new(1, -75, 0, 0)
NextBtn.BackgroundColor3 = Color3.fromRGB(40, 45, 55)
NextBtn.Text = "PRÓX ▶"
NextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
NextBtn.Font = Enum.Font.GothamBold
NextBtn.TextSize = 10
Instance.new("UICorner", NextBtn).CornerRadius = UDim.new(0, 6)

local SpecList = Instance.new("ScrollingFrame", SpecFrame)
SpecList.Size = UDim2.new(1, -24, 1, -125)
SpecList.Position = UDim2.new(0, 12, 0, 85)
SpecList.BackgroundTransparency = 1
SpecList.ScrollBarThickness = 4
local SpecUIList = Instance.new("UIListLayout", SpecList)
SpecUIList.SortOrder = Enum.SortOrder.LayoutOrder
SpecUIList.Padding = UDim.new(0, 6)

local StopSpecBtn = Instance.new("TextButton", SpecFrame)
StopSpecBtn.Size = UDim2.new(1, -24, 0, 28)
StopSpecBtn.Position = UDim2.new(0, 12, 1, -34)
StopSpecBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 50)
StopSpecBtn.Text = "SOLTAR CÂMERA (VOLTAR AO NORMAL)"
StopSpecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopSpecBtn.Font = Enum.Font.GothamBold
StopSpecBtn.TextSize = 10
Instance.new("UICorner", StopSpecBtn).CornerRadius = UDim.new(0, 6)

local function stopSpectating()
    isSpectating = false; spectatingTarget = nil; CurrentCamera.CameraType = Enum.CameraType.Custom
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
    end
end
StopSpecBtn.MouseButton1Click:Connect(stopSpectating)

-- REGRA CRÍTICA: APENAS JOGADORES EM TIMES (A OU B) PODEM SER ESPECTADOS
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
        ItemFrame.Size = UDim2.new(1, -8, 0, 32)
        ItemFrame.BackgroundColor3 = Color3.fromRGB(25, 28, 36)
        Instance.new("UICorner", ItemFrame).CornerRadius = UDim.new(0, 6)

        local NameLbl = Instance.new("TextLabel", ItemFrame)
        NameLbl.Size = UDim2.new(0.65, 0, 1, 0)
        NameLbl.Position = UDim2.new(0, 10, 0, 0)
        
        local teamTag = selectedTeam1[p.UserId] and "[A] " or "[B] "
        NameLbl.Text = teamTag .. p.DisplayName
        NameLbl.TextColor3 = selectedTeam1[p.UserId] and Color3.fromRGB(100, 180, 255) or Color3.fromRGB(255, 100, 100)
        NameLbl.TextSize = 11
        NameLbl.Font = Enum.Font.GothamMedium
        NameLbl.TextXAlignment = Enum.TextXAlignment.Left
        NameLbl.BackgroundTransparency = 1

        local SpecBtn = Instance.new("TextButton", ItemFrame)
        SpecBtn.Size = UDim2.new(0, 70, 0, 22)
        SpecBtn.Position = UDim2.new(1, -75, 0.5, -11)
        SpecBtn.BackgroundColor3 = (spectatingTarget == p) and Color3.fromRGB(30, 180, 100) or Color3.fromRGB(40, 120, 220)
        SpecBtn.Text = (spectatingTarget == p) and "ASSISTINDO" or "ASSISTIR"
        SpecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        SpecBtn.TextSize = 9
        SpecBtn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", SpecBtn).CornerRadius = UDim.new(0, 4)

        SpecBtn.MouseButton1Click:Connect(function()
            spectatePlayer(p)
            updateSpecList()
        end)
    end
    
    if isSpectating and spectatingTarget and not targetStillInList then
        stopSpectating()
    end
    
    SpecList.CanvasSize = UDim2.new(0, 0, 0, SpecUIList.AbsoluteContentSize.Y)
end

task.spawn(function()
    while task.wait(1) do
        if SpecFrame.Visible then updateSpecList() end
    end
end)

-- INPUTS EIXO Y INVERTIDO E CONTROLES
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isMouseDown = true; lastMousePos = UserInputService:GetMouseLocation()
    elseif input.KeyCode == Enum.KeyCode.LeftShift then
        toggleShiftLock()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then isMouseDown = false end
end)

UserInputService.InputChanged:Connect(function(input)
    if isMouseDown and input.UserInputType == Enum.UserInputType.MouseMovement then
        local currentPos = UserInputService:GetMouseLocation()
        local delta = currentPos - lastMousePos
        lastMousePos = currentPos

        cameraAngleX = cameraAngleX - delta.X * 0.4
        -- EIXO Y INVERTIDO (+delta.Y)
        cameraAngleY = math.clamp(cameraAngleY + delta.Y * 0.4, -75, 75)
    elseif input.UserInputType == Enum.UserInputType.MouseWheel then
        cameraDistance = math.clamp(cameraDistance - input.Position.Z * 2, 4, 40)
    end
end)

-- LOOP DA CÂMERA DO ESPECTADOR
_G.CS2SpectatorConnection = RunService.RenderStepped:Connect(function()
    if not isSpectating or not spectatingTarget or not spectatingTarget.Character then return end

    local char = spectatingTarget.Character
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
    if not hrp then return end

    local targetPos = hrp.Position + Vector3.new(0, 2, 0)

    if shiftLockMode then
        local lookVector = hrp.CFrame.LookVector
        local camPos = targetPos - (lookVector * cameraDistance) + Vector3.new(0, 2, 0)
        CurrentCamera.CFrame = CFrame.new(camPos, targetPos)
    else
        local radX, radY = math.rad(cameraAngleX), math.rad(cameraAngleY)
        local xOffset = cameraDistance * math.cos(radY) * math.sin(radX)
        local yOffset = cameraDistance * math.sin(radY)
        local zOffset = cameraDistance * math.cos(radY) * math.cos(radX)
        CurrentCamera.CFrame = CFrame.new(targetPos + Vector3.new(xOffset, yOffset, zOffset), targetPos)
    end
end)
