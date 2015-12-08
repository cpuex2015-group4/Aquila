#include <stdio.h>
#include <stdint.h>
#include <math.h>

// A = 1 X X X X X X X X X | X X X X X X X X X X X X X X
//    [      A0(key)      ] [        A1(variable)       ]
// FINVMAN(A) = (2*x0 - A0*x0^2/2^(23+k)) - A1*x0^2/2^46
//             [        constant         ]    [ liner  ]
//
// output file : finv_table.coe
// format :
// MEMORY_INITIALIZATION_RADIX=2;
// MEMORY_INITIALIZATION_VECTOR=
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX,
// ...
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX;

// to <= from(up downto down);
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
	printf("%s =",name);
	j = down;

	for(i = 0; down < up+1; down++){
		if(up == 31 && j == 0){
			if(i == 0 || i == 1 || i == 9) printf(" ");
			i++;
		}
		printf("%d", (int)((f & ((uint32_t)1 << (up-down))) >> (up-down)));
	}
	puts("");
}	 

int main(int argc, char *argv[]){
	union hoge input;
	union hoge a0;
	union hoge a1;
	union hoge x1; // to derive initial number
	union hoge x2; // to derive initial number
	union hoge constant;
	union hoge gradient;
	union hoge one;

	uint32_t mant;
	uint32_t mantc;
	uint32_t mantg;
	uint32_t manto;
	union hoge out;
	union hoge ans;

	input.i  = 0x3fc147ae; // input 
	one.f    = 1.0;
	ans.f    = 1.0 / input.f;

	a0.i = one.i + (fromdownto(input.i, 22, 13) << 13);
	a1.i = one.i + fromdownto(input.i, 22,  0);

	x1.f = one.f / a0.f;
	x2.i = a0.i + ((uint32_t)1 << 13);
	x2.f = one.f / x2.f;

	constant.f = pow((sqrt(x1.f) + sqrt(x2.f)),2) / 2;
	gradient.f = x1.f * x2.f;

	mant  = fromdownto(a1.i      ,22,0) + ((uint32_t)1 << 23);
	mantc = fromdownto(constant.i,22,0) + ((uint32_t)1 << 23);
	if(fromdownto(gradient.i,30,23) == 126){
		mantg = (fromdownto(gradient.i,22,0) + ((uint32_t)1 << 23)) / 2;
	}else{
		mantg = (fromdownto(gradient.i,22,0) + ((uint32_t)1 << 23)) / 4;
	}
	manto = ((uint64_t)mantg * (uint64_t)mant) / 8388608;
	manto = mantc - manto;

	out.i = (fromdownto(input.i,31,31) << 31) + ((uint32_t)(253 - fromdownto(input.i,30,23)) << 23) + (fromdownto(manto,21,0) << 1);

	printbit("output",out.i,31,0);
	printbit("answer",ans.i,31,0);

	return 0;
}
