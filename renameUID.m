function renameUID

[~,~,UID_id]=xlsread('Z:\user\mhelm1\Subcellular Distribution Analysis\CopyNumbers_iBAQ_highPH_combined.xlsx','List old UID new gene names');
UID_id=UID_id(1:98,8:9);

reps={'Z:\user\mhelm1\Subcellular Distribution Analysis\Replicate1','Z:\user\mhelm1\Subcellular Distribution Analysis\Replicate2'};
% reps={'Z:\user\mhelm1\toast'};
for j=1:numel(reps)
cd(reps{j})
folders=dir;
folders([folders.isdir]==0)=[];
folders={folders.name};

for i=3:numel(folders)
    
      %extract uniprot ID from folder name
    expression='(?<=UID-)[a-zA-Z0-9]*';
    old_UID=regexp(folders{i},expression,'match');
    old_UID=old_UID{1};
    
try
    idx=find(contains(UID_id(:,2),old_UID));
    if isempty(idx)
        continue
    end
    name=regexp(folders{i},'_','split');
    new_name=[name{1} '_UID-' UID_id{idx,1} '_' name{end}];
    
    system(['ren ' '"' reps{j} filesep folders{i} '"' ' ' new_name])
%     movefile(folders{i},new_name);
catch
    continue
end
end
end

    
