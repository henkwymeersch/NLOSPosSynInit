function TOA = getTOA(BS,UE,point,type)
   switch(type)
       case('LOS')
           TOA=norm(BS-UE(1:3))+UE(5);           
       case('VA')
           TOA=norm(point-UE(1:3))+UE(5);
       case('SP')
           TOA=norm(point-UE(1:3))+norm(BS-point)+UE(5);
       otherwise
           error('unknown type')
   end
end