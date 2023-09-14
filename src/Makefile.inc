EXE=$(PREFIX)rolyplay$(SUFFIX)

OBJECTS=rolyplay.o \
	player.o

EXOOBJECTS=\
	exomizer/chunkpool.o \
	exomizer/exomizer.o \
	exomizer/match.o \
	exomizer/optimal.o \
	exomizer/output.o \
	exomizer/radix.o \
	exomizer/search.o \
	exomizer/sfx64ne.o

all: $(EXE)

$(PREFIX)rolyplay$(SUFFIX): $(OBJECTS) $(EXOOBJECTS)
	$(CC) $(CFLAGS) -o $@ $^ $(LIBS)
	strip $@

clean:
	$(RM) $(OBJECTS) $(EXOOBJECTS)
