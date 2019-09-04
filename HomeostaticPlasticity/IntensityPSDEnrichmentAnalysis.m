function IntensityPSDEnrichmentAnalysis

cd_path='Z:\user\mhelm1\Nanomap_Analysis\Homeostatic data from Tal';
cd(cd_path);

files=[];
files=dir;
proteins={};
for i=3:numel(files)
    if files(i).isdir && isempty(regexp(files(i).name,'^[_]','once'))
        proteins{numel(proteins)+1}=files(i).name;
    end
end
%% Read in Synaptic intensities for Mush/Stubby for the three conditions and normalize them by Untreated

results_intensity.mush=table;
results_intensity.flat=table;

for i=1:numel(proteins)
    cd([cd_path filesep proteins{i}]);
    results=readtable('ProteinIntensity_central800nm.xlsx');
    mush=results(:,1:4);
    mush.Properties.VariableNames={'Untreated','Bic','TTX','CNQXAP5'};
    flat=results(:,5:8);
    flat.Properties.VariableNames={'Untreated','Bic','TTX','CNQXAP5'};
    %     Renormalize flat, because I only normalized everything to Untreated of mush so far...
    flat{:,:}=flat{:,:}./nanmean(flat.Untreated)*100;
    %     Calculate the mean change to untreated (which is by definition 100)
    Change_mush=nanmean(mush{:,:})/nanmean(mush{:,1});
    Change_flat=nanmean(flat{:,:})/nanmean(flat{:,1});
    %     remove Untreated columns, as it is always 1
    Change_mush(1)=[];
    Change_flat(1)=[];
    
    results_intensity.mush{i,:}=Change_mush;
    results_intensity.flat{i,:}=Change_flat;
end
results_intensity.mush.Properties.VariableNames={'Bic','TTX','CNQXAP5'};
results_intensity.mush.Properties.RowNames=proteins;
results_intensity.flat.Properties.VariableNames={'Bic','TTX','CNQXAP5'};
results_intensity.flat.Properties.RowNames=proteins;

save([cd_path filesep 'IntensityAnalysis.mat'],'results_intensity');

%% Scatterplot of intensity and calculate R2

comb=cat(3,results_intensity.mush{:,:},results_intensity.flat{:,:});
for i=1:size(comb,2)
    figure
    x=comb(:,i,1)';
    y=comb(:,i,2)';
    scatter(x,y);
    p=polyfit(x,y,1);
    yfit = polyval(p,x);
    yresid = y - yfit;
    SSresid = sum(yresid.^2);
    SStotal = (length(y)-1) * var(y);
    rsq = 1 - SSresid/SStotal;
    disp(['Linear regression is Y= ' num2str(p(2)) ' + ' num2str(p(1)) ' *X']);
    disp(['R2 is ' num2str(rsq)]);
    
    xlabel('MushroomIntensityChange');
    ylabel('StubbyIntensityChange');
    title(results_intensity.mush.Properties.VariableNames{i});
    export_fig([cd_path filesep 'IntensityChange_' results_intensity.mush.Properties.VariableNames{i} '.png'],'-q101','-transparent');
end

%% Collect data on PSD Enrichment
% Read in zone qualifiers
zones_mush=double(imread('Z:\user\mhelm1\Nanomap_Analysis\Matlab\ZoneAnalysis\mushroom_zones_plus_background.tif'));
zones_flat=double(imread('Z:\user\mhelm1\Nanomap_Analysis\Matlab\ZoneAnalysis\flat_thin_zones_plus_background.tif'));
treatments={'Untreated','Bic','TTX','CNQXAP5'};
results_PSDEnrichment_mush=[];
results_PSDEnrichment_flat=[];

for i=1:numel(proteins)
    
    
    for j=1:numel(treatments)
        cd([cd_path filesep proteins{i} filesep treatments{j}]);
        sted_mush=dlmread(['Mush_sted_' treatments{j} '_total.txt']);
        sted_flat=dlmread(['Flat_sted_' treatments{j} '_total.txt']);
        
        signal_head_mush=nanmean(sted_mush(zones_mush<4));
        signal_dendrite_mush=nanmean(sted_mush(zones_flat==15 | zones_flat==17));
        %     signal_background_mush=nanmean(sted_mush(zones_mush==16));
        signal_enrichment_mush=signal_head_mush/signal_dendrite_mush;
        results_PSDEnrichment_mush(i,j)=signal_enrichment_mush;
        
        signal_head_flat=nanmean(sted_flat(zones_flat<4));
        signal_dendrite_flat=nanmean(sted_flat(zones_flat==15 | zones_flat==17));
        %     signal_background_flat=nanmean(sted_flat(zones_flat==16));
        signal_enrichment_flat=signal_head_flat/signal_dendrite_flat;
        results_PSDEnrichment_flat(i,j)=signal_enrichment_flat;
        
    end
end

results_PSDEnrichment_mush=array2table(results_PSDEnrichment_mush,'RowNames',proteins,'VariableNames',treatments);
results_PSDEnrichment_flat=array2table(results_PSDEnrichment_flat,'RowNames',proteins,'VariableNames',treatments);
writetable(results_PSDEnrichment_mush,[cd_path filesep 'EnrichmentAnalysisAverages.xlsx'],'WriteRowNames',1,'WriteVariableNames',1,'Sheet','Mush');
writetable(results_PSDEnrichment_flat,[cd_path filesep 'EnrichmentAnalysisAverages.xlsx'],'WriteRowNames',1,'WriteVariableNames',1,'Sheet','Stubby');

%% Scatterplot of Enrichment and calculate R2
comb=cat(3,results_PSDEnrichment_mush{:,:},results_PSDEnrichment_flat{:,:});
for i=1:size(comb,2)
    figure
    x=comb(:,i,1)';
    y=comb(:,i,2)';
    scatter(x,y);
    p=polyfit(x,y,1);
    yfit = polyval(p,x);
    yresid = y - yfit;
    SSresid = sum(yresid.^2);
    SStotal = (length(y)-1) * var(y);
    rsq = 1 - SSresid/SStotal;
    disp(['Linear regression is Y= ' num2str(p(2)) ' + ' num2str(p(1)) ' *X']);
    disp(['R2 is ' num2str(rsq)]);
    
    xlabel('MushroomPSDEnrichment');
    ylabel('StubbyPSDEnrichment');
    title(results_PSDEnrichment_mush.Properties.VariableNames{i});
    export_fig([cd_path filesep 'PSDEnrichment_' results_PSDEnrichment_mush.Properties.VariableNames{i} '.png'],'-q101','-transparent');
end



