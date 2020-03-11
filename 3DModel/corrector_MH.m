function corrector_MH

% Correction script for the organelle and zone identities.
cd 'Z:\user\mhelm1\Nanomap_Analysis\Electron Microscopy\for_models\new tracings with mito\Mushroom_new with missing spine_after debugging script'
close all
load matrix_zone_identities.mat;
matrix_new=matrix;

%This reads in the old zone distributions from Silvio, before I realized
%the tracing error. Its to compare the new matrix to to get as close to it
%as possible
load matrix_zone_identities_Silvio_old.mat;
matrix_old=matrix;
matrix_old_orig=matrix_old;
% % figure; for i=1:9; subplot(3,3,i); imagesc(matrix_new(:,:,i)); end;
% % figure; for i=1:9; subplot(3,3,i); imagesc(matrix_old(:,:,i)); end;

%get zero matrix of same size
top=matrix_old(:,:,1)-matrix_old(:,:,1); 

%define cut out mask. This actually cuts out a small part of the head on
%the left, but doesnt matter as it is only used for modifications in the shaft region.
top(20:40,10:30)=1;

%check layer1, find all elements that are new in the new matrix and within the mask
nn=matrix_new(:,:,1); oo=matrix_old(:,:,1); 
ccc=find(nn>0 & oo==0 & top>0); numel(ccc) % 57 (new elements I guess)

%  modify the OLD matrix (I guess he rather modifies the old one, that
%  making the new one correct...) to also include these regions, give them
%  the index 15 (thats what matrix_old(24,25,7) has as a value)
mm=matrix_old(:,:,1); 
mm(ccc)=matrix_old(24,25,7); 
matrix_old(:,:,1)=mm;

% Do the same for layer 2
nn=matrix_new(:,:,2); oo=matrix_old(:,:,2); ccc=find(nn>0 & oo==0 & top>0); numel(ccc) % 70
mm=matrix_old(:,:,2); mm(ccc)=matrix_old(24,25,7); matrix_old(:,:,2)=mm;

% go to layer 3, here processing is different. Find all elements that have
% zone identity 15 and are not present in the old matrix and within mask.
% Also set these to identity 15 
nn=matrix_new(:,:,3); oo=matrix_old(:,:,3);
ccc=find(nn==15 & oo==0 & top>0); numel(ccc) % 72
mm=matrix_old(:,:,3); mm(ccc)=matrix_old(24,25,7); matrix_old(:,:,3)=mm;

% For layers 4 to 8 shave off the first 3 and the last 5 columns in the
% shaft region
for i=4:8
    matrix_old(20:30,1:3,i)=0; 
    matrix_old(20:30,37:41,i)=0; 
end

% Shave off some more shaft region in layer 3
matrix_old(25:26,1:18,3)=0;
matrix_old(25:26,27:41,3)=0;
% Also remove another pixel in layer1
matrix_old(29,30,1)=0;

% for layers 5:8 remove row 26 completely
for i=5:8
    matrix_old(26,:,i)=0; 
end

% In layer 3 copy new zones 13
nn=matrix_new(:,:,3); oo=matrix_old(:,:,3); 
ccc=find(nn==13 );
mm=matrix_old(:,:,3); 
mm(ccc)=13; 
matrix_old(:,:,3)=mm;

% modify layer 9. This has not been changed yet and is still in the "old"
% state. He modifies it to look like the new tracings.
matrix_old(16:18,:,9)=0; %get rid of a bit at bottom of the head
matrix_old(15,15:19,9)=0; %get rid of everything in row 15 except this one pixel to the left. This is because this is also present with the same identity in the new tracing.
matrix_old(11:14,13:15,9)=0; %get rid of more pixels on the left side of the head. Its everything on the left side until column 15
matrix_old(14,16,9)=0; %remove another pixel

% copy identities 14 for layer 3
nn=matrix_new(:,:,3); oo=matrix_old(:,:,3); ccc=find(nn==14 );
mm=matrix_old(:,:,3); mm(ccc)=14; matrix_old(:,:,3)=mm;

%Add a few pixels with identity 15. They were 14 in the new matrix
matrix_old(21:22,26:27,3)=15;
matrix_old(22,24:25,3)=15;
%Remove some identity 15 pixels
matrix_old(22:24,29:30,3)=0;

