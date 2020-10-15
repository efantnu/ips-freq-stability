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
subplot(1,1,1, ...
    'FontSize', 20, ...
    'FontName', 'OpenSans', ...
    'FontWeight', 'bold',...
    'XGrid', 'on', ...
    'YGrid', 'on');

hold on;
histogram(Load/70,'Normalization','probability');

ylim([0, 0.061]);
ylabel('Probability', 'FontSize', 24, 'FontWeight', 'bold');
xlabel('Power demand [pu]', 'FontSize', 24, 'FontWeight', 'bold');



%% Simulation parameters
Ts = 0.01;
Ttotal = 40;
Tstep = 0.5;

%% Model parameters
% System
Pb = 0.0428;
rss = 0.025;
rtr = 0.1;
x0 = 0;
M = 10.2;
Dmin = Pb / (rss * (1-rtr));

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

ha = subplot(1,1,1, ...
    'FontSize', 20, ...
    'FontName', 'OpenSans', ...
    'FontWeight', 'bold',...
    'XGrid', 'on', ...
    'YGrid', 'on');

plot(Calc.D{1}.Values, ...
        'Color','k', ...
        'LineStyle','--', ...
        'LineWidth',2, ....
        'DisplayName','Steady-state limit');

for k=1:numElements(Calc.D)
    plot(Sim.D{k}.Values,...
        'LineStyle','-', ...
        'LineWidth',2, ....
        'DisplayName',sprintf('%s', Sim.D{k}.Name));
end

legend('Location', 'southeast');
ylim([0, 0.037]);
ylabel('Absolute frequency dev.  [pu]', 'FontSize', 24, 'FontWeight', 'bold');
xlabel('Time [s]', 'FontSize', 24, 'FontWeight', 'bold');
ha.XAxis.TickValues(1) = '';



%% D sweep with rtr = rss
rtr = rss;
Dmin = Pb / (rss * (1-rtr));
Sim.Drss = Simulink.SimulationData.Dataset;
Calc.Drss = Simulink.SimulationData.Dataset;
for D = Dmin*0.7:Dmin*0.1:Dmin*1.3
    sim('avg_model');
    elem = Simulink.SimulationData.Signal;
    elem.Name = sprintf('D=%.2f', D);
    elem.Values = yout{1}.Values;
    Sim.Drss = addElement(Sim.Drss,elem);
    elem.Values = yout{2}.Values;
    Calc.Drss = addElement(Calc.Drss,elem);
end


%% Plot D sweep with rtr = rss
figID = figID + 1;
fig(figID) = figure('NumberTitle', 'off',...
    'Units', 'centimeters', ...
    'InnerPosition', [0 0 32 20.5], ...
    'Color','w');
fig(figID).OuterPosition = fig(figID).InnerPosition;

hold on;

ha = subplot(1,1,1, ...
    'FontSize', 20, ...
    'FontName', 'OpenSans', ...
    'FontWeight', 'bold',...
    'XGrid', 'on', ...
    'YGrid', 'on');

plot(Calc.Drss{1}.Values, ...
        'Color','k', ...
        'LineStyle','--', ...
        'LineWidth',2, ....
        'DisplayName','Steady-state limit');

for k=1:numElements(Calc.Drss)
    plot(Sim.Drss{k}.Values,...
        'LineStyle','-', ...
        'LineWidth',2, ....
        'DisplayName',sprintf('%s', Sim.Drss{k}.Name));
end

legend('Location', 'southeast');
ylim([0, 0.037]);
xlabel('Time [s]', 'FontSize', 24, 'FontWeight', 'bold');
ha.XAxis.TickValues(1) = '';
set(ha, 'YTickLabel','');



%% Pb sweep 
D = 2.0;
Dmin = D;
rtr = 0.1;
Pb =  D * (rss * (1-rtr));
Sim.Pb = Simulink.SimulationData.Dataset;
Calc.Pb = Simulink.SimulationData.Dataset;

for Pb = Pb*0.7:Pb*0.1:Pb*1.3
    sim('avg_model');
    elem = Simulink.SimulationData.Signal;
    elem.Name = sprintf('Pb=%.3f', Pb);
    elem.Values = yout{1}.Values;
    Sim.Pb = addElement(Sim.Pb,elem);
    elem.Values = yout{2}.Values;
    Calc.Pb = addElement(Calc.Pb,elem);
end

%% Plot b sweep

figID = figID + 1;
fig(figID) = figure('NumberTitle', 'off',...
    'Units', 'centimeters', ...
    'InnerPosition', [0 0 32 21.5], ...
    'Color','w');
