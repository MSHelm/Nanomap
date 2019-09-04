function DisplayAverages()
cd_path='Z:\user\mhelm1\Nanomap_Analysis\Data\total';
cd(cd_path)

classes='Mush';


avg_type={'_150px','_fullimg','_nofilt_150px','_nofilt_fullimg','_150px_aligntop'};


files=[];
files=dir;
folders={};
for i=3:numel(files)
    if files(i).isdir && strcmp(files(i).name,'figures')==0
        folders{numel(folders)+1}=files(i).name;
    end
end

for i=1:numel(folders)
    try
        cd([cd_path filesep folders{i}])
%         disp(folders{i})
        figure('Visible','off');
        
        img=dlmread([classes '_dio_average_150px_Replicate1.txt']);
        subplot(4,6,1); imagesc(img); axis equal;
        
        img=dlmread([classes '_homer_average_150px_Replicate1.txt']);
        subplot(4,6,2); imagesc(img); axis equal;
        
        img=dlmread([classes '_sted_average_150px_Replicate1.txt']);
        subplot(4,6,3); imagesc(img); axis equal;
        
        img=dlmread([classes '_dio_average_150px_Replicate2.txt']);
        subplot(4,6,4); imagesc(img); axis equal;
        
        img=dlmread([classes '_homer_average_150px_Replicate2.txt']);
        subplot(4,6,5); imagesc(img); axis equal;
        
        img=dlmread([classes '_sted_average_150px_Replicate2.txt']);
        subplot(4,6,6); imagesc(img); axis equal;
        
        z=7;
        for j=1:numel(avg_type)
            
            img=dlmread([classes '_sted_average' avg_type{j} '_Replicate1.txt']);
            subplot(4,6,z); imagesc(img); axis equal;
            title([avg_type{j} '_Rep1']);
            
            img=dlmread([classes '_sted_average' avg_type{j} '_Replicate2.txt']);
            subplot(4,6,z+1); imagesc(img); axis equal;
            title([avg_type{j} '_Rep2']);
            
            img=dlmread([classes '_sted_average' avg_type{j} '_total.txt']);
            subplot(4,6,z+2); imagesc(img); axis equal;
            title([avg_type{j} '_total']);
            
            z=z+3;
        end
        print([cd_path filesep '_Overviews' filesep folders{i} '_AverageOverview.svg'],'-dsvg','-painters');
        print([cd_path filesep '_Overviews' filesep folders{i} '_AverageOverview.jpeg'],'-djpeg','-opengl')
        close all
    catch
        disp(['Error in ' folders{i} '. Skipping it']);
        continue
    end
end

end