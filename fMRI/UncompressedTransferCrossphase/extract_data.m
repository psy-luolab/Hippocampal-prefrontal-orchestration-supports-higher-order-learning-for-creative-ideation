% extract data from the results of learning-creating pattern similarity in neural space

clear
clc
mask = fmri_mask_image('...\aHPC_L.nii'); % HPC,IFG
mydir = '...';
%%
image_names_hsc = filenames(fullfile(mydir, 'HSC*nii'), 'absolute'); 
image_obj_hsc = fmri_data(image_names_hsc); 
hsc = extract_roi_averages(image_obj_hsc, mask);
HSC=hsc.dat;
%%
image_names_lsc = filenames(fullfile(mydir, 'LSC*nii'), 'absolute'); 
image_obj_lsc = fmri_data(image_names_lsc); 
lsc = extract_roi_averages(image_obj_lsc, mask);
LSC=lsc.dat;
%%
[h,p,ci,stats]=ttest(HSC,LSC);


