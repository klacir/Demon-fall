-- GetPlaceInfo.lua
-- Script para uso legítimo no Roblox Studio: mostra PlaceId, JobId e informações básicas do place (via MarketplaceService).

local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

local function fetchProductInfo(placeId)
    local ok, info = pcall(function()
        return MarketplaceService:GetProductInfo(placeId, Enum.InfoType.Product)
    end)
    if ok then
        return info
    else
        return nil, info -- info contém a mensagem de erro
    end
end

local function displayInfo()
    local placeId = tostring(game.PlaceId)
    local jobId = tostring(game.JobId) -- id da instância de servidor
    print("PlaceId:", placeId)
    print("JobId:", jobId)
    print("IsStudio:", RunService:IsStudio())

    local info, err = fetchProductInfo(game.PlaceId)
    if info then
        print("Product Name:", info.Name)
        if info.Creator and info.Creator.Id then
            print("Creator Id:", info.Creator.Id)
        end
        print("Price:", info.Price or "N/A")
        print("IsForSale:", info.IsForSale and "yes" or "no")
    else
        warn("Não foi possível obter ProductInfo:", err)
    end
end

-- Se quiser também mostrar na tela (GUI), este trecho cria uma ScreenGui temporária com os dados:
local function createGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PlaceInfoGui"
    screenGui.ResetOnSpawn = false

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 380, 0, 140)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.BackgroundTransparency = 0.3
    label.BackgroundColor3 = Color3.fromRGB(20,20,20)
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.TextScaled = false
    label.TextWrapped = true
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.Padding = UDim.new(0, 8)
    label.Parent = screenGui

    local placeId = tostring(game.PlaceId)
    local jobId = tostring(game.JobId)
    local isStudio = tostring(RunService:IsStudio())

    local info, _ = fetchProductInfo(game.PlaceId)
    local productName = info and info.Name or "N/A"

    label.Text = string.format(
        "PlaceId: %s\nJobId: %s\nIsStudio: %s\nProduct Name: %s",
        placeId, jobId, isStudio, productName
    )

    screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

-- Execução:
displayInfo()
-- Apenas em contextos de cliente (LocalScript) chame createGui() para mostrar na tela:
if RunService:IsStudio() or game:GetService("RunService"):IsRunning() then
    -- se estiver rodando no cliente (LocalScript), crie a GUI
    local success, err = pcall(createGui)
    if not success then
        -- Em servidores ou situações onde PlayerGui não existe, ignore
        warn("Não foi possível criar GUI:", err)
    end
end