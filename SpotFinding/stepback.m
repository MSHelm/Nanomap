function stepback

global list mapname b movi rows cols A i xx yy zz iii bbb q s ijj jjj r firstred olds inner_radius outer_radius matrix
global alignsx alignsy hex hey
ijj=ijj-1;
if ijj>q-1
   if ijj==1
        colormap(summer(150));
         else
              colormap(hot(250));
       end;
    himg=imagesc(movi(:,:,ijj)); axis square;

 % set(himg,'cdata',movi(:,:,ijj));
else ijj=s;
       if ijj==1
        colormap(summer(150));
         else
              colormap(hot(250));
       end;
    himg=imagesc(movi(:,:,ijj)); axis square;
 % set(himg,'cdata',movi(:,:,ijj));
end;


   switch ijj
    case 1
     textul=strcat('pHlourin');
     text(10,35,textul,'FontSize',10,'color','g','BackgroundColor',[0.7 0.7 0.7]);
    case 2
     textul=strcat('Cy3');
     text(10,35,textul,'FontSize',10,'color','r','BackgroundColor',[0.7 0.7 0.7]);
    case 3
     textul=strcat('647nC');
     text(10,35,textul,'FontSize',10,'color','b','BackgroundColor',[0.7 0.7 0.7]);
    case 4
     textul=strcat('STED');
     text(10,35,textul,'FontSize',10,'color','r','BackgroundColor',[0.7 0.7 0.7]);

   end

   try
   if numel(hex>1)
            
        xes=[hex(ijj)-50 hex(ijj)+50 hex(ijj)+50 hex(ijj)-50 hex(ijj)-50];
        yes=[hey(ijj)-50 hey(ijj)-50 hey(ijj)+50 hey(ijj)+50 hey(ijj)-50];
        
        line(xes,yes,'color','g');   
   end;
   catch
   end
   