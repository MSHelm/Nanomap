function make_files;

the_folder='C:\data_2008\december_2008\sina_pHluorins_Tfuptake_081203\081203_pHluorin_bleaching-control';


cella{1}='Sx6_control_PC12 3';
cella{2}='Sx13_control_PC12 2';
cella{3}='Syb_control_PC12 2';
cella{4}='Vti1a_control_PC12 2';


for klm=1:numel(cella)
    klm
    cd(strcat(the_folder,'\',cella{klm}));
    interns=[];
    membrs=[];
    
    [stat,mess]=fileattrib('*value*.txt');
    
    if stat==1 
        for i=1:numel(mess)
            in=dlmread(mess(i).Name);
            interns(:,i)=in(:,3);
        end;
        
        
        siz=size(interns);
    for i=1:siz(2)
        interns(:,i)=interns(:,i)*100/interns(1,i);
    end;
        
        
        m_in=mean(interns')';
        
        s_in=std(interns')'/sqrt(siz(2));
        
        interns=[];
        interns(:,1)=m_in;
        interns(:,2)=s_in;
        
        dlmwrite('internal_areas.txt',interns);
    end;
    
    
         [stat,mess]=fileattrib('*membrane*.txt');
    
    if stat==1 
        for i=1:numel(mess)
            in=dlmread(mess(i).Name);
            interns(:,i)=in(:,3);
        end;
        
                siz=size(interns);
    for i=1:siz(2)
        interns(:,i)=interns(:,i)*100/interns(1,i);
    end;
        
        
        m_in=mean(interns')';

        s_in=std(interns')'/sqrt(siz(2));
        
        interns=[];
        interns(:,1)=m_in;
        interns(:,2)=s_in;
        
        dlmwrite('membr_areas.txt',interns);
    end;
end;
        
            
    