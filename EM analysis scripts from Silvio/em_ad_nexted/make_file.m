function make_file;

pixel_size=2.2324;

mother_folder='D:\LabRotII\EM';

%conditionen={1}='CA';
%conditionen={2}='HiK';
%conditionen={3}='Ts';



cella{1}='droso_d-analyse 2 Hz';
cella{2}='droso_d-analyse 30 Hz';

for klm=1:numel(cella)
    cd(strcat(mother_folder,'\',cella{klm}));
    
    photo_dist=[];
    unphoto_dist=[];
    
    [stat, mess]=fileattrib('Tv*.txt');
    stat
    if stat==1
        for i=1:numel(mess)
            a=dlmread(mess(i).Name);
            photo=[]; photo=a(:,12); ccc=find(photo>0); photo=photo(ccc);
            unphoto=[]; unphoto=a(:,10); ccc=find(unphoto>0); unphoto=unphoto(ccc);
            
            photo_dist(numel(photo_dist)+1:numel(photo_dist)+numel(photo))=photo;
            unphoto_dist(numel(unphoto_dist)+1:numel(unphoto_dist)+numel(unphoto))=unphoto;
        end;
   % cd ..
    matrix=[];
   matrix(1:numel(unphoto_dist),1)=unphoto_dist*pixel_size;;
   matrix(1:numel(photo_dist),2)=photo_dist*pixel_size;
   dlmwrite(strcat(cella{klm},'_mem_dist.txt'),matrix);
       
   unphoto_dist=unphoto_dist*pixel_size;
   photo_dist=photo_dist*pixel_size;
   
   cd ..
   x=[0:25:1000];
   hist_unphoto=hist(unphoto_dist,x);
   hist_photo=hist(photo_dist,x);
   matrix2(:,1)=x';
   matrix2(:,2)=hist_unphoto'*100/sum(hist_unphoto);
   matrix2(:,3)=hist_photo'*100/sum(hist_photo);
   strcat(cella{klm},'_hist_mem_dist.txt')
      dlmwrite(strcat(cella{klm},'_hist_mem_dist.txt'),matrix2);
    end;
end; 
    
 %   [stat, mess]=fileattrib('*_mem_dist.txt');
    
    
    
 %   for i=1:numel(mess)
 %       for j=1:numel(conditionen)
 %           if mess(i).Name(1:numel(conditionen{j})==conditionen{j}
 %               ccc=dlmread(conditionen
        
        
        
            