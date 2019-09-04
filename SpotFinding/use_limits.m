function automatic_sted_raj_cy3;

global positioner old_movi old_small_movi small_movi orange green sted old_orange old_green pixel_size limits the_sizer pos1
global contrastor1 contrastor2 contrastor3 old_sted rr1 hex hey xxes yyes background_orange background_green imagenr movi

load 'use_last';


     i=4; movib=movi(:,:,i);
     small_movi(:,:,i)=movib(pos1(1):pos1(2),pos1(3):pos1(4));


greenm=small_movi(:,:,1);
redm=small_movi(:,:,2);
sted=small_movi(:,:,4);

for i=1:numel(orangex)
    try
    gmmatrix=greenm(round(orangex(i))-250:round(orangex(i))+250,round(orangey(i))-250:round(orangey(i))+250);
    redmmatrix=redm(round(orangex(i))-250:round(orangex(i))+250,round(orangey(i))-250:round(orangey(i))+250);
    stedmatrix=sted(round(orangex(i))-250:round(orangex(i))+250,round(orangey(i))-250:round(orangey(i))+250);


rmmm=[];
rmmm(:,:,2)=gmmatrix;
rmmm(:,:,1)=redmmatrix;
rmmm(:,:,3)=stedmatrix;


 dlmwrite(strcat(rr1,'_',num2str(positioner),'_spots',num2str(i),'.txt'),rmmm);
    catch
    end
end;


 figure; text(0.3,0.5, 'READY');
      pause(0.5);
      close; 
      
      disp('READY READY READY READY READY READY READY');
      sroi_next_for_summed_planes;
% az_dist=[];
% vesdist=[];
% orange_matrix=[];
% 
% ccc=find(orange>0);
% siz=size(orange);
% [xx yy]=ind2sub([siz(1) siz(2)],ccc);
% orangex=xx;
% orangey=yy;
% 
%        pk=pkfnd(sted,0,6);
%        cnt=cntrd(sted,pk,6);
%        pos=cnt(:,1:2);
%  
%        stedx=pos(:,2);
%        stedy=pos(:,1);
% 
%        
%        ccc=find(sted==0);
%        back=mean(old_sted(ccc));
%     
%  
%        
% minimuri=[];
% minimuri_2=[];
% sums=[];
% angles=[];
% angles2=[];
% 
% %figure;
% 
% for k=1:numel(stedx)
% x=stedx(k);
% y=stedy(k);
%     distx=[];disty=[];
%     distx=greenx;
%     disty=greeny;
%     distx(:)=distx(:)-x;
%     disty(:)=disty(:)-y;
%     distx(:)=distx(:).^2;
%     disty(:)=disty(:).^2;
%     distx=distx+disty;
%     distx(:)=sqrt(distx(:));
% 
% 
%     angle=greenx-x;
%     angle=angle./distx;
%     
%     angle2=greeny-y;
%     angle2=angle2./distx;
%     
%     
%     
% mmm=min(min(distx));
% minimuri(k)=mmm;
% ccc=find(distx==mmm);
% minimuri_2(k)=ccc(1);
% angles(k)=asind(angle(ccc(1)));
% angles2(k)=asind(angle2(ccc(1)));
% 
% sums(k)=sum(sum(old_sted(x-4:x+4,y-4:y+4)))-81*back;
% 
% % ff=old_sted;
% % ff(x-4:x+4,y-4:y+4)=max(max(old_sted));
% %imagesc(ff); drawnow;
% %pause(0.5);
% 
% 
% 
% 
% 
% end;
% 
% 
% minimuri=minimuri*pixel_size;
% 
% az_dist=minimuri;
% 
% minimuri=[];
% for k=1:numel(stedx)
% x=stedx(k);
% y=stedy(k);
%     distx=[];disty=[];
%     distx=orangex;
%     disty=orangey;
%     distx(:)=distx(:)-x;
%     disty(:)=disty(:)-y;
%     distx(:)=distx(:).^2;
%     disty(:)=disty(:).^2;
%     distx=distx+disty;
%     distx(:)=sqrt(distx(:));
% mmm=min(min(distx));
% minimuri(k)=mmm;
% end;
% minimuri=minimuri*pixel_size;
% 
% ves_dist=minimuri;
% 
%        drawing_matrix=[];
%        drawing_matrix(:,1)=az_dist;
%        drawing_matrix(:,2)=minimuri_2;
%        drawing_matrix(:,3)=sums;
%        drawing_matrix(:,4)=angles;    
%        drawing_matrix(:,5)=angles2; 
%        drawing_matrix(:,6)=ves_dist;
%        
%      
%        dlmwrite(strcat(rr1,'_',num2str(positioner),'_distances.txt'),drawing_matrix);
%           close;
% 
% end