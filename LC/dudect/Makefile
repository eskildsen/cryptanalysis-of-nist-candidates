all: dut_aes32 dut_aesbitsliced dut_cmpmemcmp dut_cmpct dut_donna dut_donnabad

OBJS = src/cpucycles.o src/fixture.o src/random.o \
src/ttest.o src/percentile.o
OBJS_AES32 = dut/aes32/rijndael-alg-fst.o
OBJS_DONNA = dut/donna/curve25519-donna.o
OBJS_DONNABAD = dut/donnabad/curve25519-donnabad.o
OBJS_AESBITSLICED = dut/aesbitsliced/afternm_aes128ctr.o \
dut/aesbitsliced/beforenm_aes128ctr.o \
dut/aesbitsliced/common_aes128ctr.o \
dut/aesbitsliced/consts_aes128ctr.o \
dut/aesbitsliced/int128_aes128ctr.o \
dut/aesbitsliced/stream_aes128ctr.o \
dut/aesbitsliced/xor_afternm_aes128ctr.o
OBJS_TINYJAMBU = dut/TinyJAMBU/encrypt.o
OBJS_DRYGASCON = dut/drygascon256test/encrypt.o
# CC=clang
OPTIMIZATION=-O2
#CFLAGS	= -Weverything -O0 -fsanitize=memory -fno-omit-frame-pointer -g -std=c11
CFLAGS	= $(OPTIMIZATION) -std=c11
LIBS	= -lm
#LDFLAGS	= -fsanitize=memory -fno-omit-frame-pointer -g 
#LDFLAGS = -Weverything $(OPTIMIZATION) -std=c11
LDFLAGS = $(OPTIMIZATION) -std=c11
INCS	= -Iinc/
SECONDS?=120
REFONLY=1
BATCH_SIZE=4

dut_aes32: $(OBJS) $(OBJS_AES32) dut/aes32/dut_aes32.c
	$(CC) $(LDFLAGS) $(INCS) -o dudect_aes32_$(OPTIMIZATION) dut/aes32/$@.c $(OBJS) $(OBJS_AES32) $(LIBS)

dut_aesbitsliced: $(OBJS) $(OBJS_AESBITSLICED) dut/aesbitsliced/dut_aesbitsliced.c
	$(CC) $(LDFLAGS) $(INCS) -o dudect_aesbitsliced_$(OPTIMIZATION) dut/aesbitsliced/$@.c $(OBJS) $(OBJS_AESBITSLICED) $(LIBS)

dut_cmpmemcmp: $(OBJS) dut/cmpmemcmp/dut_cmpmemcmp.c
	$(CC) $(LDFLAGS) $(INCS) -o dudect_cmpmemcmp_$(OPTIMIZATION) dut/cmpmemcmp/$@.c $(OBJS) $(LIBS)

dut_cmpct: $(OBJS) dut/cmpct/dut_cmpct.c
	$(CC) $(LDFLAGS) $(INCS) -o dudect_cmpct_$(OPTIMIZATION) dut/cmpct/$@.c $(OBJS) $(LIBS)

dut_donna: $(OBJS) $(OBJS_DONNA) dut/donna/dut_donna.c
	$(CC) $(LDFLAGS) $(INCS) -o dudect_donna_$(OPTIMIZATION) dut/donna/$@.c $(OBJS) $(OBJS_DONNA) $(LIBS)

dut_donnabad: $(OBJS) $(OBJS_DONNABAD) dut/donnabad/dut_donnabad.c
	$(CC) $(LDFLAGS) $(INCS) -o dudect_donnabad_$(OPTIMIZATION) dut/donnabad/$@.c $(OBJS) $(OBJS_DONNABAD) $(LIBS)

dut_drygascon256: $(OBJS) $(OBJS_DRYGASCON) dut/drygascon256test/dut_drygascon256.c
	$(CC) $(LDFLAGS) $(INCS) -Idut/drygascon256test/ -o dudect_test_$(OPTIMIZATION) dut/drygascon256test/$@.c $(OBJS) $(OBJS_DRYGASCON) $(LIBS)

libctgrind.so:
	gcc -o libctgrind.so -shared src/ctgrind.c -Wall -std=c99 -fPIC -Wl,-soname,libctgrind.so.1

libctgrind.so.1: libctgrind.so
	ln -s libctgrind.so libctgrind.so.1

compile_dudect: $(OBJS)
	./scripts/compile_base.sh dudect
	./scripts/compile_dudect.sh

compile_ctgrind: $(OBJS) libctgrind.so libctgrind.so.1
	./scripts/compile_base.sh ctgrind
	./scripts/compile_ctgrind.sh

dudect:
	./scripts/run.sh $(SECONDS) $(REFONLY) $(BATCH_SIZE) dudect

ctgrind:
	./scripts/run.sh $(SECONDS) $(REFONLY) $(BATCH_SIZE) ctgrind

get_candidates:
	./scripts/get_candidates.sh

.c.o:
	$(CC) $(CFLAGS) $(INCS) -c $< -o $@

clean:
	rm -f $(OBJS) $(OBJS_AES32) $(OBJS_AESBITSLICED) $(OBJS_DONNA) $(OBJS_DONNABAD) dudect_* *.exe a.out
	rm -f -r compiled
	rm -f -r out
