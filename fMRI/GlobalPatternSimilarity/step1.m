clear;clc;
spm('Defaults','fMRI');
spm_jobman('initcfg');
data_dir = '...\gps\patterns';  
data_name = dir([data_dir filesep 'sub*']);
data_out_dir = [data_dir filesep 'rsa'];

if ~exist(data_out_dir)
    mkdir(data_out_dir);
end
%%  
for nsub = 1:size(data_name,1)
    sub_dir = [data_dir filesep data_name(nsub).name];
    %%
   pattern1=filenames(fullfile(sub_dir,'HSC*nii'));
   pattern2=filenames(fullfile(sub_dir,'LSC*nii'));
   pattern3=filenames(fullfile(sub_dir,'tianchong*nii'));
  
   pattern=[pattern1;pattern2;pattern3];
   
   out_dir = [data_out_dir filesep data_name(nsub).name];
    
    if ~exist(out_dir)
        mkdir(out_dir);
    end
 
    matlabbatch{1}.spm.util.cat.vols = cellstr(pattern);
    matlabbatch{1}.spm.util.cat.name = [out_dir filesep 'glm_T_gps.nii'];
    matlabbatch{1}.spm.util.cat.dtype = 4;
    matlabbatch{1}.spm.util.cat.RT = NaN;
    spm_jobman('run',matlabbatch);
    clear matlabbatch
end

