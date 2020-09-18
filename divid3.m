function [ids,cnt]=divid3(x,sc,numprint)

mn=min(x);
mx=max(x);

if mx~=mn
    
    p=0;
    cnt=repmat(0,sc,1); [0 0 0];
    L=length(x);
    for i=1:L
        if ~isnan(x(i))
            p=p+1;
            if p>numprint disp([num2str(i),'/',num2str(L)]); p=0; end
            n=floor((sc-1)*((x(i)-mn)/(mx-mn)))+1;
            cnt(n)=cnt(n)+1;
            ids{n}(cnt(n))=i;
        end
    end

else
    ids{1}=find(~isnan(x));ids{2}=[];ids{3}=[];
    cnt=[length(ids{1}) 0 0];
end
