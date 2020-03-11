function step

global list mapname b movi rows cols A i xx yy zz iii bbb q s ijj jjj r firstred olds inner_radius outer_radius matrix

ijj=ijj+1
if ijj<s+1

    himg=image(movi(:,:,ijj),'cdatamapping','scaled'); axis equal;

else ijj=q;himg=image(movi(:,:,ijj),'cdatamapping','scaled'); axis equal;

end;



    textul=strcat(num2str(ijj));
    text(10,30,'@','color',[0.7 0.7 0.7],'BackgroundColor',[0.7 0.7 0.7]);
    text(10,30,textul,'FontSize',10,'EdgeColor','r','color','r','BackgroundColor',[0.7 0.7 0.7]);
 

    
if numel (xx)>0
    
   
    for j=1:numel(xx)
       
        doublex=xx(j);
        doubley=yy(j);
        
    k = 4;
    n = 2^k-1;
   theta = pi*(-n:1:n)/n;

   protx=doublex; proty=doubley;
   protx = protx + outer_radius*cos(theta);
   proty = proty + outer_radius*sin(theta);
   orows3=round(protx);
   ocols3=round(proty);

if j==1
     line(orows3,ocols3,'color','y');
else
    line(orows3,ocols3,'color','r');
end;
 
   drawnow;
    end;
end;

   
   