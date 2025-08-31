% Compressed hippocampus-IFG connectivity during the learning and creating phases 
% PCA-reduced latent variables similarity

clear;clc;
subjects = {'sub-01';'sub-02';'sub-03';'sub-04';'sub-05';'sub-06';'sub-07';'sub-08';'sub-09';'sub-10';'sub-11';'sub-12';'sub-13';'sub-14';'sub-15';'sub-16';'sub-17';'sub-18';'sub-19';'sub-20';'sub-21';'sub-22';'sub-23';'sub-24';'sub-25';'sub-26';'sub-27';'sub-28';'sub-29';'sub-30';'sub-31';'sub-32';'sub-33';'sub-34';'sub-36';'sub-37';'sub-38';'sub-39';'sub-40'};

masks = {'Hippocampus_L.nii';'IFG_L.nii'};%

s_path='...';%

roi_path='...s\mask';

n_subjects=numel(subjects);

n_masks=numel(masks);

counter=0;
counter1=0;


for s = 1:length(subjects)
    %%
    %% HSC 
    sub = subjects{s};
    sub_s2_path=fullfile(s_path,sub);
    mask1_fn=fullfile(roi_path,masks{1});
    mask2_fn=fullfile(roi_path,masks{2});
    %%
    S1data_HSC=fullfile(sub_s2_path,'glm_HSC.nii');
    S1ds_HSC=cosmo_fmri_dataset(S1data_HSC,'mask',mask1_fn);

    S1dsm_HSC=cosmo_pdist(S1ds_HSC.samples, 'correlation');
    S1RDM_HSC=cosmo_squareform(S1dsm_HSC);
    S1RDM_HSC=1-S1RDM_HSC;
    [coeff_S1,latent,explained]=pcacov(S1RDM_HSC);
    
    total_explained_hsc=0;
     for n0 = 1:length(explained)
        total_explained_hsc=total_explained_hsc+explained(n0);
        if total_explained_hsc > 80
            break
        end
    end
  %%
     S2data_HSC=fullfile(sub_s2_path,'glm_HSC.nii');
    S2ds_HSC=cosmo_fmri_dataset(S2data_HSC,'mask',mask2_fn);

    S2dsm_HSC=cosmo_pdist(S2ds_HSC.samples, 'correlation');
    S2RDM_HSC=cosmo_squareform(S2dsm_HSC);
    S2RDM_HSC=1-S2RDM_HSC;
    [coeff_S2,latent,explained]=pcacov(S2RDM_HSC);
    
    total_explained_hsc=0;
    for n1 = 1:length(explained)
        total_explained_hsc=total_explained_hsc+explained(n1);
        if total_explained_hsc > 80
            break
        end
    end
    
    R_sum = 0;
    for n = 1:min(n1,n0)
        vector1 = coeff_S1(:,n);
        vector2 = coeff_S2(:,n);
        matrix = [vector1,vector2]';
        R = 1 - pdist2(matrix(1,:), matrix(2,:), 'cosine');
        R_sum = R_sum+R;
    end
    
    counter=counter+1;
    Rhsc(counter,:)=R_sum/n;
   
    %% LSC
    S1data_LSC=fullfile(sub_s2_path,'glm_LSC.nii');
    S1ds_LSC=cosmo_fmri_dataset(S1data_LSC,'mask',mask1_fn);

    S1dsm_LSC=cosmo_pdist(S1ds_LSC.samples, 'correlation');
    S1RDM_LSC=cosmo_squareform(S1dsm_LSC);
    S1RDM_LSC=1-S1RDM_LSC;
   
    
    
     [lsccoeff_S1,latent,explained]=pcacov(S1RDM_LSC);
    total_explained_hsc=0;
     for n0 = 1:length(explained)
        total_explained_hsc=total_explained_hsc+explained(n0);
        if total_explained_hsc > 80
            break
        end
    end
  %%
     S2data_LSC=fullfile(sub_s2_path,'glm_LSC.nii');
    S2ds_LSC=cosmo_fmri_dataset(S2data_LSC,'mask',mask2_fn);

    S2dsm_LSC=cosmo_pdist(S2ds_LSC.samples, 'correlation');
    S2RDM_LSC=cosmo_squareform(S2dsm_LSC);
    S2RDM_LSC=1-S2RDM_LSC;
    
    %%
     [lsccoeff_S2,latent,explained]=pcacov(S2RDM_LSC);
    total_explained_hsc=0;
     for n1 = 1:length(explained)
        total_explained_hsc=total_explained_hsc+explained(n1);
        if total_explained_hsc > 80
            break
        end
    end

    %%
    R_sum = 0;
    for m = 1:min(n1,n0)
        vector1 = lsccoeff_S1(:,n);
        vector2 = lsccoeff_S2(:,n);
        matrix = [vector1,vector2]';
        R = 1 - pdist2(matrix(1,:), matrix(2,:), 'cosine');
        R_sum = R_sum+R;
    end
    
    counter1=counter1+1;
    Rlsc(counter1,:)=R_sum/m;
    
end
%
[h1,p1,ci1,stats1] = ttest(Rhsc,Rlsc)
