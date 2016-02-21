/* sqrt.c
   IS.S Imai Yuki
   Sun Feb 21 16:37:34 2016 */
#include<stdlib.h>
#include<stdio.h>

float mysqrt(float f){
  float d=f/2;
  float g=f;
  while(d>0){
    if (g*g>f){
      g-=d;
    }else{
      g+=d;
    }
    d/=2;
  }

  return g;
}

int main(int argc,char *argv[])
{
  float f;
  while(1){
    scanf("%f",&f);
    printf("%f\n",mysqrt(f));
  }
  return 0;
}
