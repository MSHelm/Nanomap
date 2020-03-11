function sgetline_2_2gaussian;

cd 'C:\data_2009\january2009\Tf_uptake-and-chase\Sx13_control 2'
        
[stat, mess]=fileattrib('xxx*txt');

for i=1:numel(mess)
    
histo=dlmread(mess(i).Name);

     px=[1:1:numel(histo)]; px=px';
     

     
     opts = fitoptions('y0+a*exp(-.5*((x-x0)/b)^2)');
     opts.Startpoint=[0 2000 100 200];
     opts.Lower=[0 -Inf -Inf -Inf];
     
     ftype=fittype('y0+a*exp(-.5*((x-x0)/b)^2)','options',opts);
     
    
     
     gfit2=fit(px,histo,ftype)
     
     a2=gfit2.a; b2=gfit2.b; x02=gfit2.x0; y02=gfit2.y0;
     
     %ggfit1=[];
     ggfit2=[];
     
     for i=1:numel(px)
     %    ggfit1(i)=y01+a1/(1+((px(i)-x01)/b1)^2);
         ggfit2(i)=y02+a2/(1+((px(i)-x02)/b2)^2);
     end;
         
     
     

 e=uicontrol('tag','ddd','style','pushbutton','callback','sgetline2_3gaussian',...
            'position',[100 0 100 30],'Backgroundcolor','g','ForegroundColor','k','FontWeight','bold',...
            'string','Good fit');    
        
 e=uicontrol('tag','ddd','style','pushbutton','callback','sgetline2_4',...
            'position',[200 0 100 30],'Backgroundcolor','r','ForegroundColor','k','FontWeight','bold',...
            'string','Bad fit');  
        
        
    % subplot(2,1,1);
    % plot(px,mean1);
    % line(px,ggfit1,'color','r');
    % subplot(2,1,2);
     plot(histo);
     line(px,ggfit2,'color','r');
     drawnow;
end;
     
   
    

     
    
    