%note most of the analyses are done on day-to-day data, or on a subset of longer trees, so i guess that's why i didn't notice the discrepancy at least. this was probably a number inferred from the database without taking the period into account.

clear; clc; close all
set(0,'DefaultFigureWindowStyle','docked')
set(0,'defaultTextInterpreter','none') % 'latex'

format long g

% file with sentiments and additional classes
% tic
% d=readtable('inferred_data8.csv','Delimiter',',');
% toc
% 
% %%% remove -1, 18151
% d(d.hate_score==-1 & d.counter_score==-1,:)=[];
% 
% %%% remove text vars
% d.text=[];
% 
% 
% %% reduce text further
% [d.root_account2,roots]=grp2idx(d.root_account);

% rootable=table();
% for i=1:max(d.root_account2)
%     rootable{i,1}=i;
%     rootable{i,2}=unique(d.root_account(d.root_account2==i));
% end

% d.root_account=[];
% [d.strategy2,strategy]=grp2idx(d.strategy);
% d.strategy=[];
% [d.topic2,topic]=grp2idx(d.topic);
% d.topic=[];
% [d.goal2,goal]=grp2idx(d.goal);
% d.goal=[];
% [d.speech_hate2,speech_hate]=grp2idx(d.speech_hate);
% d.speech_hate=[];
% [d.speech_group2,speech_group]=grp2idx(d.speech_group);
% d.speech_group=[];
% 
% [d.strategy_human_label2,strategy_human_label]=grp2idx(d.strategy_human_label);
% d.strategy_human_label=[];
% [d.topic_human_label2,topic_human_label]=grp2idx(d.topic_human_label);
% d.topic_human_label=[];
% [d.goal_human_label2,goal_human_label]=grp2idx(d.goal_human_label);
% d.goal_human_label=[];
% [d.speech_hate_human_label2,speech_hate_human_label]=grp2idx(d.speech_hate_human_label);
% d.speech_hate_human_label=[];
% [d.speech_group_human_label2,speech_group_human_label]=grp2idx(d.speech_group_human_label);
% d.speech_group_human_label=[];
% 
% [d.strategy_human_label_confident2,strategy_human_label_confident]=grp2idx(d.strategy_human_label_confident);
% d.strategy_human_label_confident=[];
% [d.topic_human_label_confident2,topic_human_label_confident]=grp2idx(d.topic_human_label_confident);
% d.topic_human_label_confident=[];
% [d.goal_human_label_confident2,goal_human_label_confident]=grp2idx(d.goal_human_label_confident);
% d.goal_human_label_confident=[];
% [d.speech_hate_human_label_confident2,speech_hate_human_label_confident]=grp2idx(d.speech_hate_human_label_confident);
% d.speech_hate_human_label_confident=[];
% [d.speech_group_human_label_confident2,speech_group_human_label_confident]=grp2idx(d.speech_group_human_label_confident);
% d.speech_group_human_label_confident=[];
% 
% 
% %% remove -1 from toxicity variables
% tempvars={'PROFANITY','TOXICITY','INSULT','IDENTITY_ATTACK','THREAT'};
% for i=1:length(tempvars)
%     temp=d{:,contains(d.Properties.VariableNames,tempvars{i})};
%     temp(temp==-1)=nan;
%     d{:,contains(d.Properties.VariableNames,tempvars{i})}=temp;
% end
% % critical vars for next tweet etc
% cvs={'tree_nr';'tweet_nr';'user_twitter_id';'hate_score';'counter_score';'valence';'arousal';'dominance';...
%     'goodness';'energy';'power';'danger';'structure';'valence_similarity';'arousal_similarity';'dominance_similarity';...
%     'goodness_similarity';'energy_similarity';'power_similarity';'danger_similarity';'structure_similarity';'PROFANITY';'TOXICITY';...
%     'INSULT';'SEVERE_TOXICITY';'IDENTITY_ATTACK';'THREAT';...
%     'anger';'fear';'disgust';'sadness';'joy';'enthusiasm';'pride';'hope';...
%     'strategy_construct';'strategy_opin';'strategy_sarc';'strategy_leave_fact';...
%     'strategy_other_new';'topic_not_out';'topic_out';'topic2_in_both';...
%     'topic2_out';'topic2_neutral_unint';'goal_other';'goal_weak';...
%     'goal_neutral';'goal2_in_both_positive';'goal2_out_negative';...
%     'goal2_neutral_unint';'speech_hate_yes';'speech_hate_no';...
%     'speech_group_inst';'speech_group_right_wing';'speech_group_left_wing';...
%     'speech_group_vulnerable';'speech_group_other_new'};
% % for each tweet, want to get all vars for 1) the next tweet in time, 
% % 2) all next tweets, 3) the replying tweet
% 
% %% next tweet - smarter way
% d=sortrows(d,{'tree_nr','tweet_nr'}); 
% %vars=d.Properties.VariableNames(:,cvs)';
% vars=cvs;
% for v=1:length(vars); vars_next{v}=['next_',vars{v}]; end
% w=width(d);
% d{:,w+1:w+length(vars)}=nan;
% d.Properties.VariableNames(:,w+1:w+length(vars))=vars_next;
% d{1:end-1,w+1:w+length(vars)}=d{2:end,cvs};
% d{d.tree_nr~=d.next_tree_nr,w+1:w+length(vars)}=nan;
% 
% %% mean of the rest of tree - smarter way
% for v=1:length(vars); vars_all{v}=['all_',vars{v}]; end
% for tn=0:max(d.tweet_nr)
%     tn
%     tic
%     dtemp=d(d.tweet_nr>=tn,:);
%     %try    
%     tmean=grpstats(dtemp{:,contains(dtemp.Properties.VariableNames, 'next_')},dtemp.next_tree_nr); % for the first tweet
%     tmean=[repmat(tn,size(tmean,1),1) tmean];
%     tmeans = array2table(tmean);     
%     tmeans.Properties.VariableNames(:,2:end)=vars_all;
%     tmeans.Properties.VariableNames(:,2)={'tree_nr'};
%     tmeans.Properties.VariableNames(:,1)={'tweet_nr'};
%     if tn==0; dxtemp=tmeans; else dxtemp=[dxtemp;tmeans]; end
%     %end
%     toc
% end
% dxtemp=sortrows(dxtemp,{'tree_nr','tweet_nr'});
% dx=outerjoin(d,dxtemp,'Keys',{'tree_nr','tweet_nr'},'MergeKeys', 1);
% dx(isnan(dx.tree_id),:)=[];
% d=dx;
% clear dx dxtemp
% 
% %% mean of direct replies - smarter way
% for v=1:length(vars); vars_re{v}=['re_',vars{v}]; end
% % first grpstats all replies to a tweet
% [treplied,tmeanreplies]=grpstats(d{:,cvs},d.in_reply_to,{'gname','mean'}); 
% treplies = array2table(tmeanreplies);  
% treplies{:,1}=str2double(treplied);
% treplies.Properties.VariableNames(:,1:end)=vars_re;
% treplies.Properties.VariableNames(:,1)={'tweet_id'};
% 
% treplies=sortrows(treplies,1);
% d=sortrows(d,{'tweet_id'});
% dx=outerjoin(d,treplies,'Keys',{'tweet_id'},'MergeKeys', 1);
% dx(isnan(dx.tree_id),:)=[]; % 2174 tweets replied to but not in the database
% d=dx;
% clear dx
% 
% %% some recodes
% d.date=datetime(d.created_at,'InputFormat','eee MMM d HH:mm:ss Z yyyy','TimeZone','local');
% d.weeks=week(d.date);
% d.years=year(d.date);
% d.wy=[datenum(d.years) + datenum(d.weeks)/100];
% 
% 
% %% split d
% % joint id
% d.id=[1:height(d)]';
% 
% d_basic=[array2table(d.id) d(:,[1:79 252:256])];
% d_id=[array2table(d.id) d(:,strcmp(d.Properties.VariableNames, 'tweet_nr')) d(:,strcmp(d.Properties.VariableNames, 'user_twitter_id')) ...
%     d(:,strcmp(d.Properties.VariableNames, 'tree_nr')) d(:,strcmp(d.Properties.VariableNames, 'date')) ...
%     d(:,strcmp(d.Properties.VariableNames, 'weeks')) d(:,strcmp(d.Properties.VariableNames, 'years')) ...
%     d(:,strcmp(d.Properties.VariableNames, 'wy'))];
% d_next=[array2table(d.id) d(:,contains(d.Properties.VariableNames, 'next_'))];
% d_all=[array2table(d.id) d(:,contains(d.Properties.VariableNames, 'all'))];
% d_re=[array2table(d.id) d(:,contains(d.Properties.VariableNames, 're_'))];
% 
% d_basic.id=[];
% d_basic.Properties.VariableNames(:,1)={'id'};
% d_id.Properties.VariableNames(:,1)={'id'};
% d_next.Properties.VariableNames(:,1)={'id'};
% d_all.Properties.VariableNames(:,1)={'id'};
% d_re.Properties.VariableNames(:,1)={'id'};
% 
% tic
% savefast d_all d_all
% toc
% tic
% savefast d_id d_id
% toc
% tic
% savefast d_next d_next
% toc
% tic
% savefast d_re d_re
% toc
% tic
% savefast d_basic d_basic
% toc
% 
% tic
% savefast d d
% toc
% clear d
% 
% % load d_basic % will have to make again for before 2015
% % load d_id % will have to make again for before 2015
% 
% 
% 
% % %% attach size of tree
% % trimax=grpstats([d_basic.tree_nr d_basic.tweet_nr],d_basic.tree_nr,{'max'});
% % trimax(:,2)=trimax(:,2)+1;
% % trimax=array2table(trimax);
% % trimax.Properties.VariableNames(:,1)={'tree_nr'}; trimax.Properties.VariableNames(:,2)={'tree_max'};
% % d_basic=sortrows(d_basic,{'tree_nr','tweet_nr'}); % sort by tree and tweet number - check
% % dx=outerjoin(d_basic,trimax,'Keys',{'tree_nr'},'MergeKeys', 1);
% % d_basic=dx; clear dx
% % d_basic=sortrows(d_basic,1); % sort rows back, important
% 
% %% attach day
% d_basic.day=day(d_basic.date);
% d_basic.month=month(d_basic.date);
% d_basic=sortrows(d_basic,{'date'});
% d_basic.date2=datetime(d_basic.years, d_basic.month, d_basic.day);
% d_basic.dayn=grp2idx(d_basic.date2);
% 
% % %% recode tweet_nr, tree_max
% % d_basic.tweet_root(d_basic.tweet_nr==0)=1;d_basic.tweet_root(d_basic.tweet_nr>0)=0;
% % tabulate(d_basic.tweet_root);
% % 
% % d_basic.tree_max2=d_basic.tree_max;
% % d_basic.tree_max2(d_basic.tree_max>=100)=100;
% % tabulate(d_basic.tree_max2);
% 
% %% clean a bit more
% d_basic.created_at=[];
% 
% d_basic.in_reply_to2=d_basic.in_reply_to;
% d_basic.in_reply_to2(strcmp(d_basic.in_reply_to,'None'))={'nan'};
% d_basic.in_reply_to2=str2double(d_basic.in_reply_to2);
% d_basic.in_reply_to=[];
% 
% %% attach day
% d_id.day=day(d_id.date);
% d_id.month=month(d_id.date);
% d_id=sortrows(d_id,1);
% d_id.date2=datetime(d_id.years, d_id.month, d_id.day);
% d_id.dayn=grp2idx(d_id.date2);
% 
% %% correct bug in tree_max
% % attach size of tree
% trimax=grpstats(d_basic.tree_nr,d_basic.tree_nr,{'numel'});
% trimax=array2table(trimax);
% trimax=[array2table(unique(d_basic.tree_nr)) trimax];
% trimax.Properties.VariableNames(:,1)={'tree_nr'}; trimax.Properties.VariableNames(:,2)={'tree_max3'};
% d_basic=sortrows(d_basic,{'tree_nr'}); % sort by tree_nr
% dx=outerjoin(d_basic,trimax,'Keys',{'tree_nr'},'MergeKeys', 1);
% d_basic=dx; clear dx
% d_basic=sortrows(d_basic,{'tree_nr','tweet_nr'}); % sort rows back, important
% 
% %% correct for missings in tree_nr - consecutive numbering - VALID FOR THE WHOLE PERIOD ONLY AND WITHOUT MISSINGS
% d_basic=sortrows(d_basic,{'tree_nr','tweet_nr'});
% treens=unique(d_basic.tree_nr);
% d_basic.tweet_nr2=nan(height(d_basic),1);
% for i=1:length(treens)
%     d_basic.tweet_nr2(d_basic.tree_nr==treens(i),:)=1:sum(d_basic.tree_nr==treens(i));
% end
% 
% %% log max - CORRECT VARIABLES FOR ANALYSES (for sorting any fine): TWEET_NR2 AND TREE_MAX3
% d_basic.tweet_nr2_log=log10(d_basic.tweet_nr2+1);
% d_basic.tree_max3_log=log10(d_basic.tree_max3);
% 
% %% mean tox
% d_basic.tox=nanmean([d_basic.PROFANITY d_basic.TOXICITY d_basic.INSULT d_basic.SEVERE_TOXICITY d_basic.IDENTITY_ATTACK],2);
% d_basic.next_tox=nanmean([d_next.next_PROFANITY d_next.next_TOXICITY d_next.next_INSULT d_next.next_SEVERE_TOXICITY d_next.next_IDENTITY_ATTACK],2);
% d_basic.re_tox=nanmean([d_re.re_PROFANITY d_re.re_TOXICITY d_re.re_INSULT d_re.re_SEVERE_TOXICITY d_re.re_IDENTITY_ATTACK],2);
% d_basic.all_tox=nanmean([d_all.all_PROFANITY d_all.all_TOXICITY d_all.all_INSULT d_all.all_SEVERE_TOXICITY d_all.all_IDENTITY_ATTACK],2);
% d_basic.tbef_tox=nanmean([d_tbef.tbef_PROFANITY d_tbef.tbef_TOXICITY d_tbef.tbef_INSULT d_tbef.tbef_SEVERE_TOXICITY d_tbef.tbef_IDENTITY_ATTACK],2);
% d_basic.dbef_tox=nanmean([d_dbef.dbef_PROFANITY d_dbef.dbef_TOXICITY d_dbef.dbef_INSULT d_dbef.dbef_SEVERE_TOXICITY d_dbef.dbef_IDENTITY_ATTACK],2);
% 
% %% mean of the tree before L
% d_basic=sortrows(d_basic,{'tree_nr','tweet_nr'}); % sort by tree and tweet number - check
% cvs={'id';'tree_nr';'tweet_nr';'user_twitter_id';'hate_score';'counter_score';'valence';'arousal';'dominance';...
%     'goodness';'energy';'power';'danger';'structure';'valence_similarity';'arousal_similarity';'dominance_similarity';...
%     'goodness_similarity';'energy_similarity';'power_similarity';'danger_similarity';'structure_similarity';'PROFANITY';'TOXICITY';...
%     'INSULT';'SEVERE_TOXICITY';'IDENTITY_ATTACK';'THREAT';...
%     'anger';'fear';'disgust';'sadness';'joy';'enthusiasm';'pride';'hope';...
%     'strategy_construct';'strategy_opin';'strategy_sarc';'strategy_leave_fact';...
%     'strategy_other_new';'topic_not_out';'topic_out';'topic2_in_both';...
%     'topic2_out';'topic2_neutral_unint';'goal_other';'goal_weak';...
%     'goal_neutral';'goal2_in_both_positive';'goal2_out_negative';...
%     'goal2_neutral_unint';'speech_hate_yes';'speech_hate_no';...
%     'speech_group_inst';'speech_group_right_wing';'speech_group_left_wing';...
%     'speech_group_vulnerable';'speech_group_other_new'};
% vars=cvs;
% for v=1:length(vars); vars_tbef{v}=['tbef_',vars{v}]; end
% 
% for tn=1:max(d_basic.tweet_nr)
%     tn
%     tic
%     dtemp=d_basic(d_basic.tweet_nr2<tn & d_basic.tree_max3>=tn,:);
%     tmean=grpstats(dtemp{:,cvs},dtemp.tree_nr);   
%     tmean(:,3)=tn;
%     if tn==1; dxtemp=tmean; else dxtemp=[dxtemp;tmean]; end
%     toc
% end
% dxtemp = array2table(dxtemp); 
% dxtemp.Properties.VariableNames=vars_tbef;
% dxtemp.Properties.VariableNames(:,2)={'tree_nr'};
% dxtemp.Properties.VariableNames(:,3)={'tweet_nr'};
% dxtemp=sortrows(dxtemp,{'tree_nr','tweet_nr'});
% dx=outerjoin(d_id,dxtemp,'Keys',{'tree_nr','tweet_nr'},'MergeKeys', 1);
% dx(isnan(dx.id),:)=[];
% d_tbef=dx;
% d_basic=sortrows(d_basic,1); % sort rows back, important
% d_tbef=sortrows(d_tbef,1); % sort rows back, important
% save d_tbef d_tbef
% save d_basic d_basic
% clear dx
% 
% %% mean of the day before 
% cvs={'id';'tree_nr';'tweet_nr';'user_twitter_id';'hate_score';'counter_score';'valence';'arousal';'dominance';...
%     'goodness';'energy';'power';'danger';'structure';'valence_similarity';'arousal_similarity';'dominance_similarity';...
%     'goodness_similarity';'energy_similarity';'power_similarity';'danger_similarity';'structure_similarity';'PROFANITY';'TOXICITY';...
%     'INSULT';'SEVERE_TOXICITY';'IDENTITY_ATTACK';'THREAT';...
%     'anger';'fear';'disgust';'sadness';'joy';'enthusiasm';'pride';'hope';...
%     'strategy_construct';'strategy_opin';'strategy_sarc';'strategy_leave_fact';...
%     'strategy_other_new';'topic_not_out';'topic_out';'topic2_in_both';...
%     'topic2_out';'topic2_neutral_unint';'goal_other';'goal_weak';...
%     'goal_neutral';'goal2_in_both_positive';'goal2_out_negative';...
%     'goal2_neutral_unint';'speech_hate_yes';'speech_hate_no';...
%     'speech_group_inst';'speech_group_right_wing';'speech_group_left_wing';...
%     'speech_group_vulnerable';'speech_group_other_new'};
% vars=cvs;
% for v=1:length(vars); vars_dbef{v}=['dbef_',vars{v}]; end
% tmean=grpstats(d_basic{:,cvs},d_basic.dayn);  
% tmeans = array2table(tmean);     
% tmeans.Properties.VariableNames=vars_dbef;
% tmeans.Properties.VariableNames(:,1)={'dayn'};
% 
% dx=outerjoin(d_id,tmeans,'Keys',{'dayn'},'MergeKeys', 1);
% d_dbef=dx;
% d_dbef(isnan(d_dbef.id),:)=[];
% save d_dbef d_dbef
% clear dx
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%
tic
load d_basic2 % CURRENTLY SCREWED UP: d_basic is now only 15-18, with tox nans; d_basic2 is d_basic without tox nans; will have to rerun above to get the whole d_basic again
load d_id % will have to make again for before 2015
load d_next
load d_re
load d_all
load d_tbef
load d_dbef
toc

