library(openxlsx)
library(micEconCES)

###############################################################################
###             Cobb - Douglas                                              ###
###############################################################################

# Wczytanie danych
dane_CD <- read.xlsx("dane_12.xlsx")

# Logarytmowanie zmiennych numerycznych
ln_dane_CD <- log(dane_CD[, c("rgdpna", "rnna", "emp")])

# Budowa macierzy X i wektora lnQ (CD)
ones_CD <- matrix(1, nrow(dane_CD), 1)
X_CD    <- cbind(ones_CD, ln_dane_CD$rnna, ln_dane_CD$emp)
lnQ_CD  <- cbind(ln_dane_CD$rgdpna)

# Estymacja MNK: b = (X'X)^-1 X'y
bmnk_CD <- solve(t(X_CD) %*% X_CD) %*% t(X_CD) %*% lnQ_CD

# Wielkość produkcji przy jednostkowych nakładach
Q1_CD <- exp(bmnk_CD[1, ])

# Reszty, wariancja i macierz kowariancji
eps_hat_CD        <- lnQ_CD - X_CD %*% bmnk_CD
SKR_CD            <- t(eps_hat_CD) %*% eps_hat_CD
s2_CD             <- SKR_CD / (nrow(dane_CD) - nrow(bmnk_CD))
MacKow_CD         <- as.vector(s2_CD) * solve(t(X_CD) %*% X_CD)
bledy_szacunku_CD <- as.matrix(sqrt(diag(MacKow_CD)))

# Testowanie istotności parametrów
iloraz_t_CD <- bmnk_CD / bledy_szacunku_CD
p_value_CD  <- 2 * (1 - pt(abs(iloraz_t_CD), nrow(dane_CD) - nrow(bmnk_CD)))

# Przedziały ufności dla parametrów
alfa_CD           <- 0.05
wart_kryt_0975_CD <- qt(1 - alfa_CD / 2, nrow(X_CD) - ncol(X_CD))
L_ci_CD           <- bmnk_CD - bledy_szacunku_CD * wart_kryt_0975_CD
P_CD              <- bmnk_CD + bledy_szacunku_CD * wart_kryt_0975_CD

# Estymacja CD za pomocą lm()
fCD_CD <- lm(rgdpna ~ rnna + emp, data = ln_dane_CD)
summary(fCD_CD)

# Produkty krańcowe dla wszystkich obserwacji
MP_rnna_CD <- data.matrix(bmnk_CD[2] * dane_CD$rgdpna / dane_CD$rnna)
MP_emp_CD  <- data.matrix(bmnk_CD[3] * dane_CD$rgdpna / dane_CD$emp)

# Produkty krańcowe dla przeciętnych wartości nakładów
MP_rnna_me_CD <- bmnk_CD[2] * mean(dane_CD$rgdpna) / mean(dane_CD$rnna)
MP_emp_me_CD  <- bmnk_CD[3] * mean(dane_CD$rgdpna) / mean(dane_CD$emp)

# Techniczna stopa substytucji
TRS_rnnaemp_CD    <- MP_rnna_CD / MP_emp_CD
TRS_rnnaemp_me_CD <- MP_rnna_me_CD / MP_emp_me_CD

# Test efektu skali: H0: RTS = 1 vs H1: RTS ≠ 1
c_RTS_CD   <- rbind(0, 1, 1)
RTS_hat_CD <- t(c_RTS_CD) %*% bmnk_CD
D_RTS_CD   <- sqrt(t(c_RTS_CD) %*% MacKow_CD %*% c_RTS_CD)
t_RTS_CD       <- (RTS_hat_CD - 1) / D_RTS_CD
p.value_RTS_CD <- 2 * (1 - pt(abs(t_RTS_CD), nrow(X_CD) - ncol(X_CD)))

# Test TRS: H0: TRS = 40 vs H1: TRS ≠ 40
TRS_star_CD      <- 40
c_TRS_rnnaemp_CD <- rbind(0, mean(dane_CD$emp), -mean(dane_CD$rnna) * TRS_star_CD)

