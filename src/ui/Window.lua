-- src/ui/Window.lua
local UI = {}
local Bot = _G.IslandsBot
local State = Bot.State

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Limpeza caso o script seja reinjetado
if CoreGui:FindFirstChild("IslandsCustomUI") then
    CoreGui.IslandsCustomUI:Destroy()
end

-- ================= INSTÂNCIA PRINCIPAL DA UI =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "IslandsCustomUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Janela Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 320)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Ativa o arrastar nativo
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Barra de Topo
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

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

-- Label de Status Geral
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

-- ================= MENU LATERAL (ABAS) =================
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 110, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 2)
SidebarLayout.Parent = Sidebar

-- Conteiner das Páginas
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -115, 1, -45)
ContentContainer.Position = UDim2.new(0, 115, 0, 40)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local Paginas = {}
local BotoesAba = {}

local function CriarAba(nome, id)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BorderSizePixel = 0
    btn.Text = nome
    btn.TextColor3 = Color3.fromRGB(160, 160, 160)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = Sidebar
    
    local pg = Instance.new("Frame")
    pg.Size = UDim2.new(1, 0, 1, 0)
    pg.BackgroundTransparency = 1
    pg.Visible = false
    pg.Parent = ContentContainer
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = pg
    
    Paginas[id] = pg
    BotoesAba[id] = btn
    
    btn.MouseButton1Click:Connect(function()
        for k, v in pairs(Paginas) do v.Visible = (k == id) end
        for k, v in pairs(BotoesAba) do 
            v.TextColor3 = (k == id) and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(160, 160, 160)
            v.BackgroundColor3 = (k == id) and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(30, 30, 30)
        end
    end)
end

CriarAba("1. Seletor", "seletor")
CriarAba("2. Ações", "acoes")
CriarAba("3. Fazenda", "fazenda")
CriarAba("4. Sistema", "sistema")

-- Ativa a primeira aba por padrão
BotoesAba["seletor"].TextColor3 = Color3.fromRGB(0, 150, 255)
Paginas["seletor"].Visible = true

-- ================= COMPONENTES VISUAIS CUSTOMIZADOS =================
local function CriarBotaoEstilizado(texto, parent, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = texto
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.SourceSansSemibold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.Parent = parent
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = btn
    
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
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = btn
    
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
    mainBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainBtn.Text = labelTexto .. ": Clique p/ Atualizar"
    mainBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    mainBtn.Font = Enum.Font.SourceSansSemibold
    mainBtn.TextSize = 14
    mainBtn.BorderSizePixel = 0
    mainBtn.Parent = frame
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = mainBtn
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 0, 100)
    scroll.Position = UDim2.new(0, 0, 1, 2)
    scroll.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    scroll.BorderSizePixel = 0
    scroll.Visible = false
    scroll.ZIndex = 5
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.Parent = frame
    
    local sLayout = Instance.new("UIListLayout")
    sLayout.Parent = scroll
    
    mainBtn.MouseButton1Click:Connect(function()
        scroll.Visible = not scroll.Visible
    end)
    
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

-- ================= CONSTRUTOR ABA 1: SELETOR ESPACIAL =================
local p1 = Paginas["seletor"]

CriarBotaoEstilizado("🟦 Gerar Cubo Azul no Personagem", p1, function()
    if Bot.Modules.Scanner then Bot.Modules.Scanner:CriarSeletorFrontal() end
end)

-- SEÇÃO DIREÇÃO NO FORMATO COMPACTO PEDIDO!
local PadSection = Instance.new("Frame")
PadSection.Size = UDim2.new(1, -10, 0, 110)
PadSection.BackgroundTransparency = 1
PadSection.Parent = p1

local PadLabel = Instance.new("TextLabel")
PadLabel.Size = UDim2.new(1, 0, 0, 20)
PadLabel.BackgroundTransparency = 1
PadLabel.Text = "Controle Direcional do Seletor:"
PadLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
PadLabel.Font = Enum.Font.SourceSansBold
PadLabel.TextSize = 13
PadLabel.TextXAlignment = Enum.TextXAlignment.Left
PadLabel.Parent = PadSection

-- O Painel Direcional Físico em Formato de Cruz Compacta
local CrossContainer = Instance.new("Frame")
CrossContainer.Size = UDim2.new(0, 100, 0, 80)
CrossContainer.Position = UDim2.new(0, 10, 0, 25)
CrossContainer.BackgroundTransparency = 1
CrossContainer.Parent = PadSection

