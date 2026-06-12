-- src/ui/Window.lua
local UI = {}
local Bot = _G.IslandsBot
local State = Bot.State

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

if CoreGui:FindFirstChild("IslandsCustomUI") then CoreGui.IslandsCustomUI:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "IslandsCustomUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 600, 0, 480)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- ================= ARRASTAR APENAS PELO TOPBAR =================
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TopBar.BorderSizePixel = 0
TopBar.Active = true

local dragToggle, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1) then 
        dragToggle = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragToggle = false end end)
    end
end)

local WindowResizeHandle = Instance.new("TextButton", MainFrame)
WindowResizeHandle.Size = UDim2.new(0, 20, 0, 20)
WindowResizeHandle.Position = UDim2.new(1, -20, 1, -20)
WindowResizeHandle.BackgroundTransparency = 1
WindowResizeHandle.Text = "◢"
WindowResizeHandle.TextColor3 = Color3.fromRGB(150, 150, 150)
WindowResizeHandle.TextSize = 16
WindowResizeHandle.ZIndex = 100

local draggingWindow, winDragStartPos, winStartSize
WindowResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingWindow = true; winDragStartPos = input.Position; winStartSize = MainFrame.AbsoluteSize
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        if dragToggle then
            local delta = input.Position - dragStart
            TweenService:Create(MainFrame, TweenInfo.new(0.1), {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}):Play()
        end
        if draggingWindow then
            local delta = input.Position - winDragStartPos
            MainFrame.Size = UDim2.new(0, math.max(500, winStartSize.X + delta.X), 0, math.max(400, winStartSize.Y + delta.Y))
        end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingWindow = false end
end)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Islands Automation PRO"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16

local StatusLabel = Instance.new("TextLabel", TopBar)
StatusLabel.Size = UDim2.new(0.5, -15, 1, 0)
StatusLabel.Position = UDim2.new(0.5, 0, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Ocioso"
StatusLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
StatusLabel.TextXAlignment = Enum.TextXAlignment.Right
StatusLabel.Font = Enum.Font.SourceSansSemibold
StatusLabel.TextSize = 14
function UI:SetStatusText(texto) StatusLabel.Text = "Status: " .. tostring(texto) end

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 120, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Sidebar.BorderSizePixel = 0

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 10)

local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.Size = UDim2.new(1, -120, 1, -35)
ContentContainer.Position = UDim2.new(0, 120, 0, 35)
ContentContainer.BackgroundTransparency = 1

local Paginas, BotoesAba = {}, {}
local function CriarAba(nome, id)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BorderSizePixel = 0
    btn.Text = nome
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(0, 150, 255)
    stroke.Thickness = 1.5
    stroke.Transparency = 1
    
    local pg = Instance.new("ScrollingFrame", ContentContainer)
    pg.Size = UDim2.new(1, 0, 1, -5)
    pg.Position = UDim2.new(0, 0, 0, 5)
    pg.BackgroundTransparency = 1
    pg.BorderSizePixel = 0
    pg.ScrollBarThickness = 4
    pg.Visible = false
    
    -- O SEGREDO DO FLEX-WRAP (CSS):
    local layout = Instance.new("UIListLayout", pg)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Wraps = true -- Faz os cartões caírem de linha quando a tela encolhe!
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local padding = Instance.new("UIPadding", pg)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 5)
    padding.PaddingBottom = UDim.new(0, 25)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        pg.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 30)
    end)
    
    Paginas[id], BotoesAba[id] = pg, btn
    
    btn.MouseButton1Click:Connect(function()
        for k, v in pairs(Paginas) do v.Visible = (k == id) end
        for k, v in pairs(BotoesAba) do 
            local isAtivo = (k == id)
            v.TextColor3 = isAtivo and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
            v.BackgroundColor3 = isAtivo and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(30, 30, 30)
            v.UIStroke.Transparency = isAtivo and 0 or 1
        end
    end)
end

CriarAba("Geral (Azul)", "seletor")
CriarAba("Fazenda (Verde)", "fazenda")
CriarAba("Sistema", "sistema")

BotoesAba["fazenda"].TextColor3 = Color3.fromRGB(255, 255, 255)
BotoesAba["fazenda"].BackgroundColor3 = Color3.fromRGB(0, 100, 200)
BotoesAba["fazenda"].UIStroke.Transparency = 0
Paginas["fazenda"].Visible = true

