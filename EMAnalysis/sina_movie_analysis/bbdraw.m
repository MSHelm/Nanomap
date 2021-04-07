function bbdraw(varargin)
source='bbdraw';
switch (nargin)      
case 0
   hax=gca; hfig=gcf; % get(hax,'parent');
   him=findobj(get(hax,'children'),'type','image');
   set(0,'currentfigure',hfig);
   disp ('Left button down to start, up to end')
   ht0=size(get(him,'Cdata')); ht0=ht0(1);
   set(hfig, 'Pointer','circle',...
      'WindowButtonDownFcn','',...
      'WindowButtonMotionFcn','',...
      'WindowButtonupFcn','');
   x=[];y=[];
   line('tag','lines','xdata',x,'ydata',y,'Visible', 'on', 'Clipping', 'on', ...
      'Color', 'r', 'LineStyle', '-', 'EraseMode', 'xor');
   line('tag','lines','xdata',x,'ydata',y,'Visible', 'on', 'Clipping', 'on', ...
      'color', 'r', 'LineStyle', '-', 'EraseMode', 'xor');
   set(hfig, 'WindowButtonDownFcn', [source ' down;']);
   setappdata(hfig,'xdata',x);setappdata(hfig,'ydata',y)
   drawnow   
case 1
   hfig=gcf;hax=gca;
   set(0,'currentfigure',hfig);
   hline=findobj(hax,'tag','lines');
   x=getappdata(hfig,'xdata');y=getappdata(hfig,'ydata');
   %disp(varargin{:})
   switch(varargin{:})   
   case 'down'
      set(0,'currentfigure',hfig);
      [x y] = bbgetcurpt(gca);
      set(hfig, 'WindowButtonDownFcn', '',...
         'WindowButtonMotionFcn', [source ' move;']);
      setappdata(hfig,'xdata',x);setappdata(hfig,'ydata',y);   
   case 'move'
      set(0,'currentfigure',hfig);
      [xnow,ynow] = bbgetcurpt(hax);
      [ymax xmax zmax]=size(getappdata(hfig,'Movi'));
     % if (xnow>0 & xnow<=xmax & ynow>0 & ynow<=ymax);      
         x=[x xnow]; 
         y=[y ynow];
         setappdata(hfig,'xdata',x);setappdata(hfig,'ydata',y);   
         set(findobj('tag','lines'),'xdata',xnow,'ydata',ynow,'visible','on');
     % end  
      set(hfig,'windowbuttonupfcn',[source ' up'])
      drawnow   
   case 'up'
%      keyboard
      set(0,'currentfigure',hfig);
      set(hfig,'pointer','arrow',...
         'WindowButtonMotionFcn', '',...
         'WindowButtonupFcn', '',...
         'userdata','')
      delete (hline)
   end   
end