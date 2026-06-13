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
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 650, 0, 500) 
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

State.HideKey = Enum.KeyCode.V
State.IsListeningForKey = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed and not State.IsListeningForKey then return end
    if State.IsListeningForKey and input.UserInputType == Enum.UserInputType.Keyboard then
        State.HideKey = input.KeyCode
        State.IsListeningForKey = false
        if State.UpdateKeybindButton then State.UpdateKeybindButton() end
        return
    end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == State.HideKey then
        if ScreenGui:FindFirstChild("MainFrame") then
            ScreenGui.MainFrame.Visible = not ScreenGui.MainFrame.Visible
        end
    end
end)

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TopBar.BorderSizePixel = 0
TopBar.Active = true
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local TopBarBase = Instance.new("Frame", TopBar)
TopBarBase.Size = UDim2.new(1, 0, 0, 8)
TopBarBase.Position = UDim2.new(0, 0, 1, -8)
TopBarBase.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TopBarBase.BorderSizePixel = 0

local dragToggle, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1) then 
        dragToggle = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragToggle = false end end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragToggle then
        local delta = input.Position - dragStart
        TweenService:Create(MainFrame, TweenInfo.new(0.1), {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}):Play()
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
    if draggingWindow and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - winDragStartPos
        MainFrame.Size = UDim2.new(0, math.max(550, winStartSize.X + delta.X), 0, math.max(400, winStartSize.Y + delta.Y))
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
Sidebar.Size = UDim2.new(0, 140, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Sidebar.BorderSizePixel = 0

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 10)

local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.Size = UDim2.new(1, -140, 1, -35)
ContentContainer.Position = UDim2.new(0, 140, 0, 35)
ContentContainer.BackgroundTransparency = 1

local Paginas, BotoesAba = {}, {}
local function CriarAba(nome, id)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(0.9, 0, 0, 34)
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
    pg.ScrollBarThickness = 5
    pg.Visible = false
    pg.ClipsDescendants = false
    
    local layout = Instance.new("UIListLayout", pg)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Wraps = true
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local padding = Instance.new("UIPadding", pg)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 180)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        pg.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 200)
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

local layoutOrderGlobal = 0
local function GetOrdem() layoutOrderGlobal = layoutOrderGlobal + 1 return layoutOrderGlobal end

local function CriarCard(titulo, parent, zIndexCard)
    local card = Instance.new("Frame", parent)
    card.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    card.Size = UDim2.new(0, 240, 0, 0)
    card.LayoutOrder = GetOrdem()
    card.ZIndex = zIndexCard or 1
    card.ClipsDescendants = false
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
    
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = Color3.fromRGB(60, 60, 60)
    stroke.Thickness = 1
    
    local titleLabel = Instance.new("TextLabel", card)
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "  " .. titulo
    titleLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = card.ZIndex

    local div = Instance.new("Frame", card)
    div.Size = UDim2.new(1, 0, 0, 1)
    div.Position = UDim2.new(0, 0, 0, 30)
    div.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    div.BorderSizePixel = 0
    div.ZIndex = card.ZIndex

    local content = Instance.new("Frame", card)
    content.Size = UDim2.new(1, 0, 0, 0)
    content.Position = UDim2.new(0, 0, 0, 31)
    content.BackgroundTransparency = 1
    content.ZIndex = card.ZIndex
    content.ClipsDescendants = false

    local cLayout = Instance.new("UIListLayout", content)
    cLayout.Padding = UDim.new(0, 8)
    cLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    cLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local pad = Instance.new("UIPadding", content)
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)

    cLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.Size = UDim2.new(1, 0, 0, cLayout.AbsoluteContentSize.Y + 20)
        card.Size = UDim2.new(0, 240, 0, 31 + content.Size.Y.Offset)
    end)

    return content, card.ZIndex
end

