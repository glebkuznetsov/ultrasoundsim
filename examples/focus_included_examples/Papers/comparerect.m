clc;
fprintf('================================[ comparerect.m ]================================\n\n');
fprintf('This file compares the Fast Nearfield Method to the Rayleigh-Sommerfeld Integral\n');
fprintf('in the calculation of the pressure profile of a rectangular transducer. In\n');
fprintf('particular, it compares the execution time of each function for a given number of\n');
fprintf('abscissas and it compares the number of abscissas each technique requires in order\n');
fprintf('to achieve a given error.\n\n');

% Check for required variables and run the required scripts
if(~exist('timevectorFNMrect','var') || ~exist('errorvectorFNMrect','var'))
    warning('FNMrect.m has not been run. Running it now to generate required data.');
    FNMrect;
end

if(~exist('timevectorRayleighrect','var') || ~exist('errorvectorRayleighrect','var'))
    warning('Rayleighrect.m has not been run. Running it now to generate required data.');
    Rayleighrect;
end

% plot the times
figure(4)
plot(1:length(timevectorFNMrect), timevectorFNMrect, ...
	(1:length(timevectorRayleighrect)) * 2, timevectorRayleighrect)
ylabel('time (s)')
xlabel('number of abscissas')
legend('FNM rect', 'Rayleigh rect')
%fix_axis(gca, 2)
grid

% plot the errors
figure(5)
semilogy(1:length(errorvectorFNMrect), errorvectorFNMrect, ...
	(1:length(errorvectorRayleighrect)) * 2, errorvectorRayleighrect)
xlabel('number of abscissas')
ylabel('normalized error')
legend('FNM rect', 'Rayleigh rect')
%fix_axis(gca, 2)
grid

% plot the errors as a function of time
figure(6)
semilogy(timevectorFNMrect, errorvectorFNMrect, ...
	timevectorRayleighrect, errorvectorRayleighrect)
xlabel('time (s)')
ylabel('normalized error')
legend('FNM rect', 'Rayleigh rect')
%fix_axis(gca, 2)
grid