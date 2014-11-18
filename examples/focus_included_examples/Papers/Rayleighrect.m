% Script to evaluate the times and errors as in the FNM rectangle paper,
% but using the Rayleigh Sommerfeld approach.
clc;
fprintf('================================[ Rayleighrect.m ]================================\n\n');
fprintf('This example calculates the continuous-wave pressure for a rectangular transducer\n');
fprintf('using the Rayleigh-Sommerfeld Integral. It will output a plot of the pressure,\n');
fprintf('the error of the calculation compared to the number of abscissas, the number\n');
fprintf('of abscissas compared to the execution time, and the error compared to the\n');
fprintf('execution time. Similar figures were used in the FNM circle paper published in\n');
fprintf('JASA in 2004.\n\n');

f0 = 1e6; % excitation frequency
% atten = 0; % no attenuation
soundspeed = 1500; % m/s
lambda = soundspeed / f0; % wavelength
width = 5 * lambda; % transducer width
height = 7.5 * lambda; % transducer height

% create the transducer object
transducer=get_rect(width, height, [0 0 0 ], [0 0 0]);

% create the data structure that specifies the attenuation value, etc.
lossless = set_medium('lossless');

% define the computational grid
xmin = 0;
xmax = 1.5 * width/2;
ymin = 0;
ymax = 0;
zmin = 0.0;
zmax = (width/2)^2 / lambda;
nx = 61;
ny = 1;
nz = 101;
dx = xmax / (nx - 1);
dz = zmax / (nz - 1);
ps = set_coordinate_grid([dx 0 dz],xmin,xmax,ymin,ymax,zmin,zmax);
x = xmin:dx:xmax;
y = ymin:0:ymax;
z = zmin:dz:zmax;

% generate the reference pressure field
ndiv = 200;
dflag = 0;
tic
pref=fnm_call(transducer,ps,lossless,ndiv,f0,dflag);
toc

% evaluate the times and errors as a function of the number of abscissas
clear timevectorRayleighrect errorvectorRayleighrect
% Only use an odd number of abscissas 
% This avoids division by zero on the piston face

nabscissas = [1:200];
timevectorRayleighrect = zeros(size(ndiv));
errorvectorRayleighrect = zeros(size(ndiv));
for ndiv = 1:length(nabscissas)
    fprintf('Calculating pressure for ndiv = %i\n', nabscissas(ndiv));
	tic
	p = rayleigh_cw(transducer,ps,lossless,nabscissas(ndiv),f0,dflag);
	timevectorRayleighrect(ndiv) = toc;
	errorvectorRayleighrect(ndiv) = max(max(abs(pref - p)))/max(max(abs(pref)));
end

% show the pressure field
figure(1)
mesh(z*1000, x*1000, abs(squeeze(pref))/max(max(abs(squeeze(pref)))))
xlabel('z (mm)')
ylabel('x (mm)')
zlabel('normalized pressure')

% plot the times
figure(2)
plot(nabscissas, timevectorRayleighrect)
ylabel('time (s)')
xlabel('number of abscissas')

% plot the errors
figure(3)
semilogy(nabscissas, errorvectorRayleighrect)
xlabel('number of abscissas')
ylabel('normalized error')

% plot the errors as a function of time
figure(4)
semilogy(timevectorRayleighrect, errorvectorRayleighrect)
xlabel('time (s)')
ylabel('normalized error')

datestr(now)