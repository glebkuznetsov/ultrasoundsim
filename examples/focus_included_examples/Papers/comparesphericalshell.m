clc;
fprintf('===========================[ comparesphericalshell.m ]===========================\n\n');
fprintf('This file compares the Fast Nearfield Method to the Rayleigh-Sommerfeld Integral\n');
fprintf('in the calculation of the pressure profile of a spherical shell transducer. In\n');
fprintf('particular, it compares the execution time of each function for a given number of\n');
fprintf('abscissas and it compares the number of abscissas each technique requires in order\n');
fprintf('to achieve a given error.\n\n');

% Check for required variables and run the scripts if necessary
if(~exist('FNMtimesphere','var') || ~exist('FNMerrorsphere','var'))
    warning('FNMsphericalshell.m has not been run. Running it to generate required data.');
    FNMsphericalshell;
end
if(~exist('RStimesphere','var') || ~exist('RSerrorsphere','var'))
    warning('Rayleighsphericalshell.m has not been run. Running it to generate required data.');
    Rayleighsphericalshell;
end

% plot the times
figure(1)
plot(1:length(FNMtimesphere), FNMtimesphere, ...
	(1:length(RStimesphere)), RStimesphere)
ylabel('time (s)')
xlabel('number of abscissas')
legend('FNM spherical shell', 'Rayleigh spherical shell')
% fix_axis(gca, 2)
grid

% plot the errors
figure(2)
semilogy(1:length(FNMerrorsphere), FNMerrorsphere, ...
	(1:length(RSerrorsphere)), RSerrorsphere)
xlabel('number of abscissas')
ylabel('normalized error')
legend('FNM spherical shell', 'Rayleigh spherical shell')
% fix_axis(gca, 2)
grid

% plot the errors as a function of time
figure(3)
semilogy(FNMtimesphere, FNMerrorsphere, ...
	RStimesphere, RSerrorsphere)
xlabel('time (s)')
ylabel('normalized error')
legend('FNM spherical shell', 'Rayleigh spherical shell')
% fix_axis(gca, 2)
grid