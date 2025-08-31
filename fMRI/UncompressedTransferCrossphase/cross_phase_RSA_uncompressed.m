% learning-creating neural pattern similarit in uncompress neural space

clear
clc
subjects = {'sub-01';'sub-02...'};
s1_path='...\First_level\S1\rsa';
s2_path='...\First_level\S2\rsa';
roi_path = '...';
masks = {'mask.nii'};
msk = masks{1};
out_path='...';

for s=1:length(subjects)
    sub = subjects{s};
    sub_s1_path=fullfile(s1_path,sub);
    sub_s2_path=fullfile(s2_path,sub);

    roi=fullfile(roi_path,sub);

    mask_fn=fullfile(roi,msk);

    output_path=fullfile(out_path,sub);

    if ~exist(output_path)
        mkdir(output_path);
    end

    %%

    data_HSC=fullfile(sub_s1_path,'glm_HSC.nii');
    ds_HSC_roi=cosmo_fmri_dataset(data_HSC,'mask',mask_fn);

    data_s2=fullfile(sub_s2_path,'glm_HSC.nii');
    ds_s2_roi=cosmo_fmri_dataset(data_s2,'mask',mask_fn);

    all_ds = cosmo_stack({ds_s2_roi,ds_HSC_roi});

    %%
    measure = @my_measure;

    measure_args = struct();


    voxel_count=100;

    nbrhood=cosmo_spherical_neighborhood(all_ds,'count',voxel_count);
    result_hsc = cosmo_searchlight(all_ds,nbrhood,measure,measure_args);
    cosmo_map2fmri(result_hsc, ...
        fullfile(output_path,'HSC.nii'));


end


for s=1:length(subjects)
    sub = subjects{s};
    sub_s1_path=fullfile(s1_path,sub);
    sub_s2_path=fullfile(s2_path,sub);

    roi=fullfile(roi_path,sub);

    mask_fn=fullfile(roi,msk);

    output_path=fullfile(out_path,sub);

    if ~exist(output_path)
        mkdir(output_path);
    end

    %%
    data_LSC=fullfile(sub_s1_path,'glm_LSC.nii');
    ds_LSC_roi=cosmo_fmri_dataset(data_LSC,'mask',mask_fn);

    data_s2=fullfile(sub_s2_path,'glm_LSC.nii');
    ds_s2_roi=cosmo_fmri_dataset(data_s2,'mask',mask_fn);

    all_ds = cosmo_stack({ds_s2_roi,ds_LSC_roi});

    %%
    measure = @my_measure_help_all_within;

    measure_args = struct();

    voxel_count=100;

    nbrhood=cosmo_spherical_neighborhood(all_ds,'count',voxel_count);
    result_hsc = cosmo_searchlight(all_ds,nbrhood,measure,measure_args);
    cosmo_map2fmri(result_hsc, ...
        fullfile(output_path,'LSC.nii'));

end