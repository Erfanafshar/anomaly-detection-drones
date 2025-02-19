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

numScenarios = 50; 
numQuadcopters = 5;

failed = 0;

timeVector = 0:stepValue:simulationTime;
dataValues = transpose(zeros(size(timeVector)));
timeSeries = timeseries(dataValues, timeVector);

% used for final dataset labeling
baseVariables = {'x', 'y', 'z', 'phi', 'theta', 'psi', 'T', ...
    'tau_phi', 'tau_theta', 'tau_psi'};
variableNames = {'time'};
for q = 1:numQuadcopters
    variableNames = [variableNames, strcat(baseVariables, '_', num2str(q))];
end
for q = 1:numQuadcopters
    variableNames = [variableNames, strcat({'label', 'type', 'target'}, '_', num2str(q))];
end

% used to take signals from Simulink in correct order
baseSignal = {'x_a', 'y_a', 'z_a', 'phi_a', 'theta_a', 'psi_a', 'T', ...
    'tau_phi', 'tau_theta', 'tau_psi'};
signalOrder = {};
for q = 1:numQuadcopters
    signalOrder = [signalOrder, strcat(baseSignal, '_', num2str(q))];
end

% list of time_series variable for each quadcopter
baseVariables = {'x_ref', 'y_ref', 'z_ref', ...
                 'x_selector', 'y_selector', 'z_selector', ...
                 'phi_selector', 'theta_selector', 'psi_selector', ...
                 'T_selector', 'tau_phi_selector', 'tau_theta_selector', ...
                 'tau_psi_selector'};
for q = 1:numQuadcopters
    for i = 1:length(baseVariables)
        variableName = [baseVariables{i}, '_', num2str(q)];
        eval([variableName ' = timeSeries;']);
    end
end

% simulation variables
simOuts = cell(1, numScenarios); 
scenarioCount = 0; 
scenarios = [];

% generate data from scenarios 
while scenarioCount < numScenarios   
    % Generate points for each quadcopter
    for i = 1:numQuadcopters
        eval(sprintf('[x_ref_%d, y_ref_%d, z_ref_%d] = generatePoints(numPointsScenario, setPointDuration, stepValue, x_ref_%d, y_ref_%d, z_ref_%d);', ...
            i, i, i, i, i, i));
    end
    
    % Attack target selection 
    attackTargets = generateAttackTargets(numQuadcopters);
    
    
    % Apply attacks
    for i = 1:numQuadcopters
        eval(sprintf('[x_DoS_duration_%d, x_FDI_value_%d, x_Replay_delay_%d, x_selector_%d] = generateSelector(x_selector_%d, 3, attackTargets(5, 1, %d), attackTargets(5, 2, %d), attackTargets(5, 3, %d));', ...
            i, i, i, i, i, i, i, i));
        eval(sprintf('[y_DoS_duration_%d, y_FDI_value_%d, y_Replay_delay_%d, y_selector_%d] = generateSelector(y_selector_%d, 3, attackTargets(6, 1, %d), attackTargets(6, 2, %d), attackTargets(6, 3, %d));', ...
            i, i, i, i, i, i, i, i));   
        eval(sprintf('[z_DoS_duration_%d, z_FDI_value_%d, z_Replay_delay_%d, z_selector_%d] = generateSelector(z_selector_%d, 3, attackTargets(7, 1, %d), attackTargets(7, 2, %d), attackTargets(7, 3, %d));', ...
            i, i, i, i, i, i, i, i));   
        eval(sprintf('[phi_DoS_duration_%d, phi_FDI_value_%d, phi_Replay_delay_%d, phi_selector_%d] = generateSelector(phi_selector_%d, 0.01, attackTargets(8, 1, %d), attackTargets(8, 2, %d), attackTargets(8, 3, %d));', ...
            i, i, i, i, i, i, i, i));   
        eval(sprintf('[theta_DoS_duration_%d, theta_FDI_value_%d, theta_Replay_delay_%d, theta_selector_%d] = generateSelector(theta_selector_%d, 0.01, attackTargets(9, 1, %d), attackTargets(9, 2, %d), attackTargets(9, 3, %d));', ...
            i, i, i, i, i, i, i, i));
        eval(sprintf('[psi_DoS_duration_%d, psi_FDI_value_%d, psi_Replay_delay_%d, psi_selector_%d] = generateSelector(psi_selector_%d, 0.01, attackTargets(10, 1, %d), attackTargets(10, 2, %d), attackTargets(10, 3, %d));', ...
            i, i, i, i, i, i, i, i));  
        eval(sprintf('[T_DoS_duration_%d, T_FDI_value_%d, T_Replay_delay_%d, T_selector_%d] = generateSelector(T_selector_%d, 3, attackTargets(1, 1, %d), attackTargets(1, 2, %d), attackTargets(1, 3, %d));', ...
            i, i, i, i, i, i, i, i));
        eval(sprintf('[tau_phi_DoS_duration_%d, tau_phi_FDI_value_%d, tau_phi_Replay_delay_%d, tau_phi_selector_%d] = generateSelector(tau_phi_selector_%d, 0.01, attackTargets(2, 1, %d), attackTargets(2, 2, %d), attackTargets(2, 3, %d));', ...
            i, i, i, i, i, i, i, i)); 
        eval(sprintf('[tau_theta_DoS_duration_%d, tau_theta_FDI_value_%d, tau_theta_Replay_delay_%d, tau_theta_selector_%d] = generateSelector(tau_theta_selector_%d, 0.01, attackTargets(3, 1, %d), attackTargets(3, 2, %d), attackTargets(3, 3, %d));', ...
            i, i, i, i, i, i, i, i)); 
        eval(sprintf('[tau_psi_DoS_duration_%d, tau_psi_FDI_value_%d, tau_psi_Replay_delay_%d, tau_psi_selector_%d] = generateSelector(tau_psi_selector_%d, 0.01, attackTargets(4, 1, %d), attackTargets(4, 2, %d), attackTargets(4, 3, %d));', ...
            i, i, i, i, i, i, i, i));
    end
    
    % Simulation
    try
        simOut = sim('Gen_net_5');
    catch ME
