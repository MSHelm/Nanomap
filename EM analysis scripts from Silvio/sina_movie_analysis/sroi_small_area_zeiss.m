function sroi_small_area;

global movi q s cellb slide slide2

 [pos1]=round(getrect);
 xx=pos1(1); yy=pos1(2);wd=pos1(3);ht=pos1(4);
 rectangle('position',pos1,'edgecolor','w')

%  F=getframe(gcf);
%  [aF,mmap]=frame2im(F);
%  max(max(aF))
%  cF=[];
%  cF(:,:,1)=double(aF(:,:,1))*1/255;
%  cF(:,:,2)=double(aF(:,:,2))*1/255;
%  cF(:,:,3)=double(aF(:,:,3))*1/255;
%  imwrite(aF,strcat(rr,'_',num2str(positioner),'_click.jpg'),'jpg'); 


if s<20
    movi=[];
small_movi=[];
s=numel(cellb)
for klm=q:s
    klm
     name=cellb{klm};

    movi=imread(name);
     small_movi(:,:,klm)=movi(yy:yy+ht,xx:xx+wd);
    himg=image(small_movi(:,:,klm),'cdatamapping','scaled'); axis equal;drawnow;
end;

movi=[];
movi=small_movi;
siz=size(movi);
q=1;
s=siz(3)


else
    small_movi=[];
    for klm=q:s
    klm
    small_movi(:,:,klm)=movi(yy:yy+ht,xx:xx+wd,klm);
    himg=image(small_movi(:,:,klm),'cdatamapping','scaled'); axis equal;drawnow;
    end;
    
movi=[];
movi=small_movi;
siz=size(movi);
q=1;
s=siz(3)
end;


 slide=uicontrol('tag','fff','style','slider','callback','sroi_slider',...
       'position',[101 0 100 30],'min',q,'max',s,...
       'sliderstep',[1/s 5/s],'tooltipstring','cutoff');
   
  
  set(slide,'value',q);
%splay;

