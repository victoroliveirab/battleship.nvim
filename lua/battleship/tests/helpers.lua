local utils = require("battleship.utils")

---Tests equality and raises a formatted error on failure
---@param expected any
---@param actual any
local assert_equals = function(expected, actual)
    assert(
        expected == actual,
        string.format("Expected %s, but actual is %s", tostring(expected), tostring(actual))
    )
end

---Tests if an element is nil
---@param element any
local assert_is_nil = function(element)
    assert(element == nil, string.format("Expected %s to be nil", tostring(element)))
end

---Tests if an element belong to an array
---@generic T
---@param arr T[]
---@param element T
---@param equality_fn fun(a: T, b: T): boolean
local assert_belongs = function(arr, element, equality_fn)
    assert(
        utils.includes(arr, element, equality_fn),
        string.format("Expected %s to be part of array", tostring(element))
    )
end

---Runs assert_equals for each pair
---@generic T
---@generic P
---@param expected T[]
---@param input P[]|T[]
---@param fn? fun(param: P): T
local assert_equals_each = function(expected, input, fn)
    for index, element in ipairs(input) do
        local actual = fn and fn(element) or element
        assert_equals(expected[index], actual)
    end
end

local assert_equals_array_elements
---Runs assert_equals for each pair in both array at the same time
---@generic T
---@param expected T[]
---@param input T[]
assert_equals_array_elements = function(expected, input)
    for index, element1 in ipairs(input) do
        local element2 = expected[index]
        if type(element2) == "table" and type(element1) == "table" then
            assert(#element2 == #element1, "Tables have different sizes")
            assert_equals_array_elements(element2, element1)
        else
            assert_equals(element2, element1)
        end
    end
end

---Tests non-equality and raises a formatted error on failure
---@param expected any
---@param actual any
local assert_not_equals = function(expected, actual)
    assert(
        expected ~= actual,
        string.format("Expected and actual values are the same: %s", tostring(expected))
    )
end

---Runs test multiple times
---@param test_case fun(): nil
---@param times integer
local run_multiple = function(test_case, times)
    for _ = 1, times do
        test_case()
    end
end

return {
    assert_belongs = assert_belongs,
    assert_equals = assert_equals,
    assert_equals_each = assert_equals_each,
    assert_equals_array_elements = assert_equals_array_elements,
    assert_is_nil = assert_is_nil,
    assert_not_equals = assert_not_equals,
    run_multiple = run_multiple,
}
