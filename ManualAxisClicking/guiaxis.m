function varargout = guiaxis(varargin)
% GUIAXIS M-file for guiaxis.fig
%      GUIAXIS, by itself, creates a new GUIAXIS or raises the existing
%      singleton*.
%
%      H = GUIAXIS returns the handle to a new GUIAXIS or the handle to
%      the existing singleton*.
%
%      GUIAXIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIAXIS.M with the given input arguments.
%
%      GUIAXIS('Property','Value',...) creates a new GUIAXIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guiaxis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guiaxis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guiaxis

% Last Modified by GUIDE v2.5 05-Feb-2017 11:57:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guiaxis_OpeningFcn, ...
                   'gui_OutputFcn',  @guiaxis_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before guiaxis is made visible.
function guiaxis_OpeningFcn(hObject, eventdata, handles, varargin)
global dio homer
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guiaxis (see VARARGIN)

% Choose default command line output for guiaxis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

imoverlay(dio,homer,[],[],'copper',0.3,handles.axes1);
% dio=repmat(mat2gray(double(dio),double([1,256])),[1,1,3]);
% handles.green = dio;
% handles.blue = homer;
% %handles.homer=homer(100:200,100:200);
% axes(handles.axes1);imagesc(handles.green(50:250,50:250));
%    % hold on; tran=imagesc(handles.homer);set(tran,'AlphaData',0.7); axis off; hold off;

set(gcf, 'WindowButtonDownFcn', @getMousePositionOnImage);
%set(src, 'Pointer', 'crosshair'); % Optional
pan off % Panning will interfere with this code

% UIWAIT makes guiaxis wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function getMousePositionOnImage(src, event)
global clickno curX curY counter spineline_x spineline_y
handles = guidata(src);


cursorPoint = get(handles.axes1, 'CurrentPoint');
curX(clickno) = cursorPoint(1,1)
curY(clickno) = cursorPoint(1,2)

xLimits = get(handles.axes1, 'xlim');
yLimits = get(handles.axes1, 'ylim');

if (curX(clickno) > min(xLimits) && curX(clickno) < max(xLimits) && curY(clickno) > min(yLimits) && curY(clickno) < max(yLimits))
disp(['Cursor coordinates are (' num2str(curX(clickno)) ', ' num2str(curY(clickno)) ').']);


axes(handles.axes1);hold on;plot(curX(clickno),curY(clickno),'r+','markersize',10);hold off;
clickno=clickno+1;

    if clickno==2
        set(handles.text1, 'String', 'Click on spine top-most point');   
    elseif clickno==3
        set(handles.text1, 'String', 'Click on spine right-most point');
    elseif clickno==4
        set(handles.text1, 'String', 'Click on spine left-most point');
    elseif clickno==5
        set(handles.text1, 'String', 'Click on the lowest point of the neck');
    elseif clickno==6
        set(handles.text1, 'String', 'Draw a rectangle on the shaft: top left');   
    elseif clickno==7
        set(handles.text1, 'String', 'Draw a rectangle on the shaft: top right');  
    elseif clickno==8
        set(handles.text1, 'String', 'Draw a rectangle on the shaft: bottom right');   
    elseif clickno==9
        set(handles.text1, 'String', 'Draw a rectangle on the shaft: bottom left');
    elseif clickno==10
        set(handles.text1, 'String', 'Click on spine bottom-most point');
        [line,spineline_x,spineline_y]=freehanddraw();
        sort_axis_synapses
    end
else
disp('Cursor is outside bounds of image.');
end


function getDendriteArea(h,event)
h = imfreehand;data=get(h);
xydata=get(data.Children(4));
x=xydata.XData;
y=xydata.YData;
figure; plot(x,y,'-.') 

% --- Outputs from this function are returned to the command line.
function varargout = guiaxis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure


% --- Executes on button press in mush.
function mush_Callback(hObject, eventdata, handles)
global classification counter
% hObject    handle to mush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
classification(counter)=1

% --- Executes on button press in flat.
function flat_Callback(hObject, eventdata, handles)
global classification counter
% hObject    handle to flat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
classification(counter)=2

% --- Executes on button press in Other.
function Other_Callback(hObject, eventdata, handles)
global classification counter
% hObject    handle to Other (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
classification(counter)=3


% --- Executes on button press in skip.
function skip_Callback(hObject, eventdata, handles)
global counter classification
% hObject    handle to skip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
classification(counter)=4;
sort_axis_synapses_skip
% --- Executes on button press in previous.
function previous_Callback(hObject, eventdata, handles)
% hObject    handle to previous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sort_axis_synapses_previous