-- ================= CONSTRUTOR DE CARDS (Os Blocos Visuais) =================
local layoutOrderGlobal = 0
local function GetOrdem() layoutOrderGlobal = layoutOrderGlobal + 1 return layoutOrderGlobal end

local function CriarCard(titulo, parent, widthScale, widthOffset)
    local card = Instance.new("Frame", parent)
    card.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    card.Size = UDim2.new(widthScale or 0, widthOffset or 220, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.LayoutOrder = GetOrdem()
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
    
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = Color3.fromRGB(50, 50, 50)
    stroke.Thickness = 1
    
    local titleLabel = Instance.new("TextLabel", card)
    titleLabel.Size = UDim2.new(1, 0, 0, 25)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "  " .. titulo
    titleLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local div = Instance.new("Frame", card)
    div.Size = UDim2.new(1, 0, 0, 1)
    div.Position = UDim2.new(0, 0, 0, 25)
    div.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    div.BorderSizePixel = 0

    local content = Instance.new("Frame", card)
    content.Size = UDim2.new(1, 0, 0, 0)
    content.Position = UDim2.new(0, 0, 0, 26)
    content.BackgroundTransparency = 1
    content.AutomaticSize = Enum.AutomaticSize.Y

    local cLayout = Instance.new("UIListLayout", content)
    cLayout.Padding = UDim.new(0, 6)
    cLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    cLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local pad = Instance.new("UIPadding", content)
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)

    return content
end

local function CriarBotaoEstilizado(texto, parent, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.92, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = texto
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.SourceSansSemibold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.LayoutOrder = GetOrdem()
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function CriarToggleEstilizado(texto, parent, stateTable, stateKey, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.92, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = GetOrdem()
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = " " .. texto
    label.TextColor3 = Color3.fromRGB(210, 210, 210)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 45, 0, 22)
    btn.Position = UDim2.new(1, -45, 0, 4)
    local isAtivo = stateTable[stateKey]
    btn.BackgroundColor3 = isAtivo and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(180, 50, 50)
    btn.Text = isAtivo and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function()
        stateTable[stateKey] = not stateTable[stateKey]
        local v = stateTable[stateKey]
        btn.Text = v and "ON" or "OFF"
        btn.BackgroundColor3 = v and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(180, 50, 50)
        if callback then callback(v) end
    end)
end

local function CriarLinhaCheckboxes(parent, listaConfigs)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.92, 0, 0, 24)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = GetOrdem()
    
    local layout = Instance.new("UIListLayout", frame)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 8)
    
    local wScale = (1 / #listaConfigs) - 0.05
    for _, config in ipairs(listaConfigs) do
        local container = Instance.new("Frame", frame)
        container.Size = UDim2.new(wScale, 0, 1, 0)
        container.BackgroundTransparency = 1
        
        local btn = Instance.new("TextButton", container)
        btn.Size = UDim2.new(0, 20, 0, 20)
        btn.Position = UDim2.new(0, 0, 0, 2)
        local isAtivo = config.table[config.key]
        btn.BackgroundColor3 = isAtivo and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 40)
        btn.Text = isAtivo and "✓" or ""
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        
        local label = Instance.new("TextLabel", container)
        label.Size = UDim2.new(1, -25, 1, 0)
        label.Position = UDim2.new(0, 25, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = config.texto
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.Font = Enum.Font.SourceSans
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        btn.MouseButton1Click:Connect(function()
            config.table[config.key] = not config.table[config.key]
            local v = config.table[config.key]
            btn.BackgroundColor3 = v and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 40)
            btn.Text = v and "✓" or ""
            if config.callback then config.callback(v) end
        end)
    end
end

local function CriarInputDelay(texto, parent, stateTable, stateKey, valDefault)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.92, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = GetOrdem()
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = " " .. texto
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(0.4, 0, 0, 22)
    input.Position = UDim2.new(0.6, 0, 0, 4)
    input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    input.Text = tostring(stateTable[stateKey] or valDefault)
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.Font = Enum.Font.SourceSansBold
    input.TextSize = 13
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 4)
    
    input.FocusLost:Connect(function()
        local val = tonumber(input.Text)
        if val then stateTable[stateKey] = val else input.Text = tostring(stateTable[stateKey]) end
    end)
