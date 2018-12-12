function SP=mapEnvironment(BS,SP,UEmean,UEcov,measurement)
%% 
% This function computes an estimate of the SP locations
% input:
%   -BS: base station data structure
%   -SP: scatter point data structure (only used as an output)
%   -UEmean: UE mean state
%   -UEcov: UE covariance

%   
% output
%   -SP: scatter point data structure, with mean and covariance for each SP
%
% (c) 2018, Henk Wymeersch
% henkw@chalmers.se
Ns=100;
N_SP=size(measurement,1);
UEsamples=real(sqrtm(UEcov))*randn(5,Ns)+UEmean;                        % generate UE state samples
UEsamples=UEsamples(1:3,:);                                               % only keep position
ipsp=zeros(3,Ns,N_SP);
for k=1:N_SP           
    for n=1:Ns    
         % determine a line between SP and BS
        rho=measurement(k,1)-UEmean(5);                                % max distance of SP
        thetaSP=measurement(k,2:3);                                     % angle from BS to SP
        SPSmax(1)=rho*cos(thetaSP(2))*cos(thetaSP(1))+BS.pos(1);        % 3D position of SP along angle thetaSP
        SPSmax(2)=rho*cos(thetaSP(2))*sin(thetaSP(1))+BS.pos(2);
        SPSmax(3)=rho*sin(thetaSP(2))+BS.pos(3);   
        thetaUE(1)=pi-UEmean(4)-measurement(k,4);                        % Az AOA seen from SP
        thetaUE(2)=-measurement(k,5);                                   % El AOA seen from SP         
        % now determine a line from UE to SP and compute distance
        % to line from BS to SP: 
        pt1a = UEsamples(:,n);                                          % guess of UE position
        pt2a = UEsamples(:,n)-rho*[cos(thetaUE(2))*cos(-thetaUE(1)); cos(thetaUE(2))*sin(-thetaUE(1)); sin(thetaUE(2))];        % line from UE to SP
        [~,~,pt1,pt2]=DistBetween2Segment(pt1a,pt2a,BS.pos,SPSmax');
        ipsp(:,n,k)=(pt1+pt2)/2;  % possible location of SP
    end    
   SP(k).mean=mean(ipsp(:,:,k)')';
   SP(k).cov=cov(ipsp(:,:,k)')';       
end