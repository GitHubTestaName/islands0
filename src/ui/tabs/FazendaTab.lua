-- src/ui/tabs/FazendaTab.lua
local FazendaTab = {}

function FazendaTab:Construir(paginaPai)
    local Bot = _G.IslandsBot
    local State = Bot.State
    local Componentes = Bot.Modules.UIComponents

    Componentes:ResetOrder()

    -- MAIN FARM
    local cFarm, zFarm = Componentes:CriarCard("MAIN FARM", paginaPai)
    Componentes:CriarToggleLargo("Start Farm", cFarm, State, "AutoFarmingCrops", zFarm, function(v) 
        if Bot.Modules.Farmer then Bot.Modules.Farmer:AlternarAutoFazenda(v) end 
    end)
    local rFarm1 = Componentes:CriarGridDupla(cFarm, zFarm)
    Componentes:CriarCheckboxMetade("Plow Grass", rFarm1, State.FarmSettings, "PlowGrass", zFarm)
    Componentes:CriarCheckboxMetade("Place Grass", rFarm1, State.FarmSettings, "PlaceGrass", zFarm)
    local rFarm2 = Componentes:CriarGridDupla(cFarm, zFarm)
    Componentes:CriarCheckboxMetade("Auto Replace", rFarm2, State.FarmSettings, "AutoReplace", zFarm)

    -- SEED SELECT
    local cSeed, zSeed = Componentes:CriarCard("SEED SELECT", paginaPai)
    local DropdownSementes = Componentes:CriarDropdown("Sementes Pessoais", cSeed, State, "SementeSelecionada", true, zSeed, false)
    local PriorizeDropdown = Componentes:CriarDropdown("Priorize Plant", cSeed, State.FarmSettings, "PrioritizePlant", false, zSeed, true)
    Componentes:CriarBotaoEstilizado("🔄 Atualizar Mochila", cSeed, zSeed, function()
        if Bot.Modules.Manager then 
            pcall(function()
                local sementesPessoais = Bot.Modules.Manager:GetInventoryTools("Seed")
                DropdownSementes:Refresh(sementesPessoais)
                local sementesGerais = Bot.Modules.Manager:GetAllSeedsInGame()
                PriorizeDropdown:Refresh(sementesGerais)
            end)
        end
    end)

    -- CONFIG & DELAY
    local cDelay, zDelay = Componentes:CriarCard("CONFIG & DELAY", paginaPai)
    local rDelay1 = Componentes:CriarGridDupla(cDelay, zDelay)
    Componentes:CriarInputMetade("Harvest:", rDelay1, State.FarmSettings, "HarvestDelay", 0.1, zDelay)
    Componentes:CriarInputMetade("Plant:", rDelay1, State.FarmSettings, "PlantDelay", 0.15, zDelay)
    local rDelay2 = Componentes:CriarGridDupla(cDelay, zDelay)
    Componentes:CriarCheckboxMetade("Tween/Voo", rDelay2, State.FarmSettings, "TweenToTarget", zDelay)
    Componentes:CriarInputMetade("Vel. Voo:", rDelay2, State.FarmSettings, "TweenSpeed", 20, zDelay)
    local rDelay3 = Componentes:CriarGridDupla(cDelay, zDelay)
    Componentes:CriarCheckboxMetade("Esconder Nums", rDelay3, State.ScannerFazenda, "HideNumbers", zDelay, function()
        if State.ScannerFazenda then State.ScannerFazenda:EscanearArea() end
    end)

    -- SELECTOR & SAVES
    local cSave, zSave = Componentes:CriarCard("SELECTOR & SAVES", paginaPai)
    Componentes:CriarBotaoEstilizado("🟩 Ligar/Desligar Cubo Verde", cSave, zSave, function() 
        if State.ScannerFazenda then State.ScannerFazenda:CriarSeletorFrontal() end 
    end)
    Componentes:CriarControlesEspaciais(cSave, zSave, "ScannerFazenda")

    local rSaveNome = Instance.new("Frame", cSave)
    rSaveNome.Size = UDim2.new(0.95, 0, 0, 32)
    rSaveNome.BackgroundTransparency = 1
    rSaveNome.ZIndex = zSave + 2
    rSaveNome.LayoutOrder = Componentes:GetInnerOrder()
    
    local inputPlotFazenda = Componentes:CriarInputLargo("Nome do seu Plot...", rSaveNome, zSave)
    
    local plotDropdownFazenda = Componentes:CriarDropdown("Selecionar Save", cSave, State.FarmSettings, "CurrentSaveName", false, zSave - 5, false)

    local function AtualizarListaSavesFazenda()
        if Bot.Modules.PlotManager and plotDropdownFazenda then
            pcall(function()
                local plots = Bot.Modules.PlotManager:ObterTodos()
                local lista = {}
                for nome, _ in pairs(plots) do 
                    if nome:sub(1, 8) == "Farming_" then table.insert(lista, nome:sub(9)) end
                end
                if #lista == 0 then lista = {"Nenhum"} end
                plotDropdownFazenda:Refresh(lista)
            end)
        end
    end

    -- EXCELENTE EXEMPLO DE CONCATENAÇÃO DE ESTILOS!
    -- Criamos o botão com a nossa fábrica, e depois alteramos apenas o que nos interessa!
    local btnSavePlotFazenda = Componentes:CriarBotaoEstilizado("💾 Salvar", rSaveNome, zSave, function()
        local cubo = State.ScannerFazenda and State.ScannerFazenda.AncoraPart
        if inputPlotFazenda.Text ~= "" and cubo then
            Bot.Modules.PlotManager:SalvarPlot("Farming_" .. inputPlotFazenda.Text, cubo.Position, cubo.Size)
            AtualizarListaSavesFazenda()
            inputPlotFazenda.Text = ""
        end
    end)
    
    -- Aqui eu sobrescrevo (concateno) as propriedades visuais
    btnSavePlotFazenda.Size = UDim2.new(0.35, 0, 1, 0)
    btnSavePlotFazenda.Position = UDim2.new(0.65, 5, 0, 0)
    btnSavePlotFazenda.BackgroundColor3 = Color3.fromRGB(0, 160, 220)

    local rAcoesF = Componentes:CriarGridTripla(cSave, zSave)
    Componentes:CriarBotaoPequeno("Load", Color3.fromRGB(40, 150, 80), rAcoesF, zSave, function()
        local sn = State.FarmSettings.CurrentSaveName
        if sn and sn ~= "Nenhum" then
            local p = Bot.Modules.PlotManager:ObterTodos()["Farming_" .. sn]
            if p and State.ScannerFazenda then State.ScannerFazenda:CarregarPlot(Vector3.new(p.PosX, p.PosY, p.PosZ), Vector3.new(p.SizeX, p.SizeY, p.SizeZ)) end
        end
    end)
    Componentes:CriarBotaoPequeno("Rewrite", Color3.fromRGB(200, 120, 20), rAcoesF, zSave, function()
        local sn = State.FarmSettings.CurrentSaveName
        local cubo = State.ScannerFazenda and State.ScannerFazenda.AncoraPart
        if sn and sn ~= "Nenhum" and cubo then Bot.Modules.PlotManager:SalvarPlot("Farming_" .. sn, cubo.Position, cubo.Size) end
    end)
    Componentes:CriarBotaoPequeno("Delete", Color3.fromRGB(200, 50, 50), rAcoesF, zSave, function()
        local sn = State.FarmSettings.CurrentSaveName
        if sn and sn ~= "Nenhum" then
            Bot.Modules.PlotManager:DeletarPlot("Farming_" .. sn)
            State.FarmSettings.CurrentSaveName = "Nenhum"
            AtualizarListaSavesFazenda()
        end
    end)
    
    local rSave2F = Componentes:CriarGridDupla(cSave, zSave)
    Componentes:CriarCheckboxMetade("Auto Load Start", rSave2F, State.FarmSettings, "AutoUseSelectedSave", zSave)

    task.spawn(function()
        task.wait(1)
        pcall(function() AtualizarListaSavesFazenda() end)
        if Bot.Modules.Manager then
            pcall(function()
                local sementesGerais = Bot.Modules.Manager:GetAllSeedsInGame()
                local sementesPessoais = Bot.Modules.Manager:GetInventoryTools("Seed")
                DropdownSementes:Refresh(sementesPessoais)
                PriorizeDropdown:Refresh(sementesGerais)
            end)
        end
    end)
end

return FazendaTab