# Reinforcment Learning

Introduction here.

## Toy Simulation

```
# Reinforcement Learning
# This is a baby version of a reinforced strategy using Yin's Predictor
# Let us train an agent to learn a strategy designed by Yin's Predictor
BuyAction <- c(); SellAction <- c()
for (i in 1:nrow(data$Raw.Buy.Sell.Signal.Table)) {
  if (data$Raw.Buy.Sell.Signal.Table$BuySignal[i] > 0) {
    print(paste0("There is a buy action."))
    BuyAction[i] <- -data$Raw.Buy.Sell.Signal.Table[i,1]
  } else { BuyAction[i] <- BuyAction[i-1] }
  if (data$Raw.Buy.Sell.Signal.Table$SellSignal[i] > 0) {
    print(paste0("There is a sell action."))
    SellAction[i] <- data$Raw.Buy.Sell.Signal.Table[i,1]
  } else {SellAction[i] <- SellAction[i-1] }
} # End of RL Training

# Result
data$Raw.Buy.Sell.Signal.Table$Value <- rowMeans(cbind(BuyAction, SellAction))

# Output
# Let us plot the past 500 days of profit/loss trading this stock
# rebased with the growth of this stock in order to simulate the performance
# comparison investing in this particular stock versus using Yin's 
# Reinforced Learning Strategy
library(dygraphs)
N <- nrow(data$Raw.Buy.Sell.Signal.Table)
dygraph(data$Raw.Buy.Sell.Signal.Table[(N-500):N, c(1,4)]) %>% dyRebase()
```
## Simulation

Given a stock and a certain amount of money, it is recommended to trade this stock in the following manner. In this RL design, we have:
- an agent: a stock trader;
- a serious of actions: buy, sell, do nothing;
- reward/penalty: profit and/or loss (which is monitored by thye monetary value, i.e. the worth according to current stock price).

With the definition described above, we execute the following protocols:
- Buy a unit of shares condition on a buy signal;
- Sell a unit of shares condition on a sell signal;
- Hold or do nothing if observe nothing. 

```
data <- YinsPredictoR::yins_predictor('NFLX', c.buy = -1.96, c.sell = 3, past.n.days = 2000)
temp <- data$Raw.Buy.Sell.Signal.Table; colnames(temp)[1] <- "Close"

# Reinforcement Learning
# With above prototype in mind, let us code a more strategic algorithm.
# Managed parameters:
# (1) Shares
# (2) BuyAction
# (3) SellAction
temp$Action <- 0;  temp$Action[1] <- 0; shs <- 1
N <- nrow(temp)
for (t in 2:N) {
  if (temp$Action[t-1] > 0) {temp$Action[t] <- temp$Action[t-1]}
  if (sum(temp$Action[t-1], temp$BuySignal[t]) > 0) {
    if (temp$BuySignal[t] > 0) {
      temp$Action[t] <- temp$Action[t-1] + shs
    }
  }
  if (temp$SellSignal[t] > 0) {
    if (temp$Action[t] > 0) {
      temp$Action[t] <- temp$Action[t] - shs
    }
  }
} # End of agent's actions

# Compute Accumulated Value
temp$Value <- temp$Close * temp$Action

# Plot
library(dygraphs)
dygraph(temp[(N-300):N, c(1,5)]) %>% dyRebase()
knitr::kable(summary(lm(temp$Value~temp$Close,temp))$coefficients)
```
Results of above experiment are presented below. We can observe path for this stock versus trading with this strategy. 

[Path for target stock versus RL strategy](https://github.com/yiqiao-yin/YinsPredictor3_0/blob/master/Reinforcement%20Learning/RL-Trial-2019-3-4-Screenshot-1.PNG)

We know that such strategy is creating an alpha because regression model has a constant term that is significant which translates to the graph above as the consistent difference between stock price and simulated strategy monetary value. 

[Regression model results](https://github.com/yiqiao-yin/YinsPredictor3_0/blob/master/Reinforcement%20Learning/RL-Trial-2019-3-4-Screenshot-2.PNG)
