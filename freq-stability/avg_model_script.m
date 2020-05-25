clear
figID = 0;

%% Load analysis
loadStep = 0.1; % Step between bins 
loadProb = 0.999; % Probability of the variation
Sb = 70; % Base power

% Load SCADA data
load('LoadSec.mat');  
Loadpu = Load/Sb;

% Remove outliers
LoadpuFilt = Loadpu(Loadpu >= 0.6);

% Fit data with normal distribution
[mupu,sigmapu,muCIpu,sigmaCIpu] = normfit(LoadpuFilt,100*(1-loadProb)); 

% Find the maximum load variation
loadVarpu = norminv(loadProb,mupu,sigmapu) - norminv(1-loadProb,mupu,sigmapu); 


%% Plot histogram
figID = 1;
fig(figID) = figure('NumberTitle', 'off',...
    'Units', 'centimeters', ...
    'InnerPosition', [0 0 32 15], ...
    'Color','w');
fig(figID).OuterPosition = fig(figID).InnerPosition;

i = 1;
sp(i) = subplot(1,1,1, ...
    'FontSize', 20, ...
    'FontName', 'OpenSans', ...
    'FontWeight', 'bold',...
    'XGrid', 'on', ...
    'YGrid', 'on');

hold on;
histogram(Load/70,'Normalization','probability');

ylim([0, 0.061]);
ylabel(sp(i), 'Probability', 'FontSize', 24, 'FontWeight', 'bold');
xlabel(sp(i), 'Power demand [pu]', 'FontSize', 24, 'FontWeight', 'bold');



%% Simulation parameters
Ts = 0.01;
Ttotal = 40;
Tstep = 0.5;

%% Model parameters
% System
b = 0.0428;
rss = 0.025;
rtr = 0.1;
x0 = 0;
M = 10.2;
Dmin = b / (rss * (1-rtr));

% Turbine governor
Dtg = Dmin;
Tms = 50e-3;
Tgt = 2.7;

%% D sweep
Sim.D = Simulink.SimulationData.Dataset;
Calc.D = Simulink.SimulationData.Dataset;
for D = Dmin*0.7:Dmin*0.1:Dmin*1.3
    sim('avg_model');
    elem = Simulink.SimulationData.Signal;
    elem.Name = sprintf('D=%.2f', D);
    elem.Values = yout{1}.Values;
    Sim.D = addElement(Sim.D,elem);
    elem.Values = yout{2}.Values;
    Calc.D = addElement(Calc.D,elem);
end


%% Plot D sweep
figID = figID + 1;
fig(figID) = figure('NumberTitle', 'off',...
    'Units', 'centimeters', ...
    'InnerPosition', [0 0 32 20.5], ...
    'Color','w');
fig(figID).OuterPosition = fig(figID).InnerPosition;

hold on;
plot(Calc.D{1}.Values, ...
        'Color','k', ...
        'LineStyle','--', ...
        'LineWidth',2, ....
        'DisplayName','Steady-state limit');

subplot(1,1,1, ...
    'FontSize', 20, ...
    'FontName', 'OpenSans', ...
    'FontWeight', 'bold',...
    'XGrid', 'on', ...
    'YGrid', 'on');


for k=1:numElements(Calc.D)
    plot(Sim.D{k}.Values,...
        'LineStyle','-', ...
        'LineWidth',2, ....
        'DisplayName',sprintf('%s', Sim.D{k}.Name));
end

legend('Location', 'southeast');
ylim([0, 0.036]);
ylabel('Frequency deviation [pu]', 'FontSize', 24, 'FontWeight', 'bold');
xlabel('Time [s]', 'FontSize', 24, 'FontWeight', 'bold');



