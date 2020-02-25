function DeconvolutionWrapper(SortFiles, RetrieveFiles)
addpath(genpath('Z:\user\mhelm1\Programming\MatLab\bfmatlab'));

cd_path = 'Z:\user\mhelm1\Nanomap_Analysis\Data\total';
cd(cd_path);

decon_folder = 'Z:\user\mhelm1\Manuscripts\2019_Dendritic spine Nanomap paper\Deconvolution';
if exist([decon_folder filesep 'sted']) == 0
    mkdir([decon_folder filesep 'sted']);
    mkdir([decon_folder filesep 'homer']);
    mkdir([decon_folder filesep 'dio']);
end

proteins = getfolders(pwd);
proteins(startsWith(proteins,'_')) = [];
%% Copy files to separate channels folders for deconvolution
if SortFiles
    for protein = 1:numel(proteins)
        cd([cd_path filesep proteins{protein} filesep 'Images' filesep 'LargeImages' filesep 'repImages'])
        UID = char(regexp(proteins{protein},'(?<=UID-)[a-zA-Z0-9]*','match'));
        images = dir('*.tiff');
        images = {images.name};
        images(endsWith(images,{'_mush.tiff','_flat.tiff'})) = [];
        for image = 1:numel(images)
            img = bfopen(images{image});
            img = img{1}; %we only need the image data, no need for the metadata
            sted = img{1,1};
            img_name = img{1,2};
            img_name = img_name(1:end-24);
            dio = img{2,1};
            homer = img{3,1};
            bfsave(sted, [decon_folder filesep 'sted' filesep img_name '_UID-' UID '_sted.tiff']);
            bfsave(homer, [decon_folder filesep 'homer' filesep img_name '_UID-' UID '_homer.tiff']);
            bfsave(dio, [decon_folder filesep 'dio' filesep img_name '_UID-' UID '_dio.tiff']);
        end
    end
end

%% Retrieve deconvolved images and sort back into the appropriate folder as a 3 channel tiff image
if RetrieveFiles
    cd([decon_folder filesep 'sted']);
    images = dir('*.tiff');
    images = {images.name};
    
    for image = 1:numel(images)
        dio = imread([decon_folder filesep 'decon' filesep images{image}(1:end-10) '_dio_cmle.tif']);
        homer = imread([decon_folder filesep 'decon' filesep images{image}(1:end-10) '_homer_cmle.tif']);
        sted = imread([decon_folder filesep 'decon' filesep images{image}(1:end-10) '_sted_cmle.tif']);
        img = cat(3, sted, dio, homer);
        
        %     find corresponding protein folder to save the images back to
        UID = char(regexp(images{image},'(?<=UID-)[a-zA-Z0-9]*','match'));
        img_name = char(regexp(images{image},'.+(?=_UID)','match'));
        bfsave(img, [cd_path filesep proteins{contains(proteins,['UID-' UID])} filesep 'Images' filesep 'LargeImages' filesep 'repImages' filesep img_name '_cmle.tiff']);
    end
end
end