D_TRS_rnnaemp_CD       <- sqrt(t(c_TRS_rnnaemp_CD) %*% MacKow_CD %*% c_TRS_rnnaemp_CD)
TRS_rnnaemp_hat_CD     <- t(c_TRS_rnnaemp_CD) %*% bmnk_CD
t_TRS_rnnaemp_CD       <- TRS_rnnaemp_hat_CD / D_TRS_rnnaemp_CD
p.value_TRS_rnnaemp_CD <- 2 * (1 - pt(abs(t_TRS_rnnaemp_CD), nrow(X_CD) - ncol(X_CD)))

# Efektywność techniczna metodą COLS
eps_hat_vec_CD <- as.vector(eps_hat_CD)
u_hat_CD       <- max(eps_hat_vec_CD) - eps_hat_vec_CD
TE_cols_CD     <- exp(-u_hat_CD)

dane_CD$TE_cols_CD <- TE_cols_CD

mean(TE_cols_CD)
aggregate(TE_cols_CD ~ dane_CD$iso3, FUN = mean)

# Podsumowanie podstawowych wyników w konsoli
cat("Elastyczność względem rnna (β_K) =", bmnk_CD[2], "\n")
cat("Elastyczność względem emp  (β_L) =", bmnk_CD[3], "\n")
cat("RTS = β_K + β_L                 =", bmnk_CD[2] + bmnk_CD[3], "\n")
cat("MP_rnna (śr.)                   =", mean(MP_rnna_CD), "\n")
cat("MP_emp  (śr.)                   =", mean(MP_emp_CD),  "\n")
cat("TRS_rnnaemp (śr.)               =", mean(TRS_rnnaemp_CD), "\n")
cat("TE_cols_CD (śr.)                =", mean(TE_cols_CD), "\n")


###############################################################################
###             CES                                                         ###
###############################################################################

# Wczytanie danych
dane_CES <- read.xlsx("dane_12.xlsx")

# Logarytmowanie zmiennych (przydatne do startu CES)
ln_dane_CES <- data.frame(
  ln_rgdpna_CES = log(dane_CES$rgdpna),
  ln_rnna_CES   = log(dane_CES$rnna),
  ln_emp_CES    = log(dane_CES$emp)
)

# Przygotowanie zmiennych pomocniczych do startu (Kmenta)
X_CES <- as.matrix(dane_CES[, c("rnna", "emp")])

z1_CES <- log(X_CES[, 1])
z2_CES <- log(X_CES[, 2])
z3_CES <- -0.5 * (z1_CES - z2_CES)^2

ones_CES <- matrix(1, nrow(dane_CES), 1)
Z_CES    <- cbind(ones_CES, z1_CES, z2_CES, z3_CES)
lnQ_CES  <- log(dane_CES$rgdpna)

# Estymacja MNK do wartości startowych CES
bMNK_CES <- solve(t(Z_CES) %*% Z_CES) %*% t(Z_CES) %*% lnQ_CES

resK_CES  <- lnQ_CES - Z_CES %*% bMNK_CES
sig2K_CES <- as.numeric(t(resK_CES) %*% resK_CES / (nrow(X_CES) - 4))

gamK_CES   <- exp(bMNK_CES[1])
deltaK_CES <- bMNK_CES[2] / (bMNK_CES[2] + bMNK_CES[3])
nuK_CES    <- bMNK_CES[2] + bMNK_CES[3]
rhoK_CES   <- bMNK_CES[4] * (bMNK_CES[2] + bMNK_CES[3]) / (bMNK_CES[2] * bMNK_CES[3])

# Klampowanie wartości startowych do sensownego zakresu
gamK_CES   <- max(gamK_CES, 1e-6)
deltaK_CES <- min(max(deltaK_CES, 0.01), 0.99)
rhoK_CES   <- min(max(rhoK_CES, -0.9), 10)
nuK_CES    <- max(nuK_CES, 0.01)

