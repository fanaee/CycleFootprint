function [s,s2i,t]=remove_state_repeats(y)

s=[];
s2i=[];
t=[];
t=0;
Ly=numel(y);
for i=1:Ly-1
    if y(i)~=0
        if y(i)~=y(i+1) && y(i+1)~=0
            t=t+1;
            s(t)=y(i);
            s2i(t)=i;
        end
    end
end   
