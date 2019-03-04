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
