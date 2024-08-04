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
C_SRCS = $(wildcard $(LIBDIR)/*.c)
CPP_SRCS = $(wildcard $(MAINDIR)/*.cpp)
OBJS = $(C_SRCS:$(LIBDIR)/%.c=$(OBJDIR)/%.o) $(CPP_SRCS:$(MAINDIR)/%.cpp=$(OBJDIR)/%.o)
TARGET = $(BINDIR)/gbemu

# Verilator files
VERILOG_SRC = $(wildcard $(VERILOGDIR)/*.v)
VERILATED_CPP = $(OBJDIR)/Vcpu__ALL.cpp
VERILATOR_O = $(OBJDIR)/Vcpu__ALL.o

# Rules
all: $(TARGET)

# Ensure Verilator runs and generates Verilated C++ files
$(VERILATED_CPP): $(VERILOG_SRC)
	@mkdir -p $(OBJDIR)
	verilator --cc $(VERILOG_SRC) --Mdir $(OBJDIR)
	make -C $(OBJDIR) -f Vcpu.mk

# Compile Verilated C++ files, including verilated.cpp
$(OBJDIR)/Vcpu__ALL.o: $(OBJDIR)/Vcpu__ALL.cpp | $(VERILATED_CPP)
	$(CXX) $(CXXFLAGS) -c -o $@ $<

# Compile C library files with Verilated headers
$(OBJDIR)/%.o: $(LIBDIR)/%.c | $(VERILATED_CPP)
	@mkdir -p $(OBJDIR)
	$(CXX) $(CXXFLAGS) -c -o $@ $<

# Compile C++ main files with Verilated headers
$(OBJDIR)/%.o: $(MAINDIR)/%.cpp | $(VERILATED_CPP)
	@mkdir -p $(OBJDIR)
	$(CXX) $(CXXFLAGS) -c -o $@ $<

# Link everything together
$(TARGET): $(OBJS) $(VERILATOR_O)
	@mkdir -p $(BINDIR)
	$(CXX) $(CXXFLAGS) -o $@ $(OBJS) $(VERILATOR_O) $(LDFLAGS)

# Clean up
clean:
	rm -f $(OBJDIR)/*.o $(OBJDIR)/*.cpp $(TARGET)
	rm -rf $(OBJDIR)

.PHONY: all clean
