-- src/ui/tabs/GeralTab.lua
local GeralTab = {}

function GeralTab:Construir(paginaPai)
    local Bot = _G.IslandsBot
    local State = Bot.State
    local Componentes = Bot.Modules.UIComponents
    local Manager = Bot.Modules.Manager

    Componentes:ResetOrder()

    -- ================= AÇÕES MINERADOR / CONSTRUTOR =================
    local cMiner, zMiner = Componentes:CriarCard("CONTROLES: MINERADOR & CONSTRUTOR", paginaPai)
    
    Componentes:CriarBotaoEstilizado("🟦 Ligar/Desligar Cubo Seletor (Azul)", cMiner, zMiner, function() 
        if State.ScannerGeral then State.ScannerGeral:CriarSeletorFrontal() end 
    end)
    Componentes:CriarControlesEspaciais(cMiner, zMiner, "ScannerGeral")
    
    Componentes:CriarToggleLargo("⛏️ Auto Minerar Tudo no Seletor Azul", cMiner, State, "Minerando", zMiner, function(v) 
        if Bot.Modules.Miner then Bot.Modules.Miner:Alternar(v) end 
    end)
    
    -- Seção de Builder / Drops Seguros e Flutuantes com Z-Index Fortalecido!
    local DropdownBlocos = Componentes:CriarDropdown("Material da Sua Construção:", cMiner, State, "BlocoSelecionado", false, zMiner + 100, true)
    
    Componentes:CriarBotaoEstilizado("🔄 Detectar Meus Blocos Inventário", cMiner, zMiner, function() 
        if Bot.Modules.Manager then 
            DropdownBlocos:Refresh(Bot.Modules.Manager:GetInventoryTools("Block")) 
            Manager:AtualizarStatus("🔨 Scanner leu sua mochila e achou blocos!")
        end 
    end)
    Componentes:CriarBotaoEstilizado("🏗️ Autopreencer Seletor (Colocar Bloco)", cMiner, zMiner, function() 
        if Bot.Modules.Builder then Bot.Modules.Builder:ColocarAreaMarcada() end 
    end)

    -- ================= LOGIC E SALVAMENTO DE ÁREA: =================
    local cSelAzul, zSelAzul = Componentes:CriarCard("SALVADOR: SAVES DA ÁREA DE MINERAÇÃO", paginaPai)

    local rSaveNomeM = Instance.new("Frame", cSelAzul)
    rSaveNomeM.Size = UDim2.new(0.95, 0, 0, 32)
    rSaveNomeM.BackgroundTransparency = 1
    rSaveNomeM.ZIndex = zSelAzul + 2
    rSaveNomeM.LayoutOrder = Componentes:GetInnerOrder()
    
    local inputPlotMining = Componentes:CriarInputLargo("Digite Nome para Área Azul...", rSaveNomeM, zSelAzul)
    -- Usa zSelAzul+50 pro Menu Descer Por cima Dos demais em baixo:
    local plotDropdownMining = Componentes:CriarDropdown("Mineração Salvas Atualmente:", cSelAzul, State.MiningSettings, "CurrentSaveName", false, zSelAzul + 50, false)

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

    -- [Ação]: SALVAR 
    local btnSavePlotMining = Componentes:CriarBotaoEstilizado("💾 Guardar Save", rSaveNomeM, zSelAzul, function()
        local nStr = inputPlotMining.Text
        local cubo = State.ScannerGeral and State.ScannerGeral.AncoraPart
        if nStr == "" then
             if Manager then Manager:AtualizarStatus("❌ Coloque nome pra Salvar área Mineral!") end return
        elseif not cubo then
             if Manager then Manager:AtualizarStatus("❌ Erro: Acione o botão de Mostrar/Criar o Cubo Azul.") end return
        end

        Bot.Modules.PlotManager:SalvarPlot("Mining_" .. nStr, cubo.Position, cubo.Size)
        AtualizarListaSavesMining()
        if Manager then Manager:AtualizarStatus("✅ O SELETOR DE MINE " .. nStr .. " foi adicionado aos dados locais.") end
        inputPlotMining.Text = ""
    end)
    btnSavePlotMining.Size = UDim2.new(0.35, 0, 1, 0)
    btnSavePlotMining.Position = UDim2.new(0.65, 5, 0, 0)
    btnSavePlotMining.BackgroundColor3 = Color3.fromRGB(0, 160, 220)

    local rAcoesM = Componentes:CriarGridTripla(cSelAzul, zSelAzul)
    
    -- [Ação]: CARREGAR
    Componentes:CriarBotaoPequeno("Load Save", Color3.fromRGB(40, 150, 80), rAcoesM, zSelAzul, function()
        local sn = State.MiningSettings.CurrentSaveName
        if not sn or sn == "Nenhum" or sn == "Carregando..." then 
             if Manager then Manager:AtualizarStatus("❌ Marque um Cubo Azul Guardado abaixo.") end return 
        end
        local p = Bot.Modules.PlotManager:ObterTodos()["Mining_" .. sn]
        if p and State.ScannerGeral then 
            State.ScannerGeral:CarregarPlot(Vector3.new(p.PosX, p.PosY, p.PosZ), Vector3.new(p.SizeX, p.SizeY, p.SizeZ)) 
            if Manager then Manager:AtualizarStatus("⛏️ ÁREA PUXADA: Plot azul [ " .. sn .. " ] agora vivo!") end
        else
            if Manager then Manager:AtualizarStatus("❌ Os Dados salvos pra mineração de fato Sumiram ou estão corrompidos") end
        end
    end)
    
    -- [Ação]: SUBSCREVER
    Componentes:CriarBotaoPequeno("Regravar", Color3.fromRGB(200, 120, 20), rAcoesM, zSelAzul, function()
        local sn = State.MiningSettings.CurrentSaveName
        local cubo = State.ScannerGeral and State.ScannerGeral.AncoraPart
        if not sn or sn == "Nenhum" then 
            if Manager then Manager:AtualizarStatus("❌ Nenhum Nome em seleção detectado!") end return
        elseif not cubo then
            if Manager then Manager:AtualizarStatus("❌ Requer Existência de um Plot Flutuante Atualmente pra clonar coordenadas!") end return
        end

        Bot.Modules.PlotManager:SalvarPlot("Mining_" .. sn, cubo.Position, cubo.Size) 
        if Manager then Manager:AtualizarStatus("🔁 MODO EDITOR MINEIRO: Você Corrigiu Coordenadas/Scale no: [".. sn .."]") end
    end)
    
    -- [Ação]: EXCLUIR 
    Componentes:CriarBotaoPequeno("Lixeira", Color3.fromRGB(200, 50, 50), rAcoesM, zSelAzul, function()
        local sn = State.MiningSettings.CurrentSaveName
        if not sn or sn == "Nenhum" then return end
        Bot.Modules.PlotManager:DeletarPlot("Mining_" .. sn)
        State.MiningSettings.CurrentSaveName = "Nenhum"
        AtualizarListaSavesMining()
        if Manager then Manager:AtualizarStatus("💀 FANTASMAS NÃO MINERAM. VOCÊ LIXOU/DELETOU O SAVE MINING [ " .. sn .." ]") end
    end)
    
    local rSave2M = Componentes:CriarGridDupla(cSelAzul, zSelAzul)
    Componentes:CriarCheckboxMetade("Auto Carregador de Plot de Mina.", rSave2M, State.MiningSettings, "AutoUseSelectedSave", zSelAzul)

    -- ================= TWEAKS / ENGINE SETS =================
    local cMinerCfg, zMinerCfg = Componentes:CriarCard("O.S E ACELERAÇÃO (MOTOR DE BUSCAS MINEIRO)", paginaPai)
    local rMinerDelay1 = Componentes:CriarGridDupla(cMinerCfg, zMinerCfg)
    Componentes:CriarCheckboxMetade("Voo C/ PathFinder Autom.", rMinerDelay1, State.MiningSettings, "TweenToTarget", zMinerCfg)
    Componentes:CriarInputMetade("Velocida De Ida P/Blocos", rMinerDelay1, State.MiningSettings, "TweenSpeed", 20, zMinerCfg)
    local rMinerDelay2 = Componentes:CriarGridDupla(cMinerCfg, zMinerCfg)
    Componentes:CriarCheckboxMetade("Desativar Contador Numericos na GUI visual dos Flocos/Mine.", rMinerDelay2, State.ScannerGeral, "HideNumbers", zMinerCfg, function()
        if State.ScannerGeral then State.ScannerGeral:EscanearArea() end
    end)

    task.spawn(function()
        task.wait(1.5)
        AtualizarListaSavesMining()
    end)
end

return GeralTab