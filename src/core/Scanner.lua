-- src/core/Scanner.lua
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local Scanner = {}
local Bot = _G.IslandsBot
local State = Bot.State
local Config = Bot.Config

local LocalPlayer = Players.LocalPlayer

function Scanner:LimparEnumeracao()
    for _, obj in pairs(State.MarcadoresVisuais) do 
        if obj then obj:Destroy() end 
    end
    State.MarcadoresVisuais = {}
    State.ListaBlocos = {}
end

function Scanner:LimparAncora()
    if State.AncoraPart then State.AncoraPart:Destroy() end
    if State.Handles then State.Handles:Destroy() end
    State.AncoraPart = nil
    self:LimparEnumeracao()
end

function Scanner:CriarNumeroVisual(posicao, numero)
    local part = Instance.new("Part")
    part.Size = Vector3.new(0.5, 0.5, 0.5)
    part.Position = posicao + Vector3.new(0, 1.5, 0)
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.CanTouch = false
    part.Transparency = 1
    part.Parent = Workspace
    
    local bg = Instance.new("BillboardGui", part)
    bg.Size = UDim2.new(0, 25, 0, 25)
    bg.AlwaysOnTop = true
    
    local txt = Instance.new("TextLabel", bg)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 0.2
    txt.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
    txt.TextScaled = true
    txt.Font = Enum.Font.SourceSansBold
    txt.Text = tostring(numero)
    
    table.insert(State.MarcadoresVisuais, part)
    return part
end

function Scanner:EscanearArea()
    if not State.AncoraPart then return end
    self:LimparEnumeracao()
    
    local minhaIlha = nil
    for _, island in pairs(Workspace:WaitForChild("Islands"):GetChildren()) do
        if island:FindFirstChild("Blocks") then 
            minhaIlha = island 
            break 
        end
    end
    if not minhaIlha then return end

    local areaCenter = State.AncoraPart.Position
    local areaSize = State.AncoraPart.Size
    local minCoord = areaCenter - (areaSize / 2)
    local maxCoord = areaCenter + (areaSize / 2)

    local blocosEncontrados = {}

    for _, bloco in ipairs(minhaIlha.Blocks:GetChildren()) do
        if bloco:IsA("BasePart") or bloco:IsA("Model") then
            local pos = bloco:IsA("Model") and bloco:GetPivot().Position or bloco.Position
            
            if pos.X >= minCoord.X - 0.1 and pos.X <= maxCoord.X + 0.1 and
               pos.Y >= minCoord.Y - 0.1 and pos.Y <= maxCoord.Y + 0.1 and
               pos.Z >= minCoord.Z - 0.1 and pos.Z <= maxCoord.Z + 0.1 then
               
                table.insert(blocosEncontrados, { Instancia = bloco, Posicao = pos, Nome = bloco.Name })
            end
        end
    end

    -- Ordenação espacial de mineração
    table.sort(blocosEncontrados, function(a, b)
        if math.abs(a.Posicao.Y - b.Posicao.Y) > 0.5 then return a.Posicao.Y > b.Posicao.Y end
        if math.abs(a.Posicao.Z - b.Posicao.Z) > 0.5 then return a.Posicao.Z < b.Posicao.Z end
        return a.Posicao.X < b.Posicao.X
    end)

    for i, dadosBloco in ipairs(blocosEncontrados) do
        local visualPart = self:CriarNumeroVisual(dadosBloco.Posicao, i)
        dadosBloco.Marcador = visualPart 
        table.insert(State.ListaBlocos, dadosBloco)
    end
end

