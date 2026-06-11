-- src/ui/Window.lua
local UI = {}
local Bot = _G.IslandsBot
local State = Bot.State

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

if CoreGui:FindFirstChild("IslandsCustomUI") then
    CoreGui.IslandsCustomUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "IslandsCustomUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- ================= ARRASTAR APENAS PELO TOPBAR =================
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TopBar.BorderSizePixel = 0
TopBar.Active = true

local dragToggle = nil
local dragSpeed = 0.1
local dragStart = nil
local startPos = nil

local function updateInput(input)
    local delta = input.Position - dragStart
    local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    TweenService:Create(MainFrame, TweenInfo.new(dragSpeed), {Position = position}):Play()
end

TopBar.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then 
        dragToggle = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragToggle = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragToggle then updateInput(input) end
    end
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

-- ================= REDIMENSIONAR JANELA GERAL =================
local WindowResizeHandle = Instance.new("TextButton", MainFrame)
WindowResizeHandle.Size = UDim2.new(0, 20, 0, 20)
WindowResizeHandle.Position = UDim2.new(1, -20, 1, -20)
WindowResizeHandle.BackgroundTransparency = 1
WindowResizeHandle.Text = "◢"
WindowResizeHandle.TextColor3 = Color3.fromRGB(150, 150, 150)
WindowResizeHandle.TextSize = 16
WindowResizeHandle.ZIndex = 10

local draggingWindow = false
local winDragStartPos = nil
local winStartSize = nil

WindowResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingWindow = true
        winDragStartPos = input.Position
        winStartSize = MainFrame.AbsoluteSize
    end
end)

-- ================= MENU LATERAL E DIVISÓRIA =================
local SidebarWidth = 110

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, SidebarWidth, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Sidebar.BorderSizePixel = 0

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 10)

local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.Size = UDim2.new(1, -(SidebarWidth + 5), 1, -35)
ContentContainer.Position = UDim2.new(0, SidebarWidth + 5, 0, 35)
ContentContainer.BackgroundTransparency = 1

local SidebarResizer = Instance.new("TextButton", MainFrame)
SidebarResizer.Size = UDim2.new(0, 5, 1, -35)
SidebarResizer.Position = UDim2.new(0, SidebarWidth, 0, 35)
SidebarResizer.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
SidebarResizer.BackgroundTransparency = 1
SidebarResizer.Text = ""
SidebarResizer.ZIndex = 10

local draggingSidebar = false
local sidebarDragStartPos = nil
local sidebarStartWidth = nil

SidebarResizer.MouseEnter:Connect(function() SidebarResizer.BackgroundTransparency = 0.5 end)
SidebarResizer.MouseLeave:Connect(function() if not draggingSidebar then SidebarResizer.BackgroundTransparency = 1 end end)

SidebarResizer.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSidebar = true
        sidebarDragStartPos = input.Position.X
        sidebarStartWidth = Sidebar.AbsoluteSize.X
        SidebarResizer.BackgroundTransparency = 0.2
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        if draggingWindow then
            local delta = input.Position - winDragStartPos
            local newWidth = math.max(400, winStartSize.X + delta.X)
            local newHeight = math.max(300, winStartSize.Y + delta.Y)
            MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
        if draggingSidebar then
            local deltaX = input.Position.X - sidebarDragStartPos
            local newWidth = math.clamp(sidebarStartWidth + deltaX, 90, 200)
            
            Sidebar.Size = UDim2.new(0, newWidth, 1, -35)
            SidebarResizer.Position = UDim2.new(0, newWidth, 0, 35)
            ContentContainer.Position = UDim2.new(0, newWidth + 5, 0, 35)
            ContentContainer.Size = UDim2.new(1, -(newWidth + 5), 1, -35)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingWindow = false
        draggingSidebar = false
        SidebarResizer.BackgroundTransparency = 1
    end
end)

-- ================= ABAS =================
local Paginas = {}
local BotoesAba = {}

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
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
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
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        pg.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    Paginas[id] = pg
    BotoesAba[id] = btn
    
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

CriarAba("Seletor", "seletor")
CriarAba("Ações", "acoes")
CriarAba("Fazenda", "fazenda")
CriarAba("Sistema", "sistema")

