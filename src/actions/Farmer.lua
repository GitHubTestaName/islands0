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
            if bloco and bloco.Parent and (bloco.Name:lower():find("grass") or bloco.Name:lower():find("dirt")) then
                pcall(function() Manager.PlowRemote:InvokeServer({ block = bloco }) end)
                task.wait(0.05)
            end
        end
        if Manager then Manager:AtualizarStatus("Área arada!") end
    end)
end

-- LOOP INTELIGENTE DE AUTO-FAZENDA (Colhe e Planta)
function Farmer:AlternarAutoFazenda(valor)
    State.AutoFarmingCrops = valor
    local Manager = Bot.Modules.Manager

    if valor then
        if Manager then Manager:AtualizarStatus("Auto-Fazenda Iniciada...") end
        task.spawn(function()
            while State.AutoFarmingCrops do
                if not State.AncoraPart then
                    if Manager then Manager:AtualizarStatus("ERRO: Crie o seletor!") end
                    State.AutoFarmingCrops = false
                    break
                end

                for _, dados in ipairs(State.ListaBlocos) do
                    if not State.AutoFarmingCrops then break end
                    
                    local blocoRaiz = dados.Instancia
                    if not blocoRaiz or not blocoRaiz.Parent then continue end
                    
                    -- Avalia apenas os blocos de terra da área selecionada
                    if blocoRaiz.Name:lower():find("grass") or blocoRaiz.Name:lower():find("dirt") then
                        local posPlanta = dados.Posicao + Vector3.new(0, Config.BLOCK_SIZE, 0)
                        local plantaObj = nil

                        for _, obj in ipairs(blocoRaiz.Parent:GetChildren()) do
                            local objPos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
                            if (objPos - posPlanta).Magnitude < 1.5 then
                                plantaObj = obj
                                break
                            end
                        end

                        if plantaObj then
                            -- 1. Existe planta -> COLHER
                            local payload = {
                                dZnpyRtxna = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nsDahbvdxZludavlcoipDDMYasPlcm",
                                player = LocalPlayer,
                                model = plantaObj
                            }
                            pcall(function() Manager.HarvestRemote:InvokeServer(payload) end)
                            task.wait(0.15)
                        else
                            -- 2. Não existe planta -> PLANTAR
                            local nomeSemente = State.SementeSelecionada
                            if nomeSemente and nomeSemente ~= "" and nomeSemente ~= "Nenhuma ferramenta encontrada" then
                                local char = LocalPlayer.Character
                                local tool = LocalPlayer.Backpack:FindFirstChild(nomeSemente) or (char and char:FindFirstChild(nomeSemente))
                                
                                if tool then
                                    if char and tool.Parent == LocalPlayer.Backpack then
                                        char.Humanoid:EquipTool(tool)
                                        task.wait(0.1)
                                    end
                                    
                                    -- CFrame PURO alinhado com a grelha do mundo, sem rotação "torta"
                                    local targetCFrame = CFrame.new(dados.Posicao + Vector3.new(0, Config.BLOCK_SIZE, 0))
                                    local payload = {
                                        uwhiHAMdjExWka = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nffEgdldU",
                                        cframe = targetCFrame,
                                        blockType = tool.Name,
                                        upperBlock = false
                                    }
                                    pcall(function() Manager.PlaceRemote:InvokeServer(payload) end)
                                    task.wait(0.15)
                                end
                            end
                        end
                    end
                end
                task.wait(2) -- Pausa de 2s para não sobrecarregar o servidor do jogo entre os ciclos
            end
            if Manager then Manager:AtualizarStatus("Auto-Fazenda Parada") end
        end)
    else
        if Manager then Manager:AtualizarStatus("Ocioso") end
    end
end

return Farmer