end

local function CriarDropdownEstilizado(labelTexto, parent, stateTable, stateKey, isMulti, zBase)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.92, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = GetOrdem()
    frame.ZIndex = zBase
    
    local mainBtn = Instance.new("TextButton", frame)
    mainBtn.Size = UDim2.new(1, 0, 1, 0)
    mainBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    mainBtn.Text = labelTexto .. ": Clique p/ Atualizar"
    mainBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    mainBtn.Font = Enum.Font.SourceSansSemibold
    mainBtn.TextSize = 13
    mainBtn.BorderSizePixel = 0
    mainBtn.ZIndex = zBase + 1
    Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(0, 4)
    
    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1, 0, 0, 120)
    scroll.Position = UDim2.new(0, 0, 1, 2)
    scroll.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    scroll.BorderSizePixel = 0
    scroll.Visible = false
    scroll.ZIndex = zBase + 5
    scroll.ScrollBarThickness = 4
    Instance.new("UIListLayout", scroll)
    
    mainBtn.MouseButton1Click:Connect(function() scroll.Visible = not scroll.Visible end)
    
    if isMulti and not stateTable[stateKey] then stateTable[stateKey] = {["All"] = true} end
    
    local dropdownObj = {}
    function dropdownObj:Refresh(listaItems)
        for _, old in ipairs(scroll:GetChildren()) do if old:IsA("TextButton") then old:Destroy() end end
        
        local hTotal = 0
        local itemsToRender = {}
        if isMulti then table.insert(itemsToRender, "All") end
        for _, item in ipairs(listaItems) do table.insert(itemsToRender, item) end
        
        local botoesCriados = {}
        local function atualizarMainText()
            if isMulti then
                if stateTable[stateKey]["All"] then
                    mainBtn.Text = labelTexto .. ": All"
                else
                    local count = 0
                    for k, v in pairs(stateTable[stateKey]) do if v then count = count + 1 end end
                    mainBtn.Text = labelTexto .. ": " .. count .. " sel."
                end
            else
                mainBtn.Text = labelTexto .. ": " .. tostring(stateTable[stateKey] or "Nenhum")
            end
        end
        
        for _, itemNome in ipairs(itemsToRender) do
            local itemBtn = Instance.new("TextButton", scroll)
            itemBtn.Size = UDim2.new(1, 0, 0, 25)
            itemBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            itemBtn.BorderSizePixel = 0
            itemBtn.Text = itemNome
            itemBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
            itemBtn.Font = Enum.Font.SourceSans
            itemBtn.TextSize = 13
            itemBtn.ZIndex = zBase + 6
            table.insert(botoesCriados, {btn = itemBtn, nome = itemNome})
            hTotal = hTotal + 25
            
            local function applyVisual()
                if isMulti then
                    itemBtn.BackgroundColor3 = stateTable[stateKey][itemNome] and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(35, 35, 35)
                    itemBtn.TextColor3 = stateTable[stateKey][itemNome] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
                end
            end
            applyVisual()
            
            itemBtn.MouseButton1Click:Connect(function()
                if isMulti then
                    if itemNome == "All" then stateTable[stateKey] = {["All"] = true}
                    else
                        stateTable[stateKey]["All"] = nil
                        stateTable[stateKey][itemNome] = not stateTable[stateKey][itemNome]
                    end
                    for _, obj in ipairs(botoesCriados) do
                        obj.btn.BackgroundColor3 = stateTable[stateKey][obj.nome] and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(35, 35, 35)
                        obj.btn.TextColor3 = stateTable[stateKey][obj.nome] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
                    end
                    atualizarMainText()
                else
                    stateTable[stateKey] = itemNome
                    atualizarMainText()
                    scroll.Visible = false
                end
            end)
        end
        scroll.CanvasSize = UDim2.new(0, 0, 0, hTotal)
        atualizarMainText()
    end
    return dropdownObj
end

-- ================= ABA 3: FAZENDA (CARDS FLEX-WRAP) =================
local p3 = Paginas["fazenda"]

