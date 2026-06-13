-- src/ui/Components.lua
local Components = {}

-- ================= VARIÁVEIS DE TEMA (DESIGN SYSTEM) =================
Components.Theme = {
    CardBG = Color3.fromRGB(32, 32, 32),
    CardStroke = Color3.fromRGB(60, 60, 60),
    ButtonBG = Color3.fromRGB(50, 50, 50),
    ButtonHover = Color3.fromRGB(65, 65, 65),
    AccentBlue = Color3.fromRGB(0, 180, 255),
    ToggleOn = Color3.fromRGB(40, 140, 70),
    ToggleOff = Color3.fromRGB(160, 50, 50),
    TextWhite = Color3.fromRGB(255, 255, 255),
    TextDimmed = Color3.fromRGB(200, 200, 200),
    InputBG = Color3.fromRGB(20, 20, 20),
    PanelBG = Color3.fromRGB(45, 45, 45)
}

Components.layoutOrderGlobal = 0
Components.zIndexGlobal = 1000 
Components.innerOrderGlobal = 0

function Components:ResetOrder()
    self.layoutOrderGlobal = 0
    self.zIndexGlobal = 1000
    self.innerOrderGlobal = 0
end

function Components:GetOrdem() 
    self.layoutOrderGlobal = self.layoutOrderGlobal + 1 
    self.zIndexGlobal = self.zIndexGlobal - 10 
    return self.layoutOrderGlobal, self.zIndexGlobal 
end

function Components:GetInnerOrder() 
    self.innerOrderGlobal = self.innerOrderGlobal + 1 
    return self.innerOrderGlobal 
end

-- ================= CONSTRUTORES DE INTERFACE =================

function Components:CriarCard(titulo, parent)
    local order, baseZ = self:GetOrdem()
    
    local card = Instance.new("Frame", parent)
    card.BackgroundColor3 = self.Theme.CardBG
    card.Size = UDim2.new(0, 240, 0, 0)
    card.LayoutOrder = order
    card.ZIndex = baseZ
    card.ClipsDescendants = false 
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
    
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = self.Theme.CardStroke
    stroke.Thickness = 1
    
    local titleLabel = Instance.new("TextLabel", card)
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "  " .. titulo
    titleLabel.TextColor3 = self.Theme.AccentBlue
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = baseZ + 1

    local div = Instance.new("Frame", card)
    div.Size = UDim2.new(1, 0, 0, 1)
    div.Position = UDim2.new(0, 0, 0, 30)
    div.BackgroundColor3 = self.Theme.CardStroke
    div.BorderSizePixel = 0
    div.ZIndex = baseZ + 1

    local content = Instance.new("Frame", card)
    content.Size = UDim2.new(1, 0, 0, 0)
    content.Position = UDim2.new(0, 0, 0, 31)
    content.BackgroundTransparency = 1
    content.ZIndex = baseZ + 1
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

    return content, baseZ
end

function Components:CriarGridDupla(parent, cardZBase)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(0.95, 0, 0, 32)
    f.BackgroundTransparency = 1
    f.ZIndex = cardZBase + 2
    f.LayoutOrder = self:GetInnerOrder()
    local layout = Instance.new("UIListLayout", f)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 5) 
    return f
end

function Components:CriarGridTripla(parent, cardZBase)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(0.95, 0, 0, 32)
    f.BackgroundTransparency = 1
    f.ZIndex = cardZBase + 2
    f.LayoutOrder = self:GetInnerOrder()
    local layout = Instance.new("UIListLayout", f)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 5)
    return f
end

function Components:CriarBotaoEstilizado(texto, parent, cardZBase, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 32)
    btn.BackgroundColor3 = self.Theme.ButtonBG
    btn.Text = texto
    btn.TextColor3 = self.Theme.TextWhite
    btn.Font = Enum.Font.SourceSansSemibold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.ZIndex = cardZBase + 2
    btn.LayoutOrder = self:GetInnerOrder()
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

function Components:CriarBotaoPequeno(texto, cor, parentRow, cardZBase, callback)
    local b = Instance.new("TextButton", parentRow)
    b.Size = UDim2.new(0.333, -3.3, 1, 0)
    b.BackgroundColor3 = cor
    b.Text = texto
    b.TextColor3 = self.Theme.TextWhite
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 13
    b.ZIndex = cardZBase + 3
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.MouseButton1Click:Connect(callback)
    return b
end

