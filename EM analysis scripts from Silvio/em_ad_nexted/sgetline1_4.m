function sgetline1_4
global Movi xx yy memornot matrix vesicler matrix_old

if memornot>3
    
if vesicler==1
       bb=matrix(:,5);
       finder=find(bb>0);
       if numel(finder)>0
       matrix(numel(finder),5)=0;
       matrix(numel(finder),6)=0;
       end;
       
elseif vesicler==2
           bb=matrix(:,7);
        
       finder=find(bb>0);
          if numel(finder)>0
       matrix(numel(finder),7)=0;
       matrix(numel(finder),8)=0;
           end;
end;

 himg=imagesc(Movi(:,:),'tag','him'); axis equal;
 
 sizem=size(matrix);
 
 if sizem(2)>4
 uves=matrix(:,5);
uvesfinder=find(uves>0);
line('Xdata',matrix(1:numel(uvesfinder),6),'Ydata',matrix(1:numel(uvesfinder),5),...
    'Linestyle','none','Marker','o','MarkerSize',5,'MarkerEdgeColor','c','MarkerFaceColor','y');
 end;
 
 if sizem(2)>6
pves=matrix(:,7);
pvesfinder=find(pves>0);
line('Xdata',matrix(1:numel(pvesfinder),8),'Ydata',matrix(1:numel(pvesfinder),7),...
    'Linestyle','none','Marker','o','MarkerSize',5,'MarkerEdgeColor','c','MarkerFaceColor','r');
 end;
 
 try
mem=matrix(:,3);
memfinder=find(mem>0);
  line('Xdata',matrix(1:numel(memfinder),4),'Ydata',matrix(1:numel(memfinder),3),'Color','y',...
     'Linestyle','none','Marker','o','MarkerSize',1,'MarkerEdgeColor','y','MarkerFaceColor','y');
 catch
 end
 
 try
az=matrix(:,1);
azfinder=find(az>0);
   line('Xdata',matrix(1:numel(azfinder),2),'Ydata',matrix(1:numel(azfinder),1),'Color','r',...
     'Linestyle','none','Marker','o','MarkerSize',1,'MarkerEdgeColor','r','MarkerFaceColor','r');
 catch
 end
 
  try
 vc=matrix(:,13);
 vfinder=find(vc>0);
  line('Xdata',matrix(1:numel(vfinder),14),'Ydata',matrix(1:numel(vfinder),13),'Color','g',...
     'Linestyle','none','Marker','o','MarkerSize',1,'MarkerEdgeColor','g','MarkerFaceColor','g');
  catch
  end
  
  try
  vc=matrix(:,15);
 vfinder=find(vc>0);
  line('Xdata',matrix(1:numel(vfinder),16),'Ydata',matrix(1:numel(vfinder),15),'Color','b',...
     'Linestyle','none','Marker','o','MarkerSize',1,'MarkerEdgeColor','b','MarkerFaceColor','b');
  catch
  end
 
 
elseif memornot==3 | memornot==0 | memornot==1 | memornot==2
    
     himg=imagesc(Movi(:,:),'tag','him'); axis equal;
        matrix=matrix_old;
 
 
 try
mem=matrix(:,3);
memfinder=find(mem>0);
  line('Xdata',matrix(1:numel(memfinder),4),'Ydata',matrix(1:numel(memfinder),3),'Color','y',...
     'Linestyle','none','Marker','o','MarkerSize',1,'MarkerEdgeColor','y','MarkerFaceColor','y');
 catch
 end
 
 try
az=matrix(:,1);
azfinder=find(az>0);
   line('Xdata',matrix(1:numel(azfinder),2),'Ydata',matrix(1:numel(azfinder),1),'Color','r',...
     'Linestyle','none','Marker','o','MarkerSize',1,'MarkerEdgeColor','r','MarkerFaceColor','r');
 catch
 end
 
  try
 vc=matrix(:,13);
 vfinder=find(vc>0);
  line('Xdata',matrix(1:numel(vfinder),14),'Ydata',matrix(1:numel(vfinder),13),'Color','g',...
     'Linestyle','none','Marker','o','MarkerSize',1,'MarkerEdgeColor','g','MarkerFaceColor','g');
  catch
  end
  
  try
  vc=matrix(:,15);
 vfinder=find(vc>0);
  line('Xdata',matrix(1:numel(vfinder),16),'Ydata',matrix(1:numel(vfinder),15),'Color','b',...
     'Linestyle','none','Marker','o','MarkerSize',1,'MarkerEdgeColor','b','MarkerFaceColor','b');
  catch
  end
 
 
  

end;

