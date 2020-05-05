#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "random.h"
#include "dut.h"
#include "api.h"
#include "crypto_aead.h"

const size_t chunk_size = 32; //256 bit
const size_t number_measurements = 1e6; // per test

const size_t nonce_size = 16; //128 bit
const size_t msg_size = 64;
const size_t ad_size = 16; //32 bit
const size_t c_len = 64 + 8; // msg_size + 8
uint8_t *nonce;
uint8_t *msg;
uint8_t *ad;
uint8_t *cipher;
unsigned long long int *cipher_size;
const uint8_t nsec = 0;

uint8_t do_one_computation(uint8_t *data) {
  //uint8_t secret[16] = {0x2b,0x7e,0x15,0x16,0x28,0xae,0xd2,0xa6,0xab,0xf7,0x15,0x88,0x09,0xcf,0x4f,0x3c};
  //uint8_t secret[16] = {0};
  return (uint8_t)crypto_aead_encrypt(cipher, cipher_size, msg, msg_size, ad, ad_size, &nsec, nonce, data);
}

void init_dut(void) {
  nonce = calloc(nonce_size, sizeof(uint8_t));
  msg = calloc(msg_size, sizeof(uint8_t));
  ad = calloc(ad_size, sizeof(uint8_t));
  cipher = calloc(c_len, sizeof(uint8_t));
  cipher_size = calloc(1, sizeof(unsigned long long int));
  randombytes(nonce, nonce_size * sizeof(uint8_t));
  randombytes(msg, msg_size * sizeof(uint8_t));
  randombytes(ad, ad_size * sizeof(uint8_t));
}

/*
 * This is a simple example on how good test vectors
 * accelerate leakage detection. The code below defines
 * two input classes:
 *  a) random input
 *  b) input fixed to 0
 *
 * This helps to detect timing leakage in do_one_computation()
 * above. The process is faster if the input is equal to the
 * `secret` variable inside do_one_computation(). In that case,
 * the timing difference is be much larger and hence more
 * easily detectable. Otherwise, the timing difference is still
 * detectable but more measurements are needed. (Try changing
 * the value of `secret` variable.)
 *
 * Morale: carefully crafted input vectors detect much faster
 * leakage (``whitebox'' testing).
 * 
 */
void prepare_inputs(uint8_t *input_data, uint8_t *classes) {
  randombytes(input_data, number_measurements * chunk_size);
  for (size_t i = 0; i < number_measurements; i++) {
    classes[i] = randombit();
    if (classes[i] == 0) {
      memset(input_data + (size_t)i * chunk_size, 0x00, chunk_size);
    } else {
      // leave random
    }
  }
}
