function [y,UEMean,UECov] = computeErrorMetric(x,Ns,S,measurement,BS)
%% 
% This function aims to compute an error metric for a hypothesis of the
% user bias and orientation. 
% input:
%   -x: [bias, orientation]
%   -Ns: number of samples used in the computation
%   -S: measurement covariance matrix
%   -measurement: [TOA, DODaz, DODel, DOAaz, DOAel] tuple
%   -BS: base station data structure
%   
% output
%   -y: scalar error metric 
%   -UEMean:  mean vector of the UE state  ( [3D position, orientation, bias])
%   -UECov: covariance matrix of UE state
%
% (c) 2018, Henk Wymeersch
% henkw@chalmers.se

N_SP=size(measurement,1);
rng(1)
for k=1:N_SP           
    for n=1:Ns               
        rho=measurement(k,1)-x(1)+randn(1)*sqrt(S(1,1));   %maximum distance of SP from the BS                
        thetaSP=measurement(k,2:3)+randn(1,2)*sqrtm(S(2:3,2:3)); % generate an AOD guess
        
        % generate a line where SP can be, given max range and AOD guess
        SPSmax(1)=rho*cos(thetaSP(2))*cos(thetaSP(1))+BS.pos(1);
        SPSmax(2)=rho*cos(thetaSP(2))*sin(thetaSP(1))+BS.pos(2);
        SPSmax(3)=rho*sin(thetaSP(2))+BS.pos(3);
        
        % generate a line where the UE can be, relative to SP:
        thetaUE(1)=pi-x(2)-measurement(k,4)+randn(1)*sqrtm(S(4,4)); 
        thetaUE(2)=-measurement(k,5)+randn(1)*sqrtm(S(5,5));                               
        xUErelmax(3)=rho*sin(thetaUE(2)); 
        xUErelmax(2)=rho*cos(thetaUE(2))*sin(-thetaUE(1));  
        xUErelmax(1)=rho*cos(thetaUE(2))*cos(-thetaUE(1)); 
       
        %UE line
        xmin(1:3,n,k)=reshape(SPSmax,3,1);        
        xmax(1:3,n,k)=BS.pos+reshape(xUErelmax,3,1);           
        % SP line
        xmin(4:6,n,k)=BS.pos;  
        xmax(4:6,n,k)=reshape(SPSmax,3,1); 
    end                        
end
                
% now we have Ns line segments, one per SP.      
D=zeros(Ns,N_SP*(N_SP-1)/2);
intersectionPoints=zeros(3,Ns,N_SP*(N_SP-1)/2);
for n=1:Ns
    k=0;
    for p1=1:N_SP
        for p2=p1+1:N_SP
            k=k+1;
            [D(n,k),~,pt1,pt2]=DistBetween2Segment(xmin(1:3,n,p1),xmax(1:3,n,p1),xmin(1:3,n,p2),xmax(1:3,n,p2));           
            intersectionPoints(:,n,k)=(pt1+pt2)/2;
        end                       
    end                        
end
zz=reshape(intersectionPoints,3,Ns*N_SP*(N_SP-1)/2);
UEMean=mean(zz')';            
UECov=cov(zz');   
UEMean=[UEMean; x(2); x(1)];
UECov=[UECov zeros(3,2); zeros(2,3) eye(2)];
UECov(4:5,4:5)=[0.1 0; 0 max(diag(UECov(1:3,1:3)))]; % just to put some value
y=mean(mean(D));
        