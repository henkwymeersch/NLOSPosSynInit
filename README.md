# NLOSPosSynInit
A simple routine for intializing 5G positioning and synchronization from only NLOS paths

## Summary 
This matlab code (main file main.m) generates a 3D environment with a user equipment (UE) with unknown 3D position, 1D heading, and 1D clock bias, a base station (BS) with known 3D location, and a number of scattering points (SPs) with unknown 3D postions. From this environment, a 5D measurement is generated for each non-line-of-sight (NLOS) path: a time of arrival (TOA), a direction of arrival (DOA, also known as AOA) in azimuth and elevation, a direction of departure (DOD, also known as AOD) in azimuth and elevation. The purpose of the code is then to find an initial guess of the UE state and the locations of the SPs. 

## Main parameters
The main parameters that the user can set are:
```
sigma.DOA_az = 0.01; %[radian]  standard deviation of DOA in azimuth
sigma.DOA_el = 0.01; %[radian]  standard deviation of DOA in elevation
sigma.DOD_az = 0.01; %[radian]  standard deviation of DOD in azimuth
sigma.DOD_el = 0.01; %[radian]  standard deviation of DOD in elevation
sigma.TOA = 0.1;     %[m]       standard deviation of TOA in elevation
N_SP=5;              % number of NLOS paths
bias_prior=200.00;   % [m] uncertainty of the bias (-bias_prior/2,+bias_prior/2)
alpha_prior=pi;      % [rad] uncertainty of the orientation (0,alpha_prior);
UE.state=[70 0 0 pi/3 20]';     % generate UE prior [3D position, orientation, bias]
BS.pos = [0; 0; 40];            % BS position
SP(k).pos=[rand(1)*100-50; (rand(1)*100)-50; rand(1)*40-20];     % the k-th scattering point  
```

## Authors
The code was developed by 
* **[Henk Wymeersch](https://sites.google.com/site/hwymeers/)**

For more information, please see **[here](https://arxiv.org/abs/1812.05417)**
```
@article{wymeersch2018simple,
  title={A Simple Method for 5G Positioning and Synchronization without Line-of-Sight},
  author={Wymeersch, Henk},
  journal={arXiv preprint arXiv:1812.05417},
  year={2018}
}
```
