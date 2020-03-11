function address_spots;

%%%%%this folder shouldcontain subfolders for the individual experiments,
%%%%%and the file model.tif
 thefolder='F:\data_2012\katharina_new_analysis\analysis';
cd(thefolder); 
cellb={}; [dsstat, dmmess]=fileattrib('*'); for i=1:numel(dmmess); if dmmess(i).directory; cellb{numel(cellb)+1}=dmmess(i).Name;end; end;

matrix=[];
names={};

for abcdef=1:numel(cellb);
      disp(abcdef); name=cellb{abcdef}; cd(name);
[stat1, mess1]=fileattrib('confocal_POI_matrix_by_both.txt');
[stat2, mess2]=fileattrib('confocal_Green_matrix_by_both.txt');
    if stat1==1 & stat2==1
        poi=dlmread(mess1(1).Name);
        green=dlmread(mess2(1).Name);
        poi=poi(1:101,50:150);
        green=green(1:101,50:150);
        ccc=find(green>50); 
        sizm=size(matrix);
        matrix(sizm(1)+1,1)=mean(poi(ccc));
        matrix(sizm(1)+1,2)=mean(green(ccc));
        matrix(sizm(1)+1,3)=numel(ccc);
    names{numel(names)+1}=name;
    end
end
   
  cd(thefolder);
  xlswrite('organized_values.xlsx',names','Tabelle1');
  xlswrite('organized_values.xlsx',matrix,'Tabelle2');