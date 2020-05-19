#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "random.h"
#include "cpucycles.h"
#include <limits.h>

typedef unsigned char u8;
typedef unsigned int u32;
#define KSZ 16
#define HAVE_SIGN_EXTENDING_BITSHIFT 1
const size_t chunk_size = KSZ; //128 bit
const size_t number_measurements = 1e7; // per test

u8 *z;

/* Conditionally return a or b depending on whether bit is set */
/* Equivalent to: return bit ? a : b */
u8 select (u8 a, u8 b, u8 bit)
{
  u8 isnonzero = (bit | -bit) >> (sizeof(u8) * CHAR_BIT - 1);
  /* -0 = 0, -1 = 0xff....ff */
  #if HAVE_SIGN_EXTENDING_BITSHIFT
    u8 mask = isnonzero;
  #else
    u8 mask = -isnonzero;
  #endif
  u8 ret = mask & (b^a);
  ret = ret ^ b;
  return ret;
}

void permute(u8 *Z, const u8 *Z_){
	
	//(Z'1, Z'0) <-p- Z'
	u32 p = KSZ/2;
	
	//Z0 <- Z'0 MUL alpha
	Z[0] = Z_[0]<<1;
	for(u32 j=1; j<p; j++){
		Z[j] = Z_[j]<<1 | Z_[j-1]>>7;
	}
	
	Z[0] = select(Z[0] ^ 0x1B, Z[0], Z_[p-1] & 0x80);
	
	//Z <- (Z'1, _)
	memcpy(&Z[p], &Z_[p], p);
	
	return;
}

void permute_old(u8 *Z, const u8 *Z_){
	
	//(Z'1, Z'0) <-p- Z'
	u32 p = KSZ/2;
	
	//Z0 <- Z'0 MUL alpha
	Z[0] = Z_[0]<<1;
	for(u32 j=1; j<p; j++){
		Z[j] = Z_[j]<<1 | Z_[j-1]>>7;
	}
	
	if(Z_[p-1] & 0x80){		/*10000000*/
		Z[0] ^= 0x1B;	/*00011011*/
	}
	
	//Z <- (Z'1, _)
	memcpy(&Z[p], &Z_[p], p);
	
	return;
}

uint8_t do_one_computation(uint8_t *data) {
  permute(z, data);
  return 0;
}

uint8_t do_one_computation_old(uint8_t *data) {
  permute_old(z, data);
  return 0;
}

void init_dut(void) {
  z = calloc(KSZ, sizeof(u8));
  randombytes(z, KSZ * sizeof(u8));

  u8 *rand;
  u8 *rand2;
  u8 *z1;
  u8 *z_1;
  u8 *z2;
  u8 *z_2;
  rand = calloc(KSZ, sizeof(u8));
  rand2 = calloc(KSZ, sizeof(u8));
  z1 = calloc(KSZ, sizeof(u8));
  z_1 = calloc(KSZ, sizeof(u8));
  z2 = calloc(KSZ, sizeof(u8));
  z_2 = calloc(KSZ, sizeof(u8));
  for (int i=0; i < 1000000; i++) {
    randombytes(rand, KSZ * sizeof(u8));
    randombytes(rand2, KSZ * sizeof(u8));
    memcpy(z1, rand, KSZ);
    memcpy(z2, rand, KSZ);
    memcpy(z_1, rand2, KSZ);
    memcpy(z_2, rand2, KSZ);

    permute(z1, z_1);
    permute_old(z2, z_2);

    if (memcmp(z1,z2, KSZ) != 0) {
      printf("Output differs \n");
      int j;
      for (j = 0; j < KSZ; j++)
      {
          if (j > 0) printf(":");
          printf("%02X", z1[j]);
      }
      printf("\n");
      for (j = 0; j < KSZ; j++)
      {
          if (j > 0) printf(":");
          printf("%02X", z2[j]);
      }
      printf("\n");
      exit(2);
    }
    if (memcmp(z_1,z_2, KSZ) != 0) {
      printf("Input differs after execution \n");
      exit(2);
    }
  }

  printf("Implementation looks identical \n");

  free(rand);
  free(rand2);
  free(z1);
  free(z_1);
  free(z2);
  free(z_2);
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
    ticks_old[i] = cpucycles();
    do_one_computation_old(input_data + i * chunk_size);
  }
  ticks_old[number_measurements] = cpucycles();

  for (size_t i = 0; i < number_measurements; i++) {
    ticks[i] = cpucycles();
    do_one_computation(input_data + i * chunk_size);
  }
  ticks[number_measurements] = cpucycles();
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
