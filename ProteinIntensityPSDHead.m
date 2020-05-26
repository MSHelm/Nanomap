function ProteinIntensityPSDHead
cd 'Z:\user\mhelm1\Nanomap_Analysis\Data\total\_Clustering'
load MorphData_mush.mat
load ProteinID_mush.mat
load MorphData_flat.mat
load ProteinID_flat.mat


proteins = ProteinID_mush.Properties.VariableNames;

results_mush = array2table(NaN(numel(proteins),6));
results_mush.Properties.VariableNames = {'IntensityPSD_Mean', 'IntensityPSD_SD', 'IntensityPSD_SEM', 'IntensityHead_Mean', 'IntensityHead_SD', 'IntensityHead_SEM'};

results_flat = array2table(NaN(numel(proteins),6));
results_flat.Properties.VariableNames = {'IntensityPSD_Mean', 'IntensityPSD_SD', 'IntensityPSD_SEM', 'IntensityHead_Mean', 'IntensityHead_SD', 'IntensityHead_SEM'};

for prot = 1 :numel(proteins)
    protein = proteins{prot};
    data_mush = MorphData_mush(logical(ProteinID_mush.(protein)),:);

    results_mush.IntensityPSD_Mean(prot) = nanmean(data_mush.STEDHomerFWHMIntensity);
    results_mush.IntensityPSD_SD(prot) = nanstd(data_mush.STEDHomerFWHMIntensity);
    results_mush.IntensityPSD_SEM(prot) = results_mush.IntensityPSD_Mean(prot) / sum(~isnan(data_mush.STEDHomerFWHMIntensity));
    results_mush.IntensityHead_Mean(prot) = nanmean(data_mush.STEDHeadIntensity);
    results_mush.IntensityHead_SD(prot) = nanstd(data_mush.STEDHeadIntensity);
    results_mush.IntensityHead_SEM(prot) = results_mush.IntensityHead_Mean(prot) / sum(~isnan(data_mush.STEDHeadIntensity));
    
    data_flat = MorphData_flat(logical(ProteinID_flat.(protein)),:);
    results_flat.IntensityPSD_Mean(prot) = nanmean(data_flat.STEDHomerFWHMIntensity);
    results_flat.IntensityPSD_SD(prot) = nanstd(data_flat.STEDHomerFWHMIntensity);
    results_flat.IntensityPSD_SEM(prot) = results_flat.IntensityPSD_Mean(prot) / sum(~isnan(data_flat.STEDHomerFWHMIntensity));
    results_flat.IntensityHead_Mean(prot) = nanmean(data_flat.STEDHeadIntensity);
    results_flat.IntensityHead_SD(prot) = nanstd(data_flat.STEDHeadIntensity);
    results_flat.IntensityHead_SEM(prot) = results_flat.IntensityHead_Mean(prot) / sum(~isnan(data_flat.STEDHeadIntensity));
end

results_mush.Properties.RowNames = proteins;
results_flat.Properties.RowNames = proteins;

writetable(results_mush, 'Z:\user\mhelm1\Nanomap_Analysis\Data\total\ProteinIntensityPSDHead.xlsx', 'Sheet' , 'mush', 'WriteRowNames', 1, 'WriteVariableNames', 1);
writetable(results_flat, 'Z:\user\mhelm1\Nanomap_Analysis\Data\total\ProteinIntensityPSDHead.xlsx', 'Sheet' , 'flat', 'WriteRowNames', 1, 'WriteVariableNames', 1);

end