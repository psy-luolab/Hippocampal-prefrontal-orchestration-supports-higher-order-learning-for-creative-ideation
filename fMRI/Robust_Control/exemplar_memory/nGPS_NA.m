%%  parahippocampal_gyrus_R
clear;
clc;
subjects = {'sub02';'sub03';'sub04';'sub05';'sub06';'sub07';'sub08';'sub09';'sub10';'sub11';'sub12';'sub13';'sub14';'sub15';'sub17';'sub18';'sub19';'sub20';'sub21';'sub25';'sub28';'sub29';'sub30'};
%%
masks = {'Hippocampus_L.nii'};           
%%
study_path='H:\GJXX_1_reanalysis\gps\patterns_hlrf\rsa';

roi_path='E:\FLDATA_analysis\ROI';

n_subjects=numel(subjects);
n_masks=numel(masks);
msk = masks{1};
%%
data_dir = 'H:\GJXX_1_reanalysis\gps\patterns_hlrf';
%%
counter=0;
%%
for s = 1:length(subjects)
    sub = subjects{s};
    sub_path=fullfile(study_path,sub);
    mask_fn=fullfile(roi_path,msk);
    sub_dir =fullfile(data_dir,sub);
    %% 
   pattern1=filenames(fullfile(sub_dir,'HSC_r*nii'));
   
   pattern3=filenames(fullfile(sub_dir,'LSC_r*nii'));
  
   
   HR=length(pattern1);
 
   LR=length(pattern3);
  
   
   if HR < 8
       continue;
   elseif LR < 8
       continue;
   end
  
   
    %%
    data=fullfile(sub_path,'glm_T_gps.nii');  
    ds=cosmo_fmri_dataset(data,'mask',mask_fn);

     dsm=cosmo_pdist(ds.samples, 'correlation');
   
    RDM=cosmo_squareform(dsm);
    RDM=1-RDM; 
    RDM=atanh(RDM);
    counter=counter+1;
    
    %%ֵ
    RDM(RDM==inf)=0; % 
    ALL=mean(RDM,2);
    
    HSCR=mean(ALL(1:HR,1));
   
    LSCR=mean(ALL(HR+1:HR+LR,1));
 
    
    HSC_R(counter,1)=HSCR;
   
    LSC_R(counter,1)=LSCR;
  
    
end
[h,p,ci,stats]= ttest(HSC_R,LSC_R)
mean(HSC_R) 
mean(LSC_R)

