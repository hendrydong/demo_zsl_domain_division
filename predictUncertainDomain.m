function res = predictUncertainDomain(x,protoself,domainMat)
dist = pdist2(x,protoself);
for i = 1:size(dist,1)
distDomain(i,:) = dist(i,domainMat(i,:));
end
[~,resIdx] = min(distDomain,[],2);
for i = 1:size(dist,1)
res(i) = domainMat(i,resIdx(i));
end
end