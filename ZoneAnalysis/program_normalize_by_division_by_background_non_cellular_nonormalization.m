function program_normalize_by_division_by_background_non_cellular_nonormalization

close all

the_folder='Z:\user\mhelm1\Nanomap_Analysis\Data\total';
channels={'dio','homer','sted'};
cd(the_folder);

% names={};
zonesf=imread('Z:\user\mhelm1\Nanomap_Analysis\Matlab\ZoneAnalysis\flat_thin_zones_plus_background.tif'); %% max 11; background up = 16; background down = 17;
zonesm=imread('Z:\user\mhelm1\Nanomap_Analysis\Matlab\ZoneAnalysis\mushroom_zones_plus_background.tif'); %% max 15; background up = 16; background down = 17;
zoneso=imread('Z:\user\mhelm1\Nanomap_Analysis\Matlab\ZoneAnalysis\other_zones_plus_background.tif'); %% max 11; background up = 16; background down = 17;

matrixm=[]; matrixf=[]; matrixcorrsm=[];matrixcorrsf=[];
[dsstat, dmmess]=fileattrib('*');

files=[];
files=dir;
folders={};
for i=3:numel(files)
    if files(i).isdir && isempty(regexp(files(i).name,'^[_]','once'))
        folders{numel(folders)+1}=files(i).name;
    end
end


corrs=[];

dios=zeros(151,151);
homers=zeros(151,151);
matrix=[];

results={};


for k=1:numel(channels)
    protein_names={};
    matrix=[];
    for abcdef=1:numel(folders)
%         try
            disp(folders{abcdef});
            cd([the_folder filesep folders{abcdef}]);

            expression='(?<=UID-)[a-zA-Z0-9]*';
            UID=regexp(folders{abcdef},expression,'match');
            
            expression='\S*(?=_UID)';
            name=regexp(folders{abcdef},expression,'match');
            
            name=cat(2,name,UID);
            
            protein_names=cat(1,protein_names,name);
            
%             flat1=dlmread(['Flat_' channels{k} '_average_Replicate1.txt']);
%             flat2=dlmread(['Flat_' channels{k} '_average_Replicate2.txt']);
%             mush1=dlmread(['Mush_' channels{k} '_average_Replicate1.txt']);
%             mush2=dlmread(['Mush_' channels{k} '_average_Replicate2.txt']);
%             other1=dlmread(['Other_' channels{k} '_average_Replicate1.txt']);
%             other2=dlmread(['Other_' channels{k} '_average_Replicate2.txt']);
%             
%             %Here Image is divided by background -> the image is now signal fold over background!
%             ccc=find(zonesf==16); flat1back=mean(flat1(ccc)); flat1=flat1/flat1back; flat2back=mean(flat2(ccc)); flat2=flat2/flat2back;
%             ccc=find(zonesm==16); mush1back=mean(mush1(ccc)); mush1=mush1/mush1back; mush2back=mean(mush2(ccc)); mush2=mush2/mush2back;
%             ccc=find(zoneso==16); other1back=mean(other1(ccc)); other1=other1/other1back; other2back=mean(other2(ccc)); other2=other2/other2back;
%             
%             %simply average of both pictures is made. If a flipped version of avg2
%             %overlaps better with avg1 then this flipped image is taken for averaging.
%             mm1=corr2(mush1,mush2); mm2=corr2(mush1,fliplr(mush2)); if mm1>=mm2; mush=(mush1+mush2)/2; else mush=(mush1+fliplr(mush2))/2; end
%             mm1=corr2(flat1,flat2); mm2=corr2(flat1,fliplr(flat2)); if mm1>=mm2; flat=(flat1+flat2)/2; else flat=(flat1+fliplr(flat2))/2; end
%             mm1=corr2(other1,other2); mm2=corr2(other1,fliplr(other2)); if mm1>=mm2; other=(other1+other2)/2; else other=(other1+fliplr(other2))/2; end
%             

