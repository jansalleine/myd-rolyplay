#ifndef ROLYPLAY_H_
#define ROLYPLAY_H_

#define VERSION         "1.0"
#define DEFAULT_OUT     "out.prg"
#define DEFAULT_TITLE   "untitled"
#define DEFAULT_DUR     "03:30"
#define LOAD_ADDR       0x0810
#define OFFS_MUSIC      0x07F2
#define OFFS_TITLE      0x2CA2
#define OFFS_LINE       0x2CCA
#define OFFS_DUR        0x2D57
#define OFFS_SIDHEAD    0x7E

char *newstr(char *initial_str);
void print_info();
void print_help();

#endif // ROLYPLAY_H_
