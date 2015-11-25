function varargout = wvfPlotter(varargin)
%     wvfPlotter - This program displays and manipulates data collected on
%     Yokogawa (R) oscilloscopes. Data import is accomplished through the
%     use of Erik Benkler's wvfread program. Command line acces is provided
%     but not yet well documented. 
%     Copyright (C) 2015  Devin C Prescott
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%     
%     Author:
%     Devin C Prescott
%     devin.c.prescott@gmail.com

% Last Modified 18-Nov-2015

if nargin >=1
    if isstruct(varargin{1})
        % Hide the GUI
        varargin = [{'visible','off'},varargin];
    end
end
    
% end

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wvfPlotter_OpeningFcn, ...
                   'gui_OutputFcn',  @wvfPlotter_OutputFcn, ...
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

%% --- Executes just before wvfPlotter is made visible.
function wvfPlotter_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for wvfPlotter
handles.output = hObject;
handles.gui_handle = get(gca,'Parent');

% If running from the command line (Structure Input)
try 
    isstruct(varargin{end});
    handles.Struct = varargin{end};
    handles.hidden = true;
    cmd_line_helper(hObject,handles);
    handles = guidata(hObject);
catch
    handles.hidden = false;
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes wvfPlotter wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%% --- Outputs from this function are returned to the command line.
function varargout = wvfPlotter_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;

function cmd_line_helper(hObject,handles)
S = handles.Struct;
handles.FolderName = S(1).defPath;
handles.FileNames = {S.filename};
getHdrInfo(hObject,handles);
handles = guidata(hObject);
[S.var_names,~] = deal(varFind(handles.TraceStruct.Name,S(1).var_names));
handles.Struct = S;
get_t_y(hObject,handles)
handles = guidata(hObject);
for i = 1:length(handles.y)
    S(i).t = handles.t{i};
    S(i).y = handles.y{i};
end
[S(:).var_names] = handles.Struct.var_names;
handles.output = S;
guidata(hObject, handles);

%% --- Executes on button press in dir_pushbutton.
function dir_pushbutton_Callback(hObject, eventdata, handles)
% Load Filenames and strip extension - Includes error handling if user
% selects cancel or chooses a directory without WVF files
try
    startpath = evalin('base','DataOut(1).folder');
