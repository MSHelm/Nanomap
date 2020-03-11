function stack_3d;

thefolder='C:\data_2012\spines\spine_3Ds';

cellb={};
cd (thefolder);
[sstat, mmess]=fileattrib('*');
for i=1:numel(mmess)
    if mmess(i).directory
        cellb{numel(cellb)+1}=mmess(i).Name;
    end;
end;

for abcdef=1:numel(cellb);
    
abcdef*100/numel(cellb)

    cd(cellb{abcdef});
   

pixel_size=3.067; % nm
dicke=70;


dicke=dicke/pixel_size;
basename='*_numbers.txt';

%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
% Active zone - x = first column; y=second column
% Membrane - x = 3rd column; y=4th colum
% Normal vesicles - x = 5th column; y = 6th column
% dense-core vesicles - x = 7th column; y = 8th column [empty for now, as we have not seen any]
% Normal vesicles, distance to the active zone = 9th column - not useful for 3D
% Normal vesicles, distance to the membrane = 10th column - not useful for 3D
% dense-core vesicles, distance to the active zone = 11th column - not useful for 3D
% dense-core vesicles, distance to the membrane = 12th column - not useful for 3D
% Vacuoles - x = 13th column; y=14th column
% Mitochondria - x = 15th column; y=16th column
% The vacuole separators (index number) are in column 17 [for all the x
% and y values of the first vacuole (in columns 13 and 14) this column will have ones in the
% respective positions; for the second vacuole in the particular image there will be twos, etc.
% The mitochondria separators (index number) are in column 18 - same as for vacuoles
% Column 19 does nothing
% note that all columns are padded with zeros 
% all values are in pixels - and pixel size is 2.2 nm
% the distance between sections, or in other words the section thickness, is 70 nm (approximately, of course)
% we expect that the structures shrunk by ~20% versus the original situation

[stat, mess]=fileattrib(strcat(basename));
val_matrix=zeros(numel(mess),20);
% col1=az area; col2=pm perimeter; col3=mitoch perimeter; col4=vacuole perimeter; col5=ves number
% col6=pixels in membrane; col7=major axis length membrane; col8=minor axis length membrane
% col9=mean pixels in mitoch; col10=mean major axis length mitoch; col11=mean minor axis length mitoch
% col12= number vacuole objects
% col13=mean pixels in vacuoles; col14=mean major axis length vacuoles; col15=mean minor axis length vacuoles
% col16=number vacuole objects

val_matrix_dist=zeros(9,25);

az_matrix=[];az_cen_matrix=[];
pm_matrix=[];pm_cen_matrix=[];
ves_matrix=[];
vac_matrix=[];
mit_matrix=[];
tot_vac_matrix=[];
tot_mit_matrix=[];

if stat==1

for klm=1:numel(mess)
    matrix=dlmread(mess(klm).Name);
    
    azx=matrix(:,1); azy=matrix(:,2); ccc=find(azx>0); azx=azx(ccc); azy=azy(ccc); 
    siz=size(az_matrix);
    az_matrix(siz(1)+1:siz(1)+numel(azx),1)=azx;
    az_matrix(siz(1)+1:siz(1)+numel(azx),2)=azy;    
    az_matrix(siz(1)+1:siz(1)+numel(azx),3)=(klm-1)*dicke;
    siz=size(az_cen_matrix);
    az_cen_matrix(siz(1)+1,1)=mean(azx);
    az_cen_matrix(siz(1)+1,2)=mean(azy);    
    az_cen_matrix(siz(1)+1,3)=(klm-1)*dicke;    

    pmx=matrix(:,3); pmy=matrix(:,4); ccc=find(pmx>0); pmx=pmx(ccc); pmy=pmy(ccc); 
    siz=size(pm_matrix);
    pm_matrix(siz(1)+1:siz(1)+numel(pmx),1)=pmx;
    pm_matrix(siz(1)+1:siz(1)+numel(pmx),2)=pmy;    
    pm_matrix(siz(1)+1:siz(1)+numel(pmx),3)=(klm-1)*dicke;
    siz=size(pm_cen_matrix);
    pm_cen_matrix(siz(1)+1,1)=mean(pmx);
    pm_cen_matrix(siz(1)+1,2)=mean(pmy);    
    pm_cen_matrix(siz(1)+1,3)=(klm-1)*dicke;    
      
    
    vx=matrix(:,13); vy=matrix(:,14); ccc=find(vx>0); vx=vx(ccc); vy=vy(ccc); vindex=matrix(:,17); vindex=vindex(ccc);
    siz=size(tot_vac_matrix);
    tot_vac_matrix(siz(1)+1:siz(1)+numel(vx),1)=vx;
    tot_vac_matrix(siz(1)+1:siz(1)+numel(vx),2)=vy;    
    tot_vac_matrix(siz(1)+1:siz(1)+numel(vx),3)=(klm-1)*dicke;
    
    mmx=matrix(:,15); mmy=matrix(:,16); ccc=find(mmx>0); mmx=mmx(ccc); mmy=mmy(ccc); mindex=matrix(:,18); mindex=mindex(ccc);
    siz=size(tot_mit_matrix);
    tot_mit_matrix(siz(1)+1:siz(1)+numel(mmx),1)=mmx;
    tot_mit_matrix(siz(1)+1:siz(1)+numel(mmx),2)=mmy;    
    tot_mit_matrix(siz(1)+1:siz(1)+numel(mmx),3)=(klm-1)*dicke;
    
    vesx=matrix(:,5); vesy=matrix(:,6); ccc=find(vesx>0); vesx=vesx(ccc); vesy=vesy(ccc); 
    siz=size(ves_matrix);
    ves_matrix(siz(1)+1:siz(1)+numel(vesx),1)=vesx;
    ves_matrix(siz(1)+1:siz(1)+numel(vesx),2)=vesy;    
    ves_matrix(siz(1)+1:siz(1)+numel(vesx),3)=(klm-1)*dicke;
    
    
    
    azarea=numel(azx); val_matrix(klm,1)=azarea; 
    pmarea=numel(pmx); val_matrix(klm,2)=pmarea; 
    mmarea=numel(mmx); val_matrix(klm,3)=mmarea; 
    varea=numel(vx); val_matrix(klm,4)=varea; 
    vesnum=numel(vesx); val_matrix(klm,5)=vesnum; 

    img=zeros(max(max(pmx),max(pmy)),max(max(pmx),max(pmy))); rpl=roipoly(img,pmx,pmy);
    ccc=find(rpl>0); val_matrix(klm,6)=numel(ccc);
    l=regionprops(bwlabel(rpl),'MajorAxisLength','MinorAxisLength'); ll=struct2cell(l); lll=cell2mat(ll); 
    val_matrix(klm,7)=lll(1); val_matrix(klm,8)=lll(2);
    

    if numel(mindex)>0
        minuser=0;
        for i=1:max(max(mindex));
            ccc=find(mindex==i); 
            try
            svx=mmx(ccc);
            svy=mmy(ccc);
            
            siz=size(mit_matrix);
            mit_matrix(siz(1)+1,1)=mean(svx);
            mit_matrix(siz(1)+1,2)=mean(svy);
            mit_matrix(siz(1)+1,3)=(klm-1)*dicke;
            
            img=zeros(max(max(svx),max(svy)),max(max(svx),max(svy))); rpl=roipoly(img,svx,svy); imagesc(rpl)
    ccc=find(rpl>0); val_matrix(klm,9)=val_matrix(klm,9)+numel(ccc);  
    l=regionprops(bwlabel(rpl),'MajorAxisLength','MinorAxisLength'); ll=struct2cell(l); lll=cell2mat(ll); 
    val_matrix(klm,10)=val_matrix(klm,10)+lll(1); val_matrix(klm,11)=val_matrix(klm,11)+lll(2);
            catch
               minuser=minuser-1; 
            end
               
        end
        
        val_matrix(klm,9)=val_matrix(klm,9)/(max(max(mindex))+minuser);
        val_matrix(klm,10)=val_matrix(klm,10)/(max(max(mindex))+minuser);
        val_matrix(klm,11)=val_matrix(klm,11)/(max(max(mindex))+minuser);
        val_matrix(klm,12)=max(max(mindex));
    
    end;
    
    if numel(vindex)>0
        minuser=0;
        for i=1:max(max(vindex));
            ccc=find(vindex==i); 
            try
            svx=vx(ccc);
            svy=vy(ccc); 
            
            siz=size(vac_matrix);
            vac_matrix(siz(1)+1,1)=mean(svx);
            vac_matrix(siz(1)+1,2)=mean(svy);
            vac_matrix(siz(1)+1,3)=(klm-1)*dicke;
            
            
            img=zeros(max(max(svx),max(svy)),max(max(svx),max(svy))); rpl=roipoly(img,svx,svy); imagesc(rpl)
    ccc=find(rpl>0); val_matrix(klm,13)=val_matrix(klm,13)+numel(ccc);  
    l=regionprops(bwlabel(rpl),'MajorAxisLength','MinorAxisLength'); ll=struct2cell(l); lll=cell2mat(ll); 
    val_matrix(klm,14)=val_matrix(klm,14)+lll(1); val_matrix(klm,15)=val_matrix(klm,15)+lll(2);
            catch
               minuser=minuser-1; 
            end
               
        end
        
        val_matrix(klm,13)=val_matrix(klm,13)/(max(max(vindex))+minuser);
        val_matrix(klm,14)=val_matrix(klm,14)/(max(max(vindex))+minuser);
        val_matrix(klm,15)=val_matrix(klm,15)/(max(max(vindex))+minuser);
        val_matrix(klm,16)=max(max(vindex));
    
        
    end;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% vesicle distances
if numel(ves_matrix)>2
siz=size(ves_matrix); 
numves=siz(1);

ax=az_matrix(:,1); ay=az_matrix(:,2); az=az_matrix(:,3);%%%%% distances to AZ
counter=[];
for i=1:numves; 
    bx=ax-ax+ves_matrix(i,1); by=ax-ax+ves_matrix(i,2); bz=ax-ax+ves_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
    try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc); val_matrix_dist(1,17)=mean(counter);

