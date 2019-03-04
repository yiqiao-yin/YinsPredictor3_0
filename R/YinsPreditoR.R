#' @title Predicts Stock Price Movement for Given Stock Symbol
#' @description This package predicts whether the stock price at tommorow's market close would be higher or lower compared to today's closing place.
#' @param symbol
#' @return NULL
#' @examples  yins_predictor('AAPL')
#' @export stock_predict
#'
#' # Define function
yins_predictor <- function(
  # TS Prediction
  # symbol = 'SPY'
  symbol,
  # Buy Symbols
  # starting.percentile=.8; ending.percentile=1; c.buy=-1.96; c.sell=+1.96; height=1; past.n.days=3; test.new.price=0
  starting.percentile=.8, ending.percentile=1, c.buy=-1.96, c.sell=+1.96, height=1, past.n.days=3, test.new.price=0)
{
  
  ## Parameter Check
  # Check values for c.buy and c.sell
  if (c.buy < 0) {} else {c.buy <- -1.96}
  if (c.sell > 0) {} else {c.sell <- +1.96}
  
  ## TS Prediction
  # To ignore the warnings during usage
  options(warn=-1)
  options("getSymbols.warning4.0"=FALSE)
  # Importing price data for the given symbol
  data<-data.frame(xts::as.xts(get(quantmod::getSymbols(symbol))))
  
  # Assighning the column names
  colnames(data) <- c("data.Open","data.High","data.Low","data.Close","data.Volume","data.Adjusted")
  
  # Creating lag and lead features of price column.
  data <- xts::xts(data,order.by=as.Date(rownames(data)))
  data <- as.data.frame(merge(data, lm1=stats::lag(data[,'data.Adjusted'],c(-1,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
                                                                            20,30,40,50,60,100,150,200,250,300))))
  
  # Extracting features from Date
  data$Date<-as.Date(rownames(data))
  data$Day_of_month<-as.integer(format(as.Date(data$Date),"%d"))
  data$Month_of_year<-as.integer(format(as.Date(data$Date),"%m"))
  data$Year<-as.integer(format(as.Date(data$Date),"%y"))
  data$Day_of_week<-as.factor(weekdays(data$Date))
  
  # Naming variables for reference
  today <- 'data.Adjusted'
  tommorow <- 'data.Adjusted.5'
  
  # Creating outcome
  data$up_down <- as.factor(ifelse(data[,tommorow] > data[,today], 1, 0))
  
  ## Interaction based learning
  # Data
  data_new <- data.frame(na.omit(data))
  data_new <- data.frame(cbind(data_new$up_down, data_new[, c(1:32,34,35,37)]))
  data_new$data_new.up_down <- as.numeric(as.character(data_new$data_new.up_down))
  data_new$Day_of_week <- as.numeric(data_new$Day_of_week)
  
  ## Starting from here:
  # Begin function:
  # Compute influence score, i.e., i-score:
  iscore <- function(
    x = t(train.x),
    y = train.y,
    K = K.means.K) {
    
    # Define data frame:
    x = data.frame(x)
    y = data.frame(y)
    
    # Define modified I-score:
    # Standardize
    x.stand <- scale(x)
    k = K
    
    # K-means
    k.means.fit <- kmeans(x.stand, k)
    all <- data.frame(cbind(y, x))
    all$assigned.clusters <- k.means.fit$cluster
    
    # Compute I-score
    i.score.draft <- NULL
    y_bar <- plyr::count(y)[2,2]/sum(plyr::count(y)[,2])
    for (i in 1:length(unique(k.means.fit$cluster))) {
      local.n <- length(all[all$assigned.clusters == i, 1])
      i.score <- local.n^2*(mean(all[all$assigned.clusters == i, 1]) - y_bar)^2
      i.score.draft <- c(i.score.draft, i.score)
    }
    i.score <- mean(i.score.draft)/nrow(all)
    #i.score
    
    # Return modified I-score:
    round(i.score, 2)
  } # End of function
  
  # Run BDA using iscore()
  # For each row, i.e., for each response variable,
  # we want run BDA for them individually.
  m <- ncol(data_new[,-1])
  y <- data_new[,1]
  train.x.copy <- data_new[,-1]; train.y <- y; K.means.K <- round(sqrt(ncol(data_new[,-1]))); num.initial.set <- 1
  # Algorithm starts from here: we need to repeat 1000 times:
  BDA.Algo <- function() {
    # Set Seed
    set.seed(1)
    # Pick Initial Set (state of art) and call it X (capital X):
    initial.set <- data.frame(train.x.copy[,sample(ncol(train.x.copy),size=m,replace=FALSE)])
    # head(initial.set)
    # Records influence path:
    i.score.path <- matrix(0,nrow=2,ncol=m)
    i.score.path <- rbind(colnames(initial.set), i.score.path) #; i.score.path
    # Compute i score for initial set:
    i.score.col <- 1
    # Create iscore path:
    i.score.path[2,i.score.col] <- iscore(x=initial.set, y=train.y, K = 2); # i.score.path
    
    while(i.score.col < m) {
      # Each round: taking turns dropping one variable and computing I-score:
      i <- 0
      initial.set.copy <- initial.set
      i.score.drop <- matrix(0,nrow=1,ncol=ncol(initial.set.copy))
      while (i < ncol(initial.set.copy)){
        i <- i + 1
        initial.set <- data.frame(initial.set.copy[,-i]); # head(initial.set.copy); dim(initial.set)
        i.score.drop[,i] <- iscore(x=initial.set, y=train.y); # i.score.drop;
      }
      
      # This round:
      i.score.path[3,i.score.col] <- which(i.score.drop == max(i.score.drop))[[1]]
      variable.dropped <- which(i.score.drop == max(i.score.drop))[[1]]
      initial.set <- initial.set.copy[,-variable.dropped] # head(initial.set)
      i.score.col <- i.score.col + 1
      
      # Update I-score and ready for next round
      i.score.path[2,i.score.col] <- iscore(x=initial.set, y=train.y); # i.score.path
    }# End of loop
    
    # Record fianl table:
    i.score.path
    
    # Upload data:
    # Indexed a, b, c, ... for different trials.
    final.i.score.path.mat <- i.score.path
    final.i.score.path.mat <- data.frame(as.matrix(final.i.score.path.mat))
    
    # Return
    return(final.i.score.path.mat)
  } # End of function
  
  # Output
  # Compute iscore for each draw
  final.i.score.path.mat <- BDA.Algo()
  
  # Max
  feature.names <- final.i.score.path.mat[
    1,
    (which((
      as.numeric(as.character(unlist(final.i.score.path.mat[2,])))) ==
        max(as.numeric(as.character(unlist(final.i.score.path.mat[2,])))))):ncol(final.i.score.path.mat)]
  data_new_update <- data.frame(cbind(
    data_new$data_new.up_down,
    data_new[
      ,
      colnames(data_new) %in% c(unlist(lapply(
        plyr::count(feature.names)[1,-ncol(plyr::count(feature.names))],
        function(x) as.character(x) )))]))
  
  # Interaction-based learning tomorrow's stock price probability:\
  if (ncol(data_new_update) > 2) {
    interaction.based.probability <- stats::predict(lm(data_new_update$data_new.data_new.up_down~., data=data_new_update), data_new_update[nrow(data_new_update), -1])
  } else {
    interaction.based.probability <- 0.5
  }
  
  ## Buy Signal
  x <- data.frame(xts::as.xts(get(quantmod::getSymbols(symbol))))
  if (test.new.price == 0) {
    x = x
  } else {
    intra.day.test <- matrix(c(0,0,0,test.new.price,0,0), nrow = 1)
    rownames(intra.day.test) <- as.character(Sys.Date())
    colnames(intra.day.test) <- colnames(x)
    x = data.frame(rbind(x, intra.day.test))
  }
  Close<-x[,4] # Define Close as adjusted closing price
  # A new function needs redefine data from above:
  # Create SMA for multiple periods
  SMA10<-TTR::SMA(Close,n=10)
  SMA20<-TTR::SMA(Close,n=20)
  SMA30<-TTR::SMA(Close,n=30)
  SMA50<-TTR::SMA(Close,n=50)
  SMA200<-TTR::SMA(Close,n=200)
  SMA250<-TTR::SMA(Close,n=250)
  
  # Create RSI for multiple periods
  RSI10 <- (TTR::RSI(Close,n=10)-50)*height
  RSI20 <- (TTR::RSI(Close,n=20)-50)*height
  RSI30 <- (TTR::RSI(Close,n=30)-50)*height
  RSI50 <- (TTR::RSI(Close,n=50)-50)*height
  RSI200 <- (TTR::RSI(Close,n=200)-50)*height
  RSI250 <- (TTR::RSI(Close,n=250)-50)*height
  
  # Create computable dataset: Close/SMA_i-1
  ratio_10<-(Close/SMA10-1)
  ratio_20<-(Close/SMA20-1)
  ratio_30<-(Close/SMA30-1)
  ratio_50<-(Close/SMA50-1)
  ratio_200<-(Close/SMA200-1)
  ratio_250<-(Close/SMA250-1)
  all_data_ratio <- cbind.data.frame(
    ratio_10,
    ratio_20,
    ratio_30,
    ratio_50,
    ratio_200,
    ratio_250
  )
  # Here we want to create signal for each column
  # Then we add them all together
  all_data_ratio[is.na(all_data_ratio)] <- 0 # Get rid of NAs
  sd(all_data_ratio[,1])
  sd(all_data_ratio[,2])
  sd(all_data_ratio[,3])
  sd(all_data_ratio[,4])
  sd(all_data_ratio[,5])
  sd(all_data_ratio[,6])
  m<-height*mean(Close)
  
  # Buy Signal
  coef<-c.buy
  all_data_ratio$Sig1<-ifelse(
    all_data_ratio[,1] <= coef*sd(all_data_ratio[,1]),
    m, "0")
  all_data_ratio$Sig2<-ifelse(
    all_data_ratio[,2] <= coef*sd(all_data_ratio[,2]),
    m, "0")
  all_data_ratio$Sig3<-ifelse(
    all_data_ratio[,3] <= coef*sd(all_data_ratio[,3]),
    m, "0")
  all_data_ratio$Sig4<-ifelse(
    all_data_ratio[,4] <= coef*sd(all_data_ratio[,4]),
    m, "0")
  all_data_ratio$Sig5<-ifelse(
    all_data_ratio[,5] <= coef*sd(all_data_ratio[,5]),
    m, "0")
  all_data_ratio$Sig6<-ifelse(
    all_data_ratio[,6] <= coef*sd(all_data_ratio[,6]),
    m, "0")
  all_data_ratio$Signal <- (
    as.numeric(all_data_ratio[,7])
    + as.numeric(all_data_ratio[,8])
    + as.numeric(all_data_ratio[,9])
    + as.numeric(all_data_ratio[,10])
    + as.numeric(all_data_ratio[,11])
    + as.numeric(all_data_ratio[,12])
  )
  all_data_signal <- cbind.data.frame(Close, all_data_ratio$Signal); all_data_buy_signal <- all_data_signal
  
  # Sell Signal
  coef<-c.sell
  all_data_ratio$Sig1<-ifelse(
    all_data_ratio[,1] >= coef*sd(all_data_ratio[,1]),
    m, "0")
  all_data_ratio$Sig2<-ifelse(
    all_data_ratio[,2] >= coef*sd(all_data_ratio[,2]),
    m, "0")
  all_data_ratio$Sig3<-ifelse(
    all_data_ratio[,3] >= coef*sd(all_data_ratio[,3]),
    m, "0")
  all_data_ratio$Sig4<-ifelse(
    all_data_ratio[,4] >= coef*sd(all_data_ratio[,4]),
    m, "0")
  all_data_ratio$Sig5<-ifelse(
    all_data_ratio[,5] >= coef*sd(all_data_ratio[,5]),
    m, "0")
  all_data_ratio$Sig6<-ifelse(
    all_data_ratio[,6] >= coef*sd(all_data_ratio[,6]),
    m, "0")
  all_data_ratio$Signal <- (
    as.numeric(all_data_ratio[,7])
    + as.numeric(all_data_ratio[,8])
    + as.numeric(all_data_ratio[,9])
    + as.numeric(all_data_ratio[,10])
    + as.numeric(all_data_ratio[,11])
    + as.numeric(all_data_ratio[,12])
  )
  all_data_signal <- cbind.data.frame(Close, all_data_ratio$Signal); all_data_sell_signal <- all_data_signal
  
  # Consolidate
  # Here let us put buy sell signal table together
  final_table <- cbind.data.frame(
    Date = rownames(x),
    Buy_Sginal = all_data_buy_signal,
    Sell_Signal = all_data_sell_signal
  )[, -4]
  reduced_table <- data.frame(final_table[(nrow(final_table)-past.n.days):nrow(final_table),]);
  colnames(reduced_table) <- c("Date", paste0("ClosePriceof",symbol), "BuySignal", "SellSignal");
  rownames(reduced_table) <- reduced_table$Date
  
  # Record the statistics
  final_table_stats <- rbind(
    BuySignalStats = c(plyr::count(as.numeric(final_table[,3] > 0))[2,2]/sum(plyr::count(as.numeric(final_table[,3] > 0))[,2]), mean(final_table[,3]), sd(final_table[,3])),
    SellSignalStats = c(plyr::count(as.numeric(final_table[,4] > 0))[2,2]/sum(plyr::count(as.numeric(final_table[,4] > 0))[,2]), mean(final_table[,4]), sd(final_table[,4]))
  ); colnames(final_table_stats) <- c("ActionFreq", "Mean", "SD"); final_table_stats <- round(final_table_stats, 2)
  
  # Printing results
  return(list(
    interaction.based.Learning = paste0("Interaction-based Learning: Tomorrow this stock goes up with probability: ", round(interaction.based.probability, 2)),
    Raw.Buy.Sell.Signal.Table = data.frame(reduced_table[, -1],
    Buy.Sell.Signal.Table = knitr::kable(reduced_table[, -1]),
    Statistics = knitr::kable(final_table_stats),
    Comment = paste0(
      "We recommend buy frequency to be less than ", final_table_stats[1,1],
      " for the first entry. Moreover, the expectation of buy signals is ", final_table_stats[1,2],
      " and the standard deviation is ", final_table_stats[1,3],
      ", respectively. Hence, we conclude: ", ifelse(reduced_table[nrow(reduced_table), 3] < final_table_stats[1,2], "Do nothing.", "Enter this stock."))
  ))
} # End of function
