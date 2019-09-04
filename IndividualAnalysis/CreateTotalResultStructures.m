function CreateTotalResultStructures()

addpath(genpath('Z:\user\mhelm1\Nanomap_Analysis\Matlab'));

if ~exist('Z:\user\mhelm1\Nanomap_Analysis\Data\total','dir')
    mkdir('Z:\user\mhelm1\Nanomap_Analysis\Data\total');
end


%first go to Replicate2 folder to only check for proteins that I actually
%already did a second replicate
rep1='Z:\user\mhelm1\Nanomap_Analysis\Data\Replicate1';
rep2='Z:\user\mhelm1\Nanomap_Analysis\Data\Replicate2';
cd(rep2);

files=[];
files=dir;
folders={};
for i=3:numel(files)
    if files(i).isdir && isempty(regexp(files(i).name,'^[_]','once'))
        folders{numel(folders)+1}=files(i).name;
    end
end

%get a list of the proteins from replicate 1
cd(rep1);
files=[];
files=dir;
folders_rep1={};
for i=3:numel(files)
    if files(i).isdir
        folders_rep1{numel(folders_rep1)+1}=files(i).name;
    end
end

w=waitbar(0,'Creating averages...');

for i=1:numel(folders_rep1) 
tmp=regexp(folders_rep1{i},'(?<=UID-)[a-zA-Z0-9]*','match');
UIDs_rep1{i}=tmp{1};
end


for i=1:numel(folders)
    
    %extract uniprot ID from folder name
    str=folders{i};
    expression='(?<=UID-)[a-zA-Z0-9]*';
    UID=regexp(str,expression,'match');
    UID=UID{1};
    
    %determine protein name
    exp2='\S*(?=_UID)';
    proteinname=regexp(str,exp2,'match');
    proteinname=proteinname{:};
    
    waitbar(i/numel(folders),w,['Currently calculating ' proteinname]);
    
%     try
        dir_rep1=find(contains(UIDs_rep1,UID));
        cd([rep2 filesep folders{i}]);
        
        load([rep1 filesep folders_rep1{dir_rep1} filesep folders_rep1{dir_rep1} '_SpotAnalysis.mat']);
        results_rep1=results;
        clear results
        load([folders{i} '_SpotAnalysis.mat']);
        results_rep2=results;
        clear results
        %         results_total=[results_rep1, results_rep2];
        fields=fieldnames(results_rep1);
        for k=1:numel(fields)
            results_total.(fields{k})=cat(2,results_rep1.(fields{k}),results_rep2.(fields{k}));
        end
        save(['Z:\user\mhelm1\Nanomap_Analysis\Data\total\' proteinname '_UID-' UID filesep 'SpotAnalysis_total.mat'],'results_total');
        clear results_total
%     catch
%         disp(['Error in ' proteinname])
%     end
end

close(w)

end