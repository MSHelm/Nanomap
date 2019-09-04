function MorphologyEDA

cd 'Z:\user\mhelm1\Nanomap_Analysis\Data\total\_Clustering'
classes={'mush','flat'};

for j=1:numel(classes)
tmp=load(['MorphData_' classes{j} '_cleaned.mat']);
data=tmp.(['MorphData_' classes{j} '_cleaned']);

if strcmp('mush',classes{j})
    data=data(:,{'HeadHeight','HeadWidth','HeadArea','HomerFWHMArea','HomerFWHMCenterAngle','HomerFWHMCenterDistance','HomerFWHMDioDistance','HomerFWHMEccentricity','HomerFWHMMajorAxisLength','HomerFWHMMinorAxisLength','HomerFWHMMeanIntensity','NeckLength','NeckArea'});
elseif strcmp('flat',classes{j})
     data=data(:,{'HeadHeight','HeadWidth','HeadArea','HomerFWHMArea','HomerFWHMCenterAngle','HomerFWHMCenterDistance','HomerFWHMDioDistance','HomerFWHMEccentricity','HomerFWHMMajorAxisLength','HomerFWHMMinorAxisLength','HomerFWHMMeanIntensity'});
end


