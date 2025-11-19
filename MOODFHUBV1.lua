local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VIM = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
-- NOME
local Window = Library.CreateLib("MOONDF HUB V1", "DarkTheme")
-- Variáveis Principais
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")
-- Configurações de Voo e Speed
local flyToggle = false
local flySpeedValue = 150
local flyConn, bg, bv
local speedToggle = false
local walkSpeed = 16
local speedConn
local BASE_WALKSPEED = 16
-- Configurações Visuais
local coordsEnabled = false
local coordsGui, coordsLabel, coordsConn
local noFogEnabled = false
-- Configurações Ultra Lite
local ultraLiteEnabled = false
local liteLoop = nil
-- Configurações de Farm
local trinketFarm = false
local autoAttack = false
-- Lógica de Farm
local currentMob = nil
local isEnabled = false
local connection = nil
local loadingAllMobs = false
local teleportAndLookLooping = false
local selectedPlayerName = nil
-- ==========================================
-- COORDENADAS & LOCAIS
-- ==========================================
local raidCFrame = CFrame.new(7099.3, 1762.3, 1342.9)
local hayakawaCFrame = CFrame.new(-3571.8, 714.1, -994.5)
local okuyaCFrame = CFrame.new(893.3, 772.6, -2260.9)
local kamakuraCFrame = CFrame.new(-2343.6, 1166.6, -1678.2)
local slayerCFrame = CFrame.new(-5433.1, 761.0, -6392.9)
local distritoCFrame = CFrame.new(-1986.7, 871.8, -6484.5)
local slayerExamCFrame = CFrame.new(-5123, 815, -3037)
local mistBreathCFrame = CFrame.new(3237, 778.8, -4051.3)
local serpentBreathCFrame = CFrame.new(991.8, 1071.3, -1144.8)
local loveBreathCFrame = CFrame.new(1192.8, 1079.3, -1107.6)
local flameBreathCFrame = CFrame.new(1493, 1245, -354)
local moonBreathCFrame = CFrame.new(1820, 1121, -5958)
local windBreathCFrame = CFrame.new(-3294, 708, -1267)
local thunderBreathCFrame = CFrame.new(-750, 705, 552)
local insectBreathCFrame = CFrame.new(-1635, 913, -6493)
local soundBreathCFrame = CFrame.new(-1266, 877.9, -6432.9)
local flowerBreathCFrame = CFrame.new(-1320, 872.5, -6237)
local beastBreathCFrame = CFrame.new(-3112, 785, -6596)
local waterBreathCFrame = CFrame.new(-925, 851.5, -994.6)
local sunBreathCFrame = CFrame.new(393, 819.7, -421)
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
local MOBS = { "GenericSlayer", "GenericOni", "FrostyOni", "Green Demon", "Blue Demon", "Zenitsu", "Gyutaro", "Kaigaku" }
-- ==========================================
-- UTILS
-- ==========================================
local blockedStates = {
    Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.Freefall, Enum.HumanoidStateType.GettingUp,
    Enum.HumanoidStateType.Seated, Enum.HumanoidStateType.PlatformStanding, Enum.HumanoidStateType.Dead, Enum.HumanoidStateType.Physics,
}
local function isInBlockedState(h)
    if not h then return true end
    if h.PlatformStand == true then return true end
    for _, v in ipairs(blockedStates) do if h:GetState() == v then return true end end
    return false
end
-- Novas variáveis para as funções adicionais
local noclipToggle = false
local noclipConn
local antiBurnToggle = false
local antiBurnConn

local function onCharAdded(newChar)
    char = newChar
    root = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
    if flyToggle then
        task.wait(0.5)
        pcall(function() if bg then bg:Destroy() end if bv then bv:Destroy() end if flyConn then flyConn:Disconnect() end end)
        setupFly()
    end
    if coordsEnabled then createCoordsGui() startCoordsUpdate() end
    if speedToggle then
        if speedConn then speedConn:Disconnect() end
        speedConn = RunService.Heartbeat:Connect(function()
            if humanoid and humanoid.Health > 0 and not isInBlockedState(humanoid) then humanoid.WalkSpeed = walkSpeed end
        end)
    end
    if isEnabled and currentMob then task.wait(0.5) toggleTeleport(true, currentMob) end

    -- Reativa noclip se estava ativado
    if noclipToggle then
        toggleNoclip(true)
    end

    -- Reativa anti-burn se estava ativado
    if antiBurnToggle then
        toggleAntiBurn(true)
    end
