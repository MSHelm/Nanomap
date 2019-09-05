function empic

global movi xx yy A counter tipul culoare numar r background inverter
global switcher image_number valoare values_string deleter
global countter axx ayy newfig smart_values

cd C:\data_2008\march2008\ioanna;

dir *.tif;
r=input('What file      ','s');
qqq=('.tif');
r1=strcat(r,qqq);
xx=[]; yy=[];

inverter=1;
switcher=0; 
numar=0;
numar_p=0;
numar_b=0;
background=0;
deleter=1;

smart_values=[];

values_string =[];

   info=imfinfo(r1);
   
      bitdepth = info.BitDepth;
      switch bitdepth
      case 8
         movi = uint8(0);
         
         A=uint8(0);
      case 16
         movi = uint16(0);
         A=uint16(0);
      end
        


xmovi = imread(r1);
if numel(size(xmovi))>2
    movi=rgb2gray(xmovi);
else
    movi=xmovi;
end;
    
    

A=movi;
 
    
   %%%%%%%%%% MAKE FIGURE (minimum size = minpix)

   
  colormap('bone');
  
  

himg=image(movi(:,:),'tag','him','cdatamapping','scaled');
  
cleaning=uicontrol('tag','clense','style','pushbutton', 'callback',{@empic_write},...
      'position',[0 0 70 30],'string','clean','tooltipstring','erase all drawings');

new_back=uicontrol('tag','newback','style','pushbutton', 'callback',{@empic_backgr},...
      'position',[70 0 140 30],'string','New background','tooltipstring','draw a new background area');
  
undoing=uicontrol('tag','undoes','style','pushbutton', 'callback',{@empic_undo},...
      'position',[210 0 70 30],'string','Undo last','tooltipstring','eliminates the last saved value');

fliph=uicontrol('tag','undoes','style','pushbutton', 'callback',{@empic_fliph},...
      'position',[300 0 70 30],'string','Horiz. flip','tooltipstring','flips image horizontally');
  
flipv=uicontrol('tag','undoes','style','pushbutton', 'callback',{@empic_flipv},...
      'position',[400 0 70 30],'string','Vert. flip','tooltipstring','flips image vertically');
  
      flipv=uicontrol('tag','invertgreylevels','style','pushbutton', 'callback',{@empic_invert},...
      'position',[500 0 70 30],'string','Invert','tooltipstring','invert grey levels');
  
set(gcf,'windowbuttondownfcn',{@empic1});

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function empic_write(source,eventdata)

global movi xx yy A counter tipul culoare numar numar_p clear unclear r background numar_b r
global switcher image_number valoare 

  himg=image(movi(:,:),'tag','him','cdatamapping','scaled');


switcher=0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function empic_backgr(source,eventdata)

global movi xx yy A counter tipul culoare numar numar_p clear unclear r background numar_b r
global switcher image_number valoare

switcher=0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function empic_undo(source,eventdata)

global movi xx yy A counter tipul culoare numar numar_p clear unclear r background numar_b r
global switcher image_number valoare values_string deleter

if deleter>0
fisier=strcat(r,'.txt');

values_string=dlmread(fisier);
if numel(values_string>1)
    values_string=values_string(1:numel(values_string)-1);
    dlmwrite(fisier, values_string,'\t');
else
    values_string=[];
    dlmwrite(fisier, values_string,'\t');
end;



   tx=[xx(1),xx(numel(xx))];
  ty=[yy(1),yy(numel(yy))];
 linia(counter-1)=line('Xdata',ty,'Ydata',tx,'color','w');
 line('Xdata',yy,'Ydata',xx,'color','w');
 
end;

deleter=0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function empic_fliph(source,eventdata)

global movi xx yy A counter tipul culoare numar numar_p clear unclear r background numar_b r
global switcher image_number valoare


A=fliplr(A);
movi=fliplr(movi);
himg=image(movi(:,:),'tag','him','cdatamapping','scaled');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function empic_flipv(source,eventdata)

global movi xx yy A counter tipul culoare numar numar_p clear unclear r background numar_b r
global switcher image_number valoare


A=flipud(A);
movi=flipud(movi);
himg=image(movi(:,:),'tag','him','cdatamapping','scaled');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function empic_invert(source,eventdata)

