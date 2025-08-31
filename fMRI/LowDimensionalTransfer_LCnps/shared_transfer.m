% LC-nps in PCA space
% the code first fit learning data into a pca space, then transform
% creating data into the same space, then compute LC-nps between PCs


clear;clc;
subjects = {'sub-01';'sub-02';'sub-03';'sub-04';'sub-05';'sub-06';'sub-07';'sub-08';'sub-09';'sub-10';'sub-11';'sub-12';'sub-13';'sub-14';'sub-15';'sub-16';'sub-17';'sub-18';'sub-19';'sub-20';'sub-21';'sub-22';'sub-23';'sub-24';'sub-25';'sub-26';'sub-27';'sub-28';'sub-29';'sub-30';'sub-31';'sub-32';'sub-33';'sub-34';'sub-36';'sub-37';'sub-38';'sub-39';'sub-40'};
masks = {'Hippocampus_L.nii'};

s1_path='H:\GJXX_2_reanalysis\C\First_level\S1\rsa';
s2_path='H:\GJXX_2_reanalysis\C\First_level\S2\rsa';

roi_path='...\mask';
n_subjects = numel(subjects);
n_masks = numel(masks);

counterp = 0;
alldata = [];

%%
for EV = 70:90

    counter = 0;

    for s = 1:length(subjects)

        sub = subjects{s};
        sub_s1_path=fullfile(s1_path,sub);
        sub_s2_path=fullfile(s2_path,sub);
        mask1_fn=fullfile(roi_path,masks{1});

        %%
        S1data_HSC=fullfile(sub_s1_path,'glm_HSC_NA.nii');
        S1ds_HSC=cosmo_fmri_dataset(S1data_HSC,'mask',mask1_fn);
        S1data_LSC=fullfile(sub_s1_path,'glm_LSC_NA.nii');
        S1ds_LSC=cosmo_fmri_dataset(S1data_LSC,'mask',mask1_fn);
        S2data_HSC=fullfile(sub_s2_path,'glm_HSC_NA.nii');
        S2ds_HSC=cosmo_fmri_dataset(S2data_HSC,'mask',mask1_fn);
        S2data_LSC=fullfile(sub_s2_path,'glm_LSC_NA.nii');
        S2ds_LSC=cosmo_fmri_dataset(S2data_LSC,'mask',mask1_fn);

        %%
        input =S1ds_HSC.samples';
        [coeff,score,~,~,explained,~]=pca(input);

        total_explained=0;

        for m = 1:length(explained)
            total_explained = total_explained + explained(m);
            if total_explained > EV
                break
            end
        end

        num_pcs = m;

        predict = S2ds_HSC.samples';
        predict_score = (predict - mean(predict))/ coeff';
        generation_score  = predict_score(:,1:num_pcs);
        learning_score = score(:,1:num_pcs);


        %%
        my_r_hsc = 0;
        for x = 1:size(generation_score,2)
            rallhsc=0;
            for y =1:size(learning_score,2)
                r = corr(generation_score(:,x),learning_score(:,y),'Type','Spearman');
                rallhsc = rallhsc+r;
            end

            my_r_hsc= my_r_hsc + rallhsc/size(generation_score,2);
        end

        %%
        input =S1ds_LSC.samples';
        [coeff,score,~,~,explained,mu]=pca(input);

        total_explained=0;

        for m = 1:length(explained)
            total_explained = total_explained + explained(m);
            if total_explained > EV
                break
            end
        end

        num_pcs = m;

        predict = S2ds_LSC.samples';
        predict_score = (predict - mean(predict))/ coeff';

        generation_score  = predict_score(:,1:num_pcs);
        learning_score = score(:,1:num_pcs);
        %%
        my_r_lsc = 0;
        for x = 1:size(generation_score,2)
            ralllsc=0;
            for y =1:size(learning_score,2)
                r = corr(generation_score(:,x),learning_score(:,y),'Type','Spearman');
                ralllsc = ralllsc+r;
            end
            %
            my_r_lsc= my_r_lsc + ralllsc/size(generation_score,2);
        end

        %%
        counter = counter + 1;
        H_r(counter,:) = my_r_hsc;
        L_r(counter,:) = my_r_lsc;

    end

    [h,p,ci,stats] = ttest(H_r,L_r);
    counterp = counterp + 1;
    alldata = [alldata,H_r,L_r];
    allp(counterp,:) = p;

end