cat("Start CES: gamma =", gamK_CES, "delta =", deltaK_CES,
    "rho =", rhoK_CES, "nu =", nuK_CES, "\n")

# Estymacja CES: VRS, błąd multiplikatywny
CES_vrs_CES <- cesEst("rgdpna",
                      cbind("rnna", "emp"),
                      data    = dane_CES,
                      vrs     = TRUE,
                      method  = "Newton",
                      multErr = TRUE)
summary(CES_vrs_CES)

# Estymacja CES: VRS, błąd addytywny
CES_vrs_add_err_CES <- cesEst("rgdpna",
                              cbind("rnna", "emp"),
                              data    = dane_CES,
                              vrs     = TRUE,
                              method  = "Newton",
                              multErr = FALSE)
summary(CES_vrs_add_err_CES)

# Estymacja CES: CRS, błąd multiplikatywny
CES_crs_CES <- cesEst("rgdpna",
                      cbind("rnna", "emp"),
                      data    = dane_CES,
                      vrs     = FALSE,
                      method  = "Newton",
                      multErr = TRUE)
summary(CES_crs_CES)

# Wyznaczenie parametrów CES (model VRS, multErr = TRUE)
parametry_CES <- as.numeric(CES_vrs_CES$coefficients)

gamma1_CES <- parametry_CES[1]
delta1_CES <- parametry_CES[2]
rho1_CES   <- parametry_CES[3]
nu1_CES    <- parametry_CES[4]

# Elastyczność produkcji względem rnna (K)
El_rnna_CES <- as.matrix(
  nu1_CES * delta1_CES * X_CES[, 1]^(-rho1_CES) /
    (delta1_CES * X_CES[, 1]^(-rho1_CES) + (1 - delta1_CES) * X_CES[, 2]^(-rho1_CES))
)

# Elastyczność produkcji względem emp (L)
El_emp_CES <- as.matrix(
  nu1_CES * (1 - delta1_CES) * X_CES[, 2]^(-rho1_CES) /
    (delta1_CES * X_CES[, 1]^(-rho1_CES) + (1 - delta1_CES) * X_CES[, 2]^(-rho1_CES))
)

# Produkty krańcowe CES
MP_rnna_CES <- dane_CES$rgdpna / dane_CES$rnna * El_rnna_CES
MP_emp_CES  <- dane_CES$rgdpna / dane_CES$emp  * El_emp_CES

# Techniczna stopa substytucji CES (K / L)
TRS_rnnaemp_CES <- MP_rnna_CES / MP_emp_CES

# Elastyczność substytucji CES
El_subst_CES <- 1 / (1 + rho1_CES)

# Efektywność techniczna CES (COLS na resztach logarytmicznych)
eps_CES <- residuals(CES_vrs_CES)
eps_vec_CES <- as.vector(eps_CES)

u_hat_CES <- max(eps_vec_CES) - eps_vec_CES
TE_CES    <- exp(-u_hat_CES)

dane_CES$TE_CES <- TE_CES

# Test efektu skali CES: H0: nu = 1 (CRS) vs H1: nu ≠ 1
vcov_CES  <- vcov(CES_vrs_CES)
nu_se_CES <- sqrt(vcov_CES["nu", "nu"])
RTS_hat_CES    <- nu1_CES
t_RTS_CES      <- (nu1_CES - 1) / nu_se_CES
p.value_RTS_CES <- 2 * (1 - pt(abs(t_RTS_CES), nrow(dane_CES) - length(parametry_CES)))

# Podsumowanie podstawowych wyników w konsoli
cat("El_rnna_CES (śr.)    =", mean(El_rnna_CES),      "\n")
cat("El_emp_CES  (śr.)    =", mean(El_emp_CES),       "\n")
cat("MP_rnna_CES (śr.)    =", mean(MP_rnna_CES),      "\n")
cat("MP_emp_CES  (śr.)    =", mean(MP_emp_CES),       "\n")
cat("TRS_rnnaemp_CES (śr.)=", mean(TRS_rnnaemp_CES),  "\n")
cat("El_subst_CES         =", El_subst_CES,           "\n")
cat("TE_CES (śr.)         =", mean(TE_CES),           "\n")
cat("RTS_CES (nu)         =", RTS_hat_CES,    "\n")
cat("t_RTS_CES            =", t_RTS_CES,      "\n")
cat("p.value_RTS_CES      =", p.value_RTS_CES,"\n")

