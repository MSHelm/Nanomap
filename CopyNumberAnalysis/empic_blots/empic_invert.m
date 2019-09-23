function empic_invert;

global movi xx yy A counter tipul culoare numar r background inverter
global switcher image_number valoare values_string deleter

minimum=min(min(movi));

maximum=max(max(movi));

inverter=inverter*(-1);
movi(:,:)=maximum + minimum - movi(:,:);

colormap('gray');
  
  
himg=image(movi(:,:),'tag','him','cdatamapping','scaled');axis equal;