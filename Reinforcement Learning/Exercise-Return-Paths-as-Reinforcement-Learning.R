######################### BEGIN SCRIPT #################################

######################## DEFINE FUNCTIONS ##############################

# Buy table;
Buy.table<-function(x,r_day_plot,end_day_plot,c,height,past.n.days,test.new.price = 0){
  if (test.new.price == 0) {
    x = x
  } else {
    intra.day.test <- matrix(c(0,0,0,test.new.price,0,0), nrow = 1)
    rownames(intra.day.test) <- as.character(Sys.Date())
    x = data.frame(rbind(x, intra.day.test))
  }
  Close<-x[,4] # Define Close as adjusted closing price
  # A new function needs redefine data from above:
  # Create SMA for multiple periods
  SMA10<-SMA(Close,n=10)
  SMA20<-SMA(Close,n=20)
  SMA30<-SMA(Close,n=30)
  SMA50<-SMA(Close,n=50)
  SMA200<-SMA(Close,n=200)
  SMA250<-SMA(Close,n=250)
  
  # Create RSI for multiple periods
  RSI10 <- (RSI(Close,n=10)-50)*height*5
  RSI20 <- (RSI(Close,n=20)-50)*height*5
  RSI30 <- (RSI(Close,n=30)-50)*height*5
  RSI50 <- (RSI(Close,n=50)-50)*height*5
  RSI200 <- (RSI(Close,n=200)-50)*height*5
  RSI250 <- (RSI(Close,n=250)-50)*height*5
  
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
  coef<-c
  m<-height*mean(Close)
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
  
  all_data_signal <- cbind.data.frame(Close, all_data_ratio$Signal)
  
  return(
    #tail(all_data_signal)
    all_data_signal[(nrow(all_data_signal)-past.n.days):nrow(all_data_signal),]
  )
} # End of function # End of function # End of function
# End of function

#x=SPY; r_day_plot=.8; end_day_plot=1; c=-1.2; height=.1; past.n.days=2; test.new.price=0
#Buy.table(SPY,.8,1,-1.2,.1,2,0)

# Sell table;
Sell.table<-function(x,r_day_plot,end_day_plot,c,height,past.n.days,test.new.price = 0){
  if (test.new.price == 0) {
    x = x
  } else {
    intra.day.test <- matrix(c(0,0,0,test.new.price,0,0), nrow = 1)
    rownames(intra.day.test) <- as.character(Sys.Date())
    x = data.frame(rbind(x, intra.day.test))
  }
  Close<-x[,4] # Define Close as adjusted closing price
  # A new function needs redefine data from above:
  # Create SMA for multiple periods
  SMA10<-SMA(Close,n=10)
  SMA20<-SMA(Close,n=20)
  SMA30<-SMA(Close,n=30)
  SMA50<-SMA(Close,n=50)
  SMA200<-SMA(Close,n=200)
  SMA250<-SMA(Close,n=250)
  
  # Create RSI for multiple periods
  RSI10 <- (RSI(Close,n=10)-50)*height*5
  RSI20 <- (RSI(Close,n=20)-50)*height*5
  RSI30 <- (RSI(Close,n=30)-50)*height*5
  RSI50 <- (RSI(Close,n=50)-50)*height*5
  RSI200 <- (RSI(Close,n=200)-50)*height*5
  RSI250 <- (RSI(Close,n=250)-50)*height*5
  
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
  coef<-c
  m<-height*mean(Close)
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
  
  all_data_signal <- cbind.data.frame(Close, all_data_ratio$Signal)
  
  return(
    #tail(all_data_signal)
    all_data_signal[(nrow(all_data_signal)-past.n.days):nrow(all_data_signal),]
  )
} # End of function # End of function # End of function
# End of function

# Buy/Sell Algorithm:
BS.Algo <- function(x,r_day_plot,end_day_plot,c.buy,c.sell,height,past.n.days,test.new.price=0) {
  buy.sell.table <- data.frame(cbind(
    rownames(Buy.table(x,r_day_plot,end_day_plot,c.buy,height,past.n.days)),
    Buy.table(x,r_day_plot,end_day_plot,c.buy,height,past.n.days,test.new.price)[,1:2],
    Sell.table(x,r_day_plot,end_day_plot,c.sell,height,past.n.days,test.new.price)[,2]
  ))
  colnames(buy.sell.table) <- c("Date", "Ticker", "Buy.Signal", "Sell.Signal")
  buy.sell.table
} # End of function

########################### ANIMATION ################################

# Library
library(quantmod); library(animation)

# Write GIF
saveGIF({
  # Loop to create animation
  for (month in as.character(rep(1:12))) {
    # Data
    getSymbols("AAPL", to = paste0("2018-",month,"-01"))
    head(AAPL); tail(AAPL)
    data <- BS.Algo(
      x = AAPL,
      r_day_plot = 0.5,
      end_day_plot = 1,
      c.buy = -2,
      c.sell = 3,
      height = 0.005,
      past.n.days = 3*200,
      test.new.price = 0)
    temp <- data[, -1]; colnames(temp) <- c("Close","BuySignal","SellSignal")
    
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
    dateWindow <- c(Sys.Date()-3*200, Sys.Date())
    plot(temp$Close, type="l", col="blue", ylim=c(0,1000), 
         ylab = "Value", xlab = "Number of days after reinforced training",
         main=paste0("Yin's RL Stategy (Green) vs. Investing in Target Stock (Blue)")); 
    lines(temp$Value, type="l", col="green")
  } # Finished RL Algorithm
}, movie.name = paste0("2018-",month,"-01-BM-style", ".gif"),
interval = 0.8, nmax = 30, 
ani.width = 600)

######################### END SCRIPT ###############################