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

                -- PRÉ-EQUIPAMENTO: Previne o erro "Something unexpectedly tried to set the parent"
                -- Equipa a ferramenta apenas uma vez no início do ciclo, fora da pressa do loop.
                local nomeSemente = State.SementeSelecionada
                local char = LocalPlayer.Character
                local toolEmUso = nil
                
                if nomeSemente and nomeSemente ~= "" and nomeSemente ~= "Nenhum item encontrado" then
                    toolEmUso = (char and char:FindFirstChild(nomeSemente)) or LocalPlayer.Backpack:FindFirstChild(nomeSemente)
                    if toolEmUso and char and toolEmUso.Parent == LocalPlayer.Backpack then
                        char.Humanoid:EquipTool(toolEmUso)
                        task.wait(0.5) -- Espera o Roblox mover a semente com calma e segurança
                    end
                end

                for _, dados in ipairs(State.ListaBlocos) do
                    if not State.AutoFarmingCrops then break end
                    
                    local blocoRaiz = dados.Instancia
                    
                    -- SISTEMA DE CURA DE MEMÓRIA (Auto-Heal)
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
                        
                        if novoBloco then
                            dados.Instancia = novoBloco
                            dados.Nome = novoBloco.Name
                            blocoRaiz = novoBloco
                        else
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
                            -- ETAPA 1: Colher
                            local payload = {
                                dZnpyRtxna = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nsDahbvdxZludavlcoipDDMYasPlcm",
                                player = LocalPlayer,
                                model = plantaObj
                            }
                            pcall(function() Manager.HarvestRemote:InvokeServer(payload) end)
                            task.wait(0.1)
                        else
                            if terraBruta then
                                -- ETAPA 2: Arar
                                pcall(function() Manager.PlowRemote:InvokeServer({ block = blocoRaiz }) end)
                                task.wait(0.1)
                            elseif terraArada then
                                -- ETAPA 3: Plantar
                                if toolEmUso then
                                    -- A MÁGICA DOS NOMES: Corta a palavra "Seeds"
                                    -- Exemplo: "wheatSeeds" -> "wheat"
                                    local blockTypeReal = toolEmUso.Name:gsub("Seeds", ""):gsub("seeds", "")
                                    
                                    local targetCFrame = CFrame.new(dados.Posicao.X, dados.Posicao.Y + Config.BLOCK_SIZE, dados.Posicao.Z)
                                    
                                    local payload = {
                                        uwhiHAMdjExWka = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nffEgdldU",
                                        cframe = targetCFrame,
                                        blockType = blockTypeReal, -- Enviando o nome limpo pro servidor!
                                        upperBlock = false
                                    }
                                    pcall(function() Manager.PlaceRemote:InvokeServer(payload) end)
                                    task.wait(0.15) -- Mais um pouquinho de delay seguro para o Place
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