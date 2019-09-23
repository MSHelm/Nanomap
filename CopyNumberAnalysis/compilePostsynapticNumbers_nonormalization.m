function compilePostsynapticNumbers_nonormalization()

addpath(genpath('Z:\user\mhelm1\Subcellular Distribution Analysis\Matlab Programs'));
spinenumber=299;
%specify path to parent image data folder
the_folder='Z:\user\mhelm1\Subcellular Distribution Analysis\';
SE_erode=0;
cd(the_folder);

%Debugging variables
%second_extend=2;

%read in protein copy number overview file for synaptosomal protein numbers
[synaptosome_data_num,synaptosome_data_txt,synaptosome_data]=xlsread('Z:\user\mhelm1\Subcellular Distribution Analysis\Protein copy number overview');
synaptosome_UID=synaptosome_data_txt(:,2);

%read in table with whole-cell results from Sunit. last parameter is the
%raw data, which includes both numeric and text data. I use the
%wholecell_UID to later find the correct row of the protein of interest and
%then get the value from wholecell raw data
[wholecell_num,wholecell_UID,wholecell]=xlsread('Z:\user\mhelm1\Subcellular Distribution Analysis\270219_revised_SwissProt_ids_copy number','combined');%,'L2:L4654');
wholecell_UID=wholecell_UID(:,15);

%Read in Colocalization values, Rsquared and  Ratio of synaptosomes to neurons from SE analysis
coloc_analysis_Rep1=load([the_folder 'Replicate1' filesep 'results_SE' num2str(SE_erode) '.mat']);
coloc_analysis_Rep1=coloc_analysis_Rep1.results;
coloc_UID_Rep1=coloc_analysis_Rep1.UniprotID;
coloc_analysis_Rep1=table2cell(coloc_analysis_Rep1);
% [coloc_analysis_num_Rep1,coloc_analysis_txt_Rep1,coloc_analysis_Rep1]=xlsread([the_folder 'Replicate1' filesep 'results_SE' num2str(SE_erode) '.xlsx']);
% coloc_UID_Rep1=coloc_analysis_txt_Rep1(:,2);

coloc_analysis_Rep2=load([the_folder 'Replicate2' filesep 'results_SE' num2str(SE_erode) '.mat']);
coloc_analysis_Rep2=coloc_analysis_Rep2.results;
coloc_UID_Rep2=coloc_analysis_Rep2.UniprotID;
coloc_analysis_Rep2=table2cell(coloc_analysis_Rep2);
% [coloc_analysis_num_Rep2,coloc_analysis_txt_Rep2,coloc_analysis_Rep2]=xlsread([the_folder 'Replicate2' filesep 'results_SE' num2str(SE_erode) '.xlsx']);
% coloc_UID_Rep2=coloc_analysis_txt_Rep2(:,2);

%Read in STEDCorrelation file
tmp=load('Z:\user\mhelm1\Nanomap_Analysis\Data\total\STEDCorrelations.mat');
STEDCorr=tmp.results;
STEDCorr=table2cell(STEDCorr);
STEDCorr_UID=STEDCorr(:,1);

% Read in spine type correction file
tmp=load('Z:\user\mhelm1\Nanomap_Analysis\Data\total\SpineTypeCorrection_nonormalization.mat');
type_corr_raw=tmp.results;
type_corr_UID=type_corr_raw.UID;
type_corr_num=cat(2,type_corr_raw.Corrected_Mush, type_corr_raw.Corrected_Flat, type_corr_raw.Corrected_Other);
type_corr_num=type_corr_num/100;%Change it from percentages to factors.
%
% [type_corr_num,type_corr_txt,type_corr_raw]=xlsread('Z:\user\mhelm1\Nanomap_Analysis\Data\total\SpineTypeCorrection.xlsx');
% type_corr_UID=type_corr_txt(:,2);
% type_corr_num=type_corr_num/100; %Change it from percentages to factors.

% Give volumes of the two spine types, in µm³  == femtoliter
vol_mush=0.198125;
vol_flat=0.30975;

% bring volumes to liters.
vol_mush=vol_mush*1E-15;
vol_flat=vol_flat*1E-15;

% Define Avogadros Numbers
NA=6.0221409e+23;

