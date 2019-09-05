function CalculateColocRatioR2(the_folder)

addpath(genpath('Z:\user\mhelm1\Subcellular Distribution Analysis\Matlab Programs')); 

cd(the_folder)


%Debugging variables
%the_folder='Z:\user\mhelm1\Subcellular Distribution Analysis\Replicate2';
%i=1;
%second_extend

second_extend=0;
SE_erode=2;
cd(the_folder);

%look for all the subfolder names
files=[];
files=dir;
folders={};
for i=3:numel(files)
    if files(i).isdir
        folders{numel(folders)+1}=files(i).name;
    end
end

for abcdef=1:numel(folders)
    abcdef;
    name=folders{abcdef}
    cd(name);
    
    
%Calculate amount of protein inside SYNAPTOSOMES
    mess=dir('*Synapto*_ch0.TIF'); %change it to ('*Synapto*_ch0.tif') for my images. channel 0 is SyPhy in presynaptic controls and Homer1 in my data
    
%     Check if there are Synaptosome stainings present. If yes analyze
%     them. if not then get the number of neuron stainings and write a file
%     with zeros.
    if ~isempty(mess)
        
    insyn=zeros(numel(mess),1);

%First detect homer spots with filtering and erode/dilate. 
    parfor i=1:numel(mess)
        name=mess(i).name; name=name(1:numel(name)-5);
        homer=double(imread(strcat(name,'0.tif')));
        poi=double(imread(strcat(name,'1.tif')));
            %figure; subplot(2,2,2); imagesc(homer); axis equal; subplot(2,2,1); imagesc(poi);axis equal;title(char(name)); 
        homer=bpass(homer,0,15);
        ccc=find(homer<mean2(homer)+std2(homer)); homer(ccc)=0;
        homer2=homer-homer; ccc=find(homer>0); homer2(ccc)=1; 
        homer2=imerode(homer2,strel('disk',SE_erode));homer2=imdilate(homer2,strel('disk',second_extend));
        homernum=max(max(bwlabel(homer2)));

        %filter protein of interest image: bandpass, remove everything below
        %mean (which is very low, probably close to offset), create mask from
        %this and dilate it with a disk of size 2. -> this should give all
        %regions that contain any real protein of interest signal
        %Calculate background by looking at everything outside of this mask.
        %The histogram stuff does the following: plot the signal intensity
        %distribution. Look for the bin that has the highest population ->
        %select the signal there as the background signal (the ccc(1)*2 is to
        %get from the index of the histogram bin to the signal intensity, since
        %the bins are done using a width of 2
        poi2=bpass(poi,0,15);
        ccc=find(poi2<mean2(poi2)); poi2(ccc)=0; poi3=poi2-poi2; ccc=find(poi2>0); poi3(ccc)=1; poi3=imdilate(poi3,strel('disk',2));
        ccc=find(poi3==0);baseline=poi(ccc); bb=hist(baseline,[0:2:10000]); bb=bb(1:4000); ccc=find(bb==max(bb)); tosub=ccc(1)*2;
        %here finally look for the proteins signal: select all regions that
        %have homer, as determined before with homer2, take the mean and
        %subtract the background
        ccc=find(homer2>0); homersurf=numel(ccc);
        insyn(i)=(mean(poi(ccc))-tosub);%*homersurf/homernum;%%[per pixel]
    end
    dlmwrite(['in_synaptosomes_average_SE' num2str(second_extend) '.txt'],insyn);
    
    else
        disp(['No Synaptosome stainings detected in ' folders{abcdef} '. Writing a dummy in synaptosome file'])
        mess=dir('*Neuron*_ch0.tif'); %Get number of neuron images to write an equally large file.
        insyn=zeros(size(mess));
        dlmwrite(['in_synaptosomes_average_SE' num2str(second_extend) '.txt'],insyn);
    end


    %Calculate amount of protein inside NEURONS and R2 with Homer1
    mess=dir('*Neuron*_ch0.tif');  %change it to ('*Synapto*_ch0.tif') for my images. channel 0 is SyPhy in presynaptic controls and Homer1 in my data
    
    inneur=zeros(numel(mess),1); ratiorest=zeros(numel(mess),1); RSquared=zeros(numel(mess),1); RSquared_p=zeros(numel(mess),1);

    parfor i=1:numel(mess)
        name=mess(i).name; name=name(1:numel(name)-5);
        homer=double(imread(strcat(name,'0.tif'))); homer_raw=homer;
        poi=double(imread(strcat(name,'1.tif'))); poi_raw=poi;

            %figure; subplot(2,2,2); imagesc(homer); title('Homer');axis equal; subplot(2,2,1); imagesc(poi);axis equal; title(['POI:' char(name)]);
        homer=bpass(homer,0,15);
        ccc=find(homer<mean2(homer)+std2(homer)); homer(ccc)=0;
        homer2=homer-homer; ccc=find(homer>0); homer2(ccc)=1; 
        homer2=imerode(homer2,strel('disk',SE_erode));homer2=imdilate(homer2,strel('disk',second_extend));

        poi2=bpass(poi,0,15);
        ccc=find(poi2<mean2(poi2)); poi2(ccc)=0; poi3=poi2-poi2; ccc=find(poi2>0); poi3(ccc)=1; poi3=imdilate(poi3,strel('disk',2));
        ccc=find(poi3==0);baseline=poi(ccc); bb=hist(baseline,[0:2:10000]); bb=bb(1:4000); ccc=find(bb==max(bb)); tosub=ccc(1)*2;

            %subplot(2,2,3); imagesc(homer2); title('filtered and dilated Homer'); axis equal; subplot(2,2,4); imagesc(poi2); title('Poi >= mean2 of poi'); axis equal;

        homernum=max(max(bwlabel(homer2)));
        ccc=find(homer2>0); homersurf=numel(ccc);
        inneur(i)=mean(poi(ccc))-tosub; inhom=inneur(i)*numel(ccc); % the *numel(ccc) doesnt make sense. Why should I multiply the signal times the amount of PSDs? I would rather divide it.
        ccc=find(homer2==0 & poi2>0); inrest=(mean(poi(ccc))-tosub)*numel(ccc);
        ratiorest(i)=inhom*100/(inhom+inrest);
        
        %Calculate R^2 from raw images but only from areas within synapses
        %(as defined by homer signal)
        ccc=find(homer2>0);
        RSquared(i)=corr2(homer_raw(ccc),poi_raw(ccc));
        %calculate p value of correlation
        [h, p]=corrcoef(homer_raw(ccc),poi_raw(ccc));
        RSquared_p(i)=p(2);
        
        %RSquared(i,1)=power(corr2(homer,poi2-tosub),2);
        
        
    end

     RSquared=cat(2,RSquared,RSquared_p);
     dlmwrite(['in_neuronal_synapses_average_SE' num2str(second_extend) '.txt'],inneur); 
     dlmwrite(['percentage_in_synapses_SE' num2str(second_extend) '.txt'],ratiorest);
     dlmwrite(['RSquared_SE' num2str(second_extend) '.txt'],RSquared);
     
     cd(the_folder); 
end
 
    
results={}; 
for i=1:numel(folders);
    results{1,1}='Foldername'; results{1,2}='Uniprot ID'; results{1,3}='Ratio Neurons/synaptosomes'; results{1,4}='Ratio Neurons/synaptosomes SEM';
    results{1,5}='% in synapses'; results{1,6}='% in synapses SEM'; results{1,7}='R Squared Homer1 and POI'; results{1,8}='R Squared Homer1 and POI SEM';
    results{1,9}='R Squared p value'; results{1,10}='R Squared p value SEM';
    
    cd(the_folder);    
    cd(folders{i});
    
    insyn=dlmread(['in_synaptosomes_average_SE' num2str(second_extend) '.txt']);
    inneur=dlmread(['in_neuronal_synapses_average_SE' num2str(second_extend) '.txt']);
    ratior=dlmread(['percentage_in_synapses_SE' num2str(second_extend) '.txt']);
    RSquared=dlmread(['RSquared_SE' num2str(second_extend) '.txt']);

    results{i+1,1}=folders{i};
%extract uniprot ID from folder name
    str=results{i+1,1};
    expression='(?<=UID-)[a-zA-Z0-9]*';
    UID=regexp(str,expression,'match');
    UID=UID{1};
    results{i+1,2}=UID;
    
    results{i+1,3}=mean(inneur)/mean(insyn);
    results{i+1,4}=std(inneur)/(mean(insyn)*sqrt(numel(inneur)));
    results{i+1,5}=mean(ratior);
    results{i+1,6}=std(ratior)/sqrt(numel(ratior));
    results{i+1,7}=mean(RSquared(:,1));
    results{i+1,8}=mean(RSquared(:,1))/sqrt(numel(RSquared(:,1)));
    results{i+1,9}=mean(RSquared(:,2));
    results{i+1,10}=mean(RSquared(:,2))/sqrt(numel(RSquared(:,2)));
    

end

cd(the_folder);

xlswrite(strcat('results_SE',num2str(second_extend),'.xlsx'),results);
header=results(1,:);
header=matlab.lang.makeValidName(header);
results(1,:)=[];
results=cell2table(results,'VariableNames',header);
save(strcat('results_SE',num2str(second_extend),'.mat'),'results');

end

    
    
    