% find voxels with significant activation differences in HSC and LSC (p < .05, uncorrected) 
% the method is based on Xue 2010 science paper


%%
clear;clc;
subjects = {'sub-02';'sub-03';'sub-04'};
masks = {'Hippocampus_L.nii'};
study_path='I:\FLXX1\Dimension\pattern'; 
roi_path='I:\FLXX1\mask';
n_subjects=numel(subjects);
msk = masks{1};

%% how many voxels?
for s = 1
    sub = subjects{s};
    sub_path=fullfile(study_path,sub);
    mask_fn=fullfile(roi_path,msk);
    %%
    data_HSC=fullfile(sub_path,'glm_T_stats_HSC.nii');
    ds_HSC=cosmo_fmri_dataset(data_HSC,'mask',mask_fn);
    d_HSC=ds_HSC.samples;

    nvoxels = size(d_HSC,2);
end

%%
mymask =[];
counter = 1;

%%
for n = 1: nvoxels
    allh=[];
    alll=[];
    count =1;
    for s = 1:n_subjects

        sub = subjects{s};
        sub_path=fullfile(study_path,sub);
        mask_fn=fullfile(roi_path,msk);
        %%
        data_HSC=fullfile(sub_path,'glm_T_stats_HSC.nii');
        ds_HSC=cosmo_fmri_dataset(data_HSC,'mask',mask_fn);
        d_HSC=ds_HSC.samples;
        hscdat = mean(d_HSC);
        h = hscdat(1,n);
        data_LSC=fullfile(sub_path,'glm_T_stats_LSC.nii');
        ds_LSC=cosmo_fmri_dataset(data_LSC,'mask',mask_fn);
        d_LSC=ds_LSC.samples;
        lscdat = mean(d_LSC);
        l = lscdat(1,n);

        allh(count,1)=h;
        alll(count,1)=l;
        count = count + 1;
    end
    [h,p,ci,stats]=ttest(allh,alll)

    if h==1
        mymask(1,counter)=0;
    else
        mymask(1,counter)=1;
    end
    counter =counter +1;

end

save voxelmask.mat mymask
