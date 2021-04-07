function make_percs;

the_folder='C:\rizzoli_thesis\serial';

cd (the_folder);

cella={};
cellb={};
percs=[];

[stat, mess]=fileattrib('*');

for i=1:numel(mess)
    if mess(i).directory
    cella{numel(cella)+1}=mess(i).Name;
    end;
end;

for i=1:numel(cella)
    cd(cella{i});
    cella{i}
    i
    surf=[];
    [sstat, mmess]=fileattrib('*_for_vol_only.txt');
if sstat==1

    for j=1:numel(mmess)
        j
        a=dlmread(mmess(j).Name);
        
        
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
memx=[]; memy=[]; vx=[]; bvx=[];


mfinder=find(a(:,3)>0); mfinder=numel(mfinder);
memx=a(1:mfinder,3);
memy=a(1:mfinder,4);
maxes(1)=max(memx); maxes(2)=max(memy);

vfinder=find(a(:,13)>0); vfinder=numel(vfinder);
if vfinder>1
vx=a(1:vfinder,13); vy=a(1:vfinder,14);
else
    vfinder==1;
    vx=1; vy=1;
end;
maxes(3)=max(vx); maxes(4)=max(vy);

bvfinder=find(a(:,15)>0); bvfinder=numel(bvfinder);
if bvfinder>1
bvx=a(1:bvfinder,15); bvy=a(1:bvfinder,16);
else
    bvfinder=1;
    bvx=1; bvy=1;
end;
    
maxes(5)=max(bvx); maxes(6)=max(bvy);

mmax=max(maxes);

matrix=zeros(mmax,mmax);
size(matrix)


the_surface=roipoly(matrix, memx,memy); ccc=find(the_surface==1);
surf(j,1)=numel(ccc);




the_surface=roipoly(matrix,vx,vy); ccc=find(the_surface==1); surf(j,4)=numel(ccc);
the_surface=roipoly(matrix,bvx,bvy); ccc=find(the_surface==1); surf(j,2)=numel(ccc);

surf(j,3)=surf(j,1)-surf(j,2);

end;
dlmwrite('surface_occupied.txt',surf);
surf_sum=sum(surf);
surf_sum(5)=surf_sum(4)*100/surf_sum(3);
dlmwrite('surface_summed_occupied.txt',surf_sum);
end;
end;
