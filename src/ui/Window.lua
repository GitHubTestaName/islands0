-- src/ui/Window.lua
local UI = {}
local Bot = _G.IslandsBot
local State = Bot.State

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

if CoreGui:FindFirstChild("IslandsCustomUI") then
    CoreGui.IslandsCustomUI:Destroy()
end

-- ================= INSTÂNCIA PRINCIPAL DA UI =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "IslandsCustomUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- ================= SISTEMA DE REDIMENSIONAMENTO DA JANELA =================
local WindowResizeHandle = Instance.new("TextButton", MainFrame)
WindowResizeHandle.Size = UDim2.new(0, 20, 0, 20)
WindowResizeHandle.Position = UDim2.new(1, -20, 1, -20)
WindowResizeHandle.BackgroundTransparency = 1
WindowResizeHandle.Text = "◢"
WindowResizeHandle.TextColor3 = Color3.fromRGB(100, 100, 100)
WindowResizeHandle.TextSize = 14
WindowResizeHandle.ZIndex = 10

local draggingWindow = false
local dragStartPos = nil
local startSize = nil

WindowResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingWindow = true
        dragStartPos = input.Position
        startSize = MainFrame.AbsoluteSize
    end
end)

-- ================= SISTEMA DE OCULTAR (KEYBIND) =================
local currentHideKey = Enum.KeyCode.V
local isListeningForKey = false

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

-- Barra de Topo
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Islands Automation PRO"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = TopBar

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, 200, 0, 20)
StatusLabel.Position = UDim2.new(1, -215, 0, 7)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Ocioso"
StatusLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
StatusLabel.TextXAlignment = Enum.TextXAlignment.Right
StatusLabel.Font = Enum.Font.SourceSansSemibold
StatusLabel.TextSize = 14
StatusLabel.Parent = TopBar

function UI:SetStatusText(texto)
    StatusLabel.Text = "Status: " .. tostring(texto)
end

-- ================= MENU LATERAL & CONTEÚDO =================
local SidebarWidth = 110

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, SidebarWidth, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Sidebar.BorderSizePixel = 0
Sidebar.ClipsDescendants = true
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 4)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarLayout.Parent = Sidebar

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -(SidebarWidth + 10), 1, -45)
ContentContainer.Position = UDim2.new(0, SidebarWidth + 5, 0, 40)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- ================= SISTEMA DE REDIMENSIONAMENTO DO MENU LATERAL =================
local SidebarResizer = Instance.new("TextButton")
SidebarResizer.Size = UDim2.new(0, 6, 1, -35)
SidebarResizer.Position = UDim2.new(0, SidebarWidth, 0, 35)
SidebarResizer.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
SidebarResizer.BackgroundTransparency = 0.8 -- Fica sutil
SidebarResizer.Text = "⋮"
SidebarResizer.TextColor3 = Color3.fromRGB(200, 200, 200)
SidebarResizer.TextSize = 14
SidebarResizer.BorderSizePixel = 0
SidebarResizer.ZIndex = 10
SidebarResizer.Parent = MainFrame

local draggingSidebar = false
local sidebarDragStartPos = 0
local sidebarStartWidth = 0

SidebarResizer.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSidebar = true
        sidebarDragStartPos = input.Position.X
        sidebarStartWidth = Sidebar.AbsoluteSize.X
        SidebarResizer.BackgroundTransparency = 0.2 -- Fica brilhante ao arrastar
    end
end)

UserInputService.InputChanged:Connect(function(input)
    -- Arrastar da Janela Geral
    if draggingWindow and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartPos
        local newWidth = math.max(450, startSize.X + delta.X)
        local newHeight = math.max(320, startSize.Y + delta.Y)
        MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
    end

    -- Arrastar do Menu Lateral
    if draggingSidebar and input.UserInputType == Enum.UserInputType.MouseMovement then
        local deltaX = input.Position.X - sidebarDragStartPos
        local newWidth = math.clamp(sidebarStartWidth + deltaX, 80, 200) -- Limites de largura do menu
        
        Sidebar.Size = UDim2.new(0, newWidth, 1, -35)
        SidebarResizer.Position = UDim2.new(0, newWidth, 0, 35)
        ContentContainer.Position = UDim2.new(0, newWidth + 8, 0, 40)
        ContentContainer.Size = UDim2.new(1, -(newWidth + 12), 1, -45)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingWindow = false
        if draggingSidebar then
            draggingSidebar = false
            SidebarResizer.BackgroundTransparency = 0.8
        end
    end
end)

