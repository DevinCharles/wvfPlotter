function files = getFiles(file_type,recursive)
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
    try
        % TODO: Save to APPDATA (see WVFREAD2)
        startpath = evalin('base','DataOut(1).folder');
    catch
        startpath = strcat(getenv('HOMEPATH'),'\Desktop\');
    end
    results = uigetdir(startpath);
    if ~results
        return
    end
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
            data_files = [hdr_files;dat_files;csv_files];
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
    if recursive % Only works for V >= 2016b
        files = cellfun(@(x,y) strcat(x,'\',y),{data_files.folder},{data_files.name},'UniformOutput',false)';
    else
        files = cellfun(@(x,y) strcat(results,'\',x),{data_files.name},'UniformOutput',false)';
    end
end