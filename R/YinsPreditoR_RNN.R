#' @title Predicts Stock Price Movement Using Recurrent Neural Network RNN for Given Stock Symbol
#' @description This package predicts whether the stock price at tommorow's market close would be higher or lower compared to today's closing place.
#' @param symbol
#' @return NULL
#' @examples  yins_predictor_rnn('AAPL')
#' @export
#'
#' # Define function
yins_predictor_rnn(
  symbol = "NFLX",
  cutoff = 0.3
) {
  
  # Library
  library(keras)
  library(quantmod)
  
  # Data Preparation -----------------------------------------------------------------
  
  # Download ticker
  #symbol <- "NFLX"
  
  # Importing price data for the given symbol
  data <- data.frame(xts::as.xts(get(quantmod::getSymbols(symbol))))
  
  # Assighning the column names
  colnames(data) <- c("data.Open","data.High","data.Low","data.Close","data.Volume","data.Adjusted")
  
  # Creating lag and lead features of price column.
  data <- xts::xts(data,order.by=as.Date(rownames(data)))
  data <- as.data.frame(merge(data, lm1=stats::lag(data[,'data.Adjusted'],
                                                   c(1:59,65,70,75,80,85,90,95,100,
                                                     120,150,200,250,300)))); 
  # Extracting features from Date
  data$Date<-as.Date(rownames(data))
  data$Day_of_month<-as.integer(format(as.Date(data$Date),"%d"))
  data$Month_of_year<-as.integer(format(as.Date(data$Date),"%m"))
  data$Year<-as.integer(format(as.Date(data$Date),"%y"))
  
  # Naming variables for reference
  today <- 'data.Adjusted'
  tommorow <- 'data.Adjusted.5'
  
  # Creating outcome
  data$up_down <- as.factor(ifelse(data[,tommorow] > data[,today], 1, 0)); 
  all <- data; all <- data.frame(na.omit(all)); 
  all <- data.frame(all$up_down, all[, -ncol(all)]); all <- all[, -which(colnames(all) == "Date")]
  colnames(all)[1] <- "label"
  head(all); dim(all)
  
  # Training parameters.
  batch_size <- 32
  plyr::count(all[,1])
  num_classes <- nrow(plyr::count(all[,1])); num_classes
  epochs <- 30
  
  # Embedding dimensions.
  row_hidden <- 128
  col_hidden <- 128
  
  # The data, shuffled and split between train and test sets
  #cutoff <- 0.3
  all <- as.matrix(all)
  index <- 1:(cutoff*nrow(all))
  x_train <- all[index, -1]
  y_train <- all[index, 1]
  x_test <- all[-index, -1]
  y_test <- all[-index, 1]; y_test_backup <- y_test
  dim(x_train); dim(y_train); dim(x_test); dim(y_test)
  
  # Reshapes data to 4D for Hierarchical RNN.
  x_train <- array_reshape(x_train, c(nrow(x_train), 9, 9, 1))
  x_test <- array_reshape(x_test, c(nrow(x_test), 9, 9, 1))
  dim(x_train); dim(y_train); dim(x_test); dim(y_test)
  
  dim_x_train <- dim(x_train)
  cat('x_train_shape:', dim_x_train)
  cat(nrow(x_train), 'train samples')
  cat(nrow(x_test), 'test samples')
  
  # Converts class vectors to binary class matrices
  y_train <- to_categorical(y_train, num_classes)
  y_test <- to_categorical(y_test, num_classes)
  
  # Define input dimensions
  row <- dim_x_train[[2]]
  col <- dim_x_train[[3]]
  pixel <- dim_x_train[[4]]
  
  # Model input (4D)
  input <- layer_input(shape = c(row, col, pixel))
  
  # Encodes a row of pixels using TimeDistributed Wrapper
  encoded_rows <- input %>% time_distributed(layer_lstm(units = row_hidden))
  
  # Encodes columns of encoded rows
  encoded_columns <- encoded_rows %>% layer_lstm(units = col_hidden)
  
  # Model output
  prediction <- encoded_columns %>%
    layer_dense(units = num_classes, activation = 'softmax')
  
  # Define Model ------------------------------------------------------------------------
  
  model <- keras_model(input, prediction)
  model %>% compile(
    loss = 'categorical_crossentropy',
    optimizer = 'rmsprop',
    metrics = c('accuracy')
  )
  
  # Training
  model %>% fit(
    x_train, y_train,
    batch_size = batch_size,
    epochs = epochs,
    verbose = 1,
    validation_data = list(x_test, y_test)
  )
  
  # Evaluation
  scores <- model %>% evaluate(x_test, y_test, verbose = 1)
  cat('Test loss:', scores[[1]], '\n')
  cat('Test accuracy:', scores[[2]], '\n')
  
  # Prediction
  predictions <- model %>% predict(x_test)
  head(predictions); which.max(predictions[1, ])
  y_hat <- apply(predictions, 1, which.max) - 1L
  y_test <- y_test_backup
  confusion.matrix <- table(y_hat, y_test); confusion.matrix
  test.acc <- sum(diag(confusion.matrix))/sum(confusion.matrix)
  
  # Comment
  print(paste0("The data has ", nrow(all), " total number of days. ", 
               "The algo used the first ", length(index), " days as training and the rest as test. ",
               "The test set accuracy is ", round(test.acc, 3), ". ",
               "The next trading day we expect ",
               symbol, " to go up with probability ", 
               round(tail(predictions)[6,2], 3), "."))
}