function sroi_RGB2X;

%global list mapname b movi rows cols A i xx yy zz iii bbb q s ijj jjj r firstred olds inner_radius outer_radius matrix
%cd E:\_MBPC11200_ALL\labmemb\Silvio\Sina\22_may_2006\movie2

load movie.mat;
%matrix=dlmread('matrix.txt');
sizeul=size(matrix);
matrix_red=[];
matrix_green=[];
matrix_blue=[];

sub_matrix_blue=[];
sub_matrix_red=[];
sub_matrix_green=[];

avg_matrix_blue=[];
avg_matrix_red=[];
avg_matrix_green=[];

norm_matrix_blue=[];
norm_matrix_red=[];
norm_matrix_green=[];

for i=1:sizeul(1)
    if matrix(i,3)==2
        xxx=size(matrix_red);
        matrix_red(xxx(1)+1,:)=matrix(i,4:sizeul(2));
    elseif matrix(i,3)==1
        xxx=size(matrix_green);
        matrix_green(xxx(1)+1,:)=matrix(i,4:sizeul(2));
    else
        xxx=size(matrix_blue);
        matrix_blue(xxx(1)+1,:)=matrix(i,4:sizeul(2));
    end;
end;

dlmwrite('matrix_red.txt',matrix_red);
dlmwrite('matrix_blue.txt',matrix_blue);
dlmwrite('matrix_green.txt',matrix_green);

size_r=size(matrix_red);
size_g=size(matrix_green);
size_b=size(matrix_blue);    

for i=1:size_r(1)
    for j=1:(size_r(2))/2
        if matrix_red(i,2*j)>0
    sub_matrix_red(i,j)=matrix_red(i,2*j-1)-matrix_red(i,2*j);
        else
            sub_matrix_red(i,j)=55555;
        end;
    end;
end;
dlmwrite('sub_matrix_red.txt',sub_matrix_red);
    
for i=1:size_g(1)
    for j=1:(size_g(2))/2
        if matrix_green(i,2*j)>0
    sub_matrix_green(i,j)=matrix_green(i,2*j-1)-matrix_green(i,2*j);
        else
            sub_matrix_green(i,j)=55555;
        end;
    end;
end;
dlmwrite('sub_matrix_green.txt',sub_matrix_green);    
    

for i=1:size_b(1)
    for j=1:(size_b(2))/2
        if matrix_blue(i,2*j)>0
    sub_matrix_blue(i,j)=matrix_blue(i,2*j-1)-matrix_blue(i,2*j);
        else
            sub_matrix_blue(i,j)=55555;
        end;
    end;
end;
dlmwrite('sub_matrix_blue.txt',sub_matrix_blue);
    
 
size_rr=size(sub_matrix_red);
size_gg=size(sub_matrix_green);
size_bb=size(sub_matrix_blue);
    
for i=1:size_rr(1)
    for j=1:(size_rr(2))/2
        if sub_matrix_red(i,2*j-1)<55550 & sub_matrix_red(i,2*j)<55550
            avg_matrix_red(i,j)=(sub_matrix_red(i,2*j-1)+sub_matrix_red(i,2*j))/2;
        elseif sub_matrix_red(i,2*j-1)<55550 & sub_matrix_red(i,2*j)==55555
            avg_matrix_red(i,j)=sub_matrix_red(i,2*j-1);
        elseif sub_matrix_red(i,2*j-1)==55555 & sub_matrix_red(i,2*j)<55550
            avg_matrix_red(i,j)=sub_matrix_red(i,2*j);
        else
            avg_matrix_red(i,j)=55555;
        end;
   end;
end;
dlmwrite('avg_matrix_red.txt',avg_matrix_red);


for i=1:size_bb(1)
    for j=1:(size_bb(2))/2
        if sub_matrix_blue(i,2*j-1)<55550 & sub_matrix_blue(i,2*j)<55550
            avg_matrix_blue(i,j)=(sub_matrix_blue(i,2*j-1)+sub_matrix_blue(i,2*j))/2;
        elseif sub_matrix_blue(i,2*j-1)<55550 & sub_matrix_blue(i,2*j)==55555
            avg_matrix_blue(i,j)=sub_matrix_blue(i,2*j-1);
        elseif sub_matrix_blue(i,2*j-1)==55555 & sub_matrix_blue(i,2*j)<55550
            avg_matrix_blue(i,j)=sub_matrix_blue(i,2*j);
        else
            avg_matrix_blue(i,j)=55555;
        end;
   end;
