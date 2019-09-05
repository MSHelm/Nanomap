function empic_pos;
 
for i=5:8
    
    a=strcat('spotsd_red00',num2str(i-1),'_positions.txt');
    aa=strcat('spotsd_green00',num2str(i-1),'.tif');
    
    matrix=dlmread(a);
    
    xx=matrix(:,1);
    yy=matrix(:,2);
    movi(:,:) = imread(aa);
    A(:,:)=movi(:,:); 
    media=[];
    for j=1:numel(xx)
        x=xx(j);
        y=yy(j);
        
         ocols=[x-14, x-10, x,    x+10,   x+14, x+10,   x,   x-10,   x-14];
         orows=[y,   y-10, y-14,  y-10,   y,   y+10,   y+14, y+10,   y];
           % disp(orows); 
           % disp(ocols);
    octogon=roipoly(A(:,:),orows,ocols);
       
       pos=find(octogon==1);
       media(j)=mean(A(pos));
   end;
   
   matrix(:,4)=media';
   
   dlmwrite(a,matrix);
end;

