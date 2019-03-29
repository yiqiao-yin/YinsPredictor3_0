# Project Title: YinsPredictor3_0

This package is designed to assist money managers to build better understanding of action-based trading behaviors.

<p align="center">
  <img src="https://github.com/yiqiao-yin/YinsPredictor3_0/blob/master/figs/2017-12-01-to-2018-12-01.gif">
</p>

## Information

Information:
- Package: YinsPredictoR
- Type: Package
- Title: Stock Behavior and Trading Decision Given a Ticker
- Version: 0.3.0
- Author: Yiqiao Yin
- Maintainer: Yiqiao Yin <eagle0504@gmail.com>
- Description: This package advises a trading/investment decision given a stock ticker.
- License: GPL-2 [What is GPL-2?](http://r-pkgs.had.co.nz/description.html#license)
- imports: quantmod,stats,xts,TTR,knitr
- Encoding: UTF-8
- LazyData: true

The package originated from [YinsPredictor2_0](https://github.com/yiqiao-yin/YinsPredictor2_0). It is updated with a buy/sell signal table, statistics, and comments.
- The theorem of how to construct these signals come from Yin's Research, click [here](https://yinscapital.com/research/).
- The app with this function built in is [here](https://y-yin.shinyapps.io/CENTRAL-INTELLIGENCE-PLATFORM/).

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

Basic working knowledge of using *R* and *RStudio*.

### Installing

The installation of this package is simple. We recommend to use *devtools* to install from Github.

```
# Install Packge using devtools
devtools::install_github("yiqiao-yin/YinsPredictor3_0")
```

### Usage

Inputs are the following:
- *starting.percentile=.8*: the algorithm downloads all data but reports beginning from the 80% percentile of observation;
- *ending.percentile=1*: the algorithm downloads all data but reports ending at the 100% percentile of observation (i.e. all of the observations which implies ending at the most recent business day);
- *c.buy=-1.96*: a value related to the critical value in t-distribution and default is set at -1.96, implying user is interested at the bottom 5% of the low prices (How low is low? This value is calculated relatively by looking at multiple different levels of moving averages and historical stock price. Theoretically, |1.96| indicating +/- 5%, but in practice one should check the statistics table in the output.);
- *c.sell=+1.96*: a value related to the critical value in t-distribution and default is set at +1.96, implying user is interested at the top 5% of the high prices (How high is high? This value is calculated relatively by looking at multiple different levels of moving averages and historical stock price. Theoretically, |1.96| indicating +/- 5%, but in practice one should check the statistics table in the output.);
- *height=1*: a default value to scale the buy/signals (it can be changed so that user can scale all signals to mean zero);
- *past.n.days=3*: this parameter tells the algorithm how many past days of data to report (the algorithm always downloads all the historically available data from Yahoo Finance);
- *test.new.price=0*: default is set to 0 so that algorithm will download data as it is (meaning that the last observation is the most recent trading day); there is no need to change this if user has time frame bigger than a day as the algorithm downloads live data every time it executes; however, if user observes interesting pricing behavior during trading hours, then we make it available to change this parameter to any value that is observed and the algorithm will treat that value as the most recent value to conduct computation.

Output is a list of objects: 
- *TS.Result*: The first object has a comment with a quantity calculated from backend of the package. This is a string of text. The calculation does not take *test.new.price* into consideration, because *test.new.price* is mostly for intraday movement and for the scope of time-series analysis conducted in our algorithm the smallest unit of analysis is "day" (anything less than a day time-series will not consider).
- *Buy.Sell.Signal.Table*: The second object is a table resulting from a more complex comptutation from the packge. This is tabular form of buy/sell signals.
- *Statistics*: The third object is a table resulting from buy/sell signals. It is in tabular form and summarizes the statistics of buy/sell signals.
- *Comment* and *Notes*: The four and fifth are comments and notes.

## Soft Threshold

Money Management is more of an art than science. The soft threshold here is how to change **c.buy** to adapt to different stocks at different market environment. Default value is |1.96| which indicating a theoretical 5% of pricing activities out there. However, this is not always the case. For example, the math that comes up with 5% value is dependent on t-distribution, which is dependent on central limit theorem which we need law of large numbers. For IPOs, it is intuitive that this would fail, because the tapes trades pure and all sorts of human interactions can come in to the market any time, causing consistent fall or rise in a way that this algorithm will not differentiate. This is simply because this algorithm needs data (usually the company should be at least 5 years old).

If you strictly follow this algorithm and my thresholds, you should be able to pin point bottom 5% of the stocks for almost all companies that are in the market for at least 5 years. For younger companies, I do not see sophisticated algorithm to detect "bottom" or "top". 

## Example: Simple Results

An example usage of this package can refer to the following. Suppose user just wants to see some quick results. Such research can be done pre-market and we can use the following code to accomplish this.

```
# For example
Sys.time(); YinsPredictoR::yins_predictor('NFLX')

# Output
[1] "2019-02-27 03:50:43 EST"
$inter.based.Learning
[1] "Interaction-based Learning: Tomorrow this stock goes up with probability: 0.29"

$Buy.Sell.Signal.Table


|           | ClosePriceofNFLX| BuySignal| SellSignal|
|:----------|----------------:|---------:|----------:|
|2019-02-21 |           356.97|         0|          0|
|2019-02-22 |           363.02|         0|          0|
|2019-02-25 |           363.91|         0|          0|
|2019-02-26 |           364.97|         0|          0|

$Statistics


|                | ActionFreq|  Mean|    SD|
|:---------------|----------:|-----:|-----:|
|BuySignalStats  |       0.04|  7.05| 38.26|
|SellSignalStats |       0.15| 22.64| 63.14|

$Comment
[1] "We recommend buy frequency to be less than 0.04 for the first entry. Moreover, the expectation of buy signals is 7.05 and the standard deviation is 38.26, respectively. Hence, we conclude: Do nothing."
```

With default values set to thresholds that are tailored to my experience and personality, one can observe that there are barely any activities happening. This is intuitive in the sense that mispricings do not happen very often. The sudden drop or jump that deserve our attention probably occur very few times a year.

## Example: Intra-day

Suppose user observes any unlikely pricing activities in the market and it is of his/her interest to discover posterior results based on this new observation. It is recommended to use the following code to update a new price. The algorithm will update itself. 

```
# Let us set the input *test.new.price* to some arbitrarily low value.
Sys.time(); YinsPredictoR::yins_predictor('NFLX', test.new.price = 100)

# Output
[1] "2019-02-27 03:51:27 EST"
$inter.based.Learning
[1] "Interaction-based Learning: Tomorrow this stock goes up with probability: 0.29"

$Buy.Sell.Signal.Table


|           | ClosePriceofNFLX| BuySignal| SellSignal|
|:----------|----------------:|---------:|----------:|
|2019-02-22 |           363.02|    0.0000|          0|
|2019-02-25 |           363.91|    0.0000|          0|
|2019-02-26 |           364.97|    0.0000|          0|
|2019-02-27 |           100.00|  440.1835|          0|

$Statistics


|                | ActionFreq|  Mean|    SD|
|:---------------|----------:|-----:|-----:|
|BuySignalStats  |       0.04|  6.98| 38.66|
|SellSignalStats |       0.15| 22.26| 62.57|

$Comment
[1] "We recommend buy frequency to be less than 0.04 for the first entry. Moreover, the expectation of buy signals is 6.98 and the standard deviation is 38.66, respectively. Hence, we conclude: Enter this stock."
```

In this case, the algorithm will learn about this sudden and perhaps bizarre activity to make a new decision. This function is also designed for intra-day activities. For regular users, simply run the function every morning and it shall be sufficient, because the algorithm downloads live data every time it runs.

## Example: Use Recurrent Neural Network

<p align="center">
  <img src="https://github.com/yiqiao-yin/YinsPredictor3_0/blob/master/figs/rnn%2C%20lstm.gif">
</p>

Recurrent neural networks (RNNs) are a class of artificial neural networks which are often used with sequential data. The 3 most common types of recurrent neural networks are vanilla RNN, long short-term memory (LSTM), proposed by Hochreiter and Schmidhuber in 1997, and
gated recurrent units (GRU), proposed by [Cho et. al in 2014](https://arxiv.org/abs/1409.1259).

A few good sources to explain RNN are:
- [RNN, LSTM, GRU](https://towardsdatascience.com/animated-rnn-lstm-and-gru-ef124d06cf45);
- [Illustrated Guide LSTM](https://towardsdatascience.com/illustrated-guide-to-lstms-and-gru-s-a-step-by-step-explanation-44e9eb85bf21).

As an example, we can use RNN as machine learning algorithm to predict the probability a given stock is going up or down the next trading day. Simple code can be found in the following. 

```
YinsPredictoR::yins_predictor_rnn("NFLX", epochs = 10)
```

## Reinforcement Learning

We can train an agent by using a very basic reinforcement learning model to learn to trade stocks using Yin's Predictor.

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

More details can be found [here](https://github.com/yiqiao-yin/YinsPredictor3_0/tree/master/Reinforcement%20Learning).

## Built With

* [Yiqiao Yin's Research](https://yinscapital.com/research/): We conduct research at Yin's Capital and we develop packages for trading algorithms.

## Contributing

Yiqiao Yin (myself) is the sole owner and manager for this package. The origin of author's inspiration of developing this package comes from his experience in statistical machine learning and stock market. For story, please click [here](https://github.com/yiqiao-yin/Statistical_Machine_Learning/blob/master/Story.md).
