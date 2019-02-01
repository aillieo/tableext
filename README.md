## tableext

A set of functions that extend lua table operation. Including functions like:

- serializing/deserializing
- deep comparing
- deep copying
- get size of a k-v-table
- judging whether a table is empty/an array
- map/filter/reduce
- split into array-part and k-v-part
- intersect/combine
- and much more

### requirement

Lua 5.1 - Lua 5.3

### usage

With input:

```lua
local te = require("tableext")
local functions = te.findall(te,function(v) return type(v) == "function" end)
local function_names = te.unzip(functions)
table.sort(function_names)
te.printtable(function_names)
```

you may get output like this:

```
{
    [1]="append",
    [2]="clear",
    [3]="combine",
    [4]="deepcopy",
    [5]="deserialize",
    [6]="equal",
    [7]="filter",
    [8]="find",
    [9]="findall",
    [10]="flip",
    [11]="intersect",
    [12]="isarray",
    [13]="isempty",
    [14]="kvtoarray",
    [15]="lock",
    [16]="map",
    [17]="merge",
    [18]="printtable",
    [19]="reduce",
    [20]="removeall",
    [21]="reverse",
    [22]="serialize",
    [23]="size",
    [24]="split",
    [25]="textbuffer",
    [26]="unique",
    [27]="unzip",
    [28]="zip",
}
```

For more details read `testcases.lua`.

