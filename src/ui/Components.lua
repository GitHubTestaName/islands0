-- src/ui/Components.lua
local Components = {}

Components.Theme = {
    CardBG = Color3.fromRGB(32, 32, 32),
    CardStroke = Color3.fromRGB(60, 60, 60),
    ButtonBG = Color3.fromRGB(50, 50, 50),
    ButtonHover = Color3.fromRGB(65, 65, 65),
    AccentBlue = Color3.fromRGB(0, 180, 255),
    ToggleOn = Color3.fromRGB(40, 140, 70),
    ToggleOff = Color3.fromRGB(160, 50, 50),
    TextWhite = Color3.fromRGB(255, 255, 255),
    TextDimmed = Color3.fromRGB(180, 180, 180),
    InputBG = Color3.fromRGB(20, 20, 20),
    PanelBG = Color3.fromRGB(45, 45, 45),
    DropdownBG = Color3.fromRGB(25, 25, 25)
}

Components.layoutOrderGlobal = 0
Components.zIndexGlobal = 1000 
Components.innerOrderGlobal = 0

function Components:ResetOrder()
    self.layoutOrderGlobal = 0; self.zIndexGlobal = 1000; self.innerOrderGlobal = 0
end
function Components:GetOrdem() 
    self.layoutOrderGlobal = self.layoutOrderGlobal + 1; self.zIndexGlobal = self.zIndexGlobal - 10 
    return self.layoutOrderGlobal, self.zIndexGlobal 
end
function Components:GetInnerOrder() 
    self.innerOrderGlobal = self.innerOrderGlobal + 1; return self.innerOrderGlobal 
end

function Components:CriarCard(titulo, parent, forcedHeight, customWidth)
    local width = customWidth or 240 -- A mágica da largura aqui!
    local order, baseZ = self:GetOrdem()
    local card = Instance.new("Frame", parent)
    card.Name = "Card_" .. titulo
    card.BackgroundColor3 = self.Theme.CardBG
    card.LayoutOrder = order
    card.ZIndex = baseZ
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
    
    local stroke = Instance.new("UIStroke", card)
    stroke.Name = "Stroke"
    stroke.Color = self.Theme.CardStroke
    
    local titleLabel = Instance.new("TextLabel", card)
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "  " .. titulo
    titleLabel.TextColor3 = self.Theme.AccentBlue
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = baseZ + 1

    local div = Instance.new("Frame", card)
    div.Name = "Divider"
    div.Size = UDim2.new(1, 0, 0, 1); div.Position = UDim2.new(0, 0, 0, 30)
    div.BackgroundColor3 = self.Theme.CardStroke; div.BorderSizePixel = 0
    div.ZIndex = baseZ + 1

    local content = Instance.new("Frame", card)
    content.Name = "ContentFrame"
    content.Size = UDim2.new(1, 0, 0, 0); content.Position = UDim2.new(0, 0, 0, 31)
    content.BackgroundTransparency = 1; content.ZIndex = baseZ + 1

    local cLayout = Instance.new("UIListLayout", content)
    cLayout.Name = "VerticalLayout"
    cLayout.Padding = UDim.new(0, 8)
    cLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    cLayout.SortOrder = Enum.SortOrder.LayoutOrder 

    local pad = Instance.new("UIPadding", content)
    pad.PaddingTop = UDim.new(0, 10); pad.PaddingBottom = UDim.new(0, 10)

    if forcedHeight then
        card.Size = UDim2.new(0, width, 0, forcedHeight)
        content.Size = UDim2.new(1, 0, 1, -31)
    else
        cLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            content.Size = UDim2.new(1, 0, 0, cLayout.AbsoluteContentSize.Y + 20)
            card.Size = UDim2.new(0, width, 0, 31 + content.Size.Y.Offset)
        end)
    end
    return content, baseZ
end

