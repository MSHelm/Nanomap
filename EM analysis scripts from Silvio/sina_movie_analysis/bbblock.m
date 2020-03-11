 function a=bbblock (varargin); % x,y,big,small)
% inserts small array into big array with upper left corner at x,y
%disp (nargin); %varargin{:})

x=varargin{1};
y=varargin{2};
big=varargin{3};
small=varargin{4};

szx=size(small,2);
szy=size(small,1);

big(y:y+szy-1,x:x+szx-1)=small;
a=big;