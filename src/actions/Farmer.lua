-- src/actions/Farmer.lua
local Players = game:GetService("Players")
local Farmer = {}
local Bot = _G.IslandsBot
local State = Bot.State
local Config = Bot.Config
local LocalPlayer = Players.LocalPlayer

local function ObterBlocoPorPosicao(pos, raio)
    local Manager = Bot.Modules.Manager
    local partes = workspace:GetPartBoundsInRadius(pos, raio)
    local melhorBloco = nil
    local menorDistancia = 999
    
    for _, p in ipairs(partes) do
        local lowerName = p.Name:lower()
        if lowerName ~= "trunk" and lowerName ~= "top" and lowerName ~= "selectionanchor_script" then
            local rootBlock = Manager:ObterBlocoRaiz(p)
            if rootBlock and rootBlock.Name ~= "SelectionAnchor_Script" then
                local objPos = rootBlock:IsA("Model") and rootBlock:GetPivot().Position or rootBlock.Position
                
                if math.abs(objPos.X - pos.X) < 1.5 and math.abs(objPos.Z - pos.Z) < 1.5 then
                    local dist = (objPos - pos).Magnitude
                    if dist < menorDistancia then
                        menorDistancia = dist
                        melhorBloco = rootBlock
                    end
                end
            end
        end
    end
    return melhorBloco
end

function Farmer:ArarTerra()
    local Manager = Bot.Modules.Manager
    if not State.AncoraPart then return end
    if Manager then Manager:AtualizarStatus("Arando a terra abaixo do seletor...") end

    local minCoord = State.AncoraPart.Position - (State.AncoraPart.Size / 2)
    local maxCoord = State.AncoraPart.Position + (State.AncoraPart.Size / 2)

    task.spawn(function()
        for x = minCoord.X + (Config.BLOCK_SIZE/2), maxCoord.X, Config.BLOCK_SIZE do
            for y = minCoord.Y + (Config.BLOCK_SIZE/2), maxCoord.Y, Config.BLOCK_SIZE do
                for z = minCoord.Z + (Config.BLOCK_SIZE/2), maxCoord.Z, Config.BLOCK_SIZE do
                    
                    local posPlanta = Vector3.new(x, y, z)
                    local posSolo = posPlanta - Vector3.new(0, Config.BLOCK_SIZE, 0)
                    
                    local blocoSolo = ObterBlocoPorPosicao(posSolo, 1.0)
                    if blocoSolo then
                        local n = blocoSolo.Name:lower()
                        if n:find("grass") or n:find("dirt") then
                            pcall(function() Manager.PlowRemote:InvokeServer({ block = blocoSolo }) end)
                            task.wait(0.05)
                        end
                    end
                end
            end
        end
        if Manager then Manager:AtualizarStatus("Área arada!") end
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

                -- =======================================================
                -- NOVO PRÉ-EQUIPAMENTO (Suporta ALL e Multi-Seleção!)
                -- =======================================================
                local stateSementes = State.SementeSelecionada
                if type(stateSementes) ~= "table" then stateSementes = {["All"] = true} end
                
                local char = LocalPlayer.Character
                local toolEmUso = nil
                local sementesNoInventario = Manager:GetInventoryTools("Seed")
                
                for _, sementeNome in ipairs(sementesNoInventario) do
                    if sementeNome ~= "Nenhum item encontrado" then
                        -- Se for 'All', pega a primeira. Se for específica, verifica no dicionário.
                        if stateSementes["All"] or stateSementes[sementeNome] then
                            toolEmUso = (char and char:FindFirstChild(sementeNome)) or LocalPlayer.Backpack:FindFirstChild(sementeNome)
                            if toolEmUso then
                                if char and toolEmUso.Parent == LocalPlayer.Backpack then
                                    char.Humanoid:EquipTool(toolEmUso)
                                    task.wait(0.5) 
                                end
                                break -- Já achamos e equipamos uma semente válida!
                            end
                        end
                    end
                end

                local minCoord = State.AncoraPart.Position - (State.AncoraPart.Size / 2)
                local maxCoord = State.AncoraPart.Position + (State.AncoraPart.Size / 2)

                for x = minCoord.X + (Config.BLOCK_SIZE/2), maxCoord.X, Config.BLOCK_SIZE do
                    if not State.AutoFarmingCrops then break end
                    for y = minCoord.Y + (Config.BLOCK_SIZE/2), maxCoord.Y, Config.BLOCK_SIZE do
                        if not State.AutoFarmingCrops then break end
                        for z = minCoord.Z + (Config.BLOCK_SIZE/2), maxCoord.Z, Config.BLOCK_SIZE do
                            if not State.AutoFarmingCrops then break end
                            
                            local posPlanta = Vector3.new(x, y, z)
                            local posSolo = posPlanta - Vector3.new(0, Config.BLOCK_SIZE, 0)
                            
                            local plantaObj = ObterBlocoPorPosicao(posPlanta, 1.5)
                            local blocoSolo = ObterBlocoPorPosicao(posSolo, 1.0)

                            if plantaObj then
                                local nPlanta = plantaObj.Name:lower()
                                if not nPlanta:find("grass") and not nPlanta:find("dirt") and not nPlanta:find("soil") and not nPlanta:find("farm") and not nPlanta:find("plowed") then
                                    local payload = {
                                        dZnpyRtxna = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nsDahbvdxZludavlcoipDDMYasPlcm",
                                        player = LocalPlayer,
                                        model = plantaObj
                                    }
                                    pcall(function() Manager.HarvestRemote:InvokeServer(payload) end)
                                    task.wait(0.1)
                                    continue 
                                end
                            end
                            
                            if blocoSolo then
                                local nSolo = blocoSolo.Name:lower()
                                local terraBruta = nSolo:find("grass") or nSolo:find("dirt")
                                local terraArada = nSolo:find("soil") or nSolo:find("plowed") or nSolo:find("farm")
                                
                                if terraBruta then
                                    pcall(function() Manager.PlowRemote:InvokeServer({ block = blocoSolo }) end)
                                    task.wait(0.1)
                                elseif terraArada then
                                    if toolEmUso then
                                        local blockTypeReal = toolEmUso.Name:gsub("Seeds", ""):gsub("seeds", "")
                                        local targetCFrame = CFrame.new(posPlanta)
                                        
                                        local payload = {
                                            uwhiHAMdjExWka = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nffEgdldU",
                                            cframe = targetCFrame,
                                            blockType = blockTypeReal,
                                            upperBlock = false
                                        }
                                        pcall(function() Manager.PlaceRemote:InvokeServer(payload) end)
                                        task.wait(0.15)
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