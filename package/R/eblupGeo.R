#' EBLUP's for domain means using Geoadditive Small Area Model
#'
#' This function calculates EBLUP's based on unit level using Geoadditive Small Area Model
#'
#' @param formula the model that to be fitted
#' @param zspline n*k matrix that used in model for random effect of spline-2 (n is the number of observations, and k is the number of knots used)
#' @param dom a*1 vector with domain codes (a is the number of small areas)
#' @param xmean a*p matrix of auxiliary variables means for each domains (a is the number of small areas, and p is the number of auxiliary variables)
#' @param zmean a*k matrix of spline-2 means for each domains
#' @param data data unit level that used as data frame that containing the variables named in formula and dom
#'
#' @return This function returns a list of the following objects:
#'    \item{eblup}{A Vector with a list of EBLUP with Geoadditive Small Area Model}
#'    \item{fit}{A list of components of the formed Geoadditive Small Area Model that containing the following objects such as model structure of the model, coefficients of the model, method, and residuals}
#'    \item{sigma2}{Variance (sigma square) of random effect and error with Geoadditive Small Area Model}
#'
#' @export eblupgeo
#'
#' @examples
#' #Load the dataset for unit level
#' data(dataUnit)
#'
#' #Load the dataset for spline-2
#' data(zspline)
#'
#' #Load the dataset for area level
#' data(dataArea)
#'
#' #Construct the data frame
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
#' #Estimate EBLUP
#' eblup_geosae <- eblupgeo(formula, zspline, dom, xmean, zmean, data)
#'
#' @import stats
#' @import nlme
#' @import MASS

eblupgeo<- function (formula, zspline, dom, xmean, zmean, data)
{
  result <- list(eblup = NA, fit = NA)
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

  y   <- formuladata[, 1]
  x1  <- formuladata[, 2]
  x2  <- formuladata[, 3]
  x3  <- formuladata[, 4]
  z   <- zspline
  obs <- data$number

  ZBlock=pdBlocked(list(pdIdent(~zspline-1),pdIdent(~area-1)))
  dataMu=groupedData(y~1+x1+x2+x3|dom,data=data.frame(y,x1,x2,x3,z,obs))
  fit<-lme(fixed=y~x1+x2+x3, data=dataMu, random=ZBlock)
  result$fit<-fit

  beta<-fixed.effects(fit)
  udom<-unique(dom)
  m<-length(udom)
  n<-length(y)
  D<-matrix(0,nrow=n,ncol=m)
  for(i in 1:n){
    domain<-dom[i]
    D[i,]<-rep(c(0,1,0),c(domain-1,1,m-domain))
  }

  Dt<-t(D)
  zt<-t(z)
  In<-diag(1,n)

  sigma2.gamma<-as.numeric(VarCorr(fit)[1, 1])
  sigma2.u<-as.numeric(VarCorr(fit)[ncol(z)+1, 1])
  sigma2.e<-as.numeric(VarCorr(fit)[nrow(VarCorr(fit)),1])
  result$sigma2<-c(sigma2.gamma=sigma2.gamma,sigma2.u=sigma2.u,sigma2.e=sigma2.e )

  v<-sigma2.gamma*z%*%zt + sigma2.u*D%*%Dt + sigma2.e*In
  vi<-solve(v)

  gamma<-sigma2.gamma*zt%*%vi%*%(y-X%*%beta)
  u<-sigma2.u*Dt%*%vi%*%(y-X%*%beta)

  if (sum(c((nrow(xmean) != nrow(zmean)), (nrow(xmean)!= m)))!=0)
    stop("   Arguments xmean [rows=", nrow(xmean),
         "] , zmean [rows=", nrow(zmean), "] and area [rows=", m, "] must be the same length.\n")

  yihat<-as.matrix(xmean)%*% beta + as.matrix(zmean) %*% gamma + unique(u)

  result$eblup<-yihat
  return(result)
}