function Scanner:CriarSeletorFrontal()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = char.HumanoidRootPart
    local look = hrp.CFrame.LookVector
    
    local dirVector = Vector3.new(0, 0, 0)
    if math.abs(look.X) > math.abs(look.Z) then
        dirVector = Vector3.new(math.sign(look.X) * Config.BLOCK_SIZE, 0, 0)
    else
        dirVector = Vector3.new(0, 0, math.sign(look.Z) * Config.BLOCK_SIZE)
    end

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local ray = workspace:Raycast(hrp.Position, Vector3.new(0, -10, 0), params)
    
    local posExata = Vector3.new(0,0,0)
    local Manager = Bot.Modules.Manager
    
    if ray and ray.Instance and Manager then
        local rootBlock = Manager:ObterBlocoRaiz(ray.Instance)
        local hitPos = rootBlock:IsA("Model") and rootBlock:GetPivot().Position or rootBlock.Position
        posExata = hitPos + dirVector + Vector3.new(0, Config.BLOCK_SIZE, 0) 
    else
        posExata = hrp.Position + dirVector
        posExata = Vector3.new(
            math.round(posExata.X / Config.BLOCK_SIZE) * Config.BLOCK_SIZE,
            math.round(posExata.Y / Config.BLOCK_SIZE) * Config.BLOCK_SIZE,
            math.round(posExata.Z / Config.BLOCK_SIZE) * Config.BLOCK_SIZE
        )
    end

    self:LimparAncora()
    
    State.AncoraPart = Instance.new("Part")
    State.AncoraPart.Size = Vector3.new(Config.BLOCK_SIZE, Config.BLOCK_SIZE, Config.BLOCK_SIZE)
    State.AncoraPart.Position = posExata
    State.AncoraPart.Anchored = true
    State.AncoraPart.CanCollide = false
    State.AncoraPart.CanQuery = false 
    State.AncoraPart.CanTouch = false
    State.AncoraPart.Transparency = 0.7
    State.AncoraPart.Color = Color3.fromRGB(0, 150, 255)
    State.AncoraPart.Parent = Workspace

    State.CaixaVisual = Instance.new("SelectionBox")
    State.CaixaVisual.Color3 = Color3.fromRGB(0, 255, 255)
    State.CaixaVisual.LineThickness = 0.05
    State.CaixaVisual.Adornee = State.AncoraPart
    State.CaixaVisual.Parent = State.AncoraPart

    State.Handles = Instance.new("Handles")
    State.Handles.Color3 = Color3.fromRGB(255, 200, 50)
    State.Handles.Style = Enum.HandlesStyle.Resize
    State.Handles.Adornee = State.AncoraPart
    State.Handles.Parent = CoreGui

    local sizeInicial, cframeInicial
    State.Handles.MouseButton1Down:Connect(function()
        sizeInicial = State.AncoraPart.Size
        cframeInicial = State.AncoraPart.CFrame
    end)

    State.Handles.MouseDrag:Connect(function(face, distancia)
        local deltaSnap = math.floor(distancia / Config.BLOCK_SIZE + 0.5) * Config.BLOCK_SIZE
        if face == Enum.NormalId.Front or face == Enum.NormalId.Back then
            State.AncoraPart.Size = sizeInicial + Vector3.new(0, 0, deltaSnap)
            State.AncoraPart.CFrame = cframeInicial * CFrame.new(0, 0, deltaSnap / 2 * (face == Enum.NormalId.Front and -1 or 1))
        elseif face == Enum.NormalId.Top or face == Enum.NormalId.Bottom then
            State.AncoraPart.Size = sizeInicial + Vector3.new(0, deltaSnap, 0)
            State.AncoraPart.CFrame = cframeInicial * CFrame.new(0, deltaSnap / 2 * (face == Enum.NormalId.Top and 1 or -1), 0)
        elseif face == Enum.NormalId.Right or face == Enum.NormalId.Left then
            State.AncoraPart.Size = sizeInicial + Vector3.new(deltaSnap, 0, 0)
            State.AncoraPart.CFrame = cframeInicial * CFrame.new(deltaSnap / 2 * (face == Enum.NormalId.Right and 1 or -1), 0, 0)
        end
    end)

    State.Handles.MouseButton1Up:Connect(function() 
        self:EscanearArea() 
    end)
    self:EscanearArea()
end

return Scanner