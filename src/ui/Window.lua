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
MainFrame.Size = UDim2.new(0, 500, 0, 450)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- ================= ARRASTAR APENAS PELO TOPBAR =================
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
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
WindowResizeHandle.ZIndex = 10

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
            MainFrame.Size = UDim2.new(0, math.max(450, winStartSize.X + delta.X), 0, math.max(350, winStartSize.Y + delta.Y))
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

-- ================= MENU LATERAL =================
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 110, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Sidebar.BorderSizePixel = 0

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 10)

local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.Size = UDim2.new(1, -115, 1, -35)
ContentContainer.Position = UDim2.new(0, 115, 0, 35)
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
    pg.Size = UDim2.new(1, 0, 1, -15)
    pg.Position = UDim2.new(0, 0, 0, 10)
    pg.BackgroundTransparency = 1
    pg.BorderSizePixel = 0
    pg.ScrollBarThickness = 4
    pg.Visible = false
    
    local layout = Instance.new("UIListLayout", pg)
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder -- Ordem Estrita de layout
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        pg.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
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

-- ================= CONSTRUTORES DE LAYOUT (A Mágica da Ordem) =================
local layoutOrderGlobal = 0
local function GetOrdem() layoutOrderGlobal = layoutOrderGlobal + 1 return layoutOrderGlobal end

local function CriarSecao(titulo, parent)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(0.95, 0, 0, 20)
    f.BackgroundTransparency = 1
    f.LayoutOrder = GetOrdem()
    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(1, 0, 1, 0)
    t.BackgroundTransparency = 1
    t.Text = titulo
    t.TextColor3 = Color3.fromRGB(0, 180, 255)
    t.Font = Enum.Font.SourceSansBold
    t.TextSize = 14
    t.TextXAlignment = Enum.TextXAlignment.Left
    return f
end

local function CriarBotaoEstilizado(texto, parent, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = texto
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.SourceSansSemibold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.LayoutOrder = GetOrdem()
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function CriarToggleEstilizado(texto, parent, stateTable, stateKey, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.95, 0, 0, 32)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = GetOrdem()
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = " " .. texto
    label.TextColor3 = Color3.fromRGB(210, 210, 210)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 50, 0, 24)
    btn.Position = UDim2.new(1, -50, 0, 4)
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

-- ================= LINHAS HORIZONTAIS COMPACTAS =================
-- Para organizar os Checkboxes Lado a Lado
local function CriarLinhaCheckboxes(parent, listaConfigs)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.95, 0, 0, 24)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = GetOrdem()
    
    local layout = Instance.new("UIListLayout", frame)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 10)
    
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

