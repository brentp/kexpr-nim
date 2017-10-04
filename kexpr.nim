{.compile: "kexpr-c.c".}
import tables

type
  kexpr_s* {.bycopy.} = object
  
  kexpr_t* = kexpr_s

##  Parse errors

const
  KEE_UNQU* = 0x00000001
  KEE_UNLP* = 0x00000002
  KEE_UNRP* = 0x00000004
  KEE_UNOP* = 0x00000008
  KEE_FUNC* = 0x00000010
  KEE_ARG* = 0x00000020
  KEE_NUM* = 0x00000040

##  Evaluation errors

const
  KEE_UNFUNC* = 0x00000040
  KEE_UNVAR* = 0x00000080

##  Return type

const
  KEV_REAL* = 1
  KEV_INT* = 2
  KEV_STR* = 3

##  parse an expression and return errors in $err

proc ke_parse*(s: cstring; err: ptr cint): ptr kexpr_t {.importc, header:"kexpr-c.h".}
##  free memory allocated during parsing

proc ke_destroy*(ke: ptr kexpr_t) {.importc, header:"kexpr-c.h".}
##  set a variable to integer value and return the occurrence of the variable

proc ke_set_int*(ke: ptr kexpr_t; `var`: cstring; x: int64): cint {.importc, header:"kexpr-c.h".}
##  set a variable to real value and return the occurrence of the variable

proc ke_set_real*(ke: ptr kexpr_t; `var`: cstring; x: cdouble): cint {.importc, header:"kexpr-c.h".}
##  set a variable to string value and return the occurrence of the variable

proc ke_set_str*(ke: ptr kexpr_t; `var`: cstring; x: cstring): cint {.importc, header:"kexpr-c.h".}
##  set a user-defined function

proc ke_set_real_func1*(ke: ptr kexpr_t; name: cstring;
                       `func`: proc (a2: cdouble): cdouble): cint {.importc, header:"kexpr-c.h".}
proc ke_set_real_func2*(ke: ptr kexpr_t; name: cstring;
                       `func`: proc (a2: cdouble; a3: cdouble): cdouble): cint {.importc, header:"kexpr-c.h".}
##  set default math functions

proc ke_set_default_func*(ke: ptr kexpr_t): cint {.importc, header:"kexpr-c.h".}
##  mark all variable as unset

proc ke_unset*(e: ptr kexpr_t) {.importc, header:"kexpr-c.h".}
##  evaluate expression; return error code; final value is returned via pointers

proc ke_eval*(ke: ptr kexpr_t; i: ptr int64; r: ptr cdouble; s: cstringArray;
             ret_type: ptr cint): cint {.importc, header:"kexpr-c.h".}
proc ke_eval_int*(ke: ptr kexpr_t; err: ptr cint): int64 {.importc, header:"kexpr-c.h".}
proc ke_eval_real*(ke: ptr kexpr_t; err: ptr cint): cdouble {.importc, header:"kexpr-c.h".}
##  print the expression in Reverse Polish notation (RPN)

proc ke_print*(ke: ptr kexpr_t) {.importc, header:"kexpr-c.h".}

type 
  Expr* = ref object of RootObj
    ## Expr is a math expression
    ke*: ptr kexpr_t
    err: cint

proc finalize_expr(e: Expr) =
  ke_destroy(e.ke)

proc expression*(s: string): Expr =
  var e: Expr
  new(e, finalize_expr)
  e = Expr(err:cint(0))
  e.ke = ke_parse(s, e.err.addr)
  return e

proc error*(e:Expr): int =
  return int(e.err)
 
proc clear*(e:Expr) =
  e.err = 0
  if e.ke != nil:
    ke_unset(e.ke)


proc set_int_vars*(e:Expr, vars:TableRef[string, int]=nil) {.inline.} =
  if vars == nil: return
  for k, v in vars:
    discard ke_set_int(e.ke, k, cint(v))

proc get_int*(e: Expr, vars: TableRef[string, int] = nil): int =
  e.set_int_vars(vars)
  return int(ke_eval_int(e.ke, e.err.addr))

proc get_bool*(e: Expr, vars: TableRef[string, int] = nil): bool =
  e.set_int_vars(vars)
  return int(ke_eval_int(e.ke, e.err.addr)) == 1

proc set_float_vars*(e:Expr, vars:TableRef[string, float]=nil) {.inline.} =
  if vars == nil: return
  for k, v in vars:
    discard ke_set_real(e.ke, k, cdouble(v))

proc get_float*(e: Expr, vars: TableRef[string, float] = nil): float =
  e.set_float_vars(vars)
  return float(ke_eval_real(e.ke, e.err.addr))

when isMainModule:

  var err = cint(0)
  var ke = ke_parse("5*6+x", err.addr)
  discard ke_set_real(ke, "x", 2.0)
  echo ke_eval_real(ke, err.addr)
  ke_destroy(ke)

  var e = expression("5*6+x > 20")
  echo e.get_int({"x": 10}.newTable)
  echo e.get_int({"x": -20}.newTable)
  assert e.error() == 0

  e = expression("5.5*6.7+a/b")
  echo e.get_float({"x": 12.0, "b": 65.5}.newTable)

  e = expression("(sample1 > 20 & sample2 > 10 & sample3 < 40")
  # missing paren
  assert e.error() != 0
  e.clear()

  e = expression("(sample1 > 20) & (sample2 > 10) & (sample3 < 40)")
  echo e.get_int({"sample1": 21, "sample2": 65, "sample3": 20}.newTable)
  echo e.get_bool({"sample1": 0, "sample2": 0, "sample3": 0}.newTable)

