function CreateClusterAverages(type)
%global counter angles scaling bottomx topx rightx leftx bottomy topy righty lefty classification no_sted_images...
%    rotation_angles vertical_shifts horizontal_shifts...
%    bottomneckx bottomnecky shafttopleftx shafttoplefty shafttoprightx shafttoprighty shaftbottomrightx shaftbottomrighty shaftbottomleftx shaftbottomlefty...
%    spineline_x spineline_y cd_path
% cd_path='Z:\user\mhelm1\Nanomap_Analysis\Data\Replicate1';
addpath(genpath('Z:\user\mhelm1\Nanomap_Analysis\Matlab\Clustering'));
cd_path='Z:\user\mhelm1\Nanomap_Analysis\Data\total\_Clustering';
cd(cd_path);

if strcmp(type,'Mush')
    U=load('U_mush.mat'); U=U.U;
    ProteinID=load('ProteinID_mush_cleaned.mat'); ProteinID=ProteinID.ProteinID_mush_cleaned;
%     MorphData=load('MorphData_mush_cleaned.mat'); MorphData=MorphData.MorphData_mush_cleaned;
    SpotFiles=load('SpotFiles_mush_cleaned.mat'); SpotFiles=SpotFiles.SpotFiles_mush_cleaned;
    
elseif strcpm(type,'Flat')
    U=load('U_flat.mat'); U=U.U;
    ProteinID=load('ProteinID_flat_cleaned.mat'); ProteinID=ProteinID.ProteinID_flat_cleaned;
%     MorphData=load('MorphData_flat_cleaned.mat'); MorphData=MorphData.MorphData_flat_cleaned;
    SpotFiles=load('SpotFiles_flat_cleaned.mat'); SpotFiles=SpotFiles.SpotFiles_flat_cleaned;
else
    error('No valid spine type was given. Enter either Mush or Flat.')
end

proteinnames=ProteinID.Properties.VariableNames;

