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
    local Scanner = State.ScannerFazenda
    if not Scanner or not Scanner.AncoraPart then return end
    if Manager then Manager:AtualizarStatus("Arando a terra abaixo do seletor...") end

    local minCoord = Scanner.AncoraPart.Position - (Scanner.AncoraPart.Size / 2)
    local maxCoord = Scanner.AncoraPart.Position + (Scanner.AncoraPart.Size / 2)

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
        -- INTEGRAÇÃO COM OS SAVES: Carrega automaticamente se estiver marcado
        if State.FarmSettings.AutoUseSelectedSave and State.FarmSettings.CurrentSaveName then
            local PlotManager = Bot.Modules.PlotManager
            local plots = PlotManager:ObterTodos()
            local plot = plots[State.FarmSettings.CurrentSaveName]
            if plot and State.ScannerFazenda then
                State.ScannerFazenda:CarregarPlot(Vector3.new(plot.PosX, plot.PosY, plot.PosZ), Vector3.new(plot.SizeX, plot.SizeY, plot.SizeZ))
            end
        end

        local Scanner = State.ScannerFazenda
        if not Scanner or not Scanner.AncoraPart then 
            if Manager then Manager:AtualizarStatus("Crie o seletor da fazenda primeiro!") end
            State.AutoFarmingCrops = false
            return 
        end

        if Manager then Manager:AtualizarStatus("Auto-Fazenda Ativa...") end
        task.spawn(function()
            while State.AutoFarmingCrops do
                if not Scanner.AncoraPart then break end

                local stateSementes = State.SementeSelecionada
                if type(stateSementes) ~= "table" then stateSementes = {["All"] = true} end
                
                local char = LocalPlayer.Character
                local sementesNoInventario = Manager:GetInventoryTools("Seed")
                local sementesDisponiveis = {}
                
                for _, sementeNome in ipairs(sementesNoInventario) do
                    if sementeNome ~= "Nenhum item encontrado" then
                        if stateSementes["All"] or stateSementes[sementeNome] then
                            table.insert(sementesDisponiveis, sementeNome)
                        end
                    end
                end

                -- A LÓGICA DE PRIORIDADE QUE VOCÊ PEDIU
                local prioridade = State.FarmSettings.PrioritizePlant
                if prioridade and prioridade ~= "Nenhum" then
                    table.sort(sementesDisponiveis, function(a, b) return a == prioridade end)
                end

                local minCoord = Scanner.AncoraPart.Position - (Scanner.AncoraPart.Size / 2)
                local maxCoord = Scanner.AncoraPart.Position + (Scanner.AncoraPart.Size / 2)

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
                                    task.wait(State.FarmSettings.HarvestDelay or 0.1)
                                    continue 
                                end
                            end
                            
                            -- A INTELIGÊNCIA DO BURACO (Place Grass)
                            if not blocoSolo and State.FarmSettings.PlaceGrass then
                                local blockGrass = LocalPlayer.Backpack:FindFirstChild("grass") or (char and char:FindFirstChild("grass"))
                                if blockGrass then
                                    local payload = {
                                        uwhiHAMdjExWka = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nffEgdldU",
                                        cframe = CFrame.new(posSolo),
                                        blockType = blockGrass.Name,
                                        upperBlock = false
                                    }
                                    pcall(function() Manager.PlaceRemote:InvokeServer(payload) end)
                                    task.wait(0.15)
                                    blocoSolo = ObterBlocoPorPosicao(posSolo, 1.0) -- Atualiza a memória
                                end
                            end

                            if blocoSolo then
                                local nSolo = blocoSolo.Name:lower()
                                local terraBruta = nSolo:find("grass") or nSolo:find("dirt")
                                local terraArada = nSolo:find("soil") or nSolo:find("plowed") or nSolo:find("farm")
                                
                                -- A INTELIGÊNCIA DO ARADO AUTOMÁTICO (Plow Grass)
                                if terraBruta and State.FarmSettings.PlowGrass then
                                    pcall(function() Manager.PlowRemote:InvokeServer({ block = blocoSolo }) end)
                                    task.wait(0.1)
                                    terraArada = true 
                                end
                                
                                -- A INTELIGÊNCIA DE REPOSIÇÃO (Auto Replace Seed)
                                if terraArada and State.FarmSettings.AutoReplace then
                                    local ferramentaEquipar = nil
                                    for _, semente in ipairs(sementesDisponiveis) do
                                        ferramentaEquipar = (char and char:FindFirstChild(semente)) or LocalPlayer.Backpack:FindFirstChild(semente)
                                        if ferramentaEquipar then break end
                                    end

                                    if ferramentaEquipar then
                                        if char and ferramentaEquipar.Parent == LocalPlayer.Backpack then
                                            char.Humanoid:EquipTool(ferramentaEquipar)
                                            task.wait(0.05)
                                        end

                                        local blockTypeReal = ferramentaEquipar.Name:gsub("Seeds", ""):gsub("seeds", "")
                                        local targetCFrame = CFrame.new(posPlanta)
                                        
                                        local payload = {
                                            uwhiHAMdjExWka = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nffEgdldU",
                                            cframe = targetCFrame,
                                            blockType = blockTypeReal,
                                            upperBlock = false
                                        }
                                        pcall(function() Manager.PlaceRemote:InvokeServer(payload) end)
                                        task.wait(State.FarmSettings.PlantDelay or 0.15)
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