end
player.CharacterAdded:Connect(onCharAdded)
-- ==========================================
-- SISTEMA DE FLY
-- ==========================================
local function calculateFlySpeed(sliderVal)
    if sliderVal <= 5000 then
        return (sliderVal / 5000) * 400
    else
        local excess = sliderVal - 5000
        return 400 + (excess * 2) 
    end
end
function setupFly()
    bg = Instance.new("BodyGyro", root)
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.P = 9e4
    bg.CFrame = root.CFrame
    bv = Instance.new("BodyVelocity", root)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.new(0,0,0)
    humanoid.PlatformStand = true
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
-- ==========================================
-- LITE MODE
-- ==========================================
local function toggleUltraLite(state)
    ultraLiteEnabled = state
    if state then
        settings().Rendering.QualityLevel = 1
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 1
        Lighting.ClockTime = 12
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") or v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("SunRaysEffect") then v.Enabled = false end
        end
        local Terrain = workspace.Terrain
        Terrain.WaterWaveSize = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 0
        local function uglyfy(v)
            if v:IsA("BasePart") and not v:IsA("Terrain") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
                v.CastShadow = false
                v.Color = Color3.fromRGB(100, 100, 100)
                if v:IsA("MeshPart") then v.TextureID = "" end
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Highlight") then
                v.Enabled = false
            elseif v:IsA("Explosion") then
                v.Visible = false
            elseif v:IsA("SurfaceAppearance") then
                v:Destroy()
            end
        end
        for _, v in pairs(workspace:GetDescendants()) do uglyfy(v) end
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
        Lighting.Brightness = 3
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") or v:IsA("Sky") or v:IsA("Atmosphere") then v.Enabled = true end
        end
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 0 end
        end
    end
end
-- ==========================================
-- VISUAL (COORDS & FOG)
-- ==========================================
function createCoordsGui()
    coordsGui = Instance.new("ScreenGui")
    coordsGui.Name = "GrokCoords"
    coordsGui.Parent = player:WaitForChild("PlayerGui")
    coordsGui.ResetOnSpawn = false
    local frame = Instance.new("Frame", coordsGui)
    frame.Size = UDim2.new(0, 220, 0, 70)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(255,255,255)
    coordsLabel = Instance.new("TextLabel", frame)
    coordsLabel.Size = UDim2.new(1, -10, 1, 0)
    coordsLabel.Position = UDim2.new(0, 5, 0, 0)
    coordsLabel.BackgroundTransparency = 1
    coordsLabel.TextColor3 = Color3.fromRGB(255,255,255)
    coordsLabel.TextScaled = true
    coordsLabel.Font = Enum.Font.SourceSansBold
    coordsLabel.Text = "Coords: carregando..."
end
function startCoordsUpdate()
    if coordsConn then coordsConn:Disconnect() end
    coordsConn = RunService.RenderStepped:Connect(function()
        if coordsEnabled and root and root.Parent then
            local pos = root.Position
            coordsLabel.Text = string.format("X: %.1f\nY: %.1f\nZ: %.1f", pos.X, pos.Y, pos.Z)
        end
    end)
end
local function applyNoFog(state)
    if state then
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        Lighting.GlobalShadows = false
        Lighting.Brightness = 2
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") then v.Density = 0 end
        end
    else
        Lighting.FogEnd = 500
        Lighting.GlobalShadows = true
    end
end
-- ==========================================
-- FARM & TP LOGIC
-- ==========================================
local function findEnemy(mobName)
    local targetPlayer = Players:FindFirstChild(mobName)
    if targetPlayer and targetPlayer.Character then return targetPlayer.Character end
    return workspace:FindFirstChild(mobName)
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
    task.wait(1)
    loadingAllMobs = false
