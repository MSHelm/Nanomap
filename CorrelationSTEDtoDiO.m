function CorrelationSTEDtoDiO()


cd_path='Z:\user\mhelm1\Nanomap_Analysis\Data\total';
cd(cd_path);

files=[];
files=dir;
folders={};
for i=3:numel(files)
    if files(i).isdir && isempty(regexp(files(i).name,'^[_]','once'))
        folders{numel(folders)+1}=files(i).name;
    end
end

results=zeros(numel(folders),2);


for i=1:numel(folders)
cd([cd_path filesep folders{i}]);
dio_mush=dlmread('Mush_dio_average_150px_myfilt_total.txt');
sted_mush=dlmread('Mush_sted_average_150px_myfilt_total.txt');
dio_flat=dlmread('Flat_dio_average_150px_myfilt_total.txt');
sted_flat=dlmread('Flat_sted_average_150px_myfilt_total.txt');

results(i,1)=corr2(dio_mush,sted_mush);
results(i,2)=corr2(dio_flat,sted_flat);

end

results=array2table(results,'VariableNames',{'CorrelationMushroom','CorrelationFlat'},'RowNames',folders);
writetable(results,'Z:\user\mhelm1\Nanomap_Analysis\Data\total\_Controls\DiOSTEDCorrelation.xlsx','WriteVariableNames',1,'WriteRowNames',1);
save('Z:\user\mhelm1\Nanomap_Analysis\Data\total\_Controls\DiOSTEDCorrelation.mat','results');

end
