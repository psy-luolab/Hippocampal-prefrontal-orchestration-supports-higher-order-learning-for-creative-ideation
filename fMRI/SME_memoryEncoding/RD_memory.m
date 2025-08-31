% 
clear;clc;
%subjects = {'sub-01';'sub-02';'sub-03';'sub-04';'sub-06';'sub-07';'sub-08';'sub-09';'sub-10';'sub-11';'sub-12';'sub-14';'sub-15';'sub-16';'sub-17';'sub-18';'sub-19';'sub-20';'sub-22';'sub-23';'sub-24';'sub-25';'sub-26';'sub-27'};
subjects = {'sub-01';'sub-02';'sub-03';'sub-04';'sub-05';'sub-06';'sub-07';'sub-08';'sub-09';'sub-10';'sub-11';'sub-12';'sub-14';'sub-15';'sub-16';'sub-17';'sub-18';'sub-19';'sub-20';'sub-22';'sub-23';'sub-24';'sub-25';'sub-26';'sub-27'};

masks = {'Reslice_Hippocampus_L.nii'};           %   parahippocampal_gyrus_L  Hippocampus_L

study_path='/home/luo/flxx_memory/dimension4/pattern';

roi_path='/home/luo/flxx_memory/mask';

n_subjects=numel(subjects);

n_masks=numel(masks);

msk = masks{1};

counter=0;
counter1=0;
%
for s = 1:length(subjects)
    
    RD_eig_lsc=0;
    total_explained_lsc=0;
    RD_var_lsc=0;
    myexplained_lsc=0;
    
    RD_eig_hsc=0;
    total_explained_hsc=0;
    RD_var_hsc=0;
    myexplained_hsc=0;
   
    %%
    sub = subjects{s};
    sub_path=fullfile(study_path,sub);
    mask_fn=fullfile(roi_path,msk);%%%%%%%%%
    %%
    data_HSC=fullfile(sub_path,'glm_T_rz.nii');
    ds_HSC=cosmo_fmri_dataset(data_HSC,'mask',mask_fn);

    dsm_HSC=cosmo_pdist(ds_HSC.samples, 'correlation');
    RDM_HSC=cosmo_squareform(dsm_HSC);
    RDM_HSC=1-RDM_HSC;
    [coeff,latent,explained]=pcacov(RDM_HSC);
    for m = 1:length(latent)
        if latent(m)>1
            RD_eig_hsc = RD_eig_hsc+1;
            myexplained_hsc=myexplained_hsc+explained(m);
        end
    end
    
    for n = 1:length(explained)
        total_explained_hsc=total_explained_hsc+explained(n);
        if total_explained_hsc > 80
            break
        end
    end
    
    RD_var_hsc = n;
    RD_eff_hsc=RD_eig_hsc/myexplained_hsc;
    
    counter=counter+1;
    %RDeig_hsc(counter,:)=RD_eig_hsc;
    RDvar_hsc(counter,:)=RD_var_hsc;
    %RDeff_hsc(counter,:)=RD_eff_hsc;
    
    %%
    data_LSC=fullfile(sub_path,'glm_T_fw.nii');
    ds_LSC=cosmo_fmri_dataset(data_LSC,'mask',mask_fn);

    dsm_LSC=cosmo_pdist(ds_LSC.samples, 'correlation');
    RDM_LSC=cosmo_squareform(dsm_LSC);
    RDM_LSC=1-RDM_LSC;
    [coeff,latent,explained]=pcacov(RDM_LSC);
    for w = 1:length(latent)
        if latent(w)>1
            RD_eig_lsc = RD_eig_lsc+1;
            myexplained_lsc=myexplained_lsc+explained(w);
        end
    end
    
    for j = 1:length(explained)
        total_explained_lsc=total_explained_lsc+explained(j);
        if total_explained_lsc > 80
            break
        end
    end
     RD_var_lsc = j;
    RD_eff_lsc=RD_eig_lsc/myexplained_lsc;
    
    counter1=counter1+1;
    %RDeig_lsc(counter1,:)=RD_eig_lsc;
    
    
    if isempty(RD_var_lsc)
        RD_var_lsc=NaN;
    end
    RDvar_lsc(counter1,:)=RD_var_lsc;
    %RDeff_lsc(counter1,:)=RD_eff_lsc;
    
    
    
end
%
%[h,p,ci,stats]=ttest(RDeig_hsc,RDeig_lsc);
%
[h1,p1,ci1,stats1] = ttest(RDvar_hsc,RDvar_lsc)
%
%[h2,p2,ci2,stats2]=ttest(RDeff_hsc,RDeff_lsc);


mean(RDvar_hsc)> mean(RDvar_lsc)

%datas=[RDeff_hsc,RDeff_lsc,RDeig_hsc,RDeig_lsc,RDvar_hsc,RDvar_lsc];