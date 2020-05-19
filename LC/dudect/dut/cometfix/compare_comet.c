#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "random.h"
#include "api.h"
#include "crypto_aead.h"
#include "cpucycles.h"

const size_t chunk_size = 16; //128 bit
const size_t number_measurements = 5*1e6; // per test

const size_t nonce_size = 16; //128 bit
const size_t msg_size = 32;
const size_t ad_size = 16; //32 bit
const size_t c_len = 32 + 16; // msg_size + 8
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

uint8_t do_one_computation_old(uint8_t *data) {
  //uint8_t secret[16] = {0x2b,0x7e,0x15,0x16,0x28,0xae,0xd2,0xa6,0xab,0xf7,0x15,0x88,0x09,0xcf,0x4f,0x3c};
  //uint8_t secret[16] = {0};
  return (uint8_t)crypto_aead_encrypt_old(cipher, cipher_size, msg, msg_size, ad, ad_size, &nsec, nonce, data);
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

void prepare_inputs(uint8_t *input_data) {
  randombytes(input_data, number_measurements * chunk_size);
}

static void differentiate(int64_t *exec_times, int64_t *ticks) {
  for (size_t i = 0; i < number_measurements; i++) {
    exec_times[i] = ticks[i + 1] - ticks[i];
  }
}

static void measure(int64_t *ticks, int64_t *ticks_old, uint8_t *input_data) {
  for (size_t i = 0; i < number_measurements; i++) {
    ticks[i] = cpucycles();
    do_one_computation(input_data + i * chunk_size);
  }
  ticks[number_measurements] = cpucycles();

  for (size_t i = 0; i < number_measurements; i++) {
    ticks_old[i] = cpucycles();
    do_one_computation_old(input_data + i * chunk_size);
  }
  ticks_old[number_measurements] = cpucycles();
}

int64_t average(int64_t a[], int64_t n) {
  int64_t x = 0;
  int64_t y = 0;
  for (int64_t i = 0; i < n; i++) {
      x += a[i] / n;
      int64_t b = a[i] % n;
      if (y >= n - b) {
          x++;
          y -= n - b;
      } else {
          y += b;
      }
  }

  return (int64_t)x + (y / n);
}


static void doit(void) {
  // XXX move these callocs to parent
  int64_t *ticks = calloc(number_measurements + 1, sizeof(int64_t));
  int64_t *ticks_old = calloc(number_measurements + 1, sizeof(int64_t));
  int64_t *exec_times = calloc(number_measurements, sizeof(int64_t));
  int64_t *exec_times_old = calloc(number_measurements, sizeof(int64_t));
  uint8_t *input_data = calloc(number_measurements * chunk_size, sizeof(uint8_t));

  prepare_inputs(input_data);
  measure(ticks, ticks_old, input_data);
  differentiate(exec_times, ticks); // inplace
  differentiate(exec_times_old, ticks_old); // inplace
  
  int64_t exec_average = average(exec_times, number_measurements);
  int64_t exec_average_old = average(exec_times_old, number_measurements);

  printf("average new: %ld, average old: %ld \n", exec_average, exec_average_old);

  free(ticks);
  free(ticks_old);
  free(exec_times);
  free(exec_times_old);
  free(input_data);
}

int main(int argc, char **argv) {
  (void)argc;
  (void)argv;
  printf("Sample size %ld \n", number_measurements);

  printf("Generating test vectors \n");
  init_dut();

  for (;;) {
    doit();
  }
}