function Components:CriarSubtitulo(texto, parent, cardZBase)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Name = "SubTitle_" .. texto
    lbl.Size = UDim2.new(0.95, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = "  " .. texto
    lbl.TextColor3 = self.Theme.TextDimmed
    lbl.Font = Enum.Font.SourceSansSemibold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = cardZBase + 2
    lbl.LayoutOrder = self:GetInnerOrder()
    return lbl
end

function Components:CriarGridDupla(parent, cardZBase)
    local f = Instance.new("Frame", parent); f.Name = "RowGrid_Double"; f.Size = UDim2.new(0.95, 0, 0, 32); f.BackgroundTransparency = 1
    f.ZIndex = cardZBase + 2; f.LayoutOrder = self:GetInnerOrder()
    local layout = Instance.new("UIListLayout", f)
    layout.FillDirection = Enum.FillDirection.Horizontal; layout.Padding = UDim.new(0, 5) 
    return f
end

function Components:CriarGridTripla(parent, cardZBase)
    local f = Instance.new("Frame", parent); f.Name = "RowGrid_Triple"; f.Size = UDim2.new(0.95, 0, 0, 32); f.BackgroundTransparency = 1
    f.ZIndex = cardZBase + 2; f.LayoutOrder = self:GetInnerOrder()
    local layout = Instance.new("UIListLayout", f)
    layout.FillDirection = Enum.FillDirection.Horizontal; layout.Padding = UDim.new(0, 5)
    return f
end

function Components:CriarBotaoEstilizado(texto, parent, cardZBase, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Name = "Button_" .. texto
    btn.Size = UDim2.new(0.95, 0, 0, 32); btn.BackgroundColor3 = self.Theme.ButtonBG
    btn.Text = "  " .. texto; btn.TextColor3 = self.Theme.TextWhite
    btn.Font = Enum.Font.SourceSansSemibold; btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.ZIndex = cardZBase + 2; btn.LayoutOrder = self:GetInnerOrder()
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

function Components:CriarBotaoPequeno(texto, cor, parentRow, cardZBase, callback)
    local b = Instance.new("TextButton", parentRow)
    b.Name = "SubButton_" .. texto
    b.Size = UDim2.new(0.333, -3.3, 1, 0); b.BackgroundColor3 = cor
    b.Text = texto; b.TextColor3 = self.Theme.TextWhite
    b.Font = Enum.Font.SourceSansBold; b.TextSize = 13
    b.ZIndex = cardZBase + 3; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.MouseButton1Click:Connect(callback)
    return b
end

function Components:CriarToggleLargo(texto, parent, stateTable, stateKey, cardZBase, callback)
    stateTable = stateTable or {}
    local btn = Instance.new("TextButton", parent)
    btn.Name = "Toggle_" .. stateKey
    btn.Size = UDim2.new(0.95, 0, 0, 34)
    local isAtivo = stateTable[stateKey]
    btn.BackgroundColor3 = isAtivo and self.Theme.ToggleOn or self.Theme.ToggleOff
    btn.Text = "  " .. texto .. (isAtivo and " [ON]" or " [OFF]")
    btn.TextColor3 = self.Theme.TextWhite; btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14; btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.ZIndex = cardZBase + 2; btn.LayoutOrder = self:GetInnerOrder()
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
    stateTable = stateTable or {}
    local frame = Instance.new("Frame", parentRow)
    frame.Name = "CheckboxContainer_" .. stateKey
    frame.Size = UDim2.new(0.5, -2.5, 1, 0); frame.BackgroundColor3 = self.Theme.PanelBG
    frame.ZIndex = cardZBase + 3; Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    
    local btn = Instance.new("TextButton", frame)
    btn.Name = "CheckTick"
    btn.Size = UDim2.new(0, 22, 0, 22); btn.Position = UDim2.new(0, 5, 0.5, -11)
    local isAtivo = stateTable[stateKey]
    btn.BackgroundColor3 = isAtivo and self.Theme.AccentBlue or self.Theme.CardBG
    btn.Text = isAtivo and "✓" or ""; btn.TextColor3 = self.Theme.TextWhite
    btn.ZIndex = cardZBase + 4; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local label = Instance.new("TextLabel", frame)
    label.Name = "Label"
    label.Size = UDim2.new(1, -35, 1, 0); label.Position = UDim2.new(0, 32, 0, 0)
    label.BackgroundTransparency = 1; label.Text = texto; label.TextColor3 = self.Theme.TextWhite
    label.Font = Enum.Font.SourceSansSemibold; label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left; label.ZIndex = cardZBase + 4
    
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
    stateTable = stateTable or {}
    local frame = Instance.new("Frame", parentRow)
    frame.Name = "InputContainer_" .. stateKey
    frame.Size = UDim2.new(0.5, -2.5, 1, 0); frame.BackgroundColor3 = self.Theme.PanelBG
    frame.ZIndex = cardZBase + 3; Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    
    local label = Instance.new("TextLabel", frame)
    label.Name = "Label"
    label.Size = UDim2.new(0.5, 0, 1, 0); label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1; label.Text = texto; label.TextColor3 = self.Theme.TextDimmed
    label.Font = Enum.Font.SourceSansSemibold; label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left; label.ZIndex = cardZBase + 4
    
    local input = Instance.new("TextBox", frame)
    input.Name = "BoxValue"
    input.Size = UDim2.new(0.45, 0, 0, 22); input.Position = UDim2.new(0.5, 0, 0.5, -11)
    input.BackgroundColor3 = self.Theme.InputBG; input.Text = tostring(stateTable[stateKey] or valDefault)
    input.TextColor3 = self.Theme.AccentBlue; input.Font = Enum.Font.SourceSansBold
    input.TextSize = 13; input.ZIndex = cardZBase + 4
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 4)
    
    input.FocusLost:Connect(function()
        local val = tonumber(input.Text)
        if val then stateTable[stateKey] = val else input.Text = tostring(stateTable[stateKey]) end
    end)
    return input
end

function Components:CriarInputLargo(placeholder, parentRow, cardZBase)
    local input = Instance.new("TextBox", parentRow)
    input.Name = "LargeInput_" .. placeholder
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

function Components:CriarItemDropdown(texto, parent, zIndexBase)
    local itemBtn = Instance.new("TextButton", parent)
    itemBtn.Name = "DropItem_" .. texto
    itemBtn.Size = UDim2.new(1, 0, 0, 32); itemBtn.BackgroundColor3 = Components.Theme.PanelBG 
    itemBtn.Text = "   " .. texto; itemBtn.TextColor3 = Components.Theme.TextWhite
    itemBtn.Font = Enum.Font.SourceSansSemibold; itemBtn.TextSize = 13
    itemBtn.TextXAlignment = Enum.TextXAlignment.Left; itemBtn.ZIndex = zIndexBase
    Instance.new("UICorner", itemBtn).CornerRadius = UDim.new(0, 6)
    return itemBtn
end

function Components:CriarDropdown(labelTexto, parent, stateTable, stateKey, isMulti, cardZBase, hasSearch)
    stateTable = stateTable or {}
    local frame = Instance.new("Frame", parent)
    frame.Name = "DropdownContainer_" .. stateKey
    frame.Size = UDim2.new(0.95, 0, 0, 32); frame.BackgroundTransparency = 1
    frame.ZIndex = cardZBase + 2; frame.LayoutOrder = self:GetInnerOrder()
    
    local mainBtn = Instance.new("TextButton", frame)
    mainBtn.Name = "TriggerButton"
    mainBtn.Size = UDim2.new(1, 0, 1, 0); mainBtn.BackgroundColor3 = self.Theme.ButtonBG
    mainBtn.Text = "  " .. labelTexto; mainBtn.TextColor3 = self.Theme.TextWhite
    mainBtn.Font = Enum.Font.SourceSansSemibold; mainBtn.TextSize = 14
    mainBtn.TextXAlignment = Enum.TextXAlignment.Left; mainBtn.ZIndex = cardZBase + 3
    Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(0, 4)
    
    local icone = Instance.new("TextLabel", mainBtn)
    icone.Name = "ArrowIcon"
    icone.Size = UDim2.new(0, 20, 1, 0); icone.Position = UDim2.new(1, -25, 0, 0)
    icone.BackgroundTransparency = 1; icone.Text = "▼"
    icone.TextColor3 = self.Theme.TextDimmed; icone.ZIndex = cardZBase + 4
    
    local dropdownContainer = Instance.new("TextButton", frame)
    dropdownContainer.Name = "MenuListPanel"
    dropdownContainer.Text = ""; dropdownContainer.AutoButtonColor = false
    dropdownContainer.Size = UDim2.new(1, 0, 0, 210); dropdownContainer.Position = UDim2.new(0, 0, 1, 4)
    dropdownContainer.BackgroundColor3 = self.Theme.DropdownBG; dropdownContainer.Visible = false
    dropdownContainer.ZIndex = cardZBase + 50; dropdownContainer.Active = true 
    Instance.new("UICorner", dropdownContainer).CornerRadius = UDim.new(0, 6)

    local dropStroke = Instance.new("UIStroke", dropdownContainer)
    dropStroke.Color = Color3.fromRGB(80, 80, 80); dropStroke.Thickness = 1
    
    local searchBox = nil; local yOffsetScroll = 0
    if hasSearch then
        searchBox = Instance.new("TextBox", dropdownContainer)
        searchBox.Name = "SearchField"
        searchBox.Size = UDim2.new(1, -12, 0, 30); searchBox.Position = UDim2.new(0, 6, 0, 6)
        searchBox.BackgroundColor3 = self.Theme.InputBG; searchBox.PlaceholderText = "Search..."
        searchBox.Text = ""; searchBox.TextColor3 = self.Theme.AccentBlue
        searchBox.Font = Enum.Font.SourceSansSemibold; searchBox.TextSize = 13
        searchBox.TextXAlignment = Enum.TextXAlignment.Left; searchBox.ZIndex = cardZBase + 51
        Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 4)
        local sPad = Instance.new("UIPadding", searchBox); sPad.PaddingLeft = UDim.new(0, 10)
        yOffsetScroll = 40 
    end
    
    local scroll = Instance.new("ScrollingFrame", dropdownContainer)
    scroll.Name = "Scroller"
    scroll.Size = UDim2.new(1, 0, 1, -yOffsetScroll); scroll.Position = UDim2.new(0, 0, 0, yOffsetScroll)
    scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.ZIndex = cardZBase + 51
    scroll.ScrollBarThickness = 4; scroll.ScrollBarImageColor3 = self.Theme.AccentBlue; scroll.Active = true 

    local listLayout = Instance.new("UIListLayout", scroll)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder; listLayout.Padding = UDim.new(0, 5) 
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    local scrollPad = Instance.new("UIPadding", scroll)
    scrollPad.PaddingTop = UDim.new(0, 5); scrollPad.PaddingBottom = UDim.new(0, 5)
    scrollPad.PaddingLeft = UDim.new(0, 5); scrollPad.PaddingRight = UDim.new(0, 5)
    
    mainBtn.MouseButton1Click:Connect(function() 
        dropdownContainer.Visible = not dropdownContainer.Visible 
        if searchBox and dropdownContainer.Visible then searchBox.Text = "" end
    end)
    
    if isMulti and not stateTable[stateKey] then stateTable[stateKey] = {["All"] = true} end
    local dropdownObj = {}; local todosBotoes = {}
    
    function dropdownObj:Refresh(listaItems)
        if type(listaItems) ~= "table" then listaItems = {} end
        for _, old in ipairs(scroll:GetChildren()) do if old:IsA("TextButton") then old:Destroy() end end
        todosBotoes = {}
        
        local itemsToRender = {}
        if isMulti then table.insert(itemsToRender, "All") end
        for _, item in ipairs(listaItems) do 
            if item ~= "Nenhuma Ferramenta Equipada" and item ~= "Ainda não carregou / Vazio" then table.insert(itemsToRender, item) end
        end

        if #itemsToRender == 0 or (isMulti and #itemsToRender == 1) then table.insert(itemsToRender, "None Found") end

        local function atualizarMainText()
            if isMulti then
                if stateTable[stateKey]["All"] then mainBtn.Text = "  " .. labelTexto .. ": All"
                else
                    local count = 0
                    for k, v in pairs(stateTable[stateKey]) do if v and k ~= "None Found" then count = count + 1 end end
                    mainBtn.Text = "  " .. labelTexto .. ": " .. count .. " sel."
                end
            else
                mainBtn.Text = "  " .. labelTexto .. ": " .. tostring(stateTable[stateKey] or "None")
            end
        end
        
        for _, itemNome in ipairs(itemsToRender) do
            local itemBtn = Components:CriarItemDropdown(itemNome, scroll, cardZBase + 52)
            local corPadrao = Components.Theme.PanelBG
            table.insert(todosBotoes, {btn = itemBtn, nome = itemNome, bg = corPadrao})
            
            local function applyVisual()
                if isMulti then
                    itemBtn.BackgroundColor3 = (stateTable[stateKey] and stateTable[stateKey][itemNome]) and Components.Theme.AccentBlue or corPadrao
                else
                    itemBtn.BackgroundColor3 = (stateTable[stateKey] == itemNome) and Components.Theme.AccentBlue or corPadrao
                end
            end
            applyVisual()
            
            itemBtn.MouseButton1Click:Connect(function()
                if itemNome == "None Found" then return end
                if isMulti then
                    if itemNome == "All" then stateTable[stateKey] = {["All"] = true}
                    else
                        if not stateTable[stateKey] then stateTable[stateKey] = {} end
                        stateTable[stateKey]["All"] = nil
                        stateTable[stateKey][itemNome] = not stateTable[stateKey][itemNome]
                    end
                    for _, obj in ipairs(todosBotoes) do obj.btn.BackgroundColor3 = stateTable[stateKey][obj.nome] and Components.Theme.AccentBlue or obj.bg end
                    atualizarMainText()
                else
                    stateTable[stateKey] = itemNome
                    for _, obj in ipairs(todosBotoes) do obj.btn.BackgroundColor3 = (obj.nome == itemNome) and Components.Theme.AccentBlue or obj.bg end
                    atualizarMainText()
                    dropdownContainer.Visible = false
                end
            end)
        end
        
        local function renderizarBusca()
            local termo = searchBox and searchBox.Text:lower() or ""
            local count = 0
            for _, obj in ipairs(todosBotoes) do
                if termo == "" or obj.nome:lower():match(termo) then obj.btn.Visible = true; count = count + 1 else obj.btn.Visible = false end
            end
            local alturaNecessaria = (count * 32) + (math.max(0, count - 1) * 5) + 10
            scroll.CanvasSize = UDim2.new(0, 0, 0, alturaNecessaria)
        end
        if searchBox then searchBox:GetPropertyChangedSignal("Text"):Connect(renderizarBusca) end
        renderizarBusca(); atualizarMainText()
    end
    dropdownObj:Refresh({}) 
    return dropdownObj
