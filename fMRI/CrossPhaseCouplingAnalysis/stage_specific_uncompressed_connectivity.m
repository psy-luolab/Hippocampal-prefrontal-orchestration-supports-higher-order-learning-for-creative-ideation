% Uncompressed hippocampus-IFG connectivity during the learning and creating phases
% Hippocampus-IFG representational connectivity analysis during both phase

clear;clc;
subjects = {'sub-01';'sub-02';'sub-03';'sub-04';'sub-05';'sub-07';'sub-08';'sub-09';'sub-10';'sub-11';'sub-12';'sub-13';'sub-14';'sub-15';'sub-16';'sub-17';'sub-18';'sub-20';'sub-21';'sub-22';'sub-23';'sub-24';'sub-25';'sub-26';'sub-27';'sub-28';'sub-29';'sub-30';'sub-31';'sub-32';'sub-33';'sub-34';'sub-36';'sub-37';'sub-38';'sub-39';'sub-40'};

masks = {'Hippocampus_L.nii';'MFG_L.nii'}; % right HIP left IFG ¡Ì   HSC-con > LSC-con

%parahippocampal_gyrus_L

study_path='H:\GJXX_2_reanalysis\C\First_level\S2\rsa'; % WHERE IS YOUR PATTERNS

roi_path='E:\gjxx2\FLXX_2\RSA\masks'; 

n_subjects=numel(subjects);
n_masks=numel(masks);

msk1 = masks{1};
msk2 = masks{2};

counter_hsc=0;
counter_lsc=0;

for s = 1:length(subjects)
    sub = subjects{s};
    sub_path=fullfile(study_path,sub);
    mask1_fn=fullfile(roi_path,msk1);
    mask2_fn=fullfile(roi_path,msk2);
    %% mask1,HSC
    data_HSC_msk1=fullfile(sub_path,'glm_HSC_NA.nii');     %%%%%%%
    ds_HSC_msk1=cosmo_fmri_dataset(data_HSC_msk1,'mask',mask1_fn);
  
    cosmo_check_dataset(ds_HSC_msk1)
 
    dsm_HSC_msk1=cosmo_pdist(ds_HSC_msk1.samples, 'correlation');
     dsm_HSC_msk1=1-dsm_HSC_msk1; 
     dsm_HSC_msk1=atanh(dsm_HSC_msk1);
    %% mask2,hsc
    data_HSC_msk2=fullfile(sub_path,'glm_HSC_NA.nii');     %%%%%%
    ds_HSC_msk2=cosmo_fmri_dataset(data_HSC_msk2,'mask',mask2_fn);
   
    cosmo_check_dataset(ds_HSC_msk2)

    dsm_HSC_msk2=cosmo_pdist(ds_HSC_msk2.samples, 'correlation');
     dsm_HSC_msk2=1-dsm_HSC_msk2; 
     dsm_HSC_msk2=atanh(dsm_HSC_msk2);
    %% hscµÄr
    r_hsc = cosmo_corr(dsm_HSC_msk1(:), dsm_HSC_msk2(:), 'Pearson');
    counter_hsc=counter_hsc+1;
    my_r_hsc(counter_hsc,:)=r_hsc;
    %% msk1,lsc
    data_LSC_msk1=fullfile(sub_path,'glm_LSC_NA.nii');    %%%%%%
    ds_LSC_msk1=cosmo_fmri_dataset(data_LSC_msk1,'mask',mask1_fn);
  
    cosmo_check_dataset(ds_LSC_msk1)

    dsm_LSC_msk1=cosmo_pdist(ds_LSC_msk1.samples, 'correlation');
      dsm_LSC_msk1=1-dsm_LSC_msk1; 
     dsm_LSC_msk1=atanh(dsm_LSC_msk1);
    %% msk2,lsc
    data_LSC_msk2=fullfile(sub_path,'glm_LSC_NA.nii');   %%%%%
    ds_LSC_msk2=cosmo_fmri_dataset(data_LSC_msk2,'mask',mask2_fn);
   
    cosmo_check_dataset(ds_LSC_msk2)
    dsm_LSC_msk2=cosmo_pdist(ds_LSC_msk2.samples, 'correlation');
         dsm_LSC_msk2=1-dsm_LSC_msk2; 
     dsm_LSC_msk2=atanh(dsm_LSC_msk2);
    %%
    r_lsc = cosmo_corr(dsm_LSC_msk1(:), dsm_LSC_msk2(:), 'Pearson');
    counter_lsc=counter_lsc+1;
    my_r_lsc(counter_lsc,:)=r_lsc;
end

[h,p,ci,stats]=ttest(my_r_hsc,my_r_lsc)
mean(my_r_hsc)
mean(my_r_lsc)
%atanh
