-- src/ui/Window.lua
local UI = {}
local Bot = _G.IslandsBot

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Islands Automation",
    LoadingTitle = "Carregando Módulos...",
    LoadingSubtitle = "Modular Framework",
    ConfigurationSaving = { Enabled = false }
})

-- ================= ABA 1: SELETOR ESPACIAL =================
local TabSeletor = Window:CreateTab("1. Seletor", nil)

local ParagraphStatus = TabSeletor:CreateParagraph({
    Title = "Status do Sistema", 
    Content = "> Ocioso"
})

function UI:SetStatusText(texto)
    ParagraphStatus:Set({ Title = "Status do Sistema", Content = "> " .. tostring(texto) })
end

TabSeletor:CreateButton({
    Name = "🟦 Gerar Cubo Azul no Personagem",
    Callback = function()
        local Scanner = Bot.Modules.Scanner
        if Scanner then Scanner:CriarSeletorFrontal() end
    end,
})

TabSeletor:CreateSection("Mover Cubo (Horizontal)")
TabSeletor:CreateButton({ Name = "Mover para Frente", Callback = function() Bot.Modules.Scanner:MoverSeletor("Frente") end })
TabSeletor:CreateButton({ Name = "Mover para Tras", Callback = function() Bot.Modules.Scanner:MoverSeletor("Tras") end })
TabSeletor:CreateButton({ Name = "Mover para Esquerda", Callback = function() Bot.Modules.Scanner:MoverSeletor("Esquerda") end })
TabSeletor:CreateButton({ Name = "Mover para Direita", Callback = function() Bot.Modules.Scanner:MoverSeletor("Direita") end })

TabSeletor:CreateSection("Mover Cubo (Vertical)")
TabSeletor:CreateButton({ Name = "Subir Cubo", Callback = function() Bot.Modules.Scanner:MoverSeletor("Subir") end })
TabSeletor:CreateButton({ Name = "Descer Cubo", Callback = function() Bot.Modules.Scanner:MoverSeletor("Descer") end })

-- ================= ABA 2: AÇÕES GERAIS =================
local TabAcoes = Window:CreateTab("2. Ações", nil)

TabAcoes:CreateToggle({
    Name = "⛏️ Autofarm Mineração (Loop)",
    CurrentValue = false,
    Flag = "ToggleMiner",
    Callback = function(Value)
        local Miner = Bot.Modules.Miner
        if Miner then Miner:Alternar(Value) end
    end,
})

TabAcoes:CreateSection("Construção Automática")
local DropdownBlocos = TabAcoes:CreateDropdown({
    Name = "Bloco Selecionado",
    Options = {"Nenhum item encontrado"},
    CurrentOption = {"Nenhum item encontrado"},
    MultipleOptions = false,
    Callback = function(Option) Bot.State.BlocoSelecionado = Option[1] end,
})

TabAcoes:CreateButton({
    Name = "🔄 Atualizar Inventário de Blocos",
    Callback = function()
        if Bot.Modules.Manager then DropdownBlocos:Refresh(Bot.Modules.Manager:GetInventoryTools("Block"), true) end
    end,
})

TabAcoes:CreateButton({
    Name = "🔨 Preencher Área Selecionada",
    Callback = function()
        local Builder = Bot.Modules.Builder
        if Builder then Builder:ColocarAreaMarcada() end
    end,
})

-- ================= ABA 3: FAZENDA =================
local TabFazenda = Window:CreateTab("3. Fazenda", nil)

TabFazenda:CreateButton({
    Name = "🚜 Arar Terra Manualmente",
    Callback = function()
        if Bot.Modules.Farmer then Bot.Modules.Farmer:ArarTerra() end
    end,
})

TabFazenda:CreateSection("Sementes e Autofarm")
local DropdownSementes = TabFazenda:CreateDropdown({
    Name = "Semente Selecionada",
    Options = {"Nenhum item encontrado"},
    CurrentOption = {"Nenhum item encontrado"},
    MultipleOptions = false,
    Callback = function(Option) Bot.State.SementeSelecionada = Option[1] end,
})

TabFazenda:CreateButton({
    Name = "🔄 Atualizar Inventário de Sementes",
    Callback = function()
        if Bot.Modules.Manager then DropdownSementes:Refresh(Bot.Modules.Manager:GetInventoryTools("Seed"), true) end
    end,
})

TabFazenda:CreateToggle({
    Name = "🟢 Auto-Fazenda (Ara, Planta e Colhe)",
    CurrentValue = false,
    Flag = "ToggleFarmer",
    Callback = function(Value)
        local Farmer = Bot.Modules.Farmer
        if Farmer then Farmer:AlternarAutoFazenda(Value) end
    end,
})

-- ================= ABA 4: SISTEMA =================
local TabSistema = Window:CreateTab("4. Sistema", nil)

TabSistema:CreateButton({
    Name = "Descarregar Script e Limpar Tela",
    Callback = function()
        if Bot.Modules.Miner then Bot.Modules.Miner:Alternar(false) end
        if Bot.Modules.Farmer then Bot.Modules.Farmer:AlternarAutoFazenda(false) end
        if Bot.Modules.Scanner then Bot.Modules.Scanner:LimparAncora() end
        Rayfield:Destroy()
    end,
})

return UI