%this is just to count number of identity 15 pixels 
ccc=find(matrix_old_orig==15); numel(ccc)
ccc=find(matrix_old==15); numel(ccc)

% figure; 
% for i=1:9
%     subplot(3,3,i); 
%     imagesc(matrix_old(:,:,i)); 
% end

load matrix_organelle_identities_plus_endosomes_Silvio_old.mat
orgs=matrix; orgs_orig=orgs;

%%figure; for i=1:9; subplot(3,3,i); imagesc(orgs(:,:,i)); end;

% For all new added pixels in layers 1to3 change their organell identiy to cytosol if they
% are not identified as something else in the organelle identities.
for i=1:3
    ccc=find(matrix_old(:,:,i)>0 & orgs(:,:,i)==0);
    mm=orgs(:,:,i);
    mm(ccc)=6; 
    orgs(:,:,i)=mm; 
end

% Add the shaft membranes in layers 1,2,3,9
orgs(24,10:14,1)=2; orgs(25,15:22,1)=2;orgs(26,23:26,1)=2;orgs(28:29,26:29,1)=2;orgs(27,26,1)=2;
orgs(20,10:17,2)=2; orgs(21,18:22,2)=2;orgs(22,23:24,2)=2;orgs(23,25:26,2)=2;orgs(24,27,2)=2;orgs(25,28,2)=2;orgs(26,29,2)=2;
orgs(22,11:16,3)=2; orgs(21,17:29,3)=2;

% Add membranes in layer 9 head
orgs(12:13,16,9)=2; orgs(14,17:19,9)=2;

% In layer9 there was this small bug with membrane outside of the shaft.
% Silio now assigns these to membrane and in exchange changes on membrane
% pixel to cytosol as well as adding some cytosol pixels underneath the
% membrane.
% This effectively moves the bent in the mebrane to the left!!!
orgs(26,20:22,9)=2;
orgs(26,23,9)=6; orgs(27,21:23,9)=6;

% In layer9 find everything that is present in the organelle matrix but has
% no zone identy assigend (due to the removals we performed above). Change
% the organelle identifiers of these regions to 0.
ccc=find(orgs(:,:,9)>0 & matrix_old(:,:,9)==0); 
mm=orgs(:,:,9); 
mm(ccc)=0; 
orgs(:,:,9)=mm;

% For all layers check what doesnt have zones assigned but still has some
% organelle identity and remove this.
% Also check which mitochondria pixels got removed compared to Silvios old
% organelle identities and add them back.
for i=1:9
    ccc=find(matrix_old(:,:,i)==0 & orgs(:,:,i)>0); mm=orgs(:,:,i); mm(ccc)=0; orgs(:,:,i)=mm;
    ccc=find(orgs_orig(:,:,i)==5 & orgs(:,:,i)==0); mm=orgs(:,:,i); mm(ccc)=5; orgs(:,:,i)=mm;
end

% Move the Rab7/late endosome, which was way outside the "top" mask defined
% above, into the shaft that is still there. It is placed under the ER into
% a position that was cytosol before!!!
orgs(24,27:28,5)=40; orgs(25,26:28,5)=40; orgs(22:25,26:27,6)=40;

% fill the Rab9/TGN vesicle on the side. the lumen had not been
% characterized before/misscharacterized as cytosol. That seems fine
orgs(23,8:10,5)=70; 

% Also add more of Rab9/TGN in layer 6. In the EM images there is obviously
% cytosol between the vesicle and the mitochondrion, which is now
% removed!!!
orgs(24,12:13,6)=70;  orgs(25,11:13,6)=70;

for i=1:9;
%     removes all mitochondria pixels!!!
    ccc=find(orgs(:,:,i)==5); mm=orgs(:,:,i); mm(ccc)=0; orgs(:,:,i)=mm;
%     everything that is not an organelle but has a zone identity is set to
%     cytosol. This probably mostly acts on the pixels that were previously
%     cytosol.
    ccc=find(orgs(:,:,i)==0 & matrix_old(:,:,i)>0); mm=orgs(:,:,i); mm(ccc)=6; orgs(:,:,i)=mm;
    
