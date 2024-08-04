#include <Vcpu.h>
#include <verilated.h>
#include <bus.h>
#include <emu.h>
#include <interrupts.h>

Vcpu* verilated_cpu = new Vcpu;
FILE *log_file = NULL;


void cpu_init() {
    log_file = fopen("cpu_log.txt", "w");

    verilated_cpu->dbg_pc = 0x100;
    verilated_cpu->dbg_sp = 0xFFFE;
    verilated_cpu->dbg_AF = 0xB001;
    verilated_cpu->dbg_BC = 0x1300;
    verilated_cpu->dbg_DE = 0xD800;
    verilated_cpu->dbg_HL = 0x4D01;
    verilated_cpu->cpu_is_halted = false;
    verilated_cpu->interrupts_enabled = false;
}

bool cpu_step() {
  //grab the read data (instruction)
  verilated_cpu->mem_data_read = bus_read(verilated_cpu->mem_addr);
  //write the data out if needed
  if(verilated_cpu->mem_do_write){
    bus_write(verilated_cpu->mem_addr, verilated_cpu->mem_data_write);
  }
    fprintf(log_file, "A:%02X F:%02X B:%02X C:%02X D:%02X E:%02X H:%02X L:%02X SP:%04X PC:%04X PCMEM:%02X,%02X,%02X,%02X\n",
          (verilated_cpu->dbg_AF >> 8), ((verilated_cpu->dbg_AF >> 8)&0xFF), 
          (verilated_cpu->dbg_BC >> 8), ((verilated_cpu->dbg_BC >> 8)&0xFF),  
          (verilated_cpu->dbg_DE >> 8), ((verilated_cpu->dbg_DE >> 8)&0xFF),  
          (verilated_cpu->dbg_HL >> 8), ((verilated_cpu->dbg_HL >> 8)&0xFF), 
          verilated_cpu->dbg_sp, verilated_cpu->dbg_pc,
          bus_read(verilated_cpu->dbg_pc), bus_read(verilated_cpu->dbg_pc + 1), bus_read(verilated_cpu->dbg_pc + 2), bus_read(verilated_cpu->dbg_pc + 3));
    //step the clock   
    verilated_cpu->clk = !verilated_cpu->clk;
    verilated_cpu->eval();
    return true;
}