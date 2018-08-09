function varargout = nit_ExtractPower(varargin)
% NIT_EXTRACTPOWER MATLAB code for nit_ExtractPower.fig
%      NIT_EXTRACTPOWER, by itself, creates a new NIT_EXTRACTPOWER or raises the existing
%      singleton*.
%
%      H = NIT_EXTRACTPOWER returns the handle to a new NIT_EXTRACTPOWER or the handle to
%      the existing singleton*.
%
%      NIT_EXTRACTPOWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NIT_EXTRACTPOWER.M with the given input arguments.
%
%      NIT_EXTRACTPOWER('Property','Value',...) creates a new NIT_EXTRACTPOWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nit_ExtractPower_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nit_ExtractPower_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help nit_ExtractPower

% Last Modified by GUIDE v2.5 27-Oct-2015 14:18:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nit_ExtractPower_OpeningFcn, ...
                   'gui_OutputFcn',  @nit_ExtractPower_OutputFcn, ...
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


% --- Executes just before nit_ExtractPower is made visible.
function nit_ExtractPower_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nit_ExtractPower (see VARARGIN)

% Choose default command line output for nit_ExtractPower
handles.output = hObject;
handles.cfg.timefreqflag = 0;
handles.cfg.SelectChanns = [];     % Selected EEG channels.
handles.cfg.SelectEvent = [];      % Selected Events.
handles.cfg.EventInfo = [];        % event info
handles.cfg.Hz1 = 1;              % frequency band 1.
handles.cfg.Hz2 = 4;              % frequency band 2.
handles.cfg.ModelSelectFlag = 1;   % Model Select (1->continuous data; 2->discharge epoch; 3->event epoch).
handles.cfg.srate = [];            % sampling rate.
handles.cfg.EpochTimeRange = [];   % Epoch time range.[min max] (msec).
handles.cfg.WaveletCycles = 0;     % Wavelet Cycles.
handles.cfg.TaperingFunction = 'hanning';   % FFT Tapering Function.
handles.cfg.WaveletMethod = 'dftfilt3';     % Wavelet Method/Program.
handles.cfg.NormalizeFlag = 1;              % Normalize?
handles.cfg.DetrendFlag = 1;                % Detrend before fft?
handles.cfg.ExcludBadBlockFlag = 1;         % Exclude bad block?
handles.cfg.MeanPowerFlag = 1;              % Calculate mean power across selected channels?

handles.cfg.fMRIOnset = 0;      % fMRI Onset(sec).
handles.cfg.fMRIDur = Inf; % fMRI Duration (sec).
handles.cfg.MatchFlag = 1;      % Match to fMRI timepoints?
handles.cfg.TR = 2;             % TR (sec).
try EEG = evalin('base','EEG');
    if ~isempty(EEG)
        try EEG.data;
            if ~isempty(EEG.data)
                handles.cfg.EEG = EEG;
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

