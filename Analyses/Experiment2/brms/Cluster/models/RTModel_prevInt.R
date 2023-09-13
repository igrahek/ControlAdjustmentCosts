library("brms")
library("MASS")

# set seed
set.seed(42) 

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
### Import the data
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

df.trial = read.csv("../data/SpeedAccuracySpeedAcc_nSubs_38.csv")

# Remove the cases with NAs in the prev interval variable
df.trial = subset(df.trial,is.na(df.trial$previntervalType)==0)

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

df.trial$intervalType = ordered(df.trial$intervalType, levels = c("Speed","Accuracy","Speed_Accuracy"))
contrasts(df.trial$intervalType) = contr.sdif(3)
colnames(attr(df.trial$intervalType, "contrasts")) =  c("Speed_min_Accuracy","Accuracy_min_Speed_Accuracy")

df.trial$previntervalType = ordered(df.trial$previntervalType, levels = c("Speed","Accuracy","Speed_Accuracy"))
contrasts(df.trial$previntervalType) = contr.sdif(3)
colnames(attr(df.trial$previntervalType, "contrasts")) =  c("Speed_min_Accuracy","Accuracy_min_Speed_Accuracy")

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
### Set the priors based on Experiment 1 posteriors
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# prior = c(
#   prior(normal(655.36, 10.21), class = Intercept),
#   prior(normal(71.29, 5.81), class = b, coef=Congruencyincongruent),
#   prior(normal(-16.00, 9.47), class = b, coef=mbased_efficacy_prev),
#   prior(normal(-1.56, 13.32), class = b, coef=mbased_reward_prev))

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
### Fit the RT model
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
model.RT = brm(AccRT ~ Congruency + intervalType * previntervalType + scaledIntervalSessionNum + scaledIntervalLength + (Congruency + previntervalType * intervalType|uniqueid),
                                        data=subset(df.trial,df.trial$blockType=="Varying"),
                                        family=exgaussian(),
                                        #prior = prior,
                                        cores = 4,
                                        iter  = 20000,
                                        warmup = 19000,
                                        save_pars=save_pars(all=TRUE),
                                        sample_prior = TRUE)
saveRDS(model.RT,file="../output/model.RT_prevInt.rds")
