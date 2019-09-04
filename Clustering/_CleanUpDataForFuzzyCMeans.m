function CleanUpDataForFuzzyCMeans()

cd 'Z:\user\mhelm1\Nanomap_Analysis\Data\total\_Clustering'

load MorphData_mush
load MorphData_flat
load ProteinID_mush
load ProteinID_flat
load SpotFiles_mush
load SpotFiles_flat

% Remove neck measurements for flat spine types, as they dont exist there
MorphData_flat.NeckLength=[];
MorphData_flat.NeckArea=[];


% MorphData_mush_num=table2array(MorphData_mush);
% MorphData_flat_num=table2array(MorphData_flat);

% remove all entries with a NaN inside
iOk=[];
iOk=all(isfinite(table2array(MorphData_mush)),2);
MorphData_mush_cleaned=MorphData_mush(iOk,:);
% ProteinID_mush=table2array(ProteinID_mush);
ProteinID_mush_cleaned=ProteinID_mush(iOk,:);
SpotFiles_mush_cleaned=SpotFiles_mush(iOk,:);

iOk=[];
iOk=all(isfinite(table2array(MorphData_flat)),2);
MorphData_flat_cleaned=MorphData_flat(iOk,:);
% ProteinID_flat=table2array(ProteinID_flat);
ProteinID_flat_cleaned=ProteinID_flat(iOk,:);
SpotFiles_flat_cleaned=SpotFiles_flat(iOk,:);

save('MorphData_mush_cleaned.mat','MorphData_mush_cleaned')
save('MorphData_flat_cleaned.mat','MorphData_flat_cleaned')
save('ProteinID_mush_cleaned.mat','ProteinID_mush_cleaned')
save('ProteinID_flat_cleaned.mat','ProteinID_flat_cleaned')
save('SpotFiles_mush_cleaned.mat','SpotFiles_mush_cleaned');
save('SpotFiles_flat_cleaned.mat','SpotFiles_flat_cleaned');



% Only keep the necessary variables.
MorphData_mush_cleaned=MorphData_mush_cleaned(:,{'HeadArea','HomerArea','HomerCenterDistance','HomerDioDistance','HomerMeanIntensity','NeckLength'});
% For flats also dont take the Neck Measurements, as they do not exist/dont
% make sense for flat type spines.
MorphData_flat_cleaned=MorphData_flat_cleaned(:,{'HeadArea','HomerArea','HomerCenterDistance','HomerDioDistance','HomerMeanIntensity'});

% Normalize to fit to normal distribution
% Actually not many of the data are normally distributed!!! Does this still
% make sense? it at least compresses the data to be close together
% regarding min/max values.

MorphData_mush_cleaned_num=table2array(MorphData_mush_cleaned);
MorphData_flat_cleaned_num=table2array(MorphData_flat_cleaned);

MorphData_mush_cleaned_norm=(MorphData_mush_cleaned_num - mean(MorphData_mush_cleaned_num))./std(MorphData_mush_cleaned_num);
MorphData_flat_cleaned_norm=(MorphData_flat_cleaned_num - mean(MorphData_flat_cleaned_num))./std(MorphData_flat_cleaned_num);

end