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
                local n = bloco.Name:lower()
                if n:find("grass") or n:find("dirt") then
                    pcall(function() Manager.PlowRemote:InvokeServer({ block = bloco }) end)
                    task.wait(0.05)
                end
            end
        end
        if Manager then Manager:AtualizarStatus("Area arada!") end
    end)
end

function Farmer:AlternarAutoFazenda(valor)
    State.AutoFarmingCrops = valor
    local Manager = Bot.Modules.Manager

    if valor then
        if Manager then Manager:AtualizarStatus("Auto-Fazenda Ativa...") end
        task.spawn(function()
            while State.AutoFarmingCrops do
                if not State.AncoraPart then
                    if Manager then Manager:AtualizarStatus("ERRO: Seletor sumiu!") end
                    State.AutoFarmingCrops = false
                    break
                end

                for _, dados in ipairs(State.ListaBlocos) do
                    if not State.AutoFarmingCrops then break end
                    
                    local blocoRaiz = dados.Instancia
                    if not blocoRaiz or not blocoRaiz.Parent then continue end
                    
                    local n = blocoRaiz.Name:lower()
                    -- Filtro expandido para abranger qualquer tipo de solo do jogo
                    if n:find("grass") or n:find("dirt") or n:find("soil") or n:find("plowed") or n:find("farm") then
                        local posPlanta = dados.Posicao + Vector3.new(0, Config.BLOCK_SIZE, 0)
                        local plantaObj = nil

                        for _, obj in ipairs(blocoRaiz.Parent:GetChildren()) do
                            if obj ~= blocoRaiz and obj.Name ~= "SelectionAnchor_Script" then
                                local objPos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
                                
                                -- ALINHAMENTO DE GRID DE ALTA PRECISÃO (Resolve o problema do Trigo)
                                if math.abs(objPos.X - posPlanta.X) < 1.5 and 
                                   math.abs(objPos.Z - posPlanta.Z) < 1.5 and 
                                   math.abs(objPos.Y - posPlanta.Y) < 2.5 then
                                    plantaObj = obj
                                    break
                                end
                            end
                        end

                        if plantaObj then
                            -- 1. Se achou qualquer objeto em cima da terra, manda colher
                            local payload = {
                                dZnpyRtxna = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nsDahbvdxZludavlcoipDDMYasPlcm",
                                player = LocalPlayer,
                                model = plantaObj
                            }
                            pcall(function() Manager.HarvestRemote:InvokeServer(payload) end)
                            task.wait(0.05)
                        else
                            -- 2. Se a terra está vazia, auto-equipa a semente selecionada e planta
                            local nomeSemente = State.SementeSelecionada
                            if nomeSemente and nomeSemente ~= "" and nomeSemente ~= "Nenhum item encontrado" then
                                local char = LocalPlayer.Character
                                local tool = LocalPlayer.Backpack:FindFirstChild(nomeSemente) or (char and char:FindFirstChild(nomeSemente))
                                
                                if tool then
                                    if char and tool.Parent == LocalPlayer.Backpack then
                                        char.Humanoid:EquipTool(tool)
                                        task.wait(0.05)
                                    end
                                    
                                    local payload = {
                                        uwhiHAMdjExWka = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nffEgdldU",
                                        cframe = CFrame.new(dados.Posicao + Vector3.new(0, Config.BLOCK_SIZE, 0)),
                                        blockType = tool.Name,
                                        upperBlock = false
                                    }
                                    pcall(function() Manager.PlaceRemote:InvokeServer(payload) end)
                                    task.wait(0.05)
                                end
                            end
                        end
                    end
                end
                task.wait(1)
            end
            if Manager then Manager:AtualizarStatus("Auto-Fazenda Desligada") end
        end)
    else
        if Manager then Manager:AndyualizarStatus("Ocioso") end
    end
end

return Farmer