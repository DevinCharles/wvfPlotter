function varargout = analysis()
    %% MAIN FIGURE
    % Set Figure Number
    f = figure(1000);
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
    lsbx_file = uicontrol(pnl_lstbx,...
        'Style','listbox',...
        'String',{'Double Click to Open','Right Click for Options'},...
        'Value',1,...
        'Position',[brdr_w brdr_h lsbx_w lsbx_h],...
        'Max',2,...
        'Enable','on',...
        'Callback',@file_clbk);
    % Context Menu
    c = uicontextmenu;

    % Assign the uicontextmenu to the plot line
    lsbx_file.UIContextMenu = c;
    % Child Menu for Regular Open
    open_reg = uimenu('Parent',c,'Label','Open');
    open_rec = uimenu('Parent',c,'Label','Open Recursive');
    % List Items for Regular Context Menu
    uimenu('Parent',open_reg,'Label','All Files','Callback',@file_clbk);
    uimenu('Parent',open_reg,'Label','WVF Files','Callback',@file_clbk);
    uimenu('Parent',open_reg,'Label','INCA Files','Callback',@file_clbk);
    uimenu('Parent',open_reg,'Label','CSV Files','Callback',@file_clbk);
    % List Items for Recursive Context Menu
    uimenu('Parent',open_rec,'Label','All Files','Callback',@file_clbk);
    uimenu('Parent',open_rec,'Label','WVF Files','Callback',@file_clbk);
    uimenu('Parent',open_rec,'Label','INCA Files','Callback',@file_clbk);
    uimenu('Parent',open_rec,'Label','CSV Files','Callback',@file_clbk);
    %% LISTBOX - Axis Left
    titl_axs1 = uicontrol(pnl_lstbx,...
        'Style','text',...
        'FontWeight','bold',...
        'String','Axis 1: Select Channel(s)',...
        'Position',[2*brdr_w+lsbx_w brdr_h+lsbx_h lsbx_w 2*brdr_h]);
    lsbx_axs1 = uicontrol(pnl_lstbx,...
        'Style','listbox',...
        'String',{'One','Two','Three'},...
        'Value',1,...
        'Position',[2*brdr_w+lsbx_w brdr_h lsbx_w lsbx_h],...
        'Max',2,...
        'Callback',@axs1_clbk);
    %% LISTBOX - Axis Right
    titl_axs2 = uicontrol(pnl_lstbx,...
        'Style','text',...
        'FontWeight','bold',...
        'String','Axis 2: Select Channel(s)',...
        'Position',[3*brdr_w+2*lsbx_w brdr_h+lsbx_h lsbx_w 2*brdr_h]);
    lsbx_axs2 = uicontrol(pnl_lstbx,...
        'Style','listbox',...
        'String',{'One','Two','Three'},...
        'Value',1,...
        'Position',[3*brdr_w+2*lsbx_w brdr_h lsbx_w lsbx_h],...
        'Max',2,...
        'Callback',@axs2_clbk);
end

function file_clbk(hObject, eventdata)
    % Coming from Context Menu
    if strcmpi(hObject.Type,'uimenu')
        % Recursive or Regular Open
        open_type = lower(hObject.Parent.Label);
        % File Type
        file_type = lower(hObject.Label);
     % Coming from double-click
    else
        open_type = get(1000,'SelectionType');
        file_type = 'all files';
    end
    switch open_type
        case 'open'
            files = getFiles(file_type,false);
        case 'open recursive'
            files = getFiles(file_type,true);
        otherwise
            return
    end
    disp(files);
end

function axs1_clbk(hObject, eventdata)
end

function axs2_clbk(hObject, eventdata)
end

function files = getFiles(file_type,recursive)
    try
        % TODO: Save to APPDATA (see WVFREAD2)
        startpath = evalin('base','DataOut(1).folder');
    catch
        startpath = strcat(getenv('HOMEPATH'),'\Desktop\');
    end
    results = uigetdir(startpath);
    if recursive
        modifier = '\**\*';
    else
        modifier = '\*';
    end
    switch file_type
        case 'all files'
            % Get WVF Headers
            hdr_files = dir(strcat(results,modifier,'.hdr'));
            % Get INCA Dat Files
            dat_files = dir(strcat(results,modifier,'.dat'));
            % Get CSV Files
            csv_files = dir(strcat(results,modifier,'.csv'));
            data_files = [hdr_files,dat_files,csv_files];
        case 'wvf files'
            % Get WVF Headers
            data_files = dir(strcat(results,modifier,'.hdr'));
        case 'inca files'
            % Get INCA Dat Files
            data_files = dir(strcat(results,modifier,'.dat'));
        case 'csv files'
            % Get CSV Files
            data_files = dir(strcat(results,modifier,'.csv'));
    end
    files = cellfun(@(x,y) strcat(x,'\',y),{data_files.folder},{data_files.name},'UniformOutput',false)';
end