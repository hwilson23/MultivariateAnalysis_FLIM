# Multi-variate Analysis for FLIM 

Determination of Coefficient of Variation in complex FLIM datasets under different imaging conditions

## Results

- **Large Cov is strongly associated with long-lifetime FLIM data**

## Goals

- Compare two  distinct lifetime distributions over time/ days
- Compare many distinct lifetimes over singleday/ time-lapse
- Compare live changes using a quencher
  - Translate result into biexponential dataset and biological samples
  - Examine acqusition parameters / Test pile-up correction
  - Examine solutions both hardware and software  

## Todo List

- Make R-project
- Folder-based separation for project milestones (update .gitignore)
- Examine the cause for segregation in High CCV values
- Refactor CCV to tau-mean

### Steps Oct 11, 2022
 - bins in dye-solution (why certain high-laserpower values)
 - cells and morphology based covariance analysis
 - pollen grain: increase number of pixels 
				: additional test to identify why low lifetime pollen has high cov between files
 - dye solution : quenching of Rh110.
 - 