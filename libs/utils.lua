local utils = {}

utils.boolToInteger = function(condition, falsevalue, truevalue)
    return condition and truevalue or falsevalue
end

utils.unpackLove = function(t, _i)
    local i = _i or 1
    local n = #t
    if i > n then
        return nil
    end
    return t[i], utils.unpackLove(t, i + 1)
end

return utils