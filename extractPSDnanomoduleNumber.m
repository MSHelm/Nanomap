cd_path = 'Z:\user\mhelm1\Nanomap_Analysis\Analysis\PSDnanomodules';
classes = {'mush','flat'};


%%         Count how many spines have 0,1,2,3,>3 PSD nanomodules
spotresults = nan(5,8,2);
for class = 1:numel(classes)
    spotresults = nan(5,8,2);
    spots = [];
    
    for i = 1:2
        proteins = getfolders([cd_path filesep 'Replicate' num2str(i)]);
        proteins = natsortfiles(proteins);
        
        
        for j = 1:numel(proteins)
            cd([cd_path filesep 'Replicate' num2str(i) filesep proteins{j}])
            load([proteins{j} '_SpotAnalysis.mat']);
            
            spotnum = cell2mat(results.STEDHeadSpotNumber)';
            classification = cell2mat(results.Class)';
            spotnum(classification~=class) = [];
            
            spotresults(1,j,i) = sum(spotnum==0);
            spotresults(2,j,i) = sum(spotnum==1);
            spotresults(3,j,i) = sum(spotnum==2);
            spotresults(4,j,i) = sum(spotnum==3);
            spotresults(5,j,i) = sum(spotnum>3);
        end
        
    end
    spots=reshape([spotresults(:,:,1); spotresults(:,:,2)] ,size(spotresults,1),[]);
    spotresult.(classes{class})=spots;
end
save([cd_path filesep 'spotresult.m'], 'spotresult');


%%         Extract the respective images
addpath(genpath('Z:\user\mhelm1\Programming\MatLab\bfmatlab'));
k=1;

for class = 1:numel(classes)
    for i = 1:2
        proteins = getfolders([cd_path filesep 'Replicate' num2str(i)]);
        proteins = natsortfiles(proteins);
        for j = 1:numel(proteins)
            cd([cd_path filesep 'Replicate' num2str(i) filesep proteins{j}])
            load([proteins{j} '_SpotAnalysis.mat']);
            spotnum = cell2mat(results.STEDHeadSpotNumber)';
            classification = cell2mat(results.Class)';
            spotnum(classification~=class) = [];
            
            [~, mess]=fileattrib('*spots*.txt');
            [~,order]=sort({mess.Name}); mess=mess(order); clear order %sort to avoid unordered files due to server bugs
            mess(classification~=class) = [];

            for spot = 1:numel(mess)
                img = zeros(151,151,3);
                spotfile = dlmread(mess(spot).Name);
                img(:,:,2) = spotfile(76:226,76:226); %homer
                img(:,:,1) = spotfile(76:226,377:527); %dio
                img(:,:,3) = spotfile(76:226,678:828); %sted
                img = uint8(img);
                
                if class==1
                    if spotnum(spot)==0
                        continue
                    elseif spotnum(spot)==1
                        bfsave(img,['Z:\user\mhelm1\Nanomap_Analysis\Analysis\PSDnanomodules\RepresentativeMushroomImages\1\Image_' num2str(k) '.ome.tiff'])
                        
                    elseif spotnum(spot)==2
                        bfsave(img,['Z:\user\mhelm1\Nanomap_Analysis\Analysis\PSDnanomodules\RepresentativeMushroomImages\2\Image_' num2str(k) '.ome.tiff'])
                        
                    elseif spotnum(spot)==3
                        bfsave(img,['Z:\user\mhelm1\Nanomap_Analysis\Analysis\PSDnanomodules\RepresentativeMushroomImages\3\Image_' num2str(k) '.ome.tiff'])
                        
                    elseif spotnum(spot)>3
                        bfsave(img,['Z:\user\mhelm1\Nanomap_Analysis\Analysis\PSDnanomodules\RepresentativeMushroomImages\over3\Image_' num2str(k) '.ome.tiff'])
                    end
                    
                elseif class==2
                    if spotnum(spot)==0
                        continue
                    elseif spotnum(spot)==1
                        bfsave(img,['Z:\user\mhelm1\Nanomap_Analysis\Analysis\PSDnanomodules\RepresentativeStubbyImages\1\Image_' num2str(k) '.ome.tiff'])
                        
                    elseif spotnum(spot)==2
                        bfsave(img,['Z:\user\mhelm1\Nanomap_Analysis\Analysis\PSDnanomodules\RepresentativeStubbyImages\2\Image_' num2str(k) '.ome.tiff'])
                        
                    elseif spotnum(spot)==3
                        bfsave(img,['Z:\user\mhelm1\Nanomap_Analysis\Analysis\PSDnanomodules\RepresentativeStubbyImages\3\Image_' num2str(k) '.ome.tiff'])
                        
                    elseif spotnum(spot)>3
                        bfsave(img,['Z:\user\mhelm1\Nanomap_Analysis\Analysis\PSDnanomodules\RepresentativeStubbyImages\over3\Image_' num2str(k) '.ome.tiff'])
                    end
                end

                k=k+1;
            end
        end
    end
end

