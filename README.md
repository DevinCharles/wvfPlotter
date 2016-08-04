# wvfPlotter
Matlab WVF File Plotter (for Yokogawa(R) Oscilloscope files). Requires utilityFunctions(https://github.com/DevinCharles/utilityFunctions) and wvfread (http://www.mathworks.com/matlabcentral/fileexchange/20830-read-yokogawa---wvf-files/content/wvfread.m) 
Check Matlab FileExchange

Make sure you add these three folders to you Matlab path (you can use the `pathtool` command), and be sure to save your path after editing using the `savepath` command.

### Command-Line Usage Example
```
% Get the Folder containing the files
folder = strcat(uigetdir(),'\');

% Find all .HDR files in the folder
files = dir(strcat(folder,'\*.HDR'));
files = {files.name};

% Create a structure for passing data into wvfPlotter
S = struct();
[S(1:length(files)).defPath] = deal(folder);
[S(1:length(files)).filename] = files{:};
% Below are the variable names you want to capture. This is somewhat
% "smart," so you can guess at variable names and it will try to find them
% for you. Read the info on varFind.m
[S.var_names] = deal({{'DC'},{'OUT'},{'IN'},{'TEMP'},{'PRESS'}});

S_out = wvfPlotter(S);
```