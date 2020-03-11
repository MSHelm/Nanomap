function vacuole_labeler;
azx=[];azy=[];mx=[];my=[];cx=[];cy=[];pvesx=[];pvesy=[];uvesx=[];uvesy=[];dimensx=0;dimensy=0;mz=[];azz=[];cz=[];uvesz=[];pvesz=[];

cd C:\data_2008\october2008\katharina_EM;
pixel_size=2.2; % nm
basename='Tv137_Grid6_20_T6_2.txt';


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



[stat, mess]=fileattrib(strcat('*',basename));
start=1;
finish=numel(mess);

disp('working on unlabeled vacuoles');

for i=start:finish
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%labeling the different vacuoles with
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%different numbers 
    disp(i);
    if i<10
    r1=strcat('0',num2str(i),basename);
    else
        r1=strcat(num2str(i),basename);
    end;
    
      if i+1<10
    r2=strcat('0',num2str(i+1),basename);
    else
        r2=strcat(num2str(i+1),basename);
    end;
    
    bigmatrix=dlmread(r1);
    

vacx=bigmatrix(:,13);
vacy=bigmatrix(:,14);
vac_counter=1;
if numel(vacx)>0
for j=1:numel(vacx)
    if vacx(j)>0
        bigmatrix(j,17)=vac_counter;
    elseif vacx(j)==-1 & j<(numel(vacx))
        if vacx(j+1)>0
        vac_counter=vac_counter+1;
        end;
    end;
end;
end;
 
bvacx=bigmatrix(:,15);
bvacy=bigmatrix(:,16);
bvac_counter=1;
if numel(bvacx)>0
for j=1:numel(bvacx)
    if bvacx(j)>0
        bigmatrix(j,18)=bvac_counter;
    elseif bvacx(j)==-1 & j<(numel(bvacx))
        if bvacx(j+1)>0
        bvac_counter=bvac_counter+1;
        end;
    end;
end;
end;
 


dlmwrite(r1,bigmatrix);


end;

%         figuring out connections between 




































