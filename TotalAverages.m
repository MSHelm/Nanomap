function TotalAverages

addpath(genpath('Z:\user\mhelm1\Programming\export_fig'));
cd_path='Z:\user\mhelm1\Nanomap_Analysis\Data\total';
cd(cd_path);

classes={'Mush', 'Flat', 'Other'};
channels={'dio','homer','sted'};

files=[];
files=dir;
folders={};
for i=3:numel(files)
    if files(i).isdir && isempty(regexp(files(i).name,'^[_]','once'))
        folders{numel(folders)+1}=files(i).name;
    end
end

results=struct('Mush_dio',NaN(151,151,numel(folders)),...
    'Mush_homer',NaN(151,151,numel(folders)),...
    'Mush_sted',NaN(151,151,numel(folders)),...
    'Flat_dio',NaN(151,151,numel(folders)),...
    'Flat_homer',NaN(151,151,numel(folders)),...
    'Flat_sted',NaN(151,151,numel(folders)),...
    'Other_dio',NaN(151,151,numel(folders)),...
    'Other_homer',NaN(151,151,numel(folders)),...
    'Other_sted',NaN(151,151,numel(folders)));


for i=1:numel(folders)
    cd([cd_path filesep folders{i}]);
    for j=1:numel(classes)
        for k=1:numel(channels)
            a=[];
            a=dlmread([classes{j} '_' channels{k} '_average_150px_myfilt_total.txt']);
            a=(a/max(a(:)))*255;
            results.([classes{j} '_' channels{k}])(:,:,i)=a;
        end
    end
end

fields=fieldnames(results);
for i=1:numel(fields)
    results.(fields{i})=nanmean(results.(fields{i}),3);
    dlmwrite(['Z:\user\mhelm1\Nanomap_Analysis\Data\total\_Controls\TotalAverages\' fields{i} '_total_average.txt'],results.(fields{i}));
    f1=figure('Visible','off');
    imagesc(results.(fields{i})); axis equal; axis off;
    export_fig(['Z:\user\mhelm1\Nanomap_Analysis\Data\total\_Controls\TotalAverages\' fields{i} '_total_average'],'-transparent', '-CMYK', '-q101','-png')
    close(f1);
end



end
