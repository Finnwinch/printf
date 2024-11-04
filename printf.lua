local function printf(message)
    local env = {}
    local i = 1
    while true do
        local name, value = debug.getlocal(2, i)
        if not name then break end
        env[name] = value
        i = i + 1
    end
    local isCode = message:sub(1, 1) == "@"
    message = message:gsub("{(.-)}", function(key)
        return tostring(env[key] or _G[key] or "{" .. key .. "}")
    end)
    message = message:gsub("@if (.-) == (.-) then (.-) else (.-) end@", function(varName, compareValue, trueCode, falseCode)
        local variableValue = env[varName] or _G[varName]
        if tonumber(variableValue) == tonumber(compareValue) then
            return trueCode:gsub("{(.-)}", function(key)
                return tostring(env[key] or _G[key] or "{" .. key .. "}")
            end)
        else
            return falseCode:gsub("{(.-)}", function(key)
                return tostring(env[key] or _G[key] or "{" .. key .. "}")
            end)
        end
    end)
    message = message:gsub("@for (.-) = (.-), (.-) do (.-) end@", function(varName, startValue, endValue, code)
        local results = {}
        startValue = tonumber(startValue)
        endValue = tonumber(endValue)
        for i = startValue, endValue do
            local loopEnv = setmetatable({[varName] = i}, {__index = env})
            local loopCode = code:gsub("{(.-)}", function(key)
                return tostring(loopEnv[key] or _G[key] or "{" .. key .. "}")
            end)
            table.insert(results, loopCode)
        end
        return table.concat(results, "\n")
    end)
    if isCode then
        return message
    end
    print(message)
end
-- Déclaration d'une variable
local value = 2

-- Appel à printf
printf("The value of value is {value}")
printf("I not return data, but i do the work: @if value == 1 then value({value}) is equal to 1 else value is not 1 end@")

-- Traitement d'une condition avec retour
local result = printf("@if value == 1 then 'value{value} is equal to 1' else 'value is not egal to 1' end@")
print(result)

-- Exemple d'utilisation de la boucle for
local loopResult = printf("@for i = 1, 5 do 'Value of i is {i}' end@")
print(loopResult)