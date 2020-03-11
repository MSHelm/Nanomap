function yyy;

cd ('Y:\user\mhelm1\Electron Microscopy\spines\for_models\for_model_3D_mushroom');

pixel_size=3.067; % nm
vesikel_radius=22;

 % Klein k (2-3) => relariv schnell, aber nicht perfekt rund
 % grosser k (4-6) => langsam, aber rund
 k=5;

basename='*_ves_numbers.txt';

[stat, mess]=fileattrib(strcat(basename));
 

close;

start=1;    finish=numel(mess); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set figure preferences

axis vis3d
set(gca,'visible','off');
view(37,20);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%Active zones
[stat, mess]=fileattrib('avert*.txt');
if stat==1
for i=1:numel(mess)
 vert=dlmread(strcat('avert',num2str(i),'.txt'));
 supraf=dlmread(strcat('asupraf',num2str(i),'.txt'));
 if numel(vert)>6
 p=patch('vertices',vert,'faces',supraf,'edgecolor','none','edgealpha',0,'facecolor',[1 0 0],'facealpha',0.5);% 0.1 0.1 0.1 gray 1 0 0  color
 reducepatch(p,0.1);
end;
end;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%Membrane
try
for i=start:finish-1
 vert=dlmread(strcat('first_mvert',num2str(i),'.txt'));
 supraf=dlmread(strcat('first_msupraf',num2str(i),'.txt'));
 p=patch('vertices',vert,'faces',supraf,'edgecolor','none','edgealpha',0,'facecolor',[1 0.5 0],'facealpha',0.2);% 0.7 0.7 0.7 gray  1 0.5 0 color
 reducepatch(p,0.1);
end;
drawnow;
catch
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%Membrane
try
for i=start:finish-1
 vert=dlmread(strcat('mvert',num2str(i),'.txt'));
 supraf=dlmread(strcat('msupraf',num2str(i),'.txt'));
 p=patch('vertices',vert,'faces',supraf,'edgecolor','none','edgealpha',0,'facecolor',[1 0.5 0],'facealpha',0.2);% 0.7 0.7 0.7 gray  1 0.5 0 color
 reducepatch(p,0.1);
end;
drawnow;
catch
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%Vacuoles (non labeled)
[stat, mess]=fileattrib('vac_vert*.txt');
if stat==1
for i=1:numel(mess)
    
vert=dlmread(strcat('vac_vert',num2str(i),'.txt'));
supraf=dlmread(strcat('vac_supraf',num2str(i),'.txt'));
if numel(vert)>6
p=patch('vertices',vert,'faces',supraf,'edgecolor','none','edgealpha',0,'facecolor',[1 0.8 0.8],'facealpha',0.85);% 0.7 0.7 0.7 gray  1 0.5 0 color
reducepatch(p,0.1);
end;
end;
drawnow;
end;

[stat, mess]=fileattrib('black_vac_vert*.txt');
if stat==1
for i=1:numel(mess)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%Vacuoles (labeled)  
 vert=dlmread(strcat('black_vac_vert',num2str(i),'.txt'));
 supraf=dlmread(strcat('black_vac_supraf',num2str(i),'.txt'));
 if numel(vert)>6
 p=patch('vertices',vert,'faces',supraf,'edgecolor','none','edgealpha',0,'facecolor',[0.4 0 0.5],'facealpha',0.85);% 0.7 0.7 0.7 gray  1 0.5 0 color
 reducepatch(p,0.1);
 end;
end;
drawnow;
end;


num_ves=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Plot labeled vesicles');
for ii=start:finish
 %   bigmatrix=dlmread(strcat(r,rr,num2str(ii),'XX.txt'));
 %   cdist=[]; mdist=[]; adist=[];

uvesx=dlmread(strcat('unphotovesx',num2str(ii),'.txt'));
uvesy=dlmread(strcat('unphotovesy',num2str(ii),'.txt'));
uvesz=dlmread(strcat('unphotovesz',num2str(ii),'.txt'));
num_ves=num_ves+numel(uvesz)

pvesx=dlmread(strcat('photovesx',num2str(ii),'.txt'));
pvesy=dlmread(strcat('photovesy',num2str(ii),'.txt'));
pvesz=dlmread(strcat('photovesz',num2str(ii),'.txt'));