function Components:CriarToggleLargo(texto, parent, stateTable, stateKey, cardZBase, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 34)
    local isAtivo = stateTable[stateKey]
    btn.BackgroundColor3 = isAtivo and self.Theme.ToggleOn or self.Theme.ToggleOff
    btn.Text = "  " .. texto .. (isAtivo and " [ON]" or " [OFF]")
    btn.TextColor3 = self.Theme.TextWhite
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.ZIndex = cardZBase + 2
    btn.LayoutOrder = self:GetInnerOrder()
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function()
        stateTable[stateKey] = not stateTable[stateKey]
        local v = stateTable[stateKey]
        btn.Text = "  " .. texto .. (v and " [ON]" or " [OFF]")
        btn.BackgroundColor3 = v and self.Theme.ToggleOn or self.Theme.ToggleOff
        if callback then callback(v) end
    end)
    return btn
end

function Components:CriarCheckboxMetade(texto, parentRow, stateTable, stateKey, cardZBase, callback)
    local frame = Instance.new("Frame", parentRow)
    frame.Size = UDim2.new(0.5, -2.5, 1, 0)
    frame.BackgroundColor3 = self.Theme.PanelBG
    frame.ZIndex = cardZBase + 3
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 22, 0, 22)
    btn.Position = UDim2.new(0, 5, 0.5, -11)
    local isAtivo = stateTable[stateKey]
    btn.BackgroundColor3 = isAtivo and self.Theme.AccentBlue or self.Theme.CardBG
    btn.Text = isAtivo and "✓" or ""
    btn.TextColor3 = self.Theme.TextWhite
    btn.ZIndex = cardZBase + 4
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -35, 1, 0)
    label.Position = UDim2.new(0, 32, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = texto
    label.TextColor3 = self.Theme.TextWhite
    label.Font = Enum.Font.SourceSansSemibold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = cardZBase + 4
    
    btn.MouseButton1Click:Connect(function()
        stateTable[stateKey] = not stateTable[stateKey]
        local v = stateTable[stateKey]
        btn.BackgroundColor3 = v and self.Theme.AccentBlue or self.Theme.CardBG
        btn.Text = v and "✓" or ""
        if callback then callback(v) end
    end)
    return frame
end

function Components:CriarInputMetade(texto, parentRow, stateTable, stateKey, valDefault, cardZBase)
    local frame = Instance.new("Frame", parentRow)
    frame.Size = UDim2.new(0.5, -2.5, 1, 0)
    frame.BackgroundColor3 = self.Theme.PanelBG
    frame.ZIndex = cardZBase + 3
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = texto
    label.TextColor3 = self.Theme.TextDimmed
    label.Font = Enum.Font.SourceSansSemibold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = cardZBase + 4
    
    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(0.45, 0, 0, 22)
    input.Position = UDim2.new(0.5, 0, 0.5, -11)
    input.BackgroundColor3 = self.Theme.InputBG
    input.Text = tostring(stateTable[stateKey] or valDefault)
    input.TextColor3 = self.Theme.AccentBlue
    input.Font = Enum.Font.SourceSansBold
    input.TextSize = 13
    input.ZIndex = cardZBase + 4
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 4)
    
    input.FocusLost:Connect(function()
        local val = tonumber(input.Text)
        if val then stateTable[stateKey] = val else input.Text = tostring(stateTable[stateKey]) end
    end)
    return input
end

function Components:CriarInputLargo(placeholder, parentRow, cardZBase)
    local input = Instance.new("TextBox", parentRow)
    input.Size = UDim2.new(0.65, -5, 1, 0)
    input.BackgroundColor3 = self.Theme.InputBG
    input.PlaceholderText = "  " .. placeholder
    input.Text = ""
    input.TextColor3 = self.Theme.TextWhite
    input.Font = Enum.Font.SourceSans
    input.TextSize = 13
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.ZIndex = cardZBase + 3
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 4)
    return input
end

-- ================= NOVO: MOLDE PARA ITEM DA LISTA =================
function Components:CriarItemDropdown(texto, isPar, parent, zIndexBase)
    local itemBtn = Instance.new("TextButton", parent)
    itemBtn.Size = UDim2.new(1, 0, 0, 30)
    -- Usa a referência Absoluta de Components para não dar crash de escopo (nil value)
    itemBtn.BackgroundColor3 = isPar and Components.Theme.PanelBG or Components.Theme.CardBG
    itemBtn.BorderSizePixel = 0
    itemBtn.Text = "   " .. texto
    itemBtn.TextColor3 = Components.Theme.TextWhite
    itemBtn.Font = Enum.Font.SourceSans
    itemBtn.TextSize = 13
    itemBtn.TextXAlignment = Enum.TextXAlignment.Left
    itemBtn.ZIndex = zIndexBase
    return itemBtn
end

