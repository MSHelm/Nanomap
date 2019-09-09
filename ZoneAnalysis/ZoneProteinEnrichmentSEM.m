function ZoneProteinEnrichmentSEM()

cd_path='Z:\user\mhelm1\Nanomap_Analysis\Data\total';
cd(cd_path);

files=[];
files=dir;
folders={};
for i=3:numel(files)
    if files(i).isdir && isempty(regexp(files(i).name,'^[_]','once'))
        folders{numel(folders)+1}=files(i).name;
    end
end

% Read in zone qualifiers
zones_mush=double(imread('Z:\user\mhelm1\Nanomap_Analysis\Matlab\ZoneAnalysis\mushroom_zones_plus_background.tif'));
zones_flat=double(imread('Z:\user\mhelm1\Nanomap_Analysis\Matlab\ZoneAnalysis\flat_thin_zones_plus_background.tif'));

% Initiate results table
T_mush=table();
T_flat=table();
T_mush_sd=table();
T_flat_sd=table();
T_mush_sem=table();
T_flat_sem=table();
T_mush_raw=nan(numel(folders),15,500);
T_flat_raw=nan(numel(folders),11,500);

w=waitbar(0,'Calculating Zone Intensities. Please wait...');

%     Turn warning for not adding entries to all columns in table off, as
%     the flat table does not have zones 12-15
warning('off','MATLAB:table:RowsAddedExistingVars')

%% Collect the data
for i=1:numel(folders)
    cd([cd_path filesep folders{i}]);
    waitbar(i/numel(folders))
    
    try
        
        sted_mush=load('CombinedImageStack_Mush_sted_150px_myfilt');
        sted_mush=sted_mush.img_both;
        
        for j=1:15%max(zones_mush(:))
            temp=[];
            for k=1:size(sted_mush,3)
                z=sted_mush(:,:,k);
                temp=cat(1,temp,nansum(z(zones_mush==j))/nansum(z(zones_mush<16)));
            end
            temp(temp==Inf)=[];
            T_mush_raw(i,j,1:numel(temp))=temp;
            temp=temp/sum(zones_mush(:)==j);
            T_mush{i,j}=nanmean(temp);
            T_mush_sd{i,j}=nanstd(temp);
            T_mush_sem{i,j}=nanstd(temp)/sqrt(length(temp));
        end
        
        sted_flat=load('CombinedImageStack_Flat_sted_150px_myfilt');
        sted_flat=sted_flat.img_both;
        
        for j=1:11%max(zones_flat(:))
            temp=[];
            for k=1:size(sted_flat,3)
                z=sted_flat(:,:,k);
                temp=cat(1,temp,nansum(z(zones_flat==j))/nansum(z(zones_flat<16)));
            end
            T_flat_raw(i,j,1:numel(temp))=temp;
            temp=temp/sum(zones_flat(:)==j);
            T_flat{i,j}=nanmean(temp);
            T_flat_sd{i,j}=nanstd(temp);
            T_flat_sem{i,j}=nanstd(temp)/sqrt(length(temp));
        end
        
        %determine protein name
            exp='(?<=UID-)[a-zA-Z0-9]*';
            proteinname{i}=char(regexp(folders{i},exp,'match'));
            
    catch
        disp(['Error in folder ' folders{i}])
        continue
    end
end

%this will later be used for the fold over avg calculation.
T_mush_avg=nanmean(T_mush{:,:},1);
T_flat_avg=nanmean(T_flat{:,:},1);

dlmwrite('Z:\user\mhelm1\Nanomap_Analysis\Matlab\ZoneAnalysis\Mush_ZoneEnrichment_avg_nonnormalized.txt',T_mush_avg);
dlmwrite('Z:\user\mhelm1\Nanomap_Analysis\Matlab\ZoneAnalysis\Flat_ZoneEnrichment_avg_nonnormalized.txt',T_flat_avg);

% remove trailing Nans in third deminsion of the raw value matrix and then save it
T_mush_raw=T_mush_raw(~all(all(isnan(T_mush_raw),2),3),...
  ~all(all(isnan(T_mush_raw),1),3),...
  ~all(all(isnan(T_mush_raw),1),2));
T_flat_raw=T_flat_raw(~all(all(isnan(T_flat_raw),2),3),...
  ~all(all(isnan(T_flat_raw),1),3),...
  ~all(all(isnan(T_flat_raw),1),2));
