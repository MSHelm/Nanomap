function sroi_00y;

global movi rr xx yy filename chol b2 Movi3 pixel_size image_matrix
global list mapname b rows cols A q s ijj jjj r1
global alignsx alignsy rect fused not_fused hey hex counter xxes yyes

  hfig=gcf;
    button=get(hfig,'selectiontype');
        if (strcmp(button,'extend'))
    
            
           
            % l=get(gca,'currentpoint')
               
%         alignsx(ijj)=round(l(1));
%         alignsy(ijj)=round(l(3));
%         line(alignsx,alignsy,'linestyle','none','markeredgecolor','y','ma
%         rker','o','markersize',5,'markerfacecolor','c');  
      elseif (strcmp(button,'alt'))

        l=get(gca,'currentpoint')
        
        hex=round(l(1));
        hey=round(l(3));
        
        xes=[hex-50 hex+50 hex+50 hex-50 hex-50];
        yes=[hey-50 hey-50 hey+50 hey+50 hey-50];
        
        line(xes,yes,'color','g');   
        
        %figure; imagesc(movi(hey(ijj)-50:hey(ijj)+50,hex(ijj)-50:hex(ijj)+50,ijj));
        
        elseif (strcmp(button,'normal'))
            
            counter=1;
               xxes=[];
            yyes=[];
            set(gcf,'windowbuttonmotionfcn','sroi_motion');
            set(gcf,'windowbuttonupfcn','sroi_2');
 
   % 
        end;
        
            