#include <ctype.h>
#include <libgen.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "exomizer/exomizer.h"
#include "player.h"
#include "rolyplay.h"

// for converting uppercase ASCII to C64 screen codes
unsigned char convtab[] = {
    0x00,       // 0x00
    0x00,       // 0x01
    0x00,       // 0x02
    0x00,       // 0x03
    0x00,       // 0x04
    0x00,       // 0x05
    0x00,       // 0x06
    0x00,       // 0x07
    0x00,       // 0x08
    0x00,       // 0x09
    0x00,       // 0x0A
    0x00,       // 0x0B
    0x00,       // 0x0C
    0x00,       // 0x0D
    0x00,       // 0x0E
    0x00,       // 0x0F
    0x00,       // 0x10
    0x00,       // 0x11
    0x00,       // 0x12
    0x00,       // 0x13
    0x00,       // 0x14
    0x00,       // 0x15
    0x00,       // 0x16
    0x00,       // 0x17
    0x00,       // 0x18
    0x00,       // 0x19
    0x00,       // 0x1A
    0x00,       // 0x1B
    0x00,       // 0x1C
    0x00,       // 0x1D
    0x00,       // 0x1E
    0x00,       // 0x1F
    0x20,       // 0x20
    0x21,       // 0x21
    0x22,       // 0x22
    0x23,       // 0x23
    0x24,       // 0x24
    0x25,       // 0x25
    0x26,       // 0x26
    0x27,       // 0x27
    0x28,       // 0x28
    0x29,       // 0x29
    0x2A,       // 0x2A
    0x2B,       // 0x2B
    0x2C,       // 0x2C
    0x2D,       // 0x2D
    0x2E,       // 0x2E
    0x2F,       // 0x2F
    0x30,       // 0x30
    0x31,       // 0x31
    0x32,       // 0x32
    0x33,       // 0x33
    0x34,       // 0x34
    0x35,       // 0x35
    0x36,       // 0x36
    0x37,       // 0x37
    0x38,       // 0x38
    0x39,       // 0x39
    0x3A,       // 0x3A
    0x3B,       // 0x3B
    0x3C,       // 0x3C
    0x3D,       // 0x3D
    0x3E,       // 0x3E
    0x3F,       // 0x3F
    0x00,       // 0x40
    0x01,       // 0x41
    0x02,       // 0x42
    0x03,       // 0x43
    0x04,       // 0x44
    0x05,       // 0x45
    0x06,       // 0x46
    0x07,       // 0x47
    0x08,       // 0x48
    0x09,       // 0x49
    0x0A,       // 0x4A
    0x0B,       // 0x4B
    0x0C,       // 0x4C
    0x0D,       // 0x4D
    0x0E,       // 0x4E
    0x0F,       // 0x4F
    0x10,       // 0x50
    0x11,       // 0x51
    0x12,       // 0x52
    0x13,       // 0x53
    0x14,       // 0x54
    0x15,       // 0x55
    0x16,       // 0x56
    0x17,       // 0x57
    0x18,       // 0x58
    0x19,       // 0x59
    0x1A,       // 0x5A
    0x1B,       // 0x5B
    0x1C,       // 0x5C
    0x1D,       // 0x5D
    0x1E,       // 0x5E
    0x1F,       // 0x5F
    // ... the rest is invalid anyway ...
};

