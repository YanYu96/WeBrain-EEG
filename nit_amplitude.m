function varargout = nit_amplitude(varargin)
% NIT_AMPLITUDE MATLAB code for nit_amplitude.fig
%      NIT_AMPLITUDE, by itself, creates a new NIT_AMPLITUDE or raises the existing
%      singleton*.
%
%      H = NIT_AMPLITUDE returns the handle to a new NIT_AMPLITUDE or the handle to
%      the existing singleton*.
%
%      NIT_AMPLITUDE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NIT_AMPLITUDE.M with the given input arguments.
%
%      NIT_AMPLITUDE('Property','Value',...) creates a new NIT_AMPLITUDE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nit_amplitude_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nit_amplitude_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help nit_amplitude

% Last Modified by GUIDE v2.5 06-Oct-2015 16:05:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nit_amplitude_OpeningFcn, ...
                   'gui_OutputFcn',  @nit_amplitude_OutputFcn, ...
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


% --- Executes just before nit_amplitude is made visible.
function nit_amplitude_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nit_amplitude (see VARARGIN)

% Choose default command line output for nit_amplitude
handles.output = hObject;

handles.cfg.method = 1;            % method
handles.cfg.SelectedEvent = [];    % selected Type/Event
handles.cfg.SelectedICs = [];      % selected ICs
handles.cfg.srate = [];            % EEG sampling rate
handles.cfg.BaselineFlag = 1;      % baseline correction?
handles.cfg.NormalizeFlag = 1;     % Normalize?
handles.cfg.fMRIOnset = 0;         % fMRI onset (sec);
handles.cfg.fMRIDur = Inf;         % fMRI duration.
handles.cfg.MatchFlag = 0;       % match to fMRI timepoints?
handles.cfg.TR = 2;                % TR
try EEG = evalin('base','EEG');
    if ~isempty(EEG)
        try EEG.srate
            if ~isempty(EEG.srate)
                handles.cfg.srate = EEG.srate;
                set(handles.edit_srate,'string',num2str(EEG.srate));
            end
        catch
        end;
    else
        warndlg('EEG is empty!!!!','Data Error');
    end
catch, warndlg('Failed to find EEG data!!!','Data Error');
end;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nit_amplitude wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = nit_amplitude_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_Run.
function pushbutton_Run_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rawBackgroundColor = get(hObject ,'BackgroundColor');
set(hObject ,'Enable', 'off','BackgroundColor', 'red');
set(handles.pushbutton_Cancel ,'Enable', 'off');
set(handles.pushbutton_Save ,'Enable', 'off');
drawnow;

try ICAresults = evalin('base','ICAresults');
    if isempty(ICAresults)
        errordlg('ICAresults is empty, please run ICA first or load the ICA results!!!!','Data Error');
        set(hObject ,'Enable', 'on','BackgroundColor', rawBackgroundColor);
        set(handles.pushbutton_Cancel ,'Enable', 'on');
        set(handles.pushbutton_Save ,'Enable', 'on');
        return;
    end
catch
    errordlg('ICAresults is NULL, please run ICA first or load the ICA results!!!!','Data Error');
    set(hObject ,'Enable', 'on','BackgroundColor', rawBackgroundColor);
    set(handles.pushbutton_Cancel ,'Enable', 'on');
    set(handles.pushbutton_Save ,'Enable', 'on');
    return;
end

SelectEvent = handles.cfg.SelectedEvent;    % Selected Events.
if isempty(SelectEvent)
    errordlg('Please select a type/event!!!','Parameter Error');
    set(hObject ,'Enable', 'on','BackgroundColor', rawBackgroundColor);
    set(handles.pushbutton_Cancel ,'Enable', 'on');
    set(handles.pushbutton_Save ,'Enable', 'on');
    return;
else
    if isempty(SelectEvent.eventlist)
        errordlg('Please select a type/event!!!','Parameter Error');
        set(hObject ,'Enable', 'on','BackgroundColor', rawBackgroundColor);
        set(handles.pushbutton_Cancel ,'Enable', 'on');
        set(handles.pushbutton_Save ,'Enable', 'on');
        return;
    end
