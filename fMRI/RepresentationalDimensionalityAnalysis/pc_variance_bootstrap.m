%Bootstrap analysis of variance explained by early principal components (PCs).

%This script tests whether the observed dimensionality reduction in HSC trials is primarily driven by early, information-rich PCs

%%
clear;clc;
subjects = {'sub-02';'sub-03';'sub-04';'sub-05';'sub-06';'sub-07';'sub-08';'sub-09';'sub-10';'sub-11';'sub-12';'sub-13';'sub-14';'sub-15';'sub-17';'sub-18';'sub-19';'sub-20';'sub-21';'sub-25';'sub-28';'sub-29';'sub-30'};
masks = {'Hippocampus_L.nii'}; %% ROI

study_path='I:\FLXX1\Dimension\pattern'; 
roi_path='I:\FLXX1\mask';

n_subjects=numel(subjects);
n_masks=numel(masks);
msk = masks{1};

alldata = [];
counterp = 0;
%% ?th to ?th PCs
jj = 3;
jjj = 5;
%%
counter=0;
counter1=0;

for s = 1:length(subjects)
    %%
    sub = subjects{s};
    sub_path=fullfile(study_path,sub);
    mask_fn=fullfile(roi_path,msk);
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    data_HSC=fullfile(sub_path,'glm_T_stats_HSC.nii');
    ds_HSC=cosmo_fmri_dataset(data_HSC,'mask',mask_fn);
    d_HSC=ds_HSC.samples';
    
    data_LSC=fullfile(sub_path,'glm_T_stats_LSC.nii');
    ds_LSC=cosmo_fmri_dataset(data_LSC,'mask',mask_fn);
    d_LSC=ds_LSC.samples';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % true_length = min(size(d_HSC,2),size(d_LSC,2));
    true_length = 20;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if  true_length ~= size(d_HSC,2)
        
        allrd = 0;
        for x = 1:1000
            da_HSC = d_HSC(:,randperm(size(d_HSC,2),true_length)); 
            [coeff,score,latent,tsquared,explained,mu]=pca(da_HSC);
                total_explained_hsc=0;
                 RD_var_hsc=0;
        for n = jj:jjj
           total_explained_hsc=total_explained_hsc+explained(n);
                
        end
            
            RD_var_hsc = total_explained_hsc;
            allrd = allrd + RD_var_hsc;
            
        end
        
        counter=counter+1;
        RDhsc(counter,:)=allrd/1000;
        
    else
        %%%%%%
        %
        [coeff,score,latent,tsquared,explained,mu]=pca(d_HSC);
        total_explained_hsc=0;
         RD_var_hsc=0;
        for n = jj:jjj
           total_explained_hsc=total_explained_hsc+explained(n);
                
        end
        RD_var_hsc = total_explained_hsc;
        counter=counter+1;
        RDhsc(counter,:)=RD_var_hsc;
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% LSC
    if  true_length ~= size(d_LSC,2)
       
        allrd = 0;
        for x = 1:1000
            da_LSC = d_LSC(:,randperm(size(d_LSC,2),true_length)); 
            [coeff,score,latent,tsquared,explained,mu]=pca(da_LSC);
            total_explained_lsc=0;
             RD_var_lsc=0;
            for n = jj:jjj
                total_explained_lsc=total_explained_lsc+explained(n);
                
            end
            
            RD_var_lsc = total_explained_lsc;
            allrd = allrd + RD_var_lsc;
            
        end
        
        counter1=counter1+1;
        RDlsc(counter1,:)=allrd/1000;
        
    else
        %%%%%%
      
        [coeff,score,latent,tsquared,explained,mu]=pca(d_LSC);
         total_explained_lsc=0;
          RD_var_lsc = 0;
       for n = jj:jjj
           total_explained_lsc=total_explained_lsc+explained(n);
                
        end
        
        RD_var_lsc = total_explained_lsc;
        counter1=counter1+1;
        RDlsc(counter1,:)=RD_var_lsc;
    end
    
end

[h,p,ci,stats]=ttest(RDhsc,RDlsc)

