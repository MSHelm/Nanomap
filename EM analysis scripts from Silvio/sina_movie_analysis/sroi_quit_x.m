function sroi_quit;

global list mapname b movi rows cols A i xx yy zz iii bbb q s ijj jjj r olds inner_radius outer_radius matrix backmatrix

   
%dlmwrite('matrix.txt',matrix);
%save('movie.mat','movi','matrix','r','rows','cols','A','q','s','olds','inner_radius','outer_radius');
%close all;
%return;

     for kounter=1:s
         kounter

      BBB=movi(:,:,kounter);
  
         for jj=1:numel(xx)
   doublex=xx(jj);
   doubley=yy(jj);          
    ocols3=[];
    orows3=[];
         
    k = 4;
    n = 2^k-1;
   theta = pi*(-n:1:n)/n;
   protx=doublex; proty=doubley;
   protx = protx + outer_radius*cos(theta);
   proty = proty + outer_radius*sin(theta);
   orows3=round(protx);
   ocols3=round(proty);
       
              
       octogon2=roipoly(BBB, orows3,ocols3);
       pos=find(octogon2==1);
       media=mean(BBB(pos));
       
       matrix(jj,2+kounter)=media;

           
      end;
    end;
     

     matrix(numel(xx)+1,3:numel(backmatrix)+2)=backmatrix;
     
          
dlmwrite(strcat(r,'matrix.txt'),matrix);
save(strcat(r,'movie.mat'),'movi','matrix','r','rows','cols','A','q','s','xx','yy','outer_radius');

frap_processing;
%close all;