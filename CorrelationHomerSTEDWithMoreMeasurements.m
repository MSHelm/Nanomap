function CorrelationHomerSTEDWithMoreMeasurements(calcCorrs,showFigures)

addpath(genpath('Z:\user\mhelm1\Nanomap_Analysis\Matlab\Utilities'));

classes={'Mush','Flat','Other'};

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

if calcCorrs
    results=nan(1000,numel(folders)*numel(classes)*3);
    HomerSTEDCorr=cell(numel(folders),4*numel(classes));
    VarNames={};
    w=waitbar(0,'Please wait...');
    
    for j=1:numel(folders)
        cd([cd_path filesep folders{j}]);
        waitbar(j/numel(folders),w,['Currently calculating ' folders{j}]);
        load SpotAnalysis_total.mat
                    class=[results_total.Class{:}];
        
        for k=1:numel(classes)
            
            load(['CombinedImageStack_' classes{k} '_sted_150px_nodiofilt_nostedfilt']);
            sted=img_both;
            load(['CombinedImageStack_' classes{k} '_homer_150px_nodiofilt_nostedfilt']);
            homer=img_both;
            load(['CombinedImageStack_' classes{k} '_dio_150px_nodiofilt_nostedfilt']);
            dio=img_both;
            ff = fspecial('average', [10 10]);
            vals=[];
            
            HeadArea=results_total.HeadArea(class==k);
            HeadArea=cell2mat(HeadArea);
            HeadHeight=results_total.HeadArea(class==k);
            HeadHeight=cell2mat(HeadHeight);
            HeadWidth=results_total.HeadArea(class==k);
            HeadWidth=cell2mat(HeadWidth);
            HomerMajorAxisLength=cellfun(@nanmean, results_total.HomerMajorAxisLength(class==k));           
            HomerArea=cellfun(@nansum, results_total.HomerArea(class==k));
            HomerNumber=results_total.HeadArea(class==k);
            HomerNumber=cell2mat(HomerNumber);
            
            for i=1:size(dio,3)
                origh=homer(:,:,i);
                origd=dio(:,:,i);
                origs=sted(:,:,i);
                %%%%%figure;
                h=origh;
                h=imfilter(h,ff,'replicate');  h=bpass(h,1,30); ccc=find(h<mean2(h)); h(ccc)=0; h2=max(max(h))-h;
                v=watershed(h2); ccc=find(v==0); h(ccc)=0; ccc=find(h>0); h(ccc)=1; h=bwlabel(h);
                %  subplot(3,2,1); imagesc(origh); axis equal; subplot(3,2,2); imagesc(h); axis equal;
                midbox=h(60:90,60:90); ccc=find(midbox>0); mmm=hist(midbox(ccc),[1:1:100]); ccc=find(mmm==max(mmm));
                pp=ccc(1); homersignal=find(h==pp);
                backx=origh(31:121,31:121); backbox=h(31:121,31:121); ccc=find(backbox==0); backhomer=mean(backx(ccc));
                
                h=origd;
                h=imfilter(h,ff,'replicate');  h=bpass(h,1,30); ccc=find(h<mean2(h)); h(ccc)=0; h2=max(max(h))-h;
                v=watershed(h2); ccc=find(v==0); h(ccc)=0; ccc=find(h>0); h(ccc)=1; h=bwlabel(h);
                %  subplot(3,2,3); imagesc(origd); axis equal; subplot(3,2,4); imagesc(h); axis equal;
                backx=origd(31:121,31:121); backbox=h(31:121,31:121); ccc=find(backbox==0); backdio=mean(backx(ccc));
                
                h=origs;
                h=imfilter(h,ff,'replicate');  h=bpass(h,1,30); ccc=find(h<mean2(h)); h(ccc)=0; h2=max(max(h))-h;
                v=watershed(h2); ccc=find(v==0); h(ccc)=0; ccc=find(h>0); h(ccc)=1; h=bwlabel(h);
                %  subplot(3,2,5); imagesc(origs); axis equal; subplot(3,2,6); imagesc(h); axis equal;
                backx=origs(31:121,31:121); backbox=h(31:121,31:121); ccc=find(backbox==0); backsted=mean(backx(ccc));
                
                vals(i,1)=sum(origh(homersignal))-backhomer*numel(homersignal);
                vals(i,2)=sum(origd(homersignal))-backdio*numel(homersignal);
                vals(i,3)=sum(origs(homersignal))-backsted*numel(homersignal);
            end

            vals=cat(2,vals,HeadArea',HeadHeight',HeadWidth',HomerMajorAxisLength',HomerArea',HomerNumber');
            dlmwrite(['Z:\user\mhelm1\Nanomap_Analysis\Analysis\HomerCorrelations\' folders{j} '_' classes{k} '.txt'],vals);
%             vals=sortrows(vals);
%             results(1:size(vals,1),j*k*3-2:j*k*3)=vals;
%             VarNames(end+1:end+3)={[folders{j} '_' classes{k} '_homer'],[folders{j} '_' classes{k} '_dio'],[folders{j} '_' classes{k} '_sted']};
%             %         fit a linear regression to the values
%             p=polyfit(vals(:,1),vals(:,3),1);
%             yfit=polyval(p,vals(:,1));
%             yresid=vals(:,3)-yfit;
%             SSresid=sum(yresid.^2);
%             SStotal=length(vals(:,3)-1)*var(vals(:,3));
%             rsq=1-SSresid/SStotal;
%             HomerSTEDCorr{j,k*4-3}=[folders{j} '_' classes{k}];
%             HomerSTEDCorr{j,k*4-2}=p(1); %slope
%             HomerSTEDCorr{j,k*4-1}=p(2); %intercept
%             HomerSTEDCorr{j,k*4}=rsq; %R²
        end
    end
%     VarNames=matlab.lang.makeValidName(VarNames);
%     results=array2table(results,'VariableNames',VarNames);
%     writetable(results,[cd_path filesep 'CorrelationHomerSTED.xlsx'],'Sheet','data');
%     
% %     Calculate the mean for each sted signal, which will serve as the
% %     normalizer to calculate the protein copy number per synapse.
%     VarNamesSTED=VarNames(contains(VarNames,'sted'));
%     results_sted=results(:,VarNamesSTED);
%     results_sted=table2array(results_sted);
%     results_sted=nanmean(results_sted);
%     results_sted=reshape(results_sted,3,[]);
%     results_sted=results_sted';
%     VarNamesSTED=VarNamesSTED(1:3:end);
%     VarNamesSTED=cellfun(@(x) x(1:end-10),VarNamesSTED,'UniformOutput',0);
%     results_sted=array2table(results_sted,'VariableNames',{'MeanSTEDIntensity_Mush','MeanSTEDIntensity_Stubby','MeanSTEDIntensity_Other'},'RowNames',VarNamesSTED);
%     writetable(results_sted,[cd_path filesep 'CorrelationHomerSTED.xlsx'],'Sheet','MeanSTEDSignal','WriteRowNames',1);
%     
%     writetable(cell2table(HomerSTEDCorr,'VariableNames',{'Protein_Mush','Slope_Mush','Intercept_Mush','Rsquared_Mush','Protein_Stubby','Slope_Stubby','Intercept_Stubby','Rsquared_Stubby','Protein_Other','Slope_Other','Intercept_Other','Rsquared_Other'}),[cd_path filesep 'CorrelationHomerSTED.xlsx'],'Sheet','fits');
    close(w)
end

if showFigures
    if ~calcCorrs
        results=readtable([cd_path filesep 'CorrelationHomerSTED.xlsx'],'Sheet','data');
        HomerSTEDCorr=readtable([cd_path filesep 'CorrelationHomerSTED.xlsx'],'Sheet','fits');
    end
    %     remove the protein name entry
    HomerSTEDCorr(:,1)=[];
    HomerSTEDCorr=table2array(HomerSTEDCorr);
    results=table2array(results);
    for j=1:numel(folders)
        for k=1:numel(classes)
            figure
            x=results(:,j*k*3-2);
            x(isnan(x))=[];
            y=results(:,j*k*3);
            y(isnan(y))=[];
            scatter(x,y);
            p=HomerSTEDCorr(j,:);
            hold on
            fplot(@(x) p(1)*x+p(2),[min(x), max(x)],'r')
            title([folders{j} '_' classes{k} '_R2=' num2str(p(3))]);
            hold off
        end
    end
end
end