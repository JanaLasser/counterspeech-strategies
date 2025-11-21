clear; clc; close all
set(0,'DefaultFigureWindowStyle','docked')
set(0,'defaultTextInterpreter','none') % 'latex'

%% calculate everything by day
load d_basic2

d_basic.extreme_score=abs(.5-d_basic.hate_score);

corr([d_basic.joy d_basic.enthusiasm d_basic.pride d_basic.joy])
d_basic.enthop=mean([d_basic.enthusiasm d_basic.hope],2);
d_basic.prijoy=mean([d_basic.pride d_basic.joy],2);

vars={'id';'tree_nr';'tweet_nr';'user_twitter_id';'tree_max3';'tweet_nr2';'tree_max4';'tweet_nr3';...
    'weeks';'years';'wy';'day';'month';'dayn';...
    'hate_score';'counter_score';'extreme_score';'valence';'arousal';'dominance';...
    'goodness';'energy';'power';'danger';'structure';'valence_similarity';'arousal_similarity';'dominance_similarity';...
    'goodness_similarity';'energy_similarity';'power_similarity';'danger_similarity';'structure_similarity';'PROFANITY';'TOXICITY';...
    'INSULT';'SEVERE_TOXICITY';'IDENTITY_ATTACK';'threat';...
    'anger';'fear';'disgust';'sadness';'joy';'enthusiasm';'pride';'hope';...
    'enthop';'prijoy';...
    'strategy_construct';'strategy_opin';'strategy_sarc';'strategy_leave_fact';...
    'strategy_other_new';'topic_not_out';'topic_out';'topic2_in_both';...
    'topic2_out';'topic2_neutral_unint';'goal_other';'goal_weak';...
    'goal_neutral';'goal2_in_both_positive';'goal2_out_negative';...
    'goal2_neutral_unint';'speech_hate_yes';'speech_hate_no';...
    'speech_group_inst';'speech_group_right_wing';'speech_group_left_wing';...
    'speech_group_vulnerable';'speech_group_other_new';'user_hate_score';...
    'user_group_70e';'user_group_80e';'user_group_90e';'user_group_95e';...
    'user_group_70rg';'user_group_80rg';'user_group_90rg';'user_group_95rg';...
    'user_group_70ri';'user_group_80ri';'user_group_90ri';'user_group_95ri';...
    'tox';'next_tox';'re_tox';'all_tox'};

for v=1:length(vars)
    d_basic_byday(:,v)=grpstats(d_basic{:,vars{v}},d_basic.dayn,{'std'}); % repeat for mean
end
for v=1:length(vars)
    vars_dbd{v}=['dbd_',vars{v}];
end
d_basic_byday = array2table(d_basic_byday);     
d_basic_byday.Properties.VariableNames=vars_dbd;

writetable(d_basic_byday,"d_basic_byday_std.xlsx") % for stata
save d_basic_byday_std d_basic_byday

%% %%%%%%%%%%% PLOTS %%%%%%%%%%%%
%https://xkcd.com/color/rgb/
load d_basic2
d=d_basic;
clear d_basic

load d_basic_byday
dd=d_basic_byday;
clear d_basic_byday

load d_basic_byday_sem
dd_sem=d_basic_byday;
clear d_basic_byday_sem

load d_basic_byday_std
dd_std=d_basic_byday;
clear d_basic_byday_std

%% setup for the initial figs
step=1:1:height(dd);
wyu=num2str([dd.dbd_month(step) dd.dbd_years(step)]);
st=122;
mm=14;

events=[852,1005,1463,1729,1948]; %1.10.15, 1.1.2017, 24.9.2017, 1.5.2018
event_names={'mc1','mc2','RG','el','RI'};

%% balance
figure
plot(dd.dbd_user_group_90rg,'r')
hold on
plot(dd.dbd_user_group_90ri,'b')
figure
plot(movmean(dd.dbd_user_group_70rg-dd.dbd_user_group_70ri,14),'k')
figure
plot(movmean(1-dd.dbd_user_group_70rg-dd.dbd_user_group_70ri,14),'g')

%% neutrality and extremity, enth, pds vad
d.extreme_score=abs(.5-d.hate_score);
d_next.next_extreme_score=abs(.5-d_next.next_hate_score);
d_all.all_extreme_score=abs(.5-d_all.all_hate_score);
d_re.re_extreme_score=abs(.5-d_re.re_hate_score);

d.enthusiasm_avg=mean([d.enthusiasm d.hope],2);

d.power(d.power==0)=nan;
d.danger(d.danger==0)=nan;
d.structure(d.structure==0)=nan;
d.valence(d.valence==0)=nan;
d.arousal(d.arousal==0)=nan;
d.dominance(d.dominance==0)=nan;

%% toxicity, hate speech over time, extremity of speech, extremity of participation over time
figure
subplot(1,2,1)
h1=shadedErrorBar(dd.dbd_dayn,movmean(dd.dbd_speech_hate_yes,mm),movmean(dd_sem.dbd_speech_hate_yes,mm));
h1.edge(1).Visible='Off'; h1.edge(2).Visible='Off';
h1.mainLine.Color=rgb('Red'); h1.patch.FaceColor=rgb('Red');
h1.mainLine.LineWidth=1.5;

hold on
h2=shadedErrorBar(dd.dbd_dayn,movmean(dd.dbd_tox,mm),movmean(dd_sem.dbd_tox,mm));
h2.edge(1).Visible='Off'; h2.edge(2).Visible='Off';
h2.mainLine.Color=rgb('Dark red'); h2.patch.FaceColor=rgb('Dark red');
h2.mainLine.LineWidth=1.5;

hold on
h3=shadedErrorBar(dd.dbd_dayn,movmean(dd.dbd_extreme_score,mm),movmean(dd_sem.dbd_extreme_score,mm));
h3.edge(1).Visible='Off'; h3.edge(2).Visible='Off';
h3.mainLine.Color=rgb('Orange'); h3.patch.FaceColor=rgb('Orange');
h3.mainLine.LineWidth=1.5;

