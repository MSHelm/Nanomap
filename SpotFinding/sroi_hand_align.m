function sroi_hand_align; % Select a point holding the ctrl in the STED image, then select the "same" spot again holding ctrl in the 647nC image and press Hand align!

global list mapname b movi rows cols A xx yy zz iii bbb q s ijj jjj r firstred olds inner_radius outer_radius matrix rr %movi2

global alignsx alignsy

alignsx(1)=alignsx(3);
alignsy(1)=alignsy(3);

alignsx(2)=alignsx(3);
alignsy(2)=alignsy(3);

alignsx
alignsy

sizeul=size(movi);

for i=4:4
    diffx=alignsx(i)-alignsx(1);
    diffy=alignsy(i)-alignsy(1);
    try
    if diffx<0
        movi(:,abs(diffx):sizeul(2),i)=movi(:,1:sizeul(2)-abs(diffx)+1,i);
        movi(:,1:abs(diffx),i)=0;
    else
        movi(:,1:sizeul(2)-abs(diffx)+1,i)=movi(:,abs(diffx):sizeul(2),i);
        movi(:,sizeul(2)-abs(diffx)+1:sizeul(2),i)=0;    
    end;
    catch
    end
    try 
    if diffy<0
        movi(abs(diffy):sizeul(1),:,i)=movi(1:sizeul(1)-abs(diffy)+1,:,i);
        movi(1:abs(diffy),:,i)=0;
    else
        movi(1:sizeul(1)-abs(diffy)+1,:,i)=movi(abs(diffy):sizeul(1),:,i);
        movi(sizeul(1)-abs(diffy)+1:sizeul(1),:,i)=0;    
    end;
    catch
    end
    
end;

% siz=size(movi2);
% for k=1:siz(3)
%     i=4;
%     diffx=alignsx(i)-alignsx(1);
%     diffy=alignsy(i)-alignsy(1);
%     try
%     if diffx<0
%         movi2(:,abs(diffx):sizeul(2),k)=movi2(:,1:sizeul(2)-abs(diffx)+1,k);
%         movi2(:,1:abs(diffx),i)=0;
%     else
%         movi2(:,1:sizeul(2)-abs(diffx)+1,i)=movi2(:,abs(diffx):sizeul(2),i);
%         movi2(:,sizeul(2)-abs(diffx)+1:sizeul(2),i)=0;    
%     end;
%     catch
%     end
%     try 
%     if diffy<0
%         movi2(abs(diffy):sizeul(1),:,i)=movi2(1:sizeul(1)-abs(diffy)+1,:,i);
%         movi2(1:abs(diffy),:,i)=0;
%     else
%         movi2(1:sizeul(1)-abs(diffy)+1,:,i)=movi2(abs(diffy):sizeul(1),:,i);
%         movi2(sizeul(1)-abs(diffy)+1:sizeul(1),:,i)=0;    
%     end;
%     catch
%     end
%     
% end;


himg=image(movi(:,:,ijj),'cdatamapping','scaled'); axis square;

   name=strcat(rr(1:numel(rr)-4),'.mat')
   save(name,'movi');
