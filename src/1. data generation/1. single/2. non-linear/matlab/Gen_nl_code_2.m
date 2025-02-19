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
numScenarios = 10;

timeVector = 0:stepValue:simulationTime;
dataValues = transpose(zeros(size(timeVector)));
timeSeries = timeseries(dataValues, timeVector);
simOuts = cell(1, numScenarios);

variables = {'x_ref', 'y_ref', 'z_ref', 'T_selector', ...
             'tau_phi_selector', 'tau_theta_selector', 'tau_psi_selector' ...
             'x_selector', 'y_selector', 'z_selector', ...
             'phi_selector', 'theta_selector', 'psi_selector'};

for i = 1:length(variables)
    eval([variables{i} ' = timeSeries;']);
end

attack_selector = [false, false, false;
                   false, false, false;
                   false, false, false;
                   false, false, false;
                   false, false, false;
                   false, false, false;
                   false, false, false;
                   false, false, false;
                   false, false, false;
                   false, false, false];

for s = 1:numScenarios
    % points
    [x_ref, y_ref, z_ref] = generatePoints(numPointsScenario, setPointDuration, stepValue, x_ref, y_ref, z_ref);
    
    [T_DoS_duration, T_FDI_value, T_Replay_delay, T_selector] = generateSelector(T_selector, 3, attack_selector(1, 1), attack_selector(1, 2), attack_selector(1, 3));
    [tau_phi_DoS_duration, tau_phi_FDI_value, tau_phi_Replay_delay, tau_phi_selector] = generateSelector(tau_phi_selector, 0.001, attack_selector(2, 1), attack_selector(2, 2), attack_selector(2, 3));
    [tau_theta_DoS_duration, tau_theta_FDI_value, tau_theta_Replay_delay, tau_theta_selector] = generateSelector(tau_theta_selector, 0.01, attack_selector(3, 1), attack_selector(3, 2), attack_selector(3, 3));
    [tau_psi_DoS_duration, tau_psi_FDI_value, tau_psi_Replay_delay, tau_psi_selector] = generateSelector(tau_psi_selector, 0.01, attack_selector(4, 1), attack_selector(4, 2), attack_selector(4, 3));

    [x_DoS_duration, x_FDI_value, x_Replay_delay, x_selector] = generateSelector(x_selector, 1, attack_selector(5, 1), attack_selector(5, 2), attack_selector(5, 3));
    [y_DoS_duration, y_FDI_value, y_Replay_delay, y_selector] = generateSelector(y_selector, 1, attack_selector(6, 1), attack_selector(6, 2), attack_selector(6, 3));
    [z_DoS_duration, z_FDI_value, z_Replay_delay, z_selector] = generateSelector(z_selector, 1, attack_selector(7, 1), attack_selector(7, 2), attack_selector(7, 3));
    [phi_DoS_duration, phi_FDI_value, phi_Replay_delay, phi_selector] = generateSelector(phi_selector, 0.001, attack_selector(8, 1), attack_selector(8, 2), attack_selector(8, 3));
    [theta_DoS_duration, theta_FDI_value, theta_Replay_delay, theta_selector] = generateSelector(theta_selector, 0.001, attack_selector(9, 1), attack_selector(9, 2), attack_selector(9, 3));
    [psi_DoS_duration, psi_FDI_value, psi_Replay_delay, psi_selector] = generateSelector(psi_selector, 0.001, attack_selector(10, 1), attack_selector(10, 2), attack_selector(10, 3));