local cardMainFarm = CriarCard("MAIN FARM", p3)
CriarToggleEstilizado("🟢 Start Farm", cardMainFarm, State, "AutoFarmingCrops", function(v) if Bot.Modules.Farmer then Bot.Modules.Farmer:AlternarAutoFazenda(v) end end)
CriarLinhaCheckboxes(cardMainFarm, {
    { texto = "Plow Grass", table = State.FarmSettings, key = "PlowGrass" },
    { texto = "Place Grass", table = State.FarmSettings, key = "PlaceGrass" }
})
CriarLinhaCheckboxes(cardMainFarm, { { texto = "Auto Replace", table = State.FarmSettings, key = "AutoReplace" } })

local cardSeed = CriarCard("SEED SELECT", p3)
local DropdownSementes = CriarDropdownEstilizado("Sementes", cardSeed, State, "SementeSelecionada", true, 150)
local PriorizeDropdown = CriarDropdownEstilizado("Priorize", cardSeed, State.FarmSettings, "PrioritizePlant", false, 100)
CriarBotaoEstilizado("🔄 Refresh Seeds", cardSeed, function()
    if Bot.Modules.Manager then 
        local inv = Bot.Modules.Manager:GetInventoryTools("Seed")
        DropdownSementes:Refresh(inv)
        PriorizeDropdown:Refresh(inv)
    end
end)

local cardDelay = CriarCard("CONFIG DELAY", p3)
CriarInputDelay("Harvest (s)", cardDelay, State.FarmSettings, "HarvestDelay", 0.1)
CriarInputDelay("Plant (s)", cardDelay, State.FarmSettings, "PlantDelay", 0.15)
CriarLinhaCheckboxes(cardDelay, {
    { texto = "Ocultar Números", table = State, key = "HideNumbers", callback = function()
        if State.ScannerFazenda then State.ScannerFazenda:EscanearArea() end
        if State.ScannerGeral then State.ScannerGeral:EscanearArea() end
    end }
})

local cardSaves = CriarCard("SELECTOR & SAVES", p3, 1, 0) -- WidthScale 1 faz ele ocupar a linha inteira sozinho embaixo
cardSaves.Parent.Size = UDim2.new(0.95, 0, 0, 0) -- Ajuste do wrapper
CriarBotaoEstilizado("🟩 Spawn Block Verde", cardSaves, function() if State.ScannerFazenda then State.ScannerFazenda:CriarSeletorFrontal() end end)

local PadFazenda = Instance.new("Frame", cardSaves)
PadFazenda.Size = UDim2.new(0.95, 0, 0, 90)
PadFazenda.BackgroundTransparency = 1
PadFazenda.LayoutOrder = GetOrdem()

local CrossFazenda = Instance.new("Frame", PadFazenda)
CrossFazenda.Size = UDim2.new(0, 100, 0, 80)
CrossFazenda.Position = UDim2.new(0, 10, 0, 5)
CrossFazenda.BackgroundTransparency = 1

local function CriarMiniBotao(texto, x, y, direcao, parent, scannerName)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0, 30, 0, 25)
    b.Position = UDim2.new(0, x, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    b.Text = texto
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 14
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 3)
    b.MouseButton1Click:Connect(function() if State[scannerName] then State[scannerName]:MoverSeletor(direcao) end end)
end
CriarMiniBotao("^", 35, 5, "Frente", CrossFazenda, "ScannerFazenda")
CriarMiniBotao("<", 2, 35, "Esquerda", CrossFazenda, "ScannerFazenda")
CriarMiniBotao("v", 35, 35, "Tras", CrossFazenda, "ScannerFazenda")
CriarMiniBotao(">", 68, 35, "Direita", CrossFazenda, "ScannerFazenda")

local VertFazenda = Instance.new("Frame", PadFazenda)
VertFazenda.Size = UDim2.new(1, -125, 0, 80)
VertFazenda.Position = UDim2.new(0, 120, 0, 5)
VertFazenda.BackgroundTransparency = 1

