function frap_processing;

global matrix r
%cd C:\data_2008\february2008\dirk\FRAP_001;
%%%%%%%%%%%%%%%
nrspots=1;
%%%%%%%%%%%%%%%

%cellb{1}='FRAP Series04_t';
%cellb{2}='';
%cellb{3}='';
%cellb{4}='';
%cellb{5}='';
%cellb{6}='';
%cellb{7}='';
%cellb{8}='';
%cellb{9}='';
%cellb{10}='


frap1=[]; frap2=[];

frap=[];
rest=[];
back=[];
rest_correct=[];

%for i=1:numel(cellb)
    
  %  matrix=dlmread(strcat(cellb{i},'matrix.txt'));
    
    sizeul=size(matrix);
    
    matrix=matrix(:,3:sizeul(2));
    
    if nrspots==1
        frap=matrix(1,:);
        matrix=matrix(2:sizeul(1),:);
        
        for k=1:numel(frap)
            if frap(k)==0
                frap(k)=NaN;
            end;
        end;
                   
    elseif nrspots==2
        frap1=matrix(1,:);
        frap2=matrix(2,:);
       matrix=matrix(3:sizeul(1),:);
    end;
    
    sizeul=size(matrix);
    
    back=matrix(sizeul(1),:);
    matrix=matrix(1:sizeul(1)-1,:);
    
    rest=matrix;
    rest=mean(rest);
    
    if nrspots==1
        frap=frap-back;
        rest=rest-back;
    elseif nrspots==2
        frap1=frap1-back;
        frap2=frap2-back;
        rest=rest-back;
    end;
    
    for j=1:numel(rest)
   rest_correct(j)=rest(1)/rest(j);
    end;
    
    if nrspots==1
        frap=frap.*rest_correct;
        dlmwrite(strcat(r,'spot.txt'),frap');
        
    elseif nrspots==2
        frap1=frap1.*rest_correct;
        frap2=frap2.*rest_correct;
        frapp=[];
        frapp(1,:)=frap1;
        frapp(2,:)=frap2;
        dlmwrite(strcat(r,'spot.txt'),frapp');
    end;
%end;
  
    x=[1:1:numel(frap)];
    x=x*2.62;
    figure; 
    line(x,frap,'color','r','marker','o','markeredgecolor','b');
    
    
    
    
        
        
        