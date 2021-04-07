function sroi_00;

global list mapname b movi rows cols A i xx yy zz iii bbb q s ijj jjj r firstred olds inner_radius outer_radius matrix


%  hfig=gcf;
%    button=get(hfig,'selectiontype');
%        if (strcmp(button,'alt'))
          l=get(gca,'currentpoint');
          doublex=round(l(1));
          doubley=round(l(3));

          xx(numel(xx)+1)=doublex;
          yy(numel(yy)+1)=doubley;
          
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
 

if ijj<olds+1 & ijj >0
   line(orows,ocols,'color','g');
   zz(numel(zz)+1)=1;
elseif ijj<2*olds+1 & ijj >olds
     line(orows,ocols,'color','r');
   zz(numel(zz)+1)=2;
else
     line(orows,ocols,'color','b');
     zz(numel(zz)+1)=3;
end;
drawnow;

     line(orows3,ocols3,'color','b');

     
     
     matrix(numel(xx),1)=doublex;
     matrix(numel(xx),2)=doubley;
     matrix(numel(xx),3)=zz(numel(zz));
     
   %  for k=1:s
   % 
   %    BBB=movi(:,:,k);
   %    octogon=roipoly(BBB,orows,ocols);
   %    pos=find(octogon==1);
   %    media=mean(BBB(pos));
   %    
   %    matrix(numel(xx),2+2*k)=media;
   %           
   %    octogon2=roipoly(BBB, orows3,ocols3);
   %    pos=find(octogon2==1 & octogon==0);
   %    media=mean(BBB(pos));
   %    
   %    matrix(numel(xx),3+2*k)=media;
   %      
   %
   %    end;
   %   
   %   dlmwrite('matrix.txt',matrix);
       
        drawnow;   
 
   