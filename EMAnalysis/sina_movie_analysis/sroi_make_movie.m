function make_movie;

global list mapname b movi rows cols A i xx yy zz iii bbb q s ijj jjj r firstred olds inner_radius outer_radius matrix backmatrix autos 
global cellb slide xxes yyes hex hey movib


%figure;

   colormap(gray);
   set(gcf,'doublebuffer','on');

for klm=q:s
klm


himg=image(movi(:,:,klm),'cdatamapping','scaled'); axis equal;



 
 F(klm)=getframe(gcf);
 
%  [aF,mmap]=frame2im(F);
%  max(max(aF))
%  cF=[];
%  cF(:,:,1)=double(aF(:,:,1))*1/255;
%  cF(:,:,2)=double(aF(:,:,2))*1/255;
%  cF(:,:,3)=double(aF(:,:,3))*1/255;
%  imwrite(aF,strcat(rr,'_',num2str(positioner),'_click.jpg'),'jpg'); 
 
 
end
[stat, mess]=fileattrib('*movie*');

 if stat==0
    movie_name='movie1.avi';
 else
    movie_name=strcat('movie',num2str(numel(mess)+1),'.avi');
 end;
     


movie2avi(F,movie_name,'compression','none','quality',100,'fps',10);
