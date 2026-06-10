-- src/ui/Window.lua
local UI = {}
local Bot = _G.IslandsBot

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Islands Automation (Modular)",
    LoadingTitle = "Carregando Módulos...",
    LoadingSubtitle = "by Islands Script",
    ConfigurationSaving = { Enabled = false }
})

-- ================= ABA PRINCIPAL (CONSTRUÇÃO / MINERAÇÃO) =================
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

TabAutofarm:CreateToggle({
    Name = "2. Autofarm Mineração",
    CurrentValue = false,
    Flag = "ToggleMiner",
    Callback = function(Value)
        local Miner = Bot.Modules.Miner
        if Miner then Miner:Alternar(Value) end
    end,
})

-- Secção de Construção Automática
local DropdownBlocos = TabAutofarm:CreateDropdown({
    Name = "Bloco para Construir",
    Options = {"Nenhuma ferramenta encontrada"},
    CurrentOption = {"Nenhuma ferramenta encontrada"},
    MultipleOptions = false,
    Callback = function(Option)
        Bot.State.BlocoSelecionado = Option[1]
    end,
})

TabAutofarm:CreateButton({
    Name = "🔄 Atualizar Inventário de Blocos",
    Callback = function()
        if Bot.Modules.Manager then
            DropdownBlocos:Refresh(Bot.Modules.Manager:GetInventoryTools(), true)
        end
    end,
})

TabAutofarm:CreateButton({
    Name = "3. Preencher Área (Auto-Equipa)",
    Callback = function()
        local Builder = Bot.Modules.Builder
        if Builder then Builder:ColocarAreaMarcada() end
    end,
})

-- ================= NOVA ABA: FAZENDA INTELIGENTE =================
local TabFazenda = Window:CreateTab("Fazenda", nil)

TabFazenda:CreateButton({
    Name = "Arar Terra Selecionada",
    Callback = function()
        if Bot.Modules.Farmer then Bot.Modules.Farmer:ArarTerra() end
    end,
})

local DropdownSementes = TabFazenda:CreateDropdown({
    Name = "Semente para Auto-Fazenda",
    Options = {"Nenhuma ferramenta encontrada"},
    CurrentOption = {"Nenhuma ferramenta encontrada"},
    MultipleOptions = false,
    Callback = function(Option)
        Bot.State.SementeSelecionada = Option[1]
    end,
})

TabFazenda:CreateButton({
    Name = "🔄 Atualizar Inventário de Sementes",
    Callback = function()
        if Bot.Modules.Manager then
            DropdownSementes:Refresh(Bot.Modules.Manager:GetInventoryTools(), true)
        end
    end,
})

TabFazenda:CreateToggle({
    Name = "🟢 Iniciar Auto-Fazenda (Colher + Plantar)",
    CurrentValue = false,
    Flag = "ToggleFarmer",
    Callback = function(Value)
        local Farmer = Bot.Modules.Farmer
        if Farmer then Farmer:AlternarAutoFazenda(Value) end
    end,
})

-- ================= SAÍDA =================
TabAutofarm:CreateButton({
    Name = "Descarregar Script",
    Callback = function()
        if Bot.Modules.Miner then Bot.Modules.Miner:Alternar(false) end
        if Bot.Modules.Farmer then Bot.Modules.Farmer:AlternarAutoFazenda(false) end
        if Bot.Modules.Scanner then Bot.Modules.Scanner:LimparAncora() end
        Rayfield:Destroy()
    end,
})

return UI