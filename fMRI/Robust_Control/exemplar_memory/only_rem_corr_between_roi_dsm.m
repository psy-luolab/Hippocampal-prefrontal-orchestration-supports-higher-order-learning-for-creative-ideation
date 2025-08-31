

clear;clc;
subjects = {'sub02';'sub03';'sub04';'sub05';'sub06';'sub07';'sub08';'sub09';'sub10';'sub11';'sub12';'sub13';'sub14';'sub15';'sub17';'sub18';'sub19';'sub20';'sub21';'sub25';'sub28';'sub29';'sub30'};

masks = {'Hippocampus_L.nii';'IFG_L.nii'};

study_path='H:\GJXX_1_reanalysis\gps\patterns_hlrf\rsa'; 
roi_path='H:\GJXX_1_reanalysis\no_too_easyorhard_item\rca';
data_dir = 'H:\GJXX_1_reanalysis\gps\patterns_hlrf';
n_subjects=numel(subjects);
n_masks=numel(masks);

msk1 = masks{1};
msk2 = masks{2};

counter_hsc=0;
counter_lsc=0;

for s = 1:length(subjects)
    sub = subjects{s};
    
    sub_dir = fullfile(data_dir,sub);
   pattern1=filenames(fullfile(sub_dir,'HSC_r*nii'));
   pattern2=filenames(fullfile(sub_dir,'LSC_r*nii'));
  
   
   H=length(pattern1);
   L=length(pattern2);
   
   if H <8
       continue;
   elseif L<8
       continue;
   end
    
    sub_path=fullfile(study_path,sub);
    mask1_fn=fullfile(roi_path,msk1);
    mask2_fn=fullfile(roi_path,msk2);
    %% mask1,HSC
    
    data_HSC_msk1=fullfile(sub_path,'HSC_r.nii');
    ds_HSC_msk1=cosmo_fmri_dataset(data_HSC_msk1,'mask',mask1_fn);
   % ds_HSC_msk1=cosmo_remove_useless_data(ds_HSC_msk1);
    cosmo_check_dataset(ds_HSC_msk1)
  %
    dsm_HSC_msk1=cosmo_pdist(ds_HSC_msk1.samples, 'correlation');
    dsm_HSC_msk1=1-dsm_HSC_msk1;
    dsm_HSC_msk1=atanh(dsm_HSC_msk1);
    %% mask2,hsc
    data_HSC_msk2=fullfile(sub_path,'HSC_r.nii');
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
    my_r_hsc(counter_hsc,:)=r_hsc;
    %% msk1,lsc
    data_LSC_msk1=fullfile(sub_path,'LSC_r.nii');
    ds_LSC_msk1=cosmo_fmri_dataset(data_LSC_msk1,'mask',mask1_fn);
   % ds_LSC_msk1=cosmo_remove_useless_data(ds_LSC_msk1);
    cosmo_check_dataset(ds_LSC_msk1)
 %
    dsm_LSC_msk1=cosmo_pdist(ds_LSC_msk1.samples, 'correlation');
    
    dsm_LSC_msk1=1-dsm_LSC_msk1;
    dsm_LSC_msk1=atanh(dsm_LSC_msk1);
    %% msk2,lsc
    data_LSC_msk2=fullfile(sub_path,'LSC_r.nii');
    ds_LSC_msk2=cosmo_fmri_dataset(data_LSC_msk2,'mask',mask2_fn);
  %  ds_LSC_msk2=cosmo_remove_useless_data(ds_LSC_msk2);
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
mean(my_r_hsc)> mean(my_r_lsc)
%atanh



