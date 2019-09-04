function DoFCM()

disp('Cleaning up data...')
types={'mush','flat'};
[selection,~]=listdlg('PromptString','Select what spine type should be Analyzed','ListString',{'Mushroom','Flat'},'SelectionMode','single');
data = CleanUpDataForFuzzyCMeans(selection);

Nc=inputdlg('Select Number of Clusters','Input',1,{'5'});
Nc=str2num(Nc{:});

% Normalize each column by its median
data_norm=data./median(data,1);

disp('Running Fuzzy C Means Algorithm')
options=[2.0, 10000, 1e-5,1];  %options: Fuzzy partition matrix exponent, maximum iterations, minimum improvement per step, Information display flag
[centers, U]=fcm(data_norm,Nc,options);

% Retransform with the median to get actual values
centers=centers.*median(data,1);

if selection==1
    centers=array2table(centers,'VariableNames',{'HeadHeight','HeadWidth','HomerFWHMMajorAxisLength','HomerFWHMMinorAxisLength','HomerFWHMCenterDistance','HomerFWHMDioDistance','HomerFWHMMeanIntensity','HomerNumber','NeckLength','NeckArea'});
elseif selection==2
    centers=array2table(centers,'VariableNames',{'HeadHeight','HeadWidth','HomerFWHMMajorAxisLength','HomerFWHMMinorAxisLength','HomerFWHMCenterDistance','HomerFWHMDioDistance','HomerFWHMMeanIntensity','HomerNumber'});
end

display(centers)
writetable(centers,['Centers_' types{selection} '_' num2str(Nc) 'clusters.xlsx'],'WriteRowNames',1);
save(['Centers_' types{selection} '_' num2str(Nc) 'clusters'],'centers')

% Display the maximum membership distribution
figure();
histogram(max(U',[],2))
title('Distribution of the maximum membership for each spine (before dropping low values)')

% Drop all membership percentages with very low value. Spines that have a
% low membership for any cluster will therefore get dropped completely
% (this is very little though)

U(U<0.3)=0;
[~,id]=max(U',[],2);
save(['U_' types{selection} '_' num2str(Nc) 'clusters'],'U')

% Calculate number of member per cluster
id_sum=sum(id==1:Nc);
disp('Number of members per cluster');
display(id_sum');

disp('Number of spines without a clearly associated cluster')
display(sum(id==0));


% AnalyzeFCMClustering%(U,centers,MorphData,ProteinID,selection);

    function data = CleanUpDataForFuzzyCMeans(selection)
        
        cd 'Z:\user\mhelm1\Nanomap_Analysis\Data\total\_Clustering'
        
        load MorphData_mush.mat MorphData_mush
        load MorphData_flat.mat MorphData_flat
        load ProteinID_mush.mat ProteinID_mush
        load ProteinID_flat.mat ProteinID_flat
        load SpotFiles_mush.mat SpotFiles_mush
        load SpotFiles_flat.mat SpotFiles_flat
        
        % Remove neck measurements for flat spine types, as they dont exist there
        MorphData_flat.NeckLength=[];
        MorphData_flat.NeckArea=[];
        
        
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
        save('SpotFiles_mush_cleaned.mat','SpotFiles_mush_cleaned')
        save('SpotFiles_flat_cleaned.mat','SpotFiles_flat_cleaned')
        writetable(MorphData_mush_cleaned,'MorphData_mush_cleaned.csv')
        writetable(MorphData_flat_cleaned,'MorphData_flat_cleaned.csv')
        writetable(ProteinID_mush_cleaned,'ProteinID_mush_cleaned.csv')
        writetable(ProteinID_flat_cleaned,'ProteinID_flat_cleaned.csv')
        writetable(cell2table(SpotFiles_mush_cleaned),'SpotFiles_mush_cleaned.csv')
        writetable(cell2table(SpotFiles_flat_cleaned),'SpotFiles_flat_cleaned.csv')
        
        % Only keep the necessary variables.
        MorphData_mush_cleaned_num=MorphData_mush_cleaned(:,{'HeadHeight','HeadWidth','HomerFWHMMajorAxisLength','HomerFWHMMinorAxisLength','HomerFWHMCenterDistance','HomerFWHMDioDistance','HomerFWHMMeanIntensity','HomerNumber','NeckLength','NeckArea'});
        % For flats also dont take the Neck Measurements, as they do not exist/dont
        % make sense for flat type spines.
        MorphData_flat_cleaned_num=MorphData_flat_cleaned(:,{'HeadHeight','HeadWidth','HomerFWHMMajorAxisLength','HomerFWHMMinorAxisLength','HomerFWHMCenterDistance','HomerFWHMDioDistance','HomerFWHMMeanIntensity','HomerNumber'});
        
        MorphData_mush_cleaned_num=table2array(MorphData_mush_cleaned_num);
        MorphData_flat_cleaned_num=table2array(MorphData_flat_cleaned_num);
      
        if selection==1
            data=MorphData_mush_cleaned_num;
            ProteinID=ProteinID_mush_cleaned;
            MorphData=MorphData_mush_cleaned;
        elseif selection==2
            data=MorphData_flat_cleaned_num;
            ProteinID=ProteinID_flat_cleaned;
            MorphData=MorphData_flat_cleaned;
        else
            error('Could not get valid data')
        end
        
    end


end