%%
%%% are they all sorted in the same way?!!!
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

%% remove missing tox
d_basic(isnan(d_basic.tox),:)=[];

d_id(isnan(d_basic2.tox),:)=[];
d_next(isnan(d_basic2.tox),:)=[];
d_re(isnan(d_basic2.tox),:)=[];
d_all(isnan(d_basic2.tox),:)=[];
d_tbef(isnan(d_basic2.tox),:)=[];
d_dbef(isnan(d_basic2.tox),:)=[];


%% recode goal and topic - not needed
% not yet but we will maybe have three groups of goal: weak+threat, strength+just+emph, neutral + unint
% and for topic: out, in+both, neutral+unint (where I guess this last one is the same as for goal)
corr([d_basic.topic_out d_basic.goal_weak d_basic.goal_other d_basic.goal_neutral])

%% recode speech_group by hate_speech - not needed - BUT IT IS, FOR TREES
corr([d_basic.speech_hate_yes d_basic.speech_group_inst d_basic.speech_group_right_wing ...
    d_basic.speech_group_left_wing d_basic.speech_group_vulnerable d_basic.speech_group_other_new])

d_basic.speech_group_inst2=d_basic.speech_group_inst; d_basic.speech_group_inst2(isnan(d_basic.speech_group_inst))=0;
d_basic.speech_group_right_wing2=d_basic.speech_group_right_wing; d_basic.speech_group_right_wing2(isnan(d_basic.speech_group_right_wing))=0;
d_basic.speech_group_left_wing2=d_basic.speech_group_left_wing; d_basic.speech_group_left_wing2(isnan(d_basic.speech_group_left_wing))=0;
d_basic.speech_group_vulnerable2=d_basic.speech_group_vulnerable; d_basic.speech_group_vulnerable2(isnan(d_basic.speech_group_vulnerable))=0;
d_basic.speech_group_other_new2=d_basic.speech_group_other_new; d_basic.speech_group_other_new2(isnan(d_basic.speech_group_other_new))=0;

%--> actually, after checking lmes below, it's most interpretable if we put
%in both hate_speech and speech_group

% try interactions - no new insights compared to just main effects (hate
% bad, but if about inst or left wing, decreased toxicity, else if for
% reight wing and vulnerable, more toxicity); seems that left defends
% vulnerable and right defends its own, and nobody defends institutions or left
d_basic.speech_group_inst_inthate=d_basic.speech_group_inst.*d_basic.speech_hate_yes<.5;
d_basic.speech_group_right_wing_inthate=d_basic.speech_group_right_wing.*d_basic.speech_hate_yes;
d_basic.speech_group_left_wing_inthate=d_basic.speech_group_left_wing.*d_basic.speech_hate_yes;
d_basic.speech_group_vulnerable_inthate=d_basic.speech_group_vulnerable.*d_basic.speech_hate_yes;
d_basic.speech_group_other_new_inthate=d_basic.speech_group_other_new.*d_basic.speech_hate_yes;


%% select 2015-2018 - this brings everything to 1163302 cases
d_basic=d_basic(d_basic.years>=2015 & d_basic.years<=2018,:);
d_id=d_id(d_id.years>=2015 & d_id.years<=2018,:);
d_next=d_next(d_id.years>=2015 & d_id.years<=2018,:);
d_re=d_re(d_id.years>=2015 & d_id.years<=2018,:);
d_all=d_all(d_id.years>=2015 & d_id.years<=2018,:);
d_tbef=d_tbef(d_id.years>=2015 & d_id.years<=2018,:);
d_dbef=d_dbef(d_id.years>=2015 & d_id.years<=2018,:);


%% CALCULATE AVERAGE AUTHOR HATE SCORE
d_basic2=d_basic;

[aid amean]=grpstats(d_basic.hate_score,d_basic.user_twitter_id,{'gname','mean'});
for i=1:length(aid); aidn(i,:)=str2num(cell2mat(aid(i,:))); end

dx=array2table([aidn amean]);
dx.Properties.VariableNames={'user_twitter_id','user_hate_score'};

d_basic=sortrows(d_basic,30);
dx=sortrows(dx,1);
d_basic2
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


