#' Parametric Bootstrap Mean Squared Error of EBLUP's for domain means using Geoadditive Small Area Model
#'
#' This function calculates MSE of EBLUP's based on unit level using Geoadditive Small Area Model
#'
#' @param formula the model that to be fitted
#' @param zspline n*k matrix that used in model for random effect of spline-2 (n is the number of observations, and k is the number of knots used)
#' @param dom a*1 vector with domain codes (a is the number of small areas)
#' @param xmean a*p matrix of auxiliary variables means for each domains (a is the number of small areas, and p is the number of auxiliary variables)
#' @param zmean a*k matrix of spline-2 means for each domains
#' @param data data unit level that used as data frame that containing the variables named in formula and dom
#' @param B the number of iteration bootstraping
#'
#' @return This function returns a list of the following objects:
#'    \item{est}{A list containing the following objects:}
#'      \itemize{
#'        \item eblup: A Vector with a list of EBLUP with Geoadditive Small Area Model
#'        \item fit: A list of components of the formed Geoadditive Small Area Model that containing the following objects such as model structure of the model, coefficients of the model, method, and residuals
#'        \item sigma2: Variance (sigma square) of random effect and error with Geoadditive Small Area Model
#'      }
#'    \item{mse}{A vector with a list of estimated mean squared error of EBLUPs estimators}
#'
#' @export pbmsegeo
#'
#' @examples
#' \donttest{
#' #Load the dataset for unit level
#' data(dataUnit)
#'
#' #Load the dataset for spline-2
#' data(zspline)
#'
#' #Load the dataset for area level
#' data(dataArea)
#'
#' #Construct data frame
#' y       <- dataUnit$y
#' x1      <- dataUnit$x1
#' x2      <- dataUnit$x2
#' x3      <- dataUnit$x3
#' formula <- y~x1+x2+x3
#' zspline <- as.matrix(zspline[,1:6])
#' dom     <- dataUnit$area
#' xmean   <- cbind(1,dataArea[,3:5])
#' zmean   <- dataArea[,7:12]
#' number  <- dataUnit$number
#' area    <- dataUnit$area
#' data    <- data.frame(number, area, y, x1, x2, x3)
#'
#' #Estimate MSE
#' mse_geosae <- pbmsegeo(formula,zspline,dom,xmean,zmean,data,B=100)
#' }

pbmsegeo<-function(formula, zspline, dom, xmean, zmean, data, B=100)
{
  result <- list(est = NA, mse=NA)
  namedom<-deparse(substitute(dom))
  if (!missing(data)) {
    formuladata <- model.frame(formula, na.action = na.omit,data)
    X <- model.matrix(formula, data)
    dom <- data[,"area"]
  }
  else {
    formuladata <- model.frame(formula, na.action = na.omit)
    X <- model.matrix(formula)
  }

  if (is.factor(dom))
    dom <- as.vector(dom)
  if (sum(c(nrow(formuladata) != length(dom)) , (nrow(formuladata) != nrow(zspline)))!=0)
    stop("   Arguments formula [rows=", nrow(formuladata),
         "] , dom [rows=", length(dom), "] and zmatrix [rows=", nrow(zspline), "] must be the same length.\n")

  y <- formuladata[, 1]
  z <- zspline

  result$est<-eblupgeo(y~x1+x2+x3, zspline, dom, xmean, zmean, data)

  udom<-unique(dom)
  m<-length(udom)
  k<-ncol(z)
  n<-length(y)
  D<-matrix(0,nrow=n,ncol=m)
  for(i in 1:n){
    domain<-	dom[i]
    D[i,]<-rep(c(0,1,0),c(domain-1,1,m-domain))
  }

  beta<-result$est$fit$coefficients$fixed
  sigma2.gamma<-result$est$sigma2[1]
  sigma2.u<-result$est$sigma2[2]
  sigma2.e<-result$est$sigma2[3]

  cat("\nBootstrap procedure with B =", B, "iterations starts.\n")
  summse.pb<-NULL
  error<-NULL
  b<-1
  while(b<=B){
    u.boot <- rnorm(m,0,sqrt(sigma2.u))
    gamma.boot <- rnorm(k, 0, sqrt(sigma2.gamma))
    e.boot <- rnorm(n, 0, sqrt(sigma2.e))
    ebar.boot<-aggregate(e.boot,list(dom),mean)[,2]
    theta.boot <- as.matrix(xmean) %*% as.vector(beta) + as.matrix(zmean) %*% as.vector(gamma.boot) + u.boot+ebar.boot
    y_ij.boot <- as.matrix(X) %*% as.vector(beta) + as.matrix(z) %*% as.vector(gamma.boot) + D %*% u.boot + e.boot
    model.boot <- eblupgeo(y_ij.boot~ x1+x2+x3 , z, dom, xmean, zmean, data)
    selisih<-(model.boot$eblup - theta.boot)^2
    error<-rbind(error,t(selisih))
    b=b+1
  }
  result$mse<-colMeans(error, na.rm=T)
  return(result)
}
