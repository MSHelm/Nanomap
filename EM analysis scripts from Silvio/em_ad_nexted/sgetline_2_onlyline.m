function sgetline_2

global Movi xx yy memornot matrix matrix_old

    set(gcf,'windowbuttonmotionfcn','sroi03');
    
       matrix_old=matrix;
    
x33=[];y33=[];
%xx=[]; yy=[];
if memornot==0

for j=2:numel(xx)
    [xxx, yyy]=sgetline_int(xx(j-1),xx(j),yy(j-1),yy(j));
     x33=[x33;xxx(1:max(1,end-1))]; y33=[y33;yyy(1:max(1,end-1))];
 end;
 line('Xdata',y33,'Ydata',x33,'Color','r');
 sizm=size(matrix);
 matrix(sizm(1)+1:sizm(1)+numel(x33),1)=x33;
 matrix(sizm(1)+1:sizm(1)+numel(y33),2)=y33;
   set(gcf,'windowbuttondownfcn','sgetline_0');
   
elseif memornot==1
    
for j=2:numel(xx)
    [xxx, yyy]=sgetline_int(xx(j-1),xx(j),yy(j-1),yy(j));
     x33=[x33;xxx(1:max(1,end-1))]; y33=[y33;yyy(1:max(1,end-1))];
 end;
 line('Xdata',y33,'Ydata',x33,'Color','g');
 sizm=size(matrix);
 if sizm(2)<14
     x33(numel(x33)+1:numel(x33)+10)=-1;
     y33(numel(y33)+1:numel(y33)+10)=-1;
 matrix(1:numel(x33),13)=x33;
 matrix(1:numel(y33),14)=y33;

 else
     x33(numel(x33)+1:numel(x33)+10)=-1;
     y33(numel(y33)+1:numel(y33)+10)=-1;
     axa=matrix(:,13);
     ccc=find(axa==0);
     numberpix=numel(axa)-numel(ccc);
     matrix(numberpix+1:numberpix+numel(x33),13)=x33;
     matrix(numberpix+1:numberpix+numel(y33),14)=y33;
 end;    
     
   set(gcf,'windowbuttondownfcn','sgetline_0');
   
  
elseif memornot==2
    
for j=2:numel(xx)
    [xxx, yyy]=sgetline_int(xx(j-1),xx(j),yy(j-1),yy(j));
     x33=[x33;xxx(1:max(1,end-1))]; y33=[y33;yyy(1:max(1,end-1))];
 end;
 line('Xdata',y33,'Ydata',x33,'Color','b');
 sizm=size(matrix);
 if sizm(2)<16
     x33(numel(x33)+1:numel(x33)+10)=-1;
     y33(numel(y33)+1:numel(y33)+10)=-1;
 matrix(1:numel(x33),15)=x33;
 matrix(1:numel(y33),16)=y33;

 else
     x33(numel(x33)+1:numel(x33)+10)=-1;
     y33(numel(y33)+1:numel(y33)+10)=-1;
     axa=matrix(:,15);
     ccc=find(axa==0);
     numberpix=numel(axa)-numel(ccc);
     matrix(numberpix+1:numberpix+numel(x33),15)=x33;
     matrix(numberpix+1:numberpix+numel(y33),16)=y33;
 end;    
     
   set(gcf,'windowbuttondownfcn','sgetline_0');
   
else
    
       
for j=2:numel(xx)
    [xxx, yyy]=sgetline_int(xx(j-1),xx(j),yy(j-1),yy(j));
     x33=[x33;xxx(1:max(1,end-1))]; y33=[y33;yyy(1:max(1,end-1))];
 end;
 line('Xdata',y33,'Ydata',x33,'Color','y');
  sizm=size(matrix);
  
  %added from vacuoles
       x33(numel(x33)+1:numel(x33)+10)=-1;
     y33(numel(y33)+1:numel(y33)+10)=-1;
     axa=matrix(:,3);
     ccc=find(axa==0);
     numberpix=numel(axa)-numel(ccc);
     matrix(numberpix+1:numberpix+numel(x33),3)=x33;
     matrix(numberpix+1:numberpix+numel(y33),4)=y33;
  
%  matrix(1:numel(x33),3)=x33;
%  matrix(1:numel(y33),4)=y33;
%  
 set(gcf,'windowbuttondownfcn','sgetline_0');
   

end;
    


        

 xx=[]; yy=[];
 



