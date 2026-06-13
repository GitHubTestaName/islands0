-- src/actions/Farmer.lua
local Players = game:GetService("Players")
local Farmer = {}
local Bot = _G.IslandsBot
local State = Bot.State
local Config = Bot.Config
local LocalPlayer = Players.LocalPlayer

function Farmer:ArarTerra()
    local Manager = Bot.Modules.Manager
    local Scanner = State.ScannerFazenda
    if not Scanner or not Scanner.AncoraPart then return end
    local bounds = workspace:GetPartBoundsInBox(Scanner.AncoraPart.CFrame, Scanner.AncoraPart.Size)
    task.spawn(function()
        for _, p in ipairs(bounds) do
            local n = p.Name:lower()
            if n:find("grass") or n:find("dirt") then
                local root = Manager:ObterBlocoRaiz(p)
                if root then
                    pcall(function() Manager.PlowRemote:InvokeServer({ block = root }) end)
                    task.wait(0.05)
                end
            end
        end
    end)
end

function Farmer:AlternarAutoFazenda(valor)
    State.AutoFarmingCrops = valor
    local Manager = Bot.Modules.Manager
    local Navigator = Bot.Modules.Navigator

    if valor then
        if State.FarmSettings.AutoUseSelectedSave and State.FarmSettings.CurrentSaveName then
            local PlotManager = Bot.Modules.PlotManager
            local plots = PlotManager:ObterTodos()
            local plot = plots["Farming_" .. State.FarmSettings.CurrentSaveName]
            if plot and State.ScannerFazenda then
                State.ScannerFazenda:CarregarPlot(Vector3.new(plot.PosX, plot.PosY, plot.PosZ), Vector3.new(plot.SizeX, plot.SizeY, plot.SizeZ))
            end
        end

        local Scanner = State.ScannerFazenda
        if not Scanner or not Scanner.AncoraPart then 
            State.AutoFarmingCrops = false
            return 
        end

        task.spawn(function()
            while State.AutoFarmingCrops do
                if not Scanner.AncoraPart then break end

                local stateSementes = State.SementeSelecionada
                if type(stateSementes) ~= "table" then stateSementes = {["All"] = true} end
                
                local char = LocalPlayer.Character
                local sementesNoInventario = Manager:GetInventoryTools("Seed")
                local sementesDisponiveis = {}
                
                for _, sementeNome in ipairs(sementesNoInventario) do
                    if sementeNome ~= "Nenhuma Ferramenta Equipada" then
                        if stateSementes["All"] or stateSementes[sementeNome] then
                            table.insert(sementesDisponiveis, sementeNome)
                        end
                    end
                end

                local prioridade = State.FarmSettings.PrioritizePlant
                if prioridade and prioridade ~= "Nenhum" then
                    table.sort(sementesDisponiveis, function(a, b) return a == prioridade end)
                end

                local toolEmUso = nil
                for _, semente in ipairs(sementesDisponiveis) do
                    toolEmUso = (char and char:FindFirstChild(semente)) or LocalPlayer.Backpack:FindFirstChild(semente)
                    if toolEmUso then
                        if char and toolEmUso.Parent == LocalPlayer.Backpack then
                            char.Humanoid:EquipTool(toolEmUso)
                            task.wait(0.2)
                        end
                        break
                    end
                end

                local cacheSolos = {}
                local cachePlantas = {}
                local bounds = workspace:GetPartBoundsInBox(Scanner.AncoraPart.CFrame, Scanner.AncoraPart.Size)
                
                for _, p in ipairs(bounds) do
                    local root = Manager:ObterBlocoRaiz(p)
                    if root and root.Name ~= "SelectionAnchor_Script" then
                        local n = root.Name:lower()
                        if n ~= "trunk" and n ~= "top" then
                            local pos = root:IsA("Model") and root:GetPivot().Position or root.Position
                            local posGrid = Scanner:AlinharParaGrid(pos)
                            local key = string.format("%.1f_%.1f_%.1f", posGrid.X, posGrid.Y, posGrid.Z)
                            
                            if n:find("grass") or n:find("dirt") or n:find("soil") or n:find("plowed") or n:find("farm") then
                                cacheSolos[key] = root
                            else
                                cachePlantas[key] = root
                            end
                        end
                    end
                end

                local minCoord = Scanner.AncoraPart.Position - (Scanner.AncoraPart.Size / 2)
                local maxCoord = Scanner.AncoraPart.Position + (Scanner.AncoraPart.Size / 2)
                
                local tarefasPendentes = {}

                -- Mapeia TODAS as tarefas que precisam de ação
                for y = minCoord.Y + (Config.BLOCK_SIZE/2), maxCoord.Y, Config.BLOCK_SIZE do
                    for x = minCoord.X + (Config.BLOCK_SIZE/2), maxCoord.X, Config.BLOCK_SIZE do
                        for z = minCoord.Z + (Config.BLOCK_SIZE/2), maxCoord.Z, Config.BLOCK_SIZE do
                            
                            local posPlanta = Vector3.new(x, y, z)
                            local posSolo = posPlanta - Vector3.new(0, Config.BLOCK_SIZE, 0)
                            
                            local keyPlanta = string.format("%.1f_%.1f_%.1f", posPlanta.X, posPlanta.Y, posPlanta.Z)
                            local keySolo = string.format("%.1f_%.1f_%.1f", posSolo.X, posSolo.Y, posSolo.Z)
                            
                            local plantaObj = cachePlantas[keyPlanta]
                            local blocoSolo = cacheSolos[keySolo]

                            local temTrabalho = false
                            if plantaObj and plantaObj:FindFirstChild("Harvestable", true) then temTrabalho = true
                            elseif not blocoSolo and State.FarmSettings.PlaceGrass then temTrabalho = true
                            elseif blocoSolo then
                                local nSolo = blocoSolo.Name:lower()
                                if (nSolo:find("grass") or nSolo:find("dirt")) and State.FarmSettings.PlowGrass then temTrabalho = true
                                elseif (nSolo:find("soil") or nSolo:find("plowed") or nSolo:find("farm")) and State.FarmSettings.AutoReplace and toolEmUso then temTrabalho = true end
                            end

                            if temTrabalho then
                                table.insert(tarefasPendentes, {
                                    pPlanta = posPlanta, pSolo = posSolo,
                                    objP = plantaObj, objS = blocoSolo
                                })
                            end
                        end
                    end
                end

                -- ====== O VERDADEIRO ALGORITMO NEAREST NEIGHBOR ======
                while #tarefasPendentes > 0 and State.AutoFarmingCrops do
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local posAtual = hrp and hrp.Position or Scanner.AncoraPart.Position

                    -- Ordena a lista para o alvo MAIS PRÓXIMO ser o primeiro
                    table.sort(tarefasPendentes, function(a, b)
                        return (posAtual - a.pPlanta).Magnitude < (posAtual - b.pPlanta).Magnitude
                    end)

                    local centroDoCluster = tarefasPendentes[1].pPlanta

                    if State.FarmSettings.TweenToTarget then
                        local tween = Navigator:VoarPara(centroDoCluster, State.FarmSettings.TweenSpeed)
                        if tween then
                            while tween.PlaybackState == Enum.PlaybackState.Playing and State.AutoFarmingCrops do task.wait(0.05) end
                        end
                    end

                    if Manager then Manager:AtualizarStatus("Trabalhando no Cluster (15 studs)...") end

                    local tarefasSobrando = {}
                    
                    -- Parado neste centro, varre TUDO o que ele conseguir alcançar sem andar!
                    for _, dados in ipairs(tarefasPendentes) do
                        if not State.AutoFarmingCrops then break end
                        
                        local pAtual = (char and char:FindFirstChild("HumanoidRootPart")) and char.HumanoidRootPart.Position or posAtual
                        local dist = (pAtual - dados.pPlanta).Magnitude

                        if dist <= 16 then -- Alcançável (margem de segurança)
                            if dados.objP then
                                local payload = { dZnpyRtxna = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nsDahbvdxZludavlcoipDDMYasPlcm", player = LocalPlayer, model = dados.objP }
                                pcall(function() Manager.HarvestRemote:InvokeServer(payload) end)
                                task.wait(State.FarmSettings.HarvestDelay or 0.1)
                            
                            elseif not dados.objS and State.FarmSettings.PlaceGrass then
                                local blockGrass = LocalPlayer.Backpack:FindFirstChild("grass") or (char and char:FindFirstChild("grass"))
                                if blockGrass then
                                    local payload = { uwhiHAMdjExWka = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nffEgdldU", cframe = CFrame.new(dados.pSolo), blockType = blockGrass.Name, upperBlock = false }
                                    pcall(function() Manager.PlaceRemote:InvokeServer(payload) end)
                                    task.wait(0.15)
                                end
                                
                            elseif dados.objS then
                                local nSolo = dados.objS.Name:lower()
                                local isTerraBruta = nSolo:find("grass") or nSolo:find("dirt")
                                local isTerraArada = nSolo:find("soil") or nSolo:find("plowed") or nSolo:find("farm")
                                
                                if isTerraBruta and State.FarmSettings.PlowGrass then
                                    pcall(function() Manager.PlowRemote:InvokeServer({ block = dados.objS }) end)
                                    task.wait(0.1)
                                    isTerraArada = true 
                                end
                                
                                if isTerraArada and State.FarmSettings.AutoReplace and toolEmUso then
                                    local blockTypeReal = toolEmUso.Name:gsub("Seeds", ""):gsub("seeds", "")
                                    local payload = { uwhiHAMdjExWka = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nffEgdldU", cframe = CFrame.new(dados.pPlanta), blockType = blockTypeReal, upperBlock = false }
                                    pcall(function() Manager.PlaceRemote:InvokeServer(payload) end)
                                    task.wait(State.FarmSettings.PlantDelay or 0.15)
                                end
                            end
                        else
                            -- Se estiver fora do alcance deste ponto, guarda para o próximo voo
                            table.insert(tarefasSobrando, dados)
                        end
                    end
                    
                    tarefasPendentes = tarefasSobrando
                end
                
                task.wait(1)
            end
            
            if Manager then Manager:AtualizarStatus("Auto-Fazenda Desligada") end
            if Navigator then Navigator:LimparVoo() end
        end)
    else
        if Navigator then Navigator:LimparVoo() end
        if Manager then Manager:AtualizarStatus("Ocioso") end
    end
end

return Farmer