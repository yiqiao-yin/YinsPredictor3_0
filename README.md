# Project Title: YinsPredictor3_0

This package is designed to assist money managers to build better understanding of action-based trading behaviors.

## Information

Information:
- Package: YinsPredictoR
- Type: Package
- Title: Stock Behavior and Trading Decision Given a Ticker
- Version: 0.3.0
- Author: Yiqiao Yin
- Maintainer: Yiqiao Yin <eagle0504@gmail.com>
- Description: This package advises a trading/investment decision given a stock ticker.
- License: GPL-1
- imports: quantmod,stats,xts,TTR,knitr
- Encoding: UTF-8
- LazyData: true

The package originate from source [SAURAV KAUSHIK, MARCH 22, 2017](https://www.analyticsvidhya.com/blog/2017/03/create-packages-r-cran-github/).
It is updated with a buy/sell signal table. 
- The theorem of how to construct these signals come from Yin's Research, click [here](https://yinscapital.com/research/).
- The app with this function built in is [here](https://y-yin.shinyapps.io/CENTRAL-INTELLIGENCE-PLATFORM/)

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

Output is a list of objects: 
- The first object has a comment with a quantity calculated from backend of the package. This is a string of text.
- The second object is a table resulting from a more complex comptutation from the packge. This is tabular form of buy/sell signals.
- The third object is a table resulting from buy/sell signals. It is in tabular form and summarizes the statistics of buy/sell signals.
- The four and fifth are comments and notes.

## Built With

* [Yiqiao Yin's Research](https://yinscapital.com/research/): We conduct research at Yin's Capital and we develop packages for trading algorithms.

## Contributing

Yiqiao Yin (myself) is the sole owner and manager for this package. The origin of author's inspiration of developing this package comes from his experience in statistical machine learning and stock market. For story, please click [here](https://github.com/yiqiao-yin/Statistical_Machine_Learning/blob/master/Story.md).