int main(int argc, char *argv[])
{
    // vars depending on #defines
    char    outfileName[128]    = DEFAULT_OUT;

    // vars - init just to be "super-safe" :-P
    char    *infileName         = NULL;
    char    *infileNopath       = NULL;

    char    duration[6]         = DEFAULT_DUR;
    char    songTitle[41]       = DEFAULT_TITLE;

    FILE    *infile             = NULL;
    FILE    *outfile            = NULL;

    int     c                   = 0;
    int     compressedSize      = 0;
    int     i                   = 0;
    int     inputData           = 0;
    int     load                = LOAD_ADDR;
    int     offsetDur           = OFFS_DUR;
    int     offsetLine          = OFFS_LINE;
    int     offsetMusic         = OFFS_MUSIC;
    int     offsetTitle         = OFFS_TITLE;
    int     padLeft             = 0;
    int     padRight            = 0;
    int     skipBytes           = OFFS_SIDHEAD;
    int     titleSize           = 0;

    unsigned char compressedData[0xFFFF] = {0};

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

    // getopt cmdline-argument handler
    opterr = 1;

    while ((c = getopt(argc, argv, "d:t:o:")) != -1)
    {
        switch (c)
        {
            case 'd':
                if (strlen(optarg) != 5)
                {
                    printf("\nError: -d duration parameter incorrect.\n");
                    printf("Correct format: 59:59\n");
                    exit(EXIT_FAILURE);
                }
                else
                {
                    strcpy(duration, optarg);
                }
                break;
            case 't':
                if (strlen(optarg) > 40)
                {
                    printf("\nError: -t songtitle parameter too long\n");
                    exit(EXIT_FAILURE);
                }
                else
                {
                    strcpy(songTitle, optarg);
                }
                break;
            case 'o':
                if (strlen(optarg) > 127)
                {
                    printf("\nError: -o outfile parameter too long\n");
                    exit(EXIT_FAILURE);
                }
                else
                {
                    strcpy(outfileName, optarg);
                }
                break;
        }
    }

    // make sure a file was given
    if ((optind) == argc)
    {
        printf( "\nError: no SID file specified.\n" );
        exit(EXIT_FAILURE);
    }

    // create outfile and make sure it's writeable
    outfile = fopen(outfileName, "w");
    if (outfile == NULL)
    {
        printf("\nError: couldn't create file \"%s\".\n", outfileName);
        exit(EXIT_FAILURE);
    }
    else
    {
        fclose(outfile);
    }

    // open SID file
    infileName = newstr(argv[optind]);
    infileNopath = basename(infileName);

    infile = fopen(infileName, "rb");
    if (infile == NULL)
    {
        printf("\nError: couldn't read file \"%s\".\n", infileNopath);
        exit(EXIT_FAILURE);
    }

    // title to uppercase (ascii -> petscii)
    for (i = 0; songTitle[i]; i++)
    {
        songTitle[i] = toupper(songTitle[i]);
    }

    printf("input filename:    %s\n", infileNopath);
    printf("output filename:   %s\n", outfileName);
    printf("song title:        %s\n", songTitle);
    printf("song duration:     %s\n", duration);

    // forward infile again according to skipbytes
    fseek(infile, skipBytes, 0);

    // read SID tune data into playerPrg
    while  ((inputData = fgetc(infile)) != EOF)
    {
        playerPrg[offsetMusic] = inputData;
        offsetMusic++;
    }

    fclose(infile);

    // get the title padding
    titleSize = strlen(songTitle);
    padLeft = (40 - titleSize) / 2;
    padRight = padLeft;

    if ((padLeft + titleSize + padRight) < 40)
    {
        padRight++;
    }

    // insert title and underline
    for (i = 0; i < padLeft; i++)
    {
        playerPrg[offsetTitle] = 0x20;
        playerPrg[offsetLine] = 0x20;
        offsetTitle++;
        offsetLine++;
    }

    for (i = 0; i < titleSize; i++)
    {
        playerPrg[offsetTitle] = convtab[songTitle[i]];
        playerPrg[offsetLine] = 0x00;
        offsetTitle++;
        offsetLine++;
    }

    for (i = 0; i < padRight; i++)
    {
        playerPrg[offsetTitle] = 0x20;
        playerPrg[offsetLine] = 0x20;
        offsetTitle++;
        offsetLine++;
    }

    // insert duration
    for (i = 0; i < 5; i++)
    {
        playerPrg[offsetDur] = duration[i];
        offsetDur++;
    }

    // exomize the data
    compressedSize = exomizer(playerPrg + 2, playerPrgLength - 2, load, load, compressedData);

    // write to the outfile
    outfile = fopen(outfileName, "ab");

    for (i = 0; i < compressedSize; i++)
    {
        fputc(compressedData[i], outfile);
    }

    fclose(outfile);

    exit(EXIT_SUCCESS);
}

// string helper functions

char *newstr(char *initial_str)
{
    int num_chars;
    char *new_str;

    num_chars = strlen(initial_str) + 1;
    new_str = malloc(num_chars);

    strcpy (new_str, initial_str);

    return new_str;
}

void print_info()
{
    const char* version = VERSION;

    printf( "===============================================================================\n" );
    printf( "rolyplay - generates a C64 SID tune player for R0ly                 Version %s\n", version );
    printf( "                                                            by Spider Jerusalem\n");
    printf( "===============================================================================\n" );
    printf( "\n" );
}

void print_help()
{
    printf( "Usage:\n" );
    printf( "======\n" );
    printf( "  rolyplay(.exe) [options] {sidfile}\n" );
    printf( "\n" );

  //printf( "===============================================================================\n" );
    printf( "Command line options:\n" );
    printf( "=====================\n" );
    printf( "  -d duration : length of the tune. format: 03:30.\n" );
    printf( "                [default: 03:30]\n" );
    printf( "  -t title    : title of the tune. lowercase!\n" );
    printf( "                [default: untitled]\n" );
    printf( "  -o outfile  : name of the output file.\n" );
    printf( "                [default: out.prg]\n" );
    printf( "\n" );

    printf( "Example:\n" );
    printf( "========\n" );
    printf( "  rolyplay -d\"03:41\" -t\"mein toller titel\" -o\"meintitel.prg\" meintitel.sid\n" );
    printf( "  rolyplay.exe -d\"03:41\" -t\"mein toller titel\" -o\"meintitel.prg\" meintitel.sid\n" );
    printf( "\n" );
    printf( "Have fun!\n" );
}
