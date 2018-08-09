function varargout = wb_EEG(varargin)
% -------------------------------------------------------------------------
% Code Summary for working in School of Life Science and Technology,UESTC.
% Author: Li Dong, e-mail: Li_dong729@163.com
% This software is for non commercial use only.
% It is freeware but not in the public domain.
% last edit: 2015/11/30
%            2016/10/12
%--------------------------------------------------------------------------
% WB_EEG MATLAB code for wb_EEG.fig
%      WB_EEG, by itself, creates a new WB_EEG or raises the existing
%      singleton*.
%
%      H = WB_EEG returns the handle to a new WB_EEG or the handle to
%      the existing singleton*.
%
%      WB_EEG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WB_EEG.M with the given input arguments.
%
%      WB_EEG('Property','Value',...) creates a new WB_EEG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before wb_EEG_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to wb_EEG_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help wb_EEG

% Last Modified by GUIDE v2.5 04-Jul-2018 10:43:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wb_EEG_OpeningFcn, ...
                   'gui_OutputFcn',  @wb_EEG_OutputFcn, ...
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


% -------------------------------------
% add tool paths
p = which('nit_EEG.m');
p = p(1:findstr(p,'nit_EEG.m')-1);
if strcmpi(p, './') || strcmpi(p, '.\'), p = [ pwd filesep ]; end;
tmpp = which('pop_fmrib_fastr.m');
if isempty(tmpp)
    disp(['Adding FMRIB path to all EEGLAB functions']);
    newpath = [p,'fmrib1.21',filesep];
    addpath(newpath);
end;


% --- Executes just before wb_EEG is made visible.
function wb_EEG_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to wb_EEG (see VARARGIN)

% Choose default command line output for wb_EEG
handles.output = hObject;
handles.cfg.biosigflag = 0;
[ProgramPath, ~, ~] = fileparts(which('nit_EEG.m'));
logo = imread(fullfile(ProgramPath,'EEG_TitleImage.png'));
imshow(logo,'Parent',handles.axes_TitleImage);
% set(handles.axes_TitleImage,'Color',[0.86,0.86,0.86]);
% axis off;
% handles.cfg.EEGdata = [];
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes wb_EEG wait for user response (see UIRESUME)
% uiwait(handles.wb_EEG);


% --- Outputs from this function are returned to the command line.
function varargout = wb_EEG_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Import_Data_Callback(hObject, eventdata, handles)
% hObject    handle to Import_Data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Load_EEGLAB_SET_File_Callback(hObject, eventdata, handles)
% hObject    handle to Load_EEGLAB_SET_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
EEG = pop_loadset();            % select EEG data
assignin('base','EEG',EEG); % assign data to workspace
% Update handles structure
if ~isempty(EEG)
    try
    set(handles.text_FileName,'String',EEG.filename);
    set(handles.text_SetName,'String',EEG.setname);
    set(handles.text_Channels,'String',num2str(EEG.nbchan));
    set(handles.text_TimePoints,'String',num2str(EEG.pnts));
    set(handles.text_Epochs,'String',num2str(EEG.trials));
    set(handles.text_Events,'String',num2str(length(EEG.event)));
    set(handles.text_SamplingRate,'String',num2str(EEG.srate));
    set(handles.text_Start,'String',num2str(EEG.xmin));
    set(handles.text_End,'String',num2str(EEG.xmax));
    set(handles.text_Ref,'String',EEG.ref);
    S1 = whos('EEG');
    set(handles.text_DataSize,'String',num2str(S1.bytes/1024^2));
    catch
    end
else
    errordlg('Failed to import EEG data, please import EEG data first!!!','Data Error');
    return;
end
guidata(hObject, handles);




% --------------------------------------------------------------------
function Plot_Callback(hObject, eventdata, handles)
% hObject    handle to Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Channels_Plot_Callback(hObject, eventdata, handles)
% hObject    handle to Channels_Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try EEG = evalin('base','EEG');
    if ~isempty(EEG)
        if isempty(EEG.event)
            tempEvent.type = '0000';
            tempEvent.latency = 1;
            tempEvent.urevent = 1;
        else
            tempEvent = EEG.event;
        end
        
        try evalin('base','clear ''tempChanlocs'''); % try to delete tempchanlocs
        catch
        end
        
        nit_eegplot(EEG.data,...
            'srate',EEG.srate,...
            'events',tempEvent,...
            'ploteventdur','on'); % command example -> 'command','fprintf(''REJECT\n'')'
    else
        errordlg('EEG is empty, please import EEG data first!!!!','Data Error');
        return;
    end
catch, errordlg('Failed to find EEG data.Or other errors!!!','Data Error');
end;


% --------------------------------------------------------------------
function Save_CurrentEEG_As_Callback(hObject, eventdata, handles)
% hObject    handle to Save_CurrentEEG_As (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try EEG = evalin('base','EEG');
    EEG.setname = 'SET file';
    pop_saveset(EEG);
catch
    errordlg('Failed to find EEG data.Or other errors!!!','Data Error');
end

% --------------------------------------------------------------------
function Clear_EEGdata_Callback(hObject, eventdata, handles)
% hObject    handle to Clear_EEGdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

evalin('base','clear'); % clear workspace
assignin('base','EEG',[]); % assign null data to workspace
% handles.cfg.EEGdata = [];
set(handles.text_FileName,'String','None');
set(handles.text_SetName,'String','None');
set(handles.text_Channels,'String','None');
set(handles.text_TimePoints,'String','None');
set(handles.text_Epochs,'String','None');
set(handles.text_Events,'String','None');
set(handles.text_SamplingRate,'String','None');
set(handles.text_Start,'String','None');
set(handles.text_End,'String','None');
set(handles.text_Ref,'String','None');
set(handles.text_DataSize,'String','None');
guidata(hObject, handles);

% --------------------------------------------------------------------
function Exist_Callback(hObject, eventdata, handles)
% hObject    handle to Exist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
evalin('base','clear ''all''');
close(handles.nit_EEG)


% --------------------------------------------------------------------
function Tools_Callback(hObject, eventdata, handles)
% hObject    handle to Tools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Mark_Events_Callback(hObject, eventdata, handles)
% hObject    handle to Mark_Events (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try EEG = evalin('base','EEG'); % get EEG from workspace
    if ~isempty(EEG)
        nit_MarkModelSelect;
    else
        errordlg('EEG is empty, please import EEG data first!!!','Data Error');
        return;
    end
catch
    errordlg('Failed to find EEG data.Or other errors!!!','Data Error');
    return;
end


% --------------------------------------------------------------------
function Extract_EEG_Features_Callback(hObject, eventdata, handles)
% hObject    handle to Extract_EEG_Features (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% try EEG = evalin('base','EEG'); % get EEG from workspace
%     if ~isempty(EEG)
%         nit_Extract_EEG_Features;
%     else
%         errordlg('EEG is empty, please import EEG data first!!!','Data Error');
%         return;
%     end
% catch
%     errordlg('Failed to find EEG data, please import EEG data first!!!','Data Error');
%     return;
% end
nit_Extract_EEG_Features;


% --- Executes during object creation, after setting all properties.
function text_FileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_FileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --------------------------------------------------------------------
function Load_NeuroScan_CNT_Callback(hObject, eventdata, handles)
% hObject    handle to Load_NeuroScan_CNT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

EEG = pop_loadcnt();            % select EEG data
assignin('base','EEG',EEG);    % assign data to workspace
% Update handles structure
if ~isempty(EEG)
    try
        set(handles.text_FileName,'String',EEG.filename);
        set(handles.text_SetName,'String',EEG.setname);
        set(handles.text_Channels,'String',num2str(EEG.nbchan));
        set(handles.text_TimePoints,'String',num2str(EEG.pnts));
        set(handles.text_Epochs,'String',num2str(EEG.trials));
        set(handles.text_Events,'String',num2str(length(EEG.event)));
        set(handles.text_SamplingRate,'String',num2str(EEG.srate));
        set(handles.text_Start,'String',num2str(EEG.xmin));
        set(handles.text_End,'String',num2str(EEG.xmax));
        set(handles.text_Ref,'String',EEG.ref);
        S1 = whos('EEG');
        set(handles.text_DataSize,'String',num2str(S1.bytes/1024^2));
    catch
    end
else
    errordlg('Failed to import EEG data!!!','Data Error');
    return;
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function Load_NeuroScan_EEG_Callback(hObject, eventdata, handles)
% hObject    handle to Load_NeuroScan_EEG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

EEG = pop_loadeeg();            % select EEG data
assignin('base','EEG',EEG);    % assign data to workspace
% Update handles structure
if ~isempty(EEG)
    try
        set(handles.text_FileName,'String',EEG.filename);
        set(handles.text_SetName,'String',EEG.setname);
        set(handles.text_Channels,'String',num2str(EEG.nbchan));
        set(handles.text_TimePoints,'String',num2str(EEG.pnts));
        set(handles.text_Epochs,'String',num2str(EEG.trials));
        set(handles.text_Events,'String',num2str(length(EEG.event)));
        set(handles.text_SamplingRate,'String',num2str(EEG.srate));
        set(handles.text_Start,'String',num2str(EEG.xmin));
        set(handles.text_End,'String',num2str(EEG.xmax));
        set(handles.text_Ref,'String',EEG.ref);
        S1 = whos('EEG');
        set(handles.text_DataSize,'String',num2str(S1.bytes/1024^2));
    catch
    end
else
    errordlg('Failed to import EEG data!!!','Data Error');
    return;
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function Load_ASCII_Float_MatlabArray_Callback(hObject, eventdata, handles)
% hObject    handle to Load_ASCII_Float_MatlabArray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
EEG = pop_importdata();            % select EEG data
assignin('base','EEG',EEG);    % assign data to workspace
% Update handles structure
if ~isempty(EEG)
    try
        set(handles.text_FileName,'String',EEG.filename);
        set(handles.text_SetName,'String',EEG.setname);
        set(handles.text_Channels,'String',num2str(EEG.nbchan));
        set(handles.text_TimePoints,'String',num2str(EEG.pnts));
        set(handles.text_Epochs,'String',num2str(EEG.trials));
        set(handles.text_Events,'String',num2str(length(EEG.event)));
        set(handles.text_SamplingRate,'String',num2str(EEG.srate));
        set(handles.text_Start,'String',num2str(EEG.xmin));
        set(handles.text_End,'String',num2str(EEG.xmax));
        set(handles.text_Ref,'String',EEG.ref);
        S1 = whos('EEG');
        set(handles.text_DataSize,'String',num2str(S1.bytes/1024^2));
    catch
    end
else
    errordlg('Failed to import EEG data!!!','Data Error');
    return;
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function Load_BCI2000_File_Callback(hObject, eventdata, handles)
% hObject    handle to Load_BCI2000_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
EEG = pop_loadbci();            % select EEG data
assignin('base','EEG',EEG);     % assign data to workspace
% Update handles structure
if ~isempty(EEG)
    try
        set(handles.text_FileName,'String',EEG.filename);
        set(handles.text_SetName,'String',EEG.setname);
        set(handles.text_Channels,'String',num2str(EEG.nbchan));
        set(handles.text_TimePoints,'String',num2str(EEG.pnts));
        set(handles.text_Epochs,'String',num2str(EEG.trials));
        set(handles.text_Events,'String',num2str(length(EEG.event)));
        set(handles.text_SamplingRate,'String',num2str(EEG.srate));
        set(handles.text_Start,'String',num2str(EEG.xmin));
        set(handles.text_End,'String',num2str(EEG.xmax));
        set(handles.text_Ref,'String',EEG.ref);
        S1 = whos('EEG');
        set(handles.text_DataSize,'String',num2str(S1.bytes/1024^2));
    catch
    end
else
    errordlg('Failed to import EEG data!!!','Data Error');
    return;
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function Load_BIOSIG_EDF_Callback(hObject, eventdata, handles)
% hObject    handle to Load_BIOSIG_EDF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% adding all folders in external
% -------------------------------
if handles.cfg.biosigflag == 0
    disp(['Adding biosig path to all EEGLAB functions']);
    p = which('nit_EEG.m');
    p = p(1:findstr(p,'nit_EEG.m')-1);
    if strcmpi(p, './') || strcmpi(p, '.\'), p = [ pwd filesep ]; end;
    dircontent  = dir([ p 'external' ]);
    dircontent  = { dircontent.name };
    for index = 1:length(dircontent)
        if dircontent{index}(1) ~= '.'
            if ~isempty(findstr('biosig', lower(dircontent{index})))
                aadpathifnotexist( [ p 'external' filesep dircontent{index} filesep 't200_FileAccess' ], 'sopen.m');
                aadpathifnotexist( [ p 'external' filesep dircontent{index} filesep 't250_ArtifactPreProcessingQualityControl' ], 'regress_eog.m' );
                aadpathifnotexist( [ p 'external' filesep dircontent{index} filesep 'doc' ], 'DecimalFactors.txt');
                handles.cfg.biosigflag = 1;
            elseif exist([p 'external' filesep dircontent{index}]) == 7
                addpathifnotinlist([p 'external' filesep dircontent{index}]);
                disp(['Adding path to eeglab' filesep 'external' filesep dircontent{index}]);
            end;
        end;
    end
end
EEG = pop_biosig();            % select EEG data
assignin('base','EEG',EEG);    % assign data to workspace
% Update handles structure
if ~isempty(EEG)
    try
        set(handles.text_FileName,'String',EEG.filename);
        set(handles.text_SetName,'String',EEG.setname);
        set(handles.text_Channels,'String',num2str(EEG.nbchan));
        set(handles.text_TimePoints,'String',num2str(EEG.pnts));
        set(handles.text_Epochs,'String',num2str(EEG.trials));
        set(handles.text_Events,'String',num2str(length(EEG.event)));
        set(handles.text_SamplingRate,'String',num2str(EEG.srate));
        set(handles.text_Start,'String',num2str(EEG.xmin));
        set(handles.text_End,'String',num2str(EEG.xmax));
        set(handles.text_Ref,'String',EEG.ref);
        S1 = whos('EEG');
        set(handles.text_DataSize,'String',num2str(S1.bytes/1024^2));
    catch
    end
else
    errordlg('Failed to import EEG data!!!','Data Error');
    return;
end
guidata(hObject, handles);

function aadpathifnotexist(newpath, functionname);
    tmpp = which(functionname);
    if isempty(tmpp)
        addpath(newpath);
    end;

% --------------------------------------------------------------------
function Load_BrainVisRec_vhdr_Callback(hObject, eventdata, handles)
% hObject    handle to Load_BrainVisRec_vhdr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

EEG = pop_loadbv();            % select EEG data
assignin('base','EEG',EEG);    % assign data to workspace
% Update handles structure
if ~isempty(EEG)
    try
        set(handles.text_FileName,'String',EEG.filename);
        set(handles.text_SetName,'String',EEG.setname);
        set(handles.text_Channels,'String',num2str(EEG.nbchan));
        set(handles.text_TimePoints,'String',num2str(EEG.pnts));
        set(handles.text_Epochs,'String',num2str(EEG.trials));
        set(handles.text_Events,'String',num2str(length(EEG.event)));
        set(handles.text_SamplingRate,'String',num2str(EEG.srate));
        set(handles.text_Start,'String',num2str(EEG.xmin));
        set(handles.text_End,'String',num2str(EEG.xmax));
        set(handles.text_Ref,'String',EEG.ref);
        S1 = whos('EEG');
        set(handles.text_DataSize,'String',num2str(S1.bytes/1024^2));
    catch
    end
else
    errordlg('Failed to import EEG data!!!','Data Error');
    return;
end
guidata(hObject, handles);
% --------------------------------------------------------------------
function Help_Callback(hObject, eventdata, handles)
% hObject    handle to Help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Re_reference_Callback(hObject, eventdata, handles)
% hObject    handle to Re_reference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles   s structure with handles and user data (see GUIDATA)

try EEG = evalin('base','EEG');
    if ~isempty(EEG)
        EEG = pop_reref(EEG);
        assignin('base','EEG',EEG); % assign data to workspace
        set(handles.text_Ref,'String',EEG.ref);
        guidata(hObject, handles);
    else
        errordlg('EEG is empty!!!!','Data Error');
    end
catch
    errordlg('Failed to find EEG data.Or other errors!!!','Data Error');
end



% --------------------------------------------------------------------
function runICA_Callback(hObject, eventdata, handles)
% hObject    handle to runICA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try EEG = evalin('base','EEG');
    if ~isempty(EEG)
        nit_runICA;
    else
        errordlg('EEG data is empty,please import EEG data first!!!!','Data Error');
        return;
    end
catch, errordlg('Failed to find EEG data.Or other errors!!!!','Data Error');
    return;
end


% --------------------------------------------------------------------
function Load_Curry_DAT_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Curry_DAT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
EEG = pop_loadcurry();            % select EEG data
assignin('base','EEG',EEG);    % assign data to workspace
% Update handles structure
if ~isempty(EEG)
    try
        set(handles.text_FileName,'String',EEG.filename);
        set(handles.text_SetName,'String',EEG.setname);
        set(handles.text_Channels,'String',num2str(EEG.nbchan));
        set(handles.text_TimePoints,'String',num2str(EEG.pnts));
        set(handles.text_Epochs,'String',num2str(EEG.trials));
        set(handles.text_Events,'String',num2str(length(EEG.event)));
        set(handles.text_SamplingRate,'String',num2str(EEG.srate));
        set(handles.text_Start,'String',num2str(EEG.xmin));
        set(handles.text_End,'String',num2str(EEG.xmax));
        set(handles.text_Ref,'String',EEG.ref);
        S1 = whos('EEG');
        set(handles.text_DataSize,'String',num2str(S1.bytes/1024^2));
    catch
    end
else
    errordlg('Failed to import EEG data!!!','Data Error');
    return;
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function Load_ChannsLocs_Callback(hObject, eventdata, handles)
% hObject    handle to Load_ChannsLocs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try EEG = evalin('base','EEG');
    if isempty(EEG)
        [inputname,inputpath] = uigetfile('*','Channel locations file');
        if inputname == 0
            return;
        else
            eloc_file = fullfile(inputpath,inputname);
            channslocs = readlocs(eloc_file);
            EEG.chanlocs = channslocs;
            assignin('base','EEG',EEG);    % assign data to workspace
        end
    else
        EEG = pop_chanedit(EEG);
        assignin('base','EEG',EEG);    % assign data to workspace
    end
catch
    errordlg('Failed to find EEG data.Or other errors!!!','Data Error');
end


% --------------------------------------------------------------------
function WeBrain_web_Callback(hObject, eventdata, handles)
% hObject    handle to WeBrain_web (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('http://webrain.uestc.edu.cn/');


% --------------------------------------------------------------------
function Load_Biosemi_BDF_EDF_File_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Biosemi_BDF_EDF_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
EEG = pop_readbdf();            % select EEG data
assignin('base','EEG',EEG);    % assign data to workspace

if ~isempty(EEG)
    try
        set(handles.text_FileName,'String',EEG.filename);
        set(handles.text_SetName,'String',EEG.setname);
        set(handles.text_Channels,'String',num2str(EEG.nbchan));
        set(handles.text_TimePoints,'String',num2str(EEG.pnts));
        set(handles.text_Epochs,'String',num2str(EEG.trials));
        set(handles.text_Events,'String',num2str(length(EEG.event)));
        set(handles.text_SamplingRate,'String',num2str(EEG.srate));
        set(handles.text_Start,'String',num2str(EEG.xmin));
        set(handles.text_End,'String',num2str(EEG.xmax));
        set(handles.text_Ref,'String',EEG.ref);
        S1 = whos('EEG');
        set(handles.text_DataSize,'String',num2str(S1.bytes/1024^2));
    catch
    end
else
    errordlg('Failed to import EEG data!!!','Data Error');
    return;
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function EEG_Filter_Callback(hObject, eventdata, handles)
% hObject    handle to EEG_Filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try EEG = evalin('base','EEG');
    if ~isempty(EEG)
        EEG = pop_eegfilt(EEG);
        assignin('base','EEG',EEG); % assign data to workspace
        guidata(hObject, handles);
    else
        errordlg('EEG is empty!!!!','Data Error');
    end
catch
    errordlg('Failed to find EEG data.Or other errors!!!','Data Error');
end


% --------------------------------------------------------------------
function reref_REST_Callback(hObject, eventdata, handles)
% hObject    handle to reref_REST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiwait(pop_REST_reref);
try EEG = evalin('base','EEG');   
    set(handles.text_Ref,'String',EEG.ref);
    set(handles.text_FileName,'String',EEG.filename);
    set(handles.text_SetName,'String',EEG.setname);
    guidata(hObject, handles);
catch
    errordlg('Failed to find EEG data!!!','Data Error');
end


% --------------------------------------------------------------------
function FMRIB_Callback(hObject, eventdata, handles)
% hObject    handle to FMRIB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function fastr_Callback(hObject, eventdata, handles)
% hObject    handle to fastr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try EEG = evalin('base','EEG');
    if ~isempty(EEG)
        EEG = pop_fmrib_fastr(EEG);
        assignin('base','EEG',EEG); % assign data to workspace
        guidata(hObject, handles);
    else
        errordlg('EEG is empty!!!!','Data Error');
    end
catch
    errordlg('Failed to find EEG data.Or other errors!!!','Data Error');
end

% --------------------------------------------------------------------
function qrsdetect_Callback(hObject, eventdata, handles)
% hObject    handle to qrsdetect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try EEG = evalin('base','EEG');
    if ~isempty(EEG)
        EEG = pop_fmrib_qrsdetect(EEG);
        assignin('base','EEG',EEG); % assign data to workspace
        guidata(hObject, handles);
    else
        errordlg('EEG is empty!!!!','Data Error');
    end
catch
    errordlg('Failed to find EEG data.Or other errors!!!','Data Error');
end

% --------------------------------------------------------------------
function pulse_Callback(hObject, eventdata, handles)
% hObject    handle to pulse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try EEG = evalin('base','EEG');
    if ~isempty(EEG)
        EEG = pop_fmrib_pas(EEG);
        assignin('base','EEG',EEG); % assign data to workspace
        guidata(hObject, handles);
    else
        errordlg('EEG is empty!!!!','Data Error');
    end
catch
    errordlg('Failed to find EEG data.Or other errors!!!','Data Error');
end


% --------------------------------------------------------------------
function Stats1_Callback(hObject, eventdata, handles)
% hObject    handle to Stats1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function stats_1_Callback(hObject, eventdata, handles)
% hObject    handle to stats_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Load_stats1_Callback(hObject, eventdata, handles)
% hObject    handle to Load_stats1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Plot_stats1_Callback(hObject, eventdata, handles)
% hObject    handle to Plot_stats1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function EEG_ttest1_Callback(hObject, eventdata, handles)
% hObject    handle to EEG_ttest1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function EEG_ttest2_Callback(hObject, eventdata, handles)
% hObject    handle to EEG_ttest2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function EEG_paired_ttest_Callback(hObject, eventdata, handles)
% hObject    handle to EEG_paired_ttest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function EEG_ANOVA1_Callback(hObject, eventdata, handles)
% hObject    handle to EEG_ANOVA1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function PlotScalpNetwork_1_Callback(hObject, eventdata, handles)
% hObject    handle to PlotScalpNetwork_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function PlotPower_topo1_Callback(hObject, eventdata, handles)
% hObject    handle to PlotPower_topo1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function PlotERP_Callback(hObject, eventdata, handles)
% hObject    handle to PlotERP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function LoadStatsResults_Callback(hObject, eventdata, handles)
% hObject    handle to LoadStatsResults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Save_CurrentStats_As_Callback(hObject, eventdata, handles)
% hObject    handle to Save_CurrentStats_As (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Clear_Stats_Callback(hObject, eventdata, handles)
% hObject    handle to Clear_Stats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function NIT_web_Callback(hObject, eventdata, handles)
% hObject    handle to NIT_web (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('http://www.neuro.uestc.edu.cn/NIT.html');