end;

SelectICs = handles.cfg.SelectedICs;    % Selected Events.
if isempty(SelectICs)
    errordlg('Please select ICs!!!','Parameter Error');
    set(hObject ,'Enable', 'on','BackgroundColor', rawBackgroundColor);
    set(handles.pushbutton_Cancel ,'Enable', 'on');
    set(handles.pushbutton_Save ,'Enable', 'on');
    return;
else
    if isempty(SelectICs.ICslist)
        errordlg('Please select ICs!!!','Parameter Error');
        set(hObject ,'Enable', 'on','BackgroundColor', rawBackgroundColor);
        set(handles.pushbutton_Cancel ,'Enable', 'on');
        set(handles.pushbutton_Save ,'Enable', 'on');
        return;
    end
end;

method = handles.cfg.method;
srate = handles.cfg.srate;            % sampling rate.
if isempty(srate)
    errordlg('Sampling rate must be > 0!!!','Parameter Error');
    set(hObject ,'Enable', 'on','BackgroundColor', rawBackgroundColor);
    set(handles.pushbutton_Cancel ,'Enable', 'on');
    set(handles.pushbutton_Save ,'Enable', 'on');
    return;
end;
BaselineFlag = handles.cfg.BaselineFlag;     % baseline correction?
NormalizeFlag = handles.cfg.NormalizeFlag;   % Normalize?
MatchFlag = handles.cfg.MatchFlag;      % Match to fMRI timepoints?
if MatchFlag == 1
    TR = handles.cfg.TR;  % TR (sec).
    if any(~isfinite(TR)) || any(TR <= 0) || length(TR)>1
        errordlg('TR must be a real positive scalar!!!','Parameter Error');
        set(hObject ,'Enable', 'on','BackgroundColor', rawBackgroundColor);
        set(handles.pushbutton_Cancel ,'Enable', 'on');
        set(handles.pushbutton_Save ,'Enable', 'on');
        return;
    end;
    fMRIOnset = handles.cfg.fMRIOnset;           % fMRI Onset(sec).
    if isempty(fMRIOnset) || fMRIOnset<0 || length(fMRIOnset)>1 || ~isreal(fMRIOnset)
        errordlg('fMRI onset must be 0 or a real positive scalar!!!','Parameter Error');
        set(hObject ,'Enable', 'on','BackgroundColor', rawBackgroundColor);
        set(handles.pushbutton_Cancel ,'Enable', 'on');
        set(handles.pushbutton_Save ,'Enable', 'on');
        return;
    end;
    
    fMRIDur = handles.cfg.fMRIDur; % fMRI Duration (sec).
    if isempty(fMRIDur) || fMRIDur < 0 || length(fMRIDur)>1 || ~isreal(fMRIDur) || fMRIDur/TR ~= fix(fMRIDur/TR)
        errordlg('fMRI Duration must be a real positive scalar which is divisible by TR!!!','Parameter Error');
        set(hObject ,'Enable', 'on','BackgroundColor', rawBackgroundColor);
        set(handles.pushbutton_Cancel ,'Enable', 'on');
        set(handles.pushbutton_Save ,'Enable', 'on');
        return;
    end;
    
    try  ICAresults.results(SelectEvent.eventlist(1)).latencies;
    catch
        errordlg('No latencies in ICAreuslts, please DO NOT check the match checkbox!!!','Parameter Error');
        set(hObject ,'Enable', 'on','BackgroundColor', rawBackgroundColor);
        set(handles.pushbutton_Cancel ,'Enable', 'on');
        set(handles.pushbutton_Save ,'Enable', 'on');
        return;
    end
