/*This program uses automatic variables*/
#include <stdio.h>

int checksum(char buffer[]){
    int i;
    int sum=0;
    for(i=0; buffer[i] != 0; sum+=buffer[i++]);
    return sum;
}

int main() {
    char buffer[4096];
    int i=0;
    printf("Enter text (ctrl-D to end): ");
    do
        buffer[i]=getchar();
    while((buffer[i] != -1)&&(++i<4095));
    buffer[i]=0;
    printf("%s\n",buffer);

    printf("\nThe checksum is %08X\n",checksum(buffer));
    printf("\nThe checksum is %08X\n",checksum(buffer));
    return 0;
}