% Script to evaluate the times and errors as in the FNM rectangle paper 
% published in JASA in 2004.

clc;
fprintf('===================================[ FNMrect.m ]==================================\n\n');
fprintf('This example calculates the continuous-wave pressure for a rectangular transducer\n');
fprintf('using the Fast Nearfield Method. It will output a plot of the pressure, the\n');
fprintf('error of the calculation compared to the number of abscissas, the number of\n');
fprintf('abscissas compared to the execution time, and the error compared to the\n');
fprintf('execution time. These figures were used in the FNM rectangle paper published in\n');
fprintf('JASA in 2004.\n\n');

datestr(now)

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
timevectorFNMrect = zeros(1, 100);
errorvectorFNMrect = zeros(1, 100);
for ndiv = 1:100,
%    ndiv
	tic
	p = fnm_call(transducer,ps,lossless,ndiv,f0,dflag);
	timevectorFNMrect(ndiv) = toc;
	errorvectorFNMrect(ndiv) = max(max(abs(pref - p)))/max(max(abs(pref)));
end

timevectorFNMrectSSE2 = zeros(1, 100);
errorvectorFNMrectSSE2 = zeros(1, 100);
for ndiv = 1:100,
%    ndiv
	tic
	p = fnm_cw_sse(transducer,ps,lossless,ndiv,f0,dflag);
	timevectorFNMrectSSE2(ndiv) = toc;
	errorvectorFNMrectSSE2(ndiv) = max(max(abs(pref - p)))/max(max(abs(pref)));
end

% show the pressure field
figure(1)
mesh(z*1000, x*1000, abs(squeeze(pref))/max(max(abs(squeeze(pref)))))
xlabel('z (mm)')
ylabel('x (mm)')
zlabel('normalized pressure')

% plot the times
figure(2)
plot(1:100, timevectorFNMrect*1000, 1:100, timevectorFNMrectSSE2*1000)
ylabel('time (ms)')
xlabel('number of abscissas')
legend('Standard FNM','FNM with SSE2 Instructions');

% plot the errors
figure(3)
semilogy(1:100, errorvectorFNMrect, 1:100, errorvectorFNMrectSSE2)
xlabel('number of abscissas')
ylabel('normalized error')
legend('Standard FNM','FNM with SSE2 Instructions');

% plot the errors as a function of time
figure(4)
semilogy(timevectorFNMrect*1000, errorvectorFNMrect, timevectorFNMrectSSE2*1000, errorvectorFNMrectSSE2)
xlabel('time (ms)')
ylabel('normalized error')
legend('Standard FNM','FNM with SSE2 Instructions');

datestr(now)
