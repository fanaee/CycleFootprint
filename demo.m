% 
% Hadi Fanaee-T, Mohamed-Rafik Bouguelia, Mahmoud Rahat, Jonathan Blixt and Harpal Singh,CycleFootprint: A Fully Automated Method for Extracting Operation Cycles from Historical Raw Data of Multiple Sensors, IoTStream workshop @ECMLPKDD 2020.
%

clear;
load data/Test2
% you need to have X
% rows : sensor readings, columns: different sensors (tempreture, pressure, ...) 
%ss=[1 6 7 8 14];
ss=1:17
for s=1:numel(ss)
    sno=ss(s);
    x=X(:,sno);
    state_min_members=5;
    minRepeat=100;
    min_win_size=4;
    max_win_size=20;
    numprint=9999;
    sname=sensors{sno};
    [cycles,selected_win_size,result]=find_cycles(x,sname,state_min_members,minRepeat,min_win_size,max_win_size,numprint)
    save(['results/',num2str(sno),'.mat']);
    results{sno}=result;
end

clear mxcnts;
for s=1:numel(ss)
    sno=ss(s);
    load(['results/',num2str(sno),'.mat']);
    if ~isempty(result)
        allresult{s}=result;
        for i=1:length(result)
            if length(result{i,5})<minRepeat
                result{i,7}=[];
            else
                result{i,7}=result{i,6};
            end
        end
        mxcnts(s,1:2)=nan;
        [tmp1,tmp2]=max(cell2mat(result(:,7)));
        if ~isempty(tmp1) && ~isempty(tmp2)
            mxcnts(s,1)=tmp1;
            mxcnts(s,2)=tmp2;
            mxcnts(s,2)=mxcnts(s,2)+min_win_size-1;
        end
    end
end

[~,refsensorid]=max(mxcnts(:,1))
ref_sensor=ss(refsensorid)
ref_win_size=mxcnts(refsensorid,2)
ref_cycles=allresult{refsensorid}{ref_win_size,5};
x=X(:,ref_sensor);

[prj,rec,ovlp]=eval_seg2(segsn,ref_cycles);

% plot normal cycles
tot=size(ref_cycles,1);
for i=1:size(ref_cycles,1)
    disp(['plot #',num2str(i),'/',num2str(tot)]);
    try
    h=figure('visible','off');
    plot(x(ref_cycles(i,1):ref_cycles(i,2)));
    if ~isnan(prj(i,2))
        title([datetimes{ref_cycles(i,1)},' - ',datetimes{ref_cycles(i,2)},' > Cycle#',num2str(prj(i,2)),' Overlap=',num2str(prj(i,3))]);
    else
        title([datetimes{ref_cycles(i,1)},' - ',datetimes{ref_cycles(i,2)}]);
    end
    pdir=['plots/cycles'];
    if ~exist(pdir, 'dir')
       mkdir(pdir);
    end
    saveas(h,[pdir,'/',num2str(i),'.png']);
    catch
    end
end  

fileID = fopen('output/Test2_cycles.csv','w');
for i=1:size(ref_cycles,1)
    fprintf(fileID,'%s , %s\r\n',datetimes(ref_cycles(i,1)),datetimes(ref_cycles(i,2)));
end 
fclose(fileID);

fileID = fopen('output/GT-match.csv','w');
for i=1:size(prj,1)
    if isnan(prj(i,2))
        a2='nan';
        b2='nan';
    else
       a2=datetimes(segsn(prj(i,2),1));
       b2=datetimes(segsn(prj(i,2),2));
    end
    fprintf(fileID,'%s , %s , %s , %s\r\n',datetimes(ref_cycles(prj(i,1)),1),datetimes(ref_cycles(prj(i,1),2)),a2,b2);
end 
fclose(fileID);

