function for_lego_model_mushroom_use_play_3D(draw_Model)
azx=[];azy=[];mx=[];my=[];cx=[];cy=[];pvesx=[];pvesy=[];uvesx=[];uvesy=[];dimensx=0;dimensy=0;mz=[];azz=[];cz=[];uvesz=[];pvesz=[];

% a=imread('flat_thin_zones_plus_background.tif');
% a=a(:,1:75); imagesc(a)
% mm=[]; siz=size(a); for i=1:11; ccc=find(a==i);  [xx yy]=ind2sub([siz(1) siz(2)],ccc); for j=1:numel(xx); sizm=size(mm); mm(sizm(1)+1,1)=i; mm(sizm(1)+1,2)=min(round(3.1415926*(2*(76-yy(j))-1)),80); end; end; figure; plot(mm);
% mm2=[]; zones=mm(:,1); pix=mm(:,2); for i=1:11; ccc=find(zones==i); mm2(i)=sum(pix(ccc)); end; mm2=mm2*100/sum(mm2); mm2'

% a=imread('mushroom_zones_plus_background.tif');
%  a=a(:,1:75); imagesc(a)
% mm=[]; siz=size(a); for i=1:15; ccc=find(a==i);  [xx yy]=ind2sub([siz(1) siz(2)],ccc); for j=1:numel(xx); sizm=size(mm); mm(sizm(1)+1,1)=i; mm(sizm(1)+1,2)=min(round(3.1415926*(2*(76-yy(j))-1)),80); end; end; figure; plot(mm);
% mm2=[]; zones=mm(:,1); pix=mm(:,2); for i=1:15; ccc=find(zones==i); mm2(i)=sum(pix(ccc)); end; mm2=mm2*100/sum(mm2); mm2'

cd_path='Z:\user\mhelm1\Nanomap_Analysis\Data\total';
cd(cd_path)
names={};

%Read in Allocation file
[~,~,allocation_raw]=xlsread('Z:\user\mhelm1\Nanomap_Analysis\Data\total\ProteinZoneAllocations.xlsx');
%dont need this anymore, as it is in the allocation cell
% [protorgs, textt]=xlsread('zone_distribution_from_images.xlsx','Sheet1','B2:L57');
[~,~,name_UID]=xlsread('zone_distribution_from_images.xlsx','names');
UID_list=name_UID(:,2);
%%%%%% (1)active zone  (2)membrane	(3)mitochondria (4)cytosol (5)BDNF/Rab3 (6)Chromo/Rab3 (7)Rab11/4 recycling
%%%%%% (8)Rab7 late	(9) Rab5/4 early	(10)ER (11)Rab9/TGN
[distribs, ~]=xlsread('zone_distribution_from_images.xlsx','sted_mush');

%read in copy number file
[~,~,copynum_raw]=xlsread('Z:\user\mhelm1\Subcellular Distribution Analysis\THE COPY NUMBER FILE_SE0.xlsx');
copynum_UID=copynum_raw(:,2);

%dont need this anymore as it is in the allocation cell [list, textt]=xlsread('zone_distribution_from_images.xlsx','Sheet1','N2:N57');
% ccc=find(list>0); list=ccc;

%only show the proteins selected in the protein allocation file
ccc=find(cell2mat(allocation_raw(:,15)));
prot_list=ccc;


%Read in the organelle and zone identities.
cd ('Z:\user\mhelm1\Electron Microscopy\spines\for_models\new tracings with mito\Mushroom_new with missing spine_after debugging script');
load('matrix_organelle_identities_plus_endosomes_corrected.mat');
orgs=matrix;

load('matrix_zone_identities_corrected.mat');
zones=matrix;
sizm=size(zones);


empercs=[0.0627	1.2547	2.6976	3.7014	1.1292	4.5169	5.0188	2.3839	4.1405	0.5019	1.7566	0.1882	5.3325	10.8532	56.4617];
%%%%% zonemeans from the surface distribution on zones on drawings
%%%%% zonemeans=[0.4386	3.5088	3.9474	2.6316	2.1930	4.8246	3.5088	3.5088	3.5088	2.1930	3.5088	1.7544	5.2632	11.8421	47.3684];

%%%%% zonemeans from the average distribution of signal on all STED images
zonemeans=mean(distribs);

protimgdir={};
protimgdirtemp=dir('Z:\user\mhelm1\Thesis\figures\Protein Averages\Semi3Dmodels\singleProteinImages_scaled_renamed');
for i=3:numel(protimgdirtemp)
    protimgdir{end+1}=protimgdirtemp(i).name;
end

