local te = require("tableext")

print("Beginning ...")
local time = os.clock()

-- isempty
do
    assert(te.isempty({}))
    assert(not te.isempty({1}))
end

-- size
do
    assert(te.size({}) == 0)
    assert(te.size({1,2,3}) == 3)
    assert(te.size({a=1,b=2,c=3}) == 3)
end

-- isarray
do
    assert(te.isarray({1,2,3}))
    assert(not te.isarray({a=1,b=2,c=3}))
end

-- clear
do
    local t = {a=3,b=6}
    assert(not te.isempty(t))
    te.clear(t)
    assert(te.isempty(t))
end

-- equal
do
    local t1 = {1,2,3,4,5,{a=3,b={9,8,7}}}
    local t2 = {1,2,3,4,5,{a=3,b={9,8,7}}}
    assert(te.equal(t1,t2))
end

-- deepcopy
do
    local t = {a=1,b=2,c={1,2,3}}
    local c = te.deepcopy(t)
    assert(t~=c)
    assert(te.equal(t,c))
end

-- find
do
    assert(te.find({1,2,3},2) == 2)
    assert(te.find({a=1,b=2,c=3},2) == "b")
    assert(te.find({a=1,b=2,c=3},4) == nil)
end

-- zip
do
    local a = {"a","b","c"}
    local b = {1,2,3}
    local c = {a=1,b=2,c=3}
    assert(te.equal(te.zip(a,b),c))
end

-- unzip
do
    local a = {a=1,b=2,c=3}
    local ks,vs = te.unzip(a)
    for i,v in ipairs(ks) do
        assert(te.equal(vs[i],a[v]))
    end
end

-- merge
do
    local a = {a=1,b=2,c=3}
    local b = {c=4,d=5}
    te.merge(a,b)
    local c = {a=1,b=2,c=4,d=5}
    assert(te.equal(a,c))
end

-- append
do
    local a = {1,2,3}
    local b = {4,5,6}
    te.append(a,b)
    local c = {1,2,3,4,5,6}
    assert(te.equal(a,c))
end

-- split
do
    local a = {1,2,3,a=4,b=5,c=6}
    local b,c = te.split(a)
    assert(te.equal(b,{1,2,3}))
    assert(te.equal(c,{a=4,b=5,c=6}))
end

-- reverse
do
    local a = {1,2,3,4,5,6,7}
    te.reverse(a)
    assert(te.equal(a,{7,6,5,4,3,2,1}))
end

-- map
do
    local a = {1,2,3}
    local b = te.map(a,tostring)
    assert(te.equal(b,{"1","2","3"}))
end

-- filter
do
    local a = {1,2,3,4,5}
    local b = te.filter(a,function(i) return i%2 == 0 end)
    assert(te.equal(b,{2,4}))
end

-- reduce
do
    local a = {1,2,3,4,5}
    local b = te.reduce(a,function(t,i) return t..i end)
    assert(b == "12345")
end

-- unique
do
    local a = {1,2,3,4,4,5,1}
    local b = te.unique(a)
    assert(te.equal(b,{1,2,3,4,5}))
end

-- flip
do
    local a = {a=1,b=2,c=3}
    local b = te.flip(a)
    assert(te.equal(b,{"a","b","c"}))
end

-- intersect
do
    local a = {a=1,b=2,c=3}
    local b = {c=4,d=5}
    local i = te.intersect(a,b)
    assert(te.equal(i,{c=3}))
end

-- combine
do
    local a = {a=1,b=2,c=3}
    local b = {c=4,d=5}
    local c = te.combine(a,b)
    assert(te.equal(c,{a=1,b=2,c=3,d=5}))
end

-- lock
do
    local a = {1,2,3}
    local b = te.lock(a)
    xpcall(function() b[1] = 0 end,
    print)
    xpcall(function() b[4] = 5 end,
    print)
end

-- serialize/deserialize
do
    local a = {1,2,{4,5,{a=1}}}
    te.printtable(a)
    local str = te.serialize(a)
    local b = te.deserialize(str)
    assert(te.equal(a,b))
end

local cost = os.clock() - time
print("All cases passed successfully!\n cost time " .. cost)
