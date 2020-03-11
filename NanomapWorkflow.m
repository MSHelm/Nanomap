function NanomapWorkflow
addpath(genpath('Z:\user\mhelm1\Nanomap_Analysis\Matlab'));
addpath(genpath('Z:\user\mhelm1\Building the 3D model\Matlab Code for Lego model\Matlab'));
addpath(genpath('Z:\user\mhelm1\Subcellular Distribution Analysis\Matlab Programs'));
addpath(genpath('Z:\user\mhelm1\Programming'));
addpath(genpath('Z:\user\mhelm1\Programming\MatLab\Colormaps'));
set(0, 'DefaultFigureColormap', inferno())


reps={'Z:\user\mhelm1\Nanomap_Analysis\Data\Replicate1','Z:\user\mhelm1\Nanomap_Analysis\Data\Replicate2'};

for i=1:numel(reps)
align_images_imwarp_parallelized_150px_myfilt(reps{i});
align_images_imwarp_parallelized_150px_mydiofilt_nostedfilt(reps{i});
align_images_imwarp_parallelized_150px_nodiofilt_nostedfilt(reps{i});
end 

for i=1:numel(reps)
    ConvertSpotSTEDChannelToTif(reps{i});
end
%Run icy here
for i=1:numel(reps)
    CombineAndAlignCoordinatFiles(reps{i});
    IndividualSpineAnalysis(reps{i});
end

create_total_average;
CreateTotalResultStructures;
CreateMasterStruct;

FiltNoDiOFiltComparison;
CorrelationSTEDtoDiO;
CorrSTEDToEachOther;
TotalAverages;

ZoneProteinEnrichmentSEM;
CollectMorphologyDataForClustering;

CreatePDFFigures;
IndividualAnalysisPrismFigures;

determineSpineTypeComposition;
program_normalize_by_division_by_background_non_cellular;
program_copy_number_qualifiers;
process_files_for_maps_extract_zone_numbers;
EnrichmentAnalysisAverages;

reps_ms={'Z:\user\mhelm1\Nanomap_Analysis\Copy Numbers\Replicate1','Z:\user\mhelm1\Nanomap_Analysis\Copy Numbers\Replicate2'};
for i=1:numel(reps_ms)
    CalculateColocRatioR2(reps_ms{i});
end
STEDCorrelations;
compilePostsynapticNumbers;
for_lego_model_mushroom_organelles;
corrector_MH;
for_lego_model_mushroom_use_play(0);
for_lego_model_stubby_organelles;
for_lego_model_stubby_use_play(0);

CorrelationHomerSTED;
 