-- ================= ABAS (DESIGN PREMIUM) =================
local Paginas = {}
local BotoesAba = {}

local function CriarAba(nome, id)
    local btn = Instance.new("TextButton")
    -- Usa 90% da largura do Sidebar para deixar uma bordinha legal
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BorderSizePixel = 0
    btn.Text = nome
    btn.TextColor3 = Color3.fromRGB(160, 160, 160)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = Sidebar
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    -- A Mágica do Outline Azul
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 150, 255)
    stroke.Thickness = 1.5
    stroke.Transparency = 1 -- Invisível por padrão
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = btn
    
    local pg = Instance.new("ScrollingFrame")
    pg.Size = UDim2.new(1, 0, 1, 0)
    pg.BackgroundTransparency = 1
    pg.BorderSizePixel = 0
    pg.ScrollBarThickness = 4
    pg.Visible = false
    pg.Parent = ContentContainer
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = pg
    
    -- Ajusta o canvas interno dinamicamente
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        pg.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)
    
    Paginas[id] = pg
    BotoesAba[id] = btn
    
    btn.MouseButton1Click:Connect(function()
        for k, v in pairs(Paginas) do v.Visible = (k == id) end
        for k, v in pairs(BotoesAba) do 
            local isActive = (k == id)
            v.TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 160)
            v.BackgroundColor3 = isActive and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(30, 30, 30)
            v.UIStroke.Transparency = isActive and 0 or 1
        end
    end)
end

CriarAba("Seletor", "seletor")
CriarAba("Ações", "acoes")
CriarAba("Fazenda", "fazenda")
CriarAba("Sistema", "sistema")

-- Ativa a primeira aba por padrão
BotoesAba["seletor"].TextColor3 = Color3.fromRGB(255, 255, 255)
BotoesAba["seletor"].BackgroundColor3 = Color3.fromRGB(0, 100, 200)
BotoesAba["seletor"].UIStroke.Transparency = 0
Paginas["seletor"].Visible = true

-- ================= COMPONENTES (100% RESPONSIVOS NA LARGURA) =================
local function CriarBotaoEstilizado(texto, parent, callback)
    local btn = Instance.new("TextButton")
    -- A mágica da responsividade: Width é 100% (Scale 1), Height é fixa (32px)
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = texto
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.SourceSansSemibold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function CriarToggleEstilizado(texto, parent, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 32)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = texto
    label.TextColor3 = Color3.fromRGB(210, 210, 210)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 24)
    btn.Position = UDim2.new(1, -50, 0, 4)
    btn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local estado = false
    btn.MouseButton1Click:Connect(function()
        estado = not estado
        btn.Text = estado and "ON" or "OFF"
        btn.BackgroundColor3 = estado and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(180, 50, 50)
        callback(estado)
    end)
end

local function CriarDropdownEstilizado(labelTexto, parent, stateKey)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.BackgroundTransparency = 1
    frame.ClipsDescendants = false
    frame.Parent = parent
    
    local mainBtn = Instance.new("TextButton")
    mainBtn.Size = UDim2.new(1, 0, 1, 0)
    mainBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    mainBtn.Text = labelTexto .. ": Clique p/ Atualizar"
    mainBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    mainBtn.Font = Enum.Font.SourceSansSemibold
    mainBtn.TextSize = 14
    mainBtn.BorderSizePixel = 0
    mainBtn.Parent = frame
    Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(0, 4)
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 0, 120)
    scroll.Position = UDim2.new(0, 0, 1, 2)
    scroll.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    scroll.BorderSizePixel = 0
    scroll.Visible = false
    scroll.ZIndex = 5
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 4
    scroll.Parent = frame
    Instance.new("UIListLayout", scroll)
    
    mainBtn.MouseButton1Click:Connect(function() scroll.Visible = not scroll.Visible end)
    
    local dropdownObj = {}
    function dropdownObj:Refresh(listaItems)
        for _, old in ipairs(scroll:GetChildren()) do
            if old:IsA("TextButton") then old:Destroy() end
        end
        
        local hTotal = 0
        for _, itemNome in ipairs(listaItems) do
            local itemBtn = Instance.new("TextButton")
            itemBtn.Size = UDim2.new(1, 0, 0, 25)
            itemBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            itemBtn.BorderSizePixel = 0
            itemBtn.Text = itemNome
            itemBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
            itemBtn.Font = Enum.Font.SourceSans
            itemBtn.TextSize = 13
            itemBtn.ZIndex = 6
            itemBtn.Parent = scroll
            
            hTotal = hTotal + 25
            itemBtn.MouseButton1Click:Connect(function()
                mainBtn.Text = labelTexto .. ": " .. itemNome
                Bot.State[stateKey] = itemNome
                scroll.Visible = false
            end)
        end
        scroll.CanvasSize = UDim2.new(0, 0, 0, hTotal)
    end
    return dropdownObj
