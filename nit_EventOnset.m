function varargout = nit_EventOnset(varargin)
% NIT_EVENTONSET MATLAB code for nit_EventOnset.fig
%      NIT_EVENTONSET, by itself, creates a new NIT_EVENTONSET or raises the existing
%      singleton*.
%
%      H = NIT_EVENTONSET returns the handle to a new NIT_EVENTONSET or the handle to
%      the existing singleton*.
%
%      NIT_EVENTONSET('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NIT_EVENTONSET.M with the given input arguments.
%
%      NIT_EVENTONSET('Property','Value',...) creates a new NIT_EVENTONSET or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nit_EventOnset_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nit_EventOnset_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help nit_EventOnset

% Last Modified by GUIDE v2.5 07-Oct-2015 10:09:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @nit_EventOnset_OpeningFcn, ...
    'gui_OutputFcn',  @nit_EventOnset_OutputFcn, ...
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


% --- Executes just before nit_EventOnset is made visible.
function nit_EventOnset_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nit_EventOnset (see VARARGIN)

% Choose default command line output for nit_EventOnset
handles.output = hObject;
handles.cfg.EventInfo = []; % event info
handles.cfg.fMRIOnset = 0;  % onset of fmri series (sec).
handles.cfg.fMRIDur = Inf;   % fMRI duration (sec).
handles.cfg.srate = [];     % EEG sampling rate
handles.cfg.matched = 1;    % 1-> match to fMRI timepoints; 0 -> not match.
handles.cfg.TR = 2;         % TR
handles.cfg.WithEventDur = 1;    % 1-> event onsets with duration; 0-> only event onset. 
handles.cfg.ExcludeBadBlock = 1; % 1-> Exclude events in Bad Block; 0-> DO NOT Exclude

try EEG = evalin('base','EEG');
    if ~isempty(EEG)
        try handles.cfg.srate = EEG.srate;
        catch, errordlg('EEG sampling rate is NULL!!!!','Data Error');
        end
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
            set(handles.listbox_Events,'String',Eventtypes);
        catch, errordlg('Event is empty!!!!','Event Error');
        end
    else
        errordlg('EEG is empty!!!!','Data Error');
    end
catch, errordlg('Failed to find EEG data!!!','Data Error');
end;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nit_EventOnset wait for user response (see UIRESUME)
% uiwait(handles.nit_EventOnset);


% --- Outputs from this function are returned to the command line.
function varargout = nit_EventOnset_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_Save.
function pushbutton_Save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
EventInfo = handles.cfg.EventInfo;
fMRIOnset = handles.cfg.fMRIOnset;  % onset of fmri series (sec).
fMRIDur = handles.cfg.fMRIDur;   % fMRI duration (sec).
flag1 = handles.cfg.WithEventDur;    % 1-> event onsets with duration; 0-> only event onset. 
flag2 = handles.cfg.ExcludeBadBlock; % 1-> Exclude events in Bad Block; 0-> DO NOT Exclude
try LogiVal = EventInfo.Eventtypes == 9999;
catch, LogiVal = cellfun(@(x) isequal(x,'9999'),EventInfo.Eventtypes);
end;
try EventInfo.events(1,1).duration;flag_dur = 1; % duration exist in event field?
catch, flag_dur = 0;
end;
srate = handles.cfg.srate;     % EEG sampling rate
flag3 = handles.cfg.matched;   % 1-> match to fMRI timepoints; 0 -> not match.
TR = handles.cfg.TR;           % TR
if isempty(fMRIDur)
    fMRIDur = inf;
end
if fMRIDur/TR ~= fix(fMRIDur/TR) && flag3 == 1
    errordlg('fMRI Duration must be is divisible by TR!!!!','Input Error');
    return;
end
if ~isempty(EventInfo) && ~isempty(srate)
    selectVal = get(handles.listbox_Events,'Value');
    selectStr = cellstr(get(handles.listbox_Events,'String'));
    selectStr = selectStr(selectVal);
    N_select = length(selectVal);
    Latencies = [];
    t1 = round(fMRIOnset * srate);
    t2 = round((fMRIOnset+fMRIDur) * srate); 
    for j = 1:N_select
        temp_index = EventInfo.TypeInd(1,selectVal(j)).index;
        temp_latency1 = [];
        temp_duration = [];
        for i = 1:length(temp_index)
            temp_latency1(i) = EventInfo.events(1,temp_index(i)).latency;
            try temp_duration(i) = EventInfo.events(1,temp_index(i)).duration;catch
            end
        end
        index1 = find(t1<temp_latency1 & temp_latency1<t2);
        temp_latency1 = temp_latency1(index1);
        % ---------
        % with event duration?
        if flag_dur == 1 && flag1 == 1
            if ~isempty(temp_duration) && ~isempty(temp_latency1)
                temp_duration = temp_duration(index1);
                temp2 = [];
                for j1 = 1:length(temp_latency1)
                    temp1 = temp_latency1(j1):(temp_latency1(j1) + temp_duration(j1));
                    temp2 = [temp2,temp1];
                end
                temp_latency1 = temp2;
            end
        end
        % ----------
        % exclude events in bad block
        if flag2 == 1 && sum(LogiVal) ~= 0 % exclude events in bad block?
            BadBlockInd = EventInfo.TypeInd(1,LogiVal).index;
            t1_Begin = [EventInfo.events(1,BadBlockInd).latency];
            t1_End = t1_Begin + [EventInfo.events(1,BadBlockInd).duration];
            for k = 1:length(t1_Begin)
                temp_latency1 = temp_latency1(temp_latency1<t1_Begin(k) | temp_latency1>t1_End(k));
            end
        end
        % ----------
        % match to fMRI timepoints?
        if flag3 == 1 && ~isempty(temp_latency1)
            temp_latency1 = ceil((temp_latency1-t1)./srate./TR);
            % temp_latency1(temp_latency1 == 0) = 1;
            temp_latency2 = unique(temp_latency1);
            if length(temp_latency1) ~= length(temp_latency2)
                disp(['Type-',selectStr{j},': Same events exist during one period of TR!']);
            end
            if isfinite(fMRIDur)
                temp_latency3 = zeros(round(fMRIDur/TR),1);
                temp_latency3(temp_latency2) = 1;
            else
                temp_latency3 = temp_latency2;
            end
            Latencies(1,j).latency = temp_latency3;
        elseif  isempty(temp_latency1)
            Latencies(1,j).latency = [];
        else
            temp_latency1 = temp_latency1./srate;
            temp_latency1(temp_latency1 == 0) = 1;
            temp_latency2 = unique(temp_latency1);
            Latencies(1,j).latency = temp_latency2;
        end
    end
    % ---------------
    % save
    [filename,pathname] = uiputfile({'*.xlsx','Excel';'*.xls','Excel 2003';'*.txt','Text';'*.mat','Matlab'},'Save Onsets');
    if ~isequal(filename,0) && ~isequal(pathname,0)
        fpath = fullfile(pathname,filename);
        [~, ~, ext] = fileparts(fpath);
        switch ext
            case '.xlsx'
                xlswrite(fpath,{[]},'A1:DZ10000');
                temp_data = [];
                for j = 1: length(Latencies)
                    temp_data{1,j} = ['Type-',selectStr{j}]; % first row is type
                    temp1 = Latencies(1,j).latency;  % event latency
                    for k = 1: length(temp1)
                        temp_data{k+1,j} = temp1(k);
                    end
                end
                xlswrite(fpath,temp_data);
            case '.xls'
                xlswrite(fpath,{[]},'A1:DZ10000');
                temp_data = [];
                for j = 1: length(Latencies)
                    temp_data{1,j} = ['Type-',selectStr{j}]; % first row is type
                    temp1 = Latencies(1,j).latency;  % event latency
                    for k = 1: length(temp1)
                        temp_data{k+1,j} = temp1(k);
                    end
                end
                xlswrite(fpath,temp_data);
            case '.txt'
                temp_data = [];
                for j = 1: length(Latencies)
                    temp_data{1,j} = ['Type-',selectStr{j}]; % first row is type
                    temp1 = Latencies(1,j).latency;  % event latency
                    for k = 1: length(temp1)
                        temp_data{k+1,j} = temp1(k);
                    end
                end
                fid = fopen(fpath,'w');
                for i = 1:size(temp_data,1)
                    for j = 1:size(temp_data,2)
                        if i == 1
                            fprintf(fid,'%s',temp_data{i,j});
                            fprintf(fid,' ');
                        else
                            fprintf(fid,'%e',temp_data{i,j});
                            fprintf(fid,' ');
                        end
                    end
                    fprintf(fid,'\r\n');
                end
                fclose(fid);
            case '.mat'
                % save as structure array (contain all parameter settings)
                Latencies.ParaSettings.type = selectStr;
                Latencies.ParaSettings.srate = srate;
                Latencies.ParaSettings.fMRIOnset = fMRIOnset;
                Latencies.ParaSettings.fMRIDur = fMRIDur;
                Latencies.ParaSettings.FlagMatch = flag3;
                Latencies.ParaSettings.TR = TR;
                Latencies.ParaSettings.FlagWithEventDur = flag_dur;
                Latencies.ParaSettings.FlagExcludeBadBlock = flag2;
                save(fpath,'Latencies');
                % save as cell array
%                 temp_data = [];
%                 for j = 1: length(Latencies)
%                     temp_data{1,j} = ['Type-',selectStr{j}]; % first row is type
%                     temp1 = Latencies(1,j).latency;  % event latency
%                     for k = 1: length(temp1)
%                         temp_data{k+1,j} = temp1(k);
%                     end
%                 end
%                 save(fpath,'temp_data');
        end
        msgbox('Event Info has saved!','Success','help');
    end
else
    errordlg('Event or sampling rate is NULL!!!!','Event Error');
    return;
end

% --- Executes on selection change in listbox_Events.
function listbox_Events_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_Events (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_Events contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_Events


% --- Executes during object creation, after setting all properties.
function listbox_Events_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_Events (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_fMRIOnset_Callback(hObject, eventdata, handles)
% hObject    handle to edit_fMRIOnset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_fMRIOnset as text
%        str2double(get(hObject,'String')) returns contents of edit_fMRIOnset as a double
fMRIOnset = str2num(get(hObject,'String'));
if length(fMRIOnset)==1
    if isempty(fMRIOnset) || fMRIOnset >= 0
        handles.cfg.fMRIOnset = fMRIOnset;
    end
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_fMRIOnset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_fMRIOnset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_fMRIDur_Callback(hObject, eventdata, handles)
% hObject    handle to edit_fMRIDur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_fMRIDur as text
%        str2double(get(hObject,'String')) returns contents of edit_fMRIDur as a double
fMRIDur = str2num(get(hObject,'String'));
if length(fMRIDur)==1
    if isempty(fMRIDur) || fMRIDur > 0
        handles.cfg.fMRIDur = fMRIDur;
    end
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_fMRIDur_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_fMRIDur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_Help.
function pushbutton_Help_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox({'Extract event onsets from EEG data during fMRI recording.';...
        '   fMRI Onset: Set the fMRI onset (sec). It should be >=0.';...
        '   fMRI Duration: Set the fMRI duration (sec). If = empty/negative/0, default is Inf.';...
        '   Match to fMRI timepoints?: Match event onsets to fMRI time scale.';...
        '   With Event duration?: Event onsets with duration (continuous times)';...
        '   Exclude Events in Bad Block?: Exclude events in the bad block (label-9999)';...
        '   TR: Reapting time (sec) of fMRI.';...
        '   Show Info: Show the No. of all events during from fMRI onset and end (NOT contain duration).'...
        },'Help');

% --- Executes on button press in pushbutton_info.
function pushbutton_info_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
EventInfo = handles.cfg.EventInfo;
fMRIOnset = handles.cfg.fMRIOnset;  % onset of fmri series (sec).
fMRIDur = handles.cfg.fMRIDur;   % fMRI duration (sec).
srate = handles.cfg.srate;     % EEG sampling rate
flag1 = handles.cfg.ExcludeBadBlock; % 1-> Exclude events in Bad Block; 0-> DO NOT Exclude
t1 = round(fMRIOnset * srate);
t2 = round((fMRIOnset+fMRIDur) * srate); 
ShowStr = cell(1,length(EventInfo.Eventtypes)+1);
ShowStr(1) = {'No. of events during period of fMRI!'};
if isempty(t2) % if duration is empty, default is inf.
    t2 = inf;
end
try LogiVal = EventInfo.Eventtypes == 9999;
catch, LogiVal = cellfun(@(x) isequal(x,'9999'),EventInfo.Eventtypes);
end;
if ischar(EventInfo.events(1).type) % event type is string?
    if flag1 == 1 && sum(LogiVal) ~= 0 % exclude events in bad block?
        BadBlockInd = EventInfo.TypeInd(1,LogiVal).index;
        t1_Begin = [EventInfo.events(1,BadBlockInd).latency];
        t1_End = t1_Begin + [EventInfo.events(1,BadBlockInd).duration];
        for j = 1:length(EventInfo.Eventtypes)
            if isequal(EventInfo.Eventtypes{j},'9999')
                tempInd = EventInfo.TypeInd(1,j).index;
                t3 = [EventInfo.events(1,tempInd).latency];
                t4 = t3(t3 >= t1 & t3 <= t2); % during fMRI
                ShowStr(j+1) = {['Type-',EventInfo.Eventtypes{j},'-> No. of events ',num2str(length(t4))]};
            else
                tempInd = EventInfo.TypeInd(1,j).index;
                t3 = [EventInfo.events(1,tempInd).latency];
                t4 = t3(t3 >= t1 & t3 <= t2); % during fMRI
                for k = 1:length(t1_Begin)    % exclude event onsets in bad block.
                    t4 = t4(t4<t1_Begin(k) | t4>t1_End(k));
                end
                ShowStr(j+1) = {['Type-',EventInfo.Eventtypes{j},'-> No. of events ',num2str(length(t4))]};
            end
        end
    else
        for j = 1:length(EventInfo.Eventtypes)
            tempInd = EventInfo.TypeInd(1,j).index;
            t3 = [EventInfo.events(1,tempInd).latency];
            t4 = t3(t3 >= t1 & t3 <= t2); % during fMRI
            ShowStr(j+1) = {['Type-',EventInfo.Eventtypes{j},'-> No. of events ',num2str(length(t4))]};
        end
    end
else
    if flag1 == 1 && sum(LogiVal) ~= 0 % exclude events in bad block?
        BadBlockInd = EventInfo.TypeInd(1,LogiVal).index;
        t1_Begin = [EventInfo.events(1,BadBlockInd).latency];
        t1_End = t1_Begin + [EventInfo.events(1,BadBlockInd).duration];
        for j = 1:length(EventInfo.Eventtypes)
            if isequal(EventInfo.Eventtypes(j),9999)
                tempInd = EventInfo.TypeInd(1,j).index;
                t3 = [EventInfo.events(1,tempInd).latency];
                t4 = t3(t3 >= t1 & t3 <= t2); % during fMRI
                ShowStr(j+1) = {['Type-',num2str(EventInfo.Eventtypes(j)),'-> No. of events ',num2str(length(t4))]};
            else
                tempInd = EventInfo.TypeInd(1,j).index;
                t3 = [EventInfo.events(1,tempInd).latency];
                t4 = t3(t3 >= t1 & t3 <= t2); % during fMRI
                for k = 1:length(t1_Begin)    % exclude event onsets in bad block.
                    t4 = t4(t4<t1_Begin(k) | t4>t1_End(k));
                end
                ShowStr(j+1) = {['Type-',num2str(EventInfo.Eventtypes(j)),'-> No. of events ',num2str(length(t4))]};
            end
        end
    else
        for j = 1:length(EventInfo.Eventtypes)
            tempInd = EventInfo.TypeInd(1,j).index;
            t3 = [EventInfo.events(1,tempInd).latency];
            t4 = t3(t3 >= t1 & t3 <= t2); % during fMRI
            ShowStr(j+1) = {['Type-',num2str(EventInfo.Eventtypes(j)),'-> No. of events ',num2str(length(t4))]};
        end
    end
end
set(handles.listbox_EventInfo,'String',ShowStr);
% Update handles structure
guidata(hObject, handles);



function edit_TR_Callback(hObject, eventdata, handles)
% hObject    handle to edit_TR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_TR as text
%        str2double(get(hObject,'String')) returns contents of edit_TR as a double
TR = str2double(get(hObject,'String'));
if isfinite(TR) && TR >0
    handles.cfg.TR = TR;
else
    errordlg('TR must be finite and > 0!!!!','Parameter Error');
    return;
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_TR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_TR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_Matched.
function checkbox_Matched_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_Matched (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_Matched
value = get(hObject,'Value');
handles.cfg.matched = value;
if value == 0
    set(handles.edit_TR,'enable','off');
else
    set(handles.edit_TR,'enable','on');
end
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


% --- Executes on button press in checkbox_WithEventDur.
function checkbox_WithEventDur_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_WithEventDur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_WithEventDur
value = get(hObject,'Value');
handles.cfg.WithEventDur = value;
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in checkbox_ExcludeBadBlock.
function checkbox_ExcludeBadBlock_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_ExcludeBadBlock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_ExcludeBadBlock
value = get(hObject,'Value');
handles.cfg.ExcludeBadBlock = value;
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(nit_EventOnset);
