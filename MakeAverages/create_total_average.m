function create_total_average
addpath(genpath('Z:\user\mhelm1\Nanomap_Analysis\Matlab'));

if ~exist('Z:\user\mhelm1\Nanomap_Analysis\Data\total','dir')
    mkdir('Z:\user\mhelm1\Nanomap_Analysis\Data\total');
end

clear class* avg dir* files folders img_* names* sd sem

classes={'Mush', 'Flat', 'Other'}; %Order is important so that it follows the classification numbering!!!
channels={'dio','homer','sted'};
avg_type={'_150px_myfilt','_150px_mydiofilt_nostedfilt','_150px_nodiofilt_nostedfilt'};%'_150px_myfilt','_150px_myfilt_nostedfilt','_150px_nodiofilt_nostedfilt'}; %
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
    if files(i).isdir && isempty(regexp(files(i).name,'^[_]','once'))
        folders_rep1{numel(folders_rep1)+1}=files(i).name;
    end
end

w=waitbar(0,'Creating averages...');

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
    
    UID_rep1=cellfun(@(x)regexp(x,expression,'match'),folders_rep1);
    
    try
        dir_rep1=find(contains(UID_rep1,UID));
        
        cd(rep2);
        cd(folders{i});
        for l=1:numel(avg_type)
            if  exist(['Mush_dio_average' avg_type{l} '.txt'])==0
                disp([proteinname ' was not yet analyzed. Skipping it'])
                continue
            else
                if ~exist(['Z:\user\mhelm1\Nanomap_Analysis\Data\total\' proteinname '_UID-' UID],'dir')
                    mkdir(['Z:\user\mhelm1\Nanomap_Analysis\Data\total\' proteinname '_UID-' UID]);
                end
                
                for k=1:numel(channels)
                    
%%                      calculate the maximum for this channel across all spine classes

                    max_rep1=[];
                    max_rep2=[];
                    
                    [~, names_rep2]=fileattrib([channels{k} '_aligned' avg_type{l} '_*.txt']);
                    names_rep2=natsortfiles({names_rep2.Name});
                    [~, names_rep1]=fileattrib([rep1 filesep folders_rep1{dir_rep1} filesep channels{k} '_aligned' avg_type{l} '_*.txt']);
                    names_rep1=natsortfiles({names_rep1.Name});
                    
                    if contains(avg_type{l},'fullimg')
                        [avg, sd, sem]=deal(zeros(501));
                        img_rep1=zeros(501,501,numel(names_rep1));
                        img_rep2=zeros(501,501,numel(names_rep2));
                    else
                        [avg, sd, sem]=deal(zeros(151));
                        img_rep1=zeros(151,151,numel(names_rep1));
                        img_rep2=zeros(151,151,numel(names_rep2));
                    end
                    
                    parfor n=1:numel(names_rep2)
                        img_rep2(:,:,n)=dlmread(names_rep2{n});
                    end
                    
                    parfor n=1:numel(names_rep1)
                        img_rep1(:,:,n)=dlmread(names_rep1{n});
                    end
                    max_rep1=max(img_rep1(:));
                    max_rep2=max(img_rep2(:));
                    
                    
                    
%% Now actually read in the images to calculate the averages.                     
                    for j=1:numel(classes)
                        clear class_*  names*
                        %                         if exist(['Z:\user\mhelm1\Nanomap_Analysis\Data\total\' proteinname '_UID-' UID filesep classes{j} '_' channels{k} '_average' avg_type{l} '_total.txt'])==2
                        % %                             disp([proteinname ' was already analyzed for ' classes{j} '_' channels{k} '_average' avg_type{l} '. Skipping it']);
                        %                             continue
                        %                         end
                        
                        [~, names_rep2]=fileattrib([channels{k} '_aligned' avg_type{l} '_*.txt']);
                        names_rep2=natsortfiles({names_rep2.Name});
                        [~, names_rep1]=fileattrib([rep1 filesep folders_rep1{dir_rep1} filesep channels{k} '_aligned' avg_type{l} '_*.txt']);
                        names_rep1=natsortfiles({names_rep1.Name});
                        
                        class_rep2=dlmread('classification.txt');
                        class_rep2(class_rep2==4)=[];
                        class_rep1=dlmread([rep1 filesep folders_rep1{dir_rep1} filesep 'classification.txt']);
                        class_rep1(class_rep1==4)=[];
                        
                        % Select only the spots from the correct type.
                        names_rep2=names_rep2(class_rep2==j);
                        names_rep1=names_rep1(class_rep1==j);
                        
                        if contains(avg_type{l},'fullimg')
                            [avg, sd, sem]=deal(zeros(501));
                            img_rep1=zeros(501,501,numel(names_rep1));
                            img_rep2=zeros(501,501,numel(names_rep2));
                        else
                            [avg, sd, sem]=deal(zeros(151));
                            img_rep1=zeros(151,151,numel(names_rep1));
                            img_rep2=zeros(151,151,numel(names_rep2));
                        end
                        
                        %                         Read in the filesd
                        parfor n=1:numel(names_rep2)
                            img_rep2(:,:,n)=dlmread(names_rep2{n});
                        end
                        
                        parfor n=1:numel(names_rep1)
                            img_rep1(:,:,n)=dlmread(names_rep1{n});
                        end
                        
                        %                         normalize each replicate to its maximum to make
                        %                         them better comparable
                        img_rep2=(img_rep2/max_rep2)*255;
                        img_rep1=(img_rep1/max_rep1)*255;
                        
                        img_both=cat(3,img_rep1,img_rep2);
                        
                        avg=mean(img_both,3);
                        sd=std(img_both,0,3);
                        sem=sd/sqrt(size(img_both,3));
                        save(['Z:\user\mhelm1\Nanomap_Analysis\Data\total\' proteinname '_UID-' UID filesep 'CombinedImageStack_' classes{j} '_' channels{k} avg_type{l} '.mat'],'img_both')
                        dlmwrite(['Z:\user\mhelm1\Nanomap_Analysis\Data\total\' proteinname '_UID-' UID filesep classes{j} '_' channels{k} '_average' avg_type{l} '_total.txt'],avg);
                        dlmwrite(['Z:\user\mhelm1\Nanomap_Analysis\Data\total\' proteinname '_UID-' UID filesep classes{j} '_' channels{k} '_average' avg_type{l} '_total_sd.txt'],sd);
                        dlmwrite(['Z:\user\mhelm1\Nanomap_Analysis\Data\total\' proteinname '_UID-' UID filesep classes{j} '_' channels{k} '_average' avg_type{l} '_total_sem.txt'],sem);
                    end
                end
            end
        end
    catch e
        disp(['Error in ' proteinname]);
        fprintf(1,'The identifier was:\n%s',e.identifier);
        fprintf(1,'There was an error! The message was:\n%s \n',e.message);
        
    end
end
close(w)

end



