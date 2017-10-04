# Package

version = "0.0.1"
description   = "math expression evaluator library"
author        = "Brent Pedersen"
license       = "MIT"

requires "nim >= 0.17.0"

bin = @["kexpr"]

task run, "run the generated main":
    exec "rm -rf nimcache"
    exec "mkdir -p nimcache && cp kexpr-c.h nimcache/"
    exec "nim c --passL:'-lm' kexpr.nim"
    exec "./kexpr"

task build, "build kexpr":
    exec "rm -rf nimcache"
    exec "mkdir -p nimcache && cp kexpr-c.h nimcache/"
    exec "nim c --passL:'-lm' kexpr.nim"

before install:
    exec "rm -rf nimcache"
    exec "mkdir -p nimcache && cp kexpr-c.h nimcache/"
