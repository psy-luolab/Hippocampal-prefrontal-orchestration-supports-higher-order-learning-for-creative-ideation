
clear; clc;
spm_jobman('initcfg');
spm('defaults', 'fMRI');
data_dir = 'E:\gjxx2\FLXX_2\First_level\pre_proc_encoding_phase';
sublist = dir([data_dir,'\sub*']);
%%
for nsub=37:39   

    if nsub==16
        sub_dir = [data_dir,filesep,sublist(nsub).name];
    %-----------------------------------------------------------------------
    out_dir = ['H:\GJXX_2_reanalysis\C\First_level\condition_hl\',sublist(nsub).name]; %
    
    if ~exist(out_dir)
        mkdir(out_dir);
    end
    %%
    run1 = spm_select('ExtFPList', fullfile(sub_dir,'run1'),'smooth.*\.nii$');%
    run2 = spm_select('ExtFPList', fullfile(sub_dir,'run2'),'smooth.*\.nii$');
    run3 = spm_select('ExtFPList', fullfile(sub_dir,'run3'),'smooth.*\.nii$');
    run4 = spm_select('ExtFPList', fullfile(sub_dir,'run4'),'smooth.*\.nii$');
    run5 = spm_select('ExtFPList', fullfile(sub_dir,'run5'),'smooth.*\.nii$');
    %%
    run_con_all = dir([sub_dir,filesep,'condition_C_median_inner_divide\sub*.txt']);%
    run1_con=readtable([sub_dir,filesep,'condition_C_median_inner_divide\',run_con_all(1).name]);
    run2_con=readtable([sub_dir,filesep,'condition_C_median_inner_divide\',run_con_all(2).name]);
    run3_con=readtable([sub_dir,filesep,'condition_C_median_inner_divide\',run_con_all(3).name]);
    run4_con=readtable([sub_dir,filesep,'condition_C_median_inner_divide\',run_con_all(4).name]);
    run5_con=readtable([sub_dir,filesep,'condition_C_median_inner_divide\',run_con_all(5).name]);
    
    all_run=[run1;run2;run3;run4;run5];

    
    %%
    all_con=[run1_con;run2_con;run3_con;run4_con;run5_con];
    x=132*2;
    all_con.onset(all_con.run_data==2)=all_con.onset(all_con.run_data==2)+x;
    all_con.onset(all_con.run_data==3)=all_con.onset(all_con.run_data==3)+2*x;
    all_con.onset(all_con.run_data==4)=all_con.onset(all_con.run_data==4)+3*x;
    all_con.onset(all_con.run_data==5)=all_con.onset(all_con.run_data==5)+4*x;
    
    %%
   
    multi_reg_path=[sub_dir,filesep,'rp'];
  
    %% para
    matlabbatch{1}.spm.stats.fmri_spec.dir = {out_dir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 30;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 15;
    %%
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = cellstr(all_run);
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).name = 'NA-HSC';
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).onset = all_con.onset(string(all_con.trial_type)=='NA'& all_con.cat==1);
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).duration = 6;
   
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).name = 'NA-LSC';
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).onset = all_con.onset(string(all_con.trial_type)=='NA'& all_con.cat==0);
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).duration = 6;
   
    
      matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).name = 'all_other';
     matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).onset = all_con.onset(string(all_con.trial_type)~='NA');
     matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).duration = 6;
     
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
    
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'NA-HSC'; %hsc na
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1,0,0];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'NA-LSC'; % lsc na
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0,1,0];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

    
    matlabbatch{3}.spm.stats.con.delete = 0;
    spm_jobman('run', matlabbatch);
    clear matlabbatch;
    disp(['Stats 1st-level done: ' sub_dir]);
    
    elseif nsub==37
        
        sub_dir = [data_dir,filesep,sublist(nsub).name];
    %-----------------------------------------------------------------------
    out_dir = ['H:\GJXX_2_reanalysis\C\First_level\condition_hl\',sublist(nsub).name]; %
    
    if ~exist(out_dir)
        mkdir(out_dir);
    end
    %%
    run1 = spm_select('ExtFPList', fullfile(sub_dir,'run1'),'smooth.*\.nii$');%
    run2 = spm_select('ExtFPList', fullfile(sub_dir,'run2'),'smooth.*\.nii$');
    run3 = spm_select('ExtFPList', fullfile(sub_dir,'run3'),'smooth.*\.nii$');
    run4 = spm_select('ExtFPList', fullfile(sub_dir,'run4'),'smooth.*\.nii$');
    run5 = spm_select('ExtFPList', fullfile(sub_dir,'run5'),'smooth.*\.nii$');
    %%
    run_con_all = dir([sub_dir,filesep,'condition_C_median_inner_divide\sub*.txt']);%
    run1_con=readtable([sub_dir,filesep,'condition_C_median_inner_divide\',run_con_all(1).name]);
    run2_con=readtable([sub_dir,filesep,'condition_C_median_inner_divide\',run_con_all(2).name]);
    run3_con=readtable([sub_dir,filesep,'condition_C_median_inner_divide\',run_con_all(3).name]);
    run4_con=readtable([sub_dir,filesep,'condition_C_median_inner_divide\',run_con_all(4).name]);
    run5_con=readtable([sub_dir,filesep,'condition_C_median_inner_divide\',run_con_all(5).name]);
    
    all_run=[run1;run2;run3;run4;run5];

    
    %%
    all_con=[run1_con;run2_con;run3_con;run4_con;run5_con];
    x=132*2;
    all_con.onset(all_con.run_data==2)=all_con.onset(all_con.run_data==2)+x;
    all_con.onset(all_con.run_data==3)=all_con.onset(all_con.run_data==3)+2*x;
    all_con.onset(all_con.run_data==4)=all_con.onset(all_con.run_data==4)+3*x;
    all_con.onset(all_con.run_data==5)=all_con.onset(all_con.run_data==5)+4*x;
    
    %%
   
    multi_reg_path=[sub_dir,filesep,'rp'];
  
    %% para
    matlabbatch{1}.spm.stats.fmri_spec.dir = {out_dir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 30;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 15;
    %%
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = cellstr(all_run);
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).name = 'NA-HSC';
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).onset = all_con.onset(string(all_con.trial_type)=='NA'& all_con.cat==1);
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).duration = 6;
   
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).name = 'NA-LSC';
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).onset = all_con.onset(string(all_con.trial_type)=='NA'& all_con.cat==0);
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).duration = 6;
    
      matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).name = 'all_other';
     matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).onset = all_con.onset(string(all_con.trial_type)~='NA');
     matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).duration = 6;
     
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
    
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'NA-HSC'; %hsc na
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1,0,0];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'NA-LSC'; % lsc na
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0,1,0];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

    
    matlabbatch{3}.spm.stats.con.delete = 0;
    spm_jobman('run', matlabbatch);
    clear matlabbatch;
    disp(['Stats 1st-level done: ' sub_dir]);
    %
   else
    
    sub_dir = [data_dir,filesep,sublist(nsub).name];
    %-----------------------------------------------------------------------
    out_dir = ['H:\GJXX_2_reanalysis\C\First_level\condition_hl\',sublist(nsub).name]; %
    
    if ~exist(out_dir)
        mkdir(out_dir);
    end
    %%
    run1 = spm_select('ExtFPList', fullfile(sub_dir,'run1'),'smooth.*\.nii$');%
    run2 = spm_select('ExtFPList', fullfile(sub_dir,'run2'),'smooth.*\.nii$');
    run3 = spm_select('ExtFPList', fullfile(sub_dir,'run3'),'smooth.*\.nii$');
    run4 = spm_select('ExtFPList', fullfile(sub_dir,'run4'),'smooth.*\.nii$');
    run5 = spm_select('ExtFPList', fullfile(sub_dir,'run5'),'smooth.*\.nii$');
    %%
    run_con_all = dir([sub_dir,filesep,'condition_C_median_inner_divide\sub*.txt']);%
    run1_con=readtable([sub_dir,filesep,'condition_C_median_inner_divide\',run_con_all(1).name]);
    run2_con=readtable([sub_dir,filesep,'condition_C_median_inner_divide\',run_con_all(2).name]);
    run3_con=readtable([sub_dir,filesep,'condition_C_median_inner_divide\',run_con_all(3).name]);
    run4_con=readtable([sub_dir,filesep,'condition_C_median_inner_divide\',run_con_all(4).name]);
    run5_con=readtable([sub_dir,filesep,'condition_C_median_inner_divide\',run_con_all(5).name]);
    
    all_run=[run1;run2;run3;run4;run5];

    %%
    all_con=[run1_con;run2_con;run3_con;run4_con;run5_con];
    x=132*2;
    all_con.onset(all_con.run_data==2)=all_con.onset(all_con.run_data==2)+x;
    all_con.onset(all_con.run_data==3)=all_con.onset(all_con.run_data==3)+2*x;
    all_con.onset(all_con.run_data==4)=all_con.onset(all_con.run_data==4)+3*x;
    all_con.onset(all_con.run_data==5)=all_con.onset(all_con.run_data==5)+4*x;
    
    %%
   
    multi_reg_path=[sub_dir,filesep,'rp'];
  
    %% para
    matlabbatch{1}.spm.stats.fmri_spec.dir = {out_dir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 30;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 15;
    %%
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = cellstr(all_run);
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).name = 'NA-HSC';
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).onset = all_con.onset(string(all_con.trial_type)=='NA'& all_con.cat==1);
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(1).duration = 6;
   
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).name = 'NA-LSC';
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).onset = all_con.onset(string(all_con.trial_type)=='NA'& all_con.cat==-1);
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(2).duration = 6;
   
     matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).name = 'NA_median';
     matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).onset = all_con.onset(string(all_con.trial_type)=='NA'& all_con.cat==0);
     matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(3).duration = 6;
    
      matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).name = 'all_other';
     matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).onset = all_con.onset(string(all_con.trial_type)~='NA');
     matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(4).duration = 6;
     
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
    
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'NA-HSC'; %hsc na
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1,0,0,0];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'NA-LSC'; % lsc na
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0,1,0,0];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

    
    matlabbatch{3}.spm.stats.con.delete = 0;
    spm_jobman('run', matlabbatch);
    clear matlabbatch;
    disp(['Stats 1st-level done: ' sub_dir]);

    end
end