end
Methodstr= {'Maximal Absolute Value','Maximal Value','Absolute Maximal Value (signed)'};
% display settings:
disp('--------------------------');
disp('Select Types:');
disp(SelectEvent.celleventnames);
disp('Select ICs:');
disp(SelectICs.cellICsnames);
disp(['Method:',num2str(method),'->',Methodstr{method}]);
disp(['Sampling Rate -> ',num2str(srate),' Hz']);
try disp(['Epoch Time Range (msec) -> ',num2str(ICAresults.Settings.epoch)]);catch;end;
disp(['Baseline correction? -> ',num2str(BaselineFlag)]);
disp(['Normalize? -> ',num2str(NormalizeFlag)]);
disp(['Match to fMRI timepoints? -> ',num2str(MatchFlag)]);
if MatchFlag == 1
    disp(['fMRI Onset (sec) -> ',num2str(fMRIOnset)]);
    disp(['fMRI Duration (sec) -> ', num2str(fMRIDur)]);
    disp(['TR (sec) -> ',num2str(TR)]);
end
disp('--------------------------');
% calculate the amplitude
ICAresults_1 = ICAresults.results(SelectEvent.eventlist(1)); % ICA results of selected event.
N_trials = ICAresults_1.trials;              % number of trials
N_SelectICs = length(SelectICs.ICslist);     % number of selected ICs
ampli_matrix1 = zeros(N_trials,N_SelectICs);  % amplitude matrix (trials X ICs)
try epoch = ICAresults.Settings.epoch; 
catch
    epoch = 0;
end;
t0 = round(abs(epoch(1))/1000*srate);
for i = 1:N_SelectICs
    timecourse1 = ICAresults_1.IC_timecourses(SelectICs.ICslist(i),:);
    M1 = (reshape(timecourse1,length(timecourse1)/N_trials,N_trials))';
    for j = 1:N_trials
        temp1 = M1(j,:);
        if BaselineFlag == 1 && t0 ~=0 
            temp1 = temp1 - mean(temp1(1:t0));
        end
        temp2 = temp1(1+t0:end);
        switch method
            case 1 % maxiaml absolute value
                ampli_matrix1(j,i)  = max(abs(temp2));
            case 2 % absolute maximal value (signed)
                index1 = find(abs(temp2) == max(abs(temp2)));
                ampli_matrix1(j,i)  = temp2(index1(1));
            case 3 % maximal
                ampli_matrix1(j,i)  = max(temp2);
        end
    end
end

% normalize?
if NormalizeFlag == 1
    for k = 1:size(ampli_matrix1,2)
        ampli_matrix1(:,k) = (ampli_matrix1(:,k)-min(ampli_matrix1(:,k)))./(max(ampli_matrix1(:,k))-min(ampli_matrix1(:,k)));
    end
end

% match to fMRI timepoints?
if MatchFlag == 1
    latencies_ori = ICAresults.results(SelectEvent.eventlist(1)).latencies;
    % reject the trials out of fMRI scanning
    latencies_new = latencies_ori;
    t1 = round(fMRIOnset * srate);
    t2 = round((fMRIOnset+fMRIDur) * srate);
    Nf = round(fMRIDur/TR); % length of fMRI serises
    ampli_matrix2 = zeros(Nf,size(ampli_matrix1,2));
    for j = 1:N_trials
        if latencies_ori(j)>t1 && latencies_ori(j)<t2
            index2 = max(round((latencies_ori(j)./srate-fMRIOnset)./TR),1);
            ampli_matrix2(index2,:)=ampli_matrix1(j,:);
        else
            latencies_new(j) = 0;
        end
    end
    latencies_new(latencies_new==0)= [];
    if length(latencies_ori)~=length(latencies_new)
        disp(['Delete ',num2str(length(latencies_ori)-length(latencies_new)),' trials which are out of fMRI scanning']);
    end
end
% ---------------------
% assign to workspace
ampli_results.type = SelectEvent.celleventnames;
ampli_results.ICs = SelectICs.cellICsnames;
ampli_results.method = Methodstr{method};
ampli_results.srate = srate;
ampli_results.BaselineFlag = BaselineFlag;
ampli_results.NormalizeFlag = NormalizeFlag;
ampli_results.MatchFlag = MatchFlag;
if MatchFlag == 1
    ampli_results.ampli = ampli_matrix2;
    ampli_results.latencies = latencies_new;
    ampli_results.fMRIOnset = fMRIOnset;
    ampli_results.fMRIDur = fMRIDur;
    ampli_results.TR = TR;
