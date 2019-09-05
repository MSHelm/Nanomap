function program_copy_number_qualifiers

the_folder='Z:\user\mhelm1\Nanomap_Analysis\Data\total';
cd(the_folder);
DiffInt=load('Z:\user\mhelm1\Nanomap_Analysis\Data\total\DifferentialIntensities.mat');
DiffInt=DiffInt.tab;

names=DiffInt.Name;
UID=DiffInt.UID;
mush=DiffInt.Mean_sted_mush;
flat=DiffInt.Mean_sted_flat;
other=DiffInt.Mean_sted_other;

results={};

% [~,names]=xlsread('DifferentialIntensities.xlsx','A:A');
% [~,UID]=xlsread('DifferentialIntensities.xlsx','B:B');
% [mush, ~]=xlsread('DifferentialIntensities.xlsx','I:I');
% [flat, ~]=xlsread('DifferentialIntensities.xlsx','J:J');
% [other, ~]=xlsread('DifferentialIntensities.xlsx','K:K');

%read in spine type composition file
[~,~,spinetype_comp]=xlsread('SpineTypeComposition.xlsx');
percmush=spinetype_comp{2,3};
percflat=spinetype_comp{3,3};
percother=spinetype_comp{4,3};

%This was Silvios old stuff, but he needed to edit it in manually
%beforehand
% [percmush, ~]=xlsread('dioDifferentialIntensities.xlsx','names','H2:H2');
% [percflat, ~]=xlsread('dioDifferentialIntensities.xlsx','names','H3:H3');
% [percother, ~]=xlsread('dioDifferentialIntensities.xlsx','names','H4:H4');

percmush=percmush/100; percflat=percflat/100; percother=percother/100;
matrix=[];

for i=1:numel(mush)
    beta1=mush(i)/flat(i);
    beta2=mush(i)/other(i);
    formulamush=1/(percmush+(percflat/beta1)+(percother/beta2));
    formulaflat=formulamush/beta1;
    formulaother=formulamush/beta2;
    matrix(i,1)=formulamush;
    matrix(i,2)=formulaflat;
    matrix(i,3)=formulaother;
end
results=names;
results=cat(2,results,UID);
results=cat(2,results,num2cell(matrix));
xlswrite('SpineTypeCorrection.xlsx',results)

results=cell2table(results,'VariableNames',{'Name','UID','Corrected_Mush','Corrected_Flat','Corrected_Other',});
save('SpineTypeCorrection.mat','results');

end


