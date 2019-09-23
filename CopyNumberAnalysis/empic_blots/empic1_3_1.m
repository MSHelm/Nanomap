function empic1_3_1

global movi xx yy A counter tipul culoare val_m val_v val_c val_vold val_cold val_mold ttt linia
global switcher image_number valoare
global countter axx ayy newfig smart_values r

set(gcf,'windowbuttonupfcn','sroi03');
countter=countter+1;

       l=get(gca,'currentpoint');
          axx(countter)=round(l(3));
          ayy(countter)=round(l(1));
          
           line(ayy,axx,'linestyle','none','marker','o','markeredgecolor','r','markersize',5);

if countter==2
   
    limit1=ayy(1)-3;
    limit2=ayy(1)+3;
    limit3=ayy(2)-3;
    limit4=ayy(2)+3;
    
    back1=newfig(limit1:limit2,:);
    back2=newfig(limit3:limit4,:);
    

    if ayy(1)<ayy(2)
    signal=newfig(ayy(1):ayy(2),:);
    else
        signal=newfig(ayy(2):ayy(1),:);
    end;
    
    signal_value=sum(sum(signal));
    
    backvalue=sum(sum(back1))+sum(sum(back2));
    backaver=backvalue/(numel(back1)+numel(back2));
    
    signal_value=(signal_value - backaver*numel(signal))/1000
    
        
    smart_values(numel(smart_values)+1)=signal_value;
    dlmwrite(strcat(r,'smart_values.txt'),smart_values');
    close;
    close;
    
    
end;