local function CriarGridDupla(parent, zBase)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(0.95, 0, 0, 32)
    f.BackgroundTransparency = 1
    f.LayoutOrder = GetOrdem()
    f.ZIndex = zBase
    local layout = Instance.new("UIListLayout", f)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 5) 
    return f
end

local function CriarGridTripla(parent, zBase)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(0.95, 0, 0, 32)
    f.BackgroundTransparency = 1
    f.LayoutOrder = GetOrdem()
    f.ZIndex = zBase
    local layout = Instance.new("UIListLayout", f)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 5)
    return f
end

local function CriarBotaoEstilizado(texto, parent, zBase, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = texto
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.SourceSansSemibold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.LayoutOrder = GetOrdem()
    btn.ZIndex = zBase + 1
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function CriarToggleLargo(texto, parent, stateTable, stateKey, zBase, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 34)
    btn.LayoutOrder = GetOrdem()
    local isAtivo = stateTable[stateKey]
    btn.BackgroundColor3 = isAtivo and Color3.fromRGB(40, 140, 70) or Color3.fromRGB(160, 50, 50)
    btn.Text = "  " .. texto .. (isAtivo and " [ON]" or " [OFF]")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.ZIndex = zBase + 1
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(function()
        stateTable[stateKey] = not stateTable[stateKey]
        local v = stateTable[stateKey]
        btn.Text = "  " .. texto .. (v and " [ON]" or " [OFF]")
        btn.BackgroundColor3 = v and Color3.fromRGB(40, 140, 70) or Color3.fromRGB(160, 50, 50)
        if callback then callback(v) end
    end)
end

local function CriarCheckboxMetade(texto, parentRow, stateTable, stateKey, zBase, callback)
    local frame = Instance.new("Frame", parentRow)
    frame.Size = UDim2.new(0.5, -2.5, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    frame.ZIndex = zBase + 1
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 22, 0, 22)
    btn.Position = UDim2.new(0, 5, 0.5, -11)
    local isAtivo = stateTable[stateKey]
    btn.BackgroundColor3 = isAtivo and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(30, 30, 30)
    btn.Text = isAtivo and "✓" or ""
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.ZIndex = zBase + 2
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -35, 1, 0)
    label.Position = UDim2.new(0, 32, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = texto
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.Font = Enum.Font.SourceSansSemibold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = zBase + 2
    
    btn.MouseButton1Click:Connect(function()
        stateTable[stateKey] = not stateTable[stateKey]
        local v = stateTable[stateKey]
        btn.BackgroundColor3 = v and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(30, 30, 30)
        btn.Text = v and "✓" or ""
        if callback then callback(v) end
    end)
end

local function CriarInputMetade(texto, parentRow, stateTable, stateKey, valDefault, zBase)
    local frame = Instance.new("Frame", parentRow)
    frame.Size = UDim2.new(0.5, -2.5, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    frame.ZIndex = zBase + 1
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = texto
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.SourceSansSemibold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = zBase + 2
    
    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(0.45, 0, 0, 22)
    input.Position = UDim2.new(0.5, 0, 0.5, -11)
    input.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    input.Text = tostring(stateTable[stateKey] or valDefault)
    input.TextColor3 = Color3.fromRGB(0, 180, 255)
    input.Font = Enum.Font.SourceSansBold
    input.TextSize = 13
    input.ZIndex = zBase + 2
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 4)
    
    input.FocusLost:Connect(function()
        local val = tonumber(input.Text)
        if val then stateTable[stateKey] = val else input.Text = tostring(stateTable[stateKey]) end
    end)
end

local function CriarDropdown(labelTexto, parent, stateTable, stateKey, isMulti, zBase)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.95, 0, 0, 32)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = GetOrdem()
    frame.ZIndex = zBase
    
    local mainBtn = Instance.new("TextButton", frame)
    mainBtn.Size = UDim2.new(1, 0, 1, 0)
    mainBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    mainBtn.Text = "  " .. labelTexto .. ": Atualizar"
    mainBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
    mainBtn.Font = Enum.Font.SourceSansSemibold
    mainBtn.TextSize = 14
    mainBtn.TextXAlignment = Enum.TextXAlignment.Left
    mainBtn.BorderSizePixel = 0
    mainBtn.ZIndex = zBase + 1
    Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(0, 4)
    
    local icone = Instance.new("TextLabel", mainBtn)
    icone.Size = UDim2.new(0, 20, 1, 0)
    icone.Position = UDim2.new(1, -25, 0, 0)
    icone.BackgroundTransparency = 1
    icone.Text = "▼"
    icone.TextColor3 = Color3.fromRGB(200, 200, 200)
    icone.ZIndex = zBase + 1
    
    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1, 0, 0, 150)
    scroll.Position = UDim2.new(0, 0, 1, 3)
    scroll.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    scroll.BorderSizePixel = 0
    scroll.Visible = false
    scroll.ZIndex = zBase + 10
    scroll.ScrollBarThickness = 5
    Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 4)
    Instance.new("UIListLayout", scroll).SortOrder = Enum.SortOrder.LayoutOrder
    
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
                if stateTable[stateKey]["All"] then mainBtn.Text = "  " .. labelTexto .. ": All"
                else
                    local count = 0
                    for k, v in pairs(stateTable[stateKey]) do if v then count = count + 1 end end
                    mainBtn.Text = "  " .. labelTexto .. ": " .. count .. " itens sel."
                end
            else
                mainBtn.Text = "  " .. labelTexto .. ": " .. tostring(stateTable[stateKey] or "Nenhum")
            end
        end
        
        for i, itemNome in ipairs(itemsToRender) do
            local itemBtn = Instance.new("TextButton", scroll)
            itemBtn.Size = UDim2.new(1, 0, 0, 30)
            itemBtn.BackgroundColor3 = (i%2==0) and Color3.fromRGB(45, 45, 45) or Color3.fromRGB(40, 40, 40)
            itemBtn.BorderSizePixel = 0
            itemBtn.Text = "   " .. itemNome
            itemBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
            itemBtn.Font = Enum.Font.SourceSans
            itemBtn.TextSize = 13
            itemBtn.TextXAlignment = Enum.TextXAlignment.Left
            itemBtn.ZIndex = zBase + 11
            table.insert(botoesCriados, {btn = itemBtn, nome = itemNome, bg = itemBtn.BackgroundColor3})
            hTotal = hTotal + 30
            
            local function applyVisual()
                if isMulti then
                    if stateTable[stateKey][itemNome] then
                        itemBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
                        itemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    else
                        itemBtn.BackgroundColor3 = itemBtn.bg
                        itemBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
                    end
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
                        if stateTable[stateKey][obj.nome] then
                            obj.btn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
                            obj.btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                        else
                            obj.btn.BackgroundColor3 = obj.bg
                            obj.btn.TextColor3 = Color3.fromRGB(230, 230, 230)
                        end
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

