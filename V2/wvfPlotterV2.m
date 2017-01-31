function varargout = wvfPlotterV2(varargin)
%     wvfPlotter - This program displays and manipulates data collected on
%     Yokogawa (R) oscilloscopes, INCA Data, and CSV Viles. Data import is 
%     accomplished through the use of Erik Benkler's wvfread program for 
%     WVF files, and Daniel F.'s MDF Import Tool for INCA Files.
%     Command line access is provided but not yet well documented. 
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

% Last Modified 31-Jan-2017

    %% Matlab Version
    gui.setup.version = regexp(version,'\(R(?<year>\d{4})(?<letter>\D{1})\)','names');
    gui.setup.main_fig = 1000;
    %% Build Main GUI
    gui = buildMainGUI(gui);
    disp(gui);
    
