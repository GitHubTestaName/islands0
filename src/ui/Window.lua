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
    Name = "🟦 Gerar / Alinhar Cubo Azul",
    Callback = function()
        local Scanner = Bot.Modules.Scanner
        if Scanner then Scanner:CriarSeletorFrontal() end
    end,
})

TabSeletor:CreateSection("Controle por Teclado (Keybinds)")
TabSeletor:CreateParagraph({
    Title = "Dica de Movimentação Pro",
    Content = "Use as setas do seu teclado para mover o cubo azul rapidamente sem precisar clicar na tela!"
})

TabSeletor:CreateKeybind({
    Name = "Mover para Frente",
    CurrentKeybind = "Up",
    HoldToInteract = false,
    Flag = "KeyFrente",
    Callback = function() if Bot.Modules.Scanner then Bot.Modules.Scanner:MoverSeletor("Frente") end end,
})
TabSeletor:CreateKeybind({
    Name = "Mover para Tras",
    CurrentKeybind = "Down",
    HoldToInteract = false,
    Flag = "KeyTras",
    Callback = function() if Bot.Modules.Scanner then Bot.Modules.Scanner:MoverSeletor("Tras") end end,
})
TabSeletor:CreateKeybind({
    Name = "Mover para Esquerda",
    CurrentKeybind = "Left",
    HoldToInteract = false,
    Flag = "KeyEsq",
    Callback = function() if Bot.Modules.Scanner then Bot.Modules.Scanner:MoverSeletor("Esquerda") end end,
})
TabSeletor:CreateKeybind({
    Name = "Mover para Direita",
    CurrentKeybind = "Right",
    HoldToInteract = false,
    Flag = "KeyDir",
    Callback = function() if Bot.Modules.Scanner then Bot.Modules.Scanner:MoverSeletor("Direita") end end,
})

TabSeletor:CreateSection("Controle Vertical (Altura)")
TabSeletor:CreateKeybind({
    Name = "Subir Cubo (+3)",
    CurrentKeybind = "PageUp",
    HoldToInteract = false,
    Flag = "KeySubir",
    Callback = function() if Bot.Modules.Scanner then Bot.Modules.Scanner:MoverSeletor("Subir") end end,
})
TabSeletor:CreateKeybind({
    Name = "Descer Cubo (-3)",
    CurrentKeybind = "PageDown",
    HoldToInteract = false,
    Flag = "KeyDescer",
    Callback = function() if Bot.Modules.Scanner then Bot.Modules.Scanner:MoverSeletor("Descer") end end,
})

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
    Name = "🚜 Arar Terra Selecionada",
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
    Name = "🟢 Iniciar Auto-Fazenda (Colher + Plantar)",
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