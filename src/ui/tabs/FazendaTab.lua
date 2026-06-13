-- src/ui/tabs/FazendaTab.lua
local FazendaTab = {}

function FazendaTab:Construir(paginaPai)
    local Bot = _G.IslandsBot
    local State = Bot.State
    local Componentes = Bot.Modules.UIComponents
    local Manager = Bot.Modules.Manager

    Componentes:ResetOrder()

    -- =================== CONTROLE GERAL ===================
    local cFarm, zFarm = Componentes:CriarCard("CONTROLE DA FAZENDA (VERDE)", paginaPai)
    
    Componentes:CriarBotaoEstilizado("🟩 Ligar/Desligar Cubo Seletor (Verde)", cFarm, zFarm, function() 
        if State.ScannerFazenda then State.ScannerFazenda:CriarSeletorFrontal() end 
    end)
    Componentes:CriarControlesEspaciais(cFarm, zFarm, "ScannerFazenda")
    
    Componentes:CriarToggleLargo("🌾 Auto-Fazenda Principal", cFarm, State, "AutoFarmingCrops", zFarm, function(v) 
        if Bot.Modules.Farmer then Bot.Modules.Farmer:AlternarAutoFazenda(v) end 
    end)
    Componentes:CriarBotaoEstilizado("🚜 Arar Terra dentro do Seletor Verde", cFarm, zFarm, function() 
        if Bot.Modules.Farmer then Bot.Modules.Farmer:ArarTerra() end 
    end)

    -- =================== SAVES E PLOTS (A MÁGICA DOS LOGS E ROTINAS) ===================
    local cFarmSaves, zFarmSaves = Componentes:CriarCard("SAVER DE TERRAS & PLOTS", paginaPai)
    
    local rSaveNomeF = Instance.new("Frame", cFarmSaves)
    rSaveNomeF.Size = UDim2.new(0.95, 0, 0, 32)
    rSaveNomeF.BackgroundTransparency = 1
    rSaveNomeF.ZIndex = zFarmSaves + 2
    rSaveNomeF.LayoutOrder = Componentes:GetInnerOrder()
    
    local inputPlotFarming = Componentes:CriarInputLargo("Escreva Nome da Área...", rSaveNomeF, zFarmSaves)
    local plotDropdownFarming = Componentes:CriarDropdown("Lista de Saves de Farm", cFarmSaves, State.FarmSettings, "CurrentSaveName", false, zFarmSaves, false)

    local function AtualizarListaSavesFarming()
        if Bot.Modules.PlotManager and plotDropdownFarming then
            local plots = Bot.Modules.PlotManager:ObterTodos()
            local lista = {}
            for nome, _ in pairs(plots) do 
                if nome:sub(1, 8) == "Farming_" then table.insert(lista, nome:sub(9)) end
            end
            if #lista == 0 then lista = {"Nenhum"} end
            plotDropdownFarming:Refresh(lista)
        end
    end

    -- [Ação]: SALVAR NOVO
    local btnSavePlotFarm = Componentes:CriarBotaoEstilizado("💾 Salvar Plot", rSaveNomeF, zFarmSaves, function()
        local nomePuro = inputPlotFarming.Text
        local cubo = State.ScannerFazenda and State.ScannerFazenda.AncoraPart
        
        if nomePuro == "" then
            if Manager then Manager:AtualizarStatus("❌ ERRO: Escreva um nome na caixa!") end return
        elseif not cubo then
            if Manager then Manager:AtualizarStatus("❌ ERRO: Crie o cubo na tela primeiro!") end return
        end

        Bot.Modules.PlotManager:SalvarPlot("Farming_" .. nomePuro, cubo.Position, cubo.Size)
        AtualizarListaSavesFarming()
        if Manager then Manager:AtualizarStatus("✅ SAVE DA FAZENDA: [" .. nomePuro .. "] Gravado!") end
        inputPlotFarming.Text = "" 
    end)
    btnSavePlotFarm.Size = UDim2.new(0.35, 0, 1, 0)
    btnSavePlotFarm.Position = UDim2.new(0.65, 5, 0, 0)
    btnSavePlotFarm.BackgroundColor3 = Color3.fromRGB(0, 160, 50)

    local rAcoesF = Componentes:CriarGridTripla(cFarmSaves, zFarmSaves)
    
    -- [Ação]: CARREGAR O DROP ATUAL NO MAPA
    Componentes:CriarBotaoPequeno("Carregar", Color3.fromRGB(40, 150, 80), rAcoesF, zFarmSaves, function()
        local sn = State.FarmSettings.CurrentSaveName
        if not sn or sn == "Nenhum" or sn == "Carregando..." then 
            if Manager then Manager:AtualizarStatus("❌ Selecione um save válido na lista!") end return 
        end
        local p = Bot.Modules.PlotManager:ObterTodos()["Farming_" .. sn]
        if p and State.ScannerFazenda then 
            State.ScannerFazenda:CarregarPlot(Vector3.new(p.PosX, p.PosY, p.PosZ), Vector3.new(p.SizeX, p.SizeY, p.SizeZ)) 
            if Manager then Manager:AtualizarStatus("✅ LOAD CONCLUÍDO: Plot [" .. sn .. "]") end
        else
            if Manager then Manager:AtualizarStatus("❌ Erro ao achar os dados do Save!") end
        end
    end)
    
    -- [Ação]: REESCREVER PLOT ATUAL
    Componentes:CriarBotaoPequeno("Substituir", Color3.fromRGB(200, 120, 20), rAcoesF, zFarmSaves, function()
        local sn = State.FarmSettings.CurrentSaveName
        local cubo = State.ScannerFazenda and State.ScannerFazenda.AncoraPart
        if not sn or sn == "Nenhum" then 
            if Manager then Manager:AtualizarStatus("❌ Selecione na lista qual reescrever!") end return 
        elseif not cubo then
            if Manager then Manager:AtualizarStatus("❌ Crie o cubo primeiro na nova posição!") end return
        end
        
        Bot.Modules.PlotManager:SalvarPlot("Farming_" .. sn, cubo.Position, cubo.Size) 
        if Manager then Manager:AtualizarStatus("🔄 PLOT SOBREPOSTO: O save [" .. sn .. "] foi modificado!") end
    end)
    
    -- [Ação]: DELETAR PLOT ATUAL DA LISTA
    Componentes:CriarBotaoPequeno("Excluir", Color3.fromRGB(200, 50, 50), rAcoesF, zFarmSaves, function()
        local sn = State.FarmSettings.CurrentSaveName
        if not sn or sn == "Nenhum" then return end
        Bot.Modules.PlotManager:DeletarPlot("Farming_" .. sn)
        State.FarmSettings.CurrentSaveName = "Nenhum"
        AtualizarListaSavesFarming()
        if Manager then Manager:AtualizarStatus("🗑️ PLOT DELETADO: Apagamos [" .. sn .. "] com sucesso!") end
    end)
    
    local rowFAutoSave = Componentes:CriarGridDupla(cFarmSaves, zFarmSaves)
    Componentes:CriarCheckboxMetade("Autoload na Entrada", rowFAutoSave, State.FarmSettings, "AutoUseSelectedSave", zFarmSaves)
    Componentes:CriarCheckboxMetade("Esconder Numbers plot", rowFAutoSave, State.ScannerFazenda, "HideNumbers", zFarmSaves, function()
        if State.ScannerFazenda then State.ScannerFazenda:EscanearArea() end
    end)

    -- =================== CONFIGS DESEMPENHO E SEMENTES ===================
    local cFarmCfg, zFarmCfg = Componentes:CriarCard("DESEMPENHO (FAZENDA)", paginaPai)
    local rowF1 = Componentes:CriarGridDupla(cFarmCfg, zFarmCfg)
    Componentes:CriarCheckboxMetade("Usar Voo Direcionado", rowF1, State.FarmSettings, "TweenToTarget", zFarmCfg)
    Componentes:CriarInputMetade("Veloc. do Voo", rowF1, State.FarmSettings, "TweenSpeed", 20, zFarmCfg)
    local rowF2 = Componentes:CriarGridDupla(cFarmCfg, zFarmCfg)
    Componentes:CriarCheckboxMetade("Arar + Substituir", rowF2, State.FarmSettings, "AutoReplace", zFarmCfg)
    Componentes:CriarCheckboxMetade("Colocar Gramas", rowF2, State.FarmSettings, "PlaceGrass", zFarmCfg)
    
    local cSeed, zSeed = Componentes:CriarCard("CONTROLE: PLANTIOS DA SEMENTE", paginaPai)
    local dropPessoal = Componentes:CriarDropdown("Semente Na Mochila:", cSeed, State, "SementeSelecionada", true, zSeed + 100, true)
    local dropPriorize = Componentes:CriarDropdown("Geral Jogo/Prioridades:", cSeed, State.FarmSettings, "PrioritizePlant", false, zSeed + 50, true)
    
    Componentes:CriarBotaoEstilizado("🔄 Scan/Sincronizar Listas de Sementes", cSeed, zSeed, function()
        if Bot.Modules.Manager then
            dropPessoal:Refresh(Bot.Modules.Manager:GetInventoryTools("Seed"))
            local globals = Bot.Modules.Manager:GetAllSeedsInGame()
            table.insert(globals, 1, "Nenhum") 
            dropPriorize:Refresh(globals)
            Manager:AtualizarStatus("🌱 Banco de Sementes Escaneado e Atualizado!")
        end
    end)

    task.spawn(function()
        task.wait(1.5) 
        AtualizarListaSavesFarming()
        if Bot.Modules.Manager then
            dropPessoal:Refresh(Bot.Modules.Manager:GetInventoryTools("Seed"))
            local glob = Bot.Modules.Manager:GetAllSeedsInGame()
            table.insert(glob, 1, "Nenhum")
            dropPriorize:Refresh(glob)
        end
    end)
end

return FazendaTab