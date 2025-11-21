% run fin_data_prep_day first
%close all
figure
subplot(3,2,1)

h1=shadedErrorBar(dd.dbd_dayn,movmean(dd.dbd_speech_hate_yes,mm),movmean(dd_sem.dbd_speech_hate_yes,mm));
h1.edge(1).Visible='Off'; h1.edge(2).Visible='Off';
h1.mainLine.Color='r'; h1.patch.FaceColor='r'; %rgb('Red');
h1.mainLine.LineWidth=1.5;

hold on
h2=shadedErrorBar(dd.dbd_dayn,movmean(dd.dbd_tox,mm),movmean(dd_sem.dbd_tox,mm));
h2.edge(1).Visible='Off'; h2.edge(2).Visible='Off';
h2.mainLine.Color=[153, 0, 0]/255; h2.patch.FaceColor=[153, 0, 0]/255;
h2.mainLine.LineWidth=1.5;

hold on
h3=shadedErrorBar(dd.dbd_dayn,movmean(dd.dbd_extreme_score,mm),movmean(dd_sem.dbd_extreme_score,mm));
h3.edge(1).Visible='Off'; h3.edge(2).Visible='Off';
h3.mainLine.Color=[255, 102, 0]/255; h3.patch.FaceColor=[255, 102, 0]/255;
h3.mainLine.LineWidth=1.5;

hold on
h4=shadedErrorBar(dd.dbd_dayn,movmean(dd.dbd_user_group_70e,mm),movmean(dd_sem.dbd_user_group_70e,mm));
h4.edge(1).Visible='Off'; h4.edge(2).Visible='Off';
h4.mainLine.Color=[204, 153, 0]/255; h4.patch.FaceColor=[204, 153, 0]/255;
h4.mainLine.LineWidth=1.5;

xlabel('Time (months)','fontsize',11); 
ylabel('Average probability','fontsize',11)

step=1:st:height(dd);
set(gca,'xtick',dd.dbd_dayn(step))
set(gca,'xticklabels',num2str([dd.dbd_month(step) dd.dbd_years(step)]),'fontsize',11)
set(gca,'ytick',0:.05:.35)
set(gca,'yticklabels',0:.05:.35,'fontsize',11)
xtickangle(45)
xlim([min(dd.dbd_dayn)-5 max(dd.dbd_dayn)+5])
ylim([0 .36])
grid

hold on
for ev=1:length(events)
    plot([events(ev) events(ev)]+min(dd.dbd_dayn),[-.1 1],'color',[0.7  0.7  0.7],'linewidth',1); hold on
    yl=ylim; text(events(ev)+2+min(dd.dbd_dayn), yl(1)+.03*yl(2),event_names{ev})
end

l=legend([h1.mainLine h2.mainLine h3.mainLine h4.mainLine],'Hate speech','Toxicity','Extremity of speech','Extremity of speakers','location','northwest');
l.FontSize=10;

title("A. Incivility and extremity",'fontsize',11)

% normalized trends
subplot(3,2,2)
h1=plot(dd.dbd_dayn,(movmean(dd.dbd_speech_hate_yes,mm)-min(movmean(dd.dbd_speech_hate_yes,mm)))./(max(movmean(dd.dbd_speech_hate_yes,mm))-min(movmean(dd.dbd_speech_hate_yes,mm))),'color','r','linewidth',1.5);
hold on
h2=plot(dd.dbd_dayn,(movmean(dd.dbd_tox,mm)-min(movmean(dd.dbd_tox,mm)))./(max(movmean(dd.dbd_tox,mm))-min(movmean(dd.dbd_tox,mm))),'color',[153, 0, 0]/255,'linewidth',1.5);
hold on
h3=plot(dd.dbd_dayn,(movmean(dd.dbd_extreme_score,mm)-min(movmean(dd.dbd_extreme_score,mm)))./(max(movmean(dd.dbd_extreme_score,mm))-min(movmean(dd.dbd_extreme_score,mm))),'color',[255, 102, 0]/255,'linewidth',1.5);
hold on
h4=plot(dd.dbd_dayn,(movmean(dd.dbd_user_group_70e,mm)-min(movmean(dd.dbd_user_group_70e,mm)))./(max(movmean(dd.dbd_user_group_70e,mm))-min(movmean(dd.dbd_user_group_70e,mm))),'color',[204, 153, 0]/255,'linewidth',1.5);
box off