%     % actuator attack
%     [T_DoS_duration, T_FDI_value, T_Replay_delay, T_selector] = generateSelector(T_selector, 3, false, false, false);
%     [tau_phi_DoS_duration, tau_phi_FDI_value, tau_phi_Replay_delay, tau_phi_selector] = generateSelector(tau_phi_selector, 0.001, false, false, false);
%     [tau_theta_DoS_duration, tau_theta_FDI_value, tau_theta_Replay_delay, tau_theta_selector] = generateSelector(tau_theta_selector, 0.01, false, false, false);
%     [tau_psi_DoS_duration, tau_psi_FDI_value, tau_psi_Replay_delay, tau_psi_selector] = generateSelector(tau_psi_selector, 0.01, false, false, false);
% 
%     % signal attack
%     [x_DoS_duration, x_FDI_value, x_Replay_delay, x_selector] = generateSelector(x_selector, 1, false, false, false);
%     [y_DoS_duration, y_FDI_value, y_Replay_delay, y_selector] = generateSelector(y_selector, 1, false, false, false);
%     [z_DoS_duration, z_FDI_value, z_Replay_delay, z_selector] = generateSelector(z_selector, 1, false, false, false);
%     [phi_DoS_duration, phi_FDI_value, phi_Replay_delay, phi_selector] = generateSelector(phi_selector, 0.001, false, false, false);
%     [theta_DoS_duration, theta_FDI_value, theta_Replay_delay, theta_selector] = generateSelector(theta_selector, 0.001, false, false, false);
%     [psi_DoS_duration, psi_FDI_value, psi_Replay_delay, psi_selector] = generateSelector(psi_selector, 0.001, false, false, false);
%     
    % simulation
    simOuts{s} = sim('Gen_nl');
end

function [x_ref, y_ref, z_ref] = generatePoints(numPointsScenario, setPointDuration, stepValue, x_ref, y_ref, z_ref)
    numDimensions = 3;
    points = zeros(numPointsScenario, numDimensions);
    points(1, :) = randi([-5, 5], 1, numDimensions);

    for i = 2:numPointsScenario
        numChanges = randi([1, 3]);  
        dimensionsToChange = randperm(numDimensions, numChanges);  
        newValues = points(i-1, :);  
        for dim = dimensionsToChange
            change = randi([-3, 3]);
            newValues(dim) = newValues(dim) + change;
            if newValues(dim) > 5
                newValues(dim) = 5;
            elseif newValues(dim) < -5
                newValues(dim) = -5;
            end
        end
        points(i, :) = newValues;
    end
        
    for i = 1:numPointsScenario
        startIndex = 1 + (i-1) * setPointDuration / stepValue;
        endIndex = min(length(x_ref.Data), startIndex + setPointDuration / stepValue - 1);
        x_ref.Data(startIndex:endIndex) = points(i, 1);
        y_ref.Data(startIndex:endIndex) = points(i, 2);
        z_ref.Data(startIndex:endIndex) = points(i, 3);
    end
end

function [DoS_duration, FDI_value, Replay_delay, selector] = ...
    generateSelector(selector, FDI_value_range, ...
    apply_DoS, apply_Replay, apply_FDI)
    % DoS
    DoS_start = randi([5, 95]);
    DoS_duration = randi([1, 3]);
    DoS_time = [DoS_start * 10 + 1, (DoS_start + DoS_duration) * 10];

    % FDI
    FDI_start = randi([5, 95]);
    FDI_duration = randi([1, 3]);
    FDI_value = -FDI_value_range + 2 * FDI_value_range * rand();
    FDI_time = [FDI_start * 10 + 1, (FDI_start + FDI_duration) * 10];

    % Replay
    Record_start = randi([5, 45]);
    Replay_start = randi([55, 95]);
    Replay_duration = randi([1, 3]);
    Replay_time = [Replay_start * 10 + 1, (Replay_start + Replay_duration) * 10];
    Replay_delay = (Replay_start - Record_start) * 10;

    % Selector
    selector.Data(:) = 1;
    if apply_DoS
        selector.Data(DoS_time(1): DoS_time(2)) = 2;
    end
    if apply_FDI
        selector.Data(FDI_time(1): FDI_time(2)) = 3;
    end
    if apply_Replay
        selector.Data(Replay_time(1): Replay_time(2)) = 4;
    end
    selector.Data = int32(selector.Data);
end


