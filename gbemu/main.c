#include <emu.h>

int main(int argc, char **argv) {
    return emu_run(argc, argv);
}
double sc_time_stamp() {
    return 0; // Return the current simulation time in picoseconds, or 0 if not using SystemC.
}