-- Para organizar os Delays Lado a Lado
local function CriarLinhaInputs(parent, listaConfigs)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.95, 0, 0, 32)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = GetOrdem()
    
    local layout = Instance.new("UIListLayout", frame)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 10)
    
    local wScale = (1 / #listaConfigs) - 0.05
    for _, config in ipairs(listaConfigs) do
        local container = Instance.new("Frame", frame)
        container.Size = UDim2.new(wScale, 0, 1, 0)
        container.BackgroundTransparency = 1
        
        local label = Instance.new("TextLabel", container)
        label.Size = UDim2.new(0.6, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = config.texto
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.Font = Enum.Font.SourceSans
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        local input = Instance.new("TextBox", container)
        input.Size = UDim2.new(0.4, 0, 0, 24)
        input.Position = UDim2.new(0.6, 0, 0, 4)
        input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        input.Text = tostring(config.table[config.key])
        input.TextColor3 = Color3.fromRGB(255, 255, 255)
        input.Font = Enum.Font.SourceSansBold
        input.TextSize = 13
        Instance.new("UICorner", input).CornerRadius = UDim.new(0, 4)
        
        input.FocusLost:Connect(function()
            local val = tonumber(input.Text)
            if val then config.table[config.key] = val else input.Text = tostring(config.table[config.key]) end
        end)
    end
end

-- ================= DROPDOWNS COM Z-INDEX FIXO =================
-- Adicionamos zBase para que um Dropdown não se esconda atrás do outro!
local function CriarDropdownEstilizado(labelTexto, parent, stateTable, stateKey, isMulti, zBase)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.95, 0, 0, 32)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = GetOrdem()
    frame.ZIndex = zBase
    
    local mainBtn = Instance.new("TextButton", frame)
    mainBtn.Size = UDim2.new(1, 0, 1, 0)
    mainBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    mainBtn.Text = labelTexto .. ": Clique p/ Atualizar"
    mainBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    mainBtn.Font = Enum.Font.SourceSansSemibold
    mainBtn.TextSize = 14
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
                    mainBtn.Text = labelTexto .. ": All (Qualquer)"
                else
                    local count = 0
                    for k, v in pairs(stateTable[stateKey]) do if v then count = count + 1 end end
                    mainBtn.Text = labelTexto .. ": " .. count .. " selecionada(s)"
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


-- ================= ABA 1: GERAL (AZUL) =================
local p1 = Paginas["seletor"]

CriarSecao("=== MINER & BUILDER ===", p1)
CriarToggleEstilizado("⛏️ Ativar Loop de Mineração", p1, State, "Minerando", function(v) if Bot.Modules.Miner then Bot.Modules.Miner:Alternar(v) end end)
local DropdownBlocos = CriarDropdownEstilizado("Material (Build)", p1, State, "BlocoSelecionado", false, 100)
CriarBotaoEstilizado("🔄 Recarregar Inventário", p1, function() if Bot.Modules.Manager then DropdownBlocos:Refresh(Bot.Modules.Manager:GetInventoryTools("Block")) end end)
CriarBotaoEstilizado("🔨 Preencher Área Selecionada", p1, function() if Bot.Modules.Builder then Bot.Modules.Builder:ColocarAreaMarcada() end end)

CriarSecao("=== CONFIG. DO SELETOR ===", p1)
CriarLinhaCheckboxes(p1, {
    { texto = "Ocultar Números", table = State, key = "HideNumbers", callback = function()
        if State.ScannerGeral then State.ScannerGeral:EscanearArea() end
    end }
})

CriarSecao("=== SELETOR AZUL ===", p1)
CriarBotaoEstilizado("🟦 Spawn Block (Frente)", p1, function() if State.ScannerGeral then State.ScannerGeral:CriarSeletorFrontal() end end)

local PadContainer = Instance.new("Frame", p1)
PadContainer.Size = UDim2.new(0.95, 0, 0, 90)
PadContainer.BackgroundTransparency = 1
PadContainer.LayoutOrder = GetOrdem()

local CrossContainer = Instance.new("Frame", PadContainer)
CrossContainer.Size = UDim2.new(0, 100, 0, 80)
CrossContainer.Position = UDim2.new(0, 10, 0, 5)
CrossContainer.BackgroundTransparency = 1

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
    b.MouseButton1Click:Connect(function()
        if State[scannerName] then State[scannerName]:MoverSeletor(direcao) end
    end)
end

CriarMiniBotao("^", 35, 5, "Frente", CrossContainer, "ScannerGeral")
CriarMiniBotao("<", 2, 35, "Esquerda", CrossContainer, "ScannerGeral")
CriarMiniBotao("v", 35, 35, "Tras", CrossContainer, "ScannerGeral")
CriarMiniBotao(">", 68, 35, "Direita", CrossContainer, "ScannerGeral")

local VerticalContainer = Instance.new("Frame", PadContainer)
VerticalContainer.Size = UDim2.new(1, -125, 0, 80)
VerticalContainer.Position = UDim2.new(0, 120, 0, 5)
VerticalContainer.BackgroundTransparency = 1

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
    b.MouseButton1Click:Connect(function()
        if State[scannerName] then State[scannerName]:MoverSeletor(direcao) end
    end)
end

CriarBtnVertical("🔼 Subir (+3)", 15, "Subir", VerticalContainer, "ScannerGeral")
CriarBtnVertical("🔽 Descer (-3)", 45, "Descer", VerticalContainer, "ScannerGeral")


-- ================= ABA 3: FAZENDA (A OBRA DE ARTE) =================
local p3 = Paginas["fazenda"]

CriarSecao("=== MAIN FARM ===", p3)
CriarToggleEstilizado("🟢 Start Farm", p3, State, "AutoFarmingCrops", function(v) if Bot.Modules.Farmer then Bot.Modules.Farmer:AlternarAutoFazenda(v) end end)

CriarLinhaCheckboxes(p3, {
    { texto = "Plow Grass", table = State.FarmSettings, key = "PlowGrass" },
    { texto = "Place Grass", table = State.FarmSettings, key = "PlaceGrass" },
    { texto = "Auto Replace", table = State.FarmSettings, key = "AutoReplace" }
})

CriarSecao("=== SEED SELECT ===", p3)
-- Passando "State" e Z-Index = 150 para que a lista de Sementes caia sobre a lista de Priorize!
local DropdownSementes = CriarDropdownEstilizado("Sementes", p3, State, "SementeSelecionada", true, 150)
-- Passando "State.FarmSettings" com a chave correta e Z-Index menor
local PriorizeDropdown = CriarDropdownEstilizado("Priorize Plant", p3, State.FarmSettings, "PrioritizePlant", false, 100)
CriarBotaoEstilizado("🔄 Refresh Seeds", p3, function()
    if Bot.Modules.Manager then 
        local inv = Bot.Modules.Manager:GetInventoryTools("Seed")
        DropdownSementes:Refresh(inv)
        PriorizeDropdown:Refresh(inv)
    end
end)

CriarSecao("=== CONFIGURE DELAY ===", p3)
CriarLinhaInputs(p3, {
    { texto = "Harvest (s)", table = State.FarmSettings, key = "HarvestDelay" },
    { texto = "Plant (s)", table = State.FarmSettings, key = "PlantDelay" }
})

CriarSecao("=== CONFIGURAÇÃO DO SELETOR ===", p3)
CriarLinhaCheckboxes(p3, {
    { texto = "Ocultar Números", table = State, key = "HideNumbers", callback = function()
        if State.ScannerFazenda then State.ScannerFazenda:EscanearArea() end
    end }
})

CriarSecao("=== SELECTOR & SAVES ===", p3)
CriarBotaoEstilizado("🟩 Spawn Block Verde", p3, function()
    if State.ScannerFazenda then State.ScannerFazenda:CriarSeletorFrontal() end
end)

local PadFazenda = Instance.new("Frame", p3)
PadFazenda.Size = UDim2.new(0.95, 0, 0, 90)
PadFazenda.BackgroundTransparency = 1
PadFazenda.LayoutOrder = GetOrdem()

local CrossFazenda = Instance.new("Frame", PadFazenda)
CrossFazenda.Size = UDim2.new(0, 100, 0, 80)
CrossFazenda.Position = UDim2.new(0, 10, 0, 5)
CrossFazenda.BackgroundTransparency = 1

CriarMiniBotao("^", 35, 5, "Frente", CrossFazenda, "ScannerFazenda")
CriarMiniBotao("<", 2, 35, "Esquerda", CrossFazenda, "ScannerFazenda")
CriarMiniBotao("v", 35, 35, "Tras", CrossFazenda, "ScannerFazenda")
CriarMiniBotao(">", 68, 35, "Direita", CrossFazenda, "ScannerFazenda")

local VertFazenda = Instance.new("Frame", PadFazenda)
VertFazenda.Size = UDim2.new(1, -125, 0, 80)
VertFazenda.Position = UDim2.new(0, 120, 0, 5)
VertFazenda.BackgroundTransparency = 1

CriarBtnVertical("🔼 Subir (+3)", 15, "Subir", VertFazenda, "ScannerFazenda")
CriarBtnVertical("🔽 Descer (-3)", 45, "Descer", VertFazenda, "ScannerFazenda")

-- LINHA DE SALVAMENTO DE PLOTS (Save)
local rowSave = Instance.new("Frame", p3)
rowSave.Size = UDim2.new(0.95, 0, 0, 32)
rowSave.BackgroundTransparency = 1
rowSave.LayoutOrder = GetOrdem()

local inputPlot = Instance.new("TextBox", rowSave)
inputPlot.Size = UDim2.new(0.65, -5, 1, 0)
inputPlot.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
inputPlot.PlaceholderText = "Nome do Plot..."
inputPlot.Text = ""
inputPlot.TextColor3 = Color3.fromRGB(255, 255, 255)
inputPlot.Font = Enum.Font.SourceSans
inputPlot.TextSize = 14
Instance.new("UICorner", inputPlot).CornerRadius = UDim.new(0, 4)

local btnSave = Instance.new("TextButton", rowSave)
btnSave.Size = UDim2.new(0.35, 0, 1, 0)
btnSave.Position = UDim2.new(0.65, 5, 0, 0)
btnSave.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
btnSave.Text = "💾 Save Plot"
btnSave.TextColor3 = Color3.fromRGB(255, 255, 255)
btnSave.Font = Enum.Font.SourceSansBold
btnSave.TextSize = 14
Instance.new("UICorner", btnSave).CornerRadius = UDim.new(0, 4)

-- Forward Declaration
local plotDropdown = nil 

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
    local cubo = State.ScannerFazenda.AncoraPart
    if inputPlot.Text ~= "" and cubo then
        Bot.Modules.PlotManager:SalvarPlot(inputPlot.Text, cubo.Position, cubo.Size)
        AtualizarListaSaves()
        inputPlot.Text = ""
    end
end)

