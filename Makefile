CC=$(CC)

kexpr: kexpr.nim 
	cp kexpr-c.h nimcache/
	nim c --passL:"-lm" kexpr.nim

all: kexpr

