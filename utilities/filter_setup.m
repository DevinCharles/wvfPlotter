% Copyright (C) 2015  Devin C Prescott
function varargout = filter_setup()
    % Find Main GUI Handle
    gui_handle = findobj(0,'Name','WVF Plotter');
    % Get GUI Structure
    gui = gui_handle.UserData;
    % Check that a File and a Trace are Selected
    try
        if ~any([gui.data(find([gui.data.selection],1)).headerdata.Axis1Selection])
            return
        end
    catch
        return
    end
    
    % Setup Figure
    f = figure(2000);
    f.Position(3)= 600;
    
    left = gui.listbox.axes_left.String(gui.listbox.axes_left.Value);
    right = gui.listbox.axes_right.String(gui.listbox.axes_right.Value);
    channels = [left(:);right(:)];
    
    f.Position(4)= (length(channels))*(30+5)+45;
    h0 = f.Position(4)-30-5*(length(channels)-1);

    set(f,'Resize','off','MenuBar','none','ToolBar','none',...
        'NumberTitle','off','Name','WVF Plotter - Filter Setup')
    
    toggles = uipanel('Title','Filter Toggles',...
             'Position',[0.03 0.08 0.200 0.85]);
    
    options = uipanel('Title','Filter Options',...
             'Position',[0.272 0.08 0.70 0.85]);
    %% Loop Through Channels and Create
    filt_params = struct();
    for ind = 1:length(channels)
        fld_name = strcat('fld_',channels{ind});
        try
            % If toggle exists, then we've already set values
            toggle = gui.filt_params.(fld_name).('toggle');
            type = gui.filt_params.(fld_name).('type');
            type = find(strcmpi(type,{'low','high','bandpass','stop'}));
            value = gui.filt_params.(fld_name).('value');
            order = gui.filt_params.(fld_name).('order');
        catch
            % If toggle doesn't exit, we haven't set defaults
            gui.filt_params.(fld_name).('toggle') = false;
            toggle = false;
            gui.filt_params.(fld_name).('type') = 'low';
            type = 1;
            gui.filt_params.(fld_name).('value') = 20;
            value = 20;
            gui.filt_params.(fld_name).('order') = 3;
            order = 3;
        end
        
        
        uicontrol('Parent', toggles, 'Style', 'toggle', ...
            'Position', [10 h0-30*ind 95 20],'String',channels(ind),...
            'Value',abs(toggle),...
            'Callback', @update_gui,...
            'tag',strcat(fld_name,'`toggle'));
        
        uicontrol('Parent', options, 'Style', 'text',...
            'String', 'Filter Type','HorizontalAlignment', 'left',...
            'Position', [10 h0-30*ind 60 20]);
        
        uicontrol('Parent', options, 'Style', 'popupmenu',...
            'String', {'Low-Pass','High-Pass','Band-Pass','Band-Stop'},...
            'Value',type,...
            'Position', [70 h0-30*ind 80 20],...
            'Callback', @update_gui,...
            'tag',strcat(fld_name,'`type'));
        
        uicontrol('Parent', options, 'Style', 'text',...
            'String', 'Filter Value','HorizontalAlignment', 'left',...
            'Position', [170 h0-30*ind 60 20]);
        
        uicontrol('Parent', options, 'Style', 'edit',...
            'String', num2str(value),'HorizontalAlignment', 'right',...
            'Position', [240 h0-30*ind 40 20],...
            'Callback', @update_gui,...
            'tag',strcat(fld_name,'`value'));
        
        uicontrol('Parent', options, 'Style', 'text',...
            'String', 'Filter Order','HorizontalAlignment', 'left',...
            'Position', [290 h0-30*ind 60 20]);
        
        uicontrol('Parent', options, 'Style', 'edit',...
            'String', num2str(order),'HorizontalAlignment', 'right',...
            'Position', [360 h0-30*ind 40 20],...
            'Callback', @update_gui,...
            'tag',strcat(fld_name,'`order'));
    end
    % Set GUI Structure
    gui_handle.UserData= gui;
end

function update_gui(source,~)
    % Find Main GUI Handle
    gui_handle = findobj(0,'Name','WVF Plotter');
    % Get GUI Structure
    gui = gui_handle.UserData;
    
    field = strsplit(source.Tag,'`');
    switch field{2}
        case 'value'
            data = str2num(source.String);
        case 'order'
            data = str2double(source.String);
        case 'type'
            filters = {'low','high','bandpass','stop'};
            data = filters{source.Value};
        case 'toggle'
            data = logical(source.Value);     
    end
    gui.filt_params.(field{1}).(field{2}) = data;
    
    % Set GUI Structure
    gui_handle.UserData= gui;
end