global movi xx yy A counter tipul culoare numar r background inverter
global switcher image_number valoare values_string deleter

minimum=min(min(movi));

maximum=max(max(movi));

inverter=inverter*(-1);
movi(:,:)=maximum + minimum - movi(:,:);

colormap('gray');
  
  
himg=image(movi(:,:),'tag','him','cdatamapping','scaled');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function empic1(source,eventdata)

global movi xx yy A counter tipul culoare val_m val_v val_c val_vold val_cold val_mold ttt linia
global switcher image_number valoare

counter=1;
  xx=[];
  yy=[];
  linia=[];
  hfig=gcf;
      button=get(hfig,'selectiontype');
        if (strcmp(button,'normal'))
set(gcf,'windowbuttonmotionfcn',{@empic3});
set(gcf,'windowbuttonupfcn',{@empic4});
        elseif (strcmp(button,'alt'))
            empic1_2;
            set(gcf,'windowbuttonupfcn',{@empic4});
        elseif (strcmp(button,'extend'))
            empic1_3;
            set(gcf,'windowbuttonupfcn',{@sroi03});
             end;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function empic1_1(source,eventdata)

global movi xx yy A numar clear unclear background r


hfig=gcf;
    button=get(hfig,'selectiontype');
        if (strcmp(button,'normal'))
          l=get(gca,'currentpoint');
          x=round(l(3));
          y=round(l(1));
          
          numar=numar+1;
          xx(numar)=x;
          yy(numar)=y;
          octogon=[];
                      
         ocols=[x-14, x-10, x,    x+10,   x+14, x+10,   x,   x-10,   x-14];
         orows=[y,   y-10, y-14,  y-10,   y,   y+10,   y+14, y+10,   y];
           % disp(orows); 
           % disp(ocols);
       line(orows,ocols,'color','r');
       octogon=roipoly(A(:,:),orows,ocols);
       
       pos=find(octogon==1);
       media=mean(A(pos));
       media=media-background;       
       clear(numar)=media;
       
       
              elseif (strcmp(button,'alt'))
          l=get(gca,'currentpoint');
          x=round(l(3));
          y=round(l(1));
         octogon=[];
         ocols=[x-28, x-20, x,    x+20,   x+28, x+20,   x,   x-20,   x-28];
         orows=[y,   y-20, y-28,  y-20,   y,   y+20,   y+28, y+20,   y];
           % disp(orows); 
           % disp(ocols);
     line(orows,ocols,'color','b');
       octogon=roipoly(A(:,:),orows,ocols);
       
       pos=find(octogon==1);
       media=mean(A(pos));
       
       background=media;
      
   end;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function empic1_2(source,eventdata)

global movi xx yy A counter tipul culoare numar r background
global switcher image_number valoare values_string deleter

switcher=0;

          l=get(gca,'currentpoint');
          abx=round(l(3));
          aby=round(l(1));
          
          numar=numar+1;
          
         octogon=[];
         
             
         ocols=[abx-20, abx+20, abx+20, abx-20];
         orows=[aby-25, aby-25, aby+25, aby+25];
         
         xx=ocols;
         yy=orows;
    counter=8;
           % disp(orows); 
           % disp(ocols);
     line(yy,xx,'color','r');
  %     octogon=roipoly(A(:,:),orows,ocols);
       
  %     pos=find(octogon==1);
  %    valoare=mean(A(pos));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function empic1_3(source,eventdata)

global movi xx yy A counter tipul culoare numar r background
global switcher image_number valoare values_string deleter
global countter axx ayy newfig smart_values

switcher=0;

          l=get(gca,'currentpoint');
          abx=round(l(3));
          aby=round(l(1));
          
          numar=numar+1;
          
         octogon=[];
         
             
         ocols=[abx-50, abx+50, abx+50, abx-50];
         orows=[aby-100, aby-100, aby+100, aby+100];
         
         xx=ocols;
         yy=orows;
    counter=8;
           % disp(orows); 
           % disp(ocols);
     line(yy,xx,'color','b');
     
     newfig=[];
     newfig(:,:)=A(abx-50:abx+50,aby-100:aby+100); 
     newfig=255-newfig;



