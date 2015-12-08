#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
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
	for(; down < up+1; down++){
		printf("%d", (int)((f & ((uint32_t)1 << (up-down))) >> (up-down)));
	}
	printf(" ");
}	 

int main(int argc, char *argv[]){
	union hoge outer;
	union hoge inner;
	union hoge inputa;
	union hoge inputb;
	union hoge winner;
	union hoge loser;
	// 仮数部の計算
	uint32_t   manta;
	uint32_t   mantb;
	uint32_t   manto;
	uint32_t   expoa;
	uint32_t   expob;
	int        expo;
	uint32_t   sign;

	int i,j;

//	union hoge answer;
	union hoge out;


	for(outer.i = 8388608; outer.i < 2139095040; outer.i += 4278190){
		for(inner.i = outer.i; inner.i < 2139095040; inner.i += 4278190){
			for(j = 0; j < 4; j++){
				switch(j){
					case 0:
						inputa.i = outer.i;
						inputb.i = inner.i;
						break;
					case 1:
						inputa.i = inner.i;
						inputb.i = outer.i;
						break;
					case 2:
						inputa.i = outer.i + ((uint32_t)1 << 31);
						inputb.i = inner.i;
						break;
					case 3:
						inputa.i = outer.i;
						inputb.i = inner.i + ((uint32_t)1 << 31);
						break;
				}
//				answer.f = inputa.f + inputb.f;
				// cmpExp
				if(fromdownto(inputa.i,30,0) < fromdownto(inputb.i,30,0)){
					winner.i = inputb.i;
					loser.i  = inputa.i;
				}else{
					winner.i = inputa.i;
					loser.i  = inputb.i;
				}

				// shiftloser
				expoa = fromdownto(winner.i,30,23);
				expob = fromdownto(loser.i ,30,23);
				manta = (fromdownto(winner.i,22,0) + ((uint32_t)1 << 23)) << 3;
				mantb = (fromdownto(loser.i ,22,0) + ((uint32_t)1 << 23)) << 3;
				for(i = 0; i < expoa - expob; i++){
          mantb = (fromdownto(mantb,26,2) << 1) + (fromdownto(mantb,1,1) | fromdownto(mantb,0,0));
				}

				// mantadd *there is no underflow because manta grater than mantb
				if(fromdownto(winner.i,31,31) == fromdownto(loser.i,31,31)){
					manto = manta + mantb;
				}else{
					manto = manta - mantb;
				}
				expo = expoa;
				sign = fromdownto(winner.i,31,31);

				// moveup
				if(fromdownto(manto,27,27) != 0){ // when overflow
					manto = (fromdownto(manto,27,2) << 1) + (fromdownto(manto,1,1) | fromdownto(manto,0,0));
					expo  = expo + 1;
				}

				// shiftup
				for(i = 0; i < 27; i++){
					if(fromdownto(manto,26-i,26-i) == 1){
						if(i == 26){
							manto = 0;
						}else{
							manto = (fromdownto(manto,25-i,0) << i);
						}
						expo = expo - i;
						break;
					}
				}

				// round
				if(fromdownto(manto,2,2) == 0 || fromdownto(manto,3,0) == 4){
					manto = fromdownto(manto,25,3);
				}else{
					if(fromdownto(manto,25,3) == 8388607){
						manto = 0;
						expo = expo + 1;
					}else{
						manto = fromdownto(manto,25,3) + 1;
					}
				}

				// output
				if(fromdownto(winner.i,30,0) == fromdownto(loser.i,30,0) && fromdownto(winner.i,31,31) != fromdownto(loser.i,31,31)){ // 答えが0なら0を返す
					out.i = 0;
				}else if(expoa == 0 || expoa == 255 || expob == 0 || expob == 255){ // どちらかがzeroまたはinfならwinnerを返す
					out.i = winner.i;
				}else if(expo > 254){ // オーバーフロー
					out.i = (sign << 31) + ((uint32_t)255 << 23);
				}else if(expo < 1){ // アンダーフロー
					out.i = 0;
				}else{
					out.i = (sign << 31) + ((uint32_t)expo << 23) + manto;
				}

        printbit("inputa",inputa.i,31,0);
        printbit("inputb",inputb.i,31,0);
        printbit("output",out.i,31,0);
				puts("");
/*				if(abs(answer.i - out.i) > 0){
					printf("%8x %8x %8x %8x ",inputa.i,inputb.i,out.i,answer.i);
					printf("%7d ulp\n",abs(answer.i - out.i));
				}
 */		}
		}
	}
	return 0;
}
