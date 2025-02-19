clear; clc;

g = 9.8;
m = 0.551;
Jx = 0.0019005;
Jy = 0.0019536;
Jz = 0.0036894;

simulationTime = 100;  
stepValue = 0.1;     

timeVector = 0:stepValue:simulationTime;
dataValues = transpose(zeros(size(timeVector)));
timeSeries = timeseries(dataValues, timeVector);

x_ref = timeSeries; y_ref = timeSeries; z_ref = timeSeries; 

% 1
% z_ref.Data(1:end) = 1;
% y_ref.Data(101:end) = 4;
% z_ref.Data(201:end) = 2;

% 2
% z_ref.Data(1:end) = 2;
% x_ref.Data(101:end) = 1;
% y_ref.Data(201:end) = 1;

% 3
% x_ref.Data(1:end) = 1; y_ref.Data(1:end) = 1;
% x_ref.Data(101:end) = 3;
% z_ref.Data(201:end) = 2;

% 4
% x_ref.Data(1:end) = 2; y_ref.Data(1:end) = 1;
% z_ref.Data(101:end) = 3;
% y_ref.Data(201:end) = -1;

% 5
% x_ref.Data(1:end) = 1; z_ref.Data(1:end) = 2;
% y_ref.Data(101:end) = 1; z_ref.Data(101:end) = 1;
% z_ref.Data(201:end) = 3;

% 6
% y_ref.Data(1:end) = 1; z_ref.Data(1:end) = 1;
% x_ref.Data(101:end) = -1;
% y_ref.Data(201:end) = 3;

% 7
% x_ref.Data(1:end) = 1; y_ref.Data(1:end) = 1; z_ref.Data(1:end) = 1;
% x_ref.Data(101:end) = 2;
% y_ref.Data(201:end) = -1;

% % 8
% x_ref.Data(1:end) = 20; 
% y_ref.Data(101:end) = 40; 
% z_ref.Data(201:end) = 60;

% 9
% x_ref.Data(1:end) = 1;
% y_ref.Data(101:end) = 1;
% x_ref.Data(201:end) = 0;
% y_ref.Data(301:end) = 0;

% 10
% x_ref.Data(1:end) = 1;
% y_ref.Data(101:end) = 1;
% z_ref.Data(201:end) = 1;
% x_ref.Data(301:end) = 0;
% y_ref.Data(401:end) = 0;
% z_ref.Data(501:end) = 0;

