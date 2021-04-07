function sgetline_1

global Movi xx yy memornot matrix

 l=get(gca,'currentpoint');
          x=round(l(3));
          y=round(l(1));
          xx(numel(xx)+1)=x;
          yy(numel(yy)+1)=y;
 
         if memornot==0
             if numel(yy)>1
                 line('Xdata',[yy(numel(yy)-1),yy(numel(yy))],'Ydata',[xx(numel(xx)-1),xx(numel(xx))],'Color','r');
             end;
         end;
         if memornot==1
             if numel(yy)>1
                line('Xdata',[yy(numel(yy)-1),yy(numel(yy))],'Ydata',[xx(numel(xx)-1),xx(numel(xx))],'Color','g');
             end;
         end;   

                 if memornot==2
             if numel(yy)>1
                line('Xdata',[yy(numel(yy)-1),yy(numel(yy))],'Ydata',[xx(numel(xx)-1),xx(numel(xx))],'Color','b');
             end;
                 end;
              if memornot==3
             if numel(yy)>1
                line('Xdata',[yy(numel(yy)-1),yy(numel(yy))],'Ydata',[xx(numel(xx)-1),xx(numel(xx))],'Color','y');
             end;
         end;   


  
