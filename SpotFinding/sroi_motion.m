function sroi_motion

global counter xxes yyes switcher



 l=get(gca,'currentpoint');
          x=round(l(3));
          y=round(l(1));
          xxes(counter)=x;yyes(counter)=y;
          
if counter>1
      tx=[xxes(counter-1),xxes(counter)];
      ty=[yyes(counter-1),yyes(counter)];

      if switcher==1
   line('Xdata',ty,'Ydata',tx,'color','b');
      else
          
   line('Xdata',ty,'Ydata',tx,'color','r');
      end;

 end;

 
            counter=counter+1;
 
