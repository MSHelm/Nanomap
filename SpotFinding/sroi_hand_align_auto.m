function sroi_hand_align; % Select a point holding the ctrl in the STED image, then select the "same" spot again holding ctrl in the 647nC image and press Hand align!

global list mapname b movi rows cols A xx yy zz iii bbb q s ijj jjj rr firstred olds inner_radius outer_radius matrix

global alx aly

sizeul=size(movi);

diffx=alx-100;
diffy=aly-100;


% there is no for loop needed, as just the STED image is aligned, or the
% fourth image .... i = 4
   i = 4;
      
   
   
   if diffx<0
       
       movi(:,1:sizeul(2)-abs(diffx),4)=movi(:,abs(diffx)+1:sizeul(2),4);
       movi(:,sizeul(2)-abs(diffx)+1:sizeul(2),4)=0;
       
   elseif diffx>0
       movi(:,1+abs(diffx):sizeul(2),4)=movi(:,1:sizeul(2)-abs(diffx),4);
       movi(:,1:abs(diffx),4)=0;
       
   end;
   
   
   if diffy<0
       
       movi(1:sizeul(2)-abs(diffy),:,4)=movi(abs(diffy)+1:sizeul(2),:,4);
       movi(sizeul(2)-abs(diffy)+1:sizeul(2),:,4)=0;
       
   elseif diffy>0
       movi(1+abs(diffy):sizeul(2),:,4)=movi(1:sizeul(2)-abs(diffy),:,4);
       movi(1:abs(diffy),:,4)=0;
       
   end;
   
   name=strcat(rr(1:numel(rr)-4),'.mat');
   save(name,'movi');
   
   
himg=image(movi(:,:,ijj),'cdatamapping','scaled'); axis square;


dd=uicontrol('string','Step',...
      'style','pushbutton','callback','step',...
      'position',[100 0 50 30]);
ee=uicontrol('string','Stepback',...
      'style','pushbutton','callback','stepback',...
      'position',[150 0 50 30]);