disp(['Adding timefreq path to all EEGLAB functions']);
p = which('nit_EEG.m');
p = p(1:findstr(p,'nit_EEG.m')-1);
if strcmpi(p, './') || strcmpi(p, '.\'), p = [ pwd filesep ]; end;
if handles.cfg.timefreqflag == 0
    aadpathifnotexist( [ p 'timefreqfunc' filesep ], 'timefreq.m');
    handles.cfg.timefreq = 1;
end
% Update handles structure
guidata(hObject, handles);
function aadpathifnotexist(newpath, functionname);
tmpp = which(functionname);
if isempty(tmpp)
    addpath(newpath);
end;

% UIWAIT makes nit_ExtractPower wait for user response (see UIRESUME)
% uiwait(handles.nit_ExtractPower);


% --- Outputs from this function are returned to the command line.
function varargout = nit_ExtractPower_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_SelectChanns.
function pushbutton_SelectChanns_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_SelectChanns (see GCBO)
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


% --- Executes on button press in checkbox_matchedfMRI.
function checkbox_matchedfMRI_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_matchedfMRI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_matchedfMRI
value = get(hObject,'Value');
handles.cfg.MatchFlag = value;
if value == 1
    set(handles.edit_TR,'Enable','on');
else
    set(handles.edit_TR,'Enable','off');
end
% Update handles structure
guidata(hObject, handles);

function edit_TR_Callback(hObject, eventdata, handles)
% hObject    handle to edit_TR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_TR as text
%        str2double(get(hObject,'String')) returns contents of edit_TR as a double

handles.cfg.TR = str2num(get(hObject,'String'));
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



function edit_fMRIOnset_Callback(hObject, eventdata, handles)
% hObject    handle to edit_fMRIOnset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_fMRIOnset as text
%        str2double(get(hObject,'String')) returns contents of edit_fMRIOnset as a double
handles.cfg.fMRIOnset = str2double(get(hObject,'String'));
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



function edit_fMRIDura_Callback(hObject, eventdata, handles)
% hObject    handle to edit_fMRIDura (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_fMRIDura as text
%        str2double(get(hObject,'String')) returns contents of edit_fMRIDura as a double

handles.cfg.fMRIDur = str2double(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_fMRIDura_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_fMRIDura (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkbox_BadBlockFlag.
function checkbox_BadBlockFlag_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_BadBlockFlag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_BadBlockFlag

handles.cfg.ExcludBadBlockFlag = get(hObject,'Value');
% Update handles structure
guidata(hObject, handles);

function edit_EpochTimeRange_Callback(hObject, eventdata, handles)
% hObject    handle to edit_EpochTimeRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_EpochTimeRange as text
%        str2double(get(hObject,'String')) returns contents of edit_EpochTimeRange as a double
handles.cfg.EpochTimeRange = str2num(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_EpochTimeRange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_EpochTimeRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_WaveletCycles_Callback(hObject, eventdata, handles)
% hObject    handle to edit_WaveletCycles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_WaveletCycles as text
%        str2double(get(hObject,'String')) returns contents of edit_WaveletCycles as a double

handles.cfg.WaveletCycles = str2num(get(hObject,'String'));   % Wavelet Cycles.
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_WaveletCycles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_WaveletCycles (see GCBO)
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
% ---------------
if evalin('base','exist(''MeanPower'')')==1 % MeanPower exist in the workspace?
    MeanPower = evalin('base','MeanPower');
    if ~isempty(MeanPower)
        % save
        [filename,pathname] = uiputfile({'*.xlsx','Excel';'*.xls','Excel 2003';'*.txt','Text';'*.mat','Matlab'},'Save Onsets');
        if ~isequal(filename,0) && ~isequal(pathname,0)
            fpath = fullfile(pathname,filename);
            [~, ~, ext] = fileparts(fpath);
            switch ext
                case '.xlsx'
                    % generate cell array for saving
                    Np = length(MeanPower);
                    PowerMatrix = [];
                    for i = 1:Np
                        temp_data = [];
                        [d1,d2] = size(MeanPower(i).power);
                        for j = 1:d1
                            % first row is label info
                            switch MeanPower(i).model
                                case 1
                                    if d1>1
                                        temp_data{1,j} = [MeanPower(i).label,'-',num2str(MeanPower(i).channs{j})];
                                    else
                                        temp_data{1,j} = [MeanPower(i).label];
                                    end
                                case 2
                                    if d1>1
                                        temp_data{1,j} = ['Type-',num2str(MeanPower(i).type),'-',...
                                            MeanPower(i).label,'-',num2str(MeanPower(i).channs{j})];
                                    else
                                        temp_data{1,j} = ['Type-',num2str(MeanPower(i).type),'-',MeanPower(i).label];
                                    end
                                case 3
                                    if d1>1
                                        temp_data{1,j} = ['Event-',num2str(MeanPower(i).type),'-',...
                                            MeanPower(i).label,'-',num2str(MeanPower(i).channs{j})];
                                    else
                                        temp_data{1,j} = ['Event-',num2str(MeanPower(i).type),'-',MeanPower(i).label];
                                    end
                            end
                            % data
                            for k = 1:d2
                                temp_data{k+1,j} = MeanPower(i).power(j,k);
                            end
                        end
                        PowerMatrix = [PowerMatrix,temp_data];
                    end
                    % ---------------------
                    xlswrite(fpath,{[]},'A1:DZ10000');
                    xlswrite(fpath,PowerMatrix);
                case '.xls'
                    % generate cell array for saving
                    Np = length(MeanPower);
                    PowerMatrix = [];
                    for i = 1:Np
                        temp_data = [];
                        [d1,d2] = size(MeanPower(i).power);
                        for j = 1:d1
                            % first row is label info
                            switch MeanPower(i).model
                                case 1
                                    if d1>1
                                        temp_data{1,j} = [MeanPower(i).label,'-',num2str(MeanPower(i).channs{j})];
                                    else
                                        temp_data{1,j} = [MeanPower(i).label];
                                    end
                                case 2
                                    if d1>1
                                        temp_data{1,j} = ['Type-',num2str(MeanPower(i).type),'-',...
                                            MeanPower(i).label,'-',num2str(MeanPower(i).channs{j})];
                                    else
                                        temp_data{1,j} = ['Type-',num2str(MeanPower(i).type),'-',MeanPower(i).label];
                                    end
                                case 3
                                    if d1>1
                                        temp_data{1,j} = ['Event-',num2str(MeanPower(i).type),'-',...
                                            MeanPower(i).label,'-',num2str(MeanPower(i).channs{j})];
                                    else
                                        temp_data{1,j} = ['Event-',num2str(MeanPower(i).type),'-',MeanPower(i).label];
                                    end
                            end
                            % data
                            for k = 1:d2
                                temp_data{k+1,j} = MeanPower(i).power(j,k);
                            end
                        end
                        PowerMatrix = [PowerMatrix,temp_data];
                    end
                    % ---------------------
                    xlswrite(fpath,{[]},'A1:DZ10000');
                    xlswrite(fpath,PowerMatrix);
                case '.txt'
                    % generate cell array for saving
                    Np = length(MeanPower);
                    PowerMatrix = [];
                    for i = 1:Np
                        temp_data = [];
                        [d1,d2] = size(MeanPower(i).power);
                        for j = 1:d1
                            % first row is label info
                            switch MeanPower(i).model
                                case 1
                                    if d1>1
                                        temp_data{1,j} = [MeanPower(i).label,'-',num2str(MeanPower(i).channs{j})];
                                    else
                                        temp_data{1,j} = [MeanPower(i).label];
                                    end
                                case 2
                                    if d1>1
                                        temp_data{1,j} = ['Type-',num2str(MeanPower(i).type),'-',...
                                            MeanPower(i).label,'-',num2str(MeanPower(i).channs{j})];
                                    else
                                        temp_data{1,j} = ['Type-',num2str(MeanPower(i).type),'-',MeanPower(i).label];
                                    end
                                case 3
                                    if d1>1
                                        temp_data{1,j} = ['Event-',num2str(MeanPower(i).type),'-',...
                                            MeanPower(i).label,'-',num2str(MeanPower(i).channs{j})];
                                    else
                                        temp_data{1,j} = ['Event-',num2str(MeanPower(i).type),'-',MeanPower(i).label];
                                    end
                            end
                            % data
                            for k = 1:d2
                                temp_data{k+1,j} = MeanPower(i).power(j,k);
                            end
                        end
                        PowerMatrix = [PowerMatrix,temp_data];
                    end
                    % ---------------------
                    fid = fopen(fpath,'w');
                    for i = 1:size(PowerMatrix,1)
                        for j = 1:size(PowerMatrix,2)
                            if i == 1
                                fprintf(fid,'%s',PowerMatrix{i,j});
                                fprintf(fid,' ');
                            else
                                fprintf(fid,'%e',PowerMatrix{i,j});
                                fprintf(fid,' ');
                            end
                        end
                        fprintf(fid,'\r\n');
                    end
                    fclose(fid);
                case '.mat'
                    save(fpath,'MeanPower');
            end
            msgbox('Power has saved!','Success','help');
        end
    else
        errordlg('MeanPower is empty!!!!','Data Error');
        return;
    end
else
    errordlg('MeanPower is NULL!!!!','Data Error');
    return;
end


% --- Executes on button press in pushbutton_HelpEEG.
function pushbutton_HelpEEG_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_HelpEEG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox({'EEG settings: ';...
        '   Select Channels: Select channels you want to calculate.';...
        '   Select Event/Type: Select Event/Type you interested.';...
        '   '' ''~'' ''Hz: Select frequecy band you interested.';...
        '   Model Select: ';...
        '        Extract Power From Continuous Data: time-frequecy analysis is conducted in continuous time periods (if check ''Match to fMRI timepoints?'',period = 1 TR; if not, period = 1 sec);';...
        '        Extract Power From Discharge Epoch: time-frequecy analysis is conducted in each discharge period;';...
        '        Extract Power From Event Epoch: time-frequecy analysis is conducted in each event epoch.';...
        '   EEG Sampling Rate: It can be automatically filled. If failed, please fill it by hand.';...
        '   Epoch Time Range [min max] (msec): In the epoch time range,''min'' must be <= 0;''max'' must be >0.';...
        '   Wavelet Cycles: [real] indicates the number of cycles for the time-frequency decomposition.More details can be seen help in ''timefreq.m''.';...
        '   FFT Tapering Function: FFT tapering function. Default is ''hanning''. Note that ''hamming'' and ''blackmanharris'' require the signal processing toolbox.';...
        '   Wavelet Method/Program: Wavelet method/program to use.''dftfilt2'': Morlet-variant or Hanning DFT; ''dftfilt3'': Morlet wavelet or Hanning DFT (exact Tallon Baudry).';...
        '   Normalize?: Power vector is normalized by subtracting the minimum value and dividing by the difference of maximum and minimum values';...
        '   Detrend?: Linearly detrend each data epoch.Default is ''on''.';...
        '   Exclude Powers in Bad Block (label 9999)?: Exculde power values in the bad block (label 9999).';...
        '   Mean Power Across Channels?: Obtain mean power across selected channels.';...
        },'Help');

% --- Executes on button press in checkbox_MeanPowerFlag.
function checkbox_MeanPowerFlag_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_MeanPowerFlag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_MeanPowerFlag
handles.cfg.MeanPowerFlag = get(hObject,'Value');
% Update handles structure
guidata(hObject, handles);

% --- Executes on selection change in popupmenu_Freq.
function popupmenu_Freq_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_Freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_Freq contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_Freq
value = get(hObject,'Value');
switch value
    case 1 % delta
        Hz1 = 1;
        Hz2 = 4;
        handles.cfg.Hz1 = Hz1;              % frequency band 1.
        handles.cfg.Hz2 = Hz2;              % frequency band 2.
        set(handles.edit_Hz1,'string',num2str(Hz1),'Enable','off');
        set(handles.edit_Hz2,'string',num2str(Hz2),'Enable','off');
    case 2 % theta
        Hz1 = 4;
        Hz2 = 8;
        handles.cfg.Hz1 = Hz1;              % frequency band 1.
        handles.cfg.Hz2 = Hz2;              % frequency band 2.
        set(handles.edit_Hz1,'string',num2str(Hz1),'Enable','off');
        set(handles.edit_Hz2,'string',num2str(Hz2),'Enable','off');
    case 3 % alpha
        Hz1 = 8;
        Hz2 = 13;
        handles.cfg.Hz1 = Hz1;              % frequency band 1.
        handles.cfg.Hz2 = Hz2;              % frequency band 2.
        set(handles.edit_Hz1,'string',num2str(Hz1),'Enable','off');
        set(handles.edit_Hz2,'string',num2str(Hz2),'Enable','off');
    case 4 % beta
        Hz1 = 13;
        Hz2 = 30;
        handles.cfg.Hz1 = Hz1;              % frequency band 1.
        handles.cfg.Hz2 = Hz2;              % frequency band 2.
        set(handles.edit_Hz1,'string',num2str(Hz1),'Enable','off');
        set(handles.edit_Hz2,'string',num2str(Hz2),'Enable','off');
    case 5 % Gamma
        Hz1 = 30;
        Hz2 = 40;
        handles.cfg.Hz1 = Hz1;              % frequency band 1.
        handles.cfg.Hz2 = Hz2;              % frequency band 2.
        set(handles.edit_Hz1,'string',num2str(Hz1),'Enable','off');
        set(handles.edit_Hz2,'string',num2str(Hz2),'Enable','off');
    case 6 % user defined
        handles.cfg.Hz1 = [];              % frequency band 1.
        handles.cfg.Hz2 = [];              % frequency band 2.
        set(handles.edit_Hz1,'string',[],'Enable','on');
        set(handles.edit_Hz2,'string',[],'Enable','on');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu_Freq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_Freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Hz1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Hz1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Hz1 as text
%        str2double(get(hObject,'String')) returns contents of edit_Hz1 as a double

handles.cfg.Hz1 = str2num(get(hObject,'String'));           % frequence band 1.
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_Hz1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Hz1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Hz2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Hz2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Hz2 as text
%        str2double(get(hObject,'String')) returns contents of edit_Hz2 as a double
handles.cfg.Hz2 = str2num(get(hObject,'String'));           % frequence band 2.
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_Hz2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Hz2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_NormalizeFlag.
function checkbox_NormalizeFlag_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_NormalizeFlag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_NormalizeFlag
handles.cfg.NormalizeFlag = get(hObject,'Value');
% Update handles structure
guidata(hObject, handles);

% --- Executes on selection change in popupmenu_TaperingFunc.
function popupmenu_TaperingFunc_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_TaperingFunc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_TaperingFunc contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_TaperingFunc
contents = cellstr(get(hObject,'String'));
value = get(hObject,'Value');
handles.cfg.TaperingFunction = contents{value};
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupmenu_TaperingFunc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_TaperingFunc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_WaveletMethod.
function popupmenu_WaveletMethod_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_WaveletMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_WaveletMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_WaveletMethod
contents = cellstr(get(hObject,'String'));
value = get(hObject,'Value');
handles.cfg.WaveletMethod = contents{value};
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu_WaveletMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_WaveletMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_Run.
function pushbutton_Run_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

rawBackgroundColor = get(hObject ,'BackgroundColor');
set(hObject ,'Enable', 'off','BackgroundColor', 'red');
set(handles.pushbutton_cancel ,'Enable', 'off');
drawnow;
EEG =  handles.cfg.EEG;
if isempty(EEG)
    errordlg('EEG is empty!!!!','Data Error');
    set(hObject,'Enable', 'on','BackgroundColor', rawBackgroundColor);
    set(handles.pushbutton_cancel ,'Enable', 'on');
    return;
end;

SelectChanns = handles.cfg.SelectChanns;     % Selected EEG channels.
if isempty(SelectChanns)
    errordlg('Please select channels!!!','Parameter Error');
    set(hObject,'Enable', 'on','BackgroundColor', rawBackgroundColor);
    set(handles.pushbutton_cancel ,'Enable', 'on');
    return;
end;

Hz1 = handles.cfg.Hz1;              % frequency band 1.
Hz2 = handles.cfg.Hz2;              % frequency band 2.
if isempty(Hz1) && isempty(Hz2)
    errordlg('At least 1 positive frequency!!!','Parameter Error');
    set(hObject,'Enable', 'on','BackgroundColor', rawBackgroundColor);
    set(handles.pushbutton_cancel ,'Enable', 'on');
    return;
else
    if isempty(Hz1)
        Hz1 = 0;
        if Hz2 <=0
            errordlg('At least 1 positive frequency!!!','Parameter Error');
            set(hObject,'Enable', 'on','BackgroundColor', rawBackgroundColor);
            set(handles.pushbutton_cancel ,'Enable', 'on');
            return;
        end
    elseif isempty(Hz2)
        Hz2 = Inf;
        if Hz1 <=0
            errordlg('At least 1 positive frequency!!!','Parameter Error');
            set(hObject,'Enable', 'on','BackgroundColor', rawBackgroundColor);
            set(handles.pushbutton_cancel ,'Enable', 'on');
            return;
        end
    else
        if Hz1 <=0 && Hz2 <=0
            errordlg('At least 1 positive frequency!!!','Parameter Error');
            set(hObject,'Enable', 'on','BackgroundColor', rawBackgroundColor);
            set(handles.pushbutton_cancel ,'Enable', 'on');
            return;
        end
    end
end;

model = handles.cfg.ModelSelectFlag;   % Model Select (1->continuous data; 2->discharge epoch; 3->event epoch).
srate = handles.cfg.srate;            % sampling rate.
if isempty(srate)
    errordlg('Sampling rate must be > 0!!!','Parameter Error');
    set(hObject,'Enable', 'on','BackgroundColor', rawBackgroundColor);
    set(handles.pushbutton_cancel ,'Enable', 'on');
    return;
end;

WaveletCycles = handles.cfg.WaveletCycles;     % Wavelet Cycles.
if ~isreal(WaveletCycles) || all(WaveletCycles<0)
    errordlg('Wavelet cycles should be 0 or real positive scalar!!!','Parameter Error');
    set(hObject,'Enable', 'on','BackgroundColor', rawBackgroundColor);
    set(handles.pushbutton_cancel ,'Enable', 'on');
    return;
end;

TaperingFunction = handles.cfg.TaperingFunction;   % FFT Tapering Function.
WaveletMethod = handles.cfg.WaveletMethod;         % Wavelet Method/Program.
NormalizeFlag = handles.cfg.NormalizeFlag;         % Normalize?
DetrendFlag = handles.cfg.DetrendFlag;             % Detrend?
if DetrendFlag == 1
    DetrendStr = 'on';
else
    DetrendStr = 'off';
end
BadBlockFlag = handles.cfg.ExcludBadBlockFlag;     % Exclude bad block?
MeanPowerFlag = handles.cfg.MeanPowerFlag;         % Calculate mean power across selected channels?

fMRIOnset = handles.cfg.fMRIOnset;      % fMRI Onset(sec).
if isempty(fMRIOnset) || fMRIOnset<0 || length(fMRIOnset)>1 || ~isreal(fMRIOnset)
    fMRIOnset = 0;
end;

fMRIDur = handles.cfg.fMRIDur; % fMRI Duration (sec).
if isempty(fMRIDur) || fMRIDur < 0 || length(fMRIDur)>1 || ~isreal(fMRIDur)
    fMRIDur = Inf;
end;
MatchFlag = handles.cfg.MatchFlag;      % Match to fMRI timepoints?
if MatchFlag == 1
    TR = handles.cfg.TR;  % TR (sec).
    if any(~isfinite(TR)) || any(TR <= 0) || length(TR)>1
        errordlg('TR must be a real positive scalar!!!','Parameter Error');
        set(hObject,'Enable', 'on','BackgroundColor', rawBackgroundColor);
        set(handles.pushbutton_cancel ,'Enable', 'on');
        return;
    end;
end
% run
switch model
    case 1
        % --------------------------------------
        % display settings:
        disp('--------------------------');
        disp(['Model Select:',num2str(model),' -> Extract Power From Continuous Data']);
        disp('Select Channels: ');
        disp(SelectChanns.cellchannames);
        disp(['Frequcey Band -> ',num2str(Hz1),'~',num2str(Hz2),' Hz']);
        disp(['Sampling Rate -> ',num2str(srate),' Hz']);
        disp(['Wavelet Cycles -> ',num2str(WaveletCycles)]);
        disp(['FFT Tapering Funtion -> ',TaperingFunction]);
        disp(['Wavelet Method/Program -> ',WaveletMethod]);
        disp(['Normalize? -> ',num2str(NormalizeFlag)]);
        disp(['Detrend? -> ',num2str(DetrendFlag)]);
        disp(['Exclude Bad Block (label 9999)? -> ',num2str(BadBlockFlag)]);
        disp(['Mean Power Across Channels? -> ',num2str(MeanPowerFlag)]);
        disp(['Downsample to fMRI timepoints? -> ',num2str(MatchFlag)]);
        disp(['fMRI Onset (sec) -> ',num2str(fMRIOnset)]);
        disp(['fMRI Duration (sec) -> ', num2str(fMRIDur)]);
        try disp(['TR (sec) -> ',num2str(TR)]);catch;end;
        disp('--------------------------');
        % -------------------------------------
        % calculate power using time-frequency analysis
        temp_data1 = EEG.data(SelectChanns.chanlist,:); % selected data
        [Nchanns,timeLenth_1] = size(temp_data1); % number of selected channels and length of data
        t1 = round(fMRIOnset * srate);
        t2 = round((fMRIOnset+fMRIDur) * srate); 
        index1 = 1:timeLenth_1;
        index2 = find(t1<index1 & index1<=t2);
        temp_data2 = temp_data1(:,index2);
        timeLenth_2 = size(temp_data2,2);
        % generate epoch for time-frequency analysis
        if MatchFlag==1
            EpochLenth = round(srate*TR);
        else
            EpochLenth = round(srate);
        end
        temp1 = 1:EpochLenth:timeLenth_2;
        temp2 = EpochLenth:EpochLenth:timeLenth_2;
        if length(temp2)==length(temp1)
            epochs = [temp1',temp2'];
        else
            epochs = [temp1',[temp2';timeLenth_2]];
        end
        % calculate power
        N_epoch = size(epochs,1);
        Y_power = zeros(Nchanns,N_epoch);
        for i = 1:Nchanns
            for j = 1: N_epoch
               temp_data4 = temp_data2(i,epochs(j,1):epochs(j,2));
                [tf, freqs, ~] = timefreq(temp_data4,...
                    srate,'cycles',WaveletCycles,'wletmethod',WaveletMethod,...
                    'ffttaper',TaperingFunction,'detrend',DetrendStr);
                temp_power = 2*abs(tf).^2/length(temp_data4); % power
                temp_MeanPower = mean(temp_power,2);
                Y_power(i,j) = mean(temp_MeanPower(freqs>Hz1 & freqs<Hz2,:));
            end
        end
        % exclude bad block?
        if BadBlockFlag == 1
            EventInfo = handles.cfg.EventInfo;        % event info
            if isempty(EventInfo)
                errordlg('No event info in EEG data,please UNCHECK ''Exclude Powers in Bad Block (label 9999)''!!!','BadBlock Error');
                set(hObject,'Enable', 'on','BackgroundColor', rawBackgroundColor);
                set(handles.pushbutton_cancel ,'Enable', 'on');
                return;
            end;
            try LogiVal = EventInfo.Eventtypes == 9999;
            catch, LogiVal = cellfun(@(x) isequal(x,'9999'), EventInfo.Eventtypes);
            end;
            IndexInd = EventInfo.TypeInd(1,LogiVal);
            if ~isempty(IndexInd)
                BadBlocks = EventInfo.events(IndexInd.index);
                IndBadBlock = zeros(1,timeLenth_1);
                for k1 = 1:length(BadBlocks)
                    IndBadBlock(BadBlocks(1,k1).latency:BadBlocks(1,k1).latency+BadBlocks(1,k1).duration)=1;
                end
                IndBadBlock = IndBadBlock(index2);
                for k2 = 1:N_epoch
                    if sum(IndBadBlock(epochs(k2,1):epochs(k2,2)))~=0
                        Y_power(:,k2) = 0;
                    end
                end
            end
        end
        % mean power across channels?
        if MeanPowerFlag == 1
            Y_power = mean(Y_power,1);
        end
        % normalize?
        if NormalizeFlag == 1
            for i = 1:size(Y_power,1)
                Y_power(i,:) = (Y_power(i,:) - min(Y_power(i,:)))./ (max(Y_power(i,:))-min(Y_power(i,:)));
            end
        end
        % ---------------------
        % assign to workspace
        MeanPower.power = Y_power;
        Freq_str = get(handles.popupmenu_Freq,'string');
        freq_str_select = Freq_str(get(handles.popupmenu_Freq,'value'));
        MeanPower.label = [freq_str_select{1},':',num2str(Hz1),'-',num2str(Hz2),'Hz'];
        MeanPower.channs = SelectChanns.cellchannames;
        MeanPower.type = [];
        MeanPower.model = model;
        
        MeanPower.ParaSettings.srate = srate;
        MeanPower.ParaSettings.epoch = [];
        MeanPower.ParaSettings.WaveletCycles = WaveletCycles;
        MeanPower.ParaSettings.TaperingFunction = TaperingFunction;
        MeanPower.ParaSettings.WaveletMethod = WaveletMethod;
        MeanPower.ParaSettings.NormalizeFlag = NormalizeFlag;
        MeanPower.ParaSettings.DetrendFlag = DetrendFlag;
        MeanPower.ParaSettings.ExcludeBadBlockFlag = BadBlockFlag;
        MeanPower.ParaSettings.MeanPowerFlag = MeanPowerFlag;
        MeanPower.ParaSettings.fMRIOnset = fMRIOnset;
        MeanPower.ParaSettings.fMRIDur = fMRIDur;
        MeanPower.ParaSettings.MatchFlag = MatchFlag;
        if MatchFlag == 1
            MeanPower.ParaSettings.TR = TR;
        end
        
        if evalin('base','exist(''MeanPower'')')==0 % MeanPower exist in the workspace?
           assignin('base','MeanPower',MeanPower);
        else
            assignin('base','MeanPower',[evalin('base','MeanPower'),MeanPower]);
        end
    case 2
        SelectEvent = handles.cfg.SelectEvent;    % Selected Events.
        if isempty(SelectEvent)
            errordlg('Please select types!!!','Parameter Error');
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
        % --------------------------------------
        % display settings:
        disp('--------------------------');
        disp(['Model Select:',num2str(model), '-> Extract Power From Discharge Epoch']);
        disp('Select Channels: ');
        disp(SelectChanns.cellchannames);
        disp('Select Types:');
        disp(SelectEvent.celleventnames);
        disp(['Frequcey Band -> ',num2str(Hz1),'~',num2str(Hz2),' Hz']);
        disp(['Sampling Rate -> ',num2str(srate),' Hz']);
        disp(['Wavelet Cycles -> ',num2str(WaveletCycles)]);
        disp(['FFT Tapering Funtion -> ',TaperingFunction]);
        disp(['Wavelet Method/Program -> ',WaveletMethod]);
        disp(['Normalize? -> ',num2str(NormalizeFlag)]);
        disp(['Detrend? -> ',num2str(DetrendFlag)]);
        disp(['Exclude Bad Block (label 9999)? -> ',num2str(BadBlockFlag)]);
        disp(['Mean Power Across Channels? -> ',num2str(MeanPowerFlag)]);
        disp(['Downsample to fMRI timepoints? -> ',num2str(MatchFlag)]);
        disp(['fMRI Onset (sec) -> ',num2str(fMRIOnset)]);
        disp(['fMRI Duration (sec) -> ', num2str(fMRIDur)]);
        try disp(['TR (sec) -> ',num2str(TR)]);catch;end;
        disp('--------------------------');
        % -------------------------------------
        % calculate power using time-frequency analysis
        temp_data1 = EEG.data(SelectChanns.chanlist,:); % selected data
        [Nchanns,timeLenth_1] = size(temp_data1); % number of selected channels
        t1 = round(fMRIOnset * srate);
        t2 = round((fMRIOnset+fMRIDur) * srate); 
        index1 = 1:timeLenth_1;
        index2 = find(t1<index1 & index1<=t2);
        temp_data2 = temp_data1(:,index2);
        timeLenth_2 = size(temp_data2,2); % time points of fMRI duration
        % calculate power
        N_type = length(SelectEvent.celleventnames); % number of selected types
        Y_power = [];
        for i = 1:N_type
            TypeInd = EventInfo.TypeInd(SelectEvent.eventlist(i)).index;
            N_epoch = length(TypeInd);
            Y_power_1 = zeros(Nchanns,timeLenth_2);
            TypeEpochs = EventInfo.events(TypeInd);
            for k = 1:N_epoch
                temp1 = zeros(1,timeLenth_1);
                temp1(TypeEpochs(1,k).latency:TypeEpochs(1,k).latency+TypeEpochs(1,k).duration) = 1;
                temp2 = temp1(index2);
                if any(temp2)
                    for j = 1:Nchanns
                        temp_data3 = temp_data2(j,temp2==1);
                        [tf, freqs, ~] = timefreq(temp_data3,...
                            srate,'cycles',WaveletCycles,'wletmethod',WaveletMethod,...
                            'ffttaper',TaperingFunction,'detrend',DetrendStr);
                        temp_power1 = 2*abs(tf).^2/length(temp_data3); % power
                        temp_MeanPower = mean(temp_power1,2);
                        temp_power2 = mean(temp_MeanPower(freqs>Hz1 & freqs<Hz2,:));
                        Y_power_1(j,temp2==1) = temp_power2;
                    end
                end
            end
            Y_power(1,i).power = Y_power_1;
            Y_power(1,i).type = EventInfo.Eventtypes(SelectEvent.eventlist(i));
        end
        % match to TR/sec scale
        if MatchFlag == 1
            ScaleLenth = round(srate*TR);
        else
            ScaleLenth = round(srate);
        end
        temp3 = 1:ScaleLenth:timeLenth_2;
        temp4 = ScaleLenth:ScaleLenth:timeLenth_2;
        if length(temp3)==length(temp4)
            Scales = [temp3',temp4'];
        else
            Scales = [temp3',[temp4';timeLenth_2]];
        end
        for i = 1:N_type
            ScalePower = zeros(size(Y_power(1,i).power,1),size(Scales,1));
            for j = 1:size(Scales,1)
                temp1 = Y_power(1,i).power(:,Scales(j,1):Scales(j,2));
                if sum(temp1(1,:)~=0)==0
                    ScalePower(:,j) = 0;
                else
                    ScalePower(:,j) = sum(temp1,2)./sum(temp1(1,:)~=0);
                end
            end
            Y_power(1,i).power = ScalePower;
        end
        % exclude bad block?
        if BadBlockFlag == 1
            EventInfo = handles.cfg.EventInfo;        % event info
            if isempty(EventInfo)
                errordlg('No event info in EEG data,please UNCHECK ''Exclude Powers in Bad Block (label 9999)''!!!','BadBlock Error');
                set(hObject,'Enable', 'on','BackgroundColor', rawBackgroundColor);
                set(handles.pushbutton_cancel ,'Enable', 'on');
                return;
            end;
            try LogiVal = EventInfo.Eventtypes == 9999;
            catch, LogiVal = cellfun(@(x) isequal(x,'9999'), EventInfo.Eventtypes);
            end;
            IndexInd = EventInfo.TypeInd(1,LogiVal);
            if ~isempty(IndexInd)
                BadBlocks = EventInfo.events(IndexInd.index);
                IndBadBlock = zeros(1,timeLenth_1);
                for k1 = 1:length(BadBlocks)
                    IndBadBlock(BadBlocks(1,k1).latency:BadBlocks(1,k1).latency+BadBlocks(1,k1).duration)=1;
                end
                IndBadBlock = IndBadBlock(index2);
                for k2 = 1:size(Scales,1)
                    for i = 1:length(Y_power)
                        if sum(IndBadBlock(Scales(k2,1):Scales(k2,2)))~=0
                            Y_power(1,i).power(:,k2) = 0;
                        end
                    end
                end
            end
        end
        % mean power across channels?
        if MeanPowerFlag == 1
            for i = 1:length(Y_power)
                Y_power(1,i).power = mean(Y_power(1,i).power,1);
            end
        end
        % normalize?
        if NormalizeFlag == 1
            for i = 1:length(Y_power)
                for j = 1:size(Y_power(1,i).power,1)
                    temp2 = Y_power(1,i).power(j,:);
                    Y_power(1,i).power(j,:) = (temp2 - min(temp2))./ (max(temp2)-min(temp2));
                end
            end
        end
        % ---------------------
        % assign to workspace
        MeanPower = Y_power;
        Freq_str = get(handles.popupmenu_Freq,'string');
        freq_str_select = Freq_str(get(handles.popupmenu_Freq,'value'));
        label = [freq_str_select{1},':',num2str(Hz1),'-',num2str(Hz2),'Hz'];
        for i = 1:length(MeanPower)
            MeanPower(i).label = label;
            MeanPower(i).channs = SelectChanns.cellchannames;
            MeanPower(i).model = model;
            
            MeanPower(i).ParaSettings.srate = srate;
            MeanPower(i).ParaSettings.epoch = [];
            MeanPower(i).ParaSettings.WaveletCycles = WaveletCycles;
            MeanPower(i).ParaSettings.TaperingFunction = TaperingFunction;
            MeanPower(i).ParaSettings.WaveletMethod = WaveletMethod;
            MeanPower(i).ParaSettings.NormalizeFlag = NormalizeFlag;
            MeanPower(i).ParaSettings.DetrendFlag = DetrendFlag;
            MeanPower(i).ParaSettings.ExcludeBadBlockFlag = BadBlockFlag;
            MeanPower(i).ParaSettings.MeanPowerFlag = MeanPowerFlag;
            MeanPower(i).ParaSettings.fMRIOnset = fMRIOnset;
            MeanPower(i).ParaSettings.fMRIDur = fMRIDur;
            MeanPower(i).ParaSettings.MatchFlag = MatchFlag;
            if MatchFlag == 1
                MeanPower(i).ParaSettings.TR = TR;
            end
        end
        if evalin('base','exist(''MeanPower'')')==0 % MeanPower exist in the workspace?
           assignin('base','MeanPower',MeanPower);
        else
            assignin('base','MeanPower',[evalin('base','MeanPower'),MeanPower]);
        end
    case 3
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
        % --------------------------------------
        % display settings:
        disp('--------------------------');
        disp(['Model Select:',num2str(model),' -> Extract Power From Event Epoch']);
        disp('Select Channels: ');
        disp(SelectChanns.cellchannames);
        disp('Select Events:');
        disp(SelectEvent.celleventnames);
        disp(['Frequcey Band -> ',num2str(Hz1),'~',num2str(Hz2),' Hz']);
        disp(['Epoch Time Range -> ',num2str(EpochTimeRange(1)),'ms',' ~ ',num2str(EpochTimeRange(2)),'ms']);
        disp(['Sampling Rate -> ',num2str(srate),' Hz']);
        disp(['Wavelet Cycles -> ',num2str(WaveletCycles)]);
        disp(['FFT Tapering Funtion -> ',TaperingFunction]);
        disp(['Wavelet Method/Program -> ',WaveletMethod]);
        disp(['Normalize? -> ',num2str(NormalizeFlag)]);
        disp(['Detrend? -> ',num2str(DetrendFlag)]);
        disp(['Exclude Bad Block (label 9999)? -> ',num2str(BadBlockFlag)]);
        disp(['Mean Power Across Channels? -> ',num2str(MeanPowerFlag)]);
        disp(['Downsample to fMRI timepoints? -> ',num2str(MatchFlag)]);
        disp(['fMRI Onset (sec) -> ',num2str(fMRIOnset)]);
        disp(['fMRI Duration (sec) -> ', num2str(fMRIDur)]);
        try disp(['TR (sec) -> ',num2str(TR)]);catch;end;
        disp('--------------------------');
        % -------------------------------------
        % calculate power using time-frequency analysis
        temp_data1 = EEG.data(SelectChanns.chanlist,:); % selected data
        [Nchanns,timeLenth_1] = size(temp_data1); % number of selected channels
        t1 = round(fMRIOnset * srate);
        t2 = round((fMRIOnset+fMRIDur) * srate);
        index1 = 1:timeLenth_1;
        index2 = find(t1<index1 & index1<=t2);
        temp_data2 = temp_data1(:,index2);
        timeLenth_2 = size(temp_data2,2);
        % calculate power
        N_type = length(SelectEvent.celleventnames); % number of selected types
        Y_power = [];
        for i = 1:N_type
            TypeInd = EventInfo.TypeInd(SelectEvent.eventlist(i)).index;
            N_epoch = length(TypeInd);
            Y_power_1 = zeros(Nchanns,timeLenth_2);
            TypeEpochs = EventInfo.events(TypeInd);
            for k = 1:N_epoch
                temp1 = zeros(1,timeLenth_1);
                t3 = TypeEpochs(1,k).latency + round(EpochTimeRange(1)/1000*srate);
                t4 = TypeEpochs(1,k).latency + round(EpochTimeRange(2)/1000*srate);
                temp1(max(1,t3):min(t4,timeLenth_1)) = 1;
                temp2 = temp1(index2);
                if any(temp2)
                    for j = 1:Nchanns
                        temp_data3 = temp_data2(j,temp2==1);
                        [tf, freqs, ~] = timefreq(temp_data3,...
                            srate,'cycles',WaveletCycles,'wletmethod',WaveletMethod,...
                            'ffttaper',TaperingFunction,'detrend',DetrendStr);
                        temp_power1 = 2*abs(tf).^2/length(temp_data3); % power
                        temp_MeanPower = mean(temp_power1,2);
                        temp_power2 = mean(temp_MeanPower(freqs>Hz1 & freqs<Hz2,:));
                        Y_power_1(j,temp2==1) = temp_power2;
                    end
                end
            end
            Y_power(1,i).power = Y_power_1;
            Y_power(1,i).type = EventInfo.Eventtypes(SelectEvent.eventlist(i));
        end
        % match to TR/sec scale
        if MatchFlag == 1
            ScaleLenth = round(srate*TR);
        else
            ScaleLenth = round(srate);
        end
        temp3 = 1:ScaleLenth:timeLenth_2;
        temp4 = ScaleLenth:ScaleLenth:timeLenth_2;
        if length(temp3)==length(temp4)
            Scales = [temp3',temp4'];
        else
            Scales = [temp3',[temp4';timeLenth_2]];
        end
        for i = 1:N_type
            ScalePower = zeros(size(Y_power(1,i).power,1),size(Scales,1));
            for j = 1:size(Scales,1)
                temp1 = Y_power(1,i).power(:,Scales(j,1):Scales(j,2));
                if sum(temp1(1,:)~=0)==0
                    ScalePower(:,j) = 0;
                else
                    ScalePower(:,j) = sum(temp1,2)./sum(temp1(1,:)~=0);
                end
            end
            Y_power(1,i).power = ScalePower;
        end
        % exclude bad block?
        if BadBlockFlag == 1
            EventInfo = handles.cfg.EventInfo;        % event info
            if isempty(EventInfo)
                errordlg('No event info in EEG data,please UNCHECK ''Exclude Powers in Bad Block (label 9999)''!!!','BadBlock Error');
                set(hObject,'Enable', 'on','BackgroundColor', rawBackgroundColor);
                set(handles.pushbutton_cancel ,'Enable', 'on');
                return;
            end;
            try LogiVal = EventInfo.Eventtypes == 9999;
            catch, LogiVal = cellfun(@(x) isequal(x,'9999'), EventInfo.Eventtypes);
            end;
            IndexInd = EventInfo.TypeInd(1,LogiVal);
            if ~isempty(IndexInd)
                BadBlocks = EventInfo.events(IndexInd.index);
                IndBadBlock = zeros(1,timeLenth_1);
                for k1 = 1:length(BadBlocks)
                    IndBadBlock(BadBlocks(1,k1).latency:BadBlocks(1,k1).latency+BadBlocks(1,k1).duration)=1;
                end
                IndBadBlock = IndBadBlock(index2);
                for k2 = 1:size(Scales,1)
                    for i = 1:length(Y_power)
                        if sum(IndBadBlock(Scales(k2,1):Scales(k2,2)))~=0
                            Y_power(1,i).power(:,k2) = 0;
                        end
                    end
                end
            end
        end
        % mean power across channels?
        if MeanPowerFlag == 1
            for i = 1:length(Y_power)
                Y_power(1,i).power = mean(Y_power(1,i).power,1);
            end
        end
        % normalize?
        if NormalizeFlag == 1
            for i = 1:length(Y_power)
                for j = 1:size(Y_power(1,i).power,1)
                    temp2 = Y_power(1,i).power(j,:);
                    Y_power(1,i).power(j,:) = (temp2 - min(temp2))./ (max(temp2)-min(temp2));
                end
            end
        end
        % ---------------------
        % assign to workspace
        MeanPower = Y_power;
        Freq_str = get(handles.popupmenu_Freq,'string');
        freq_str_select = Freq_str(get(handles.popupmenu_Freq,'value'));
        label = [freq_str_select{1},':',num2str(Hz1),'-',num2str(Hz2),'Hz'];
        for i = 1:length(MeanPower)
            MeanPower(i).label = label;
            MeanPower(i).channs = SelectChanns.cellchannames;
            MeanPower(i).model = model;
            
            MeanPower(i).ParaSettings.srate = srate;
            MeanPower(i).ParaSettings.epoch = EpochTimeRange;
            MeanPower(i).ParaSettings.WaveletCycles = WaveletCycles;
            MeanPower(i).ParaSettings.TaperingFunction = TaperingFunction;
            MeanPower(i).ParaSettings.WaveletMethod = WaveletMethod;
            MeanPower(i).ParaSettings.NormalizeFlag = NormalizeFlag;
            MeanPower(i).ParaSettings.DetrendFlag = DetrendFlag;
            MeanPower(i).ParaSettings.ExcludeBadBlockFlag = BadBlockFlag;
            MeanPower(i).ParaSettings.MeanPowerFlag = MeanPowerFlag;
            MeanPower(i).ParaSettings.fMRIOnset = fMRIOnset;
            MeanPower(i).ParaSettings.fMRIDur = fMRIDur;
            MeanPower(i).ParaSettings.MatchFlag = MatchFlag;
            if MatchFlag == 1
                MeanPower(i).ParaSettings.TR = TR;
            end
        end
        if evalin('base','exist(''MeanPower'')')==0 % MeanPower exist in the workspace?
           assignin('base','MeanPower',MeanPower);
        else
            assignin('base','MeanPower',[evalin('base','MeanPower'),MeanPower]);
        end
end
set(hObject,'Enable', 'on','BackgroundColor', rawBackgroundColor);
set(handles.pushbutton_cancel ,'Enable', 'on');



% --- Executes when selected object is changed in uipanel_ModelSelect.
function uipanel_ModelSelect_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_ModelSelect 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
TagName = get(hObject,'Tag');
switch TagName
    case 'radiobutton_FlagContinuData'
        handles.cfg.ModelSelectFlag = 1;
        set(handles.edit_EpochTimeRange,'string','None','Enable','off');
        set(handles.pushbutton_SelectEvent,'Enable','off');
    case 'radiobutton_FlagDischargeEpoch'
        handles.cfg.ModelSelectFlag = 2;
        set(handles.edit_EpochTimeRange,'string','None','Enable','off');
        set(handles.pushbutton_SelectEvent,'Enable','on');
    case 'radiobutton_FlagEventEpoch'
        handles.cfg.ModelSelectFlag = 3;
        handles.cfg.EpochTimeRange = [];
        set(handles.edit_EpochTimeRange,'string',[],'Enable','on');
        set(handles.pushbutton_SelectEvent,'Enable','on');
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in listbox_SelectedEvents.
function listbox_SelectedEvents_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_SelectedEvents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_SelectedEvents contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_SelectedEvents


% --- Executes during object creation, after setting all properties.
function listbox_SelectedEvents_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_SelectedEvents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_SelectEvent.
function pushbutton_SelectEvent_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_SelectEvent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.cfg.EventInfo)
    EventTypes = handles.cfg.EventInfo.Eventtypes;
    if iscell(EventTypes)
        [eventlist,~,celleventnames] = pop_chansel(EventTypes,'withindex','off');
    else
        [eventlist,~,celleventnames] = pop_chansel(cellstr(num2str(EventTypes')),'withindex','off');
    end
    handles.cfg.SelectEvent.eventlist = eventlist;
    handles.cfg.SelectEvent.celleventnames = celleventnames;
    set(handles.listbox_SelectedEvents,'string',celleventnames);
else
    msgbox({'No events/types in the EEG data'},'Note');
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
evalin('base','clear ''MeanPower''');
close(nit_ExtractPower);

% --- Executes on button press in pushbutton_HelpfMRI.
function pushbutton_HelpfMRI_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_HelpfMRI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox({'fMRI settings: ';...
        '   fMRI Onset: Set the fMRI onset (sec). It should be >=0.';...
        '   fMRI Duration: Set the fMRI duration (sec). If = empty/negative/0, default is Inf.';...
        '   Match to fMRI timepoints?:If check, match to fMRI time scale.';...
        '   TR: Reapting time (sec) of fMRI.';...
        },'Help');


% --- Executes on button press in checkbox_DetrendFlag.
function checkbox_DetrendFlag_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_DetrendFlag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_DetrendFlag
handles.cfg.DetrendFlag = get(hObject,'Value');
% Update handles structure
guidata(hObject, handles);
