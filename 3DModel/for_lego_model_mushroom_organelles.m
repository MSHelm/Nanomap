function for_lego_model_mushroom_organelles
azx=[];azy=[];mx=[];my=[];cx=[];cy=[];pvesx=[];pvesy=[];uvesx=[];uvesy=[];dimensx=0;dimensy=0;mz=[];azz=[];cz=[];uvesz=[];pvesz=[];

cd ('Z:\user\mhelm1\Nanomap_Analysis\Electron Microscopy\for_models\new tracings with mito\Mushroom_new with missing spine_after debugging script');

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
% find maximum pixel coordinate for each images. Necessary because layer7 has a different image size than all the others. Use this to construct a 3D
% zero matrix
for i=1:numel(mess); a=dlmread(mess(i).Name); mm(i)=max(max(a));end
dim=max(mm);
matrix=zeros(dim,dim,numel(mess));
matrix2=[];
% look at the individual images. Fix layer 7 position, because this is a
% much larger image, as it was forgotten initially and we dont have the
% same cut out mask as for all the others.
for klm=1:numel(mess)
    a=dlmread(mess(klm).Name); a2=a;
    if klm==7
        a(:,1)=a(:,1)-195; a(:,3)=a(:,3)-195; a(:,5)=a(:,5)-195; a(:,13)=a(:,13)-195; a(:,15)=a(:,15)-195;
        a(:,2)=a(:,2)-220; a(:,4)=a(:,4)-220; a(:,6)=a(:,6)-220; a(:,14)=a(:,14)-220; a(:,16)=a(:,16)-220;
        ccc=find(a<=0 & a2>0); a(ccc)=1;
    end
    
    
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
    
    %     layers 1,2,3,9 need special treatment, as they have a head that is
    %     separated fromt he shaft membrane. I need to define the cytosol for
    %     each structure individually here, because otherwise roipoly messes up
    mmm=matrix(:,:,klm);
    if (klm==9) || (klm==3) || (klm==2) || (klm==1)
        head=zeros(size(mmm));
        shaft=zeros(size(mmm));
        for i=1:numel(memx)
            %head is always below this linear separator function
            if memx(i) < 40+0.6*memy(i)
                head(memx(i),memy(i))=2;
            else
                shaft(memx(i),memy(i))=2;
            end
        end
%         find cytosol in head. Can be done with imfill since the head is a
%         close structure
        head=imfill(head);
        ccc=find(head>0 & mmm==0);
        mmm(ccc)=6;
        
%         find cytosol in shaft. need to use polygon here as it is not
%         necessarily a closed structure
        shaft_mem=find(shaft);
        [shaft_x, shaft_y]=ind2sub(size(shaft),shaft_mem);
        ppp=roipoly(shaft,shaft_y,shaft_x);
        ccc=find(ppp==1 & mmm==0);
        mmm(ccc)=6;    
    else
%         All the other spines, that have a head connected to shaft
        ppp=roipoly(mmm,memy,memx); ccc=find(ppp==1 & mmm==0); mmm(ccc)=6;

    end

    %  rotate to have the spine nicely aligned sticking out to the top.
    mmm=imrotate(mmm,35);
    
    matrix2(:,:,klm)=mmm;
    %figure; imagesc(matrix2(:,:,klm))
    
end



matrix=matrix2;

sizm=size(matrix); matrix2=zeros(floor(sizm(1)/11),floor(sizm(2)/11),sizm(3));

% We need to resize the EM matrix to make it match the STED pictures. The
% factor 11 is chosen, because it makes a z volume of ~33 nm, if we take
% that twice it closely resembles the 70 nm slices from the EM.
% It doesnt matter that it doest not correlate to a 20 nm lateral pixel
% size as in the fluorescence data, as we dont need a 1 to 1 correlation of
% fluorescence to EM data. By saying which pixels from EM and fluorescence
% belong to each other we circumvent this problem.
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
for i=1:sizm(3);
    matrix3(:,:,i)=matrix2(28:68,20:60,i);
    %the vacuoles labeled in layer 3 are much further down than any of the
    %analyzed structures in the other spines. Therefore cut them out, resp
    %set it to cytosol where it protrudes into the area that is also
    %analyzed by the other layers.
    if i==3; 
        matrix3(26:40,:,3)=0;
        matrix3(23:25,20:22,3)=6;
%         matrix3(26,5:36)=6;
%         matrix3(20:40,:,3)=0;
    end;
    if i==7; mm=matrix3(:,:,7);mm2=mm-mm+1; mm2(1:24,:)=0;
        ccc=find(mm==6 & mm2==1); mm(ccc)=0;
        ccc=find(mm==2 & mm2==1); mm(ccc)=0;
        matrix3(:,:,7)=mm;
    end
    %subplot(3,3,i); imagesc(matrix3(:,:,i)) ; axis equal
