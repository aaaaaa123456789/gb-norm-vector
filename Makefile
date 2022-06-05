all: test.gb

test.gb: test.o normvector.o
	rgblink -t $^ -m test.map -n test.sym -o $@ -p 0xff
	rgbfix -v -c -m TPP1_1.0+BATTERY -p 0xff -r 9 $@

%.o: %.asm
	rgbasm -p 0xff -DGBC $^ -o $@

clean:
	rm -f *.gb *.o
