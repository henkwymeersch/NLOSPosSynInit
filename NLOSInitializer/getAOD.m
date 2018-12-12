function AOD = getAOD(BS,UE,point,type)    
   point=reshape(point,3,1);
   switch(type)
       case('LOS')           
           d_BS_UE=norm(BS-UE(1:3));
           AOD=[atan2(UE(2),UE(1)) asin((UE(3)-BS(3))./d_BS_UE)];           
       case('VA')
            VA=point;
            xUE=UE(1:3);
            u=(BS-VA)/norm(BS-VA);
            f=(BS+VA)/2;
            incidencePoint=VA+((f-VA)'*u)/((xUE-VA)'*u)*(xUE-VA);
            AOD=[atan2(incidencePoint(2),incidencePoint(1)) asin((incidencePoint(3)-BS(3))/norm(incidencePoint-BS))];            
       case('SP')
           SP=point;
           d_SP_BS=norm(BS-SP);
           AOD=[atan2(SP(2),SP(1)) asin((SP(3)-BS(3))./d_SP_BS)];           
       otherwise
           error('unknown type')
   end
end