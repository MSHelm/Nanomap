function sgetline_contrast;

global Movi xx yy r matrix memornot vesicler contrastor old_Movi

Movi=old_Movi;
hh=get(contrastor,'value');
ccc=find(Movi>hh);
Movi(ccc)=hh;


 himg=imagesc(Movi(:,:),'tag','him'); axis equal;
 
 if memornot==1
  e=uicontrol('tag','ddd','style','text',...
            'position',[200 0 200 30],'Backgroundcolor','g','ForegroundColor','k','FontWeight','bold',...
            'string','Vacuoles');   
elseif memornot==0
            e=uicontrol('tag','ddd','style','text',...
            'position',[200 0 200 30],'Backgroundcolor','r','ForegroundColor','k','FontWeight','bold',...
            'string','Active Zones'); 
  elseif memornot==2
     e=uicontrol('tag','ddd','style','text',...
            'position',[200 0 200 30],'Backgroundcolor','y','ForegroundColor','k','FontWeight','bold',...
            'string','Membrane'); 
   end;
