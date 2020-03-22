clear
load('res101')
load('att_splits')
load('awa_tr_res_v2.mat')

load('awa_protoVis_v2')
features = features';
att = att';
if length(prob)==length(trainval_loc) train_loc=trainval_loc;end
x_tr = features(train_loc,:);
y_tr = labels(train_loc,:);
x_te_unseen = features(test_unseen_loc,:);
x_te_seen = features(test_seen_loc,:);
y_te_unseen = labels(test_unseen_loc);
y_te_seen = labels(test_seen_loc);
selfIter = 5;
seen = unique(y_tr);
unseen = unique(labels(test_unseen_loc));
mean_x = mean(x_tr);
std_x = std(x_tr);
standardize = @(x) (x-repmat(mean_x,...
[size(x,1),1]))./repmat(std_x,[size(x,1),1]);
x_te_unseen = standardize(x_te_unseen);

true = y_tr;
load('awa_te_seen_res_v2.mat')
predSeen = predTest;
probSeen = probTest;
opts.pValue = 0.01;
opts.pValue2 = 0.01;

predEditSeen = domainDiv(pred,prob,true,predTest,probTest,opts);
load('awa_te_unseen_res_v2.mat')
predEditUnseen = domainDiv(pred,prob,true,predTest,probTest,opts);
ResultUnseen = zeros(size(predEditUnseen));
predUnseen = predTest;
probUnseen = probTest;
load('w_std_awa_v2');

[~,RawIdx] = min(pdist2(x_te_unseen*w,att(unseen,:)),[],2);
[ResIdx1,protoself] = selfTuning(x_te_unseen(predEditUnseen<0,:),RawIdx(predEditUnseen<0,:),5,10,@(x) predictArchors(x*w,att(unseen,:)));
Res1 = unseen(ResIdx1);
ResultUnseen(predEditUnseen<0) = Res1;
ResultUnseen(predEditUnseen>0) = predEditUnseen(predEditUnseen>0);
domainMat = zeros(sum(predEditUnseen==-2),length(unseen)+1);
domainMat(:,1:end-1) = repmat(unseen(:)',[size(domainMat,1),1]);
domainMat(:,end) = predUnseen(predEditUnseen == -2);
proto = protoVis;
proto(unseen,:) = protoself;
Res2 = predictUncertainDomain(x_te_unseen(predEditUnseen==-2,:),proto,domainMat);
ResultUnseen(predEditUnseen==-2) = Res2;
for j = 1:length(unseen)
    i = unseen(j);
    acc(j) = sum(ResultUnseen(y_te_unseen==i)==y_te_unseen(y_te_unseen==i))/length(y_te_unseen(y_te_unseen==i));
end
u=max(sum(ResultUnseen == y_te_unseen)/length(y_te_unseen),mean(acc));
fprintf('Unseen acc = %f\n',u);

[~,RawIdxSeen] = min(pdist2(x_te_seen*w,att(unseen,:)),[],2);
[ResIdxSeen,protoselfSeen] = selfTuning(x_te_seen(predEditSeen<0,:),RawIdxSeen(predEditSeen<0,:),selfIter,10,@(x) predictArchors(x*w,att(unseen,:)));
protoSeen = protoVis;
protoSeen(unseen,:) = protoselfSeen;
domainMatSeen = zeros(sum(predEditSeen==-2),length(unseen)+1);
domainMatSeen(:,1:end-1) = repmat(unseen(:)',[size(domainMatSeen,1),1]);
domainMatSeen(:,end) = predSeen(predEditSeen == -2);
ResultSeen = predEditSeen;
if sum(predEditSeen==-2)>0
Res2Seen = predictUncertainDomain(x_te_seen(predEditSeen==-2,:),protoSeen,domainMatSeen);
ResultSeen(predEditSeen==-2) = Res2Seen;
end
uni_te_seen = unique(y_te_seen);
for j = 1:length(uni_te_seen)
    i = uni_te_seen(j);
    accSeen(j)= sum(y_te_seen(y_te_seen==i)==ResultSeen(y_te_seen==i))/length(y_te_seen(y_te_seen==i));
end
s = max(sum(ResultSeen == y_te_seen)/length(y_te_seen),mean(accSeen));
fprintf('Seen acc = %f\n',s);
fprintf('H = %f\n',2*u*s/(s+u));
u0 = sum(predEditUnseen<0)/length(y_te_unseen);
f1 = s*u0*2/(s+u0);
fprintf('Our F1 = %f\n',f1)
a = sum(probUnseen<0.1)/length(probUnseen);
predSeen2 = predSeen;
predSeen2(probSeen<0.1)=0;
b = sum(predSeen2==y_te_seen)/length(y_te_seen);
fprintf('WSVM F1 = %f\n',2*a*b/(a+b));