catch
    startpath = strcat(getenv('HOMEPATH'),'\Desktop\');
end

dir_sel = uigetdir(startpath);
if dir_sel==0
    msgbox('Please pick a directory containing .wvf files');
    return
else
    FolderName = strcat(dir_sel,'\');
    FileNames = dir(strcat(FolderName,'*.HDR'));
    if isempty(FileNames)
        msgbox('Please pick a directory containing .wvf files');
        return        
    end
    FileNames = {FileNames.name};
    for i = 1:length(FileNames)
        FileNames{i}(end-3:end)=[];
    end
end

if ~handles.hidden
    set(handles.files_listbox, 'String', FileNames);
    set(handles.files_listbox, 'Value', []);
end

% Add variables to handle structure
handles.FileNames = FileNames;
handles.FolderName = FolderName;

% Get Header Info
getHdrInfo(hObject,handles);
handles = guidata(hObject);
guidata(hObject,handles);

function getHdrInfo(hObject,handles)
% Load header info from the first file 
% **ALL FILES MUST HAVE THE SAME HEADER - From the same experiment**
FileNames = handles.FileNames;
FolderName = handles.FolderName;

HDRinfo = hdrread(strcat(FolderName,FileNames{1}));
n_Groups = HDRinfo.GroupNumber;
k=1;
for i = 1:n_Groups
    Group = strcat('Group',num2str(i));
    n_Trace = HDRinfo.(Group).TraceNumber;
    for j = 1:n_Trace
        Trace = strcat('Trace',num2str(j));
        % Fill Structure
        TraceStruct.Name(k) = HDRinfo.(Group).(Trace).TraceName;
        TraceStruct.GTpair{k}=[i,j];
        TraceStruct.HUnit(k) = HDRinfo.(Group).(Trace).HUnit;
        TraceStruct.VUnit(k) = HDRinfo.(Group).(Trace).VUnit;
        TraceStruct.Samples(k) = HDRinfo.(Group).(Trace).BlockSize;
        k=k+1;
    end
end

set(handles.axis1_listbox, 'String', TraceStruct.Name);
set(handles.axis1_listbox, 'Value', []);
set(handles.axis2_listbox, 'String', TraceStruct.Name);
set(handles.axis2_listbox, 'Value', []);
% set(handles.popup_trigger, 'String', TraceStruct.Name{1})

% Add variables to handle structure
handles.TraceStruct = TraceStruct;
guidata(hObject, handles);

%% --- Executes during object creation, after setting all properties.
function files_listbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% --- Executes on selection change in axis1_listbox.
function axis1_listbox_Callback(hObject, eventdata, handles)
channels = handles.TraceStruct.Name;
channels_selected = [get(handles.axis1_listbox,'Value'),...
                     get(handles.axis2_listbox,'Value')];
set(handles.popup_trigger, 'String', channels(channels_selected))
guidata(hObject, handles);

%% --- Executes during object creation, after setting all properties.
function axis1_listbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% --- Executes on selection change in axis2_listbox.
function axis2_listbox_Callback(hObject, eventdata, handles)
channels = handles.TraceStruct.Name;
channels_selected = [get(handles.axis1_listbox,'Value'),...
                     get(handles.axis2_listbox,'Value')];
set(handles.popup_trigger, 'String', channels(channels_selected))
guidata(hObject, handles);

%% --- Executes during object creation, after setting all properties.
function axis2_listbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function get_t_y(hObject,handles)
% Get Variables
if ~handles.hidden
    try
        TraceStruct = handles.TraceStruct;
    catch
        return
    end
    trigger_ch = cellstr(get(handles.popup_trigger,'String'));
    trigger_ch = trigger_ch(get(handles.popup_trigger,'Value'));
    trigger_ch = find(strcmpi(TraceStruct.Name,trigger_ch));
    trigger_val = str2double(get(handles.edit_trig_val,'String'));
    try
        filt_params = handles.filt_params;
        set_filt = true;
    catch
        filt_params = '';
        set_filt = false;
    end
   
    FileNames = handles.FileNames;
    FolderName = handles.FolderName;
    files_selected = get(handles.files_listbox,'Value');
    ch_sel{1} = get(handles.axis1_listbox,'Value');
    y_label{1} =  strjoin({TraceStruct.VUnit{[ch_sel{1}]'}},' \\ ');
    if isempty(get(handles.axis2_listbox,'Value'))
    else
        ch_sel{2} = get(handles.axis2_listbox,'Value');
        y_label{2} =  strjoin({TraceStruct.VUnit{[ch_sel{2}]'}},' \\ ');
    end
    units = TraceStruct.VUnit([ch_sel{:}]);
    
else % Running from command line
    TraceStruct = handles.TraceStruct;
    trigger_ch = handles.Struct(1).var_names{1};
    trigger_ch = find(strcmpi(TraceStruct.Name,trigger_ch));
    trigger_val = 0.1;
    FileNames = handles.FileNames;
    FolderName = handles.FolderName;
    files_selected = 1:length(handles.Struct);
    ch_sel{1} = find(ismember(TraceStruct.Name,...
        [handles.Struct(1).var_names{:}]));
    y_label = '';
    
    [handles.Struct(:).units] = TraceStruct.VUnit([ch_sel{:}]);
    [handles.Struct(:).var_names] = deal(cellfun(@(x) {{x}},...
        TraceStruct.Name(ch_sel{:})));
end

% Read Scope Files into y and t
for file = 1:length(files_selected)
    HDRinfo = hdrread(strcat(FolderName,FileNames{files_selected(file)}));
    file_date(file) = HDRinfo.Group1.Trace1.Date;
    file_time(file) = HDRinfo.Group1.Trace1.Time;
    for axis = 1:length(ch_sel)
        for num = 1:length(ch_sel{axis})
            
            [y{file}{axis}(:,num),t{file}{axis}(:,num)]= wvfread(...
                strcat(FolderName,FileNames{files_selected(file)}),...
                TraceStruct.GTpair{ch_sel{axis}(num)}(1),...
                TraceStruct.GTpair{ch_sel{axis}(num)}(2));
            if ch_sel{axis}(num)==trigger_ch
                try
                    trim_start(file) = find([y{file}{axis}(:,num)]>trigger_val,1,'first');
                catch
                    trim_start(file) = 1;
                end
            end
        end
    end
end

% Trim data before trigger
for file = 1:length(files_selected)
    for axis = 1:length(ch_sel)
        y{file}{axis}(1:trim_start(file),:)=[];
        t{file}{axis}(1:trim_start(file),:)=[];
        % Filter Data
        if set_filt
            for num = 1:length(ch_sel{axis})
                try
                    name = TraceStruct.Name{ch_sel{axis}(num)};
                    filter_val = filt_params.(name).('value');
                    filter_type = filt_params.(name).('type');
                    filter_ord = filt_params.(name).('order');
                    filter_tog = filt_params.(name).('toggle');
                catch
                    break
                end
                if filter_tog
                    yf = auto_butter(y{file}{axis}(:,num),t{file}{axis}(:,num),0,filter_val,filter_type,filter_ord);
                    y{file}{axis}(:,num)=yf{:};
                end
            end
        end
    end
end

handles.file_date = file_date;
handles.file_time = file_time;
handles.ch_sel = ch_sel;
handles.files_selected = files_selected;
handles.y_label = y_label;
handles.y = y;
handles.t = t;

guidata(hObject,handles);

%% --- Executes on button press in plot_pushbutton.
function plot_pushbutton_Callback(hObject, eventdata, handles)
% Error Handling
if isempty(get(handles.files_listbox,'Value'))
    msgbox('Please choose at least one file to plot.');
    return
elseif isempty(get(handles.axis1_listbox,'Value'))
    msgbox('Please choose at least one channel to plot.');
    return
end

% Save Figure Setup
FilterSpec = {'.pdf';'.png'};
DialogTitle = 'Save Figure As';
Format = {'-dpdf','-dpng'};

get_t_y(hObject,handles);
handles = guidata(hObject);

% Get Variables
file_date = handles.file_date;
file_time = handles.file_time;
ch_sel = handles.ch_sel;
files_selected = handles.files_selected;
TraceStruct = handles.TraceStruct;
y_label = handles.y_label;
% units = handles.Struct(1).units;
y = handles.y;
t = handles.t;

% Plot and Label
AX{length(t)}=[];
H1{length(t)}=[];
H2{length(t)}=[];
FIG{length(t)}={};
for i=1:length(t) % For each File
% ---------------------This Plots on Embedded Axis-------------------------
    if length(t)==1
        hax = findobj(gcf,'type','axes');
        if length(hax) > 1
            delete(hax(1:end-1))
        end
        if length(y{1,1}) == 1 % If using only one axis to plot
            H1{i} = plot([t{1}{1}(:,1:end)],[y{1}{1}(:,1:end)]);
            ylabel(y_label{1},'Interpreter','none');
            xlabel('Seconds','Interpreter','none');
            H2{i} = '';
            FIG{i} = '';
        else % If using two axes to plot
            [AX{i},H1{i},H2{i}] = plotyy([t{1}{1}(:,1:end)],...
                                        [y{1}{1}(:,1:end)],...
                                        [t{1}{2}(:,1:end)],...
                                        [y{1}{2}(:,1:end)]);
            set(get(AX{i}(1),'Ylabel'),'String',y_label{1},...
                'Interpreter','none') 
            set(get(AX{i}(2),'Ylabel'),'String',y_label{2},...
                'Interpreter','none')
            set(get(AX{i}(1),'Xlabel'),'String','Seconds',...
                'Interpreter','none')
            linkaxes(AX{i},'x');
            FIG{i} = '';
        end
        Leg = legend(TraceStruct.Name{[ch_sel{:}]'});
        set(Leg,'Interpreter','none');
        title_str = strcat(handles.FileNames(files_selected(i)),...
            '-',file_date(i),'-',file_time(i));
        title(title_str,'Interpreter','none');
        if get(handles.checkbox_grid,'Value');
            grid minor
        else
            grid off
        end   
        print_fig = figure(1);
        set(print_fig,'Visible','off'); % Invisible figure for save
    else % Plotting more than one file - create figures for each
        print_fig = figure(i);
    end
%---------------------This Plots on Figure(i)------------------------------    
    if length(y{1,1}) == 1 % If using only one axis to plot
        H1{i} = plot([t{i}{1}(:,1:end)],[y{i}{1}(:,1:end)]);
        ylabel(y_label{1},'Interpreter','none');
        xlabel('Seconds','Interpreter','none');
        H2{i} = '';
        AX{i}(1) = gca;
        set(gca,'Tag',handles.FileNames{files_selected(i)})
        FIG{i} = gcf;
    else % If using two axes to plot
        [AX{i},H1{i},H2{i}] = plotyy([t{i}{1}(:,1:end)],[y{i}{1}(:,1:end)],...
                            [t{i}{2}(:,1:end)],[y{i}{2}(:,1:end)]);
        set(get(AX{i}(1),'Ylabel'),'String',y_label{1},...
            'Interpreter','none')
        set(gca,'Tag',handles.FileNames{files_selected(i)})
        set(get(AX{i}(2),'Ylabel'),'String',y_label{2},...
        'Interpreter','none')
        set(get(AX{i}(1),'Xlabel'),'String','Seconds',...
            'Interpreter','none')
        linkaxes(AX{i},'x');
        FIG{i} = gcf;
    end
    Leg = legend(TraceStruct.Name{[ch_sel{:}]'});
    set(Leg,'Interpreter','none');
    title_str = strcat(handles.FileNames(files_selected(i)),...
        '-',file_date(i),'-',file_time(i));
    title(title_str,'Interpreter','none');
    if get(handles.checkbox_grid,'Value');
        grid minor
    else
        grid off
    end
    % Save Figures
    if get(handles.save_checkbox,'Value');
        DefaultName = char(handles.FileNames(files_selected(i)));
        set(gcf,'PaperUnits', 'inches',...
        'PaperPosition', [0 0 11 8.5],...
        'PaperSize', [11 8.5]);
        [FileName,PathName,FilterIndex] = uiputfile(FilterSpec,...
            DialogTitle,DefaultName);
        print(print_fig,Format{FilterIndex},...
            strcat(PathName,FileName),'-r600');
    end
end

% Save data to Workspace
S = struct(...
    'filename',handles.FileNames(files_selected),...
    'folder',deal(handles.FolderName),...
    't',t,...
    'y',y,...
    'ax',AX,...
    'h1',H1,...
    'h2',H2,...
    'fig',FIG);

% [S.units] = deal(units);

[S.traces] = deal(TraceStruct.Name([ch_sel{:}]'));
assignin('base','DataOut',S)

handles.y = y;
handles.t = t;
guidata(hObject, handles);

%% --- Executes during object creation, after setting all properties.
function embedded_fig_CreateFcn(hObject, eventdata, handles)
set(gcf,'DefaultAxesTag','embedded_fig')
guidata(hObject, handles);


%% --- Executes on button press in checkbox_grid.
function checkbox_grid_Callback(hObject, eventdata, handles)
if get(hObject,'Value');
    grid minor
else
    grid off
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function checkbox_grid_CreateFcn(hObject, eventdata, handles)
set(hObject,'Value',1);

% --- Executes during object creation, after setting all properties.
function popup_trigger_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_trig_val_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','1')

% --- Executes on button press in analysis_pushbutton.
function analysis_pushbutton_Callback(hObject, ~, handles)
get_t_y(hObject,handles);
analysis()


% --- Executes on button press in filter_button.
function filter_button_Callback(hObject, ~, handles)
get_t_y(hObject,handles);
filter_setup()