local function CriarControlesEspaciais(parentCard, zBase, scannerName)
    local container = Instance.new("Frame", parentCard)
    container.Size = UDim2.new(0.95, 0, 0, 100)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    container.LayoutOrder = GetOrdem()
    container.ZIndex = zBase
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
    
    local dpad = Instance.new("Frame", container)
    dpad.Size = UDim2.new(0, 80, 0, 80)
    dpad.Position = UDim2.new(0, 10, 0, 10)
    dpad.BackgroundTransparency = 1
    dpad.ZIndex = zBase
    
    local function CriarSetinha(texto, x, y, direcao)
        local btn = Instance.new("TextButton", dpad)
        btn.Size = UDim2.new(0, 26, 0, 26)
        btn.Position = UDim2.new(0, x, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        btn.Text = texto
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 14
        btn.ZIndex = zBase + 1
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.MouseButton1Click:Connect(function() if State[scannerName] then State[scannerName]:MoverSeletor(direcao) end end)
    end
    
    CriarSetinha("^", 27, 0, "Frente")
    CriarSetinha("v", 27, 54, "Tras")
    CriarSetinha("<", 0, 27, "Esquerda")
    CriarSetinha(">", 54, 27, "Direita")
    
    local vertPanel = Instance.new("Frame", container)
    vertPanel.Size = UDim2.new(1, -100, 1, -20)
    vertPanel.Position = UDim2.new(0, 95, 0, 10)
    vertPanel.BackgroundTransparency = 1
    vertPanel.ZIndex = zBase
    
    local layout = Instance.new("UIListLayout", vertPanel)
    layout.Padding = UDim.new(0, 8)
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    
    local function CriarAcaoVert(texto, direcao)
        local btn = Instance.new("TextButton", vertPanel)
        btn.Size = UDim2.new(1, 0, 0, 34)
        btn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
        btn.Text = texto
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 13
        btn.ZIndex = zBase + 1
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.MouseButton1Click:Connect(function() if State[scannerName] then State[scannerName]:MoverSeletor(direcao) end end)
    end
    CriarAcaoVert("🔼 Subir Seletor", "Subir")
    CriarAcaoVert("🔽 Descer Seletor", "Descer")
end

-- ================= PREENCHENDO ABA 3: FAZENDA =================
local p3 = Paginas["fazenda"]

local cFarm, zFarm = CriarCard("MAIN FARM", p3, 100)
CriarToggleLargo("Start Farm", cFarm, State, "AutoFarmingCrops", zFarm, function(v) if Bot.Modules.Farmer then Bot.Modules.Farmer:AlternarAutoFazenda(v) end end)
local rFarm1 = CriarGridDupla(cFarm, zFarm)
CriarCheckboxMetade("Plow Grass", rFarm1, State.FarmSettings, "PlowGrass", zFarm)
CriarCheckboxMetade("Place Grass", rFarm1, State.FarmSettings, "PlaceGrass", zFarm)
local rFarm2 = CriarGridDupla(cFarm, zFarm)
CriarCheckboxMetade("Auto Replace", rFarm2, State.FarmSettings, "AutoReplace", zFarm)

local cSeed, zSeed = CriarCard("SEED SELECT", p3, 90) 
local DropdownSementes = CriarDropdown("Lista Sementes", cSeed, State, "SementeSelecionada", true, 95)
local PriorizeDropdown = CriarDropdown("Priorize Plant", cSeed, State.FarmSettings, "PrioritizePlant", false, 90)
CriarBotaoEstilizado("🔄 Atualizar Mochila", cSeed, 90, function()
    if Bot.Modules.Manager then 
        local inv = Bot.Modules.Manager:GetInventoryTools("Seed")
        DropdownSementes:Refresh(inv)
        PriorizeDropdown:Refresh(inv)
    end
end)

local cDelay, zDelay = CriarCard("CONFIG & DELAY", p3, 80)
local rDelay1 = CriarGridDupla(cDelay, zDelay)
CriarInputMetade("Harvest:", rDelay1, State.FarmSettings, "HarvestDelay", 0.1, zDelay)
CriarInputMetade("Plant:", rDelay1, State.FarmSettings, "PlantDelay", 0.15, zDelay)
local rDelay2 = CriarGridDupla(cDelay, zDelay)
CriarCheckboxMetade("Tween/Voo", rDelay2, State.FarmSettings, "TweenToTarget", zDelay)
CriarInputMetade("Vel. Voo:", rDelay2, State.FarmSettings, "TweenSpeed", 20, zDelay)
local rDelay3 = CriarGridDupla(cDelay, zDelay)
CriarCheckboxMetade("Esconder Nums", rDelay3, State, "HideNumbers", zDelay, function()
    if State.ScannerFazenda then State.ScannerFazenda:EscanearArea() end
end)

local cSave, zSave = CriarCard("SELECTOR & SAVES", p3, 70)
-- O Botão Modificado para Ligar/Desligar Visualmente
CriarBotaoEstilizado("🟩 Ligar/Desligar Cubo Verde", cSave, zSave, function() if State.ScannerFazenda then State.ScannerFazenda:CriarSeletorFrontal() end end)
CriarControlesEspaciais(cSave, zSave, "ScannerFazenda")

local rSaveNome = Instance.new("Frame", cSave)
rSaveNome.Size = UDim2.new(0.95, 0, 0, 32)
rSaveNome.BackgroundTransparency = 1
rSaveNome.LayoutOrder = GetOrdem()
rSaveNome.ZIndex = zSave

local inputPlot = Instance.new("TextBox", rSaveNome)
inputPlot.Size = UDim2.new(0.65, -5, 1, 0)
inputPlot.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
inputPlot.PlaceholderText = "  Nome do seu novo Plot..."
inputPlot.Text = ""
inputPlot.TextColor3 = Color3.fromRGB(255, 255, 255)
inputPlot.Font = Enum.Font.SourceSans
inputPlot.TextSize = 13
inputPlot.TextXAlignment = Enum.TextXAlignment.Left
inputPlot.ZIndex = zSave + 1
Instance.new("UICorner", inputPlot).CornerRadius = UDim.new(0, 4)

local btnSavePlot = Instance.new("TextButton", rSaveNome)
btnSavePlot.Size = UDim2.new(0.35, 0, 1, 0)
btnSavePlot.Position = UDim2.new(0.65, 5, 0, 0)
btnSavePlot.BackgroundColor3 = Color3.fromRGB(0, 160, 220)
btnSavePlot.Text = "💾 Salvar"
btnSavePlot.TextColor3 = Color3.fromRGB(255, 255, 255)
btnSavePlot.Font = Enum.Font.SourceSansBold
btnSavePlot.TextSize = 13
btnSavePlot.ZIndex = zSave + 1
Instance.new("UICorner", btnSavePlot).CornerRadius = UDim.new(0, 4)

local plotDropdown = CriarDropdown("Selecionar Save", cSave, State.FarmSettings, "CurrentSaveName", false, zSave - 5)

local function AtualizarListaSaves()
    if Bot.Modules.PlotManager and plotDropdown then
        local plots = Bot.Modules.PlotManager:ObterTodos()
        local lista = {}
        for nome, _ in pairs(plots) do table.insert(lista, nome) end
        if #lista == 0 then lista = {"Nenhum"} end
        plotDropdown:Refresh(lista)
    end
end

btnSavePlot.MouseButton1Click:Connect(function()
    local cubo = State.ScannerFazenda and State.ScannerFazenda.AncoraPart
    if inputPlot.Text ~= "" and cubo then
        Bot.Modules.PlotManager:SalvarPlot(inputPlot.Text, cubo.Position, cubo.Size)
        AtualizarListaSaves()
        inputPlot.Text = ""
    end
end)

local rAcoes = CriarGridTripla(cSave, zSave)
local function CriarAcaoBotao(texto, cor, parentRow, zBase, callback)
    local b = Instance.new("TextButton", parentRow)
    b.Size = UDim2.new(0.333, -3.3, 1, 0)
    b.BackgroundColor3 = cor
    b.Text = texto
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 13
    b.ZIndex = zBase + 1
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.MouseButton1Click:Connect(callback)
end

CriarAcaoBotao("Load", Color3.fromRGB(40, 150, 80), rAcoes, zSave, function()
    local sn = State.FarmSettings.CurrentSaveName
    if sn and sn ~= "Nenhum" then
        local p = Bot.Modules.PlotManager:ObterTodos()[sn]
        if p and State.ScannerFazenda then State.ScannerFazenda:CarregarPlot(Vector3.new(p.PosX, p.PosY, p.PosZ), Vector3.new(p.SizeX, p.SizeY, p.SizeZ)) end
    end
end)
CriarAcaoBotao("Rewrite", Color3.fromRGB(200, 120, 20), rAcoes, zSave, function()
    local sn = State.FarmSettings.CurrentSaveName
    local cubo = State.ScannerFazenda and State.ScannerFazenda.AncoraPart
    if sn and sn ~= "Nenhum" and cubo then Bot.Modules.PlotManager:SalvarPlot(sn, cubo.Position, cubo.Size) end
end)
CriarAcaoBotao("Delete", Color3.fromRGB(200, 50, 50), rAcoes, zSave, function()
    local sn = State.FarmSettings.CurrentSaveName
    if sn and sn ~= "Nenhum" then
        Bot.Modules.PlotManager:DeletarPlot(sn)
        State.FarmSettings.CurrentSaveName = "Nenhum"
        AtualizarListaSaves()
    end
end)

local rSave2 = CriarGridDupla(cSave, zSave)
CriarCheckboxMetade("Auto Load Start", rSave2, State.FarmSettings, "AutoUseSelectedSave", zSave)

task.spawn(function() task.wait(1); AtualizarListaSaves() end)

-- ================= ABA 1: GERAL =================
local p1 = Paginas["seletor"]
local cMiner, zMiner = CriarCard("MINER & BUILDER", p1, 100)
CriarToggleLargo("Auto Minerar", cMiner, State, "Minerando", zMiner, function(v) if Bot.Modules.Miner then Bot.Modules.Miner:Alternar(v) end end)
local DropdownBlocos = CriarDropdown("Material de Construção", cMiner, State, "BlocoSelecionado", false, 95)
CriarBotaoEstilizado("🔄 Carregar Mochila", cMiner, zMiner, function() if Bot.Modules.Manager then DropdownBlocos:Refresh(Bot.Modules.Manager:GetInventoryTools("Block")) end end)
CriarBotaoEstilizado("🔨 Preencher Área do Seletor", cMiner, zMiner, function() if Bot.Modules.Builder then Bot.Modules.Builder:ColocarAreaMarcada() end end)

local cSelAzul, zSelAzul = CriarCard("SELETOR AZUL", p1, 90)
-- O Botão Modificado para Ligar/Desligar Visualmente
CriarBotaoEstilizado("🟦 Ligar/Desligar Cubo Azul", cSelAzul, zSelAzul, function() if State.ScannerGeral then State.ScannerGeral:CriarSeletorFrontal() end end)
CriarControlesEspaciais(cSelAzul, zSelAzul, "ScannerGeral")

-- ================= ABA 4: SISTEMA =================
local p4 = Paginas["sistema"]
local cSys, zSys = CriarCard("CONFIGURAÇÕES DO BOT", p4, 100)

local btnKeybind = CriarBotaoEstilizado("⌨️ Tecla Ocultar UI: V", cSys, zSys, function() end)
btnKeybind.MouseButton1Click:Connect(function()
    State.IsListeningForKey = true
    btnKeybind.Text = "⌨️ Pressione uma tecla..."
    btnKeybind.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
end)
State.UpdateKeybindButton = function()
    btnKeybind.Text = "⌨️ Tecla Ocultar UI: " .. State.HideKey.Name
    btnKeybind.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
end

CriarBotaoEstilizado("❌ Fechar Bot de Forma Segura", cSys, zSys, function()
    if Bot.Modules.Miner then Bot.Modules.Miner:Alternar(false) end
    if Bot.Modules.Farmer then Bot.Modules.Farmer:AlternarAutoFazenda(false) end
    if State.ScannerGeral then State.ScannerGeral:LimparAncora() end
    if State.ScannerFazenda then State.ScannerFazenda:LimparAncora() end
    ScreenGui:Destroy()
end)

return UI