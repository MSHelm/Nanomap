function for_lego_model_stubby_organelles
azx=[];azy=[];mx=[];my=[];cx=[];cy=[];pvesx=[];pvesy=[];uvesx=[];uvesy=[];dimensx=0;dimensy=0;mz=[];azz=[];cz=[];uvesz=[];pvesz=[];

cd('Z:\user\mhelm1\Electron Microscopy\spines\for_models\for_model_3D_stumpy');

% % pixel_size=3.067; % nm
% % dicke=70;
% % dicke=dicke/pixel_size;
% % % close all
% %
% % %$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
% % % Active zone - x = first column; y=second column
% % % Membrane - x = 3rd column; y=4th colum
% % % Normal vesicles - x = 5th column; y = 6th column
% % % dense-core vesicles - x = 7th column; y = 8th column [empty for now, as we have not seen any]
% % % Normal vesicles, distance to the active zone = 9th column - not useful for 3D
% % % Normal vesicles, distance to the membrane = 10th column - not useful for 3D
% % % dense-core vesicles, distance to the active zone = 11th column - not useful for 3D
% % % dense-core vesicles, distance to the membrane = 12th column - not useful for 3D
% % % Vacuoles - x = 13th column; y=14th column
% % % Mitochondria - x = 15th column; y=16th column
% % % The vacuole separators (index number) are in column 17 [for all the x
% % % and y values of the first vacuole (in columns 13 and 14) this column will have ones in the
% % % respective positions; for the second vacuole in the particular image there will be twos, etc.
% % % The mitochondria separators (index number) are in column 18 - same as for vacuoles
% % % Column 19 does nothing  note that all columns are padded with zeros
% % % all values are in pixels - and pixel size is 3.067 nm
% % % the distance between sections, or in other words the section thickness, is 70 nm (approximately, of course)
% % % we expect that the structures shrunk by ~20% versus the original situation
% % figure;
[~, mess]=fileattrib('*_for_ves_numbers.txt');
mm=[];
% find maximum pixel coordinate for each images. Here not really necessary
% as all images have the same size. This is only necessary for the mushroom
% model
for i=1:numel(mess); a=dlmread(mess(i).Name); mm(i)=max(max(a));end
dim=max(mm);
matrix=zeros(dim,dim,numel(mess));
matrix2=[];
% look at the individual images.
for klm=1:numel(mess)
    a=dlmread(mess(klm).Name); a2=a;
    
    % for all interesting zones only take the entries, were there are actual tracings.
    azx=a(:,1);azy=a(:,2);ccc=find(azx>0);  if numel(ccc)>0; azx=azx(ccc); azy=azy(ccc); else azx=[]; azy=[]; end;
    memx=a(:,3); memy=a(:,4);ccc=find(memx>0);if numel(ccc)>0; memx=memx(ccc); memy=memy(ccc); else memx=[]; memy=[]; end;
    vesx=a(:,5); vesy=a(:,6);ccc=find(vesx>0);if numel(ccc)>0; vesx=vesx(ccc); vesy=vesy(ccc); else vesx=[]; vesy=[]; end;
    vacx=a(:,13); vacy=a(:,14);ccc=find(vacx>0);if numel(ccc)>0; vacx=vacx(ccc); vacy=vacy(ccc); else vacx=[]; vacy=[]; end;
    mitx=a(:,15); mity=a(:,16);ccc=find(mitx>0);if numel(ccc)>0; mitx=mitx(ccc); mity=mity(ccc); else mitx=[]; mity=[]; end;
    
    %  write the tracings to the matrix file. 1: AZ, 2= Membrane, 3:
    % vesicles, 4= vacuoles, 5= mitochondria
    if numel(azx)>0; disp('AZ'); for j=1:numel(azx); matrix(azx(j),azy(j),klm)=1; end; end
    if numel(memx)>0; disp('mem');for j=1:numel(memx); matrix(memx(j),memy(j),klm)=2; end; end
    if numel(vesx)>0; disp('ves');for j=1:numel(vesx); matrix(vesx(j),vesy(j),klm)=3; end; end
    if numel(vacx)>0;disp('vac'); for j=1:numel(vacx); matrix(vacx(j),vacy(j),klm)=4; end; end
    if numel(mitx)>0;disp('mit'); for j=1:numel(mitx); matrix(mitx(j),mity(j),klm)=5; end; end
    
    % also create the cytosol from the membrane, basically anything inside
    % membrane will be defined as cytosol.
    mmm=matrix(:,:,klm); ppp=roipoly(mmm,memy,memx); ccc=find(ppp==1 & mmm==0); mmm(ccc)=6;
    %  rotate to have the spine nicely aligned sticking out to the top.
    mmm=imrotate(mmm,35);
    
    matrix2(:,:,klm)=mmm;
    %figure; imagesc(matrix2(:,:,klm))
    
end



matrix=matrix2;

sizm=size(matrix); matrix2=zeros(floor(sizm(1)/11),floor(sizm(2)/11),sizm(3));

% We need to resize the EM matrix to make it match the STED pictures.
for i=1:sizm(3)
    for j=1:floor(sizm(1)/11)
        for k=1:floor(sizm(2)/11)
            % go through the matrix in 11x11 "windows" that we slide over the EM
            % data matrix.
            pp=matrix(11*(j-1)+1:11*j,11*(k-1)+1:11*k,i);
            mms=[];
            %for each tracing identity find the number of traced pixels there.
            ccc=find(pp==1); mms(1)=numel(ccc);ccc=find(pp==2); mms(2)=numel(ccc);ccc=find(pp==3); mms(3)=numel(ccc);
            ccc=find(pp==4); mms(4)=numel(ccc); ccc=find(pp==5); mms(5)=numel(ccc);ccc=find(pp==6); mms(6)=numel(ccc);
            
            %  now define the identity in the matrix that matches the fluorescence
            % data. The priority is defined by the order in which they appear here.
            % Meaning that AZ>vesicle>vacuole>mitochondria>membrane>Cytosol
            if mms(1)>0; matrix2(j,k,i)=1;
            elseif mms(3)>0; matrix2(j,k,i)=3;
            elseif mms(4)>0; matrix2(j,k,i)=4;
            elseif mms(5)>0; matrix2(j,k,i)=5;
            elseif mms(2)>0; matrix2(j,k,i)=2;
            elseif mms(6)>0; matrix2(j,k,i)=6;
            end
        end
    end
    
    %
end
% cut out only the relevant part of the matrix. the rest is empty.
matrix3=[];
for i=1:sizm(3)
    matrix3(:,:,i)=matrix2(10:60,20:70,i);
    %      subplot(3,3,i); imagesc(matrix3(:,:,i)) ; axis equal
end

 save('matrix3.mat','matrix3')
%%% end of previously outcommented section


load matrix3.mat
matrix=matrix3;
save('matrix_organelle_identities.mat','matrix');

%Manually define the vacuole identities to the different endosomal
%identities that Silvio chose. The top is always just used as a mask, which
%is then used to find the correct vacuole. The vacuole identities are then
%changed from 4 to 10,20,30... which correspond to the different types
top=matrix3(:,:,1)-matrix3(:,:,1); top(:,1:20)=1;
ccc=find(matrix3(:,:,1)==4 & top==1); mm=matrix3(:,:,1); mm(ccc)=10; matrix3(:,:,1)=mm; %%% BDNF/Rab3 vesicle

top=matrix3(:,:,1)-matrix3(:,:,1);top(:,1:16)=1;
ccc=find(matrix3(:,:,2)==4 & top==1); mm=matrix3(:,:,2); mm(ccc)=20; matrix3(:,:,2)=mm; %%% Chromogranin/Rab3 vesicle

ccc=find(matrix3(:,:,4)==4); mm=matrix3(:,:,4); mm(ccc)=30; matrix3(:,:,4)=mm; %%% Rab11/4 recycling endosome
ccc=find(matrix3(:,:,5)==4); mm=matrix3(:,:,5); mm(ccc)=30; matrix3(:,:,5)=mm; %%% Rab11/4 recycling endosome

top=matrix3(:,:,1)-matrix3(:,:,1);top(1:24,25:35)=1;
ccc=find(matrix3(:,:,1)==4 & top==1); mm=matrix3(:,:,1); mm(ccc)=40; matrix3(:,:,1)=mm; %%% Rab7 late endosome

ccc=find(matrix3(:,:,6)==4); mm=matrix3(:,:,6); mm(ccc)=50; matrix3(:,:,6)=mm; %%% Rab5/4 early endosome

top=matrix3(:,:,1)-matrix3(:,:,1);top(1:18,1:25)=1;
ccc=find(matrix3(:,:,2)==4 & top==1); mm=matrix3(:,:,2); mm(ccc)=70; matrix3(:,:,2)=mm; %%% Rab9/TGN
%everything that we did not set to a specific vacuole identity we set to
%ER=identifier 60
ccc=find(matrix3==4); matrix3(ccc)=60; %%%% ER

matrix=matrix3;

% Modification by Martin: we should set all pixels, that are enclosed in
% endosomes to 0 (i.e. extracellular space) and not to 6 (cytosol). I do
% this here
matrix(20,17,1)=0;
matrix(21,16,1)=10; %to close the vesicle
matrix(28,26,1)=0;

matrix(23,15,2)=0;
matrix(30,21:22,2)=0;
matrix(22,29,2)=0;

matrix(30,22,3)=0;


save('matrix_organelle_identities_plus_endosomes.mat','matrix');
figure
sizm=size(matrix);
for i=1:sizm(3)
    matrix(1,1,i)=70; %%% This pixel is probably only set to 70 so that we get the same scaling in all slices, independent of which vacuole identies are actually present...
    subplot(3,3,i);
    imagesc(matrix(:,:,i));
    axis equal;
end


mm=[];
%find all the different vacuole identities and show their total size in 3D in number of
%pixels
for i=1:7
    ccc=find(matrix==i*10);
    mm(i)=numel(ccc);
end
mm'
mm=[];
%find all the other basic identities like AZ, membrane and show their total size in 3D in number of
%pixels
for i=1:6
    ccc=find(matrix==i);
    mm(i)=numel(ccc);
end
mm'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% for zone identities
sizm=size(matrix3);

matrix4=matrix3-matrix3;

%%%% region 1 = Homer center
matrix4(21,22,5)=1;
%%%% region 2 = Homer central area
ccc=find(matrix3==1 & matrix4==0); matrix4(ccc)=2;

%%%% region 3 = around Homer central area
top=matrix3(:,:,1)-matrix3(:,:,1); top(16:20,:)=1;
ccc=find(matrix3(:,:,4)==1 & top==0); mm=matrix4(:,:,4); mm(ccc)=3; matrix4(:,:,4)=mm;
top=matrix3(:,:,1)-matrix3(:,:,1); top(18:22,:)=1;
ccc=find(matrix3(:,:,5)==1 & top==0); mm=matrix4(:,:,5); mm(ccc)=3; matrix4(:,:,5)=mm;
top=matrix3(:,:,1)-matrix3(:,:,1); top(21:23,:)=1;
ccc=find(matrix3(:,:,6)==1 & top==0); mm=matrix4(:,:,6); mm(ccc)=3; matrix4(:,:,6)=mm;

for i=1:sizm(3);
    ccc=find(matrix3(:,:,i)==1); if numel(ccc)>0; mm=matrix3(:,:,1)-matrix3(:,:,1); mm(ccc)=1;
        mm=imdilate(mm,strel('disk',1)); ccc=find(mm>0 & matrix4(:,:,i)==0 & (matrix3(:,:,i)==2 | matrix3(:,:,i)==6 | matrix3(:,:,i)==4));
        mm=matrix4(:,:,i); mm(ccc)=3; matrix4(:,:,i)=mm;
    end;
end
top=matrix3(:,:,1)-matrix3(:,:,1); top(20:21,23:24)=1;
ccc=find(matrix3(:,:,7)>0 & top>0); mm=matrix4(:,:,7); mm(ccc)=3; matrix4(:,:,7)=mm;
ccc=find(matrix4(:,:,4)>0 & matrix3(:,:,3)>0); mm=matrix4(:,:,3); mm(ccc)=1; mm=imerode(mm,strel('disk',1));
matrix4(:,:,3)=mm*3;

%%%% region 4 = wider Homer around area
matrix4(25:28,19:20,6)=4;

ccc=find(matrix4(:,:,3)>0 & matrix3(:,:,2)>0); mm=matrix4(:,:,2); mm(ccc)=4;mm=imerode(mm,strel('disk',1));  matrix4(:,:,2)=mm;
for i=1:sizm(3);
    ccc=find(matrix4(:,:,i)>0); if numel(ccc)>0; mm=matrix3(:,:,1)-matrix3(:,:,1); mm(ccc)=1;
        mm=imdilate(mm,strel('disk',1)); ccc=find(mm>0 & matrix4(:,:,i)==0 & (matrix3(:,:,i)==2 | matrix3(:,:,i)==6 | matrix3(:,:,i)==4));
        mm=matrix4(:,:,i); mm(ccc)=4; matrix4(:,:,i)=mm;
    end;
end


%%%% region 5 = wider Homer around area
matrix4(25:29,19,6)=5; matrix4(28,20:21,6)=5; matrix4(29,20,6)=5;
ccc=find(matrix4(:,:,2)>0 & matrix3(:,:,1)>0); mm=matrix4(:,:,1); mm(ccc)=5; mm=imerode(mm,strel('disk',1));matrix4(:,:,1)=mm;

for i=4:6%sizm(3);
    ccc=find(matrix4(:,:,i)>0); if numel(ccc)>0; mm=matrix3(:,:,1)-matrix3(:,:,1); mm(ccc)=1;
        mm=imdilate(mm,strel('disk',1)); ccc=find(mm>0 & matrix4(:,:,i)==0 & (matrix3(:,:,i)==2 | matrix3(:,:,i)==6 | matrix3(:,:,i)==4));
        mm=matrix4(:,:,i); mm(ccc)=5; matrix4(:,:,i)=mm;
    end;
end



%%%% region 6 = further around Homer area (further around AZ)
matrix4(29,19:21,6)=6; matrix4(30,19:20,6)=6; matrix4(11,27,4)=6; matrix4(12,28,4)=6;
matrix4(19:20,21:22,2)=6; matrix4(20,23:24,2)=6; matrix4(19,21:22,1)=6;
for i=1:sizm(3);
    ccc=find(matrix4(:,:,i)>0); if numel(ccc)>0; mm=matrix3(:,:,1)-matrix3(:,:,1); mm(ccc)=1;
        mm=imdilate(mm,strel('disk',1)); ccc=find(mm>0 & matrix4(:,:,i)==0 & (matrix3(:,:,i)==2 | matrix3(:,:,i)==6 | matrix3(:,:,i)==4));
        mm=matrix4(:,:,i); mm(ccc)=6; matrix4(:,:,i)=mm;
    end;
end

%%%% region 7 = further around Homer area (further around AZ)
for i=1:sizm(3);
    ccc=find(matrix4(:,:,i)>0); if numel(ccc)>0; mm=matrix3(:,:,1)-matrix3(:,:,1); mm(ccc)=1;
        mm=imdilate(mm,strel('disk',2)); ccc=find(mm>0 & matrix4(:,:,i)==0 & (matrix3(:,:,i)==2 | matrix3(:,:,i)==6 | matrix3(:,:,i)==4));
        mm=matrix4(:,:,i); mm(ccc)=7; matrix4(:,:,i)=mm;
    end;
end

for i=5:5;
    ccc=find(matrix4(:,:,i)>0); if numel(ccc)>0; mm=matrix3(:,:,1)-matrix3(:,:,1); mm(ccc)=1;
        mm=imdilate(mm,strel('disk',1)); ccc=find(mm>0 & matrix4(:,:,i)==0 & (matrix3(:,:,i)==2 | matrix3(:,:,i)==6 | matrix3(:,:,i)==4));
        mm=matrix4(:,:,i); mm(ccc)=7; matrix4(:,:,i)=mm;
    end;
end

%%%% region 8 = further around Homer area (further around AZ)
for i=2:6%sizm(3);
    ccc=find(matrix4(:,:,i)>0); if numel(ccc)>0; mm=matrix3(:,:,1)-matrix3(:,:,1); mm(ccc)=1;
        mm=imdilate(mm,strel('disk',3)); ccc=find(mm>0 & matrix4(:,:,i)==0 & (matrix3(:,:,i)==2 | matrix3(:,:,i)==6 | matrix3(:,:,i)==4));
        mm=matrix4(:,:,i); mm(ccc)=8; matrix4(:,:,i)=mm;
    end;
end

for i=1:1%sizm(3);
    ccc=find(matrix4(:,:,i)>0); if numel(ccc)>0; mm=matrix3(:,:,1)-matrix3(:,:,1); mm(ccc)=1;
        mm=imdilate(mm,strel('disk',1)); ccc=find(mm>0 & matrix4(:,:,i)==0 & (matrix3(:,:,i)==2 | matrix3(:,:,i)==6 | matrix3(:,:,i)==4));
        mm=matrix4(:,:,i); mm(ccc)=8; matrix4(:,:,i)=mm;
    end;
end
for i=7:7%sizm(3);
    ccc=find(matrix4(:,:,i)>0); if numel(ccc)>0; mm=matrix3(:,:,1)-matrix3(:,:,1); mm(ccc)=1;
        mm=imdilate(mm,strel('disk',2)); ccc=find(mm>0 & matrix4(:,:,i)==0 & (matrix3(:,:,i)==2 | matrix3(:,:,i)==6 | matrix3(:,:,i)==4));
        mm=matrix4(:,:,i); mm(ccc)=8; matrix4(:,:,i)=mm;
    end;
end


%%%% region 9 = again further around Homer area (further around AZ)
for i=3:sizm(3);
    ccc=find(matrix4(:,:,i)>0); if numel(ccc)>0; mm=matrix3(:,:,1)-matrix3(:,:,1); mm(ccc)=1;
        mm=imdilate(mm,strel('disk',5)); ccc=find(mm>0 & matrix4(:,:,i)==0 & (matrix3(:,:,i)==2 | matrix3(:,:,i)==6 | matrix3(:,:,i)==4));
        mm=matrix4(:,:,i); mm(ccc)=9; matrix4(:,:,i)=mm;
    end
end

for i=1:1%sizm(3);
    ccc=find(matrix4(:,:,i)>0); if numel(ccc)>0; mm=matrix3(:,:,1)-matrix3(:,:,1); mm(ccc)=1;
        mm=imdilate(mm,strel('disk',4)); ccc=find(mm>0 & matrix4(:,:,i)==0 & (matrix3(:,:,i)==2 | matrix3(:,:,i)==6 | matrix3(:,:,i)==4));
        mm=matrix4(:,:,i); mm(ccc)=9; matrix4(:,:,i)=mm;
    end
end


for i=1:1%sizm(3);
    ccc=find(matrix4(:,:,i)>0); if numel(ccc)>0; mm=matrix3(:,:,1)-matrix3(:,:,1); mm(ccc)=1;
        mm=imdilate(mm,strel('disk',4)); ccc=find(mm>0 & matrix4(:,:,i)==0 & (matrix3(:,:,i)==2 | matrix3(:,:,i)==6 | matrix3(:,:,i)==4));
        mm=matrix4(:,:,i); mm(ccc)=9; matrix4(:,:,i)=mm;
    end
end

%               top=matrix3(:,:,1)-matrix3(:,:,1); top(1:37,:)=1;
%        ccc=find(matrix3(:,:,3)>0 & top==0); mm=matrix4(:,:,3); mm(ccc)=9; matrix4(:,:,3)=mm;
%

%%%% region 10 = again further around Homer area (further around %%%% AZ)
for i=1:2%sizm(3);
    ccc=find(matrix4(:,:,i)>0); if numel(ccc)>0; mm=matrix3(:,:,1)-matrix3(:,:,1); mm(ccc)=1;
        mm=imdilate(mm,strel('disk',3)); ccc=find(mm>0 & matrix4(:,:,i)==0 & (matrix3(:,:,i)==2 | matrix3(:,:,i)==6 | matrix3(:,:,i)==4));
        mm=matrix4(:,:,i); mm(ccc)=10; matrix4(:,:,i)=mm;
    end
end


for i=3:sizm(3);
    ccc=find(matrix4(:,:,i)>0); if numel(ccc)>0; mm=matrix3(:,:,1)-matrix3(:,:,1); mm(ccc)=1;
        mm=imdilate(mm,strel('disk',4)); ccc=find(mm>0 & matrix4(:,:,i)==0 & (matrix3(:,:,i)==2 | matrix3(:,:,i)==6 | matrix3(:,:,i)==4));
        mm=matrix4(:,:,i); mm(ccc)=10; matrix4(:,:,i)=mm;
    end
end

%%%% region 11 = again further around Homer area (further around %%%% AZ)
for i=1:sizm(3);
    ccc=find(matrix4(:,:,i)>0); if numel(ccc)>0; mm=matrix3(:,:,1)-matrix3(:,:,1); mm(ccc)=1;
        mm=imdilate(mm,strel('disk',20)); ccc=find(mm>0 & matrix4(:,:,i)==0 & (matrix3(:,:,i)==2 | matrix3(:,:,i)==6 | matrix3(:,:,i)==4));
        mm=matrix4(:,:,i); mm(ccc)=11; matrix4(:,:,i)=mm;
    end
end

%also remove the above pixels from the zone identies
matrix4(20,17,1)=0;
matrix4(21,16,1)=0; %to close the vesicle
matrix4(28,26,1)=0;
matrix4(23,15,2)=0;
matrix4(30,21:22,2)=0;
matrix4(22,29,2)=0;
matrix4(30,22,3)=0;



matrix=matrix4;
save('matrix_zone_identities.mat','matrix');


figure;

for i=1:sizm(3);
    matrix4(1,1,i)=11;
    subplot(3,3,i); imagesc(matrix4(:,:,i)) ; axis equal; end
mm=[];  for i=1:11; ccc=find(matrix4==i); mm(i)=numel(ccc); end; mm'

mm'*100/sum(mm)

figure
for i=1:sizm(3);
    ccc=find(matrix3(:,:,i)>0 & matrix4(:,:,i)==0);
    
    mm=matrix3(:,:,1)-matrix3(:,:,1); mm(ccc)=1; subplot(3,3,i); imagesc(mm); end



    