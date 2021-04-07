function sroi_undo;

global list mapname b movi rows cols A i xx yy zz iii bbb q s ijj jjj r firstred olds inner_radius outer_radius matrix counter backmatrix

global xxes yyes hex hey

[stat, mess]=fileattrib('*membrane*.txt')
if numel(mess)>0
    disp(numel(mess));
      delete(strcat('membrane',num2str(numel(mess)),'.txt'));
end;
    
      