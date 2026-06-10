-- src/actions/Plower.lua
local Plower = {}
local Bot = _G.IslandsBot
local State = Bot.State

function Plower:ArarArea()
    local Manager = Bot.Modules.Manager
    if not State.AncoraPart then 
        if Manager then Manager:AtualizarStatus("ERRO: Crie o seletor primeiro!") end
        return 
    end

    Manager:AtualizarStatus("Arando a área selecionada...")
    
    task.spawn(function()
        for i, dados in ipairs(State.ListaBlocos) do
            local bloco = dados.Instancia
            if not bloco or not bloco:IsDescendantOf(workspace) then continue end

            -- Só ara blocos que possuem propriedades de terra/grama que possam ser arados
            if bloco.Name:lower():find("grass") or bloco.Name:lower():find("dirt") then
                local payload = {
                    {
                        block = bloco
                    }
                }
                pcall(function()
                    Manager.PlowRemote:InvokeServer(unpack(payload))
                end)
                task.wait(0.05) -- Delay seguro para evitar kick de spam
            end
        end
        Manager:AtualizarStatus("Aração concluída!")
    end)
end

return Plower