end;

%Here Silviomanually previously manually defined layer9 because it was not
%traced in the data, because of his script bug.
% matrix3(1:18,:,9)=matrix3(1:18,:,8);
% mm=matrix3(:,:,9);
% mm1=mm;mm1(20:41,:)=0;  mm(1:20,:)=0;
% ccc=find(mm1>0); mm1(ccc)=1; mm1=imerode(mm1,strel('disk',2));
% ccc=find(mm1>0); mm(ccc)=6; mm2=imdilate(mm1,strel('disk',1)); ccc=find(mm2==1 & mm1==0); mm(ccc)=2;
% matrix3(:,:,9)=mm;


save('matrix3.mat','matrix3')
%%% end of previously outcommented section


load matrix3.mat
matrix=matrix3;
save('matrix_organelle_identities.mat','matrix');



%Manually define the vacuole identities to the different endosomal
%identities that Silvio chose. The top is always just used as a mask, which
%is then used to find the correct vacuole. The vacuole identities are then
%changed from 4 to 10,20,30... which correspond to the different types
top=matrix3(:,:,1)-matrix3(:,:,1);top(24:27,7:10)=1;
ccc=find(matrix3(:,:,6)==4 & top==1); mm=matrix3(:,:,6); mm(ccc)=10; matrix3(:,:,6)=mm; %%% BDNF/Rab3 vesicle
top=matrix3(:,:,1)-matrix3(:,:,1);top(22:23,4:7)=1;
ccc=find(matrix3(:,:,5)==4 & top==1); mm=matrix3(:,:,5); mm(ccc)=10; matrix3(:,:,5)=mm; %%% BDNF/Rab3 vesicle


top=matrix3(:,:,1)-matrix3(:,:,1);top(20:26,28:32)=1;
ccc=find(matrix3(:,:,7)==4 & top==1); mm=matrix3(:,:,7); mm(ccc)=20; matrix3(:,:,7)=mm; %%% Chromogranin/Rab3 vesicle


top=matrix3(:,:,1)-matrix3(:,:,1);top(24:25,23:26)=1;
ccc=find(matrix3(:,:,5)==4 & top==1); mm=matrix3(:,:,5); mm(ccc)=30; matrix3(:,:,5)=mm; %%% Rab11/4 recycling endosome
top=matrix3(:,:,1)-matrix3(:,:,1);top(19:26,20:26)=1;
ccc=find(matrix3(:,:,6)==4 & top==1); mm=matrix3(:,:,6); mm(ccc)=30; matrix3(:,:,6)=mm; %%% Rab11/4 recycling endosome


top=matrix3(:,:,1)-matrix3(:,:,1);top(27:28,35:37)=1;
ccc=find(matrix3(:,:,5)==4 & top==1); mm=matrix3(:,:,5); mm(ccc)=40; matrix3(:,:,5)=mm; %%% Rab7 late endosome
top=matrix3(:,:,1)-matrix3(:,:,1);top(26:28,32:37)=1;
ccc=find(matrix3(:,:,6)==4 & top==1); mm=matrix3(:,:,6); mm(ccc)=40; matrix3(:,:,6)=mm; %%% Rab7 late endosome


ccc=find(matrix3(:,:,3)==4); mm=matrix3(:,:,3); mm(ccc)=50; matrix3(:,:,3)=mm;         %%% Rab5/4 early endosome
top=matrix3(:,:,1)-matrix3(:,:,1);top(20:26,15:25)=1;                                  %%% Rab5/4 early endosome
ccc=find(matrix3(:,:,4)==4 & top==1); mm=matrix3(:,:,4); mm(ccc)=50; matrix3(:,:,4)=mm;%%% Rab5/4 early endosome
top=matrix3(:,:,1)-matrix3(:,:,1);top(20:26,18:22)=1;                                  %%% Rab5/4 early endosome
ccc=find(matrix3(:,:,8)==4 & top==1); mm=matrix3(:,:,8); mm(ccc)=50; matrix3(:,:,8)=mm;%%% Rab5/4 early endosome


top=matrix3(:,:,1)-matrix3(:,:,1);top(22:24,8:12)=1;
ccc=find(matrix3(:,:,5)==4 & top==1); mm=matrix3(:,:,5); mm(ccc)=70; matrix3(:,:,5)=mm; %%% Rab9/TGN
top=matrix3(:,:,1)-matrix3(:,:,1);top(23:24,11:14)=1;
ccc=find(matrix3(:,:,6)==4 & top==1); mm=matrix3(:,:,6); mm(ccc)=70; matrix3(:,:,6)=mm; %%% Rab9/TGN


