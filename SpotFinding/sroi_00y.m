function sroi_00y;

global movi rr xx yy filename chol b2 Movi3 pixel_size image_matrix
global list mapname b rows cols A q s ijj jjj r1
global alignsx alignsy rect fused not_fused hey hex counter xxes yyes

  hfig=gcf;
    button=get(hfig,'selectiontype');
        if (strcmp(button,'extend'))
         
       
        l=get(gca,'currentpoint')
        
        hex(ijj)=round(l(1));
        hey(ijj)=round(l(3));
        
        xes=[hex(ijj)-50 hex(ijj)+50 hex(ijj)+50 hex(ijj)-50 hex(ijj)-50];
        yes=[hey(ijj)-50 hey(ijj)-50 hey(ijj)+50 hey(ijj)+50 hey(ijj)-50];
        
        line(xes,yes,'color','g');   
        
        %figure; imagesc(movi(hey(ijj)-50:hey(ijj)+50,hex(ijj)-50:hex(ijj)+50,ijj));
           step; 

            
        elseif (strcmp(button,'alt'))

  l=get(gca,'currentpoint')
               
       
        alignsx(ijj)=round(l(1));
        alignsy(ijj)=round(l(3));
        line(alignsx,alignsy,'linestyle','none','markeredgecolor','y','marker','o','markersize',5,'markerfacecolor','c');  
        
        elseif (strcmp(button,'normal'))
            
            counter=1;
               xxes=[];
            yyes=[];
            set(gcf,'windowbuttonmotionfcn','sroi_motion');
            set(gcf,'windowbuttonupfcn','sroi_2');

            
            
   % 
        end;
        
            