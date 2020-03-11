function EnrichmentAnalysisAverages()
%Analyze Enrichment in head or PSD in average pictures
%Reads in the averages file and calculates how much a protein is enriched in the PSD and the head, compared to the shaft

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

% Read in zone qualifiers
zones_mush=double(imread('Z:\user\mhelm1\Nanomap_Analysis\Matlab\ZoneAnalysis\mushroom_zones_plus_background.tif'));
zones_flat=double(imread('Z:\user\mhelm1\Nanomap_Analysis\Matlab\ZoneAnalysis\flat_thin_zones_plus_background.tif'));

results_mush=cell2table(cell(0,8), 'VariableNames',{'UID','SignalPSD','SignalPSDSEM','SignalHeadSmall','SignalHeadLarge','SignalDendrite','SignalDendriteSEM','SignalBackground'});
results_flat=cell2table(cell(0,8), 'VariableNames',{'UID','SignalPSD','SignalPSDSEM','SignalHeadSmall','SignalHeadLarge','SignalDendrite','SignalDendriteSEM','SignalBackground'});

warning('OFF','MATLAB:table:RowsAddedExistingVars');

for i=1:numel(folders)
    cd([cd_path filesep folders{i}]);
    
    expression='(?<=UID-)[a-zA-Z0-9]*';
    UID=regexp(pwd,expression,'match');
    UID=UID{1};
    
    results_mush.UID{i}=UID;
    results_flat.UID{i}=UID;
    
    sted_mush=dlmread('Mush_sted_average_150px_myfilt_total.txt');
    sted_mush_sem=dlmread('Mush_sted_average_150px_myfilt_total_sem.txt');
    sted_flat=dlmread('Flat_sted_average_150px_myfilt_total.txt');
    sted_flat_sem=dlmread('Flat_sted_average_150px_myfilt_total_sem.txt');
    
    results_mush.SignalPSD(i)=nanmean(sted_mush(zones_mush<4));
    results_mush.SignalPSDSEM(i)=nanmean(sted_mush_sem(zones_mush<4));
    results_mush.SignalHeadSmall(i)=nanmean(sted_mush(zones_mush<8));
    results_mush.SignalHeadLarge(i)=nanmean(sted_mush(zones_mush<11));
    results_mush.SignalDendrite(i)=nanmean(sted_mush(zones_flat==15 | zones_flat==17));
    results_mush.SignalDendriteSEM(i)=nanmean(sted_mush_sem(zones_flat==15 | zones_flat==17));
    results_mush.SignalBackground(i)=nanmean(sted_mush(zones_mush==16));
    
    results_flat.SignalPSD(i)=nanmean(sted_flat(zones_flat<4));
    results_flat.SignalPSDSEM(i)=nanmean(sted_flat_sem(zones_flat<4));
    results_flat.SignalHeadSmall(i)=nanmean(sted_flat(zones_flat<7));
    results_flat.SignalHeadLarge(i)=nanmean(sted_flat(zones_flat<9));
    results_flat.SignalDendrite(i)=nanmean(sted_flat(zones_flat==15 | zones_flat==17));
    results_flat.SignalDendriteSEM(i)=nanmean(sted_flat_sem(zones_flat==15 | zones_flat==17));
    results_flat.SignalBackground(i)=nanmean(sted_flat(zones_flat==16));
end

results_mush.EnrichmentPSDWithoutBackgroundCorrection=results_mush.SignalPSD./results_mush.SignalDendrite;
results_mush.EnrichmentPSDWithoutBackgroundCorrectionSEM=results_mush.EnrichmentPSDWithoutBackgroundCorrection .* sqrt((results_mush.SignalPSDSEM./results_mush.SignalPSD).^2 + (results_mush.SignalDendriteSEM./results_mush.SignalDendrite).^2);
results_mush.EnrichmentPSDWithBackgroundCorrection=(results_mush.SignalPSD-results_mush.SignalBackground)./(results_mush.SignalDendrite-results_mush.SignalBackground);
results_mush.EnrichmentHeadSmallWithoutBackgroundCorrection=results_mush.SignalHeadSmall./results_mush.SignalDendrite;
results_mush.EnrichmentHeadLargeWithoutBackgroundCorrection=results_mush.SignalHeadLarge./results_mush.SignalDendrite;

results_flat.EnrichmentPSDWithoutBackgroundCorrection=results_flat.SignalPSD./results_flat.SignalDendrite;
results_flat.EnrichmentPSDWithoutBackgroundCorrectionSEM=results_flat.EnrichmentPSDWithoutBackgroundCorrection .* sqrt((results_flat.SignalPSDSEM./results_flat.SignalPSD).^2 + (results_flat.SignalDendriteSEM./results_flat.SignalDendrite).^2);
results_flat.EnrichmentPSDWithBackgroundCorrection=(results_flat.SignalPSD-results_flat.SignalBackground)./(results_flat.SignalDendrite-results_flat.SignalBackground);
results_flat.EnrichmentHeadSmallWithoutBackgroundCorrection=results_flat.SignalHeadSmall./results_flat.SignalDendrite;
results_flat.EnrichmentHeadLargeWithoutBackgroundCorrection=results_flat.SignalHeadLarge./results_flat.SignalDendrite;

results_mush.Properties.RowNames=folders;
results_flat.Properties.RowNames=folders;

save('Z:\user\mhelm1\Nanomap_Analysis\Data\total\EnrichmentAnalysisAverages_mush.mat','results_mush');
save('Z:\user\mhelm1\Nanomap_Analysis\Data\total\EnrichmentAnalysisAverages_flat.mat','results_flat');

writetable(results_mush,[cd_path filesep 'EnrichmentAnalysisAverages.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','Mush');
writetable(results_flat,[cd_path filesep 'EnrichmentAnalysisAverages.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','Stubby');

warning('ON','MATLAB:table:RowsAddedExistingVars');

end