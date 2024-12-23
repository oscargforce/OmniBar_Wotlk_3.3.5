-- Filter function: returns a new array with elements that satisfy the predicate
function addon.Filter(array, predicate)
    local result = {}
    for i, value in ipairs(array) do
        if predicate(value, i) then
            table.insert(result, value)
        end
    end
    return result
end

-- Map function: returns a new array with elements transformed by the mapper function
function addon.Map(array, mapper)
    local result = {}
    for i, value in ipairs(array) do
        table.insert(result, mapper(value, i))
    end
    return result
end
