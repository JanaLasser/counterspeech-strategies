clear; clc; close all
set(0,'DefaultFigureWindowStyle','normal')
set(0,'defaultTextInterpreter','none') % 'latex'


%% colors
% Siena
colors(1,:)=[235 156 30];
colors(2,:)=[30 30 235];
colors(3,:)=[235 71 30];
colors(4,:)=[30 160 235];


% paper
colors(1,:)=[220 184 30];
colors(2,:)=[84 120 197];
colors(3,:)=[240 76 99];
colors(4,:)=[147 207 235];

colors_lag1(1,:)=[220 184 30];
colors_lag1(2,:)=[84 120 197];
colors_lag1(3,:)=[240 76 99];
colors_lag1(4,:)=[147 207 235];

colors_lag2(1,:)=[220 184 30];
colors_lag2(2,:)=[84 120 197];
colors_lag2(3,:)=[240 76 99];
colors_lag2(4,:)=[147 207 235];

pos = [1.0000    1.0000  943.2000  366.0000];

%% RG and RI icons
clear rgpic
rgpic{3}=imread('C:\Users\mirta\Dropbox\SFI Reconquista\00 strategies\analyses\RG_icon3r.png');
ripic{3}=imread('C:\Users\mirta\Dropbox\SFI Reconquista\00 strategies\analyses\RI_icon3r.png');

rgpic{1}=imread('C:\Users\mirta\Dropbox\SFI Reconquista\00 strategies\analyses\RG_icon3o.png');
ripic{1}=imread('C:\Users\mirta\Dropbox\SFI Reconquista\00 strategies\analyses\RI_icon3o.png');

rgpic{2}=imread('C:\Users\mirta\Dropbox\SFI Reconquista\00 strategies\analyses\RG_icon3b.png');
ripic{2}=imread('C:\Users\mirta\Dropbox\SFI Reconquista\00 strategies\analyses\RI_icon3b.png');

rgpic{4}=imread('C:\Users\mirta\Dropbox\SFI Reconquista\00 strategies\analyses\RG_icon3s.png');
ripic{4}=imread('C:\Users\mirta\Dropbox\SFI Reconquista\00 strategies\analyses\RI_icon3s.png');

%% interactions rg, ri
clear ints
ints{1}(:,1)=[0 -1 -1 0 0 1 0 0 0 0 0 0];
ints{1}(:,2)=[0 -1 0 0 0 1 0 0 0 0 0 0];

ints{3}(:,1)=[0 -1 0 0 0 1 0 0 0 0 0 0];
ints{3}(:,2)=[0 -1 0 0 1 1 -1 1 0 0 0 -1];

ints{2}(:,1)=[0 -1 0 0 0 1 0 0 0 0 0 1];
ints{2}(:,2)=[0 0 0 1 1 0 0 0 0 0 0 0];

ints{4}(:,1)=[0 0 -1 0 0 0 0 0 0 0 0 0];
ints{4}(:,2)=[0 0 0 1 0 0 0 0 0 0 0 0];


%% plot results by days - prep
pathreg="C:\Users\mirta\Dropbox\SFI Reconquista\00 strategies\analyses\";
bydayres={"reg_byday_joint_tox_rob.csv","reg_byday_joint_extsp_rob.csv",...
    "reg_byday_joint_hate_rob.csv","reg_byday_joint_extind_rob.csv"};

titles={'Toxicity';'Extremity of speech';'Hate speech'; ...
    'Extremity of speakers'};

for f=1 :length(bydayres)
    f
    [NUM,TXT,RAW]=xlsread([pathreg + bydayres{f}]);
    j=1;
    for i=1:length(TXT)
        if length(cell2mat(TXT(i,1)))>1
            vars{f}{j,:}=cell2mat(TXT(i,1));
            try; dayres{f}(j,1)=str2num(cell2mat(TXT(i,2))); end
            try; dayres{f}(j,2)=str2num(cell2mat(TXT(i+1,2))); end
            j=j+1;
        end
    end
    dayres{f}(:,3)=dayres{f}(:,1)-1.96*dayres{f}(:,2);
    dayres{f}(:,4)=dayres{f}(:,1)+1.96*dayres{f}(:,2);
    dayres{f}(sum(dayres{f},2)==0,:)=[];
    vars{f}(length(dayres{f}))={'cons'};
    vars{f}(length(dayres{f})+1:end)=[];
    
    for ii=1:length(vars{f})
        vars{f}{ii}=strrep(vars{f}{ii},'L.','L1.');
    end
end

clear mats
%types={'zee','D','LD','rgi2_','rgi3_','dbd','cons','rgi2','rgi3'};
types={'zee','L1','L2','rgi2_','rgi3_','dbd','cons','rgi2','rgi3'};

