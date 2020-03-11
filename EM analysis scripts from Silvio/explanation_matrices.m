Description "collected_data.txt":    


matrix(siza(1)+1,1)=sum(val_matrix(:,1)); %%%%Total AZ area (pixels)
    matrix(siza(1)+1,2)=sum(val_matrix(:,6));%%%%% Total spine volume (pixels)
    matrix(siza(1)+1,3)=sum(val_matrix(:,13).*val_matrix(:,16));%%% Total vacuole volume
    matrix(siza(1)+1,4)=sum(val_matrix(:,9).*val_matrix(:,12));%%%%%Total mitochondria volume
    matrix(siza(1)+1,5)=sum(val_matrix(:,5));%%%% Total number of vesicles
    matrix(siza(1)+1,6)=sum(val_matrix(:,12)); %%%% Total number of mitochondria   
    matrix(siza(1)+1,7)=mean(val_matrix(:,6));%%%% A
    matrix(siza(1)+1,8)=mean(val_matrix(:,2));  %%%%% Spine perimeter per slice
    matrix(siza(1)+1,9)=sum(val_matrix(:,2));    %%%%% Total spine perimeter (equivalent to total membrane area)
  
    
    sizm=size(matrix_major); majors=val_matrix(:,7); matrix_major(1:numel(majors),sizm(2)+1)=majors;
    sizm=size(matrix_minor); minors=val_matrix(:,8); matrix_minor(1:numel(minors),sizm(2)+1)=minors;
    sizm=size(matrix_mems); mems=val_matrix(:,6); matrix_mems(1:numel(mems),sizm(2)+1)=mems;  
    
    
    
    matrix(siza(1)+1,10)=val_matrix_dist(1,17);
    matrix(siza(1)+1,11)=val_matrix_dist(2,17);    
    matrix(siza(1)+1,12)=val_matrix_dist(3,17);
    matrix(siza(1)+1,13)=val_matrix_dist(4,17);       
    matrix(siza(1)+1,14)=val_matrix_dist(5,17);
    matrix(siza(1)+1,15)=val_matrix_dist(6,17);   
    matrix(siza(1)+1,16)=val_matrix_dist(7,17);
    matrix(siza(1)+1,17)=val_matrix_dist(8,17);
    matrix(siza(1)+1,18)=val_matrix_dist(9,17);
    
    %%%%%col 10: vesicle distance to any AZ pixels;
    %%%%%col 11: vesicle distance to any membrane pixels;   
    %%%%%col 12: vesicle distance to any vacuole pixels (also inside);    
    %%%%%col 13: vesicle distance to any mitochondria pixels (also inside);    
    %%%%%col 14: vesicle distance to vesicles;
    %%%%%col 15: vesicle distance to AZ center;
    %%%%%col 16: vesicle distance to plasma membrane center;   
    %%%%%col 17: vesicle distance to vacuole membrane;    
    %%%%%col 18: vesicle distance to mitochondria membrane;    
    %%%%%col 19: empty;  
    
    matrix(siza(1)+1,20)=val_matrix_dist(1,18);
    matrix(siza(1)+1,21)=val_matrix_dist(2,18);    
    matrix(siza(1)+1,22)=val_matrix_dist(3,18);
    matrix(siza(1)+1,23)=val_matrix_dist(4,18);       
    matrix(siza(1)+1,24)=val_matrix_dist(5,18);
    matrix(siza(1)+1,25)=val_matrix_dist(6,18);   
    matrix(siza(1)+1,26)=val_matrix_dist(7,18);
    matrix(siza(1)+1,27)=val_matrix_dist(8,18);
    matrix(siza(1)+1,28)=val_matrix_dist(9,18);    
    
    
    %%%%%col 20: vacuole distance to any AZ pixels;
    %%%%%col 21: vacuole distance to any membrane pixels;   
    %%%%%col 22: vacuole distance to any vacuole pixels (also inside);    
    %%%%%col 23: vacuole distance to any mitochondria pixels (also inside);    
    %%%%%col 24: vacuole distance to vesicles;
    %%%%%col 25: vacuole distance to AZ center;
    %%%%%col 26: vacuole distance to plasma membrane center;   
    %%%%%col 27: vacuole distance to vacuole membrane;    
    %%%%%col 28: vacuole distance to mitochondria membrane;    
    %%%%%col 29: empty;  
    
    matrix(siza(1)+1,30)=val_matrix_dist(1,19);
    matrix(siza(1)+1,31)=val_matrix_dist(2,19);    
    matrix(siza(1)+1,32)=val_matrix_dist(3,19);
    matrix(siza(1)+1,33)=val_matrix_dist(4,19);       
    matrix(siza(1)+1,34)=val_matrix_dist(5,19);
    matrix(siza(1)+1,35)=val_matrix_dist(6,19);   
    matrix(siza(1)+1,36)=val_matrix_dist(7,19);
    matrix(siza(1)+1,37)=val_matrix_dist(8,19);
    matrix(siza(1)+1,38)=val_matrix_dist(9,19);   
    
    %%%%%col 30: mitochondria distance to any AZ pixels;
    %%%%%col 31: mitochondria  distance to any membrane pixels;   
    %%%%%col 32: mitochondria  distance to any vacuole pixels (also inside);    
    %%%%%col 33: mitochondria  distance to any mitochondria pixels (also inside);    
    %%%%%col 34: mitochondria  distance to vesicles;
    %%%%%col 35: mitochondria  distance to AZ center;
    %%%%%col 36: mitochondria  distance to plasma membrane center;   
    %%%%%col 37: mitochondria distance to vacuole membrane;    
    %%%%%col 38: mitochondria  distance to mitochondria membrane;    
    %%%%%col 39: empty;  
    
    matrix(siza(1)+1,40)=val_matrix_dist(1,20);
    matrix(siza(1)+1,41)=val_matrix_dist(2,20);    
    matrix(siza(1)+1,42)=val_matrix_dist(3,20);
    matrix(siza(1)+1,43)=val_matrix_dist(4,20);       
    matrix(siza(1)+1,44)=val_matrix_dist(5,20);
    matrix(siza(1)+1,45)=val_matrix_dist(6,20);   
    matrix(siza(1)+1,46)=val_matrix_dist(7,20);
    matrix(siza(1)+1,47)=val_matrix_dist(8,20);
    matrix(siza(1)+1,48)=val_matrix_dist(9,20);   
    
    %%%%%col 30: AZ center distance to any AZ pixels;
    %%%%%col 31: AZ center  distance to any membrane pixels;   
    %%%%%col 32: AZ center  distance to any vacuole pixels (also inside);    
    %%%%%col 33: AZ center  distance to any mitochondria pixels (also inside);    
    %%%%%col 34: AZ center distance to vesicles;
    %%%%%col 35: AZ center  distance to AZ center;
    %%%%%col 36: AZ center  distance to plasma membrane center;   
    %%%%%col 37: AZ center distance to vacuole membrane;    
    %%%%%col 38: AZ center  distance to mitochondria membrane;    
    %%%%%col 39: empty;  
    
    
    matrix(siza(1)+1,50)=val_matrix_dist(1,21);
    matrix(siza(1)+1,51)=val_matrix_dist(2,21);    
    matrix(siza(1)+1,52)=val_matrix_dist(3,21);
    matrix(siza(1)+1,53)=val_matrix_dist(4,21);       
    matrix(siza(1)+1,54)=val_matrix_dist(5,21);
    matrix(siza(1)+1,55)=val_matrix_dist(6,21);   
    matrix(siza(1)+1,56)=val_matrix_dist(7,21);
    matrix(siza(1)+1,57)=val_matrix_dist(8,21);
    matrix(siza(1)+1,58)=val_matrix_dist(9,21);   
    
    %%%%%col 30: membrane vacuole distance to any AZ pixels;
    %%%%%col 31: membrane vacuole  distance to any membrane pixels;   
    %%%%%col 32: membrane vacuole  distance to any vacuole pixels (also inside);    
    %%%%%col 33: membrane vacuole  distance to any mitochondria pixels (also inside);    
    %%%%%col 34: membrane vacuole distance to vesicles;
    %%%%%col 35: membrane vacuole  distance to AZ center;
    %%%%%col 36: membrane vacuole  distance to plasma membrane center;   
    %%%%%col 37: membrane vacuole distance to vacuole membrane;    
    %%%%%col 38: membrane vacuole  distance to mitochondria membrane;    
    %%%%%col 39: empty;  
       
    matrix(siza(1)+1,60)=val_matrix_dist(1,22);
    matrix(siza(1)+1,61)=val_matrix_dist(2,22);    
    matrix(siza(1)+1,62)=val_matrix_dist(3,22);
    matrix(siza(1)+1,63)=val_matrix_dist(4,22);       
    matrix(siza(1)+1,64)=val_matrix_dist(5,22);
    matrix(siza(1)+1,65)=val_matrix_dist(6,22);   
    matrix(siza(1)+1,66)=val_matrix_dist(7,22);
    matrix(siza(1)+1,67)=val_matrix_dist(8,22);
    matrix(siza(1)+1,68)=val_matrix_dist(9,22);   
    
    %%%%%col 30: membrane mitochondria distance to any AZ pixels;
    %%%%%col 31: membrane mitochondria  distance to any membrane pixels;   
    %%%%%col 32: membrane mitochondria  distance to any vacuole pixels (also inside);    
    %%%%%col 33: membrane mitochondria  distance to any mitochondria pixels (also inside);    
    %%%%%col 34: membrane mitochondria distance to vesicles;
    %%%%%col 35: membrane mitochondria  distance to AZ center;
    %%%%%col 36: membrane mitochondria  distance to plasma membrane center;   
    %%%%%col 37: membrane mitochondria distance to vacuole membrane;    
    %%%%%col 38: membrane mitochondria  distance to mitochondria membrane;    
    %%%%%col 39: empty;    

    
    
    
    
    Description "matrix_majors.txt", "matrix_minors.txt", "matrix_mems.txt":
 %   - each column is one 3D reconstruction
 %   - each line is one section (image)
 %   - The values indicate the major axis length, minor axis length, or
 %   surface area, of the respective sections
 %  - The matrix is padded with 0, to account for some 3Ds having more
 %  sections (images) than others
    
    