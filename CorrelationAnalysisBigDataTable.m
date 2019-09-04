function CorrelationAnalysisBigDataTable(FDR)

PrepareBigDataTable;
PreparePolishedMatFile;
DoCorrelations(FDR);
FullDatasetAnalysis;


    function PrepareBigDataTable
        % Read in the big table file with only the information on my proteins
        bigTable=readtable('Z:\user\mhelm1\Nanomap_Analysis\Analysis\big_data_comparison\FINAL_BIG_TABLE_SILVIO_sorted.xlsx','ReadRowNames',1,'ReadVariableNames',1,'Sheet','data from Martin');
        
        % Read in copy number table
        copynumTable=readtable('Z:\user\mhelm1\Subcellular Distribution Analysis\THE COPY NUMBER FILE_SE0.xlsx','ReadRowNames',1,'ReadVariableNames',1,'Sheet','Tabelle1');
        % Read in Enrichment tables
        PSDEnrichTableMush=load('Z:\user\mhelm1\Nanomap_Analysis\Data\total\EnrichmentAnalysisAverages_mush.mat');
        PSDEnrichTableMush=PSDEnrichTableMush.results_mush;
        
        PSDEnrichTableStubby=load('Z:\user\mhelm1\Nanomap_Analysis\Data\total\EnrichmentAnalysisAverages_flat.mat');
        PSDEnrichTableStubby=PSDEnrichTableStubby.results_flat;
        
        % Read in ZoneEnrichment tables
        ZoneEnrichTableMush=load('Z:\user\mhelm1\Nanomap_Analysis\Data\total\ProteinZoneEnrichment_mush_FoldOverAvg.mat');
        ZoneEnrichTableMush=ZoneEnrichTableMush.T_mush_foldoveravg;
        
        ZoneEnrichTableStubby=load('Z:\user\mhelm1\Nanomap_Analysis\Data\total\ProteinZoneEnrichment_flat_FoldOverAvg.mat');
        ZoneEnrichTableStubby=ZoneEnrichTableStubby.T_flat_foldoveravg;
        
        
        for i=1:size(bigTable,1)
            UID=bigTable.Gene_Names_3(i);
            UID=UID{:};
            
            %     Get the copynumbers from the copynumber table
            idx=[];
            idx=find(strcmp(copynumTable.UniprotID,UID));
            bigTable.wholeCellCopyNumber(i)=copynumTable.whole_cellCopynumber(idx);
            bigTable.spineCopyNumber(i)=copynumTable.spineCopyNumber(idx);
            bigTable.synapseCopyNumber(i)=copynumTable.synapticCopyNumberFromColocalizationWithHomer1(idx);
            
            %     Get the enrichment in PSD
            idx=[];
            idx=find(strcmp(PSDEnrichTableMush.UID,UID));
            bigTable.MushEnrichmentInHeadWithoutBackgroundCorrection(i)=PSDEnrichTableMush.EnrichmentPSDWithoutBackgroundCorrection(idx);
            bigTable.MushEnrichmentInHeadWithBackgroundCorrection(i)=PSDEnrichTableMush.EnrichmentPSDWithBackgroundCorrection(idx);
            bigTable.StubbyEnrichmentInHeadWithoutBackgroundCorrection(i)=PSDEnrichTableStubby.EnrichmentPSDWithoutBackgroundCorrection(idx);
            bigTable.StubbyEnrichmentInHeadWithBackgroundCorrection(i)=PSDEnrichTableStubby.EnrichmentPSDWithBackgroundCorrection(idx);
            
            
            %     Get the Zone Enrichment
            ZoneIdx=find(strcmp(bigTable.Properties.VariableNames,'MushroomZoneEnrichmentFoldOverAverage'));
            idx=find(strcmp(ZoneEnrichTableMush.Row,UID));
            bigTable{i,ZoneIdx+1:ZoneIdx+15}=ZoneEnrichTableMush{idx,1:15};
            
            ZoneIdx=find(strcmp(bigTable.Properties.VariableNames,'FlatZoneEnrichmentFoldOverAverage'));
            idx=find(strcmp(ZoneEnrichTableStubby.Row,UID));
            bigTable{i,ZoneIdx+1:ZoneIdx+11}=ZoneEnrichTableStubby{idx,1:11};
        end
        
        save('Z:\user\mhelm1\Nanomap_Analysis\Analysis\big_data_comparison\FinalBigTableSilviosortedMartinData.mat','bigTable');
        writetable(bigTable,'Z:\user\mhelm1\Nanomap_Analysis\Analysis\big_data_comparison\FinalBigTableSilviosortedMartinData.xlsx','WriteRowNames',1,'WriteVariableNames',1,'Sheet','data');
        
        addpath(genpath('Z:\user\mhelm1\Nanomap_Analysis\Matlab\IndividualAnalysis'));
        VarNames=bigTable.Properties.VariableNames;
        oldVarsStart=find(strcmp(VarNames,'EE_hom'));
        oldVarsEnd=find(strcmp(VarNames,'lifetimeAgedCerebellumSynVes'));
        oldVars=VarNames(oldVarsStart:oldVarsEnd);
        
        newVarsStart=find(strcmp(VarNames,'wholeCellCopyNumber'));
        newVarsEnd=find(strcmp(VarNames,'FlatZone11'));
        newVars=VarNames(newVarsStart:newVarsEnd);
        VarNamesUsed=padcatcell(oldVars,newVars);
        VarNamesUsed=cell2table(VarNamesUsed','VariableNames',{'OldVariableNames','NewVariableNames'});
        writetable(VarNamesUsed,'Z:\user\mhelm1\Nanomap_Analysis\Analysis\big_data_comparison\FinalBigTableSilviosortedMartinData.xlsx','Sheet','headers','WriteVariableNames',1)
        clear VarNamesUsed
    end

    function PreparePolishedMatFile
        cd 'Z:\user\mhelm1\Nanomap_Analysis\Analysis\big_data_comparison'
        [old, ~]=xlsread('FinalBigTableSilviosortedMartinData.xlsx','data','F2:ACP125');
        [order, ~]=xlsread('FinalBigTableSilviosortedMartinData.xlsx','data','ACQ2:ACQ125');
        [new, ~]=xlsread('FinalBigTableSilviosortedMartinData.xlsx','data','ACT2:AEC125');
        
        old2=[]; new2=[];order2=[];
        
        for i=1:max(order);
            i
            ccc=find(order==i);
            oldx=old(ccc,:);
            newx=new(ccc,:);
            if numel(ccc)>1
                size1=size(oldx);
                pp=mean(oldx); pp(1:numel(pp))=0;
                for j=1:size1(2); prp=oldx(:,j); cccx=find(prp>0); pp(j)=mean(prp(cccx)); end;
                old2=cat(1,old2,pp);
                size1=size(newx);
                pp=mean(newx); pp(1:numel(pp))=0;
                for j=1:size1(2); prp=newx(:,j); cccx=find(prp>-10000000); pp(j)=mean(prp(cccx)); end;
                new2=cat(1,new2,pp);
            else
                old2=cat(1,old2,oldx);
                new2=cat(1,new2,newx);
            end
            
            order2(i)=mean(order(ccc));
        end
        old=old2;new=new2; order=order2;
        VarNamesUsed=readtable('FinalBigTableSilviosortedMartinData.xlsx','Sheet','headers');
        namesold=VarNamesUsed.OldVariableNames;
        namesnew=VarNamesUsed.NewVariableNames;
        namesnew(cellfun('isempty',namesnew))=[];
        save('polished.mat','old','new','order','namesold','namesnew');
        
    end

    function DoCorrelations(FDR)
        
        cd 'Z:\user\mhelm1\Nanomap_Analysis\Analysis\big_data_comparison'
        close all
        
        load polished.mat;
        rr=zeros(765,37);pp=zeros(765,37);nn=zeros(765,37);
        
        for i=1:765;
            i
            for j=1:36
                old1=old(:,i); new1=new(:,j); %new1=new1-min(new1)+1;   new1=new1/median(new1); new1=log10(new1);
                ccc=find(old1>=0 & new1>-1000);
                
                [h,p]=corrcoef((old1(ccc)),new1(ccc));
                try
                    rr(i,j)=h(2);
                    pp(i,j)=p(2);
                    nn(i,j)=numel(ccc);
                catch; end
            end
        end
        
        dlmwrite('nn.txt',nn);
        dlmwrite('pp.txt',pp);
        dlmwrite('rr.txt',rr);
        
        ccc=find(nn<10); pp(ccc)=1;
        ccc=find(nn>10 & pp<1);
        numel(ccc)
        pp2=pp(ccc);
        pp2=sort(pp2);
        order=[1:1:numel(pp2)]; order=order/numel(pp2); order=order*FDR;
        cccpp=find(pp2<order');
        if numel(cccpp)>0
            cccx=find(pp<=pp2(max(cccpp)));
            
            siz=size(pp);
            [xx yy]=ind2sub([siz(1) siz(2)],cccx);
            
            cella={};
            for i=1:numel(xx)
                cella{i,1}=namesold{xx(i)};
                cella{i,2}=namesnew{yy(i)};
                cella{i,3}=pp(cccx(i));
                cella{i,4}=xx(i);
                cella{i,5}=yy(i);
            end
            xlswrite(['CorrelationResult_FDR' num2str(FDR*100) '.xlsx'],cella);
        end
        
    end

    function FullDatasetAnalysis
        % Read in the big table file, this time with all information
        bigTable=readtable('Z:\user\mhelm1\Nanomap_Analysis\Analysis\big_data_comparison\FINAL_BIG_TABLE_SILVIO_sorted.xlsx','ReadRowNames',1,'ReadVariableNames',1,'Sheet','big table');
        
        % Read in the my whole-cell proteome file
        copynums=readtable('Z:\user\mhelm1\Subcellular Distribution Analysis\270219_revised_SwissProt_ids_copy number.xlsx','Sheet','combined','ReadVariableNames',1);
        
        results=cell2table(cell(0,6),'VariableNames',{'GeneName','wholecell_copynumber','iBAQ_average','Kim_mRNA_fetal_brain', 'Kim_mRNA_Adult_Frontal_Cortex', 'Kim_Prot_Adult_Frontal_Cortex'});
        
        k=1;
        
        warning('Off','MATLAB:table:RowsAddedExistingVars');
        for i=1:size(copynums,1)
            gene=char(copynums.GeneName_(i));
            %             If no gene name is present continue
            if isempty(gene)
                continue
            end
            
            idx=find(strcmp(bigTable.Gene_Names,gene));
            %             If the protein is not present in the big data table then skip
            %             it
            if isempty(idx) || numel(idx)>1
                continue
            end
            
            results.GeneName{k}=gene;
            results.wholecell_copynumber(k)=copynums.Mean(i);
            results.iBAQ_average(k)=bigTable.Average(idx);
            results.Kim_mRNA_fetal_brain(k)=bigTable.KimMRNAFetalBrain(idx);
            results.Kim_mRNA_Adult_Frontal_Cortex(k)=bigTable.KimMRNAAdultFrontalCortex(idx);
            results.Kim_Prot_Adult_Frontal_Cortex(k)=bigTable.KimProtAdultFrontalCortex(idx);
            
            k=k+1;
        end
        warning('On','MATLAB:table:RowsAddedExistingVars');
        results=standardizeMissing(results,[NaN,Inf,0,-1]);
        save('Z:\user\mhelm1\Nanomap_Analysis\Analysis\big_data_comparison\FullDatasetCorrelation.mat','results');
        writetable(results,'Z:\user\mhelm1\Nanomap_Analysis\Analysis\big_data_comparison\FullDatasetCorrelation.xlsx','WriteVariableNames',1);
    end


end