###############################################################################
###             Translog                                                    ###
###############################################################################


gdp.data = read.xlsx("dane_12.xlsx")

lnGDP   <- log(gdp.data$rgdpna)
ones    <- matrix(1, nrow(gdp.data), 1)
lnL     <- log(gdp.data$emp)
lnK     <- log(gdp.data$rnna)

X_T = cbind(ones,
            lnL,
            lnK,
            lnL * lnK,
            lnL^2,
            lnK^2)

zeros_T = matrix(0, nrow(X_T), 1)

bMNK_T = solve(t(X_T) %*% X_T) %*% t(X_T) %*% lnGDP

res_T = lnGDP - X_T %*% bMNK_T

sig2_T = t(res_T) %*% res_T / (nrow(X_T) - ncol(X_T))

MatKow_T = as.vector(sig2_T) * solve(t(X_T) %*% X_T)

###### Elastycznosc produkcji wzgledem L ######
#lnQ = beta1 + beta2*lnL + beta3*lnK + beta4*lnL*lnK + beta5*lnL^2 + beta6*lnK^2
###### ElL = beta2 + beta4*lnK + 2*beta5*lnL ######

c_L_T    = cbind(zeros_T, ones, zeros_T, lnK, 2*lnL, zeros_T)
c_L_me_T = cbind(0, 1, 0,  mean(lnK), 2*mean(lnL), 0)

El_L_T    = c_L_T %*% bMNK_T
El_L_me_T = c_L_me_T %*% bMNK_T
D_El_L_T  = sqrt(c_L_me_T %*% MatKow_T %*% t(c_L_me_T))

###### Elastyczność wzgledem kapitału ######
###### El_K = beta3 + beta4*lnL + 2*beta6*lnK ######
c_K_T    = cbind(zeros_T, zeros_T, ones,  lnL, zeros_T, 2*lnK)
c_K_me_T = cbind(0, 0, 1,  mean(lnL), 0, 2*mean(lnK))

El_K_T    = c_K_T %*% bMNK_T
El_K_me_T = c_K_me_T %*% bMNK_T
D_El_K_T  = sqrt(c_K_me_T %*% MatKow_T %*% t(c_K_me_T))

###### Drugie pochodne cząstkowe - test czy zachodzi prawo malejącej użyteczności ######

deriv2_L_T = mean(gdp.data$rgdpna) / mean(gdp.data$emp)^2 *
  (2 * bMNK_T[5] + El_L_me_T * (El_L_me_T - 1))

deriv2_K_T = mean(gdp.data$rgdpna) / mean(gdp.data$rnna)^2 *
  (2 * bMNK_T[6] + El_K_me_T * (El_K_me_T - 1))

show(deriv2_L_T)
show(deriv2_K_T)

###### Współczynnik efektu skali ######

c_RTS_T    = c_L_T + c_K_T
RTS_T      = c_RTS_T %*% bMNK_T
c_RTS_me_T = c_L_me_T + c_K_me_T
RTS_me_T   = c_RTS_me_T %*% bMNK_T

###### Produkty krańcowe ######

MP_L_T   = El_L_T   * gdp.data$rgdpna / gdp.data$emp
MP_K_T   = El_K_T   * gdp.data$rgdpna / gdp.data$rnna

MP_L_me_T   = El_L_me_T   * mean(gdp.data$rgdpna) / mean(gdp.data$emp)
MP_K_me_T   = El_K_me_T   * mean(gdp.data$rgdpna) / mean(gdp.data$rnna)

###### Techniczna stopa substytucji ######

