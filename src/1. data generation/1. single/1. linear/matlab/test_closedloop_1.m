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

T_ref = timeSeries; 
tau_phi_ref = timeSeries; tau_theta_ref = timeSeries;

