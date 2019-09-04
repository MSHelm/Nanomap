function initiate_manual_axis_sort
clear all
global counter dio homer sted classification clickno curX curY cd_path

addpath(genpath('Z:\user\mhelm1\Nanomap_Analysis\Matlab\ManualAxisClicking'));

cd_path='C:\Users\mhelm1\Desktop\newimages\Syntaxin8-PFA_UID-Stx8_2019-04-15';
cd(cd_path);
counter=1;
clickno=1;
curX=[1 1 1 1];curY=[1 1 1 1];

[stat, mess]=fileattrib('*_spots*.txt');
[blub,order]=sort({mess.Name});mess=mess(order);order=[]; %sort to avoid unordered spot files due to server bugs


spots_full=dlmread(mess(1).Name);
classification=zeros(1,numel(mess));
homer=spots_full(1:301,1:301); dio=spots_full(1:301,302:602); sted=spots_full(1:301,603:903);
dlmwrite('Mu_average.txt',dio);
dlmwrite('Fl_average.txt',dio);
dlmwrite('Oth_average.txt',dio);

guiaxis

end