BotoesAba["seletor"].TextColor3 = Color3.fromRGB(255, 255, 255)
BotoesAba["seletor"].BackgroundColor3 = Color3.fromRGB(0, 100, 200)
BotoesAba["seletor"].UIStroke.Transparency = 0
Paginas["seletor"].Visible = true

-- ================= COMPONENTES RESPONSIVOS =================
local function CriarBotaoEstilizado(texto, parent, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = texto
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.SourceSansSemibold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function CriarToggleEstilizado(texto, parent, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.95, 0, 0, 32)
    frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = " " .. texto
    label.TextColor3 = Color3.fromRGB(210, 210, 210)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 50, 0, 24)
    btn.Position = UDim2.new(1, -50, 0, 4)
    btn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local estado = false
    btn.MouseButton1Click:Connect(function()
        estado = not estado
        btn.Text = estado and "ON" or "OFF"
        btn.BackgroundColor3 = estado and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(180, 50, 50)
        callback(estado)
    end)
end

-- Novo Dropdown Inteligente (Com Suporte a Multi-Seleção e "All")
local function CriarDropdownEstilizado(labelTexto, parent, stateKey, isMulti)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.95, 0, 0, 32)
    frame.BackgroundTransparency = 1
    frame.ZIndex = 2
    
    local mainBtn = Instance.new("TextButton", frame)
    mainBtn.Size = UDim2.new(1, 0, 1, 0)
    mainBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    mainBtn.Text = labelTexto .. ": Clique p/ Atualizar"
    mainBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    mainBtn.Font = Enum.Font.SourceSansSemibold
    mainBtn.TextSize = 14
    mainBtn.BorderSizePixel = 0
    mainBtn.ZIndex = 3
    Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(0, 4)
    
    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1, 0, 0, 120)
    scroll.Position = UDim2.new(0, 0, 1, 2)
    scroll.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    scroll.BorderSizePixel = 0
    scroll.Visible = false
    scroll.ZIndex = 10
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 4
    Instance.new("UIListLayout", scroll)
    
    mainBtn.MouseButton1Click:Connect(function() scroll.Visible = not scroll.Visible end)
    
    -- Inicializa o estado
    Bot.State[stateKey] = isMulti and {["All"] = true} or "Nenhum"
    
    local dropdownObj = {}
    function dropdownObj:Refresh(listaItems)
        for _, old in ipairs(scroll:GetChildren()) do
            if old:IsA("TextButton") then old:Destroy() end
        end
        
        local hTotal = 0
        local itemsToRender = {}
        if isMulti then table.insert(itemsToRender, "All") end
        for _, item in ipairs(listaItems) do table.insert(itemsToRender, item) end
        
        local botoesCriados = {}
        
        local function atualizarMainText()
            if isMulti then
                if Bot.State[stateKey]["All"] then
                    mainBtn.Text = labelTexto .. ": All (Qualquer)"
                else
                    local count = 0
                    for k, v in pairs(Bot.State[stateKey]) do if v then count = count + 1 end end
                    mainBtn.Text = labelTexto .. ": " .. count .. " selecionada(s)"
                end
            else
                mainBtn.Text = labelTexto .. ": " .. tostring(Bot.State[stateKey])
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
            itemBtn.ZIndex = 11
            
            table.insert(botoesCriados, {btn = itemBtn, nome = itemNome})
            hTotal = hTotal + 25
            
            local function applyVisual()
                if isMulti then
                    itemBtn.BackgroundColor3 = Bot.State[stateKey][itemNome] and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(35, 35, 35)
                    itemBtn.TextColor3 = Bot.State[stateKey][itemNome] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
                end
            end
            applyVisual()
            
            itemBtn.MouseButton1Click:Connect(function()
                if isMulti then
                    if itemNome == "All" then
                        Bot.State[stateKey] = {["All"] = true}
                    else
                        Bot.State[stateKey]["All"] = nil
                        Bot.State[stateKey][itemNome] = not Bot.State[stateKey][itemNome]
                        
                        local temAlgum = false
                        for k, v in pairs(Bot.State[stateKey]) do if v then temAlgum = true end end
                        if not temAlgum then Bot.State[stateKey] = {["All"] = true} end
                    end
                    
                    for _, obj in ipairs(botoesCriados) do
                        obj.btn.BackgroundColor3 = Bot.State[stateKey][obj.nome] and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(35, 35, 35)
                        obj.btn.TextColor3 = Bot.State[stateKey][obj.nome] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
                    end
                    atualizarMainText()
                else
                    Bot.State[stateKey] = itemNome
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

-- ================= PREENCHENDO ABA 1: SELETOR =================
local p1 = Paginas["seletor"]
CriarBotaoEstilizado("🟦 Gerar Cubo Azul no Personagem", p1, function()
    if Bot.Modules.Scanner then Bot.Modules.Scanner:CriarSeletorFrontal() end
end)

local PadContainer = Instance.new("Frame", p1)
PadContainer.Size = UDim2.new(0.95, 0, 0, 90)
PadContainer.BackgroundTransparency = 1

local CrossContainer = Instance.new("Frame", PadContainer)
CrossContainer.Size = UDim2.new(0, 100, 0, 80)
CrossContainer.Position = UDim2.new(0, 10, 0, 5)
CrossContainer.BackgroundTransparency = 1

local function CriarMiniBotao(texto, x, y, direcao)
    local b = Instance.new("TextButton", CrossContainer)
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
        if Bot.Modules.Scanner then Bot.Modules.Scanner:MoverSeletor(direcao) end
    end)