hold on
h4=shadedErrorBar(dd.dbd_dayn,movmean(dd.dbd_user_group_70e,mm),movmean(dd_sem.dbd_user_group_70e,mm));
h4.edge(1).Visible='Off'; h4.edge(2).Visible='Off';
h4.mainLine.Color=rgb('Ocher'); h4.patch.FaceColor=rgb('Ocher');
h4.mainLine.LineWidth=1.5;

xlabel('Time (months)','fontsize',14); 
ylabel('Average probability','fontsize',14)

step=1:st:height(dd);
set(gca,'xtick',dd.dbd_dayn(step))
set(gca,'xticklabels',num2str([dd.dbd_month(step) dd.dbd_years(step)]),'fontsize',12)
set(gca,'ytick',0:.05:.35)
set(gca,'yticklabels',0:.05:.35,'fontsize',12)
xtickangle(45)
xlim([min(dd.dbd_dayn)-5 max(dd.dbd_dayn)+5])
ylim([0 .36])
grid

hold on
for ev=1:length(events)
    plot([events(ev) events(ev)],[-.1 1],'color',rgb('Grey'),'linewidth',1); hold on
    yl=ylim; text(events(ev)+2, yl(1)+.03*yl(2),event_names{ev})
end

% normalized min-max
subplot(1,2,2)
h1=plot(dd.dbd_dayn,(movmean(dd.dbd_speech_hate_yes,mm)-min(movmean(dd.dbd_speech_hate_yes,mm)))./(max(movmean(dd.dbd_speech_hate_yes,mm))-min(movmean(dd.dbd_speech_hate_yes,mm))),'color',rgb('Red'),'linewidth',1.5);
hold on
h2=plot(dd.dbd_dayn,(movmean(dd.dbd_tox,mm)-min(movmean(dd.dbd_tox,mm)))./(max(movmean(dd.dbd_tox,mm))-min(movmean(dd.dbd_tox,mm))),'color',rgb('Dark red'),'linewidth',1.5);
hold on
h3=plot(dd.dbd_dayn,(movmean(dd.dbd_extreme_score,mm)-min(movmean(dd.dbd_extreme_score,mm)))./(max(movmean(dd.dbd_extreme_score,mm))-min(movmean(dd.dbd_extreme_score,mm))),'color',rgb('Orange'),'linewidth',1.5);
hold on
h4=plot(dd.dbd_dayn,(movmean(dd.dbd_user_group_70e,mm)-min(movmean(dd.dbd_user_group_70e,mm)))./(max(movmean(dd.dbd_user_group_70e,mm))-min(movmean(dd.dbd_user_group_70e,mm))),'color',rgb('Ocher'),'linewidth',1.5);
box off

xlabel('Time (months)','fontsize',14); 
ylabel({'Normalized avg.','probability'},'fontsize',14)

step=1:st:height(dd);
set(gca,'xtick',dd.dbd_dayn(step))
set(gca,'xticklabels',num2str([dd.dbd_month(step) dd.dbd_years(step)]),'fontsize',12)
xtickangle(45)
xlim([min(dd.dbd_dayn)-5 max(dd.dbd_dayn)+5])
ylim([0 1.01])
grid

hold on
for ev=1:length(events)
    plot([events(ev) events(ev)],[-.1 1],'color',rgb('Grey'),'linewidth',1); hold on
    yl=ylim; text(events(ev)+2, yl(1)+.03*yl(2),event_names{ev})
end

l=legend([h1 h2 h3 h4],'Hate speech','Toxicity','Extremity of speech','Extremity of speakers','location','northwest');
l.FontSize=12;

%% relationship of quality of discourse variables
%close all
figure

