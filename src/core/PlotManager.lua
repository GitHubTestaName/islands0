-- src/core/PlotManager.lua
local HttpService = game:GetService("HttpService")
local PlotManager = {}

local FILE_NAME = "IslandsBot_FarmPlots.json"
local memoryPlots = {} -- Salvaguarda de Memória

function PlotManager:ObterTodos()
    if type(isfile) == "function" and type(readfile) == "function" then
        pcall(function()
            if isfile(FILE_NAME) then
                local dados = HttpService:JSONDecode(readfile(FILE_NAME))
                if type(dados) == "table" then
                    for k, v in pairs(dados) do memoryPlots[k] = v end
                end
            end
        end)
    end
    return memoryPlots
end

function PlotManager:SalvarPlot(nome, posicao, tamanho)
    local plots = self:ObterTodos()
    plots[nome] = {
        PosX = posicao.X, PosY = posicao.Y, PosZ = posicao.Z,
        SizeX = tamanho.X, SizeY = tamanho.Y, SizeZ = tamanho.Z
    }
    
    -- Salva na RAM instantaneamente
    memoryPlots = plots 
    
    -- Tenta salvar no disco, se permitido
    if type(writefile) == "function" then 
        pcall(function()
            writefile(FILE_NAME, HttpService:JSONEncode(plots))
        end)
    end
    return true
end

function PlotManager:DeletarPlot(nome)
    local plots = self:ObterTodos()
    
    if plots[nome] then
        plots[nome] = nil
        memoryPlots = plots
        if type(writefile) == "function" then
            pcall(function()
                writefile(FILE_NAME, HttpService:JSONEncode(plots))
            end)
        end
        return true
    end
    return false
end

return PlotManager