function Components:CriarDropdown(labelTexto, parent, stateTable, stateKey, isMulti, cardZBase, hasSearch)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.95, 0, 0, 32)
    frame.BackgroundTransparency = 1
    frame.ZIndex = cardZBase + 2
    frame.LayoutOrder = self:GetInnerOrder()
    
    local mainBtn = Instance.new("TextButton", frame)
    mainBtn.Size = UDim2.new(1, 0, 1, 0)
    mainBtn.BackgroundColor3 = self.Theme.ButtonBG
    mainBtn.Text = "  " .. labelTexto .. ": Atualizar"
    mainBtn.TextColor3 = self.Theme.TextWhite
    mainBtn.Font = Enum.Font.SourceSansSemibold
    mainBtn.TextSize = 14
    mainBtn.TextXAlignment = Enum.TextXAlignment.Left
    mainBtn.BorderSizePixel = 0
    mainBtn.ZIndex = cardZBase + 3
    Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(0, 4)
    
    local icone = Instance.new("TextLabel", mainBtn)
    icone.Size = UDim2.new(0, 20, 1, 0)
    icone.Position = UDim2.new(1, -25, 0, 0)
    icone.BackgroundTransparency = 1
    icone.Text = "▼"
    icone.TextColor3 = self.Theme.TextDimmed
    icone.ZIndex = cardZBase + 4
    
    local dropdownContainer = Instance.new("TextButton", frame)
    dropdownContainer.Text = ""
    dropdownContainer.AutoButtonColor = false
    dropdownContainer.Size = UDim2.new(1, 0, 0, 180)
    dropdownContainer.Position = UDim2.new(0, 0, 1, 3)
    dropdownContainer.BackgroundColor3 = self.Theme.InputBG
    dropdownContainer.BorderSizePixel = 0
    dropdownContainer.Visible = false
    dropdownContainer.ZIndex = cardZBase + 10 
    dropdownContainer.Active = true 
    Instance.new("UICorner", dropdownContainer).CornerRadius = UDim.new(0, 4)
    
    local searchBox = nil
    local yOffsetScroll = 0
    if hasSearch then
        searchBox = Instance.new("TextBox", dropdownContainer)
        searchBox.Size = UDim2.new(1, -10, 0, 25)
        searchBox.Position = UDim2.new(0, 5, 0, 5)
        searchBox.BackgroundColor3 = self.Theme.PanelBG
        searchBox.PlaceholderText = "Pesquisar..."
        searchBox.Text = ""
        searchBox.TextColor3 = self.Theme.TextWhite
        searchBox.Font = Enum.Font.SourceSans
        searchBox.TextSize = 13
        searchBox.ZIndex = cardZBase + 11
        Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 4)
        yOffsetScroll = 35
    end
    
    local scroll = Instance.new("ScrollingFrame", dropdownContainer)
    scroll.Size = UDim2.new(1, 0, 1, -yOffsetScroll)
    scroll.Position = UDim2.new(0, 0, 0, yOffsetScroll)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ZIndex = cardZBase + 11
    scroll.ScrollBarThickness = 5
    scroll.Active = true
    Instance.new("UIListLayout", scroll).SortOrder = Enum.SortOrder.LayoutOrder
    
    mainBtn.MouseButton1Click:Connect(function() 
        dropdownContainer.Visible = not dropdownContainer.Visible 
        if searchBox and dropdownContainer.Visible then searchBox.Text = "" end
    end)
    
    if isMulti and not stateTable[stateKey] then stateTable[stateKey] = {["All"] = true} end
    
    local dropdownObj = {}
    local todosBotoes = {}
    
    function dropdownObj:Refresh(listaItems)
        if type(listaItems) ~= "table" then listaItems = {} end
        for _, old in ipairs(scroll:GetChildren()) do if old:IsA("TextButton") then old:Destroy() end end
        todosBotoes = {}
        
        local itemsToRender = {}
        if isMulti then table.insert(itemsToRender, "All") end
        
        for _, item in ipairs(listaItems) do 
            if item ~= "Nenhuma Ferramenta Equipada" and item ~= "Ainda não carregou / Vazio" then
                table.insert(itemsToRender, item) 
            end
        end

        local function atualizarMainText()
            if isMulti then
                if stateTable[stateKey]["All"] then mainBtn.Text = "  " .. labelTexto .. ": All"
                else
                    local count = 0
                    for k, v in pairs(stateTable[stateKey]) do if v and k ~= "Nenhum Encontrado" then count = count + 1 end end
                    mainBtn.Text = "  " .. labelTexto .. ": " .. count .. " itens sel."
                end
            else
                mainBtn.Text = "  " .. labelTexto .. ": " .. tostring(stateTable[stateKey] or "Nenhum")
            end
        end
        
        for i, itemNome in ipairs(itemsToRender) do
            -- AQUI ESTÁ A CORREÇÃO: Chama o Molde que criámos acima (Fim dos botões com erro de ZIndex 1!)
            local itemBtn = Components:CriarItemDropdown(itemNome, i%2==0, scroll, cardZBase + 12)
            
            table.insert(todosBotoes, {btn = itemBtn, nome = itemNome, bg = itemBtn.BackgroundColor3})
            
            local function applyVisual()
                if isMulti then
                    if stateTable[stateKey][itemNome] then
                        itemBtn.BackgroundColor3 = Components.Theme.AccentBlue
                        itemBtn.TextColor3 = Components.Theme.TextWhite
                    else
                        itemBtn.BackgroundColor3 = itemBtn.bg
                        itemBtn.TextColor3 = Components.Theme.TextWhite
                    end
                end
            end
            applyVisual()
            
            itemBtn.MouseButton1Click:Connect(function()
                if itemNome == "Nenhum Encontrado" then return end

                if isMulti then
                    if itemNome == "All" then stateTable[stateKey] = {["All"] = true}
                    else
                        stateTable[stateKey]["All"] = nil
                        stateTable[stateKey][itemNome] = not stateTable[stateKey][itemNome]
                    end
                    for _, obj in ipairs(todosBotoes) do
                        if stateTable[stateKey][obj.nome] then
                            obj.btn.BackgroundColor3 = Components.Theme.AccentBlue
                        else
                            obj.btn.BackgroundColor3 = obj.bg
                        end
                    end
                    atualizarMainText()
                else
                    stateTable[stateKey] = itemNome
                    atualizarMainText()
                    dropdownContainer.Visible = false
                end
            end)
        end
        
        local function renderizarBusca()
            local termo = searchBox and searchBox.Text:lower() or ""
            local hTotal = 0
            for _, obj in ipairs(todosBotoes) do
                if termo == "" or obj.nome:lower():match(termo) then
                    obj.btn.Visible = true
                    hTotal = hTotal + 30
                else
                    obj.btn.Visible = false
                end
            end
            scroll.CanvasSize = UDim2.new(0, 0, 0, hTotal)
        end
        
        if searchBox then searchBox:GetPropertyChangedSignal("Text"):Connect(renderizarBusca) end
        renderizarBusca()
        atualizarMainText()
    end

    dropdownObj:Refresh({}) 
    return dropdownObj
