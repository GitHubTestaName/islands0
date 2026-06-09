-- src/ui/Window.lua
local UI = {}
local Bot = _G.IslandsBot

-- Importação segura da biblioteca Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Islands Automation (Modular)",
    LoadingTitle = "Carregando Modulos...",
    LoadingSubtitle = "by Islands Script",
    ConfigurationSaving = {
        Enabled = false
    }
})

local TabAutofarm = Window:CreateTab("Autofarm", nil)

-- Elemento de texto dinâmico para os Status do Bot
local ParagraphStatus = TabAutofarm:CreateParagraph({
    Title = "Status do Sistema", 
    Content = "> Ocioso"
})

function UI:SetStatusText(texto)
    ParagraphStatus:Set({
        Title = "Status do Sistema",
        Content = "> " .. tostring(texto)
    })
end

-- 1. Botão Seletor Frontal
TabAutofarm:CreateButton({
    Name = "1. Gerar/Alinhar Seletor Frontal",
    Callback = function()
        local Scanner = Bot.Modules.Scanner
        if Scanner then
            Scanner:CriarSeletorFrontal()
        end
    end,
})

-- 2. Toggle de Autofarm de Mineração
local ToggleMinerar = TabAutofarm:CreateToggle({
    Name = "2. Autofarm Mineração",
    CurrentValue = false,
    Flag = "ToggleMiner",
    Callback = function(Value)
        local Miner = Bot.Modules.Miner
        if Miner then
            local success = Miner:Alternar(Value)
            if not success and Value == true then
                -- Se falhar (ex: sem seletor), força o visual do toggle a desligar
                warn("[UI] Falha ao iniciar autofarm. Seletor pode nao existir.")
            end
        end
    end,
})

-- 3. Botão para Construção (Place Blocks)
TabAutofarm:CreateButton({
    Name = "3. Preencher Area Selecionada",
    Callback = function()
        local Builder = Bot.Modules.Builder
        if Builder then
            Builder:ColocarAreaMarcada()
        end
    end,
})

-- Botão de Finalização e Descarregamento (Clean-up)
TabAutofarm:CreateButton({
    Name = "Descarregar Script",
    Callback = function()
        local Scanner = Bot.Modules.Scanner
        local Miner = Bot.Modules.Miner
        local Builder = Bot.Modules.Builder

        if Miner then Miner:Alternar(false) end
        if Builder then Builder:Cancelar() end
        if Scanner then Scanner:LimparAncora() end
        
        Rayfield:Destroy()
    end,
})

return UI