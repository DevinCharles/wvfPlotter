function gui = plotData(gui)
    % Get File Selection
    file_selection = find([gui.data.selection]);
    
    % Get Selected File Names
    fname = {gui.data(file_selection).filename};
    
    % Get Selected File Extensions
    ext = lower({gui.data(file_selection).ext});
    
    % Loop over selected files
    for ind = 1:length(file_selection)
        % Current File Number and Name
        file_num = file_selection(ind);
        filename = fname{ind};
        % Get Trace Selections
        axis_1_selection = [gui.data(file_num).headerdata.Axis1Selection];
        axis_2_selection = [gui.data(file_num).headerdata.Axis2Selection];
        
        % If this is a wvf/hdr file, we need to read in the data first
        if strcmpi(ext{ind},'.hdr')
            pairs = [gui.data(file_num).headerdata(axis_1_selection).GTpair];
            pairs = reshape(pairs',2,length(pairs)/2)';
            if any(axis_2_selection)
                pairs_2 = [gui.data(file_num).headerdata(axis_2_selection).GTpair];
                pairs_2 = reshape(pairs_2',2,length(pairs_2)/2)';
                pairs = [pairs;pairs_2];
            end
            % TODO: FIX THIS... Read all groups and pairs at once???
            % Started down the right path... then hacked it together to get
            % it working quickly...
            sel_inds = [find(axis_1_selection),find(axis_2_selection)];
            
            for i = 1:size(pairs,1)
                trace_name = gui.data(file_num).headerdata(sel_inds(i)).name;
                try
                    filter_data = gui.filt_params.(strcat('fld_',trace_name));
                    filt_bool = filter_data.toggle;
                catch
                    filt_bool = false;
                end
                
                [gui.data(file_num).headerdata(sel_inds(i)).y,...
                    gui.data(file_num).headerdata(sel_inds(i)).t] = ...
                    wvfread(filename, pairs(i,1), pairs(i,2));
                
                if filt_bool
                    yf = auto_butter(...
                        gui.data(file_num).headerdata(sel_inds(i)).y,...
                        gui.data(file_num).headerdata(sel_inds(i)).t,...
                        0,...
                        filter_data.value,...
                        filter_data.type,...
                        filter_data.order);
                    gui.data(file_num).headerdata(sel_inds(i)).y = yf{:};
                end
            end
            
        end
       
        % Now plot the data
        tl = {gui.data(file_num).headerdata(axis_1_selection).t};
        yl = {gui.data(file_num).headerdata(axis_1_selection).y};
%         flt_flds = strcat('fld_',{gui.data(file_num).headerdata(axis_1_selection).name});
%         yfl = auto_butter(yl,tl,0,...
%             gui.filt_params.filter_val,...
%             gui.filt_params.filter_type,...
%             gui.filt_params.filter_ord);
        
        nl = {gui.data(file_num).headerdata(axis_1_selection).name};
        
        tr = {gui.data(file_num).headerdata(axis_2_selection).t};
        yr = {gui.data(file_num).headerdata(axis_2_selection).y};
%         yfr = auto_butter(yr,tr,0,...
%             gui.filt_params.filter_val,...
%             gui.filt_params.filter_type,...
%             gui.filt_params.filter_ord);
        
        nr = {gui.data(file_num).headerdata(axis_2_selection).name};
        
        colors = repmat(colormap(parula(5)),100,1);
        
        figure(ind)
        clf;
        
        if ~isempty(tr)
            yyaxis left
        end
        for i = 1:length(tl)
            hold on
            hl = plot(tl{i},yl{i},'-','LineWidth',2);
            hl.Color = colors(i,1:3);
            hold off
        end
        legend(nl,'Interpreter','none')
        [~,title_str,~] = fileparts(filename);
        title(title_str)
        
        vunit = {gui.data(file_num).headerdata(axis_1_selection).VUnit};
        ylabel(strcat('[',strjoin(vunit,'  \\\\  '),']'))
        
        if gui.checkbox.grid.Value
            set(gca,{'XGrid','YGrid','XMinorGrid','YMinorGrid'},repmat({'on'},1,4))
        else
            set(gca,{'XGrid','YGrid','XMinorGrid','YMinorGrid'},repmat({'off'},1,4))
        end
        if exist('dataCursor','file')==2
            % Custom DataCursor
            dcm_obj = datacursormode(gcf);
            datacursormode on
            set(dcm_obj,'UpdateFcn',@dataCursor);
        else
            warning('UtilityFunctions is not installed. Get it here:')
            disp('<a href="https://www.mathworks.com/matlabcentral/fileexchange/54074-devincharles-wvfplotter">https://www.mathworks.com/matlabcentral/fileexchange/54074-devincharles-wvfplotter</a>')
        end
        % Plot on the Second Axis
        if ~isempty(tr)
            yyaxis right
            for i = 1:length(tr)
                hold on
                hr = plot(tr{i},yr{i},'-','LineWidth',2);
                hr.Color = colors(length(tl)+i,1:3);
                hold off
            end
            legend([nl(:);nr(:)],'Interpreter','none')
            vunit = {gui.data(file_num).headerdata(axis_2_selection).VUnit};
            ylabel(strcat('[',strjoin(vunit,'  \\\\  '),']'))
        end
        
    end
end
    
    
