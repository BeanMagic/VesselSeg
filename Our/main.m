%% =============================ѵ���׶�===================================
% ���ò���
set_params;
params.scansdir = '../dataset/Scans';%����·��
params.masksdir = '../dataset/Lungmasks';%����·��
params.annotsdir ='../dataset/Annotations';%����·��

% ��ȡͼ�񣬱�ǩֵ����˹������
disp('���ڶ�ȡ���ݣ�ʵ�ָ�˹������...')
ntv = 2; %��ȡ����ͼ������ѵ��
V = cell(ntv, 1);
A = cell(ntv, 1);%��ǩ�洢
Vlist = cell(ntv, 1);
Vs = [];
for i = 1:ntv
    I = load_vessel12(params, 20+i);
    A{i} = load(sprintf('%s/VESSEL12_%d_Annotations.csv', params.annotsdir, 20+i));
    V{i} = pyramid(I, params);
    Vlist{i} = imagelist(A{i}, params.numscales);
    Vs = [Vs; V{i}];
    clear I;
end

% ��ȡС��
disp('������ȡͼ��С��...');
patches = extract_patches(Vs, params);

%����ϡ���Ա����������ֵ�
disp('��������ϡ���Ա�����ѵ���ֵ�...')
D.mean = mean(patches);
D.codes=train(patches,params);

% �������
disp('����ͼ����...')
L = cell(ntv, 1);
for i = 1:ntv
    L{i} = extract_features(V{i}(Vlist{i}), D, params);%ֻ��ȡ����ǲ��ͼ������
end

% �ϲ���
disp('�����ϲ���...')
for i = 1:ntv
    L{i} = upsample(L{i}, params.numscales, params.upsample);
end

% ��ȡ��ǵ�Ͷ�Ӧ��ǩֵ
disp('������ȡ����������ǩ...')
X = []; labels = [];
for i = 1:ntv
    [tr, tl] = convert(L{i}, A{i}, Vlist{i}(params.numscales:params.numscales:end)/params.numscales);
    X = [X; tr];
    labels = [labels; tl];
end

%% ���ɭ��ѵ��
[X_scale,scaleparams]=standard_my(X);%��һ������
model_rf = classRF_train(X_scale,labels,500,160);
% %�ָ����
% slice_index =164;%ͼ��������ֱ����� 121+1��290+1��163+1 
% disp('���ڷָ����ͼ��...')
% preds = segment_rf(V(:,:,slice_index), V_seg(:,:,slice_index), model, D, params, scaleparams);
% disp('���ڿ��ӻ�����ͼ��...')
% visualize_segment(V(:,:,slice_index), preds==1);


%% ֧������������
disp('����ѵ��֧������������...')
[X_scale,scaleparams]=standard_my(X);%��һ������
% [bestacc,bestc,bestg]=SVMcgForClass(labels,X_scale);%����Ѱ��
% [bestacc,bestc,bestg]=SVMcgForClass(labels,X_scale,-8,1,-8,0,5,0.1,0.1);%����Ѱ��
% [bestCVaccuarcy,bestc,bestg] = psoSVMcgForClass(labels,X_scale)%����ȺѰ��
% [bestCVaccuarcy,bestc,bestg] = gaSVMcgForClass(labels,X_scale)%�Ŵ��㷨Ѱ��
model_svm = svmtrain(labels,X_scale,'-c 1  -g 0.003  -v 10 -q');%ʮ�۽�����֤
model_svm = svmtrain(labels,X_scale,'-c 1 -g 0.003 -b 1  -q');%������Ѳ���ֵ���������ģ��

%% ===========================����ͼ����ʵ��=================================
%��ȡͼ��
volume_index =23;%ͼ������Ŀ
disp('���ڶ�ȡ����ͼ��...')
[V, V_seg] = load_vessel12(params, volume_index);
%����������
% V=double(imnoise(uint8(V),'salt & pepper',0.02));%�ӽ�������
% V=double(imnoise(uint8(V),'gaussian'));%�Ӹ�˹����
% V=double(imnoise(uint8(V1),'poisson'));%�Ӳ�������
% V=double(imnoise(uint8(V1),'speckle'));%�ӳ�������
% ��ʾ��Ⱦ��ͼ����Ҫ������������С�V��Ϊ��V1��or��V2��
% subplot(1,2,1),imshow(uint8(V(:,:,200))),title('ԭͼ��')
% subplot(1,2,2),imshow(uint8(V1(:,:,200))),title('������������Ⱦ��ͼ��')
% subplot(1,3,3),imshow(uint8(V2(:,:,200))),title('����˹������Ⱦ��ͼ��')
%�ָ�ͼ��
slice_index =164;%ͼ��������ֱ����� 121+1��290+1��163+1 
disp('���ڷָ����ͼ��...')
preds = segment_svm(V(:,:,slice_index), V_seg(:,:,slice_index), model_svm, D, params, scaleparams);
disp('���ڿ��ӻ�����ͼ��...')
visualize_segment(V(:,:,slice_index), preds==1);

%% =============================׼ȷ��ͳ��===================================
% load dec_values.mat;
% dec=reshape(dec_values(:,2),512,512);
% a=load(['E:/Strange/SRTP.10/codes/dataset/Annotations/' num2str(volume_index) '_' num2str(slice_index-1) '.txt']);
% a(:,1)=a(:,1)+1;
% a(:,2)=a(:,2)+1;
% a(:,3)=[];
% count=0;
% n=size(a,1);
% % labels0=[];
% % dec_values0=[];
% for i=1:n
%     temp1=a(i,1);
%     temp2=a(i,2);
%     temp3=a(i,3);
%     temp4=preds(temp2,temp1);
% %     labels0=[labels0;temp4];
% %     temp5=dec(temp2,temp1);
% %     dec_values0=[dec_values0;temp5];
%     if temp3==temp4
%         count=count+1;
%     end
% end
% acc = count / n  %׼ȷ��

%ROC����
% dec_values0;
% labels0;
% [XX,YY,THRE,AUC] = perfcurve(labels0,dec_values0,'1');
% AUC   %��AUC
% % YY1=smooth(YY,30);%�⻬����
% figure;
% plot(XX,YY,'*');%���ROC����




