function sgetline
global Movi xx yy r matrix memornot vesicler contrastor old_Movi imagenr cella cellb movi name
 
 
cd 'C:\Users\mhelm1\Desktop\toast'

name='Spine600b3_'  

movi=[];
imagenr=1;
 [stat, mess]=fileattrib(strcat('*',name,'*.tif'));
 for i=1:numel(mess); movi(:,:,i)=imread(mess(i).Name); end;
     

niveau=0;


matrix=[]; xx=[]; yy=[]; 
memornot=0;
Movi=movi(:,:,imagenr);

aba=strcat(name,'_',num2str(imagenr),'.tif');
r=aba(1:numel(aba)-4);


 old_Movi=Movi;
 colormap(gray(255));
 himg=imagesc(Movi(:,:),'tag','him'); axis equal; title (r);
 
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

      

 b=uicontrol('tag','ddd','style','pushbutton','callback','sgetline1_2',...
            'position',[0 0 100 30],...
            'string','AZ, Vac or M');
        
e=uicontrol('tag','ddd','style','pushbutton','callback','sgetline1_4',...
            'position',[100 0 100 30],...
            'string','Undo');      
 
 e=uicontrol('tag','ddd','style','pushbutton','callback','sroi_next',...
             'position',[500 0 100 30],...
             'string','Next');    
  e=uicontrol('tag','ddd','style','pushbutton','callback','sroi_previous',...
             'position',[400 0 100 30],...
             'string','Previous');           
 contrastor=uicontrol('tag','fff',...
      'style','slider','callback','sgetline_contrast',...
      'position',[0 31 100 30],'min',0,'max',255,...
      'sliderstep',[0.0255 0.1],'tooltipstring','cutoff');       
        
        set(contrastor,'value',255);
        
set(gcf,'windowbuttondownfcn','sgetline_0');
set(gcf,'windowbuttonupfcn','sgetline_2_onlyline');