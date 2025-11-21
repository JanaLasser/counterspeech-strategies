clear; clc; close all
set(0,'DefaultFigureWindowStyle','docked')
set(0,'defaultTextInterpreter','none') % 'latex'

format long g

%% file with sentiments and additional classes
tic
d=readtable('data.csv','Delimiter',',');
toc

%% remove -1, 18151
d(d.hate_score==-1 & d.counter_score==-1,:)=[];

%% remove text vars
d.text=[];

%% reduce text variables further
[d.root_account2,roots]=grp2idx(d.root_account);

rootable=table();
for i=1:max(d.root_account2)
    rootable{i,1}=i;
    rootable{i,2}=unique(d.root_account(d.root_account2==i));
end

d.root_account=[];
[d.strategy2,strategy]=grp2idx(d.strategy);
d.strategy=[];
[d.topic2,topic]=grp2idx(d.topic);
d.topic=[];
[d.goal2,goal]=grp2idx(d.goal);
d.goal=[];
[d.speech_hate2,speech_hate]=grp2idx(d.speech_hate);
d.speech_hate=[];
[d.speech_group2,speech_group]=grp2idx(d.speech_group);
d.speech_group=[];

[d.strategy_human_label2,strategy_human_label]=grp2idx(d.strategy_human_label);
d.strategy_human_label=[];
[d.topic_human_label2,topic_human_label]=grp2idx(d.topic_human_label);
d.topic_human_label=[];
[d.goal_human_label2,goal_human_label]=grp2idx(d.goal_human_label);
d.goal_human_label=[];
[d.speech_hate_human_label2,speech_hate_human_label]=grp2idx(d.speech_hate_human_label);
d.speech_hate_human_label=[];
[d.speech_group_human_label2,speech_group_human_label]=grp2idx(d.speech_group_human_label);
d.speech_group_human_label=[];

[d.strategy_human_label_confident2,strategy_human_label_confident]=grp2idx(d.strategy_human_label_confident);
d.strategy_human_label_confident=[];
[d.topic_human_label_confident2,topic_human_label_confident]=grp2idx(d.topic_human_label_confident);
d.topic_human_label_confident=[];
[d.goal_human_label_confident2,goal_human_label_confident]=grp2idx(d.goal_human_label_confident);
d.goal_human_label_confident=[];
[d.speech_hate_human_label_confident2,speech_hate_human_label_confident]=grp2idx(d.speech_hate_human_label_confident);
d.speech_hate_human_label_confident=[];
[d.speech_group_human_label_confident2,speech_group_human_label_confident]=grp2idx(d.speech_group_human_label_confident);
d.speech_group_human_label_confident=[];


%% remove -1 from toxicity variables
tempvars={'PROFANITY','TOXICITY','INSULT','IDENTITY_ATTACK','THREAT'};
for i=1:length(tempvars)
    temp=d{:,contains(d.Properties.VariableNames,tempvars{i})};
    temp(temp==-1)=nan;
    d{:,contains(d.Properties.VariableNames,tempvars{i})}=temp;
end
% critical vars for next tweet etc
cvs={'tree_nr';'tweet_nr';'user_twitter_id';'hate_score';'counter_score';'valence';'arousal';'dominance';...
    'goodness';'energy';'power';'danger';'structure';'valence_similarity';'arousal_similarity';'dominance_similarity';...
    'goodness_similarity';'energy_similarity';'power_similarity';'danger_similarity';'structure_similarity';'PROFANITY';'TOXICITY';...
    'INSULT';'SEVERE_TOXICITY';'IDENTITY_ATTACK';'THREAT';...
    'anger';'fear';'disgust';'sadness';'joy';'enthusiasm';'pride';'hope';...
    'strategy_construct';'strategy_opin';'strategy_sarc';'strategy_leave_fact';...
    'strategy_other_new';'topic_not_out';'topic_out';'topic2_in_both';...
    'topic2_out';'topic2_neutral_unint';'goal_other';'goal_weak';...
    'goal_neutral';'goal2_in_both_positive';'goal2_out_negative';...
    'goal2_neutral_unint';'speech_hate_yes';'speech_hate_no';...
    'speech_group_inst';'speech_group_right_wing';'speech_group_left_wing';...
    'speech_group_vulnerable';'speech_group_other_new'};


