function make_percs;

the_folder='W:\#COMMON\Sinem\11.08.23';

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
    vals=[];
    i
    [sstat, mmess]=fileattrib('*_ch00.tif');
    
for j=1:numel(mmess)

  a=imread(mmess(j).Name);
vals(j)=mean2(a);


end;


dlmwrite('vals.txt',vals');
end;
