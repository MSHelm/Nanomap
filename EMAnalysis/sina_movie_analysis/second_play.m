function splay

global list mapname b movi rows cols A i xx yy zz iii bbb q s ijj jjj r firstred olds inner_radius outer_radius matrix movib

sum_movib=[];

sum_movib=movib(:,:,1);
   for j=q+1:s-1
           
   colormap(jet);
 imagesc(movib(:,:,j)); axis equal;
%    ,'cdatamapping','scaled');
  
   %disp(j);
   drawnow;
   
   sum_movib(:,:)=sum_movib+movib(:,:,j);
end;

