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
    for _, obj in pairs(State.MarcadoresVisuais) do if obj then obj:Destroy() end end
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

-- MÁGICA: Pega o offset matemático perfeito da ilha atual
function Scanner:AlinharParaGrid(posicao)
    local offsetGrid = Vector3.new(0, 0, 0)
    local minhaIlha = nil
    for _, island in pairs(Workspace:WaitForChild("Islands"):GetChildren()) do
        if island:FindFirstChild("Blocks") then minhaIlha = island; break end
    end
    
    if minhaIlha then
        local umBloco = minhaIlha.Blocks:FindFirstChildWhichIsA("Model") or minhaIlha.Blocks:FindFirstChildWhichIsA("BasePart")
        if umBloco then
            local bp = umBloco:IsA("Model") and umBloco:GetPivot().Position or umBloco.Position
            offsetGrid = Vector3.new(bp.X % Config.BLOCK_SIZE, bp.Y % Config.BLOCK_SIZE, bp.Z % Config.BLOCK_SIZE)
        end
    end
    
    local nx = math.floor((posicao.X - offsetGrid.X) / Config.BLOCK_SIZE + 0.5) * Config.BLOCK_SIZE + offsetGrid.X
    local ny = math.floor((posicao.Y - offsetGrid.Y) / Config.BLOCK_SIZE + 0.5) * Config.BLOCK_SIZE + offsetGrid.Y
    local nz = math.floor((posicao.Z - offsetGrid.Z) / Config.BLOCK_SIZE + 0.5) * Config.BLOCK_SIZE + offsetGrid.Z
    
    return Vector3.new(nx, ny, nz)
end

function Scanner:MoverSeletor(direcao)
    if not State.AncoraPart then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local look = char.HumanoidRootPart.CFrame.LookVector
    local frenteWorld, direitaWorld
    
    if math.abs(look.X) > math.abs(look.Z) then
        frenteWorld = Vector3.new(math.sign(look.X) * Config.BLOCK_SIZE, 0, 0)
        direitaWorld = Vector3.new(0, 0, math.sign(look.X) * Config.BLOCK_SIZE)
    else
        frenteWorld = Vector3.new(0, 0, math.sign(look.Z) * Config.BLOCK_SIZE)
        direitaWorld = Vector3.new(-math.sign(look.Z) * Config.BLOCK_SIZE, 0, 0)
    end
    
    local d = Vector3.new(0,0,0)
    if direcao == "Frente" then d = frenteWorld
    elseif direcao == "Tras" then d = -frenteWorld
    elseif direcao == "Esquerda" then d = -direitaWorld
    elseif direcao == "Direita" then d = direitaWorld
    elseif direcao == "Subir" then d = Vector3.new(0, Config.BLOCK_SIZE, 0)
    elseif direcao == "Descer" then d = Vector3.new(0, -Config.BLOCK_SIZE, 0)
    end
    
    -- Aplica o movimento e re-aloca na grid infalivel
    State.AncoraPart.Position = self:AlinharParaGrid(State.AncoraPart.Position + d)
    if State.CaixaVisual then State.CaixaVisual.Adornee = State.AncoraPart end
    self:EscanearArea()
end

function Scanner:EscanearArea()
    if not State.AncoraPart then return end
    self:LimparEnumeracao()
    
    local minhaIlha = nil
    for _, island in pairs(Workspace:WaitForChild("Islands"):GetChildren()) do
        if island:FindFirstChild("Blocks") then minhaIlha = island; break end
    end
    if not minhaIlha then return end

    local overlapParams = OverlapParams.new()
    overlapParams.FilterDescendantsInstances = {minhaIlha.Blocks}
    overlapParams.FilterType = Enum.RaycastFilterType.Include
    
    local partsInBox = workspace:GetPartBoundsInBox(State.AncoraPart.CFrame, State.AncoraPart.Size, overlapParams)
    
    local blocosUnicos = {}
    local blocosEncontrados = {}
    local Manager = Bot.Modules.Manager

    for _, part in ipairs(partsInBox) do
        local rootBlock = Manager:ObterBlocoRaiz(part)
        if rootBlock and not blocosUnicos[rootBlock] then
            blocosUnicos[rootBlock] = true
            local pos = rootBlock:IsA("Model") and rootBlock:GetPivot().Position or rootBlock.Position
            table.insert(blocosEncontrados, { Instancia = rootBlock, Posicao = pos, Nome = rootBlock.Name })
        end
    end

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

    local posExata = hrp.Position + dirVector
    local Manager = Bot.Modules.Manager
    
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local ray = workspace:Raycast(hrp.Position, Vector3.new(0, -20, 0), params)
    
    if ray and ray.Instance and Manager then
        local rootBlock = Manager:ObterBlocoRaiz(ray.Instance)
        if rootBlock then
            local hitPos = rootBlock:IsA("Model") and rootBlock:GetPivot().Position or rootBlock.Position
            posExata = hitPos + dirVector
        end
    end

    -- ALINHAMENTO INFALÍVEL
    posExata = self:AlinharParaGrid(posExata)

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
        State.AncoraPart.Position = self:AlinharParaGrid(State.AncoraPart.Position)
        self:EscanearArea() 
    end)
    self:EscanearArea()
end

return Scanner