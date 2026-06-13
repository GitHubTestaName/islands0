-- src/actions/Farmer.lua
local Players = game:GetService("Players")
local Farmer = {}
local Bot = _G.IslandsBot
local State = Bot.State
local Config = Bot.Config
local LocalPlayer = Players.LocalPlayer

local function IrParaAlvo(alvoPos)
    if not State.FarmSettings.TweenToTarget then return end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local dist = (hrp.Position - alvoPos).Magnitude
    if dist > 15 then 
        hrp.Anchored = true
        local speed = State.FarmSettings.TweenSpeed or 20
        local tempo = dist / speed
        
        local hoverPos = alvoPos + Vector3.new(0, 6, 0)
        local hoverCFrame = CFrame.new(hoverPos, alvoPos)
        
        local tween = game:GetService("TweenService"):Create(
            hrp, 
            TweenInfo.new(tempo, Enum.EasingStyle.Linear), 
            {CFrame = hoverCFrame}
        )
        
        tween:Play()
        while tween.PlaybackState == Enum.PlaybackState.Playing and State.AutoFarmingCrops do
            task.wait(0.05)
        end
        
        if not State.AutoFarmingCrops then tween:Cancel() end
    end
end

function Farmer:ArarTerra()
    local Manager = Bot.Modules.Manager
    local Scanner = State.ScannerFazenda
    if not Scanner or not Scanner.AncoraPart then return end
    if Manager then Manager:AtualizarStatus("Arando a terra...") end

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
        if Manager then Manager:AtualizarStatus("Área arada!") end
    end)
end

function Farmer:AlternarAutoFazenda(valor)
    State.AutoFarmingCrops = valor
    local Manager = Bot.Modules.Manager

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

                -- 1. CRIAÇÃO DOS PONTOS MATEMATICAMENTE PERFEITOS (ADEUS ZEBRA)
                local pontosPendentes = {}
                for y = minCoord.Y + (Config.BLOCK_SIZE/2), maxCoord.Y, Config.BLOCK_SIZE do
                    for x = minCoord.X + (Config.BLOCK_SIZE/2), maxCoord.X, Config.BLOCK_SIZE do
                        for z = minCoord.Z + (Config.BLOCK_SIZE/2), maxCoord.Z, Config.BLOCK_SIZE do
                            table.insert(pontosPendentes, Vector3.new(x, y, z))
                        end
                    end
                end

                -- 2. ALGORITMO DE CLUSTER (Limpa por área e voa para a próxima)
                local timeoutSegurança = 0
                while #pontosPendentes > 0 and State.AutoFarmingCrops do
                    timeoutSegurança = timeoutSegurança + 1
                    if timeoutSegurança > 2000 then break end

                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local posAtual = hrp and hrp.Position or Scanner.AncoraPart.Position

                    -- ORDENA PARA ACHAR O ALVO MAIS PRÓXIMO
                    table.sort(pontosPendentes, function(a, b)
                        return (posAtual - a).Magnitude < (posAtual - b).Magnitude
                    end)

                    local centroAtual = pontosPendentes[1]
                    IrParaAlvo(centroAtual) -- VOA PARA O NOVO CLUSTER

                    local proximaFila = {}
                    -- PROCESSA TUDO QUE ESTIVER AO ALCANCE NESTE CLUSTER
                    for _, posPlanta in ipairs(pontosPendentes) do
                        if not State.AutoFarmingCrops then break end

                        local hrpAgora = char and char:FindFirstChild("HumanoidRootPart")
                        local distReal = hrpAgora and (hrpAgora.Position - posPlanta).Magnitude or 999

                        -- SE ESTIVER DENTRO DE 15 STUDS (5 BLOCOS), ELE AGE!
                        if distReal <= 15 then 
                            local posSolo = posPlanta - Vector3.new(0, Config.BLOCK_SIZE, 0)
                            
                            local keyPlanta = string.format("%.1f_%.1f_%.1f", posPlanta.X, posPlanta.Y, posPlanta.Z)
                            local keySolo = string.format("%.1f_%.1f_%.1f", posSolo.X, posSolo.Y, posSolo.Z)
                            
                            local plantaObj = cachePlantas[keyPlanta]
                            local blocoSolo = cacheSolos[keySolo]

                            if plantaObj then
                                local isMadura = plantaObj:FindFirstChild("Harvestable", true)
                                if isMadura then
                                    local payload = {
                                        dZnpyRtxna = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nsDahbvdxZludavlcoipDDMYasPlcm",
                                        player = LocalPlayer,
                                        model = plantaObj
                                    }
                                    pcall(function() Manager.HarvestRemote:InvokeServer(payload) end)
                                    task.wait(State.FarmSettings.HarvestDelay or 0.1)
                                end
                            elseif not blocoSolo and State.FarmSettings.PlaceGrass then
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
                                end
                            elseif blocoSolo then
                                local nSolo = blocoSolo.Name:lower()
                                local terraBruta = nSolo:find("grass") or nSolo:find("dirt")
                                local terraArada = nSolo:find("soil") or nSolo:find("plowed") or nSolo:find("farm")
                                
                                if terraBruta and State.FarmSettings.PlowGrass then
                                    pcall(function() Manager.PlowRemote:InvokeServer({ block = blocoSolo }) end)
                                    task.wait(0.1)
                                    terraArada = true 
                                end
                                
                                if terraArada and State.FarmSettings.AutoReplace and toolEmUso then
                                    local blockTypeReal = toolEmUso.Name:gsub("Seeds", ""):gsub("seeds", "")
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
                        else
                            -- Se estiver longe, guarda na fila para o próximo voo
                            table.insert(proximaFila, posPlanta)
                        end
                    end
                    -- Atualiza a lista apenas com os blocos distantes que sobraram
                    pontosPendentes = proximaFila
                    task.wait(0.05)
                end
                task.wait(1)
            end
            
            if Manager then Manager:AtualizarStatus("Auto-Fazenda Desligada") end
            local charAtual = LocalPlayer.Character
            if charAtual and charAtual:FindFirstChild("HumanoidRootPart") then
                charAtual.HumanoidRootPart.Anchored = false
            end
            
        end)
    else
        if Manager then Manager:AtualizarStatus("Ocioso") end
    end
end

return Farmer