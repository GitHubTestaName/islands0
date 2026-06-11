-- src/actions/Miner.lua
local Miner = {}
local Bot = _G.IslandsBot
local State = Bot.State

function Miner:ExecutarLoop()
    local Manager = Bot.Modules.Manager
    local Scanner = State.ScannerGeral -- Usa exclusivamente o Seletor Azul

    while State.Minerando do
        if Scanner then Scanner:EscanearArea() end
        
        if not Scanner or #Scanner.ListaBlocos == 0 then
            if Manager then Manager:AtualizarStatus("Aguardando blocos...") end
            task.wait(1)
            continue
        end

        for i, dados in ipairs(Scanner.ListaBlocos) do
            if not State.Minerando then break end

            local bloco = dados.Instancia
            if not bloco or not bloco:IsDescendantOf(workspace) then continue end

            local healthObj = bloco:FindFirstChild("Health")
            local partTarget = bloco 
            local tentativas = 0
            
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

                if tentativas > 200 then 
                    if Manager then Manager:AtualizarStatus("Gargalo! Pulando " .. dados.Nome) end
                    task.wait(0.5)
                    break 
                end

                local basePos = bloco:IsA("Model") and bloco:GetPivot().Position or bloco.Position
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
end

function Miner:Alternar(valor)
    local Manager = Bot.Modules.Manager
    if not State.ScannerGeral or not State.ScannerGeral.AncoraPart then 
        if Manager then Manager:AtualizarStatus("ERRO: Crie o seletor geral primeiro!") end
        return false
    end
    
    State.Minerando = valor
    if State.Minerando then
        State.Construindo = false
        task.spawn(function()
            Miner:ExecutarLoop()
        end)
    else
        if Manager then Manager:AtualizarStatus("Ocioso") end
    end
    return true
end

return Miner