%generate results cell with headers
results={};
results{1,1}='Foldername';
results{1,end+1}='Uniprot ID';
results{1,end+1}='whole-cell copynumber';
results{1,end+1}='whole-cell copynumber SEM';
results{1,end+1}='colocalization ratio Rep1'; col_ratio_Rep1_indx=size(results,2);
results{1,end+1}='colocalization ratio SEM Rep1'; col_ratio_SEM_Rep1_indx=size(results,2);
results{1,end+1}='colocalization ratio Rep2'; col_ratio_Rep2_indx=size(results,2);
results{1,end+1}='colocalization ratio SEM Rep2'; col_ratio_SEM_Rep2_indx=size(results,2);
results{1,end+1}='Mean colocalization ratio';  col_ratio_mean_indx=size(results,2);
results{1,end+1}='Mean colocalization ratio SEM'; col_ratio_SEM_mean_indx=size(results,2);
% results{1,end+1}='R2 Replicate1'; R2_Rep1_indx=size(results,2);
% results{1,end+1}='R2 Replicate1 SEM'; R2_SEM_Rep1_indx=size(results,2);
% results{1,end+1}='R2 Replicate2'; R2_Rep2_indx=size(results,2);
% results{1,end+1}='R2 Replicate2 SEM'; R2_SEM_Rep2_indx=size(results,2);
results{1,end+1}='STEDCorr'; STEDCorr_indx=size(results,2);
results{1,end+1}='STEDCorr SEM'; STEDCorr_SEM_indx=size(results,2);
results{1,end+1}='Fold More in Spine'; FoldSpine_indx=size(results,2);
results{1,end+1}='synaptic copy number from colocalization with Homer1'; copynum_from_Homer_indx=size(results,2);
results{1,end+1}='synaptic copy number from colocalization with Homer1 SEM'; copynum_from_Homer_SEM_indx=size(results,2);
results{1,end+1}='inneurons&insynaptosomes Rep1'; ratio_neurons_synaptosomes_Rep1_indx=size(results,2);
results{1,end+1}='inneurons&insynaptosomes SEM Rep1'; ratio_neurons_synaptosomes_SEM_Rep1_indx=size(results,2);
results{1,end+1}='inneurons&insynaptosomes Rep2'; ratio_neurons_synaptosomes_Rep2_indx=size(results,2);
results{1,end+1}='inneurons&insynaptosomes SEM Rep2'; ratio_neurons_synaptosomes_SEM_Rep2_indx=size(results,2);
results{1,end+1}='mean inneurons&insynaptosomes'; ratio_neurons_synaptosomes_mean_indx=size(results,2);
results{1,end+1}='mean inneurons&insynaptosomes SEM'; ratio_neurons_synaptosomes_SEM_mean_indx=size(results,2);
results{1,end+1}='synaptic copy number (type uncorrected) from synaptosome data'; copynum_from_synaptosomes_indx=size(results,2);
results{1,end+1}='synaptic copy number (type uncorrected) from synaptosome data SEM'; copynum_from_synaptosomes_SEM_indx=size(results,2);
results{1,end+1}='synaptic copy number Mushroom type from synaptosome data'; copynum_mush_indx=size(results,2);
results{1,end+1}='synaptic copy number Mushroom type from synaptosome data SEM'; copynum_mush_SEM_indx=size(results,2);
results{1,end+1}='synaptic copy number Flat type from synaptosome data'; copynum_flat_indx=size(results,2);
results{1,end+1}='synaptic copy number Flat type from synaptosome data SEM';copynum_flat_SEM_indx=size(results,2);
results{1,end+1}='spine copy number'; spinecopy_indx=size(results,2);
results{1,end+1}='spine copy number SEM'; spinecopy_SEM_indx=size(results,2);
results{1,end+1}='mushroom spine copy number'; mush_spinecopy_indx=size(results,2);
results{1,end+1}='mushroom spine copy number SEM'; mush_spinecopy_SEM_indx=size(results,2);
results{1,end+1}='flat spine copy number'; flat_spinecopy_indx=size(results,2);
results{1,end+1}='flat spine copy number SEM'; flat_spinecopy_SEM_indx=size(results,2);
results{1,end+1}='other spine copy number'; other_spinecopy_indx=size(results,2);
results{1,end+1}='other spine copy number SEM'; other_spinecopy_SEM_indx=size(results,2);
results{1,end+1}='Molecular Weight'; mol_weight_indx=size(results,2);
results{1,end+1}='Mushroom protein amount'; prot_mush_indx=size(results,2);
results{1,end+1}='Mushroom protein amount SEM'; prot_mush_SEM_indx=size(results,2);
results{1,end+1}='Flat protein amount'; prot_flat_indx=size(results,2);
results{1,end+1}='Flat protein amount SEM'; prot_flat_SEM_indx=size(results,2);
results{1,end+1}='Mushroom percentage protein'; mush_perc_prot_indx=size(results,2);
results{1,end+1}='Mushroom percentage protein SEM'; mush_perc_prot_SEM_indx=size(results,2);
results{1,end+1}='Flat percentage protein'; flat_perc_prot_indx=size(results,2);
results{1,end+1}='Flat percentage protein SEM'; flat_perc_prot_SEM_indx=size(results,2);
results{1,end+1}='Synapse Molarity'; syn_molar_indx=size(results,2);
results{1,end+1}='Synapse Molarity SEM'; syn_molar_SEM_indx=size(results,2);
results{1,end+1}='Mushroom Molarity'; mush_molar_indx=size(results,2);
results{1,end+1}='Mushroom Molarity SEM'; mush_molar_SEM_indx=size(results,2);
results{1,end+1}='Flat Molarity'; flat_molar_indx=size(results,2);
results{1,end+1}='Flat Molarity SEM'; flat_molar_SEM_indx=size(results,2);
results{1,end+1}='Mushroom Volume'; mush_vol_indx=size(results,2);
results{1,end+1}='Mushroom Volume SEM'; mush_vol_SEM_indx=size(results,2);
results{1,end+1}='Flat Volume'; flat_vol_indx=size(results,2);
results{1,end+1}='Flat Volume SEM'; flat_vol_SEM_indx=size(results,2);
results{1,end+1}='Mushroom PSD Concentration'; mush_psd_conc_indx=size(results,2);
results{1,end+1}='Mushroom PSD Concentration SEM'; mush_psd_conc_SEM_indx=size(results,2);
results{1,end+1}='Flat PSD Concentration'; flat_psd_conc_indx=size(results,2);
results{1,end+1}='Flat PSD Concentration SEM'; flat_psd_conc_SEM_indx=size(results,2);




