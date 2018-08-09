function varargout = nit_Extract_EEG_Features(varargin)
%NIT_EXTRACT_EEG_FEATURES M-file for nit_Extract_EEG_Features.fig
%      NIT_EXTRACT_EEG_FEATURES, by itself, creates a new NIT_EXTRACT_EEG_FEATURES or raises the existing
%      singleton*.
%
%      H = NIT_EXTRACT_EEG_FEATURES returns the handle to a new NIT_EXTRACT_EEG_FEATURES or the handle to
%      the existing singleton*.
%
%      NIT_EXTRACT_EEG_FEATURES('Property','Value',...) creates a new NIT_EXTRACT_EEG_FEATURES using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to nit_Extract_EEG_Features_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      NIT_EXTRACT_EEG_FEATURES('CALLBACK') and NIT_EXTRACT_EEG_FEATURES('CALLBACK',hObject,...) call the
%      local function named CALLBACK in NIT_EXTRACT_EEG_FEATURES.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help nit_Extract_EEG_Features

% Last Modified by GUIDE v2.5 07-Oct-2015 10:49:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nit_Extract_EEG_Features_OpeningFcn, ...
                   'gui_OutputFcn',  @nit_Extract_EEG_Features_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before nit_Extract_EEG_Features is made visible.
function nit_Extract_EEG_Features_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for nit_Extract_EEG_Features
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nit_Extract_EEG_Features wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = nit_Extract_EEG_Features_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_EventOnset.
function pushbutton_EventOnset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_EventOnset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try EEG = evalin('base','EEG');
    if ~isempty(EEG) && length(size(EEG.data)) == 2
        nit_EventOnset;
        close(nit_Extract_EEG_Features);
    else
        errordlg('EEG is empty or EEG.data is 3D epoched data!!!!','Data Error');
        return;
    end
catch
    errordlg('Failed to find EEG data!!!','Data Error');
    return;
end;

% --- Executes on button press in pushbutton_power.
function pushbutton_power_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_power (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try EEG = evalin('base','EEG');
    if ~isempty(EEG) && length(size(EEG.data)) == 2
        nit_ExtractPower;
        close(nit_Extract_EEG_Features);
    else
        errordlg('EEG is empty or EEG.data is 3D epoched data!!!!','Data Error');
        return;
    end
catch
    errordlg('Failed to find EEG data!!!','Data Error');
    return;
end;

% --- Executes on button press in pushbutton_amplitude.
function pushbutton_amplitude_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_amplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try ICAresults = evalin('base','ICAresults');
    if ~isempty(ICAresults)
        nit_amplitude;
        close(nit_Extract_EEG_Features);
    else
        errordlg('ICAresults is empty, please run ICA first or load the ICA results!!!!','Data Error');
        return;
    end
catch
    errordlg('Failed to find ICAresults data,please run ICA first or load the ICA results!!!','Data Error');
    return;
end;

% --- Executes on button press in pushbutton_Help.
function pushbutton_Help_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox({'Extract features from EEG data.';...
        '   Event Onset: Get the event onsets from EEG data.';...
        '   Power: Get the powers of specific frequency band from EEG data.';...
        '   ERP amplitude: Get ERP amplitudes from EEG ICA results (Please run ICA, or load ICA results first!).';...       '   Show Info: Show the No. of all events during from fMRI onset and end (NOT contain duration).'...
        },'Help');


% --- Executes on button press in pushbutton_loadICA.
function pushbutton_loadICA_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_loadICA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname]= uigetfile('*.mat','Select the ICA result file!');
if ~isequal(filename,0)
    dir1 = fullfile(pathname,filename);
    ICAresults = importdata(dir1);
    assignin('base','ICAresults',ICAresults);
end
