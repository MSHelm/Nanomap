function CollectDataForRichard

addpath(genpath('Z:\user\mhelm1\Nanomap_Analysis\Matlab\IndividualAnalysis'))

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

ProteinID=[];
SpotFiles={};

w=waitbar(0,'Please Wait...');

for i=1:numel(folders)
    cd([cd_path filesep folders{i}]);
    waitbar(i/numel(folders));
    %     try
    load SpotAnalysis_total.mat
    %         Remove the HeadEccentricity, because it doesnt work apparently
    results_total=rmfield(results_total,{'HeadEccentricity'});
    fields=fieldnames(results_total);
    
    %On first run initialize total results structure with the fieldnames
    if i==1
        MorphData=cell(1e6,numel(fields));
            rowcount=1;
    end
    
    for j=1:numel(fields)
        % Concatenate the results from this folder to the total results file.
        MorphData(rowcount:rowcount+size(results_total.Class,2)-1,j)=results_total.(fields{j})';
        rowcount=rowcount+size(results_total.Class,2);
        % Create the Protein ID matrix
        temp_PID=zeros(size(ProteinID,1),1);
        temp_PID=cat(1,temp_PID,ones([size(results_total.Class,2),1]));
        ProteinID=cat(1,ProteinID,zeros(size(results_total.Class,2),size(ProteinID,2)));
        ProteinID=cat(2,ProteinID,temp_PID);
        
        % Also save the SpotFile name so that I can later assign cluster identity
        % back to spot.
        SpotFiles=cat(1,SpotFiles,results_total.SpotFile');
    end
end
    MorphData(rowcount:end,:)=[];
    

ProteinID=array2table(ProteinID);
ProteinID.Properties.VariableNames=matlab.lang.makeValidName(folders(:)');
% save([cd_path filesep '_Clustering' filesep 'MorphData.mat'],'MorphData');
dlmwrite([cd_path filesep '_Clustering' filesep 'MorphData.json'],jsonencode(MorphData));
% save([cd_path filesep '_Clustering' filesep 'ProteinID.mat'],'ProteinID');
dlmwrite([cd_path filesep '_Clustering' filesep 'ProteinID.json'],jsonencode(ProteinID));
% save([cd_path filesep '_Clustering' filesep 'SpotFiles.mat'],'SpotFiles');
dlmwrite([cd_path filesep '_Clustering' filesep 'SpotFiles.json'],jsonencode(SpotFiles));

close(w)

end