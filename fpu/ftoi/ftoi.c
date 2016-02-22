#include <stdio.h>
#include <stdint.h>

union hoge{
	float    f;
	uint32_t i;
};

uint32_t fromdownto(uint32_t from, int up, int down){
	uint32_t to = 0;
	int i;

	for(i = up; i > down-1; i--){
		to = (to << 1) | ((from >> i) & (uint32_t)1);
	}

	return to;
}

// to(up downto down) <= from;
uint32_t todownto(uint32_t from, uint32_t to, int up, int down){
	uint32_t mask = 0; // 代入すべき箇所を0で初期化
	int i;
	for(i = 0; i < mask; i++){
		mask = mask | ((uint32_t)1 << i);
	}
	for(i = up+1; i < 64; i++){
		mask = mask | ((uint32_t)1 << i);
	}
	to = to & mask;
	for(i = down; i < up+1; i++){
		to = to | ((from & (uint32_t)1) << i);
		from = from >> 1;
	}
	return to;
}

void printbit(char *name, uint32_t f, int up, int down){
	int i,j;
	//	printf("%s =",name);
	j = down;

	for(i = 0; down < up+1; down++){
		if(up == 31 && j == 0){
			//			if(i == 0 || i == 1 || i == 9) printf(" ");
			i++;
		}
		printf("%d", (int)((f & ((uint32_t)1 << (up-down))) >> (up-down)));
	}
	//	puts("");
}

int bitwiseor(uint32_t i){
	if(i > 0){
		return 1;
	}else{
		return 0;
	}
}

uint32_t reverse(uint32_t in){
	int i;
	uint32_t out = 0;
	for(i = 0; i < 32; i++){
		if((in >> i) % 2 == 0){
			out += (1 << i);
		}
	}
	return out + 1;
}

int main(int argc, char *argv[]){
	union hoge input;
	int        sign;
	uint32_t   into;
	uint32_t   output;
	uint32_t   expo;
	uint32_t   mant;

	input.i = 0x3f000000;
	// 入力値

	sign = fromdownto(input.i, 31, 31);
	expo = fromdownto(input.i, 30, 23);
	mant = fromdownto(input.i, 22,  0);

	// todo:rv,ov into:34bit -> 32bit
	if(expo < 126){
		into = 0;
	}else if(expo == 126){
		into = 0;
	}else if(expo == 127){
		into = 1;
	}else if(expo > 157){
		into = 1 << 31; // overflow
	}else if(expo > 149){
		into = (1 << (expo - 127)) + (fromdownto(mant, 22, 0) << (expo - 150));
	}else if(expo == 149){
		into = (1 << (expo - 127)) + fromdownto(mant, 22, (150 - expo));
	}else{
		into = (1 << (expo - 127)) + fromdownto(mant, 22, (150 - expo));
	}

	if(into == 0x80000000){ // when overflow
		output = into;
	}else{
		if(sign == 1){ // 符号処理
			into = reverse(into);
		}
		if(into == 0){ // when 0
			output = into;
		}else{
			output = (sign << 31) + fromdownto(into,30,0);
		}
	}
	printf("input  : %lf\noutput : %d\n", input.f, output);
	return 0;
}