ax=pm_matrix(:,1); ay=pm_matrix(:,2); az=pm_matrix(:,3);%%%%% distances to membrane
counter=[];
for i=1:numves; 
    bx=ax-ax+ves_matrix(i,1); by=ax-ax+ves_matrix(i,2); bz=ax-ax+ves_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(2,17)=mean(counter);

if numel(vac_matrix)>2
ax=vac_matrix(:,1); ay=vac_matrix(:,2); az=vac_matrix(:,3);%%%%% distances to vacuole
counter=[];
for i=1:numves; 
    bx=ax-ax+ves_matrix(i,1); by=ax-ax+ves_matrix(i,2); bz=ax-ax+ves_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(3,17)=mean(counter);
end;

if numel(mit_matrix)>2
ax=mit_matrix(:,1); ay=mit_matrix(:,2); az=mit_matrix(:,3);%%%%% distances to mitochondria
counter=[];
for i=1:numves; 
    bx=ax-ax+ves_matrix(i,1); by=ax-ax+ves_matrix(i,2); bz=ax-ax+ves_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
    try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(4,17)=mean(counter);
end;

if numel(ves_matrix)>4
ax=ves_matrix(:,1); ay=ves_matrix(:,2); az=ves_matrix(:,3);%%%%% distances to vesicles
counter=[];
for i=1:numves; 
    bx=ax-ax+ves_matrix(i,1); by=ax-ax+ves_matrix(i,2); bz=ax-ax+ves_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(5,17)=mean(counter);
