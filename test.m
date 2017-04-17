clc;
load .\dataset\V23\V.mat;
load .\dataset\V23\V_seg.mat;
volume_index =23;%ͼ������Ŀ
num=[122,291,164];
for kk=1:3
    slice_index =num(kk);
    %% Our_SVM
    %{
    addpath(genpath('./Our'));
    load ('./Our/OurModelSVM.mat');
    preds = segment_svm(V(:,:,slice_index), V_seg(:,:,slice_index), model_svm, D, params, scaleparams);%�ָ�ͼ��
    figure; visualize_segment(V(:,:,slice_index), preds==1);%���ӻ�
    %}
    %% Our_RF
    %{
    addpath(genpath('./Our'));
    load ('./Our/OurModelRF.mat');
    preds = segment_rf(V(:,:,slice_index), V_seg(:,:,slice_index), model, D, params, scaleparams);%�ָ�ͼ��
    figure; visualize_segment(V(:,:,slice_index), preds==1);%���ӻ�
    %}
    %% Kiros
    %{
    addpath(genpath('./Kiros'));
    load ('./Kiros/KirosModel.mat');
    preds = segment(V(:,:,slice_index), V_seg(:,:,slice_index), model, D, params, scaleparams);%�ָ�ͼ��
    preds(preds>0.5)=1;   preds(preds<0.5)=0;
    figure; visualize_segment(V(:,:,slice_index), preds==1);%���ӻ�
    %}
    %% Threshold
    %{
    level=0.15;%�趨��ֵ
    [preds,Img]=Threshold(V,V_seg,slice_index,level);
    figure;imshow(Img);%���ӻ�
    %}
    %% Hessian
    %{
    addpath('.\Hessian_FrangiFilter');
    level=0.15;%�趨��ֵ
    [preds,Img]=myHessian(V,V_seg,slice_index,level);
    figure;imshow(Img);%���ӻ�
    %}
    %% RegionGrowing
    %{
    
    %{
    %��������ִֻ��һ�μ���
    addpath('.\RegionGrowing');
    V1=bsxfun(@times,V,V_seg./255);
    preds0=regiongrowing(V1,28, [161,259,230]);%��������
    %}
    
    [preds,Img] = myRegionGrowing(V,preds0,slice_index);
    figure;imshow(Img);%���ӻ�
    %}
    %% ָ�����
    a=load(['./dataset/Annotations/' num2str(volume_index) '_' num2str(slice_index-1) '.txt']);
    a(:,1)=a(:,1)+1;
    a(:,2)=a(:,2)+1;
    a(:,3)=[];
    TP(kk)=0;%TP
    FN(kk)=0;%FN
    FP(kk)=0;%FP
    TN(kk)=0;%TN
    n(kk)=size(a,1);%����ǵ����ص���Ŀ
    for i=1:n(kk)
        temp1=a(i,1);% x������
        temp2=a(i,2);% y������
        temp3=a(i,3);% ���ص�ʵ������
        temp4=preds(temp2,temp1);% ���ص�Ԥ������
        %TP
        if temp3==1 && temp4==1
            TP(kk)=TP(kk)+1;% ����
        end
        %FN
        if temp3==1 && temp4==0
            FN(kk)=FN(kk)+1;% ����
        end
        %FP
        if temp3==0 && temp4==1
            FP(kk)=FP(kk)+1;% ����
        end
        %TN
        if temp3==0 && temp4==0
            TN(kk)=TN(kk)+1;% ����
        end
    end
    Acc(kk)=(TP(kk)+TN(kk))/(TP(kk)+FN(kk)+TN(kk)+FP(kk));
    TPR(kk)=TP(kk)/(TP(kk)+FN(kk));
    FPR(kk)=FP(kk)/(FP(kk)+TN(kk));
    Precision(kk)=TP(kk)/(TP(kk)+FP(kk));
    Fscore(kk)=(2*Precision(kk)*TPR(kk))/(Precision(kk)+TPR(kk));
end

TP0=sum(TP);%TP��
FN0=sum(FN);%FN��
FP0=sum(FP);%FP��
TN0=sum(TN);%TN��
Acc0=(TP0+TN0)/(TP0+FN0+TN0+FP0);%Acc��
TPR0=TP0/(TP0+FN0);%TPR��
FPR0=FP0/(FP0+TN0);%FPR��
Precision0=TP0/(TP0+FP0);%Precision��
Fscore0=(2*Precision0*TPR0)/(Precision0+TPR0);%Fscore��
disp(['����׼ȷ�ʣ�' num2str(Acc)])
disp(['����TPR��' num2str(TPR)])
disp(['����FPR��' num2str(FPR)])
disp(['����Fscore��' num2str(Fscore)])
disp(['��׼ȷ�ʣ�' num2str(Acc0)])
disp(['��TPR��' num2str(TPR0)])
disp(['��FPR��' num2str(FPR0)])
disp(['��Fscore��' num2str(Fscore0)])