%% next tweet 
d=sortrows(d,{'tree_nr','tweet_nr'}); 
%vars=d.Properties.VariableNames(:,cvs)';
vars=cvs;
for v=1:length(vars); vars_next{v}=['next_',vars{v}]; end
w=width(d);
d{:,w+1:w+length(vars)}=nan;
d.Properties.VariableNames(:,w+1:w+length(vars))=vars_next;
d{1:end-1,w+1:w+length(vars)}=d{2:end,cvs};
d{d.tree_nr~=d.next_tree_nr,w+1:w+length(vars)}=nan;

%% mean of the rest of tree 
for v=1:length(vars); vars_all{v}=['all_',vars{v}]; end
for tn=0:max(d.tweet_nr)
    tn
    tic
    dtemp=d(d.tweet_nr>=tn,:);
    %try    
    tmean=grpstats(dtemp{:,contains(dtemp.Properties.VariableNames, 'next_')},dtemp.next_tree_nr); % for the first tweet
    tmean=[repmat(tn,size(tmean,1),1) tmean];
    tmeans = array2table(tmean);     
    tmeans.Properties.VariableNames(:,2:end)=vars_all;
    tmeans.Properties.VariableNames(:,2)={'tree_nr'};
    tmeans.Properties.VariableNames(:,1)={'tweet_nr'};
    if tn==0; dxtemp=tmeans; else dxtemp=[dxtemp;tmeans]; end
    %end
    toc
end
dxtemp=sortrows(dxtemp,{'tree_nr','tweet_nr'});
dx=outerjoin(d,dxtemp,'Keys',{'tree_nr','tweet_nr'},'MergeKeys', 1);
dx(isnan(dx.tree_id),:)=[];
d=dx;
clear dx dxtemp

%% mean of direct replies
for v=1:length(vars); vars_re{v}=['re_',vars{v}]; end
% first grpstats all replies to a tweet
[treplied,tmeanreplies]=grpstats(d{:,cvs},d.in_reply_to,{'gname','mean'}); 
treplies = array2table(tmeanreplies);  
treplies{:,1}=str2double(treplied);
treplies.Properties.VariableNames(:,1:end)=vars_re;
treplies.Properties.VariableNames(:,1)={'tweet_id'};

treplies=sortrows(treplies,1);
d=sortrows(d,{'tweet_id'});
dx=outerjoin(d,treplies,'Keys',{'tweet_id'},'MergeKeys', 1);
dx(isnan(dx.tree_id),:)=[]; % 2174 tweets replied to but not in the database
d=dx;
clear dx

%% date recodes
d.date=datetime(d.created_at,'InputFormat','eee MMM d HH:mm:ss Z yyyy','TimeZone','local');
d.weeks=week(d.date);
d.years=year(d.date);
d.wy=[datenum(d.years) + datenum(d.weeks)/100];


%% split d file into several smaller ones
% joint id
d.id=[1:height(d)]';

d_basic=[array2table(d.id) d(:,[1:79 252:256])];
d_id=[array2table(d.id) d(:,strcmp(d.Properties.VariableNames, 'tweet_nr')) d(:,strcmp(d.Properties.VariableNames, 'user_twitter_id')) ...
    d(:,strcmp(d.Properties.VariableNames, 'tree_nr')) d(:,strcmp(d.Properties.VariableNames, 'date')) ...
    d(:,strcmp(d.Properties.VariableNames, 'weeks')) d(:,strcmp(d.Properties.VariableNames, 'years')) ...
    d(:,strcmp(d.Properties.VariableNames, 'wy'))];
d_next=[array2table(d.id) d(:,contains(d.Properties.VariableNames, 'next_'))];
d_all=[array2table(d.id) d(:,contains(d.Properties.VariableNames, 'all'))];
d_re=[array2table(d.id) d(:,contains(d.Properties.VariableNames, 're_'))];

d_basic.id=[];
d_basic.Properties.VariableNames(:,1)={'id'};
d_id.Properties.VariableNames(:,1)={'id'};
d_next.Properties.VariableNames(:,1)={'id'};
d_all.Properties.VariableNames(:,1)={'id'};
d_re.Properties.VariableNames(:,1)={'id'};

tic
savefast d_all d_all
toc
tic
savefast d_id d_id
toc
tic
savefast d_next d_next
toc
tic
savefast d_re d_re
toc
tic
savefast d_basic d_basic
toc

tic
savefast d d
toc
clear d

%% attach day
d_basic.day=day(d_basic.date);
d_basic.month=month(d_basic.date);
d_basic=sortrows(d_basic,{'date'});
d_basic.date2=datetime(d_basic.years, d_basic.month, d_basic.day);
d_basic.dayn=grp2idx(d_basic.date2);

