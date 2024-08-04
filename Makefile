# Variables
CC = gcc
CXX = g++
CFLAGS = -Wall -I/mingw64/include -I$(INCLUDEDIR)
CXXFLAGS = -Wall -I/mingw64/include -I$(INCLUDEDIR) -I$(OBJDIR) -I$(VERILATOR_INC)
LDFLAGS = -L/mingw64/bin -lSDL2 -lSDL2_ttf

# Directories
INCLUDEDIR = include
LIBDIR = lib
MAINDIR = gbemu
BINDIR = bin
VERILOGDIR = verilog_src
OBJDIR = obj_dir
VERILATOR_INC = C:/msys64/mingw64/share/verilator/include

# Source and object files
SRCS = $(wildcard $(LIBDIR)/*.c) $(wildcard $(MAINDIR)/*.cpp)
OBJS = $(SRCS:$(LIBDIR)/%.c=$(OBJDIR)/%.o) $(SRCS:$(MAINDIR)/%.cpp=$(OBJDIR)/%.o)
TARGET = $(BINDIR)/gbemu

# Verilator files
VERILOG_SRC = $(wildcard $(VERILOGDIR)/*.v)
VERILATED_CPP = $(OBJDIR)/verilated.cpp
VERILATOR_O = $(OBJDIR)/Vcpu__ALL.o

# Rules
all: $(TARGET)

# Ensure Verilator runs and generates Verilated C++ files
$(VERILATOR_O): $(VERILOG_SRC)
	@mkdir -p $(OBJDIR)
	verilator --cc $(VERILOG_SRC) --exe --Mdir $(OBJDIR)
	make -C $(OBJDIR) -f Vcpu.mk

# Compile Verilated C++ files, including verilated.cpp
$(OBJDIR)/%.o: $(OBJDIR)/%.cpp | $(VERILATOR_O)
	$(CXX) $(CXXFLAGS) -c -o $@ $<

# Compile verilated.cpp
$(OBJDIR)/verilated.o: 
	$(CXX) $(CXXFLAGS) -c -o $@ $<

# Compile verilator_utils.cpp
$(OBJDIR)/verilator_utils.o:
	$(CXX) $(CXXFLAGS) -c -o $@ $<

# Compile C library files with Verilated headers
$(OBJDIR)/%.o: $(LIBDIR)/%.c | $(VERILATOR_O)
	@mkdir -p $(OBJDIR)
	$(CXX) $(CXXFLAGS) -c -o $@ $<

# Link everything together
$(TARGET): $(OBJS) $(VERILATOR_O) $(OBJDIR)/verilated.o
	@mkdir -p $(BINDIR)
	$(CXX) $(CXXFLAGS) -o $@ $(OBJS) $(VERILATOR_O) $(OBJDIR)/verilated.o $(LDFLAGS)

# Clean up
clean:
	rm -f $(OBJDIR)/*.o $(OBJDIR)/*.cpp $(TARGET)
	rm -rf $(OBJDIR)

.PHONY: all clean
