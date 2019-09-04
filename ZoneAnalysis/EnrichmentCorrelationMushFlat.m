function EnrichmentCorrelationMushFlat

mush_orig=readtable('Z:\user\mhelm1\Nanomap_Analysis\Data\total\ProteinZoneEnrichment_mush_FoldOverAvg.xlsx','Sheet','data','ReadRowNames',1);
flat_orig=readtable('Z:\user\mhelm1\Nanomap_Analysis\Data\total\ProteinZoneEnrichment_flat_FoldOverAvg.xlsx','Sheet','data','ReadRowNames',1);

proteinnames=mush_orig.Properties.RowNames;

mush_orig=table2array(mush_orig);
flat_orig=table2array(flat_orig);
% Fine
mush_fine(:,1:6)=mush_orig(:,1:6);
mush_fine(:,7)=nanmean(mush_orig(:,7:10),2);
mush_fine(:,8)=nanmean(mush_orig(:,11:13),2);
mush_fine(:,9)=mush_orig(:,14);
mush_fine(:,10)=mush_orig(:,15);

flat_fine(:,1:9)=flat_orig(:,1:9);
flat_fine(:,10)=nanmean(flat_orig(:,10:11),2);

% Coarse
mush_coarse(:,1)=nanmean(mush_orig(:,1:3),2);
mush_coarse(:,2)=nanmean(mush_orig(:,4:7),2);
mush_coarse(:,3)=nanmean(mush_orig(:,8:10),2);
mush_coarse(:,4)=nanmean(mush_orig(:,11:13),2);
mush_coarse(:,5)=nanmean(mush_orig(:,14:15),2);


flat_coarse(:,1)=nanmean(flat_orig(:,1:3),2);
flat_coarse(:,2)=nanmean(flat_orig(:,4:6),2);
flat_coarse(:,3)=nanmean(flat_orig(:,7:8),2);
flat_coarse(:,4)=nanmean(flat_orig(:,9:10),2);
flat_coarse(:,5)=flat_orig(:,11);


correlations=nan(size(mush_fine,1),2);

for i=1:size(mush_fine,1)
    correlations(i,1)=corr2(mush_coarse(i,:),flat_coarse(i,:));
    correlations(i,2)=corr2(mush_fine(i,:),flat_fine(i,:));
end

correlations=array2table(correlations,'RowNames',proteinnames,'VariableNames',{'Correlation_coarse','Correlation_fine'});
writetable(correlations,'Z:\user\mhelm1\Nanomap_Analysis\Data\total\ZoneEnrichmentCorrelation.xlsx','WriteVariableNames',1,'WriteRowNames',1);
end



