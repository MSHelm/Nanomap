function IndividualSpineAnalysis(cd_path)
% cd_path='Z:\user\mhelm1\Nanomap_Analysis\Data\Replicate1';
clearvars -except cd_path

addpath(genpath('Z:\user\mhelm1\Nanomap_Analysis\Matlab\IndividualAnalysis'))
cd(cd_path);

files=[];
files=dir;
folders={};
for i=3:numel(files)
    if files(i).isdir && isempty(regexp(files(i).name,'^[_]','once'))
        folders{numel(folders)+1}=files(i).name;
    end
end


% folders = regexp(genpath(the_folder),'[^;]*','match');

for i=1:numel(folders)
    
    
    clear results
    results=struct('Class',[],...
        'HeadArea',[],...
        'HeadCenterColumn',[],...
        'HeadCenterRow',[],...
        'HeadHeight',[],...
        'HeadMajorAxisLength',[],...
        'HeadMinorAxisLength',[],...
        'HeadMajorMinorAxisOrientation',[],...
        'HeadEccentricity',[],...
        'HeadWidth',[],...
        'HomerCenterDistance',[],...
        'HomerDioDistance',[],...
        'HomerMajorAxisLength',[],...
        'HomerMaxIntensity',[],...
        'HomerMeanIntensity',[],...
        'HomerMinorAxisLength',[],...
        'HomerMajorMinorAxisOrientation',[],...
        'HomerEccentricity',[],...
        'HomerCentroidX',[],...
        'HomerCentroidY',[],...
        'HomerCenterAngle',[],...
        'HomerNumber',[],...
        'HomerArea',[],...
        'HomerFWHMCenterDistance',[],...
        'HomerFWHMDioDistance',[],...
        'HomerFWHMMajorAxisLength',[],...
        'HomerFWHMMaxIntensity',[],...
        'HomerFWHMMeanIntensity',[],...
        'HomerFWHMMinorAxisLength',[],...
        'HomerFWHMMajorMinorAxisOrientation',[],...
        'HomerFWHMEccentricity',[],...
        'HomerFWHMCentroidX',[],...
        'HomerFWHMCentroidY',[],...
        'HomerFWHMCenterAngle',[],...
        'HomerFWHMArea',[],...
        'STEDHeadIntensity',[],...
        'STEDHeadSpotNumber',[],...
        'STEDHomerIntensity',[],...
        'STEDHomerEnrichment',[],...
        'STEDHomerFWHMIntensity',[],...
        'STEDHomerFWHMEnrichment',[],...
        'NeckArea',[],...
        'NeckLength',[],...
        'RootArea',[],...
        'SpotCompartment',[],...
        'STEDArea',[],...
        'STEDDioDistance',[],...
        'STEDHeadBottomDistance',[],...
        'STEDHeadCenterDistance',[],...
        'STEDHeadTopDistance',[],...
        'STEDHomerFWHMDistance',[],...
        'STEDMajorAxisLength',[],...
        'STEDMaxIntensity',[],...
        'STEDMeanIntensity',[],...
        'STEDMinorAxisLength',[],...
        'STEDNeckBottomDistance',[],...
        'STEDCentroidX',[],...
        'STEDCentroidY',[],...
        'STEDSpotNumber',[],...
        'STEDTotalIntensity',[],...
        'STEDShaftIntensity',[],...
        'STEDBackgroundIntensity',[],...
        'STEDEccentricity',[],...
        'STEDLaterality',[],...
        'STEDDistribution',[],...
        'STEDHeadEnrichment',[],...
        'SpotFile',[]...
        );
    
    
    cd([cd_path filesep folders{i}]);
    disp(['Currently analyzing ' folders{i}]);
    [stat, mess]=fileattrib('*spots*.txt');
    if stat==0
        disp(['No files found in ' folders{i}]);
        continue
    end
    
    %     if exist('*SpotAnalysis')==2
    %         disp(['Folder ' pwd ' already analyzed. Skipping it']);
    %         continue
    %     end
    
    [~,order]=sort({mess.Name}); mess=mess(order); clear order %sort to avoid unordered files due to server bugs
    
    
    
    load coordinates.mat
    coord=coordinates;
    clear coordinates
    
    for j=1:numel(mess)
        
        
        if coord.classification(j)==4
            fields=fieldnames(results);
            for m=1:numel(fields)
                results.(fields{m}){j}=NaN;
            end
            results.Class{j}=4;
            results.SpotFile{j}=mess(j).Name;
            continue
        end
        
        try
            results.Class{j}=coord.classification(j);
            results.SpotFile{j}=mess(j).Name;
            spots=dlmread(mess(j).Name);
            homer=spots(:,1:301);
            dio=spots(:,302:602);
            leftin=dio-dio;
            sted=spots(:,603:903);
            wavelet=imread([mess(j).Name(1:end-4) '_sted_wavelet_binary.tif']);
            wavelet=double(wavelet/255); %icy stores the binaries with value 255, but I need 1
            line_x=dlmread(['spineline_x_',num2str(j),'.txt']);
            line_y=dlmread(['spineline_y_',num2str(j),'.txt']);
            
            %create DiO mask, applying different filters
            dio_bw = foregrounddetect(dio,3);
            
            %remove signal outside dio mask.
            ccc=find(dio_bw==0); homer(ccc)=0; sted(ccc)=0; filt_db(ccc)=0;
            
            %Find center of spine
            centerrow=round((coord.topy(j)+coord.bottomy(j))/2);
            centercolumn=round((coord.rightx(j)+coord.leftx(j))/2);
            results.HeadCenterRow{j}=centerrow;
            results.HeadCenterColumn{j}=centercolumn;
            
            %Calculate width (left-right) and height (bottom-top) distances of
            %the head. This is almost identical to above script but I think
            %faster and more accurate.
            head_w=pdist([coord.leftx(j),coord.lefty(j);coord.rightx(j),coord.righty(j)],'euclidean');
            head_h=pdist([coord.bottomx(j),coord.bottomy(j);coord.topx(j),coord.topy(j)],'euclidean');
            results.HeadWidth{j}=head_w;
            results.HeadHeight{j}=head_h;
            
            %             define average intensities from the background rectangle I
            %             clicked
            polix=[]; polix(1)=coord.shaftbottomleftx(j); polix(2)=coord.shaftbottomrightx(j); polix(3)=coord.shafttoprightx(j); polix(4)=coord.shafttopleftx(j);
            poliy=[]; poliy(1)=coord.shaftbottomlefty(j); poliy(2)=coord.shaftbottomrighty(j); poliy(3)=coord.shafttoprighty(j); poliy(4)=coord.shafttoplefty(j);
            poli=roipoly(dio,polix,poliy); ccc=find(poli==1); meanshaft=mean(dio(ccc));stdshaft=std(dio(ccc));
            
            results.STEDShaftIntensity{j}=mean(sted(ccc));
            
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
            
            if coord.classification(j)==1
                %             Define neck area
                for l=1:numel(line_x)
                    doublex=round(line_x(l)); doubley=round(line_y(l)); ocols3=[]; orows3=[]; outer_radius=max([head_h,head_w])/4+1;
                    k = 4; n = 2^k-1;
                    theta = pi*(-n:1:n)/n;
                    protx=doublex; proty=doubley;
                    protx = protx + outer_radius*cos(theta)*0.5;
                    proty = proty + outer_radius*sin(theta)*0.5;
                    orows3=round(protx);
                    ocols3=round(proty);
                    octogon2=roipoly(dio, orows3,ocols3);
                    pos=find(octogon2==1 & dio>meanshaft*0.33 & leftin==0);%%% only takes pixels with values in DiO and which have not been assigned to head or root
                    leftin(pos)=3;%%%% 3 = in neck;
                end
                
                if isempty(numel(line_x))
                    results.NeckLength{j}=NaN;
                else
                    results.NeckLength{j}=numel(line_x);
                end
                
                results.NeckArea{j}=sum(leftin(:)==3);
            else
                results.NeckLength{j}=NaN;
                results.NeckArea{j}=NaN;
            end
            
            %             Define Root area
            doublex=coord.bottomneckx(j); doubley=coord.bottomnecky(j); ocols3=[]; orows3=[]; outer_radius=max([head_h,head_w])+3;%%%
            %%% the root of the spine has the same dimension as the head.
            %%% (approximately)
            %%% But I actually take more than double the radius here!!!
            k = 4; n = 2^k-1;
            theta = pi*(-n:1:n)/n;
            protx=doublex; proty=doubley;
            protx = protx + outer_radius*cos(theta)*2;
            proty = proty + outer_radius*sin(theta)*2;
            orows3=round(protx);
            ocols3=round(proty);
            octogon2=roipoly(dio, orows3,ocols3);
            pos=find(octogon2==1 & dio>0.8*meanshaft & leftin==0);%%% only takes pixels with values in DiO
            temp_leftin=zeros(size(leftin));
            temp_leftin(pos)=1;
            temp_leftin=imfill(temp_leftin,'holes');
            leftin(temp_leftin==1 & leftin==0)=2;%%%% 2 = in spine root
            temp_leftin=[];
            results.RootArea{j}=sum(leftin(:)==2);
            
            %             Create accurate head mask. For this take initial
            %             ellipse guess from Silvio and expand it. Then
            %             take everything that is within the large elipse,
            %             withing dio and is not neck.
            dio_head=zeros(size(leftin));
            dio_head(leftin==1)=1;
            dio_head=imdilate(dio_head,strel('disk',5));
            %             remove the preliminary head mask and replace it
            %             with the accurate one
            leftin(leftin==1)=0;
            leftin(dio_bw==1 & dio_head==1 & leftin~=3)=1;
            
            %             create again the mask just for the head to quantify it.
            dio_head=zeros(size(leftin));
            dio_head(leftin==1)=1;
            HeadStats=regionprops(dio_head,'MajorAxisLength','MinorAxisLength','Area','Orientation');
            results.HeadArea{j}=HeadStats.Area;
            results.HeadMajorAxisLength{j}=HeadStats.MajorAxisLength;
            results.HeadMinorAxisLength{j}=HeadStats.MinorAxisLength;
            results.HeadMajorMinorAxisOrientation{j}=HeadStats.Orientation; 
            
            %Set homer outside spinehead to 0. This prevents us from
            %looking at homer structures outside the head.
            ccc=find(leftin~=1); homer(ccc)=0;
            
            %             Create binary image.
            homer_bw=imfilter(homer,fspecial('average',[5 5]),'replicate');
            homer_bw=bpass(homer_bw,1,25); 
            homer_bw=imbinarize(mat2gray(homer_bw),0.5*otsuthresh(mat2gray(homer_bw(:))));
            
            %             Filter out all homer spots that have below 20 pixels.
            homer_bw=bwareaopen(homer_bw,20);           
            homer_bwl=bwlabel(homer_bw);
            
            stats=regionprops('table',homer_bwl,homer,'Centroid','MajorAxisLength','MinorAxisLength','Orientation','Area','MeanIntensity','MaxIntensity');
            results.HomerCentroidX{j}=stats.Centroid(:,1)';
            results.HomerCentroidY{j}=stats.Centroid(:,2)';
            results.HomerMajorAxisLength{j}=stats.MajorAxisLength';
            results.HomerMinorAxisLength{j}=stats.MinorAxisLength';
            results.HomerMajorMinorAxisOrientation{j}=stats.Orientation';
            results.HomerArea{j}=stats.Area';
            results.HomerMeanIntensity{j}=stats.MeanIntensity';
            results.HomerMaxIntensity{j}=stats.MaxIntensity';
            
            %             find distances of the homer spots to the membrane
            HomerDist=[];
            DistMap=bwdist(edge(dio_bw));
            for l=1:max(max(homer_bwl))
                HomerDist(l)=DistMap(round(results.HomerCentroidY{j}(l)),round(results.HomerCentroidX{j}(l)));
            end
            results.HomerDioDistance{j}=HomerDist;
            
            %             distance of homer to center of spine
            head_center=zeros(size(dio));
            head_center(centerrow,centercolumn)=1;
            HomerDist=[];
            DistMap=bwdist(head_center);
            for l=1:max(max(homer_bwl))
                HomerDist(l)=DistMap(round(results.HomerCentroidY{j}(l)),round(results.HomerCentroidX{j}(l)));
            end
            results.HomerCenterDistance{j}=HomerDist;
            
            %             Get angle of Homer to Center
            for l=1:max(max(homer_bwl))
                vectorHomer{l} = [results.HomerCentroidY{j}(l), results.HomerCentroidX{j}(l)]-[centercolumn, centerrow];
                angle(l)=atan2d(vectorHomer{l}(1),vectorHomer{l}(2));
            end
            results.HomerCenterAngle{j}=angle;
            
            %             Excentricity of homer in regard to top-bottom axis of head.
            %             Modified after Tals calculation. 1= at bttom, -1 =
            %             at head
            for l=1:max(max(homer_bwl))
                rel_dist_top(l)=sqrt((results.HomerCentroidY{j}(l)-coord.topx(j)^2+results.HomerCentroidX{j}(l)-coord.topy(j)^2));
                rel_dist_bottom(l)=sqrt((results.HomerCentroidY{j}(l)-coord.bottomx(j)^2+results.HomerCentroidX{j}(l)-coord.bottomy(j)^2));
                axial_eccentricity(l)=(rel_dist_top(l)-rel_dist_bottom(l))/(rel_dist_top(l)+rel_dist_bottom(l));
            end
            results.HomerEccentricity{j}=axial_eccentricity;
            
            %             Get number of detected PSDs
            results.HomerNumber{j}=max(max(homer_bwl));          
            
            sted_head = imgaussfilt(sted,1);
            sted_head(sted_head==0) = NaN;
            sted_head = sted_head/nanmax(sted_head(:));
            sted_head_mean = nanmean(sted_head(:));
            sted_head_std = nanstd(sted_head(:));
            sted_head = sted_head - 1.2*sted_head_mean;
            sted_head = sted_head / sted_head_std;
            sted_head_bw = imbinarize(sted_head,'adaptive');
            sted_head_bw(leftin~=1) = 0;
            sted_head_bw = bwareaopen(sted_head_bw,16);
            sted_head_bwl = bwlabel(sted_head_bw);
            results.STEDHeadSpotNumber{j} = max(sted_head_bwl(:));
            
            
            %             Get total intensity of staining in head. This will be used
            %             for the clustering analysis
            results.STEDHeadIntensity{j}=sum(sted(leftin==1));
            
            %             Get "Enrichment" of staining head over shaft
            results.STEDHeadEnrichment{j}=(results.STEDHeadIntensity{j}/results.HeadArea{j})/results.STEDShaftIntensity{j};
            
            %             Get total intensity of staining in Homer.
            %             results.STEDHomerIntensity{j}=sum(sted(homer_bw==1));
            homer_intensity=[];
            for l=1:max(max(homer_bwl))
                homer_intensity(l)=sum(sted(homer_bwl==l));
            end
            results.STEDHomerIntensity{j}=homer_intensity;
            
            %             Get "Enrichment" of staining homer over shaft
            results.STEDHomerEnrichment{j}=(results.STEDHomerIntensity{j}./results.HomerArea{j})/results.STEDShaftIntensity{j};
            
            %             Get total intensity of staining over whole image
            results.STEDTotalIntensity{j}=sum(sted(:));   
            
            %             Analyze sted spots
            %             remove spots smaller than 3 pixels
            wavelet=bwareaopen(wavelet,3);
            
            %             remove spots that are more outside than inside
            %             head, neck or root
            wavelet_l=bwlabel(wavelet);
            for l=1:max(max(wavelet_l))
                wavelet_temp=zeros(size(wavelet));
                wavelet_temp(wavelet_l==l)=1;
                if numel(find(wavelet_temp==1 & dio_bw==0))> numel(find(wavelet_temp==1 & dio_bw~=0))
                    wavelet=wavelet - wavelet_temp;
                end
            end
            
            %             relabel the spots :)
            wavelet_l=bwlabel(wavelet);
            %             Get data on center, major and minor axis, area, mean and max
            %             intensity
            stedstats=regionprops('table',wavelet_l,sted,'Centroid','MajorAxisLength','MinorAxisLength','Area','MeanIntensity','MaxIntensity');
            results.STEDCentroidX{j}=stedstats.Centroid(:,1)';
            results.STEDCentroidY{j}=stedstats.Centroid(:,2)';
            results.STEDMajorAxisLength{j}=stedstats.MajorAxisLength';
            results.STEDMinorAxisLength{j}=stedstats.MinorAxisLength';
            results.STEDArea{j}=stedstats.Area';
            results.STEDMeanIntensity{j}=stedstats.MeanIntensity';
            results.STEDMaxIntensity{j}=stedstats.MaxIntensity';     
            
            %             Get data on distribution of spots, i.e. distances of spots to
            %             each other
            results.STEDDistribution{j}=pdist(cat(2,results.STEDCentroidX{j}',results.STEDCentroidY{j}'));
            
            %             get data on distance to DiO
            DistMap=bwdist(edge(dio_bw));
            StedDist=[];
            for l=1:max(max(wavelet_l))
                StedDist(l)=DistMap(round(results.STEDCentroidY{j}(l)),round(results.STEDCentroidX{j}(l)));
            end
            results.STEDDioDistance{j}=StedDist;
            
            
            %                 get data on distance to homer.
            
            % create homer mask which features only signal above fwhm. This represents
            % closely what would be seen by superresolution, as described by Blanpied
            % paper: Li & Blanpied, 2016, Frontiers in Synaptic
            % Neuroscience
            
            homer_bw_fwhm=homer_bw;
            for l=1:max(max(homer_bwl))
                homer_bw_fwhm((homer_bwl==l & homer<(results.HomerMaxIntensity{j}(l)/2)))=0;
            end
            
            homer_bw_fwhml=bwlabel(homer_bw_fwhm);
            
            stats=regionprops('table',homer_bw_fwhml,homer,'Centroid','MajorAxisLength','MinorAxisLength','Orientation','Area','MeanIntensity','MaxIntensity');
            results.HomerFWHMCentroidX{j}=stats.Centroid(:,1)';
            results.HomerFWHMCentroidY{j}=stats.Centroid(:,2)';
            results.HomerFWHMMajorAxisLength{j}=stats.MajorAxisLength';
            results.HomerFWHMMinorAxisLength{j}=stats.MinorAxisLength';
            results.HomerFWHMMajorMinorAxisOrientation{j}=stats.Orientation';
            results.HomerFWHMArea{j}=stats.Area';
            results.HomerFWHMMeanIntensity{j}=stats.MeanIntensity';
            results.HomerFWHMMaxIntensity{j}=stats.MaxIntensity';
            
            %             find distances of the homer spots to the membrane
            HomerDist=[];
            DistMap=bwdist(edge(dio_bw));
            for l=1:max(max(homer_bw_fwhml))
                HomerDist(l)=DistMap(round(results.HomerFWHMCentroidY{j}(l)),round(results.HomerFWHMCentroidX{j}(l)));
            end
            results.HomerFWHMDioDistance{j}=HomerDist;
            
            %             distance of homer to center of spine
            head_center=zeros(size(dio));
            head_center(centerrow,centercolumn)=1;
            HomerDist=[];
            DistMap=bwdist(head_center);
            for l=1:max(max(homer_bw_fwhml))
                HomerDist(l)=DistMap(round(results.HomerFWHMCentroidY{j}(l)),round(results.HomerFWHMCentroidX{j}(l)));
            end
            results.HomerFWHMCenterDistance{j}=HomerDist;
            
            %             Get angle of Homer to Center
            for l=1:max(max(homer_bw_fwhml))
                vectorHomer{l} = [results.HomerFWHMCentroidY{j}(l), results.HomerFWHMCentroidX{j}(l)]-[centercolumn, centerrow];
                angle(l)=atan2d(vectorHomer{l}(1),vectorHomer{l}(2));
            end
            results.HomerFWHMCenterAngle{j}=angle;
               
            %             Excentricity of homer in regard to top-bottom axis of head.
            %             Modified after Tals calculation. 1= at bttom, -1 =
            %             at head
            for l=1:max(max(homer_bw_fwhml))
                rel_dist_top(l)=sqrt((results.HomerFWHMCentroidY{j}(l)-coord.topx(j)^2+results.HomerFWHMCentroidX{j}(l)-coord.topy(j)^2));
                rel_dist_bottom(l)=sqrt((results.HomerFWHMCentroidY{j}(l)-coord.bottomx(j)^2+results.HomerFWHMCentroidX{j}(l)-coord.bottomy(j)^2));
                axial_eccentricity(l)=(rel_dist_top(l)-rel_dist_bottom(l))/(rel_dist_top(l)+rel_dist_bottom(l));
            end
            results.HomerFWHMEccentricity{j}=axial_eccentricity;
                 
            %                          Get total intensity of staining in Homer FWHM.
            %             results.STEDHomerFWHMIntensity{j}=sum(sted(homer_bw_fwhm==1));
            homer_intensity=[];
            for l=1:max(max(homer_bw_fwhml))
                homer_intensity(l)=sum(sted(homer_bw_fwhml==l));
            end
            results.STEDHomerFWHMIntensity{j}=homer_intensity;
            
            %             Get enrichment of staining in Homer FWHM over shaft
            results.STEDHomerFWHMEnrichment{j}=(results.STEDHomerFWHMIntensity{j}./results.HomerFWHMArea{j})/results.STEDShaftIntensity{j};
            
            %             This time dont use edge, so distance to homer is 0 if within homer spot.
            DistMap=bwdist(homer_bw_fwhm);
            StedDist=[];
            for l=1:max(max(wavelet_l))
                StedDist(l)=DistMap(round(results.STEDCentroidY{j}(l)),round(results.STEDCentroidX{j}(l)));
            end
            results.STEDHomerFWHMDistance{j}=StedDist;
            
            %             Get data on distance to center of head
            head_center=zeros(size(dio));
            head_center(centerrow,centercolumn)=1;
            
            StedDist=[];
            DistMap=bwdist(head_center);
            for l=1:max(max(wavelet_l))
                StedDist(l)=DistMap(round(results.STEDCentroidY{j}(l)),round(results.STEDCentroidX{j}(l)));
            end
            results.STEDHeadCenterDistance{j}=StedDist;
            
            %             Get Distance to top of head
            head_top=zeros(size(dio));
            head_top(round(coord.topy(j)),round(coord.topx(j)))=1;
            DistMap=bwdist(head_top);
            StedDist=[];
            for l=1:max(max(wavelet_l))
                StedDist(l)=DistMap(round(results.STEDCentroidY{j}(l)),round(results.STEDCentroidX{j}(l)));
            end
            results.STEDHeadTopDistance{j}=StedDist;
            
            %             Get distance to bottom of head
            head_bottom=zeros(size(dio));
            head_bottom(round(coord.bottomy(j)),round(coord.bottomx(j)))=1;
            DistMap=bwdist(head_bottom);
            StedDist=[];
            for l=1:max(max(wavelet_l))
                StedDist(l)=DistMap(round(results.STEDCentroidY{j}(l)),round(results.STEDCentroidX{j}(l)));
            end
            results.STEDHeadBottomDistance{j}=StedDist;
            
            %             Calculate Eccentricity of STED Spot in Head. 1 is top of
            %             head, -1 is bottom of ead
            results.STEDEccentricity{j}=(results.STEDHeadBottomDistance{j}-results.STEDHeadTopDistance{j})./(results.STEDHeadBottomDistance{j}+results.STEDHeadTopDistance{j});
            
            %             Get distance to bottom of neck
            neck_bottom=zeros(size(dio));
            neck_bottom(round(coord.bottomnecky(j)),round(coord.bottomneckx(j)))=1;
            DistMap=bwdist(neck_bottom);
            StedDist=[];
            for l=1:max(max(wavelet_l))
                StedDist(l)=DistMap(round(results.STEDCentroidY{j}(l)),round(results.STEDCentroidX{j}(l)));
            end
            results.STEDNeckBottomDistance{j}=StedDist;
            
            %             Calculate Laterality of STED Spots: 1 is completely
            %             left/right, 0 is in the center.
            head_left=zeros(size(dio));
            head_right=zeros(size(dio));
            head_left(round(coord.lefty(j)),round(coord.leftx(j)))=1;
            head_right(round(coord.righty(j)),round(coord.rightx(j)))=1;
            DistMapLeft=bwdist(head_left);
            DistMapRight=bwdist(head_right);
            LeftDist=[];
            RightDist=[];
            for l=1:max(max(wavelet_l))
                LeftDist(l)=DistMapLeft(round(results.STEDCentroidY{j}(l)),round(results.STEDCentroidX{j}(l)));
                RightDist(l)=DistMapRight(round(results.STEDCentroidY{j}(l)),round(results.STEDCentroidX{j}(l)));
            end
            
            results.STEDLaterality{j}=abs((LeftDist-RightDist)./(LeftDist+RightDist));
            
            %             Find out in which compartment (head, neck, root) the spots
            %             are
            spot_comp=[];
            for l=1:max(max(wavelet_l))
                spot_comp(l)=mean(leftin(wavelet_l==l));
            end
            results.SpotCompartment{j}=spot_comp;
            
            %             Get number of spots
            results.STEDSpotNumber{j}=max(wavelet_l);
            
            %             Get background STED intensity
            hist_sted=histogram(sted);
            [~, max_idx]=max(hist_sted.Values);
            results.STEDBackgroundIntensity{j}=mean(hist_sted.BinEdges(max_idx:max_idx+1));
            
        catch e
            disp(['Error in spot number ' num2str(j) ' in folder ' folders{i}]);
            fprintf(1,'The identifier was:\n%s',e.identifier);
            fprintf(1,'There was an error! The message was:\n%s \n',e.message);
            
            fields=fieldnames(results);
            for m=1:numel(fields)
                results.(fields{m}){j}=NaN;
            end
            results.Class{j}=coord.classification(j);
            results.SpotFile{j}=mess(j).Name;
            continue
        end
    end
    
    
    % Transform all values to the appropriate units (pixels into distance or
    % area etc.)
    fields=fieldnames(results);
    for z=1:numel(fields)
        if contains(fields{z},{'Distance','Length','Height','Width','Distribution'})
            results.(fields{z})=cellfun(@(x) x*20.2,results.(fields{z}),'UniformOutput',0);
            
        elseif contains(fields{z},{'Area'})
            results.(fields{z})=cellfun(@(x) x*(20.2^2),results.(fields{z}),'UniformOutput',0);
        end
    end
    
    
    save([folders{i} '_SpotAnalysis.mat'],'results');
end

end