end

function Components:CriarControlesEspaciais(parentCard, cardZBase, scannerName)
    local Bot = _G.IslandsBot
    local State = Bot.State

    local container = Instance.new("Frame", parentCard)
    container.Name = "DPlayerRemoteControl"
    container.Size = UDim2.new(0.95, 0, 0, 85)
    container.BackgroundColor3 = self.Theme.InputBG
    container.ZIndex = cardZBase + 2
    container.LayoutOrder = self:GetInnerOrder()
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
    
    local dpad = Instance.new("Frame", container)
    dpad.Name = "JoystickXZ"
    dpad.Size = UDim2.new(0, 80, 0, 80)
    dpad.Position = UDim2.new(0.15, 0, 0, 2)
    dpad.BackgroundTransparency = 1
    dpad.ZIndex = cardZBase + 3
    
    local btnSize = 24
    local function CriarSetinha(texto, x, y, direcao, parentFrame)
        local btn = Instance.new("TextButton", parentFrame)
        btn.Name = "KeyPad_" .. direcao
        btn.Size = UDim2.new(0, btnSize, 0, btnSize)
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
    
    CriarSetinha("^", 28, 5, "Frente", dpad)
    CriarSetinha("v", 28, 53, "Tras", dpad)
    CriarSetinha("<", 4, 29, "Esquerda", dpad)
    CriarSetinha(">", 52, 29, "Direita", dpad)
    
    local vertPanel = Instance.new("Frame", container)
    vertPanel.Name = "JoystickY"
    vertPanel.Size = UDim2.new(0, 30, 0, 80)
    vertPanel.Position = UDim2.new(0.7, 0, 0, 2)
    vertPanel.BackgroundTransparency = 1
    vertPanel.ZIndex = cardZBase + 3
    
    CriarSetinha("🔼", 3, 10, "Subir", vertPanel)
    CriarSetinha("🔽", 3, 46, "Descer", vertPanel)
end

return Components