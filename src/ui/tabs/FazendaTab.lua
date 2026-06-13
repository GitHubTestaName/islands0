-- src/ui/tabs/FazendaTab.lua
local FazendaTab = {}

function FazendaTab:Construir(paginaPai)
    local Bot = _G.IslandsBot
    local State = Bot.State
    local Componentes = Bot.Modules.UIComponents

    Componentes:ResetOrder()

    ------------------------------------------------------
    -- CARD 1: MAIN FARM (Com controles gerais e seletor ativo)
    ------------------------------------------------------
    local cFarm, zFarm = Componentes:CriarCard("CONTROLE DA FAZENDA (VERDE)", paginaPai)
    
    Componentes:CriarBotaoEstilizado("🟩 Ligar/Desligar Cubo Seletor (Verde)", cFarm, zFarm, function() 
        if State.ScannerFazenda then State.ScannerFazenda:CriarSeletorFrontal() end 
    end)
    -- Controles D-pad Espaciais 
    Componentes:CriarControlesEspaciais(cFarm, zFarm, "ScannerFazenda")
    
    -- Alternadores Auto 
    Componentes:CriarToggleLargo("🌾 Auto-Fazenda Principal", cFarm, State, "AutoFarmingCrops", zFarm, function(v) 
        if Bot.Modules.Farmer then Bot.Modules.Farmer:AlternarAutoFazenda(v) end 
    end)
    Componentes:CriarBotaoEstilizado("🚜 Arar Terra dentro do Seletor Verde", cFarm, zFarm, function() 
        if Bot.Modules.Farmer then Bot.Modules.Farmer:ArarTerra() end 
    end)


    ------------------------------------------------------
    -- CARD 2: OS SAVES & PLOTAGEM EXCLUSIVAS DA FAZENDA!
    ------------------------------------------------------
    local cFarmSaves, zFarmSaves = Componentes:CriarCard("SAVER DE TERRAS & PLOTS", paginaPai)
    
    local rSaveNomeF = Instance.new("Frame", cFarmSaves)
    rSaveNomeF.Size = UDim2.new(0.95, 0, 0, 32)
    rSaveNomeF.BackgroundTransparency = 1
    rSaveNomeF.ZIndex = zFarmSaves + 2
    rSaveNomeF.LayoutOrder = Componentes:GetInnerOrder()
    
    local inputPlotFarming = Componentes:CriarInputLargo("Escreva Nome da Área...", rSaveNomeF, zFarmSaves)
    local plotDropdownFarming = Componentes:CriarDropdown("Plots de Farm", cFarmSaves, State.FarmSettings, "CurrentSaveName", false, zFarmSaves, false)

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

    local btnSavePlotFarm = Componentes:CriarBotaoEstilizado("💾 Salvar Plot", rSaveNomeF, zFarmSaves, function()
        local cubo = State.ScannerFazenda and State.ScannerFazenda.AncoraPart
        if inputPlotFarming.Text ~= "" and cubo then
            Bot.Modules.PlotManager:SalvarPlot("Farming_" .. inputPlotFarming.Text, cubo.Position, cubo.Size)
            AtualizarListaSavesFarming()
            inputPlotFarming.Text = "" 
        end
    end)
    
    btnSavePlotFarm.Size = UDim2.new(0.35, 0, 1, 0)
    btnSavePlotFarm.Position = UDim2.new(0.65, 5, 0, 0)
    btnSavePlotFarm.BackgroundColor3 = Color3.fromRGB(0, 160, 50) 

    local rAcoesF = Componentes:CriarGridTripla(cFarmSaves, zFarmSaves)
    Componentes:CriarBotaoPequeno("Carregar", Color3.fromRGB(40, 150, 80), rAcoesF, zFarmSaves, function()
        local sn = State.FarmSettings.CurrentSaveName
        if sn and sn ~= "Nenhum" then
            local p = Bot.Modules.PlotManager:ObterTodos()["Farming_" .. sn]
            if p and State.ScannerFazenda then 
                State.ScannerFazenda:CarregarPlot(Vector3.new(p.PosX, p.PosY, p.PosZ), Vector3.new(p.SizeX, p.SizeY, p.SizeZ)) 
            end
        end
    end)
    
    Componentes:CriarBotaoPequeno("Substituir", Color3.fromRGB(200, 120, 20), rAcoesF, zFarmSaves, function()
        local sn = State.FarmSettings.CurrentSaveName
        local cubo = State.ScannerFazenda and State.ScannerFazenda.AncoraPart
        if sn and sn ~= "Nenhum" and cubo then 
            Bot.Modules.PlotManager:SalvarPlot("Farming_" .. sn, cubo.Position, cubo.Size) 
        end
    end)
    
    Componentes:CriarBotaoPequeno("Excluir", Color3.fromRGB(200, 50, 50), rAcoesF, zFarmSaves, function()
        local sn = State.FarmSettings.CurrentSaveName
        if sn and sn ~= "Nenhum" then
            Bot.Modules.PlotManager:DeletarPlot("Farming_" .. sn)
            State.FarmSettings.CurrentSaveName = "Nenhum"
            AtualizarListaSavesFarming()
        end
    end)
    
    local rowFAutoSave = Componentes:CriarGridDupla(cFarmSaves, zFarmSaves)
    Componentes:CriarCheckboxMetade("Autocarregar Plot Start", rowFAutoSave, State.FarmSettings, "AutoUseSelectedSave", zFarmSaves)
    Componentes:CriarCheckboxMetade("Esconder Numbers plot", rowFAutoSave, State.ScannerFazenda, "HideNumbers", zFarmSaves, function()
        if State.ScannerFazenda then State.ScannerFazenda:EscanearArea() end
    end)


    ------------------------------------------------------
    -- CARD 3: TWEAKS, AJUSTES e DELAYS
    ------------------------------------------------------
    local cFarmCfg, zFarmCfg = Componentes:CriarCard("DESEMPENHO (FAZENDA)", paginaPai)
    local rowF1 = Componentes:CriarGridDupla(cFarmCfg, zFarmCfg)
    Componentes:CriarCheckboxMetade("Teletransporte Voo", rowF1, State.FarmSettings, "TweenToTarget", zFarmCfg)
    Componentes:CriarInputMetade("Aceler. Voo", rowF1, State.FarmSettings, "TweenSpeed", 20, zFarmCfg)

    local rowF2 = Componentes:CriarGridDupla(cFarmCfg, zFarmCfg)
    Componentes:CriarCheckboxMetade("Quebra/Recoloca Auto", rowF2, State.FarmSettings, "AutoReplace", zFarmCfg)
    Componentes:CriarCheckboxMetade("Forçar Repor Terra/Grama", rowF2, State.FarmSettings, "PlaceGrass", zFarmCfg)
    

    ------------------------------------------------------
    -- CARD 4: DROPDOWNS SEMENTES (CORREÇÃO DE RENDERIZACAO!)
    ------------------------------------------------------
    local cSeed, zSeed = Componentes:CriarCard("CONTROLE: PLANTIOS DA SEMENTE", paginaPai)

    -- Note as matemáticas absolutas: Colocamos (+100), e em quem fica abaixo apenas (+50).
    -- Assim quando este abrir sua tela do drop list ele VAI SOBREPOR qualquer um sem medo:
    local dropPessoal = Componentes:CriarDropdown("Inventário Mochila Pessoal:", cSeed, State, "SementeSelecionada", true, zSeed + 100, true)
    local dropPriorize = Componentes:CriarDropdown("Puxar Geral do Jogo Server", cSeed, State.FarmSettings, "PrioritizePlant", false, zSeed + 50, true)
    
    -- Deixamos em (zSeed) inalterado de fundo do Card normal!
    Componentes:CriarBotaoEstilizado("🔄 Sincronizar Listas Inventário Semente", cSeed, zSeed, function()
        if Bot.Modules.Manager then
            dropPessoal:Refresh(Bot.Modules.Manager:GetInventoryTools("Seed"))
            
            local globalItensListadosNoLadoDaPasta = Bot.Modules.Manager:GetAllSeedsInGame()
            table.insert(globalItensListadosNoLadoDaPasta, 1, "Nenhum") 
            dropPriorize:Refresh(globalItensListadosNoLadoDaPasta)
        end
    end)

    ------------------------------------------------------
    -- START / CARREGA INVISIVEL NO GAME LOGS:
    ------------------------------------------------------
    task.spawn(function()
        task.wait(2) 
        AtualizarListaSavesFarming()
        
        if Bot.Modules.Manager then
            dropPessoal:Refresh(Bot.Modules.Manager:GetInventoryTools("Seed"))
            local itensListadoEmGlobalArray = Bot.Modules.Manager:GetAllSeedsInGame()
            table.insert(itensListadoEmGlobalArray, 1, "Nenhum")
            dropPriorize:Refresh(itensListadoEmGlobalArray)
        end
    end)
end

return FazendaTab