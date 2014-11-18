clc;
fprintf('================================[ comparecirc.m ]================================\n\n');
fprintf('This file compares the Fast Nearfield Method to the Rayleigh-Sommerfeld Integral\n');
fprintf('in the calculation of the pressure profile of a circular transducer. In particular,\n');
fprintf('it compares the execution time of each function for a given number of abscissas\n');
fprintf('and it compares the number of abscissas each technique requires in order to\n');
fprintf('achieve a given error.\n\n');

% Check for required variables and run the required scripts
if(~exist('timevectorFNMcirc','var') || ~exist('errorvectorFNMcirc','var'))
    warning('FNMcirc.m has not been run. Running it now to generate required data.');
    FNMcirc;
end

if(~exist('timevectorRayleighcirc','var') || ~exist('errorvectorRayleighcirc','var'))
    warning('Rayleighcirc.m has not been run. Running it now to generate required data.');
    Rayleighcirc;
end

% plot the times
figure(1)
plot(1:length(timevectorFNMcirc), timevectorFNMcirc, ...
	(1:length(timevectorRayleighcirc)), timevectorRayleighcirc)
ylabel('time (s)')
xlabel('number of abscissas')
legend('FNM circ', 'Rayleigh circ')
%fix_axis(gca, 2)
grid

% plot the errors
figure(2)
semilogy(1:length(errorvectorFNMcirc), errorvectorFNMcirc, ...
	(1:length(errorvectorRayleighcirc)), errorvectorRayleighcirc)
xlabel('number of abscissas')
ylabel('normalized error')
legend('FNM circ', 'Rayleigh circ')
%fix_axis(gca, 2)
grid

% plot the errors as a function of time
figure(3)
semilogy(timevectorFNMcirc, errorvectorFNMcirc, ...
	timevectorRayleighcirc, errorvectorRayleighcirc)
xlabel('time (s)')
ylabel('normalized error')
legend('FNM circ', 'Rayleigh circ')
% fix_axis(gca, 2)
grid