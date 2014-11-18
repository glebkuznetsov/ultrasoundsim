% Script to evaluate the times and errors for a 5 lambda radius piston 
% (as in the FNM circle paper published in JASA in 2003) with the Rayleigh
% Sommerfeld integral.
clc;
fprintf('==============================[ Rayleighcirc.m ]==============================\n\n');
fprintf('This example calculates the continuous-wave pressure for a circular transducer\n');
fprintf('using the Rayleigh-Sommerfeld Integral. It will output a plot of the pressure,\n');
fprintf('the error of the calculation compared to the number of abscissas, the number\n');
fprintf('of abscissas compared to the execution time, and the error compared to the\n');
fprintf('execution time. Similar figures were used in the FNM circle paper published in\n');
fprintf('JASA in 2004.\n\n');

f0 = 1e6; % excitation frequency
% atten = 0; % no attenuation
soundspeed = 1500; % m/s
lambda = soundspeed / f0; % wavelength
radius = 5 * lambda; % transducer radius

% create the transducer object
transducer=get_circ(radius,[0 0 0 ], [0 0 0]);

% create the data structure that specifies the attenuation value, etc.
lossless = set_medium('lossless');

% define the computational grid
xmin = 0;
xmax = 1.5 * radius;
ymin = 0;
ymax = 0;
zmin = 0.0;
zmax = radius^2 / lambda;
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
disp('Calculating reference pressure...');
ndiv = 200;
dflag = 0;
tic
pref=fnm_call(transducer,ps,lossless,ndiv,f0,dflag);
toc

% evaluate the times and errors as a function of the number of abscissas
nabscissas = [1:200];
timevectorRayleighcirc = zeros(size(ndiv));
errorvectorRayleighcirc = zeros(size(ndiv));
for ndiv = 1:length(nabscissas)
    fprintf('Calculating pressure for ndiv = %i\n', nabscissas(ndiv));
	tic
	p = rayleigh_cw(transducer,ps,lossless,nabscissas(ndiv),f0,dflag);
	timevectorRayleighcirc(ndiv) = toc;
	errorvectorRayleighcirc(ndiv) = max(max(abs(pref - p)))/max(max(abs(pref)));
end


% show the pressure field
figure(1)
mesh(z*1000, x*1000, abs(squeeze(pref))/max(max(abs(squeeze(pref)))))
xlabel('axial distance (mm)')
ylabel('radial distance (mm)')
zlabel('normalized pressure')

% plot the times
figure(2)
plot(nabscissas, timevectorRayleighcirc)
ylabel('time (s)')
xlabel('number of abscissas')

% plot the errors
figure(3)
semilogy(nabscissas, errorvectorRayleighcirc)
xlabel('number of abscissas')
ylabel('normalized error')

% plot the errors as a function of time
figure(4)
semilogy(timevectorRayleighcirc, errorvectorRayleighcirc)
xlabel('time (s)')
ylabel('normalized error')

datestr(now)
