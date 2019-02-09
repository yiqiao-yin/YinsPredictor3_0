# Project Title: YinsPredictor3_0

This package is designed to assist money managers to build better understanding of action-based trading behaviors.

<p align="center">
  <img src="https://github.com/yiqiao-yin/YinsPredictor3_0/blob/master/2017-12-01-to-2018-12-01.gif">
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

Basic working knowledge of using *R* and *RSTudio*.

### Installing

The installation of this package is simple. We recommend to use *devtools* to install from Github.

```
# Install Packge using devtools
devtools::install_github("yiqiao-yin/YinsPredictor2_0")
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
- *TS.Result*: The first object has a comment with a quantity calculated from backend of the package. This is a string of text.
- *Buy.Sell.Signal.Table*: The second object is a table resulting from a more complex comptutation from the packge. This is tabular form of buy/sell signals.
- *Statistics*: The third object is a table resulting from buy/sell signals. It is in tabular form and summarizes the statistics of buy/sell signals.
- *Comment* and *Notes*: The four and fifth are comments and notes.

## Soft Threshold

Money Management is more of an art than science. The soft threshold here is how to change **c.buy** to adapt to different stocks at different market environment. Default value is |1.96| which indicating a theoretical 5% of pricing activities out there. However, this is not always the case. For example, the math that comes up with 5% value is dependent on t-distribution, which is dependent on central limit theorem which we need law of large numbers. For IPOs, it is intuitive that this would fail, because the tapes trades pure and all sorts of human interactions can come in to the market any time, causing consistent fall or rise in a way that this algorithm will not differentiate. This is simply because this algorithm needs data (usually the company should be at least 5 years old).

If you strictly follow this algorithm and my thresholds, you should be able to pin point bottom 5% of the stocks for almost all companies that are in the market for at least 5 years. For younger companies, I do not see sophisticated algorithm to detect "bottom" or "top". 

## Example

An example usage of this package can refer to the following.

```
# For example
Sys.time(); YinsPredictoR::yins_predictor('NFLX')

# Output
[1] "2019-02-09 12:11:41 EST"
$TS.Result
[1] "Tomorrow this stock goes up with probability: 0.93"

$Buy.Sell.Signal.Table


|           | ClosePriceofNFLX| BuySignal| SellSignal|
|:----------|----------------:|---------:|----------:|
|2019-02-05 |           355.81|         0|          0|
|2019-02-06 |           352.19|         0|          0|
|2019-02-07 |           344.71|         0|          0|
|2019-02-08 |           347.57|         0|          0|

$Statistics


|                | ActionFreq|  Mean|    SD|
|:---------------|----------:|-----:|-----:|
|BuySignalStats  |       0.04|  6.91| 37.74|
|SellSignalStats |       0.15| 22.29| 62.18|

$Comment
[1] "We recommend buy frequency to be less than 0.04 for the first entry. Moreover, the expectation of buy signals is 6.91 and the standard deviation is 37.74, respectively. Hence, we conclude: Do nothing."

$Notes
[1] "PS: We recommend action frequency (ActionFreq) to be less than 5% and do nothing if signal values are less than 1 SD above Mean."
```

With default values set to thresholds that are tailored to my experience and personality, one can observe that there are barely any activities happening. This is intuitive in the sense that mispricings do not happen very often. The sudden drop or jump that deserve our attention probably occur very few times a year.

That being said, if user observes any unlikely pricing activities in the market, user could use the following:
```
# Let us set the input *test.new.price* to some arbitrarily low value.
Sys.time(); YinsPredictoR::yins_predictor('NFLX', test.new.price = 100)

# Output
[1] "2019-02-09 13:01:13 EST"
$TS.Result
[1] "Tomorrow this stock goes up with probability: 0.93"

$Buy.Sell.Signal.Table


|           | ClosePriceofNFLX| BuySignal| SellSignal|
|:----------|----------------:|---------:|----------:|
|2019-02-06 |           352.19|    0.0000|          0|
|2019-02-07 |           344.71|    0.0000|          0|
|2019-02-08 |           347.57|    0.0000|          0|
|2019-02-09 |           100.00|  434.0081|          0|

$Statistics


|                | ActionFreq|  Mean|    SD|
|:---------------|----------:|-----:|-----:|
|BuySignalStats  |       0.04|  6.91| 38.19|
|SellSignalStats |       0.15| 21.90| 61.60|

$Comment
[1] "We recommend buy frequency to be less than 0.04 for the first entry. Moreover, the expectation of buy signals is 6.91 and the standard deviation is 38.19, respectively. Hence, we conclude: Enter this stock."

$Notes
[1] "PS: We recommend action frequency (ActionFreq) to be less than 5% and do nothing if signal values are less than 1 SD above Mean."
```

In this case, the algorithm will learn about this sudden and perhaps bizarre activity to make a new decision. This function is also designed for intra-day activities. For regular users, simply run the function every morning and it shall be sufficient, because the algorithm downloads live data every time it runs.

## Built With

* [Yiqiao Yin's Research](https://yinscapital.com/research/): We conduct research at Yin's Capital and we develop packages for trading algorithms.

## Contributing

Yiqiao Yin (myself) is the sole owner and manager for this package. The origin of author's inspiration of developing this package comes from his experience in statistical machine learning and stock market. For story, please click [here](https://github.com/yiqiao-yin/Statistical_Machine_Learning/blob/master/Story.md).
