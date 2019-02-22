function varargout = multidsGUI(varargin)
% MULTIDSGUI MATLAB code for multidsGUI.fig
%      MULTIDSGUI, by itself, creates a new MULTIDSGUI or raises the existing
%      singleton*.
%
%      H = MULTIDSGUI returns the handle to a new MULTIDSGUI or the handle to
%      the existing singleton*.
%
%      MULTIDSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MULTIDSGUI.M with the given input arguments.
%
%      MULTIDSGUI('Property','Value',...) creates a new MULTIDSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before multidsGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to multidsGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help multidsGUI

% Last Modified by GUIDE v2.5 13-Dec-2018 10:46:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @multidsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @multidsGUI_OutputFcn, ...
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


% --- Executes just before multidsGUI is made visible.
function multidsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to multidsGUI (see VARARGIN)

% Choose default command line output for multidsGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes multidsGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = multidsGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
