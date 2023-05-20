---Source: http://lua-users.org/wiki/CopyTable
---Creates a deepcopy of a data structure
---@generic T
---@param orig T
---@return T
local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
---Maps an array
---@generic T
---@generic P
---@param arr T[]
---@param predicate fun(element: T): P
---@return P[]
local function map(arr, predicate)
    local mapped_arr = {}
    for _, element in ipairs(arr) do
        table.insert(mapped_arr, predicate(element))
    end
    return mapped_arr
end

---Filters an array
---@generic T
---@param arr T[]
---@param predicate fun(element: T): boolean
---@return T[]
local function filter(arr, predicate)
    local filtered_arr = {}
    for _, element in ipairs(arr) do
        if predicate(element) then
            table.insert(filtered_arr, element)
        end
    end
    return filtered_arr
end

---Checks if an element belongs to an array
---@generic T
---@param arr T[]
---@param element T
---@param equality_fn fun(a: T, b: T)?: boolean
---@return boolean
local function includes(arr, element, equality_fn)
    equality_fn = equality_fn or function(a, b)
        return a == b
    end
    for _, value in pairs(arr) do
        if equality_fn(element, value) then
            return true
        end
    end
    return false
end

---Creates an equal padding on both sizes of the string
---@param str string the uncentered string
---@param length integer the final length of the string
---@param char string? the string to use on padding
---@return string str str centralized
local function centralize_string(str, length, char)
    char = char or " "
    local available_length = length - #str
    local left_pad = math.floor(available_length / 2)
    local right_pad = math.ceil(available_length / 2)
    return string.format("%s%s%s", char:rep(left_pad), str, char:rep(right_pad))
end

---Converts a value to true or false
---@generic T
---@param value T
---@return boolean
local function toboolean(value)
    return value ~= false and value ~= nil
end

return {
    centralize_string = centralize_string,
    deepcopy = deepcopy,
    filter = filter,
    includes = includes,
    map = map,
    toboolean = toboolean,
}
