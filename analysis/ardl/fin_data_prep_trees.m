clear; clc; close all
set(0,'DefaultFigureWindowStyle','docked')

%% get long threads
load d_basic2
longtrees=unique(d_basic.tree_nr(d_basic.tree_max4>=50));
path="D:\Dropbox\SFI Reconquista\00 strategies\analyses\trees50\";
for i=1:length(longtrees)    
    writetable(d_basic(d_basic.tree_nr==longtrees(i),:),[path + 'd_basic_50_' + num2str(i) + '.xlsx']); % for stata
end
