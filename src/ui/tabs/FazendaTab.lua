-- src/ui/tabs/FazendaTab.lua
local FazendaTab = {}

function FazendaTab:Construir(paginaPai)
    local Bot = _G.IslandsBot
    local State = Bot.State
    local Componentes = Bot.Modules.UIComponents
    local Manager = Bot.Modules.Manager

    Componentes:ResetOrder()

    -- ================= CAIXA 1: AÇÕES (AUTO-FARM) =================
    local cFarm, zFarm = Componentes:CriarCard("AÇÕES (PLANTAÇÕES)", paginaPai)
    
    Componentes:CriarToggleLargo("🌾 Auto Fazenda", cFarm, State, "AutoFarmingCrops", zFarm, function(v) 
        if Bot.Modules.Farmer then Bot.Modules.Farmer:AlternarAutoFazenda(v) end 
    end)
    Componentes:CriarBotaoEstilizado("🚜 Arar Terra Rápido", cFarm, zFarm, function() 
        if Bot.Modules.Farmer then Bot.Modules.Farmer:ArarTerra() end 
    end)

    -- Caixa Segura das Sementes Com Elevado Z-Index Pro Dropdown Sobreviver sobre Tudo:
    local dropPessoal = Componentes:CriarDropdown("Da Sua Mochila:", cFarm, State, "SementeSelecionada", true, zFarm + 60, true)
    local dropPriorize = Componentes:CriarDropdown("Busca Geral Alvo:", cFarm, State.FarmSettings, "PrioritizePlant", false, zFarm + 40, true)
    
    Componentes:CriarBotaoEstilizado("🔄 Escanear Sementes Novamente", cFarm, zFarm, function()
        if Manager then
            dropPessoal:Refresh(Manager:GetInventoryTools("Seed"))
            local globais = Manager:GetAllSeedsInGame()
            table.insert(globais, 1, "Nenhum") 
            dropPriorize:Refresh(globais)
            Manager:AtualizarStatus("🌱 Banco de Sementes Escaneado e Atualizado!")
        end
    end)


    -- ================= CAIXA 2: O SELETOR =================
    local cSelVerde, zSelVerde = Componentes:CriarCard("CONTROLE DO SELETOR VERDE", paginaPai)
    
    Componentes:CriarBotaoEstilizado("🟩 Exibir / Ocultar Cubo", cSelVerde, zSelVerde, function() 
        if State.ScannerFazenda then State.ScannerFazenda:CriarSeletorFrontal() end 
    end)
    Componentes:CriarControlesEspaciais(cSelVerde, zSelVerde, "ScannerFazenda")
    
    local rCheckSelV = Componentes:CriarGridDupla(cSelVerde, zSelVerde)
    Componentes:CriarCheckboxMetade("Ocultar Números", rCheckSelV, State.ScannerFazenda, "HideNumbers", zSelVerde, function()
        if State.ScannerFazenda then State.ScannerFazenda:EscanearArea() end
    end)


    -- ================= CAIXA 3: SISTEMA DE SAVES (PLOT VERDE) =================
    local cFarmSaves, zFarmSaves = Componentes:CriarCard("GERENCIADOR DE TERRAS", paginaPai)
    
    local rSaveNomeF = Instance.new("Frame", cFarmSaves)
    rSaveNomeF.Size = UDim2.new(0.95, 0, 0, 32)
    rSaveNomeF.BackgroundTransparency = 1
    rSaveNomeF.ZIndex = zFarmSaves + 2
    rSaveNomeF.LayoutOrder = Componentes:GetInnerOrder()
    
    local inputPlotFarming = Componentes:CriarInputLargo("Nome do Save...", rSaveNomeF, zFarmSaves)
    local plotDropdownFarming = Componentes:CriarDropdown("Terras Salvas", cFarmSaves, State.FarmSettings, "CurrentSaveName", false, zFarmSaves + 20, false)

    local function AtualizarListaFarming()
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

    local btnSaveF = Componentes:CriarBotaoEstilizado("💾 Salvar", rSaveNomeF, zFarmSaves, function()
        local nomeStr = inputPlotFarming.Text
        local cubo = State.ScannerFazenda and State.ScannerFazenda.AncoraPart
        
        if nomeStr == "" then
            if Manager then Manager:AtualizarStatus("❌ ERRO: Faltou um Nome!") end return
        elseif not cubo then
            if Manager then Manager:AtualizarStatus("❌ ERRO: Crie o cubo Seletor!") end return
        end

        Bot.Modules.PlotManager:SalvarPlot("Farming_" .. nomeStr, cubo.Position, cubo.Size)
        AtualizarListaFarming()
        if Manager then Manager:AtualizarStatus("✅ SUCESSO: Fazenda '" .. nomeStr .. "' foi arquivada.") end
        inputPlotFarming.Text = "" 
    end)
    btnSaveF.Size = UDim2.new(0.35, 0, 1, 0)
    btnSaveF.Position = UDim2.new(0.65, 5, 0, 0)
    btnSaveF.BackgroundColor3 = Color3.fromRGB(0, 150, 60)

    local rAcoesF = Componentes:CriarGridTripla(cFarmSaves, zFarmSaves)
    
    Componentes:CriarBotaoPequeno("Load", Color3.fromRGB(40, 150, 80), rAcoesF, zFarmSaves, function()
        local sn = State.FarmSettings.CurrentSaveName
        if not sn or sn == "Nenhum" then return end
        local p = Bot.Modules.PlotManager:ObterTodos()["Farming_" .. sn]
        if p and State.ScannerFazenda then 
            State.ScannerFazenda:CarregarPlot(Vector3.new(p.PosX, p.PosY, p.PosZ), Vector3.new(p.SizeX, p.SizeY, p.SizeZ)) 
            if Manager then Manager:AtualizarStatus("✅ LOAD: Fazenda '" .. sn .. "' armada!") end
        end
    end)
    Componentes:CriarBotaoPequeno("Over-write", Color3.fromRGB(200, 120, 20), rAcoesF, zFarmSaves, function()
        local sn, cubo = State.FarmSettings.CurrentSaveName, State.ScannerFazenda and State.ScannerFazenda.AncoraPart
        if not sn or sn == "Nenhum" or not cubo then return end
        Bot.Modules.PlotManager:SalvarPlot("Farming_" .. sn, cubo.Position, cubo.Size) 
        if Manager then Manager:AtualizarStatus("🔄 ATUALIZADO: Regravou local da Fazenda '".. sn .."'.") end
    end)
    Componentes:CriarBotaoPequeno("Delete", Color3.fromRGB(200, 50, 50), rAcoesF, zFarmSaves, function()
        local sn = State.FarmSettings.CurrentSaveName
        if not sn or sn == "Nenhum" then return end
        Bot.Modules.PlotManager:DeletarPlot("Farming_" .. sn)
        State.FarmSettings.CurrentSaveName = "Nenhum"
        AtualizarListaFarming()
        if Manager then Manager:AtualizarStatus("🗑️ DELETADO: Fechamos de vez o plot '" .. sn .."'.") end
    end)
    
    local rCheckFarmLoad = Componentes:CriarGridDupla(cFarmSaves, zFarmSaves)
    Componentes:CriarCheckboxMetade("Autoload na Conexão", rCheckFarmLoad, State.FarmSettings, "AutoUseSelectedSave", zFarmSaves)


    -- ================= CAIXA 4: COMPORTAMENTO AUTOMÁTICO =================
    local cFarmCfg, zFarmCfg = Componentes:CriarCard("COMPORTAMENTO DA IA", paginaPai)
    
    local rowF1 = Componentes:CriarGridDupla(cFarmCfg, zFarmCfg)
    Componentes:CriarCheckboxMetade("Auto Tween Voo", rowF1, State.FarmSettings, "TweenToTarget", zFarmCfg)
    Componentes:CriarInputMetade("Velocid. Bot", rowF1, State.FarmSettings, "TweenSpeed", 20, zFarmCfg)
    
    local rowF2 = Componentes:CriarGridDupla(cFarmCfg, zFarmCfg)
    Componentes:CriarCheckboxMetade("Repor/Limpar Fim", rowF2, State.FarmSettings, "AutoReplace", zFarmCfg)
    Componentes:CriarCheckboxMetade("Construir Terra Pura", rowF2, State.FarmSettings, "PlaceGrass", zFarmCfg)
    
    -- Auto Load Inicial de dados e Preenchimento Listas.
    task.spawn(function()
        task.wait(1.5) 
        AtualizarListaFarming()
        if Manager then
            dropPessoal:Refresh(Manager:GetInventoryTools("Seed"))
            local glob = Manager:GetAllSeedsInGame()
            table.insert(glob, 1, "Nenhum")
            dropPriorize:Refresh(glob)
        end
    end)
end

return FazendaTab