end;

ax=az_cen_matrix(:,1); ay=az_cen_matrix(:,2); az=az_cen_matrix(:,3);%%%%% distances to AZ centers
counter=[];
for i=1:numves; 
    bx=ax-ax+ves_matrix(i,1); by=ax-ax+ves_matrix(i,2); bz=ax-ax+ves_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(6,17)=mean(counter);


ax=pm_cen_matrix(:,1); ay=pm_cen_matrix(:,2); az=pm_cen_matrix(:,3);%%%%% distances to mem centers
counter=[];
for i=1:numves; 
    bx=ax-ax+ves_matrix(i,1); by=ax-ax+ves_matrix(i,2); bz=ax-ax+ves_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
    try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(7,17)=mean(counter);

if numel(tot_vac_matrix)>4
ax=tot_vac_matrix(:,1); ay=tot_vac_matrix(:,2); az=tot_vac_matrix(:,3);%%%%% distances to vac membranes
counter=[];
for i=1:numves; 
    bx=ax-ax+ves_matrix(i,1); by=ax-ax+ves_matrix(i,2); bz=ax-ax+ves_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
    try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(8,17)=mean(counter);
end;

if numel(tot_mit_matrix)>4
ax=tot_mit_matrix(:,1); ay=tot_mit_matrix(:,2); az=tot_mit_matrix(:,3);%%%%% distances to mitoch membranes
counter=[];
for i=1:numves; 
    bx=ax-ax+ves_matrix(i,1); by=ax-ax+ves_matrix(i,2); bz=ax-ax+ves_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
    try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(9,17)=mean(counter);
