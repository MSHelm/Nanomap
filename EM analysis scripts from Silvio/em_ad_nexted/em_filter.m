function em_filter;

cd 'C:\rizzoli_documents\miscellania\denker_manuscript\Revision\high K\destained\selected';

[stat, mess]=fileattrib('*.tif');

if stat==1
    a=imread(mess(1).Name);
    
    subplot(2,2,1);
    
    siz=size(a);
    if numel(siz)>2
    a=rgb2gray(a);
    end;
    
    imagesc(a);colormap(gray(255));
    
    subplot(2,2,2);    
    a=255-a;
  
%   surface(double(a),'edgecolor','none'); 
   
    imagesc(a); colormap(gray(255));



background=imopen(a,strel('disk',500));
a_filt=imsubtract(a,background);
subplot(2,2,3);

imagesc(a_filt);colormap(gray);

subplot(2,2,4);
a_filt=255-a_filt;
imagesc(a_filt);colormap(gray);
end;