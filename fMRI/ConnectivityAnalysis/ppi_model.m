clear all;clc;
data_path= '...';
subname = dir([data_path,'sub*']);
data_orgin_path = '...\processing\';
spm('Defaults','fMRI');
spm_jobman('initcfg');
condition_type = 'HSC_LSC';
% WORKING DIRECTORY

for i= 1: length(subname); 
clear matlabbatch ppi1 ppi2 ppi3 ppi4  
data_folder = [data_path,subname(i).name,filesep];
name = subname(i).name;

ppi1=load([data_folder,'PPI_',condition_type,'_R1_Hippocampus_L.mat']);%%%%%%%%%%%%%%%
ppi2=load([data_folder,'PPI_',condition_type,'_R2_Hippocampus_L.mat']);%%%%%%%%%%%%%%%%
ppi3=load([data_folder,'PPI_',condition_type,'_R3_Hippocampus_L.mat']);%%%%%%%%%%%%%%%
ppi4=load([data_folder,'PPI_',condition_type,'_R4_Hippocampus_L.mat']);%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GLM SPECIFICATION, ESTIMATION & INFERENCE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODEL SPECIFICATION

%--------------------------------------------------------------------------
fundata1 = spm_select('ExtFPList', fullfile(data_orgin_path,name,filesep,'run1'), '.*\.nii$');
fundata2 = spm_select('ExtFPList', fullfile(data_orgin_path,name,filesep,'run2'), '.*\.nii$');
fundata3 = spm_select('ExtFPList', fullfile(data_orgin_path,name,filesep,'run3'), '.*\.nii$');
fundata4 = spm_select('ExtFPList', fullfile(data_orgin_path,name,filesep,'run4'), '.*\.nii$');

outdir = [data_path,'results\PPI\Hippocampus_L\HSC_LSC\',name];
if ~exist(outdir)
    mkdir(outdir);
end
matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr(outdir);%%%%%%%%%%%
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT    = 2;

matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans            = cellstr(fundata1);
matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress(1).name = 'ppi1';
matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress(1).val = ppi1.PPI.ppi;
matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress(2).name = 'Y1';
matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress(2).val = ppi1.PPI.Y;
matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress(3).name = 'P1';
matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress(3).val = ppi1.PPI.P;

matlabbatch{1}.spm.stats.fmri_spec.sess(2).scans            = cellstr(fundata2);
matlabbatch{1}.spm.stats.fmri_spec.sess(2).regress(1).name =  'ppi2';
matlabbatch{1}.spm.stats.fmri_spec.sess(2).regress(1).val = ppi2.PPI.ppi;
matlabbatch{1}.spm.stats.fmri_spec.sess(2).regress(2).name = 'Y2';
matlabbatch{1}.spm.stats.fmri_spec.sess(2).regress(2).val = ppi2.PPI.Y;
matlabbatch{1}.spm.stats.fmri_spec.sess(2).regress(3).name =  'P2';
matlabbatch{1}.spm.stats.fmri_spec.sess(2).regress(3).val = ppi2.PPI.P;

matlabbatch{1}.spm.stats.fmri_spec.sess(3).scans            = cellstr(fundata3);
matlabbatch{1}.spm.stats.fmri_spec.sess(3).regress(1).name =  'ppi3';
matlabbatch{1}.spm.stats.fmri_spec.sess(3).regress(1).val = ppi2.PPI.ppi;
matlabbatch{1}.spm.stats.fmri_spec.sess(3).regress(2).name = 'Y3';
matlabbatch{1}.spm.stats.fmri_spec.sess(3).regress(2).val = ppi2.PPI.Y;
matlabbatch{1}.spm.stats.fmri_spec.sess(3).regress(3).name =  'P3';
matlabbatch{1}.spm.stats.fmri_spec.sess(3).regress(3).val = ppi2.PPI.P;

matlabbatch{1}.spm.stats.fmri_spec.sess(4).scans            = cellstr(fundata4);
matlabbatch{1}.spm.stats.fmri_spec.sess(4).regress(1).name =  'ppi4';
matlabbatch{1}.spm.stats.fmri_spec.sess(4).regress(1).val = ppi2.PPI.ppi;
matlabbatch{1}.spm.stats.fmri_spec.sess(4).regress(2).name = 'Y4';
matlabbatch{1}.spm.stats.fmri_spec.sess(4).regress(2).val = ppi2.PPI.Y;
matlabbatch{1}.spm.stats.fmri_spec.sess(4).regress(3).name =  'P4';
matlabbatch{1}.spm.stats.fmri_spec.sess(4).regress(3).val = ppi2.PPI.P;


% MODEL ESTIMATION
%--------------------------------------------------------------------------
spmpath=[outdir,'\SPM.mat'];%%%%%%%%%%%%%%%%
matlabbatch{2}.spm.stats.fmri_est.spmmat = {spmpath};

% INFERENCE
%--------------------------------------------------------------------------
matlabbatch{3}.spm.stats.con.spmmat ={spmpath};
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name   = 'ppi';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = [1 0 0 1 0 0 1 0 0 1 0 0];

spm_jobman('run',matlabbatch);
end