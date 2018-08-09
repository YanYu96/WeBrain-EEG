function varargout = nit_runICA(varargin)
% NIT_RUNICA MATLAB code for nit_runICA.fig
%      NIT_RUNICA, by itself, creates a new NIT_RUNICA or raises the existing
%      singleton*.
%
%      H = NIT_RUNICA returns the handle to a new NIT_RUNICA or the handle to
%      the existing singleton*.
%
%      NIT_RUNICA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NIT_RUNICA.M with the given input arguments.
%
%      NIT_RUNICA('Property','Value',...) creates a new NIT_RUNICA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nit_runICA_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nit_runICA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help nit_runICA

% Last Modified by GUIDE v2.5 12-Oct-2015 16:23:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nit_runICA_OpeningFcn, ...
                   'gui_OutputFcn',  @nit_runICA_OutputFcn, ...
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


% --- Executes just before nit_runICA is made visible.
function nit_runICA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nit_runICA (see VARARGIN)

% Choose default command line output for nit_runICA
handles.output = hObject;
handles.cfg.EventInfo = [];                % event info
handles.cfg.SelectEvent = [];              % Selected Events.
handles.cfg.SelectChanns = [];             % Selected channels.
handles.cfg.EpochTimeRange = [-200 800];   % Epoch time range.[min max] (msec).
handles.cfg.ExcludBadBlockFlag = 1;     % Exclude bad block?
handles.cfg.srate = [];                 % sampling rate.

handles.cfg.ICAPara.ICs = 'Default';    % number of ICs.
handles.cfg.ICAPara.N = 0;              % perform tanh() "extended-ICA" with sign estimation N training blocks.
handles.cfg.ICAPara.PCs = 'Default';    % number of PCs to retain.
handles.cfg.ICAPara.stop = 1e-6;        % stop training when weight-change.
handles.cfg.ICAPara.MaxSteps = 512;     % Max Steps.

try EEG = evalin('base','EEG');
    if ~isempty(EEG)
        try EEG.data;
            if ~isempty(EEG.data)
                handles.cfg.EEG = EEG;
                if length(size(EEG.data))==3
                    set(handles.pushbutton_SelectEvents,'enable','off');
                    set(handles.checkbox_ExcludeBadBlock,'enable','off');
                    try EpochTimeRange = round(1000*[EEG.xmin,EEG.xmax]); % change sec to msec.
                        handles.cfg.EpochTimeRange = EpochTimeRange;   % Epoch time range.[min max] (msec).
                        set(handles.edit_epoch,'string',num2str(EpochTimeRange));
                        set(handles.edit_epoch,'enable','off');
                    catch
                    end
                end
            else
                errordlg('EEG data is empty!!!!','Data Error');
            end
        catch, errordlg('EEG data is NULL!!!!','Data Error');
        end
        % ----------
        % try sampling rate
        try EEG.srate
            if ~isempty(EEG.srate)
                handles.cfg.srate = EEG.srate;
                set(handles.edit_srate,'string',num2str(EEG.srate));
            end
        catch
        end;
        % ----------
        % try events
        try EEG.event(1).type;
            handles.cfg.EventInfo.events = EEG.event;
            if ischar(EEG.event(1).type)
                types = {EEG.event.type};
                [Eventtypes, ~, ~] = unique_bc(types); % indexcolor countinas the event type
                handles.cfg.EventInfo.Eventtypes = Eventtypes;
                TypeInd = [];
                for j = 1:length(Eventtypes)
                    k = 1;
                    tempInd = [];
                    for i = 1:length(types)
                        if Eventtypes{j} == types{i}
                            tempInd(k) = i;
                            k = k+1;
                        end
                    end
                    TypeInd(1,j).index = tempInd;
                end
            else [Eventtypes, ~, ~] = unique_bc([EEG.event.type]);
                handles.cfg.EventInfo.Eventtypes = Eventtypes;
                TypeInd = [];
                for j = 1:length(Eventtypes)
                    TypeInd(1,j).index = find(Eventtypes(j)==[EEG.event.type]);
                end
            end;
            handles.cfg.EventInfo.TypeInd = TypeInd;
        catch
        end
    else
        errordlg('EEG is empty!!!!','Data Error');
    end
