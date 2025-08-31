clear;clc;
%subjects = {'sub-01';'sub-02';'sub-03';'sub-04';'sub-05';'sub-06';'sub-07';'sub-08';'sub-09';'sub-10';'sub-11';'sub-12';'sub-14';'sub-15';'sub-16';'sub-17';'sub-18';'sub-19';'sub-20';'sub-22';'sub-23';'sub-24';'sub-25';'sub-26';'sub-27'};
subjects = {'sub-01';'sub-02';'sub-03';'sub-04';'sub-05';'sub-06';'sub-07';'sub-08';'sub-09';'sub-10';'sub-11';'sub-12';'sub-14';'sub-15';'sub-16';'sub-17';'sub-18';'sub-19';'sub-20';'sub-22';'sub-23';'sub-24';'sub-25';'sub-26';'sub-27'};

masks = {'Reslice_Hippocampus_L.nii';'Reslice_IFG_L.nii'};

study_path='/home/luo/flxx_memory/dimension4/pattern'; 
roi_path='/home/luo/flxx_memory/mask';

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
    
    data_HSC_msk1=fullfile(sub_path,'glm_T_rz.nii');
    ds_HSC_msk1=cosmo_fmri_dataset(data_HSC_msk1,'mask',mask1_fn);
   % ds_HSC_msk1=cosmo_remove_useless_data(ds_HSC_msk1);
    cosmo_check_dataset(ds_HSC_msk1)
  %
    dsm_HSC_msk1=cosmo_pdist(ds_HSC_msk1.samples, 'correlation');
    dsm_HSC_msk1=1-dsm_HSC_msk1;
    dsm_HSC_msk1=atanh(dsm_HSC_msk1);
    %% mask2,hsc
    data_HSC_msk2=fullfile(sub_path,'glm_T_rz.nii');
    ds_HSC_msk2=cosmo_fmri_dataset(data_HSC_msk2,'mask',mask2_fn);
  %  ds_HSC_msk2=cosmo_remove_useless_data(ds_HSC_msk2);
    cosmo_check_dataset(ds_HSC_msk2)
  % 
    dsm_HSC_msk2=cosmo_pdist(ds_HSC_msk2.samples, 'correlation');
    
     dsm_HSC_msk2=1-dsm_HSC_msk2;
    dsm_HSC_msk2=atanh(dsm_HSC_msk2);
    %% hsc��r
    r_hsc = cosmo_corr(dsm_HSC_msk1(:), dsm_HSC_msk2(:), 'Pearson');
    counter_hsc=counter_hsc+1;
    my_rem(counter_hsc,:)=r_hsc;
    %% msk1,lsc
    data_LSC_msk1=fullfile(sub_path,'glm_T_fw.nii');
    ds_LSC_msk1=cosmo_fmri_dataset(data_LSC_msk1,'mask',mask1_fn);
   % ds_LSC_msk1=cosmo_remove_useless_data(ds_LSC_msk1);
    cosmo_check_dataset(ds_LSC_msk1)
 %
    dsm_LSC_msk1=cosmo_pdist(ds_LSC_msk1.samples, 'correlation');
    
    dsm_LSC_msk1=1-dsm_LSC_msk1;
    dsm_LSC_msk1=atanh(dsm_LSC_msk1);
    %% msk2,lsc
    data_LSC_msk2=fullfile(sub_path,'glm_T_fw.nii');
    ds_LSC_msk2=cosmo_fmri_dataset(data_LSC_msk2,'mask',mask2_fn);
  %  ds_LSC_msk2=cosmo_remove_useless_data(ds_LSC_msk2);
    cosmo_check_dataset(ds_LSC_msk2)
 
    dsm_LSC_msk2=cosmo_pdist(ds_LSC_msk2.samples, 'correlation');
    
    dsm_LSC_msk2=1-dsm_LSC_msk2;
    dsm_LSC_msk2=atanh(dsm_LSC_msk2);
    %%
    r_lsc = cosmo_corr(dsm_LSC_msk1(:), dsm_LSC_msk2(:), 'Pearson');
    counter_lsc=counter_lsc+1;
    my_for(counter_lsc,:)=r_lsc;
end

[h,p,ci,stats]=ttest(my_rem,my_for)
mean(my_rem)> mean(my_for)
%atanh