%% prepare d_basic without missing tox, redo trees
d_basic=d_basic2;
d_basic(isnan(d_basic.tox),:)=[];
% correct for missings in tree_nr - HAVE TO REPEAT AS CONSECUTIVE LOST BECAUSE PERIOD AND TOX CUTS
d_basic=sortrows(d_basic,{'tree_nr','tweet_nr'});
treens=unique(d_basic.tree_nr);
d_basic.tweet_nr3=nan(height(d_basic),1);
d_basic.tree_max4=nan(height(d_basic),1);
for i=1:length(treens)
    i
    d_basic.tweet_nr3(d_basic.tree_nr==treens(i),:)=1:sum(d_basic.tree_nr==treens(i));
    d_basic.tree_max4(d_basic.tree_nr==treens(i),:)=sum(d_basic.tree_nr==treens(i));
end

save d_basic2 d_basic %%% THIS IS THE PROPER DATA FILE FOR ALL ANALYSES, INCLUDING DAY BY DAY
length(unique(d_basic.user_twitter_id))
length(unique(d_basic.tree_id))



%% calculate everything by day
load d_basic2

d_basic.extreme_score=abs(.5-d_basic.hate_score);

corr([d_basic.joy d_basic.enthusiasm d_basic.pride d_basic.joy])

d_basic.enthop=mean([d_basic.enthusiasm d_basic.hope],2);
d_basic.prijoy=mean([d_basic.pride d_basic.joy],2);

% d_basic.power(d_basic.power==0)=nan;
% d_basic.danger(d_basic.danger==0)=nan;
% d_basic.structure(d_basic.structure==0)=nan;
% d_basic.valence(d_basic.valence==0)=nan;
% d_basic.arousal(d_basic.arousal==0)=nan;
% d_basic.dominance(d_basic.dominance==0)=nan;


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
    d_basic_byday(:,v)=grpstats(d_basic{:,vars{v}},d_basic.dayn,{'std'});
end
for v=1:length(vars)
    vars_dbd{v}=['dbd_',vars{v}];
end
d_basic_byday = array2table(d_basic_byday);     
d_basic_byday.Properties.VariableNames=vars_dbd;
%d_basic_byday(1,:)=[];

writetable(d_basic_byday,"d_basic_byday_std.xlsx") % for stata
save d_basic_byday_std d_basic_byday

% % bootstrap too long  
% tic
% bootci(10,@(x)mean(x),d_basic{:,vars{v}})
% toc


%% %%%% get long threads %%%%%
%load d_basic2
longtrees=unique(d_basic.tree_nr(d_basic.tree_max4>=50));
path="D:\Dropbox\SFI Reconquista\00 strategies\analyses\trees50\";
for i=934:length(longtrees)    
    writetable(d_basic(d_basic.tree_nr==longtrees(i),:),[path + 'd_basic_50_' + num2str(i) + '.xlsx']); % for stata
end


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

%% cors by tweet (for by day see analysis6.do)
corr([d.speech_hate_yes  d.tox d.hate_score d.user_group_70e ...
d.strategy_opin d.strategy_construct d.strategy_sarc d.strategy_leave_fact d.strategy_other_new ...
d.topic_out d.topic_not_out ...
d.goal2_in_both_positive d.goal2_out_negative d.goal2_neutral_unint ...
d.anger d.fear d.disgust d.sadness d.enthusiasm d.hope d.pride d.joy])

%% setup for the first few figs
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
% dd.dbd_neutral_score=.5-abs(.5-dd.dbd_hate_score); % DON'T DO THIS
% dd.dbd_extreme_score=abs(.5-dd.dbd_hate_score); % DON'T DO THIS
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
% plot(dd.dbd_dayn,movmean(dd.dbd_speech_hate_yes,mm),'color',rgb('Red'),'linewidth',2)
% hold on
% plot(dd.dbd_dayn,movmean(dd.dbd_tox,mm),'color',rgb('Dark red'),'linewidth',2)
% hold on
% plot(dd.dbd_dayn,movmean(dd.dbd_extreme_score,mm),'color',rgb('Orange'),'linewidth',2)
% hold on
% plot(dd.dbd_dayn,movmean(dd.dbd_user_group_70e,mm),'color',rgb('Ocher'),'linewidth',2)

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

% x=(movmean(dd.dbd_speech_hate_yes,mm)-min(movmean(dd.dbd_speech_hate_yes,mm)))./(max(movmean(dd.dbd_speech_hate_yes,mm))-min(movmean(dd.dbd_speech_hate_yes,mm)));
% y=(movmean(dd_sem.dbd_speech_hate_yes,mm)-min(movmean(dd_sem.dbd_speech_hate_yes,mm)))./(max(movmean(dd_sem.dbd_speech_hate_yes,mm))-min(movmean(dd_sem.dbd_speech_hate_yes,mm)));
% h=shadedErrorBar(dd.dbd_dayn,x,y);
% h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
% h.mainLine.Color=rgb('Red'); h.patch.FaceColor=rgb('Red');
% h.mainLine.LineWidth=1.5;
% 
% hold on
% x=(movmean(dd.dbd_tox,mm)-min(movmean(dd.dbd_tox,mm)))./(max(movmean(dd.dbd_tox,mm))-min(movmean(dd.dbd_tox,mm)));
% y=(movmean(dd_sem.dbd_tox,mm)-min(movmean(dd_sem.dbd_tox,mm)))./(max(movmean(dd_sem.dbd_tox,mm))-min(movmean(dd_sem.dbd_tox,mm)));
% h=shadedErrorBar(dd.dbd_dayn,x,y);
% h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
% h.mainLine.Color=rgb('Dark red'); h.patch.FaceColor=rgb('Dark red');
% h.mainLine.LineWidth=1.5;
% 
% hold on
% x=(movmean(dd.dbd_extreme_score,mm)-min(movmean(dd.dbd_extreme_score,mm)))./(max(movmean(dd.dbd_extreme_score,mm))-min(movmean(dd.dbd_extreme_score,mm)));
% y=(movmean(dd_sem.dbd_extreme_score,mm)-min(movmean(dd_sem.dbd_extreme_score,mm)))./(max(movmean(dd_sem.dbd_extreme_score,mm))-min(movmean(dd_sem.dbd_extreme_score,mm)));
% h=shadedErrorBar(dd.dbd_dayn,x,y);
% h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
% h.mainLine.Color=rgb('Orange'); h.patch.FaceColor=rgb('Orange');
% h.mainLine.LineWidth=1.5;
% 
% hold on
% x=(movmean(dd.dbd_user_group_70e,mm)-min(movmean(dd.dbd_user_group_70e,mm)))./(max(movmean(dd.dbd_user_group_70e,mm))-min(movmean(dd.dbd_user_group_70e,mm)));
% y=(movmean(dd_sem.dbd_user_group_70e,mm)-min(movmean(dd_sem.dbd_user_group_70e,mm)))./(max(movmean(dd_sem.dbd_user_group_70e,mm))-min(movmean(dd_sem.dbd_user_group_70e,mm)));
% h=shadedErrorBar(dd.dbd_dayn,x,y);
% h.edge(1).Visible='Off'; h.edge(2).Visible='Off';
% h.mainLine.Color=rgb('Ocher'); h.patch.FaceColor=rgb('Ocher');
% h.mainLine.LineWidth=1.5;

xlabel('Time (months)','fontsize',14); 
ylabel({'Normalized avg.','probability'},'fontsize',14)
% l=legend('Toxicity','Political extremity of speech','Hate speech','Political extremity of speakers','location','northwest');
% l.FontSize=12;

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

% %all looks fine but pol extr of speech look lower then when calc from raw data - CHECK
% when extremity of speech first calculated on raw data (d or d_basic), then averaged by days - higher than
% if extremity calculated from means of hate score per day. MUST CALCULATE EXTREMITY IN RAW DATA FIRST, THEN AVERAGE.

%## NEXT : ERROR BANDS

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
% plot(dd.dbd_dayn,movmean(dd.dbd_user_group_70rg,mm),'color',rgb('Light plum'),'linewidth',1)
% hold on
% plot(dd.dbd_dayn,movmean(dd.dbd_user_group_70ri,mm),'--','color',rgb('Teal'),'linewidth',1)
% hold on

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
% plot(dd.dbd_dayn,movmean(dd.dbd_speech_group_inst,mm),'color',rgb('bluegreen'),'linewidth',2)
% hold on
% plot(dd.dbd_dayn,movmean(dd.dbd_speech_group_right_wing,mm),'color',rgb('Blue'),'linewidth',2)
% hold on
% plot(dd.dbd_dayn,movmean(dd.dbd_speech_group_left_wing,mm),'color',rgb('Red'),'linewidth',2)
% hold on
% plot(dd.dbd_dayn,movmean(dd.dbd_speech_group_vulnerable,mm),'color',rgb('Gold'),'linewidth',2)
% hold on
% plot(dd.dbd_dayn,movmean(dd.dbd_speech_group_other_new,mm),'color',rgb('Grey'),'linewidth',2)

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
% plot(movmean(grpstats(d.strategy_opin,d.dayn),mm),'color',rgb('sky blue'),'linewidth',1); hold on
% plot(movmean(grpstats(d.strategy_construct,d.dayn),mm),'color',rgb('blue'),'linewidth',1); hold on
% plot(movmean(grpstats(d.strategy_sarc,d.dayn),mm),'color',rgb('orange'),'linewidth',1); hold on
% plot(movmean(grpstats(d.strategy_leave_fact,d.dayn),mm),'color',rgb('red'),'linewidth',1); hold on
% plot(movmean(grpstats(d.strategy_other_new,d.dayn),mm),'color',rgb('grey'),'linewidth',1); hold on
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
% plot(movmean(grpstats(d.strategy_opin(filt),d.dayn(filt)),mm),'color',rgb('sky blue'),'linewidth',1); hold on
% plot(movmean(grpstats(d.strategy_construct(filt),d.dayn(filt)),mm),'color',rgb('blue'),'linewidth',1); hold on
% plot(movmean(grpstats(d.strategy_sarc(filt),d.dayn(filt)),mm),'color',rgb('orange'),'linewidth',1); hold on
% plot(movmean(grpstats(d.strategy_leave_fact(filt),d.dayn(filt)),mm),'color',rgb('red'),'linewidth',1); hold on
% plot(movmean(grpstats(d.strategy_other_new(filt),d.dayn(filt)),mm),'color',rgb('grey'),'linewidth',1); hold on
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
% plot(movmean(grpstats(d.strategy_opin(filt),d.dayn(filt)),mm),'color',rgb('sky blue'),'linewidth',1); hold on
% plot(movmean(grpstats(d.strategy_construct(filt),d.dayn(filt)),mm),'color',rgb('blue'),'linewidth',1); hold on
% plot(movmean(grpstats(d.strategy_sarc(filt),d.dayn(filt)),mm),'color',rgb('orange'),'linewidth',1); hold on
% plot(movmean(grpstats(d.strategy_leave_fact(filt),d.dayn(filt)),mm),'color',rgb('red'),'linewidth',1); hold on
% plot(movmean(grpstats(d.strategy_other_new(filt),d.dayn(filt)),mm),'color',rgb('grey'),'linewidth',1); hold on
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
% plot(movmean(grpstats(d.topic2_in_both,d.dayn),mm),'color',rgb('bluegreen'),'linewidth',1); hold on
% plot(movmean(grpstats(d.topic2_out,d.dayn),mm),'color',rgb('deep orange'),'linewidth',1); hold on
% plot(movmean(grpstats(d.topic2_neutral_unint,d.dayn),mm),'color',rgb('grey'),'linewidth',1); hold on
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
% plot(movmean(grpstats(d.topic2_in_both(filt),d.dayn(filt)),mm),'color',rgb('bluegreen'),'linewidth',1); hold on
% plot(movmean(grpstats(d.topic2_out(filt),d.dayn(filt)),mm),'color',rgb('deep orange'),'linewidth',1); hold on
% plot(movmean(grpstats(d.topic2_neutral_unint(filt),d.dayn(filt)),mm),'color',rgb('grey'),'linewidth',1); hold on
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
% plot(movmean(grpstats(d.topic2_in_both(filt),d.dayn(filt)),mm),'color',rgb('bluegreen'),'linewidth',1); hold on
% plot(movmean(grpstats(d.topic2_out(filt),d.dayn(filt)),mm),'color',rgb('deep orange'),'linewidth',1); hold on
% plot(movmean(grpstats(d.topic2_neutral_unint(filt),d.dayn(filt)),mm),'color',rgb('grey'),'linewidth',1); hold on
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
% plot(movmean(grpstats(d.goal2_in_both_positive,d.dayn),mm),'color',rgb('bluegreen'),'linewidth',1); hold on
% plot(movmean(grpstats(d.goal2_out_negative,d.dayn),mm),'color',rgb('deep orange'),'linewidth',1); hold on
% plot(movmean(grpstats(d.goal2_neutral_unint,d.dayn),mm),'color',rgb('grey'),'linewidth',1); hold on
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