fig(figID).OuterPosition = fig(figID).InnerPosition;


ha = subplot(1,1,1, ...
    'FontSize', 20, ...
    'FontName', 'OpenSans', ...
    'FontWeight', 'bold',...
    'XGrid', 'on', ...
    'YGrid', 'on');

hold on;

for k=1:numElements(Calc.Pb)
    pl = plot(Sim.Pb{k}.Values,...
        'LineStyle','-', ...
        'LineWidth',2, ....
        'DisplayName',sprintf('%s', Sim.Pb{k}.Name));

    plot(Calc.Pb{k}.Values,...
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
ylabel('Absolute frequency dev.  [pu]', 'FontSize', 24, 'FontWeight', 'bold');
xlabel('Time [s]', 'FontSize', 24, 'FontWeight', 'bold');
ha.XAxis.TickValues(1) = '';


%% b sweep with rtr = rss
rtr = rss;
Pb =  D * (rss * (1-rtr));
Sim.Pbrss = Simulink.SimulationData.Dataset;
Calc.Pbrss = Simulink.SimulationData.Dataset;

for Pb = Pb*0.7:Pb*0.1:Pb*1.3
    sim('avg_model');
    elem = Simulink.SimulationData.Signal;
    elem.Name = sprintf('Pb=%.3f', Pb);
    elem.Values = yout{1}.Values;
    Sim.Pbrss = addElement(Sim.Pbrss,elem);
    elem.Values = yout{2}.Values;
    Calc.Pbrss = addElement(Calc.Pbrss,elem);
end

%% Plot b sweep with rtr = rss

figID = figID + 1;
fig(figID) = figure('NumberTitle', 'off',...
    'Units', 'centimeters', ...
    'InnerPosition', [0 0 32 21.5], ...
    'Color','w');
fig(figID).OuterPosition = fig(figID).InnerPosition;


ha = subplot(1,1,1, ...
    'FontSize', 20, ...
    'FontName', 'OpenSans', ...
    'FontWeight', 'bold',...
    'XGrid', 'on', ...
    'YGrid', 'on');

hold on;

for k=1:numElements(Calc.Pbrss)
    pl = plot(Sim.Pbrss{k}.Values,...
        'LineStyle','-', ...
        'LineWidth',2, ....
        'DisplayName',sprintf('%s', Sim.Pbrss{k}.Name));

    plot(Calc.Pbrss{k}.Values,...
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
xlabel('Time [s]', 'FontSize', 24, 'FontWeight', 'bold');
ha.XAxis.TickValues(1) = '';
set(ha, 'YTickLabel','');

%% Tgt sweep With turbine governor

% System
Pb = 0.0428;
rss = 0.025;
rtr = 0.1;
x0 = 0;
M = 10.2;

Dmin = Pb / (rss * (1-rtr));

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


ha = subplot(1,1,1, ...
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
ylabel('Absolute frequency dev.  [pu]', 'FontSize', 24, 'FontWeight', 'bold');
xlabel('Time [s]', 'FontSize', 24, 'FontWeight', 'bold');
ha.XAxis.TickValues(1) = '';


%% Influence of M and Tgt 

% System
Pb = 0.0428;
rss = 0.025;
rtr = 0.1;
x0 = 0;
M = 10.2;

Dmin = Pb / (rss * (1-rtr));

% Turbine governor
Dtg1 = Dmin/2;
Ttg1 = 0.1;
Tgt1 = 2.7;

Dtg2 = Dtg1;
Ttg2 = Ttg1;
Tgt2 = Tgt1;


Sim.MTgt = Simulink.SimulationData.Dataset;
Calc.MTgt = Simulink.SimulationData.Dataset;

for M = M:-M*0.2:M*0.4
    sim('avg_model_gov');
    elem = Simulink.SimulationData.Signal;
    elem.Name = sprintf('M=%.1f', M);
    elem.Values = yout{1}.Values;
    Sim.MTgt = addElement(Sim.MTgt,elem);
    elem.Values = yout{2}.Values;
    Calc.MTgt = addElement(Calc.MTgt,elem);
end

Tgt1 = 0.1;
Tgt2 = 2.7;
M = 10.2;

Sim.MTgt2 = Simulink.SimulationData.Dataset;
Calc.MTgt2 = Simulink.SimulationData.Dataset;


for M = M:-M*0.2:M*0.4
    sim('avg_model_gov');
    elem = Simulink.SimulationData.Signal;
    elem.Name = sprintf('M=%.1f', M);
    elem.Values = yout{1}.Values;
    Sim.MTgt2 = addElement(Sim.MTgt2,elem);
    elem.Values = yout{2}.Values;
    Calc.MTgt2 = addElement(Calc.MTgt2,elem);
end

Tgt1 = 0.1;
Tgt2 = Tgt1;
M = 10.2;

Sim.MTgt3 = Simulink.SimulationData.Dataset;
Calc.MTgt3 = Simulink.SimulationData.Dataset;


for M = M:-M*0.2:M*0.4
    sim('avg_model_gov');
    elem = Simulink.SimulationData.Signal;
    elem.Name = sprintf('M=%.1f', M);
    elem.Values = yout{1}.Values;
    Sim.MTgt3 = addElement(Sim.MTgt3,elem);
    elem.Values = yout{2}.Values;
    Calc.MTgt3 = addElement(Calc.MTgt3,elem);
end



%% Plot Influence of M and Tgt 

figID = figID + 1;
fig(figID) = figure('NumberTitle', 'off',...
    'Units', 'centimeters', ...
    'InnerPosition', [0 0 22 17.6], ...
    'Color','w');
fig(figID).OuterPosition = fig(figID).InnerPosition;

ha = subplot(1,1,1, ...
    'FontSize', 20, ...
    'FontName', 'OpenSans', ...
    'FontWeight', 'bold',...
    'XGrid', 'on', ...
    'YGrid', 'on');

hold on;

plot(Calc.MTgt{1}.Values, ...
        'Color','k', ...
        'LineStyle','--', ...
        'LineWidth',2, ....
        'DisplayName','Steady-state limit');

for k=1:numElements(Calc.MTgt)
    pl = plot(Sim.MTgt{k}.Values,...
        'LineStyle','-', ...
        'LineWidth',2, ....
        'DisplayName',sprintf('%s', Sim.MTgt{k}.Name));
end

legend('Location', 'southeast');
ylim([0, 0.0351]);
ylabel('Absolute frequency dev.  [pu]', 'FontSize', 24, 'FontWeight', 'bold');
xlabel('Time [s]', 'FontSize', 24, 'FontWeight', 'bold');
ha.XAxis.TickValues(1) = '';


figID = figID + 1;
fig(figID) = figure('NumberTitle', 'off',...
    'Units', 'centimeters', ...
    'InnerPosition', [0 0 22 17.6], ...
    'Color','w');
fig(figID).OuterPosition = fig(figID).InnerPosition;

ha = subplot(1,1,1, ...
    'FontSize', 20, ...
    'FontName', 'OpenSans', ...
    'FontWeight', 'bold',...
    'XGrid', 'on', ...
    'YGrid', 'on');

hold on;

plot(Calc.MTgt2{1}.Values, ...
        'Color','k', ...
        'LineStyle','--', ...
        'LineWidth',2, ....
        'DisplayName','Steady-state limit');

for k=1:numElements(Calc.MTgt2)
    pl = plot(Sim.MTgt2{k}.Values,...
        'LineStyle','-', ...
        'LineWidth',2, ....
        'DisplayName',sprintf('%s', Sim.MTgt2{k}.Name));
end

legend('Location', 'southeast');
ylim([0, 0.0351]);
xlabel('Time [s]', 'FontSize', 24, 'FontWeight', 'bold');
ha.XAxis.TickValues(1) = '';
set(ha, 'YTickLabel','');


figID = figID + 1;
fig(figID) = figure('NumberTitle', 'off',...
    'Units', 'centimeters', ...
    'InnerPosition', [0 0 22 17.6], ...
    'Color','w');
fig(figID).OuterPosition = fig(figID).InnerPosition;

ha = subplot(1,1,1, ...
    'FontSize', 20, ...
    'FontName', 'OpenSans', ...
    'FontWeight', 'bold',...
    'XGrid', 'on', ...
    'YGrid', 'on');

hold on;

plot(Calc.MTgt3{1}.Values, ...
        'Color','k', ...
        'LineStyle','--', ...
        'LineWidth',2, ....
        'DisplayName','Steady-state limit');

for k=1:numElements(Calc.MTgt3)
    pl = plot(Sim.MTgt3{k}.Values,...
        'LineStyle','-', ...
        'LineWidth',2, ....
        'DisplayName',sprintf('%s', Sim.MTgt3{k}.Name));
end

legend('Location', 'southeast');
ylim([0, 0.0351]);
xlabel('Time [s]', 'FontSize', 24, 'FontWeight', 'bold');
ha.XAxis.TickValues(1) = '';
set(ha, 'YTickLabel','');

