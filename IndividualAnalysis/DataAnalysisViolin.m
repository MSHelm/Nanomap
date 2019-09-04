function DataAnalysisViolin()

addpath(genpath('Z:\user\mhelm1\Nanomap_Analysis\Matlab\IndividualAnalysis\Violinplot-Matlab-master'));
% addpath(genpath('Z:\user\mhelm1\Programming\export_fig'));

cd_path='Z:\user\mhelm1\Nanomap_Analysis\Data\total';
cd(cd_path)

% load MasterStruct.mat
load MasterStruct


%Get names of proteins that are present
fields=fieldnames(Master_results);

%Get names of measures parameters
Measurements=fieldnames(Master_results.(fields{1}));

while 1
    clear Measure SpotCompartment stedselect
    %Ask User to choose which Parameter should be shown
    [selection,selectstatus]=listdlg('PromptString','Select Measurement to be shown','SelectionMode','multiple','ListString',Measurements);
    
    if selectstatus==0
        break
    end
    
    for i=1:numel(selection)
        %     try
        %         First get all the protein names
        fields=fieldnames(Master_results(1));
             
        %Need to create a struct which contains all entries for a certain parameter, e.g. HeadArea:
        %         If the parameter is about the STED spots also take the
        %         information in which compartment the spots are. 1=head, 2=neck,
        %         3=root
        for k=1:numel(fields)
            Measure.(fields{k})=Master_results.(fields{k}).(Measurements{selection(i)})';
            if contains(Measurements{selection(i)},'STED')
                SpotCompartment.(fields{k})=Master_results.(fields{k}).SpotCompartment';
            end
        end
        
        %Make everything a numeric vector
        fields=fieldnames(Measure);
        for k=1:numel(fields)
            Measure.(fields{k})=[Measure.(fields{k}){:}]';
            if contains(Measurements{selection(i)},'STED')
                SpotCompartment.(fields{k})=round([SpotCompartment.(fields{k}){:}]');
            end
        end
        
        %         If parameter is about STED spots ask which compartments should be
        %         analyzed
        if contains(Measurements{selection(i)},'STED') && ~contains(Measurements{selection(i)},'Intensity') && ~contains(Measurements{selection(i)},'Enrichment')
            [stedselect,~]=listdlg('PromptString','Select Which compartments should be analyzed','SelectionMode','multiple','ListString',{'Head','Root','Neck'});
            fields=fieldnames(Measure);
            for k=1:numel(fields)
                Measure.(fields{k})=Measure.(fields{k})(ismember(SpotCompartment.(fields{k}),stedselect));
            end
        end
        
        
%         remove NaN or Inf values
            for k=1:numel(fields)
                Measure.(fields{k})(isnan(Measure.(fields{k})))=[];
                Measure.(fields{k})(isinf(Measure.(fields{k})))=[];
            end
        
        %         Multiply measurements with pixel size to get acutal nanometer
        %         values.
%         if contains(Measurements{selection(i)},{'Distance','Length','Height','Width','Distribution'})
%             for k=1:numel(fields)
%                 Measure.(fields{k})=Measure.(fields{k})*20.2;
%             end
%             
%         elseif contains(Measurements{selection(i)},{'Area'})
%             for k=1:numel(fields)
%                 Measure.(fields{k})=Measure.(fields{k})*(20.2^2);
%             end
%         end
        
        
        
        
        figure
        title(Measurements{selection(i)})
        violinplot(Measure)
        %     catch
        %         disp(['Error in ' Measurements{selection(i)}]);
        %         continue
        %     end
    end
end
end