l=legend([h1.mainLine h2.mainLine h3.mainLine],'Positive about own or both groups','Negative about outgroup','Other','location','northwest');
l.FontSize=12;

subplot(1,3,2)
filt=d.hate_score<.3;
% plot(movmean(grpstats(d.goal2_in_both_positive(filt),d.dayn(filt)),mm),'color',rgb('bluegreen'),'linewidth',1); hold on
% plot(movmean(grpstats(d.goal2_out_negative(filt),d.dayn(filt)),mm),'color',rgb('deep orange'),'linewidth',1); hold on
% plot(movmean(grpstats(d.goal2_neutral_unint(filt),d.dayn(filt)),mm),'color',rgb('grey'),'linewidth',1); hold on
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
% plot(movmean(grpstats(d.goal2_in_both_positive(filt),d.dayn(filt)),mm),'color',rgb('bluegreen'),'linewidth',1); hold on
% plot(movmean(grpstats(d.goal2_out_negative(filt),d.dayn(filt)),mm),'color',rgb('deep orange'),'linewidth',1); hold on
% plot(movmean(grpstats(d.goal2_neutral_unint(filt),d.dayn(filt)),mm),'color',rgb('grey'),'linewidth',1); hold on
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
% plot(movmean(grpstats(d.anger,d.dayn),mm),'color',rgb('red'),'linewidth',1); hold on
% plot(movmean(grpstats(d.fear,d.dayn),mm),'color',rgb('bluegreen'),'linewidth',1); hold on
% plot(movmean(grpstats(d.disgust,d.dayn),mm),'color',rgb('brown'),'linewidth',1); hold on
% plot(movmean(grpstats(d.sadness,d.dayn),mm),'color',rgb('blue'),'linewidth',1); hold on
% plot(movmean(grpstats(d.enthop,d.dayn),mm),'color',rgb('gold'),'linewidth',1); hold on
% plot(movmean(grpstats(d.prijoy,d.dayn),mm),'color',rgb('pink'),'linewidth',1); hold on
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
% plot(movmean(grpstats(d.anger(filt),d.dayn(filt)),mm),'color',rgb('red'),'linewidth',1); hold on
% plot(movmean(grpstats(d.fear(filt),d.dayn(filt)),mm),'color',rgb('bluegreen'),'linewidth',1); hold on
% plot(movmean(grpstats(d.disgust(filt),d.dayn(filt)),mm),'color',rgb('brown'),'linewidth',1); hold on
% plot(movmean(grpstats(d.sadness(filt),d.dayn(filt)),mm),'color',rgb('blue'),'linewidth',1); hold on
% plot(movmean(grpstats(d.enthop(filt),d.dayn(filt)),mm),'color',rgb('gold'),'linewidth',1); hold on
% plot(movmean(grpstats(d.prijoy(filt),d.dayn(filt)),mm),'color',rgb('pink'),'linewidth',1); hold on
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
% plot(movmean(grpstats(d.anger(filt),d.dayn(filt)),mm),'color',rgb('red'),'linewidth',1); hold on
% plot(movmean(grpstats(d.fear(filt),d.dayn(filt)),mm),'color',rgb('bluegreen'),'linewidth',1); hold on
% plot(movmean(grpstats(d.disgust(filt),d.dayn(filt)),mm),'color',rgb('brown'),'linewidth',1); hold on
% plot(movmean(grpstats(d.sadness(filt),d.dayn(filt)),mm),'color',rgb('blue'),'linewidth',1); hold on
% plot(movmean(grpstats(d.enthop(filt),d.dayn(filt)),mm),'color',rgb('gold'),'linewidth',1); hold on
% plot(movmean(grpstats(d.prijoy(filt),d.dayn(filt)),mm),'color',rgb('pink'),'linewidth',1); hold on
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

%% meaning - similarity
%close all
figure
subplot(1,3,1)
plot(movmean(grpstats(d.power_similarity,d.dayn),mm),'color',rgb('forest green'),'linewidth',1); hold on
plot(movmean(grpstats(d.danger_similarity,d.dayn),mm),'color',rgb('dark red'),'linewidth',1); hold on
plot(movmean(grpstats(d.valence_similarity,d.dayn),mm),'color',rgb('blue'),'linewidth',1); hold on
plot(movmean(grpstats(d.arousal_similarity,d.dayn),mm),'color',rgb('red'),'linewidth',1); hold on
plot(movmean(grpstats(d.dominance_similarity,d.dayn),mm),'color',rgb('midnight'),'linewidth',1); hold on
title('All tweets','fontsize',14)
xlabel('Time (months)','fontsize',14); 
ylabel({'Probability of different','dimensions of meaning','(similarity)'},'fontsize',14)
set(gca,'xtick',(1:st:length(wyu)))
set(gca,'xticklabels',wyu(1:st:length(wyu),:),'fontsize',12)
xtickangle(45)
set(gca,'ytick',.1:.1:.5)
ylim([.1 .5])
grid
l=legend('Power','Danger','Valence','Arousal','Dominance','location','northwest'); l.FontSize=12;

subplot(1,3,2)
filt=d.hate_score<.3;
plot(movmean(grpstats(d.power_similarity(filt),d.dayn(filt)),mm),'color',rgb('forest green'),'linewidth',1); hold on
plot(movmean(grpstats(d.danger_similarity(filt),d.dayn(filt)),mm),'color',rgb('dark red'),'linewidth',1); hold on
plot(movmean(grpstats(d.valence_similarity(filt),d.dayn(filt)),mm),'color',rgb('blue'),'linewidth',1); hold on
plot(movmean(grpstats(d.arousal_similarity(filt),d.dayn(filt)),mm),'color',rgb('red'),'linewidth',1); hold on
plot(movmean(grpstats(d.dominance_similarity(filt),d.dayn(filt)),mm),'color',rgb('midnight'),'linewidth',1); hold on
title('RI-like tweets','fontsize',14)
xlabel('Time (months)','fontsize',14); 
ylabel({'Probability of different','dimensions of meaning','(similarity)'},'fontsize',14)
set(gca,'xtick',(1:st:length(wyu)))
set(gca,'xticklabels',wyu(1:st:length(wyu),:),'fontsize',12)
xtickangle(45)
set(gca,'ytick',.1:.1:.5)
ylim([.1 .5])
grid

subplot(1,3,3)
filt=d.hate_score>.7;
plot(movmean(grpstats(d.power_similarity(filt),d.dayn(filt)),mm),'color',rgb('forest green'),'linewidth',1); hold on
plot(movmean(grpstats(d.danger_similarity(filt),d.dayn(filt)),mm),'color',rgb('dark red'),'linewidth',1); hold on
plot(movmean(grpstats(d.valence_similarity(filt),d.dayn(filt)),mm),'color',rgb('blue'),'linewidth',1); hold on
plot(movmean(grpstats(d.arousal_similarity(filt),d.dayn(filt)),mm),'color',rgb('red'),'linewidth',1); hold on
plot(movmean(grpstats(d.dominance_similarity(filt),d.dayn(filt)),mm),'color',rgb('midnight'),'linewidth',1); hold on
title('RG-like tweets','fontsize',14)
xlabel('Time (months)','fontsize',14); 
ylabel({'Probability of different','dimensions of meaning','(similarity)'},'fontsize',14)
set(gca,'xtick',(1:st:length(wyu)))
set(gca,'xticklabels',wyu(1:st:length(wyu),:),'fontsize',12)
xtickangle(45)
set(gca,'ytick',.1:.1:.5)
ylim([.1 .5])
grid
%% meaning - only original
%close all
figure
subplot(1,3,1)
plot(movmean(grpstats(d.power,d.dayn),mm),'color',rgb('forest green'),'linewidth',1); hold on
plot(movmean(grpstats(d.danger,d.dayn),mm),'color',rgb('dark red'),'linewidth',1); hold on
plot(movmean(grpstats(d.valence,d.dayn),mm),'color',rgb('blue'),'linewidth',1); hold on
plot(movmean(grpstats(d.arousal,d.dayn),mm),'color',rgb('red'),'linewidth',1); hold on
plot(movmean(grpstats(d.dominance,d.dayn),mm),'color',rgb('midnight'),'linewidth',1); hold on
title('All tweets','fontsize',14)
xlabel('Time (months)','fontsize',14); 
ylabel({'Probability of different','dimensions of meaning','(original)'},'fontsize',14)
set(gca,'xtick',(1:st:length(wyu)))
set(gca,'xticklabels',wyu(1:st:length(wyu),:),'fontsize',12)
xtickangle(45)
%set(gca,'ytick',.1:.1:.5)
%ylim([.1 .5])
grid
l=legend('Power','Danger','Valence','Arousal','Dominance','location','northwest'); l.FontSize=12;

subplot(1,3,2)
filt=d.hate_score<.3;
plot(movmean(grpstats(d.power(filt),d.dayn(filt)),mm),'color',rgb('forest green'),'linewidth',1); hold on
plot(movmean(grpstats(d.danger(filt),d.dayn(filt)),mm),'color',rgb('dark red'),'linewidth',1); hold on
plot(movmean(grpstats(d.valence(filt),d.dayn(filt)),mm),'color',rgb('blue'),'linewidth',1); hold on
plot(movmean(grpstats(d.arousal(filt),d.dayn(filt)),mm),'color',rgb('red'),'linewidth',1); hold on
plot(movmean(grpstats(d.dominance(filt),d.dayn(filt)),mm),'color',rgb('midnight'),'linewidth',1); hold on
title('RI-like tweets','fontsize',14)
xlabel('Time (months)','fontsize',14); 
ylabel({'Probability of different','dimensions of meaning','(original)'},'fontsize',14)
set(gca,'xtick',(1:st:length(wyu)))
set(gca,'xticklabels',wyu(1:st:length(wyu),:),'fontsize',12)
xtickangle(45)
%set(gca,'ytick',.1:.1:.5)
%ylim([.1 .5])
grid

subplot(1,3,3)
filt=d.hate_score>.7;
plot(movmean(grpstats(d.power(filt),d.dayn(filt)),mm),'color',rgb('forest green'),'linewidth',1); hold on
plot(movmean(grpstats(d.danger(filt),d.dayn(filt)),mm),'color',rgb('dark red'),'linewidth',1); hold on
plot(movmean(grpstats(d.valence(filt),d.dayn(filt)),mm),'color',rgb('blue'),'linewidth',1); hold on
plot(movmean(grpstats(d.arousal(filt),d.dayn(filt)),mm),'color',rgb('red'),'linewidth',1); hold on
plot(movmean(grpstats(d.dominance(filt),d.dayn(filt)),mm),'color',rgb('midnight'),'linewidth',1); hold on
title('RG-like tweets','fontsize',14)
xlabel('Time (months)','fontsize',14); 
ylabel({'Probability of different','dimensions of meaning','(original)'},'fontsize',14)
set(gca,'xtick',(1:st:length(wyu)))
set(gca,'xticklabels',wyu(1:st:length(wyu),:),'fontsize',12)
xtickangle(45)
%set(gca,'ytick',.1:.1:.5)
%ylim([.1 .5])
grid