% hatespeech and toxicity
subplot(2,2,1)
d.speech_hate_yes_r=round(d.speech_hate_yes,1);
errorbar(unique(d.speech_hate_yes_r),grpstats(d.tox,d.speech_hate_yes_r),1.96*grpstats(d.tox,d.speech_hate_yes_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
xlabel('Probability of hate speech','fontsize',14); 
ylabel({'Mean toxicity by','probability of hate speech'},'fontsize',14)
xlim([-.05 1.05]); xlim([-.05 1.05]); ylim([.1 .6])
set(gca,'xtick',0:.2:1)
set(gca,'xticklabels',0:.2:1,'fontsize',12)
grid
box off

% extremity by party
subplot(2,2,2)
h1=shadedErrorBar(dd.dbd_dayn,movmean(dd.dbd_user_group_70rg,mm),movmean(dd_sem.dbd_user_group_70rg,mm));
h1.edge(1).Visible='Off'; h1.edge(2).Visible='Off';
h1.mainLine.Color=rgb('Purple'); h1.patch.FaceColor=rgb('Purple');
h1.mainLine.LineWidth=1.5;

hold on
h2=shadedErrorBar(dd.dbd_dayn,movmean(dd.dbd_user_group_70ri,mm),movmean(dd_sem.dbd_user_group_70ri,mm));
h2.edge(1).Visible='Off'; h2.edge(2).Visible='Off';
h2.mainLine.Color=rgb('Orange'); h2.patch.FaceColor=rgb('Orange');
h2.mainLine.LineWidth=1.5;

xlabel('Time (months)','fontsize',14); 
ylabel({'Percentage of speakers'},'fontsize',14)

step=1:366:height(dd);
set(gca,'xtick',dd.dbd_dayn(step))
set(gca,'xticklabels',num2str([dd.dbd_month(step) dd.dbd_years(step)]),'fontsize',12)
%xtickangle(45)
xlim([min(dd.dbd_dayn)-5 max(dd.dbd_dayn)+5])
ylim([0 .2])
grid

hold on
for ev=1:length(events)
    plot([events(ev) events(ev)],[-.1 1],'color',rgb('Grey'),'linewidth',1); hold on
    yl=ylim; text(events(ev)+2, yl(1)+.03*yl(2),event_names{ev})
end

l=legend([h1.mainLine h2.mainLine],'RG-like','RI-like','location','north');
l.FontSize=12;

% extremity and toxicity
subplot(2,2,3)
d.user_hate_score_r=round(d.user_hate_score,1);
errorbar(unique(d.user_hate_score_r),grpstats(d.tox,d.user_hate_score_r),1.96*grpstats(d.tox,d.user_hate_score_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
d.hate_score_r=round(d.hate_score,1);
errorbar(unique(d.hate_score_r),grpstats(d.tox,d.hate_score_r),1.96*grpstats(d.tox,d.hate_score_r,{'sem'}),'--','color',rgb('Dark Red'),'linewidth',1)
hold on

l=legend('Speakers','Speech','location','north');
l.FontSize=12;

xlabel({'Extremity of speakers','and speech'},'fontsize',14)
ylabel('Mean toxicity by extremity','fontsize',14); 
xlim([-.05 1.05]); 
set(gca,'xtick',[0:.1:1])
set(gca,'xticklabels',{'RI-like','','','','','','','','','','RG-like'},'fontsize',12)
grid
box off

% hatespeech by extremity
subplot(2,2,4)
d.user_hate_score_r=round(d.user_hate_score,1);
errorbar(unique(d.user_hate_score_r),grpstats(d.speech_hate_yes,d.user_hate_score_r),1.96*grpstats(d.speech_hate_yes,d.user_hate_score_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
d.hate_score_r=round(d.hate_score,1);
errorbar(unique(d.hate_score_r),grpstats(d.speech_hate_yes,d.hate_score_r),1.96*grpstats(d.speech_hate_yes,d.hate_score_r,{'sem'}),'--','color',rgb('Red'),'linewidth',1)
hold on

l=legend('Speakers','Speech','location','north');
l.FontSize=12;

xlabel({'Extremity of speakers','and speech'},'fontsize',14)
ylabel({'Mean probability of hate speech','by extremity'},'fontsize',14); 
xlim([-.05 1.05]); 
set(gca,'xtick',[0:.1:1])
set(gca,'xticklabels',{'RI-like','','','','','','','','','','RG-like'},'fontsize',12)
grid
box off

%% targets of hate speech
mm=14;
figure
h1=shadedErrorBar(dd.dbd_dayn,movmean(dd.dbd_speech_group_inst,mm),movmean(dd_sem.dbd_speech_group_inst,mm));
h1.edge(1).Visible='Off'; h1.edge(2).Visible='Off';
h1.mainLine.Color=rgb('bluegreen'); h1.patch.FaceColor=rgb('bluegreen');
h1.mainLine.LineWidth=1.5;

hold on
h2=shadedErrorBar(dd.dbd_dayn,movmean(dd.dbd_speech_group_right_wing,mm),movmean(dd_sem.dbd_speech_group_right_wing,mm));
h2.edge(1).Visible='Off'; h2.edge(2).Visible='Off';
h2.mainLine.Color=rgb('Blue'); h2.patch.FaceColor=rgb('Blue');
h2.mainLine.LineWidth=1.5;

hold on
h3=shadedErrorBar(dd.dbd_dayn,movmean(dd.dbd_speech_group_left_wing,mm),movmean(dd_sem.dbd_speech_group_left_wing,mm));
h3.edge(1).Visible='Off'; h3.edge(2).Visible='Off';
h3.mainLine.Color=rgb('Red'); h3.patch.FaceColor=rgb('Red');
h3.mainLine.LineWidth=1.5;

hold on
h4=shadedErrorBar(dd.dbd_dayn,movmean(dd.dbd_speech_group_vulnerable,mm),movmean(dd_sem.dbd_speech_group_vulnerable,mm));
h4.edge(1).Visible='Off'; h4.edge(2).Visible='Off';
h4.mainLine.Color=rgb('Gold'); h4.patch.FaceColor=rgb('Gold');
h4.mainLine.LineWidth=1.5;

hold on
h5=shadedErrorBar(dd.dbd_dayn,movmean(dd.dbd_speech_group_other_new,mm),movmean(dd_sem.dbd_speech_group_other_new,mm));
h5.edge(1).Visible='Off'; h5.edge(2).Visible='Off';
h5.mainLine.Color=rgb('Grey'); h5.patch.FaceColor=rgb('Grey');
h5.mainLine.LineWidth=1.5;


xlabel('Time (months)','fontsize',14); 
ylabel({'Probability of different','targets of hate speech'},'fontsize',14)

step=1:st:height(dd);
set(gca,'xtick',dd.dbd_dayn(step))
set(gca,'xticklabels',num2str([dd.dbd_month(step) dd.dbd_years(step)]),'fontsize',12)
xtickangle(45)
xlim([min(dd.dbd_dayn)-5 max(dd.dbd_dayn)+5])
ylim([0 .8])
grid

hold on
for ev=1:length(events)
    plot([events(ev) events(ev)],[-.1 1],'color',rgb('Grey'),'linewidth',1); hold on
    yl=ylim; text(events(ev)+2, yl(1)+.03*yl(2),event_names{ev})
end

l=legend([h1.mainLine h2.mainLine h3.mainLine h4.mainLine h5.mainLine],'Institutions','Right-wing parties','Left-wing parties','Vulnerable groups','Other','location','southeast');
l.FontSize=12;


%% dimensions - setup
step=1:1:height(dd);
wyu=num2str([dd.dbd_month(step) dd.dbd_years(step)]);
st=122;
mm=14;

events=[852,1005,1463,1729,1948]-731; %1.10.15, 1.1.2017, 24.9.2017, 1.5.2018
event_names={'mc1','mc2','RG','el','RI'};

%% strategies
%close all
figure
subplot(1,3,1)
h1=shadedErrorBar(1:1461,movmean(grpstats(d.strategy_opin,d.dayn),mm),movmean(grpstats(d.strategy_opin,d.dayn,'sem'),mm));
h1.edge(1).Visible='Off'; h1.edge(2).Visible='Off';
h1.mainLine.Color=rgb('sky blue'); h2.patch.FaceColor=rgb('sky blue');
h1.mainLine.LineWidth=1.5;

hold on
h2=shadedErrorBar(1:1461,movmean(grpstats(d.strategy_construct,d.dayn),mm),movmean(grpstats(d.strategy_construct,d.dayn,'sem'),mm));
h2.edge(1).Visible='Off'; h2.edge(2).Visible='Off';
h2.mainLine.Color=rgb('Blue'); h2.patch.FaceColor=rgb('Blue');
h2.mainLine.LineWidth=1.5;

hold on
h3=shadedErrorBar(1:1461,movmean(grpstats(d.strategy_sarc,d.dayn),mm),movmean(grpstats(d.strategy_sarc,d.dayn,'sem'),mm));
h3.edge(1).Visible='Off'; h3.edge(2).Visible='Off';
h3.mainLine.Color=rgb('orange'); h3.patch.FaceColor=rgb('orange');
h3.mainLine.LineWidth=1.5;

hold on
h4=shadedErrorBar(1:1461,movmean(grpstats(d.strategy_leave_fact,d.dayn),mm),movmean(grpstats(d.strategy_leave_fact,d.dayn,'sem'),mm));
h4.edge(1).Visible='Off'; h4.edge(2).Visible='Off';
h4.mainLine.Color=rgb('red'); h4.patch.FaceColor=rgb('red');
h4.mainLine.LineWidth=1.5;

hold on
h5=shadedErrorBar(1:1461,movmean(grpstats(d.strategy_other_new,d.dayn),mm),movmean(grpstats(d.strategy_other_new,d.dayn,'sem'),mm));
h5.edge(1).Visible='Off'; h5.edge(2).Visible='Off';
h5.mainLine.Color=rgb('Grey'); h5.patch.FaceColor=rgb('Grey');
h5.mainLine.LineWidth=1.5;

title('All tweets','fontsize',14)
xlabel('Time (months)','fontsize',14); 
ylabel('Probability of different strategies','fontsize',14)
set(gca,'xtick',(1:st:length(wyu)))
set(gca,'xticklabels',wyu(1:st:length(wyu),:),'fontsize',12)
xtickangle(45)
ylim([0 .5])
grid

hold on
for ev=1:length(events)
    plot([events(ev) events(ev)],[-.1 1],'color',rgb('Grey'),'linewidth',1); hold on
    yl=ylim; text(events(ev)+2, yl(1)+.03*yl(2),event_names{ev})
end

l=legend([h1.mainLine h2.mainLine h3.mainLine h4.mainLine h5.mainLine],'Opinion','Constructive','Sarcasm','Insults','Other','location','northwest');
l.FontSize=12;

subplot(1,3,2)
filt=d.hate_score<.3;
h=shadedErrorBar(1:1461,movmean(grpstats(d.strategy_opin(filt),d.dayn(filt)),mm),movmean(grpstats(d.strategy_opin(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('sky blue'); h.patch.FaceColor=rgb('sky blue');
h.mainLine.LineWidth=1.5;

hold on
h=shadedErrorBar(1:1461,movmean(grpstats(d.strategy_construct(filt),d.dayn(filt)),mm),movmean(grpstats(d.strategy_construct(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('Blue'); h.patch.FaceColor=rgb('Blue');
h.mainLine.LineWidth=1.5;

hold on
h=shadedErrorBar(1:1461,movmean(grpstats(d.strategy_sarc(filt),d.dayn(filt)),mm),movmean(grpstats(d.strategy_sarc(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('orange'); h.patch.FaceColor=rgb('orange');
h.mainLine.LineWidth=1.5;

hold on
h=shadedErrorBar(1:1461,movmean(grpstats(d.strategy_leave_fact(filt),d.dayn(filt)),mm),movmean(grpstats(d.strategy_leave_fact(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('red'); h.patch.FaceColor=rgb('red');
h.mainLine.LineWidth=1.5;

hold on
h=shadedErrorBar(1:1461,movmean(grpstats(d.strategy_other_new(filt),d.dayn(filt)),mm),movmean(grpstats(d.strategy_other_new(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('Grey'); h.patch.FaceColor=rgb('Grey');
h.mainLine.LineWidth=1.5;

title('RI-like tweets','fontsize',14)
xlabel('Time (months)','fontsize',14); 
ylabel('Probability of different strategies','fontsize',14)
set(gca,'xtick',(1:st:length(wyu)))
set(gca,'xticklabels',wyu(1:st:length(wyu),:),'fontsize',12)
xtickangle(45)
ylim([0 .5])
grid

hold on
for ev=1:length(events)
    plot([events(ev) events(ev)],[-.1 1],'color',rgb('Grey'),'linewidth',1); hold on
    yl=ylim; text(events(ev)+2, yl(1)+.03*yl(2),event_names{ev})
end

subplot(1,3,3)
filt=d.hate_score>.7;
h=shadedErrorBar(1:1461,movmean(grpstats(d.strategy_opin(filt),d.dayn(filt)),mm),movmean(grpstats(d.strategy_opin(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('sky blue'); h.patch.FaceColor=rgb('sky blue');
h.mainLine.LineWidth=1.5;

hold on
h=shadedErrorBar(1:1461,movmean(grpstats(d.strategy_construct(filt),d.dayn(filt)),mm),movmean(grpstats(d.strategy_construct(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('Blue'); h.patch.FaceColor=rgb('Blue');
h.mainLine.LineWidth=1.5;

hold on
h=shadedErrorBar(1:1461,movmean(grpstats(d.strategy_sarc(filt),d.dayn(filt)),mm),movmean(grpstats(d.strategy_sarc(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('orange'); h.patch.FaceColor=rgb('orange');
h.mainLine.LineWidth=1.5;

hold on
h=shadedErrorBar(1:1461,movmean(grpstats(d.strategy_leave_fact(filt),d.dayn(filt)),mm),movmean(grpstats(d.strategy_leave_fact(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('red'); h.patch.FaceColor=rgb('red');
h.mainLine.LineWidth=1.5;

hold on
h=shadedErrorBar(1:1461,movmean(grpstats(d.strategy_other_new(filt),d.dayn(filt)),mm),movmean(grpstats(d.strategy_other_new(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('Grey'); h.patch.FaceColor=rgb('Grey');
h.mainLine.LineWidth=1.5;

title('RG-like tweets','fontsize',14)
xlabel('Time (months)','fontsize',14); 
ylabel('Probability of different strategies','fontsize',14)
set(gca,'xtick',(1:st:length(wyu)))
set(gca,'xticklabels',wyu(1:st:length(wyu),:),'fontsize',12)
xtickangle(45)
ylim([0 .5])
grid

hold on
for ev=1:length(events)
    plot([events(ev) events(ev)],[-.1 1],'color',rgb('Grey'),'linewidth',1); hold on
    yl=ylim; text(events(ev)+2, yl(1)+.03*yl(2),event_names{ev})
end

%% topic with 3 cats
%close all
figure
subplot(1,3,1)
h1=shadedErrorBar(1:1461,movmean(grpstats(d.topic2_in_both,d.dayn),mm),movmean(grpstats(d.topic2_in_both,d.dayn,'sem'),mm));
h1.edge(1).Visible='Off'; h1.edge(2).Visible='Off';
h1.mainLine.Color=rgb('bluegreen'); h1.patch.FaceColor=rgb('bluegreen');
h1.mainLine.LineWidth=1.5;

hold on
h2=shadedErrorBar(1:1461,movmean(grpstats(d.topic2_out,d.dayn),mm),movmean(grpstats(d.topic2_out,d.dayn,'sem'),mm));
h2.edge(1).Visible='Off'; h2.edge(2).Visible='Off';
h2.mainLine.Color=rgb('deep orange'); h2.patch.FaceColor=rgb('deep orange');
h2.mainLine.LineWidth=1.5;

hold on
h3=shadedErrorBar(1:1461,movmean(grpstats(d.topic2_neutral_unint,d.dayn),mm),movmean(grpstats(d.topic2_neutral_unint,d.dayn,'sem'),mm));
h3.edge(1).Visible='Off'; h3.edge(2).Visible='Off';
h3.mainLine.Color=rgb('grey'); h3.patch.FaceColor=rgb('grey');
h3.mainLine.LineWidth=1.5;

title('All tweets','fontsize',14)
xlabel('Time (months)','fontsize',14); 
ylabel('Probability of different topics','fontsize',14)
set(gca,'xtick',(1:st:length(wyu)))
set(gca,'xticklabels',wyu(1:st:length(wyu),:),'fontsize',12)
xtickangle(45)
ylim([0 .8])
grid
l=legend('Ingroup or both groups','Outgroup','Other','location','northwest'); l.FontSize=11;

hold on
for ev=1:length(events)
    plot([events(ev) events(ev)],[-.1 1],'color',rgb('Grey'),'linewidth',1); hold on
    yl=ylim; text(events(ev)+2, yl(1)+.03*yl(2),event_names{ev})
end

l=legend([h1.mainLine h2.mainLine h3.mainLine],'Ingroup or both groups','Outgroup','Other','location','northwest'); 
l.FontSize=12;

subplot(1,3,2)
filt=d.hate_score<.3;
h=shadedErrorBar(1:1461,movmean(grpstats(d.topic2_in_both(filt),d.dayn(filt)),mm),movmean(grpstats(d.topic2_in_both(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('bluegreen'); h.patch.FaceColor=rgb('bluegreen');
h.mainLine.LineWidth=1.5;

hold on
h=shadedErrorBar(1:1461,movmean(grpstats(d.topic2_out(filt),d.dayn(filt)),mm),movmean(grpstats(d.topic2_out(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('deep orange'); h.patch.FaceColor=rgb('deep orange');
h.mainLine.LineWidth=1.5;

hold on
h=shadedErrorBar(1:1461,movmean(grpstats(d.topic2_neutral_unint(filt),d.dayn(filt)),mm),movmean(grpstats(d.topic2_neutral_unint(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('grey'); h.patch.FaceColor=rgb('grey');
h.mainLine.LineWidth=1.5;

title('RI-like tweets','fontsize',14)
xlabel('Time (months)','fontsize',14); 
ylabel('Probability of different topics','fontsize',14)
set(gca,'xtick',(1:st:length(wyu)))
set(gca,'xticklabels',wyu(1:st:length(wyu),:),'fontsize',12)
xtickangle(45)
ylim([0 .8])
grid

hold on
for ev=1:length(events)
    plot([events(ev) events(ev)],[-.1 1],'color',rgb('Grey'),'linewidth',1); hold on
    yl=ylim; text(events(ev)+2, yl(1)+.03*yl(2),event_names{ev})
end

subplot(1,3,3)
filt=d.hate_score>.7;
h=shadedErrorBar(1:1461,movmean(grpstats(d.topic2_in_both(filt),d.dayn(filt)),mm),movmean(grpstats(d.topic2_in_both(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('bluegreen'); h.patch.FaceColor=rgb('bluegreen');
h.mainLine.LineWidth=1.5;

hold on
h=shadedErrorBar(1:1461,movmean(grpstats(d.topic2_out(filt),d.dayn(filt)),mm),movmean(grpstats(d.topic2_out(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('deep orange'); h.patch.FaceColor=rgb('deep orange');
h.mainLine.LineWidth=1.5;

hold on
h=shadedErrorBar(1:1461,movmean(grpstats(d.topic2_neutral_unint(filt),d.dayn(filt)),mm),movmean(grpstats(d.topic2_neutral_unint(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('grey'); h.patch.FaceColor=rgb('grey');
h.mainLine.LineWidth=1.5;

title('RG-like tweets','fontsize',14)
xlabel('Time (months)','fontsize',14); 
ylabel('Probability of different topics','fontsize',14)
set(gca,'xtick',(1:st:length(wyu)))
set(gca,'xticklabels',wyu(1:st:length(wyu),:),'fontsize',12)
xtickangle(45)
ylim([0 .8])
grid

hold on
for ev=1:length(events)
    plot([events(ev) events(ev)],[-.1 1],'color',rgb('Grey'),'linewidth',1); hold on
    yl=ylim; text(events(ev)+2, yl(1)+.03*yl(2),event_names{ev})
end

%% topic with 2 cats
%close all
figure
subplot(1,3,1)
h1=shadedErrorBar(1:1461,movmean(grpstats(d.topic_out,d.dayn),mm),movmean(grpstats(d.topic_out,d.dayn,'sem'),mm));
h1.edge(1).Visible='Off'; h1.edge(2).Visible='Off';
h1.mainLine.Color=rgb('deep orange'); h1.patch.FaceColor=rgb('deep orange');
h1.mainLine.LineWidth=1.5;

hold on
h2=shadedErrorBar(1:1461,movmean(grpstats(d.topic_not_out,d.dayn),mm),movmean(grpstats(d.topic_not_out,d.dayn,'sem'),mm));
h2.edge(1).Visible='Off'; h2.edge(2).Visible='Off';
h2.mainLine.Color=rgb('grey'); h2.patch.FaceColor=rgb('grey');
h2.mainLine.LineWidth=1.5;

title('All tweets','fontsize',14)
xlabel('Time (months)','fontsize',14); 
ylabel('Probability of different topics','fontsize',14)
set(gca,'xtick',(1:st:length(wyu)))
set(gca,'xticklabels',wyu(1:st:length(wyu),:),'fontsize',12)
xtickangle(45)
ylim([0 1])
grid
%l=legend('Outgroup','Other content','location','northwest'); l.FontSize=11;

hold on
for ev=1:length(events)
    plot([events(ev) events(ev)],[-.1 1],'color',rgb('Grey'),'linewidth',1); hold on
    yl=ylim; text(events(ev)+2, yl(1)+.03*yl(2),event_names{ev})
end

l=legend([h1.mainLine h2.mainLine],'Outgroup','Other content','location','northwest');
l.FontSize=12;

subplot(1,3,2)
filt=d.hate_score<.3;
h=shadedErrorBar(1:1461,movmean(grpstats(d.topic_out(filt),d.dayn(filt)),mm),movmean(grpstats(d.topic_out(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('deep orange'); h.patch.FaceColor=rgb('deep orange');
h.mainLine.LineWidth=1.5;

hold on
h=shadedErrorBar(1:1461,movmean(grpstats(d.topic_not_out(filt),d.dayn(filt)),mm),movmean(grpstats(d.topic_not_out(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('grey'); h.patch.FaceColor=rgb('grey');
h.mainLine.LineWidth=1.5;

title('RI-like tweets','fontsize',14)
xlabel('Time (months)','fontsize',14); 
ylabel('Probability of different topics','fontsize',14)
set(gca,'xtick',(1:st:length(wyu)))
set(gca,'xticklabels',wyu(1:st:length(wyu),:),'fontsize',12)
xtickangle(45)
ylim([0 1])
grid

hold on
for ev=1:length(events)
    plot([events(ev) events(ev)],[-.1 1],'color',rgb('Grey'),'linewidth',1); hold on
    yl=ylim; text(events(ev)+2, yl(1)+.03*yl(2),event_names{ev})
end

subplot(1,3,3)
filt=d.hate_score>.7;
h=shadedErrorBar(1:1461,movmean(grpstats(d.topic_out(filt),d.dayn(filt)),mm),movmean(grpstats(d.topic_out(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('deep orange'); h.patch.FaceColor=rgb('deep orange');
h.mainLine.LineWidth=1.5;

hold on
h=shadedErrorBar(1:1461,movmean(grpstats(d.topic_not_out(filt),d.dayn(filt)),mm),movmean(grpstats(d.topic_not_out(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('grey'); h.patch.FaceColor=rgb('grey');
h.mainLine.LineWidth=1.5;

title('RG-like tweets','fontsize',14)
xlabel('Time (months)','fontsize',14); 
ylabel('Probability of different topics','fontsize',14)
set(gca,'xtick',(1:st:length(wyu)))
set(gca,'xticklabels',wyu(1:st:length(wyu),:),'fontsize',12)
xtickangle(45)
ylim([0 1])
grid

hold on
for ev=1:length(events)
    plot([events(ev) events(ev)],[-.1 1],'color',rgb('Grey'),'linewidth',1); hold on
    yl=ylim; text(events(ev)+2, yl(1)+.03*yl(2),event_names{ev})
end
%% goals
%close all
figure
subplot(1,3,1)
h1=shadedErrorBar(1:1461,movmean(grpstats(d.goal2_in_both_positive,d.dayn),mm),movmean(grpstats(d.goal2_in_both_positive,d.dayn,'sem'),mm));
h1.edge(1).Visible='Off'; h1.edge(2).Visible='Off';
h1.mainLine.Color=rgb('bluegreen'); h1.patch.FaceColor=rgb('bluegreen');
h1.mainLine.LineWidth=1.5;

hold on
h2=shadedErrorBar(1:1461,movmean(grpstats(d.goal2_out_negative,d.dayn),mm),movmean(grpstats(d.goal2_out_negative,d.dayn,'sem'),mm));
h2.edge(1).Visible='Off'; h2.edge(2).Visible='Off';
h2.mainLine.Color=rgb('deep orange'); h2.patch.FaceColor=rgb('deep orange');
h2.mainLine.LineWidth=1.5;

hold on
h3=shadedErrorBar(1:1461,movmean(grpstats(d.goal2_neutral_unint,d.dayn),mm),movmean(grpstats(d.goal2_neutral_unint,d.dayn,'sem'),mm));
h3.edge(1).Visible='Off'; h3.edge(2).Visible='Off';
h3.mainLine.Color=rgb('grey'); h3.patch.FaceColor=rgb('grey');
h3.mainLine.LineWidth=1.5;

title('All tweets','fontsize',14)
xlabel('Time (months)','fontsize',14); 
ylabel('Probability of different goals','fontsize',14)
set(gca,'xtick',(1:st:length(wyu)))
set(gca,'xticklabels',wyu(1:st:length(wyu),:),'fontsize',12)
xtickangle(45)
ylim([0 .8])
grid
%l=legend('Positive about own or both groups','Negative about outgroup','Other','location','northwest'); l.FontSize=11;

hold on
for ev=1:length(events)
    plot([events(ev) events(ev)],[-.1 1],'color',rgb('Grey'),'linewidth',1); hold on
    yl=ylim; text(events(ev)+2, yl(1)+.03*yl(2),event_names{ev})
end

l=legend([h1.mainLine h2.mainLine h3.mainLine],'Inclusionary about in/both groups','Exclusionary about outgroup','Other','location','northwest');
l.FontSize=12;

subplot(1,3,2)
filt=d.hate_score<.3;
h=shadedErrorBar(1:1461,movmean(grpstats(d.goal2_in_both_positive(filt),d.dayn(filt)),mm),movmean(grpstats(d.goal2_in_both_positive(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('bluegreen'); h.patch.FaceColor=rgb('bluegreen');
h.mainLine.LineWidth=1.5;

hold on
h=shadedErrorBar(1:1461,movmean(grpstats(d.goal2_out_negative(filt),d.dayn(filt)),mm),movmean(grpstats(d.goal2_out_negative(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('deep orange'); h.patch.FaceColor=rgb('deep orange');
h.mainLine.LineWidth=1.5;

hold on
h=shadedErrorBar(1:1461,movmean(grpstats(d.goal2_neutral_unint(filt),d.dayn(filt)),mm),movmean(grpstats(d.goal2_neutral_unint(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('grey'); h.patch.FaceColor=rgb('grey');
h.mainLine.LineWidth=1.5;

title('RI-like tweets','fontsize',14)
xlabel('Time (months)','fontsize',14); 
ylabel('Probability of different goals','fontsize',14)
set(gca,'xtick',(1:st:length(wyu)))
set(gca,'xticklabels',wyu(1:st:length(wyu),:),'fontsize',12)
xtickangle(45)
ylim([0 .8])
grid

hold on
for ev=1:length(events)
    plot([events(ev) events(ev)],[-.1 1],'color',rgb('Grey'),'linewidth',1); hold on
    yl=ylim; text(events(ev)+2, yl(1)+.03*yl(2),event_names{ev})
end

subplot(1,3,3)
filt=d.hate_score>.7;
h=shadedErrorBar(1:1461,movmean(grpstats(d.goal2_in_both_positive(filt),d.dayn(filt)),mm),movmean(grpstats(d.goal2_in_both_positive(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('bluegreen'); h.patch.FaceColor=rgb('bluegreen');
h.mainLine.LineWidth=1.5;

hold on
h=shadedErrorBar(1:1461,movmean(grpstats(d.goal2_out_negative(filt),d.dayn(filt)),mm),movmean(grpstats(d.goal2_out_negative(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('deep orange'); h.patch.FaceColor=rgb('deep orange');
h.mainLine.LineWidth=1.5;

hold on
h=shadedErrorBar(1:1461,movmean(grpstats(d.goal2_neutral_unint(filt),d.dayn(filt)),mm),movmean(grpstats(d.goal2_neutral_unint(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('grey'); h.patch.FaceColor=rgb('grey');
h.mainLine.LineWidth=1.5;

title('RG-like tweets','fontsize',14)
xlabel('Time (months)','fontsize',14); 
ylabel('Probability of different goals','fontsize',14)
set(gca,'xtick',(1:st:length(wyu)))
set(gca,'xticklabels',wyu(1:st:length(wyu),:),'fontsize',12)
xtickangle(45)
ylim([0 .8])
grid

hold on
for ev=1:length(events)
    plot([events(ev) events(ev)],[-.1 1],'color',rgb('Grey'),'linewidth',1); hold on
    yl=ylim; text(events(ev)+2, yl(1)+.03*yl(2),event_names{ev})
end

%% emotions
a=corr([d.hope d.enthusiasm d.joy d.pride]);
a(a==1)=nan;
nanmean(a,2)

a=corr([d.anger d.fear d.disgust d.sadness]);
a(a==1)=nan;
nanmean(a,2)

d.enthop=mean([d.enthusiasm d.hope],2);
d.prijoy=mean([d.pride d.joy],2);

%close all
figure
subplot(1,3,1)
h=shadedErrorBar(1:1461,movmean(grpstats(d.anger,d.dayn),mm),movmean(grpstats(d.anger,d.dayn,'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('red'); h.patch.FaceColor=rgb('red');
h.mainLine.LineWidth=1.5;

hold on
h=shadedErrorBar(1:1461,movmean(grpstats(d.fear,d.dayn),mm),movmean(grpstats(d.fear,d.dayn,'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('bluegreen'); h.patch.FaceColor=rgb('bluegreen');
h.mainLine.LineWidth=1.5;

hold on
h=shadedErrorBar(1:1461,movmean(grpstats(d.disgust,d.dayn),mm),movmean(grpstats(d.disgust,d.dayn,'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('brown'); h.patch.FaceColor=rgb('brown');
h.mainLine.LineWidth=1.5;

hold on
h=shadedErrorBar(1:1461,movmean(grpstats(d.sadness,d.dayn),mm),movmean(grpstats(d.sadness,d.dayn,'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('blue'); h.patch.FaceColor=rgb('blue');
h.mainLine.LineWidth=1.5;

hold on
h=shadedErrorBar(1:1461,movmean(grpstats(d.enthop,d.dayn),mm),movmean(grpstats(d.enthop,d.dayn,'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('gold'); h.patch.FaceColor=rgb('gold');
h.mainLine.LineWidth=1.5;

hold on
h=shadedErrorBar(1:1461,movmean(grpstats(d.prijoy,d.dayn),mm),movmean(grpstats(d.prijoy,d.dayn,'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('pink'); h.patch.FaceColor=rgb('pink');
h.mainLine.LineWidth=1.5;

title('All tweets','fontsize',14)
xlabel('Time (months)','fontsize',14); 
ylabel('Probability of different emotions','fontsize',14)
set(gca,'xtick',(1:st:length(wyu)))
set(gca,'xticklabels',wyu(1:st:length(wyu),:),'fontsize',12)
xtickangle(45)
set(gca,'ytick',0:.1:1)
ylim([0 1])
grid

hold on
for ev=1:length(events)
    plot([events(ev) events(ev)],[-.1 1],'color',rgb('Grey'),'linewidth',1); hold on
    yl=ylim; text(events(ev)+2, yl(1)+.03*yl(2),event_names{ev})
end


subplot(1,3,2)
filt=d.hate_score<.3;
h=shadedErrorBar(1:1461,movmean(grpstats(d.anger(filt),d.dayn(filt)),mm),movmean(grpstats(d.anger(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('red'); h.patch.FaceColor=rgb('red');
h.mainLine.LineWidth=1.5;

hold on
h=shadedErrorBar(1:1461,movmean(grpstats(d.fear(filt),d.dayn(filt)),mm),movmean(grpstats(d.fear(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('bluegreen'); h.patch.FaceColor=rgb('bluegreen');
h.mainLine.LineWidth=1.5;

hold on
h=shadedErrorBar(1:1461,movmean(grpstats(d.disgust(filt),d.dayn(filt)),mm),movmean(grpstats(d.disgust(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('brown'); h.patch.FaceColor=rgb('brown');
h.mainLine.LineWidth=1.5;

hold on
h=shadedErrorBar(1:1461,movmean(grpstats(d.sadness(filt),d.dayn(filt)),mm),movmean(grpstats(d.sadness(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('blue'); h.patch.FaceColor=rgb('blue');
h.mainLine.LineWidth=1.5;

hold on
h=shadedErrorBar(1:1461,movmean(grpstats(d.enthop(filt),d.dayn(filt)),mm),movmean(grpstats(d.enthop(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('gold'); h.patch.FaceColor=rgb('gold');
h.mainLine.LineWidth=1.5;

hold on
h=shadedErrorBar(1:1461,movmean(grpstats(d.prijoy(filt),d.dayn(filt)),mm),movmean(grpstats(d.prijoy(filt),d.dayn(filt),'sem'),mm));
h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
h.mainLine.Color=rgb('pink'); h.patch.FaceColor=rgb('pink');
h.mainLine.LineWidth=1.5;

title('RI-like tweets','fontsize',14)
xlabel('Time (months)','fontsize',14); 
ylabel('Probability of different emotions','fontsize',14)
set(gca,'xtick',(1:st:length(wyu)))
set(gca,'xticklabels',wyu(1:st:length(wyu),:),'fontsize',12)
xtickangle(45)
set(gca,'ytick',0:.1:1)
ylim([0 1])
grid

hold on
for ev=1:length(events)
    plot([events(ev) events(ev)],[-.1 1],'color',rgb('Grey'),'linewidth',1); hold on
    yl=ylim; text(events(ev)+2, yl(1)+.03*yl(2),event_names{ev})
end


subplot(1,3,3)
filt=d.hate_score>.7;
h1=shadedErrorBar(1:1461,movmean(grpstats(d.anger(filt),d.dayn(filt)),mm),movmean(grpstats(d.anger(filt),d.dayn(filt),'sem'),mm));
h1.edge(1).Visible='Off'; h1.edge(2).Visible='Off';
h1.mainLine.Color=rgb('red'); h1.patch.FaceColor=rgb('red');
h1.mainLine.LineWidth=1.5;

hold on
h2=shadedErrorBar(1:1461,movmean(grpstats(d.fear(filt),d.dayn(filt)),mm),movmean(grpstats(d.fear(filt),d.dayn(filt),'sem'),mm));
h2.edge(1).Visible='Off'; h2.edge(2).Visible='Off';
h2.mainLine.Color=rgb('bluegreen'); h2.patch.FaceColor=rgb('bluegreen');
h2.mainLine.LineWidth=1.5;

hold on
h3=shadedErrorBar(1:1461,movmean(grpstats(d.disgust(filt),d.dayn(filt)),mm),movmean(grpstats(d.disgust(filt),d.dayn(filt),'sem'),mm));
h3.edge(1).Visible='Off'; h3.edge(2).Visible='Off';
h3.mainLine.Color=rgb('brown'); h3.patch.FaceColor=rgb('brown');
h3.mainLine.LineWidth=1.5;

hold on
h4=shadedErrorBar(1:1461,movmean(grpstats(d.sadness(filt),d.dayn(filt)),mm),movmean(grpstats(d.sadness(filt),d.dayn(filt),'sem'),mm));
h4.edge(1).Visible='Off'; h4.edge(2).Visible='Off';
h4.mainLine.Color=rgb('blue'); h4.patch.FaceColor=rgb('blue');
h4.mainLine.LineWidth=1.5;

hold on
h5=shadedErrorBar(1:1461,movmean(grpstats(d.enthop(filt),d.dayn(filt)),mm),movmean(grpstats(d.enthop(filt),d.dayn(filt),'sem'),mm));
h5.edge(1).Visible='Off'; h5.edge(2).Visible='Off';
h5.mainLine.Color=rgb('gold'); h5.patch.FaceColor=rgb('gold');
h5.mainLine.LineWidth=1.5;

hold on
h6=shadedErrorBar(1:1461,movmean(grpstats(d.prijoy(filt),d.dayn(filt)),mm),movmean(grpstats(d.prijoy(filt),d.dayn(filt),'sem'),mm));
h6.edge(1).Visible='Off'; h6.edge(2).Visible='Off';
h6.mainLine.Color=rgb('pink'); h6.patch.FaceColor=rgb('pink');
h6.mainLine.LineWidth=1.5;

title('RG-like tweets','fontsize',14)
xlabel('Time (months)','fontsize',14); 
ylabel('Probability of different emotions','fontsize',14)
set(gca,'xtick',(1:st:length(wyu)))
set(gca,'xticklabels',wyu(1:st:length(wyu),:),'fontsize',12)
xtickangle(45)
set(gca,'ytick',0:.1:1)
ylim([0 1])
grid
%l=legend('Anger','Fear','Disgust','Sadness','Enthusiasm/Hope','Pride/Joy','location','northwest'); l.FontSize=11;

hold on
for ev=1:length(events)
    plot([events(ev) events(ev)],[-.1 1],'color',rgb('Grey'),'linewidth',1); hold on
    yl=ylim; text(events(ev)+2, yl(1)+.03*yl(2),event_names{ev})
end

l=legend([h1.mainLine h2.mainLine h3.mainLine h4.mainLine h5.mainLine h6.mainLine],'Anger','Fear','Disgust','Sadness','Enthusiasm/Hope','Pride/Joy','location','northwest');
l.FontSize=12;




