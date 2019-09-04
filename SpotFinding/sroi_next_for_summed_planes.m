function sroi_next;

global movi rr xx yy filename chol b2 Movi3 pixel_size image_matrix positioner pixel_size limits
global list mapname b rows cols A q s ijj jjj r1 firstred olds inner_radius outer_radius matrix backmatrix old_movi number2
global alignsx alignsy rect fused not_fused sh hex hey rr1 imagenr sections


[sstat, mmess]=fileattrib(strcat('*Series',num2str(number2),'*_ch0.tif'));;

numel(mmess)
imagenr=imagenr+1
positioner=0;
 hex=[]; hey=[];
 values_matrix=[];
 
if imagenr<=numel(mmess)


[sstat, mmess]=fileattrib(strcat('*Series',num2str(number2),'_z*_ch0.tif'));
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
%sroi_align; 
else
      close all;
%      [stat, mess]=fileattrib('*_distances.txt');
%  
%  values=[];
%  
%  for i=1:numel(mess)
%      val=dlmread(mess(i).Name);
%      if numel(val)>0
%      values=cat(1,values,val);
%      end;
%  end;
% dlmwrite('values_matrix.txt',values');
% 
% x=[0:5:2000];
% azs=hist(values(:,1),x); azs=azs*100/sum(azs);
% ves=hist(values(:,2),x); ves=ves*100/sum(ves);
%   
% hist_mat=[]; hist_mat(:,1)=x'; hist_mat(:,2)=azs'; hist_mat(:,3)=ves';
% 
% dlmwrite('histogram_matrix.txt',hist_mat);
%address_spots;

  
end;