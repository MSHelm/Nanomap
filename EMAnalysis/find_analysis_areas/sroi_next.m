function sroi_next;

global movi rr xx yy filename chol b2 Movi3 pixel_size image_matrix positioner pixel_size limits
global list mapname b rows cols A q s ijj jjj r1 firstred olds inner_radius outer_radius matrix backmatrix old_movi
global alignsx alignsy rect fused not_fused sh hex hey rr1 imagenr mess


imagenr=imagenr+1;
imagenr*100/numel(mess)
positioner=0;
 hex=[]; hey=[];
 movi=[];
 
if numel(mess)>=imagenr 
[stat, mess]=fileattrib('*.tif');
rr=mess(imagenr).Name;

filename=strcat(rr(1:numel(rr)-4),'vals.txt');
movi=imread(mess(imagenr).Name);

imagesc(movi); colormap(gray); axis equal;


 m=uicontrol('style','pushbutton', 'callback','sroi_next',...
      'position',[400 0 70 30],'string','Next');
  
% sh=uicontrol('Style', 'slider','Callback',@lut,'Max', 255, 'Min',0,'Value',255,...
% 'SliderStep',[0.025 0.1], 'Position', [550 0 100 30]);

matrix=[];
chol=[];
inner_radius=10;
outer_radius=30;
image_matrix=[];
zz=[];
iii=0;jjj=1;
ijj=4;
backmatrix=[];
alignsx=[]; alignsy=[];
xx=[]; yy=[]; zz=[];
hex=[]; hey=[];

 fused=[];
 not_fused=[];
  
 set(gcf,'windowbuttondownfcn','sroi_00y');

else
      close all;
      [stat, mess]=fileattrib('*vals.txt');
      a=[0 0 0];
      for i=1:numel(mess);
          b=dlmread(mess(i).Name); 
      b=b(1:3);
      a=a+b; 
      end
      a=a/numel(mess);
      dlmwrite('vals_total.txt',a);
      
      a

end;