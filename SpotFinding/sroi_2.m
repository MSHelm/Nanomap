function sroi_2

global counter xxes yyes ijj movi
global rr hex hey positioner alignsx alignsy pixel_size matrix filename switcher pos1 small_movi

set(gcf,'windowbuttonmotionfcn','sroi_3'); 
set(gcf,'windowbuttonupfcn','sroi_3'); 

line(yyes,xxes,'color','y');

    pols=roipoly(movi(:,:,ijj),yyes,xxes);

 
        
        ccc=find(pols==1);
        [x y]=ind2sub(size(pols),ccc);
        

        
       pos1(1)=min(x); pos1(2)=max(x); pos1(3)=min(y); pos1(4)=max(y);
       
       
       
       small_movi=[];
 siz=size(movi)
 for i=1:siz(3)
     i
     movib=movi(:,:,i);
     if i==1
         ccc=find(pols==0); movib(ccc)=0;
     end;
     small_movi(:,:,i)=movib(pos1(1):pos1(2),pos1(3):pos1(4));
 end;

  sroi_choose_region_autocorr_only;