cd Replicate1\
%look for all the subfolder names
files=[];
files=dir;
folders={};
for i=3:numel(files)
    if files(i).isdir
        folders{numel(folders)+1}=files(i).name;
    end
end

for i=1:numel(folders)
    use_synaptosome_data=0;
    str=folders{i};
    results{i+1,1}=str;
    %extract uniprot ID from folder name
    expression='(?<=UID-)[a-zA-Z0-9]*';
    UID=regexp(str,expression,'match');
    UID=UID{1};
    results{i+1,2}=UID;
    
    %determine in which row the data is in both excel sheets
    row_wholecell=find(strcmp(wholecell_UID,UID));
    if isempty(row_wholecell)==0
        results{i+1,3}=wholecell{row_wholecell,25}; %whole cell copynumber
        %         check for SEM, because copynumbers with only 1 detection dont
        %         have an SEM.
        if isfloat(wholecell{row_wholecell,27})
            results{i+1,4}=wholecell{row_wholecell,27}; %whole cell copynumber SEM
        else
            results{i+1,4}=NaN;
        end
        
    else
        row_SynData=find(strcmp(synaptosome_UID,UID));
        if isfloat(synaptosome_data{row_SynData,5})
            use_synaptosome_data=1;
        else
            results{i+1,3}=0;
            results{i+1,4}=0;
        end
    end
    
    
    
    %find colocalization and R2 in Rep1
    row_coloc=find(strcmp(coloc_UID_Rep1,UID));
    if isempty(row_coloc)==0
        results{i+1,col_ratio_Rep1_indx}=coloc_analysis_Rep1{row_coloc,5}; %colocalization in percent
        results{i+1,col_ratio_SEM_Rep1_indx}=coloc_analysis_Rep1{row_coloc,6}; %colocalization SEM
        %         results{i+1,R2_Rep1_indx}=coloc_analysis_Rep1{row_coloc,7}; %R2
        %         results{i+1,R2_SEM_Rep1_indx}=coloc_analysis_Rep1{row_coloc,8}; %R2 SEM
    else
        results{i+1,col_ratio_Rep1_indx}=NaN;
        results{i+1,col_ratio_SEM_Rep1_indx}=NaN;
        %         results{i+1,R2_Rep1_indx}=NaN;
        %         results{i+1,R2_SEM_Rep1_indx}=NaN;
    end
    
    
    %find STEDCorr
    row_STEDCorr=find(strcmp(STEDCorr_UID,UID));
    if isempty(row_STEDCorr)==0
        results{i+1,STEDCorr_indx}=STEDCorr{row_STEDCorr,5};
        results{i+1,STEDCorr_SEM_indx}=STEDCorr{row_STEDCorr,6};
        results{i+1,FoldSpine_indx}=STEDCorr{row_STEDCorr,4};
    else
        results{i+1,STEDCorr_indx}=NaN;
        results{i+1,STEDCorr_SEM_indx}=NaN;
        results{i+1,FoldSpine_indx}=NaN;
    end
    
    
    
    %Check if second Replicate is already done.
    %If yes get the numbers, if not continue with calculations.
    try
        row_coloc_Rep2=find(strcmp(coloc_UID_Rep2,UID));
        if isempty(row_coloc_Rep2)==0
            results{i+1,col_ratio_Rep2_indx}=coloc_analysis_Rep2{row_coloc_Rep2,5}; %colocalization in percent
            results{i+1,col_ratio_SEM_Rep2_indx}=coloc_analysis_Rep2{row_coloc_Rep2,6}; %colocalization SEM
            %             results{i+1,R2_Rep2_indx}=coloc_analysis_Rep2{row_coloc_Rep2,7}; %R2
            %             results{i+1,R2_SEM_Rep2_indx}=coloc_analysis_Rep2{row_coloc_Rep2,8}; %R2 SEM
        else
            results{i+1,col_ratio_Rep2_indx}=NaN;
            results{i+1,col_ratio_SEM_Rep2_indx}=NaN;
            %             results{i+1,R2_Rep2_indx}=NaN;
            %             results{i+1,R2_SEM_Rep2_indx}=NaN;
        end
    catch
    end
    
    %Calculate the Mean of colocalization, R2 and their SEMs
    results{i+1,col_ratio_mean_indx}=nanmean([results{i+1,col_ratio_Rep1_indx},results{i+1,col_ratio_Rep2_indx}]);
    results{i+1,col_ratio_SEM_mean_indx}=nanmean([results{i+1,col_ratio_SEM_Rep1_indx},results{i+1,col_ratio_SEM_Rep2_indx}]);
    %     results{i+1,STEDCorr_indx}=nanmean([results{i+1,R2_Rep1_indx},results{i+1,R2_Rep2_indx}]);
    %     results{i+1,STEDCorr_SEM_indx}=nanmean([results{i+1,R2_SEM_Rep1_indx},results{i+1,R2_SEM_Rep2_indx}]);
    
    %calculate synaptic copy number from whole cell copy number
    %whole cell copy number * percentage in synapses * R squared / spine
    %number
    results{i+1,copynum_from_Homer_indx}=results{i+1,3}*results{i+1,col_ratio_mean_indx}*results{i+1,STEDCorr_indx}*0.01/spinenumber; %synaptic copy number
    results{i+1,copynum_from_Homer_SEM_indx}=results{i+1,copynum_from_Homer_indx}*sqrt((results{i+1,4}/results{i+1,3})^2+(results{i+1,col_ratio_SEM_mean_indx}/results{i+1,col_ratio_mean_indx})^2+(results{i+1,STEDCorr_SEM_indx}/results{i+1,STEDCorr_indx})^2); %synaptic copy number SEM
    
    %     Manually enter the two copy numbers that I get from other papers.
    if strcmp('P24062',UID) %IGF1R
        results{i+1,copynum_from_Homer_indx}=53.9278539703109;
    elseif strcmp('Q63053',UID) %Arc
        results{i+1,copynum_from_Homer_indx}=392.883758408924;
    end
    
    
    %Calculate synaptic copy numbers from synaptosome data
    %Synaptosome number * in neurons/in synaptosomes
    row_SynData=find(strcmp(synaptosome_UID,UID));
    if isempty(row_SynData)==0
        if isfloat(synaptosome_data{row_SynData,5})==1
            results{i+1,ratio_neurons_synaptosomes_Rep1_indx}=coloc_analysis_Rep1{row_coloc,3};
            results{i+1,ratio_neurons_synaptosomes_SEM_Rep1_indx}=coloc_analysis_Rep1{row_coloc,4};
            %check for Replicate2
            try
                results{i+1,ratio_neurons_synaptosomes_Rep2_indx}=coloc_analysis_Rep2{row_coloc_Rep2,3};
                results{i+1,ratio_neurons_synaptosomes_SEM_Rep2_indx}=coloc_analysis_Rep2{row_coloc_Rep2,4};
            catch
                results{i+1,ratio_neurons_synaptosomes_Rep2_indx}=NaN;
                results{i+1,ratio_neurons_synaptosomes_SEM_Rep2_indx}=NaN;
            end
        else
            %if no Rep1 analysis available, set it to NaN
            results{i+1,ratio_neurons_synaptosomes_Rep1_indx}=NaN;
            results{i+1,ratio_neurons_synaptosomes_SEM_Rep1_indx}=NaN;
        end
    else
        %if no synaptosome data available set both replicates to NaN
        results{i+1,ratio_neurons_synaptosomes_Rep1_indx}=NaN;
        results{i+1,ratio_neurons_synaptosomes_SEM_Rep1_indx}=NaN;
        results{i+1,ratio_neurons_synaptosomes_Rep2_indx}=NaN;
        results{i+1,ratio_neurons_synaptosomes_SEM_Rep2_indx}=NaN;
    end
    
    %calculate the mean of the ratios
    try
        results{i+1,ratio_neurons_synaptosomes_mean_indx}=nanmean([results{i+1,ratio_neurons_synaptosomes_Rep1_indx},results{i+1,ratio_neurons_synaptosomes_Rep2_indx}]);
        results{i+1,ratio_neurons_synaptosomes_SEM_mean_indx}=nanmean([results{i+1,ratio_neurons_synaptosomes_SEM_Rep1_indx},results{i+1,ratio_neurons_synaptosomes_SEM_Rep2_indx}]);
    catch
        results{i+1,ratio_neurons_synaptosomes_mean_indx}=NaN;
        results{i+1,ratio_neurons_synaptosomes_SEM_mean_indx}=NaN;
    end
    
    
    %calculate the copy number from synaptosome data
    try
        results{i+1,copynum_from_synaptosomes_indx}=synaptosome_data{row_SynData,5}*results{i+1,ratio_neurons_synaptosomes_mean_indx};
        results{i+1,copynum_from_synaptosomes_SEM_indx}=results{i+1,copynum_from_synaptosomes_indx}*results{i+1,ratio_neurons_synaptosomes_SEM_mean_indx};
    catch
        results{i+1,copynum_from_synaptosomes_indx}=NaN;
        results{i+1,copynum_from_synaptosomes_SEM_indx}=NaN;
    end
    
    
    
    
    %     If it is a protein with more than 4 transmembrane domains, or
    %     over 175kDa size, then use the average of Synaptosome and mass
    %     spectrometry.
    if sum(strcmp(UID,{'Shank1','Shank2','Shank3','Myo5a','Cacna1a','Sptbn2','Grin1','Grin2b','Gria1','Gria2','Gria3','P31421','Grm5','Ntrk2','Map2','Cltc'})) %The following proteins I would also list here, but where not detected by Benni: Grin2a, Grik1, Grm1, Drd1, Drd2, Igf1r, LNGFR, nAChR beta 2
        rel_SEM_homer=[];
        rel_SEM_syn=[];
        rel_SEM_homer=results{i+1,copynum_from_Homer_SEM_indx}/results{i+1,copynum_from_Homer_indx};
        rel_SEM_syn=results{i+1,copynum_from_synaptosomes_SEM_indx}/results{i+1,copynum_from_synaptosomes_indx};
        results{i+1,copynum_from_Homer_indx}=mean([results{i+1,copynum_from_synaptosomes_indx},results{i+1,copynum_from_Homer_indx}]);
        results{i+1,copynum_from_Homer_SEM_indx}=results{i+1,copynum_from_Homer_indx}*mean([rel_SEM_homer,rel_SEM_syn]);
    end
    
    
    
    %     Calculate type corrected synaptic copynumbers.
    %     determine in which row the corresponding type correction factor is
    row_type_corr=find(strcmp(type_corr_UID,UID));
    if ~isempty(row_type_corr)
        results{i+1,copynum_mush_indx}=results{i+1,copynum_from_Homer_indx}*type_corr_num(row_type_corr,1);
        results{i+1,copynum_mush_SEM_indx}=results{i+1,copynum_from_Homer_SEM_indx}*type_corr_num(row_type_corr,1);
        results{i+1,copynum_flat_indx}=results{i+1,copynum_from_Homer_indx}*type_corr_num(row_type_corr,2);
        results{i+1,copynum_flat_SEM_indx}=results{i+1,copynum_from_Homer_SEM_indx}*type_corr_num(row_type_corr,2);
    else
        [results{i+1,copynum_mush_indx}, results{i+1,copynum_mush_SEM_indx}, results{i+1,copynum_flat_indx}, results{i+1,copynum_flat_SEM_indx}]=deal(NaN);
    end
    
    %     Calculate spine copy numbers
    results{i+1,spinecopy_indx}=results{i+1,copynum_from_Homer_indx}+results{i+1,FoldSpine_indx}*results{i+1,copynum_from_Homer_indx};
    results{i+1,spinecopy_SEM_indx}=(results{i+1,copynum_from_Homer_SEM_indx}/results{i+1,copynum_from_Homer_indx})* results{i+1,spinecopy_indx};
    results{i+1,mush_spinecopy_indx}=results{i+1,spinecopy_indx}*type_corr_num(row_type_corr,1);
    results{i+1,mush_spinecopy_SEM_indx}=results{i+1,spinecopy_SEM_indx}*type_corr_num(row_type_corr,1);
    results{i+1,flat_spinecopy_indx}=results{i+1,spinecopy_indx}*type_corr_num(row_type_corr,2);
    results{i+1,flat_spinecopy_SEM_indx}=results{i+1,spinecopy_SEM_indx}*type_corr_num(row_type_corr,2);
    results{i+1,other_spinecopy_indx}=results{i+1,spinecopy_indx}*type_corr_num(row_type_corr,3);
    results{i+1,other_spinecopy_SEM_indx}=results{i+1,spinecopy_SEM_indx}*type_corr_num(row_type_corr,3);
    
    
    
    %If protein wasnt detected in MS file but is in synaptosome data then use
    %it.
    if use_synaptosome_data
        results{i+1,spinecopy_indx}=results{i+1,copynum_from_synaptosomes_indx};
        results{i+1,spinecopy_SEM_indx}=results{i+1,copynum_from_synaptosomes_SEM_indx};
        results{i+1,mush_spinecopy_indx}=results{i+1,spinecopy_indx}*type_corr_num(row_type_corr,1);
        results{i+1,mush_spinecopy_SEM_indx}=results{i+1,spinecopy_SEM_indx}*type_corr_num(row_type_corr,1);
        results{i+1,flat_spinecopy_indx}=results{i+1,spinecopy_indx}*type_corr_num(row_type_corr,2);
        results{i+1,flat_spinecopy_SEM_indx}=results{i+1,spinecopy_SEM_indx}*type_corr_num(row_type_corr,2);
                results{i+1,other_spinecopy_indx}=results{i+1,spinecopy_indx}*type_corr_num(row_type_corr,3);
        results{i+1,other_spinecopy_SEM_indx}=results{i+1,spinecopy_SEM_indx}*type_corr_num(row_type_corr,3);
        
        results{i+1,3}='Data from Synaptosomes used';
        results{i+1,copynum_from_Homer_indx}='Data from Synaptosomes used';
    end
    
    
