mydir = '...';
image_names = filenames(fullfile(mydir, 'o*nii'), 'absolute'); 
image_obj = fmri_data(image_names); 
%%
beh = importdata('rd_d_left.txt');% 
zichuangC = beh(:, 1);  

mask = '...\IFG_L.nii';
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
t = threshold(out.t, .05, 'fdr','k',1);
t = select_one_image(t, 1);
t.fullpath = fullfile(pwd, 'fdrdata_ifg.nii');
%%
write(t,'overwrite')

r = region(t);     
table(r);    

montage(r, 'colormap', 'regioncenters');


