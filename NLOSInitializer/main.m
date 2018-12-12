clear all
close all
clc
% ======================================================
% Joint localization, synchronization and orientation estimation in 3D
% Pre-processing algorithm to obtain initial estimate 
% Output in the form of a mean and covariance matrix. 
% (c) 2018, Henk Wymeersch
% henkw@chalmers.se
% 
% Comments:
% -code only works with low measurement noise
% -
% ======================================================


% 0. Simulation parameters
% ------------------------
sigma.DOA_az = 0.01; %[radian]  standard deviation of DOA in azimuth
sigma.DOA_el = 0.01; %[radian]  standard deviation of DOA in elevation
sigma.DOD_az = 0.01; %[radian]  standard deviation of DOD in azimuth
sigma.DOD_el = 0.01; %[radian]  standard deviation of DOD in elevation
sigma.TOA = 0.1;     %[m]       standard deviation of TOA in elevation
N_SP=5;              % number of NLOS paths
bias_prior=200.00;   % [m] uncertainty of the bias (-bias_prior/2,+bias_prior/2)
alpha_prior=pi;      % [rad] uncertainty of the orientation (0,alpha_prior);
plotting=1;          % flag for visualization of the cost function




% complexity parameters:
Ns=10;               % number of samples in the objective function
Na=30;               % grid points for user orientation in [0, pi]
Nb=5;                % grid points for user bias

assert(N_SP>1);


% 1. Geometric Scenario:
% ----------------------
UE.state=[70 0 0 pi/3 20]';     % generate UE prior [3D position, orientation, bias]
BS.pos = [0; 0; 40];            % BS position
measurementCovariance=diag([sigma.TOA^2,sigma.DOD_az^2,sigma.DOD_el^2,sigma.DOA_az^2,sigma.DOA_el^2]);  
measurement=zeros(N_SP,5);
for k=1:N_SP        
    SP(k).pos=[rand(1)*100-50; (rand(1)*100)-50; rand(1)*40-20];     % generate a scattering point       
    measurement(k,:)=getChannelParameters(BS.pos,UE.state,SP(k).pos,'SP') +sqrtm(measurementCovariance)*randn(5,1);        % generate a measurement of the form: [TOA, DODaz, DODel, DOAaz, DOAel]
end


% 2. Determine an estimate for bias and orientation
% --------------------------------------------------
f = @(x)computeErrorMetric(x,Ns,measurementCovariance,measurement,BS);   
alphaV=linspace(0,alpha_prior*(Na-1)/Na,Na);
biasV=linspace(-bias_prior/2,+bias_prior/2,Nb);
for k=1:Na
    a(k)=f([0 alphaV(k)]);    
end
[vbest,in]=min(a);
xbest=[];
for k=1:Nb       
    [x,fval] = fminsearch(f,[biasV(k) alphaV(in)]);               
    if (fval<vbest) vbest=fval; xbest=x; end
end

% 3. For the chosen bias and orientation, determine UE position
% --------------------------------------------------------------
[dum,UE.mean,UE.cov] = f(xbest);     


% 4. Determine the SP locations
% ------------------------------
SP=mapEnvironment(BS,SP,UE.mean,UE.cov,measurement);

% 5. Show some plots
% -------------------
if (plotting)
    Na=40;
    Nb=50;
    alphaV=linspace(0,alpha_prior*(Na-1)/Na,Na);
    biasV=linspace(-bias_prior/2,+bias_prior/2,Nb);
 	for k=1:Na   
        for l=1:Nb
            D(k,l)=f([biasV(l) alphaV(k)]);    
        end
    end
    mesh(alphaV,biasV,D');
    hold on
    [xx,yy]=find(D==min(min(D)));
    xlabel('\alpha [rad]')
    ylabel('B [m]')
    zlabel('error metric')
    plot3(alphaV(xx), biasV(yy),min(min(D))-5,'r*');
    text(alphaV(xx), biasV(yy), min(min(D))-5,'optimal value');
    plot3(UE.state(4), UE.state(5),min(min(D))-5,'b*');
    text(UE.state(4), UE.state(5), min(min(D))-5,'true value');
    
    figure
    plot3(BS.pos(1),BS.pos(2),BS.pos(3),'r*');
    hold on
    text(BS.pos(1),BS.pos(2),BS.pos(3),'BS')
    line([BS.pos(1) BS.pos(1)],[BS.pos(2) BS.pos(2)],[0 BS.pos(3)]);   
    plot3(UE.state(1),UE.state(2),UE.state(3),'b*');
    text(UE.state(1),UE.state(2),UE.state(3),'UE')    
    plot3(UE.mean(1),UE.mean(2),UE.mean(3),'b.');
    line([UE.state(1) UE.mean(1)],[UE.state(2) UE.mean(2)],[UE.state(3) UE.mean(3)]);   
    for k=1:N_SP
        plot3(SP(k).pos(1),SP(k).pos(2),SP(k).pos(3),'k*');
        text(SP(k).pos(1),SP(k).pos(2),SP(k).pos(3),'SP');
        line([SP(k).pos(1) SP(k).mean(1)],[SP(k).pos(2) SP(k).mean(2)],[SP(k).pos(3) SP(k).mean(3)])
        plot3(SP(k).mean(1),SP(k).mean(2),SP(k).mean(3),'k.');        
    end    
    xlabel('x [m]')
    ylabel('y [m]')
    zlabel('z [m]')    
    grid
end



disp('done')