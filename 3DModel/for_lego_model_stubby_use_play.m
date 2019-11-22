function for_lego_model_stubby_use_play(draw_Model)
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
cd(cd_path);
names={};
%
%Read in Allocation file
[~,~,allocation_raw]=xlsread('Z:\user\mhelm1\Nanomap_Analysis\Data\total\ProteinZoneAllocations.xlsx');
%dont need this anymore, as it is in the allocation cell
% [protorgs, textt]=xlsread('zone_distribution_from_images.xlsx','Sheet1','B2:L57');
[~,~,name_UID]=xlsread('zone_distribution_from_images.xlsx','names');
UID_list=name_UID(:,2);
%%%%%% (1)active zone  (2)membrane	(3)mitochondria (4)cytosol (5)BDNF/Rab3 (6)Chromo/Rab3 (7)Rab11/4 recycling
%%%%%% (8)Rab7 late	(9) Rab5/4 early	(10)ER (11)Rab9/TGN

[distribs, ~]=xlsread('zone_distribution_from_images.xlsx','sted_flat');

%read in copy number file
[~,~,copynum_raw]=xlsread('Z:\user\mhelm1\Subcellular Distribution Analysis\THE COPY NUMBER FILE_SE0.xlsx');
copynum_UID=copynum_raw(:,2);

%only show the proteins selected in the protein allocation file
ccc=find(cell2mat(allocation_raw(:,15)));
prot_list=ccc;

%Read in the organelle and zone identities.
cd ('Z:\user\mhelm1\Electron Microscopy\spines\for_models\for_model_3D_stumpy');
load('matrix_organelle_identities_plus_endosomes.mat');
orgs=matrix;

load('matrix_zone_identities.mat');
zones=matrix;
sizm=size(zones);



empercs=[0.0377	0.9043	2.3361	2.5622	1.8086	4.3708	9.7589	15.4484	18.9525	12.1703	31.6503];
%%%%% zonemeans from the surface distribution on zones on drawings
%%%%% zonemeans=[0.4386	3.5088	3.9474	2.6316	2.1930	4.8246	3.5088	3.5088	3.5088	2.1930	3.5088	1.7544	5.2632	11.8421	47.3684];

%%%%% zonemeans from the average distribution of signal on all STED images
zonemeans=mean(distribs);

if ~exist('Z:\user\mhelm1\Nanomap_Analysis\Data\total\_LegoModels\Flat','dir')
    mkdir('Z:\user\mhelm1\Nanomap_Analysis\Data\total\_LegoModels\Flat');
end


