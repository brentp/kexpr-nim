# Package

version = "0.0.1"
description   = "math expression evaluator library"
author        = "Brent Pedersen"
license       = "MIT"
skipFiles     = @["tests.nim"]
#installFiles  = @["kexpr.nim", "kexpr-c.c", "kexpr-c.h"]

requires "nim >= 0.17.0"

task test, "tests":
    exec "nim c -r tests.nim"