xlabel('Time (months)','fontsize',11); 
ylabel({'Normalized avg.','probability'},'fontsize',11)

step=1:st:height(dd);
set(gca,'xtick',dd.dbd_dayn(step))
set(gca,'xticklabels',num2str([dd.dbd_month(step) dd.dbd_years(step)]),'fontsize',11)
xtickangle(45)
xlim([min(dd.dbd_dayn)-5 max(dd.dbd_dayn)+5])
ylim([0 1.01])
grid

hold on
for ev=1:length(events)
    plot([events(ev) events(ev)]+min(dd.dbd_dayn),[-.1 1],'color',[0.7  0.7  0.7],'linewidth',1); hold on
    yl=ylim; text(events(ev)+2+min(dd.dbd_dayn), yl(1)+.03*yl(2),event_names{ev})
end

l=legend([h1 h2 h3 h4],'Hate speech','Toxicity','Extremity of speech','Extremity of speakers','location','northwest');
l.FontSize=10;

title("B. Incivility and extremity (normalized)",'fontsize',11)


%% extremity and toxicity
subplot(3,2,3)

d.hate_score_r=round(d.hate_score,1);
errorbar(unique(d.hate_score_r),grpstats(d.speech_hate_yes,d.hate_score_r),1.96*grpstats(d.speech_hate_yes,d.hate_score_r,{'sem'}),'--','color','r','linewidth',1)
hold on
d.user_hate_score_r=round(d.user_hate_score,1);
errorbar(unique(d.user_hate_score_r),grpstats(d.speech_hate_yes,d.user_hate_score_r),1.96*grpstats(d.speech_hate_yes,d.user_hate_score_r,{'sem'}),'color','r','linewidth',1)
hold on

d.hate_score_r=round(d.hate_score,1);
errorbar(unique(d.hate_score_r),grpstats(d.tox,d.hate_score_r),1.96*grpstats(d.tox,d.hate_score_r,{'sem'}),'--','color',[153, 0, 0]/255,'linewidth',1)
hold on
d.user_hate_score_r=round(d.user_hate_score,1);
errorbar(unique(d.user_hate_score_r),grpstats(d.tox,d.user_hate_score_r),1.96*grpstats(d.tox,d.user_hate_score_r,{'sem'}),'color',[153, 0, 0]/255,'linewidth',1)
hold on

l=legend('Speech: Hate by extremity','Speakers: Hate by extremity',...
    'Speech: Toxicity by extremity','Speakers: Toxicity by extremity','location','north');
l.FontSize=10;

xlabel({'Extremity of speakers','and speech'},'fontsize',11)
ylabel('Mean toxicity by extremity','fontsize',11); 
xlim([-.05 1.05]); 
set(gca,'xtick',[0:.1:1])
set(gca,'xticklabels',{'RI-like','','','','','','','','','','RG-like'},'fontsize',11)
grid
box off

title("C. Toxicity by extremity",'fontsize',11)

