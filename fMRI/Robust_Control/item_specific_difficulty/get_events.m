clear; clc;
onset_dir='E:\FLDATA_analysis\newdata_to_use';
onsetlist=dir([onset_dir,'\sub*']);
all_frequency = 0;

for nsub=1:length(onsetlist)
    sub_onset = [onset_dir,filesep,onsetlist(nsub).name];
    run_con_all = dir([sub_onset,filesep,'sub*.txt']);
    run1_con=readtable([sub_onset,filesep,run_con_all(1).name]);
    run2_con=readtable([sub_onset,filesep,run_con_all(2).name]);
    run3_con=readtable([sub_onset,filesep,run_con_all(3).name]);
    run4_con=readtable([sub_onset,filesep,run_con_all(4).name]);
    
    allcon = [run1_con;run2_con;run3_con;run4_con];
    allcon = sortrows(allcon,5);
    frequency = allcon.condition_median_jiaocha_1(string(allcon.trial_type)== 'e');
    
    all_frequency = all_frequency + frequency;
        
end
data = 1:100;
data = [reshape(data,100,1),all_frequency];
data =  sortrows(data,2);
S = std(data(:,2));
M = mean(data(:,2));

pic = data(:,1);
too_low = pic(data(:,2)< M-S);
too_high = pic(data(:,2)> M+S);


%%%%方法：将上面选出的pic num对应的类型改成t，然后再进行分析


save_path = 'H:\GJXX_1_reanalysis\no_too_easyorhard_item\events';
for nsub=1:length(onsetlist)
    
    path = [save_path,filesep,onsetlist(nsub).name];
    
    if ~exist(path)
        mkdir(path);
    end
    
    sub_onset = [onset_dir,filesep,onsetlist(nsub).name];
    run_con_all = dir([sub_onset,filesep,'sub*.txt']);
    run1_con=readtable([sub_onset,filesep,run_con_all(1).name]);
    run2_con=readtable([sub_onset,filesep,run_con_all(2).name]);
    run3_con=readtable([sub_onset,filesep,run_con_all(3).name]);
    run4_con=readtable([sub_onset,filesep,run_con_all(4).name]);
    
    allcon = [run1_con;run2_con;run3_con;run4_con];
    allcon = sortrows(allcon,5);
   
    allcon.trial_type(ismember(allcon.pic_num,too_low))= {'t'};
    allcon.trial_type(ismember(allcon.pic_num,too_high))= {'t'};
    allcon = sortrows(allcon,1);
    
    for run = 1:4
        runcon = allcon(30*(run-1)+1:30*run,:);
        name = strcat(onsetlist(nsub).name,'_run-',num2str(run),'_events.txt');
        save_fn = [path,filesep,name];
        writetable(runcon,save_fn,'FileType','text','Delimiter','\t');
    end
 
end




