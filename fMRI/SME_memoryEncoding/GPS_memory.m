%%   HPC
clear;
clc;
subjects = {'sub-01';'sub-02';'sub-03';'sub-04';'sub-05';'sub-06';'sub-07';'sub-08';'sub-09';'sub-10';'sub-11';'sub-12';'sub-13';'sub-14';'sub-15';'sub-16';'sub-17';'sub-18';'sub-19';'sub-20';'sub-21';'sub-22';'sub-23';'sub-24';'sub-25';'sub-26';'sub-27'};
%%
masks = {'Reslice_Hippocampus_L.nii'};           %   body head Reslice_Frontal_Inf_Tri_L
%%
study_path='/home/luo/flxx_memory/gps_4types/pattern';

roi_path='/home/luo/flxx_memory/mask';

n_subjects=numel(subjects);
n_masks=numel(masks);
msk = masks{1};
%%LSC_gps
data_dir = '/home/luo/flxx_memory/first_data_4types';
%%
counter=0;
%%1:length(subjects)
for s = 1:length(subjects)
    sub = subjects{s};
    sub_path=fullfile(study_path,sub);
    mask_fn=fullfile(roi_path,msk);
    sub_dir =fullfile(data_dir,sub);
    %% �õ�HSC��LSC������
   pattern1=filenames(fullfile(sub_dir,'*r_z*nii'));
   pattern2=filenames(fullfile(sub_dir,'*r_w*nii'));
   pattern3=filenames(fullfile(sub_dir,'*f_z*nii'));
   pattern4=filenames(fullfile(sub_dir,'*f_w*nii'));
   
   rz=length(pattern1);
   rw=length(pattern2);
   fz=length(pattern3);
   fw=length(pattern4);
   
   if s==2|3|21
       rw = 0;
   end
   
   if s==21
       rz=0;
   
   end
   
   if s==13
       fw=0;
   end
    %%
    data=fullfile(sub_path,'glm_T_gps.nii');  
    ds=cosmo_fmri_dataset(data,'mask',mask_fn);

    dsm=cosmo_pdist(ds.samples, 'correlation');
   
    RDM=cosmo_squareform(dsm);
    RDM=1-RDM; 
    RDM=atanh(RDM);
    counter=counter+1;
    
    %% �ֱ����HSC���LSC���ƽ��Rֵ
    RDM(RDM==inf)=0; % �Լ����Լ���أ���???1������fisher Zת���󣬱��inf,ͳһ���???0�������뿼��
    ALL=mean(RDM,2);
    
    r_z=mean(ALL(1:rz,1)); 
    
    f_w=mean(ALL(rz+rw+fz+1:rz+rw+fz+fw,1));
    
    rz_gps(counter,1)=r_z;
    
    fw_gps(counter,1)=f_w;

end
%% t����
[h,p,ci,stats]= ttest(rz_gps,fw_gps)


