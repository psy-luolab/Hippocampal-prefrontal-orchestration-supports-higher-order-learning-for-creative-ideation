mydir = '...';
image_names = filenames(fullfile(mydir, 'rdvar*nii'), 'absolute'); 
image_obj = fmri_data(image_names); 
%%
beh = importdata('CY.txt'); 
zichuangC = beh(:, 1);  
mask = '...\rd_regression\scripts\greymatter.nii';    
maskdat = fmri_data(mask, 'noverbose');
%%
image_obj = apply_mask(image_obj, maskdat);
image_obj = rescale(image_obj, 'rankvoxels'); 
%%
image_obj.X = scale(zichuangC, 1);
image_obj.X = scale(rankdata(image_obj.X), 1);
%%
tic
out = regress(image_obj, 'robust');
toc
%
% t = threshold(out.t, .05, 'fdr');
% t = select_one_image(t, 1);
% t.fullpath = fullfile(pwd, 'pred_FDR05.nii');
% write(t)
%%
% 
t = threshold(out.t, .05, 'unc','k',5);
t = select_one_image(t, 1);
t.fullpath = fullfile(pwd, 'rd_05.nii');
write(t,'overwrite')

r = region(t);     
table(r);    


%Make a montage showing each significant region
montage(r, 'colormap', 'regioncenters');