end

CriarMiniBotao("^", 35, 5, "Frente")
CriarMiniBotao("<", 2, 35, "Esquerda")
CriarMiniBotao("v", 35, 35, "Tras")
CriarMiniBotao(">", 68, 35, "Direita")

local VerticalContainer = Instance.new("Frame", PadContainer)
VerticalContainer.Size = UDim2.new(1, -125, 0, 80)
VerticalContainer.Position = UDim2.new(0, 120, 0, 5)
VerticalContainer.BackgroundTransparency = 1

local function CriarBtnVertical(texto, y, direcao)
    local b = Instance.new("TextButton", VerticalContainer)
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
        if Bot.Modules.Scanner then Bot.Modules.Scanner:MoverSeletor(direcao) end
    end)
end

CriarBtnVertical("🔼 Subir (+3)", 15, "Subir")
CriarBtnVertical("🔽 Descer (-3)", 45, "Descer")

-- ================= PREENCHENDO ABA 2: AÇÕES =================
local p2 = Paginas["acoes"]
CriarToggleEstilizado("⛏️ Ativar Loop de Mineração", p2, function(v) if Bot.Modules.Miner then Bot.Modules.Miner:Alternar(v) end end)
-- Passamos `false` no final para o Builder (Single Select)
local DropdownBlocos = CriarDropdownEstilizado("Material", p2, "BlocoSelecionado", false)
CriarBotaoEstilizado("🔄 Recarregar Inventário", p2, function()
    if Bot.Modules.Manager then DropdownBlocos:Refresh(Bot.Modules.Manager:GetInventoryTools("Block")) end
end)
CriarBotaoEstilizado("🔨 Preencher Área Selecionada", p2, function()
    if Bot.Modules.Builder then Bot.Modules.Builder:ColocarAreaMarcada() end
end)

-- ================= PREENCHENDO ABA 3: FAZENDA =================
local p3 = Paginas["fazenda"]
CriarBotaoEstilizado("🚜 Arar Terra Manualmente", p3, function() if Bot.Modules.Farmer then Bot.Modules.Farmer:ArarTerra() end end)
-- Passamos `true` no final para o Farmer (Multi Select / All)
local DropdownSementes = CriarDropdownEstilizado("Semente", p3, "SementeSelecionada", true)
CriarBotaoEstilizado("🔄 Recarregar Sementes", p3, function()
    if Bot.Modules.Manager then DropdownSementes:Refresh(Bot.Modules.Manager:GetInventoryTools("Seed")) end
end)
CriarToggleEstilizado("🟢 Auto-Fazenda Ativa", p3, function(v) if Bot.Modules.Farmer then Bot.Modules.Farmer:AlternarAutoFazenda(v) end end)

-- ================= PREENCHENDO ABA 4: SISTEMA =================
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

-- Sistema final de Ocultar/Mostrar com Tecla
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