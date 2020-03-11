function address_spots;

%%%%%this folder shouldcontain subfolders for the individual experiments,
%%%%%and the file model.tif
cd 'F:\data_2012\katharina_new_analysis';
initiala=double(imread('model.tif'));

cellb={};

size_limit=100;


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