#include <ctype.h>
#include <libgen.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "exomizer/exomizer.h"
#include "rolyplay.h"

int main(int argc, char *argv[])
{
    print_info();

    if ((argc == 1) ||
        (strcmp(argv[1], "-h") == 0) ||
        (strcmp(argv[1], "-help") == 0) ||
        (strcmp(argv[1], "-?") == 0) ||
        (strcmp(argv[1], "--help") == 0))
    {
        print_help();
        exit(EXIT_SUCCESS);
    }

    exit(EXIT_SUCCESS);
}

void print_info()
{
    const char* version = VERSION;

    printf( "===============================================================================\n" );
    printf( "rolyplay - generates a C64 SID tune player for Røly                 Version %s\n", version );
    printf( "                                                            by Spider Jerusalem\n");
    printf( "===============================================================================\n" );
    printf( "\n" );
}

void print_help()
{
    printf( "Description:\n" );
    printf( "============\n" );
  //printf( "===============================================================================\n" );
    printf( "\n" );

    printf( "Usage:\n" );
    printf( "======\n" );
    printf( "   rolyplay [options] {file}\n" );
    printf( "\n" );

  //printf( "===============================================================================\n" );
    printf( "Command line options:\n" );
    printf( "=====================\n" );
    printf( "   -o outfile : name of the output file for the C-code.\n" );
    printf( "                [default: out.c]\n" );
    printf( "   -s skip    : number of bytes to be skipped. I.e. set -s 2 for .PRG files\n" );
    printf( "                or -s 0x7e for .SID files.\n" );
    printf( "                [default: 0]\n" );
    printf( "   -v myvar   : variable name for the C-array.\n" );
    printf( "                [default: data]\n" );
    printf( "\n" );
    printf( "Have fun!\n" );
}