%% clean a bit more
d_basic.created_at=[];
d_basic.in_reply_to2=d_basic.in_reply_to;
d_basic.in_reply_to2(strcmp(d_basic.in_reply_to,'None'))={'nan'};
d_basic.in_reply_to2=str2double(d_basic.in_reply_to2);
d_basic.in_reply_to=[];

%% attach day
d_id.day=day(d_id.date);
d_id.month=month(d_id.date);
d_id=sortrows(d_id,1);
d_id.date2=datetime(d_id.years, d_id.month, d_id.day);
d_id.dayn=grp2idx(d_id.date2);

%% attach size of tree
trimax=grpstats(d_basic.tree_nr,d_basic.tree_nr,{'numel'});
trimax=array2table(trimax);
trimax=[array2table(unique(d_basic.tree_nr)) trimax];
trimax.Properties.VariableNames(:,1)={'tree_nr'}; trimax.Properties.VariableNames(:,2)={'tree_max3'};
d_basic=sortrows(d_basic,{'tree_nr'}); % sort by tree_nr
dx=outerjoin(d_basic,trimax,'Keys',{'tree_nr'},'MergeKeys', 1);
d_basic=dx; clear dx
d_basic=sortrows(d_basic,{'tree_nr','tweet_nr'}); % sort rows back, important

%% correct for missings in tree_nr - consecutive numbering - VALID FOR THE WHOLE PERIOD ONLY AND WITHOUT MISSINGS
d_basic=sortrows(d_basic,{'tree_nr','tweet_nr'});
treens=unique(d_basic.tree_nr);
d_basic.tweet_nr2=nan(height(d_basic),1);
for i=1:length(treens)
    d_basic.tweet_nr2(d_basic.tree_nr==treens(i),:)=1:sum(d_basic.tree_nr==treens(i));
end

%% log max 
d_basic.tweet_nr2_log=log10(d_basic.tweet_nr2+1);
d_basic.tree_max3_log=log10(d_basic.tree_max3);

%% mean tox
d_basic.tox=nanmean([d_basic.PROFANITY d_basic.TOXICITY d_basic.INSULT d_basic.SEVERE_TOXICITY d_basic.IDENTITY_ATTACK],2);
d_basic.next_tox=nanmean([d_next.next_PROFANITY d_next.next_TOXICITY d_next.next_INSULT d_next.next_SEVERE_TOXICITY d_next.next_IDENTITY_ATTACK],2);
d_basic.re_tox=nanmean([d_re.re_PROFANITY d_re.re_TOXICITY d_re.re_INSULT d_re.re_SEVERE_TOXICITY d_re.re_IDENTITY_ATTACK],2);
d_basic.all_tox=nanmean([d_all.all_PROFANITY d_all.all_TOXICITY d_all.all_INSULT d_all.all_SEVERE_TOXICITY d_all.all_IDENTITY_ATTACK],2);
d_basic.tbef_tox=nanmean([d_tbef.tbef_PROFANITY d_tbef.tbef_TOXICITY d_tbef.tbef_INSULT d_tbef.tbef_SEVERE_TOXICITY d_tbef.tbef_IDENTITY_ATTACK],2);
d_basic.dbef_tox=nanmean([d_dbef.dbef_PROFANITY d_dbef.dbef_TOXICITY d_dbef.dbef_INSULT d_dbef.dbef_SEVERE_TOXICITY d_dbef.dbef_IDENTITY_ATTACK],2);

%% mean of the tree before L
d_basic=sortrows(d_basic,{'tree_nr','tweet_nr'}); % sort by tree and tweet number - check
cvs={'id';'tree_nr';'tweet_nr';'user_twitter_id';'hate_score';'counter_score';'valence';'arousal';'dominance';...
    'goodness';'energy';'power';'danger';'structure';'valence_similarity';'arousal_similarity';'dominance_similarity';...
    'goodness_similarity';'energy_similarity';'power_similarity';'danger_similarity';'structure_similarity';'PROFANITY';'TOXICITY';...
    'INSULT';'SEVERE_TOXICITY';'IDENTITY_ATTACK';'THREAT';...
    'anger';'fear';'disgust';'sadness';'joy';'enthusiasm';'pride';'hope';...
    'strategy_construct';'strategy_opin';'strategy_sarc';'strategy_leave_fact';...
    'strategy_other_new';'topic_not_out';'topic_out';'topic2_in_both';...
    'topic2_out';'topic2_neutral_unint';'goal_other';'goal_weak';...
    'goal_neutral';'goal2_in_both_positive';'goal2_out_negative';...
    'goal2_neutral_unint';'speech_hate_yes';'speech_hate_no';...
    'speech_group_inst';'speech_group_right_wing';'speech_group_left_wing';...
    'speech_group_vulnerable';'speech_group_other_new'};
