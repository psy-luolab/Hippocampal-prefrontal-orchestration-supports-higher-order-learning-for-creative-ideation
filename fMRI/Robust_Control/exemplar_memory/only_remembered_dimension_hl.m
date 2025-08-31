% use fun but not fun_aroma
clear;clc;
subjects = {'sub02';'sub03';'sub04';'sub05';'sub06';'sub07';'sub08';'sub09';'sub10';'sub11';'sub12';'sub13';'sub14';'sub15';'sub17';'sub18';'sub19';'sub20';'sub21';'sub25';'sub28';'sub29';'sub30'};
masks = {'Hippocampus_L.nii'};%%

study_path='H:\GJXX_1_reanalysis\gps\patterns_hlrf\rsa'; % pattern位置
data_dir = 'H:\GJXX_1_reanalysis\gps\patterns_hlrf';

roi_path='I:\FLXX1\mask';

n_subjects=numel(subjects);
n_masks=numel(masks);
msk = masks{1};

counter=0;
counter1=0;

for s = 1:length(subjects) 
    %% 指标的初始值
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
     sub_dir =fullfile(data_dir,sub);
     
   pattern1=filenames(fullfile(sub_dir,'HSC_r*nii'));
   
   pattern2=filenames(fullfile(sub_dir,'LSC_r*nii'));
  
   
   HR=length(pattern1);
 
   LR=length(pattern2);
  
   
   if HR < 8
       continue;
   elseif LR <8
       continue;
   end
   
    sub_path=fullfile(study_path,sub);
    mask_fn=fullfile(roi_path,msk);
    %%  HSC组，计算3个指标
    data_HSC=fullfile(sub_path,'HSC_r.nii');
    ds_HSC=cosmo_fmri_dataset(data_HSC,'mask',mask_fn);
    dsm_HSC=cosmo_pdist(ds_HSC.samples, 'correlation');
    RDM_HSC=cosmo_squareform(dsm_HSC);
    [coeff,latent,explained]=pcacov(RDM_HSC);
    
    for m = 1:length(latent)
        if latent(m)>1
            RD_eig_hsc = RD_eig_hsc+1;
            myexplained_hsc=myexplained_hsc+explained(m);
        end
    end
    
    for n = 1:length(explained)
        total_explained_hsc=total_explained_hsc+explained(n);
        if total_explained_hsc > 90
            break
        end
    end
    
    RD_var_hsc = n;
    
    RD_eff_hsc=100*RD_eig_hsc/myexplained_hsc;
    
    counter=counter+1;
    RDeig_hsc(counter,:)=RD_eig_hsc;
    RDvar_hsc(counter,:)=RD_var_hsc;
    RDeff_hsc(counter,:)=RD_eff_hsc;
    %% LSC组
    data_LSC=fullfile(sub_path,'LSC_r.nii');
    ds_LSC=cosmo_fmri_dataset(data_LSC,'mask',mask_fn);
    dsm_LSC=cosmo_pdist(ds_LSC.samples, 'correlation');
    RDM_LSC=cosmo_squareform(dsm_LSC);
    
    [coeff,latent,explained]=pcacov(RDM_LSC);
    for w = 1:length(latent)
        if latent(w)>1
            RD_eig_lsc = RD_eig_lsc+1;
            myexplained_lsc=myexplained_lsc+explained(w);
        end
    end
    
    for j = 1:length(explained)
        total_explained_lsc=total_explained_lsc+explained(j);
        if total_explained_lsc > 90
            break
        end
    end
     RD_var_lsc = j;
     RD_eff_lsc=100*RD_eig_lsc/myexplained_lsc;
    
    counter1=counter1+1;
    RDeig_lsc(counter1,:)=RD_eig_lsc;
    RDvar_lsc(counter1,:)=RD_var_lsc;
    RDeff_lsc(counter1,:)=RD_eff_lsc;
end
% 
%[h1,p1,ci1,stats1]=ttest(RDeig_hsc,RDeig_lsc)% paired t test
[h2,p2,ci2,stats2]=ttest(RDvar_hsc,RDvar_lsc)
%[h3,p3,ci3,stats3]=ttest(RDeff_hsc,RDeff_lsc)
%%
 %data=[RDeig_hsc,RDeig_lsc,RDvar_hsc,RDvar_lsc,RDeff_hsc,RDeff_lsc];
% mean(RDvar_hsc)
% mean(RDvar_lsc)