-- src/ui/Window.lua
local UI = {}
local Bot = _G.IslandsBot

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Islands Automation (Modular)",
    LoadingTitle = "Carregando Modulos...",
    LoadingSubtitle = "by Islands Script",
    ConfigurationSaving = {
        Enabled = false
    }
})

-- Criação das Abas
local TabGeral = Window:CreateTab("Geral/Seletor", nil)
local TabFarms = Window:CreateTab("Autofarms", nil)
local TabAgricultura = Window:CreateTab("Agricultura", nil)

-- Elemento de status dinâmico
local ParagraphStatus = TabGeral:CreateParagraph({
    Title = "Status do Sistema", 
    Content = "> Ocioso"
})

function UI:SetStatusText(texto)
    ParagraphStatus:Set({
        Title = "Status do Sistema",
        Content = "> " .. tostring(texto)
    })
end

-- ==========================================
-- ABA GERAL: Controles do Seletor
-- ==========================================
TabGeral:CreateButton({
    Name = "Criar/Alinhar Seletor Frontal",
    Callback = function()
        local Scanner = Bot.Modules.Scanner
        if Scanner then Scanner:CriarSeletorFrontal() end
    end,
})

TabGeral:CreateButton({
    Name = "Limpar Seletor",
    Callback = function()
        local Scanner = Bot.Modules.Scanner
        if Scanner then Scanner:LimparAncora() end
    end,
})

-- ==========================================
-- ABA AUTOFARMS: Mineração e Construção
-- ==========================================
TabFarms:CreateToggle({
    Name = "Autofarm Mineração",
    CurrentValue = false,
    Flag = "ToggleMiner",
    Callback = function(Value)
        local Miner = Bot.Modules.Miner
        if Miner then Miner:Alternar(Value) end
    end,
})

TabFarms:CreateButton({
    Name = "Preencher Área (Colocar Blocos)",
    Callback = function()
        local Builder = Bot.Modules.Builder
        if Builder then Builder:ColocarAreaMarcada() end
    end,
})

-- ==========================================
-- ABA AGRICULTURA: Colheita, Replantio e Aração
-- ==========================================
TabAgricultura:CreateToggle({
    Name = "Auto Colheita (Crops, Berries e Frutas)",
    CurrentValue = false,
    Flag = "ToggleHarvest",
    Callback = function(Value)
        local Harvester = Bot.Modules.Harvester
        if Harvester then Harvester:SetAtivo(Value) end
    end,
})

TabAgricultura:CreateToggle({
    Name = "Auto Replantar (Segure a Semente na Mão)",
    CurrentValue = false,
    Flag = "ToggleReplant",
    Callback = function(Value)
        local Harvester = Bot.Modules.Harvester
        if Harvester then Harvester:SetAutoReplant(Value) end
    end,
})

TabAgricultura:CreateButton({
    Name = "Arar Área Selecionada",
    Callback = function()
        local Plower = Bot.Modules.Plower
        if Plower then Plower:ArarArea() end
    end,
})

-- Botão global de encerramento do script
TabGeral:CreateButton({
    Name = "Descarregar Script",
    Callback = function()
        local Scanner = Bot.Modules.Scanner
        local Miner = Bot.Modules.Miner
        local Builder = Bot.Modules.Builder
        local Harvester = Bot.Modules.Harvester

        if Miner then Miner:Alternar(false) end
        if Builder then Builder:Cancelar() end
        if Harvester then Harvester:SetAtivo(false) end
        if Scanner then Scanner:LimparAncora() end
        
        Rayfield:Destroy()
    end,
})

return UI