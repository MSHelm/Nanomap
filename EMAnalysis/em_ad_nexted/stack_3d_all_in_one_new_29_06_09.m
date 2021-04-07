function stack_3d;
azx=[];azy=[];mx=[];my=[];cx=[];cy=[];pvesx=[];pvesy=[];uvesx=[];uvesy=[];dimensx=0;dimensy=0;mz=[];azz=[];cz=[];uvesz=[];pvesz=[];

cd ('C:\data_2012\spines\test_spine1');

pixel_size=3.067; % nm
dicke=70;


dicke=dicke/pixel_size;
basename='*_numbers*.txt';

%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
% Active zone - x = first column; y=second column
% Membrane - x = 3rd column; y=4th colum
% Normal vesicles - x = 5th column; y = 6th column
% dense-core vesicles - x = 7th column; y = 8th column [empty for now, as we have not seen any]
% Normal vesicles, distance to the active zone = 9th column - not useful
% for 3D
% Normal vesicles, distance to the membrane = 10th column - not useful for
% 3D
% dense-core vesicles, distance to the active zone = 11th column - not useful for
% 3D
% dense-core vesicles, distance to the membrane = 12th column - not useful for
% 3D
% Vacuoles - x = 13th column; y=14th column
% Mitochondria - x = 15th column; y=16th column
% The vacuole separators (index number) are in column 17 [for all the x
% and y values of the first vacuole (in columns 13 and 14) this column will have ones in the
% respective positions; for the second vacuole in the particular image
% there will be twos, etc.
% The mitochondria separators (index number) are in column 18 - same as for
% vacuoles
% Column 19 does nothing
% note that all columns are padded with zeros 
% all values are in pixels - and pixel size is 2.2 nm
% the distance between sections, or in other words the section thickness,
% is 70 nm (approximately, of course)
% we expect that the structures shrunk by ~20% versus the original
% situation


[stat, mess]=fileattrib(strcat(basename))
start=1;


% for i=1:numel(mess)
%     a=dlmread(mess(i).Name);
%     a(:,1:16)=a(:,1:16)*pixel_size;
%     dlmwrite(mess(i).Name,a);
% end;

finish=numel(mess);

disp('working on unlabeled vacuoles and making their vertices');

vac_verts_nr=1;

for i=start:finish-1
    
    

    
    
    r1=(mess(i).Name);
    r2=(mess(i+1).Name);
    
    



    
bigmatrix=dlmread(r1);
finder=find(bigmatrix(:,17))>0;
findernr=numel(finder);
%vacx=bigmatrix(1:findernr,13);
%vacy=bigmatrix(1:findernr,14);
vacx=[]; vacy=[]; 

aftmatrix=dlmread(r2);
afinder=find(aftmatrix(:,17))>0;
afindernr=numel(afinder);
%avacx=aftmatrix(1:afindernr,13);
%avacy=aftmatrix(1:afindernr,14);
avacx=[]; avacy=[];


    counters=bigmatrix(:,17);
    xes=bigmatrix(:,13);
    yes=bigmatrix(:,14);
for j=1:max(bigmatrix(:,17))
    ccc=find(counters==j);
    vacx(1:numel(ccc),j)=xes(ccc);
    vacy(1:numel(ccc),j)=yes(ccc);
end;

    counters=aftmatrix(:,17);
    xes=aftmatrix(:,13);
    yes=aftmatrix(:,14);
for j=1:max(aftmatrix(:,17))
    ccc=find(counters==j);
    avacx(1:numel(ccc),j)=xes(ccc);
    avacy(1:numel(ccc),j)=yes(ccc);
end;

sizebig=size(vacx);
sizeaft=size(avacx);



if findernr>0
for j=1:sizebig(2)
    has_found=0;
        ccc=find(vacx(:,j)>0);
        xes=vacx(1:numel(ccc),j);
        yes=vacy(1:numel(ccc),j);
        
        
        if afindernr>0
        
         for k=1:sizeaft(2)
        ccc=find(avacx(:,k)>0);
        aes=avacx(1:numel(ccc),k);
        bes=avacy(1:numel(ccc),k);
        
        mat_xes=repmat(xes,1,numel(aes));
        mat_yes=repmat(yes,1,numel(aes));
   
        
        mat_aes=repmat(aes',numel(xes),1);
        mat_bes=repmat(bes',numel(xes),1);
 
        
        diffx=mat_xes - mat_aes; diffx=diffx.^2;
        diffy=mat_yes - mat_bes; diffy=diffy.^2;
        diff=sqrt(diffx + diffy);
        
        siz=size(diff);
        if siz(1)<siz(2) | siz(1)==siz(2)
            diff_min=min(diff');
        else
            diff_min=min(diff);
        end;       
        
        if mean2(diff_min)<200
            has_found=1;
            if numel(xes)>numel(aes) | numel(xes)==numel(aes)
                
            
vx=[];vy=[];
for kk=1:numel(xes)
    x=xes(kk);y=yes(kk);
    distx=[];disty=[];
    distx=aes;
    disty=bes;
    distx(:)=distx(:)-x;
    disty(:)=disty(:)-y;
    distx(:)=distx(:).^2;
    disty(:)=disty(:).^2;
    distx=distx+disty;
    distx(:)=sqrt(distx(:));
    mm=min(distx);
    p=find(distx==mm);
  
   vx(kk)=aes(min(p));
   vy(kk)=bes(min(p));
 
     
   
   
end;

vz=[]; vz=vy; vz(:)=i*dicke;

vac_vert=[];
siz_vac_vert=size(vac_vert);


zes=xes; zes(:)=(i-1)*dicke;
vac_vert(siz_vac_vert(1)+1:siz_vac_vert(1)+numel(xes),1)=xes;
vac_vert(siz_vac_vert(1)+1:siz_vac_vert(1)+numel(xes),2)=yes;
vac_vert(siz_vac_vert(1)+1:siz_vac_vert(1)+numel(xes),3)=zes;
vac_vert(siz_vac_vert(1)+numel(xes)+1:siz_vac_vert(1)+numel(xes)+numel(xes),1)=vx';
vac_vert(siz_vac_vert(1)+numel(xes)+1:siz_vac_vert(1)+numel(xes)+numel(xes),2)=vy';
vac_vert(siz_vac_vert(1)+numel(xes)+1:siz_vac_vert(1)+numel(xes)+numel(xes),3)=vz';

dlmwrite(strcat('vac_vert',num2str(vac_verts_nr),'.txt'),vac_vert);

vac_verts_nr=vac_verts_nr+1;
 else
                
vx=[];vy=[];
for kk=1:numel(aes)
    x=aes(kk);y=bes(kk);
    distx=[];disty=[];
    distx=xes;
    disty=yes;
    distx(:)=distx(:)-x;
    disty(:)=disty(:)-y;
    distx(:)=distx(:).^2;
    disty(:)=disty(:).^2;
    distx=distx+disty;
    distx(:)=sqrt(distx(:));
    mm=min(distx);
    p=find(distx==mm);
  
   vx(kk)=xes(min(p));
   vy(kk)=yes(min(p));
end;

vz=[]; vz=vy; vz(:)=(i-1)*dicke;

vac_vert=[];
siz_vac_vert=size(vac_vert);


azes=aes; azes(:)=(i)*dicke;
vac_vert(siz_vac_vert(1)+1:siz_vac_vert(1)+numel(vx),1)=vx';
vac_vert(siz_vac_vert(1)+1:siz_vac_vert(1)+numel(vx),2)=vy';
vac_vert(siz_vac_vert(1)+1:siz_vac_vert(1)+numel(vx),3)=vz';
vac_vert(siz_vac_vert(1)+numel(vx)+1:siz_vac_vert(1)+numel(vx)+numel(aes),1)=aes;
vac_vert(siz_vac_vert(1)+numel(vx)+1:siz_vac_vert(1)+numel(vx)+numel(aes),2)=bes;
vac_vert(siz_vac_vert(1)+numel(vx)+1:siz_vac_vert(1)+numel(vx)+numel(aes),3)=azes;

dlmwrite(strcat('vac_vert',num2str(vac_verts_nr),'.txt'),vac_vert);

vac_verts_nr=vac_verts_nr+1;

            end;
        end;
         end;
        end;
        
        if has_found==0
        
         centerx=round(mean(xes));
         centery=round(mean(yes)); 
         vac_vert=[];
 siz_vac_vert=size(vac_vert);
 
         vx=xes;vy=yes;vx(:)=centerx; vy(:)=centery;
         vz=vx; vz(:)=dicke*(i-1);
      siz_vac_vert=size(vac_vert);   
 vac_vert(siz_vac_vert(1)+1:siz_vac_vert(1)+numel(xes),1)=vx';
 vac_vert(siz_vac_vert(1)+1:siz_vac_vert(1)+numel(xes),2)=vy';
 vac_vert(siz_vac_vert(1)+1:siz_vac_vert(1)+numel(xes),3)=vz';
 vac_vert(siz_vac_vert(1)+numel(xes)+1:siz_vac_vert(1)+numel(xes)+numel(xes),1)=xes;
 vac_vert(siz_vac_vert(1)+numel(xes)+1:siz_vac_vert(1)+numel(xes)+numel(xes),2)=yes;
 vac_vert(siz_vac_vert(1)+numel(xes)+1:siz_vac_vert(1)+numel(xes)+numel(xes),3)=vz;
 dlmwrite(strcat('vac_vert',num2str(vac_verts_nr),'.txt'),vac_vert);
 
 vac_verts_nr=vac_verts_nr+1;

        end
end;

end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sizebig=size(vacx);
sizeaft=size(avacx);

if afindernr>0
for j=1:sizeaft(2)
    has_found=0;
        ccc=find(avacx(:,j)>0);
        xes=avacx(1:numel(ccc),j);
        yes=avacy(1:numel(ccc),j);
        
        
        if findernr>0
        
         for k=1:sizebig(2)
        ccc=find(vacx(:,k)>0);
        aes=vacx(1:numel(ccc),k);
        bes=vacy(1:numel(ccc),k);
        
        mat_xes=repmat(xes,1,numel(aes));
        mat_yes=repmat(yes,1,numel(aes));
   
        
        mat_aes=repmat(aes',numel(xes),1);
        mat_bes=repmat(bes',numel(xes),1);
 
        
        diffx=mat_xes - mat_aes; diffx=diffx.^2;
        diffy=mat_yes - mat_bes; diffy=diffy.^2;
        diff=sqrt(diffx + diffy);
        
        siz=size(diff);
        if siz(1)<siz(2) | siz(1)==siz(2)
            diff_min=min(diff');
        else
            diff_min=min(diff);
        end;       
        
        if mean2(diff_min)<20
            has_found=1;
        end;
         end;
        end;
        
        if has_found==0
        
         centerx=round(mean(xes));
         centery=round(mean(yes)); 
         vac_vert=[];
 siz_vac_vert=size(vac_vert);
 
         vx=xes;vy=yes;vx(:)=centerx; vy(:)=centery;
         vz=vx; vz(:)=dicke*(i);
      siz_vac_vert=size(vac_vert);   
 vac_vert(siz_vac_vert(1)+1:siz_vac_vert(1)+numel(xes),1)=vx';
 vac_vert(siz_vac_vert(1)+1:siz_vac_vert(1)+numel(xes),2)=vy';
 vac_vert(siz_vac_vert(1)+1:siz_vac_vert(1)+numel(xes),3)=vz';
 vac_vert(siz_vac_vert(1)+numel(xes)+1:siz_vac_vert(1)+numel(xes)+numel(xes),1)=xes;
 vac_vert(siz_vac_vert(1)+numel(xes)+1:siz_vac_vert(1)+numel(xes)+numel(xes),2)=yes;
 vac_vert(siz_vac_vert(1)+numel(xes)+1:siz_vac_vert(1)+numel(xes)+numel(xes),3)=vz;
 dlmwrite(strcat('vac_vert',num2str(vac_verts_nr),'.txt'),vac_vert);
 
 vac_verts_nr=vac_verts_nr+1;

        end;
end;


end;
end;
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Make vacuole faces');

[stat, mess]=fileattrib('vac_vert*.txt');
if stat==1
for i=1:numel(mess)
    disp(i);
    supraf=[];vert=[];
  
    vert=dlmread(strcat('vac_vert',num2str(i),'.txt'));
      if numel(vert)>6
    juma=round(numel(vert)/6);
    for k=1:juma-1
        supraf(k,1)=k;
        supraf(k,2)=juma+k;
        supraf(k,3)=juma+k+1;
        supraf(k,4)=k+1;
    end;
    
     supraf(juma,1)=juma;
        supraf(juma,2)=2*juma;
        supraf(juma,3)=juma+1;
        supraf(juma,4)=1;
    end;
dlmwrite(strcat('vac_supraf',num2str(i),'.txt'),supraf);

end;
end;





%for i=start:finish-1
% vert=dlmread(strcat('mvert',num2str(i),'.txt'));
% supraf=dlmread(strcat('msupraf',num2str(i),'.txt'));
% p=patch('vertices',vert,'faces',supraf,'edgecolor','none','edgealpha',0,'facecolor',[1 0.5 0],'facealpha',0.2);
% reducepatch(p,0.1);
%end;
%drawnow;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


disp('working on labeled vacuoles and making their vertices');

vac_verts_nr=1;

for i=start:finish-1
    
[stat, mess]=fileattrib(strcat(basename))
    disp(i);
    r1=(mess(i).Name)
    r2=(mess(i+1).Name);

    
bigmatrix=dlmread(r1);
finder=find(bigmatrix(:,18))>0;
findernr=numel(finder);
%vacx=bigmatrix(1:findernr,13);
%vacy=bigmatrix(1:findernr,14);
vacx=[]; vacy=[]; 

aftmatrix=dlmread(r2);
afinder=find(aftmatrix(:,18))>0;
afindernr=numel(afinder);
%avacx=aftmatrix(1:afindernr,13);
%avacy=aftmatrix(1:afindernr,14);
avacx=[]; avacy=[];


    counters=bigmatrix(:,18);
    xes=bigmatrix(:,15);
    yes=bigmatrix(:,16);
for j=1:max(bigmatrix(:,18))
    ccc=find(counters==j);
    vacx(1:numel(ccc),j)=xes(ccc);
    vacy(1:numel(ccc),j)=yes(ccc);
end;

    counters=aftmatrix(:,18);
    xes=aftmatrix(:,15);
    yes=aftmatrix(:,16);
for j=1:max(aftmatrix(:,18))
    ccc=find(counters==j);
    avacx(1:numel(ccc),j)=xes(ccc);
    avacy(1:numel(ccc),j)=yes(ccc);
end;

sizebig=size(vacx);
sizeaft=size(avacx);



if findernr>0
for j=1:sizebig(2)
    has_found=0;
        ccc=find(vacx(:,j)>0);
        xes=vacx(1:numel(ccc),j);
        yes=vacy(1:numel(ccc),j);
        
        
        if afindernr>0
        
         for k=1:sizeaft(2)
        ccc=find(avacx(:,k)>0);
        aes=avacx(1:numel(ccc),k);
        bes=avacy(1:numel(ccc),k);
        
        mat_xes=repmat(xes,1,numel(aes));
        mat_yes=repmat(yes,1,numel(aes));
   
        
        mat_aes=repmat(aes',numel(xes),1);
        mat_bes=repmat(bes',numel(xes),1);
 
        
        diffx=mat_xes - mat_aes; diffx=diffx.^2;
        diffy=mat_yes - mat_bes; diffy=diffy.^2;
        diff=sqrt(diffx + diffy);
        
        siz=size(diff);
        if siz(1)<siz(2) | siz(1)==siz(2)
            diff_min=min(diff');
        else
            diff_min=min(diff);
        end;       
        
        if mean2(diff_min)<500
            has_found=1;
            if numel(xes)>numel(aes) | numel(xes)==numel(aes)
                
            
vx=[];vy=[];
for kk=1:numel(xes)
    x=xes(kk);y=yes(kk);
    distx=[];disty=[];
    distx=aes;
    disty=bes;
    distx(:)=distx(:)-x;
    disty(:)=disty(:)-y;
    distx(:)=distx(:).^2;
    disty(:)=disty(:).^2;
    distx=distx+disty;
    distx(:)=sqrt(distx(:));
    mm=min(distx);
    p=find(distx==mm);
  
   vx(kk)=aes(min(p));
   vy(kk)=bes(min(p));
 
     
   
   
end;

vz=[]; vz=vy; vz(:)=i*dicke;

vac_vert=[];
siz_vac_vert=size(vac_vert);


zes=xes; zes(:)=(i-1)*dicke;
vac_vert(siz_vac_vert(1)+1:siz_vac_vert(1)+numel(xes),1)=xes;
vac_vert(siz_vac_vert(1)+1:siz_vac_vert(1)+numel(xes),2)=yes;
vac_vert(siz_vac_vert(1)+1:siz_vac_vert(1)+numel(xes),3)=zes;
vac_vert(siz_vac_vert(1)+numel(xes)+1:siz_vac_vert(1)+numel(xes)+numel(xes),1)=vx';
vac_vert(siz_vac_vert(1)+numel(xes)+1:siz_vac_vert(1)+numel(xes)+numel(xes),2)=vy';
vac_vert(siz_vac_vert(1)+numel(xes)+1:siz_vac_vert(1)+numel(xes)+numel(xes),3)=vz';

dlmwrite(strcat('black_vac_vert',num2str(vac_verts_nr),'.txt'),vac_vert);

vac_verts_nr=vac_verts_nr+1;
 else
                
vx=[];vy=[];
for kk=1:numel(aes)
    x=aes(kk);y=bes(kk);
    distx=[];disty=[];
    distx=xes;
    disty=yes;
    distx(:)=distx(:)-x;
    disty(:)=disty(:)-y;
    distx(:)=distx(:).^2;
    disty(:)=disty(:).^2;
    distx=distx+disty;
    distx(:)=sqrt(distx(:));
    mm=min(distx);
    p=find(distx==mm);
  
   vx(kk)=xes(min(p));
   vy(kk)=yes(min(p));
end;

vz=[]; vz=vy; vz(:)=(i-1)*dicke;

vac_vert=[];
siz_vac_vert=size(vac_vert);


azes=aes; azes(:)=(i)*dicke;
vac_vert(siz_vac_vert(1)+1:siz_vac_vert(1)+numel(vx),1)=vx';
vac_vert(siz_vac_vert(1)+1:siz_vac_vert(1)+numel(vx),2)=vy';
vac_vert(siz_vac_vert(1)+1:siz_vac_vert(1)+numel(vx),3)=vz';
vac_vert(siz_vac_vert(1)+numel(vx)+1:siz_vac_vert(1)+numel(vx)+numel(aes),1)=aes;
vac_vert(siz_vac_vert(1)+numel(vx)+1:siz_vac_vert(1)+numel(vx)+numel(aes),2)=bes;
vac_vert(siz_vac_vert(1)+numel(vx)+1:siz_vac_vert(1)+numel(vx)+numel(aes),3)=azes;

dlmwrite(strcat('black_vac_vert',num2str(vac_verts_nr),'.txt'),vac_vert);

vac_verts_nr=vac_verts_nr+1;

            end;
        end;
         end;
        end;
        
        if has_found==0
        
         centerx=round(mean(xes));
         centery=round(mean(yes)); 
         vac_vert=[];
 siz_vac_vert=size(vac_vert);
 
         vx=xes;vy=yes;vx(:)=centerx; vy(:)=centery;
         vz=vx; vz(:)=dicke*(i-1);
      siz_vac_vert=size(vac_vert);   
 vac_vert(siz_vac_vert(1)+1:siz_vac_vert(1)+numel(xes),1)=vx';
 vac_vert(siz_vac_vert(1)+1:siz_vac_vert(1)+numel(xes),2)=vy';
 vac_vert(siz_vac_vert(1)+1:siz_vac_vert(1)+numel(xes),3)=vz';
 vac_vert(siz_vac_vert(1)+numel(xes)+1:siz_vac_vert(1)+numel(xes)+numel(xes),1)=xes;
 vac_vert(siz_vac_vert(1)+numel(xes)+1:siz_vac_vert(1)+numel(xes)+numel(xes),2)=yes;
 vac_vert(siz_vac_vert(1)+numel(xes)+1:siz_vac_vert(1)+numel(xes)+numel(xes),3)=vz;
 dlmwrite(strcat('black_vac_vert',num2str(vac_verts_nr),'.txt'),vac_vert);
 
 vac_verts_nr=vac_verts_nr+1;

        end
end;

end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sizebig=size(vacx);
sizeaft=size(avacx);

if afindernr>0
for j=1:sizeaft(2)
    has_found=0;
        ccc=find(avacx(:,j)>0);
        xes=avacx(1:numel(ccc),j);
        yes=avacy(1:numel(ccc),j);
        
        
        if findernr>0
        
         for k=1:sizebig(2)
        ccc=find(vacx(:,k)>0);
        aes=vacx(1:numel(ccc),k);
        bes=vacy(1:numel(ccc),k);
        
        mat_xes=repmat(xes,1,numel(aes));
        mat_yes=repmat(yes,1,numel(aes));
   
        
        mat_aes=repmat(aes',numel(xes),1);
        mat_bes=repmat(bes',numel(xes),1);
 
        
        diffx=mat_xes - mat_aes; diffx=diffx.^2;
        diffy=mat_yes - mat_bes; diffy=diffy.^2;
        diff=sqrt(diffx + diffy);
        
        siz=size(diff);
        if siz(1)<siz(2) | siz(1)==siz(2)
            diff_min=min(diff');
        else
            diff_min=min(diff);
        end;       
        
        if mean2(diff_min)<500
            has_found=1;
        end;
         end;
        end;
        
        if has_found==0
        
         centerx=round(mean(xes));
         centery=round(mean(yes)); 
         vac_vert=[];
 siz_vac_vert=size(vac_vert);
 
         vx=xes;vy=yes;vx(:)=centerx; vy(:)=centery;
         vz=vx; vz(:)=dicke*(i);
      siz_vac_vert=size(vac_vert);   
 vac_vert(siz_vac_vert(1)+1:siz_vac_vert(1)+numel(xes),1)=vx';
 vac_vert(siz_vac_vert(1)+1:siz_vac_vert(1)+numel(xes),2)=vy';
 vac_vert(siz_vac_vert(1)+1:siz_vac_vert(1)+numel(xes),3)=vz';
 vac_vert(siz_vac_vert(1)+numel(xes)+1:siz_vac_vert(1)+numel(xes)+numel(xes),1)=xes;
 vac_vert(siz_vac_vert(1)+numel(xes)+1:siz_vac_vert(1)+numel(xes)+numel(xes),2)=yes;
 vac_vert(siz_vac_vert(1)+numel(xes)+1:siz_vac_vert(1)+numel(xes)+numel(xes),3)=vz;
 dlmwrite(strcat('black_vac_vert',num2str(vac_verts_nr),'.txt'),vac_vert);
 
 vac_verts_nr=vac_verts_nr+1;

        end;
end;


end;
end;
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Make vacuole faces');

[stat, mess]=fileattrib('black_vac_vert*.txt');
if stat==1
for i=1:numel(mess)
    disp(i);
    supraf=[];vert=[];
  
    vert=dlmread(strcat('black_vac_vert',num2str(i),'.txt'));
      if numel(vert)>6
    juma=round(numel(vert)/6);
    for k=1:juma-1
        supraf(k,1)=k;
        supraf(k,2)=juma+k;
        supraf(k,3)=juma+k+1;
        supraf(k,4)=k+1;
    end;
    
     supraf(juma,1)=juma;
        supraf(juma,2)=2*juma;
        supraf(juma,3)=juma+1;
        supraf(juma,4)=1;
    end;
dlmwrite(strcat('black_vac_supraf',num2str(i),'.txt'),supraf);

end;

end;




%for i=start:finish-1
% vert=dlmread(strcat('mvert',num2str(i),'.txt'));
% supraf=dlmread(strcat('msupraf',num2str(i),'.txt'));
% p=patch('vertices',vert,'faces',supraf,'edgecolor','none','edgealpha',0,'facecolor',[1 0.5 0],'facealpha',0.2);
% reducepatch(p,0.1);
%end;
%drawnow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Make membrane distances');
for i=start:finish-1
    [stat, mess]=fileattrib(strcat(basename))
disp(i);
    r1=(mess(i).Name);
    r2=(mess(i+1).Name);
  vert=[];
bigmatrix=dlmread(r1);
%dimensx=bigmatrix(1,11);
%dimensy=bigmatrix(1,12);

%Membrane - x = 3rd column; y=4th column
finder=find(bigmatrix(:,3))>0;
findernr=numel(finder);
mx=bigmatrix(1:findernr,3);
my=bigmatrix(1:findernr,4);

aftmatrix=dlmread(r2);

afinder=find(aftmatrix(:,3))>0;
afindernr=numel(afinder);
amx=aftmatrix(1:afindernr,3);
amy=aftmatrix(1:afindernr,4);

if numel(mx)>numel(amx) | numel(mx)==numel(amx)
    
vx=[];vy=[];
for k=1:numel(mx)
    x=mx(k);y=my(k);
    distx=[];disty=[];
    distx=amx;
    disty=amy;
    distx(:)=distx(:)-x;
    disty(:)=disty(:)-y;
    distx(:)=distx(:).^2;
    disty(:)=disty(:).^2;
    distx=distx+disty;
    distx(:)=sqrt(distx(:));
    mm=min(distx);
    p=find(distx==mm);
  
   vx(k)=amx(min(p));
   vy(k)=amy(min(p));
end;
%dlmwrite(strcat('mvx',num2str(i),'.txt'),vx);
%dlmwrite(strcat('mvy',num2str(i),'.txt'),vy);


mz=my;mz(:)=dicke*(i-1);
vz=vy;vz(:)=dicke*(i);

vert(1:numel(mx),1)=mx;
vert(1:numel(mx),2)=my;
vert(1:numel(mx),3)=mz;
vert(numel(mx)+1:numel(vx)+numel(mx),1)=vx';
vert(numel(mx)+1:numel(vx)+numel(mx),2)=vy';
vert(numel(mx)+1:numel(vx)+numel(mx),3)=vz';

dlmwrite(strcat('mvert',num2str(i),'.txt'),vert);

else
    
vx=[];vy=[];
for k=1:numel(amx)
    x=amx(k);y=amy(k);
    distx=[];disty=[];
    distx=mx;
    disty=my;
    distx(:)=distx(:)-x;
    disty(:)=disty(:)-y;
    distx(:)=distx(:).^2;
    disty(:)=disty(:).^2;
    distx=distx+disty;
    distx(:)=sqrt(distx(:));
    mm=min(distx);
    p=find(distx==mm);
  
   vx(k)=mx(min(p));
   vy(k)=my(min(p));
end;
%dlmwrite(strcat('mvx',num2str(i),'.txt'),vx);
%dlmwrite(strcat('mvy',num2str(i),'.txt'),vy);


amz=amy;amz(:)=dicke*(i);
vz=vy;vz(:)=dicke*(i-1);


% vert(1:numel(amx),1)=amx;
% vert(1:numel(amx),2)=amy;
% vert(1:numel(amx),3)=amz;
vert(1:numel(vx),1)=vx';
vert(1:numel(vy),2)=vy';
vert(1:numel(vz),3)=vz';
vert(numel(vx)+1:numel(vx)+numel(amx),1)=amx;
vert(numel(vx)+1:numel(vx)+numel(amx),2)=amy;
vert(numel(vx)+1:numel(vx)+numel(amx),3)=amz;

dlmwrite(strcat('mvert',num2str(i),'.txt'),vert);
    
end;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% disp('Make membrane vertices');
% for i=start:finish-1
%     
% disp(i);
% mx=[];my=[];vx=[];vy=[];vert=[];mz=[];vz=[];
% 
% [stat, mess]=fileattrib(strcat(basename))
%     r1=(mess(i).Name);
%     r2=(mess(i+1).Name);
% 
% bigmatrix=dlmread(r1);
% %%dimensx=bigmatrix(1,11);
% %%dimensy=bigmatrix(1,12);
% 
% 
% finder=find(bigmatrix(:,3))>0;
% findernr=numel(finder);
% mx=bigmatrix(1:findernr,3);
% my=bigmatrix(1:findernr,4);
% 
% mz=my;mz(:)=dicke*(i-1);
% 
% vx=dlmread(strcat('mvx',num2str(i),'.txt'));
% vy=dlmread(strcat('mvy',num2str(i),'.txt'));
% vz=vy;vz(:)=dicke*(i);
% 
% vert(1:numel(mx),1)=mx;
% vert(1:numel(mx),2)=my;
% vert(1:numel(mx),3)=mz;
% vert(numel(mx)+1:numel(vx)+numel(mx),1)=vx';
% vert(numel(mx)+1:numel(vx)+numel(mx),2)=vy';
% vert(numel(mx)+1:numel(vx)+numel(mx),3)=vz';
% 
% 
% dlmwrite(strcat('mvert',num2str(i),'.txt'),vert);
% 
% 
% end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Make membrane faces');

for i=start:finish-1
    disp(i);
    supraf=[];vert=[];
    vert=dlmread(strcat('mvert',num2str(i),'.txt'));
    juma=round(numel(vert)/6);
    for k=1:juma-1
        supraf(k,1)=k;
        supraf(k,2)=juma+k;
        supraf(k,3)=juma+k+1;
        supraf(k,4)=k+1;
    end;
    
     supraf(juma,1)=juma;
        supraf(juma,2)=2*juma;
        supraf(juma,3)=juma+1;
        supraf(juma,4)=1;
dlmwrite(strcat('msupraf',num2str(i),'.txt'),supraf);

end;






%for i=start:finish-1
% vert=dlmread(strcat('mvert',num2str(i),'.txt'));
% supraf=dlmread(strcat('msupraf',num2str(i),'.txt'));
% p=patch('vertices',vert,'faces',supraf,'edgecolor','none','edgealpha',0,'facecolor',[1 0.5 0],'facealpha',0.2);
% reducepatch(p,0.1);
%end;
%drawnow;




disp('Active zone distances and vertices');
    
    az_counter=1;

for i=start:finish-1
    
disp(i);
[stat, mess]=fileattrib(strcat(basename));
    first=num2str(i);
    second=num2str(i+1);
    r1=(mess(i).Name);
    r2=(mess(i+1).Name);

bigmatrix=dlmread(r1);

finder=find(bigmatrix(:,1))>0;
findernr=numel(finder);
ax=bigmatrix(1:findernr,1);
ay=bigmatrix(1:findernr,2);

aftmatrix=dlmread(r2);
afinder=find(aftmatrix(:,3))>0;
afindernr=numel(afinder);
aax=aftmatrix(1:afindernr,3);
aay=aftmatrix(1:afindernr,4);

vx=[];vy=[];
if findernr>0 & afindernr>0



pieces=[];
pieces(1)=1;

for k=1:numel(ax)-1
    x=ax(k); y=ay(k);
    xx=ax(k+1); yy=ay(k+1);
    
    distance=sqrt((x-xx)^2+(y-yy)^2);
    if distance>2
        pieces(numel(pieces)+1)=k;
    end;
end;

pieces(numel(pieces)+1)=numel(ax);



for j=2:numel(pieces)
    
    nrpix=pieces(j)-pieces(j-1)-1;
    vx=[];vy=[];
    vert=[];
    for k=pieces(j-1)+1:pieces(j)-1
    x=ax(k);y=ay(k);
    distx=[];disty=[];
    distx=aax;
    disty=aay;
    distx(:)=distx(:)-x;
    disty(:)=disty(:)-y;
    distx(:)=distx(:).^2;
    disty(:)=disty(:).^2;
    distx=distx+disty;
    distx(:)=sqrt(distx(:));
    mm=min(distx);
    p=find(distx==mm);
    vx(numel(vx)+1)=aax(min(p));
    vy(numel(vy)+1)=aay(min(p));
    
    vert(numel(vx),1)=ax(k);
    vert(numel(vx),2)=ay(k);
    vert(numel(vx),3)=dicke*(i-1);
    
    vert(nrpix+numel(vx),1)=vx(numel(vx));
    vert(nrpix+numel(vx),2)=vy(numel(vx));
    vert(nrpix+numel(vx),3)=dicke*i;
    
    end;

dlmwrite(strcat('avert',num2str(az_counter),'.txt'),vert);
az_counter=az_counter+1;
end;

end;

end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% disp('Make AZ vertices');
% for i=start:finish-1
% disp(i);
% ax=[];ay=[];vx=[];vy=[];vert=[];az=[];vz=[];
% [stat, mess]=fileattrib(strcat(basename))
%     r1=(mess(i).Name);
%     r2=(mess(i+1).Name);
% 
%     
% 
% bigmatrix=dlmread(r1);
% %dimensx=bigmatrix(1,11);
% %dimensy=bigmatrix(1,12);
% 
% finder=find(bigmatrix(:,1))>0;
% findernr=numel(finder);
% ax=bigmatrix(1:findernr,1);
% ay=bigmatrix(1:findernr,2);
% az=ay;az(:)=dicke*(i-1);
% 
% 
% vx=dlmread(strcat('avx',num2str(i),'.txt'));
% vy=dlmread(strcat('avy',num2str(i),'.txt'));
% vz=vy;vz(:)=dicke*(i);
% if numel(vx)>0 & numel(ax)>0
% vert(1:numel(ax),1)=ax;
% vert(1:numel(ax),2)=ay;
% vert(1:numel(ax),3)=az;
% vert(numel(ax)+1:numel(vx)+numel(ax),1)=vx';
% vert(numel(ax)+1:numel(vx)+numel(ax),2)=vy';
% vert(numel(ax)+1:numel(vx)+numel(ax),3)=vz';
% end;
% dlmwrite(strcat('avert',num2str(i),'.txt'),vert);
% 
% end;
try
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Make active zone faces');

[stat, mess]=fileattrib('avert*.txt');

for i=1:numel(mess)
    disp(i);
    supraf=[];vert=[];
  
    vert=dlmread(strcat('avert',num2str(i),'.txt'));
      if numel(vert)>6
    juma=round(numel(vert)/6);
    for k=1:juma-1
        supraf(k,1)=k;
        supraf(k,2)=juma+k;
        supraf(k,3)=juma+k+1;
        supraf(k,4)=k+1;
    end;
    
     supraf(juma,1)=juma;
        supraf(juma,2)=2*juma;
        supraf(juma,3)=juma+1;
        supraf(juma,4)=1;
    end;
dlmwrite(strcat('asupraf',num2str(i),'.txt'),supraf);

end;

catch
end

%for i=start:finish-1
% vert=dlmread(strcat('avert',num2str(i),'.txt'));
% supraf=dlmread(strcat('asupraf',num2str(i),'.txt'));
% if numel(vert)>6
%p=patch('vertices',vert,'faces',supraf,'edgecolor','none','edgealpha',0,'facecolor',[1 0 0],'facealpha',1);
% reducepatch(p,0.1);
%end;
%end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Get vesicle positions');

azx=[];azy=[];mx=[];my=[];cx=[];cy=[];pvesx=[];pvesy=[];uvesx=[];uvesy=[];

for i=start:finish
    disp(i);
    pvesx=[];uvesx=[];pvesy=[];pvesz=[];uvesy=[];uvesz=[];
[stat, mess]=fileattrib(strcat(basename));
    r1=(mess(i).Name);
    

bigmatrix=dlmread(r1);

%Unphotoconverted vesicles - x = 5th column; y = 6th column
finder=find(bigmatrix(:,5))>0;
findernr=numel(finder);
uvesx(numel(uvesx)+1:numel(uvesx)+findernr)=bigmatrix(1:findernr,5);
uvesy(numel(uvesy)+1:numel(uvesy)+findernr)=bigmatrix(1:findernr,6);
uvesz(numel(uvesz)+1:numel(uvesz)+findernr)=(i-1)*dicke;


%Photoconverted vesicles - x = 7th column; y = 8th column
pfinder=find(bigmatrix(:,7))>0;
pfindernr=numel(pfinder);
pvesx(numel(pvesx)+1:numel(pvesx)+pfindernr)=bigmatrix(1:pfindernr,7);
pvesy(numel(pvesy)+1:numel(pvesy)+pfindernr)=bigmatrix(1:pfindernr,8);
pvesz(numel(pvesz)+1:numel(pvesz)+pfindernr)=(i-1)*dicke;

dlmwrite(strcat('unphotovesx',num2str(i),'.txt'),uvesx);
dlmwrite(strcat('unphotovesy',num2str(i),'.txt'),uvesy);
dlmwrite(strcat('unphotovesz',num2str(i),'.txt'),uvesz);
dlmwrite(strcat('photovesx',num2str(i),'.txt'),pvesx);
dlmwrite(strcat('photovesy',num2str(i),'.txt'),pvesy);
dlmwrite(strcat('photovesz',num2str(i),'.txt'),pvesz);
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% for i=1:numel(mess)
%     a=dlmread(mess(i).Name);
%     a(:,1:16)=a(:,1:16)/pixel_size;
%     dlmwrite(mess(i).Name,a);
% end;