end

-- ================= CONSTRUTOR ABA 1: SELETOR =================
local p1 = Paginas["seletor"]
CriarBotaoEstilizado("🟦 Gerar Cubo Azul no Personagem", p1, function()
    if Bot.Modules.Scanner then Bot.Modules.Scanner:CriarSeletorFrontal() end
end)

local PadLabel = Instance.new("TextLabel")
PadLabel.Size = UDim2.new(1, 0, 0, 20)
PadLabel.BackgroundTransparency = 1
PadLabel.Text = "Movimentação Fixa:"
PadLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
PadLabel.Font = Enum.Font.SourceSansBold
PadLabel.TextSize = 13
PadLabel.TextXAlignment = Enum.TextXAlignment.Left
PadLabel.Parent = p1

local CrossContainer = Instance.new("Frame")
CrossContainer.Size = UDim2.new(0, 100, 0, 80)
CrossContainer.BackgroundTransparency = 1
CrossContainer.Parent = p1

local function CriarMiniBotao(texto, x, y, direcao)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 30, 0, 25)
    b.Position = UDim2.new(0, x, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    b.Text = texto
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 14
    b.BorderSizePixel = 0
    b.Parent = CrossContainer
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 3)
    b.MouseButton1Click:Connect(function()
        if Bot.Modules.Scanner then Bot.Modules.Scanner:MoverSeletor(direcao) end
    end)
end

CriarMiniBotao("^", 35, 5, "Frente")
CriarMiniBotao("<", 2, 35, "Esquerda")
CriarMiniBotao("v", 35, 35, "Tras")
CriarMiniBotao(">", 68, 35, "Direita")

CriarBotaoEstilizado("🔼 Subir Cubo (+3)", p1, function() if Bot.Modules.Scanner then Bot.Modules.Scanner:MoverSeletor("Subir") end end)
CriarBotaoEstilizado("🔽 Descer Cubo (-3)", p1, function() if Bot.Modules.Scanner then Bot.Modules.Scanner:MoverSeletor("Descer") end end)

-- ================= CONSTRUTOR ABA 2: AÇÕES =================
local p2 = Paginas["acoes"]
CriarToggleEstilizado("⛏️ Ativar Loop de Mineração", p2, function(v) if Bot.Modules.Miner then Bot.Modules.Miner:Alternar(v) end end)
local DropdownBlocos = CriarDropdownEstilizado("Material", p2, "BlocoSelecionado")
CriarBotaoEstilizado("🔄 Recarregar Inventário", p2, function()
    if Bot.Modules.Manager then DropdownBlocos:Refresh(Bot.Modules.Manager:GetInventoryTools("Block")) end
end)
CriarBotaoEstilizado("🔨 Preencher Área Selecionada", p2, function()
    if Bot.Modules.Builder then Bot.Modules.Builder:ColocarAreaMarcada() end
end)

-- ================= CONSTRUTOR ABA 3: FAZENDA =================
local p3 = Paginas["fazenda"]
CriarBotaoEstilizado("🚜 Arar Terra Manualmente", p3, function() if Bot.Modules.Farmer then Bot.Modules.Farmer:ArarTerra() end end)
local DropdownSementes = CriarDropdownEstilizado("Semente", p3, "SementeSelecionada")
CriarBotaoEstilizado("🔄 Recarregar Sementes", p3, function()
    if Bot.Modules.Manager then DropdownSementes:Refresh(Bot.Modules.Manager:GetInventoryTools("Seed")) end
end)
CriarToggleEstilizado("🟢 Auto-Fazenda Ativa", p3, function(v) if Bot.Modules.Farmer then Bot.Modules.Farmer:AlternarAutoFazenda(v) end end)

-- ================= CONSTRUTOR ABA 4: SISTEMA =================
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
    if Bot.Modules.Scanner then Bot.Modules.Scanner:LimparAncora() end
    ScreenGui:Destroy()
end)

return UI