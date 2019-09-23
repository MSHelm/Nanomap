function empic3

global movi xx yy A counter tipul culoare val_m val_v val_c val_vold val_cold val_mold ttt linia
global switcher image_number valoare


 l=get(gca,'currentpoint');
          x=round(l(3));
          y=round(l(1));
          xx(counter)=x;yy(counter)=y;



          
        %  h=findobj(gca,'type','image');
        %  set(h,'cdata',A);
          
          
if counter>1
      tx=[xx(counter-1),xx(counter)];
      ty=[yy(counter-1),yy(counter)];
      if switcher==0
   linia(counter-1)=line('Xdata',ty,'Ydata',tx,'color','r');
      else
         linia(counter-1)=line('Xdata',ty,'Ydata',tx,'color','g');    
  end;
end;

 
            counter=counter+1;
 
