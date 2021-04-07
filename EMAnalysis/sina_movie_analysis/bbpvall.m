function bbpv(varargin)
global homedir
source='bbpv'; 
names={'list' 'mapname' 'Movi' 'Movi2' 'play' 'srf' 'pse'};

%  other functions called: makelist, bbcolor, bbintline, bbblock, bbplot, 
%                          bbgetcurpt, bbgetline, bbgetsquare, bbgetrect     
%                          getappdatas, setappdatas

switch(nargin)
case {0,2}
    more off
    play=1; tc=0; nmax=0;align=0;
    red=1; green=1; blue=1;
    srf=0;hsrf=0;hcmap=0;
    if (nargin==0) % (1>0) % (isempty(get(0,'children')))
        %close all
        list=[];
        makelist; 
        list=textread('piclist.txt','%s');
        nmax=length(list);
        info = imfinfo(list{1});
        bitdepth = info.BitDepth;
        switch bitdepth
        case 8
            Movi = uint8(0);
        case 16
            %  disp('16 bit')
            Movi = uint16(0);
        end
        len=length(list);   
        rows = info.Height;
        cols = info.Width;
        Movi= Movi(ones(1,rows),ones(1,cols),ones(1,len)); 
        Movi2=Movi;
        for frame = 1:length(list)
            Movi(:,:,frame) = imread(list{frame},'tif');
        end      
        pse=[1:length(list)]; pse=pse.*0;  
        
        if (bitdepth==16) % subtract min
            mn=double(min(Movi(:)));
            Movi=uint16(double(Movi)-mn);
            %Movi=bbstretch(Movi);
        end
        %%%%%%%%%%% Colormap
        a=imfinfo(char(list(1)));
        mx=256;if (isa(Movi,'uint16'));mx=double(max(Movi(:)));end
        try; 
            mapname=a.ImageDescription;
        catch;
            rgb=gray(mx); % (mx-mn); 
            save([homedir 'color/gray.lut'] ,'rgb', '-ASCII')
            mapname='gray.lut';
        end
        try; map=load([homedir 'color/' mapname]);
        catch; map=gray(mx); mapname='gray'; 
        end
        %      setappdata(gcf,'mapname',mapname);
    else % crop comes here
        hfig=gcf;
        mapname=getappdata(hfig,'mapname');
        list=getappdata(hfig,'list');
        for j=1:length(list);
            list{j}=['x' list{j}];
        end; setappdata(hfig,'list',list)
        Movi=getappdata(hfig,'Movi2');
        Movi2=Movi;
        nmax=size(Movi,3);
        pse=getappdata(hfig,'pse');   
        map=colormap; 
        % close all
    end
    
    %%%%%%%%%% MAKE FIGURE (minimum size = minpix)
    rows=size(Movi,1);cols=size(Movi,2);
    scrnsz=get(0,'screensize'); scrnx=scrnsz(3);scrny=scrnsz(4);
    minsz=380; fac=0; fac=(min(minsz/rows, minsz/cols)>1)+1;
    rr=round(rows*fac); cc=round(cols*fac); yadd=120;
    fx0=max(0,(scrnx-cc)/1.5); fy0=max(0,(scrny-rr)/2); 
    fwid=max(minsz,cc+20); fht=rr+yadd;
    figpos=[fx0 fy0 fwid fht];
    hfig=figure('tag','hfig','position',figpos);
    set(hfig,'doublebuffer','on');
    hax=axes;
    set(gca,'tag','hax');
    set(hax,'visible','off','units','pixels')
    impos=[10 yadd cc rr];
    set(hax,'position',impos)
    
    colormap(map); 
    iptsetpref('imshowtruesize','manual')
    himg=image(Movi(:,:,1),'tag','himg');
    %axis image
    set(hax,'visible','off','units','normalized')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%% UICONTROLS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    set(hfig,'windowbuttondownfcn',[source ' xyz1']);
    
    uh=18; usw=70; ubw=30; uy2=uh+5; uy3=uh+uy2+5; uy4=uy3+uh+5+12;
    uy5=uy4+uh+5; 
    def=[.8 .8 .8]; % default backgroundcolor - but sliders are not affected! 
    %%%%%%%%%%%%%% ROW 1 (bottom)
    %                  %%%%%%%%%%%%%%%%% LINE
    uicontrol('tag','profile','callback',[source ' loi'],...
        'position',[0 0 ubw uh],'string','LOI',...
        'tooltipstring','Line Of Interest',...
        'backgroundcolor',def);
    %                      %%%%%%%%%%%%%%%%% ROI
    uicontrol('tag','tc','callback',[source ' roi'],...
        'position',[40 0 ubw uh],'string','ROI',...
        'tooltipstring','Region of Interes','backgroundcolor',def);
    %                                    %%%%%%%%%% ALIGN
    uicontrol('tag','align','callback',[source ' align'],...
        'position',[80 0 ubw uh],'string','align',...
        'tooltipstring','Align'); 
    
    %                       %%%%%%%%%% REV ORDER
    uicontrol('tag','revorder','callback',[source ' revorder'],...
        'position',[120 0 ubw uh],'string','Rev',...
        'tooltipstring','Revorder');  
    %                       %%%%%%%%%% NEW
    uicontrol('tag','restart','callback',[source ' new'],...
        'position',[160 0 ubw uh],'string','New',...
        'tooltipstring','Load new list');   
    %						%%%%%%%%% SAVE
    uicontrol('tag','save','callback',[source ' save'],...
        'position',[200 0 ubw uh],'string','save',...
        'tooltipstring','Save');
    %						%%%%%%%%% KEYBOARD
    uicontrol('tag','kbd','callback',[source ' kbd'],...
        'position',[240 0 ubw uh],'string','kbd',...
        'tooltipstring','Keyboard');
    %                          %%%%%% QUIT 
    uicontrol('tag','quit','style','pushbutton','callback',[source ' quit'],...
        'position',[280 0 ubw uh],'string','quit',...
        'tooltipstring','Quit');
    
    
    %%%%%%%%%%%%%  ROW 2
    %                      %%%%%%%%%%%% COLOR
    uicontrol('tag','color','callback',[source ' color'],...
        'position',[0 uy2 ubw uh],'string','color',...
        'tooltipstring','color');   
    %					%%%%%%%%%%% 3D
    uicontrol('tag','surf','callback',[source ' 3D'],...
        'position',[40 uy2 ubw uh],'string','3D',...
        'tooltipstring','3D');   
    %					%%%%%%%%% CROP
    uicontrol('tag','crop','callback',[source ' crop'],...
        'position',[80 uy2 ubw uh],'string','crop',...
        'tooltipstring','Crop');
    %	  			%%%%%%%%% VERTICAL FLIP
    uicontrol('tag','vflip','callback',[source ' vflip'],...
        'position',[120 uy2 ubw uh],'string','VFlip',...
        'tooltipstring','Vertical Flip');
    %                           %%%%%%% ZOOM 
    uicontrol('tag','hzoom', 'style','pushbutton','callback',' zoom',...
        'position',[160 uy2 ubw uh],'string','zoom',...
        'tooltipstring','Zoom Toggle','userdata',0);
    %										%%%%%%%%% ALIGN POPUP
    %   str='Align to Prev | Align to 1st';
    %   uicontrol('style','popup','tag','align',...
    %     'position', [160 uy2 85 uh],...
    %     'callback',[source ' align'],...
    %     'tooltipstring','Align to previous or 1st',...
    %     'string', str,'value',1);   
    
    %%%%%%%%%%%%  ROW 3
    %                                   %%%%%%%% SPEED SLIDER
    uicontrol('tag','speedslider','style','slider',...
        'callback',[source ' sliderpause'],...
        'position',[0,uy3,usw,uh],...
        'tooltipstring',['Pause ' num2str(pse(2))]);
    uicontrol('tag','speedslidertxt','style','text',...
        'position',[0 uy3+uh usw 12],'string',['Pause ' num2str(pse(2))]);
    %                             %%%%%%%%%%%MOVIE STEP SLIDER
    nmin=1; nmax=size(Movi,3); minstep=1/(nmax-nmin);maxstep=3*minstep;
    uicontrol('style','slider','tag','moviestepslider',...
        'callback',[source ' moviestep'],...
        'position',[80 uy3 usw uh],'min',nmin,'max',nmax,...
        'sliderstep',[minstep maxstep],...
        'tooltipstring',['MovieStep ' num2str(1)],'value',1);
    uicontrol('tag','moviestepslidertxt','style','text',...
        'position',[80 uy3+uh usw 12],'string',['MovieStep ' num2str(1)]);
    %                                  %%%%%%%% FIRSTFRAME SLIDER
    nmin=1;minstep=1/(nmax-1);maxstep=2*minstep;
    uicontrol('tag','firstframeslider',...
        'style','slider','callback',[source ' firstframe'],...
        'position',[160 uy3 55 uh],'min',1,'max',nmax,...
        'sliderstep',[minstep maxstep],'tooltipstring',['First frame 1'],'value',1);
    uicontrol('tag','firstframeslidertxt','style','text',...
        'position',[160 uy3+uh 55 12],'string',['First 1']);
    %                           %%%%%%%% LASTFRAME SLIDER 
    nmin=1;minstep=1/(nmax-1);maxstep=2*minstep;
    uicontrol('tag','lastframeslider',...
        'style','slider','callback',[source ' lastframe'],...
        'position',[225 uy3 55 uh],'min',1,'max',nmax,...
        'sliderstep',[minstep maxstep],...
        'tooltipstring',['Last frame ' num2str(nmax)],'value',nmax);
    uicontrol('tag','lastframeslidertxt','style','text',...
        'position',[225 uy3+uh 55 12],'string',['Last ' num2str(nmax)]);
    
    %%%%%%%%%%%%  ROW 4
    %                              %%%%%% PLAY 
    uicontrol('tag','loopbutton','style','pushbutton','callback',[source ' loop'],...
        'position',[0 uy4 ubw uh],'string','play',...
        'fontweight','light','tooltipstring','Play Rpt',...
        'backgroundcolor',def);
    %                            %%%%%%%%% FRAME-BY-FRAME SLIDER
    nmin=1;minstep=1/(nmax-1);maxstep=2*minstep;
    uicontrol('tag','frameslider',...
        'style','slider','callback',[source ' framebyframe'],...
        'position',[40 uy4 usw uh],'min',1,'max',nmax,...
        'sliderstep',[minstep maxstep],...
        'tooltipstring',['Manual ' num2str(1)],'value',1,...
        'backgroundcolor',def);
    %						%%% Frame - pic name 
    uicontrol('tag','picname','style','text','position',[40 uy4+uh usw 12],...
        'string','list(1)', 'tooltipstring','PicName');   
    %                           %%%%%%%% PAUSE START
    uicontrol('tag','pausestart','style','pushbutton', 'callback',[source ' pause1'],...
        'position',[120 uy4 ubw uh],'string','p1',...
        'tooltipstring','Pause at start',...
        'backgroundcolor',def);
    %                                  %%%%%%%% PAUSE END
    uicontrol('tag','pauseend','style','pushbutton', 'callback',[source ' pause2'],...
        'position',[160 uy4 ubw uh],'string','p2',...
        'tooltipstring','Pause at end',...
        'backgroundcolor',def);
    %								%%%%%%%%% X,Y,Z
    uicontrol('tag','xyz','style','text','position',[120 uy4+uh usw 12],...
        'string','', 'tooltipstring','XYZ-RtButn');
    
    %      ******** 16 bit movies ***********
    
    if (isa(Movi,'uint16'))
        set(findobj(hfig,'tag','color'),'visible','off'); % No color luts with 16bit
        mx=double(max(Movi(:))); uh2=12;
        uicontrol('tag','lohitxt','style','text','position',[290 uy4+2*uh2 usw 12],...
            'string','16 bit');
        
        uicontrol('tag','lohi','style','text','position',[290 uy4+uh2 usw 12],...
            'string',['0' ' : ' num2str(mx)], 'tooltipstring','LoHi',...
            'backgroundcolor',def);
        %                               %%%%%%%%% Lo
        minstep=1/(mx-1);maxstep=10*minstep;
        uicontrol('tag','lo','style','slider','callback',[source ' lohi'],...
            'position',[290 uy4 usw uh2],'min',0,'max',mx,...
            'sliderstep',[minstep maxstep],...
            'tooltipstring',['Min ' num2str(0)],'value',0,...
            'backgroundcolor',def);
        %                               %%%%%%%%% Hi
        %mx=round(double(max(Movi(:)))/2);
        minstep=1/(mx-1);maxstep=.05;
        uicontrol('tag','hi','style','slider','callback',[source ' lohi'],...
            'position',[290 uy4-uh2 usw uh2],'min',1,'max',mx,...
            'sliderstep',[minstep maxstep],...
            'tooltipstring',['Max ' num2str(mx)],'value',mx,...
            'backgroundcolor',def);
        %                         %%%%%%%% CONVERT TO 8 BIT
        uicontrol('tag','to8bit', 'callback',[source ' to8bit'],...
            'position',[330 uy4-2*uh2-4 ubw uh2],'string','->8bit',...
            'tooltipstring','Convert to 8 bit',...
            'backgroundcolor',def);
    end
    %                             %%%%%%%%%%%FIGURE SIZE SLIDER
    nmin=.1; nmax=min(scrnx/cols,scrny/rows); val=cc/cols;
    uicontrol('tag','figsizeslider',...
        'style','slider','callback',[source ' figsize'],...
        'position',[200 uy4 usw uh],'min',.1,'max',nmax,...
        'sliderstep',[0.01 0.1],...
        'tooltipstring',['FigSize ' num2str(val)],'value',val);  
    uicontrol('tag','figsizeslidertxt','style','text',...
        'position',[200 uy4+uh usw 12],'string',['FigSize ' num2str(val)]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    drawnow
    vals={list mapname Movi Movi2 play srf pse};
    setappdatas(hfig,names,vals);   
    eval([source ' replay']);
    
case 1
    [list mapname Movi Movi2 play srf pse]=getappdatas(gcf,names);
    hfig=gcf; hax=gca;
    hfs=findobj(hfig,'tag','frameslider');
    hffs=findobj(hfig,'tag','firstframeslider');
    hlfs=findobj(hfig,'tag','lastframeslider');
    himg=findobj(hfig,'tag','himg');
    hpicname=findobj(hfig,'tag','picname');
    % other objects' tags: hzoom, loopbutton, himg, xyz, lo, hi, lohi,
    % figsizeslider, speedslider, moviestepslider
    switch (varargin{:})
    case '3D'
        hfss=findobj(hfig,'tag','figsizeslider');
        setappdata(hfig,'play',0)
        switch srf
        case 0
            a=round(getrect);
            xl=a(1);xu=xl+a(3);yl=a(2);yu=yl+a(4);
            Movi2=Movi;
            Movi=double(Movi(yl:yu,xl:xu,:));
            setappdata(hfig,'Movi',Movi);
            setappdata(hfig,'Movi2',Movi2);
            lo=min(Movi(:)); hi=max(Movi(:));
            if isa(Movi2,'uint16');
                %disp('16 bit')
                hlo=findobj(hfig,'tag','lo'); hhi=findobj(hfig,'tag','hi');
                lo=round(get(hlo,'value')); hi=round(get(hhi,'value'));
            end  
            hsrf=surface(Movi(:,:,1),'tag','hsrf');
            set(hax,'xlim',[1,size(Movi,1)],...
                'ylim',[1,size(Movi,1)],...
                'zlim',[lo hi],'ydir','rev')
            set(hsrf,'zdata',Movi(:,:,1));
            set(hsrf,'cdata',Movi(:,:,1));
            rotate3d on   
            set(hfss,'visible','off')
        case 1
            rotate3d off     
            Movi=Movi2;
            setappdata(hfig,'Movi',Movi);
            himg=image(Movi(:,:,1),'tag','himg');
            set(hax,'visible','off');
            set(himg,'cdata',Movi(:,:,1))                       
            set(hax,'xlimmode','auto','ylimmode','auto',...
                'zlimmode','auto','ydir','rev');
            set(hfss,'visible','on')      
            set(hfig,'doublebuffer','on');
        end
        srf=~srf;
        setappdata(hfig,'srf',srf);
        eval([source ' loop'])   
        
    case 'align'
        setappdata(hfig,'play',0); 
        %alignmode=get(gcbo,'value'); % 1=previous; 2=first
        %************ SET ALIGNMODE AND dd HERE ********************
        alignmode=1; % 1=align to previous; 2=align=first in list
        dd=10; % % size difference of larger window to scan
        % ***************************************************
        drawnow; 
        clc; 
        set(himg,'cdata',Movi(:,:,1)); set(hfs,'value',1); 
        jmin=round(get(hffs,'value'));
        jmax=round(get(hlfs,'value'));
        %%%%%%%%%%% Align: set up 2 squares
        [pos1]=round(bbgetsquare);xl=pos1(1); yl=pos1(2);wd=pos1(3);ht=wd;
        rectangle('position',pos1,'edgecolor','r')
        sz0=size(Movi(:,:,1)); szx=sz0(2); szy=sz0(1);% rows,cols
        Xl=max(1,xl-dd);Yl=max(1,yl-dd); 
        Xu=min(szx,xl+wd+dd); Yu=min(szy,yl+wd+dd);
        pos2=[Xl,Yl,Xu-Xl+1,Yu-Yl+1];
        rectangle('position',pos2,'edgecolor','r')
        drawnow  
        %%%%%%%%%%%% Align: Find best fit positions 
        xyalign(1,1)=0; xyalign(1,2)=0;
        if (alignmode==2); % align to first in list
            a=double(Movi(yl:yl+ht,xl:xl+wd,jmin)); %  align square = first in list 
        end
        for jj=jmin+1:jmax
            disp (jmax-jj)
            if (alignmode==1);
                a=double(Movi(yl:yl+ht,xl:xl+wd,jj-1)); %  align square = previous
            end
            mindiff0=1e12;
            for xx=Xl:Xu-wd
                for yy=Yl:Yu-ht
                    b=double(Movi(yy:yy+ht,xx:xx+wd,jj)); % cutout to test
                    d1=(a-b).*(a-b);
                    d2=sum(sum(d1));
                    if (d2<mindiff0)
                        mindiff0=d2; xyalign(jj,1)=xl-xx; xyalign(jj,2)=yl-yy;
                    end
                end
            end  
            if (alignmode==1); % align to previous image in stack
                c=double(Movi(:,:,jj));szy=size(c,1); szx=size(c,2);
                dx=xyalign(jj,1); dy=xyalign(jj,2);
                yl2=1*(dy>=0)+(-dy+1)*(dy<0); yu2=szy*(dy<=0)+(szy-dy)*(dy>0);
                xl2=1*(dx>=0)+(-dx+1)*(dx<0); xu2=szx*(dx<=0)+(szx-dx)*(dx>0);
                d=c(yl2:yu2,xl2:xu2); % cutout region to move
                xx2=1*(dx<=0)+(dx+1)*(dx>0); yy2=1*(dy<=0)+(dy+1)*(dy>0);
                e=bbblock(xx2,yy2,zeros(szy,szx),d);
                Movi(:,:,jj)=uint8(e); set(himg,'cdata',Movi(:,:,jj));         
            end   
        end
        if (alignmode==2); % align all to first in list
            for jj=jmin+1:jmax
                c=double(Movi(:,:,jj));szy=size(c,1); szx=size(c,2);
                dx=xyalign(jj,1); dy=xyalign(jj,2);
                yl2=1*(dy>=0)+(-dy+1)*(dy<0); yu2=szy*(dy<=0)+(szy-dy)*(dy>0);
                xl2=1*(dx>=0)+(-dx+1)*(dx<0); xu2=szx*(dx<=0)+(szx-dx)*(dx>0);
                d=c(yl2:yu2,xl2:xu2); % cutout region to move
                xx2=1*(dx<=0)+(dx+1)*(dx>0); yy2=1*(dy<=0)+(dy+1)*(dy>0);
                e=bbblock(xx2,yy2,zeros(szy,szx),d);
                Movi(:,:,jj)=uint8(e); set(himg,'cdata',Movi(:,:,jj));         
            end
        end
        setappdata(hfig,'Movi',Movi);
        clc   
        
    case 'color'
        set(hfig,'userdata','hello')
        bbcolor
        
    case 'crop'
        set(hfig,'userdata','hello');
        bbgetrect % eval(['getbox(' num2str(hfig) ',' num2str(hax) ')' ]);   
        waitfor(hfig,'userdata')
        pos=getappdata(hfig,'pos');
        xl=pos(1);yl=pos(2);
        xu=xl+pos(3);yu=yl+pos(4);
        Movi=getappdata(hfig,'Movi');
        Movi2=Movi(yl:yu,xl:xu,:);         
        setappdata(hfig,'Movi2',Movi2);
        eval ([source ' crop' ' crop']) % to make nargin=2
        
    case 'figsize' 
        yadd=120;
        sz=size(Movi(:,:,1));
        figfac=get(findobj(hfig,'tag','figsizeslider'),'value');
        if (figfac==0.1); figfac=1;end % Minimum resets size
        set(findobj(hfig,'tag','figsizeslider')...
            ,'tooltipstring',['FigSize ' num2str(figfac)],...
            'value',figfac)   
        set(findobj(hfig,'tag','figsizeslidertxt'),...
            'string',['FigSize ' num2str(figfac)]);
        scrnsz=get(0,'screensize');
        figpos3=max(280,(sz(2)*figfac+20));
        figpos4=sz(1)*figfac+yadd;
        figpos1=max(0,(scrnsz(3)-figpos3)/1.5);
        figpos2=(scrnsz(4)-figpos4-60)/2;
        figpos=round([figpos1 figpos2 figpos3 figpos4]);
        set(hfig,'units','pixels','position',figpos);
        impos=[10 yadd sz(2)*figfac sz(1)*figfac];
        set(hax,'visible','off','units','pixels','position',impos)
        set(hax,'units','normalized')
        
    case 'firstframe' 
        hffst=findobj(hfig,'tag','firstframeslidertxt');
        n1=round(get(hffs,'value')); n2=round(get(hlfs,'value'));   
        if (n1>n2); n1=n2; set(hffs,'value',n1);end
        set (hffs,'tooltipstring',['FirstFrame ' num2str(n1)]);
        set (hffst,'string',['First ' num2str(n1)]);    
        
    case 'framebyframe'
        delete(findobj(hfig,'type','line'))
        delete(findobj(hfig,'type','rectangle'))
        setappdata(hfig,'play',0); 
        % loopbutton, frameslider,firstfs,lastfs,picname,himg,hsrf
        hlb=findobj(hfig,'tag','loopbutton');
        hpicname=findobj(hfig,'tag','picname');    
        set(hlb,'fontweight','bold','foregroundcolor','red')
        a=round(get(hfs,'value'));
        jmin=round(get(hffs,'value'));
        jmax=round(get(hlfs,'value'));
        %a=min(jmax,(max(jmin,a)));
        b=jmin*(a<jmin)+jmax*(a>jmax);a=a*~b+b;
        set(hfs,'value',a);
        set(hpicname,'string',list(a));
        if (srf==0)
            himg=findobj(hfig,'tag','himg');
            set(himg,'cdata',Movi(:,:,a));
        else
            hsrf=findobj(hfig,'tag','hzoom');
        end   
        set(hfs,'tooltipstring',['Manual ' num2str(a)]);
        drawnow
        
    case 'kbd'
        keyboard        
        
    case 'lastframe'
        hlfst=findobj(hfig,'tag','lastframeslidertxt');
        n1=round(get(hffs,'value')); n2=round(get(hlfs,'value'));   
        if (n2<n1); n2=n1; set(hlfs,'value',n2);end
        set (hlfs,'tooltipstring',['LastFrame ' num2str(n2)]);
        set (hlfst,'string',['Last ' num2str(n2)]);    
            
    case 'lohi'
        hlo=findobj(hfig,'tag','lo'); hhi=findobj(hfig,'tag','hi');
        htext=findobj(hfig,'tag','lohi');
        lo=round(get(hlo,'value')); hi=round(get(hhi,'value'));
        %disp([lo hi]);
        if lo>hi; 
            set(hlo,'value',hi); set(hhi,'value',lo)         
            a=lo; lo=hi; hi=a;
        end
        set(hlo,'tooltipstring',num2str(lo));set(hhi,'tooltipstring',num2str(hi));
        set(htext,'string',[num2str(lo) ' : ' num2str(hi)])
        map=gray(hi-lo);
        if (lo>0);map=[zeros(lo,3);map];end
        colormap(map);
        
    case 'loi' % Line Of Interest
        set(hfig,'userdata','hello');
        bbdraw
        waitfor (hfig,'userdata')
        clc
        set(hfig,'userdata','');
        x=round(getappdata(hfig,'xdata')); y=round(getappdata(hfig,'ydata'));
        x3=[];y3=[];
        for j=2:size(x,2);   % Interpolate - fill in gaps
            [xx, yy]=bbintline(x(j-1),x(j),y(j-1),y(j));
            x3=[x3;xx(1:max(1,end-1))]; y3=[y3;yy(1:max(1,end-1))];
        end
        x3=round(x3);y3=round(y3);
        hold on; 
        %line(hax,'xdata',x3,'ydata',y3); 
        plot(x3,y3,'.');
        %                 Get values 
        z=[];setappdata(hfig,'zdata',z);
        %Movi=getappdata(hfig,'Movi');
        % Plot only those frames selected for display
        jmin=round(get(findobj(hfig,'tag','firstframeslider'),'value'));
        jmax=round(get(findobj(hfig,'tag','lastframeslider'),'value'));
        for j=jmin:jmax; % 1:size(Movi,3)  % get brightness (z) values
            m=Movi(:,:,j);
            z(:,j)=double(m(sub2ind(size(m),y3,x3)));
        end
        setappdata(hfig,'zdata',z);
        setappdata(hfig,'userdata','profile');
        bbplot;
        set (0,'currentfigure',hfig)
        setappdata(hfig,'userdata','');
        figure(hfig);        
        
    case 'loop'
        hlb=findobj(hfig,'tag','loopbutton');
        set(hlb,'fontweight','light','foregroundcolor','k')
        setappdata(hfig,'play',1);    
        eval([source ' replay']);           
        
    case 'moviestep'
        hmss=findobj(hfig,'tag','moviestepslider');hmsst=findobj(hfig,'tag','moviestepslidertxt');
        step=get(hmss,'value');
        set(hmss,'tooltipstring',['Moviestep ' num2str(step)]);
        set(hmsst,'string',['Moviestep ' num2str(step)]);
        
    case 'new'
        setappdata(hfig,'play',0)
        % close (hfig)
        bbpv    
         
    case 'pause1'
        pse(1)=(pse(1)==0); % max((pse(1)<1),pse(1))
        setappdata(hfig,'pse',pse);
        
    case 'pause2'
        pse(end)=(pse(end)==0); % max((pse(end)<1),pse(2));
        setappdata(hfig,'pse',pse)
        
    case 'quit'
        setappdata(hfig,'play',0);
        close (hfig)
        
    case 'replay'
        try
            hsrf=findobj(hax,'tag','hsrf');
            hpicname=findobj(hfig,'tag','picname');
            while (play)   
                jmin=round(get(hffs,'value'));
                jjmax=round(get(hlfs,'value'));
                jjj=jmin; 
                while ((jjj <= jjmax) & (play > 0))
                    pse2=getappdata(hfig,'pse'); 
                    pse2(jmin)=pse2(1); pse2(jjmax)=pse2(end) ;
                    srf=getappdata(hfig,'srf');
                    play=getappdata(hfig,'play'); 
                    set(hfs,'value',jjj);
                    set(hpicname,'string',list(jjj));
                    if (play)
                        if (srf==0)
                            set(himg,'cdata',Movi(:,:,jjj));
                        else
                            set(hsrf,'zdata',Movi(:,:,jjj)); 
                            set(hsrf,'cdata',Movi(:,:,jjj));                  
                        end
                        step=round(get(findobj(hfig,'tag','moviestepslider'),...
                            'value'));
                        if (jjj+step>jjmax); 
                            pause(pse2(end)*play);
                        else; 
                            pause (pse2(jjj)*(play));
                        end;
                        set(findobj(hfig,'tag','moviestepslider'),...
                            'tooltipstring',['MovieStep ' num2str(step)]);
                    end   
                    jjj=(jjj+step);    
                end   % while (jjj <= ...)
            end % while (play)
        catch;return;end  
        
    case 'revorder' %%%%%%%%%%%%%
        setappdata(hfig,'play',0);
        nmax=length(list); list2=list;Movi2=Movi;
        for j=1:nmax;
            list(j)=list2(nmax-j+1); Movi(:,:,j)=Movi2(:,:,nmax-j+1);
        end
        setappdata(hfig,'list',list)         
        setappdata(hfig,'Movi',Movi)         
        n1=round(get(hffs,'value')); n2=round(get(hlfs,'value'));   
        n2new=nmax-n1+1; n1new=nmax-n2+1;
        set(hffs,'value',n1new); set(hlfs,'value',n2new);      
        hffst=findobj(hfig,'tag','firstframeslidertxt');
        set (hffst,'string',['First ' num2str(n1)]);     
        hlfst=findobj(hfig,'tag','lastframeslidertxt');
        set (hlfst,'string',['Last ' num2str(n2)]);    
        
    case 'save'
        [fname,pname]=uiputfile('*.tif','Base name for images?',100,500);
        if (fname ~= 0)
            jmin=round(get(hffs,'value')); jmax=round(get(hlfs,'value'));
            for j=jmin:jmax
                n=['000' num2str(j)]; n1=char(n(end-2:end));
                f=[fname '.' n1 '.tif']; 
                imwrite(Movi(:,:,j),f,'description',char(mapname));
                % imwrkite(Movi(:,:,j),f,'Colormap',map); % NO JOY
            end
        end
        
    case 'roi' % Region Of Interest
        set(hfig,'userdata','hello');
        bbdraw
        waitfor (hfig,'userdata')
        clc
        x=getappdata(hfig,'xdata'); y=getappdata(hfig,'ydata');
        x(end+1)=x(1);y(end+1)=y(1);
        x3=[];y3=[];
        for j=2:size(x,2);   % Interpolate - fill in gaps
            [xx, yy]=bbintline(x(j-1),x(j),y(j-1),y(j));
            x3=[x3;xx(1:max(1,end-1))]; y3=[y3;yy(1:max(1,end-1))];
        end
        hold on; 
        %line(hax,'xdata',x3,'ydata',y3); 
        plot(x3,y3,'.');
        bw = double(roipoly(Movi(:,:,1),x3,y3));
        %                 New figure for plotting z 
        Movi=getappdata(hfig,'Movi');
        hffs=findobj(hfig,'tag','firstframeslider');
        hlfs=findobj(hfig,'tag','lastframeslider');
        jmin=round(get(hffs,'value'));
        jmax=round(get(hlfs,'value'));
        z(size(Movi,3))=0;
        for j=jmin:jmax; % 1:size(Movi,3)  % get brightness (z) values
            m=Movi(:,:,j);
            z(j)=sum(sum(m(bw)))/sum(sum((bw)));            
        end
        setappdata(hfig,'zdata',z); set(hfig,'userdata','tc');
        bbplot;
        set (0,'currentfigure',hfig)
        set(hfig,'userdata','');    
        
    case 'sliderpause'
        delete(findobj(hfig,'type','line'))
        hss=findobj(hfig,'tag','speedslider'); hsst=findobj(hfig,'tag','speedslidertxt');
        pse(2:end-1)=get(hss,'value');
        if (pse(1)<1);pse(1)=pse(2);end
        if (pse(end)<1);pse(end)=pse(2);end
        setappdata(1,'pse',pse);
        set(hss,'tooltipstring',['Pause ' num2str(pse(2))]);
        set(hsst,'string',['Pause ' num2str(pse(2))]);
        
    case 'to8bit'
        set(gcbo,'visible','off')
        setappdata(hfig,'play',0)
        hlo=findobj(hfig,'tag','lo'); hhi=findobj(hfig,'tag','hi');
        htext=findobj(hfig,'tag','lohi');set(htext,'visible','off');
        lo=round(get(hlo,'value')); hi=round(get(hhi,'value'));
        set(hlo,'visible','off');set(hhi,'visible','off')
        M=double(Movi);
        if lo>0; M=max(0,M-lo);hi=hi-lo;end
        fac=255/hi; Movi=uint8(round(M.*fac));
        setappdata(hfig,'Movi',Movi); 
        mapname='gray.lut'; setappdata(hfig,'mapname',mapname);
        colormap(gray(256)); 
        set(findobj(hfig,'tag','color'),'visible','on');
        set(findobj(hfig,'tag','lohitxt'),'visible','off');
        
    case 'vflip'  %%%%%%%%%%%%%%%
        jmin=round(get(hffs,'value'));
        jjmax=round(get(hlfs,'value'));
        for j=jmin:jjmax;Movi(:,:,j)=Movi(end:-1:1,:,j);end
        setappdata(hfig,'Movi',Movi) 
        eval([source ' replay'])
        
    case 'xyz1' %%%%%%%%%%%%%
        button=get(hfig,'selectiontype');
        if (strcmp(button,'alt'))
            setappdata(hfig,'play',0); 
            zm=get(findobj(hfig,'tag','hzoom'),'userdata');
            if (zm); set(findobj(hfig,'tag','hzoom'),...
                    'foregroundcolor','red'); eval('zoom');
                set(findobj(hfig,'tag','loopbutton'),...
                    'fontweight','bold','foregroundcolor','red');end
            [x y]=bbgetcurpt(gca);
            x=round(x);y=round(y);
            m=get(findobj(gca,'tag','himg'),'cdata');
            try;
                z=double(m(y,x));str=[num2str(x) ':' num2str(y) ':' num2str(z)];
            catch;return;end;
            set(findobj(hfig,'tag','xyz'),'string',str);
        end
        
    case 'zoom' 
        zm=get(hzoom,'userdata');
        zm=~zm;
        set(hzoom,'userdata',zm);
        switch zm
        case 0
            set(hzoom,'foregroundcolor','k')
            eval('zoom') 
        case 1
            set(hzoom,'foregroundcolor','red')
            eval('zoom')
        end
        
        
    end  % nargin == 1
end  % switch nargin


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

function makelist(varargin)
source='makelist';
global basenames

switch (nargin)
case 0
   %%%%%%%%%%%%% Tif base names
   a=dir('*.tif'); b={a.name};
   for j=1:size(b,2); % base name
      x=find(b{j}=='.');    
      if (size(x,2)>1) % strip off last two fields 
         place=x(size(x,2)-1)-1; %  (e.g., 010612.001.tif -> 010612)
         b{j}=b{j}(1:place); % b{j}=(strtok(c(j,:),'.'));  
      end
   end
   basenames=unique(b) ;  % CELL array, for CHAR use f=unique(b,'rows')
   
   %%%%%%%%%%%% file (piclist.txt)
   if (~exist('piclist.txt'));
      list=[]; dlmwrite('piclist.txt',list,'');   
   end
   %more off; 
   %type ('piclist.txt'); more on
   
   eval([source ' x'])
case 1
   clc
   disp('		Tif base names:')
   for j=1:size(basenames,2); disp(['			' char(basenames{j})]); end
   
   list=textread('piclist.txt','%s');sz=size(list,1);
   if (sz);
      disp(['Current list: ' num2str(sz) ' entries: ' list{1} ' ... ' list{end}])
   else
      disp('List: 0 entries')
   end
   choices={'MENU:';' ';'s=show list';'d=dir';...
         'sk=skip'; 'c=cut'; 'cc=include';'x=start over'; 'e=edit'};
   disp(char(choices))
%beep
   inp=input ('Type base name (with wild card(s)) (ENTER=use current list)\n\n','s');
   
   switch inp
   case 's' % Show list
      clc
      more on
      disp(char(list))
      input ('Press ENTER');
      eval([source ' x'])
   case ''
      %varargout=list;
      %return; 
      clc; % more off; disp(char(list)); more on;   
   case 'd'
      more on
      dir
      eval([source ' x'])
   case 'c'
      c=input('Omit if it contains string - type string (ENTER=abort)\n\n','s')
      if (isempty(c)); 
         eval([source ' x']);   
      end
      nn=1;for j=1:length(list);
         if (isempty(findstr(c,list{j})));list2(nn)=list(j);nn=nn+1;end
      end
      dlmwrite('piclist.txt',char(list2),'')
      eval([source ' x']);
   case 'cc'
      c=input('Include if it contains string - type string (ENTER=abort)\n\n','s')
      if (isempty(c)); 
         eval([source ' x']);   
      end
      nn=1;for j=1:length(list);
         if ((findstr(c,list{j})));list2(nn)=list(j);nn=nn+1;end
      end
      dlmwrite('piclist.txt',char(list2),'')
      eval([source ' x']);
   case 'sk'
      inp=input('Take how many, skip how many? (ENTER= 1 1)\n\n','s')
      [n1 n2]=strtok(inp,' ');
      if (isempty (n1)); n1=1; n2=1;end
      nn=0; n1=str2num(n1); n2=str2num(n2);       
      for j=1:n1+n2:size(list,1)
         %list2(end+1:end+n1)=char(list(j:j+n1)); % Can't make this work!
         for k=1:n1
            nn=nn+1;
            list2(nn)=list(j+k-1);   
         end   
      end
      dlmwrite('piclist.txt',char(list2),'')
      eval([source ' x']);
   case 'x'
      list=[]; dlmwrite('piclist.txt',list,'')
      eval([source ' x'])
   case 'e'
      edit ('piclist.txt')
      input ('Press ENTER when done','s')
      eval([source ' x'])
   otherwise
      if (isempty(findstr('*',inp))); inp=[inp '*'];end
       structlist=dir(inp);
      celllist={structlist.name}; charlist=sortrows(char(celllist));
      dlmwrite('piclist.txt',charlist,''); list=charlist;
      eval([source ' x'])
   end
   
end

function [x,y] = intline(x1, x2, y1, y2)
%INTLINE Integer-coordinate line drawing algorithm.
%   [X, Y] = INTLINE(X1, X2, Y1, Y2) computes an
%   approximation to the line segment joining (X1, Y1) and
%   (X2, Y2) with integer coordinates.  X1, X2, Y1, and Y2
%   should be integers.  INTLINE is reversible; that is,
%   INTLINE(X1, X2, Y1, Y2) produces the same results as
%   FLIPUD(INTLINE(X2, X1, Y2, Y1)).

%   Steven L. Eddins, October 1994
%   Copyright 1993-1998 The MathWorks, Inc.  All Rights Reserved.
%   $Revision: 5.4 $  $Date: 1997/11/24 15:56:03 $

dx = abs(x2 - x1);
dy = abs(y2 - y1);

% Check for degenerate case.
if ((dx == 0) & (dy == 0))
  x = x1;
  y = y1;
  return;
end

flip = 0;
if (dx >= dy)
  if (x1 > x2)
    % Always "draw" from left to right.
    t = x1; x1 = x2; x2 = t;
    t = y1; y1 = y2; y2 = t;
    flip = 1;
  end
  m = (y2 - y1)/(x2 - x1);
  x = (x1:x2).';
  y = round(y1 + m*(x - x1));
else
  if (y1 > y2)
    % Always "draw" from bottom to top.
    t = x1; x1 = x2; x2 = t;
    t = y1; y1 = y2; y2 = t;
    flip = 1;
  end
  m = (x2 - x1)/(y2 - y1);
  y = (y1:y2).';
  x = round(x1 + m*(y - y1));
end
  
if (flip)
  x = flipud(x);
  y = flipud(y);
end

 function a=bbblock (varargin); % x,y,big,small)
