function [cycles,r]=useful_cycles(xp,minL,maxL)

cycles=[];
if isempty(xp)
    cycles=xp;
    r=[];
    return;
end    
dif_xp=diff(xp(:,1));
k=0;
for i=1:size(xp,1)-1
    dif=xp(i+1,2)-xp(i,2);
    if dif>=minL && dif<=maxL
        k=k+1;
        cycles(k,1)=xp(i,2);
        cycles(k,2)=xp(i+1,2);
        cycles(k,3)=dif;
    end    
end    
r=size(cycles,1)/size(xp,1);