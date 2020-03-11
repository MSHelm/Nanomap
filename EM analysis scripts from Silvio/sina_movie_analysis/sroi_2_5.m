function sroi_2_5;

global list mapname b movi rows cols A i xx yy zz iii bbb q s ijj jjj r firstred olds inner_radius outer_radius matrix backmatrix autos 
global cellb slide xxes yyes hex hey movib slide_track num_mat xmatrix ymatrix


 xmatrix=[];
 ymatrix=[];

[stat, mess]=fileattrib('*xmatrix*.txt');
if stat==1
    xmatrix=dlmread(strcat('xmatrix',num2str(numel(mess)),'.txt'));
    ymatrix=dlmread(strcat('ymatrix',num2str(numel(mess)),'.txt'));
end;
    
num_mat=[];


siz=size(xmatrix);

 planex=xmatrix(:,1);
    planey=ymatrix(:,1);
    
    ccc=find(planex>0 & planey>0);
    
    planex=planex(ccc);
    planey=planey(ccc);

for j=1:numel(planex)
    num_mat(j,1)=j;
end;

pre_planex=planex;
pre_planey=planey;

for klm=2:siz(2)
    
    
    planex=xmatrix(:,klm);
    planey=ymatrix(:,klm);
    ccc=find(planex>0 & planey>0);
    planex=planex(ccc);
    planey=planey(ccc);
    
    num_mat(1:numel(planex),klm)=0;
    
    
    mean_distx=[];
    for k=1:numel(planex)
x=planex(k);
y=planey(k);
    distx=[];disty=[];
    
    xxxx=[1:1:numel(planex)];
    ccc=find(xxxx>k | xxxx<k);
    distx=planex(ccc);
    disty=planey(ccc);
    
    distx(:)=distx(:)-x;
    disty(:)=disty(:)-y;
    distx(:)=distx(:).^2;
    disty(:)=disty(:).^2;
    distx=distx+disty;
    distx(:)=sqrt(distx(:));
mean_distx(k)=min(min(distx));
end;
    mean_distance=mean(mean_distx);
    
    
    
    
    for k=1:numel(pre_planex)
x=pre_planex(k);
y=pre_planey(k);
    distx=[];disty=[];
    distx=planex;
    disty=planey;
    distx(:)=distx(:)-x;
    disty(:)=disty(:)-y;
    distx(:)=distx(:).^2;
    disty(:)=disty(:).^2;
    distx=distx+disty;
    distx(:)=sqrt(distx(:));
mmm=min(min(distx));

if mmm<mean_distance
ccc=find(distx==mmm);
number=ccc(1);
num_mat(number,klm)=num_mat(k,klm-1);
else
    num_mat(number,klm)=0;
end;
end;

ccc=find(num_mat(1:numel(planex),klm)==0)
if numel(ccc)>0
for i=1:numel(ccc)
    num_mat(ccc(i),klm)=max(max(num_mat))+1;
end;
end;


pre_planex=planex;
pre_planey=planey;


end;

dlmwrite(strcat('num_mat',num2str(numel(mess)),'.txt'),num_mat);

figure;axis equal;

slide_track=uicontrol('tag','fff','style','slider','callback','sroi_slider_track',...
      'position',[101 0 100 30],'min',1,'max',max(max(num_mat)),...
      'sliderstep',[1/max(max(num_mat)) 5/max(max(num_mat))],'tooltipstring','cutoff');

set(slide_track,'value',1);
sroi_slider_track;
% himg=image(movib(:,:,q),'cdatamapping','scaled'); axis equal;
% b=uicontrol('tag','fff','string','Play',...
%       'style','pushbutton','callback','second_play',...
%       'position',[50 0 50 30],'tooltipstring','play movie');
%   
%   b=uicontrol('tag','fff','string','Tracks',...
%       'style','pushbutton','callback','sroi_2_5',...
%       'position',[0 0 50 30],'tooltipstring','Generate the tracking');
%  
  
    
    figure; sroi_2_6;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    