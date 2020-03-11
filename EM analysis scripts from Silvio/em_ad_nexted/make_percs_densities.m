function make_percs;

the_folder='W:\#COMMON\Annette\SynKO2hand4h_080710\4h';

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
    
    [sstat, mmess]=fileattrib('*for_ves_numbers.txt');
    
    if sstat==1
        for j=1:numel(mmess)
            cellb{numel(cellb)+1}=mmess(j).Name;
        end;
    end;
end;

percs=[];
density=[];


for i=1:numel(cellb)
    i
    a=dlmread(cellb{i});
    photo=a(:,7);
    unphoto=a(:,5);
   
    ccc=find(photo>0); photo=photo(ccc);
    ccc=find(unphoto>0); unphoto=unphoto(ccc);
    
    nrves=numel(photo)+numel(unphoto);
    
    membrx=a(:,3);
    membry=a(:,4);
    
    ccc=find(membrx>0);
    membrx=membrx(ccc);
    membry=membry(ccc);
    img=zeros(max(membrx),max(membry));
    pols=roipoly(img,membrx,membry);
    ccc=find(pols==1); nrpix=numel(ccc);
    
    density(i)=nrves*206611.57/nrpix;
    

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
dlmwrite('densities.txt',density');
    