figure; image(newfig,'cdatamapping','scaled');

figure;

sizeul=size(newfig);
xvals=[1:1:sizeul(2)];

media=mean(newfig');

plot(media);

countter=0;
axx=[];
ayy=[];

set(gcf,'windowbuttondownfcn',{@empic1_3_1});
    set(gcf,'windowbuttonupfcn',{@sroi03});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function empic1_3_1(source,eventdata)

global movi xx yy A counter tipul culoare val_m val_v val_c val_vold val_cold val_mold ttt linia
global switcher image_number valoare
global countter axx ayy newfig smart_values r

set(gcf,'windowbuttonupfcn',{@sroi03});
countter=countter+1;

       l=get(gca,'currentpoint');
          axx(countter)=round(l(3));
          ayy(countter)=round(l(1));
          
           line(ayy,axx,'linestyle','none','marker','o','markeredgecolor','r','markersize',5);

if countter==2
   
    limit1=ayy(1)-3;
    limit2=ayy(1)+3;
    limit3=ayy(2)-3;
    limit4=ayy(2)+3;
    
    back1=newfig(limit1:limit2,:);
    back2=newfig(limit3:limit4,:);
    

    if ayy(1)<ayy(2)
    signal=newfig(ayy(1):ayy(2),:);
    else
        signal=newfig(ayy(2):ayy(1),:);
    end;
    
    signal_value=sum(sum(signal));
    
    backvalue=sum(sum(back1))+sum(sum(back2));
    backaver=backvalue/(numel(back1)+numel(back2));
    
    signal_value=(signal_value - backaver*numel(signal))/1000
    
        
    smart_values(numel(smart_values)+1)=signal_value;
    dlmwrite(strcat(r,'smart_values.txt'),smart_values');
    close;
    close;
    
    
end;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
function empic2(source,eventdata)

global movi xx yy A counter tipul culoare val_m val_v val_c val_vold val_cold val_mold ttt linia
global val_mit val_mitold

set(gcf,'windowbuttonmotionfcn',{@empic4});
empic5;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function empic2_2(source,eventdata)

global movi xx yy A counter tipul culoare val_m val_v val_c val_vold val_cold val_mold ttt linia r
global val_mit val_mitold
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function empic3(source,eventdata)

global movi xx yy A counter tipul culoare val_m val_v val_c val_vold val_cold val_mold ttt linia
global switcher image_number valoare


 l=get(gca,'currentpoint');
          x=round(l(3));
          y=round(l(1));
          xx(counter)=x;yy(counter)=y;



          
        %  h=findobj(gca,'type','image');
        %  set(h,'cdata',A);
          
          
if counter>1
      tx=[xx(counter-1),xx(counter)];
      ty=[yy(counter-1),yy(counter)];
      if switcher==0
   linia(counter-1)=line('Xdata',ty,'Ydata',tx,'color','r');
      else
         linia(counter-1)=line('Xdata',ty,'Ydata',tx,'color','g');    
  end;
end;

 
            counter=counter+1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function empic4(source,eventdata)

global movi xx yy A counter tipul culoare val_m val_v val_c val_vold val_cold val_mold ttt linia

global switcher image_number valoare

set(gcf,'windowbuttonmotionfcn',{@sroi03});
empic5;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function empic5(source,eventdata)

global movi xx yy A counter tipul r inverter
global switcher image_number valoare values_string deleter

  tx=[xx(1),xx(numel(xx))];
  ty=[yy(1),yy(numel(yy))];
 linia(counter-1)=line('Xdata',ty,'Ydata',tx,'color','g');

bbb=roipoly(A(:,:),yy,xx); 

pixfig=find(bbb==1);
numar=numel(pixfig);

value=sum(A(pixfig));


if switcher>0
    
    value=value-numar*valoare; 
    value = value / 1000;
    value = value * inverter * (-1); 
    %value=value/numar;
   disp(value);
   
    values_string(numel(values_string)+1)=value;
else
     valoare=value/numar;
     %numar

end;


switcher=switcher+1;

fisier=strcat(r,'.txt');

dlmwrite(fisier, values_string,'\t');

deleter=1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sroi03(source,eventdata)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

