// Stan model to estimate exploitation rate of lamprey in Garonne & Dordogne rivers
// I should express variables and parameters as vectors of length 2 (2 rivers)
data {
  int r; //Number of rivers
  int<lower=0> Marked[r]; //Number of individuals tagged each river
  int<lower=0> Rec_t[r]; //Number of individuals retrieved with two tags
  int<lower=0> Rec_a[r]; //Number of individuals retrieved with anterior tag only
  int<lower=0> Rec_p[r]; //Number of individuals retrieved with posterior tag only

  real<lower=0> Effort[r]; //Capture effort (boats*days)
  int<lower=0> Capt[r]; // Total number of captures (tagged or not)
  int<lower=0> Rec_Philippe; //Number of taggged individuals retrieved by Philippe
  int<lower=0> Capt_Philippe; // Total number of individuals captured by Philippe
}
transformed data{
  int<lower=0> Rec[r]; //Number of individuals retrieved with at least one tag
  int<lower=0> Rec_T; //Number of individuals retrieved with at least one tag in any river
  int<lower=0> one_lost; //Number of individuals retrieved with only one tag in any river
  for(i in 1:r)
    Rec[i]=Rec_t[i]+Rec_a[i]+Rec_p[i];

  Rec_T=sum(Rec);
  one_lost=sum(Rec_a)+sum(Rec_p);
}

parameters {
  real p_survive; //Probability to survive between tagging and recapture
  real p_loss; //Probability to loose one tag
  real p_catch; //Probability to be caught by any fisherman over the whole season (=! capturability per effort unit)
  real<lower=0, upper=1> p_return; //Probability that a tag caught by a fisherman is returned
  real<lower=0> Pop[r]; // Population size in each river
}
model {
  //Priors
  p_survive~beta(1,1); // Informed by MIGADO's radiotracking study
  p_loss~uniform(0,1); // No prior information
  p_catch~uniform(0,1); // No prior information
  p_return~uniform(0,1); // No prior information
  for(i in 1:r)
    Pop[i]~uniform(Capt[i],100*Capt[i]);
  
  //Likelihood
  one_lost ~  binomial(Rec_T,p_loss); // The number of individuals retrieved with one tag follows a binomial
  Rec_Philippe ~ binomial (Capt_Philippe,Rec_T/(p_return*sum(Capt)));

  //for(i in 1:r){
  //  Rec[i] ~ binomial(Marked[i],(1-p_loss^2)*p_survive*p_catch*p_return);
   // Capt[i] ~ binomial(Pop[i],(1-p_loss^2)*p_survive*p_catch*p_return); // Pop must be a real because it is a parameter; but it must be an integer to be passed to binomal distribution
  //}
}
