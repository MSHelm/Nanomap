function Clusters_MultipleMannWhitneyUTests
classes = {'mush','flat'};
types = {'spine','PSD'};
cd_path = 'Z:\user\mhelm1\Nanomap_Analysis\Data\total\_Clustering\ClusterAverages';
results = struct();

proteins = getfolders(cd_path);
proteins(startsWith(proteins,'_')) = [];

num_tests = struct();
num_tests.mush_spine = 0;
num_tests.mush_PSD = 0;
num_tests.flat_spine = 0;
num_tests.flat_PSD = 0;

fields = fieldnames(num_tests);
for field = 1:numel(fields)
median_norm.(fields{field}) = readtable([cd_path filesep 'ClusterTotalIntensities_nans.xlsx'],'Sheet',fields{field},'ReadRowNames',1);
% Remove everything but the mean intensity values
median_norm.(fields{field})(:,~contains(median_norm.(fields{field}).Properties.VariableNames,'mean')) = [];
median_norm.(fields{field}) = table2array(median_norm.(fields{field}));
median_norm.(fields{field}) = nanmedian(median_norm.(fields{field}),1);
end

for protein = 1:numel(proteins)
    cd([cd_path filesep proteins{protein}]);
    for class = 1:numel(classes)
        for type = 1:numel(types)
            
            data = readtable('ClusterIntensities.xlsx','Sheet',[classes{class} '_' types{type}]);
            data = table2array(data);
%             normalize by median
            data = data ./ median_norm.([classes{class} '_' types{type}]);
            
            if strcmp(classes{class},'mush')
                combinations = nchoosek(1:8,2);
            elseif strcmp(classes{class},'flat')
                combinations = nchoosek(1:4,2);
            else
                disp('Error!!!')
                break
            end
            %             Do Mann-Whitney U tests across all combinations
            for combination = 1:size(combinations,1)
                %                 If there are no entries for one of the clusters, write
                %                 NaN as result of the test
                try
                    results.([classes{class} '_' types{type}])(protein,combination) = ranksum(data(:,combinations(combination,1)),data(:,combinations(combination,2)));
                    num_tests.([classes{class} '_' types{type}]) = num_tests.([classes{class} '_' types{type}]) + 1;
                catch
                    results.([classes{class} '_' types{type}])(protein,combination) = nan;
                end
            end
        end
    end
end

%% perform Bonferroni correction and save each array of the structure as a separate excel worksheet
delete([cd_path filesep 'MultipleMannWhitneyUTests.xlsx']);
fields = fieldnames(results);
for field = 1:numel(fields)
    % Do Bonferroni correction
    results.(fields{field}) = results.(fields{field})*num_tests.(fields{field});
    
    %         check which combinations we have depending on spine class
    if contains(fields{field},'mush')
        combinations = nchoosek(1:8,2);
    elseif contains(fields{field},'flat')
        combinations = nchoosek(1:4,2);
    else
        disp('Error!!!')
        break
    end
    
    VarNames = cellstr(strcat('cluster', num2str(combinations(1:size(combinations,1),1)), '_cluster', num2str(combinations(1:size(combinations,1),2))));
    result = array2table(results.(fields{field}),'RowNames',proteins,'VariableNames',VarNames);
    writetable(result,[cd_path filesep 'MultipleMannWhitneyUTests.xlsx'],'WriteRowNames',1,'WriteVariableNames',1,'Sheet',fields{field});
end

end