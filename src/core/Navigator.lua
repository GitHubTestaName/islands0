-- src/core/Navigator.lua
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Navigator = {}

local tapete = nil
local weld = nil

function Navigator:LimparVoo()
    if weld then weld:Destroy(); weld = nil end
    if tapete then tapete:Destroy(); tapete = nil end
    
    local char = Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.Anchored = false
    end
end

function Navigator:VoarPara(alvoPos, speed)
    local char = Players.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local dist = (hrp.Position - alvoPos).Magnitude
    if dist < 5 then return nil end -- Se já está perto, nem voa!

    -- Se não existir o tapete, cria-o e solda o personagem a ele
    if not tapete or not tapete.Parent then
        tapete = Instance.new("Part")
        tapete.Name = "IslandsBot_Tapete"
        tapete.Size = Vector3.new(4, 1, 4)
        tapete.Anchored = true
        tapete.CanCollide = false
        tapete.Transparency = 1 -- Plataforma invisível
        tapete.CFrame = hrp.CFrame - Vector3.new(0, 3, 0)
        tapete.Parent = workspace

        weld = Instance.new("WeldConstraint")
        weld.Part0 = tapete
        weld.Part1 = hrp
        weld.Parent = tapete
        
        -- DESANCORA O BONECO! Quem voa é o tapete, o servidor aceita perfeitamente.
        hrp.Anchored = false 
    end

    local tempo = dist / (speed or 20)
    -- O tapete fica exatos 3 studs (1 bloco) abaixo do alvo + 6 studs de altura de conforto
    local hoverPos = alvoPos + Vector3.new(0, 6, 0) - Vector3.new(0, 3, 0) 
    
    local tween = TweenService:Create(
        tapete, 
        TweenInfo.new(tempo, Enum.EasingStyle.Linear), 
        {CFrame = CFrame.new(hoverPos)}
    )
    
    if _G.IslandsBot.Modules.Manager then 
        _G.IslandsBot.Modules.Manager:AtualizarStatus("✈️ Navegando para o Setor...") 
    end
    
    tween:Play()
    return tween
end

return Navigator