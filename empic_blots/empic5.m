function empic5

global movi xx yy A counter tipul r inverter
global switcher image_number valoare values_string deleter

  tx=[xx(1),xx(numel(xx))];
  ty=[yy(1),yy(numel(yy))];
 linia(counter-1)=line('Xdata',ty,'Ydata',tx,'color','g');

bbb=roipoly(A(:,:),yy,xx); 

pixfig=find(bbb==1);
numar=numel(pixfig);

value=sum(A(pixfig));


if switcher>0
    
    value=value-numar*valoare; 
    value = value / 1000;
    value = value * inverter * (-1); 
    %value=value/numar;
   disp(value);
   
    values_string(numel(values_string)+1)=value;
else
     valoare=value/numar;
     %numar

end;


switcher=switcher+1;

fisier=strcat(r,'.txt');

dlmwrite(fisier, values_string,'\t');

deleter=1;

