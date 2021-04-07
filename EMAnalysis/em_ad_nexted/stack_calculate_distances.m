function scalculate (varargin)

cd ('C:\data2011\test2');

pixel_size=2.2324; % nm

[stat, mess]=fileattrib('*_Tv*.txt');

%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%Active zone - x = first column; y=second column
%Membrane - x = 3rd column; y=4th column
%Unphotoconverted vesicles - x = 5th column; y = 6th column
%Photoconverted vesicles - x = 7th column; y = 8th column
% Unphotoconverted vesicles, distance to the active zone = 9th column
% Unphotoconverted vesicles, distance to the membrane = 10th column
% Photoconverted vesicles, distance to the active zone = 11th column
% Photoconverted vesicles, distance to the membrane = 12th column
% Vacuoles - x = 13th column; y=14th column
% Labeled Vacuoles - x = 15th column; y=16th column
% The vacuole separators (index number) are in column 17
% The labeled vacuole separators (index number) are in column 18 
 
[stat2, mess2]=fileattrib('all_az*');

if stat2==0

    all_membranesx=[];
    all_membranesy=[];
    all_membranesz=[];
    
    all_uvesx=[];
    all_uvesy=[];
    all_uvesz=[];   
    
    all_pvesx=[];
    all_pvesy=[];
    all_pvesz=[];
    
 for ii=1:numel(mess)
     
     matrix=dlmread(mess(ii).Name);
   
     ccc=find(matrix(:,1)>0);
     all_membranesx(numel(all_membranesx)+1:numel(all_membranesx)+numel(ccc))=matrix(1:numel(ccc),1);
     all_membranesy(numel(all_membranesy)+1:numel(all_membranesy)+numel(ccc))=matrix(1:numel(ccc),2);
     all_membranesz(numel(all_membranesz)+1:numel(all_membranesz)+numel(ccc))=(ii-1)*100;
     
     ccc=find(matrix(:,5)>0);
     if numel(ccc)>0
     all_uvesx(numel(all_uvesx)+1:numel(all_uvesx)+numel(ccc))=matrix(1:numel(ccc),5);
     all_uvesy(numel(all_uvesy)+1:numel(all_uvesy)+numel(ccc))=matrix(1:numel(ccc),6);
     all_uvesz(numel(all_uvesz)+1:numel(all_uvesz)+numel(ccc))=(ii-1)*100;
     end;
     
     ccc=find(matrix(:,7)>0);
     if numel(ccc)>0
     all_pvesx(numel(all_pvesx)+1:numel(all_pvesx)+numel(ccc))=matrix(1:numel(ccc),7);
     all_pvesy(numel(all_pvesy)+1:numel(all_pvesy)+numel(ccc))=matrix(1:numel(ccc),8);
     all_pvesz(numel(all_pvesz)+1:numel(all_pvesz)+numel(ccc))=(ii-1)*100;
     end;
     
 end;
 
 dlmwrite('all_azx.txt',all_membranesx');
 dlmwrite('all_azy.txt',all_membranesy');
 dlmwrite('all_azz.txt',all_membranesz');
 
 dlmwrite('all_pvesx.txt',all_pvesx');
 dlmwrite('all_pvesy.txt',all_pvesy');
 dlmwrite('all_pvesz.txt',all_pvesz');
 
 dlmwrite('all_uvesx.txt',all_uvesx');
 dlmwrite('all_uvesy.txt',all_uvesy');
 dlmwrite('all_uvesz.txt',all_uvesz');
 
     
else
    
%     all_membranesx=dlmread('all_membranesx.txt');
%     all_membranesy=dlmread('all_membranesy.txt');
%     all_membranesz=dlmread('all_membranesz.txt');
%      
%     all_uvesx=dlmread('all_uvesx.txt');
%     all_uvesy=dlmread('all_uvesy.txt');
%     all_uvesz=dlmread('all_uvesz.txt');
%     
%     all_pvesx=dlmread('all_pvesx.txt');
%     all_pvesy=dlmread('all_pvesy.txt');
%     all_pvesz=dlmread('all_pvesz.txt');
    
     
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%calculate

all_uves_distances=[];

for i=1:numel(all_uvesx)
    
x=all_uvesx(i);
y=all_uvesy(i);
z=all_uvesz(i);

    distx=[];disty=[];distz=[];
    distx=all_membranesx;
    disty=all_membranesy;
    distz=all_membranesz;
    
    
    
    distx(:)=distx(:)-x;
    disty(:)=disty(:)-y;
    distz(:)=distz(:)-z;
    
    distx(:)=distx(:).^2;
    disty(:)=disty(:).^2;
    distz(:)=distz(:).^2;
    
    distx=distx+disty+distz;
    
    distx(:)=sqrt(distx(:));
    
    mmm=min(min(distx));
all_uves_distances(i)=mmm;
end;


all_pves_distances=[];

for i=1:numel(all_pvesx)
    
x=all_pvesx(i);
y=all_pvesy(i);
z=all_pvesz(i);

    distx=[];disty=[];distz=[];
    distx=all_membranesx;
    disty=all_membranesy;
    distz=all_membranesz;
    
    
    
    distx(:)=distx(:)-x;
    disty(:)=disty(:)-y;
    distz(:)=distz(:)-z;
    
    distx(:)=distx(:).^2;
    disty(:)=disty(:).^2;
    distz(:)=distz(:).^2;
    
    distx=distx+disty+distz;
    
    distx(:)=sqrt(distx(:));
    
    mmm=min(min(distx));
all_pves_distances(i)=mmm;
end;

all_uves_distances=all_uves_distances*pixel_size;

all_pves_distances=all_pves_distances*pixel_size;

dlmwrite('all_converted_ves_distances.txt',all_pves_distances');
dlmwrite('all_non_converted_ves_distances.txt',all_uves_distances');

   x=[0:25:1000];
   
   hist_unphoto=hist(all_uves_distances,x);
   hist_photo=hist(all_pves_distances,x);
   
   hist_unphoto=hist_unphoto*100/numel(all_uves_distances);
   hist_photo=hist_photo*100/numel(all_pves_distances);
   
   
dlmwrite('hist_all_converted_ves_distances.txt',hist_photo');
dlmwrite('hist_all_non_converted_ves_distances.txt',hist_unphoto');





