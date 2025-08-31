%Between-subject analysis of the relationship between representational dimensionality and subsequent creativity
%Implements combined analysis of Exp. 1 and Exp. 2.

subjects = {'sub-01';'sub-02';'sub-03';'sub-04';'sub-05';'sub-06';'sub-07';'sub-08';'sub-09';'sub-10';'sub-11';'sub-12';'sub-13';'sub-14';'sub-15';'sub-16';'sub-17';'sub-18';'sub-19';'sub-20';'sub-21';'sub-22';'sub-23';'sub-24';'sub-25';'sub-26';'sub-27';'sub-28';'sub-29';'sub-30';'sub-31';'sub-32';'sub-33';'sub-34';'sub-36';'sub-37';'sub-38';'sub-39';'sub-40'};
masks = {'.nii'};% hpc IFG control
study_path='...';
roi_path='...';
kkk = 80;
true_length = 20; 
n_masks=numel(masks);
msk = masks{1};
counter=0;

for s = 1:length(subjects)
    %%
    sub = subjects{s};
    sub_path = fullfile(study_path,sub);
    mask_fn = fullfile(roi_path,msk);   
    %%
     
    %%
    data = fullfile(sub_path,'glm_T_NA.nii');
    ds = cosmo_fmri_dataset(data,'mask',mask_fn);
    d = ds.samples';
    allrd = 0;
    
  for x = 1:100
    ddd = d(:,randperm(size(d,2),true_length));
    [coeff,score,latent,tsquared,explained,mu] = pca(ddd);
    total_explained = 0;
    RDvar = 0;
    
    for n = 1:length(explained)
        total_explained=total_explained+explained(n);
        if total_explained > kkk
            break
        end
    end
    
    RDvar = n;
    allrd = allrd + RDvar;
  end
    
    counter = counter+1; 
    RD(counter,:) = allrd/100;
end

beh = importdata('...');

y1 = beh(:, 1);

x1 = RD;
%%
subjects = {'sub02';'sub03';'sub04';'sub05';'sub06';'sub07';'sub08';'sub09';'sub10';'sub11';'sub12';'sub13';'sub14';'sub15';'sub17';'sub18';'sub19';'sub20';'sub21';'sub25';'sub28';'sub29';'sub30'};
study_path='...';

counter=0;

for s = 1:length(subjects)
    %%
    sub = subjects{s};
    sub_path = fullfile(study_path,sub);
    mask_fn = fullfile(roi_path,msk);
    %%
    data = fullfile(sub_path,'glm_T_allexamples.nii');
    ds = cosmo_fmri_dataset(data,'mask',mask_fn);
    d = ds.samples';
    allrd = 0;
    for x = 1:100
        ddd = d(:,randperm(size(d,2),true_length));
    [coeff,score,latent,tsquared,explained,mu] = pca(ddd);
    total_explained = 0;
    RDvar = 0;
    
    for n = 1:length(explained)
        total_explained=total_explained+explained(n);
        if total_explained > kkk
            break
        end
    end
    
    RDvar = n;
    allrd = allrd + RDvar;
    
    end
    
    
    
    counter = counter+1;
    
    RD1(counter,:) = allrd/100;
    
end
beh = importdata('...');% 
y = beh(:, 1);
x = RD1;

x=[x;x1];
y=[y;y1];

[h,p] = corr(x,y)

% Create a scatter plot
scatter(x, y, 'filled');
hold on; % Keep the plot open for adding additional elements

% Fit a line to the data using polyfit
p = polyfit(x, y, 1); % Fit a first-degree polynomial (a line)
xfit = linspace(min(x), max(x), 100); % Generate x values for the line
yfit = polyval(p, xfit); % Calculate y values for the line using the coefficients from polyfit

% Plot the line
plot(xfit, yfit, 'r', 'LineWidth', 2); % Plotting in red with a thicker line

% Add labels and title
xlabel('X-axis');
ylabel('Y-axis');
title('Scatter Plot with Fitted Line');

% Turn off hold to reset plotting behavior
hold off;


