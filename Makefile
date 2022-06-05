all: test.gb

test.gb: test.o normvector.o
	rgblink $^ -m test.map -n test.sym -o $@ -p 0xff
	rgbfix -v -c -j -m MBC1+RAM+BATTERY -p 0xff -r 2 $@

%.o: %.asm
	rgbasm -p 0xff -DGBC $^ -o $@

clean:
	rm -f *.gb *.o