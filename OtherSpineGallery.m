addpath(genpath('Z:\user\mhelm1\Programming\MatLab\bfmatlab'));

reps={'Z:\user\mhelm1\Nanomap_Analysis\Data\Replicate1','Z:\user\mhelm1\Nanomap_Analysis\Data\Replicate2'};
k=1;
for rep = 1:numel(reps)
    cd_path=reps{rep};
    folders = getfolders(cd_path);
    for folder=1:numel(folders)
        cd([cd_path filesep folders{folder}]);
        disp(['Currently extracting images from folder ' folders{folder}])
        [~, mess]=fileattrib('*_spots*.txt');
        [~,order]=sort({mess.Name});mess=mess(order);order=[]; %sort to avoid unordered spot files due to server bugs
        classification = dlmread('classification.txt');
        mess(classification~=3)=[];
        
        for i=1:numel(mess)
            img = zeros(151,151,3);
            spot = dlmread(mess(i).Name);
            img(:,:,2) = spot(76:226,76:226); %homer
            img(:,:,1) = spot(76:226,377:527); %dio
            img(:,:,3) = spot(76:226,678:828); %sted
            img = uint8(img);
            bfsave(img,['Z:\user\mhelm1\Nanomap_Analysis\Analysis\OtherSpineGallery\OtherSpine_' num2str(k) '.ome.tiff'])
            k=k+1;
        end
    end
end

