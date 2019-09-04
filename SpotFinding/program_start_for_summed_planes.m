function vesan (cd_path,imnr1,imnr2);

global movi rr xx yy filename chol b2 Movi3 pixel_size image_matrix positioner pixel_size limits
global list mapname b rows cols A q s ijj jjj r1 firstred olds inner_radius outer_radius matrix backmatrix old_movi number2
global alignsx alignsy rect fused not_fused sh hex hey rr1 imagenr sections %movi2


addpath(genpath('Z:\user\mhelm1\Nanomap_Analysis\Matlab\SpotFinding'));

cd(cd_path);

% cd 'Y:\user\mhelm1\Nanomap_Analysis\Replicate1\Syntaxin2_2015-10-19';
% 
% number1=4;
% number2=5;

number1=imnr1;
number2=imnr2;


q=1; s=4; sections=7;

limits=[3 3 3];
movi=[];
positioner=0;

imagenr=1;

[stat, mess]=fileattrib(strcat('*Series',num2str(number1),'_z*_ch0.tif'));
[blub,order]=sort({mess.Name});mess=mess(order);order=[];
a=[]; a=double(imread(mess(1).Name));
% for i=2:numel(mess)
%     a=a+double(imread(mess(i).Name));
% end;
% a=a/numel(mess); 
movi(:,:,1)=a;


[stat, mess]=fileattrib(strcat('*Series',num2str(number1),'_z*_ch1.tif'));
[blub,order]=sort({mess.Name});mess=mess(order);order=[];
a=[]; a=double(imread(mess(1).Name));
% for i=2:numel(mess)
%     a=a+double(imread(mess(i).Name));
% end;
% a=a/numel(mess); 
movi(:,:,2)=a;


[stat, mess]=fileattrib(strcat('*Series',num2str(number1),'_z*_ch2.tif'));
[blub,order]=sort({mess.Name});mess=mess(order);order=[];
a=[]; a=double(imread(mess(1).Name));
% for i=2:numel(mess)
%     a=a+double(imread(mess(i).Name));
% end;
% a=a/numel(mess); 
movi(:,:,3)=a;


[sstat, mmess]=fileattrib(strcat('*Series',num2str(number2),'_z*_ch0.tif'));
[blub,order]=sort({mmess.Name});mmess=mmess(order);order=[];

movi(:,:,4)=double(imread(mmess(imagenr).Name));

% movi2=[];
% for i=2:numel(mmess)
%     movi2(:,:,i-1)=double(imread(mmess(i).Name));
% end;


pixel_size=20.20; %input('What is the pixel size ?');
        
 rr=mmess(imagenr).Name
% r4=mmess(imagenr+sections).Name
% 
%         r1=strcat(rr(1:numel(rr)-5),'0.tif');
%         
%         r2=strcat(rr(1:numel(rr)-5),'1.tif');
%         
%         r3=strcat(rr(1:numel(rr)-5),'2.tif');
%         
% 
         filename=strcat(rr(1:numel(rr)-4));
         rr1=filename;
         filename=strcat(rr(1:numel(rr)-4),'.txt');
%         
% movi=[];
% 
% movi(:,:,1)=imread(r1);
% movi(:,:,2)=imread(r2);
% movi(:,:,3)=imread(r3);
% movi(:,:,4)=imread(r4);

old_movi=movi;

sizz=size(movi);

% 
% Mim = figure('toolbar','figure');  colormap(hot(255));
% scrsize=get(0, 'ScreenSize');
% set(Mim, 'Position', [300 500 scrsize(3)/3 scrsize(4)*2/3]);
% fsize=get(Mim,'Position');

f = figure('WindowScrollWheelFcn',@figScroll);
drawnow;
set(get(handle(gcf),'JavaFrame'),'Maximized',1);
    function figScroll(src,callbackdata)
          if callbackdata.VerticalScrollCount > 0 
             step();
          elseif callbackdata.VerticalScrollCount < 0 
            stepback();
          end
       end


STED=image(movi(:,:,sizz(3)),'tag','him','cdatamapping','scaled'); axis square; colormap(hot)

 
 

b=uicontrol('tag','ddd','style','pushbutton','callback','sroi_undo',...
            'position',[100 31 100 30],...
            'string','Undo');         
     
m=uicontrol('style','pushbutton', 'callback','sroi_align',...
      'position',[0 0 50 30],'string','align');
 
 dd=uicontrol('string','Step',...
       'style','pushbutton','callback','step',...
       'position',[100 0 50 30]);
 ee=uicontrol('string','Stepback',...
       'style','pushbutton','callback','stepback',...
       'position',[150 0 50 30]);

m=uicontrol('style','pushbutton', 'callback','sroi_hand_align',...
      'position',[300 0 70 30],'string','Manual align');
 
 m=uicontrol('style','pushbutton', 'callback','sroi_next_for_summed_planes',...
      'position',[400 0 70 30],'string','Next');
 m=uicontrol('style','pushbutton', 'callback','use_limits',...
      'position',[500 0 70 30],'string','Use old limits');
    
% sh=uicontrol('Style', 'slider','Callback',@lut,'Max', 255, 'Min',0,'Value',255,...
% 'SliderStep',[0.025 0.1], 'Position', [550 0 100 30]);


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
end
%sroi_align;