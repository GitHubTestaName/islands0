-- src/ui/tabs/GeralTab.lua
local GeralTab = {}

function GeralTab:Construir(paginaPai)
    local Bot = _G.IslandsBot
    local State = Bot.State
    local Componentes = Bot.Modules.UIComponents
    local Manager = Bot.Modules.Manager

    Componentes:ResetOrder()

    -- ================= CAIXA 1: AÇÕES (BOTS) =================
    local cAcoes, zAcoes = Componentes:CriarCard("AÇÕES (MINERAR & CONSTRUIR)", paginaPai)
    
    Componentes:CriarToggleLargo("⛏️ Auto Mineração", cAcoes, State, "Minerando", zAcoes, function(v) 
        if Bot.Modules.Miner then Bot.Modules.Miner:Alternar(v) end 
    end)
    Componentes:CriarBotaoEstilizado("🔨 Preencher Construção", cAcoes, zAcoes, function() 
        if Bot.Modules.Builder then Bot.Modules.Builder:ColocarAreaMarcada() end 
    end)
    
    local DropdownBlocos = Componentes:CriarDropdown("Material (Construção)", cAcoes, State, "BlocoSelecionado", false, zAcoes + 50, true)
    
    Componentes:CriarBotaoEstilizado("🔄 Sincronizar Meus Blocos", cAcoes, zAcoes, function() 
        if Manager then 
            DropdownBlocos:Refresh(Manager:GetInventoryTools("Block")) 
            Manager:AtualizarStatus("🔨 Inventário de Blocos Sincronizado!")
        end 
    end)


    -- ================= CAIXA 2: O SELETOR DA ÁREA =================
    local cSelAzul, zSelAzul = Componentes:CriarCard("CONTROLE DO SELETOR AZUL", paginaPai)
    
    Componentes:CriarBotaoEstilizado("🟦 Exibir / Ocultar Cubo", cSelAzul, zSelAzul, function() 
        if State.ScannerGeral then State.ScannerGeral:CriarSeletorFrontal() end 
    end)
    Componentes:CriarControlesEspaciais(cSelAzul, zSelAzul, "ScannerGeral")
    
    local rCheckSel = Componentes:CriarGridDupla(cSelAzul, zSelAzul)
    Componentes:CriarCheckboxMetade("Ocultar Números", rCheckSel, State.ScannerGeral, "HideNumbers", zSelAzul, function()
        if State.ScannerGeral then State.ScannerGeral:EscanearArea() end
    end)


    -- ================= CAIXA 3: SISTEMA DE SAVES =================
    local cSaves, zSaves = Componentes:CriarCard("GERENCIADOR DE PLOTS", paginaPai)

    local rSaveNomeM = Instance.new("Frame", cSaves)
    rSaveNomeM.Size = UDim2.new(0.95, 0, 0, 32)
    rSaveNomeM.BackgroundTransparency = 1
    rSaveNomeM.ZIndex = zSaves + 2
    rSaveNomeM.LayoutOrder = Componentes:GetInnerOrder()
    
    local inputPlotMining = Componentes:CriarInputLargo("Nome do Save...", rSaveNomeM, zSaves)
    local plotDropdownMining = Componentes:CriarDropdown("Plots de Mineração", cSaves, State.MiningSettings, "CurrentSaveName", false, zSaves + 20, false)

    local function AtualizarSavesMining()
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

    local btnSave = Componentes:CriarBotaoEstilizado("💾 Salvar", rSaveNomeM, zSaves, function()
        local nStr = inputPlotMining.Text
        local cubo = State.ScannerGeral and State.ScannerGeral.AncoraPart
        
        if nStr == "" then
             if Manager then Manager:AtualizarStatus("❌ ERRO: Escreva um Nome!") end return
        elseif not cubo then
             if Manager then Manager:AtualizarStatus("❌ ERRO: O Seletor não existe na tela!") end return
        end

        Bot.Modules.PlotManager:SalvarPlot("Mining_" .. nStr, cubo.Position, cubo.Size)
        AtualizarSavesMining()
        if Manager then Manager:AtualizarStatus("✅ SUCESSO: Plot '" .. nStr .. "' Salvo.") end
        inputPlotMining.Text = ""
    end)
    btnSave.Size = UDim2.new(0.35, 0, 1, 0)
    btnSave.Position = UDim2.new(0.65, 5, 0, 0)
    btnSave.BackgroundColor3 = Color3.fromRGB(0, 140, 200)

    local rAcoes = Componentes:CriarGridTripla(cSaves, zSaves)
    Componentes:CriarBotaoPequeno("Load", Color3.fromRGB(40, 150, 80), rAcoes, zSaves, function()
        local sn = State.MiningSettings.CurrentSaveName
        if not sn or sn == "Nenhum" then return end
        
        local p = Bot.Modules.PlotManager:ObterTodos()["Mining_" .. sn]
        if p and State.ScannerGeral then 
            State.ScannerGeral:CarregarPlot(Vector3.new(p.PosX, p.PosY, p.PosZ), Vector3.new(p.SizeX, p.SizeY, p.SizeZ)) 
            if Manager then Manager:AtualizarStatus("✅ LOAD: Área '" .. sn .. "' ativada!") end
        end
    end)
    Componentes:CriarBotaoPequeno("Over-write", Color3.fromRGB(200, 120, 20), rAcoes, zSaves, function()
        local sn, cubo = State.MiningSettings.CurrentSaveName, State.ScannerGeral and State.ScannerGeral.AncoraPart
        if not sn or sn == "Nenhum" or not cubo then return end
        Bot.Modules.PlotManager:SalvarPlot("Mining_" .. sn, cubo.Position, cubo.Size) 
        if Manager then Manager:AtualizarStatus("🔄 SUBSTITUÍDO: Modificou área '".. sn .."'.") end
    end)
    Componentes:CriarBotaoPequeno("Delete", Color3.fromRGB(200, 50, 50), rAcoes, zSaves, function()
        local sn = State.MiningSettings.CurrentSaveName
        if not sn or sn == "Nenhum" then return end
        Bot.Modules.PlotManager:DeletarPlot("Mining_" .. sn)
        State.MiningSettings.CurrentSaveName = "Nenhum"
        AtualizarSavesMining()
        if Manager then Manager:AtualizarStatus("🗑️ DELETADO: O plot '" .. sn .."' foi apagado.") end
    end)
    
    local rAutoLoad = Componentes:CriarGridDupla(cSaves, zSaves)
    Componentes:CriarCheckboxMetade("Autoload na Conexão", rAutoLoad, State.MiningSettings, "AutoUseSelectedSave", zSaves)

    -- ================= CAIXA 4: AJUSTES DE VELOCIDADE =================
    local cMinerCfg, zMinerCfg = Componentes:CriarCard("COMPORTAMENTO", paginaPai)
    local rMinerDelay = Componentes:CriarGridDupla(cMinerCfg, zMinerCfg)
    Componentes:CriarCheckboxMetade("Voo com Bot", rMinerDelay, State.MiningSettings, "TweenToTarget", zMinerCfg)
    Componentes:CriarInputMetade("Speed de Voo", rMinerDelay, State.MiningSettings, "TweenSpeed", 20, zMinerCfg)

    task.spawn(function()
        task.wait(1.5)
        AtualizarSavesMining()
    end)
end

return GeralTab