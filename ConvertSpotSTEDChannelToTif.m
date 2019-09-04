function ConvertSpotSTEDChannelToTif(cd_path)

addpath(genpath('Z:\user\mhelm1\Nanomap_Analysis\Matlab'));
% cd_path='Z:\user\mhelm1\Nanomap_Analysis\Data\Replicate1';
cd(cd_path);
files=[];
files=dir;
folders={};
for i=3:numel(files)
    if files(i).isdir && strcmp(files(i).name,'figures')==0
        folders{numel(folders)+1}=files(i).name;
    end
end

w=waitbar(0,'Calculating...');

for i=1:numel(folders)
    waitbar(i/numel(folders),w,['Currently processing ' folders{i}]);
    cd([cd_path filesep folders{i}]);
    [status,~]=fileattrib('*spots*sted.tif');
    if status==0
        try
            [~,mess]=fileattrib('*spots*.txt');
            for j=1:numel(mess)
                img=dlmread(mess(j).Name);
                img=img(1:301,603:903);
                img=mat2gray(img,[0 255]);
                imwrite(img,[mess(j).Name(1:end-4) '_sted.tif']);
            end
        catch
            disp(['No spot files found in ' folders{i} '. Skipping it']);
            continue
        end
    end
end
close(w);

end