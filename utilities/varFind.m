function [varNames,timeNames] = varFind(vars,names)
% VARS - list of variable names you want to search through. Try who() for
% variables in the workspace or who('-file','filename.mat') for variables 
% saved to a file. This is useful for only loading the variables you need.
%
% NAMES - the names you want to look for in nested cell
% {{'a','b'},{'c',d'}} will return one list of variables with names
% matching 'a' and 'b', and one list matching 'c' and 'd'. Names are not
% case sensitive.
%
% Typical variable abbreviations:
%   '_n_' for RPM or Speed
%   '_p_' for Pressure
%   '_T_' for Temperature
%   'Des' for Desired
%
% Usage: [varNames,timeNames] = varFind(who,{{'_n_','Eng'},{'_p_','Eng'}})
% will return variable names for Engine Speed and Engine RPM and their
% associated time values
%
% Author:
% Devin Prescott, 2014
% devin.c.prescott@delphi.com
%
% MDF Import by Stuart McGarrity
% <a href="http://www.mathworks.com/matlabcentral/fileexchange/9622-mdf-import-tool-and-function">MDF Import Tool</a>
%
% See also:
% WHO

    % Initialize varNames & timeNames
    varNames = {};
    timeNames = {};
    Vars = vars;
    vars = lower(vars);
    
    % Check to make sure it's a nested cell
    if ~iscell(names{1})
        names = {names};
    end
    trace = 1;
    while trace < size(names,2)+1
        ind = true(size(vars));
        for tracestr = 1:size(names{trace},2)
            ind = logical(ind.*cellfun(@(x) any(x),...
                strfind(vars,lower(names{trace}{tracestr}))));
        end
        if sum(ind) == 0
            % Alert User & Get new string
            prompt = repmat({' '},[length(names{trace}),1]);
            newName = inputdlg(prompt,'No Matches Found',[1 70],...
                names{trace});
            newName(cellfun(@isempty,newName))=[];
            if isempty(newName)
                newName = Vars(:);
                    [n,~] = listdlg('ListString',newName,...
                'SelectionMode','single','ListSize',[350 200]);
                names{trace}{tracestr} = newName{n};
            else
            names{trace} = newName';
            end
            % Restart Loop
            trace = 0;
        elseif sum(ind) > 1
            newName = Vars(ind);
            [n,~] = listdlg('ListString',newName,...
                'SelectionMode','single','ListSize',[350 200]);
            names{trace}{tracestr} = newName{n};
            %
            ind = strcmpi(vars,newName{n});
            varNames{trace} = Vars(ind);
            tn = cellfun(@(x) regexp(x,'\d+$','match'),varNames{trace},...
                'UniformOutput',false);
            tn_temp = cellfun(@(x) strcat('time_',x), tn,...
                'UniformOutput',false);
            timeNames{trace} = tn_temp{:};
            % Restart Loop
%             trace = 0;
        else
            varNames{trace} = Vars(ind);
            tn = cellfun(@(x) regexp(x,'\d+$','match'),varNames{trace},...
                'UniformOutput',false);
            tn_temp = cellfun(@(x) strcat('time_',x), tn,...
                'UniformOutput',false);
            timeNames{trace} = tn_temp{:};
        end
        trace = trace + 1;
    end
end