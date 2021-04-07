function bbpv (varargin) 
% BBPV: Copy this into the directory 'work' so it will be in the Matlab path
% Picture Viewer for displaying movies. 
% For documentation see www.uchsc.edu/sm/physiol/wjb/matlab/bbpv.htm
% Bill Betz (with thanks to Morri Feldman, Silvio Rizzoli, Audrey Brumback)
% Department of Physiology & Biophysics
% University of Colorado Medical School
% Denver, CO 80262 USA
% email: bill.betz@uchsc.edu
% Abort: 
%        set(habort,'visible','on'); setappdata(0,'abort',0) % setup
%        if getappdata(0,'abort'); set(habort,'visible','off'); setappdata(0,'abort',0); return; end
%        set(habort,'visible','off') % cleanup
%setup
%imgrotate=0;
source='bbpv'; 
setappdata(0,'source',mfilename);
homedir=getappdata(0,'homedir');
names={'list' 'mapname' 'Movi' 'Movi2' 'play' 'srf' 'pse'};
piclistdir=homedir; % [homedir 'img'];
switch(nargin)
    case 2 % subfunction: callback name (bbcolor bbplot bbdraw) uicontrol (edit, etc.)  
        % callback is ['bbpv' name uicontrol]
        eval([varargin{1} ' ' varargin{2}]);    
    case {0,3} % startup (nargin=0), plus callbacks (crop, align, and 3d(turnoff), convert)
        more off
        play=1;%srf=0;
        if (nargin==0)  
            setup
            homedir=getappdata(0,'homedir'); piclistdir=homedir;
            imgrotate=0;
            % names={'list' 'mapname' 'Movi' 'Movi2' 'play' 'srf' 'pse'};
            setappdata(0,'plotfigpos',[40 40 440 330]); 
            setappdata(0,'watershed',[]); setappdata(0,'watlabel',0)
            minmax=getappdata(0,'minmax'); if isempty(minmax); setappdata(0,'minmax',[4 200]); end       
            list=[];srf=0; setappdata(0,'makesurf',0);
            lastrect=getappdata(0,'lastrect'); 
            if isempty(lastrect); setappdata(0,'lastrect',[1 1 2 2]); end
            last3dmovie=getappdata(0,'last3dmovie');
            if isempty(last3dmovie); 
                last3dmovie={'y' '30' '89' '-89' '89' '-89'}; 
                setappdata(0,'last3dmovie',last3dmovie); 
            end
            def=getappdata(0,'lastsmooth'); 
            if isempty(def); def={'3' '0.65'}; setappdata(0,'lastsmooth',def);end                
            cd (homedir);
            if (~exist([piclistdir 'picdir.txt'])); dlmwrite([piclistdir 'picdir.txt'],'','');end
            if (~exist([piclistdir 'piclist.txt'])); dlmwrite([piclistdir 'piclist.txt'],'','');end
            Movi=getappdata(0,'movi'); % called from bbcam
            tt=getappdata(0,'imgholdtime'); 
            imgdesc=getappdata(0,'imgdesc');
            if ~isempty(Movi)
                for j=1:size(Movi,3); list{j}=num2str(tt(j)); end
                ctype='grayscale';
                picdir=homedir;
                fmt='tif';
                swing=0;
            else
                %%%%%%%%%% Check for previous list of RGB from 3 8 bit images
                rlist=getappdata(0,'fbr'); glist=getappdata(0,'fbg'); blist=getappdata(0,'fbb');
                if size(rlist,1) & size(glist,1) & size(blist,1); inp=questdlg('Keep R-G-B image lists?');
                    if strcmp(inp,'No'); setappdata(0,'fbr',''); setappdata(0,'fbg',''); setappdata(0,'fbb',''); end; end
                bbmakelist
                rlist=getappdata(0,'fbr'); glist=getappdata(0,'fbg'); blist=getappdata(0,'fbb');
                swing=getappdata(0,'swing'); if isempty(swing); swing=0; end
                cd (piclistdir)
                picdir=char(textread('picdir.txt','%s'));
                setappdata(0,'savedir',picdir); setappdata(0,'surfedgecolor','interp');
                
                %***************** RGB from 3 lists ******************
                if size(rlist,1) & size(glist,1) & size(blist,1)
                    info=imfinfo([picdir rlist{1}]); 
                    fmt=info.Format; bitdepth=info.BitDepth;                                
                    ctype=info.ColorType; rows=info.Height; cols=info.Width; 
                    len=min(size(blist,1),min(size(rlist,1),size(glist,1)));
                    biglist=[rlist glist blist]; list=rlist;
                    Movi=uint8(0); if info.BitDepth==16; Movi=uint16(0); end
                    OK=0; removelast=0;
                    while ~OK
                        try
                            disp (['Allocating memory for ' num2str(len) ' RGB frames...'])    
                            Movi=Movi(ones(1,rows),ones(1,cols),ones(1,3),ones(1,len));
                            OK=1;   
                        catch; if removelast==0; list=list(2:len); end ;
                            len=len-1; if removelast==1; list=list(1:len); end
                            disp('Not enough memory. Removing last frame from list...')
                            disp ([rlist(len) glist(len) blist(len) ' now last in list'])
                        end
                    end
                    for j=1:len
                        disp(num2str(len-j))
                        for k=1:3; 
                            Movi(:,:,k,j)=imread([picdir biglist{j,k}],fmt); 
                        end
                    end
                    % 65535
                    fac=65535/double(max(Movi(:))); 
                    disp(['Multiplying by ' num2str(fac)])
                    Movi=uint16(double(Movi)*fac);
                    
                    %*****************************************************
                    
                else % no RGB from 3        
                    list=textread('piclist.txt','%s');
                    len=length(list);
                    %if (len == 1); list(2)=list(1); len=2;end
                    bd=0; ll=0; rr=0; cc=0; avi=0;
                    info0=finfo([picdir list{1}]); % 'im' = image; 'avi'=avi movie
                    switch info0
                        case 'im'
                            disp('image')                            
                            checksize=0; % check image sizes if they are not all the same size
                            if checksize; disp ('checking image sizes'); end
                            for j=1:1*~checksize+len*checksize; % disp(num2str(len-j)); 
                                info = imfinfo([picdir list{j}]);
                                rows=max(rr,info.Height); cols=max(cc,info.Width);                          
                            end                       
                            info=imfinfo([picdir list{1}]);                    
                            bitdepth=info.BitDepth;        
                            ctype=info.ColorType; fmt=info.Format;
                            disp([fmt ' ' num2str(bitdepth) ' bit ' ctype])
                            if imgrotate; 
                                inp=inputdlg('Rotate? (degrees)','ROTATE',1,{num2str(imgrotate)}); % 90 or 270 degrees only
                                imgrotate=str2num(inp{:}); 
                                if imgrotate==90 | imgrotate==270; a=rows; rows=cols; cols=1; 
                                else imgrotate=0;
                                end
                            end
                            
                            switch bitdepth
                                case 8
                                    Movi = uint8(0); 
                                    if strcmp(ctype,'truecolor'); 
                                        Movi= Movi(ones(1,rows),ones(1,cols),ones(1,3),ones(1,len));
                                    else
                                        Movi= Movi(ones(1,rows),ones(1,cols),ones(1,len)); 
                                    end    
                                case 16
                                    Movi = uint16(0); Movi= Movi(ones(1,rows),ones(1,cols),ones(1,len));     
                                case 24
                                    Movi=uint8(0); Movi= Movi(ones(1,rows),ones(1,cols),ones(1,3),ones(1,len)); 
                                otherwise
                                    beep
                                    disp(['bitdepth = ' num2str(bitdepth)]);
                                    keyboard
                                    return 
                            end
                            %end % RGB from 3 
                            Movi2=Movi;
                            disp(['Size of frame: ' num2str(rows) ' rows x ' num2str(cols) ' cols'])
                            habortt=msgbox('Click to abort','Loading...'); drawnow
                            for frame = 1:length(list)
                                try; a=findobj(habortt); catch return; end
                                disp ([num2str(frame) '/' num2str(length(list))]);
                                try; 
                                    ii=imfinfo([picdir list{frame}]); 
                                    imgdesc{frame}=' '; 
                                    try; imgdesc{frame}=ii.ImageDescription; catch; end
                                    if strcmp(ctype,'indexed')
                                        [a,cmap]=imread([picdir list{frame}],fmt); 
                                        map=cmap;
                                    else
                                        a=imread([picdir list{frame}],fmt);                                  
                                    end
                                    if imgrotate; aa=imrotate(a,imgrotate); a=aa; end
                                    sz=size(a); rr=sz(1); cc=sz(2);
                                    if bitdepth==24;                         
                                        Movi(1:rr,1:cc,:,frame)=a;
                                    else; Movi(1:rr,1:cc,frame)=a; end
                                catch; a=[0; 0]; disp(['error! reading ' list{frame}]);
                                end
                                pause(.01)    
                            end 
                            delete(habortt)
                        case 'avi'
                            avi=1; fmt='';
                            info=aviinfo([picdir list{1}]) 
                            disp(['Reading AVI movie ' list{1}])
                            mov=aviread([picdir list{1}]);
                            len=info.NumFrames; rows=info.Height; cols=info.Width;
                            if isrgb(mov(1).cdata); Movi=uint8(0); Movi= Movi(ones(1,rows),ones(1,cols),ones(1,3),ones(1,len));
                            else Movi=uint8(0); Movi= Movi(ones(1,rows),ones(1,cols),ones(1,len));
                            end
                            list={};
                            for frame=1:len
                                disp(['Frame ' num2str(frame) '/' num2str(len)])
                                if isrgb(mov(frame).cdata);
                                    Movi(:,:,:,frame)=mov(frame).cdata;
                                else     Movi(:,:,frame)=mov(frame).cdata;
                                end
                                list{frame}=num2str(frame);
                            end
                            map=gray(256);
                            mapname='gray';
                        end % image or avi
                        
                        
                    end % RGB from 3 
                end % getappdata(0,'movi) - from bbcam
                pse=[1:length(list)]; pse=pse.*0;
                firstframe=1; lastframe=length(list);        
                name=[list{1} '++'];
                
                %%%%%%%%%%% Colormap
                %   ctype=info.ColorType;
                mn=double(min(Movi(:))); mx=double(max(Movi(:))); if mx<=mn;mx=mn+1;end
                if ~avi
                    try; mapname=info.ImageDescription; map=load([homedir 'color\' mapname '.lut']);
                        mapname='';
                    catch
                        switch ctype
                            case 'grayscale'
                                try;
                                    map=gray(mx); mapname='gray';end
                                try; 
                                    mapname=info.ImageDescription;
                                catch;             
                                    rgb=gray(256); % (mx-mn); 
                                    save([homedir 'color/gray.lut'] ,'rgb', '-ASCII')
                                    mapname='gray.lut';
                                    if (isa(Movi,'uint16')); mapname='wrap.lut';end    
                                end
                                try; map=load([homedir 'color/' mapname]);
                                catch; map=gray(256); mapname='gray'; 
                                end
                            case 'indexed'
                                mapname='';
                                %map=gray(mx); mapname='gray';
                            case 'truecolor'
                                map=gray(mx); mapname='gray';
                        end
                    end
                end % ~avi
            else % nargin==3  callback: crop, align, convert, and 3d(turnoff) come here        
                hfig=gcf;
                name=varargin{2}; play=1*~strcmp(name,'fft-square');
                moviestep=get(findobj(hfig,'tag','moviestepslider'),'value');
                firstframe=get(findobj(hfig,'tag','firstframeslider'),'value');
                lastframe=get(findobj(hfig,'tag','lastframeslider'),'value');
                mapname=getappdata(hfig,'mapname'); % picdir=getappdata(himg,'picdir');
                swing=getappdata(hfig,'swing'); if isempty(swing); swing=0; end
                pse=getappdata(hfig,'pse');
                list=getappdata(hfig,'list');
                list2=getappdata(hfig,'list2'); if isempty(list2); list2=list; end
                if length(list2)~=length(list);
                    pse=[1:length(list2)]; pse=pse.*0;
                end
                list=list2;
                if isempty(list); list=getappdata(hfig,'list');
                else 
                    firstframe=1; lastframe=length(list);
                end        
                setappdata(hfig,'list2',[]); setappdata(hfig,'play',0);
                picdir=getappdata(hfig,'picdir');
                Movi2=getappdata(hfig,'Movi2'); Movi=Movi2;
                srf=getappdata(0,'makesurf'); setappdata(0,'makesurf',0); 
                nmax=length(list); 
                mn=double(min(Movi(:))); mx=double(max(Movi(:))); if mx<=mn;mx=mn+1;end
                map=colormap; fmt='';
                picdir=getappdata(hfig,'picdir');
                %   if strcmp(varargin{2},'convert'); close(hfig); end
            end
            
            %%%%%%%%%% MAKE FIGURE (minimum size = minpix)                            
            xy=getappdata(0,'figxy'); if isempty(xy); xy=30; end % set lower left corner    
            xymax=150; xy=xy*(xy<xymax)+20; setappdata(0,'figxy',xy);    
            rows=size(Movi,1);cols=size(Movi,2); aspect=rows/cols;
            scrnsz=get(0,'screensize'); scrnx=scrnsz(3);scrny=scrnsz(4);
            wid0=round(min(370,max(cols,0.8*scrnx))); ht0=round(aspect*wid0); 
            if ht0>0.8*scrny; wid0=round(wid0*0.8*scrny/ht0); ht0=round(ht0/0.8*scrny); end       
            fac=max(0.1,min(ht0/rows,wid0/cols)); rr=round(rows*fac); cc=round(cols*fac); yadd=120;
            fwid=cc+20; fht=rr+yadd; figpos=[xy xy fwid fht];
            hfig=figure('tag','hfig','units','pixels','position',figpos,'doublebuffer','on');
            set(hfig,'doublebuffer','on');
            set(hfig,'name',name)
            
            %       %%%%%%PICKCOLOR%%%%
            setappdata(hfig,'pickcolor','white');
            hax=axes; sec=getappdata(0,'surfedgecolor');
            set(gca,'tag','hax');
            impos=[10 yadd cc rr];
            set(hax,'visible','off','units','pixels','position',impos,'units','normalized')
            colormap(map);
            if strcmp(name,'fft'); colormap(jet(256)); end
            % iptsetpref('imshowtruesize','manual')
            
            if srf; 
                himg=surface(Movi(:,:,1)); 
                colormap(jet); mapname='jet';
                set(himg,'cdata',Movi(:,:,1),'zdata',Movi(:,:,1),'tag','hsrf','edgecolor',sec);
                set(hax,'xlim',[1,size(Movi,2)], 'ylim',[1,size(Movi,1)],...
                    'zlim',[min(Movi(:)) max(Movi(:))],'ydir','rev')  
                view(30,66)
                rotate3d on   
                axis vis3d % so size (evident zoom) is constant during rotation
                %surfcontrol    
            else
                himg=image(Movi(:,:,1),'tag','himg');    
                setappdata(himg,'picdir',picdir)
            end
            if ~strcmp(fmt,'GIF'); set(himg,'cdatamapping','scaled'); end
            setappdata(hfig,'srf',srf)
            set(hax,'visible','off','units','normalized')
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%% UICONTROLS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            vis='on'; if isrgb(Movi); vis='off'; end % color,roi,loi turned off for RGB
            jj=get(hfig,'position'); len=length(list);
            xfac=jj(3); yfac=jj(4); umode='pixels'; % 'normalized';
            if strcmp(umode,'pixels'); xfac=1; yfac=1; end
            fs=1; % fontsize
            xgap=5/xfac; ygap=5/yfac;
            uh=18/yfac; usw=70/xfac; ubw=30/xfac; uy2=uh+ygap; uy3=uh+uy2+ygap; uy4=uy3+uh+(5+12)/yfac;
            uy5=uy4+uh+ygap; 
            def=[.8 .8 .8]; % default backgroundcolor - but sliders are not affected! 
            
            %%%%%%%%%%%% BUTTON and KEYPRESS
            %set(hfig,'windowbuttondownfcn',[mfilename ' xyz1']);
            %if ~srf; set(himg,'buttondownfcn',[mfilename ' xyz1']); end
            if ~srf; set(himg,'buttondownfcn',[mfilename ' xyz1.pixval']); end
            set(hfig,'keypressfcn',[mfilename ' keypress'])
            % the command below will display keypress numbers
            % set(gcf,'KeyPressFcn','get(gcf,''CurrentCharacter'')-0');
            %%%%%%%%%%%%  ROW 1 (top)
            %                              %%%%%% PLAY 
            if len>1
                str='play'; if swing; str='swing'; end
                uicontrol('tag','loopbutton','style','pushbutton','callback',[mfilename ' loop'],...
                    'fontsize',fs,'units',umode,...    
                    'position',[0 uy4 ubw uh],'string',str,...
                    'fontweight','light','tooltipstring','Play Rpt',...
                    'backgroundcolor',def);
            end
            %                            %%%%%%%%% FRAME-BY-FRAME SLIDER
            nmin=1;minstep=(len>1)/(len-(len>1));
            maxstep=min(1,(1+(len>1))*minstep);
            uicontrol('tag','frameslider',...
                'fontsize',fs,'units',umode,...
                'style','slider','callback',[mfilename ' framebyframe'],...
                'position',[40/xfac uy4 usw uh],'min',1,'max',len+0.1,...
                'sliderstep',[minstep maxstep],...
                'tooltipstring',['Manual ' num2str(1)],'value',1,...
                'backgroundcolor',def);
            %						%%% Frame - pic name 
            uicontrol('tag','picname','style','text',...
                'fontsize',fs,'units',umode,...
                'position',[0 uy4+uh usw+80/xfac 12/yfac],...
                'string',list(1), 'tooltipstring','PicName');   
            %                      %%%%%%%% PAUSE START
            if len>1
                uicontrol('tag','pausestart','style','pushbutton', 'callback',[mfilename ' pause1'],...
                    'fontsize',fs,'units',umode,...
                    'position',[120/xfac uy4 ubw uh],'string','p1',...
                    'tooltipstring','Pause at start',...
                    'backgroundcolor',def);
                %                                  %%%%%%%% PAUSE END
                uicontrol('tag','pauseend','style','pushbutton', 'callback',[mfilename ' pause2'],...
                    'fontsize',fs,'units',umode,...
                    'position',[160/xfac uy4 ubw uh],'string','p2',...
                    'tooltipstring','Pause at end',...
                    'backgroundcolor',def);
            end
            %								%%%%%%%%% X,Y,Z
            imsz=[num2str(size(Movi,2)) ' x ' num2str(size(Movi,1))];
            if ~srf; uicontrol('tag','xyz','style','text',...
                    'fontsize',fs,'units',umode,...    
                    'position',[130/xfac uy4+uh usw+5/xfac 12/yfac],...
                    'string',imsz, 'tooltipstring','XYZ-RtButn'); end
            
            %                        %%%%%%%%%%% FIGURE SIZE SLIDER
            nmin=.05; fac=min((scrnx-60)/cols,(scrny-120)/rows);
            val=cc/cols; val=round(val*100)/100;
            uicontrol('tag','figsizeslider',...
                'fontsize',fs,'units',umode,...
                'style','slider','callback',[mfilename ' figsize'],...
                'position',[200/xfac uy4 usw uh],'min',.1,'max',max(1,fac),...
                'sliderstep',[0.01 0.1],...
                'tooltipstring',['FigSize ' num2str(val)],'value',val);  
            uicontrol('tag','figsizeslidertxt','style','text',...
                'fontsize',fs,'units',umode,...    
                'position',[200/xfac uy4+uh usw 12/yfac],'string',['FigSize ' num2str(val)]);
            
            if len>1
                %%%%%%%%%%%%  ROW 2
                %                    %%%%%%%% PAUSE SLIDER (speed of movie)
                uicontrol('tag','speedslider','style','slider',...
                    'fontsize',fs,'units',umode,...
                    'callback',[mfilename ' sliderpause'],...
                    'position',[0,uy3,usw,uh]);               
                uicontrol('tag','speedslidertxt','style','text',...
                    'fontsize',fs,'units',umode,...
                    'position',[0 uy3+uh usw 12/yfac],'string',['Pause ' num2str(pse(1+len>1))]);
                %                    %%%%%%%%%% MOVIE STEP SLIDER
                nmin=1; nmax=length(list); minstep=1/(nmax-nmin);maxstep=3*minstep;
                uicontrol('style','slider','tag','moviestepslider',...
                    'fontsize',fs,'units',umode,...
                    'callback',[mfilename ' moviestep'],...
                    'position',[80/xfac uy3 usw uh],'min',nmin,'max',nmax,...
                    'sliderstep',[minstep maxstep],...
                    'tooltipstring',['MovieStep ' num2str(1)],'value',1);
                uicontrol('tag','moviestepslidertxt','style','text',...
                    'fontsize',fs,'units',umode,...
                    'position',[80/xfac uy3+uh usw 12/yfac],'string',['MovieStep ' num2str(1)]);
                %                     %%%%%%%% FIRSTFRAME SLIDER
                nmin=1;minstep=1/(nmax-1);maxstep=2*minstep;
                uicontrol('tag','firstframeslider',...
                    'fontsize',fs,'units',umode,...
                    'style','slider','callback',[mfilename ' firstframe'],...
                    'position',[160/xfac uy3 60/xfac uh],'min',1,'max',nmax,...
                    'sliderstep',[minstep maxstep],'tooltipstring',['First frame 1'],'value',firstframe);
                uicontrol('tag','firstframeslidertxt','style','text',...
                    'fontsize',fs,'units',umode,...
                    'position',[160/xfac uy3+uh 60/xfac 12/yfac],'string',['First ' num2str(firstframe)]);
                %                      %%%%%%%% LASTFRAME SLIDER 
                nmin=1;minstep=1/(nmax-1);maxstep=2*minstep;
                uicontrol('tag','lastframeslider',...
                    'fontsize',fs,'units',umode,...
                    'style','slider','callback',[mfilename ' lastframe'],...
                    'position',[230/xfac uy3 60/xfac uh],'min',1,'max',nmax,...
                    'sliderstep',[minstep maxstep],...
                    'tooltipstring',['Last frame ' num2str(nmax)],'value',lastframe);
                uicontrol('tag','lastframeslidertxt','style','text',...
                    'fontsize',fs,'units',umode,...
                    'position',[230/xfac uy3+uh 60/xfac 12/yfac],'string',['Last ' num2str(lastframe)]);    
            end
            
            %%%%%%%%%%%%%  ROW 3    
            %                 %%%%%%%%%%%% COLOR
            uicontrol('tag','color','callback',[mfilename ' color'],...
                'fontsize',fs,'units',umode,...    
                'position',[0 uy2 ubw uh],'string','color',...
                'tooltipstring','color','visible',vis);   
            %					%%%%%%%%%%% 3D
            if ~srf; uicontrol('tag','surf','callback',[mfilename ' 3D'],...
                    'fontsize',fs,'units',umode,...
                    'position',[40/xfac uy2 ubw uh],'string','3D',...
                    'tooltipstring','3D'); end
            %					%%%%%%%%% CROP
            if ~srf; uicontrol('tag','crop','callback',[mfilename ' crop'],...
                    'fontsize',fs,'units',umode,...
                    'position',[80/xfac uy2 ubw uh],'string','crop',...
                    'tooltipstring','Crop'); end
            %%%%%%%%% RESIZE
            if ~srf; uicontrol('tag','resize','callback',[mfilename ' resize'],...
                    'fontsize',fs,'units',umode,...
                    'position',[120/xfac uy2 ubw uh],'string','resze ',...
                    'tooltipstring','resize'); end
            %                    %%%%%%% ZOOM 
            if ~srf; uicontrol('tag','hzoom', 'style','pushbutton','callback',[mfilename ' zoom'],...
                    'fontsize',fs,'units',umode,...
                    'position',[160/xfac uy2 ubw uh],'string','zoom',...
                    'tooltipstring','Zoom Toggle','userdata',0); end
            %                    %%%%%%% LABEL 
            if ~srf; uicontrol('tag','label', 'style','pushbutton','callback',[mfilename ' label'],...
                    'fontsize',fs,'units',umode,...
                    'position',[200/xfac uy2 ubw uh],'string','label',...
                    'tooltipstring','Label','userdata',0); end
            setappdata(hfig,'labelcounter',0);
            %                    %%%%%%% ERASE 
            uicontrol('tag','erase', 'style','pushbutton','callback',[mfilename ' erase'],...
                'fontsize',fs,'units',umode,...
                'position',[240/xfac uy2 ubw uh],'string','erase',...
                'tooltipstring','Erase labels');
            %			     %%%%%%%%%  MISC POPUP
            str=['  MISC | cut-fill | cut-move | copy | clock |',...
                    ' colorscale | climmode | clone | rev order | flip vert |',...
                    ' keyboard | 3x8bit->RGB | montage |',...
                    ' set all sliders | surf edge color |',...
                    ' drop labels | 3d movie | concatenate | plot x/y  |',...
                    ' Matdraw | revcolor | pan'];
            uicontrol('style','popup','tag','miscpopup',...
                'fontsize',fs,'units',umode,...
                'position', [293/xfac uy2+10/yfac 80/xfac 12/yfac],... % height auto
                'callback',[mfilename ' miscpopup'],...
                'string', str,'value',1);     
            %			     %%%%%%%%%  IMAGE PROCESS POPUP
            str=['IMG PROCESS | collapse | add/mult data |',...
                    ' fft | sum | histogram | contour | ............... | smooth | equalize bkg |',...
                    ' sharpen | histeq | img open | img close | WATERSHED | ginger '];
            uicontrol('style','popup','tag','ippopup',...
                'fontsize',fs,'units',umode,...
                'position', [293/xfac uy2-15/yfac 80/xfac 12/yfac],...
                'callback',[mfilename ' ippopup'],...
                'string', str,'value',1);     
            
            %%%%%%%%%%%%%% ROW 4 (Bottom)
            if ~srf;
                %                  %%%%%%%%%%%%%%%%% Line Of Interest
                uicontrol('tag','profile','callback',[mfilename ' loi'],...
                    'fontsize',fs,'units',umode,'visible',vis,...
                    'position',[0 0 ubw uh],'string','LOI',...
                    'tooltipstring','Line Of Interest',...
                    'backgroundcolor',def);
                %                      %%%%%%%%%%%%%%%%% Region Of Interest
                uicontrol('tag','tc','callback',[mfilename ' roi'],...
                    'fontsize',fs,'units',umode,'visible','on',...
                    'position',[40/xfac 0 ubw uh],'string','ROI',...
                    'tooltipstring','Region of Interest','backgroundcolor',def);
                %                      %%%%%%%%%% ALIGN
                uicontrol('tag','align','callback',[mfilename ' align'],...
                    'fontsize',fs,'units',umode,'visible','on',...
                    'position',[80/xfac 0 ubw uh],'string','align',...
                    'tooltipstring','Align'); 
            end % if ~srf
            %                       %%%%%%%%%% NEW
            uicontrol('tag','restart','callback',[mfilename ' new'],...
                'fontsize',fs,'units',umode,...
                'position',[160/xfac 0 ubw uh],'string','New',...
                'tooltipstring','Load new leist');   
            %						%%%%%%%%% 
            uicontrol('tag','save','callback',[mfilename ' save'],...
                'fontsize',fs,'units',umode,...
                'position',[200/xfac 0 ubw uh],'string','save',...
                'tooltipstring','Save');
            %                          %%%%%% QUIT 
            uicontrol('tag','quit','style','pushbutton','callback',[mfilename ' quit'],...
                'fontsize',fs,'units',umode,...
                'position',[240/xfac 0 ubw uh],'string','close',...
                'tooltipstring','Close this window');
            
            %      ******** Clip/Stretch uicontrols ***********
            uh2=12/yfac;
            switch class(Movi)
                case 'uint8'
                    class1='8 bit'; bitdepth=8;
                case 'uint16'
                    class1='16 bit'; bitdepth=16;
                case 'double';
                    class1='double'; bitdepth=24;
            end
            if isrgb(Movi) & size(size(Movi),2)>3; class1='rgb'; bitdepth=8; end
            def=[.7 .7 1];
            hlohitxt=uicontrol('tag','lohitxt','style','text',...
                'fontsize',fs,'units',umode,...
                'position',[295/xfac uy4+2*uh2 usw 12/yfac],...
                'string',[class1],...
                'backgroundcolor',def);    
            hlohi=uicontrol('tag','lohi','style','text',...
                'fontsize',fs,'units',umode,...    
                'position',[295/xfac uy4+uh2 usw 12/yfac],...
                'string',[num2str(mn) ' : ' num2str(mx)], 'tooltipstring','LoHi',...
                'backgroundcolor',def);
            %                  %%%%%%%% CLIP (floor & ceiling) 
            uicontrol('tag','clip', 'callback',[mfilename ' clip'],...
                'fontsize',fs,'units',umode,...
                'position',[295/xfac uy4-2.8*uh2-0/yfac ubw uh],...
                'string','Apply','tooltipstring','Apply',...
                'backgroundcolor',def);      
            %%%%%%% CONVERT TO 8 BIT (stretch also to 256 levels)
            cb=' convert'; if (isrgb(Movi)); cb=' rgb2gray'; end  
            vis='on'; 
            if isa(Movi,'uint8') & ~isrgb(Movi); vis='off'; end
            uicontrol('tag','to8bit', 'callback',[mfilename cb],...
                'fontsize',fs,'units',umode,...
                'position',[340/xfac uy4-2.8*uh2-0/yfac ubw uh],...
                'string','->8bit','tooltipstring','->8bit',...
                'backgroundcolor',def, 'visible', vis);          
            
            %                               %%%%%%%%% Lo SLIDER
            vis='on'; if isrgb(Movi); vis='off'; end
            minstep=min(1,1/(mx-(mx>1)));maxstep=min(1,10*minstep);
            uicontrol('tag','lo','style','slider','callback',[mfilename ' lohi'],...
                'fontsize',fs,'units',umode,...            
                'position',[295/xfac uy4 usw uh2],'min',mn,'max',mx,...
                'sliderstep',[minstep maxstep],...
                'tooltipstring',['Min ' num2str(mn)],'value',mn,...
                'backgroundcolor',def);
            
            %                               %%%%%%%%% Hi
            minstep=1/(mx-(mx>1));maxstep=.05;
            uicontrol('tag','hi','style','slider','callback',[mfilename ' lohi'],...
                'fontsize',fs,'units',umode,...
                'position',[295/xfac uy4-uh2 usw uh2],'min',mn,'max',mx,...
                'sliderstep',[minstep maxstep],...
                'tooltipstring',['Max ' num2str(mx)],'value',mx,...
                'backgroundcolor',def);
            
            if isrgb(Movi)
                mn=0; mx=5;  
                set(hlohitxt,'string','RGB')
                %   set(hlohi,'string','factor')
                uicontrol('tag','rrgb','style','slider','callback',[mfilename ' rgbrgb'],...
                    'fontsize',fs,'units',umode,...            
                    'position',[295/xfac uy4+12 usw uh2],'min',mn,'max',mx,...
                    'sliderstep',[minstep maxstep],'visible','on',...
                    'tooltipstring','Red multiply','value',1,...
                    'backgroundcolor',def,'userdata','1');
                uicontrol('tag','grgb','style','slider','callback',[mfilename ' rgbrgb'],...
                    'fontsize',fs,'units',umode,...            
                    'position',[295/xfac uy4-uh2+12 usw uh2],'min',mn,'max',mx,...
                    'sliderstep',[minstep maxstep],'visible','on',...
                    'tooltipstring','Green multiply','value',1,...
                    'backgroundcolor',def,'userdata','2');
                uicontrol('tag','brgb','style','slider','callback',[mfilename ' rgbrgb'],...
                    'fontsize',fs,'units',umode,...            
                    'position',[295/xfac uy4-2*uh2+12 usw uh2],'min',mn,'max',mx,...
                    'sliderstep',[minstep maxstep],'visible','on',...
                    'tooltipstring','Blue multiply','value',1,...
                    'backgroundcolor',def,'userdata','3');
            end        
            
            uicontrol('tag','abort','callback',[mfilename ' abort'],...
                'visible','off','position',[10 10 150 50],...
                'string','ABORT','foregroundcolor','red',...
                'fontweight','bold','fontsize',18)
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if srf; rotate3d on; end    
            drawnow
            Movi2=Movi;
            vals={list mapname Movi Movi2 play srf pse};
            bbsetappdatas(hfig,names,vals);   
            try; setappdata(hfig,'imgdesc',imgdesc); catch; end
            setappdata(hfig,'swing',swing); setappdata(hfig,'square',0)
            if ~isrgb(Movi); 
                eval([mfilename ' lohi']) 
            end
            % if srf; return; end
            if len>1; eval([mfilename ' replay']); end
            
            % ************** END OF SETUP - BELOW ARE CALLBACKS ***********  
            
        case 1 % Begin by getting application-defined
            %  variables (bbgetappdatas) and commonly used handles
            [list mapname Movi Movi2 play srf pse]=bbgetappdatas(gcf,names);
            hfig=gcf;
            hax=gca;
            imgdesc=getappdata(hfig,'imgdesc');
            %set(hfig,'interruptible','off');
            hfs=findobj(hfig,'tag','frameslider');
            hffs=findobj(hfig,'tag','firstframeslider');
            hlfs=findobj(hfig,'tag','lastframeslider');
            himg=findobj(hfig,'tag','himg');
            hpicname=findobj(hfig,'tag','picname');    
            habort=findobj(hfig,'tag','abort');
            switch (varargin{:}) % CALLBACKS
                %%%% ROW 1 %%%%%%%%%%%%%%    
                case 'abort'
                    setappdata(0,'abort',1); set(habort,'visible','off')
                case 'button'
                    button=get(hfig,'selectiontype');
                    switch button
                        case 'normal' % left button
                        case 'alt'    % right button
                    end
                case 'keypress'
                    k=get(hfig,'currentcharacter');
                    switch k
                        case 'x'
                            setappdata(0,'abort',1)
                        otherwise
                    end
                case 'xyz1.pixval' %%%%%%%%%% DISPLAY POSITION, BRIGHTNESS
                    button=get(hfig,'selectiontype');
                    zm=get(findobj(hfig,'tag','hzoom'),'userdata'); if zm; return; end
                    if strcmp(button,'alt')            
                        setappdata(hfig,'play',0)
                        pixval % display pixel tracking bar              
                    elseif strcmp(button,'normal')
                    end
                case 'xyz1'
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
                            if isrgb(Movi); z=double(m(y,x,:)); str=[num2str(z(1)) ':' num2str(z(2)) ':' num2str(z(3))];
                            else
                                z=double(m(y,x)); 
                                str=[num2str(x) ':' num2str(y) ':' num2str(z)]; end
                        catch;return;end;
                        set(findobj(hfig,'tag','xyz'),'string',str);
                    end
                    
                case 'loop' % play/swing
                    play=getappdata(hfig,'play');
                    hlb=findobj(hfig,'tag','loopbutton');
                    swing=getappdata(hfig,'swing'); 
                    if isempty(play); play=1; setappdata(hfig,'play',1); end
                    switch play
                        case 0
                            str='play'; if swing str='swing'; end  
                        case 1
                            swing=~swing; setappdata(hfig,'swing',swing);
                            str='play'; if swing str='swing';end; 
                        end 
                        set(hlb,'fontweight','light','foregroundcolor','k','string',str)
                        setappdata(hfig,'play',1); set(hax,'visible','off'); setappdata(0,'swing',swing);
                        eval([mfilename ' replay']);           
                        
                    case 'replay' %%%%%%%%%%%% PLAY MOVIE
                        %  set (hfig,'interruptible','on')
                        currentobj=gco; if isempty(currentobj); set(hfig, 'currentobject',1); currentobj=1; end
                        swing=getappdata(hfig,'swing');
                        % picinfo=getappdata(0,'imgholdinfo');
                        try            
                            hsrf=findobj(hax,'tag','hsrf'); hxyz=findobj(hfig,'tag','xyz');
                            hpicname=findobj(hfig,'tag','picname'); 
                            while (play)   
                                tic;                
                                jmin=round(get(hffs,'value')); jjmax=round(get(hlfs,'value')); jjj=jmin; 
                                while ((jjj <= jjmax) & (play > 0))                    
                                    if swing<2; swing=getappdata(hfig,'swing'); end
                                    j4=jjj; if swing>1; j4=jjmax-(jjj-jmin); end
                                    pse2=getappdata(hfig,'pse'); pse2(jmin)=pse2(1); pse2(jjmax)=pse2(end);
                                    srf=getappdata(hfig,'srf'); play=getappdata(hfig,'play'); 
                                    set(hfs,'value',j4); str=[num2str(j4) ': ' list{j4}]; set(hpicname,'string',str);                    
                                    %if ~isempty(picinfo); disp(picinfo{j4}); end
                                    if (play)
                                        if (srf==0)
                                            if ~isrgb(Movi) | size(size(Movi),2)<4 ;
                                                set(himg,'cdata',Movi(:,:,j4));
                                            else
                                                set(himg,'cdata',Movi(:,:,:,j4));
                                            end
                                        else
                                            if isrgb(Movi); aa=Movi(:,:,:,j4); else aa=Movi(:,:,j4); end
                                            set(hsrf,'zdata',aa,'cdata',aa); 
                                            % set(hsrf,'cdata',aa);                  
                                        end
                                        step=round(get(findobj(hfig,'tag','moviestepslider'),'value'));
                                        if (jjj+step>jjmax); 
                                            pause(pse2(end)*play);
                                        else; 
                                            pause (pse2(j4)*(play));
                                        end;                        
                                    end                       
                                    jjj=(jjj+step);                      
                                    if isempty(gco) Movi=getappdata(hfig,'Movi');
                                    elseif currentobj ~= gco; Movi=getappdata(hfig,'Movi'); end                     
                                end   % while (jjj <= ...)
                                swing=swing*2*(swing<2); % 0 if no swing; 1 if swing fwd, 2 if swing back
                                set(findobj(hfig,'tag','moviestepslider'),...
                                    'tooltipstring',['MovieStep ' num2str(step)]);
                                Movi=getappdata(hfig,'Movi'); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                tt=toc-sum(pse2);
                                %                if play & jjmax>1; 
                                %                   str=[num2str(round(10*(jjmax-jmin+1)/(tt+(tt==0))/10)) ' fps'];
                                %                  set(hxyz,'string',str); 
                                %             end
                                if jmin==jjmax; play=0; setappdata(hfig,'play',0); end
                            end % while (play)
                        catch;return;end  
                        
                    case 'framebyframe' %%%%%%%%%%%% FRAME-BY-FRAME               
                        setappdata(hfig,'play',0); 
                        % loopbutton, frameslider,firstfs,lastfs,picname,himg,hsrf
                        hlb=findobj(hfig,'tag','loopbutton');
                        hpicname=findobj(hfig,'tag','picname');
                        set(hlb,'fontweight','bold','foregroundcolor','red') %,'string',str)                    
                        a=round(get(hfs,'value'));
                        hh=findobj(hfig,'tag','himg');
                        %picinfo=getappdata(0,'imgholdinfo');
                        if srf hh=findobj(hfig,'tag','hsrf'); end   
                        jmin=round(get(hffs,'value'));
                        if isempty(jmin); 
                            a=1; jmin=1; jmax=1;
                        else            
                            jmax=round(get(hlfs,'value')); b=jmin*(a<jmin)+jmax*(a>jmax); a=a*~b+b;        
                            set(hfs,'value',a); str=[num2str(a) ': ' list{a}];
                            set(hpicname,'string',str);        
                        end                    
                        if ~play & ~isempty(imgdesc); disp([num2str(a) ': ' char(imgdesc{a})]); end
                        %if ~isempty(picinfo); disp(picinfo{a}); end
                        if ~isrgb(Movi); set(hh,'cdata',Movi(:,:,a));
                            if srf set(hh,'zdata',Movi(:,:,1)); end
                        else    set(hh,'cdata',Movi(:,:,:,a));
                        end
                        set(hfs,'tooltipstring',['Manual ' num2str(a)]);
                        drawnow  
                        
                    case 'pause1'
                        pse(1)=(pse(1)==0); % max((pse(1)<1),pse(1))
                        h=findobj('tag','pausestart');
                        clr=[.8 .8 .8]; if pse(1); clr='red'; end
                        set(h,'backgroundcolor',clr)
                        setappdata(hfig,'pse',pse);
                        
                    case 'pause2'
                        pse(end)=(pse(end)==0); % max((pse(end)<1),pse(2));
                        h=findobj('tag','pauseend');
                        clr=[.8 .8 .8]; if pse(end); clr='red'; end
                        set(h,'backgroundcolor',clr)
                        setappdata(hfig,'pse',pse)
                        
                    case 'figsize'         
                        xadd=20; yadd=120;
                        sz=size(Movi(:,:,1)); imx=sz(1); imy=sz(2);
                        hfss=findobj(hfig,'tag','figsizeslider');
                        figfac=get(hfss,'value'); % if isempty(figfac); figfac=1;end
                        if (figfac==0.1); figfac=1;end % Minimum resets size      
                        scrnsz=get(0,'screensize'); scrnx=scrnsz(3); scrny=scrnsz(4);
                        set(hfss, 'tooltipstring',['FigSize ' num2str(figfac)], 'value',figfac)   
                        set(findobj(hfig,'tag','figsizeslidertxt'),...
                            'string',['FigSize ' num2str(round(figfac*100)/100)]);
                        figpos0=get(hfig,'position');
                        figpos3=max(370,(sz(2)*figfac+xadd));
                        figpos4=sz(1)*figfac+yadd;
                        figpos1=min(figpos0(1),(scrnsz(3)-figpos3)/1.5);
                        figpos2=min(figpos0(2),(scrnsz(4)-figpos4));
                        figpos=round([figpos1 figpos2 figpos3 figpos4]);
                        uu=get(hfig,'units'); 
                        set(hfig,'units','pixels')
                        set(hfig,'position',figpos)
                        set(hfig,'units',uu)
                        impos=[10 yadd sz(2)*figfac sz(1)*figfac];        
                        set(hax,'visible','off','units','pixels','position',impos)
                        set(hax,'units','normalized')
                        drawnow
                        
                        %%%%%%%%%% ROW 2             
                    case 'sliderpause'
                        hss=findobj(hfig,'tag','speedslider'); 
                        hsst=findobj(hfig,'tag','speedslidertxt');
                        pse(2:end-1)=get(hss,'value');
                        if (pse(1)<1);pse(1)=pse(2);end
                        if (pse(end)<1);pse(end)=pse(2);end
                        setappdata(hfig,'pse',pse);
                        set(hss,'tooltipstring',['Pause ' num2str(pse(2))]);
                        set(hsst,'string',['Pause ' num2str(pse(2))]);
                        
                    case 'moviestep'
                        hmss=findobj(hfig,'tag','moviestepslider');hmsst=findobj(hfig,'tag','moviestepslidertxt');
                        step=get(hmss,'value');
                        set(hmss,'tooltipstring',['Moviestep ' num2str(step)]);
                        set(hmsst,'string',['Moviestep ' num2str(step)]);
                        
                    case 'firstframe' 
                        hffst=findobj(hfig,'tag','firstframeslidertxt');
                        n1=round(get(hffs,'value')); n2=round(get(hlfs,'value'));   
                        if (n1>n2); n1=n2; set(hffs,'value',n1);end
                        set (hffs,'tooltipstring',['FirstFrame ' num2str(n1)]);
                        set (hffst,'string',['First ' num2str(n1)]);    
                        
                    case 'lastframe'
                        hlfst=findobj(hfig,'tag','lastframeslidertxt');
                        n1=round(get(hffs,'value')); n2=round(get(hlfs,'value'));   
                        if (n2<n1); n2=n1; set(hlfs,'value',n2);end
                        set (hlfs,'tooltipstring',['LastFrame ' num2str(n2)]);
                        set (hlfst,'string',['Last ' num2str(n2)]);    
                        
                        %%%%%%%%%%%%%%%% ROW 3 %%%%%%%%%%%%%%%
                    case 'color'
                        set(hfig,'userdata','hello'); % set(hfig,'interruptible','on')
                        bbcolor
                        
                    case '3D'  
                        if isrgb(Movi); 
                            hdlg=msgbox('Convert to 8 bit first');
                            uiwait(hdlg); return; end 
                        hfss=findobj(hfig,'tag','figsizeslider');
                        h3d=findobj(hfig,'tag','surf');
                        setappdata(hfig,'play',0);
                        a=round(getrect);
                        xl=a(1);xu=xl+a(3);yl=a(2);yu=yl+a(4);
                        %if isrgb(Movi); Movi2=double(Movi(yl:yu,xl:xu,:,:)); aa=Movi2(:,:,:,1);  
                        %else 
                        Movi2=double(Movi(yl:yu,xl:xu,:)); aa=Movi2(:,:,1); 
                        %end
                        lo=min(Movi2(:)); hi=max(Movi2(:));
                        if isa(Movi,'uint16') % & ~isrgb(Movi);
                            hlo=findobj(hfig,'tag','lo'); hhi=findobj(hfig,'tag','hi');
                            lo=round(get(hlo,'value')); hi=round(get(hhi,'value'));
                        end  
                        setappdata(hfig,'Movi2',Movi2);           
                        setappdata(0,'makesurf',1);
                        eval([mfilename [' surface' num2str(hfig)] ' surface' ' surface'])      
                        
                    case 'crop'
                        setappdata(hfig,'square',0)
                        set(hfig,'userdata','hello'); % set(hfig,'interruptible','on');
                        bbgetrect 
                        waitfor(hfig,'userdata')
                        pos=getappdata(hfig,'pos');
                        lastrect=getappdata(0,'lastrect');
                        a(1)=max(1,pos(1)); a(2)=max(1,pos(2));        
                        a(3)=min(size(Movi,2),a(1)+pos(3)); a(4)=min(size(Movi,1),a(2)+pos(4));        
                        allfig=findobj(0,'type','figure')'; 
                        prompt={['X Left? Type 0 to use last rectangle: (' num2str(lastrect) ')'],...
                                'Y Top?' 'X Right side?' 'Y Bottom?',...
                                ['Which figure(s) to crop? (Choose from ' num2str(allfig) ' )']};
                        title='Crop position?'; lineno=1; 
                        def={num2str(a(1)) num2str(a(2)) num2str(a(3)) num2str(a(4)) num2str(hfig)};
                        ans=inputdlg(prompt,title,lineno,def);
                        if isempty(ans); return; end
                        %set(habort,'visible','on')
                        mm=str2num(ans{5})'; nfigs=size(mm,1); 
                        if strcmp(ans{1},'0'); a=lastrect; 
                        else
                            a(1)=max(1,str2num(ans{1})); a(2)=max(1,str2num(ans{2}));
                            a(3)=min(size(Movi,2),str2num(ans{3})); 
                            a(4)=min(size(Movi,1),str2num(ans{4}));
                        end        
                        setappdata(0,'lastrect',a)
                        for jj=1:nfigs            
                            hfig=mm(jj,1); Movi=getappdata(hfig,'Movi');
                            if isrgb(Movi); Movi2=Movi(a(2):a(4),a(1):a(3),:,:);         
                            else Movi2=Movi(a(2):a(4),a(1):a(3),:); end
                            setappdata(hfig,'Movi2',Movi2);
                            figure(hfig)
                            srf=getappdata(hfig,'srf'); setappdata(0,'makesurf',srf);
                            eval ([mfilename ' crop' [' crop' num2str(hfig)] ' crop']) % to make nargin=3            
                        end
                        
                    case 'resize'  %%%%%%%%%%%%%
                        szx=size(Movi,2); szy=size(Movi,1); szz=size(Movi,3+isrgb(Movi));
                        sz=get(0,'screensize'); mxx=sz(3); mxy=sz(4);            
                        mxfac=floor(min(mxx/szx, mxy/szy)*10)/10; 
                        prompt={['Zoom factor? (max=' num2str(mxfac) ')'],...
                                ['pad x (add pixels on right side)'],['pad y (add pixels on bottom)']};
                        def={'1','0','0'};
                        lineno=1; title='Zoom or Pad';
                        inp=inputdlg(prompt,title,lineno,def); if isempty(inp); return; end 
                        zf=str2num(inp{1}); padx=str2num(inp{2}); pady=str2num(inp{3});
                        if zf==1
                            padxx=padx; padyy=szy;
                            for j=1:2
                                if j==2; padxx=szx; padyy=pady; end
                                if (padxx & padyy)
                                    b=uint8(0); 
                                    if isrgb(Movi)
                                        b=b(ones(1,padyy),ones(1,padxx),ones(1,3),ones(1,szz));
                                    else
                                        b=b(ones(1,padyy),ones(1,padxx),ones(1,szz));
                                    end
                                    if j==1; Movi=[Movi b]; szx=size(Movi,2);
                                    else Movi=[Movi; b]; end                        
                                end    
                            end
                            setappdata(hfig,'Movi',Movi); Movi2=Movi; setappdata(hfig,'Movi2',Movi2);             
                        end
                        
                        if zf ~= 1   
                            interpmode=questdlg('Zoom interpolation mode? (nearest is fastest)','Interpolation mode',...
                                'nearest','bilinear','bicubic','nearest');
                            set(habort,'visible','on')
                            Movi=getappdata(hfig,'Movi');
                            zoomfac=zf; % str2num(zf{:}); 
                            if isrgb(Movi); Movix=imresize(Movi(:,:,:,1),zoomfac); 
                            else Movix=imresize(Movi(:,:,1),zoomfac); end
                            rows=size(Movix,1); cols=size(Movix,2); len=length(list); % just to get final size of img
                            Movi2=uint16(0); if isa(Movi,'uint8'); Movi2=uint8(0); end
                            if isrgb(Movi); Movi2= Movi2(ones(1,rows),ones(1,cols),ones(1,3),ones(1,len));
                            else Movi2= Movi2(ones(1,rows),ones(1,cols),ones(1,len)); end % resizing uints         
                            htxt=text(20,50,'...','fontsize',32,'color','red');
                            for j=1:length(list); 
                                if getappdata(0,'abort'); set(habort,'visible','off'); setappdata(0,'abort',0); return; end
                                disp([num2str(j) '/' num2str(length(list))])
                                set(htxt,'string',[num2str(j) '/' num2str(length(list))]); pause(.1)
                                if isrgb(Movi); Movi2(:,:,:,j)=imresize(Movi(:,:,:,j),zoomfac,interpmode); 
                                else Movi2(:,:,j)=imresize(Movi(:,:,j),zoomfac,interpmode); end                
                            end
                            set(habort,'visible','off')
                            delete (htxt); 
                            setappdata(hfig,'Movi2',Movi2); 
                        end
                        eval ([mfilename ' resize' ' resize' ' resize'])
                        
                    case 'zoom' 
                        hzoom=findobj(hfig,'tag','hzoom');
                        zm=get(hzoom,'userdata');
                        zm=~zm;
                        set(hzoom,'userdata',zm);
                        switch zm
                            case 0
                                set(hzoom,'foregroundcolor','black')
                                eval('zoom') 
                            case 1
                                set(hzoom,'foregroundcolor','red')
                                eval('zoom')
                        end    
                        
                    case 'erase'       
                        delete(findobj(hfig,'type','line'))
                        delete(findobj(hfig,'type','rectangle'))
                        delete(findobj(hfig,'type','text'))
                        
                    case 'label'
                        hlbl=findobj(hfig,'tag','label'); 
                        lbl=get(hlbl,'userdata');
                        lbl=~lbl;
                        set(hlbl,'userdata',lbl);
                        switch lbl
                            case 0
                                %set(hfig,'windowbuttondownfcn',[mfilename ' xyz1']);
                                set(himg,'buttondownfcn',[mfilename ' xyz1']);
                                setappdata(hfig,'labelcounter',0);
                                set(hlbl,'foregroundcolor','black')
                            case 1
                                set(hfig,'windowbuttondownfcn','');
                                set(hfig,'windowbuttondownfcn',[mfilename ' label2']);
                                set(hlbl,'foregroundcolor','red')    
                        end    
                        
                    case 'label2'
                        [x y]=bbgetcurpt(gca);
                        x=round(x);
                        y=round(y);
                        button=get(hfig,'selectiontype');
                        if (strcmp(button,'alt')) % right button
                            if strcmp(get(gco,'type'),'text'); delete(gco);  % delete existing label
                            else
                                nn=getappdata(hfig,'labelcounter');
                                text (x,y,num2str(nn+1),'color','red')
                                setappdata(hfig,'labelcounter',nn+1)
                            end
                        elseif (strcmp(button,'extend')) % both buttons NO JOY!
                            beep
                        elseif (strcmp(button,'normal')) % left button  
                            if strcmp(get(gco,'type'),'text'); % edit existing label
                                a=get(gco); % struct array
                                def={a.String,a.FontSize,a.Color,a.Rotation,a.FontName,a.FontAngle,...
                                        a.FontWeight,a.HorizontalAlignment,a.VerticalAlignment};
                                for j=2:4; def{j}=num2str(def{j}); end
                                delete(gco);    
                            else 
                                def=getappdata(hfig,'lasttext'); 
                                def={'', '18', '[1 0 0]', '0', 'helvetica', 'normal', 'normal', 'left', 'middle'};
                            end
                            prompt={'Label?', 'size', 'color (0-1 for R,G, and B)', 'rotation', 'font',...
                                    'angle (normal/italic)', 'weight(normal/bold)',...
                                    'HorizAlign(left/center/right)', 'VertAlign (top/middle/bottom)'};            
                            str=inputdlg(prompt,'Label',1,def); % str=cell array
                            %strg=str{1}; % convert to string
                            htxt=text(x,y,str{1},'fontsize',str2num(str{2}),'color',str2num(str{3}),...
                                'rotation',str2num(str{4}),'fontname',str{5},'fontangle',str{6},...
                                'fontweight',str{7},'horizontalalignment',str{8},...
                                'verticalalignment',str{9});
                            setappdata(hfig,'lasttext',get(htxt))
                            if strcmp(str{1},''); delete(htxt);end            
                        end        
                        
                        %%%%%%%%%%%%%%%%%% ROW 4 %%%%%%%%%%%%%%%%%%%%%%%%%%
                    case 'loi' % Line Of Interest
                        setappdata(hfig,'play',0); 
                        set(hfig,'userdata','hello'); % set(hfig,'interruptible','on');
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
                        if isempty(jmin); jmin=1; jmax=1; end
                        for j=jmin:jmax; % 1:length(list)  % get brightness (z) values
                            m=Movi(:,:,j);
                            z(:,j)=double(m(sub2ind(size(m),y3,x3)));
                        end
                        setappdata(hfig,'zdata',z); setappdata(0,'xdata',[])
                        set(hfig,'userdata','profile');
                        bbplot;
                        set (0,'currentfigure',hfig)
                        setappdata(hfig,'userdata','');
                        figure(hfig);        
                        
                    case 'roi' % Region Of Interest
                        setappdata(hfig,'play',0); setappdata(hfig,'picknum',0);
                        roivars=getappdata(0,'roivars'); rgbcollapse=0;
                        if isempty(roivars); 
                            roivars={'a' 'a' '2' '2' '1' '1'}; setappdata(0,'roivars', roivars); 
                        end
                        aa=roivars(1:2); bb=roivars(3:6);
                        
                        if isrgb(Movi)
                            %prompt={'Collapse RGB layers? (y/n)?',...
                            %    'AVERAGE (a), SUM (s) or BRIGHTEST (b) pixel'};
                            prompt={'Collapse RGB layers? (y/n)?',...
                                    'AVERAGE (a) or BRIGHTEST (b) pixel'};
                            title='RGB images'; def={'y' 'a'}; lineno=1;
                            inp1=inputdlg(prompt,title,lineno,def); if isempty(inp1); return; end
                            roimode='p'; rgbcollapse=strcmp(inp1{1},'y'); calcmode=inp1{2};
                        else
                            prompt={'DRAW (d) or PICK (p) or AUTO by threshold brightness (a)?',...
                                    'AVERAGE (a) or BRIGHTEST (b) pixel'};
                            title='How to select area, What to calculate'; lineno=1; def=aa;
                            inp1=inputdlg(prompt,title,lineno,def); if isempty(inp1); return; end
                            roimode=inp1{1}; calcmode=inp1{2};
                            setappdata(0,'roivars',[inp1' bb])
                        end    
                        if (strcmp(roimode,'p')) % Pick
                            if length(list)==1; bb{4}='0'; end % histo
                            prompt={'First spot radius? (Spot diameter=2*size+1)',...
                                    'Last spot radius?',...
                                    'Step size from first to last?',...                    
                                    'All pics(1) or this only(0)?'};
                            title='Spot size (first size to last size, step size)'; lineno=1;
                            def=bb;
                            inp=inputdlg(prompt,title,lineno,def); 
                            if isempty(inp); return; end
                            setappdata(0,'roivars',[inp1' inp']);
                            rad1=str2num(inp{1}); rad2=str2num(inp{2}); stepit=str2num(inp{3});           
                            if rad2<rad1;rad2=rad1; end
                            histo=~str2num(inp{4});  if length(list)==1; histo=1;end 
                            setappdata(hfig,'roirad',round((rad1+rad2)/2));
                            
                            set(hfig,'userdata','hello'); % 
                            bbgetpts 
                            waitfor(hfig,'userdata')
                            x=getappdata(hfig,'xdata'); y=getappdata(hfig,'ydata');
                            rad=getappdata(hfig,'roirad');   
                            
                            Movi=getappdata(hfig,'Movi'); szx=size(Movi,2); szy=size(Movi,1);
                            hffs=findobj(hfig,'tag','firstframeslider');
                            hlfs=findobj(hfig,'tag','lastframeslider');
                            jmin=round(get(hffs,'value'));
                            jmax=round(get(hlfs,'value')); 
                            jnow=get(hfs,'value'); if histo; jmin=jnow; jmax=jnow; end
                            ok=1; z2=[]; z=[];
                            while ok% for allorone==0 (single image data only)
                                col=1;
                                for rad=rad1:stepit:rad2
                                    for spot=1:size(x,2)
                                        xmin=max(1,x(1,spot)-rad); xmax=min(szx,x(1,spot)+rad);
                                        ymin=max(1,y(1,spot)-rad); ymax=min(szy,y(1,spot)+rad);
                                        npix=abs((xmax-xmin+1)*(ymax-ymin+1)); 
                                        if isrgb(Movi) npix=3*npix;end
                                        row=0; 
                                        for frame=jmin:jmax; % get brightness (z) values
                                            row=row+1;
                                            if isrgb(Movi); m=Movi(:,:,:,frame); 
                                                if rgbcollapse
                                                    mm=double(m(ymin:ymax,xmin:xmax,:));
                                                    a=imadd(mm(:,:,1),mm(:,:,2)); a=imadd(a,mm(:,:,3));
                                                    mm=uint8(imdivide(a,3));  
                                                    z(row,col)=sum(mm(:));
                                                    if strcmp(calcmode,'a'); z(row,col)=z(row,col)/npix; end
                                                    if strcmp(calcmode,'b'); z(row,col)=max(mm(:)); end    
                                                else
                                                    for k=1:3; 
                                                        mm=m(ymin:ymax,xmin:xmax,k); 
                                                        cc=col+k-1;
                                                        z(row,cc)=sum(mm(:));
                                                        if strcmp(calcmode,'a'); z(row,cc)=z(row,cc)/npix; end
                                                        if strcmp(calcmode,'b'); z(row,cc)=max(mm(:)); end    
                                                    end; end
                                            else 
                                                try; 
                                                    m=Movi(:,:,frame); mm=m(ymin:ymax,xmin:xmax);                                                          
                                                    z(row,col)=sum(mm(:));
                                                    if strcmp(calcmode,'a'); z(row,col)=z(row,col)/npix; end
                                                    if strcmp(calcmode,'b'); z(row,col)=max(mm(:)); end    
                                                catch; 
                                                    z(row,col)=-1; 
                                                    disp(['error! row ' num2str(row) ' col ' num2str(col)])
                                                end; 
                                            end          
                                        end % for frame=jmin...
                                        col=col+1+2*isrgb(Movi)*~rgbcollapse;
                                        if strcmp(calcmode,'s'); z(:,col)=npix; col=col+1; end
                                    end % for spot=1...
                                end % for rad=rad1...                        
                                ok=0; 
                                if histo
                                    z2=double(z2); z=double(z);
                                    z2=bbpaste(z2, z'); z=[]; % horizontal paste
                                    inp=questdlg('Do another?','Another?','yes','no','no');
                                    if strcmp(inp,'yes'); ok=1; 
                                        set(hfig,'userdata','hello'); % 
                                        bbgetpts 
                                        waitfor(hfig,'userdata')
                                        x=getappdata(hfig,'xdata'); y=getappdata(hfig,'ydata'); 
                                        jnow=get(hfs,'value'); jmin=jnow; jmax=jnow;
                                    else
                                        z=z2;
                                    end
                                end
                            end % while ok
                            z=double(z);
                            set(himg,'buttondownfcn',[mfilename ' xyz1.pixval']);
                            setappdata(hfig,'zdata',z); setappdata(hfig,'histo',histo);
                            setappdata(0,'xdata',[])
                            % 5 rows: rows 1-3= spot#, x, y
                            % concatenated with z when saved in bbplot
                            z0=zeros(5,size(z,2));
                            for j=1:size(z0,2)
                                z0(1,j)=j;
                            end
                            z0(2,:)=x;
                            z0(3,:)=y;
                            setappdata(0,'z0',z0);
                            %%%%%%%%%%%%%%%
                            bbplot
                        elseif (strcmp(roimode,'d')) % Draw ROI
                            x3=[];y3=[];
                            inp='yes'; nspots=0; 
                            while strcmp(inp, 'yes')
                                set(hfig,'userdata','hello');
                                bbdraw
                                waitfor (hfig,'userdata')  
                                clc
                                x=getappdata(hfig,'xdata'); y=getappdata(hfig,'ydata');
                                x(end+1)=x(1);y(end+1)=y(1);x3=[]; y3=[];
                                for j=2:size(x,2);   % Interpolate - fill in gaps
                                    [xx, yy]=bbintline(x(j-1),x(j),y(j-1),y(j));
                                    x3=[x3;xx(1:max(1,end-1))]; y3=[y3;yy(1:max(1,end-1))];
                                end
                                hold on; 
                                line('xdata',x3,'ydata',y3,'color','white','linewidth',0.1)
                                %bw=double(roipoly(Movi(:,:,1),x3,y3)); npix=sum(bw(:));
                                bw=(roipoly(Movi(:,:,1),x3,y3)); npix=sum(bw(:));
                                %                 New figure for plotting z 
                                Movi=getappdata(hfig,'Movi');
                                hffs=findobj(hfig,'tag','firstframeslider');
                                hlfs=findobj(hfig,'tag','lastframeslider');
                                jmin=round(get(hffs,'value'));
                                jmax=round(get(hlfs,'value'));
                                row=0;
                                for j=jmin:jmax; % get brightness (z) values
                                    row=row+1;
                                    m=Movi(:,:,j);
                                    z(row,1)=sum(sum(m(bw)));                             % SUM
                                    if strcmp(calcmode,'s'); z(:,2)=npix; end
                                    if strcmp(calcmode,'a'); z(row,1)=z(row,1)/npix; end  % AVERAGE
                                    if strcmp(calcmode,'b'); z(row,1)=max(m(bw)); end     % MAX                       
                                end
                                nspots=nspots+1; 
                                if nspots==1; zz=z;
                                else 
                                    col=size(zz,2)+1; col2=size(z,2);
                                    zz(:,col:col+col2-1)=z; end;
                                z=[];
                                inp=questdlg('Do another?','Another?','yes','no','Cancel','no');
                                if strcmp(inp,'Cancel'); return; end
                            end
                            setappdata(hfig,'zdata',zz); %set(hfig,'userdata','tc');
                            set(himg,'buttondownfcn',[mfilename ' xyz1.pixval']); setappdata(0,'xdata',[])
                            bbplot;
                            set (0,'currentfigure',hfig)
                            set(hfig,'userdata','');    
                            
                        elseif (strcmp(roimode,'a')) % Auto 
                            %def=getappdata(0,'minarea');
                            %inp=inputdlg('Minimum area?' ,'Minimum area', 1 ,{'10'});
                            %if isempty(inp); inp={'10'}; end
                            minarea=10; % str2num(inp{:});
                            setappdata(hfig,'minarea',minarea)
                            histo=0; setappdata(hfig,'calcmode',calcmode)
                            Movi=getappdata(hfig,'Movi');              
                            jnow=get(hfs,'value'); % if histo; jmin=jnow; jmax=jnow; end
                            m=Movi(:,:,jnow); mx=double(max(m(:))); mn=double(min(m(:))); v=round(mx-0.8*(mx-mn));
                            hline=line('tag','roiautoline','visible','off','linestyle','none','marker','.','markersize',4,'color','red')            
                            
                            uicontrol('tag','roiauto1a','style','text','string',['min=' num2str(minarea)],...
                                'position',[2 35 80 30],'backgroundcolor','red','fontsize',12,...
                                'userdata','roiauto');
                            step=.01; 
                            uicontrol('tag','roiauto1b','style','slider','value',minarea,'min',1,'max',100,...
                                'sliderstep',[step 5*step],'callback',[mfilename ' roiautoslider'],...
                                'position',[2 5 80 30],'userdata','roiauto');
                            
                            uicontrol('tag','roiauto2a','style','text','string',['thresh=' num2str(v)],...
                                'position',[85 35 80 30],'backgroundcolor','red','fontsize',12,...
                                'userdata','roiauto');
                            step=1/(mx-mn-2); 
                            uicontrol('tag','roiauto2b','style','slider','value',v,'min',mn+1,'max',mx-1,...
                                'sliderstep',[step 5*step],'callback',[mfilename ' roiautoslider'],...
                                'position',[85 5 80 30],'userdata','roiauto');
                            %uicontrol('tag','roiautomask','string','make mask','position',[200 50 80 45],...
                             %   'callback',[mfilename ' roiautocalc'],'fontsize',18,...
                              %  'backgroundcolor','red','userdata','roiauto');   
                            uicontrol('tag','roiauto3','string','OK','position',[200 10 80 25],...
                                'callback',[mfilename ' roiautocalc'],'fontsize',18,...
                                'backgroundcolor','red','userdata','roiauto');           
                            eval([mfilename ' roiautoslider'])
                            
                        end % Draw or Pick    
                    case 'roiautoslider' 
                        h1=findobj('tag','roiauto1b'); % minarea
                        h1txt=findobj('tag','roiauto1a');
                        h2=findobj('tag','roiauto2b'); % thresh
                        h2txt=findobj('tag','roiauto2a');        
                        v=round(get(h2,'value'));
                        minarea=round(get(h1,'value'));
                        jnow=get(hfs,'value');
                        set(h2txt,'string',['thresh=' num2str(v)])
                        set(h1txt,'string',['min=' num2str(minarea)])
                        drawnow
                        m=Movi(:,:,jnow);
                        bw=(m>=v);
                        bwL=bwlabel(bw,4);
                        s=regionprops(bwL,'Area');
                        mn=9e99;
                        for j=1:size(s,1)
                            aa=s(j).Area;
                            if aa<minarea; bwL(bwL==j)=0; end
                            if aa<mn; mn=aa; end
                        end
                        disp(['Smallest area = ' num2str(mn) ' pixels'])
                        bw=(bwL>0);       
                        % display outline
                        bw2=bwmorph(bw,'remove');
                        [r,c]=find(bw2); 
                        hline=findobj('tag','roiautoline');
                        set(hline,'visible','on','xdata',c,'ydata',r);
                        setappdata(hfig,'roiautobw',bw)
                        drawnow
                    case 'roiautocalc'
                        a=findobj('userdata','roiauto'); delete(a)
                        bw=getappdata(hfig,'roiautobw');
                        calcmode=getappdata(hfig,'calcmode');
                        Movi=getappdata(hfig,'Movi');
                        hffs=findobj(hfig,'tag','firstframeslider');
                        hlfs=findobj(hfig,'tag','lastframeslider');
                        jmin=round(get(hffs,'value'));
                        jmax=round(get(hlfs,'value'));
                        
                        %** MASK ON ALL IMAGES? ****************
                        quest= ['Do you want to apply this as a mask to all pictures?'...
                        ' (If so, all pixels outside the region(s) will be set to zero)']
                        maskit=questdlg(quest,'Make mask?','Yes','No','No');
                        if strcmp(maskit,'Yes')
                            for j=jmin:jmax
                                aa=Movi(:,:,j);
                                aa(bw==0)=0;
                                Movi(:,:,j)=aa;
                            end
                            frame=get(hfs,'value');
                            set(himg,'cdata',Movi(:,:,frame))
                            setappdata(hfig,'Movi',Movi)    
                        end
                        %**************************************
                        
                        z=[];  
                        row=0; col=1;
                        for frame=jmin:jmax
                            row=row+1; 
                            m=Movi(:,:,frame);                                                    
                            m(~bw)=0;
                            s=sum(m(:));
                            npix=sum(bw(:));                   
                            if strcmp(calcmode,'a'); z(row,col)=s/npix; end
                            if strcmp(calcmode,'b') | strcmp(calcmode,'s'); z(row,col)=max(m(:)); end                        
                        end       
                        setappdata(hfig,'zdata',z);
                        disp([num2str(npix) ' pixels total'])
                        bbplot
                        set (0,'currentfigure',hfig)
                        set(hfig,'userdata',''); 
                    case 'align'
                        setappdata(hfig,'play',0); 
                        clc; 
                        Movi2=Movi;
                        jmin=round(get(hffs,'value'));
                        jmax=round(get(hlfs,'value'));
                        dmax=2; szy=size(Movi,1);
                        htxt=text('position',[5 szy/2], 'color','red', 'fontsize',14);
                        a0mode=2; % 1=auto 2=manual
                        %if ~isrgb(Movi);            
                        msg=['Select MANUAL or AUTO align' char(10) '                       INSTRUCTIONS:' char(10) char(10)...
                                'MANUAL: Left click in each image to choose point to be aligned. ' char(10)...
                                'Right click = back up.' char(10) char(10)...
                                'AUTO: Click and drag out box. ' char(10) 'Then choose either to ',...
                                'align brightest pixels or move box to find least squares fit' char(10)];     %hmsg=msgbox(msg,'Select align region'); uiwait(hmsg);
                        amode=questdlg(msg,'Align Mode','Auto','Manual','Cancel','Auto');
                        if strcmp(amode,'Cancel'); return; end
                        if (strcmp(amode,'Auto')); a0mode=1; end
                        %end;                        
                        %%%%%%%%%%%%%% MANUAL ALIGN %%%%%%%%%%%%%%%%%%%%%%%%%%
                        if (a0mode == 2); % manual
                            set(habort,'visible','on') % setup
                            jj=jmin; abort=0;
                            while jj<=jmax
                                if getappdata(0,'abort'); set(habort,'visible','off'); setappdata(0,'abort',0); return; end
                                if jj<jmin; jj=jmin; end
                                set(htxt,'string',[num2str(jj) '/' num2str(jmax)]); 
                                set(hfig,'pointer','circle');
                                disp([num2str(jj) '/' num2str(jmax)])
                                if isrgb(Movi); 
                                    set(himg,'cdata',Movi(:,:,:,jj));             
                                else set(himg,'cdata',Movi(:,:,jj)); end
                                set(hfig,'windowbuttondownfcn','uiresume');
                                uiwait                
                                button=get(hfig,'selectiontype');
                                switch button
                                    case {'normal' 'extend' 'open'} 
                                        [x y]=bbgetcurpt(gca);
                                        xyalign(jj,1)=round(x); xyalign(jj,2)=round(y);                    
                                    case 'alt'
                                        jj=jj-2;
                                        % case 'extend'
                                        %beep; abort=1; jj=999999;
                                        % case 'open'
                                        %beep; abort=1; jj=99999;
                                end
                                jj=jj+1;
                            end % while jj<=jmax            
                            set(himg,'buttondownfcn',[mfilename ' xyz1.pixval']); set(hfig,'pointer','arrow');
                            % if ~abort
                            beep
                            set(htxt,'string',' Wait...'); drawnow
                            disp('Wait...')
                            xybar=round(mean(xyalign(jmin:jmax,:)));
                            xyalign(:,1)=-(xyalign(:,1)-xybar(1,1));
                            xyalign(:,2)=-(xyalign(:,2)-xybar(1,2));
                            for jj=jmin:jmax
                                if getappdata(0,'abort'); set(habort,'visible','off'); setappdata(0,'abort',0); return; end
                                e=bbalign(jj,xyalign,Movi,9999e9);
                                if isrgb(Movi); Movi(:,:,:,jj)=uint8(e);
                                elseif isa(Movi,'uint8'); Movi(:,:,jj)=uint8(e); 
                                elseif isa(Movi,'uint16'); Movi(:,:,jj)=uint16(e); end
                            end
                            
                            %%%%%%%%%%%%%%%%% AUTO ALIGN %%%%%%%%%%%%%%%%%%%    
                        elseif (a0mode == 1) % auto
                            abort=0;
                            %%%%%%%%%%% Align: set up 2 squares
                            %[pos1]=round(bbgetrect('square'));
                            setappdata(hfig,'square',0)
                            set(hfig,'userdata','hello'); % set(hfig,'interruptible','on');
                            bbgetrect % draw rectangle, move it and click to close
                            waitfor(hfig,'userdata')
                            pos1=getappdata(hfig,'pos');  % final position
                            
                            xl=pos1(1); yl=pos1(2);wd=pos1(3);ht=pos1(4); % wd; 
                            szlittlebox=wd*ht;
                            rectangle('position',pos1,'edgecolor','r')                    
                            alignmode=1; % 1=align to previous; 2=align=first in list
                            ddwd=min(wd,10); ddht=min(ht,10); % size difference of larger window to scan
                            sz0=size(Movi); szx=sz0(2); szy=sz0(1);% rows,cols
                            Xl=max(1,xl-ddwd);Yl=max(1,yl-ddht); 
                            Xu=min(szx,xl+wd+ddwd); Yu=min(szy,yl+ht+ddht);
                            pos2=[Xl,Yl,Xu-Xl+1,Yu-Yl+1]; 
                            hrect=rectangle('position',pos2,'edgecolor','r');
                            drawnow
                            if isrgb(Movi)
                                prompt={'Align with first (f) or previous (p) image?',...    
                                        'Collapse stack(1) or not(0)'};
                                title='Auto align RGB'; lineno=1; def={'p' '1'};
                                inp=inputdlg(prompt,title,lineno,def);
                                alignmode=1+(strcmp(inp{1},'f')); collapsergb=str2num(inp{2});
                                dobrightest=1; alignmode=1; dd=10; dmax=10; trackit=0;
                            else    
                                prompt={'Width of frame (in pixels) around box? Type 0 to align to brightest pixel',...
                                        'Maximum movement for any single frame (pixels)?',...
                                        'Align with first (f) or previous (p) image?',...                                        
                                        'Smoothing? 0=no, or type radius',...
                                        'If smoothing: Std. deviation? (0=box average; >0=gaussian average)'  };
                                %  ['Track progress? (0=no; 1=yes)'...
                                %     char(10) 'Left click to toggle track on/off'],...
                                title='Auto align parameters'; lineno=1;
                                def={'10' '10' 'p' '1' '3' '0.65'}; 
                                inp=inputdlg(prompt,title,lineno,def);
                                if isempty(inp); return; end
                                ddd=str2num(inp{1}); dobrightest=(ddd==0); dd=max(0,min(ddd,50))+50*dobrightest; 
                                ddd=str2num(inp{2}); dmax=max(1,min(ddd,dd));
                                alignmode=1+(strcmp(inp{3},'f')); 
                                trackit=0; 
                                collapsergb=0; 
                                rad=str2num(inp{4}); std=str2num(inp{5});
                                smooth=(rad>0); filt='box'; if std filt='gaussian'; end
                            end
                            delete(hrect)
                            sz0=size(Movi); szx=sz0(2); szy=sz0(1);% rows,cols
                            Xl=max(1,xl-dd); Yl=max(1,yl-dd); 
                            Xu=min(szx,xl+wd+dd); Yu=min(szy,yl+ht+dd);
                            pos2=[Xl,Yl,Xu-Xl+1,Yu-Yl+1];
                            if ~dobrightest; hrect=rectangle('position',pos2,'edgecolor','r'); end
                            set(habort,'visible','on')
                            drawnow              
                            
                            xyalign(1,1)=0; xyalign(1,2)=0; 
                            if (alignmode==2); % align to first in list
                                if isrgb(Movi) a=double(Movi(yl:yl+ht,xl:xl+wd,:,jmin)); 
                                else a=double(Movi(yl:yl+ht,xl:xl+wd,jmin)); end % small box first frame 
                            end
                            setappdata(hfig,'trackit',trackit); 
                            set(hfig,'windowbuttondownfcn',[mfilename ' aligntrackit'])
                            
                            %%%%%%%%%%%%%%% AUTO align by brightest pixel %%%%%%%%%%%%%%%%
                            if dobrightest
                                dmax=9999;
                                if isrgb(Movi); a0=Movi(yl:yl+ht,xl:xl+wd,:,jmin); 
                                    if collapsergb
                                        mx=max(max(max(a0)));
                                        [y0,x0,z0]=ind2sub(size(a0),find(a0==mx)); 
                                        X0(1,1:3)=x0(1); Y0(1,1:3)=y0(1);                    
                                    else
                                        for k=1:3; mx=max(max(a0(:,:,k))); 
                                            [y0,x0]=ind2sub(size(a0),find(a0(:,:,k)==mx)); 
                                            X0(k)=x0(1); % +xl;% Brightest pixel in little box in first image (NOT ref to entire image)
                                            Y0(k)=y0(1); xl0=xl; yl0=yl; xyalign=zeros(jmin,2);
                                        end
                                    end    
                                else % brightest pixel, not rgb
                                    a0=Movi(yl:yl+ht,xl:xl+wd,jmin); %  small box frame #1                                        
                                    if smooth ao=smoothn(a0,[rad;rad],filt,std); end                    
                                    [y0,x0]=ind2sub(size(a0),find(a0==max(a0(:)))); 
                                    X0=x0(1); Y0=y0(1);
                                    % Brightest pixel in little box in first image (NOT ref to entire image)
                                end    
                                xl0=xl; yl0=yl; xyalign=zeros(jmin,2);
                                for jj=jmin+1:jmax
                                    if getappdata(0,'abort'); set(habort,'visible','off'); setappdata(0,'abort',0); return; end
                                    if isrgb(Movi)
                                        if collapsergb % brightest, RGB, collapse
                                            xl=xl0; yl=yl0; dxl=0; dyl=0;                            
                                            a=(Movi(yl:yl+ht,xl:xl+wd,:,jj)); %  small box
                                            mx=max(a(:));
                                            xy=find(a==mx); 
                                            [y6,x6,z6]=ind2sub(size(a),xy(1)); 
                                            xyalign(jj,1)=(X0(1)-x6-dxl); %  X0+xl-(Xl+x(1)); 
                                            xyalign(jj,2)=(Y0(1)-y6-dyl); % Y0+yl-(Yl+y(1));
                                            e=bbalign(jj,xyalign,Movi(:,:,:,:),dmax);
                                            Movi(:,:,:,jj)=uint8(e);
                                        else % brightest, RGB, no collapse
                                            for k=1:3
                                                xl=xl0; % +xyalign(jj-1,1); 
                                                yl=yl0; % +xyalign(jj-1,2); 
                                                dxl=0; %xl0-xl; 
                                                dyl=0; % yl0-yl;
                                                a=(Movi(yl:yl+ht,xl:xl+wd,k,jj)); %  small box
                                                mx=max(a(:));
                                                xy=find(a==mx); 
                                                [y6,x6]=ind2sub(size(a),xy(1)); 
                                                %xyalign(jj,1)=(X0-x6-dxl); %  X0+xl-(Xl+x(1)); 
                                                %xyalign(jj,2)=(Y0-y6-dyl); % Y0+yl-(Yl+y(1));                            
                                                xyalign(jj,1)=(X0(k)-x6-dxl); %  X0+xl-(Xl+x(1)); 
                                                xyalign(jj,2)=(Y0(k)-y6-dyl); % Y0+yl-(Yl+y(1));
                                                e=bbalign(jj,xyalign,Movi(:,:,k,:),dmax);
                                                ee=uint8(e); if isa(Movi,'uint16') ee=uint16(e); end
                                                Movi(:,:,k,jj)=ee;                                
                                                set(himg,'cdata',Movi(:,:,:,jj)); 
                                                drawnow                
                                            end % k=1:3
                                        end % if collapsergb   
                                    else % brightest, not RGB
                                        xl=xl0; % +xyalign(jj-1,1); 
                                        yl=yl0; % +xyalign(jj-1,2); 
                                        dxl=0; %xl0-xl; 
                                        dyl=0; % yl0-yl;
                                        a=(Movi(yl:yl+ht,xl:xl+wd,jj)); %  small box
                                        if smooth a=smoothn(a,[rad;rad],filt,std); end
                                        mx=max(a(:));
                                        xy=find(a==mx); 
                                        [y6,x6]=ind2sub(size(a),xy(1)); 
                                        xyalign(jj,1)=(X0-x6-dxl); %  X0+xl-(Xl+x(1)); 
                                        xyalign(jj,2)=(Y0-y6-dyl); % Y0+yl-(Yl+y(1));
                                        e=bbalign(jj,xyalign,Movi,dmax);
                                        if isa(Movi,'uint8'); Movi(:,:,jj)=uint8(e);
                                        else Movi(:,:,jj)=uint16(e); end
                                        set(himg,'cdata',Movi(:,:,jj)); 
                                        drawnow                
                                    end % RGB or not RGB
                                end % for jj=jmin:jmax    
                            end % if dobrightest
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% End align by brightest pixel
                            
                            if ~dobrightest % AUTO align, least squares fit
                                for jj=jmin+1:jmax                
                                    if getappdata(0,'abort'); set(habort,'visible','off'); setappdata(0,'abort',0); return; end
                                    trackit=getappdata(hfig,'trackit');
                                    hrect1=rectangle('position',[1 1 2 2], 'visible','off');               
                                    if (alignmode==1); % align to previous
                                        if isrgb(Movi) a=double(Movi(yl:yl+ht,xl:xl+wd,:,jj-1));
                                        else a=double(Movi(yl:yl+ht,xl:xl+wd,jj-1)); end %  small box previous frame
                                    end
                                    if trackit;
                                        % XX0=(Xl-wd-4)*(Xl>wd)+(Xu+4)*(Xl<wd); 
                                        % aa=bbblock(XX0,Yl,Movi(:,:,jj),a);                        
                                    end 
                                    mindiff0=1e12; 
                                    for xx=Xl:Xu-wd                             % big box
                                        for yy=Yl:Yu-ht                       
                                            b=double(Movi(yy:yy+ht,xx:xx+wd,jj)); % this small box 
                                            d1=(a-b).*(a-b);
                                            d2=sum(sum(d1));
                                            if (d2<mindiff0)
                                                mindiff0=d2; 
                                                xyalign(jj,1)=xl-xx; 
                                                xyalign(jj,2)=yl-yy; msd=sqrt(d2)/szlittlebox;
                                                if trackit;                                      
                                                    posnow=[xx yy wd ht];
                                                    set(hrect1,'position',posnow,'visible','on')
                                                    set(htxt,'string',[num2str(jj) '/' num2str(jmax)...
                                                            ': dx=' num2str(xyalign(jj,1))...
                                                            ' dy=' num2str(xyalign(jj,2)) char(10)...
                                                            'mean square diff=' num2str(msd) char(10)]);
                                                    drawnow
                                                    trackit=getappdata(hfig,'trackit');    
                                                end
                                            end
                                        end  
                                    end  
                                    set(htxt,'string',[num2str(jj) '/' num2str(jmax)...
                                            ': dx=' num2str(xyalign(jj,1))...
                                            ' dy=' num2str(xyalign(jj,2)) char(10)...
                                            'mean square diff=' num2str(msd) char(10)...
                                            'track=' num2str(trackit)])
                                    %drawnow
                                    e=bbalign(jj,xyalign,Movi,dmax);
                                    ee=uint8(e); if isa(Movi,'uint16') ee=uint16(e); end
                                    Movi(:,:,jj)=ee;
                                    set(himg,'cdata',Movi(:,:,jj)); 
                                    drawnow
                                    delete(hrect1);
                                end % jj current fig
                            end % if ~dobrightest
                        end % auto/man
                        set(hfig,'pointer','arrow')
                        delete(htxt); set(habort,'visible','off')
                        setappdata(hfig,'Movi2',Movi);
                        Movi=Movi2; 
                        set(himg,'cdata',Movi(:,:,jmin))
                        eval([mfilename ' align' ' align' ' align'])
                    case 'aligntrackit'
                        button=get(hfig,'selectiontype');
                        switch button
                            case 'alt' % left button
                                
                            case 'normal'
                                a=getappdata(hfig,'trackit'); a=~a; setappdata(hfig,'trackit',a);
                        end        
                        
                    case 'new'
                        setappdata(hfig,'play',0)
                        answer=questdlg('Erase current window?','Erase?','Yes','No','Cancel','No');
                        %answer='No';
                        if strcmp(answer,'Cancel'); return; end
                        if (strcmp(answer,'Yes')); close(hfig);end;
                        eval(mfilename);                
                        
                    case 'save'        
                        Movi0=Movi;
                        srf=getappdata(hfig,'srf'); if srf; hsrf=findobj(0,'tag','hsrf'); end
                        picdir=getappdata(0,'savedir'); % (himg,'picdir'); 
                        jmin=round(get(hffs,'value')); jmax=round(get(hlfs,'value'));
                        len=length(list); if len==1; jmin=1; jmax=1; end
                        if ~isempty(picdir); cd (picdir); end        
                        
                        mapname=getappdata(hfig,'mapname');
                        [fname,pname]=uiputfile('*.*','Base name for images? (use no periods for AVI format)',100,500);
                        if fname==0; return; end
                        setappdata(hfig,'picdir',pname); setappdata(0,'savedir',pname);
                        fmt=questdlg('Save as what format?','Format for save?','.tif','.jpg','.avi','.tif');
                        % questdlg takes 3 choices max.          
                        
                        if strcmp(mapname,'') & strcmp(fmt,'.tif'); % orig RGB converted to 8 bit
                            mapname=fname; map=colormap;
                            save([homedir 'color\' mapname '.lut'],'map', '-ASCII')             
                        end
                        
                        % labels, rectangles and other objects must be 'dropped' into the image
                        a=[findobj(hax,'type','text'); findobj(hax,'type','rectangle'); findobj(hax,'type','line')];
                        a=[]; % comment out to have labels, etc. dropped
                        if ~isempty(a) | (srf & ~strcmp(fmt,'.avi'))
                            if srf disp ('Capturing surface. Wait...')
                            else disp('Dropping text, lines, rectangles...'); end
                            F=getframe; a=F.cdata; sz=size(a); 
                            if isa(Movi,'uint8') | srf; Movi2 = uint8(0); else Movi2=uint16(0); end                            
                            if isrgb(Movi); 
                                Movi2= Movi2(ones(1,sz(1)-1),ones(1,sz(2)-1),ones(1,3),ones(1,len));
                            else
                                Movi2= Movi2(ones(1,sz(1)-1),ones(1,sz(2)-1),ones(1,len)); 
                            end                            
                            for j=jmin:jmax % 1:length(list);
                                %jj=j-jmin+1;
                                if isrgb(Movi); m=Movi(:,:,:,j); else m=Movi(:,:,j);end
                                if srf; set(hsrf,'cdata',m,'zdata',m); 
                                else set(himg,'cdata',m); drawnow; end 
                                F=getframe; % F is structure array containing RGB image
                                a=F.cdata; % a is RGB image, uint8
                                a=a(1:end-1,1:end-1,:);
                                if isrgb(Movi); 
                                    Movi2(:,:,:,j)=a; 
                                else 
                                    mm=rgb2ind(a,colormap); % uint16!! 
                                    Movi2(:,:,j)=mm(:,:);
                                end
                            end
                            Movi=Movi2; 
                        end            
                        %%%%%%%%%%%%%%%%%%%%%%% 8 bit tif to 24 bit
                        if 1<0
                            if strcmp(fmt,'.tif') & ~isrgb(Movi) & isa(Movi,'uint8')   % 8 bit tif
                                prompt=['These 8 bit images will display properly only with access to the current color lut, ',...
                                        mapname '. To display them without needing ' mapname ' convert to 24 bit (=RGB or TrueColor)'];
                                    title='Leave as 8 bit or convert to 24 bit?';
                                    fmt2=questdlg(prompt,title,'no change','to 24 bit','8 bit');
                                    
                                    if strcmp(fmt2,'to 24 bit'); 
                                        Movi2=Movi; szx=size(Movi,2); szy=size(Movi,1); % len=length(list);
                                        Movi=uint8(0); Movi=Movi(ones(1,szy),ones(1,szx),ones(1,3),ones(1,len)); 
                                        for j=jmin:jmax % 1:len
                                            disp([num2str(j) '/' num2str(jmax)]);
                                            a=ind2rgb(Movi2(:,:,j),colormap); a=a*255;
                                            Movi(:,:,:,j)=a;
                                        end
                                    end
                                end
                            end % if 1<0         
                            %****************************************
                            if (fname ~= 0)
                                if strcmp(fmt,'.avi');
                                    nf=length(list);
                                    prompt={'Frames per second (1-15)?',...
                                            'Pause at start (seconds)?',...
                                            'Pause at end (seconds)?',...
                                            ['Pause 1 sec at (type frame number: 1-' num2str(nf) '; 0=none)'],...
                                            ['Pause 1 sec at (type frame number: 1-' num2str(nf) '; 0=none)'],...
                                            ['Pause 1 sec at (type frame number: 1-' num2str(nf) '; 0=none)'],...
                                            'Compression? (cinepak, indeo3, indeo5, MSVC, none'};
                                    title='AVI variables';
                                    lineno=1; defans={'15','1','1','0','0','0','cinepak'};
                                    answer=inputdlg(prompt,title,lineno,defans);
                                    if isempty(answer); return; end
                                    fps=str2num(answer{1}); padit1=round(str2num(answer{2}));
                                    padit2=round(str2num(answer{3})); padit3=str2num(answer{4}); 
                                    padit4=str2num(answer{5}); padit5=str2num(answer{6}); comp=answer{7};                
                                end            
                                set(habort,'visible','on')
                                figure(hfig); axes(hax); % Because dialog windows reset gcf and gca!!!                
                                jj=0; % jmax-jmin+1; jj=0; % padit1=15; padit2=15;                
                                for j=jmin:jmax
                                    if getappdata(0,'abort'); set(habort,'visible','off'); setappdata(0,'abort',0); return; end
                                    jj=jj+1;
                                    n=['000' num2str(j)]; n1=char(n(end-2:end));
                                    f=[pname fname '.' n1 fmt]; 
                                    htxt=text(20,50,[num2str(j) '/' num2str(jmax)],...
                                        'color','red','fontsize',18); drawnow
                                    disp([num2str(j) '/' num2str(jmax)])
                                    pause (.1)
                                    if strcmp(fmt,'.tif');
                                        if size(size(Movi),2)>3
                                            imwrite(Movi(:,:,:,j),f);%,'description',imgdesc{j});
                                        else
                                            %imwrite(Movi(:,:,j),f,'description',char(mapname));
                                            imwrite(Movi(:,:,j),f);%,'description',imgdesc{j});
                                        end
                                    elseif strcmp(fmt,'.avi')
                                        if srf; set(hsrf,'cdata',Movi(:,:,j),'zdata',Movi(:,:,j));
                                        else
                                            if ~isrgb(Movi);
                                                set(himg,'cdata',Movi(:,:,j));
                                            else
                                                set(himg,'cdata',Movi(:,:,:,j));
                                            end; end
                                        set(htxt,'visible','off')
                                        drawnow
                                        m(jj)=getframe; % 
                                        set(htxt,'visible','on')
                                        rpt=(j==jmin)*(padit1*fps)+(j==jmax)*(padit2*fps)+(j==padit3 | j==padit4 | j==padit5)*fps;
                                        if rpt                       
                                            for jjj=1:rpt
                                                jj=jj+1;
                                                m(jj)=m(jj-1); end
                                        end
                                    else % jpg
                                        if size(size(Movi),2)>3
                                            a=Movi(:,:,:,j);
                                        else
                                            a=ind2rgb(Movi(:,:,j),colormap); 
                                        end
                                        %   a=ind2rgb(aa,colormap); 
                                        imwrite(a,f); 
                                    end
                                    delete(htxt)
                                end    
                                if strcmp(fmt,'.avi');
                                    disp (['saving ' fname '.avi using ' comp ' compression...'])                    
                                    htxt=text(20,50,['saving ' fname '.avi using ' comp ' compression...'],...
                                        'color','red','fontsize',18);
                                    disp(['Saving ' fname '.avi using ' comp ' compression...'])
                                    pause (.1)
                                    try; 
                                        movie2avi(m,[pname fname],'FPS',fps,'compression',comp);  
                                    catch;
                                        errordlg(['AVI Error! ' comp ' compression. Save failed.']);
                                        disp(['AVI ' comp ' compression failed!']); disp('');  
                                    end
                                end
                                clear m
                            end
                            try; delete(htxt); catch; end
                            Movi=Movi0; 
                            set(habort,'visible','off')            
                        case 'kbd'
                            keyboard                     
                            
                        case 'quit'
                            setappdata(hfig,'play',0);
                            close (hfig)
                            
                        case 'miscpopup'
                            hpop=findobj(hfig,'tag','miscpopup');
                            nn=round(get(hpop,'value')); set(hpop,'value',1)        
                            switch nn % 
                                case 1 % misc    
                                case 2 % cut-fill            
                                    setappdata(hfig,'play',0)
                                    a=round(getrect); % returns x,y,wd,ht
                                    a(3)=a(1)+a(3); a(4)=a(2)+a(4);
                                    lastrect=getappdata(0,'lastrect');
                                    prompt={'Fill color value?',...
                                            'Fill inside(0) or outside (1) selectedregion?',...
                                            'Fill this image only (0) or all images (1)',...
                                            ['X Left? Type 0 to use last rectangle: (' num2str(lastrect) '}'],...
                                            'Y Top' 'X Right' 'Y Bottom'};
                                    defans={'0' '0' '1',...
                                            num2str(a(1)) num2str(a(2)) num2str(a(3)) num2str(a(4))};
                                    aa=inputdlg(prompt,'Cut : Fill',1,defans); 
                                    if isempty(aa); return; end
                                    if strcmp(aa{4},'0'); a=lastrect;
                                    else
                                        a(1)=max(1,str2num(aa{4})); a(2)=max(1,str2num(aa{5}));
                                        a(3)=min(size(Movi,2),str2num(aa{6})); a(4)=min(size(Movi,1),str2num(aa{7}));
                                    end                
                                    setappdata(0,'lastrect',a)
                                    
                                    fillit=round(str2num(aa{1})); fillout=str2num(aa{2}); dest=str2num(aa{3});                
                                    if dest==1; % all frames
                                        if ~isrgb(Movi)
                                            if fillout % fill outside
                                                for jj=1:size(Movi,3)
                                                    bb=Movi(a(2):a(4),a(1):a(3),jj);
                                                    Movi(:,:,jj)=0; 
                                                    Movi(:,:,jj)=bbblock(a(1),a(2),Movi(:,:,jj),bb);
                                                end
                                            else    
                                                Movi(a(2):a(4),a(1):a(3),:)=fillit;
                                            end
                                        else
                                            Movi(a(2):a(4),a(1):a(3),:,:)=fillit;    
                                        end
                                    else       
                                        framenum=round(get(hfs,'value')); 
                                        if ~isrgb(Movi)
                                            Movi(a(2):a(4),a(1):a(3),framenum)=fillit;
                                        else
                                            Movi(a(2):a(4),a(1):a(3),:,framenum)=fillit;
                                        end    
                                    end
                                    setappdata(hfig,'Movi',Movi)
                                    setappdata(hfig,'play',1)
                                    eval([mfilename ' replay'])
                                case 3 % cut-move
                                    setappdata(hfig,'play',0)                        
                                    setappdata(hfig,'square',0)
                                    set(hfig,'userdata','hello'); % set(hfig,'interruptible','on');
                                    bbgetrect % draw rectangle, move it and click to close
                                    waitfor(hfig,'userdata')
                                    a=getappdata(hfig,'pos0'); % initial x and y only
                                    b=getappdata(hfig,'pos');  % final position
                                    a(3)=a(1)+b(3); a(4)=a(2)+b(4); % b(3)=b(1)+b(3); b(4)=b(2)+b(4);
                                    lastrect=getappdata(0,'lastrect');
                                    prompt={'Fill color value?',...                
                                            'Apply to this image only (0) or all images (1)',...
                                            ['X Left? Type 0 to use last source rectangle: (',...
                                                num2str(lastrect) '}']  'Y Top' 'X Right' 'Y Bottom'};
                                    defans={'0' '1',...
                                            num2str(a(1)) num2str(a(2)) num2str(a(3)) num2str(a(4))};
                                    aa=inputdlg(prompt,'Cut : Fill',1,defans); 
                                    if isempty(aa); return; end
                                    if strcmp(aa{3},'0'); a=lastrect;
                                    else
                                        a(1)=max(1,str2num(aa{3})); a(2)=max(1,str2num(aa{4}));
                                        a(3)=min(size(Movi,2),str2num(aa{5})); a(4)=min(size(Movi,1),str2num(aa{6}));
                                    end 
                                    b(3)=b(1)+(a(3)-a(1)); b(4)=b(2)+(a(4)-a(2));
                                    setappdata(0,'lastrect',a)              
                                    fillit=str2num(aa{1}); dest=str2num(aa{2});
                                    if dest==1;
                                        if ~isrgb(Movi)
                                            for j=1:size(Movi,3)
                                                cut=Movi(a(2):a(4),a(1):a(3),j); % cut is uint8                      
                                                Movi(a(2):a(4),a(1):a(3),j)=fillit;
                                                Movi(b(2):b(4),b(1):b(3),j)=cut;                               
                                            end    
                                        else
                                            cut=Movi(a(2):a(4),a(1):a(3),:,:);
                                            Movi(a(2):a(4),a(1):a(3),:,:)=fillit;
                                            Movi(b(2):b(4),b(1):b(3),:,:)=cut;
                                        end
                                    else
                                        framenum=round(get(hfs,'value'));
                                        if ~isrgb(Movi)
                                            cut=Movi(a(2):a(4),a(1):a(3),framenum);
                                            Movi(a(2):b(4),a(1):a(3),framenum)=fillit;
                                            Movi(b(2):b(4),b(1):b(3),framenum)=cut;
                                        else
                                            cut=Movi(a(2):a(4),a(1):a(3),:,framenum);
                                            Movi(a(2):a(4),a(1):a(3),:,framenum)=fillit;
                                            Movi(b(2):b(4),b(1):b(3),:,framenum)=cutf;
                                        end
                                        
                                    end
                                    setappdata(hfig,'Movi',Movi)
                                    setappdata(hfig,'play',1)
                                    eval([mfilename ' replay'])
                                case 4 % copy
                                    setappdata(hfig,'square',0)
                                    set(hfig,'userdata','hello'); % set(hfig,'interruptible','on');
                                    bbgetrect 
                                    waitfor(hfig,'userdata')
                                    a=getappdata(hfig,'pos0'); % x and y only
                                    b=getappdata(hfig,'pos');
                                    curfig=gcf; allfig=findobj(0,'type','figure')';
                                    prompt2=['Destination figure? (' num2str(allfig) ')'];
                                    
                                    a(3)=a(1)+b(3); a(4)=a(2)+b(4);
                                    lastrect=getappdata(0,'lastrect');
                                    prompt={'Apply to this image only (0) or all images (1)',...
                                            prompt2,...
                                            ['X Left? Type 0 to use last source rectangle: (' num2str(lastrect) '}']  'Y Top' 'X Right' 'Y Bottom'};
                                    defans={'1', num2str(curfig),...
                                            num2str(a(1)) num2str(a(2)) num2str(a(3)) num2str(a(4))};
                                    aa=inputdlg(prompt,'Copy',1,defans); 
                                    if isempty(aa); return; end
                                    if strcmp(aa{3},'0'); a=lastrect;
                                    else
                                        a(1)=max(1,str2num(aa{3})); a(2)=max(1,str2num(aa{4}));
                                        a(3)=min(size(Movi,2),str2num(aa{5})); a(4)=min(size(Movi,1),str2num(aa{6}));
                                    end                
                                    setappdata(0,'lastrect',a)              
                                    b(3)=b(1)+a(3)-a(1); b(4)=b(2)+a(4)-a(2);
                                    dest=str2num(aa{1}); destfig=str2num(aa{2}); destMovi=Movi;
                                    if destfig ~= curfig; 
                                        destMovi=getappdata(destfig,'Movi'); 
                                    end
                                    n1=size(Movi,size(size(Movi),2)); n2=size(destMovi,size(size(destMovi),2));
                                    nmin=min(n1,n2);
                                    if dest==1; % all frames
                                        if ~isrgb(Movi)
                                            if destfig ~= curfig % copy roi from each image in movie to each image in destfig                        
                                                destMovi(b(2):b(4),b(1):b(3),1:nmin)=Movi(a(2):a(4),a(1):a(3),1:nmin);
                                            else % copy from current frame to all others in movie
                                                framenum=round(get(hfs,'value')); M=Movi(a(2):a(4),a(1):a(3),framenum);
                                                for j=1:size(Movi,3); destMovi(b(2):b(4),b(1):b(3),j)=M; end
                                            end
                                        else
                                            destMovi(b(2):b(4),b(1):b(3),:,1:nmin)=Movi(a(2):a(4),a(1):a(3),:,1:nmin);
                                        end                
                                    else
                                        framenum=round(get(hfs,'value'));
                                        if ~isrgb(Movi)
                                            destMovi(b(2):b(4),b(1):b(3),framenum)=Movi(a(2):a(4),a(1):a(3),framenum);
                                        else
                                            destMovi(b(2):b(4),b(1):b(3),:,framenum)=Movi(a(2):a(4),a(1):a(3),:,framenum);
                                        end
                                        
                                    end
                                    setappdata(destfig,'Movi',destMovi)              
                                case 5 % 'clock'   %%%%%%%%% CLOCK
                                    % return
                                    ans=questdlg('circle or rectangle?','Clock shape?','circle','rectangle','circle')
                                    shape=0; if strcmp(ans,'rectangle'); shape=1; end
                                    setappdata(hfig,'play',0);         
                                    hfss=findobj(hfig,'tag','figsizeslider');
                                    set(hfss,'value',1)
                                    eval([mfilename ' figsize'])
                                    hdlg=msgbox('Select region to contain clock','Getregion');
                                    uiwait(hdlg); len=length(list);
                                    v1=get(hffs,'value'); v2=get(hlfs,'value'); vtot=v2-v1+1;
                                    if ~shape; % circle     
                                        setappdata(hfig,'square',1)
                                        set(hfig,'userdata','hello'); % set(hfig,'interruptible','on');
                                        bbgetrect 
                                        waitfor(hfig,'userdata')
                                        setappdata(hfig,'square',1)
                                        sq=round(getappdata(hfig,'pos')); sq0=sq;
                                        x=sq(1)+sq(3)/2; y=sq(2)+sq(4)/2; rad=sq(3)/2; 
                                        prompt={'Time beetween frames?', 'Time of one revolution?', 'Color?'};
                                        title='Clock'; lineno=1; def={'1', '60', '1 1 1'};
                                        vals=inputdlg(prompt,title,lineno,def); if isempty(vals); return; end
                                        step=str2num(vals{1}); rev=str2num(vals{2}); color=str2num(vals{3});
                                        pos=[x-rad y-rad rad*2 rad*2]; twohands=len*step>rev;
                                    else % rectangle                       
                                        setappdata(hfig,'square',0)
                                        set(hfig,'userdata','hello'); % set(hfig,'interruptible','on');
                                        bbgetrect 
                                        waitfor(hfig,'userdata')
                                        sq=getappdata(hfig,'pos'); 
                                        prompt={'Time between frames?' 'Units? (sec, min, etc.)'}
                                        title='Clock'; lineno=1; def={'1' 'sec'};
                                        vals=inputdlg(prompt,title,lineno,def); if isempty(vals); return; end
                                        step=str2num(vals{1}); tt=vals{2};
                                        htxt=text('position',[sq(1)+sq(3), sq(2)+sq(4)],...
                                            'color','white','string',[num2str(vtot*step) ' ' tt],...
                                            'horizontalalignment','right','verticalalignment','top');
                                        sq0=sq;                                    
                                    end
                                    setappdata(0,'abort',0); set(habort,'visible','on')                    
                                    if isrgb(Movi) 
                                        Movi2=uint8(0); Movi2=Movi2(ones(1,sq(4)),ones(1,sq(2)),ones(1,3),ones(1,len)); 
                                    else
                                        Movi2=uint8(0); if isa(Movi,'uint16'); Movi2=uint16(0); end; Movi2=Movi2(ones(1,sq(4)),ones(1,sq(2)),ones(1,len)); 
                                    end 
                                    Movi2=Movi;
                                    for j=1:len
                                        if getappdata(0,'abort'); set(habort,'visible','off'); setappdata(0,'abort',0); return; end
                                        if ~shape
                                            tt=(j-1)*step; theta=2*pi*tt/rev-pi/2;
                                            ttot=j*step/(12*rev); theta3=2*pi*ttot-pi/2;
                                            x2=x+0.9*rad*cos(theta); y2=y+0.9*rad*sin(theta);
                                            x3=x+0.5*rad*cos(theta3); y3=y+0.5*rad*sin(theta3);
                                        else
                                            sq(3)=sq0(3)*j/len;
                                        end
                                        if isrgb(Movi)
                                            set(himg,'cdata',Movi(:,:,:,j));
                                        else
                                            set(himg,'cdata',Movi(:,:,j));
                                        end                                        
                                        drawnow    
                                        if ~shape % circle
                                            hclock(1)=rectangle('position',pos,'curvature',[1 1],'edgecolor',color);            
                                            hclock(2)=line([x;x2],[y;y2],'color',color);
                                            if twohands; hclock(3)=line([x;x3],[y;y3],'color',color); end
                                        else
                                            hclock(1)=rectangle('position',sq0,'edgecolor','red');
                                            hclock(2)=rectangle('position',sq,'facecolor','white'); drawnow
                                        end
                                        F=getframe(hax); % drop into image
                                        a=F.cdata; 
                                        if isrgb(Movi); Movi2(:,:,:,j)=a(1:end-1,1:end-1,:); % bbblock(sq(1),sq(2),Movi2(:,:,:,j),a);
                                        else
                                            a=rgb2ind(a,colormap); 
                                            Movi2(:,:,j)=a(1:end-1,1:end-1); % bbblock(sq(2),sq(1),Movi2(:,:,j),a);
                                        end
                                        delete(hclock);
                                    end    
                                    set(habort,'visible','off')
                                    setappdata(hfig,'Movi2',Movi2);
                                    srf=getappdata(hfig,'srf'); setappdata(0,'makesurf',srf);                
                                    eval ([mfilename ' clock' ' clock' ' clock']) % to make nargin=3                
                                case 6 % cdatamapping
                                    mp=get(himg,'cdatamapping'); newmp='direct';
                                    if mp=='direct'; newmp='scaled'; end
                                    set(himg,'cdatamapping',newmp)
                                    disp(['cdatamapping now ' newmp])
                                case 7 % climmode
                                    clmode=get(himg,'climmode'); newmode='auto';
                                    if clmode=='auto'; newmode='manual'; end
                                    set(himg,'climmode',newmode)
                                    disp(['climmode now ' newmode])
                                case 8 % clone                  
                                    setappdata(hfig,'Movi2',Movi);
                                    srf=getappdata(hfig,'srf'); setappdata(0,'makesurf',srf);
                                    str=[' clone:' list{1} '++']; 
                                    eval([mfilename str str str])
                                    %eval ([mfilename ' clone' ' clone' ' clone']) % to make nargin=3
                                case 9 % revorder
                                    setappdata(hfig,'play',0);
                                    nmax=length(list); 
                                    list2=list; 
                                    for j=1:floor(nmax/2);
                                        jj=nmax-j+1; list(jj)=list(j); list(j)=list2(jj);
                                        if ~isrgb(Movi)
                                            a=Movi(:,:,j); Movi(:,:,j)=Movi(:,:,jj);Movi(:,:,jj)=a;
                                        else
                                            a=Movi(:,:,:,j); Movi(:,:,:,j)=Movi(:,:,:,jj);Movi(:,:,:,jj)=a;
                                        end
                                    end
                                    setappdata(hfig,'list',list)         
                                    setappdata(hfig,'Movi',Movi)         
                                    n1=round(get(hffs,'value')); n2=round(get(hlfs,'value'));   
                                    n2new=nmax-n1+1; n1new=nmax-n2+1;
                                    set(hffs,'value',n1new); set(hlfs,'value',n2new);      
                                    hffst=findobj(hfig,'tag','firstframeslidertxt');
                                    set (hffst,'string',['First ' num2str(n1new)]);     
                                    hlfst=findobj(hfig,'tag','lastframeslidertxt');
                                    set (hlfst,'string',['Last ' num2str(n2new)]);   
                                    setappdata(hfig,'play',1)
                                case 10 % VertFlip
                                    for j=1:length(list); Movi(:,:,j)=Movi(end:-1:1,:,j);end
                                    setappdata(hfig,'Movi',Movi)
                                    eval([mfilename ' replay'])
                                case 11 % KBD
                                    keyboard
                                    
                                case 12 % 3x8bit to RGB
                                    srf=getappdata(hfig,'srf'); if srf; return; end
                                    hfig=gcf;
                                    setappdata(hfig,'play',0)
                                    allfig=findobj(0,'type','figure')';
                                    if size(allfig,2)<3; return; end
                                    rprompt=['Source figure for RED? (' num2str(allfig) ')'];
                                    gprompt=['Source figure for GREEN? (' num2str(allfig) ')'];
                                    bprompt=['Source figure for BLUE? (' num2str(allfig) ')'];
                                    prompt={rprompt gprompt bprompt};
                                    defans={num2str(allfig(3)) num2str(allfig(2)) num2str(allfig(1))};
                                    aa=inputdlg(prompt,'RGB sources?',1,defans); 
                                    if isempty(aa); return; end
                                    src(1)=str2num(aa{1}); src(2)=str2num(aa{2}); src(3)=str2num(aa{3});                
                                    %Check sizes, get lohi, first & last
                                    for k=1:3                    
                                        Movi=getappdata(src(k),'Movi'); rgbsz(k,:)=size(Movi);
                                        hlo=findobj(src(k),'tag','lo'); hhi=findobj(src(k),'tag','hi');   
                                        hilo(k,1)=round(get(hlo,'value')); hilo(k,2)=round(get(hhi,'value'));
                                        hfirst=findobj(src(k),'tag','firstframeslider');
                                        hlast=findobj(src(k),'tag','lastframeslider');
                                        fila(k,1)=get(hfirst,'value'); fila(k,2)=get(hlast,'value');
                                    end 
                                    rows=max(rgbsz(:,1));
                                    cols=max(rgbsz(:,2));                
                                    len=max(rgbsz(:,3));
                                    
                                    fi=max(fila(:,1)); la=min(fila(:,2));
                                    if (fi~=1 | la~=len)
                                        prompt={['First frame? Type 0 for all frames (1-' num2str(len) ')'],...
                                                'Last frame?'};
                                        title='First and last frames?'; lineno=1;
                                        def={num2str(fi) num2str(la)};
                                        ans=inputdlg(prompt,title,lineno,def);
                                        if isempty(ans); return; end
                                        if strcmp(ans{1},'0');
                                            fi=1; la=len;
                                        else
                                            fi=str2num(ans{1}); la=str2num(ans{2});
                                            len=la-fi+1;
                                        end
                                        list2=list(fi:la); setappdata(hfig,'list2',list2);
                                    end                  
                                    M=uint8(0); % if isa(Movi,'uint16'); M=uint16(0); end
                                    M= M(ones(1,rows),ones(1,cols),ones(1,3),ones(1,len));      
                                    togo=3*len;               
                                    for k=1:3
                                        fac=255/(hilo(k,2)-hilo(k,1));
                                        Movi=getappdata(src(k),'Movi');
                                        jjj=0;                  
                                        for jj=fi:la;                 
                                            jjj=jjj+1;
                                            disp([num2str(jj) '/' num2str(la)]);
                                            v=max(0,double(Movi(:,:,jj))-hilo(k,1)); % subtract lo
                                            f=min(255,v*fac);  
                                            %M(:,:,jj)=round(f);
                                            M(1:rgbsz(k,1),1:rgbsz(k,2),k,jjj)=round(f); % Movi;
                                        end; end                
                                    % if isa(a,'uint16'); fac=65535/double(max(a(:)); a=uint16(double(a)*fac); end
                                    setappdata(hfig,'Movi2',M);                   
                                    eval([mfilename ' 3x8bit->RGB' ' 3x8bit->RGB' ' 3x8bit->RGB']);
                                case 13 % montage
                                    srf=getappdata(hfig,'srf'); if srf; msgbox('Cannot montage surfaces'); return; end
                                    allfig=findobj(0,'type','figure')'; 
                                    scrnsz=get(0,'screensize'); maxwd=scrnsz(1,3);
                                    prompt={['Figure numbers? (choose from ' num2str(allfig) ' )'],...
                                            'Maximum width? (pixels)'};
                                    title='Montage - paste figures into one figure'; lineno=1;
                                    def={'' num2str(maxwd)};
                                    ans=inputdlg(prompt,title,lineno,def);
                                    if isempty(ans); return; end
                                    mm=str2num(ans{1})'; nfigs=size(mm,1); if nfigs<2; return; end
                                    maxwd=str2num(ans{2});                
                                    xtot=0; xnow=0; ytot=0; name='montage ';
                                    bits=[0 0 0];
                                    setappdata(0,'abort',0); set(habort,'visible','on');drawnow
                                    % mm array: c1=fig; c2=x size; c3=y size; c4=len; c5,6=x,y values in montage
                                    for jj=1:size(mm,1) % get sizes of image stacks
                                        himg=findobj(get(mm(jj,1),'children'),'type','image');                  
                                        name=[name ' ' num2str(mm(jj,1))];
                                        a=getappdata(mm(jj,1),'Movi');
                                        if isrgb(a); nn=3;
                                        elseif isa(a,'uint8'); nn=1; elseif isa(a,'uint16'); nn=2; end
                                        bits(1,nn)=bits(1,nn)+1;
                                        mm(jj,2)=size(a,2); % X get(himg,'cdata'),1);
                                        mm(jj,3)=size(a,1); % Y get(himg,'cdata'),2);
                                        if jj==1; ynow=mm(1,3); end
                                        list=getappdata(mm(jj),'list'); mm(jj,4)=length(list);
                                    end
                                    maxwd=max(maxwd,max(mm(:,2))); % max width must be >= widest image
                                    xnow=1; ynow=1; mxy=0; xtot=0; mxx=0;
                                    for jj=1:size(mm,1) % figure positions of each image stack
                                        if xnow+mm(jj,3)>maxwd % start new row
                                            ynow=ynow+mxy; mm(jj,6)=ynow; mm(jj,5)=1; 
                                            xnow=mm(jj,2); mxy=mm(jj,3); mxx=mm(jj,2); 
                                        else
                                            mxy=max(mxy,mm(jj,3)); mxx=mxx+mm(jj,2);
                                            mm(jj,5)=xnow; mm(jj,6)=ynow; xnow=xnow+mm(jj,2); xtot=max(xtot,mxx);
                                        end
                                    end                   
                                    ytot=ynow+mxy; len=max(mm(:,4));
                                    Movi2=uint8(0); if isa(Movi,'uint16') Movi2=uint16(0); end
                                    Movi2=Movi2(ones(1,ytot+1),ones(1,xtot+1),ones(1,len));
                                    if isrgb(Movi); Movi2=Movi2(ones(1,ytot+1),ones(1,xtot+1),ones(1,3),ones(1,len)); end
                                    xnow=1; ynow=1; lasty=0;
                                    for jj=1:size(mm,1)
                                        if getappdata(0,'abort'); set(habort,'visible','off'); setappdata(0,'abort',0); return; end
                                        disp(num2str(size(mm,1)-jj))
                                        little=getappdata(mm(jj,1),'Movi');                     
                                        sz=size(little); szx=sz(1,2); szy=sz(1,1);
                                        xnow=mm(jj,5); ynow=mm(jj,6);
                                        for k=1:mm(jj,4) % len
                                            disp([num2str(jj) '/' num2str(size(mm,1)) ' : ' num2str(k) '/' num2str(mm(jj,4))])
                                            if isrgb(little)
                                                Movi2(:,:,:,k)=bbblock(xnow,ynow,Movi2(:,:,:,k),little(:,:,:,k));
                                            else
                                                Movi2(:,:,k)=bbblock(xnow,ynow,Movi2(:,:,k),little(:,:,k));                          
                                            end
                                            list2{k}=name;    
                                        end
                                    end
                                    set(habort,'visible','off')
                                    if getappdata(0,'abort'); set(habort,'visible','off'); setappdata(0,'abort',0); return; end
                                    setappdata(hfig,'Movi2',Movi2); setappdata(hfig,'list2',list2)
                                    eval([mfilename ' montage' ' montage' ' montage'])
                                    
                                case 14 % set all first & last frame sliders
                                    hlo=findobj(hfig,'tag','lo'); hhi=findobj(hfig,'tag','hi');
                                    htext=findobj(hfig,'tag','lohi');   
                                    lo=round(get(hlo,'value')); hi=round(get(hhi,'value'));
                                    
                                    v1=get(hffs,'value'); v2=get(hlfs,'value');
                                    allfig=findobj(0,'type','figure'); 
                                    for jj=1:size(allfig,1)
                                        hfig=allfig(jj,1); hax=findobj(hfig,'type','axes');
                                        hffs=findobj(hfig,'tag','firstframeslider'); 
                                        set(hffs,'value',v1,'tooltipstring',['FirstFrame ' num2str(v1)]);
                                        hlfs=findobj(hfig,'tag','lastframeslider');
                                        set(hlfs,'value',v2,'tooltipstring',['LastFrame ' num2str(v2)]);
                                        hffst=findobj(hfig,'tag','firstframeslidertxt');
                                        set(hffst,'string',['First ' num2str(v1)]);
                                        hlfst=findobj(hfig,'tag','lastframeslidertxt');
                                        set(hlfst,'string',['Last ' num2str(v2)]);
                                        
                                        hlo=findobj(hfig,'tag','lo'); hhi=findobj(hfig,'tag','hi');
                                        htext=findobj(hfig,'tag','lohi'); 
                                        mn=min(lo,get(hlo,'min')); mx=max(hi,get(hlo,'max'));
                                        set(hlo,'value',lo,'min',mn,'max',mx)
                                        set(hhi,'value',hi,'min',mn,'max',mx)                    
                                        set(htext,'string',[num2str(lo) ' : ' num2str(hi)])
                                        set(hax,'clim',[lo hi])
                                    end
                                    
                                case 15 % surface edge color   
                                    sec=getappdata(0,'surfedgecolor');
                                    prompt={'Surface edge color? (Type a color or "none", "flat", or "interp")'};
                                    title=['Surface edge color - now ' sec]; lineno=1; def={sec};
                                    ans=inputdlg(prompt,title,lineno,def);
                                    sec=ans{1};
                                    hsrf=findobj(0,'type','surface'); if ~isempty(hsrf); set(hsrf,'edgecolor',sec); end
                                    setappdata(0,'surfedgecolor',sec);                
                                    
                                case 16 % drop labels
                                    %   if isrgb(Movi); return; end
                                    hfss=findobj(hfig,'tag','figsizeslider');
                                    set(hfss,'value',1)
                                    eval([mfilename ' figsize'])
                                    len=length(list); frame=get(hfs,'value');
                                    str=['image to drop into? (1-' num2str(len) ')'];
                                    prompt={['First ' str] ['Last ' str]};
                                    title='Drop labels'; lineno=1; def={num2str(frame) num2str(frame)}; 
                                    inp=inputdlg(prompt,title,lineno,def);
                                    if isempty(inp); return; end
                                    fi=str2num(inp{1}); la=str2num(inp{2});
                                    if fi>la | fi<1 | la>len; return; end
                                    set(habort,'visible','on') % setup
                                    for j=fi:la
                                        if getappdata(0,'abort'); set(habort,'visible','off'); setappdata(0,'abort',0); return; end
                                        disp (['Drop labels into frame #' num2str(j)])
                                        aa=Movi(:,:,j); 
                                        if isrgb(Movi); 
                                            aa=Movi(:,:,:,j); 
                                        end
                                        set(himg,'cdata',aa)
                                        F=getframe(hax); %,sq); 
                                        a=F.cdata; 
                                        if isrgb(Movi); Movi(:,:,:,j)=a(1:end-1,1:end-1,:);                     
                                        else
                                            a=rgb2ind(a,colormap); 
                                            Movi(:,:,j)=a(1:end-1,1:end-1);
                                        end                   
                                    end
                                    set(habort,'visible','off') % cleanup
                                    setappdata(hfig,'Movi',Movi)
                                    set(himg,'cdata',Movi(:,:,frame))
                                    eval([mfilename ' erase'])
                                    
                                case 17 % 3dmovie
                                    if ~srf; hmsg=msgbox('Must be a 3d image'); uiwait(hmsg); return; end
                                    setappdata(hfig,'play',0)
                                    hfss=findobj(hfig,'tag','figsizeslider');
                                    set(hfss,'value',1); eval([mfilename ' figsize']) % sets figsize to 1.0            
                                    hsrf=findobj(hax,'tag','hsrf');
                                    last3dmovie=getappdata(0,'last3dmovie');
                                    prompt={'Advance movie? (y/n)' 'Number of frames?' 'Azimuth start?' 'Azimuth end?',...
                                            'Elevation start?' 'Elevation end?'}; 
                                    title='3d movie'; lineno=1;
                                    def=last3dmovie; % {'y' '30' '0' '180' '38' '145'};   
                                    % if length(list)>1; def{1}=num2str(length(list));end
                                    str=inputdlg(prompt,'Label',1,def); % str=cell array
                                    if isempty(str); return; end
                                    setappdata(0,'abort',0); set(habort,'visible','on') % setup
                                    advance=strcmp(str{1},'y'); nsteps=str2num(str{2}); 
                                    az0=str2num(str{3}); azend=str2num(str{4});
                                    el0=str2num(str{5}); elend=str2num(str{6});
                                    fi=get(findobj(hfig,'tag','firstframeslider'),'value');
                                    la=get(findobj(hfig,'tag','lastframeslider'),'value');
                                    try;
                                        daz=(azend-az0)/(nsteps-1); del=(elend-el0)/(nsteps-1);            
                                        Movi2=uint8(0); sx=2*size(Movi,1); sy=2*size(Movi,2);
                                        Movi2=Movi2(ones(1,sx),ones(1,sy),ones(1,3),ones(1,nsteps));                    
                                        Mframe=fi;
                                        minix=1e9; miniy=1e9;
                                        for nn=1:nsteps
                                            Mframe=Mframe+1; if Mframe>la; Mframe=fi; end
                                            if getappdata(0,'abort'); set(habort,'visible','off'); setappdata(0,'abort',0); return; end
                                            disp ([num2str(nn) '/' num2str(nsteps)])
                                            if advance; set(hsrf,'zdata',Movi(:,:,Mframe),'cdata',Movi(:,:,Mframe)); end
                                            az=az0+daz*(nn-1); % azimuth
                                            el=el0+del*(nn-1); el=el-(round(el)==180); % elevation
                                            view(az,el); drawnow               
                                            F=getframe; % F is structure array containing RGB image
                                            mm=F.cdata; % mm is RGB image, uint8 - with 'axis vis3d' these are diff. sizes              
                                            minix=min(size(mm,1),minix); miniy=min(size(mm,2),miniy);
                                            % The image captured by 'getframe' changes size with different rotations.
                                            % This is because 'axis vis3d' holds the aspect ratio constant.
                                            % Thus, each new frame must be centered in Movi2 (ssx,sx,dx,xmin, etc).
                                            ssx=min(sx,size(mm,1)); ssy=min(sy,size(mm,2));
                                            dx=max(0,round((sx-ssx)/2)); dy=max(0,round((sy-ssy)/2));
                                            xmin=max(1,dx); xmax=ssx+dx-(dx>0); ymin=max(1,dy); ymax=ssy+dy-(dy>0);
                                            Movi2(xmin:xmax,ymin:ymax,:,nn)=mm(1:ssx,1:ssy,:);
                                            list2{nn}=['3d.' num2str(az) '.' num2str(el)];    
                                        end
                                        xmin=round((sx-minix)/2); xmax=xmin+minix-2;
                                        ymin=round((sy-miniy)/2); ymax=ymin+miniy-1;          
                                        Movi2=Movi2(xmin:min(xmax,sx),ymin:min(ymax,sy),:,:);
                                        setappdata(hfig,'Movi2',Movi2); setappdata(hfig,'list2',list2);
                                        setappdata(0,'last3dmovie',str)
                                        set(habort,'visible','off') % cleanup
                                        eval([mfilename ' 3dmovie' ' 3dmovie' ' 3dmovie'])           
                                    catch; set(habort,'visible','off'); hmsg=msgbox('ERROR! Try again'); uiwait(hmsg);end
                                    
                                case 18 % concatenate 2 or more movies
                                    %srf=getappdata(hfig,'srf'); if srf; return; end
                                    hfig0=gcf;
                                    allfig=findobj(0,'type','figure')'; 
                                    prompt={['Figure numbers? (choose from ' num2str(allfig) ' )']};
                                    title='Concatenate - combine movies serially'; lineno=1;
                                    def={''};
                                    ans=inputdlg(prompt,title,lineno,def);
                                    if isempty(ans); return; end
                                    mm=str2num(ans{1})'; nfigs=size(mm,1); if nfigs<2; return; end
                                    set(habort,'visible','on');drawnow
                                    bitdepth0=8+8*isa(Movi,'uint16'); rgb0=isrgb(Movi); % caller determines format
                                    xmax=0; ymax=0; lenmax=0; name=''; 
                                    for jj=1:size(mm,1) % get max size
                                        if getappdata(0,'abort'); 
                                            set(habort,'visible','off'); setappdata(0,'abort',0); return; end
                                        hfig=mm(jj,1); figure(hfig); len=length(getappdata(hfig,'list'));
                                        Movi=getappdata(hfig,'Movi');
                                        bitdepth=8+8*isa(Movi,'uint16'); rgb=isrgb(Movi); 
                                        if bitdepth~=bitdepth0 | rgb~=rgb0; 
                                            hmsg=msgbox('Bitdepth and rgb status must match! Try again'); uiwait(hmsg); 
                                            return; end
                                        name=[name ' ' num2str(mm(jj,1))];                                
                                        y=size(Movi,1); 
                                        x=size(Movi,2);
                                        xmax=max(xmax,x); ymax=max(ymax,y);
                                        lenmax=lenmax+len;
                                    end
                                    Movi2=uint8(0); if bitdepth0==16; Movi2=uint16(0); end        
                                    if rgb0; 
                                        Movi2=Movi2(ones(1,ymax),ones(1,xmax),ones(1,3),ones(1,lenmax));
                                    else
                                        Movi2=Movi2(ones(1,ymax),ones(1,xmax),ones(1,lenmax));
                                    end
                                    nn=0;
                                    for jj=1:size(mm,1)
                                        if getappdata(0,'abort'); 
                                            set(habort,'visible','off'); setappdata(0,'abort',0); return; 
                                        end
                                        disp([num2str(jj) '/' num2str(size(mm,1))])
                                        hfig=mm(jj,1); figure(hfig); 
                                        Movi=getappdata(hfig,'Movi'); list=getappdata(hfig,'list');
                                        len=length(list); y=size(Movi,1); x=size(Movi,2);
                                        for kk=1:len
                                            nn=nn+1; 
                                            if rgb0; Movi2(1:y,1:x,:,nn)=Movi(:,:,:,kk);
                                            else Movi2(1:y,1:x,nn)=Movi(:,:,kk); end
                                            newlist{nn}=list{kk};
                                        end
                                    end
                                    figure(hfig0)
                                    set(habort,'visible','off')
                                    setappdata(hfig0,'Movi2',Movi2); setappdata(hfig0,'list2',newlist)
                                    eval([mfilename ' concatenate' ' concatenate' ' concatenate'])            
                                    
                                case 19 % x-y plot of 2 movies
                                    hfig0=gcf; setappdata(0,'abort',0)
                                    allfig=findobj(0,'type','figure')'; 
                                    prompt={['Type 2 Figure numbers? (choose from ' num2str(allfig) ' )']};
                                    title='Plot brightnesses of pixels from 2 images (x vs y)'; lineno=1; def={''};
                                    ans=inputdlg(prompt,title,lineno,def);
                                    if isempty(ans); return; end
                                    mm=str2num(ans{1})'; nfigs=size(mm,1); if nfigs ~=2; return; end
                                    try; MoviX=getappdata(mm(1,1),'Movi'); MoviY=getappdata(mm(2,1),'Movi'); catch; return; end
                                    if (sum( size(MoviX(:))~=size(MoviY(:)) )); msgbox('Movies must be same size'); return; end            
                                    setappdata(0,'abort',0); set(habort,'visible','on');drawnow                              
                                    ymax=max(size(MoviX,1), size(MoviY,1)); xmax=max(size(MoviX,2), size(MoviY,2));
                                    hffs=findobj(hfig0,'tag','firstframeslider'); hlfs=findobj(hfig0,'tag','lastframeslider');
                                    jmin=round(get(hffs,'value')); jmax=round(get(hlfs,'value'));            
                                    xx=zeros(xmax*ymax,1); yy=xx;            
                                    
                                    hfig=findobj(0,'tag','plotxyfig'); 
                                    if isempty(hfig); hfig=figure('tag','plotxyfig','doublebuffer','on'); 
                                    else hxy=findobj(hfig,'tag','plotxyslider'); delete(hxy);
                                    end
                                    figure(hfig)
                                    xmin=double(min(MoviX(:))); xmax=double(max(MoviX(:))); 
                                    ymin=double(min(MoviY(:))); ymax=double(max(MoviY(:)));
                                    hax=axes('xlim',[xmin xmax],'ylim',[ymin ymax]);
                                    hline=line; 
                                    htxt=text('tag','plotxytxt','position',[xmin+10 ymax-30],...
                                        'string','wait...','fontsize',32,'color','red');
                                    drawnow
                                    jtot=jmax-jmin+1;
                                    for jj=jmin:jmax
                                        if getappdata(0,'abort'); set(habort,'visible','off'); setappdata(0,'abort',0); return; end
                                        nn=jj-jmin+1;   
                                        nnn=[num2str(nn) '/' num2str(jtot)];                                             
                                        xx(:)=MoviX(:,:,nn); yy(:)=MoviY(:,:,nn);              
                                        set(hline,'linestyle','none','marker','.','xdata',xx,'ydata',yy)
                                        set(htxt,'string',nnn); drawnow
                                        disp(nnn)  
                                        pause(.01)
                                        %dlmwrite('junk.txt',[xx yy],'\t')    
                                    end 
                                    setappdata(0,'plotxydata',[xx yy]);
                                    set(htxt,'visible','off')
                                    set(habort,'visible','off')
                                    setappdata(hfig,'MoviX',MoviX); setappdata(hfig,'MoviY',MoviY);
                                    uicontrol('tag','plotxyclipboard','string','To ClipBoard',...
                                        'position',[40 0 70 20],'callback',[mfilename ' plotxyclipboard'])               
                                    if jtot>1;
                                        uicontrol('tag','plotxyslider','style','slider','min',1,'max',jtot,...
                                            'sliderstep',[1/jtot min(1,3/jtot)],...
                                            'position',[200 0 80 15],'callback',[mfilename ' plotxyslider'],'value',jtot) 
                                        uicontrol('tag','plotxyslidertxt','style','text','position',[200 15 80 12],...
                                            'string',num2str(jtot))
                                    end
                                case 20 % Matdraw
                                    try; matdraw; catch; msgbox('Cannot find Matdraw'); end
                                case 21 % reverse color
                                    if isrgb(Movi); msgbox('Convert to 8 bit'); return; end
                                    setappdata(hfig,'play',0);
                                    if isrgb(Movi); msgbox('Change to 8 bits'); return; end
                                    hlo=findobj('tag','lo'); hhi=findobj('tag','hi');
                                    lo=get(hlo,'value'); hi=get(hhi,'value'); 
                                    try; lohi=lo+hi; catch; lohi=lo{1}+hi{1}; end
                                    nmax=length(list);                                    
                                    for j=1:nmax                                
                                        a=double(Movi(:,:,j)); a(:,:)=lohi-a(:,:);
                                        Movi(:,:,j)=a;
                                    end                                    
                                    setappdata(hfig,'Movi',Movi)  
                                    set(himg,'cdata',Movi(:,:,1))
                                    setappdata(hfig,'play',1)
                                case 22 % pan
                                    wd0=size(Movi,2); ht0=size(Movi,1);
                                    wd=num2str(min(500,wd0-100));
                                    prompt={'Width?','Step?'}
                                    title='Pan across single image'; lineno=1; def={wd,'10'};
                                   inp=inputdlg(prompt,title,lineno,def);
                                        if isempty(inp); return; end
                                   wd=str2num(inp{1}); step=str2num(inp{2});
                                    nn=1+floor((wd0-wd)/step);
                                   frame0=get(hfs,'value');
                                   Movi2=Movi;
                                   if isrgb(Movi); Movi2=Movi(ones(1,ht0),ones(1,wd),ones(1,3),ones(1,nn));         
                            else Movi2=Movi2(ones(1,ht0),ones(1,wd),ones(1,nn)); end
                            c1=1;
                            for j=1:nn
                                c2=c1+wd-1;
                                if isrgb(Movi); Movi2(:,:,:,j)=Movi(:,c1:c2,:,frame0);
                                else Movi2(:,:,:,j)=Movi(:,c1:c2,:,frame0);
                                end
                            c1=c1+step;
                           list2{j}=['pan' num2str(j)];
                        end
                            
                            setappdata(hfig,'Movi2',Movi2); setappdata(hfig,'list2',list2)
                            figure(hfig)
                            srf=getappdata(hfig,'srf'); setappdata(0,'makesurf',srf);
                            eval ([mfilename ' pan' [' pan' num2str(hfig)] ' pan']) % to make nargin=3      
                                   
                                   
                                end % MISC
                                
                            case 'ippopup'         
                                hpop=findobj(hfig,'tag','ippopup');
                                nn=round(get(hpop,'value')); set(hpop,'value',1)        
                                switch nn % nothing(1); 
                                    case 1 % Ippopup    
                                    case 2 % collapse - keep brightest pixel                
                                        setappdata(hfig,'play',0); szy=size(Movi,1);               
                                        la=num2str(length(list));
                                        prompt={['Replace which frame (1-' la ') in movie with collapsed frame? (0=none)']};
                                        title='Replace movie frame with this frame?'; lineno=1;def={'0'};
                                        inp=inputdlg(prompt,title,lineno,def);
                                        if isempty(inp); return; end
                                        frame=max(0,min(length(list),str2num(inp{1})));                
                                        if frame; set(hfs,'value',frame); eval([mfilename ' frameslider']); end
                                        jmin=round(get(hffs,'value')); jmax=round(get(hlfs,'value'));
                                        htxt=text('position',[5 szy/2], 'color','red', 'fontsize',14);                
                                        if isrgb(Movi); a=double(Movi(:,:,:,jmin)); 
                                        else; a=double(Movi(:,:,jmin)); end 
                                        set(habort,'visible','on'); setappdata(0,'abort',0)
                                        for jj=jmin+1:jmax
                                            if getappdata(0,'abort'); set(habort,'visible','off'); setappdata(0,'abort',0); return; end
                                            set(htxt,'string',[num2str(jj) '/' num2str(jmax)]); 
                                            disp([num2str(jj) '/' num2str(jmax)]); drawnow                    
                                            if isrgb(Movi); 
                                                for k=1:3; b=double(Movi(:,:,k,jj)); a2=a(:,:,k);
                                                    c=a2>b; d=a2.*c; e=b.* ~c; a2=d+e; a(:,:,k)=a2; end 
                                            else; b=double(Movi(:,:,jj)); c=a>b; d=a.*c; e=b.* ~c; a=d+e;
                                            end
                                            set(himg,'cdata',a)
                                        end
                                        delete (htxt); setappdata(0,'abort',0)
                                        try; set(habort,'visible','off'); catch; end                
                                        if frame                    
                                            if isrgb(Movi); Movi(:,:,:,frame)=uint8(a);
                                            elseif isa(Movi,'uint8'); Movi(:,:,frame)=uint8(a);
                                            elseif isa(Movi,'uint16'); Movi(:,:,frame)=uint16(a);
                                            end
                                            setappdata(hfig,'Movi',Movi)
                                        end                
                                    case 3 % add/multiply data
                                        prompt={'Add' 'Multiply'};
                                        title='New = (Old+Add) * Mult. Type Add and Mult'; lineno=1;
                                        def={'0' '1'};
                                        ans=inputdlg(prompt,title,lineno,def);
                                        if isempty(ans); return; end
                                        add=str2num(ans{1}); mult=str2num(ans{2});
                                        if add==0 & mult==1; return; end
                                        if isrgb(Movi); return; end
                                        set(habort,'visible','on')                
                                        fi=get(findobj(hfig,'tag','firstframeslider'),'value');
                                        la=get(findobj(hfig,'tag','lastframeslider'),'value');
                                        htxt=text(20,150,[num2str(fi) '/' num2str(la)],'fontsize',24,'color','red');
                                        for jj=fi:la
                                            set(htxt,'string',[num2str(jj) '/' num2str(la)]); drawnow
                                            if getappdata(0,'abort'); set(habort,'visible','off'); setappdata(0,'abort',0); return; end    
                                            disp ([num2str(jj) '/' num2str(la)])
                                            a=double(Movi(:,:,jj))+add; 
                                            if mult~= 1; a=a.*mult;end
                                            if isa(Movi,'uint16'); a=uint16(a); Movi(:,:,jj)=a; 
                                            else Movi(:,:,jj)=uint8(a); end
                                        end               
                                        set(habort,'visible','off'); delete(htxt)
                                        setappdata(hfig,'Movi2',Movi)                
                                        eval ([mfilename ' clip' ' clip' ' clip'])
                                        
                                    case 4 % fft
                                        setappdata(hfig,'play',0) % turn off play
                                        if isrgb(Movi); msgbox('RGB images! Cannot do fft'); return; end
                                        setappdata(0,'abort',0); set(habort,'visible','on') % setup abort
                                        if getappdata(0,'abort'); set(habort,'visible','off'); return; end            
                                        jmin=round(get(hffs,'value')); jmax=round(get(hlfs,'value')); % get slider values                       
                                        linecolor='red'; % first line color
                                        sz=size(Movi); 
                                        hh=msgbox('Click OK here. Then: Select square region for fft: click, drag, release, then move, click again'); uiwait(hh)
                                        setappdata(hfig,'square',1)
                                        set(hfig,'userdata','hello'); % set(hfig,'interruptible','on');
                                        bbgetrect
                                        waitfor(hfig,'userdata')
                                        setappdata(hfig,'square',0)
                                        rectpos=getappdata(hfig,'pos');                
                                        rectangle('position',rectpos,'edgecolor','red'); drawnow
                                        %  htxt=text('units','pixels','position',[5 sz(2)/2], 'color','red', 'fontsize',12);                
                                        % htxt=text(10, sz(1)/2, '','color','red', 'fontsize',12);                
                                        %  set (htxt,'string','Using this SQUARE region for fft')
                                        drawnow
                                        sz=max(size(Movi,1), size(Movi,2)); % size of frame (must be square)
                                        % try; delete(findobj(0,'tag','fftfig'));catch; end % delete old window            
                                        hfftfig=figure('tag','fftfig','position',[100 400 300 300],...
                                            'doublebuffer','on');  % make new window            
                                        hax=axes('xlim',[0 sz],'visible','off','ylim',[0 sz]); % new axes
                                        him=image('cdatamapping','scaled'); % new image
                                        colormap(jet(256))            
                                        Movi2=uint16(0); % save fft's in Movi2
                                        Movi2= Movi(ones(1,sz),ones(1,sz),ones(1,jmax-jmin+1));           
                                        nn=0;
                                        for j=jmin:jmax % loop through movie (fft for each image)
                                            nn=nn+1;
                                            if getappdata(0,'abort'); set(habort,'visible','off'); setappdata(0,'abort',0); return; end
                                            f=Movi(:,:,j);                    
                                            F=fft2(f,sz,sz); % 2D fft, padded to sz x sz
                                            F=fftshift(F); % put low frequencies at center
                                            F2=abs(F); F2=log10(F2); % log plot
                                            F2=F2.*F2; % power spectrum 
                                            d=diag(F2); % diagonal line to plot (from center to lower right)
                                            d=d(floor(size(d,1)/2+1):end); % plot from center to corner only
                                            if j==jmin; yfac=sz/max(d(:)); % scale y data to first image
                                                s=size(d,1); x=log10([1:size(d,1)])'; 
                                                xy(:,1)=x; dmax=max(x(:)); x=x.*2*s/dmax; % scale x data                                    
                                            else linecolor='white'; end                    
                                            xy(:,nn+1)=d;
                                            d=smoothn(d,[5,5]); % smooth it                                    
                                            %xy(:,nn+1)=d;
                                            d=d*yfac;               
                                            figure(hfftfig) % pop window
                                            set(him,'cdata',F2); drawnow % show fft
                                            line(x,d,'color',linecolor); % plot line
                                            drawnow; pause(0.5)       
                                            Movi2(:,:,nn)=uint16(F2); % save for new window
                                        end % for jmin:jmax
                                        setappdata(hfftfig,'zdata',xy(:,2:end)); setappdata(0,'xdata',xy(:,1))
                                        bbplot
                                        set(habort,'visible','off') % turn off abort button
                                        setappdata(hfig,'Movi2',Movi2); setappdata(hfig,'mapname','jet')
                                        setappdata(hfig,'list2',list(jmin:jmax,:)); 
                                        
                                        figure(hfig) % must pop calling window
                                        eval([mfilename ' fft' ' fft' ' fft'])
                                        
                                    case 5 % sum - sum pixel values                
                                        setappdata(hfig,'play',0); szy=size(Movi,1);               
                                        la=num2str(length(list));
                                        prompt={['Replace which frame (1-' la ') in movie with summed frame? (0=none)']};
                                        title='Replace movie frame with this frame?'; lineno=1;def={'1'};
                                        inp={'1'};
                                        inp=inputdlg(prompt,title,lineno,def);
                                        if isempty(inp); return; end
                                        frame=max(0,min(length(list),str2num(inp{1})));                
                                        if frame; set(hfs,'value',frame); eval([mfilename ' frameslider']); end
                                        jmin=round(get(hffs,'value')); jmax=round(get(hlfs,'value'));
                                        htxt=text('position',[5 szy/2], 'color','red', 'fontsize',14);                
                                        if isrgb(Movi); a=double(Movi(:,:,:,jmin)); 
                                        else; a=double(Movi(:,:,jmin)); end 
                                        set(habort,'visible','on')
                                        for jj=jmin+1:jmax
                                            if getappdata(0,'abort'); set(habort,'visible','off'); setappdata(0,'abort',0); return; end
                                            set(htxt,'string',[num2str(jj) '/' num2str(jmax)]); 
                                            disp([num2str(jj) '/' num2str(jmax)]); drawnow                    
                                            if isrgb(Movi); 
                                                for k=1:3; b=double(Movi(:,:,k,jj)); a2=a(:,:,k);
                                                    c=a2+b; a(:,:,k)=c; end 
                                            else; b=double(Movi(:,:,jj));
                                                a=a+b; % disp(sum(b(:)))
                                            end
                                            set(himg,'cdata',a)
                                            drawnow
                                        end
                                        mx=max(a(:)); summ=sum(a(:));
                                        delete (htxt); setappdata(0,'abort',0)
                                        try; set(habort,'visible','off'); catch; end                
                                        clc; disp(['Brightest pixel=' num2str(mx)])
                                        disp(['Sum of all pixels=' num2str(summ)])
                                        if frame                    
                                            if isrgb(Movi); Movi(:,:,:,frame)=uint8(a);
                                            elseif isa(Movi,'uint8'); 
                                                if mx>255; fac=255/mx; a=a*fac;
                                                    hdlg=msgbox(['Max (' num2str(mx) ') exceeds 255. Muliplying by ',...
                                                            num2str(fac) '.'],'Max exceeds 255');
                                                    uiwait(hdlg)
                                                end
                                                Movi(:,:,frame)=uint8(a);
                                                mx=255;
                                            elseif isa(Movi,'uint16'); Movi(:,:,frame)=uint16(a); end
                                            setappdata(hfig,'Movi',Movi)
                                            hhi=findobj(hfig,'tag','hi');
                                            %hlo=findobj(hfig,'tag','lo');
                                            set(hhi,'max',mx,'value',mx);
                                            %set(hlo,'max',mx,'value',mx/2);
                                            eval([mfilename ' lohi'])
                                        end                
                                        
                                    case 6 % histogram of pixel values               
                                        setappdata(0,'abort',0); set(habort,'visible','on');drawnow               
                                        setappdata(hfig,'play',0)
                                        hffs=findobj(hfig,'tag','firstframeslider'); hlfs=findobj(hfig,'tag','lastframeslider');
                                        jmin=round(get(hffs,'value')); jmax=round(get(hlfs,'value'));            
                                        hfig=findobj(0,'tag','histofig'); 
                                        if isempty(hfig); 
                                            hfig=figure('tag','histofig','doublebuffer','on',...
                                                'position',[20 300 400 400]); setappdata(hfig,'bw',5)
                                            hhs=uicontrol; hhstxt=uicontrol; hbws=uicontrol; 
                                            hbwstxt=uicontrol; hyscale=uicontrol;   
                                        else
                                            htxt=findobj(hfig,'tag','histotxt'); if ~isempty(htxt); delete(htxt); end
                                            hline=findobj(hfig,'tag','histoline'); delete(hline)
                                            hax=findobj(hfig,'type','axes'); delete(hax);
                                            hhs=findobj(hfig,'tag','histoslider'); hhstxt=findobj(hfig,'tag','histoslidertxt');
                                            hbws=findobj(hfig,'tag','bwslider'); hbwstxt=findobj(hfig,'tag','bwslidertxt');
                                            hline=findobj(hfig,'tag','histoline');    
                                        end
                                        figure(hfig)
                                        bw=getappdata(hfig,'bw');
                                        npix=size(Movi,1)*size(Movi,2);
                                        xmin=double(min(Movi(:))); xmax=double(max(Movi(:)))+bw;                                        
                                        ymin=log10(100/npix); ymax=log10(100); 
                                        hax=axes %('xlim',[xmin xmax],'ylim',[ymin ymax]); 
                                        %ylabel(['Log % total (' num2str(npix) ' pixels)'])                                
                                        ylabel(['% total (' num2str(npix) ' pixels)'])
                                        hline=line('tag','histoline','marker','.','color','red');         
                                        htxt=text('tag','histotxt','position',[(xmin+xmax)/2 1.8], 'color','red', 'fontsize',14);                                        
                                        jtot=jmax-jmin+1;
                                        xx=[xmin:bw:xmax]; 
                                        for jj=jmin:jmax
                                            if getappdata(0,'abort'); set(habort,'visible','off'); setappdata(0,'abort',0); return; end
                                            nn=jj-jmin+1;   
                                            nnn=[num2str(nn) '/' num2str(jtot)]; set(htxt,'string',nnn)
                                            if isrgb(Movi)
                                                a=double(Movi(:,:,:,nn));
                                            else a=double(Movi(:,:,nn));
                                            end
                                            n=100*histc(a(:),xx)/npix;
                                            n(n<=0)=100/npix;
                                            %n=log10(n);                    
                                            x3=xx+bw/2;
                                            set(hline,'xdata',x3,'ydata',n)
                                            drawnow
                                        end 
                                        set(habort,'visible','off'); set(htxt,'visible','off')
                                        setappdata(hfig,'Movi',Movi);             
                                        set(hhs,'tag','histoslider','style','slider','min',jmin,'max',jmax+.1*(jmax==jmin),...
                                            'sliderstep',[min(1,1/jtot) min(1,3/jtot)],...
                                            'position',[200 0 80 15],'callback',[mfilename ' histoslider'],'value',jmax) 
                                        set(hhstxt,'tag','histoslidertxt','style','text','position',[200 15 80 12],...
                                            'string',['Frame# ' num2str(jmax)])
                                        set(hbws,'tag','bwslider','style','slider','min',1,'max',101,...
                                            'sliderstep',[.01 .05],...
                                            'position',[10 0 80 15],'callback',[mfilename ' bwslider'],'value',bw) 
                                        set(hbwstxt,'tag','bwslidertxt','style','text','position',[10 15 80 12],...
                                            'string',['BinWidth ' num2str(bw)])
                                        set(hyscale,'tag','histoyscale','string','Yscale','position',[2 50 40 25],...
                                            'callback',[mfilename ' histoyscale'])
                                        set(hax,'buttondownfcn',[mfilename ' xyz2'])        
                                    case 7 % contour
                                        setappdata(hfig,'play',0)
                                        frame=get(hfs,'value');
                                        %pos=get(hfig,'position'); wd=pos(3); scrnsz=get(0,'screensize');
                                        a=Movi(:,:,frame); 
                                        %szx=size(a,2); szy=size(a,1);
                                        %hfig2=findobj(0,'tag','contour');
                                        %if ~isempty(hfig2); delete(hfig2); end
                                        %pos=[10 scrnsz(4)-szy-200 wd szy+150];
                                        %hfig2=figure('tag','contour','position',pos);                                           
                                        %set(hfig2,'name',['Contour Fig' num2str(hfig) ' Frame' num2str(frame)])
                                        %htxt=text(0.1,0.1,'Wait...'); drawnow
                                        %figure(hfig2); 
                                        v=100;
                                        % while v
                                        inp=inputdlg('Cutoff? (0 to quit)', 'Contour', 1, {num2str(v)});
                                        v=str2num(inp{:});
                                        
                                        bw=(a>=v);
                                        npix=sum(bw(:));
                                        avg=sum(sum(a(bw)))/npix;
                                        disp([npix avg])
                                        % display outline
                                        bw2=bwmorph(bw,'remove');
                                        [r,c]=find(bw2);
                                        hline=line('xdata',c,'ydata',r,'linestyle','none','marker','.','markersize',4,'color','red');
                                        %fs=regionprops(a,'all')
                                        
                                        % vv=[v v];                                                                   
                                        %[C,h]=imcontour(a,vv);                                     
                                        % end
                                        % inp=questdlg('Label contours?','Label or not?');
                                        % if strcmp(inp,'Yes'); clabel(C,h); end
                                    case 8 % spacer    
                                        return    
                                    case 9 % smooth
                                        setappdata(hfig,'play',0);
                                        jmin=round(get(hffs,'value')); jmax=round(get(hlfs,'value'));
                                        if isempty(jmin); jmin=1; jmax=1; end
                                        prompt={'Radius? (odd number)',...
                                                'Std. deviation? (0=box average; >0=gaussian average)'}; title='Moving average smoothing'; 
                                        lineno=1; %def={'3' '0.65'}; 
                                        def=getappdata(0,'lastsmooth'); if isempty(def); def={'3' '0.65'}; end
                                        inp=inputdlg(prompt,title,lineno,def); if isempty(inp); return; end
                                        v=str2num(inp{1}); if v/2==round(v/2); v=v+1; end % odd number
                                        std=str2num(inp{2});
                                        setappdata(0,'lastsmooth',inp)              
                                        filt='box'; if std>0; filt='gaussian'; end
                                        Movi2=Movi; szy=size(Movi,1);
                                        htxt=text('position',[5 szy/2], 'color','red', 'fontsize',14);
                                        set(habort,'visible','on')
                                        for jj=jmin:jmax
                                            if getappdata(0,'abort'); set(habort,'visible','off'); setappdata(0,'abort',0); return; end
                                            set(htxt,'string',[num2str(jj) '/' num2str(jmax)]); 
                                            disp([num2str(jj) '/' num2str(jmax)]); drawnow
                                            if isrgb(Movi); 
                                                for k=1:3; Movi2(:,:,k,jj)=smoothn(Movi(:,:,k,jj),[v;v],filt,std); end
                                            else
                                                Movi2(:,:,jj)=smoothn(Movi(:,:,jj),[v;v],filt,std); end
                                        end
                                        delete(htxt)
                                        set(habort,'visible','off')
                                        setappdata(hfig,'Movi2',Movi2)
                                        srf=getappdata(hfig,'srf'); setappdata(0,'makesurf',srf);
                                        eval ([mfilename ' smooth' ' smooth' ' smooth'])                
                                    case 10 % equalize bkg (tophat)
                                        setappdata(hfig,'play',0)
                                        setappdata(hfig,'ipmode','tophat')
                                        eval([mfilename ' ip'])
                                        
                                    case 11 % sharpen   (orig+tophat-bothat)        
                                        setappdata(hfig,'play',0)
                                        setappdata(hfig,'ipmode','sharpen')
                                        eval([mfilename ' ip'])
                                    case 12 % histeq
                                        setappdata(hfig,'play',0)
                                        setappdata(hfig,'ipmode','histeq')
                                        eval([mfilename ' ip'])
                                    case 13 % open    
                                        setappdata(hfig,'play',0)
                                        setappdata(hfig,'ipmode','open')
                                        eval([mfilename ' ip'])
                                    case 14 % close
                                        setappdata(hfig,'play',0)
                                        setappdata(hfig,'ipmode','close')
                                        eval([mfilename ' ip'])                   
                                    case 15 % watershed feature extraction
                                        %setappdata(hfig,'play',0)
                                        %setappdata(hfig,'ipmode','watershed')
                                        %eval([mfilename ' ip'])
                                        eval([mfilename ' watershed'])                
                                    case 16 % ginger
                                        if isrgb(Movi); msgbox('Convert to 8 bit image'); return; end
                                        
                                        clc
                                        showintro=0;
                                        if showintro;
                                            hh=msgbox(['Ginger finds the areas of white rings with dark centers on a dark background.',...
                                                    'Adjust the slider so the rings are filled uniformly. Then leftj-click inside regions ',...
                                                    'of interest. Picked rings will be marked and their area displayed. ',...
                                                    'RIGHT click to delete the last selection']);
                                            uiwait(hh)
                                        end
                                        
                                        v.pixelspermicron=0.42;
                                        prompt={'How many pixels/micron?'}; title='Pixels per micron';
                                        lineno=1; def={num2str(v.pixelspermicron)}; 
                                        inp=inputdlg(prompt,title,lineno,def);
                                        v.pixelspermicron=str2num(inp{:});
                                        
                                        hfs=findobj(hfig,'tag','frameslider'); frame=round(get(hfs,'value'));
                                        if isempty(frame); frame=1; end
                                        v.frame=frame;
                                        v.z=[];
                                        v.a=Movi(:,:,frame);
                                        setappdata(hfig,'ginger',v)
                                        
                                        thresh=100;   
                                        uicontrol('tag','ginger1a','style','text','string',['threshold=' num2str(thresh)],...
                                            'position',[2 35 80 30],'backgroundcolor','red','fontsize',12,...
                                            'userdata','ginger');
                                        step=1/256; 
                                        uicontrol('tag','ginger1b','style','slider','value',thresh,'min',0,'max',255,...
                                            'sliderstep',[step 5*step],'callback',[mfilename ' gingerslider'],...
                                            'position',[2 5 80 30],'userdata','ginger');
                                        uicontrol('string','OK','position',[200 10 80 45],...
                                            'callback',[mfilename ' gingerexit'],'fontsize',18,...
                                            'backgroundcolor','red','userdata','ginger'); 
                                        set(himg,'buttondownfcn',[mfilename ' gingerpicker';]);
                                        eval([mfilename ' gingerslider'])
                                    end % IPPOPUP     
                                    
                                case 'gingerslider' % slider to fill holes and separate areas
                                    v=getappdata(hfig,'ginger'); frame=v.frame;
                                    a=Movi(:,:,frame);
                                    h1=findobj('tag','ginger1b'); % minarea
                                    h1txt=findobj('tag','ginger1a');
                                    thresh=get(h1,'value'); thresh=round(thresh);
                                    
                                    jnow=get(hfs,'value');
                                    set(h1txt,'string',['threshold=' num2str(thresh)])
                                    drawnow
                                    bw=(a>=thresh);
                                    bw2=bwmorph(bw,'remove'); % outline of separate areas above threshold
                                    a(bw2)=0; % this should separate all neighboring areas from each other
                                    a=imfill(a,'holes'); a(bw2)=0; % fill holes                                       
                                    set(himg,'cdata',a)                                        
                                    drawnow
                                    v=getappdata(hfig,'ginger');
                                    v.a=a;                                     
                                    setappdata(hfig,'ginger',v)    
                                case 'gingerpicker' % pick areas
                                    v=getappdata(hfig,'ginger');
                                    button=get(hfig,'selectiontype');
                                    if (strcmp(button,'alt')) % right button - omit last selection
                                        z=v.z; if isempty(z); return; end
                                        sz=size(z,1); 
                                        hh=findobj('tag',['ginger' num2str(sz)]); delete(hh)
                                        z=z(1:end-1,:); 
                                        v.z=z; setappdata(hfig,'ginger',v)
                                        frame=v.frame;
                                        disp(['Area ' num2str(sz) ' deleted'])
                                        set(himg,'cdata',Movi(:,:,frame))
                                    elseif (strcmp(button,'normal')) % select new area
                                        [x y] = bbgetcurpt(gca);
                                        x=round(x); y=round(y);                                        
                                        
                                        frame=v.frame; a=v.a; z=v.z;
                                        a0=Movi(:,:,frame);
                                        val=a(y,x); % brightness of selected pixel
                                        bw=(a==val);
                                        bw2=bwlabel(bw,4);
                                        s=regionprops(bw2,'Area','PixelList','Eccentricity','MajorAxisLength');
                                        j=0; found=0;
                                        while ~found % find the region containing the selected pixel
                                            j=j+1;
                                            if j>size(s,1); disp('not found'); return; end
                                            p=s(j).PixelList;
                                            for k=1:size(p,1)
                                                if p(k,1)==x & p(k,2)==y; found=1; end
                                            end
                                        end
                                        % found the selected area
                                        aa=s(j).Area; 
                                        aamicron=aa/((v.pixelspermicron)^2);
                                        ee=s(j).Eccentricity; 
                                        mal=s(j).MajorAxisLength; malmicron=mal/v.pixelspermicron;
                                        nn=size(v.z,1)+1;
                                        v.z=[v.z; [nn aamicron ee malmicron]];
                                        disp([num2str(nn) ' ' num2str(aa) ' pixels; ' num2str(aamicron) ' square microns; ',...
                                                num2str(ee) ' eccentricity; ' num2str(malmicron) ' microns (diam)'])
                                        for j=1:size(p,1)
                                            a0(p(j,2),p(j,1))=0;
                                        end
                                        text('tag',['ginger' num2str(nn)],'string',num2str(nn),'position',[x y],...
                                            'color','white','horizontalalignment','center')
                                        setappdata(hfig,'ginger',v)
                                        set(himg,'cdata',a0)                                     
                                    end                                    
                                case 'gingerexit'
                                    v=getappdata(hfig,'ginger'); z=v.z; frame=v.frame;                                    
                                    h1=findobj('tag','ginger1b'); 
                                    thresh=round(get(h1,'value'));                                        
                                    delete(findobj('userdata','ginger'))
                                    set(himg,'cdata',Movi(:,:,frame))
                                    set(himg,'buttondownfcn',[mfilename ' xyz1.pixval';]);                                                                              
                                    if isempty(z); return; end
                                    dlmwrite('junk.txt',z,' ') % display the results (areas)
                                    edit('junk.txt')
                                    
                                case 'ip'
                                    se=getstrel;
                                    if isempty(se); return; end                
                                    figure(hfig)
                                    ipmode=getappdata(hfig,'ipmode');
                                    hffs=findobj(hfig,'tag','firstframeslider'); hlfs=findobj(hfig,'tag','lastframeslider');
                                    jmin=round(get(hffs,'value')); jmax=round(get(hlfs,'value')); 
                                    if isempty(jmin); jmin=1; jmax=1; end
                                    set(habort,'visible','on'); setappdata(0,'abort',0) % setup
                                    htxt=text('position',[5 50],'color','yellow','fontsize',16); str0=['/' num2str(jmax)]; drawnow
                                    Movi2=uint8(0); if isa(Movi,'uint16'); Movi2=uint16(0); end
                                    Movi2=Movi2(ones(1,size(Movi,1)),ones(1,size(Movi,2)),ones(1,jmax-jmin+1));     
                                    for frame=jmin:jmax
                                        set(htxt,'string',[num2str(frame) str0])
                                        if getappdata(0,'abort'); set(habort,'visible','off'); set(habort,'visible','off'); delete(htxt); setappdata(0,'abort',0); return; end
                                        a=Movi(:,:,frame);                    
                                        switch ipmode
                                            case 'tophat'
                                                b=imtophat(a,se);
                                                c=imadjust(b,stretchlim(b));
                                            case 'sharpen'
                                                c=imsubtract(imadd(a,imtophat(a,se)),imbothat(a,se));
                                                %pause(0.05)
                                            case 'histeq'
                                                c=histeq(a);
                                            case 'open'
                                                c=imopen(a,se);
                                            case 'close'
                                                c=imclose(a,se);
                                        end 
                                        ss=c; set(himg,'cdata',ss); set(hax,'clim',[0 max(1,max(ss(:)))]); drawnow
                                        Movi2(:,:,frame-jmin+1)=ss;
                                    end    
                                    set(himg,'cdata',Movi(:,:,frame)); drawnow
                                    delete(htxt)
                                    set(habort,'visible','off') % turn off abort button
                                    setappdata(hfig,'Movi2',Movi2); setappdata(hfig,'mapname','jet')
                                    setappdata(hfig,'list2',list(jmin:jmax,:)); 
                                    figure(hfig) % must pop calling 
                                    str=[' ' ipmode];
                                    set(habort,'visible','off') % cleanup                   
                                    eval([mfilename str str str])                    
                                    
                                case 'watershed' % watershed feature extraction            
                                    setappdata(hfig,'play',0); setappdata(0,'watlabel',0)
                                    hh=findobj(0,'type','figure'); str=''; name=get(hh,'name'); 
                                    if ~iscell(name); name={name}; end; strorig='';
                                    for j=1:size(hh,1); 
                                        str=[str num2str(hh(j)) ' ']; 
                                        if findstr(name{j},'++'); strorig=num2str(hh(j)); end 
                                    end   
                                    if isempty(strorig); strorig=str(1); end
                                    prompt={['Watershed areas will be performed on this Figure. Which Figure for calculations? (' str ')']};
                                    title='Watershed Figure for calculations?'; lineno=1; 
                                    def={num2str(strorig)};
                                    inp=inputdlg(prompt,title,lineno,def);
                                    if isempty(inp); return; end
                                    hfig0=str2num(inp{1}); 
                                    hax0=findobj(hfig0,'type','axes'); himg0=findobj(hax0,'type','image');                    
                                    try; Movi0=getappdata(hfig0,'Movi'); catch; return; end
                                    %if isrgb(Movi0); msgbox('Convert to 8 or 16 bit', 'RGB not allowed'); return; end            
                                    %  if ~isa(Movi0,'uint8') | isrgb(Movi0); msgbox('Convert to 8 bit please!'); return; end
                                    hfs0=findobj(hfig0,'tag','frameslider'); 
                                    if isempty(hfs0); frame0=1; else frame0=get(hfs0,'value'); end
                                    A0=Movi0(:,:,frame0); % Do calcs on this
                                    
                                    frame=get(hfs,'value'); if isempty(frame); frame=1; end
                                    a0=Movi(:,:,frame); % apply watershed to this image                                                        
                                    if size(a0) ~= size(A0); msgbox('Frames must be same size. Try again.'); return; end
                                    
                                    mx=double(max(a0(:)))+1; if isa(Movi,'uint8'); mx=255; end
                                    hlo=findobj(hfig,'tag','lo'); lo=round(get(hlo,'value')); 
                                    hhi=findobj(hfig,'tag','hi'); hi=round(get(hhi,'value')); 
                                    a=a0; a(a<=lo)=mx; acomp=imcomplement(a);
                                    %%%%%%%%%%%%%%%%%%%%%%%
                                    wat=watershed(acomp); 
                                    bw=bwlabel(wat); wat=bw; % renumbers areas to be left -> right
                                    %%%%%%%%%%%%%%%%%%%%%%%
                                    watmax=max(wat(:)); 
                                    
                                    figure(hfig0); set(0,'currentfigure',hfig0)
                                    rgb=A0; rgb(:,:,2)=A0; rgb(:,:,3)=A0; %r=double(A0); 
                                    rgb=double(rgb); rgb=rgb/max(rgb(:));
                                    %    planea=1; planeb=2;        
                                    stats=regionprops(wat,'Area'); aa=[stats.Area]; 
                                    setappdata(0,'watstats',stats)
                                    aa=sort(aa'); 
                                    aa=aa(1:end-1); % Throw out biggest, which is background. (always?)          
                                    aau=unique(aa); szaau=size(aau,1);
                                    minarea=aau(1); maxarea=aau(end);
                                    
                                    set(himg0,'cdata',rgb); set(hax0,'clim',[0 max(rgb(:))])
                                    
                                    hh=findobj(hfig0,'type','uicontrol'); set(hh,'visible','off')
                                    setappdata(0,'handles',hh); setappdata(0,'wat',wat)
                                    setappdata(0,'watidx',[1:watmax,1])
                                    wat2=double(wat==0)*255; % makes outline of watershed areas
                                    [x,y]=find(wat2);
                                    hline=findobj(hfig,'tag','watline'); 
                                    if isempty(hline); 
                                        hline=line(y,x,'tag','watline','color','white','linestyle','none','marker','.','markersize',1);
                                    else                
                                        set(hline,'xdata',y,'ydata',x)    
                                    end 
                                    setappdata(0,'watrgb',rgb)
                                    
                                    set(himg0,'buttondownfcn',[mfilename ' watbutton'])
                                    %                     %%%%%%%% Minarea SLIDER
                                    minstep=1/szaau; maxstep=min(1,5*minstep);
                                    uicontrol('tag','watminarea','userdata','uiwatershed',...
                                        'style','slider','callback',[mfilename ' watslider'],...
                                        'position',[60 50 60 15],'min',1,'max',szaau,...
                                        'sliderstep',[minstep maxstep],'tooltipstring','MinArea','value',1);
                                    uicontrol('tag','watminareatxt','style','text','userdata','uiwatershed',...
                                        'position',[60 65 60 15],'string',['Min ' num2str(minarea)]);
                                    uicontrol('tag','watareatitletxt','style','text','userdata','uiwatershed',...
                                        'position',[60 80 60 15],'string','AREA:');
                                    %                      %%%%%%%% Maxarea SLIDER 
                                    uicontrol('tag','watmaxarea',...
                                        'style','slider','callback',[mfilename ' watslider'],'userdata','uiwatershed',...
                                        'position',[60 10 60 15],'min',1,'max',szaau,...
                                        'sliderstep',[minstep maxstep],...
                                        'tooltipstring',['Maximum Area ' num2str(maxarea)],'value',szaau);
                                    uicontrol('tag','watmaxareatxt','style','text','userdata','uiwatershed',...
                                        'position',[60 25 60 15],'string',['Max ' num2str(maxarea)]);    
                                    %%%%%%%%%%%% Calculate button
                                    uicontrol('tag','watcalc','string','Calculate','position',[160 10 60 15],...
                                        'callback',[mfilename ' watcalc'],'userdata','uiwatershed','backgroundcolor','red') 
                                    %%%%%%%%%%%% Number areas on/off
                                    uicontrol('tag','watabort','string','Label','position',[240 10 60 15],...
                                        'callback',[mfilename ' watlabel'],'userdata','uiwatershed')     
                                    %%%%%%%%%%%% Help
                                    uicontrol('tag','wathelp','string','Help','position',[320 30 60 15],...
                                        'callback',[mfilename ' wathelp'],'userdata','uiwatershed')     
                                    %%%%%%%%%%%% Quit
                                    uicontrol('tag','watabort','string','Quit','position',[320 10 60 15],...
                                        'callback',[mfilename ' watabort'],'userdata','uiwatershed')     
                                    %%%%%%%%%%%% Text
                                    uicontrol('tag','wattxt','position',[160 100 140 15],...
                                        'string',[num2str(watmax) '/' num2str(watmax) ' selected'],...
                                        'userdata','uiwatershed')
                                    %%%%%%%%%%%% Line on/off
                                    uicontrol('tag','watlinebutton','string','Line On/Off','position',[240 50 60 15],...
                                        'callback',[mfilename ' watline'],'userdata','uiwatershed')     
                                    %%%%%%%%%%% Area histogram
                                    uicontrol('tag','watareahisto','string','Area Histo','position',[240 70 60 15],...
                                        'callback',[mfilename ' watareahisto'],'userdata','uiwatershed')     
                                    
                                    setappdata(0,'watline',1)
                                    
                                    hh=findobj(0,'userdata','uiwatershed'); setappdata(0,'wathandles',hh)   
                                    eval([mfilename ' watslider']) % gets the number selected to be correct
                                    eval([mfilename ' watrgb'])    
                                    
                                case 'watbutton'
                                    button=get(hfig,'selectiontype');
                                    idx=getappdata(0,'watidx'); wat=getappdata(0,'wat');
                                    [x y]=bbgetcurpt(gca);
                                    x=round(x);y=round(y);
                                    nn=wat(y,x); % switch x&y for images!!
                                    switch button
                                        case 'normal'
                                            idx=unique([idx nn]);
                                        case 'alt'
                                            idx(idx==nn)=[];            
                                    end
                                    setappdata(0,'watidx',idx)
                                    eval([mfilename ' watrgb'])
                                case 'watareahisto'
                                    stats=getappdata(0,'watstats');  aa=[stats.Area]; aa=sort(aa)'; aa=aa(1:end-1,1);
                                    setappdata(hfig,'histo',1)
                                    setappdata(hfig,'zdata',aa); setappdata(0,'xdata',[])
                                    bbplot
                                case 'watline'
                                    watline=~getappdata(0,'watline'); setappdata(0,'watline',watline)
                                    vis='off'; if watline; vis='on'; end
                                    hline=findobj(hfig,'tag','watline'); set(hline,'visible',vis)
                                case 'watslider'
                                    stats=getappdata(0,'watstats'); aa=[stats.Area]; aau=unique(aa);
                                    wat=getappdata(0,'wat'); 
                                    %rgb=getappdata(0,'watrgb');
                                    % rgb=get(himg,'cdata'); 
                                    
                                    hmin=findobj(hfig,'tag','watminarea');
                                    watmin=get(hmin,'min'); watmax=max(wat(:)); % get(hmin,'max'); 
                                    vmin=round(get(hmin,'value')); mmin=aau(vmin);
                                    hmax=findobj(hfig,'tag','watmaxarea'); 
                                    vmax=round(get(hmax,'value')); mmax=aau(vmax);
                                    newmin=min(vmin,vmax); newmax=max(vmin,vmax);
                                    set(hmin,'value',newmin); set(hmax,'value',newmax) 
                                    
                                    hmaxtxt=findobj(hfig,'tag','watmaxareatxt'); 
                                    hmintxt=findobj(hfig,'tag','watminareatxt');
                                    set(hmaxtxt,'string',['Max ' num2str(mmax)])
                                    set(hmintxt,'string',['Min ' num2str(mmin)])
                                    
                                    idx=find(aa>=mmin & aa<=mmax);            
                                    setappdata(0,'watidx',idx);  
                                    eval([mfilename ' watrgb'])
                                    
                                case 'watrgb' % makes rgbimage from idx
                                    stats=getappdata(0,'watstats'); aa=[stats.Area]; aau=unique(aa);
                                    wat=getappdata(0,'wat'); watmax=max(wat(:));
                                    idx=getappdata(0,'watidx');
                                    rgb=getappdata(0,'watrgb');
                                    planea=1; planeb=2; plane0=3;
                                    
                                    spoton=ismember(wat,idx);
                                    spotoff=~ismember(wat,idx);
                                    bb=double(spoton); bb(spoton>0)=0.5; bb(spoton==0)=1;
                                    r=double(rgb(:,:,plane0));
                                    rgb(:,:,planea)=r.*bb; % r;                
                                    bb=double(spotoff); bb(spotoff>0)=0.5; bb(spotoff==0)=1;
                                    rgb(:,:,planeb)=r.*bb; % r;                
                                    set(himg,'cdata',rgb); set(hax,'clim',[0 max(rgb(:))])
                                    spon=size(idx,2); spoff=watmax-spon;
                                    hwattxt=findobj(hfig,'tag','wattxt'); 
                                    set(hwattxt,'string',[num2str(spon) '/' num2str(watmax) ' selected'])
                                    %disp(['minarea ' num2str(mmin) ' '  num2str(spon) ' regions selected; ' num2str(spoff) ' regions deselected'])                                                            
                                    setappdata(0,'watrgb',rgb)
                                    %    watcalc=getappdata(hfig,'watcalc'); if isempty(watcalc); watcalc=0; end
                                    %   if ~watcalc; return; end            
                                case 'watcalc'
                                    prompt={['AVG (0) or MAX (1) or ROI (2)? ',...
                                                'NOTE: AVG and MAX will use the entire region. ',...
                                                'ROI will return the AVG of all pixels in a rectangle centered on the brightest ',...
                                                'pixel in each region. The radius of the rectangle is given in the 3rd line'],...
                                            'Graph (enter 0 - x axis is frame number) or Histogram (enter 1 - x axis is brightness)?' 'If RO1 chosen in line 1: Radius of ROI rectangle?'};
                                    title='Calculate average or max or roi? / Plot as graph or histogram?';
                                    lineno=1; def={'0' '0' '2'};
                                    inp=inputdlg(prompt, title, lineno, def);
                                    if isempty(inp); return; end
                                    modecalc=str2num(inp{1}); modedisp=str2num(inp{2}); r=str2num(inp{3});
                                    
                                    stats=getappdata(0,'watstats'); aa=[stats.Area]; rgb=getappdata(0,'watrgb'); 
                                    wat=getappdata(0,'wat'); idx=getappdata(0,'watidx'); spon=size(idx,2);
                                    hrect=findobj('tag','watrect'); delete(hrect); drawnow
                                    habort=findobj(hfig,'tag','abort');
                                    hfstxt0=findobj(hfig,'tag','picname');
                                    list=getappdata(hfig,'list');
                                    hffs0=findobj(hfig,'tag','firstframeslider'); jmin=get(hffs0,'value');
                                    hlfs0=findobj(hfig,'tag','lastframeslider'); jmax=get(hlfs0,'value');
                                    if isempty(jmin); jmin=1; jmax=1; end
                                    list=getappdata(hfig,'list'); 
                                    set(habort,'visible','on'); setappdata(0,'abort',0) % setup
                                    htxt=text(5,10,'','color','red','fontsize',12);
                                    set(htxt,'string','Regionprops...')            
                                    rrmax=jmax-jmin+1; 
                                    res=zeros(rrmax,spon);
                                    rr=0; 
                                    str1=['/' num2str(jmax) ' (' num2str(spon) ' regions)'];           
                                    for frame=jmin:jmax
                                        set(htxt,'string',[num2str(frame) str1]); drawnow
                                        a0=Movi(:,:,frame); szx=size(a0,2); szy=size(a0,1);
                                        rr=rr+1;     
                                        set(hax,'climmode','auto')
                                        set(himg,'cdata',a0); drawnow              
                                        str=['/' num2str(jmax) '; Spot ']; str2=['/' num2str(spon)];
                                        for j=1:spon
                                            nn=idx(j);
                                            npix=aa(j); % watarea(j); 
                                            if getappdata(0,'abort'); 
                                                delete(htxt); set(habort,'visible','off'); setappdata(0,'abort',0); 
                                                eval([mfilename ' watabort']); return; 
                                            end
                                            a=a0; a(wat~=nn)=0; b=a>0; npix=sum(b(:));
                                            switch modecalc
                                                case 0 % 'Avg'
                                                    avg=sum(a(:))/npix;                 
                                                    npix0(rr,j)=npix; res(rr,j)=avg; 
                                                    str3=[': Avg=' num2str(avg)];
                                                case 1 % 'Max'
                                                    mx=double(max(a(:)));
                                                    res(rr,j)=mx;
                                                    str3=[': Max=' num2str(mx)];  
                                                case 2
                                                    mx=max(a(:));
                                                    [y x]=find(a==mx); 
                                                    x=x(1); y=y(1);
                                                    x1=max(1,x-r); x2=min(x+r,szx); y1=max(1,y-r); y2=min(y+r,szy);
                                                    %pos[max(1,y-r) min(y+r,szy) max(1,x-r) min(x+r,szy)];
                                                    %acb=a0(pos(1):pos(2),pos(3):pos(4));
                                                    acb=a0(y1:y2,x1:x2);
                                                    npixels=size(acb,1)*size(acb,2);
                                                    % Rectangle: Border pixels are INCLUDED in calculation
                                                    rectangle('tag','watrect','position',[x1 y1 size(acb,2)-1 size(acb,1)-1],'edgecolor','red')
                                                    acb=sum(acb(:))/npixels; disp(acb); 
                                                    res(rr,j)=acb;
                                                    str3=[': Int=' num2str(acb)]; 
                                            end    
                                            drawnow
                                            % disp(['Frame ' num2str(frame) str num2str(j) str2]) % str3])
                                        end    
                                    end 
                                    set(habort,'visible','off') % cleanup
                                    delete(htxt)
                                    if modedisp
                                        setappdata(hfig,'zdata',res'); setappdata(hfig,'histo',1); setappdata(0,'xdata',[])
                                    else
                                        setappdata(hfig,'zdata',res); setappdata(hfig,'histo',0); setappdata(0,'xdata',[])
                                    end
                                    bbplot
                                    set(himg,'cdata',rgb); set(hax,'clim',[0 max(rgb(:))])        
                                case 'watlabel'
                                    watlabel=getappdata(0,'watlabel');
                                    watlabel=~watlabel;
                                    if watlabel
                                        wat=getappdata(0,'wat'); watmax=max(wat(:));
                                        idx=getappdata(0,'watidx'); %stats=getappdata(0,'stats');
                                        wat2=ismember(wat,idx); wat=wat2.*wat; stats2=regionprops(wat,'Centroid');
                                        habort=findobj(hfig,'tag','abort');
                                        set(habort,'visible','on'); setappdata(0,'abort',0) % setup
                                        for j=1:size(idx,2)
                                            nn=idx(j);
                                            disp(stats2(nn).Centroid)
                                            if getappdata(0,'abort'); set(habort,'visible','off'); setappdata(0,'abort',0); return; end
                                            xy=stats2(nn).Centroid; 
                                            text(xy(1),xy(2),num2str(j),'color','red','horizontalalignment','center'); drawnow
                                        end      
                                    else
                                        delete(findobj('type','text'))
                                    end
                                    setappdata(0,'watlabel',watlabel)
                                    set(habort,'visible','off')
                                case 'watabort'
                                    hh=getappdata(0,'wathandles'); delete(hh)           
                                    hh=getappdata(0,'handles'); set(hh,'visible','on')
                                    habort=findobj(hfig,'tag','abort'); set(habort,'visible','off')
                                    ffs=1; hffs=findobj(hfig,'tag','firstframeslider'); 
                                    if ~isempty(hffs); ffs=get(hffs,'value'); end
                                    lo=round(get(findobj(hfig,'tag','lo'),'value'));
                                    hi=round(get(findobj(hfig,'tag','hi'),'value'));
                                    setappdata(hfig,'play',ffs);
                                    set(hax,'clim',[lo hi])
                                    set(himg,'cdata',Movi(:,:,ffs));                                                 
                                    set(himg,'buttondownfcn',[mfilename ' xyz1.pixval'])
                                case 'wathelp'
                                    str=['Green=selected areas. Red=deselected areas. The AREA sliders',...
                                            ' limit selected areas by number of pixels (area).',...
                                            ' Left click to select a single area.',...
                                            ' RIGHT click to DEselect a single area. Click CALCULATE to find',...
                                            ' average fluorescence of each selected area.'];
                                    msgbox(str,'Watershed Areas')
                                    
                                case 'xyz2'
                                    button=get(hfig,'selectiontype');
                                    if (strcmp(button,'alt'))                   
                                        [x y]=bbgetcurpt(gca);
                                        %x=round(x);y=round(y);
                                        htxt=findobj(hfig,'tag','htxt');
                                        if isempty(htxt); htxt=text('tag','htxt','position',[100, 0]); end
                                        set(htxt,'string',['x=' num2str(x)])
                                        disp([x y])
                                    end            
                                case 'plotxyslider'
                                    hfig=gcf; hax=gca; 
                                    hxy=findobj(hfig,'tag','plotxyslider'); set(hxy,'visible','off')
                                    hxytxt=findobj(hfig,'tag','plotxyslidertxt'); set(hxytxt,'visible','off')
                                    drawnow
                                    hline=findobj(hax,'type','line'); 
                                    htxt=findobj(hax,'tag','plotxytxt'); 
                                    val=round(get(hxy,'value')); set(hxy,'value',val); 
                                    set(hxytxt,'visible','on','string',num2str(val))
                                    set(hline,'visible','off'); drawnow
                                    set(htxt,'visible','on','string','wait...')
                                    MoviX=getappdata(hfig,'MoviX'); MoviY=getappdata(hfig,'MoviY'); 
                                    xx=zeros((size(MoviX,1)*size(MoviX,2)),1); yy=xx;
                                    xx(:)=MoviX(:,:,val); yy(:)=MoviY(:,:,val);
                                    set(hline,'linestyle','none','marker','.','xdata',xx,'ydata',yy,'visible','on')
                                    setappdata(0,'plotxydata',[xx yy]);
                                    set(htxt,'string',num2str(val)); 
                                    set(hxy,'visible','on')
                                    drawnow     
                                case 'plotxyclipboard'                                   
                                    xxyy=getappdata(0,'plotxydata');
                                    htxt=findobj(hax,'tag','plotxytxt'); 
                                    set(htxt,'string','Copying to clipboard...','visible','on'); drawnow
                                    clipboard('copy',xxyy);    
                                    set(htxt,'string','');
                                case 'histoslider'
                                    hfig=gcf; hax=gca; 
                                    hh=findobj(hfig,'tag','histoslider');             
                                    hhtxt=findobj(hfig,'tag','histoslidertxt');
                                    hline=findobj(hax,'type','line'); htxt=findobj(hax,'tag','histotxt');
                                    nn=round(get(hh,'value')); set(hh,'value',nn); 
                                    bw=getappdata(hfig,'bw');
                                    set(hhtxt,'string',['Frame# ' num2str(nn)])
                                    Movi=getappdata(hfig,'Movi'); npix=size(Movi,1)*size(Movi,2);
                                    xmin=double(min(Movi(:))); xmax=double(max(Movi(:)))+bw;
                                    %if xmin==0; xmin=1; end
                                    xx=[xmin:bw:xmax];
                                    if isrgb(Movi)
                                        a=double(Movi(:,:,:,nn));
                                    else a=double(Movi(:,:,nn));
                                    end
                                    n=100*histc(a(:),xx)/npix;
                                    n(n<=0)=100/npix; % Avoid log(0) error (min is 1 pixel, not 0)
                                    %n=log10(n);
                                    %set(hax,'xlim',[xmin xmax])
                                    x3=xx+bw/2;
                                    set(hline,'xdata',x3,'ydata',n)
                                    %npix2=npix; % ?????????????????????????
                                    %avg=sum(a(:))/npix2; disp(['Frame ' num2str(nn) '. Average of pixels >0 is ' num2str(avg)])
                                    drawnow     
                                case 'bwslider'
                                    hbws=findobj(hfig,'tag','bwslider'); 
                                    bw=max(1,round(get(hbws,'value'))); set(hbws,'value',bw);
                                    hbwstxt=findobj(hfig,'tag','bwslidertxt'); 
                                    set(hbwstxt,'string',['BinWidth ' num2str(bw)])
                                    setappdata(hfig,'bw',bw)
                                    eval([mfilename ' histoslider'])
                                case 'histoyscale'
                                    yy=get(gca,'ylim');
                                    ymax=num2str(yy(2));
                                    prompt={['Ymax? (ENTER=' ymax]};
                                    title='Ymax';
                                    lineno=1;
                                    def={ymax};
                                    inp=inputdlg(prompt,title,lineno,def);
                                    if isempty(inp); inp={ymax}; end
                                    set(gca,'ylim',[yy(1) str2num(inp{:})])
                                    
                                    
                                    %%%%%%%%%%%%%%%%% Clip/Stretch controls %%%%%%%%%%%%%%        
                                case 'lohi' % LO & HI SLIDERS
                                    hlo=findobj(hfig,'tag','lo'); hhi=findobj(hfig,'tag','hi');
                                    vlo=get(hlo); vhi=get(hhi); % all vals in struct array
                                    htext=findobj(hfig,'tag','lohi');   
                                    lo=round(vlo.Value); % Struct categories are case sensitive 
                                    hi=round(vhi.Value); 
                                    if lo>=hi;
                                        prompt={'Lo?' 'Hi?'}; title='Set Lo and Hi'; lineno=1;
                                        def={num2str(hi) num2str(lo)};
                                        [inp]=inputdlg(prompt,title,lineno,def);
                                        if isempty(inp); return; end
                                        a=str2num(inp{1}); b=str2num(inp{2}); lo=min(a,b); hi=max(a,b);
                                        set(hlo,'Min',lo,'Max',hi,'value',lo); 
                                        set(hhi,'Min',lo,'Max',hi,'value',hi)         
                                    end
                                    set(hlo,'tooltipstring',num2str(lo));
                                    set(hhi,'tooltipstring',num2str(hi));
                                    set(htext,'string',[num2str(lo) ' : ' num2str(hi)])
                                    set(hax,'clim',[lo hi])
                                    
                                    %     # pixels at lo and hi values
                                    frame=get(hfs,'value');
                                    if isrgb(Movi); a=Movi(:,:,:,frame); else; a=Movi(:,:,frame); end
                                    b=(a==lo); npixlo=sum(b(:)); b=(a==hi); npixhi=sum(b(:));
                                    disp ([num2str(npixlo) ' pixels=' num2str(lo) '; ' num2str(npixhi) '=' num2str(hi)])
                                    b=a<=lo; npixlo=sum(b(:)); b=a>=hi; npixhi=sum(b(:));    
                                    disp ([num2str(npixlo) ' pixels<=' num2str(lo) '; ' num2str(npixhi) '>=' num2str(hi)])
                                    
                                case 'rgbrgb' % stretch sliders for rgb movie        
                                    hs=gco; play=getappdata(hfig,'play');
                                    fac=get(hs,'value');
                                    if fac==5; set(hs,'value',1); fac=1;end
                                    set(hs,'tooltipstring',num2str(fac))
                                    plane=str2num(get(hs,'userdata'));
                                    if fac == 1;     
                                        Movi(:,:,plane,:)=Movi2(:,:,plane,:); 
                                    else
                                        for j=1:size(Movi,4)                       
                                            %a=double(Movi2(:,:,plane,j))*fac; % a=double(a);
                                            %a=a*fac; 
                                            %Movi(:,:,plane,j)=uint8*(a);
                                            Movi(:,:,plane,j)=uint8(double(Movi2(:,:,plane,j))*fac);
                                        end
                                    end
                                    setappdata(hfig,'Movi',Movi); 
                                    
                                case 'rgb2gray' % CONVERT rgb to 8 bit grayscale
                                    setappdata(hfig,'play',0);        
                                    Movi2=uint8(0); Movi2=Movi2(ones(1,size(Movi,1)),ones(1,size(Movi,2)),ones(1,length(list))); 
                                    htxt=text(20,20,'','fontsize',18,'color','red');
                                    map=colormap;
                                    for j=1:length(list); 
                                        set(htxt,'string',[num2str(j) '/' num2str(length(list))]); pause(.1); drawnow; 
                                        disp ([num2str(j) '/' num2str(length(list))]) 
                                        a=rgb2ind(Movi(:,:,:,j),map); 
                                        Movi2(:,:,j)=a;             
                                    end
                                    delete(htxt)
                                    %Movi=Movi2;
                                    %setappdata(hfig,'Movi',Movi); 
                                    setappdata(hfig,'Movi2',Movi2); 
                                    setappdata(hfig,'mapname',''); 
                                    % hlohitxt=findobj(hfig,'tag','lohitxt'); set(hlohitxt,'string','8 bit');
                                    % htext0=findobj(hfig,'tag','text0'); hto8bit=findobj(hfig,'tag','to8bit');
                                    % set(htext0,'string','8 bit'); 
                                    % set(hto8bit,'string','Apply','callback',[mfilename ' convert'],'visible','off');
                                    % hlo=findobj(hfig,'tag','lo'); hhi=findobj(hfig,'tag','hi');
                                    % set(hlo,'visible','on'); set(hhi,'visible','on')
                                    %set(himg,'cdatamapping','direct'); set(hax,'climmode','manual');
                                    colormap(map); 
                                    srf=getappdata(hfig,'srf'); setappdata(0,'makesurf',srf);
                                    eval ([mfilename ' convert' ' convert' ' convert']) % to make nargin=3
                                case 'convert' % CONVERT 16 TO 8 BIT
                                    setappdata(hfig,'play',0); setappdata(0,'convert',1)
                                    eval([mfilename ' clip'])
                                case 'clip' % CLIP FLOOR/CEILING (stretch only if converting to 8 bit)
                                    cnvt=getappdata(0,'convert'); if isempty(cnvt); cnvt=0; setappdata(0,'convert',0); end
                                    hlo=findobj(hfig,'tag','lo'); hhi=findobj(hfig,'tag','hi');
                                    lo=round(get(hlo,'value')); hi=round(get(hhi,'value'));
                                    mn=get(hlo,'min'); mx=get(hlo,'max');
                                    if lo==mn & hi==mx & ~cnvt; return; end 
                                    setappdata(hfig,'play',0); 
                                    prompt={'low cutoff?', 'high cutoff?'}; title='Clip';
                                    def={num2str(lo),num2str(hi)}; lineno=1;
                                    [lohi]=inputdlg(prompt,title,1,def); 
                                    if isempty(lohi); return; end
                                    lo=str2num(lohi{1}); hi=str2num(lohi{2});            
                                    range=hi-lo;
                                    htext=findobj(hfig,'tag','lohi'); htext0=findobj(hfig,'tag','lohitxt');
                                    hto8bit=findobj(hfig,'tag','to8bit');        
                                    Movi2=uint16(0); if isa(Movi,'uint8') | cnvt; Movi2=uint8(0); end
                                    Movi2=Movi2(ones(1,size(Movi,1)),ones(1,size(Movi,2)),ones(1,length(list))); 
                                    fac=255/range; newlo=0; newhi=hi-lo;
                                    htxt=text('position',[10 10], 'color','red', 'fontsize',12);
                                    setappdata(0,'abort',0); set(habort,'visible','on') % setup
                                    for jj=1:length(list);
                                        if getappdata(0,'abort'); set(habort,'visible','off'); setappdata(0,'abort',0); return; end
                                        set(htxt,'string',[num2str(jj) '/' num2str(length(list))]);                 
                                        drawnow
                                        disp([num2str(jj) '/' num2str(length(list))]);
                                        v=double(Movi(:,:,jj));
                                        v(v>hi)=hi; v(v<lo)=lo; 
                                        v=v-lo;
                                        if cnvt; v=v.*fac; end %%%%%%%%%%%%% ONLY IF CONVERTING TO 8 BIT
                                        Movi2(:,:,jj)=round(v);
                                    end
                                    set(habort,'visible','off') % cleanup
                                    if isa(Movi,'uint8'); set(hto8bit,'visible','off'); end
                                    setappdata(hfig,'Movi2',Movi2); setappdata(0,'convert',0);
                                    delete(htxt)
                                    eval([mfilename ' clip' ' clip' ' clip']);
                                case 'floor'
                                    floorx=getappdata(hfig,'floor');
                                    if isempty(floorx);floorx=0;end
                                    if floorx; Movi=Movi2;
                                        floorx=0;
                                    else floorx=1; 
                                        hlo=findobj(hfig,'tag','lo'); hhi=findobj(hfig,'tag','hi');
                                        lo=round(get(hlo,'value')); hi=round(get(hhi,'value'));
                                        Movi(Movi<=lo)=0;end
                                    setappdata(hfig,'floor',floorx)
                                    setappdata(hfig,'Movi',Movi)
                                end  % nargin == 1
                            end  % switch nargin
                            
                            %************************* SUBFUNCTIONS START HERE *********************
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %             %%%%%%%%%% BBBLOCK
                            function big=bbblock (varargin); % x,y,big,small)
                            % BBBLOCK: inserts a small array into a big array with the 
                            % upper left corner at position x,y
                            % syntax:  big=bbblock(x,y,big,small)
                            x=varargin{1}; y=varargin{2}; big=varargin{3}; small=varargin{4};
                            szx=size(small,2); szy=size(small,1);
                            if isrgb(big);     big(y:y+szy-1,x:x+szx-1,:)=small;
                            else
                                big(y:y+szy-1,x:x+szx-1)=small; end
                            
                            %*********************************************************************
                            %******************************* BBDRAW ******************************
                            function bbdraw(varargin)
                            % BBDRAW: For drawing a line in an image and obtaining the
                            % x,y coordinates of the line. Left click
                            % *in the image* to start. Hold down button while drawing. 
                            % Releasing button ends the routine.
                            %  X and Y data are saved in two application-defined data
                            % in the current figure, namely:
                            %    setappdata(gca,'xdata',X)   and    setappdata(gca,'ydata',Y)
                            % Note that if the mouse motion is fast not all pixels will 
                            % be returned (requiring 'bbintline' to interpolate. 
                            source=[getappdata(0,'source') ' bbdraw'];
                            %['bbpv ' 'bbdraw'];
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
                                    set(him,'buttondownfcn',[source ' down';]);
                                    setappdata(hfig,'xdata',[]);setappdata(hfig,'ydata',[])
                                    drawnow   
                                case 1
                                    hfig=gcf;hax=gca;
                                    set(0,'currentfigure',hfig);
                                    switch(varargin{:})   
                                        case 'down'
                                            x=[];y=[];
                                            line('tag','lines','xdata',x,'ydata',y,'Visible', 'on', 'Clipping', 'on', ...
                                                'Color', 'r', 'LineStyle', '-', 'EraseMode', 'xor');
                                            %line('tag','lines','xdata',x,'ydata',y,'Visible', 'on', 'Clipping', 'on', ...
                                            %'color', 'r', 'LineStyle', '-', 'EraseMode', 'xor');
                                            set(0,'currentfigure',hfig);
                                            [x y] = bbgetcurpt(gca);
                                            him=findobj(get(hax,'children'),'type','image');
                                            set(him,'buttondownfcn','')
                                            set(hfig, 'WindowButtonDownFcn', '',...
                                                'WindowButtonMotionFcn', [source ' move;']);
                                            setappdata(hfig,'xdata',x);setappdata(hfig,'ydata',y); 
                                            set(hfig,'windowbuttonupfcn',[source ' up'])
                                        case 'move'
                                            hline=findobj(hax,'tag','lines');
                                            x=getappdata(hfig,'xdata');y=getappdata(hfig,'ydata');
                                            set(0,'currentfigure',hfig);
                                            [xnow,ynow] = bbgetcurpt(hax); 
                                            x=[x xnow]; 
                                            y=[y ynow];
                                            setappdata(hfig,'xdata',x);setappdata(hfig,'ydata',y); 
                                            set(hline,'xdata',xnow,'ydata',ynow,'visible','on');
                                            %set(hline,'xdata',x,'ydata',y,'visible','on'); % Morri suggests
                                            drawnow   
                                        case 'up'
                                            hline=findobj(hax,'tag','lines');
                                            set(0,'currentfigure',hfig);
                                            set(hfig,'pointer','arrow',...
                                                'WindowButtonMotionFcn', '',...
                                                'WindowButtonupFcn', '',...
                                                'userdata','')
                                            delete (hline)
                                    end   
                            end
                            
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%% BBGETRECT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            function bbgetrect(varargin);
                            % BBGETRECT: Drag out rectangle, tben position it. Coordinates are returned.
                            % Left click to start. Hold down button while dragging out 
                            % rectangle. Rectangle size is set when button is released. 
                            % Rectangle may then be moved to a new position, which is set 
                            % by pressing left button again.
                            % Position ('pos') values (x,y,width,height) are placed in application-defined
                            % location in the current figure: setappdata(gca,'pos',[x,y,width,height).
                            source=[getappdata(0,'source') ' bbgetrect'];
                            names={'pos','dx','dy','x0','y0'};
                            hax=gca; hfig=get(hax,'parent');
                            switch (nargin);
                                case 0
                                    set(hfig, 'Pointer', 'cross',...
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
                                    bbsetappdatas(hfig,names,vals);
                                    
                                case 1
                                    [pos,dx,dy,x0,y0]=bbgetappdatas(hfig,names);
                                    square=getappdata(hfig,'square');
                                    switch(varargin{:})
                                        case 'down1'
                                            [x0,y0] = bbgetcurpt(gca);
                                            pos=[x0 y0 1 1];
                                            names={'x0','y0','pos'}; vals={x0,y0,pos};
                                            bbsetappdatas(hfig,names,vals);
                                            set(findobj('tag','rect'), 'position', pos, 'visible', 'on');
                                            set(hfig, 'WindowButtonDownFcn', '',...
                                                'WindowButtonupfcn', [source ' up;'],...
                                                'WindowButtonMotionFcn', [source ' move1;']);
                                            ptr=nan; ptr=ptr(ones(1,16),ones(1,16));
                                            set(hfig,'PointerShapeCData', ptr,'Pointer', 'custom');
                                        case 'move1'
                                            [x,y] = bbgetcurpt(gca);
                                            if square
                                                ydis = abs(y - y0);
                                                xdis = abs(x - x0);
                                                
                                                if (ydis > xdis)
                                                    x = x0 + sign(x - x0) * ydis;
                                                else
                                                    y = y0 + sign(y - y0) * xdis;
                                                end
                                            end
                                            
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
                                            names={'dx','dy'};vals={dx,dy}; bbsetappdatas(hfig,names,vals);
                                            set(hfig, 'WindowButtonDownFcn', [source ' down2;']);
                                            set(hfig, 'WindowButtonMotionFcn', [source ' move2;']);
                                            setappdata(hfig,'pos0',[x,y])  
                                        case 'move2'
                                            [x,y] = bbgetcurpt(gca);
                                            x=round(x-dx); y=round(y-dy);
                                            pos(1)=x; pos(2)=y;
                                            setappdata(hfig,'pos',pos);
                                            set (findobj('tag','rect'), 'position', pos);       
                                        case 'down2'
                                            set(hfig,'pointer','arrow',...
                                                'WindowButtonDownFcn','',...
                                                'WindowButtonMotionFcn', '',...
                                                'WindowButtonupFcn', '')
                                            [x,y] = bbgetcurpt(gca);
                                            x=x-dx;y=y-dy;
                                            y=round(y); x=round(x); ht=round(pos(3)); wd=round(pos(4));
                                            drawnow 
                                            pos=round(pos);
                                            setappdata(hfig,'pos',pos)  
                                            delete (findobj(get(gca,'children'),'tag','rect'));
                                            set (hfig,'userdata','')
                                    end
                            end
                            
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%% BBINTLINE %%%%%%%%%%%%%%%%%%%%%%%%%%
                            function [x,y] = bbintline(x1, x2, y1, y2)
                            % BBINTLINE is the same as INTLINE.
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
                            
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%% BBPLOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            function bbplot(varargin)
                            % BBPLOT: Takes data (Z) from application-defined source 'zdata' in the
                            % current figure, namely:
                            % Z=getappdata(gca,'zdata')
                            % and plots the data in a separate figure.
                            % Each column of Z is plotted as a line.
                            % X axis is image pixel number. NOTE: This operation assumes that zoom is off.
                            %    If zoom is on, X axis will not equal image pixel value.
                            % Click 'Save' button to save in a file in ASCII format.
                            % Click 'Edit' to edit data in Matlab text editor window.
                            % Click 'Quit' to erase figure.
                            source=[getappdata(0,'source') ' bbplot'];       
                            switch (nargin)
                                case 0 
                                    hfig=gcf; hax=gca;            
                                    z=getappdata(hfig,'zdata');             
                                    hplotfig=findobj('tag','plotfig');
                                    if (~isempty(hplotfig)); setappdata(hplotfig,'z2data',z); end 
                                    histo=getappdata(hfig,'histo');
                                    caller=get(hfig,'userdata'); % 'profile'=LOI or 'tc'=ROI
                                    xfac=1;
                                    if isempty(histo);histo=0;end
                                    bbplot2(z,histo); 
                                    hplotfig=findobj(0,'tag','plotfig'); hplotax=findobj(0,'tag','plotax');
                                    bw=getappdata(hplotfig,'binwidth'); binone=getappdata(hplotfig,'binone');
                                    %%%%%%%%%%   UI Controls %%%%%%%
                                    
                                    jj=get(gcf,'position');
                                    xfac=jj(3); yfac=jj(4); umode='pixels'; %'normalized';
                                    xfac=1; yfac=1;
                                    fs=1; % fontsize
                                    
                                    ubw=30/xfac; usw=70/xfac; uh=20/yfac;
                                    %		%%%%%%%%% EDIT DATA -> now display only
                                    uicontrol('tag','plotuic','callback',[source ' edit'],...
                                        'fontsize',fs,'units',umode,...   
                                        'position',[80/xfac 0 ubw uh],'string','display',...
                                        'tooltipstring','Display data as ASCII');    
                                    
                                    %		%%%%%%%%% SAVE
                                    uicontrol('tag','plotuic','callback',[source ' save'],...
                                        'fontsize',fs,'units',umode,...
                                        'position',[0 0 ubw uh],'string','save',...
                                        'tooltipstring','Save');   
                                    %		%%%%%%%%% GRID
                                    uicontrol('tag','plotuic','callback',[source ' grid'],...
                                        'fontsize',fs,'units',umode,...
                                        'position',[40/xfac 0 ubw uh],'string','grid',...
                                        'tooltipstring','grid');  
                                    
                                    %                        %%%%%%%%%%% PLOTFIGURE SIZE SLIDER
                                    scrnsz=get(0,'screensize'); scrnx=scrnsz(3); scrny=scrnsz(4);
                                    cols=400; rows=400;
                                    uicontrol('tag','plotfigsizeslider',...
                                        'fontsize',fs,'units',umode,...
                                        'style','slider','callback',[source ' plotfigsize'],...
                                        'position',[120/xfac 0 ubw*2 uh],'min',.3,'max',2,...
                                        'sliderstep',[0.01 0.1],...
                                        'tooltipstring','FigSize 1','value',1);  
                                    uicontrol('tag','figsizeslidertxt','style','text',...
                                        'fontsize',fs,'units',umode,...    
                                        'position',[120/xfac uh ubw*2 12/yfac],'string','Fig Size');
                                    
                                    if histo     
                                        setappdata(0,'xylim',[]); % xlim is auto if empty, else manual
                                        
                                        %                    %%%%%%%%% BIN WIDTH SLIDER
                                        binwd=getappdata(hplotfig,'binwd');
                                        mn=min(1,.1*binwd); mx=5*binwd;
                                        minstep=min(.01,1/max(z(:))); maxstep=5*minstep;
                                        uicontrol('tag','plotbinwd',...
                                            'fontsize',fs,'units',umode,...
                                            'style','slider','callback',[source ' binwd'],...
                                            'position',[200/xfac 0 ubw*2 uh],'min',mn,'max',mx,...
                                            'sliderstep',[minstep maxstep],...
                                            'tooltipstring','Bin Width','value',binwd)
                                        %		%%%%%%%%%%% Bin width text slider
                                        uicontrol('tag','plotbinwdtxt','style','text',...
                                            'fontsize',fs,'units',umode,...
                                            'position',[200/xfac uh ubw*2 12/yfac],...
                                            'string',['BinWd ' num2str(binwd)], 'tooltipstring','bin width');    
                                        %             %%%%%%%%% BIN SHIFT SLIDER
                                        mn=0; mx=1; binshift=0;
                                        minstep=.01; maxstep=10*minstep;
                                        uicontrol('tag','plotbinshift',...
                                            'fontsize',fs,'units',umode,...
                                            'style','slider','callback',[source ' binshift'],...
                                            'position',[270/xfac 0 ubw*2 uh],'min',mn,'max',mx,...
                                            'sliderstep',[minstep maxstep],...
                                            'tooltipstring','Bin Width','value',binshift)
                                        %						%%%%%%%%%%% Bin shift slider text
                                        uicontrol('tag','plotbinshifttxt','style','text',...
                                            'fontsize',fs,'units',umode,...
                                            'position',[270/xfac uh ubw*2 12/yfac],...
                                            'string',['Shift ' num2str(binshift)], 'tooltipstring','bin shift');                            
                                    else
                                        %                            %%%%%%%%% BOXCAR SLIDER
                                        mx=max(2,round(size(z,1)/2)); minstep=min(1,2/(mx-(mx>1))); 
                                        maxstep=min(1,minstep*3);
                                        uicontrol('tag','plotboxcar',...
                                            'fontsize',fs,'units',umode,...
                                            'style','slider','callback',[source ' boxcar'],...
                                            'position',[200/xfac 0 ubw*2 uh],'min',1,'max',mx,...
                                            'sliderstep',[minstep maxstep],...
                                            'tooltipstring',['Moving Average'],'value',1)
                                        %						%%%%%%%%%%% Boxcar slider text
                                        uicontrol('tag','plotboxcartxt','style','text',...
                                            'fontsize',fs,'units',umode,...
                                            'position',[200/xfac uh ubw*2 12/yfac],...
                                            'string','Avg 1', 'tooltipstring','Moving average');           
                                        %                            %%%%%%%%% BOXCAR STD DEV SLIDER
                                        mn=0; mx=10; minstep=.01; maxstep=.05; val=0;
                                        uicontrol('tag','plotboxcarstd',...
                                            'fontsize',fs,'units',umode,...
                                            'style','slider','callback',[source ' boxcar'],...
                                            'position',[270/xfac 0 ubw*2 uh],'min',mn,'max',mx,...
                                            'sliderstep',[minstep maxstep],...
                                            'tooltipstring',['Moving Average Std.Dev.'],'value',val)
                                        %        	%%%%%%%%%%% Boxcar Std. Dev. slider text
                                        uicontrol('tag','plotboxcarstdtxt','style','text',...
                                            'fontsize',fs,'units',umode,...
                                            'position',[270/xfac uh ubw*2 12/yfac],...
                                            'string',['StdDev ' num2str(val)], 'tooltipstring','Moving average Std. Dev.');   
                                    end % if histo       
                                    %%%%%% Axes Scales
                                    uicontrol('tag','plotxylim','style','pushbutton','callback',[source ' xylim'],...
                                        'fontsize',fs,'units',umode,...    
                                        'position',[340/xfac 0 ubw uh],'string','Scale',...
                                        'tooltipstring','Axes Scales')                      
                                    %          %%%%%% QUIT 
                                    uicontrol('tag','plotuic','style','pushbutton','callback',[source ' quit'],...
                                        'fontsize',fs,'units',umode,...    
                                        'position',[400/xfac 0 ubw uh],'string','close',...
                                        'tooltipstring','Quit')   
                                case 1
                                    hplotfig=findobj('tag','plotfig'); 
                                    %xfac=get(hplotfig,'userdata');
                                    hplotax=findobj('tag','plotax');
                                    histo=getappdata(hplotfig,'histo');
                                    huic=findobj(hplotfig,'tag','plotuic');
                                    hfig=get(hplotfig,'userdata'); % original calling figure
                                    z2=getappdata(hplotfig,'z2data'); 
                                    z=getappdata(hplotfig,'zdata');
                                    switch (varargin{end})
                                        case 'xylim'
                                            xylim=getappdata(0,'xylim'); 
                                            if isempty(xylim)
                                                xlim=get(hplotax,'xlim');
                                                prompt={'Xmin' 'Xmax'}; 
                                                def={num2str(xlim(1)) num2str(xlim(2))};
                                                lineno=1; title='Graph Scale';
                                                inp=inputdlg(prompt,title,lineno,def);
                                                xlim=[str2num(inp{1}) str2num(inp{2})];            
                                                set(hplotax,'xlim',xlim); drawnow
                                                setappdata(0,'xylim',[xlim])
                                            else
                                                setappdata(0,'xylim',[])
                                            end
                                            bbplot2(z2)
                                        case 'save'
                                            [fname,pname]=uiputfile('*.txt','File name?',100,500);
                                            if (fname ~= 0)
                                                if isempty(findstr(fname,'.txt')); fname=[char(fname) '.txt']; end
                                                try z0=getappdata(0,'z0'); % 5 rows of data to be concatenated with z2
                                                    z3=[z0;z2];
                                                    msgbox('NOTE: The first 5 rows of the data table are: Spot Number, X, Y, and the last 2 rows are zeros (not used)')
                                                catch; z3=z2; 
                                                end
                                                save([pname fname],['z3'], '-ASCII')
                                                %if histo; save([pname fname],'z2', '-ASCII')  
                                                %else 
                                                %    xdata=getappdata(0,'xdata'); aa=[xdata z2];
                                                %   msgbox('First column is X data')
                                                %  save([pname fname],['aa'], '-ASCII')
                                                %end
                                            end    
                                        case 'grid'
                                            isgrid=getappdata(hplotfig,'grid');
                                            isgrid=~isgrid; setappdata(hplotfig,'grid',isgrid)
                                            if isgrid grid on; else grid off; end
                                        case 'edit' % Displays data - no editing possible 
                                            %if ~histo; msgbox('First column is X; all others are Y'); end
                                            %set (huic,'visible','off');       
                                            %uicontrol('tag','plotcontinue','callback',[source ' edit2'],...
                                            %   'position',[0 0 240 30],...
                                            %  'string',['Edit data, Save if changed. Then Click here'],...
                                            % 'tooltipstring','Continue after edit',...
                                            %'backgroundcolor',[1 .8 .8]);          
                                            drawnow
                                            xdata=getappdata(0,'xdata')
                                            dlmwrite('junk.txt',[xdata z2],'\t')
                                            edit 'junk.txt'
                                        case 'edit2'
                                            huic2=findobj(hplotfig,'tag','plotcontinue');
                                            set(huic2,'visible','off')
                                            z=textread ('junk.txt'); % reads as double 
                                            if ~histo; xdata=z(:,1); z=z(:,2:end); setappdata(0,'xdata',xdata); end
                                            setappdata(hplotfig,'zdata',z); 
                                            z2=z; setappdata(hplotfig,'z2data',z)
                                            set (huic,'visible','on'); 
                                            delete(hplotax)
                                            bbplot2(z2)    
                                        case 'quit'      
                                            hplotfig=findobj('tag','plotfig');
                                            delete(hplotfig);            
                                        case 'plotfigsize'         
                                            szx0=440; szy0=330; 
                                            hpfss=findobj(hplotfig,'tag','plotfigsizeslider');
                                            figfac=get(hpfss,'value'); 
                                            if figfac<=.3; figfac=1; set(hpfss,'value',1); end        
                                            set(hpfss, 'tooltipstring',['FigSize ' num2str(figfac)], 'value',figfac)   
                                            f0=get(hplotfig,'position');     
                                            figpos=[40 40 max(370,szx0*figfac) szy0*figfac];
                                            set(hplotfig,'position',figpos); setappdata(0,'plotfigpos',figpos)
                                            hplotax=findobj(hplotfig,'tag','plotax'); 
                                            set(hplotax,'position',[40 60 figpos(3)-50 figpos(4)-70]);
                                            drawnow
                                        case 'binwd'
                                            hbinwd=findobj(hplotfig,'tag','plotbinwd');
                                            hbinwdtxt=findobj(hplotfig,'tag','plotbinwdtxt');
                                            binwd=get(hbinwd,'value');
                                            setappdata(hplotfig,'binwd',binwd);
                                            set(hbinwdtxt,'string',['bw ' num2str(binwd)])
                                            bbplot2(z2) 
                                        case 'binshift'
                                            hbinshift=findobj(hplotfig,'tag','plotbinshift');
                                            hbinshifttxt=findobj(hplotfig,'tag','plotbinshifttxt');
                                            binshift=get(hbinshift,'value');
                                            setappdata(hplotfig,'binshift',binshift);
                                            set(hbinshifttxt,'string',['shift ' num2str(binshift)])
                                            bbplot2(z2)            
                                        case 'boxcar'
                                            hboxcar=findobj(hplotfig,'tag','plotboxcar');
                                            hboxcartxt=findobj(hplotfig,'tag','plotboxcartxt');
                                            hboxcarstd=findobj(hplotfig,'tag','plotboxcarstd');
                                            hboxcarstdtxt=findobj(hplotfig,'tag','plotboxcarstdtxt');                        
                                            v=max(1,round(get(hboxcar,'value'))); v=v+~rem(v,2);         
                                            set(hboxcartxt,'string',['Avg ' num2str(v)]);            
                                            vstd=get(hboxcarstd,'value');
                                            set(hboxcarstdtxt,'string',['StdDev ' num2str(vstd)]);            
                                            filt='box'; if vstd filt='gaussian'; end
                                            npeaks=0;
                                            for jj=1:size(z,2)
                                                z1=smoothn(z(:,jj),[v;v],filt,vstd);
                                                z2(:,jj)=z1;
                                                % COUNT PEAKS
                                                y1=diff(z1);
                                                y2=y1<0;
                                                y3=diff(y2);
                                                y4=y3>0;
                                                npeaks=npeaks+sum(y4(:));
                                                disp(['Total #peaks=' num2str(npeaks)]);
                                            end
                                            setappdata(hplotfig,'z2data',z2)
                                            delete(hplotax)
                                            bbplot2(z2)
                                        otherwise
                                        end % switch narargin
                                    end % switch nargin
                                    
                                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% BBPLOT2 %%%%%%%%%%%%%%%%%%%%
                                    function bbplot2(varargin)  % This does the plotting    
                                    z=varargin{1}; histo=0; 
                                    if nargin >1; histo=varargin{2}; end
                                    hplotfig=findobj('tag','plotfig');
                                    %hfig=getappdata(hplotfig,'caller');
                                    if (isempty(hplotfig)); 
                                        hplotfig=figure('tag','plotfig','doublebuffer','on'); 
                                        setappdata(hplotfig,'zdata',z); 
                                        setappdata(hplotfig,'z2data',z); 
                                        setappdata(hplotfig,'histo',histo);
                                        isgrid=0; setappdata(hplotfig,'grid',isgrid);
                                    end
                                    xfac=1; % get(hplotfig,'userdata'); % Replot after edit
                                    isgrid=getappdata(hplotfig,'grid');
                                    histo=getappdata(hplotfig,'histo');
                                    figure(hplotfig)
                                    set(0,'currentfigure',hplotfig);
                                    figpos=getappdata(0,'plotfigpos');
                                    set(hplotfig,'position',figpos, 'doublebuffer','on')
                                    hplotax=findobj(0,'tag','plotax');
                                    if (~isempty(hplotax)); delete(hplotax); end
                                    hplotax=axes('tag','plotax');
                                    axpos=[40 60 figpos(3)-50 figpos(4)-70];
                                    
                                    if histo
                                        % columns in z if unequal length are padded with -1.1111
                                        bw=z==-1.1111; zz=z+bw*9e99; mn=min(zz(:));
                                        zz=z-bw*9e99; mx=max(zz(:));        
                                        try; binwd=getappdata(hplotfig,'binwd'); binshift=getappdata(hplotfig,'binshift');
                                        catch nbins=10; binwd=(mx-mn)/nbins; binshift=0;
                                        end
                                        if isempty(binwd); nbins=10; binwd=(mx-mn)/nbins; binshift=0; end
                                        mn=mn-binshift*binwd; nbins=ceil((mx-mn)/binwd); 
                                        b=zeros(nbins+1,size(z,2)); sum=zeros(size(z,2),2);
                                        for c=1:size(z,2) % column of z
                                            for r=1:size(z,1)
                                                if z(r,c)~=-1.1111; 
                                                    rr=floor((z(r,c)-mn)/binwd)+1; b(rr,c)=b(rr,c)+1;  
                                                    sum(c,1)=sum(c,1)+1; sum(c,2)=sum(c,2)+z(r,c);
                                                end          
                                            end
                                        end
                                        b(2:end+1,:)=b; b(1,:)=0; b(end+1,:)=0;
                                        for col=1:size(z,2)
                                            rr=0; ccol=col+1;
                                            for r=1:size(b,1)-1
                                                rr=rr+1;
                                                if col==1; x=mn+binwd*(r-1); cc(rr,1)=x; cc(rr+1,1)=x; end
                                                cc(rr,ccol)=b(r,col); rr=rr+1; cc(rr,ccol)=b(r+1,col);
                                            end
                                        end    
                                        
                                        xlim=[mn-binwd 1.1*(mx+binwd)]; 
                                        ylim=[0 1.1*max(max(cc(:,2:end)))]; 
                                        xdata=cc(:,1); z=cc(:,2:end); xjitter=.005*(mx-mn); yjitter=.005*ylim(2);
                                        setappdata(hplotfig,'binwd',binwd); setappdata(hplotfig,'binshift',binshift)
                                        clc; disp('Avg  N')
                                        for j=1:size(sum,1)
                                            disp([num2str(sum(j,2)/sum(j,1)) ' ' num2str(sum(j,1))])
                                        end
                                    else % graph    
                                        ylim=[0 max(max(z(:)))*1.1]; 
                                        xdata=getappdata(0,'xdata'); 
                                        if isempty(xdata) | size(xdata,1)~=size(z,1); 
                                            xdata=[1:size(z,1)]'; setappdata(0,'xdata',xdata); end
                                        xlim=[0 max(xdata(:))*xfac];
                                        xdata=xdata.*xfac; xjitter=0; yjitter=0;    
                                    end % if histo  
                                    %set(hplotax,'tag','plotax','units','pixels',...
                                    %   'xlim',xlim,'ylim',ylim,...
                                    %  'position',axpos,'visible','on');    
                                    set(hplotax,'tag','plotax','units','pixels',...
                                        'position',axpos,'visible','on');  
                                    xylim=getappdata(0,'xylim'); if ~isempty(xylim); set(hplotax,'xlim',xylim); end
                                    if isgrid; grid on; else grid off; end
                                    set(hplotfig,'visible','on'); 
                                    clr={'r' 'g' 'b' 'k'}; % 'y' 'm' 'c'};
                                    % if ~rem(size(z,2),3) clr={'r' 'g' 'b'}; end
                                    sym={'o' 's' '^' 'd' 'v' 'x' '+' '*' 'p' 'h'};
                                    typ={'-' ':' '--' '-.'};
                                    clr2=0; sym2=0; typ2=0; str={}; cc=0; rr=1;
                                    for jj=1:size(z,2);
                                        msz=4-3.99*histo;
                                        clr2=(clr2+1)*(clr2<size(clr,2))+(clr2==size(clr,2));
                                        sym2=sym2+(clr2==1); if sym2>size(sym,2); sym2=1; end
                                        % if histo sym2=11; end
                                        typ2=typ2+(clr2==1 & sym2==1); if typ2>size(typ,2); typ2=1; end
                                        cc=cc+1; if cc>6; rr=rr+1; cc=1; end
                                        str{rr,cc}=[num2str(jj) ': ' clr{clr2} sym{sym2} typ{typ2}];
                                        line(xdata+(jj-1)*xjitter,z(:,jj)+(jj-1)*yjitter,...
                                            'tag',['line' jj],...
                                            'color',clr{clr2},...
                                            'linestyle',typ{typ2},...
                                            'linewidth',0.5,...
                                            'marker',sym{sym2},...
                                            'markeredgecolor',clr{clr2},...
                                            'markerfacecolor',clr{clr2},...
                                            'markersize',msz,...
                                            'visible','on');
                                    end
                                    disp('Column#: color/symbol/line: ')
                                    disp(str)
                                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                    %%%%%%%%%%%%%%%%%%%%%%%%%% BBMAKELIST %%%%%%%%%%%%%%%%%%%%%%%%%
                                    function bbmakelist(varargin)
                                    % MAKELIST: For constructing a list of TIF images. A basename is typed and 
                                    % all files matching it are placed in a preliminary list (images are assumed
                                    % to be named 'basename.xxx.tif', where 'xxx' is a number (000-999) and 'basename'
                                    % is whatever comes before the number).
                                    % The preliminary list can be modified in several ways (edited directly, culled
                                    % by matching a string, culled by skipping some) to create a final list.
                                    % The final list is saved in a file called 'piclist.txt'. BBPV reads 
                                    % this list to determine which images to load into RAM for display.
                                    % See also Word file bbpvdocumentation.doc for details.
                                    homedir=getappdata(0,'homedir');
                                    piclistdir=homedir; % [homedir 'img\']; % directory where piclist.txt and picdir.txt exist
                                    picpath='./';
                                    exit=0; 
                                    while (exit == 0)
                                        %%%%%%%%%%%%%%%      Directory
                                        try; picdir=char(textread([piclistdir 'picdir.txt'],'%s'));
                                        catch; picdir=piclistdir; dlmwrite([piclistdir 'picdir.txt'],char(piclistdir),'');end
                                        try
                                            cd (picdir)
                                        catch
                                            %disp('ERROR trying to change directory.')
                                            picdir=piclistdir;
                                            dlmwrite([piclistdir 'picdir.txt'], char(piclistdir),'')
                                            cd (picdir)
                                        end        
                                        if (~exist([piclistdir 'piclist.txt']));
                                            list=[]; dlmwrite([piclistdir 'piclist.txt'],list,'');   
                                        end
                                        helpnote='Documentation at: http://www.uchsc.edu/sm/physiol/wjb/matlab/bbpv.htm';
                                        %disp(helpnote)
                                        wd=pwd;
                                        disp(['Current directory ' wd]); 
                                        
                                        
                                        %%%%%%%%%%%% List of images (piclist.txt)
                                        
                                        list=textread([piclistdir 'piclist.txt'],'%s');
                                        
                                        sz=size(list,1);
                                        if (sz);
                                            disp(' '); disp(['CURRENT LIST: ' num2str(sz) ' entries: ' list{1} ' ... ' list{end}])
                                        else
                                            disp('List: 0 entries')
                                        end
                                        choices={'MENU:';...
                                                's=show list';...
                                                'i=Info about image';...
                                                'd(or ls)=dir';...
                                                'b=base names (unique first fields)';...
                                                'sk=skip';... 
                                                'c=cut';... 
                                                'cc=include';...
                                                'x=erase list & start over';...
                                                'cd=change directory';...
                                                'e=edit';...
                                                'z=make RGB from 3 lists'};
                                        disp(char(choices))
                                        beep
                                        inp=input ('Type base name (wild cards OK) (ENTER=use current list)\n\n','s');
                                        
                                        switch inp
                                            case 'i'
                                                prompt=['Which number? (1-' num2str(sz) '; ENTER=all)\n\n'];
                                                inp=input(prompt,'s');
                                                if isempty(inp); 
                                                    for j=1:sz  
                                                        try
                                                            info=imfinfo([picdir list{j}])
                                                        catch; disp (['Error reading ' list{j}])
                                                        end; 
                                                    end                           
                                                else
                                                    try
                                                        %more on
                                                        info=imfinfo([picdir list{str2num(inp)}])
                                                    catch; disp (['Error reading ' list{inp}])
                                                        info
                                                        %more off            
                                                    end; 
                                                end
                                            case 'cd'
                                                [f picpath]=uigetfile('*.*','Pick any file in Directory');      
                                                cd (picpath)
                                                dlmwrite([piclistdir 'picdir.txt'],picpath,'')
                                                dlmwrite([piclistdir 'piclist.txt'],'','')
                                            case 's' % Show list
                                                clc
                                                %more on
                                                disp(char(list))
                                                input ('Press ENTER');
                                            case 'ls'
                                                ls
                                                disp('Press ENTER'); pause
                                            case ''
                                                clc; 
                                                if ~(isempty(list)); exit=1; end % more off; disp(char(list)); more on;   
                                            case 'd'
                                                % more on
                                                dir; disp('Press ENTER'); pause
                                            case 'c'
                                                nn=0;
                                                c=input('Omit if it contains string - type string (ENTER=abort)\n\n','s');
                                                if ~(isempty(c));             
                                                    nn=1; list2={};
                                                    for j=1:length(list);           
                                                        if isempty(findstr(c,list{j}));nn=nn+1;list2(nn)=list(j);end
                                                    end
                                                    dlmwrite([piclistdir 'piclist.txt'],char(list2{:}),'')
                                                end
                                            case 'cc'
                                                c=input('Include if it contains string - type string (ENTER=abort)\n\n','s');
                                                if ~(isempty(c)); 
                                                    nn=1;list2={};
                                                    for j=1:length(list);
                                                        if findstr(c,list{j}); list2(nn)=list(j); nn=nn+1; end
                                                    end
                                                    dlmwrite([piclistdir 'piclist.txt'],char(list2{:}),'')
                                                end
                                            case 'sk'
                                                inp=input('Take how many, skip how many? (ENTER= 1 1)\n\n','s');
                                                [n1 n2]=strtok(inp,' ');
                                                if (isempty (n1)); n1='1'; n2='1';end
                                                nn=0; n1=str2num(n1); n2=str2num(n2);list2={};     
                                                for j=1:n1+n2:size(list,1)
                                                    %list2(end+1:end+n1)=char(list(j:j+n1)); % Can't make this work!
                                                    for k=1:n1
                                                        nn=nn+1;
                                                        try;list2(nn)=list(j+k-1);   
                                                        catch;nn=nn-1;end
                                                    end   
                                                end
                                                dlmwrite([piclistdir 'piclist.txt'],char(list2{:}),'')
                                            case 'x'
                                                list=[]; dlmwrite([piclistdir 'piclist.txt'],list,'')
                                            case 'z' % RGB
                                                rlist=getappdata(0,'fbr'); glist=getappdata(0,'fbg'); blist=getappdata(0,'fbb');
                                                disp([rlist glist blist])
                                                if isempty(rlist) disp('RED is empty'); end
                                                if isempty(glist) disp('GREEN is empty'); end
                                                if isempty(blist) disp('BLUE is empty'); end
                                                fb=input('Which framebuffer? (r,g, or b)\n\n','s')
                                                if ~isempty(fb); fb=['fb' fb]; setappdata(0,fb,list); end
                                            case 'e'
                                                edit ([piclistdir 'piclist.txt'])
                                                input ('Press ENTER when done','s')            
                                            case 'b'
                                                a=dir([picdir '*.tif']); 
                                                a=[a;dir([picdir '*.jpg'])]; 
                                                b={a.name};
                                                for j=1:size(b,2); % base name
                                                    x=find(b{j}=='.');    
                                                    if (size(x,2)>1) % strip off last two fields 
                                                        place=x(size(x,2)-1)-1; % (e.g., 010612.001.tif -> 010612)
                                                        p2=x(size(x,2)); % up to last field
                                                        b{j}=b{j}(1:place); % c{j}=[ ' - ' b{j}(p2+1:end)]; % b{j}=(strtok(c(j,:),'.'));  
                                                    end
                                                end
                                                basenames=unique(b) ;  % CELL array, for CHAR use f=unique(b,'rows')
                                                disp('TIF & JPG base names: ');lst='';
                                                for j=1:size(basenames,2); 
                                                    lst=[lst ' ' char(basenames{j})]; 
                                                    disp(['			' char(basenames{j})]); 
                                                end 
                                                input('Press ENTER')
                                            otherwise            
                                                %if (isempty(findstr('*',inp))); inp=[inp '*'];end
                                                structlist=dir([picpath inp]); celllist={structlist.name}; 
                                                celllist=celllist'; % charlist2=zeros(size(structlist,1),1);
                                                % for j=1:size(structlist,1)
                                                %  a=[picpath celllist{j}]; celllist(j)={a};
                                                % end
                                                %list=unique([list; celllist]);
                                                list=[list; celllist];
                                                charlist=sortrows(char(list));
                                                dlmwrite([piclistdir 'piclist.txt'],charlist,''); list=charlist;
                                                % does directory (wd) end with '\'? 
                                                a=find(wd=='\'); if ~isempty(a); if a(end) ~= size(wd,2); wd=[wd '\']; end; end
                                                dlmwrite([piclistdir 'picdir.txt'],wd,'');
                                            end % switch inp
                                        end % while exit==0
                                        
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        %%%%%%%%%%%%%%%%%%%%%%%% BBGETAPPDATAS %%%%%%%%%%%%%%%%%%%%%%%%%
                                        function varargout = bbgetappdatas(handle,names)
                                        % BBGETAPPDATAS: For getting multiple application-defined data
                                        % values. The MatLab command getappdata (no 's' on end) accepts only
                                        % one datum - e.g., c=getappdata(gcf,'color'). With
                                        % bbgetappdatas ('s' on end), multiple names can be specified and
                                        % their values obtained in a single command.
                                        % Example:
                                        %  names={'gain' 'offset' 'color'};
                                        %  [g o c]=bbgetappdatas(gcf,names)
                                        %
                                        % See also bbsetappdatas
                                        
                                        if ~isa(names,'cell')
                                            names = {names};
                                        end
                                        
                                        for i = 1:length(names)
                                            varargout{i} =getappdata(handle,names{i});
                                        end
                                        
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        %%%%%%%%%%%%%%%%%%% BBSETAPPDATAS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        function bbsetappdatas(handle,names,values)
                                        % BBSETAPPDATAS: For setting multiple application-defined data
                                        % pairs. The MatLab command setappdata (no 's' on end) accepts only
                                        % one data pair - e.g., setappdata(gcf,'color',c). With
                                        % bbsetappdatas ('s' on end), multiple names and their corresponding
                                        % values, placed in two cell arrays, can be set with a single
                                        % command. Example:
                                        %  names={'gain' 'offset' 'color'}; % names in one cell array
                                        %  g=2; o=1; c='blue';
                                        %  values={g o c};   % corresponding values in another cell array
                                        % bbsetappdatas(gcf,names,values)
                                        %
                                        % See also bbgetappdatas
                                        
                                        if ~isa(names,'cell')
                                            names = {names};
                                        end
                                        
                                        if ~isa(values,'cell')
                                            values = {values};
                                        end
                                        
                                        for i = 1:length(names)
                                            setappdata(handle,names{i},values{i})
                                        end
                                        
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        %%%%%%%%%%%%%%%%%%%%%%%%% BBGETCURPT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
                                        
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        function bbcolor(varargin)   %     BBCOLOR
                                        % BBCOLOR: For pseudocoloring images. Red, green, and blue components
                                        % can be changed independently and interactively. Color luts can be loaded 
                                        % from a menu. Custom luts can be saved.
                                        
                                        homedir=getappdata(0,'homedir');
                                        source=[getappdata(0,'source') ' bbcolor'];
                                        lutdir=[homedir 'color/'];
                                        disp(varargin)
                                        switch (nargin)               
                                            case 0
                                                %dbstop if error %if (nargin==2)
                                                hfig=gcf; hax=gca; caller=hfig;
                                                callpos=get(hfig,'position');            
                                                rgb=colormap;
                                                mapname=getappdata(hfig,'mapname');
                                                if (isempty(mapname));                 
                                                    colormap gray(256)
                                                    mapname='gray';
                                                end
                                                reload=0;
                                                try; colormenu=(sort(textread('lutlist.txt','%s'))); 
                                                    a=size(colormenu,1); if a<2; reload=1; end 
                                                catch; reload=1; end
                                                reload=1;
                                                if reload
                                                    a=dir([lutdir '*.lut']); colormenu=(char(sort({a.name}))); 
                                                    dlmwrite('lutlist.txt',colormenu,'');
                                                    colormenu=(sort(textread('lutlist.txt','%s')));
                                                end
                                                
                                                hcfig=findobj(0,'tag',num2str(hfig));
                                                if ~isempty(hcfig); delete(hcfig); end 
                                                hcfig=figure('tag',num2str(hfig),'visible','off');  
                                                hcax=axes('tag','hrgbax');
                                                figure(hcfig)
                                                setappdata(hcfig,'colormenu',colormenu);
                                                setappdata(hcfig,'rgb',rgb); 
                                                setappdata(hcfig,'rgb0',rgb);
                                                x0=callpos(1); y0=max(10,callpos(2)-300);
                                                set(hcfig,'position',[x0 y0 400 200],...
                                                    'WindowButtonDownFcn', [source ' buttondown'],...
                                                    'WindowButtonMotionFcn','',...
                                                    'WindowButtonUpFcn', '',...
                                                    'userdata','normal',...
                                                    'keypressfcn',[source ' keypress'],...  
                                                    'doublebuffer','on');
                                                sz=size(rgb,1);
                                                set(gca,'tag','hrgbax',...
                                                    'position',[.2 .25 .75 .75],... % 'yticklabel','','xticklabel','',...
                                                    'xlim',[-1 sz+1],'ylim',[-.05 1.05]);
                                                jj=get(hcfig,'position');
                                                xfac=jj(3); yfac=jj(4); umode='normalized';
                                                fs=1; % fontsize
                                                
                                                % ***************************** RADIOBUTTONS             
                                                
                                                uicontrol('style','radiobutton','tag','redbutton',...
                                                    'fontsize',fs,'units',umode,...
                                                    'string','red','position',[0/xfac 150/yfac 50/xfac 20/yfac]);
                                                uicontrol('style','radiobutton','tag','greenbutton',...
                                                    'fontsize',fs,'units',umode,...   
                                                    'callback',[source ' greenbutton'],...
                                                    'string','green','position',[0/xfac 120/yfac 50/xfac 20/yfac]);  
                                                uicontrol('style','radiobutton','tag','bluebutton',...
                                                    'fontsize',fs,'units',umode,...
                                                    'callback',[source ' bluebutton'],...
                                                    'string','blue','position',[0/xfac 90/yfac 50/xfac 20/yfac]);  
                                                
                                                %                  %%%%%%%%%%%% COLORMAP NAME
                                                uicontrol('tag','mapname','style','text',...        
                                                    'fontsize',fs,'units',umode,...
                                                    'position',[0 50/yfac 70/xfac 15/yfac],...
                                                    'string',mapname,'tooltipstring',mapname);
                                                %                              %%%%%%%%% INTERP STEP SIZE   
                                                smin=2; smax=64;stmin=1/63;stmax=8/63;step0=24;
                                                uicontrol('style','slider','tag','stepslider','callback',[source ' step'],...
                                                    'fontsize',fs,'units',umode,...
                                                    'position',[0 0 70/xfac 20/yfac],...
                                                    'min',smin,'max',smax','sliderstep',[stmin stmax],'value',step0,...
                                                    'tooltipstring',['step ' num2str(step0)]);
                                                
                                                %						%%%%%%% COLORMAP POPUP
                                                a=mapname; if length(a)<4; a=[a '.lut']; end; len=length(a);
                                                if ~strcmp('.lut',a(len-3:len)); a=[a '.lut']; end
                                                nn=find(strcmp(colormenu,a)); if (isempty(nn)); nn=1;end
                                                str=''; for j=1:length(colormenu); str=[str colormenu{j} '|']; end
                                                uicontrol('style','popup','tag','hpopup',...
                                                    'fontsize',fs,'units',umode,...
                                                    'position', [80/xfac 30/yfac 70/xfac 20/yfac],...
                                                    'callback',[source ' colormappopup'],...
                                                    'string', str,'value',nn);   
                                                %						%%%%%%%%%%% COLORMAP SLIDER
                                                smin=1;smax=length(colormenu);minstep=1/(max(1,smax-1));maxstep=min(1,5*minstep);
                                                uicontrol('style','slider','tag','cmenuslider',...
                                                    'fontsize',fs,'units',umode,...
                                                    'callback',[source ' colormapslider'],...
                                                    'position',[0 30/yfac 70/xfac 20/yfac],'min',smin,'max',smax,...
                                                    'sliderstep',[minstep maxstep],...
                                                    'tooltipstring',colormenu{1},'value',nn); 
                                                %                              %%%%%%%% EDIT COLORMENU LIST
                                                uicontrol('tag','editcolorlist',...
                                                    'fontsize',fs,'units',umode,...    
                                                    'position',[80/xfac 0 30/xfac 20/yfac],...
                                                    'string','edit','callback',[source ' editcolorlist']);
                                                
                                                %                              %%%%%%%% REVERSE COLOR
                                                uicontrol('tag','revcolor',...
                                                    'fontsize',fs,'units',umode,...    
                                                    'position',[120/xfac 0 30/xfac 20/yfac],...
                                                    'string','rev','callback',[source ' revcolor']);
                                                
                                                %                              %%%%%%%% SAVE
                                                uicontrol('tag','save',...
                                                    'fontsize',fs,'units',umode,...    
                                                    'position',[160/xfac 0 30/xfac 20/yfac],...
                                                    'string','save','callback',[source ' save']);
                                                
                                                %                              %%%%%%%%% MAP TO ALL FIGURES
                                                uicontrol( 'fontsize',fs,'units',umode,...
                                                    'position',[200/xfac 0 30/xfac 20/yfac],'string','->all',...
                                                    'callback',[source ' allfigs']);
                                                
                                                %                              %%%%%%%%% QUIT
                                                uicontrol( 'fontsize',fs,'units',umode,...
                                                    'position',[260/xfac 0 30/xfac 20/yfac],'string','close',...
                                                    'callback',[source ' quit']);   
                                                %                  %%%%%%% GAMMA SLIDER
                                                smin=.1;smax=3;minstep=.01;maxstep=.05;
                                                uicontrol('style','slider','tag','gammaslider','callback',[source ' gamma'],...
                                                    'fontsize',fs,'units',umode,...    
                                                    'position',[160/xfac 30/yfac 70/xfac 20/yfac],'min',smin,'max',smax,...
                                                    'sliderstep',[minstep maxstep],...
                                                    'tooltipstring',['Gamma ' num2str(1)],'value',1);
                                                
                                                % *************
                                                rgb=plotrgb(rgb);
                                                
                                            case 1
                                                lutdir=[homedir 'color/'];
                                                hcfig=gcf;hax=gca;            
                                                rgb=getappdata(hcfig,'rgb');
                                                colormenu=(getappdata(hcfig,'colormenu')); 
                                                mapname=getappdata(hcfig,'mapname');
                                                caller=str2num(get(hcfig,'tag'));
                                                sz=size(rgb,1);
                                                set(hcfig,'interruptible','off','busyaction','queue')
                                                switch varargin{:}
                                                    case 'allfigs'
                                                        allfig=findobj(0,'type','figure'); 
                                                        for jj=1:size(allfig,1)
                                                            hfig=allfig(jj,1);
                                                            figure(hfig)
                                                            colormap(rgb)
                                                            setappdata(hfig,'mapname',mapname)
                                                        end
                                                        
                                                    case 'keyboard'
                                                        keyboard
                                                    case 'gamma'
                                                        hgs=findobj(hcfig,'tag','gammaslider');
                                                        gamma=get(hgs,'value');
                                                        set(hgs,'tooltipstring',['gamma ' num2str(gamma)]);
                                                        rgb=plotrgb(rgb);
                                                    case 'colormappopup'   
                                                        nn=round(get(findobj(hcfig,'tag','hpopup'),'value'));
                                                        mapname=colormenu{nn};
                                                        rgb=load([lutdir mapname]);
                                                        setappdata(hcfig,'rgb',rgb);setappdata(hcfig,'mapname',mapname);
                                                        for j=1:3; rgb(:,j)=min(1,max(0,rgb(:,j)));end
                                                        set(findobj(hcfig,'tag','gammaslider'),'value',1);
                                                        set(findobj(hcfig,'tag','mapname'),'string',mapname);
                                                        setappdata(hcfig,'mapname',mapname);
                                                        setappdata(caller,'mapname',mapname);
                                                        set(findobj(hcfig,'tag','cmenuslider'),'value',nn)
                                                        rgb=plotrgb(rgb);
                                                    case 'colormapslider' 
                                                        nn=round(get(findobj(hcfig,'tag','cmenuslider'),'value'));
                                                        set(findobj(hcfig,'tag','cmenuslider'),'tooltipstring',colormenu{nn}) 
                                                        mapname=colormenu{nn};
                                                        rgb=load(mapname);
                                                        setappdata(hcfig,'rgb',rgb);
                                                        setappdata(hcfig,'mapname',mapname);
                                                        setappdata(caller,'mapname',mapname);
                                                        set(findobj(hcfig,'tag','gammaslider'),'value',1);
                                                        set(findobj(hcfig,'tag','mapname'),'string',mapname);setappdata(gcf,'mapname',mapname);
                                                        set(findobj(hcfig,'tag','hpopup'),'value',nn);
                                                        rgb=plotrgb(rgb);
                                                    case 'editcolorlist'
                                                        uicontrol('tag','editcolorlistcontinue','callback',[source ' editcolorlist2'],...
                                                            'position',[0 0 240 30],...
                                                            'string',['Edit list, Save if changed. Then Click here'],...
                                                            'tooltipstring','Continue after edit',...
                                                            'backgroundcolor',[1 .8 .8]);          
                                                        drawnow
                                                        edit ([lutdir 'lutlist.txt']);
                                                    case 'editcolorlist2'
                                                        hh=findobj(0,'tag','editcolorlistcontinue'); delete(hh)
                                                        colormenu=sort(textread([lutdir 'lutlist.txt'],'%s')); reload=0;
                                                        try; a=size(colormenu,1); if a<2; reload=1; end
                                                        catch; reload=1; end
                                                        if reload
                                                            a=dir([lutdir '*.lut']); colormenu=(char(sort({a.name}))); 
                                                            dlmwrite('lutlist.txt',colormenu,'');
                                                            colormenu=(sort(textread('lutlist.txt','%s')));
                                                            %eval([source ' editcolorlist'])                    
                                                        end
                                                        delete(hcfig)
                                                        eval('bbcolor')
                                                        
                                                    case 'revcolor'
                                                        rgb=1-rgb;
                                                        setappdata(gcf,'rgb',rgb)
                                                        rgb=plotrgb(rgb);
                                                    case 'keypress'
                                                        k=get(gcf,'currentcharacter');
                                                        redok=get([findobj(hcfig,'tag','redbutton')],'value');
                                                        greenok=get([findobj(hcfig,'tag','greenbutton')],'value');
                                                        blueok=get([findobj(hcfig,'tag','bluebutton')],'value');
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
                                                            step=round(get(findobj(hcfig,'tag','stepslider'),'value'));
                                                            set(findobj(hcfig,'tag','stepslider'),'tooltipstring',['step ' num2str(step)]);
                                                        case 'buttondown'
                                                            button=get(gcf,'selectiontype');
                                                            set(gcf,'userdata',button,...
                                                                'WindowButtonMotionFcn', [source ' buttonmotion'],...
                                                                'WindowButtonUpFcn', [source ' buttonup'])
                                                        case 'buttonup'
                                                            % set(hcfig,'interruptible','off','busyaction','queue');
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
                                                            [indexx,yy] = bbgetcurpt(findobj(hcfig,'tag','hrgbax'));
                                                            indexx=round(indexx);
                                                            oob=(indexx<1)+sz*(indexx >sz); % out-of-bounds
                                                            button=get(gcf,'userdata');
                                                            mode='spline'; % 'cubic'; % 'spline'; % 'linear';
                                                            switch button
                                                                case 'normal'
                                                                    step=round(get(findobj(hcfig,'tag','stepslider'),'value'));
                                                                    indexmin=max(1,indexx-step); indexmax=min(sz,indexx+step);
                                                                    xi=[1:indexmax-indexmin+1]'; step2= round(size(xi,1)/2);
                                                                    x=[1 step2 size(xi,1)];
                                                                    if get(findobj(hcfig,'tag','redbutton'),'value'); 
                                                                        if (oob); rgb(oob,1)=yy;end
                                                                        yr=[rgb(indexmin,1) yy rgb(indexmax,1)];
                                                                        rgb(indexmin:indexmax,1)=interp1(x',yr',xi,mode);
                                                                    end   
                                                                    if get(findobj(hcfig,'tag','greenbutton'),'value'); 
                                                                        if (oob); rgb(oob,2)=yy;end
                                                                        yg=[rgb(indexmin,2) yy rgb(indexmax,2)];
                                                                        rgb(indexmin:indexmax,2)=interp1(x',yg',xi,mode);
                                                                    end   
                                                                    if get(findobj(hcfig,'tag','bluebutton'),'value'); 
                                                                        if (oob); rgb(oob,3)=yy;end
                                                                        yb=[rgb(indexmin,3) yy rgb(indexmax,3)];
                                                                        rgb(indexmin:indexmax,3)=interp1(x',yb',xi,mode);
                                                                    end
                                                                    
                                                                case 'alt'
                                                                    redok=get([findobj(hcfig,'tag','redbutton')],'value');
                                                                    greenok=get([findobj(hcfig,'tag','greenbutton')],'value');
                                                                    blueok=get([findobj(hcfig,'tag','bluebutton')],'value');
                                                                    if (redok);rgb(indexx,1)=yy;end
                                                                    if (greenok);rgb(indexx,2)=yy;end
                                                                    if (blueok);rgb(indexx,3)=yy;end
                                                                    
                                                                case 'open'
                                                                end      
                                                                %set(hcfig,'interruptible','off','busyaction','queue')
                                                                rgb=plotrgb(rgb);
                                                            case 'save'
                                                                dirx=pwd;
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
                                                                    set(findobj(hcfig,'tag','mapname'),'string',mapname);
                                                                    setappdata(caller,'mapname',mapname);
                                                                    set (findobj(hcfig,'tag','hpopup'),'string',str);
                                                                end
                                                                cd (dirx)
                                                            case 'quit'
                                                                hh=str2num(get(gcf,'tag'));
                                                                setappdata(caller,'mapname',mapname);
                                                                %set(hcfig,'userdata','')
                                                                close(hcfig);     
                                                                set(0,'currentfigure',hh);
                                                            end % nargin=1 callbacks
                                                            
                                                        end % nargin
                                                        
                                                        %%%%%%%%%%%%%%%%%%%%%%%%%% PLOT RGB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                        function rgb=plotrgb(rgb) % Plots rgb map and applies it to bbpv figure
                                                        hfig=gcf;        
                                                        gamma=get(findobj(hfig,'tag','gammaslider'),'value');
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
                                                        %set(gca,'tag','hrgbax')
                                                        set(gca,'tag','hrgbax','position',[.2 .25 .75 .75],...
                                                            'yticklabel','','xticklabel','',...
                                                            'xlim',[-1 sz+1],'ylim',[-.05 1.05]);
                                                        hh=str2num(get(hfig,'tag'));
                                                        set(0,'currentfigure',hh);
                                                        colormap(rgb);
                                                        figure(hfig);
                                                        setappdata(hfig,'rgb',rgb); 
                                                        drawnow  
                                                        
                                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% axiscapture %%%%%%%%%%%%%%%
                                                        function axiscapture2
                                                        F = getframe;
                                                        [file,d] = uiputfile('*.*','Save the image');
                                                        
                                                        % if (sum((a(b-3:b)=='.tif'))==4)
                                                        
                                                        %if length(f)<=4
                                                        file = [file,'.tif'];
                                                        %end
                                                        %if ~strcmp(file(end-3),'.')
                                                        %   file = [file,'.tif'];
                                                        %end
                                                        % imwrite(F.cdata,[d,file],'compression','none')
                                                        imwrite(F.cdata,[d,file]) % ,'compression','none')
                                                        
                                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% bbgetpts %%%%%%%%%%%%%%%
                                                        
                                                        function bbgetpts(varargin)
                                                        % BBGETPTS: For picking points. 
                                                        source=[getappdata(0,'source') ' bbgetpts'];
                                                        switch (nargin)      
                                                            case 0
                                                                hax=gca; hfig=gcf; % get(hax,'parent');
                                                                him=findobj(get(hax,'children'),'type','image');
                                                                set(0,'currentfigure',hfig);
                                                                disp ('Left button picks, right button ends (without picking)')
                                                                ht0=size(get(him,'Cdata')); ht0=ht0(1);
                                                                set(hfig, 'Pointer','circle',...
                                                                    'WindowButtonDownFcn','',...
                                                                    'WindowButtonMotionFcn','',...
                                                                    'WindowButtonupFcn','');
                                                                set(him,'buttondownfcn',[source ' down']);
                                                                setappdata(hfig,'xdata',[]);setappdata(hfig,'ydata',[])
                                                                setappdata(hfig,'labelcounter',0);
                                                                drawnow   
                                                            case 1
                                                                hfig=gcf;hax=gca;
                                                                him=findobj(get(hax,'children'),'type','image');
                                                                set(0,'currentfigure',hfig);
                                                                x=getappdata(hfig,'xdata');y=getappdata(hfig,'ydata');   
                                                                nn=getappdata(hfig,'labelcounter');
                                                                pickcolor=getappdata(hfig,'pickcolor');
                                                                if isempty(pickcolor); pickcolor='white';end
                                                                picknum=getappdata(hfig,'picknum');picknum=picknum+1;setappdata(hfig,'picknum',picknum)
                                                                switch(varargin{:})  
                                                                    case 'down'
                                                                        button=get(hfig,'selectiontype');
                                                                        if (strcmp(button,'normal'))
                                                                            [xnow ynow] = bbgetcurpt(gca);
                                                                            xnow=round(xnow); ynow=round(ynow);
                                                                            x=[x xnow]; y=[y ynow];
                                                                            %text (xnow,ynow,num2str(nn+1),'color','red','horizontalalignment','center')
                                                                            rad=getappdata(hfig,'roirad'); if isempty(rad); rad=3; end
                                                                            xmin=xnow-rad-.5; ymin=ynow-rad-.5; wd=2*rad+1; ht=wd;
                                                                            rectangle ('position',[xmin ymin wd ht],'edgecolor',pickcolor)
                                                                            text('position',[xnow ynow],'string',num2str(picknum),...
                                                                                'color',pickcolor,'fontsize',12,'horizontalalignment','center');
                                                                            setappdata(hfig,'labelcounter',nn+1);
                                                                            setappdata(hfig,'xdata',x);setappdata(hfig,'ydata',y);   
                                                                        elseif (strcmp(button,'alt')); % right button    
                                                                            set(him,'buttondownfcn','');
                                                                            set(hfig,'userdata','','pointer','arrow');
                                                                        end
                                                                end   
                                                            end
                                                            
                                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                            %%%%%%%%%%%%%%%%%%%%% bbalign %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                            function e=bbalign(jj,xyalign,Movi,dmax);
                                                            
                                                            if isrgb(Movi); c=double(Movi(:,:,:,jj));
                                                            else c=double(Movi(:,:,jj)); end
                                                            szy=size(c,1); szx=size(c,2);
                                                            dx=xyalign(jj,1);  dx=min(abs(dx),dmax)*sign(dx);
                                                            dy=xyalign(jj,2); dy=min(abs(dy),dmax)*sign(dy);
                                                            yl2=1*(dy>=0)+(-dy+1)*(dy<0); yu2=szy*(dy<=0)+(szy-dy)*(dy>0);
                                                            xl2=1*(dx>=0)+(-dx+1)*(dx<0); xu2=szx*(dx<=0)+(szx-dx)*(dx>0);
                                                            if isrgb(Movi); d=c(yl2:yu2,xl2:xu2,:); zz=zeros(szy,szx,3);
                                                            else d=c(yl2:yu2,xl2:xu2); 
                                                                bkg=round(sum(d(:))/prod(size(d))); % background 
                                                                zz=zeros(szy,szx); zz=zz+bkg; end % cutout region to move
                                                            xx2=1*(dx<=0)+(dx+1)*(dx>0); yy2=1*(dy<=0)+(dy+1)*(dy>0); 
                                                            e=bbblock(xx2,yy2,zz,d);
                                                            
                                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%% smoothn %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                            
                                                            function Y = smoothn(X,sz,filt,std)
                                                            
                                                            %SMOOTHN Smooth N-D data
                                                            %   Y = SMOOTHN(X, SIZE) smooths input data X. The smoothed data is
                                                            %       retuirned in Y. SIZE sets the size of the convolution kernel
                                                            %       such that LENGTH(SIZE) = NDIMS(X)
                                                            %
                                                            %   Y = SMOOTHN(X, SIZE, FILTER) Filter can be 'gaussian' or 'box' (default)
                                                            %       and determines the convolution kernel.
                                                            %
                                                            %   Y = SMOOTHN(X, SIZE, FILTER, STD) STD is a vector of standard deviations 
                                                            %       one for each dimension, when filter is 'gaussian' (default is 0.65)
                                                            
                                                            %     $Author: ganil $
                                                            %     $Date: 2001/09/17 18:54:39 $
                                                            %     $Revision: 1.1 $
                                                            %     $State: Exp $
                                                            
                                                            if nargin == 2,
                                                                filt = 'b';
                                                            elseif nargin == 3,
                                                                std = 0.65;
                                                            elseif nargin>4 | nargin<2
                                                                error('Wrong number of input arguments.');
                                                            end
                                                            
                                                            % check the correctness of sz
                                                            if ndims(sz) > 2 | min(size(sz)) ~= 1
                                                                error('SIZE must be a vector');
                                                            elseif length(sz) == 1
                                                                sz = repmat(sz,ndims(X));
                                                            elseif ndims(X) ~= length(sz)
                                                                error('SIZE must be a vector of length equal to the dimensionality of X');
                                                            end
                                                            
                                                            % check the correctness of std
                                                            if filt(1) == 'g'
                                                                if length(std) == 1
                                                                    std = std*ones(ndims(X),1);
                                                                elseif ndims(X) ~= length(std)
                                                                    error('STD must be a vector of length equal to the dimensionality of X');
                                                                end
                                                                std = std(:)';
                                                            end
                                                            
                                                            sz = sz(:)';
                                                            
                                                            % check for appropriate size
                                                            padSize = (sz-1)/2;
                                                            if ~isequal(padSize, floor(padSize)) | any(padSize<0)
                                                                error('All elements of SIZE must be odd integers >= 1.');
                                                            end
                                                            
                                                            % generate the convolution kernel based on the choice of the filter
                                                            filt = lower(filt);
                                                            if (filt(1) == 'b')
                                                                smooth = ones(sz)/prod(sz); % box filter in N-D
                                                            elseif (filt(1) == 'g')
                                                                smooth = ndgaussian(padSize,std); % a gaussian filter in N-D
                                                            else
                                                                error('Unknown filter');
                                                            end
                                                            
                                                            
                                                            % pad the data
                                                            X = padreplicate(X,padSize);
                                                            
                                                            % perform the convolution
                                                            Y = convn(X,smooth,'valid');
                                                            
                                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                            
                                                            function h = ndgaussian(siz,std)
                                                            
                                                            % Calculate a non-symmetric ND gaussian. Note that STD is scaled to the
                                                            % sizes in SIZ as STD = STD.*SIZ
                                                            
                                                            
                                                            ndim = length(siz);
                                                            sizd = cell(ndim,1);
                                                            
                                                            for i = 1:ndim
                                                                sizd{i} = -siz(i):siz(i);
                                                            end
                                                            
                                                            grid = gridnd(sizd);
                                                            std = reshape(std.*siz,[ones(1,ndim) ndim]);
                                                            std(find(siz==0)) = 1; % no smoothing along these dimensions as siz = 0
                                                            std = repmat(std,2*siz+1);
                                                            
                                                            
                                                            h = exp(-sum((grid.*grid)./(2*std.*std),ndim+1));
                                                            h = h/sum(h(:));
                                                            
                                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                            
                                                            function argout = gridnd(argin)
                                                            
                                                            % exactly the same as ndgrid but it accepts only one input argument of 
                                                            % type cell and a single output array
                                                            
                                                            nin = length(argin);
                                                            nout = nin;
                                                            
                                                            for i=nin:-1:1,
                                                                argin{i} = full(argin{i}); % Make sure everything is full
                                                                siz(i) = prod(size(argin{i}));
                                                            end
                                                            if length(siz)<nout, siz = [siz ones(1,nout-length(siz))]; end
                                                            
                                                            argout = [];
                                                            for i=1:nout,
                                                                x = argin{i}(:); % Extract and reshape as a vector.
                                                                s = siz; s(i) = []; % Remove i-th dimension
                                                                x = reshape(x(:,ones(1,prod(s))),[length(x) s]); % Expand x
                                                                x = permute(x,[2:i 1 i+1:nout]);% Permute to i'th dimension
                                                                argout = cat(nin+1,argout,x);% Concatenate to the output 
                                                            end
                                                            
                                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                            
                                                            function b=padreplicate(a, padSize)
                                                            %Pad an array by replicating values.
                                                            numDims = length(padSize);
                                                            idx = cell(numDims,1);
                                                            for k = 1:numDims
                                                                M = size(a,k);
                                                                onesVector = ones(1,padSize(k));
                                                                idx{k} = [onesVector 1:M M*onesVector];
                                                            end
                                                            
                                                            b = a(idx{:});
                                                            
                                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                            %%%%%%%%%%%%%%%%%%%%%%%% setup %%%%%%%%%%%%%%%
                                                            function setup
                                                            s=which('bbpv');
                                                            %source=getappdata(0,'source');
                                                            %s=eval(['which(' source ')']);
                                                            homedir=s(1:end-6);
                                                            % under homedir directory put directory 'color' (for luts)
                                                            setappdata(0,'homedir',homedir)
                                                            cd (homedir)
                                                            try
                                                                cd ('color')
                                                            catch    
                                                                disp(['Setting up directory ' homedir 'color with default color luts...'])
                                                                mkdir('color')
                                                                cd ('color')
                                                                list={'autumn';'bone'; 'colorcube'; 'cool'; 'copper'; 'flag'; ,...
                                                                        'gray'; 'hot'; 'hsv'; 'jet'; 'lines'; 'pink'; 'prism'; ,...
                                                                        'spring'; 'summer'; 'white'; 'winter'};
                                                                for j=1:size(list,1); disp(list{j})
                                                                    a=[list{j} '(256)']; map=eval(a); save([list{j} '.lut'],'map', '-ASCII') 
                                                                end        
                                                            end
                                                            cd (homedir)
                                                            format compact; % no double spacing
                                                            format short g;
                                                            % iptsetpref('imshowborder','tight'); % no border around images
                                                            more off
                                                            pathold = path;
                                                            pathnew = homedir;
                                                            if exist('matdraw')==7; pathnew=[pathnew ';' pathnew 'matdraw']; end
                                                            path(pathnew,pathold);  
                                                            %clear
                                                            %dbclear all
                                                            clc
                                                            
                                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BBPASTE %%%%%%%%%%%%%%%%%%%
                                                            function c=bbpaste(a,b) % 
                                                            
                                                            val=-1.1111; % value of unfilled cells    
                                                            rows=max(size(a,1), size(b,1)); cols=size(a,2)+size(b,2);
                                                            c=zeros(rows,cols); c=c+val;
                                                            c(1:size(a,1),1:size(a,2))=a;
                                                            c(1:size(b,1),size(a,2)+1:end)=b;
                                                            
                                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%% GETSTREL %%%%%%%%%%%%%%%%%%%%%%
                                                            
                                                            function se=getstrel % get shape and size, then make structure element
                                                            lbkg=getappdata(0,'lbkg'); 
                                                            if isempty(lbkg); lbkg={'disk' '4'}; setappdata(0,'lbkg',lbkg); end            
                                                            prompt={'Strl shape (disk,rectangle,square,diamond,octagon)',...
                                                                    'Strl size (~radius of object of interest)'};
                                                            title='Background variables'; lineno=1;      
                                                            def=lbkg;
                                                            sevar=inputdlg(prompt,title,lineno,def);
                                                            if ~isempty(sevar); 
                                                                setappdata(0,'lbkg',sevar)
                                                                seshape=sevar{1}; sesz=str2num(sevar{2});                
                                                                se=strel(seshape,sesz);
                                                            else
                                                                se=[];
                                                            end
                                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%% BBHISTO %%%%%%%%%%%%%%%%%%%%%%
                                                            
                                                            function a=bbhisto(z,varargin) % data in z; bin width in varargin
                                                            % data: raw values in one column. Multiple columns gives 1 histogram/column
                                                            
                                                            nbins=10; mn=min(z(:)); mx=max(z(:));
                                                            if nargin>1; bw=varargin{:}; nbins=(mx-mn)/bw; else bw=(mx-mn)/nbins; end
                                                            b=zeros(nbins+1,size(z,2)); 
                                                            for c=1:size(z,2) % column of z
                                                                for r=1:size(z,1)
                                                                    if z(r,c)~=-1.1111;
                                                                        rr=floor((z(r,c)-mn)/bw)+1; 
                                                                        b(rr,c)=b(rr,c)+1;  end          
                                                                end
                                                            end    
                                                            b(2:end+1,:)=b; b(1,:)=0; b(end+1,:)=0;    
                                                            
                                                            for col=1:size(z,2)
                                                                rr=0; ccol=col+1;
                                                                for r=1:size(b,1)-1
                                                                    rr=rr+1;
                                                                    if col==1; x=mn+bw*(r-1); c(rr,1)=x; c(rr+1,1)=x; end
                                                                    c(rr,ccol)=b(r,col); rr=rr+1; c(rr,ccol)=b(r+1,col);
                                                                end
                                                            end    
                                                            
                                                            a=findobj(0,'tag','histogram'); if ~isempty(a); delete(a); end
                                                            hhistfig=figure ('tag','histogram','doublebuffer','on');
                                                            hold on; 
                                                            offsetfac=.006;
                                                            c0={'r' 'g' 'b'}; jitterx=offsetfac*(mx-mn); jittery=max(max(c(:,2:end)))*offsetfac;
                                                            for col=2:size(c,2)        
                                                                color=c0{rem(col-1,3)+3*~rem(col-1,3)}; xfac=jitterx*(col-1); yfac=jittery*(col-1);
                                                                plot(c(:,1)+xfac,c(:,col)+yfac,color)
                                                            end
                                                            
                                                            hdlg=msgbox('Click to continue','Histogram');
                                                            uiwait(hdlg); 
                                                            delete(hhistfig)
                                                            
                                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                            %%%%%%%%%%%%%%%%%% END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%