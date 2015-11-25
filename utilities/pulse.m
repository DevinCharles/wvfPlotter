% Copyright (C) 2015  Devin C Prescott
function [tr,yr,tf,yf] = pulse(t,y,ppr)
% Clean up Digital Pulse
y(y<max(y)/2)=0;
y(y>max(y)/2)=1;
% Find differences
dy = diff(y);
dy = [0;dy];

% Rising Times
tr = t(dy>0);
dtr = diff(tr);
dtr = [dtr(1);dtr];

% Falling Times
tf = t(dy<0);
dtf = diff(tf);
dtf = [dtf(1);dtf];

% Output Data
yr = ppr./dtr;
yf = ppr./dtf;

