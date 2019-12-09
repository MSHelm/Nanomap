function CreatePDFFigures()

addpath(genpath('Z:\user\mhelm1\Nanomap_Analysis\Matlab'));
addpath(genpath('Z:\user\mhelm1\Programming\export_fig'));
addpath(genpath('Z:\user\mhelm1\Programming\MatLab\Colormaps'));
set(0, 'DefaultFigureColormap', inferno())

cd_path='Z:\user\mhelm1\Nanomap_Analysis\Data\total';

%List of txt files that should be converted
txt_files={'Mush_sted_average_150px_myfilt_total.txt', 'Flat_sted_average_150px_myfilt_total.txt', 'Mush_sted_average_150px_myfilt_total_sd.txt', 'Flat_sted_average_150px_myfilt_total_sd.txt', 'Mush_sted_average_150px_myfilt_total_sem.txt', 'Flat_sted_average_150px_myfilt_total_sem.txt'};

cd(cd_path);
files=[];
files=dir;
folders={};
for i=3:numel(files)
    if files(i).isdir && isempty(regexp(files(i).name,'^[_]','once'))
        folders{numel(folders)+1}=files(i).name;
    end
end

w=waitbar(0,'Calculating...');
% Load zone enrichment table for creating the zone enrichment plots later
% load Z:\user\mhelm1\Nanomap_Analysis\Data\total\ProteinZoneEnrichment_mush.mat  %T_mush
% load Z:\user\mhelm1\Nanomap_Analysis\Data\total\ProteinZoneEnrichment_flat.mat  %T_flat
% load Z:\user\mhelm1\Nanomap_Analysis\Data\total\ProteinZoneEnrichment_mush_sem.mat %T_mush_sem
% load Z:\user\mhelm1\Nanomap_Analysis\Data\total\ProteinZoneEnrichment_flat_sem.mat %T_flat_sem

load Z:\user\mhelm1\Nanomap_Analysis\Data\total\ProteinZoneEnrichment_mush_FoldOverAvg.mat  %T_mush
load Z:\user\mhelm1\Nanomap_Analysis\Data\total\ProteinZoneEnrichment_flat_FoldOverAvg.mat  %T_flat
load Z:\user\mhelm1\Nanomap_Analysis\Data\total\ProteinZoneEnrichment_mush_FoldOverAvg_sem.mat %T_mush_sem
load Z:\user\mhelm1\Nanomap_Analysis\Data\total\ProteinZoneEnrichment_flat_FoldOverAvg_sem.mat %T_flat_sem

for i=1:numel(folders)
    waitbar(i/numel(folders),w,['Currently processing ' folders{i}]);
    try
        cd([cd_path filesep folders{i}]);
        
        % Export pictures as pdf and png.
        for j=1:numel(txt_files)
            a=[];
            a=dlmread(txt_files{j});
            f1=figure('Visible','off');
            imagesc(a); axis equal; axis off;
            export_fig([cd_path filesep folders{i} filesep folders{i} '_' txt_files{j}(1:end-4)], '-transparent', '-CMYK', '-q101','-pdf', '-png', '-eps');
            close(f1)
            %         Also create the image with DiO and Homer outline
            if strcmp(txt_files{j},'Mush_sted_average_150px_myfilt_total.txt')
                dio=dlmread('Z:\user\mhelm1\Nanomap_Analysis\Data\total\_Controls\TotalAverages\Mush_dio_total_average.txt');
                homer=dlmread('Z:\user\mhelm1\Nanomap_Analysis\Data\total\_Controls\TotalAverages\Mush_homer_total_average.txt');
                dio_bw=imbinarize(mat2gray(dio),otsuthresh(mat2gray(dio(:))));
                dio_bw(120:end,:)=0;
                dio_bw=edge(dio_bw);
                dio_bw=bwboundaries(dio_bw);
                homer_bw=imbinarize(mat2gray(homer),otsuthresh(mat2gray(homer(:))));
                homer_bw=edge(homer_bw);
                homer_bw=bwboundaries(homer_bw);
                f1=figure('Visible','off');
                  imagesc(a); axis equal; axis off; hold on; plot(dio_bw{1}(:,2),dio_bw{1}(:,1),'Color', [0, 1,0.094], 'LineWidth',4); plot(homer_bw{2}(:,2),homer_bw{2}(:,1),'Color', [0, 0.529, 0.996], 'LineWidth',4); hold off;
              
