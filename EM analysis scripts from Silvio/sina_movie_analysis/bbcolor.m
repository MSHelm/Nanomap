function bbcolor(varargin)
global homedir
source='bbcolor';
lutdir=[homedir 'color/'];
%disp(nargin)
%disp(varargin)
switch (nargin)   
    
case 0
    %dbstop if error %if (nargin==2)
    caller=gcf;
    callpos=get(caller,'position');
    hfig=gcf; % varargin{1}; 
    hax=gca; % varargin{2};
    rgb=colormap;
    mapname=getappdata(caller,'mapname');
    if (isempty(mapname)); % not called from bbpv
        if (isempty(gco));
            a=dir('*.tif');a=a(1).name;imread(a);
            imshow(a);% show an image
        end
        colormap gray(256);
        mapname='gray';
    end
    a=dir([lutdir '*.lut']); colormenu=(char(sort({a.name}))); 
    dlmwrite('lutlist.txt',colormenu,'');
    colormenu=(sort(textread('lutlist.txt','%s')));
    
    figure('tag',num2str(caller),'visible','off');  % tag is handle of caller
    setappdata(gcf,'colormenu',colormenu);
    setappdata(gcf,'rgb',rgb); setappdata(gcf,'rgb0',rgb);
    x0=callpos(1); y0=max(10,callpos(2)-300);
    set(gcf,'position',[x0 y0 400 200],...
        'WindowButtonDownFcn', [source ' buttondown'],...
        'WindowButtonMotionFcn','',...
        'WindowButtonUpFcn', '',...
        'userdata','normal',...
        'keypressfcn',[source ' keypress'],...  
        'doublebuffer','on');
    %  set (0,'currentfigure',gcf);
    axes('tag','hrgbax');
    % set(gca,'visible','off')
    sz=size(rgb,1);
    set(gca,'tag','hrgbax',...
        'position',[.2 .25 .75 .75],... % 'yticklabel','','xticklabel','',...
        'xlim',[-1 sz+1],'ylim',[-.05 1.05]);
    
    %   set (gcf,'userdata',hfig,'visible','on')
    
    % ***************************** RADIOBUTTONS *****************
    uicontrol('style','radiobutton','tag','redbutton',...
        'string','red','position',[0 150 50 20]);
    uicontrol('style','radiobutton','tag','greenbutton',...
        'callback',[source ' greenbutton'],...
        'string','green','position',[0 120 50 20]);  
    uicontrol('style','radiobutton','tag','bluebutton',...
        'callback',[source ' bluebutton'],...
        'string','blue','position',[0 90 50 20]);  
    
    %                  %%%%%%%%%%%% COLORMAP NAME
    uicontrol('tag','mapname','style','text','position',[0 50 70 15],...
        'string',mapname,'tooltipstring',mapname);
    %                              %%%%%%%%% INTERP STEP SIZE   
    smin=2; smax=64;stmin=1/63;stmax=8/63;step0=24;
    uicontrol('style','slider','tag','stepslider','callback',[source ' step'],...
        'position',[0 0 70 20],...
        'min',smin,'max',smax','sliderstep',[stmin stmax],'value',step0,...
        'tooltipstring',['step ' num2str(step0)]);
    
    %										%%%%%%%%% COLORMAP POPUP
    nn=find(strcmp(colormenu,mapname)); if (isempty(nn)); nn=1;end
    str=''; for j=1:length(colormenu); str=[str colormenu{j} '|']; end
    uicontrol('style','popup','tag','hpopup',...
        'position', [80 30 70 20],...
        'callback',[source ' colormappopup'],...
        'string', str,'value',nn);   
    %						%%%%%%%%%%% COLORMAP SLIDER
    smin=1;smax=length(colormenu);minstep=1/(smax-1);maxstep=5*minstep;
    uicontrol('style','slider','tag','cmenuslider',...
        'callback',[source ' colormapslider'],...
        'position',[0 30 70 20],'min',smin,'max',smax,...
        'sliderstep',[minstep maxstep],...
        'tooltipstring',colormenu{1},'value',nn); 
    %                              %%%%%%%% EDIT COLORMENU LIST
    uicontrol('tag','editcolorlist','position',[80 0 30 20],...
        'string','edit','callback',[source ' editcolorlist']);
    
    %                              %%%%%%%% REVERSE COLOR
    uicontrol('tag','revcolor','position',[120 0 30 20],...
        'string','rev','callback',[source ' revcolor']);
    
    %                              %%%%%%%% SAVE
    uicontrol('tag','save','position',[160 0 30 20],...
        'string','save','callback',[source ' save']);
    
    %                              %%%%%%%%% QUIT
    uicontrol('position',[200 0 30 20],'string','quit',...
        'callback',[source ' quit']);
    %                  %%%%%%% GAMMA SLIDER
    smin=.1;smax=3;minstep=.01;maxstep=.05;
    uicontrol('style','slider','tag','gammaslider','callback',[source ' gamma'],...
        'position',[160 30 70 20],'min',smin,'max',smax,...
        'sliderstep',[minstep maxstep],...
        'tooltipstring',['Gamma ' num2str(1)],'value',1);
    
    % *******************************************
    rgb=plotrgb(rgb);
    