for f=1:length(bydayres)
    
    if f==1; a='_tox'; b='Toxicity'; elseif f==2; a='_extreme_score'; b='Extreme speech';
    elseif f==3; a='_hate'; b='Hate speech'; elseif f==4; a='_user_group_70e'; b='Extreme speakers'; end
    
    vs{f}={a;'_strategy_opin';'_strategy_sarc';'_strategy_construct';'_goal2_out_negative';...
        '_goal2_in_both_pos';'_anger';'_fear';'_disgust';'_sadness';'_enthop';'_prijoy'};
    vnames{f}={b;'Opinion';'Sarcasm';'Constructive';'Excl.outgroup';...
        'Incl.in/both groups';'Anger';'Fear';'Disgust';'Sadness';'Enthusiasm/Hope';'Pride/Joy'};
    
    for t=1:5
        mats{f,t}=table();
        
        temp=vars{f}(startsWith(vars{f},types{t}));
        indices=[];
        for v=1:length(vs{f})
            if sum(contains(temp,vs{f}{v}))==1
                indices=[indices v];
            end
        end
        
        mats{f,t}{:,1}=vs{f}; %vars{f}(startsWith(vars{f},types{t}));
        mats{f,t}{indices,2:5}=dayres{f}(startsWith(vars{f},types{t}),1:4);
        
    end
    
    mats{f,6}=table();
    mats{f,6}{:,1}={'RG','RG&RI','day','cons'}';
    mats{f,6}{:,2:5}=dayres{f}(strcmp(vars{f},'dbd_dayn') | strcmp(vars{f},'rgi2') | ...
        strcmp(vars{f},'rgi3') | strcmp(vars{f},'cons'),1:4);
    
    tables_export{f}=table();
    tables_export{f}.Variable=vars{f};
    tables_export{f}.Effect=dayres{f}(:,1);
    tables_export{f}.Robust_SE=dayres{f}(:,2);
    writetable(tables_export{f},'table_day.xlsx','Sheet',f)
    
end

%% fix mats to show only robustly sig lags
matsr=mats;
for f=1:4
    matsr{f,2}{mats{f,2}{:,4}<0 & mats{f,2}{:,5}>0,2:5}=0;
    matsr{f,3}{mats{f,3}{:,4}<0 & mats{f,3}{:,5}>0,2:5}=0;
end

%% figure - 4 subplots with lags
close all
vmax=12;

fpos=[2 3 1 4];

figure('Position', pos)
t = tiledlayout(1, 4, 'TileSpacing', 'compact');

for f=1:4
    %subplot(1,4,fpos(f))
    nexttile(fpos(f));
    
    % direct effects
    j=rescale(1:vmax,1,vmax*3-2);
    for i=2:height(matsr{f,1})
        if matsr{f,1}{i,2}~=0
            line(matsr{f,1}{i,4:5},[j(i) j(i)],'linewidth',3,'color',colors(f,:)/255); hold on
            plot(matsr{f,1}{i,2},j(i),'+', 'MarkerSize', 8, 'color',colors(f,:)/255); hold on
        end
    end
    hold on
    
    % lag1
    j=rescale(1:vmax,2,vmax*3-1);
    for i=2:height(matsr{f,2})
        if ints{f}(i,1)~=0; image(rgpic{f}, ...
                'XData', [ints{f}(i,1)*(abs(ints{f}(i,1))-.15) ints{f}(i,1)*(abs(ints{f}(i,1))-.15)+.15], ...
                'YData', [j(i)-.8 j(i)+.5]); hold on; end
        if ints{f}(i,2)~=0; image(ripic{f}, ...
                'XData', [ints{f}(i,2)*(abs(ints{f}(i,2))-.32) ints{f}(i,2)*(abs(ints{f}(i,2))-.32)+.15], ...
                'YData', [j(i)-.8 j(i)+.5]); hold on; end
        
        if matsr{f,2}{i,2}~=0
            line(matsr{f,2}{i,4:5},[j(i) j(i)],'linewidth',3,'color',[colors(f,:)/255 .6]); hold on
            plot(matsr{f,2}{i,2},j(i),'+', 'MarkerSize', 8, 'color',[colors(f,:)/255 .6]);  hold on
        end
    end
    hold on
    
    % lag2
    j=rescale(1:vmax,3,vmax*3);
    for i=2:height(matsr{f,3})
        if matsr{f,3}{i,2}~=0
            line(matsr{f,3}{i,4:5},[j(i) j(i)],'linewidth',3,'color',[colors(f,:)/255 .2]); hold on
            plot(matsr{f,3}{i,2},j(i),'+', 'MarkerSize', 8, 'color',[colors(f,:)/255 .2]); hold on
        end
    end
    hold on
    
    % 0 line
    plot([0 0],[3 vmax*3+5],'r','linewidth',.7);
    
    % dividers
    ds=rescale(1:vmax,1,vmax*3-2)-.5;
    for d=2:length(ds)
        plot([-1 1],[ds(d) ds(d)],'k','linewidth',.5);
    end
    
    for d=[5 7]
        plot([-1 1],[ds(d) ds(d)],'k','linewidth',1.5);
    end
    
    set(gca,'ydir','reverse')
    set(gca,'xtick',-1:.5:1)
    set(gca,'ytick',rescale(1:vmax,2,vmax*3-1))
    set(gca,'TickLength',[0 0])
    set(gca, 'TickLabelInterpreter', 'none')
    if fpos(f)==1; set(gca,'yticklabels',vnames{f},'fontsize',12); end
    if fpos(f)>1; set(gca,'ytick',[]); end
    %set(gca,'YMinorTick','on')
    ylim([3.5 vmax*3+1])
    xlim([-1 1])
    set(gca,'xticklabels',-1:.5:1,'fontsize',10)
    xtickangle(0)
    set(gca, 'XGrid', 'on', 'YGrid', 'off')
    title(titles{f},'fontsize',11)
    box on