% %% hatespeech and toxicity
% subplot(2,3,3)
% d.speech_hate_yes_r=round(d.speech_hate_yes,1);
% errorbar(unique(d.speech_hate_yes_r),grpstats(d.tox,d.speech_hate_yes_r),1.96*grpstats(d.tox,d.speech_hate_yes_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
% xlabel('Probability of hate speech','fontsize',11); 
% ylabel({'Mean toxicity by','probability of hate speech'},'fontsize',11)
% xlim([-.05 1.05]); xlim([-.05 1.05]); ylim([.1 .6])
% set(gca,'xtick',0:.2:1)
% set(gca,'xticklabels',0:.2:1,'fontsize',11)
% grid
% box off
% 
% title("C. Toxicity by hate",'fontsize',11)

%% strategies
subplot(3,2,4)
h1=shadedErrorBar(1:1461,movmean(grpstats(d.strategy_opin,d.dayn),mm),movmean(grpstats(d.strategy_opin,d.dayn,'sem'),mm));
h1.edge(1).Visible='Off'; h1.edge(2).Visible='Off';
h1.mainLine.Color=[0, 153, 255]/255; h1.patch.FaceColor=[0, 153, 255]/255;
h1.mainLine.LineWidth=1.5;

hold on
h2=shadedErrorBar(1:1461,movmean(grpstats(d.strategy_construct,d.dayn),mm),movmean(grpstats(d.strategy_construct,d.dayn,'sem'),mm));
h2.edge(1).Visible='Off'; h2.edge(2).Visible='Off';
h2.mainLine.Color='b'; h2.patch.FaceColor='b';
h2.mainLine.LineWidth=1.5;

hold on
h3=shadedErrorBar(1:1461,movmean(grpstats(d.strategy_sarc,d.dayn),mm),movmean(grpstats(d.strategy_sarc,d.dayn,'sem'),mm));
h3.edge(1).Visible='Off'; h3.edge(2).Visible='Off';
h3.mainLine.Color=[255, 102, 0]/255; h3.patch.FaceColor=[255, 102, 0]/255;
h3.mainLine.LineWidth=1.5;

hold on
h4=shadedErrorBar(1:1461,movmean(grpstats(d.strategy_leave_fact,d.dayn),mm),movmean(grpstats(d.strategy_leave_fact,d.dayn,'sem'),mm));
h4.edge(1).Visible='Off'; h4.edge(2).Visible='Off';
h4.mainLine.Color='r'; h4.patch.FaceColor='r';
h4.mainLine.LineWidth=1.5;

hold on
h5=shadedErrorBar(1:1461,movmean(grpstats(d.strategy_other_new,d.dayn),mm),movmean(grpstats(d.strategy_other_new,d.dayn,'sem'),mm));
h5.edge(1).Visible='Off'; h5.edge(2).Visible='Off';
h5.mainLine.Color=[0.7  0.7  0.7]; h5.patch.FaceColor=[0.7  0.7  0.7];
h5.mainLine.LineWidth=1.5;

xlabel('Time (months)','fontsize',11); 
ylabel('Probability of different strategies','fontsize',11)
set(gca,'xtick',(1:st:length(wyu)))
set(gca,'xticklabels',wyu(1:st:length(wyu),:),'fontsize',11)
xtickangle(45)
ylim([0 .5])
grid

hold on
for ev=1:length(events)
    plot([events(ev) events(ev)],[-.1 1],'color',[0.7  0.7  0.7],'linewidth',1); hold on
    yl=ylim; text(events(ev)+2, yl(1)+.03*yl(2),event_names{ev})
end

l=legend([h1.mainLine h2.mainLine h3.mainLine h4.mainLine h5.mainLine],'Opinion','Constructive','Sarcasm','Insults','Other','location','northwest');
l.FontSize=10;

title("D. Argumentation strategies",'fontsize',11)

%% goals
subplot(3,2,5)
h1=shadedErrorBar(1:1461,movmean(grpstats(d.goal2_in_both_positive,d.dayn),mm),movmean(grpstats(d.goal2_in_both_positive,d.dayn,'sem'),mm));
h1.edge(1).Visible='Off'; h1.edge(2).Visible='Off';
h1.mainLine.Color=[0, 153, 153]/255; h1.patch.FaceColor=[0, 153, 153]/255;
h1.mainLine.LineWidth=1.5;

hold on
h2=shadedErrorBar(1:1461,movmean(grpstats(d.goal2_out_negative,d.dayn),mm),movmean(grpstats(d.goal2_out_negative,d.dayn,'sem'),mm));
h2.edge(1).Visible='Off'; h2.edge(2).Visible='Off';
h2.mainLine.Color=[255, 102, 0]/255; h2.patch.FaceColor=[255, 102, 0]/255;
h2.mainLine.LineWidth=1.5;

hold on
h3=shadedErrorBar(1:1461,movmean(grpstats(d.goal2_neutral_unint,d.dayn),mm),movmean(grpstats(d.goal2_neutral_unint,d.dayn,'sem'),mm));
h3.edge(1).Visible='Off'; h3.edge(2).Visible='Off';
h3.mainLine.Color=[0.7  0.7  0.7]; h3.patch.FaceColor=[0.7  0.7  0.7];
h3.mainLine.LineWidth=1.5;

xlabel('Time (months)','fontsize',11); 
ylabel('Probability of different goals','fontsize',11)
set(gca,'xtick',(1:st:length(wyu)))
set(gca,'xticklabels',wyu(1:st:length(wyu),:),'fontsize',11)
xtickangle(45)
ylim([0 .8])
grid
%l=legend('Positive about own or both groups','Negative about outgroup','Other','location','northwest'); l.FontSize=11;

hold on
for ev=1:length(events)
    plot([events(ev) events(ev)],[-.1 1],'color',[0.7  0.7  0.7],'linewidth',1); hold on
    yl=ylim; text(events(ev)+2, yl(1)+.03*yl(2),event_names{ev})
end

l=legend([h1.mainLine h2.mainLine h3.mainLine],'Inclusionary about in/both groups','Exclusionary about outgroup','Other','location','northwest');
l.FontSize=10;

title("E. Ingroup/Outgroup content",'fontsize',11)

%% emotions
subplot(3,2,6)
d.enthop=mean([d.enthusiasm d.hope],2);
d.prijoy=mean([d.pride d.joy],2);

h1=shadedErrorBar(1:1461,movmean(grpstats(d.anger,d.dayn),mm),movmean(grpstats(d.anger,d.dayn,'sem'),mm));
h1.edge(1).Visible='Off'; h1.edge(2).Visible='Off';
h1.mainLine.Color='r'; h1.patch.FaceColor='r';
h1.mainLine.LineWidth=1.5;

hold on
h2=shadedErrorBar(1:1461,movmean(grpstats(d.fear,d.dayn),mm),movmean(grpstats(d.fear,d.dayn,'sem'),mm));
h2.edge(1).Visible='Off'; h2.edge(2).Visible='Off';
h2.mainLine.Color=[0, 153, 153]/255; h2.patch.FaceColor=[0, 153, 153]/255;
h2.mainLine.LineWidth=1.5;

hold on
h3=shadedErrorBar(1:1461,movmean(grpstats(d.disgust,d.dayn),mm),movmean(grpstats(d.disgust,d.dayn,'sem'),mm));
h3.edge(1).Visible='Off'; h3.edge(2).Visible='Off';
h3.mainLine.Color=[153, 102, 51]/255; h3.patch.FaceColor=[153, 102, 51]/255;
h3.mainLine.LineWidth=1.5;

hold on
h4=shadedErrorBar(1:1461,movmean(grpstats(d.sadness,d.dayn),mm),movmean(grpstats(d.sadness,d.dayn,'sem'),mm));
h4.edge(1).Visible='Off'; h4.edge(2).Visible='Off';
h4.mainLine.Color='b'; h4.patch.FaceColor='b';
h4.mainLine.LineWidth=1.5;

hold on
h5=shadedErrorBar(1:1461,movmean(grpstats(d.enthop,d.dayn),mm),movmean(grpstats(d.enthop,d.dayn,'sem'),mm));
h5.edge(1).Visible='Off'; h5.edge(2).Visible='Off';
h5.mainLine.Color=[204, 153, 0]/255; h5.patch.FaceColor=[204, 153, 0]/255;
h5.mainLine.LineWidth=1.5;

hold on
h6=shadedErrorBar(1:1461,movmean(grpstats(d.prijoy,d.dayn),mm),movmean(grpstats(d.prijoy,d.dayn,'sem'),mm));
h6.edge(1).Visible='Off'; h6.edge(2).Visible='Off';
h6.mainLine.Color=[204, 102, 153]/255; h6.patch.FaceColor=[204, 102, 153]/255;
h6.mainLine.LineWidth=1.5;

xlabel('Time (months)','fontsize',11); 
ylabel('Probability of different emotions','fontsize',11)
set(gca,'xtick',(1:st:length(wyu)))
set(gca,'xticklabels',wyu(1:st:length(wyu),:),'fontsize',11)
xtickangle(45)
set(gca,'ytick',0:.1:1)
ylim([0 1])
grid

hold on
for ev=1:length(events)
    plot([events(ev) events(ev)],[-.1 1],'color',[0.8  0.8  0.8],'linewidth',1); hold on
    yl=ylim; text(events(ev)+2, yl(1)+.03*yl(2),event_names{ev})
end

l=legend([h1.mainLine h2.mainLine h3.mainLine h4.mainLine h5.mainLine h6.mainLine],'Anger','Fear','Disgust','Sadness','Enthusiasm/Hope','Pride/Joy','location','northwest');
l.FontSize=10;

title("F. Emotional tone",'fontsize',11)