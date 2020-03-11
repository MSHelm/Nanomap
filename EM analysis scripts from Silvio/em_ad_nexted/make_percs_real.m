function make_percs;

the_folder='W:\#COMMON\Annette\summary_shibire\non-recovered\larvaD';

cd (the_folder);

cella={};
cellb={};

[stat, mess]=fileattrib('*');
for i=1:numel(mess)
    if mess(i).directory
    cella{numel(cella)+1}=mess(i).Name;
    end;
end;

for i=1:numel(cella)
    cd(cella{i});
    
    [sstat, mmess]=fileattrib('*.txt');
    
    if sstat==1
        for j=1:numel(mmess)
            cellb{numel(cellb)+1}=mmess(j).Name;
        end;
    end;
end;



percs=[];

for i=1:numel(cellb)
    a=dlmread(cellb{i});
    photo=a(:,7);
    unphoto=a(:,5);
    
    ccc=find(photo>0); photo=photo(ccc);
    ccc=find(unphoto>0); unphoto=unphoto(ccc);
    
    percs(i,1)=numel(photo)*100/(numel(photo)+numel(unphoto));
    percs(i,2)=numel(unphoto);
    percs(i,3)=numel(photo);
    
    
    memx=a(:,3);
    memy=a(:,4);
    maxx=max(memx); maxy=max(memy); im=zeros(max(maxy,maxx));
    bwim=roipoly(im, memx, memy);
    ccc=find(bwim==1);
    percs(i,4)=numel(ccc)*2.2*2.2/1000000;
end;

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


cd (the_folder);
dlmwrite('percentage.txt',percs);
mean(percs)
    