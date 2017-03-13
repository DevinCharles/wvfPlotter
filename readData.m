function gui = readData(gui)
    % Get File Selection
    file_selection = find([gui.data.selection]);
    
    % Get Selected File Names
    fnames = {gui.data(file_selection).filename};
    
    % Loop over selected files
    for ind = 1:length(file_selection)
        % Current File Number and Name
        file_num = file_selection(ind);
        filename = fnames{ind};
        % Get Trace Selections
        axis_1_selection = [gui.data(file_num).headerdata.Axis1Selection];
        axis_2_selection = [gui.data(file_num).headerdata.Axis2Selection];
        
        pairs = [gui.data(file_num).headerdata(axis_1_selection).GTpair];
        pairs = reshape(pairs',2,length(pairs)/2)';
        if any(axis_2_selection)
            pairs_2 = [gui.data(file_num).headerdata(axis_2_selection).GTpair];
            pairs_2 = reshape(pairs_2',2,length(pairs_2)/2)';
            pairs = [pairs;pairs_2];
        end
        [y,t, ind_over, ind_under, ind_illegal, info] = ...
            wvfread(filename, Group, Trace);%, datapoints, step, startind);
        gui.data(file_num).headerdata.t = t;
        gui.data(file_num).headerdata.y = y;
    end
end
    
    
