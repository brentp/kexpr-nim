# kexpr-nim
nim wrapper for Heng Li's kexpr math expression library

[![badge](https://img.shields.io/badge/docs-latest-blue.svg)](https://brentp.github.io/kexpr-nim/)

```Nim
var e = expression("5*6+x > 20")
e["x"] = 10
echo e.int
e["x"] = 20
echo e.int64
assert e.error() == 0

e = expression("(sample1 > 20 & sample2 > 10 & sample3 < 40")
# missing paren
assert e.error() != 0
e.clear()

e = expression("(sample1 > 20) & (sample2 > 10) & (sample3 < 40)")
e["sample1"] = 21; e["sample2"] = 65; e["sample3"] = 20
echo e.int # 1
e["sample1"] = 0
echo e.int # 0
assert e.error() == 0
echo e.float # 0.0
```

## installation

If you have nimble installed you can do:

```
nimble install kexpr
```

[![nimble](https://raw.githubusercontent.com/yglukhov/nimble-tag/master/nimble.png)](https://github.com/nim-lang/nimble)