% inserts small array into big array with upper left corner at x,y
%disp (nargin); %varargin{:})

x=varargin{1};
y=varargin{2};
big=varargin{3};
small=varargin{4};

szx=size(small,2);
szy=size(small,1);

big(y:y+szy-1,x:x+szx-1)=small;
a=big;

function bbplot(varargin)

source='bbplot';
hfig=gcf; hax=gca;
switch (nargin)
   
case 0 
   z=getappdata(hfig,'zdata');    
   %%%%%%% MAKE FIGURE FOR PLOTTING
   hplotfig=findobj('tag','plotfig');
   if (isempty(hplotfig)); hplotfig=figure('tag','plotfig');end
   figure(hplotfig)
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
   z=getappdata(hfig,'zdata'); 
   
   switch (varargin{:})
      
   case 'save'
      [fname,pname]=uiputfile('*.txt','File name?',100,500);
      if (fname ~= 0)
         if isempty(findstr(fname,'.txt')); 
            fname=[char(fname) '.txt'];
         end
         save(fname ,'z', '-ASCII')  
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

function [x,y] = bbgetcurpt(axHandle)
%GETCURPT Get current point.
%   [X,Y] = GETCURPT(AXHANDLE) gets the x- and y-coordinates of
%   the current point of AXHANDLE.  GETCURPT compensates these
%   coordinates for the fact that get(gca,'CurrentPoint') returns
%   the data-space coordinates of the idealized left edge of the
%   screen pixel that the user clicked on.  For IPT functions, we
%   want the coordinates of the idealized center of the screen
%   pixel that the user clicked on.

