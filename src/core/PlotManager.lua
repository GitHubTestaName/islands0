-- src/core/PlotManager.lua
local HttpService = game:GetService("HttpService")
local PlotManager = {}

local FILE_NAME = "IslandsBot_FarmPlots.json"

function PlotManager:ObterTodos()
    if type(isfile) == "function" and type(readfile) == "function" then
        if isfile(FILE_NAME) then
            local sucesso, dados = pcall(function()
                return HttpService:JSONDecode(readfile(FILE_NAME))
            end)
            if sucesso and type(dados) == "table" then
                return dados
            end
        end
    end
    return {}
end

function PlotManager:SalvarPlot(nome, posicao, tamanho)
    if type(writefile) ~= "function" then 
        warn("ERRO: Executor não suporta salvar arquivos.")
        return false 
    end
    
    local plots = self:ObterTodos()
    plots[nome] = {
        PosX = posicao.X, PosY = posicao.Y, PosZ = posicao.Z,
        SizeX = tamanho.X, SizeY = tamanho.Y, SizeZ = tamanho.Z
    }
    
    local sucesso, err = pcall(function()
        writefile(FILE_NAME, HttpService:JSONEncode(plots))
    end)
    return sucesso
end

function PlotManager:DeletarPlot(nome)
    if type(writefile) ~= "function" then return false end
    local plots = self:ObterTodos()
    
    if plots[nome] then
        plots[nome] = nil
        pcall(function()
            writefile(FILE_NAME, HttpService:JSONEncode(plots))
        end)
        return true
    end
    return false
end

return PlotManager