%% D sweep with rtr = rss
rtr = rss;
Dmin = b / (rss * (1-rtr));
Sim.D = Simulink.SimulationData.Dataset;
Calc.D = Simulink.SimulationData.Dataset;
for D = Dmin*0.7:Dmin*0.1:Dmin*1.3
    sim('avg_model');
    elem = Simulink.SimulationData.Signal;
    elem.Name = sprintf('D=%.2f', D);
    elem.Values = yout{1}.Values;
    Sim.D = addElement(Sim.D,elem);
    elem.Values = yout{2}.Values;
    Calc.D = addElement(Calc.D,elem);
end


%% Plot D sweep with rtr = rss
figID = figID + 1;
fig(figID) = figure('NumberTitle', 'off',...
    'Units', 'centimeters', ...
    'InnerPosition', [0 0 32 20.5], ...
    'Color','w');
fig(figID).OuterPosition = fig(figID).InnerPosition;

hold on;
plot(Calc.D{1}.Values, ...
        'Color','k', ...
        'LineStyle','--', ...
        'LineWidth',2, ....
        'DisplayName','Steady-state limit');

subplot(1,1,1, ...
    'FontSize', 20, ...
    'FontName', 'OpenSans', ...
    'FontWeight', 'bold',...
    'XGrid', 'on', ...
    'YGrid', 'on');


for k=1:numElements(Calc.D)
    plot(Sim.D{k}.Values,...
        'LineStyle','-', ...
        'LineWidth',2, ....
        'DisplayName',sprintf('%s', Sim.D{k}.Name));
end

legend('Location', 'southeast');
ylim([0, 0.036]);
ylabel('Frequency deviation [pu]', 'FontSize', 24, 'FontWeight', 'bold');
xlabel('Time [s]', 'FontSize', 24, 'FontWeight', 'bold');


%% b sweep 
D = 2.0;
rtr = 0.1;
b =  D * (rss * (1-rtr));
Sim.b = Simulink.SimulationData.Dataset;
Calc.b = Simulink.SimulationData.Dataset;

for b = b*0.7:b*0.1:b*1.3
    sim('avg_model');
    elem = Simulink.SimulationData.Signal;
    elem.Name = sprintf('b=%.3f', b);
    elem.Values = yout{1}.Values;
    Sim.b = addElement(Sim.b,elem);
    elem.Values = yout{2}.Values;
    Calc.b = addElement(Calc.b,elem);
end

%% Plot b sweep

figID = figID + 1;
fig(figID) = figure('NumberTitle', 'off',...
    'Units', 'centimeters', ...
    'InnerPosition', [0 0 32 21.5], ...
    'Color','w');
fig(figID).OuterPosition = fig(figID).InnerPosition;


subplot(1,1,1, ...
    'FontSize', 20, ...
    'FontName', 'OpenSans', ...
    'FontWeight', 'bold',...
    'XGrid', 'on', ...
    'YGrid', 'on');

hold on;

for k=1:numElements(Calc.b)
    pl = plot(Sim.b{k}.Values,...
        'LineStyle','-', ...
        'LineWidth',2, ....
        'DisplayName',sprintf('%s', Sim.b{k}.Name));

    plot(Calc.b{k}.Values,...
        'Color', pl.Color,...
        'LineStyle','--', ...
        'LineWidth',2, ....
        'DisplayName','');
end

% Dummy plot to fix the legend
plot(0,0,...
    'Color', 'w',...
    'LineStyle','--', ...
    'LineWidth',2, ....
    'DisplayName','');

lgd = legend('Location', 'southeast');
lgd.NumColumns = 2;
ylim([0, 0.033]);
ylabel('Frequency deviation [pu]', 'FontSize', 24, 'FontWeight', 'bold');
xlabel('Time [s]', 'FontSize', 24, 'FontWeight', 'bold');

%% b sweep with rtr = rss
rtr = rss;
b =  D * (rss * (1-rtr));
Sim.b = Simulink.SimulationData.Dataset;
Calc.b = Simulink.SimulationData.Dataset;

for b = b*0.7:b*0.1:b*1.3
    sim('avg_model');
    elem = Simulink.SimulationData.Signal;
    elem.Name = sprintf('b=%.3f', b);
    elem.Values = yout{1}.Values;
    Sim.b = addElement(Sim.b,elem);
    elem.Values = yout{2}.Values;
    Calc.b = addElement(Calc.b,elem);
