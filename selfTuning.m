function [result,protoself] = selfTuning(x,pred,iter,numOfClusters,predictFunction)
for k = 1:iter
    for i = 1:numOfClusters
        protoself(i,:) = mean(x(pred==i,:));
    end
    idx = predictFunction(protoself);
    [~,pred] = min(pdist2(x,protoself),[],2);

end

result = idx(pred);