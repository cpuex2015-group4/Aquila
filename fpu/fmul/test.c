#include <stdio.h>

int main(){
  union hoge {
		float f;
	  int i;
	};
  union hoge a;
	union hoge b;
	union hoge ans;
	int i;
	int ab[32],bb[32],ansb[32];

	a.f = 3.0;
	b.f = 5.0;
	ans.f = a.f * b.f;

  for(i = 0; i < 32; i++){
	  ab[i] = a.i % 2;
		a.i = a.i / 2;
	  bb[i] = b.i % 2;
		b.i = b.i / 2;
    ansb[i] = ans.i % 2;
		ans.i = ans.i / 2;
	}

	while(i > 0) printf("%1d", ab[--i]);
	putchar('\n');
	i = 32;
	while(i > 0) printf("%1d", bb[--i]);
	putchar('\n');
	i = 32;
  while(i > 0) printf("%1d", ansb[--i]);
	putchar('\n');

  return 0;
}