catch, errordlg('Failed to find EEG data!!!','Data Error');
end;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nit_runICA wait for user response (see UIRESUME)
% uiwait(handles.figure_runICA);


% --- Outputs from this function are returned to the command line.
function varargout = nit_runICA_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(nit_runICA);

% --- Executes on selection change in listbox_SelectedChanns.
function listbox_SelectedChanns_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_SelectedChanns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_SelectedChanns contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_SelectedChanns


% --- Executes during object creation, after setting all properties.
function listbox_SelectedChanns_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_SelectedChanns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_ICs_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ICs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ICs as text
%        str2double(get(hObject,'String')) returns contents of edit_ICs as a double
strICs = get(hObject,'String');
if strcmp(strICs,'Default')
    handles.cfg.ICAPara.ICs = strICs;
else
    ICs = str2num(strICs);
    if ~isempty(ICs)
        if ICs > 0 && round(ICs)==ICs
            handles.cfg.ICAPara.ICs = ICs;
        end
    end
end

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_ICs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ICs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_extendedN_Callback(hObject, eventdata, handles)
% hObject    handle to edit_extendedN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_extendedN as text
%        str2double(get(hObject,'String')) returns contents of edit_extendedN as a double
N = str2num(get(hObject,'String'));
if ~isempty(N) && isreal(N)
    handles.cfg.ICAPara.N = N;
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_extendedN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_extendedN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_PCs_Callback(hObject, eventdata, handles)
% hObject    handle to edit_PCs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_PCs as text
%        str2double(get(hObject,'String')) returns contents of edit_PCs as a double
strPCs = get(hObject,'String');
if strcmp(strPCs,'Default')
    handles.cfg.ICAPara.PCs = strPCs;
else
    PCs = str2num(strPCs);
    if ~isempty(PCs)
        if PCs > 0 && round(PCs)==PCs
            handles.cfg.ICAPara.PCs = PCs;
        end
    end
end


% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_PCs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_PCs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Stop_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Stop as text
%        str2double(get(hObject,'String')) returns contents of edit_Stop as a double
stop = str2num(get(hObject,'String'));
if ~isempty(stop)
    if stop < 1 && stop > 0 && isreal(stop)
        handles.cfg.ICAPara.stop = stop;
    end
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_Stop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_MaxSteps_Callback(hObject, eventdata, handles)
% hObject    handle to edit_MaxSteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_MaxSteps as text
%        str2double(get(hObject,'String')) returns contents of edit_MaxSteps as a double
MaxSteps = str2num(get(hObject,'String'));
if ~isempty(MaxSteps)
    if MaxSteps > 0 && round(MaxSteps)==MaxSteps
        handles.cfg.ICAPara.MaxSteps = MaxSteps;
    end
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_MaxSteps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_MaxSteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_ICASettingsHelp.
function pushbutton_ICASettingsHelp_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ICASettingsHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox({'ICA settings: ';...
        '   No. of ICs: Number of ICA components to compute (default -> chans or ''pca'' arg) ';...
        '   Training blocks (extended-ICA): Perform tanh() "extended-ICA" with sign estimation N training blocks. If N > 0, automatically estimate the number of sub-Gaussian sources. If N < 0, fix number of sub-Gaussian comps to -N [faster than N>0] (default|0 -> off).';...
        '   No. of PCs to retain: Decompose a principal component subspace of the data(default -> off). Value is the number of PCs to retain..';...
        '   Stop Criterion: Stop training when weight-change (default -> 1e-6).';...
        '   Max Steps: max number of ICA training steps (default -> 512).';...
        },'Help');


