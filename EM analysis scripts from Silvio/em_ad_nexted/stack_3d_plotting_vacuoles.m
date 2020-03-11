function yyy;

cd ('W:\#COMMON\Natalia\Tubulocistern separated layers');

pixel_size=2.2; % nm
vesikel_radius=25;

 % Klein k (2-3) => relariv schnell, aber nicht perfekt rund
 % grosser k (4-6) => langsam, aber rund
 k=3;

basename='*_ves_numbers.txt';

[stat, mess]=fileattrib(strcat(basename));
 

close;

start=1;    finish=numel(mess); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set figure preferences

axis vis3d
set(gca,'visible','off');
view(37,20);
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%Vacuoles (non labeled)
[stat, mess]=fileattrib('vac_vert*.txt');
if stat==1
for i=1:numel(mess)
    
vert=dlmread(strcat('vac_vert',num2str(i),'.txt'));
supraf=dlmread(strcat('vac_supraf',num2str(i),'.txt'));
if numel(vert)>6
p=patch('vertices',vert,'faces',supraf,'edgecolor','none','edgealpha',0,'facecolor',[0.4 0 0.5],'facealpha',0.85);% 0.7 0.7 0.7 gray  1 0.5 0 color
reducepatch(p,0.1);
end;
end;
drawnow;
end;







material ([0.5 0.3 0.5 1]);
h = camlight('headlight');
%lighting gouraud;


% material ([1 0.3 0.5 1]);
% h = camlight('headlight');
 lighting gouraud;
% camlight('left');
return;