end;

end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% vacuole distances
if numel(vac_matrix)>2
siz=size(vac_matrix); 
numves=siz(1);

ax=az_matrix(:,1); ay=az_matrix(:,2); az=az_matrix(:,3);%%%%% distances to AZ
counter=[];
for i=1:numves; 
    bx=ax-ax+vac_matrix(i,1); by=ax-ax+vac_matrix(i,2); bz=ax-ax+vac_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(1,18)=mean(counter);

ax=pm_matrix(:,1); ay=pm_matrix(:,2); az=pm_matrix(:,3);%%%%% distances to membrane
counter=[];
for i=1:numves; 
    bx=ax-ax+vac_matrix(i,1); by=ax-ax+vac_matrix(i,2); bz=ax-ax+vac_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(2,18)=mean(counter);

if numel(vac_matrix)>4
ax=vac_matrix(:,1); ay=vac_matrix(:,2); az=vac_matrix(:,3);%%%%% distances to vacuole
counter=[];
for i=1:numves; 
    bx=ax-ax+vac_matrix(i,1); by=ax-ax+vac_matrix(i,2); bz=ax-ax+vac_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(3,18)=mean(counter);
end;

if numel(mit_matrix)>2
ax=mit_matrix(:,1); ay=mit_matrix(:,2); az=mit_matrix(:,3);%%%%% distances to mitochondria
counter=[];
for i=1:numves; 
    bx=ax-ax+vac_matrix(i,1); by=ax-ax+vac_matrix(i,2); bz=ax-ax+vac_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(4,18)=mean(counter);
end;

if numel(ves_matrix)>2
ax=ves_matrix(:,1); ay=ves_matrix(:,2); az=ves_matrix(:,3);%%%%% distances to vesicles
counter=[];
for i=1:numves; 
    bx=ax-ax+vac_matrix(i,1); by=ax-ax+vac_matrix(i,2); bz=ax-ax+vac_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(5,18)=mean(counter);
end;

ax=az_cen_matrix(:,1); ay=az_cen_matrix(:,2); az=az_cen_matrix(:,3);%%%%% distances to AZ centers
counter=[];
for i=1:numves; 
    bx=ax-ax+vac_matrix(i,1); by=ax-ax+vac_matrix(i,2); bz=ax-ax+vac_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
    try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(6,18)=mean(counter);


ax=pm_cen_matrix(:,1); ay=pm_cen_matrix(:,2); az=pm_cen_matrix(:,3);%%%%% distances to mem centers
counter=[];
for i=1:numves; 
    bx=ax-ax+vac_matrix(i,1); by=ax-ax+vac_matrix(i,2); bz=ax-ax+vac_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(7,18)=mean(counter);

