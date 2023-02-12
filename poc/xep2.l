%{
#include <stdio.h>
%}

%% 
int printf("INTEGER\n");
[0-9]+ printf("number\n");
"-"?[0-9]+("."[0-9]+)? printf("new\n");
%%