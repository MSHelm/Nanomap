function FiltNoDiOFiltComparison

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
    mush_filt=dlmread('Mush_sted_average_150px_myfilt_nostedfilt_total.txt');
    mush_nofilt=dlmread('Mush_sted_average_150px_nodiofilt_nostedfilt_total.txt');
    flat_filt=dlmread('Flat_sted_average_150px_myfilt_nostedfilt_total.txt');
    flat_nofilt=dlmread('flat_sted_average_150px_nodiofilt_nostedfilt_total.txt');
    results(i,1)=sum(mush_filt(:))/sum(mush_nofilt(:));
    results(i,2)=sum(flat_filt(:))/sum(flat_nofilt(:));
end

results=array2table(results,'RowNames',folders,'VariableNames',{'RatioMushroom','RatioFlat'});
writetable(results,[cd_path filesep 'ComparisonFiltNoDioFilt.xlsx'],'WriteRowNames',1,'WriteVariableNames',1)
end