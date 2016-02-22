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
	union hoge output;
	union hoge answer;
	int        sign;
	uint32_t   sint;
	uint32_t   expo;
	uint32_t   mant, mano;
	int        i;
	int        flag2;
	int        zflag = 0;
	int        err = 0;

	input.i = 0;
	zflag = 0;
	answer.f = (float)(int)input.i;

	sign = fromdownto(input.i, 31, 31);

	if(sign == 1){
		sint = reverse(fromdownto(input.i, 30, 0));
	}else{
		sint = fromdownto(input.i, 30, 0);
	}
	//		printbit(" int  ",input.i,31,0);
	//		printbit("sint  ",sint,31,0);

	for(i = 0; i < 30; i++){
		if(fromdownto(sint, 30-i, 30-i) == 1){
			break;
		}
	}

	if(i < 4){
		if(fromdownto(sint, 4-i, 0) != 0){
			mant = (fromdownto(sint, 29-i, 5-i) << 1) + 1;
		}else{
			mant = fromdownto(sint, 29-i, 4-i);
		}
	}else if(i == 30){
		mant = 0;
		zflag = 1;
	}else{
		mant = fromdownto(sint, 29-i, 0) << (i-4);
	}
	//		printbit("mant  ",mant,31,0);

	if(fromdownto(mant,2,2) == 0 || fromdownto(mant,3,0) == 4){
		mano = fromdownto(mant,25,3);
	}else{
		if(fromdownto(mant,25,3) == 0x7fffff){
			flag2 = 1;
			mano = 0;
		}else{
			flag2 = 0;
			mano = fromdownto(mant,25,3)+1;
		}
	}
	//		printbit("mano  ",mano,31,0);

	if(flag2 == 1){
		expo = 158-i;
	}else{
		expo = 157-i;
	}

	if(zflag == 0){
		output.i = (sign << 31) + (expo << 23) + mano;
	}else{
		output.i = 0;
	}

	//		printf("input  = %d\noutput = %lf\n",input.i, output.f);
	printbit("output",input.i,31,0); printf(" ");
	printbit("output",output.i,31,0); // printf(",");
	/*		printbit("answer",answer.i,31,0); */ puts("");
	if(output.i != answer.i){
		err += 1;
		break;
	}
	//	printf("err = %d\n",err);
	return 0;
}
