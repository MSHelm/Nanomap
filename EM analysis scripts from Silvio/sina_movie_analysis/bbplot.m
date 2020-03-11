function bbplot(varargin)

source='bbplot';

switch (nargin)
   
case 0 
hfig=gcf; hax=gca;
    z=getappdata(hfig,'zdata');    
   %%%%%%% MAKE FIGURE FOR PLOTTING
   hplotfig=findobj('tag','plotfig');

   if (isempty(hplotfig)); hplotfig=figure('tag','plotfig');end
   figure(hplotfig)
   setappdata(hplotfig,'zdata',z);
   set(hplotfig,'visible','off');
   set(0,'currentfigure',hplotfig);
   figpos=[40 40 350 250];   
   set(hplotfig,'position',figpos,...   
      'doublebuffer','on','visible','on')
   hplotax=findobj('tag','plotax');
   if (~isempty(hplotax)); delete(hplotax); end
   hplotax=axes('tag','plotax');
   axpos=[40 60 figpos(3)-50 figpos(4)-70];
   caller=get(hfig,'userdata');
   if (strcmp(caller,'tc')); z=z';end
   xlim2=size(z,1) ;
   ymax=max(max(z))*1.1;
   set(hplotax,'tag','plotax','units','pixels',...
      'xlim',[0 1.05*xlim2],'ylim',[0 ymax],...
      'position',axpos);
   hold on; 
   set(hplotfig,'visible','on');
   clr={'k' 'r' 'g' 'b'}; % 'y' 'm' 'c'};
   sym={'o' '' 'x' '+' '*' 's' 'd' 'v' '^' 'p' 'h'};
   typ={'-' ':'};
   %keyboard
   clr2=0; sym2=0; typ2=0;
   for jj=1:size(z,2);
      clr2=(clr2+1)*(clr2<size(clr,2))+(clr2==size(clr,2));
      sym2=(sym2+1)*(sym2<size(sym,2))+(sym2==size(sym,2));
      typ2=(typ2+1)*(typ2<size(typ,2))+(typ2==size(typ,2));
      plot(z(:,jj),[clr{clr2} sym{sym2} typ{typ2}]);
   end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   ubw=30; usw=70; uh=20;
   %													%%%%%%%%% SAVE
   uicontrol('callback',[source ' save'],...
      'position',[0 0 ubw uh],'string','save',...
      'tooltipstring','Save');   
   %                                          %%%%%% QUIT 
   uicontrol('style','pushbutton','callback',[source ' quit'],...
      'position',[300 0 ubw uh],'string','quit',...
      'tooltipstring','Quit');
      
case 1
   hplotfig=findobj('tag','plotfig');
   z=getappdata(hplotfig,'zdata'); 
   
   switch (varargin{:})
      
   case 'save'
      [fname,pname]=uiputfile('*.txt','File name?',100,500);
      if (fname ~= 0)
         if isempty(findstr(fname,'.txt')); 
            fname=[char(fname) '.txt'];
         end
         zz=z';
         save(fname ,'zz', '-ASCII')  
      end
   case 'edit'
      dlmwrite('junk.txt',z,'')
      edit 'junk.txt'
      input ('Press ENTER when finished editing')
   case 'quit'      
      hplotfig=findobj('tag','plotfig');
      delete(hplotfig);
   otherwise   
   end
   
end