x=X(:,14);
xs=[];
for i=1:size(ref_cycles,1)
    sl=x(ref_cycles(i,1):ref_cycles(i,2));
    xs=[xs sl'];
end 

%{
[A,H,C,P,fit,AddiOutput]=parafac2(X,3);
DataSet_batches = DDOutlier.dataSet(C,'euclidean');
[~,max_nb_batches] = DDOutlier.NaNSearching(DataSet_batches);
[lofs_batches] = DDOutlier.LOFs(DataSet_batches,max_nb_batches);
[lofs_batches_sorted(:,1),lofs_batches_sorted(:,2)]=sort(lofs_batches,'desc');
%}

% paper figures

xs=[]

sl=x(ref_cycles(1,1):ref_cycles(1,2));
xs=[xs sl'];
sl=x(ref_cycles(2,1):ref_cycles(2,2));
xs=[xs sl'];
sl=x(ref_cycles(1,1):ref_cycles(1,2));
xs=[xs sl'];
sl=x(ref_cycles(33,1):ref_cycles(33,2));
sl = sl(1:500);
xs=[xs sl'];
sl=x(ref_cycles(1,1):ref_cycles(1,2));
xs=[xs sl'];
sl=x(ref_cycles(2,1):ref_cycles(2,2));
xs=[xs sl'];
sl=x(ref_cycles(1,1):ref_cycles(1,2));
xs=[xs sl'];
sl=repmat(0,500,1);
xs=[xs sl'];
sl=x(ref_cycles(1,1):ref_cycles(1,2));
xs=[xs sl'];
sl=x(ref_cycles(2,1):ref_cycles(2,2));
xs=[xs sl'];
sl=repmat(100,500,1);
xs=[xs sl'];
sl=x(ref_cycles(1,1):ref_cycles(1,2));
xs=[xs sl'];
sl=x(ref_cycles(2,1):ref_cycles(2,2));
xs=[xs sl'];
sl=x(ref_cycles(1,1):ref_cycles(1,2));
xs=[xs sl'];
sl=x(ref_cycles(2,1):ref_cycles(2,2));
xs=[xs sl'];
xs=[xs sl'];
h1=figure;plot(xs)
set(gca,'xtick',[])
set(gca,'ytick',[])

% paper figure 3


a = 10;
b = 15;
r1 = (b-a).*rand(15,1) + a;

a = 25;
b = 35;
r2 = (b-a).*rand(20,1) + a;

a = 50;
b = 60;
r3 = (b-a).*rand(10,1) + a;

a = 90;
b = 100;
r4 = (b-a).*rand(5,1) + a;

xr=[r1' r2' r3' r4']

h2=figure;plot(xr)

% FIGURE BOX PLOT
k=0; clear recov;
for i=1:size(prj,1)
    if ~isnan(prj(i,3))
        k=k+1;
        s1=ref_cycles(prj(i,1),1:2);
        s2=segsn(prj(i,2),1:2);
        recov(k)=length(intersect(s1(1):s1(2),s2(1):s2(2)))/length(s2(1):s2(2));
    end
end    


h2=figure;
i=67;
s1=ref_cycles(prj(i,1),1:2);
s2=segsn(prj(i,2),1:2);
subplot(2,1,1)
plot(x(s1(1):s1(2)));
title('Detected via CycleFootprint');
subplot(2,1,2)
plot(x(s2(1):s2(2)));
title('Ground Truth');


% Footprint figures

x=X(:,14);
state_min_members=5;
minRepeat=100;
min_win_size=6;
max_win_size=6;
numprint=9999;
[y,d,P,rngs]=timeseries2state(x,state_min_members,numprint);
[s,s2i,L]=remove_state_repeats(y);

p=0;
for win_size=min_win_size:max_win_size
    M {win_size}= containers.Map('KeyType','char','ValueType','double');
    cnt(win_size)=0;
    mxL(win_size)=0;
    k(win_size)=0;
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
xp=result{win_size,4}

h3=figure;
for i=1:20
    subplot (5,4,i)
    L=length(xp(i+40,1):xp(i+40,2))
    plot(x(xp(i+40,1):xp(i+40,2)))
    title(['Footprint #',num2str(i),'(L=',num2str(L),')']);
end    

xp(:,3)=xp(:,2)-xp(:,1)