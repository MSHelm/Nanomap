function process_files_for_maps_extract_zone_numbers

the_folder='Z:\user\mhelm1\Nanomap_Analysis\Data\total';


close all
cd(the_folder);

names={};
%Read in zone definitions from tif images
zonesf=imread('Z:\user\mhelm1\Nanomap_Analysis\Matlab\ZoneAnalysis\flat_thin_zones_plus_background.tif'); %% max 11; background up = 16; background down = 17;
zonesm=imread('Z:\user\mhelm1\Nanomap_Analysis\Matlab\ZoneAnalysis\mushroom_zones_plus_background.tif'); %% max 15; background up = 16; background down = 17;

% figure; subplot(2,2,1); imagesc(zonesf); axis equal;subplot(2,2,2); imagesc(zonesm); axis equal;

limit=14;

%Create matrix “top”, which is a 150 by 150 matrix. It has the value 1 on the outside 14 entries and 0 in the remaining inside 122x122 entries. This is because after the bandpass the outer 14 entries are 0
top=zonesf-zonesf; sizt=size(top);
top(1:limit,:)=1; top(:,1:limit)=1; top(sizt(1)-limit+1:sizt(1),:)=1; top(:,sizt(2)-limit+1:sizt(2))=1;
% subplot(2,2,3); imagesc(top); axis equal;

matrixm=[]; matrixf=[];
files=[];
files=dir;
folders={};
for i=3:numel(files)
    if files(i).isdir && isempty(regexp(files(i).name,'^[_]','once'))
        folders{numel(folders)+1}=files(i).name;
    end
end


% try
    %Analyze STED images. The other for loops look at homer and DiO
    for abcdef=1:numel(folders)
        disp(folders{abcdef});
        cd([the_folder filesep folders{abcdef}]);
        name=folders{abcdef};
        
        expression='(?<=UID-)[a-zA-Z0-9]*';
        UID=regexp(name,expression,'match');
        
        expression='\S*(?=_UID)';
        name=regexp(name,expression,'match');

        name=cat(2,name,UID);
        flat=dlmread('Flat_sted_average_150px_myfilt_total.txt');
        mush=dlmread('Mush_sted_average_150px_myfilt_total.txt');
        %     figure; subplot(2,2,1); imagesc(flat); axis equal;title(name);subplot(2,2,2); imagesc(mush);axis equal;
        % filter the sted images with bandpass of length 14 pixels. This
        % removes a lot of background
        mush=bpass(mush,0,limit);
        flat=bpass(flat,0,limit);
        %     subplot(2,2,3); imagesc(flat); axis equal;subplot(2,2,4); imagesc(mush);axis equal;
        ccc=find(zonesm==16 & top==0);
        %e.	Substract the background, but only from the inside area (which does not have 0 in the matrix “top”). This is only done that way for mushroom, the zones in flat always fall inside the inside area, so no additional constraints have to be taken.
        mush=mush-mean(mush(ccc));
        mush(mush<0)=0;
        mm=[];
        %For each zone sum all intensity within that zone
        for i=1:15
            ccc=find(zonesm==i & top==0);
            mm(i)=sum(mush(ccc));
        end
        
        %Calculate distribution of intensity over the zones in percentage
        ccc=find(zonesm>0 & zonesm<16 & top==0);
        mm=mm*100/sum(mush(ccc));
        matrixm=cat(1,matrixm,mm);
        ccc=find(zonesf==16);
        flat=flat-mean(flat(ccc));
        flat(flat<0)=0;
        mm=[];
        for i=1:11
            ccc=find(zonesf==i & top==0);
            mm(i)=sum(flat(ccc));
        end
        ccc=find(zonesf>0 & zonesf<16 & top==0);
        mm=mm*100/sum(flat(ccc));
        matrixf=cat(1,matrixf,mm);