if numel(tot_vac_matrix)>4
ax=tot_vac_matrix(:,1); ay=tot_vac_matrix(:,2); az=tot_vac_matrix(:,3);%%%%% distances to vac membranes
counter=[];
for i=1:numves; 
    bx=ax-ax+vac_matrix(i,1); by=ax-ax+vac_matrix(i,2); bz=ax-ax+vac_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
    try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(8,18)=mean(counter);
end;

if numel(tot_mit_matrix)>4
ax=tot_mit_matrix(:,1); ay=tot_mit_matrix(:,2); az=tot_mit_matrix(:,3);%%%%% distances to mitoch membranes
counter=[];
for i=1:numves; 
    bx=ax-ax+vac_matrix(i,1); by=ax-ax+vac_matrix(i,2); bz=ax-ax+vac_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
    try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(9,18)=mean(counter);
end;

end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% mitochondria distances
if numel(mit_matrix)>2
siz=size(mit_matrix); 
numves=siz(1);

ax=az_matrix(:,1); ay=az_matrix(:,2); az=az_matrix(:,3);%%%%% distances to AZ
counter=[];
for i=1:numves; 
    bx=ax-ax+mit_matrix(i,1); by=ax-ax+mit_matrix(i,2); bz=ax-ax+mit_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(1,19)=mean(counter);

ax=pm_matrix(:,1); ay=pm_matrix(:,2); az=pm_matrix(:,3);%%%%% distances to membrane
counter=[];
for i=1:numves; 
    bx=ax-ax+mit_matrix(i,1); by=ax-ax+mit_matrix(i,2); bz=ax-ax+mit_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(2,19)=mean(counter);

if numel(vac_matrix)>2
ax=vac_matrix(:,1); ay=vac_matrix(:,2); az=vac_matrix(:,3);%%%%% distances to vacuole
counter=[];
for i=1:numves; 
    bx=ax-ax+mit_matrix(i,1); by=ax-ax+mit_matrix(i,2); bz=ax-ax+mit_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
      try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(3,19)=mean(counter);
end;

if numel(mit_matrix)>4
ax=mit_matrix(:,1); ay=mit_matrix(:,2); az=mit_matrix(:,3);%%%%% distances to mitochondria
counter=[];
for i=1:numves; 
    bx=ax-ax+mit_matrix(i,1); by=ax-ax+mit_matrix(i,2); bz=ax-ax+mit_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(4,19)=mean(counter);
end;

if numel(ves_matrix)>2
ax=ves_matrix(:,1); ay=ves_matrix(:,2); az=ves_matrix(:,3);%%%%% distances to vesicles
counter=[];
for i=1:numves; 
    bx=ax-ax+mit_matrix(i,1); by=ax-ax+mit_matrix(i,2); bz=ax-ax+mit_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(5,19)=mean(counter);
end

ax=az_cen_matrix(:,1); ay=az_cen_matrix(:,2); az=az_cen_matrix(:,3);%%%%% distances to AZ centers
counter=[];
for i=1:numves; 
    bx=ax-ax+mit_matrix(i,1); by=ax-ax+mit_matrix(i,2); bz=ax-ax+mit_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(6,19)=mean(counter);


ax=pm_cen_matrix(:,1); ay=pm_cen_matrix(:,2); az=pm_cen_matrix(:,3);%%%%% distances to mem centers
counter=[];
for i=1:numves; 
    bx=ax-ax+mit_matrix(i,1); by=ax-ax+mit_matrix(i,2); bz=ax-ax+mit_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(7,19)=mean(counter);


if numel(tot_vac_matrix)>4
ax=tot_vac_matrix(:,1); ay=tot_vac_matrix(:,2); az=tot_vac_matrix(:,3);%%%%% distances to vac membranes
counter=[];
for i=1:numves; 
    bx=ax-ax+mit_matrix(i,1); by=ax-ax+mit_matrix(i,2); bz=ax-ax+mit_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
    try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(8,19)=mean(counter);
end;

if numel(tot_mit_matrix)>4
ax=tot_mit_matrix(:,1); ay=tot_mit_matrix(:,2); az=tot_mit_matrix(:,3);%%%%% distances to mitoch membranes
counter=[];
for i=1:numves; 
    bx=ax-ax+mit_matrix(i,1); by=ax-ax+mit_matrix(i,2); bz=ax-ax+mit_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
    try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(9,19)=mean(counter);