-- SOLUÇÃO DO BUG: Passamos a tabela CORRETA (State.FarmSettings) e a Key "CurrentSaveName"
plotDropdown = CriarDropdownEstilizado("Select Save", p3, State.FarmSettings, "CurrentSaveName", false, 50)

-- LINHA DE AÇÕES (Load, Rewrite, Delete)
local rowActions = Instance.new("Frame", p3)
rowActions.Size = UDim2.new(0.95, 0, 0, 32)
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
    b.TextSize = 14
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.MouseButton1Click:Connect(callback)
end

-- AÇÕES CORRIGIDAS PUXANDO DO LOCAL CERTO
CriarAcaoPlot("Load", Color3.fromRGB(0, 150, 100), function()
    local sn = State.FarmSettings.CurrentSaveName
    if sn and sn ~= "Nenhum" then
        local p = Bot.Modules.PlotManager:ObterTodos()[sn]
        if p and State.ScannerFazenda then 
            State.ScannerFazenda:CarregarPlot(Vector3.new(p.PosX, p.PosY, p.PosZ), Vector3.new(p.SizeX, p.SizeY, p.SizeZ)) 
        end
    end
end)

CriarAcaoPlot("Rewrite", Color3.fromRGB(200, 100, 0), function()
    local sn = State.FarmSettings.CurrentSaveName
    local cubo = State.ScannerFazenda.AncoraPart
    if sn and sn ~= "Nenhum" and cubo then
        Bot.Modules.PlotManager:SalvarPlot(sn, cubo.Position, cubo.Size)
    end
end)