end

%h=suptitle('Change over days'); h.FontWeight='bold';
qw{3} = plot(nan, 'linewidth',3,'color',[[41 41 41]/255  .2]);
qw{2} = plot(nan, 'linewidth',3,'color',[[41 41 41]/255 .6]);
qw{1} = plot(nan, 'linewidth',3,'color',[41 41 41]/255);
l=legend([qw{:}], {'Same day','Next day','2nd day'}, 'location', 'northwest');
l.FontSize=10;
a

%% ALL FOUR ON ONE FIGURE, ONLY DIRECT EFFECTS
close all, clc
vmax=16;
pos = [1.0000    1.0000  1.3*943.2000/5 366.0000];
fpos=[2 1 3 0];
figure('Position', pos)
fi=1;

for f=[3 1 2 4]
    j=rescale(1:vmax,fi,vmax*4-fpos(f)+1);
    for i=2:height(matsr{f,1})
        if matsr{f,1}{i,2}~=0
            line(matsr{f,1}{i,4:5},[j(i) j(i)],'linewidth',3,'color',colors(f,:)/255); hold on
            plot(matsr{f,1}{i,2},j(i),'+', 'MarkerSize', 8, 'color',colors(f,:)/255); hold on
        end
        
        if ints{f}(i,1)~=0; image(rgpic{f}, ...
                'XData', [ints{f}(i,1)*(abs(ints{f}(i,1))-.12) ints{f}(i,1)*(abs(ints{f}(i,1))-.12)+.09], ...
                'YData', [j(i)-.35 j(i)+.75]); hold on; end
        if ints{f}(i,2)~=0; image(ripic{f}, ...
                'XData', [ints{f}(i,2)*(abs(ints{f}(i,2))-.27) ints{f}(i,2)*(abs(ints{f}(i,2))-.27)+.09], ...
                'YData', [j(i)-.35 j(i)+.75]); hold on; end
    end
    hold on
    fi=fi+1;
end

% 0 line
plot([0 0],[3 vmax*4],'r','linewidth',.7);

% dividers
ds=rescale(1:vmax,1,vmax*4-2)-.5;
for d=2:length(ds)
    plot([-1 1],[ds(d) ds(d)],'k','linewidth',.5);
end

for d=[5 7]
    plot([-1 1],[ds(d) ds(d)],'k','linewidth',1.5);
end


set(gca,'ydir','reverse')
set(gca,'xtick',-1:.5:1)
set(gca,'ytick',rescale(1:vmax,2,vmax*4-1))
set(gca,'TickLength',[0 0])
set(gca, 'TickLabelInterpreter', 'none')
set(gca,'yticklabels','','fontsize',14);
%set(gca,'ytick',[]);
%set(gca,'YMinorTick','on')
ylim([4.5 vmax*3+1])
xlim([-1 1])
set(gca,'xticklabels',-1:.5:1,'fontsize',12)
xtickangle(0)
set(gca, 'XGrid', 'on', 'YGrid', 'off')
box on

%h=suptitle('Change over days'); h.FontWeight='bold';
% fpos=[3 1 2 4];
% for f=1:4
%     qw{f} = plot(nan, 'linewidth',3,'color',colors(fpos(f),:)/255);
% end
% l=legend([qw{:}], {'Hate speech','Toxicity','Extreme speech','Extreme speakers'}, 'location', 'northwest');
% l.FontSize=14;