end;


end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AZ center distances
if numel(az_cen_matrix)>2
siz=size(az_cen_matrix); 
numves=siz(1);

ax=az_matrix(:,1); ay=az_matrix(:,2); az=az_matrix(:,3);%%%%% distances to AZ
counter=[];
for i=1:numves; 
    bx=ax-ax+az_cen_matrix(i,1); by=ax-ax+az_cen_matrix(i,2); bz=ax-ax+az_cen_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(1,20)=mean(counter);

ax=pm_matrix(:,1); ay=pm_matrix(:,2); az=pm_matrix(:,3);%%%%% distances to membrane
counter=[];
for i=1:numves; 
    bx=ax-ax+az_cen_matrix(i,1); by=ax-ax+az_cen_matrix(i,2); bz=ax-ax+az_cen_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(2,20)=mean(counter);

if numel(vac_matrix)>2
ax=vac_matrix(:,1); ay=vac_matrix(:,2); az=vac_matrix(:,3);%%%%% distances to vacuole
counter=[];
for i=1:numves; 
    bx=ax-ax+az_cen_matrix(i,1); by=ax-ax+az_cen_matrix(i,2); bz=ax-ax+az_cen_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
      try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(3,20)=mean(counter);
end;

if numel(mit_matrix)>2
ax=mit_matrix(:,1); ay=mit_matrix(:,2); az=mit_matrix(:,3);%%%%% distances to mitochondria
counter=[];
for i=1:numves; 
    bx=ax-ax+az_cen_matrix(i,1); by=ax-ax+az_cen_matrix(i,2); bz=ax-ax+az_cen_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
    try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(4,20)=mean(counter);
end;

if numel(ves_matrix)>2
ax=ves_matrix(:,1); ay=ves_matrix(:,2); az=ves_matrix(:,3);%%%%% distances to vesicles
counter=[];
for i=1:numves; 
    bx=ax-ax+az_cen_matrix(i,1); by=ax-ax+az_cen_matrix(i,2); bz=ax-ax+az_cen_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(5,20)=mean(counter);
end;

if numel(az_cen_matrix)>4
ax=az_cen_matrix(:,1); ay=az_cen_matrix(:,2); az=az_cen_matrix(:,3);%%%%% distances to AZ centers
counter=[];
for i=1:numves; 
    bx=ax-ax+az_cen_matrix(i,1); by=ax-ax+az_cen_matrix(i,2); bz=ax-ax+az_cen_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(6,20)=mean(counter);
end;

ax=pm_cen_matrix(:,1); ay=pm_cen_matrix(:,2); az=pm_cen_matrix(:,3);%%%%% distances to mem centers
counter=[];
for i=1:numves; 
    bx=ax-ax+az_cen_matrix(i,1); by=ax-ax+az_cen_matrix(i,2); bz=ax-ax+az_cen_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
    try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(7,20)=mean(counter);

if numel(tot_vac_matrix)>4
ax=tot_vac_matrix(:,1); ay=tot_vac_matrix(:,2); az=tot_vac_matrix(:,3);%%%%% distances to vac membranes
counter=[];
for i=1:numves; 
    bx=ax-ax+az_cen_matrix(i,1); by=ax-ax+az_cen_matrix(i,2); bz=ax-ax+az_cen_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
    try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(8,20)=mean(counter);
end;

if numel(tot_mit_matrix)>4
ax=tot_mit_matrix(:,1); ay=tot_mit_matrix(:,2); az=tot_mit_matrix(:,3);%%%%% distances to mitoch membranes
counter=[];
for i=1:numves; 
    bx=ax-ax+az_cen_matrix(i,1); by=ax-ax+az_cen_matrix(i,2); bz=ax-ax+az_cen_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
    try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(9,20)=mean(counter);
end;

end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% membrane vacuole distances
if numel(tot_vac_matrix)>4
siz=size(tot_vac_matrix); 
numves=siz(1);