%   Steven L. Eddins, March 1997
%   Copyright 1993-1998 The MathWorks, Inc.  All Rights Reserved.
%   $Revision: 1.2 $  $Date: 1997/11/24 15:55:45 $

pt = get(axHandle, 'CurrentPoint');
x = pt(1,1);
y = pt(1,2);

% What is the extent of the idealized screen pixel in axes
% data space?

axUnits = get(axHandle, 'Units');
set(axHandle, 'Units', 'pixels');
axPos = get(axHandle, 'Position');
set(axHandle, 'Units', axUnits);

axPixelWidth = axPos(3);
axPixelHeight = axPos(4);

axXLim = get(axHandle, 'XLim');
axYLim = get(axHandle, 'YLim');

xExtentPerPixel = abs(diff(axXLim)) / axPixelWidth;
yExtentPerPixel = abs(diff(axYLim)) / axPixelHeight;

x = x + xExtentPerPixel/2;
y = y + yExtentPerPixel/2;


function varargout = bbgetline(varargin)
global GETLINE_FIG GETLINE_AX GETLINE_H1 GETLINE_H2
global GETLINE_X GETLINE_Y
global GETLINE_ISCLOSED

if ((nargin >= 1) & (isstr(varargin{end})))
   str = varargin{end};
   if (str(1) == 'c')
      % getline(..., 'closed')
      GETLINE_ISCLOSED = 1;
      varargin = varargin(1:end-1);
   end
