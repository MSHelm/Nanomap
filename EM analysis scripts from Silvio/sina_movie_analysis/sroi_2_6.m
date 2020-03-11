function sroi_2_6;

global list mapname b movi rows cols A i xx yy zz iii bbb q s ijj jjj r firstred olds inner_radius outer_radius matrix backmatrix autos 
global cellb slide xxes yyes hex hey slide_track num_mat movib xmatrix ymatrix

moved_dist=[];

siz=size(movib);
xxx=[0 siz(1)];
yyy=[0 siz(2)];

plot(yyy,xxx,'linestyle','none','marker','o','markersize',1);

number_spots=max(max(num_mat));


set(gcf,'DoubleBuffer','on');

for hh=1:number_spots

ccc=find(num_mat==hh);
ssiz=size(num_mat);
[xx yy]=ind2sub([ssiz(1) ssiz(2)],ccc);

linex=[];
liney=[];


for i=1:numel(yy)
    num=num_mat(:,yy(i));
    xes=xmatrix(:,yy(i));
    yes=ymatrix(:,yy(i));

    ccc=find(num==hh);
    linex(i)=xes(ccc);
    liney(i)=yes(ccc);
end;

line(liney,linex,'color','r','marker','o','markersize',2,'markerfacecolor','r','markeredgecolor','b');

dists=[];
if numel(linex)>5
    for i=2:numel(linex)
        

        distx=linex(i)-linex(i-1); 
        disty=liney(i)-liney(i-1);
    distx=distx^2;
    disty=disty^2;
    distx=distx+disty;
    distx=sqrt(distx);
dists(i-1)=distx;
end;

moved_dist(numel(moved_dist)+1)=mean(dists);

end;

end;

[stat, mess]=fileattrib('*xmatrix*.txt');

dlmwrite(strcat('mean_displacements',num2str(numel(mess)),'.txt'),moved_dist');






