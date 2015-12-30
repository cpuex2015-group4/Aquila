/* fib.c
   IS.S Imai Yuki
   Tue Dec 22 18:36:12 2015 */
#include<stdlib.h>
#include<stdio.h>

int main(int argc,char *argv[])
{
  int i;
  int now=0;
  int next=1;
  int n;
  sscanf(argv[1],"%d",&n);
  for(i=n;i>0;i--){
    int buf=now;
     now=next;
     next=buf+now;
  }
  printf("%d\n",now);
  return 0;
}
