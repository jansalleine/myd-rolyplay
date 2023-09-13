GCC = gcc
FLAGS = -Wall -v
FLAGS_STATIC = -static
DEBUG?=
RM = rm -f
CP = cp -v -f

WIN_GCC = i686-w64-mingw32-gcc
WIN_FLAGS = -Wall -v

OBJECTS=rolyplay.c rolyplay.h

EXOOBJECTS=\
	exomizer/chunkpool.o \
	exomizer/exomizer.o \
	exomizer/match.o \
	exomizer/optimal.o \
	exomizer/output.o \
	exomizer/radix.o \
	exomizer/search.o \
	exomizer/sfx64ne.o

all: rolyplay

rolyplay.o: $(OBJECTS)
	$(GCC) $(FLAGS) $(DEBUG) -c -o $@ $<
	@echo $(OBJECTS)

rolyplay: rolyplay.o $(EXOOBJECTS)
	$(GCC) $(FLAGS) $(DEBUG) -o $@ $<
	$(CP) $@ ../bin/


clean:
	$(RM) rolyplay rolyplay.o
	$(RM) ../bin/rolyplay
