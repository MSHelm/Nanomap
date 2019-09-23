function empic1

global movi xx yy A counter tipul culoare val_m val_v val_c val_vold val_cold val_mold ttt linia
global switcher image_number valoare

counter=1;
  xx=[];
  yy=[];
  linia=[];
  hfig=gcf;
      button=get(hfig,'selectiontype');
        if (strcmp(button,'extend'))
 set(gcf,'windowbuttonmotionfcn','empic3');
 set(gcf,'windowbuttonupfcn','empic4');
        elseif (strcmp(button,'alt'))
            empic1_2;
            set(gcf,'windowbuttonupfcn','empic4');
        elseif (strcmp(button,'normal'))
            empic1_3;
            set(gcf,'windowbuttonupfcn','sroi03');
             end;
        
 
