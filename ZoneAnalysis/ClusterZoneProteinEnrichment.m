function ClusterZoneProteinEnrichment()

addpath(genpath('Z:\user\mhelm1\Nanomap_Analysis\Matlab\Clustering'));
addpath(genpath('Z:\user\mhelm1\Nanomap_Analysis\Matlab\IndividualAnalysis'));
warning('off','MATLAB:xlswrite:AddSheet');

cd_path='Z:\user\mhelm1\Nanomap_Analysis\Data\total';
cd(cd_path);

T_mush=[];
T_flat=[];

load('ProteinZoneEnrichment_mush_FoldOverAvg.mat','T_mush_foldoveravg'); %T_mush
load('ProteinZoneEnrichment_flat_FoldOverAvg.mat','T_flat_foldoveravg'); %T_flat

T_mush=T_mush_foldoveravg;
T_flat=T_flat_foldoveravg;

data_mush=table2array(T_mush);
data_flat=table2array(T_flat);

% figure;
% D=pdist(data_mush,'correlation');
% Z=linkage(D);
% dendrogram(Z,0);
%
% I=inconsistent(Z);
% T=cluster(Z,'cutoff',1);

% Remove NaN columns from flat table (because these zones are not defined)
data_flat=data_flat(:,all(~isnan(data_flat)));

hierarchical_clust;
kmeans_clust;
fcm_clust;

    function hierarchical_clust
        % Do hierarchical clustering
        
        cluster_mush=clusterdata(data_mush,'Maxclust',10,'distance','euclidean');
        cluster_flat=clusterdata(data_flat,'Maxclust',10,'distance','euclidean');
        
        h_mush=histogram(cluster_mush);
        hclusterID_mush=find(h_mush.Values>mean(h_mush.Values));
        hcluster_proteinnames_mush={};
        
        h_flat=histogram(cluster_flat);
        hclusterID_flat=find(h_flat.Values>mean(h_flat.Values));
        hcluster_proteinnames_flat={};
        
        close all;
        
        for i=1:numel(hclusterID_mush)
            hcluster_proteinnames_mush{i}=T_mush.Properties.RowNames(cluster_mush==hclusterID_mush(i));
        end
        
        for i=1:numel(hclusterID_flat)
            hcluster_proteinnames_flat{i}=T_flat.Properties.RowNames(hclusterID_flat(i));
        end
        
        xlswrite([cd_path filesep 'ZoneEnrichmentClusters_mush.xlsx'],padcatcell(hcluster_proteinnames_mush{:})','Hierarchical Clustering');
        xlswrite([cd_path filesep 'ZoneEnrichmentClusters_flat.xlsx'],padcatcell(hcluster_proteinnames_flat{:})','Hierarchical Clustering');
    end

    function kmeans_clust
        %         do Kmeans clustering using optimal number of clusters as
        %         evaluated by elbow method.
        [idx_mush,C_mush,~,k_mush]=kmeans_opt(data_mush);
        kcluster_proteinnames_mush=cell(1,max(idx_mush));
        for i=1:max(idx_mush)
            kcluster_proteinnames_mush{i}=T_mush.Properties.RowNames(idx_mush==i);
        end
        
        [idx_flat,C_flat,~,k_flat]=kmeans_opt(data_flat);
        kcluster_proteinnames_flat=cell(1,max(idx_flat));
        for i=1:max(idx_flat)
            kcluster_proteinnames_flat{i}=T_flat.Properties.RowNames(idx_flat==i);
        end
        
        xlswrite([cd_path filesep 'ZoneEnrichmentClusters_mush.xlsx'],padcatcell(kcluster_proteinnames_mush{:})','KMeans Clustering');
        xlswrite([cd_path filesep 'ZoneEnrichmentClusters_mush.xlsx'],C_mush','KMeans Clustering Centers');
        
        xlswrite([cd_path filesep 'ZoneEnrichmentClusters_flat.xlsx'],padcatcell(kcluster_proteinnames_flat{:})','KMeans Clustering');
        xlswrite([cd_path filesep 'ZoneEnrichmentClusters_flat.xlsx'],C_flat','KMeans Clustering Centers');
        
    end

    function fcm_clust
        %         Do FCM clustering. number of clusters is calculated by subclust
        %         algorithm
        [C_mush, U_mush]=fcm(data_mush,size(subclust(data_mush,0.9),1));
        [~,U_mush_max]=max(U_mush',[],2);
        fcmcluster_proteinnames_mush=cell(1,max(U_mush_max));
        for i=1:max(U_mush_max)
            fcmcluster_proteinnames_mush{i}=T_mush.Properties.RowNames(U_mush_max==i);
        end
        
        [C_flat, U_flat]=fcm(data_flat,size(subclust(data_flat,0.9),1));
        [~,U_flat_max]=max(U_flat',[],2);
        fcmcluster_proteinnames_flat=cell(1,max(U_flat_max));
        for i=1:max(U_flat_max)
            fcmcluster_proteinnames_flat{i}=T_flat.Properties.RowNames(U_flat_max==i);
        end
        
        xlswrite([cd_path filesep 'ZoneEnrichmentClusters_mush.xlsx'],padcatcell(fcmcluster_proteinnames_mush{:})','FCM Clustering');
        xlswrite([cd_path filesep 'ZoneEnrichmentClusters_flat.xlsx'],padcatcell(fcmcluster_proteinnames_flat{:})','FCM Clustering');
        
    end

disp(['Optimal number of cluster for kmeans of mushroom spines was ' num2str(k_mush)]);
disp(['Optimal number of cluster for kmeans of flat spines was ' num2str(k_flat)]);
disp(['Chosen number of clusters for FCM of mushroom spines was ' num2str(size(subclust(data_mush,0.9),1))]);
disp(['Chosen number of clusters for FCM of flat spines was ' num2str(size(subclust(data_flat,0.9),1))]);

warning('on','MATLAB:xlswrite:AddSheet');

end
