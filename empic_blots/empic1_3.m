function empic1

global movi xx yy A counter tipul culoare numar r background
global switcher image_number valoare values_string deleter
global countter axx ayy newfig smart_values halfx halfy



switcher=0;

          l=get(gca,'currentpoint');
          abx=round(l(3));
          aby=round(l(1));
          
          numar=numar+1;
          
         octogon=[];
         
             
         ocols=[abx-halfx, abx+halfx, abx+halfx, abx-halfx];
         orows=[aby-halfy, aby-halfy, aby+halfy, aby+halfy];
         
         xx=ocols;
         yy=orows;
    counter=8;
           % disp(orows); 
           % disp(ocols);
     line(yy,xx,'color','b');
     
     newfig=[];
     newfig(:,:)=A(abx-halfx:abx+halfx,aby-halfy:aby+halfy); 
     newfig=455-newfig;



figure; image(newfig,'cdatamapping','scaled');

figure;

sizeul=size(newfig);
xvals=[1:1:sizeul(2)];

media=mean(newfig');

plot(media);

countter=0;
axx=[];
ayy=[];

set(gcf,'windowbuttondownfcn','empic1_3_1_felipe');
    set(gcf,'windowbuttonupfcn','sroi03');

    
    
%%end;
    
   