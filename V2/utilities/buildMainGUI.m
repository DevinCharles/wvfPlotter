function gui = buildMainGUI(gui)
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

% Last Modified 31-Jan-2017
    %% MAIN FIGURE
    % Set Figure Number
    f = figure(gui.setup.main_fig);
    clf
    % Set Figure Size
    f.Position(3)= 600;
    f.Position(4)= 300;
    figr_w = f.Position(3);
    figr_h = f.Position(4);
    % Set Figure Options
    set(f,'Resize','off','MenuBar','none','ToolBar','none',...
        'NumberTitle','off','Name','WVF Plotter')
    %% PANNEL SETUP
    % Width & Height Borders
    brdr_w = 0.0400;
    brdr_h = 0.0700;

    %% PANNEL - Listboxes
    pnl_lstbx = uipanel(...'Title','File & Channel Selection',...
        'Position',[...
            brdr_w,...  % From Left
            6*brdr_h,...  % From Bottom
            1-2*brdr_w,...  % Width
            1-7*brdr_h...   % Height
            ]);
    %% PANNEL - Plot Options
    pnl_pltop = uipanel('Title','Plot Options',...
        'Position',[...
            brdr_w,...  % From Left
            brdr_h,...  % From Bottom
            1-2*brdr_w,...  % Width
            4*brdr_h...   % Height
            ]);
    %% LISTBOX SETUP
    brdr_w = 010;
    brdr_h = 010;
    lsbx_w = 170;
    lsbx_h = 115;
    pnl_w = figr_w*pnl_lstbx.Position(3);
    pnl_h = figr_h*pnl_lstbx.Position(4);
    %% LISTBOX - Files
    titl_file = uicontrol(pnl_lstbx,...
        'Style','text',...
        'FontWeight','bold',...
        'String','Select Files(s) to Plot',...
        'Position',[brdr_w brdr_h+lsbx_h lsbx_w 2*brdr_h]);
    gui.listbox.files = uicontrol(pnl_lstbx,...
        'Style','listbox',...
        'String',{'Double Click to Open','Right Click for Options'},...
        'Value',[],...
        'Position',[brdr_w brdr_h lsbx_w lsbx_h],...
        'Max',2,...
        'Enable','on',...
        'Callback',@file_clbk);
    % Context Menu
    c = uicontextmenu;

    % Assign the uicontextmenu to the plot line
    gui.listbox.files.UIContextMenu = c;
    % Child Menu for Regular Open
    open_reg = uimenu('Parent',c,'Label','Open');
    % List Items for Regular Context Menu
    uimenu('Parent',open_reg,'Label','All Files','Callback',@file_clbk);
    uimenu('Parent',open_reg,'Label','WVF Files','Callback',@file_clbk);
    uimenu('Parent',open_reg,'Label','INCA Files','Callback',@file_clbk);
    uimenu('Parent',open_reg,'Label','CSV Files','Callback',@file_clbk);
    % Recursive mode in dir only supported in >= 2016b
    if str2double(gui.setup.version.year)>=2016 &&...
            strcmpi(gui.setup.version.letter,'b')
        % Child Menu for Recursive Open
        open_rec = uimenu('Parent',c,'Label','Open Recursive');
        % List Items for Recursive Context Menu
        uimenu('Parent',open_rec,'Label','All Files','Callback',@file_clbk);
        uimenu('Parent',open_rec,'Label','WVF Files','Callback',@file_clbk);
        uimenu('Parent',open_rec,'Label','INCA Files','Callback',@file_clbk);
        uimenu('Parent',open_rec,'Label','CSV Files','Callback',@file_clbk);
    end
    %% LISTBOX - Axis Left
    titl_axs1 = uicontrol(pnl_lstbx,...
        'Style','text',...
        'FontWeight','bold',...
        'String','Axis 1: Select Channel(s)',...
        'Position',[2*brdr_w+lsbx_w brdr_h+lsbx_h lsbx_w 2*brdr_h]);
    gui.listbox.axes_left = uicontrol(pnl_lstbx,...
        'Style','listbox',...
        'String',{''},...
        'Value',[],...
        'Position',[2*brdr_w+lsbx_w brdr_h lsbx_w lsbx_h],...
        'Max',2,...
        'Callback',@axs1_clbk);
    %% LISTBOX - Axis Right
    titl_axs2 = uicontrol(pnl_lstbx,...
        'Style','text',...
        'FontWeight','bold',...
        'String','Axis 2: Select Channel(s)',...
        'Position',[3*brdr_w+2*lsbx_w brdr_h+lsbx_h lsbx_w 2*brdr_h]);
    gui.listbox.axes_right = uicontrol(pnl_lstbx,...
        'Style','listbox',...
        'String',{''},...
        'Value',[],...
        'Position',[3*brdr_w+2*lsbx_w brdr_h lsbx_w lsbx_h],...
        'Max',2,...
        'Callback',@axs2_clbk);
end

function file_clbk(hObject, eventdata)
    % Find Main GUI Handle
    gui_handle = findobj(0,'Name','WVF Plotter');
    % Get GUI Structure
    gui = gui_handle.UserData;
    
    % Coming from Context Menu
    if strcmpi(hObject.Type,'uimenu')
        % Recursive or Regular Open
        open_type = lower(hObject.Parent.Label);
        % File Type
        file_type = lower(hObject.Label);
     % Coming from single or double click
    else
        open_type = get(gui_handle,'SelectionType');
        file_type = 'all files';
    end
    switch open_type
        case 'open'
            files = getFiles(file_type,false);
        case 'open recursive'
            files = getFiles(file_type,true);
        case 'normal'
            % Single Click, after files have been added
            if ~strcmpi(hObject.String{1},'Double Click to Open')
                % Reset Selection to False
                [gui.data(:).selection] = deal(false);
                % Now make actual selection True
                [gui.data(hObject.Value).selection] = deal(true);
            end
            % Update GUI Data
            set(gui_handle,'UserData',gui);
            % Call get Traces to update listboxes
            %TODO: Do we really need to do this every time? Maybe just when
            % a new directory is opened?
            getTraces(gui);
            return
        otherwise
            return
    end
    [folders,names,exts]=cellfun(@fileparts,files,'UniformOutput',false);
    
    gui.data = struct(...
        'selection',false,...
        'filename',files,...
        'folder',folders,...
        'name',names,...
        'ext',exts);
    set(gui.listbox.files,'String',strcat(names,' (',exts,')'));
    set(gui_handle,'UserData',gui);
end

function axs1_clbk(hObject, eventdata)
end

function axs2_clbk(hObject, eventdata)
end