function make_file;

pixel_size=2.2324;
cella={};
mother_folder='D:\LabRotII\EM';

[stat, mess]=fileattrib('*');
for i=1:numel(mess)
    if mess(i).directory
        cella{numel(cella)+1}=mess(i).Name;
    end;
end;
        

for klm=1:numel(cella)
    
    cd(cella{klm});
    
    photo_dist=[];
    unphoto_dist=[];
    az_photo_dist=[];
    au_unphoto_dist=[];
    
    
    [stat, mess]=fileattrib('Tv*.txt');
    stat
    if stat==1
        for i=1:numel(mess)
            a=dlmread(mess(i).Name);
            photo=[]; photo=a(:,12); ccc=find(photo>0); photo=photo(ccc);
            unphoto=[]; unphoto=a(:,10); ccc=find(unphoto>0); unphoto=unphoto(ccc);
            
            az_photo=[]; az_photo=a(:,11); ccc=find(az_photo>0); az_photo=az_photo(ccc);
            az_unphoto=[]; az_unphoto=a(:,9); ccc=find(az_unphoto>0); az_unphoto=az_unphoto(ccc);
            
            
            photo_dist(numel(photo_dist)+1:numel(photo_dist)+numel(photo))=photo;
            unphoto_dist(numel(unphoto_dist)+1:numel(unphoto_dist)+numel(unphoto))=unphoto;
            
                        
            az_photo_dist(numel(az_photo_dist)+1:numel(az_photo_dist)+numel(az_photo))=az_photo;
            az_unphoto_dist(numel(az_unphoto_dist)+1:numel(az_unphoto_dist)+numel(az_unphoto))=az_unphoto;
            
        end;

   matrix=[]; matrix2=[];
   matrix(1:numel(unphoto_dist),1)=unphoto_dist*pixel_size;;
   matrix(1:numel(photo_dist),2)=photo_dist*pixel_size;
   dlmwrite(strcat('mem_dist.txt'),matrix);
       
   unphoto_dist=unphoto_dist*pixel_size;
   photo_dist=photo_dist*pixel_size;

   x=[0:25:1000];
   hist_unphoto=hist(unphoto_dist,x);
   hist_photo=hist(photo_dist,x);
   matrix2(:,1)=x';
   matrix2(:,2)=hist_unphoto'*100/sum(hist_unphoto);
   matrix2(:,3)=hist_photo'*100/sum(hist_photo);

      dlmwrite(strcat('hist_mem_dist.txt'),matrix2);
      
      
         matrix=[]; matrix2=[];
   matrix(1:numel(az_unphoto_dist),1)=az_unphoto_dist*pixel_size;;
   matrix(1:numel(az_photo_dist),2)=az_photo_dist*pixel_size;
   dlmwrite(strcat('az_dist.txt'),matrix);
       
   az_unphoto_dist=az_unphoto_dist*pixel_size;
   az_photo_dist=az_photo_dist*pixel_size;

   x=[0:25:1000];
   hist_az_unphoto=hist(az_unphoto_dist,x);
   hist_az_photo=hist(az_photo_dist,x);
   matrix2(:,1)=x';
   matrix2(:,2)=hist_az_unphoto'*100/sum(hist_az_unphoto);
   matrix2(:,3)=hist_az_photo'*100/sum(hist_az_photo);

      dlmwrite(strcat('hist_az_dist.txt'),matrix2);
      
      
      
    end;
end;