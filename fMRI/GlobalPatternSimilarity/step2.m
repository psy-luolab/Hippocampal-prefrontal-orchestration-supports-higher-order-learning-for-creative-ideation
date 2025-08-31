%%  
clear;
clc;
subjects = {'sub02';'sub03';'sub04';'sub05';'sub06';'sub07';'sub08';'sub09';'sub10';'sub11';'sub12';'sub13';'sub14';'sub15';'sub17';'sub18';'sub19';'sub20';'sub21';'sub25';'sub28';'sub29';'sub30'};
%%
masks = {'hippocampus_L.nii'};            % 
%%
study_path='...';

roi_path='...\mask';

n_subjects=numel(subjects);
n_masks=numel(masks);
msk = masks{1};
%%
data_dir = '...\gps\patterns';
%%
counter=0;
%%
for s = 1:length(subjects)
    sub = subjects{s};
    sub_path=fullfile(study_path,sub);
    mask_fn=fullfile(roi_path,msk);
    sub_dir =fullfile(data_dir,sub);
    %%
   pattern1=filenames(fullfile(sub_dir,'HSC*nii'));
   pattern2=filenames(fullfile(sub_dir,'LSC*nii'));
  
   
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
    %% 
    RDM(RDM==inf)=0; 
    ALL=mean(RDM,2);
    
    HSCR=mean(ALL(1:H,1));
    
    LSCR=mean(ALL(H+1:H+L,1));
    
    HSC_gps(counter,1)=HSCR;
    LSC_gps(counter,1)=LSCR;
end
%% 
[h,p,ci,stats]= ttest(HSC_gps,LSC_gps)
mean(HSC_gps) 
mean(LSC_gps)
