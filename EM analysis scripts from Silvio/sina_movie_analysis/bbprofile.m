function bbprofile(varargin)

global hfig
source='bbprofile';
%disp(nargin)
disp(varargin)
names={'him','hax','xdata','ydata'};

switch (nargin)   
   
case 2,0
   if (nargin==2)
      hfig=varargin{1}; 
      hax=varargin{2};
   else
      close all 
   end
   set(0,'currentfigure',hfig);
   disp ('Left button to start, Left button to end; Right to start over')
   %   save 'junk' 
   %   keyboard
   him=findobj(hfig,'type','image');
   ht0=size(get(him,'Cdata')); ht0=ht0(1);
   set(hfig, 'Pointer', 'circle');
   set(hfig, 'WindowButtonDownFcn','');
   set(hfig, 'WindowButtonMotionFcn', '');
   set(hfig, 'WindowButtonupFcn', '');
   
   x=[];y=[];
   vals={him,hax,x,y};
   setappdatas(hfig,names,vals);
   %   keyboard
   line('tag','lines','xdata',x,'ydata',y, ... 
      'Visible', 'off', 'Clipping', 'off', ...
      'Color', 'w', 'LineStyle', '-', 'EraseMode', 'xor');
   line('tag','lines','xdata',x,'ydata',y, ...
      'Visible', 'off', 'Clipping', 'off', ...
      'color', 'w', 'LineStyle', '-', 'EraseMode', 'xor');
   set(hfig, 'WindowButtonDownFcn', [source ' down1;']);
   %  set(hfig,'userdata','')
   %try
   %  waitfor(hfig, 'UserData', 'done');
   %end
   disp('ready')
   drawnow   
case 1
   [him,hax,x,y]=getappdatas(hfig,names);
   vals={him,hax,x,y};
   set(0,'currentfigure',hfig);
   switch(varargin{:})
   case 'down1'
      [x y] = bbgetcurpt(gca);
      setappdatas(hfig,names,vals);
      set(findobj('tag','rect'), 'xdata',x,'ydata',y, 'on');
      set(hfig, 'WindowButtonDownFcn', [source ' down2']);
      % set(hfig, 'WindowButtonupfcn', [source ' up;']);
      set(hfig, 'WindowButtonMotionFcn', [source ' move;']);
   case 'up'
      % set(hfig,'windowbuttonmotionfcn', '');
      % set(hfig, 'WindowButtonDownFcn', [source ' down1']);   
   case 'move'
      [xnow,ynow] = bbgetcurpt(gca);
      x=[x xnow]; y=[y ynow];
      setappdata(hfig,'xdata',x);setappdata(hfig,'ydata',y);
      %setappdatas(hfig,names,vals);
      set (findobj('tag','lines'), 'xdata',xnow,'ydata',ynow,'visible', 'on');
   case 'down2'
      set(hfig, 'WindowButtonMotionFcn','');
      button=get(hfig,'selectiontype');
      switch button
      case 'normal'
         set(hfig,'pointer','arrow');
         set(hfig, 'WindowButtonDownFcn','');
         set(hfig, 'WindowButtonMotionFcn', '');
         set(hfig, 'WindowButtonupFcn', '');
         %set(hfig,'userdata','done');
         disp ('call finish')
         eval ([source ' finish']);
      case 'alt'
         disp('Start over')
         x=[]; y=[]; setappdatas(hfig,names,vals);
         load 'junk'
         eval (source)
      case 'finish'
         disp ('finishing up')
         x=getappdata(hfig,'xdata'); y=getappdata(hfig,'ydata');
         x=round(x); y=round(y);
         x3=[];y3=[];
         for j=2:size(x,2);
            [xx,yy]=bbintline(x(j-1),x(j),y(j-1),y(j));
            x3=[x3;xx]; y3=[y3;yy];
         end
         x3=round(x3); y3=round(y3);
         lastx=x3(1);lasty=y3(1); x4(1)=lastx; y4(1)=lasty;
         for j=2:size(x3);
            if ((x3(j)~=lastx) | (y3(j)~=lasty)); x4(end+1)=x3(j); y4(end+1)=y3(j);end
            lastx=x3(j); lasty=y3(j);
         end
         hold on; 
         plot(x4,y4,'.');
         %delete (findobj(get(gca,'children'),'tag','lines'));
         disp('done')
         
      end
   end
end