end
local function loadAllMap()
    local allCFrames = {
        raidCFrame,
        hayakawaCFrame,
        okuyaCFrame,
        kamakuraCFrame,
        slayerCFrame,
        distritoCFrame,
        slayerExamCFrame,
        mistBreathCFrame,
        serpentBreathCFrame,
        loveBreathCFrame,
        flameBreathCFrame,
        moonBreathCFrame,
        windBreathCFrame,
        thunderBreathCFrame,
        insectBreathCFrame,
        soundBreathCFrame,
        flowerBreathCFrame,
        beastBreathCFrame,
        waterBreathCFrame,
        sunBreathCFrame
    }
    for _, coord in ipairs(LOAD_COORDINATES) do
        table.insert(allCFrames, CFrame.new(coord))
    end
    local initialPosition = root.CFrame
    for _, cf in ipairs(allCFrames) do
        root.CFrame = cf
        task.wait(0.5)
    end
    root.CFrame = initialPosition
end
local function teleportAndLook()
    local enemy = currentMob and findEnemy(currentMob)
    if enemy and root then
        local enemyRoot = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Torso")
        if enemyRoot then
            local targetPos = enemyRoot.Position + (enemyRoot.CFrame.LookVector * -3)
            root.CFrame = CFrame.new(targetPos, enemyRoot.Position)
        else
            local success, pivot = pcall(function() return enemy:GetPivot() end)
            if success and pivot then
                root.CFrame = pivot * CFrame.new(0, 5, 0)
                root.Velocity = Vector3.new(0,0,0)
            end
        end
    end
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
        if not connection then
            teleportAndLookLooping = true
            connection = RunService.RenderStepped:Connect(teleportAndLook)
            spawn(teleportAndLookWithKeys)
        end
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
local function forceTeleportToPlayer(targetName)
    local target = Players:FindFirstChild(targetName)
    if not target or not target.Character or not root then return end
    local targetChar = target.Character
    local targetCFrame = targetChar:GetPivot()
    if targetCFrame then
        root.CFrame = targetCFrame + Vector3.new(0, 3, 0)
        local startTime = tick()
        local stayLoop
        stayLoop = RunService.RenderStepped:Connect(function()
            if targetChar then
                 targetCFrame = targetChar:GetPivot()
                 root.CFrame = targetCFrame + Vector3.new(0, 3, 0)
                 root.Velocity = Vector3.new(0,0,0)
            end
            if (tick() - startTime > 3) or (targetChar:FindFirstChild("HumanoidRootPart")) then
                stayLoop:Disconnect()
            end
        end)
    end