case 1
    hrgbfig=gcf;hax=gca;
    %kids=[get(hrgbfig,'children');get(hax,'children')];
    rgb=getappdata(hrgbfig,'rgb');
    colormenu=(getappdata(hrgbfig,'colormenu')); 
    mapname=getappdata(hrgbfig,'mapname');
    sz=size(rgb,1);
    set(hrgbfig,'interruptible','off','busyaction','queue')
    switch varargin{:}
    case 'keyboard'
        keyboard
    case 'gamma'
        hgs=findobj(hrgbfig,'tag','gammaslider');
        gamma=get(hgs,'value');
        set(hgs,'tooltipstring',['gamma ' num2str(gamma)]);
        rgb=plotrgb(rgb);
    case 'colormappopup'   
        nn=round(get(findobj(hrgbfig,'tag','hpopup'),'value'));
        mapname=colormenu{nn};
        rgb=load(mapname);
        setappdata(hrgbfig,'rgb',rgb);setappdata(hrgbfig,'mapname',mapname);
        for j=1:3; rgb(:,j)=min(1,max(0,rgb(:,j)));end
        set(findobj(hrgbfig,'tag','gammaslider'),'value',1);
        set(findobj(hrgbfig,'tag','mapname'),'string',mapname);setappdata(gcf,'mapname',mapname);
        set(findobj(hrgbfig,'tag','cmenuslider'),'value',nn)
        rgb=plotrgb(rgb);
    case 'colormapslider' 
        nn=round(get(findobj(hrgbfig,'tag','cmenuslider'),'value'));
        set(findobj(hrgbfig,'tag','cmenuslider'),'tooltipstring',colormenu{nn}) 
        mapname=colormenu{nn};
        rgb=load(mapname);
        setappdata(hrgbfig,'rgb',rgb);setappdata(hrgbfig,'mapname',mapname);
        set(findobj(hrgbfig,'tag','gammaslider'),'value',1);
        set(findobj(hrgbfig,'tag','mapname'),'string',mapname);setappdata(gcf,'mapname',mapname);
        set(findobj(hrgbfig,'tag','hpopup'),'value',nn);
        rgb=plotrgb(rgb);
    case 'editcolorlist'
        edit ('lutlist.txt');
        colormenu=sort(textread('lutlist.txt','%s'));
        str='';for j=1:length(colormenu); str=[str colormenu{j} '|'];end
        set (findobj(hrgbfig,'tag','hcmap'),'string',str);
    case 'revcolor'
        rgb=1-rgb;
        setappdata(gcf,'rgb',rgb)
        rgb=plotrgb(rgb);
    case 'keypress'
        k=get(gcf,'currentcharacter');
        redok=get([findobj(hrgbfig,'tag','redbutton')],'value');
        greenok=get([findobj(hrgbfig,'tag','greenbutton')],'value');
        blueok=get([findobj(hrgbfig,'tag','bluebutton')],'value');
        switch k
        case 'u'
            if (redok); rgb(:,1)=rgb(:,1)+.01;end
            if (greenok); rgb(:,2)=rgb(:,2)+.01;end
            if (blueok); rgb(:,3)=rgb(:,3)+.01;end
        case 'd'
            if (redok); rgb(:,1)=rgb(:,1)-.01;end
            if (greenok); rgb(:,2)=rgb(:,2)-.01;end
            if (blueok); rgb(:,3)=rgb(:,3)-.01;end
        case 'l'
            if (redok); rgb(1:sz-1,1)=rgb(2:end,1);rgb(sz,1)=0;end
            if (greenok); rgb(1:sz-1,2)=rgb(2:end,2);rgb(sz,2)=0;end
            if (blueok); rgb(1:sz-1,3)=rgb(2:end,3);rgb(sz,3)=0;end
        case 'r'
            if (redok); rgb(2:sz,1)=rgb(1:end-1,1);rgb(1,1)=0;end
            if (greenok); rgb(2:sz,2)=rgb(1:end-1,2);rgb(1,2)=0;end
            if (blueok); rgb(2:sz,3)=rgb(1:end-1,3);rgb(1,3)=0;end
        end
        setappdata(gcf,'rgb',rgb);
        rgb=plotrgb(rgb);
    case 'step'
        step=round(get(findobj(hrgbfig,'tag','stepslider'),'value'));
        set(findobj(hrgbfig,'tag','stepslider'),'tooltipstring',['step ' num2str(step)]);
    case 'buttondown'
        button=get(gcf,'selectiontype');
        set(gcf,'userdata',button,...
            'WindowButtonMotionFcn', [source ' buttonmotion'],...
            'WindowButtonUpFcn', [source ' buttonup'])
    case 'buttonup'
        % set(hrgbfig,'interruptible','off','busyaction','queue');
        set(gcf,...
            'WindowButtonMotionFcn','',...
            'WindowButtonDownFcn', [source ' buttondown'])
        %rgb=plotrgb(rgb);
    case 'buttonmotion'
        % Flush the queue
        % rootxy=get(0,'pointerlocation');
        %figxy=get(gcf,'currentpoint');
        % figpos=get(gcf,'position');
        % figxy=figxy+figpos(1:2);
        %if (abs(figxy-rootxy)>5); return; end
        %rgb=colormap; 
        %      keyboard
        %      hrgbax=kids('tag','hrgbax');
        [indexx,yy] = bbgetcurpt(findobj(hrgbfig,'tag','hrgbax'));
        %kids('tag','hrgbax')
        indexx=round(indexx);
        oob=(indexx<1)+sz*(indexx >sz); % out-of-bounds
        button=get(gcf,'userdata');
        mode='spline'; % 'cubic'; % 'spline'; % 'linear';
        switch button
        case 'normal'
            step=round(get(findobj(hrgbfig,'tag','stepslider'),'value'));
            indexmin=max(1,indexx-step); indexmax=min(sz,indexx+step);
            xi=[1:indexmax-indexmin+1]'; step2= round(size(xi,1)/2);
            x=[1 step2 size(xi,1)];
            if get(findobj(hrgbfig,'tag','redbutton'),'value'); 
                if (oob); rgb(oob,1)=yy;end
                yr=[rgb(indexmin,1) yy rgb(indexmax,1)];
                rgb(indexmin:indexmax,1)=interp1(x',yr',xi,mode);
            end   
            if get(findobj(hrgbfig,'tag','greenbutton'),'value'); 
                if (oob); rgb(oob,2)=yy;end
                yg=[rgb(indexmin,2) yy rgb(indexmax,2)];
                rgb(indexmin:indexmax,2)=interp1(x',yg',xi,mode);
            end   
            if get(findobj(hrgbfig,'tag','bluebutton'),'value'); 
                if (oob); rgb(oob,3)=yy;end
                yb=[rgb(indexmin,3) yy rgb(indexmax,3)];
                rgb(indexmin:indexmax,3)=interp1(x',yb',xi,mode);
            end
            
        case 'alt'
            redok=get([findobj(hrgbfig,'tag','redbutton')],'value');
            greenok=get([findobj(hrgbfig,'tag','greenbutton')],'value');
            blueok=get([findobj(hrgbfig,'tag','bluebutton')],'value');
            if (redok);rgb(indexx,1)=yy;end
            if (greenok);rgb(indexx,2)=yy;end
            if (blueok);rgb(indexx,3)=yy;end
            
        case 'open'
        end      
        %set(hrgbfig,'interruptible','off','busyaction','queue')
        % colormap(rgb);
        rgb=plotrgb(rgb);
    case 'save'
        dir=pwd;
        cd (lutdir);
        [fname,pname]=uiputfile('*.lut','LookUpTable menu',100,500);
        if (fname ~= 0)
            if isempty(findstr(fname,'.lut')); 
                fname=[char(fname) '.lut'];
            end
            save([pname,fname],'rgb', '-ASCII') 
            colormenu{end+1}=fname; colormenu=unique(sort(colormenu));
            mapname=char(colormenu);
            dlmwrite('lutlist.txt',mapname,'')
            str='';for j=1:length(colormenu); str=[str colormenu{j} '|'];end
            set(findobj(hrgbfig,'tag','mapname'),'string',mapname);
            setappdata(gcf,'mapname',mapname);
            set (findobj(hrgbfig,'tag','hpopup'),'string',str);
        end
        cd (dir)
    case 'quit'
        hh=str2num(get(gcf,'tag'));
        %set(hrgbfig,'userdata','')
        close(hrgbfig);     
        set(0,'currentfigure',hh);
    end % nargin=1 callbacks
    
end % nargin

function rgb=plotrgb(rgb) % Plots rgb map and applies it to bbpv figure
gcfig=gcf;
%rgb=colormap;
gamma=get(findobj(gcf,'tag','gammaslider'),'value');
%keyboard
rgb=rgb.^gamma;
sz=size(rgb,1);
rgb(:,1)=min(1,max(0,rgb(:,1))); 
rgb(:,2)=min(1,max(0,rgb(:,2))); 
rgb(:,3)=min(1,max(0,rgb(:,3))); 
hold off;
plot([1:sz],rgb(:,1),'-red');
hold on
plot([1:sz],rgb(:,2),'-green');
plot([1:sz],rgb(:,3),'-blue');
%%%% PLOT UNSETS THE AXES TAG (hrgbax)
%keyboard
%set(gca,'tag','hrgbax')
set(gca,'tag','hrgbax','position',[.2 .25 .75 .75],...
    'yticklabel','','xticklabel','',...
    'xlim',[-1 sz+1],'ylim',[-.05 1.05]);
hh=str2num(get(gcfig,'tag'));
set(0,'currentfigure',hh);
colormap(rgb);
figure(gcfig);
setappdata(gcfig,'rgb',rgb); 
drawnow   
