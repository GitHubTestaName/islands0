-- src/ui/Window.lua
local UI = {}
local Bot = _G.IslandsBot

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Islands Automation (Modular)",
    LoadingTitle = "Carregando Modulos...",
    LoadingSubtitle = "by Islands Script",
    ConfigurationSaving = { Enabled = false }
})

-- ABA PRINCIPAL
local TabAutofarm = Window:CreateTab("Principal", nil)

local ParagraphStatus = TabAutofarm:CreateParagraph({
    Title = "Status do Sistema", 
    Content = "> Ocioso"
})

function UI:SetStatusText(texto)
    ParagraphStatus:Set({ Title = "Status do Sistema", Content = "> " .. tostring(texto) })
end

TabAutofarm:CreateButton({
    Name = "1. Gerar/Alinhar Seletor Frontal",
    Callback = function()
        local Scanner = Bot.Modules.Scanner
        if Scanner then Scanner:CriarSeletorFrontal() end
    end,
})

local ToggleMinerar = TabAutofarm:CreateToggle({
    Name = "2. Autofarm Mineracao",
    CurrentValue = false,
    Flag = "ToggleMiner",
    Callback = function(Value)
        local Miner = Bot.Modules.Miner
        if Miner then Miner:Alternar(Value) end
    end,
})

TabAutofarm:CreateButton({
    Name = "3. Preencher Area (Construir)",
    Callback = function()
        local Builder = Bot.Modules.Builder
        if Builder then Builder:ColocarAreaMarcada() end
    end,
})

-- NOVA ABA: FAZENDA
local TabFazenda = Window:CreateTab("Fazenda", nil)

TabFazenda:CreateButton({
    Name = "Arar Terra Selecionada",
    Callback = function()
        if Bot.Modules.Farmer then Bot.Modules.Farmer:ArarTerra() end
    end,
})

TabFazenda:CreateButton({
    Name = "Plantar Sementes (Equipe na mao)",
    Callback = function()
        if Bot.Modules.Farmer then Bot.Modules.Farmer:PlantarSementes() end
    end,
})

TabFazenda:CreateButton({
    Name = "Colher Area Selecionada",
    Callback = function()
        if Bot.Modules.Farmer then Bot.Modules.Farmer:ColherPlantacoes() end
    end,
})

TabAutofarm:CreateButton({
    Name = "Descarregar Script",
    Callback = function()
        if Bot.Modules.Miner then Bot.Modules.Miner:Alternar(false) end
        if Bot.Modules.Scanner then Bot.Modules.Scanner:LimparAncora() end
        Rayfield:Destroy()
    end,
})

return UI