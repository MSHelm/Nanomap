function vesan

global movi rr xx yy filename chol b2 Movi3 pixel_size image_matrix positioner pixel_size limits
global list mapname b rows cols A q s ijj jjj r1 firstred olds inner_radius outer_radius matrix backmatrix old_movi
global alignsx alignsy rect fused not_fused sh hex hey rr1 imagenr

%%%%%this folder shouldcontain subfolders for the individual experiments
cd 'F:\data_2012\katharina_new_analysis';


cellb={};
[dsstat, dmmess]=fileattrib('*');
for i=1:numel(dmmess)
    if dmmess(i).directory
        cellb{numel(cellb)+1}=dmmess(i).Name;
    end;
end;


for abcdef=1:numel(cellb);
    

    abcdef*100/numel(cellb)
    name=cellb{abcdef};
    cd(name);

[stat1, mess_sted]=fileattrib('*STED*STED.mat');
[stat2, mess_confocal]=fileattrib('*confocal*confocal.mat');
if stat1
for i=1:numel(mess_sted)
    load(mess_sted(i).Name);
nn=mess_sted(i).Name; nn=nn(1:numel(nn)-4);
ccc=find(pols==0); m2=movi(:,:,2); m2(ccc)=mean(m2(ccc));
ccc=find(m2<5*mean2(m2)+5*std2(m2)); m2a=m2; m2a(ccc)=0;
 m2b=m2a-m2a; ccc=find(m2a>0); m2b(ccc)=1; m2b=imerode(m2b,strel('disk',3)); m2b=imdilate(m2b,strel('disk',3)); 
 ccc=find(m2b==0); m2a(ccc)=0;
 m2c=bwlabel(m2b);

 for j=1:max(max(m2c))
         ccc=find(m2c==j);
         siz=size(movi);
         [xx yy]=ind2sub([siz(1) siz(2)],ccc);
         mm=m2(ccc);
         bluex=round(sum(xx.*mm)/sum(mm));
         bluey=round(sum(yy.*mm)/sum(mm));
         try; 
         prp=zeros(201,201,3);
         prp(:,:,1)=movi(bluex-100:bluex+100,bluey-100:bluey+100,2);
         prp(:,:,2)=movi(bluex-100:bluex+100,bluey-100:bluey+100,3);
         prp(:,:,3)=movi(bluex-100:bluex+100,bluey-100:bluey+100,1);
         dlmwrite(strcat(nn,'_',num2str(j),'_STEDspot.txt'),prp);
         catch; end;
 end;
 
 
end
end

if stat2

for i=1:numel(mess_confocal)
    load(mess_confocal(i).Name);
nn=mess_confocal(i).Name; nn=nn(1:numel(nn)-4);
ccc=find(pols==0); m2=movi(:,:,2); m2(ccc)=mean(m2(ccc));
ccc=find(m2<2*mean2(m2)+2*std2(m2)); m2a=m2; m2a(ccc)=0;
 m2b=m2a-m2a; ccc=find(m2a>0); m2b(ccc)=1; m2b=imerode(m2b,strel('disk',3)); m2b=imdilate(m2b,strel('disk',3)); 
 ccc=find(m2b==0); m2a(ccc)=0;
  m2c=bwlabel(m2b);

for j=1:max(max(m2c))
         ccc=find(m2c==j);
         siz=size(movi);
         [xx yy]=ind2sub([siz(1) siz(2)],ccc);
         mm=m2(ccc);
         bluex=round(sum(xx.*mm)/sum(mm));
         bluey=round(sum(yy.*mm)/sum(mm));
         try; 
         prp=zeros(201,201,3);
         prp(:,:,1)=movi(bluex-100:bluex+100,bluey-100:bluey+100,2);
         prp(:,:,2)=movi(bluex-100:bluex+100,bluey-100:bluey+100,3);
         prp(:,:,3)=movi(bluex-100:bluex+100,bluey-100:bluey+100,1);
         dlmwrite(strcat(nn,'_',num2str(j),'_confocalspot.txt'),prp);
         catch; end;
 end;
  
end
end

end


