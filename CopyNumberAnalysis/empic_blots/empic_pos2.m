function empic_pos2;

green=[]; red=[];

    for i=5:8   
    a=strcat('spotsd_red00',num2str(i-1),'_positions.txt');

        
    matrix=dlmread(a);
    
    gre=matrix(:,3);
    re=matrix(:,4);
    
    green(numel(green)+1:numel(green)+numel(gre))=gre(:);
    red(numel(red)+1:numel(red)+numel(re))=re(:);
    
end;

dlmwrite('spotsd_green.txt',green');
dlmwrite('spotsd_red.txt',red');

