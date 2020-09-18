function [prj,rec,ovlp]=eval_seg2(segsn,ref_cycles)

rec=nan;
ovlp=nan;
clear mch
for i=1:size(ref_cycles,1)
    disp(['i=',num2str(i)]);
    for j=1:size(segsn,1)
        mch(i,j)=length(intersect (ref_cycles(i,1):ref_cycles(i,2),segsn(j,1):segsn(j,2)));
    end
end

ovlp=0;
prj=[];
k=0;
for i=1:size(ref_cycles,1)
    idx=find(mch(i,:));
    prj(i,1)=i;
    prj(i,2)=nan;
    prj(i,3)=nan;
    if ~isempty(idx)
        if length(idx)==1
            prj(i,2)=idx;
            prj(i,3)=mch(i,idx);
        else
            [~,n]=max(mch(i,idx));
            prj(i,2)=idx(n);
            prj(i,3)=mch(i,idx(n));
            ovlp=ovlp+length(idx)-1;
        end
    end
end
if ~isempty(prj)
    
    rec=length(unique(prj(:,2)))/size(segsn,1);
    
end