else
    ampli_results.ampli = ampli_matrix1;
    try ampli_results.latencies = latencies_ori;
    catch
    end;
end
assignin('base','ampli_results',ampli_results);
set(hObject ,'Enable', 'on','BackgroundColor', rawBackgroundColor);
set(handles.pushbutton_Cancel ,'Enable', 'on');
set(handles.pushbutton_Save ,'Enable', 'on');

% --- Executes on button press in pushbutton_Cancel.
function pushbutton_Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
evalin('base','clear ''ampli_results''');
close(nit_amplitude);

% --- Executes on button press in pushbutton_Save.
function pushbutton_Save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if evalin('base','exist(''ampli_results'')')==1 % ampli_results exist in the workspace?
    ampli_results = evalin('base','ampli_results');
    if ~isempty(ampli_results)
        % generate cell array for saving
        ampliMatrix = [];
        [Np, Nc] = size(ampli_results.ampli);
        for i = 1:Nc
            % first row is label info
            ampliMatrix{1,i} = ['Type-',ampli_results.type{1},'-',ampli_results.ICs{i}];
            for j = 1:Np
                % data
                ampliMatrix{j+1,i} = ampli_results.ampli(j,i);
            end
        end
        % ---------------------
        % save
        [filename,pathname] = uiputfile({'*.xlsx','Excel';'*.xls','Excel 2003';'*.txt','Text';'*.mat','Matlab'},'Save Onsets');
        if ~isequal(filename,0) && ~isequal(pathname,0)
            fpath = fullfile(pathname,filename);
            [~, ~, ext] = fileparts(fpath);
            switch ext
                case '.xlsx'
                    xlswrite(fpath,{[]},'A1:DZ10000');
                    xlswrite(fpath,ampliMatrix);
                case '.xls'
                    xlswrite(fpath,{[]},'A1:DZ10000');
                    xlswrite(fpath,ampliMatrix);
                case '.txt'
                    fid = fopen(fpath,'w');
                    for i = 1:size(ampliMatrix,1)
                        for j = 1:size(ampliMatrix,2)
                            if i == 1
                                fprintf(fid,'%s',ampliMatrix{i,j});
                                fprintf(fid,' ');
                            else
                                fprintf(fid,'%e',ampliMatrix{i,j});
                                fprintf(fid,' ');
                            end
                        end
                        fprintf(fid,'\r\n');
                    end
                    fclose(fid);
                case '.mat'
                    save(fpath,'ampli_results');
            end
            msgbox('Amplitudes has saved!','Success','help');
        end
    else
        errordlg('ampli_results is empty!!!!','Data Error');
        return;
    end
else
    errordlg('ampli_results is NULL!!!!','Data Error');
    return;
end

% --- Executes on selection change in listbox_SelectICs.
function listbox_SelectICs_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_SelectICs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_SelectICs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_SelectICs


% --- Executes during object creation, after setting all properties.
function listbox_SelectICs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_SelectICs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_selectEvent.
function pushbutton_selectEvent_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_selectEvent (see GCBO)
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
N_type = length(ICAresults.results);
N_trials = zeros(N_type,1); % No. of trials of each event.
EventTypes = [];
for i = 1:N_type
    EventTypes{i} = ICAresults.results(i).type;
    N_trials(i) = ICAresults.results(i).trials;
end
[eventlist,~,celleventnames] = pop_chansel(EventTypes,'withindex','off','selectionmode','single'); % select types
handles.cfg.SelectedEvent.eventlist = eventlist;
handles.cfg.SelectedEvent.celleventnames = celleventnames;
strShow = [celleventnames,['No. of trials ->',num2str(N_trials(eventlist(1)))]];
set(handles.listbox_SelectedEvent,'string',strShow);

