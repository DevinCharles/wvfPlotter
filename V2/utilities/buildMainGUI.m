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
    pnl_brdr_w = 0.0400;
    pnl_brdr_h = 0.0600;

    %% PANNEL - Listboxes
    pnl_lstbx = uipanel(...'Title','File & Channel Selection',...
        'Position',[...
            pnl_brdr_w,...  % From Left
            7*pnl_brdr_h,...  % From Bottom
            1-2*pnl_brdr_w,...  % Width
            1-8*pnl_brdr_h...   % Height
            ]);
    %% PANNEL - Plot Options
    pnl_pltop = uipanel(...'Title','Plot Options',...
        'Position',[...
            pnl_brdr_w,...  % From Left
            pnl_brdr_h,...  % From Bottom
            1-2*pnl_brdr_w,...  % Width
            5.5*pnl_brdr_h...   % Height
            ]);
    %% LISTBOX SETUP
    brdr_w = 010;
    brdr_h = 010;
    lsbx_w = 170;
    lsbx_h = 120;
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
        'Tag','listbox_left',...
        'Callback',@axes_clbk);
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
        'Tag','listbox_right',...
        'Callback',@axes_clbk);

    %% PLOT OPTIONS SETUP
    brdr_w = 010;
    brdr_h = 010;
    edbx_w = 100;
    edbx_h = 18;
    pnl_tp = 100;
    %% EDIT TEXT - XLims
    titl_xlms = uicontrol(pnl_pltop,...
        'Style','text',...
        'FontWeight','bold',...
        'String','X Axis Limits',...
        'Position',[brdr_w pnl_tp-brdr_h-edbx_h edbx_w edbx_h]);
    gui.edit_box.x0 = uicontrol(pnl_pltop,...
        'Style','edit',...
        'String','',...
        'Position',[brdr_w pnl_tp-brdr_h-2*edbx_h (edbx_w-brdr_w/2)/2 edbx_h],...
        'Tag','xlim0',...
        'Callback',@lims_clbk);
    gui.edit_box.x1 = uicontrol(pnl_pltop,...
        'Style','edit',...
        'String','',...
        'Position',[1.5*brdr_w+edbx_w/2 pnl_tp-brdr_h-2*edbx_h (edbx_w-brdr_w/2)/2 edbx_h],...
        'Tag','xlim1',...
        'Callback',@lims_clbk);
    %% EDIT TEXT - YLims
    titl_ylms = uicontrol(pnl_pltop,...
        'Style','text',...
        'FontWeight','bold',...
        'String','Y Axis Limits',...
        'Position',[brdr_w pnl_tp-1.5*brdr_h-3*edbx_h edbx_w edbx_h]);
    gui.edit_box.y0 = uicontrol(pnl_pltop,...
        'Style','edit',...
        'String','',...
        'Position',[brdr_w pnl_tp-1.5*brdr_h-4*edbx_h (edbx_w-brdr_w/2)/2 edbx_h],...
        'Tag','ylim0',...
        'Callback',@lims_clbk);
    gui.edit_box.y1 = uicontrol(pnl_pltop,...
        'Style','edit',...
        'String','',...
        'Position',[1.5*brdr_w+edbx_w/2 pnl_tp-1.5*brdr_h-4*edbx_h (edbx_w-brdr_w/2)/2 edbx_h],...
        'Tag','ylim1',...
        'Callback',@lims_clbk);
    %% CHECKBOXES - Grid / Save Plots
    titl_ckbx = uicontrol(pnl_pltop,...
        'Style','text',...
        'FontWeight','bold',...
        'String','Plot Options',...
        'Position',[125 pnl_tp-brdr_h-edbx_h edbx_w edbx_h]);
    gui.checkbox.grid = uicontrol(pnl_pltop,...
        'Style','checkbox',...
        'String','Plot Grid',...
        'Value',1,...
        'Position',[140, pnl_tp-10-2*edbx_h, edbx_w, edbx_h],...
        'Callback',@grid_clbk);
    gui.checkbox.save = uicontrol(pnl_pltop,...
        'Style','checkbox',...
        'String','Save Plots',...
        'Position',[140, pnl_tp-12-3*edbx_h, edbx_w, edbx_h]);
    gui.checkbox.zero = uicontrol(pnl_pltop,...
        'Style','checkbox',...
        'String','Reset X Zero',...
        'Position',[140, pnl_tp-14-4*edbx_h, edbx_w, edbx_h]);
    %% PUSHBUTTONS - Filter / Plot / Analysis
    psbn_filt = uicontrol(pnl_pltop,...
        'Style','pushbutton',...
        'String','Filter',...
        'FontWeight','bold',...
        'Position',[286, 10, 78, 78]);
    psbn_plot = uicontrol(pnl_pltop,...
        'Style','pushbutton',...
        'String','Plot',...
        'FontWeight','bold',...
        'Position',[286+78+10, 10, 78, 78]);
    psbn_anly = uicontrol(pnl_pltop,...
        'Style','pushbutton',...
        'String','Analysis',...
        'FontWeight','bold',...
        'Position',[286+2*(78+10), 10, 78, 78]);
    
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
            try
                files = getFiles(file_type,false);
            catch
                return
            end
        case 'open recursive'
            try
                files = getFiles(file_type,true);
            catch
                return
            end
        case 'normal'
            % Single Click, after files have been added
            if ~strcmpi(hObject.String{1},'Double Click to Open')
                % Reset Selection to False
                [gui.data(:).selection] = deal(false);
                % Now make actual selection True
                [gui.data(hObject.Value).selection] = deal(true);
                % Get the selected file's traces
                ind = find([gui.data(hObject.Value).selection],1);
                % Update the axes listboxes
                gui.listbox.axes_left.String = [gui.data(ind).headerdata.name];
                gui.listbox.axes_right.String = [gui.data(ind).headerdata.name];
                % Update GUI Data
                set(gui_handle,'UserData',gui);
            end
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
    
    % Get traces for each file
    gui = getTraces(gui);
    
    set(gui.listbox.files,'String',strcat(names,' (',exts,')'),'Value',[]);
    
    % Update the GUI Structure
    set(gui_handle,'UserData',gui);
