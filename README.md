<div align="right">
  <a href="./README.md"><img src="https://img.shields.io/badge/English-Active-0A66C2?style=flat-square" alt="English"></a>
  <a href="./README.pl.md"><img src="https://img.shields.io/badge/Polski-Przelacz_jezyk-dc143c?style=flat-square" alt="Polski"></a>
</div>

# Technical Efficiency and GDP in European Economies
### An Empirical Study Based on Cobb-Douglas, CES, and Translog Production Functions

**Author:** Filip Gorczyca  
**Field of Study:** Economic Analytics, Krakow University of Economics (UEK)

---

## Project Overview
Empirical macroeconomic and econometric analysis evaluating how physical capital and labor supply determine real GDP and technical efficiency across **9 European economies** (**Belgium, Switzerland, Germany, Spain, France, United Kingdom, Italy, Netherlands, and Poland**) over the period **2000-2022**. 

The study compares three parametric production function specifications - **Cobb-Douglas (CD)**, **Constant Elasticity of Substitution (CES)**, and **Transcendental Logarithmic (Translog)** - to test returns to scale, factor complementarity vs. substitutability, and sensitivity of technical efficiency estimates to functional form restrictions.

---

## Dataset & Variables
* **Source:** Penn World Table (PWT) version 11.0 (panel data, 2000-2022).
* **Variables:**
  * `rgdpna` ($Q$ / $Y$) - Real GDP at constant 2021 national prices (in USD PPP).
  * `rnna` ($K$) - Capital stock at constant 2021 national prices (in USD PPP).
  * `emp` ($L$) - Number of persons engaged (in millions).

### Summary Statistics by Country (Mean and Min-Max Range)
| Country | Real GDP (trillion USD) | Employment (million) | Physical Capital (trillion USD) |
| :--- | :---: | :---: | :---: |
| **Germany (DEU)** | 4.51 (3.98 - 5.11) | 42.24 (39.52 - 45.84) | 18.08 (15.57 - 20.76) |
| **France (FRA)** | 3.12 (2.69 - 3.52) | 27.64 (25.97 - 30.29) | 17.87 (14.63 - 20.96) |
| **United Kingdom (GBR)** | 2.99 (2.48 - 3.49) | 30.16 (27.44 - 33.21) | 13.92 (11.02 - 16.89) |
| **Italy (ITA)** | 2.84 (2.62 - 3.00) | 24.67 (22.93 - 25.80) | 17.95 (14.99 - 19.80) |
| **Spain (ESP)** | 1.88 (1.55 - 2.13) | 19.16 (16.71 - 21.16) | 11.27 (8.24 - 13.30) |
| **Netherlands (NLD)** | 1.04 (0.89 - 1.26) | 8.96 (8.28 - 10.18) | 4.76 (3.89 - 5.61) |
| **Poland (POL)** | 1.04 (0.68 - 1.53) | 15.52 (13.58 - 17.78) | 2.50 (1.51 - 3.75) |
| **Switzerland (CHE)** | 0.65 (0.53 - 0.79) | 4.54 (3.94 - 5.14) | 2.99 (2.35 - 3.67) |
| **Belgium (BEL)** | 0.56 (0.47 - 0.67) | 4.52 (4.11 - 5.04) | 3.11 (2.40 - 3.89) |

---

## Econometric Methodology & R Implementation
The analytical script (`kod_R.R`) implements matrix-level estimation and post-estimation diagnostics:
1. **Cobb-Douglas Model:** Matrix OLS estimation $\hat{\beta} = (X^T X)^{-1} X^T Y$, variance-covariance matrix derivation, $t$-tests for Returns to Scale ($H_0: RTS = 1$) and Technical Rate of Substitution ($TRS$), and Corrected Ordinary Least Squares (COLS) technical efficiency.
2. **CES Model:** Kmenta translog approximation for starting values followed by non-linear Newton optimization (`micEconCES`), testing both multiplicative and additive error structures under Variable Returns to Scale (VRS) and Constant Returns to Scale (CRS).
3. **Translog Model:** Full second-order flexible specification with quadratic and interaction terms ($\ln L \cdot \ln K$, $\ln^2 L$, $\ln^2 K$), bordered Hessian determinant verification ($\det(BH) = 84.29 > 0$), Allen Elasticity of Substitution ($AES_{LK}$), nested $F$-test against Cobb-Douglas ($p = 2.91 \times 10^{-25}$), and skewness-based stochastic frontier technical efficiency.

---

## Empirical Results Comparison

| Parameter / Metric | Cobb-Douglas (CD) | CES (Multiplicative VRS) | Translog (Flexible) |
| :--- | :---: | :---: | :---: |
| **Labor Elasticity ($El_L$)** | 0.5354 | 0.5252 | 0.7003 |
| **Capital Elasticity ($El_K$)** | 0.4017 | 0.4127 | 0.2567 |
| **Returns to Scale ($RTS$)** | 0.9371 (Decreasing) | 0.9379 (Decreasing) | 0.9569 (Decreasing) |
| **Marginal Product of Labor ($MP_L$)** | 58,310.45 M USD | 56,899.71 M USD | 73,510.89 M USD |
| **Marginal Product of Capital ($MP_K$)** | 0.0900 M USD | 0.0908 M USD | 0.0517 M USD |
| **Elasticity of Substitution ($\sigma$ / $DES$ / $AES$)** | 1.0000 (Fixed) | 1.1996 (Substitutes) | 0.4410 (Complements) |
| **Mean Technical Efficiency ($TE$)** | 84.92% | 84.57% | 96.87% |

---

## Key Conclusions
1. **Superiority of the Flexible Translog Specification:** The $F$-test for model expansion ($p = 2.91 \times 10^{-25}$) rejects the restrictive Cobb-Douglas functional form in favor of the Translog model. Positive bordered Hessian determinant ($\det = 84.29$) confirms concavity and diminishing marginal returns.
2. **Factor Complementarity:** While restrictive two-factor models impose unit elasticity (CD: $\sigma = 1$) or mild substitutability (CES: $DES = 1.20$), the statistically superior Translog model reveals strong technological rigidity and complementarity between physical capital and labor ($AES = 0.44$).
3. **Technical Efficiency Sensitivity:** Imposing rigid functional forms understates structural efficiency (CD: 84.92%, CES: 84.57%), whereas accounting for non-linear interactions in the Translog model yields a mean technical efficiency of 96.87%.
4. **Dominance of Labor Elasticity & Decreasing Returns to Scale:** Across all specifications, output elasticity with respect to labor ($0.53 - 0.70$) exceeds that of physical capital ($0.26 - 0.41$), and total returns to scale remain slightly below unity ($RTS \in [0.937, 0.957]$).

---

## Repository Contents
| File | Description |
| :--- | :--- |
| [`kod_R.R`](./kod_R.R) | Complete R script implementing matrix OLS, Kmenta initialization, Newton CES estimation, Translog Hessian/AES calculation, and COLS/SFA efficiency estimation. |
| [`POMIAR EFEKTYWNOSCI GOSPODAREK EUROPY.pdf`](./POMIAR%20EFEKTYWNOSCI%20GOSPODAREK%20EUROPY.pdf) | Full 24-page empirical paper (in Polish) with theoretical derivations, statistical tables, and macroeconomic interpretation. |