else
   GETLINE_ISCLOSED = 0;
end

if ((length(varargin) >= 1) & isstr(varargin{1}))
   % Callback invocation: 'KeyPress', 'FirstButtonDown',
   % 'NextButtonDown', or 'ButtonMotion'.
   %disp (varargin{:});
   feval(varargin{:});
   return;
end

GETLINE_X = [];
GETLINE_Y = [];

if (length(varargin) < 1)
   GETLINE_AX = gca;
   GETLINE_FIG = get(GETLINE_AX, 'Parent');
else
   if (~ishandle(varargin{1}))
      error('First argument is not a valid handle');
   end
   
   switch get(varargin{1}, 'Type')
   case 'figure'
      GETLINE_FIG = varargin{1};
      GETLINE_AX = get(GETLINE_FIG, 'CurrentAxes');
      if (isempty(GETLINE_AX))
         GETLINE_AX = axes('Parent', GETLINE_FIG);
      end
      
   case 'axes'
      GETLINE_AX = varargin{1};
      GETLINE_FIG = get(GETLINE_AX, 'Parent');
      
   otherwise
      error('First argument should be a figure or axes handle');
      
   end
end

% Bring target figure forward
figure(GETLINE_FIG);

% Remember initial figure state
state= uisuspend(GETLINE_FIG);

