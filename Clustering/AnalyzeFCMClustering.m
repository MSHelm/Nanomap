function AnalyzeFCMClustering%(U,centers,MorphData,ProteinID)

cd 'Z:\user\mhelm1\Nanomap_Analysis\Data\total\_Clustering'

% Create dummy input for testing
%         U=rand(size(ProteinID_mush_cleaned,1), 5)*5;

%         cd 'Z:\user\mhelm1\Nanomap_Analysis\Data\total\_Clustering'

types={'mush','flat'};
[selection,~]=listdlg('PromptString','Select what spine type should be Analyzed','ListString',{'Mushroom','Flat'},'SelectionMode','single');

if selection==1
    U=load('U_mush.mat'); U=U.U;
    ProteinID=load('ProteinID_mush_cleaned.mat'); ProteinID=ProteinID.ProteinID_mush_cleaned;
    MorphData=load('MorphData_mush_cleaned.mat'); MorphData=MorphData.MorphData_mush_cleaned;
    
elseif selection==2
    U=load('U_flat.mat'); U=U.U;
    ProteinID=load('ProteinID_flat_cleaned.mat'); ProteinID=ProteinID.ProteinID_flat_cleaned;
    MorphData=load('MorphData_flat_cleaned.mat'); MorphData=MorphData.MorphData_flat_cleaned;
end

proteinnames=ProteinID.Properties.VariableNames;
Measurements=MorphData.Properties.VariableNames;

[meas_select,~]=listdlg('PromptString','Select Measurement to be analyzed','SelectionMode','multiple','ListString',Measurements);

% Get the ID of the cluster with the maximum degree of membership for each
% spine
[~,idx]=max(U',[],2);

for k=1:numel(meas_select)
    Measure=cell(size(proteinnames,2),max(idx));
    for i=1:size(proteinnames,2)
        for j=1:max(idx)
            Measure{i,j}=MorphData.(Measurements{meas_select(k)})(ProteinID.(proteinnames{i})==1 & idx(:)==j);
        end
    end
    %     Get the number of spines per cluster per protein
    Measure_spineN=cellfun(@numel,Measure);
    
    % Take the mean of the measurement for each cluster and protein
    Measure=cellfun(@mean,Measure);
    
    %     Normalize the data to maximum per protein.
    Measure_norm=Measure./max(Measure,[],2);
    
    % Create a result table with protein names and headers
    results=array2table(Measure,'RowNames',proteinnames,'VariableNames',sprintfc('Cluster%i',1:max(idx)));
    results_norm=array2table(Measure_norm,'RowNames',proteinnames,'VariableNames',sprintfc('Cluster%i',1:max(idx)));
    results_spineN=array2table(Measure_spineN,'RowNames',proteinnames,'VariableNames',sprintfc('Cluster%i',1:max(idx)));
    writetable(results_norm,['FCM_Clustering_result_' Measurements{meas_select(k)} '_' types{selection} '_' datestr(date,'yyyy-mm-dd') '.xlsx'],'WriteRowNames',1,'Sheet','Normalized Data');
    writetable(results,['FCM_Clustering_result_' Measurements{meas_select(k)} '_' types{selection} '_' datestr(date,'yyyy-mm-dd') '.xlsx'],'WriteRowNames',1,'Sheet','Raw Data');
    writetable(results_spineN,['FCM_Clustering_result_' Measurements{meas_select(k)} '_' types{selection} '_' datestr(date,'yyyy-mm-dd') '.xlsx'],'WriteRowNames',1,'Sheet','Number of spines per cluster');
    %             writetable(centers,['Centers_' Measurements{meas_select(k)} '_' types{selection} '_' datestr(date,'yyyy-mm-dd') '.xlsx'],'WriteRowNames',1);
    %     dlmwrite(['SpotClusterIDs_' types{selection} '.txt'],idx);
end

end