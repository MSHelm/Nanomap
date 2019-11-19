cd_path = 'Z:\user\mhelm1\Nanomap_Analysis\Analysis\PSDnanomodules';
classes = {'mush','flat'};
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