% Set up initial callbacks for initial stage
set(GETLINE_FIG, 'Pointer', 'crosshair');
set(GETLINE_FIG, 'WindowButtonDownFcn', 'bbgetline(''FirstButtonDown'');');
set(GETLINE_FIG, 'KeyPressFcn', 'getline(''KeyPress'');');

% Initialize the lines to be used for the drag
GETLINE_H1 = line('Parent', GETLINE_AX, ...
   'XData', GETLINE_X, ...
   'YData', GETLINE_Y, ...
   'Visible', 'off', ...
   'Clipping', 'off', ...
   'Color', 'k', ...
   'LineStyle', '-', ...
   'EraseMode', 'xor');

GETLINE_H2 = line('Parent', GETLINE_AX, ...
   'XData', GETLINE_X, ...
   'YData', GETLINE_Y, ...
   'Visible', 'off', ...
   'Clipping', 'off', ...
   'Color', 'w', ...
   'LineStyle', '--', ...
   'EraseMode', 'xor');

% We're ready; wait for the user to do the drag
% Wrap the call to waitfor in try-catch so we'll
% have a chance to clean up after ourselves.
errCatch = 0;
try
   waitfor(GETLINE_H1, 'UserData', 'Completed');
catch
   errCatch = 1;
end

% After the waitfor, if GETLINE_H1 is still valid
% and its UserData is 'Completed', then the user
% completed the drag.  If not, the user interrupted
% the action somehow, perhaps by a Ctrl-C in the
% command window or by closing the figure.

