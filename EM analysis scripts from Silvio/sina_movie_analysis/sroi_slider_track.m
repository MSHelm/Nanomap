function sroi_slider_track;

global list mapname b movi rows cols A i xx yy zz iii bbb q s ijj jjj r firstred olds inner_radius outer_radius matrix backmatrix autos 
global cellb slide xxes yyes hex hey slide_track num_mat movib xmatrix ymatrix



set(gcf,'DoubleBuffer','on');
hh=get(slide_track,'value')
disp('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
hh=round(hh);

siz=size(movib);
xxx=[0 siz(1)];
yyy=[0 siz(2)];

plot(yyy,xxx,'linestyle','none','marker','o','markersize',1);

ccc=find(num_mat==hh);
ssiz=size(num_mat);
[xx yy]=ind2sub([ssiz(1) ssiz(2)],ccc);

linex=[];
liney=[];

for i=1:numel(yy)
    num=num_mat(:,yy(i))
    xes=xmatrix(:,yy(i))
    yes=ymatrix(:,yy(i))
   
    ccc=find(num==hh);
    linex(i)=xes(ccc);
    liney(i)=yes(ccc);
end;

line(liney,linex,'color','r','marker','o','markersize',2,'markerfacecolor','r','markeredgecolor','b');
