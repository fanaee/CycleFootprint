function [cycles,selected_win_size,result]=find_cycles(x,sname,state_min_members,minRepeat,min_win_size,max_win_size,numprint)

%{
for test only
 clear;
 load realdata/TestV2All 
 s=14;
 sname=sensors{s};
 x=X(:,s);
 state_min_members=5;
 minRepeat=100;
 min_win_size=4;
 max_win_size=20;
 numprint=9999;
%}

cycles=[];
selected_win_size=[];
result=[];

% Discretization
Lx=numel(x);
[y,d,P,rngs]=timeseries2state(x,state_min_members,numprint);
[s,s2i,L]=remove_state_repeats(y);
if isempty(s)
    return
end
% Initialization
p=0;
for win_size=min_win_size:max_win_size
    M {win_size}= containers.Map('KeyType','char','ValueType','double');
    cnt(win_size)=0;
    mxL(win_size)=0;
    k(win_size)=0;
end


% process each sliding window with varying length
for t=1:L-max_win_size+1
    p=p+1; if p>numprint disp(['Processing Window #',num2str(t),'/',num2str(L-win_size+1)]); p=0; end
    for win_size=min_win_size:max_win_size
        w=s(t:t+win_size-1);
        UL=length(unique(w));
        % if we find a window with greater unique charechters ...
        if UL>mxL(win_size)
            mxL(win_size)=UL;
            cnt(win_size)=0;
            k(win_size)=0;
            clear mem;
            clear M{win_size}
            M {win_size}= containers.Map('KeyType','char','ValueType','double');
        end
        if UL==mxL(win_size)
            k(win_size)=k(win_size)+1;
            mem{win_size}{k(win_size)}=sprintf('%03d',w);
            M{win_size}(mem{win_size}{k(win_size)})=t;
            u2t{win_size}(k(win_size))=t;
            cnt(win_size)=cnt(win_size)+1;
        end
    end
end

% Count unique charechters in keys for different window sizes (very fast)
p=0;
clear Keycnt KeyU U2t;
for win_size=min_win_size:max_win_size
    keySet=keys(M{win_size});
    n(win_size)=0;
    for j=1:length(keySet)
        Keycnt(win_size,j)=0;
    end
    if win_size<=length(mem)
    for t=1:length(mem{win_size})
        p=p+1; if p>numprint disp(['win_size=',num2str(win_size),' t=',num2str(t)]); p=0; end
        for j=1:length(keySet)
            if strcmp(keySet{j},mem{win_size}{t})
                n(win_size)=n(win_size)+1;
                Keycnt(win_size,n(win_size))=Keycnt(win_size,j)+1;
                % example: keySet=2 3 2 1 4 5 1 2 2 --> KeyU=[1 2 3 4 5]
                KeyU{win_size}{n(win_size)}=strjoin(unique(cellstr(reshape(keySet{j},3,[])')),'');
                uk2u{win_size}(n(win_size))=t;
            end
        end
    end
    end
end

% Obtain cycles of most frequent unique charechter set
for win_size=min_win_size:max_win_size
    if win_size<=length(KeyU)
    UKeyU=unique(KeyU{win_size});  % example, KeyU= [12345], [678910], [12345] , UKeyU=[12345], [678910]
    if isempty(UKeyU)
        continue;
    end
    for i=1:length(KeyU{win_size})
        for j=1:length(UKeyU)
            if strcmp(UKeyU{j},KeyU{win_size}{i})
                KeyU2{win_size}{i,1}=KeyU{win_size}{i}; %[12345] -->1, [678910] -->2
                KeyU2{win_size}{i,2}=j;
            end
        end
    end
    cntkeys=cell2mat(KeyU2{win_size}(:,2));
    cnt=unique2(cntkeys);  % sorted count unique of indices: e.g. 2->2407 , 3: 76,  6: 45, ...
    idx=find(cntkeys==cnt(1,1)); % index of most frequent charechter set: e.g. idx=8
    result{win_size,1}=KeyU{win_size}(idx(1)); % {'013014015016'}
    result{win_size,2}=cnt(1,2); %2407
    result{win_size,3}=mxL(win_size); % unique charecheters -> win_size=5 --> 5 or lower
    s1=u2t{win_size}(uk2u{win_size}(idx)); % index of time instant in original series
    s2=s1+win_size-1;
    result{win_size,4}=[s2i(s1); s2i(s2)]'; % cycles
    end
end    


% remove those cycles that are shorter or longer than a thereshold
mincnt=0;
for win_size=min_win_size:max_win_size
    if win_size<=length(result)
        % result{win_size,5}: new cycles after removal
        % r= ratio of number of found cycles to valid cycles
        [result{win_size,5},r]=useful_cycles(result{win_size,4},120,8000); 
        result{win_size,6}=r; 
        if ~isempty(r)
            rs(win_size)=r;
        end    
    end
end

% choose the cycle that have the highest r: valid/all
[~,selected_win_size]=max(rs);
cycles=result{selected_win_size,5};





%}