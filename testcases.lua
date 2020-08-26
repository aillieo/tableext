local te = require("tableext")

print("Beginning ...")
local time = os.clock()

local simpleArray = {1,2,3}
local simpleDict = {a=1,b=2,c=3}
local largeArray = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100}
local largeDict = {a=1,b=2,c=3,d=4,e=5,f=6,g=7,h=8,i=9,j=10,k=11,l=12,m=13,n=14,o=15,p=16,q=17,r=18,s=19,t=20,u=21,v=22,w=23,x=24,y=25,z=26,A=27,B=28,C=29,D=30,E=31,F=32,G=33,H=34,I=35,J=36,K=37,L=38,M=39,N=40,O=41,P=42,Q=43,R=44,S=45,T=46,U=47,V=48,W=49,X=50,Y=51,Z=52,aa=53,ab=54,ac=55,ad=56,ae=57,af=58,ag=59,ah=60,ai=61,aj=62,ak=63,al=64,am=65,an=66,ao=67,ap=68,aq=69,ar=70,as=71,at=72,au=73,av=74,aw=75,ax=76,ay=77,az=78,aA=79,aB=80,aC=81,aD=82,aE=83,aF=84,aG=85,aH=86,aI=87,aJ=88,aK=89,aL=90,aM=91,aN=92,aO=93,aP=94,aQ=95,aR=96,aS=97,aT=98,aU=99,aV=100}
local deepTable = {a=1,b={1,2},c={{1,2,3},2,3},d={{{1,2,3},2,3},2},e={{{{1,2,3},2,3},2},2,3},f={1,2,{{{{1,2,3},2,3},2},2,3}},g={1,{1,2,{{{{1,2,3},2,3},2},2,3}},3},h={a={1,{1,2,{{{{1,2,3},2,3},2},2,3}},3},b={},c={{{{1,2,3},2,3},2},2,3}},i={{a={1,{1,2,{{{{1,2,3},2,3},2},2,3}},3},b={},c={{{{{a={1,{1,2,{{{{1,2,3},2,3},2},2,3}},3},b={{a={1,{1,2,{{{{1,2,3},2,3},{a={b={c={d={},e={},f={g={h={},i={},j={k={l={m={},n={}}}},o={p={},q={}}}}},r={}}}}},2,3}},3},b={},c={{{{1,2,3},2,3},2},2,3}}},c={{{{1,2,3},2,3},2},2,3}}},2,3},2},2,3}}}}

-- isempty
do
    assert(te.isempty({}))
    assert(not te.isempty({1}))
end

-- size
do
    assert(te.size({}) == 0)
    assert(te.size(simpleArray) == 3)
    assert(te.size(simpleDict) == 3)
    assert(te.size(largeArray) == 100)
    assert(te.size(largeDict) == 100)
end

-- isarray
do
    assert(te.isarray(simpleArray))
    assert(not te.isarray(simpleDict))
    assert(te.isarray(largeArray))
    assert(not te.isarray(largeDict))
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
    local t3 = {1,2,3,4,5,{a=3,b={9,8,6}}}
    assert(te.equal(t1,t2))
    assert(not te.equal(t1,t3))
    local t4 = {a=1,b=2,c=3}
    local t5 = {c=3,b=2,a=1}
    assert(te.equal(t4,t5))
end

-- deepcopy
do
    local c = te.deepcopy(deepTable)
    assert(deepTable~=c)
    assert(te.equal(deepTable,c))
end

-- find
do
    assert(te.find(simpleArray,2) == 2)
    assert(te.find(simpleDict,2) == "b")
    assert(te.find(largeArray,80) == 80)
    assert(te.find(largeDict,80) == "aB")
    assert(te.find(largeDict,1024) == nil)
end

-- zip
do
    local a = {"a","b","c"}
    local b = te.zip(a,simpleArray)
    assert(te.equal(b,simpleDict))
end

-- unzip
do
    local ks,vs = te.unzip(simpleDict)
    for i,v in ipairs(ks) do
        local a,b = vs[i],simpleDict[v]
        assert(te.equal(a,b))
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
    local a = te.map(simpleArray,tostring)
    local b = {"1","2","3"}
    assert(te.equal(a,b))
    local c = te.map(simpleArray,b)
    assert(te.equal(c,b))
end

-- filter
do
    local a = {1,2,3,4,5}
    local b = te.filter(a,function(i) return i%2 == 0 end)
    assert(te.equal(b,{2,4}))
    local c = {false,true,false,true}
    local d = te.filter(a,c)
    assert(te.equal(d,{2,4}))
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
    local b = te.flip(simpleDict)
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
    xpcall(function() b[1] = 0 end, print)
    xpcall(function() b[4] = 5 end, print)
end

-- printtable
do
    te.printtable(deepTable)
end

-- serialize/deserialize
do
    local str = te.serialize(deepTable)
    local a = te.deserialize(str)
    assert(te.equal(deepTable,a))
end

-- findall
do
    local a = {a=1,b=2,c=3,d=4,e=5}
    local b = te.findall(a,function(k,n) return n%2 == 0 end)
    assert(te.equal(b,{b=2,d=4}))
    local c = {[2]=true, [4]=true}
    local d = te.findall(a,c)
    assert(te.equal(d,{b=2,d=4}))
end

-- removeall
do
    local a = {a=1,b=2,c=3,d=4,e=5}
    te.removeall(a,function(k,n) return n%2 == 0 end)
    assert(te.equal(a,{a=1,c=3,e=5}))
    te.removeall(a,{[3]=true})
    assert(te.equal(a,{a=1,e=5}))
end

-- kvtoarray
do
    local a = {a={1,2},b={0},c={3,3,3}}
    local b = te.kvtoarray(a,function(v1,v2) return #v1 > #v2 end)
    assert(te.equal(b,{{3,3,3},{1,2},{0}}))
end

-- flat
do
    local t = {1,{2,3},4,5,{6,{7,{8,9},10}}}
    assert(te.equal(te.flat(t),{1,2,3,4,5,6,7,8,9,10}))
end

-- pairsinorder
do
    local t = {a=1,b=2,c=3,d=1,e=2,f=3}
    local keysinorder = {"a","b","c","d","e","f"}
    local keys = {}
    for k,v,i in te.pairsinorder(t) do
        table.insert(keys, k)
    end
    assert(te.equal(keysinorder, keys))
end

local cost = os.clock() - time
print("All cases passed successfully!\n cost time " .. cost)
