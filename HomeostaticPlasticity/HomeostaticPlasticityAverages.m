function HomeostaticPlasticityAverages()
addpath(genpath('Z:\user\mhelm1\Nanomap_Analysis\Matlab'));

cd_path='Z:\user\mhelm1\Nanomap_Analysis\Homeostatic data from Tal';
cd(cd_path)


%% Do the averaging
reps = regexp(genpath(cd_path),['[^;]*'],'match');
reps=reps(contains(reps,'\Analysis\'));

for i=1:numel(reps)
    try
        align_images_imwarp_parallelized_150px_myfilt(reps{i});
    catch
        continue
    end
end


%% Do the Individual Analysis
reps2=reps(endsWith(reps,'\Manual axis selection with neck'));

addpath(genpath('Z:\user\mhelm1\Nanomap_Analysis\Matlab'));
for i=1:numel(reps2)
    try
        %         ConvertSpotSTEDChannelToTif(reps2{i});
        CombineAndAlignCoordinatFiles_Homeostatic(reps2{i});
    catch
        disp(['Skipping folders ' reps2{i}]);
        continue
    end
end


%Need to run icy here

addpath(genpath('Z:\user\mhelm1\Nanomap_Analysis\Matlab\IndividualAnalysis'));
for i=1:numel(reps2)
    try
        IndividualSpineAnalysis(reps2{i});
    catch
        disp(['Skipping folders ' reps2{i}]);
        continue
    end
end


%% Make the total averages for the different proteins and treatments.

cd(cd_path)

% clear class* avg dir* files folders img_* names* sd sem

treatments={'Bic','Bic4AP','LTP','TTX','CNQXAP5','Untreated'};
classes={'Mush', 'Flat', 'Other'}; %Order is important so that it follows the classification numbering!!!
channels={'dio','homer','sted'};
% avg_type={'_150px_orig','_nofilt_150px','_fullimg','_nofilt_fullimg','_150px_aligntop','_150px_myfilt'};


%Get all protein folders
files=[];
files=dir;
proteins={};
for i=3:numel(files)
    if files(i).isdir && isempty(regexp(files(i).name,'^[_]','once'))
        proteins{numel(proteins)+1}=files(i).name;
    end
end

for i=1:numel(proteins)
    cd([cd_path filesep proteins{i}]);
    
    % Create list of subfolders
    files=[];
    files=dir;
    subfolders={};
    for z=3:numel(files)
        if files(z).isdir && sum(strcmp(files(z).name,{'Bic','Bic4AP','LTP','TTX','CNQXAP5','Untreated'}))==0
            subfolders{end+1}=files(z).name;
        end
    end
    
    if ~exist('Bic','dir')
        mkdir('Bic');
        mkdir('Bic4AP');
        mkdir('LTP');
        mkdir('TTX');
        mkdir('CNQXAP5');
        mkdir('Untreated');
    end
    
    for l=1:numel(classes)
        
        for m=1:numel(channels)
            %Initialize results structure
            results=struct('Bic',[],...
                'Bic4AP',[],...
                'LTP',[],...
                'TTX',[],...
                'CNQXAP5',[],...
                'Untreated',[]);
            
            for j=1:numel(subfolders)
                for k=1:numel(treatments)
                    try
                        cd([cd_path filesep proteins{i} filesep subfolders{j} filesep 'Analysis' filesep 'Manual axis selection with neck' filesep treatments{k}]);
                        repdata=[];
                        [~, mess]=fileattrib([channels{m} '_aligned_150px_myfilt*.txt']);
                        mess=natsortfiles({mess.Name});
                        %                     [~,order]=sort({mess.Name});mess=mess(order);order=[]; %sort to avoid unordered spot files due to server bugs
                        class=dlmread('classification.txt');
                        class(class==4)=[];
                        mess=mess(class==l);
                        
                        repdata=zeros(151,151,numel(mess));
                        if isempty(mess)
                            continue
                        end
                        
                        %                     parfor n=1:numel(mess)
                        for n=1:numel(mess)
                            repdata(:,:,n)=dlmread(mess{n});
                        end
                        repdata=(repdata/max(repdata(:)))*255;
                        results.(treatments{k})=cat(3,results.(treatments{k}),repdata);
                    catch
                        disp(['Error in ' subfolders{j} '_' treatments{k} '. Skipping it']);
                        continue
                    end
                end
                save([cd_path filesep proteins{i} filesep classes{l} '_' channels{m} '_CombinedImageStack.mat'],'results')
                
                fields=fieldnames(results);
                for j=1:numel(fields)
                    [avg, sd, sem]=deal(zeros(151));
                    
                    avg=mean(results.(fields{j}),3);
                    sd=std(results.(fields{j}),0,3);
                    sem=sd/sqrt(size(results.(fields{j}),3));
                    
                    dlmwrite([cd_path filesep proteins{i} filesep fields{j} filesep classes{l} '_' channels{m} '_' fields{j} '_total.txt'],avg);
                    dlmwrite([cd_path filesep proteins{i} filesep fields{j} filesep classes{l} '_' channels{m} '_' fields{j} '_total_sd.txt'],sd);
                    dlmwrite([cd_path filesep proteins{i} filesep fields{j} filesep classes{l} '_' channels{m} '_' fields{j} '_total_sem.txt'],sem);
                    
                end
            end
        end
    end
end

%% Create Total results structures for individual Analysis
for i=1:numel(proteins)
    cd([cd_path filesep proteins{i}]);
    
    % Create list of subfolders
    files=[];
    files=dir;
    subfolders={};
    for z=3:numel(files)
        if files(z).isdir && sum(strcmp(files(z).name,{'Bic','Bic4AP','LTP','TTX','CNQXAP5','Untreated'}))==0
            subfolders{end+1}=files(z).name;
        end
    end
    
    for k=1:numel(treatments)
        for j=1:numel(subfolders)
            try
                cd([cd_path filesep proteins{i} filesep subfolders{j} filesep 'Analysis' filesep 'Manual axis selection with neck' filesep treatments{k}]);
                
                SpotAnalysis=load([treatments{k} '_SpotAnalysis.mat']);
                SpotAnalysis=SpotAnalysis.results;
                fields=fieldnames(SpotAnalysis);
                if k==1 %if being run on the first subfolder, create the total results structure with the appropriate fields
                    c=cell(length(fields),1);
                    SpotAnalysis_total=cell2struct(c,fields);
                end
                
                for u=1:numel(fields)
                    SpotAnalysis_total.(fields{u})=cat(2,SpotAnalysis_total.(fields{u}),SpotAnalysis.(fields{u}));
                end
            catch
                disp(['Error in ' subfolders{j} '_' treatments{k} '. Skipping it']);
                continue
            end
        end
        save([cd_path filesep proteins{i} filesep treatments{k} filesep treatments{k} '_SpotAnalysis.mat'],'SpotAnalysis_total');
    end
end


%% Determine the spine type composition in the homeostatic plasticity. I do
% not collect data about skipped synapses here, but who cares.
results_total=NaN(numel(classes),numel(treatments));
for k=1:numel(treatments)
    for l=1:numel(classes)
        tmp=[];
        for i=1:numel(proteins)
            try
                load([cd_path filesep proteins{i} filesep classes{l} '_sted_CombinedImageStack.mat'])
                tmp=cat(3,tmp,results.(treatments{k}));
                clear results
            catch
                disp(['Error in ' proteins{i} filesep classes{l} '_sted_CombinedImageStack.mat'])
                continue
            end
        end
        results_total(l,k)=size(tmp,3);
    end
end
results_total=array2table(results_total,'VariableNames',treatments,'RowNames',classes);
writetable(results_total,'Z:\user\mhelm1\Nanomap_Analysis\Homeostatic data from Tal\SpineTypeComposition.xlsx','WriteVariableNames',1,'WriteRowNames',1);


%% Create scaled images
addpath(genpath('Z:\user\mhelm1\Programming\export_fig'));
% Only use Untreated, Bic, TTX and CNQXAP5
treatments={'Bic','TTX','CNQXAP5','Untreated'};
classes={'Mush', 'Flat'};
addpath(genpath('Z:\user\mhelm1\Programming\MatLab\Colormaps'));
set(0, 'DefaultFigureColormap', inferno())

for i=1:numel(proteins)
    for l=1:numel(classes)
        for m=1:numel(channels)
            
            load([cd_path filesep proteins{i} filesep classes{l} '_' channels{m} '_CombinedImageStack.mat'])
            maximum=[];
            for k=1:numel(treatments)
                results.(treatments{k})=mean(results.(treatments{k}),3);
                maximum(k)=max(results.(treatments{k})(:));
            end
            maximum=max(maximum);
            
            for k=1:numel(treatments)
                figure('Visible','off')
                imagesc(results.(treatments{k}),[0 maximum]); axis equal; axis off
                export_fig([cd_path filesep proteins{i} filesep classes{l} '_' channels{m} '_' treatments{k} '_total.png'],'-transparent', '-CMYK', '-q101')
                if strcmp(classes{l},'Mush') && strcmp(channels{m},'sted')
                    dio=dlmread('Z:\user\mhelm1\Nanomap_Analysis\Data\total\_Controls\TotalAverages\Mush_dio_total_average.txt');
                    homer=dlmread('Z:\user\mhelm1\Nanomap_Analysis\Data\total\_Controls\TotalAverages\Mush_homer_total_average.txt');
                    dio_bw=imbinarize(mat2gray(dio),otsuthresh(mat2gray(dio(:))));
                    dio_bw(120:end,:)=0;
                    dio_bw=edge(dio_bw);
                    dio_bw=bwboundaries(dio_bw);
                    homer_bw=imbinarize(mat2gray(homer),otsuthresh(mat2gray(homer(:))));
                    homer_bw=edge(homer_bw);
                    homer_bw=bwboundaries(homer_bw);
                    f1=figure('Visible','off');
                    imagesc(results.(treatments{k}),[0 maximum]); axis equal; axis off; hold on; plot(dio_bw{1}(:,2),dio_bw{1}(:,1),'w','LineWidth',2); plot(homer_bw{2}(:,2),homer_bw{2}(:,1),'g','LineWidth',2); hold off;
                    export_fig([cd_path filesep proteins{i} filesep classes{l} '_' channels{m} '_' treatments{k} '_total_outlines.png'],'-transparent', '-CMYK', '-q101');
                    close(f1);
                elseif strcmp(classes{l},'Flat') && strcmp(channels{m},'sted')
                    dio=dlmread('Z:\user\mhelm1\Nanomap_Analysis\Data\total\_Controls\TotalAverages\Flat_dio_total_average.txt');
                    homer=dlmread('Z:\user\mhelm1\Nanomap_Analysis\Data\total\_Controls\TotalAverages\Flat_homer_total_average.txt');
                    dio_bw=imbinarize(mat2gray(dio),otsuthresh(mat2gray(dio(:))));
                    dio_bw(120:end,:)=0;
                    dio_bw=edge(dio_bw);
                    dio_bw=bwboundaries(dio_bw);
                    homer_bw=imbinarize(mat2gray(homer),otsuthresh(mat2gray(homer(:))));
                    homer_bw=edge(homer_bw);
                    homer_bw=bwboundaries(homer_bw);
                    f1=figure('Visible','off');
                    imagesc(results.(treatments{k}),[0 maximum]); axis equal; axis off; hold on; plot(dio_bw{1}(:,2),dio_bw{1}(:,1),'w','LineWidth',2); plot(homer_bw{2}(:,2),homer_bw{2}(:,1),'g','LineWidth',2); hold off;
                    export_fig([cd_path filesep proteins{i} filesep classes{l} '_' channels{m} '_' treatments{k} '_total_outlines.png'],'-transparent', '-CMYK', '-q101');
                    close(f1);
                end
                close all
            end
        end
    end
end

%% Calculate Correlation with homer for each condition
addpath(genpath('Z:\user\mhelm1\Programming\export_fig'));
% Only use Untreated, Bic, TTX and CNQXAP5
treatments={'Untreated','Bic','TTX','CNQXAP5'};
classes={'Mush', 'Flat'};
measures={'R2','p'};
measures_calc={'slope','intercept','R2'};
addpath(genpath('Z:\user\mhelm1\Programming\MatLab\Colormaps'));
set(0, 'DefaultFigureColormap', inferno())

results=nan(numel(proteins),numel(classes)*numel(treatments)*numel(measures));
results_calc=nan(numel(proteins),numel(classes)*numel(treatments)*numel(measures_calc));
results_meansted = nan(numel(proteins),numel(classes)*numel(treatments));

for i=1:numel(proteins)
    for l=1:numel(classes)
        for k=1:numel(treatments)
            tmp = load([cd_path filesep proteins{i} filesep classes{l} '_homer_CombinedImageStack.mat']);
            homer = tmp.results.(treatments{k});
            tmp = load([cd_path filesep proteins{i} filesep classes{l} '_sted_CombinedImageStack.mat']);
            sted = tmp.results.(treatments{k});
            ff = fspecial('average', [10 10]);
            vals=[];
            
            for j=1:size(homer,3)
                origh=homer(:,:,j);
                origs=sted(:,:,j);
                %%%%%figure;
                h=origh;
                h=imfilter(h,ff,'replicate');  h=bpass(h,1,30); ccc=find(h<mean2(h)); h(ccc)=0; h2=max(max(h))-h;
                v=watershed(h2); ccc=find(v==0); h(ccc)=0; ccc=find(h>0); h(ccc)=1; h=bwlabel(h);
                %  subplot(3,2,1); imagesc(origh); axis equal; subplot(3,2,2); imagesc(h); axis equal;
                midbox=h(60:90,60:90); ccc=find(midbox>0); mmm=hist(midbox(ccc),[1:1:100]); ccc=find(mmm==max(mmm));
                pp=ccc(1); homersignal=find(h==pp);
                backx=origh(31:121,31:121); backbox=h(31:121,31:121); ccc=find(backbox==0); backhomer=mean(backx(ccc));
                
                h=origs;
                h=imfilter(h,ff,'replicate');  h=bpass(h,1,30); ccc=find(h<mean2(h)); h(ccc)=0; h2=max(max(h))-h;
                v=watershed(h2); ccc=find(v==0); h(ccc)=0; ccc=find(h>0); h(ccc)=1; h=bwlabel(h);
                %  subplot(3,2,5); imagesc(origs); axis equal; subplot(3,2,6); imagesc(h); axis equal;
                backx=origs(31:121,31:121); backbox=h(31:121,31:121); ccc=find(backbox==0); backsted=mean(backx(ccc));
                
                vals(j,1)=sum(origh(homersignal))-backhomer*numel(homersignal);
                vals(j,2)=sum(origs(homersignal))-backsted*numel(homersignal);
            end
            dlmwrite(['Z:\user\mhelm1\Nanomap_Analysis\Homeostatic data from Tal\_CorrelationHomerSTED\' proteins{i} '_' classes{l} '_' treatments{k} '.txt'],vals);
            [h, p] = corrcoef(vals(:,1),vals(:,2));
            rsq=h(1,2);
            p=p(1,2);
            p=p^2;
            
            results(i,(l-1)*numel(treatments)*numel(measures)+k*numel(measures)-1)=rsq;
            results(i,(l-1)*numel(treatments)*numel(measures)+k*numel(measures))=p;
            
            [slope, intercept, rsq] = LinearRegression(vals(:,1),vals(:,2));
            results_calc(i,(l-1)*numel(treatments)*numel(measures_calc)+k*numel(measures_calc)-2)=slope;
            results_calc(i,(l-1)*numel(treatments)*numel(measures_calc)+k*numel(measures_calc)-1)=intercept;
            results_calc(i,(l-1)*numel(treatments)*numel(measures_calc)+k*numel(measures_calc))=rsq;
            
            results_meansted(i,(l-1)*numel(treatments)+k) = nanmean(vals(:,2));
        end
    end
end
[Cx, Bx, Ax] = ndgrid(1:numel(measures),1:numel(treatments), 1:numel(classes));
VarNames = strcat(classes(Ax(:)),'_',treatments(Bx(:)), '_', measures(Cx(:)));
results=array2table(results,'RowNames',proteins,'VariableNames',VarNames);
writetable(results,'Z:\user\mhelm1\Nanomap_Analysis\Homeostatic data from Tal\_CorrelationHomerSTED\CorrelationHomerSTED.xlsx','WriteVariableNames',1,'WriteRowNames',1,'sheet','CorrelationHomerSTED');

[Cx, Bx, Ax] = ndgrid(1:numel(measures_calc),1:numel(treatments), 1:numel(classes));
VarNames = strcat(classes(Ax(:)),'_',treatments(Bx(:)), '_', measures_calc(Cx(:)));
results_calc=array2table(results_calc,'RowNames',proteins,'VariableNames',VarNames);
writetable(results_calc,'Z:\user\mhelm1\Nanomap_Analysis\Homeostatic data from Tal\_CorrelationHomerSTED\CorrelationHomerSTED.xlsx','WriteVariableNames',1,'WriteRowNames',1,'sheet','fits');

[Bx, Ax] = ndgrid(1:numel(treatments), 1:numel(classes));
VarNames = strcat('MeanSTEDIntensity_', classes(Ax(:)),'_',treatments(Bx(:)));
results_meansted = array2table(results_meansted, 'RowNames', proteins, 'VariableNames', VarNames);
writetable(results_meansted,'Z:\user\mhelm1\Nanomap_Analysis\Homeostatic data from Tal\_CorrelationHomerSTED\CorrelationHomerSTED.xlsx','WriteVariableNames',1,'WriteRowNames',1,'sheet','MeanSTEDSignal');




%% Calculate Zone Enrichment

% Only use Untreated, Bic, TTX and CNQXAP5
treatments={'Untreated','Bic','TTX','CNQXAP5'};
classes={'Mush', 'Flat'};
% Read in zone qualifiers
zones_mush=double(imread('Z:\user\mhelm1\Nanomap_Analysis\Matlab\ZoneAnalysis\mushroom_zones_plus_background.tif'));
zones_flat=double(imread('Z:\user\mhelm1\Nanomap_Analysis\Matlab\ZoneAnalysis\flat_thin_zones_plus_background.tif'));

% Read in unnormalized average protein distribution
T_mush_avg=dlmread('Z:\user\mhelm1\Nanomap_Analysis\Matlab\ZoneAnalysis\Mush_ZoneEnrichment_avg_nonnormalized.txt');
T_flat_avg=dlmread('Z:\user\mhelm1\Nanomap_Analysis\Matlab\ZoneAnalysis\Flat_ZoneEnrichment_avg_nonnormalized.txt');

for i=1:numel(proteins)
    T_mush=[];
    T_mush_sd=[];
    T_mush_sem=[];
    T_flat=[];
    T_flat_sd=[];
    T_flat_sem=[];
    
    T_mush_foldoveravg=[];
    T_mush_foldoveravg_sd=[];
    T_mush_foldoveravg_sem=[];
    T_flat_foldoveravg=[];
    T_flat_foldoveravg_sd=[];
    T_flat_foldoveravg_sem=[];
    
    for l=1:numel(classes)
        load([cd_path filesep proteins{i} filesep classes{l} '_sted_CombinedImageStack.mat'])
        
        for k=1:numel(treatments)
            tmp=results.(treatments{k});
            
            if strcmp(classes{l},'Mush')
                
                sted_mush=tmp;
                for j=1:15%max(zones_mush(:))
                    
                    temp=[];
                    for m=1:size(sted_mush,3)
                        z=sted_mush(:,:,m);
                        %                 temp=cat(1,temp,z(zones_mush==j));
                        temp=cat(1,temp,nansum(z(zones_mush==j))/nansum(z(zones_mush<16)));
                    end
                    temp(temp==Inf)=[];
                    temp=temp/sum(zones_mush(:)==j);
                    T_mush(k,j)=nanmean(temp);
                    T_mush_sd(k,j)=nanstd(temp);
                    T_mush_sem(k,j)=nanstd(temp)/sqrt(length(temp));
                    
                    temp=(temp-T_mush_avg(j))/T_mush_avg(j);
                    T_mush_foldoveravg(k,j)=nanmean(temp);
                    T_mush_foldoveravg_sd(k,j)=nanstd(temp);
                    T_mush_foldoveravg_sem(k,j)=nanstd(temp)/sqrt(length(temp));
                    
                end
                
            elseif strcmp(classes{l},'Flat')
                
                sted_flat=tmp;
                for j=1:11%max(zones_flat(:))
                    temp=[];
                    for m=1:size(sted_flat,3)
                        z=sted_flat(:,:,m);
                        %                 temp=cat(1,temp,z(zones_flat==j));
                        temp=cat(1,temp,nansum(z(zones_flat==j))/nansum(z(zones_flat<16)));
                    end
                    temp=temp/sum(zones_flat(:)==j);
                    T_flat(k,j)=nanmean(temp);
                    T_flat_sd(k,j)=nanstd(temp);
                    T_flat_sem(k,j)=nanstd(temp)/sqrt(length(temp));
                    
                    temp=(temp-T_flat_avg(j))/T_flat_avg(j);
                    T_flat_foldoveravg(k,j)=nanmean(temp);
                    T_flat_foldoveravg_sd(k,j)=nanstd(temp);
                    T_flat_foldoveravg_sem(k,j)=nanstd(temp)/sqrt(length(temp));
                end
            end
        end
    end
    
    for k=1:numel(treatments)
        %Bring the values back to percentage. Because of the normalization
        %they are otherwise really low and dont add up to 100%
        %         First make the SEM and sd relative so that I can recalculate the
        %         real SD and SEM later again.
        T_mush_sem(k,:)=T_mush_sem(k,:)./[T_mush(k,:)];
        T_mush_sd(k,:)=T_mush_sd(k,:)./T_mush(k,:);
        T_mush(k,:)=(T_mush(k,:)./nansum(T_mush(k,:)))*100;
        T_mush_sem(k,:)=T_mush_sem(k,:).*T_mush(k,:);
        T_mush_sd(k,:)=T_mush_sd(k,:).*T_mush(k,:);
        
        T_flat_sem(k,:)=T_flat_sem(k,:)./T_flat(k,:);
        T_flat_sd(k,:)=T_flat_sd(k,:)./T_flat(k,:);
        T_flat(k,:)=(T_flat(k,:)./nansum(T_flat(k,:)))*100;
        T_flat_sem(k,:)=T_flat_sem(k,:).*T_flat(k,:);
        T_flat_sd(k,:)=T_flat_sd(k,:).*T_flat(k,:);
    end
    
    T_mush=array2table(T_mush,'VariableNames',sprintfc('Zone%i',1:15),'RowNames',treatments);
    T_mush_sd=array2table(T_mush_sd,'VariableNames',sprintfc('Zone%i',1:15),'RowNames',treatments);
    T_mush_sem=array2table(T_mush_sem,'VariableNames',sprintfc('Zone%i',1:15),'RowNames',treatments);
    
    T_flat=array2table(T_flat,'VariableNames',sprintfc('Zone%i',1:11),'RowNames',treatments);
    T_flat_sd=array2table(T_flat_sd,'VariableNames',sprintfc('Zone%i',1:11),'RowNames',treatments);
    T_flat_sem=array2table(T_flat_sem,'VariableNames',sprintfc('Zone%i',1:11),'RowNames',treatments);
    
    writetable(T_mush,[cd_path filesep proteins{i} filesep 'ProteinZoneEnrichment_mush.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','data');
    writetable(T_flat,[cd_path filesep proteins{i} filesep 'ProteinZoneEnrichment_flat.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','data');
    writetable(T_mush_sd,[cd_path filesep proteins{i} filesep 'ProteinZoneEnrichment_mush.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','sd');
    writetable(T_flat_sd,[cd_path filesep proteins{i} filesep 'ProteinZoneEnrichment_flat.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','sd');
    writetable(T_mush_sem,[cd_path filesep proteins{i} filesep 'ProteinZoneEnrichment_mush.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','sem');
    writetable(T_flat_sem,[cd_path filesep proteins{i} filesep 'ProteinZoneEnrichment_flat.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','sem');
    
    T_mush_prism=reshape([T_mush_foldoveravg';T_mush_foldoveravg_sem'],size(T_mush_foldoveravg',1),[]);
    writetable(array2table(T_mush_prism),[cd_path filesep proteins{i} filesep 'ProteinZoneEnrichment_mush_FoldOverAvg_prism.xlsx']);
    T_flat_prism=reshape([T_flat_foldoveravg';T_flat_foldoveravg_sem'],size(T_flat_foldoveravg',1),[]);
    writetable(array2table(T_flat_prism),[cd_path filesep proteins{i} filesep 'ProteinZoneEnrichment_flat_FoldOverAvg_prism.xlsx']);
    
    T_mush_foldoveravg=array2table(T_mush_foldoveravg,'VariableNames',sprintfc('Zone%i',1:15),'RowNames',treatments);
    T_mush_foldoveravg_sd=array2table(T_mush_foldoveravg_sd,'VariableNames',sprintfc('Zone%i',1:15),'RowNames',treatments);
    T_mush_foldoveravg_sem=array2table(T_mush_foldoveravg_sem,'VariableNames',sprintfc('Zone%i',1:15),'RowNames',treatments);
    
    T_flat_foldoveravg=array2table(T_flat_foldoveravg,'VariableNames',sprintfc('Zone%i',1:11),'RowNames',treatments);
    T_flat_foldoveravg_sd=array2table(T_flat_foldoveravg_sd,'VariableNames',sprintfc('Zone%i',1:11),'RowNames',treatments);
    T_flat_foldoveravg_sem=array2table(T_flat_foldoveravg_sem,'VariableNames',sprintfc('Zone%i',1:11),'RowNames',treatments);
    
    writetable(T_mush_foldoveravg,[cd_path filesep proteins{i} filesep 'ProteinZoneEnrichment_mush_FoldOverAvg.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','data');
    writetable(T_flat_foldoveravg,[cd_path filesep proteins{i} filesep 'ProteinZoneEnrichment_flat_FoldOverAvg.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','data');
    writetable(T_mush_foldoveravg_sd,[cd_path filesep proteins{i} filesep 'ProteinZoneEnrichment_mush_FoldOverAvg.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','sd');
    writetable(T_flat_foldoveravg_sd,[cd_path filesep proteins{i} filesep 'ProteinZoneEnrichment_flat_FoldOverAvg.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','sd');
    writetable(T_mush_foldoveravg_sem,[cd_path filesep proteins{i} filesep 'ProteinZoneEnrichment_mush_FoldOverAvg.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','sem');
    writetable(T_flat_foldoveravg_sem,[cd_path filesep proteins{i} filesep 'ProteinZoneEnrichment_flat_FoldOverAvg.xlsx'],'WriteVariableNames',1,'WriteRowNames',1,'Sheet','sem');
    
end

%% Extract total Intensity of image. cd_path needs to be changed manually!!!
cd_path='Z:\user\mhelm1\Nanomap_Analysis\Homeostatic data from Tal'
cd(cd_path);
%Get all protein folders
files=[];
files=dir;
proteins={};
for i=3:numel(files)
    if files(i).isdir && isempty(regexp(files(i).name,'^[_]','once'))
        proteins{numel(proteins)+1}=files(i).name;
    end
end

addpath(genpath('Z:\user\mhelm1\Nanomap_Analysis\Matlab\IndividualAnalysis'))
for i=1:numel(proteins)
    cd([cd_path filesep proteins{i}]);
    treatments={'Untreated','Bic','TTX','CNQXAP5'};
    classes={'Mush', 'Flat'};
    results_total=[];
    tmp={};
    j=0;
    for l=1:numel(classes)
        load([classes{l} '_sted_CombinedImageStack.mat'])
        for k=1:numel(treatments)
            j=j+1;
            result=[];
            for n=1:size(results.(treatments{k}),3)
                result(n)=sum(sum(results.(treatments{k})(50:90,50:90,n)));
            end
            tmp{j}=result';
            
            %         results_total(l,2*k-1)=mean(tmp);
            %         results_total(l,2*k)=std(tmp)/sqrt(length(tmp));
            
        end
        
    end
    results_total=padcat(tmp{:});
    results_total=(results_total/nanmean(results_total(:,1))*100);
    writetable(array2table(results_total),[cd_path filesep proteins{i} filesep 'ProteinIntensity_central800nm.xlsx']);
end

end