if ~exist('Z:\user\mhelm1\Nanomap_Analysis\Data\total\_LegoModels\Mushroom','dir')
    mkdir('Z:\user\mhelm1\Nanomap_Analysis\Data\total\_LegoModels\Mushroom');
end


for abcdef=1:numel(prot_list)
    try
        UID=allocation_raw{prot_list(abcdef),2};
        name=allocation_raw(prot_list(abcdef),1);
        
        copynum_row=find(strcmp(copynum_UID,UID));
        copynumber=copynum_raw{copynum_row,22};
        
        if isnan(copynumber)
            if ~isnan(copynum_raw{copynum_row,20})
                disp(['No spine type corrected copy number availabe for protein ' name{:} ', UID ' UID '. Using the uncorrected one'])
                copynumber=copynum_raw{copynum_row,20};
            else
                copynumber=150;
                disp(['No Copynumber found for protein ' name{:} ', UID ' UID ' . Skipping it.'])
                continue
            end
        end
        
        
        
        if contains(name,{'Homer','Dynamin'})
            copynumber=copynumber/4;
        elseif strcmp(name,'CamKII')
            copynumber=copynumber/12;
        elseif strcmp(name,'NSF')
            copynumber=copynumber/6;
        end
        
        
        
        %name=char(names(prot_list(abcdef)));
        matrixview=zones-zones;
        
        protorg=cell2mat(allocation_raw(prot_list(abcdef),3:13));
        %since active zone proteins are mostly in the cytosol (Homer etc), they
        %are added to the cytosol definition
        protorg(4)=protorg(4)+protorg(1);
        
        %first put all proteins that belong to a specific organelle to the
        %respective pixels. They are distributed evenly over the whole volume
        %there.
        inmit=0; inBDNF=0; inchromo=0; inrab11=0; inrab7=0; inrab5=0; inER=0; inTGN=0; inmem=0;
        
        
        
        %         Here I removed the vacuole proteins .
%         if protorg(3)>0
%             inmit=round(copynumber*protorg(3)/100);
%             ccc=find(orgs==5);
%             rpp=floor(inmit/numel(ccc));
%             matrixview(ccc)=matrixview(ccc)+rpp;
%             rpp=(inmit-numel(ccc)*floor(inmit/numel(ccc)));
%             ppp=randperm(numel(ccc));
%             matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
%             ppp=randperm(numel(ccc));
%             matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
%         end
%         
%         
%         if protorg(5)>0
%             inBDNF=round(copynumber*protorg(5)/100);
%             ccc=find(orgs==10);
%             rpp=floor(inBDNF/numel(ccc));
%             matrixview(ccc)=matrixview(ccc)+rpp;
%             rpp=(inBDNF-numel(ccc)*floor(inBDNF/numel(ccc)));
%             ppp=randperm(numel(ccc));
%             matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
%             ppp=randperm(numel(ccc));
%             matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
%         end
%         
%         
%         if protorg(6)>0
%             inchromo=round(copynumber*protorg(6)/100);
%             ccc=find(orgs==20);
%             rpp=floor(inchromo/numel(ccc));
%             matrixview(ccc)=matrixview(ccc)+rpp;
%             rpp=(inchromo-numel(ccc)*floor(inchromo/numel(ccc)));
%             ppp=randperm(numel(ccc));
%             matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
%             ppp=randperm(numel(ccc));
%             matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
%         end
%         