ccc=find(matrix3==4); matrix3(ccc)=60; %%%% ER

matrix=matrix3;
save('matrix_organelle_identities_plus_endosomes.mat','matrix');


figure
sizm=size(matrix);
for i=1:sizm(3)
    matrix(1,1,i)=70; %%% This pixel is probably only set to 70 so that we get the same scaling in all slices, independent of which vacuole identies are actually present...
    subplot(3,3,i);
    imagesc(matrix(:,:,i));
    axis equal;
end

%Some visualizing things
%{
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
%}

%%%% for zone identities
% it is basically manually pinpointing to certain regions and giving them
% the identifiers.
sizm=size(matrix3);

matrix4=matrix3-matrix3;
%%%% region 1 = Homer center
matrix4(13,19,5)=1;

%%%% region 2 = Homer central area
%%% its everything that is traced as Active zone in EM, but not the
%%% central pixel defined as zone 1
ccc=find(matrix3==1 & matrix4==0); matrix4(ccc)=2;

%%%% region 3 = around Homer central area
matrix4(12,17,3)=3; matrix4(13,21,3)=3; matrix4(12,17:18,6)=3; matrix4(14,21,5)=3; matrix4(14,22,4)=3;

for i=1:sizm(3)
    ccc=find(matrix3(:,:,i)==1);
    if numel(ccc)>0
        mm=matrix3(:,:,1)-matrix3(:,:,1);
        mm(ccc)=1;
        mm=imdilate(mm,strel('disk',1));
        ccc=find(mm>0 & matrix4(:,:,i)==0 & (matrix3(:,:,i)==2 | matrix3(:,:,i)==6 | matrix3(:,:,i)==4));
        mm=matrix4(:,:,i);
        mm(ccc)=3;
        matrix4(:,:,i)=mm;
    end
end
matrix4(12,17,4)=3;matrix4(13,18,4)=3;matrix4(14,19,4)=3;matrix4(15,20,4)=3;

%%%% region 4 = wider Homer around area
for i=1:sizm(3)
    ccc=find(matrix3(:,:,i)==1);
    if numel(ccc)>0; mm=matrix3(:,:,1)-matrix3(:,:,1);
        mm(ccc)=1;
        mm=imdilate(mm,strel('disk',3));
        ccc=find(mm>0 & matrix4(:,:,i)==0 & (matrix3(:,:,i)==2 | matrix3(:,:,i)==6 | matrix3(:,:,i)==4));
        mm=matrix4(:,:,i);
        mm(ccc)=4;
        matrix4(:,:,i)=mm;
    end
end


matrix4(16,20:22,5)=10; matrix4(17:18,21,5)=10;%%% 5 pixels
matrix4(16,20:21,4)=10; matrix4(17,21,4)=10;%%% 3 pixels
matrix4(14,15:17,6)=8;  %%% 3 pixels
matrix4(14,15,3)=8;  %%% 3 pixels
matrix4(15,16,3)=8;  %%% 3 pixels
matrix4(15,16,5)=8;  %%% 3 pixels



%%%% region 5 = Above Homer area (above AZ)
top=matrix3(:,:,1)-matrix3(:,:,1); top(1:11,:)=1;
for i=1:sizm(3)
    ccc=find(matrix4(:,:,i)>0);
    if numel(ccc)>0;
        mm=matrix3(:,:,1)-matrix3(:,:,1);
        mm(ccc)=1;
        mm=imdilate(mm,strel('disk',3));
        ccc=find(mm>0 & matrix4(:,:,i)==0 & (matrix3(:,:,i)==2 | matrix3(:,:,i)==6) & top==1);
        mm=matrix4(:,:,i);
        mm(ccc)=5;
        matrix4(:,:,i)=mm;
    end
end
matrix4(10:11,11:12,3)=5; matrix4(11,13,3)=5;

%%%% region 6 = further above Homer area (further above AZ)

top=matrix3(:,:,1)-matrix3(:,:,1); top(1:11,:)=1;
for i=1:sizm(3)
    ccc=find(matrix4(:,:,i)>0);
    if numel(ccc)>0;
        mm=matrix3(:,:,1)-matrix3(:,:,1);
        mm(ccc)=1;
        mm=imdilate(mm,strel('disk',3));
        ccc=find(mm>0 & matrix4(:,:,i)==0 & (matrix3(:,:,i)==2 | matrix3(:,:,i)==6) & top==1);
        mm=matrix4(:,:,i);
        mm(ccc)=6;
        matrix4(:,:,i)=mm;
    end
