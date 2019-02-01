local error,assert = error,assert
local print,tostring = print,tostring
local loadstring = loadstring or load
local type = type
local next = next
local pairs,ipairs = pairs,ipairs
local setmetatable,getmetatable = setmetatable,getmetatable
local format,rep = string.format,string.rep
local insert, concat = table.insert, table.concat
local sort = table.sort
local floor = math.floor

local _ = {}

function _.istable(t)
    return type(t) == "table"
end

function _.isarray(t)
    if not _.istable(t) then return false end
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

function _.asserttable(t)
    assert(_.istable(t), "invalid argument: table expected, got " .. type(t))
end

function _.assertstring(t)
    assert(type(t) == "string", "invalid argument: string expected, got " .. type(t))
end

function _.assertarray(t)
    -- assert(_.isarray(t), "invalid argument: not an array-table")
end

function _.assertfunction(t)
    assert(type(t) == "function", "invalid argument: function expected, got " .. type(t))
end

function _.assertnotnil(arg)
    assert(nil ~= arg, "invalid argument: nil")
end

function _.isempty(t)
    _.asserttable(t)
    return next(t) == nil
end

function _.size(t)
    _.asserttable(t)
    local ret = 0
    for _ in pairs(t) do
        ret = ret + 1
    end
    return ret
end

function _.clear(t)
    _.asserttable(t)
    for k in pairs(t) do
        t[k] = nil
    end
end

function _.map(t, func)
    _.asserttable(t)
    _.assertfunction(func)
    local ret = {}
    for k,v in pairs(t) do
        ret[k] = func(v)
    end
    return ret
end

function _.filter(t, func)
    _.assertarray(t)
    _.assertfunction(func)
    local ret = {}
    for _,v in ipairs(t) do
        if func(v) then insert(ret,v) end
    end
    return ret
end

function _.reduce(t, func)
    _.assertarray(t)
    _.assertfunction(func)
    local ret = t[1]
    local n = #t
    for i = 2, n do
        ret = func(ret,t[i])
    end
    return ret
end

function _.deepcopy(t)
    local copied = {}
    local function copy(t)
        if not _.istable(t) then
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

function _.find(t,v)
    _.asserttable(t)
    _.assertnotnil(v)
    for k1,v1 in pairs(t) do
        if v1 == v then
            return k1
        end
    end
    return nil
end

_.textbuffermeta = {
    __index = {
        append = function(self,text)
            _.assertstring(text)
            self._len = self._len + 1
            self._data[self._len] = text
            return self
        end
    },
    __concat = function(self,text)
        return self:append(text)
    end,
    __tostring = function(self)
        if self._len > 1 then
            self._data = {concat(self._data,self._sep or "\n")}
            self._len = 1
        end
        return self._data[1] or ""
    end
}

function _.textbuffer(sep)
    sep = sep or ""
    return setmetatable({_len = 0, _data = {}, _sep = sep},_.textbuffermeta)
end

_.indenttable = setmetatable({},{__index = function(t,k) t[k] = rep("    ",k) return t[k] end })
function _.serializefunc(args)
    local obj,curpath = args.obj,args.curpath or "t"
    local forprint,indent = args.forprint or false,args.indent or 0
    local saved,refs = args.saved or {}, args.refs or _.textbuffer()
    local ret = _.textbuffer()
    local function append(str) return ret:append(str) end
    local function appendline() return ret:append("\n") end
    local function appendkv(k,v)
        return ret:append("["):append(tostring(k)):append("]="):append(tostring(v))
    end
    local function serializekv(k,v)
        local serializedk = _.serializefunc{obj = k,indent = indent +1, forprint = forprint,saved = saved,refs = refs,curpath = curpath }
        local serializedv = _.serializefunc{obj = v,indent = indent +1, forprint = forprint,saved = saved,refs = refs,curpath = format("%s[%s]",curpath,serializedk)}
        if serializedk~= nil and serializedv~= nil then
            append(_.indenttable[indent +1])
            appendkv(serializedk,serializedv)
            append(",")
            appendline()
        end
    end

    local t = type(obj)
    if t == "number" then
        append(tostring(obj))
    elseif t == "boolean" then
        append(tostring(obj))
    elseif t == "string" then
        append(format("%q", obj))
    elseif t == "table" then
        if saved[obj] then
            refs:append("\n"):append(curpath):append("="):append(saved[obj])
            return nil
        else
            saved[obj] = curpath
            local metatable = getmetatable(obj)
            if forprint and metatable and type(metatable.__tostring) == "function" then
                append(tostring(obj))
            else
                append("{")
                appendline()
                for k, v in pairs(obj) do
                    serializekv(k,v)
                end
                if metatable ~= nil and type(metatable.__index) == "table" then
                    for k, v in pairs(metatable.__index) do
                        serializekv(k,v)
                    end
                end
                append(_.indenttable[indent])
                append("}")
            end
        end
    elseif t == "nil" then
        if forprint then
            append("nil")
        else
            return nil
        end
    elseif forprint then
        append(tostring(obj))
    else
        error("failed to serialize type " .. t)
        return nil
    end
    return ret,refs
end