if (errCatch == 1)
   errStatus = 'trap';
   
elseif (~ishandle(GETLINE_H1) | ...
      ~strcmp(get(GETLINE_H1, 'UserData'), 'Completed'))
   errStatus = 'unknown';
   
else
   errStatus = 'ok';
   x = GETLINE_X(:);
   y = GETLINE_Y(:);
   % If no points were selected, return rectangular empties.
   % This makes it easier to handle degenerate cases in
   % functions that call getline.
   if (isempty(x))
      x = zeros(0,1);
   end
   if (isempty(y))
      y = zeros(0,1);
   end
end

% Delete the animation objects
if (ishandle(GETLINE_H1))
   delete(GETLINE_H1);
end
if (ishandle(GETLINE_H2))
   delete(GETLINE_H2);
end

% Restore the figure's initial state
if (ishandle(GETLINE_FIG))
   uirestore(state);
end

% Clean up the global workspace
clear global GETLINE_FIG GETLINE_AX GETLINE_H1 GETLINE_H2
clear global GETLINE_X GETLINE_Y
clear global GETLINE_ISCLOSED

% Depending on the error status, return the answer or generate
% an error message.
switch errStatus
case 'ok'
   % Return the answer
   if (nargout >= 2)
      varargout{1} = x;
      varargout{2} = y;
   else
      % Grandfathered output syntax
      varargout{1} = [x(:) y(:)];
   end
   
