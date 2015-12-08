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
	union hoge inputa;
	union hoge inputb;
	// 仮数部の計算
	uint32_t   manta;
	uint32_t   mantb;
	uint32_t   anshh;
	uint32_t   anshl;
	uint32_t   anslh;
	uint32_t   ans;
	uint32_t   manto;
	uint32_t   expoa;
	uint32_t   expob;
	int        expo;
	uint32_t   sign;

	union hoge answer;
	union hoge out;

  // 入力値をここにいれてね
	inputa.i = 8388608;
	inputb.i = 8388608; 

	answer.f = inputa.f * inputb.f;
  manta    = fromdownto(inputa.i,22,0) + ((uint32_t)1 << 23);
	expoa    = fromdownto(inputa.i,30,23);
	mantb    = fromdownto(inputb.i,22,0) + ((uint32_t)1 << 23);
	expob    = fromdownto(inputb.i,30,23);

	anshh    = fromdownto(manta,23,11) * fromdownto(mantb,23,11);
	anshl    = fromdownto(manta,23,11) * fromdownto(mantb,10, 0);
	anslh    = fromdownto(manta,10, 0) * fromdownto(mantb,23,11);

	ans      = anshh + fromdownto(anshl,23,11) + fromdownto(anslh,23,11) + 2;

	// 仮数部の判定,指数部の加算
	if(fromdownto(ans,25,25) == 1){
	  manto = fromdownto(ans,24,2);
		expo  = expoa + expob - 126;
	}else{
	  manto = fromdownto(ans,23,1);
		expo  = expoa + expob - 127;
	}

	sign = fromdownto(inputa.i,31,31) ^ fromdownto(inputb.i,31,31);

  // このへんはvhdl実装ではカバーしてないけどまぁレイトレでは関係ないらしいし
	if(expo < 1 || expoa == 0 || expob == 0){ // アンダーフロー
	  manto = 0;
		expo  = 0;
	}else if(expo > 254){ // オーバーフロー
	  manto = 0;
		expo  = 255;
	}

	out.i = (sign << 31) + (fromdownto((uint32_t)expo,7,0) << 23) + manto;

	printbit("inputa",inputa.i,31,0);
	printbit("inputb",inputb.i,31,0);
	printbit("output",out.i,31,0);
	printf("%d\n",out.i);
	//    printbit("answer",answer.i,31,0);
	//    printf("%20.14e,%20.14e\n",input.f, out.f - answer.f);

	return 0;
}
