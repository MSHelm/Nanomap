function MeansIndividualAnalysis

cd 'Z:\user\mhelm1\Nanomap_Analysis\Data\total\_Figures\Prism'
files=dir('*.csv');
files={files.name};
Measures={'DistanceDiO','DistancePSD','EnrichmentHead','EnrichmentPSD','Eccentricity','Laterality','SpotDiameter','Distribution'};
Types={'Mushroom','Stumpy'};
Variables=cell(numel(Measures)*numel(Types),1);

for i=1:numel(Measures)
    Variables{i*2-1}=[Measures{i} Types{1}];
    Variables{i*2}=[Measures{i} Types{2}];
end

results=nan(numel(files),20);


for i=1:numel(files)
    temp=readtable(files{i});
    temp=standardizeMissing(temp,Inf);
    results(i,:)=nanmean(table2array(temp),1);
end

results=results(:,1:16);
Rows=cellfun(@(x) x(1:end-4),files,'UniformOutput',false);
results=array2table(results,'RowNames',Rows,'VariableNames',Variables);

writetable(results,'IndividualAnalysisMeans.xlsx','WriteRowNames',1,'WriteVariableNames',1)

end
