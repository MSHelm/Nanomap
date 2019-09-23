function sgetline_contrast;

global movi memornot contrastor2 contrastor new_movi

% new_movi=movi;
 hh=get(contrastor,'value')
 
 
 hh2=get(contrastor2,'value')
% ccc=find(new_movi>hh);
% new_movi(ccc)=hh;


 himg=imagesc(new_movi(:,:),[hh hh2]); axis equal;
 
