-- src/ui/tabs/FazendaTab.lua
local FazendaTab = {}

function FazendaTab:Construir(paginaPai)
    local Bot = _G.IslandsBot
    local State = Bot.State
    
    -- Função local para criar dropdown sem depender de bibliotecas externas
    local function CriarDropdownLocal(labelTexto, parent, stateTable, stateKey, isMulti, zIndex)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(0.95, 0, 0, 32)
        frame.BackgroundTransparency = 1
        
        local btnMain = Instance.new("TextButton", frame)
        btnMain.Size = UDim2.new(1, 0, 1, 0)
        btnMain.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btnMain.Text = "  " .. labelTexto .. ": Carregando..."
        btnMain.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnMain.Font = Enum.Font.SourceSansSemibold
        btnMain.TextSize = 14
        btnMain.TextXAlignment = Enum.TextXAlignment.Left
        btnMain.BorderSizePixel = 0
        Instance.new("UICorner", btnMain).CornerRadius = UDim.new(0, 4)

        local listaContainer = Instance.new("ScrollingFrame", frame)
        listaContainer.Size = UDim2.new(1, 0, 0, 150)
        listaContainer.Position = UDim2.new(0, 0, 1, 5)
        listaContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        listaContainer.Visible = false
        listaContainer.ZIndex = 50 -- ZIndex fixo e alto
        listaContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
        Instance.new("UIListLayout", listaContainer).Padding = UDim.new(0, 2)
        
        btnMain.MouseButton1Click:Connect(function() listaContainer.Visible = not listaContainer.Visible end)

        return {
            btnMain = btnMain,
            scroll = listaContainer,
            Refresh = function(self, lista)
                listaContainer:ClearAllChildren()
                Instance.new("UIListLayout", listaContainer).Padding = UDim.new(0, 2)
                
                -- Adiciona o botão "All"
                local btnAll = Instance.new("TextButton", listaContainer)
                btnAll.Text = "  All"
                btnAll.Size = UDim2.new(1, 0, 0, 30)
                btnAll.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                btnAll.TextColor3 = Color3.fromRGB(255, 255, 255)
                btnAll.MouseButton1Click:Connect(function() stateTable[stateKey] = {["All"] = true}; btnMain.Text = "  " .. labelTexto .. ": All" end)

                for _, item in ipairs(lista) do
                    local b = Instance.new("TextButton", listaContainer)
                    b.Text = "  " .. item
                    b.Size = UDim2.new(1, 0, 0, 30)
                    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    b.TextColor3 = Color3.fromRGB(255, 255, 255)
                    b.MouseButton1Click:Connect(function() 
                        stateTable[stateKey] = item
                        btnMain.Text = "  " .. labelTexto .. ": " .. item 
                        listaContainer.Visible = false
                    end)
                end
                listaContainer.CanvasSize = UDim2.new(0, 0, 0, listaContainer.UIListLayout.AbsoluteContentSize.Y)
            end
        }
    end

    -- Desenho da Aba
    local cFarm = Instance.new("Frame", paginaPai); cFarm.Size = UDim2.new(0, 240, 0, 150); cFarm.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    Instance.new("UIListLayout", cFarm).Padding = UDim.new(0, 10)
    Instance.new("TextLabel", cFarm).Text = "MAIN FARM"
    
    local cSeed = Instance.new("Frame", paginaPai); cSeed.Size = UDim2.new(0, 240, 0, 200); cSeed.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    Instance.new("TextLabel", cSeed).Text = "SEED"
    
    local dropPessoal = CriarDropdownLocal("Sementes Pessoais", cSeed, State, "SementeSelecionada", true, 10)
    local dropPriorize = CriarDropdownLocal("Priorize Plant", cSeed, State.FarmSettings, "PrioritizePlant", false, 10)
    
    local btnUpdate = Instance.new("TextButton", cSeed)
    btnUpdate.Text = "🔄 Atualizar"
    btnUpdate.MouseButton1Click:Connect(function()
        if Bot.Modules.Manager then
            local pessoais = Bot.Modules.Manager:GetInventoryTools("Seed")
            dropPessoal:Refresh(pessoais)
            local globais = Bot.Modules.Manager:GetAllSeedsInGame()
            dropPriorize:Refresh(globais)
        end
    end)

    -- Carregamento inicial (após 2 segundos para garantir que o jogo carregou tudo)
    task.spawn(function()
        task.wait(2)
        if Bot.Modules.Manager then
            dropPessoal:Refresh(Bot.Modules.Manager:GetInventoryTools("Seed"))
            dropPriorize:Refresh(Bot.Modules.Manager:GetAllSeedsInGame())
        end
    end)
end

return FazendaTab