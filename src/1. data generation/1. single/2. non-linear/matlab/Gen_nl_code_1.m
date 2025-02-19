clear; clc;

% initialization
g = 9.8;
m = 0.551;
Jx = 0.0019005;
Jy = 0.0019536;
Jz = 0.0036894;

simulationTime = 100; 
stepValue = 0.1;    
numPointsScenario = 10;
setPointDuration = 10; 
numScenarios = 1;

timeVector = 0:stepValue:simulationTime;
dataValues = transpose(zeros(size(timeVector)));
timeSeries = timeseries(dataValues, timeVector);

variables = {'x_ref', 'y_ref', 'z_ref', ...
    'tau_psi_attack_selector', 'tau_psi_DOS_data', 'tau_theta_attack_selector', ...
    'tau_theta_DOS_data', 'tau_phi_attack_selector', 'tau_phi_DOS_data', ...
    'T_attack_selector', 'T_DOS_data', 'x_attack_selector', 'x_DOS_data', ...
    'y_attack_selector', 'y_DOS_data', 'z_attack_selector', 'z_DOS_data', ...
    'phi_attack_selector', 'phi_DOS_data', 'theta_attack_selector', 'theta_DOS_data', ...
    'psi_attack_selector', 'psi_DOS_data', 'T_selector'};

for i = 1:length(variables)
    eval([variables{i} ' = timeSeries;']);
end


for i = 1:length(variables)
    % 1. points
    % 1.1 design
    % random points, between [-5, 5], each step change in 1 or 2 dimension %
    points = [0, 0, 1;
              1, 0, 1;
              2, 1, 1;
              0, 1, 1;
              0, 3, 3;
              -2, 3, 3;
              -2, -3, 3;
              1, -3, 2;
              -1, -2, 2;
              0, 1, 2];
     
    matrixSize = [10, 3];
    matrix = randi([-5, 5], matrixSize);

    % 1.2 implement
    for i = 1:numPointsScenario
        x_ref.Data(1 + (i-1) * setPointDuration / stepValue:end) = points(i, 1);
        y_ref.Data(1 + (i-1) * setPointDuration / stepValue:end) = points(i, 2);
        z_ref.Data(1 + (i-1) * setPointDuration / stepValue:end) = points(i, 3);
    end


    % 2. attacks
    % 2.1 design
    % DoS
    % duration can be 1, 2, 3, should be considered in setting DoS_times %
    DoS_duration = 3;
    % each row is duration of an attack, number of attacks between 2,3 %
    DoS_times = [61, 90; 
                 720, 750];

    % FDI 
    % duration can be 1, 2, 3 %
    FDI_duration = 3;
    % each row is duration of an attack, number of attacks between 2,3 %
    FDI_times = [251, 280; 
                 351, 380];
    % value can change between [-3, 3] %
    T_FDI_value = 2;

    % Replay
    % duration can be 1, 2, 3 %
    Replay_duration = 3;
    % first value should be smaller than second one, last one is end of replay
    % time %
    Replay_time = [401, 501, 530];
    T_delay = Replay_time(2) - Replay_time(1);

    % 2.2 implement
    T_selector.Data(:) = 1;
    for i = 1:size(DoS_times, 1)
        T_selector.Data(DoS_times(i, :)) = 2;
    end
    for i = 1:size(FDI_times, 1)
        T_selector.Data(FDI_times(i, :)) = 3;
    end
    T_selector.Data(Replay_time(2): Replay_time(3)) = 4;
    T_selector.Data = int32(T_selector.Data);

    % simulation
    simOut = sim('Gen_nl');
end