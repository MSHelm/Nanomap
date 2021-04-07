function splay

global list mapname b movi rows cols A i xx yy zz iii bbb q s ijj jjj r firstred olds inner_radius outer_radius matrix


% movi(1,1,:)=max(max(max(movi)));
% movi(1,2,:)=min(min(min(movi)));

   for j=q:s
 imagesc(movi(:,:,j)); axis equal;
%    ,'cdatamapping','scaled');
  
   %disp(j);
   drawnow;
end;
