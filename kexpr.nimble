# Package

version = "0.0.2"
description   = "math expression evaluator library"
author        = "Brent Pedersen"
license       = "MIT"
skipFiles     = @["tests.nim"]
#installFiles  = @["src/kexpr.nim", "src/kexpr-c.c", "src/kexpr-c.h"]

requires "nim >= 0.17.0"

task test, "tests":
    exec "nim c -r tests.nim"

task docs, "make the docs":
    exec "nim doc kexpr.nim"
    exec "mv kexpr.html docs/index.html"