function _.serialize(t)
    local ret,refs = _.serializefunc{obj = t, forprint = false, curpath = "t"}
    local refstr = tostring(refs)
    if refstr == "" then
        return tostring(ret)
    else
        return "local t =" .. tostring(ret:append("\n"):append(refstr))
    end
end

function _.printtable(t)
    local ret,refs = _.serializefunc{obj = t, forprint = true, curpath = "t"}
    local refstr = tostring(refs)
    if refstr == "" then
        print(tostring(ret))
    else
        print("local t =" .. tostring(ret:append("\n"):append(refstr)))
    end
end

function _.deserialize(str)
    local t = type(str)
    if t == "nil" or str == "" then
        return nil
    elseif t == "number" or t == "string" or t == "boolean" then
        str = tostring(str)
    else
        error("failed to deserialize type " .. t)
    end
    str = "return " .. str
    -- str .. "\n return t"
    local func = loadstring(str)
    if func == nil then
        error("deserialize failed ... got invalid string")
    end
    return func()
end

function _.zip(tk,tv)
    _.assertarray(tk)
    _.assertarray(tv)
    local len, ret = 0,{}
    local lenk, lenv = #tk, #tv
    len = lenk < lenv and lenk or lenv
    for i = 1, len do
        ret[tk[i]] = tv[i]
    end
    return ret
end

function _.unzip(t)
    _.asserttable(t)
    local tk,tv = {},{}
    for k,v in pairs(t) do
        insert(tk,k)
        insert(tv,v)
    end
    return tk,tv
end

function _.merge(tto,tfrom)
    _.asserttable(tto)
    _.asserttable(tfrom)
    for k, v in pairs(tfrom) do
        tto[k] = v
    end
    return tto
end

function _.append(fst, sec)
    _.assertarray(fst)
    _.assertarray(sec)
    local l = #fst
    for i,v in ipairs(sec) do
        fst[l+i] = v
    end
    return fst
end

function _.split(t)
    _.asserttable(t)
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

function _.reverse(t)
    _.assertarray(t)
    local n = #t+1
    local half = floor(n/2)
    for i= 1, half do
        t[i], t[n-i] = t[n - i], t[i]
    end
    return t
end

function _.lock(t)
    _.asserttable(t)
    return setmetatable({},{
        __index = t,
        __newindex = function(t,k) error("failed to add/change value for index/key ".. k) end,
        __metatable = "table is locked"
    })
end

function _.unique(t)
    _.assertarray(t)
    local ret = {}
    for i,v in ipairs(t) do
        if nil == _.find(ret,v) then
            insert(ret,v)
        end
    end
    return ret
end

function _.flip(t)
    _.asserttable(t)
    local ret = {}
    for k,v in pairs(t) do
        if nil == ret[v] then ret[v] = k end
    end
    return ret
end

function _.intersect(t1,t2)
    _.asserttable(t1)
    _.asserttable(t2)
    local ret = {}
    for k,_ in pairs(t2) do
        if t1[k] ~= nil then
            ret[k] = t1[k]
        end
    end
    return ret
end

function _.combine(t1,t2)
    _.asserttable(t1)
    _.asserttable(t2)
    local ret = _.deepcopy(t2)
    for k,_ in pairs(t1) do
        ret[k] = t1[k]
    end
    return ret
end

function _.equal(t1, t2)
    if not _.istable(t1) or not _.istable(t2) then return t1 == t2 end
    local size1 = 0
    for k,v in pairs(t1) do
        if not _.equal(v,t2[k]) then return false end
        size1 = size1 + 1
    end
    return size1 == _.size(t2)
end

function _.findall(t,func)
    _.asserttable(t)
    _.assertfunction(func)
    local ret = {}
    for k,v in pairs(t) do
        if func(v) then
            ret[k] = v
        end
    end
    return ret
end

function _.removeall(t,func)
    _.asserttable(t)
    _.assertfunction(func)
    for k,v in pairs(t) do
        if func(v) then
            t[k] = nil
        end
    end
    return t
end

function _.kvtoarray(t,sortfunc)
    _.asserttable(t)
    local ret = {}
    for _,v in pairs(t) do
        insert(ret,v)
    end
    if sortfunc then
        _.assertfunction(sortfunc)
        sort(ret,sortfunc)
    end
    return ret
end

return {
    NAME = "tableext",
    REPO = "https://github.com/aillieo/tableext",
    isempty = _.isempty,
    size = _.size,
    isarray = _.isarray,
    clear = _.clear,
    deepcopy = _.deepcopy,
    find = _.find,
    serialize = _.serialize,
    deserialize = _.deserialize,
    printtable = _.printtable,
    zip = _.zip,
    unzip = _.unzip,
    merge = _.merge,
    append = _.append,
    split = _.split,
    reverse = _.reverse,
    lock = _.lock,
    map = _.map,
    filter = _.filter,
    reduce = _.reduce,
    unique = _.unique,
    flip = _.flip,
    intersect = _.intersect,
    combine = _.combine,
    textbuffer = _.textbuffer,
    equal = _.equal,
    findall = _.findall,
    removeall = _.removeall,
    kvtoarray = _.kvtoarray
}
