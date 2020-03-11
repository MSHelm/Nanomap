function sroi_make_diff_image2;

global movi s q movib
global cellb slide xxes yyes hex hey thefolder slide2

movib=[];
if numel(hex)>0
for klm=s:-1:q
    klm
 

    movib(:,:,klm)=movi(:,:,klm);
 

H=fspecial('average',5);
movib(:,:,klm)=imfilter(movib(:,:,klm),H,'replicate');

background=movib(hey-10:hey+10,hex-10:hex+10,klm);

%ccc=find(movib(:,:,klm)<(mean2(background)+std2(background)*2));
cccm=find(movib(:,:,klm));
aa=movib(:,:,klm);
movib_linear=aa(cccm);
histom=hist(movib_linear,[0:10:4000]);
histo_dist=[0:10:3999];
histom=histom(1:numel(histom)-1);
ccc=max(histom);
ddd=find(histom==ccc);
%plot(histom);drawnow;
%dlmwrite(strcat('xxx',num2str(klm),'.txt'),histom');
ddd=ddd(1);
fraction=get(slide2,'value');
eee=find(histom<fraction*max(histom) & histo_dist>ddd*10);

eee=mean(eee(1:10));



ccc=find(movib(:,:,klm)<(eee*10));


a=movib(:,:,klm);
a(ccc)=0;
movib(:,:,klm)=a;

bw=im2bw(movib(:,:,klm));
%bw=bwperim(bw);
bw=bwmorph(bw,'clean');
bw=bwlabel(bw);

bw_reg=regionprops(bw);
aareas=struct2cell(bw_reg);
sizul=size(aareas);
c=[];
for j=1:sizul(2)
    c(j)=aareas{1,j};
end;    

ccc=find(c==max(c));

bw2=bw; bw2=bw2-bw;
for i=1:numel(ccc)
    ddd=find(bw==ccc(i));
    bw2(ddd)=1;
end;

imagesc(bw2); drawnow;

bw2 = imfill(bw2,'holes');

imagesc(bw2); drawnow;

se = strel('disk',10);        
erodedBW = imerode(bw2,se);

ccc=find(bw2==1 & erodedBW==0);
bw2=bw2-bw2;
bw2(ccc)=1;


ccc=find(bw2==1);

movib(:,:,klm)=movi(:,:,klm);

aa=movib(:,:,klm);
aa(ccc)=max(max(aa))+1;

movib(:,:,klm)=aa;

%movib(:,:,klm)=bw2;



end;
movi=[];
movi=movib;

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
 else
     figure; text(0.3,0.5, 'Define background area');
     pause(1);
     close;
 end; 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sroi_check_membrane(source,eventdata)

global cellb slide xxes yyes hex hey thefolder
global movi s q movib 

 sizeul=size(movi);

value=[];back=[];


    
 for j=1:sizeul(3)
     
      bbb=find(movib(:,:,j)==max(max(movib(:,:,j))));
      A=movi(:,:,j);
     
      back(j)=mean2(A(hey-10:hey+10,hex-10:hex+10));
      if numel(bbb)>0
     value_array=A(bbb);
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

siz=size(values);
for j=2:siz(1)
    if values(j,3)==0
        values(j,3)=values(j-1,3);
    end;
end;        

plot(values(:,3))
hex=[]; hey=[];

cd(thefolder);
[stat, mess]=fileattrib('*membrane*.txt')

if stat==0
    dlmwrite(strcat('membrane1.txt'),values);
else
      dlmwrite(strcat('membrane',num2str(numel(mess)+1),'.txt'),values);
end;

end
  
    