% close all
% cd(the_folder); cellb={};
% names={}; zonesf=imread('flat_thin_zones_plus_background.tif'); %% max 11; background up = 16; background down = 17;
% zonesm=imread('mushroom_zones_plus_background.tif'); %% max 15; background up = 16; background down = 17;
% zoneso=imread('other_zones_plus_background.tif'); %% max 11; background up = 16; background down = 17;
% 
% matrixm=[]; matrixf=[]; matrixcorrsm=[];matrixcorrsf=[]; 
% [dsstat, dmmess]=fileattrib('*');
% for i=1:numel(dmmess); if dmmess(i).directory; cellb{numel(cellb)+1}=dmmess(i).Name; end; end;
% 
% corrs=[];
%  
% dios=zeros(151,151); homers=zeros(151,151);
% matrix=[];
% 
% for abcdef=1:numel(cellb); 
%     
% try    
%     disp(abcdef); name=cellb{abcdef}; disp(name); cd(name); name=name(47:numel(name));
%     
% flat1=dlmread('Flat_dio_average_Replicate1.txt'); 
% flat2=dlmread('Flat_dio_average_Replicate2.txt'); 
% mush1=dlmread('Mush_dio_average_Replicate1.txt'); 
% mush2=dlmread('Mush_dio_average_Replicate2.txt'); 
% other1=dlmread('Other_dio_average_Replicate1.txt'); 
% other2=dlmread('Other_dio_average_Replicate2.txt'); 
% 
% ccc=find(zonesf==16); flat1back=mean(flat1(ccc)); flat1=flat1/flat1back; flat2back=mean(flat2(ccc)); flat2=flat2/flat2back;
% ccc=find(zonesm==16); mush1back=mean(mush1(ccc)); mush1=mush1/mush1back; mush2back=mean(mush2(ccc)); mush2=mush2/mush2back;
% ccc=find(zoneso==16); other1back=mean(other1(ccc)); other1=other1/other1back; other2back=mean(other2(ccc)); other2=other2/other2back;
% 
% mm1=corr2(mush1,mush2); mm2=corr2(mush1,fliplr(mush2)); if mm1>=mm2; mush=(mush1+mush2)/2; else mush=(mush1+fliplr(mush2))/2; end
% mm1=corr2(flat1,flat2); mm2=corr2(flat1,fliplr(flat2)); if mm1>=mm2; flat=(flat1+flat2)/2; else flat=(flat1+fliplr(flat2))/2; end
% mm1=corr2(other1,other2); mm2=corr2(other1,fliplr(other2)); if mm1>=mm2; other=(other1+other2)/2; else other=(other1+fliplr(other2))/2; end
% 
% sizm=size(matrix);
% ccc1=find(zonesm>0 & zonesm<16); ccc2=find(zonesm==17); 
% matrix(sizm(1)+1,1)=mean(mush(ccc1));%*100/(mean(mush(ccc2)));
% 
% ccc1=find(zonesf>0 & zonesf<16); ccc2=find(zonesf==17); 
% matrix(sizm(1)+1,2)=mean(flat(ccc1));%*100/(mean(flat(ccc2)));
% 
% ccc1=find(zoneso>0 & zoneso<16); ccc2=find(zoneso==17); 
% matrix(sizm(1)+1,3)=mean(other(ccc1));%*100/(mean(other(ccc2)));
% 
% % figure
% % subplot(3,3,1); imagesc(flat1); axis equal;colorbar; title(name)
% % subplot(3,3,2); imagesc(flat2); axis equal;colorbar
% % subplot(3,3,3); imagesc(flat); axis equal;colorbar
% % subplot(3,3,4); imagesc(mush1); axis equal;colorbar
% % subplot(3,3,5); imagesc(mush2); axis equal;colorbar
% % subplot(3,3,6); imagesc(mush); axis equal;colorbar
% % subplot(3,3,7); imagesc(other1); axis equal;colorbar
% % subplot(3,3,8); imagesc(other2); axis equal;colorbar
% % subplot(3,3,9); imagesc(other); axis equal;colorbar
% 
% dlmwrite('Mush_DiO_norm_total.txt',mush);
% dlmwrite('Flat_DiO_norm_total.txt',flat);
% dlmwrite('Other_DiO_norm_total.txt',other);
% 
% 
% %ccc=find(zonesf<16);corrs(abcdef,1)=corr2(flat1(ccc),flat2(ccc));
% %ccc=find(zonesm<16);corrs(abcdef,2)=corr2(mush1(ccc),mush2(ccc));
% %corrs(abcdef,3)=corr2(flat1,mush1);
% %corrs(abcdef,4)=corr2(flat2,mush2);
% %corrs(abcdef,5)=corr2(flat1,mush2);
% %corrs(abcdef,6)=corr2(flat2,mush1);
% names{numel(names)+1}=name;
% 
% catch;
% end; 
% end
% 
% 
% figure; imagesc(matrix); colorbar
% cd (the_folder)
% dlmwrite('matrix_differential_intensities.txt',matrix)
% 
% xlswrite('test.xlsx',names','names');
% xlswrite('test.xlsx',matrix,'DiO_matrix');

% % % % % % % % % % % % for abcdef=1:numel(cellb); 
% % % % % % % % % % % %     
% % % % % % % % % % % % try    
% % % % % % % % % % % %     disp(abcdef); name=cellb{abcdef}; disp(name); cd(name); name=name(61:numel(name)); 
% % % % % % % % % % % % 
% % % % % % % % % % % % flat=dlmread('Flat_sted_average.txt'); mush=dlmread('Mush_sted_average.txt'); 
% % % % % % % % % % % % hflat=dlmread('Flat_homer_average.txt'); hmush=dlmread('Mush_homer_average.txt');
% % % % % % % % % % % % dflat=dlmread('Flat_dio_average.txt'); dmush=dlmread('Mush_dio_average.txt');
% % % % % % % % % % % % 
% % % % % % % % % % % % ccc=find(zonesm==16); mush=mush-mean(mush(ccc)); 
% % % % % % % % % % % % mm=[]; for i=1:15; ccc=find(zonesm==i); mm(i)=sum(mush(ccc)); end;
% % % % % % % % % % % % ccc=find(zonesm>0 & zonesm<16); mm=mm*100/sum(mush(ccc)); matrixm=cat(1,matrixm,mm);
% % % % % % % % % % % % 
% % % % % % % % % % % % ccc=find(zonesf==16); flat=flat-mean(flat(ccc)); 
% % % % % % % % % % % % mm=[]; for i=1:11; ccc=find(zonesf==i); mm(i)=sum(flat(ccc)); end;
% % % % % % % % % % % % ccc=find(zonesf>0 & zonesf<16); mm=mm*100/sum(flat(ccc)); matrixf=cat(1,matrixf,mm);
% % % % % % % % % % % % 
% % % % % % % % % % % % mm=[]; mm(1)=corr2(flat, hflat); mm(2)=corr2(flat,dflat); matrixcorrsf=cat(1,matrixcorrsf,mm);
% % % % % % % % % % % % mm=[]; mm(1)=corr2(mush, hmush); mm(2)=corr2(mush,dmush); matrixcorrsm=cat(1,matrixcorrsm,mm);
% % % % % % % % % % % % names{numel(names)+1}=name;
% % % % % % % % % % % % catch; end; end
% % % % % % % % % % % % figure;
% % % % % % % % % % % % subplot(1,2,1); imagesc(matrixf);colorbar
% % % % % % % % % % % % subplot(1,2,2); imagesc(matrixm);colorbar; 
% % % % % % % % % % % % cd (the_folder); dlmwrite('percs_flat_new.txt',matrixf); dlmwrite('percs_mushroom_new.txt',matrixm);
% % % % % % % % % % % % dlmwrite('corrs_flat.txt', matrixcorrsf); dlmwrite('corrs_mushroom.txt', matrixcorrsm);
% % % % % % % % % % % % disp(corr2(matrixf(:,1:6),matrixm(:,1:6)))
% % % % % % % % % % % % [h, p]=corrcoef(matrixf(:,1:6),matrixm(:,1:6))
% % % % % % % % % % % % 
% % % % % % % % % % % % xlswrite('test.xlsx',names','Sheet1'); xlswrite('test.xlsx',matrixf,'Sheet2'); xlswrite('test.xlsx',matrixm,'Sheet3');
% % % % % % % % % % % % xlswrite('test.xlsx',matrixcorrsf,'Sheet4'); xlswrite('test.xlsx',matrixcorrsm,'Sheet5'); 
% % % % % % % % % % % % 
% % % % % % % % % % % % ppflat=sum(matrixf(:,1:6)')';
% % % % % % % % % % % % ppmush=sum(matrixm(:,1:6)')';
% % % % % % % % % % % % dlmwrite('ppflat.txt',ppflat);
% % % % % % % % % % % % dlmwrite('ppmush.txt',ppmush);




% % % % % zones=[66 255 0
% % % % %     253 0 227
% % % % %     12 0 250
% % % % %     6 0 129
% % % % %     0 253 237
% % % % %     0 164 154
% % % % %     32 123 0
% % % % %     103 107 0 
% % % % %     157 0 141
% % % % %     243 252 0
% % % % %     253 114 0 
% % % % %     73 0 124
% % % % %     118 54 0
% % % % %     15 95 71
% % % % %     254 0 0];
% % % % % counter=0;
% % % % % 
% % % % % a=imread('dio_flat_binned_color2.tif');
% % % % % 
% % % % % a1=double(a(:,:,1)); a2=double(a(:,:,2)); a3=double(a(:,:,3));
% % % % % aa=double(a1-a1);
% % % % % sizz=size(zones);
% % % % % for i=1:sizz(1); ccc=find(a1==zones(i,1) & a2==zones(i,2) & a3==zones(i,3)); 
% % % % %     if numel(ccc)>0 
% % % % %         counter=counter+1;
% % % % %     aa(ccc)=counter; end;
% % % % % end;
% % % % % imagesc(aa)
% % % % % 
% % % % % imwrite(uint8(aa),'aa.tif','tif','Compression','none')






% % % close all
% % % 
% % % cd(the_folder);
% % % cellb={};
% % % 
% % % [dsstat, dmmess]=fileattrib('*');
% % % for i=1:numel(dmmess)
% % %     if dmmess(i).directory
% % %         cellb{numel(cellb)+1}=dmmess(i).Name;
% % %     end;
% % % end;
% % % 
% % % diomush=zeros(151,151); dioflat=zeros(151,151); homermush=zeros(151,151); homerflat=zeros(151,151); stedmush=zeros(151,151); stedflat=zeros(151,151); 
% % % 
% % % for abcdef=1:numel(cellb);
% % %     abcdef
% % %     name=cellb{abcdef}; 
% % %    
% % %     cd(name);
% % %  name=name(61:numel(name))
% % % try
% % %    % figure
% % %     dio=dlmread('Mush_dio_average.txt');    ccc=find(dio<mean2(dio)+1*std2(dio)); dio(ccc)=0; 
% % %     sted=dlmread('Mush_sted_average.txt');sted(ccc)=0; 
% % %     homer=dlmread('Mush_homer_average.txt');ccc=find(homer<mean2(homer)+3*std2(homer)); homer(ccc)=0; 
% % %     
% % %     diomush=diomush+dio+fliplr(dio); homermush=homermush+homer+fliplr(homer); stedmush=stedmush+sted+fliplr(sted);
% % %     
% % %   %  subplot(2,3,1); imagesc(dio); axis equal; title(name);
% % %   %  subplot(2,3,2); imagesc(homer); axis equal;
% % %   %  subplot(2,3,3); imagesc(sted); axis equal;
% % %     
% % %     dio=dlmread('Flat_dio_average.txt'); ccc=find(dio<mean2(dio)+1*std2(dio)); dio(ccc)=0; 
% % %     sted=dlmread('Flat_sted_average.txt');sted(ccc)=0;
% % %     homer=dlmread('Flat_homer_average.txt');ccc=find(homer<mean2(homer)+3*std2(homer)); homer(ccc)=0;
% % % 
% % %       
% % %     dioflat=dioflat+dio+fliplr(dio); homerflat=homerflat+homer+fliplr(homer); stedflat=stedflat+sted+fliplr(sted);
% % %     
% % %   %  subplot(2,3,4); imagesc(dio); axis equal;
% % %   %  subplot(2,3,5); imagesc(homer); axis equal;
% % %   %  subplot(2,3,6); imagesc(sted); axis equal; drawnow;%%%%pause(1);
% % %     
% % %  %%%%%%%  M = getframe;
% % %  %%%%%%%  M=frame2im(M);
% % %  %%%%%%%  imwrite(M,'axon_frap_curves.jpg','jpeg','Quality',100);
% % % catch;
% % % end;
% % % end;
% % % 
% % % cd(the_folder)
% % % 
% % % 
% % %   %  subplot(2,3,1); imagesc(diomush); axis equal; title(name);
% % %   %  subplot(2,3,2); imagesc(homermush); axis equal;
% % %   %  subplot(2,3,3); imagesc(stedmush); axis equal;
% % %     
% % %   %  subplot(2,3,4); imagesc(dioflat); axis equal;
% % %   %  subplot(2,3,5); imagesc(homerflat); axis equal;
% % %   %  subplot(2,3,6); imagesc(stedflat); axis equal; drawnow;%%%%pause(1);
% % % diomush=diomush/(2*numel(cellb));
% % % dioflat=dioflat/(2*numel(cellb));
% % % homermush=homermush/(2*numel(cellb));
% % % homerflat=homerflat/(2*numel(cellb));
% % % stedmush=stedmush/(2*numel(cellb));
% % % stedflat=stedflat/(2*numel(cellb));
% % %  
% % % dlmwrite('DiO_mushroom.txt',diomush);
% % % dlmwrite('DiO_flat.txt',dioflat);
% % % dlmwrite('homer_mushroom.txt',homermush);
% % % dlmwrite('homer_flat.txt',homerflat);
% % % dlmwrite('sted_mushroom.txt',stedmush);
% % % dlmwrite('sted_flat.txt',stedflat);
% % % 
% % %   
% % % dio2=[]; for i=1:37; for j=1:37; dio2(i,j)=sum(sum(diomush(4*i:4*i+1,4*j:4*j+1))); end; end; %%imagesc(dio2)
% % % homer2=[]; for i=1:37; for j=1:37; homer2(i,j)=sum(sum(homermush(4*i:4*i+1,4*j:4*j+1))); end; end; %%imagesc(homer2)
% % % sted2=[]; for i=1:37; for j=1:37; sted2(i,j)=sum(sum(stedmush(4*i:4*i+1,4*j:4*j+1))); end; end; %%imagesc(sted2)
% % % 
% % % dlmwrite('DiO_mushroom_binned.txt',dio2);
% % % dlmwrite('homer_mushroom_binned.txt',homer2);
% % % dlmwrite('sted_mushroom_binned.txt',sted2);
% % % 
% % %     subplot(2,3,1); imagesc(dio2); axis equal;
% % %     subplot(2,3,2); imagesc(homer2); axis equal;
% % %     subplot(2,3,3); imagesc(sted2); axis equal;
% % %     
% % % dio2=[]; for i=1:37; for j=1:37; dio2(i,j)=sum(sum(dioflat(4*i:4*i+1,4*j:4*j+1))); end; end; %%imagesc(dio2)
% % % homer2=[]; for i=1:37; for j=1:37; homer2(i,j)=sum(sum(homerflat(4*i:4*i+1,4*j:4*j+1))); end; end; %%imagesc(homer2)
% % % sted2=[]; for i=1:37; for j=1:37; sted2(i,j)=sum(sum(stedflat(4*i:4*i+1,4*j:4*j+1))); end; end; %%imagesc(sted2)
% % % 
% % % dlmwrite('DiO_flat_binned.txt',dio2);
% % % dlmwrite('homer_flat_binned.txt',homer2);
% % % dlmwrite('sted_flat_binned.txt',sted2);
% % % 
% % %     subplot(2,3,4); imagesc(dio2); axis equal;
% % %     subplot(2,3,5); imagesc(homer2); axis equal;
% % %     subplot(2,3,6); imagesc(sted2); axis equal; drawnow;%%%%pause(1);
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    