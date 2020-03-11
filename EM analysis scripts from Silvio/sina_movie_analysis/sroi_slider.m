function sroi_slider

global list mapname b movi rows cols A i xx yy zz iii bbb q s ijj jjj r firstred olds inner_radius outer_radius matrix backmatrix autos 
global cellb slide xxes yyes hex hey

hh=get(slide,'value');

hh=round(hh);


    himg=image(movi(:,:,hh),'cdatamapping','scaled'); axis equal;

    textul=strcat(num2str(hh));
    text(3,3,'@','color',[0.7 0.7 0.7],'BackgroundColor',[0.7 0.7 0.7]);
    text(3,3,textul,'FontSize',10,'EdgeColor','r','color','r','BackgroundColor',[0.7 0.7 0.7]);
 

   if numel(xxes)>1
       line('Xdata',yyes,'Ydata',xxes,'color','g');
   end;
   
   if numel(hex)>0
        
        xes=[hex-10 hex+10 hex+10 hex-10 hex-10];
        yes=[hey-10 hey-10 hey+10 hey+10 hey-10];
        
        line(xes,yes,'color','r');  
%         
%         A=movi(:,:,hh);
%         back=A(hey-10:hey+10,hex-10:hex+10);
%         ccc=find(A<(mean2(back)+2*std2(back)));
%         A(ccc)=0;       
%         
%         himg=image(A,'cdatamapping','scaled'); axis equal;
        
        
        
   end;
   
   