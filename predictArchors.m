function final_res = predictArchors(RawData,InformData)
[val,idx] = sort(pdist2(RawData,InformData));
final_res = zeros(1,size(InformData,1));

set = 1:size(InformData,1);
for i = 1:size(InformData,1)
    tmpIdx = idx(i,:);
    tmpDist = val(i,:);
    for j = set

        idx0 = intersect(find(tmpIdx==j),find(final_res==0));
        if length(idx0) == 1
            final_res(idx0) = j;
            set = setdiff(set,j);
        end
        if length(idx0) > 1
            [~,idxtmp] = sort(tmpDist(idx0));
            idx1 = idx0(idxtmp(1));
            final_res(idx1) = j;
            set = setdiff(set,j);
        end
    end
end
end