vars=cvs;
for v=1:length(vars); vars_tbef{v}=['tbef_',vars{v}]; end

for tn=1:max(d_basic.tweet_nr)
    tn
    tic
    dtemp=d_basic(d_basic.tweet_nr2<tn & d_basic.tree_max3>=tn,:);
    tmean=grpstats(dtemp{:,cvs},dtemp.tree_nr);   
    tmean(:,3)=tn;
    if tn==1; dxtemp=tmean; else dxtemp=[dxtemp;tmean]; end
    toc
end
dxtemp = array2table(dxtemp); 
dxtemp.Properties.VariableNames=vars_tbef;
dxtemp.Properties.VariableNames(:,2)={'tree_nr'};
dxtemp.Properties.VariableNames(:,3)={'tweet_nr'};
dxtemp=sortrows(dxtemp,{'tree_nr','tweet_nr'});
dx=outerjoin(d_id,dxtemp,'Keys',{'tree_nr','tweet_nr'},'MergeKeys', 1);
dx(isnan(dx.id),:)=[];
d_tbef=dx;
d_basic=sortrows(d_basic,1); % sort rows back, important
d_tbef=sortrows(d_tbef,1); % sort rows back, important
save d_tbef d_tbef
save d_basic d_basic
clear dx

%% mean of the day before 
cvs={'id';'tree_nr';'tweet_nr';'user_twitter_id';'hate_score';'counter_score';'valence';'arousal';'dominance';...
    'goodness';'energy';'power';'danger';'structure';'valence_similarity';'arousal_similarity';'dominance_similarity';...
    'goodness_similarity';'energy_similarity';'power_similarity';'danger_similarity';'structure_similarity';'PROFANITY';'TOXICITY';...
    'INSULT';'SEVERE_TOXICITY';'IDENTITY_ATTACK';'THREAT';...
    'anger';'fear';'disgust';'sadness';'joy';'enthusiasm';'pride';'hope';...
    'strategy_construct';'strategy_opin';'strategy_sarc';'strategy_leave_fact';...
    'strategy_other_new';'topic_not_out';'topic_out';'topic2_in_both';...
    'topic2_out';'topic2_neutral_unint';'goal_other';'goal_weak';...
    'goal_neutral';'goal2_in_both_positive';'goal2_out_negative';...
    'goal2_neutral_unint';'speech_hate_yes';'speech_hate_no';...
    'speech_group_inst';'speech_group_right_wing';'speech_group_left_wing';...
    'speech_group_vulnerable';'speech_group_other_new'};
vars=cvs;
for v=1:length(vars); vars_dbef{v}=['dbef_',vars{v}]; end
tmean=grpstats(d_basic{:,cvs},d_basic.dayn);  
tmeans = array2table(tmean);     
tmeans.Properties.VariableNames=vars_dbef;
tmeans.Properties.VariableNames(:,1)={'dayn'};

dx=outerjoin(d_id,tmeans,'Keys',{'dayn'},'MergeKeys', 1);
d_dbef=dx;
d_dbef(isnan(d_dbef.id),:)=[];
save d_dbef d_dbef
clear dx


%% a few additional adjustments
tic
load d_basic2 % d_basic is now only 15-18, with tox nans; d_basic2 is d_basic without tox nans; rerun above to get the whole d_basic again
load d_id % rerun above for before 2015
load d_next
load d_re
load d_all
load d_tbef
load d_dbef
toc

%% making sure the files are all sorted in the same way
load d_basic
d_basic=sortrows(d_basic,1);
d_basic2=sortrows(d_basic2,1);
d_id=sortrows(d_id,1);
d_next=sortrows(d_next,1);
d_re=sortrows(d_re,1);
d_all=sortrows(d_all,1);
d_tbef=sortrows(d_tbef,1);
d_dbef=sortrows(d_dbef,1);

d_basic.Properties.VariableNames(:,20)={'threat'};

%% remove cases with missing tox
d_basic(isnan(d_basic.tox),:)=[];

d_id(isnan(d_basic2.tox),:)=[];
d_next(isnan(d_basic2.tox),:)=[];
d_re(isnan(d_basic2.tox),:)=[];
d_all(isnan(d_basic2.tox),:)=[];
d_tbef(isnan(d_basic2.tox),:)=[];
d_dbef(isnan(d_basic2.tox),:)=[];

