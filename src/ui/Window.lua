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

-- ================= ABA PRINCIPAL =================
local TabAutofarm = Window:CreateTab("Principal", nil)

local ParagraphStatus = TabAutofarm:CreateParagraph({
    Title = "Status do Sistema", 
    Content = "> Ocioso"
})

function UI:SetStatusText(texto)
    ParagraphStatus:Set({ Title = "Status do Sistema", Content = "> " .. tostring(texto) })
end

TabAutofarm:CreateButton({
    Name = "1. Gerar Seletor Frontal",
    Callback = function()
        local Scanner = Bot.Modules.Scanner
        if Scanner then Scanner:CriarSeletorFrontal() end
    end,
})

-- SEÇÃO DE MOVIMENTAÇÃO DO SELETOR
local SecMover = TabAutofarm:CreateSection("Controle Direcional do Seletor")

TabAutofarm:CreateButton({
    Name = "          [^] Frente",
    Callback = function() if Bot.Modules.Scanner then Bot.Modules.Scanner:MoverSeletor("Frente") end end,
})
TabAutofarm:CreateButton({
    Name = "[<] Esquerda    |    [>] Direita",
    Callback = function() 
        -- Como o Rayfield executa em clique único, dividimos em botões separados abaixo para evitar confusão visual
    end,
})
TabAutofarm:CreateButton({
    Name = "     [<] Mover para Esquerda",
    Callback = function() if Bot.Modules.Scanner then Bot.Modules.Scanner:MoverSeletor("Esquerda") end end,
})
TabAutofarm:CreateButton({
    Name = "     [>] Mover para Direita",
    Callback = function() if Bot.Modules.Scanner then Bot.Modules.Scanner:MoverSeletor("Direita") end end,
})
TabAutofarm:CreateButton({
    Name = "          [v] Tras",
    Callback = function() if Bot.Modules.Scanner then Bot.Modules.Scanner:MoverSeletor("Tras") end end,
})

local SecMoverVertical = TabAutofarm:CreateSection("Eixo Vertical (Separado)")
TabAutofarm:CreateButton({
    Name = "Subir Altura (+3)",
    Callback = function() if Bot.Modules.Scanner then Bot.Modules.Scanner:MoverSeletor("Subir") end end,
})
TabAutofarm:CreateButton({
    Name = "Descer Altura (-3)",
    Callback = function() if Bot.Modules.Scanner then Bot.Modules.Scanner:MoverSeletor("Descer") end end,
})

local SecConstruir = TabAutofarm:CreateSection("Automacao de Construcao")

local DropdownBlocos = TabAutofarm:CreateDropdown({
    Name = "Filtrar Bloco para Construir",
    Options = {"Nenhum item encontrado"},
    CurrentOption = {"Nenhum item encontrado"},
    MultipleOptions = false,
    Callback = function(Option) Bot.State.BlocoSelecionado = Option[1] end,
})

TabAutofarm:CreateButton({
    Name = "🔄 Atualizar Blocos do Inventario",
    Callback = function()
        if Bot.Modules.Manager then
            DropdownBlocos:Refresh(Bot.Modules.Manager:GetInventoryTools("Block"), true)
        end
    end,
})

TabAutofarm:CreateButton({
    Name = "3. Preencher Area Selecionada",
    Callback = function()
        local Builder = Bot.Modules.Builder
        if Builder then Builder:ColocarAreaMarcada() end
    end,
})

TabAutofarm:CreateToggle({
    Name = "Autofarm Mineracao",
    CurrentValue = false,
    Flag = "ToggleMiner",
    Callback = function(Value)
        local Miner = Bot.Modules.Miner
        if Miner then Miner:Alternar(Value) end
    end,
})

-- ================= ABA FAZENDA INTELIGENTE =================
local TabFazenda = Window:CreateTab("Fazenda", nil)

TabFazenda:CreateButton({
    Name = "Arar Terra Selecionada",
    Callback = function()
        if Bot.Modules.Farmer then Bot.Modules.Farmer:ArarTerra() end
    end,
})

local DropdownSementes = TabFazenda:CreateDropdown({
    Name = "Filtrar Semente para Plantio",
    Options = {"Nenhum item encontrado"},
    CurrentOption = {"Nenhum item encontrado"},
    MultipleOptions = false,
    Callback = function(Option) Bot.State.SementeSelecionada = Option[1] end,
})

TabFazenda:CreateButton({
    Name = "🔄 Atualizar Sementes do Inventario",
    Callback = function()
        if Bot.Modules.Manager then
            DropdownSementes:Refresh(Bot.Modules.Manager:GetInventoryTools("Seed"), true)
        end
    end,
})

TabFazenda:CreateToggle({
    Name = "🟢 Iniciar Auto-Fazenda Loop (Colher + Plantar)",
    CurrentValue = false,
    Flag = "ToggleFarmer",
    Callback = function(Value)
        local Farmer = Bot.Modules.Farmer
        if Farmer then Farmer:AlternarAutoFazenda(Value) end
    end,
})

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