%         names{numel(names)+1}=name;
        names=cat(1,names,name);
    end
    
    figure;
    subplot(1,2,1); imagesc(matrixf(:,1:10));colorbar
    set(gca,'YTick',1:size(names,1),'YTickLabel',names(:,1))
    subplot(1,2,2); imagesc(matrixm(:,1:14));colorbar;
    set(gca,'YTick',1:size(names,1),'YTickLabel',names(:,1))   
    
    cd(the_folder);
    dlmwrite('sted_percs_flat_new.txt',matrixf);
    dlmwrite('sted_percs_mushroom_new.txt',matrixm);
    
    xlswrite('zone_distribution_from_images.xlsx',names,'names');
    xlswrite('zone_distribution_from_images.xlsx',matrixf,'sted_flat');
    xlswrite('zone_distribution_from_images.xlsx',matrixm,'sted_mush');
    
    matrixm=[]; matrixf=[];
    %Analyze DiO
    for abcdef=1:numel(folders)
%         disp(abcdef);
%         name=cellb{abcdef};
        disp(folders{abcdef});
        cd([the_folder filesep folders{abcdef}]);
%         s=name;
%         s=regexp(s,filesep,'split');
        name=folders{abcdef};
        flat=dlmread('Flat_dio_average_150px_myfilt_total.txt');
        mush=dlmread('Mush_dio_average_150px_myfilt_total.txt');
        ccc=find(zonesm==16);
        mush=mush-mean(mush(ccc));
        mm=[];
        for i=1:15
            ccc=find(zonesm==i);
            mm(i)=sum(mush(ccc));
        end
        ccc=find(zonesm>0 & zonesm<16);
        mm=mm*100/sum(mush(ccc));
        matrixm=cat(1,matrixm,mm);
        ccc=find(zonesf==16);
        flat=flat-mean(flat(ccc));
        mm=[];
        for i=1:11
            ccc=find(zonesf==i);
            mm(i)=sum(flat(ccc));
        end
        ccc=find(zonesf>0 & zonesf<16);
        mm=mm*100/sum(flat(ccc));
        matrixf=cat(1,matrixf,mm);
%         names{numel(names)+1}=name;
    end
    figure;
    subplot(1,2,1); imagesc(matrixf);colorbar
    subplot(1,2,2); imagesc(matrixm);colorbar;
    
    cd (the_folder); 
    dlmwrite('dio_percs_flat_new.txt',matrixf); 
    dlmwrite('dio_percs_mushroom_new.txt',matrixm);
    xlswrite('zone_distribution_from_images.xlsx',matrixf,'dio_flat'); 
    xlswrite('zone_distribution_from_images.xlsx',matrixm,'dio_mush');
    
    matrixm=[]; matrixf=[];
    %Analyze Homer
    for abcdef=1:numel(folders)
%         disp(abcdef);
%         name=cellb{abcdef};
        disp(folders{abcdef});
        cd([the_folder filesep folders{abcdef}]);
%         s=name;
%         s=regexp(s,filesep,'split');
        name=folders{abcdef};
        flat=dlmread('Flat_homer_average_150px_myfilt_total.txt');
        mush=dlmread('Mush_homer_average_150px_myfilt_total.txt');
        ccc=find(zonesm==16);
        mush=mush-mean(mush(ccc));
        mm=[];
        for i=1:15
            ccc=find(zonesm==i);
            mm(i)=sum(mush(ccc));
        end
        ccc=find(zonesm>0 & zonesm<16);
        mm=mm*100/sum(mush(ccc));
        matrixm=cat(1,matrixm,mm);
        ccc=find(zonesf==16);
        flat=flat-mean(flat(ccc));
        mm=[];
        for i=1:11
            ccc=find(zonesf==i);
            mm(i)=sum(flat(ccc));
        end
        ccc=find(zonesf>0 & zonesf<16);
        mm=mm*100/sum(flat(ccc));
        matrixf=cat(1,matrixf,mm);
%         names{numel(names)+1}=name;
    end
    figure;
    subplot(1,2,1); imagesc(matrixf);colorbar
    subplot(1,2,2); imagesc(matrixm);colorbar;
    cd (the_folder); 
    dlmwrite('homer_percs_flat_new.txt',matrixf); 
    dlmwrite('homer_percs_mushroom_new.txt',matrixm);
    xlswrite('zone_distribution_from_images.xlsx',matrixf,'homer_flat'); 
    xlswrite('zone_distribution_from_images.xlsx',matrixm,'homer_mush');
% catch
%     disp(['Error in ' folders{abcdef}]);
% end
end
