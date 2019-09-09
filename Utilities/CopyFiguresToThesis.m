function CopyFiguresToThesis

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

targetfolders={};
[~,mess]=fileattrib('Z:\user\mhelm1\Thesis\figures\Protein Averages\*');
for i=1:numel(mess)
    if mess(i).directory==1
        targetfolders{end+1}=mess(i).Name;
    end
end


for i=1:numel(folders)
    cd([cd_path filesep folders{i}]);
    target=regexp(folders{i},'_','split');
    target=target{1};
    files=[];
    files=[dir('*IndividualAnalysisPrism.png'); dir('*outlines.png')];
    
    %determine protein name
    exp='\S*(?=_UID)';
    proteinname=regexp(folders{i},exp,'match');
    proteinname=proteinname{1};
        
%     if ~exist(['Z:\user\mhelm1\Thesis\figures\Protein Averages\' proteinname],'dir')
%         mkdir(['Z:\user\mhelm1\Thesis\figures\Protein Averages\' proteinname]);
%     end
    try
    for j=1:size(files,1)
        copyfile(files(j).name,[targetfolders{find(contains(targetfolders,target))} filesep]);
    end
    catch
        disp(['Error in ' folders{i}]);
        continue
    end
end
end
