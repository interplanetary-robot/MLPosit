#set up include directory
INC=-I./include

obj/posit8.o: src/c-lib/posit8.cpp
	gcc -c -Wall -Werror -fpic $(INC) src/c-lib/posit8.cpp -o obj/posit8.o

obj/Posit8.o: src/c-lib/Posit8.cpp
	gcc -c -Wall -Werror -fpic $(INC) src/c-lib/Posit8.cpp -o obj/Posit8.o

build: obj/posit8.o obj/Posit8.o
	gcc -shared -o bin/libmlposit.so obj/posit8.o obj/Posit8.o

#test: /test/test.cpp
#	gcc -Wall -o test /test/test.cpp -lstdc++ -lmlposit
#	chmod +x test
#	./test

.PHONY: install
install:
	cp bin/libmlposit.so /usr/lib
	chmod a+r /usr/lib/libmlposit.so

.PHONY: clean
clean:
	rm -f bin/*.so obj/*.o