% Update handles structure
guidata(hObject, handles);

% --- Executes on selection change in listbox_SelectedEvent.
function listbox_SelectedEvent_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_SelectedEvent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_SelectedEvent contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_SelectedEvent


% --- Executes during object creation, after setting all properties.
function listbox_SelectedEvent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_SelectedEvent (see GCBO)
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


% --- Executes on button press in pushbutton_Help.
function pushbutton_Help_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox({'Settings: ';...
        '   Select a Event/Type: Select a Event/Type you interested.';...
        '   Select ICs: Select ICs you want to calculate.';...
        '   Method: ';...
        '        Maximal Absolute Value: In each trial, maximal absolute value after stimulus is extracted.';...
        '        Absolute Maximal Value (signed): In each trial, the vaule, which is absolutely maximal after stimulus, is extracted.;';...
        '        Maximal Value: In each trial, maximal value after stimulus is extracted.';...
        '   EEG Sampling Rate: It can be automatically filled. If failed, please fill it by hand.';...
        '   Baseline Correction: For each trial, it can be corrected by subtracting the mean value of pre-stimulation period';...
        '   Normalize?: Amplitude vectors are normalized by subtracting the minimum value and dividing by the difference of maximum and minimum values';...
        '   Match to fMRI timepoints?:If check, match to fMRI time scale.';...
        '   fMRI Onset (sec): Set the fMRI onset (sec). It should be >=0.';...
        '   fMRI Duration (sec): Set the fMRI duration (sec). It should be >0 and divided by TR with no remainder.';...
        '   TR (sec): Reapting time (sec) of fMRI.';...
        },'Help');

% --- Executes on button press in checkbox_MatchFlag.
function checkbox_MatchFlag_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_MatchFlag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_MatchFlag
value = get(hObject,'Value');
handles.cfg.MatchFlag = value;
if value == 1
    set(handles.edit_TR,'Enable','on');
    set(handles.edit_fMRIOnset,'Enable','on');
    set(handles.edit_fMRIDur,'Enable','on');
else
    set(handles.edit_TR,'Enable','off');
    set(handles.edit_fMRIOnset,'Enable','off');
    set(handles.edit_fMRIDur,'Enable','off');
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



function edit_fMRIDur_Callback(hObject, eventdata, handles)
% hObject    handle to edit_fMRIDur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_fMRIDur as text
%        str2double(get(hObject,'String')) returns contents of edit_fMRIDur as a double
handles.cfg.fMRIDur = str2double(get(hObject,'String'));
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


% --- Executes on button press in checkbox_BaseCorrect.
function checkbox_BaseCorrect_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_BaseCorrect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_BaseCorrect
value = get(hObject,'Value');
handles.cfg.BaselineFlag = value;
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function uipanel_method_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when selected object is changed in uipanel_method.
function uipanel_method_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_method 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
TagName = get(hObject,'Tag');
switch TagName
    case 'radiobutton_MaxAbs'
        handles.cfg.method = 1;
    case 'radiobutton_Max'
        handles.cfg.method = 2;
    case 'radiobutton_AbsMax'
        handles.cfg.method = 3;
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton_SelectICs.
function pushbutton_SelectICs_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_SelectICs (see GCBO)
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
N_ICs = size(ICAresults.results(1).IC_timecourses,1);
strICs = [];
for i = 1:N_ICs
    strICs{i} = ['IC-',num2str(i)];
end
[ICslist,~,cellICsnames] = pop_chansel(strICs,'withindex','off'); % select types
handles.cfg.SelectedICs.ICslist = ICslist;
handles.cfg.SelectedICs.cellICsnames = cellICsnames;
set(handles.listbox_SelectICs,'string',cellICsnames);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in checkbox_NormalizeFlag.
function checkbox_NormalizeFlag_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_NormalizeFlag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_NormalizeFlag
handles.cfg.NormalizeFlag = get(hObject,'Value');
% Update handles structure
guidata(hObject, handles);
