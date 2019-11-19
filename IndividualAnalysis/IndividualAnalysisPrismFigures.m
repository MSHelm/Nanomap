function IndividualAnalysisPrismFigures
addpath(genpath('Z:\user\mhelm1\Nanomap_Analysis\Matlab\IndividualAnalysis'));
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
load 'Z:\user\mhelm1\Nanomap_Analysis\Data\total\ProteinZoneEnrichment_mush_FoldOverAvg.mat'
mush_UID=T_mush_foldoveravg.Properties.RowNames;
load 'Z:\user\mhelm1\Nanomap_Analysis\Data\total\ProteinZoneEnrichment_mush_FoldOverAvg_sem.mat'

load 'Z:\user\mhelm1\Nanomap_Analysis\Data\total\ProteinZoneEnrichment_flat_FoldOverAvg.mat'
flat_UID=T_flat_foldoveravg.Properties.RowNames;
load 'Z:\user\mhelm1\Nanomap_Analysis\Data\total\ProteinZoneEnrichment_flat_FoldOverAvg_sem.mat'

for i=1:numel(folders)
    cd([cd_path filesep folders{i}]);
    results_total=[];
    results=[];
    tmp={};
    load SpotAnalysis_total
    
    for j=1:2
        %         Select only spots that are in the head for the following
        %         analysis. As the information whether a spot is in the head, and
        %         what class it has, is encoded in two different tables I need to
        %         construct the selector manually.
        ClassSelect=[results_total.Class{:}]==j;
        SpotSelect=[];
        for k=1:numel(ClassSelect)
            
            if ClassSelect(k)
                SpotSelect=cat(2,SpotSelect,results_total.SpotCompartment{k});
            else
                SpotSelect=cat(2,SpotSelect,zeros(1,size(results_total.SpotCompartment{k},2)));
            end
        end
        SpotSelect=round(SpotSelect);
        SpotSelect=SpotSelect==1;
        
        tmp{1,j}=[results_total.STEDDioDistance{[results_total.Class{:}]==j}]'; %*20.2
        
        data_tmp=[results_total.STEDHomerFWHMDistance{:}];
        tmp{1,j+2}=data_tmp(SpotSelect)';%*20.2
        data_tmp=[];
        
        tmp{1,j+4}=[results_total.STEDHeadEnrichment{[results_total.Class{:}]==j}]';
        tmp{1,j+6}=[results_total.STEDHomerFWHMEnrichment{[results_total.Class{:}]==j}]';
        
        data_tmp=[results_total.STEDEccentricity{:}];
        tmp{1,j+8}=data_tmp(SpotSelect)';
        data_tmp=[];
        
        data_tmp=[results_total.STEDLaterality{:}];
        tmp{1,j+10}=data_tmp(SpotSelect)';
        data_tmp=[];
        
        data_tmp=[results_total.STEDMajorAxisLength{:}];
        tmp{1,j+12}=data_tmp(SpotSelect)';%*20.2
        data_tmp=[];
        
        data_tmp=[results_total.STEDDistribution{:}];
        tmp{1,j+14}=data_tmp(SpotSelect)';%*20.2
        data_tmp=[];
    end
    
    %determine protein name
    exp='\S*(?=_UID)';
    proteinname=matlab.lang.makeValidName(char(regexp(folders{i},exp,'match')));
    id_mush=[];
    id_flat=[];
    id_mush=find(strcmp(mush_UID,proteinname));
    id_flat=find(strcmp(flat_UID,proteinname));
    results=padcat(tmp{:},T_mush_foldoveravg{id_mush,:}',T_mush_foldoveravg_sem{id_mush,:}',T_flat_foldoveravg{id_flat,:}',T_flat_foldoveravg_sem{id_flat,:}');
    results=array2table(results,'VariableNames',[reshape([sprintfc('Mushroom%i',1:8);sprintfc('Stumpy%i',1:8)],1,[]),{'MushroomMean','MushroomSEM','StumpyMean','StumpySEM'}]);
    
    writetable(results,['Z:\user\mhelm1\Nanomap_Analysis\Data\total\_PrismFigures\' folders{i} '.csv']);
    %     csvwrite(['Z:\user\mhelm1\Nanomap_Analysis\Data\total\_PrismFigures' folders{i} '_IndividualPrism.csv'],results);
    
end
end