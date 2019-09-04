addpath(genpath('Z:\user\mhelm1\Nanomap_Analysis\Matlab\IndividualAnalysis'))
cd_path='Z:\user\mhelm1\Nanomap_Analysis\Data\Replicate1';
cd(cd_path)
files=[];
files=dir;
folders={};
for i=3:numel(files)
    if files(i).isdir && strcmp(files(i).name,'figures')==0
        folders{numel(folders)+1}=files(i).name;
    end
end

for k=1:10
    cd([cd_path filesep folders{k}]);
    

% cd 'Z:\user\mhelm1\Nanomap_Analysis\Data\Replicate1\BDNF_UID-P23363_2015-06-22'
[stat, mess]=fileattrib('*spots*.txt');
[~,order]=sort({mess.Name}); mess=mess(order); clear order %sort to avoid unordered files due to server bugs
load coordinates.mat
coord=coordinates;
clear coordinates


load([folders{k} '_SpotAnalysis'])

figure
i=1;
for j=1:numel(mess)
    if coord.classification(j)==1
        
        
        spots=dlmread(mess(j).Name);
        homer=spots(:,1:301);
        dio=spots(:,302:602);
        sted=spots(:,603:903);
        leftin=dio-dio;
        %preprocess Homer
        homer=imfilter(homer,fspecial('average',[5 5]),'replicate');
        homer=bpass(homer,1,25);
        %create DiO mask, applying different filters
%         H=fspecial('average',[2 2]); dio_b=imfilter(medfilt2(dio, [4 4]),H,'replicate');
%dio_b=medfilt2(dio);
dio_b=dio;
        dio_bw=imbinarize(mat2gray(dio_b),0.3*otsuthresh(mat2gray(dio_b(:))));
%         dio_bw=imbinarize(mat2gray(dio_b),'adaptive','Sensitivity',0.7);

dio_bw=imfill(dio_bw,'holes');
dio_bw=imclose(dio_bw,strel('disk',2));
dio_bw=imopen(dio_bw,strel('disk',2));


        %             filt_db=dio_b;ccc=find(dio_b>0);
        %             pp=hist(dio_b(ccc),[0.5:1:50]); ppm=max(pp); cccp=find(pp==ppm,1);
        %             ccc=find(dio_b<cccp+std2(dio_b)); dio_b(ccc)=0;
        %             ccc=find(dio_b>0); dio_bw=dio_b; dio_bw(ccc)=1; dio_bw=imerode(dio_bw,strel('disk',1));
        %
        %remove signal outside dio mask.
        ccc=find(dio_bw==0); homer(ccc)=0; sted(ccc)=0; filt_db(ccc)=0;
        
        %Find center of spine
        centerrow=round((coord.topy(j)+coord.bottomy(j))/2);
        centercolumn=round((coord.rightx(j)+coord.leftx(j))/2);
        head_w=pdist([coord.leftx(j),coord.lefty(j);coord.rightx(j),coord.righty(j)],'euclidean');
        head_h=pdist([coord.bottomx(j),coord.bottomy(j);coord.topx(j),coord.topy(j)],'euclidean');
        %Create preliminary head mask from polygon. This is
        %Silvios code. I use this to limit the neck to get
        %too much into the head region!
        doublex=centercolumn; doubley=centerrow; ocols3=[]; orows3=[]; outer_radius=max([head_h,head_w])/2+1;
        k = 4; n = 2^k-1;
        theta = pi*(-n:1:n)/n;
        protx=doublex; proty=doubley;
        protx = protx + outer_radius*cos(theta);
        proty = proty + outer_radius*sin(theta);
        orows3=round(protx);
        ocols3=round(proty);
        octogon2=roipoly(dio, orows3,ocols3);
        pos=find(octogon2==1);
        leftin(pos)=1;%%%% 1 = in spine head
        %             Create accurate head mask. For this take initial
        %             ellipse guess from Silvio and expand it. Then
        %             take everything that is within the large elipse,
        %             withing dio and is not neck.
        dio_head=zeros(size(leftin));
        dio_head(leftin==1)=1;
        dio_head=imdilate(dio_head,strel('disk',3));
        %             remove the preliminary head mask and replace it
        %             with the accurate one
        leftin(leftin==1)=0;
        leftin(dio_bw==1 & dio_head==1 & leftin~=3)=1;
        
        
        head_check=zeros(size(leftin));
        head_check(leftin==1)=1;
        head_check=edge(head_check);
        [X, Y]=find(head_check==1);
        subplot(3,4,i); imagesc(dio); axis equal; hold on; plot(Y,X,'*','Color','r','MarkerSize',2); hold off;
        
        i=i+1;
        if i==12
            break
        end
    else
        continue
    end
end
end