end

top=matrix3(:,:,1)-matrix3(:,:,1); top(1:12,:)=1;
%%%% region 7 = further under/around Homer area (further under AZ)
for i=1:sizm(3)
    ccc=find(matrix4(:,:,i)>0);
    if numel(ccc)>0;
        mm=matrix3(:,:,1)-matrix3(:,:,1);
        mm(ccc)=1;
        mm=imdilate(mm,strel('disk',1));
        ccc=find(mm>0 & matrix4(:,:,i)==0 & (matrix3(:,:,i)==2 | matrix3(:,:,i)==6) & top==1);
        mm=matrix4(:,:,i);
        mm(ccc)=7;
        matrix4(:,:,i)=mm;
    end
end
ccc=find(matrix3(:,:,1)==6 ); mm=matrix4(:,:,1)-matrix4(:,:,1); mm(ccc)=6;
ccc=find(matrix3(:,:,1)==2 & top==1); mm(ccc)=7; matrix4(:,:,1)=mm;

ccc=find(matrix3(:,:,2)==6 ); mm=matrix4(:,:,2)-matrix4(:,:,2); mm(ccc)=6;
ccc=find(matrix3(:,:,2)==2 & top==1); mm(ccc)=7; matrix4(:,:,2)=mm;

top=matrix3(:,:,1)-matrix3(:,:,1); top(1:15,:)=1;
ccc=find(matrix3(:,:,8)==6 & top==1); mm=matrix4(:,:,8)-matrix4(:,:,8); mm(ccc)=6;
ccc=find(matrix3(:,:,8)==2 & top==1); mm(ccc)=7; matrix4(:,:,8)=mm;

ccc=find(matrix3(:,:,9)==6 ); mm=matrix4(:,:,9)-matrix4(:,:,9); mm(ccc)=6;
ccc=find(matrix3(:,:,9)==2 & top==1); mm(ccc)=7; matrix4(:,:,9)=mm;



%%%% region 10 = sub-head central beam
%%% see lines 151 and 152

top=matrix3(:,:,1)-matrix3(:,:,1); top(1:20,:)=1;
%%%% region 8 = sub-head central beam lateral
for i=1:sizm(3)
    ccc=find(matrix4(:,:,i)==10);
    if numel(ccc)>0; mm=matrix3(:,:,1)-matrix3(:,:,1); mm(ccc)=1;
        mm=imdilate(mm,strel('disk',2));
        ccc=find(mm>0 & matrix4(:,:,i)==0 & top==1);
        mm=matrix4(:,:,i);
        mm(ccc)=8;
        matrix4(:,:,i)=mm;
    end
end
matrix4(12:14,15:16,2)=9;
matrix4(13:14,17:19,2)=9;
matrix4(12:14,16:18,8)=8;


top=matrix3(:,:,1)-matrix3(:,:,1); top(16:19,:)=1;
%%% region 9 = sub-head wide edges
for i=3:7
    %ccc=find(matrix4(:,:,i)); if numel(ccc)>0; mm=matrix3(:,:,1)-matrix3(:,:,1); mm(ccc)=1;
    %  mm=imdilate(mm,strel('disk',1));
    ccc=find(matrix4(:,:,i)==0 & (matrix3(:,:,i)==2 ) & top==1);
    mm=matrix4(:,:,i);
    mm(ccc)=9;
    matrix4(:,:,i)=mm;
    
end

%%%% region 12 = bottom neck central beam
matrix4(19,22,4)=12;    matrix4(19,23,5)=12;   matrix4(16,21,6)=12;

%%%% region 11 = bottom neck central edges
for i=1:sizm(3)
    ccc=find(matrix4(:,:,i)==12);
    if numel(ccc)>0;
        mm=matrix3(:,:,1)-matrix3(:,:,1);
        mm(ccc)=1;
        mm=imdilate(mm,strel('disk',3));
        ccc=find(matrix4(:,:,i)==0 & (matrix3(:,:,i)>0) & mm>0);
        mm=matrix4(:,:,i);
        mm(ccc)=11;
        matrix4(:,:,i)=mm;
    end
end


%%%% region 13 = bottom neck wide edges
top=matrix3(:,:,1)-matrix3(:,:,1); top(16:24,15:25)=1;
for i=1:sizm(3)
    ccc=find(matrix3(:,:,i)==2 & top==1 & matrix4(:,:,i)==0);
    mm=matrix4(:,:,i);
    mm(ccc)=13;
    matrix4(:,:,i)=mm;