%         if protorg(7)>0
%             inrab11=round(copynumber*protorg(7)/100);
%             ccc=find(orgs==30);
%             rpp=floor(inrab11/numel(ccc));
%             matrixview(ccc)=matrixview(ccc)+rpp;
%             rpp=(inrab11-numel(ccc)*floor(inrab11/numel(ccc)));
%             ppp=randperm(numel(ccc));
%             matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
%             ppp=randperm(numel(ccc));
%             matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
%         end
%         
%         
%         if protorg(8)>0
%             inrab7=round(copynumber*protorg(8)/100);
%             ccc=find(orgs==40);
%             rpp=floor(inrab7/numel(ccc));
%             matrixview(ccc)=matrixview(ccc)+rpp;
%             rpp=(inrab7-numel(ccc)*floor(inrab7/numel(ccc)));
%             ppp=randperm(numel(ccc));
%             matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
%             ppp=randperm(numel(ccc));
%             matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
%         end
%         
%         
%         if protorg(9)>0
%             inrab5=round(copynumber*protorg(9)/100);
%             ccc=find(orgs==50);
%             rpp=floor(inrab5/numel(ccc));
%             matrixview(ccc)=matrixview(ccc)+rpp;
%             rpp=(inrab5-numel(ccc)*floor(inrab5/numel(ccc)));
%             ppp=randperm(numel(ccc));
%             matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
%             ppp=randperm(numel(ccc));
%             matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
%         end
%         
%         
%         if protorg(10)>0
%             inER=round(copynumber*protorg(10)/100);
%             ccc=find(orgs==60);
%             rpp=floor(inER/numel(ccc));
%             matrixview(ccc)=matrixview(ccc)+rpp;
%             rpp=(inER-numel(ccc)*floor(inER/numel(ccc)));
%             ppp=randperm(numel(ccc));
%             matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
%             ppp=randperm(numel(ccc));
%             matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
%         end
%         
%         
%         if protorg(11)>0
%             inTGN=round(copynumber*protorg(11)/100);
%             ccc=find(orgs==60);
%             rpp=floor(inTGN/numel(ccc));
%             matrixview(ccc)=matrixview(ccc)+rpp;
%             rpp=(inTGN-numel(ccc)*floor(inTGN/numel(ccc)));
%             ppp=randperm(numel(ccc));
%             matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
%             ppp=randperm(numel(ccc));
%             matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
%         end
        
        
        %%copynumber=copynumber-inmit-inBDNF-inchromo-inrab11-inrab7-inrab5-inER-inTGN;
        
        
        %the protein distribution over the zones actually only matters for
        %membrane and cytosol
        %name_UID has the names for the distrib matrix
        distrib_row=find(strcmp(UID_list,UID));
        
        distrib=distribs(distrib_row,:);%distrib=distrib.^2; distrib=distrib*100/sum(distrib);
        %%%%%%%%ratios=(distrib./zonemeans).*empercs; ratios=ratios*100/sum(ratios); distrib=ratios;
        
        if protorg(2)>0
            inmem=round(copynumber*protorg(2)/100);
            nums=distrib*inmem/100;
            
            
            nums2=nums(10:12); nn=floor(sum(nums2)/13); nums(1:9)=nums(1:9)+nn; nums(13:15)=nums(13:15)+nn;
            
            for i=1:9
                ccc=find(zones==i & (orgs==2 |orgs==1)); %%% both AZ and Mem drawings, as the AZ is always drawn on the membrane
                num=round(nums(i));
                rpp=floor(num/numel(ccc));
                matrixview(ccc)=matrixview(ccc)+rpp;
                rpp=(num-numel(ccc)*floor(num/numel(ccc)));
                ppp=randperm(numel(ccc));
                matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
                ppp=randperm(numel(ccc));
                matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
            end
            
            for i=13:15
                ccc=find(zones==i & (orgs==2 |orgs==1)); %%% both AZ and Mem drawings, as the AZ is always drawn on the membrane
                num=round(nums(i));
                rpp=floor(num/numel(ccc));
                matrixview(ccc)=matrixview(ccc)+rpp;
                rpp=(num-numel(ccc)*floor(num/numel(ccc)));
                ppp=randperm(numel(ccc));
                matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
                ppp=randperm(numel(ccc));
                matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
            end
            
        end
        
        
        if protorg(4)>0
            incyt=round(copynumber*protorg(4)/100);
            nums=distrib*incyt/100;
            
            for i=1:15
                ccc=find(zones==i); %%% both AZ and Mem drawings, as the AZ is always drawn on the membrane
                num=round(nums(i));
                rpp=floor(num/numel(ccc));
                matrixview(ccc)=matrixview(ccc)+rpp;
                rpp=(num-numel(ccc)*floor(num/numel(ccc)));
                ppp=randperm(numel(ccc));
                matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
                ppp=randperm(numel(ccc));
                matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
            end
            
        end
        
        
        if draw_Model
            
            
            
            [stat, mess]=fileattrib('Z:\user\mhelm1\Electron Microscopy\spines\for_models\new tracings with mito\Mushroom_new with missing spine_after debugging script\*_for_ves_numbers.txt');
            mm=[];
            for i=1:numel(mess); a=dlmread(mess(i).Name); mm(i)=max(max(a));end
            dim=max(mm);
            
            
            for klm=1:7%numel(mess)
                matrix=zeros(dim,dim);
                a=dlmread(mess(klm).Name); a2=a;
                if klm==7
                    a(:,1)=a(:,1)-195; a(:,3)=a(:,3)-195; a(:,5)=a(:,5)-195; a(:,13)=a(:,13)-195; a(:,15)=a(:,15)-195;
                    a(:,2)=a(:,2)-220; a(:,4)=a(:,4)-220; a(:,6)=a(:,6)-220; a(:,14)=a(:,14)-220; a(:,16)=a(:,16)-220;
                    ccc=find(a<=0 & a2>0); a(ccc)=1;
                end
                
                
                azx=a(:,1);azy=a(:,2);ccc=find(azx>0);  if numel(ccc)>0; azx=azx(ccc); azy=azy(ccc); else azx=[]; azy=[]; end;
                %         if klm==1 | klm==3;
                %             memx=a(:,3); memy=a(:,4);ccc=find(memx>0 & memx<300);if numel(ccc)>0; memx=memx(ccc); memy=memy(ccc); else memx=[]; memy=[]; end;
                %         else
                memx=a(:,3); memy=a(:,4);ccc=find(memx>0);if numel(ccc)>0; memx=memx(ccc); memy=memy(ccc); else memx=[]; memy=[]; end;
                %         end
                
                %%%    vesx=a(:,5); vesy=a(:,6);ccc=find(vesx>0);if numel(ccc)>0; vesx=vesx(ccc); vesy=vesy(ccc); else vesx=[]; vesy=[]; end;
                vacx=a(:,13); vacy=a(:,14);ccc=find(vacx>0);if numel(ccc)>0; vacx=vacx(ccc); vacy=vacy(ccc); else vacx=[]; vacy=[]; end;
                mitx=a(:,15); mity=a(:,16);ccc=find(mitx>0);if numel(ccc)>0; mitx=mitx(ccc); mity=mity(ccc); else mitx=[]; mity=[]; end;
                
                if numel(azx)>0;  for j=1:numel(azx); matrix(azx(j),azy(j))=1; end; end;
                if numel(memx)>0; for j=1:numel(memx); matrix(memx(j),memy(j))=2; end; end;
                %%%   if numel(vesx)>0; disp('ves');for j=1:numel(vesx); matrix(vesx(j),vesy(j),klm)=3; end; end;
                if numel(vacx)>0;for j=1:numel(vacx); matrix(vacx(j),vacy(j))=4; end; end;
                if numel(mitx)>0;for j=1:numel(mitx); matrix(mitx(j),mity(j))=5; end; end;
                
                matrix=imrotate(matrix,35);
                
                %         for making videos include the following line
                % 		theta=90;
                %             tOrigOrganelles = [1 0 0; 0 1 0; -size(matrix,1)/2 -size(matrix,1)/2 1];
                %             tRotation = [cosd(theta) -sind(theta) 0; sind(theta) cosd(theta) 0; 0 0 1];
                %             tOrigOrganellesBack = [1 0 0; 0 1 0; size(matrix,1)/2 size(matrix,1)/2 1];
                %             tformCenteredRotationOrganelles = tOrigOrganelles*tRotation*tOrigOrganellesBack;
                %             tformOrganelles= affine2d(tformCenteredRotationOrganelles);
                %
                %             matrix=imwarp(matrix,tformOrganelles);
                %
                
                
                matrix=fliplr(matrix);
                
                siz=size(matrix);
                ccc=find(matrix==1);
                [azx azy]=ind2sub([siz(1) siz(2)],ccc);
                ccc=find(matrix==2);
                [memx memy]=ind2sub([siz(1) siz(2)],ccc);
                ccc=find(matrix==4);
                [vacx vacy]=ind2sub([siz(1) siz(2)],ccc);
                ccc=find(matrix==5);
                [mitx mity]=ind2sub([siz(1) siz(2)],ccc);
                
                
                
                
                
            end
            
            
            protimgidx=find(strcmp(protimgdir,[name{:} '.png']));
            
            [img,~,alphachannel]=imread(['Z:\user\mhelm1\Thesis\figures\Protein Averages\Semi3Dmodels\singleProteinImages_scaled_renamed' filesep protimgdir{protimgidx}]);
            
            prot=zeros(1500,1000,7.5*70);
            sizm=size(matrixview);
            for i=1:7
                for j=1:sizm(1)
                    for k=1:sizm(2)
                        if matrixview(j,k,i)>0
                            for l=1:matrixview(j,k,i)
                                try
                                    pos=randperm(35); pos=pos-15; pos2=randperm(70); pos2=pos2-35;
                                    prot(k*35+pos(2),1000-j*35+pos(1),i*70+pos2(1))=1;
                                catch
                                    continue
                                end
                                
                            end
                        end
                    end
                end
            end
            
            polygon=[235.043010752688 716.105095541401;283.430107526882 721.837579617834;334.505376344086 746.678343949045;373.483870967742 769.608280254777;384.236559139785 781.073248407644;420.52688172043 784.894904458599;472.94623655914 788.716560509554;494.451612903226 796.359872611465;554.935483870968 805.914012738853;580.47311827957 809.735668789809;600.634408602151 828.843949044586;628.860215053764 846.041401273886;654.397849462366 857.506369426752;690.688172043011 872.792993630573;720.258064516129 880.436305732484;755.204301075269 897.633757961783;780.741935483871 928.207006369427;796.870967741936 953.047770700637;822.408602150538 960.691082802548;843.913978494624 985.531847133758;856.010752688172 998.907643312102;874.827956989247 1033.3025477707;878.860215053764 1069.60828025478;872.139784946237 1096.35987261147;853.322580645161 1113.55732484076;811.655913978495 1125.02229299363;771.333333333333 1136.4872611465;731.010752688172 1149.86305732484;702.784946236559 1168.97133757962;674.559139784946 1172.79299363057;623.483870967742 1188.07961783439;599.290322580645 1203.36624203822;581.817204301075 1220.56369426752;585.849462365592 1239.67197452229;597.94623655914 1258.78025477707;611.387096774194 1281.7101910828;639.612903225807 1306.55095541401;666.494623655914 1327.57006369427;681.279569892473 1339.03503184713;700.096774193549 1346.67834394904;720.258064516129 1361.96496815287;735.043010752688 1371.51910828025;757.89247311828 1377.25159235669;782.086021505376 1386.80573248408;800.903225806452 1390.62738853503;825.096774193549 1392.53821656051;841.225806451613 1388.71656050955;869.451612903226 1373.42993630573;881.548387096774 1365.78662420382;890.956989247312 1352.41082802548;900.36559139785 1335.21337579618;908.430107526882 1321.83757961783;913.806451612903 1304.64012738854;928.591397849463 1283.62101910828;940.688172043011 1264.5127388535;951.440860215054 1237.76114649682;963.537634408602 1201.45541401274;968.913978494624 1182.34713375796;982.354838709678 1149.86305732484;989.075268817204 1136.4872611465;1019.98924731183 1096.35987261147;1033.43010752688 1086.80573248408;1050.90322580645 1065.78662420382;1076.44086021505 1044.76751592357;1091.22580645161 1029.48089171975;1107.35483870968 1018.01592356688;1135.58064516129 1008.46178343949;1165.15053763441 995.085987261147;1201.44086021505 981.710191082802;1248.48387096774 966.423566878981;1269.98924731183 954.958598726115;1306.27956989247 947.315286624204;1347.94623655914 939.671974522293;1390.95698924731 926.296178343949;1420.52688172043 926.296178343949;1458.16129032258 924.385350318471;1507.89247311828 924.385350318471;1525.36559139785 905.277070063694;1545.52688172043 889.990445859873;1589.88172043011 878.525477707006;1568.37634408602 811.646496815287;1476.97849462366 817.37898089172;1325.09677419355 859.417197452229;1279.39784946237 859.417197452229;1153.05376344086 851.773885350319;1049.55913978495 828.843949044586;1009.23655913979 805.914012738853;959.505376344086 788.716560509554;826.440860215054 779.162420382166;683.967741935484 769.608280254777;606.010752688172 754.321656050955;507.89247311828 748.589171974522;388.268817204301 739.035031847134;333.161290322581 706.550955414013;267.301075268817 695.085987261147;232.354838709677 689.353503184713];
            mask=poly2mask(polygon(:,1),polygon(:,2),1500,2000);
            mask=rot90(fliplr(mask));
            
            prot(2000,1500,1)=0;
            prot=noncircshift(prot, [158 664]);
            
            prot=prot.*mask;
            
            ccc=find(prot>0);
            [X,Y,Z]=ind2sub(size(prot),ccc);
            f1=figure('Visible','on');
            
            [spine_img,~,spine_alpha]=imread('Z:\user\mhelm1\Thesis\figures\EM\Reconstructions\mushroom_open_AZ_cut_top4.png');
            spine_img=imrotate(spine_img,180);
            spine_alpha=imrotate(spine_alpha,180);
            image(spine_img,'AlphaData',spine_alpha);
            hold on
            scale_factor=32;
            for i=1:numel(ccc)
                rotangle=randi(360);
                image([X(i)-scale_factor,X(i)+scale_factor],[Y(i)-scale_factor,Y(i)+scale_factor],imrotate(img,rotangle,'crop'),'AlphaData',imrotate(alphachannel,rotangle,'crop'));
            end
            hold off
            axis off
        end
        view(180,90)
       
        export_fig(['Z:\user\mhelm1\Thesis\figures\Protein Averages\Semi3Dmodels\' name{:}], '-transparent', '-CMYK', '-q101','-png','-native');
        close(f1)
    catch
        disp(['Error in protein ' name{:} '. Skipping it'])
        continue
    end
end



end






