## kexpr evaluates math and boolean expressions

{.compile: "kexpr/kexpr-c.c".}
import tables

type
  kexpr_s {.bycopy.} = object

  kexpr_t* = kexpr_s

const
  KEE_UNQU* = 0x00000001
  KEE_UNLP* = 0x00000002
  KEE_UNRP* = 0x00000004
  KEE_UNOP* = 0x00000008
  KEE_FUNC* = 0x00000010
  KEE_ARG* = 0x00000020
  KEE_NUM* = 0x00000040


const
  KEE_UNFUNC* = 0x00000040
  KEE_UNVAR* = 0x00000080


const
  KEV_REAL* = 1
  KEV_INT* = 2
  KEV_STR* = 3


proc ke_parse*(s: cstring; err: ptr cint): ptr kexpr_t {.importc:"ke_parse",cdecl.}
  ## parse an expression and return errors in $err

proc ke_destroy*(ke: ptr kexpr_t) {.importc:"ke_destroy",cdecl.}
  ## free memory allocated during parsing

proc ke_set_int*(ke: ptr kexpr_t; `var`: cstring; x: int64): cint {.importc:"ke_set_int", discardable, cdecl.}
  ## set a variable to integer value and return the occurrence of the variable

proc ke_set_real*(ke: ptr kexpr_t; `var`: cstring; x: cdouble): cint {.importc:"ke_set_real", discardable, cdecl.}
  ## set a variable to real value and return the occurrence of the variable

proc ke_set_str*(ke: ptr kexpr_t; `var`: cstring; x: cstring): cint {.importc:"ke_set_str", discardable, cdecl.}
  ## set a variable to string value and return the occurrence of the variable

proc ke_set_real_func1*(ke: ptr kexpr_t; name: cstring;
                       `func`: proc (a2: cdouble): cdouble): cint {.importc:"ke_set_real_func1", cdecl.}

proc ke_set_real_func2*(ke: ptr kexpr_t; name: cstring;
                       `func`: proc (a2: cdouble; a3: cdouble): cdouble): cint {.importc:"ke_set_real_func2", cdecl.}
  ## set a user-defined function

proc ke_set_default_func*(ke: ptr kexpr_t): cint {.importc:"ke_set_default_func", cdecl.}
  ## set default math functions

proc ke_unset*(e: ptr kexpr_t) {.importc:"ke_unset", cdecl.}
  ## mark all variable as unset

proc ke_eval*(ke: ptr kexpr_t; i: ptr int64; r: ptr cdouble; s: cstringArray;
             ret_type: ptr cint): cint {.importc:"ke_eval", cdecl.}
  ## evaluate expression; return error code; final value is returned via pointers
proc ke_eval_int*(ke: ptr kexpr_t; err: ptr cint): int64 {.importc:"ke_eval_int", cdecl.}
proc ke_eval_real*(ke: ptr kexpr_t; err: ptr cint): cdouble {.importc:"ke_eval_real", cdecl.}

proc ke_print*(ke: ptr kexpr_t) {.importc:"ke_print", cdecl.}
  ##  print the expression in Reverse Polish notation (RPN)

type
  Expr* = ref object
    ## Expr is a math expression
    ke*: ptr kexpr_t
    err: cint

proc finalize_expr(e: Expr) =
  ke_destroy(e.ke)

proc expression*(s: string): Expr =
  ## initalize an expression
  var e: Expr
  new(e, finalize_expr)
  e.ke = ke_parse(s, e.err.addr)
  return e

proc error*(e:Expr): int {.inline.} =
  ## check the error value of the expression. non-zero values are errors.
  return int(e.err)

proc clear*(e:Expr) {.inline.} =
  ## clear the error state and empty the expression.
  e.err = 0
  if e.ke != nil:
    ke_unset(e.ke)

proc `[]=`*(e:Expr, k:string, val:int or int32 or int64 or int8 or uint or uint8 or uint16 or uint32) {.inline.} =
  ke_set_int(e.ke, k, cint(val))

proc `[]=`*(e:Expr, k:string, val:float or float32 or float64) {.inline.} =
  ke_set_real(e.ke, k, cdouble(val))

proc `[]=`*(e:Expr, k:string, val:string) {.inline.} =
  ke_set_str(e.ke, k, val)

converter toInt*(e: Expr): int {.inline.} =
  ## evaluate the epression and interpret the result as an int.
  return int(ke_eval_int(e.ke, e.err.addr))

converter toInt64*(e: Expr): int64 {.inline.} =
  ## evaluate the epression and interpret the result as an int64.
  return int64(ke_eval_int(e.ke, e.err.addr))

converter toBool*(e: Expr): bool {.inline.} =
  ## evaluate the epression and interpret the result as a bool
  return abs(ke_eval_real(e.ke, e.err.addr)) > 1e-8

converter toFloat*(e: Expr): float {.inline.} =
  ## evaluate the expression and interpret the result as a float.
  return float(ke_eval_real(e.ke, e.err.addr))

converter toFloat64*(e: Expr): float64 {.inline.} =
  ## evaluate the expression and interpret the result as a float64.
  return float64(ke_eval_real(e.ke, e.err.addr))
