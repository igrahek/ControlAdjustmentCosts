library("brms")
library("MASS")

# set seed
set.seed(42) 

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
### Import the data
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

df.trial = read.csv("../data/SpeedAccuracyISI_nSubs_50.csv")

df.trial$hit = as.numeric(df.trial$hit)

# Change the name of the congruency variable
df.trial$Congruency = df.trial$type

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
### Re-scale the data
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Contrast code the categorical variables
df.trial$Congruency = ordered(df.trial$type, levels = c("congruent", "incongruent"))
contrasts(df.trial$Congruency) = contr.sdif(2)
colnames(attr(df.trial$Congruency, "contrasts")) =  c("inc_min_con")

df.trial$blockType = ordered(df.trial$blockType, levels = c("Varying","Fixed"))
contrasts(df.trial$blockType) = contr.sdif(2)
colnames(attr(df.trial$blockType, "contrasts")) =  c("Varying_min_Fixed")

df.trial$intervalType = ordered(df.trial$intervalType, levels = c("Speed","Accuracy"))
contrasts(df.trial$intervalType) = contr.sdif(2)
colnames(attr(df.trial$intervalType, "contrasts")) =  c("Speed_min_Accuracy")

df.trial$previntervalType = ordered(df.trial$previntervalType, levels = c("Speed","Accuracy"))
contrasts(df.trial$previntervalType) = contr.sdif(2)
colnames(attr(df.trial$previntervalType, "contrasts")) =  c("Speed_min_Accuracy")

df.trial$Switch = ordered(df.trial$Switch, levels = c("Switch","Repeat"))
contrasts(df.trial$Switch) = contr.sdif(2)
colnames(attr(df.trial$Switch, "contrasts")) =  c("Switch_min_Repeat")

df.trial$intervalNumHalf = ifelse(df.trial$intervalNum>15,"Second","First")
df.trial$intervalNumHalf = ordered(df.trial$intervalNumHalf, levels = c("Second","First"))
contrasts(df.trial$intervalNumHalf) = contr.sdif(2)
colnames(attr(df.trial$intervalNumHalf, "contrasts")) =  c("Second_min_First")

df.trial$isi = ifelse(df.trial$isi==250,"ISI_250",df.trial$isi)
df.trial$isi = ifelse(df.trial$isi==1000,"ISI_1000",df.trial$isi)
df.trial$isi = ordered(df.trial$isi, levels = c("ISI_250", "ISI_1000"))
contrasts(df.trial$isi) = contr.sdif(2)
colnames(attr(df.trial$isi, "contrasts")) =  c("1000_min_250")

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
### Set the priors 
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# prior = c(
#   prior(normal(1.56, 0.12), class = Intercept),
#   prior(normal(-0.59, 0.09), class = b, coef=Congruencyincongruent),
#   prior(normal(0.11, 0.16), class = b, coef=mbased_efficacy_prev),
#   prior(normal(-0.36, 0.19), class = b, coef=mbased_reward_prev))

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
### Fit the accuracy model
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
model.Acc = brm(hit ~ Congruency + isi*intervalType*blockType + scaledIntervalSessionNum + scaledIntervalLength + scaledRunningTime + (Congruency + isi*intervalType*blockType|uniqueid),
                                         data=df.trial,
                                         family="bernoulli",
                                         #prior = prior,
                                         iter  = 20000,
                                         warmup = 19000,
                                         save_pars=save_pars(all=TRUE),
                                         cores = 4,
                                         sample_prior = TRUE)
saveRDS(model.Acc,file="../output/model.Acc.rds")
