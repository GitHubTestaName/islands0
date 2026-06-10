-- src/actions/Farmer.lua
local Players = game:GetService("Players")
local Farmer = {}
local Bot = _G.IslandsBot
local State = Bot.State
local Config = Bot.Config
local LocalPlayer = Players.LocalPlayer

function Farmer:ArarTerra()
    local Manager = Bot.Modules.Manager
    if not State.AncoraPart then return end
    if Manager then Manager:AtualizarStatus("Arando a terra...") end

    task.spawn(function()
        for _, dados in ipairs(State.ListaBlocos) do
            local bloco = dados.Instancia
            if bloco and bloco.Parent then
                pcall(function() 
                    Manager.PlowRemote:InvokeServer({ block = bloco }) 
                end)
                task.wait(0.05) -- Respeitando o limite do servidor
            end
        end
        if Manager then Manager:AtualizarStatus("Area arada!") end
    end)
end

function Farmer:ColherPlantacoes()
    local Manager = Bot.Modules.Manager
    if not State.AncoraPart then return end
    if Manager then Manager:AtualizarStatus("Colhendo...") end

    task.spawn(function()
        for _, dados in ipairs(State.ListaBlocos) do
            local bloco = dados.Instancia
            if bloco and bloco.Parent then
                local payload = {
                    dZnpyRtxna = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nsDahbvdxZludavlcoipDDMYasPlcm",
                    player = LocalPlayer,
                    model = bloco
                }
                pcall(function() Manager.HarvestRemote:InvokeServer(payload) end)
                task.wait(0.05)
            end
        end
        if Manager then Manager:AtualizarStatus("Colheita finalizada!") end
    end)
end

function Farmer:PlantarSementes()
    local Manager = Bot.Modules.Manager
    if not State.AncoraPart then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then
        if Manager then Manager:AtualizarStatus("ERRO: Equipe a semente!") end
        return
    end

    if Manager then Manager:AtualizarStatus("Plantando: " .. tool.Name) end

    task.spawn(function()
        for _, dados in ipairs(State.ListaBlocos) do
            local bloco = dados.Instancia
            if bloco and bloco.Parent then
                -- IA Inteligente: Planta exatamente 1 bloco acima da terra selecionada
                local posAlvo = dados.Posicao + Vector3.new(0, Config.BLOCK_SIZE, 0)
                
                local payload = {
                    uwhiHAMdjExWka = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nffEgdldU",
                    cframe = CFrame.new(posAlvo),
                    blockType = tool.Name,
                    upperBlock = false
                }
                pcall(function() Manager.PlaceRemote:InvokeServer(payload) end)
                task.wait(0.05)
            end
        end
        if Manager then Manager:AtualizarStatus("Plantio finalizado!") end
    end)
end

return Farmer