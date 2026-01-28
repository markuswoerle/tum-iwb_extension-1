% Technical University of Munich (TUM)
% TUM School of Engineering and Design
% Institute for Machine Tools and Industrial Management (iwb)
% Markus Woerle, M.Sc.

% Closing all figures, clearing all variables, and clearing the command window
close all;
clear variables;
clc;

% Loading the thermal demand profile
thermal_power_demand_profile = readmatrix('thermal_demand_profile.csv');

% Loading the electricity prices
electricity_prices = readmatrix('electricity_prices.csv');

% Loading the electrical emission factors
electricity_emission_factors = readmatrix('electricity_emission_factors_forecasted.csv');
%electricity_emission_factors = readmatrix('electricity_emission_factors_actual.csv');

% Specifying the required user input data
resolution = 60; % in min

% Calculating the sampling frequency of the thermal demand profile
sampling_frequency = 1/(resolution*60); % in Hz

% Determining the number of data points in the thermal demand profile
number_of_data_points = length(thermal_power_demand_profile);

% Specifying relevant technology parameters
degree_of_efficiency_burner = 0.95;
degree_of_efficiency_electrolyzer = 0.62;
coefficient_of_performance_heat_pump = 4;

% Calculating the power demand profiles
electrical_power_demand_profile_electrolyzer = thermal_power_demand_profile/(degree_of_efficiency_burner*degree_of_efficiency_electrolyzer); % in kW
electrical_power_demand_profile_heat_pump = thermal_power_demand_profile/coefficient_of_performance_heat_pump; % in kW

% Calculating the dynamic levelized costs of energy
levelized_costs_of_energy_electrolyzer = electricity_prices./(degree_of_efficiency_burner*degree_of_efficiency_electrolyzer); % in EUR/kWh
levelized_costs_of_energy_heat_pump = electricity_prices./(coefficient_of_performance_heat_pump); % in EUR/kWh

% Calculating the dynamic levelized emissions of energy
levelized_emissions_of_energy_electrolyzer = electricity_emission_factors./(degree_of_efficiency_burner*degree_of_efficiency_electrolyzer); % in kg CO2e / kWh
levelized_emissions_of_energy_heat_pump = electricity_emission_factors./(coefficient_of_performance_heat_pump); % in kg CO2e / kWh

% Specifying the economic benchmark reference
reference_levelized_costs_of_energy = 0.039420626/degree_of_efficiency_burner; % in EUR/kWh

% Specifying the ecological benchmark reference
reference_levelized_emissions_of_energy = 0.252/degree_of_efficiency_burner; % in kg CO2e / kWh

% Finding the indices for the hybrid operation
indices_economic_electrolyzer = find(levelized_costs_of_energy_electrolyzer<reference_levelized_costs_of_energy);
indices_economic_heat_pump = find(levelized_costs_of_energy_heat_pump<reference_levelized_costs_of_energy);
indices_ecological_electrolyzer = find(levelized_emissions_of_energy_electrolyzer<reference_levelized_emissions_of_energy);
indices_ecological_heat_pump = find(levelized_emissions_of_energy_heat_pump<reference_levelized_emissions_of_energy);

% Calculating the economic deviations
economic_deviations_electrolyzer = levelized_costs_of_energy_electrolyzer(indices_economic_electrolyzer)-reference_levelized_costs_of_energy; % in EUR/kWh
economic_deviations_heat_pump = levelized_costs_of_energy_heat_pump(indices_economic_heat_pump)-reference_levelized_costs_of_energy; % in EUR/kWh

% Calculating the economic balances
economic_balance_electrolyzer = sum(economic_deviations_electrolyzer.*(thermal_power_demand_profile(indices_economic_electrolyzer)/(sampling_frequency*3600))); % in EUR
economic_balance_heat_pump = sum(economic_deviations_heat_pump.*(thermal_power_demand_profile(indices_economic_heat_pump)/(sampling_frequency*3600))); % in EUR

% Displaying the economic balances
fprintf('Economic balance (electrolyzer): %.2f €\n',economic_balance_electrolyzer);
fprintf('Economic balance (heat pump): %.2f €\n',economic_balance_heat_pump);

% Calculating the ecological deviations
ecological_deviations_electrolyzer = levelized_emissions_of_energy_electrolyzer(indices_ecological_electrolyzer)-reference_levelized_emissions_of_energy; % in kg CO2e / kWh
ecological_deviations_heat_pump = levelized_emissions_of_energy_heat_pump(indices_ecological_heat_pump)-reference_levelized_emissions_of_energy; % in kg CO2e / kWh

