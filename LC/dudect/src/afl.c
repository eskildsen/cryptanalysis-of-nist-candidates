#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include "random.h"

#include "crypto_aead.h"
#include "api.h"

#define CRYPTO_MSGBYTES 32
#define CRYPTO_ADBYTES 4
#define DUDECT_MEASUREMENTS 1e6 // per test

//const size_t chunk_size = CRYPTO_KEYBYTES;
const size_t clen = CRYPTO_MSGBYTES + CRYPTO_ABYTES;

uint8_t *npub;
uint8_t *nsec;
uint8_t *msg;
uint8_t *ad;
uint8_t *cipher;
uint8_t *key;
unsigned long long int *cipher_size;

void generate_test_vectors() {
    npub = calloc(CRYPTO_NPUBBYTES, sizeof(uint8_t));
    msg = calloc(CRYPTO_MSGBYTES, sizeof(uint8_t));
    ad = calloc(CRYPTO_ADBYTES, sizeof(uint8_t));
    key = calloc(CRYPTO_KEYBYTES, sizeof(uint8_t));
    
    cipher = calloc(clen, sizeof(uint8_t));
    cipher_size = calloc(1, sizeof(unsigned long long int));

    if (CRYPTO_NSECBYTES > 0) {
        nsec = calloc(CRYPTO_NSECBYTES, sizeof(uint8_t));
        randombytes(nsec, CRYPTO_NSECBYTES * sizeof(uint8_t));
    } else {
        //TODO
    }

    //Fill randombytes
    randombytes(npub, CRYPTO_NPUBBYTES * sizeof(uint8_t));
    randombytes(msg, CRYPTO_MSGBYTES * sizeof(uint8_t));
    randombytes(ad, CRYPTO_ADBYTES * sizeof(uint8_t));
    //randombytes(key, CRYPTO_KEYBYTES * sizeof(uint8_t));
}

int main() {
    generate_test_vectors();

    ssize_t num_read = read(STDIN_FILENO, key, CRYPTO_KEYBYTES);
    if(num_read != CRYPTO_KEYBYTES)
        return 1;

    int res = crypto_aead_encrypt(cipher, cipher_size, msg, CRYPTO_MSGBYTES, ad, CRYPTO_ADBYTES, nsec, npub, key);
    return res;
}
