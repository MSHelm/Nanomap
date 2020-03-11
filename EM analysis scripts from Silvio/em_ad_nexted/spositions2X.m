function spositions2X

global Movi xx yy r matrix memornot vesicler

hfig=gcf;
      

    button=get(hfig,'selectiontype');
        if (strcmp(button,'normal'))
            vesicler=1;
            
          l=get(gca,'currentpoint');
          x=round(l(3));
          y=round(l(1));
          
          line(y,x,'Linestyle','none','Marker','o','MarkerSize',5,'MarkerEdgeColor','c','MarkerFaceColor','y');
  
           sizem=size(matrix);
           if sizem(2)>4    
       bb=matrix(:,5);
       finder=find(bb>0);
       matrix(numel(finder)+1,5)=x;
       matrix(numel(finder)+1,6)=y;
           else
               matrix(1,5)=x;
               matrix(1,6)=y;
           end;
          
             
       elseif (strcmp(button,'alt'))
           vesicler=2;
          l=get(gca,'currentpoint');
          x=round(l(3));
          y=round(l(1));
          line(y,x,'Linestyle','none','Marker','o','MarkerSize',5,'MarkerEdgeColor','c','MarkerFaceColor','r');


          
      sizem=size(matrix);
           if sizem(2)>6    
       bb=matrix(:,7);
       finder=find(bb>0);
       matrix(numel(finder)+1,7)=x;
       matrix(numel(finder)+1,8)=y;
           else
              matrix(1,7)=x;
              matrix(1,8)=y;  
        end;
        end;
        
