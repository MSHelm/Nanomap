function empic1

global movi xx yy A numar clear unclear background r


hfig=gcf;
    button=get(hfig,'selectiontype');
        if (strcmp(button,'normal'))
          l=get(gca,'currentpoint');
          x=round(l(3));
          y=round(l(1));
          
          numar=numar+1;
          xx(numar)=x;
          yy(numar)=y;
          octogon=[];
                      
         ocols=[x-14, x-10, x,    x+10,   x+14, x+10,   x,   x-10,   x-14];
         orows=[y,   y-10, y-14,  y-10,   y,   y+10,   y+14, y+10,   y];
           % disp(orows); 
           % disp(ocols);
       line(orows,ocols,'color','r');
       octogon=roipoly(A(:,:),orows,ocols);
       
       pos=find(octogon==1);
       media=mean(A(pos));
       media=media-background;       
       clear(numar)=media;
       
       
              elseif (strcmp(button,'alt'))
          l=get(gca,'currentpoint');
          x=round(l(3));
          y=round(l(1));
         octogon=[];
         ocols=[x-28, x-20, x,    x+20,   x+28, x+20,   x,   x-20,   x-28];
         orows=[y,   y-20, y-28,  y-20,   y,   y+20,   y+28, y+20,   y];
           % disp(orows); 
           % disp(ocols);
     line(orows,ocols,'color','b');
       octogon=roipoly(A(:,:),orows,ocols);
       
       pos=find(octogon==1);
       media=mean(A(pos));
       
       background=media;
      
   end;
         