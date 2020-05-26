function CorrectColorMap3DModel
% The pictures I get from Burkhard have a problem with the
% transparency/color map, which causes them to be differently displayed in
% different applications. This script just opens each image and resaves it
% as a png, which fixes this problem
cd_path = 'Z:\user\mhelm1\Nanomap_Analysis\3D model\stubby_original';
cd(cd_path);
files = dir('*.png');
files = {files.name};
for file = 1 : numel(files)
    img = imread(files{file});
    imwrite(img,['Z:\user\mhelm1\Nanomap_Analysis\3D model\stubby' filesep files{file}]);
end
end
