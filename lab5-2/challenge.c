#include<stdio.h>
#include<string.h>
#include<stdint.h>
#include<unistd.h>
#include<fcntl.h>

char input_buffer[100];
char name_buffer[100];
int phase_box[16]={14, 6, 8, 10, 3, 2, 13, 5, 11, 4, 9, 12, 7, 0, 1, 15};

int char2num(int c){
    if('0' <= c && c <= '9'){
        return c - '0';
    }else if('a' <= c && c <= 'f'){
        return c - 'a' + 10;
    }else{
        return -1;
    }
}

uint32_t binary_hash_key(void){
    char exe_path[512];
    ssize_t n = readlink("/proc/self/exe", exe_path, sizeof(exe_path) - 1);
    if(n <= 0){
        printf("Bomb! failed to read self executable path.\n");
        _exit(-1);
    }
    exe_path[n] = '\0';

    int fd = open(exe_path, O_RDONLY);
    if(fd < 0){
        printf("Bomb! failed to open self executable.\n");
        _exit(-1);
    }

    uint32_t h = 2166136261u;
    unsigned char buf[4096];
    for(;;){
        ssize_t r = read(fd, buf, sizeof(buf));
        if(r == 0){
            break;
        }
        if(r < 0){
            close(fd);
            printf("Bomb! failed to read self executable.\n");
            _exit(-1);
        }
        for(ssize_t i = 0; i < r; i++){
            h ^= (uint32_t)buf[i];
            h *= 16777619u;
        }
    }
    close(fd);
    return h;
}

int phase_1(const char* str){
    
    int data = char2num(name_buffer[6]);
    int iter = 20;
    while(iter--){
        data = (phase_box[data]^phase_box[(data+3)&0xf]^phase_box[phase_box[data]])&0xf;
    }
    int ret = 1;
    while(*str){
        if(char2num(*str) == data){
            ret = 0;
            break;
        }
        str++;
    }
    return ret;
}

int phase_2(const char* str){
    int sum = char2num(name_buffer[6])^char2num(name_buffer[7])^char2num(name_buffer[8])^char2num(name_buffer[9]);
    int ret = 1;
    asm volatile(
        "mv t0, %[sum]\n"
        "mv t1, %[str]\n"
        "j phase_2_L1\n"
        "phase_2_L2:\n"
        "xor t0, t0, t2\n"
        "addi t1, t1, 1\n"
        "phase_2_L1:\n"
        "lbu t2, 0(t1)\n"
        "bne t2, zero, phase_2_L2\n"
        "bne t0, zero, phase_2_L3\n"
        "mv %[ret], zero\n"
        "phase_2_L3:\n"
        "nop\n"
        :[ret] "=r" (ret)
        :[sum] "r" (sum),[str] "r" (str)
        :"memory","t0","t1","t2"
    );
    return ret;
}

int phase_3(const char* str){
    if(strlen(str) != 8){
        return 1;
    }
    for(int i=0;i<8;i++){
        if(char2num(str[i]) < 0){
            return 1;
        }
    }

    int d0 = char2num(name_buffer[6]);
    int d1 = char2num(name_buffer[7]);
    int d2 = char2num(name_buffer[8]);
    int d3 = char2num(name_buffer[9]);
    uint32_t seed = ((uint32_t)d0<<12) | ((uint32_t)d1<<8) | ((uint32_t)d2<<4) | (uint32_t)d3;
    seed ^= 0x13579bdfu;
    uint32_t bin_key = binary_hash_key();
    seed ^= bin_key;
    seed ^= (bin_key << 11) | (bin_key >> 21);
    for(int i=0;i<16;i++){
        seed = (seed<<3) | (seed>>29);
        seed ^= 0x9e3779b9u + (uint32_t)i * 0x11111111u;
        seed ^= (uint32_t)phase_box[(seed>>((uint32_t)i&15u))&15u];
    }

    const uint8_t enc[8] = {0x5, 0xc, 0x9, 0x1, 0x6, 0xb, 0xe, 0x2};
    char expect[9];
    for(int i=0;i<8;i++){
        uint32_t x = seed ^ (0x45d9f3bu * (uint32_t)(i+1));
        asm volatile(
            "addi t3, zero, 13\n"
            "xor %[x], %[x], t3\n"
            "slli t0, %[x], 7\n"
            "srli t1, %[x], 3\n"
            "xor %[x], t0, t1\n"
            "andi %[x], %[x], 15\n"
            :[x] "+r" (x)
            :
            :"t0","t1","t3"
        );
        int nib = (enc[i] ^ (int)(x & 0xf) ^ phase_box[(seed>>((uint32_t)(i*4)&15u))&15u]) & 0xf;
        expect[i] = "0123456789abcdef"[nib];
        asm volatile(
            "slli t0, %[s], 5\n"
            "srli t1, %[s], 2\n"
            "xor %[s], t0, t1\n"
            "addi %[s], %[s], 61\n"
            :[s] "+r" (seed)
            :
            :"t0","t1"
        );
    }
    expect[8] = '\0';

    int ret = 1;
    asm volatile(
        "mv t0, %[in]\n"
        "mv t1, %[ex]\n"
        "addi t2, zero, 8\n"
        "1:\n"
        "lbu t3, 0(t0)\n"
        "lbu t4, 0(t1)\n"
        "bne t3, t4, 2f\n"
        "addi t0, t0, 1\n"
        "addi t1, t1, 1\n"
        "addi t2, t2, -1\n"
        "bne t2, zero, 1b\n"
        "lbu t3, 0(t0)\n"
        "bne t3, zero, 2f\n"
        "mv %[ret], zero\n"
        "j 3f\n"
        "2:\n"
        "addi %[ret], zero, 1\n"
        "3:\n"
        "nop\n"
        :[ret] "=r" (ret)
        :[in] "r" (str),[ex] "r" (expect)
        :"memory","t0","t1","t2","t3","t4"
    );
    return ret;
} 

int main(){
    printf("please input your student ID:");
    scanf("%s",name_buffer);
    if(strlen(name_buffer)!=10){
        printf("please input the true ID.\n");
        return -1;
    }
    for(int i=0;i<10;i++){
        if(name_buffer[i]<'0' || name_buffer[i]>'9'){
            printf("please input the true ID.\n");
            return -1;
        }
    }
    
	printf("Welcome to my fiendish little bomb. You have 3 phases with\n");

	scanf("%s",input_buffer);
	if (phase_1(input_buffer) == 0) {
		printf("Phase 1 defused. How about the next one?\n");
	} else {
		printf("Bomb! You fail to defuse the first bomb!\n");
		return -1;
	}

    scanf("%s",input_buffer);
	if (phase_2(input_buffer) == 0) {
		printf("Phase 2 defused. How about the next one?\n");
	} else {
		printf("Bomb! You fail to defuse the second bomb!\n");
		return -1;
	}

    scanf("%s",input_buffer);
	if (phase_3(input_buffer) == 0) {
		printf("Phase 3 defused.\n");
	} else {
		printf("Bomb! You fail to defuse the third bomb!\n");
		return -1;
    }
}