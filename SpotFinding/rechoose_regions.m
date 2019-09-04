function rechoose_regions;

global mat_file_counter positioner old_movi old_small_movi small_movi orange green sted old_orange old_green pixel_size limits the_sizer pos1
global contrastor1 contrastor2 contrastor3 old_sted rr1 hex hey xxes yyes background_orange background_green imagenr
global  mat_file_counter orange sted green rr1 positioner small_movi xxes yyes pixel_size orangex orangey old_sted old_small_movi pos1 rr movi

cd 'Y:\user\mhelm1\Nanomap_Analysis\Replicate1\NA-beta-1_PFA';
mat_files=dir('*_ch0.mat');
mat_file_counter=1;

load_region

    function load_region
    try
    %number1=i; number2=number1+1; 
    limits=[3 3 3]; %taken from program_start_for_summed_planes function   
    limit_orange=limits(2);
    limit_green=limits(1);
    limit_sted=limits(3);
    % name the new area by increasing positioner
    positioner=1; %we always only have 1 region...
   
    
    %load already aligned file and regionselected file

    a=load(mat_files(mat_file_counter).name);
    small_movi=a.small_movi;
    figure;


    % generate the selected area matrix, and a second copy in "old_small_movi"
    % with only the orange and STED images (atto confocal is by now irrelevant

     old_small_movi=[];
     old_small_movi(:,:,1)=small_movi(:,:,1);
     old_small_movi(:,:,2)=small_movi(:,:,2);
     old_small_movi(:,:,3)=small_movi(:,:,4); 
     size(old_small_movi)


     %%%%%%
     small_movi_filtered=[];
        H=fspecial('average',3);
        for i=1:3
           small_movi_filtered(:,:,i)=medfilt2(old_small_movi(:,:,i));
           small_movi_filtered(:,:,i)=imfilter(old_small_movi(:,:,i),H,'replicate');
        end;

    %%%%%%%%%%%%%%% the actual images to work with, orange and sted

        green=small_movi_filtered(:,:,1);
       % green=bpass(green,0,15);
        orange=small_movi_filtered(:,:,2);
        orange=bpass(orange,0,15);
        sted=small_movi_filtered(:,:,3);  

        old_orange=orange;
        old_sted=sted;
        old_green=green;

    %%%%%%%%%%%%%%%%%%%%%% getting a bw image of the area, saved as "pols"
    pols=old_small_movi(:,:,1);
    ccc=find(pols>0); pols(ccc)=1;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ccc_pols=find(pols==1);

       contrastor3=uicontrol('tag','fff',...
          'style','slider','callback',{@sroi_levels3},...
          'position',[0 0 100 30],'min',0,'max',(max(green(ccc_pols))),...
          'sliderstep',[0.0255 0.1]);    
    set(contrastor3,'value',(mean(green(ccc_pols)) + limit_green));
    sroi_levels3;


       contrastor1=uicontrol('tag','fff',...
          'style','slider','callback',{@sroi_levels1},...
          'position',[200 0 100 30],'min',0,'max',(max(orange(ccc_pols))),...
          'sliderstep',[0.0255 0.1]);    
    set(contrastor1,'value',(mean(orange(ccc_pols)) + limit_orange));
    sroi_levels1;


    %    contrastor2=uicontrol('tag','fff',...
    %       'style','slider','callback',{@sroi_levels2},...
    %       'position',[300 0 100 30],'min',0,'max',(max(sted(ccc_pols))),...
    %       'sliderstep',[0.0255 0.1]);    
    % set(contrastor2,'value',(mean(sted(ccc_pols)) + limit_sted));
    % sroi_levels2;






    cleaning=uicontrol('tag','clense','style','pushbutton', 'callback',{@make_do},...
          'position',[100 0 100 30],'string','Calculate');
     % cleaning2=uicontrol('tag','clense','style','pushbutton', 'callback',{@make_do2},...
     %     'position',[200 0 100 30],'string','Auto was OK','tooltipstring','erase all drawings');
      % cleaning2=uicontrol('tag','clense','style','pushbutton', 'callback',{@show_do},...
      %    'position',[400 0 100 30],'string','Show Auto','tooltipstring','erase all drawings');

        subplot(2,2,1); imagesc(small_movi(:,:,1)); axis equal;
        subplot(2,2,2); imagesc(small_movi(:,:,2)); axis equal; 
      %subplot(2,3,3); imagesc(small_movi(:,:,4)); axis equal;


      drawnow;
    set(get(handle(gcf),'JavaFrame'),'Maximized',1);
    catch
        disp(strcat('No .mat file for ',mat_files(mat_file_counter).name,' was found -> Going to next Series'))
        mat_file_counter=mat_file_counter+1;
        load_region
    end
    end


function make_do(source,eventdata)
%name=strcat(rr(1:numel(rr)-4),'_lenient','.mat') %inserted this here since we do not have the name defined in this function before.
name=strcat(mat_files(mat_file_counter).name(1:end-4),'_lenient','.mat') %inserted this here since we do not have the name defined in this function before.
save('use_last','small_movi','pos1','orangex','orangey');
save(name,'movi','small_movi','pos1','orangex','orangey');

greenm=old_small_movi(:,:,1);
redm=old_small_movi(:,:,2);
sted=old_small_movi(:,:,3);


for i=1:numel(orangex)
    try
    gmmatrix=greenm(round(orangex(i))-150:round(orangex(i))+150,round(orangey(i))-150:round(orangey(i))+150);
    redmmatrix=redm(round(orangex(i))-150:round(orangex(i))+150,round(orangey(i))-150:round(orangey(i))+150);
    stedmatrix=sted(round(orangex(i))-150:round(orangex(i))+150,round(orangey(i))-150:round(orangey(i))+150);


rmmm=[];
rmmm(:,:,2)=gmmatrix;
rmmm(:,:,1)=redmmatrix;
rmmm(:,:,3)=stedmatrix;


 dlmwrite(strcat(mat_files(mat_file_counter).name(1:end-4),'_',num2str(positioner),'_spots_lenient_',num2str(i),'.txt'),rmmm);
    catch
    end
end;
close  

disp(strcat('Analyzed', num2str(mat_file_counter), 'out of',num2str(size(mat_files,1)), 'mat files.'))
mat_file_counter=mat_file_counter+1;

if mat_file_counter<=size(mat_files,1)
    load_region
else
    disp('Finished all .mat files! Great job!')
    return
end


%sroi_next_for_summed_planes;
end
end

function sroi_levels1(source,eventdata)

global  orange sted contrastor1 contrastor2 old_orange old_sted the_sizer bwlgreen orangex orangey old_small_movi
orangex=[];
orangey=[];
orange=old_orange;
hh=get(contrastor1,'value');

ccc=find(orange<hh);orange(ccc)=0;
ccc=find(bwlgreen==0); orange(ccc)=0;

%%%%%% orange


 
     orange=imerode(orange,strel('disk',1));
     orange=imdilate(orange,strel('disk',1));

%      pk=pkfnd(orange,0,6);
%      cnt=cntrd(orange,pk,6);
%      pos=cnt(:,1:2);
%      siz_pos=size(pos);
%      
%     siz=size(pos)

old_real_orange=old_small_movi(:,:,2);
 bworange=im2bw(orange);
 bwlorange=bwlabel(bworange);
 
 for i=1:max(max(bwlorange))
ccc=find(bwlorange==i);
   if numel(ccc)<70
       bwlorange(ccc)=0;                 
   end;
 end;
 
 bwlorange=bwlabel(bwlorange);
   for i=1:max(max(bwlorange))
 ccc=find(bwlorange==i);
          siz=size(bwlorange);
          [xx yy]=ind2sub([siz(1) siz(2)],ccc);
          mm=old_real_orange(ccc);
          orangex(numel(orangex)+1)=sum(xx.*mm)/sum(mm);
          orangey(numel(orangey)+1)=sum(yy.*mm)/sum(mm);
  end;
 subplot(2,2,4);

     imagesc(im2bw(bwlorange));      axis equal;

 hh
end
% function sroi_levels2(source,eventdata)
% 
% global  orange sted contrastor1 contrastor2 old_orange old_sted the_sizer bwlgreen old_small_movi
% 
% sted=old_sted;
% hh=get(contrastor2,'value');
% 
% ccc=find(sted<hh);sted(ccc)=0;
% ccc=find(bwlgreen==0); sted(ccc)=0;
% %%%%%% orange
% 
%   sted=bpass(sted,0,30);
%  
%      sted=imerode(sted,strel('disk',1));
%      sted=imdilate(sted,strel('disk',1));
% 
% 
%        pk=pkfnd(sted,0,6);
%        cnt=cntrd(sted,pk,6);
%        pos=cnt(:,1:2);
% 
%       
%     subplot(2,3,6);
%   imagesc(im2bw(sted));     axis equal;
%   
%   %      siz=size(pos)
% %      
%       colors='rgbcmyk';
%       siz=size(pos);
%         for k=1:siz(1)
%             p=randperm(numel(colors));
%             line(pos(k,1),pos(k,2),'linestyle','none','marker','o','markeredgecolor','none','markerfacecolor',colors(p(1)),'markersize',3);
%         end;
%  hh
% 
% 
% end
function sroi_levels3(source,eventdata)

global  orange green contrastor3 old_orange old_green old_small_movi greenx greeny the_sizer bwlgreen old_small_movi

green=old_green;
hh=get(contrastor3,'value');

ccc=find(green<hh);green(ccc)=0;

%%%%%% orange


 
     green=imerode(green,strel('disk',1));
     green=imdilate(green,strel('disk',1));

%      pk=pkfnd(green,0,6);
%      cnt=cntrd(green,pk,6);
%      pos=cnt(:,1:2);
%      siz_pos=size(pos);
%      
%     siz=size(pos)


 bwgreen=im2bw(green); 
 bwgreen=imerode(bwgreen,strel('disk',3));
 bwgreen=imfill(bwgreen,'holes');
 bwgreen=imdilate(bwgreen,strel('disk',4)); 

 bwgreen=imfill(bwgreen,'holes');
  bwlgreen=bwlabel(bwgreen);
 for i=1:max(max(bwlgreen))
ccc=find(bwlgreen==i);
   if numel(ccc)<1700
       bwlgreen(ccc)=0;                 
   end;
 end;
 
bwlgreen=bwlabel(bwlgreen);
 bwgreen1=im2bw(bwlgreen);
 bwgreen2=imerode(bwgreen1,strel('disk',1));
 ccc=find(bwgreen1==1 & bwgreen2==0);
 
 bwgreen3=bwgreen-bwgreen; bwgreen3(ccc)=1;
 %dlmwrite('bwgreen.txt',old_small_movi(:,:,1));
 



%greenx=[]; greeny=[];


%   for i=1:max(max(bwlgreen))
% ccc=find(bwlgreen==i);
%          siz=size(bwlgreen);
%          [xx yy]=ind2sub([siz(1) siz(2)],ccc);
%          mm=old_real_green(ccc);
%          greenx(numel(greenx)+1)=sum(xx.*mm)/sum(mm);
%          greeny(numel(greeny)+1)=sum(yy.*mm)/sum(mm);
%  end;
 
       
       subplot(2,2,3); imagesc((bwlgreen));     axis equal;

  
  hh
 
end