for abcdef=1:numel(prot_list)
    try
        UID=allocation_raw{prot_list(abcdef),2};
        name=allocation_raw(prot_list(abcdef),1);
        
        copynum_row=find(contains(copynum_UID,UID));
        copynumber=copynum_raw{copynum_row,24};
        
        if isnan(copynumber)
            if ~isnan(copynum_raw{copynum_row,20})
                disp(['No spine type corrected copy number availabe for protein ' name{:} ', UID ' UID '. Using the uncorrected one'])
                copynumber=copynum_raw{copynum_row,20};
            else
                copynumber=150;
                disp(['No Copynumber found for protein ' name{:} ', UID ' UID ' . Skippin it.'])
                continue
            end
        end
        
        
        % name=char(names(list(abcdef)));
        matrixview=zones-zones;
        
        protorg=cell2mat(allocation_raw(prot_list(abcdef),3:13));
        %since active zone proteins are mostly in the cytosol (Homer etc), they
        %are added to the cytosol definition and I remove the entry in
        %protorg(1) because it is never used and screws up the cumsum command
        %later
        protorg(4)=protorg(4)+protorg(1);
        protorg(1)=0;
        
        inmit=0; inBDNF=0; inchromo=0; inrab11=0; inrab7=0; inrab5=0; inER=0; inTGN=0; inmem=0;
        if protorg(3)>0;
            try
                inmit=round(copynumber*protorg(3)/100);
                ccc=find(orgs==5);  rpp=floor(inmit/numel(ccc));
                matrixview(ccc)=matrixview(ccc)+rpp;
                rpp=(inmit-numel(ccc)*floor(inmit/numel(ccc)));
                ppp=randperm(numel(ccc));
                matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
                ppp=randperm(numel(ccc));
                matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
            catch
                disp(['No Mitochondrion in Stumpy type synapses. Skipping protein ' name{:} ', UID ' UID '. Skipping it,'])
                continue
            end
        end
        
        
        if protorg(5)>0; inBDNF=round(copynumber*protorg(5)/100);
            ccc=find(orgs==10);
            rpp=floor(inBDNF/numel(ccc));
            matrixview(ccc)=matrixview(ccc)+rpp;
            rpp=(inBDNF-numel(ccc)*floor(inBDNF/numel(ccc)));
            ppp=randperm(numel(ccc));
            matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
            ppp=randperm(numel(ccc));
            matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
        end
        
        
        if protorg(6)>0; inchromo=round(copynumber*protorg(6)/100);
            ccc=find(orgs==20);  rpp=floor(inchromo/numel(ccc));
            matrixview(ccc)=matrixview(ccc)+rpp;
            rpp=(inchromo-numel(ccc)*floor(inchromo/numel(ccc)));
            ppp=randperm(numel(ccc));
            matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
            ppp=randperm(numel(ccc));
            matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
        end
        
        
        if protorg(7)>0; inrab11=round(copynumber*protorg(7)/100);
            ccc=find(orgs==30);  rpp=floor(inrab11/numel(ccc));
            matrixview(ccc)=matrixview(ccc)+rpp;
            rpp=(inrab11-numel(ccc)*floor(inrab11/numel(ccc)));
            ppp=randperm(numel(ccc));
            matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
            ppp=randperm(numel(ccc));
            matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
        end
        
        
        if protorg(8)>0; inrab7=round(copynumber*protorg(8)/100);
            ccc=find(orgs==40);  rpp=floor(inrab7/numel(ccc));
            matrixview(ccc)=matrixview(ccc)+rpp;
            rpp=(inrab7-numel(ccc)*floor(inrab7/numel(ccc)));
            ppp=randperm(numel(ccc));
            matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
            ppp=randperm(numel(ccc));
            matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
        end
        
        
        if protorg(9)>0; inrab5=round(copynumber*protorg(9)/100);
            ccc=find(orgs==50);  rpp=floor(inrab5/numel(ccc));
            matrixview(ccc)=matrixview(ccc)+rpp;
            rpp=(inrab5-numel(ccc)*floor(inrab5/numel(ccc)));
            ppp=randperm(numel(ccc));
            matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
            ppp=randperm(numel(ccc));
            matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
        end
        
        
        if protorg(10)>0; inER=round(copynumber*protorg(10)/100);
            ccc=find(orgs==60);  rpp=floor(inER/numel(ccc));
            matrixview(ccc)=matrixview(ccc)+rpp;
            rpp=(inER-numel(ccc)*floor(inER/numel(ccc)));
            ppp=randperm(numel(ccc));
            matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
            ppp=randperm(numel(ccc));
            matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
        end
        
        
        if protorg(11)>0; inTGN=round(copynumber*protorg(11)/100);
            ccc=find(orgs==70);  rpp=floor(inTGN/numel(ccc));
            matrixview(ccc)=matrixview(ccc)+rpp;
            rpp=(inTGN-numel(ccc)*floor(inTGN/numel(ccc)));
            ppp=randperm(numel(ccc));
            matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
            ppp=randperm(numel(ccc));
            matrixview(ccc(ppp(1:floor(rpp/2))))=matrixview(ccc(ppp(1:floor(rpp/2))))+1;
        end
        
        
        %the protein distribution over the zones actually only matters for
        %membrane and cytosol
        %name_UID has the names for the distrib matrix
        distrib_row=find(contains(UID_list,UID));
        distrib=distribs(distrib_row,:);
        
        %%%%%%%%ratios=(distrib./zonemeans).*empercs; ratios=ratios*100/sum(ratios); distrib=ratios;
        
        if protorg(2)>0
            inmem=round(copynumber*protorg(2)/100);
            nums=distrib*inmem/100;
            
            
            for i=1:11
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
            
            for i=1:11
                ccc=find(zones==i);
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
        
        %     Due to the rounding, there are sometimes a few protein copies
        %     missing. These are now distributed randomly on all organelles/zones
        %     that the protein is present in.
        a=cumsum(protorg);
        a(protorg==0)=0;
        while round(copynumber-sum(matrixview(:)))>0
            x_rand=randi(100);
            org_id=find(x_rand<=a,1,'first');
            
            switch org_id
                case 2
                    ccc=find(orgs==2);
                case 4
                    ccc=find(orgs==6);
                case 3
                    ccc=find(orgs==5);
                case 5
                    ccc=find(orgs==10);
                case 6
                    ccc=find(orgs==20);
                case 7
                    ccc=find(orgs==30);
                case 8
                    ccc=find(orgs==40);
                case 9
                    ccc=find(orgs==50);
                case 10
                    ccc=find(orgs==60);
                case 11
                    ccc=find(orgs==70);
            end
            ccc=ccc(randsample(length(ccc),1));
            matrixview(ccc)=matrixview(ccc)+1;
        end
        
        
        if draw_Model
            
            
            %figure; for i=1:sizm(3); subplot(3,3,i); imagesc(matrixview(:,:,i)); title(name); axis equal; end;
            
            %mm=matrixview(:,:,1)-matrixview(:,:,1);
            % for i=1:sizm(3); mm=mm+matrixview(:,:,i); end;
            % figure; imagesc(mm); colorbar; title(name); axis equal
            subplot(3,3,abcdef);
            
            [stat, mess]=fileattrib('Z:\user\mhelm1\Electron Microscopy\spines\for_models\for_model_3D_stumpy\*_for_ves_numbers.txt');
            mm=[];
            for i=1:numel(mess)
                a=dlmread(mess(i).Name);
                mm(i)=max(max(a));
            end
            dim=max(mm);
            
            for klm=1:numel(mess)
                matrix=zeros(dim,dim);
                a=dlmread(mess(klm).Name); a2=a;
                azx=a(:,1);azy=a(:,2);ccc=find(azx>0);  if numel(ccc)>0; azx=azx(ccc); azy=azy(ccc); else azx=[]; azy=[]; end;
                memx=a(:,3); memy=a(:,4);ccc=find(memx>0);if numel(ccc)>0; memx=memx(ccc); memy=memy(ccc); else memx=[]; memy=[]; end;
                %%%    vesx=a(:,5); vesy=a(:,6);ccc=find(vesx>0);if numel(ccc)>0; vesx=vesx(ccc); vesy=vesy(ccc); else vesx=[]; vesy=[]; end;
                vacx=a(:,13); vacy=a(:,14);ccc=find(vacx>0);if numel(ccc)>0; vacx=vacx(ccc); vacy=vacy(ccc); else vacx=[]; vacy=[]; end;
                mitx=a(:,15); mity=a(:,16);ccc=find(mitx>0);if numel(ccc)>0; mitx=mitx(ccc); mity=mity(ccc); else mitx=[]; mity=[]; end;
                
                if numel(azx)>0;  for j=1:numel(azx); matrix(azx(j),azy(j))=1; end; end;
                if numel(memx)>0; for j=1:numel(memx); matrix(memx(j),memy(j))=2; end; end;
                %%%   if numel(vesx)>0; disp('ves');for j=1:numel(vesx); matrix(vesx(j),vesy(j),klm)=3; end; end;
                if numel(vacx)>0;for j=1:numel(vacx); matrix(vacx(j),vacy(j))=4; end; end;
                if numel(mitx)>0;for j=1:numel(mitx); matrix(mitx(j),mity(j))=5; end; end;
                
                matrix=imrotate(matrix,35);
                
                siz=size(matrix);
                ccc=find(matrix==1);
                [azx azy]=ind2sub([siz(1) siz(2)],ccc);
                ccc=find(matrix==2);
                [memx memy]=ind2sub([siz(1) siz(2)],ccc);
                ccc=find(matrix==4);
                [vacx vacy]=ind2sub([siz(1) siz(2)],ccc);
                ccc=find(matrix==5);
                [mitx mity]=ind2sub([siz(1) siz(2)],ccc);
                
                for i=1:numel(memx)
                    line(round(memy(i)*3.181818)-19*35,1000-round(memx(i)*3.181818)+9*35,70*klm,'linestyle','none','marker','o','markeredgecolor','none','markerfacecolor','k','markersize',1);
                end
                
                for i=1:numel(azx)
                    line(round(azy(i)*3.181818)-19*35,1000-round(azx(i)*3.181818)+9*35,70*klm,'linestyle','none','marker','o','markeredgecolor','none','markerfacecolor','r','markersize',1);
                end
                for i=1:numel(mitx)
                    line(round(mity(i)*3.181818)-19*35,1000-round(mitx(i)*3.181818)+9*35,70*klm,'linestyle','none','marker','o','markeredgecolor','none','markerfacecolor','m','markersize',1);
                end
                for i=1:numel(vacx)
                    line(round(vacy(i)*3.181818)-19*35,1000-round(vacx(i)*3.181818)+9*35,70*klm,'linestyle','none','marker','o','markeredgecolor','none','markerfacecolor','c','markersize',1);
                end
            end
            
            
            
            title(name);
            xlim([0 1500]); ylim([0 1000]);zlim([0 800]);
            colors='rgbcmyk';
            pp1=randperm(numel(colors));
            pp2=randperm(numel(colors));
            for i=1:sizm(3)
                for j=1:sizm(1)
                    for k=1:sizm(2)
                        if matrixview(j,k,i)>0
                            for l=1:matrixview(j,k,i)
                                pos=randperm(30); pos=pos-15; pos2=randperm(70); pos2=pos2-35;
                                line(k*35+pos(2),1000-j*35+pos(1),i*70+pos2(1),'linestyle','none','marker','o','markersize',4,'markerfacecolor','b','markeredgecolor','none');
                                
                                %                     line(k*35+pos(2),1000-j*35+pos(1),i*70+pos2(1),'linestyle','none','marker','o','markerfacecolor',colors(abcdef),...
                                %                              'markeredgecolor',colors(abcdef),'markersize',3);
                                
                            end
                        end
                    end
                end
            end
            view(-6,4); drawnow
        end
        
        save([cd_path filesep '_LegoModels' filesep 'Flat' filesep name{:} '_flat_LegoModel.mat'],'matrixview')
        PSDDef=zones>0 & zones<4;
        PSDNum=sum(matrixview(PSDDef));
        copynum_raw{copynum_row,48}=PSDNum;
        copynum_raw{copynum_row,49}=PSDNum*copynum_raw{copynum_row,25}/copynum_raw{copynum_row,24};  %calculate the SEM based on the Flat spine copy number
        copynum_raw{copynum_row,52}=copynum_raw{copynum_row,48}/copynum_raw{copynum_row,24}*100;
        copynum_raw{copynum_row,53}=copynum_raw{copynum_row,52}*copynum_raw{copynum_row,24}/copynum_raw{copynum_row,24};
    catch
        disp(['Error in protein ' name{:} '. Skipping it'])
        continue
    end
end

xlswrite('Z:\user\mhelm1\Subcellular Distribution Analysis\THE COPY NUMBER FILE_SE0.xlsx',copynum_raw);
end



