function sroi_quit;

global list mapname b movi rows cols A i xx yy zz iii bbb q s ijj jjj r olds inner_radius outer_radius matrix

   
     for kounter=1:olds% 2*olds
         kounter

       BBB=movi(:,:,kounter);
   
         for jj=1:numel(xx)
   doublex=xx(jj);
   doubley=yy(jj);          
    ocols=[];
    orows=[];
    ocols3=[];
    orows3=[];
          
    k = 4;
    n = 2^k-1;
   theta = pi*(-n:1:n)/n;
   protx=doublex; proty=doubley;
   protx = protx + inner_radius*cos(theta);
   proty = proty + inner_radius*sin(theta);
   orows=round(protx);
   ocols=round(proty);

   protx=doublex; proty=doubley;
   protx = protx + outer_radius*cos(theta);
   proty = proty + outer_radius*sin(theta);
   orows3=round(protx);
   ocols3=round(proty);
        
           
       octogon=roipoly(BBB,orows,ocols);
       pos=find(octogon==1);
       media1=mean(BBB(pos));
      % matrix(jj,2+2*kounter)=media;
              
       octogon2=roipoly(BBB, orows3,ocols3);
       pos=find(octogon2==1 & octogon==0);
       media2=mean(BBB(pos));
       
       matrix(jj,kounter)=media1-media2;

           
       end;
     end;
  
        
dlmwrite('matrix.txt',matrix);
save('movie.mat','movi','matrix','r','rows','cols','A','q','s','olds','inner_radius','outer_radius');


ee=uicontrol('tag','fff','string','Do you want to process the data for R/G/B 2x?',...
      'style','pushbutton','callback','sroi_RGB2X',...
      'position',[300 300 300 30],'tooltipstring','makes averages of the doubles, and makes separate files for the colors, and also normalizes');
ee=uicontrol('tag','fff','string','No, I just want to quit!',...
      'style','pushbutton','callback','sroi_out',...
      'position',[300 200 300 30],'tooltipstring','closes the image');