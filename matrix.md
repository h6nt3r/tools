```
while :;do echo $LINES $COLUMNS $((RANDOM%COLUMNS)) "$(printf "\U$((RANDOM%500+1000))")";sleep 0.05;done|gawk '{a[$3]=0;for(x in a){o=a[x];a[x]=a[x]+1;c=int(rand()*5);if(c==0)col="\033[1;32m";else if(c==1)col="\033[0;32m";else if(c==2)col="\033[1;36m";else if(c==3)col="\033[1;31m";else col="\033[1;37m";printf "\033[%s;%sH%s%s",o,x,col,$4;printf "\033[%s;%sH\033[0m",a[x],x;if(a[x]>=$1)a[x]=0;}}'
```
