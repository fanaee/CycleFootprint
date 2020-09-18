function [y,d,P,rngs]=timeseries2state(x,state_min_members,numprint)

d=0;
y=zeros(size(x));
ContinueLoop=1;
while ContinueLoop
    [ids,cnt]=divid3(x,3,numprint);
    [~,MinorIdx]=sort(cnt);
    NumZeroCnt=length(find(cnt==0));
    switch NumZeroCnt         
        case 2
            [cntOnlyGroup,OnlyGroup]=max(cnt);
            if cntOnlyGroup>state_min_members
                d=d+1;
                y(ids{OnlyGroup})=d;
                rngs(d,1)=d;
                rngs(d,2)=min(x(ids{OnlyGroup}));
                rngs(d,3)=max(x(ids{OnlyGroup}));
                rngs(d,4)=max(x(ids{OnlyGroup}))-min(x(ids{OnlyGroup}));
                rngs(d,5)=cnt(OnlyGroup);
            end
            x(ids{OnlyGroup})=NaN;
            ContinueLoop=0;
        case 3
            ContinueLoop=0;            
    end
    for i=1:2
        minor_mn{i}=min(x(ids{i}));minor_mx{i}=max(x(ids{i}));
        if isempty(minor_mn{i}) || isnan(minor_mn{i})  minor_mn{i}=0;  end
        if isempty(minor_mx{i}) || isnan(minor_mx{i})  minor_mx{i}=0;  end
        rng{i}=minor_mx{i}-minor_mn{i};
        if cnt(MinorIdx(i))>state_min_members % && rng{i}>0
            d=d+1;
            rngs(d,1)=d;
            rngs(d,2)=minor_mn{i};
            rngs(d,3)=minor_mx{i};
            rngs(d,4)=rng{i};
            rngs(d,5)=cnt(MinorIdx(i));
            y(ids{MinorIdx(i)})=d;
        end
        x(ids{MinorIdx(i)})=NaN;
	end
end

P=rngs(:,5)./sum(rngs(:,5));