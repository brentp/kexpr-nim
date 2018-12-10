import ./kexpr, unittest, math
# these are taken from: https://github.com/Yardanico/nim-mathexpr
# which is a great library to use if you need pure nim.
const
  TestCases = [
    ("1", 1.0),
    ("1 ", 1.0),

    ("2+1", 2+1.0),
    ("(((2+(1))))", 2 + 1.0),

    ("3+2", 3+2.0),
    ("3+2+4", 3+2+4.0),
    ("(3+2)+4", 3+2+4.0),
    ("3+(2+4)", 3+2+4.0),
    ("(3+2+4)", 3+2+4.0),

    ("3*2*4", 3*2*4.0),
    ("(3*2)*4", 3*2*4.0),
    ("3*(2*4)", 3*2*4.0),
    ("(3*2*4)", 3*2*4.0),

    ("3-2-4", 3-2-4.0),
    ("(3-2)-4", (3-2)-4.0),
    ("3-(2-4)", 3-(2-4.0)),
    ("(3-2-4)", 3-2-4.0),

    ("(3.0*2.0/4.0)", 3.0*2.0/4.0),

    ("log10(1000)", 3.0),
    ("10 > 20", 0.0),
    ("(10 > 20)", 0.0),
    ("20 > 10", 1.0)
  ]

proc `~=`(a, b: float): bool =
  ## Checks if difference between two floats is less than 0.0001
  abs(a - b) < 1e-2

suite "Eval test cases":
  for data in TestCases:
    let (expr, expected) = data
    var e = expression(expr)
    echo ke_set_default_func(e.ke)
    check e.error() == 0
    echo expr, " got:", e.float, " expected:", expected, " ", e.float ~= expected
    check e.float() ~= expected
    e.clear()


  var e = expression("(2 > 1)")
  check e.bool()
  e = expression("0.4")
  check e.bool()
  e = expression("0.0")
  check (not e.bool())


  test "expression strings":
    e = expression("sval > aa22")
    e["sval"] = "asdf"
    #echo e.float
