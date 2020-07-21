#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>

#include "libscrypt/libscrypt.h"


/**
 * Swaps bytes of a given buffer, effectively performing a big-endian to/from little-endian conversion
 */
void swap_bytes(uint8_t *buf, int buf_size)
{
    for (int i = 0; i < buf_size/2; i++)
    {
        uint8_t temp = buf[i];
        buf[i] = buf[buf_size-i-1];
        buf[buf_size-i-1] = temp;
    }
}


int main(int argc, char *argv[])
{
    // general definitions for scrypt hash
    const int INPUT_SIZE = 80;   // block header data: concatenation of Version, Prev Hash, Merkle Root, Timestamp, Bits, Nonce
    const int OUTPUT_SIZE = 32;  // hash output size
    const int N = 1024;
    const int r = 1;
    const int p = 1;

    // reads input/output args
    if (argc != 3)
    {
        fprintf(stderr, "ERROR: expected 2 arguments, one for input and another for output, but received %d.\n", argc-1);
        exit(1);
    }
    char *inputFilename = argv[1];
    char *outputFilename = argv[2];

    // defines input and output buffers
    uint8_t input[INPUT_SIZE];
    uint8_t output[OUTPUT_SIZE];

    // reads input data
    printf("Reading input data...\n");
    FILE *inputFile = fopen(inputFilename, "rb");
    if (inputFile == NULL)
    {
        fprintf(stderr, "ERROR: could not open input file '%s' reading.\n", inputFilename);
        exit(2);
    }
    int freadRet = fread(input, sizeof(uint8_t), INPUT_SIZE, inputFile);
    fclose(inputFile);
    if (freadRet < INPUT_SIZE)
    {
        fprintf(stderr, "ERROR: could only read %d bytes from input file '%s' - should have read %d bytes.\n", freadRet, inputFilename, INPUT_SIZE);
        exit(3);
    }

    // converts input from big-endian to little-endian, considering each sub-part
    // - Version (4 bytes)
    // - Previous hash (32 bytes)
    // - Merkle root (32 bytes)
    // - Timestamp (4 bytes)
    // - Bits (target in compact form) (4 bytes)
    // - Nonce (4 bytes)
    swap_bytes(input, 4);
    swap_bytes(input+4, 32);
    swap_bytes(input+36, 32);
    swap_bytes(input+68, 4);
    swap_bytes(input+72, 4);
    swap_bytes(input+76, 4);


    // COMPUTES HASH USING SCRYPT
    printf("Computing scrypt hash...\n");
    int retval = libscrypt_scrypt(input, INPUT_SIZE, input, INPUT_SIZE, N, r, p, output, OUTPUT_SIZE);
    if(retval != 0)
    {
        fprintf(stderr, "ERROR COMPUTING SCRYPT HASH: return value is %d", retval);
        exit(retval);
    }


    // converts output from little-endian to big-endian
    swap_bytes(output, OUTPUT_SIZE);

    // writes output data
    printf("Writing computed scrypt hash to output...\n");
    FILE *outputFile = fopen(outputFilename, "wb");
    if (outputFile == NULL)
    {
        fprintf(stderr, "ERROR: could not open output file '%s' for writing.\n", outputFilename);
        exit(2);
    }
    int fwriteRet = fwrite(output, sizeof(uint8_t), OUTPUT_SIZE, outputFile);
    fclose(outputFile);
    if (fwriteRet < OUTPUT_SIZE)
    {
        fprintf(stderr, "ERROR: could only write %d bytes to output file '%s' - should have written %d bytes.\n", fwriteRet, outputFilename, OUTPUT_SIZE);
        exit(4);
    }

    printf("DONE!\n");
    return 0;
}

