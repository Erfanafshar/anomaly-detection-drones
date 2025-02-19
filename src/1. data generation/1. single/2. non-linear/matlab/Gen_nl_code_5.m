clear; clc;

% initialization
g = 9.8;
m = 0.551;
Jx = 0.0019005;
Jy = 0.0019536;
Jz = 0.0036894;

simulationTime = 100; 
stepValue = 0.1;    
numData = simulationTime / stepValue;
numPointsScenario = 10;
setPointDuration = 10; 

numScenario = 50; 

timeVector = 0:stepValue:simulationTime;
dataValues = transpose(zeros(size(timeVector)));
timeSeries = timeseries(dataValues, timeVector);

scenarioCount = 0; 
scenarios = [];

datasetVariableNames = {'time', 'x', 'y', 'z', 'phi', 'theta', 'psi', ...
                        'T', 'tau_phi', 'tau_theta', 'tau_psi', ...
                        'label', 'type', 'target'};

signalOrder = {'x_a', 'y_a', 'z_a', 'phi_a', 'theta_a', 'psi_a', 'T', ...
               'tau_phi', 'tau_theta', 'tau_psi'};

variables = {'x_ref', 'y_ref', 'z_ref', ...
             'x_selector', 'y_selector', 'z_selector', ...
             'phi_selector', 'theta_selector', 'psi_selector', ...
             'T_selector', 'tau_phi_selector', 'tau_theta_selector', ...
             'tau_psi_selector'};
for i = 1:length(variables)
    eval([variables{i} ' = timeSeries;']);
end

% generate data from scenarios 
while scenarioCount < numScenario   
    % Points
    [x_ref, y_ref, z_ref] = generatePoints(numPointsScenario, setPointDuration, stepValue, x_ref, y_ref, z_ref);
    
    % Attack target selection 
    attackTarget = generateAttackTarget();
    
    % Apply attacks
    [x_DoS_duration, x_FDI_value, x_Replay_delay, x_selector] = generateSelector(x_selector, 3, attackTarget(5, 1), attackTarget(5, 2), attackTarget(5, 3));
    [y_DoS_duration, y_FDI_value, y_Replay_delay, y_selector] = generateSelector(y_selector, 3, attackTarget(6, 1), attackTarget(6, 2), attackTarget(6, 3));
    [z_DoS_duration, z_FDI_value, z_Replay_delay, z_selector] = generateSelector(z_selector, 3, attackTarget(7, 1), attackTarget(7, 2), attackTarget(7, 3));
    [phi_DoS_duration, phi_FDI_value, phi_Replay_delay, phi_selector] = generateSelector(phi_selector, 0.01, attackTarget(8, 1), attackTarget(8, 2), attackTarget(8, 3));
    [theta_DoS_duration, theta_FDI_value, theta_Replay_delay, theta_selector] = generateSelector(theta_selector, 0.01, attackTarget(9, 1), attackTarget(9, 2), attackTarget(9, 3));
    [psi_DoS_duration, psi_FDI_value, psi_Replay_delay, psi_selector] = generateSelector(psi_selector, 0.01, attackTarget(10, 1), attackTarget(10, 2), attackTarget(10, 3));

    [T_DoS_duration, T_FDI_value, T_Replay_delay, T_selector] = generateSelector(T_selector, 3, attackTarget(1, 1), attackTarget(1, 2), attackTarget(1, 3));
    [tau_phi_DoS_duration, tau_phi_FDI_value, tau_phi_Replay_delay, tau_phi_selector] = generateSelector(tau_phi_selector, 0.01, attackTarget(2, 1), attackTarget(2, 2), attackTarget(2, 3));
    [tau_theta_DoS_duration, tau_theta_FDI_value, tau_theta_Replay_delay, tau_theta_selector] = generateSelector(tau_theta_selector, 0.01, attackTarget(3, 1), attackTarget(3, 2), attackTarget(3, 3));
    [tau_psi_DoS_duration, tau_psi_FDI_value, tau_psi_Replay_delay, tau_psi_selector] = generateSelector(tau_psi_selector, 0.01, attackTarget(4, 1), attackTarget(4, 2), attackTarget(4, 3));

    % Fix replay attack 
    % Step 1: Replace any value of 4 with 1 in T_selector, tau_phi_selector, tau_theta_selector, tau_psi_selector
    T_selector(T_selector == 4) = 1;
    tau_phi_selector(tau_phi_selector == 4) = 1;
    tau_theta_selector(tau_theta_selector == 4) = 1;
    tau_psi_selector(tau_psi_selector == 4) = 1;

    % Step 2: Loop over time and check the conditions
    for t = 1:length(x_selector) % assuming all selectors are of the same length
        % Check if any of the primary selectors have a value of 4
        if x_selector(t) == 4 || theta_selector(t) == 4
           tau_theta_selector(t) = 3;
        end
        if y_selector(t) == 4 || phi_selector(t) == 4
            tau_phi_selector(t) = 3;
        end
        if z_selector(t) == 4
            T_selector(t) = 3;
        end
        if psi_selector(t) == 4
            tau_psi_selector(t) = 3;
        end
    end

    % Simulation
    try
        simOut = sim('Gen_nl');
    catch ME
