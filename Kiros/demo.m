%% =============================ѵ���׶�===================================
% ���ò���
set_params;
params.upsample = [512 512];
params.scansdir = '..\dataset\Scans';
params.masksdir = '..\dataset\Lungmasks';
params.annotsdir ='..\dataset\Annotations';

%����ѧϰ 
[D, X, labels] = run_vessel12(params);%�Ѹ���Ϊ����21��22����ͼ��

%logistic������ѵ��
n_folds = 10;
[model, scaleparams] = learn_classifier(X, labels, n_folds);

%% =============================����ͼ��ָ�===================================
volume_index = 23;%����Ŀ
[V, V_seg] = load_vessel12(params, volume_index);
slice_index =164;%����Ŀ���ֱ����� 121+1��290+1��163+1 
preds = segment(V(:,:,slice_index), V_seg(:,:,slice_index), model, D, params, scaleparams);
preds(preds>0.5)=1;
preds(preds<0.5)=0;
visualize_segment(V(:,:,slice_index), preds>0.5);%������ӻ