%     %     If it is one of the problematic proteins then take the synaptosome
%     %     data
%     
%     if sum(strcmp(UID,{'Shank1','Shank2','Shank3'}))
%         results{i+1,spinecopy_indx}=results{i+1,copynum_from_synaptosomes_indx};
%         results{i+1,spinecopy_SEM_indx}=results{i+1,copynum_from_synaptosomes_SEM_indx};
%         results{i+1,mush_spinecopy_indx}=results{i+1,spinecopy_indx}*type_corr_num(row_type_corr,1);
%         results{i+1,mush_spinecopy_SEM_indx}=results{i+1,spinecopy_SEM_indx}*type_corr_num(row_type_corr,1);
%         results{i+1,flat_spinecopy_indx}=results{i+1,spinecopy_indx}*type_corr_num(row_type_corr,2);
%         results{i+1,flat_spinecopy_SEM_indx}=results{i+1,spinecopy_SEM_indx}*type_corr_num(row_type_corr,2);
%                 results{i+1,other_spinecopy_indx}=results{i+1,spinecopy_indx}*type_corr_num(row_type_corr,3);
%         results{i+1,other_spinecopy_SEM_indx}=results{i+1,spinecopy_SEM_indx}*type_corr_num(row_type_corr,3);
%         results{i+1,copynum_from_Homer_indx}='Data from Synaptosomes used';
%         
%     end
%     
    
    
    % Calculate protein amount of protein
    if ~isempty(row_wholecell) && ~isempty(results{i+1,mush_spinecopy_indx})
        results{i+1,mol_weight_indx}=wholecell{row_wholecell,4};
        results{i+1,prot_mush_indx}=results{i+1,mush_spinecopy_indx}/NA*results{i+1,mol_weight_indx};
        results{i+1,prot_mush_SEM_indx}=results{i+1,prot_mush_indx}*(results{i+1,mush_spinecopy_SEM_indx}/results{i+1,mush_spinecopy_indx});
        results{i+1,prot_flat_indx}=results{i+1,flat_spinecopy_indx}/NA*results{i+1,mol_weight_indx};
        results{i+1,prot_flat_SEM_indx}=results{i+1,prot_flat_indx}*(results{i+1,flat_spinecopy_SEM_indx}/results{i+1,flat_spinecopy_indx});
    end
    % Calculate protein molarity
    
    if ~isempty(results{i+1,mush_spinecopy_indx})
        % results{i+1,syn_molar_indx}=results{i+1,spinecopy_indx}/NA/vol_mush;
        % results{i+1,syn_molar_SEM_indx}=results{i+1,syn_molar_indx}*(results{i+1,spinecopy_SEM_indx}/results{i+1,spinecopy_indx});
        results{i+1,mush_molar_indx}=results{i+1,mush_spinecopy_indx}/NA/vol_mush;
        results{i+1,mush_molar_SEM_indx}=results{i+1,mush_molar_indx}*(results{i+1,mush_spinecopy_SEM_indx}/results{i+1,mush_spinecopy_indx});
        results{i+1,flat_molar_indx}=results{i+1,flat_spinecopy_indx}/NA/vol_flat;
        results{i+1,flat_molar_SEM_indx}=results{i+1,flat_molar_indx}*(results{i+1,flat_spinecopy_SEM_indx}/results{i+1,flat_spinecopy_indx});
        
        % Calculate percentage of occupied volume in spine. *1E-27 is conversion of cubic
        % angoström to l
        results{i+1,mush_vol_indx}=results{i+1,mush_spinecopy_indx}*synaptosome_data{row_SynData,41}*1E-27/vol_mush*100;
        results{i+1,mush_vol_SEM_indx}=results{i+1,mush_vol_indx}*(results{i+1,mush_spinecopy_SEM_indx}/results{i+1,mush_spinecopy_indx});
        results{i+1,flat_vol_indx}=results{i+1,flat_spinecopy_indx}*synaptosome_data{row_SynData,41}*1E-27/vol_flat*100;
        results{i+1,flat_vol_SEM_indx}=results{i+1,flat_vol_indx}*(results{i+1,flat_spinecopy_SEM_indx}/results{i+1,flat_spinecopy_indx});
    end
    
    
    
    
    
    
    %Compile The Copy number file!
    synaptosome_data{row_SynData,6}=results{i+1,ratio_neurons_synaptosomes_mean_indx};
    synaptosome_data{row_SynData,7}=results{i+1,copynum_from_synaptosomes_indx};
    synaptosome_data{row_SynData,8}=results{i+1,copynum_from_synaptosomes_SEM_indx};
    synaptosome_data{row_SynData,9} =results{i+1,3};
    synaptosome_data{row_SynData,10} = results{i+1,4};
    
    synaptosome_data{row_SynData,11}=results{i+1,col_ratio_mean_indx};
    
    %     if isempty(row_coloc)==0
    %         synaptosome_data{row_SynData,11}=coloc_analysis_Rep1{row_coloc,7};
    %     else
    %         synaptosome_data{row_SynData,11}=0;
    %     end
    synaptosome_data{row_SynData,12}=results{i+1,STEDCorr_indx};
    synaptosome_data{row_SynData,13}=results{i+1,FoldSpine_indx};
    synaptosome_data{row_SynData,14}=results{i+1,copynum_from_Homer_indx};
    synaptosome_data{row_SynData,15}=results{i+1,copynum_from_Homer_SEM_indx};
    synaptosome_data{row_SynData,16}=results{i+1,copynum_mush_indx};
    synaptosome_data{row_SynData,17}=results{i+1,copynum_mush_SEM_indx};
    synaptosome_data{row_SynData,18}=results{i+1,copynum_flat_indx};
    synaptosome_data{row_SynData,19}=results{i+1,copynum_flat_SEM_indx};
    synaptosome_data{row_SynData,20}=results{i+1,spinecopy_indx};
    synaptosome_data{row_SynData,21}=results{i+1,spinecopy_SEM_indx};
    synaptosome_data{row_SynData,22}=results{i+1,mush_spinecopy_indx};
    synaptosome_data{row_SynData,23}=results{i+1,mush_spinecopy_SEM_indx};
    synaptosome_data{row_SynData,24}=results{i+1,flat_spinecopy_indx};
    synaptosome_data{row_SynData,25}=results{i+1,flat_spinecopy_SEM_indx};
    synaptosome_data{row_SynData,26}=results{i+1,other_spinecopy_indx};
    synaptosome_data{row_SynData,27}=results{i+1,other_spinecopy_SEM_indx};
    synaptosome_data{row_SynData,28}=results{i+1,mol_weight_indx};
    synaptosome_data{row_SynData,29}=results{i+1,prot_mush_indx};
    synaptosome_data{row_SynData,30}=results{i+1,prot_mush_SEM_indx};
    synaptosome_data{row_SynData,31}=results{i+1,prot_flat_indx};
    synaptosome_data{row_SynData,32}=results{i+1,prot_flat_SEM_indx};
    %     synaptosome_data{row_SynData,35}=results{i+1,syn_molar_indx};
    %     synaptosome_data{row_SynData,36}=results{i+1,syn_molar_SEM_indx};
    synaptosome_data{row_SynData,37}=results{i+1,mush_molar_indx};
    synaptosome_data{row_SynData,38}=results{i+1,mush_molar_SEM_indx};
    synaptosome_data{row_SynData,39}=results{i+1,flat_molar_indx};
    synaptosome_data{row_SynData,40}=results{i+1,flat_molar_SEM_indx};
    synaptosome_data{row_SynData,42}=results{i+1,mush_vol_indx};
    synaptosome_data{row_SynData,43}=results{i+1,mush_vol_SEM_indx};
    synaptosome_data{row_SynData,44}=results{i+1,flat_vol_indx};
    synaptosome_data{row_SynData,45}=results{i+1,flat_vol_SEM_indx};
    
