function program_start_auto
addpath(genpath('Z:\user\mhelm1\Nanomap_Analysis\Matlab\SpotFinding'));
cd_path='C:\Users\mhelm1\Desktop\newimages\Syntaxin8-PFA_UID-Stx8_2019-04-15';
for imnr1=0:2:18
    imnr2=imnr1+1;
    program_start_for_summed_planes(cd_path,imnr1,imnr2)
    uiwait;
end
end