end
top=matrix4(:,:,1)-matrix4(:,:,1); top(1:18,12:18)=1;
ccc=find(matrix4(:,:,1)==7 & top==1); mm=matrix4(:,:,1); mm(ccc)=14; matrix4(:,:,1)=mm;
ccc=find(matrix4(:,:,2)==7 & top==1); mm=matrix4(:,:,2); mm(ccc)=14; matrix4(:,:,2)=mm;
ccc=find(matrix4(:,:,9)==7 & top==1); mm=matrix4(:,:,9); mm(ccc)=14; matrix4(:,:,9)=mm;
top=matrix4(:,:,1)-matrix4(:,:,1); top(1:18,15:19)=1;
ccc=find(matrix4(:,:,8)==7 & top==1); mm=matrix4(:,:,8); mm(ccc)=14; matrix4(:,:,8)=mm;


%%%% region 14 = neck root
top=matrix3(:,:,1)-matrix3(:,:,1); top(20:22,16:27)=1;
for i=1:sizm(3)
    ccc=find(matrix3(:,:,i)>0 & top==1 & matrix4(:,:,i)==0);
    mm=matrix4(:,:,i);
    mm(ccc)=14;
    matrix4(:,:,i)=mm;
end


%%%% region 15 = base
top=matrix3(:,:,1)-matrix3(:,:,1); top(20:26,:)=1;
for i=1:sizm(3)
    ccc=find((matrix3(:,:,i)==1 | matrix3(:,:,i)==2 |matrix3(:,:,i)==3 |matrix3(:,:,i)==4 |matrix3(:,:,i)==6) & top==1 & matrix4(:,:,i)==0);
    mm=matrix4(:,:,i);
    mm(ccc)=15;
    matrix4(:,:,i)=mm;
end


matrix4(26:26,1:36,4)=15;
matrix4(26:26,2:38,5)=15;
matrix4(26:26,3:38,6)=15;
matrix4(26:26,:,7)=15;
matrix4(26:26,3:35,8)=15;
matrix4(25,1,7)=15; matrix4(25,1,4)=15;matrix4(22:23,1,4)=15;matrix4(24:25,4:5,5)=15;matrix4(25,41,7)=15;

for i=1:sizm(3)
    pp=matrix4(:,:,i);
    ccc=find(pp>0);
    pp(ccc)=1;
    pp2=imfill(pp);
    ccc=find(pp==0 & pp2==1);
    if numel(ccc)>0
        mm=matrix4(:,:,i);
        mm(ccc)=15; matrix4(:,:,i)=mm;
    end
end
matrix=matrix4;

% Everything from here on was not saved before. Was this an error? I think
% it is, because in his matrix this part was performed!
ccc=find(matrix4(:,:,9)==6); mm=matrix4(:,:,9); mm(ccc)=13; matrix4(:,:,9)=mm;
top=matrix4(:,:,9)-matrix4(:,:,9); top(10:14,10:13)=1;
ccc=find(matrix4(:,:,1)==6 & top==1);
mm=matrix4(:,:,1); mm(ccc)=7; matrix4(:,:,1)=mm;

matrix4(19,20:23,6)=14;
top=matrix4(:,:,9)-matrix4(:,:,9); top(20:30,:)=1; ccc=find(top==1 & ( matrix4(:,:,9)>0 |matrix3(:,:,9)>0));
mm=matrix4(:,:,9); mm(ccc)=14; matrix4(:,:,9)=mm;

top=matrix4(:,:,9)-matrix4(:,:,9); top(1:22,:)=1;

% Set everythin that has an organelle identity but no zone to zone 15.
for i=1:sizm(3)
    ccc=find(matrix4(:,:,i)==0 & top==1 & matrix3(:,:,i)>0);
    mm=matrix4(:,:,i);
    mm(ccc)=15;
    matrix4(:,:,i)=mm;
end

% If the modifications above should be saved we need to define the matrix
% here again.
% matrix=matrix4;
save('matrix_zone_identities.mat','matrix');

figure;

for i=1:sizm(3)
    matrix4(1,1,i)=15;
    subplot(3,3,i); imagesc(matrix4(:,:,i)) ; axis equal; 
end

mm=[];  for i=1:15; ccc=find(matrix4==i); mm(i)=numel(ccc); end; mm'



mm'*100/sum(mm)

figure
for i=1:sizm(3);
    ccc=find(matrix3(:,:,i)>0 & matrix4(:,:,i)==0);
    
    mm=matrix3(:,:,1)-matrix3(:,:,1); mm(ccc)=1; subplot(3,3,i); imagesc(mm); end

