CXX = mpicxx
CXXFLAGS = -O2 -DBARNEHUT_PARALLEL

SRCS = nbody_mpi.cpp argc.cpp universe.cpp quad_tree.cpp
OBJS = $(SRCS:.cpp=.o)
EXEC = nbody

all: $(EXEC)

$(EXEC): $(OBJS)
	$(CXX) $(LDFLAGS) -o $@ $^

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

clean:
	rm -f $(OBJS) $(EXEC)

.PHONY: all clean