local function CriarMiniBotao(texto, x, y, direcao)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 30, 0, 25)
    b.Position = UDim2.new(0, x, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    b.Text = texto
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 14
    b.BorderSizePixel = 0
    b.Parent = CrossContainer
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 3)
    c.Parent = b
    
    b.MouseButton1Click:Connect(function()
        if Bot.Modules.Scanner then Bot.Modules.Scanner:MoverSeletor(direcao) end
    end)
end

-- Posicionamento exato das Setas na Grid Horizontal
CriarMiniBotao("^", 35, 5, "Frente")
CriarMiniBotao("<", 2, 35, "Esquerda")
CriarMiniBotao("v", 35, 35, "Tras")
CriarMiniBotao(">", 68, 35, "Direita")

-- Painel Vertical de Altura do lado das setas
local VerticalContainer = Instance.new("Frame")
VerticalContainer.Size = UDim2.new(0, 120, 0, 80)
VerticalContainer.Position = UDim2.new(0, 160, 0, 25)
VerticalContainer.BackgroundTransparency = 1
VerticalContainer.Parent = PadSection

local function CriarBtnVertical(texto, y, direcao)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 25)
    b.Position = UDim2.new(0, 0, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(45, 55, 65)
    b.Text = texto
    b.TextColor3 = Color3.fromRGB(240, 240, 240)
    b.Font = Enum.Font.SourceSansSemibold
    b.TextSize = 13
    b.BorderSizePixel = 0
    b.Parent = VerticalContainer
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = b
    
    b.MouseButton1Click:Connect(function()
        if Bot.Modules.Scanner then Bot.Modules.Scanner:MoverSeletor(direcao) end
    end)
end

CriarBtnVertical("🔼 Subir Cubo (+3)", 5, "Subir")
CriarBtnVertical("🔽 Descer Cubo (-3)", 35, "Descer")

-- ================= CONSTRUTOR ABA 2: AÇÕES =================
local p2 = Paginas["acoes"]

CriarToggleEstilizado("⛏️ Ativar Loop de Mineração", p2, function(valor)
    if Bot.Modules.Miner then Bot.Modules.Miner:Alternar(valor) end
end)

local DropdownBlocos = CriarDropdownEstilizado("Material de Construção", p2, "BlocoSelecionado")

CriarBotaoEstilizado("🔄 Recarregar Inventário de Blocos", p2, function()
    if Bot.Modules.Manager then
        DropdownBlocos:Refresh(Bot.Modules.Manager:GetInventoryTools("Block"))
    end
end)

CriarBotaoEstilizado("🔨 Preencher Toda a Área Selecionada", p2, function()
    if Bot.Modules.Builder then Bot.Modules.Builder:ColocarAreaMarcada() end
end)

-- ================= CONSTRUTOR ABA 3: FAZENDA =================
local p3 = Paginas["fazenda"]

CriarBotaoEstilizado("🚜 Arar Terra Manualmente", p3, function()
    if Bot.Modules.Farmer then Bot.Modules.Farmer:ArarTerra() end
end)

local DropdownSementes = CriarDropdownEstilizado("Semente de Plantio", p3, "SementeSelecionada")

CriarBotaoEstilizado("🔄 Recarregar Lista de Sementes", p3, function()
    if Bot.Modules.Manager then
        DropdownSementes:Refresh(Bot.Modules.Manager:GetInventoryTools("Seed"))
    end
end)

CriarToggleEstilizado("🟢 Auto-Fazenda Ativa (Ciclo Total)", p3, function(valor)
    if Bot.Modules.Farmer then Bot.Modules.Farmer:AlternarAutoFazenda(valor) end
end)

-- ================= CONSTRUTOR ABA 4: SISTEMA =================
local p4 = Paginas["sistema"]

CriarBotaoEstilizado("❌ Finalizar Bot e Deletar Interface", p4, function()
    if Bot.Modules.Miner then Bot.Modules.Miner:Alternar(false) end
    if Bot.Modules.Farmer then Bot.Modules.Farmer:AlternarAutoFazenda(false) end
    if Bot.Modules.Scanner then Bot.Modules.Scanner:LimparAncora() end
    ScreenGui:Destroy()
end)

return UI