case 'trap'
   % An error was trapped during the waitfor
   error('Interruption during mouse selection.');
   
case 'unknown'
   % User did something to cause the polyline selection to
   % terminate abnormally.  For example, we would get here
   % if the user closed the figure in the middle of the selection.
   error('Interruption during mouse selection.');
end

%--------------------------------------------------
% Subfunction KeyPress
%--------------------------------------------------
function KeyPress

global GETLINE_FIG GETLINE_AX GETLINE_H1 GETLINE_H2
global GETLINE_PT1 
global GETLINE_ISCLOSED
global GETLINE_X GETLINE_Y

key = real(get(GETLINE_FIG, 'CurrentCharacter'));
switch key
case {8, 127}  % delete and backspace keys
   % remove the previously selected point
   switch length(GETLINE_X)
   case 0
      % nothing to do
   case 1
      GETLINE_X = [];
      GETLINE_Y = [];
      % remove point and start over
      set([GETLINE_H1 GETLINE_H2], ...
         'XData', GETLINE_X, ...
         'YData', GETLINE_Y);
      set(GETLINE_FIG, 'WindowButtonDownFcn', ...
         'getline(''FirstButtonDown'');', ...
         'WindowButtonMotionFcn', '');
   otherwise
      % remove last point
      if (GETLINE_ISCLOSED)
         GETLINE_X(end-1) = [];
         GETLINE_Y(end-1) = [];
      else
         GETLINE_X(end) = [];
         GETLINE_Y(end) = [];
      end
      set([GETLINE_H1 GETLINE_H2], ...
         'XData', GETLINE_X, ...
         'YData', GETLINE_Y);
   end
   
case {13, 3}   % enter and return keys
   % return control to line after waitfor
   set(GETLINE_H1, 'UserData', 'Completed');     
   
end

%--------------------------------------------------
% Subfunction FirstButtonDown
%--------------------------------------------------
function FirstButtonDown

global GETLINE_FIG GETLINE_AX GETLINE_H1 GETLINE_H2
global GETLINE_ISCLOSED
global GETLINE_X GETLINE_Y
%disp('ok1')
[GETLINE_X, GETLINE_Y] = bbgetcurpt(GETLINE_AX);

if (GETLINE_ISCLOSED)
   GETLINE_X = [GETLINE_X GETLINE_X];
   GETLINE_Y = [GETLINE_Y GETLINE_Y];
end

set([GETLINE_H1 GETLINE_H2], ...
   'XData', GETLINE_X, ...
   'YData', GETLINE_Y, ...
   'Visible', 'on');

if (~strcmp(get(GETLINE_FIG, 'SelectionType'), 'normal'))
   % We're done!
   set(GETLINE_H1, 'UserData', 'Completed');
else
   % Let the motion functions take over.
      set(GETLINE_FIG, 'WindowButtonMotionFcn', 'bbgetline(''ButtonMotion'');', ...
      'WindowButtonDownFcn', 'bbgetline(''NextButtonDown'');');
      
      %set(GETLINE_FIG, 'WindowButtonMotionFcn', 'bbgetline(''NextButtonDown'');', ...
      %'WindowButtonDownFcn', 'bbgetline(''NextButtonDown'');');
   
end

%--------------------------------------------------
% Subfunction NextButtonDown
%--------------------------------------------------
function NextButtonDown

global GETLINE_FIG GETLINE_AX GETLINE_H1 GETLINE_H2
global GETLINE_ISCLOSED
global GETLINE_X GETLINE_Y

selectionType = get(GETLINE_FIG, 'SelectionType');
if (~strcmp(selectionType, 'open'))
   % We don't want to add a point on the second click
   % of a double-click
   
   [x,y] = bbgetcurpt(GETLINE_AX);
   if (GETLINE_ISCLOSED)
      GETLINE_X = [GETLINE_X(1:end-1) x GETLINE_X(end)];
      GETLINE_Y = [GETLINE_Y(1:end-1) y GETLINE_Y(end)];
   else
      GETLINE_X = [GETLINE_X x];
      GETLINE_Y = [GETLINE_Y y];
   end
   
   set([GETLINE_H1 GETLINE_H2], 'XData', GETLINE_X, ...
      'YData', GETLINE_Y);
   
end

if (~strcmp(get(GETLINE_FIG, 'SelectionType'), 'normal'))
   % We're done!
   set(GETLINE_H1, 'UserData', 'Completed');
end

%-------------------------------------------------
% Subfunction ButtonMotion
%-------------------------------------------------
function ButtonMotion

global GETLINE_FIG GETLINE_AX GETLINE_H1 GETLINE_H2
global GETLINE_ISCLOSED
global GETLINE_X GETLINE_Y

[newx, newy] = bbgetcurpt(GETLINE_AX);
if (GETLINE_ISCLOSED & (length(GETLINE_X) >= 3))
   x = [GETLINE_X(1:end-1) newx GETLINE_X(end)];
   y = [GETLINE_Y(1:end-1) newy GETLINE_Y(end)];
else
   x = [GETLINE_X newx];
   y = [GETLINE_Y newy];
end
%disp(x)
%disp(y)
set([GETLINE_H1 GETLINE_H2], 'XData', x, 'YData', y);


function rect = bbgetsquare(varargin)
%GETRECT Select rectangle with mouse.
%   RECT = GETRECT(FIG) lets you select a rectangle in the
%   current axes of figure FIG using the mouse.  Use the mouse to
%   click and drag the desired rectangle.  RECT is a four-element
%   vector with the form [xmin ymin width height].  To constrain
%   the rectangle to be a square, use a shift- or right-click to
%   begin the drag.
%
%   RECT = GETRECT(AX) lets you select a rectangle in the axes
%   specified by the handle AX.
%
%   See also GETLINE, GETPTS.

%   Callback syntaxes:
%        getrect('ButtonDown')
%        getrect('ButtonMotion')
%        getrect('ButtonUp')

%   Clay M. Thompson 1-22-93
%   Revised by Steven L. Eddins, September 1996
%   Copyright 1993-1998 The MathWorks, Inc.  All Rights Reserved.
%   $Revision: 5.12 $  $Date: 1998/09/29 16:24:52 $

global GETRECT_FIG GETRECT_AX GETRECT_H1 GETRECT_H2
global GETRECT_PT1 GETRECT_TYPE

if ((nargin >= 1) & (isstr(varargin{1})))
    % Callback invocation: 'ButtonDown', 'ButtonMotion', or 'ButtonUp'
    feval(varargin{:});
    return;
end

if (nargin < 1)
    GETRECT_AX = gca;
    GETRECT_FIG = get(GETRECT_AX, 'Parent');