TRS_LK_T   = MP_L_me_T / MP_K_me_T

###### Test czy zasadny jest model TL ######

# H0: CD vs H1: TL

SKR_TL = t(res_T) %*% res_T

X1_T  = cbind(ones, lnL, lnK)
k2_T  = ncol(X_T) - ncol(X1_T)

bMNK1_T = solve(t(X1_T) %*% X1_T) %*% t(X1_T) %*% lnGDP

res1_T   = lnGDP - X1_T %*% bMNK1_T
SKR_CD = t(res1_T) %*% res1_T

F_emp_T     = ((SKR_CD - SKR_TL) / k2_T) / (SKR_TL / (nrow(X_T) - ncol(X_T)))
p_value_F_T = pf(F_emp_T, k2_T, nrow(X_T) - ncol(X_T), lower.tail = FALSE)

###### Drugie pochodne - mieszane ######

deriv2_KL_T    = as.numeric(exp(lnGDP)/(exp(lnK)*exp(lnL))*(bMNK_T[4] + El_K_me_T*El_L_me_T))
deriv2_KL_me_T = mean(gdp.data$rgdpna) / (mean(gdp.data$rnna) * mean(gdp.data$emp)) *
  (bMNK_T[4] + El_K_me_T * El_L_me_T)

###### Hesjan ######

BHess_T = rbind(
  cbind(0,                     as.numeric(MP_L_me_T),    as.numeric(MP_K_me_T)),
  cbind(as.numeric(MP_L_me_T), as.numeric(deriv2_L_T),     deriv2_KL_me_T),
  cbind(as.numeric(MP_K_me_T), deriv2_KL_me_T,             as.numeric(deriv2_K_T))
)
Det_BHess_T = det(BHess_T)

###### AES ######

F_LK_T = (-1)^(2+3) * det(BHess_T[-2, -3])

sum_xf_T = as.numeric(MP_L_me_T) * mean(gdp.data$emp) + as.numeric(MP_K_me_T) * mean(gdp.data$rnna)

AES_LK_T   = sum_xf_T / (mean(gdp.data$emp) * mean(gdp.data$rnna)) * (F_LK_T / Det_BHess_T)

###### Efektywność techniczna ######
eps_hat_T = as.vector(res_T)
eps_max_T = max(eps_hat_T)
u_hat_T   = eps_max_T - eps_hat_T
TE_T      = exp(-u_hat_T)
TE_me_T = mean(TE_T)

m2_T = sum(eps_hat_T^2)/length(eps_hat_T)
m3_T = sum(eps_hat_T^3)/length(eps_hat_T)
sig2u_T = (pi/2)^(1/3)*(pi*m3_T/(pi-4))^(2/3) 
sig2v_T = m2_T - ((pi-2)/pi)*sig2u_T
mu_s_T = (-1)*eps_hat_T*sig2u_T/(sig2u_T+sig2v_T)
sig2s_T = sig2u_T*sig2v_T/(sig2u_T+sig2v_T)
sigs_T = sqrt(sig2s_T)

ineff_T = mu_s_T + sigs_T*(dnorm(mu_s_T/sigs_T)/pnorm(mu_s_T/sigs_T))
TE_approx_T = exp(-ineff_T)
eff_T = exp(sig2s_T/2-mu_s_T)*(pnorm(mu_s_T/sigs_T - sigs_T)/pnorm(mu_s_T/sigs_T))
mean(eff_T)

###### Kompilacja wyników ######

# Elastyczności:
# Względem nakładu pracy
El_L_me_T
# Względem kapitału
El_K_me_T

# Efekt skali:
RTS_me_T

# Produkty krańcowe:
MP_L_me_T
MP_K_me_T

# Techniczna stopa substytucji
TRS_LK_T

# P-value testu istotności rozszerzenia modelu
p_value_F_T

# Wyznacznik Hesjanu
Det_BHess_T

# Elastyczność substytucji Allena
AES_LK_T

# Efektywność techniczna
mean(eff_T)