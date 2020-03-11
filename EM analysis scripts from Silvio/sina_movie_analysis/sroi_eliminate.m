function sroi_eliminate;

global list mapname b movi rows cols A i xx yy zz iii bbb q s ijj jjj r firstred olds inner_radius outer_radius matrix

movi(:,:,ijj)=0;
    himg=image(movi(:,:,ijj),'cdatamapping','scaled');
  