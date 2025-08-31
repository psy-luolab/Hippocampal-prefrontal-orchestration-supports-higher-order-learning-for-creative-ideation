clear; clc;
spm_jobman('initcfg');
spm('defaults', 'fMRI');
data_dir = 'I:\FLXX1\func';
sublist = dir([data_dir,'\sub*']);
%%
mydir = 'H:\GJXX_1_reanalysis\events';

for nsub=1:length(sublist)
     sub_dir = [data_dir,filesep,sublist(nsub).name];
     onset_dir = [mydir,filesep,sublist(nsub).name];
    %-----------------------------------------------------------------------
    out_dir = ['H:\GJXX_1_reanalysis\biggerthan3\pattern\',sublist(nsub).name]; %
    
    if ~exist(out_dir)
        mkdir(out_dir);
    end
    
    run1 = spm_select('ExtFPList', fullfile(sub_dir,'run1'),'^sub-.*\.nii$');%
    run2 = spm_select('ExtFPList', fullfile(sub_dir,'run2'),'^sub-.*\.nii$');
    run3 = spm_select('ExtFPList', fullfile(sub_dir,'run3'),'^sub-.*\.nii$');
    run4 = spm_select('ExtFPList', fullfile(sub_dir,'run4'),'^sub-.*\.nii$');
    
    run_con_all = dir([onset_dir,filesep,'sub*.txt']);%
    run1_con=readtable([onset_dir,filesep,run_con_all(1).name]);
    run2_con=readtable([onset_dir,filesep,run_con_all(2).name]);
    run3_con=readtable([onset_dir,filesep,run_con_all(3).name]);
    run4_con=readtable([onset_dir,filesep,run_con_all(4).name]);
    %%
    all_run=[run1;run2;run3;run4];
    a=[ones(175,1);zeros(175,1);zeros(175,1);zeros(175,1)];
    b=[zeros(175,1);ones(175,1);zeros(175,1);zeros(175,1)];
    c=[zeros(175,1);zeros(175,1);ones(175,1);zeros(175,1)];
    run_regressor=[a,b,c];
    %%
    all_con=[run1_con;run2_con;run3_con;run4_con];
    x=175*2;
    all_con.onset(all_con.run==2)=all_con.onset(all_con.run==2)+x;
    all_con.onset(all_con.run==3)=all_con.onset(all_con.run==3)+2*x;
    all_con.onset(all_con.run==4)=all_con.onset(all_con.run==4)+3*x;
    %%
    multi_reg=dir([sub_dir,filesep,'multi_reg\sub*.tsv']);
    multi_reg_path=[sub_dir,filesep,'multi_reg'];
    rp_run1=tdfread([sub_dir,filesep,'multi_reg\',multi_reg(1).name]);
    multi_reg_run1=[rp_run1.rot_x,rp_run1.rot_y,rp_run1.rot_z,rp_run1.trans_x,rp_run1.trans_y,rp_run1.trans_z];
    rp_run2=tdfread([sub_dir,filesep,'multi_reg\',multi_reg(2).name]);
    multi_reg_run2=[rp_run2.rot_x,rp_run2.rot_y,rp_run2.rot_z,rp_run2.trans_x,rp_run2.trans_y,rp_run2.trans_z];
    rp_run3=tdfread([sub_dir,filesep,'multi_reg\',multi_reg(3).name]);
    multi_reg_run3=[rp_run3.rot_x,rp_run3.rot_y,rp_run3.rot_z,rp_run3.trans_x,rp_run3.trans_y,rp_run3.trans_z];
    rp_run4=tdfread([sub_dir,filesep,'multi_reg\',multi_reg(4).name]);
    multi_reg_run4=[rp_run4.rot_x,rp_run4.rot_y,rp_run4.rot_z,rp_run4.trans_x,rp_run4.trans_y,rp_run4.trans_z];
    
    multi_reg_all_run=[multi_reg_run1;multi_reg_run2;multi_reg_run3;multi_reg_run4];
    
    multi_reg_all=[multi_reg_all_run,run_regressor];
    cd (multi_reg_path)
    save multi_reg_all.txt multi_reg_all -ascii
 
    %%   
    matlabbatch{1}.spm.stats.fmri_spec.dir = {out_dir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 30;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 15;
    %%
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = cellstr(all_run);
    
    HSC = all_con.onset(string(all_con.trial_type) == 'e' & all_con.jiaocha_score >= 3);
    LSC = all_con.onset(string(all_con.trial_type) == 'e' & all_con.jiaocha_score < 3);
    tianchong = all_con.onset(string(all_con.trial_type) == 't');
    
    condition_all = [HSC;LSC;tianchong];
    condition_number = length(HSC)+length(LSC)+length(tianchong);
    
    condition_label={};
    condition_label(1:length(HSC),1)={'HSC'};
    condition_label(length(condition_label)+1:length(condition_label)+length(LSC),1)={'LSC'};
    condition_label(length(condition_label)+1:length(condition_label)+length(tianchong),1)={'tianchong'};
    condition_label(length(condition_label)+1:length(condition_label)+6+3,1)={'regressor'};
    
    for n_condi=1:condition_number
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(n_condi).name = ['trial_' num2str(n_condi)];
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(n_condi).onset = condition_all(n_condi); 
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(n_condi).duration = 6; 
    end
 
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg ={[multi_reg_path,filesep,'multi_reg_all.txt']};
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).hpf = 128;
    
    %%
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    
    %%
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    
    %%
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    null_contra = zeros(1,condition_number+6+3); 
    for n_contrast=1:(condition_number+9)
        matlabbatch{3}.spm.stats.con.consess{n_contrast}.tcon.name = ['contra_' num2str(n_contrast)];
        real_contra = null_contra;
        real_contra(1,n_contrast)=1;
        matlabbatch{3}.spm.stats.con.consess{n_contrast}.tcon.weights = real_contra;
        matlabbatch{3}.spm.stats.con.consess{n_contrast}.tcon.sessrep = 'none';
    end
    matlabbatch{3}.spm.stats.con.delete = 0;
    spm_jobman('run', matlabbatch);
    clear matlabbatch;
    
    
    cd(out_dir); 
    for n_spmt=1:(condition_number+9)
        if n_spmt<10
            orignal_name = ['spmT_000' num2str(n_spmt) '.nii'];
            movefile(orignal_name,[condition_label{n_spmt} 'spmT_000' num2str(n_spmt) '.nii'])
        elseif n_spmt<100
            orignal_name = ['spmT_00' num2str(n_spmt) '.nii'];
            movefile(orignal_name,[condition_label{n_spmt} 'spmT_00' num2str(n_spmt) '.nii'])
        else 
            orignal_name = ['spmT_0' num2str(n_spmt) '.nii'];
            movefile(orignal_name,[condition_label{n_spmt} 'spmT_0' num2str(n_spmt) '.nii'] )
        end
    end
    disp(['Stats 1st-level done: ' sub_dir]);
end