ax=az_matrix(:,1); ay=az_matrix(:,2); az=az_matrix(:,3);%%%%% distances to AZ
counter=[];
for i=1:numves; 
    bx=ax-ax+tot_vac_matrix(i,1); by=ax-ax+tot_vac_matrix(i,2); bz=ax-ax+tot_vac_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(1,21)=mean(counter);

ax=pm_matrix(:,1); ay=pm_matrix(:,2); az=pm_matrix(:,3);%%%%% distances to membrane
counter=[];
for i=1:numves; 
    bx=ax-ax+tot_vac_matrix(i,1); by=ax-ax+tot_vac_matrix(i,2); bz=ax-ax+tot_vac_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(2,21)=mean(counter);

if numel(vac_matrix)>2
ax=vac_matrix(:,1); ay=vac_matrix(:,2); az=vac_matrix(:,3);%%%%% distances to vacuole
counter=[];
for i=1:numves; 
    bx=ax-ax+tot_vac_matrix(i,1); by=ax-ax+tot_vac_matrix(i,2); bz=ax-ax+tot_vac_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
      try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(3,21)=mean(counter);
end;

if numel(mit_matrix)>2
ax=mit_matrix(:,1); ay=mit_matrix(:,2); az=mit_matrix(:,3);%%%%% distances to mitochondria
counter=[];
for i=1:numves; 
    bx=ax-ax+tot_vac_matrix(i,1); by=ax-ax+tot_vac_matrix(i,2); bz=ax-ax+tot_vac_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
    try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(4,21)=mean(counter);
end;

if numel(ves_matrix)>2
ax=ves_matrix(:,1); ay=ves_matrix(:,2); az=ves_matrix(:,3);%%%%% distances to vesicles
counter=[];
for i=1:numves; 
    bx=ax-ax+tot_vac_matrix(i,1); by=ax-ax+tot_vac_matrix(i,2); bz=ax-ax+tot_vac_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(5,21)=mean(counter);
end;

if numel(az_cen_matrix)>2
ax=az_cen_matrix(:,1); ay=az_cen_matrix(:,2); az=az_cen_matrix(:,3);%%%%% distances to AZ centers
counter=[];
for i=1:numves; 
    bx=ax-ax+tot_vac_matrix(i,1); by=ax-ax+tot_vac_matrix(i,2); bz=ax-ax+tot_vac_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(6,21)=mean(counter);
end;

ax=pm_cen_matrix(:,1); ay=pm_cen_matrix(:,2); az=pm_cen_matrix(:,3);%%%%% distances to mem centers
counter=[];
for i=1:numves; 
    bx=ax-ax+tot_vac_matrix(i,1); by=ax-ax+tot_vac_matrix(i,2); bz=ax-ax+tot_vac_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
    try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(7,21)=mean(counter);

% if numel(tot_vac_matrix)>4
% ax=tot_vac_matrix(:,1); ay=tot_vac_matrix(:,2); az=tot_vac_matrix(:,3);%%%%% distances to vac membranes
% counter=[];
% for i=1:numves; 
%     bx=ax-ax+tot_vac_matrix(i,1); by=ax-ax+tot_vac_matrix(i,2); bz=ax-ax+tot_vac_matrix(i,3); 
%     dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
%     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
% end;
% ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(8,21)=mean(counter);
% end;

if numel(tot_mit_matrix)>4
ax=tot_mit_matrix(:,1); ay=tot_mit_matrix(:,2); az=tot_mit_matrix(:,3);%%%%% distances to mitoch membranes
counter=[];
for i=1:numves; 
    bx=ax-ax+tot_vac_matrix(i,1); by=ax-ax+tot_vac_matrix(i,2); bz=ax-ax+tot_vac_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
    try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(9,21)=mean(counter);
end;

end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% membrane mitochondria distances
if numel(tot_mit_matrix)>4
siz=size(tot_mit_matrix); 
numves=siz(1);

ax=az_matrix(:,1); ay=az_matrix(:,2); az=az_matrix(:,3);%%%%% distances to AZ
counter=[];
for i=1:numves; 
    bx=ax-ax+tot_mit_matrix(i,1); by=ax-ax+tot_mit_matrix(i,2); bz=ax-ax+tot_mit_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(1,22)=mean(counter);

