function empic_end;

global movi xx yy A counter tipul culoare val_m val_v val_c val_vold val_cold val_mold ttt linia
global val_mit val_mitold

close all;
disp('val_m=');disp(val_m)
surf=val_m-val_mit;
val_v=100*val_v/surf;
val_c=100*val_c/surf;

disp('Vesicles percentage = ');disp(val_v);
disp('Cisternae percentage = ');disp(val_c);

