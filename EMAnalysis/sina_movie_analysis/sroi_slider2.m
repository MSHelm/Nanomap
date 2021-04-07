function sroi_slider

global list mapname b movi rows cols A i xx yy zz iii bbb q s ijj jjj r firstred olds inner_radius outer_radius matrix backmatrix autos 
global cellb slide xxes yyes hex hey slide2

hh=get(slide2,'value');

  
    textul=strcat(num2str(hh));
    text(10,10,'@','color',[0.7 0.7 0.7],'BackgroundColor',[0.7 0.7 0.7]);
    text(10,10,textul,'FontSize',10,'EdgeColor','b','color','b','BackgroundColor',[0.7 0.7 0.7]);
 