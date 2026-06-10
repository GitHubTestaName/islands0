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
                -- Segurança: Só envia para o remote de arar se for terra ou grama
                if bloco.Name:lower():find("grass") or bloco.Name:lower():find("dirt") then
                    pcall(function() 
                        Manager.PlowRemote:InvokeServer({ block = bloco }) 
                    end)
                    task.wait(0.05) -- Respeitando o limite do servidor
                end
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
            local blocoRaiz = dados.Instancia
            if blocoRaiz and blocoRaiz.Parent then
                local alvoColheita = blocoRaiz
                
                -- IA de Colheita: Se o bloco selecionado for a terra, procura a planta 1 bloco acima!
                if blocoRaiz.Name:lower():find("grass") or blocoRaiz.Name:lower():find("dirt") then
                    local posPlanta = dados.Posicao + Vector3.new(0, Config.BLOCK_SIZE, 0)
                    
                    -- Varre a ilha para achar a planta (crop) exata no eixo superior
                    for _, obj in ipairs(blocoRaiz.Parent:GetChildren()) do
                        local objPos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
                        -- Se a posição bater (com margem de erro pequena para não dar ban)
                        if (objPos - posPlanta).Magnitude < 1.5 then
                            alvoColheita = obj
                            break
                        end
                    end
                end

                -- Se não achou planta nenhuma e o alvo continua sendo a terra, ignora e pula para o próximo
                if alvoColheita.Name:lower():find("grass") or alvoColheita.Name:lower():find("dirt") then
                    continue
                end

                local payload = {
                    dZnpyRtxna = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nsDahbvdxZludavlcoipDDMYasPlcm",
                    player = LocalPlayer,
                    model = alvoColheita
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
                -- IA de Plantio: Herda o CFrame (eixos de rotação exatos) da terra e sobe 1 bloco
                local baseCFrame = bloco:IsA("Model") and bloco:GetPivot() or bloco.CFrame
                local targetCFrame = baseCFrame + Vector3.new(0, Config.BLOCK_SIZE, 0)
                
                local payload = {
                    uwhiHAMdjExWka = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nffEgdldU",
                    cframe = targetCFrame,
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