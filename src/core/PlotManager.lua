-- src/core/PlotManager.lua
local HttpService = game:GetService("HttpService")
local PlotManager = {}

local FILE_NAME = "IslandsBot_PlotsSave.txt"

function PlotManager:ObterTodos()
    local dadosFormatados = {}
    if type(isfile) == "function" and type(readfile) == "function" then
        if isfile(FILE_NAME) then
            local pSuccess, rData = pcall(readfile, FILE_NAME)
            if pSuccess and type(rData) == "string" and rData ~= "" then
                local jsonSuccess, jsonData = pcall(function() return HttpService:JSONDecode(rData) end)
                if jsonSuccess and type(jsonData) == "table" then
                    dadosFormatados = jsonData
                end
            end
        end
    end
    return dadosFormatados
end

function PlotManager:SalvarPlot(nome, posicao, tamanho)
    if type(writefile) ~= "function" then return false end
    
    local plots = self:ObterTodos()
    -- Formatamos os tamanhos tirando quebras bizarras da engine
    plots[nome] = {
        PosX = math.floor(posicao.X * 100) / 100, 
        PosY = math.floor(posicao.Y * 100) / 100, 
        PosZ = math.floor(posicao.Z * 100) / 100,
        SizeX = math.floor(tamanho.X * 100) / 100, 
        SizeY = math.floor(tamanho.Y * 100) / 100, 
        SizeZ = math.floor(tamanho.Z * 100) / 100
    }
    
    local sucesso = pcall(function() writefile(FILE_NAME, HttpService:JSONEncode(plots)) end)
    return sucesso
end

function PlotManager:DeletarPlot(nome)
    if type(writefile) ~= "function" then return false end
    local plots = self:ObterTodos()
    
    if plots[nome] then
        plots[nome] = nil
        pcall(function() writefile(FILE_NAME, HttpService:JSONEncode(plots)) end)
        return true
    end
    return false
end

return PlotManager