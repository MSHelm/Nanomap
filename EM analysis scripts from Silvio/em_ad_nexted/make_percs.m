function make_percs;

the_folder='W:\#COMMON\Zebrafish Analysis\Summary\Injection';

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
    
    [sstat, mmess]=fileattrib('*.txt');
    
    if sstat==1
        for j=1:numel(mmess)
            cellb{numel(cellb)+1}=mmess(j).Name;
        end;
    end;
end;

movi=zeros(1024,1024);

for i=1:numel(cellb)
   
    a=dlmread(cellb{i});
    try
    xes=a(:,3); ccc=find(xes>0); xes=xes(ccc);
    yes=a(:,4); ccc=find(yes>0); yes=yes(ccc);
    
    themat=roipoly(movi,xes,yes);
    ccc=find(themat==1);
    pixnr=numel(ccc);
    
   % photo=a(:,7); ccc=find(photo>0); photo=photo(ccc); photop=numel(photo);
    unphoto=a(:,5); ccc=find(unphoto>0); unphoto=unphoto(ccc); unphotop=numel(unphoto);
    
    percs(i,1)=unphotop;
    percs(i,2)=pixnr;
    percs(i,3)=unphotop*206611.57/pixnr;
    catch
    end
end;

cd (the_folder);
dlmwrite('percentage.txt',percs);
    