local function CriarBtnVertical(texto, y, direcao, parent, scannerName)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, 0, 0, 25)
    b.Position = UDim2.new(0, 0, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(45, 55, 65)
    b.Text = texto
    b.TextColor3 = Color3.fromRGB(240, 240, 240)
    b.Font = Enum.Font.SourceSansSemibold
    b.TextSize = 13
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.MouseButton1Click:Connect(function() if State[scannerName] then State[scannerName]:MoverSeletor(direcao) end end)
end
CriarBtnVertical("🔼 Subir (+3)", 15, "Subir", VertFazenda, "ScannerFazenda")
CriarBtnVertical("🔽 Descer (-3)", 45, "Descer", VertFazenda, "ScannerFazenda")

local rowSave = Instance.new("Frame", cardSaves)
rowSave.Size = UDim2.new(0.95, 0, 0, 30)
rowSave.BackgroundTransparency = 1
rowSave.LayoutOrder = GetOrdem()
local inputPlot = Instance.new("TextBox", rowSave)
inputPlot.Size = UDim2.new(0.65, -5, 1, 0)
inputPlot.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
inputPlot.PlaceholderText = "Nome do Plot..."
inputPlot.Text = ""
inputPlot.TextColor3 = Color3.fromRGB(255, 255, 255)
inputPlot.Font = Enum.Font.SourceSans
inputPlot.TextSize = 13
Instance.new("UICorner", inputPlot).CornerRadius = UDim.new(0, 4)
local btnSave = Instance.new("TextButton", rowSave)
btnSave.Size = UDim2.new(0.35, 0, 1, 0)
btnSave.Position = UDim2.new(0.65, 5, 0, 0)
btnSave.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
btnSave.Text = "💾 Save Plot"
btnSave.TextColor3 = Color3.fromRGB(255, 255, 255)
btnSave.Font = Enum.Font.SourceSansBold
btnSave.TextSize = 13
Instance.new("UICorner", btnSave).CornerRadius = UDim.new(0, 4)

local plotDropdown = CriarDropdownEstilizado("Select Save", cardSaves, State.FarmSettings, "CurrentSaveName", false, 50)
local function AtualizarListaSaves()
    if Bot.Modules.PlotManager and plotDropdown then
        local plots = Bot.Modules.PlotManager:ObterTodos()
        local lista = {}
        for nome, _ in pairs(plots) do table.insert(lista, nome) end
        if #lista == 0 then lista = {"Nenhum"} end
        plotDropdown:Refresh(lista)
    end
end
btnSave.MouseButton1Click:Connect(function()
    local cubo = State.ScannerFazenda and State.ScannerFazenda.AncoraPart
    if inputPlot.Text ~= "" and cubo then
        Bot.Modules.PlotManager:SalvarPlot(inputPlot.Text, cubo.Position, cubo.Size)
        AtualizarListaSaves()
        inputPlot.Text = ""
    end
end)

local rowActions = Instance.new("Frame", cardSaves)
rowActions.Size = UDim2.new(0.95, 0, 0, 30)
rowActions.BackgroundTransparency = 1
rowActions.LayoutOrder = GetOrdem()
local layoutActions = Instance.new("UIListLayout", rowActions)
layoutActions.FillDirection = Enum.FillDirection.Horizontal
layoutActions.Padding = UDim.new(0, 5)

local function CriarAcaoPlot(texto, cor, callback)
    local b = Instance.new("TextButton", rowActions)
    b.Size = UDim2.new(0.33, -3, 1, 0)
    b.BackgroundColor3 = cor
    b.Text = texto
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 13
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.MouseButton1Click:Connect(callback)
end

CriarAcaoPlot("Load", Color3.fromRGB(0, 150, 100), function()
    local sn = State.FarmSettings.CurrentSaveName
    if sn and sn ~= "Nenhum" then
        local p = Bot.Modules.PlotManager:ObterTodos()[sn]
        if p and State.ScannerFazenda then State.ScannerFazenda:CarregarPlot(Vector3.new(p.PosX, p.PosY, p.PosZ), Vector3.new(p.SizeX, p.SizeY, p.SizeZ)) end
    end
end)
CriarAcaoPlot("Rewrite", Color3.fromRGB(200, 100, 0), function()
    local sn = State.FarmSettings.CurrentSaveName
    local cubo = State.ScannerFazenda and State.ScannerFazenda.AncoraPart
    if sn and sn ~= "Nenhum" and cubo then Bot.Modules.PlotManager:SalvarPlot(sn, cubo.Position, cubo.Size) end
end)
CriarAcaoPlot("Delete", Color3.fromRGB(200, 50, 50), function()
    local sn = State.FarmSettings.CurrentSaveName
    if sn and sn ~= "Nenhum" then
        Bot.Modules.PlotManager:DeletarPlot(sn)
        State.FarmSettings.CurrentSaveName = "Nenhum"
        AtualizarListaSaves()
    end
end)

CriarLinhaCheckboxes(cardSaves, { { texto = "Auto Load Selected Save", table = State.FarmSettings, key = "AutoUseSelectedSave" } })

task.spawn(function() task.wait(1); AtualizarListaSaves() end)

-- ================= ABA 1: GERAL (Adaptada para Cards) =================
local p1 = Paginas["seletor"]
local cardMiner = CriarCard("MINER & BUILDER", p1)
CriarToggleEstilizado("⛏️ Ativar Mineração", cardMiner, State, "Minerando", function(v) if Bot.Modules.Miner then Bot.Modules.Miner:Alternar(v) end end)
local DropdownBlocos = CriarDropdownEstilizado("Material", cardMiner, State, "BlocoSelecionado", false, 100)
CriarBotaoEstilizado("🔄 Recarregar Inventário", cardMiner, function() if Bot.Modules.Manager then DropdownBlocos:Refresh(Bot.Modules.Manager:GetInventoryTools("Block")) end end)
CriarBotaoEstilizado("🔨 Preencher Área", cardMiner, function() if Bot.Modules.Builder then Bot.Modules.Builder:ColocarAreaMarcada() end end)

local cardSelGeral = CriarCard("SELETOR AZUL", p1)
CriarBotaoEstilizado("🟦 Spawn Block (Frente)", cardSelGeral, function() if State.ScannerGeral then State.ScannerGeral:CriarSeletorFrontal() end end)
local PadGeral = Instance.new("Frame", cardSelGeral)
PadGeral.Size = UDim2.new(0.95, 0, 0, 90)
PadGeral.BackgroundTransparency = 1
PadGeral.LayoutOrder = GetOrdem()
local CrossGeral = Instance.new("Frame", PadGeral)
CrossGeral.Size = UDim2.new(0, 100, 0, 80)
CrossGeral.Position = UDim2.new(0, 10, 0, 5)
CrossGeral.BackgroundTransparency = 1
CriarMiniBotao("^", 35, 5, "Frente", CrossGeral, "ScannerGeral")
CriarMiniBotao("<", 2, 35, "Esquerda", CrossGeral, "ScannerGeral")
CriarMiniBotao("v", 35, 35, "Tras", CrossGeral, "ScannerGeral")
CriarMiniBotao(">", 68, 35, "Direita", CrossGeral, "ScannerGeral")
local VertGeral = Instance.new("Frame", PadGeral)
VertGeral.Size = UDim2.new(1, -125, 0, 80)
VertGeral.Position = UDim2.new(0, 120, 0, 5)
VertGeral.BackgroundTransparency = 1
CriarBtnVertical("🔼 Subir (+3)", 15, "Subir", VertGeral, "ScannerGeral")
CriarBtnVertical("🔽 Descer (-3)", 45, "Descer", VertGeral, "ScannerGeral")

-- ================= ABA 4: SISTEMA =================
local p4 = Paginas["sistema"]
local cardSys = CriarCard("SISTEMA", p4)
local btnKeybind = CriarBotaoEstilizado("⌨️ Tecla de Ocultar: V", cardSys, function() end)
btnKeybind.MouseButton1Click:Connect(function()
    isListeningForKey = true
    btnKeybind.Text = "⌨️ Pressione uma tecla..."
    btnKeybind.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
end)

State.UpdateKeybindButton = function()
    btnKeybind.Text = "⌨️ Tecla de Ocultar: " .. currentHideKey.Name
    btnKeybind.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
end

CriarBotaoEstilizado("❌ Finalizar Bot e Limpar UI", cardSys, function()
    if Bot.Modules.Miner then Bot.Modules.Miner:Alternar(false) end
    if Bot.Modules.Farmer then Bot.Modules.Farmer:AlternarAutoFazenda(false) end
    if State.ScannerGeral then State.ScannerGeral:LimparAncora() end
    if State.ScannerFazenda then State.ScannerFazenda:LimparAncora() end
    ScreenGui:Destroy()
end)

return UI