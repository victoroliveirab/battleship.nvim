---Tests equality and raises a formatted error on failure
---@param expected any
---@param actual any
local assert_equals = function(expected, actual)
    print(vim.inspect(expected))
    print(vim.inspect(actual))
    assert(
        expected == actual,
        string.format("Expected %s, but actual is %s", tostring(expected), tostring(actual))
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

return {
    assert_equals = assert_equals,
    assert_equals_each = assert_equals_each,
    assert_equals_array_elements = assert_equals_array_elements,
    assert_not_equals = assert_not_equals,
}
