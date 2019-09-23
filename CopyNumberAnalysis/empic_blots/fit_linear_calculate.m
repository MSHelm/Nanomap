function fit_linear_calculate;

cd '\\winfs-uni.top.gwdg.de\srizzol$\MATLAB';

scale(:,1)=[0.0000
0.5000
1.0000
2.0000];

scale(:,2)=[-1.0720
293.2900
507.8500
875.2000];


plot(scale(:,1),scale(:,2)); line(scale(:,1),scale(:,2),'linestyle','none','marker','o');

probes=[408.8700
573.4700
481.1900
580.8600];

probes_plus=[971.0700
998.0800];



%      opts = fitoptions('y0+a*x');
%      opts.Startpoint=[0 0];
%      opts.Lower=[0 0];
     
     ftype=fittype('y0+a*x');%,'options',opts);
     
     gfit=fit(scale(:,1),scale(:,2),ftype);
     
     y0=gfit.y0;
     a=gfit.a; 
     
     
     siz=size(scale);
     for i=1:siz(1)
         lines(i)=y0+a*scale(i,1);
     end;
     line(scale(:,1),lines, 'color','r');
         
         
         
         
     probes_val=(probes-y0)./a;
     probes_plus_val=(probes_plus-y0)./a;
     
     matrix=[];
     
     matrix(1:numel(probes_val),1)=probes_val;
     matrix(1:numel(probes_plus_val),2)=probes_plus_val
     
     dlmwrite('matrix.txt',matrix);
     
     
     
     
     