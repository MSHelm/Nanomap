function CreateMasterStruct()
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

Master_results=struct;

% HeadArea=struct;
% HeadCenterColumn=struct;
% HeadCenterRow=struct;
% HeadHeight=struct;
% HeadMajorAxisLength=struct;
% HeadMinorAxisLength=struct;
% HeadWidth=struct;
% HomerArea=struct;
% HomerCenterDistance=struct;
% HomerDioDistance=struct;
% HomerMajorAxisLength=struct;
% HomerMaxIntensity=struct;
% HomerMeanIntensity=struct;
% HomerMinorAxisLength=struct;
% HomerWeightedCentroidX=struct;
% HomerWeightedCentroidY=struct;
% NeckArea=struct;
% NeckLength=struct;
% RootArea=struct;
% SpotCompartment=struct;
% STEDArea=struct;
% STEDDioDistance=struct;
% STEDHeadBottomDistance=struct;
% STEDHeadCenterDistance=struct;
% STEDHeadTopDistance=struct;
% STEDHomerFWHMDistance=struct;
% STEDMajorAxisLength=struct;
% STEDMaxIntensity=struct;
% STEDMeanIntensity=struct;
% STEDMinorAxisLength=struct;
% STEDNeckBottomDistance=struct;
% STEDWeightedCentroidX=struct;
% STEDWeightedCentroidY=struct;




for i=1:numel(folders)
    try
        cd([cd_path filesep folders{i}])
        load 'SpotAnalysis_total.mat'
        exp2='\S*(?=_UID)';
        proteinname=regexp(folders{i},exp2,'match');
        proteinname=proteinname{:};
        proteinname=matlab.lang.makeValidName(proteinname);
        Master_results.(proteinname)=results_total;
        
        %         HeadArea.(proteinname)=results_total.HeadArea;
        % HeadCenterColumn.(proteinname)=results_total.HeadCenterColumn;
        % HeadCenterRow.(proteinname)=results_total.HeadCenterRow;
        % HeadHeight.(proteinname)=results_total.HeadHeight;
        % HeadMajorAxisLength.(proteinname)=results_total.HeadMajorAxisLength;
        % HeadMinorAxisLength.(proteinname)=results_total.HeadMinorAxisLength;
        % HeadWidth.(proteinname)=results_total.HeadWidht;
        % HomerArea.(proteinname)=results_total.HomerArea;
        % HomerCenterDistance.(proteinname)=results_total.HomerCenterDistance;
        % HomerDioDistance.(proteinname)=results_total.HomerDioDistance;
        % HomerMajorAxisLength.(proteinname)=results_total.HomerMajorAxisLength;
        % HomerMaxIntensity.(proteinname)=results_total.HomerMaxIntensity;
        % HomerMeanIntensity.(proteinname)=results_total.HomerMeanIntensity;
        % HomerMinorAxisLength.(proteinname)=results_total.HomerMinorAxisLength;
        % HomerWeightedCentroidX.(proteinname)=results_total.HomerWeightedCentroidX;
        % HomerWeightedCentroidY.(proteinname)=results_total.HomerWeightedCentroidY;
        % NeckArea.(proteinname)=results_total.NeckArea;
        % NeckLength.(proteinname)=results_total.NeckLength;
        % RootArea.(proteinname)=results_total.RootArea;
        % SpotCompartment.(proteinname)=results_total.SpotCompartment;
        % STEDArea.(proteinname)=results_total.STEDArea;
        % STEDDioDistance.(proteinname)=results_total.STEDDioDistance;
        % STEDHeadBottomDistance.(proteinname)=results_total.STEDHeadBottomDistance;
        % STEDHeadCenterDistance.(proteinname)=results_total.STEDHeadCenterDistance;
        % STEDHeadTopDistance.(proteinname)=results_total.STEDHeadTopDistance;
        % STEDHomerFWHMDistance.(proteinname)=results_total.STEDHomerFWHMDistance;
        % STEDMajorAxisLength.(proteinname)=results_total.STEDMajorAxisLength;
        % STEDMaxIntensity.(proteinname)=results_total.STEDMaxIntensity;
        % STEDMeanIntensity.(proteinname)=results_total.STEDMeanIntensity;
        % STEDMinorAxisLength.(proteinname)=results_total.STEDMinorAxisLength;
        % STEDNeckBottomDistance.(proteinname)=results_total.STEDNeckBottomDistance;
        % STEDWeightedCentroidX.(proteinname)=results_total.STEDWeightedCentroidX;
        % STEDWeightedCentroidY.(proteinname)=results_total.STEDWeightedCentroidY;
        
        
        
        clear results_total proteinname
    catch
        disp(['Error in ' folders{i} '. Skipping it'])
        continue
    end
end

save([cd_path filesep 'MasterStruct.mat'],'-v7.3','Master_results');
end

