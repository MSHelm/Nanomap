function empic1

global movi xx yy A counter tipul culoare numar r background
global switcher image_number valoare values_string deleter

switcher=0;

          l=get(gca,'currentpoint');
          abx=round(l(3));
          aby=round(l(1));
          
          numar=numar+1;
          
         octogon=[];
         
             
         ocols=[abx-20, abx+20, abx+20, abx-20];
         orows=[aby-25, aby-25, aby+25, aby+25];
         
         xx=ocols;
         yy=orows;
    counter=8;
           % disp(orows); 
           % disp(ocols);
     line(yy,xx,'color','r');
  %     octogon=roipoly(A(:,:),orows,ocols);
       
  %     pos=find(octogon==1);
  %    valoare=mean(A(pos));
     