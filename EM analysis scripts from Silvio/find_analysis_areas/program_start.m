function vesan

global movi rr xx yy filename chol b2 Movi3 pixel_size image_matrix positioner pixel_size limits
global list mapname b rows cols A q s ijj jjj r1 firstred olds inner_radius outer_radius matrix backmatrix old_movi
global alignsx alignsy rect fused not_fused sh hex hey rr1 imagenr mess

cd 'F:\data_2012\spines\spine_3Ds - Kopie\stumpy\Spine600b_1_forsilvio';

q=1; s=4;
limits=[8 3 25];

positioner=0;
imagenr=1;

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