%% plot relationship between strategy and next tweet/next day indicators of quality (rest of the tree or direct reply better)
%d.strategy_opin d.strategy_construct d.strategy_sarc d.strategy_leave_fact d.strategy_other_new

close all
figure

temp=round(d.strategy_opin,1);
d.strategy_opin_r=temp; 
d.strategy_opin_r(temp==max(temp))=round(max(temp)-.1,1); 

temp=round(d.strategy_construct,1);
d.strategy_construct_r=temp; 
d.strategy_construct_r(temp==max(temp))=round(max(temp)-.1,1); 

temp=round(d.strategy_sarc,1);
d.strategy_sarc_r=temp; 
d.strategy_sarc_r(temp==max(temp))=round(max(temp)-.1,1); 

temp=round(d.strategy_leave_fact,1);
d.strategy_leave_fact_r=temp; 
d.strategy_leave_fact_r(temp==max(temp))=round(max(temp)-.1,1); 


temp=round(dd.dbd_strategy_opin,1);
dd.dbd_strategy_opin_r=temp; 
%dd.dbd_strategy_opin_r(temp==max(temp))=round(max(temp)-.1,1); 

temp=round(dd.dbd_strategy_construct,1);
dd.dbd_strategy_construct_r=temp; 
%dd.dbd_strategy_construct_r(temp==max(temp))=round(max(temp)-.1,1); 

temp=round(dd.dbd_strategy_sarc,1);
dd.dbd_strategy_sarc_r=temp; 
%dd.dbd_strategy_sarc_r(temp==max(temp))=round(max(temp)-.1,1); 

temp=round(dd.dbd_strategy_leave_fact,1);
dd.dbd_strategy_leave_fact_r=temp; 
%dd.dbd_strategy_leave_fact_r(temp==max(temp))=round(max(temp)-.1,1); 


