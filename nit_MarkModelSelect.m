function varargout = nit_MarkModelSelect(varargin)
% NIT_MARKMODELSELECT MATLAB code for nit_MarkModelSelect.fig
%      NIT_MARKMODELSELECT, by itself, creates a new NIT_MARKMODELSELECT or raises the existing
%      singleton*.
%
%      H = NIT_MARKMODELSELECT returns the handle to a new NIT_MARKMODELSELECT or the handle to
%      the existing singleton*.
%
%      NIT_MARKMODELSELECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NIT_MARKMODELSELECT.M with the given input arguments.
%
%      NIT_MARKMODELSELECT('Property','Value',...) creates a new NIT_MARKMODELSELECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nit_MarkModelSelect_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nit_MarkModelSelect_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help nit_MarkModelSelect

% Last Modified by GUIDE v2.5 07-Aug-2015 14:53:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nit_MarkModelSelect_OpeningFcn, ...
                   'gui_OutputFcn',  @nit_MarkModelSelect_OutputFcn, ...
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


% --- Executes just before nit_MarkModelSelect is made visible.
function nit_MarkModelSelect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nit_MarkModelSelect (see VARARGIN)

% Choose default command line output for nit_MarkModelSelect
handles.output = hObject;
try EEG = evalin('base','EEG'); % get EEG from workspace
    if ~isempty(EEG)
        handles.cfg.EEG = EEG;
        try ChannsLabels = {EEG.chanlocs.labels}';
        catch
            ChannsLabels = cellstr(num2str((1:size(EEG.data,1))')); % using numbera as label
        end
        set(handles.listbox_Channs,'string',ChannsLabels);
        handles.cfg.ChannsList = ChannsLabels;
    else
        errordlg('EEG is NULL!!!','Data Error');
        return;
    end
catch
    errordlg('Failed to find EEG data!!!','Data Error');
    return;
end
handles.cfg.MarkModel = 0;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nit_MarkModelSelect wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = nit_MarkModelSelect_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox_Channs.
function listbox_Channs_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_Channs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_Channs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_Channs


% --- Executes during object creation, after setting all properties.
function listbox_Channs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_Channs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_UserDefinChanns_Callback(hObject, eventdata, handles)
% hObject    handle to edit_UserDefinChanns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_UserDefinChanns as text
%        str2double(get(hObject,'String')) returns contents of edit_UserDefinChanns as a double


% --- Executes during object creation, after setting all properties.
function edit_UserDefinChanns_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_UserDefinChanns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_UserDefinChanns.
function pushbutton_UserDefinChanns_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_UserDefinChanns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.xls;*.xlsx;*.txt','Channel List (*.xls;*.xlsx;*.txt)';'*.*', 'All Files (*.*)';}, ...
    'Pick a file of channel list');
if ~(filename==0)
    ChannsListFile = fullfile(pathname,filename);
    [~,~,extension]= fileparts(ChannsListFile);
    switch extension
        case '.xls'
            [ChannsNum,ChannsLabels,~] = xlsread(ChannsListFile);
        case '.xlsx'
            [ChannsNum,ChannsLabels,~] = xlsread(ChannsListFile);
        case '.txt'
            ChannsLabels = importdata(ChannsListFile);
        otherwise
            errordlg('Please select .xls/.xlsx/.txt file!','File Error');
            return
    end
    if isempty(ChannsLabels)
        if size(ChannsNum,2) == 1
            ChannsLabels = cellstr(num2str(ChannsNum));
            handles.cfg.ChannsList = ChannsNum;
        elseif size(ChannsNum,2) == 2
            ChannsLabels = [cellstr(num2str(ChannsNum(:,1))),cellstr(num2str(ChannsNum(:,2)))];
            handles.cfg.ChannsList = ChannsNum;
        else
            errordlg('Channel number is not correct!','Channel List Error');
            return
        end
    else
        handles.cfg.ChannsList = ChannsLabels;
    end
    if size(ChannsLabels,2) == 1
        set(handles.listbox_Channs,'string',ChannsLabels);
    elseif size(ChannsLabels,2) == 2
        temp_ChannsLabels = [];
        if isnumeric(ChannsLabels)
            for j = 1:size(ChannsLabels,1)
                temp_ChannsLabels{j,1} = [num2str(ChannsLabels(j,1)),'-',num2str(ChannsLabels(j,2))];
            end
        else
            for j = 1:size(ChannsLabels,1)
                temp_ChannsLabels{j,1} = [ChannsLabels{j,1},'-',ChannsLabels{j,2}];
            end
        end
        set(handles.listbox_Channs,'string',temp_ChannsLabels);
    elseif size(ChannsLabels,2) > 2
        errordlg('The No. of columns in channel list file must be <= 2!','Channel List Error');
        return
    else
        errordlg('Channel labels are NULL!','Channel List Error');
        return
    end
    set(handles.edit_UserDefinChanns,'string',ChannsListFile);
    guidata(hObject, handles);
else
    errordlg('Select File is falied !','File Error');
    return
end


% --- Executes on button press in pushbutton_OK.
function pushbutton_OK_Callback(hObject, eventdata, handles)
 % hObject    handle to pushbutton_OK (see GCBO)
 % eventdata  reserved - to be defined in a future version of MATLAB
 % handles    structure with handles and user data (see GUIDATA)
 if ~isempty(handles.cfg.EEG)
     if isempty(handles.cfg.EEG.event)
         handles.cfg.EEG.event.type = '0000';
         handles.cfg.EEG.event.latency = 1;
         handles.cfg.EEG.event.urevent = 1;
     end
     tempData = [];
     tempChanlocs = [];
     SelectChannsLabels = handles.cfg.ChannsList;
     dim1 = size(SelectChannsLabels,2);
     try OriginChannsLabels = {handles.cfg.EEG.chanlocs.labels}';
     catch
         OriginChannsLabels = cellstr(num2str((1:size(handles.cfg.EEG.data,1))')); % using numbera as label
     end
     switch dim1
         case 1 % a column in the list of channel labels
             if isnumeric(SelectChannsLabels) % if input is number,original labels is set as numbers.
                 OriginChannsLabels = cellstr(num2str((1:size(handles.cfg.EEG.data,1))'));
                 SelectChannsLabels = cellstr(num2str(SelectChannsLabels));
             end
             for i = 1:length(SelectChannsLabels)
                 str1 = SelectChannsLabels(i);
                 str1= strtrim(str1); % remove leading and trailing space
                 temp_str = [];
                 for j = 1:length(OriginChannsLabels);
                     str2 = OriginChannsLabels(j);
                     str2 = strtrim(str2); % remove leading and trailing space
                     if  strcmp(str1,str2)
                         tempData(i,:) = handles.cfg.EEG.data(j,:);
                         temp_str = str2;
                         try tempChanlocs.chanlocs(1,i) = handles.cfg.EEG.chanlocs(1,j);
                         catch, tempChanlocs.chanlocs(1,i).labels = str2;
                         end
                     end
                 end
             end
             try
                 for i = 1:length(tempChanlocs.chanlocs)
                     if isempty(tempChanlocs.chanlocs(i).labels)
                         tempChanlocs.chanlocs(i).labels = 'NULL';
                     end
                 end
             catch
             end
             
             assignin('base','tempChanlocs',tempChanlocs); % assign data to workspace
             if isempty(tempData)
                 errordlg('All displayed channels defined in channel list file are not included in the EEG data!!!!','Data Error');
                 return
             elseif size(tempData,1) < length(SelectChannsLabels)
                 warndlg('Displayed channels are less than selected !!!!','Warning');
                 nit_eegplot(tempData,...
                     'srate',handles.cfg.EEG.srate,...
                     'events',handles.cfg.EEG.event,...
                     'ploteventdur','on'); % command example -> 'command','fprintf(''REJECT\n'')'
             elseif size(tempData,1) == length(SelectChannsLabels)
                 nit_eegplot(tempData,...
                     'srate',handles.cfg.EEG.srate,...
                     'events',handles.cfg.EEG.event,...
                     'ploteventdur','on'); % command example -> 'command','fprintf(''REJECT\n'')'
             end
             close(nit_MarkModelSelect);
         case 2 % two columns in the list of channel labels (Bipolar: first column - second column)
             if isnumeric(SelectChannsLabels) % if input is number,original labels is set as numbers.
                 OriginChannsLabels = cellstr(num2str((1:size(handles.cfg.EEG.data,1))'));
                 SelectChannsLabels = [cellstr(num2str(SelectChannsLabels(:,1))),cellstr(num2str(SelectChannsLabels(:,2)))];
             end
             for i = 1:size(SelectChannsLabels,1)
                 str1a = SelectChannsLabels(i,1);
                 str1a = strtrim(str1a); % remove leading and trailing space
                 str1b = SelectChannsLabels(i,2);
                 str1b = strtrim(str1b); % remove leading and trailing space
                 tempData1 = [];
                 tempData2 = [];
                 tempLabela = [];
                 tempLabelb = [];
                 if ~isempty(str1a{1}) && ~isempty(str1b{1})
                     for j = 1:length(OriginChannsLabels);
                         str2 = OriginChannsLabels(j);
                         str2 = strtrim(str2); % remove leading and trailing space
                         if  strcmp(str1a,str2)
                             tempData1 = handles.cfg.EEG.data(j,:);
                             tempLabela = str1a;
                         end
                         if  strcmp(str1b,str2)
                             tempData2 = handles.cfg.EEG.data(j,:);
                             tempLabelb = str1b;
                         end
                     end
                     if ~isempty(tempLabela) && ~isempty(tempLabelb)
                         tempChanlocs.chanlocs(1,i).labels = [tempLabela{1},'-',tempLabelb{1}];
                         tempData(i,:) = tempData1 - tempData2;
                     else
                         tempChanlocs.chanlocs(1,i).labels = 'NULL';
                     end
                 else
                     tempChanlocs.chanlocs(1,i).labels = 'NULL';
                 end
             end
             assignin('base','tempChanlocs',tempChanlocs); % assign data to workspace
             if isempty(tempData)
                 errordlg('Displayed channels are not included in the EEG data!!!!','Data Error');
                 return
             elseif size(tempData,1) < size(SelectChannsLabels,1)
                 warndlg('Displayed channels are less than selected !!!!','Warning');
                 nit_eegplot(tempData,...
                     'srate',handles.cfg.EEG.srate,...
                     'events',handles.cfg.EEG.event,...
                     'ploteventdur','on'); % command example -> 'command','fprintf(''REJECT\n'')'
             elseif size(tempData,1) == size(SelectChannsLabels,1)
                 nit_eegplot(tempData,...
                     'srate',handles.cfg.EEG.srate,...
                     'events',handles.cfg.EEG.event,...
                     'ploteventdur','on'); % command example -> 'command','fprintf(''REJECT\n'')'
             end
             close(nit_MarkModelSelect);
     end
 else
     errordlg('handles.cfg.EEG is NULL!!!!','Data Error');
     return;
 end

% --- Executes during object creation, after setting all properties.
function uipanel_MarkModel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel_MarkModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when selected object is changed in uipanel_MarkModel.
function uipanel_MarkModel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_MarkModel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
TagName = get(hObject,'Tag');
[ProgramPath, ~, ~] = fileparts(which('nit_EEG.m'));
switch TagName
    case 'radiobutton_OriginChanns'
       handles.cfg.MarkModel = 0;  % Using original channels
       set(handles.edit_UserDefinChanns,'enable','off');
       set(handles.pushbutton_UserDefinChanns,'enable','off');
       try ChannsLabels = {handles.cfg.EEG.chanlocs.labels}';
           set(handles.listbox_Channs,'string',ChannsLabels);
           handles.cfg.ChannsList = ChannsLabels;
       catch, ChannsLabels = num2str((1:size(handles.cfg.EEG.data,1))');
           for j = 1: size(ChannsLabels,1)
               handles.cfg.EEG.chanlocs(1,j).labels = strtrim(ChannsLabels(j,:));% remove leading and trailing space
           end
           set(handles.listbox_Channs,'string',cellstr(ChannsLabels));
           handles.cfg.ChannsList = cellstr(ChannsLabels);
       end
       guidata(hObject, handles);
    case 'radiobutton_16ChansCurry'
       handles.cfg.MarkModel = 1;  % Using 16 channels (NeuroScan Curry7)
       set(handles.edit_UserDefinChanns,'enable','off');
       set(handles.pushbutton_UserDefinChanns,'enable','off');
       
       [~,ChannsLabels,~] = xlsread(fullfile(ProgramPath,'NeuroScanCurry7_16Channels.xlsx'));
       handles.cfg.ChannsList = ChannsLabels;
       set(handles.listbox_Channs,'string',ChannsLabels);
       guidata(hObject, handles);
    case 'radiobutton_32ChannsCurry'
        handles.cfg.MarkModel = 2; % Using 32 channels (NeuroScan Curry7)
        set(handles.edit_UserDefinChanns,'enable','off');
        set(handles.pushbutton_UserDefinChanns,'enable','off');
        
        [~,ChannsLabels,~] = xlsread(fullfile(ProgramPath,'NeuroScanCurry7_32Channels.xlsx'));
        handles.cfg.ChannsList = ChannsLabels;
        set(handles.listbox_Channs,'string',ChannsLabels);
        guidata(hObject, handles);
    case 'radiobutton_16BiploarChannsCurry'
        handles.cfg.MarkModel = 3; % Using 16 bipolar channels (NeuroScan Curry7)
        set(handles.edit_UserDefinChanns,'enable','off');
        set(handles.pushbutton_UserDefinChanns,'enable','off');
        
        [~,ChannsLabels,~] = xlsread(fullfile(ProgramPath,'NeuroScanCurry7_16BipolarChannels.xlsx'));
        handles.cfg.ChannsList = ChannsLabels;
        temp_ChannsLabels = [];
        for j = 1:size(ChannsLabels,1)
            temp_ChannsLabels{j,1} = [ChannsLabels{j,1},'-',ChannsLabels{j,2}];
        end
        set(handles.listbox_Channs,'string',temp_ChannsLabels);
        guidata(hObject, handles);
    case 'radiobutton_UserDefChanns'
        handles.cfg.MarkModel = 4;  % User defined channels
        set(handles.edit_UserDefinChanns,'enable','on');
        set(handles.pushbutton_UserDefinChanns,'enable','on');
        set(handles.listbox_Channs,'string',[]);
        guidata(hObject, handles);
end

% --- Executes on button press in pushbutton_Help.
function pushbutton_Help_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox({ 'Mark Models: Select the channels your want to show. '...
         '     Original Channels: Show the all of channels of EEG data.'...
         '     16 Channels (NeuroScan Curry7): Show 16 channels from NeuroScan electrodes.'...
         '     32 Channels (NeuroScan Curry7): Show 32 channels from NeuroScan electrodes.'...
         '     16 Bipolar Channels (NeuroScan Curry7): Show 16 bipolar channels from NeuroScan electrodes.'...
         '     User Defined Channels: Please select the txt/xls/xlsx file which contains the list of channel labels you want to show.The list (rows) can be defined as channel number or labels!'...
         '    '...
         'Displayed Channels: Preview the channel labels you want to show.'...
         '    '...
         'NOTE: [1] The sort order of dispalyed channels depends on the list of channels in the file!'...
         '      [2] If selected channel list file is numerical, the channel label is row number of EEG data!'...
         '      [3] If number of columns are 2 in list file, the displayed data are:  data1(channels of first column) - data2 (channels of second column)'...
         '      [4] The size of columns of channel list file should be <=2.'...
       },'Help');
