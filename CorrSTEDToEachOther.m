function CorrSTEDToEachOther
addpath(genpath('Z:\user\mhelm1\Programming\export_fig'))

cd_path='Z:\user\mhelm1\Nanomap_Analysis\Data\total';
cd(cd_path);

classes={'Mush', 'Flat'};

files=[];
files=dir;
folders={};
for i=3:numel(files)
    if files(i).isdir && isempty(regexp(files(i).name,'^[_]','once'))
        folders{numel(folders)+1}=files(i).name;
    end
end

    exp2='\S*(?=_UID)';
for i=1:numel(folders)
proteins(i)=regexp(folders{i},exp2,'match');
end

proteins=matlab.lang.makeValidName(proteins);

for h=1:numel(classes)
    if h==1
        zones=double(imread('Z:\user\mhelm1\Nanomap_Analysis\Matlab\ZoneAnalysis\mushroom_zones_plus_background.tif'));
    elseif h==2
        zones=double(imread('Z:\user\mhelm1\Nanomap_Analysis\Matlab\ZoneAnalysis\flat_thin_zones_plus_background.tif'));
    end
    
    results=NaN(numel(folders),numel(folders));
    for i=1:numel(folders)
        cd([cd_path filesep folders{i}]);
        a=dlmread([classes{h} '_sted_average_150px_myfilt_total.txt']);
        for j=1:numel(folders)
            b=dlmread([cd_path filesep folders{j} filesep classes{h} '_sted_average_150px_myfilt_total.txt']);
            results(i,j)=corr2(a(zones<16),b(zones<16));
        end
    end
    
    
    f1=figure('Visible','Off');
    imagesc(results); axis equal; xticklabels(proteins); xticks(1:numel(proteins)); xtickangle(90); yticklabels(proteins); yticks(1:numel(proteins)); ytickangle(90); ax=gca; ax.XAxis.FontSize=8; ax.YAxis.FontSize=8;
   
    export_fig(['Z:\user\mhelm1\Nanomap_Analysis\Data\total\_Controls' filesep  classes{h} '_CorrelationsSTEDToEachOther_zones'], '-q101','-png','-transparent');
    close(f1);
    results=array2table(results,'VariableNames',proteins,'RowNames',proteins);
    writetable(results,['Z:\user\mhelm1\Nanomap_Analysis\Data\total\_Controls\' classes{h} '_CorrelationsSTEDToEachOther_zones.xlsx'],'WriteRowNames',1,'WriteVariableNames',1);
end
end

