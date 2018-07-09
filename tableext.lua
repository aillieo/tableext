local error,assert = error,assert
local print,tostring = print,tostring
local loadstring = loadstring or load
local type = type
local next = next
local pairs,ipairs = pairs,ipairs
local setmetatable,getmetatable = setmetatable,getmetatable
local format,rep = string.format,string.rep
local insert, concat = table.insert, table.concat
local floor = math.floor

local istable = function(t)
    return type(t) == "table"
end

local isarray = function(t)
    if not istable(t) then return false end
    local len = #t
    for i in pairs(t) do
        if type(i) ~= "number" then
            return false
        end
        if i > len then
            return false
        end
    end
    return true
end

local asserttable = function(t)
    assert(istable(t), "invalid argument: table expected, got " .. type(t))
end

local assertarray = function(t)
    asserttable(t);
    assert(isarray(t), "invalid argument: not an array-table")
end

local assertnotnil = function(arg)
    assert(nil ~= arg, "invalid argument: nil")
end

local isempty = function(t)
    asserttable(t)
    return next(t) == nil end

local size = function(t)
    asserttable(t)
    local ret = 0
    for _ in pairs(t) do
        ret = ret + 1
    end
    return ret
end
local clear = function(t)
    asserttable(t)
    for k in pairs(t) do
        t[k] = nil
    end
end

local deepcopy = function(t)
    local copied = {}
    local function copy(t)
        if not istable(t) then
            return t
        elseif copied[t] then
            return copied[t]
        end
        local tocopy = {}
        for k, v in pairs(t) do
            tocopy[copy(k)] = copy(v)
        end
        copied[t] = tocopy
        return setmetatable(tocopy, getmetatable(t))
    end
    return copy(t)

end

local find = function(t,v)
    asserttable(t)
    assertnotnil(v)
    for k1,v1 in pairs(t) do
        if v1 == v then
            return k1
        end
    end
    return nil
end

local indenttable = {}
local function serializefunc(obj,indent)
    local ret = {}
    if indent and not indenttable[indent] then
        indenttable[indent] = rep(" ",indent)
    end
    local function append(str) return insert(ret, str) end
    local function appendline() if indent then append("\n") end end
    local t = type(obj)
    if t == "number" then
        append(obj)
    elseif t == "boolean" then
        append(tostring(obj))
    elseif t == "string" then
        append(format("%q", obj))
    elseif t == "table" then
        local metatable = getmetatable(obj)
        if metatable and type(metatable.__tostring) == "function" then
            append(tostring(obj))
        else
            append("{")
            appendline()
            for k, v in pairs(obj) do
                append(indenttable[indent and indent +1])
                append("[")
                append(serializefunc(k,indent and indent +1))
                append("]=")
                append(serializefunc(v,indent and indent +1))
                append(",")
                appendline()
            end
            if metatable ~= nil and type(metatable.__index) == "table" then
                for k, v in pairs(metatable.__index) do
                    append(indenttable[indent and indent +1])
                    append("[")
                    append(serializefunc(k,indent and indent +1))
                    append("]=")
                    append(serializefunc(v,indent and indent +1))
                    append(",")
                    appendline()
                end
            end
            append(indenttable[indent])
            append("}")
        end
    elseif t == "nil" then
        return nil
    elseif indent then
        append(tostring(obj))
    else
        error("failed to serialize type " .. t)
    end
    return concat(ret)
end

local serialize = function(t)
    return serializefunc(t)
end

local deserialize = function(str)
    local t = type(str)
    if t == "nil" or str == "" then
        return nil
    elseif t == "number" or t == "string" or t == "boolean" then
        str = tostring(str)
    else
        error("failed to deserialize type " .. t)
    end
    str = "return " .. str
    local func = loadstring(str)
    if func == nil then
        error("deserialize failed ... got invalid string")
    end
    return func()
end

local printtable = function(t)
    return print(serializefunc(t,1))
end

local zip = function(tk,tv)
    assertarray(tk)
    assertarray(tv)
    local len, ret = 0,{}
    local lenk, lenv = #tk, #tv
    len = lenk < lenv and lenk or lenv
    for i = 1, len do
        ret[tk[i]] = tv[i]
    end
    return ret
end

local unzip = function(t)
    asserttable(t)
    local tk,tv = {},{}
    for k,v in pairs(t) do
        insert(tk,k)
        insert(tv,v)
    end
    return tk,tv
end

local merge = function(tto,tfrom)
    asserttable(tto)
    asserttable(tfrom)
    for k, v in pairs(tfrom) do
        tto[k] = v
    end
end


local append = function(fst, sec)
    assertarray(fst)
    assertarray(sec)
    local l = #fst
    for i,v in ipairs(sec) do
        fst[l+i] = v
    end
end

local split = function(t)
    asserttable(t)
    local arr, rec = {}, {}
    for i=1, #t do
        arr[i] = t[i]
    end
    for k,v in pairs(t) do
        if not arr[k] then
            rec[k] = v
        end
    end
    return arr, rec
end

local reverse = function(t)
    assertarray(t)
    local n = #t+1
    local half = floor(n/2)
    for i= 1, half do
        t[i], t[n-i] = t[n - i], t[i]
    end
end

local lock = function(t)
    asserttable(t)
    return setmetatable({},{
        __index = t;
        __newindex = function(t,k) error("failed to add/change value for index/key ".. k) end;
        __metatable = "table is locked" })
end

local map = function(t, func)
    asserttable(t)
    local ret = {}
    for k,v in pairs(t) do
        ret[k] = func(v)
    end
    return ret
end

local filter = function(t, func)
    asserttable(t)
    local ret = {}
    if isarray(t) then
        for _,v in ipairs(t) do
            if func(v) then insert(ret,v) end
        end
    else
        for k,v in pairs(t) do
            if func(v) then ret[k] = v end
        end
    end
    return ret
end

local reduce = function(t, func)
    assertarray(t)
    local ret = t[1]
    local n = #t
    for i = 2, n do
        ret = func(ret,t[i])
    end
    return ret
end


local unique = function(t)
    assertarray(t)
    local ret = {}
    for _,v in ipairs(t) do
        if nil ~= find(ret,v) then
            insert(ret,v)
        end
    end
    return ret
end


local flip = function(t)
    asserttable(t)
    local ret = {}
    for k,v in pairs(t) do
        if nil ~= ret[v] then ret[v] = k end
    end
    return ret
end

local intersect = function(t1,t2)
    asserttable(t1)
    asserttable(t2)
    local ret = {}
    for k,v in pairs(t1) do
        if t2[k] ~= nil then
            ret[k] = v
        end
    end
    return ret
end

local combine = function(t1,t2)
    asserttable(t1)
    asserttable(t2)
    local ret = deepcopy(t1)
    for k,v in pairs(t2) do
        if ret[k] == nil then
            ret[k] = v
        end
    end
    return ret
end


return {
    NAME = "tableext";
    REPO = "https://github.com/aillieo/tableext";
    isempty = isempty;
    size = size;
    isarray = isarray;
    clear = clear;
    deepcopy = deepcopy;
    find = find;
    serialize = serialize;
    deserialize = deserialize;
    printtable = printtable;
    zip = zip;
    unzip = unzip;
    merge = merge;
    append = append;
    split = split;
    reverse = reverse;
    lock = lock;
    map = map;
    filter = filter;
    reduce = reduce;
    unique = unique;
    flip = flip;
    intersect = intersect;
    combine = combine;
}
