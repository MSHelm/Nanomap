function make_file;

pixel_size=2.2324;
cella={};
mother_folder='C:\data_2009\september2009\farah';

cd(mother_folder);
[stat, mess]=fileattrib('*');
for i=1:numel(mess)
    if mess(i).directory
        cella{numel(cella)+1}=mess(i).Name;
    end;
end;
        

for klm=1:numel(cella)
    
    cd(cella{klm});
    
azs=[];
vesdist=[];

    
    [stat, mess]=fileattrib('Tv*.txt');
    stat
    if stat==1
        for i=1:numel(mess)
            a=dlmread(mess(i).Name);
            
            az=[]; ves=[];
            
            az=a(:,1); ccc=find(az>0); az=az(ccc);
            ves=a(:,5); ccc=find(ves>0); ves=ves(ccc);
            azs(i,1)=numel(az);
            azs(i,2)=numel(ves); 
            azs(i,3)=azs(i,2)*1000/azs(i,1)*pixel_size;
            
         
            
            vesx=[]; vesy=[];
            vesx=a(:,5); vesy=a(:,6);
            ccc=find(vesx>0); vesx=vesx(ccc); vesy=vesy(ccc);
            
            vesd=[];
            for k=1:numel(vesx)
x=vesx(k);
y=vesy(k);
    distx=[];disty=[];
    distx=vesx; disty=vesy;
    distx(:)=distx(:)-x;
    disty(:)=disty(:)-y;
    distx(:)=distx(:).^2;
    disty(:)=disty(:).^2;
    distx=distx+disty;
    distx(:)=sqrt(distx(:));
    ccc=find(distx>0); distx=distx(ccc);
    mmm=min(min(distx));
    vesd(k)=mmm;
            end;
            
 vesdist(numel(vesdist)+1:numel(vesdist)+numel(vesd))=vesd;
        end;
    end;
    
    dlmwrite('azs_stuff.txt',azs);
    
   dlmwrite(strcat('ves_dist.txt'),vesdist');
       
   x=[0:2:100];
   hist_vesdist=hist(vesdist,x);
   hist_vesdist=hist_vesdist*100/sum(hist_vesdist);
   
      dlmwrite(strcat('hist_vesdist.txt'),hist_vesdist');
      
  
end;