save([cd_path filesep 'Mush_ZoneEnrichment_raw.mat'],'T_mush_raw');
save([cd_path filesep 'Flat_ZoneEnrichment_raw.mat'],'T_flat_raw');

for i=1:numel(folders)
    %Bring the values back to percentage. Because of the normalization
    %they are otherwise really low and dont add up to 100%
    %         First make the SEM and sd relative so that I can recalculate the
    %         real SD and SEM later again.
    T_mush_sem{i,:}=T_mush_sem{i,:}./T_mush{i,:};
    T_mush_sd{i,:}=T_mush_sd{i,:}./T_mush{i,:};
    T_mush{i,:}=(T_mush{i,:}./nansum(T_mush{i,:}))*100;
    T_mush_sem{i,:}=T_mush_sem{i,:}.*T_mush{i,:};
    T_mush_sd{i,:}=T_mush_sd{i,:}.*T_mush{i,:};
    
    T_flat_sem{i,:}=T_flat_sem{i,:}./T_flat{i,:};
    T_flat_sd{i,:}=T_flat_sd{i,:}./T_flat{i,:};
    T_flat{i,:}=(T_flat{i,:}./nansum(T_flat{i,:}))*100;
    T_flat_sem{i,:}=T_flat_sem{i,:}.*T_flat{i,:};
    T_flat_sd{i,:}=T_flat_sd{i,:}.*T_flat{i,:};
end

%% do t-tests for each protein per zone. 
% First I create an array containing the results for all proteins per zone, against which I test.
T_mush_raw_total=nan(numel(folders)*500,15);
for j=1:size(T_mush_raw_total,2)
    tmp=[];
    tmp=T_mush_raw(:,j,:);
    tmp=tmp(:);
    tmp(isnan(tmp))=[];
T_mush_raw_total(1:numel(tmp),j)=tmp;
end
T_mush_raw_total(all(T_mush_raw_total,2),:)=[];

T_flat_raw_total=nan(numel(folders)*500,11);
for j=1:size(T_flat_raw_total,2)
    tmp=[];
    tmp=T_flat_raw(:,j,:);
    tmp=tmp(:);
    tmp(isnan(tmp))=[];
T_flat_raw_total(1:numel(tmp),j)=tmp;
end
T_flat_raw_total(all(T_flat_raw_total,2),:)=[];

save([cd_path filesep 'Mush_ZoneEnrichment_raw_total.mat'],'T_mush_raw_total');
save([cd_path filesep 'Flat_ZoneEnrichment_raw_total.mat'],'T_flat_raw_total');

% Then I do uncorrected t tests
T_mush_p=nan(size(T_mush,1),size(T_mush,2));
for i=1:size(T_mush,1)
    for j=1:size(T_mush,2)
        [~,p]=ttest2(T_mush_raw_total(:,j),squeeze(T_mush_raw(i,j,:)));
        T_mush_p(i,j)=p;
    end
end

T_flat_p=nan(size(T_flat,1),size(T_flat,2));
for i=1:size(T_flat,1)
    for j=1:size(T_flat,2)
        [~,p]=ttest2(T_flat_raw_total(:,j),squeeze(T_flat_raw(i,j,:)));
        T_flat_p(i,j)=p;
    end
end
        