%                 imagesc(a); axis equal; axis off; hold on; plot(dio_bw{1}(:,2),dio_bw{1}(:,1),'w','LineWidth',2); plot(homer_bw{2}(:,2),homer_bw{2}(:,1),'g','LineWidth',2); hold off;
                export_fig([cd_path filesep folders{i} filesep folders{i} '_' txt_files{j}(1:end-4) '_outlines'], '-transparent', '-CMYK', '-q101','-png');
                close(f1);
            elseif strcmp(txt_files{j},'Flat_sted_average_150px_myfilt_total.txt')
                dio=dlmread('Z:\user\mhelm1\Nanomap_Analysis\Data\total\_Controls\TotalAverages\Flat_dio_total_average.txt');
                homer=dlmread('Z:\user\mhelm1\Nanomap_Analysis\Data\total\_Controls\TotalAverages\Flat_homer_total_average.txt');
                dio_bw=imbinarize(mat2gray(dio),otsuthresh(mat2gray(dio(:))));
                dio_bw(120:end,:)=0;
                dio_bw=edge(dio_bw);
                dio_bw=bwboundaries(dio_bw);
                homer_bw=imbinarize(mat2gray(homer),otsuthresh(mat2gray(homer(:))));
                homer_bw=edge(homer_bw);
                homer_bw=bwboundaries(homer_bw);
                f1=figure('Visible','off');
                imagesc(a); axis equal; axis off; hold on; plot(dio_bw{1}(:,2),dio_bw{1}(:,1),'Color', [0, 1,0.094],'LineWidth',4); plot(homer_bw{2}(:,2),homer_bw{2}(:,1), 'Color', [0, 0.529, 0.996],'LineWidth',4); hold off;
                export_fig([cd_path filesep folders{i} filesep folders{i} '_' txt_files{j}(1:end-4) '_outlines'], '-transparent', '-CMYK', '-q101','-png');
                close(f1);
            end
        end
        
        %     get proteinname of current folder to find the respective row in the
        %     zone enrichment table
        exp='(?<=UID-)[a-zA-Z0-9]*';
        proteinname=matlab.lang.makeValidName(char(regexp(folders{i},exp,'match')));
        
        f_mush=figure('Visible','off');
        %     errorbar(1:size(T_mush,2),T_mush{proteinname,:},T_mush_sem{proteinname,:},'-k')
        %     hold on
        %     errorbar(1:size(T_mush,2),mean(T_mush{:,:},1),mean(T_mush_sem{:,:},1),'--r');
        %     hold off
        
        errorbar(1:size(T_mush_foldoveravg,2), T_mush_foldoveravg{proteinname,:}, T_mush_foldoveravg_sem{proteinname,:},'-k');
        ax=gca;
        set(ax,'Box','off','XTickmode','manual','XTick',1:size(T_mush_foldoveravg,2),'XTickLabel',sprintfc('Zone %i',1:size(T_mush_foldoveravg,2)));
        ylabel('Percentage of protein [%]');
        export_fig([cd_path filesep folders{i} filesep folders{i} '_' 'ZoneEnrichment_mush'], '-transparent', '-CMYK', '-q101','-pdf', '-png', '-eps')
        close(f_mush)
        
        f_flat=figure('Visible','off');
        %     errorbar(1:size(T_flat,2),T_flat{proteinname,:},T_flat_sem{proteinname,:},'-k')
        %     hold on
        %     errorbar(1:size(T_flat,2),mean(T_flat{:,:},1),mean(T_flat_sem{:,:},1),'--r');
        %     hold off
        errorbar(1:size(T_flat_foldoveravg,2), T_flat_foldoveravg{proteinname,:}, T_flat_foldoveravg_sem{proteinname,:},'-k');
        ax=gca;
        set(ax,'Box','off','XTickmode','manual','XTick',1:size(T_flat_foldoveravg,2),'XTickLabel',sprintfc('Zone %i',1:size(T_flat_foldoveravg,2)));
        ylabel('Percentage of protein [%]');
        export_fig([cd_path filesep folders{i} filesep folders{i} '_' 'ZoneEnrichment_flat'], '-transparent', '-CMYK', '-q101','-pdf', '-png', '-eps')
        close(f_flat)
        
    catch
        disp(['Error in ' folders{i} ' . Skipping it']);
        continue
    end
end




close(w);




disp('Done!')


end