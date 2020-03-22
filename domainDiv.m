function predEdit = domainDiv(pred,prob,true,predTest,probTest,opts)
if nargin<6
    pValue = 0.05^2;
pValue2 = 0.05;
maxThreshold = 1;
else
    pValue = opts.pValue;
    pValue2 = opts.pValue2;
    if isfield(opts,'maxThreshold')
        maxThreshold = opts.maxThreshold;
    else
        maxThreshold = 1;
    end
end


B = 1000;
uniqueTest =  unique(predTest);
uniqueTrue = unique(true);
for i = 1:length(uniqueTrue)
    sizeBootstrap(i) = max(1,sum(predTest==uniqueTrue(i)));
end

refuseThreshold = zeros(length(uniqueTrue),1);
predTrue = pred(pred==true);
trueTrue = true(pred==true);
probTrue = prob(pred==true);

for i = 1:length(uniqueTrue)
    idx = find( predTrue == uniqueTrue(i));
    minSet = ones(B,1);
    for j = 1:B
        bootIdx = idx(randi(length(idx),sizeBootstrap(i),1));
        minSet(j) = min(probTrue(bootIdx));
    end
    sortMinSet = sort(minSet);
    refuseThreshold(i) = sortMinSet(ceil(pValue*B));
end
refuseThreshold(refuseThreshold>maxThreshold)=maxThreshold;


predEdit = zeros(length(predTest),1);

for i = 1:length(uniqueTest)
    threshold = refuseThreshold(uniqueTrue==uniqueTest(i));
    idxI0 = find(predTest == uniqueTest(i));
    res = probTest(idxI0);
    [minI,idxI] = min(res);
    while minI<threshold
        res(idxI) = 1;
        predEdit(idxI0(idxI)) = -1;
        [minI,idxI] = min(res);
    end
end
predEdit(predEdit==0)=predTest(predEdit==0);
censored = 1;
if censored

uniPredEdit = unique(predEdit);
uniPredEdit(uniPredEdit==-1)=[];
for i = 1:length(uniPredEdit)
    sampleTest = probTest(predEdit==uniPredEdit(i));
    sampleTrue = probTrue(predTrue==uniPredEdit(i));
    idx = randi([1 length(sampleTest)],[1 min(length(sampleTest),10)]);
    if ~isempty(sampleTrue)
    rej = kstest2(sampleTest(idx),sampleTrue,'Alpha',pValue2);
    else
        rej=0;
    end
    if rej
        predEdit(predEdit==uniPredEdit(i))=-2;
    end
    %[f,x]=ecdf(sampleTest);
    %[f0,x0]=ecdf(sampleTrue);
end
else
    
uniPredTest = unique(predTest);

for i = 1:length(uniPredTest)
    sampleTest = probTest(predTest==uniPredTest(i));
    sampleTrue = probTrue(predTrue==uniPredTest(i));
    
    rej = kstest2(sampleTest,sampleTrue,'Alpha',pValue2);
    
    if rej
        predEdit(predEdit==uniPredTest(i))=-2;
    end
    %[f,x]=ecdf(sampleTest);
    %[f0,x0]=ecdf(sampleTrue);
end

end
fprintf('Percentage of Rej. by thereshold  = %d\n',sum(predEdit==-1)/length(predEdit));
fprintf('Percentage of Rej. by K-S test  = %d\n',sum(predEdit==-2)/length(predEdit));
fprintf('Total Rej.  = %d\n',(sum(predEdit==-2)+sum(predEdit==-1))/length(predEdit));