% Get the ID of the cluster with the maximum degree of membership for each
% spine
[~,idx]=max(U',[],2);

w=waitbar(0,'Please wait...');

for protein=1:size(proteinnames,2)
    
    waitbar(protein/size(proteinnames,2),w,['Currently calculating ' proteinnames{protein}]);
    %     Create a results folder for the protein
    
    try
    if ~exist(['ClusterAverages' filesep proteinnames{protein}],'dir')
        mkdir(['ClusterAverages' filesep proteinnames{protein}]);
    end
    
    clear mess* spots cluster_id path coord* lib* dio* homer* sted*
    
    %     get the spot files and cluster memberships of spines analyzed for this protein
    spots=SpotFiles(ProteinID.(proteinnames{protein})==1);
    cluster_id=idx(ProteinID.(proteinnames{protein})==1);
    
    %% Create a library that links a spot file to its corresponding aligned images.

    % get the two folder names from the spot files
    
    
    path=regexp(spots,'\','split');
    path=cellfun(@(x) x(end-1),path,'UniformOutput',0);
    path=[path{:}]';
    path=unique(path);
    
    coord1=load(['Z:\user\mhelm1\Nanomap_Analysis\Data\Replicate1' filesep path{1} filesep 'coordinates.mat']);
    coord1=coord1.coordinates;
    
    [~,mess_spots_rep1]=fileattrib(['Z:\user\mhelm1\Nanomap_Analysis\Data\Replicate1' filesep path{1} filesep '*_spots*.txt']);
    [~,order]=sort({mess_spots_rep1.Name});mess_spots_rep1=mess_spots_rep1(order);order=[]; %sort to avoid unordered spot files due to server bugs
    mess_spots_rep1=mess_spots_rep1(coord1.classification==1 | coord1.classification==2 | coord1.classification==3);
    [~,mess_dio_rep1]=fileattrib(['Z:\user\mhelm1\Nanomap_Analysis\Data\Replicate1' filesep path{1} filesep '*dio_aligned_150px_myfilt*.txt']);
%     [~,order]=sort({mess_dio_rep1.Name});mess_dio_rep1=mess_dio_rep1(order);order=[];
%     %sort to avoid unordered spot files due to server bugs. I need to use
%     natsort instead
    mess_dio_rep1=natsort({mess_dio_rep1.Name});
    [~,mess_homer_rep1]=fileattrib(['Z:\user\mhelm1\Nanomap_Analysis\Data\Replicate1' filesep path{1} filesep 'homer_aligned_150px_myfilt*.txt']);
%     [~,order]=sort({mess_homer_rep1.Name});mess_homer_rep1=mess_homer_rep1(order);order=[]; %sort to avoid unordered spot files due to server bugs. I need to use
%     natsort instead
    mess_homer_rep1=natsort({mess_homer_rep1.Name});
    [~,mess_sted_rep1]=fileattrib(['Z:\user\mhelm1\Nanomap_Analysis\Data\Replicate1' filesep path{1} filesep 'sted_aligned_150px_myfilt*.txt']);
%     [~,order]=sort({mess_sted_rep1.Name});mess_sted_rep1=mess_sted_rep1(order);order=[]; %sort to avoid unordered spot files due to server bugs. I need to use
%     natsort instead
mess_sted_rep1=natsort({mess_sted_rep1.Name});
    lib_rep1=cat(2,{mess_spots_rep1.Name}',{mess_dio_rep1.Name}',{mess_homer_rep1.Name}',{mess_sted_rep1.Name}');
    

    coord2=load(['Z:\user\mhelm1\Nanomap_Analysis\Data\Replicate2' filesep path{2} filesep 'coordinates.mat']);
    coord2=coord2.coordinates;
    
    [~,mess_spots_rep2]=fileattrib(['Z:\user\mhelm1\Nanomap_Analysis\Data\Replicate2' filesep path{2} filesep '*_spots*.txt']);
    [~,order]=sort({mess_spots_rep2.Name});mess_spots_rep2=mess_spots_rep2(order);order=[]; %sort to avoid unordered spot files due to server bugs
    mess_spots_rep2=mess_spots_rep2(coord2.classification==1 | coord2.classification==2 | coord2.classification==3);
    [~,mess_dio_rep2]=fileattrib(['Z:\user\mhelm1\Nanomap_Analysis\Data\Replicate2' filesep path{2} filesep 'dio_aligned_150px_myfilt*.txt']);
%     [~,order]=sort({mess_dio_rep2.Name});mess_dio_rep2=mess_dio_rep2(order);order=[]; %sort to avoid unordered spot files due to server bugs. I need to use
%     natsort instead
    mess_dio_rep2=natsort({mess_dio_rep2.Name});
    [~,mess_homer_rep2]=fileattrib(['Z:\user\mhelm1\Nanomap_Analysis\Data\Replicate2' filesep path{2} filesep 'homer_aligned_150px_myfilt*.txt']);
%     [~,order]=sort({mess_homer_rep2.Name});mess_homer_rep2=mess_homer_rep2(order);order=[]; %sort to avoid unordered spot files due to server bugs. I need to use
%     natsort instead
    mess_homer_rep2=natsort({mess_homer_rep2.Name});
    [~,mess_sted_rep2]=fileattrib(['Z:\user\mhelm1\Nanomap_Analysis\Data\Replicate2' filesep path{2} filesep 'sted_aligned_150px_myfilt*.txt']);
%     [~,order]=sort({mess_sted_rep2.Name});mess_sted_rep2=mess_sted_rep2(order);order=[]; %sort to avoid unordered spot files due to server bugs. I need to use
%     natsort instead
    mess_homer_rep2=natsort({mess_homer_rep2.Name});
    lib_rep2=cat(2,{mess_spots_rep2.Name}',{mess_dio_rep2.Name}',{mess_homer_rep2.Name}',{mess_sted_rep2.Name}');
    lib=cat(1,lib_rep1,lib_rep2);
    
    
    
    %% Loop over the cluster IDs and find all spots that correspond to the cluster for the protein. Average them
    for i=1:max(cluster_id)
        spots_cluster=spots(cluster_id==i);
        dio=[];
        homer=[];
        sted=[];
        for j=1:numel(spots_cluster)
            spots_avg_num=find(contains(lib(:,1),spots_cluster{j}));
            dio(:,:,j)=dlmread(lib{spots_avg_num,2});
            homer(:,:,j)=dlmread(lib{spots_avg_num,3});
            sted(:,:,j)=dlmread(lib{spots_avg_num,4});
        end
        dio_avg=mean(dio,3);
        homer_avg=mean(homer,3);
        sted_avg=mean(sted,3);
        
        dlmwrite(['ClusterAverages' filesep proteinnames{protein} filesep type '_dio_cluster' num2str(i) '.txt'],dio_avg);
        dlmwrite(['ClusterAverages' filesep proteinnames{protein} filesep type '_homer_cluster' num2str(i) '.txt'],homer_avg);
        dlmwrite(['ClusterAverages' filesep proteinnames{protein} filesep type '_sted_cluster' num2str(i) '.txt'],sted_avg);
        
    end
    catch
        disp(['Error in protein ' proteinnames{protein} '. Skipping it.']);
    end
end
close all
end




