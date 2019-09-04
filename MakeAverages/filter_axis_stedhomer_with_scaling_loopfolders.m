function filter_axis_stedhomer_with_scaling_loopfolders
global counter angles scaling bottomx topx rightx leftx bottomy topy righty lefty classification no_sted_images...
    rotation_angles vertical_shifts horizontal_shifts...
    bottomneckx bottomnecky shafttopleftx shafttoplefty shafttoprightx shafttoprighty shaftbottomrightx shaftbottomrighty shaftbottomleftx shaftbottomlefty...
    spineline_x spineline_y cd_path
cd_path='Z:\user\mhelm1\Nanomap_Analysis\Replicate1';
cd(cd_path);


files=[];
files=dir;
folders={};
for i=1:numel(files)
    if files(i).isdir && strcmp(files(i).name,'figures')==0
        folders{numel(folders)+1}=files(i).name;
    end;
end;

for treatment=3:numel(folders)
    cd(strcat(cd_path, '\', folders{treatment}));
    clear bottomx bottomy topx topy leftx lefty rightx righty classification bottomneckx bottomnecky shafttopleftx shafttoplefty 
    clear shafttoprightx shafttopyrighty shaftbottomrightx shaftbottomrighty shaftbottomleftx shaftbottomlefty
    clear stat mess statbottom messbottom
    progress=treatment*100/numel(folders)
    sfolder=regexp(pwd,'\','split'); 
    treatmentname=sfolder(end);treatmentname=treatmentname{:};

[stat, mess]=fileattrib('*_spots*.txt');
[blub,order]=sort({mess.Name});mess=mess(order);order=[]; %sort to avoid unordered spot files due to server bugs

if exist('bottomx.txt')==2 && exist('Mush_dio_average.txt')==0;

    
bottomx=double(dlmread('bottomx.txt'));bottomy=double(dlmread('bottomy.txt'));
topx=double(dlmread('topx.txt'));topy=double(dlmread('topy.txt'));
leftx=double(dlmread('leftx.txt'));lefty=double(dlmread('lefty.txt'));
rightx=double(dlmread('rightx.txt'));righty=double(dlmread('righty.txt'));
classification=dlmread('classification.txt');
bottomneckx=dlmread('bottomneckx.txt');
bottomnecky=dlmread('bottomnecky.txt');
shafttopleftx=dlmread('shafttopleftx.txt');
shafttoplefty=dlmread('shafttoplefty.txt');
shafttoprightx=dlmread('shafttoprightx.txt');
shafttoprighty=dlmread('shafttoprighty.txt');
shaftbottomrightx=dlmread('shaftbottomrightx.txt');
shaftbottomrighty=dlmread('shaftbottomrighty.txt');
shaftbottomleftx=dlmread('shaftbottomleftx.txt');
shaftbottomlefty=dlmread('shaftbottomlefty.txt');

Mush_sted_average=zeros(151);
Mush_dio_average=zeros(151);
Mush_homer_average=zeros(151);
Flat_sted_average=zeros(151);
Flat_dio_average=zeros(151);
Flat_homer_average=zeros(151);
Other_sted_average=zeros(151);
Other_dio_average=zeros(151);
Other_homer_average=zeros(151);
Mush_sted_resized_average=zeros(151);
Mush_dio_resized_average=zeros(151);
Mush_homer_resized_average=zeros(151);
Flat_sted_resized_average=zeros(151);
Flat_dio_resized_average=zeros(151);
Flat_homer_resized_average=zeros(151);
Other_sted_resized_average=zeros(151);
Other_dio_resized_average=zeros(151);
Other_homer_resized_average=zeros(151); 
Mush_sted_noback_average=zeros(151);
Mush_dio_noback_average=zeros(151);
Mush_homer_noback_average=zeros(151);
Flat_sted_noback_average=zeros(151);
Flat_dio_noback_average=zeros(151);
Flat_homer_noback_average=zeros(151);
Other_sted_noback_average=zeros(151);
Other_dio_noback_average=zeros(151);
Other_homer_noback_average=zeros(151);
Mush_sted_norm2shaft_average=zeros(151);
Mush_dio_norm2shaft_average=zeros(151);
Mush_homer_norm2shaft_average=zeros(151);
Flat_sted_norm2shaft_average=zeros(151);
Flat_dio_norm2shaft_average=zeros(151);
Flat_homer_norm2shaft_average=zeros(151);
Other_sted_norm2shaft_average=zeros(151);
Other_dio_norm2shaft_average=zeros(151);
Other_homer_norm2shaft_average=zeros(151);
Mush_sted_noback_norm2shaft_average=zeros(151);
Mush_dio_noback_norm2shaft_average=zeros(151);
Mush_homer_noback_norm2shaft_average=zeros(151);
Flat_sted_noback_norm2shaft_average=zeros(151);
Flat_dio_noback_norm2shaft_average=zeros(151);
Flat_homer_noback_norm2shaft_average=zeros(151);
Other_sted_noback_norm2shaft_average=zeros(151);
Other_dio_noback_norm2shaft_average=zeros(151);
Other_homer_noback_norm2shaft_average=zeros(151);


%scale according to height axis
bottomtop_length=zeros(1,numel(mess));
for j=1:numel(mess)
    bottomtop_length(j)=abs(topy(j)-bottomy(j));
end
scale_by=max(bottomtop_length);
dlmwrite('max_spine_length_forscaling.txt',scale_by);


rotation_angles=zeros(1,numel(mess));
vertical_shifts=zeros(1,numel(mess));
horizontal_shifts=zeros(1,numel(mess));

for i=1:numel(mess)

disp(strcat(num2str(i), ' out of',' ', num2str(numel(mess)), 'in folder', sfolder{end}))

if exist(['sted_aligned_' num2str(i) '.txt'])==1
    %if spot was already analyzed read in the files
    sted_aligned=dlmread(strcat('sted_aligned_',num2str(i),'.txt'));
    dio_aligned=dlmread(strcat('dio_aligned_',num2str(i),'.txt'));
    homer_aligned=dlmread(strcat('homer_aligned_',num2str(i),'.txt'));
    sted_aligned_resized=dlmread(strcat('sted_aligned_resized_',num2str(i),'.txt'));
    dio_aligned_resized=dlmread(strcat('dio_aligned_resized_',num2str(i),'.txt'));
    homer_aligned_resized=dlmread(strcat('homer_aligned_resized_',num2str(i),'.txt'));
    sted_aligned_noback=dlmread(strcat('sted_aligned_noback_',num2str(i),'.txt'));
    dio_aligned_noback=dlmread(strcat('dio_aligned_noback_',num2str(i),'.txt'));
    homer_aligned_noback=dlmread(strcat('homer_aligned_noback_',num2str(i),'.txt'));
    sted_aligned_norm2shaft=dlmread(strcat('sted_aligned_norm2shaft_',num2str(i),'.txt'));
    dio_aligned_norm2shaft=dlmread(strcat('dio_aligned_norm2shaft_',num2str(i),'.txt'));
    homer_aligned_norm2shaft=dlmread(strcat('homer_aligned_norm2shaft_',num2str(i),'.txt'));
    sted_aligned_noback_norm2shaft=dlmread(strcat('sted_aligned_noback_norm2shaft_',num2str(i),'.txt'));
    dio_aligned_noback_norm2shaft=dlmread(strcat('dio_aligned_noback_norm2shaft_',num2str(i),'.txt'));
    homer_aligned_noback_norm2shaft=dlmread(strcat('homer_aligned_noback_norm2shaft_',num2str(i),'.txt'));

    %then add the values to the average
    if classification(i)==1
    Mush_sted_average=Mush_sted_average+sted_aligned;
    Mush_dio_average=Mush_dio_average+dio_aligned;
    Mush_homer_average=Mush_homer_average+homer_aligned;
    Mush_sted_resized_average=Mush_sted_resized_average+sted_aligned_resized;
    Mush_dio_resized_average=Mush_dio_resized_average+dio_aligned_resized;
    Mush_homer_resized_average=Mush_homer_resized_average+homer_aligned_resized;
    Mush_sted_noback_average=Mush_sted_noback_average+sted_aligned_noback;
    Mush_dio_noback_average=Mush_dio_noback_average+dio_aligned_noback;
    Mush_homer_noback_average=Mush_homer_noback_average+homer_aligned_noback;
    Mush_sted_norm2shaft_average=Mush_sted_norm2shaft_average+sted_aligned_norm2shaft;
    Mush_dio_norm2shaft_average=Mush_dio_norm2shaft_average+dio_aligned_norm2shaft;
    Mush_homer_norm2shaft_average=Mush_homer_norm2shaft_average+homer_aligned_norm2shaft;
    Mush_sted_noback_norm2shaft_average=Mush_sted_noback_norm2shaft_average+sted_aligned_noback_norm2shaft;
    Mush_dio_noback_norm2shaft_average=Mush_dio_noback_norm2shaft_average+dio_aligned_noback_norm2shaft;
    Mush_homer_noback_norm2shaft_average=Mush_homer_noback_norm2shaft_average+homer_aligned_noback_norm2shaft;
    
elseif classification(i)==2
    Flat_sted_average=Flat_sted_average+sted_aligned;
    Flat_dio_average=Flat_dio_average+dio_aligned;
    Flat_homer_average=Flat_homer_average+homer_aligned;
    Flat_sted_resized_average=Flat_sted_resized_average+sted_aligned_resized;
    Flat_dio_resized_average=Flat_dio_resized_average+dio_aligned_resized;
    Flat_homer_resized_average=Flat_homer_resized_average+homer_aligned_resized;
    Flat_sted_noback_average=Flat_sted_noback_average+sted_aligned_noback;
    Flat_dio_noback_average=Flat_dio_noback_average+dio_aligned_noback;
    Flat_homer_noback_average=Flat_homer_noback_average+homer_aligned_noback;
    Flat_sted_norm2shaft_average=Flat_sted_norm2shaft_average+sted_aligned_norm2shaft;
    Flat_dio_norm2shaft_average=Flat_dio_norm2shaft_average+dio_aligned_norm2shaft;
    Flat_homer_norm2shaft_average=Flat_homer_norm2shaft_average+homer_aligned_norm2shaft;
    Flat_sted_noback_norm2shaft_average=Flat_sted_noback_norm2shaft_average+sted_aligned_noback_norm2shaft;
    Flat_dio_noback_norm2shaft_average=Flat_dio_noback_norm2shaft_average+dio_aligned_noback_norm2shaft;
    Flat_homer_noback_norm2shaft_average=Flat_homer_noback_norm2shaft_average+homer_aligned_noback_norm2shaft;
else
    Other_sted_average=Other_sted_average+sted_aligned;
    Other_dio_average=Other_dio_average+dio_aligned;
    Other_homer_average=Other_homer_average+homer_aligned;  
    Other_sted_resized_average=Other_sted_resized_average+sted_aligned_resized;
    Other_dio_resized_average=Other_dio_resized_average+dio_aligned_resized;
    Other_homer_resized_average=Other_homer_resized_average+homer_aligned_resized;
    Other_sted_noback_average=Other_sted_noback_average+sted_aligned_noback;
    Other_dio_noback_average=Other_dio_noback_average+dio_aligned_noback;
    Other_homer_noback_average=Other_homer_noback_average+homer_aligned_noback;
    Other_sted_norm2shaft_average=Other_sted_norm2shaft_average+sted_aligned_norm2shaft;
    Other_dio_norm2shaft_average=Other_dio_norm2shaft_average+dio_aligned_norm2shaft;
    Other_homer_norm2shaft_average=Other_homer_norm2shaft_average+homer_aligned_norm2shaft;
    Other_sted_noback_norm2shaft_average=Other_sted_noback_norm2shaft_average+sted_aligned_noback_norm2shaft;
    Other_dio_noback_norm2shaft_average=Other_dio_noback_norm2shaft_average+dio_aligned_noback_norm2shaft;
    Other_homer_noback_norm2shaft_average=Other_homer_noback_norm2shaft_average+homer_aligned_noback_norm2shaft;
    end

    continue
else
    
if classification(i)<4
    
    spots_full=dlmread(mess(i).Name);   
    homer=spots_full(1:301,1:301);
    sted=spots_full(1:301,603:903);
    di=spots_full(1:301,302:602);
   
    %create DiO mask, applying different filters
    H=fspecial('average',[2 2]); di_b=imfilter(medfilt2(di, [4 4]),H,'replicate');
    filt_db=di_b;ccc=find(di_b>0);
    pp=hist(di_b(ccc),[0.5:1:50]); ppm=max(pp); cccp=find(pp==ppm);
    ccc=find(di_b<cccp+std2(di_b)); di_b(ccc)=0; 
    ccc=find(di_b>0); di_bw=di_b; di_bw(ccc)=1; di_bw=imerode(di_bw,strel('disk',1));

    %filter STED signal to remove noise and set everything outside DiO mask to 0
    sted2=medfilt2(sted,[2 2]); H=fspecial('average',[20 20]);
    sted_back=imfilter(sted2, H, 'replicate');%imopen(sted2,strel('disk',4));
    sted3=sted2-sted_back; ccc=find(sted3<0); sted3(ccc)=0; 
    ccc=find(sted3<mean2(sted3)+4); sted3(ccc)=0; 

    ccc=find(di_bw==0); homer(ccc)=0; sted3(ccc)=0; filt_db(ccc)=0;

%cut out only the relevant part of the sted picture and rotate it according to axis

%calculate new center point
try
bottomtopcos=polyfit([bottomx(i) topx(i)], [bottomy(i) topy(i)],1);
rightleftcos=polyfit([rightx(i) leftx(i)], [righty(i) lefty(i)],1);
bottomtop= @(x) (bottomtopcos(1))*x + bottomtopcos(2);
rightleft= @(x) (rightleftcos(1))*x + rightleftcos(2);

pt = fzero(@(x) bottomtop(x)-rightleft(x),7); % The x-coord
coord = [pt,bottomtop(pt)]; % The coordinates in xy!! (i.e. left-right and then top down, this is the opposite of columns and rows!). 

%make an additional matrix where everything outside of spine head =0
% leftynoback=302-round(lefty);rightynoback=302-round(righty);topynoback=302-round(topy);bottomynoback=302-round(bottomy);%convert y to rows
% bottomneckynoback=302-round(bottomnecky);
thecolumns =[round(leftx(i)) round(rightx(i)) round(bottomx(i)) round(topx(i)) round(bottomneckx(i))];
            therows=[round(lefty(i)) round(righty(i)) round(bottomy(i)) round(topy(i)) round(bottomnecky(i))];
            mincolumn=min(thecolumns);
            minrow=min(therows);
            maxcolumn=max(thecolumns);
            maxrow=max(therows);
            sted_noback=sted3;sted_noback(:,1:mincolumn)=0;sted_noback(:,maxcolumn:end)=0;sted_noback(1:minrow,:)=0;sted_noback(maxrow:end,:)=0;
            dio_noback=filt_db;dio_noback(:,1:mincolumn)=0;dio_noback(:,maxcolumn:end)=0;dio_noback(1:minrow,:)=0;dio_noback(maxrow:end,:)=0;
            homer_noback=homer;homer_noback(:,1:mincolumn)=0;homer_noback(:,maxcolumn:end)=0;homer_noback(1:minrow,:)=0;homer_noback(maxrow:end,:)=0;




vertical_shift=round(151-coord(2)); %if coord2 is smaller (higher), the value will be positive and the image will shift down
%if coord2 is larger (lower), the value will be negative and the image will
%shift up
horizontal_shift=round(151-coord(1)); %if coord2 is smaller (to the left), the value will be positive and the image will shift right
%if coord2 is larger (to the right), the value will be negative and the
%image will shift left
vertical_shifts(i)=vertical_shift;
horizontal_shifts(i)=horizontal_shift;

%shift images
shifted_sted=circshift(sted3,[vertical_shift horizontal_shift]);
shifted_dio=circshift(filt_db,[vertical_shift horizontal_shift]);
shifted_homer=circshift(homer,[vertical_shift horizontal_shift]);

shifted_sted_noback=circshift(sted_noback,[vertical_shift horizontal_shift]);
shifted_dio_noback=circshift(dio_noback,[vertical_shift horizontal_shift]);
shifted_homer_noback=circshift(homer_noback,[vertical_shift horizontal_shift]);


%rotate images

if topx(i)<151 && topy(i)<151 %if the head is in top left quartile
    angle=atand(abs(topy(i)-coord(2))/abs(topx(i)-coord(1)))+270;
elseif topx(i)<151 && topy(i)>151 %if the head is in the bottom left quartile
    angle=atand(abs(topx(i)-coord(1))/abs(topy(i)-coord(2)))+180;
elseif topx(i)>151 && topy(i)>151 %if the head is in the bottom right quartile
    angle=atand(abs(topy(i)-coord(2))/abs(topx(i)-coord(1)))+90;
else %head is in the top right quartile
    angle=atand(abs(topx(i)-coord(1))/abs(topy(i)-coord(2)));
end 

rotation_angles(i)=angle;
    
rot_shifted_sted=imrotate(shifted_sted,(angle));
rot_shifted_scaled_sted=imresize(shifted_sted,(scale_by/(abs(topy(i)-bottomy(i)))));
rot_shifted_scaled_sted=imrotate(rot_shifted_scaled_sted,angle);
rot_shifted_sted_noback=imrotate(shifted_sted_noback,(angle));

rot_shifted_dio=imrotate(shifted_dio,(angle));
rot_shifted_scaled_dio=imrotate(imresize(shifted_dio,(scale_by/(abs(topy(i)-bottomy(i))))),angle);
rot_shifted_dio_noback=imrotate(shifted_dio_noback,(angle));

rot_shifted_homer=imrotate(shifted_homer,(angle));
rot_shifted_scaled_homer=imrotate(imresize(shifted_homer,(scale_by/(abs(topy(i)-bottomy(i))))),angle);
rot_shifted_homer_noback=imrotate(shifted_homer_noback,(angle));

%make versions which are normalized to the mean intensity in the shaft
shaftx=[shafttopleftx shafttoprightx shaftbottomrightx shaftbottomleftx];
shafty=[shafttoplefty shafttoprighty shaftbottomrighty shaftbottomlefty];
mask=poly2mask(shaftx, shafty, 301, 301);
rectangle_shaft_sted=sted3(mask);
rectangle_shaft_dio=filt_db(mask);
rectangle_shaft_homer=homer(mask);

shaft_meanintensity_sted=mean(mean(rectangle_shaft_sted));
shaft_meanintensity_dio=mean(mean(rectangle_shaft_dio));
shaft_meanintensity_homer=mean(mean(rectangle_shaft_homer));

rot_shifted_sted_normalized2shaft=(rot_shifted_sted./shaft_meanintensity_sted);
rot_shifted_sted_noback_normalized2shaft=(rot_shifted_sted_noback./shaft_meanintensity_sted);
rot_shifted_dio_normalized2shaft=(rot_shifted_dio./shaft_meanintensity_dio);
rot_shifted_dio_noback_normalized2shaft=(rot_shifted_dio_noback./shaft_meanintensity_dio);
rot_shifted_homer_normalized2shaft=(rot_shifted_homer./shaft_meanintensity_homer);
rot_shifted_homer_noback_normalized2shaft=(rot_shifted_homer_noback./shaft_meanintensity_homer);

%take only central 150 pixels

startpoint=double(ceil((size(rot_shifted_sted,1)-150)/2));
startpoint2=double(ceil((size(rot_shifted_scaled_sted,1)-150)/2));
    sted_aligned=rot_shifted_sted(startpoint:startpoint+150,startpoint:startpoint+150);
    dio_aligned=rot_shifted_dio(startpoint:startpoint+150,startpoint:startpoint+150);
    homer_aligned=rot_shifted_homer(startpoint:startpoint+150,startpoint:startpoint+150);
    sted_aligned_resized=rot_shifted_scaled_sted(startpoint2:startpoint2+150,startpoint2:startpoint2+150);
    dio_aligned_resized=rot_shifted_scaled_dio(startpoint2:startpoint2+150,startpoint2:startpoint2+150);
    homer_aligned_resized=rot_shifted_scaled_homer(startpoint2:startpoint2+150,startpoint2:startpoint2+150);
    sted_aligned_noback=rot_shifted_sted_noback(startpoint:startpoint+150,startpoint:startpoint+150);
    dio_aligned_noback=rot_shifted_dio_noback(startpoint:startpoint+150,startpoint:startpoint+150);
    homer_aligned_noback=rot_shifted_homer_noback(startpoint:startpoint+150,startpoint:startpoint+150);
    sted_aligned_norm2shaft=rot_shifted_sted_normalized2shaft(startpoint:startpoint+150,startpoint:startpoint+150);
    dio_aligned_norm2shaft=rot_shifted_dio_normalized2shaft(startpoint:startpoint+150,startpoint:startpoint+150);
    homer_aligned_norm2shaft=rot_shifted_homer_normalized2shaft(startpoint:startpoint+150,startpoint:startpoint+150);
    sted_aligned_noback_norm2shaft=rot_shifted_sted_noback_normalized2shaft(startpoint:startpoint+150,startpoint:startpoint+150);
    dio_aligned_noback_norm2shaft=rot_shifted_dio_noback_normalized2shaft(startpoint:startpoint+150,startpoint:startpoint+150);
    homer_aligned_noback_norm2shaft=rot_shifted_homer_noback_normalized2shaft(startpoint:startpoint+150,startpoint:startpoint+150);

%add to average by classification
dlmwrite(strcat('sted_aligned_',num2str(i),'.txt'),sted_aligned);
dlmwrite(strcat('dio_aligned_',num2str(i),'.txt'),dio_aligned);
dlmwrite(strcat('homer_aligned_',num2str(i),'.txt'),homer_aligned);
dlmwrite(strcat('sted_aligned_resized_',num2str(i),'.txt'),sted_aligned_resized);
dlmwrite(strcat('dio_aligned_resized_',num2str(i),'.txt'),dio_aligned_resized);
dlmwrite(strcat('homer_aligned_resized_',num2str(i),'.txt'),homer_aligned_resized);
dlmwrite(strcat('sted_aligned_noback_',num2str(i),'.txt'),sted_aligned_noback);
dlmwrite(strcat('dio_aligned_noback_',num2str(i),'.txt'),dio_aligned_noback);
dlmwrite(strcat('homer_aligned_noback_',num2str(i),'.txt'),homer_aligned_noback);
dlmwrite(strcat('sted_aligned_norm2shaft_',num2str(i),'.txt'),sted_aligned_norm2shaft);
dlmwrite(strcat('dio_aligned_norm2shaft_',num2str(i),'.txt'),dio_aligned_norm2shaft);
dlmwrite(strcat('homer_aligned_norm2shaft_',num2str(i),'.txt'),homer_aligned_norm2shaft);
dlmwrite(strcat('sted_aligned_noback_norm2shaft_',num2str(i),'.txt'),sted_aligned_noback_norm2shaft);
dlmwrite(strcat('dio_aligned_noback_norm2shaft_',num2str(i),'.txt'),dio_aligned_noback_norm2shaft);
dlmwrite(strcat('homer_aligned_noback_norm2shaft_',num2str(i),'.txt'),homer_aligned_noback_norm2shaft);

%save the rectangle!

dlmwrite(strcat('rectangle_shaft_sted',num2str(i),'.txt'),rectangle_shaft_sted);
dlmwrite(strcat('rectangle_shaft_dio',num2str(i),'.txt'),rectangle_shaft_dio);
dlmwrite(strcat('rectangle_shaft_homer',num2str(i),'.txt'),rectangle_shaft_homer);

%parameter that notes how many files called sted_aligned_* are saved for
%each synapse..is used in the gui
no_sted_images=5;

if classification(i)==1
    Mush_sted_average=Mush_sted_average+sted_aligned;
    Mush_dio_average=Mush_dio_average+dio_aligned;
    Mush_homer_average=Mush_homer_average+homer_aligned;
    Mush_sted_resized_average=Mush_sted_resized_average+sted_aligned_resized;
    Mush_dio_resized_average=Mush_dio_resized_average+dio_aligned_resized;
    Mush_homer_resized_average=Mush_homer_resized_average+homer_aligned_resized;
    Mush_sted_noback_average=Mush_sted_noback_average+sted_aligned_noback;
    Mush_dio_noback_average=Mush_dio_noback_average+dio_aligned_noback;
    Mush_homer_noback_average=Mush_homer_noback_average+homer_aligned_noback;
    Mush_sted_norm2shaft_average=Mush_sted_norm2shaft_average+sted_aligned_norm2shaft;
    Mush_dio_norm2shaft_average=Mush_dio_norm2shaft_average+dio_aligned_norm2shaft;
    Mush_homer_norm2shaft_average=Mush_homer_norm2shaft_average+homer_aligned_norm2shaft;
    Mush_sted_noback_norm2shaft_average=Mush_sted_noback_norm2shaft_average+sted_aligned_noback_norm2shaft;
    Mush_dio_noback_norm2shaft_average=Mush_dio_noback_norm2shaft_average+dio_aligned_noback_norm2shaft;
    Mush_homer_noback_norm2shaft_average=Mush_homer_noback_norm2shaft_average+homer_aligned_noback_norm2shaft;
    
elseif classification(i)==2
    Flat_sted_average=Flat_sted_average+sted_aligned;
    Flat_dio_average=Flat_dio_average+dio_aligned;
    Flat_homer_average=Flat_homer_average+homer_aligned;
    Flat_sted_resized_average=Flat_sted_resized_average+sted_aligned_resized;
    Flat_dio_resized_average=Flat_dio_resized_average+dio_aligned_resized;
    Flat_homer_resized_average=Flat_homer_resized_average+homer_aligned_resized;
    Flat_sted_noback_average=Flat_sted_noback_average+sted_aligned_noback;
    Flat_dio_noback_average=Flat_dio_noback_average+dio_aligned_noback;
    Flat_homer_noback_average=Flat_homer_noback_average+homer_aligned_noback;
    Flat_sted_norm2shaft_average=Flat_sted_norm2shaft_average+sted_aligned_norm2shaft;
    Flat_dio_norm2shaft_average=Flat_dio_norm2shaft_average+dio_aligned_norm2shaft;
    Flat_homer_norm2shaft_average=Flat_homer_norm2shaft_average+homer_aligned_norm2shaft;
    Flat_sted_noback_norm2shaft_average=Flat_sted_noback_norm2shaft_average+sted_aligned_noback_norm2shaft;
    Flat_dio_noback_norm2shaft_average=Flat_dio_noback_norm2shaft_average+dio_aligned_noback_norm2shaft;
    Flat_homer_noback_norm2shaft_average=Flat_homer_noback_norm2shaft_average+homer_aligned_noback_norm2shaft;
else
    Other_sted_average=Other_sted_average+sted_aligned;
    Other_dio_average=Other_dio_average+dio_aligned;
    Other_homer_average=Other_homer_average+homer_aligned;  
    Other_sted_resized_average=Other_sted_resized_average+sted_aligned_resized;
    Other_dio_resized_average=Other_dio_resized_average+dio_aligned_resized;
    Other_homer_resized_average=Other_homer_resized_average+homer_aligned_resized;
    Other_sted_noback_average=Other_sted_noback_average+sted_aligned_noback;
    Other_dio_noback_average=Other_dio_noback_average+dio_aligned_noback;
    Other_homer_noback_average=Other_homer_noback_average+homer_aligned_noback;
    Other_sted_norm2shaft_average=Other_sted_norm2shaft_average+sted_aligned_norm2shaft;
    Other_dio_norm2shaft_average=Other_dio_norm2shaft_average+dio_aligned_norm2shaft;
    Other_homer_norm2shaft_average=Other_homer_norm2shaft_average+homer_aligned_norm2shaft;
    Other_sted_noback_norm2shaft_average=Other_sted_noback_norm2shaft_average+sted_aligned_noback_norm2shaft;
    Other_dio_noback_norm2shaft_average=Other_dio_noback_norm2shaft_average+dio_aligned_noback_norm2shaft;
    Other_homer_noback_norm2shaft_average=Other_homer_noback_norm2shaft_average+homer_aligned_noback_norm2shaft;
end
catch
    disp('An error occured during the alignment!')
end
%previously average was written here.


end
end

end
dlmwrite('Mush_sted_average.txt',(Mush_sted_average./(sum(classification(:)==1))));
dlmwrite('Mush_dio_average.txt',(Mush_dio_average./(sum(classification(:)==1))));
dlmwrite('Mush_homer_average.txt',(Mush_homer_average./(sum(classification(:)==1))));

dlmwrite('Mush_sted_resized_average.txt',(Mush_sted_resized_average./(sum(classification(:)==1))));
dlmwrite('Mush_dio_resized_average.txt',(Mush_dio_resized_average./(sum(classification(:)==1))));
dlmwrite('Mush_homer_resized_average.txt',(Mush_homer_resized_average./(sum(classification(:)==1))));

dlmwrite('Mush_sted_noback_average.txt',(Mush_sted_noback_average./(sum(classification(:)==1))));
dlmwrite('Mush_dio_noback_average.txt',(Mush_dio_noback_average./(sum(classification(:)==1))));
dlmwrite('Mush_homer_noback_average.txt',(Mush_homer_noback_average./(sum(classification(:)==1))));

dlmwrite('Mush_sted_norm2shaft_average.txt',(Mush_sted_norm2shaft_average./(sum(classification(:)==1))));
dlmwrite('Mush_dio_norm2shaft_average.txt',(Mush_dio_norm2shaft_average./(sum(classification(:)==1))));
dlmwrite('Mush_homer_norm2shaft_average.txt',(Mush_homer_norm2shaft_average./(sum(classification(:)==1))));

dlmwrite('Mush_sted_noback_norm2shaft_average.txt',(Mush_sted_noback_norm2shaft_average./(sum(classification(:)==1))));
dlmwrite('Mush_dio_noback_norm2shaft_average.txt',(Mush_dio_noback_norm2shaft_average./(sum(classification(:)==1))));
dlmwrite('Mush_homer_noback_norm2shaft_average.txt',(Mush_homer_noback_norm2shaft_average./(sum(classification(:)==1))));

dlmwrite('Flat_sted_average.txt',(Flat_sted_average./(sum(classification(:)==2))));
dlmwrite('Flat_dio_average.txt',(Flat_dio_average./(sum(classification(:)==2))));
dlmwrite('Flat_homer_average.txt',(Flat_homer_average./(sum(classification(:)==2))));

dlmwrite('Flat_sted_resized_average.txt',(Flat_sted_resized_average./(sum(classification(:)==2))));
dlmwrite('Flat_dio_resized_average.txt',(Flat_dio_resized_average./(sum(classification(:)==2))));
dlmwrite('Flat_homer_resized_average.txt',(Flat_homer_resized_average./(sum(classification(:)==2))));

dlmwrite('Flat_sted_noback_average.txt',(Flat_sted_noback_average./(sum(classification(:)==2))));
dlmwrite('Flat_dio_noback_average.txt',(Flat_dio_noback_average./(sum(classification(:)==2))));
dlmwrite('Flat_homer_noback_average.txt',(Flat_homer_noback_average./(sum(classification(:)==2))));

dlmwrite('Flat_sted_norm2shaft_average.txt',(Flat_sted_norm2shaft_average./(sum(classification(:)==1))));
dlmwrite('Flat_dio_norm2shaft_average.txt',(Flat_dio_norm2shaft_average./(sum(classification(:)==1))));
dlmwrite('Flat_homer_norm2shaft_average.txt',(Flat_homer_norm2shaft_average./(sum(classification(:)==1))));

dlmwrite('Flat_sted_noback_norm2shaft_average.txt',(Flat_sted_noback_norm2shaft_average./(sum(classification(:)==1))));
dlmwrite('Flat_dio_noback_norm2shaft_average.txt',(Flat_dio_noback_norm2shaft_average./(sum(classification(:)==1))));
dlmwrite('Flat_homer_noback_norm2shaft_average.txt',(Flat_homer_noback_norm2shaft_average./(sum(classification(:)==1))));

dlmwrite('Other_sted_average.txt',(Other_sted_average./(sum(classification(:)==3))));
dlmwrite('Other_dio_average.txt',(Other_dio_average./(sum(classification(:)==3))));
dlmwrite('Other_homer_average.txt',(Other_homer_average./(sum(classification(:)==3))));

dlmwrite('Other_sted_resized_average.txt',(Other_sted_resized_average./(sum(classification(:)==3))));
dlmwrite('Other_dio_resized_average.txt',(Other_dio_resized_average./(sum(classification(:)==3))));
dlmwrite('Other_homer_resized_average.txt',(Other_homer_resized_average./(sum(classification(:)==3))));

dlmwrite('Other_sted_noback_average.txt',(Other_sted_noback_average./(sum(classification(:)==3))));
dlmwrite('Other_dio_noback_average.txt',(Other_dio_noback_average./(sum(classification(:)==3))));
dlmwrite('Other_homer_noback_average.txt',(Other_homer_noback_average./(sum(classification(:)==3))));

dlmwrite('Other_sted_norm2shaft_average.txt',(Other_sted_norm2shaft_average./(sum(classification(:)==1))));
dlmwrite('Other_dio_norm2shaft_average.txt',(Other_dio_norm2shaft_average./(sum(classification(:)==1))));
dlmwrite('Other_homer_norm2shaft_average.txt',(Other_homer_norm2shaft_average./(sum(classification(:)==1))));

dlmwrite('Other_sted_noback_norm2shaft_average.txt',(Other_sted_noback_norm2shaft_average./(sum(classification(:)==1))));
dlmwrite('Other_dio_noback_norm2shaft_average.txt',(Other_dio_noback_norm2shaft_average./(sum(classification(:)==1))));
dlmwrite('Other_homer_noback_norm2shaft_average.txt',(Other_homer_noback_norm2shaft_average./(sum(classification(:)==1))));

dlmwrite('vertical_shifts.txt',vertical_shifts);
dlmwrite('horizontal_shifts.txt',horizontal_shifts);
dlmwrite('rotation_angles.txt',rotation_angles);
else
    disp(strcat('No files found in', pwd, ' or already analyzed, going to next folder'));
    continue
end
%cd ..
end

 