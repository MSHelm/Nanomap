function sroi_2

global list mapname b movi rows cols A i xx yy zz iii bbb q s ijj jjj r firstred olds inner_radius outer_radius matrix counter backmatrix

global xxes yyes hex hey
set(gcf,'windowbuttonmotionfcn','sroi_3'); 

  

  tx=[xxes(1),xxes(numel(xxes))];
  ty=[yyes(1),yyes(numel(yyes))];
  
 linia(counter-1)=line('Xdata',ty,'Ydata',tx,'color','g');

 xxes(numel(xxes)+1)=xxes(1);
 yyes(numel(yyes)+1)=yyes(1);
 
 sizeul=size(movi);

value=[];back=[];
 
 for j=1:sizeul(3)
      bbb=roipoly(movi(:,:,j),yyes,xxes);
      pixfig=find(bbb==1);
      A=movi(:,:,j);
     
      back(j)=mean2(A(hey-10:hey+10,hex-10:hex+10));
      
      value_array=A(pixfig);

     ccc=find(value_array>(mean2(back)+2*std2(back)));
     value_array=value_array(ccc);

     value(j)=mean(value_array);
     
      
 end;
figure;
values=[];
values(:,1)=value';
values(:,2)=back';
values(:,3)=value'-back';

plot(values(:,3))

[stat, mess]=fileattrib('*value*.txt')
if stat==0
    dlmwrite(strcat('value1.txt'),values);
else
      dlmwrite(strcat('value',num2str(numel(mess)+1),'.txt'),values);
end;
    
      

          
      
      