function edit_epoch_Callback(hObject, eventdata, handles)
% hObject    handle to edit_epoch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_epoch as text
%        str2double(get(hObject,'String')) returns contents of edit_epoch as a double
handles.cfg.EpochTimeRange = str2num(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_epoch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_epoch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_ExcludeBadBlock.
function checkbox_ExcludeBadBlock_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_ExcludeBadBlock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_ExcludeBadBlock
value = get(hObject,'Value');
handles.cfg.ExcludBadBlockFlag = value;
% Update handles structure
guidata(hObject, handles);

% --- Executes on selection change in listbox_EventInfo.
function listbox_EventInfo_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_EventInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_EventInfo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_EventInfo


% --- Executes during object creation, after setting all properties.
function listbox_EventInfo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_EventInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_SelectEvents.
function pushbutton_SelectEvents_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_SelectEvents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
BadBlockFlag = handles.cfg.ExcludBadBlockFlag; % 1-> Exclude events in Bad Block; 0-> DO NOT Exclude
EventInfo = handles.cfg.EventInfo;
try LogiVal = EventInfo.Eventtypes == 9999;
catch, LogiVal = cellfun(@(x) isequal(x,'9999'),EventInfo.Eventtypes);
end;
if ~isempty(EventInfo)
    EventTypes = EventInfo.Eventtypes;
    if iscell(EventTypes)
        [eventlist,~,celleventnames] = pop_chansel(EventTypes,'withindex','off');
    else
        [eventlist,~,celleventnames] = pop_chansel(cellstr(num2str(EventTypes')),'withindex','off');
    end
    handles.cfg.SelectEvent.eventlist = eventlist;
    handles.cfg.SelectEvent.celleventnames = celleventnames;
    % set(handles.listbox_SelectedChanns,'string',celleventnames);
    % ---------------------------------
    ShowStr = cell(1,length(eventlist)+1);
    ShowStr(1) = {'No. of events/trials!'};
    if ischar(EventInfo.events(1).type) % event type is string?
        if BadBlockFlag == 1 && sum(LogiVal) ~= 0 % exclude events in bad block?
            BadBlockInd = EventInfo.TypeInd(1,LogiVal).index;
            t1_Begin = [EventInfo.events(1,BadBlockInd).latency];
            t1_End = t1_Begin + [EventInfo.events(1,BadBlockInd).duration];
            for j = 1:length(eventlist)
                if isequal(EventInfo.Eventtypes{eventlist(j)},'9999')
                    tempInd = EventInfo.TypeInd(1,eventlist(j)).index;
                    t3 = [EventInfo.events(1,tempInd).latency];
                    ShowStr(j+1) = {['Type-',celleventnames{j},'-> ',num2str(length(t3))]};
                else
                    tempInd = EventInfo.TypeInd(1,eventlist(j)).index;
                    t3 = [EventInfo.events(1,tempInd).latency];
                    for k = 1:length(t1_Begin)    % exclude event onsets in bad block.
                        t3 = t3(t3<t1_Begin(k) | t3>t1_End(k));
                    end
                    ShowStr(j+1) = {['Type-',EventInfo.Eventtypes{eventlist(j)},'-> ',num2str(length(t3))]};
                end
            end
        else
            for j = 1:length(eventlist)
                tempInd = EventInfo.TypeInd(1,eventlist(j)).index;
                t3 = [EventInfo.events(1,tempInd).latency];
                ShowStr(j+1) = {['Type-',EventInfo.Eventtypes{eventlist(j)},'-> ',num2str(length(t3))]};
            end
        end
    else
        if BadBlockFlag == 1 && sum(LogiVal) ~= 0 % exclude events in bad block?
            BadBlockInd = EventInfo.TypeInd(1,LogiVal).index;
            t1_Begin = [EventInfo.events(1,BadBlockInd).latency];
            t1_End = t1_Begin + [EventInfo.events(1,BadBlockInd).duration];
            for j = 1:length(eventlist)
                if isequal(EventInfo.Eventtypes(eventlist(j)),9999)
                    tempInd = EventInfo.TypeInd(1,eventlist(j)).index;
                    t3 = [EventInfo.events(1,tempInd).latency];
                    ShowStr(j+1) = {['Type-',num2str(EventInfo.Eventtypes(eventlist(j))),'-> ',num2str(length(t3))]};
                else
                    tempInd = EventInfo.TypeInd(1,eventlist(j)).index;
                    t3 = [EventInfo.events(1,tempInd).latency];
                    for k = 1:length(t1_Begin)    % exclude event onsets in bad block.
                        t3 = t3(t3<t1_Begin(k) | t3>t1_End(k));
                    end
                    ShowStr(j+1) = {['Type-',num2str(EventInfo.Eventtypes(eventlist(j))),'-> ',num2str(length(t3))]};
                end
            end
        else
            for j = 1:length(eventlist)
                tempInd = EventInfo.TypeInd(1,eventlist(j)).index;
                t3 = [EventInfo.events(1,tempInd).latency];
                ShowStr(j+1) = {['Type-',num2str(EventInfo.Eventtypes(eventlist(j))),'-> ',num2str(length(t3))]};
            end
        end
    end
    set(handles.listbox_EventInfo,'String',ShowStr);
else
    msgbox({'No events/types in the EEG data'},'Note');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbutton_EEGSettingsHelp.
function pushbutton_EEGSettingsHelp_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_EEGSettingsHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox({'EEG settings: ';...
        '   Select Events: Select Events/Types you interested.';...
        '   EEG Sampling Rate: It can be automatically filled. If failed, please fill it by hand.';...
        '   Epoch Time Range [min max] (msec): In the epoch time range,''min'' must be <= 0;''max'' must be >0.';...
        '   Exclude Powers in Bad Block (label 9999)?: Exculde trials in the bad block (label 9999).';...
        },'Help');


function edit_srate_Callback(hObject, eventdata, handles)
% hObject    handle to edit_srate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_srate as text
%        str2double(get(hObject,'String')) returns contents of edit_srate as a double
srate = str2double(get(hObject,'String'));
if srate > 0
    handles.cfg.srate = srate;
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_srate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_srate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_Save.
function pushbutton_Save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if evalin('base','exist(''ICAresults'')')==1 % MeanPower exist in the workspace?
    ICAresults = evalin('base','ICAresults');
    if ~isempty(ICAresults)
        % save
        [filename,pathname] = uiputfile({'*.mat','Matlab'},'Save ICA results');
        if ~isequal(filename,0) && ~isequal(pathname,0)
            fpath = fullfile(pathname,filename);
            % [~, ~, ext] = fileparts(fpath);
            save(fpath,'ICAresults');
            msgbox('ICA results has saved!','Success','help');
        end
    else
        errordlg('ICAresults is empty, please run ICA first!!!!','Data Error');
        return;
    end
else
    errordlg('ICAresults is NULL,please run ICA first!!!!','Data Error');
    return;
end

% --- Executes on button press in pushbutton_Show.
function pushbutton_Show_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Show (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try ICAresults = evalin('base','ICAresults');
    if isempty(ICAresults)
        errordlg('ICAresults is empty, please run ICA first!!!!','Data Error');
        return;
    end
catch
    errordlg('ICAresults is NULL, please run ICA first!!!!','Data Error');
    return;
end

epochRange = ICAresults.Settings.epoch;
srate = ICAresults.Settings.srate;
N_type = length(ICAresults.results);
EventTypes = [];
for i = 1:N_type
    try EventTypes{i} = ICAresults.results(i).type;
    catch
        EventTypes{i} = 'Default';
    end
end
[eventlist,~,celleventnames] = pop_chansel(EventTypes,'withindex','off');
N_selectEvents = length(eventlist);
chanlocs = handles.cfg.EEG.chanlocs;
chanlist = ICAresults.Settings.SelectedChanns.chanlist;
% check the chanlocs.
if ~isempty(chanlocs)
   try 
       if isempty(chanlocs(1,1).theta) || isempty(chanlocs(1,1).X)
           chanlocs = [];
       end
       chanlocs = chanlocs(chanlist);
   catch
       chanlocs = [];
   end
end
for i = 1:N_selectEvents % ICA results of selected events
    ICweights = ICAresults.results(i).IC_weights;
    ICtimecourses = ICAresults.results(i).IC_timecourses;
    N_trials = ICAresults.results(i).trials;
    if ~isempty(chanlocs)
        for j = 1:size(ICweights,1)
            epochedEEG = (reshape(ICtimecourses(j,:),size(ICtimecourses,2)/N_trials,N_trials))';
            titlename = ['Component-',num2str(j),'-Event-',celleventnames{i}];
            pop_ERPimage1(epochedEEG,epochRange,srate,titlename,(ICweights(j,:))',chanlocs);
        end
    else
        for j = 1:size(ICweights,1)
            epochedEEG = (reshape(ICtimecourses(j,:),size(ICtimecourses,2)/N_trials,N_trials))';
            titlename = ['Component-',num2str(j),'-Event-',celleventnames{i}];
            pop_ERPimage1(epochedEEG,epochRange,srate,titlename);
        end
    end
end

% --- Executes on button press in pushbutton_run.
function pushbutton_run_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rawBackgroundColor = get(hObject ,'BackgroundColor');
set(hObject ,'Enable', 'off','BackgroundColor', 'red');
set(handles.pushbutton_cancel ,'Enable', 'off');
drawnow;
EEG =  handles.cfg.EEG;
% Checking EEG settings
if isempty(EEG)
    errordlg('EEG is empty!!!!','Data Error');
    set(hObject,'Enable', 'on','BackgroundColor', rawBackgroundColor);
    set(handles.pushbutton_cancel ,'Enable', 'on');
    return;
else
    DIM = size(EEG.data);
end;

srate = handles.cfg.srate;            % sampling rate.
if isempty(srate)
    errordlg('Sampling rate must be > 0!!!','Parameter Error');
    set(hObject,'Enable', 'on','BackgroundColor', rawBackgroundColor);
    set(handles.pushbutton_cancel ,'Enable', 'on');
    return;
end;

SelectChanns = handles.cfg.SelectChanns;    % Selected Channels.
if isempty(SelectChanns)
    errordlg('Please select channels!!!','Parameter Error');
    set(hObject,'Enable', 'on','BackgroundColor', rawBackgroundColor);
    set(handles.pushbutton_cancel ,'Enable', 'on');
    return;
else
    if isempty(SelectChanns.chanlist)
        errordlg('Please select channels!!!','Parameter Error');
        set(hObject,'Enable', 'on','BackgroundColor', rawBackgroundColor);
        set(handles.pushbutton_cancel ,'Enable', 'on');
        return;
    end
end;

if length(DIM) == 2 %  no epoched data
    SelectEvent = handles.cfg.SelectEvent;    % Selected Events.
    if isempty(SelectEvent)
        errordlg('Please select events!!!','Parameter Error');
        set(hObject,'Enable', 'on','BackgroundColor', rawBackgroundColor);
        set(handles.pushbutton_cancel ,'Enable', 'on');
        return;
    else
        if isempty(SelectEvent.eventlist)
            errordlg('Please select types!!!','Parameter Error');
            set(hObject,'Enable', 'on','BackgroundColor', rawBackgroundColor);
            set(handles.pushbutton_cancel ,'Enable', 'on');
            return;
        end
    end;
    
    EventInfo = handles.cfg.EventInfo;        % event info
    if isempty(EventInfo)
        errordlg('No event info in EEG data!!!','Event Error');
        set(hObject,'Enable', 'on','BackgroundColor', rawBackgroundColor);
        set(handles.pushbutton_cancel ,'Enable', 'on');
        return;
    end;
    
    EpochTimeRange = handles.cfg.EpochTimeRange;   % Epoch time range.[min max] (msec).
    if length(EpochTimeRange)~=2
        errordlg('The epoch time range shold be [min max]!!!','Parameter Error');
        set(hObject,'Enable', 'on','BackgroundColor', rawBackgroundColor);
        set(handles.pushbutton_cancel ,'Enable', 'on');
        return;
    else
        if EpochTimeRange(1)>0 || EpochTimeRange(2)<=0
            errordlg('In the epoch time range,''min'' must be <= 0;''max'' must be >0!!!','Parameter Error');
            set(hObject,'Enable', 'on','BackgroundColor', rawBackgroundColor);
            set(handles.pushbutton_cancel ,'Enable', 'on');
            return;
        end;
    end
    BadBlockFlag = handles.cfg.ExcludBadBlockFlag;     % Exclude bad block?
    try LogiVal = EventInfo.Eventtypes == 9999;
    catch, LogiVal = cellfun(@(x) isequal(x,'9999'),EventInfo.Eventtypes);
    end;
    % checking ICA parameters
    ICAPara = handles.cfg.ICAPara;
    
    % --------------------------------------
    % display settings:
    disp('--------------------------');
    disp('Select Channels:');
    disp(['No. of channels:',num2str(length(SelectChanns.chanlist))]);
    disp(SelectChanns.cellchannames);
    disp('Select Events:');
    disp(SelectEvent.celleventnames);
    disp(['Epoch Time Range -> ',num2str(EpochTimeRange(1)),'ms',' ~ ',num2str(EpochTimeRange(2)),'ms']);
    disp(['Sampling Rate -> ',num2str(srate),' Hz']);
    disp(['Exclude Events in Bad Block (label 9999)? -> ',num2str(BadBlockFlag)]);
    disp('-------');
    disp(['ICs -> ',num2str(ICAPara.ICs)]);
    disp(['Training blocks (extended-ICA) -> ',num2str(ICAPara.N)]);
    disp(['PCs -> ',num2str(ICAPara.PCs)]);
    disp(['Stop Criterion -> ',num2str(ICAPara.stop)]);
    disp(['Max Steps -> ',num2str(ICAPara.MaxSteps)]);
    disp('--------------------------');
    % -------------------------------------
    ICAresults = []; % ICA results
    ICAresults.Settings.SelectedChanns = SelectChanns;
    ICAresults.Settings.epoch = EpochTimeRange;
    ICAresults.Settings.srate = srate;
    ICAresults.Settings.BadBlockFlag = BadBlockFlag;
    ICAresults.Settings.ICs = ICAPara.ICs;
    ICAresults.Settings.N = ICAPara.N;
    ICAresults.Settings.PCs = ICAPara.PCs;
    ICAresults.Settings.stop = ICAPara.stop;
    ICAresults.Settings.MaxSteps = ICAPara.MaxSteps;
    
    N_event = length(SelectEvent.eventlist);
    for j = 1:N_event
        % extract epochs for each selected event
        latencies = [];
        if ischar(EventInfo.events(1).type) % event type is string?
            if BadBlockFlag == 1 && sum(LogiVal) ~= 0 % exclude events in bad block?
                BadBlockInd = EventInfo.TypeInd(1,LogiVal).index;
                t1_Begin = [EventInfo.events(1,BadBlockInd).latency];
                t1_End = t1_Begin + [EventInfo.events(1,BadBlockInd).duration];
                if ~isequal(EventInfo.Eventtypes{SelectEvent.eventlist(j)},'9999')
                    tempInd = EventInfo.TypeInd(1,SelectEvent.eventlist(j)).index;
                    latencies = [EventInfo.events(1,tempInd).latency];
                    for k = 1:length(t1_Begin)    % exclude event onsets in bad block.
                        latencies = latencies(latencies<t1_Begin(k) | latencies>t1_End(k));
                    end
                end
            else
                tempInd = EventInfo.TypeInd(1,SelectEvent.eventlist(j)).index;
                latencies = [EventInfo.events(1,tempInd).latency];
            end
        else
            if BadBlockFlag == 1 && sum(LogiVal) ~= 0 % exclude events in bad block?
                BadBlockInd = EventInfo.TypeInd(1,LogiVal).index;
                t1_Begin = [EventInfo.events(1,BadBlockInd).latency];
                t1_End = t1_Begin + [EventInfo.events(1,BadBlockInd).duration];
                if ~isequal(EventInfo.Eventtypes(SelectEvent.eventlist(j)),9999)
                    tempInd = EventInfo.TypeInd(1,SelectEvent.eventlist(j)).index;
                    latencies = [EventInfo.events(1,tempInd).latency];
                    for k = 1:length(t1_Begin)    % exclude event onsets in bad block.
                        latencies = latencies(latencies<t1_Begin(k) | latencies>t1_End(k));
                    end
                end
            else
                tempInd = EventInfo.TypeInd(1,SelectEvent.eventlist(j)).index;
                latencies = [EventInfo.events(1,tempInd).latency];
            end
        end
        temp_data = [];
        if ~isempty(latencies)
            t_prior = round(EpochTimeRange(1)/1000*srate);
            t_post = round(EpochTimeRange(2)/1000*srate);
            for i = 1:length(latencies)
                t1 = latencies(i) + t_prior;
                t2 = latencies(i) + t_post;
                try temp1 = EEG.data(:,t1:t2);
                    temp_data = [temp_data,temp1];
                catch
                    temp1 = [];
                    latencies(i) = 0;
                end
            end
            latencies(latencies==0)=[];
            ICAresults.results(1,j).latencies = latencies;
            ICAresults.results(1,j).type = SelectEvent.celleventnames{j};
            ICAresults.results(1,j).trials = length(latencies);
            temp_data = temp_data(SelectChanns.chanlist,:); % get data of  selected channels
        end
        if ~isempty(temp_data)
            % Calculate ICA
            if strcmp(ICAPara.ICs,'Default')
                if strcmp(ICAPara.PCs,'Default')
                    [weights,~,~,~,~,~,activations] = runica(temp_data,'extended',ICAPara.N,...
                        'stop',ICAPara.stop,'maxsteps',ICAPara.MaxSteps);
                else
                    [weights,~,~,~,~,~,activations] = runica(temp_data,'pca',ICAPara.PCs,'extended',ICAPara.N,...
                        'stop',ICAPara.stop,'maxsteps',ICAPara.MaxSteps);
                end
            else
                if strcmp(ICAPara.PCs,'Default')
                    [weights,~,~,~,~,~,activations] = runica(temp_data,'ncomps',ICAPara.ICs,'extended',ICAPara.N,...
                        'stop',ICAPara.stop,'maxsteps',ICAPara.MaxSteps);
                else
                    [weights,~,~,~,~,~,activations] = runica(temp_data,'ncomps',ICAPara.ICs,'pca',ICAPara.PCs,'extended',ICAPara.N,...
                        'stop',ICAPara.stop,'maxsteps',ICAPara.MaxSteps);
                end
            end
            ICAresults.results(1,j).IC_weights = weights;
            ICAresults.results(1,j).IC_timecourses = activations;
        else
            ICAresults.results(1,j).IC_weights = [];
            ICAresults.results(1,j).IC_timecourses = [];
            warning(['No trials for event-',SelectEvent.celleventnames{j},':Out of bad block/less than epoch length!!']);
        end
    end
elseif length(DIM) == 3 % epoched data (assumes data dimension is channels X timepoints X trials)
    % --------------------------------------
    EpochTimeRange = handles.cfg.EpochTimeRange;
    % checking ICA parameters
    ICAPara = handles.cfg.ICAPara;
    % display settings:
    disp('--------------------------');
    disp('Select Channels:');
    disp(['No. of channels:',num2str(length(SelectChanns.chanlist))]);
    disp(SelectChanns.cellchannames);
    disp(['Epoch Time Range -> ',num2str(EpochTimeRange(1)),'ms',' ~ ',num2str(EpochTimeRange(2)),'ms']);
    disp(['Sampling Rate -> ',num2str(srate),' Hz']);
    disp('-------');
    disp(['ICs -> ',num2str(ICAPara.ICs)]);
    disp(['Training blocks (extended-ICA) -> ',num2str(ICAPara.N)]);
    disp(['PCs -> ',num2str(ICAPara.PCs)]);
    disp(['Stop Criterion -> ',num2str(ICAPara.stop)]);
    disp(['Max Steps -> ',num2str(ICAPara.MaxSteps)]);
    disp('--------------------------');
    % -------------------------------------
    ICAresults = []; % ICA results
    ICAresults.Settings.SelectedChanns = SelectChanns;
    ICAresults.Settings.epoch = EpochTimeRange;
    ICAresults.Settings.srate = srate;
    ICAresults.Settings.ICs = ICAPara.ICs;
    ICAresults.Settings.N = ICAPara.N;
    ICAresults.Settings.PCs = ICAPara.PCs;
    ICAresults.Settings.stop = ICAPara.stop;
    ICAresults.Settings.MaxSteps = ICAPara.MaxSteps;
    % ------------------------------------
    % reshape EEG.data
    temp_data = reshape(EEG.data,EEG.nbchan,EEG.pnts*EEG.trials);
    temp_data = temp_data(SelectChanns.chanlist,:);
    % Calculate ICA  
    if strcmp(ICAPara.ICs,'Default')
        if strcmp(ICAPara.PCs,'Default')
            [weights,~,~,~,~,~,activations] = runica(temp_data,'extended',ICAPara.N,...
                'stop',ICAPara.stop,'maxsteps',ICAPara.MaxSteps);
        else
            [weights,~,~,~,~,~,activations] = runica(temp_data,'pca',ICAPara.PCs,'extended',ICAPara.N,...
                'stop',ICAPara.stop,'maxsteps',ICAPara.MaxSteps);
        end
    else
        if strcmp(ICAPara.PCs,'Default')
            [weights,~,~,~,~,~,activations] = runica(temp_data,'ncomps',ICAPara.ICs,'extended',ICAPara.N,...
                'stop',ICAPara.stop,'maxsteps',ICAPara.MaxSteps);
        else
            [weights,~,~,~,~,~,activations] = runica(temp_data,'ncomps',ICAPara.ICs,'pca',ICAPara.PCs,'extended',ICAPara.N,...
                'stop',ICAPara.stop,'maxsteps',ICAPara.MaxSteps);
        end
    end
    ICAresults.results(1,1).IC_weights = weights;
    ICAresults.results(1,1).IC_timecourses = activations;
    ICAresults.results(1,1).trials = EEG.trials;
    ICAresults.results(1,1).type = 'Default';
else
    errordlg('Data dimension is not corrected, please check your data!!!','Data Error');
    set(hObject,'Enable', 'on','BackgroundColor', rawBackgroundColor);
    set(handles.pushbutton_cancel ,'Enable', 'on');
    return;
end
assignin('base','ICAresults',ICAresults);
% 
% -------------------------------------
set(hObject,'Enable', 'on','BackgroundColor', rawBackgroundColor);
set(handles.pushbutton_cancel ,'Enable', 'on');


% --- Executes during object creation, after setting all properties.
function pushbutton_run_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton_selectChanns.
function pushbutton_selectChanns_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_selectChanns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.cfg.EEG.chanlocs)
    Nchanns = size(handles.cfg.EEG.data,1); 
    [chanlist,~,cellchannames] = pop_chansel(cellstr(num2str((1:Nchanns)')),'withindex','off');
else
    [chanlist,~,cellchannames] = pop_chansel({handles.cfg.EEG.chanlocs.labels},'withindex','on');
end
handles.cfg.SelectChanns.chanlist = chanlist;
handles.cfg.SelectChanns.cellchannames = cellchannames;
set(handles.listbox_SelectedChanns,'string',cellchannames);
% Update handles structure
guidata(hObject, handles);