%         fprintf('Simulation %d failed with error: %s\n', i, ME.message);
        failed = failed + 1;
        continue
    end 


    % Create attack column
    selectors = cell(numQuadcopters, 1);
    for q = 1:numQuadcopters
        selectors{q} = {eval(sprintf('x_selector_%d', q)), eval(sprintf('y_selector_%d', q)), eval(sprintf('z_selector_%d', q)), ...
                        eval(sprintf('phi_selector_%d', q)), eval(sprintf('theta_selector_%d', q)), eval(sprintf('psi_selector_%d', q)), ...
                        eval(sprintf('T_selector_%d', q)), eval(sprintf('tau_phi_selector_%d', q)), eval(sprintf('tau_theta_selector_%d', q)), ...
                        eval(sprintf('tau_psi_selector_%d', q))};
    end
    attackColumn = createAttackColumn(selectors, numData, numQuadcopters);

    % Create scenario
    scenario = processData(simOut, attackColumn, signalOrder);
    scenarios = [scenarios; scenario];
    
    scenarioCount = scenarioCount + 1;
end


% disp(failed);
% disp(failed / (failed + numScenarios) * 100);

% create dataset
tableData = array2table(scenarios, 'VariableNames', variableNames);
writetable(tableData, 'dataset.csv');

% create attack columns label for dataset
function attackColumn = createAttackColumn(selectors, numData, numQuadcopters)
    % Initialize an empty cell array to store the attack columns for each quadcopter
    allAttackColumns = cell(numQuadcopters, 1);
    
    % Iterate over each quadcopter
    for q = 1:numQuadcopters
        % Get the selector for this quadcopter
        selector = selectors{q};
        
        % Initialize attackColumn for this quadcopter, size (numData, 3)
        quadAttackColumn = zeros(numData, 3);
        
        % Iterate over the data points
        for i = 1:numData
            % Iterate over the selectors for this quadcopter
            for j = 1:length(selector)
                sel = selector{j}; 
                if sel.Data(i) ~= 1 
                    quadAttackColumn(i, 1) = 1;              % Mark the attack as active
                    quadAttackColumn(i, 2) = sel.Data(i) - 1; % Save the attack intensity
                    quadAttackColumn(i, 3) = j;              % Save the attack type (which selector)
                    break; % Exit the loop once an attack is found
                end
            end
        end
        
        % Store the attack column for this quadcopter
        allAttackColumns{q} = quadAttackColumn;
    end
    
    % Concatenate all quadcopter attack columns horizontally
    attackColumn = horzcat(allAttackColumns{:});
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

    % set column 2 -> 11 (features) % not valid
    for i = 1:numSignals
        signalName = signals{i}.Name;
        signalIndex = find(strcmp(signalOrder, signalName));
        if ~isempty(signalIndex)
            dataMatrix(:, signalIndex + 1) = signals{i}.Values.Data(1:end-1, :);
        end
    end
   
    % set column 12 -> 14 (labels) % not valid
    dataMatrix = [dataMatrix, attack_column];
end

% geneate matrix that specified targets of attacks 
function attackTargets = generateAttackTargets(numQuadcopters)
    attackTargets = false(10, 3, numQuadcopters);

    % Iterate over each quadcopter
    for q = 1:numQuadcopters
        numTrue = randi([3, 6]); % Number of attack targets in each scenario
        totalElements = 10 * 3;
        trueIndices = randperm(totalElements, numTrue);
        [rowIndices, colIndices] = ind2sub([10, 3], trueIndices);
        for k = 1:numTrue
            attackTargets(rowIndices(k), colIndices(k), q) = true;
        end
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
    DoS_duration = randi([1, 2]); % DoS attack duration
    DoS_time = [DoS_start * 10 + 1, (DoS_start + DoS_duration) * 10];

    % FDI
    FDI_start = randi([5, 95]); % FDI attack start time 
    FDI_duration = randi([1, 2]); % FDI attack duration
    FDI_value = -FDI_value_range + 2 * FDI_value_range * rand();
    FDI_time = [FDI_start * 10 + 1, (FDI_start + FDI_duration) * 10];

    % Replay
    Record_start = randi([5, 45]); % Record start time 
    Replay_start = randi([55, 95]); % Replay start time 
    Replay_duration = randi([1, 2]); % Replay attack duration
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
