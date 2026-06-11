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
            if bloco and bloco:IsDescendantOf(workspace) then
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
                    
                    -- =================================================================
                    -- SISTEMA DE CURA DE MEMÓRIA (A solução da sua descoberta!)
                    -- Se a grama foi deletada pelo servidor para virar 'soil', 
                    -- o bloco morre. Nós capturamos o novo bloco na mesma posição.
                    -- =================================================================
                    if not blocoRaiz or not blocoRaiz:IsDescendantOf(workspace) then
                        local partes = workspace:GetPartBoundsInRadius(dados.Posicao, 0.5)
                        local novoBloco = nil
                        
                        for _, p in ipairs(partes) do
                            local lowerName = p.Name:lower()
                            if lowerName ~= "trunk" and lowerName ~= "top" then
                                local rb = Manager:ObterBlocoRaiz(p)
                                if rb and rb.Name ~= "SelectionAnchor_Script" then 
                                    novoBloco = rb 
                                    break 
                                end
                            end
                        end
                        
                        -- Atualiza a memória do bot com o novo 'soil'
                        if novoBloco then
                            dados.Instancia = novoBloco
                            dados.Nome = novoBloco.Name
                            blocoRaiz = novoBloco
                        else
                            -- Se realmente não tem nada lá, ignora
                            continue
                        end
                    end
                    
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
                            -- ETAPA 1: Tem planta, então Colhe
                            local payload = {
                                dZnpyRtxna = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nsDahbvdxZludavlcoipDDMYasPlcm",
                                player = LocalPlayer,
                                model = plantaObj
                            }
                            pcall(function() Manager.HarvestRemote:InvokeServer(payload) end)
                            task.wait(0.1)
                        else
                            -- Não tem planta
                            if terraBruta then
                                -- ETAPA 2: Grama normal, envia o remote de Arar!
                                pcall(function() Manager.PlowRemote:InvokeServer({ block = blocoRaiz }) end)
                                task.wait(0.1)
                            elseif terraArada then
                                -- ETAPA 3: Já é Soil, então planta usando o CFrame Exato!
                                local nomeSemente = State.SementeSelecionada
                                if nomeSemente and nomeSemente ~= "" and nomeSemente ~= "Nenhum item encontrado" then
                                    local char = LocalPlayer.Character
                                    local tool = LocalPlayer.Backpack:FindFirstChild(nomeSemente) or (char and char:FindFirstChild(nomeSemente))
                                    
                                    if tool then
                                        if char and tool.Parent == LocalPlayer.Backpack then
                                            char.Humanoid:EquipTool(tool)
                                            task.wait(0.05)
                                        end
                                        
                                        -- CFrame Puro, sem rotações malucas, espelhando perfeitamente a Terra
                                        local targetCFrame = CFrame.new(dados.Posicao.X, dados.Posicao.Y + Config.BLOCK_SIZE, dados.Posicao.Z)
                                        
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
        if Manager then Manager:AtualizarStatus("Ocioso") end
    end
end

return Farmer