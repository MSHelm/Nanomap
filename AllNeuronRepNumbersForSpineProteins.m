function AllNeuronRepNumbersForSpineProteins

spine_prots=readtable('Z:\user\mhelm1\Subcellular Distribution Analysis\THE COPY NUMBER FILE_SE0.xlsx','Sheet','Tabelle1');
spine_prots=spine_prots.UniprotID;
spine_prots(find(strcmp(spine_prots,'toast')))=[];

neuron_prots=readtable('Z:\user\mhelm1\Subcellular Distribution Analysis\270219_revised_SwissProt_ids_copy number.xlsx','Sheet','combined');
results=nan(numel(spine_prots),8);

neuron_nums=neuron_prots(:,{'BR1_highph','BR2_highph','BR3_highph','BR4_highph','BR1_max_normalized','BR2_max_normalized','BR3_max_normalized','BR4_max_normalized'});
neuron_nums=table2array(neuron_nums);

for i=1:numel(spine_prots)
    prot_idx=find(strcmp(neuron_prots.GeneName_,spine_prots{i}));
    rep_idx=find(neuron_nums(prot_idx,:),1,'first');
    if isempty(rep_idx)
        continue
    end
    
    if nansum(neuron_nums(prot_idx,1:4))>0
        results(i,1:4)=neuron_nums(prot_idx,1:4);
    elseif nansum(neuron_nums(prot_idx,5:8))>0
        results(i,1:4)=neuron_nums(prot_idx,5:8);
    end 
end
    
results(:,5)=nanmean(results(:,1:4),2);
results(:,6)=nanstd(results(:,1:4),[],2);
results(:,7)=results(:,6)./sqrt(sum(~isnan(results(:,1:4)),2));
results(:,8)=results(:,6)./results(:,5);
results=array2table(results,'VariableNames',{'Rep1','Rep2','Rep3','Rep4','Mean','SD','SEM','CV'},'RowNames',spine_prots);
writetable(results,'Z:\user\mhelm1\Subcellular Distribution Analysis\THE COPY NUMBER FILE_SE0.xlsx','Sheet','NeuronCopyNums','WriteRowNames',1,'WriteVariableNames',1);

end