% Apply Benjamini-Hochberg Correction
FDR_rate=0.1;
T_mush_p_FDR=cat(2,T_mush_p(:),[1:1:numel(T_mush_p)]');
T_mush_p_FDR=sortrows(T_mush_p_FDR);
T_mush_p_FDR(:,3)=[1:1:size(T_mush_p_FDR,1)]';
T_mush_p_FDR(:,4)=(T_mush_p_FDR(:,3)/size(T_mush_p_FDR,1))*FDR_rate;
cutoff=find(T_mush_p_FDR(:,1)<T_mush_p_FDR(:,4),1,'last');
T_mush_p_FDR(cutoff:end,:)=[];
tmp=ones(size(T_mush_p));
tmp(T_mush_p_FDR(:,2))=T_mush_p_FDR(:,1);
T_mush_p_FDR=tmp;

T_flat_p_FDR=cat(2,T_flat_p(:),[1:1:numel(T_flat_p)]');
T_flat_p_FDR=sortrows(T_flat_p_FDR);
T_flat_p_FDR(:,3)=[1:1:size(T_flat_p_FDR,1)]';
T_flat_p_FDR(:,4)=(T_flat_p_FDR(:,3)/size(T_flat_p_FDR,1))*FDR_rate;
cutoff=find(T_flat_p_FDR(:,1)<T_flat_p_FDR(:,4),1,'last');
T_flat_p_FDR(cutoff:end,:)=[];
tmp=ones(size(T_flat_p));
tmp(T_flat_p_FDR(:,2))=T_flat_p_FDR(:,1);
T_flat_p_FDR=tmp;



% Also do bonferroni correction
T_mush_p_bonf=T_mush_p*numel(T_mush_p);
T_flat_p_bonf=T_flat_p*numel(T_flat_p);

%% Writing the data
T_mush.Properties.RowNames=proteinname;
T_flat.Properties.RowNames=proteinname;
T_mush_sd.Properties.RowNames=proteinname;
T_flat_sd.Properties.RowNames=proteinname;
T_mush_sem.Properties.RowNames=proteinname;
T_flat_sem.Properties.RowNames=proteinname;
T_mush_p=array2table(T_mush_p,'RowNames',proteinname,'VariableNames',sprintfc('Zone%i',1:15));
T_flat_p=array2table(T_flat_p,'RowNames',proteinname,'VariableNames',sprintfc('Zone%i',1:11));
T_mush_p_FDR=array2table(T_mush_p_FDR,'RowNames',proteinname,'VariableNames',sprintfc('Zone%i',1:15));
T_flat_p_FDR=array2table(T_flat_p_FDR,'RowNames',proteinname,'VariableNames',sprintfc('Zone%i',1:11));
T_mush_p_bonf=array2table(T_mush_p_bonf,'RowNames',proteinname,'VariableNames',sprintfc('Zone%i',1:15));
T_flat_p_bonf=array2table(T_flat_p_bonf,'RowNames',proteinname,'VariableNames',sprintfc('Zone%i',1:11));


T_mush.Properties.VariableNames=sprintfc('Zone%i',1:15);
T_flat.Properties.VariableNames=sprintfc('Zone%i',1:11);
T_mush_sd.Properties.VariableNames=sprintfc('Zone%i',1:15);
T_flat_sd.Properties.VariableNames=sprintfc('Zone%i',1:11);
T_mush_sem.Properties.VariableNames=sprintfc('Zone%i',1:15);
T_flat_sem.Properties.VariableNames=sprintfc('Zone%i',1:11);

save([cd_path filesep 'ProteinZoneEnrichment_mush.mat'],'T_mush');
save([cd_path filesep 'ProteinZoneEnrichment_flat.mat'],'T_flat');
save([cd_path filesep 'ProteinZoneEnrichment_mush_sd.mat'],'T_mush_sd');
save([cd_path filesep 'ProteinZoneEnrichment_flat_sd.mat'],'T_flat_sd');
save([cd_path filesep 'ProteinZoneEnrichment_mush_sem.mat'],'T_mush_sem');
save([cd_path filesep 'ProteinZoneEnrichment_flat_sem.mat'],'T_flat_sem');
save([cd_path filesep 'ProteinZoneEnrichment_mush_p.mat'],'T_mush_p');
save([cd_path filesep 'ProteinZoneEnrichment_flat_p.mat'],'T_flat_p');
save([cd_path filesep 'ProteinZoneEnrichment_mush_p_FDR.mat'],'T_mush_p_FDR');
save([cd_path filesep 'ProteinZoneEnrichment_flat_p_FDR.mat'],'T_flat_p_FDR');
save([cd_path filesep 'ProteinZoneEnrichment_mush_p_bonf.mat'],'T_mush_p_bonf');
save([cd_path filesep 'ProteinZoneEnrichment_flat_p_bonf.mat'],'T_flat_p_bonf');

writetable(T_mush,[cd_path filesep 'ProteinZoneEnrichment_mush.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','data');
writetable(T_flat,[cd_path filesep 'ProteinZoneEnrichment_flat.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','data');
writetable(T_mush_sd,[cd_path filesep 'ProteinZoneEnrichment_mush.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','sd');
writetable(T_flat_sd,[cd_path filesep 'ProteinZoneEnrichment_flat.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','sd');
writetable(T_mush_sem,[cd_path filesep 'ProteinZoneEnrichment_mush.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','sem');
writetable(T_flat_sem,[cd_path filesep 'ProteinZoneEnrichment_flat.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','sem');
writetable(T_mush_p,[cd_path filesep 'ProteinZoneEnrichment_mush.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','uncorrected p-values');
writetable(T_flat_p,[cd_path filesep 'ProteinZoneEnrichment_flat.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','uncorrected p-values');
writetable(T_mush_p_FDR,[cd_path filesep 'ProteinZoneEnrichment_mush.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','FDR p-values');
writetable(T_flat_p_FDR,[cd_path filesep 'ProteinZoneEnrichment_flat.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','FDR p-values');
writetable(T_mush_p_bonf,[cd_path filesep 'ProteinZoneEnrichment_mush.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','bonferroni p-values');
writetable(T_flat_p_bonf,[cd_path filesep 'ProteinZoneEnrichment_flat.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','bonferroni p-values');

pclose(w)


%% Calculate Fold over average
w=waitbar(0,'Calculating Fold over Average. Please wait...');

T_mush_foldoveravg=table();
T_flat_foldoveravg=table();
T_mush_foldoveravg_sd=table();
T_flat_foldoveravg_sd=table();
T_mush_foldoveravg_sem=table();
T_flat_foldoveravg_sem=table();

for i=1:numel(folders)
    cd([cd_path filesep folders{i}]);
    waitbar(i/numel(folders))
    
    try
        sted_mush=load('CombinedImageStack_Mush_sted_150px_myfilt');
        sted_mush=sted_mush.img_both;
        
        %         total_mush=[];
        for j=1:15%max(zones_mush(:))
            temp=[];
            for k=1:size(sted_mush,3)
                z=sted_mush(:,:,k);
                %                 temp=cat(1,temp,z(zones_mush==j));
                temp=cat(1,temp,nansum(z(zones_mush==j))/nansum(z(zones_mush<16)));
            end
            
            temp=temp/sum(zones_mush(:)==j);
            temp=(temp-T_mush_avg(j))/T_mush_avg(j);
            T_mush_foldoveravg{i,j}=nanmean(temp);
            T_mush_foldoveravg_sd{i,j}=nanstd(temp);
            T_mush_foldoveravg_sem{i,j}=nanstd(temp)/sqrt(length(temp));
        end
        
        sted_flat=load('CombinedImageStack_Flat_sted_150px_myfilt');
        sted_flat=sted_flat.img_both;
        
        
        
        for j=1:11%max(zones_flat(:))
            temp=[];
            for k=1:size(sted_flat,3)
                z=sted_flat(:,:,k);
                %                 temp=cat(1,temp,z(zones_flat==j));
                temp=cat(1,temp,nansum(z(zones_flat==j))/nansum(z(zones_flat<16)));
            end
            
            temp=temp/sum(zones_flat(:)==j);
            temp=(temp-T_flat_avg(j))/T_flat_avg(j);
            T_flat_foldoveravg{i,j}=nanmean(temp);
            T_flat_foldoveravg_sd{i,j}=nanstd(temp);
            T_flat_foldoveravg_sem{i,j}=nanstd(temp)/sqrt(length(temp));
        end
        
    catch
        disp(['Error in folder ' folders{i}])
        continue
    end
end

T_mush_foldoveravg.Properties.RowNames=proteinname;
T_flat_foldoveravg.Properties.RowNames=proteinname;
T_mush_foldoveravg_sd.Properties.RowNames=proteinname;
T_flat_foldoveravg_sd.Properties.RowNames=proteinname;
T_mush_foldoveravg_sem.Properties.RowNames=proteinname;
T_flat_foldoveravg_sem.Properties.RowNames=proteinname;

T_mush_foldoveravg.Properties.VariableNames=sprintfc('Zone%i',1:15);
T_flat_foldoveravg.Properties.VariableNames=sprintfc('Zone%i',1:11);
T_mush_foldoveravg_sd.Properties.VariableNames=sprintfc('Zone%i',1:15);
T_flat_foldoveravg_sd.Properties.VariableNames=sprintfc('Zone%i',1:11);
T_mush_foldoveravg_sem.Properties.VariableNames=sprintfc('Zone%i',1:15);
T_flat_foldoveravg_sem.Properties.VariableNames=sprintfc('Zone%i',1:11);

save([cd_path filesep 'ProteinZoneEnrichment_mush_FoldOverAvg.mat'],'T_mush_foldoveravg');
save([cd_path filesep 'ProteinZoneEnrichment_flat_FoldOverAvg.mat'],'T_flat_foldoveravg');
save([cd_path filesep 'ProteinZoneEnrichment_mush_FoldOverAvg_sd.mat'],'T_mush_foldoveravg_sd');
save([cd_path filesep 'ProteinZoneEnrichment_flat_FoldOverAvg_sd.mat'],'T_flat_foldoveravg_sd');
save([cd_path filesep 'ProteinZoneEnrichment_mush_FoldOverAvg_sem.mat'],'T_mush_foldoveravg_sem');
save([cd_path filesep 'ProteinZoneEnrichment_flat_FoldOverAvg_sem.mat'],'T_flat_foldoveravg_sem');

writetable(T_mush_foldoveravg,[cd_path filesep 'ProteinZoneEnrichment_mush_FoldOverAvg.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','data');
writetable(T_flat_foldoveravg,[cd_path filesep 'ProteinZoneEnrichment_flat_FoldOverAvg.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','data');
writetable(T_mush_foldoveravg_sd,[cd_path filesep 'ProteinZoneEnrichment_mush_FoldOverAvg.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','sd');
writetable(T_flat_foldoveravg_sd,[cd_path filesep 'ProteinZoneEnrichment_flat_FoldOverAvg.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','sd');
writetable(T_mush_foldoveravg_sem,[cd_path filesep 'ProteinZoneEnrichment_mush_FoldOverAvg.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','sem');
writetable(T_flat_foldoveravg_sem,[cd_path filesep 'ProteinZoneEnrichment_flat_FoldOverAvg.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','sem');

close(w)

%% Plot the data
% Put Warning for table columns on again
warning('on','MATLAB:table:RowsAddedExistingVars')

% Plot Mushroom zone enrichments
Ax=[];
f_mush=figure('Name','Mushroom Zone Enrichment');
suptitle('Mushroom Zone Enrichment')
for i=1:size(T_mush,1)
    Ax(i)=subplot(ceil(sqrt(size(T_mush,1))),ceil(sqrt(size(T_mush,1))),i);
    errorbar(T_mush{i,:},T_mush_sem{i,:},'-k')
    hold on
    plot(mean(T_mush{:,:},1),'-r');
    title(T_mush.Properties.RowNames{i})
    hold off
    drawnow limitrate
end
linkaxes(Ax);

Ax=[];
f_mush_foldoveravg=figure('Name','Mushroom Zone Enrichment Fold over Average');
suptitle('Mushroom Zone Enrichment Fold over Average');
for i=1:size(T_mush_foldoveravg,1)
    Ax(i)=subplot(ceil(sqrt(size(T_mush_foldoveravg,1))),ceil(sqrt(size(T_mush_foldoveravg,1))),i);
    errorbar(T_mush_foldoveravg{i,:},T_mush_foldoveravg_sem{i,:},'-k')
    title(T_mush_foldoveravg.Properties.RowNames{i})
end
% linkaxes(Ax);

Ax=[];
f_flat=figure('Name','Flat Zone Enrichment');
suptitle('Flat Zone Enrichment')
for i=1:size(T_flat,1)
    Ax(i)=subplot(ceil(sqrt(size(T_flat,1))),ceil(sqrt(size(T_flat,1))),i);
    errorbar(T_flat{i,:},T_flat_sem{i,:},'-k')
    hold on
    plot(mean(T_flat{:,:},1),'-r');
    title(T_mush.Properties.RowNames{i})
    hold off
    drawnow limitrate
end
linkaxes(Ax);


Ax=[];
f_flat_foldoveravg=figure('Name','Flat Zone Enrichment Fold over Average');
suptitle('Flat Zone Enrichment Fold over Average');
for i=1:size(T_flat_foldoveravg,1)
    Ax(i)=subplot(ceil(sqrt(size(T_flat_foldoveravg,1))),ceil(sqrt(size(T_flat_foldoveravg,1))),i);
    errorbar(T_flat_foldoveravg{i,:},T_flat_foldoveravg_sem{i,:},'-k')
    title(T_flat_foldoveravg.Properties.RowNames{i})
end
% linkaxes(Ax);


end