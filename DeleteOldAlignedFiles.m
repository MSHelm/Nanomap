function DeleteOldAlignedFiles()
reps={'Z:\user\mhelm1\Nanomap_Analysis\Data\Replicate1','Z:\user\mhelm1\Nanomap_Analysis\Data\Replicate2'};

for j=1:numel(reps)
    cd(reps{j});
    
files=[];
files=dir;
folders={};
for i=3:numel(files)
    if files(i).isdir && isempty(regexp(files(i).name,'^[_]','once'))
        folders{numel(folders)+1}=files(i).name;
    end
end

for i=1:numel(folders)
    cd([reps{j} filesep folders{i}]);

    delete *noback*.txt
    delete *norm2shaft*.txt
    delete *resized*.txt
    
    %delete *aligned*.txt
% delete *rectangle*.txt
% delete *shift*.txt
% delete *average*.txt
% delete *rotation*.txt
% delete *coordinates*
% delete *SpotAnalysis*
% try
% movefile classification_original.txt classification.txt
% catch

% end

end
end

end

