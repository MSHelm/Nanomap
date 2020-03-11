function bbgetbox(varargin);
source='bbgetbox';
names={'pos','dx','dy','x0','y0'};
hax=gca; hfig=get(hax,'parent');
switch (nargin);
case 0
   set(hfig, 'Pointer', 'arrow',...
   'WindowButtonDownFcn','',...
   'WindowButtonMotionFcn', '',...
   'WindowButtonupFcn', '');
   pos=[1 1 1 1]; dx=0;dy=0;x0=0;y0=0; 
   rect1 = rectangle('tag','rect','parent', hax,'position', pos, ... 
      'Visible', 'off', 'Clipping', 'off', ...
      'edgeColor', 'k', 'LineStyle', '-', 'EraseMode', 'xor');
   rect2 = rectangle('tag','rect','Parent', hax, 'position', pos, ...
      'Visible', 'off', 'Clipping', 'off', ...
      'edgeColor', 'w', 'LineStyle', '-', 'EraseMode', 'xor');
   set(hfig, 'WindowButtonDownFcn', [source ' down1;']);
   vals={pos,dx,dy,x0,y0};
   setappdatas(hfig,names,vals);
   
case 1
   [pos,dx,dy,x0,y0]=getappdatas(hfig,names);
   switch(varargin{:})
   case 'down1'
      [x0,y0] = bbgetcurpt(gca);
      pos=[x0 y0 1 1];
      names={'x0','y0','pos'}; vals={x0,y0,pos};
      setappdatas(hfig,names,vals);
      set(findobj('tag','rect'), 'position', pos, 'visible', 'on');
      set(hfig, 'WindowButtonDownFcn', '',...
      'WindowButtonupfcn', [source ' up;'],...
      'WindowButtonMotionFcn', [source ' move1;']);
      ptr=nan; ptr=ptr(ones(1,16),ones(1,16));
      set(hfig,'PointerShapeCData', ptr,'Pointer', 'custom');
   case 'move1'
      [x,y] = bbgetcurpt(gca);
      wd=max(1,abs(x-x0)); ht=max(1, abs(y-y0));
      xmin=min(x,x0); ymin=min(y,y0);
      pos=[xmin ymin wd ht];
      %     setappdata(hfig,'pos',pos);
      set (findobj('tag','rect'), 'position', pos, 'visible', 'on');
      %set(hfig,'userdata',[pos,dx,dy,x0,y0]);
      setappdata(hfig,'pos',pos)  
   case 'up'
      [x,y] = bbgetcurpt(gca);
      dx=x-pos(1); dy=y-pos(2);
      x=round(x-dx); y=round(y-dy);
      names={'dx','dy'};vals={dx,dy}; setappdatas(hfig,names,vals);
      set(hfig, 'WindowButtonDownFcn', [source ' down2;']);
      set(hfig, 'WindowButtonMotionFcn', [source ' move2;']);
      %setappdata(hfig,'pos',pos)  
      
   case 'move2'
      [x,y] = bbgetcurpt(gca);
      x=round(x-dx); y=round(y-dy);
      pos(1)=x; pos(2)=y;
      setappdata(hfig,'pos',pos);
      set (findobj('tag','rect'), 'position', pos);
      %    set(hfig,'userdata',[pos,dx,dy,x0,y0]);
      %setappdata(hfig,'pos',pos)  
      
   case 'down2'
      set(hfig,'pointer','arrow',...
      'WindowButtonDownFcn','',...
      'WindowButtonMotionFcn', '',...
      'WindowButtonupFcn', '')
      [x,y] = bbgetcurpt(gca);
      x=x-dx;y=y-dy;
      y=round(y); x=round(x); ht=round(pos(3)); wd=round(pos(4));
      %him=findobj(get(gca,'children'),'type','image');
      %set(him,'cdata',im(:,:));
      drawnow 
      pos=round(pos);
      setappdata(hfig,'pos',pos)  
      delete (findobj(get(gca,'children'),'tag','rect'));
      set (hfig,'userdata','')
      %   goback=get(hfig,'userdata'); set(hfig,'userdata','');
      %   if isempty(goback); 
      %      pos
      %   else
      %      eval (['bbpv ' goback]); 
      %   end  
   end
end