else
    if (~ishandle(varargin{1}))
        error('First argument is not a valid handle');
    end
    
    switch get(varargin{1}, 'Type')
    case 'figure'
        GETRECT_FIG = varargin{1};
        GETRECT_AX = get(GETRECT_FIG, 'CurrentAxes');
        if (isempty(GETRECT_AX))
            GETRECT_AX = axes('Parent', GETRECT_FIG);
        end

    case 'axes'
        GETRECT_AX = varargin{1};
        GETRECT_FIG = get(GETRECT_AX, 'Parent');

    otherwise
        error('First argument should be a figure or axes handle');

    end
end

% Bring target figure forward
figure(GETRECT_FIG);

% Remember initial figure state
state = uisuspend(GETRECT_FIG);

% Set up initial callbacks for initial stage
set(GETRECT_FIG, 'Pointer', 'crosshair');
set(GETRECT_FIG, 'WindowButtonDownFcn', 'bbgetsquare(''ButtonDown'');');

% Initialize the lines to be used for the drag
GETRECT_H1 = line('Parent', GETRECT_AX, ...
                  'XData', [0 0 0 0 0], ...
                  'YData', [0 0 0 0 0], ...
                  'Visible', 'off', ...
                  'Clipping', 'off', ...
                  'Color', 'm', ...
                  'LineStyle', '-', ...
                  'EraseMode', 'xor');

GETRECT_H2 = line('Parent', GETRECT_AX, ...
                  'XData', [0 0 0 0 0], ...
                  'YData', [0 0 0 0 0], ...
                  'Visible', 'off', ...
                  'Clipping', 'off', ...
                  'Color', 'r', ...
                  'LineStyle', '--', ...
                  'EraseMode', 'xor');


% We're ready; wait for the user to do the drag
% Wrap the waitfor call in try-catch so
% that if the user Ctrl-C's we get a chance to
% clean up the figure.
errCatch = 0;
try
    waitfor(GETRECT_H1, 'UserData', 'Completed');
catch
    errCatch = 1;
end

% After the waitfor, if GETRECT_H1 is still valid
% and its UserData is 'Completed', then the user
% completed the drag.  If not, the user interrupted
% the action somehow, perhaps by a Ctrl-C in the
% command window or by closing the figure.

if (errCatch == 1)
    errStatus = 'trap';
    
elseif (~ishandle(GETRECT_H1) | ...
            ~strcmp(get(GETRECT_H1, 'UserData'), 'Completed'))
    errStatus = 'unknown';
    
else
    errStatus = 'ok';
    x = get(GETRECT_H1, 'XData');
    y = get(GETRECT_H1, 'YData');
end

% Delete the animation objects
if (ishandle(GETRECT_H1))
    delete(GETRECT_H1);
end
if (ishandle(GETRECT_H2))
    delete(GETRECT_H2);
end

% Restore the figure state
if (ishandle(GETRECT_FIG))
   uirestore(state);
end

% Clean up the global workspace
clear global GETRECT_FIG GETRECT_AX GETRECT_H1 GETRECT_H2
clear global GETRECT_PT1 GETRECT_TYPE

% Depending on the error status, return the answer or generate
% an error message.
switch errStatus
case 'ok'
    % Return the answer
    xmin = min(x);
    ymin = min(y);
    rect = [xmin ymin max(x)-xmin max(y)-ymin];
    
case 'trap'
    % An error was trapped during the waitfor
    error('Interruption during mouse selection.');
    
case 'unknown'
    % User did something to cause the rectangle drag to
    % terminate abnormally.  For example, we would get here
    % if the user closed the figure in the drag.
    error('Interruption during mouse selection.');
end

%--------------------------------------------------
% Subfunction ButtonDown
%--------------------------------------------------
function ButtonDown

global GETRECT_FIG GETRECT_AX GETRECT_H1 GETRECT_H2
global GETRECT_PT1 GETRECT_TYPE

set(GETRECT_FIG, 'Interruptible', 'off', ...
                 'BusyAction', 'cancel');

[x1, y1] = bbgetcurpt(GETRECT_AX);
GETRECT_PT1 = [x1 y1];
GETRECT_TYPE ='alt'; %  get(GETRECT_FIG, 'SelectionType');
x2 = x1;
y2 = y1;
xdata = [x1 x2 x2 x1 x1];
ydata = [y1 y1 y2 y2 y1];

set(GETRECT_H1, 'XData', xdata, ...
                'YData', ydata, ...
                'Visible', 'on');
set(GETRECT_H2, 'XData', xdata, ...
                'YData', ydata, ...
                'Visible', 'on');

% Let the motion functions take over.
set(GETRECT_FIG, 'WindowButtonMotionFcn', 'bbgetsquare(''ButtonMotion'');', ...
                 'WindowButtonUpFcn', 'bbgetsquare(''ButtonUp'');');


%-------------------------------------------------
% Subfunction ButtonMotion
%-------------------------------------------------
function ButtonMotion

global GETRECT_FIG GETRECT_AX GETRECT_H1 GETRECT_H2
global GETRECT_PT1 GETRECT_TYPE

[x2,y2] = bbgetcurpt(GETRECT_AX);
x1 = GETRECT_PT1(1,1);
y1 = GETRECT_PT1(1,2);
xdata = [x1 x2 x2 x1 x1];
ydata = [y1 y1 y2 y2 y1];

if (~strcmp(GETRECT_TYPE, 'normal'))
    [xdata, ydata] = Constrain(xdata, ydata);
end

set(GETRECT_H1, 'XData', xdata, ...
                'YData', ydata);
set(GETRECT_H2, 'XData', xdata, ...
                'YData', ydata);

%--------------------------------------------------
% Subfunction ButtonUp
%--------------------------------------------------
function ButtonUp

global GETRECT_FIG GETRECT_AX GETRECT_H1 GETRECT_H2
global GETRECT_PT1 GETRECT_TYPE

% Kill the motion function and discard pending events
set(GETRECT_FIG, 'WindowButtonMotionFcn', '', ...
                 'Interruptible', 'off');

% Set final line data
[x2,y2] = bbgetcurpt(GETRECT_AX);
x1 = GETRECT_PT1(1,1);
y1 = GETRECT_PT1(1,2);
xdata = [x1 x2 x2 x1 x1];
ydata = [y1 y1 y2 y2 y1];
if (~strcmp(GETRECT_TYPE, 'normal'))
    [xdata, ydata] = Constrain(xdata, ydata);
end

set(GETRECT_H1, 'XData', xdata, ...
                'YData', ydata);
set(GETRECT_H2, 'XData', xdata, ...
                'YData', ydata);

% Unblock execution of the main routine
set(GETRECT_H1, 'UserData', 'Completed');

%-----------------------------------------------
% Subfunction Constrain
% 
% constrain rectangle to be a square in
% axes coordinates
%-----------------------------------------------
function [xdata_out, ydata_out] = Constrain(xdata, ydata)

x1 = xdata(1);
x2 = xdata(2);
y1 = ydata(1);
y2 = ydata(3);
ydis = abs(y2 - y1);
xdis = abs(x2 - x1);

if (ydis > xdis)
   x2 = x1 + sign(x2 - x1) * ydis;
else
   y2 = y1 + sign(y2 - y1) * xdis;
end

xdata_out = [x1 x2 x2 x1 x1];
ydata_out = [y1 y1 y2 y2 y1];

function bbgetrect(varargin);
source='bbgetrect';
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

function varargout = getappdatas(handle,properties)
if ~isa(properties,'cell')
   properties = {properties};
end

for i = 1:length(properties)
   varargout{i} =getappdata(handle,properties{i});
end

function setappdatas(handle,properties,values)
if ~isa(properties,'cell')
   properties = {properties};
end

if ~isa(values,'cell')
   values = {values};
end

for i = 1:length(properties)
   setappdata(handle,properties{i},values{i})
end

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


