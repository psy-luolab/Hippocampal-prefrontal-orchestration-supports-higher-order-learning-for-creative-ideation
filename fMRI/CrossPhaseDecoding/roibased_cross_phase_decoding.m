%% roi based cross-phase decoding
clear
clc
subject_ids={'sub-01';'sub-02';'sub-03';'sub-04';'sub-05';'sub-06';'sub-07';'sub-08';'sub-09';'sub-10';'sub-11';'sub-12';'sub-13';'sub-14';'sub-15';'sub-16';'sub-17';'sub-18';'sub-19';'sub-20';'sub-21';'sub-22';'sub-23';'sub-24';'sub-25';'sub-26';'sub-27';'sub-28';'sub-29';'sub-30';'sub-31';'sub-32';'sub-33';'sub-34';'sub-36';'sub-37';'sub-38';'sub-39';'sub-40'};

nsubjects=numel(subject_ids);

s2_path='...';  % creating
s1_path='...';  % learning

data_path='...';  % mask.nii

out_path='...';

mask_fn = '...';

mask_fn = '...';

allacc = [];
for i_subj=1:39
    subject_id=subject_ids{i_subj};
   % sub_path=fullfile(data_path,subject_id);
    sub_s2_path=fullfile(s2_path,subject_id);
    sub_s1_path=fullfile(s1_path,subject_id);
    %%
      output_path=fullfile(out_path,subject_id);
     if ~exist(output_path)
        mkdir(output_path);
    end
    %% hscÌõ¼þµÄsearchlight

    data_HSC=fullfile(sub_s2_path,'glm_HSC.nii');
    ds_hsc_s2=cosmo_fmri_dataset(data_HSC,'mask',mask_fn);
    % 
    data_hsc_fn=fullfile(sub_s1_path,'glm_HSC.nii');
    ds_hsc_s1=cosmo_fmri_dataset(data_hsc_fn,'mask',mask_fn);
    
    data_HSC=fullfile(sub_s2_path,'glm_LSC.nii');
    ds_lsc_s2=cosmo_fmri_dataset(data_HSC,'mask',mask_fn);
    
    data_hsc_fn=fullfile(sub_s1_path,'glm_LSC.nii');
    ds_lsc_s1=cosmo_fmri_dataset(data_hsc_fn,'mask',mask_fn);

    all_ds_train=cosmo_stack({ds_hsc_s1,ds_lsc_s1});
    all_ds_test=cosmo_stack({ds_hsc_s2,ds_lsc_s2});
   
    ds = cosmo_stack({all_ds_train,all_ds_test});
    
    measure_args = struct();  
    measure = @use_svm;
    
    [a,b]=size(ds_hsc_s1.samples);
    measure_args.s1_H=a;
    [c,d]=size(ds_lsc_s1.samples);
    measure_args.s1_L=c;
    [e,f]=size(ds_hsc_s2.samples);
    measure_args.s2_H=e;
    [g,h]=size(ds_lsc_s2.samples);
    measure_args.s2_L=g;
    %%
   
ds=cosmo_remove_useless_data(ds);
%% set the targets and chunks
ds.sa.targets = [ones(measure_args.s1_H,1);ones(measure_args.s1_L,1)+1;ones(measure_args.s2_H,1);ones(measure_args.s2_L,1)+1];   
ds.sa.chunks = [ones(measure_args.s1_H+measure_args.s1_L,1);ones(measure_args.s2_H+measure_args.s2_L,1)+1]; 
% 
x=cosmo_nfold_partitioner(ds);
aa=cosmo_balance_partitions(x,ds,'nmin',1);
counter=1;

for m=1:length(aa.train_indices)
    
   if aa.train_indices{1,m}(1,1)==1
    train=cosmo_slice(ds,aa.train_indices{1,m}',1);
    test=cosmo_slice(ds,aa.test_indices{1,m}',1);
    pred = cosmo_classify_svm(train.samples, train.sa.targets, test.samples);
    acc0 = mean(test.sa.targets == pred);
    myacc(counter,1)=acc0;
    counter=counter+1;
   end
end
allacc = [allacc;mean(myacc)-0.5];

end

[h,p,ci,stas]=ttest(allacc)

save data

