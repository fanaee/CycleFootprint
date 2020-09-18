function [s2m,w2s,UKey,UCnt,UKeyD] = unique_patterns(s,win_size,L,s2i,minRepeat,numprint)

w2s=[];
UCnt=[];
UKeyD=[];
UKey=[];
s2m=[];
p=0;
M = containers.Map('KeyType','char','ValueType','double');

for t=1:L-win_size+1
    w2s{t}=[t,t+win_size-1];
    mem{t}=sprintf('%03d',s(t:t+win_size-1));
    M(mem{t})=t;
    UK{t}=s(t:t+win_size-1);
    p=p+1; if p>numprint disp(['Processing Window #',num2str(t),'/',num2str(L-win_size+1)]); p=0; end
end
keySet=keys(M);
n_unique=length(keySet);

MC = containers.Map('KeyType','char','ValueType','double');
p=0;
for i=1:n_unique
    a=keySet(i);
    MC(a{1}) = i;
    cnt(i)=0;
    p=p+1; if p>numprint disp(['Indexing Key #',num2str(i),'/',num2str(n_unique)]); p=0; end
end


p=0;
for t=1:L-win_size+1
	hash_id=MC(mem{t});
    cnt(hash_id)=cnt(hash_id)+1;
    p=p+1; if p>numprint disp(['Counting Keys... #',num2str(t),'/',num2str(L-win_size+1)]); p=0; end
end


UKeyID = containers.Map;
k=0;
p=0;    
for i=1:n_unique
    if cnt(i)>=minRepeat
        k=k+1;
        UKey{k}=keySet(i);
        a=keySet(i);
        UKeyD(k,:)=UK{M(a{1})};
        UCnt(k)=cnt(i);
        UKeyID(UKey{k}{1})=k;
        p=p+1; if p>numprint disp(['Re-indexing Keys... #',num2str(i),'/',num2str(n_unique)]); p=0; end
    end
end    

p=0;    
for t=1:L-win_size+1
    if isKey(UKeyID,mem{t})
        s2m(t)=UKeyID(mem{t});
        p=p+1; if p>numprint disp(['Reverse Index for Window #',num2str(t),'/',num2str(L-win_size+1)]); p=0; end
    end
end



end