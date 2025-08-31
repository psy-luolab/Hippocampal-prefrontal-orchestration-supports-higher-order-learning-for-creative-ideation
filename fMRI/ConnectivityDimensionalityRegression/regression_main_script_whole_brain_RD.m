mydir = '...';
image_names = filenames(fullfile(mydir, 'o*nii'), 'absolute'); 
image_obj = fmri_data(image_names); 
%%
beh = importdata('rd_d_left.txt');% 
zichuangC = beh(:, 1);  
mask = '...\HIP_PFC_connectivity_modulates_HIP_infomation\greymatter.nii';   

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
t = threshold(out.t, .05, 'fdr','k',5);
t = select_one_image(t, 1);
t.fullpath = fullfile(pwd, 'fdr_rd_leftifg_rank.nii');

%%

% t = threshold(out.t, .005, 'unc','k',5);
% t = select_one_image(t, 1);
% t.fullpath = fullfile(pwd, 'rd_ifg_p005k5.nii');
write(t,'overwrite')

% o2 = montage(t, 'trans', 'full');
% o2 = title_montage(o2, 2, '0.005 unc');
% snapnow

r = region(t);     
table(r);    

%Make a montage showing each significant region
montage(r, 'colormap', 'regioncenters');