end


% Calculate percentage of synaptic protein. Need to do this in separate
% loop because I first need to calculate total protein.
total_prot_mush=[results{2:end,prot_mush_indx}];
total_prot_mush(total_prot_mush<0)=[];
total_prot_mush=nansum(total_prot_mush);
total_prot_flat=[results{2:end,prot_flat_indx}];
total_prot_flat(total_prot_flat<0)=[];
total_prot_flat=nansum(total_prot_flat);
for i=1:numel(folders)
    if ~isempty(results{i+1,prot_mush_indx})
        results{i+1,mush_perc_prot_indx}=results{i+1,prot_mush_indx}/total_prot_mush*100;
        results{i+1,mush_perc_prot_SEM_indx}=results{i+1,mush_perc_prot_indx}*(results{i+1,mush_spinecopy_SEM_indx}/results{i+1,mush_spinecopy_indx});
        results{i+1,flat_perc_prot_indx}=results{i+1,prot_flat_indx}/total_prot_flat*100;
        results{i+1,flat_perc_prot_SEM_indx}=results{i+1,flat_perc_prot_indx}*(results{i+1,flat_spinecopy_SEM_indx}/results{i+1,flat_spinecopy_indx});
        
        %extract uniprot ID from folder name
        expression='(?<=UID-)[a-zA-Z0-9]*';
        UID=regexp(folders{i},expression,'match');
        UID=UID{1};
        row_SynData=find(strcmp(synaptosome_UID,UID));
        synaptosome_data{row_SynData,33}=results{i+1,mush_perc_prot_indx};
        synaptosome_data{row_SynData,34}=results{i+1,mush_perc_prot_SEM_indx};
        synaptosome_data{row_SynData,35}=results{i+1,flat_perc_prot_indx};
        synaptosome_data{row_SynData,36}=results{i+1,flat_perc_prot_SEM_indx};
    end
end



cd(the_folder);
xlswrite(['SynapticCopynumbers_Extended_results_SE' num2str(SE_erode) '_nonormalization.xlsx'],results);
xlswrite(['THE COPY NUMBER FILE_SE' num2str(SE_erode) '_nonormalization.xlsx'],synaptosome_data);

end