% Calculating the ecological balances
ecological_balance_electrolyzer = sum(ecological_deviations_electrolyzer.*(thermal_power_demand_profile(indices_ecological_electrolyzer)/(sampling_frequency*3600))); % in kg CO2e
ecological_balance_heat_pump = sum(ecological_deviations_heat_pump.*(thermal_power_demand_profile(indices_ecological_heat_pump)/(sampling_frequency*3600))); % in kg CO2e

% Displaying the ecological balances
fprintf('\nEcological balance (electrolyzer): %.2f kg CO2e\n',ecological_balance_electrolyzer);
fprintf('Ecological balance (heat pump): %.2f kg CO2e\n',ecological_balance_heat_pump);

% Plotting the thermal power demand profile
figure;
stairs(0:24,[thermal_power_demand_profile(:);thermal_power_demand_profile(end)],'LineWidth',2,'Color',[0 101 189]/255);
grid on;
xlim([0 24]);
xticks(0:4:24)
ylim([0 1000]);
yticks(0:200:1000);
xlabel('Time / h \rightarrow');
ylabel('Thermal power demand / kW \rightarrow');
title('Thermal power demand profile');

% Plotting the electrical power demand profiles
figure;
power_electrolyzer = stairs(0:24,[electrical_power_demand_profile_electrolyzer(:);electrical_power_demand_profile_electrolyzer(end)],'LineWidth',2,'Color',[0 101 189]/255);
hold on;
power_heat_pump = stairs(0:24,[electrical_power_demand_profile_heat_pump(:);electrical_power_demand_profile_heat_pump(end)],'LineWidth',2,'Color',[247 129 30]/255);
hold off;
grid on;
xlim([0 24]);
xticks(0:4:24)
ylim([0 1000]);
yticks(0:200:1000);
xlabel('Time / h \rightarrow');
ylabel('Electrical power demand / kW \rightarrow');
title('Electrical power demand of the electrolyzer and the heat pump');
legend([power_electrolyzer power_heat_pump],{'Electrolyzer','Heat pump'},'Location','northwest','NumColumns',2);

% Plotting the dynamic levelized costs of energy
figure;
dlcoe_electrolyzer = stairs(0:24,[levelized_costs_of_energy_electrolyzer(:);levelized_costs_of_energy_electrolyzer(end)],'LineWidth',2,'Color',[0 101 189]/255);
hold on;
dlcoe_heat_pump = stairs(0:24,[levelized_costs_of_energy_heat_pump(:);levelized_costs_of_energy_heat_pump(end)],'LineWidth',2,'Color',[247 129 30]/255);
dlcoe_benchmark = yline(reference_levelized_costs_of_energy,'LineStyle','--','LineWidth',2,'Color',[162 173 0]/255);
hold off
grid on;
xlim([0 24]);
xticks(0:4:24)
ylim([0 0.4]);
yticks(0:0.1:0.4);
xlabel('Time / h \rightarrow');
ylabel('Levelized costs / (€/kWh) \rightarrow');
title('Levelized costs of energy for the electrolyzer and the heat pump');
legend([dlcoe_electrolyzer dlcoe_heat_pump dlcoe_benchmark],{'Electrolyzer','Heat pump', 'Benchmark'},'Location','northwest','NumColumns',3);

% Plotting the dynamic levelized emissions of energy
figure;
dleoe_electrolyzer = stairs(0:24,[levelized_emissions_of_energy_electrolyzer(:);levelized_emissions_of_energy_electrolyzer(end)],'LineWidth',2,'Color',[0 101 189]/255);
hold on;
dleoe_heat_pump = stairs(0:24,[levelized_emissions_of_energy_heat_pump(:);levelized_emissions_of_energy_heat_pump(end)],'LineWidth',2,'Color',[247 129 30]/255);
dleoe_benchmark = yline(reference_levelized_emissions_of_energy,'LineStyle','--','LineWidth',2,'Color',[162 173 0]/255);
hold off
grid on;
xlim([0 24]);
xticks(0:4:24)
ylim([0 1.5]);
yticks(0:0.3:1.5);
xlabel('Time / h \rightarrow');
ylabel('Levelized emissions / (kg CO_2e / kWh) \rightarrow');
title('Levelized emissions of energy for the electrolyzer and the heat pump');
legend([dleoe_electrolyzer dleoe_heat_pump dleoe_benchmark],{'Electrolyzer','Heat pump', 'Benchmark'},'Location','northwest','NumColumns',3);