-- src/ui/tabs/FazendaTab.lua
local FazendaTab = {}

function FazendaTab:Construir(paginaPai)
    local Bot = _G.IslandsBot
    local State = Bot.State
    local Componentes = Bot.Modules.UIComponents -- Chamando a biblioteca principal de UI

    Componentes:ResetOrder() -- Reset do layout

    -- 1. CARD PRINCIPAL: CONTROLES DA FAZENDA (O Toggle On/Off e as Saves!)
    local cFarm, zFarm = Componentes:CriarCard("MAIN FARM & SELETOR", paginaPai)
    
    Componentes:CriarBotaoEstilizado("🟩 Criar Seletor de Fazenda", cFarm, zFarm, function() 
        if State.ScannerFazenda then State.ScannerFazenda:CriarSeletorFrontal() end 
    end)
    Componentes:CriarControlesEspaciais(cFarm, zFarm, "ScannerFazenda")
    
    Componentes:CriarToggleLargo("🌾 Iniciar Auto-Fazenda", cFarm, State, "AutoFarmingCrops", zFarm, function(v)
        if Bot.Modules.Farmer then Bot.Modules.Farmer:AlternarAutoFazenda(v) end 
    end)

    Componentes:CriarBotaoEstilizado("🚜 Arar Toda a Área Manualmente", cFarm, zFarm, function() 
        if Bot.Modules.Farmer then Bot.Modules.Farmer:ArarTerra() end 
    end)

    -- 2. CARD DE CONFIGURAÇÕES (Velocidade e Delays do Bot de Farm)
    local cFarmCfg, zFarmCfg = Componentes:CriarCard("TWEAKS DA FAZENDA", paginaPai)
    local rowF1 = Componentes:CriarGridDupla(cFarmCfg, zFarmCfg)
    Componentes:CriarCheckboxMetade("Voo Auto (Tween)", rowF1, State.FarmSettings, "TweenToTarget", zFarmCfg)
    Componentes:CriarInputMetade("Velocidade Voo", rowF1, State.FarmSettings, "TweenSpeed", 20, zFarmCfg)

    local rowF2 = Componentes:CriarGridDupla(cFarmCfg, zFarmCfg)
    Componentes:CriarCheckboxMetade("Repor/Arar auto", rowF2, State.FarmSettings, "PlowGrass", zFarmCfg)
    Componentes:CriarCheckboxMetade("Limpar números", rowF2, State.ScannerFazenda, "HideNumbers", zFarmCfg, function()
        if State.ScannerFazenda then State.ScannerFazenda:EscanearArea() end
    end)

    -- 3. CARD DAS SEMENTES! (Aqui está a grande mágica)
    local cSeed, zSeed = Componentes:CriarCard("SEED CONFIG & PLANTIO", paginaPai)

    -- True no final significa "temSearchBox", perfeito pra não precisar rolar mil nomes!
    local dropPessoal = Componentes:CriarDropdown("Mochila (O que quero plantar)", cSeed, State, "SementeSelecionada", true, zSeed, true)
    local dropPriorize = Componentes:CriarDropdown("Prioridade Geral do Bot", cSeed, State.FarmSettings, "PrioritizePlant", false, zSeed, true)
    
    Componentes:CriarBotaoEstilizado("🔄 Atualizar Listas de Sementes", cSeed, zSeed, function()
        if Bot.Modules.Manager then
            -- Mágica dos delays já integrada no refresh do manager
            local pessoais = Bot.Modules.Manager:GetInventoryTools("Seed")
            dropPessoal:Refresh(pessoais)
            local globais = Bot.Modules.Manager:GetAllSeedsInGame()
            table.insert(globais, 1, "Nenhum") -- Opção de "Limpar prioridade"
            dropPriorize:Refresh(globais)
        end
    end)

    -- Carrega inicialmente os itens sem bloquear o jogo!
    task.spawn(function()
        task.wait(1.5) -- Apenas um cooldown suave inicial pra n causar lag spike no script execution
        if Bot.Modules.Manager then
            local pt = Bot.Modules.Manager:GetInventoryTools("Seed")
            dropPessoal:Refresh(pt)
            
            local gt = Bot.Modules.Manager:GetAllSeedsInGame()
            table.insert(gt, 1, "Nenhum")
            dropPriorize:Refresh(gt)
        end
    end)
end

return FazendaTab