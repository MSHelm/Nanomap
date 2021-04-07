function stack_3d;
azx=[];azy=[];mx=[];my=[];cx=[];cy=[];pvesx=[];pvesy=[];uvesx=[];uvesy=[];dimensx=0;dimensy=0;mz=[];azz=[];cz=[];uvesz=[];pvesz=[];

cd ('W:\#COMMON\Natalia\Tubulocistern separated layers');

pixel_size=2.2; % nm
dicke=100;


dicke=dicke/pixel_size;
basename='*_*.txt';

%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
% Active zone - x = first column; y=second column
% Membrane - x = 3rd column; y=4th colum
% Normal vesicles - x = 5th column; y = 6th column
% dense-core vesicles - x = 7th column; y = 8th column [empty for now, as we have not seen any]
% Normal vesicles, distance to the active zone = 9th column - not useful
% for 3D
% Normal vesicles, distance to the membrane = 10th column - not useful for
% 3D
% dense-core vesicles, distance to the active zone = 11th column - not useful for
% 3D
% dense-core vesicles, distance to the membrane = 12th column - not useful for
% 3D
% Vacuoles - x = 13th column; y=14th column
% Mitochondria - x = 15th column; y=16th column
% The vacuole separators (index number) are in column 17 [for all the x
% and y values of the first vacuole (in columns 13 and 14) this column will have ones in the
% respective positions; for the second vacuole in the particular image
% there will be twos, etc.
% The mitochondria separators (index number) are in column 18 - same as for
% vacuoles
% Column 19 does nothing
% note that all columns are padded with zeros 
% all values are in pixels - and pixel size is 2.2 nm
% the distance between sections, or in other words the section thickness,
% is 70 nm (approximately, of course)
% we expect that the structures shrunk by ~20% versus the original
% situation


[stat, mess]=fileattrib(strcat(basename))
start=1;


% for i=1:numel(mess)
%     a=dlmread(mess(i).Name);
%     a(:,1:16)=a(:,1:16)*pixel_size;
%     dlmwrite(mess(i).Name,a);
% end;

finish=numel(mess);

disp('working on unlabeled vacuoles and making their vertices');

vac_verts_nr=1;

for i=start:finish
    
    

    
    
    r1=(mess(i).Name);



    
bigmatrix=dlmread(r1);
finder=find(bigmatrix(:,13))>0;
findernr=numel(finder);
vacx=bigmatrix(1:findernr,13);
vacy=bigmatrix(1:findernr,14);

ccc=find(vacx>0); vacx=vacx(ccc); vacy=vacy(ccc);

vacx=vacx*2.2;
vacy=vacy*2.2;

vacz=vacx-vacx; vacz(1:numel(vacz))=(i-1)*100;


line(vacx,vacy,vacz, 'linestyle','none','marker','o');

vacs=[];
vacs(:,1)=vacx;
vacs(:,2)=vacy;
vacs(:,3)=vacz;

dlmwrite(strcat('vacuole_',num2str(i),'.txt'),vacs);;
end;














