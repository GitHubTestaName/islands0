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
    
    State.AncoraPart.Position = State.AncoraPart.Position + d
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

    -- NOVA FÍSICA: Pega TUDO o que a caixa azul estiver tocando (Mesmo galhos de árvore)
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
    posExata = Vector3.new(
        math.round(posExata.X / Config.BLOCK_SIZE) * Config.BLOCK_SIZE,
        math.round(posExata.Y / Config.BLOCK_SIZE) * Config.BLOCK_SIZE,
        math.round(posExata.Z / Config.BLOCK_SIZE) * Config.BLOCK_SIZE
    )

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

    self:EscanearArea()
end

return Scanner