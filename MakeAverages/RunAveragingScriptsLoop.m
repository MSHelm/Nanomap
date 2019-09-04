reps={'Z:\user\mhelm1\Nanomap_Analysis\Data\Replicate1','Z:\user\mhelm1\Nanomap_Analysis\Data\Replicate2'};
addpath(genpath('Z:\user\mhelm1\Nanomap_Analysis\Matlab\MakeAverages'));
% for i=1:numel(reps)
% disp('Running align_images_imwarp_parallelized_150px');
% align_images_imwarp_parallelized_150px(reps{i});
% disp('Running align_images_imwarp_parallelized_150px_aligntop');
% align_images_imwarp_parallelized_150px_aligntop(reps{i});
% disp('align_images_imwarp_parallelized_fullimg');
% align_images_imwarp_parallelized_fullimg(reps{i});
% disp('align_images_imwarp_parallelized_nofilt_150px');
% align_images_imwarp_parallelized_nofilt_150px(reps{i});
% disp('align_images_imwarp_parallelized_nofilt_fullimg');
% align_images_imwarp_parallelized_nofilt_fullimg(reps{i});
% disp('Running align_images_imwarp_parallelized_150px_myfilt');
% align_images_imwarp_parallelized_150px_myfilt(reps{i});
% end

for i=1:numel(reps)
disp('Running align_images_imwarp_parallelized_150px');
align_images_imwarp_parallelized_150px(reps{i});
% disp('Running align_images_imwarp_parallelized_150px_myfilt');
% align_images_imwarp_parallelized_150px_myfilt(reps{i});
end
create_total_average;
addpath(genpath('Z:\user\mhelm1\Nanomap_Analysis\Matlab'));
determineSpineTypeComposition();
CreateTotalResultStructures();
CreateMasterStruct();
CollectMorphologyDataForClustering();


create_total_average;

