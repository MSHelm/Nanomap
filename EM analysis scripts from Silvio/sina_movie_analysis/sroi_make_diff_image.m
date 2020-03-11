function sroi_make_diff_image;

global movi s q movib
global cellb slide xxes yyes hex hey thefolder

movib=[];

for klm=q:s
    klm
 
background=imopen(movi(:,:,klm),strel('disk',10));
movib(:,:,klm)=imsubtract(movi(:,:,klm),background);



 
ccc=find(movib(:,:,klm)<(mean2(movib(:,:,klm))+std2(movib(:,:,klm))));
a=movib(:,:,klm);
a(ccc)=0;
movib(:,:,klm)=a;

bw=bwlabel(movib(:,:,klm));
bw=bwmorph(bw,'clean');
bw=bwlabel(bw);

bw_reg=regionprops(bw);
aareas=struct2cell(bw_reg);
sizul=size(aareas);
c=[];
for j=1:sizul(2)
    c(j)=aareas{1,j};
end;    

ccc=find(c>300);

bw2=bw; bw2=bw2-bw;
for i=1:numel(ccc)
    ddd=find(bw==ccc(i));
    bw2(ddd)=1;
end;





movib(:,:,klm)=bw2;
end;

% 
% siz=size(movi);
% 
% a=movi(:,:,1)-movi(:,:,2);
% 
% movib=[];
% for i=2:siz(3)
%     i
%     movib(:,:,i-1)=movi(:,:,i)-movi(:,:,i-1);
%     ccc=find(movib<0);
%     movib(ccc)=0;
%     
% end;

figure;
colormap(jet);
himg=image(movib(:,:,q),'cdatamapping','scaled'); axis equal;
b=uicontrol('tag','fff','string','Play',...
      'style','pushbutton','callback','second_play',...
      'position',[50 0 50 30],'tooltipstring','play movie');
  
  
  m=uicontrol('tag','get','style','pushbutton', 'callback',{@sroi_check_membrane},...
      'position',[0 0 50 30],'string','Membr.',...
      'tooltipstring','Whole terminal');
  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sroi_check_membrane(source,eventdata)

global cellb slide xxes yyes hex hey thefolder
global movi s q movib 

 sizeul=size(movi);

value=[];back=[];
 
 for j=1:sizeul(3)
      bbb=find(movib(:,:,j)>0);
      A=movi(:,:,j);
     
      back(j)=mean2(A(hey-10:hey+10,hex-10:hex+10));
      if numel(bbb)>0
      value_array=A(bbb);

     ccc=find(value_array>(mean2(back)+2*std2(back)));
     value_array=value_array(ccc);

     value(j)=mean(value_array);
      else
          value(j)=back(j);
      end;
      
 end;
figure;
values=[];
values(:,1)=value';
values(:,2)=back';
values(:,3)=value'-back';

vvalues=[]; vvalues=values(:,3);
ccc=find(vvalues);
vvalues(1)=vvalues(ccc(1));
values(:,3)=vvalues;

siz=size(values);
for j=2:siz(1)
    if values(j,3)==0
        values(j,3)=values(j-1,3);
    end;
end;        

plot(values(:,3))

[stat, mess]=fileattrib('*membrane*.txt')
if stat==0
    dlmwrite(strcat('membrane1.txt'),values);
else
      dlmwrite(strcat('membrane',num2str(numel(mess)+1),'.txt'),values);
end;
    
      
end
  
    