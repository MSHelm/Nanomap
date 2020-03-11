function sroi_motion

global list mapname b movi rows cols A i xx yy zz iii bbb q s ijj jjj r firstred olds inner_radius outer_radius matrix counter xxes yyes backmatrix



 l=get(gca,'currentpoint');
          x=round(l(3));
          y=round(l(1));
          xxes(counter)=x;yyes(counter)=y;



          
        %  h=findobj(gca,'type','image');
        %  set(h,'cdata',A);
          
          
if counter>1
      tx=[xxes(counter-1),xxes(counter)];
      ty=[yyes(counter-1),yyes(counter)];

   linia(counter-1)=line('Xdata',ty,'Ydata',tx,'color','y');

 end;

 
            counter=counter+1;
 