ax=pm_matrix(:,1); ay=pm_matrix(:,2); az=pm_matrix(:,3);%%%%% distances to membrane
counter=[];
for i=1:numves; 
    bx=ax-ax+tot_mit_matrix(i,1); by=ax-ax+tot_mit_matrix(i,2); bz=ax-ax+tot_mit_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(2,22)=mean(counter);

if numel(vac_matrix)>2
ax=vac_matrix(:,1); ay=vac_matrix(:,2); az=vac_matrix(:,3);%%%%% distances to vacuole
counter=[];
for i=1:numves; 
    bx=ax-ax+tot_mit_matrix(i,1); by=ax-ax+tot_mit_matrix(i,2); bz=ax-ax+tot_mit_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
      try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(3,22)=mean(counter);
end;

if numel(mit_matrix)>2
ax=mit_matrix(:,1); ay=mit_matrix(:,2); az=mit_matrix(:,3);%%%%% distances to mitochondria
counter=[];
for i=1:numves; 
    bx=ax-ax+tot_mit_matrix(i,1); by=ax-ax+tot_mit_matrix(i,2); bz=ax-ax+tot_mit_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
    try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(4,22)=mean(counter);
end;

if numel(ves_matrix)>2
ax=ves_matrix(:,1); ay=ves_matrix(:,2); az=ves_matrix(:,3);%%%%% distances to vesicles
counter=[];
for i=1:numves; 
    bx=ax-ax+tot_mit_matrix(i,1); by=ax-ax+tot_mit_matrix(i,2); bz=ax-ax+tot_mit_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(5,22)=mean(counter);
end;

if numel(az_cen_matrix)>2
ax=az_cen_matrix(:,1); ay=az_cen_matrix(:,2); az=az_cen_matrix(:,3);%%%%% distances to AZ centers
counter=[];
for i=1:numves; 
    bx=ax-ax+tot_mit_matrix(i,1); by=ax-ax+tot_mit_matrix(i,2); bz=ax-ax+tot_mit_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(6,22)=mean(counter);
end;

ax=pm_cen_matrix(:,1); ay=pm_cen_matrix(:,2); az=pm_cen_matrix(:,3);%%%%% distances to mem centers
counter=[];
for i=1:numves; 
    bx=ax-ax+tot_mit_matrix(i,1); by=ax-ax+tot_mit_matrix(i,2); bz=ax-ax+tot_mit_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
    try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(7,22)=mean(counter);

if numel(tot_vac_matrix)>4
ax=tot_vac_matrix(:,1); ay=tot_vac_matrix(:,2); az=tot_vac_matrix(:,3);%%%%% distances to vac membranes
counter=[];
for i=1:numves; 
    bx=ax-ax+tot_mit_matrix(i,1); by=ax-ax+tot_mit_matrix(i,2); bz=ax-ax+tot_mit_matrix(i,3); 
    dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
    try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
end;
ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(8,22)=mean(counter);
end;

% if numel(tot_mit_matrix)>4
% ax=tot_mit_matrix(:,1); ay=tot_mit_matrix(:,2); az=tot_mit_matrix(:,3);%%%%% distances to mitoch membranes
% counter=[];
% for i=1:numves; 
%     bx=ax-ax+tot_vac_matrix(i,1); by=ax-ax+tot_vac_matrix(i,2); bz=ax-ax+tot_vac_matrix(i,3); 
%     dists=sqrt((ax-bx).^2+(ay-by).^2+(az-bz).^2);
%     try; ccc=find(dists>0); dists=dists(ccc); counter(i)=min(dists);catch; counter(i)=-1; end;
% end;
% ccc=find(counter>-1); counter=counter(ccc);val_matrix_dist(9,22)=mean(counter);
% end;

end;




dlmwrite('all_val_matrix.txt',val_matrix);
dlmwrite('all_val_matrix_dist.txt',val_matrix_dist);

end;

end;
    
    