end

function axes_clbk(hObject, ~)
    % Find Main GUI Handle
    gui_handle = findobj(0,'Name','WVF Plotter');
    % Get GUI Structure
    gui = gui_handle.UserData;
    
    % If the listbox isn't empty
    if ~strcmpi(hObject.String{1},'')
        % Get the File Selection
        file_selection = find([gui.data.selection]);
        % Determine Which List Box
        if strcmpi(hObject.Tag,'listbox_left')
            selection = 'Axis1Selection';
        elseif strcmpi(hObject.Tag,'listbox_right')
            selection = 'Axis2Selection';
        end
        for i = 1:length(file_selection)
            % Reset Trace Selection
            [gui.data(file_selection(i)).headerdata.(selection)] = deal(false);
            % Make Selected Traces True
            [gui.data(file_selection(i)).headerdata(hObject.Value).(selection)] = deal(true);
        end
        set(gui_handle,'UserData',gui);
    else
        return
    end
end

function grid_clbk(hObject, ~)
    if hObject.Value
        value = 'on';
    else
        value = 'off';
    end
    %TODO: Probably going to want to use a tag find here
    axes = findobj('type','axes');
    set(axes,{'XGrid','YGrid','XMinorGrid','YMinorGrid'},repmat({value},1,4))
end

function lims_clbk(hObject,~)
    %TODO: Probably going to want to use a tag find here
    axes = findobj('type','axes');
   
    switch hObject.Tag
        case {'xlim0','xlim1'}
            xlim0 = findobj(hObject.Parent,'Tag','xlim0');
            xlim1 = findobj(hObject.Parent,'Tag','xlim1');
            xlims = str2double({xlim0.String,xlim1.String});
            if any(isnan(xlims))
                return
            else
                set(axes,'XLim',xlims)
            end
            
        case {'ylim0','ylim1'}
            ylim0 = findobj(hObject.Parent,'Tag','ylim0');
            ylim1 = findobj(hObject.Parent,'Tag','ylim1');
            ylims = str2double({ylim0.String,ylim1.String});
            if any(isnan(ylims))
                return
            else
                set(axes,'YLim',ylims)
            end
    end     
end
