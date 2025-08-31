%ROI activation comparison during creation phase (HSC vs LSC)in the creation phase of Exp. 2
%Assesses whether exemplar memory interferes with independent creative ideation
%by comparing activation in:
%- Dorsolateral prefrontal cortex (DLPFC)
%- Anterior cingulate cortex (ACC)
%- Insula
%Between HSC and LSC conditions. 

clear
clc
mask = fmri_mask_image('...Insula_R_AAL.nii'); %
mydir = '...\Phase2\Beta\First_level\results';  % 
%% NA beta

image_names = filenames(fullfile(mydir, 'con_0001*nii'), 'absolute');
image_obj = fmri_data(image_names); 
beta_hsc = extract_roi_averages(image_obj, mask);

image_names_lsc = filenames(fullfile(mydir, 'con_0004*nii'), 'absolute');
image_obj_lsc = fmri_data(image_names_lsc); 
beta_lsc = extract_roi_averages(image_obj_lsc, mask);

[h,p,t,stats]=ttest(beta_hsc.dat,beta_lsc.dat)

HSC=beta_hsc.dat;
LSC=beta_lsc.dat;

