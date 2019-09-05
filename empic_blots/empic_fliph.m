function empic_fliph;

global movi xx yy A counter tipul culoare numar numar_p clear unclear r background numar_b r
global switcher image_number valoare


A=fliplr(A);
movi=fliplr(movi);
himg=image(movi(:,:),'tag','him','cdatamapping','scaled');
