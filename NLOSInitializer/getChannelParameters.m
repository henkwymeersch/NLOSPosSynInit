function ChannelParams = getChannelParameters(BS,UE,point,type)
% OUTPUT: this function returns [TOA, DODaz, DODel, DOAaz, DOAel]
% INPUT: input is the 3D BS location, the 3D user location, a 3D VA or SP location
% and the type ('LOS','VA','SP') = LOS, virtual anchor, scattering point. 
% usage: ChannelParams = getChannelParameters(BS,UE,point,type)
    ChannelParams =zeros(5,1);
    ChannelParams(1) =getTOA(BS,UE,point,type);
    ChannelParams(2:3) =getAOD(BS,UE,point,type);
    ChannelParams(4:5) =getAOA(BS,UE,point,type);