%% recode speech_group by hate_speech
corr([d_basic.speech_hate_yes d_basic.speech_group_inst d_basic.speech_group_right_wing ...
    d_basic.speech_group_left_wing d_basic.speech_group_vulnerable d_basic.speech_group_other_new])

d_basic.speech_group_inst2=d_basic.speech_group_inst; d_basic.speech_group_inst2(isnan(d_basic.speech_group_inst))=0;
d_basic.speech_group_right_wing2=d_basic.speech_group_right_wing; d_basic.speech_group_right_wing2(isnan(d_basic.speech_group_right_wing))=0;
d_basic.speech_group_left_wing2=d_basic.speech_group_left_wing; d_basic.speech_group_left_wing2(isnan(d_basic.speech_group_left_wing))=0;
d_basic.speech_group_vulnerable2=d_basic.speech_group_vulnerable; d_basic.speech_group_vulnerable2(isnan(d_basic.speech_group_vulnerable))=0;
d_basic.speech_group_other_new2=d_basic.speech_group_other_new; d_basic.speech_group_other_new2(isnan(d_basic.speech_group_other_new))=0;

%% select 2015-2018
d_basic=d_basic(d_basic.years>=2015 & d_basic.years<=2018,:);
d_id=d_id(d_id.years>=2015 & d_id.years<=2018,:);
d_next=d_next(d_id.years>=2015 & d_id.years<=2018,:);
d_re=d_re(d_id.years>=2015 & d_id.years<=2018,:);
d_all=d_all(d_id.years>=2015 & d_id.years<=2018,:);
d_tbef=d_tbef(d_id.years>=2015 & d_id.years<=2018,:);
d_dbef=d_dbef(d_id.years>=2015 & d_id.years<=2018,:);

%% calculate average user hate score
d_basic2=d_basic;

[aid amean]=grpstats(d_basic.hate_score,d_basic.user_twitter_id,{'gname','mean'});
for i=1:length(aid); aidn(i,:)=str2num(cell2mat(aid(i,:))); end

dx=array2table([aidn amean]);
dx.Properties.VariableNames={'user_twitter_id','user_hate_score'};

d_basic=sortrows(d_basic,30);
dx=sortrows(dx,1);
dx2=outerjoin(d_basic,dx,'Keys',{'user_twitter_id'},'MergeKeys', 1);
d_basic2=dx2;

d_basic2=sortrows(d_basic2,1);

d_basic2.user_group_70e(d_basic2.user_hate_score>.7 | d_basic2.user_hate_score<.3,:)=1;
d_basic2.user_group_80e(d_basic2.user_hate_score>.8 | d_basic2.user_hate_score<.2,:)=1;
d_basic2.user_group_90e(d_basic2.user_hate_score>.9 | d_basic2.user_hate_score<.1,:)=1;
d_basic2.user_group_95e(d_basic2.user_hate_score>.95 | d_basic2.user_hate_score<.05,:)=1;

d_basic2.user_group_70rg(d_basic2.user_hate_score>.7)=1;
d_basic2.user_group_70ri(d_basic2.user_hate_score<.3,:)=1;
d_basic2.user_group_80rg(d_basic2.user_hate_score>.8)=1;
d_basic2.user_group_80ri(d_basic2.user_hate_score<.2,:)=1;
d_basic2.user_group_90rg(d_basic2.user_hate_score>.9)=1;
d_basic2.user_group_90ri(d_basic2.user_hate_score<.1,:)=1;
d_basic2.user_group_95rg(d_basic2.user_hate_score>.95)=1;
d_basic2.user_group_95ri(d_basic2.user_hate_score<.05,:)=1;

grpstats(d_basic2.user_group_70rg,d_basic2.dayn,.95)
ylim([0 0.1])

%% prepare d_basic without missing tox 
d_basic=d_basic2;
d_basic(isnan(d_basic.tox),:)=[];

%% correct for missings in tree_nr 
d_basic=sortrows(d_basic,{'tree_nr','tweet_nr'});
treens=unique(d_basic.tree_nr);
d_basic.tweet_nr3=nan(height(d_basic),1);
d_basic.tree_max4=nan(height(d_basic),1);
for i=1:length(treens)
    i
    d_basic.tweet_nr3(d_basic.tree_nr==treens(i),:)=1:sum(d_basic.tree_nr==treens(i));
    d_basic.tree_max4(d_basic.tree_nr==treens(i),:)=sum(d_basic.tree_nr==treens(i));
end

%% this is the data file for all analyses, 1150469 tweets
save d_basic2 d_basic 
length(unique(d_basic.user_twitter_id)) % 130548 users
length(unique(d_basic.tree_id)) % 130127 trees


