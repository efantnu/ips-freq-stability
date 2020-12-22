# Data set and simulation files
This repository contains the data set and simulation files of the paper "Sufficient conditions for robust frequency stability of ac power systems" authored by Erick F. Alves, Gilbert Bergna-Diaz, Danilo I. Brandao and Elisabetta Tedeschi. With these files, it is possible to reproduce all the simulations and results obtained in the paper.

[![DOI](https://zenodo.org/badge/275805008.svg)](https://zenodo.org/badge/latestdoi/275805008)

# File organization
- 39_Bus_New_England_System.pfd: DIgSILENT PowerFactory 2020 pfd project of the 39 Bus New England System used for validation in the paper. 
- 39_Bus_New_England_System.pdf: detailed description of the model.
- First Draft: folder with the files used in the first draft of the paper.
    - LoadSec.mat: data set of the load demand from the platform's SCADA system for one representative week with a sampling period of one second
    - avg_model.slx: Matlab Simulink model of an isolated power system, as presented in fig.1 of the paper.
    - avg_model_gov.slx: Matlab Simulink extended model of an isolated power system, as presented in fig.5 of the paper. It includes the speed droop control loop with controller and actuator delays.
    - avg_model_script.m: Matlab script that executes all simulations and produces all figures in the paper.  
