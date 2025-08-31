%%  parahippocampal_gyrus_R
clear;
clc;
subjects = {'sub-02';'sub-03';'sub-04';'sub-05';'sub-06';'sub-07';'sub-08';'sub-09';'sub-10';'sub-11';'sub-12';'sub-13';'sub-14';'sub-15';'sub-17';'sub-18';'sub-19';'sub-20';'sub-21';'sub-25';'sub-28';'sub-29';'sub-30'};
%%
masks = {'Hippocampus_L.nii'};          
%%
study_path='H:\GJXX_1_reanalysis\jiaocha_vs_nojiaocha\gps\pattern';

roi_path='H:\GJXX_1_reanalysis\jiaocha_vs_nojiaocha\rca';

n_subjects=numel(subjects);
n_masks=numel(masks);
msk = masks{1};
%%
data_dir = 'H:\GJXX_1_reanalysis\jiaocha_vs_nojiaocha\glm_item_hl';
%%
counter=0;
%%
for s = 1:length(subjects)
    sub = subjects{s};
    sub_path=fullfile(study_path,sub);
    mask_fn=fullfile(roi_path,msk);
    sub_dir =fullfile(data_dir,sub);
    
    %% �õ�HSC��LSC������
   pattern1=filenames(fullfile(sub_dir,'HSC_C*nii'));
   pattern2=filenames(fullfile(sub_dir,'LSC_C*nii'));
   
   H=length(pattern1);
   L=length(pattern2);
    %%
    data=fullfile(sub_path,'glm_T_gps.nii');  
    ds=cosmo_fmri_dataset(data,'mask',mask_fn);
 
     dsm=cosmo_pdist(ds.samples, 'correlation');
   
    RDM=cosmo_squareform(dsm);
    RDM=1-RDM; 
    RDM=atanh(RDM);
    counter=counter+1;
    
    %% �ֱ����HSC���LSC���ƽ��Rֵ
    RDM(RDM==inf)=0; % �Լ����Լ���أ���??1������fisher Zת���󣬱��inf,ͳһ���??0�������뿼��
    ALL=mean(RDM,2);
    
    HSCR=mean(ALL(1:H,1));
    
    LSCR=mean(ALL(H+1:H+L,1));
    
    HSC_gps(counter,1)=HSCR;
    LSC_gps(counter,1)=LSCR;
end
%% t����
[h,p,ci,stats]= ttest(HSC_gps,LSC_gps)
mean(HSC_gps) 
mean(LSC_gps)
