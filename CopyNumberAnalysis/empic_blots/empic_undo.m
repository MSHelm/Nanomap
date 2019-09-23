function empic

global movi xx yy A counter tipul culoare numar numar_p clear unclear r background numar_b r
global switcher image_number valoare values_string deleter smart_values


deleter

%if deleter>0
fisier=strcat(r,'smart_values.txt');

values_string=dlmread(fisier);values_string=values_string';
if numel(values_string>1)
    values_string=values_string(1:numel(values_string)-1);
    dlmwrite(fisier, values_string,'\t');
    smart_values=values_string
else
    smart_values=[];
    dlmwrite(fisier, smart_values,'\t');
end;



   tx=[xx(1),xx(numel(xx))];
  ty=[yy(1),yy(numel(yy))];
 linia(counter-1)=line('Xdata',ty,'Ydata',tx,'color','w');
 line('Xdata',yy,'Ydata',xx,'color','w');
 
%end;

deleter=0;