end

function Components:CriarControlesEspaciais(parentCard, cardZBase, scannerName)
    local Bot = _G.IslandsBot
    local State = Bot.State

    local container = Instance.new("Frame", parentCard)
    container.Size = UDim2.new(0.95, 0, 0, 100)
    container.BackgroundColor3 = self.Theme.InputBG
    container.ZIndex = cardZBase + 2
    container.LayoutOrder = self:GetInnerOrder()
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
    
    local dpad = Instance.new("Frame", container)
    dpad.Size = UDim2.new(0, 80, 0, 80)
    dpad.Position = UDim2.new(0, 10, 0, 10)
    dpad.BackgroundTransparency = 1
    dpad.ZIndex = cardZBase + 3
    
    local function CriarSetinha(texto, x, y, direcao)
        local btn = Instance.new("TextButton", dpad)
        btn.Size = UDim2.new(0, 26, 0, 26)
        btn.Position = UDim2.new(0, x, 0, y)
        btn.BackgroundColor3 = self.Theme.CardStroke
        btn.Text = texto
        btn.TextColor3 = self.Theme.TextWhite
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 14
        btn.ZIndex = cardZBase + 4
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
    vertPanel.ZIndex = cardZBase + 3
    
    local layout = Instance.new("UIListLayout", vertPanel)
    layout.Padding = UDim.new(0, 8)
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    
    local function CriarAcaoVert(texto, direcao)
        local btn = Instance.new("TextButton", vertPanel)
        btn.Size = UDim2.new(1, 0, 0, 34)
        btn.BackgroundColor3 = self.Theme.AccentBlue
        btn.Text = texto
        btn.TextColor3 = self.Theme.TextWhite
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 13
        btn.ZIndex = cardZBase + 4
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.MouseButton1Click:Connect(function() if State[scannerName] then State[scannerName]:MoverSeletor(direcao) end end)
    end
    CriarAcaoVert("🔼 Subir Seletor", "Subir")
    CriarAcaoVert("🔽 Descer Seletor", "Descer")
end

return Components