end;
dlmwrite('avg_matrix_blue.txt',avg_matrix_blue);


for i=1:size_gg(1)
    for j=1:(size_gg(2))/2
        if sub_matrix_green(i,2*j-1)<55550 & sub_matrix_green(i,2*j)<55550
            avg_matrix_green(i,j)=(sub_matrix_green(i,2*j-1)+sub_matrix_green(i,2*j))/2;
        elseif sub_matrix_green(i,2*j-1)<55550 & sub_matrix_green(i,2*j)==55555
            avg_matrix_green(i,j)=sub_matrix_green(i,2*j-1);
        elseif sub_matrix_green(i,2*j-1)==55555 & sub_matrix_green(i,2*j)<55550
            avg_matrix_green(i,j)=sub_matrix_green(i,2*j);
        else
            avg_matrix_green(i,j)=55555;
        end;
   end;
end;
dlmwrite('avg_matrix_green.txt',avg_matrix_green);

size_rrr=size(avg_matrix_red);
size_ggg=size(avg_matrix_green);
size_bbb=size(avg_matrix_blue);

norm_matrix_blue=[];
norm_matrix_red=[];
norm_matrix_green=[];

s=olds;

for i=1:size_rrr(1)
    for j=1:s/2

        if avg_matrix_red(i,j)<55550
            normalizer=avg_matrix_red(i,1);
            norm_matrix_red(i,j)=avg_matrix_red(i,j)*100/normalizer;  
       else
            norm_matrix_red(i,j)=55555;
       end;
   end;
   
   for j=s/2 + 1:s
       
       if avg_matrix_red(i,j)<55550
            normalizer=avg_matrix_red(i,s/2+1);
            norm_matrix_red(i,j)=avg_matrix_red(i,j)*100/normalizer;  
       else
            norm_matrix_red(i,j)=55555;
       end;
   end;
   
   for j=s + 1: s+s/2
       if avg_matrix_red(i,j)<55550
            normalizer=avg_matrix_red(i,s+1);
            norm_matrix_red(i,j)=avg_matrix_red(i,j)*100/normalizer;  
       else
            norm_matrix_red(i,j)=55555;
       end;
   end;
end;
dlmwrite('norm_matrix_red.txt',norm_matrix_red);




for i=1:size_ggg(1)
    for j=1:s/2
        if avg_matrix_green(i,j)<55550
            normalizer=avg_matrix_green(i,1);
            norm_matrix_green(i,j)=avg_matrix_green(i,j)*100/normalizer;  
       else
            norm_matrix_green(i,j)=55555;
       end;
   end;
   
   for j=s/2 + 1:s
       if avg_matrix_green(i,j)<55550
            normalizer=avg_matrix_green(i,s/2+1);
            norm_matrix_green(i,j)=avg_matrix_green(i,j)*100/normalizer;  
       else
            norm_matrix_green(i,j)=55555;
       end;
   end;
   
   for j=s + 1: s+s/2
       if avg_matrix_green(i,j)<55550
            normalizer=avg_matrix_green(i,s+1);
            norm_matrix_green(i,j)=avg_matrix_green(i,j)*100/normalizer;  
       else
            norm_matrix_green(i,j)=55555;
       end;
   end;
end;
dlmwrite('norm_matrix_green.txt',norm_matrix_green);




for i=1:size_bbb(1)
    for j=1:s/2
        if avg_matrix_blue(i,j)<55550
            normalizer=avg_matrix_blue(i,1);
            norm_matrix_blue(i,j)=avg_matrix_blue(i,j)*100/normalizer;  
       else
            norm_matrix_blue(i,j)=55555;
       end;
   end;
   
   for j=s/2 + 1:s
       if avg_matrix_blue(i,j)<55550
            normalizer=avg_matrix_blue(i,s/2+1);
            norm_matrix_blue(i,j)=avg_matrix_blue(i,j)*100/normalizer;  
       else
            norm_matrix_blue(i,j)=55555;
       end;
   end;
   
   for j=s + 1: s+s/2
       if avg_matrix_blue(i,j)<55550
            normalizer=avg_matrix_blue(i,s+1);
            norm_matrix_blue(i,j)=avg_matrix_blue(i,j)*100/normalizer;  
       else
            norm_matrix_blue(i,j)=55555;
       end;
   end;
end;
dlmwrite('norm_matrix_blue.txt',norm_matrix_blue);

close all;


