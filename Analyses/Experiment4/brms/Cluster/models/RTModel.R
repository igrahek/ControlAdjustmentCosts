library("brms")
library("MASS")

# set seed
set.seed(42) 

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
### Import the data
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

df.trial= read.csv("../data/SpeedAccuracyProb_nSubs_55.csv")

# Change the name of the congruency variable
df.trial$Congruency = df.trial$type

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
### Re-scale the data
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Contrast code the categorical variables
df.trial$Congruency = ordered(df.trial$type, levels = c("congruent", "incongruent"))
contrasts(df.trial$Congruency) = contr.sdif(2)
colnames(attr(df.trial$Congruency, "contrasts")) =  c("inc_min_con")

df.trial$blockType = ordered(df.trial$blockType, levels = c("2intervals", "4intervals", "8intervals","Fixed"))  
contrasts(df.trial$blockType) <- contr.poly(4)
colnames(attr(df.trial$blockType, "contrasts")) =  c("Linear", "Quadratic","Cubical") # Change the name of the contrasts

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
model.RT = brm(AccRT ~ Congruency + intervalType * blockType + scaledIntervalSessionNum + scaledIntervalLength + scaledRunningTime + (Congruency + intervalType * blockType|uniqueid),
                                        data=df.trial,
                                        family=exgaussian(),
                                        #prior = prior,
                                        cores = 4,
                                        iter  = 20000,
                                        warmup = 19000,
                                        save_pars=save_pars(all=TRUE),
                                        sample_prior = TRUE)
saveRDS(model.RT,file="../output/model.RT.rds")