%     find the mitochondria pixels in the old organelle matrix
    pp=orgs_orig(:,:,1)-orgs_orig(:,:,1); ccc=find(orgs_orig(:,:,i)==5); pp(ccc)=1;
    %% subplot(3,3,i);   imagesc(pp);
    
%     Silvios old mito modifications:
%effectively move the mitochondrian downwards a bit, 2 px in layers 4 and 1 px in 5.
% remains the same in layer 6
%  move down 2 px in layer 7
% move up 1 px in layer 8 (probably to make it align with layer 7.
% All of this is not following the EM!!!

%I correct it slightly, see the following comments. in total 2 cytosol
%pixels are added, as well as 7 mitochondria pixels.

    if i==4
        orgs(26:39,:,i)=pp(25:38,:)*5; %only move it 1 pixel instead of 2. This removes 10 cytosol pixels
        [orgs(26,11:25,i),orgs(26,29:35,i)]=deal(6);   %need to manually add the cytosol and membrane pixels, as they are not present in pp
        orgs(26,36,i)=2;
    elseif i==5
        orgs(26:40,:,i)=pp(25:39,:)*5; %Mitochondrio like Silvio moved it. but fill up the nonassigned pixles between mito and cytosol with cytosol. This adds 21 pixels
        orgs(26,14:33,i)=6;
        orgs(27,32:33,i)=6;
    elseif i==6
        orgs(26:40,:,i)=pp(26:40,:)*5; %leave it like Silvio moved it
        [orgs(26,7,i),orgs(26,9,i),orgs(26,22,i),orgs(27,30,i),orgs(27,32,i),orgs(28,34,i)]=deal(5); % fill the mitochondria tracing gaps. 
        mean2(pp)
    elseif i==7
        orgs(25:39,:,i)=pp(24:38,:)*5; %only move 1 pixel instead of 2. This removes 9 cytosol pixels and takes care of all nonassigned pixels
        orgs(25,29,i)=5; %fill the gap in the mitochondrion tracing
        [orgs(25,4:21,i),orgs(25,31:36,i)]=deal(6); %need to manually add the cytosol
    elseif i==8
        orgs(26:40,:,i)=pp(27:41,:)*5; %leave it like Silvio did it.
    end
    
    
end


% Correct layer 2 position to make it match to how Burkhard positioned it
% (in this layer was the large black crack in the sample)

m=orgs(:,:,2);
m_shaft=m;
m_shaft(1:18,:)=0;   %20 pixels of membrane (2); 50 pixels of cytosol (6)
m_head=m-m_shaft;
theta=12; %rotate by 12 degree counterclockwise

m_shaft=imtranslate(m_shaft,[11,1]); %translate top left membrane point to center of image
m_shaft=imrotate(m_shaft,theta,'crop');  %rotate by 30 degee counterclockwise; still 20 pixels of membrane (2); 50 pixels of cytosol (6)
m_shaft=imtranslate(m_shaft,[-11,-1]); %translate back
m_shaft=imtranslate(m_shaft,[round(-99/35),ceil(116.5/35)-1]);
m_both=m_shaft+m_head;
orgs(:,:,2)=zeros(size(orgs,1),size(orgs,2));
orgs(:,:,2)=m_both;

matrix_old(:,:,2)=zeros(size(matrix_old,1),size(matrix_old,2));
matrix_old(:,:,2)=m_both;


% figure; 
% for i=1:9
%     subplot(3,3,i); 
%     imagesc(matrix_old(:,:,i)); 
% end
% 
% figure; 
% for i=1:9
%     subplot(3,3,i); 
%     imagesc(orgs(:,:,i)); 
% end

%% Fix vacuole identities once again.
orgs(orgs>6)=6;
org_temp=zeros(41,41,9);
%% Create ER:
% layer4
tmp=zeros(41,41); 
[tmp(17,21:23), tmp(18,19:21), tmp(18,23), tmp(19,19:22), tmp(20,17:20), tmp(21,17:19)]=deal(60); %from old green vesicles
org_temp(:,:,4)=org_temp(:,:,4)+tmp;
% layer5
tmp=zeros(41,41); 
[tmp(14,35:37), tmp(15,34:37), tmp(16,31:36), tmp(17,29:33), tmp(18,28:31), tmp(19,29)]=deal(60); %from old violet vesicle
[tmp(16,24) tmp(17,23:26), tmp(18,23), tmp(18,26:27), tmp(19,24:27) tmp(20,26)]=deal(60); %from old green vesicle
[tmp(19,17), tmp(20,16:17), tmp(21,16:17)]=deal(60); %from old red vesicle
[tmp(19,15:16)]=deal(60); %partially from old black vesicle. Since the signal in EM is very bad there, I removed the uncertain pixels: tmp(17,12:14), tmp(18,12), tmp(18,14:15), tmp(19,12), tmp(20,12:15) 
org_temp(:,:,5)=org_temp(:,:,5)+tmp;
% layer6
tmp=zeros(41,41);
[tmp(17,12:13), tmp(18,11:14), tmp(19,11:15)]=deal(60); %from old black vesicle
[tmp(16,6:9), tmp(17,6:10)]=deal(60); %from old red vesicle
[tmp(13,35:36), tmp(14,34:37), tmp(15,32:36), tmp(16,29:34), tmp(17,28:32), tmp(18,28:30), tmp(19,28)]=deal(60);
org_temp(:,:,6)=org_temp(:,:,6)+tmp;
% layer7
tmp=zeros(41,41);
[tmp(18,29:32), tmp(19,27:32), tmp(20,27:30)]=deal(60); %from old violet vesicle
org_temp(:,:,7)=org_temp(:,:,7)+tmp;
% layer8
tmp=zeros(41,41);
[tmp(17,24:32), tmp(18,24:30)]=deal(60); %from old violet vesicle
org_temp(:,:,8)=org_temp(:,:,8)+tmp;

%% Create vesicles at top of the head. silvio classified them as Rab5/4
% early endosome, so lets stick with this. Its only in layer 3
tmp=zeros(41,41);
[tmp(31,10:13), tmp(31,11:12)]=deal(50); 
org_temp(:,:,3)=org_temp(:,:,3)+tmp;

%% Create funny vesicle on the left side, is light blue from before. I will call this a recycling endosome, just because of the nice peeling of shape ^^
% layer4
tmp=zeros(41,41);
[tmp(17,1:5), tmp(18,1), tmp(18,5), tmp(19,1:11), tmp(20,3:7), tmp(20,10:11), tmp(21,7:10)]=deal(30);
org_temp(:,:,4)=org_temp(:,:,4)+tmp;
% layer5
tmp=zeros(41,41);
[tmp(18,7:10), tmp(19,5:8), tmp(19,11), tmp(20,5:11)]=deal(30);
org_temp(:,:,5)=org_temp(:,:,5)+tmp;

%% Create Round vesicle on the left side, is red from layer 4. I will treat this as a Chromogranin/Rab3 vesicle (LDCV), it is a little bit over 100 nm in diameter (LDCV 100-300 nm usually).
tmp=zeros(41,41);
[tmp(17,12:14), tmp(18,12), tmp(18,14), tmp(19,12), tmp(19,14), tmp(20,12:13)]=deal(20);
org_temp(:,:,4)=org_temp(:,:,4)+tmp;

%% Create large vesicle in the center, right below neck. Is dark blue from above. Lets call this a late endosome.
% layer6
tmp=zeros(41,41);
[tmp(16,22), tmp(17,21:23), tmp(18,21), tmp(18,23), tmp(19,21:23), tmp(20,22)]=deal(40);
org_temp(:,:,6)=org_temp(:,:,6)+tmp;
% layer7
tmp=zeros(41,41);
[tmp(18,21), tmp(19,20:22), tmp(20,20), tmp(20,22), tmp(21,20:22), tmp(22,21)]=deal(40);
org_temp(:,:,7)=org_temp(:,:,7)+tmp;
% layer8
tmp=zeros(41,41);
[tmp(18,20:22), tmp(19,20), tmp(19,22), tmp(20,20:22)]=deal(40);
org_temp(:,:,8)=org_temp(:,:,8)+tmp;

%% Create curved thing under the neck, is white from above plus the red from layer 7. I will call this Rab9/TGN
% layer5:
tmp=zeros(41,41);
[tmp(20,18:25), tmp(21,18:24), tmp(22,20:21)]=deal(70); 
org_temp(:,:,5)=org_temp(:,:,5)+tmp;
% layer6: 
tmp=zeros(41,41);
[tmp(17,25), tmp(18,24:26), tmp(19,24:26), tmp(20,23:25), tmp(21,21:24), tmp(22,20:23), tmp(23,21:22)]=deal(70);
org_temp(:,:,6)=org_temp(:,:,6)+tmp;
% layer7: 
tmp=zeros(41,41);
[tmp(19,24:25), tmp(20,23:25), tmp(21,23:24)]=deal(70);
org_temp(:,:,7)=org_temp(:,:,7)+tmp;


% In total the extra BDNF vesicle, identifier 10, is now missing but we can
% integrate this into the Chromogranin vesicle

%% Set lumen of vacuoles to one, so I can later set it to 0

for i=1:9
    tmp=zeros(41,41);
    tmp=imfill(org_temp(:,:,i),'holes');
    tmp=org_temp(:,:,i)-tmp;
    tmp(tmp<0)=1;
    org_temp(:,:,i)=org_temp(:,:,i)+tmp;
end

%% Flip it upside down to make it match the actual tracings
org_temp=flipud(org_temp);
% figure
% for i=1:9
%     subplot(3,3,i); imagesc(org_temp(:,:,i),[0 70]); axis equal;
% end
 

%remove all current endosomal compartments and set them to cytosol. Then
%replace everything with the new endosomal compartments. I do not replace
%pixels that already have a different identity such as plasmamembrane or
%AZ. I do replace mitochondrion and manually move the replaced mito pixels.
orgs(orgs>6)=6;
orgs(org_temp>1 & orgs~=1 & orgs~=2 & orgs~=3)=org_temp(org_temp>1 & orgs~=1 & orgs~=2 & orgs~=3);
% make lumen of vacuoles 0
orgs(org_temp==1)=0;
% Fix ER, as this should not have 0 in lumen.
[orgs(24,22,4), orgs(24,24:25,5)]=deal(60);

% add this extra PM pixel to make the PM connected
[orgs(27,26,1), orgs(20,17,5), orgs(22,12,6)]=deal(2);

% Fix mitochondria
[orgs(27,7:10,6), orgs(27,22,6), orgs(27,29,6), orgs(28,32,6), orgs(29,34,6)]=deal(5);

% remove the cytosol pixel outside the head in layer 5
orgs(16,24,5)=0;

% Create BDNF Vesicle
orgs(22,3:5,4)=10;
orgs(23,1:5,4)=10;
orgs(24,1,4)=10;
orgs(24,5,4)=10;
orgs(25,1:5,4)=10;


figure; 
for i=1:9
    subplot(3,3,i); 
    imagesc(matrix_old(:,:,i)); axis equal;
end

figure; 
for i=1:9
    subplot(3,3,i); 
    imagesc(orgs(:,:,i),[0 70]); axis equal; 
end


matrix=orgs;
save('matrix_organelle_identities_plus_endosomes_corrected.mat','matrix');

% For zone identities, set all pixels where we have organelles to 0. This
% prevents placing cytosolic proteins into these 
organelles = orgs>6;

for i=1:9
    tmp=zeros(41,41);
    tmp=imfill(organelles(:,:,i),'holes');
organelles(:,:,i)=tmp;
end

matrix=matrix_old;
matrix(organelles) = 0;

save('matrix_zone_identities_corrected.mat','matrix');
% % x=[1 2 3 4 5 6 10 20 30 40 50 60 70];
% % mm=[]; for i=1:numel(x); ccc=find(orgs==x(i)); mm(i,1)=numel(ccc); ccc=find(orgs_orig==x(i)); mm(i,2)=numel(ccc); end;
% % mm

% % figure; for i=1:9;
% %    ccc=find(orgs(:,:,i)==5); mm=orgs(:,:,i); mm(ccc)=0; orgs(:,:,i)=mm;
% %    ccc=find(orgs(:,:,i)>0 & matrix_old(:,:,i)==0); pp=mm-mm; pp(ccc)=1; subplot(3,3,i); imagesc(pp);
% % end

end