CriarAcaoPlot("Delete", Color3.fromRGB(200, 50, 50), function()
    local sn = State.FarmSettings.CurrentSaveName
    if sn and sn ~= "Nenhum" then
        Bot.Modules.PlotManager:DeletarPlot(sn)
        AtualizarListaSaves()
    end
end)

CriarLinhaCheckboxes(p3, {
    { texto = "Auto use Selected Save", table = State.FarmSettings, key = "AutoUseSelectedSave" }
})

task.spawn(function()
    task.wait(1)
    AtualizarListaSaves()
end)

-- ================= ABA 4: SISTEMA =================
local p4 = Paginas["sistema"]

local btnKeybind = CriarBotaoEstilizado("⌨️ Tecla de Ocultar: V", p4, function() end)
btnKeybind.MouseButton1Click:Connect(function()
    isListeningForKey = true
    btnKeybind.Text = "⌨️ Pressione uma tecla..."
    btnKeybind.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
end)

State.UpdateKeybindButton = function()
    btnKeybind.Text = "⌨️ Tecla de Ocultar: " .. currentHideKey.Name
    btnKeybind.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
end

CriarBotaoEstilizado("❌ Finalizar Bot e Limpar UI", p4, function()
    if Bot.Modules.Miner then Bot.Modules.Miner:Alternar(false) end
    if Bot.Modules.Farmer then Bot.Modules.Farmer:AlternarAutoFazenda(false) end
    if State.ScannerGeral then State.ScannerGeral:LimparAncora() end
    if State.ScannerFazenda then State.ScannerFazenda:LimparAncora() end
    ScreenGui:Destroy()
end)

local isListeningForKey = false
local currentHideKey = Enum.KeyCode.V

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed and not isListeningForKey then return end
    if isListeningForKey and input.UserInputType == Enum.UserInputType.Keyboard then
        currentHideKey = input.KeyCode
        isListeningForKey = false
        if State.UpdateKeybindButton then State.UpdateKeybindButton() end
        return
    end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentHideKey then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

return UI