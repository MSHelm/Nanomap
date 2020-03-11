function sroi_align;

global movi rows cols A d c xx yy zz iii bbb ccc ijj q s jjj r
hfig=gcf;
 himg=imagesc(movi(:,:,1),'tag','himg'); % hfs=findobj(hfig,'tag','frameslider'); hfss=findobj(hfig,'tag','figsizeslider');    hfig=gcf; hax=gca;
   % hfs=findobj(hfig,'tag','frameslider');
   % hffs=findobj(hfig,'tag','firstframeslider');
   % hlfs=findobj(hfig,'tag','lastframeslider');
   % himg=findobj(hfig,'tag','himg');
   % hpicname=findobj(hfig,'tag','picname');
   %     setappdata(hfig,'play',0); 
      
        %************ SET ALIGNMODE AND dd HERE ********************
        alignmode=1; % 1=align to previous; 2=align=first in list
        dd=25; % % size difference of larger window to scan
        % ***************************************************
        drawnow; 
        %set(himg,'cdata',movi(:,:,1)); %set(hfs,'value',1); 
        jmin=q;%round(get(hffs,'value'));
        jmax=s;%round(get(hlfs,'value'));
        %%%%%%%%%%% Align: set up 2 squares
        [pos1]=round(bbgetsquare);xl=pos1(1); yl=pos1(2);wd=pos1(3);ht=wd;
        rectangle('position',pos1,'edgecolor','b')
        sz0=size(movi(:,:,1)); szx=sz0(2); szy=sz0(1);% rows,cols
        Xl=max(1,xl-dd);Yl=max(1,yl-dd); 
        Xu=min(szx,xl+wd+dd); Yu=min(szy,yl+wd+dd);
        pos2=[Xl,Yl,Xu-Xl+1,Yu-Yl+1];
        rectangle('position',pos2,'edgecolor','b')
        drawnow  
        %%%%%%%%%%%% Align: Find best fit positions 
        xyalign(1,1)=0; xyalign(1,2)=0;
        if (alignmode==2); % align to first in list
            a=double(movi(yl:yl+ht,xl:xl+wd,jmin)); %  align square = first in list 
        end
        for jj=jmin+1:jmax
            disp (jmax-jj)
            if (alignmode==1);
                a=double(movi(yl:yl+ht,xl:xl+wd,jj-1)); %  align square = previous
            end
            mindiff0=1e12;
            for xx=Xl:Xu-wd
                for yy=Yl:Yu-ht
                    b=double(movi(yy:yy+ht,xx:xx+wd,jj)); % cutout to test
                    d1=(a-b).*(a-b);
                    d2=sum(sum(d1));
                    if (d2<mindiff0)
                        mindiff0=d2; xyalign(jj,1)=xl-xx; xyalign(jj,2)=yl-yy;
                    end
                end
            end  
            if (alignmode==1); % align to previous image in stack
                c=double(movi(:,:,jj));szy=size(c,1); szx=size(c,2);
                dx=xyalign(jj,1); dy=xyalign(jj,2);
                yl2=1*(dy>=0)+(-dy+1)*(dy<0); yu2=szy*(dy<=0)+(szy-dy)*(dy>0);
                xl2=1*(dx>=0)+(-dx+1)*(dx<0); xu2=szx*(dx<=0)+(szx-dx)*(dx>0);
                d=c(yl2:yu2,xl2:xu2); % cutout region to move
                xx2=1*(dx<=0)+(dx+1)*(dx>0); yy2=1*(dy<=0)+(dy+1)*(dy>0);
                e=bbblock(xx2,yy2,zeros(szy,szx),d);
                movi(:,:,jj)=uint16(e); set(himg,'cdata',movi(:,:,jj));         
            end   
        end
        if (alignmode==2); % align all to first in list
            for jj=jmin+1:jmax
                c=double(movi(:,:,jj));szy=size(c,1); szx=size(c,2);
                dx=xyalign(jj,1); dy=xyalign(jj,2);
                yl2=1*(dy>=0)+(-dy+1)*(dy<0); yu2=szy*(dy<=0)+(szy-dy)*(dy>0);
                xl2=1*(dx>=0)+(-dx+1)*(dx<0); xu2=szx*(dx<=0)+(szx-dx)*(dx>0);
                d=c(yl2:yu2,xl2:xu2); % cutout region to move
                xx2=1*(dx<=0)+(dx+1)*(dx>0); yy2=1*(dy<=0)+(dy+1)*(dy>0);
                e=bbblock(xx2,yy2,zeros(szy,szx),d);
                movi(:,:,jj)=uint16(e); set(himg,'cdata',movi(:,:,jj));         
            end
        end
        setappdata(hfig,'movi',movi);
        
        
        xx=[]; yy=[]; zz=[];
        
        save('new_movie.mat','movi');
       