%         fprintf('Simulation %d failed with error: %s\n', i, ME.message);
        continue
    end 
    
    % Create attack column
    selector = {x_selector, y_selector, z_selector, ...
                phi_selector, theta_selector, psi_selector, ...
                T_selector, tau_phi_selector, tau_theta_selector, ...
                tau_psi_selector};     
    attackColumn = createAttackColumn(selector, numData);
    
    % Create scenario
    scenario = processData(simOut, attackColumn, signalOrder);
    scenarios = [scenarios; scenario];
    scenarioCount = scenarioCount + 1;
end

% create dataset file 
tableData = array2table(scenarios, 'VariableNames', datasetVariableNames);
writetable(tableData, 'dataset.csv');


% %%%%%%%%%%%%%%%%%%%%%%% functions
% create attack column
function attackColumn = createAttackColumn(selector, numData)
    % Initialize the attackColumn matrix
    attackColumn = zeros(numData, 3);
    
    % Iterate over the data points
    for i = 1:numData
        % Iterate over the selectors
        for j = 1:length(selector)
            sel = selector{j}; 
            if sel.Data(i) ~= 1 
                attackColumn(i, 1) = 1;             
                attackColumn(i, 2) = sel.Data(i) - 1;
                attackColumn(i, 3) = j;             
                break; 
            end
        end
    end
end

% Function to load and process the data
function dataMatrix = processData(data, attack_column, signalOrder)
    % create data matrix with size (1000, 11)
    signals = data.logsout;
    numSignals = numElements(signals);
    numSamples = size(signals{1}.Values.Data, 1) - 1;
    dataMatrix = zeros(numSamples, numSignals + 1);  

    % set column 1 (time)
    dataMatrix(:, 1) = signals{1}.Values.Time(1: end-1);

    % set column 2 -> 11 (features)
    for i = 1:numSignals
        signalName = signals{i}.Name;
        signalIndex = find(strcmp(signalOrder, signalName));
        if ~isempty(signalIndex)
            dataMatrix(:, signalIndex + 1) = signals{i}.Values.Data(1:end-1, :);
        end
    end
   
    % set column 12 -> 14 (labels)
    dataMatrix = [dataMatrix, attack_column];
end

% generate attack targets for each scenario
function attackTarget = generateAttackTarget()
    numTrue = randi([5, 10]); % number of attack target in each scenario
    attackTarget = false(10, 3);
    totalElements = 10 * 3;
    trueIndices = randperm(totalElements, numTrue);
    [rowIndices, colIndices] = ind2sub([10, 3], trueIndices);
    for k = 1:numTrue
        attackTarget(rowIndices(k), colIndices(k)) = true;
    end
end

% generate trajectory points for each scenario 
function [x_ref, y_ref, z_ref] = generatePoints(numPointsScenario, ...
    setPointDuration, stepValue, x_ref, y_ref, z_ref)
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

% generate selector for attacks 
function [DoS_duration, FDI_value, Replay_delay, selector] = ...
    generateSelector(selector, FDI_value_range, ...
    apply_DoS, apply_Replay, apply_FDI)
    % DoS
    DoS_start = randi([5, 95]); % DoS attack start time 
    DoS_duration = randi([1, 3]); % DoS attack duration
    DoS_time = [DoS_start * 10 + 1, (DoS_start + DoS_duration) * 10];

    % FDI
    FDI_start = randi([5, 95]); % FDI attack start time 
    FDI_duration = randi([1, 3]); % FDI attack duration
    FDI_value = -FDI_value_range + 2 * FDI_value_range * rand();
    FDI_time = [FDI_start * 10 + 1, (FDI_start + FDI_duration) * 10];

    % Replay
    Record_start = randi([5, 45]); % Record start time 
    Replay_start = randi([55, 95]); % Replay start time 
    Replay_duration = randi([1, 3]); % Replay attack duration
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
