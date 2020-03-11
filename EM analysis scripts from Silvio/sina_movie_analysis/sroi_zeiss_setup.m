function sroi
global list mapname b movi rows cols A i xx yy zz iii bbb q s ijj jjj r firstred olds inner_radius outer_radius matrix backmatrix autos 
global cellb slide xxes yyes hex hey thefolder slide2
movi=[];
thefolder='C:\data_2009\february2009\090224_pHluorins-Tf-uptake_Ringer\TfR_Tf_2';
   
 cd(thefolder);
 
q=1;

cellb={};

shortener=5;

[sstat, mmess]=fileattrib('green*tif')

s=floor(numel(mmess)/shortener);
movi=[];

for klm=q:s+1
    klm
    (klm-1)*shortener+1
    a=imread(mmess((klm-1)*shortener+1).Name);
     
    movi(:,:,klm)=a(:,:);
    
end;
for j=1:numel(mmess)
    cellb{j}=mmess(j).Name;
end;



     
   colormap(gray);
   set(gcf,'doublebuffer','on');
 %  colormap(color);
 %  colorbar('vert');
himg=image(movi(:,:,q),'cdatamapping','scaled'); axis equal;
 
m=uicontrol('tag','get','style','pushbutton', 'callback','sroi_align',...
      'position',[0 0 50 30],'string','align',...
      'tooltipstring','Whole terminal');
b=uicontrol('tag','fff','string','Play',...
      'style','pushbutton','callback','splay',...
      'position',[50 0 50 30],'tooltipstring','play movie');
% dd=uicontrol('tag','fff','string','Step',...
%       'style','pushbutton','callback','step',...
%       'position',[100 0 50 30],'tooltipstring','one by one');
% ee=uicontrol('tag','fff','string','Stepback',...
%       'style','pushbutton','callback','stepback',...
%       'position',[150 0 50 30],'tooltipstring','one by one back');
ee=uicontrol('tag','fff','string','Eliminate',...
      'style','pushbutton','callback','sroi_eliminate',...
      'position',[460 0 60 30],'tooltipstring','takes out the frame');
ee=uicontrol('tag','fff','string','Undo',...
      'style','pushbutton','callback','sroi_undo',...
      'position',[200 0 50 30],'tooltipstring','takes out spots one by one');
 ee=uicontrol('tag','fff','string','movie',...
       'style','pushbutton','callback','sroi_make_movie',...
       'position',[520 0 40 30]);
ee=uicontrol('tag','fff','string','Upload',...
      'style','pushbutton','callback','sroi_upload_zeiss_setup',...
      'position',[250 0 50 30],'tooltipstring','Bring back the aligned movie with all the previous measurements');
% ee=uicontrol('tag','fff','string','Quit',...
%       'style','pushbutton','callback','sroi_quit_x',...
%       'position',[380 0 50 30],'tooltipstring','Terminate the session');  
 m=uicontrol('style','pushbutton', 'callback','sroi_make_diff_image2',...
      'position',[300 0 50 30],'string','Diff Movie',...
      'tooltipstring','Makes the difference pre-bleach/post bleach image');
 m=uicontrol('style','pushbutton', 'callback','sroi_small_area_zeiss',...
      'position',[51 31 50  30],'string','Choose',...
      'tooltipstring','Makes the difference pre-bleach/post bleach image');
  ee=uicontrol('tag','fff','string','Subtract',...
       'style','pushbutton','callback','sroi_2_3',...
       'position',[0 30 50 30],'tooltipstring','write the line');  

   
slide=uicontrol('tag','fff','style','slider','callback','sroi_slider',...
      'position',[101 0 100 30],'min',q,'max',s,...
      'sliderstep',[1/s 5/s]);
  
slide2=uicontrol('tag','fff','style','slider','callback','sroi_slider2',...
      'position',[351 0 100 30],'min',0,'max',0.5,...
      'sliderstep',[0.01 0.1],'tooltipstring','cutoff'); 
    
  set(slide,'value',q);
set(slide2,'value',0.1);
  
  hh=get(slide2,'value');
    textul=strcat(num2str(hh));
    text(10,10,'@','color',[0.7 0.7 0.7],'BackgroundColor',[0.7 0.7 0.7]);
    text(10,10,textul,'FontSize',10,'EdgeColor','b','color','b','BackgroundColor',[0.7 0.7 0.7]);
  
     m=uicontrol('style','text', 'position',[101 31 100 15],'string','Stepper');
   m=uicontrol('style','text', 'position',[351 31 100 15],'string','Threshold');

 
inner_radius=10;
outer_radius=30;
zz=[];
iii=0;jjj=1;
ijj=1;
backmatrix=[];
autos=[];
hex=[]; hey=[]; xxes=[]; yyes=[];
xx=[]; yy=[]; zz=[];
set(gcf,'windowbuttondownfcn','sroi_00y');
%set(gcf,'windowbuttonupfcn','sroi_2');