end

%% Plot b sweep with rtr = rss

figID = figID + 1;
fig(figID) = figure('NumberTitle', 'off',...
    'Units', 'centimeters', ...
    'InnerPosition', [0 0 32 21.5], ...
    'Color','w');
fig(figID).OuterPosition = fig(figID).InnerPosition;


subplot(1,1,1, ...
    'FontSize', 20, ...
    'FontName', 'OpenSans', ...
    'FontWeight', 'bold',...
    'XGrid', 'on', ...
    'YGrid', 'on');

hold on;

for k=1:numElements(Calc.b)
    pl = plot(Sim.b{k}.Values,...
        'LineStyle','-', ...
        'LineWidth',2, ....
        'DisplayName',sprintf('%s', Sim.b{k}.Name));

    plot(Calc.b{k}.Values,...
        'Color', pl.Color,...
        'LineStyle','--', ...
        'LineWidth',2, ....
        'DisplayName','');
end

% Dummy plot to fix the legend
plot(0,0,...
    'Color', 'w',...
    'LineStyle','--', ...
    'LineWidth',2, ....
    'DisplayName','');

lgd = legend('Location', 'southeast');
lgd.NumColumns = 2;
ylim([0, 0.033]);
ylabel('Frequency deviation [pu]', 'FontSize', 24, 'FontWeight', 'bold');
xlabel('Time [s]', 'FontSize', 24, 'FontWeight', 'bold');

%% Tgt sweep With turbine governor

% System
b = 0.0428;
rss = 0.025;
rtr = 0.1;
x0 = 0;
M = 10.2;

Dmin = b / (rss * (1-rtr));

% Turbine governor
Dtg1 = Dmin/2;
Ttg1 = 0.1;
Tgt1 = 2.7;

Dtg2 = Dtg1;
Ttg2 = Ttg1;
Tgt2 = 1.2*Tgt1;


Sim.Tgt = Simulink.SimulationData.Dataset;
Calc.Tgt = Simulink.SimulationData.Dataset;

for Tgt1 = Tgt1:Tgt1*0.2:Tgt1*2
    Tgt2 = 1.2*Tgt1;
    sim('avg_model_gov');
    elem = Simulink.SimulationData.Signal;
    elem.Name = sprintf('T_{gt1}=%.1f / T_{gt2}=%.1f', Tgt1, Tgt2);
    elem.Values = yout{1}.Values;
    Sim.Tgt = addElement(Sim.Tgt,elem);
    elem.Values = yout{2}.Values;
    Calc.Tgt = addElement(Calc.Tgt,elem);
end

%% Plot Tgt sweep with turbine governor

figID = figID + 1;
fig(figID) = figure('NumberTitle', 'off',...
    'Units', 'centimeters', ...
    'InnerPosition', [0 0 32 17.6], ...
    'Color','w');
fig(figID).OuterPosition = fig(figID).InnerPosition;


subplot(1,1,1, ...
    'FontSize', 20, ...
    'FontName', 'OpenSans', ...
    'FontWeight', 'bold',...
    'XGrid', 'on', ...
    'YGrid', 'on');

hold on;

plot(Calc.Tgt{1}.Values, ...
        'Color','k', ...
        'LineStyle','--', ...
        'LineWidth',2, ....
        'DisplayName','Steady-state limit');

for k=1:numElements(Calc.Tgt)
    pl = plot(Sim.Tgt{k}.Values,...
        'LineStyle','-', ...
        'LineWidth',2, ....
        'DisplayName',sprintf('%s', Sim.Tgt{k}.Name));
end

legend('Location', 'southeast');
ylim([0, 0.0311]);
ylabel('Frequency deviation [pu]', 'FontSize', 24, 'FontWeight', 'bold');
xlabel('Time [s]', 'FontSize', 24, 'FontWeight', 'bold');

