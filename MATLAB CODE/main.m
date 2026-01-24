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
degree_of_efficiency_electrolysis = 0.62;
coefficient_of_performance_heat_pump = 4;

% Calculating the power demand profile for the electrolyzer
electrical_power_demand_profile_electrolyzer = thermal_power_demand_profile/(degree_of_efficiency_burner*degree_of_efficiency_electrolysis); % in kW

% Calculating the power demand profile for the heat pump
electrical_power_demand_profile_heat_pump = thermal_power_demand_profile/coefficient_of_performance_heat_pump; % in kW

% Calculating the dynamic electricity consumption for the electrolyzer
electricity_consumption_electrolyzer = electrical_power_demand_profile_electrolyzer/(sampling_frequency*3600); % in kWh

% Calculating the dynamic electricity consumption for the heat pump
electricity_consumption_heat_pump = electrical_power_demand_profile_heat_pump/(sampling_frequency*3600); % in kWh

% Calculating the electricity costs for the electrolyzer
electricity_costs_electrolyzer = electricity_prices.*electricity_consumption_electrolyzer; % in EUR

% Calculating the electricity costs for the heat pump
electricity_costs_heat_pump = electricity_prices.*electricity_consumption_heat_pump; % in EUR

% Calculating the dynamic levelized costs of energy for the electrolyzer
levelized_costs_of_energy_electrolyzer = electricity_costs_electrolyzer./(thermal_power_demand_profile/(sampling_frequency*3600)); % in EUR/kWh

% Calculating the dynamic levelized costs of energy for the heat pump
levelized_costs_of_energy_heat_pump = electricity_costs_heat_pump./(thermal_power_demand_profile/(sampling_frequency*3600)); % in EUR/kWh

% Calculating the electricity-induced greenhouse gas emissions for the electrolyzer
electricity_emissions_electrolyzer = electricity_emission_factors.*electricity_consumption_electrolyzer; % in kg CO2e

% Calculating the electricity-induced greenhouse gas emissions for the heat pump
electricity_emissions_heat_pump = electricity_emission_factors.*electricity_consumption_heat_pump; % in kg CO2e

% Calculating the dynamic levelized emissions of energy for the electrolyzer
levelized_emissions_of_energy_electrolyzer = electricity_emissions_electrolyzer./(thermal_power_demand_profile/(sampling_frequency*3600)); % in kg CO2e / kWh

% Calculating the dynamic levelized emissions of energy for the heat pump
levelized_emissions_of_energy_heat_pump = electricity_emissions_heat_pump./(thermal_power_demand_profile/(sampling_frequency*3600)); % in kg CO2e / kWh

% Specifying the economic benchmark reference
reference_levelized_costs_of_energy = 0.039420626/degree_of_efficiency_burner; % in EUR/kWh

% Specifying the ecological benchmark reference
reference_levelized_emissions_of_energy = 0.252/degree_of_efficiency_burner; % in kg CO2e / kWh

% Finding the indices for the hybrid operation
indices_economic_electrolyzer = find(levelized_costs_of_energy_electrolyzer<reference_levelized_costs_of_energy);
indices_economic_heat_pump = find(levelized_costs_of_energy_heat_pump<reference_levelized_costs_of_energy);
indices_ecological_electrolyzer = find(levelized_emissions_of_energy_electrolyzer<reference_levelized_emissions_of_energy);
indices_ecological_heat_pump = find(levelized_emissions_of_energy_heat_pump<reference_levelized_emissions_of_energy);

% Calculating the economic deviations for the electrolyzer
economic_deviations_electrolyzer = levelized_costs_of_energy_electrolyzer(indices_economic_electrolyzer)-reference_levelized_costs_of_energy; % in EUR/kWh

% Calculating the economic deviations for the heat pump
economic_deviations_heat_pump = levelized_costs_of_energy_heat_pump(indices_economic_heat_pump)-reference_levelized_costs_of_energy; % in EUR/kWh

% Calculating the relative economic undercut rate for the electrolyzer
relative_economic_undercut_rate_electrolyzer = length(indices_economic_electrolyzer)/number_of_data_points*100; % in %

% Calculating the relative economic undercut rate for the heat pump
relative_economic_undercut_rate_heat_pump = length(indices_economic_heat_pump)/number_of_data_points*100; % in %

% Calculating the absolute economic balance for the electrolyzer
absolute_economic_balance_electrolyzer = sum(economic_deviations_electrolyzer.*(thermal_power_demand_profile(indices_economic_electrolyzer)/(sampling_frequency*3600))); % in EUR

% Calculating the absolute economic balance for the heat pump
absolute_economic_balance_heat_pump = sum(economic_deviations_heat_pump.*(thermal_power_demand_profile(indices_economic_heat_pump)/(sampling_frequency*3600))); % in EUR

% Displaying the economic deviations for the electrolyzer
fprintf('Relative economic undercut rate (electrolyzer): %.2f Percent',relative_economic_undercut_rate_electrolyzer);
fprintf('\nAbsolute economic balance (electrolyzer): %.2f €\n',absolute_economic_balance_electrolyzer);

% Displaying the economic deviations for the heat pump
fprintf('\nRelative economic undercut rate (heat pump): %.2f Percent',relative_economic_undercut_rate_heat_pump);
fprintf('\nAbsolute economic balance (heat pump): %.2f €\n',absolute_economic_balance_heat_pump);

% Calculating the ecological deviations for the electrolyzer
ecological_deviations_electrolyzer = levelized_emissions_of_energy_electrolyzer(indices_ecological_electrolyzer)-reference_levelized_emissions_of_energy; % in kg CO2e / kWh

% Calculating the ecological deviations for the heat pump
ecological_deviations_heat_pump = levelized_emissions_of_energy_heat_pump(indices_ecological_heat_pump)-reference_levelized_emissions_of_energy; % in kg CO2e / kWh

% Calculating the relative ecological undercut rate for the electrolyzer
relative_ecological_undercut_rate_electrolyzer = length(indices_ecological_electrolyzer)/number_of_data_points*100; % in %

% Calculating the relative ecological undercut rate for the heat pump
relative_ecological_undercut_rate_heat_pump = length(indices_ecological_heat_pump)/number_of_data_points*100; % in %

% Calculating the absolute ecological balance for the electrolyzer
absolute_ecological_balance_electrolyzer = sum(ecological_deviations_electrolyzer.*(thermal_power_demand_profile(indices_ecological_electrolyzer)/(sampling_frequency*3600))); % in kg CO2e

% Calculating the absolute ecological balance for the heat pump
absolute_ecological_balance_heat_pump = sum(ecological_deviations_heat_pump.*(thermal_power_demand_profile(indices_ecological_heat_pump)/(sampling_frequency*3600))); % in kg CO2e

% Displaying the ecological deviations for the electrolyzer
fprintf('\nRelative ecological undercut rate (electrolyzer): %.2f Percent',relative_ecological_undercut_rate_electrolyzer);
fprintf('\nAbsolute ecological balance (electrolyzer): %.2f kg CO2e\n',absolute_ecological_balance_electrolyzer);

% Displaying the ecological deviations for the heat pump
fprintf('\nRelative ecological undercut rate (heat pump): %.2f Percent',relative_ecological_undercut_rate_heat_pump);
fprintf('\nAbsolute ecological balance (heat pump): %.2f kg CO2e\n',absolute_ecological_balance_heat_pump);

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

% Plotting the electrical power demand profiles of the electrolyzer and the heat pump
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

% Plotting the dynamic levelized costs of energy for the electrolyzer and the heat pump
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

% Plotting the dynamic levelized emissions of energy of the electrolyzer and the heat pump
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