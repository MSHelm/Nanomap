%% Combine deconvolved images into one PDF
% delete('C:\Users\mhelm1\Desktop\representative_images.pdf');
classes = {'mush', 'flat'};
warning('off','images:initSize:adjustingMag');
w = waitbar(0,'Initializing');
for protein = 1:numel(proteins)
    waitbar(protein/numel(proteins),w,'Appending images')
    for class = 1:numel(classes)
        file = dir([cd_path filesep proteins{protein} filesep 'Images' filesep 'LargeImages' filesep 'repImages' filesep '*' classes{class} '*']);
        file = [file.folder filesep file.name];
        file_confocal = file;
        file = [file(1:end-9) 'cmle.tiff'];
        
        img = bfopen(file);
        img = img{1,1};
        img = autoscaleimg(img);
        
        img_confocal = bfopen(file_confocal);
        img_confocal = img_confocal{1,1};
        img_confocal = autoscaleimg(img_confocal);
        
        name = char(regexp(proteins{protein},'\S*(?=_UID)','match'));
        f1 = figure('Visible','off');
        subplot(1,2,1);
        imshow(img);
        axis equal
        title([name '-' classes{class} '-deconvolved']);
        subplot(1,2,2);
        imshow(img_confocal);
        axis equal
        title([name '-' classes{class} '-raw']);
        
        export_fig('C:\Users\mhelm1\Desktop\representative_images.pdf','-append');
        close(f1)
    end
end
close(w)
warning('on','images:initSize:adjustingMag');

function img_scaled = autoscaleimg(img)
red = double(img{1,1});
red(red<prctile(img{1,1}(:),20)) = 0;
red(red>prctile(img{1,1}(:),99.7)) = prctile(img{1,1}(:),99.7);
red = red/max(red(:))*255;

green = double(img{2,1});
green(green<prctile(img{2,1}(:),10)) = 0;
green(green>prctile(img{2,1}(:),99)) = prctile(img{2,1}(:),99);
green = green/max(green(:))*255;

blue = double(img{3,1});
blue(blue<prctile(img{3,1}(:),10)) = 0;
blue(blue>prctile(img{3,1}(:),99)) = prctile(img{3,1}(:),99);
blue = blue/max(blue(:))*255;

img = cat(3,red, green, blue);
img_scaled = uint8(img);
end
