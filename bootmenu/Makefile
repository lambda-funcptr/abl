all:
	make bootmenu

bootmenu: src/*.c
	mkdir -p build
	$(CC) -o build/bootmenu src/*.c -l ncurses

run:
	make bootmenu
	build/bootmenu

clean:
	rm -rf build