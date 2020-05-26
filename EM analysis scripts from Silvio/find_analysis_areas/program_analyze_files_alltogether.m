function address_spots;

%%%%%this folder shouldcontain subfolders for the individual experiments,
%%%%%and the file model.tif
 thefolder='F:\data_2012\katharina_new_analysis';cd(thefolder);initiala=double(imread('model.tif'));
a=dir; a=struct2cell(a); siza=size(a); a=a(:,3:siza(2)); siza=size(a); a2={}; for i=1:siza(2); if a{4,i}==1; a2{numel(a2)+1}=a{1,i}; end; end; a=a2; 
foldernames=a;

size_limit=100;

for folders=1:numel(foldernames)
    cd(strcat(thefolder,'\',foldernames{folders}));
a=dir; a=struct2cell(a); siza=size(a); a=a(:,3:siza(2)); siza=size(a); a2={}; for i=1:siza(2); if a{4,i}==1; a2{numel(a2)+1}=a{1,i}; end; end; a=a2; 
foldernames2=a;


counter=1;matcounter=0;
matrix=zeros(2*size_limit+1,2*size_limit+1); redx=matrix; greenx=matrix; stedx=matrix;
%%%%matrix(round(size_limit/3):size_limit,round(size_limit/4):size_limit+round(size_limit/4)+1)=1;
red=initiala;
sted=initiala;

for abcdef=1:numel(foldernames2);
    strcat(thefolder,'\',foldernames{folders})
    cd(strcat(thefolder,'\',foldernames{folders}));
    name=foldernames2{abcdef}
    cd(name);
    try;
cd 'IHC';
  
close all; [stat, mess]=fileattrib('*_STEDspot.txt');
if stat==1
    for klm=1:numel(mess)
matrix=dlmread(mess(klm).Name); 
green2=matrix(1:2*size_limit+1,1:2*size_limit+1);
red2=matrix(1:2*size_limit+1,2*size_limit+2:4*size_limit+2);
sted2=matrix(1:2*size_limit+1,4*size_limit+3:6*size_limit+3);
    %%%%%%%%%%%%%%%turn around
for klmmm=1:72
    aa=imrotate(red2,klmmm*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit);
    %bb=imrotate(sted2,klmmm*5); siz=size(bb);half=round(siz(1)/2); bb=bb(half-size_limit:half+size_limit,half-size_limit:half+size_limit);
    minima(klmmm)=corr2(aa(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2),red(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2));%*...
      %  corr2(bb(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2),sted(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2));    
end;
%%%%%%%%%%%%%%flip
for klmmm=1:72
    aa=imrotate(flipud(red2),klmmm*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit);
    %bb=imrotate(flipud(sted2),klmmm*5); siz=size(bb);half=round(siz(1)/2); bb=bb(half-size_limit:half+size_limit,half-size_limit:half+size_limit);
    minima(klmmm+72)=corr2(aa(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2),red(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2));%*...
      %  corr2(bb(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2),sted(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2));
end;
 ccc=find(minima==max(max(minima)));
try
pos=ccc(1);
catch
end;
if pos<72
     aa=imrotate(red2,pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); red2=aa;
     aa=imrotate(sted2,pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); stedc2=aa; 
     aa=imrotate(green2,pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); green2=aa;
else
    aa=imrotate(flipud(red2),pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); red2=aa;
    aa=imrotate(flipud(sted2),pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); sted2=aa;
    aa=imrotate(flipud(green2),pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); green2=aa;
end;
counter=counter+1;redx=(redx+red2);greenx=(greenx+green2);stedx=(stedx+sted2);
end;end;  catch; end;end
  cd(strcat(thefolder,'\',foldernames{folders}));

dlmwrite('IHCallSTED_active_zone_matrix_by_both.txt',greenx/counter);
dlmwrite('IHCallSTED_Green_matrix_by_both.txt',redx/counter);
dlmwrite('IHCallSTED_POI_matrix_by_both.txt',stedx/counter); 
imwrite(uint16(round(greenx/counter)),'IHCallSTED_active_zone_matrix_by_both.tif','tif','Compression','none');
imwrite(uint16(round(redx/counter)),'IHCallSTED_Green_matrix_by_both.tif','tif','Compression','none');
imwrite(uint16(round(stedx/counter)),'IHCallSTED_POI_matrix_by_both.tif','tif','Compression','none');
%%%figure;
  subplot(1,3,1); imagesc(greenx/counter); axis equal;
  subplot(1,3,2); imagesc(redx/counter); axis equal;
  subplot(1,3,3); imagesc(stedx/counter); axis equal;
end;











for folders=1:numel(foldernames)
    cd(strcat(thefolder,'\',foldernames{folders}));
a=dir; a=struct2cell(a); siza=size(a); a=a(:,3:siza(2)); siza=size(a); a2={}; for i=1:siza(2); if a{4,i}==1; a2{numel(a2)+1}=a{1,i}; end; end; a=a2; 
foldernames2=a;


counter=1;matcounter=0;
matrix=zeros(2*size_limit+1,2*size_limit+1); redx=matrix; greenx=matrix; stedx=matrix;
%%%%matrix(round(size_limit/3):size_limit,round(size_limit/4):size_limit+round(size_limit/4)+1)=1;
red=initiala;
sted=initiala;

for abcdef=1:numel(foldernames2);
    cd(strcat(thefolder,'\',foldernames{folders}));
    name=foldernames2{abcdef}; cd(name);
   
    try;
cd 'Syn';
  
close all; [stat, mess]=fileattrib('*_STEDspot.txt');
if stat==1
    for klm=1:numel(mess)
matrix=dlmread(mess(klm).Name); 
green2=matrix(1:2*size_limit+1,1:2*size_limit+1);
red2=matrix(1:2*size_limit+1,2*size_limit+2:4*size_limit+2);
sted2=matrix(1:2*size_limit+1,4*size_limit+3:6*size_limit+3);
    %%%%%%%%%%%%%%%turn around
for klmmm=1:72
    aa=imrotate(red2,klmmm*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit);
    %bb=imrotate(sted2,klmmm*5); siz=size(bb);half=round(siz(1)/2); bb=bb(half-size_limit:half+size_limit,half-size_limit:half+size_limit);
    minima(klmmm)=corr2(aa(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2),red(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2));%*...
      %  corr2(bb(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2),sted(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2));    
end;
%%%%%%%%%%%%%%flip
for klmmm=1:72
    aa=imrotate(flipud(red2),klmmm*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit);
    %bb=imrotate(flipud(sted2),klmmm*5); siz=size(bb);half=round(siz(1)/2); bb=bb(half-size_limit:half+size_limit,half-size_limit:half+size_limit);
    minima(klmmm+72)=corr2(aa(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2),red(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2));%*...
      %  corr2(bb(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2),sted(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2));
end;
 ccc=find(minima==max(max(minima)));
try
pos=ccc(1);
catch
end;
if pos<72
     aa=imrotate(red2,pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); red2=aa;
     aa=imrotate(sted2,pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); stedc2=aa; 
     aa=imrotate(green2,pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); green2=aa;
else
    aa=imrotate(flipud(red2),pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); red2=aa;
    aa=imrotate(flipud(sted2),pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); sted2=aa;
    aa=imrotate(flipud(green2),pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); green2=aa;
end;
counter=counter+1;redx=(redx+red2);greenx=(greenx+green2);stedx=(stedx+sted2);
end;end;
  catch; end;end;  cd(strcat(thefolder,'\',foldernames{folders}));
dlmwrite('SynallSTED_active_zone_matrix_by_both.txt',greenx/counter);
dlmwrite('SynallSTED_Green_matrix_by_both.txt',redx/counter);
dlmwrite('SynallSTED_POI_matrix_by_both.txt',stedx/counter); 
imwrite(uint16(round(greenx/counter)),'SynallSTED_active_zone_matrix_by_both.tif','tif','Compression','none');
imwrite(uint16(round(redx/counter)),'SynallSTED_Green_matrix_by_both.tif','tif','Compression','none');
imwrite(uint16(round(stedx/counter)),'SynallSTED_POI_matrix_by_both.tif','tif','Compression','none');
%%%figure;
  subplot(1,3,1); imagesc(greenx/counter); axis equal;
  subplot(1,3,2); imagesc(redx/counter); axis equal;
  subplot(1,3,3); imagesc(stedx/counter); axis equal;
end;









for folders=1:numel(foldernames)
    cd(strcat(thefolder,'\',foldernames{folders}));
a=dir; a=struct2cell(a); siza=size(a); a=a(:,3:siza(2)); siza=size(a); a2={}; for i=1:siza(2); if a{4,i}==1; a2{numel(a2)+1}=a{1,i}; end; end; a=a2;
foldernames2=a;


counter=1;matcounter=0;
matrix=zeros(2*size_limit+1,2*size_limit+1); redx=matrix; greenx=matrix; stedx=matrix;
%%%%matrix(round(size_limit/3):size_limit,round(size_limit/4):size_limit+round(size_limit/4)+1)=1;
red=initiala;
sted=initiala;

for abcdef=1:numel(foldernames2);
    cd(strcat(thefolder,'\',foldernames{folders}));
    name=foldernames2{abcdef}; cd(name);
   
    try;
cd 'IHC';
  
close all; [stat, mess]=fileattrib('*_confocalspot.txt');
if stat==1
    for klm=1:numel(mess)
matrix=dlmread(mess(klm).Name); 
green2=matrix(1:2*size_limit+1,1:2*size_limit+1);
red2=matrix(1:2*size_limit+1,2*size_limit+2:4*size_limit+2);
sted2=matrix(1:2*size_limit+1,4*size_limit+3:6*size_limit+3);
    %%%%%%%%%%%%%%%turn around
for klmmm=1:72
    aa=imrotate(red2,klmmm*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit);
    %bb=imrotate(sted2,klmmm*5); siz=size(bb);half=round(siz(1)/2); bb=bb(half-size_limit:half+size_limit,half-size_limit:half+size_limit);
    minima(klmmm)=corr2(aa(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2),red(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2));%*...
      %  corr2(bb(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2),sted(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2));    
end;
%%%%%%%%%%%%%%flip
for klmmm=1:72
    aa=imrotate(flipud(red2),klmmm*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit);
    %bb=imrotate(flipud(sted2),klmmm*5); siz=size(bb);half=round(siz(1)/2); bb=bb(half-size_limit:half+size_limit,half-size_limit:half+size_limit);
    minima(klmmm+72)=corr2(aa(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2),red(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2));%*...
      %  corr2(bb(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2),sted(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2));
end;
 ccc=find(minima==max(max(minima)));
try
pos=ccc(1);
catch
end;
if pos<72
     aa=imrotate(red2,pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); red2=aa;
     aa=imrotate(sted2,pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); stedc2=aa; 
     aa=imrotate(green2,pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); green2=aa;
else
    aa=imrotate(flipud(red2),pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); red2=aa;
    aa=imrotate(flipud(sted2),pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); sted2=aa;
    aa=imrotate(flipud(green2),pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); green2=aa;
end;
counter=counter+1;redx=(redx+red2);greenx=(greenx+green2);stedx=(stedx+sted2);
end;end; catch; end;end;  cd(strcat(thefolder,'\',foldernames{folders}));
dlmwrite('IHCallconfocal_active_zone_matrix_by_both.txt',greenx/counter);
dlmwrite('IHCallconfocal_Green_matrix_by_both.txt',redx/counter);
dlmwrite('IHCallconfocal_POI_matrix_by_both.txt',stedx/counter); 
imwrite(uint16(round(greenx/counter)),'IHCallconfocal_active_zone_matrix_by_both.tif','tif','Compression','none');
imwrite(uint16(round(redx/counter)),'IHCallconfocal_Green_matrix_by_both.tif','tif','Compression','none');
imwrite(uint16(round(stedx/counter)),'IHCallconfocal_POI_matrix_by_both.tif','tif','Compression','none');
%%%figure;
  subplot(1,3,1); imagesc(greenx/counter); axis equal;
  subplot(1,3,2); imagesc(redx/counter); axis equal;
  subplot(1,3,3); imagesc(stedx/counter); axis equal;
 
end;
















for folders=1:numel(foldernames)
    cd(strcat(thefolder,'\',foldernames{folders}));
a=dir; a=struct2cell(a); siza=size(a); a=a(:,3:siza(2)); siza=size(a); a2={}; for i=1:siza(2); if a{4,i}==1; a2{numel(a2)+1}=a{1,i}; end; end; a=a2; 
foldernames2=a;


counter=1;matcounter=0;
matrix=zeros(2*size_limit+1,2*size_limit+1); redx=matrix; greenx=matrix; stedx=matrix;
%%%%matrix(round(size_limit/3):size_limit,round(size_limit/4):size_limit+round(size_limit/4)+1)=1;
red=initiala;
sted=initiala;

for abcdef=1:numel(foldernames2);
    cd(strcat(thefolder,'\',foldernames{folders}));
    name=foldernames2{abcdef}; cd(name);
   
    try;
cd 'Syn';
  
close all; [stat, mess]=fileattrib('*_confocalspot.txt');
if stat==1
    for klm=1:numel(mess)
matrix=dlmread(mess(klm).Name); 
green2=matrix(1:2*size_limit+1,1:2*size_limit+1);
red2=matrix(1:2*size_limit+1,2*size_limit+2:4*size_limit+2);
sted2=matrix(1:2*size_limit+1,4*size_limit+3:6*size_limit+3);
    %%%%%%%%%%%%%%%turn around
for klmmm=1:72
    aa=imrotate(red2,klmmm*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit);
    %bb=imrotate(sted2,klmmm*5); siz=size(bb);half=round(siz(1)/2); bb=bb(half-size_limit:half+size_limit,half-size_limit:half+size_limit);
    minima(klmmm)=corr2(aa(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2),red(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2));%*...
      %  corr2(bb(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2),sted(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2));    
end;
%%%%%%%%%%%%%%flip
for klmmm=1:72
    aa=imrotate(flipud(red2),klmmm*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit);
    %bb=imrotate(flipud(sted2),klmmm*5); siz=size(bb);half=round(siz(1)/2); bb=bb(half-size_limit:half+size_limit,half-size_limit:half+size_limit);
    minima(klmmm+72)=corr2(aa(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2),red(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2));%*...
      %  corr2(bb(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2),sted(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2));
end;
 ccc=find(minima==max(max(minima)));
try
pos=ccc(1);
catch
end;
if pos<72
     aa=imrotate(red2,pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); red2=aa;
     aa=imrotate(sted2,pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); stedc2=aa; 
     aa=imrotate(green2,pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); green2=aa;
else
    aa=imrotate(flipud(red2),pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); red2=aa;
    aa=imrotate(flipud(sted2),pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); sted2=aa;
    aa=imrotate(flipud(green2),pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); green2=aa;
end;
counter=counter+1;redx=(redx+red2);greenx=(greenx+green2);stedx=(stedx+sted2);
end;end;  catch; end;end;  cd(strcat(thefolder,'\',foldernames{folders}));
dlmwrite('Synallconfocal_active_zone_matrix_by_both.txt',greenx/counter);
dlmwrite('Synallconfocal_Green_matrix_by_both.txt',redx/counter);
dlmwrite('Synallconfocal_POI_matrix_by_both.txt',stedx/counter); 
imwrite(uint16(round(greenx/counter)),'Synallconfocal_active_zone_matrix_by_both.tif','tif','Compression','none');
imwrite(uint16(round(redx/counter)),'Synallconfocal_Green_matrix_by_both.tif','tif','Compression','none');
imwrite(uint16(round(stedx/counter)),'Synallconfocal_POI_matrix_by_both.tif','tif','Compression','none');
%%%figure;
  subplot(1,3,1); imagesc(greenx/counter); axis equal;
  subplot(1,3,2); imagesc(redx/counter); axis equal;
  subplot(1,3,3); imagesc(stedx/counter); axis equal;

end;


cd(thefolder);
 a=dir; a=struct2cell(a); siza=size(a); a=a(:,3:siza(2)); siza=size(a); a2={};
 for i=1:siza(2); if a{4,i}==1; a2{numel(a2)+1}=a{1,i}; end; end; a=a2; 
 foldernames=a;

 for i=1:numel(foldernames)
     cd(strcat(thefolder,'\',foldernames{i}));
     close all;
     figure;
     subplot(4,3,1);
     a=imread('IHCallconfocal_active_zone_matrix_by_both.tif');
     imagesc(a); axis equal; axis off; title('IHC Ribbon confocal');
     subplot(4,3,2);
     a=imread('IHCallconfocal_Green_matrix_by_both.tif');
     imagesc(a); axis equal; axis off; title('IHC green confocal');
     subplot(4,3,3);
     a=imread('IHCallconfocal_POI_matrix_by_both.tif');
     imagesc(a); axis equal; axis off; title('IHC POI confocal');
     subplot(4,3,4);
     a=imread('IHCallSTED_active_zone_matrix_by_both.tif');
     imagesc(a); axis equal; axis off; title('IHC Ribbon STED');
     subplot(4,3,5);
     a=imread('IHCallSTED_Green_matrix_by_both.tif');
     imagesc(a); axis equal; axis off; title('IHC green STED');
     subplot(4,3,6);
     a=imread('IHCallSTED_POI_matrix_by_both.tif');
     imagesc(a); axis equal; axis off; title('IHC POI STED');
     subplot(4,3,7);
     a=imread('Synallconfocal_active_zone_matrix_by_both.tif');
     imagesc(a); axis equal; axis off; title('Syn AZ confocal');
     subplot(4,3,8);
     a=imread('Synallconfocal_Green_matrix_by_both.tif');
     imagesc(a); axis equal; axis off; title('Syn green confocal');
     subplot(4,3,9);
     a=imread('Synallconfocal_POI_matrix_by_both.tif');
     imagesc(a); axis equal; axis off; title('Syn POI confocal');
     subplot(4,3,10);
     a=imread('SynallSTED_active_zone_matrix_by_both.tif');
     imagesc(a); axis equal; axis off; title('Syn AZ STED');
     subplot(4,3,11);
     a=imread('SynallSTED_Green_matrix_by_both.tif');
     imagesc(a); axis equal; axis off; title('Syn green STED');
     subplot(4,3,12);
     a=imread('SynallSTED_POI_matrix_by_both.tif');
     imagesc(a); axis equal; axis off; title('Syn POI STED');
     
     h=gcf; saveas(h, strcat('Overview.png'),'png');
h=gcf; saveas(h, strcat('Overview.fig'),'fig');
 end






 clc;
 
  
 
 
 
 
 
cd(thefolder);
cellb={};

[dsstat, dmmess]=fileattrib('*');
for i=1:numel(dmmess)
    if dmmess(i).directory
        cellb{numel(cellb)+1}=dmmess(i).Name;
    end;
end;

for abcdef=1:numel(cellb);

    abcdef
    name=cellb{abcdef};
    cd(name);

close all;
[stat, mess]=fileattrib('*_STEDspot.txt');
if stat==1

matcounter=0;
matrix=zeros(2*size_limit+1,2*size_limit+1); redx=matrix; greenx=matrix; stedx=matrix;
%%%%matrix(round(size_limit/3):size_limit,round(size_limit/4):size_limit+round(size_limit/4)+1)=1;
red=initiala;
sted=initiala;


counter=1;
for klm=1:numel(mess)
klm*100/numel(mess)
       
matrix=dlmread(mess(klm).Name); 
green2=matrix(1:2*size_limit+1,1:2*size_limit+1);
red2=matrix(1:2*size_limit+1,2*size_limit+2:4*size_limit+2);
sted2=matrix(1:2*size_limit+1,4*size_limit+3:6*size_limit+3);

    %%%%%%%%%%%%%%%turn around

for klmmm=1:72

    aa=imrotate(red2,klmmm*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit);
    %bb=imrotate(sted2,klmmm*5); siz=size(bb);half=round(siz(1)/2); bb=bb(half-size_limit:half+size_limit,half-size_limit:half+size_limit);
    minima(klmmm)=corr2(aa(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2),red(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2));%*...
      %  corr2(bb(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2),sted(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2));    
end;

%%%%%%%%%%%%%%flip
for klmmm=1:72

    aa=imrotate(flipud(red2),klmmm*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit);
    %bb=imrotate(flipud(sted2),klmmm*5); siz=size(bb);half=round(siz(1)/2); bb=bb(half-size_limit:half+size_limit,half-size_limit:half+size_limit);
    minima(klmmm+72)=corr2(aa(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2),red(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2));%*...
      %  corr2(bb(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2),sted(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2));
end;
 ccc=find(minima==max(max(minima)));
try
pos=ccc(1);
catch
end;

if pos<72
     aa=imrotate(red2,pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); red2=aa;
     aa=imrotate(sted2,pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); stedc2=aa; 
     aa=imrotate(green2,pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); green2=aa;
else
    aa=imrotate(flipud(red2),pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); red2=aa;
    aa=imrotate(flipud(sted2),pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); sted2=aa;
    aa=imrotate(flipud(green2),pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); green2=aa;
end;
     


%turn_matrix=turn_matrix/2;
counter=counter+1;

redx=(redx+red2);
greenx=(greenx+green2);
stedx=(stedx+sted2);
end;

% imagesc(turn_matrix); axis equal; drawnow;
  
 

dlmwrite('STED_active_zone_matrix_by_both.txt',greenx/counter);
dlmwrite('STED_Green_matrix_by_both.txt',redx/counter);
dlmwrite('STED_POI_matrix_by_both.txt',stedx/counter); 

imwrite(uint16(round(greenx/counter)),'STED_active_zone_matrix_by_both.tif','tif','Compression','none');
imwrite(uint16(round(redx/counter)),'STED_Green_matrix_by_both.tif','tif','Compression','none');
imwrite(uint16(round(stedx/counter)),'STED_POI_matrix_by_both.tif','tif','Compression','none');

%%%figure;
  subplot(1,3,1); imagesc(greenx/counter); axis equal;
  subplot(1,3,2); imagesc(redx/counter); axis equal;
  subplot(1,3,3); imagesc(stedx/counter); axis equal;

end;

end;





for abcdef=1:numel(cellb);
    

    abcdef
    name=cellb{abcdef};
    cd(name);

close all;
[stat, mess]=fileattrib('*_confocalspot.txt');
if stat==1

matcounter=0;
matrix=zeros(2*size_limit+1,2*size_limit+1); redx=matrix; greenx=matrix; stedx=matrix;
matrix(round(size_limit/3):size_limit,round(size_limit/4):size_limit+round(size_limit/4)+1)=1;
red=initiala;
sted=initiala;


counter=1;
for klm=1:numel(mess)
klm*100/numel(mess)
       
matrix=dlmread(mess(klm).Name); 
green2=matrix(1:2*size_limit+1,1:2*size_limit+1);
red2=matrix(1:2*size_limit+1,2*size_limit+2:4*size_limit+2);
sted2=matrix(1:2*size_limit+1,4*size_limit+3:6*size_limit+3);

    %%%%%%%%%%%%%%%turn around

for klmmm=1:72

    aa=imrotate(red2,klmmm*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit);
    %bb=imrotate(sted2,klmmm*5); siz=size(bb);half=round(siz(1)/2); bb=bb(half-size_limit:half+size_limit,half-size_limit:half+size_limit);
    minima(klmmm)=corr2(aa(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2),red(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2));%*...
      %  corr2(bb(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2),sted(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2));    
end;

%%%%%%%%%%%%%%flip
for klmmm=1:72

    aa=imrotate(flipud(red2),klmmm*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit);
    %bb=imrotate(flipud(sted2),klmmm*5); siz=size(bb);half=round(siz(1)/2); bb=bb(half-size_limit:half+size_limit,half-size_limit:half+size_limit);
    minima(klmmm+72)=corr2(aa(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2),red(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2));%*...
      %  corr2(bb(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2),sted(size_limit/2:size_limit*3/2,size_limit/2:size_limit*3/2));
end;
 ccc=find(minima==max(max(minima)));
try
pos=ccc(1);
catch
end;

if pos<72
     aa=imrotate(red2,pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); red2=aa;
     aa=imrotate(sted2,pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); stedc2=aa; 
     aa=imrotate(green2,pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); green2=aa;
else
    aa=imrotate(flipud(red2),pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); red2=aa;
    aa=imrotate(flipud(sted2),pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); sted2=aa;
    aa=imrotate(flipud(green2),pos*5); siz=size(aa);half=round(siz(1)/2); aa=aa(half-size_limit:half+size_limit,half-size_limit:half+size_limit); green2=aa;
end;
     


%turn_matrix=turn_matrix/2;
counter=counter+1;

redx=(redx+red2);
greenx=(greenx+green2);
stedx=(stedx+sted2);
end;

% imagesc(turn_matrix); axis equal; drawnow;
  
 

dlmwrite('confocal_active_zone_matrix_by_both.txt',greenx/counter);
dlmwrite('confocal_Green_matrix_by_both.txt',redx/counter);
dlmwrite('confocal_POI_matrix_by_both.txt',stedx/counter); 

imwrite(uint16(round(greenx/counter)),'confocal_active_zone_matrix_by_both.tif','tif','Compression','none');
imwrite(uint16(round(redx/counter)),'confocal_Green_matrix_by_both.tif','tif','Compression','none');
imwrite(uint16(round(stedx/counter)),'confocal_POI_matrix_by_both.tif','tif','Compression','none');

%%%figure;
  subplot(1,3,1); imagesc(greenx/counter); axis equal;
  subplot(1,3,2); imagesc(redx/counter); axis equal;
  subplot(1,3,3); imagesc(stedx/counter); axis equal;

end;

end;










