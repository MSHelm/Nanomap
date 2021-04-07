function vesan

cd 'C:\data_2009\october2009\Shibire Exp2 Analysis\141009';

[stat, mess]=fileattrib('*.tif');



% dir *.tif;
% rr=input('The first confocal file      ','s');


for i=4:4
    figure;
    redimg=imread('Tv27_ShiRTc_109126D_grid1_20.tif');
  %  redimg=max(max(redimg))-redimg;
    
    subplot(1,3,1);
    imagesc(redimg); 
     axis off; axis equal; colormap(gray);

 background=imopen(redimg,strel('disk',10));
 redimg=imsubtract(redimg,background);
 
   H=fspecial('average',3);
  redimg=imfilter(redimg, H,'replicate');
 
%  H=fspecial('average',100);
%  background=imfilter(redimg, H,'replicate');
%  redimg=redimg-background; 
  
% background=medfilt2(redimg, [30 30]);
% redimg=redimg-background;   
subplot(1,3,2);
imagesc(background); axis off; axis equal; colormap(gray);


  subplot(1,3,3);
  imagesc(redimg, [0 round(2*mean2(redimg))]); axis off; axis equal; colormap(gray);
end;