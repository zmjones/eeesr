pkgs <- c("stringr", "lubridate", "plyr")
invisible(lapply(pkgs, function(x) if(!is.element(x, installed.packages()[, 1]))
                 install.packages(x, repos = c(CRAN = "http://cran.rstudio.com"))))
invisible(lapply(pkgs, require, character.only = TRUE))
options(stringsAsFactors = FALSE)

createColumns <- function(x, head) {
  if (is.data.frame(x)) {
    head <- colnames(x)
    if (ncol(x) == 1)
      x <- x[, 1]
  }
  type <- str_extract(x, "[a-zA-Z]+$")
  type <- ifelse(type == "1", "one", type) #I think there is only one instance of this
  atypes <- unique(type[!is.na(type)])
  df <- vector(mode = "list", length(atypes))
  names(df) <- atypes
  for(i in seq_along(atypes)) {
    check.index <- 1
    check <- grepl(paste0(" ", atypes[i], "$"), x)
    for (j in seq_along(check)) {
      if (check[j] == TRUE) {
        df[[atypes[i]]][j] <- gsub(" [a-zA-Z]+$", "", x[check][check.index])
        check.index <- check.index + 1
      }
      else
        df[[atypes[i]]][j] <- NA
    }}
  if (length(unique(type)) == 1)
    df <- data.frame(df[[1]])
  else {
    df <- do.call("cbind", df)
    df <- data.frame(x, df)
    df$x <- ifelse(apply(df, 1, function(x) all(is.na(x[-1]))), x, NA)
    head <- gsub(" ", "_", head)
    head <- str_trim(unlist(str_split(head, ",")))
    head <- gsub("^_", "", head)
    dupes <- !(grepl("\\)$", head)) #looking for multiple reference categories
    if (sum(dupes) > 1)
      head <- c(paste0(head[which(dupes)], collapse = "/"), head[-c(which(dupes))])
    head.types <- gsub("\\(|\\)", "", str_extract(head, "\\([a-zA-Z]?{2}\\)$"))
    head.types <- sapply(head.types, function(x) x %in% colnames(df) | is.na(x))
    head <- head[head.types]
    head.types <- names(head.types[head.types == TRUE])
  }
  is.ref <- grepl("\\([a-zA-Z]?{2}\\)$", head)
  if (any(!is.ref)) {
    ref <- head[!is.ref]
    head <- head[c(match(colnames(df), head.types))]
    colnames(df) <- gsub("\\(.*\\)", "", tolower(head))
    colnames(df)[is.na(colnames(df))] <- ref
  }
  else
    colnames(df) <- gsub("\\(.*\\)", "", tolower(head))    
  df <- as.data.frame(df[, !(apply(df, 2, function(x) all(is.na(x))))])
  return(df)
}

expandColumns <- function(df) {
  date.df <- findDates(df)
  other.df <- data.frame(df[, !(colnames(df) %in% colnames(date.df))])
  has.type <- apply(date.df, 2, function(x) any(grepl("[a-zA-Z]+$", x)))
  date.nt.df <- data.frame(date.df[, !(has.type)])
  other.df <- data.frame(other.df, date.nt.df)
  temp <- colnames(date.df)[has.type]
  date.df <- data.frame(date.df[, has.type])
  if (ncol(date.df) != 0)
    colnames(date.df) <- temp
  colnames(other.df) <- colnames(df)[!(colnames(df) %in% colnames(date.df))]
  if (any(has.type) == FALSE) {
    colnames(other.df) <- gsub(".*\\(([^\\)]+)\\), ", "", colnames(other.df))
    df <- other.df
    date.df <- NULL
  }
  else if (!(is.null(date.df))) {
    if (ncol(date.df) > 1) {
      cols <- vector("list", ncol(date.df))
      for(i in 1:ncol(date.df))
        cols[[i]] <- createColumns(date.df[, i], colnames(date.df)[i])
      df <- data.frame(other.df, do.call("cbind", cols))
    }
    else
      df <- as.data.frame(cbind(other.df, createColumns(date.df, colnames(date.df))))
  }
  colnames(df) <- gsub("\\.", "_", tolower(colnames(df)))
  return(df)
}

loadData <- function(chap, treaty, expand = FALSE, panel = FALSE, ...) {
  df <- read.csv(paste0("./treaties/", chap, "-", treaty, ".csv"),
                 check.names = FALSE, na.string = "")
  if (expand == TRUE & panel == TRUE)
    df <- expandPanel(expandColumns(df), ...)
  else if (expand == TRUE & panel == FALSE)
    df <- expandColumns(df)
  else if (expand == FALSE & panel == TRUE)
    stop("column names must be expanded to use panel expansion.")
  return(df)
}

convertPanel <- function(x, pyear) {
  x <- gsub("Sept", "Sep", x) #date conversion expects 3 letter abbr
  x <- ifelse(year(dmy(x)) <= pyear, 1, 0)
  x[is.na(x)] <- 0
  return(x)
}

expandPanel <- function(df, syear, eyear) {
  df <- do.call("ddply", list(df, "participant", transform, 
                year = call("year", x = seq(ymd(paste0(syear, "-1-1")),
                ymd(paste0(eyear, "-1-1")), "year"))))
  date.df <- findDates(df)
  other.df <- df[, !(colnames(df) %in% colnames(date.df))]
  df <- data.frame(other.df, apply(date.df, 2, function(x) convertPanel(x, df$year)))
  return(df)
}

findDates <- function(df) {
  re.date <- "[0-9]?{2} [a-zA-Z]?{4} [0-9]{4}( [a-zA-Z]+)?$"
  test <- apply(df, 2, function(x) any(grepl(re.date, x)))
  date.df <- data.frame(df[, test])
  colnames(date.df) <- colnames(df)[test]
  return(date.df)
}
