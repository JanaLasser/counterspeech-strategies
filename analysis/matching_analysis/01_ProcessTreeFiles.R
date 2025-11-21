library(dplyr)
library(readxl)
files <- list.files(path="treeFiles", pattern="*.xlsx", full.names=TRUE, recursive=FALSE)

tdf <- data.frame()
adf <- data.frame()
i <- 0
for (file in files)
{
    df <- read_xlsx(file)
    df$ts <- as.numeric(as.POSIXct(df$date))
    df %>% arrange(ts) -> df
    df$tweetpos <- seq(1, nrow(df))
    ndf <- data.frame(id= as.character(df$id), tweetid=as.character(df$tweet_id),
                      treeid=as.character(df$tree_id), treenr=as.character(df$tree_nr),
                      tweetpos = df$tweetpos, treesize=nrow(df),
                      ts = df$ts,
                      userid=as.character(df$user_twitter_id), replytoid=as.character(df$in_reply_to2),
                      TOXICITY=df$tox, HATE=df$speech_hate_yes,
                      SPEECHEXT=abs(0.5-df$hate_score), PARTEXT=df$user_group_70e,
                      OPINION=df$strategy_opin, SARCASM=df$strategy_sarc, CONSTRUCTIVE=df$strategy_construct, 
                      INSULT=df$strategy_leave_fact, OTHER=df$strategy_other_new,
                      EXCL=df$goal2_out_negative, INCL=df$goal2_in_both_positive,
                      ANGER=df$anger, FEAR=df$fear,
                      DISGUST=df$disgust, SADNESS=df$sadness,
                      HOPENTH=df$enthusiasm+df$hope, PRIJOY=df$pride+df$joy)
    
    ndf %>% select(tweetid, userid, replytoid) -> andf
    adf <- rbind(adf, andf)
    
    pairsdf <- data.frame()
    for (uid in unique(ndf$userid))
    {
      ndf %>% filter(userid==uid) %>% arrange(ts) -> sdf
      if (nrow(sdf)>1)
      {
        firstdf <- sdf[1:(nrow(sdf)-1),]
        names(firstdf) <- paste0(names(firstdf), rep("_1", ncol(firstdf)))
        
        seconddf <- sdf[2:(nrow(sdf)),]
        names(seconddf) <- paste0(names(seconddf), rep("_2", ncol(seconddf)))
        pairsdf <- rbind(pairsdf, cbind(firstdf, seconddf))
      }
    }
    
    if (nrow(pairsdf)>0)
    {
      PRdf <- inner_join(pairsdf, ndf, by=c("tweetid_1" = "replytoid"))
      PRdf %>% filter(ts < ts_2 & userid != userid_1) -> fdf
      tdf <- rbind(tdf, fdf)
    }
    print(file)
    i <- i+1
    print(i)
    if (i%%1000 == 0)
    {
      write.csv(tdf, file="triads.csv", row.names=F)
      write.csv(adf, file="tweetbasics.csv", row.names=F)
    }
}

write.csv(tdf, file="triads.csv", row.names=F)
write.csv(adf, file="tweetbasics.csv", row.names=F)

