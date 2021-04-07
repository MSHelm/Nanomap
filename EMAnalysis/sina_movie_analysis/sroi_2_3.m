function sroi_2

global list mapname b movi rows cols A i xx yy zz iii bbb q s ijj jjj r firstred olds inner_radius outer_radius matrix backmatrix autos 
global cellb slide xxes yyes hex hey movib

if numel(hex)==0
    disp('NO BACKGROUND SELECTED!!!');
else
    
movib=[];

for klm=q+1:s
    klm
movib(:,:,klm-1)=movi(:,:,klm)-movi(:,:,klm-1);

movib(:,:,klm-1)=movib(:,:,klm-1)-mean2(movib(:,:,klm-1));
ccc=find(movib(:,:,klm-1)<0);
a=movib(:,:,klm-1);
a(ccc)=0;
movib(:,:,klm-1)=a;

end;

sizeul=size(movib);

value1=[];
back1=[];
value2=[];
back2=[];
 
real_value=[];

 for j=1:sizeul(3)
    
    back1=movi(hey-10:hey+10,hex-10:hex+10,j);
    
    back2=movib(hey-10:hey+10,hex-10:hex+10,j);
      
    
    ccc=find(movi(:,:,j)>(mean2(back1)+2*std2(back1)));
    A=movi(:,:,j);
    good_pixels=A(ccc); 
    value1(j)=mean(good_pixels)-(mean2(back1)+2*std2(back1));
    
    
     ccc=find(movib(:,:,j)>(mean2(back2)+2*std2(back2)));
    A=movib(:,:,j);
    good_pixels=A(ccc); 
    value2(j)=mean(good_pixels)-(mean2(back2)+2*std2(back2));
     
 real_value(j)=value2(j)*100/value1(j);
      
 end;


[stat, mess]=fileattrib('*difference_frames*.txt')
if stat==0
    dlmwrite(strcat('difference_frames1.txt'),real_value');
else
      dlmwrite(strcat('difference_frames',num2str(numel(mess)+1),'.txt'),real_value');
end;
    
      



figure;
colormap(gray);
himg=image(movib(:,:,q),'cdatamapping','scaled'); axis equal;
b=uicontrol('tag','fff','string','Play',...
      'style','pushbutton','callback','second_play',...
      'position',[50 0 50 30],'tooltipstring','play movie');
  
end;