%cdist=bigmatrix(1:numel(pvesx),15);
%mdist=bigmatrix(1:numel(pvesx),14);
%adist=bigmatrix(1:numel(pvesx),13);
%disp(mdist);
%disp(ii);
posz_label=[];
[ss, mess]=fileattrib(strcat('posz_labeled',num2str(ii),'.txt'));
if ss==1
    posz_label=dlmread(strcat('posz_labeled',num2str(ii),'.txt'));
end;

for i=1:numel(pvesx)
%if adist(i)<114.75

 x=pvesx(i); y=pvesy(i); z=pvesz(i);
 b=randperm(100);

 
 if ss==0  
      if ii<finish
 z=z+(b(1)/pixel_size);
 end;
     posz_label(i)=z;
 else
     z=posz_label(i);
 end;
     
  % Klein k (2-3) => relariv schnell, aber nicht perfekt rund
 % grosser k (4-6) => langsam, aber rund
%k = 4;

n = 2^k-1;
theta = pi*(-n:2:n)/n;
phi = (pi/2)*(-n:2:n)'/n;
x = x + (vesikel_radius/pixel_size)*cos(phi)*cos(theta);
y = y + (vesikel_radius/pixel_size)*cos(phi)*sin(theta);
z = z + (vesikel_radius/pixel_size)*sin(phi)*ones(size(theta));


s=surface(x,y,z);
bbb=surf2patch(s);
delete(s);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%Vesicles (labeled)
p=patch(bbb,'edgecolor','none','edgealpha',0,'facecolor',[0.4 0 0.5],'facealpha',0.7); % 0.4 0.4 0.4 gray; 0.4 0 0.5 color
reducepatch(p,1);
%end;
%end;
end;
if ss==0
dlmwrite(strcat('posz_labeled',num2str(ii),'.txt'),posz_label);
end;
%elseif adist(i)>130 & mdist(i)<130
%    p=patch(bbb,'edgecolor','none','edgealpha',0,'facecolor',[0.5 0.5 0],'facealpha',0.5);    
%elseif adist(i)>130 & mdist(i)>130 & cdist(i)<50
%    p=patch(bbb,'edgecolor','none','edgealpha',0,'facecolor',[0 0 0.8],'facealpha',0.5); 
%elseif adist(i)>130 & mdist(i)>130 & cdist(i)>50
%    p=patch(bbb,'edgecolor','none','edgealpha',0,'facecolor',[0 0.7 0.7],'facealpha',0.5); 
%end;





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Plot unlabeled vesicles');
% uadist=bigmatrix(1:numel(uvesx),16);
posz_unlabel=[];
[ss, mess]=fileattrib(strcat('posz_unlabeled',num2str(ii),'.txt'));
if ss==1
    posz_unlabel=dlmread(strcat('posz_unlabeled',num2str(ii),'.txt'));
end;

for i=1:numel(uvesx)
%if uadist(i)<114.75


b=randperm(100);
 x=uvesx(i); y=uvesy(i); z=uvesz(i);

 
 
 if ss==0  
      if ii<finish
 z=z+(b(1)/pixel_size);
 end;
     posz_unlabel(i)=z;
 else
     z=posz_unlabel(i);
 end;
     

 % Klein k (2-3) => relariv schnell, aber nicht perfekt rund
 % grosser k (4-6) => langsam, aber rund
%k = 4;


n = 2^k-1;
theta = pi*(-n:2:n)/n;
phi = (pi/2)*(-n:2:n)'/n;


x = x + (vesikel_radius/pixel_size)*cos(phi)*cos(theta);
y = y + (vesikel_radius/pixel_size)*cos(phi)*sin(theta);
z = z + (vesikel_radius/pixel_size)*sin(phi)*ones(size(theta));


s=surface(x,y,z);
bbb=surf2patch(s);
delete(s);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%Vesicles (non labeled)
p=patch(bbb,'edgecolor','none','edgealpha',0,'facecolor',[1 0.9 0.9],'facealpha',0.9); 
reducepatch(p,1);
%end;
% if ss==0
% dlmwrite(strcat('posz_unlabeled',num2str(ii),'.txt'),posz_unlabel);
end;




end;



material ([0.5 0.3 0.5 1]); h = camlight('headlight');
%lighting gouraud;


% material ([1 0.3 0.5 1]);
% h = camlight('headlight');
 lighting gouraud;
% camlight('left');
return;