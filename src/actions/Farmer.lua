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
                if not State.AncoraPart then break end

                for _, dados in ipairs(State.ListaBlocos) do
                    if not State.AutoFarmingCrops then break end
                    
                    local blocoRaiz = dados.Instancia
                    if not blocoRaiz or not blocoRaiz.Parent then continue end
                    
                    local n = blocoRaiz.Name:lower()
                    local terraBruta = n:find("grass") or n:find("dirt")
                    local terraArada = n:find("soil") or n:find("plowed") or n:find("farm")
                    
                    if terraBruta or terraArada then
                        local posPlanta = dados.Posicao + Vector3.new(0, Config.BLOCK_SIZE, 0)
                        local plantaObj = nil

                        for _, obj in ipairs(blocoRaiz.Parent:GetChildren()) do
                            if obj ~= blocoRaiz and obj.Name ~= "SelectionAnchor_Script" then
                                local objPos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
                                if math.abs(objPos.X - posPlanta.X) < 1.5 and 
                                   math.abs(objPos.Z - posPlanta.Z) < 1.5 and 
                                   math.abs(objPos.Y - posPlanta.Y) < 2.5 then
                                    plantaObj = obj
                                    break
                                end
                            end
                        end

                        if plantaObj then
                            local payload = {
                                dZnpyRtxna = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nsDahbvdxZludavlcoipDDMYasPlcm",
                                player = LocalPlayer,
                                model = plantaObj
                            }
                            pcall(function() Manager.HarvestRemote:InvokeServer(payload) end)
                            task.wait(0.1)
                        else
                            if terraBruta then
                                pcall(function() Manager.PlowRemote:InvokeServer({ block = blocoRaiz }) end)
                                task.wait(0.1)
                            elseif terraArada then
                                local nomeSemente = State.SementeSelecionada
                                if nomeSemente and nomeSemente ~= "" and nomeSemente ~= "Nenhum item encontrado" then
                                    local char = LocalPlayer.Character
                                    local tool = LocalPlayer.Backpack:FindFirstChild(nomeSemente) or (char and char:FindFirstChild(nomeSemente))
                                    
                                    if tool then
                                        if char and tool.Parent == LocalPlayer.Backpack then
                                            char.Humanoid:EquipTool(tool)
                                            task.wait(0.05)
                                        end
                                        
                                        local targetCFrame = CFrame.new(math.round(dados.Posicao.X/3)*3, dados.Posicao.Y + 3, math.round(dados.Posicao.Z/3)*3)
                                        local payload = {
                                            uwhiHAMdjExWka = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nffEgdldU",
                                            cframe = targetCFrame,
                                            blockType = tool.Name,
                                            upperBlock = false
                                        }
                                        pcall(function() Manager.PlaceRemote:InvokeServer(payload) end)
                                        task.wait(0.1)
                                    end
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
        -- AQUi ESTAVA O ERRO! Corrigido para "AtualizarStatus"
        if Manager then Manager:AtualizarStatus("Ocioso") end
    end
end

return Farmer