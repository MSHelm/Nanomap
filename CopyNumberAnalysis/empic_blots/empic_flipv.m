function empic_flipv;

global movi xx yy A counter tipul culoare numar numar_p clear unclear r background numar_b r
global switcher image_number valoare


A=flipud(A);
movi=flipud(movi);
himg=image(movi(:,:),'tag','him','cdatamapping','scaled');