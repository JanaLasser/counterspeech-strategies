clear; clc; %close all
set(0,'DefaultFigureWindowStyle','normal')
set(0,'defaultTextInterpreter','none') % 'latex'

colors(1,:)=[220 184 30];
colors(2,:)=[84 120 197];
colors(3,:)=[240 76 99];
colors(4,:)=[147 207 235];

pos = [1.0000    1.0000  3.9*943.2000/5  366.0000];

vnames={' '; 'Opinion';'Sarcasm';'Constructive';'Excl.outgroup';...
    'Incl.in/both groups';'Anger';'Fear';'Disgust';'Sadness';'Enthusiasm/Hope';'Pride/Joy'};

titles={'Toxicity';'Extremity of speech';'Hate speech'; ...
    'Extremity of speakers'};

%% figure - 4 subplots
temp=readtable('C:\Users\mirta\Dropbox\SFI Reconquista\00 strategies\analyses\bootResults_new.csv');
temp0=temp(:,[1 3 5 6]); temp0{1,1}={'0'}; temp0{1,2:4}=[0 0 0]; temp0(2:height(temp),:)=[];
matsb{3}=[temp0; temp(1:11,[1 3 5 6])];
matsb{1}=[temp0; temp(23:33,[1 3 5 6])];
matsb{2}=[temp0; temp(12:22,[1 3 5 6])];

close all, clc
vmax=12;

fpos=[2 3 1];

figure('Position', pos)
t = tiledlayout(1, 3, 'TileSpacing', 'compact');

for f=1:3
    nexttile(fpos(f));
    
    j=rescale(1:vmax,2,vmax*3-1);
    for i=1:height(matsb{f})
        if matsb{f}{i,2}~=0
            line(matsb{f}{i,3:4},[j(i) j(i)],'linewidth',3, 'color',colors(f,:)/255); hold on
            plot(matsb{f}{i,2},j(i),'+', 'MarkerSize', 8, 'color',colors(f,:)/255); hold on
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
    set(gca,'xtick',-.06:.03:.06)
    set(gca,'ytick',rescale(1:vmax,2,vmax*3-1))
    set(gca,'TickLength',[0 0])
    set(gca, 'TickLabelInterpreter', 'none')
    set(gca,'yticklabels',vnames,'fontsize',12);
    if fpos(f)>1; set(gca,'ytick',[]); end
    %set(gca,'YMinorTick','on')
    ylim([3.5 vmax*3+1])
    xlim([-.06 .06])
    set(gca,'xticklabels',-.06:.03:.06,'fontsize',10)
    xtickangle(0)
    set(gca, 'XGrid', 'on', 'YGrid', 'off')
    title(titles{f},'fontsize',11)
    box on
    %h=suptitle('Change within users'); h.FontWeight='bold';
    
end

a
%% ALL FOUR IN ONE FIGURE
close all, clc
vmax=16;
pos = [1.0000    1.0000  2*943.2000/5 366.0000];
fpos=[2 3 1];
figure('Position', pos)
fi=1;
for f=1:3
    j=rescale(1:vmax,fpos(f),vmax*4-(3-fpos(f)))
    for i=1:height(matsb{f})
        if matsb{f}{i,2}~=0
            line(matsb{f}{i,3:4},[j(i) j(i)],'linewidth',3,'color',colors(f,:)/255); hold on
            plot(matsb{f}{i,2},j(i),'+', 'MarkerSize', 8, 'color',colors(f,:)/255); hold on
        end
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
set(gca,'xtick',-.06:.03:.06)
set(gca,'ytick',rescale(1:vmax,2,vmax*4-1))
set(gca,'TickLength',[0 0])
set(gca, 'TickLabelInterpreter', 'none')
set(gca,'yticklabels',vnames,'fontsize',14);
ylim([4.5 vmax*3+1])
xlim([-.06 .06])
set(gca,'xticklabels',-.06:.03:.06,'fontsize',12)
xtickangle(0)
set(gca, 'XGrid', 'on', 'YGrid', 'off')
box on

