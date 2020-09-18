function cnt= unique2(in )

un = unique(in);
un(isnan(un(1:end-1))) = [];
for i = 1:length(un)
    cnt(i,2)=length(find(in == un(i)));
    cnt(i,1)=un(i);
end

cnt=sortrows(cnt,2,'descend');