end
-- ==========================================
-- FUNÇÕES ADICIONAIS: NO CLIP, ANTI-BURN
-- ==========================================
-- No Clip
local function toggleNoclip(state)
    noclipToggle = state
    if state then
        if noclipConn then noclipConn:Disconnect() end
        noclipConn = RunService.Stepped:Connect(function(time, step)
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() end
    end
end

-- Anti-Burn (Anti Sun para Demônios)
local function toggleAntiBurn(state)
    antiBurnToggle = state
    if state then
        if antiBurnConn then antiBurnConn:Disconnect() end
        antiBurnConn = RunService.Heartbeat:Connect(function()
            if char and char:FindFirstChild("Demon") then
                -- Desativar dano do sol
                local sunBurnScript = char.Demon:FindFirstChild("SunBurn") or char.Demon:FindFirstChild("SunDamage")
                if sunBurnScript and sunBurnScript:IsA("Script") then
                    sunBurnScript.Disabled = true
                end
                -- Ou curar dano
                if humanoid.Health < humanoid.MaxHealth then
                    humanoid.Health = humanoid.MaxHealth
                end
            end
        end)
    else
        if antiBurnConn then antiBurnConn:Disconnect() end
    end
end

-- Server Hop
local function serverHop()
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    local Servers = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local Server, Next = nil, nil
    local function ListServers(cursor)
        local Raw = game:HttpGet(Servers .. ((cursor and "&cursor=" .. cursor) or ""))
        return HttpService:JSONDecode(Raw)
    end
    repeat
        local ServersData = ListServers(Next)
        Server = ServersData.data[math.random(1, #ServersData.data)]
        Next = ServersData.nextPageCursor
    until Server
    if Server.playing < Server.maxPlayers and Server.id ~= game.JobId then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, Server.id, game.Players.LocalPlayer)
    end
end

-- ==========================================
-- UI
-- ==========================================
local geralTab = Window:NewTab("Geral")  -- Nome alterado de Movimento para Geral
local extraTab = Window:NewTab("Farm")
local playersTab = Window:NewTab("Players")
local tpTab = Window:NewTab("Teleportes")
-- FLY (na aba Geral)
local flySec = geralTab:NewSection("Fly Híbrido")
flySec:NewToggle("Ativar Fly", "WASD + Space↑ + C↓", function(state)
    flyToggle = state
    if state then setupFly() else
        humanoid.PlatformStand = false
        if flyConn then flyConn:Disconnect() end
        pcall(function() if bg then bg:Destroy() end if bv then bv:Destroy() end end)
    end
end)
flySec:NewSlider("Força do Fly", "0-5000 (Preciso) | 5k-10k (Turbo)", 10000, 150, function(v) flySpeedValue = v end)
local speedSec = geralTab:NewSection("Speed no Chão")
speedSec:NewToggle("Ativar Speed", "Aumenta velocidade", function(state)
    speedToggle = state
    if state then
        if speedConn then speedConn:Disconnect() end
        speedConn = RunService.Heartbeat:Connect(function()
            if humanoid and humanoid.Health > 0 and not isInBlockedState(humanoid) then humanoid.WalkSpeed = walkSpeed end
        end)
    else
        if speedConn then speedConn:Disconnect() end
        if humanoid then humanoid.WalkSpeed = BASE_WALKSPEED end
    end
end)
speedSec:NewSlider("Valor Speed", "Normal ~100", 1000, 100, function(v) walkSpeed = v end)
-- VISUAL (na aba Geral)
local visualSec = geralTab:NewSection("Visual")
visualSec:NewToggle("Mostrar Coords", "X Y Z na tela", function(state)
    coordsEnabled = state
    if state then createCoordsGui() startCoordsUpdate() else
        if coordsGui then coordsGui:Destroy() end
        if coordsConn then coordsConn:Disconnect() end
    end
end)
visualSec:NewToggle("No Fog (Lite Básico)", "Remove apenas neblina", function(state)
    noFogEnabled = state
    applyNoFog(state)
end)
visualSec:NewToggle("SUPER ULTRA LITE", "DEIXA TUDO FEIO E LISO (FPS)", function(state)
    toggleUltraLite(state)
end)
-- Novas funções na aba Geral
local cheatsSec = geralTab:NewSection("Cheats Adicionais")
cheatsSec:NewToggle("No Clip", "Atravesse paredes", function(state)
    toggleNoclip(state)
end)
cheatsSec:NewToggle("Anti-Burn (Demônios imunes ao sol)", "Sem dano do sol", function(state)
    toggleAntiBurn(state)
end)
cheatsSec:NewButton("Trocar Servidor (Server Hop)", "Pula para outro servidor sem sair", function()
    serverHop()
end)
-- PLAYERS
local playerSec = playersTab:NewSection("Interagir com Players")
local playerDropdown = nil
local function getPlayerList()
    local list = {}
    for _, v in pairs(Players:GetPlayers()) do if v ~= player then table.insert(list, v.Name) end end
    return list
end
playerDropdown = playerSec:NewDropdown("Selecionar Player", "Escolha o alvo", getPlayerList(), function(v) selectedPlayerName = v end)
playerSec:NewButton("Atualizar Lista", "Clica se entrar gente nova", function() if playerDropdown then playerDropdown:Refresh(getPlayerList()) end end)
playerSec:NewButton("Teleportar para Player", "Carrega o mapa e vai até ele", function() if selectedPlayerName then forceTeleportToPlayer(selectedPlayerName) end end)
playerSec:NewToggle("Farmar Player", "TP Costas + Seguir", function(state)
    if state and selectedPlayerName then toggleTeleport(true, selectedPlayerName) else toggleTeleport(false) end
end)
-- TELEPORTES
local tpMainSec = tpTab:NewSection("Utilitários")
tpMainSec:NewButton("Carregar Todo o Mapa", "Teleporta para todos os lugares conhecidos", function() loadAllMap() end)
tpMainSec:NewButton("TP Raid", "Teleporta para a área da Raid", function() if root then root.CFrame = raidCFrame end end)
local vilaSec = tpTab:NewSection("Vilas & Locais")
vilaSec:NewButton("Okuya Village", "TP", function() if root then root.CFrame = hayakawaCFrame end end)
vilaSec:NewButton("Hayakawa Village", "TP", function() if root then root.CFrame = okuyaCFrame end end)
vilaSec:NewButton("Kamakura Village", "TP", function() if root then root.CFrame = kamakuraCFrame end end)
vilaSec:NewButton("Distrito", "TP", function() if root then root.CFrame = slayerCFrame end end)
vilaSec:NewButton("Slayer Corps", "TP", function() if root then root.CFrame = distritoCFrame end end)
vilaSec:NewButton("Slayer Exam", "TP", function() if root then root.CFrame = slayerExamCFrame end end)
local breathSec = tpTab:NewSection("Respirações")
breathSec:NewButton("Mist Breath", "TP", function() if root then root.CFrame = mistBreathCFrame end end)
breathSec:NewButton("Water Breath", "TP", function() if root then root.CFrame = waterBreathCFrame end end)
breathSec:NewButton("Wind Breath", "TP", function() if root then root.CFrame = windBreathCFrame end end)
breathSec:NewButton("Thunder Breath", "TP", function() if root then root.CFrame = thunderBreathCFrame end end)
breathSec:NewButton("Insect Breath", "TP", function() if root then root.CFrame = insectBreathCFrame end end)
breathSec:NewButton("Flame Breath", "TP", function() if root then root.CFrame = flameBreathCFrame end end)
breathSec:NewButton("Sun Breath", "TP", function() if root then root.CFrame = sunBreathCFrame end end)
breathSec:NewButton("Moon Breath", "TP", function() if root then root.CFrame = moonBreathCFrame end end)
breathSec:NewButton("Beast Breath", "TP", function() if root then root.CFrame = beastBreathCFrame end end)
breathSec:NewButton("Sound Breath", "TP", function() if root then root.CFrame = soundBreathCFrame end end)
breathSec:NewButton("Flower Breath", "TP", function() if root then root.CFrame = flowerBreathCFrame end end)
breathSec:NewButton("Serpent Breath", "TP", function() if root then root.CFrame = serpentBreathCFrame end end)
breathSec:NewButton("Love Breath", "TP", function() if root then root.CFrame = loveBreathCFrame end end)
-- FARM
local farmSec = extraTab:NewSection("Mob Farms")
farmSec:NewButton("Carregar Todos Mobs", "Teleporta para spawn points", function() loadAllMobs() end)
local mobToggles = {}
for _, mob in ipairs(MOBS) do
    local tog = farmSec:NewToggle("Farm "..mob, "Auto teleport", function(state)
        if state then toggleTeleport(true, mob) else toggleTeleport(false) end
    end)
    mobToggles[mob] = tog
end
farmSec:NewLabel(" Trinkets ")
farmSec:NewToggle("Auto Farm Trinkets", "Teleporta e coleta", function(state)
    trinketFarm = state
    if state then
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
    end
end)
farmSec:NewLabel(" Raid System ")
farmSec:NewToggle("Farm Raid (Auto Enemy)", "Foca no inimigo 'Enemy'", function(state)
    if state then toggleTeleport(true, "Enemy") else toggleTeleport(false) end
end)
farmSec:NewLabel(" Combat ")
farmSec:NewToggle("Auto Attack M1", "Simula clique do mouse", function(state)
    autoAttack = state
    if state then spawn(autoAttackLoop) end
end)
