# Reinforcment Learning

Reinforcement learning is an area of Machine Learning. It is about taking suitable action to maximize reward in a particular situation. It is employed by various software and machines to find the best possible behavior or path it should take in a specific situation.

This section let me introduce my version of trading strategy given a particular stock.

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

Annotations:
- **Close**: This is the path for the target stock which we use daily closing price to record. This is served as a benchmark in this experiment.
- **Value**: This is the path for the values for simulated strategy using reinforced agent that takes advantage of Yin's predictor. 

<p align="center">
  <img src="https://github.com/yiqiao-yin/YinsPredictor3_0/blob/master/Reinforcement%20Learning/RL-Trial-2019-3-4-Screenshot-2.PNG">
</p>

We know that such strategy is creating an alpha because regression model has a constant term that is significant which translates to the graph above as the consistent difference between stock price and simulated strategy monetary value. This evidence can be seen from the regression results below. We observe the intercept has a statistically significant test statistics. 

<p align="center">
  <img src="https://github.com/yiqiao-yin/YinsPredictor3_0/blob/master/Reinforcement%20Learning/RL-Trial-2019-3-4-Screenshot-1.PNG">
</p>

I also made a small animation showing time elapsed performance for Yin's Leveraged Reinforced Strategy versus investing in target stock. This algorithm, presented in the following animation, allows traders to flip 5- or even 6-folds under high leverage. This means you can return 500% return under high leverage trading environment (here standard trading leverage is 4x account value for beginners and 8x to 12x account values for senior traders).

<p align="center">
  <img src="https://github.com/yiqiao-yin/YinsPredictor3_0/blob/master/Reinforcement%20Learning/2019-3-6-RL.gif">
</p>

## Soft Threshold

I always cover this part for every algorithm I introduce for the purpose of "stock trading is art than science" philosphy. 

The soft thresholds here is:
- What stock? Given a stock, I introduce this strategy. However, stock picking skill is also very important. I have another algorithm covering this part. 
- How much money deserves to be allocated to this stock? This is about the weight of a stock comparing to overall portfolio which is related to modern portfolio theory. However, there is much more advanced version to achieve this goal. 
- For answers, please click [here](https://yiqiaoyin.files.wordpress.com/2018/12/rubust-portfolio-by-influence-measure-yiqiao-yin-2018.pdf)
