function empic

global movi xx yy A counter tipul culoare numar r background inverter
global switcher image_number valoare values_string deleter
global countter axx ayy newfig smart_values halfx halfy new_movi contrastor contrastor2

cd 'Z:\user\mhelm1\Biochemistry\Dot Blots\2019-05-13_quantitative dot blot 10 proteins';
%normal gels benni: %halfx=60; %halfy=30;%%%%%% 40 for smaller, 60 for bigger gels

halfx=20; %%% vertical
halfy=20; %%% lateral


dir *.tif;
r=input('What file      ','s');
qqq=('.tif');
r1=strcat(r,qqq);
xx=[]; yy=[];

inverter=1;
switcher=0; 
numar=0;
numar_p=0;
numar_b=0;
background=0;
deleter=1;

smart_values=[];

values_string =[];

   info=imfinfo(r1);
   
      bitdepth = info.BitDepth;
      switch bitdepth
      case 8
         movi = uint8(0);
         
         A=uint8(0);
      case 16
         movi = uint16(0);
         A=uint16(0);
      end
        


xmovi = imread(r1);
if numel(size(xmovi))>2
    movi=rgb2gray(xmovi);
else
    movi=xmovi;
end;
    
    ccc=find(movi>60000);
    cccx=find(movi>10 & movi<60000);  movi(ccc)=mean(movi(cccx));
%movi=rot90(movi);
 
A=movi;
new_movi=movi;
 

min(min(movi))
max(max(movi))




   %%%%%%%%%% MAKE FIGURE (minimum size = minpix)

  colormap('gray');
   
himg=image(movi(:,:),'tag','him','cdatamapping','scaled');axis equal;
  
cleaning=uicontrol('tag','clense','style','pushbutton', 'callback','empic_write',...
      'position',[0 0 70 30],'string','clean','tooltipstring','erase all drawings');

new_back=uicontrol('tag','newback','style','pushbutton', 'callback','empic_backgr',...
      'position',[70 0 140 30],'string','New background','tooltipstring','draw a new background area');
  
undoing=uicontrol('tag','undoes','style','pushbutton', 'callback','empic_undo',...
      'position',[210 0 70 30],'string','Undo last','tooltipstring','eliminates the last saved value');

fliph=uicontrol('tag','undoes','style','pushbutton', 'callback','empic_fliph',...
      'position',[300 0 70 30],'string','Horiz. flip','tooltipstring','flips image horizontally');
  
flipv=uicontrol('tag','undoes','style','pushbutton', 'callback','empic_flipv',...
      'position',[400 0 70 30],'string','Vert. flip','tooltipstring','flips image vertically');
  
      flipv=uicontrol('tag','invertgreylevels','style','pushbutton', 'callback','empic_invert',...
      'position',[500 0 70 30],'string','Invert','tooltipstring','invert grey levels');
        
contrastor=uicontrol('tag','fff',...
      'style','slider','callback','sgetline_contrast',...
      'position',[0 31 100 30],'min',min(min(movi)),'max',max(max(movi)),...
      'sliderstep',[0.001 0.01],'tooltipstring','cutoff');       
 
 set(contrastor,'value',mean2(movi));
   
  
  contrastor2=uicontrol('tag','fff',...
      'style','slider','callback','sgetline_contrast',...
      'position',[0 61 100 30],'min',min(min(movi)),'max',max(max(movi)),...
      'sliderstep',[0.001 0.01],'tooltipstring','cutoff');      
    
set(contrastor2,'value',max(max(movi)));
  
set(gcf,'windowbuttondownfcn','empic1');

