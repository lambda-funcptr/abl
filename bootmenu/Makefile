
all:
	make bootmenu

chibi-scheme:
	make -C chibi-scheme SEXP_USE_DL=0 CPPFLAGS="-DSEXP_USE_DL=0 -DSEXP_USE_MODULES=0 -DSEXP_USE_GREEN_THREADS=0 -DSEXP_USE_BIGNUMS=0 -DSEXP_USE_FLONUMS=0 -DSEXP_USE_RATIOS=0 -SEXP_USE_COMPLEX=0"

bootmenu: src/*.c
	make chibi-scheme
	mkdir -p build
	cp -L chibi-scheme/libchibi-scheme.so* build/.
	$(CC)\
	 -I chibi-scheme/include \
	 -L chibi-scheme \
	 -o build/bootmenu src/*.c \
	 -l ncurses -l chibi-scheme

run:
	make bootmenu
	LD_PRELOAD=build/libchibi-scheme.so build/bootmenu

clean:
	make -C chibi-scheme clean
	rm -rf build