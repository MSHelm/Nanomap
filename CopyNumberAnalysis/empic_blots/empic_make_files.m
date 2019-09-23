function sgetline_make_files
paz=[];naz=[];pm=[];nm=[];
allpaz=[];allnaz=[];allpm=[];allnm=[];
pclus=[];nclus=[];allpclus=[];allnclus=[];

for i=1:2
    paz=[];naz=[];media=0;
    
    paz=dlmread(strcat('clear_',num2str(i),'.txt'));

    naz=dlmread(strcat('unclear_',num2str(i),'.txt'));
    
    paz(:)=paz(:)*(-1);
    naz(:)=naz(:)*(-1);
  
   

   
    
    

   allpaz(numel(allpaz)+1:numel(allpaz)+numel(paz))=paz(1:numel(paz));
   allnaz(numel(allnaz)+1:numel(allnaz)+numel(naz))=naz(1:numel(naz));

    
    
    
    
    
end;
dlmwrite('photo_clear.txt',allpaz');
dlmwrite('photo_unclear.txt',allnaz');


for i=10:15
    paz=[];naz=[];media=0;
    
    paz=dlmread(strcat('clear__con_',num2str(i),'.txt'));

    paz(:)=paz(:)*(-1);


   allpaz(numel(allpaz)+1:numel(allpaz)+numel(paz))=paz(1:numel(paz));
    
  
    
    
    
    
end;
dlmwrite('unphoto_clear.txt',allpaz');


empic_hists;