
<!-- README.md is generated from README.Rmd. Please edit that file -->

# geoSAE

<!-- badges: start -->
<!-- badges: end -->

This function is an extension of the Small Area Estimation (SAE) model.
Geoadditive Small Area Model is a combination of the geoadditive model
with the Small Area Estimation (SAE) model, by adding geospatial
information to the SAE model.

## Authors

Ketut Karang Pradnyadika, Ika Yuni Wulansari

## Maintainer

Ketut Karang Pradnyadika <221709776@stis.ac.id>

## Installation

You can install the released version of geoSAE from
[CRAN](https://CRAN.R-project.org) or find my github repository
[Github](https://github.com/ketutdika)

## Example

``` r
#Load the dataset for unit level
library(geoSAE)
data(dataUnit)
#Load the dataset for spline-2
data(zspline)
#Load the dataset for area level
data(dataArea)
#Construct the data frame
y       <- dataUnit$y
x1      <- dataUnit$x1
x2      <- dataUnit$x2
x3      <- dataUnit$x3
formula <- y~x1+x2+x3
zspline <- as.matrix(zspline[,1:6])
dom     <- dataUnit$area
xmean   <- cbind(1,dataArea[,3:5])
zmean   <- dataArea[,7:12]
number  <- dataUnit$number
area    <- dataUnit$area
data    <- data.frame(number, area, y, x1, x2, x3)
#Estimate EBLUP
eblup_geosae <- eblupgeo(formula, zspline, dom, xmean, zmean, data)
eblup_geosae$eblup
#>           [,1]
#>  [1,] 29.04625
#>  [2,] 33.43651
#>  [3,] 34.66706
#>  [4,] 33.81857
#>  [5,] 23.52744
#>  [6,] 22.89752
#>  [7,] 21.86852
#>  [8,] 21.26004
#>  [9,] 33.73404
#> [10,] 38.43505
#> [11,] 33.77393
#> [12,] 28.98660
#> [13,] 32.29918
#> [14,] 24.31817
#> [15,] 31.23797
 
#Estimate MSE
mse_geosae <- pbmsegeo(formula,zspline,dom,xmean,zmean,data,B=100)
#> 
#> Bootstrap procedure with B = 100 iterations starts.
mse_geosae$mse
#>  [1]  2.052566  1.978709  2.231913 10.926587  1.480916  4.157471  3.172412
#>  [8]  1.839984  2.466619  1.563998  3.051762 16.937056 16.238457  2.648152
#> [15]  5.538344
 
## eblup_geosae$eblup        #to see the result of EBLUPs with Geoadditive Small Area Model each area
## mse_geosae$mse            #to see the result of MSE with Geoadditive Small Area Model each area
```

## References

-   Rao, J.N.K & Molina. (2015). Small Area Estimation 2nd Edition. New
    York: John Wiley and Sons, Inc.
-   Bocci, C., & Petrucci, A. (2016). Spatial information and
    geoadditive small area models. Analysis of poverty data by small
    area estimation, 245-259.
-   Ardiansyah, M., Djuraidah, A., & Kurnia, A. (2018). PENDUGAAN AREA
    KECIL DATA PRODUKTIVITAS TANAMAN PADI DENGAN GEOADDITIVE SMALL AREA
    MODEL. Jurnal Penelitian Pertanian Tanaman Pangan, 2(2), 101-110.
