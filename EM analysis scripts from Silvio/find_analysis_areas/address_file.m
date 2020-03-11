function address_spots;

cd 'F:\data_2012\spines\spine_3Ds - Kopie\stumpy';

cellb={};

[dsstat, dmmess]=fileattrib('*');
for i=1:numel(dmmess)
    if dmmess(i).directory
        cellb{numel(cellb)+1}=dmmess(i).Name;
    end;
end;
vals=[];

for abcdef=1:numel(cellb);
    

    abcdef
    name=cellb{abcdef};
    cd(name);



try
    a=dlmread('vals_total.txt');
    vals=cat(1,vals,a);
    
catch
end
end

  cd 'F:\data_2012\spines\spine_3Ds - Kopie\stumpy'
  dlmwrite('values_all.txt',vals)