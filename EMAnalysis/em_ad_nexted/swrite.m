function swrite (varargin)

global Movi xx yy r matrix memornot imagenr


gg=strcat(r,'_for_ves_numbers.txt')

matrix(1,17)=0;

%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%Active zone - x = first column; y=second column
%Membrane - x = 3rd column; y=4th column
%Unphotoconverted vesicles - x = 5th column; y = 6th column
%Photoconverted vesicles - x = 7th column; y = 8th column
% Unphotoconverted vesicles, distance to the active zone = 9th column
% Unphotoconverted vesicles, distance to the membrane = 10th column
% Photoconverted vesicles, distance to the active zone = 11th column
% Photoconverted vesicles, distance to the membrane = 12th column
% Vacuoles - x = 13th column; y=14th column
% Labeled Vacuoles - x = 15th column; y=16th column
% The vacuole separators (index number) are in column 17
% The labeled vacuole separators (index number) are in column 18 
matrix(:,16)

uves=matrix(:,5);
uvesfinder=find(uves>0);

pves=matrix(:,7);
pvesfinder=find(pves>0);

mem=matrix(:,3);
memfinder=find(mem>0 | mem==-1);

az=matrix(:,1);
azfinder=find(az>0);

vacf=matrix(:,13);
vacfinder=find(vacf>0 | vacf==-1);

vacf2=matrix(:,15);
vacfinder2=find(vacf2>0 | vacf2==-1);

if uvesfinder>0

if numel(azfinder)>0
for k=1:numel(uvesfinder)
x=matrix(k,5);
y=matrix(k,6);
    distx=[];disty=[];
    distx=matrix(1:numel(azfinder),1);
    disty=matrix(1:numel(azfinder),2);
    distx(:)=distx(:)-x;
    disty(:)=disty(:)-y;
    distx(:)=distx(:).^2;
    disty(:)=disty(:).^2;
    distx=distx+disty;
    distx(:)=sqrt(distx(:));
mmm=min(min(distx));

matrix(k,9)=mmm;
end;
end;

for k=1:numel(uvesfinder)
x=matrix(k,5);
y=matrix(k,6);
    distx=[];disty=[];
    distx=matrix(1:numel(memfinder),3);
    disty=matrix(1:numel(memfinder),4);
    distx(:)=distx(:)-x;
    disty(:)=disty(:)-y;
    distx(:)=distx(:).^2;
    disty(:)=disty(:).^2;
    distx=distx+disty;
    distx(:)=sqrt(distx(:));
mmm=min(min(distx));

matrix(k,10)=mmm;
end;
end;


if pvesfinder>0

if numel(azfinder)>0
for k=1:numel(pvesfinder)
x=matrix(k,7);
y=matrix(k,8);
    distx=[];disty=[];
    distx=matrix(1:numel(azfinder),1);
    disty=matrix(1:numel(azfinder),2);
    distx(:)=distx(:)-x;
    disty(:)=disty(:)-y;
    distx(:)=distx(:).^2;
    disty(:)=disty(:).^2;
    distx=distx+disty;
    distx(:)=sqrt(distx(:));
mmm=min(min(distx));
matrix(k,11)=mmm;
end;
end;


for k=1:numel(pvesfinder)
x=matrix(k,7);
y=matrix(k,8);
    distx=[];disty=[];
    distx=matrix(1:numel(memfinder),3);
    disty=matrix(1:numel(memfinder),4);
    distx(:)=distx(:)-x;
    disty(:)=disty(:)-y;
    distx(:)=distx(:).^2;
    disty(:)=disty(:).^2;
    distx=distx+disty;
    distx(:)=sqrt(distx(:));
mmm=min(min(distx));

matrix(k,12)=mmm;
end;

end;




vacx=matrix(:,13);
vacy=matrix(:,14);
vac_counter=1;
if numel(vacx)>0
for j=1:numel(vacx)
    if vacx(j)>0
        matrix(j,17)=vac_counter;
    elseif vacx(j)==-1 & j<(numel(vacx))
        if vacx(j+1)>0
        vac_counter=vac_counter+1;
        end;
    end;
end;
end;
 
bvacx=matrix(:,15);
bvacy=matrix(:,16);
bvac_counter=1;
if numel(bvacx)>0
for j=1:numel(bvacx)
    if bvacx(j)>0
        matrix(j,18)=bvac_counter;
    elseif bvacx(j)==-1 & j<(numel(bvacx))
        if bvacx(j+1)>0
        bvac_counter=bvac_counter+1;
        end;
    end;
end;
end;
 
matrix(1,19)=0;


close;
figure;
try
 line('Xdata',matrix(1:numel(azfinder),2),'Ydata',matrix(1:numel(azfinder),1),'Color','r',...
     'Linestyle','none','Marker','o','MarkerSize',2,'MarkerEdgeColor','r','MarkerFaceColor','r');
catch;
end;

try
 line('Xdata',matrix(1:numel(vacfinder),14),'Ydata',matrix(1:numel(vacfinder),13),'Color','g',...
     'Linestyle','none','Marker','o','MarkerSize',2,'MarkerEdgeColor','g','MarkerFaceColor','g');
catch;
end;

try
 line('Xdata',matrix(1:numel(vacfinder2),16),'Ydata',matrix(1:numel(vacfinder2),15),'Color','b',...
     'Linestyle','none','Marker','o','MarkerSize',2,'MarkerEdgeColor','b','MarkerFaceColor','b');
catch;
end;

 line('Xdata',matrix(1:numel(memfinder),4),'Ydata',matrix(1:numel(memfinder),3),'Color','y','Marker','o','Markeredgecolor','y',...
     'MarkerSize',2);
 try
line('Xdata',matrix(1:numel(uvesfinder),6),'Ydata',matrix(1:numel(uvesfinder),5),...
    'Linestyle','none','Marker','o','MarkerSize',5,'MarkerEdgeColor','c','MarkerFaceColor','y');
 catch;
 end;
 
 try
line('Xdata',matrix(1:numel(pvesfinder),8),'Ydata',matrix(1:numel(pvesfinder),7),...
    'Linestyle','none','Marker','o','MarkerSize',5,'MarkerEdgeColor','c','MarkerFaceColor','r');
catch;
 end;

 drawnow;
 disp(gg)
 dlmwrite(gg,matrix);
 
 pause(2);
 
 sroi_next;

 
 
 
 
