function sroi_00y;

global list mapname b movi rows cols A i xx yy zz iii bbb q s ijj jjj r  outer_radius matrix counter xxes yyes backmatrix counter2 xxes2 yyes2
 
global hex hey

gcf
      button=get(gcf,'selectiontype');
        if (strcmp(button,'normal'))
    set(gcf,'windowbuttonupfcn','sroi_3');
        elseif (strcmp(button,'alt'))
            counter=1;
            xxes=[];
            yyes=[];
            set(gcf,'windowbuttonmotionfcn','sroi_motion');
            set(gcf,'windowbuttonupfcn','sroi_2');
        elseif (strcmp(button,'extend'))
              
        l=get(gca,'currentpoint')
        
        hex=round(l(1));
        hey=round(l(3));
        
        xes=[hex-10 hex+10 hex+10 hex-10 hex-10];
        yes=[hey-10 hey-10 hey+10 hey+10 hey-10];
        
        line(xes,yes,'color','r');  
         set(gcf,'windowbuttonupfcn','sroi_3');
            
        end;
        
            