mush=dlmread(['Mush_' channels{k} '_average_150px_myfilt_total_nonormalization.txt']);
flat=dlmread(['Flat_' channels{k} '_average_150px_myfilt_total_nonormalization.txt']);
other=dlmread(['Other_' channels{k} '_average_150px_myfilt_total_nonormalization.txt']);


            %make mean of signal within spine (so everything except 16 and 17)
            sizm=size(matrix);
            ccc1=find(zonesm>0 & zonesm<16); %ccc2=find(zonesm==17);
            matrix(sizm(1)+1,1)=mean(mush(ccc1));%*100/(mean(mush(ccc2)));
            
            ccc1=find(zonesf>0 & zonesf<16); %ccc2=find(zonesf==17);
            matrix(sizm(1)+1,2)=mean(flat(ccc1));%*100/(mean(flat(ccc2)));
            
            ccc1=find(zoneso>0 & zoneso<16); %ccc2=find(zoneso==17);
            matrix(sizm(1)+1,3)=mean(other(ccc1));%*100/(mean(other(ccc2)));
            
            % figure
            % subplot(3,3,1); imagesc(flat1); axis equal;colorbar; title(name)
            % subplot(3,3,2); imagesc(flat2); axis equal;colorbar
            % subplot(3,3,3); imagesc(flat); axis equal;colorbar
            % subplot(3,3,4); imagesc(mush1); axis equal;colorbar
            % subplot(3,3,5); imagesc(mush2); axis equal;colorbar
            % subplot(3,3,6); imagesc(mush); axis equal;colorbar
            % subplot(3,3,7); imagesc(other1); axis equal;colorbar
            % subplot(3,3,8); imagesc(other2); axis equal;colorbar
            % subplot(3,3,9); imagesc(other); axis equal;colorbar
            
            
%             previously silvios normalized mean of both replicates was
%             written here. I dont use it anymore.
%             dlmwrite(['Mush_' channels{k} '_norm_total.txt'],mush);
%             dlmwrite(['Flat_' channels{k} '_norm_total.txt'],flat);
%             dlmwrite(['Other_' channels{k} '_norm_total.txt'],other);
%             
            
            %ccc=find(zonesf<16);corrs(abcdef,1)=corr2(flat1(ccc),flat2(ccc));
            %ccc=find(zonesm<16);corrs(abcdef,2)=corr2(mush1(ccc),mush2(ccc));
            %corrs(abcdef,3)=corr2(flat1,mush1);
            %corrs(abcdef,4)=corr2(flat2,mush2);
            %corrs(abcdef,5)=corr2(flat1,mush2);
            %corrs(abcdef,6)=corr2(flat2,mush1);
            
%             names{numel(names)+1}=name;
            
            %start making the final result matrix
%             if k==1
%                 results=proteinnames;
%             end
            
%         catch
%         end
    end
    
    figure;
    imagesc(matrix); colorbar
    spinetypes={'Mushroom','Stubby','Other'};
    set(gca,'YTick',1:numel(protein_names),'YTickLabel',protein_names,'XTick',1:3,'XTickLabel',spinetypes)
    title(['Mean total ' channels{k} ' Distribution in all zones across the different spine types'])
    cd (the_folder)
    dlmwrite([channels{k} '_matrix_differential_intensities_nonormalization.txt'],matrix)
    
    if k==1
        results=protein_names;
    end
    
    results=cat(2,results,num2cell(matrix));
    %matrix is the mean signal of everything within the spine.
    %     xlswrite([channels{k} 'DifferentialIntensities.xlsx'],names','names');
    %     xlswrite([channels{k} 'DifferentialIntensities.xlsx'],matrix,[channels{k} '_matrix']);
    
    
end

xlswrite('DifferentialIntensities_nonormalization.xlsx',results);

tab=cell2table(results,'VariableNames',{'Name','UID','Mean_dio_mush','Mean_dio_flat','Mean_dio_other','Mean_homer_mush','Mean_homer_flat','Mean_homer_other','Mean_sted_mush','Mean_sted_flat','Mean_sted_other'});
save('DifferentialIntensities_nonormalization.mat','tab');

end