subplot(4,4,1)
errorbar(unique(d.strategy_opin_r),grpstats(d.next_tox,d.strategy_opin_r),grpstats(d.next_tox,d.strategy_opin_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.strategy_opin_r),grpstats(d_next.next_speech_hate_yes,d.strategy_opin_r),grpstats(d_next.next_speech_hate_yes,d.strategy_opin_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.strategy_opin_r),grpstats(d_next.next_extreme_score,d.strategy_opin_r),grpstats(d_next.next_extreme_score,d.strategy_opin_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: opinion','fontsize',14); 
ylabel('Next tweet','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid
l=legend('Toxicity','Hate speech','Extremity of speech');
l.FontSize=12;

subplot(4,4,5)
errorbar(unique(d.strategy_opin_r),grpstats(d.all_tox,d.strategy_opin_r),grpstats(d.all_tox,d.strategy_opin_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.strategy_opin_r),grpstats(d_all.all_speech_hate_yes,d.strategy_opin_r),grpstats(d_all.all_speech_hate_yes,d.strategy_opin_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.strategy_opin_r),grpstats(d_all.all_extreme_score,d.strategy_opin_r),grpstats(d_all.all_extreme_score,d.strategy_opin_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: opinion','fontsize',14); 
ylabel('Rest of the tree','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,9)
errorbar(unique(d.strategy_opin_r),grpstats(d.re_tox,d.strategy_opin_r),grpstats(d.re_tox,d.strategy_opin_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.strategy_opin_r),grpstats(d_re.re_speech_hate_yes,d.strategy_opin_r),grpstats(d_re.re_speech_hate_yes,d.strategy_opin_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.strategy_opin_r),grpstats(d_re.re_extreme_score,d.strategy_opin_r),grpstats(d_re.re_extreme_score,d.strategy_opin_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: opinion','fontsize',14); 
ylabel('Direct replies','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,13)
errorbar(unique(dd.dbd_strategy_opin_r),grpstats(dd.dbd_tox,dd.dbd_strategy_opin_r),grpstats(dd.dbd_tox,dd.dbd_strategy_opin_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(dd.dbd_strategy_opin_r),grpstats(dd.dbd_speech_hate_yes,dd.dbd_strategy_opin_r),grpstats(dd.dbd_speech_hate_yes,dd.dbd_strategy_opin_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(dd.dbd_strategy_opin_r),grpstats(dd.dbd_extreme_score,dd.dbd_strategy_opin_r),grpstats(dd.dbd_extreme_score,dd.dbd_strategy_opin_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: opinion','fontsize',14); 
ylabel('Next day','fontsize',14)
xlim([-.05 .55]); ylim([.1 .3])
grid



subplot(4,4,2)
errorbar(unique(d.strategy_construct_r),grpstats(d.next_tox,d.strategy_construct_r),grpstats(d.next_tox,d.strategy_construct_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.strategy_construct_r),grpstats(d_next.next_speech_hate_yes,d.strategy_construct_r),grpstats(d_next.next_speech_hate_yes,d.strategy_construct_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.strategy_construct_r),grpstats(d_next.next_extreme_score,d.strategy_construct_r),grpstats(d_next.next_extreme_score,d.strategy_construct_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: constructive','fontsize',14); 
%ylabel('Quality of discourse: the next tweet','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,6)
errorbar(unique(d.strategy_construct_r),grpstats(d.all_tox,d.strategy_construct_r),grpstats(d.all_tox,d.strategy_construct_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.strategy_construct_r),grpstats(d_all.all_speech_hate_yes,d.strategy_construct_r),grpstats(d_all.all_speech_hate_yes,d.strategy_construct_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.strategy_construct_r),grpstats(d_all.all_extreme_score,d.strategy_construct_r),grpstats(d_all.all_extreme_score,d.strategy_construct_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: constructive','fontsize',14); 
%ylabel('Quality of discourse: the rest of the tree','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,10)
errorbar(unique(d.strategy_construct_r),grpstats(d.re_tox,d.strategy_construct_r),grpstats(d.re_tox,d.strategy_construct_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.strategy_construct_r),grpstats(d_re.re_speech_hate_yes,d.strategy_construct_r),grpstats(d_re.re_speech_hate_yes,d.strategy_construct_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.strategy_construct_r),grpstats(d_re.re_extreme_score,d.strategy_construct_r),grpstats(d_re.re_extreme_score,d.strategy_construct_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: constructive','fontsize',14); 
%ylabel('Quality of discourse: direct replies','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,14)
errorbar(unique(dd.dbd_strategy_construct_r),grpstats(dd.dbd_tox,dd.dbd_strategy_construct_r),grpstats(dd.dbd_tox,dd.dbd_strategy_construct_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(dd.dbd_strategy_construct_r),grpstats(dd.dbd_speech_hate_yes,dd.dbd_strategy_construct_r),grpstats(dd.dbd_speech_hate_yes,dd.dbd_strategy_construct_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(dd.dbd_strategy_construct_r),grpstats(dd.dbd_extreme_score,dd.dbd_strategy_construct_r),grpstats(dd.dbd_extreme_score,dd.dbd_strategy_construct_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: constructive','fontsize',14); 
ylabel('Next day','fontsize',14)
xlim([-.05 .55]); ylim([.1 .3])
grid



subplot(4,4,3)
errorbar(unique(d.strategy_sarc_r),grpstats(d.next_tox,d.strategy_sarc_r),grpstats(d.next_tox,d.strategy_sarc_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.strategy_sarc_r),grpstats(d_next.next_speech_hate_yes,d.strategy_sarc_r),grpstats(d_next.next_speech_hate_yes,d.strategy_sarc_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.strategy_sarc_r),grpstats(d_next.next_extreme_score,d.strategy_sarc_r),grpstats(d_next.next_extreme_score,d.strategy_sarc_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: sarcasm','fontsize',14); 
%ylabel('Quality of discourse: the next tweet','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,7)
errorbar(unique(d.strategy_sarc_r),grpstats(d.all_tox,d.strategy_sarc_r),grpstats(d.all_tox,d.strategy_sarc_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.strategy_sarc_r),grpstats(d_all.all_speech_hate_yes,d.strategy_sarc_r),grpstats(d_all.all_speech_hate_yes,d.strategy_sarc_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.strategy_sarc_r),grpstats(d_all.all_extreme_score,d.strategy_sarc_r),grpstats(d_all.all_extreme_score,d.strategy_sarc_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: sarcasm','fontsize',14); 
%ylabel('Quality of discourse: the rest of the tree','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,11)
errorbar(unique(d.strategy_sarc_r),grpstats(d.re_tox,d.strategy_sarc_r),grpstats(d.re_tox,d.strategy_sarc_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.strategy_sarc_r),grpstats(d_re.re_speech_hate_yes,d.strategy_sarc_r),grpstats(d_re.re_speech_hate_yes,d.strategy_sarc_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.strategy_sarc_r),grpstats(d_re.re_extreme_score,d.strategy_sarc_r),grpstats(d_re.re_extreme_score,d.strategy_sarc_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: sarcasm','fontsize',14); 
%ylabel('Quality of discourse: direct replies','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,15)
errorbar(unique(dd.dbd_strategy_sarc_r),grpstats(dd.dbd_tox,dd.dbd_strategy_sarc_r),grpstats(dd.dbd_tox,dd.dbd_strategy_sarc_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(dd.dbd_strategy_sarc_r),grpstats(dd.dbd_speech_hate_yes,dd.dbd_strategy_sarc_r),grpstats(dd.dbd_speech_hate_yes,dd.dbd_strategy_sarc_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(dd.dbd_strategy_sarc_r),grpstats(dd.dbd_extreme_score,dd.dbd_strategy_sarc_r),grpstats(dd.dbd_extreme_score,dd.dbd_strategy_sarc_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: sarcasm','fontsize',14); 
ylabel('Next day','fontsize',14)
xlim([-.05 .55]); ylim([.1 .3])
grid



subplot(4,4,4)
errorbar(unique(d.strategy_leave_fact_r),grpstats(d.next_tox,d.strategy_leave_fact_r),grpstats(d.next_tox,d.strategy_leave_fact_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.strategy_leave_fact_r),grpstats(d_next.next_speech_hate_yes,d.strategy_leave_fact_r),grpstats(d_next.next_speech_hate_yes,d.strategy_leave_fact_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.strategy_leave_fact_r),grpstats(d_next.next_extreme_score,d.strategy_leave_fact_r),grpstats(d_next.next_extreme_score,d.strategy_leave_fact_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: insults','fontsize',14); 
%ylabel('Quality of discourse: the next tweet','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,8)
errorbar(unique(d.strategy_leave_fact_r),grpstats(d.all_tox,d.strategy_leave_fact_r),grpstats(d.all_tox,d.strategy_leave_fact_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.strategy_leave_fact_r),grpstats(d_all.all_speech_hate_yes,d.strategy_leave_fact_r),grpstats(d_all.all_speech_hate_yes,d.strategy_leave_fact_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.strategy_leave_fact_r),grpstats(d_all.all_extreme_score,d.strategy_leave_fact_r),grpstats(d_all.all_extreme_score,d.strategy_leave_fact_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: insults','fontsize',14); 
%ylabel('Quality of discourse: the rest of the tree','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid


subplot(4,4,12)
errorbar(unique(d.strategy_leave_fact_r),grpstats(d.re_tox,d.strategy_leave_fact_r),grpstats(d.re_tox,d.strategy_leave_fact_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.strategy_leave_fact_r),grpstats(d_re.re_speech_hate_yes,d.strategy_leave_fact_r),grpstats(d_re.re_speech_hate_yes,d.strategy_leave_fact_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.strategy_leave_fact_r),grpstats(d_re.re_extreme_score,d.strategy_leave_fact_r),grpstats(d_re.re_extreme_score,d.strategy_leave_fact_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: insults','fontsize',14); 
%ylabel('Quality of discourse: direct replies','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,16)
errorbar(unique(dd.dbd_strategy_leave_fact_r),grpstats(dd.dbd_tox,dd.dbd_strategy_leave_fact_r),grpstats(dd.dbd_tox,dd.dbd_strategy_leave_fact_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(dd.dbd_strategy_leave_fact_r),grpstats(dd.dbd_speech_hate_yes,dd.dbd_strategy_leave_fact_r),grpstats(dd.dbd_speech_hate_yes,dd.dbd_strategy_leave_fact_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(dd.dbd_strategy_leave_fact_r),grpstats(dd.dbd_extreme_score,dd.dbd_strategy_leave_fact_r),grpstats(dd.dbd_extreme_score,dd.dbd_strategy_leave_fact_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: insults','fontsize',14); 
ylabel('Next day','fontsize',14)
xlim([-.05 .55]); ylim([.1 .3])
grid



%% plot relationship between ingroup-outgroup and next tweet/next day indicators of quality (rest of the tree or direct reply better)
%topic2_in_both topic2_out goal2_in_both_positive goal2_out_negative

%close all
figure

temp=round(d.topic2_in_both,1);
d.topic2_in_both_r=temp; 
d.topic2_in_both_r(temp==max(temp))=round(max(temp)-.1,1); 

temp=round(d.topic2_out,1);
d.topic2_out_r=temp; 
d.topic2_out_r(temp==max(temp))=round(max(temp)-.1,1); 

temp=round(d.goal2_in_both_positive_r,1);
d.goal2_in_both_positive_r=temp; 
d.goal2_in_both_positive_r(temp==max(temp))=round(max(temp)-.1,1); 

temp=round(d.goal2_out_negative,1);
d.goal2_out_negative_r=temp; 
d.goal2_out_negative_r(temp==max(temp))=round(max(temp)-.1,1); 


temp=round(dd.dbd_topic2_in_both,1);
dd.dbd_topic2_in_both_r=temp; 
%dd.dbd_topic2_in_both_r(temp==max(temp))=round(max(temp)-.1,1); 

temp=round(dd.dbd_topic2_out,1);
dd.dbd_topic2_out_r=temp; 
%dd.dbd_topic2_out_r(temp==max(temp))=round(max(temp)-.1,1); 

temp=round(dd.dbd_goal2_in_both_positive,1);
dd.dbd_goal2_in_both_positive_r=temp; 
%dd.dbd_goal2_in_both_positive_r(temp==max(temp))=round(max(temp)-.1,1); 

temp=round(dd.dbd_goal2_out_negative,1);
dd.dbd_goal2_out_negative_r=temp; 
%dd.dbd_goal2_out_negative_r(temp==max(temp))=round(max(temp)-.1,1); 


subplot(4,4,1)
errorbar(unique(d.topic2_in_both_r),grpstats(d.next_tox,d.topic2_in_both_r),grpstats(d.next_tox,d.topic2_in_both_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.topic2_in_both_r),grpstats(d_next.next_speech_hate_yes,d.topic2_in_both_r),grpstats(d_next.next_speech_hate_yes,d.topic2_in_both_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.topic2_in_both_r),grpstats(d_next.next_extreme_score,d.topic2_in_both_r),grpstats(d_next.next_extreme_score,d.topic2_in_both_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: ingroup or both groups','fontsize',14); 
ylabel('Quality of discourse: next tweet','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid
l=legend('Toxicity','Hate speech','Extremity of speech');
l.FontSize=12;

subplot(4,4,5)
errorbar(unique(d.topic2_in_both_r),grpstats(d.all_tox,d.topic2_in_both_r),grpstats(d.all_tox,d.topic2_in_both_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.topic2_in_both_r),grpstats(d_all.all_speech_hate_yes,d.topic2_in_both_r),grpstats(d_all.all_speech_hate_yes,d.topic2_in_both_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.topic2_in_both_r),grpstats(d_all.all_extreme_score,d.topic2_in_both_r),grpstats(d_all.all_extreme_score,d.topic2_in_both_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: ingroup or both groups','fontsize',14); 
ylabel('Quality of discourse: rest of the tree','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,9)
errorbar(unique(d.topic2_in_both_r),grpstats(d.re_tox,d.topic2_in_both_r),grpstats(d.re_tox,d.topic2_in_both_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.topic2_in_both_r),grpstats(d_re.re_speech_hate_yes,d.topic2_in_both_r),grpstats(d_re.re_speech_hate_yes,d.topic2_in_both_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.topic2_in_both_r),grpstats(d_re.re_extreme_score,d.topic2_in_both_r),grpstats(d_re.re_extreme_score,d.topic2_in_both_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: ingroup or both groups','fontsize',14); 
ylabel('Quality of discourse: direct replies','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,13)
errorbar(unique(dd.dbd_topic2_in_both_r),grpstats(dd.dbd_tox,dd.dbd_topic2_in_both_r),grpstats(dd.dbd_tox,dd.dbd_topic2_in_both_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(dd.dbd_topic2_in_both_r),grpstats(dd.dbd_speech_hate_yes,dd.dbd_topic2_in_both_r),grpstats(dd.dbd_speech_hate_yes,dd.dbd_topic2_in_both_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(dd.dbd_topic2_in_both_r),grpstats(dd.dbd_extreme_score,dd.dbd_topic2_in_both_r),grpstats(dd.dbd_extreme_score,dd.dbd_topic2_in_both_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: ingroup or both groups','fontsize',14); 
ylabel('Next day','fontsize',14)
xlim([-.05 .55]); ylim([.1 .3])
grid


subplot(4,4,2)
errorbar(unique(d.topic2_out_r),grpstats(d.next_tox,d.topic2_out_r),grpstats(d.next_tox,d.topic2_out_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.topic2_out_r),grpstats(d_next.next_speech_hate_yes,d.topic2_out_r),grpstats(d_next.next_speech_hate_yes,d.topic2_out_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.topic2_out_r),grpstats(d_next.next_extreme_score,d.topic2_out_r),grpstats(d_next.next_extreme_score,d.topic2_out_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: outgroup','fontsize',14); 
%ylabel('Quality of discourse: the next tweet','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,6)
errorbar(unique(d.topic2_out_r),grpstats(d.all_tox,d.topic2_out_r),grpstats(d.all_tox,d.topic2_out_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.topic2_out_r),grpstats(d_all.all_speech_hate_yes,d.topic2_out_r),grpstats(d_all.all_speech_hate_yes,d.topic2_out_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.topic2_out_r),grpstats(d_all.all_extreme_score,d.topic2_out_r),grpstats(d_all.all_extreme_score,d.topic2_out_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: outgroup','fontsize',14); 
%ylabel('Quality of discourse: the rest of the tree','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,10)
errorbar(unique(d.topic2_out_r),grpstats(d.re_tox,d.topic2_out_r),grpstats(d.re_tox,d.topic2_out_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.topic2_out_r),grpstats(d_re.re_speech_hate_yes,d.topic2_out_r),grpstats(d_re.re_speech_hate_yes,d.topic2_out_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.topic2_out_r),grpstats(d_re.re_extreme_score,d.topic2_out_r),grpstats(d_re.re_extreme_score,d.topic2_out_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: outgroup','fontsize',14); 
%ylabel('Quality of discourse: direct replies','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,14)
errorbar(unique(dd.dbd_topic2_out_r),grpstats(dd.dbd_tox,dd.dbd_topic2_out_r),grpstats(dd.dbd_tox,dd.dbd_topic2_out_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(dd.dbd_topic2_out_r),grpstats(dd.dbd_speech_hate_yes,dd.dbd_topic2_out_r),grpstats(dd.dbd_speech_hate_yes,dd.dbd_topic2_out_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(dd.dbd_topic2_out_r),grpstats(dd.dbd_extreme_score,dd.dbd_topic2_out_r),grpstats(dd.dbd_extreme_score,dd.dbd_topic2_out_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: outgroup','fontsize',14); 
%ylabel('Next day','fontsize',14)
xlim([-.05 .55]); ylim([.1 .3])
grid


subplot(4,4,3)
errorbar(unique(d.goal2_in_both_positive_r),grpstats(d.next_tox,d.goal2_in_both_positive_r),grpstats(d.next_tox,d.goal2_in_both_positive_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.goal2_in_both_positive_r),grpstats(d_next.next_speech_hate_yes,d.goal2_in_both_positive_r),grpstats(d_next.next_speech_hate_yes,d.goal2_in_both_positive_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.goal2_in_both_positive_r),grpstats(d_next.next_extreme_score,d.goal2_in_both_positive_r),grpstats(d_next.next_extreme_score,d.goal2_in_both_positive_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: positive own/both','fontsize',14); 
%ylabel('Quality of discourse: the next tweet','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,7)
errorbar(unique(d.goal2_in_both_positive_r),grpstats(d.all_tox,d.goal2_in_both_positive_r),grpstats(d.all_tox,d.goal2_in_both_positive_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.goal2_in_both_positive_r),grpstats(d_all.all_speech_hate_yes,d.goal2_in_both_positive_r),grpstats(d_all.all_speech_hate_yes,d.goal2_in_both_positive_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.goal2_in_both_positive_r),grpstats(d_all.all_extreme_score,d.goal2_in_both_positive_r),grpstats(d_all.all_extreme_score,d.goal2_in_both_positive_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: positive own/both','fontsize',14); 
%ylabel('Quality of discourse: the rest of the tree','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,11)
errorbar(unique(d.goal2_in_both_positive_r),grpstats(d.re_tox,d.goal2_in_both_positive_r),grpstats(d.re_tox,d.goal2_in_both_positive_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.goal2_in_both_positive_r),grpstats(d_re.re_speech_hate_yes,d.goal2_in_both_positive_r),grpstats(d_re.re_speech_hate_yes,d.goal2_in_both_positive_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.goal2_in_both_positive_r),grpstats(d_re.re_extreme_score,d.goal2_in_both_positive_r),grpstats(d_re.re_extreme_score,d.goal2_in_both_positive_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: positive own/both','fontsize',14); 
%ylabel('Quality of discourse: direct replies','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,15)
errorbar(unique(dd.dbd_goal2_in_both_positive_r),grpstats(dd.dbd_tox,dd.dbd_goal2_in_both_positive_r),grpstats(dd.dbd_tox,dd.dbd_goal2_in_both_positive_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(dd.dbd_goal2_in_both_positive_r),grpstats(dd.dbd_speech_hate_yes,dd.dbd_goal2_in_both_positive_r),grpstats(dd.dbd_speech_hate_yes,dd.dbd_goal2_in_both_positive_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(dd.dbd_goal2_in_both_positive_r),grpstats(dd.dbd_extreme_score,dd.dbd_goal2_in_both_positive_r),grpstats(dd.dbd_extreme_score,dd.dbd_goal2_in_both_positive_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: positive own/both','fontsize',14); 
%ylabel('Next day','fontsize',14)
xlim([-.05 .55]); ylim([.1 .3])
grid


subplot(4,4,4)
errorbar(unique(d.goal2_out_negative_r),grpstats(d.next_tox,d.goal2_out_negative_r),grpstats(d.next_tox,d.goal2_out_negative_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.goal2_out_negative_r),grpstats(d_next.next_speech_hate_yes,d.goal2_out_negative_r),grpstats(d_next.next_speech_hate_yes,d.goal2_out_negative_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.goal2_out_negative_r),grpstats(d_next.next_extreme_score,d.goal2_out_negative_r),grpstats(d_next.next_extreme_score,d.goal2_out_negative_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: negative out','fontsize',14); 
%ylabel('Quality of discourse: the next tweet','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,8)
errorbar(unique(d.goal2_out_negative_r),grpstats(d.all_tox,d.goal2_out_negative_r),grpstats(d.all_tox,d.goal2_out_negative_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.goal2_out_negative_r),grpstats(d_all.all_speech_hate_yes,d.goal2_out_negative_r),grpstats(d_all.all_speech_hate_yes,d.goal2_out_negative_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.goal2_out_negative_r),grpstats(d_all.all_extreme_score,d.goal2_out_negative_r),grpstats(d_all.all_extreme_score,d.goal2_out_negative_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: negative out','fontsize',14); 
%ylabel('Quality of discourse: the rest of the tree','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid


subplot(4,4,12)
errorbar(unique(d.goal2_out_negative_r),grpstats(d.re_tox,d.goal2_out_negative_r),grpstats(d.re_tox,d.goal2_out_negative_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.goal2_out_negative_r),grpstats(d_re.re_speech_hate_yes,d.goal2_out_negative_r),grpstats(d_re.re_speech_hate_yes,d.goal2_out_negative_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.goal2_out_negative_r),grpstats(d_re.re_extreme_score,d.goal2_out_negative_r),grpstats(d_re.re_extreme_score,d.goal2_out_negative_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: negative out','fontsize',14); 
%ylabel('Quality of discourse: direct replies','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,16)
errorbar(unique(dd.dbd_goal2_out_negative_r),grpstats(dd.dbd_tox,dd.dbd_goal2_out_negative_r),grpstats(dd.dbd_tox,dd.dbd_goal2_out_negative_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(dd.dbd_goal2_out_negative_r),grpstats(dd.dbd_speech_hate_yes,dd.dbd_goal2_out_negative_r),grpstats(dd.dbd_speech_hate_yes,dd.dbd_goal2_out_negative_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(dd.dbd_goal2_out_negative_r),grpstats(dd.dbd_extreme_score,dd.dbd_goal2_out_negative_r),grpstats(dd.dbd_extreme_score,dd.dbd_goal2_out_negative_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: negative_out','fontsize',14); 
%ylabel('Next day','fontsize',14)
xlim([-.05 .55]); ylim([.1 .3])
grid




%% plot relationship between emotions and next tweet/next day indicators of quality (rest of the tree or direct reply better)
%anger fear disgust enthusiasm

%close all
figure

temp=round(d.anger,1);
d.anger_r=temp; 
%d.anger_r(temp==max(temp))=round(max(temp)-.1,1); 

temp=round(d.fear,1);
d.fear_r=temp; 
d.fear_r(temp==max(temp))=round(max(temp)-.1,1); 

temp=round(d.disgust,1);
d.disgust=temp; 
%d.disgust(temp==max(temp))=round(max(temp)-.1,1); 

temp=round(d.enthop,1);
d.enthop_r=temp; 
%d.enthusiasm_r(temp==max(temp))=round(max(temp)-.1,1); 

temp=round(d.prijoy,1);
d.prijoy_r=temp; 
%d.enthusiasm_r(temp==max(temp))=round(max(temp)-.1,1); 


temp=round(dd.dbd_anger,2);
dd.dbd_anger_r=temp; 
%dd.dbd_anger_r(temp==min(temp))=round(min(temp)+.1,1); 

temp=round(dd.dbd_fear,2);
dd.dbd_fear_r=temp; 
%dd.dbd_fear_r(temp==max(temp))=round(max(temp)-.1,1); 

temp=round(dd.dbd_disgust,2);
dd.dbd_disgust_r=temp; 
%dd.dbd_disgust_r(temp==max(temp))=round(max(temp)-.1,1); 

temp=round(dd.dbd_enthop,2);
dd.dbd_enthop_r=temp; 
%dd.dbd_enthop_r(temp==max(temp))=round(max(temp)-.1,1); 

temp=round(dd.dbd_prijoy,2);
dd.dbd_prijoy_r=temp; 
%dd.dbd_enthop_r(temp==max(temp))=round(max(temp)-.1,1); 


subplot(4,4,1)
errorbar(unique(d.anger_r),grpstats(d.next_tox,d.anger_r),grpstats(d.next_tox,d.anger_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.anger_r),grpstats(d_next.next_speech_hate_yes,d.anger_r),grpstats(d_next.next_speech_hate_yes,d.anger_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.anger_r),grpstats(d_next.next_extreme_score,d.anger_r),grpstats(d_next.next_extreme_score,d.anger_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: anger','fontsize',14); 
ylabel('Quality of discourse: next tweet','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid
l=legend('Toxicity','Hate speech','Extremity of speech');
l.FontSize=12;

subplot(4,4,5)
errorbar(unique(d.anger_r),grpstats(d.all_tox,d.anger_r),grpstats(d.all_tox,d.anger_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.anger_r),grpstats(d_all.all_speech_hate_yes,d.anger_r),grpstats(d_all.all_speech_hate_yes,d.anger_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.anger_r),grpstats(d_all.all_extreme_score,d.anger_r),grpstats(d_all.all_extreme_score,d.anger_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: anger','fontsize',14); 
ylabel('Quality of discourse: rest of the tree','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,9)
errorbar(unique(d.anger_r),grpstats(d.re_tox,d.anger_r),grpstats(d.re_tox,d.anger_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.anger_r),grpstats(d_re.re_speech_hate_yes,d.anger_r),grpstats(d_re.re_speech_hate_yes,d.anger_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.anger_r),grpstats(d_re.re_extreme_score,d.anger_r),grpstats(d_re.re_extreme_score,d.anger_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: anger','fontsize',14); 
ylabel('Quality of discourse: direct replies','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,13)
errorbar(unique(dd.dbd_anger_r),grpstats(dd.dbd_tox,dd.dbd_anger_r),grpstats(dd.dbd_tox,dd.dbd_anger_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(dd.dbd_anger_r),grpstats(dd.dbd_speech_hate_yes,dd.dbd_anger_r),grpstats(dd.dbd_speech_hate_yes,dd.dbd_anger_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(dd.dbd_anger_r),grpstats(dd.dbd_extreme_score,dd.dbd_anger_r),grpstats(dd.dbd_extreme_score,dd.dbd_anger_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: anger','fontsize',14); 
ylabel('Next day','fontsize',14)
xlim([.4 .95]); ylim([0 .4])
grid



subplot(4,4,2)
errorbar(unique(d.fear_r),grpstats(d.next_tox,d.fear_r),grpstats(d.next_tox,d.fear_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.fear_r),grpstats(d_next.next_speech_hate_yes,d.fear_r),grpstats(d_next.next_speech_hate_yes,d.fear_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.fear_r),grpstats(d_next.next_extreme_score,d.fear_r),grpstats(d_next.next_extreme_score,d.fear_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: fear','fontsize',14); 
%ylabel('Quality of discourse: the next tweet','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,6)
errorbar(unique(d.fear_r),grpstats(d.all_tox,d.fear_r),grpstats(d.all_tox,d.fear_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.fear_r),grpstats(d_all.all_speech_hate_yes,d.fear_r),grpstats(d_all.all_speech_hate_yes,d.fear_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.fear_r),grpstats(d_all.all_extreme_score,d.fear_r),grpstats(d_all.all_extreme_score,d.fear_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: fear','fontsize',14); 
%ylabel('Quality of discourse: the rest of the tree','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,10)
errorbar(unique(d.fear_r),grpstats(d.re_tox,d.fear_r),grpstats(d.re_tox,d.fear_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.fear_r),grpstats(d_re.re_speech_hate_yes,d.fear_r),grpstats(d_re.re_speech_hate_yes,d.fear_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.fear_r),grpstats(d_re.re_extreme_score,d.fear_r),grpstats(d_re.re_extreme_score,d.fear_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: fear','fontsize',14); 
%ylabel('Quality of discourse: direct replies','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,14)
errorbar(unique(dd.dbd_fear_r),grpstats(dd.dbd_tox,dd.dbd_fear_r),grpstats(dd.dbd_tox,dd.dbd_fear_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(dd.dbd_fear_r),grpstats(dd.dbd_speech_hate_yes,dd.dbd_fear_r),grpstats(dd.dbd_speech_hate_yes,dd.dbd_fear_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(dd.dbd_fear_r),grpstats(dd.dbd_extreme_score,dd.dbd_fear_r),grpstats(dd.dbd_extreme_score,dd.dbd_fear_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: fear','fontsize',14); 
%ylabel('Next day','fontsize',14)
xlim([-.05 .55]); ylim([0 .4])
grid



subplot(4,4,3)
errorbar(unique(d.disgust),grpstats(d.next_tox,d.disgust),grpstats(d.next_tox,d.disgust,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.disgust),grpstats(d_next.next_speech_hate_yes,d.disgust),grpstats(d_next.next_speech_hate_yes,d.disgust,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.disgust),grpstats(d_next.next_extreme_score,d.disgust),grpstats(d_next.next_extreme_score,d.disgust,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: disgust','fontsize',14); 
%ylabel('Quality of discourse: the next tweet','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,7)
errorbar(unique(d.disgust),grpstats(d.all_tox,d.disgust),grpstats(d.all_tox,d.disgust,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.disgust),grpstats(d_all.all_speech_hate_yes,d.disgust),grpstats(d_all.all_speech_hate_yes,d.disgust,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.disgust),grpstats(d_all.all_extreme_score,d.disgust),grpstats(d_all.all_extreme_score,d.disgust,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: disgust','fontsize',14); 
%ylabel('Quality of discourse: the rest of the tree','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid
.55
subplot(4,4,11)
errorbar(unique(d.disgust),grpstats(d.re_tox,d.disgust),grpstats(d.re_tox,d.disgust,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.disgust),grpstats(d_re.re_speech_hate_yes,d.disgust),grpstats(d_re.re_speech_hate_yes,d.disgust,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.disgust),grpstats(d_re.re_extreme_score,d.disgust),grpstats(d_re.re_extreme_score,d.disgust,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: disgust','fontsize',14); 
%ylabel('Quality of discourse: direct replies','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,15)
errorbar(unique(dd.dbd_disgust_r),grpstats(dd.dbd_tox,dd.dbd_disgust_r),grpstats(dd.dbd_tox,dd.dbd_disgust_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(dd.dbd_disgust_r),grpstats(dd.dbd_speech_hate_yes,dd.dbd_disgust_r),grpstats(dd.dbd_speech_hate_yes,dd.dbd_disgust_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(dd.dbd_disgust_r),grpstats(dd.dbd_extreme_score,dd.dbd_disgust_r),grpstats(dd.dbd_extreme_score,dd.dbd_disgust_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: disgust','fontsize',14); 
%ylabel('Next day','fontsize',14)
xlim([-.05 .55]); ylim([0 .4])
grid


subplot(4,4,4)
errorbar(unique(d.enthop_r),grpstats(d.next_tox,d.enthop_r),grpstats(d.next_tox,d.enthop_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.enthop_r),grpstats(d_next.next_speech_hate_yes,d.enthop_r),grpstats(d_next.next_speech_hate_yes,d.enthop_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.enthop_r),grpstats(d_next.next_extreme_score,d.enthop_r),grpstats(d_next.next_extreme_score,d.enthop_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: enthusiasm','fontsize',14); 
%ylabel('Quality of discourse: the next tweet','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,8)
errorbar(unique(d.enthop_r),grpstats(d.all_tox,d.enthop_r),grpstats(d.all_tox,d.enthop_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.enthop_r),grpstats(d_all.all_speech_hate_yes,d.enthop_r),grpstats(d_all.all_speech_hate_yes,d.enthop_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.enthop_r),grpstats(d_all.all_extreme_score,d.enthop_r),grpstats(d_all.all_extreme_score,d.enthop_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: enthusiasm','fontsize',14); 
%ylabel('Quality of discourse: the rest of the tree','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid


subplot(4,4,12)
errorbar(unique(d.enthop_r),grpstats(d.re_tox,d.enthop_r),grpstats(d.re_tox,d.enthop_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.enthop_r),grpstats(d_re.re_speech_hate_yes,d.enthop_r),grpstats(d_re.re_speech_hate_yes,d.enthop_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.enthop_r),grpstats(d_re.re_extreme_score,d.enthop_r),grpstats(d_re.re_extreme_score,d.enthop_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: enthusiasm','fontsize',14); 
%ylabel('Quality of discourse: direct replies','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,16)
errorbar(unique(dd.dbd_enthop_r),grpstats(dd.dbd_tox,dd.dbd_enthop_r),grpstats(dd.dbd_tox,dd.dbd_enthop_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(dd.dbd_enthop_r),grpstats(dd.dbd_speech_hate_yes,dd.dbd_enthop_r),grpstats(dd.dbd_speech_hate_yes,dd.dbd_enthop_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(dd.dbd_enthop_r),grpstats(dd.dbd_extreme_score,dd.dbd_enthop_r),grpstats(dd.dbd_extreme_score,dd.dbd_enthop_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: enthusiasm','fontsize',14); 
%ylabel('Next day','fontsize',14)
xlim([-.05 .55]); ylim([0 .4])
grid


%% %% with pride and joy
subplot(4,4,4)
errorbar(unique(d.prijoy_r),grpstats(d.next_tox,d.prijoy_r),grpstats(d.next_tox,d.prijoy_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.prijoy_r),grpstats(d_next.next_speech_hate_yes,d.prijoy_r),grpstats(d_next.next_speech_hate_yes,d.prijoy_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.prijoy_r),grpstats(d_next.next_extreme_score,d.prijoy_r),grpstats(d_next.next_extreme_score,d.prijoy_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: enthusiasm','fontsize',14); 
%ylabel('Quality of discourse: the next tweet','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,8)
errorbar(unique(d.prijoy_r),grpstats(d.all_tox,d.prijoy_r),grpstats(d.all_tox,d.prijoy_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.prijoy_r),grpstats(d_all.all_speech_hate_yes,d.prijoy_r),grpstats(d_all.all_speech_hate_yes,d.prijoy_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.prijoy_r),grpstats(d_all.all_extreme_score,d.prijoy_r),grpstats(d_all.all_extreme_score,d.prijoy_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: enthusiasm','fontsize',14); 
%ylabel('Quality of discourse: the rest of the tree','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid


subplot(4,4,12)
errorbar(unique(d.prijoy_r),grpstats(d.re_tox,d.prijoy_r),grpstats(d.re_tox,d.prijoy_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(d.prijoy_r),grpstats(d_re.re_speech_hate_yes,d.prijoy_r),grpstats(d_re.re_speech_hate_yes,d.prijoy_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(d.prijoy_r),grpstats(d_re.re_extreme_score,d.prijoy_r),grpstats(d_re.re_extreme_score,d.prijoy_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: enthusiasm','fontsize',14); 
%ylabel('Quality of discourse: direct replies','fontsize',14)
xlim([-.05 1.05]); ylim([.1 .3])
grid

subplot(4,4,16)
errorbar(unique(dd.dbd_prijoy_r),grpstats(dd.dbd_tox,dd.dbd_prijoy_r),grpstats(dd.dbd_tox,dd.dbd_prijoy_r,{'sem'}),'color',rgb('Dark Red'),'linewidth',1)
hold on
errorbar(unique(dd.dbd_prijoy_r),grpstats(dd.dbd_speech_hate_yes,dd.dbd_prijoy_r),grpstats(dd.dbd_speech_hate_yes,dd.dbd_prijoy_r,{'sem'}),'color',rgb('Red'),'linewidth',1)
hold on
errorbar(unique(dd.dbd_prijoy_r),grpstats(dd.dbd_extreme_score,dd.dbd_prijoy_r),grpstats(dd.dbd_extreme_score,dd.dbd_prijoy_r,{'sem'}),'color',rgb('Orange'),'linewidth',1)
xlabel('Probability: enthusiasm','fontsize',14); 
%ylabel('Next day','fontsize',14)
xlim([-.05 .55]); ylim([0 .4])
grid




%% plot relationship between strategy and next tweet/next day indicators of quality (rest of the tree or direct reply better)
%d.strategy_opin d.strategy_construct d.strategy_sarc d.strategy_leave_fact d.strategy_other_new

close all
figure
%## THIS - NEEDS TO BE ALL NEXT. TO DO - RECALCULATE AGIAN DBASIC ETC MAKE SURE YOU KNOW WHAT IS WHAT
subplot(4,4,1)
scatter(dd.dbd_strategy_opin,dd.dbd_next_tox,'.','MarkerEdgeColor',rgb('Dark Red')); 
hold on
scatter(dd.dbd_strategy_opin,dd.dbd_speech_hate_yes,'.','MarkerEdgeColor',rgb('Red')); 
hold on
scatter(dd.dbd_strategy_opin,dd.dbd_extreme_score,'.','MarkerEdgeColor',rgb('Orange')); 
lsline
xlabel('Probability: opinion','fontsize',14); 
ylabel('Next day','fontsize',14)
%xlim([-.05 .55]); ylim([.1 .3])
grid

subplot(4,4,2)
scatter(dd.dbd_strategy_construct,dd.dbd_tox,'.','MarkerEdgeColor',rgb('Dark Red')); 
hold on
scatter(dd.dbd_strategy_construct,dd.dbd_speech_hate_yes,'.','MarkerEdgeColor',rgb('Red')); 
hold on
scatter(dd.dbd_strategy_construct,dd.dbd_extreme_score,'.','MarkerEdgeColor',rgb('Orange')); 
lsline
xlabel('Probability: constructive','fontsize',14); 
ylabel('Next day','fontsize',14)
%xlim([-.05 .55]); ylim([.1 .3])
grid

subplot(4,4,3)
scatter(dd.dbd_strategy_sarc,dd.dbd_tox,'.','MarkerEdgeColor',rgb('Dark Red')); 
hold on
scatter(dd.dbd_strategy_sarc,dd.dbd_speech_hate_yes,'.','MarkerEdgeColor',rgb('Red')); 
hold on
scatter(dd.dbd_strategy_sarc,dd.dbd_extreme_score,'.','MarkerEdgeColor',rgb('Orange')); 
lsline
xlabel('Probability: sarcasm','fontsize',14); 
ylabel('Next day','fontsize',14)
%xlim([-.05 .55]); ylim([.1 .3])
grid

subplot(4,4,4)
scatter(dd.dbd_strategy_leave_fact,dd.dbd_tox,'.','MarkerEdgeColor',rgb('Dark Red')); 
hold on
scatter(dd.dbd_strategy_leave_fact,dd.dbd_speech_hate_yes,'.','MarkerEdgeColor',rgb('Red')); 
hold on
scatter(dd.dbd_strategy_leave_fact,dd.dbd_extreme_score,'.','MarkerEdgeColor',rgb('Orange')); 
lsline
xlabel('Probability: insults','fontsize',14); 
ylabel('Next day','fontsize',14)
%xlim([-.05 .55]); ylim([.1 .3])
grid


% plot relationship between ingroup-outgroup and next tweet/next day indicators of quality (rest of the tree or direct reply better)
%topic2_in_both topic2_out goal2_in_both_positive goal2_out_negative

subplot(4,4,5)
scatter(dd.dbd_goal2_in_both_positive,dd.dbd_tox,'.','MarkerEdgeColor',rgb('Dark Red')); 
hold on
scatter(dd.dbd_goal2_in_both_positive,dd.dbd_speech_hate_yes,'.','MarkerEdgeColor',rgb('Red')); 
hold on
scatter(dd.dbd_goal2_in_both_positive,dd.dbd_extreme_score,'.','MarkerEdgeColor',rgb('Orange')); 
lsline
xlabel('Probability: positive own/both','fontsize',14); 
ylabel('Next day','fontsize',14)
%xlim([-.05 .55]); ylim([.1 .3])
grid

subplot(4,4,6)
scatter(dd.dbd_goal2_out_negative,dd.dbd_tox,'.','MarkerEdgeColor',rgb('Dark Red')); 
hold on
scatter(dd.dbd_goal2_out_negative,dd.dbd_speech_hate_yes,'.','MarkerEdgeColor',rgb('Red')); 
hold on
scatter(dd.dbd_goal2_out_negative,dd.dbd_extreme_score,'.','MarkerEdgeColor',rgb('Orange')); 
lsline
xlabel('Probability: negative out','fontsize',14); 
ylabel('Next day','fontsize',14)
%xlim([-.05 .55]); ylim([.1 .3])
grid


subplot(4,4,7)
scatter(dd.dbd_enthop,dd.dbd_tox,'.','MarkerEdgeColor',rgb('Dark Red')); 
hold on
scatter(dd.dbd_enthop,dd.dbd_speech_hate_yes,'.','MarkerEdgeColor',rgb('Red')); 
hold on
scatter(dd.dbd_enthop,dd.dbd_extreme_score,'.','MarkerEdgeColor',rgb('Orange')); 
lsline
xlabel('Probability: enthusiasm & hope','fontsize',14); 
ylabel('Next day','fontsize',14)
%xlim([-.05 .55]); ylim([.1 .3])
grid


subplot(4,4,8)
scatter(dd.dbd_prijoy,dd.dbd_tox,'.','MarkerEdgeColor',rgb('Dark Red')); 
hold on
scatter(dd.dbd_prijoy,dd.dbd_speech_hate_yes,'.','MarkerEdgeColor',rgb('Red')); 
hold on
scatter(dd.dbd_prijoy,dd.dbd_extreme_score,'.','MarkerEdgeColor',rgb('Orange')); 
lsline
xlabel('Probability: pride & joy','fontsize',14); 
ylabel('Next day','fontsize',14)
%xlim([-.05 .55]); ylim([.1 .3])
grid


% plot relationship between emotions and next tweet/next day indicators of quality (rest of the tree or direct reply better)
%anger fear disgust enthusiasm

subplot(4,4,9)
scatter(dd.dbd_anger,dd.dbd_tox,'.','MarkerEdgeColor',rgb('Dark Red')); 
hold on
scatter(dd.dbd_anger,dd.dbd_speech_hate_yes,'.','MarkerEdgeColor',rgb('Red')); 
hold on
scatter(dd.dbd_anger,dd.dbd_extreme_score,'.','MarkerEdgeColor',rgb('Orange')); 
lsline
xlabel('Probability: anger','fontsize',14); 
ylabel('Next day','fontsize',14)
%xlim([-.05 .55]); ylim([.1 .3])
grid

subplot(4,4,10)
scatter(dd.dbd_fear,dd.dbd_tox,'.','MarkerEdgeColor',rgb('Dark Red')); 
hold on
scatter(dd.dbd_fear,dd.dbd_speech_hate_yes,'.','MarkerEdgeColor',rgb('Red')); 
hold on
scatter(dd.dbd_fear,dd.dbd_extreme_score,'.','MarkerEdgeColor',rgb('Orange')); 
lsline
xlabel('Probability: fear','fontsize',14); 
ylabel('Next day','fontsize',14)
%xlim([-.05 .55]); ylim([.1 .3])
grid

subplot(4,4,11)
scatter(dd.dbd_disgust,dd.dbd_tox,'.','MarkerEdgeColor',rgb('Dark Red')); 
hold on
scatter(dd.dbd_disgust,dd.dbd_speech_hate_yes,'.','MarkerEdgeColor',rgb('Red')); 
hold on
scatter(dd.dbd_disgust,dd.dbd_extreme_score,'.','MarkerEdgeColor',rgb('Orange')); 
lsline
xlabel('Probability: disgust','fontsize',14); 
ylabel('Next day','fontsize',14)
%xlim([-.05 .55]); ylim([.1 .3])
grid


subplot(4,4,12)
scatter(dd.dbd_sadness,dd.dbd_tox,'.','MarkerEdgeColor',rgb('Dark Red')); 
hold on
scatter(dd.dbd_sadness,dd.dbd_speech_hate_yes,'.','MarkerEdgeColor',rgb('Red')); 
hold on
scatter(dd.dbd_sadness,dd.dbd_extreme_score,'.','MarkerEdgeColor',rgb('Orange')); 
lsline
xlabel('Probability: sadness','fontsize',14); 
ylabel('Next day','fontsize',14)
%xlim([-.05 .55]); ylim([.1 .3])
grid

ADD USERS, COLOR LSLINES, SHOW THOSE BIVARIATE ANALYSES. THEN ARDL TOGETHER
AND FOR TREES - NO PLOTS!