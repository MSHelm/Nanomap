function STEDCorrelations
results={};
[~,~,copynumbers]=xlsread('Z:\user\mhelm1\Nanomap_Analysis\Copy Numbers\Protein copy number overview.xlsx');
copynum_UID=copynumbers(:,2);
zoom=10;

cd_path='Z:\user\mhelm1\Nanomap_Analysis\Data\total';
cd(cd_path);
files=[];
files=dir;
%%
folders={};
for i=3:numel(files)
    if files(i).isdir && isempty(regexp(files(i).name,'^[_]','once'))
        folders{numel(folders)+1}=files(i).name;
    end
end
%%

for i=1:numel(folders)
    try
        cd([cd_path filesep folders{i}]);
        correlations=[]; correlations_flat=[];
        
        disp(folders{i})
        load CombinedImageStack_Mush_sted_150px_myfilt.mat
        sted_mush=img_both;
        load CombinedImageStack_Mush_homer_150px_myfilt.mat
        homer_mush=img_both;
        correlations=zeros(size(sted_mush,3),1);
        for j=1:size(sted_mush,3)
            correlations(j)=corr2(sted_mush(75-zoom:75+zoom,75-zoom:75+zoom,j),homer_mush(75-zoom:75+zoom,75-zoom:75+zoom,j));
        end
        
        load CombinedImageStack_Flat_sted_150px_myfilt.mat
        sted_flat=img_both;
        load CombinedImageStack_Flat_homer_150px_myfilt.mat
        homer_flat=img_both;
        correlations_flat=zeros(size(sted_flat,3),1);
        for j=1:size(sted_flat,3)
            correlations_flat(j)=corr2(sted_flat(75-zoom:75+zoom,75-zoom:75+zoom,j),homer_flat(75-zoom:75+zoom,75-zoom:75+zoom,j));
        end
        
        correlations=cat(1,correlations,correlations_flat);
        
        %extract uniprot ID from folder name
        expression='(?<=UID-)[a-zA-Z0-9]*';
        UID=regexp(folders{i},expression,'match');
        UID=UID{1};
        id=find(strcmp(UID,copynum_UID));
        results{i,1}=UID;
        results{i,2}=nanmean(correlations);
        results{i,3}=nanstd(correlations)/sqrt(size(correlations,1));
        %         results{i,3}=copynumbers{id,9};
        %         results{i,4}=copynumbers{id,11};
        
        zones_mush=imread('Z:\user\mhelm1\Nanomap_Analysis\Matlab\ZoneAnalysis\mushroom_zones_plus_background.tif');
        zones_flat=imread('Z:\user\mhelm1\Nanomap_Analysis\Matlab\ZoneAnalysis\flat_thin_zones_plus_background.tif');
        sted_mush_avg=nanmean(sted_mush,3);
        sted_flat_avg=nanmean(sted_flat,3);
        sted_mush_avg_nonsynaptic=sted_mush_avg;
        sted_mush_avg_nonsynaptic(75-zoom:75+zoom,75-zoom:75+zoom)=0;
        sted_flat_avg_nonsynaptic=sted_flat_avg;
        sted_flat_avg_nonsynaptic(75-zoom:75+zoom,75-zoom:75+zoom)=0;
        
        spine_mush=sum(sted_mush_avg_nonsynaptic(zones_mush>0 & zones_mush<16))/sum(sum(sted_mush_avg(75-zoom:75+zoom,75-zoom:75+zoom)));
        spine_flat=sum(sted_flat_avg_nonsynaptic(zones_flat>0 & zones_flat<16))/sum(sum(sted_flat_avg(75-zoom:75+zoom,75-zoom:75+zoom)));
        results{i,4}=((spine_mush*size(sted_mush,3))+(spine_flat*size(sted_flat,3)))/(size(sted_mush,3)+size(sted_flat,3));
    catch
        disp(['Error in ' folders{i}])
        continue
    end
end
%%

homer1_id=find(contains(folders,'Homer1'));
results=cat(2,results,num2cell([results{:,2}]'/results{homer1_id,2}),num2cell([results{:,3}]'/results{homer1_id,2}));

results=cell2table(results,'RowNames',folders,'VariableNames',{'UID','Correlation','CorrelationSEM','FoldMoreinSpine','NormalizedCorrelation','NormalizedCorrelationSEM'});
writetable(results,'Z:\user\mhelm1\Nanomap_Analysis\Data\total\STEDCorrelations.xlsx','WriteRowNames',1);
save('Z:\user\mhelm1\Nanomap_Analysis\Data\total\STEDCorrelations.mat','results');
end