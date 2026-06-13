-- src/ui/tabs/GeralTab.lua
local GeralTab = {}

function GeralTab:Construir(paginaPai)
    local Bot = _G.IslandsBot
    local State = Bot.State
    local Componentes = Bot.Modules.UIComponents

    Componentes:ResetOrder()

    -- MINER & BUILDER
    local cMiner, zMiner = Componentes:CriarCard("MINER & BUILDER", paginaPai)
    Componentes:CriarToggleLargo("⛏️ Auto Minerar", cMiner, State, "Minerando", zMiner, function(v) 
        if Bot.Modules.Miner then Bot.Modules.Miner:Alternar(v) end 
    end)
    local DropdownBlocos = Componentes:CriarDropdown("Material de Construção", cMiner, State, "BlocoSelecionado", false, zMiner, false)
    Componentes:CriarBotaoEstilizado("🔄 Carregar Mochila", cMiner, zMiner, function() 
        if Bot.Modules.Manager then DropdownBlocos:Refresh(Bot.Modules.Manager:GetInventoryTools("Block")) end 
    end)
    Componentes:CriarBotaoEstilizado("🔨 Preencher Área do Seletor", cMiner, zMiner, function() 
        if Bot.Modules.Builder then Bot.Modules.Builder:ColocarAreaMarcada() end 
    end)

    -- CONFIG & DELAY (MINER)
    local cMinerCfg, zMinerCfg = Componentes:CriarCard("CONFIG & DELAY (MINER)", paginaPai)
    local rMinerDelay1 = Componentes:CriarGridDupla(cMinerCfg, zMinerCfg)
    Componentes:CriarCheckboxMetade("Tween/Voo", rMinerDelay1, State.MiningSettings, "TweenToTarget", zMinerCfg)
    Componentes:CriarInputMetade("Vel. Voo:", rMinerDelay1, State.MiningSettings, "TweenSpeed", 20, zMinerCfg)
    local rMinerDelay2 = Componentes:CriarGridDupla(cMinerCfg, zMinerCfg)
    Componentes:CriarCheckboxMetade("Esconder Nums", rMinerDelay2, State.ScannerGeral, "HideNumbers", zMinerCfg, function()
        if State.ScannerGeral then State.ScannerGeral:EscanearArea() end
    end)

    -- SELECTOR & SAVES (MINER)
    local cSelAzul, zSelAzul = Componentes:CriarCard("SELECTOR & SAVES (MINER)", paginaPai)
    Componentes:CriarBotaoEstilizado("🟦 Ligar/Desligar Cubo Azul", cSelAzul, zSelAzul, function() 
        if State.ScannerGeral then State.ScannerGeral:CriarSeletorFrontal() end 
    end)
    Componentes:CriarControlesEspaciais(cSelAzul, zSelAzul, "ScannerGeral")

    local rSaveNomeM = Instance.new("Frame", cSelAzul)
    rSaveNomeM.Size = UDim2.new(0.95, 0, 0, 32)
    rSaveNomeM.BackgroundTransparency = 1
    rSaveNomeM.ZIndex = zSelAzul + 2
    rSaveNomeM.LayoutOrder = Componentes:GetInnerOrder()
    
    local inputPlotMining = Componentes:CriarInputLargo("Nome do seu Plot...", rSaveNomeM, zSelAzul)
    
    local plotDropdownMining = Componentes:CriarDropdown("Selecionar Save", cSelAzul, State.MiningSettings, "CurrentSaveName", false, zSelAzul - 5, false)

    local function AtualizarListaSavesMining()
        if Bot.Modules.PlotManager and plotDropdownMining then
            local plots = Bot.Modules.PlotManager:ObterTodos()
            local lista = {}
            for nome, _ in pairs(plots) do 
                if nome:sub(1, 7) == "Mining_" then table.insert(lista, nome:sub(8)) end
            end
            if #lista == 0 then lista = {"Nenhum"} end
            plotDropdownMining:Refresh(lista)
        end
    end

    -- Usando e Concatenando o Componente
    local btnSavePlotMining = Componentes:CriarBotaoEstilizado("💾 Salvar", rSaveNomeM, zSelAzul, function()
        local cubo = State.ScannerGeral and State.ScannerGeral.AncoraPart
        if inputPlotMining.Text ~= "" and cubo then
            Bot.Modules.PlotManager:SalvarPlot("Mining_" .. inputPlotMining.Text, cubo.Position, cubo.Size)
            AtualizarListaSavesMining()
            inputPlotMining.Text = ""
        end
    end)
    
    btnSavePlotMining.Size = UDim2.new(0.35, 0, 1, 0)
    btnSavePlotMining.Position = UDim2.new(0.65, 5, 0, 0)
    btnSavePlotMining.BackgroundColor3 = Color3.fromRGB(0, 160, 220)

    local rAcoesM = Componentes:CriarGridTripla(cSelAzul, zSelAzul)
    Componentes:CriarBotaoPequeno("Load", Color3.fromRGB(40, 150, 80), rAcoesM, zSelAzul, function()
        local sn = State.MiningSettings.CurrentSaveName
        if sn and sn ~= "Nenhum" then
            local p = Bot.Modules.PlotManager:ObterTodos()["Mining_" .. sn]
            if p and State.ScannerGeral then State.ScannerGeral:CarregarPlot(Vector3.new(p.PosX, p.PosY, p.PosZ), Vector3.new(p.SizeX, p.SizeY, p.SizeZ)) end
        end
    end)
    Componentes:CriarBotaoPequeno("Rewrite", Color3.fromRGB(200, 120, 20), rAcoesM, zSelAzul, function()
        local sn = State.MiningSettings.CurrentSaveName
        local cubo = State.ScannerGeral and State.ScannerGeral.AncoraPart
        if sn and sn ~= "Nenhum" and cubo then Bot.Modules.PlotManager:SalvarPlot("Mining_" .. sn, cubo.Position, cubo.Size) end
    end)
    Componentes:CriarBotaoPequeno("Delete", Color3.fromRGB(200, 50, 50), rAcoesM, zSelAzul, function()
        local sn = State.MiningSettings.CurrentSaveName
        if sn and sn ~= "Nenhum" then
            Bot.Modules.PlotManager:DeletarPlot("Mining_" .. sn)
            State.MiningSettings.CurrentSaveName = "Nenhum"
            AtualizarListaSavesMining()
        end
    end)
    
    local rSave2M = Componentes:CriarGridDupla(cSelAzul, zSelAzul)
    Componentes:CriarCheckboxMetade("Auto Load Start", rSave2M, State.MiningSettings, "AutoUseSelectedSave", zSelAzul)

    task.spawn(function()
        task.wait(1)
        AtualizarListaSavesMining()
    end)
end

return GeralTab