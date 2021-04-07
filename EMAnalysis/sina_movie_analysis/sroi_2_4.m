function sroi_2

global list mapname b movi rows cols A i xx yy zz iii bbb q s ijj jjj r firstred olds inner_radius outer_radius matrix backmatrix autos 
global cellb slide xxes yyes hex hey movib

movib=[];
siz=size(movi(:,:,1));
 % redfilter=highpassfilter([siz(1), siz(2)],0.1,10);
 xmatrix=[];
 ymatrix=[];

for klm=q:s
    
klm

% F = fft2(double(movi(:,:,klm)));
%  G=redfilter.*F;
%  g=real(ifft2(G));
% minim=min(min(g));
% g(:,:)=g(:,:)-minim;
% maxim=max(max(g));
% g=g*511/maxim;
% 
% movib(:,:,klm)=g;
% 
    H=fspecial('average',10);
    movib(:,:,klm)=imfilter(movi(:,:,klm),H,'replicate');
  
  
background=imopen(movib(:,:,klm),strel('disk',5));
movib(:,:,klm)=imsubtract(movi(:,:,klm),background);

movib(:,:,klm)=movib(:,:,klm)-mean2(movib(:,:,klm))-std2(movib(:,:,klm));
a=movib(:,:,klm);
ccc=find(a<0);
a(ccc)=0;
movib(:,:,klm)=a;

movib(:,:,klm)=bwlabel(movib(:,:,klm));
movib(:,:,klm)=bwmorph(movib(:,:,klm),'clean');
movib(:,:,klm)=bwlabel(movib(:,:,klm));


for i=1:max(max(movib(:,:,klm)))
    ccc=find(movib(:,:,klm)==i);
    
     if numel(ccc)>30
        a(ccc)=a(ccc)-mean(a(ccc))-0.5*std(a(ccc));
     end;
end;
ccc=find(a<0);a(ccc)=0;

movib(:,:,klm)=a;
movib(:,:,klm)=bwlabel(movib(:,:,klm));
movib(:,:,klm)=bwmorph(movib(:,:,klm),'clean');
movib(:,:,klm)=bwlabel(movib(:,:,klm));


se = strel('disk',1); 
movib(:,:,klm)=imdilate(movib(:,:,klm),se);

bw=movib(:,:,klm);
 bluex=[];bluey=[];
 for i=1:max(max(bw))
         ccc=find(bw==i);
         siz=size(bw);
         [xx yy]=ind2sub([siz(1) siz(2)],ccc);
         old_redimg=movi(:,:,klm);
         mm=old_redimg(ccc);
         bluex(numel(bluex)+1)=sum(xx.*mm)/sum(mm);
         bluey(numel(bluey)+1)=sum(yy.*mm)/sum(mm);
         
 end;
xmatrix(1:numel(bluex),klm)=bluex;
ymatrix(1:numel(bluey),klm)=bluey;


end;

[stat, mess]=fileattrib('*xmatrix*.txt')
if stat==0
    dlmwrite(strcat('xmatrix1.txt'),xmatrix);
    dlmwrite(strcat('ymatrix1.txt'),ymatrix);
else
      dlmwrite(strcat('xmatrix',num2str(numel(mess)+1),'.txt'),xmatrix);
      dlmwrite(strcat('ymatrix',num2str(numel(mess)+1),'.txt'),ymatrix);
end;
    


figure;
colormap(jet);
himg=image(movib(:,:,q),'cdatamapping','scaled'); axis equal;
b=uicontrol('tag','fff','string','Play',...
      'style','pushbutton','callback','second_play',...
      'position',[50 0 50 30],'tooltipstring','play movie');
  
  b=uicontrol('tag','fff','string','Tracks',...
      'style','pushbutton','callback','sroi_2_5',...
      'position',[0 0 50 30],'tooltipstring','Generate the tracking');
 
  
  
