-- src/actions/Builder.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Builder = {}
local Bot = _G.IslandsBot
local State = Bot.State
local Config = Bot.Config
local LocalPlayer = Players.LocalPlayer

function Builder:ColocarAreaMarcada()
    local Manager = Bot.Modules.Manager
    local Scanner = Bot.Modules.Scanner

    if State.Minerando or State.Construindo then return end
    if not State.AncoraPart then 
        if Manager then Manager:AtualizarStatus("ERRO: Crie o seletor primeiro!") end
        return 
    end

    local char = LocalPlayer.Character
    if not char then return end

    local tool = char:FindFirstChildOfClass("Tool")
    if not tool or not ReplicatedStorage:WaitForChild("Blocks"):FindFirstChild(tool.Name) then
        if Manager then Manager:AtualizarStatus("ERRO: Equipe um Bloco Válido!") end
        return
    end

    State.Construindo = true
    if Manager then Manager:AtualizarStatus("Construindo com: " .. tool.Name) end

    local minCoord = State.AncoraPart.Position - (State.AncoraPart.Size / 2)
    local maxCoord = State.AncoraPart.Position + (State.AncoraPart.Size / 2)

    task.spawn(function()
        for x = minCoord.X + (Config.BLOCK_SIZE/2), maxCoord.X, Config.BLOCK_SIZE do
            for y = minCoord.Y + (Config.BLOCK_SIZE/2), maxCoord.Y, Config.BLOCK_SIZE do
                for z = minCoord.Z + (Config.BLOCK_SIZE/2), maxCoord.Z, Config.BLOCK_SIZE do
                    if not State.Construindo then break end
                    
                    local slotPos = Vector3.new(x, y, z)
                    local overlap = workspace:GetPartBoundsInRadius(slotPos, 0.5)
                    local ocupado = false
                    for _, v in pairs(overlap) do
                        if v:IsDescendantOf(workspace.Islands) and v.Name ~= "SelectionAnchor_Script" then
                            ocupado = true
                            break
                        end
                    end
                    
                    if not ocupado then
                        local payload = {
                            uwhiHAMdjExWka = "\a\240\159\164\163\240\159\164\161\a\n\a\n\a\nffEgdldU",
                            cframe = CFrame.new(slotPos),
                            blockType = tool.Name,
                            upperBlock = false
                        }
                        pcall(function() 
                            Manager.PlaceRemote:InvokeServer(payload) 
                        end)
                        task.wait(0.05) 
                    end
                end
            end
        end
        if Manager then Manager:AtualizarStatus("Construção Finalizada!") end
        State.Construindo = false
        if Scanner then Scanner:EscanearArea() end
    end)
end

function Builder:Cancelar()
    State.Construindo = false
end

return Builder