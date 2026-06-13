-- src/actions/Miner.lua
local Players = game:GetService("Players")
local Miner = {}
local Bot = _G.IslandsBot
local State = Bot.State
local LocalPlayer = Players.LocalPlayer

local function IrParaAlvo(alvoPos)
    if not State.MiningSettings.TweenToTarget then return end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local dist = (hrp.Position - alvoPos).Magnitude
    if dist > 15 then
        hrp.Anchored = true
        local speed = State.MiningSettings.TweenSpeed or 20
        local tempo = dist / speed
        
        local hoverPos = alvoPos + Vector3.new(0, 6, 0)
        local hoverCFrame = CFrame.new(hoverPos, alvoPos)
        
        local tween = game:GetService("TweenService"):Create(
            hrp, 
            TweenInfo.new(tempo, Enum.EasingStyle.Linear), 
            {CFrame = hoverCFrame}
        )
        
        tween:Play()
        while tween.PlaybackState == Enum.PlaybackState.Playing and State.Minerando do
            task.wait(0.05)
        end
        if not State.Minerando then tween:Cancel() end
    end
end

function Miner:ExecutarLoop()
    local Manager = Bot.Modules.Manager
    local Scanner = State.ScannerGeral

    while State.Minerando do
        if Scanner then Scanner:EscanearArea() end
        
        if not Scanner or #Scanner.ListaBlocos == 0 then
            if Manager then Manager:AtualizarStatus("Aguardando blocos...") end
            task.wait(1)
            continue
        end

        -- ORDENAÇÃO DINÂMICA: Sempre ataca as pedras mais próximas do boneco
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        table.sort(Scanner.ListaBlocos, function(a, b)
            local posAtual = hrp and hrp.Position or Scanner.AncoraPart.Position
            return (posAtual - a.Posicao).Magnitude < (posAtual - b.Posicao).Magnitude
        end)

        for i, dados in ipairs(Scanner.ListaBlocos) do
            if not State.Minerando then break end

            local bloco = dados.Instancia
            if not bloco or not bloco:IsDescendantOf(workspace) then continue end

            local healthObj = bloco:FindFirstChild("Health")
            local partTarget = bloco 
            local tentativas = 0
            
            local basePos = bloco:IsA("Model") and bloco:GetPivot().Position or bloco.Position
            IrParaAlvo(basePos) 
            
            while bloco and bloco:IsDescendantOf(workspace) do
                if not State.Minerando then break end
                
                local hpAtual = healthObj and healthObj.Value or 0
                if healthObj and hpAtual <= 0 then 
                    if dados.Marcador then dados.Marcador:Destroy() end
                    break 
                end
                
                tentativas = tentativas + 1
                if Manager then
                    Manager:AtualizarStatus(string.format("[%d/%d] %s | HP: %s | Hit: %d", i, #Scanner.ListaBlocos, dados.Nome, tostring(hpAtual), tentativas))
                end

                if tentativas > 50 then 
                    if Manager then Manager:AtualizarStatus("Gargalo! Recalculando pedras...") end
                    Scanner:EscanearArea() 
                    task.wait(0.5)
                    break 
                end

                local offsetX = math.random(-15, 15) / 100
                local offsetZ = math.random(-15, 15) / 100
                local hitPosition = basePos + Vector3.new(offsetX, 0, offsetZ)

                local payload = {
                    Xoeoxuqilfgenamojfjmj = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nohIstskUiftvgjy",
                    part = partTarget, 
                    block = bloco,
                    norm = hitPosition,
                    pos = Vector3.new(0, 1, 0)
                }

                pcall(function() Manager.HitRemote:InvokeServer(payload) end)
                task.wait(0.02)
            end
            
            if dados.Marcador and dados.Marcador.Parent then dados.Marcador:Destroy() end
        end
        task.wait(0.2)
    end
    
    local charAtual = LocalPlayer.Character
    if charAtual and charAtual:FindFirstChild("HumanoidRootPart") then
        charAtual.HumanoidRootPart.Anchored = false
    end
end

function Miner:Alternar(valor)
    local Manager = Bot.Modules.Manager
    State.Minerando = valor
    
    if valor then
        if State.MiningSettings.AutoUseSelectedSave and State.MiningSettings.CurrentSaveName then
            local PlotManager = Bot.Modules.PlotManager
            local plots = PlotManager:ObterTodos()
            local plot = plots["Mining_" .. State.MiningSettings.CurrentSaveName]
            if plot and State.ScannerGeral then
                State.ScannerGeral:CarregarPlot(Vector3.new(plot.PosX, plot.PosY, plot.PosZ), Vector3.new(plot.SizeX, plot.SizeY, plot.SizeZ))
            end
        end

        if not State.ScannerGeral or not State.ScannerGeral.AncoraPart then 
            if Manager then Manager:AtualizarStatus("ERRO: Crie o seletor azul primeiro!") end
            State.Minerando = false
            return false
        end
        
        State.Construindo = false
        task.spawn(function() Miner:ExecutarLoop() end)
    else
        if Manager then Manager:AtualizarStatus("Ocioso") end
    end
    return true
end

return Miner