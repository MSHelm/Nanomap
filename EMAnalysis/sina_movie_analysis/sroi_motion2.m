function sroi_motion

global list mapname b movi rows cols A i xx yy zz iii bbb q s ijj jjj r firstred matrix counter xxes yyes backmatrix counter2 xxes2 yyes2



 l=get(gca,'currentpoint');
          x=round(l(3));
          y=round(l(1));
          xxes2(counter2)=x;yyes2(counter2)=y;



          
        %  h=findobj(gca,'type','image');
        %  set(h,'cdata',A);
          
          
if counter2>1
      tx=[xxes2(counter2-1),xxes2(counter2)];
      ty=[yyes2(counter2-1),yyes2(counter2)];

   linia(counter2-1)=line('Xdata',ty,'Ydata',tx,'color','c');

 end;

 
            counter2=counter2+1;
 
