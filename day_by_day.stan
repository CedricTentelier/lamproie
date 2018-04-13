// Stan model for CMR on lamprey
// Data are expressed as daily number of fish captured

data {
  int days; //Number of days in the experiment
  int marked; //Number of individuals marked
  int recaptured[days]; //Number of individuals captured each day
  real effort[days]; //Capture effort on each day
}

transformed data{
  int remain[days]; //Number of marked individuals remaining in the population each day
  remain[1]=marked;
  for(d in 2:days)
    remain[d]=remain[d-1]-recaptured[d-1];
}

parameters{
  real <lower=0> alpha; // Alpha parameter of the beta distribution from which daily catchabilities are drawn
  real <lower=0> beta; // Beta parameter of the beta distribution from which daily catchabilities are drawn
  real <lower=0, upper=1> catchability[days]; //Catchability for each day
}

transformed parameters{
  real <lower=0, upper=1> p_capture[days]; //Probability of capture for each day
  real <lower=0, upper=1> exploitation_rate; //Probability that an individual gets caught anytime
  real <lower=0, upper=1> mean_catchability; //Mean of the beta distribution for p_capture
  real <lower=0> var_catchability; //Variance of the beta distribution for p_capture
  for(d in 1:days)
    p_capture[d]=catchability[d]*effort[d];
  exploitation_rate=sum(p_capture);
  mean_catchability=alpha/(alpha+beta);
  var_catchability=(alpha*beta)/((alpha+beta)^2*(alpha+beta+1));

}

model{
  //Priors
  alpha~gamma(0.001,0.001);
  beta~gamma(0.001,0.001);

  //Likelihood
  recaptured~binomial(remain,p_capture);
  catchability~beta(alpha,beta);
}
