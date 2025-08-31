clear;clc;

subjects = {'sub-02';'sub-03';'sub-04';'sub-05';'sub-06';'sub-07';'sub-08';'sub-09';'sub-10';'sub-11';'sub-12';'sub-13';'sub-14';'sub-15';'sub-17';'sub-18';'sub-19';'sub-20';'sub-21';'sub-25';'sub-28';'sub-29';'sub-30'};

masks = {'Hippocampus_L.nii'};

study_path='H:\GJXX_1_reanalysis\jiaocha_vs_nojiaocha\rca\patterns'; % patternλ��

roi_path='H:\GJXX_1_reanalysis\jiaocha_vs_nojiaocha\rca';

n_subjects=numel(subjects);
n_masks=numel(masks);
msk = masks{1};

counter=0;
counter1=0;

for s = 1:length(subjects) 
    %% ָ��ĳ�ʼ�?
    RD_eig_lsc=0;
    total_explained_lsc=0;
    RD_var_lsc=0;
    myexplained_lsc=0;
    %%
    RD_eig_hsc=0;
    total_explained_hsc=0;
    RD_var_hsc=0;
    myexplained_hsc=0;
    %%
    sub = subjects{s};
    sub_path=fullfile(study_path,sub);
    mask_fn=fullfile(roi_path,msk);
    %%  HSC�飬����3��ָ��
    data_HSC=fullfile(sub_path,'glm_T_HSC_C.nii');
    ds_HSC=cosmo_fmri_dataset(data_HSC,'mask',mask_fn);
    dsm_HSC=cosmo_pdist(ds_HSC.samples, 'correlation');
    RDM_HSC=cosmo_squareform(dsm_HSC);
    [coeff,latent,explained]=pcacov(RDM_HSC);
    

    
    for n = 1:length(explained)
        total_explained_hsc=total_explained_hsc+explained(n);
        if total_explained_hsc > 80
            break
        end
    end
    
    RD_var_hsc = n;
    
%     RD_eff_hsc=100*RD_eig_hsc/myexplained_hsc;
    
    counter=counter+1;
 %   RDeig_hsc(counter,:)=RD_eig_hsc;
    RDvar_hsc(counter,:)=RD_var_hsc;
%    RDeff_hsc(counter,:)=RD_eff_hsc;
    %% LSC��
    data_LSC=fullfile(sub_path,'glm_T_LSC_C.nii');
    ds_LSC=cosmo_fmri_dataset(data_LSC,'mask',mask_fn);
    dsm_LSC=cosmo_pdist(ds_LSC.samples, 'correlation');
    RDM_LSC=cosmo_squareform(dsm_LSC);
    
    [coeff,latent,explained]=pcacov(RDM_LSC);

    
    for j = 1:length(explained)
        total_explained_lsc=total_explained_lsc+explained(j);
        if total_explained_lsc > 80
            break
        end
    end
     RD_var_lsc = j;
%      RD_eff_lsc=100*RD_eig_lsc/myexplained_lsc;
    
    counter1=counter1+1;
 %   RDeig_lsc(counter1,:)=RD_eig_lsc;
    RDvar_lsc(counter1,:)=RD_var_lsc;
  %  RDeff_lsc(counter1,:)=RD_eff_lsc;
end
% 
[h,p,ci,stats]=ttest(RDvar_hsc,RDvar_lsc)

