function CorrectColorMap3DModel
cd_path = 'Z:\user\mhelm1\Nanomap_Analysis\3D model\images from Burkhard\2020-03-05_TGN38 separate cut_BDNf Calreticulin\2020_03_05_images';
cd(cd_path);
files = dir('*.png');
files = {files.name};
for file = 1 : numel(files)
    img = imread(files{file});
    imwrite(img,['Z:\user\mhelm1\Nanomap_Analysis\3D model\images from Burkhard\2020-03-05_TGN38 separate cut_BDNf Calreticulin\matlab' filesep files{file}]);
end
end
