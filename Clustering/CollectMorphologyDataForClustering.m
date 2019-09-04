function CollectMorphologyDataForClustering()

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

MorphData_mush=[];
MorphData_flat=[];
MorphData_other=[];
ProteinID_mush=[];
ProteinID_flat=[]; 
ProteinID_other=[];
SpotFiles_mush={};
SpotFiles_flat={};
SpotFiles_other={};

w=waitbar(0,'Please Wait...');

for i=1:numel(folders)
    cd([cd_path filesep folders{i}]);
    waitbar(i/numel(folders));
%     try
        load SpotAnalysis_total.mat
        
%         Remove the HeadEccentricity, because it doesnt work apparently,
        results_total=rmfield(results_total,{'HeadEccentricity'});

        results_total=orderfields(results_total);
        fields=fieldnames(results_total);
        %     Collect the Data on Morphology. I collect everything that is related
        %     to DiO or Homer
        class=[results_total.Class{:}]';
        
%         This takes the mean for all measurements where theoretically
%         multiple results are possible, such as HomerArea if multiple
%         Homer spots are detected. For things like Head Area, which have
%         only one entry per spot, this doesnt do anything. This messes up
%         the SpotFile entry, but this doesnt matter, as I save it
%         in a separate file.
        for j=1:numel(fields)
                temp_mush(:,j)=nanmean(padcat(results_total.(fields{j}){class==1}),2);
            temp_flat(:,j)=nanmean(padcat(results_total.(fields{j}){class==2}),2);
            temp_other(:,j)=nanmean(padcat(results_total.(fields{j}){class==3}),2);
                end
        
        % Concatenate the results from this folder to the total results file.
        MorphData_mush=cat(1,MorphData_mush,temp_mush);
        MorphData_flat=cat(1,MorphData_flat,temp_flat);
        MorphData_other=cat(1,MorphData_other,temp_other);
        
        % Create the Protein ID matrix
        temp_PID_mush=zeros(size(ProteinID_mush,1),1);
        temp_PID_mush=cat(1,temp_PID_mush,ones([size(temp_mush,1),1]));
        ProteinID_mush=cat(1,ProteinID_mush,zeros(size(temp_mush,1),size(ProteinID_mush,2)));
        ProteinID_mush=cat(2,ProteinID_mush,temp_PID_mush);
        
        temp_PID_flat=zeros(size(ProteinID_flat,1),1);
        temp_PID_flat=cat(1,temp_PID_flat,ones([size(temp_flat,1),1]));
        ProteinID_flat=cat(1,ProteinID_flat,zeros(size(temp_flat,1),size(ProteinID_flat,2)));
        ProteinID_flat=cat(2,ProteinID_flat,temp_PID_flat);
        
                
        temp_PID_other=zeros(size(ProteinID_other,1),1);
        temp_PID_other=cat(1,temp_PID_other,ones([size(temp_other,1),1]));
        ProteinID_other=cat(1,ProteinID_other,zeros(size(temp_other,1),size(ProteinID_other,2)));
        ProteinID_other=cat(2,ProteinID_other,temp_PID_other);
        
        % Also save the SpotFile name so that I can later assign cluster identity
        % back to spot.
        SpotFiles_mush=cat(1,SpotFiles_mush,results_total.SpotFile(class==1)');
        SpotFiles_flat=cat(1,SpotFiles_flat,results_total.SpotFile(class==2)');
         SpotFiles_other=cat(1,SpotFiles_other,results_total.SpotFile(class==2)');
        
        clear temp*
%     catch
%         disp(['Error in folder ' folders{i}])
%         continue
%     end
    
end

% Switch from Matrix to table.
MorphData_mush=array2table(MorphData_mush);
MorphData_flat=array2table(MorphData_flat);
MorphData_other=array2table(MorphData_other);

MorphData_mush.Properties.VariableNames=fields';
MorphData_flat.Properties.VariableNames=fields';
MorphData_other.Properties.VariableNames=fields';

ProteinID_mush=array2table(ProteinID_mush);
ProteinID_flat=array2table(ProteinID_flat);
ProteinID_other=array2table(ProteinID_other);

ProteinID_mush.Properties.VariableNames=matlab.lang.makeValidName(folders(:)');
ProteinID_flat.Properties.VariableNames=matlab.lang.makeValidName(folders(:)');
ProteinID_other.Properties.VariableNames=matlab.lang.makeValidName(folders(:)');

save([cd_path filesep '_Clustering' filesep 'MorphData_mush.mat'],'MorphData_mush');
save([cd_path filesep '_Clustering' filesep 'MorphData_flat.mat'],'MorphData_flat');
save([cd_path filesep '_Clustering' filesep 'MorphData_other.mat'],'MorphData_other');
dlmwrite([cd_path filesep '_Clustering' filesep 'MorphData_mush.json'],jsonencode(MorphData_mush));
dlmwrite([cd_path filesep '_Clustering' filesep 'MorphData_flat.json'],jsonencode(MorphData_flat));
dlmwrite([cd_path filesep '_Clustering' filesep 'MorphData_other.json'],jsonencode(MorphData_other));

save([cd_path filesep '_Clustering' filesep 'ProteinID_mush.mat'],'ProteinID_mush');
save([cd_path filesep '_Clustering' filesep 'ProteinID_flat.mat'],'ProteinID_flat');
save([cd_path filesep '_Clustering' filesep 'ProteinID_other.mat'],'ProteinID_other');
dlmwrite([cd_path filesep '_Clustering' filesep 'ProteinID_mush.json'],jsonencode(ProteinID_mush));
dlmwrite([cd_path filesep '_Clustering' filesep 'ProteinID_flat.json'],jsonencode(ProteinID_flat));
dlmwrite([cd_path filesep '_Clustering' filesep 'ProteinID_other.json'],jsonencode(ProteinID_other));

save([cd_path filesep '_Clustering' filesep 'SpotFiles_mush.mat'],'SpotFiles_mush');
save([cd_path filesep '_Clustering' filesep 'SpotFiles_flat.mat'],'SpotFiles_flat');
save([cd_path filesep '_Clustering' filesep 'SpotFiles_other.mat'],'SpotFiles_other');
dlmwrite([cd_path filesep '_Clustering' filesep 'SpotFiles_mush.json'],jsonencode(SpotFiles_mush));
dlmwrite([cd_path filesep '_Clustering' filesep 'SpotFiles_flat.json'],jsonencode(SpotFiles_flat));
dlmwrite([cd_path filesep '_Clustering' filesep 'SpotFiles_other.json'],jsonencode(SpotFiles_other));
close(w)
end




